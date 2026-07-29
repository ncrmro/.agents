# Contributing

Rules for changes committed to this repository. For machine setup and validation commands, follow the [agent dotfile development runbook](docs/runbook/agent.dotfile-development.md).

## Scope

Committed changes here MUST be project-agnostic:

- No hardcoded consuming project, company, customer, domain taxonomy, or machine-specific consumer path.
- Define roles by reusable responsibilities and outcomes; project context lives in the consumer.
- No credentials, tokens, sessions, transcripts, caches, generated prompts, or absolute machine paths.
- Machine paths go in ignored `settings.local.yml`; published sources and reviewed refs go in committed `settings.yml`.

Consuming repositories are test environments, not sources of shared policy — generalize before committing here.

## Change standards

- Preserve focused agents and explicit loadouts; keep prompts concise and behaviorally testable.
- Keep native v1 resources under `agents/` and `skills/`; legacy `profiles/` are compatibility-only.
- Keep the published and live v1 source graphs equivalent and in the same precedence order.
- Pin published sources when reproducibility or supply-chain risk requires it.
- Document compatibility exceptions and link the upstream issue or release that can remove them.
- Update `AGENTS.md` and the runbook whenever checkout locations, catalog roots, source precedence, validation commands, or Outfitter migration status changes.

## Skill scripts

- A script MUST NOT silently fall back to another way of running a missing
  dependency. A fallback turns a missing tool into a slow, surprising success
  that nobody fixes.
- Check every external tool up front and fail with exit 127, naming the tool
  and offering install lines for the package managers a reader plausibly has:

  ```
  session-record.sh: check-jsonschema is required but is not on PATH.

  HINT  install it with one of:
          nix profile install nixpkgs#check-jsonschema
          pipx install check-jsonschema
          brew install check-jsonschema
  ```

  `skills/project-notes/scripts/lib/require.sh` is the reference
  implementation; copy it rather than depending on another skill's path, so a
  skill stays self-contained when it moves catalogs.
- Validate structured input against a JSON Schema kept beside the script in
  `schemas/`, so the rules are reviewable data rather than code. The validator
  is an implementation detail: callers pass fields or JSON, never a schema
  path, and never learn which validator is in use.
- A script that writes a file an agent would otherwise hand-edit MUST own that
  file completely: validate, render, and write. Hand-editing is where fields go
  missing and neighbouring content changes by accident.

## Landing a change

Edit a resource only in the repository that owns it and validate from a consumer using the [development workflow](docs/runbook/agent.dotfile-development.md#step-2-point-at-local-development-checkouts).
