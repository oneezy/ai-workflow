# Tool Catalog

<!-- tools.csv is canonical. Update tools.csv first and update this mirror in the same change. -->

This table is an exact Markdown view of `tools.csv`. `Checked` records when the catalog entry was reviewed; it does not claim that every upstream version was re-verified that day.

🟢 Use · 🔵 Selected · 🟡 Test · 🟣 Research · ⚪ Watch · 🟠 Hold · 🔴 Rejected · ⚫ Replaced · 🟤 Archived

| Name | Category | Status | Version | Role | Platform | URL | Notes | Checked |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| VS Code | IDE | 🟢 Use | Current | Primary editor | Windows; WSL | https://code.visualstudio.com/ | Selected editor and current human-facing coding workspace. | 2026-08-08 |
| WSL Extension | IDE | 🟢 Use | Current | Remote development bridge | Windows; WSL | https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl | Connects the Windows VS Code UI to the Ubuntu repository. | 2026-08-08 |
| Zed | IDE | ⚪ Watch | Current | Alternative editor and ACP client | Windows; Linux; macOS | https://zed.dev/ | Re-evaluate after the workflow is reliable; notable for ACP and Pi support. | 2026-08-08 |
| Cursor | IDE | ⚪ Watch | Current | AI-first editor alternative | Windows; Linux; macOS | https://www.cursor.com/ | Alternative editor and Sandcastle agent provider; not selected for the initial lab. | 2026-08-08 |
| Windsurf | IDE | ⚪ Watch | Current | AI-first editor alternative | Windows; Linux; macOS | https://windsurf.com/ | Alternative editor; not selected for the initial lab. | 2026-08-08 |
| Codex Desktop | Harness | 🟢 Use | Current | Supervised coordinator | Windows; WSL execution | https://openai.com/codex/ | Primary human-facing control surface configured to execute in WSL. | 2026-08-08 |
| Codex CLI | Harness | 🟢 Use | 0.145.0 | Portable coding agent | Linux; WSL; Sandbox | https://github.com/openai/codex | Primary terminal and headless execution layer. | 2026-08-08 |
| Claude Code | Harness | 🔵 Selected | 2.1.220 | Specialist coding agent | Linux; WSL; Sandbox | https://github.com/anthropics/claude-code | Optional planner, architect, implementer, and reviewer. | 2026-08-08 |
| GitHub Copilot CLI | Harness | 🔵 Selected | 1.0.74 | GitHub-adjacent coding agent | Linux; WSL; VS Code | https://github.com/github/copilot-cli | Optional GitHub-native and VS Code-adjacent worker. | 2026-08-08 |
| Pi | Harness | 🟡 Test | 0.82.0 | Interactive agent harness | Linux; WSL; Sandbox | https://pi.dev/ | Bounded evaluation after the first clean Codex pull request. | 2026-08-08 |
| OpenCode | Harness | ⚪ Watch | Current | Provider-flexible coding agent | Linux; WSL; Sandbox | https://opencode.ai/ | Alternative terminal agent and Sandcastle provider. | 2026-08-08 |
| Herdr | Orchestration | 🟣 Research | Current | Multi-agent terminal multiplexer | Linux; macOS | https://herdr.dev/ | New candidate for spawning, watching, resuming, and steering multiple terminal agents. | 2026-08-08 |
| Sandcastle | Orchestration | 🔵 Selected | 0.12.0 | Bounded isolated agent orchestration | Docker; Podman; Vercel Sandbox | https://github.com/mattpocock/sandcastle | Manages agents, branches, worktrees, iterations, cleanup, commits, and PR preparation. | 2026-08-08 |
| Hermes | Control | 🔵 Selected | Current | Remote control plane | Windows; future Linux VPS | https://github.com/NousResearch/hermes-agent | Planned bounded remote control; must not receive unrestricted merge, production, secret, or shell access. | 2026-08-08 |
| Codex Mobile | Control | ⚪ Watch | Current | Mobile session control | Mobile | https://openai.com/codex/ | Alternative way to steer Codex sessions remotely without a separate command layer. | 2026-08-08 |
| Agent Skills CLI | Workflow | 🔵 Selected | 1.5.20 | Skills installer | Node.js; WSL | https://skills.sh/ | Installs project-scoped Agent Skills for supported coding agents. | 2026-08-08 |
| Matt Pocock Skills | Workflow | 🔵 Selected | Current | Specification and delivery skills | Agent harnesses | https://github.com/mattpocock/skills | Planned grilling, specification, ticket, TDD, implementation, and review skills. | 2026-08-08 |
| GitHub Actions | Workflow | 🔵 Selected | Current | CI enforcement | GitHub | https://github.com/features/actions | Planned shared validation and branch-policy evidence for all workers. | 2026-08-08 |
| Vite+ | Toolchain | 🟢 Use | Latest stable; 0.2.8 verified | Unified Node toolchain | Linux; WSL | https://viteplus.dev/ | Environment, package, dev, check, test, build, and task authority. Bootstrap prompt still says 0.2.6 and needs reconciliation. | 2026-08-08 |
| Node.js | Toolchain | 🟢 Use | 24.18.0 LTS | JavaScript runtime | Linux; WSL; Sandbox | https://nodejs.org/ | Managed by Vite+ for this lab. | 2026-08-08 |
| pnpm | Toolchain | 🟢 Use | 11.17.0 | Package manager | Linux; WSL; Sandbox | https://pnpm.io/ | Workspace package manager managed and invoked through Vite+. | 2026-08-08 |
| TypeScript | Toolchain | 🔵 Selected | 7.0.2 | Language and compiler | Node.js | https://www.typescriptlang.org/ | Selected language and compiler for the framework-free lab. | 2026-08-08 |
| Vite | Toolchain | 🔵 Selected | Via Vite+ | Development server | Node.js | https://vite.dev/ | Underlying development server exposed through Vite+ commands. | 2026-08-08 |
| Rolldown | Toolchain | 🔵 Selected | Via Vite+ | Production bundler | Node.js | https://rolldown.rs/ | Underlying production build component exposed through Vite+. | 2026-08-08 |
| tsx | Toolchain | 🔵 Selected | 4.23.1 | TypeScript script runner | Node.js; Sandbox | https://tsx.is/ | Runs Sandcastle TypeScript scripts. | 2026-08-08 |
| npm | Toolchain | ⚫ Replaced | Managed by Vite+ | Direct package commands | Node.js | https://www.npmjs.com/ | Direct npm package management is replaced by normalized Vite+ commands; README still uses npm for the isolated Pi experiment. | 2026-08-08 |
| Corepack | Toolchain | 🟠 Hold | Bundled with Node.js | Package-manager shim | Node.js | https://nodejs.org/api/corepack.html | Verified as part of the environment but not the package-manager authority. | 2026-08-08 |
| NVM | Toolchain | ⚫ Replaced | Current | Node version manager | Linux; macOS | https://github.com/nvm-sh/nvm | Vite+ replaces this role inside WSL. | 2026-08-08 |
| fnm | Toolchain | ⚫ Replaced | Current | Node version manager | Windows; Linux; macOS | https://github.com/Schniz/fnm | Vite+ replaces this role inside WSL. | 2026-08-08 |
| Volta | Toolchain | ⚫ Replaced | Current | JavaScript tool manager | Windows; Linux; macOS | https://volta.sh/ | Vite+ replaces this role inside WSL. | 2026-08-08 |
| Deno | Toolchain | 🔴 Rejected | Current | Alternative runtime and toolchain | Windows; Linux; macOS | https://deno.com/ | Not selected because it changes the lab's runtime and ecosystem assumptions. | 2026-08-08 |
| Bun | Toolchain | 🔴 Rejected | Current | Alternative runtime and package manager | Windows; Linux; macOS | https://bun.sh/ | Not selected as the compatibility baseline for this workflow. | 2026-08-08 |
| Vitest | Testing | 🔵 Selected | 4.1.10 | Unit and integration testing | Node.js; Vite+ | https://vitest.dev/ | Selected test runner supplied through Vite+. | 2026-08-08 |
| Playwright Test | Testing | 🔵 Selected | 1.62.0 | Browser and deployment testing | Node.js; Browsers | https://playwright.dev/ | Selected cross-browser E2E, smoke, trace, screenshot, and video test system. | 2026-08-08 |
| Playwright CLI | Testing | 🔵 Selected | 0.1.17 | Browser control for agents | Node.js; Browsers | https://github.com/microsoft/playwright-cli | Provides browser-control skills and CLI access for coding agents. | 2026-08-08 |
| Cypress | Testing | 🔴 Rejected | Current | Browser testing alternative | Node.js; Browsers | https://www.cypress.io/ | Mature alternative, but Playwright is selected for the lab. | 2026-08-08 |
| WebdriverIO | Testing | 🔴 Rejected | Current | WebDriver testing alternative | Node.js; Browsers | https://webdriver.io/ | Flexible alternative, but Playwright is selected for the lab. | 2026-08-08 |
| Docker Desktop | Sandbox | 🟢 Use | Current | Local container runtime | Windows; WSL | https://www.docker.com/products/docker-desktop/ | Selected local Linux sandbox with WSL integration; do not install a second engine inside WSL. | 2026-08-08 |
| Docker Engine | Sandbox | 🟠 Hold | Current | Native container runtime | Future Linux VPS | https://docs.docker.com/engine/ | Reserved for the VPS; intentionally not installed separately inside WSL. | 2026-08-08 |
| Docker Compose | Sandbox | 🟠 Hold | Current | Multi-container configuration | Future Linux VPS | https://docs.docker.com/compose/ | Planned with the native Docker Engine during VPS setup. | 2026-08-08 |
| Podman | Sandbox | ⚪ Watch | Current | Rootless container alternative | Linux; WSL | https://podman.io/ | Alternative sandbox provider for Sandcastle. | 2026-08-08 |
| Vercel Sandbox | Sandbox | ⚪ Watch | Current | Cloud microVM sandbox | Cloud | https://vercel.com/docs/vercel-sandbox | Disposable remote-worker alternative for Sandcastle. | 2026-08-08 |
| Vercel | Deployment | 🔵 Selected | Current | Preview, staging, and production platform | Cloud | https://vercel.com/ | Selected deployment platform for the lab while builds and tests remain portable. | 2026-08-08 |
| Vercel CLI | Deployment | 🔵 Selected | 58.0.0 | Deployment command line | Linux; WSL | https://vercel.com/docs/cli | Used after human authentication for project linking and inspection; production remains merge-triggered. | 2026-08-08 |
| Coolify | Deployment | 🟠 Hold | Current | Self-hosted deployment platform | Linux VPS | https://coolify.io/ | Strong later VPS option; explicitly excluded from the first bootstrap. | 2026-08-08 |
| Cloudflare Pages | Deployment | ⚪ Watch | Current | Git-based web deployment | Cloud | https://pages.cloudflare.com/ | Edge-first deployment alternative. | 2026-08-08 |
| Cloudflare Workers | Deployment | ⚪ Watch | Current | Edge compute deployment | Cloud | https://workers.cloudflare.com/ | Cloudflare-native application and service alternative. | 2026-08-08 |
| Netlify | Deployment | ⚪ Watch | Current | Git-based web deployment | Cloud | https://www.netlify.com/ | Established preview and deployment alternative. | 2026-08-08 |
| Windows | Platform | 🟢 Use | 11 | Host operating system | Desktop | https://www.microsoft.com/windows/ | Hosts the UI applications while development execution stays in WSL. | 2026-08-08 |
| Ubuntu | Platform | 🟢 Use | 26.04 LTS | Linux development environment | WSL; future VPS | https://ubuntu.com/ | Current WSL distribution and future VPS baseline. | 2026-08-08 |
| WSL | Platform | 🟢 Use | Current | Linux environment on Windows | Windows | https://learn.microsoft.com/windows/wsl/ | Primary execution environment and repository location. | 2026-08-08 |
| Git | Platform | 🟢 Use | Current | Version control | Windows; Linux; WSL | https://git-scm.com/ | Portable source-of-truth and branch boundary for the workflow. | 2026-08-08 |
| GitHub | Platform | 🟢 Use | Current | Repository, issue, PR, and policy platform | Cloud | https://github.com/ | Shared coordination, review, branch-policy, and CI source of truth. | 2026-08-08 |
| VPS | Infrastructure | 🟠 Hold | Future | Always-on worker host | Linux |  | Future migration target after the local workflow is stable. | 2026-08-08 |
| Tailscale | Infrastructure | 🟠 Hold | Current | Private remote network | Windows; Linux; Mobile | https://tailscale.com/ | Optional private administrative access for the future remote worker. | 2026-08-08 |
| OpenSSH | Infrastructure | 🟠 Hold | Current | Remote administration | Windows; Linux | https://www.openssh.com/ | Potential private administrative path through Tailscale. | 2026-08-08 |
| GitHub CLI | Utility | 🟢 Use | Current | GitHub command line | Linux; WSL | https://cli.github.com/ | Authentication and repository, issue, branch, PR, and policy operations. | 2026-08-08 |
| build-essential | Utility | 🔵 Selected | Ubuntu package | Compiler tool bundle | Ubuntu | https://packages.ubuntu.com/ | WSL and VPS prerequisite package. | 2026-08-08 |
| ca-certificates | Utility | 🔵 Selected | Ubuntu package | Certificate trust store | Ubuntu | https://packages.ubuntu.com/ | WSL and VPS prerequisite package. | 2026-08-08 |
| curl | Utility | 🔵 Selected | Ubuntu package | HTTP command line | Ubuntu | https://curl.se/ | Used for prerequisite installation and scripted downloads. | 2026-08-08 |
| jq | Utility | 🔵 Selected | Ubuntu package | JSON command line | Ubuntu | https://jqlang.org/ | Used for inspecting and transforming command-line JSON. | 2026-08-08 |
| unzip | Utility | 🔵 Selected | Ubuntu package | Archive extraction | Ubuntu | https://infozip.sourceforge.net/UnZip.html | WSL and VPS prerequisite utility. | 2026-08-08 |
| Svelte | Framework | 🔴 Rejected | Current | UI framework | Web | https://svelte.dev/ | Explicitly excluded until the workflow itself is proven. | 2026-08-08 |
| SvelteKit | Framework | 🔴 Rejected | Current | Application framework | Web | https://svelte.dev/docs/kit/ | Explicitly excluded from the framework-free lab; considered only when adapting a real project. | 2026-08-08 |
| React | Framework | 🔴 Rejected | Current | UI library | Web | https://react.dev/ | Explicitly excluded until the workflow itself is proven. | 2026-08-08 |
| Tailwind CSS | Framework | 🔴 Rejected | Current | CSS framework | Web | https://tailwindcss.com/ | Explicitly excluded until the workflow itself is proven. | 2026-08-08 |
| Storybook | Framework | 🔴 Rejected | Current | Component workshop | Web | https://storybook.js.org/ | Explicitly excluded until the workflow itself is proven. | 2026-08-08 |
| Photoshop | Design | 🟢 Use | Current | Design source editing | Windows | https://www.adobe.com/products/photoshop.html | Kept on the Windows side with design-source files. | 2026-08-08 |
| Discord | Communication | 🔵 Selected | Current | Remote command surface | Windows; Mobile | https://discord.com/ | Selected interface for the bounded Hermes remote-control experiment. | 2026-08-08 |
| ACP | Protocol | ⚪ Watch | Current | Agent Client Protocol | Agent clients; IDEs | https://agentclientprotocol.com/ | Relevant to Zed, Pi integration, and portable agent-client interoperability. | 2026-08-08 |
