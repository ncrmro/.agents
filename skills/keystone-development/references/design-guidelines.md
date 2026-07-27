# Keystone design guidelines

Use these rules for new work and migrations. They describe the intended
architecture; an old branch, PR, or currently deployed exception does not
override them.

## Ownership at a glance

| Layer | Owner | Mechanism |
| --- | --- | --- |
| Human-authored user configuration | `ncrmro/dotfiles` | Plain files organized as GNU Stow packages |
| User packages, dependencies, activation, and machine selection | Home Manager through Nix | Install tools and restow the selected dotfile packages |
| Reusable OS and user integration | `ncrmro/keystone` | Reusable NixOS and Home Manager modules |
| Host identity and fleet policy | `ncrmro/ks-config` | Consumer flake, host modules, hardware values, secret wiring, locked inputs |
| Linux operating system | NixOS | Boot, storage, networking, security, users, system services, and the Kubernetes substrate |
| Application build and deployment | Application repository | Nix-built OCI image plus Kubernetes manifests, Kustomize, or Helm values |
| Shared cluster infrastructure | `ks-config` | k3s, storage class, ingress/edge, networking, and cluster secret integration |

Apply the rule at the narrowest owning layer. Do not duplicate the same
configuration payload across dotfiles, Home Manager, host modules, and
Kubernetes manifests.

## User configuration: dotfiles first

Put editable application configuration in `ncrmro/dotfiles`. Organize it as
Stow packages and link it into `$HOME`; favor whole-directory links so new files
appear without adding one Nix declaration per file.

Use Nix and Home Manager to:

- install applications, language servers, fonts, and other dependencies;
- choose which Stow packages a user or machine receives;
- apply or restow links during activation;
- configure user services, session integration, and machine-specific values;
- make the result reproducible from a fresh machine.

If a Stow package owns an application's configuration directory, install the
application as a package and disable Home Manager's generated configuration for
it.

After Home Manager activation, verify the symlink targets and exercise the
application. Activation can succeed with only a warning when the dotfiles
checkout is absent.

On NixOS, Home Manager is integrated into the system configuration. Apply it
through the host's `nixos-rebuild`/`ks-dev` path; do not run an independent
`home-manager switch`. On macOS, use dotfiles plus standalone Home Manager.
The prior nix-darwin adoption was reverted; standalone Home Manager remains the
macOS default.

## Linux systems: NixOS owns the machine

NixOS owns:

- boot, initrd, storage, encryption, resume, and Secure Boot;
- hardware, kernel, networking, firewall, users, and privilege boundaries;
- systemd services that are intrinsic to the host;
- k3s and its container runtime, storage, networking, and edge integration.

Keystone owns reusable modules and capabilities. `ks-config` composes those
modules into named machines and supplies fleet-specific values. Keep physical
disk IDs, LAN addresses, host names, and secret wiring out of Keystone.

Nix pins dependencies, builds host closures and OCI images, and drives Home
Manager activation. With "dotfiles first," Nix applies plain configuration
instead of encoding each editable file as Nix data.

## Services: Kubernetes on Nix by default

Place new application services on Kubernetes/k3s unless they are part of the
host substrate or have a documented reason not to be clustered.

The normal path is:

1. The application repository builds a content-addressed OCI image with Nix.
2. It pushes that image to the configured registry.
3. The same repository owns its workload manifests and deployment/rollout
   verification.
4. `ks-config` owns the shared cluster substrate and fleet-level integration.

Test the image and manifests against a disposable or development cluster, then
promote the immutable image reference through the declared cluster
configuration.

Prefer registry delivery over privileged `ctr import`, passwordless sudo, or an
SSH-based image side channel. Direct containerd imports may be useful for an
isolated diagnostic, but are not the deployment design.

Host-native exceptions include:

- boot, storage, networking, security, k3s, and the container runtime;
- hardware-coupled daemons that Kubernetes cannot sensibly own;
- a service whose local coupling or migration risk is explicitly documented,
  such as mail or an edge bridge during a staged migration.

An exception should name the constraint and, when temporary, the exit
condition. Existing host-native deployment alone is not a reason to make a new
service host-native.

## How the current direction emerged

The repositories contain several generations of development practice:

1. The early `ks-config` flake combined NixOS hosts, Home Manager configuration,
   and host-managed Kubernetes/Helm resources.
2. Keystone extracted reusable NixOS and Home Manager modules. VM validation
   evolved through quickemu, `build-vm`, microVM/libvirt, and direct qcow2
   testing; each remains useful only for the layer it can exercise.
3. The current platform-to-consumer loop uses local flake overrides, explicit
   consumer selection, targeted lock updates, and lock-first deployment.
   Devcontainer, devbox, Kind, and rootless-container branches remain useful
   experiments rather than the system deployment model.
4. The dotfiles refactor moved editable Git, SSH, Hyprland, and similar config
   out of generated Home Manager files. Home Manager retained dependency
   provisioning and activation.
5. The k3s cutover work moved application workloads toward Nix-built registry
   images and Kubernetes-owned rollout, while NixOS continued to own the
   cluster substrate and temporary host-service bridges.

For historical intent and tradeoffs, see:

- [`ks-config` #1](https://github.com/ncrmro/ks-config/pull/1): initial
  combined NixOS/Home Manager configuration.
- [`ks-config` #11](https://github.com/ncrmro/ks-config/pull/11): early
  host-declared Helm deployment.
- [`ks-config` #30](https://github.com/ncrmro/ks-config/pull/30): devbox and
  rootless-container development experiment.
- [`ks-config` #46](https://github.com/ncrmro/ks-config/pull/46): NixOS-owned
  k3s substrate and migration bridges.
- [`ks-config` #48](https://github.com/ncrmro/ks-config/pull/48): Nix-built
  registry image and application-owned Kubernetes deployment.
- [`keystone` #193](https://github.com/ncrmro/keystone/pull/193): local
  development mode and repository registry.
- [`keystone` #430](https://github.com/ncrmro/keystone/pull/430): direct qcow2
  validation.
- [`keystone` #450](https://github.com/ncrmro/keystone/pull/450): explicit
  authoritative consumer flake.
- [`keystone` #502](https://github.com/ncrmro/keystone/pull/502): approve,
  lock-first deployment, and rollback.
- [`keystone` #555](https://github.com/ncrmro/keystone/pull/555) and
  [`keystone` #563](https://github.com/ncrmro/keystone/pull/563): the
  nix-darwin tradeoff and reversion.

Treat PRs and non-main worktrees as history. Confirm current behavior in
scripts, modules, and the consumer lock. The `keystone-systems` fleet harness
currently supports VM testing only; deployed hosts are defined by `ks-config`
host modules and its locked `nixosConfigurations` outputs.
