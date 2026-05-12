# AeroBeat UI Kit Community — Hybrid World-Space Glass Parity Polish

**Date:** 2026-05-12  
**Status:** Draft  
**Agent:** Byte 🐈‍⬛

---

## Goal

Improve the new hybrid world-space glass panel so it better matches the successful 2D glass shader feel, specifically restoring a stronger frosted-glass read and removing the unusual blurry curved-edge rectangle artifact seen in runtime.

---

## Overview

The previous bead chain successfully replaced the dead-end hybrid architecture with the correct technical foundation: the UI is still authored through normal 2D Godot `Control` flow inside a `SubViewport`, while a new 3D shader owns the true world-aware glass optics. QA and audit both passed that architecture, but Derrick’s live review confirms the remaining problem is now visual parity rather than architecture.

Two specific follow-up issues are now the focus. First, the frosted glass quality from the 2D shader is not yet reading strongly enough in the world-space hybrid version. Second, there appears to be an unusual rectangle with blurry curved edges on the SubViewport panel, which likely indicates an issue in the new 3D shader’s masking/compositing/sample region, or in how the UI texture and world sample are being blended. The new screenshot should be treated as a primary debugging reference.

This plan should keep the correct hybrid architecture intact and treat the work as a targeted parity/polish/debug pass, not a restart. The job is to inspect the current hybrid shader/material composition against the 2D reference, identify the source of the curved blurry artifact, strengthen the frosted-glass read, then QA and audit the result against both the regular 2D scene and the new hybrid scene.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | 2D glass reference scene | `.testbed/scenes/glass-shader-test.tscn` |
| `REF-02` | Shared 2D authored panel source | `.testbed/scenes/glass-shader-panel-source.tscn` |
| `REF-03` | Current replacement hybrid world-space scene | `.testbed/scenes/glass-shader-gui-3d-test.tscn` |
| `REF-04` | New hybrid world-space shader | `.testbed/assets/shaders/glass-panel-hybrid-3d.gdshader` |
| `REF-05` | Hybrid scene controller script | `.testbed/scripts/glass_shader_gui_3d_test.gd` |
| `REF-06` | Shared panel source script | `.testbed/scripts/glass_shader_panel_source.gd` |
| `REF-07` | Prior architecture plan | `.plans/2026-05-12-hybrid-world-space-glass.md` |
| `REF-08` | User-provided screenshot of current artifact/parity gap | `/home/derrick/.openclaw/workspace/.temp/nerve-uploads/2026/05/12/image-4016922a.png` |

---

## Tasks

### Task 1: Investigate the frosted-glass parity gap and blurry curved-edge rectangle artifact

**Bead ID:** `aerobeat-ui-kit-community-9ka`  
**SubAgent:** `primary` (for `research` workflow role)  
**Role:** `research`  
**References:** `REF-01`, `REF-03`, `REF-04`, `REF-05`, `REF-06`, `REF-08`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, inspect the current hybrid world-space implementation and Derrick’s screenshot at `/home/derrick/.openclaw/workspace/.temp/nerve-uploads/2026/05/12/image-4016922a.png`. Determine why the hybrid result is not reading with the same frosted-glass strength as the 2D reference and identify the likely source of the unusual blurry curved-edge rectangle artifact on the panel. Produce an honest diagnosis and a focused implementation recommendation that preserves the new hybrid architecture.

**Folders Created/Deleted/Modified:**
- `.plans/` (notes/results only if needed)

**Files Created/Deleted/Modified:**
- optional investigation notes if needed

**Status:** ✅ Complete

**Results:** Diagnosis completed and confirmed two main issues. First, the hybrid world-space shader is not yet reproducing the 2D shader’s actual distortion field; it replaced the 2D card-bound axis-shaped exponential warp with a simpler full-quad radial refraction model and only rough parameter remaps, which weakens the frosted-glass parity. Second, the blurry curved-edge rectangle artifact appears to come from the 3D shader applying its rounded-rect glass mask across the entire `PanelDisplay` quad, while the intended authored UI card inside the `SubViewport` occupies only a smaller inset region. In other words, the large blurry rounded rectangle is the current 3D glass pass and the smaller crisp card is the authored UI. Recommended fix direction: preserve the hybrid architecture, but drive the 3D glass boundary from an authored mask coming from the 2D source scene, then port the 2D warp profile into the 3D shader as the base refraction model while keeping world-angle/fresnel behavior as an enhancement. Diagnosis note written at `.temp/9ka-hybrid-parity-diagnosis.md`.

---

### Task 2: Implement targeted shader/compositing fixes while preserving the new hybrid architecture

**Bead ID:** `aerobeat-ui-kit-community-f7e`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`, `REF-06`, `REF-08`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, fix the current hybrid world-space scene so it better matches the successful 2D glass feel without backing out the new architecture. Specifically target: (1) improving the frosted-glass read, and (2) removing the blurry curved-edge rectangle artifact visible in Derrick’s screenshot. Keep the 2D-authored/SubViewport workflow and the 3D world-aware shader architecture intact.

**Folders Created/Deleted/Modified:**
- `.testbed/scenes/`
- `.testbed/scripts/`
- `.testbed/assets/shaders/`

**Files Created/Deleted/Modified:**
- `.testbed/assets/shaders/glass-panel-hybrid-3d.gdshader`
- `.testbed/scenes/glass-shader-gui-3d-test.tscn`
- `.testbed/scenes/glass-shader-panel-source.tscn`
- `.testbed/scripts/glass_shader_gui_3d_test.gd`
- `.testbed/scripts/glass_shader_panel_source.gd`

**Status:** ✅ Complete

**Results:** The parity/artifact fix pass landed and was pushed in commit `437cadf` (`Polish hybrid world-space glass parity`). The implementation added a dedicated authored-mask path from the shared 2D source scene via a new `PRESENTATION_MODE_HYBRID_MASK` and `HybridMaskPanel`, then reworked the hybrid 3D scene to use separate content and mask `SubViewport`s. The hybrid 3D shader was rewritten to sample/crop the authored card region rather than glassing the whole source canvas, use the 2D warp profile (`warp_intensity`, `strength_x/y`, `offset_x/y`) as the base distortion field, and constrain blur/refraction/tint/highlight to the authored card mask while keeping world-angle/fresnel behavior as an additive enhancement. The old ghost `PanelShell` surface was hidden and the display quad resized to the authored card aspect. Validation included headless Godot load/quit, a scripted runtime capture pass, and manual inspection of generated captures under `.temp/subagent-hybrid-parity-captures/`. Honest result: the large ghost/blurry panel artifact is addressed and the hybrid result is materially closer to the 2D reference, but it still does not perfectly match the exact 2D glass look yet.

---

### Task 3: QA the polished hybrid scene against the 2D reference and the reported artifact

**Bead ID:** `aerobeat-ui-kit-community-eps`  
**SubAgent:** `primary` (for `qa` workflow role)  
**Role:** `qa`  
**References:** `REF-01`, `REF-03`, `REF-04`, `REF-08`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, run the polished hybrid scene in Godot and compare it directly against the 2D reference scene. Verify whether the frosted-glass feel is stronger and whether the blurry curved-edge rectangle artifact is gone. Be explicit about what improved, what remains different, and whether the result is now close enough to the 2D reference for the intended workflow.

**Folders Created/Deleted/Modified:**
- `.testbed/`

**Files Created/Deleted/Modified:**
- `.temp/qa-evidence/`

**Status:** ✅ Complete

**Results:** QA partial-passed the parity/polish slice. Real desktop Godot verification confirmed that the old oversized blurry/ghost rounded rectangle no longer hangs outside the intended card bounds; the glass/refraction now reads as constrained to the authored card region. Frosted-glass parity is improved and more intentional than before, with stronger edge/highlight/refraction behavior, but it still does not fully equal the 2D reference. The hybrid version remains more transparent/lens-like and more scene-reactive, while the 2D reference still reads denser, creamier, and more uniformly frosted. QA also confirmed that the 2D-authored/SubViewport workflow remains intact and the 3D world-aware behavior remains intact. Evidence was captured under `.temp/qa-evidence/`, including `2d-reference-full.png`, `2d-reference-crop.png`, `hybrid-angle-a-full.png`, `hybrid-angle-a-crop.png`, `hybrid-angle-b-full.png`, and `hybrid-angle-b-crop.png`.

---

### Task 4: Audit the visual-parity pass and decide whether the hybrid scene is now close enough

**Bead ID:** `aerobeat-ui-kit-community-ppw`  
**SubAgent:** `primary` (for `auditor` workflow role)  
**Role:** `auditor`  
**References:** `REF-01`, `REF-03`, `REF-04`, `REF-07`, `REF-08`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, audit the parity/polish pass independently. Decide whether the hybrid scene now truthfully preserves the right architecture while also coming close enough to the successful 2D glass feel, and whether the reported blurry curved-edge rectangle artifact is actually fixed.

**Folders Created/Deleted/Modified:**
- `.plans/` (notes/results only if needed)

**Files Created/Deleted/Modified:**
- optional audit notes if needed

**Status:** ✅ Complete

**Results:** Audit passed this bead as a successful targeted polish/artifact-fix slice, not as exact final 2D parity. Independent review confirmed that the authored-mask approach materially fixed the ghost/blurry curved-edge rectangle by constraining the glass to the authored card region, and that frosted-glass parity is meaningfully improved. The remaining gap is now strictly visual: the hybrid panel still reads somewhat more transparent, fresnel/specular-heavy, and scene-reactive than the denser, creamier 2D reference. The correct framing is that this bead got the hybrid scene close enough for this polish/debug slice while documenting the remaining parity gap honestly.

---

## Final Results

**Status:** ⚠️ Partial

**What We Built:** Landed a focused parity/artifact-fix pass on the hybrid world-space glass path. The hybrid scene now uses an authored mask and authored card bounds to constrain the 3D glass pass, eliminating the oversized ghost rounded rectangle and bringing the world-space shader materially closer to the 2D reference. The result preserves the correct 2D-authored + 3D world-aware architecture while improving visual cohesion and card-bound frosting behavior.

**Reference Check:** `REF-01` through `REF-08` were satisfied for the goals of this slice: the ghost artifact is materially resolved, the hybrid scene is closer to the 2D look, and the architecture remains intact. The unresolved difference is that exact 2D visual parity was not yet achieved.

**Commits:**
- `437cadf` - Polish hybrid world-space glass parity

**Lessons Learned:** Once the architecture and mask ownership were correct, the parity problem narrowed to two things: matching the authored card bounds exactly and reintroducing the 2D-style distortion/body behavior without glassing the whole quad. That was enough to remove the false ghost-panel bug and recover much more of the intended feel, but it also clarified that true world-aware 3D glass will still diverge aesthetically from a controlled 2D screen-space plate.

---

*Updated on 2026-05-12*
