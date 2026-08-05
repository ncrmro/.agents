---
name: social-accounts
description: Build and maintain the account registry for a project, org or person — a socials.md recording which social handles and channels you own, which are held by someone else, which are still free, and which you deliberately skipped — and drive a browser to check handle availability against the live signup forms and to claim and set up the accounts. Use when asked what accounts a project has, before drafting or posting (to resolve a platform to a real handle), when claiming or renaming a handle, when a desired name is taken and you need available alternatives, or when filling in profile bios, links and avatars.
---

# Social accounts

One file per entity records the identities it owns. `social-media` writes the
copy and `publication` owns the canonical piece; this skill answers the question
both of them assume: **which account does `platform: x` actually mean here, and
do we control it?**

The registry is built and maintained through a **browser**. HTTP probes are a
pre-filter, nothing more — on the platforms that matter most they are worthless,
and no HTTP request can create an account or set a bio. Read
`references/checking.md` before checking and `references/claiming.md` before
claiming.

## The trap that wastes an afternoon

**Every check is conclusive in one direction only, and the two directions need
different surfaces.**

| To prove | You need | Because |
| --- | --- | --- |
| `unavailable` | the profile URL, in a logged-in browser | a page that renders settles it, and shows who holds it |
| `available` | the **signup validator** | it is the code that will accept or reject the claim |
| `owned` | a **login** | nothing weaker distinguishes your account from a stranger's |

The failure that looks most like success: **a 404 is not availability.** A
username can be unreachable and unregistrable at the same time — deactivated and
disabled accounts keep their handles, and platforms reserve names for brands,
trademarks and banned words. All of those 404.

This has now been got wrong in both directions on the same day. First `curl`
reported `instagram.com/artera` taken (its `200` is a JS shell, not a page);
then a logged-in profile load reported it free; then the actual Instagram signup
form said **not available**. Only the third surface was answering the question.

So: load profile URLs first, because it is cheap and it eliminates most
candidates. But a 404 promotes a candidate to *worth confirming*, and the row
stays `unverified` until a validator accepts it. `references/checking.md` has
the per-platform strings and surfaces.

## Browser tooling

Three tools, three jobs. Picking wrong is the difference between a conclusive
answer and a plausible one:

| Job | Tool | Why |
| --- | --- | --- |
| Ruling names **out**, and seeing who holds them | **Claude in Chrome** | The user's session strips the authwall, so the profile URL answers directly — and only a logged-in view shows Subscribe/Follow versus Edit profile. |
| Confirming a survivor is actually **claimable** | **Playwright MCP**, isolated/logged-out | The signup validator is the only surface that answers this, and it behaves differently when a session already exists. **Required** before any row reads `available`. |
| Claiming, setting bios, avatars and links | **Claude in Chrome** | Needs their real session, their password manager, and their email or SMS for verification. |
| A first cheap pass over many candidates | `curl` | Cuts obviously-taken names on GitHub, Bluesky and YouTube. Never proves availability anywhere. |

Do not drive a signup or a profile edit from an isolated Playwright context: the
account would be created against a throwaway session and a credential store the
user does not have — which is worse than not creating it, because the name is
now gone. See `~/.agents/skills/browser-mcp/SKILL.md` for the operational rules
on both servers — in particular that a headful launch silently runs headless
without the display env, which on a signup flow means a CAPTCHA the user can
never see and a run that hangs with no visible cause.

## Where the registry lives

Resolve in this order and say which one you used:

1. A location named by the host project's `AGENTS.md` / `CLAUDE.md`.
2. An existing file with this skill's frontmatter (grep for `accounts:` beside
   `status:`) — never create a second registry for one entity.
3. In a code repo: **`docs/marketing/socials.md`**.
4. In a notes vault: `wiki/projects/<slug>/socials.md` for a project,
   `wiki/socials.md` for the person who owns the vault.

`docs/marketing/` is the shared marketing root, so the registry and the drafts
that depend on it sit together:

```text
docs/marketing/
  socials.md      # this skill — who we are, per platform
  posts/          # social-media drafts (YYYY-MM-DD-<slug>.md)
```

An entity may be a project, an org, or a person, and the three do not nest. A
person's registry and a project's registry are separate files even when the same
human logs into both. Cross-reference them; do not merge them.

## Frontmatter contract

The frontmatter is the machine-readable half — a drafting agent reads it to
resolve a platform to a handle without parsing prose:

```yaml
---
generated: true
updated: 2026-08-04          # whenever any row changes
entity: artera               # the thing this registry covers
kind: project                # project | org | person
canonical_url: https://artera.space
tags: [meta, publishing]     # vault pages only

accounts:
  - platform: x              # same vocabulary as social-media / publication
    handle: arteraspace      # no leading @
    url: https://x.com/arteraspace
    status: available
    verified: 2026-08-04     # the date of the last real check — required
    method: signup-form      # how it was checked — see below
    channels: [microblog, article]
    credentials: null        # password-manager entry NAME, never a secret
    held_by: null            # who has it, when status is unavailable
---
```

### Status vocabulary

Six values, and the distinctions between them are the point of the file:

| status | means |
| --- | --- |
| `owned` | we control it and can log in |
| `reserved` | registered only to hold the name; nothing is published there |
| `available` | a signup validator accepted it as of `verified`, and we may want it |
| `unavailable` | someone else holds it — `held_by` says who |
| `declined` | gettable, deliberately not pursued — the reason is required |
| `unverified` | never checked, or the check was not trustworthy |

`declined` is what stops the same question being re-asked every quarter. Write
the reason, not just the status.

A `verified` date older than **90 days** demotes `available` to `unverified` on
sight — an available name is the one fact another party can invalidate without
warning. `owned` and `declined` do not decay.

### Method vocabulary

`method:` records what the check actually was, so a later agent can tell a
conclusive row from a hopeful one without re-doing the work:

| method | strength |
| --- | --- |
| `login` | **the only method that may write `owned`** |
| `signup-form` | **the only method that may write `available`** — the validator accepted it, *and* both session controls behaved (`references/checking.md`) |
| `browser` | a profile read in a logged-in browser. May write `unavailable` outright; a 404 leaves the row `unverified` |
| `api` | a public identity API (GitHub, Bluesky). Same asymmetry as `browser` |
| `http-probe` | pre-filter only; name the signal (`http-404`, `title`) |
| `none` | not checked — say why |

A row whose `method` cannot support its `status` is a bug. `status: available`
with `method: browser` is the specific error to look for: it means a 404 was
read as an answer.

### Accounts, not channels

Key the registry on the **account you log into**, and list the surfaces it
publishes to in `channels:`. Some platforms have no independent identity, which
changes what claiming even means:

| you register | you get |
| --- | --- |
| an Instagram account | feed, Reels, Stories — **and the Threads handle**, which cannot be registered separately but is *not* created automatically: the profile must be opted into. Owning the Instagram account reserves the name; it does not claim the surface. |
| a Google account | the YouTube channel, and Shorts on it |
| a Meta Business asset | a Facebook Page paired to the Instagram account |
| a LinkedIn **page** | company posts, articles, document posts — and it requires a personal profile to create it |
| a domain | a Bluesky handle, and a Mastodon instance if you host one |

**Decide the constraining platform first.** One platform in the set is usually
both the hardest to get a name on and the one that silently settles another
channel — Instagram is the common case, since it is heavily squatted *and* it
issues the Threads handle, which cannot be registered separately. Check it
first and let the rest of the set follow. Choosing a name that works everywhere
else and testing Instagram last is how a set gets re-decided from scratch.

Two accounts on one platform (a personal handle and a food handle, a company
page and a founder profile) are two rows with the same `platform` and different
`handle`. When that happens a draft must name the handle, not just the platform,
and this file is what makes the ambiguity visible.

`channels:` uses `social-media`'s artifact shapes — `microblog`, `article`,
`short-video`, `story`, `carousel` — so a draft of a given `kind` can be matched
to the accounts that can carry it.

## Body sections

`assets/socials.template.md` is the starting point. In order:

1. **Identity** — the canonical name, the domain, and the one-line bio that
   every profile is trimmed from. This is the source; per-profile bios are
   renderings of it.
2. **Shared avatar** — one mark on every platform, named here so no platform
   gets whatever was uploaded first. Record the *source file* (usually the
   site's `favicon.svg` or logo component), the brand colours as tokens, and the
   render sizes. Site marks are authored small: a 32×32 favicon must be
   **re-rendered at 1024×1024, never upscaled**. Every platform crops to a
   circle, so keep the glyph inside the safe area. Once a live account has an
   avatar, confirm it *is* this mark before copying it onward — an uploaded copy
   is not automatically canonical.
3. **Accounts** — one table: platform, handle, status, verified, channels.
4. **Per-account detail** — the live bio, the link in it, and any follower
   numbers as *dated approximations*. Say what a profile is missing.
5. **Contested names** — the desired handle, who holds it, and the ranked
   alternatives with their own status and date.
6. **Not pursued** — every `declined` row with its reason.
7. **Open actions** — what to claim, fix, or verify next.

## Workflow

1. **Scope** — name the entity and its kind. Find the domain first: it decides
   the handle candidates and on Bluesky it *is* the handle.
2. **Inventory what exists** — ask the user which accounts they already have
   before checking anything. No amount of browsing discovers an account you
   could have been told about, and a forgotten account is the most common
   `unverified` row. Where they are unsure, open the profile in Chrome with
   their session: if it loads as *yours*, that is a `login` and the row is
   `owned`.
3. **Check the charset rules before proposing anything** (`references/handles.md`).
   A hyphen is invalid on X, Instagram and TikTok, so a hyphenated candidate is
   dead on the three platforms that carry microblog and short-video no matter
   what any check says. Eliminating a name on the rules costs one lookup;
   eliminating it on the evidence costs a browser pass per platform.
4. **Rule names out** — `curl` first to cut obviously-taken names, then profile
   URLs in the user's Chrome. Anything whose profile renders is `unavailable`,
   done, with `held_by` filled in from the page.
5. **Confirm the survivors in the signup validators** (logged-out Playwright,
   or logged-in settings where the platform defers the username). This step is
   not optional: **until it runs, nothing may read `available`.** Record
   `method: signup-form` and today's date.
6. **Suggest alternatives** for anything `unavailable` — see below. Take each
   candidate through steps 3–5 on *every* target platform before proposing it.
7. **Confirm the handle with the user**, then **claim** the accounts they
   approve (`references/claiming.md`).
8. **Set each account up** — display name, bio, link, avatar. A claimed and
   empty account is worse than no account; the setup is part of claiming, not a
   follow-up.
9. **Write the file** with the new rows, then report what remains: names to
   claim, bios that disagree with the identity line, profiles with no link home.

Steps 7 and 8 are the outward-facing half. They create things that are hard to
undo, so the confirmation in step 6 is not optional — see Boundaries.

## When the name is taken

Consistency across platforms beats the best name on any one platform. A single
handle everywhere is a searchable identity; five clever ones are five strangers.
So choose the alternative that is free on *all* the platforms that matter, not
the best available on the most important one.

Ranked patterns, best first:

1. **The domain, as the handle.** `artera.space` → `arteraspace`. It matches
   what a reader already saw, and on Bluesky the domain *is* the handle, which
   no squatter can take.
2. **Name + category.** `arteraspace`, `arterafarms` — reads as intentional
   rather than as a second choice.
3. **Name + `hq` / `team` / `labs`.** Conventional for an org whose plain name
   is held by an unrelated company.
4. **Prefix `get` / `use`.** Product-shaped; weak for a research or mission
   entity.

Reject: trailing digits (`artera2`), doubled letters, underscores where the
platform allows dots, and anything that differs per platform without reason.
Separators are the most common source of an off-by-one handle in a printed URL.

Check the character rules first — `references/handles.md` holds the length and
charset limits, and X's 15-character ceiling eliminates candidates that pass
everywhere else.

## Boundaries

- **Never write `owned` from anything but a login.** If a profile exists at your
  name and you cannot tell whose it is, write `unverified` with a note saying it
  must be confirmed.
- **Never write `available` from a 404.** Only a signup validator can say a name
  is claimable; a missing profile page is a candidate, not an answer. Reporting
  a name as free and having the user discover otherwise at the signup form is
  the most expensive error this skill can make — it is acted on immediately.
- **Never write `available` from an unbracketed validator read.** A validator
  that answers before the server replies, or one that is rate-limited, produces
  confident results in both directions. Two controls per session or the results
  do not go in the file — see `references/checking.md`.
- **Say when your own data is void.** If a control fails, the honest report is
  "I have no reliable data", not a hedged list. A list of names presented with
  reasons reads as researched no matter how it is caveated, and the user will
  act on it.
- **Confirm the exact handle with the user before the first submit.** An account
  is outward-facing and effectively permanent: most platforms will not free a
  released handle, and several never let you rename. Approval for one handle on
  one platform is not approval for the rest of the set.
- **No credentials, ever, in the file.** `credentials:` holds the *name* of a
  password manager entry. No passwords, no tokens, no recovery codes, no TOTP
  seeds — not in the file, not in a sibling file, not "temporarily". Never print
  a credential into the transcript.
- **Hand the human steps to the human.** CAPTCHA, email and SMS codes, ID
  checks, payment, and phone verification are theirs. Never attempt to defeat a
  CAPTCHA or an anti-automation check; stop and ask.
- **One entity, real accounts, honestly presented.** Claim names for the user's
  own project, org or person. Do not register handles that impersonate somebody
  else or a company the user has no claim to, do not bulk-register names to
  hold or resell, and do not create additional accounts to appear to be more
  people than there are.
- Never delete or rename a live account, and never change a bio a human wrote
  without showing the new text and getting a yes.
- Don't invent follower counts, verification badges, or a launch date. An
  uncounted number is absent, not zero.
- A row without a `verified` date is `unverified`, whatever it says.
- Related skills: `social-media` writes the copy and owns `docs/marketing/posts/`;
  `publication` owns the canonical piece and its syndication record;
  `browser-mcp` owns browser server configuration; `wiki` owns note anatomy when
  the registry lives in a vault. This skill owns identity only.
