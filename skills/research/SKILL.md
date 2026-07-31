---
name: research
description: Run bounded, evidence-backed research — find existing research before starting new, frame a timeboxed spike, gather primary sources from the web, capture each one as a citable source package, then graduate durable findings into the wiki. Use when asked to research, investigate, spike, de-risk, compare options, evaluate feasibility, gather sources or citations, or answer a question that needs evidence rather than recall.
---

# Research

Three artifacts, three lifecycles. The common mistake is putting a finding in
the wrong artifact.

| Artifact | Where | Lifecycle |
| --- | --- | --- |
| **Spike** — the working investigation | `~/notes/research/YYYY-MM-DD-<slug>/` | Timeboxed. Frozen once closed; corrections go in a new spike. |
| **Source package** — the evidence | `~/notes/wiki/sources/YYYY-MM-DD-<slug>/` | Immutable. Never rewritten after capture. |
| **Synthesized note** — the durable answer | `~/notes/wiki/research/<slug>.md` | Living. Revised and superseded as understanding changes. |

A spike is a *session*: dated by the day you started it, tagged `spike`, and
answering one question for one decision. A source is an *artifact*: dated by its
own publication or recording date, so `wiki/sources/` sorts chronologically by
what was published, not by when you read it.

The `wiki` skill owns everything else about note structure, tags, and linking —
read it before writing into `wiki/`. This skill owns the investigation, the
evidence capture, and the hand-off between the two.

## The rule everything else serves

**A finding you cannot re-open is not evidence.**

A URL in a bibliography is a promise that the page still says what you said it
said. It usually doesn't — docs get versioned away, pricing pages change, repos
force-push. And a `WebFetch` result is a model's rendering of a page rather than
the page itself: a lead, not a citation.

So: **before a claim enters a spike README or a wiki note, the bytes it rests on
live in a source package on disk, with a hash.** If you couldn't capture it
(paywall, login wall, live dashboard), say so in the note's evidence limits
rather than citing it as if you had.

Two corollaries:

- **Never cite an LLM summary — yours or another agent's — as a source.** A
  subagent's research report is a lead list. Follow its links, capture them,
  cite those.
- **Never invent source metadata.** No guessed publication dates, DOIs,
  authors, or version numbers. Unknown is a valid value; wrong is not.

## Step 0 — find before you spike

The vault has years of spikes in it, and a request often lands on one that is
already answered. Always check, and say what you found before starting new work.

```sh
cd ~/notes
~/.agents/skills/wiki/scripts/wiki-cli search 'query'   # notes AND captured source text
ls research/ | rg -i 'keyword'                          # existing spikes
rg -il 'keyword' research/*/README.md wiki/research/ wiki/sources/*/source.md
```

Then pick the outcome, out loud:

- **A closed spike already answers it** → report the finding and its date, and
  say what could have drifted since. Don't silently redo it.
- **An active spike covers it** → continue that spike, don't fork a second one.
- **A stale spike is close but its facts have aged** → new spike, linked to the
  old one as prior work; the old spike stays frozen.
- **A wiki concept or research note covers it** → answer from the note and
  refresh it if the sources have moved on.
- **Nothing** → frame a new spike.

## Step 1 — frame

Write the frame *before* the deep work, in `README.md`. Full template:
[`assets/spike-README.template.md`](assets/spike-README.template.md).

Five things make a spike useful, and all five go in before you start:

1. **Research question** — the single uncertainty being resolved.
2. **Decision it informs** — what will be done differently after. If nothing
   changes either way, this isn't a spike; it's reading.
3. **Assumptions that would change the answer** — the facts or priorities that
   would flip the recommendation.
4. **Scope** — in and out, explicitly.
5. **Timebox / stopping rule** — the condition under which you stop gathering
   and make the call, decided while you're still unattached to an answer.

The template also carries **method** (how you'll get the evidence) and
**acceptance criteria** (what evidence would be enough). Fill them in for
anything bigger than an afternoon; for a quick spike the method is obvious from
the question and the stopping rule does the work.

```text
~/notes/research/YYYY-MM-DD-<slug>/
├── README.md     # frame, findings, recommendation — the whole spike if it's small
├── docs/         # analysis, source notes, evidence transcripts, screenshots
└── code/         # disposable prototypes, scripts, flakes, fixtures
```

`README.md` frontmatter is `type: research`, `status: active`, and a `tags:` list
of the structural tag `spike` plus 2–4 subject tags. Subject tags come from
`wiki/tags.md` and are flat kebab-case, 2–5 per page for this vault — the
hierarchical `namespace/value` scheme in the `wiki` skill is its portable
default, and `wiki/tags.md` overrides it here. Add any new tag there in the same
commit. (`spike` itself is structural and is not in `wiki/tags.md`.)

## Step 2 — gather

Prefer primary sources for claims about what a system, author, or dataset
directly says or does: official documentation for the exact version in play,
standards, filings, source code you read yourself, datasets, and original
publications. Use strong secondary sources for synthesis, context, and locating
relevant primary evidence.

- **Search broadly, then narrow to primaries.** `WebSearch` for the landscape;
  follow through to the vendor doc, the RFC, the repo, the paper.
- **Read the code when the code is the authority.** For any claim about a
  tool's behavior, the repo at a specific commit outranks its blog post.
- **Note the version.** "Forgejo does X" is not a finding; "Forgejo 15.0.2
  does X" is. Record the version you checked and how you checked it.
- **JS-heavy or interactive pages** — use the browser MCP (`browser-mcp` skill)
  to reach the content, but still capture something durable: saved HTML, a
  screenshot, or a copied-out block quoted in `docs/`.
- **Audio/video sources** — the `media-editor` skill owns transcription and
  diarization; bring the transcript back here as the searchable representation.
- **Delegating a sweep to subagents is fine** and often the fastest way to cover
  a landscape — but their output is a lead list. The capture in step 3 is yours.

Reading another project's repository is normal during a spike; **editing one is
not.** Clone or read it, quote it, cite the commit — but don't commit to it
unless the task authorized changes in that repo.

Keep contradictions. When two credible sources disagree, record both and say
which is stronger and why; do not average them into a bland middle.

## Step 3 — capture each citable source

One directory per source, created the moment you decide to cite it.

```text
~/notes/wiki/sources/YYYY-MM-DD-<slug>/
├── source.md          # the note — frontmatter, provenance, integrity, summary, limits
├── <original>.html    # immutable original bytes, descriptive name
├── content.md         # searchable extracted text
└── figures/
```

Capturing a documentation page:

```sh
S=~/notes/wiki/sources/2026-07-26-forgejo-actions-reuse
mkdir -p "$S"
curl -sSL --compressed -o "$S/forgejo-v15-actions-reference.html" \
  'https://forgejo.org/docs/v15.0/user/actions/reference/'
sha256sum "$S"/*.html          # → the Integrity table in source.md
docling convert --to md --output "$S" "$S/forgejo-v15-actions-reference.html"
mv "$S/forgejo-v15-actions-reference.md" "$S/content.md"
```

`source.md` is the graph node, so it always exists — even when the original
couldn't be archived. Template and the full toolchain (PDFs, OCR, paywalls, Git
LFS, what to do when capture fails):
[`references/source-capture.md`](references/source-capture.md) and
[`assets/source.template.md`](assets/source.template.md).

**`## Evidence limits` is not optional.** Every source note states what its
evidence does *not* establish. Documentation proves documented behavior, not
that a system works; a config file proves configuration, not a successful run.

## Step 4 — synthesize

Keep three things visibly separate in the write-up, because collapsing them is
how a guess becomes a fact three months later:

| Layer | What it is | How to mark it |
| --- | --- | --- |
| **Observed evidence** | What a captured source states, or what a command you ran output | Cite the source package or paste the command + output |
| **Interpretation** | What you conclude that follows from it | Say "this implies", and name the assumption |
| **Recommendation** | What to do | Attach confidence (low/medium/high) and the risk if wrong |

Cite inline, by relative wiki link into the source package — from a spike
README (`research/<slug>/README.md`) that is `../../wiki/sources/…`; from a wiki
research note it is `../sources/…`:

```md
Forgejo v15 expands same-instance reusable workflows into separate jobs
([[../../wiki/sources/2026-07-26-forgejo-actions-reuse/source|Forgejo Actions reuse on v15]]).
```

## Step 5 — close

A spike ends with a decision, not a pile of notes. Set `status:` to `resolved`
(question answered) or `archived` (abandoned or overtaken), and record:

- the **answer**, in one or two sentences;
- **confidence** and what would change it;
- **key sources**, linked to their packages;
- **open questions** the spike did not resolve;
- **follow-up tasks** as checkboxes — and if they belong to a project, add them
  to that project's `## Open Tasks` via the `project-notes` skill rather than
  leaving them stranded in the spike.

If it hit the timebox without an answer, that *is* the outcome: close it as
`resolved` with "insufficient evidence within timebox", and say what a follow-up
would need. Silently extending the timebox is the failure mode.

## Step 6 — graduate

The spike is a session record; it should not be where the vault keeps its
knowledge. Anything durable moves into the wiki.

- A finding that explains **what something is or how it works** → a
  `wiki/concepts/` note.
- A finding that is a **bounded investigation others will re-read** (trade
  study, feasibility, evidence synthesis, literature review) → a
  `wiki/research/<slug>.md` note with `type: research`, `generated: true`, and a
  `research_kind:` (`trade-study`, `feasibility-study`, `evidence-synthesis`,
  `literature-review`, `experiment-summary`).
- A finding that **changes a project's plan** → the project registry, via
  `project-notes`.
- The rest stays in the spike.

Graduation is a copy-and-link, not a move: the spike stays frozen where it is,
the wiki note carries the durable version, and each links to the other. Then add
the `wiki/index.md` entry and the `wiki/log.md` line in the same run — the
`wiki` skill's rules apply in full to anything you write under `wiki/`.

## Traps

| Symptom | Cause | Fix |
| --- | --- | --- |
| Spike duplicates one from three months ago | Skipped step 0 | `wiki-cli search` and `ls research/` before framing, always |
| Citation 404s, or the page no longer says it | Cited a URL, captured nothing | Capture bytes + hash into `wiki/sources/` before citing |
| Confident claim, no traceable basis | `WebFetch` summary or subagent report treated as evidence | Follow the link, capture the primary, cite that |
| "Tool X does Y" turns out false | Version not pinned | Record the exact version checked, and how it was checked |
| Spike runs for days | No stopping rule, or it was moved | Write the timebox in the frame; hitting it is a valid outcome |
| Findings unfindable six weeks later | Never graduated to the wiki | Step 6 — the spike is a session, the wiki is the memory |
| Wiki note over-claims what the sources support | `source.md` had no evidence limits | Every source note states what it does *not* prove |
| Two sources disagree, note picks one silently | Contradiction smoothed away | Record both, rank them, explain the ranking |

## Working outside the notes vault

The default is `~/notes/` — say the absolute path when creating a spike, even
when the session is running inside a code repo.

A code repo with its own `wiki/` tree is the exception: there, the same three
shapes apply relative to the repo root, and `wiki-cli` resolves that repo's
vault automatically. Never split one investigation across both vaults — pick the
one that owns the knowledge and link from the other.
