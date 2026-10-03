# Manual Matt Pocock skill setup in VS Code and Ubuntu

Planning walkthrough, sources checked 2026-09-12. Justin chose VS Code. Open the existing `/home/justin/dev/ai-workflow` folder through VS Code's WSL connection, then run Ubuntu Codex CLI in its integrated terminal. This keeps the Windows app available for voice, browser, and desktop work. No installer, configuration change, or skill setup was executed for this document.

## Before the walkthrough

The comparison task owns the Ubuntu CLI diagnostic. Use its outcome before checking prerequisites again. This document does not establish the installed Ubuntu CLI, authentication, runtime, or skill discovery. A denied diagnostic has no established cause. The separate [VS Code repair](research/2026-09-12/vscode-ubuntu-v2-repair-2026-09-12.md) verified the Ubuntu-26.04 connection, existing lowercase `v2` profile, and remote extension host. Opening the folder through WSL proves neither CLI readiness nor Android Remote attachment.

Microsoft requires Windows VS Code, WSL with the chosen distribution, and the WSL extension. The extension may fetch VS Code Server when first connecting. Once a folder is open in WSL, **Terminal > New Terminal** starts a WSL terminal. VS Code supplies the editor and terminal; `codex` is the coding agent running there. The Codex IDE extension is a separate optional interface and is unnecessary for this CLI walkthrough. [Microsoft WSL guide](https://code.visualstudio.com/docs/remote/wsl), [Codex CLI](https://learn.chatgpt.com/docs/codex/cli).

The existing [README](../README.md) selects Vite+ to manage the Ubuntu JavaScript environment. Retain that choice. Vite+ documents managed `node`, `npm`, and `npx` shims, so Matt's `npx` spelling does not require adding NVM or another runtime manager. The inspected Skills CLI source declares Node `>=22.20.0`; its source version is `1.5.26`, which is not proof of the npm `latest` version. Missing prerequisites are a separate manual setup decision. [Vite+ environment](https://www.viteplus.dev/guide/env), [Skills CLI package manifest](https://github.com/vercel-labs/skills/blob/d667282815248da03a08a18272b5d2eef9caf77c/package.json).

## Manual sequence

1. Open the desktop shortcut **AI Workflow - Ubuntu v2**. The [repair task](research/2026-09-12/vscode-ubuntu-v2-repair-2026-09-12.md) verified its direct WSL launch and existing lowercase `v2` profile. Confirm the window shows `ai-workflow [WSL: Ubuntu-26.04] - v2`, then open **Terminal > New Terminal**. The manual fallback is **F1 > WSL: Connect to WSL using Distro > Ubuntu-26.04**, then **File > Open Folder > /home/justin/dev/ai-workflow** and selection of the existing `v2` profile. Avoid the old UNC recent-folder entry, which can choose Windows Default. [Microsoft WSL guide](https://code.visualstudio.com/docs/remote/wsl).

2. Reuse the comparison task's diagnostic results. Before any installation, record this folder's existing dirty and untracked files and inspect existing skill names and target paths. Once the Ubuntu CLI prerequisite is confirmed, launch `codex` from this project directory and use its `/skills` selector to establish existing discovery. Close that session before running the installer in the shell. Windows-installed skills do not establish Ubuntu availability. Current OpenAI docs list repository `.agents/skills` and user `~/.agents/skills` locations, support symlinks, and say duplicate names are not merged. Treat this as documented behavior to verify against the installed CLI. Preserve every pre-existing skill and local adaptation. [OpenAI skill discovery](https://learn.chatgpt.com/docs/build-skills).

3. Review the incoming skill names and source before installing. Matt's current documented command is:

   ```bash
   npx skills@latest add mattpocock/skills
   ```

   His README says to choose the desired skills and agents and include `setup-matt-pocock-skills`. It then says to run `/setup-matt-pocock-skills` once per repository. That is Matt's published sequence. [Matt's README at the inspected commit](https://github.com/mattpocock/skills/blob/3cca18b368ae95cdbdebbff572ccafa662551015/README.md).

   The Skills CLI supports adding `--list` to inspect available names without installing skills. It still downloads and executes CLI tooling. Default installation scope is the project; `--global` selects the user scope, and interactive installation offers symlinks or copies. Review those destinations before confirming. Avoid bulk selection, unattended confirmation, and broad updates during this experiment. [Skills CLI documentation](https://github.com/vercel-labs/skills/blob/d667282815248da03a08a18272b5d2eef9caf77c/README.md).

   Project adaptation, still requiring Justin's choice: keep reusable procedures in the Ubuntu user skill collection and repository-specific configuration here. Compare collisions before choosing the scope or skill set. A same-name collision is a stop point, not permission to overwrite. `@latest` is a moving target; record the CLI version and upstream revision actually selected during the eventual run. The source revisions cited here are research evidence, not an installer pin.

4. After Justin completes the selected installation, launch `codex` from this Ubuntu project directory. Follow its sign-in flow if needed. Use `/skills` to confirm the intended setup skill appears once at the expected path. OpenAI documents `$` mentions for Codex, so enter:

   ```text
   $setup-matt-pocock-skills
   Explore this existing repository and show the proposed setup. Preserve dirty
   files and existing instructions. Stop with the draft before writing files.
   ```

   Matt's slash-command spelling and Codex's `$` invocation refer to the same skill. If discovery fails, stop and inspect the installed location and CLI behavior. OpenAI says changes are detected automatically and restarting Codex may help if a skill does not appear. [Codex CLI](https://learn.chatgpt.com/docs/codex/cli), [OpenAI skill invocation](https://learn.chatgpt.com/docs/build-skills).

5. Review the setup draft. Current source discovers the repository, proposes its issue tracker, and defaults to one `CONTEXT.md` plus `docs/adr/`. It asks about triage labels only when `triage` is installed. It drafts `docs/agents/issue-tracker.md`, `docs/agents/domain.md`, and conditionally `docs/agents/triage-labels.md`. It edits existing `CLAUDE.md` preferentially, otherwise existing `AGENTS.md`, and requires review before writing. Check the actual files at that time. [Setup skill source](https://github.com/mattpocock/skills/blob/3cca18b368ae95cdbdebbff572ccafa662551015/skills/engineering/setup-matt-pocock-skills/SKILL.md).

   Proposed local answers: preserve the lab's GitHub Issues direction if the current remote supports it, keep Trello as the personal task system, and retain the documentation layout already established here. These are recommendations for Justin's setup answers. This planning task has not authorized or performed the setup writes. Do not create tracker labels, issues, hooks, or unrelated agent rules as incidental setup.

6. After separately approving and completing that setup, review the diff and newly created files against the recorded starting state. Accept the experiment when the Ubuntu CLI discovers the intended skill, uses this repository's configuration, and leaves existing skills and unrelated work intact. Remove only experiment-created files or explicitly restore experiment edits if abandoning the pilot; never reset the whole working tree. Keep installation, discovery, and setup outcomes as separate observations.

This tests reusable engineering procedures. It does not adopt gbrain, configure personal memory, synchronize machines, or connect an arbitrary CLI session to Android Remote.

First manual action: open the desktop shortcut **AI Workflow - Ubuntu v2**.
