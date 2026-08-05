---
name: social-media
description: Draft, schedule, and track social media content — microblog posts and threads (X, Bluesky, Threads, Mastodon, LinkedIn), longform articles, vertical short video (Reels, Shorts, TikTok), stories, and image carousels — as markdown files with scheduled/posted frontmatter. Use when writing a post, thread, video script, story sequence, or carousel, adapting one idea across channels, checking what's due to go out, or recording that something was published.
---

# Social media

Draft social content as markdown files in the host project, track each piece
from idea to published URL via frontmatter, and never auto-post. The human
publishes; the file records.

Templates are keyed by **artifact shape**, not platform — a Reel, a Short and a
TikTok are one artifact with three sets of numbers, as are an X post, a Bluesky
post and a Threads post. Copy a template, never edit it in place.

| The idea is… | Template | Typical channels |
| --- | --- | --- |
| a claim that fits in a breath, or a numbered spine of them | `assets/template.microblog.md` | X, Bluesky, Threads, Mastodon, LinkedIn |
| a whole argument or course that earns 1000+ words | `assets/template.article.md` | X article, LinkedIn article, own blog |
| something you have to *see* happen | `assets/template.short-video.md` | Reels, YouTube Shorts, TikTok |
| a nudge, a poll, or behind-the-scenes for people already following | `assets/template.story.md` | Instagram / Facebook stories |
| a sequence of points that reads better swiped than scrolled | `assets/template.carousel.md` | Instagram carousel, LinkedIn document post, X image set |

One idea going to several channels at once uses
`assets/template.microblog.multi.md` instead — same artifact shape, but the body
holds a finished variant per channel rather than a single text. See § Variant
sections.

`platforms.md` holds the per-platform numbers — character and caption limits,
link and hashtag behavior, durations, aspect ratios, alt-text limits. Read it
when choosing channels and before writing to a budget.

`README.md` records the real posts these templates are modeled on, which
templates are grounded in a read exemplar and which are not, and the three forms
an idea takes (standalone article, post funneling to your own article, post
framing someone else's longform) — read it when revising a template or deciding
which form an idea wants.

## Where drafts live

**If the content has a canonical publication behind it — a blog post, paper or
talk — the `publication` skill owns it.** The draft belongs in that piece's
`syndication/` directory and its schedule and posted URL are tracked in the
publication's frontmatter, not here. This skill still writes the copy; it just
doesn't own the record. Never syndicate before the canonical has a live URL.

**If the canonical is a project's own site rather than a vault publication —
a marketing-site post, a changelog, a docs page — the record lives in that
project's repo, beside the content it announces.** Use
`docs/marketing/social/<post-slug>.md`, named after the piece rather than the
draft date, so the record and the post it points at are obviously the same
thing. Do not touch the piece's own frontmatter; the site owns that. The
canonical gate still applies in full: fetch the URL and confirm it returns
**200** before writing any `scheduled`, and never write `posted` on a piece
whose canonical is not live.

Two consequences worth stating, because both bite:

- The registry may live in a **different repo** from the record — a project's
  `socials.md` is often in a notes vault while its syndication files are in the
  code repo. Resolution crosses repos; say which file you used in `registry:`.
  An agent working only inside the code repo will otherwise conclude no registry
  exists and invent handles.
- Where the repo requires a branch and PR for every change, the `posted:`
  writeback needs its own short-lived PR, so **the record can lag the post by a
  merge**. Put the live URLs in the session output too — a stalled PR must not
  be the only place they exist.

Use the standalone layout below only for content with no canonical behind it.

This skill is project-agnostic — run it from any repo or notes directory. Find
the posts directory in this order:

1. The host project's own instructions (`AGENTS.md` / `CLAUDE.md`) naming a
   social/posts location.
2. An existing directory of drafts using this frontmatter (look for `posted:`).
3. Otherwise create `docs/marketing/posts/` and say so. That puts the drafts
   beside `docs/marketing/socials.md`, the account registry owned by the
   `social-accounts` skill. An older project may still use `social/` at the
   root; leave it where it is rather than moving live drafts.

Name files `YYYY-MM-DD-<slug>.md` (date the draft was started). Formats with
media get a sibling directory `YYYY-MM-DD-<slug>/` for footage and images,
pointed at by the `media:` field.

## Frontmatter contract

Every draft carries this frontmatter; it is the tracking system — no separate
index to maintain:

```yaml
---
title: Short working title
kind: microblog     # microblog | article | short-video | story | carousel
platform: x
scheduled: null     # ISO 8601 datetime it should go out, or null (unplanned)
posted: null        # null until live, then the URL of the published post
media: null         # optional: asset directory, for video/image formats
---
```

When one idea goes to several channels, replace `platform:` with a `channels:`
list carrying its own `scheduled` and `posted` per destination:

```yaml
---
title: What a kilogram of blueberries costs on the Moon
kind: microblog
source: code/apps/marketing-site/src/content/posts/public/2026-08-04-what-a-kilogram-of-blueberries-costs.md
canonical: https://artera.space/posts/2026-08-04-what-a-kilogram-of-blueberries-costs/
registry: ~/notes/wiki/projects/artera/socials.md
channels:
  - platform: x
    handle: arteraspace
    kind: microblog
    scheduled: 2026-08-06T09:00:00-05:00
    posted: null
    posted_at: null
  - platform: bluesky
    handle: artera.space
    kind: microblog
    scheduled: 2026-08-06T09:00:00-05:00
    posted: null
    posted_at: null
---
```

Both forms are valid; use the flat one for single-destination drafts.

`source:` is the piece this syndicates (repo-relative path, or the publication
directory); `canonical:` is its live URL; `registry:` is the `socials.md` the
handles were resolved against. All three are optional on a draft with no
canonical behind it, and all three are what make the record checkable later
without guessing.

**`(platform, handle, kind)` is unique within a file**, and `handle` is
**required** in the `channels:` form — not "required when ambiguous". A
conditional requirement produces records that are correct today and ambiguous
the day a second account is claimed on the same platform, which is a day that
arrives without warning. The flat single-target form keeps `handle` optional.

That triple is also why the list is a list and not a map keyed by platform. A
platform-keyed map cannot hold two accounts on one platform (an entity may own
two Instagram accounts), nor two artifacts on one platform (an X thread *and* an
X article for the same piece). Both are ordinary, and a map loses one silently.

`posted_at` is the timestamp; `posted` is the URL. The `publication` skill
carries both and the two files describing one post should not disagree.

The lifecycle is readable from two fields: `posted: null` + `scheduled: null`
is an idea; `posted: null` + a future `scheduled` is queued; `posted: null` +
a past `scheduled` is **overdue**; a URL in `posted` is done. When asked
"what's due" or "what's unposted", grep the drafts directory for
`posted: null` and compare `scheduled` against today. A `channels:` draft is
done only when no `posted: null` remains in it — partially posted (live on X,
still queued for Bluesky) is a real and normal state.

### Which account it posts from

`platform:` names a network, not an identity. Before scheduling, resolve it
against the entity's `socials.md` (the `social-accounts` skill; usually
`docs/marketing/socials.md`, or `wiki/socials.md` in a notes vault) and confirm
the account is `owned` — a draft queued for a handle nobody controls is a draft
that can never go out. Where the registry lists two `owned` accounts on one
platform, the draft must carry the handle too, not just the platform. If no
registry exists, say so and offer to build one rather than assuming the account.

Check for `owned` **specifically**, not for the absence of a problem. The other
statuses are load-bearing and they mean different things: `declined` is a
decision not to be on that platform, `unverified` is a row nobody has confirmed,
and `reserved` is a name held with no surface to post to. One entity may decline
a platform another entity owns — the same person's personal registry and their
company's registry routinely disagree — so "post everywhere" resolved against
the wrong file queues a channel that was deliberately skipped.

## Variant sections

A `channels:` draft carries **one section per channel, each holding finished
copy** — not one body plus notes about what changes. Notes about what changes
are not postable, and the moment there are five destinations somebody has to
turn them into five texts anyway, usually in the composer, unreviewed.

````markdown
## Claim

One sentence. Every variant asserts this and nothing stronger.

Numbers — verbatim wherever they appear at all:

- `$770,000` — floor, delivered cost per kg to the lunar surface
- `at least` — the hedge is part of the claim; never drop it

## x · arteraspace · microblog

### 1/3

```text
Delivering a kilogram of freeze-dried blueberries to the lunar surface costs
at least $770,000. The food is a rounding error. The freight is the product.
```
<!-- 148/280 -->

### 2/3

```text
...
```
<!-- 203/280 -->

## linkedin · artera-space · microblog

```text
[one block, nothing to strip]
```
<!-- 1,240/3,000 -->
````

Four rules, and what each is for:

1. **`## Claim` is a section, not a comment**, and carries a `Numbers:` list of
   exact strings. This makes drift *checkable* rather than merely visible: every
   variant either omits a string or contains it **verbatim**. `$770k` or
   `~$800,000` is then a diff, not a style choice. Five versions of one number
   across five platforms is the failure this format exists to catch.
2. **Every post unit is a fenced ` ```text ` block, and nothing outside a fence
   is ever copy.** That is the pasteability guarantee — there is no marker to
   strip and no ambiguity about where the post starts. A fence survives copy that
   legitimately contains `—`, `#`, or `1/`; a separator convention does not.
3. **A thread is consecutive fences under `### n/N`; a single-block variant is
   one fence with no `###`.** One shape covers both, with no mode flag in
   frontmatter. The `1/` marker lives *outside* the fence, so it can only reach
   the posted text if someone deliberately typed it inside — which is exactly the
   artifact "Adapting one idea across channels" warns about, now structurally
   hard to do by accident.
4. **The heading is `## <platform> · <handle> · <kind>`** — the uniqueness
   triple, in the same order as the frontmatter keys. The mapping from section to
   `channels:` entry is then unambiguous by construction, including two accounts
   on one platform (`## instagram · ncrmro · story` beside
   `## instagram · armchair.chef · story`). Write the handle **verbatim from the
   registry, with no `@` prefix**: LinkedIn's handle is `artera-space` under a
   `company/` URL, and `@artera-space` would be an identity that does not exist.

Record the character count in a trailing `<!-- n/limit -->` comment as you write,
not at review time. A variant that is 40 characters over is a rewrite, and
finding that out after five are drafted means rewriting the claim, not the
variant.

## Check the surface before you draft

If the piece depends on something the target surface may not render — monospace,
code blocks, aligned ASCII, tables, wide images — confirm the surface supports it
**before** writing, not after. `platforms.md` § Rendering capabilities, and the
per-platform file in `references/`, answer this in a minute.

Getting it wrong is expensive and quiet: X strips monospace but preserves
newlines, so a pasted ASCII diagram looks nearly right while its alignment is
destroyed. A surface that can't render the artifact changes the draft — the
diagram becomes a planned image with alt text, in the outline, from the start.

Check the surface's capabilities each time rather than trusting the last
answer — these editors gain block types, and a draft written against a stale
assumption specifies screenshots for things that should be native blocks. When
the surface does have a block that holds the content, use it: **copyable beats
pretty**, and an image nobody can select is a downgrade whenever the content is
text someone would paste.

## Workflow

1. **Draft** — pick the template from the table above, copy it into the posts
   directory and fill it in. The templates carry the hook-first structure; keep
   their section comments while drafting, delete them before scheduling.
2. **Render the stills** — produce every image the draft plans: code and diagram
   cards, covers, carousel slides. `references/rendering-images.md` has the
   headless-Chromium method and the house look. Do this as part of drafting, not
   at publish time; a `<!-- IMAGE -->` note left in a finished draft is what
   blocks it weeks later. Then replace the note with the real filename,
   dimensions, and alt text. (Video and photography are a handoff, below — this
   step is stills you can render.)
3. **Review** — run the `prose-reviewer` skill on the draft before it's
   queued, including captions and on-screen text. Social copy is the most
   outward-facing prose there is, and AI tells in a post get called out
   publicly.
4. **Schedule** — set `scheduled`. Convert relative asks ("tomorrow morning")
   to absolute ISO 8601 with the local offset.
5. **Publish** — the user posts it themselves; publishing is never done by this
   skill. After they post, set `posted` to the live URL. If asked to help
   publish, the most this skill does is load the draft into the compose page and
   leave the user to submit.

   **The markdown file is canonical; the composer is a render target.** Never
   patch a live draft to match an edited file — delete the draft, make a new one,
   and load it once. Re-rendering is slower per round and the only version that
   stays correct; in-place edits silently duplicate and corrupt content. Read the
   platform's file in `references/` before touching its editor, and always verify
   by reloading the draft, never by reading the live page.

## Adapting one idea across channels

Reuse the **claim**. Rewrite the hook, the CTA, and anything platform-shaped.
Pasting one text into five boxes reads as imported everywhere and native
nowhere.

**When someone asks for a post to go out "uniformly", that means the same claim
and the same link at the same time. It never means the same text.** Say so
plainly if the ask is ambiguous — the multi-variant format is easy to fill with
five copies of one paragraph, which is precisely the thing it was built to
prevent. Use `assets/template.microblog.multi.md`.

- Write to the tightest limit in the target set (`platforms.md`), or create
  separate versions when the shorter draft would underserve the roomier
  channels.
- Strip artifacts that don't belong: `1/` numbering on channels that post as a
  single block, "link in bio" where links are clickable, another platform's
  watermark on a re-uploaded video.
- When a post and an article are the same idea at two resolutions, the post's
  job is the hook and the funnel — it should not try to teach the whole thing
  (see `README.md`, exemplar 2).
- A story is not a smaller Reel. It reaches existing followers only, so it
  supports a launch rather than carrying one.

## Media handoff

This skill renders its own **stills** — code cards, diagram cards, covers,
carousel slides — per `references/rendering-images.md`. Anything that must be
*shot* or *cut* is a brief, never media this skill makes: photography, screen
capture, and video. The short-video, story and carousel templates specify what to
shoot, what the beats are, and what the edit must preserve. Production belongs to
the skills that already do it:

- `obs-recording` — capture.
- `media-editor` — transcription, transcript-driven cuts, subtitles, export.
  The timestamped beat table in `template.short-video.md` is written to feed its
  edit plan directly.

Don't introduce new video or image tooling here.

## Boundaries

- Never set `posted` to anything but a real URL the user provides or confirms.
- **Never re-post a channel whose `posted:` is already set.** That field is the
  send-log, and the check is cheap: read it before opening any composer. Nothing
  in a draft distinguishes "posted once" from "about to be posted again", so the
  field is the only guard, and a duplicate post cannot be un-sent.
- Never write `posted` for a piece whose `canonical:` does not return 200. A
  variant that points at a 404 is worse than an unposted one.
- Don't invent engagement claims, follower counts, or "as promised in my last
  post" continuity the drafts directory doesn't show.
- When adapting prose the user has already written or published, their
  punctuation and phrasing are the content. Read the source first and preserve
  it; a colon they chose is not an em dash you prefer. Rewrite only what the new
  surface actually forces.
- Ghostwriting in the user's first person carries their authority. Every claim of
  personal experience must be traceable to something they wrote or did — no
  invented numbers, durations, or war stories, and no roadmap voice over work
  that is days old.
- Alt text is required on every image and carousel slide before scheduling, and
  burned-in subtitles on every short video. Not optional, not a follow-up task.
- Don't post on the user's behalf — load the composer, verify it, and stop at
  the button. The only exception is an explicit go-ahead from the user in this
  session, for this piece; act on that and nothing looser. Approval to publish
  one target is not approval for the next, and an earlier session's yes does not
  carry over. After posting, read the real URL and timestamp off the live page.
- One piece of content per file; a thread is one file, a carousel is one file, a
  story sequence is one file.
