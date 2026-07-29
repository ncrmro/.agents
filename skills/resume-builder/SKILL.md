---
name: resume-builder
description: Human-invoked. Create and maintain a canonical personal resume record, produce role-specific resume variants, track work history and evidence, and synchronize the public resume website. Use when explicitly asked to create, tailor, audit, export, or publish a resume or CV.
disable-model-invocation: true
---

# Resume builder

Maintain one evidence-backed career record under `docs/personal/resumes/`,
derive targeted resumes from it, and publish only the explicitly public subset
to a personal website.

Read these supporting docs when needed:

- `references/convention.md` — required file layout, record fields, claim IDs,
  variants, and publication state.
- `references/website-sync.md` — discovering and updating a resume website
  without making it a second source of truth.
- `assets/scaffold/` — starter files for an empty resume root.

## Default decision

**Facts live once; variants select them by stable ID.** Never copy a role or
achievement into a variant and let it drift. Update the canonical record, then
select, order, or narrowly reframe its claims for a target role. A website is a
publication target, not the canonical work-history database.

## Safety and truthfulness

- Never invent dates, titles, metrics, credentials, employers, clients, or
  technologies. Mark uncertain material `status: needs-verification`.
- Preserve the most precise date actually known; do not manufacture a day to
  satisfy a format.
- Treat contact details, compensation, references, customer names, and
  non-public evidence as private unless explicitly marked otherwise.
- Do not publish or commit private fields to a public repository.
- Keep evidence beside the canonical claim as a link or short provenance note;
  do not copy confidential source material into the resume tree.
- Show the user material wording changes and unresolved facts before publishing.

## Workflow

1. **Locate the personal source.**
   - Read the governing `AGENTS.md`.
   - Use the repository root containing `docs/personal/resumes/`.
   - If the directory is absent, offer to copy `assets/scaffold/` there.
   - Read its `README.md` and all records involved in the requested change.
2. **Inventory before editing.**
   - List canonical roles, projects, claim IDs, variants, and publication
     targets.
   - Compare the record with the current resume website and any supplied resume
     files.
   - Report contradictions, stale open-ended roles, and unverified claims.
3. **Update canonical facts first.**
   - Add or amend `work-history/` and `projects/` records.
   - Give each reusable achievement a stable claim ID.
   - Record visibility, confidence, evidence, and `last_verified`.
   - Close prior open-ended roles when a newer fact establishes an end date.
4. **Build or refresh variants.**
   - Create `variants/<slug>.md` from the canonical profile and selected claim
     IDs.
   - Tailor summary, ordering, and emphasis to the target role.
   - Keep job-description keywords only where the canonical evidence supports
     them.
   - Link application-specific variants to the existing application record
     rather than duplicating application tracking here.
5. **Render and review.**
   - Resolve every selected claim ID.
   - Check chronology, tense, consistency, page length, contact fields, links,
     and spelling.
   - Present material edits and any `needs-verification` items to the user.
6. **Synchronize publication targets.**
   - Follow `references/website-sync.md`.
   - Update only records with `visibility: public`.
   - Preserve the target repository's content schema and local instructions.
   - Build or run the narrowest available validation before publishing.
7. **Record freshness.**
   - Update the variant's `last_reviewed`.
   - After a verified website update, update the target record's
     `last_published` and source revision or commit.
   - Report what remains unpublished or unverified.

## Variant rules

A variant may:

- choose and order canonical claim IDs;
- use a target-specific summary;
- shorten a supported claim without changing its meaning;
- group supported skills for readability;
- omit irrelevant roles, projects, and claims.

A variant must not:

- create facts that exist only in the variant;
- inflate scope, seniority, ownership, or numerical impact;
- expose a private claim;
- silently change dates or titles;
- overwrite another targeted variant.

## Completion checks

- Every rendered claim resolves to one canonical record.
- Every public claim is explicitly marked public.
- No unresolved contradiction is presented as fact.
- Current roles use present tense; completed roles use past tense.
- Dates are chronologically consistent and open-ended roles are intentional.
- The website matches the designated public variant after synchronization.
- Generated files are reproducible from the canonical records and variant.
