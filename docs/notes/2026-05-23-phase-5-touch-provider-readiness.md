# Phase 5 Touch Provider Readiness

Date: 2026-05-23

This note records the extraction-readiness result for the still-local hybrid touch path in `aerobeat-ui-kit-community` after the mouse-provider and packaged-resolver cleanup passes.

## Readiness verdict

**Ready for repo split planning, not ready for a blind code move.**

The current proof host already has the correct high-level ownership shape:

- `aerobeat-input-core` owns canonical interaction semantics and the `HybridSubViewportInputAdapter`
- `aerobeat-spatial-ui-core` owns reusable projected-surface helpers and target-resolution helpers
- `aerobeat-ui-kit-community` still owns world-ray acquisition plus the remaining touch proof glue in the hybrid host

That means a future `aerobeat-spatial-ui-touch` style repo can be opened without reopening the mouse/provider split. But the current touch path is **not** just a thin call into shared provider code yet. The proof host still owns touch-specific capture/owner continuity and projected-data composition decisions locally, so extraction should happen as an intentional provider-lane pass rather than a mechanical copy/paste from this repo.

## What still remains local today

The remaining touch-path local glue is concentrated in `.testbed/scripts/glass_shader_gui_3d_test.gd`:

1. **Touch pointer ownership state**
   - `_active_touch_state`
   - per-pointer stored `projected_data`
   - per-pointer stored `owner_target_path`

2. **Touch event entry routing**
   - `_forward_world_panel_input(...)` still branches on `InputEventScreenTouch` and `InputEventScreenDrag`

3. **Touch press / release policy**
   - `_publish_screen_touch_to_contract(...)` decides:
     - whether off-surface press should be ignored
     - whether off-surface release may continue via prior captured state
     - when cancel should publish
     - which target path remains the owner across the lifecycle

4. **Touch drag policy**
   - `_publish_screen_drag_to_contract(...)` decides:
     - drag continuity from prior owner state
     - reuse of prior projected data when the live hit is missing
     - hover-vs-owner reporting for debug truth

5. **Projected-data assembly for touch continuation**
   - `_build_projected_data(...)`
   - `_resolve_projected_target_path_from_hit(...)`
   - `_screen_position_to_panel_hit(...)`
   - these are shared with the mouse proof, but touch currently depends on them through host-local wrappers and host-local world-hit acquisition

## What belongs in a future dedicated touch spatial provider repo

A future concrete touch provider lane should own the reusable **touch-specific spatial-provider lifecycle**, analogous to what `aerobeat-spatial-ui-mouse` now owns for mouse:

1. **Per-touch pointer runtime state**
   - active touch bookkeeping
   - owner-path continuity
   - last projected-data continuity needed for off-surface release/drag behavior

2. **Touch lifecycle publication policy**
   - press begin / press end publication
   - drag threshold handling via the existing input-core adapter boundary
   - cancel handling when continuity is broken
   - stable mapping of `InputEventScreenTouch` / `InputEventScreenDrag` into adapter calls

3. **Provider-facing runtime diagnostics**
   - touch runtime description/debug state similar in spirit to the mouse provider runtime state
   - enough metadata for proof hosts and tests to report owner target, hover target, and last publish truth without re-owning provider internals

4. **Thin public provider config/runtime boundary**
   - pointer-id naming policy if needed
   - host metadata passthrough (`host_surface`, `target_resolution`, etc.)
   - no contract ownership and no helper-layer duplication

## What should remain proof-host-local even after a touch provider exists

Even after a dedicated touch lane exists, these seams should still stay in `aerobeat-ui-kit-community` for this proof scene:

1. **World-ray acquisition and scene hit sourcing**
   - camera ray creation
   - `PhysicsRayQueryParameters3D`
   - raycast against `PanelInputSurface`
   - world-hit to panel-hit conversion tied to this scene's mesh/camera layout

2. **Proof-scene composition**
   - mounting the panel viewports
   - authored panel scene composition
   - proof-scene status text / demo UX

3. **Probe-facing compatibility wrappers when they are only test harness seams**
   - host helpers such as `_resolve_projected_target_path_from_hit(...)` and `_build_projected_data(...)` can remain as consumer-side wrappers if repo-local tests still depend on them
   - those wrappers should delegate into packaged helper/provider code rather than regrowing local ownership

## Semantic-parity and dependency risks that must stay aligned with REF-08

The main risk is not missing an API; it is letting the touch lane publish meanings that drift from the native 2D bridge and the existing mouse/provider split.

### Required parity rules

From `REF-08`, the future touch provider must preserve at least these semantics:

- `press_end.target_path` stays the **press owner**, not the current hover target
- hover ownership and press/drag ownership remain separate concepts
- `drag_end` publishes before `press_end`
- `cancel` is only for interrupted lifecycle/continuity loss, not ordinary release-outside
- idle remains derived rather than emitted

### Concrete drift risks visible in the current proof host

1. **Owner-path continuity drift**
   - the current host stores `owner_target_path` per touch and republishes against that owner even when live hover changes
   - the future provider must preserve this, or touch release semantics will diverge from both REF-08 and the mouse lane

2. **Cancel-vs-release drift**
   - the current host only publishes `cancel` from the explicit canceled-touch path
   - extraction must keep that conservative meaning unless real contract changes are approved upstream

3. **Adapter/provider boundary drift**
   - `HybridSubViewportInputAdapter` already owns canonical phase publication once projected data is provided
   - the future touch repo must not clone contract semantics out of `aerobeat-input-core`; it should compose through the adapter exactly like the mouse lane composes through the contract/helper split

4. **Helper-layer duplication drift**
   - `aerobeat-spatial-ui-core` is helper-only
   - the touch repo should consume `AeroSpatialSurfaceDescriptor`, `AeroSpatialProjectionHelper`, and `AeroSpatialRectTargetResolver` rather than forking target resolution or projected-data shaping again

5. **Verification-truth drift**
   - touch remains `unverified` today in `aerobeat-input-core`
   - extraction into a provider repo must not silently promote the verification claim; real device validation still has to happen separately

## Recommended ownership split

### Future `aerobeat-spatial-ui-touch`

Own:
- touch provider runtime state
- touch owner/capture continuity
- touch-specific publish/cancel policy
- adapter composition for projected touch events
- provider-local tests proving semantic parity against the contract

Do not own:
- canonical contract/event taxonomy
- native 2D bridge behavior
- shared projection/target-resolution helper duplication
- scene-specific raycast/world-hit acquisition

### `aerobeat-ui-kit-community`

Keep:
- proof-scene world-hit acquisition
- proof-scene composition/debug UI
- any intentionally thin test/probe wrappers
- consumer-proof validation that the packaged touch lane is the one being exercised downstream

## Practical next slice

The next truthful step is **provider extraction planning plus parity tests**, not direct implementation in this repo.

That follow-up should:

1. open the dedicated touch provider repo/lane
2. move the reusable touch runtime-state and lifecycle glue there
3. keep the proof host responsible only for world-hit acquisition and consumer-side proof wiring
4. add parity-focused tests that compare touch publication meaning against the REF-08 semantic matrix and the already-extracted mouse/provider split

## Files inspected for this readiness result

- `.testbed/scripts/glass_shader_gui_3d_test.gd`
- `.testbed/scripts/glass_shader_test.gd`
- `.testbed/tests/ui/test_aero_ui_glass_panel_view_host_adoption.gd`
- `docs/notes/2026-05-22-phase-2-proof-host-cutover-deferred-seams.md`
- `docs/notes/2026-05-23-phase-3-packaged-resolver-proof-seams.md`
- `.plans/2026-05-22-native-2d-bridge-and-host-driven-3d-contract-architecture.md`
- `.plans/2026-05-22-spatial-ui-repo-family-architecture-and-rollout.md`
- `../aerobeat-input-core/docs/ui-interaction-contract-v1.md`
- `../aerobeat-input-core/src/ui/adapters/hybrid_subviewport_input_adapter.gd`
- `.testbed/addons/aerobeat-spatial-ui-core/docs/phase-1-boundary-freeze.md`
- `docs/notes/2026-05-15-input-core-hybrid-adoption-design.md`
