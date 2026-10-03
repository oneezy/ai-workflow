# Global capability selector

Built September 14, 2026. Invoke `$global-capability-selector` in Codex, for example: "List eligible globals" or "Preview disabling the global PDF skill." The installed skill is [SKILL.md](C:/Users/Justin/.codex/skills/global-capability-selector/SKILL.md). Its maintained project copy is [scripts/global-capability-selector](../scripts/global-capability-selector/SKILL.md).

This release includes a Python standard-library helper, operating instructions, and regression tests. The startup catalog description is one short sentence. No existing skill or memory setting was toggled to install it.

## Interface

The skill translates natural-language requests into these helper operations:

| Operation | Result |
|---|---|
| `list` | Compact inventory with exact selectable IDs, state, and eligibility; `--json` adds provenance |
| `preview --enable/--disable --id ID --out FILE` | Frozen selection with original states and a plan ID; repeat `--id` for several items |
| `preview --disable --group eligible-global-skills ...` | Explicit bulk selection of eligible global skills only |
| `apply FILE --confirm PLAN_ID` | Version-checked local configuration edits and an owned-key recovery journal |
| `undo TRANSACTION_DIRECTORY --confirm TRANSACTION_ID` | Restore owned values while preserving unrelated later edits |

Disable operations require a recorded dependency review, including an undo that would disable an enabled item. The skill explains and prepares that review from actual project evidence. It must leave uncertain consumers out. Details and command syntax live in the [operating guide](../scripts/global-capability-selector/references/operations.md).

## Scope

Personal global skills and discovered skills from eligible local packages use exact-path overrides. Eligible whole local plugins must have an existing local boolean toggle, a proven installation source, and no declared apps, MCP servers, hooks, or scheduled tasks. A transaction selects either a whole package or its skills, never both.

Project/workspace skills, system built-ins, links into other roots, and the selector itself are excluded. The helper does not infer global ownership from UI installation alone. A project dependency review is an operator responsibility; it cannot prove that no arbitrary Markdown file refers to a global skill. Its configured-project fingerprint detects changes to the registered project set. Changed project content or active-project context requires a fresh review.

Remote plugins, MCP tools, connected apps, and local integrations with dependencies remain read-only. Their documented configuration controls have not been qualified for this desktop workflow. Local plugin-skill configuration writes work through the same tested path mechanism; actual desktop discovery after a toggle remains a separate live test. Hiding skill metadata does not remove tools.

User-global edits can affect other tasks. This is not a desktop profile per task. The helper does not reload, restart, install, uninstall, alter PATH, or edit memory, authentication, hooks, project settings, or package files. Existing loaded task context remains. No token savings are promised.

## Verification and release boundary

All 16 tests passed, including a real installed app-server test in a marked temporary Codex home. Coverage includes skill disable/enable/undo, quoted local-plugin keys, optimistic config versions, memory edits between apply and undo, preserved same-named project skills, protected dependencies, stale previews, uncertain responses without retries, altered journals, worktree sources, and marketplace path traversal. The skill-creator validator passed. Independent review found scope and journal issues that were fixed and covered by regression tests.

The five installed files matched the project copies byte for byte. Configuration bytes were unchanged during installation. Live read-only inventory found 76 personal packages including the protected selector, 12 local plugins, 16 remote plugins, 10 discovered local-plugin skills, two local MCP components, and two local app dependencies. This is the helper's bounded inventory, not the complete desktop tool catalog. Remote package components are not exhaustively enumerated.

No live toggle or fresh-task probe was performed. The next optional user-authorized validation is one exact global PDF skill disable, a fresh-task discovery check with project dependencies preserved, then undo. Preserve the user's memory setting as it exists then. Earlier [startup evidence and feasibility](research/2026-09-14/startup-context-reduction.md) explains why catalog counts alone cannot predict input-token savings.
