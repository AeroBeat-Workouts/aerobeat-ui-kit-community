# `aerobeat-input-core` adoption design for hybrid world-space UI testbed

**Date:** 2026-05-15  
**Repo:** `aerobeat-ui-kit-community`  
**Scope:** design only, no implementation  
**Primary target:** `.testbed/scenes/glass-shader-gui-3d-test.tscn` + `.testbed/scripts/glass_shader_gui_3d_test.gd`

---

## Goal

Adopt the approved `aerobeat-input-core` UI interaction contract into this repo’s hybrid world-space testbed so the testbed stops owning its own normalized input semantics and instead becomes a host integration layer that:

- performs world hit detection and surface projection locally
- feeds projected data into `HybridSubViewportInputAdapter`
- publishes normalized `AeroUiInteractionEvent` traffic through `AeroUiInteractionBus`
- lets downstream widget/test behavior consume the shared contract instead of repo-local raw Godot event parsing

---

## References consulted

- `../.plans/2026-05-15-input-core-adoption-for-hybrid-ui.md`
- `../.plans/2026-05-15-hybrid-3d-gui-input-detection.md`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-input-core/docs/ui-interaction-contract-v1.md`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-input-core/docs/ui-interaction-contract-v1-proposal.md`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-input-core/.plans/2026-05-15-ui-input-abstraction-contract.md`

---

## What the current hybrid proof does

### Current host scene/script

The current proof lives in:

- `.testbed/scenes/glass-shader-gui-3d-test.tscn`
- `.testbed/scripts/glass_shader_gui_3d_test.gd`

It already proves the hard host-side pieces we still need after contract adoption:

1. ray-pick against `PanelInputSurface`
2. convert screen ray hit -> local panel hit
3. convert local panel hit -> normalized UV
4. convert UV -> `PanelViewport` pixel coordinates
5. forward mouse/touch event classes into `panel_viewport`
6. keep capture-like local state for off-surface release/drag continuity

### Current local responsibilities in `glass_shader_gui_3d_test.gd`

The script currently owns all of these directly:

- raw input class switching in `_forward_world_panel_input`
- host hit testing in `_screen_position_to_panel_hit`
- viewport coordinate mapping
- forwarding of `InputEventMouseButton`, `InputEventMouseMotion`, `InputEventScreenTouch`, and `InputEventScreenDrag` into `panel_viewport`
- local hover/capture/touch tracking:
  - `_mouse_panel_capture`
  - `_mouse_hover_active`
  - `_active_touch_positions`
  - `_last_mouse_viewport_position`
- debug text that describes the forwarded raw event path

### Current downstream behavior path

The authored panel logic in:

- `.testbed/scripts/glass_shader_panel_source.gd`

still reacts to raw/native `Control` behavior via:

- `preview_button.mouse_entered`
- `preview_button.mouse_exited`
- `preview_button.button_down`
- `preview_button.button_up`
- `preview_button.toggled`
- `preview_button.gui_input`

So the current proof is a good hybrid-host prototype, but it does **not** yet prove that downstream widget behavior depends on the shared normalized contract.

---

## Current dependency / GodotEnv state

### Existing `.testbed` manifest

Current manifest:

- `.testbed/addons.jsonc`

Current entries:

- `aerobeat-ui-core`
- `aerobeat-vendor-godot-unit-test`

`aerobeat-input-core` is **not** currently installed into this repo’s `.testbed` dependency graph.

### Relevant GodotEnv convention

For this repo shape, the canonical dependency contract is `.testbed/addons.jsonc`.

The cleanest adoption wiring is to add a first-party entry using the repo name as the addon key:

```jsonc
"aerobeat-input-core": {
  "url": "git@github.com:AeroBeat-Workouts/aerobeat-input-core.git",
  "checkout": "<approved tag or temporary approved branch>",
  "subfolder": "/"
}
```

Notes:

- keep the key exactly `aerobeat-input-core`
- keep SSH remote form
- keep `subfolder: "/"`
- do not customize `path` or `cache`
- prefer a tagged checkout once the adoption target is pinned
- if this adoption must consume the just-landed contract before a tag bump exists, a temporary branch pin is acceptable for local/dev work, but the committed repo state should end at an approved durable tag

### Project config implications

`project.godot` currently only explicitly enables the vendorized GUT plugin. That is fine.

The input-core classes are `class_name` scripts under repo root and should become available after GodotEnv restore/import. No new plugin enablement is required unless the implementation deliberately chooses an autoload plugin later. For this adoption slice, the cleanest path is **scene-local node instancing**, not plugin/autoload changes.

---

## Cleanest adoption shape

## Recommendation in one sentence

Keep all world-hit math local to `glass_shader_gui_3d_test.gd`, add a local `AeroUiInteractionBus` + `HybridSubViewportInputAdapter` to the hybrid test scene, route projected data into the adapter, and move the panel proof behavior in `glass_shader_panel_source.gd` onto `AeroUiInteractionListener` / `AeroUiInteractable` instead of raw `Button.gui_input` semantics.

---

## Responsibility split after adoption

### Remains local host glue in `ui-kit-community`

These responsibilities should stay in this repo because `input-core` explicitly does **not** claim to own them for hybrid world-presented UI:

1. **Ray picking against the world-space panel surface**
   - `Camera3D.project_ray_origin`
   - `Camera3D.project_ray_normal`
   - `PhysicsRayQueryParameters3D`
   - collision filtering against `PanelInputSurface`

2. **Projection math from world hit to surface coordinates**
   - hit position -> local panel position
   - local panel position -> UV
   - UV -> viewport pixel coordinates

3. **Scene-specific surface metadata**
   - actual `surface_id`
   - actual `surface_pixel_size`
   - world hit normal / direction values
   - any scene-local debug notes

4. **Continuation policy when the pointer leaves the panel**
   - whether off-surface release should still complete the interaction
   - whether hover exit should emit immediately on miss
   - whether cancel should be emitted on interruption/lost validity

5. **Proof-scene target routing**
   - for this testbed, the host can truthfully declare that the authored card button is the target when the hit lands inside the interactive card region

### Moves to shared contract usage

These responsibilities should move out of repo-local custom semantics and into `aerobeat-input-core` usage:

1. **Canonical phase generation for forwarded events**
   - `press_begin`
   - `press_hold`
   - `drag_begin`
   - `drag_move`
   - `drag_end`
   - `press_end`

2. **Normalized source/button taxonomy**
   - `mouse` / `touch`
   - `screen_mouse` / `screen_touch`
   - `primary` / `contact`

3. **Truthful verification metadata**
   - use bus defaults or local override only if evidence justifies it

4. **Downstream interaction consumption**
   - use `AeroUiInteractionBus`
   - use `AeroUiInteractionListener` and/or `AeroUiInteractable`
   - stop making the proof logic depend on raw `InputEvent*` classes inside `glass_shader_panel_source.gd`

5. **Interaction-state interpretation**
   - hover/pressed/dragging/tapped behaviors should come from shared helpers or canonical phase handling, not `gui_input` event-class branching in repo-local panel code

---

## File-level change plan

## 1. `.testbed/addons.jsonc`

### Change
Add `aerobeat-input-core` to the manifest.

### Expected result
After `godotenv addons install` and import, `.testbed/addons/aerobeat-input-core/...` is available and the testbed can reference:

- `AeroUiInteractionBus`
- `HybridSubViewportInputAdapter`
- `AeroUiInteractionListener`
- `AeroUiInteractable`

### Suggested dependency pin
Prefer the first durable tag that includes commit `94a2e42` and the rollout docs. If that tag does not exist yet, temporarily pin the branch/commit used for this rollout, then normalize to a tag before treating the integration as stable.

---

## 2. `.testbed/scenes/glass-shader-gui-3d-test.tscn`

### Change
Add scene-local contract nodes under the host scene, ideally near the root:

- `AeroUiInteractionBus`
- `HybridSubViewportInputAdapter`

### Suggested shape
Example conceptual tree:

- `GlassShaderGui3DTest`
  - `AeroUiInteractionBus`
  - `HybridInputAdapter`
  - existing world nodes...

### Adapter config
Set:

- `bus_path` to the bus node
- `surface_id` to a stable testbed-specific ID, e.g. `hybrid_glass_panel`
- `surface_type` to `hybrid_3d_gui`
- `surface_pixel_size` to the actual `PanelViewport.size`
- `drag_threshold_pixels` to match or intentionally replace the current local threshold behavior

### Why scene-local instead of autoload
This keeps the adoption slice isolated, explicit, and easy to audit. The goal here is to prove contract integration inside one hybrid scene, not to promote a repo-wide singleton policy yet.

---

## 3. `.testbed/scripts/glass_shader_gui_3d_test.gd`

### Change
Refactor it from “raw event forwarder” into “hybrid host integration publisher”.

### Remove or reduce
Minimize or delete the parts whose job is now covered by `HybridSubViewportInputAdapter`:

- repo-local phase semantics
- repo-local source-type semantics
- repo-local event meaning in status text
- any future temptation to recreate bus logic here

### Keep
Preserve the host-owned pieces:

- `_screen_position_to_panel_hit`
- panel surface size lookup
- world hit mapping
- continuity state needed to know when an interaction should still be forwarded or explicitly exited/canceled

### New responsibility
Build a `projected_data` dictionary and call the adapter instead of pushing meaning directly into downstream logic.

Recommended `projected_data` fields per forwarded event:

- `screen_position`
- `surface_normalized_position`
- `surface_position`
- `world_position`
- `world_normal`
- `world_direction`
- `target_path` when known
- optional `raw_metadata` for extra host debugging

### Important nuance: keep host continuity state, but only as transport glue
The host probably still needs local state for:

- active mouse capture
- active touches
- hover-known vs hover-lost
- last projected position for off-surface continuation

That is okay. The key is that this state should only decide **whether/how to publish via the adapter**, not define downstream interaction semantics.

### Recommended publishing pattern

#### Mouse button / touch press-release / drag events
Use:

- `HybridSubViewportInputAdapter.publish_from_input_event(event, projected_data, overrides)`

This lets the shared adapter normalize:

- source taxonomy
- phase transitions for press/hold/drag lanes
- button/contact meaning
- default verification status

#### Hover enter / hover exit on world miss transitions
This is the one place where host glue should stay explicit.

`HybridSubViewportInputAdapter` currently accepts projected data and can publish explicit phases, but it does not independently perform 3D hover boundary detection once the ray no longer hits the panel. So the host should own:

- first hit after no-hit -> `hover_enter`
- hit while not pressed -> normal motion path / `hover_move`
- miss after prior hit and not captured -> `hover_exit`
- interruption / invalidated capture -> `cancel` when appropriate

Use:

- `publish_projected_phase(PHASE_HOVER_ENTER, ...)`
- `publish_projected_phase(PHASE_HOVER_EXIT, ...)`
- `publish_projected_phase(PHASE_CANCEL, ...)`

This is still contract usage, not a contract bypass.

### Recommended target-path policy for this proof slice
For the current proof scene, the simplest truthful target is the one main interactive card button inside the mounted panel UI. Since the whole proof is centered on that one authored card, the host can resolve and publish that button’s `NodePath` as `target_path` for panel hits intended for the card interaction.

That gives the downstream panel script a stable filter target without needing raw `gui_input` parsing.

If later the panel grows multiple interactive regions, target resolution can get more granular. That is follow-on work, not required for this first adoption slice.

---

## 4. `.testbed/scripts/glass_shader_panel_source.gd`

### Change
Move the proof behavior off raw `Button` input signals and onto shared contract consumers.

### Current anti-goal
Do **not** leave the proof behavior primarily driven by:

- `preview_button.gui_input`
- `mouse_entered`
- `mouse_exited`
- `button_down`
- `button_up`
- `toggled`

If those remain the source of truth, the scene is still proving native forwarded Godot events, not the shared AeroBeat interaction contract.

### Cleanest consumer pattern
Add one of these inside the authored panel scene/script:

#### Preferred option: `AeroUiInteractable`
Use it for stateful behavior:

- hover state
- pressed state
- dragging state
- tapped signal

This maps well to the existing proof UI.

#### Optional companion: `AeroUiInteractionListener`
Use it if the proof scene wants explicit phase counters or a per-phase debug readout.

### Recommended behavior wiring
Drive the current proof readouts from normalized events/state instead of raw event classes:

- `_hover_active` <- `hovered_changed`
- `_press_active` <- `pressed_changed`
- drag counters <- `dragging_changed` and/or listener drag signals
- toggle/count behavior <- `tapped`
- last input source / pointer summary <- `last_event.source_variant`, `last_event.phase`, `last_event.surface_position`
- verification truth readout <- `last_event.verification_status` and `last_event.verification_notes`

### Important proof decision
The panel no longer needs to rely on native `Button.toggle_mode` semantics to prove input. It can still look like a button/card, but the proof value is higher if the visual toggle/debug state is driven by normalized contract events.

That is the clearest “downstream widget behavior uses the shared contract” demonstration.

---

## 5. Optional new local helper script(s)

A small local helper is reasonable if it keeps the host scene clean.

Examples:

- a tiny panel-target resolver helper
- a small bridge that resolves the interactive button path after mounting the panel scene
- a debug overlay helper that subscribes to the bus and prints normalized events

This is optional. The adoption does **not** need a new local abstraction layer if the existing host script can stay readable.

---

## Projected hit data contract for this repo

The host should feed `HybridSubViewportInputAdapter` with a dictionary shaped approximately like this when a world hit is valid:

```gdscript
{
  "screen_position": event.position,
  "surface_normalized_position": uv,
  "surface_position": Vector2(uv.x * panel_viewport.size.x, uv.y * panel_viewport.size.y),
  "world_position": hit.position,
  "world_normal": hit.normal,
  "world_direction": ray_direction,
  "target_path": preview_button_path,
  "raw_metadata": {
    "host_surface": "PanelInputSurface",
    "uv": uv,
    "local_hit": local_hit
  }
}
```

### Required fields for good downstream value
At minimum, the host should provide:

- `surface_normalized_position`
- `surface_position`
- `world_position`
- `world_normal` when available
- `world_direction`
- `target_path` for the proof button

### Why this split is correct
This matches the contract docs exactly:

- `input-core` owns normalized interaction meaning
- the host repo still owns projected hit/surface data wiring

---

## Expected proof after adoption

After the coder integrates this correctly, the test scene should prove all of the following:

1. **The hybrid host still ray-picks and projects correctly**
   - world-space card remains interactable from the 3D scene

2. **Normalized events are flowing through `AeroUiInteractionBus`**
   - the proof can show `phase`, `source_variant`, `surface_id`, `verification_status`

3. **Downstream panel behavior is bus-driven**
   - the visual hover/press/drag/tap/toggle proof reacts from `AeroUiInteractable` / `AeroUiInteractionListener`, not `preview_button.gui_input`

4. **Host/local code only owns projection and routing glue**
   - no repo-local reimplementation of canonical event taxonomy in the panel source

5. **Truthful verification metadata remains intact**
   - mouse on `hybrid_3d_gui` should still initially show `prototype` unless local evidence is strong enough for a later explicit promotion
   - touch remains `unverified`
   - XR remains out of scope for this slice but structurally compatible

6. **The proof scene becomes a real downstream-adoption demo**
   - the panel should be able to report something like:
     - source: `screen_mouse`
     - phase: `press_begin` / `drag_move` / `press_end`
     - verification: `prototype`
     - target: preview button path

---

## Suggested coder execution order

1. Add `aerobeat-input-core` to `.testbed/addons.jsonc`
2. Restore/import `.testbed` dependencies
3. Add `AeroUiInteractionBus` and `HybridSubViewportInputAdapter` to `glass-shader-gui-3d-test.tscn`
4. Refactor `glass_shader_gui_3d_test.gd` so it publishes projected data into the adapter/bus
5. Resolve and publish a stable `target_path` for the proof card/button
6. Refactor `glass_shader_panel_source.gd` so the proof state is bus-driven through shared helpers
7. Update proof/debug text so it explicitly reports normalized contract fields
8. Validate that no repo-local panel logic still depends on raw input event class parsing as the source of truth

---

## Validation checklist for coder / QA / auditor

### Coder should be able to show

- `.testbed/addons.jsonc` contains `aerobeat-input-core`
- the scene instantiates/uses `AeroUiInteractionBus` and `HybridSubViewportInputAdapter`
- the host script publishes projected data rather than owning its own normalized semantics
- the panel proof script no longer uses raw `gui_input` parsing as the primary interaction contract

### QA should verify

- hover enter/move/exit readouts change from normalized phases
- press/hold/drag/release behavior updates the proof UI from contract events
- tap/toggle behavior works from shared helper semantics
- verification metadata shown in the proof matches the contract truth model
- off-surface release / hover exit behavior is truthful and stable

### Auditor should truth-check

- host math still lives locally
- downstream semantics now live on shared contract usage
- no hidden fallback is still making the proof depend on raw `Button` event internals as the main contract seam

---

## Bottom line

The cleanest adoption path is **not** to replace the world-hit math. It is to **move the semantic contract boundary upward**:

- keep local world-hit/projected-surface glue in `glass_shader_gui_3d_test.gd`
- add `AeroUiInteractionBus` + `HybridSubViewportInputAdapter` in the scene
- publish projected hit data into the shared adapter
- move the authored panel proof behavior in `glass_shader_panel_source.gd` onto `AeroUiInteractable` / `AeroUiInteractionListener`

That yields the exact split we want:

- `ui-kit-community` owns host integration truth
- `aerobeat-input-core` owns normalized UI interaction truth
- the hybrid test scene becomes a real downstream proof of the approved contract
