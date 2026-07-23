# Ideas

Candidate shared-agent resources and runbooks that are not yet ready to become repository contracts. Each entry records the useful intent of an earlier draft without treating that draft as approved guidance.

## Project operating contract

Establish a small, reviewable contract when starting a project:

- Commit a canonical mission statement that names the audience, desired outcome, non-goals, evidence of success or failure, and review horizon.
- Represent KPIs as durable, machine-readable interfaces with stable IDs, units, direction, ownership, source, computation, dimensions, freshness, review cadence, and targets or decision thresholds.
- Select an iteration loop according to the cost of breakage: direct-to-main experimentation, pull-request review, deliberate release automation, or full release-candidate review.
- Keep `TASK.md` as an execution view with one coordinator, explicit acceptance criteria, validation evidence, and either local or issue-backed completion boundaries.
- Link the mission, KPIs, delivery loop, development environment, and readiness commands from a concise project-setup document.

Former drafts: `docs/runbook/project.setup.md`, `project.mission-success.md`, `project.kpis.md`, and `project.iteration-loops.md`.

## Shared agent-dotfile development

Turn the personal-to-shared agent configuration workflow into one maintained skill and runbook:

- Standardize checkout and worktree locations for personal resources and upstream Outfitter catalogs.
- Preserve last-wins source precedence across portable pinned settings and ignored live-checkout settings.
- Keep machine paths local, generalize resources before promotion, and validate changes from a consumer before publishing upstream.
- Teach agents to inspect existing layers, avoid disturbing unrelated checkout state, and report the exact source graph they validated.
- Revisit the transitional Dotagents configuration represented by `default_agent: founder`, `default_harness: pi`, and the pinned `ai-outfitter/default-profiles` source once the profile-era migration settles.

Former drafts: `docs/runbook/environment.development.md`, `skills/local-agent-dotfiles/SKILL.md`, and `settings.yml`.

## Cloudflare Workers deployment runbook

Create a project-agnostic GitHub Actions pattern for deploying a Workers monorepo:

- Detect per-application and shared-workspace changes, then construct a dynamic deployment matrix so unaffected applications do not build.
- Pin third-party actions to verified commit SHAs and explicitly fan shared-library changes out to every consumer.
- Document least-privilege Cloudflare credentials, noninteractive Wrangler deployment, custom-domain verification, and manual full-deployment behavior.
- Include a validation matrix for path filters, clean checkouts, builds, deployments, and live URLs.
- Treat staging D1 reseeding as a separate, explicitly authorized extension with backups and production safeguards.

Former draft: `docs/runbook/environment.cloudflare-workers.md`.

## Kubernetes observability runbook

Develop a version-pinned Helm/GitOps runbook for a self-hosted observability stack:

- Define responsibilities and data paths for kube-prometheus-stack, Grafana, Mimir, Loki, Tempo, Pyroscope, and Alloy.
- Distinguish small-cluster and production deployment modes, requiring external object storage, workload identity, tested high availability, and explicit Kafka-era architecture decisions where applicable.
- Keep versions, values, Alloy configuration, dashboards, alerts, render checks, and upgrade notes in the repository while keeping credentials in managed secrets.
- Validate ingestion and querying for metrics, logs, traces, and profiles end to end; monitor the monitoring stack through an independent path.
- Specify component-aware upgrade, backup, restore, and removal procedures instead of relying on generic Helm rollback or uninstall behavior.

Former draft: `docs/runbook/kubernetes.observability.md`.

## Hardware-key operations runbook

Develop a safety-first YubiKey runbook spanning disk unlock, administrative access, local elevation, and application authentication:

- Require independently enrolled daily and spare keys, offline recovery material, private inventory, and tested break-glass access.
- Cover FIDO2-backed LUKS2 enrollment, OpenSSH security-key credentials, PAM U2F rollout, mobile WebAuthn, and OATH only as a legacy fallback.
- Separate the authenticator's FIDO2, OATH, PIV, OpenPGP, and OTP applications so resets and credentials are never conflated.
- Stage every change with old access retained, test one service at a time, and include lost-key, blocked-PIN, revocation, and quarterly verification procedures.
- Verify commands and compatibility against the exact operating system, systemd, OpenSSH, PAM, firmware, and YubiKey models before promoting the draft.

Former draft: `docs/runbook/hardware.keys.md`.

## Workflow and maintenance skills

- **Workflow leader:** explore a Zejent-backed role that watches GitHub repositories, organizes work into milestones, and keeps issue state aligned with the selected delivery loop. Former note: `profiles/workflow.leader.md`.
- **Project maintainer:** build a real skill around repository health, CODEOWNERS, issue templates, RFCs, triage, and maintenance checklists. The prior directory was only an empty scaffold plus a link to GitHub's CODEOWNERS documentation.
- **Rapid prototyping:** define when speed is the priority, what shortcuts are allowed, what evidence is still mandatory, and how a prototype graduates or is discarded. The prior skill file was empty.

## Generated-tool integration

- Evaluate whether DeepWork's deep planning, job authoring, repair, shared-job, and review workflows belong in this repository. Regenerate its schema and status manifests from the owning tool rather than committing `.deepwork` runtime state.
- Keep downloaded Outfitter source repositories in a machine-local cache outside the committed catalog, with an ignore rule and a reproducible refresh command. Do not treat cached Git repositories as source files.
- Empty scratch files and template placeholders should not enter the catalog until they contain a scoped, testable resource.

Former generated or empty paths: `.deepwork/`, `cache/`, `SCRATCH.md`, `skills/project-maintainer/`, and `skills/rapid-prototyping/`.
