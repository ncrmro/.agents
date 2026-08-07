---
name: sdlc-report
description: Assess the agentic software development lifecycle maturity of an organization or a set of user repositories and return a typed JSON report plus a human summary. Use when a user asks where their org sits on the agentic-SDLC ramp, what to automate next, or for an agentic maturity / readiness / SDLC report. Read-only; runs on a local coding harness with forge access.
---

# SDLC report

Produce one report that says where an organization (or a group of a user's
repositories) sits on the agentic-SDLC maturity ramp, with the evidence for
that placement and the highest-leverage next steps. The report is typed JSON
validated against `schemas/sdlc-report.schema.json`, with a Markdown summary
beside it. Treat the gaps the report finds as the backlog.

The person who runs this is usually an engineer inside the org who already
uses a local coding harness and has read access to the repos. This skill is
read-only. Gather from two evidence sources and record which one each claim
came from:

- **The forge API** (use the `git-forge` skill for the GitHub-versus-Forgejo
  interface choice) — the authority for org-wide inventory, workflows,
  required checks, and PR metrics.
- **Local checkouts the user already has** — read them directly; they are the
  cheapest evidence and show practice the forge cannot (harness configs,
  untracked instruction files, `.agents/` trees in progress). Ask the user
  where their checkouts live.

Do not clone new repositories. Do not change any repository, setting, or
forge object.

## The maturity ramp

Rate each repository, and the org as a whole, on Outfitter's adoption ramp.
The canonical definition is the "ramp to an autonomous lifecycle" section of
[outfitter `docs/philosophy.md`](https://github.com/ai-outfitter/outfitter/blob/main/docs/philosophy.md);
this table extends it with level 0 for rating purposes.

| Level | Name | Meaning |
| --- | --- | --- |
| 0 | none | No AI use in the development workflow. |
| 1 | assisted | Autocomplete and chat; human hands stay on the keyboard. |
| 2 | delegated | A local agent does tasks; the human defines the idea and reviews the PR. |
| 3 | automated | Workflows run without a laptop: issue/message/schedule triggers agents in CI or a cluster; adversarial review is a pipeline step; session logs are captured before merge. |
| 4 | governed | One shared, pinned catalog of agents, skills, and policy; agent actions land in an auditable record; resident agents work as onboarded teammates. |
| 5 | self-improving | The audit record feeds evals and model improvement; humans set goals and acceptance gates. |

The org level is not the maximum repo level — it is the level the org can
claim consistently. One level-3 repo in a level-1 org is a pilot, not a level.

## Model choice

Ask the user which model tier to run the assessment on before you start, and
recommend a mid-tier model by default — in Claude terms an Opus- or
Sonnet-class model rather than the top tier; use the equivalent tier names
for whatever harness and vendor the user runs. The scan is mechanical and the
schema and evidence rules do the quality work, so the top tier adds cost, not
accuracy. Reserve it for the verdict and recommendations only when the user
asks for deeper analysis.

## Procedure

Steps 3's per-repo scans are independent; run them concurrently.

1. **Confirm scope with the user.** Which forge, which org or which list of
   repos, and whether private repos are in scope. Cap the survey at ~30
   repos. When the org is larger, sample the most recently pushed repos by
   default, agree on the sample with the user, and record the rule in
   `scope.sampling_note`. Scan an employer org beyond the user's stated
   involvement only when the user explicitly asks.
2. **Inventory in one call.**
   `gh repo list <org> --json name,visibility,defaultBranchRef,pushedAt --limit <N>`
   (or the Forgejo equivalent via `tea`/API). This also supplies the
   activity data step 1's sampling needs.
3. **Scan each repo.** When the user has a local checkout, read it directly.
   Otherwise one tree listing answers most schema fields without cloning:
   `gh api "repos/<org>/<repo>/git/trees/HEAD?recursive=1"` shows whether
   `AGENTS.md`, `CLAUDE.md`, other instruction files, a `.agents/` tree, and
   workflow files exist. Fetch content only for the few files the tree
   revealed as interesting:
   - Workflow files: which are agent workflows, and their triggers. Record
     entry points with this vocabulary where it fits — `issue`, `pr-comment`,
     `chat`, `email`, `schedule`, `manual` — and free-form strings where it
     does not.
   - Preview environments and CI smoke tests.
   - Required checks, a merge queue, and agent or adversarial review steps.
     Read these from the rulesets API (`gh api repos/<org>/<repo>/rulesets`
     and the branch rules endpoint) — the classic branch-protection endpoint
     often returns 404 even where rules exist.
   - Session capture: are agent session logs uploaded or archived (CI
     artifacts, a records store), or lost when the session ends on the
     laptop.
   - Docs quality (`none`/`thin`/`adequate`/`strong`): judge from the README
     plus tree metadata (count and size of docs); read at most a handful of
     doc files per repo. The bar: could an agent start work from them alone?
4. **Gather org-level signals.** Harnesses and model vendors in use (from
   workflow files, docs, and what the user reports — mark which); shared
   catalogs and whether they are pinned; where audit records live; how model
   spend is routed (for example, burn bundled credits first). Derive
   duplicated tools and skills from the tree listings step 3 already
   fetched — compare `.agents/skills/*` and workflow names across repos; do
   not re-scan.
5. **Compute metrics where derivable.** One GraphQL query per repo over
   merged PRs (`createdAt`, `mergedAt`, review counts), bounded by the last
   90 days or the last 50 merged PRs, whichever is smaller; record the bound
   in `metrics.window_days`. Use these definitions so reports are comparable
   across runs and orgs: cycle time is the median days from PR open to
   merge; rework rate is the fraction of merged PRs with at least one review
   thread; include bot-authored PRs and say so in `metrics.notes`. Leave a
   metric `null` with a note when not derivable — do not estimate.
6. **Write the report.** Emit `sdlc-report.json` conforming to the schema and
   a `sdlc-report.md` summary ordered: verdict, evidence, gaps,
   recommendations. Validate with
   `check-jsonschema --schemafile <skill-dir>/schemas/sdlc-report.schema.json sdlc-report.json`,
   where `<skill-dir>` is this skill's directory. If `check-jsonschema` is
   not on PATH, stop and tell the user how to install it; do not skip
   validation silently. Fill `evidence_limits` honestly: what the scan could
   not see (private repos, local-only usage, vendor dashboards) bounds every
   claim.

## Recommendations shape next steps

Each recommendation targets the next rung, not the top of the ramp. Automate
a single workflow end to end (for example, feature idea → reviewed PR) before
generalizing. Never recommend automating a workflow the org has not first
done manually. Move the human locus of control outward one layer at a time.
When step 4 found duplicated tools or skills, recommend consolidating them
first — a shared catalog entry beats N private reimplementations and needs no
new capability.

## After the report: offer the wiki

The report can seed a durable knowledge layer. For an org, that is an agentic
wiki: repos, conventions, catalogs, and audit posture as living pages. For an
individual, that is notes in their own system — for example an Obsidian
vault. Offer this. You MUST ask the user before you create a wiki, a
repository, or notes from the report. You MUST NOT write outside the report
files without that confirmation. When the user accepts, follow a wiki skill's
conventions if one is available, and cite the report as the source.

## Evidence rules

- Trace every claim in the report to a checked artifact (a file path, a
  workflow name, a forge query) or mark it as user-reported.
- Record absence of evidence as absence ("no session capture found"), not as
  a negative fact ("sessions are not captured") — local-only practice is
  invisible to a repo scan.
- Put no credentials, tokens, or session content in the report — paths and
  counts only.
