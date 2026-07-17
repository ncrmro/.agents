# Shared agent configuration

This repository is the canonical development checkout for project-agnostic agent configuration currently consumed as an Outfitter `.outfitter/` directory. Reusable profiles and operating rules here MUST NOT depend on any consuming project.

## Transitional architecture

Outfitter currently authors and loads profiles from `.outfitter/`. Open Outfitter RFC [ai-outfitter/outfitter#165](https://github.com/ai-outfitter/outfitter/issues/165) proposes replacing profile-era `.outfitter` configuration with the Dotagents `.agents` protocol, including `~/.agents/` as the global layer and `<project>/.agents/` as the workspace overlay. The RFC is not yet the released standard.

Until that refactor lands, this repository keeps the profile-era layout at its root and consumer projects may expose it through a local relative `.outfitter` symlink. This allows profile development against real projects without making a copied `.outfitter` directory authoritative.

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

From a consuming project root, create a **relative** development symlink:

```bash
target="$HOME/repos/ncrmro/.agents"
ln -s "$(realpath --relative-to="$PWD" "$target")" .outfitter
```

The relative target is interpreted from the consuming project root. Verify it before running Outfitter:

```bash
test -L .outfitter
readlink .outfitter
realpath .outfitter
outfitter profile lint --strict
outfitter profile list
```

By default this symlink is local development state, not a portable project artifact. Keep it out of the consuming repository without changing shared ignore policy:

```bash
printf '%s\n' '/.outfitter' >> .git/info/exclude
```

A project MAY commit the symlink only when its documented workspace layout guarantees the relative target for every contributor and automation environment. Otherwise, document the setup command instead.

## Development workflow

1. Edit files through the canonical checkout or the consumer's `.outfitter` symlink.
2. Keep consumer-specific behavior in the consumer repository; generalize shared profile changes here.
3. Review changes from the canonical checkout:

   ```bash
   git -C "$HOME/repos/ncrmro/.agents" status --short
   git -C "$HOME/repos/ncrmro/.agents" diff
   ```

4. Validate from at least one consuming project:

   ```bash
   outfitter profile lint --strict
   outfitter profile list
   ```

5. When changing role composition, extensions, inheritance, or subagent generation, launch the affected profile and confirm the expected tools, skills, and subagents are present.
6. Commit and push from this repository, never from a copied profile directory.

## Change standards

- Preserve focused roles and explicit inheritance.
- Keep prompts concise and behaviorally testable.
- Pin external resources when reproducibility or supply-chain risk requires it.
- Document temporary compatibility decisions and link the upstream issue that can remove them.
- Update this file when the canonical checkout location, symlink convention, validation commands, or Outfitter migration status changes.
