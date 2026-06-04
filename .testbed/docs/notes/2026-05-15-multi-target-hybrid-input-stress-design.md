# Multi-target hybrid input stress design

**Date:** 2026-05-15  
**Repo:** `aerobeat-ui-kit-community`  
**Scope:** design only, no implementation  
**Primary targets:**
- `.testbed/scenes/glass-shader-gui-3d-test.tscn`
- `.testbed/scripts/glass_shader_gui_3d_test.gd`
- `.testbed/scenes/glass-shader-panel-source.tscn`
- `.testbed/scripts/glass_shader_panel_source.gd`

---

## Goal

Expand the current hybrid single-target proof into a small but adversarial **multi-target** hybrid world-space slice that pressure-tests the existing `aerobeat-input-core` contract seam without redesigning it.

The point is not to make the panel more feature-rich. The point is to force the current host/consumer split to survive:

- multiple distinct target paths on one hybrid surface
- hover movement between targets
- press/drag continuity that begins on one target and moves across others
- release behavior when pointer ownership and hover ownership differ

If this slice works cleanly, the next uncertainty is no longer “can the contract work in hybrid?” but “how far can we push hybrid routing complexity before we need a new abstraction?”

---

## References consulted

- `.plans/2026-05-15-multi-target-hybrid-input-stress.md`
- `.plans/2026-05-15-input-core-adoption-for-hybrid-ui.md`
- `.plans/2026-05-15-input-core-adoption-for-screen-2d-ui.md`
- `docs/notes/2026-05-15-input-core-hybrid-adoption-design.md`
- `docs/notes/2026-05-15-input-core-screen-2d-adoption-design.md`
- `.testbed/scenes/glass-shader-gui-3d-test.tscn`
- `.testbed/scripts/glass_shader_gui_3d_test.gd`
- `.testbed/scenes/glass-shader-panel-source.tscn`
- `.testbed/scripts/glass_shader_panel_source.gd`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-input-core/docs/ui-interaction-contract-v1.md`

---

## What the current proof already proves

The current hybrid scene already has the right seam shape:

- `glass_shader_gui_3d_test.gd` owns world hit detection, UV projection, hover/capture continuity, and projected publish calls into `HybridSubViewportInputAdapter`
- `glass_shader_panel_source.gd` consumes normalized events through `AeroUiInteractable` and `AeroUiInteractionListener`
- the host currently hard-resolves a single `target_path` to `PreviewButton`
- the panel proof currently treats the whole card as one interactive ownership region

That means the honest next test is not another contract rewrite. It is to keep the seam exactly where it is and increase **target routing pressure**.

---

## Design principle for this slice

Keep the scene to **one hybrid surface** and **one interaction bus/adapter pair**, but add **multiple sibling interactive targets inside the same mounted panel source**.

That is the cleanest stress slice because it isolates one new variable:

- before: one host surface -> one contract target
- after: one host surface -> several contract targets

This avoids conflating routing questions with:

- multiple surfaces
- multiple buses
- overlapping world objects
- multi-touch gestures
- XR-specific semantics

---

## Recommended target set

Use **three explicit targets** inside the existing panel source, each with a different interaction role.

### 1. Primary card button

**Node role:** existing center card, evolved from the current `PreviewButton`  
**Suggested path:** `PreviewCenter/PreviewStack/PrimaryCardButton`

Purpose:
- preserve parity with the current proof
- remain the large “main target” that is easy to hit from the 3D scene
- continue to show canonical hover/press/tap behavior

What it proves:
- the old single-target proof still works after multi-target routing is introduced
- larger targets do not hide bugs in smaller neighbors

### 2. Secondary toggle chip

**Node role:** a smaller sibling target near the badge/title area  
**Suggested path:** `PreviewCenter/PreviewStack/SecondaryToggleChip`

Purpose:
- provide a distinctly smaller target on the same surface
- exercise hover transitions from the large card into a separate sibling target
- prove the host is not just publishing the whole surface as the same path every time

Recommended behavior:
- tap toggles a local ON/OFF state
- hover highlights independently of the main card
- labels should clearly say which target currently owns hover and which target last toggled

What it proves:
- target-path routing is truly target-specific
- tiny/secondary targets can receive honest hover and tap traffic through the same hybrid seam

### 3. Drag strip / scrub lane

**Node role:** a horizontal control near the lower part of the panel  
**Suggested path:** `PreviewCenter/PreviewStack/DragStrip`

Purpose:
- provide a target whose main job is drag continuity rather than tap
- make drag begin / drag move / drag end visible and easy to distinguish from button semantics
- provide a clean place to observe what happens when drag crosses onto or away from neighboring targets

Recommended behavior:
- press begins ownership on the strip
- drag updates a fill/percent/handle readout
- release ends drag without also toggling neighboring tap targets

What it proves:
- drag ownership can remain anchored to the originating target even when hover visually moves elsewhere
- the host can preserve continuation without reassigning target ownership mid-gesture

---

## Layout recommendation

Keep the scene visually simple and asymmetric enough that target transitions are obvious.

Recommended structure inside `PreviewStack`:

- top-left or top-center: `SecondaryToggleChip`
- center: `PrimaryCardButton`
- bottom section: `DragStrip`
- right-side or lower debug readout: shared status labels showing
  - current hovered target
  - active pressed/drag owner target
  - last released target
  - last phase
  - source variant
  - verification status

Important: these should be **siblings**, not nested interactive children inside the main card target. This keeps routing honest and avoids ambiguous “did the parent receive this or the child?” confusion in the first stress slice.

---

## Target-path routing policy

## Core recommendation

The host should resolve **one concrete `target_path` per projected event** based on projected surface position, but should also preserve **captured target ownership** once a press begins.

That gives two different concepts which this slice must intentionally distinguish:

- **hover target**: what the pointer is currently over
- **capture/press owner target**: what began the active press/drag interaction

That distinction is the whole point of the slice.

### Routing states the host should own

The host script should keep local routing state for:

- current hover target path
- active mouse press owner target path
- active touch press owner target path(s)
- last projected coordinates for off-surface continuation

This is still host-local responsibility. It should not move into `input-core`.

### How to resolve the hover target

For this slice, do **local screen-space panel hit routing inside the mounted panel source bounds** after UV -> viewport mapping.

Recommended approach:
1. keep the existing world ray -> UV -> viewport projection exactly as-is
2. once a valid projected `surface_position` exists, determine which authored target rect contains that point
3. resolve that authored target to its concrete `NodePath`
4. publish that `target_path` into the projected data

This is cleaner than trying to ask the input-core layer to discover target ownership. The contract doc already makes the host responsible for projected target data in hybrid mode.

### How to resolve target ownership during press/drag

When a press begins on a target:
- store that target as the active owner for that pointer
- continue publishing that same `target_path` for subsequent drag/hold/release on that pointer
- do **not** retarget the press to a sibling just because the pointer moved across it

That keeps target ownership stable and is the most important routing rule to validate.

### Hover vs capture split

During an active drag that began on `DragStrip`, if the pointer moves over `SecondaryToggleChip`:
- hover reporting may truthfully show the pointer is now over the chip
- but the drag/pointer ownership should remain on `DragStrip`
- release should complete against `DragStrip`, not accidentally tap the chip

This is the most valuable adversarial case in the slice.

---

## Recommended host-side routing helper

Add a small local helper in the hybrid host script, not a new shared contract abstraction.

Conceptually, the host needs a helper that does:

- map projected panel-space position to one of a few known target rects
- return the winning `NodePath` or empty path
- keep capture owner paths per pointer

This can live either:
- directly inside `glass_shader_gui_3d_test.gd`, or
- in a tiny local helper script if readability suffers

Do **not** generalize this into a reusable framework yet. The current objective is to stress the seam, not to commit to a library-level routing system.

---

## Hover transitions this slice should demonstrate

The proof should explicitly demonstrate these hover cases:

### Case A: surface enter into primary target
- pointer comes from off-panel onto `PrimaryCardButton`
- expect `hover_enter` on primary target
- visual readout updates hovered target path to primary

### Case B: primary target to empty panel region
- pointer leaves `PrimaryCardButton` but stays on the world panel in non-interactive space
- expect hover exit for primary target
- no sibling target should receive a fake hover enter
- host readout should show surface still hit, but hovered target becomes empty/none

### Case C: primary target to chip target
- pointer moves directly from primary into `SecondaryToggleChip`
- expect old target hover exit + new target hover enter sequence
- host and in-panel readouts should show target change cleanly

### Case D: chip target to drag strip
- pointer moves from chip into drag strip before press
- expect hover ownership to move to drag strip
- no press counts should change

### Case E: panel exit from any hovered target
- pointer leaves the world panel entirely while not captured
- expect hover exit for the current hovered target
- host hover state should clear

These cases prove target routing quality even before press/drag complexity starts.

---

## Press / drag / release cases this slice should demonstrate

### Case 1: simple tap on primary card
- hover primary
- `press_begin` on primary
- small movement stays `press_hold`
- release yields `press_end`
- listener-derived `tapped` toggles only primary state

Purpose:
- confirm existing proof behavior still survives the new multi-target host routing path

### Case 2: simple tap on secondary chip
- hover chip
- `press_begin` / `press_end`
- tap toggles only chip state
- primary card state must remain unchanged

Purpose:
- prove the host is not publishing every event to the old primary path by habit

### Case 3: drag born on drag strip, move across primary, release over primary
- begin press on `DragStrip`
- exceed threshold -> `drag_begin`
- move over `PrimaryCardButton`
- keep ownership on `DragStrip`
- release over primary should yield `drag_end` / `press_end` on strip owner only
- primary must not toggle from the release

Purpose:
- the most important capture-continuity test in the slice

### Case 4: press on primary, move onto chip without crossing drag threshold, release on chip
- press begins on primary
- hover may move to chip if the host chooses to report live hover during capture
- release should still complete against primary owner
- chip must not tap on release

Purpose:
- prove release ownership is tied to press origin, not release location

### Case 5: press on chip, leave panel, release off-surface
- begin on chip
- move off the world panel entirely
- release off-surface while still captured
- host should publish continuation using last projected data and end the chip-owned interaction truthfully

Purpose:
- validate current off-surface continuation policy still works when multiple targets exist

### Case 6: drag strip hover transition without ownership transfer
- hover strip
- begin press and drag
- move over empty space and sibling targets
- observe that drag visualization stays attached to strip owner
- hover readout may change, but active owner readout should not

Purpose:
- clearly separate hover truth from gesture ownership truth

---

## What the host should keep owning locally

These responsibilities should remain in `glass_shader_gui_3d_test.gd`:

1. **World hit acquisition**
   - ray cast against `PanelInputSurface`

2. **Projection math**
   - world hit -> local hit -> UV -> `surface_position`

3. **Per-pointer continuity policy**
   - off-surface release continuation
   - last projected data reuse
   - hover enter/exit decisions on world hit loss

4. **Target-path resolution**
   - projected surface position -> target rect/path lookup

5. **Target ownership capture**
   - store the owner path for active mouse/touch presses
   - preserve owner path for drag/release

6. **Host-level debug readout**
   - current hovered target
   - active owner target
   - last published path
   - surface hit status

This is all consistent with the current contract and should not be pushed down into `input-core`.

---

## What should remain unchanged on the shared consumer side

The consumer-side pattern in `glass_shader_panel_source.gd` should stay structurally the same:

- keep using `AeroUiInteractable`
- keep using `AeroUiInteractionListener`
- keep filtering via `surface_id_filter` + `target_path_filter`
- keep visible proof behavior driven by normalized events
- keep `tapped` as helper-derived ergonomics rather than introducing a core `tap` phase

The main change should be **multiplicity**, not architecture.

### Recommended consumer shape

Instead of one interactable/listener pair for one `PreviewButton`, create one pair per target:

- primary target consumers
- chip target consumers
- drag strip consumers

Each target should:
- subscribe to the same bus
- filter to its own `target_path`
- update only its own visual state and local counters

A shared panel-level debug summary can listen broadly and render:
- last event target path
- currently hovered target label
- currently active owner label
- per-target tap/drag counts

That is still the same contract pattern, just repeated across multiple sibling consumers.

---

## Concrete scene/script changes

## `glass-shader-panel-source.tscn`

Recommended authored changes:

- rename current `PreviewButton` to `PrimaryCardButton` for clarity
- add `SecondaryToggleChip` as a sibling interactive control
- add `DragStrip` as a sibling interactive control
- add or expand debug labels so the panel shows:
  - hovered target label
  - active owner label
  - primary tap state/count
  - chip tap state/count
  - drag strip percent/count

Important:
- keep the target controls as visible authored controls
- keep them as non-overlapping siblings for this first stress pass
- avoid nesting the chip or strip inside the primary target’s ownership region if possible

## `glass-shader-panel_source.gd`

Recommended script changes:

- split the current single-target state into per-target state buckets
- instantiate one `AeroUiInteractable` + one `AeroUiInteractionListener` per target
- filter each pair to its target path
- maintain a small panel-level summary readout fed by the same normalized event stream
- keep the current hybrid/screen configurability intact

Recommended local presentation behavior:
- `PrimaryCardButton`: hover/press/tap accent + toggle count
- `SecondaryToggleChip`: compact hover/press accent + own toggle count
- `DragStrip`: drag fill or progress percentage + drag count

## `glass-shader-gui-3d-test.gd`

Recommended host changes:

- replace `_resolve_panel_target_path()` with a projected target resolver that can return one of several paths
- add mouse/touch owner-path tracking, not just capture booleans
- continue to publish through `HybridSubViewportInputAdapter`
- keep hover-enter/hover-exit explicit in the host
- augment host status panel with:
  - `hover_target_path`
  - `active_owner_target_path`
  - `last_release_target_path`
  - whether current publish is live hover or captured continuation

Important implementation policy:
- once capture starts, override subsequent projected `target_path` with the owner path for press/drag/release publishing
- do not silently transfer drag ownership to a sibling target mid-gesture

---

## What should stay intentionally out of scope

To keep this slice focused, do **not** add any of the following yet:

1. **Multiple hybrid surfaces**
   - one panel is enough

2. **Overlapping target arbitration**
   - keep target rects non-overlapping in this pass

3. **General reusable target-resolution framework**
   - local helper only

4. **Keyboard/gamepad navigation**
   - unrelated seam

5. **Gesture recognition beyond basic drag**
   - no pinch, rotate, multitouch gesture semantics

6. **Verification promotion**
   - still keep `screen_mouse + hybrid_3d_gui` at `prototype`
   - keep touch at `unverified`

7. **XR path work**
   - out of scope

8. **Nested bubbling/capture semantics between parent and child controls**
   - use sibling targets to avoid conflating problems

9. **Concurrent multi-touch ownership stress**
   - single active mouse plus simple touch parity is enough for now

This slice should answer exactly one question well: **does the existing contract seam remain clean under multi-target hybrid routing pressure?**

---

## Success criteria

This slice is successful if all of the following are true:

1. one hybrid world surface can route to multiple distinct target paths without changing the contract
2. hover target transitions are visible and truthful
3. press/drag/release ownership remains stable to the originating target
4. release over a different sibling does not incorrectly tap that sibling
5. host responsibilities remain projection/routing/continuity only
6. shared consumer-side behavior remains normal `AeroUiInteractable` / `AeroUiInteractionListener` usage
7. the proof gives coder/QA/auditor a readable way to distinguish hover truth from capture ownership truth

---

## Coder-ready implementation summary

Implement the hybrid stress slice as **one world-space panel with three sibling interactive targets**:

- `PrimaryCardButton` for the existing large tap target
- `SecondaryToggleChip` for a smaller independent tap target
- `DragStrip` for drag ownership testing

Keep all world hit math, UV projection, target rect lookup, and capture ownership in `glass_shader_gui_3d_test.gd`. Replace the single hardcoded `PreviewButton` path with target resolution that returns one of the three target paths based on projected panel coordinates, but once a press begins, lock ownership to that target for drag/release publishing.

On the panel source side, keep the same contract-driven consumer pattern, but create per-target listeners/interactables so each target reacts only to its own filtered `target_path`. Add panel and host readouts that show hovered target, active owner target, last phase, and per-target counts.

The key proof cases to validate are:
- hover transitions between targets
- tap primary without affecting chip
- tap chip without affecting primary
- drag born on strip across other targets without ownership transfer
- release over a different sibling without accidental tap transfer
- off-surface release continuation finishing on the original owner

Do not broaden scope into multiple surfaces, overlapping targets, gesture systems, or contract redesign.