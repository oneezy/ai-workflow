# Context and memory strategy

Research and bounded local audit, September 12, 2026. Recommendation only.

Keep the existing ownership model and add retrieval only where it solves a demonstrated access problem. Obsidian should remain the canonical home for durable private context; repositories, GitHub, Trello and Drive should retain their existing responsibilities. A shared search service can make selected information accessible across clients without becoming another authority or another automatic writer.

The most useful initial improvement is to verify and simplify the current loaders. A new memory system would otherwise sit beside existing Codex memory and the Obsidian capture workflow. There is evidence of overlapping mechanisms, but this audit did not establish an actual contradictory answer or quantify a performance penalty.

## What is active, available, or unknown

| Surface | Observed evidence | Meaning and limit |
|---|---|---|
| Windows Codex local memory | User config has `features.memories=true`, `memories.generate_memories=true`, and `memories.use_memories=true`. This task received a memory summary and retrieval instructions. | Memory use is observed; generation is configured. This does not prove every eligible task produces a memory. |
| Global instructions | Windows `~/.codex/AGENTS.md` is empty. No AGENTS or override was found in this standalone working directory or the sampled Documents ancestors. No custom instruction-file or fallback-filename key appeared in the inspected user config. | The large instructions visible in this task also come from the app, supplied skills catalog and memory layer. An empty global AGENTS file does not mean an empty starting prompt. |
| Matt skills | Windows `skills/ask-matt/SKILL.md`, its phase-boundary reference and `skills/research/SKILL.md` were read. Ask Matt declares `disable-model-invocation: true`; research calls for background primary-source reading. | The router exists locally and was explicitly used for this research. Existence is not evidence that its full text automatically enters every task. The earlier research also inspected the WSL project copy. |
| Obsidian | Vault root and its three policy files exist and were read. Its skill and Stop-hook script exist. | The ownership and capture contract is present. No personal notes, daily entries or application settings were audited. |
| Obsidian closeout hook | `hooks.json` defines a Stop command. The matching `config.toml` hook state has a stored trusted hash and **`enabled=false`**. | Configured but disabled in the inspected Windows user state. A past successful closeout is not proof of current automatic operation. The script requests an agent closeout; it does not itself write a note. |
| Desktop / WSL boundary | Windows config says `runCodexInWindowsSubsystemForLinux=false`, while the integrated terminal is `wsl`. | A WSL terminal is not proof that Codex itself runs under the WSL configuration. A new read of WSL config failed with `Wsl/Service/E_ACCESSDENIED`. Its current memory flags and hooks remain unverified. |
| gbrain and alternatives | No matching memory tools were exposed in this task; no gbrain MCP entry in inspected Windows config; no `gbrain` on this process PATH; common Windows `.gbrain`, `.basic-memory`, `.supermemory`, `.openmemory` directories absent. | No active integration found in this bounded Windows sample. This is not a machine-wide or WSL proof that software is uninstalled. |
| ChatGPT / Android | No account Personalization settings, app authorizations, Android session or live Remote connection was inspected. | Saved memories, custom instructions, project memory mode and mobile connector access remain unknown. Do not infer synchronization from a shared account or model name. |

Audit evidence: `C:\Users\Justin\.codex\config.toml` (file timestamp 2026-09-12 16:48:39 UTC), `hooks.json`, `skills/obsidian-memory/SKILL.md`, `skills/obsidian-memory/scripts/closeout-hook.ps1`; `C:\Users\Justin\Obsidian\AGENTS.md`, `WORKING-AGREEMENTS.md`, and `50 Reference/System ownership contract.md`. Only policy/configuration fields were relevant; credentials and personal vault contents were outside scope. The existing Windows memory registry was used to locate historical wiring, then current files were checked.

## How context enters a task

OpenAI documents separate stores for ordinary ChatGPT memory and local Codex memory. Local memories live under the Codex home; per-task controls can separately govern using memories and contributing inputs for future generation. Generated files should be treated as recall aids, while required guidance belongs in instructions or checked-in documentation. These are product capabilities; Justin's cloud/account settings were not verified. [OpenAI memory documentation](https://learn.chatgpt.com/docs/customization/memories)

Codex builds its AGENTS instruction chain at startup. It selects the global override or global AGENTS, then applicable project files down to the working directory; nearer instructions override broader ones. The documented default combined file limit is 32 KiB. Reopening a fresh task is therefore an important acceptance check after a future instruction change. This instruction limit is not a budget for all tools, skills, memories and conversation history. [AGENTS discovery](https://learn.chatgpt.com/docs/agent-configuration/agents-md)

Matt's installed router gives complementary workflow advice: retain primary reasoning while it is needed; use a portable handoff when changing execution environment or directory; start implementation from a self-contained ticket when prior discussion is dispensable. It does not provide a shared memory backend. The writing guidance favors useful pointers and clear completion criteria over loading every document. Its approximate context-window advice should not become a universal runtime limit. [Ask Matt](https://github.com/mattpocock/skills/blob/3cca18b368ae95cdbdebbff572ccafa662551015/skills/engineering/ask-matt/SKILL.md), [Writing for agents](https://www.aihero.dev/skills-writing-for-agents)

Skills initially contribute names and descriptions; their full instructions are read when selected. MCP makes tools available and can supply server instructions at initialization, while specific records are retrieved through calls. Neither mechanism means that all underlying files are automatically loaded. The present task nevertheless visibly has a broad skills catalog and an injected memory summary. [Skill loading](https://learn.chatgpt.com/docs/build-skills), [MCP](https://learn.chatgpt.com/docs/extend/mcp)

Android Remote uses the connected host's files, tools, skills, credentials and permissions. A phone controlling the Windows task can use that task's environment; an ordinary ChatGPT conversation on the same phone is a different context route. WSL-native Codex using another home should be treated as a separate configuration and memory store unless explicit wiring proves otherwise. That WSL conclusion follows from documented host and home boundaries, not a successful live WSL audit. [Remote](https://learn.chatgpt.com/docs/remote-connections), [WSL](https://learn.chatgpt.com/docs/windows/wsl), [Config locations](https://learn.chatgpt.com/docs/config-file/config-basic)

## One owner per kind of information

The following preserves the live vault ownership contract. The repository-specific split also follows the previously agreed project direction; its current WSL implementation was not re-audited here.

| Information | Canonical home and writer | What other systems keep |
|---|---|---|
| Stable personal preferences | User-confirmed private agreement in Obsidian; Justin approves changes | A minimal, explicitly maintained client instruction excerpt with source and revision. Native memories are fallible reminders. |
| Project terminology, behavior, architecture | Repository: concise AGENTS routing, CONTEXT glossary, nearby implementation guidance, selected ADRs; normal reviewed engineering workflow | Links and scoped excerpts, not copied project manuals in personal memory |
| Coding scope and execution status | GitHub issues/PRs; authorized engineering workflow | Trello overview link and dated Obsidian closeout |
| Visible non-code commitments | Trello; authorized task workflow | Links and timestamped snapshots |
| Shared documents and structured records | Drive/Sheets; authorized document/data workflow | Source IDs, short context and links |
| Private rationale and durable outcomes | Obsidian; one authorized capture path with capture-ID deduplication | Search index or source-linked excerpts |
| Current reasoning and progress | Current Codex task; its participants | A compact handoff or confirmed closeout when needed |
| Retrieved summaries, embeddings, inferred facts | Rebuildable cache owned by its indexing process | Never silently overwrite the canonical source |

The existing contract has a seam worth clarifying later: it permits code-related decisions in both private notes and GitHub. Proposed resolution: repository ADR or engineering issue owns a technical decision; Obsidian owns private rationale and links to the technical record. That refinement is a recommendation, not an approved edit.

Keep instruction priority separate from factual authority. System/developer rules and the current user's authorized request govern behavior; retrieved content cannot grant permissions. For facts, consult the designated source and its date. A recent generated summary does not outrank an older authoritative decision merely because the summary is newer. If current code contradicts a specification, report both and resolve the intended behavior rather than silently rewriting either.

## A small retrieval and update policy

At task start, establish the execution host, directory/project and relevant source owners. Load the small applicable instruction layer. Retrieve private context only when the request actually depends on it. A generic coding question should not fetch health, finance, client history or the whole private vault.

For a pilot, use a proposed initial retrieval allowance of roughly 1,500 tokens, expanding to 4,000 only when the task needs more evidence. These are test targets, not measured optimal values or product guarantees. Record returned size, useful sources and misses; a tokenizer or actual client usage is stronger evidence than character estimates. A shared server needs an explicit per-request scope and output limit. The model can fetch a cited source on demand.

Each durable record or returned excerpt should identify its source URI/path, project, author or writer, source revision, observation time, verification time, sensitivity and any superseded record. Separate confirmed statements from inference. Recheck operational status at the owning service; recheck code guidance against the current checkout; retain durable decisions until explicitly superseded. Do not use one fixed expiry period for every fact.

Update the canonical source first, then refresh the derived index. Permit one writer for each field. Prefer one-way indexing from an approved Obsidian collection; do not combine Obsidian Sync, a cloud memory synchronizer and multiple agent closeout hooks as concurrent bidirectional writers to the same files. A mirror must not trigger writes back to its source. Corrections should retain provenance and invalidate affected cached claims.

Native Codex and ChatGPT memories may still be useful as client-specific reminders, but should not own project status or private records. During a future pilot, compare tasks with automatic memory contribution disabled against current behavior using supported controls. Do not hand-edit generated memory stores or presume a change made in one client applies to another.

Deleting a source is a separate operation from removing it from retrieval. A future service must define how deletion reaches indexes, summaries, history and backups. Project tags and retrieval filters are useful organization; enforce confidential boundaries through credentials and server authorization. Never rely on a prompt or collection name as access control.

## The shortlist

Five choices cover the relevant tradeoffs without surveying the whole market. Prices are published USD rates checked September 12, 2026, excluding tax, model-provider usage or infrastructure where applicable. None was installed or tested against Justin's accounts.

| Choice | Best reason to consider it | Main tradeoff | Recommendation |
|---|---|---|---|
| Existing Obsidian plus scoped local reads | Owned Markdown and the least change | No verified ordinary ChatGPT access; host availability matters | Keep as the baseline |
| Basic Memory local / Cloud | Retrieval over Markdown that can coexist with Obsidian | Cloud adds a copy and synchronization decisions | First candidate for a small shared-retrieval pilot |
| gbrain | Source-aware database, explicit memory operations and self-hosted access | More runtime, permissions, backup and upgrade work | Consider when those database capabilities are needed |
| Mem0 Platform / OSS | Managed extracted memory, or a developer-controlled backend | Additional memory authority unless carefully constrained | Consider for an agent application or managed extraction need |
| Supermemory managed / local | Managed cross-tool recall and document-backed memory | Automatic capture, metered service and client-specific differences | Consider if automatic capture is an explicit priority |

**Existing Obsidian.** Its current policy already defines source ownership, compact capture, deduplication and readback. The audit confirms local policy access, not an active cloud bridge, current Sync setup or backup recovery. Local files remain usable without a memory service; an AI provider may still receive excerpts when an agent reads them. Keeping the present architecture incurs no new memory-service subscription, but the disabled closeout hook means its automatic capture behavior cannot be assumed. This is the control condition against which a new service should earn its place.

**Basic Memory.** It can work directly with Markdown and Obsidian wiki links. Local installation is documented through `uv` with Python 3.12+, including Windows/Linux paths. It provides project-scoped search and graph retrieval with result-count, depth and time controls; these are not a universal token ceiling. Local is free and AGPL-3.0. Cloud starts at $15/seat/month; Business is $30. [Obsidian integration](https://docs.basicmemory.com/integrations/obsidian/), [Local setup](https://docs.basicmemory.com/start-here/quickstart-local), [Tool controls](https://docs.basicmemory.com/reference/mcp-tools-reference/), [Pricing](https://www.basicmemory.com/pricing)

Cloud sync uses explicit project push/pull, is additive and stops on conflicts. Deletion propagation uses a separate mirror operation. That is not an automatic fully reconciled mirror. Markdown exports, version history and snapshots help portability; local files remain usable offline. Its privacy policy states no model training on content, encrypted transport/storage, US hosting, content deletion within 30 days and backup removal within 90. Local telemetry defaults on. A connected AI provider separately receives retrieved content. [Sync](https://docs.basicmemory.com/cloud/cloud-sync/), [Snapshots](https://docs.basicmemory.com/cloud/cloud-snapshots/), [Privacy](https://www.basicmemory.com/privacy)

**gbrain and the README deployment choices.** The current README recommends adding memory to existing Codex or Claude Code. Memory-only setup does not require creating a new personal-agent identity. The other routes include standalone CLI, a shared HTTP memory server, and optional OpenClaw or Hermes for an always-on personal agent. A VPS is a possible place to run a service or agent; it is not required for local memory. OpenClaw is an orchestrator choice, separate from the storage/backend choice. [Current README](https://github.com/garrytan/gbrain/blob/master/README.md)

Local PGlite supports keyless keyword/entity recall and explicit writes; one process should own a PGlite database. Concurrent clients can share a server. PostgreSQL and remote thin-client arrangements are documented. Self-hosting `gbrain serve --http` means owning authentication, updates, uptime and recovery; this audit established no turnkey managed-service price. Model-powered operations and an always-on agent can add provider and compute costs. Native Windows operation remains untested. [Coding-agent setup](https://github.com/garrytan/gbrain/blob/master/docs/tutorials/connect-coding-agent.md), [Install reference](https://github.com/garrytan/gbrain/blob/master/docs/INSTALL.md)

Its narrow memory protocol supports provenance, scoped recall and context packs; its skill optimization is an additional capability, not necessary for shared retrieval. Some optimization paths can apply accepted edits to user-owned skills, so a pilot should omit that capability. Forgetting removes facts from active recall rather than guaranteeing erasure of source/history/backups. Full PGlite backup includes database-only facts; Git alone is insufficient. Backups are checksummed, not encrypted. Documented PGlite recovery currently has PostgreSQL-version and size limits. [Memory protocol](https://github.com/garrytan/gbrain/blob/a6be012a3bcfac42e279630aedec5cda4a450e29/docs/protocol/MEMORY_VERBS_v1.md), [SkillOpt](https://github.com/garrytan/gbrain/blob/a6be012a3bcfac42e279630aedec5cda4a450e29/docs/guides/skillopt.md), [Backup/recovery](https://github.com/garrytan/gbrain/blob/master/docs/guides/in-agent-setup.md)

**Mem0.** Platform supplies a managed memory service and HTTPS MCP; OSS lets an operator choose database, model and embedder. Its current self-hosting guide includes an authenticated Docker Compose server. Memory history records originating conversation, previous/new values, timestamps and change type. Update/delete and filtered exports are available, but an export is not proof of complete backup restoration or a defined backup-erasure timetable. Platform lists free Hobby, $19/month Starter and $249/month Pro. [MCP](https://docs.mem0.ai/platform/mem0-mcp), [Self-hosting](https://docs.mem0.ai/open-source/setup), [History](https://docs.mem0.ai/api-reference/memory/history-memory), [Export](https://docs.mem0.ai/api-reference/memory/create-memory-export), [Delete](https://docs.mem0.ai/core-concepts/memory-operations/delete), [Pricing](https://mem0.ai/pricing)

Do not confuse several products called OpenMemory. The old components in the Mem0 repository were sunset according to a maintainer. The current `mem0ai/openmemory` is a beta session-portability tool for coding agents, with several synchronization and agent integrations still on its roadmap. Mem0's browser extension is yet another route. None establishes native Android memory access. [Maintainer notice](https://github.com/mem0ai/mem0/issues/3238), [Current OpenMemory](https://github.com/mem0ai/openmemory), [Browser extension](https://github.com/mem0ai/mem0-chrome-extension)

**Supermemory.** Managed ingestion extracts a memory graph alongside source documents. It supports scoped retrieval, source-document IDs and review of inferred memories. Its Codex guide describes a CLI plugin that captures every three prompts by default and flushes at Stop, with automatic user/repository tags and limited recall/profile items. That would introduce another automatic writer. Desktop hook parity was not verified. [MCP tools](https://supermemory.ai/docs/supermemory-mcp/mcp), [Inference review](https://supermemory.ai/docs/recall/memory-review), [Codex integration](https://supermemory.ai/docs/integrations/codex)

Managed API pricing lists Free with $5 monthly credit and Pro at $19/month with $20 credit; usage is metered. An August 15 release says coding plugins are free while pricing/setup pages still imply paid access, so exact entitlement is unresolved. A free local macOS/Linux binary exists, but lacks managed connectors and the Supermemory MCP service; fully offline use needs a local model. Native Windows binary support was not established. JSON export is documented up to 25,000 documents/memories, and permanent API deletion is available; a bounded backup-retention/restore guarantee was not established. Security documentation states no customer-content training and scoped access. [Pricing](https://supermemory.ai/pricing/), [Plugin release](https://supermemory.ai/changelog/plugins/), [Local capabilities](https://supermemory.ai/docs/self-hosting/overview), [Export](https://supermemory.ai/changelog/console/), [Deletion](https://supermemory.ai/docs/ingestion/document-operations), [Security](https://supermemory.ai/docs/overview/security)

## Which clients can actually connect

“Documented” below means a vendor recipe exists, not that Justin's client is installed, authorized or tested. Android Remote can use a configured host; it does not eliminate host downtime or prove direct mobile-app support.

| Option | Codex / Claude Code | Ordinary ChatGPT | Windows, WSL and Android limits |
|---|---|---|---|
| Existing Obsidian | Local file access, subject to task permissions | No active bridge found | Windows policy reads verified; WSL config and phone Sync not verified |
| Basic Memory | Local MCP and cloud routes for both | Published Cloud plugin documented | Local cross-platform instructions exist; native mobile access remains subject to plugin availability and authentication |
| gbrain | Local MCP and hosted routes for both | HTTPS/OAuth search/fetch connector guide | No native Windows or Android end-to-end test; server availability and supported client connection required |
| Mem0 | Dedicated Codex/Claude plugins; direct MCP option | Browser extension documents ChatGPT integration | Extension route is not Android-native; CLI plugin behavior is not proven desktop parity |
| Supermemory | Codex CLI and Claude Code plugins; managed MCP | ChatGPT Web developer-mode connection | PowerShell credential setup documented; direct Android custom-MCP behavior not established |

Integration sources: Basic Memory [Codex](https://docs.basicmemory.com/integrations/codex/), [Claude Code](https://docs.basicmemory.com/integrations/claude-code/), [ChatGPT](https://docs.basicmemory.com/integrations/chatgpt/); gbrain [ChatGPT](https://github.com/garrytan/gbrain/blob/master/docs/mcp/CHATGPT.md); Mem0 [Codex](https://docs.mem0.ai/integrations/codex), [Claude Code](https://docs.mem0.ai/integrations/claude-code); Supermemory [ChatGPT Web](https://supermemory.ai/docs/supermemory-mcp/chatgpt-web), [Claude Code](https://supermemory.ai/docs/integrations/claude-code).

OpenAI currently documents developer-mode custom MCP for eligible Pro, Plus, Business, Enterprise and Education accounts on the web, subject to policy. A private server can use Secure MCP Tunnel in the documented testing route; public exposure is not the only possibility. Published plugins can work across web, desktop and mobile, but desktop-only plugins do not run on mobile. These general capabilities do not establish that a particular memory service is available to Justin on Android. [Developer mode](https://developers.openai.com/api/docs/guides/developer-mode), [Connection testing](https://developers.openai.com/plugins/deploy/connect-chatgpt), [Plugins](https://learn.chatgpt.com/docs/plugins)

Vendor documentation has inconsistencies: Mem0's general MCP page and dedicated Codex setup disagree on HTTP registration; its general OSS comparison and current self-hosting guide disagree on a dashboard. Basic Memory's Codex page blurs app/client distinctions. Prefer the narrow current client guide and then test the installed client. These are reasons to avoid treating a compatibility table as an acceptance result.

Maturity evidence is mixed rather than a defensible numerical ranking. Basic Memory documents a v0.23 migration; gbrain's recent validation explicitly distinguishes repository tests from actual fresh-client recall; Supermemory disclosed an August Claude-plugin command-approval flaw and a security update. All require version-aware maintenance. No independent comparative benchmark was run here. [Basic Memory upgrade](https://docs.basicmemory.com/whats-new/v0-23-upgrade/), [gbrain validation](https://github.com/garrytan/gbrain/blob/master/docs/guides/harness-validation.md), [Supermemory update](https://supermemory.ai/changelog/plugins/claude/)

For shared access, Basic Memory offers team-wide or invite-only projects; Supermemory documents scoped credentials. Check the actual grant, not just the collection filter. Mem0's managed and OSS editions also differ in capabilities, so self-hosting is not automatically feature-equivalent to Platform. [Basic Memory project access](https://docs.basicmemory.com/teams/team-projects/), [Supermemory authentication](https://supermemory.ai/docs/authentication), [Mem0 editions](https://docs.mem0.ai/platform/platform-vs-oss)

## Minimal staged pilot, if authorized later

1. **Establish the baseline.** Confirm the actual host and per-task memory controls in a fresh Windows task, a WSL-native task and Android Remote. Confirm whether the disabled Obsidian hook is intentional. Check ordinary ChatGPT plugin/settings availability separately. Do not enable anything merely to complete the audit.
2. **Test one small collection.** Use 10–20 synthetic or non-sensitive notes in an isolated directory. Include one superseded decision, two similarly named projects and one deliberately misleading instruction embedded in a note. Start with existing file search, then Basic Memory local if authorized. Give one client write responsibility; others retrieve only. Keep automatic conversation capture and skill rewriting out of this pilot.
3. **Add remote access only if it solves a real need.** If direct ordinary ChatGPT access while the PC is off matters, evaluate Basic Memory Cloud with the same small collection and a declared one-way publication process. If only Android Remote is needed, first test the existing host route. Consider gbrain when the trial demonstrates a need for its richer database/provenance operations, rather than adopting OpenClaw just to serve memory.
4. **Require useful results and recoverability.** Run the cases below in new tasks. Keep the service only if it improves correct, source-backed answers without cross-project leakage, uncontrolled capture or excessive retrieved context. Export and restore the test collection before expanding it.

| Fresh-task case | Pass condition |
|---|---|
| Unrelated question | No private vault retrieval; useful answer without project history |
| Repository question | Current repo guidance and relevant ticket/ADR; no unrelated project policy |
| Corrected decision | Cites the replacement and identifies superseded evidence |
| Cross-client recall | Same source revision found from each actually configured client, including a new conversation |
| Android Remote | Identifies its host and successfully uses that host's allowed retrieval tool |
| Ordinary Android ChatGPT | Separately proves plugin access, or reports it unavailable without inventing recall |
| Conflicting writers / scope | Unauthorized writes rejected; another project's restricted records inaccessible |
| Imported instruction | Treated as source text, not authority to change behavior or send data |
| Forget / delete / restore | Removed from active retrieval, retention limits disclosed, test export restores correctly |
| Host or network offline | States the limitation and uses only available local evidence |
| Small context | Records actual returned size and source usefulness against the proposed budget |
| Duplicate closeout | Exactly one authorized capture, with readback; disabled paths produce no capture |

These are proposed acceptance cases, not tests already passed. No benchmark can guarantee future retrieval quality or privacy; the scoped permission checks should remain enforced after the trial.

Before putting client, health or financial material into any new service, require a concrete approved data subset, client permissions and retention terms. No privacy marketing statement alone establishes a suitable contract, legal basis or healthcare compliance arrangement. Managed storage reduces operations work but adds a provider; VPS hosting adds patching, network exposure and backups; local storage still sends selected context to whichever model processes it. Synthetic data is enough for the first comparison.

The two decisions that materially affect the next step are whether direct ordinary ChatGPT access while the computer is off is required, and whether the disabled Obsidian closeout hook is intentional. Neither blocks this recommendation. No deployment, purchase, upload, configuration change, skill edit, memory update or vault write was performed for this extension.
