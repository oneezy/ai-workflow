# Startup context reduction: verified results

September 14, 2026. AI Workflow owns configuration changes and synthesis. The [startup evidence task](codex://threads/01a0a2a9-69d3-7931-b777-1e33d511e2f8) owns trace extraction. Justin approved the temporary memory test, then explicitly approved leaving memory use off and disabling all personal Windows skills.

## Current state

Windows `C:/Users/Justin/.codex/config.toml` now has `memories.use_memories=false` and 75 exact personal-skill `[[skills.config]]` entries with `enabled=false`. `memories.generate_memories=true` remains unchanged. All 255 inventoried files across the 75 personal packages retain their hashes. No memory notes or skill files were deleted, moved, or rewritten.

The change excludes `.system` built-ins, plugin/cache packages, project-local skills, and Ubuntu installations. Hook flags, global instructions, authentication, skill-catalog cap, and tool installations were untouched. No app restart occurred. Existing active tasks retain context already loaded.

## Matched fresh-task measurements

All three authorized projectless tasks received the same prompt to reply READY without tools, reads, or writes. Each made one request and complied.

| First-request measure | Original baseline | Memory use off | Memory use off and personal skills disabled |
|---|---:|---:|---:|
| Input including cached | 32,417 | 28,503 | 28,369 |
| Cached input | 19,584 | 19,584 | 19,584 |
| Uncached input | 12,833 | 8,919 | 8,785 |
| Output, including reasoning | 36 | 41 | 5 |
| Request total | 32,453 | 28,544 | 28,374 |

Memory use off saved 3,914 input tokens, 12.07%. The additional personal-skill disables saved 134 input tokens, 0.47% relative to memory-off-only. Combined savings were 4,048 input tokens, 12.49% relative to the original baseline. These are observed request differences, not exact tokenizer allocations to individual components.

| Probe | Task ID | First usage event, UTC |
|---|---|---|
| Baseline | `01a0a2b6-530c-7bc1-8a7f-1889d37108d6` | September 15, 01:37:40.293, rollout line 15 |
| Memory off | `01a0a2b7-0559-7543-b447-e4c3bb507501` | September 15, 01:38:25.869, rollout line 15 |
| Combined | `01a0a2bd-7235-7c42-bf40-3cb518fd5eff` | September 15, 01:45:27.155, rollout line 13 |

These times fall on September 14 in Chicago. Read-back evidence: [baseline metadata](C:/Users/Justin/Documents/Codex/2026-09-14/justin-requests-a-separate-investigation-into/outputs/baseline-startup-evidence.json), [memory-off metadata](C:/Users/Justin/Documents/Codex/2026-09-14/justin-requests-a-separate-investigation-into/outputs/treatment-startup-evidence.json), [combined metadata](C:/Users/Justin/Documents/Codex/2026-09-14/justin-requests-a-separate-investigation-into/outputs/combined-startup-evidence.json), [catalog comparison](C:/Users/Justin/Documents/Codex/2026-09-14/justin-requests-a-separate-investigation-into/outputs/combined-catalog-comparison.json).

Each task's first cumulative thread/turn usage equals its first request, because it made only one request. This does not describe cumulative usage or current context in the planning or voice tasks. Cached tokens remain input context; caching reuses computation rather than freeing those tokens from the window. [OpenAI caching](https://developers.openai.com/api/docs/guides/prompt-caching).

Justin reported seeing 29K in the UI. The memory-off request total 28,544 would round to 29K under the previously inspected indicator logic. This is consistent with his observation but does not identify which task he viewed. The combined total 28,374 would round to 28K.

## What actually disappeared

Baseline included a 9,526-character memory summary plus 6,867 characters of memory guidance, delimiters, and whitespace, excluding its heading. Both summary and guidance disappeared in the two memory-off probes without restarting. Disabling generation alone would not have produced this effect; use and generation have separate controls. Saved files remain available for a later explicitly scoped read. [Memory controls](https://learn.chatgpt.com/docs/customization/memories).

The desktop catalog changed from 112 entries to 96. All 16 previously visible personal entries disappeared. The 75 disabled packages were not all initially advertised, so package count and prompt-catalog count differ.

| Catalog | Before | Combined |
|---|---:|---:|
| Personal skill entries | 16 | 0 |
| Built-in entries | 5 | 5 |
| Plugin/cache entries | 91 | 91 |
| Total catalog characters | 22,119 | 22,111 |

The retained descriptions grew from 12,242 to 14,962 characters; 91 descriptions expanded. Removing personal entries therefore freed space that the bounded catalog used for longer remaining descriptions. The disables worked, but did not substantially shrink the catalog. No remaining skill names were added, and retained paths matched.

The remaining 91 plugin entries comprise Vercel 54, Figma 12, Google Drive 5, OpenAI Developers 5, Sites 2, Spreadsheets 2, Supabase 2, and one each from computer use, deep research, documents, PDF, plugin management, presentations, Tailscale, template creator, and visualization. These are skill entries, not tool/schema token allocations. Plugins remain enabled as instructed.

Official docs describe progressive disclosure: names, descriptions, and paths enter the initial catalog; full skill instructions arrive when selected. The default catalog budget is 2% of context capacity. Its 8,000-character fallback applies when capacity is unknown, not to the entire task. No catalog-cap change was made. The recalled Nat video and Ask Nat identity were not verified and were set aside at Justin's request. [Skill loading and controls](https://learn.chatgpt.com/docs/build-skills), [configuration reference](https://learn.chatgpt.com/docs/config-file/config-reference).

## Scope, provenance, and verification

The [75-package manifest](windows-personal-skills-disabled.json) records exact paths, file hashes, ownership basis, original settings, and backup location. Every target is a regular package under `C:/Users/Justin/.codex/skills`, outside `.system`; none is a directory link to another installation. `C:/Users/Justin/.agents/skills` does not exist. This confirms personal installation scope, including pstack and Matt packages; it is not a fresh upstream publisher/commit audit.

Installed backend `0.154.0-alpha.6.2` accepted the exact `SKILL.md` paths documented by OpenAI. Fresh [before](windows-personal-skills-discovery-before.json) and [after](windows-personal-skills-discovery-after.json) `skills/list` calls reported all 75 enabled before and disabled afterward, with no loading errors. That standalone discovery kept 6 system and 10 plugin-cache entries enabled. The desktop additionally supplies curated plugin entries; its measured catalog count of 96 must not be replaced with the standalone count of 16.

Recorded model `gpt-6-astra`, effort `high`, CLI version, handoff and base-instruction hashes, collaboration mode, and permission settings match across probes. The app generated directory suffixes `-2` and `-3` and workspace-root UUIDs. After normalizing generated paths/IDs, baseline and memory-off messages matched apart from memory; combined content outside the catalog matched memory-off. Full hidden tool-schema equality is not independently verified. One probe per condition and these generated identifiers limit exact causal attribution. A separate Windows setup task was operating on tool installations; the probe's recorded CLI version remained unchanged. This task did not touch PATH, packages, or shell profiles.

## Ranked attribution of the remaining input

The combined first request used exactly 28,369 input tokens, including 19,584 cached tokens. [Source attribution report](C:/Users/Justin/Documents/Codex/2026-09-14/justin-requests-a-separate-investigation-into/outputs/combined-input-attribution.md) and [metadata-only representation audit](C:/Users/Justin/Documents/Codex/2026-09-14/justin-requests-a-separate-investigation-into/outputs/combined-representation-audit.json) preserve the extraction evidence. The trace owner inspected source-tagged content blocks without exposing their text. The ranking below is by measured decoded characters, not tokens. Counts are distinct rather than overlapping.

| Recorded component | Characters | Source/owner and supported adjustment |
|---|---:|---|
| Host skills block | 22,154 | App skill discovery and installed packages. Includes the 22,111-character catalog plus 43 wrapper characters. The documented `skills.max_context_tokens` controls catalog budget; selected plugin availability is another separate control. Neither was changed during attribution. |
| Model base instructions | 20,919 | Recorded provenance is the model `gpt-6-astra`. This is the decoded text, not the earlier 21,209-character JSON serialization. These are model/app defaults. `model_instructions_file` can replace built-in instructions, but that changes agent behavior and is not the recommended context-only experiment. No override is configured. |
| Other app/orchestration instructions | 11,684 | Generic app/projectless guidance 7,293; multi-agent role 2,429; collaboration mode 1,328; permissions 363; multi-agent mode 271. App/runtime sources, not personal skill files. No separate user custom-instruction block was identified. Keep required behavior; no supported blanket removal established here. |
| User/environment and opening handoff | 1,293 | Plugin recommendations 421, environment 615, opening handoff 257. Generated host/task metadata plus the bounded task prompt. Keep handoffs short; shrinking an already small READY prompt offers little benefit. |
| Full tool definitions, hidden system content, and request serialization | Not available | The scoped trace lacks the complete serialized model request and hidden tool schemas. Some tool availability has supported MCP/plugin controls, but its exact current token contribution and the app-controlled minimum cannot be allocated. |

Distinct recorded base/body strings sum to 56,050 characters and 56,158 UTF-8 bytes, excluding request serialization, message separators, and unrecorded tool definitions. This is not a token subtotal. Without the exact request representation and a verified tokenizer, subtracting an estimated text count from 28,369 would create an unreliable remainder. The opaque remainder therefore has no defensible numerical allocation. Cached input cannot be assigned wholesale to any one category.

### System skills versus plugin skills

| Inner catalog component | Count | Characters | UTF-8 bytes |
|---|---:|---:|---:|
| Plugin entry lines | 91 | 19,897 | 19,993 |
| System entry lines | 5 | 992 | 994 |
| Skill-root mapping table | 11 rows | 912 | Included in catalog total |
| Catalog headings/guidance | Separate wrapper text | 310 | Included in catalog total |
| Inner catalog total | 96 skills | 22,111 | 22,209 |

Plugin entry text is about twenty times the system entry text. This compares catalog metadata, not their share of all 28,369 tokens. Plugin names contribute 1,951 characters, descriptions 14,217, aliased paths 2,546, and formatting 1,183. System names contribute 61, descriptions 745, paths 121, and formatting 65. Counts differ from raw resolved-path metadata because the actual prompt uses aliases.

All five system paths resolve under `C:/Users/Justin/.codex/skills/.system`. All 91 plugin paths resolve under verified `C:/Users/Justin/.codex/plugins/cache` packages, with the package breakdown above. There are no personal, project-local, or unexplained other skill entries. No full `SKILL.md` body is visible in the startup representation, and the probe made no tool calls or file reads. File presence is not full-content injection.

The trace also stores a duplicate skill body and a large approved-command-prefix structure in `world_state`. Those are runtime records, not additional model-input messages. In particular, 172,904 characters of approved-command arguments must not be added to the prompt count; the rendered permissions block is only 363 characters. Counting all JSONL fields indiscriminately would greatly overstate context.

### Prior findings and limits

The older research request used 35,739 input tokens before explicit memory-read results, but already contained injected memory. Its later 65K display represented 64,642 latest-request tokens while cumulative usage was 195,893. That different prompt is historical evidence, not the comparison baseline. [Original metadata](C:/Users/Justin/Documents/Codex/2026-09-14/justin-requests-a-separate-investigation-into/outputs/startup-evidence.json).

Current scoped checks found the Obsidian Stop hook disabled, no Obsidian process, an empty Windows global `AGENTS.md`, and no `developer_instructions`, `model_instructions_file`, or legacy instruction-file override in user config. The source-tagged startup state also had empty AGENTS/managed-developer maps. This identifies no large personal custom-instruction body to trim. Earlier [memory audit](../2026-09-12/context-memory-strategy-2026-09-12.md) and [saved-memory review](C:/Users/Justin/Documents/Codex/2026-09-13/review-saved-codex-memories/outputs/memory-inventory.md) counted stored mechanisms/files, not automatic loading of every file.

Retain the [source-ownership architecture](../../cross-machine-workflow.md): current tasks hold working context, repositories own technical decisions, source systems own live records, selected personal context supplies background, and skills contain reusable procedures. gbrain remains a pilot candidate, not a demonstrated remedy for this startup cost. Bounded later tool results prevent additional growth but do not reduce the initial app instructions or schemas.

### Next proposed reduction test

Temporarily set only `skills.max_context_tokens=2000`, leaving memory use off and the 75 personal disables in place. This targets the catalog budget directly, because removing entries just allowed remaining descriptions to expand. The documented default is 2% of context capacity; at the observed 258,400 capacity that is 5,168. A 3,168-token difference between budgets is conditional, not promised input savings. Verify installed-client application through one separately authorized matched fresh probe, compare input including cached tokens, inspect catalog size, and confirm needed built-in/plugin skills remain discoverable or explicitly usable. Restore the absent override afterward unless Justin approves retaining it. No test or cap edit is authorized yet.

MCP server/tool allowlists and plugin-server policy are supported, but plugin skill metadata and tool schemas are distinct. Do not disable integrations blindly to chase an unknown schema allocation. No plugin disable/uninstall, instruction replacement, memory reenable, package/PATH edit, or app restart occurred during this attribution. [Catalog and instruction controls](https://learn.chatgpt.com/docs/config-file/config-reference), [MCP/plugin tool policy](https://learn.chatgpt.com/docs/extend/mcp).

## Reversible selector proposal

A selector is feasible for documented local controls. A universal switch covering every desktop-installed remote plugin is not established. This section is a read-only design, not an implemented script or an approved toggle experiment.

Justin's scope excludes every workspace/project-owned skill and all system built-ins. Preserve project-scoped discovery and operation. Global personal skills and eligible global desktop plugins are separate selectable groups. Installation through the UI alone does not prove user-global ownership. Resolve each target's source, effective configuration layer, exact package ID, and canonical path before offering it. Reject repository `.agents/skills`, other project-owned roots, and links resolving into them. Never generate name-based overrides, which could affect a same-named project skill. If disabling a global component would break a project skill's required dependency, exclude that action until the dependency can remain available.

### Controls and confidence

| Layer | Supported control | Verification and limit |
|---|---|---|
| Individual global skill | Exact `SKILL.md` path in `skills.config`, `enabled=false`; installed API also exposes `skills/config/write` | Verified for the 75 personal Windows packages. Applying it to desktop-supplied plugin skills still needs a fresh-task test. Hiding a skill does not disable its tools. Do not use the API's name selector. |
| Whole local-marketplace plugin | `plugins."name@marketplace".enabled` | Documented; installed inventory supplies exact IDs. No toggle tested here. Remote/workspace-managed enablement is not covered by this guarantee. |
| Plugin MCP server or selected tools | `plugins."id".mcp_servers."server".enabled`, `enabled_tools`, `disabled_tools` | Documented separately from skill loading. Installed metadata confirms server names for three packages below. No runtime exposure test performed. |
| Standalone global MCP server | `mcp_servers."server".enabled`, tool allow/deny lists | Supported, but outside the desktop-plugin inventory unless separately selected and confirmed global. Project-owned servers stay excluded. |
| Connected app tools | `apps."connector-id".enabled`, `default_tools_enabled`, `tools."tool".enabled` | Documented controls; resolve the connector ID from plugin details. Their effect on desktop-supplied remote tools and skill catalogs needs measurement. They do not uninstall or disconnect an account. |
| Permissions, hooks, platform instructions | Separate mechanisms | Approval modes govern permission prompts, not tool removal. The available plugin-management permission API is not an enable/disable API. Hooks and platform instructions are excluded from presets. |

Sources: [skill configuration](https://learn.chatgpt.com/docs/build-skills), [plugin and app keys](https://learn.chatgpt.com/docs/config-file/config-reference), [MCP controls](https://learn.chatgpt.com/docs/extend/mcp). No dedicated plugin enable/disable method appears in the inspected installed app-server protocol. Generic configuration writes provide the local route; do not substitute uninstall/install or an undocumented remote endpoint.

### Installed inventory and catalog size

Read-only `plugin/installed` and `plugin/read` calls through installed backend `0.154.0-alpha.6.2` reported 28 installed, enabled plugins: 12 local-marketplace packages and 16 remote packages. The inventory had no load errors. Three detail reads returned 404, as listed below. These observations are distinct from the earlier desktop startup catalog.

The following 16 owners account for all 91 plugin skill entries in the combined probe. Characters include the rendered aliased path and line formatting, exclude shared root mappings, and are not token costs or predicted removal savings. [Grouped source evidence](C:/Users/Justin/Documents/Codex/2026-09-14/justin-requests-a-separate-investigation-into/outputs/combined-input-attribution.md).

| Plugin owner | Entries | Characters | Installed source and component metadata |
|---|---:|---:|---|
| Vercel | 54 | 11,384 | Remote; skills and connected app |
| Figma | 12 | 2,726 | Remote; skills and connected app |
| OpenAI Developers | 5 | 1,183 | Remote; skills, OpenAI Platform app, `openai-api-key-local-confirmation` MCP |
| Google Drive | 5 | 1,128 | Remote; skills and connected app |
| Supabase | 2 | 464 | Remote; skills and connected app |
| Spreadsheets | 2 | 460 | Local primary runtime; skills and Codex Document Control app |
| Sites | 2 | 436 | Local bundled; skills and Sites app |
| Template Creator | 1 | 272 | Local primary runtime; skill |
| Plugin Management | 1 | 268 | Remote; skill and app; implicit canonical installation |
| Deep Research Work | 1 | 264 | Remote; app; implicit canonical installation; current details list zero skills |
| Documents | 1 | 244 | Local primary runtime; skill |
| Tailscale | 1 | 244 | Remote inventory; detail request returned 404 |
| Presentations | 1 | 239 | Local primary runtime; skill |
| Visualize | 1 | 236 | Local bundled; skill |
| PDF | 1 | 220 | Local primary runtime; skill |
| Computer Use | 1 | 129 | Local bundled; skill and three hooks; preserve desktop dependencies |
| Total | 91 | 19,897 | Tool/schema token costs remain unknown |

Local IDs use the exact slugs `documents`, `pdf`, `spreadsheets`, `presentations`, `template-creator` with `@openai-primary-runtime`; `sites`, `visualize`, `computer-use` with `@openai-bundled`. Remote owners above resolve to their lowercase hyphenated slugs with `@openai-curated-remote`; Deep Research uses `deep-research-work`. These IDs were returned by inventory, not inferred solely from cache directories. Remote package-level toggling remains unverified even when an exact ID is known.

The other 12 installed packages had zero entries in that measured catalog:

| Group | Packages and observed components | Selector treatment |
|---|---|---|
| Four local bundled integrations | `codex-app-tools` has MCP `codex_app`; `unified-computer-use` has MCP `cua_repl` and three hooks; `browser` and `chrome` each list a skill and three hooks in current details | Exact IDs end in `@openai-bundled`. Preserve these desktop integrations by default. Zero catalog entries does not establish zero tool cost. |
| Eight remote integrations | Default templates, DoorDash, Finances, GitHub, Gmail, Google Calendar, Google Contacts, Trello | App availability requires its own control and test. Default templates is implicitly installed and current details list 20 skills absent from the measured catalog. DoorDash and Trello detail requests returned 404 despite installed inventory entries. |

Remote IDs are `openai-templates`, `finances`, `github`, `gmail`, `google-calendar`, `google-contacts`, each with `@openai-curated-remote`. DoorDash is `app-6943126354348191867f3efffccf94f1@openai-curated-remote`; Trello is `app-6a20b18a639081918c1b438f8381b27e@openai-curated-remote`. Metadata inconsistencies and 404s are unresolved; they do not establish that tools are unavailable or that a package is safe to disable.

### Scope and when changes apply

User configuration belongs to the Windows Codex home, not one task. Trusted project layers can override it; project files must remain read-only to the selector. Report the effective value and its winning layer rather than claiming success from the user file alone. An installed plugin can be remote/account-managed even when cached locally. This inventory does not prove identical availability across Windows, Ubuntu, Mac, or mobile. [Configuration precedence](https://learn.chatgpt.com/docs/config-file/config-basic).

CLI profiles use separate `~/.codex/<name>.config.toml` files selected with `--profile`. No evidence here establishes equivalent per-task desktop plugin profiles. Selector presets should be explicit lists of intended changes, stored separately from runtime profiles. Switching a user-level preset can affect other tasks and cannot promise concurrent desktop tasks with isolated capability sets. [Profiles](https://learn.chatgpt.com/docs/config-file/config-advanced).

The installed `ConfigBatchWriteParams` schema exposes `expectedVersion`, `filePath`, and `reloadUserConfig`. Its reload description covers runtime settings while excluding session-static defaults; it does not specifically prove plugin-catalog replacement. `config/mcpServer/reload` queues refreshes for loaded tasks. Neither removes content already used by earlier requests. Use a fresh task to verify prompt impact. The prior personal-skill and memory changes applied to fresh desktop tasks without restarting; official skill-config instructions still prescribe a restart. Treat that as a fallback requiring separate authorization, not a universal no-restart promise. [App-server reload](https://learn.chatgpt.com/docs/app-server), [skill reload guidance](https://learn.chatgpt.com/docs/build-skills).

### Small proposed interface and pilot

An explicitly run selector would offer `list`, `preview`, `apply`, and `undo`. Each row would show source/scope, exact identity, available layers, effective state, and whether behavior was tested. Selection would expand only a reviewed global allowlist. "All" would mean all eligible items in the chosen group, never every discovered skill or integration. Coding, browser, and documents presets are illustrative subsets, not approved defaults. Each keeps project skills, system built-ins, the current memory settings, and existing personal disables intact unless Justin explicitly selects a particular global personal skill to reenable.

Before any future apply, snapshot the target file and record each owned key's old value, including absence, plus its proposed value. Prefer the installed configuration API with an expected version and narrowly scoped edits. Reject stale versions, ambiguous ownership, changed cache paths, or conflicting edits. Exact path overrides must be resolved again after package updates. Undo restores only owned values that still match what the selector wrote; conflicts require review. Never replace the whole config from a backup, because the app and other tasks add legitimate entries. Do not alter installed files, credentials, hooks, runtime packages, project configuration, or permanent memory.

The first separately authorized pilot should target one optional local plugin skill, such as the exact global PDF skill path, while retaining the plugin and its other components. Verify the supported plugin-skill override before adding whole-plugin or connector-tool controls. Acceptance requires:

1. The preview contains only the selected global target and rejects a same-named project skill or a path resolving into a repository.
2. Configuration readback and fresh discovery match the requested state; required project skills and dependencies remain operational.
3. A matched fresh-task comparison records actual catalog entries, input including cached tokens, and available tools. Do not infer schema savings from catalog characters.
4. A second apply is a no-op, concurrent changes cause a conflict, and undo restores only the pilot's original values while preserving an unrelated edit.
5. Package/auth files and protected memory/personal-skill settings remain unchanged. No restart or installation occurs without its own authorization.

Open decisions are which global items belong in each preset, whether remote plugin-skill/app controls work in this desktop build, and whether measurable savings justify a selector. The separate catalog-cap proposal remains unapproved. No selector, toggle, reload, or fresh probe was executed for this feasibility section.

## Undo and next decision

The first temporary memory test restored `use_memories=true`. Justin's later explicit instruction superseded that restoration and authorized the present `false` value and personal-skill disables to remain.

The pre-combined-change backup is `C:/Users/Justin/.codex/backups/config-personal-skills-disable-2026-09-14.toml`. To undo only this operation, remove the 75-entry block between `BEGIN approved Windows personal skills disable 2026-09-14` and its matching END comment, and set `memories.use_memories=true`. Original personal overrides were empty. Do not replace the entire config with the backup: the app added a legitimate project entry during validation, and later unrelated edits must survive. Re-read settings and verify fresh discovery after any authorized undo.

Current readback confirms memory use false, generation true, 75 disables, and no catalog cap. All other parsed differences from the backup were the app's generated test-project entry. No further configuration, plugin reduction, restart, or deletion is authorized. Further savings would need a separately scoped test of the remaining catalog or tool exposure; removing saved notes is not supported by these results.
