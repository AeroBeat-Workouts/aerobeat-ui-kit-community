# AeroBeat UI Kit Community — Hybrid Button Whiteout and Debug Panel Layout

**Date:** 2026-05-18  
**Status:** In Progress  
**Agent:** Cookie 🍪

---

## Goal

Fix the hybrid-scene primary action button whiteout issue and move the input debug printout below the shader-editor controls in both the hybrid and 2D scenes so the editor remains usable before the debug section.

---

## Overview

Derrick provided direct visual feedback from the current hybrid world-space scene: the primary action button is washed out/white in the hybrid presentation, and the left-side debug text occupies the panel area in a way that makes the shader-editor portion hard to access or read in order. This is exactly the kind of feedback that should override any “looks good in captured QA” assumption. The next step is to treat the screenshot and description as the source of truth and correct both the visual contrast issue and the control/debug panel layout hierarchy.

This slice still belongs to `aerobeat-ui-kit-community`, and it likely spans both the shared source panel styling/script and the test scenes/scripts that lay out the editor/debug panel. Implementation should specifically aim for a visibly readable hybrid button body/text balance and a control-panel ordering that puts shader editing first, then input/debug output below it in both the 2D and hybrid experiences.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Shared glass panel source scene | `.testbed/scenes/glass-shader-panel-source.tscn` |
| `REF-02` | Shared glass panel source script | `.testbed/scripts/glass_shader_panel_source.gd` |
| `REF-03` | Hybrid 3D GUI test scene | `.testbed/scenes/glass-shader-gui-3d-test.tscn` |
| `REF-04` | Hybrid 3D GUI test controller | `.testbed/scripts/glass_shader_gui_3d_test.gd` |
| `REF-05` | User-provided screenshot of current failure state | `/home/derrick/.openclaw/workspace/.temp/nerve-uploads/2026/05/18/image-81734571.png` |
| `REF-06` | Prior literal badge-button pass plan/history | `.plans/2026-05-18-primary-action-literal-badge-button-pass.md` |

---

## Tasks

### Task 1: Audit the hybrid whiteout and debug-panel layout problems

**Bead ID:** `aerobeat-ui-kit-community-ppm`  
**SubAgent:** `primary` (for `research` workflow role)  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`, `REF-06`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, inspect the current hybrid button styling and the 2D/hybrid control-panel layout. Use the provided screenshot and current scenes/scripts to determine why the primary action button is washing out to near-white in the hybrid scene, and why the debug text is positioned in a way that blocks the intended shader-editor-first workflow. Identify the exact files/nodes/layout structure and recommend the minimum safe fix path.

**Folders Created/Deleted/Modified:**
- optional `.temp/`

**Files Created/Deleted/Modified:**
- `.temp/aerobeat-ui-kit-community-ppm-research-report.md`

**Status:** ✅ Complete

**Results:** Research confirmed that the hybrid button whiteout is driven primarily by the hybrid startup preset/compositing path rather than by the shared button style alone. The hybrid default preset currently disables visible base UI contribution while redrawing the overlay at boosted alpha/brightness/tint, and the shared source button is already bright in hybrid mode, so the pill and its text blow toward white together. Research also confirmed that the hybrid left-rail debug block is outside the scroll container, unlike the better 2D pattern where debug/status is part of the scrollable control list. The minimum safe path is: fix the hybrid default preset first, lightly trim shared hybrid button fill only if still needed after that, and move the hybrid `StatusPanel` into the scroll flow so shader editing comes first and debug printouts follow below it. Notes were written to `.temp/aerobeat-ui-kit-community-ppm-research-report.md`.

---

### Task 2: Fix hybrid button readability and reorder debug output below shader editor

**Bead ID:** `aerobeat-ui-kit-community-t0c`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, fix the hybrid-scene primary action button so it is no longer washed out/white and remains legible over the glass panel, then reorder the 2D and hybrid editor/debug layout so the shader editing section comes first and the input debug printout appears below it. Preserve the current interaction behavior, run validation, then commit and push to `main` by default.

**Folders Created/Deleted/Modified:**
- `.testbed/scenes/`
- `.testbed/scripts/`
- optional `.testbed/tests/`

**Files Created/Deleted/Modified:**
- `.testbed/presets/glass/hybrid/default.json`
- `.testbed/scenes/glass-shader-gui-3d-test.tscn`
- `.testbed/scripts/glass_shader_gui_3d_test.gd`
- `.testbed/scripts/glass_shader_test.gd`

**Status:** ✅ Complete

**Results:** Implementation landed and was pushed to `main` in commit `7e27eeb` (`Fix hybrid glass button contrast and control ordering`). The fix targeted the actual root causes rather than changing the shared source button blindly: the hybrid default preset was rebalanced away from the over-bright overlay-only composite path so base UI contribution returns and overlay alpha/brightness/tint no longer blow the pill and label toward white; overly hot hybrid shell/body values were also toned down to restore contrast headroom. The hybrid layout was updated so the status/debug block is no longer a static panel outside the scroll area; instead, hybrid controls now follow the intended order of editor controls first and debug/status below in the scroll flow, matching the 2D host pattern. The 2D host script was also reordered so status/debug appears after the shader controls there as well. No shared-source button tweak was needed once the preset/composite path was corrected. Validation passed via headless scene runs for hybrid and 2D plus headless import.

---

### Task 3: QA hybrid readability and debug-panel ordering

**Bead ID:** `aerobeat-ui-kit-community-bq6`  
**SubAgent:** `primary` (for `qa` workflow role)  
**Role:** `qa`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, verify that the hybrid primary action button is no longer washed out and that the shader editor section now appears before the input debug printout in both the 2D and hybrid scenes. Confirm the ordering is actually usable for scrolling/reading and that the button remains readable and actionable.

**Folders Created/Deleted/Modified:**
- optional `.temp/qa-evidence/`

**Files Created/Deleted/Modified:**
- `.temp/qa-evidence/aerobeat-ui-kit-community-bq6/` (hybrid/2D startup, bottom, hover/press captures + results)

**Status:** ✅ Complete

**Results:** QA approved the fix after live Godot validation against both scenes. In the hybrid scene, QA confirmed that the primary action pill is no longer blown out white, the `PRIMARY TARGET` label and meta text are legible at startup, and the card still reads as glass rather than opaque flat white. QA also confirmed that the hybrid left rail now places shader/preset controls before debug/status and that the debug/status block is inside the scroll flow rather than pinned outside it. In the 2D scene, QA likewise confirmed shader controls appear before debug/status and that the ordering is usable for scrolling, reading, and editing. Hybrid target interaction remained intact under automated live mouse and touch validation.

---

### Task 4: Independent audit of readability and panel-order fix

**Bead ID:** `aerobeat-ui-kit-community-1au`  
**SubAgent:** `primary` (for `auditor` workflow role)  
**Role:** `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`, `REF-06`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, independently audit the finished fix. Confirm the hybrid button no longer whites out, the editor/debug ordering now puts shader editing before the debug printout in both scenes, and the result is genuinely verifiable on screen rather than just theoretically fixed in code.

**Folders Created/Deleted/Modified:**
- `.plans/` (results only if needed)

**Files Created/Deleted/Modified:**
- optional audit notes if needed

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

*Drafted on 2026-05-18*
