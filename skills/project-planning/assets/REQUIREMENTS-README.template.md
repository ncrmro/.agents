# <Project> requirements

Formal, numbered project obligations live here as `<PREFIX>-NNN-<topic>.md`
files. Their format and governance are themselves specified by
[<PREFIX>-NNN: Requirements Governance](./<PREFIX>-NNN-requirements-governance.md);
machine-verifiable requirements are pinned by tests carrying a
`THIS TEST VALIDATES A HARD REQUIREMENT (<PREFIX>-NNN.M)` traceability comment.

## Register

| ID | Topic | Status |
| --- | --- | --- |
| <PREFIX>-001 | <topic> | Active |
| <PREFIX>-002 | <topic> | Draft |

## Amending requirements

Pinned tests say "YOU MUST NOT MODIFY THIS TEST UNLESS THE REQUIREMENT
CHANGES" — so when reality and a requirement disagree, change the requirement
first, with a trace, then the test. The process:

1. **Amend the requirement file first.** Edit the relevant `<PREFIX>-NNN.M`
   section. Never renumber or reassign existing statement or section IDs:
   replace a withdrawn statement in place with
   `REQUIREMENT REMOVED (YYYY-MM-DD): <rationale>` and append new statements
   at the end of the list. Add a short `Amendment (YYYY-MM-DD): ...` note
   under the section heading recording what changed and why.
2. **Then update the pinned tests.** Adjust every test whose traceability
   comment references the amended requirement so it validates the new text.
   The amendment note in step 1 is the trace that authorises touching a
   "must not modify" test.
3. **Then change the implementation** in the same change set, and run the full
   suite.

Amendments are reviewed like any other change: the requirement edit, test
edit, and implementation edit land together so the diff shows the whole trace.

## Conventions

- **One scope per file.** If a title needs "and", it is two documents.
- **Prefixes are per-subject, not per-repo.** A repo may hold several.
- **Package requirements live with the package** —
  `code/<pkg>/docs/requirements/` — so it can be extracted without orphaning
  its contract. Requirements that govern how the *application* uses a package
  stay in the application's register.
- **Numbers are permanent.** Withdrawn statements leave a tombstone; they do
  not free their number.
