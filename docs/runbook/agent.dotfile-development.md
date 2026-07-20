# Runbook: adopting agent dotfiles

The start-to-finish flow for adopting agent dotfiles: establish your personal `~/.agents` layer first, then point it at local development checkouts, then bring projects on board. Read and execute it in that order.

**Why this order matters.** If you start per project, every new repository restarts the same debate — which skills to copy in, where they live, how they stay in sync — and the copies immediately begin to drift. Decision paralysis and churn compound as you move between projects. Starting from a personal layer inverts that: conventions are decided once, every project inherits them, and a resource only graduates into a project (or upstream) after it has proven itself. The layers below exist to make "where does this go?" a question you answer once.

## The layer model

Three layers, from most personal to most shared:

1. **Personal** — `<username>/.agents`, linked at `~/.agents`. Your roles, skills, and source graph. Highest precedence everywhere you work.
2. **Machine** — ignored `legacy/outfitter/local/settings.yml` files pointing at live local checkouts and worktrees. Never committed.
3. **Project** — a consumer repository's committed, pinned source graph plus its own domain skills and context.

Outfitter merges `profile_sources` last-wins: the last entry in the list is the highest precedence. Your personal layer is always listed last, so it overrides everything, and changes trickle upstream without ever changing behavior out from under you (see `AGENTS.md` for the full precedence and source-graph reference).

## Step 1: establish the personal layer

Create (or fork) a `<username>/.agents` repository and link it to `~/.agents`:

```bash
mkdir -p "$HOME/repos/<username>"
git clone git@github.com:<username>/.agents.git "$HOME/repos/<username>/.agents"
ln -s "$HOME/repos/<username>/.agents" "$HOME/.agents"
```

The symlink makes the repo the durable home of your agent configuration while keeping it a normal, reviewable git repository. It also positions you for the Dotagents `.agents` protocol (RFC [ai-outfitter/outfitter#165](https://github.com/ai-outfitter/outfitter/issues/165)), which proposes `~/.agents/` as the native global layer; until that lands, Outfitter consumes the repo as a profile source.

Your repository should contain, at minimum:

- `legacy/outfitter/profiles/` — transitional Outfitter 0.10 roles defined by reusable responsibilities.
- `skills/` — personal skills, discovered through the profile source's catalog root.
- `legacy/outfitter/settings.yml` — the published Outfitter 0.10 graph, with its sibling `./profiles` listed last.

Everything here MUST be project-agnostic. The moment something references a specific project, it belongs in that project instead.

## Step 2: point at local development checkouts

To edit upstream resources live (or your own, from a consumer), replace the pinned graph with an ignored machine-local one. Create `legacy/outfitter/local/settings.yml` listing absolute paths to your checkouts, keeping the same order — your personal legacy profiles last:

```yaml
# ~/.agents/legacy/outfitter/local/settings.yml (ignored)
profile_sources:
  # Merged last-wins: LAST entry is HIGHEST precedence.
  - path: /home/<user>/repos/upstream-org/some-catalog/profiles
  # Personal overrides — highest precedence; keep last.
  - path: /home/<user>/repos/<username>/.agents/legacy/outfitter/profiles
```

Point an entry at a **worktree** when the checkout's current branch has unrelated work — never switch or reset a checkout you don't own the state of. Concrete checkout layout, clone commands, worktree setup, and the full template for this machine live in the [local development runbook](local-development.md).

Validate after any graph change:

```bash
outfitter profile lint --strict
outfitter profile list
```

## Step 3: bring projects on board

A project adopts the same pattern in miniature:

1. **Commit the portable graph** — `.outfitter/settings.yml` with the flattened published sources at pinned refs, your `<username>/.agents` listed last. The project works identically on CI and on machines that aren't yours.
2. **Ignore machine state** — `.outfitter/.gitignore` with `/local/` and generated artifacts.
3. **For live development**, copy (never symlink) the machine-local template into the project as `.outfitter/local/settings.yml`. It replaces the committed graph wholesale while it exists; delete it to test the published graph.

Project-owned skills and context stay in the project. The project layer only pins *which revisions* of the shared layers it consumes.

## Moving resources between layers

The layers give every resource one obvious home and a low-churn path between homes:

- **New idea** → start in your personal layer (`~/.agents`). It is immediately available in every project via precedence, with nothing copied.
- **Personal → upstream** — generalize it, move it to the owning catalog repository, bump refs. Behavior never changes for you: your personal copy keeps overriding until you delete it, so the handoff is zero-churn.
- **Project → personal** (promoting a project skill you want everywhere): copy it into `~/.agents/skills/`, select it in your profiles, then remove the project copy in a reviewed commit. Note that project-committed skills shadow shared ones in plain (non-Outfitter) sessions, so keep the project copy until every consumer of it launches through Outfitter — the two copies coexist safely in the meantime, at the cost of syncing edits manually.

## Summary checklist

- [ ] `<username>/.agents` cloned and symlinked at `~/.agents`
- [ ] Published `legacy/outfitter/settings.yml` pinned, sibling `./profiles` last
- [ ] Ignored `legacy/outfitter/local/settings.yml` points at live checkouts/worktrees
- [ ] Each project commits its pinned graph and ignores `/local/`
- [ ] `outfitter profile lint --strict` clean at every boundary
