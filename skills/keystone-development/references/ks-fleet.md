# ks-fleet — the unified fleet harness (ks.systems/os)

The current harness for booting, deploying, and smoke-testing fleet hosts.
Lives in `ks.systems/os` (`lib/mk-fleet.nix` + `bin/ks-fleet`); supersedes
the legacy `test-iso`/`bin/virtual-machine` flows for day-to-day work.

## Model

A host has up to three *realizations*, declared in `targets.<host>`:

- `vm` — QEMU vmVariant (fresh-install semantics; stable ssh port
  `basePort+index`, VNC display slot). Consumer flakes without `mkFleet`
  still work: ks-fleet falls back to plain
  `nixosConfigurations.<h>.config.system.build.vm` + `QEMU_NET_OPTS`
  ssh forwarding.
- `machine` — physical box over ssh (`nixos-rebuild test|switch
  --target-host`, `buildOnRemote` supported).
- `install` — the real disko-built disk image (`system.build.vmWithDisko`)
  with emulated TPM2 (swtpm, default on) and optional canokey FIDO2
  token: LUKS unlock flows testable pre-hardware.

`fleetMeta` (a flake output of plain data) is the contract between nix and
the runner; `nix eval --json .#fleetMeta` is the source of truth.

## Commands

```bash
nix run ks.systems/os#ks-fleet -- status|up|down|deploy|test [host ...]
  --as vm|machine     # force realization (same fleet, all-VM or mixed)
  --durable           # machine deploy = switch instead of test
  --no-deploy         # smoke only
  --allow-degraded    # accept degraded (vm boots without host secrets)
  --vm-host U@H       # delegate the VM to a remote machine (e.g.
                      # ncrmro@ocean): closure nix-copied, QEMU runs
                      # remotely, smoke ssh jumps through it
KS_FLEET_VM_USER=ncrmro KS_FLEET_DIR=/tmp/ksf   # common env
```

`ks-fleet test` with no hosts runs the whole mixed fleet: machines get
reversible `nixos-rebuild test`, VMs boot beside them, everything must
reach `systemctl is-system-running == running`.

## Dev-VM conventions (proven on ks-test-delltop)

- vmVariant 9p-shares the host's `~/repos/ncrmro/{dotfiles,.agents}` so
  the stow config surface is live-editable inside the VM; requires the
  root-oneshot chown and greetd-after-home-manager ordering (see
  vm-observation.md gotchas) for a deterministic desktop boot.
- Remote delegation requires KVM, nix, and the 9p-shared checkouts on the
  vm host; pre-seed with `nix copy --substitute-on-destination`.
- Headed viewing: `QEMU_OPTS="-display gtk"` (GL clashes with a baked-in
  `-vnc`); headless driving via the monitor socket
  (`-monitor unix:/tmp/x.sock,server,nowait`).
