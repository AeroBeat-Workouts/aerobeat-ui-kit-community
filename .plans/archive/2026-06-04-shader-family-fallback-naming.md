# AeroBeat UI Kit Community — Shader-Family Fallback Naming Cleanup

**Date:** 2026-06-04  
**Status:** Complete  
**Last Updated:** 2026-06-04 22:29 EDT  
**Blocked Reason:** None  
**Agent:** `byte`

---

## Goal

Remove the remaining generic fallback naming and compatibility/legacy seams so the live 2D and hybrid glass paths are shader-family oriented end-to-end, then follow that cleanup by addressing the save/load ownership UI and bug seams.

---

## Overview

The prior slice established the major shader-family naming split: `2d-glass-shader.gdshader`, `3d-glass-panel.gdshader`, and `3d-glass-ui.gdshader`, plus clearer example separation. Derrick’s next goal was to finish that clarity pass by removing generic fallback names where they still obscured ownership, and by making a clean break from compatibility wrappers and legacy entrypoints instead of keeping them around.

This cleanup now makes it obvious which config/preset/runtime entrypoint maps to which shader family or example path. The end state is that a person browsing the repo can immediately tell whether a file belongs to the 2D screen-space glass path or the 3D hybrid glass path. With that naming/ownership cleanup landed and verified, the next planned seam is the save/load ownership UI and bug work, where the editor controls should map cleanly to the real owning config/runtime state.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Current shader-family usage guide | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/.testbed/docs/glass-shader-usage.md` |
| `REF-02` | Current hybrid host controller | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/.testbed/scripts/glass_shader_gui_3d_test.gd` |
| `REF-03` | Current 2D host controller | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/.testbed/scripts/glass_shader_test.gd` |
| `REF-04` | Current canonical hybrid panel view | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/.testbed/ui/views/aero_ui_glass_panel_view.tscn` |
| `REF-05` | Current dedicated 2D panel source/view path | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/.testbed/ui/views/screen_2d_glass_panel_view.tscn` |
| `REF-06` | Current preset/readme naming truth | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/.testbed/ui/presets/glass/README.md` |

---

## Tasks

### Task 1: Remove generic fallback naming and legacy compatibility seams

**Bead ID:** `aerobeat-ui-kit-community-c48`  
**SubAgent:** `primary` (for `coder`)  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`, `REF-06`  
**Prompt:** Remove the remaining generic fallback naming and compatibility/legacy seams in aerobeat-ui-kit-community so the live runtime/config entrypoints are shader-family oriented and explicit. Derrick wants clean breaks, not compatibility shims. Update live source, preset/config names, docs, tests, and host references as needed so the 2D path and the hybrid 3D path are clearly separate and do not rely on generic `default` or legacy alias ownership language where avoidable. Keep the slice focused on naming/ownership clarity rather than widening into the save/load bug fixes yet. Run relevant repo-local validation, then commit and push by default before handoff.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/.testbed/`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/assets/shaders/`

**Files Created/Deleted/Modified:**
- live preset/config/runtime/doc/test files directly affected by removal of generic fallback naming and compatibility wrappers
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/.plans/2026-06-04-shader-family-fallback-naming.md`

**Status:** ✅ Complete

**Results:** Completed in commit `105f481` (`Remove shader-family fallback naming seams`). The coder removed the old runtime/scene alias paths entirely, removed legacy-path tests that existed only to prove those aliases, rewired live hosts to explicit runtime entrypoints, moved presets to shader-family folders (`screen-2d/` and `hybrid-3d/`), and deleted generic/fuzzy preset names. Follow-up fix commits `4ce86ff` and `7a00533` repaired a YAML smoke test parse/runtime regression exposed by the cleanup without reintroducing shims.

---

### Task 2: QA shader-family runtime/config naming cleanup

**Bead ID:** `aerobeat-ui-kit-community-lwx`  
**SubAgent:** `primary` (for `qa`)  
**Role:** `qa`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`, `REF-06`  
**Prompt:** Verify the naming cleanup truthfully removes generic fallback/legacy ambiguity. Confirm the live runtime/config entrypoints are shader-family oriented, that the 2D and hybrid paths remain loadable, and that no accidental path regressions were introduced. Call out any residual generic or legacy ownership language still visible in live source.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/.plans/`

**Files Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/.plans/2026-06-04-shader-family-fallback-naming.md`

**Status:** ✅ Complete

**Results:** QA initially found two cleanup leftovers: a parse/type inference failure in `.testbed/tests/ui/test_aero_ui_glass_panel_view_yaml_smoke.gd` and lingering orphan legacy-named `.uid` files for removed panel-source paths. Both were fixed in follow-up commits `4ce86ff` (`Fix glass panel YAML smoke test typing`) and `7a00533` (`Fix glass panel YAML smoke runtime assertions`). Final QA rerun passed: `16/16` changed-scope UI tests passed, explicit shader-family entrypoints remained intact, removed legacy test/shim files were absent, and no live-source references remained to older generic preset filenames or removed compatibility paths.

---

### Task 3: Audit final shader-family naming state and queue save/load seam

**Bead ID:** `aerobeat-ui-kit-community-svk`  
**SubAgent:** `primary` (for `auditor`)  
**Role:** `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`, `REF-06`  
**Prompt:** Independently truth-check the final shader-family naming state after the cleanup. Confirm the compatibility shims are gone or acceptably removed, that the live paths are shader-family explicit, and that the next seam should now cleanly be the save/load ownership UI/bug pass. No code changes.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/.plans/`

**Files Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/.plans/2026-06-04-shader-family-fallback-naming.md`

**Status:** ✅ Complete

**Results:** Independent audit passed. The cleanup achieved the intended clarity goal: explicit runtime entrypoints for 2D (`screen_2d_glass_panel_view` + `screen-2d/default.yaml`) and hybrid (`aero_ui_glass_panel_view` + `hybrid-3d/default.yaml`) are intact, the removed legacy panel-source files and orphan metadata are gone, and the changed-scope UI suite passes. Remaining ambiguity is minor and non-blocking: filenames like `default.yaml`, `badge.yaml`, and `primary-button.yaml` remain generic inside explicit family folders, but ownership is now carried clearly by the directory path and YAML variant.

---

## Final Results

**Status:** ✅ Complete

**What We Built:** Removed the remaining generic fallback naming and legacy compatibility seams from the live runtime/config layer so the repo now exposes clean shader-family runtime ownership. The 2D screen-space path and hybrid 3D path now have explicit family-owned entrypoints, legacy panel-source wrapper/shim paths are gone, old generic preset entrypoints are gone, and the canonical changed-scope UI suite passes after two narrow follow-up fixes.

**Reference Check:** `REF-01` through `REF-06` were used to verify the live shader-family docs, hosts, views, and preset naming truth. No deliberate deviations.

**Commits:**
- `105f481` - Remove shader-family fallback naming seams
- `4ce86ff` - Fix glass panel YAML smoke test typing
- `7a00533` - Fix glass panel YAML smoke runtime assertions

**Lessons Learned:** Shader/path naming clarity alone is not enough; tests and runtime views can still encode ownership assumptions that surface only after the naming cleanup. With the naming seam now truthfully closed, the next slice should focus on save/load ownership UI and bugs so editor controls, exported bundles, and loaded runtime state all map to the same real owner.

---

*Completed on 2026-06-04*
