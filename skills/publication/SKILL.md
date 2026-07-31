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
stays null. A publisher job must refuse to act on a syndication target whose
canonical is unset, and an agent must refuse to record one.

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
published: false                # flipped true by the publisher at publish_at
tags: [git, agents]

# --- vault-side: synced through as-is; the site schema ignores what it
# doesn't model, and edits happen only here ---
kind: post                      # post | paper | talk | note
publish_at: 2026-08-02T09:00:00-05:00   # when to go live; null = unscheduled
canonical: null                 # the live URL. The gate for everything below.

syndication:
  - target: x-article
    draft: syndication/x-article.md
    publish_at: 2026-08-02T15:00:00-05:00
    posted: null                # the live URL once posted
    posted_at: null             # ISO timestamp of posting
  - target: linkedin-post
    draft: syndication/linkedin-post.md
    publish_at: null
    posted: null
    posted_at: null
---
```

Three fields carry three different meanings, and conflating them is the common
mistake:

| field | means |
| --- | --- |
| `publish_date` | the date shown to a reader — display only |
| `publish_at` | when the publisher should act — the scheduling trigger |
| `published` | whether it is live — state, flipped by the publisher |

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
   the composers), store them under `syndication/`, and give each a
   `publish_at`.
6. **Record** — when a target goes live, set its `posted` to the real URL and
   `posted_at` to the timestamp. Never invent either.

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

## Automation

A publisher job can run this on a schedule. Its selection rules:

- **Canonical:** `publish_at <= now AND published == false` → flip, sync, deploy.
- **Syndication:** `canonical != null AND entry.publish_at <= now AND
  entry.posted == null` → post it, then write back `posted` and `posted_at`.

`references/automation.md` has the full job spec, the required safeguards, and
the writeback protocol. Read it before building or changing the runner.

## Boundaries

- **The canonical gate is not advisory.** Never record a syndication `posted`
  while `canonical` is null, and never reorder to "just get it out".
- Never set `canonical`, `posted` or `posted_at` to anything but a real URL and
  a real timestamp — one you fetched or the user confirmed. A publication record
  that contains a guess is worse than an empty one.
- Media that carries meaning needs alt text before `published` flips, not after.
- Deleting or rewriting a published piece changes a URL other people may link
  to. Prefer an addendum; if it must change, keep the slug.
- An automated publisher acts on the user's behalf under their identity. It
  requires their explicit standing authorization, honours the kill switch
  immediately, and stops on the first error rather than continuing down the
  list.
