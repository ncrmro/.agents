# Legacy source recovery

Use this when the canonical resume record is empty, incomplete, or newer than
the person's old sites, documents, and bookmarks.

## Source order

Start with the sources already under the user's control:

1. prior resume/CV files and exports;
2. the full Git history of an old resume or personal website;
3. professional profiles such as LinkedIn;
4. talks, project pages, employer pages, bookmarks, and archived links;
5. user confirmation.

A directly visible user-owned professional profile can support titles and
dates. Search-result snippets, scraped profile aggregators, bookmarks, and dead
links are leads, not proof.

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

## Recover from professional profiles

Use a professional profile primarily to establish:

- organization and official role title;
- start and end month;
- employment relationship and location, when explicitly shown;
- whether overlapping entries are concurrent roles, clients, or contracting
  organizations;
- current headline and summary.

Do not expect the profile to preserve the richest accomplishments. Legacy
resumes and their Git history often contain more detailed claims; combine those
claims with the profile's chronology without letting either silently overwrite
the other.

If direct profile access is blocked by login, robots policy, or an unavailable
browser session:

- record the canonical profile URL and access date;
- use search snippets or profile aggregators only to form
  `needs-verification` leads;
- do not expose scraped contact details;
- ask for a profile export, screenshot, or user confirmation when exact fields
  materially affect the resume.

## Search bookmarks and archives

Bookmarks can still locate old profiles, project pages, talks, and resume
snapshots. Search by organization, role-title variants, project names, old
personal domains, and tags such as `resume`, `career`, `portfolio`, or `work`.
A bookmark's title, notes, tags, and saved URL help locate evidence, but they do
not verify a dead or inaccessible target.

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
