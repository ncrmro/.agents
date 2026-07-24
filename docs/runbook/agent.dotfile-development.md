# Runbook: adopting agent dotfiles

The start-to-finish flow for adopting agent dotfiles: establish your personal `~/.agents` layer first, then point it at local development checkouts, then bring projects on board. Read and execute it in that order.

**Why this order matters.** If you start per project, every new repository restarts the same debate — which skills to copy in, where they live, how they stay in sync — and the copies immediately begin to drift. Decision paralysis and churn compound as you move between projects. Starting from a personal layer inverts that: conventions are decided once, every project inherits them, and a resource only graduates into a project (or upstream) after it has proven itself. The layers below exist to make "where does this go?" a question you answer once.

## The layer model

Three layers, from most personal to most shared:

1. **Personal** — `<username>/.agents`, linked at `~/.agents`. Your agents, skills, and source graph.
2. **Machine** — ignored `settings.local.yml` files pointing at live local checkouts and worktrees. Never committed.
3. **Project** — a consumer repository's `.agents/` tree with its own domain agents, skills, and context.

Outfitter v1 resolves resource layers from highest to lowest precedence: project `.agents/`, personal `~/.agents/`, then configured `sources` in listed order. Changes can start in the personal layer and move upstream after they prove reusable (see `AGENTS.md` for this repository's source graph).

## Step 1: establish the personal layer

Create (or fork) a `<username>/.agents` repository and link it to `~/.agents`:

```bash
mkdir -p "$HOME/repos/<username>"
git clone git@github.com:<username>/.agents.git "$HOME/repos/<username>/.agents"
ln -s "$HOME/repos/<username>/.agents" "$HOME/.agents"
```

The symlink makes the repo the durable home of your agent configuration while keeping it a normal, reviewable git repository. Outfitter v1 implements the native Dotagents layer from [RFC #165](https://github.com/ai-outfitter/outfitter/issues/165) and reads `~/.agents/` directly.

Your repository should contain, at minimum:

- `agents/<slug>/agent.md` — durable identities and their loadouts, defined by reusable responsibilities.
- `skills/<slug>/SKILL.md` — personal capabilities selected by those agents.
- `settings.yml` — `default_agent`, `default_harness`, and reviewed upstream `.agents` sources.

Everything here MUST be project-agnostic. The moment something references a specific project, it belongs in that project instead.

## Step 2: point at local development checkouts

To edit upstream resources live, override the pinned graph with an ignored machine-local file. Create `settings.local.yml` beside `settings.yml`, listing absolute paths to the `.agents` payload roots of your checkouts:

```yaml
# ~/.agents/settings.local.yml (ignored)
sources:
  # Sources are lower precedence than project and personal resources.
  - path: /home/<user>/repos/upstream-org/some-catalog
```

Point an entry at a **worktree** when the checkout's current branch has unrelated work — never switch or reset a checkout you don't own the state of. The local file replaces the `sources` list from `settings.yml`, so include every source needed for the development run.

Validate and inspect after any graph change:

```bash
outfitter validate
outfitter list agents
outfitter list skills --agent founder

validation_root="$(mktemp -d)"
for agent in founder engineer platform researcher; do
  outfitter dump --agent "$agent" --out "$validation_root/$agent"
done
```

`outfitter validate --strict` is useful when the source graph has no intentional shadowing. In this repository, the personal `founder` and `engineer` agents intentionally override the default catalog, so normal validation reports those shadows as warnings.

## Step 3: bring projects on board

A project adopts the same pattern in miniature:

1. **Commit project resources** — put project-specific context, agents, and skills under `<project>/.agents/`.
2. **Commit project settings when needed** — use `<project>/.agents/settings.yml` for shared project defaults or sources.
3. **Ignore machine state** — add `<project>/.agents/settings.local.yml` and generated artifacts to the project ignore file.
4. **Develop against checkouts** — put absolute source paths only in the ignored `settings.local.yml`.

Project-owned resources automatically override personal and remote resources with the same slug.

## Moving resources between layers

The layers give every resource one obvious home and a low-churn path between homes:

- **New idea** → start in your personal layer (`~/.agents`). It is immediately available in every project unless a project resource with the same slug overrides it.
- **Personal → upstream** — generalize it, move it to the owning catalog repository, bump refs. Behavior never changes for you: your personal copy keeps overriding until you delete it, so the handoff is zero-churn.
- **Project → personal** (promoting a project skill you want everywhere): copy it into `~/.agents/skills/`, select it in the relevant agents, then remove the project copy in a reviewed commit.

## Summary checklist

- [ ] `<username>/.agents` cloned and symlinked at `~/.agents`
- [ ] Native agents live at `agents/<slug>/agent.md`
- [ ] Published `settings.yml` uses `default_agent`, `default_harness`, and `sources`
- [ ] Ignored `settings.local.yml` points at live checkouts/worktrees
- [ ] Each project keeps project-owned resources under `<project>/.agents/`
- [ ] `outfitter validate` and representative `outfitter dump` commands pass
