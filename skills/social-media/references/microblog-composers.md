# Microblog composers

Getting a drafted variant *into* the box, per platform, and reading the live URL
back out. Limits live in `platforms.md`; this file is mechanics.

**verified: nothing.** No section below has been exercised against a live
composer. Everything here is structure and expectation, not observation — the
same status `references/claiming.md` carried before its first real run. Treat
every step as a hypothesis, stamp each section with a date as it is actually
driven, and correct whatever turns out to be wrong. `references/x.md` is candid
that even X's *post* composer is unverified while its Article composer is not;
do not let one verified surface on a platform imply another.

An absent stamp means nobody has done it, not that it works.

## The shape of a posting pass

1. **Read the record first.** Any channel whose `posted:` is set is done —
   opening its composer at all is a chance to double-post. Confirm `canonical:`
   returns 200 before anything.
2. **`tabs_context_mcp` before touching a browser**, then one new tab per
   channel via `tabs_create_mcp`. Never reuse a tab ID from an earlier session
   and never commandeer a tab the user has something in.
3. **Paste the fence contents verbatim.** The file is the approved copy; the
   composer is a render target. An edit made in the box is an edit nobody
   reviewed and nobody has a copy of.
4. **Verify what the box actually holds** before submitting — read it back from
   the page, not from what was typed. Composers normalize, autolink, collapse
   newlines, and silently truncate.
5. **Submit** per the session's authorization, then **read the live URL off the
   posted item**, not off the composer or a redirect. Write it to `posted:` and
   the timestamp to `posted_at:`.
6. **A challenge is a stop, not an obstacle.** Login wall, captcha, "verify it's
   you", an unexpected 2FA prompt: hand the browser back. Never work around an
   anti-automation check.

Partial completion is normal and gets recorded: live on X, still queued on
Bluesky is a real state, not a failure.

## Per platform

### X — `@handle`

Composer at `x.com/compose/post`. Articles are documented and verified
separately in `references/x.md`; **the post and thread composer is not**, and
the two surfaces share almost nothing.

Threads are built with the "+" control, adding every post before submitting any
of them. Expect the whole chain to publish as one action. Unknown and worth
recording on first run: whether the composer counts graphemes or UTF-16 units,
whether the 23-char URL rule is reflected in the visible counter, and whether
newlines survive a paste as they do in the Article editor.

### Bluesky — `handle.tld`

Composer at `bsky.app`. Limit is 300 **graphemes**, which is not the same count
most editors show — verify against the app's own counter rather than a local
character count.

Links are **facets**: the URL is detected and stored as a range over the text.
A pasted URL should autolink. Unknown: whether a link posted this way produces a
card preview automatically, and whether the card can be removed.

### Threads — `@handle`

Composer at `threads.com`. Single topic tag per post — see `platforms.md`.

The account is derived from Instagram, so an authenticated Instagram session is
expected to carry it. Confirm the composer is posting as the intended account
before submitting; a derived-identity surface is exactly where the wrong account
gets posted from.

### Mastodon — `@handle@instance`

Two routes, and the choice is not obvious:

- **Browser**, at the instance's own compose box. No credential to create, no
  token to store. This is the default.
- **API** — `POST /api/v1/statuses` with a bearer token. Genuinely clean, fully
  documented, and the only microblog channel here with a first-class public
  write API. But **a token is a credential**: it must be created by the user,
  stored in their password manager, and never written to a file, a transcript,
  or an environment this skill controls. It is worth it for repeated
  programmatic posting and not worth it for one post.

Take the browser route unless the user asks for the API. Then note that Mastodon
is also the cheapest place to *verify* a variant end to end, since the public
API can read the posted status back without any authentication at all:

```sh
curl -s "https://<instance>/api/v1/accounts/lookup?acct=<handle>"
```

`visibility` defaults to public; confirm it rather than assuming, because an
instance can default otherwise.

### LinkedIn — company page

Posting **as a company page** is not the same flow as posting as a person: it
happens from the page's admin view, and the identity selector is the thing to
check before submitting. A company post accidentally made from a personal
profile is not movable — it is delete and repost.

The feed truncates around 140 chars on mobile at "see more"; write the hook to
fit that, and verify the fold in the preview rather than counting.

Observed 2026-08-04 during account creation, and likely to recur: LinkedIn's
forms reset and re-render on scroll, so **clicks land on the wrong element when
driven by coordinates**. Re-read element refs after any scroll and drive the
form by ref, not position.

## Do not

- Post from a composer whose account identity you have not confirmed on screen.
- Edit copy in the box. Fix the file, reload, and paste again.
- Retry a submit whose outcome you did not read. A duplicate post cannot be
  un-sent, and a failed submit and a slow one look identical.
- Treat a redirect or a success toast as the URL. Open the post.
