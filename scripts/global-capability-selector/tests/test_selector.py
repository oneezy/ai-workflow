"""Behavioral regression tests. All writes use temporary, synthetic homes."""
import copy
import importlib.util
import json
import os
from pathlib import Path
import tempfile
import unittest

script = Path(__file__).resolve().parents[1] / "scripts" / "selector.py"
spec = importlib.util.spec_from_file_location("selector", script)
s = importlib.util.module_from_spec(spec)
spec.loader.exec_module(s)


class FakeStore:
    def __init__(self, home, config):
        self.home = home
        self.config = copy.deepcopy(config)
        self.writes = 0

    def read(self):
        return {"config": copy.deepcopy(self.config), "version": s.digest(self.config),
                "sha256": s.digest(self.config)}

    def write(self, snapshot, edits):
        if snapshot["version"] != s.digest(self.config):
            raise s.Refused("version conflict")
        for edit in edits:
            if edit["keyPath"] == "skills.config":
                self.config.setdefault("skills", {})["config"] = copy.deepcopy(edit["value"])
            else:
                identity = json.loads(edit["keyPath"][8:-8])
                self.config["plugins"][identity]["enabled"] = edit["value"]
        self.writes += 1


class InventoryRpc:
    def __init__(self, home, plugin_source=None):
        self.home = home
        self.source = plugin_source

    def call(self, method, params):
        if method == "plugin/installed":
            plugins = [] if self.source is None else [{"id": "example@test", "name": "example",
                       "installed": True, "enabled": True, "source": {"type": "local", "path": str(self.source)}}]
            return {"marketplaces": [{"name": "test", "path": str(self.home / "market.json"), "plugins": plugins}]}
        if method == "plugin/read":
            return {"plugin": {"apps": [], "mcpServers": [], "hooks": [], "skills": []}}
        if method == "skills/list":
            return {"data": [{"skills": [], "errors": []}]}
        raise AssertionError(method)


class SelectorTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix="selector-test-")
        self.addCleanup(self.tmp.cleanup)
        self.home = Path(self.tmp.name) / ".codex"
        self.home.mkdir()
        self.skill = self.home / "skills" / "example" / "SKILL.md"
        self.skill.parent.mkdir(parents=True)
        self.skill.write_text("---\nname: example\ndescription: Fixture\n---\n", encoding="utf-8")
        self.project = Path(self.tmp.name) / "project" / ".agents" / "skills" / "example" / "SKILL.md"
        self.project.parent.mkdir(parents=True)
        self.project.write_text("Project-owned fixture", encoding="utf-8")
        self.config = {"memories": {"use_memories": False, "generate_memories": True},
                       "projects": {str(self.project.parents[3]): {"trust_level": "trusted"}},
                       "skills": {"config": []}, "plugins": {"example@test": {"enabled": True}}}
        self.store = FakeStore(self.home, self.config)
        self.rows = s.inventory(self.home, self.config, InventoryRpc(self.home))
        self.row = self.rows[0]

    def review(self):
        return {"projects_sha256": s.project_fingerprint(self.store.config),
                "reviewed_ids": [self.row["id"]], "protected_ids": [],
                "basis": "Synthetic project fixture has no global dependencies; test only."}

    def plan(self, enabled=False):
        return s.make_plan(self.home, self.store.read(), self.rows, [self.row["id"]], None,
                           enabled, self.review())

    def apply(self, plan):
        return s.apply_plan(self.store, plan, self.rows, self.home / "transactions")

    def test_roundtrip_preserves_project_memory_and_unrelated_skill(self):
        original = self.project.read_bytes()
        plan = self.plan()
        result = self.apply(plan)
        self.store.config["memories"]["use_memories"] = True
        unrelated = {"path": str(self.home / "skills" / "other" / "SKILL.md"), "enabled": False}
        self.store.config["skills"]["config"].append(unrelated)
        transaction = Path(result["transaction"])
        s.undo_plan(self.store, transaction, self.rows, transaction.name)
        self.assertEqual(self.store.config["skills"]["config"], [unrelated])
        self.assertTrue(self.store.config["memories"]["use_memories"])
        self.assertEqual(self.project.read_bytes(), original)

    def test_system_self_and_project_are_not_eligible(self):
        for name in (".system", s.SELF):
            p = self.home / "skills" / name / "SKILL.md"
            p.parent.mkdir(); p.write_text("fixture")
        rows = s.inventory(self.home, self.config, InventoryRpc(self.home))
        allowed = [r["identity"] for r in rows if r["eligible"]]
        self.assertEqual(allowed, [s.normalized(self.skill)])
        with self.assertRaises(s.Refused):
            s.make_plan(self.home, self.store.read(), rows, ["personal-skill:project"], None, False, self.review())

    def test_no_disable_without_review_or_with_protected_dependency(self):
        for review in (None, {**self.review(), "protected_ids": [self.row["id"]]},
                       {**self.review(), "projects_sha256": "stale"}):
            with self.assertRaises(s.Refused):
                s.make_plan(self.home, self.store.read(), self.rows, [self.row["id"]], None, False, review)
        self.assertEqual(self.store.writes, 0)

    def test_stale_preview_after_memory_edit_does_not_write(self):
        plan = self.plan()
        self.store.config["memories"]["use_memories"] = True
        with self.assertRaises(s.Refused):
            self.apply(plan)
        self.assertEqual(self.store.writes, 0)

    def test_repeat_apply_is_noop(self):
        plan = self.plan()
        self.apply(plan)
        self.assertIn("no-op", self.apply(plan)["status"])
        self.assertEqual(self.store.writes, 1)

    def test_owned_conflict_refuses_undo(self):
        result = self.apply(self.plan())
        self.store.config["skills"]["config"][0]["enabled"] = True
        tx = Path(result["transaction"])
        with self.assertRaises(s.Refused):
            s.undo_plan(self.store, tx, self.rows, tx.name)
        self.assertEqual(self.store.writes, 1)

    def test_altered_journal_cannot_insert_project_skill(self):
        result = self.apply(self.plan())
        tx = Path(result["transaction"])
        record = s.read_json(tx / "journal.json")
        record["plan"]["changes"][0]["before"] = {"path": str(self.project), "enabled": False}
        record["plan"]["plan_id"] = s.digest({k: v for k, v in record["plan"].items() if k != "plan_id"})
        (tx / "journal.json").write_text(json.dumps(record), encoding="utf-8")
        with self.assertRaises(s.Refused):
            s.undo_plan(self.store, tx, self.rows, tx.name)
        self.assertEqual(self.store.writes, 1)
        self.assertNotIn(str(self.project), json.dumps(self.store.config["skills"]))

    def test_project_source_under_worktrees_is_blocked(self):
        source = self.home / "worktrees" / "id" / "repo" / "plugins" / "example"
        source.mkdir(parents=True)
        rows = s.inventory(self.home, self.config, InventoryRpc(self.home, source))
        self.assertFalse(next(r for r in rows if r["kind"] == "local-plugin")["eligible"])

    def test_local_plugin_boolean_roundtrip(self):
        source = self.home / ".tmp" / "bundled-marketplaces" / "test" / "plugins" / "example"
        source.mkdir(parents=True)
        self.rows = s.inventory(self.home, self.config, InventoryRpc(self.home, source))
        self.row = next(r for r in self.rows if r["kind"] == "local-plugin")
        self.assertTrue(self.row["eligible"])
        result = self.apply(self.plan())
        self.assertFalse(self.store.config["plugins"]["example@test"]["enabled"])
        tx = Path(result["transaction"])
        s.undo_plan(self.store, tx, self.rows, tx.name)
        self.assertTrue(self.store.config["plugins"]["example@test"]["enabled"])

    def test_enable_then_undo_requires_current_review(self):
        self.store.config["skills"]["config"] = [{"path": self.row["identity"], "enabled": False}]
        result = self.apply(self.plan(True))
        tx = Path(result["transaction"])
        with self.assertRaises(s.Refused):
            s.undo_plan(self.store, tx, self.rows, tx.name)
        s.undo_plan(self.store, tx, self.rows, tx.name, self.review())
        self.assertFalse(self.store.config["skills"]["config"][0]["enabled"])

    def test_group_excludes_protected_and_whole_plugins(self):
        protected = s.capability("personal-skill", "protected", "protected", eligible=False)
        plugin = s.capability("local-plugin", "example@test", "example", eligible=True)
        plan = s.make_plan(self.home, self.store.read(), self.rows + [protected, plugin], None,
                           "eligible-global-skills", False, self.review())
        self.assertEqual([r["id"] for r in plan["changes"]], [self.row["id"]])

    def test_custom_project_home_refused(self):
        with self.assertRaises(s.Refused):
            s.validate_home(self.project.parents[3] / ".codex")

    def test_uncertain_reply_leaves_recovery_journal_and_no_retry(self):
        real_write = self.store.write
        def uncertain(snapshot, edits):
            real_write(snapshot, edits)
            raise s.Refused("simulated lost response")
        self.store.write = uncertain
        with self.assertRaises(s.Refused):
            self.apply(self.plan())
        self.assertEqual(self.store.writes, 1)
        journals = list((self.home / "transactions").glob("*/journal.json"))
        self.assertEqual(len(journals), 1)
        self.assertFalse((journals[0].parent / "applied.json").exists())

    @unittest.skipUnless(os.environ.get("SELECTOR_TEST_BACKEND"), "Existing backend opt-in required")
    def test_real_backend_only_in_isolated_home(self):
        (self.home / ".selector-test-home").write_text(s.SELF, encoding="utf-8")
        (self.home / "config.toml").write_text('[memories]\nuse_memories = false\n[plugins."example@test"]\nenabled = true\n', encoding="utf-8")
        s.validate_home(self.home)
        rpc = s.Rpc(os.environ["SELECTOR_TEST_BACKEND"], self.home)
        try:
            store = s.Store(self.home, rpc)
            snap = store.read()
            review = {**self.review(), "projects_sha256": s.project_fingerprint(snap["config"])}
            plan = s.make_plan(self.home, snap, self.rows, [self.row["id"]], None, False, review)
            result = s.apply_plan(store, plan, self.rows, self.home / "transactions")
            self.assertFalse(s.skill_value(store.read()["config"], self.row["identity"])["enabled"])
            # Separate supported write simulates a concurrent user memory edit after apply.
            store.write(store.read(), [{"keyPath": "memories.use_memories", "value": True, "mergeStrategy": "replace"}])
            tx = Path(result["transaction"])
            s.undo_plan(store, tx, self.rows, tx.name)
            self.assertIsNone(s.skill_value(store.read()["config"], self.row["identity"]))
            self.assertTrue(store.read()["config"]["memories"]["use_memories"])
            # Qualify quoted plugin identity and optimistic concurrency on the actual protocol.
            initial = store.read()
            store.write(initial, [{"keyPath": 'plugins."example@test".enabled', "value": False, "mergeStrategy": "replace"}])
            self.assertFalse(store.read()["config"]["plugins"]["example@test"]["enabled"])
            with self.assertRaises(s.Refused):
                store.write(initial, [{"keyPath": 'plugins."example@test".enabled', "value": True, "mergeStrategy": "replace"}])
        finally:
            rpc.close()


if __name__ == "__main__":
    unittest.main(verbosity=2)
