# Checking a handle

**verified: 2026-08-04** — exercised end to end against X, Instagram, TikTok and
YouTube in a real logged-in Chrome session, plus the `curl` column against all
platforms listed. Everything below was observed, not recalled. **Not exercised:**
LinkedIn, Reddit, Mastodon, and every signup form.

## The asymmetry: 404 is not availability

**Every check here is conclusive in one direction only.** Getting this backwards
is the mistake this file exists to prevent, and it has now been made twice in
opposite directions:

| Evidence | Proves | Does NOT prove |
| --- | --- | --- |
| The profile **renders** | `unavailable` — conclusively | — |
| The profile **404s** | nobody is publicly using it | **that you can register it** |
| The signup validator **accepts** | `available` — conclusively | — |
| An identity API returns nothing | nobody is publicly using it | **that you can register it** |

Verified the hard way on 2026-08-04: `instagram.com/artera` returned "Sorry,
this page isn't available." in a logged-in session, and I recorded it free.
Nicholas then put the name into the actual signup form — **not available.**

A username can be unreachable and unregistrable at the same time, for two
independent reasons:

- **Reserved or retained** — Instagram holds the usernames of deactivated and
  disabled accounts, and platforms reserve names for trademarks, brands and
  banned words.
- **Format-rejected** — the name is free and legal by charset, and a *shape*
  rule still refuses it. YouTube rejects handles that look like URLs, so
  `@artera.space` 404s as available and is then refused by the handle picker
  with a red icon and no message (`references/handles.md`).

Both 404. So:

- A rendered profile ends the question. Write `unavailable`, and the page tells
  you who holds it.
- A 404 promotes the candidate to *worth confirming* and **nothing more**. The
  row stays `unverified` until a signup validator accepts it.

## Load the profile URL first — it is the cheap half

Logged in, the authwall goes away and the profile URL settles every *taken*
name in one navigation. Do this pass first; it is fast and it eliminates most
candidates.

| Platform | 404 reads as | Session |
| --- | --- | --- |
| X | "This account doesn't exist" | logged in |
| Instagram | "Sorry, this page isn't available." | logged in |
| TikTok | "Couldn't find this account" | **either** — renders logged out |
| YouTube | `404 Not Found` in the page title | either |

`find`/`read_page` on the accessibility tree beats a screenshot for reading the
verdict, but a screenshot is what tells you *who* holds a taken name.

GitHub and Bluesky have public identity APIs that are instant — but they are
subject to the same asymmetry. A `404` from `api.github.com/users/<h>` does not
mean GitHub will let you register it.

## Then confirm the survivors in the signup form

**Only the registration form can say a name is claimable**, because it is the
code that will do the claiming. Whatever survives the 404 pass goes through it
before the row may read `available`.

Use an isolated, logged-out Playwright context: a signup form behaves
differently, or refuses to render, when a session already exists.

### Bracket every candidate with two controls

**A signup validator lies in both directions, and neither lie announces
itself.** Do not read a single result. Every real candidate goes between two
controls whose answers you already know:

| Control | Expected | If it comes back wrong |
| --- | --- | --- |
| a name you have **confirmed taken** (its profile renders) | rejected | the validator is not consulting the server — you are reading the format check |
| a **random 16-char string** | accepted | the session is rate-limited and rejecting everything |

Both failures were hit in one session on 2026-08-04, and each individually looks
exactly like a real answer:

- **Read too early.** Instagram shows "Input Username is valid." as soon as the
  *format* check passes, before the availability round-trip returns. Six
  candidates were recorded as confirmed this way. With a 5-second wait, they
  came back "is not available."
- **Session poisoned.** After roughly fifteen candidates in one form, the
  validator rejected everything — including `qzxvbn7k2mwplr4t`. Every rejection
  after that point was worthless, and rejections are the results that *feel*
  trustworthy.

The taken-control alone is not enough: it passed while the reads were still
premature, because a known-taken name can resolve from cache fast enough to look
like proof. **Both controls, every session.**

### Procedure

- Fill the field, **move focus out**, then **wait for the server answer** — 5
  seconds, or until the text changes from the format-valid state. Never snapshot
  immediately after blur.
- Read the message from the accessibility snapshot. `[invalid]` plus "The
  username X is not available." and a clean accept are the two answers; a rate
  limit, a challenge, or "enter a valid username" is **not an answer** — record
  `unverified` and say what you saw.
- **Keep it to a handful per session** — under ten, spaced out. Beyond that the
  rate limit arrives and everything after it is noise. Batch the 404 pre-filter
  first precisely so the form sees only survivors.
- If the random control fails, **stop and start a fresh session.** Nothing
  gathered after that point may be written to the registry, including results
  gathered before it in the same run — you cannot tell when the limit engaged.
- **Never submit.** Reading the validator is the check.

Where a platform defers the username until after verification (X, LinkedIn,
YouTube), its logged-in settings validator plays this role instead — read it,
never save it. If neither surface is reachable, the honest status is
`unverified`, not `available`.

## Ownership: the affordance is the tell

A page that renders proves the name is taken, not who holds it. In a logged-in
session the button answers that:

| You see | It is |
| --- | --- |
| Subscribe / Follow | **somebody else's** |
| Customise channel / Edit profile | **yours** |

Verified on YouTube 2026-08-04: `@ArteraSpace` offered **Subscribe** in
Nicholas's own session, settling a channel that an API probe had left ambiguous
for a day. It is a Vietnamese arts collective — 1 subscriber, one video, its own
Artera logo — not, as the shape of the data suggested, a forgotten channel of
his own.

That is the whole reason `owned` requires a login. A 1-subscriber channel with
an empty description at exactly your desired name looks identical whether it is
yours or a stranger's, and the guess was wrong.

## The cheap pre-filter

Conclusive where marked; everywhere else it only cuts obviously-taken names
before the browser pass.

| Platform | `curl` verdict |
| --- | --- |
| GitHub | **conclusive** — JSON on hit, `404` on miss, and the payload names the holder |
| Bluesky | **conclusive** — a DID, or `InvalidRequest` |
| YouTube | **conclusive via the `<title>`**, never via the status code |
| X | suggestive — `404` on a miss matched the logged-in verdict on 2026-08-04, but confirm |
| Instagram, TikTok | **useless** — `200` for every handle, real or not. The `200` is a JS shell, not a page: TikTok's *rendered* page says "Couldn't find this account" for the same URL `curl` calls a hit |
| Threads | n/a — it is the Instagram account |
| Reddit, LinkedIn | **blocked** — interstitial or authwall to unauthenticated clients |

```sh
# GitHub — also tells you who holds it
curl -s -H "Accept: application/vnd.github+json" \
  https://api.github.com/users/<handle> | grep -E '"(login|type|name|blog)"'

# Bluesky — a DID means taken; InvalidRequest means free
curl -s "https://public.api.bsky.app/xrpc/com.atproto.identity.resolveHandle?handle=<handle>.bsky.social"
# And the domain handle, which is the one worth having:
curl -s "https://public.api.bsky.app/xrpc/com.atproto.identity.resolveHandle?handle=<your-domain>"

# YouTube — read the title, NOT the status code
curl -s -A "Mozilla/5.0" -L "https://www.youtube.com/@<handle>" \
  | grep -oE '<title>[^<]*</title>' | head -1

# X — weak signal, confirm in the settings validator
curl -s -o /dev/null -w "%{http_code}\n" -A "Mozilla/5.0" "https://x.com/<handle>"
```

Always send a browser `User-Agent`. Several of these return a consent wall or an
interstitial to a bare `curl`, which is indistinguishable from a real page.

## The YouTube status-code trap

`GET /@somehandle` returns `200` for handles that resolve *and* for some that do
not, so a status-code probe reports every candidate as taken. The `<title>` is
the discriminator: a real channel titles as `<Channel Name> - YouTube`, a free
handle titles as `404 Not Found` while still answering `200`. Observed directly
on 2026-08-04: `@arterafarms` → `404 Not Found`; `@arteraspace` → `Artera Space
- YouTube`.

## Driving the browser check

1. Open **one** tab and reuse it, navigating in place.
2. Batch `navigate` → `wait` → `screenshot` per candidate. These are all SPAs:
   a screenshot taken immediately after `navigate` catches a loading skeleton,
   which reads as neither free nor taken. **3–4 seconds** was enough for all
   four platforms on 2026-08-04.
3. Check the **tab title** as well as the page. It settles before the body
   renders and often carries the verdict outright (YouTube's `404 Not Found`,
   TikTok's "Couldn't find this account…").
4. Anything that is not one of the two expected strings — a rate limit, a
   challenge, a consent wall — is **not an answer.** Record `unverified` and
   say what you saw.
5. Batch the `curl` pre-filter first so the browser only sees survivors. Beyond
   politeness: a run of profile loads is how enumeration looks, and a challenged
   session makes everything you read afterwards untrustworthy.

`browser_batch` chains these in one round trip, but a batch **stops on the first
error and drops the images from that call** — a mid-batch navigation permission
failure cost a screenshot that had already been taken on 2026-08-04. Keep
batches to one platform, and re-take rather than re-navigate when one fails.

## Reading ownership off a hit

A hit is more useful than a miss, because the payload usually says who. Prefer a
check that returns identity over one that returns a boolean:

- GitHub's `blog` and `name` identify the holder outright — `github.com/artera`
  is an Organization named "Artera" pointing at `artera.net`, an unrelated
  company.
- A YouTube channel's subscriber count and description separate a real presence
  from a shell. A 1-subscriber channel with an empty description at exactly your
  desired name is very often **your own**, made and forgotten. Ask before
  recording it as a squatter, and before recording it as yours.
- The fastest resolution for "is this mine?" is to open it in the user's own
  Chrome session. An owned account shows an edit affordance; somebody else's
  shows a follow button.

## What no check can tell you

- Whether a dormant account can be reclaimed. Some platforms release inactive
  handles on request; none do so predictably. Do not plan on it.
- Whether the name is legally yours to use. Availability is not clearance.
- Whether a validator's "available" survives the submit. Trademark and
  banned-word holds sometimes only fire at registration.
