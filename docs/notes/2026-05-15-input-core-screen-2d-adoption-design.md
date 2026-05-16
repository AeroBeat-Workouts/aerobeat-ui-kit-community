# `aerobeat-input-core` adoption design for screen-space 2D UI testbed

**Date:** 2026-05-15  
**Repo:** `aerobeat-ui-kit-community`  
**Scope:** design only, no implementation  
**Primary target:** `.testbed/scenes/glass-shader-test.tscn` + `.testbed/scripts/glass_shader_test.gd`

---

## Goal

Prove that the approved `aerobeat-input-core` contract cleanly works in a plain screen-space 2D slice inside this repo’s hidden `.testbed`, using the same downstream consumer pattern already adopted by the hybrid path but without any world-hit or `SubViewport` projection complexity.

This should become the simple baseline counterpart to the existing hybrid proof:

- hybrid slice proves the contract can sit behind world-space projection glue
- screen-space 2D slice proves the same contract is still clean when that glue disappears

---

## Best candidate 2D surface

Use the existing screen-space host scene:

- `.testbed/scenes/glass-shader-test.tscn`
- `.testbed/scripts/glass_shader_test.gd`

and keep the visible interactive surface as the existing authored panel scene already mounted there:

- `.testbed/scenes/glass-shader-panel-source.tscn`
- `.testbed/scripts/glass_shader_panel_source.gd`

### Why this is the right slice

This is the cleanest candidate because it already gives us exactly what we want for a baseline proof:

1. **It is plain screen-space 2D already.**
   - root is `Control`
   - the visible panel is mounted directly into `PanelSourceHost`
   - there is no 3D raycast math, no `Area3D`, no `SubViewport` projection, and no hybrid continuity policy to untangle

2. **It already reuses the same authored panel source as the hybrid scene.**
   - that makes the proof stronger than inventing a new 2D demo
   - the same panel consumer code can be shown working in both hybrid and screen-space contexts

3. **It is the natural baseline counterpart to `glass-shader-gui-3d-test.tscn`.**
   - same repo
   - same visible card
   - same debug-minded testbed structure
   - simpler host integration

4. **It keeps the comparison honest.**
   - hybrid host owns ray picking + projection
   - screen host should only own local screen-space routing + minimal capture continuity
   - downstream UI should look nearly identical from the contract consumer side

---

## Clean adoption shape

## Recommendation in one sentence

Adopt `AeroUiInteractionBus` + `ScreenUiInputAdapter` into `glass-shader-test.tscn`, let `glass_shader_test.gd` do only minimal screen-space routing/capture for the single proof card, and keep the actual visible card behavior driven by `AeroUiInteractable` / `AeroUiInteractionListener` inside `glass_shader_panel_source.gd`.

---

## Responsibility split

### What should stay local to the 2D host scene

The 2D host still owns a small amount of repo-local glue, but much less than hybrid:

1. **Mounting the shared panel source scene**
2. **Creating / wiring the local bus and screen adapter**
3. **Resolving the proof target path for the single card**
   - the current proof target is still the main `PreviewButton`
4. **Minimal capture continuity for press-drag-release outside the card bounds**
   - only enough to finish a started interaction cleanly
5. **Optional host-level status text summarizing the last normalized event**

### What should move to the shared contract path

These should be demonstrated as `input-core` usage, not repo-local raw input logic:

1. **Canonical phases**
   - `hover_enter`
   - `hover_move`
   - `hover_exit`
   - `press_begin`
   - `press_hold`
   - `drag_begin`
   - `drag_move`
   - `drag_end`
   - `press_end`

2. **Source / surface taxonomy**
   - `screen_mouse`
   - `screen_touch`
   - `screen_2d`

3. **Verification metadata**
   - `screen_mouse` + `screen_2d` should remain truthfully `prototype`
   - `screen_touch` + `screen_2d` should remain `unverified`

4. **Visible card reaction logic**
   - hover accent
   - pressed state
   - drag state
   - tapped toggle
   - debug labels

5. **Tap derivation ergonomics**
   - use `AeroUiInteractionListener.tapped` and/or `AeroUiInteractable.tapped`
   - do not treat raw `Button` signals as the proof contract

---

## File-level design

## 1. `.testbed/scenes/glass-shader-test.tscn`

### Change
Add scene-local contract nodes for the 2D host.

### Recommended nodes
Under `PanelSourceHost` or directly under the scene root, add:

- `AeroUiInteractionBus`
- `ScreenUiInputAdapter`

### Preferred placement
Put both under `PanelSourceHost` so the adapter’s parent `Control` is the same screen-space surface that already hosts the mounted panel source.

Conceptual tree:

- `GlassShaderTest`
  - `SplitRoot`
    - `ControlsPanel`
    - `PreviewArea`
      - `PreviewCenter`
        - `PanelSourceHost`
          - `AeroUiInteractionBus`
          - `ScreenUiInputAdapter`
          - mounted `GlassShaderPanelSource`

### Suggested adapter config
- `bus_path` -> `../AeroUiInteractionBus`
- `surface_id` -> stable new screen ID such as `screen_glass_panel`
- `surface_type` -> `screen_2d`
- `drag_threshold_pixels` -> `12.0` to match current contract defaults and hybrid proof feel

### Optional scene tweak
Add a small status/readout block to the left controls column if coder wants a host-level mirror of the current hybrid proof. This is optional but recommended because it makes side-by-side comparison easier.

---

## 2. `.testbed/scripts/glass_shader_test.gd`

### Change
Turn this file from “2D shader controls host” into “2D shader controls host plus screen-contract publisher”.

### Keep
Keep all of its existing responsibilities:

- mounting `glass-shader-panel-source.tscn`
- background/shader controls
- preset import/export

### Add
Add the smallest possible interaction-core host glue:

1. resolve the local bus + screen adapter
2. after mounting the panel source, inject the runtime bus path into that source scene
3. resolve the proof target path (`PreviewCenter/PreviewStack/PreviewButton` inside the mounted panel source)
4. route relevant input events into `ScreenUiInputAdapter.publish_input_event(...)`
5. optionally maintain very small local continuity state for:
   - active mouse press started on card
   - active touch contacts started on card
   - off-card release after card-origin press

### Important design choice
**Do not rely on `ScreenUiInputAdapter._input()` as the whole proof by itself.**

For this slice, the cleaner proof is for the host script to publish explicitly with a known `target_path`, because:

- the current `PreviewButton` is intentionally visually authored, not a trustworthy native-input proof target
- we want the host to state clearly which contract target is under test
- we want to avoid silently falling back to native Godot hovered-control behavior as the hidden source of truth

### Recommended publish pattern
For supported events:

- `InputEventMouseButton`
- `InputEventMouseMotion`
- `InputEventScreenTouch`
- `InputEventScreenDrag`

`glass_shader_test.gd` should:

1. determine whether the interaction is inside the proof card, or is a continuation of a capture that started there
2. call `screen_input_adapter.publish_input_event(event, preview_button_path, metadata)`
3. update an optional host readout from bus events, not from raw input events

### Minimal routing rule
Keep the routing rule deliberately simple:

- single target only: `PreviewButton`
- if pointer/touch starts inside the card, that interaction belongs to the proof target
- once started, allow release/drag completion even if pointer moves a bit outside
- do not add multi-target arbitration here

That gives us the same “host owns routing glue, contract owns semantics” split as hybrid, but in a much smaller form.

---

## 3. `.testbed/scripts/glass_shader_panel_source.gd`

### Change
Generalize the already-working contract-driven consumer logic so it can be reused by both the hybrid and screen-space hosts without pretending the surface is always hybrid.

### Current state
This file is already most of the way there because it now uses:

- `AeroUiInteractable`
- `AeroUiInteractionListener`
- `AeroUiInteractionEvent`

for visible state changes.

That is exactly the consumer-side shape we want to preserve.

### What should change
Replace the hybrid-specific assumptions with configurable screen/hybrid contract configuration.

Recommended additions:

- configurable interaction bus path
- configurable `surface_id_filter`
- configurable proof mode / presentation copy
- optional configurable proof summary strings for screen vs hybrid text

### Practical result
The same panel source scene should be able to behave like this:

- in `glass-shader-gui-3d-test.tscn`
  - bus path resolves to hybrid scene bus
  - `surface_id_filter = hybrid_glass_panel`
  - copy references world-hit projection / `HybridSubViewportInputAdapter`

- in `glass-shader-test.tscn`
  - bus path resolves to local 2D scene bus
  - `surface_id_filter = screen_glass_panel`
  - copy references direct screen-space routing / `ScreenUiInputAdapter`

### Keep as contract-driven
The visible proof should still be driven by:

- `hovered_changed`
- `pressed_changed`
- `dragging_changed`
- `interaction_event`
- `tapped`

and not revert to:

- `gui_input`
- `mouse_entered`
- `mouse_exited`
- `button_down`
- `button_up`
- native `Button` toggle semantics as the primary truth

---

## 4. Optional new local helper script

A new helper is optional, not required.

If readability starts to slip in `glass_shader_test.gd`, the best candidate helper would be something tiny like:

- `.testbed/scripts/screen_ui_contract_route.gd`

responsible only for:

- resolving whether a screen event belongs to the proof card
- remembering capture continuity for mouse/touch
- returning `target_path` + route metadata

But the cleaner first pass is probably to keep this logic in `glass_shader_test.gd` unless the diff gets noisy.

---

## Visible proof behavior

The proof should be obvious and human-visible without inspecting code.

### What the user should see

Inside the mounted glass card:

1. **Hover**
   - moving onto the card changes the card accent state
   - in-card labels show `hover_enter` / `hover_move`

2. **Press / hold**
   - pressing changes the card to pressed styling
   - labels show `press_begin`, then `press_hold` if the pointer stays down and moves lightly

3. **Drag**
   - exceeding threshold produces `drag_begin` then `drag_move`
   - drag count/debug text increments from normalized contract events

4. **Release / tap**
   - release shows `press_end`
   - non-drag release triggers `tapped`
   - the card toggles ON/OFF and updates its labels from the listener/interactable path

5. **Verification truth**
   - readout shows:
     - source variant: `screen_mouse`
     - surface type/id: `screen_2d` / `screen_glass_panel`
     - verification: `prototype`
   - touch path, if exercised, should still show `unverified`

### Host-side readout (recommended)

A small host status block should also show the latest normalized event so the difference is unmistakable:

- target path
- phase
- source variant
- verification status
- a short sentence like:
  - “This screen-space proof publishes through `ScreenUiInputAdapter`; the card reacts through `AeroUiInteractable` / `AeroUiInteractionListener`.”

---

## What this slice must prove

This 2D pass is successful if it clearly proves all of the following:

1. **The same downstream consumer pattern works outside the hybrid path.**
   - the card reacts through `AeroUiInteractable` / `AeroUiInteractionListener`
   - the consumer side does not care whether the host is hybrid or screen-space

2. **The host/consumer seam is cleaner in 2D.**
   - no 3D math
   - no projection dictionaries
   - same normalized contract downstream

3. **Contract reuse is real, not hybrid-only coincidence.**
   - same panel source can be mounted in both scenes
   - only host integration details change

4. **The proof is still truthful about verification.**
   - `screen_mouse` + `screen_2d` should remain `prototype` unless later QA explicitly upgrades it
   - touch remains `unverified`

5. **The repo is ready for a later hybrid stress pass.**
   - after this slice, the remaining open questions are mostly about multi-target routing and hybrid complexity, not whether the contract can handle a simple non-hybrid consumer

---

## What should stay deliberately simple here

Do not turn this slice into the later stress test.

### Keep in scope
- one screen-space surface
- one visible primary target (the preview card)
- mouse-first proof
- optional touch passthrough only as a truthful unverified path
- minimal capture continuity
- explicit target-path routing for the single card

### Defer to the later multi-target hybrid pass
- multiple simultaneous interactive targets
- target arbitration between overlapping controls
- hover transitions across multiple contract targets
- hybrid/world-space multi-surface routing
- XR-specific validation
- verification promotion decisions beyond what QA can honestly prove here
- generalized reusable target-resolution frameworks

---

## Suggested coder execution order

1. Add `AeroUiInteractionBus` and `ScreenUiInputAdapter` to `glass-shader-test.tscn`
2. Extend `glass_shader_test.gd` to resolve those nodes and subscribe to bus events
3. After mounting the panel source, inject the runtime bus path and screen surface filter/config into it
4. Route mouse/touch input explicitly into `ScreenUiInputAdapter.publish_input_event(...)` with the `PreviewButton` target path
5. Add minimal capture continuity only for interactions that begin on the card
6. Generalize `glass_shader_panel_source.gd` labels/copy so the same contract-driven panel works in both screen and hybrid scenes
7. Add or update host readout text so it explicitly says the visible card is reacting from normalized contract events
8. Validate that no raw `gui_input`-driven fallback is secretly the source of truth

---

## Validation checklist for coder / QA / auditor

### Coder should be able to show

- `glass-shader-test.tscn` contains `AeroUiInteractionBus` + `ScreenUiInputAdapter`
- `glass_shader_test.gd` explicitly publishes screen events to the adapter with a stable proof target path
- `glass_shader_panel_source.gd` consumes the bus through `AeroUiInteractable` / `AeroUiInteractionListener`
- visible toggle/hover/drag state comes from normalized events, not raw `Button` input parsing

### QA should verify

- hover enter/move/exit visibly works in the 2D screen host
- press/hold/drag/release phases update the readout correctly
- tap toggles the card from `tapped`, not native button semantics
- screen host and in-card readouts agree on source/phase/verification
- moving off the card after press still ends truthfully if continuity is intentionally supported
- touch, if tested, stays labeled `unverified`

### Auditor should truth-check

- the candidate surface really is the plain screen-space counterpart, not a disguised hybrid path
- host logic is smaller and simpler than hybrid for the right reasons
- the shared panel consumer code is actually reused
- no hidden raw-input dependency remains as the real contract seam

---

## Bottom line

The cleanest screen-space 2D adoption slice is to use the **existing `glass-shader-test.tscn` host** and the **existing `glass-shader-panel-source.tscn` card** as the proof surface.

That gives us the exact contrast we want:

- **hybrid host:** local raycast/projection glue + shared contract consumers
- **screen host:** minimal local screen routing glue + the same shared contract consumers

If this is implemented cleanly, the repo will then have two complementary proofs:

1. a more complex hybrid world-space proof
2. a simpler screen-space baseline proof

At that point, the next meaningful contract-hardening step is no longer “does this abstraction only work in one weird scene?” but “how well does it hold up when hybrid routing gets multi-target and more adversarial?”
