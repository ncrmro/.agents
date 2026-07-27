# The .agents standard, Pi skill discovery, and Outfitter

## The .agents directory standard (Dotagents)

`.agents/` is the harness-neutral home for agent-facing configuration. It exists at multiple layers:

- **Workspace layer — `<project>/.agents/`**: the consuming repository's own domain skills, agents, settings, and resources. This is where project-specific knowledge lives.
- **Global layer — `~/.agents/`**: user/owner-wide shared configuration used across repositories.
- **Remote catalog layers**: pinned `.agents` repositories consumed by tools such as Outfitter.

For this environment, the global-layer source repository is `github.com/ncrmro/.agents`, checked out under the standard repo layout at `~/repos/ncrmro/.agents`. Treat `~/.agents` as the runtime/install path; it may be managed by Home Manager or symlinked to generated files, so edit the source checkout rather than a generated or Nix-store copy.

Layout inside a `.agents/` directory:

```text
.agents/
  agents.md            # shared operating context
  system-prompt.md     # optional base system prompt
  settings.yml         # Outfitter settings: defaults, sources, launch behavior
  settings.local.yml   # ignored machine-private overrides (never committed)
  mcp.json             # MCP server configuration
  models.json          # model configuration
  agents/
    <id>/
      agent.md         # identity + loadout; runnable directly or as a subagent
      config.json      # optional loadout overrides; JSON-merges across layers
      pi/              # optional native Pi overlay: settings.json, keybindings.json, themes/
      skills/          # optional skills private to this agent
  skills/
    <name>/
      SKILL.md         # frontmatter: name, description (the loading trigger)
      references/      # deep-dive docs the skill points to
      scripts/         # helper scripts the skill invokes
      assets/          # templates and other static material
  knowledge/           # reference documents
  commands/            # slash commands
```

Conventions:

- **`.agents/skills/` is canonical for reusable skills.** A skill's `SKILL.md` stays short and operational; depth goes in `references/*.md`.
- **`AGENTS.md` is the agent-readable instruction file** at a repository root (and optionally per subproject). `CLAUDE.md` should be a symlink to `AGENTS.md` where Claude Code compatibility is needed — one source of truth, no drift.
- **Shared/global content should stay project-agnostic**: no consumer project names, company/customer specifics, credentials, or machine-specific absolute paths. Project specifics belong in the consuming repository's `.agents/` and `AGENTS.md`; machine specifics belong only in ignored local settings.

## Pi usage

Pi implements the Agent Skills standard and discovers skills from both Pi-native and `.agents` locations. Relevant `.agents` locations are:

- `~/.agents/skills/`
- `.agents/skills/` in the current project and ancestor directories

Pi scans these locations at startup, exposes skill names/descriptions to the model, and the agent loads the full `SKILL.md` on demand. Use `.agents/skills/<name>/SKILL.md` for skills intended to work across Pi, Claude Code, and Outfitter-mediated runs.

## Pi extensions in an Outfitter agent

Writing a Pi extension is usually small TypeScript: export a default function that receives `ExtensionAPI`, then register tools, commands, shortcuts, providers, UI, or event handlers. Test local files directly with Pi before putting them in an Outfitter agent:

```bash
pi -e ./path/to/extension.ts
```

Outfitter agents select Pi extensions in the agent loadout:

```md
---
name: engineer
extensions:
  - git:github.com/ai-outfitter/deepwork
  - npm:@owner/pi-extension@1.2.3
---
```

For shared or reproducible use, package the extension as a Pi package and select it with a `git:` or `npm:` specifier. Include a `package.json` with a `pi.extensions` entry when the extension is not in a conventional `extensions/` directory. Put runtime dependencies in `dependencies`; list Pi-provided packages such as `@earendil-works/pi-coding-agent`, `@earendil-works/pi-ai`, `@earendil-works/pi-tui`, and `typebox` as peer dependencies with a `"*"` range rather than bundling them.

For a local Outfitter override of an existing agent, prefer a higher-precedence `agents/<agent-id>/config.json` instead of copying `agent.md`:

```json
{
  "extensions": [
    "git:github.com/ai-outfitter/deepwork",
    "git:github.com/you/my-pi-extension@my-branch"
  ]
}
```

`config.json` is a loadout override, but arrays replace rather than append; preserve existing extension entries you still need. Do not use a partial `agent.md` for a one-field override because the winning `agent.md` replaces the lower-layer identity.

Outfitter's `extensions:` loadout projects `git:` and `npm:` Pi package sources. For raw local extension files during development, either keep testing with `pi -e` or use the native Pi overlay in an uncommitted higher-precedence layer:

```text
.agents/agents/<agent-id>/pi/settings.json
```

```json
{
  "extensions": ["/absolute/path/to/extension.ts"]
}
```

Absolute local paths are machine-specific: keep them out of shared catalogs, or route them through a gitignored local layer/source while iterating.

## How Outfitter works with it

Outfitter is the toolchain for `.agents`: it resolves agent configuration from local and remote `.agents` trees, composes agents, skills, knowledge, MCP, models, and commands by slug, and launches the result through wrapped harnesses such as Pi or Claude Code.

Outfitter does not own a separate authored configuration format. The `.agents/` tree is the source of truth: useful without Outfitter, committed and reviewed like code, and shared through personal, project, organization, or community catalogs.

Layer precedence is:

1. `<project>/.agents/`
2. `~/.agents/`
3. pinned remote catalogs

Standalone `.agents` repositories — where the repository root is the payload — are the normal way to develop and share reusable layers. In this setup, `ncrmro/.agents` is both the personal global catalog and the source repo for the installed `~/.agents` layer.

When you encounter old `.outfitter/` profile-era configuration, migrate it to `.agents/` rather than extending it.

## Validation loop

After changing `.agents` resources or Outfitter settings:

```bash
cd ~/repos/ncrmro/.agents
outfitter validate --strict
outfitter list agents
outfitter list skills
```

For a consuming repository, validate from that repository so Outfitter sees the effective workspace + global + remote layer composition.
