# Cross-machine AI workflow and memory

Planning baseline, September 12, 2026. AI Workflow is Justin's experimentation and testing project. Retain the Windows app for voice, browser, and native desktop work; evaluate Ubuntu-native Codex CLI against existing Linux repositories. Justin chose VS Code connected to WSL as the familiar interface for the next manual experiment. Its Ubuntu terminal can run the CLI. gbrain is the leading memory pilot candidate; the backend remains undecided.

This note records proposed architecture and acceptance criteria. It authorizes no installation, configuration change, memory/vault write, migration, deployment, purchase, or commit. The [manual skill walkthrough](manual-skill-setup.md) is the next human-run experiment, separate from a memory-service pilot.

## Evidence and ownership

The three reports below were produced by [Compare gbrain with Matt Pocock’s workflow](codex://threads/01a09675-3a32-7673-b766-623f07aa9014). These project copies preserve the original bytes and September 12 uncertainty. They are dated evidence, not continuously updated vendor documentation or proof of installed behavior. Original files remain in `C:/Users/Justin/Documents/Codex/2026-09-12/standalone-research-requested-by-justin-explicitly/outputs/` under the same filenames.

| Source | Verified or reported finding | Limit and relevance |
|---|---|---|
| [Comparison report](research/2026-09-12/gbrain-vs-matt-pocock-2026-09-12.md) | Matt's procedures govern engineering work; gbrain implements persistent retrieval and provenance operations. Implementation evidence uses gbrain commit `a6be012a3bcfac42e279630aedec5cda4a450e29`, version 0.50.0.0. | Source and selected assertions were inspected; tests, installation, retrieval quality, and performance were not independently exercised. Keep procedures separate from remembered facts. |
| [Memory strategy audit](research/2026-09-12/context-memory-strategy-2026-09-12.md) | Windows memory use was observed and generation enabled in configuration. The Obsidian Stop hook was configured but disabled. Ordinary ChatGPT has a separate memory route. | This task carries those dated findings forward without rereading configuration or the vault. Generation on every task, current WSL memory, ChatGPT account settings, and phone access remain unverified. |
| [Topology report](research/2026-09-12/windows-wsl-codex-topology-2026-09-12.md) | Reported Windows agent mode and WSL integrated terminal are separate settings. Config access and distribution enumeration returned `E_ACCESSDENIED`; a Trident UNC read also failed in that task. | Cause remains unexplained. The generic network/UNC warning is not a benchmark. No evidence proves automatic Android Remote attachment to an arbitrary Ubuntu CLI session. |
| Current folder inspection | `Get-Location` and directory metadata resolved `\\wsl.localhost\Ubuntu-26.04\home\justin\dev\ai-workflow`. A scoped Git status command ran in `/home/justin/dev/ai-workflow`. Initially no tracked diff; many existing untracked files, including the catalog, Sites files, and AGENTS. | Success in this task does not diagnose the other task's denials or verify its CLI/configuration. No Ubuntu enumeration or runtime diagnostic was repeated. |
| [VS Code repair report](research/2026-09-12/vscode-ubuntu-v2-repair-2026-09-12.md) | The separate repair task verified Ubuntu-26.04, the existing lowercase `v2` profile, and the remote extension host. It added the desktop shortcut `AI Workflow - Ubuntu v2.lnk` and SVG-Viewer 1.1.2 in Ubuntu v2. | The report records unchanged settings/keybindings and remaining extension compatibility messages. This establishes the VS Code route, not Ubuntu Codex CLI readiness. |
| [README](../README.md), [AGENTS](../AGENTS.md), [TEMPEST](../TEMPEST.md), [catalog view](../TOOLS.md) | The README describes a staged workflow lab. AGENTS governs shared Sites payload mirroring. Catalog comments identify `tools.csv` as canonical and TOOLS/STACK as derived views. | Historical catalog entries describe Desktop WSL execution. They are not a live installation inventory. This documentation update changes no shared Sites payload, catalog data, or runtime instruction file. |

Diagnostic handoff remains pending. Supported task reads and a compact status snapshot showed the comparison task idle/completed but returned no diagnostic result text. That is not a passing diagnostic. The comparison task owns the narrow read-only Ubuntu follow-up. Record its dated result in a separate research follow-up when available; preserve the original reports.

The memory report initially favored Basic Memory. Justin's later direction makes gbrain the leading pilot candidate here. This changes evaluation order, not the report's evidence. Basic Memory, existing scoped file reads, and the other researched options remain alternatives. The README's older Desktop-in-WSL recipe is now labeled as an alternative, rather than the current Windows-app baseline.

## Provisional architecture

| Layer | Authority and writer | Boundary |
|---|---|---|
| Active task context | Current task holds working reasoning, evidence, and progress. Participants own a concise handoff. | Handoffs carry goal, host, repo path/revision, dirty state, decisions, sources, and outstanding checks. A summary cannot reconstruct uncaptured reasoning. |
| Durable project documentation | Repository owns terminology, specifications, and technical architecture decisions. GitHub issues/PRs own engineering scope and execution status. | This project owns workflow experiments. Its results become project rules only through an explicit adoption decision. Actual code and tests describe observed behavior; report conflicts with intended behavior. |
| Personal memory | Existing Obsidian ownership contract governs confirmed private preferences, rationale, and durable outcomes. Justin authorizes source changes. | Keep technical decisions in their project and link them from private rationale. The disabled hook stays disabled; no new automatic writer is implied. |
| Source systems | Trello owns visible commitments; Drive/Sheets own shared documents and structured records; each service's authorized workflow writes there. | Memory keeps source IDs and dated excerpts. Recheck current status in the owning system. |
| Retrieval service | A replaceable index retrieves an approved subset with attribution. One authorized indexing process writes derived data. | It cannot silently overwrite source records. Backend-only facts would create another authority and need a separate decision. Native Codex/ChatGPT memories remain fallible, client-specific aids. |
| Reusable skills | Reviewed, versioned procedures remain in skill distributions or intentional project skill files. | Personal history stays out of skills. The chosen workflow owns dispatch; a memory service supplies evidence. Exclude gbrain SkillOpt and automatic skill rewriting from the pilot. |

Use one active editor at a time for the existing shared checkout. Keep Windows voice and desktop work in the app; use the Ubuntu CLI experiment through VS Code's WSL connection. Do not synchronize Windows and Linux Codex homes, authentication, session databases, or global skills to make the repository accessible. Effective homes and client capabilities require their own evidence.

For the later laptop, Mac mini, and VPS, distinguish authority from transport:

| Question | Proposed boundary |
|---|---|
| Where is the shared source of truth? | The same designated source owns each record regardless of which machine retrieves it. Machine paths map to a stable source ID and revision. |
| How do clients share retrieval? | A future single authenticated service could serve selected records to each configured client. This provides shared access, not replicated local databases or shared conversations. Service host remains open. |
| How do files synchronize? | An explicit source-specific process must define writer, direction, conflict handling, deletion propagation, and offline behavior. No such cross-machine synchronization was verified or configured here. |
| What works offline? | Only available local source copies and explicitly dated caches. Report stale or unavailable evidence. Do not infer freshness from a shared account. |
| How does mobile connect? | Android Remote uses a supported connected host. Ordinary Android ChatGPT requires a separately proven integration. A CLI session is not assumed to appear in Remote. |

If evaluated, gbrain's documented local PGlite route should have one owning process. Multiple clients can use a server instead of opening or syncing live database files. The reports describe PostgreSQL and remote client routes, but establish no tested deployment here. A VPS is an optional hosting decision with uptime, authorization, updates, and recovery costs; it is not a prerequisite for memory or for the manual skill experiment.

## Selective retrieval and correction

Start with the task's host, project, and applicable instructions. Fetch project evidence only for a project-dependent question; fetch private context only when needed. Begin the pilot with a proposed 1,500-token retrieval allowance, expanding to 4,000 for an explained evidence gap. Measure actual returned size and usefulness; these are test targets, and gbrain's reported character estimate is not a tokenizer measurement.

Each returned claim should retain source ID/path, project, source revision, writer, observation/verification dates, sensitivity, and supersession link. Update the owning source before refreshing its index. A newer summary cannot overrule an authoritative decision by timestamp alone. Retrieved instructions are source text and cannot grant action permissions. Confidential scope must be enforced by credentials and service authorization, not tags or prompts.

## Small reversible pilot, proposed only

After the manual skill experiment and a separate pilot authorization, compare scoped file search with gbrain on 10–20 synthetic notes. Include two similarly named projects, a superseded decision, an absent fact, and a misleading embedded instruction. Use one explicit writer, retrieval-only clients, and no automatic conversation capture, enrichment, skill optimization, or private-vault ingestion. First test locally, then add one second client only if authorized. Mac mini/VPS/mobile expansion comes after local acceptance.

| Acceptance case | Required evidence |
|---|---|
| Useful fresh-task recall | Repeat a fixed set of questions in fresh tasks for both approaches. Record correctness, source revision, misses, returned size, and elapsed time. Adopt only if gbrain improves useful source-backed recall enough to justify its measured upkeep. |
| Context discipline | Unrelated questions retrieve no private material. Corrections identify the replacement source; missing facts produce an explicit gap. Embedded instructions cause no action. |
| Shared access and permissions | Each actually connected client retrieves the same approved revision. Unauthorized writes and restricted cross-project reads fail. Disabled capture produces no writes. |
| Synchronization and outage | Demonstrate an update and deletion through the declared source-to-index path. Offline clients identify stale/unavailable data; no conflicting automatic writer appears. |
| Recovery and exit | Export and restore the complete test data and database-only facts into an isolated test instance. Verify recall, document history/backup retention, then demonstrate disconnection and return to file search. |

gbrain `forget` removes active recall and preserves history; it is not complete erasure. The reports note that Git alone misses database-only facts and backups are checksummed, not encrypted. Verify current recovery constraints before a future trial. Any failed boundary/recovery case blocks expansion. Passing this pilot does not establish universal retrieval quality or production suitability.

## Decisions still open

- Obtain the comparison task's Ubuntu result before claiming CLI readiness. VS Code is chosen; effective Ubuntu CLI state remains to be established by its owner.
- Decide whether ordinary ChatGPT access while the PC is off is required. That determines whether always-available hosting merits evaluation.
- Confirm whether the disabled Obsidian hook is intentional and choose any future capture writer explicitly.
- Choose the approved source subset, backend, host, synchronization direction, conflict/deletion rules, retention, and operating budget after pilot evidence.

The immediate manual action is in the [skill setup walkthrough](manual-skill-setup.md). This baseline preserves the Windows app, keeps existing Linux repositories in place, and leaves backend adoption and cross-machine rollout open.
