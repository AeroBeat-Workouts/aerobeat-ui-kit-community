# Phase 3 Packaged Resolver Proof Seams

Date: 2026-05-23

This note records what changed in `aerobeat-ui-kit-community` once the hybrid proof host was tightened around the packaged resolver flow.

## What now proves the packaged resolver path

The hidden testbed manifest now pins `aerobeat-spatial-ui-mouse` to commit `54a8d036323a9cc4c367dcebcd1381fa260eede0`, which is the first packaged mouse-provider commit that resolves projected targets through the shared packaged helper path in `aerobeat-spatial-ui-core`.

That means the hybrid mouse proof in `.testbed/scripts/glass_shader_gui_3d_test.gd` now proves this downstream chain end-to-end:

- `aerobeat-ui-kit-community`
  - world ray acquisition and panel-hit shaping
- `aerobeat-spatial-ui-mouse`
  - `AeroSpatialUiMouseProvider`
- `aerobeat-spatial-ui-core`
  - packaged `AeroSpatialRectTargetResolver`
  - packaged `AeroSpatialProjectionHelper`
- `aerobeat-input-core`
  - canonical interaction contract publication

The repo-local validation for this slice checks both:
- the installed addon script text under `res://addons/aerobeat-spatial-ui-mouse/...` to confirm the packaged resolver path is the one being loaded in the consumer workbench
- runtime press-path metadata to confirm the packaged resolver still resolves the expected authored target (`primary_action` / `PrimaryActionButton`) during the live hybrid proof flow

## Seams intentionally still retained locally

### 1. World-ray acquisition and proof-scene hit sourcing

The proof host still owns camera ray creation, `PhysicsRayQueryParameters3D`, the actual raycast against `PanelInputSurface`, and conversion from world hit to projected surface hit input.

Why it stays local:
- it is still tied to this proof scene's specific mesh/camera composition
- no generalized host-agnostic world-hit acquisition API was approved in this slice
- the packaged resolver proof begins after the world hit is already known

### 2. Touch-path proof glue

The hybrid proof still keeps local touch publication/capture composition.

Why it stays local:
- this slice tightens the mouse-driven packaged resolver proof only
- touch extraction belongs in a separate provider lane rather than being hidden inside this consumer repo slice

### 3. Thin compatibility wrappers for repo-local probes and touch-focused tests

`glass_shader_gui_3d_test.gd` still exposes helper entrypoints such as `_resolve_projected_target_path_from_hit(...)`, `_resolve_projected_target_path(...)`, and `_build_projected_data(...)`.

What changed about that seam:
- those wrappers are no longer part of the mouse proof path that this slice validates end-to-end
- they remain only so existing repo-local touch/probe coverage can keep using the scene as a stable proof harness without forcing unrelated cleanup into this bead
- the shared resolver/helper ownership they call remains in `aerobeat-spatial-ui-core`; the wrappers are just consumer-side proof harness glue

## Ownership truth after this tightening pass

- canonical interaction contract and native 2D bridge: `aerobeat-input-core`
- reusable UI consumer/binding layer: `aerobeat-ui-core`
- reusable spatial helper layer and shared resolver ownership: `aerobeat-spatial-ui-core`
- reusable mouse-driven spatial provider lifecycle: `aerobeat-spatial-ui-mouse`
- proof-scene composition, world-ray acquisition, touch glue, and probe-facing compatibility wrappers: `aerobeat-ui-kit-community`
