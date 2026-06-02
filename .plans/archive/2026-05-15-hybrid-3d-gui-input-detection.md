# AeroBeat UI Kit Community — Hybrid 3D GUI Input Detection

**Date:** 2026-05-15  
**Status:** Stale  
**Agent:** Byte 🐈‍⬛

---

## Goal

Add input-detection proof to the current hybrid 3D GUI test scene so we can demonstrate mouse and touch support with visible button states, then decide whether Godot already gives us a cross-compatible event path for mouse/touch/VR or whether AeroBeat needs a higher-level input contract in `aerobeat-input-core`.

---

## Overview

The immediate slice belongs in `aerobeat-ui-kit-community`, because that repo already owns the current hybrid world-space glass testbed scene and its shared 2D-authored panel source. The right first milestone is not a whole new architecture; it is a proof scene that makes input observable. That means extending the existing 3D GUI hybrid test panel with at least one clearly stateful button and lightweight instrumentation so we can verify hover, press, release, toggle/focus/disabled-or-selected behavior, and specifically whether the current world-space path receives mouse and touch interactions reliably.

Once that proof exists, we can answer the architectural question honestly instead of guessing. If Godot’s `Control` + viewport + event model already gives us a clean enough abstraction for mouse, touch, and XR pointer-style interaction, then we should document that and avoid inventing an unnecessary wrapper. If the current hybrid path exposes gaps — especially around forwarding events into the SubViewport/UI layer from different device classes — then the follow-up should be a high-level input contract in `aerobeat-input-core`, with the `ui-kit-community/.testbed` importing it through the existing GodotEnv-style dependency flow to prove singleton-based UI event passthrough.

This plan intentionally separates proof from platform architecture. First we make the test scene tell the truth. Then we decide whether `aerobeat-input-core` needs to exist as the compatibility layer for UI interaction, or whether Godot already gives us enough out of the box.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Current hybrid world-space 3D GUI test scene | `.testbed/scenes/glass-shader-gui-3d-test.tscn` |
| `REF-02` | Current hybrid world-space test controller script | `.testbed/scripts/glass_shader_gui_3d_test.gd` |
| `REF-03` | Shared 2D-authored panel source scene | `.testbed/scenes/glass-shader-panel-source.tscn` |
| `REF-04` | Shared 2D-authored panel source script | `.testbed/scripts/glass_shader_panel_source.gd` |
| `REF-05` | Existing hybrid-world-space parity plan/history | `.plans/2026-05-12-hybrid-world-space-glass-final-parity-push.md` |
| `REF-06` | Candidate follow-up repo for shared input contract | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-input-core` |

---

## Tasks

### Task 1: Audit the current hybrid scene’s input path and Godot’s built-in support

**Bead ID:** `aerobeat-ui-kit-community-4w8`  
**SubAgent:** `primary` (for `research` workflow role)  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-06`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, inspect the current hybrid 3D GUI test scene and determine how input reaches — or fails to reach — the authored `Control` UI mounted in the SubViewport path. Also check what Godot already provides for mouse, touch, and XR/VR-style UI interaction in this setup so we can avoid inventing an unnecessary abstraction. Report the concrete technical constraints, what works out of the box, and what does not.

**Folders Created/Deleted/Modified:**
- `.plans/` (notes/results only if needed)

**Files Created/Deleted/Modified:**
- optional investigation notes if needed

**Status:** ✅ Complete

**Results:** Research confirmed the current hybrid panel is render-correct but input-dead. The authored `Control` scene is mounted into `PanelViewport`/`MaskViewport`, but both SubViewports are explicitly configured with `gui_disable_input = true` and `handle_input_locally = false`, there is no 3D hit-to-viewport coordinate mapping, and the displayed panel meshes are not backed by a pickable collision surface. Godot does already provide the needed building blocks out of the box for this proof slice: `SubViewport` for GUI rendering, 3D pick events via `CollisionObject3D`/`Area3D`, and manual event injection through `Viewport.push_input()` for mouse/touch event types. The recommendation is to prove the path locally in this repo first: add a pickable panel surface, convert 3D hits to viewport coordinates, forward pointer/touch events into `panel_viewport`, and keep `mask_viewport` display-only. Research note written at `.temp/aerobeat-ui-kit-community-4w8-input-path-research.md`. No shared `aerobeat-input-core` contract is justified yet.

---

### Task 2: Add a visible input-proof panel state demo to the hybrid 3D GUI test scene

**Bead ID:** `aerobeat-ui-kit-community-vx1`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, extend the current hybrid 3D GUI testbed so the panel visibly proves input handling. Add at least one stateful button and any supporting labels/debug readouts needed to show hover/press/release/focus/toggle or equivalent state transitions clearly for mouse and touch testing. Keep the existing hybrid world-space architecture intact; this slice is about proving input behavior, not replacing the rendering pipeline.

**Folders Created/Deleted/Modified:**
- `.testbed/scenes/`
- `.testbed/scripts/`

**Files Created/Deleted/Modified:**
- `.testbed/scenes/glass-shader-panel-source.tscn`
- `.testbed/scripts/glass_shader_panel_source.gd`
- `.testbed/scenes/glass-shader-gui-3d-test.tscn`
- `.testbed/scripts/glass_shader_gui_3d_test.gd`

**Status:** ✅ Complete

**Results:** The input-proof implementation landed in commit `1315276` (`Add hybrid 3D GUI input proof`) and was pushed to `origin/main`. The hybrid scene now has a dedicated pickable `PanelInputSurface` aligned to the world-space card, and the test controller script now ray-picks against that surface, converts hit position to panel UV / `PanelViewport` coordinates, and forwards `InputEventMouseButton`, `InputEventMouseMotion`, `InputEventScreenTouch`, and `InputEventScreenDrag` into `panel_viewport` while leaving `mask_viewport` display-only. The authored 2D panel source was extended into a visible interaction proof: the card itself is now toggleable and exposes live readouts for source, pointer state, toggle state, and press/release/drag counts so mouse and touch behavior are obvious. Repo-local validation completed successfully with `godot --headless --path .testbed --editor --quit-after 1`, `godot --headless --path .testbed scenes/glass-shader-gui-3d-test.tscn --quit-after 1`, and `git diff --check`. Known QA risk: validation so far is headless only; live interactive verification is still required.

---

### Task 3: QA the hybrid input proof with mouse and touch paths

**Bead ID:** `aerobeat-ui-kit-community-wzt`  
**SubAgent:** `primary` (for `qa` workflow role)  
**Role:** `qa`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, run the hybrid 3D GUI test scene in Godot and verify the new input-proof UI behavior. Confirm what the button states do with mouse input and what works or fails with touch input. Capture enough evidence to tell whether the current setup truly supports both paths or needs additional forwarding/translation work.

**Folders Created/Deleted/Modified:**
- `.testbed/`
- `.temp/qa-evidence/` if useful

**Files Created/Deleted/Modified:**
- QA evidence artifacts if produced

**Status:** ⚠️ Partial

**Results:** QA completed a live host-side run of `.testbed/scenes/glass-shader-gui-3d-test.tscn` in Godot 4.6.2 and confirmed that the scene launches correctly, renders the new input-proof UI/readouts, and accepts live keyboard input in the running desktop session (verified by toggling auto-rotation with Space and observing the on-screen state change). Evidence was captured under `.temp/qa-evidence/`, including screenshots and QA notes at `.temp/qa-evidence/aerobeat-ui-kit-community-wzt-qa-notes.md`. However, QA could not honestly certify mouse hover/press/drag forwarding or native touch behavior: the available remote click path on this GNOME Wayland host produced no visible state changes despite repeated attempts, and no touch-capable paired device was available for real touch validation. So this slice is partially validated: live scene + instrumentation are real, but end-to-end pointer/touch truth still needs direct human interaction or a more trustworthy pointer/touch automation path.

---

### Task 4: Audit the result and decide whether `aerobeat-input-core` needs a shared contract

**Bead ID:** `aerobeat-ui-kit-community-7du`  
**SubAgent:** `primary` (for `auditor` workflow role)  
**Role:** `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-06`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, audit the finished input-proof scene and the research findings. Decide whether Godot already provides a sufficient cross-compatible path for mouse/touch/XR-oriented UI input in this hybrid world-space setup, or whether AeroBeat should define a higher-level input contract in `aerobeat-input-core`. If a shared contract is needed, outline the minimum responsibilities that contract should own.

**Folders Created/Deleted/Modified:**
- `.plans/` (notes/results only if needed)

**Files Created/Deleted/Modified:**
- optional audit notes if needed

**Status:** ✅ Complete

**Results:** Audit concluded this slice is **⚠️ partial, but not blocked**. The implementation credibly established the missing architecture/prototype path for hybrid 3D GUI input: the scene now has a pickable panel surface, world-hit → UV → `PanelViewport` mapping, forwarding for mouse and touch event classes, and visible instrumentation/readouts on the authored card. Research and code review agree the original input-dead gap was addressed without breaking the hybrid render architecture, and QA plus independent validation confirm the scene launches and runs live. However, the audit explicitly rejected any stronger claim than that: end-to-end live mouse hover/press/release/drag forwarding and real native touch behavior are **not yet proven in practice** because trustworthy pointer/touch QA could not be completed on this host. The minimum required next step is one trustworthy live interaction validation with a real mouse and a real touch-capable path to determine whether forwarded native touch is sufficient or whether `aerobeat-input-core` should normalize toward a device-agnostic UI pointer intent. This is enough to proceed with contract design exploration, but not enough to freeze final cross-device semantics yet.

---

## Final Results

**Status:** ⏳ Pending

**What We Built:** Pending execution.

**Reference Check:** Pending execution.

**Commits:**
- Pending

**Lessons Learned:** Pending execution.

---

*Drafted on 2026-05-15*