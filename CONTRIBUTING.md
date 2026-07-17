# Contributing

Rules for changes committed to this repository. For machine setup, validation commands, and the publish workflow, follow the [local development runbook](docs/runbook/local-development.md).

## Scope

Committed changes here MUST be project-agnostic:

- No hardcoded consuming project, company, customer, domain taxonomy, or machine-specific consumer path.
- Define roles by reusable responsibilities and outcomes; project context lives in the consumer.
- No credentials, tokens, sessions, transcripts, caches, generated prompts, or absolute machine paths.
- Machine paths go in ignored `local/settings.yml`; published sources and reviewed refs in committed `settings.yml`.

Consuming repositories are test environments, not sources of shared policy — generalize before committing here.

## Change standards

- Preserve focused roles and explicit inheritance; keep prompts concise and behaviorally testable.
- Keep the published and live source graphs equivalent and in the same precedence order.
- Pin published sources when reproducibility or supply-chain risk requires it.
- Document compatibility exceptions and link the upstream issue or release that can remove them.
- Update `AGENTS.md` and the runbook whenever checkout locations, catalog roots, source precedence, validation commands, or Outfitter migration status changes.

## Landing a change

Edit a resource only in the repository that owns it, validate from a consumer, and publish per the [development workflow](docs/runbook/local-development.md#development-workflow).
