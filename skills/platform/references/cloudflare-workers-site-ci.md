# Cloudflare Workers site CI: previews, smoke, and production

Hard-won lessons from building a multi-site Cloudflare Workers deploy pipeline
(Astro apps on Workers, mock version previews, Playwright smoke, gated
production). Read before changing site CI, preview/smoke, or Worker auth config.

## The consolidated pattern

One reusable `workflow_call` workflow, called by thin PR and push triggers, so
**PR previews and main run the identical path** — build → upload mock version
preview → smoke — and only explicit input flags differ:

```yaml
# .github/workflows/site-pipeline.yml
on: { workflow_call: { inputs: {
  preview-alias: {required: true, type: string},
  run-smoke: {type: boolean, default: true},
  comment-on-pr: {type: boolean, default: false},
  promote-production: {type: boolean, default: false} } } }
# jobs: changes → build → preview(matrix) → smoke[if run-smoke]
#       → comment[if comment-on-pr] → production-deploy[if promote-production]
```

```yaml
# preview.yml (pull_request): preview-alias pr-<n>, run-smoke, comment-on-pr
# deploy.yml  (push main):    preview-alias main, run-smoke, promote-production
jobs: { pipeline: { uses: ./.github/workflows/site-pipeline.yml,
                    secrets: inherit, with: { ... } } }
```

Each job gates on an input (`if: inputs.run-smoke`), not on `github.event_name`
— that is what makes one pipeline serve every environment. Build ONE reviewed
production artifact per site; preview it with mock var-overrides, smoke it, and
(main only) deploy the same artifact to production. Drop any persistent
"staging" tier: there are version *previews* (per PR and for main) plus
production.

### Reusable-workflow gotchas that fail at *startup*

- **Permissions can't escalate.** A called job may not request more permission
  than the caller grants, or the run is rejected with `startup_failure`
  ("workflow file issue", no logs). Don't put `permissions: {issues: write}` on
  a reusable job — let it inherit, and grant the scope in the *caller* that
  needs it (preview.yml grants issue/PR write for the comment job; deploy.yml
  stays contents:read and skips commenting).
- `secrets: inherit` in the caller lets the reusable read `${{ secrets.* }}`
  directly; without it you must declare each under `on.workflow_call.secrets`.
- YAML that `js-yaml` accepts can still `startup_failure` — Actions validates
  reusable calls more strictly. Expect to iterate via merge (a PR that edits a
  `pull_request` workflow runs the *base* branch's copy, so you can't fully test
  workflow edits on their own PR).

## Version previews are mock, self-contained environments

`wrangler versions upload --preview-alias <a>` gives an unpromoted version at a
stable preview URL without touching production traffic. But a preview that
*builds* fine still 500s at runtime unless every config the app requires "in
production" is injected as a per-version `--var`. Inject explicitly:

```
--var ARTERA_DATA_MODE:mock            # mock data, not the real DB
--var AUTH_STORAGE_MODE:memory         # in-memory auth, no Turso/D1 needed
--var "AUTH_COOKIE_DOMAIN:"            # host-only cookie (each alias is its own host)
--var BETTER_AUTH_SECRET:<throwaway>   # apps that require a secret in prod
```

Symptoms when one is missing: `ConfigError: Missing required config X in
production`, or `Persistent authentication requires TURSO_DATABASE_URL; cannot
fall back to memory`. One site working and another not is usually a config
asymmetry (e.g. only one Worker sets `AUTH_STORAGE_MODE:memory`) — normalize it.

### Durable Objects block version-preview URLs

A Worker with a Durable Object namespace uploads a version but **emits no
preview URL** (`wrangler did not report a preview URL; verify preview_urls is
enabled`). `preview_urls: true` in config does not change this. If a DO-bearing
Worker must participate in preview-smoke, it needs its DO removed (or moved off
that Worker). Removing a DO requires a **delete-class migration** or the deploy
is rejected:

```jsonc
"migrations": [
  { "tag": "x-v1", "new_sqlite_classes": ["Foo"] },
  { "tag": "x-v2-delete", "deleted_classes": ["Foo"] }  // append; never edit v1
]
```
The delete only takes effect on a live `wrangler deploy`, not on `versions
upload`.

## Smoke ≠ production, and production secrets are separate

The smoke gate tests **mock previews** (with the injected dummy secret + memory
storage). A green smoke does **NOT** prove production is healthy — it can't see
missing *production* secrets. Provision those out of band and verify live:

- `BETTER_AUTH_SECRET` etc. are runtime-read Worker **secrets**, not baked into
  a version — set them per Worker with `wrangler secret put` (or the dashboard),
  and confirm with `wrangler secret list`. A missing one 500s every authed page
  independent of which version is deployed, so **rollback does not fix it**.
- Set a secret without seeing it: `openssl rand -base64 48 | wrangler secret put
  NAME` (pipe stdin; never echo). Same value on peer Workers only matters if
  they actually share sessions — with `AUTH_STORAGE_MODE:memory`, cross-Worker
  SSO doesn't work anyway.
- **`wrangler secret put` fails after a rollback:** "the latest version of your
  Worker isn't currently deployed." Either `wrangler versions secret put` (adds
  the secret without deploying, then `wrangler versions deploy`), or redeploy
  latest first, then `secret put`.
- After any production deploy, curl the real origins (`/` → 200/302, not
  500/404). "CI green" is necessary, not sufficient.

## Firmware / non-web builds don't belong in the site loop

Don't make a site build shell out to a hardware toolchain (esphome, etc.). It
couples unrelated toolchains and cadences and breaks the site deploy when the
toolchain or a build-dir assumption drifts. Give it its own workflow and publish
to R2. (See the `esp-firmware` skill's web-flasher reference.)

## Small traps

- **`changed-sites` empty array under `set -o pipefail`:** `printf '%s\n'
  "${arr[@]}" | grep -v '^$'` exits 1 when the array is empty, failing the job.
  Emit `[]` explicitly when there are zero matches.
- **Build worker-name derivation:** an `CLOUDFLARE_ENV=staging` build names the
  artifact `<name>-staging`; those `-staging` workers may be retired / not emit
  preview URLs. Preview the **production-named** artifact + mock vars instead.
- **Auto-promoting to production on every main push**, gated only by a smoke
  that tests previews, can take prod down (a bad artifact, or missing prod
  config the preview masks). Either require reviewers on the `production`
  environment, or add a real post-deploy production health check.
