---
name: prose-reviewer
description: Review and clean up user-facing prose — READMEs, docs, blog posts, release notes, UI copy, marketing text — by launching parallel reviewer agents that flag AI-writing tells, wordiness, and tone problems, then applying the fixes. Use when asked to review, polish, copyedit, "de-AI", or "humanize" prose, when text "sounds like ChatGPT", or before publishing anything user-facing that an agent helped write.
---

# Prose reviewer

Works like `/simplify`, but for prose instead of code: fan out a few read-only
reviewer agents over the target text, merge and verify their findings, then apply
the fixes yourself in one editing pass. The backbone reference is a local copy of
Wikipedia's field guide to AI-writing tells:

- `references/signs-of-ai-writing.md` — the full guide (~1,700 lines). For
  general prose the high-value sections are **Content**, **Language and
  grammar**, **Style**, and **Communication intended for the user**; the Markup
  and Citations sections are Wikipedia-specific.

## The trap: masking tells instead of fixing prose

The guide's own warning applies here: the listed patterns are *signs* of shallow
writing, not the problem itself. Deleting every em dash and "moreover" while
leaving vague, puffed-up content produces prose that is still bad — just harder
to diagnose. Rewrite for substance: replace inflated claims with concrete facts,
delete filler instead of rephrasing it, and flag (don't silently keep) any claim
no source in the project supports.

## Workflow

### 1. Scope

Decide what prose is under review, in this order:

1. Files or text the user named.
2. Otherwise, user-facing prose in the working diff (`git diff` + staged +
   untracked): markdown docs, README changes, UI strings, changelog entries,
   comments in templates/emails.
3. If neither yields anything, ask what to review.

Code, identifiers, API names, quoted material, and licensed text are out of
scope — reviewers may flag prose *around* them but never rewrite them.

### 2. Fan out reviewers

Launch 2–3 read-only reviewer agents **in parallel**, each with the file list, a
single lens, and instructions to return findings as `file:line`, the offending
text, why it's a problem, and a suggested rewrite. Reviewers read; only the lead
edits — this avoids conflicting edits and keeps one voice in the final pass.

| Lens | Instructions to the agent |
| --- | --- |
| AI tells | Read `references/signs-of-ai-writing.md` (sections named above), then hunt those patterns: significance inflation ("stands as a testament"), puffery, rule-of-three padding, negative parallelisms ("not just X, but Y"), AI vocabulary ("delve", "showcase", "boasts", "vibrant"), boldface/em-dash/emoji overuse, title case headings, outline-like "challenges and future prospects" conclusions, vague attributions ("industry reports suggest"). |
| Clarity & concision | No reference needed. Flag wordiness, redundancy, hedging, filler transitions, sentences that say nothing, headers for two-sentence sections, lists that should be prose (and vice versa). |
| Voice & audience | Tone consistency with surrounding/existing project prose, terminology drift, audience fit (over-explaining to experts, jargon for newcomers), and factual claims the project itself doesn't support (superlatives, invented user benefits). |

For a small target (one README, a few strings) two agents suffice: AI tells +
clarity. Add the voice lens when reviewing across multiple files or anything
outward-facing (blog post, announcement, marketing page).

### 3. Merge, verify, apply

1. Dedupe overlapping findings; where lenses disagree, prefer the more concrete
   rewrite.
2. Verify each finding against the actual text before acting — the guide is
   explicit that these are indicators, not proof, and human writing legitimately
   uses every one of these constructions. Drop findings where the original is
   genuinely the best phrasing.
3. Apply the surviving fixes with normal edits, keeping diffs minimal and
   reviewable. Preserve the author's meaning and register; shorter is the
   default direction.
4. Anything that needs a fact the text doesn't contain (a real number, a real
   source, whether a claim is true) becomes a question for the user, not an
   invention.

### 4. Report

Summarize per file: what changed and the dominant patterns found (e.g. "cut ~30%
for wordiness; removed six significance-inflation phrases"). List the questions
from step 3.4 last, so unverifiable claims don't ship silently.
