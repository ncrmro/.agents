# npm packages in Nix flakes and containers

Use one Nix package derivation as the source of truth for both flake package outputs and Nix-built container images. Prefer Nixpkgs' `buildNpmPackage` with `importNpmLock`: it consumes the integrity hashes already committed in `package-lock.json`, so dependency or release automation does not also need to refresh an `npmDepsHash`.

## Flake package pattern

```nix
let
  package = builtins.fromJSON (builtins.readFile ./path/to/package.json);
in
pkgs.buildNpmPackage {
  pname = "example";
  inherit (package) version;
  src = ./.;

  npmDeps = pkgs.importNpmLock { npmRoot = ./.; };
  npmConfigHook = pkgs.importNpmLock.npmConfigHook;

  # Set this for an npm workspace; keep npmRoot at the lockfile root.
  npmWorkspace = "path/to/package";

  meta.mainProgram = "example";
}
```

Expose the derivation as both `packages.<system>.example` and `packages.<system>.default`. `nix run` uses `meta.mainProgram`, so a redundant app wrapper is unnecessary unless the app needs custom arguments or environment.

Read the version from the published workspace's `package.json`; do not duplicate it in Nix. Release Please or equivalent release automation then remains authoritative for versions, while `package-lock.json` remains authoritative for dependency content.

## Lockfile requirements

Every remote package entry used by `importNpmLock` must have both `resolved` and `integrity` data. If evaluation reports `attribute 'integrity' missing`, repair or regenerate the committed lockfile. Do not switch to `npmDepsHash` merely to hide an incomplete lockfile.

Local npm workspace links are supported. Point `npmRoot` to the repository directory containing the root `package-lock.json`, and set `npmWorkspace` to the package being built. This preserves one dependency graph for npm, Nix, CI, and releases.

A dependency that publishes its own `npm-shrinkwrap.json` can bypass the root paths rewritten by `importNpmLock` and attempt registry access during the offline build. Normalize that dependency source with `packageSourceOverrides`—for example, derive a tarball without the nested shrinkwrap—and remove the corresponding `hasShrinkwrap`/stale integrity metadata only in the lock value passed to `importNpmLock`. Derive the override URL, version, and source hash from the committed root lockfile; do not duplicate them as Nix literals.

Use `fetchNpmDeps`/`npmDepsHash` only when a dependency source cannot be represented by a complete npm lockfile. Document that exception: the hash then needs manual refresh whenever the fetched dependency cache changes, and release tooling will not update it automatically.

## Runtime dependencies

Nix packages do not inherit arbitrary host tools. If the CLI invokes programs such as `git` or `ssh`, add them through a wrapper:

```nix
nativeBuildInputs = [ pkgs.makeWrapper ];
postInstall = ''
  wrapProgram "$out/bin/example" \
    --prefix PATH : ${lib.makeBinPath [ pkgs.git pkgs.openssh ]}
'';
```

Only include programs the application actually invokes. Keep build-only tools out of the runtime wrapper.

## Containers

Build the npm application once with the derivation above, then place that same package in `dockerTools.buildLayeredImage`/`buildImage` contents or copy it into the final Nix image closure. Do not run `npm install` again in a Docker layer: that creates a second dependency-resolution path and discards the lockfile-backed Nix build.

Add certificates, shells, users, writable directories, and runtime tools explicitly according to the application's needs. Set the container command to the packaged executable from `/bin` or its linked profile path.

## Validation

For a flake package, run:

```sh
nix flake check
nix build .#example
nix run .#example -- --version
```

Also exercise one command that loads runtime assets or invokes wrapped tools; `--version` alone cannot catch missing schemas, templates, `git`, or `ssh`.

For a container output, build it, load or stream it into the local runtime, and execute the same artifact smoke tests inside the container. Verify the image does not perform network dependency installation during its build.
