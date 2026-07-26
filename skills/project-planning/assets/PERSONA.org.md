# Orgs

Atomic **org** fragments for `scripts/personas.sh --orgs-from`. Each `##`
heading is one organisation. Org is optional in a persona, and it is often the
axis that changes the answer most: the same role at an agency and at a startup
disagree about risk, procurement, and how much evidence a claim needs.

For the **unaffiliated** variant — a persona with no org row at all — pass an
empty org on the command line alongside this file:

```sh
scripts/personas.sh --roles-from ... --orgs-from docs/personas/PERSONA.org.md \
  --org "" --bios-from ...
```

Copy this file to `docs/personas/PERSONA.org.md` and replace the examples.
If the project has a wiki, harvest first: `organizations/` notes and the
`affiliation:` field of `people/` notes are org fragments already researched.

## national space agency

## commercial satellite operator

## venture-backed startup, pre-revenue
