# AeroBeat UI Kit Community — Decouple 2D and Hybrid Glass Defaults

**Date:** 2026-05-12  
**Status:** Stale  
**Agent:** Byte 🐈‍⬛

---

## Goal

Decouple the startup/default parameter values for the hybrid world-space glass scene from the 2D glass source scene, so the 3D hybrid path can keep its own tuned defaults without being overwritten by the 2D source defaults at runtime.

---

## Overview

Right now `glass_shader_gui_3d_test.gd` seeds the hybrid shader with its own defaults, but then `_copy_source_shader_defaults_to_hybrid_material()` copies a shared subset of values from the mounted 2D source scene back onto the hybrid material during `_ready()`. That means several important startup values in the hybrid scene are not actually authoritative in the hybrid script.

Derrick already confirmed the hybrid scene can get closer to the desired 2D feel by tuning values directly, which strongly suggests the two shaders should now be treated as related but independent systems. The 2D scene should keep its own defaults for the pure 2D use case, while the hybrid world-space scene should own its own defaults entirely.

This pass should remove the implicit startup inheritance, preserve the authored UI/content sharing between the 2D and hybrid paths, then QA that editing the hybrid defaults in `glass_shader_gui_3d_test.gd` actually controls the launched hybrid scene without affecting the 2D scene.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Hybrid scene controller script | `.testbed/scripts/glass_shader_gui_3d_test.gd` |
| `REF-02` | Shared 2D source script | `.testbed/scripts/glass_shader_panel_source.gd` |
| `REF-03` | Hybrid world-space scene | `.testbed/scenes/glass-shader-gui-3d-test.tscn` |
| `REF-04` | 2D reference scene | `.testbed/scenes/glass-shader-test.tscn` |
| `REF-05` | Current Unity-inspired pass plan/results | `.plans/2026-05-12-hybrid-world-space-glass-unity-inspiration-pass.md` |

---

## Tasks

### Task 1: Inspect the current hybrid startup inheritance and define the clean decoupling approach

**Bead ID:** `aerobeat-ui-kit-community-aac`  
**SubAgent:** `primary` (for `research` workflow role)  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, inspect how the hybrid scene currently seeds and then overrides shader defaults from the 2D source scene. Recommend the cleanest way to fully decouple startup/default values while preserving shared authored UI/content.

**Folders Created/Deleted/Modified:**
- `.plans/` (notes/results only if needed)

**Files Created/Deleted/Modified:**
- optional investigation notes if needed

**Status:** ✅ Complete

**Results:** Research confirmed the hidden startup override path is `.testbed/scripts/glass_shader_gui_3d_test.gd` → `_ready()` → `_apply_panel_materials()` → `_copy_source_shader_defaults_to_hybrid_material()` → `_panel_ui.get_shader_parameters()`. The hybrid script seeds its own defaults first, then overwrites a shared passthrough subset from the mounted 2D source scene: `blur`, `warp_intensity`, `strength_x`, `strength_y`, `offset_x`, `offset_y`, `corner_radius`, `edge_smoothness`, and `edge_width`. The clean decoupling recommendation is to remove the `_copy_source_shader_defaults_to_hybrid_material()` call while still sharing the authored UI/content scene, the authored preview/card rect, and runtime mask/style sync for card-shape alignment parameters. Diagnosis note written at `.temp/aac-default-decoupling-notes.md`.

---

### Task 2: Implement complete default-value decoupling between 2D and hybrid paths

**Bead ID:** `aerobeat-ui-kit-community-ddw`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, remove the startup/default-value inheritance from the 2D source scene into the hybrid world-space scene. After the change, the hybrid script should be the sole authority for hybrid defaults, and changing its declared defaults should affect hybrid playback without being overwritten by the 2D source. Preserve the shared UI/content relationship and do not regress the current scene behavior beyond the intended decoupling.

**Folders Created/Deleted/Modified:**
- `.testbed/scripts/`
- `.testbed/scenes/` if needed

**Files Created/Deleted/Modified:**
- `.testbed/scripts/glass_shader_gui_3d_test.gd`

**Status:** ✅ Complete

**Results:** The coder pass fully decoupled startup/default ownership by removing the hidden startup override from `.testbed/scripts/glass_shader_gui_3d_test.gd`. Specifically, it deleted the `_copy_source_shader_defaults_to_hybrid_material()` call from `_apply_panel_materials()` and removed the helper itself. Hybrid startup/default values are now owned solely by `HYBRID_FLOAT_CONTROLS` / `HYBRID_COLOR_CONTROLS` in `glass_shader_gui_3d_test.gd`, while 2D defaults remain owned solely by `FLOAT_CONTROLS` / `COLOR_CONTROLS` in `glass_shader_panel_source.gd`. Validation included a proof pass that temporarily changed the hybrid `blur` default from `4.2` to `5.7`, confirmed the hybrid runtime used `5.7` while the 2D source runtime stayed at `4.2`, then restored the value before commit. Commit pushed: `641fd9a` (`Decouple hybrid shader startup defaults`). No remaining default-value ownership ambiguity was found; the remaining shared behavior is authored UI/content/mask/geometry sync only.

---

### Task 3: QA that hybrid defaults now apply independently of the 2D scene

**Bead ID:** `aerobeat-ui-kit-community-jym`  
**SubAgent:** `primary` (for `qa` workflow role)  
**Role:** `qa`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, verify that the hybrid scene now uses its own defaults independently of the 2D source scene. Be explicit that changing hybrid defaults affects the hybrid scene at startup and that the 2D scene keeps its own behavior.

**Folders Created/Deleted/Modified:**
- `.testbed/`

**Files Created/Deleted/Modified:**
- QA evidence artifacts if produced

**Status:** ✅ Complete

**Results:** QA confirmed that the main hybrid 3D material now starts from `glass_shader_gui_3d_test.gd` defaults rather than being overwritten from the 2D source scene. A black-box sentinel test patched the 2D source defaults to obvious values like `blur=7.7`, `warp_intensity=0.91`, and `chromatic_strength=4.4`, then launched the hybrid scene and verified its runtime values still started from the hybrid script defaults like `blur=4.2`, `warp_intensity=0.45`, and `chromatic_strength=1.3`. QA also confirmed the standalone 2D scene keeps its own defaults. The caveat discovered here was that a startup-time hybrid→mask sync path still affected shell-alignment params on the mask-side source instance, which is why a follow-up full-decoupling pass was necessary.

---

### Task 4: Audit the decoupling so the ownership model is clear and truthful

**Bead ID:** `aerobeat-ui-kit-community-tbo`  
**SubAgent:** `primary` (for `auditor` workflow role)  
**Role:** `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, audit the decoupling independently. Confirm that default ownership is now clear: hybrid defaults live in the hybrid script, 2D defaults live in the 2D source script, and there is no hidden startup override path left.

**Folders Created/Deleted/Modified:**
- `.plans/` (notes/results only if needed)

**Files Created/Deleted/Modified:**
- optional audit notes if needed

**Status:** ⏳ Pending

**Results:** This plan’s original audit goal was partially superseded by the later full-decoupling follow-up, because QA found the remaining hybrid→mask shell sync path. See `.plans/2026-05-12-full-hybrid-decoupling-and-frost-line-parity.md` for the completed full-decoupling audit result.

---

## Final Results

**Status:** ⚠️ Partial

**What We Built:** Removed the original hidden 2D→hybrid startup override so the hybrid scene’s material defaults now come from `glass_shader_gui_3d_test.gd` instead of silently inheriting a shared subset from the mounted 2D source scene. This successfully decoupled the main hybrid material from the 2D scene’s startup defaults while preserving shared authored UI/content and card-rect behavior.

**Reference Check:** `REF-01` through `REF-04` are satisfied for the narrow goal of removing the old source→hybrid startup override. The later QA caveat matters: startup ownership was clearer, but not fully complete until the follow-up pass removed the remaining hybrid→mask shell sync ambiguity.

**Commits:**
- `641fd9a` - Decouple hybrid shader startup defaults

**Lessons Learned:** The first decoupling pass fixed the user-facing problem Derrick hit—hybrid defaults being silently overwritten by the 2D source—but it also showed that ownership clarity has layers. Removing the obvious source→hybrid override was not the same as full startup ownership isolation, because shell/mask alignment parameters were still being pushed into the mask-side source instance. That led directly to the follow-up full-decoupling pass.

---

*Updated on 2026-05-12*
