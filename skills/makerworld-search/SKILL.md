---
name: makerworld-search
description: Search for 3D-printable models, defaulting to MakerWorld. Use when a task needs a printable part, fixture, bracket, enclosure, or mount (e.g. "find a model for X", "is there a printable Y"). API-first — MakerWorld's unofficial JSON search endpoint works from curl while the HTML site 403s behind Cloudflare — with Chrome browser automation as the fallback for model pages and downloads.
---

# MakerWorld model search

Find 3D-printable models on makerworld.com from an agent session. Default site
for model search unless the user names another (Printables, Thingiverse).

## The one trap

**Do not scrape MakerWorld HTML pages with curl — every page 403s behind
Cloudflare.** The search API, however, is open: no cookies, no UA, no auth
needed (verified 2026-08-08). Go straight to the API; open a real browser only
for model pages/downloads.

## Search API (verified working)

```sh
curl -s "https://makerworld.com/api/v1/search-service/select/design2?keyword=load+cell+mount&limit=10"
```

Parameters (all verified): `keyword` (URL-encoded), `limit`, `offset`
(pagination), `orderBy=hotScore` (optional; the *default* relevance order is
usually better — hotScore surfaces popular-but-off-topic items).

Response: `{"total": N, "hits": [...]}` plus `keywordBlock`/`blockedMessage`
(set when a query is filtered). Useful fields per hit:

| field | use |
| --- | --- |
| `id`, `slug` | model URL: `https://makerworld.com/en/models/<id>-<slug>` |
| `title`, `tags` | relevance check |
| `downloadCount`, `printCount`, `likeCount` | quality signal — `printCount` > 0 means people actually printed it |
| `license` | e.g. `BY-NC-SA` — check before commercial/derivative use |
| `is_printable`, `isStaffPicked`, `nsfw` | filters |
| `cover` | preview image URL (on `makerworld.bblmw.com` CDN) |
| `designCreator.name` | author |

Triage recipe — top hits with quality signals:

```sh
curl -s "https://makerworld.com/api/v1/search-service/select/design2?keyword=QUERY&limit=15" |
  python3 -c "
import json,sys
for h in json.load(sys.stdin)['hits']:
    print(f\"{h['printCount']:>5}p {h['downloadCount']:>6}d  {h['license']:<12} {h['title'][:60]}\n       https://makerworld.com/en/models/{h['id']}-{h['slug']}\")"
```

Search tips: 2–4 concrete nouns beat sentences (`load cell 1kg fixture`, not
`something to hold my weight sensor`); try the part's common alias too (`HX711
bracket`, `scale frame`); `total` in the response tells you whether to broaden
or narrow.

## Chrome fallback (model pages, downloads, when the API fails)

The API covers *finding*; reading a model's full description, print profiles,
comments, or downloading files needs a real browser because of the Cloudflare
wall (and downloads may require a signed-in account). Use the claude-in-chrome
MCP tools: open `https://makerworld.com/en/models/<id>-<slug>` in a new tab and
read/screenshot from there. Also the fallback if the API endpoint ever moves or
starts 403ing — search interactively at
`https://makerworld.com/en/search/models?keyword=...`.

Downloads: prefer handing the user the model URL; STL/3MF retrieval is
login-gated and belongs to the human's account.

## Other sites (when MakerWorld misses)

- Printables (printables.com) — has a public GraphQL API at `api.printables.com/graphql` (unverified here).
- Thingiverse — official REST API needs an app token.
Name the site you're falling back to; don't silently switch.
