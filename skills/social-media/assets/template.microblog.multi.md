---
title: Short working title
kind: microblog
source: null        # the piece this syndicates — repo path or publication dir
canonical: null     # its live URL. Fetch it and confirm 200 before scheduling.
registry: null      # the socials.md the handles below were resolved against
channels:
  # One entry per destination. (platform, handle, kind) is unique in this file
  # and MUST match a `## platform · handle · kind` heading below, exactly.
  # `handle` is required here — copy it verbatim from the registry, no @.
  - platform: x
    handle: null
    kind: microblog
    scheduled: null
    posted: null
    posted_at: null
  - platform: bluesky
    handle: null
    kind: microblog
    scheduled: null
    posted: null
    posted_at: null
---

## Claim

<!-- ONE sentence. The invariant. Every variant below asserts this and nothing
     stronger — a variant that promises more than the claim is the drift this
     section exists to catch. Write it before any variant. -->

[The claim]

<!-- Numbers: every figure, unit and hedge that must appear identically wherever
     it appears at all. Each variant either omits the string or contains it
     VERBATIM. Rounding a number to fit a limit is a rewrite of the claim, not a
     trim of the copy — cut a clause instead. Include hedges ("at least", "to
     date"): dropping one is how a careful claim becomes an overclaim. -->

Numbers — verbatim wherever they appear at all:

- `[exact string]` — [what it is, and its limits]

<!-- Delete this section only if the piece genuinely carries no figures. -->

<!-- ============================================================
     One section per channel below. Heading is:
         ## <platform> · <handle> · <kind>
     matching a channels: entry field-for-field, in that order.

     Every post unit is a fenced ```text block. NOTHING outside a fence is
     ever copy — no markers to strip, no ambiguity about where the post
     starts. Record the count in a trailing <!-- n/limit --> comment as you
     write, not at review time.

     Look limits up in platforms.md. Do not recall them.
     ============================================================ -->

## [platform] · [handle] · microblog

<!-- THREAD form: consecutive fences under ### n/N headings. Post 1 is the hook
     and must stand alone — assume most readers never expand. The last post
     carries the link. The `1/` marker lives OUTSIDE the fence so it can never
     be pasted into the post itself. -->

### 1/3

```text
[Hook post. The claim, sharpened. Not the title of the piece.]
```
<!-- n/limit -->

### 2/3

```text
[Evidence post. One concrete, verifiable thing, carrying its limits — what it
proves and what it does not claim.]
```
<!-- n/limit -->

### 3/3

```text
[Closing post with the canonical link.]
```
<!-- n/limit -->

## [platform] · [handle] · microblog

<!-- SINGLE-BLOCK form: exactly one fence, no ### headings. Used where the
     platform posts one block (LinkedIn, Mastodon, and any thread-capable
     platform where the idea fits in one). The first line is the whole hook —
     the feed truncates, and platforms.md says where. No `1/` numbering here,
     and no "link in bio" where links are clickable. -->

```text
[One block. Nothing to strip.]
```
<!-- n/limit -->

<!-- MEDIA: note any image or video per channel, WITH its alt text — required
     before scheduling, not a follow-up. Attach the same asset everywhere it
     appears; a different crop per platform is a rendering decision, not a
     different image. -->

<!-- BEFORE SCHEDULING:
     - every heading triple matches a channels: entry, and vice versa
     - every Numbers: string is verbatim-or-absent in each variant
     - every count is within its platform's limit
     - canonical: fetched and 200
     - each handle is `owned` in the registry (not reserved/declined/unverified)
     Delete these comments before the first post goes out. -->
