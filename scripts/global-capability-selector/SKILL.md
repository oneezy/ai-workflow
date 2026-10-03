---
name: global-capability-selector
description: Preview, toggle, and undo selected global Codex skills and eligible local plugins.
---

# Global capability selector

Use the deterministic Python 3.12+ helper at `scripts/selector.py`. Run it with an existing interpreter and the desktop's existing Codex backend. Do not install tools. Run `--help` for syntax; read [the operating guide](references/operations.md) before an apply or undo.

Start with `list`. Translate the user's selection into exact returned IDs. A request to build, inspect, or preview does not authorize toggles. An explicit enable/disable request authorizes that exact change; preview it, explain any blocked items, and apply the saved plan without expanding its scope. Never interpret "all" as every discovered integration. The only bulk group is `eligible-global-skills`, expanded and frozen in the preview.

Project/workspace skills and system built-ins are never targets. The helper protects this selector and rejects linked paths. Before disabling globals, review project dependencies and supply a JSON review file as described in the guide. Unknown dependencies block the change. Never fabricate a clean review. Keep a same-named project skill intact; use paths, never name-based overrides.

Local plugins with apps, MCP servers, or hooks are blocked in this version. Remote plugins, MCP tools, and connected apps are inventory-only. Hiding a plugin skill does not disable its tools. Memory settings, credentials, packages, hooks, project configuration, and development tooling are outside this helper's write scope.

Report configuration application separately from fresh-task behavior and token savings. Existing tasks retain loaded context. User-global changes can affect other tasks. Do not restart or trigger a probe task without authorization. Preserve all existing personal disables unless the user selects an enable action. Undo restores only the transaction's keys and rejects conflicts.
