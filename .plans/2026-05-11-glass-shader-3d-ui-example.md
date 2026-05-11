# AeroBeat UI Kit Community — 3D Glass Shader + Example Scene

**Date:** 2026-05-11  
**Status:** Draft  
**Agent:** Byte 🐈‍⬛

---

## Goal

Create a new shader and a new `.testbed` example scene that demonstrate a true 3D glass-style UI panel workflow for this repo.

---

## Overview

This work belongs in `aerobeat-ui-kit-community`, so the plan and Beads live here. Instead of only adapting the current 2D `canvas_item` shader into a 3D-ish presentation, this plan now assumes Derrick wants a separate shader specifically aimed at 3D-facing panel work, plus an example scene that proves how to use it.

The key constraint is still truthfulness. The existing 2D glass shader and tester are validated in this repo, but a new 3D shader would be fresh work. So the new example scene should be presented as a validated repo-local example once built and tested here, not retroactively described as an already-established system. The implementation needs to decide on a practical 3D path — most likely a `spatial` shader on a 3D panel/mesh, or a tightly-scoped hybrid if that proves more truthful — and then expose enough scene structure and controls to make the effect inspectable.

The scene should make it easy to answer the real question: does the new 3D shader create a convincing glass panel effect in 3D space, with readable highlights, background response, and useful tuning hooks? Derrick also clarified that the new scene should include a basic rotation option so the panel can be viewed as real 3D instead of a static straight-on card. QA and audit will verify both the visual result and that the scene/doc wording does not overclaim beyond what is actually built and tested.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Original 2D shader source page | `https://godotshaders.com/shader/liquid-glass-ui-customizable/` |
| `REF-02` | Current 2D glass test scene | `/home/derrick/Documents/projects/aerobeat/aerobeat-ui-kit-community/.testbed/scenes/glass-shader-test.tscn` |
| `REF-03` | Current 2D glass controller script | `/home/derrick/Documents/projects/aerobeat/aerobeat-ui-kit-community/.testbed/scripts/glass_shader_test.gd` |
| `REF-04` | Current 2D debug backdrop helper | `/home/derrick/Documents/projects/aerobeat/aerobeat-ui-kit-community/.testbed/scripts/glass_debug_backdrop.gd` |
| `REF-05` | Current shader usage doc | `/home/derrick/Documents/projects/aerobeat/aerobeat-ui-kit-community/docs/glass-shader-usage.md` |
| `REF-06` | Target testbed root | `/home/derrick/Documents/projects/aerobeat/aerobeat-ui-kit-community/.testbed/` |

---

## Tasks

### Task 1: Design the truthful 3D shader approach and build the new shader + example scene

**Bead ID:** `aerobeat-ui-kit-community-nj4`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`, `REF-06`  
**Prompt:** In `/home/derrick/Documents/projects/aerobeat/aerobeat-ui-kit-community`, claim bead `aerobeat-ui-kit-community-nj4` with `bd update aerobeat-ui-kit-community-nj4 --status in_progress --json`. Design and build a truthful new 3D-focused glass shader plus a new `.testbed` example scene. The scene must include a basic rotation option so the panel can be viewed from different angles and read as real 3D. Stay honest about what is newly built here: create the shader, create the example scene, add any supporting scripts/resources needed, and preserve enough inspectability that QA can verify the glass look and the rotation behavior live. Close the bead with a clear reason when done.

**Folders Created/Deleted/Modified:**
- `.testbed/scenes/`
- `.testbed/scripts/`
- `.testbed/assets/shaders/`
- `.testbed/assets/` if supporting assets are needed

**Files Created/Deleted/Modified:**
- new 3D shader file
- new 3D example scene file(s)
- any supporting scripts/resources

**Status:** ✅ Complete

**Results:** Built a real 3D path in the hidden testbed rather than a 2D fake: a new spatial shader at `.testbed/assets/shaders/glass-panel-3d.gdshader`, a new example scene at `.testbed/scenes/glass-shader-3d-test.tscn`, a procedural 3D debug backdrop, and controller/capture scripts. The scene uses a perspective camera, a mesh-backed glass panel with actual thickness (`BoxMesh` body plus shader-driven `QuadMesh` face), and a basic rotation system on `PanelPivot` with auto-rotate plus manual yaw/pitch controls. The main shader/documentation file was also updated to point at the new 3D source-of-truth files.

---

### Task 2: QA the 3D shader example for live usefulness and real 3D glass behavior

**Bead ID:** `aerobeat-ui-kit-community-516`  
**SubAgent:** `primary` (for `qa` workflow role)  
**Role:** `qa`  
**References:** `REF-02`, `REF-05`, `REF-06`  
**Prompt:** In `/home/derrick/Documents/projects/aerobeat/aerobeat-ui-kit-community`, claim bead `aerobeat-ui-kit-community-516` with `bd update aerobeat-ui-kit-community-516 --status in_progress --json`. QA the new 3D glass shader example scene live. Verify that the scene reads as real 3D, that the rotation option works, and that the new glass treatment is useful/inspectable rather than just a flat imitation. Capture evidence and close the bead with a precise pass/fail reason.

**Folders Created/Deleted/Modified:**
- `.testbed/`

**Files Created/Deleted/Modified:**
- QA evidence artifacts if produced

**Status:** ✅ Complete

**Results:** QA passed in a rendered Godot session. The panel reads as genuinely 3D with visible box thickness, helpful fresnel/rim response, and convincing screen-space distortion/blur across the debug backdrop. Auto rotation, manual rotation, and reset all worked. QA noted the expected screen-space weakening at stronger oblique angles, but judged the result still acceptable and useful as a real 3D example. Evidence was captured under the testbed app_userdata `qa_glass_3d` and `qa_glass_3d_input` folders.

---

### Task 3: Audit the new 3D shader/example scene against the request and repo truthfulness

**Bead ID:** `aerobeat-ui-kit-community-l59`  
**SubAgent:** `primary` (for `auditor` workflow role)  
**Role:** `auditor`  
**References:** `REF-01`, `REF-05`, `REF-06`  
**Prompt:** In `/home/derrick/Documents/projects/aerobeat/aerobeat-ui-kit-community`, claim bead `aerobeat-ui-kit-community-l59` with `bd update aerobeat-ui-kit-community-l59 --status in_progress --json`. Audit the new 3D shader and example scene independently. Confirm it truthfully satisfies the request for a new shader, a new example scene, and a basic rotation option, without overstating what is validated. Close the bead only if the result is accurate and complete.

**Folders Created/Deleted/Modified:**
- `TBD`

**Files Created/Deleted/Modified:**
- `TBD`

**Status:** ✅ Complete

**Results:** Final audit passed. Verified that the new shader exists, the new scene exists, the panel reads as real 3D with real thickness plus a separate glass face, the rotation option works, and the implementation is described truthfully with the expected limitation that screen-space glass weakens at stronger oblique angles.

---

## Final Results

**Status:** ✅ Complete

**What We Built:** Added a new 3D-focused glass shader path and example scene to the hidden testbed. The new shader lives at `.testbed/assets/shaders/glass-panel-3d.gdshader`, and the example scene lives at `.testbed/scenes/glass-shader-3d-test.tscn`. The scene uses a real `Node3D` setup with perspective camera, lighting, a thick `BoxMesh` panel body, a separate shader-driven `QuadMesh` glass face, a procedural 3D debug backdrop, and a basic rotation system with auto-rotate plus manual pitch/yaw controls.

**Reference Check:** `REF-01` through `REF-06` satisfied. The result is a newly built and validated repo-local 3D example — not an overclaim that the original 2D shader already solved 3D glass UI. The implementation is truthful about the known limitation that the screen-space distortion effect weakens at stronger oblique angles.

**Commits:**
- None yet.

**Lessons Learned:** The honest way to pursue 3D here was not to stretch the 2D `canvas_item` shader further, but to build a separate 3D path with a spatial shader and actual 3D geometry. Real thickness, rotation, and diagnostic backdrops were essential for proving that the panel reads as 3D instead of just being a rotated flat card.

---

*Completed on 2026-05-11*
