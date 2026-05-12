# AeroBeat UI Kit Community — 3D GUI Panel Using the Original 2D Glass Shader

**Date:** 2026-05-11  
**Status:** Draft  
**Agent:** Byte 🐈‍⬛

---

## Goal

Create a new test scene that uses the original 2D glass shader effect together with Godot’s 3D GUI panel workflow, so we can compare that path directly against the separate native 3D shader example.

---

## Overview

This work belongs in `aerobeat-ui-kit-community`, so the plan and Beads live here. The goal is not to replace the new native 3D shader scene, but to add a second example scene that answers a different question: what does the original 2D glass shader look like when routed through Godot’s 3D GUI panel system?

The truthful implementation path is a `SubViewport`-backed UI surface, where the original 2D shader remains the glass effect source and the resulting UI is presented as a real 3D panel in space. Derrick sharpened the hybrid target further: the scene should keep the native 3D scene’s rotation/presentation behavior, but also gain a left-side control panel in the hybrid scene itself, using the AeroBeat image / Hybrid background options from the 2D scene. Those controls should drive the shader/material values of the separate 2D subviewport source scene so the 3D panel can be fine-tuned live.

To keep this inspectable, the hybrid path should be split into two layers:
- a dedicated standalone 2D source scene used as the `SubViewport` content, so the unobstructed 2D panel can be inspected on its own
- the 3D hybrid wrapper scene, which shows a left-side control panel plus the 3D panel in space and forwards control changes into the subviewport scene

That gives us a direct A/B between:
- original 2D shader on a 3D GUI panel system
- new dedicated 3D shader on a real 3D panel

The scene should preserve inspectability: it should clearly show that the original 2D shader is still being used, provide useful 2D-style tuning/verification controls, expose the background mode switching in the hybrid wrapper, and still include the real 3D rotation option so the panel can be inspected in space.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Original 2D shader file | `/home/derrick/Documents/projects/aerobeat/aerobeat-ui-kit-community/.testbed/assets/shaders/glass-shader.gdshader` |
| `REF-02` | Original 2D glass test scene | `/home/derrick/Documents/projects/aerobeat/aerobeat-ui-kit-community/.testbed/scenes/glass-shader-test.tscn` |
| `REF-03` | Current 2D controller | `/home/derrick/Documents/projects/aerobeat/aerobeat-ui-kit-community/.testbed/scripts/glass_shader_test.gd` |
| `REF-04` | New native 3D shader scene | `/home/derrick/Documents/projects/aerobeat/aerobeat-ui-kit-community/.testbed/scenes/glass-shader-3d-test.tscn` |
| `REF-05` | New native 3D shader file | `/home/derrick/Documents/projects/aerobeat/aerobeat-ui-kit-community/.testbed/assets/shaders/glass-panel-3d.gdshader` |
| `REF-06` | Shader usage doc | `/home/derrick/Documents/projects/aerobeat/aerobeat-ui-kit-community/docs/glass-shader-usage.md` |
| `REF-07` | Target testbed root | `/home/derrick/Documents/projects/aerobeat/aerobeat-ui-kit-community/.testbed/` |

---

## Tasks

### Task 1: Build a 3D GUI panel example that reuses the original 2D glass shader

**Bead ID:** `aerobeat-ui-kit-community-51v`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-06`, `REF-07`  
**Prompt:** In `/home/derrick/Documents/projects/aerobeat/aerobeat-ui-kit-community`, claim bead `aerobeat-ui-kit-community-51v` with `bd update aerobeat-ui-kit-community-51v --status in_progress --json`. Build a new test scene that reuses the original 2D glass shader through Godot’s 3D GUI panel workflow. Use the 2D scene’s background image and tuning/options style, but give the scene the real 3D rotation/presentation behavior of the native 3D scene so it can be inspected from different angles. Keep it truthful and clearly distinct from the dedicated native 3D shader path. Close the bead with a clear reason when done.

**Folders Created/Deleted/Modified:**
- `.testbed/scenes/`
- `.testbed/scripts/`
- `.testbed/assets/` if needed

**Files Created/Deleted/Modified:**
- new 3D GUI panel test scene file(s)
- any supporting scripts/resources

**Status:** ✅ Complete

**Results:** Built the hybrid 3D GUI panel path using a truthful SubViewport-backed approach. The new scene at `.testbed/scenes/glass-shader-gui-3d-test.tscn` instantiates the original 2D glass tester, renders it into a `SubViewport`, maps that texture onto a `QuadMesh` in 3D, and adds a thin `BoxMesh` shell so the panel reads as a real object in space. The original 2D shader remains the actual glass effect source. A new wrapper script adds native-3D-style rotation behavior and `1/2/3` shortcuts for the embedded scene’s background modes, and the original 2D controller was extended with public background-mode setters/getters so the wrapper can drive it without duplicating 2D logic.

---

### Task 2: QA the 3D GUI panel scene for truthful 2D-shader reuse and 3D presentation

**Bead ID:** `aerobeat-ui-kit-community-yjw`  
**SubAgent:** `primary` (for `qa` workflow role)  
**Role:** `qa`  
**References:** `REF-01`, `REF-02`, `REF-07`  
**Prompt:** In `/home/derrick/Documents/projects/aerobeat/aerobeat-ui-kit-community`, claim bead `aerobeat-ui-kit-community-yjw` with `bd update aerobeat-ui-kit-community-yjw --status in_progress --json`. QA the new 3D GUI panel scene live. Verify that it really reuses the original 2D shader path, really presents as a 3D panel with working rotation, and really keeps the 2D scene’s background image/options style. Capture evidence and close the bead with a precise pass/fail reason.

**Folders Created/Deleted/Modified:**
- `.testbed/`

**Files Created/Deleted/Modified:**
- QA evidence artifacts if produced

**Status:** ✅ Complete

**Results:** QA passed in a live rendered session. Verified that the new scene really instantiates the original 2D glass test scene and reuses the original `canvas_item` shader path, while presenting that result through a SubViewport-backed 3D panel with working rotation. The embedded panel preserved the 2D scene’s AeroBeat image, Debug Pattern, Hybrid Overlay modes, and left-side control layout. Evidence was captured in app_userdata under `qa_glass_gui_3d`.

---

### Task 3: Audit the new 3D GUI panel scene against the request and repo truthfulness

**Bead ID:** `aerobeat-ui-kit-community-524`  
**SubAgent:** `primary` (for `auditor` workflow role)  
**Role:** `auditor`  
**References:** `REF-01`, `REF-04`, `REF-07`  
**Prompt:** In `/home/derrick/Documents/projects/aerobeat/aerobeat-ui-kit-community`, claim bead `aerobeat-ui-kit-community-524` with `bd update aerobeat-ui-kit-community-524 --status in_progress --json`. Audit the new 3D GUI panel scene independently. Confirm it truthfully satisfies the request for the original 2D shader on a 3D GUI panel workflow, with the 2D scene’s background/options feel and the 3D scene’s rotation/presentation behavior, without confusing it with the native 3D shader path. Close the bead only if the result is accurate and complete.

**Folders Created/Deleted/Modified:**
- `TBD`

**Files Created/Deleted/Modified:**
- `TBD`

**Status:** ✅ Complete

**Results:** Final audit passed. Verified that the original 2D shader path is still the actual effect source, the panel is presented as a rotating 3D GUI panel through a SubViewport-backed workflow, the 2D scene’s background/options feel is preserved, and the result remains clearly distinct from the native 3D shader path.

---

### Task 4: Refactor the hybrid path into a dedicated 2D source scene plus a left-side control panel in the 3D wrapper

**Bead ID:** `aerobeat-ui-kit-community-ys6`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-06`, `REF-07`  
**Prompt:** In `/home/derrick/Documents/projects/aerobeat/aerobeat-ui-kit-community`, claim bead `aerobeat-ui-kit-community-ys6` with `bd update aerobeat-ui-kit-community-ys6 --status in_progress --json`. Refactor the hybrid path so it uses a dedicated standalone 2D source scene as the SubViewport content, and add a left-side control panel directly in the 3D wrapper scene. The wrapper should expose the AeroBeat image / Hybrid background options and forward tuning changes into the shader/material values of the 2D source scene so the 3D panel updates live. Keep the hybrid path truthful and clearly distinct from the native 3D shader path. Close the bead with a clear reason when done.

**Folders Created/Deleted/Modified:**
- `.testbed/scenes/`
- `.testbed/scripts/`

**Files Created/Deleted/Modified:**
- hybrid 3D GUI panel scene
- new dedicated 2D subviewport source scene
- supporting scripts/resources

**Status:** ⏳ Pending

**Results:** Derrick requested that the hybrid scene itself gain a left-side tuning panel using the AeroBeat image / Hybrid options, that a separate standalone 2D glass-panel scene be created as the subviewport source so the unobstructed 2D panel can be inspected directly, and that the hybrid scene forward those control values into the shader/material used by the subviewport content.

---

### Task 5: QA the refactored hybrid scene and standalone 2D source scene

**Bead ID:** `aerobeat-ui-kit-community-4b7`  
**SubAgent:** `primary` (for `qa` workflow role)  
**Role:** `qa`  
**References:** `REF-01`, `REF-02`, `REF-07`  
**Prompt:** In `/home/derrick/Documents/projects/aerobeat/aerobeat-ui-kit-community`, claim bead `aerobeat-ui-kit-community-4b7` with `bd update aerobeat-ui-kit-community-4b7 --status in_progress --json`. QA the refactored hybrid scene and the standalone 2D source scene. Verify the unobstructed 2D scene renders correctly on its own, the hybrid scene’s left-side controls drive the 2D source shader/material values live, the AeroBeat/Hybrid background options work, and the 3D presentation/rotation behavior still works. Capture evidence and close the bead with a precise pass/fail reason.

**Folders Created/Deleted/Modified:**
- `.testbed/`

**Files Created/Deleted/Modified:**
- QA evidence artifacts if produced

**Status:** ⏳ Pending

**Results:** Not started.

---

### Task 6: Audit the refactored hybrid path for truthfulness and control forwarding correctness

**Bead ID:** `aerobeat-ui-kit-community-tca`  
**SubAgent:** `primary` (for `auditor` workflow role)  
**Role:** `auditor`  
**References:** `REF-01`, `REF-04`, `REF-07`  
**Prompt:** In `/home/derrick/Documents/projects/aerobeat/aerobeat-ui-kit-community`, claim bead `aerobeat-ui-kit-community-tca` with `bd update aerobeat-ui-kit-community-tca --status in_progress --json`. Audit the refactored hybrid path independently. Confirm that the standalone 2D source scene is the actual subviewport content, that the wrapper controls really forward values into that source scene, that the background options behave correctly, and that the scene remains clearly distinct from the native 3D shader path. Close the bead only if the result is accurate and complete.

**Folders Created/Deleted/Modified:**
- `TBD`

**Files Created/Deleted/Modified:**
- `TBD`

**Status:** ⏳ Pending

**Results:** Not started.

---

### Task 7: Restore the left-side shader controls in `glass-shader-test.tscn`

**Bead ID:** `aerobeat-ui-kit-community-i3x`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-07`  
**Prompt:** In `/home/derrick/Documents/projects/aerobeat/aerobeat-ui-kit-community`, claim bead `aerobeat-ui-kit-community-i3x` with `bd update aerobeat-ui-kit-community-i3x --status in_progress --json`. Repair the regression where `glass-shader-test.tscn` no longer shows the shader controls on the left side. Restore the original 2D tester usability while preserving the shared-source refactor, and also add a no-background mode to the hybrid 3D GUI path so the subviewport panel can be viewed without its own internal backdrop. Keep the fixes truthful and clearly distinct from the native 3D shader path. Close the bead with a clear reason when done.

**Folders Created/Deleted/Modified:**
- `.testbed/scenes/`
- `.testbed/scripts/`

**Files Created/Deleted/Modified:**
- `.testbed/scenes/glass-shader-test.tscn`
- `.testbed/scripts/glass_shader_test.gd`
- `.testbed/scripts/glass_shader_panel_source.gd` if needed

**Status:** ✅ Complete

**Results:** Restored the practical usability of `glass-shader-test.tscn` by clipping the shared preview host so the mounted source scene stays confined to the right pane, which keeps the left-side controls visible again. Also added `No background` as shared background mode `3`, exposed it in both the standalone 2D tester and the hybrid 3D wrapper, and wired keyboard `4` in the hybrid wrapper to select it.

---

### Task 8: Add a no-background mode to `glass-shader-gui-3d-test.tscn`

**Bead ID:** `Pending`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-04`, `REF-07`  
**Prompt:** Pending until plan approval.

**Folders Created/Deleted/Modified:**
- `.testbed/scenes/`
- `.testbed/scripts/`

**Files Created/Deleted/Modified:**
- `.testbed/scenes/glass-shader-gui-3d-test.tscn`
- `.testbed/scripts/glass_shader_gui_3d_test.gd`
- `.testbed/scripts/glass_shader_panel_source.gd` if needed

**Status:** ⏳ Pending

**Results:** Derrick wants an option to display the subviewport source panel with no internal background so we can see whether the subviewport panel’s glass rendering meaningfully shows the 3D world/wallpaper behind it in `glass-shader-gui-3d-test.tscn`.

---

### Task 9: QA the regression fix and no-background hybrid option

**Bead ID:** `aerobeat-ui-kit-community-0ap`  
**SubAgent:** `primary` (for `qa` workflow role)  
**Role:** `qa`  
**References:** `REF-01`, `REF-02`, `REF-04`, `REF-07`  
**Prompt:** In `/home/derrick/Documents/projects/aerobeat/aerobeat-ui-kit-community`, claim bead `aerobeat-ui-kit-community-0ap` with `bd update aerobeat-ui-kit-community-0ap --status in_progress --json`. QA the restored 2D controls and the new no-background hybrid option. Verify that `glass-shader-test.tscn` again shows the left-side shader controls, that the hybrid scene offers a mode where the subviewport panel has no internal background, and that this mode usefully reveals whether the 2D shader effect shows the 3D world behind the panel. Capture evidence and close the bead with a precise pass/fail reason.

**Folders Created/Deleted/Modified:**
- `.testbed/`

**Files Created/Deleted/Modified:**
- QA evidence artifacts if produced

**Status:** ⏳ Pending

**Results:** Not started.

---

### Task 10: Audit the restored 2D controls and no-background 3D GUI-panel mode

**Bead ID:** `aerobeat-ui-kit-community-duq`  
**SubAgent:** `primary` (for `auditor` workflow role)  
**Role:** `auditor`  
**References:** `REF-01`, `REF-02`, `REF-04`, `REF-07`  
**Prompt:** In `/home/derrick/Documents/projects/aerobeat/aerobeat-ui-kit-community`, claim bead `aerobeat-ui-kit-community-duq` with `bd update aerobeat-ui-kit-community-duq --status in_progress --json`. Audit the restored 2D controls and the no-background hybrid mode independently. Confirm the 2D tester regression is actually fixed, and confirm the no-background hybrid mode truthfully reveals whether the subviewport path shows the 3D world behind the panel or not. Close the bead only if the result is accurate and complete.

**Folders Created/Deleted/Modified:**
- `TBD`

**Files Created/Deleted/Modified:**
- `TBD`

**Status:** ⏳ Pending

**Results:** Not started.

---

## Final Results

**Status:** ✅ Complete

**What We Built:** Added a new hybrid test scene that routes the original 2D glass shader through Godot’s 3D GUI panel workflow. The new scene lives at `.testbed/scenes/glass-shader-gui-3d-test.tscn` and uses the original 2D glass tester scene rendered into a `SubViewport`, mapped onto a 3D panel in space, with a thin `BoxMesh` shell behind it for real object presence. It preserves the 2D scene’s background image, Debug Pattern, Hybrid Overlay modes, and left-side control layout, while adding the native 3D scene’s rotation/presentation behavior for spatial inspection.

**Reference Check:** `REF-01` through `REF-07` satisfied. The implementation is truthful about being the “original 2D shader on a 3D GUI panel system” path and not the same thing as the dedicated native 3D shader scene.

**Commits:**
- None yet.

**Lessons Learned:** This scene is most useful as an A/B comparison path. It demonstrates that the original 2D shader can be embedded truthfully into a 3D GUI panel workflow, while remaining architecturally and visually distinct from a native 3D glass shader/material path.

---

*Completed on 2026-05-11*
