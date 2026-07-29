# Website synchronization

The website is a rendered publication target. Keep it easy to rebuild from the
canonical records without forcing every website to adopt the same framework.

## Discover the adapter

1. Read `docs/personal/resumes/targets/<target>.md`.
2. Locate the target repository and read its `AGENTS.md`.
3. Inspect the current resume route, content schema, job/project records, asset
   locations, build command, deployment boundary, and git status.
4. Compare the current site with the target's designated variant before
   editing.
5. If the target record is incomplete, record the discovered mapping before
   relying on it.

Never assume that a website repository is clean, on its default branch, or safe
to publish merely because it exists.

## Map canonical data

Map fields explicitly:

| canonical source | typical website destination |
| --- | --- |
| public profile fields | resume page header or shared profile data |
| selected public roles | job content collection or resume page data |
| selected public claims | role/project body content |
| public links | profile or role links |
| public skills | structured tags or badges |
| target-specific summary | resume page introduction |

Preserve the target's schema and naming conventions. Prefer updating structured
content over embedding a second hand-written resume in a page component.

If the target cannot represent a canonical field, either omit it or change the
target schema deliberately. Do not smuggle data into an unrelated field.

## Public boundary

Before writing to a public repository:

1. Resolve the designated variant.
2. Intersect it with `visibility: public`.
3. Exclude private evidence and provenance notes.
4. Scan the resulting diff for contact details, customer names, internal URLs,
   compensation, references, and confidential metrics.

A `resume-only` claim may be exported into a directly shared document but must
not be synchronized to the public website.

## Freshness audit

Treat these as defects to review:

- an `end: Present` or missing end date on a role that may have ended;
- a role present on the site but absent from the designated variant;
- different dates or titles between canonical and published records;
- a website-only bullet with no canonical claim ID;
- a broken employer, project, or profile link;
- stale summary text that contradicts newer work history;
- current-role bullets written in past tense or former-role bullets in present
  tense.

Do not auto-close a role just because it is old. Ask for or find reliable
evidence.

## Validate and publish

Run the target's narrowest relevant content/schema check, then its documented
build when the change affects rendering. Preview when layout or page length
changed materially.

Publishing is a separate state change:

- A successful local build does not authorize a deployment.
- Follow the target repository's commit, branch, and deployment rules.
- If the user's request includes keeping the live site current and the target
  deploys from committed content, complete that documented path.
- Otherwise stop after a validated change and report the remaining publication
  step.

After a verified update, record `last_published` and `source_revision` in the
target file. Never claim the live site is current without checking the
deployment or live page.
