# Roles

Atomic **role** fragments for `scripts/personas.sh --roles-from`. Each `##`
heading is one role. A role is *the job someone does*, not the segment they
belong to: "flight director" behaves differently from "procurement lead" in a
way that "enterprise buyer" never will.

Prose outside a `##` entry — like this paragraph — is ignored, as is anything
inside an HTML comment, so keep notes wherever they help.

Copy this file to `docs/personas/PERSONA.role.md` and replace the examples.

## flight director

## procurement lead

## integration engineer

<!--
An entry may carry a body, which becomes the fragment instead of the heading.
Useful when the role needs qualifying beyond a title:

## staff engineer
Staff engineer on the platform team, accountable for the build but not for
the roadmap.
-->
