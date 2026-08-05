# Handle rules

Check these **before** proposing a candidate. The tightest limit in the target
set decides the name for all of them — X's 15 characters is almost always that
limit, and it eliminates candidates that pass everywhere else.

| Platform | Length | Allowed characters | Confidence |
| --- | --- | --- | --- |
| X | 15 | letters, digits, `_` | high — long-standing and widely documented |
| GitHub | 39 | letters, digits, `-` (no leading/trailing or doubled `-`) | high |
| Instagram | 30 | lowercase letters, digits, `.`, `_` | high |
| Threads | — | inherits the Instagram handle exactly | high |
| TikTok | 24 | lowercase letters, digits, `.`, `_` | medium — verify at signup |
| YouTube handle | 3–30 | letters, digits, `.`, `_`, `-` — **but see the URL rule below** | medium |
| Reddit | 3–20 | letters, digits, `_`, `-` | medium |
| Mastodon | 30 | letters, digits, `_` | medium — per instance, and instance-configurable |
| Bluesky | a DNS name | your own domain, or `<name>.bsky.social` | high |
| LinkedIn page vanity | unverified | unverified | low — check in the page settings |

Rows marked medium or low are worth re-checking against the platform's own
signup form before a name is committed across the whole set. Correct this table
when a signup form contradicts it; a wrong limit here costs a rename everywhere.

## YouTube rejects handles that look like a URL

**A handle that ends in a real TLD will be refused even though every character
in it is legal.** YouTube disallows handles resembling URLs or phone numbers,
and it enforces this *after* the charset check.

Observed 2026-08-04: `@artera.space` passed a 404 availability probe, is 12
characters, and uses only legal characters — and the handle picker rejected it
with **a red exclamation icon and no error text**. The domain-shaped suffix is
the cause; `artera.space` is a live domain and `.space` is a TLD.

This bites exactly the names this skill recommends most, because "use the
domain as the handle" is the top-ranked pattern. It works on Bluesky, where the
handle *is* a domain by design. It fails on YouTube for the same reason.

Fix by removing the TLD shape, not the period: `artera_space` and `arteraspace`
are both fine; `artera.space` and `artera.io` are not. A period elsewhere in the
name (`artera.orbital`) does not trigger it.

**A silent validator is still a validator.** A red icon with no message is a
rejection, not a glitch — do not retry it, change the name.

## Separator choice

`.` and `_` are not interchangeable. X has no `.`; Instagram and TikTok have
both; GitHub has neither and only `-`. A name needing a separator therefore
cannot be identical across the set, which is a reason to pick a name that does
not need one.

Concatenation beats separation: `arteraspace` works on every platform in the
table; `artera.space` and `artera_space` each fail on some of them.

## Bluesky is the exception worth exploiting

A Bluesky handle is a domain you control, verified by a DNS TXT record or a
`/.well-known/atproto-did` file on the site. Nobody can hold `yourdomain.com`
on Bluesky except whoever holds the domain. When the plain name is squatted
everywhere else, this is still available, and it is the strongest identity
signal on the platform — take it even if the rest of the set has to compromise.

The same logic applies to a self-hosted Mastodon instance and to a DNS proof on
Keybase: identity anchored to a domain cannot be squatted.

## Case

Handles are case-insensitive for resolution and case-preserving for display on
most platforms — YouTube shows `@ArteraSpace` for a handle registered in any
case. Record the lowercase form in `handle:` and the displayed form, if it
differs, in the notes. Never treat two casings as two accounts.
