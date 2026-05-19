# AeroBeat UI Kit Community — Hybrid Glass GUI Panel Alignment and Button Parity

**Date:** 2026-05-18  
**Status:** Complete  
**Agent:** Cookie 🍪

---

## Goal

Bring `glass-shader-gui-3d-test.tscn` back into visual/input parity by syncing to latest `main`, fixing the primary action button’s apparent vs functional placement, giving that action a real glass-button treatment, and checking whether vertical stretch/scaling in the hybrid 3D path is causing the remaining mismatch.

---

## Overview

This slice belongs fully inside `aerobeat-ui-kit-community`, because the reported issues are in the repo-owned hybrid world-space test scene and its authored panel source. Derrick already spotted three concrete symptoms: the clickable location for the primary action does not line up with where the button appears on the panel, the action styling no longer reads like a button, and the hybrid 3D panel may be vertically stretched relative to the 2D source. Those symptoms may be related: if the SubViewport content or panel mesh mapping is stretched, the visual layout and collider/input mapping can drift together.

The safest path is to first sync the repo to latest `main`, then audit the current 2D source scene versus the hybrid 3D world-space scene and controller so we can isolate whether the problem lives in authored layout, hybrid scaling, viewport sizing, mesh UV/world transform, or forwarded input coordinate math. After that, implementation should restore the intended button placement and visual treatment, then QA should verify both parity and live click alignment in the actual scene rather than relying only on headless validation.

This plan keeps implementation and truth-checking separate. A coder lane should make the scene/script changes, a QA lane should verify the live panel visually and interactively, and an auditor lane should independently check that the result really matches the stated goal and does not just look close enough.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Current hybrid world-space GUI scene under review | `.testbed/scenes/glass-shader-gui-3d-test.tscn` |
| `REF-02` | Hybrid world-space GUI scene controller script | `.testbed/scripts/glass_shader_gui_3d_test.gd` |
| `REF-03` | Shared 2D-authored glass panel source scene | `.testbed/scenes/glass-shader-panel-source.tscn` |
| `REF-04` | Shared 2D-authored glass panel source script | `.testbed/scripts/glass_shader_panel_source.gd` |
| `REF-05` | Prior hybrid 3D GUI input-detection plan/history | `.plans/2026-05-15-hybrid-3d-gui-input-detection.md` |

Use these references for exact parity checks between the authored 2D panel and the hybrid 3D rendering/input path.

---

## Tasks

### Task 1: Sync repo and audit hybrid-vs-2D mismatch sources

**Bead ID:** `aerobeat-ui-kit-community-31j`  
**SubAgent:** `primary` (for `research` workflow role)  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, sync to the latest `main` from origin, then inspect the hybrid 3D GUI test scene and the 2D-authored source panel to determine why the primary action button’s functional click location does not match its visible location, why the action visually reads as plain text instead of a glass button, and whether the hybrid 3D panel is vertically stretched relative to the 2D source. Identify the concrete files/properties/math responsible and report the minimum safe fix path.

**Folders Created/Deleted/Modified:**
- `.plans/` (results only if needed)
- optional `.temp/` notes/evidence

**Files Created/Deleted/Modified:**
- `.temp/aerobeat-ui-kit-community-31j-root-cause-report.md`
- `.temp/inspect_panel_layout.gd` (temporary inspection aid)

**Status:** ✅ Complete

**Results:** Research completed after syncing to latest `origin/main` (already up to date). Root-cause findings: (1) the click mismatch comes from resolving projected hit targets in raw quad/full-viewport space while the visible authored card is rendered through `glass_rect` crop/remapping, so input-space and render-space diverge; the main implicated file is `.testbed/scripts/glass_shader_gui_3d_test.gd`, especially the projected target resolution path. (2) The primary action reads like text because in hybrid presentation it is only a faint flat UI-overlay style rather than a strong glass-bodied button; the implicated scene/script are `.testbed/scenes/glass-shader-panel-source.tscn` and `.testbed/scripts/glass_shader_panel_source.gd`. (3) The vertical stretch is caused by aspect-ratio mismatch between the authored source card and the 3D display/input surface in `.testbed/scenes/glass-shader-gui-3d-test.tscn`; the current quad/input surface is materially taller than the authored card ratio. Research notes were written to `.temp/aerobeat-ui-kit-community-31j-root-cause-report.md`. The stretch and click mismatch are related under the broader authored-space vs world-space parity problem, but they do not share the exact same root cause.

---

### Task 2: Restore visual parity and input alignment for the primary action

**Bead ID:** `aerobeat-ui-kit-community-hq4`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, update the hybrid glass GUI scene so the primary action button is visually and functionally aligned, and style it as an actual glass button similar to the pill treatment at the panel’s top-left instead of plain text. If vertical stretch or viewport/world-space scaling is causing mismatch, correct that too while preserving the intended hybrid render architecture. Run repo-local validation, then commit and push the implementation by default.

**Folders Created/Deleted/Modified:**
- `.testbed/scenes/`
- `.testbed/scripts/`

**Files Created/Deleted/Modified:**
- `.testbed/scenes/glass-shader-gui-3d-test.tscn`
- `.testbed/scripts/glass_shader_gui_3d_test.gd`
- `.testbed/scenes/glass-shader-panel-source.tscn`
- `.testbed/scripts/glass_shader_panel_source.gd`
- `.testbed/tests/test_hybrid_mouse_release_path.gd`
- `.testbed/tests/test_hybrid_projection_mapping_and_aspect.gd`
- `.testbed/tests/test_hybrid_projection_mapping_and_aspect.gd.uid`

**Status:** ✅ Complete

**Results:** Implementation landed and was pushed to `main` in commit `e3038f1` (`e3038f17ae2b9e80004020b18962ee43c1750a9e`). The fix corrected the click mismatch by remapping world-hit panel UV through the same authored-space `glass_rect` transform used by the shaders before projected target lookup, while preserving raw panel-space metadata for debugging. The hybrid 3D surface aspect was brought into parity with the authored card by updating the scene defaults and adding runtime aspect syncing so the display quad, overlay quad, and input/collision surface derive from the authored card rect. The primary action styling was strengthened so it reads as a real glass button in hybrid mode via stronger fill/border treatment, added glow/shadow, stronger font/outline, and more button-like shell spacing. Validation passed via headless GUT tests, headless scene launch, and `git diff --check`. Residual QA focus areas: edge-hit alignment at different panel rotations/angles, drag/release continuity after authored-space remap, and whether the stronger button treatment still reads clearly against brighter hybrid backgrounds.

---

### Task 3: QA live visual parity and click-hit alignment in Godot

**Bead ID:** `aerobeat-ui-kit-community-2qy`  
**SubAgent:** `primary` (for `qa` workflow role)  
**Role:** `qa`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, run the hybrid glass GUI test scene in Godot and verify that the primary action now looks like a real glass button, appears in the correct place on the panel, and that the actual clickable/interactive region matches the visible button location. Explicitly compare the hybrid 3D presentation against the authored 2D panel to check for residual vertical stretch or text distortion. Capture concise evidence.

**Folders Created/Deleted/Modified:**
- optional `.temp/qa-evidence/`

**Files Created/Deleted/Modified:**
- `.temp/qa-evidence/01-source-2d.png`
- `.temp/qa-evidence/02-hybrid-front.png`
- `.temp/qa-evidence/03-hybrid-oblique.png`
- `.temp/qa-evidence/hybrid-qa-report.json`
- `.temp/qa-evidence/qa-summary-2026-05-18.md`
- `.temp/qa-evidence/qa-summary-2026-05-18-reverify.md`

**Status:** ✅ Complete

**Results:** Final QA re-verification approved the work after the follow-up aspect fix. Using live windowed Godot runtime capture/probing plus headless regression tests, QA confirmed that front-view and oblique-view parity now match the authored 2D card proportions, with authored-vs-surface aspect effectively identical at runtime. QA also re-confirmed that primary-action alignment did not regress: center and near-edge-inside probes hit, just-outside probes miss, and the button still reads clearly as a glass button against the hybrid background. The one caveat remains that interaction validation was performed through the live scene’s actual projection/input path rather than blind OS-level hand-mouse clicking, but QA considered that sufficient for approval and closed the QA bead.

---

### Task 3B: Fix remaining vertical stretch parity gap

**Bead ID:** `aerobeat-ui-kit-community-cxp`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, QA confirmed the primary action click alignment and visual button treatment, but the hybrid 3D panel still appears vertically stretched relative to the authored 2D panel. Use the QA evidence under `.temp/qa-evidence/` plus the prior root-cause report to correct the remaining aspect/parity issue in the live scene, update any tests that are asserting the wrong aspect model, preserve the now-working authored-space click alignment, run validation, then commit and push to `main` by default.

**Folders Created/Deleted/Modified:**
- `.testbed/scenes/`
- `.testbed/scripts/`
- `.testbed/tests/`
- optional `.temp/qa-evidence/` follow-up notes

**Files Created/Deleted/Modified:**
- `.testbed/scripts/glass_shader_gui_3d_test.gd`
- `.testbed/tests/test_hybrid_projection_mapping_and_aspect.gd`
- `.temp/qa-evidence/hybrid_glass_qa_capture.gd` (local QA helper adjusted during validation)

**Status:** ✅ Complete

**Results:** The follow-up implementation fixed the remaining vertical stretch bug in commit `8aa540e` (`Fix hybrid panel aspect parity`) and pushed it to `main`. The actual issue was that runtime aspect syncing was using the normalized `glass_rect` crop ratio as if it were the true authored aspect; because `glass_rect` is normalized within a `1600x900` SubViewport, that produced the wrong ratio and made the live 3D panel too tall. The fix now computes authored aspect in pixel space from `glass_rect.size * panel_viewport.size`, then uses that pixel-correct authored aspect to size the display mesh, overlay mesh, and input/collision surface. The aspect test was corrected to assert against authored pixel aspect rather than normalized crop ratio. Validation passed via headless import, focused GUT tests, and runtime QA-report regeneration showing effective zero delta between authored aspect and live surface aspect. The click-target mapping path was intentionally left untouched to avoid regressing the already-fixed alignment behavior.

---

### Task 4: Independent audit of parity, alignment, and stretch fix

**Bead ID:** `aerobeat-ui-kit-community-ga3`  
**SubAgent:** `primary` (for `auditor` workflow role)  
**Role:** `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, independently audit the finished hybrid glass GUI changes. Confirm whether the visible primary action button styling now reads as a glass button, whether its actual interactive/clickable area matches its rendered location, and whether the hybrid 3D panel still shows any vertical stretch relative to the 2D-authored panel. Check the final diff, validation output, and QA evidence before deciding whether the bead is actually done.

**Folders Created/Deleted/Modified:**
- `.temp/qa-evidence/`

**Files Created/Deleted/Modified:**
- QA captures, reports, and summaries used to validate the final pass

**Status:** ✅ Complete

**Results:** Final audit passed. The hybrid GUI scene now has authored-space click alignment, corrected aspect parity, and a primary action that reads as an actual button with matching functional hit location. QA confirmed parity in front and oblique views, and audit accepted the final result as complete.

---

## Final Results

**Status:** ✅ Complete

**What We Built:** A repaired hybrid glass GUI test scene with authored-space hit mapping, corrected panel aspect parity, and stronger primary-action button treatment.

**Reference Check:** `REF-01` through `REF-04` were satisfied by bringing the hybrid 3D scene back into visual/input parity with the authored 2D panel; `REF-05` informed the earlier input-detection history used during audit.

**Commits:**
- `e3038f1` - Fix hybrid GUI primary action alignment and glass-button parity
- `8aa540e` - Fix hybrid panel aspect parity
- `9e399b6` - Document hybrid glass GUI parity fix plan

**Lessons Learned:** Distinguish coordinate-space bugs from aspect-ratio bugs. They can share a theme of authored-space drift without sharing the same root cause.

---

*Drafted on 2026-05-18*
