# AeroBeat UI Kit Community

**Date:** 2026-05-16  
**Status:** Stale  
**Agent:** Byte 🐈‍⬛

---

## Goal

Remove the requested proof/debug UI sections from the shared panel scene and both test scenes, then clean the scripts so no deleted nodes or removed verification text are still referenced.

---

## Overview

This is a focused cleanup pass across the hidden UI-kit testbed. Derrick’s requested scope is explicit: strip several proof/debug presentation sections out of `glass-shader-panel-source.tscn`, remove the verification/debug copy from the 2D and 3D test scenes, and make sure the corresponding scripts no longer look up or write to deleted nodes. The goal is not to redesign interaction behavior or revisit the hybrid click bug in this slice; it is to clean the authored testbed UI and keep the scene/script contracts consistent afterward.

The affected files are already clear from the current scene/script grep pass. `glass_shader_panel_source.gd` still references `InteractionStatePanel`, `HintLabel`, `BottomSpacer`, `DragStrip`, and `HybridSummaryPanel` plus their child labels. `glass_shader_test.gd` and `glass_shader_gui_3d_test.gd` still render the verification lines and the host-owned-truth explainer text in their status rails. So the work should be a narrow coder-only scene/script cleanup with one implementation bead, leaving QA/audit out unless Derrick asks for them later.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Shared panel source scene with removable sections | `.testbed/scenes/glass-shader-panel-source.tscn` |
| `REF-02` | Shared panel source script with node references to delete | `.testbed/scripts/glass_shader_panel_source.gd` |
| `REF-03` | 2D test scene script with removable proof/debug text | `.testbed/scripts/glass_shader_test.gd` |
| `REF-04` | 3D test scene script with removable proof/debug text | `.testbed/scripts/glass_shader_gui_3d_test.gd` |
| `REF-05` | Derrick feedback in current session | current session request at 2026-05-16 13:55 EDT |

---

## Tasks

### Task 1: Remove requested proof/debug UI sections and dead references

**Bead ID:** `aerobeat-ui-kit-community-268`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, implement Derrick’s requested cleanup exactly. In `glass-shader-panel-source.tscn`, delete `InteractionStatePanel`, `HintLabel`, `BottomSpacer`, `DragStrip`, and `HybridSummaryPanel`, then remove or refactor all script references in `glass_shader_panel_source.gd` so the deleted UI is no longer used. In the 2D and 3D test scenes/scripts, remove the requested proof/debug text: the host-owned-truth explainer line in the 2D test scene, the `Verification` and `Verification notes` lines in the 2D test scene, and the same proof/debug sections from the 3D test scene as from the 2D test scene. Keep the change narrowly scoped, validate that the scripts no longer reference deleted nodes/text, and commit/push before handoff unless concretely blocked.

**Folders Created/Deleted/Modified:**
- `.testbed/scenes/`
- `.testbed/scripts/`
- `.plans/`

**Files Created/Deleted/Modified:**
- `.testbed/scenes/glass-shader-panel-source.tscn`
- `.testbed/scripts/glass_shader_panel_source.gd`
- `.testbed/scripts/glass_shader_test.gd`
- `.testbed/scripts/glass_shader_gui_3d_test.gd`

**Status:** ⏳ Pending

**Results:** Pending.

---

## Final Results

**Status:** ⏳ Pending

**What We Built:** Pending execution.

**Reference Check:** Pending execution.

**Commits:**
- Pending

**Lessons Learned:** Pending execution.

---

*Drafted on 2026-05-16*