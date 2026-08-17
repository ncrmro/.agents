---
name: prose-voice-critic
description: Get an independent, uncontaminated critique of prose against its author's own style guide by running a CLI subagent with a fully replaced system prompt from a neutral directory. Use when you wrote the prose yourself and need an outside read, when a style guide has a checklist that should be run item by item, when a reviewer keeps agreeing with you, or before publishing anything written in someone else's voice.
---

# Prose voice critic

One command gets you a critic that has never seen your project, your notes, or
your opinion of the draft: a subagent whose system prompt you replace entirely,
run from an empty directory, with the style guide and the document pasted into
its prompt. It returns criticism, not an offer to help.

Supporting files, read when needed:

- `references/critic-system-prompt.md` — the tested critic persona. Copy it.
- `scripts/blind-critique.sh` — runs the blind pass (and the primed pass for
  comparison).

Related: `prose-reviewer` fans out several lenses *inside* the project and
applies the fixes. Use that to edit. Use this to find out whether the piece is
any good in the first place, especially when you are the author.

## The one trap that wastes an afternoon

**Replacing the system prompt does not make the subagent blind.** Project
context — `CLAUDE.md` / `AGENTS.md`, the memory index, git status — is injected
from the **current working directory**, on the user side, not the system side.
So a critic launched from inside the project reads your own notes about the
flaw you asked it to find independently, and hands your hypothesis back to you
as its discovery.

The tell is exact: the critique cites a memory slug, a note filename, or a rule
you wrote — evidence it read the answer key.

Fix: **run from an empty directory.** Nothing else is required.

```sh
mkdir -p "$(mktemp -d)/blind" && cd "$_"
```

And a corollary trap: `--exclude-dynamic-system-prompt-sections` does **not**
solve this. Its own help says it applies only with the default system prompt,
so it is ignored exactly when you are replacing it.

## The flags that matter

| flag | effect |
| --- | --- |
| `--system-prompt <text>` | **replaces** the system prompt — no harness persona, no tool instructions |
| `--append-system-prompt <text>` | appends to the default; the assistant persona survives, which is not what you want |
| `--system-prompt-file <path>` | same as `--system-prompt`, from a file |
| `--model <model>` | a mid-tier model is a *better* critic here — less eager to agree |
| `-p` | print and exit |

Replace rather than append on purpose. The default harness prompt makes a
helpful assistant with tools, and a helpful assistant offers to fix your draft.
A critic with no tools has nothing to do but criticize.

Because the system prompt is gone, the subagent has no tool instructions — so
**embed both documents in the prompt** rather than expecting it to read files.

## Workflow

1. Write the critic persona (start from `references/critic-system-prompt.md`).
2. Assemble one prompt: the author's style guide, then the document, then the
   task. Label the two documents unmistakably.
3. If the guide ends with a checklist addressed to agents, **tell the critic to
   run it item by item and give each item a verdict plus the line that proves
   it.** This is where most of the value comes from — it converts taste into
   something auditable.
4. Ask it to judge repeated structures *as a set* (all the headings, every
   section opener). Set-level faults are invisible one at a time: a document
   where half the headings report and half tease reads as two documents.
5. Run blind. Then, optionally, run primed and diff.

## Run both passes, and read the disagreement

The primed run — launched inside the project — is not useless. It is a
different instrument, and **where the two disagree is the finding.**

Observed: an author objected to a specific sentence, and that objection had
been written into project notes. The primed critic duly condemned that
sentence. The blind critic **defended** it — it earned its place, because the
payoff the sentence promised actually arrived four sentences later. Both runs
independently condemned two *other* sentences the author had not mentioned.

Read it this way:

| agreement | meaning |
| --- | --- |
| both condemn | real; fix it |
| blind only | you were too close to see it |
| primed only | it pattern-matched your complaint; re-examine before cutting |

## Verify what the critic asserts

A critic with no tools cannot check anything, and will still produce specific
numbers. One cited a line count that was wrong because it had counted a whole
commit rather than the file under discussion. **Every figure it hands you is a
claim, not a measurement.** Check before promoting one into the document.

## The strip test

The most portable heuristic to come out of this, worth putting in the critic
persona and in your own head:

> Remove every specific from the sentence. If what remains is still true, it
> was posture — cut it.

- "The answer does not fall where you would guess" — survives stripping.
  Posture.
- "Drafted at thirteen slides, eleven after review" — nothing survives. Real.

It catches the failure the tells-based guides describe as inflated
significance: setup sentences that promise a reveal, headings that dramatize,
and short declaratives that assert importance onto the sentence before them.

## Quick diagnostics

| symptom | cause | fix |
| --- | --- | --- |
| Critique cites your memory, notes, or a rule you wrote | ran with project context in cwd | rerun from an empty directory |
| Opens with "I'd be happy to review…" or ends offering more help | system prompt appended, not replaced | use `--system-prompt`, and forbid pleasantries in the persona |
| Everything is praised; no findings | persona too polite, or model too agreeable | strengthen the three-way sort; drop to a mid-tier model |
| Invents faults in good passages | rigor demanded without permission to pass | let it say "this is good" in one line and move on |
| Flags every em dash and "moreover" | masking tells instead of judging substance | say the tells are symptoms; ask what the sentence *does* |
| Rewrites the whole piece | no constraint on output | forbid rewriting; allow a replacement line only where it is faster than describing the fix |

## When not to use it

- The prose is a spec, an error message, or inter-agent instruction — that is a
  different discipline; use the project's technical-English standard instead.
- You need the fixes applied, not judged — use `prose-reviewer`.
- The document is long enough that pasting it plus the guide is wasteful; split
  it and critique the sections that carry the argument.
