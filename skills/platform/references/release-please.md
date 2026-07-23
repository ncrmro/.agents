# release-please

How repositories automate versioning and releases with
`googleapis/release-please-action@v4`: it reads Conventional Commits on the
default branch, maintains a single **release PR** that bumps the version +
CHANGELOG, and on merge tags a GitHub release. A **separate** workflow reacts to
the published release and ships the artifact (npm, container, git tag). Keep
publishing *out* of the release-please workflow — trigger it on
`release: published` so the merged release PR is the single gate.

Document the procedure here; keep repo-specific values (package names, registry,
secret names) in the consuming repository.

## The PR-creation gotcha (org policy)

release-please's only action on each push is to open/update the release PR. If
the org or repo disables **"Allow GitHub Actions to create and approve pull
requests"**, the default `GITHUB_TOKEN` gets as far as creating the branch, then
fails:

```
release-please failed: GitHub Actions is not permitted to create or approve pull requests
```

This is commonly enforced **org-wide** and cannot be overridden per repo
(`PUT /repos/{owner}/{repo}/actions/permissions/workflow` returns
`409 "The organization does not allow GitHub Actions to create or approve pull
requests"`). The portable fix is a **PAT** (a user or bot token with
`contents:write` + `pull-requests:write`) stored as a secret and passed to the
action as `token:`:

```yaml
permissions:
  contents: write
  issues: write
  pull-requests: write

jobs:
  release-please:
    runs-on: ubuntu-latest
    steps:
      - uses: googleapis/release-please-action@v4
        with:
          token: ${{ secrets.RELEASE_PLEASE_TOKEN }} # GITHUB_TOKEN can't open PRs here
          config-file: release-please-config.json
          manifest-file: .release-please-manifest.json
```

Store the PAT as an **org-level secret** shared to the repos that need it, so
every repo authenticates the same way rather than minting its own token.

## Config + manifest

Two committed files drive it:

- `release-please-config.json` — release type, tag format, per-package settings.
- `.release-please-manifest.json` — the last released version(s), e.g.
  `{ ".": "0.3.0" }`. release-please rewrites this in the release PR; it is the
  source of truth for "what was last released".

Pick the **release-type** by what the repo ships.

### `node` — an npm package

```json
{
  "$schema": "https://raw.githubusercontent.com/googleapis/release-please/main/schemas/config.json",
  "release-type": "node",
  "include-component-in-tag": false,
  "packages": { ".": { "package-name": "@scope/name" } }
}
```

- `include-component-in-tag: false` → clean `vX.Y.Z` tags for a single-package
  repo (otherwise the component name is prefixed).
- For a single package at the repo root, release-please **auto-syncs both
  `package.json` and `package-lock.json`** — no `extra-files` needed. Add
  `extra-files` only in a **workspace** where the published package is not at the
  root and the root `package.json`/lockfile version must be mirrored:
  ```json
  "extra-files": [
    { "type": "json", "path": "/package.json", "jsonpath": "$.version" },
    { "type": "json", "path": "/package-lock.json", "jsonpath": "$.version" },
    { "type": "json", "path": "/package-lock.json", "jsonpath": "$.packages[''].version" }
  ]
  ```

### `simple` — a git-tag-only repo (a GitHub Action, a Nix flake)

```json
{
  "release-type": "simple",
  "bump-minor-pre-major": true,
  "bump-patch-for-minor-pre-major": true,
  "include-v-in-tag": true
}
```

A published **GitHub Action** also needs its floating major/minor aliases moved
on each release (marketplace consumers pin `@v1`), in the same workflow, guarded
on the action's output:

```yaml
- name: Move floating tags
  if: ${{ steps.release.outputs.release_created == 'true' }}
  env:
    TAG: ${{ steps.release.outputs.tag_name }}
    MAJOR: v${{ steps.release.outputs.major }}
  run: |
    git tag -f "$MAJOR" "$(git rev-list -n1 "$TAG")"
    git push --force origin "refs/tags/${MAJOR}:refs/tags/${MAJOR}"
```

### Pre-1.0 bump behavior

Below `1.0.0`, choose how aggressive bumps are:

- **default** (node leaves these off): a `feat` bumps the **minor**
  (`0.1.0 → 0.2.0`); a breaking change bumps the major.
- **conservative** (`bump-minor-pre-major` + `bump-patch-for-minor-pre-major`):
  breaking → minor, `feat` → **patch**, keeping `0.x` slow-moving.

Be consistent within a language family (e.g. all npm repos default, all
git-tag repos conservative) rather than choosing per repo.

## Publishing on release (a separate workflow)

Publish in its own workflow so a merged release PR is the only trigger:

```yaml
on:
  release:
    types: [published]

permissions:
  contents: read
  id-token: write # OIDC → provenance / trusted publishing

jobs:
  publish-npm:
    runs-on: ubuntu-latest
    environment: npm-publish # a protected Environment gates who/what can publish
    steps:
      - uses: actions/checkout@v4
        with: { persist-credentials: false }
      - uses: actions/setup-node@v4
        with: { node-version: "22", registry-url: https://registry.npmjs.org/ }
      - run: npm ci
      - run: npm run check # re-gate at release time
      - run: npm publish --access public --provenance
```

- `--provenance` + `id-token: write` attaches a Sigstore-signed **build
  attestation** (supply-chain provenance). It needs a public source repo (or a
  plan that allows private provenance).
- **Auth**: prefer npm **trusted publishing** (OIDC) — configure the package's
  trusted publisher on the registry (repo + workflow + environment) and no token
  is needed. Otherwise map a token: `env: { NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }} }`.
  A **first publish of a brand-new package** needs the trusted publisher (or
  token) provisioned before it can succeed.
- The version is already in `package.json` (release-please bumped it in the
  merged PR), so the publish job just checks out and ships — no version argument.

## Verifying

```sh
# release-please opened/updated its PR, and the run's result
gh pr list --search 'head:release-please--'
gh run list --workflow release-please.yml --limit 1
gh run view <id> --log-failed        # why a run failed

# after merging the release PR
gh release list
```

Common failures: **"not permitted to create … pull requests"** → missing or
unauthenticated PAT (see the gotcha); **release PR never appears** → no
releasable (`feat`/`fix`) commit since the last release, or non-conventional
commit history; **publish 403/404** → npm auth (trusted publisher or token) or
the publish Environment is not configured for the package.
