---
generated: true
updated: YYYY-MM-DD
entity: <slug>
kind: project            # project | org | person
canonical_url: https://example.com
tags: [meta]             # vault pages only; drop this key in a code repo

accounts:
  - platform: x
    handle: null
    url: null
    status: unverified   # owned | reserved | available | unavailable | declined | unverified
    verified: null       # date of the last real check — required for any other status
    method: null         # login | signup-form | api | browser | http-probe | none
    channels: [microblog, article]
    credentials: null    # password-manager entry NAME only
    held_by: null        # who has it, when status is unavailable
---

# <Entity> — social accounts

<One sentence: what this registry covers, and what it deliberately excludes.>

## Identity

- **Name:** <the name as written everywhere>
- **Domain:** <domain> — the canonical link in every bio
- **One-line bio:** <the source text every profile bio is trimmed from>
- **Assets:** <where the avatar, banner and brand files live>

## Accounts

| Platform | Handle | Status | Verified | Channels |
| --- | --- | --- | --- | --- |
| | | | | |

## Per-account detail

### <Platform> — @<handle>

- **Link:** <url>
- **Status:** <status> (checked YYYY-MM-DD, <method>)
- **Bio, as live:** "<current text>"
- **Missing:** <no link, no avatar, bio disagrees with the identity line…>

## Contested names

<The desired handle, who holds it, and the ranked alternatives with their own
status and check date. Delete this section when nothing is contested.>

## Not pursued

| Platform | Reason |
| --- | --- |
| | |

## Open actions

- [ ] <claim, fix, or verify — one per line>
