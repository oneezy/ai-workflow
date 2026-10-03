#!/usr/bin/env bash
cd /home/justin || exit 1
printf 'USER=%s HOME=%s SHELL=%s\nPATH=%s\n' "$USER" "$HOME" "$SHELL" "$PATH"
for tool in vp node npm pnpm nvm codex git gh copilot code python3 uv bun deno rg docker cargo go; do
  printf '\nTOOL %s\n' "$tool"
  type -a "$tool" 2>/dev/null || true
done
for tool in vp node npm pnpm codex git gh python3 bun; do
  printf '\nVERSION %s\n' "$tool"
  command "$tool" --version 2>&1 | head -20
done
printf '\nLOCAL CODEX\n'
if [ -x "$HOME/.local/bin/codex" ]; then "$HOME/.local/bin/codex" --version; fi
printf '\nMANAGED VERSIONS\n'
"$HOME/.vite-plus/bin/vp" env list 2>&1
printf '\nUSER BIN ENTRIES\n'
find "$HOME/.local/bin" -maxdepth 1 -printf '%f -> %l\n'
printf '\nSTARTUP TOOL REFERENCES\n'
grep -nE 'vite|nvm|PATH|bashrc|local/bin|pnpm|bun|codex|corepack' "$HOME/.bashrc" "$HOME/.profile" "$HOME/.bash_profile" 2>/dev/null