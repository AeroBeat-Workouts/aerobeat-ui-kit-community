# Spatial Provider Human Verification Harness Parity Standard

**Date:** 2026-05-24  
**Status:** Drafted from current mouse lane truth  
**Scope:** `aerobeat-spatial-ui-mouse`, future `aerobeat-spatial-ui-touch`, future `aerobeat-spatial-ui-xr`

## Purpose

This note defines the minimum parity standard for a **provider-owned human-verifiable harness** across the AeroBeat spatial UI family.

The source-of-truth pattern comes from the current mouse lane harness:
- `aerobeat-spatial-ui-mouse/.testbed/scenes/mouse_provider_verification_harness.tscn`
- `aerobeat-spatial-ui-mouse/.testbed/scripts/mouse_provider_verification_harness.gd`
- `aerobeat-spatial-ui-mouse/.testbed/tests/support/mouse_provider_test_harness.gd`
- related repo-local verification tests

This standard exists so each concrete provider repo can prove its own lane semantics before downstream consumer proof happens in `aerobeat-ui-kit-community`.

## Ownership boundary

Keep this split explicit:

- `aerobeat-input-core` owns:
  - the canonical UI interaction contract
  - event/source/surface/phase taxonomy
  - verification-status truth model
  - the native 2D bridge
- `aerobeat-spatial-ui-core` owns:
  - shared provider helpers only
  - shared surface/projection/target-resolution/hover-capture helper seams
- concrete provider repos (`aerobeat-spatial-ui-mouse`, `...-touch`, `...-xr`) own:
  - lane-specific provider runtime behavior
  - provider-owned repo-local human verification harnesses
  - repo-local tests proving packaged-provider semantics and runtime state
- `aerobeat-ui-kit-community` owns:
  - downstream integration proof
  - proof-host composition
  - world-hit / rig / scene-local composition seams that truthfully remain consumer-host owned

## What counts as a provider-owned human-verifiable harness

A lane meets parity when its provider repo contains a hidden `.testbed` harness that:

1. **Instantiates the packaged provider directly**
   - The harness must exercise the installed addon/provider runtime seam for that repo.
   - It must not prove behavior through a copied local mirror of downstream host logic.

2. **Uses synthetic or host-supplied lane inputs, not downstream proof-host ownership**
   - Mouse: synthetic projected hits + mouse events is acceptable.
   - Touch/XR: host-supplied projected/world-hit inputs is acceptable.
   - The provider harness should not re-own consumer scene composition, camera rigging, world-ray acquisition, or authored hybrid panel layout.

3. **Publishes through the canonical contract path**
   - The harness must drive the provider into `aerobeat-input-core` contract publication, not a local fake event channel.
   - The observable truth should include actual normalized interaction events coming off the bus/adapter path.

4. **Exposes a human-readable runtime/debug HUD or equivalent live readout**
   - A human should be able to open the scene and confirm what provider lane is active, what phase was published, and what runtime ownership state the provider currently believes.

5. **Has repo-local automated coverage paired with the harness**
   - Human verification alone is not enough.
   - The provider repo should also have repo-local tests that assert the same runtime and semantic truths the harness exposes.

## Minimum semantic proof the harness must provide

A provider-owned harness is good enough only if it can let a human and repo-local tests prove the lane publishes contract semantics aligned with the parity baseline from the native-2D/spatial architecture plan.

At minimum, the harness must make it possible to prove:

1. **Hover ownership truth**
   - `hover_enter` / `hover_move` / `hover_exit` semantics are truthful for the lane.
   - Hover ownership changes only when target ownership really changes.

2. **Press ownership truth**
   - `press_begin` resolves to the correct press owner.
   - The provider preserves press-owner continuity even if live/hover target changes afterward.

3. **Drag continuity truth**
   - `drag_begin` / `drag_move` / `drag_end` are emitted according to lane truth.
   - Drag ownership remains captured consistently.
   - `drag_end` occurs before `press_end` when both apply.

4. **Release semantics truth**
   - `press_end.target_path` remains the original press owner.
   - Release-outside and off-surface continuation do not silently retarget to the last hover target.
   - Ordinary release-outside stays `press_end`, not `cancel`, when continuity is intact.

5. **Cancel semantics truth**
   - `cancel` is reserved for actual continuity breakage or interruption.
   - The lane does not use `cancel` as a generic substitute for release-outside.

6. **Verification-status truth**
   - The provider harness must not promote `verification_status` locally.
   - It should show whatever the canonical upstream truth is for that `source_variant + surface_type` combination.
   - For current spatial lanes, remaining `prototype` / `unverified` truth is acceptable and should stay explicit.

7. **Packaged-provider identity truth**
   - The harness must make it obvious that the active runtime seam is the packaged provider for the lane, not shadow state rebuilt in the scene.

## Minimum runtime/debug state the harness must expose

The mouse lane establishes the right pattern: the human harness should expose both normalized last-event truth and provider runtime-state truth.

Every provider-owned harness should expose these categories, even if exact field names vary by lane:

### A. Contract/event truth

- provider lane name
- packaged provider seam / runtime source identity
- `source_variant`
- published `phase`
- published `target_path`
- `verification_status`
- `verification_notes`

### B. Provider-owned runtime truth

Expose the lane-equivalent of:
- current hover/live target
- current capture / press owner target
- whether the active pointer/interaction is down/active
- last live target path
- last release target path
- last provider-forwarded event summary
- last projected/resolved target metadata sufficient to explain why the provider published what it published

For mouse, that currently looks like:
- `hover_target_path`
- `capture_target_path`
- `left_button_down`
- `last_live_target_path`
- `last_release_target_path`
- `last_forwarded_panel_event`

Touch and XR do not need identical field names, but they do need lane-equivalent runtime state that answers the same human questions:
- who is hovered/live now?
- who owns the active press/drag/capture?
- what was the last published release owner?
- what runtime seam is currently active?
- why did the provider publish that event?

## What the harness does **not** need to own

To stay truthful, provider-owned harnesses should **not** become miniature downstream proof-host clones.

They do **not** need to own:

- real hybrid proof-scene composition
- real glass panel composition and downstream UX polish
- world-ray acquisition
- XR rig wiring and authored downstream XR scene composition
- consumer-scene camera placement/layout
- downstream button activation proof in the full UI kit host
- canonical contract ownership or verification-status policy
- shared helper ownership that belongs in `aerobeat-spatial-ui-core`

Those remain downstream or upstream proofs:

- **upstream proof**: `aerobeat-input-core` defines contract and verification truth
- **shared helper proof**: `aerobeat-spatial-ui-core` owns reusable helper seams
- **downstream proof**: `aerobeat-ui-kit-community` proves the composed host actually uses the packaged providers correctly in a real hybrid scene

## Parity standard by lane

### Mouse

Current mouse harness already demonstrates the expected shape:
- provider-owned scene in the provider repo
- synthetic projected-hit bench instead of real world-ray ownership
- live HUD backed by provider runtime snapshot
- repo-local tests for runtime state, off-surface release, dependency boundary, and verification truth

This is the reference pattern to match.

### Touch

Touch parity does **not** require copying the mouse scene exactly.
It does require the same proof categories:
- packaged touch provider is the active seam
- touch press/drag/release/cancel semantics follow the contract baseline
- touch keeps truthful `verification_status`
- touch exposes active owner/live-target/release summary runtime state
- touch harness does not quietly absorb proof-host world-hit or scene-composition ownership

### XR

XR parity also does **not** require a clone of the mouse scene.
It does require the same proof categories, adapted to XR realities:
- packaged XR provider is the active seam
- stable XR `source_variant` truth is visible (`xr_ray`, `xr_direct`, etc.)
- owner continuity and release semantics stay correct
- cancel remains interruption-only
- runtime state exposes active target/owner/interaction summary clearly
- the harness stays provider-owned instead of turning into a full downstream rig/composition host

## Acceptance checklist

A provider repo can be considered at harness parity only when all are true:

- [ ] provider repo owns a repo-local human-verifiable harness scene under hidden `.testbed`
- [ ] harness proves the **packaged provider** is the active runtime seam
- [ ] harness publishes through the canonical contract/bus path
- [ ] harness exposes normalized event truth (`source_variant`, `phase`, `target_path`, `verification_status`, `verification_notes`)
- [ ] harness exposes provider-owned runtime truth (hover/live/capture/release/debug summary)
- [ ] repo-local tests assert the same semantic and runtime truths
- [ ] harness proves release continuity and non-promoted verification truth
- [ ] harness does not re-own world-hit acquisition, rig wiring, full hybrid proof-scene composition, or consumer integration proof

## Why this boundary matters

If a provider repo lacks its own truthful human harness, semantic bugs get discovered too late downstream.
If a provider repo tries to host the whole downstream proof scene, ownership drifts and the provider quietly absorbs responsibilities that belong elsewhere.

The standard is therefore:

- **provider repos prove provider semantics and provider runtime truth**
- **`ui-kit-community` proves downstream integration/composition truth**

That is the parity line the spatial family should preserve.
