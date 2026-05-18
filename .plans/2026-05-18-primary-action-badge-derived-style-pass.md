# AeroBeat UI Kit Community — Primary Action Badge-Derived Style Pass

**Date:** 2026-05-18  
**Status:** In Progress  
**Agent:** Cookie 🍪

---

## Goal

Restyle the `PrimaryActionButton` in `glass-shader-panel-source.tscn` so it more clearly derives from the existing `Badge` visual language while still behaving like a usable action button over hybrid glass panels.

---

## Overview

Derrick likes the existing `Badge` treatment in the shared glass panel source scene and wants the primary action to borrow that family resemblance. The right implementation is not to make the action identical to the badge at all times, because the primary action still needs to read as clickable and carry hover/pressed/toggled affordances. Instead, the visual base should become a stretched, action-capable badge/chip: same family of corner radius, padding philosophy, softer fill/border recipe, and label treatment, with stateful emphasis layered on top.

This repo already drives the action style mostly from script rather than static scene styles, so the main implementation work belongs in `glass_shader_panel_source.gd`, with scene defaults adjusted only where they support the intended resting shape and typography. QA should verify that the result still reads like a button, still looks coherent with the badge, and still holds up in hybrid world-space presentation.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Shared glass panel source scene | `.testbed/scenes/glass-shader-panel-source.tscn` |
| `REF-02` | Shared glass panel source script | `.testbed/scripts/glass_shader_panel_source.gd` |
| `REF-03` | Existing badge node/style in the source scene | `.testbed/scenes/glass-shader-panel-source.tscn` |
| `REF-04` | Prior hybrid alignment/parity fix plan/history | `.plans/2026-05-18-hybrid-glass-gui-panel-alignment-and-button-parity.md` |

---

## Tasks

### Task 1: Audit the current badge-vs-action styling gap

**Bead ID:** `aerobeat-ui-kit-community-0cn`  
**SubAgent:** `primary` (for `research` workflow role)  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, inspect the current `Badge` and `PrimaryActionButton` styling in the shared glass panel source scene/script and identify the minimum set of shape, padding, alpha, border, and typography changes needed to make the primary action feel badge-derived while still clearly button-like in hybrid glass presentation.

**Folders Created/Deleted/Modified:**
- optional `.temp/`

**Files Created/Deleted/Modified:**
- `.temp/aerobeat-ui-kit-community-0cn-badge-vs-primary-action-style-gap.md`

**Status:** ✅ Complete

**Results:** Research confirmed that the main gap is token drift, not scene structure. The `Badge` is already a compact glass pill (`PanelContainer -> MarginContainer -> Label`) with explicit hybrid tuning tokens, while the `PrimaryActionButton` is a proper `Button` with child meta label but has been styled from a separate chip family rather than a scaled-up badge family. The recommended implementation path is to keep the existing button structure, stop treating `StyleBoxFlat_chip_panel` as the real source of truth, and instead generate the button from the same white-glass badge token family with scaled-up affordance values for button use. Notes were written to `.temp/aerobeat-ui-kit-community-0cn-badge-vs-primary-action-style-gap.md`.

---

### Task 2: Implement a badge-derived primary action style

**Bead ID:** `aerobeat-ui-kit-community-v9n`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, restyle the `PrimaryActionButton` so it visibly derives from the `Badge` style while remaining clearly clickable and usable as the primary action in both the source scene and hybrid world-space presentation. Prefer using the badge’s style language as the base and layering button states on top. Run relevant validation, then commit and push to `main` by default.

**Folders Created/Deleted/Modified:**
- `.testbed/scenes/`
- `.testbed/scripts/`
- optional `.testbed/tests/`

**Files Created/Deleted/Modified:**
- `.testbed/scenes/glass-shader-panel-source.tscn`
- `.testbed/scripts/glass_shader_panel_source.gd`

**Status:** ✅ Complete

**Results:** Implementation landed and was pushed to `main` in commit `b37760e` (`Derive primary action styling from badge tokens`). The primary action is now generated from the same badge token family rather than from a separate scene-authored chip style: badge fill/border/label baselines are used in both 2D and hybrid modes, then scaled up with button-specific deltas for radius, border width, padding, and hover/pressed/toggled emphasis. The old `StyleBoxFlat_chip_panel` scene resource and scene-level normal/hover/pressed stylebox bindings were removed so the button no longer pretends to come from a separate component family. Validation passed via headless import, headless runs of the 2D and hybrid test scenes, `git diff --check`, and a one-off derivation validator confirming the button style remains badge-derived in both presentation modes.

---

### Task 3: QA the badge-derived button style in source and hybrid presentation

**Bead ID:** `aerobeat-ui-kit-community-ofr`  
**SubAgent:** `primary` (for `qa` workflow role)  
**Role:** `qa`  
**References:** `REF-01`, `REF-02`, `REF-03`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, verify that the `PrimaryActionButton` now feels visually derived from the `Badge` while still reading clearly as a button in both the source scene and the hybrid 3D presentation. Check resting state, hover/pressed/toggled readability, and whether the action still feels visually prominent enough to remain the primary button.

**Folders Created/Deleted/Modified:**
- optional `.temp/qa-evidence/`

**Files Created/Deleted/Modified:**
- `.temp/qa-evidence/primary-action-badge-derived-2026-05-18/` (rendered source/hybrid captures, report, summary)

**Status:** ✅ Complete

**Results:** QA approved the badge-derived button style. Rendered capture passes against both the source panel scene and the hybrid 3D scene confirmed that the `PrimaryActionButton` now reads as a scaled-up sibling of the `Badge` rather than a separate component family, and that this family resemblance holds in both presentations. QA also confirmed the action still reads clearly as primary at rest, pressed, and toggled; the brighter 2D white-glass treatment does not appear washed out; the meta label remains readable but subordinate; and no blocking interaction regression was visible. QA noted that hover feedback and the tiny pressed-scale effect are subtler in full-scene captures than stronger state changes, but still approved completion.

---

### Task 4: Independent audit of the badge-derived button result

**Bead ID:** `aerobeat-ui-kit-community-s54`  
**SubAgent:** `primary` (for `auditor` workflow role)  
**Role:** `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, independently audit the final badge-derived `PrimaryActionButton` styling. Confirm it clearly inherits from the `Badge` family, still reads as a real primary action button, and does not regress the hybrid scene’s overall visual clarity.

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
