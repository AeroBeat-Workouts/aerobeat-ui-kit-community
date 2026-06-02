# AeroBeat UI Kit Community

**Date:** 2026-05-16  
**Status:** Stale  
**Agent:** Byte 🐈‍⬛

---

## Goal

Truth-check the hybrid input-core UI seam with a real desktop mouse pass and close the remaining audit lane only if the manual evidence supports it.

---

## Overview

Yesterday’s rollout proved the contract seam technically across `aerobeat-input-core`, `aerobeat-ui-core`, and `aerobeat-ui-kit-community`, and the reusable consumer layer was already extracted cleanly. The remaining honest gap is not another abstraction redesign; it is truth. We need evidence from a real desktop mouse path on the hybrid world-space test scene before we say more about the maturity of the `screen_mouse` + `hybrid_3d_gui` lane.

This execution plan stays inside `aerobeat-ui-kit-community` because that repo owns the hybrid host testbed, the world-hit/projection plumbing, and the remaining open audit bead. The work is therefore: run a QA-focused desktop validation against the real scene using the current local desktop-control workflow, record what actually happens, then run an independent auditor pass against the plan, beads, code, and evidence. If the evidence is good, the audit can close. If not, the audit should stay open and state exactly why.

We already checked the supposed pending `aerobeat-input-core` audit from yesterday’s handoff and found that bead `aerobeat-input-core-ada` was actually closed on 2026-05-15. So this plan narrows to the real unfinished lane instead of inventing extra work.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Yesterday handoff and next-step truth gap | `/home/derrick/.openclaw/workspace/memory/2026-05-15.md` |
| `REF-02` | Active hybrid adoption plan from yesterday | `.plans/2026-05-15-input-core-adoption-for-hybrid-ui.md` |
| `REF-03` | Hybrid 3D GUI scene | `.testbed/scenes/glass-shader-gui-3d-test.tscn` |
| `REF-04` | Hybrid 3D GUI controller | `.testbed/scripts/glass_shader_gui_3d_test.gd` |
| `REF-05` | Shared panel consumer script | `.testbed/scripts/glass_shader_panel_source.gd` |
| `REF-06` | Input-core rollout contract doc | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-input-core/docs/ui-interaction-contract-v1.md` |
| `REF-07` | Desktop-control skill instructions | `/home/derrick/.openclaw/workspace/skills/desktop-control/SKILL.md` |
| `REF-08` | Remaining ui-kit audit bead | `bd:aerobeat-ui-kit-community-5e9` |
| `REF-09` | New manual desktop validation bead | `bd:aerobeat-ui-kit-community-6u8` |

---

## Tasks

### Task 1: Run manual desktop mouse validation against the hybrid input-core seam

**Bead ID:** `aerobeat-ui-kit-community-6u8`  
**SubAgent:** `primary` (for `qa` workflow role)  
**Role:** `qa`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`, `REF-06`, `REF-07`, `REF-09`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, claim bead `aerobeat-ui-kit-community-6u8` and perform a real desktop mouse validation pass for the hybrid input-core seam. Use the local desktop-control skill workflow appropriate for this host/session and be honest about what can and cannot be proven. Validate the hybrid 3D GUI scene in practice, capture evidence, and answer: does desktop mouse interaction really drive the downstream contract-consumer behavior end-to-end, and should `screen_mouse` + `hybrid_3d_gui` stay `prototype` or be promoted? Do not redesign the seam unless validation reveals a concrete bug. Close the bead only if the QA pass is actually complete with evidence.

**Folders Created/Deleted/Modified:**
- `.temp/`
- `.plans/`

**Files Created/Deleted/Modified:**
- QA evidence artifacts as needed
- plan/results notes if needed

**Status:** ⏳ Pending

**Results:** Pending.

---

### Task 2: Independently audit the hybrid seam using the manual validation evidence

**Bead ID:** `aerobeat-ui-kit-community-5e9`  
**SubAgent:** `primary` (for `auditor` workflow role)  
**Role:** `auditor`  
**References:** `REF-02`, `REF-03`, `REF-04`, `REF-05`, `REF-06`, `REF-08`, `REF-09`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, claim bead `aerobeat-ui-kit-community-5e9` and audit whether the hybrid host path genuinely uses `aerobeat-input-core` as the real contract seam. Review the existing code, yesterday’s adoption plan, the new QA/manual desktop evidence from bead `aerobeat-ui-kit-community-6u8`, and the current repo state. Close the audit bead only if the seam is genuinely proven and the truth labels remain honest.

**Folders Created/Deleted/Modified:**
- `.plans/`
- optional QA/audit artifact paths

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