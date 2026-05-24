# UI Kit Community Provider Trust Boundary

**Date:** 2026-05-24  
**Status:** Active guidance

## Purpose

This note makes the current spatial-input trust boundary explicit from the `aerobeat-ui-kit-community` side.

`aerobeat-ui-kit-community` is a **downstream proof host**. It proves that contract-aware Aero UI primitives still behave correctly when real packaged spatial providers are composed into a consumer host. It is **not** the first semantic truth source for those providers.

## The trust boundary

### Provider repos must prove provider semantics first

The concrete spatial provider repos own the truth for their lane-specific runtime semantics:

- `aerobeat-spatial-ui-mouse`
- `aerobeat-spatial-ui-touch`
- `aerobeat-spatial-ui-xr`

Those repos are responsible for proving, in their own hidden `.testbed` harnesses and repo-local tests, that the packaged provider:

- is the runtime seam actually being exercised
- publishes through the canonical `aerobeat-input-core` contract path
- preserves truthful hover / press / drag / release / cancel semantics
- exposes truthful provider-owned runtime/debug state
- does not overclaim verification beyond the current upstream truth

If a provider cannot prove those semantics in its own repo, `aerobeat-ui-kit-community` should not become the place where that truth gets reinvented.

### `aerobeat-ui-kit-community` proves downstream composed behavior

This repo proves a different thing:

- packaged providers can be installed and consumed downstream
- contract-aware UI kit primitives behave correctly inside a composed proof host
- provider/runtime metadata still appears truthfully through the downstream host path
- host-local composition seams remain correctly separated from provider-owned seams

In other words:

- **provider repos prove provider semantics**
- **`aerobeat-ui-kit-community` proves downstream composition and consumption**

## What stays local to `aerobeat-ui-kit-community`

This repo can still own consumer-host responsibilities such as:

- proof-scene composition
- world-hit / rig / camera / authored host wiring
- installed-addon downstream proof
- contract-aware UI composition and presentation checks
- narrow compatibility wrappers or probes that delegate to packaged providers instead of re-owning provider logic

These seams are truthful here because they are part of the downstream host, not because this repo owns provider semantics.

## What should not drift back here

Avoid re-expanding this repo into the long-term owner of:

- hover/press/drag/release/cancel provider semantics for mouse/touch/XR lanes
- provider-owned runtime state machines
- canonical contract ownership
- shared spatial helper ownership
- provider verification harnesses whose real job is to prove the packaged provider itself

If those responsibilities need changes, the owning provider repo or shared package should move first.

## Operational rule for future work

When a spatial behavior bug appears, ask this question first:

1. **Is the bug about provider semantics being truthful?**
   - Fix/prove it in the provider repo first.
2. **Is the bug about downstream composition, host wiring, or contract-aware UI behavior after provider truth is already established?**
   - Fix/prove it in `aerobeat-ui-kit-community`.

That keeps this repo honest as a downstream proof host instead of letting it quietly become the semantic source of truth for the provider family.
