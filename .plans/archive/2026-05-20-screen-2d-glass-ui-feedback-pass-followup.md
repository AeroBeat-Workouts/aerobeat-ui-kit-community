# AeroBeat UI Kit Community

**Date:** 2026-05-20  
**Status:** Stale  
**Agent:** Cookie 🍪

---

## Goal

Fix the Screen 2D primary-button hover-exit regression and clean up the current Godot warning burst so the AeroUiGlass test scene returns to a stable, low-noise iteration baseline.

---

## Overview

Derrick’s latest hands-on test found that leaving the primary button collider after hover does not return the control to `idle`; the UI remains stuck in `hover`. That is a real interaction-state regression in the Screen 2D testing scene and needs to be fixed at the source of the current hover/press contract flow rather than papered over in the debug display.

The same test pass also surfaced a noisy warning burst in Godot. From the screenshot, the warnings appear to include duplicate constant-vs-global-class naming, local variable/parameter shadowing, a lambda-capture warning, and at least one base-script `@tool` mismatch. This follow-up slice should treat those warnings as product debt to reduce now, especially where they were introduced by the recent AeroUiGlass refactor and TweenAlpha additions.

This slice should preserve the recently-landed good state: large section spacing, the minimal `input debug` section, distinct hover vs pressed visual behavior, shared `TweenAlpha()` support, and the higher-level child fanout path.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Screen 2D testing scene script and current input debug wiring | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/.testbed/scripts/glass_shader_test.gd` |
| `REF-02` | Primary button current hover/pressed implementation | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/.testbed/ui/views/aero_ui_glass_primary_button_view.gd` |
| `REF-03` | Shared TweenAlpha utility and recent shared-view additions | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/.testbed/ui/views/shared/` |
| `REF-04` | Derrick screenshot showing the warning burst during testing | `/home/derrick/.openclaw/workspace/.temp/nerve-uploads/2026/05/20/image-7e59387c.png` |
| `REF-05` | Existing active plan for the broader 2026-05-20 AeroUiGlass feedback pass | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/.plans/2026-05-20-screen-2d-glass-ui-feedback-pass.md` |

---

## Tasks

### Task 1: Fix hover-exit reset and warning burst

**Bead ID:** `aerobeat-ui-kit-community-ca0`  
**SubAgent:** `primary` (for `coder`)  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`  
**Prompt:** Implement the 2026-05-20 follow-up fix in `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community` against bead `aerobeat-ui-kit-community-ca0`. Claim the bead on start with `bd update aerobeat-ui-kit-community-ca0 --status in_progress --json`. Fix the Screen 2D hover-exit bug so leaving the primary button collider returns the interaction state to `idle` instead of staying stuck in `hover`. Also identify and clean up the warning burst visible in `REF-04`, prioritizing warnings introduced by the recent AeroUiGlass refactor/TweenAlpha work: duplicate constant/global-class naming, variable/parameter shadowing, lambda-capture misuse, and any `@tool` inheritance mismatch. Preserve the minimal input debug section, larger section spacing, distinct hover vs pressed behavior, shared `TweenAlpha()` support, and the higher-level child fanout path. Run relevant validation, capture before/after warning evidence if practical, commit/push to `main`, and leave a concise handoff.

**Folders Created/Deleted/Modified:**
- `.testbed/scripts/`
- `.testbed/ui/views/`
- `.testbed/ui/views/shared/`
- `.testbed/ui/configs/types/`
- `.testbed/ui/configs/loaders/`
- `.testbed/tests/ui/`

**Files Created/Deleted/Modified:**
- `.testbed/scripts/glass_shader_test.gd`
- `.testbed/ui/views/aero_ui_glass_primary_button_view.gd`
- shared utility/controller files as needed
- any directly implicated config/loader/test files needed to eliminate the warnings cleanly

**Status:** ⏳ Pending

**Results:** Not started.

---

### Task 2: QA hover-exit reset and warning cleanup

**Bead ID:** `aerobeat-ui-kit-community-qvm`  
**SubAgent:** `primary` (for `qa`)  
**Role:** `qa`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`  
**Prompt:** QA the follow-up fix on bead `aerobeat-ui-kit-community-qvm` after coder handoff. Claim the bead on start with `bd update aerobeat-ui-kit-community-qvm --status in_progress --json`. Verify in the highest-fidelity path available that the Screen 2D primary button returns to `idle` when the pointer exits after hover, and that the warning burst from `REF-04` has been reduced/eliminated for the touched codepaths. Confirm the minimal input debug section still shows only hover target + interaction state, larger section spacing remains intact, and primary-button hover vs pressed behavior still works correctly.

**Folders Created/Deleted/Modified:**
- `.testbed/`
- `.temp/qa-evidence/` (if needed)

**Files Created/Deleted/Modified:**
- QA evidence artifacts only if needed

**Status:** ⏳ Pending

**Results:** Not started.

---

### Task 3: Audit the follow-up fix

**Bead ID:** `aerobeat-ui-kit-community-1sc`  
**SubAgent:** `primary` (for `auditor`)  
**Role:** `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`  
**Prompt:** Audit the follow-up fix on bead `aerobeat-ui-kit-community-1sc` after QA. Claim the bead on start with `bd update aerobeat-ui-kit-community-1sc --status in_progress --json`. Independently truth-check the hover-exit reset behavior and warning cleanup against the plan, diffs, and QA evidence. Confirm the UI now returns to `idle` on hover exit, the recent warning burst has been materially resolved for the touched codepaths, and the prior good behavior remains intact.

**Folders Created/Deleted/Modified:**
- repo inspection only

**Files Created/Deleted/Modified:**
- none expected unless audit evidence is added

**Status:** ⏳ Pending

**Results:** Not started.

---

## Final Results

**Status:** ⏳ Pending

**What We Built:** Pending execution.

**Reference Check:** Pending execution.

**Commits:**
- Pending

**Lessons Learned:** Pending execution.

---

*Completed on Pending*
