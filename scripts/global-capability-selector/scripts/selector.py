"""Scoped Codex global capability controls. Python 3.12+, standard library only."""
from __future__ import annotations

import argparse
import copy
import hashlib
import json
import os
from pathlib import Path
import queue
import subprocess
import sys
import threading
import time
import tempfile
import tomllib
import uuid

SELF = "global-capability-selector"
FORMAT = 1


class Refused(Exception):
    pass


def digest(value):
    if not isinstance(value, bytes):
        value = json.dumps(value, sort_keys=True, separators=(",", ":")).encode()
    return hashlib.sha256(value).hexdigest()


def normalized(path):
    return os.path.normcase(str(Path(path).resolve()))


def contained(path, root):
    return Path(normalized(path)).is_relative_to(Path(normalized(root)))


def unlinked(path):
    p = Path(path).absolute()
    for part in (p, *p.parents):
        if part.is_symlink() or (hasattr(part, "is_junction") and part.is_junction()):
            return False
    return True


def read_json(path):
    return json.loads(Path(path).read_text(encoding="utf-8"))


def write_new(path, value):
    path = Path(path)
    if not unlinked(path):
        raise Refused("Linked output path refused")
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("x", encoding="utf-8", newline="\n") as stream:
        json.dump(value, stream, indent=2, ensure_ascii=False)
        stream.write("\n")
        stream.flush()
        os.fsync(stream.fileno())


class Rpc:
    def __init__(self, executable, home):
        env = dict(os.environ, CODEX_HOME=str(home))
        self.process = subprocess.Popen(
            [str(executable), "app-server"], env=env, stdin=subprocess.PIPE,
            stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True,
            encoding="utf-8", creationflags=getattr(subprocess, "CREATE_NO_WINDOW", 0))
        self.messages = queue.Queue()
        self.counter = 0

        def consume():
            for line in self.process.stdout:
                try:
                    self.messages.put(json.loads(line))
                except ValueError:
                    pass
            self.messages.put({"eof": True})

        threading.Thread(target=consume, daemon=True).start()
        self.call("initialize", {"clientInfo": {"name": SELF, "version": "1"},
                                 "capabilities": {"experimentalApi": True}})
        self.process.stdin.write('{"method":"initialized","params":{}}\n')
        self.process.stdin.flush()

    def call(self, method, params):
        self.counter += 1
        number = self.counter
        self.process.stdin.write(json.dumps({"id": number, "method": method,
                                             "params": params}) + "\n")
        self.process.stdin.flush()
        deadline = time.monotonic() + 30
        while True:
            try:
                message = self.messages.get(timeout=max(.01, deadline - time.monotonic()))
            except queue.Empty:
                raise Refused(f"Timeout during {method}; do not blindly retry a write")
            if message.get("eof"):
                raise Refused("Backend closed; inspect transaction before retrying")
            if message.get("id") == number:
                if "error" in message:
                    raise Refused(f"{method} rejected, code {message['error'].get('code')}")
                return message["result"]

    def close(self):
        self.process.terminate()
        try:
            self.process.wait(timeout=5)
        except subprocess.TimeoutExpired:
            self.process.kill()


class Store:
    def __init__(self, home, rpc):
        self.home = Path(home).resolve()
        self.path = self.home / "config.toml"
        self.rpc = rpc

    def read(self):
        if not unlinked(self.path):
            raise Refused("Linked configuration path refused")
        raw = self.path.read_bytes()
        state = self.rpc.call("config/read", {"includeLayers": True})
        if raw != self.path.read_bytes():
            raise Refused("Configuration changed during read; retry preview")
        versions = []
        for layer in state.get("layers") or []:
            metadata = layer.get("metadata", layer)
            source = metadata.get("name", {})
            if source.get("type") == "user" and normalized(source.get("file", "")) == normalized(self.path):
                versions.append(metadata["version"])
        if len(versions) != 1:
            raise Refused("Cannot identify one versioned user config layer; writes unavailable")
        return {"config": tomllib.loads(raw.decode("utf-8-sig")), "sha256": digest(raw),
                "version": versions[0]}

    def write(self, snapshot, edits):
        if digest(self.path.read_bytes()) != snapshot["sha256"]:
            raise Refused("Configuration conflict; generate a new preview")
        return self.rpc.call("config/batchWrite", {
            "filePath": str(self.path), "expectedVersion": snapshot["version"],
            "reloadUserConfig": False, "edits": edits})


def capability(kind, identity, name, **kwargs):
    return {"id": kind + ":" + digest(identity)[:16], "kind": kind,
            "identity": identity, "name": name, **kwargs}


def skill_value(config, path):
    matches = [x for x in config.get("skills", {}).get("config", [])
               if x.get("path") and normalized(x["path"]) == normalized(path)]
    if len(matches) > 1:
        raise Refused("Duplicate exact skill overrides; resolve separately")
    return copy.deepcopy(matches[0]) if matches else None


def global_plugin_source(home, market, name, source):
    if not source or not unlinked(source):
        return False
    roots = [home / "plugins" / "cache" / market / name,
             home / ".tmp" / "bundled-marketplaces" / market / "plugins" / name,
             home.parent / ".cache" / "codex-runtimes" / "codex-primary-runtime" /
             "plugins" / market / "plugins" / name]
    return any(contained(source, root) for root in roots)


def inventory(home, config, rpc):
    home = Path(home).resolve()
    rows = []
    personal = home / "skills"
    if personal.exists():
        for package in sorted(personal.iterdir()):
            path = package / "SKILL.md"
            if package.name.casefold() == ".system" or not path.is_file():
                continue
            eligible = (package.name.casefold() != SELF and unlinked(path) and contained(path, personal))
            override = skill_value(config, path)
            rows.append(capability("personal-skill", normalized(path), package.name,
                                   eligible=eligible, scope="user-global",
                                   enabled=(override or {}).get("enabled", True),
                                   reason="" if eligible else "Selector or linked path protected"))
    installed = rpc.call("plugin/installed", {"cwds": [str(home)]})
    if installed.get("marketplaceLoadErrors"):
        raise Refused("Incomplete plugin inventory; no preview until discovery succeeds")
    local_plugins = {}
    for market in installed.get("marketplaces", []):
        for item in market.get("plugins", []):
            if not item.get("installed"):
                continue
            identity = item["id"]
            is_local = item.get("source", {}).get("type") == "local"
            detail = {}
            if is_local:
                detail = rpc.call("plugin/read", {"pluginName": item["name"],
                                  "marketplacePath": market["path"]})["plugin"]
            source_path = item.get("source", {}).get("path", "")
            global_source = global_plugin_source(home, market["name"], item["name"], source_path)
            special = item["name"] in {"browser", "chrome", "computer-use", "codex-app-tools", "unified-computer-use", SELF}
            isolated = not any(detail.get(k) for k in ("apps", "mcpServers", "hooks", "scheduledTasks"))
            existing_bool = isinstance(config.get("plugins", {}).get(identity, {}).get("enabled"), bool)
            eligible = is_local and global_source and isolated and existing_bool and not special
            row = capability("local-plugin" if is_local else "remote-plugin", identity, item["name"],
                             enabled=item["enabled"], scope="user-global" if global_source else "remote-or-unverified",
                             eligible=eligible, reason="" if eligible else "Read-only: remote, dependencies, ownership, or absent local toggle",
                             source=source_path if is_local else "remote")
            rows.append(row)
            if is_local and global_source:
                local_plugins[identity] = row
            for server in detail.get("mcpServers", []):
                rows.append(capability("mcp", identity + "/" + server, server, eligible=False,
                                       scope="plugin", reason="Read-only: tool/dependency behavior not qualified"))
            for app in detail.get("apps", []):
                rows.append(capability("connected-app", app["id"], app.get("name", app["id"]),
                                       eligible=False, scope="connector", reason="Read-only: remote control not qualified"))
    discovered = rpc.call("skills/list", {"cwds": [str(home)], "forceReload": True})
    for entry in discovered.get("data", []):
        if entry.get("errors"):
            raise Refused("Skill discovery errors; no preview")
        for skill in entry.get("skills", []):
            path = Path(skill["path"])
            cache = home / "plugins" / "cache"
            if not contained(path, cache) or not unlinked(path):
                continue
            parts = Path(normalized(path)).relative_to(Path(normalized(cache))).parts
            if len(parts) < 4:
                continue
            identity = parts[1] + "@" + parts[0]
            if identity not in local_plugins:
                continue  # Desktop-only remote skill paths are not guessed from cache versions.
            override = skill_value(config, path)
            parent = local_plugins[identity]
            rows.append(capability("plugin-skill", normalized(path), skill["name"],
                                   plugin=identity, eligible=parent["eligible"], scope="user-global",
                                   enabled=(override or {}).get("enabled", skill.get("enabled", True)),
                                   reason="" if parent["eligible"] else "Parent package is protected or not qualified"))
    unique = {row["id"]: row for row in rows}
    return sorted(unique.values(), key=lambda x: (x["kind"], x["name"]))


def project_fingerprint(config):
    """Bind an operator's dependency review to the configured project set."""
    return digest(config.get("projects", {}))


def check_review(config, changes, review):
    if not review or review.get("projects_sha256") != project_fingerprint(config):
        raise Refused("Disable requires a dependency review for the current project set")
    approved = set(review.get("reviewed_ids", []))
    protected = set(review.get("protected_ids", []))
    if any(row["id"] not in approved or row["id"] in protected for row in changes):
        raise Refused("Selected global has unknown or protected project dependencies")
    if len(review.get("basis", "").strip()) < 20:
        raise Refused("Record concrete dependency review evidence")


def make_plan(home, snapshot, rows, ids, group, enabled, review=None):
    if bool(ids) == bool(group):
        raise Refused("Choose exact IDs or one explicit group")
    by_id = {row["id"]: row for row in rows}
    if group:
        ids = [row["id"] for row in rows if row["eligible"] and row["kind"] in {"personal-skill", "plugin-skill"}]
    if not ids or len(set(ids)) != len(ids):
        raise Refused("Empty or duplicate selection")
    selected = []
    for key in ids:
        if key not in by_id or not by_id[key]["eligible"]:
            raise Refused(f"Unknown or protected target: {key}")
        row = copy.deepcopy(by_id[key])
        if row["kind"].endswith("skill"):
            before = skill_value(snapshot["config"], row["identity"])
            if before is not None and before.get("enabled", True) == enabled:
                continue
            # Do not materialize an enabled override when the default is already enabled.
            if before is None and row.get("enabled", True) == enabled:
                continue
            after = {**(before or {}), "path": row["identity"], "enabled": enabled}
        else:
            before = snapshot["config"]["plugins"][row["identity"]]["enabled"]
            after = enabled
            if before == after:
                continue
        row.update(before=before, after=after)
        selected.append(row)
    if selected and not enabled:
        check_review(snapshot["config"], selected, review)
    body = {"format": FORMAT, "home": normalized(home), "config_sha256": snapshot["sha256"],
            "config_version": snapshot["version"], "projects_sha256": project_fingerprint(snapshot["config"]),
            "enabled": enabled, "changes": selected, "dependency_review": review if not enabled else None}
    return {**body, "plan_id": digest(body)}


def verify_plan(plan, home):
    body = {k: v for k, v in plan.items() if k != "plan_id"}
    if plan.get("format") != FORMAT or plan.get("plan_id") != digest(body):
        raise Refused("Invalid plan or changed plan contents")
    if plan["home"] != normalized(home):
        raise Refused("Plan belongs to another Codex home")
    for row in plan["changes"]:
        validate_change(row)
        after = row["after"].get("enabled") if row["kind"].endswith("skill") else row["after"]
        if after is not plan["enabled"]:
            raise Refused("Mixed or inconsistent plan actions")


def validate_change(row):
    kind = row["kind"]
    if kind not in {"personal-skill", "plugin-skill", "local-plugin"}:
        raise Refused("Unsupported mutation layer")
    if row["id"] != capability(kind, row["identity"], "")["id"]:
        raise Refused("Identity does not match capability ID")
    for key in ("before", "after"):
        value = row[key]
        if kind.endswith("skill"):
            if value is None and key == "before":
                continue
            if (not isinstance(value, dict) or not set(value) <= {"path", "enabled"}
                    or not isinstance(value.get("path"), str)
                    or normalized(value["path"]) != row["identity"]
                    or not isinstance(value.get("enabled", True), bool)):
                raise Refused("Skill override must contain only this exact path and boolean state")
        elif not isinstance(value, bool):
            raise Refused("Plugin mutation requires existing boolean before and after values")


def make_edits(config, changes, undo=False):
    entries = copy.deepcopy(config.get("skills", {}).get("config", []))
    edits = []
    skill_changed = False
    for row in changes:
        validate_change(row)
        expected, wanted = (row["after"], row["before"]) if undo else (row["before"], row["after"])
        if row["kind"] in {"personal-skill", "plugin-skill"}:
            if skill_value(config, row["identity"]) != expected:
                raise Refused("Owned skill value changed; no automatic overwrite")
            entries = [x for x in entries if not x.get("path") or normalized(x["path"]) != row["identity"]]
            if wanted is not None:
                entries.append(copy.deepcopy(wanted))
            skill_changed = True
        elif row["kind"] == "local-plugin":
            current = config.get("plugins", {}).get(row["identity"], {}).get("enabled")
            if current != expected or not isinstance(wanted, bool):
                raise Refused("Owned plugin value changed or absent; no automatic overwrite")
            edits.append({"keyPath": "plugins." + json.dumps(row["identity"]) + ".enabled",
                          "value": wanted, "mergeStrategy": "replace"})
        else:
            raise Refused("Unsupported mutation layer")
    if skill_changed:
        edits.append({"keyPath": "skills.config", "value": entries, "mergeStrategy": "replace"})
    return edits


def verify_values(config, changes, undo=False):
    for row in changes:
        wanted = row["before"] if undo else row["after"]
        value = (skill_value(config, row["identity"]) if row["kind"].endswith("skill")
                 else config.get("plugins", {}).get(row["identity"], {}).get("enabled"))
        if value != wanted:
            raise Refused("Write outcome not verified; inspect journal before retrying")


def apply_plan(store, plan, rows, state_dir):
    verify_plan(plan, store.home)
    now = store.read()
    if now["sha256"] != plan["config_sha256"] or now["version"] != plan["config_version"]:
        # Repeating a completed selection may report no-op but must never rewrite a newer file.
        allowed = {row["id"]: row for row in rows if row["eligible"]}
        if plan["changes"] and all(r["id"] in allowed and allowed[r["id"]]["identity"] == r["identity"] for r in plan["changes"]):
            try:
                verify_values(now["config"], plan["changes"])
                return {"status": "no-op; selected values already match; no write"}
            except Refused:
                pass
        raise Refused("Stale preview; configuration changed, regenerate preview")
    # Rebuild rather than trusting editable plan rows as authorization to arbitrary paths.
    rebuilt = make_plan(store.home, now, rows, [r["id"] for r in plan["changes"]], None,
                        plan["enabled"], plan["dependency_review"]) if plan["changes"] else plan
    if rebuilt != plan:
        raise Refused("Inventory or ownership changed; regenerate preview")
    edits = make_edits(now["config"], plan["changes"])
    if not edits:
        return {"status": "no-op"}
    transaction = uuid.uuid4().hex
    folder = Path(state_dir) / transaction
    journal = {"transaction": transaction, "plan": plan, "status": "prepared"}
    write_new(folder / "journal.json", journal)
    try:
        store.write(now, edits)
        verify_values(store.read()["config"], plan["changes"])
    except Exception:
        # The prepared record survives uncertain replies. Never automatically repeat a write.
        raise Refused(f"Apply not confirmed; inspect transaction {folder}. No retry was made")
    write_new(folder / "applied.json", {"status": "config-applied", "plan_id": plan["plan_id"]})
    return {"status": "config-applied; fresh-task behavior unverified", "transaction": str(folder)}


def undo_plan(store, transaction, rows, confirm, review=None):
    folder = Path(transaction)
    record = read_json(folder / "journal.json")
    plan = record["plan"]
    verify_plan(plan, store.home)
    if confirm != record["transaction"]:
        raise Refused("Undo confirmation must match transaction ID")
    if (folder / "undone.json").exists():
        return {"status": "already-undone"}
    # Recheck exact identities, links and package protection even after package upgrades.
    allowed = {r["id"]: r for r in rows if r["eligible"]}
    if any(r["id"] not in allowed or allowed[r["id"]]["identity"] != r["identity"]
           or allowed[r["id"]]["kind"] != r["kind"] for r in plan["changes"]):
        raise Refused("Target ownership changed; manual scoped recovery required")
    now = store.read()
    # Reversing an enable could now disable a required global. Do not silently use an old review.
    disabling = [row for row in plan["changes"] if
                 ((row["before"] or {}).get("enabled", True) is False if row["kind"].endswith("skill")
                  else row["before"] is False)]
    if disabling:
        check_review(now["config"], disabling, review)
    edits = make_edits(now["config"], plan["changes"], undo=True)
    store.write(now, edits)
    verify_values(store.read()["config"], plan["changes"], undo=True)
    write_new(folder / "undone.json", {"status": "restored-owned-values"})
    return {"status": "restored-owned-values; fresh-task behavior unverified"}


def backend_path(override=None):
    if override:
        path = Path(override)
    else:
        root = Path(os.environ.get("LOCALAPPDATA", "")) / "OpenAI" / "Codex" / "bin"
        candidates = list(root.glob("*/codex.exe"))
        if not candidates:
            raise Refused("Supply --codex with an existing desktop backend; no installer is run")
        path = max(candidates, key=lambda p: p.stat().st_mtime)
    if not path.is_absolute() or not path.is_file():
        raise Refused("Backend must be an existing absolute executable path")
    return path


def validate_home(home):
    if not unlinked(home):
        raise Refused("Linked Codex home refused")
    if normalized(home) == normalized(Path.home() / ".codex"):
        return
    # Explicit isolated testing is allowed, but a repository .codex is never a global home.
    marker = Path(home) / ".selector-test-home"
    if (contained(home, tempfile.gettempdir()) and marker.is_file()
            and marker.read_text(encoding="utf-8") == SELF
            and not (Path(home) / "auth.json").exists()):
        return
    raise Refused("Only the user's global .codex or a marked temporary test home is supported")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--home", type=Path, default=Path(os.environ.get("CODEX_HOME", Path.home() / ".codex")))
    parser.add_argument("--codex", help="Existing desktop backend executable")
    sub = parser.add_subparsers(dest="command", required=True)
    sub.add_parser("list")
    preview = sub.add_parser("preview")
    mode = preview.add_mutually_exclusive_group(required=True)
    mode.add_argument("--enable", action="store_true")
    mode.add_argument("--disable", action="store_true")
    target = preview.add_mutually_exclusive_group(required=True)
    target.add_argument("--id", action="append")
    target.add_argument("--group", choices=["eligible-global-skills"])
    preview.add_argument("--dependency-review", type=Path)
    preview.add_argument("--out", required=True, type=Path)
    apply = sub.add_parser("apply")
    apply.add_argument("plan", type=Path)
    apply.add_argument("--confirm", required=True, help="Exact plan_id from reviewed preview")
    undo = sub.add_parser("undo")
    undo.add_argument("transaction", type=Path)
    undo.add_argument("--confirm", required=True, help="Exact transaction ID")
    undo.add_argument("--dependency-review", type=Path, help="Required when undo would disable a global")
    args = parser.parse_args()
    rpc = None
    try:
        home = args.home.resolve()
        validate_home(args.home)
        rpc = Rpc(backend_path(args.codex), home)
        store = Store(home, rpc)
        snapshot = store.read()
        rows = inventory(home, snapshot["config"], rpc)
        if args.command == "list":
            result = {"home": str(home), "projects_sha256": project_fingerprint(snapshot["config"]),
                      "capabilities": rows, "notice": "Global scope; remote/MCP/app controls are read-only. No settings changed."}
        elif args.command == "preview":
            review = read_json(args.dependency_review) if args.dependency_review else None
            plan = make_plan(home, snapshot, rows, args.id, args.group, args.enable, review)
            write_new(args.out, plan)
            result = {"plan": str(args.out), "plan_id": plan["plan_id"], "changes": plan["changes"],
                      "notice": "Preview only. Apply changes user-global settings and can affect other tasks."}
        elif args.command == "apply":
            plan = read_json(args.plan)
            if args.confirm != plan.get("plan_id"):
                raise Refused("Confirmation does not match reviewed plan")
            state = home / "capability-selector" / "transactions"
            result = apply_plan(store, plan, rows, state)
        else:
            expected_root = home / "capability-selector" / "transactions"
            if not contained(args.transaction, expected_root) or not unlinked(args.transaction):
                raise Refused("Undo requires this home's original transaction directory")
            review = read_json(args.dependency_review) if args.dependency_review else None
            result = undo_plan(store, args.transaction, rows, args.confirm, review)
        print(json.dumps(result, indent=2, ensure_ascii=False))
        return 0
    except (Refused, OSError, ValueError, KeyError) as error:
        print(json.dumps({"status": "refused", "reason": str(error)}))
        return 2
    finally:
        if rpc:
            rpc.close()


if __name__ == "__main__":
    sys.exit(main())
