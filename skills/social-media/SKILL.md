---
name: social-media
description: Draft, schedule, and track social media content — X posts and longform X articles — as markdown files with scheduled/posted frontmatter. Use when writing a post or article, checking what's due to go out, or recording that something was published.
---

# Social media

Draft social content as markdown files in the host project, track each piece
from idea to published URL via frontmatter, and never auto-post. The human
publishes; the file records.

Templates (copy, never edit in place):

- `assets/template.x.post.md` — a short-form X post or thread.
- `assets/template.x.article.md` — a longform X article (course/roadmap style).

## Where drafts live

This skill is project-agnostic — run it from any repo or notes directory. Find
the posts directory in this order:

1. The host project's own instructions (`AGENTS.md` / `CLAUDE.md`) naming a
   social/posts location.
2. An existing directory of drafts using this frontmatter (look for `posted:`).
3. Otherwise create `social/` at the project root and say so.

Name files `YYYY-MM-DD-<slug>.md` (date the draft was started).

## Frontmatter contract

Every draft carries this frontmatter; it is the tracking system — no separate
index to maintain:

```yaml
---
title: Short working title
platform: x
kind: post          # post | article
scheduled: null     # ISO 8601 datetime it should go out, or null (unplanned)
posted: null        # null until live, then the URL of the published post
---
```

The lifecycle is readable from two fields: `posted: null` + `scheduled: null`
is an idea; `posted: null` + a future `scheduled` is queued; `posted: null` +
a past `scheduled` is **overdue**; a URL in `posted` is done. When asked
"what's due" or "what's unposted", grep the drafts directory for
`posted: null` and compare `scheduled` against today.

## Workflow

1. **Draft** — copy the right template into the posts directory and fill it
   in. The templates carry the hook-first structure; keep their section
   comments while drafting, delete them before scheduling.
2. **Review** — run the `prose-reviewer` skill on the draft before it's
   queued. Social copy is the most outward-facing prose there is, and AI
   tells in a post get called out publicly.
3. **Schedule** — set `scheduled`. Convert relative asks ("tomorrow morning")
   to absolute ISO 8601 with the local offset.
4. **Publish** — the user posts it themselves; publishing to X is never done
   by this skill. After they post, set `posted` to the live URL. If asked to
   help publish, the most this skill does is open the compose page and leave
   the user to submit.

## Boundaries

- Never set `posted` to anything but a real URL the user provides or confirms.
- Don't invent engagement claims, follower counts, or "as promised in my last
  post" continuity the drafts directory doesn't show.
- One piece of content per file; a thread is one file (the post template shows
  the thread form).
