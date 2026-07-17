# Shared agent configuration

This repository is the canonical, project-agnostic composition layer for shared agent roles and Outfitter development resources. Consuming repositories use it as an Outfitter settings source; they keep their own domain context, skills, and operating rules locally.

## Transitional architecture

Outfitter currently authors and loads profiles from `.outfitter/`. Open RFC [ai-outfitter/outfitter#165](https://github.com/ai-outfitter/outfitter/issues/165) proposes replacing profile-era `.outfitter` configuration with the Dotagents `.agents` protocol, including `~/.agents/` as the global layer and `<project>/.agents/` as the workspace overlay. The RFC is not yet the released standard.

Until that refactor lands, this repository provides two equivalent source graphs:

1. `settings.yml` pins published GitHub revisions for portable consumers and CI.
2. Ignored `local/settings.yml` replaces those sources with live local checkouts for development.

A consumer commits the flattened published source graph, then writes its own ignored `.outfitter/local/settings.yml` when it wants live edits. That local file includes this checkout's `profiles/` directory and the local repositories that publish the other selected resources. It MUST be a regular settings file, not a symlink. Outfitter does not recursively load `settings.yml` from a profile source, and a user's higher-precedence `profile_sources` can mask lower remote settings. Keeping both graphs explicit avoids that ambiguity. The project-local settings layer replaces `profile_sources` as a whole, so the live graph cleanly overrides the published graph.

## Scope and portability

Committed changes in this repository MUST be project-agnostic:

- Do not hardcode a consuming project, company, customer, deployment, domain taxonomy, or machine-specific consumer path.
- Keep project-specific context in the consumer's `AGENTS.md`, `.agents/skills/`, documentation, or other project-owned files.
- Define roles by reusable responsibilities and outcomes.
- Do not commit credentials, tokens, auth state, sessions, transcripts, caches, generated prompts, or machine-specific absolute paths.
- Keep machine paths in ignored `local/settings.yml`; keep published sources and reviewed refs in committed `settings.yml`.
- Treat profile-era files as transitional artifacts requiring deliberate migration if RFC #165 is implemented.

Consuming repositories are test environments, not sources of shared policy. Generalize improvements before committing them here.

## Source graph

Sources are ordered from lowest to highest precedence. Later sources override or compose over same-ID resources from earlier sources.

| Source | Published catalog root | Typical local source | Resources used here |
| --- | --- | --- | --- |
| `ai-outfitter/default-profiles` | `profiles/` | `~/repos/unsupervised/ai-outfitters/default-profiles/profiles` | Default roles and `pyramid-principle` |
| `ai-outfitter/community-profiles` | `profiles/` | `~/repos/unsupervised/ai-outfitters/community-profiles/profiles` | Community roles such as `github-actions` |
| `ai-outfitter/outfitter` | `.outfitter/` on current main | Checkout-dependent; this machine's development branch publishes from `code/cli/` | Local `outfitter` skill |
| `ai-outfitter/actions` | `.outfitter/` | Primary checkout or a clean main worktree's `.outfitter/` | `outfitter-actions` skill |
| `ncrmro/.agents` | `profiles/` | `~/repos/ncrmro/.agents/profiles` | Highest-precedence shared roles |

The `founder` profile selects the local `outfitter` skill. The actions source is present for `outfitter-actions` development, but the checked-out skill currently uses glob references that Outfitter 0.10.0 cannot materialize. Select it in a profile only when validating with a compatible Outfitter checkout or release.

## Repository layout

- `settings.yml` defines the portable, pinned remote source graph.
- `profiles/` contains project-agnostic roles owned by this repository.
- `local/settings.yml` is ignored machine state containing the equivalent live source graph.
- `AGENTS.md` defines maintenance and environment conventions.
- `*.generated-system-prompt.md` files are ignored validation artifacts.

## Standard checkout layout

Use this layout on development machines:

```text
~/repos/
  ncrmro/
    .agents/
  unsupervised/
    ai-outfitters/
      actions/
      community-profiles/
      default-profiles/
      outfitter/
    worktrees/
      actions/
        main/                 # optional when actions/ is on another branch
  <consumer-owner>/
    <consumer-project>/
```

Clone missing repositories:

```bash
mkdir -p "$HOME/repos/ncrmro" "$HOME/repos/unsupervised/ai-outfitters"
git clone git@github.com:ncrmro/.agents.git \
  "$HOME/repos/ncrmro/.agents"
git clone git@github.com:ai-outfitter/actions.git \
  "$HOME/repos/unsupervised/ai-outfitters/actions"
git clone git@github.com:ai-outfitter/community-profiles.git \
  "$HOME/repos/unsupervised/ai-outfitters/community-profiles"
git clone git@github.com:ai-outfitter/default-profiles.git \
  "$HOME/repos/unsupervised/ai-outfitters/default-profiles"
git clone git@github.com:ai-outfitter/outfitter.git \
  "$HOME/repos/unsupervised/ai-outfitters/outfitter"
```

Do not switch or reset a checkout containing unrelated work. If a published resource is absent from the current branch, create a clean worktree instead. For example:

```bash
actions="$HOME/repos/unsupervised/ai-outfitters/actions"
actions_main="$HOME/repos/unsupervised/worktrees/actions/main"
mkdir -p "$(dirname "$actions_main")"
git -C "$actions" fetch origin
git -C "$actions" worktree add "$actions_main" main
git -C "$actions_main" merge --ff-only origin/main
```

If `main` is already checked out elsewhere, point the local source graph at that checkout instead of creating a duplicate worktree.

## Portable consumer configuration

A consuming project SHOULD commit `.outfitter/settings.yml` with the flattened published graph. Keep its order equivalent to this repository's `settings.yml`, and replace this repository's local `./profiles` entry with a pinned GitHub source:

```yaml
default_profile: founder
profile_export: false
profile_sources:
  - github: ai-outfitter/default-profiles
    ref: <reviewed-commit>
    path: profiles
  - github: ai-outfitter/community-profiles
    ref: <reviewed-commit>
    path: profiles
  - github: ai-outfitter/outfitter
    ref: <reviewed-commit>
    path: .outfitter
  - github: ai-outfitter/actions
    ref: <reviewed-commit>
    path: .outfitter
  - github: ncrmro/.agents
    ref: <reviewed-commit>
    path: profiles
```

All catalogs are public, so Outfitter can sync them without private-catalog configuration. After changing a source or shared profile, push its owning repository and bump the relevant consumer ref.

The consumer SHOULD ignore only machine-private state:

```gitignore
# .outfitter/.gitignore
/local/
*.generated-system-prompt.md
```

## Live local source graph

Create ignored `local/settings.yml` with absolute paths as the canonical machine-local composition template. Use a shell-expanded `$HOME`; do not write literal `~`, because Outfitter does not shell-expand it.

```bash
catalog="$HOME/repos/ncrmro/.agents"
mkdir -p "$catalog/local"
cat > "$catalog/local/settings.yml" <<EOF
default_profile: founder
profile_export: true
profile_sources:
  - path: $HOME/repos/unsupervised/ai-outfitters/default-profiles/profiles
  - path: $HOME/repos/unsupervised/ai-outfitters/community-profiles/profiles
  - path: $HOME/repos/unsupervised/ai-outfitters/outfitter/.outfitter
  - path: $HOME/repos/unsupervised/ai-outfitters/actions/.outfitter
  - path: $HOME/repos/ncrmro/.agents/profiles
EOF
```

Adjust only machine-local entries when a development branch publishes from another root. On this machine:

- Outfitter's active development checkout publishes the `outfitter` skill from `code/cli/`.
- Actions main is isolated at `~/repos/unsupervised/worktrees/actions/main`, so its source is that worktree's `.outfitter/`.

From a consumer using the same machine, create a regular project-local settings file from the template:

```bash
mkdir -p .outfitter/local
cp "$HOME/repos/ncrmro/.agents/local/settings.yml" \
  .outfitter/local/settings.yml
test -f .outfitter/local/settings.yml
test ! -L .outfitter/local/settings.yml
```

The copied settings explicitly include `$HOME/repos/ncrmro/.agents/profiles` as the highest-precedence local profile source. Keep the consumer copy synchronized when the machine-local source graph changes; do not replace it with a symlink.

Verify every boundary:

```bash
outfitter profile lint --strict
outfitter profile list
```

The expected profile list includes this repository's roles plus profiles from the default and community catalogs. Remove or rename the consumer's local settings file temporarily, run `outfitter sync`, and validate again when testing the portable published graph.

## Development workflow

1. Confirm each source checkout is clean enough for the intended work; preserve unrelated branches and changes.
2. Edit a resource only in the repository that owns it:
   - shared roles here;
   - `outfitter-actions` in `ai-outfitter/actions`;
   - community roles in `ai-outfitter/community-profiles`;
   - default roles in `ai-outfitter/default-profiles`;
   - the `outfitter` skill in `ai-outfitter/outfitter`.
3. Validate from a consumer with `outfitter profile lint --strict` and `outfitter profile list`.
4. Launch the affected profile and confirm expected tools, skills, subagents, and prompt behavior.
5. Review and commit in each owning repository independently.
6. Update pinned remote refs in this repository only after reviewing upstream diffs.
7. Push this repository, update each consumer's affected source refs, remove the local override, and run `outfitter sync` to test the published graph.

## Change standards

- Preserve focused roles and explicit inheritance.
- Keep prompts concise and behaviorally testable.
- Keep the published and live source graphs equivalent and in the same precedence order.
- Pin published sources when reproducibility or supply-chain risk requires it.
- Document compatibility exceptions and link the upstream issue or release that can remove them.
- Update this file whenever checkout locations, catalog roots, source precedence, validation commands, or Outfitter migration status changes.
