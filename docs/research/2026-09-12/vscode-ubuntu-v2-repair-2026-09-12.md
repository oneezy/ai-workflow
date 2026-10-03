# VS Code Ubuntu launch and v2 extension repair

Verified September 12, 2026 in task `01a09778-e1e9-76d0-bbfb-92507c4d1c24`. Existing project directory is `/home/justin/dev/ai-workflow`, exposed to Windows at `\\wsl.localhost\Ubuntu-26.04\home\justin\dev\ai-workflow`.

## Result

Opened the existing folder directly in Ubuntu-26.04 with the existing lowercase `v2` profile. Created `C:/Users/Justin/Desktop/AI Workflow - Ubuntu v2.lnk` so Justin can repeat that route. Installed only the existing SVG-Viewer extension, `dheovani.svg-viewer@1.1.2`, in Ubuntu's v2 profile.

The shortcut targets the existing Windows VS Code executable with these arguments:

```text
--new-window --profile v2 --folder-uri vscode-remote://wsl+Ubuntu-26.04/home/justin/dev/ai-workflow
```

The matching CLI launch was verified; the saved shortcut's target, arguments, and working directory were read back. The shortcut deliberately opens a new window and preserves other sessions. Existing launch alternatives remain unchanged. Opening the old UNC recent-folder entry can still choose the Windows route.

## Evidence

| Check | Observed result |
|---|---|
| Client | Windows VS Code 1.137.0, commit `645f29cc3176500b4b5762ba887cf2a7f0ffdf2c` |
| Profile | `v2`, ID `-4a0d1427` |
| Folder associations before repair | The Windows UNC folder URI selected Default; the WSL folder URI selected v2. This makes the entry route significant. |
| Direct launch | Window title showed `ai-workflow [WSL: Ubuntu-26.04] - v2 - Visual Studio Code`; accessibility showed `Manage v2 (Profile)`. |
| Execution host | Supported `code --status` reported WSL Ubuntu-26.04, a Linux remote server, and a remote extension host. Remote logs showed ESLint, Prettier, and Rainbow CSV activation. |
| Existing extensions | Ubuntu v2 already contained 92 registered extensions with existing directories. The separate default remote registry had 18. Neither count alone indicates missing v2 extensions. |
| Actual installation candidates | VS Code's Install Local Extensions in WSL picker offered SVG-Viewer 1.1.2 and deprecated VSCode simpler Icons with Angular 1.6.14. Only SVG-Viewer was selected. |
| Installation readback | The UI reported success; Ubuntu v2 registered `/home/justin/.vscode-server/extensions/dheovani.svg-viewer-1.1.2`. Its status item appeared. Before/after registry comparison showed only that extension added. |
| Preservation | Hash comparisons confirmed unchanged Windows user settings, keybindings, and v2 settings. No existing window was closed, no repository code was edited, and no commit was made. |

Most differences between Windows and Ubuntu are expected UI extensions, themes, or remote connectors. Microsoft documents separate local and WSL extension hosts and states that Settings Sync does not synchronize extensions to or from remote windows. Use the actual active profile and VS Code's host-aware installation picker instead of copying extension directories. [WSL extensions](https://code.visualstudio.com/docs/remote/wsl#managing-extensions), [profiles and remote synchronization](https://code.visualstudio.com/docs/configure/profiles#synchronize-profiles-across-machines).

Microsoft documents both the WSL folder URI launch and the `--profile` option. A differently spelled, nonexistent profile name can create a new empty profile, so the launcher uses the observed lowercase name. [WSL launch](https://code.visualstudio.com/docs/remote/wsl#from-the-windows-command-prompt), [profile CLI](https://code.visualstudio.com/docs/configure/profiles#command-line).

## Remaining compatibility limits

Some installed extensions still produce compatibility messages in this VS Code version. These are distinct from absent extensions:

- Mermaid Chart and Live Share reference unavailable or restricted proposed APIs in renderer logs. No experimental API flags were enabled.
- `vscode-icons-team.vscode-icons` failed activation in the Windows extension host after attempting a `C:/home/justin/...` path for this Linux workspace. The current theme/settings were preserved.
- Bundled Copilot emitted a `navigator` migration error in the remote extension host. Copilot presence is not proof that all its features work.
- GitHub integration logged that the nested `site` folder has no GitHub remotes. No remote or repository setting was changed.

A broad extension upgrade was outside this repair. Authentication and every individual extension's behavior were not tested. The separate font task owns the Meslo warning; this repair changed no fonts. Ubuntu Codex CLI readiness and Matt's manual skill setup remain separate checks, and neither installer nor a broad toolchain inventory ran here.

## Backup and reversal

Pre-launch copies of Windows user settings, keybindings, v2 settings/extension registration, VS Code storage metadata, and Ubuntu v2 extension registration are under `C:/Users/Justin/AppData/Local/Codex/repair-backups/vscode-20260912-01a09778/`.

To reverse this repair, remove the new shortcut and uninstall SVG-Viewer specifically from WSL's v2 extension group. Keep the Windows installation. Do not restore whole profile/storage files over newer work merely to undo this extension addition.
