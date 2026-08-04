---
name: publication
description: Write and publish blog posts, papers and talks canonical-first — the piece lives in the notes vault, publishes to your own site first, then syndicates everywhere else with per-target scheduling and posted-URL tracking. Use when drafting or scheduling a post or paper, recording that something went live, deciding where a piece should be published, or wiring a vault-to-site publishing pipeline.
---

# Publication

One idea, one directory, one canonical URL. The vault is where a piece is
written and tracked; your own site is where it lives; every other platform gets
a copy or an adaptation that points home.

Writing the social adaptations is the `social-media` skill's job — this skill
owns the canonical artifact, the schedule, and the record of what went where.

## The rule everything else serves

**Your site publishes first, and nothing else may be marked posted until it has
a live URL.**

Publishing on your site first gives every later adaptation a live home URL and
keeps the publication record unambiguous. The order is not a preference; it is
the reason the pipeline exists.

This is a hard gate. While `canonical:` is null, every `syndication[].posted`
stays null. An agent must refuse to record a syndication `posted` whose
canonical is unset.

**Missing is not the same as null.** A piece that predates this pipeline — or
was imported from the site rather than drafted here — often has `published: true`
and no `canonical:` key at all, while the post has been live for months. The gate
is about *the canonical not existing*, not about the field being unfilled, so
treat an absent key as unverified rather than as a refusal:

1. Derive the URL from the slug (`/posts/<slug>/`, date prefix stripped).
2. `curl -s -o /dev/null -w "%{http_code}"` it. A 200 means the canonical
   shipped; the record was just never written.
3. Write it into `canonical:` and continue. Anything other than 200 means the
   piece genuinely is not live — then the gate is real and stands.

Backfilling a verified URL is not the same as inventing one, and it is the fix
whenever the gate blocks a piece that is demonstrably published. Never skip
step 2: an assumed URL in `canonical:` corrupts the record the gate protects.

## Where publications live

**Always `~/notes/publications/`.** There is no other location and nothing to
resolve — not the current repo, not a project directory, not wherever the
session happens to be running. A piece drafted while working in a code repo
still gets written to `~/notes/publications/`; say the absolute path when you
create it. Create the directory if it doesn't exist yet.

One directory per piece, dated by first draft:

```text
~/notes/publications/YYYY-MM-DD-<slug>/
  index.mdx              # frontmatter + the canonical body
  media/                 # images, video, diagrams — referenced by the body
  syndication/           # one file per syndicated version
    x-article.md
    x-thread.md
    linkedin-post.md
    bluesky.md
```

This matches how the vault already stores research spikes and source packages —
a dated directory holding everything about one thing — so a publication is
greppable, movable, and archivable as a unit.

The site repo is a *render target*, not a second home. Never draft there and
never edit a piece there — every post's canonical file is its vault directory,
and **`publications/sync-posts.sh` is the only path from vault to site**:

| vault | destination |
| --- | --- |
| `publications/<date>-<slug>/index.mdx` | `docs/posts/<date>-<slug>.mdx` (repo root) |
| `publications/<date>-<slug>/media/*` | `r2://ncrmro-website-uploads/posts/<slug>/media/*` |

Site filenames keep the full `<date>-<slug>` name, mirroring the vault
directory one-to-one; the site's routes strip the date prefix from the URL
(`src/lib/posts.ts` `postSlug()`), so `/posts/<slug>/` is date-free and stable.
Posts sit at the *repository root* in `docs/posts/`, outside the Astro app —
they are documents the site renders, not app source.

**Keep the body portable.** A piece's `index.mdx` is the canonical file and
must not depend on the site repo's layout: no `import` statements, no
`client:*` directives. Where a piece needs a component, write the bare tag
(`<ApolloReplayMap />`) and let the site inject it through Astro's documented
`<Content components={{ … }} />`; a framework island gets an `.astro` wrapper
in the site that owns its client directive. An import in an MDX body is the
one thing that breaks the vault-is-canonical property.

`sync-posts.sh` transforms on the way across:

- passes frontmatter through as-is — the vault-side keys (below) reach the
  site repo, where the collection schema ignores what it doesn't model and may
  grow to use them (e.g. `canonical` for a `rel=canonical` tag);
- stamps `draft: true` on any piece whose `published` is not `true`, so
  unpublished pieces still sync — they land as drafts, invisible in every
  public listing and reachable only at `/drafts/<slug>` behind the admin
  session. Publishing is therefore: flip `published: true` in the vault, run
  the script again;
- writes only real changes, reports site orphans (blog files with no vault
  directory) without deleting them, and commits and pushes directly to `main`
  (`content: sync publications from vault`).

Run `./sync-posts.sh --dry-run` before a real run; it also takes a single
piece-directory name. The site deploys from a push to `main` — GitHub Actions →
Cloudflare — so a sync of a published piece is a live post, and "pushed" is not
the same as "deployed": confirm the URL returns 200 before recording it as
`canonical`.

Note the two repos sit on different forges — the vault on Forgejo, the site on
GitHub — so any automated crossing needs a GitHub credential.

### The site checkout the script pushes through

`sync-posts.sh` writes into `~/notes/.repos/ncrmro/website` — a sparse,
blobless checkout of `ncrmro/website` on `main` containing the site source
(`lfs.fetchexclude=*` keeps legacy images out). `~/notes/posts` symlinks to its
blog directory for direct inspection. `/.repos/` and `/posts` are gitignored by
the vault (and `.repos` is in Obsidian's `userIgnoreFilters`), so nothing about
this crosses into the public Forgejo repo. Edits belong in `publications/`,
never in the checkout — the script overwrites blog files wholesale from the
vault on every sync.

`.repos/<owner>/<repo>` is the pattern for any other repo the vault needs to
reach into: sparse-checkout what you want visible, symlink it flat at the vault
root, gitignore both.

### Media lives in the vault, not the site repo

The site repo carries no images for new pieces. Media goes in the vault's
`media/` directory and `publications/sync-media.sh` uploads it to the R2 bucket
`ncrmro-website-uploads`, which is served publicly at `r2.ncrmro.com`:

```text
publications/2026-07-29-my-slug/media/diagram.png
  → https://r2.ncrmro.com/posts/my-slug/media/diagram.png
```

Reference that absolute URL from the body. Run `./sync-media.sh --dry-run`
first; the script takes an optional piece directory to sync just one. Media
already under `code/web/public/posts/` predates this and stays in Git LFS.

## Frontmatter contract

```yaml
---
# --- site schema: modeled by the site's collection ---
title: Projected git graph planning
description: One sentence. Becomes the meta description and the card subtitle.
publish_date: 2026-08-02        # the date displayed on the piece
published: false                # flipped true when the piece goes live
tags: [git, agents]

# --- vault-side: synced through as-is; the site schema ignores what it
# doesn't model, and edits happen only here ---
kind: post                      # post | paper | talk | note
publish_at: 2026-08-02T09:00:00-05:00   # when to go live; null = unscheduled
canonical: null                 # the live URL. The gate for everything below.

syndication:
  - platform: x                  # the destination network
    kind: article                # the artifact shape, per the social-media skill
    draft: syndication/2026-08-02-x-article.md
    scheduled: null              # when it should go out; null = unplanned
    posted: null                 # the live URL once posted
    posted_at: null              # ISO timestamp of posting, local offset
  - platform: linkedin
    kind: post
    draft: syndication/2026-08-02-linkedin-post.md
    scheduled: null
    posted: null
    posted_at: null
---
```

`platform` + `kind` rather than one composite `target`, and `scheduled` rather
than `publish_at`, so a syndication entry matches the `social-media` draft it
points at — that skill's frontmatter uses the same three names, and the two
files describing one post should not disagree about what to call things.
`publish_at` stays reserved for the canonical, where it triggers the site
publish; a syndication entry never carries it.

Three fields carry three different meanings, and conflating them is the common
mistake:

| field | means |
| --- | --- |
| `publish_date` | the date shown to a reader — display only |
| `publish_at` | when the piece should go live — the scheduling intent |
| `published` | whether it is live — state, flipped when it ships |

The lifecycle is readable from the file alone. `publish_at: null` is an idea;
a future `publish_at` with `published: false` is queued; a past `publish_at`
still unpublished is **overdue**; `canonical` holding a URL means the canonical
shipped and syndication is unblocked; a syndication entry with `posted` set is
done. Partially syndicated — canonical live, two targets posted, one still
queued — is a normal state, not an error.

**Frontmatter syncs in full.** The site's collection schema models the fields it
renders and ignores the rest. Scheduling and syndication state therefore travel
with the site copy but remain editable only in the vault; every sync overwrites
the site copy. The site may start reading the extra keys (e.g. `canonical` →
`rel=canonical`); that is a site schema change, not a pipeline change.

## Kinds

`kind:` distinguishes the type without needing separate pipelines: `post`,
`paper`, `talk`, `note`. Same directory layout, same frontmatter, same sync;
templates and listings filter on it. Reach for a separate site collection only
when a kind needs fields the others don't (a paper's authors, abstract, DOI) —
that's a change in the site repo, not here.

## Workflow

1. **Draft** — create the directory, copy `assets/index.template.mdx` to
   `index.mdx`, write the piece. Media goes in `media/` from the start, with
   alt text; don't leave it to publication time. Running `sync-posts.sh` at
   this stage is fine and normal: the piece lands on the site as a draft
   (`draft: true` stamped in transit), previewable at `/drafts/<slug>` behind
   the admin session.
2. **Schedule** — set `publish_at`. Convert relative asks ("Tuesday morning")
   to absolute ISO 8601 with the local offset. Leave `published: false`.
3. **Publish the canonical** — at `publish_at`, flip `published: true` in the
   vault and run `publications/sync-posts.sh` (media first via
   `sync-media.sh` if any). The push to `main` deploys. Confirm the URL
   returns 200, then record it in `canonical:`. **Nothing may be syndicated
   before this field is set.**
4. **Let it index** — days, not hours, before syndicating full text. Confirm
   with a `site:` search. This is a recommended wait, not an enforced one; it
   cannot be reliably automated.
5. **Syndicate** — write each version with the `social-media` skill (its
   templates are keyed by artifact shape, and its per-platform references cover
   the composers), store them under `syndication/`, and give each a `scheduled`.
   Load the composer, verify it, and stop at the button: the user posts.
6. **Record** — when a target goes live, set its `posted` to the real URL and
   `posted_at` to the timestamp. Never invent either — read both off the live
   page after posting, not off the composer you just drove. A composer's own DOM
   will report success over a document the platform saved differently, and an ID
   you construct rather than fetch is a guess.

   Writing back into `index.mdx` has its own discipline, because a human edits
   the same file:

   - Re-read the file immediately before writing; never write from a copy read
     earlier in the session.
   - Touch only the fields you own — `published`, `canonical`, and each entry's
     `posted` / `posted_at`. Don't reflow the body, reorder keys, or rewrite what
     a human set.
   - This vault auto-commits and pushes every few minutes. On conflict, stop and
     surface it rather than forcing.

## Choosing targets

Not every channel deserves the full text. The distinction that matters is
whether a copy competes with your canonical in search:

| target | full text? | why |
| --- | --- | --- |
| your site | canonical | the only copy that builds your domain |
| platform-native longform on a poorly-indexed network | yes | in-feed reach, negligible search cost |
| a high-authority publishing network | prefer a summary + link | it can outrank you, and most disallow a canonical tag |
| microblogs | adaptation only | the format can't hold the piece anyway |

Check whether the target lets you set `rel=canonical`. Where it doesn't, prefer
an excerpt with a link and an "originally published at" credit.

## Boundaries

- **The canonical gate is not advisory.** Never record a syndication `posted`
  while `canonical` is null, and never reorder to "just get it out".
- Never set `canonical`, `posted` or `posted_at` to anything but a real URL and
  a real timestamp — one you fetched or the user confirmed. A publication record
  that contains a guess is worse than an empty one.
- Media that carries meaning needs alt text before `published` flips, not after.
- Deleting or rewriting a published piece changes a URL other people may link
  to. Prefer an addendum; if it must change, keep the slug.
- **The user publishes.** Prepare the piece, verify it, and stop at the button.
  Posting under someone's identity is theirs to trigger, per target, per
  session — an approval to publish the canonical is not an approval to
  syndicate, and yesterday's yes does not carry to today.
