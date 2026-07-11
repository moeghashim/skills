---
name: gpt-claude
description: >-
  Set up the OpenAI Codex plugin inside Claude Code and establish a
  Claude-as-orchestrator / Codex-as-executor workflow, where Claude (Fable 5)
  handles planning, repo understanding, architecture decisions, task
  decomposition, and final review, while Codex (via /codex:rescue and the
  codex-rescue sub-agent) executes heavy implementation, debugging, test
  fixing, refactoring, and multi-file edits. Use this skill at the start of a
  session, whenever the user mentions Codex, GPT, "gpt-claude", "Fable-GPT",
  delegating implementation work to another model, or wants Claude to
  orchestrate while another agent codes.
---

# GPT-Claude

Turn a Claude Code session into an orchestrator/executor pair: Claude plans and reviews, Codex implements. Invoke this skill at the start of a session so every subsequent heavy task is delegated correctly.

## Step 1 — Ensure the Codex plugin is installed

Check whether the Codex plugin commands (`/codex:setup`, `/codex:rescue`) and the `codex:codex-rescue` sub-agent are available in this session.

If they are NOT available, ask the user to run these commands in Claude Code (they are interactive terminal commands only the user can run):

```
/plugin marketplace add openai/codex-plugin-cc
/plugin install codex@openai-codex
/reload-plugins
```

## Step 2 — Complete the Codex setup

Once the plugin is available, finish the setup:

1. Run `/codex:setup` (the official OpenAI Codex plugin setup).
2. If the Codex CLI is missing, install it.
3. If Codex is installed but not authenticated, ask the user to authenticate with their ChatGPT account. Authentication happens once; afterwards Codex runs from inside Claude Code using the user's Codex subscription.
4. After auth completes, verify Codex works from inside Claude Code.
5. Confirm the `codex:codex-rescue` sub-agent is available.
6. Do not change any project code during setup.

## Step 3 — Operate with this delegation workflow

For the rest of the session, follow this division of labor:

**You (Claude / Fable 5) are the orchestrator.** Use yourself for:
- Planning and task decomposition
- Repo understanding and architecture decisions
- Final review of all delegated work

**Codex (`codex-rescue`) is the executor.** Delegate to it when a task needs:
- Heavy implementation
- Debugging or test fixing
- Refactoring
- Multi-file code edits

Delegation rules:
- When delegating to Codex, use `/codex:rescue`.
- Prefer **GPT 5.5 (xtra high)** as the go-to Codex model.
- Keep Codex tasks focused and specific — one well-scoped task per delegation, not a vague "fix everything".
- After Codex finishes, inspect the result yourself before accepting it. Do not blindly trust Codex output.

## Pro tips

1. Invoke this skill at the start of every session where Codex delegation is wanted.
2. Combine the skill with a goal for heavy tasks — goals work best for long-horizon work.
3. On the Codex 20x Pro plan, sub-agents can run in parallel: 5–7 Codex agents at a time typically stays under the 5-hour limit.
4. Context rot is real — clear the conversation after ~4 compactions. Use a `/handoff` skill (if available) to preserve context across the reset.
