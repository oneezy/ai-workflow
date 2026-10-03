# What Pi, Sandcastle and Hermes would add over Claude Code and Codex

Research for wayfinder ticket oneezy/ai-workflow#9. Checked 2026-10-03 from a Claude Code cloud session. Release data came from the npm registry and PyPI JSON APIs, the published npm tarballs (`@earendil-works/pi-coding-agent@1.0.0` and `@ai-hero/sandcastle@0.12.0`, whose README, CHANGELOG and docs were read in full), raw.githubusercontent.com (Hermes source at tag `v2026.9.24`), and WebFetch for github.com pages, because this session's repo-scoped GitHub access refuses `gh api` for these repos. The starting claims came from `/home/user/ai-workflow/README.md`: the version snapshot (§2), Milestone 6 (Pi), Milestone 9 (Docker and Sandcastle) and Milestone 11 (Hermes).

## Answer

All three tools are alive, MIT-licensed and safe to use as optional extras. None of them fills a gap that Claude Code and Codex leave wide open. **Pi** (Earendil Works; it was Mario Zechner's project until Earendil bought it on 2026-04-08) reached **1.0.0 on 2026-10-01**, two days before this check. Since the README's pin (0.82.0, 2026-07-24) it has had five releases with breaking changes, and it now has MCP and "codemode". What it adds is one hackable, provider-neutral harness that can route each request to a different model. Its costs: no permission gate by default, and Anthropic now bills a Claude subscription used through a third-party harness as per-token extra usage. A ChatGPT/Codex subscription does work in Pi. So the gap Pi fills is small for someone who already runs both vendors' own agents. **Sandcastle** (Matt Pocock / AI Hero) is still at **0.12.0 (2026-06-29)**, which is the version the README pins. Nothing has been released since. The repo had no commits between 2026-06-29 and 2026-10-02, and it has 64 open PRs and 113 open issues. On 2026-09-27 someone reported an open security issue (#1010): the host `.git` is mounted read-write, so a container agent can plant hooks that later run on the host. The maintainer's partial fix (#1014) was still a draft on 2026-10-02. Sandcastle fills the one real gap: a scriptable, agent-agnostic, local, Docker-isolated loop with a branch/worktree lifecycle, iteration caps and a completion signal. Neither Claude Code nor Codex ships that locally, although their cloud surfaces cover much of the same need. The adoption cost is medium: Docker Desktop with WSL integration, a TypeScript `main.ts`, and pinning or patching around #1010. **Hermes Agent** (Nous Research) is at **v0.21.5, tag `v2026.9.24`**. It is very active, merging hundreds of PRs a week, with a state.db corruption-fix campaign in September. PyPI is stale at 0.19.0. It now runs natively on Windows. Most of what it would add as a phone control plane is already covered by Claude Code Remote Control server mode (`--spawn worktree`) and Claude Code Channels (Discord/Telegram, research preview). What Hermes adds on top is an always-on, provider-neutral gateway with cron and deterministic `quick_commands`. Those commands run without an LLM, but they time out at 30 s and ignore arguments in the CLI path. Hermes has the highest adoption cost and attack surface of the three. Order of adoption: Sandcastle first if local AFK runs are wanted, then Pi only as an experiment, and Hermes last, possibly never.

## Pi

**What it is.** "Pi is a minimal, extensible AI agent for the terminal. Adapt Pi to your workflow, not the other way around." It runs interactively or in print, JSON or RPC mode, and as a TypeScript SDK. The package is `@earendil-works/pi-coding-agent` in the monorepo `earendil-works/pi`. That monorepo also holds `pi-ai` (a unified multi-provider LLM API), `pi-agent-core`, `pi-tui`, `pi-durable` (experimental) and others. [npm tarball README; GitHub repo page]

**Ownership and governance.** Earendil (Armin Ronacher, Colin Sidoti) announced on 2026-04-08 that it had acquired Pi and that Mario Zechner was joining. Earendil's RFC 0015 keeps the Pi core MIT and leaves room for paid Fair Source layers on top. The npm package moved from `@mariozechner/pi-coding-agent` (last 0.73.1, now deprecated: "please use @earendil-works/pi-coding-agent instead going forward") to `@earendil-works/pi-coding-agent`, first published 2026-05-07. The repo README states: "New issues and PRs from new contributors are closed automatically. Maintainers review closed submissions daily." [earendil.com/posts/announcing-pi-and-lefos; mariozechner.at 2026-04-08; rfc.earendil.com/0015; npm registry]

**Release and maintenance state (2026-10-03).**
- `latest` = **1.0.0, published 2026-10-01T19:15Z**. There is also a `legacy-node20` dist-tag at 0.74.2. It requires Node ≥ 22.19. [npm registry]
- The release cadence is very high: 53 versions under the new name since May, and 0.99.0 → 0.99.1 → 0.99.2 → 1.0.0 shipped between 29 Sep and 1 Oct. [npm registry; CHANGELOG]
- Between the README's pin (0.82.0, 2026-07-24) and 1.0.0, the CHANGELOG has **Breaking Changes** sections in 0.83.0, 0.84.0, 0.84.3, 0.86.0 and 0.87.0. Most of them hit extension and SDK authors: event shapes, `SessionManager`, provider stream inputs, JSON/RPC `message_update` now carrying deltas only. [CHANGELOG.md in the 1.0.0 tarball]
- 0.99.0 (2026-09-29) added **codemode, tool search and MCP** as built-in extensions, ChatGPT-subscription sign-in for the OpenAI provider, and virtual models. 1.0.0 made fullscreen TUI the default and hardened MCP OAuth. [CHANGELOG; earendil.com/posts/you-said-no-mcp (2026-09-29); earendil.com/posts/pi-1-0 (2026-10-01)]
- The Pi 1.0 post does not state a versioning, LTS or API-stability policy. [earendil.com/posts/pi-1-0]

**Checking the README's claims (Milestone 6, §2).**
- "*can switch models and gain custom tools, extensions, skills, prompt templates, and subagents*": **True, with a qualifier.** Subagents, plan mode, a permission gate and a sandbox all ship as **example extensions** (`examples/extensions/subagent`, `plan-mode`, `permission-gate.ts`, `sandbox`), not as core features. The GitHub README says Pi "skips features like sub-agents and plan mode" in its defaults. [tarball `examples/extensions/`; GitHub README]
- Install command `npm install --global --ignore-scripts …@0.82.0`: **Still valid in form**, but the pin is about 2.5 months and five breaking releases old. 1.0.0 is the natural re-pin. [npm; CHANGELOG]
- "*Use `/login` inside Pi for supported subscription providers*": **True, but with a cost catch for Claude.** Since 0.66.0 (2026-04-08), Pi has warned that "Anthropic third-party usage draws from extra usage and is billed per token", and setting `warnings.anthropicExtraUsage` silences that warning. Anthropic's own terms say OAuth is for "ordinary use of Claude Code and other native Anthropic applications", and that third parties should use API keys. A ChatGPT subscription works through `/login openai`, and the OpenAI Codex provider defaults to `gpt-6.1-sol` as of 0.99.1. [CHANGELOG 0.66.0, 0.99.0, 0.99.1; docs/settings.md; code.claude.com/docs/en/legal-and-compliance]
- "*Pi extensions and packages execute with the user's system permissions*": **True, and the problem goes further than extensions.** Pi's security doc says Pi "does not ask for approval before every tool call", and adds: "Safety comes from limiting the files, credentials, processes, and network services Pi can access." It recommends running the whole process in Docker, Docker Sandboxes, OpenShell, or the Gondolin micro-VM extension. [docs/security.md, docs/containerization.md]
- Windows: Pi runs **natively** (Git Bash, plus an optional `powershell` tool added in 0.84.0) **or inside WSL**. [docs/windows.md]
- "*Pi can be the agent provider running inside a Sandcastle sandbox*": **True.** Sandcastle ships `pi()` with `thinking` and session capture. [Sandcastle README `PiOptions`]

**Gap it fills.** Pi gives you a single harness where you own the system prompt, tools, routing and UI, and where one session can mix providers. Earendil's 1.0 post demonstrates Opus planning, GPT implementing and a Jev classifier choosing between them. It also gives a small, scriptable RPC/SDK surface for building your own coordinator. Claude Code and Codex already cover both vendors' frontier models, skills (via `AGENTS.md`/skills sync), subagents, MCP and headless modes, so for this setup Pi's marginal gain is mostly in **customisability and per-request model routing**. It brings no capability that is missing today.

**Adoption cost.**
- Install: one npm global plus `/login`, so minutes.
- Money: Claude models via subscription in Pi bill as per-token extra usage, so use an Anthropic API key or stay on OpenAI models through the ChatGPT subscription.
- Safety: there is no approval gate by default, so unattended use needs a container (Sandcastle, Docker or Docker Sandboxes) or the permission-gate example extension.
- Churn: frequent breaking changes in the extension API through 0.x. 1.0 is 2 days old, with no stated stability policy yet.
- Time: about half a day for the README's evaluation prompt. Ongoing cost only if you write extensions.

**Verdict.** Keep it as the README's optional experiment. Re-pin to 1.0.0 and evaluate it on OpenAI models through the ChatGPT subscription, or on an API key. Do not promote it to coordinator unless the evaluation shows clear wins in steering or routing.

## Sandcastle

**What it is.** "A TypeScript library for orchestrating AI coding agents in isolated sandboxes": you call `run()`/`createSandbox()`/`createWorktree()`, Sandcastle sandboxes the agent with a branch strategy (`head`, `merge-to-head` or `branch`), and the commits get merged back. Agent providers: `claudeCode`, `codex`, `pi`, `cursor`, `opencode`, `copilot`. Sandbox providers: Docker and Podman (bind-mount), Vercel (Firecracker microVM, isolated), `noSandbox`, or a custom provider. Features include `maxIterations`, a `<promise>COMPLETE</promise>` completion signal, idle and completion timeouts, structured output with `maxRetries` (resumable providers only: claudeCode, codex, pi), session capture/resume/fork, and `sandcastle init` templates with GitHub Issues or beads issue-tracker wiring. [npm tarball README]

**Release and maintenance state (2026-10-03).**
- `latest` = **0.12.0, published 2026-06-29**. That is still the newest release, so the README's pin is current. Releases came quickly from March to June (44 versions since 2026-03-26), then stopped. [npm registry; github.com/mattpocock/sandcastle/releases]
- Commits: the commit log jumps from 2026-06-29 ("Version Packages") straight to 2026-10-02 ("Add triage-repro skill…"), with nothing in between. [github.com/mattpocock/sandcastle/commits/main, fetched 2026-10-03]
- Backlog: **64 open PRs and 113 open issues**. Community fix PRs dated 2026-09-11 to 2026-10-01 are unmerged. [repo /pulls and /issues pages]
- **Open security issue #1010 (2026-09-27):** "Worktree sandboxes mount the host .git read-write, so hooks and config written in the container run on the host". A container agent can write `.git/hooks/*` or `core.fsmonitor`, and those then run on the host the next time git runs there. The report was against 0.12.0 with rootless Podman. Matt Pocock's PR **#1014** (disable hooks and fsmonitor for host-side git commands via `GIT_CONFIG_*`) was **still a draft on 2026-10-02**, and it leaves the rewritten-`.git`-pointer vector unaddressed. There is also an open Windows issue (#996) about linked-worktree hosts. [issues/1010, pull/1014, issues/996]
- Reading of the state: the project is maintained, but in bursts. It is pre-1.0, has no release for three months, and has a known host-escape path. [above]

**Checking the README's claims (Milestone 9, §2).**
- Versions `@ai-hero/sandcastle 0.12.0` and `tsx 4.23.1`: **current** for Sandcastle (tsx not checked).
- "*Docker supplies the local Linux sandbox, while Sandcastle manages agents, branches or worktrees, bounded iterations, prompts, commits, and results*": **True.** [README "How it works", `RunOptions`]
- Option list "*Docker / Podman / Vercel / custom*", and agent list "*Pi, Codex, Claude Code, Copilot, Cursor, OpenCode*": **True.** [README tables]
- "*require an explicit completion signal*" and "*at most three iterations*": **Supported** through `<promise>COMPLETE</promise>` and `maxIterations` (default 1). [README]
- "*open or prepare a PR into dev*": **Not a Sandcastle feature.** Sandcastle puts commits on a branch, and opening the PR is up to your script or the agent's prompt (for example `gh` inside the container, which needs a token in the container). [README branch strategies]
- "*Do not expose host secrets to the container*": **The default setup does expose some.** `init` asks for `CLAUDE_CODE_OAUTH_TOKEN` (from `claude setup-token`) in `.sandcastle/.env`. On AFK runs, Sandcastle passes `--dangerously-skip-permissions` to Claude and `--dangerously-bypass-approvals-and-sandbox` to Codex by default, unless you set `permissionMode`/`approvalsReviewer`. Issue #1010 also means a bind-mounted worktree is not a clean trust boundary until it is fixed. [README `ClaudeCodeOptions`, `CodexOptions`; issue #1010]
- Billing: Sandcastle runs the **unmodified** Claude Code binary signed in with your own subscription, which Anthropic's terms explicitly allow. [code.claude.com/docs/en/legal-and-compliance]

**Gap it fills.** Sandcastle is the only one of the three that fills a real gap. It gives a **local, repeatable, agent-agnostic AFK loop**: issue in, container, bounded iterations, branch out, with the same script driving Claude Code, Codex or Pi. That makes side-by-side runs (README Milestone 9's second test) cheap. Claude Code offers a Bash sandbox (Linux/WSL2), a whole-process `sandbox-runtime`, a dev container and `--worktree`, and its sandbox-runtime denies writes to `.git/hooks` and `.git/config` by default. Codex has its own read-only / workspace-write / danger-full-access sandbox on Linux, WSL2 and native Windows. Neither ships a multi-iteration orchestration library. Their **cloud** surfaces (Claude Code on the web, Codex cloud) already give isolated, unattended, branch-to-PR runs with no local Docker. So the gap Sandcastle fills is specifically "own hardware, own toolchain image, either vendor's agent". [code.claude.com/docs/en/sandbox-environments; learn.chatgpt.com/codex/sandboxing]

**Adoption cost.**
- Setup: Docker Desktop with WSL integration, `npm i -D @ai-hero/sandcastle` plus `tsx`, `npx @ai-hero/sandcastle init` (writes the Dockerfile and builds the image), and a token in `.sandcastle/.env`.
- Code: a TypeScript `main.ts` that you own, covering issue selection, planner/implementer/reviewer chaining, PR creation and cleanup.
- Security work: until #1014 or something like it ships, either use the `branch` strategy and never run git hooks on the host after a run (for example by setting `core.hooksPath=/dev/null` and unsetting `core.fsmonitor` for the repo), or prefer the isolated Vercel provider.
- Maintenance risk: pre-1.0, a slowed release cadence and a large PR backlog. Pin the version and expect to carry local patches.
- Time: about one day to a first clean documentation-only run.

**Verdict.** Keep it as Milestone 9's choice, but add a security step for #1010 to the milestone. Treat the cloud surfaces as the alternative if local Docker turns out not to be worth the upkeep.

## Hermes Agent

**What it is.** "The self-improving AI agent built by Nous Research". It is a general agent with a learning loop (it creates and improves skills), cross-session memory and search, and cron. It has **one gateway process for Telegram, Discord, Slack, WhatsApp, Signal and more**, plus seven terminal backends: local, Docker, SSH, Singularity, Modal, Daytona and Vercel Sandbox. It is not a coding agent in the same class as Claude Code or Codex. It delegates coding to them through bundled skills: the `claude-code` skill (v2.2.1; print mode `-p` or tmux-driven interactive, with `--allowedTools`, `--max-turns` and worktrees) and a `codex` skill. [GitHub README; hermes-agent docs: Claude Code skill page]

**Release and maintenance state (2026-10-03).**
- Latest GitHub release: **Hermes Agent v0.21.5, tag `v2026.9.24`, 2026-09-24** ("~460 PRs merged"). Before it came v0.21.4 (2026-09-21, "~1,800 PRs merged"), v0.21.3 (09-14), v0.21.2 (09-11, a "state.db reliability campaign addressing multiple corruption issues"), v0.21.1 (09-07) and v0.21.0 "The Pantheon Release" (2026-08-31: bot mode, agent-to-agent messaging, live subagent steering). `pyproject.toml` at that tag says `version = "0.21.5"` and Python `>=3.11,<3.14`. [github.com/NousResearch/hermes-agent/releases; raw pyproject.toml @ v2026.9.24]
- **PyPI is stale**: the newest `hermes-agent` there is 0.19.0 (2026-07-20). The supported install path is the git-based installer script. [pypi.org/pypi/hermes-agent/json]
- Very active, and churning a lot. The repo page showed about 250k stars. [GitHub repo page]

**Checking the README's claims (Milestone 11).**
- "*Keep Hermes on Windows … It may call WSL through `wsl.exe`*": **Now workable.** Hermes "runs natively on Windows 10 and Windows 11 — no WSL, no Cygwin, no Docker". You install it with `iex (irm …/install.ps1)`, and `-Tag` pins a release. Native data lives in `%LOCALAPPDATA%\hermes`, WSL data in `~/.hermes`, and the gateway autostarts through a Scheduled Task. [hermes-agent docs: windows-native]
- "*Allow only commands such as `start issue <number>` …*": **Partly possible.** `quick_commands` with `type: exec` "run locally on the host and return the output directly — no LLM call, no tokens consumed". They work on Discord, but they have a **30-second timeout**. In the CLI code path (`cli.py` `_run_quick_command`), **user arguments are not passed into `exec` commands**, only into `alias`. Whether the gateway path forwards arguments was not verified. So `start issue 42` needs either one fixed command per action that backgrounds a WSL job, or a skill or plugin, and a skill means the LLM is back in the loop. [configuration.md @ main; cli.py @ v2026.9.24]
- "*Hermes must not … execute arbitrary Discord-provided shell commands*": **This has to be configured; it is not the default.** `approvals.mode` defaults to **`smart`**, meaning an auxiliary LLM auto-approves commands it judges low-risk, so set `manual`. Lock the Discord bot to `DISCORD_ALLOWED_USERS` and never use `GATEWAY_ALLOW_ALL_USERS`. The docs recommend `terminal.backend: docker` for production gateways, and also supports `approvals.deny` glob rules and DM pairing. [hermes-agent docs: security]
- Model cost: Hermes needs its own LLM for every message that is not a quick command (Nous Portal, OpenRouter, OpenAI, Anthropic and others). Using a Claude subscription there would be a third-party harness, under the same terms as for Pi. [GitHub README; legal-and-compliance]

**Gap it fills.** It would give **an always-on chat control plane** that is provider-neutral, works across several messaging platforms, has cron, and can start either Claude Code or Codex jobs, later from a VPS. Most of that is now built into Claude Code:
- **Remote Control server mode** (`claude remote-control --spawn worktree --capacity N`) lets the phone app or claude.ai start new sessions, each in its own git worktree, on the local machine. It works on Pro/Max, not with API keys.
- **Channels** (research preview) bridge **Discord**, Telegram and iMessage into a running session, with pairing, a sender allowlist and optional permission relay.

Codex mobile and cloud cover the Codex side (see the sibling cloud-surfaces research). What only Hermes adds is deterministic, LLM-free commands, a single bot over both vendors, and cron/memory in the control plane itself. [code.claude.com/docs/en/remote-control; code.claude.com/docs/en/channels]

**Adoption cost.**
- Install: a Python runtime through the installer, and creating a Discord application with Message Content intent and an allowlist.
- Configuration: `config.yaml` (approvals, quick_commands, backend), plus a separate LLM key and bill.
- Operations: a long-running gateway process to keep healthy on Windows now and on a VPS later.
- Security: the largest new attack surface of the three, a chat-reachable agent holding API keys on the host.
- Churn: hundreds of PRs merged a week and recent state-database corruption fixes. Pin with `-Tag` and upgrade on purpose.
- Time: about one day to a locked-down first `status`-style command, and more for safe `start issue` semantics.

**Verdict.** Defer it. Try Claude Code Remote Control server mode and the Discord channel first, since they need no new runtime. Revisit Hermes only if a provider-neutral, always-on bot with LLM-free commands is still wanted when Milestone 12 (VPS) arrives.

## Sources

All accessed 2026-10-03 unless a different date is noted.

**Pi**
- npm registry, `@earendil-works/pi-coding-agent` (dist-tags, version times): https://registry.npmjs.org/@earendil-works/pi-coding-agent. latest 1.0.0, 2026-10-01.
- npm registry, `@mariozechner/pi-coding-agent` (deprecation notice): https://registry.npmjs.org/@mariozechner/pi-coding-agent. Last 0.73.1, 2026-05-07.
- Tarball `@earendil-works/pi-coding-agent@1.0.0`: `README.md`, `CHANGELOG.md` (entries 0.66.0 2026-04-08 to 1.0.0 2026-10-01), `docs/security.md`, `docs/containerization.md`, `docs/windows.md`, `docs/models.md`, `docs/providers.md`, `docs/settings.md`, `examples/extensions/`.
- GitHub repo: https://github.com/earendil-works/pi
- Earendil, "Pi 1.0", 2026-10-01: https://earendil.com/posts/pi-1-0/
- Earendil, "“You Said No MCP!”", 2026-09-29: https://earendil.com/posts/you-said-no-mcp/
- Earendil, "Announcing Pi & Lefos", 2026-04-08: https://earendil.com/posts/announcing-pi-and-lefos/
- Mario Zechner, "I've sold out", 2026-04-08: https://mariozechner.at/posts/2026-04-08-ive-sold-out/
- Earendil RFC 0015, Pi Licensing: https://rfc.earendil.com/0015/

**Sandcastle**
- npm registry, `@ai-hero/sandcastle`: https://registry.npmjs.org/@ai-hero/sandcastle. latest 0.12.0, 2026-06-29.
- Tarball `@ai-hero/sandcastle@0.12.0`: `README.md` (providers, branch strategies, `RunOptions`, `ClaudeCodeOptions`, `CodexOptions`, `PiOptions`, `sandcastle init`).
- GitHub repo, releases, commits, pulls and issues: https://github.com/mattpocock/sandcastle (plus `/releases`, `/commits/main`, `/pulls`, `/issues`).
- Issue #1010, 2026-09-27: https://github.com/mattpocock/sandcastle/issues/1010
- PR #1014 (draft), 2026-10-02: https://github.com/mattpocock/sandcastle/pull/1014
- Issue #996, 2026-09-11: https://github.com/mattpocock/sandcastle/issues/996

**Hermes Agent**
- GitHub releases: https://github.com/NousResearch/hermes-agent/releases. v0.21.5 / v2026.9.24, 2026-09-24.
- GitHub repo README: https://github.com/NousResearch/hermes-agent
- `pyproject.toml` @ v2026.9.24: https://raw.githubusercontent.com/NousResearch/hermes-agent/v2026.9.24/pyproject.toml
- `cli.py` @ v2026.9.24 (`_run_quick_command`): https://raw.githubusercontent.com/NousResearch/hermes-agent/v2026.9.24/cli.py
- Configuration doc (quick_commands), main: https://raw.githubusercontent.com/NousResearch/hermes-agent/main/website/docs/user-guide/configuration.md
- PyPI JSON: https://pypi.org/pypi/hermes-agent/json. 0.19.0, 2026-07-20.
- Docs, Windows (Native) guide: https://hermes-agent.nousresearch.com/docs/user-guide/windows-native
- Docs, Security: https://hermes-agent.nousresearch.com/docs/user-guide/security
- Docs, CLI (quick commands): https://hermes-agent.nousresearch.com/docs/user-guide/cli
- Docs, Claude Code bundled skill: https://hermes-agent.nousresearch.com/docs/user-guide/skills/bundled/autonomous-ai-agents/autonomous-ai-agents-claude-code

**Baseline (Claude Code, Codex, Anthropic terms)**
- Claude Code, Remote Control: https://code.claude.com/docs/en/remote-control
- Claude Code, Channels (research preview): https://code.claude.com/docs/en/channels
- Claude Code, Sandboxing: https://code.claude.com/docs/en/sandboxing
- Claude Code, Choose a sandbox environment: https://code.claude.com/docs/en/sandbox-environments
- Claude Code, Legal and compliance (authentication and credential use): https://code.claude.com/docs/en/legal-and-compliance
- Codex, Sandboxing (developers.openai.com redirects here): https://learn.chatgpt.com/codex/sandboxing

**Not verified**
- Whether the Hermes gateway forwards arguments to `exec` quick commands. Only the CLI path was read.
- The `tsx` version pin.
- Star counts, which came from WebFetch summaries of GitHub pages.
- The exact date native Windows support landed in Hermes.
