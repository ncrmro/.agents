---
name: formal-verification
description: Ground a codebase's estimate/quantitative numbers (prices, budgets, delta-v, yields) in machine-checked properties. Covers the LemmaScript→Dafny toolchain and its traps, the prove/test/source three-tier portfolio, the functional-core/shell packaging, certified brackets for transcendentals, and the trust-manifest audit map.
disable-model-invocation: true
---

# Formal verification of numbers

Make the numbers a system shows — order prices, payback, delta-v, crop yields —
carry a **machine-checked property**, not just a unit test. This is *function*
provenance (a property that holds for all inputs) layered on top of whatever
*data* provenance the code already has. The deliverable is not a green checkmark;
it is an **auditable trust map** of which numbers are proven vs tested vs still
resting on a stub.

Assurance is a **portfolio**, not one tool. Sort every number onto a three-tier
ladder — because a verifier reasons about **integers and reals only**, not
IEEE-754 floats or transcendentals (`√`, `ln`, `exp`):

| Tier | What | How grounded |
| --- | --- | --- |
| **A — proven** | linear/rational finance & budgets | LemmaScript→Dafny→Z3 (`cost/(1−margin) ≥ cost`; `margin = budget − load`) |
| **B — tested** | floats / transcendentals | fast-check property tests + golden values |
| **C — sourced** | constants **and outputs of validated libraries** | provenance, not proof — a stub here taints everything above it |

A number is only as trustworthy as its weakest input, so color each node by the
**worst tier in its dependency closure** (🟢 proven / 🟡 tested / 🔵 sourced / 🔴
stub). Corollary: *"what library should we use" and "what should we prove" are the
same question from opposite ends* — every validated library adopted (money
allocation, astrodynamics propagation) is surface you no longer have to prove.

## The workflow

1. **Provision the prover via nix, not global install.** Dafny (+ Z3/cvc5/Lean)
   come from nixpkgs: `nix build --no-link --print-out-paths nixpkgs#dafny` and put
   the store `bin` on PATH for the run. Use the **Dafny backend** — Lean needs
   `elan` + midspiral forks (heavier); reach for it only to discharge real-analysis
   axioms (`ln`/`exp`) for real instead of assuming them.
2. **Extract a pure real-valued core.** The prover requires purity: no I/O, no
   framework imports, and **no `Math.round`** in the proved part. Put cores in a
   leaf package (functional core / imperative shell — see below), annotate with
   inert `//@` comments, list them in `LemmaScript-files.txt`.
3. **Prove:** `bunx lemmascript check --backend=dafny <file>` (batch via the files
   list). `regen` / `rm *.dfy *.dfy.gen` before re-checking if a signature changed.
4. **Differential-test** each core against the real function it abstracts, and
   fuzz its `//@ ensures` as a property (fast-check). This bridges the model↔code
   gap — a proof of the wrong function proves nothing.
5. **Emit the manifest:** walk the annotated cores + their deps + stub markers →
   `numbers-manifest.json` + a colored dependency graph. Report **assurance
   coverage** = N/M user-facing numbers standing on something (proofs give *zero*
   line coverage — they never execute).
6. **Prove it has teeth:** a negative control. Drop one `//@ requires` and show
   `lsc check` *fails* the postcondition. A proof you can't fail is theater.

## Toolchain traps (these cost real time)

- **`number` defaults to `int`.** Reals need `//@ type x real` **and**
  `//@ type \result real` (the `\result` keyword — `//@ returns real` is a red
  herring). Missing this → *"Function body type mismatch (expected int, got real)."*
- **Decimal literals are unsupported in specs.** `0.0` tokenizes as `0` then `.0`
  → *"Expected ident, got num 0."* Use integer literals; Dafny coerces via `as real`.
- **A bare `0` in a ternary branch is `int`** and mismatches a `real` branch. Get a
  real-typed zero with `x - x`.
- **Nonlinear *division* is not auto-proved by Z3**; multiplication usually is. Add
  a one-line hint in the `.dfy`: for `cost/(1−margin) ≥ cost`, assert
  `cost/d − cost == cost*margin/d` (with `d = 1−margin`).
- **`Math.round` is non-linear** → verify the pre-rounding core; differential-test
  the rounded wrapper.
- **Stale `.dfy` keeps the old signature.** `rm *.dfy *.dfy.gen` (or `lsc regen`).
- **Batch file paths are relative to the CWD where `lsc` runs**, not to the list
  file — a nested `verify/verify/...` means the paths are doubled.
- **Vacuous proofs.** An unsatisfiable precondition verifies *everything* trivially
  and covers nothing (Dafny won't warn). A passing differential test doubles as the
  satisfiability check.

## Transcendentals: prove a certified bracket

Don't give up at `ln`/`exp`/`√`. Decompose at the transcendental boundary: prove
the algebra around it, and **prove rational bounds that bracket the value**. For
the rocket equation `Δv = ve·ln(R)`, `R ≥ 1`, the bounds `(R−1)/R ≤ ln R ≤ R−1`
are rational → fully provable, giving a certified interval
`ve(R−1)/R ≤ Δv ≤ ve(R−1)`. Test the single `ln` (golden + monotonic + that the
runtime value lands inside the proven bracket); source the constants. The number
stays 🟡; its *bounds* go 🟢. Alternative: axiomatize `ln` with its real-analysis
properties and prove relative to them — but list the axioms as trusted, and beware
a false axiom proves anything.

## Architecture: functional core, imperative shell

The purity the prover demands *is* a package boundary. Extract a pure leaf package
(`verified/` with per-domain folders) holding the real-valued cores + `//@` specs +
`LemmaScript-files.txt`; the impure shells (rounding, DB, framework, mocks)
**delegate** to it — so the proved core *is* the shipped code, not a shadow copy
that can drift. Keep the prover tooling (nix Dafny, manifest generator) in a
separate dir so consumers never dev-dep on Dafny. Tier-C constants get their own
provenance-carrying leaf — one home to brand units (the m/s-vs-km/s class that is
invisible to both the prover and runtime validators).

## Where each tool fits (complements, not competitors)

- **Proofs** — universal ("cannot fail on any input"), over the computation, zero
  runtime cost, but only reals/ints.
- **Property tests (fast-check)** — wide sampling; the only option for floats;
  bridges model↔real-code.
- **Runtime contracts (Zod `z.function`)** — enforce, at the boundary, the very
  `//@ requires` preconditions a proof *assumes*. This closes the gap between "the
  proof assumed margin<1" and "live data actually satisfies it."
- **Validated libraries** (the Tier-C "source, don't prove" move): money
  allocation (`dinero.js` `allocate`), astrodynamics (satellite.js /
  astronomy-engine), exact decimal (`decimal.js`) to make a Tier-A runtime match
  the proved reals.

## The highest-value properties to reach for

Conservation and totality invariants — pure linear algebra, fully provable, and the
bugs that silently corrupt a whole model: **allocation conservation** (`Σ allocated
== demand`, none negative), **partition totality** (every item in exactly one
bucket, no gap/overlap), **energy/mass balance** (`margin = generation − draw`,
clamps in range).

## References

- LemmaScript: github.com/midspiral/LemmaScript ·
  midspiral.com/blog/lemmascript-a-verification-toolchain-for-typescript
- Dafny: dafny.org · fast-check: github.com/dubzzz/fast-check
