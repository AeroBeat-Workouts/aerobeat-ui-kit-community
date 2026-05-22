# AeroBeat UI Kit Community — Hover Exit and Hybrid Section Spacing Follow-up

**Date:** 2026-05-22  
**Status:** Complete  
**Agent:** Byte 🐈‍⬛

---

## Goal

Fix the still-broken 2D mouse hover exit behavior and restore true large-gap section spacing in the 3D hybrid panel so it matches the 2D panel’s visual grouping.

---

## Overview

Derrick’s manual check caught two real misses after the previous pass was committed and pushed: the 2D scene still does not return to idle when the mouse exits the interactive collider, and the hybrid panel still does not have the same large empty spacer rhythm as the 2D panel. A quick read of the current repo state explains why the spacing result drifted: the pushed hybrid script is now on a newer upstream/refactored panel-editor structure than the one the earlier subagent validated, and the current `_build_controls()` path is using compact `_make_section_block(...)` groups rather than the larger separated spacer model that the QA notes described.

The hover issue also needs to be treated as still open until we verify behavior against the current pushed checkout rather than the earlier local/probe assumption. The current screen-space host does use `_input`, but that alone clearly was not enough in real interaction. So this follow-up needs to inspect actual hover-exit publication on the current branch, fix the host or target-state flow narrowly, and verify with a stronger runtime/manual-aligned check.

This retry will stay tightly scoped to the two failed user-visible outcomes. First we correct the implementation against the current pushed codebase, then we re-run QA specifically against Derrick’s two reported failures, then we do an independent audit before reporting complete.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Current 2D screen-space host scene/script | `.testbed/scenes/glass-shader-test.tscn` / `.testbed/scripts/glass_shader_test.gd` |
| `REF-02` | Current 3D hybrid host scene/script | `.testbed/scenes/glass-shader-gui-3d-test.tscn` / `.testbed/scripts/glass_shader_gui_3d_test.gd` |
| `REF-03` | Shared panel/view interaction visuals | `.testbed/scenes/glass-shader-panel-source.tscn` / `.testbed/scripts/glass_shader_panel_source.gd` |
| `REF-04` | 2D panel spacing source of truth | `.testbed/scripts/glass_shader_test.gd` and the instantiated 2D controls layout it builds |
| `REF-05` | Prior attempt plan for the failed pass | `.plans/2026-05-22-2d-hover-exit-and-hybrid-panel-debug-parity.md` |

---

## Tasks

### Task 1: Reproduce and fix the 2D hover-exit failure on the current pushed checkout

**Bead ID:** `aerobeat-ui-kit-community-ulc`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-01`, `REF-03`, `REF-05`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, reproduce why the 2D `glass-shader-test.tscn` scene still does not return to idle when the mouse exits the interactive collider on the current pushed checkout. Investigate the actual hover-exit publication path and fix it narrowly. Validate against the real current code, not the previous pass assumptions.

**Folders Created/Deleted/Modified:**
- `.testbed/`

**Files Created/Deleted/Modified:**
- `.testbed/scripts/glass_shader_test.gd`
- `.testbed/tests/ui/test_aero_ui_glass_panel_view_host_adoption.gd`

**Status:** ✅ Complete

**Results:** Root cause on current checkout was the outside-release cleanup path in `.testbed/scripts/glass_shader_test.gd`: a captured left-button release outside the proof button published the release but did not publish a follow-up `hover_exit`, so the control could remain hovered until another outside motion arrived. The narrow fix synthesizes a cleanup `InputEventMouseMotion` after a captured outside release so the existing hover-exit publication path runs and returns the interaction to idle/rest immediately. Validation used the real host `_input(...)` route through the UI GUT suite, and the targeted file now includes explicit coverage for outside-release idle recovery. Landed in commit `6f86104` (`Fix screen host hover exit on outside release`).

---

### Task 2: Restore true large empty section spacers in the hybrid panel to match the 2D panel rhythm

**Bead ID:** `aerobeat-ui-kit-community-7z9`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-02`, `REF-04`, `REF-05`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, update the current hybrid controls builder so the left panel has clearly visible large empty spacers between sections like the 2D panel. Match the 2D panel’s grouping rhythm truthfully on the current refactored hybrid structure instead of relying on the earlier flat section assumption.

**Folders Created/Deleted/Modified:**
- `.testbed/`

**Files Created/Deleted/Modified:**
- `.testbed/scripts/glass_shader_gui_3d_test.gd`

**Status:** ✅ Complete

**Results:** The hybrid controls builder was updated on the current refactored structure instead of reverting to the earlier flat assumption. A shared `SECTION_SPACER_HEIGHT := 56.0` now drives clearly visible large empty gaps both between top-level left-panel sections and between major grouped blocks inside those sections, while the smaller local per-control spacing remains unchanged. This restores the big-gap rhythm Derrick expected from the 2D panel without disturbing the newer editor layout. Landed in commit `30eeb27` (`Restore large hybrid control section spacing`). Caveat from the coder pass: an initial validation command hit unrelated pre-existing parse/type-resolution noise, which is why strict QA on current code was required next.

---

### Task 3: QA the two failed user-visible behaviors directly on current code

**Bead ID:** `aerobeat-ui-kit-community-934`  
**SubAgent:** `primary` (for `qa` workflow role)  
**Role:** `qa`  
**References:** `REF-01`, `REF-02`, `REF-04`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, verify only the two user-reported failures on the current code: (1) 2D hover truly returns to idle on mouse exit, and (2) the hybrid panel has obvious large empty spacers between sections comparable to the 2D panel. Use the highest-fidelity validation path available and be strict.

**Folders Created/Deleted/Modified:**
- `.temp/qa-evidence/`

**Files Created/Deleted/Modified:**
- `.temp/qa-evidence/2026-05-22-hover-and-hybrid-spacing-followup/report.json`
- `.temp/qa-evidence/2026-05-22-hover-and-hybrid-spacing-followup/godot-run.log`
- `.temp/qa-evidence/2026-05-22-hover-and-hybrid-spacing-followup/2d-initial.png`
- `.temp/qa-evidence/2026-05-22-hover-and-hybrid-spacing-followup/2d-hover-exit.png`
- `.temp/qa-evidence/2026-05-22-hover-and-hybrid-spacing-followup/2d-release-outside.png`
- `.temp/qa-evidence/2026-05-22-hover-and-hybrid-spacing-followup/3d-initial.png`

**Status:** ✅ Complete

**Results:** QA passed both requested outcomes on current code using a runtime harness against the actual `.testbed` project and both target scenes. For 2D, QA verified plain hover exit and press-inside/drag-outside/release-outside both return to `idle` with hovered target `none` (`hover_exit_idle: true`, `release_outside_idle: true`). For the hybrid panel, QA confirmed the scene loads successfully and the current layout contains obvious large spacer rhythm: outer spacers `[56.0, 56.0, 56.0, 8.0]`, plus large inner `56px` spacers inside all major sections. The QA bead closed with evidence saved under `.temp/qa-evidence/2026-05-22-hover-and-hybrid-spacing-followup/`.

---

### Task 4: Audit the follow-up fix and verify no new drift was introduced

**Bead ID:** `aerobeat-ui-kit-community-5vp`  
**SubAgent:** `primary` (for `auditor` workflow role)  
**Role:** `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-05`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, independently audit the follow-up fixes for the still-broken 2D hover exit and missing hybrid section spacer rhythm. Confirm the requested visible outcomes are actually present on the current checkout and note any remaining caveats.

**Folders Created/Deleted/Modified:**
- `.plans/`

**Files Created/Deleted/Modified:**
- `.temp/audit_hover_spacing_runner.gd`

**Status:** ✅ Complete

**Results:** Independent audit passed. The auditor inspected the follow-up plan, the current implementation files, the targeted UI host test, commits `6f86104` / `30eeb27`, QA’s structured evidence, and also ran a separate audit runner at `.temp/audit_hover_spacing_runner.gd`. Audit confirmed that the 2D scene now returns to `idle` / `none` both on hover exit and on outside release cleanup, with `hover_exit` as the last contract phase, and that the hybrid panel truly has obvious large empty spacer rhythm via outer spacers `56, 56, 56, 8` plus `56px` inner spacers in all major sections. Caveats recorded: one unrelated pre-existing UI GUT failure in `test_aero_ui_glass_config_loaders.gd`, and dummy-renderer screenshot capture noise that did not affect the audited behavioral conclusions. The audit bead closed with a pass reason.

---

## Final Results

**Status:** ✅ Complete

**What We Built:** Corrected the real remaining 2D hover-exit bug on current code by ensuring outside release cleanup actually emits the hover-exit path and returns the scene to idle immediately, and restored the hybrid panel’s true large-gap section rhythm so it visually matches the 2D panel more honestly.

**Reference Check:** `REF-01` is now satisfied on current runtime behavior, not just probe assumptions. `REF-02` now reflects the intended large empty hybrid section spacing. `REF-03` remained shared/reference context only. `REF-04` was matched directly by using the 2D panel rhythm as the spacing target. `REF-05` was superseded by this follow-up after Derrick’s manual truth-check caught the earlier miss.

**Commits:**
- `6f86104` - Fix screen host hover exit on outside release
- `30eeb27` - Restore large hybrid control section spacing

**Lessons Learned:** Manual user truth-checking caught two things the first pass’s automation overstated: hover-exit-to-idle needs coverage for outside release cleanup specifically, and visual parity claims about spacing need to be tested against the actual current layout structure, not assumed from an earlier branch shape.

---

*Drafted on 2026-05-22*
