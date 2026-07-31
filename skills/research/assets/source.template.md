---
title: "<Source Title>"
type: source
source_kind: documentation   # documentation | paper | repository | dataset | article | meeting | presentation | recording | filing | standard
status: reviewed
generated: false
authors:
  - <Author or publishing organization>
publication: <Journal, vendor, or venue — omit if not applicable>
published: YYYY-MM-DD        # the artifact's own date; omit if genuinely unknown
retrieved: YYYY-MM-DD        # when you captured it
url: <canonical URL>
version: <exact version/commit/instance checked — omit if not applicable>
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags:
  - <2-5 material tags; reuse from wiki/tags.md>
---

# <Source Title>

## Provenance

- Canonical URL: <https://…>
- Retrieved: YYYY-MM-DD
- Version checked: <docs version, release tag, commit SHA, or deployed instance version>
- How it was retrieved: <curl, browser MCP, repo clone at commit, API call>

<Name what is archived beside this note and what the searchable representation
is: [[./content|Content]] for extracted text, [[./transcript|Transcript]] for
audio/video.>

## Integrity

| File | SHA-256 |
| --- | --- |
| `<file>` | `<hash>` |

## Summary

<What this source actually says, in the reader's terms. Quote or closely
paraphrase; do not extrapolate here.>

## Key claims

- <Claim, with the section or line it comes from.>

## Operational conclusion

<What this source means for the work at hand — kept separate from the summary
so the source's own content stays unmixed with your reading of it.>

## Related notes

- [[../../concepts/<concept>|Concept]]
- [[../../research/<note>|Research note]]

## Evidence limits

<Required. What this source does NOT establish. Documentation proves documented
behavior, not that a system works. A config file proves configuration, not a
successful run. A benchmark proves one run on one machine. If capture failed or
was partial, say so here.>
