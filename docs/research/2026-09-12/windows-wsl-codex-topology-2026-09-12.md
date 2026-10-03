# Windows app and Linux-first Codex development

September 12, 2026. Focused follow-up to the context and memory architecture audit.

**Recommendation:** use Ubuntu-native Codex CLI for sustained work on the existing `/home/justin/dev` repositories, and retain the Windows-native app for voice, browser and Windows-specific work. Keep one checkout. This is an execution split, not a reason to move the project or install a shared-memory service.

This recommendation fits Justin's stated priority: Linux-native project files/builds plus Windows integration. It is not a measured performance result. Existing CLI installation, its effective configuration and its permissions still need verification.

## What the settings and warning mean

The Windows user config was read again and shows `runCodexInWindowsSubsystemForLinux=false` and `integratedTerminalShell="wsl"`. These settings control different things. OpenAI documents the native agent as running commands through PowerShell; the selected terminal is separate. It also documents WSL-project access through the `wsl` CLI. Terminal actions and agent setup scripts can therefore execute in different environments. [Windows app documentation](https://learn.chatgpt.com/docs/windows/windows-app)

Justin's screenshot shows the Trident Edit project dialog with this exact warning:

> ChatGPT may be slower here
>
> Files on network or cloud drives can take longer to read and save

The screenshot does not expose the source folder's full path. Justin supplied the path as `\\wsl.localhost\Ubuntu-26.04\home\justin\dev\trident`. That UNC address exposes Linux files to Windows; it does not make a Windows process execute in Ubuntu. The warning is consistent with crossing that filesystem boundary. It does not establish that the files are in a remote cloud, that the repository is damaged, or how much slower this project actually runs. [Microsoft interoperability](https://learn.microsoft.com/en-us/windows/dev-environment/wsl-interop)

| Boundary | Current meaning | Consequence |
|---|---|---|
| Agent host | Windows native | Agent-side file and process operations originate on Windows |
| Integrated terminal | WSL selected | Interactive commands can run in Ubuntu; this does not relocate the agent |
| Repository storage | Linux home, exposed through UNC | Windows file operations cross the bridge; Linux processes can access `/home/...` directly |

Selecting WSL for the terminal alone therefore does not remove the Windows agent's file-reading overhead. Explicitly launching Linux builds fixes where those builds execute, but Windows-side searches, editing and app Git/review operations can still encounter the boundary.

## Practical choices

| Arrangement | Strength | Limitation / decision |
|---|---|---|
| Windows app agent plus explicit `wsl.exe` commands | Preserves the present Windows workflow and one Linux checkout | Useful for occasional mixed tasks; Windows file operations still use the bridge. Currently blocked from WSL in this task. |
| Ubuntu Codex CLI plus Windows app for Windows work | Agent, Git, dependencies and files can all be Linux-local | Preferred for sustained coding. Client-specific state and GUI capabilities remain separate. |
| Desktop app agent switched to WSL | Linux agent execution is a documented option | Requires a settings change/restart; Windows GUI integration in that mode is not established here. Not needed for the first trial. |
| Windows-native agent plus repository on Windows | OpenAI's documented reliability preference for that agent | Conflicts with the Linux-first goal; Linux builds through `/mnt/c` can incur the opposite filesystem crossing. No move recommended. |
| Desktop connected to a Linux SSH host | Documented remote filesystem/shell execution | Adds connection setup. Using local Ubuntu this way is not verified here; unnecessary for an initial CLI trial. |

OpenAI's Windows preference and Microsoft's Linux-filesystem recommendation optimize different execution environments. Microsoft recommends placing Linux-tool projects in the Linux filesystem, and specifically keeping Node.js and project files on the same operating system. With Ubuntu CLI, both the agent's file work and build tools can stay there. [Microsoft filesystem guidance](https://learn.microsoft.com/en-us/windows/wsl/filesystems), [Node.js on WSL](https://learn.microsoft.com/en-us/windows/dev-environment/javascript/nodejs-on-wsl), [Codex WSL guide](https://learn.chatgpt.com/docs/windows/wsl)

For mixed tasks, the supported command pattern is `wsl.exe -d Ubuntu-26.04 --cd /home/justin/dev/trident -- <Linux command>`. Verify that Git, Node and the package manager resolve to Linux executables rather than Windows programs inherited through PATH. Avoid Windows package managers operating on the UNC checkout. This pattern is a recommendation; it did not successfully run in this task. [Command interoperability](https://learn.microsoft.com/en-us/windows/wsl/filesystems#run-linux-tools-from-a-windows-command-line)

A Windows browser can normally open a WSL2 development server through `localhost:<port>` under documented networking defaults. Actual forwarding, firewall and server binding still matter. That provides a useful division: Ubuntu builds/serves; Windows previews. WSLg's ability to display Linux GUI apps does not demonstrate Windows GUI automation from a Linux Codex agent. Current Windows browser/native-app capabilities must be checked in the chosen client. [Microsoft networking](https://learn.microsoft.com/en-us/windows/wsl/networking), [WSLg](https://learn.microsoft.com/en-us/windows/wsl/tutorials/gui-apps), [OpenAI Computer Use](https://learn.chatgpt.com/docs/computer-use)

## What carries across, and what does not

The same checkout provides the same code and repository-scoped instructions to either client when accessible. Repo `.agents/skills` can travel with that checkout; Windows-global skills do not automatically become Ubuntu-global skills. A handoff should identify the project, goal, decisions, files and outstanding checks. Only one agent should edit the shared working tree at a time. [Instruction discovery](https://learn.chatgpt.com/docs/agent-configuration/agents-md), [Skill discovery](https://learn.chatgpt.com/docs/build-skills)

Windows uses `%USERPROFILE%\.codex`; an independently launched WSL CLI normally uses its Linux home. Configuration, authentication and session history are not automatically shared. A `CODEX_HOME` override can change that, so inspect the effective path before assuming separation or synchronization. Do not merge or synchronize those directories merely to make the repository accessible. [Windows/WSL state locations](https://learn.chatgpt.com/docs/windows/windows-app)

Codex memory is stored beneath its effective home. Running `wsl.exe git ...` does not start another Codex agent or switch the parent task's memories. Launching Linux `codex` creates a separate agent execution context whose actual memory settings must be checked. Windows memory being enabled says nothing about the current Ubuntu configuration. [Memory documentation](https://learn.chatgpt.com/docs/customization/memories)

Android Remote pairs with a supported desktop host; setup is not available directly from CLI/IDE. The desktop app documents SSH-host projects and handoff between matching saved projects, but this does not establish automatic attachment to an arbitrary existing Ubuntu CLI session. Do not promise the new CLI task will appear on the phone. Manual source-linked handoff is the initial assumption; verify app-managed SSH separately only if unified task/Remote access becomes necessary. [Remote and SSH](https://learn.chatgpt.com/docs/remote-connections)

## The access denial is a separate unresolved issue

Two read-only checks from this agent failed:

- `wsl.exe --list --verbose` returned `Wsl/EnumerateDistros/Service/E_ACCESSDENIED`.
- A metadata read of the supplied Trident UNC path returned access denied.

The earlier config-read attempt failed with `Wsl/Service/E_ACCESSDENIED`. Since distribution enumeration fails without reading any config, the evidence does not point specifically to malformed or unreadable `config.toml`. It also does not establish the cause: agent permissions, Windows policy, service access and other execution-context differences have not been isolated. The screenshot's generic performance warning is not proof of a connection to this denial. No security controls were changed or bypassed.

## Narrow next test

In an already working Ubuntu terminal, run these read-only identity checks:

```bash
cd /home/justin/dev/trident
uname -s
pwd -P
type -a codex git node pnpm
printf 'Codex home: %s\n' "${CODEX_HOME:-$HOME/.codex}"
```

Then, if `codex` resolves to an installed Linux CLI, start one read-only task asking it to identify the repository instructions, effective host/home, and an existing test command without editing files or installing dependencies. This checks topology before any benchmark or migration. No such task was launched during this research.

To isolate the denial separately, compare `wsl.exe --list --verbose` in ordinary PowerShell against the failed agent result. If ordinary PowerShell succeeds, that narrows the problem to the agent execution context; it still does not identify the exact blocking control. Do not infer that broader privileges or a restart are the right fix. [Microsoft WSL commands](https://learn.microsoft.com/en-us/windows/wsl/basic-commands)

Only this standalone report was added. No repositories, app settings, installs, credentials, memories or running services were changed; no build benchmark or restart was performed.
