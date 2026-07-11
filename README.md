# Skills

Agent skills for Claude Code.

## Available skills

- **[gpt-claude](gpt-claude/SKILL.md)** — Set up the OpenAI Codex plugin inside Claude Code and run a Claude-as-orchestrator / Codex-as-executor workflow: Claude plans, decomposes, and reviews; Codex executes heavy implementation via `/codex:rescue`.

## Installation

One-liner, no clone needed:

```
curl -fsSL https://raw.githubusercontent.com/moeghashim/skills/main/install.sh | bash -s -- gpt-claude
```

Or from a clone:

```
./install.sh --list        # show available skills
./install.sh gpt-claude    # install one skill
./install.sh --all         # install every skill
```

Skills install to `~/.claude/skills` by default; override with `--dir PATH` or `$CLAUDE_SKILLS_DIR`. Re-running updates an already-installed skill. After installing, restart Claude Code (or `/reload-plugins`) and invoke with `/<skill-name>`.
