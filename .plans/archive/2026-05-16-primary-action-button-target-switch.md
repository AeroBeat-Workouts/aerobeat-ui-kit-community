# AeroBeat UI Kit Community

**Date:** 2026-05-16  
**Status:** Complete  
**Agent:** Byte 🐈‍⬛

---

## Goal

Make `PrimaryActionButton` the actual interaction contract target instead of just a visible affordance layered inside `PrimaryCardButton`.

---

## Overview

Derrick clarified the intended behavior: the visible centered `PrimaryActionButton` should not merely mirror the state of a larger hidden parent hit area. It should be the real target. That means the shared panel source needs to move the primary contract binding and cursor semantics onto `PrimaryActionButton`, then ensure the surrounding content/decorative nodes do not steal hover/cursor behavior or create conflicting hit truth.

This slice should stay narrow and truthful. We are not redesigning the full hybrid input system here. We are switching the shared source’s primary target from `PrimaryCardButton` to `PrimaryActionButton`, then making the related cursor/interaction configuration coherent so both the 2D and 3D test scenes inherit the same visible target through the shared subviewport. If host scripts need small follow-up changes because they assume the old path, those should be limited to what is necessary for the target switch.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Shared panel source scene | `.testbed/scenes/glass-shader-panel-source.tscn` |
| `REF-02` | Shared panel source script | `.testbed/scripts/glass_shader_panel_source.gd` |
| `REF-03` | 2D test scene host script | `.testbed/scripts/glass_shader_test.gd` |
| `REF-04` | 3D test scene host script | `.testbed/scripts/glass_shader_gui_3d_test.gd` |
| `REF-05` | Derrick clarification in current session | current session request at 2026-05-16 16:55 EDT |

---

## Tasks

### Task 1: Switch the primary contract target to `PrimaryActionButton`

**Bead ID:** `aerobeat-ui-kit-community-kka`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, make `PrimaryActionButton` the real primary interaction contract target instead of `PrimaryCardButton`. Update the shared panel source scene/script so the visible center button owns the target path/cursor semantics, and ensure surrounding decorative/content nodes do not create conflicting hover/cursor behavior. Keep the change narrowly scoped, touch host scripts only if required by the path switch, validate lightly, and commit/push before handoff unless concretely blocked.

**Folders Created/Deleted/Modified:**
- `.testbed/scenes/`
- `.testbed/scripts/`
- `.plans/`

**Files Created/Deleted/Modified:**
- `.testbed/scenes/glass-shader-panel-source.tscn`
- `.testbed/scripts/glass_shader_panel_source.gd`
- host scripts only if strictly necessary

**Status:** ✅ Complete

**Results:** Coder switched the shared contract binding from `PrimaryCardButton` to `PrimaryActionButton`, moved cursor ownership to the visible center button, and made surrounding content ignore mouse filtering so it no longer steals hover/cursor behavior. The only required host-script adjustment was in `.testbed/scripts/glass_shader_test.gd`, which now points its proof-button path at `PrimaryActionButton`; the 3D host script needed no change because it resolves from shared target specs. Coder validation passed (`git diff --check`) and the change landed in commit `5f02f34` (`Switch panel contract target to primary action button`). QA then verified at runtime that the 2D host path publishes `PrimaryActionButton`, the shared binding target is really `PrimaryActionButton`, hover/press/release events resolve to that target, and motion/press outside the visible center button emits nothing. Independent audit passed and confirmed the scope stayed narrow across exactly three `.testbed/` files.

---

## Final Results

**Status:** ✅ Complete

**What We Built:** Made `PrimaryActionButton` the truthful primary contract target in the shared glass panel source, moved pointer/cursor truth to that visible center button, and aligned the 2D host path so both the visible affordance and the published interaction target now match.

**Reference Check:** `REF-01` and `REF-02` now bind/register the primary target on `PrimaryActionButton`; `REF-03` now publishes the 2D host path to that same target; `REF-04` remained unchanged because shared target-spec resolution already covered the 3D host path. Audit also confirmed surrounding content/decorative nodes no longer steal target/cursor truth.

**Commits:**
- `5f02f34` - Switch panel contract target to primary action button

**Lessons Learned:** When the visible center button is what humans use to judge pointer alignment, it should also be the real contract target. Keeping a larger invisible wrapper as the true target makes cursor truth, hover truth, and test evidence harder to reason about.

---

*Completed on 2026-05-16*