# Phase 5 Touch Provider — Parity and Test Packet

Date: 2026-05-23

This note defines the **test/parity packet that should exist before or alongside the first touch-provider extraction implementation**.

It is intentionally a planning artifact, not implementation.

## Why this packet exists

The first touch-provider extraction should not be judged by "seems right" hybrid behavior. It should be judged against:

1. the semantic baseline in `REF-08` (`.plans/2026-05-22-native-2d-bridge-and-host-driven-3d-contract-architecture.md`)
2. the already-extracted mouse-lane structure proved by:
   - `.testbed/tests/test_hybrid_mouse_release_path.gd`
   - `.testbed/tests/test_hybrid_packaged_resolver_flow.gd`
3. the current touch-proof host behavior in `.testbed/scripts/glass_shader_gui_3d_test.gd`
4. the contract truth in `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-input-core/docs/ui-interaction-contract-v1.md`

If the future touch lane cannot satisfy this packet, the extraction is not ready to claim parity.

## Packet summary

**Required packet shape for slice 1:**

- **provider-local parity tests** in the future touch repo
- **consumer-side installed-addon proof tests** in `aerobeat-ui-kit-community`
- **semantic-order assertions** tied directly to `REF-08`
- **runtime/probe expectations** proving owner continuity, hover-vs-owner separation, and truthful verification metadata
- **a pass/fail checklist** that can be used by coder, QA, and auditor without reinterpreting the contract

The first truthful touch extraction is ready only when both of these are true:

1. the provider repo proves touch lifecycle semantics in isolation
2. the consumer repo proves the installed packaged provider is the code path actually being exercised downstream

## Recommended slice-1 test inventory

## A. Consumer-repo tests to add in `aerobeat-ui-kit-community`

These should exist before or land alongside the first host cutover to a packaged touch provider.

### 1. `.testbed/tests/test_hybrid_touch_release_path.gd`

Purpose: touch equivalent of `test_hybrid_mouse_release_path.gd`.

Required assertions:

1. **Explicit touch release completes against the press owner**
   - synthesize `InputEventScreenTouch` press on `PrimaryActionButton`
   - assert publish returns `true`
   - assert `_last_contract_phase == "press_begin"`
   - synthesize touch release for the same pointer
   - assert publish returns `true`
   - assert final `_last_contract_phase == "press_end"`
   - assert `_last_release_target_path` contains `PrimaryActionButton`
   - assert the button/toggle side effect actually completed

2. **Drag release orders `drag_end` before `press_end`**
   - press touch on target
   - drag past threshold
   - release
   - assert emitted phase sequence includes `drag_begin`, `drag_move` (optional if enough motion), `drag_end`, `press_end`
   - assert `drag_end` occurs before `press_end`
   - assert both `drag_end.target_path` and `press_end.target_path` remain the press owner

3. **Release off-surface still resolves to prior owner rather than cancel**
   - press on target
   - move/release with no live hit
   - assert release still publishes
   - assert terminal phase is `press_end`, not `cancel`
   - assert terminal `target_path` remains the original owner

### 2. `.testbed/tests/test_hybrid_touch_provider_parity.gd`

Purpose: semantic packet for touch owner continuity and metadata truth.

Required assertions:

1. **Off-surface press does not publish**
   - touch press away from the panel or on non-interactive space
   - assert publish returns `false`
   - assert no active touch state is created for that pointer

2. **Touch drag below threshold stays `press_hold`**
   - press on target
   - small drag below configured threshold
   - assert `_last_contract_phase == "press_hold"`
   - assert no drag state is reported yet

3. **Touch drag over threshold becomes drag while preserving owner**
   - press on target
   - drag beyond threshold
   - assert phase becomes `drag_begin` then `drag_move`
   - assert event `target_path` stays the original press owner
   - assert live hover may differ in runtime metadata without changing owner

4. **Canceled touch publishes `cancel` and clears runtime state**
   - begin touch on target
   - synthesize canceled `InputEventScreenTouch`
   - assert publish returns `true`
   - assert `_last_contract_phase == "cancel"`
   - assert `_active_touch_state` no longer contains that pointer

5. **Verification metadata remains conservative**
   - for any published touch event assert:
     - `source_type == "touch"`
     - `source_variant == "screen_touch"`
     - `surface_type == "hybrid_3d_gui"`
     - `verification_status == "unverified"`
   - assert notes remain the contract/bus truth, not a provider-local promotion

### 3. `.testbed/tests/test_hybrid_packaged_touch_provider_flow.gd`

Purpose: installed-addon proof equivalent of `test_hybrid_packaged_resolver_flow.gd`.

Required assertions:

1. **Installed touch provider script is readable from `res://addons/...`**
2. **Installed touch provider composes through packaged helper/provider seams rather than host-local fallback logic**
3. **Installed touch provider exposes a public runtime/describe seam comparable to the mouse lane**
4. **Hybrid host runtime actually routes touch through the installed provider path**
5. **Published metadata still includes shared helper labels such as `host_surface` and `target_resolution`**
6. **Installed provider does not re-own world-ray acquisition**
   - provider source should not contain camera ray creation / physics raycast scene ownership
   - those remain host-local

## B. Future provider-repo tests to add in the touch lane

Assuming a future package like `aerobeat-spatial-ui-touch`, slice 1 should include provider-local tests roughly parallel to the mouse lane.

Recommended files:

1. `.testbed/tests/test_touch_provider_press_release_semantics.gd`
2. `.testbed/tests/test_touch_provider_drag_semantics.gd`
3. `.testbed/tests/test_touch_provider_cancel_and_continuity.gd`
4. `.testbed/tests/test_touch_provider_runtime_state.gd`

Required provider-local assertions:

1. pointer state is keyed by touch pointer id (`touch_<index>` unless explicitly configured otherwise)
2. `press_begin` stores owner/capture state
3. below-threshold drag stays `press_hold`
4. threshold crossing yields `drag_begin` exactly once
5. continued drag yields `drag_move`
6. release after drag publishes `drag_end` before `press_end`
7. `press_end.target_path` remains the press owner
8. `cancel` clears active pointer state and does not masquerade as release
9. provider runtime description reports enough truth for downstream diagnostics:
   - active pointer ids
   - owner target path
   - live hover target path if tracked
   - last projected data / last published phase / last release target path
10. provider never claims `verified` status for hybrid touch unless upstream truth changes

## Exact fixture and probe expectations

The first extraction implementation should not invent new proof surfaces. Reuse the current hidden testbed hybrid scene and its authored target.

### Required fixture expectations

1. **Scene fixture**
   - use `res://scenes/glass-shader-gui-3d-test.tscn`
   - keep `set_auto_rotate_enabled(false)` in tests for stability

2. **Primary target fixture**
   - derive screen position using the same `PrimaryActionButton` lookup pattern already used by mouse tests
   - do not hardcode screen coordinates

3. **Touch pointer fixture**
   - use touch index `0` for the first parity slice unless a test explicitly verifies multi-pointer isolation
   - pointer id expectation is `touch_0`

4. **Runtime probe expectations**
   - there must be a readable runtime description seam after extraction, analogous to `_current_mouse_runtime_state()`
   - consumer tests should be able to inspect:
     - active touch state count
     - owner target path
     - last release target path
     - last projected/published metadata
   - if the host keeps a temporary wrapper such as `_current_touch_runtime_state()`, that wrapper must delegate to the installed provider rather than recreate logic locally

5. **Phase capture probe**
   - tests should record emitted contract phases through the interaction bus rather than inferring order only from final state
   - minimum capture fields per event:
     - `phase`
     - `target_path`
     - `pointer_id`
     - `source_variant`
     - `verification_status`
     - `raw_event_class`

## Installed-addon proof recipe for the future touch lane

This is the touch equivalent of the current packaged-resolver proof.

### Expected downstream setup

1. pin the future touch package in `.testbed/addons.jsonc`
2. install/refresh the hidden testbed addons so the provider is present under `res://addons/...`
3. cut the hybrid host over so it instantiates the packaged touch provider instead of owning touch lifecycle logic locally
4. keep world-hit acquisition in `glass_shader_gui_3d_test.gd`

### Proof steps

1. **Static source proof**
   - read the installed provider source from `res://addons/<touch-package>/src/providers/touch/...`
   - assert the file is non-empty and readable from the hidden testbed
   - assert it contains the expected provider/config/runtime seam names
   - assert it does not contain host-owned world-hit responsibilities

2. **Runtime wiring proof**
   - instantiate the hybrid scene from the consumer repo
   - synthesize touch press/drag/release events at the primary target
   - assert the publish path succeeds end-to-end
   - assert runtime state comes from the provider-owned describe seam

3. **Shared metadata proof**
   - inspect published/raw metadata from the consumer side
   - assert:
     - `host_surface == "PanelInputSurface"`
     - `target_resolution == "rect_target_specs"`
     - published target path matches the actual control path
   - this proves the host still owns world-hit acquisition while the provider owns lifecycle semantics

4. **No-local-fallback proof**
   - assert the consumer host no longer contains the old local touch lifecycle ownership seams as behavior owners
   - acceptable temporary wrappers must be thin delegations only

## Explicit semantic-parity checks against `REF-08`

The following are pass/fail requirements, not suggestions.

1. **`press_end.target_path` is the press owner**
   - fail if it switches to current hover target or empty target on ordinary release-outside

2. **Hover ownership and press/drag ownership stay separate**
   - fail if hover transition retargets the captured drag/release owner mid-gesture

3. **`drag_end` publishes before `press_end`**
   - fail if release after drag emits only `press_end` or reverses the order

4. **`cancel` means interrupted continuity only**
   - fail if ordinary release-outside becomes `cancel`
   - fail if provider emits `cancel` just because live hover moved away

5. **Idle stays derived, not emitted**
   - fail if the provider invents an `idle` publication phase

6. **Touch truth stays `unverified`**
   - fail if provider or consumer tests upgrade `screen_touch + hybrid_3d_gui` beyond bus truth without approved live validation

## Explicit structure-parity checks against the mouse lane

The touch lane should not merely produce similar events. It should follow the same ownership shape as the extracted mouse lane where applicable.

1. **Provider owns lifecycle/runtime state**
   - pass only if touch owner continuity and release/cancel policy move out of the consumer host

2. **Host owns world-hit acquisition**
   - pass only if camera ray creation, physics query, and panel-hit derivation remain in `aerobeat-ui-kit-community`

3. **Shared helper layer remains shared**
   - pass only if target-resolution / projected-data shaping composes through packaged helper paths instead of re-forking logic in the touch lane

4. **Installed addon is the exercised downstream path**
   - pass only if consumer tests prove the hidden testbed uses the installed packaged provider

5. **Runtime diagnostics are inspectable**
   - pass only if downstream tests can inspect enough provider runtime truth to debug owner/hover/release behavior without re-owning state locally

## Recommended concrete assertion list for slice 1

This is the shortest honest assertion set for the first implementation slice.

### Must-pass assertions

1. touch press on `PrimaryActionButton` publishes `press_begin`
2. touch release on the same pointer publishes `press_end`
3. touch release toggles/completes the primary action in the proof scene
4. below-threshold touch drag stays `press_hold`
5. over-threshold touch drag publishes `drag_begin`
6. continued drag publishes `drag_move`
7. release after drag publishes `drag_end` before `press_end`
8. `drag_end.target_path == press_end.target_path == original press owner`
9. off-surface release publishes `press_end`, not `cancel`, when continuity exists
10. canceled touch publishes `cancel` and clears active pointer state
11. off-surface press with no prior continuity does not publish
12. `pointer_id == "touch_0"` for touch index `0`
13. `source_variant == "screen_touch"`
14. `surface_type == "hybrid_3d_gui"`
15. `verification_status == "unverified"`
16. installed provider source is readable from `res://addons/...`
17. installed provider is the code path exercised by the consumer test
18. host still supplies `host_surface == "PanelInputSurface"` and `target_resolution == "rect_target_specs"`

### Nice-to-have but not required for slice 1

1. multi-pointer isolation tests (`touch_0` vs `touch_1`)
2. explicit hover-readout assertions during active drag
3. richer provider runtime snapshots for human-readable QA output

## Pass/fail checklist for coder, QA, and auditor

A slice-1 touch extraction is **PASS** only if every item below is true:

- provider-local tests cover press/hold/drag/release/cancel continuity
- consumer tests prove the installed addon path, not a repo-local fallback path
- `press_end.target_path` remains the original owner
- `drag_end` occurs before `press_end`
- ordinary release-outside is not rewritten into `cancel`
- touch verification remains `unverified`
- host still owns world-hit acquisition
- touch provider owns lifecycle/runtime state
- shared helper/resolver composition is still shared rather than forked
- runtime/probe surface is sufficient to inspect owner and release truth downstream

The slice is **FAIL** if any of the following occurs:

- final release target follows current hover instead of original owner
- drag release omits `drag_end`
- `cancel` is used for normal release-outside
- consumer proof does not show installed-addon usage
- provider duplicates host world-ray logic
- provider silently promotes verification truth
- downstream tests cannot inspect enough runtime truth to explain a failure

## Recommended file destinations when implementation starts

In `aerobeat-ui-kit-community`:

- `.testbed/tests/test_hybrid_touch_release_path.gd`
- `.testbed/tests/test_hybrid_touch_provider_parity.gd`
- `.testbed/tests/test_hybrid_packaged_touch_provider_flow.gd`

In the future touch repo:

- `.testbed/tests/test_touch_provider_press_release_semantics.gd`
- `.testbed/tests/test_touch_provider_drag_semantics.gd`
- `.testbed/tests/test_touch_provider_cancel_and_continuity.gd`
- `.testbed/tests/test_touch_provider_runtime_state.gd`

## Files inspected for this packet

- `docs/notes/2026-05-23-phase-5-touch-provider-readiness.md`
- `docs/notes/2026-05-23-phase-5-touch-provider-first-extraction-packet.md`
- `.testbed/tests/test_hybrid_packaged_resolver_flow.gd`
- `.testbed/tests/test_hybrid_mouse_release_path.gd`
- `.testbed/tests/ui/test_aero_ui_glass_panel_view_host_adoption.gd`
- `.testbed/scripts/glass_shader_gui_3d_test.gd`
- `docs/notes/2026-05-15-multi-target-hybrid-input-stress-design.md`
- `docs/notes/2026-05-15-input-core-screen-2d-adoption-design.md`
- `.testbed/addons/aerobeat-input-core/src/ui/adapters/hybrid_subviewport_input_adapter.gd`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-input-core/docs/ui-interaction-contract-v1.md`
- `.plans/2026-05-22-native-2d-bridge-and-host-driven-3d-contract-architecture.md`
- `.plans/2026-05-22-spatial-ui-repo-family-architecture-and-rollout.md`

## Files touched for this packet

- `docs/notes/2026-05-23-phase-5-touch-provider-parity-test-packet.md`

## Bottom line

The missing piece is not more extraction theory. It is a concrete parity packet that forces the first touch-provider implementation to prove four things at once:

1. semantic parity with `REF-08`
2. structural parity with the extracted mouse lane
3. installed-addon consumer truth in `aerobeat-ui-kit-community`
4. conservative verification truth for hybrid touch

That is the minimum durable packet needed before calling the first touch-provider extraction honest.
