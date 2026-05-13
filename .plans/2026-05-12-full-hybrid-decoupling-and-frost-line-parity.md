# AeroBeat UI Kit Community — Full Hybrid Decoupling and Frost/Line Parity

**Date:** 2026-05-12  
**Status:** Draft  
**Agent:** Byte 🐈‍⬛

---

## Goal

Finish full default-ownership decoupling for the hybrid world-space path, then investigate why the 3D shader still cannot reproduce the 2D frosted-glass body, sharp outer rim, and crisp interior edge line even after value tuning.

---

## Overview

The previous decoupling pass removed the hidden 2D-source-to-hybrid startup override, which made the hybrid material’s defaults truly come from `glass_shader_gui_3d_test.gd`. QA confirmed that part worked, but also surfaced a remaining startup-time coupling from the hybrid scene back into the mask-side source instance for shell/shape-alignment parameters like `corner_radius`, `edge_smoothness`, `edge_width`, `tint`, and `edge_highlight`. Derrick now wants the hybrid 3D shader to be fully decoupled, so this pass should make the ownership model completely explicit and remove any remaining ambiguous startup inheritance.

Derrick also provided a direct visual comparison screenshot showing the 2D reference on the left and the closest current 3D result on the right. That human comparison sharpens the remaining parity problem a lot. The issue is not just “it’s still somewhat off.” It is specifically that the frosted-glass body does not behave like the 2D shader, the outer rim cannot reach the same sharp bright white read, and the interior edge line is too fuzzy to match the 2D card. Those are strong clues that the current 3D material is not merely under-tuned; it may be using the wrong layering or edge-generation model for the body/rim/inner-line treatment.

This pass should therefore do two things in order. First, finish the full decoupling cleanly so ownership is obvious and tuning the hybrid path is no longer fighting hidden coupling. Second, investigate the frost/rim/inner-line mismatch using Derrick’s screenshot as a truth source and determine whether the current hybrid shader needs a revised face/rim/inner-border composition model rather than more scalar tweaking.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Hybrid scene controller script | `.testbed/scripts/glass_shader_gui_3d_test.gd` |
| `REF-02` | Shared 2D source script | `.testbed/scripts/glass_shader_panel_source.gd` |
| `REF-03` | Hybrid world-space scene | `.testbed/scenes/glass-shader-gui-3d-test.tscn` |
| `REF-04` | 2D reference scene | `.testbed/scenes/glass-shader-test.tscn` |
| `REF-05` | Current hybrid body shader | `.testbed/assets/shaders/glass-panel-hybrid-3d.gdshader` |
| `REF-06` | Current hybrid UI overlay shader | `.testbed/assets/shaders/glass-panel-ui-overlay-3d.gdshader` |
| `REF-07` | Prior decoupling plan/results | `.plans/2026-05-12-decouple-2d-and-hybrid-defaults.md` |
| `REF-08` | User screenshot showing 2D vs current 3D comparison | `/home/derrick/.openclaw/workspace/.temp/nerve-uploads/2026/05/13/image-073fa4ac.png` |

---

## Tasks

### Task 1: Investigate remaining hybrid→mask coupling and frost/rim/inner-line mismatch

**Bead ID:** `aerobeat-ui-kit-community-71l`  
**SubAgent:** `primary` (for `research` workflow role)  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`, `REF-06`, `REF-07`, `REF-08`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, inspect the remaining hybrid→mask startup coupling and Derrick’s 2D-vs-3D screenshot. Determine the cleanest way to fully decouple hybrid default ownership, then diagnose why the current 3D shader still cannot reproduce the 2D frosted body, sharp white outer rim, and crisp interior edge line. Be explicit if the current body/rim/inner-line composition model itself needs to change rather than just more tuning.

**Folders Created/Deleted/Modified:**
- `.plans/` (notes/results only if needed)

**Files Created/Deleted/Modified:**
- optional investigation notes if needed

**Status:** ✅ Complete

**Results:** Research found that the remaining coupling is hybrid→mask startup mirroring in `glass_shader_gui_3d_test.gd`: `set_panel_shader_parameter()` still forwards `corner_radius`, `edge_smoothness`, `edge_width`, `tint`, and `edge_highlight` into `_mask_ui.set_shader_parameter(...)`, so the mask path still depends on the source scene’s shader-param plumbing. The cleanest decoupling is to stop driving the mask viewport through generic shader-parameter mirroring and give the source scene an explicit shell/mask sync API instead. More importantly, the frost/rim/inner-line problem was diagnosed as a composition-model mismatch rather than a tuning-only problem: in 2D, the look comes from a composite of `GlassFill`, `PreviewFrame`, `PreviewInnerBorder`, and content, while the hybrid path currently hides `PreviewFrame` and `PreviewInnerBorder` in world mode and asks one soft 3D body shader to procedurally recreate them. The recommended next pass is to keep authored `PreviewFrame` + `PreviewInnerBorder` + content visible in a dedicated hybrid overlay, hide only `GlassFill` and backgrounds there, feed that authored overlay to the front overlay mesh, and retune the body shader downward so it owns frost/perimeter lift/subtle world fresnel rather than the final sharp rim/inner line. Notes written at `.temp/71l-full-decoupling-frost-line-notes.md`.

---

### Task 2: Implement full decoupling and the best next shader/line-composition fix

**Bead ID:** `aerobeat-ui-kit-community-pd7`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`, `REF-06`, `REF-08`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, fully decouple hybrid default ownership so no hidden startup inheritance remains, then implement the best next change to improve the 3D shader’s frosted body, sharp outer rim, and crisp interior edge line toward the 2D reference. Preserve the correct authored UI/world-space architecture unless the research proves a small layering/composition change is necessary.

**Folders Created/Deleted/Modified:**
- `.testbed/scripts/`
- `.testbed/assets/shaders/`
- `.testbed/scenes/` if needed

**Files Created/Deleted/Modified:**
- `.testbed/scripts/glass_shader_gui_3d_test.gd`
- `.testbed/scripts/glass_shader_panel_source.gd`
- `.testbed/assets/shaders/glass-panel-hybrid-3d.gdshader`
- `.testbed/scenes/glass-shader-gui-3d-test.tscn`

**Status:** ✅ Complete

**Results:** The coder pass landed and was pushed in commit `86c3ca5` (`Finish hybrid glass decoupling and overlay parity`). It fully removed the remaining hybrid→mask generic shader-parameter mirroring from `glass_shader_gui_3d_test.gd`, added an explicit `sync_hybrid_shell()` API in `glass_shader_panel_source.gd` so shell ownership is intentional and clear, and changed hybrid world-space presentation so the front overlay now keeps `PreviewFrame`, `PreviewInnerBorder`, and content while still hiding `GlassFill` and backgrounds. The body shader in `.testbed/assets/shaders/glass-panel-hybrid-3d.gdshader` was retuned downward so it focuses on frost/refraction/subtle perimeter lift instead of trying to synthesize the final sharp outer rim and crisp inner line. Honest coder verdict: rim/inner-line behavior is now much closer thanks to the authored overlay path, but the frosted body itself still lags the 2D reference somewhat in richness/compositing.

---

### Task 3: QA full decoupling plus frost/rim/edge-line behavior against the screenshot and 2D reference

**Bead ID:** `aerobeat-ui-kit-community-4q0`  
**SubAgent:** `primary` (for `qa` workflow role)  
**Role:** `qa`  
**References:** `REF-03`, `REF-04`, `REF-05`, `REF-06`, `REF-08`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, verify both parts of this pass: (1) hybrid default ownership is fully decoupled, and (2) the frosted body, outer rim, and interior edge line are materially closer to the 2D reference and Derrick’s screenshot target. Be explicit about whether the 3D shader can now achieve the sharp white exterior line and the crisp interior line look or whether those still remain below parity.

**Folders Created/Deleted/Modified:**
- `.testbed/`

**Files Created/Deleted/Modified:**
- `.temp/qa-evidence/full-hybrid-decoupling-2026-05-12/`

**Status:** ✅ Complete

**Results:** QA passed the decoupling and line-treatment goals, but only partial-passed the frost-body goal. Runtime probing confirmed the remaining hybrid→mask startup coupling is gone in practice: the panel preview background can switch through modes while the mask stays fixed at `BACKGROUND_MODE_NONE` in `HYBRID_MASK` mode, indicating the mask is no longer implicitly following the hybrid startup defaults. Visually, the authored overlay materially improves both the outer rim and the inner edge line: the perimeter is much sharper and whiter, and the inner line is visibly crisper and less fuzzy than the old shader-only approach. The remaining gap is still the frosted body itself, which remains more transparent / less milky than the 2D shader, allowing background geometry to read through more strongly than the 2D reference. QA also confirmed the authored overlay helps without breaking the world-space behavior. Evidence was saved under `.temp/qa-evidence/full-hybrid-decoupling-2026-05-12/`, including `contact-sheet.png`, `zoom-sheet.png`, `full-sheet.png`, and `startup-probe.json`.

---

### Task 4: Audit whether the hybrid path now has clear ownership and a credible path to matching the 2D card details

**Bead ID:** `aerobeat-ui-kit-community-n8m`  
**SubAgent:** `primary` (for `auditor` workflow role)  
**Role:** `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`, `REF-06`, `REF-07`, `REF-08`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, audit the full decoupling and frost/rim/inner-line pass independently. Confirm whether default ownership is now truly explicit and whether the hybrid shader now has a credible path to the 2D card’s frosted body and line detail, or whether the parity gap still points to a deeper shader-model limitation.

**Folders Created/Deleted/Modified:**
- `.plans/` (notes/results only if needed)

**Files Created/Deleted/Modified:**
- optional audit notes if needed

**Status:** ✅ Complete

**Results:** Audit passed this slice for what it was actually trying to achieve: full hybrid default decoupling, materially sharper outer rim, materially crisper inner edge line, and meaningful progress on the frosted body. The key truth is that the pass succeeded by shifting authored rim/inner-line responsibility back into the overlay path, while the body shader became more narrowly responsible for frost/refraction/perimeter lift. The remaining gap is honest and specific: the frosted body still lags the 2D reference and lets background geometry show through more strongly, so this is not yet full visual parity.

---

## Final Results

**Status:** ⚠️ Partial

**What We Built:** Completed a full-decoupling and line-parity pass on the hybrid world-space glass path. The hybrid scene now has clear default ownership boundaries, with the remaining hybrid→mask startup coupling removed and shell syncing made explicit through `sync_hybrid_shell()`. The front overlay now carries the authored `PreviewFrame`, `PreviewInnerBorder`, and content in world space, which materially improves the sharp white perimeter and crisp inner edge line while preserving the correct world-space authored UI architecture.

**Reference Check:** `REF-01` through `REF-08` are satisfied for the intended scope of this slice. The default-ownership goal is achieved, and the screenshot-driven rim/inner-line complaints are materially improved. The unresolved difference is the frosted body itself, which still falls short of the 2D card’s density/richness.

**Commits:**
- `86c3ca5` - Finish hybrid glass decoupling and overlay parity

**Lessons Learned:** The rim/inner-line problem was not primarily a shader-parameter problem; it was a composition-ownership problem. The 2D card’s sharp shell details come from authored overlay layers, not from the same soft body pass that handles frost/refraction. Once that ownership was restored in the hybrid path, the remaining parity gap isolated cleanly to the body frost itself.

---

*Updated on 2026-05-12*
