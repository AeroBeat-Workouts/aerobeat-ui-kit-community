# AeroBeat UI Kit Community — Hybrid World-Space Glass Unity-Inspiration Pass

**Date:** 2026-05-12  
**Status:** Stale  
**Agent:** Byte 🐈‍⬛

---

## Goal

Use the Unity shader/reference project at `https://github.com/TommyDatLC/GlassShaderRender` as inspiration for one more hybrid world-space glass pass, to see whether borrowing its world-space UI glass treatment ideas gets the Godot hybrid panel meaningfully closer to the successful 2D frosted-glass look.

---

## Overview

The prior architecture, mask, artifact-fix, and final parity-push passes already established the truthful ceiling of the current in-house hybrid approach: it now preserves 2D Godot UI authoring, uses authored card bounds, and refracts the real 3D world behind the panel. However, even after the final shader rebalance, Derrick’s live review is still that the result is not very close enough to the best 2D glass card.

That makes the new Unity reference strategically valuable. Instead of continuing to grind blindly on the current Godot shader, this pass should inspect the Unity project for specific world-space UI glass ideas: how it handles body density, blur layering, frosted-face stability, rim balance, and whether it uses any compositing tricks that make a world-space canvas still feel like a creamy frosted slab rather than a reactive lens. The goal is not to copy Unity code literally into Godot, but to extract rendering ideas and adapt them honestly.

This pass should therefore start with a careful reference study, then implement only the most promising portable ideas into the current Godot hybrid shader path. Derrick also now identified three specific visible gaps that should be treated as the acceptance criteria for this slice: (1) the glass frost effect still does not match the 2D shader closely enough, (2) the text in the 3D world shader pass reads blurry, and (3) the lighting/coloring of the UI and text does not match the 2D version. If the Unity reference suggests a materially better visual model for those exact issues, we should test it. If it turns out to rely on Unity-specific rendering features that do not port cleanly, the audit should say so clearly and document whether the current Godot hybrid path has effectively hit its ceiling.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Unity inspiration repo | `https://github.com/TommyDatLC/GlassShaderRender` |
| `REF-02` | Current hybrid world-space scene | `.testbed/scenes/glass-shader-gui-3d-test.tscn` |
| `REF-03` | Current hybrid world-space shader | `.testbed/assets/shaders/glass-panel-hybrid-3d.gdshader` |
| `REF-04` | 2D reference scene | `.testbed/scenes/glass-shader-test.tscn` |
| `REF-05` | Latest final parity-push plan/results | `.plans/2026-05-12-hybrid-world-space-glass-final-parity-push.md` |
| `REF-06` | Prior parity/artifact polish plan/results | `.plans/2026-05-12-hybrid-world-space-glass-parity-polish.md` |
| `REF-07` | Latest parity QA evidence | `.temp/qa-evidence/` |
| `REF-08` | Current hybrid controller script | `.testbed/scripts/glass_shader_gui_3d_test.gd` |

---

## Tasks

### Task 1: Research the Unity reference and extract portable world-space glass ideas

**Bead ID:** `aerobeat-ui-kit-community-tq5`  
**SubAgent:** `primary` (for `research` workflow role)  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`, `REF-07`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, inspect the Unity reference project at `https://github.com/TommyDatLC/GlassShaderRender` and compare its world-space UI glass treatment to our current Godot hybrid implementation. Extract the most promising portable ideas that could make the Godot hybrid panel feel denser, creamier, and closer to the 2D reference. Be explicit about which parts look portable versus Unity-specific.

**Folders Created/Deleted/Modified:**
- `.plans/` (notes/results only if needed)

**Files Created/Deleted/Modified:**
- optional investigation notes if needed

**Status:** ⏳ Pending

**Results:** Not started.

---

### Task 2: Implement the best Unity-inspired parity improvements in the Godot hybrid shader path

**Bead ID:** `aerobeat-ui-kit-community-1ct`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`, `REF-06`, `REF-08`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, implement the most promising Unity-inspired visual ideas into the current Godot hybrid glass path without breaking the correct 2D-authored/world-aware architecture. Focus on the concrete user-reported gaps: improve the frost effect so it more closely matches the 2D shader, address blurry text in the 3D world-space pass, and bring the lighting/coloring of the UI and text closer to the 2D version, while remaining truthful in Godot.

**Folders Created/Deleted/Modified:**
- `.testbed/scenes/`
- `.testbed/scripts/`
- `.testbed/assets/shaders/`

**Files Created/Deleted/Modified:**
- `.testbed/assets/shaders/glass-panel-hybrid-3d.gdshader`
- `.testbed/assets/shaders/glass-panel-ui-overlay-3d.gdshader`
- `.testbed/scripts/glass_shader_gui_3d_test.gd`
- `.testbed/scenes/glass-shader-gui-3d-test.tscn`

**Status:** ✅ Complete

**Results:** The Unity-inspired implementation pass landed and was pushed in commit `820828a` (`Split hybrid glass body from crisp UI overlay`). The key change was splitting the hybrid panel into a milkier frosted-body shader pass plus a separate crisp UI overlay pass in front. This preserved the existing correct architecture—2D-authored SubViewport content, authored mask/card bounds, and world-aware 3D glass body—while making the face treatment flatter and more art-directed and letting UI text/content stay much crisper and closer to the 2D color treatment. A new overlay shader was added at `.testbed/assets/shaders/glass-panel-ui-overlay-3d.gdshader`, and the hybrid body shader, controller script, and scene were updated accordingly. Runtime captures were generated under `.temp/qa-evidence/unity-inspired-hybrid-pass/`. Honest coder verdict: all three reported issues improved materially, but the hybrid can still read too milky/opaque straight-on against bright geometry, so this is a meaningful improvement rather than guaranteed full parity.

---

### Task 3: QA the Unity-inspired Godot result against the 2D reference

**Bead ID:** `aerobeat-ui-kit-community-9x1`  
**SubAgent:** `primary` (for `qa` workflow role)  
**Role:** `qa`  
**References:** `REF-02`, `REF-03`, `REF-04`, `REF-07`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, run the updated hybrid scene in Godot and compare it directly against the 2D reference. Verify specifically whether (1) the frost effect is closer to the 2D shader, (2) text clarity is improved rather than blurry, and (3) the lighting/coloring of the UI and text are closer to the 2D version. Also state whether the Unity-inspired pass actually gets the hybrid version past the prior ceiling, what improved, what remained unchanged, and whether the extra pass was worth it.

**Folders Created/Deleted/Modified:**
- `.testbed/`

**Files Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/.temp/qa-hybrid-glass-2026-05-12/`

**Status:** ✅ Complete

**Results:** QA completed in real Godot renders and judged this pass mixed. Text clarity is materially improved versus the older single-pass 3D panel thanks to the crisp overlay, and UI/text lighting-color treatment is somewhat closer to the 2D version, though still washed out and flatter than the 2D reference. However, the frost effect itself remains only a partial and weak match: the new hybrid reads much milkier/creamier straight-on than the 2D reference rather than matching its clearer colored frost. QA also confirmed that the correct world-space behavior and SubViewport-driven authored UI workflow remain intact. The coder-reported new issue is real and significant: straight-on views against bright geometry show a large white veil that obscures backdrop detail and reduces UI contrast. Bottom line: two of the three reported issues improved to some degree, but frost fidelity remains weak and the new milkiness is a moderate-to-high severity regression risk.

---

### Task 4: Audit whether the Unity inspiration materially broke through the prior parity ceiling

**Bead ID:** `aerobeat-ui-kit-community-e87`  
**SubAgent:** `primary` (for `auditor` workflow role)  
**Role:** `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`, `REF-06`, `REF-07`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, audit the Unity-inspired pass independently. Decide whether the borrowed ideas materially improved the Godot hybrid panel beyond the prior parity ceiling, or whether the current Godot approach still tops out below the 2D reference despite the new inspiration.

**Folders Created/Deleted/Modified:**
- `.plans/` (notes/results only if needed)

**Files Created/Deleted/Modified:**
- optional audit notes if needed

**Status:** ✅ Complete

**Results:** Audit judged this pass a mixed branch point rather than a clean pass. The important insight worth keeping is the split crisp UI overlay, which materially improves text legibility and helps UI/text treatment somewhat. But the current tuned body pass is not a final keeper for parity because the new milky straight-on veil regression outweighs the body-side gains, and the frost effect still does not match the 2D card closely enough. The correct interpretation is that `820828a` is a useful exploratory result, not proof that the Unity-inspired pass solved the hybrid glass problem.

---

## Final Results

**Status:** ⚠️ Partial

**What We Built:** Ran a Unity-inspired exploratory pass on the hybrid world-space glass path and adapted the main portable idea from the donor: separate the crisp UI presentation from the frosted glass body. The resulting implementation split the panel into a milkier frosted body shader plus a separate crisp UI overlay in front, preserving the existing correct Godot architecture while materially improving text clarity and somewhat improving UI/text lighting-color treatment.

**Reference Check:** `REF-01` through `REF-08` were satisfied for the exploratory goals of this slice. The donor did provide a useful portable insight—art-directed face/UI compositing matters more than more refraction complexity—but it did not break through the prior parity ceiling cleanly. The frost effect still falls short of the 2D reference and the new body treatment introduced a significant milky/opaque straight-on veil regression.

**Commits:**
- `820828a` - Split hybrid glass body from crisp UI overlay

**Lessons Learned:** The Unity donor reinforced that the remaining problem is not missing refraction cleverness; it is how the face is art-directed and how the UI is composited relative to the frosted body. Separating a crisp UI overlay from the body shader is a real improvement lever worth preserving, but simply making the body milkier is not enough and can overshoot into a white veil that harms both backdrop detail and UI contrast. The clean next move, if continuing later, is likely to keep the crisp overlay idea while backing off the opaque veil and trying to recover the 2D card’s clearer colored frost.

---

*Updated on 2026-05-12*
