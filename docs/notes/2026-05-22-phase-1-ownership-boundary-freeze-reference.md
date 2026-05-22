# Phase 1 Ownership-Boundary Freeze Reference

Date: 2026-05-22

This note freezes the current ownership seams from the **consumer/reference** side in `aerobeat-ui-kit-community` before Phase 2 extraction work begins.

## Purpose

`aerobeat-ui-kit-community` is still the easiest place to inspect the end-to-end proof scenes, but it is **not** the intended long-term owner of shared interaction infrastructure. This note records what currently lives here only as reference truth and what belongs in the owning repos.

## Current ownership boundary

### `aerobeat-input-core` remains the owner of

- the canonical UI interaction contract
- event/source/surface/phase taxonomy
- the interaction bus
- the native 2D bridge path
- shared adapter semantics for publishing normalized interaction events

Reference paths currently mirrored into this testbed:
- `.testbed/addons/aerobeat-input-core/src/ui/adapters/screen_ui_input_adapter.gd`

### `aerobeat-ui-core` remains the owner of

- reusable consumer-side target bindings
- consumer base classes
- detection-agnostic UI reaction behavior driven by normalized events

Reference paths currently mirrored into this testbed:
- `.testbed/addons/aerobeat-ui-core/scripts/contract/aero_ui_contract_target_binding.gd`
- `.testbed/addons/aerobeat-ui-core/scripts/base/aero_contract_consumer_view_base.gd`

### `aerobeat-ui-kit-community` currently owns only reference/proof host glue

These proof hosts still carry scene-local wiring that exists so Phase 2 has a stable extraction reference:

- `.testbed/scripts/glass_shader_test.gd`
  - consumer-side proof wiring for the current screen-space contract demo
  - attaches the proof card to `AeroUiInteractionBus` and `ScreenUiInputAdapter`
  - useful as a reference for what the native 2D bridge consumer side expects, but not a second contract-owner surface

- `.testbed/scripts/glass_shader_gui_3d_test.gd`
  - world-hit raycast/projection reference logic for the current hybrid 3D proof
  - hover-owner transitions
  - press-owner / drag-owner capture continuity
  - projected `target_path` resolution against panel target rects
  - useful as the extraction reference for future spatial providers, but not the long-term home of reusable helper/provider code

## Phase 2 extraction intent

Phase 2 should move reusable pieces out of `aerobeat-ui-kit-community` while preserving the semantic parity defined in:

- `.plans/2026-05-22-native-2d-bridge-and-host-driven-3d-contract-architecture.md`
- `.plans/2026-05-22-spatial-ui-repo-family-architecture-and-rollout.md`

Expected ownership after extraction:

- reusable spatial helper-layer code -> `aerobeat-spatial-ui-core`
- reusable mouse-driven spatial provider code -> `aerobeat-spatial-ui-mouse`
- canonical contract / native 2D bridge ownership -> `aerobeat-input-core`
- reusable consumer/binding behavior -> `aerobeat-ui-core`
- proof/demo composition and visual kit scenes -> `aerobeat-ui-kit-community`

## Guardrails for future work

- Do not add new canonical contract ownership to this repo.
- Do not treat the vendored `.testbed/addons/*` mirrors as the source repo to evolve.
- Do not keep accumulating reusable spatial provider logic in the proof hosts.
- Do keep these proof hosts readable enough to act as extraction references until the owning repos absorb the reusable logic.
