# AeroBeat UI Kit Community — Hybrid World-Space Glass Panel

**Date:** 2026-05-12  
**Status:** Draft  
**Agent:** Byte 🐈‍⬛

---

## Goal

Prove a workflow where AeroBeat UI is still authored as normal 2D Godot GUI, but is then displayed in 3D world space with the same strong glass effect as the current 2D test scene while also interacting meaningfully with the real 3D world behind the panel.

---

## Overview

This work belongs in the `aerobeat-ui-kit-community` repo because the current 2D, native 3D, and hybrid glass experiments all live in the repo-local `.testbed`. The immediate problem is now clear: the current hybrid path renders the original 2D glass scene inside a `SubViewport`, so the `canvas_item` shader only samples that inner viewport rather than the surrounding 3D world. That means the current hybrid panel can preserve 2D authoring ergonomics and some of the 2D look, but it cannot truthfully refract or blur the actual 3D scene behind it in its current form.

Derrick’s clarified goal matters a lot: the target is not “replace 2D UI authoring with 3D-native UI authoring.” The target is to keep building the UI itself with Godot’s normal 2D GUI tools, then display that authored UI in 3D world space with the same glass quality the current 2D test scene already achieves. Derrick also wants this new path to replace the current hybrid scene in practice, while remaining easy to compare directly against the regular 2D scene during iteration. That makes the hybrid/world-space route strategically valuable because it keeps the authoring workflow friendly, preserves fast A/B comparison, and aligns with AeroBeat’s VR direction. Derrick is okay with a dedicated shader for this specific presentation path, so the plan should treat that as a first-class option.

The plan is to first verify the technical options honestly, then choose the most viable implementation path. The strongest candidate is likely a split architecture: keep the authored UI content in a 2D `SubViewport`, but move the actual glass/world-distortion work onto the 3D panel material or another world-aware layer so the panel can both show the 2D UI and distort the real 3D world behind it. Other candidates remain: (1) compositing world content into the same viewport the 2D shader samples, or (2) concluding that the current hybrid architecture should be documented as limited and the native 3D path should become the main world-space direction. We should not guess; we should prove which path is viable in the `.testbed`.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Existing 2D glass tester source scene | `.testbed/scenes/glass-shader-test.tscn` |
| `REF-02` | Existing shared hybrid source scene | `.testbed/scenes/glass-shader-panel-source.tscn` |
| `REF-03` | Existing hybrid 3D GUI wrapper scene to replace/evolve | `.testbed/scenes/glass-shader-gui-3d-test.tscn` |
| `REF-04` | Existing native 3D glass scene | `.testbed/scenes/glass-shader-3d-test.tscn` |
| `REF-05` | Current 2D shader used for the tester/source panel | `.testbed/assets/shaders/glass-shader.gdshader` |
| `REF-06` | Current native 3D shader path | `.testbed/assets/shaders/glass-panel-3d.gdshader` |
| `REF-07` | Prior handoff / limitation summary | `memory/2026-05-11.md` |

Use these references in implementation notes, QA findings, and audit conclusions so we stay exact about what changed and what behavior was validated.

---

## Tasks

### Task 1: Investigate viable 2D-authored, 3D-presented glass architectures

**Bead ID:** `aerobeat-ui-kit-community-uvx`  
**SubAgent:** `primary` (for `research` workflow role)  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`, `REF-06`, `REF-07`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, inspect the existing 2D, hybrid, and native 3D glass paths and produce an honest technical recommendation for Derrick’s clarified goal: author the UI with normal 2D Godot GUI tools, then present that authored UI in 3D world space with the same convincing glass effect as the current 2D test scene. Specifically evaluate whether we should: (a) keep the UI authored in a `SubViewport` but move the actual glass/world-distortion work onto a dedicated 3D/world-space panel shader, (b) composite/capture world content into the same viewport the 2D shader samples, or (c) formally abandon the current hybrid approach in favor of extending the native 3D path despite the authoring-workflow cost. The result must explain tradeoffs for VR/world-space UI, expected Godot rendering constraints, and the most promising next implementation slice.

**Folders Created/Deleted/Modified:**
- `.plans/` (notes/results only if needed)

**Files Created/Deleted/Modified:**
- optional investigation notes if needed

**Status:** ✅ Complete

**Results:** Research completed and confirmed the current `SubViewport` hybrid path is not world-aware glass. The recommended architecture is a split path: keep normal 2D GUI authoring inside the `SubViewport`, but move the actual glass optics to a new `spatial` shader on the 3D panel mesh that samples both the real 3D `screen_texture` and the authored UI texture. This preserves 2D authoring while enabling real world-behind-glass distortion. Investigation note written at `.temp/uvx-hybrid-architecture-recommendation.md`. Option B (feeding world content back into the 2D viewport) was judged too brittle/heavy for the next slice, and Option C (native 3D UI authoring) fails Derrick’s workflow goal.

---

### Task 2: Implement the chosen prototype for a 2D-authored GUI panel with true world-behind-glass behavior

**Bead ID:** `aerobeat-ui-kit-community-52g`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`, `REF-06`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, implement the smallest truthful prototype that best supports Derrick’s goal of keeping UI authored with Godot’s 2D GUI tools while presenting it as a world-space / VR-friendly glass panel. Replace or evolve the current `.testbed/scenes/glass-shader-gui-3d-test.tscn` hybrid scene rather than creating an unrelated parallel path, but preserve easy direct comparison with the regular 2D scene during development. Use a dedicated shader for this hybrid presentation path if that is the most honest solution. Preserve the useful parts of the current 2D authoring workflow wherever possible, but prioritize proving a result that both displays the authored 2D UI and shows real world-behind-glass distortion.

**Folders Created/Deleted/Modified:**
- `.testbed/scenes/`
- `.testbed/scripts/`
- `.testbed/assets/shaders/`

**Files Created/Deleted/Modified:**
- `.testbed/assets/shaders/glass-panel-hybrid-3d.gdshader`
- `.testbed/scripts/glass_shader_panel_source.gd`
- `.testbed/scripts/glass_shader_gui_3d_test.gd`
- `.testbed/scenes/glass-shader-gui-3d-test.tscn`

**Status:** ✅ Complete

**Results:** The replacement hybrid/world-space prototype landed and was pushed in commit `27ad5a6` (`Implement hybrid world-space glass panel shader`). The implementation introduced a new `spatial` shader at `.testbed/assets/shaders/glass-panel-hybrid-3d.gdshader` that samples both the real 3D `screen_texture` and the authored `SubViewport` UI texture, so the 3D panel now owns the actual glass optics rather than pasting a pre-baked 2D glass result onto a mesh. The shared 2D source script gained a hybrid/world-space presentation mode that hides the old 2D `GlassFill` distortion while preserving authored UI/chrome, and the hybrid test scene/script were reworked to use that mode, default to transparent/no-background for truthful world-space behavior, and expose a smaller more honest control set. Headless validation passed for import, scene instantiation, hybrid-mode wiring, default background mode, shader assignment, and readable shader params, but final visual judgment still requires interactive QA because reliable automated screenshot capture was not available in the dummy headless renderer.

---

### Task 3: QA the prototype in Godot for real 2D-authoring + world-space usefulness

**Bead ID:** `aerobeat-ui-kit-community-avf`  
**SubAgent:** `primary` (for `qa` workflow role)  
**Role:** `qa`  
**References:** `REF-02`, `REF-03`, `REF-04`, `REF-05`, `REF-06`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, run the chosen prototype in Godot and verify whether it is actually useful for AeroBeat’s intended workflow. Do not just confirm that a shader renders; verify both sides of the goal: (1) the panel still presents real UI authored through normal 2D Godot GUI tools, and (2) the panel visibly distorts or blurs the real 3D world behind it in a way that would make sense for a VR/shared-art-direction UI approach. Capture evidence and be explicit about what works, what still fails, and whether the result is good enough to continue investing in.

**Folders Created/Deleted/Modified:**
- `.testbed/`

**Files Created/Deleted/Modified:**
- `.temp/qa-worldspace-glass-20260512/`

**Status:** ✅ Complete

**Results:** QA passed on the architecture and partial-passed on visual parity. Live Godot verification confirmed that the replacement hybrid scene still mounts the shared 2D panel source through a `SubViewport`, so the normal 2D Godot GUI authoring path is preserved. More importantly, the new hybrid shader now shows meaningful real world-behind-glass interaction: changing `refraction_strength` and panel yaw visibly changes the real 3D backdrop seen through the glass, rather than just changing a baked 2D texture. QA also confirmed the hybrid mode is not double-glassing the panel because `GlassFill` is hidden and the authored UI/chrome reads as a separate layer over the world-aware glass pass. Direct comparison with the regular 2D scene remains practical. The honest gap is visual parity: the hybrid result is credible and worth continuing, but it does not yet fully match the strongest “hero” liquid-glass feel of `glass-shader-test.tscn`; today it reads more like a solid diegetic 3D prop with composited UI than a true 3D clone of the best 2D look. Evidence was saved under `.temp/qa-worldspace-glass-20260512/`, including `qa-summary.md`, `qa-contact-sheet.png`, and individual captures.

---

### Task 4: Audit the result and decide the 2D-authoring / 3D-presentation architecture

**Bead ID:** `aerobeat-ui-kit-community-98n`  
**SubAgent:** `primary` (for `auditor` workflow role)  
**Role:** `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`, `REF-06`, `REF-07`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, audit the implemented prototype and QA evidence independently. Decide whether the result truthfully advances Derrick’s actual goal: a workflow where UI is authored in normal 2D Godot GUI tooling, then presented in 3D world space with a glass treatment that still meaningfully interacts with the world behind it and can share style with VR. If yes, close with a clear recommendation for the new preferred architecture. If not, state exactly which limitation remains and whether the correct next move is further 3D shader work, world-compositing work, or explicit documentation of the hybrid limit.

**Folders Created/Deleted/Modified:**
- `.plans/` (notes/results only if needed)

**Files Created/Deleted/Modified:**
- optional audit notes if needed

**Status:** ✅ Complete

**Results:** Audit passed this bead as the correct architectural completion. Independent review confirmed that the replacement hybrid path now keeps UI authored through the shared 2D `Control` scene and `SubViewport`, while moving the actual glass optics to the new world-aware 3D shader. The old hybrid limitation is resolved: the panel now meaningfully interacts with the real 3D world behind it, and the hybrid mode avoids fake double-glass layering by hiding the old 2D `GlassFill`. The honest remaining gap is aesthetic rather than architectural: the result does not yet fully match the strongest 2D “hero” liquid-glass feel, so the right follow-up is a dedicated visual-parity/polish pass rather than more foundational architecture work.

---

## Final Results

**Status:** ⚠️ Partial

**What We Built:** Replaced the old dead-end hybrid architecture with a truthful world-space version of the scene. The new `glass-shader-gui-3d-test.tscn` still uses the shared 2D-authored panel source through a `SubViewport`, but the real glass optics now live in a new 3D shader, `.testbed/assets/shaders/glass-panel-hybrid-3d.gdshader`, which samples both the authored UI texture and the real 3D world behind the panel. This solves the core workflow/architecture goal: AeroBeat can keep authoring UI with normal 2D Godot tools while presenting it in 3D world space with real behind-glass interaction.

**Reference Check:** `REF-01` through `REF-07` are satisfied for the architectural goal. The unresolved gap is visual parity rather than structure: the new world-space hybrid result is credible and useful, but it does not yet fully match the strongest “hero” liquid-glass feel of the 2D reference scene.

**Commits:**
- `27ad5a6` - Implement hybrid world-space glass panel shader

**Lessons Learned:** The original hybrid limitation was real and structural, not just a tuning bug: a 2D `canvas_item` glass shader inside a `SubViewport` cannot truthfully refract the outer 3D world. The correct split is to preserve 2D UI authoring in the viewport while moving the optics to a world-aware 3D shader. Once that foundation is in place, remaining work becomes honest aesthetic/polish work instead of fighting Godot’s render model.

---

*Updated on 2026-05-12*
