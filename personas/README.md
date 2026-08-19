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

Keep the name short and match it to the same role elsewhere. The launcher
resolves a bare name across all three directories, so `engineer.md` here and
`engineer.md` in a project are the same role and shadow correctly, while
`software-engineer.md` here against `engineer.md` there would silently resolve
to different documents depending on the working directory.

## Organization personas

Files named `org.*.md` describe an institution rather than a role. They compose:
pass an organization and a role together and the reviewer adopts one identity
built from both, in the order given.

```bash
~/.agents/scripts/persona-review \
  --persona org.defense-supplier --persona compliance-assessor \
  --report ~/.agents/local/persona-reviews/dib-assessor.md \
  'Review the deployment guide and write the report. @README.md'
```

Use an organization alone when the institution is the whole point, a role alone
when it is portable across institutions, and both when the same role would reach
a different conclusion at a different employer — a procurement officer at a
county and at a defence ministry do not want the same things.

The four `org.*` files here are copies. Their canonical home is the ks.systems
wiki under `wiki/orgs/`, where they carry frontmatter this tier does not allow;
these are the same text with the frontmatter stripped. Edit the wiki copy and
regenerate rather than editing here.

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
outfitter run persona-reviewer \
  --append-prompt ~/.agents/personas/platform-engineer.md -- \
  --print "Review the onboarding docs from this persona's point of view."
```

`--append-prompt` goes before `--`, never after it. A harness flag written
after `--` reaches the harness verbatim, and the harnesses disagree about what
it means: pi reads a path, Claude Code reads a prompt string. The wrong one
produces a generic review with no persona and no error.

The `persona-review` skill wraps the same call and owns the review method,
evidence gathering, and report shape. Its launcher takes a bare role name and
searches `./docs/personas/`, then `./.agents/personas/`, then this directory —
so a project persona shadows a cross-project one of the same name:

```bash
~/.agents/scripts/persona-review \
  --persona platform-engineer \
  --report ~/.agents/local/persona-reviews/platform-engineer-docs.md \
  'Review the onboarding docs and write the report. @README.md'
```

The prompt is one positional argument, and the report's parent directory must
already exist. Repeat `--persona` to run several, each in its own process with
its own session and report.

Both skills and the `persona-reviewer` agent resolve from
`ai-outfitter/community-profiles`, pinned in `settings.yml`.
