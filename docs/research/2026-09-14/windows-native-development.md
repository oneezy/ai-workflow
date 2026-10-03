# Native Windows development inventory and transition plan

September 14, 2026, America/Chicago. Discovery continued after midnight UTC. No installation, uninstall, persistent PATH edit, default-shell change, credential copy, repository migration, or project upgrade was performed. New artifacts live under scripts/windows-dev and this report. Existing dirty repository files remain intact.

## Recommendation

Use Vite+ as the sole Windows Node and package-manager owner. Remove Windows NVM after its replacement and required global CLIs pass the pilot. Keep Ubuntu intact as an optional environment. Standardize actively maintained projects on a deliberately recorded stable pnpm version, with reviewed per-project lockfile/config updates.

Use the existing Windows Git, GitHub CLI, Copilot CLI, VS Code v2, and prompt tools. They do not need replacement merely to move routine development to Windows. Justin selected PowerShell 7 as the everyday shell. Preserve the existing Oh My Posh customization. The bootstrap also uses PowerShell 7, without changing default-shell settings during the pilot.

The proposed baseline, verified against publisher metadata today:

| Component | Recorded target | Owner |
|---|---|---|
| Vite+ global CLI | 0.3.2 | Private Windows Vite+ installation |
| Node | 24.21.0 LTS | Vite+ |
| pnpm | 12.4.1 | Vite+; project pins converge after reviewed upgrades |
| npm | 11.19.0 | Vite+; aligned with the Node 24.21.0 distribution |
| Codex standalone CLI | 0.154.0 | Complete official native release package, independent of npm |
| Git, gh, Copilot | Keep observed installations for the pilot | Existing native installations; selected WinGet updates later |
| VS Code and extensions | Existing v2; add native Codex after version review | VS Code and its extension manager |
| Oh My Posh and zoxide | Preserve current installation and customizations | Existing Windows installs |

These are explicit versions, not moving latest tags during every run. Node 24 meets dental's 24.x requirement and AI Workflow site's >=22.13.0 requirement. Trident's root declares no Node engine; that is not proof all its dependencies support a new runtime. The proposed Node also satisfies Vite+ 0.3.2's published engine requirement. [Node release index](https://nodejs.org/dist/index.json), [Vite+ metadata](https://registry.npmjs.org/vite-plus/0.3.2), [pnpm metadata](https://registry.npmjs.org/pnpm/12.4.1).

Vite+ supports Windows x64 and managed Node/package-manager selection. Its global CLI does not require migrating every repository onto the project-local vite-plus package. Do not run vp migrate as part of moving machines. [Vite+ getting started](https://viteplus.dev/guide/), [environment management](https://viteplus.dev/guide/env).

## Shell decision

Justin selected PowerShell 7 after reviewing the comparison below. Other shells can be considered later. This resolves shell selection only; it does not approve installation, NVM removal, PATH changes, or editor settings.

| Shell | Windows / Linux / macOS | Bash scripts | Native tools and Codex | Effort here |
|---|---|---|---|---|
| PowerShell 7 | All three | Call Bash explicitly | Direct Windows APIs and executables. Official Codex docs describe native PowerShell execution | Already 7.6.6 with a customized profile |
| Git Bash | Windows distribution; Bash on Linux/macOS | Strongest compatibility, subject to available Unix commands and Windows path semantics | Runs Windows executables. Its launch shell does not establish Codex's internal execution shell | Already installed; v2 currently selects it |
| Nushell | All three | Its language is distinct; call Bash explicitly | Runs native executables and offers structured pipelines. Codex agent-shell support was not established by reviewed docs | Not found on PATH; new setup and language |
| Ubuntu Bash | Existing WSL environment | Linux behavior | Retains Linux execution and paths | Available, but does not meet the preferred routine Windows-native workflow |

Use PowerShell 7 with the existing Oh My Posh customization. Git for Windows supplies the native git.exe used from PowerShell. Its bundled Git Bash remains available for scripts that require Bash; it does not need to be the interactive shell. The pilot must verify git, gh, copilot, vp, node, npm, pnpm, and codex by executable path and version in fresh PowerShell sessions, including a normal session with the existing profile loaded.

Oh My Posh is a prompt renderer, not a shell. It supports PowerShell, Bash, and Nushell. The bootstrap runs with pwsh -NoProfile -File and does not select any of them as default. Enter mode launches only the explicit native shell executable supplied by the user. [PowerShell overview](https://learn.microsoft.com/en-us/powershell/scripting/overview), [Git for Windows](https://gitforwindows.org/), [Nushell installation](https://www.nushell.sh/book/installation.html), [Bash-to-Nushell differences](https://www.nushell.sh/book/coming_from_bash.html), [Oh My Posh](https://ohmyposh.dev/docs/installation/prompt), [Codex Windows support](https://learn.chatgpt.com/docs/windows/windows-sandbox).

## Live tool inventory

Read-only executable resolution, installed manifests, selected registry metadata, and direct version commands supplied these observations. A name on disk does not prove current use. No shell history was searched.

| Tool | Ubuntu | Windows | Interpretation |
|---|---|---|---|
| Vite+ | ~/.vite-plus/bin/vp 0.3.1; old 0.2.8 directory retained | No vp on inspected PATH | Native install needed |
| Node | Vite+ default 24.18.0; cached 24.19.0, 24.21.0 | NVM active 24.4.0 | Cache versions are not separate active requirements |
| npm | 11.16.0 from current Node fallback; standalone npm 12.0.2 cached | Active NVM npm 11.4.2; roaming duplicate | Remove duplicate ownership during reviewed cutover |
| pnpm | 12.4.1 outside projects; cached 10.33.0, 11.20.0 | NVM 10.16.0; roaming 10.0.0 | Project selections differ from global default |
| NVM | No Linux nvm found in inspected Bash | 1.2.2; Node 22.17.0, 23.10.0, 24.4.0 | Windows removal is required target state |
| Codex CLI | ~/.local/bin/codex 0.154.0; login Bash resolves it | Roaming npm 0.1.2505172129 wins before app-provided executable | Install standalone and retire old npm shim after verification |
| Git | /usr/bin/git 2.53.0, dpkg-owned | C:\Program Files\Git\cmd\git.exe 2.47.1.windows.1 | Keep native Windows Git; do not add UNC trust exceptions |
| GitHub CLI | /usr/bin/gh 2.97.0, dpkg-owned | C:\Program Files\GitHub CLI\gh.exe 2.96.0 | Already native |
| Copilot CLI | Not found by that command name | WinGet Links/copilot.exe 1.0.65 | Independent of NVM; keep |
| VS Code | Windows launcher plus Linux remote extension host | User install 1.137.0; Insiders 1.138.0 also installed | Existing v2 needs native extension verification |
| PowerShell | Not part of this Linux inventory | 7.6.6 | Existing bootstrap runtime |
| Oh My Posh | ~/.local/bin/oh-my-posh; Bash setup references custom theme | 24.17.1, user Programs installation | Preserve |
| zoxide / fzf / starship | ~/.local/bin entries; Bash config uses them conditionally | zoxide present; fzf/starship not found on inspected PATH | Convenience tools, not app build prerequisites |
| Python | 3.14.4 executable; dpkg python3 metapackage 3.14.3 | Default 3.12.8; 3.10.5 installed; Hermes venv also on PATH | Keep specialized ownership; do not migrate all Python packages |
| uv | Not found | Hermes-owned uv.exe | Do not make Hermes' runtime a global replacement |
| Bun | Vite+ shim 1.4.2 | Not found | No inspected active root requires it |
| Deno | Not found | 2.4.1 in ~/.deno/bin | Preserve for Deno projects; not automatically upgraded |
| ripgrep | No distro rg found | WinGet rg plus app-provided rg | No blanket OS package replication |
| Docker | Windows launcher on inherited PATH | Docker CLI 29.6.2, Desktop 4.84.0 | Server state and workload compatibility not tested |
| Build tools | dpkg build-essential 12.12ubuntu2.26.04.2, GCC 15.2, make 4.4.1 | VS 2022 BuildTools and CUDA paths present | Install additional components only if pilot demonstrates need |

Ubuntu non-login interactive Bash did not include ~/.local/bin, so it resolved the old Windows npm Codex shim through inherited Windows PATH. Login Bash includes ~/.local/bin via .profile and resolves native Codex 0.154.0. This explains differing command results without changing Ubuntu.

### Windows global package export

See [the complete export](../../../scripts/windows-dev/inventory-globals-2026-09-14.json) and [repeatable inventory script](../../../scripts/windows-dev/inventory-globals.ps1).

| Location | Packages |
|---|---|
| NVM v22.17.0 | corepack 0.33.0, npm 10.9.2 |
| NVM v23.10.0 | corepack 0.32.0, npm 10.9.2, vnow 0.33.3 |
| NVM v24.4.0 | @google/gemini-cli 0.1.15, corepack 0.34.0, npm 11.4.2, pnpm 10.16.0, vercel 48.0.0, vnow 0.38.0 |
| %APPDATA%\npm | @google/clasp 3.0.6-alpha, @google/gemini-cli 0.1.9, @openai/codex 0.1.2505172129, degit 2.8.4, madge 8.0.0, npm 11.4.2, plop 4.0.1, pnpm 10.0.0 |
| %LOCALAPPDATA%\pnpm\global\5 | Manifest requests turbo ^2.4.4 and vercel ^48.0.0; these are ranges, not verified installed versions |
| C:\Program Files\nodejs and x86 counterpart | Neither directory exists |

A separate Node.js 22.17.0 MSI registration remains, with product ID {974591B0-CB6E-49FA-8E9B-4A0463A3E1C0}. Its registered install location is empty. Do not infer an active standalone runtime or blindly delete its registration.

### Retained CLI ownership

| Tool | Evidence of need | Target owner / action |
|---|---|---|
| Codex | Explicit requirement; old shim conflict reproduced | Official complete native package, then remove only the old @openai/codex package/shims |
| gh | Explicit requirement, native installed | Keep native GitHub CLI; WinGet GitHub.cli for deliberately selected updates |
| Copilot | Explicit requirement, native installed | Keep WinGet GitHub.Copilot; no npm reinstall |
| Vercel | Present in multiple locations; relevant client workflow | Retain one explicitly versioned CLI through Vite+ global package installation or project-local tooling after review; do not keep duplicate owners |
| Turbo | Trident pins 2.8.3 locally | Prefer project-local executable; global need is unconfirmed |
| Gemini CLI | Two global versions | Usage unresolved; do not infer unused from age |
| clasp | Present; separate user config exists | Usage unresolved; retain if Google Apps Script work needs it |
| vnow | Two NVM versions | Usage unresolved; account for it before deleting NVM |
| degit, madge, plop | Present in roaming npm | Usage unresolved; project-local or explicit on-demand version if still needed |
| Corepack | Installed under every NVM Node | Vite+ replaces this role in the target model |
| npm / pnpm | Explicit requirement | Vite+ owns both; do not install additional global copies |

Vite+ documents global package commands, while its environment manager selects project package-manager versions. Review exact versions and retained tools before using global installs. Do not automate reinstallation of every exported package. [Vite+ package management](https://viteplus.dev/guide/install), [GitHub CLI installation](https://github.com/cli/cli#installation), [Copilot native installation](https://docs.github.com/en/copilot/how-tos/copilot-cli/set-up-copilot-cli/install-copilot-cli).

## PATH, startup, prompt, and editor

Windows node resolves through C:\nvm4w\nodejs, a symlink to %LOCALAPPDATA%\nvm\v24.4.0. NVM_HOME and NVM_SYMLINK are set at both User and Machine scopes.

Machine PATH includes NVM's root and symlink directory. User PATH includes roaming npm, pnpm, Corepack, Hermes, multiple editors, and other tools. Corepack's shim directory appears in both scopes. Codex adds its own tool/runtime paths to its process; do not persist those cache paths as system dependencies.

C:\Users\Justin\.npmrc contains prefix=C:/nvm4w/nodejs. This must be removed or replaced with the verified intended npm behavior during cutover, preserving any unrelated settings and auth. It remains unchanged today.

The PowerShell ConsoleHost profile is a customized Chris Titus Tech profile. It initializes Oh My Posh and zoxide only for an interactive console. It also contains update helpers. The bootstrap uses -NoProfile and does not trigger them. It looks for POSH_THEME or cobalt2.omp.json beside the profile or in the home directory. POSH_THEME was unset in this process, and neither candidate theme file existed. Oh My Posh is installed and initialization is configured; successful interactive theme rendering is not established by this audit.

MesloLGM Nerd Font v3.5.1 regular/bold/italic files are registered. VS Code Default settings name MesloLGM Nerd Font. No fonts or themes were reinstalled.

The existing v2 profile lives at %APPDATA%\Code\User\profiles\-4a0d1427. Its Windows terminal default is Git Bash. It lists 102 local extensions, including Svelte, Tailwind, ESLint, Prettier, PowerShell, and Copilot Chat. It does not list openai.chatgpt or Playwright. Ubuntu's remote extension directories include both. Cached remote directories do not prove active versions.

Add only the native extensions required for the pilot. Preserve v2's existing themes and settings. Verify the actual desktop folder/file Open actions select local v2; previous tests selected local Default. Profile association is a separate UI setting from executable installation. [VS Code profile associations](https://code.visualstudio.com/docs/configure/profiles).

## Project compatibility

| Project | Current declared requirement | Migration check |
|---|---|---|
| Advanced Family Dental | Node 24.x, .nvmrc 24, pnpm 11.20.0; .npmrc engine-strict=true | Move engine-strict to pnpm-workspace.yaml when adopting pnpm 12. Review lockfile, package scripts, native dependencies, and private package access |
| Trident | pnpm 9.15.4; root has no Node engine; local Turbo 2.8.3 | Review pnpm major-version config/build permissions and monorepo scripts, symlink tasks, and platform-specific helpers |
| AI Workflow site | Node >=22.13.0; package-lock.json; no packageManager pin | Deliberate npm-to-pnpm migration if selected; Unix inline WRANGLER_LOG_PATH assignments need portable scripts |

Justin's shared latest-stable pnpm plan removes differing pins as a permanent target-state requirement. Until each upgrade is reviewed, honor the existing declarations. pnpm 12 supports Windows and Node 24, but configuration changes still matter: non-auth/non-registry .npmrc settings move to pnpm-workspace.yaml. No repository files or lockfiles were modified. [pnpm compatibility](https://pnpm.io/installation), [pnpm 12 settings](https://pnpm.io/settings).

Prefer one runtime owner. Vite+ warns that pnpm can separately manage devEngines.runtime. Review a project-scoped runtimeOnFail policy during the pnpm migration; do not silently change a global setting that could also affect Bun or Deno. This inventory found no devEngines declaration in the inspected root manifests. [Vite+ runtime ownership](https://viteplus.dev/guide/env).

## Ordered transition and NVM removal

1. Use the selected PowerShell 7 shell and the new isolated pilot parent V:\dev-pilot. Justin authorized its creation; the directory was confirmed unused before creation and read back empty. V: is the verified fixed ReFS drive labeled Dev. B: was absent. The proposed toolchain root is V:\dev-pilot\.toolchain, with a future synthetic app at V:\dev-pilot\app. Existing V: projects remain untouched.
2. Preserve the global-package export, exact PATH/variable values, NVM installation metadata, and the reviewed uninstaller hash. Resolve whether Gemini, clasp, vnow, degit, madge, and plop are needed. Preserve their existing Windows config in place. Do not copy sessions or credentials between hosts.
3. Run the reviewed bootstrap in a new private Windows toolchain directory. Verify exact versions and complete Codex companion files. The first release is a pilot replacement; temporary pre-cutover NVM remains untouched only until its replacement is proven.
4. Install/verify retained global CLIs through their selected single owner. Verify required authentication interactively without printing tokens. Keep GitHub CLI and Copilot's existing native installation. Test Codex's existing Windows login normally; never copy Ubuntu auth.
5. Create a synthetic Windows pilot in the confirmed folder. Install fresh Windows dependencies. Test shell resolution, local v2, desktop-agent editing, extension behavior, hot reload, tests, build, and line endings. Do not copy Linux node_modules or caches.
6. After the pilot passes, review the exact final removal/PATH plan. Back up recoverable Windows NVM package metadata and any needed local custom files before deletion. Retain a verified official 1.2.2 installer for recovery if required, without leaving NVM active in the target setup.
7. Use the registered supported uninstaller at C:\Users\Justin\AppData\Local\nvm\unins000.exe. It removes NVM and its managed Node versions. Do not run nvm uninstall against each version before the dependency mapping and backup. The registered uninstaller is the preferred supported route. [NVM 1.x uninstall instructions](https://github.com/nvm-windows/nvm/wiki#uninstall).
8. Read back the result. Remove only confirmed residual NVM_HOME and NVM_SYMLINK values at both scopes and exact owned PATH entries for %LOCALAPPDATA%\nvm and C:\nvm4w\nodejs. Verify the symlink's target before any residual link cleanup. Do not recursively delete C:\nvm4w or a broad npm directory.
9. Remove the old npm prefix line with a file hash/conflict check and preserve unrelated .npmrc content. Retire only inventoried replaced npm/Corepack/Codex shims. Keep unrelated roaming npm tools until mapped. Resolve the separate Node MSI registration with its supported installer only if its remaining ownership is established.
10. Activate the approved Vite+ bin and standalone Codex bin through the chosen shell or a reviewed persistent PATH change. The final target has no active NVM manager. Back up both PATH scopes before changing them; deduplicate by normalized path while preserving unrelated entries and order.
11. Open fresh desktop, VS Code, and terminal processes. Verify node, npm, pnpm, vp, codex, gh, copilot, and git by both path and version. nvm should no longer resolve. Confirm normal commands no longer point at C:\nvm4w or old Codex npm files.
12. Upgrade and migrate each active repository separately, with its dirty work and local inputs preserved. Justin retains production release authority.

Discovery, script artifact preparation, shell selection, and creation of the empty pilot parent have been performed. The bootstrap intentionally automates isolated installation/update and verification. It does not execute final NVM retirement, permanent PATH activation, global-CLI migration, or repository upgrades. Those steps depend on the retained-tool decisions and successful pilot; this is an explicit execution boundary, not an optional NVM end state.

### Authentication and recovery

Existence-only checks found Windows .codex/auth.json, .gemini, .clasprc.json, and .copilot. No contents were displayed or copied. Absence of gh hosts.yml at two conventional paths does not prove logged-out state; credential-manager storage and overrides were not exhaustively inspected. NVM removal does not authorize deleting any of these locations. Verify each retained CLI after replacement.

For a failed pilot installation, leave its partial directory for inspection; do not retry over it. Close its child shell to restore the original process environment. No persisted PATH is changed by the bootstrap. A prior successful private release stays available for an update rollback by running Enter with its matching manifest. Do not copy mutable state across releases. Final NVM removal needs its own recovery package and scoped PATH/file backups before execution.

## Script and verification

See [bootstrap instructions](../../../scripts/windows-dev/README.md), [bootstrap.ps1](../../../scripts/windows-dev/bootstrap.ps1), [versions.json](../../../scripts/windows-dev/versions.json), and [mock tests](../../../scripts/windows-dev/Test-bootstrap.ps1).

The bootstrap checks exact official URLs and pinned artifact integrity before extraction or execution. It rejects unsafe tar members and links, unknown Vite+ versions, unsafe destinations, local changes to owned files, stale protected settings, and concurrent writes. Downloaded tools run with a small child environment that excludes inherited credentials and custom registries. It keeps Node signature verification enabled. It logs status and hashes, not full process output or secrets.

Vite+ 0.3.2 self-installs on first execution. Its release source includes VP_SELF_SETUP_NO_MODIFY_PATH; the script uses that flag plus a private VP_HOME and noninteractive mode. It stops on other Vite+ versions until this implementation behavior is reviewed again. Vite+ still downloads its own dependencies and runtimes through its official mechanisms. Top-level hashes do not constitute a complete transitive dependency lock. [Reviewed release implementation](https://github.com/voidzero-dev/vite-plus/blob/v0.3.2/crates/vp_global_cli/src/self_setup.rs), [official Windows platform package](https://registry.npmjs.org/@voidzero-dev/vite-plus-cli-win32-x64-msvc/0.3.2), [Codex release](https://github.com/openai/codex/releases/tag/rust-v0.154.0).

Final safe test run passed 29 checks, including parser validation, audit/dry-run non-execution, source/hash checks, tar traversal/link rejection, approval hash mismatch, stale-plan rejection, repeat-install idempotence, and local-change detection. Network/process calls in installation tests were mocks. No real installer or native development build has run. Integration and fresh-shell behavior remain pilot acceptance checks.

Windows refused unsigned repository scripts through the UNC path. Tests ran from a temporary local copy with pwsh -NoProfile, without changing execution policy. Use a reviewed local copy for the pilot too.

## Command permission diagnosis

This task's active managed permission profile is restricted/workspace-write. Saved Windows config.toml instead says sandbox_mode="danger-full-access" at line 7 and approval_policy="never" at line 15. The named effective approval policy is not exposed in this task, so the report does not infer it from the saved defaults.

Three default command launches failed before process creation with helper_unknown_error: setup refresh had errors. Even Get-Location failed. The agent therefore used require_escalated for read-only work, causing actual command approval dialogs. Artifact writes also needed that path after the sandbox writer failed. The underlying sandbox initialization cause is unproven.

Changing saved defaults again would not establish a fix for the active task override. Justin can review this task's Permissions selector or separately authorize sandbox repair/restart. No permission/security changes or broad prefix allowances were requested as a remedy. Command execution dialogs are separate from approval of the concrete installation/removal plan.

## Resolved pilot choices

PowerShell 7 is selected, with existing Oh My Posh customization preserved. The empty pilot parent is V:\dev-pilot. These choices authorize neither installation nor NVM removal. Retained-global CLI decisions apply before NVM retirement; they do not block the isolated pilot. The next execution gate is approval of the specific plan to install the pinned toolchain under V:\dev-pilot\.toolchain.
