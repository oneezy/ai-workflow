# Operating guide

Use an existing Python 3.12+ interpreter. This helper uses only its standard library and the desktop's existing `codex.exe app-server`. It does not use a shell to build commands, download executables, install packages, or change PATH. The default backend is the newest existing executable in `%LOCALAPPDATA%/OpenAI/Codex/bin/*/codex.exe`; use `--codex ABSOLUTE_PATH` to select a known installed version.

## Interface

Run commands against this skill's `scripts/selector.py`. Examples use `python` as shorthand for the verified existing interpreter, not an installation instruction.

```text
python scripts/selector.py list
python scripts/selector.py preview --enable --id PERSONAL_ID --out preview.json
python scripts/selector.py preview --disable --id GLOBAL_ID --dependency-review review.json --out preview.json
python scripts/selector.py preview --disable --group eligible-global-skills --dependency-review review.json --out preview.json
python scripts/selector.py apply preview.json --confirm EXACT_PLAN_ID
python scripts/selector.py undo ABSOLUTE_TRANSACTION_DIRECTORY --confirm EXACT_TRANSACTION_ID
```

Repeat `--id` for multiple exact targets. A preview writes only a new preview artifact and never overwrites one. Read its changes before apply. The confirmation value binds the command to the reviewed plan; it is not independent user authorization. Apply requires the user's request for those toggles. Keep previews and reviews outside repositories when they contain private paths.

`list` reports IDs, exact identities, source/scope, enabled state when known, and eligibility. A global personal directory with a `SKILL.md` is a candidate; `.system`, this selector, links/junctions, and paths outside the global root are excluded. Local plugin skills must also appear in supported discovery under the verified plugin cache. The current backend can advertise desktop skills that standalone discovery cannot enumerate; the helper does not invent their paths.

The explicit group expands only eligible global personal and local-plugin skills. It never includes whole plugins, project skills, system skills, MCP tools, or remote apps. Already-disabled personal skills remain disabled during a disable operation. Enabling the group is a broad enable request and must not be inferred from a coding/browser/documents preference.

## Dependency review

A live disable, including an undo that would disable a newly enabled item, needs a concrete project-dependency review. The helper cannot infer arbitrary procedural dependencies from Markdown. The invoking agent must inspect relevant project instructions and known consumers, preserve required global dependencies, and record uncertainty instead of claiming an automatic proof.

```json
{
  "projects_sha256": "value returned by list",
  "reviewed_ids": ["exact eligible IDs reviewed for this operation"],
  "protected_ids": ["IDs required by project workflows"],
  "basis": "Specific project paths and dependency evidence reviewed; unresolved consumers must be excluded."
}
```

Only list a target as reviewed when the available evidence supports the disable. Include current active/unsaved projects in that review too; the configured-project fingerprint is a stale-review guard, not a complete inventory of every project on disk. A changed configured-project set invalidates the review. If project files or active-project context change after review, regenerate the review and preview. Unknown project consumers block the operation. There is no bypass flag. This is an operator-reviewed safeguard, not machine proof that no Markdown anywhere refers to a global skill.

Whole local plugins are eligible only with confirmed global source paths, an existing boolean user toggle, and no declared apps, MCP servers, hooks, or scheduled tasks. Browser, Chrome, Computer Use, unified computer use, app coordination, and this selector are protected. Dependencies can still exist outside the package, so the review also applies to those eligible packages.

## Supported layers and limits

| Kind | Behavior in this version |
|---|---|
| Global personal skills | Exact-path enable/disable overrides; existing metadata and other entries preserved |
| Global local-plugin skills | Same override control, using current discovered cache paths; desktop catalog behavior needs a separately authorized fresh-task test |
| Eligible whole local plugins | Existing `plugins."id".enabled` boolean only; no manifest edit or install/uninstall |
| Other local plugins | Read-only when dependencies, scope, or the existing key cannot be verified |
| Remote plugins, connected apps, MCP tools | Read-only; no unsupported endpoint or assumed universal switch |

Disabling skill instructions does not disable tools. Local config is user-global and may affect other tasks; this is not a per-task desktop profile. No automatic reload or restart occurs. Existing tasks retain their loaded context. Report `config-applied` separately from fresh-task skill/tool availability. The earlier measured catalog refilled freed space with longer descriptions, so no token-saving estimate follows from the number disabled.

## Transactions and recovery

The helper re-reads configuration before writing and uses the installed app-server's versioned `config/batchWrite`. A stale preview is rejected. It edits only exact skill entries and existing eligible plugin booleans. Memory fields, authentication, hooks, packages, project settings, and unrelated configuration keys are never selected. Concurrent user memory edits therefore survive or make the preview stale.

Each apply first creates an immutable journal under `~/.codex/capability-selector/transactions/<id>/`. The journal contains owned before/after values and the plan, not a whole-config copy or credentials. `applied.json` marks successful configuration readback. An uncertain write leaves `journal.json`; inspect current owned values before deciding on undo. The helper never blindly retries a failed write.

Undo merges the journal's original skill entries into the current array and restores owned plugin booleans using the latest config version. It preserves unrelated later settings and skill entries. If an owned value or target identity changed, undo refuses instead of overwriting it. Removing a newly created skill override may leave an empty `skills.config` array; discovery semantics are restored, while formatting and empty TOML containers need not be byte-identical. If undo would disable a global, add `--dependency-review CURRENT_REVIEW.json`.

The selector cannot disable itself, so undo remains callable. Keep its installed files until outstanding transactions are resolved. Do not restore the whole config from an old backup. An unavailable backend or changed package path requires a separately reviewed recovery of the journal's exact keys.

## Validation

Run `tests/test_selector.py` with the existing interpreter. The suite uses temporary files and an in-memory config adapter. The optional `SELECTOR_TEST_BACKEND` environment variable runs an integration test against the real existing backend with a marked temporary Codex home, synthetic skills, and no auth. It never uses the live home for writes.

Live discovery is read-only. Live disable/enable and a matched fresh-task test are separate user-authorized operations. After one optional global pilot, compare the actual fresh catalog and required project workflows, then undo and verify restoration. Keep the memory setting and existing personal-skill choices exactly as the user has them at test time.
