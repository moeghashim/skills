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

For the rest of the session, follow this workflow:

**You (Claude / Fable 5) are the orchestrator.** Stay in the main loop for decomposition and final decisions. Do not do heavy reading or heavy implementation inline — fire subagents for both.

**Fable subagents (planning/understanding/review):**
- Spawn Fable 5 subagents via the Agent tool: `Explore` agents for repo understanding and broad searches, `Plan` agents for implementation strategy, `general-purpose` agents for research and reviewing completed work.
- When tasks are independent, launch all subagents in one message so they run concurrently.

**Codex subagents (execution):**
- Use codex-rescue as the executor when a task needs heavy implementation, debugging, test fixing, refactoring, or multi-file code edits.
- Delegate via the Agent tool with `subagent_type: "codex:codex-rescue"` (equivalent to `/codex:rescue`). Run Codex agents in the background so you can keep orchestrating, and run multiple Codex agents in parallel when tasks are independent.
- Use `gpt-5.6-codex` at medium effort as the go-to Codex model — pass `--model gpt-5.6-codex --effort medium` when delegating.
- Keep each Codex task focused and specific: one scoped objective per agent, with exact file paths, constraints, and acceptance criteria (e.g. "these tests must pass"). Never delegate a vague "fix everything" task.
- If parallel Codex agents would touch overlapping files, either serialize them or isolate each in its own worktree, then merge.

**Verification (non-negotiable):**
- After any subagent finishes, inspect the result yourself before accepting: read the diff, run the tests/build, check the acceptance criteria. Do not blindly trust Codex output.
- If a result fails inspection, send a focused follow-up to the same Codex thread (`--resume`) instead of restarting from scratch.
- Only report a task as done after your own verification passes.

## Pro tips

1. Invoke this skill at the start of every session where Codex delegation is wanted.
2. Make sure the session itself runs on Fable 5 (`/model` → Fable 5) — the orchestrator is the main-loop model. The Claude Code header always shows the Claude model, never Codex; Codex activity appears as `codex:codex-rescue` agents in the task/agent activity.
3. Combine the skill with a goal for heavy tasks — goals work best for long-horizon work.
4. On the Codex 20x Pro plan, sub-agents can run in parallel: 5–7 Codex agents at a time typically stays under the 5-hour limit.
5. Context rot is real — clear the conversation after ~4 compactions. Use a `/handoff` skill (if available) to preserve context across the reset.
