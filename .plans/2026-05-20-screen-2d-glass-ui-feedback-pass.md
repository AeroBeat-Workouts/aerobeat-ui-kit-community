# AeroBeat UI Kit Community

**Date:** 2026-05-20  
**Status:** In Progress  
**Agent:** Cookie 🍪

---

## Goal

Apply Derrick’s next Screen 2D AeroUiGlass feedback pass in the 2D testing scene, including layout cleanup, correct primary-button hover/pressed behavior, and a reusable TweenAlpha orchestration layer for Aero UI elements.

---

## Overview

This pass is focused on the 2D testing scene in `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, specifically the current YAML-native AeroUiGlass proof scene and its shared UI view scripts. The requested changes fall into three buckets: scene UX cleanup, interaction-state correctness/polish for the primary button, and common animation APIs for Aero UI components plus a higher-level composite controller.

The implementation should keep the current YAML-native panel/badge/button structure intact while improving authoring ergonomics and runtime behavior. The primary button needs a true hover vs pressed split, with exposed easing/speed controls so the pressed state actually matters. Separately, the UI layer needs a reusable `TweenAlpha()` contract available across Aero UI elements, plus a parent/controller-level entrypoint that can fan out common calls to child elements.

After QA, Derrick clarified the intended end-state for the `input debug` section: keep it, but make it intentionally minimal. It should show only the current hover target and the current interaction state (`hover` vs `pressed`). The previous broad contract/status dump is considered noise and should stay removed.

Derrick’s next live test surfaced two follow-up issues that now define the current slice: first, leaving the primary button collider after hover currently fails to return the interaction state to `idle`, so hover-exit/reset behavior needs correction and re-verification. Second, the current implementation emits a large warning burst in Godot reload/runtime output, including duplicate global-class/constant naming, shadowing warnings, and at least one `@tool` inheritance mismatch. This slice should now treat warning cleanup as first-class work alongside the hover-exit bug so the scene is cleaner to iterate on.

This plan assumes the work stays inside the existing `.testbed`/UI view/config structure unless implementation reveals that a small shared base class or interface-style pattern should live elsewhere in the repo. If that structural decision needs to shift, the plan will be updated before further execution.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | 2D testing scene control composition and current debug/status text | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/.testbed/scripts/glass_shader_test.gd` |
| `REF-02` | Primary button current visual-state implementation | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/.testbed/ui/views/aero_ui_glass_primary_button_view.gd` |
| `REF-03` | Primary button current config/state schema | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/.testbed/ui/configs/types/aero_ui_glass_primary_button_config.gd` |
| `REF-04` | Derrick screenshot showing the text to remove from the 2D testing scene | `/home/derrick/.openclaw/workspace/.temp/nerve-uploads/2026/05/20/image-11adc963.png` |
| `REF-05` | Derrick screenshot showing the current warning burst during test iteration | `/home/derrick/.openclaw/workspace/.temp/nerve-uploads/2026/05/20/image-7e59387c.png` |

---

## Tasks

### Task 1: Implement Screen 2D feedback pass

**Bead ID:** `aerobeat-ui-kit-community-676`  
**SubAgent:** `primary` (for `coder`)  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** Implement the 2026-05-20 Screen 2D AeroUiGlass feedback pass in `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community` against bead `aerobeat-ui-kit-community-676`. Claim the bead on start with `bd update aerobeat-ui-kit-community-676 --status in_progress --json`. Remove the unwanted text shown in `REF-04` from the 2D testing scene, add large visual section spacing between panel/badge/primary button/input debug sections, correct the primary button so hover and pressed are distinct real states, expose hover/pressed easing types and speeds for interaction polish, add a common Aero UI `TweenAlpha(alpha: float, tweenSpeed: float, easeType, optionalCallback)` capability via shared inheritance/interface-style structure, and add a higher-level script/controller path that can call child Aero UI elements for shared actions like `TweenAlpha()`. Run relevant repo-local validation, update/add tests if appropriate, commit/push to `main` by default, and leave a concise handoff with touched files and validation results.

**Folders Created/Deleted/Modified:**
- `.testbed/scripts/`
- `.testbed/ui/views/`
- `.testbed/ui/configs/types/`
- `.testbed/ui/configs/loaders/`
- `.testbed/tests/ui/`

**Files Created/Deleted/Modified:**
- `.testbed/scripts/glass_shader_test.gd`
- `.testbed/ui/views/aero_ui_glass_primary_button_view.gd`
- `.testbed/ui/configs/types/aero_ui_glass_primary_button_config.gd`
- additional shared Aero UI base/controller scripts as needed
- relevant tests/docs only if required by the implementation

**Status:** ✅ Complete

**Results:** Coder implementation landed in `4e068da` (`Implement AeroUiGlass feedback pass`) and was pushed to `main`. The pass removed the unwanted 2D status copy, added larger section spacing, split primary-button hover vs pressed visuals into distinct phases, exposed hover/pressed easing and speed controls through config/YAML, added shared `TweenAlpha()` support for panel/badge/primary-button views, and introduced a higher-level child fanout controller via `AeroUiElementGroupController` and `AeroUiGlassPanelView.TweenAlphaChildren(...)`. Scoped UI validation passed (`9/9` UI tests). The coder also touched `.testbed/scripts/glass_shader_gui_3d_test.gd` and YAML/config plumbing to keep the shared authored button flow coherent. Repo follow-up still needed from orchestrator: QA, audit, and cleanup of two regenerated `.uid` artifacts plus committing the active plan file.

---

### Task 2: QA the feedback pass in the highest-fidelity path available

**Bead ID:** `aerobeat-ui-kit-community-nmx`  
**SubAgent:** `primary` (for `qa`)  
**Role:** `qa`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** QA bead `aerobeat-ui-kit-community-nmx` after coder handoff. Claim the bead on start with `bd update aerobeat-ui-kit-community-nmx --status in_progress --json`. Verify the already-landed coder change from commit `4e068da` plus current repo state. Verify the Screen 2D AeroUiGlass feedback pass in `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community` using the highest-fidelity path available. Confirm the unwanted text from `REF-04` is gone, the section spacing is clearly larger, the primary button shows distinct hover and pressed behavior, the pressed scale/easing path is actually exercised, and the new shared `TweenAlpha()` plus parent/controller orchestration path works as intended. Capture concrete evidence, note any regressions, and do not close the bead unless the workflow says QA owns closure in this repo.

**Folders Created/Deleted/Modified:**
- `.testbed/`
- `.temp/qa-evidence/` (if needed)

**Files Created/Deleted/Modified:**
- QA evidence artifacts only if needed

**Status:** ⏳ Pending

**Results:** Not started.

---

### Task 3: Audit the implementation and QA claims

**Bead ID:** `aerobeat-ui-kit-community-61e`  
**SubAgent:** `primary` (for `auditor`)  
**Role:** `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** Audit bead `aerobeat-ui-kit-community-61e` after QA. Claim the bead on start with `bd update aerobeat-ui-kit-community-61e --status in_progress --json`. Independently truth-check the already-landed coder change from commit `4e068da`, the current repo state, and the QA evidence before deciding completion. Independently truth-check the Screen 2D AeroUiGlass feedback pass in `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community` against the plan, refs, diffs, and validation evidence. Confirm the scene cleanup, spacing changes, primary-button state correctness, easing/speed exposure, shared `TweenAlpha()` contract, and higher-level child-action orchestration are all actually present and coherent. Close the bead directly only if the work fully passes; otherwise leave it active with a precise gap report.

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
