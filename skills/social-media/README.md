# social-media — design notes

This skill helps a user take **an idea they already have** and present it as an
X post or a longform X article, tracked as markdown with `scheduled`/`posted`
frontmatter. See [`SKILL.md`](SKILL.md) for the workflow and frontmatter
contract; this file records *what good looks like* — the real posts the
templates are modeled on — so the templates can be judged against live
examples rather than taste alone.

## The shape we're designing for

A user has a point to make. It lands in one of three forms, by how much room
the idea needs and whether the longform lives here or elsewhere:

| Form | Template | When |
| --- | --- | --- |
| **Article** | `assets/template.x.article.md` | The idea is a whole course/argument — it earns 1000+ words and stands alone. |
| **Post → own article** | `assets/template.x.post.md` (thread) | The same idea compressed into a numbered thread that hooks and funnels to the article. |
| **Post → external longform** | `assets/template.x.post.md` (single) | The longform is someone else's (or a blog); the post is a framed pointer to it. |

The three reference posts below are one instance of each. All were read in full
from their live pages; only structure is recorded here, never their text.

## Reference exemplars

### 1. Longform article — the self-contained course

- **Post:** <https://x.com/0xCodez/status/2079165300625330317>
- **Article:** "Graph Engineering with Claude: 14-Step roadmap from 0 to graph architect (Full Course)" by [@0xCodez](https://x.com/0xCodez), 2026-07-20.
- **Form:** longform X article (`kind: article`).
- **Structure that the template encodes:**
  1. **Hook** — names a failure mode vividly (agents built as a straight line, each step "waiting politely" for the last) and twists with an observed ratio ("9/10 never notice half those steps didn't need to wait").
  2. **Reframe** — the thesis nobody spells out: "the shape of the work is a graph. Nodes think, edges carry results." Every lesson is an application of this.
  3. **14 numbered lessons** (`01.`…`14.`) titled as memorable *assertions* ("Your linear script is a degenerate graph"), each = claim → why it bites → the misconception it kills → **one concrete artifact** (a code block, a before/after, a named "smell test").
  4. **Applications** — "Six graphs to build with Claude this week": one-paragraph sketches of the whole roadmap applied to real jobs. The screenshot-and-act section.
  5. **Aphoristic close** — "A prompter asks a question. An architect draws a graph." No CTA; self-promo woven lightly into the hook, not saved for the end.

### 2. Post that funnels to its own article — the compressed thread

- **Post:** <https://x.com/0xCodila/status/2080344428179259846>
- By [@0xCodila](https://x.com/0xCodila), 2026-07-23, quote-tweeting the author's own article.
- **Form:** short-form thread/post (`kind: post`) selling a longform.
- **Structure worth stealing:**
  - **Borrowed-authority hook** — "Andrew Ng just dropped an 8-page PDF on…" anchors the idea to a name the reader trusts.
  - **The twist** — a single antithesis line that frames the whole idea ("Loops let agents think — Graphs let agents remember").
  - **Numbered one-liners** — `step 1 →`, `step 2 →` … each a compressed claim with an em-dash payoff, not a paragraph. The article's lessons, boiled to a scannable spine.
  - **Punchline result** — "a weak model with 4 steps destroys a strong model without them — same cost, it's the architecture."
  - **Explicit CTA + funnel** — "save this — then read the full build workflow in the article below ↓", with the article quote-tweeted beneath.
- **Lesson for the skill:** a post and its article are one idea at two resolutions. When both exist, the post's job is the hook and the funnel; it should not try to teach the whole thing.

### 3. Post that points at external longform — the framed share

- **Post:** <https://x.com/pidotdev/status/2080254453874127033>
- By [@pidotdev](https://x.com/pidotdev), 2026-07-23, quote-tweeting a blog post by [@mitsuhiko](https://x.com/mitsuhiko).
- **Form:** short single post (`kind: post`) amplifying someone else's writing.
- **Structure worth stealing:**
  - **Stakes-first line** — leads with why the reader should care ("Prompt caching affects latency, cost, tool design and product feature decisions"), not "check out this post."
  - **Clear attribution** — names the author and what it is ("New blog post from @mitsuhiko on…").
  - **One ask** — "Read the full post below," with the source quote-tweeted. No manufactured hype, no fake first-person claim over another's work.
- **Lesson for the skill:** when the longform isn't yours, the post is a *frame*, not a summary — assert the stakes, credit the source, link, stop.

## Why this lives in the skill

These are moving targets: accounts delete posts, X changes article rendering,
and the genre's conventions drift. This README is the durable capture of the
patterns so the templates stay grounded even after the links rot. When a
template is revised, re-read whichever exemplar it's modeled on (they need a
logged-in X session) and update this file if the structure it teaches has
changed.
