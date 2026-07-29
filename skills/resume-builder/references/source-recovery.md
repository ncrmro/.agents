# Legacy source recovery

Use this when the canonical resume record is empty, incomplete, or newer than
the person's old sites, documents, and bookmarks.

## Source order

Start with the sources already under the user's control:

1. prior resume/CV files and exports;
2. the full Git history of an old resume or personal website;
3. bookmark-manager entries and archived links;
4. public profiles, talks, project pages, and employer pages;
5. user confirmation.

A bookmark is a lead, not proof. Its title, notes, tags, and saved URL can help
locate evidence, but a dead or inaccessible target does not verify the claim.

## Recover from Git, not only the working tree

The current website may contain compressed wording, migrated fields, or stale
open-ended roles. Inspect the commits that introduced and materially revised
each role:

```text
git log --all --follow -- <resume-record>
git show <revision>:<path>
git log --all -S '<organization-or-title>' -- .
```

Treat different revisions as separate sources. A later revision is not
automatically more factual: it may be a design cleanup, title rewrite, or
abbreviation. Preserve richer earlier claims when they remain supported, and
record title/date conflicts instead of silently choosing one.

## Search bookmark managers

Search by:

- organization and product names;
- exact role titles and title variants;
- project, talk, and repository names;
- old personal domains and resume URLs;
- technologies paired with an organization;
- tags such as `resume`, `career`, `portfolio`, `talk`, or `work`.

Open promising targets and capture only the provenance needed to recover the
fact. Never copy session tokens, private bookmark notes, or unrelated browsing
data into the resume tree.

If the bookmark service or target is unavailable, record the access failure and
continue with local sources. Do not turn inability to corroborate into a claim
that the fact is false.

## Reconcile

Build a small conflict table before writing:

| field | source A | source B | action |
| --- | --- | --- | --- |
| title | one title | another title | mark the role `needs-verification` |
| date | precise month | different month | retain both in context; do not guess |
| claim | detailed wording | shorter wording | keep supported detail canonically |
| current role | `Present` on an old source | no newer evidence | leave unresolved |

Import internally consistent facts as supported by their source. Mark the
record `needs-verification` when a material field conflicts or an open-ended
date is stale. Claim-level status may remain verified when the claim itself is
consistent even if the role title or end date is unresolved.

## Provenance

Each imported record should say:

- which file, URL, bookmark, or repository revision supplied it;
- when that source was authored or captured, when known;
- what conflicted or could not be accessed;
- whether the source was public, resume-only, or private.

Do not call the import complete until every role and selected claim is either
verified or visibly marked for verification.
