---
name: agent-session-search
description: Search, read, and summarize past coding-agent session logs — Codex rollout JSONL and Claude Code project JSONL — without loading raw transcripts into the calling context. Use when asked what a previous session did, to recover a decision or command from an earlier run, to find every session that touched a host/repo/feature, or to summarize an agent's work on a topic. Extracts user and assistant turns with jq, then delegates the reading to an Opus subagent.
---

# Agent session search

Session logs are enormous and mostly not prose. A single Claude Code session file
is 400+ JSONL records, of which ~24 are actual conversation; a Codex rollout is
worse (596 `item_completed` events wrapping 55 assistant messages). **Never
`cat`, `Read`, or `grep -h` a raw session file into your own context.** Use the
jq filters here to reduce to the turns, and hand the reading to a subagent.

## The one trap

There are **two Codex rollout schemas in the same directory tree**, and a filter
written against one silently returns zero rows on the other:

| Variant | Conversation lives in |
| --- | --- |
| A | `.type=="response_item"` → `.payload.type=="message"` → `.payload.role` + `.payload.content[].text` |
| B | `.type=="event_msg"` → `.payload.type=="user_message"` \| `"agent_message"` |

`scripts/codex.jq` emits both, so it never returns empty for the wrong reason. If
you write your own filter and get no output, check the variant before concluding
the session is irrelevant.

## Where the logs are

| Harness | Path |
| --- | --- |
| Codex | `~/.codex/sessions/YYYY/MM/DD/rollout-<ISO>-<uuid>.jsonl` |
| Claude Code | `~/.claude/projects/<cwd-slug>/<session-uuid>.jsonl` |
| Claude subagents | `~/.claude/projects/<slug>/<session-uuid>/subagents/agent-*.jsonl` |
| Claude workflow agents | `.../<session-uuid>/subagents/workflows/wf_*/agent-*.jsonl` |

The Claude project directory name is the working directory with `/` → `-`, so
`~/repos/acme/api` becomes `-home-user-repos-acme-api`. Subagent logs are separate
files — a topic can appear only in a subagent transcript, so search the whole tree,
not just top-level session files.

## Workflow

**1. Rank candidates by term density.** Hit count is a good proxy for "this
session was *about* the topic" versus "it mentioned it once".

```sh
scripts/session-grep.sh <term> [codex|claude|all] [limit]   # prints "count<TAB>path"
```

**2. Screen out machine-generated rollouts.** Codex spawns judge/guardian
subagent rollouts that quote whole transcripts, so they rank high on any term and
contain no real work:

```sh
jq -c -f scripts/codex-meta.jq FILE
# {"thread_source":"user",     "originator":"codex-tui"}   <- real session, keep
# {"thread_source":"subagent", "originator":"codex_exec"}  <- judge/guardian, drop
```

**3. Check the opening ask before committing to a file.** One line tells you
whether the session is the one you want:

```sh
jq -r -f scripts/codex.jq FILE | jq -rs '[.[]|select(.role=="user")][1].text[0:400]'
```

Index `[1]`, not `[0]` — the first "user" turn on both harnesses is the injected
`AGENTS.md` / `CLAUDE.md` preamble, not a human.

**4. Delegate the reading to an Opus subagent.** This is the point of the skill:
the extracted turns still run to tens of thousands of tokens, and they belong in
a subagent's context, not yours.

```
Agent(subagent_type: "general-purpose", model: "opus", prompt: ...)
```

Give the subagent: the exact file paths, the filter path, the extraction command,
and the question. Tell it to return a summary, never a transcript.

```sh
# codex
jq -r -f <SKILL>/scripts/codex.jq FILE  | jq -rs '.[]|"\(.ts) [\(.role)]\n\(.text)\n"'
# claude code
jq -r -f <SKILL>/scripts/claude.jq FILE | jq -rs '.[]|"\(.ts) [\(.role)]\n\(.text)\n"'
```

Spawn one subagent per candidate session and let them run concurrently; synthesize
their reports yourself. Subagent reports are not shown to the user — relay the
findings.

## Reading the extracted turns

- The first `user` turn is always harness-injected instructions. So are turns
  starting with `<command-message>`, `<skills_instructions>`, or
  `Base directory for this skill:` — skill and slash-command bodies, not the human.
- Codex `developer`-role messages are system prompts; the filters drop them.
- Assistant `reasoning` records are excluded on purpose. If a summary needs the
  *why* behind an action and the visible text does not carry it, extract
  `.payload.type=="reasoning"` separately for that one file.
- Tool calls and results are excluded. When a summary must name the commands run,
  extract them narrowly rather than widening the filter:
  `jq -r 'select(.payload.type=="function_call")|.payload.name' FILE | sort | uniq -c`

## Diagnostics

| Symptom | Cause | Fix |
| --- | --- | --- |
| jq filter returns nothing | wrong Codex variant | use `scripts/codex.jq`, which covers both |
| Session is 90% quoted transcript | judge/guardian rollout | screen with `codex-meta.jq`, `thread_source` |
| `grep -rl` matches hundreds of files | term is a hostname or common noun | rank by count and take the top few |
| `head` on the ranking script exits 141 | SIGPIPE, expected | already suppressed in the script |
| Claude session file has no matches but the work happened there | it ran in a subagent | search `.../subagents/agent-*.jsonl` too |
| Extracted text still floods context | you ran the jq yourself | that is the subagent's job, not yours |
