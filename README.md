# Skills

Moe's agent skills for Claude Code and other coding agents.

## Quickstart

1. Run the skills.sh installer:

```bash
npx skills@latest add moeghashim/skills
```

2. Pick the skills you want, and which coding agents you want to install them on.

3. Invoke a skill in your agent with `/<skill-name>` (e.g. `/gpt-claude`).

<details>
<summary>Alternative install (no Node needed)</summary>

```bash
curl -fsSL https://raw.githubusercontent.com/moeghashim/skills/main/install.sh | bash -s -- gpt-claude
```

Or from a clone: `./install.sh --list`, `./install.sh <skill>`, `./install.sh --all`. Skills install to `~/.claude/skills` by default; override with `--dir PATH` or `$CLAUDE_SKILLS_DIR`. Re-running updates an installed skill.

</details>

## Repo structure

Skills live at `skills/<category>/<skill-name>/SKILL.md`. Run `scripts/list-skills.sh` to list them all.

## Reference

### Engineering

- **[gpt-claude](./skills/engineering/gpt-claude/SKILL.md)** — Set up the OpenAI Codex plugin inside Claude Code and run a Claude-as-orchestrator / Codex-as-executor workflow: Claude (Fable 5) plans, decomposes, and reviews; Codex (`gpt-5.6-codex`) executes heavy implementation as parallel background subagents.
