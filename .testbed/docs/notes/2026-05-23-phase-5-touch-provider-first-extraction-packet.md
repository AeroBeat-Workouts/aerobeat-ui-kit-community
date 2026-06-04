# Phase 5 Touch Provider — First Extraction Packet

Date: 2026-05-23

This note converts the touch-readiness findings into the **first executable extraction packet** for a future dedicated touch-provider lane.

## Packet summary

**Recommended slice:** extract only the reusable **touch lifecycle/provider runtime** out of the hybrid proof host, while leaving world-ray acquisition and proof-scene composition in `aerobeat-ui-kit-community`.

That first slice should mirror the already-landed mouse-provider shape:

- `aerobeat-input-core` remains the canonical contract owner and keeps `HybridSubViewportInputAdapter`
- `aerobeat-spatial-ui-core` remains helper-layer only and continues to own shared projected-surface helpers / resolver helpers
- a future `aerobeat-spatial-ui-touch` lane should own per-touch runtime state, owner continuity, off-surface continuation policy, cancel policy, and adapter composition for `InputEventScreenTouch` / `InputEventScreenDrag`
- `aerobeat-ui-kit-community` should keep only world-hit acquisition, proof-scene composition, and any intentionally thin consumer-side wrappers/tests

This is the minimum honest vertical slice because it moves the reusable touch semantics without prematurely baking this proof scene’s camera / `Area3D` / raycast assumptions into the provider package.

## Minimum vertical slice to move first

Move the **touch publication/capture lane only**, not the hit-acquisition lane.

### Slice 1 owns

A future `aerobeat-spatial-ui-touch` should own:

1. per-pointer touch runtime state
2. owner-target continuity across press / drag / release
3. off-surface continuation using the last valid projected data
4. explicit cancel publication for interrupted touch lifecycles
5. mapping from projected touch input into `HybridSubViewportInputAdapter`
6. provider-facing runtime diagnostics describing owner/hover/last-published truth

### Slice 1 does not own

It should **not** own:

1. world ray creation
2. physics ray query setup
3. `PanelInputSurface` collision assumptions
4. proof-scene viewport/panel composition
5. canonical contract types or phase taxonomy
6. native 2D bridge behavior
7. duplicated target resolver / projection helper logic

## Exact source seams that move first

Current source of truth: `.testbed/scripts/glass_shader_gui_3d_test.gd`

### Move into the future touch-provider lane first

These are the exact host-local seams that should become provider-owned first:

1. **Touch runtime state field**
   - `_active_touch_state` (`.testbed/scripts/glass_shader_gui_3d_test.gd:506`)

2. **Touch event routing branch**
   - `_forward_world_panel_input(...)` touch branches for:
     - `InputEventScreenTouch` (`:654-655`)
     - `InputEventScreenDrag` (`:656-657`)

3. **Touch press / release / cancel lifecycle policy**
   - `_publish_screen_touch_to_contract(...)` (`:714-764`)
   - especially the local decisions for:
     - `event.canceled` -> `cancel` publication (`:719-733`)
     - ignore off-surface press (`:738-739`)
     - allow release continuation from prior projected state (`:740-747`)
     - preserve `owner_target_path` through release (`:743-756`)

4. **Touch drag continuity policy**
   - `_publish_screen_drag_to_contract(...)` (`:767-791`)
   - especially the local decisions for:
     - requiring prior active state (`:769-771`)
     - preserving `owner_target_path` across drag (`:773-783`)
     - publishing owner-vs-hover truth in the runtime/debug path (`:784-790`)

5. **Thin provider adapter seam already suitable for reuse**
   - `_publish_projected_phase(...)` (`:794-800`)
   - this is the natural provider-owned path for explicit `cancel` or future hover/diagnostic publication

### Likely move with the provider or become provider-owned wrappers

These are shared helper-composition seams used by touch today. They should not stay as behavior owners in the proof host after slice 1, but they also should not be duplicated if helper-layer code already covers them.

1. `_build_projected_data(...)` (`:838-862`)
2. `_resolve_projected_target_path_from_hit(...)` (`:865-870`)

For slice 1, the preferred direction is:
- the touch provider composes through packaged `AeroSpatialProjectionHelper` / `AeroSpatialRectTargetResolver`
- the proof host may keep a thin wrapper only if repo-local tests/probes still need a host-call seam

## Recommended first-slice move list

If the touch repo opens now, the first implementation packet should create these provider-lane artifacts:

1. `src/providers/touch/aero_spatial_ui_touch_provider.gd`
   - owns the extracted logic from `_active_touch_state`, `_publish_screen_touch_to_contract(...)`, and `_publish_screen_drag_to_contract(...)`

2. `src/providers/touch/aero_spatial_ui_touch_provider_config.gd`
   - mirrors the mouse lane’s config boundary
   - should carry at minimum:
     - pointer-id naming convention / prefix policy
     - `host_surface`
     - `target_resolution`
     - drag threshold passthrough where needed

3. `src/providers/touch/aero_spatial_ui_touch_runtime_boundary.gd`
   - explicitly documents lane ownership / non-goals

4. `docs/phase-1-boundary-freeze.md` or phase-appropriate lane doc
   - records that this lane owns touch lifecycle publication but not world-hit acquisition or contract ownership

5. provider-local tests equivalent in spirit to the mouse lane
   - press / drag / release continuity
   - off-surface release continuation
   - cancel semantics
   - owner-target preservation
   - drag-end-before-press-end ordering
   - truthful `screen_touch` + `hybrid_3d_gui` verification status remaining `unverified`

6. consumer cutover in `aerobeat-ui-kit-community`
   - replace local touch lifecycle code with calls into the packaged touch provider
   - keep host-local hit acquisition intact

## Explicit keep-local list after slice 1

After the first touch extraction step, these seams should still remain in `aerobeat-ui-kit-community`:

1. **World-hit acquisition**
   - `_screen_position_to_panel_hit(...)` (`.testbed/scripts/glass_shader_gui_3d_test.gd:803-835`)
   - including:
     - `camera_3d.project_ray_origin(...)`
     - `camera_3d.project_ray_normal(...)`
     - `PhysicsRayQueryParameters3D.create(...)`
     - `direct_space_state.intersect_ray(...)`
     - proof-scene `PanelInputSurface` assumptions

2. **Proof-scene surface description / authored layout refresh**
   - `_refresh_spatial_surface_descriptor(...)` (`:612-636`)
   - this is still tied to the authored panel scene and target-spec collection path in this repo

3. **Proof-scene runtime composition**
   - `_ensure_interaction_contract_nodes(...)` (`:575-590`)
   - `_inject_panel_view_interaction_bus(...)` (`:593-599`)
   - `_build_spatial_provider_runtime(...)` should remain the host composition seam, but after slice 1 it should instantiate both mouse and touch providers rather than owning touch behavior directly (`:602-609`)

4. **Probe/test wrappers only if still needed by repo-local tests**
   - `_build_projected_data(...)` (`:838-862`) may remain only as a thin delegation seam if host-side tests depend on it
   - `_resolve_projected_target_path_from_hit(...)` (`:865-870`) may remain only as a thin delegation seam if host-side tests depend on it

5. **Proof-scene debug/status presentation**
   - `_refresh_status(...)`, `_current_interaction_state_label(...)`, and related UI/debug text should stay host-local unless a future provider runtime API cleanly exposes richer diagnostics

## Validation and parity checklist

The first touch extraction pass should not ship without these checks.

### REF-08 semantic parity checks

1. `press_end.target_path` remains the original press owner, not the current hover target
2. hover ownership remains separate from press/drag ownership
3. `drag_end` publishes before `press_end`
4. `cancel` is used only for interrupted continuity, not ordinary release-outside
5. idle remains derived rather than explicitly emitted

### Existing mouse-lane parity checks

Touch slice 1 should match the mouse lane’s structural truth where applicable:

1. provider owns runtime state and lifecycle semantics
2. host owns world-hit acquisition
3. provider composes through packaged helper-layer resolver/projection code
4. provider exposes enough runtime state for proof-host diagnostics and tests
5. consumer repo proves the installed addon path rather than only repo-local source paths

### Concrete test cases required

1. **Touch press on target publishes `press_begin`**
   - target path resolves to the pressed control
   - pointer id uses the touch index lane

2. **Touch drag below threshold stays `press_hold`**
   - no premature drag transition

3. **Touch drag over threshold publishes `drag_begin`, then `drag_move`**
   - owner remains the original press owner

4. **Touch release after drag publishes `drag_end` before `press_end`**
   - both events target the press owner

5. **Touch release off-surface still resolves against prior owner/projected state**
   - ordinary release-outside is not upgraded to `cancel`

6. **Canceled touch publishes `cancel` and clears runtime state**
   - only from the explicit canceled path / broken continuity path

7. **Off-surface press does not publish**
   - preserve current conservative entry policy

8. **Verification truth remains conservative**
   - `source_variant=screen_touch`
   - `surface_type=hybrid_3d_gui`
   - verification status remains `unverified` unless live validation changes upstream truth

9. **Installed-addon consumer proof**
   - `aerobeat-ui-kit-community` should prove that the downstream-installed touch provider is the exercised code path, analogous to the packaged-resolver proof used for the mouse lane

## Why this is the minimum truthful slice

Anything smaller than this leaves reusable touch lifecycle semantics stranded in the proof host.
Anything larger than this risks dragging proof-scene world-hit acquisition into the provider lane too early.

So the first truthful slice is:

- **move touch lifecycle/provider semantics**
- **keep world-hit acquisition local**
- **prove parity against `REF-08` and the mouse lane before claiming readiness**

## Files inspected for this extraction packet

- `.testbed/scripts/glass_shader_gui_3d_test.gd`
- `docs/notes/2026-05-23-phase-5-touch-provider-readiness.md`
- `.plans/2026-05-22-native-2d-bridge-and-host-driven-3d-contract-architecture.md`
- `.plans/2026-05-22-spatial-ui-repo-family-architecture-and-rollout.md`
- `.testbed/tests/test_hybrid_mouse_release_path.gd`
- `.testbed/tests/test_hybrid_packaged_resolver_flow.gd`
- `.testbed/tests/ui/test_aero_ui_glass_panel_view_host_adoption.gd`
- `.testbed/addons/aerobeat-spatial-ui-mouse/docs/phase-2-first-mouse-provider-extraction.md`
- `.testbed/addons/aerobeat-spatial-ui-mouse/.testbed/tests/test_example.gd`
- `.testbed/addons/aerobeat-spatial-ui-mouse/src/providers/mouse/aero_spatial_ui_mouse_provider.gd`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-input-core/docs/ui-interaction-contract-v1.md`
- `.testbed/addons/aerobeat-input-core/src/ui/adapters/hybrid_subviewport_input_adapter.gd`
- `.testbed/addons/aerobeat-input-core/src/ui/adapters/screen_ui_input_adapter.gd`
