# AeroBeat UI Kit Community — Primary Action Literal Badge Button Pass

**Date:** 2026-05-18  
**Status:** In Progress  
**Agent:** Cookie 🍪

---

## Goal

Make the `PrimaryActionButton` in `glass-shader-panel-source.tscn` visually read like the existing `Badge` turned into a button, with a clearly visible badge-family silhouette and stronger primary-action affordance.

---

## Overview

The previous pass succeeded at making the button badge-derived in code, but Derrick’s direct visual check and the final audit both agreed that the rendered result did not look meaningfully different enough. The action still read too much like styled text with subtle state changes rather than a literal badge-family button. That means the next pass must optimize for visible outcome first: badge silhouette, badge-family fill/border recipe, and a clearly readable resting button boundary that can survive scene distance.

This pass should be stricter and more literal than the last one. The target is not “inspired by the badge”; it is “the badge promoted into a primary action button.” That means keeping the badge’s family identity obvious in the resting state, then layering stronger action affordance for hover/pressed/toggled states without drifting back into a generic chip or text-only look. QA and audit should judge the rendered result, not just the implementation story.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Shared glass panel source scene | `.testbed/scenes/glass-shader-panel-source.tscn` |
| `REF-02` | Shared glass panel source script | `.testbed/scripts/glass_shader_panel_source.gd` |
| `REF-03` | Existing badge node/style in the source scene | `.testbed/scenes/glass-shader-panel-source.tscn` |
| `REF-04` | Prior badge-derived pass plan/history | `.plans/2026-05-18-primary-action-badge-derived-style-pass.md` |
| `REF-05` | Prior hybrid alignment/parity plan/history | `.plans/2026-05-18-hybrid-glass-gui-panel-alignment-and-button-parity.md` |

---

## Tasks

### Task 1: Audit what must change to make the button literally read as a badge-family button

**Bead ID:** `aerobeat-ui-kit-community-syq`  
**SubAgent:** `primary` (for `research` workflow role)  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, inspect the current `Badge`, the current `PrimaryActionButton`, and the prior badge-derived pass. Identify the concrete visual reasons the result still reads like text with state rather than a literal badge-family button, and recommend the minimum set of visible changes needed to make the action obviously look like the badge turned into a button.

**Folders Created/Deleted/Modified:**
- optional `.temp/`

**Files Created/Deleted/Modified:**
- `.temp/aerobeat-ui-kit-community-syq-literal-badge-button-report.md`

**Status:** ✅ Complete

**Results:** Research confirmed the miss is primarily visible/rendered, not architectural: the button body is too faint at rest, its boundary blends into the parent glass card, its wide/airy layout reads like a CTA region rather than a promoted badge, and the centered two-line text composition makes it feel like styled card copy more than a button object. The minimum recommended fix is to strengthen the resting body/border substantially, reduce vertical slack, nudge radius closer to the badge family, and make the meta line clearly more subordinate. Highest-value improvement: make the button a visibly denser, stronger, more content-shaped badge body before tweaking any interaction theatrics. Notes were written to `.temp/aerobeat-ui-kit-community-syq-literal-badge-button-report.md`.

---

### Task 2: Implement a literal badge-family primary action button

**Bead ID:** `aerobeat-ui-kit-community-ap9`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, restyle the `PrimaryActionButton` so it visibly reads like the `Badge` turned into a button, not merely badge-derived internally. Make the resting silhouette and boundary clearly badge-family and clearly clickable at scene distance, while preserving interaction behavior and hybrid presentation compatibility. Run validation, then commit and push to `main` by default.

**Folders Created/Deleted/Modified:**
- `.testbed/scenes/`
- `.testbed/scripts/`
- optional `.testbed/tests/`

**Files Created/Deleted/Modified:**
- `.testbed/scenes/glass-shader-panel-source.tscn`
- `.testbed/scripts/glass_shader_panel_source.gd`

**Status:** ✅ Complete

**Results:** Implementation landed and was pushed to `main` in commit `8d1e365` (`Restyle primary action as literal badge button`). The visible design was changed more aggressively than the prior pass: the action now renders as a visibly smaller inner pill/body inside the existing full-width button hit area, with a stronger resting body/border, reduced vertical slack, tighter badge-family radius, and a more button-like internal text composition. Rest-state targets landed close to the requested values in both source and hybrid presentations, and the old centered two-line text-block feel was replaced with a compact vertical stack inside the pill. Validation passed via headless import, headless runs of the source and hybrid scenes, full repo GUT tests, `git diff --check`, and a temporary style validator that confirmed the intended visible metrics.

---

### Task 3: QA literal badge-button readability in source and hybrid views

**Bead ID:** `aerobeat-ui-kit-community-rol`  
**SubAgent:** `primary` (for `qa` workflow role)  
**Role:** `qa`  
**References:** `REF-01`, `REF-02`, `REF-03`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, verify that the `PrimaryActionButton` now visibly looks like the `Badge` turned into a button in both the source scene and hybrid 3D presentation. Confirm the resting silhouette is obvious, the boundary is readable at scene distance, and the button still feels primary and clickable through hover/pressed/toggled states.

**Folders Created/Deleted/Modified:**
- optional `.temp/qa-evidence/`

**Files Created/Deleted/Modified:**
- `.temp/qa-evidence/qa-summary-2026-05-18-literal-badge-button.md`
- refreshed QA evidence under `.temp/qa-evidence/`

**Status:** ✅ Complete

**Results:** QA approved the literal badge-button pass after fresh rendered verification against current `main`. In both the source scene and the hybrid 3D presentation, the primary action now reads as a clear badge-family pill turned into a button rather than floating text in the card. QA confirmed that the boundary separates clearly from the glass card, the visible body feels denser and more button-like, the narrower inner pill is obvious, the meta line reads as subordinate support text, and scene-distance readability now comes primarily from the silhouette/body instead of the `PRIMARY TARGET` text alone. The only softer note is that in the straight-on hybrid capture, the text inside the pill is a bit more washed than the now-stronger body silhouette, but not enough to fail the pass.

---

### Task 4: Independent audit of the literal badge-button result

**Bead ID:** `aerobeat-ui-kit-community-7b0`  
**SubAgent:** `primary` (for `auditor` workflow role)  
**Role:** `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, independently audit the final `PrimaryActionButton` result. Confirm it visibly reads like the `Badge` turned into a primary button, not just badge-derived in code, and that it remains clearly actionable over the glass panel in the source and hybrid scenes.

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
