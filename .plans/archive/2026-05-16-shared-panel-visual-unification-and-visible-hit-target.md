# AeroBeat UI Kit Community

**Date:** 2026-05-16  
**Status:** Stale  
**Agent:** Byte 🐈‍⬛

---

## Goal

Unify the shared glass panel visuals across 2D and 3D test scenes by removing `SecondaryToggleChip`, keeping the panel body copy visually consistent between scenes, and replacing the effectively invisible middle hit target with a visible glass button that lives in the shared subviewport panel scene.

---

## Overview

Derrick’s feedback points at three related cleanup/design issues in the testbed. First, `SecondaryToggleChip` should be removed from the shared panel source scene entirely. Second, the glass panel body copy should stop mutating into alternate text during interaction; the panel should look basically the same visually whether it is rendered in the 2D or 3D scene. Third, the current middle interaction target is functionally invisible during testing, which makes mouse-alignment debugging harder than it needs to be. The requested direction is to make that central target visibly present on the glass panel itself so human testing can compare the pointer to a real visible interactive affordance.

The current scene/script scan shows these concerns are rooted in the shared source panel, not only the host scenes. `SecondaryToggleChip` is still authored in `glass-shader-panel-source.tscn` and heavily referenced in `glass_shader_panel_source.gd`. The primary panel text changes are also driven from that shared script, where badge/headline/body content currently react to toggle state. And the host scenes target `PrimaryCardButton`, which is structurally present but visually framed in a way that is still reading as an invisible middle hit area during testing. So the right slice is to modify the shared panel scene/script first, then keep the 2D and 3D host scenes consuming the same underlying visible panel affordance rather than inventing separate overlays.

This plan should stay narrow and practical: remove the secondary chip lane, preserve a stable shared visual identity for the glass card across scenes, and make the primary interactable visibly obvious on the shared panel so pointer-vs-target alignment can be tested honestly in both 2D and 3D. The implementation should then be validated in the testbed and committed normally.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Shared panel source scene | `.testbed/scenes/glass-shader-panel-source.tscn` |
| `REF-02` | Shared panel source script | `.testbed/scripts/glass_shader_panel_source.gd` |
| `REF-03` | 2D test scene host script using the shared panel | `.testbed/scripts/glass_shader_test.gd` |
| `REF-04` | 3D test scene host script using the shared panel | `.testbed/scripts/glass_shader_gui_3d_test.gd` |
| `REF-05` | Derrick feedback in current session | current session request at 2026-05-16 14:51 EDT |

---

## Tasks

### Task 1: Remove SecondaryToggleChip and unify the shared panel visuals around one visible primary control

**Bead ID:** `aerobeat-ui-kit-community-5jc`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, remove `SecondaryToggleChip` from `glass-shader-panel-source.tscn` and delete/refactor all script references to it in `glass_shader_panel_source.gd`. Also stop the shared panel body copy from changing to alternate interaction text so the glass panel looks basically the same in every scene. Finally, make the middle/primary interactable visibly present as a glass button on the shared panel scene itself so the 2D and 3D test scenes both show the same visible hit target through the subviewport. Keep the implementation narrow, validate it, and commit/push before handoff unless concretely blocked.

**Folders Created/Deleted/Modified:**
- `.testbed/scenes/`
- `.testbed/scripts/`
- `.plans/`

**Files Created/Deleted/Modified:**
- `.testbed/scenes/glass-shader-panel-source.tscn`
- `.testbed/scripts/glass_shader_panel_source.gd`
- any host-script touch-ups only if strictly required by the shared panel change

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