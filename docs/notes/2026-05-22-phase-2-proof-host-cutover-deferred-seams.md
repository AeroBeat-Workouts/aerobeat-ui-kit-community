# Phase 2 Proof-Host Cutover Deferred Seams

Date: 2026-05-22

This note records the small seams intentionally left local in `aerobeat-ui-kit-community` after the Phase 2 proof-host cutover to the extracted spatial packages.

## What now consumes extracted packages

The hybrid proof host in `.testbed/scripts/glass_shader_gui_3d_test.gd` now consumes:

- `aerobeat-spatial-ui-core`
  - `AeroSpatialSurfaceDescriptor`
  - `AeroSpatialProjectionHelper`
  - `AeroSpatialRectTargetResolver`
- `aerobeat-spatial-ui-mouse`
  - `AeroSpatialUiMouseProvider`
  - `AeroSpatialUiMouseProviderConfig`

That means reusable mouse hover/capture/publication behavior and reusable projected-surface helper logic are no longer owned directly by this repo’s hybrid proof host.

## Deferred seams that remain local on purpose

### 1. World-ray acquisition and proof-scene hit sourcing

The proof host still owns camera ray creation, `PhysicsRayQueryParameters3D`, the actual raycast against `PanelInputSurface`, and conversion from world hit to panel-local hit inputs.

Why it remains local now:
- this is still scene-specific composition glue tied to the proof mesh/camera setup
- the extracted mouse provider intentionally starts **after** world-hit acquisition
- no broader generalized host-agnostic world-hit acquisition API was approved in this slice

### 2. Touch-path proof glue

The hybrid proof still keeps local touch publication/capture composition.

Why it remains local now:
- Phase 2 scope only extracted the first mouse-provider lane
- touch extraction would belong in a separate provider lane/repo slice rather than being folded into this cutover

### 3. Thin compatibility helpers used by repo-local probes/tests

`glass_shader_gui_3d_test.gd` still exposes thin host helpers such as `_resolve_projected_target_path_from_hit(...)` and `_build_projected_data(...)`, but they now delegate to the extracted spatial helper layer instead of re-owning the underlying logic.

Why they remain local now:
- repo-local tests and proof probes already call these host methods
- keeping them as wrappers preserves semantic parity while avoiding unrelated probe cleanup in this slice

## Ownership truth after cutover

- canonical interaction contract: `aerobeat-input-core`
- reusable UI consumer/binding layer: `aerobeat-ui-core`
- reusable spatial helper layer: `aerobeat-spatial-ui-core`
- reusable mouse-driven spatial provider lifecycle: `aerobeat-spatial-ui-mouse`
- proof-scene composition and remaining scene-local glue: `aerobeat-ui-kit-community`
