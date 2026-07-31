# Personas

One persona per file, one committed Markdown file per person or role. A persona
says who work is for; it carries no frontmatter, no schema, and no review
procedure.

Personas here are **cross-project**: the reader exists independently of any one
repository, so the file is available from any working directory, including
`~`. A persona that only makes sense inside one project belongs in that
project's own `docs/personas/`, next to the work it describes.

Filenames are lowercase and hyphenated, and name the role rather than the
person — `platform-lead.md`, not `dana.md`. Add a named individual only when a
specific person's voice is the point.

## Authoring

Use the `persona-authoring` skill rather than writing from scratch; it owns the
template and the rules about what must not be invented (demographics, private
facts, research that does not exist).

```text
/skill:persona-authoring Write a platform lead persona in ~/.agents/personas/.
```

## Reviewing with one

The persona is appended to the shared `persona-reviewer` agent's system prompt
at launch, so it becomes that session's identity rather than a request in the
conversation. Because the path is absolute, this works from any directory:

```bash
outfitter run persona-reviewer -- \
  --append-system-prompt ~/.agents/personas/platform-lead.md \
  --print "Review the onboarding docs from this persona's point of view."
```

The `persona-review` skill wraps the same call and owns the review method,
evidence gathering, and report shape.

Both skills and the `persona-reviewer` agent resolve from
`ai-outfitter/community-profiles`, pinned in `settings.yml`.
