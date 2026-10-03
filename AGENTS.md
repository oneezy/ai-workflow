# AGENTS.md

## Agent skills

Skills are not committed here. They come from the skills library `oneezy/skills`, linked into the harness user folders by `npx @oneezy/skills-sync` (source: `oneezy/tools`, `packages/skills-sync`).

A cloud session (`CLAUDE_CODE_REMOTE=true`) starts without them unless the cloud environment's setup script runs the sync. If `/grilling`, `/oneezy-brain` or another library skill is not in your skill list, run this first, then carry on:

```
npx --yes @oneezy/skills-sync -y --agents claude-code --global --no-projects --no-wsl --quiet
```

Claude Code lists the new skills about a minute later; until then, Read the SKILL.md.

A message that starts with `/<name>` runs that skill, even in a project thread, where it reaches you as plain text rather than a command. If the skill is in your list, invoke it. If it is not, which is always the case for skills marked `disable-model-invocation` (`/wayfinder`, `/grill-me`, `/to-tickets`, `/oneezy-merge` and others), Read `~/.claude/skills/<name>/SKILL.md` and follow it, with the rest of the message as its arguments.
