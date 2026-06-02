# AeroBeat UI Kit Community

**Date:** 2026-05-16  
**Status:** Stale  
**Agent:** Byte 🐈‍⬛

---

## Goal

Fix the hybrid desktop mouse release/tap path so real desktop interaction can complete `press_end` / tap / toggle behavior through the shared input-core seam, then re-verify and re-audit the truth of that lane.

---

## Overview

The previous manual desktop validation and audit settled an important architecture question: the hybrid world-space testbed in `aerobeat-ui-kit-community` really is using `aerobeat-input-core` as the interaction contract seam. That part is not speculative anymore. But the same validation also exposed the concrete product bug that now matters more than architecture debate: real GNOME Wayland + GRD-driven desktop mouse input reaches hover and `press_begin` on `PrimaryCardButton`, yet does not complete the full downstream cycle to `press_end`, tap/release accounting, or the visible toggle flip.

This plan is intentionally narrow. We are not redesigning the seam, changing ownership boundaries, or promoting labels prematurely. We are fixing one bug in the host-to-contract path: why real desktop release/tap completion is not propagating through the hybrid adapter/consumer flow in the live testbed. The outcome we want is modest and concrete: a real desktop mouse pass that shows the downstream consumer completes the interaction truthfully, or, if it still fails, precise evidence about the remaining gap.

Execution stays in `aerobeat-ui-kit-community` because that repo owns the hybrid host scene, world-hit projection path, and current bug surface. The workflow is the normal coder → QA → auditor loop: implement the narrow fix, run a fresh real desktop validation pass, then independently audit whether the lane can remain prototype or be promoted based on evidence.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Manual desktop QA evidence showing hover + `press_begin` but no completion | `.temp/qa-evidence/manual-mouse-2026-05-16/README.md` |
| `REF-02` | Previous hybrid seam validation and audit plan | `.plans/2026-05-16-hybrid-ui-manual-mouse-validation-and-audit.md` |
| `REF-03` | Previous adoption plan/results | `.plans/2026-05-15-input-core-adoption-for-hybrid-ui.md` |
| `REF-04` | Hybrid host scene/controller | `.testbed/scripts/glass_shader_gui_3d_test.gd` |
| `REF-05` | Downstream panel consumer script | `.testbed/scripts/glass_shader_panel_source.gd` |
| `REF-06` | Shared input-core contract rollout doc | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-input-core/docs/ui-interaction-contract-v1.md` |
| `REF-07` | Desktop-control skill instructions used for real-host validation | `/home/derrick/.openclaw/workspace/skills/desktop-control/SKILL.md` |
| `REF-08` | Existing closed seam audit bead | `bd:aerobeat-ui-kit-community-5e9` |
| `REF-09` | Existing closed manual QA bead | `bd:aerobeat-ui-kit-community-6u8` |
| `REF-10` | Real-host release path likely in `_publish_mouse_button_to_contract()` | `.testbed/scripts/glass_shader_gui_3d_test.gd` |

---

## Tasks

### Task 1: Fix the hybrid desktop mouse release/tap completion path

**Bead ID:** `aerobeat-ui-kit-community-6ax`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-01`, `REF-03`, `REF-04`, `REF-05`, `REF-06`, `REF-10`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, claim the coder bead for this plan and fix the specific bug where real desktop mouse input reaches hover and `press_begin` on the hybrid input-core seam but does not complete to `press_end` / tap / release / toggle on the downstream consumer. Start from the current host scene/controller and consumer scripts, inspect the release path carefully, and make the narrowest truthful fix. Run relevant repo-local validation, commit, and push before handoff unless blocked.

**Folders Created/Deleted/Modified:**
- `.testbed/`
- `.plans/`
- optional `.temp/` validation artifacts

**Files Created/Deleted/Modified:**
- `.testbed/scripts/glass_shader_gui_3d_test.gd`
- `.testbed/scripts/glass_shader_panel_source.gd`
- any narrowly-related local test helpers/evidence files if needed

**Status:** ⏳ Pending

**Results:** Pending.

---

### Task 2: QA real desktop release/tap completion after the fix

**Bead ID:** `aerobeat-ui-kit-community-bd7`  
**SubAgent:** `primary` (for `qa` workflow role)  
**Role:** `qa`  
**References:** `REF-01`, `REF-02`, `REF-04`, `REF-05`, `REF-06`, `REF-07`, `REF-10`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, claim the QA bead for this plan and perform a fresh real desktop validation pass after the coder fix. Use the same honest host workflow as the previous manual QA. Verify whether real desktop mouse input now completes `press_end`, release/tap accounting, and visible toggle behavior end-to-end through the contract consumer. Capture evidence and keep the truth label conservative unless the evidence is strong.

**Folders Created/Deleted/Modified:**
- `.temp/qa-evidence/`
- `.plans/`

**Files Created/Deleted/Modified:**
- new QA evidence artifacts and summary notes

**Status:** ⏳ Pending

**Results:** Pending.

---

### Task 3: Audit whether desktop mouse completion is now truthfully proven

**Bead ID:** `aerobeat-ui-kit-community-7ep`  
**SubAgent:** `primary` (for `auditor` workflow role)  
**Role:** `auditor`  
**References:** `REF-01`, `REF-02`, `REF-04`, `REF-05`, `REF-06`, `REF-10`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, claim the auditor bead for this plan and independently judge whether the desktop mouse lane is now truthfully end-to-end for the hybrid seam. Use the new QA evidence plus the current code/diff. Pass only if the proof is real and the label remains honest.

**Folders Created/Deleted/Modified:**
- `.plans/`
- optional audit notes/evidence paths

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

*Drafted on 2026-05-16*