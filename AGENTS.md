# Shared agent configuration

This repository is the canonical development checkout for project-agnostic agent configuration currently consumed as an Outfitter `.outfitter/` directory. Reusable profiles and operating rules here MUST NOT depend on any consuming project.

## Transitional architecture

Outfitter currently authors and loads profiles from `.outfitter/`. Open Outfitter RFC [ai-outfitter/outfitter#165](https://github.com/ai-outfitter/outfitter/issues/165) proposes replacing profile-era `.outfitter` configuration with the Dotagents `.agents` protocol, including `~/.agents/` as the global layer and `<project>/.agents/` as the workspace overlay. The RFC is not yet the released standard.

Until that refactor lands, this repository keeps the profile-era layout at its root. Consumer projects should commit a small `.outfitter/settings.yml` that selects this repository as a pinned remote profile source, while developers may use machine-private `.outfitter/local/settings.yml` to replace that source with a live local checkout. This preserves a portable published baseline and an editable local feedback loop without copying profiles into consumers.

## Scope and portability

Changes in this repository MUST be project-agnostic:

- Do not hardcode a consuming project, company, customer, deployment, domain taxonomy, or machine-specific consumer path. The canonical checkout path documented below is the sole local-development convention.
- Keep project-specific context in that project's `AGENTS.md`, `.agents/skills/`, documentation, or other project-owned files.
- Define roles by reusable responsibilities and outcomes rather than one repository's current architecture.
- Do not commit credentials, tokens, auth state, sessions, transcripts, caches, generated system prompts, or machine-specific absolute paths.
- Prefer portable relative paths and documented environment variables over assumptions about one workstation.
- Treat current profile files as transitional artifacts that will need deliberate migration if RFC #165 is implemented.

Consuming repositories are test environments, not sources of shared policy. Improvements discovered while working in one project must be generalized before they are committed here.

## Repository layout

- `settings.yml` selects the default profile and local profile source.
- `profiles/` contains reusable role profiles.
- `AGENTS.md` defines repository maintenance and local-development conventions.
- Generated `*.generated-system-prompt.md` files are local validation artifacts and are ignored.

## Standard local setup

Use the same workspace layout on each development machine:

```text
~/repos/
  <owner>/
    .agents/                 # this repository
  <organization>/
    <project>/               # consuming repository
```

Clone the canonical repository:

```bash
mkdir -p "$HOME/repos/ncrmro"
git clone git@github.com:ncrmro/.agents.git "$HOME/repos/ncrmro/.agents"
```

### Committed consumer configuration

A consuming project SHOULD commit `.outfitter/settings.yml` with a reviewed remote source pinned to a tag or commit:

```yaml
default_profile: founder
profile_sources:
  - github: ncrmro/.agents
    ref: <reviewed-tag-or-commit>
    path: profiles
```

Public GitHub repositories work directly. Private GitHub catalogs require the documented Outfitter Enterprise opt-in in the user's `~/.outfitter/settings.yml`. Do not place credentials in project settings.

The consumer SHOULD ignore only machine-private state, not the whole `.outfitter` directory:

```gitignore
# .outfitter/.gitignore
/local/
*.generated-system-prompt.md
```

### Machine-local live override

For live profile development, create `.outfitter/local/settings.yml`. `profile_sources` is replaced as a whole by the higher-precedence project-local settings layer, so this local source overrides the committed remote source instead of composing with it:

```yaml
# .outfitter/local/settings.yml — never commit
profile_sources:
  - path: ../../../<owner>/.agents/profiles
```

`path:` is resolved relative to `.outfitter/local/settings.yml`. Adjust the relative path for the standardized workspace layout, and verify the resolved target before launching:

```bash
realpath .outfitter/local/../../../<owner>/.agents/profiles
outfitter profile lint --strict
outfitter profile list
```

Do not use `~` in `path:` entries: current Outfitter path resolution does not shell-expand it. Prefer a relative path in project-local settings; an absolute path is acceptable only in the ignored machine-private file when workspace layouts differ.

## Development workflow

1. Keep the committed consumer settings pinned to a reviewed remote revision.
2. Enable live development with ignored project-local settings pointing at the canonical checkout.
3. Keep consumer-specific behavior in the consumer repository; generalize shared profile changes here.
4. Review changes from the canonical checkout:

   ```bash
   git -C "$HOME/repos/ncrmro/.agents" status --short
   git -C "$HOME/repos/ncrmro/.agents" diff
   ```

5. Validate from at least one consuming project:

   ```bash
   outfitter profile lint --strict
   outfitter profile list
   ```

6. When changing role composition, extensions, inheritance, or subagent generation, launch the affected profile and confirm the expected tools, skills, and subagents are present.
7. Commit and push from this repository, then update the consuming project's pinned `ref` after reviewing the shared diff.
8. Temporarily remove the local override and run `outfitter sync` when validating the published remote path.

## Change standards

- Preserve focused roles and explicit inheritance.
- Keep prompts concise and behaviorally testable.
- Pin external resources when reproducibility or supply-chain risk requires it.
- Document temporary compatibility decisions and link the upstream issue that can remove them.
- Update this file when the canonical checkout location, symlink convention, validation commands, or Outfitter migration status changes.
