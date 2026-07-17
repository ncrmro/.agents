# The .agents standard, and how Outfitter works with it

## The .agents directory standard (Dotagents)

`.agents/` is the harness-neutral home for agent-facing configuration. It exists at two layers:

- **Workspace layer — `<project>/.agents/`**: the consuming repository's own domain skills and agent resources. This is where project-specific knowledge lives (e.g. a `wiki` or `research` skill tuned to that repo).
- **Global layer — `~/.agents/`**: user/owner-wide shared configuration. Its canonical checkout on development machines is a repository under the standardized layout `~/repos/<owner>/.agents`, so the global layer is versioned, reviewable, and cloneable like any other repo.

Layout inside a `.agents/` directory:

```text
.agents/
  AGENTS.md            # conventions for maintaining this directory/repo
  skills/
    <name>/
      SKILL.md         # frontmatter: name, description (the loading trigger)
      references/      # deep-dive docs the skill points to
      scripts/         # helper scripts the skill invokes
      assets/          # templates and other static material
  profiles/            # transitional, Outfitter profile-era (see below)
  settings.yml         # transitional, Outfitter source graph (see below)
  local/               # ignored machine-private overrides (never committed)
```

Conventions:

- **`.agents/skills/` is canonical for skills.** Harnesses discover them natively (Claude Code loads `SKILL.md` frontmatter directly from `.agents/skills/`). A skill's `SKILL.md` stays short and operational; depth goes in `references/*.md`.
- **`AGENTS.md` is the agent-readable instruction file** at a repository root (and optionally per subproject). `CLAUDE.md` should be a symlink to `AGENTS.md` where Claude Code compatibility is needed — one source of truth, no drift.
- **Shared (global-layer) content must be project-agnostic**: no consumer project names, company/customer specifics, machine-specific absolute paths, or credentials. Project specifics belong in the consuming repository's `.agents/` and `AGENTS.md`. Machine paths belong only in ignored `local/` settings.

## How Outfitter works with it

Outfitter composes shared agent roles ("profiles") across repositories. Today it is in a **transitional, profile-era architecture**: it authors and loads configuration from `.outfitter/` directories, while `.agents/` is already the canonical home for skills and shared-role sources.

- **Consumer side**: a consuming repository commits `.outfitter/settings.yml` declaring a `default_profile` and its settings sources — either `remote_settings` pinning a published catalog (a GitHub repo + reviewed ref, e.g. an owner's `.agents` repository) or `profile_sources` paths. It ignores `.outfitter/local/` and `*.generated-system-prompt.md`.
- **Catalog side**: a shared catalog (such as the global-layer `.agents` repo) provides `settings.yml` with an ordered `profile_sources` list — lowest to highest precedence; later sources override same-ID resources. Typical graph: published default profiles → community profiles → tool-owned skills → the owner's `profiles/` as the highest-precedence layer.
- **Live development**: an ignored `local/settings.yml` mirrors the published graph with absolute paths to local checkouts; consumers symlink it into `.outfitter/local/settings.yml` for live edits, and remove it to test the published graph. Paths use shell-expanded `$HOME` (Outfitter does not expand `~`).
- **Profiles** are YAML roles (`id`, `label`, `inherits`, `controls`) that can append system-prompt text and select skills by id. Skill selection from `.agents/skills/` is intentionally left disabled in profiles for now — those skills load natively via the harness — pending Outfitter's `.agents` support.
- **Validation loop**: `outfitter profile lint --strict`, `outfitter profile list`, launch the affected profile, then `outfitter sync` to exercise the published graph after bumping pinned refs.

## Migration direction

Outfitter RFC [ai-outfitter/outfitter#165](https://github.com/ai-outfitter/outfitter/issues/165) proposes replacing the profile-era `.outfitter/` configuration with the Dotagents `.agents` protocol: `~/.agents/` as the global layer and `<project>/.agents/` as the workspace overlay. Until it lands:

- treat `profiles/`, `settings.yml`, and `.outfitter/` as transitional artifacts that will require deliberate migration;
- keep new durable content (skills, references, conventions) in `.agents/` form so it survives the migration unchanged;
- keep the published (`settings.yml`) and live (`local/settings.yml`) source graphs equivalent and in the same precedence order.
