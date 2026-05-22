# AeroBeat UI Kit Community — Desktop-Truth 2D Hover Bug and Hybrid Shader Review

**Date:** 2026-05-22  
**Status:** Draft  
**Agent:** Byte 🐈‍⬛

---

## Goal

Fix the still-reported 2D mouse hover bug using real desktop-truth validation, and separately review whether the current 3D hybrid glass shader layer is over-scoped for a 2D-parity goal.

---

## Overview

Derrick has now explicitly reported that the 2D mouse interaction bug is still present in real use, and that prior automation clearly did not match real desktop interaction. That means this pass must elevate real desktop validation to the source of truth. Headless probes and unit tests can still support the work, but they are no longer sufficient evidence for closure. The coder may use them for diagnosis, but QA and audit must confirm behavior via the desktop-control workflow or an equivalently truthful live-desktop path.

In parallel, we should continue the architectural discussion around the hybrid 3D panel shader. The current hybrid scene uses a world-space glass body shader plus a UI overlay shader, which is useful when the panel needs to refract and sit convincingly in 3D space over the live scene. But Derrick’s current usage suggests the tuning surface may be much larger than necessary for a parity-first workflow. This plan keeps that shader work in the review/discussion lane unless implementation is explicitly requested later.

This plan therefore has two tracks: (1) a desktop-truth coder → QA → audit loop for the 2D hover bug, and (2) a research-style review of the hybrid shader’s responsibilities versus which controls are actually needed when the goal is simply to match the 2D panel look.

After desktop-truth QA proved the bug still reproduces for the inside-window collider-exit case, this plan now also includes a focused Godot behavior research slice before the next implementation retry. That research specifically pointed to a design flaw in the 2D forwarded-input path: it models hover as a surface-level inside/outside boolean instead of explicit target-transition ownership, unlike the more robust hybrid 3D host. The next implementation retry should port that target-transition pattern into the 2D path.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Current 2D scene/script | `.testbed/scenes/glass-shader-test.tscn` / `.testbed/scripts/glass_shader_test.gd` |
| `REF-02` | Current 3D hybrid scene/script | `.testbed/scenes/glass-shader-gui-3d-test.tscn` / `.testbed/scripts/glass_shader_gui_3d_test.gd` |
| `REF-03` | Hybrid glass body shader | `.testbed/assets/shaders/glass-panel-hybrid-3d.gdshader` |
| `REF-04` | Hybrid UI overlay shader | `.testbed/assets/shaders/glass-panel-ui-overlay-3d.gdshader` |
| `REF-05` | Most recent follow-up plan/results | `.plans/2026-05-22-hover-exit-and-hybrid-spacing-followup.md` |
| `REF-06` | Desktop control workflow source of truth | `/home/derrick/.openclaw/workspace/skills/desktop-control/SKILL.md` |

---

## Tasks

### Task 1: Diagnose and fix the 2D hover bug using desktop-truth validation

**Bead ID:** `aerobeat-ui-kit-community-2pw`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-01`, `REF-05`, `REF-06`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, reproduce the still-reported 2D hover bug using real desktop-truth validation rather than headless-only assumptions. Use the desktop-control workflow to inspect session/control feasibility and confirm real mouse interaction behavior in the current scene. Then implement the narrowest correct fix and validate again on the real desktop. Headless tests may support diagnosis, but do not treat them as sufficient closure evidence.

**Folders Created/Deleted/Modified:**
- `.testbed/`
- `.temp/` if desktop evidence is needed

**Files Created/Deleted/Modified:**
- `.testbed/scripts/glass_shader_test.gd`
- relevant tests/evidence only if actually needed

**Status:** ⏳ Pending

**Results:** Awaiting execution.

---

### Task 2: QA the 2D hover bug on the real desktop path

**Bead ID:** `aerobeat-ui-kit-community-8hz`  
**SubAgent:** `primary` (for `qa` workflow role)  
**Role:** `qa`  
**References:** `REF-01`, `REF-05`, `REF-06`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, verify the 2D hover bug fix using the real desktop path. Do not rely on headless-only checks. Confirm whether hover truly returns to idle/non-hover when the mouse exits the collider in live interaction. Save evidence if useful and be strict.

**Folders Created/Deleted/Modified:**
- `.temp/qa-evidence/` if useful

**Files Created/Deleted/Modified:**
- QA evidence artifacts only if produced

**Status:** ⏳ Pending

**Results:** Awaiting execution.

---

### Task 3: Audit the 2D hover bug fix independently using desktop-truth evidence

**Bead ID:** `aerobeat-ui-kit-community-aj1`  
**SubAgent:** `primary` (for `auditor` workflow role)  
**Role:** `auditor`  
**References:** `REF-01`, `REF-05`, `REF-06`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, independently audit the 2D hover bug fix using the real desktop-truth workflow and any coder/QA evidence. Confirm the bug is actually gone in live interaction before passing it.

**Folders Created/Deleted/Modified:**
- `.plans/` (results updates only if needed)

**Files Created/Deleted/Modified:**
- optional audit notes/evidence if produced

**Status:** ⏳ Pending

**Results:** Awaiting execution.

---

### Task 4: Review the hybrid 3D shader’s real responsibilities vs parity-first needs

**Bead ID:** `aerobeat-ui-kit-community-c7q`  
**SubAgent:** `primary` (for `research` workflow role)  
**Role:** `research`  
**References:** `REF-02`, `REF-03`, `REF-04`, `REF-05`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, review what the current hybrid glass body shader and UI overlay shader actually do for the 3D world-space panel, and identify which parts look genuinely necessary for world-space presentation versus which controls appear over-scoped if the goal is simply to match the 2D panel look. Focus on explanation and downscope opportunities, not implementation.

**Folders Created/Deleted/Modified:**
- none required unless a review note is created

**Files Created/Deleted/Modified:**
- optional review notes only if produced

**Status:** ✅ Complete

**Results:** Research confirmed the hybrid body shader is the real world-space glass slab: it samples and warps the live screen behind the mesh, shapes that through the authored panel mask, applies frost/tint/edge/angle-response treatment, and lightly grades the body under the UI. The overlay shader is a second crisp UI pass that restores readable SubViewport UI over the glass body with light alpha/brightness/tint grading. For a parity-first workflow, research suggests most of the glass/world-reactive tuning surface is over-scoped; likely keepers are mask/shape, blur, a simplified refraction strength, tint, edge treatment, and overlay alpha/brightness, while many frost/face/perimeter/chroma controls look like downscope candidates.
---

## Final Results

**Status:** ⚠️ In Progress

**What We Built:** Desktop-truth work is still in progress on the 2D hover bug. The hybrid shader scope review is complete and suggests the current 3D material tuning surface can likely be downscoped substantially for a parity-first workflow.

**Reference Check:** `REF-02` through `REF-05` now inform the shader review conclusions; `REF-01` / `REF-06` remain active for the unfinished desktop-truth mouse-bug loop.

**Commits:**
- Pending additional hover-bug fix iteration

**Lessons Learned:** The first truthful desktop QA proved the important missing thing was not just “more tests,” but the right kind of tests. We now have a confirmed live-desktop repro split between window-exit success and inside-window collider-exit failure, which should make the next implementation pass much tighter.

---

*Drafted on 2026-05-22*
