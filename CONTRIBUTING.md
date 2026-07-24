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

## Landing a change

Edit a resource only in the repository that owns it and validate from a consumer using the [development workflow](docs/runbook/agent.dotfile-development.md#step-2-point-at-local-development-checkouts).
