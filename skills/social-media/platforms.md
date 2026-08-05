# Platform constraints

Per-platform numbers for the format templates in `assets/`. The templates teach
*structure*; this file holds the *limits*. Read it when picking target channels,
before writing to a character budget, and before scheduling.

For the mechanics of getting a draft *into* a platform — what its editor
renders, how to load a draft, what breaks — see the per-platform reference:

| Platform | Reference |
| --- | --- |
| X — articles | [`references/x.md`](references/x.md) — verified |
| X, Bluesky, Threads, Mastodon, LinkedIn — posts and threads | [`references/microblog-composers.md`](references/microblog-composers.md) — **none verified yet** |
| Instagram, TikTok, YouTube | none yet |

Write one the first time you publish to a new surface. An absent file means
nobody has exercised that composer, not that it behaves like X's.

**verified: 2026-07-27** — these are working figures checked against third-party
references on that date, not an authoritative record of platform policy.
Unlinked values are provisional. Platform limits drift and aggregators
disagree, so re-check any limit that materially shapes a draft and update this
line.

## Microblog — `template.microblog.md`

| Platform | Post limit | Link handling | Thread mechanic | Alt text |
| --- | --- | --- | --- | --- |
| X | 280 chars free, 25,000 with Premium | URLs count as 23 chars regardless of length | native reply-chain; author numbering (`1/`) is convention, not required | ~1,000 chars (unverified) |
| Bluesky | 300 **graphemes** (visual characters, not bytes) | counted against the limit | native reply-chain | 2,000 chars (raised from 1,000) |
| Threads | 500 chars | counted against the limit | native reply-chain | supported, limit unverified |
| Mastodon | 500 chars default; instance-configurable | counted against the limit | native reply-chain | supported, limit unverified |
| LinkedIn | 3,000 chars | **contested** — see note below | no threading; long posts are one block | 300 chars |

Emojis count as 2 characters on X. LinkedIn folds at "see more" around 140–150
chars on mobile and 200–220 on desktop — write the hook to fit **140**.

**Outbound links, all platforms (checked 2026-07-29).** Whether a link costs
reach depends on whether the platform ranks posts at all:

| Platform | Link cost | Basis |
| --- | --- | --- |
| X | disputed; no published platform policy found | creator analytics and anecdotal reports conflict |
| LinkedIn | disputed; no published platform policy found | creator analytics and anecdotal reports conflict |
| Bluesky | none reported | Following feed is reverse-chronological — no ranker to demote |
| Mastodon | none possible | no ranking at all; reach is federation topology, not composition |
| YouTube | none; the belief is a documented misconception | ranking optimizes session contribution, not link presence |

No platform has published a policy demoting posts for containing a link. Treat
any percentage as folklore unless the platform stated it, and don't degrade a
post to dodge an effect you can't measure — bare link-drops underperform because
they're thin, which explains the observation without a link detector.

**LinkedIn specifics (contested).** Claims that in-body links reduce reach, and
that putting the link in the first comment avoids the penalty, are widespread
but disputed. LinkedIn has not published such a policy, and the reports come
from creator analytics rather than controlled research. Bare link-drops are also
thin posts, which confounds the claimed effect.

Don't contort for this. Write a post that stands alone and put the link in the
body. Treat any specific percentage as folklore unless it comes from LinkedIn.
LinkedIn *articles* and newsletters are native and carry no link penalty —
but they also can't set `rel=canonical`, which is the reason to avoid them for
syndicating something you published elsewhere first.

**Cross-posting:** write to the tightest limit among the target channels — 280
if X is in the set, 300 if it is Bluesky-and-up. Do not paste X thread numbering
into a single-post channel, and do not leave "link in bio" phrasing on platforms
where links are clickable.

### Hashtags

**Not verified against platform documentation.** These are working conventions,
and the *cultural* rows below are softer than the *mechanical* ones. The
mechanical rows are the ones that change what you write.

| Platform | Working norm | Why |
| --- | --- | --- |
| X | **0–1** | X's own communication has said tags are no longer needed for reach; piles read as spam |
| Bluesky | **1–3** | tags are real facets and feed into custom feeds, so they do discovery work |
| Threads | **1** — mechanical | the tag system takes a single topic tag per post; a second is not a style choice, it is unavailable |
| Mastodon | **2–5** — mechanical | there is no ranking algorithm at all, so tags and follows are the *only* discovery surface. A Mastodon post with no tag reaches your followers and nobody else |
| LinkedIn | **3–5** | conventional; effect on reach disputed like everything else on LinkedIn |

**Write multi-word Mastodon tags in CamelCase** — `#SpaceAgriculture`, not
`#spaceagriculture`. Screen readers pronounce a CamelCase tag as words and a
lowercase one as a single unintelligible run. This is an established
accessibility norm in the fediverse, not a preference, and it is noticed.

The asymmetry matters when adapting: the same post wants **zero** tags on X and
**several** on Mastodon. Hashtags are the one element you should expect to differ
most between variants, not least.

### Cadence

No best-time claims here — they are unmeasurable from this side and every
aggregator disagrees. Two things are worth writing down:

- **Stagger a multi-channel push across days, not minutes**, when the same link
  is going to every channel. Simultaneous identical-link posts across five
  accounts is a spam-shaped pattern, most visibly on LinkedIn and Threads.
- **A brand-new account is the fragile case.** Accounts with no posting history,
  no avatar and no bio are the ones platforms scrutinise. Finish the profiles
  first, then post; and do not make the first post from a new account a link-out
  to the same URL as four other new accounts on the same morning.

## Short vertical video — `template.short-video.md`

| Platform | Duration | Caption limit | Notes |
| --- | --- | --- | --- |
| Instagram Reels | 3s minimum; up to ~15–20 min by upload, but reach collapses past **180s** — treat 3 min as the real ceiling | 2,200 chars, first ~125 visible before "more" | 1:1 / 4:5 / 9:16 accepted, 9:16 (1080×1920) recommended |
| YouTube Shorts | up to 3 min (raised from 60s in Oct 2024) | — | square or vertical videos may qualify as Shorts |
| TikTok | 10 min recorded in-app; up to 60 min uploaded | **disputed**: sources report both 2,200 and 4,000 — write to 2,200 | only 1–2 lines show in-feed |

All three take the same 9:16 1080×1920 master. Keep text and faces out of the
top and bottom ~15% — every platform overlays UI chrome there, and the safe zone
differs per app.

## Story — `template.story.md`

| Platform | Frame length | Notes |
| --- | --- | --- |
| Instagram / Facebook Stories | up to 60s per video frame; static images display ~7s by default | 24h expiry; 9:16 full-bleed; stickers, polls and link stickers are the interaction surface |

Feed carousels cannot be posted as a Story. Anything meant to outlive 24h needs
a Highlight, which changes the writing — a highlighted frame has to stand alone
months later with no surrounding context.

## Carousel / image post — `template.carousel.md`

| Platform | Slides | Caption | Alt text |
| --- | --- | --- | --- |
| Instagram feed carousel | 2–20 (raised from 10) | 2,200 chars, first ~125 visible | 100 chars |
| LinkedIn document post | PDF-backed; per-slide cap unverified | 3,000 chars, folds at ~140 mobile | 300 chars |
| X image post | up to 4 images | as per microblog row | ~1,000 chars (unverified) |

Instagram carousel slides are 1:1 (1080×1080) or 4:5 (1080×1350); 4:5 takes more
vertical screen. Video clips inside a feed carousel cap at 60s each.

## Article — `template.article.md`

| Platform | Notes |
| --- | --- |
| X article | Premium-only; cover image 5:2; renders as a scrolling page. **No monospace or code block** — diagrams must be images (`references/x.md`) |
| LinkedIn article | separate surface from posts; no 3,000-char limit |
| Own blog | no constraints; the canonical home when the piece should outlive the platform |

## Rendering capabilities

Limits decide what fits; *rendering* decides what survives. Check this before
drafting anything whose meaning depends on alignment or formatting.

| Surface | Monospace / code | Consequence |
| --- | --- | --- |
| X article | no — forced proportional font; newlines survive, alignment does not | ASCII diagrams, aligned tables and code listings must be **images with alt text** |
| everything else | unverified | check before drafting, and record it here |

## Not covered

Long-form landscape YouTube (title, thumbnail, chapters, description, pinned
comment) has no template yet — see `README.md`.
