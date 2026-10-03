# Windows development bootstrap

This is a reviewed proposal and safely tested pilot installer. Nothing has been installed with it. Justin selected PowerShell 7 with the existing Oh My Posh customization. The script does not change the default shell. Run it from a reviewed local Windows copy, using native PowerShell 7.4 or newer. The repository's UNC path is blocked by the current unsigned-script policy.

The target setup removes Windows NVM after the replacement passes the pilot. This script performs the earlier isolated replacement stage. The [transition report](../../docs/research/2026-09-14/windows-native-development.md) covers retained global tools, supported NVM uninstall, and final PATH cleanup. Do not use this script as evidence that those later steps are complete.

## Commands

From PowerShell, Git Bash, or Nushell, invoke the same PowerShell runtime:

    pwsh -NoProfile -File ./bootstrap.ps1 -Mode Audit
    pwsh -NoProfile -File ./bootstrap.ps1 -Mode Plan -PlanFile ./pilot-plan.json
    pwsh -NoProfile -File ./bootstrap.ps1 -Mode Install

Audit prints current resolution and protected-setting hashes without invoking package shims. Plan writes a new JSON file and prints its SHA-256. Install without Apply is a dry run and writes nothing.

After reviewing the exact plan, supply the printed hash explicitly:

    pwsh -NoProfile -File ./bootstrap.ps1 -Mode Install -PlanFile ./pilot-plan.json -Apply -ApprovedPlanSha256 <reviewed-sha256>

The default installation root is %LOCALAPPDATA%\JustinDevToolchain. The release directory includes every pinned version. A custom Root must be an absolute dedicated local Windows path, with no junction/symlink ancestors. Supply the same Root to all commands.

    pwsh -NoProfile -File ./bootstrap.ps1 -Mode Verify
    pwsh -NoProfile -File ./bootstrap.ps1 -Mode Enter -ShellPath 'C:\Program Files\PowerShell\7\pwsh.exe'

For another everyday shell, give its explicit native .exe path. Git Bash is normally C:\Program Files\Git\bin\bash.exe. Nushell's actual path must be verified after a separately approved installation. Launching a child shell does not change Windows Terminal, VS Code, or Codex's default shell.

Enter prepends the release bins to the child process PATH and sets that child's VP_HOME. It deduplicates paths without changing either persisted PATH scope. Shell startup files can still override PATH. Verify Get-Command/which in the resulting shell before using it. Existing .npmrc still points global npm installations at NVM, so do not install global npm packages from the pilot shell before the reviewed prefix cleanup.

## Update and recovery

Edit versions.json only after checking current publisher metadata and compatibility. Record exact release versions and fresh publisher integrity values. Create a new plan and review it, then use Mode Update with Apply and the reviewed hash. It uses the same safe acquisition path as Install.

Updating any version creates a new release directory. Existing successful releases are retained. A Vite+ version other than 0.3.2 is refused until its self-install behavior and no-PATH-change option are reviewed. No scheduled updater is created.

Keep the old manifest with its release receipt. For rollback before permanent cutover, close the child shell or run Enter using the previous manifest. The installer does not overwrite the existing NVM setup. After final NVM retirement, use a prior verified Vite+ release for routine rollback; NVM recovery metadata is for exceptional recovery, not parallel active ownership.

A failed install leaves its directory and started.json for diagnosis. A repeat refuses to overwrite it. Inspect the failure and plan a new dedicated root, or review exact scoped cleanup after confirming no user files were added. There is no recursive automatic delete and no automatic package uninstall.

## Integrity and boundaries

- Exact Vite+ npm platform tarball and Codex complete native release archive.
- SHA-512 npm integrity and GitHub-published SHA-256 pinned in versions.json.
- No downloaded text is piped to Invoke-Expression.
- Traversal, absolute archive paths, and archive links are rejected before extraction.
- Vite+ downloads its own runtime/dependencies using its built-in verification. This is not a full transitive supply-chain lock.
- Child install environment excludes inherited credentials, node options, custom npm prefix, and custom registries. Proxy/private-registry requirements need a separate reviewed change.
- The bootstrap never changes execution policy or Defender settings.
- Plan hashes bind script, manifest, destination, and the protected settings snapshot.
- Receipts hash managed executables and selected configuration. Local changes stop repeat installs.
- Audit/Plan/dry run do not run downloaded executables. Verify runs only an installed release with a matching receipt.
- NVM, old npm packages, VS Code settings, auth, global model/reasoning defaults, project files, and persistent PATH remain outside this script's write operations.
- Existing Git/gh/Copilot/VS Code keep their current installation owners. Later selected updates use their official native installers or exact WinGet IDs/versions, not winget upgrade --all.
- Network access is required only for approved installation. The isolated install does not require an administrator. Final NVM uninstall and Machine PATH changes may require elevation.
- First-run Codex/Copilot/GitHub authentication stays interactive. Never copy Linux credentials, sessions, caches, or node_modules.
- Logs contain action status, manifest hashes, and receipts. Full child stdout/stderr is not saved.

## Tests and inventory

    pwsh -NoProfile -File ./Test-bootstrap.ps1
    pwsh -NoProfile -File ./inventory-globals.ps1 -OutputFile ./globals.json

Tests use temporary local directories and mocked installation boundaries. The real tar safety and digest functions are exercised before the mocks replace network/process/extraction calls. Mock artifacts remain in the printed temporary directory for inspection. They are not installed tools.

The global inventory records each NVM version, package names and versions, shim names, pnpm global declarations, Corepack directories, and executable resolution. It refuses to overwrite an export. It reads no credential contents. Package presence does not establish active use.

The Ubuntu discovery helper is read-only, but version queries through a package-manager shim may consult managed caches. Invoke from Ubuntu home with an interactive Bash; login versus non-login PATH differs here.

## Pilot acceptance

Use the selected PowerShell 7 shell and the created empty pilot parent V:\dev-pilot. The current pilot plan uses -Root 'V:\dev-pilot\.toolchain'; supply that exact Root to Install, Update, Verify, and Enter. Then approve the concrete generated install plan. Use a synthetic project before client source. Require correct executable paths for Git and retained CLIs in fresh PowerShell sessions, local v2 selection, native Codex extension, existing Oh My Posh prompt rendering, Node/pnpm versions, package install, representative tests/build, and hot reload. Include a normal profile-loaded PowerShell session to catch startup PATH overrides. The current mock results cannot establish these Windows integration behaviors.

After that, review and execute the separate NVM retirement and persistent activation plan. Each client repo upgrade/migration remains a separate scoped operation with dirty work preserved.
