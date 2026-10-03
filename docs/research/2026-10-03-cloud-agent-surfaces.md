# Cloud agent surfaces for taking one ticket to a PR (as of 2026-10-03)

Research for wayfinder ticket oneezy/ai-workflow#8, "What each cloud agent surface offers for running one ticket to a PR". Every claim comes from first-party docs, blog posts or changelogs. I fetched them on 2026-10-03. Doc pages are live and mostly undated, so a dated release note is cited wherever one exists.

## Answer

The only surface built to take one GitHub issue all the way to a pull request that watches its own CI and review feedback is a Claude Code cloud session, either standalone or as a thread in a Claude Project. You start it from a browser, the phone, the desktop app or `claude --cloud`. It runs on Anthropic's Ubuntu 24.04 VM and loads the repo's `CLAUDE.md` (or `AGENTS.md` if the repo has no `CLAUDE.md`) plus its `.claude/skills`. It pushes a branch, opens the PR, and with auto-fix on it pushes fixes when CI fails or a reviewer comments.

Projects (beta since 2026-09-17, Pro and Max only) add a coordinator that runs many of these sessions in parallel and shows a "Waiting on you" list. Routines run the same kind of session on a schedule, from an API call or from a GitHub event. GitHub triggers cover only pull request and release events, though, so routines cannot start from an issue without your own glue, such as a GitHub Action that calls the routine's `/fire` endpoint.

OpenAI's equivalent is Codex Cloud, which now runs inside ChatGPT (web, mobile, and the desktop app since 2026-07-09). It was rebuilt around reusable, published environments on 2026-09-29 and reads `AGENTS.md` plus `.agents/skills`. Its weak spot here is that the hand-off itself is manual: you review the diff, then commit or open a PR. The GitHub `@codex` integration works only in PR comments, and it still runs on the "Codex Cloud (Legacy)" stack, which OpenAI plans to deprecate.

The "dots and spaces" the user mentioned are two DevDay 2026 launches (2026-09-29):

- **Dots** are always-on personal agents. Each runs on GPT-6 Astra with its own cloud computer and browser. A dot can hand coding work to a Codex cloud environment and prepare a PR. It is a coordinator for ongoing responsibilities rather than a pipeline for a single ticket.
- **ChatGPT Space** is a home for pages and files that people and agents edit together. It is not a coding surface.

The "built-in cloud computer" is the dot's own cloud computer, plus the Work Cloud containers that let ChatGPT Work tasks keep running from web and mobile.

None of the cloud surfaces runs Windows. Claude cloud VMs are Linux, the Codex Cloud environment docs never name a Windows option, and none of them can see your local files. Windows or local-file work has to go to your own machine: Claude Remote Control (or a Project thread run locally), Codex Remote, or a dot connected to your computer.

## Comparison table

| | Claude Code cloud session | Claude Project thread | Claude routine | Codex Cloud (ChatGPT) | ChatGPT dot (+ Work Cloud) |
|---|---|---|---|---|---|
| **Status** | GA on Pro, Max and Team; Enterprise with premium or Chat + Claude Code seats | Public beta since 2026-09-17; Pro and Max only, not Team or Enterprise | Research preview (launched week of 2026-04-13); Pro, Max, Team, Enterprise | Current version since 2026-09-29; legacy stack still backs GitHub, Linear and Code Review | Rolling out since 2026-09-29; Pro 100/200/500 (outside EEA, UK, CH), Business Premium, Enterprise (admin opt-in) |
| **How a run starts** | claude.ai/code, the Code tab in the iOS/Android app, Desktop app (Cloud), `claude --cloud`, `claude -p … --cloud <id>` for follow-ups, prefilled-URL links | One message in the project conversation (web, desktop, mobile); the coordinator starts one thread per task | Schedule (minimum 1 h, cron via CLI), one-off time, HTTP `/fire` with a bearer token, GitHub `pull_request`/`release` events | ChatGPT web, desktop app (Work in > Cloud), mobile (Codex), `codex cloud exec`, `@ChatGPT` in Slack or Teams (Enterprise), Linear assign or `@Codex`, GitHub `@codex` in PR comments (legacy) | Message or call the dot in ChatGPT (desktop, then mobile), Slack, Teams; dot-set schedules; event monitoring where a connected source supports it |
| **Starts from a GitHub issue?** | Paste the issue or link; the built-in GitHub tools read issues | Paste it into the conversation | No issue trigger; an Action calling `/fire` works around this (my inference) | Not from GitHub issues; Linear issues and GitLab issues (beta) yes | Through the GitHub plugin ("investigate an issue and prepare a pull request") |
| **Repo access** | Claude GitHub App (private repos where it is installed) or `/web-setup` gh token; credentials stay outside the VM behind a GitHub proxy | Claude GitHub App required on every repo; github.com only | GitHub App needed for event triggers; repos cloned each run from the default branch | GitHub connected to ChatGPT; environment's repo map; access follows the account running the task | Through the GitHub plugin and its permissions, or a Codex cloud environment |
| **Branch rules** | Proxy blocks tag pushes and branch deletes but not which branch you push to; use GitHub rulesets | New branch from the default branch; opens a PR for concrete changes; auto-fix always on | Pushes to `claude/*` unless the prompt says otherwise; rulesets apply against your access | Not documented for the current cloud; you commit or open the PR from the review UI | Not documented |
| **Secrets** | Env vars, readable by anyone using the environment; API credentials injected by a proxy (Pro and Max only) | Same as cloud sessions (project's environment) | Same as cloud sessions | Env vars, plus network secrets (placeholder swapped by the proxy for allowed HTTPS:443 hosts), a Personal vault, OIDC on request (Enterprise) | Private sign-in form for websites; plugin accounts; separate cloud-browser sessions |
| **Network** | None, Trusted (default allowlist), Full, or Custom; GitHub, MCP connectors and the Anthropic API bypass the allowlist | Same | Same; Default environment is Trusted | Off by default; Package managers preset, custom domains, or unrestricted; Tailscale VPN | Admin "Cloud network access" and "Cloud browser use" toggles |
| **Instructions and skills loaded** | Repo `CLAUDE.md` (or `AGENTS.md` if there is no CLAUDE.md), `.claude/rules`, `.claude/skills\|agents\|commands`, hooks and permissions in single-repo sessions, `.mcp.json`, skills enabled on claude.ai. Not `~/.claude`, and not repo-declared plugins | Each repo's `CLAUDE.md` and skills, project instructions (16k chars), project memory `MEMORY.md`, plugins added in project settings, claude.ai connectors; hooks and permissions only in single-repo projects | Same as a cloud session; connectors included by default | `AGENTS.md` chain (32 KiB cap; also `## Code Review Rules`); repo `.agents/skills`; personal skills are not synced to the cloud | Plugins and skills on the account; local skills only through a connected computer |
| **Parallel runs** | Each session is independent; start as many as you like (rate limits apply) | Coordinator runs many at once; hard cap of 200 new threads/day | 100 scheduled runs/h per account; 30/h per routine for Run now and API; hourly GitHub event caps | One task per workspace from one environment; best-of-N 1–4 via `--attempts` | Background agents and several cloud threads at once |
| **Answering a question mid-run** | Reply in the session on web, phone or desktop; an idle question waits until the VM expires; queued messages can be retracted | Answer inside the thread; Overview "Waiting on you"; desktop notifications | Autonomous with no permission picker; open the run session afterwards to continue | Follow up in the same task on web, mobile or desktop; setup asks for missing access | Dot messages you on your chosen channel; Activity shows requests; Take over and Return control on its computer |
| **PR review loop** | Auto-fix: reacts to CI failures and review comments, asks when unclear; cannot see merge conflicts | Auto-fix on by default; card buttons for Fix CI, Address comments, Resolve conflicts, Merge it | Same as a cloud session if the prompt opens a PR | `@codex review` / auto review (P0/P1 only); `@codex fix …` starts a legacy cloud task that can push to the branch; event-triggered tasks on PR activity (web and mobile) | "Prepare a fix for code review before merging" |
| **Cost and limits** | Shares your plan's rate limits; no separate VM charge | Same limits, used faster; waits for reset; usage credits for overage | Subscription limits plus the hourly caps above; usage credits for overage | Shares the ChatGPT Work/Codex allowance; cloud tasks use more than local; Pro has no 5-hour limit; weekly limits may apply; credits | Dot chat is free of limits; tasks it starts count toward Work and Codex limits; plan allowance for deeper work |
| **Hardware** | Ubuntu 24.04 x86_64, ~4 vCPU / 16 GB RAM / 30 GB disk | Same | Same | Plus: 2 vCPU / 8 GiB / 8 GiB. Pro, Business, Enterprise: 4 / 16 / 32 GiB | Not documented |
| **Cannot do** | Windows or macOS builds, local files, interactive SSO, non-GitHub push (GitLab only as an upload with no push back), orgs with IP allowlists or ZDR | Team and Enterprise plans; GHES, GitLab, Bitbucket; sharing; the CLI and IDEs | Issue events; intervals under 1 h; mid-run approval | Computer and browser use; GHES (and GitLab, per the environments page; but see GitLab beta below); local files, processes and VPN sign-ins | Local work unless a computer is connected and online; data residency (Enterprise beta) |

## Claude Code cloud sessions (claude.ai/code)

- **Start points.** Browser, the Code tab of the Claude mobile app, the Desktop app with **Cloud** selected, `claude --cloud "task"` (`--remote` is a deprecated alias), and routines. `claude -p "msg" --cloud <session-id>` posts a follow-up into a running session from any logged-in machine, including CI. `--teleport` pulls a cloud session and its branch into a local terminal, one-way. [S1]
- **Plans.** Pro, Max and Team, plus Enterprise users with premium or Chat + Claude Code seats. Orgs with Zero Data Retention cannot use cloud sessions. Orgs with IP allowlisting fail unless Anthropic exempts them. [S1]
- **GitHub.**
  - The Claude GitHub App covers public repos and the private repos it is installed on. `/web-setup` instead uploads your `gh` token and reaches whatever that token can.
  - In Anthropic-hosted environments, credentials never enter the VM: a GitHub proxy swaps in a scoped credential.
  - The proxy rejects tag pushes and branch deletions but "doesn't limit which branches a push can update", so use GitHub branch protection or rulesets.
  - API calls reach only repos attached to the session.
  - GraphQL is restricted to a pinned set of PR operations, so Projects v2 is unreachable.
  - The built-in GitHub tools read issues, list PRs and post comments. `gh` is preinstalled, and `GH_TOKEN` reads `proxy-injected`. [S1][S2]
- **Environments, network and secrets.**
  - Network levels are None, Trusted (the default allowlist), Full, or Custom.
  - GitHub, MCP connectors, API-credential hosts and the Anthropic API bypass the allowlist.
  - Environment variables are readable by anyone using the environment. On Pro and Max only, "API credentials" are attached by the agent proxy and never reach the VM; Team and Enterprise don't have them yet.
  - Setup scripts run as root and are snapshot-cached if they finish in about 5 minutes. [S2]
- **What loads.**
  - From the clone: repo `CLAUDE.md`, `.claude/rules/`, `.claude/skills|agents|commands/`, and `.mcp.json` plus `.claude/settings.json` hooks and permissions in single-repo sessions.
  - Not loaded: plugins declared in the repo's settings, anything in `~/.claude` (user CLAUDE.md, skills, plugins, local MCP servers), and interactive SSO.
  - Skills you enable on claude.ai do load. [S2]
  - Claude Code reads `AGENTS.md` when there is no `CLAUDE.md` or `CLAUDE.local.md`; when both exist it reads only the CLAUDE.md files. [S3]
  - Implication for this setup: library skills synced to `~/.claude/skills` by `@oneezy/skills-sync` are not in a cloud session unless the setup script syncs them, which is what `ai-workflow/AGENTS.md` already instructs.
- **Mid-run interaction.**
  - Steer or answer from web, phone or desktop. An idle question waits "up to environment expiry".
  - Queued messages can be taken back before Claude reads them (week 37, 2026-09-07..11).
  - Permission modes in the cloud are Accept edits, Plan and Auto, with no Manual or Bypass. [S1][S4][S9]
  - Mobile push notifications arrived the week of 2026-04-13 [S10]. Per the mobile doc they fire when Remote Control is active. [S11]
- **PR review loop (auto-fix).**
  - Needs the Claude GitHub App.
  - Claude subscribes to the PR's CI failures and review comments. It pushes clear fixes, asks when a comment is ambiguous, and replies on GitHub under your username labelled as Claude Code.
  - It cannot react to merge conflicts because GitHub sends no webhook for them.
  - It can be turned on from the session, with `/autofix-pr` in the terminal, from the mobile app, or for any PR URL.
  - First shipped the week of 2026-03-23. [S1][S12]
- **Limits.**
  - Shares rate limits with all your Claude usage, with "no separate compute charge for the cloud VM".
  - Roughly 4 vCPU, 16 GB RAM and 30 GB disk.
  - Foreground commands time out at 2 minutes by default (up to 10 on request), then move to the background for up to 30 more minutes.
  - Idle VMs pause and are later reclaimed. [S1][S2]
- **Cannot.**
  - Run Windows or macOS: the VM is Ubuntu 24.04 x86_64.
  - Push anywhere but GitHub. Self-hosted GHES works on Team and Enterprise; GitLab and Bitbucket only as a bundle upload with no push back.
  - See local files, except through a bundle upload.
  - For local or Windows work, use Remote Control, which steers a session on your own machine from your phone or browser. Self-hosted environments (public beta on Team and Enterprise since the week of 2026-08-03) run cloud sessions on your own runners. [S1][S2][S13]

## Claude Projects threads

- **What it is.** "One ongoing conversation where Claude coordinates a stream of related work". Each thread is a cloud session on its own branch that opens PRs. Announced as a beta on 2026-09-17 for select Pro and Max users. Not on Team or Enterprise, and not in the CLI or IDEs. Usable on web, desktop and the iOS/Android apps. [S5][S6]
- **Per-thread defaults.**
  - New branch from the default branch.
  - Opens a PR when asked, or on its own for a concrete fix.
  - Auto-fix is always on once the PR is open.
  - Thread cards offer **Fix CI**, **Address comments**, **Resolve conflicts**, **Merge it** and **Create PR**. [S5]
- **Context.**
  - Project instructions (up to 16,000 chars).
  - Project memory, a `MEMORY.md` index read by every cloud thread.
  - Each repo's `CLAUDE.md` and `.claude/skills|agents|commands`.
  - Plugins added in **Project settings > Plugins**.
  - All claude.ai connectors.
  - In multi-repo projects, no repo's hooks, permissions or `env` apply.
  - The Claude GitHub App is required on every repo; a `/web-setup` token is not enough.
  - github.com only. [S5]
- **Human in the loop.**
  - Threads run in auto mode. An approval prompt waits inside its thread, and telling the coordinator "go ahead" does not reach it.
  - **Overview** groups threads as Ready for review, Waiting on you, Working, Landing, Idle and Resolved.
  - Desktop notifications fire when a thread needs input. [S5]
- **Local or Windows.** A thread can run on your computer through Remote Control (**Work locally**, Claude Code v2.1.280+), using that machine's files, tools and settings while it is awake. [S5]
- **Cost.**
  - Same plan limits, used faster.
  - A thread that hits the limit waits for the reset.
  - Overage only with usage credits.
  - Hard cap of 200 new threads per day.
  - Idle threads watching a PR wake (and spend) on CI or review events.
  - New projects default to Opus at high effort. [S5]
- **Limits.**
  - Single-user, with no sharing.
  - A thread cannot move between projects.
  - Sandboxes pause between turns, and uncommitted work can be lost if a resume fails. [S5]

## Claude routines (scheduled and triggered cloud runs)

- **What it is.** A saved prompt plus repos, environment, connectors and triggers that "run autonomously as full Claude Code cloud sessions", with no permission picker. Research preview, launched the week of 2026-04-13. Pro, Max, Team and Enterprise. Managed at claude.ai/code/routines, from the Desktop app (Cloud), or with `/schedule` in the CLI. [S7][S10]
- **Triggers.**
  - Schedules: hourly, daily, weekdays, weekly, a custom cron through `/schedule update` (minimum one hour), or a one-off time.
  - API: `POST …/routines/<id>/fire` with a per-routine bearer token. The optional `text` arrives wrapped as untrusted `<routine-fire-payload>`. Uses the beta header `experimental-cc-routine-2026-04-01`.
  - GitHub: **pull request** and **release** events only, filtered by author, title, body, base or head branch, and labels. [S7]
  - There is no issue event. To start a routine from `issues.labeled`, you would call `/fire` from a GitHub Action. That is my inference from the docs, not a documented recipe.
- **Branches.** Cloned from the default branch each run, pushing to `claude/`-prefixed branches unless the prompt says otherwise. Rulesets apply against your connected GitHub access. [S7]
- **Identity and limits.**
  - Runs as you, so commits, PRs and connector actions carry your identity.
  - 100 scheduled runs per hour per account. 30 per hour per routine, shared by Run now, API fires and one-off reruns.
  - GitHub events have per-routine and per-account hourly caps, and excess events are dropped.
  - Subscription limits apply, with overage only through usage credits.
  - A green run status means only that the run started and exited without an infrastructure error, not that the task succeeded. [S7]
- **Related, not cloud.** The Claude Code GitHub Action (`anthropics/claude-code-action`) does respond to `@claude` in issues and PRs and turns issues into PRs. It runs on GitHub Actions runners with an API key or a `CLAUDE_CODE_OAUTH_TOKEN` subscription token, not on the claude.ai cloud. [S14]

## OpenAI Codex Cloud (inside ChatGPT)

- **Where it lives now.** OpenAI's docs moved to learn.chatgpt.com (developers.openai.com/codex/cloud redirects there, HTTP 308). Codex merged into the ChatGPT desktop app on 2026-07-09. In the composer, **Work in** chooses between This computer (Local or Worktree) and **Cloud**. [S20][S21][S22]
- **Start points.**
  - Web and desktop: Work in > Cloud, pick a published environment.
  - Mobile: open **Codex**.
  - CLI: `codex cloud exec --env <id> [--attempts 1-4]`.
  - `@ChatGPT` in Slack or Teams with Cloud delegation (Enterprise).
  - Linear: assign the issue or `@Codex`; triage rules can auto-assign.
  - GitHub PR comments: `@codex review` and `@codex <task>`.
  - GitLab issues and MRs with `@codex`, in beta since 2026-08-19. [S20][S21][S23][S24][S25][S26]
- **Environments (rebuilt 2026-09-29).**
  - Pick repos, and Codex inspects them, installs dependencies and tests the workflow. You review and **Publish**.
  - Each task gets an isolated workspace from the published filesystem.
  - Task state is recoverable for 7 days.
  - Environments can be shared across a workspace. [S21][S27]
  - **Codex Cloud (Legacy)** still backs Code Review and the Linear and GitHub integrations, and OpenAI says "We plan to deprecate this experience". Legacy secrets were available to setup scripts only. [S21][S28]
- **Network and secrets.**
  - Internet is off unless turned on, then Package managers preset, custom domains, or unrestricted.
  - Environment variables are passed through directly.
  - Network secrets give programs a placeholder, and the proxy substitutes the real value only for allowed HTTPS:443 hosts.
  - Personal vault values per user.
  - Tailscale VPN.
  - OIDC cloud identities on request for Enterprise.
  - Published egress IP feed. [S21]
- **Instructions and skills.**
  - `AGENTS.md` chain: global `~/.codex/AGENTS.md`, then project root down to the working directory, with `AGENTS.override.md` support and a 32 KiB cap. [S29]
  - Code review follows `## Code Review Rules` sections in `AGENTS.md`. [S23]
  - Repo skills come from `.agents/skills` (each directory up to the repo root). "Skills stored in your repository are available in cloud tasks. Personal skills from your local computer aren't synced to cloud environments." [S21][S30]
  - CLAUDE.md is not read natively. The desktop app's **Import** (2026-08-11) converts Claude Code instructions, settings and skills (for example `CLAUDE.md` to `AGENTS.md`, `~/.claude/skills` to `~/.agents/skills`). [S22][S31]
- **To a PR.**
  - The cloud flow ends with "Review changes and test results, request follow-ups, and commit or open a pull request when ready". [S20]
  - In GitHub, `@codex review` and automatic reviews flag only P0/P1 issues. `@codex fix the P1 issue` starts a legacy cloud task that "can push a fix back to the branch when it has permission". There is also an in-depth `@codex security review`. [S23]
  - Event-triggered scheduled tasks (2026-08-25) can fire on GitHub PR activity (reviews, comments, commits, merges). They are web and mobile only and cannot be combined with a time schedule. [S22][S32]
  - None of these pages documents a GitHub issue trigger or `@codex` in GitHub issue comments.
- **Parallel.** Any number of tasks from one environment, each isolated. Best-of-N up to 4 attempts from the CLI. [S21][S33]
- **Mid-run.**
  - Reopen the task on web, mobile or desktop and send follow-ups.
  - Setup asks for missing access.
  - Desktop notifications cover questions and permissions, and Activity view lists "waiting for your response". [S21][S34]
  - The cloud pages did not show whether a cloud task can stop to ask a question mid-turn, as opposed to taking a follow-up after it finishes.
- **Cost and limits.**
  - ChatGPT Work and Codex share one allowance. "Cloud tasks may use more of your allowance than local messages."
  - Plus and Standard Business have 5-hour windows (for example GPT-6.1 Sol at 15–160 local messages per 5 h). Pro ($100/$200/$500) has no 5-hour limit. Weekly limits may apply. Credits extend usage.
  - API-key users get no cloud features.
  - GPT-5.5 retires 2026-10-14; move scheduled tasks to GPT-6 Sol. [S35]
  - VMs: Plus 2 vCPU / 8 GiB / 8 GiB; Pro, Business and Enterprise 4 / 16 / 32 GiB. [S21]
- **Cannot.**
  - "Computer and browser use" and "GitLab and self-hosted GitHub Enterprise Server" are listed as unsupported in cloud environments. GitLab beta does exist through the legacy integration path. [S21][S26]
  - Cloud tasks do not get your local files, processes, browser sign-ins or VPN. [S36]
  - Windows work goes through the desktop app's Windows support or **Codex Remote**, where the phone drives a connected Mac or Windows PC that must stay awake. [S37]

## ChatGPT desktop: "dots", "Space", Work Cloud and the cloud computer

These launched at **DevDay 2026 on 2026-09-29** and in the week of 2026-09-28..10-02. [S22][S38][S39]

- **Dots ("dots").**
  - "An always-on agent that keeps work moving across your tools and projects", powered by GPT-6 Astra.
  - It "lives in the cloud and has its own computer and browser" and keeps working while your devices are off.
  - You create it in the desktop app or a desktop browser and can continue on the mobile app. Mobile web is not supported.
  - Reached from ChatGPT, a phone call, Slack or Teams. Handle `@yourname-dot`.
  - Can connect **one** personal computer (online, ChatGPT app open) for local files, code and apps. Local skills require that connection.
  - For coding it can "create a task in a Codex cloud environment you have already set up", start and continue local Codex tasks, and use the GitHub plugin to "investigate an issue and prepare a pull request".
  - Runs background agents in parallel, and sets schedules and event monitors when you ask.
  - Approvals come from automatic action review plus optional custom rules (take action, take action when told, ask first, hand off). **Take over** and **Return control** apply on its computer, and **Pause** stops the main task.
  - Plans: Pro 100/200/500 (18+, outside the EEA, UK and Switzerland), Business Premium, and Enterprise (off by default; no data residency in the beta; not on FedRAMP or EKM workspaces).
  - Usage: "Conversations with your dot don't count toward your ChatGPT usage limits". Work and Codex tasks it starts do count. [S40][S41][S42][S43][S44][S45]
- **ChatGPT Space ("spaces").**
  - "A home for your pages, files, and shared work with ChatGPT".
  - Pages are editable documents. A "space" groups pages around a topic or team.
  - Agents are invoked with `@ChatGPT` or `@dot` inline or in comments, plus `/Generate`, `/Visualize` and `/Image`.
  - Web, where available. "Keep Updated" is not available at launch. It is not a coding or PR surface. [S46][S47]
- **The cloud computer.**
  - There are two documented "cloud computers": the dot's own cloud computer and browser, and **Work Cloud**.
  - With "Local computer access with Work Cloud", a Work task started on desktop is coordinated in OpenAI's cloud and can be continued from web or mobile while still using the connected computer's files.
  - Needs the desktop app 26.929+ and a workspace admin opt-in.
  - Without the local machine, the task continues in a cloud container that cannot see local files. [S48][S49][S50]
- **For one ticket to a PR**, a dot is an orchestration layer over Codex Cloud environments and the GitHub plugin, not a separate coding runtime with its own repo, branch and PR controls. Use it for ongoing responsibilities, such as "watch this feedback channel and prepare fixes", rather than as the per-ticket executor.

## Takeaways for oneezy/ai-workflow

1. **One issue to a reviewed PR in the cloud today:** a Claude Code cloud session, or a Project thread on Pro or Max. It is the only surface with a documented PR-watching auto-fix loop. Commit skills to `.claude/skills` in the repo, or sync them in the environment's setup script, because `~/.claude` does not carry over.
2. **Event-driven starts:** neither vendor's cloud scheduler triggers on GitHub *issues*. Claude routines take PR and release events plus an API `/fire`. ChatGPT event tasks take PR activity only. Issue-driven runs need glue (an Action calling `/fire`), the Claude GitHub Action, or Linear for Codex.
3. **Windows and local files:** route them to a local session steered from the phone (Claude Remote Control or a Project's **Work locally**, Codex Remote, or a dot with a connected computer). No cloud surface covers them.
4. **Instruction portability:** keep `AGENTS.md` as the shared source. Codex reads it natively, and Claude reads it only when there is no `CLAUDE.md`. This repo's `CLAUDE.md` is `@AGENTS.md`, so Claude gets the content through the import while Codex reads the file directly. Skills live in two places: `.claude/skills` for Claude and `.agents/skills` for Codex.

## Sources

Fetched 2026-10-03 unless noted. Dates in brackets are publication or release dates shown on the page.

- [S1] Use Claude Code in the cloud: https://code.claude.com/docs/en/claude-code-on-the-web
- [S2] Configure cloud environments: https://code.claude.com/docs/en/cloud-environments
- [S3] How Claude remembers your project (AGENTS.md section): https://code.claude.com/docs/en/memory
- [S4] Get started with Claude Code in the cloud: https://code.claude.com/docs/en/web-quickstart
- [S5] Let Claude coordinate ongoing work with Projects: https://code.claude.com/docs/en/claude-projects
- [S6] Claude blog, "Projects redesigned: from folder to conversation" [2026-09-17]: https://claude.com/blog/projects-redesigned
- [S7] Automate work with routines: https://code.claude.com/docs/en/routines
- [S9] Claude Code what's new, week 37 [2026-09-07..11]: https://code.claude.com/docs/en/whats-new/2026-w37
- [S10] Claude Code what's new, week 16 (Routines on the web, mobile push notifications) [2026-04-13..17]: https://code.claude.com/docs/en/whats-new/2026-w16
- [S11] Claude Code on mobile: https://code.claude.com/docs/en/mobile
- [S12] Claude Code what's new, week 13 (PR auto-fix in the cloud) [2026-03-23..27]: https://code.claude.com/docs/en/whats-new/2026-w13
- [S13] Claude Code what's new, week 32 (self-hosted environments) [2026-08-03..07]: https://code.claude.com/docs/en/whats-new/2026-w32
- [S14] Claude Code GitHub Actions: https://code.claude.com/docs/en/github-actions
- [S20] Codex Cloud: https://learn.chatgpt.com/docs/cloud (formerly developers.openai.com/codex/cloud, 308 redirect)
- [S21] Cloud environments (Codex): https://learn.chatgpt.com/docs/environments/cloud-environments
- [S22] ChatGPT/Codex What's new digest (2026-07-09 Codex app merger, 2026-08-11 import and Linux, 2026-08-25 event triggers, DevDay): https://learn.chatgpt.com/docs/whats-new
- [S23] Review GitHub pull requests with Codex: https://learn.chatgpt.com/docs/third-party/github
- [S24] Use Codex in Linear: https://learn.chatgpt.com/docs/third-party/linear
- [S25] Use ChatGPT in Slack: https://learn.chatgpt.com/docs/third-party/slack
- [S26] What's new, "Work with GitLab projects in Codex cloud" [release notes 2026-08-19]: https://learn.chatgpt.com/docs/whats-new (section August 17–21, 2026)
- [S27] What's new, "Prepare reusable Codex Cloud environments" [2026-09-28..10-02]: https://learn.chatgpt.com/docs/whats-new/september-28-october-2-2026
- [S28] Codex Cloud (Legacy): https://learn.chatgpt.com/docs/environments/cloud-environment and internet access https://learn.chatgpt.com/docs/cloud/internet-access
- [S29] Custom instructions with AGENTS.md: https://learn.chatgpt.com/docs/agent-configuration/agents-md
- [S30] Build skills (skill locations): https://learn.chatgpt.com/docs/build-skills
- [S31] Import from another agent: https://learn.chatgpt.com/docs/import (examples quoted from https://learn.chatgpt.com/docs/llms-full.txt)
- [S32] Scheduled tasks (event triggers): https://learn.chatgpt.com/docs/automations
- [S33] Codex CLI reference, `codex cloud exec --attempts` (in https://learn.chatgpt.com/docs/llms-full.txt)
- [S34] Notifications: https://learn.chatgpt.com/docs/notifications
- [S35] Pricing: https://learn.chatgpt.com/docs/pricing
- [S36] Codex environments (Local, Worktree, Cloud): https://learn.chatgpt.com/docs/environments/modes
- [S37] Codex Remote: https://learn.chatgpt.com/docs/remote
- [S38] DevDay 2026 [2026-09-29]: https://learn.chatgpt.com/docs/whats-new/devday-2026
- [S39] What's new, September 28–October 2, 2026: https://learn.chatgpt.com/docs/whats-new/september-28-october-2-2026
- [S40] Meet dots: https://learn.chatgpt.com/docs/dots
- [S41] Connect computers and apps to your dot: https://learn.chatgpt.com/docs/dots/computers-and-apps
- [S42] Tasks and memory (dots): https://learn.chatgpt.com/docs/dots/tasks-and-memory
- [S43] Control your dot: https://learn.chatgpt.com/docs/dots/controls
- [S44] Get started with your dot: https://learn.chatgpt.com/docs/dots/getting-started
- [S45] Set up dots for work (admin guide): https://learn.chatgpt.com/docs/enterprise/dots-admin-guide
- [S46] ChatGPT Space: https://learn.chatgpt.com/docs/space
- [S47] Work with agents in Space: https://learn.chatgpt.com/docs/space/agents
- [S48] Local computer access for Work Cloud and dots: https://learn.chatgpt.com/docs/enterprise/cloud-local-access
- [S49] Get started with ChatGPT Work: https://learn.chatgpt.com/docs/get-started-with-work
- [S50] ChatGPT Work cloud security: https://learn.chatgpt.com/docs/enterprise/chatgpt-work-cloud-security

## Gaps and caveats

- The ChatGPT release-notes article (help.openai.com/en/articles/6825453) returned HTTP 403, so OpenAI dates come from the learn.chatgpt.com digest and the dated DevDay page.
- The current Codex Cloud docs do not say what branch name a cloud task pushes to, whether a cloud task can stop mid-turn for a question, or what OS the new environments use. The legacy stack used the `codex-universal` image (openai/codex-universal).
- The Codex environments page lists GitLab as unsupported, while the 2026-08-19 notes announce GitLab beta in Codex cloud. GitLab most likely runs through the legacy integration path. That is unconfirmed.
- Dots, Projects and routines are all beta or research preview, and their limits and plans may change.
