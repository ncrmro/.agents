---
name: prose-reviewer
description: Review and clean up (user-facing) prose.
---

# Prose reviewer

Works like `/simplify`, but for prose instead of code: fan out a few read-only
reviewer agents over the target text, merge and verify their findings, then apply
the fixes yourself in one editing pass. The backbone reference is Wikipedia's
field guide to AI-writing tells, split into one cleaned file per reviewer lens:

- `references/content-tells.md` — inflated significance, promotional framing,
  vague sourcing, hollow analysis (the highest-value tells).
- `references/language-tells.md` — AI vocabulary, copula avoidance, negative
  parallelisms, rule-of-three padding, elegant variation.
- `references/style-tells.md` — title case, boldface/em-dash/emoji overuse,
  inline-header lists, table misuse, curly quotes.
- `references/communication-tells.md` — chat remnants, knowledge-cutoff
  disclaimers, placeholders, model-specific citation artifacts.
- `references/signs-of-ai-writing.md` — the full vendored guide the above are
  derived from; read only when a finding needs the original context.

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

Launch read-only reviewer agents **in parallel**, each with the file list, a
single lens, and instructions to read its one reference file first, then return
findings as `file:line`, the offending text, why it's a problem, and a suggested
rewrite. Reviewers read; only the lead edits — this avoids conflicting edits and
keeps one voice in the final pass.

| Lens | Reads | Hunts |
| --- | --- | --- |
| Content & substance | `references/content-tells.md` | Significance inflation ("stands as a testament"), puffery, vague attributions ("industry reports suggest"), superficial analysis, formulaic "challenges and future prospects" conclusions. |
| Language & phrasing | `references/language-tells.md` | AI vocabulary ("delve", "showcase", "boasts", "vibrant"), copula avoidance ("serves as" for "is"), negative parallelisms ("not just X, but Y"), rule-of-three padding, elegant variation. |
| Style & remnants | `references/style-tells.md` + `references/communication-tells.md` | Title case headings, boldface/em-dash/emoji overuse, inline-header lists, chat leakage ("I hope this helps"), placeholders, leftover machine artifacts. |
| Clarity & voice | nothing | Wordiness, redundancy, hedging, filler transitions, headers for two-sentence sections, tone/terminology drift against the project's existing prose, audience fit, claims the project itself doesn't support. |

For a small target (one README, a few strings) two agents suffice: content +
language, with the lead covering clarity while merging. Use all four for
anything outward-facing (blog post, announcement, marketing page) or multi-file.

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
