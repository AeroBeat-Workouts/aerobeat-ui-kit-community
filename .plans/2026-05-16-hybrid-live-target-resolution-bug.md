# AeroBeat UI Kit Community

**Date:** 2026-05-16  
**Status:** Draft  
**Agent:** Byte 🐈‍⬛

---

## Goal

Fix the newly exposed real-desktop hybrid input bug where the live scene reports `Surface currently hit: YES` but resolves no interactive target and publishes no normalized contract event on the click-only GNOME Wayland + GRD path.

---

## Overview

The prior loop already settled two important truths. First, the hybrid world-space scene really is using `aerobeat-input-core` as the interaction contract seam. Second, the release-completion bug fixed in commit `0f51dad` may still be a valid code-path fix, but real desktop QA did not reach that path at all. On the real click-only desktop workflow, the live scene stayed earlier in the pipeline: the debug rail showed a surface hit, yet `Hover target path`, `Active owner path`, and `Last release target` all stayed `none`, while the contract side remained at `Verification: waiting • No normalized contract event`.

That changes the next bug to chase. We should not keep pushing on release synthesis until the live host path actually resolves a target and emits normalized contract traffic under the real desktop conditions. The likely problem area now is the boundary between surface-hit math, target lookup, and the specific shape of click-only desktop input on this host. In other words: real desktop hit detection is reaching the panel surface, but target resolution and/or contract publication are not engaging from that path.

This plan stays narrow. It is not another architecture pass, and it is not a broad desktop-control investigation. It is a focused bug hunt in `aerobeat-ui-kit-community` around the live hybrid scene’s target resolution / publication path for the real click-only desktop workflow. The workflow should be coder → QA → auditor: isolate the earlier live bug, validate it on the real desktop path, then independently judge what is truly proven.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Earlier manual QA proving hover + `press_begin` but no completion | `.temp/qa-evidence/manual-mouse-2026-05-16/README.md` |
| `REF-02` | QA after commit `0f51dad` showing no normalized event on real click-only path | `.temp/qa-evidence/manual-mouse-release-fix-2026-05-16/README.md` |
| `REF-03` | Release-completion fix plan now blocked by earlier live issue | `.plans/2026-05-16-hybrid-desktop-release-path-fix.md` |
| `REF-04` | Previous manual validation / audit plan | `.plans/2026-05-16-hybrid-ui-manual-mouse-validation-and-audit.md` |
| `REF-05` | Original hybrid adoption plan/results | `.plans/2026-05-15-input-core-adoption-for-hybrid-ui.md` |
| `REF-06` | Hybrid host controller | `.testbed/scripts/glass_shader_gui_3d_test.gd` |
| `REF-07` | Downstream panel consumer script | `.testbed/scripts/glass_shader_panel_source.gd` |
| `REF-08` | Desktop-control host workflow instructions | `/home/derrick/.openclaw/workspace/skills/desktop-control/SKILL.md` |
| `REF-09` | Closed coder bead for release synthesis fallback | `bd:aerobeat-ui-kit-community-6ax` |
| `REF-10` | Blocked QA bead that exposed the earlier live-path gap | `bd:aerobeat-ui-kit-community-bd7` |

---

## Tasks

### Task 1: Isolate and fix the real-desktop target-resolution / contract-publication gap

**Bead ID:** `aerobeat-ui-kit-community-jrd`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-05`, `REF-06`, `REF-07`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, isolate the earlier live-desktop bug now blocking proof of the hybrid seam: the scene reports `Surface currently hit: YES` on the real click-only GNOME Wayland + GRD path, but resolves no interactive target and emits no normalized contract event. Start from `.testbed/scripts/glass_shader_gui_3d_test.gd` and any tightly-related panel/consumer code. Determine whether the failure is in target rect lookup, missing motion/hover priming, projected coordinate assumptions, click-only path handling, or another narrow host-scene issue. Implement the smallest truthful fix, run repo-local validation, and commit/push before handoff unless concretely blocked.

**Folders Created/Deleted/Modified:**
- `.testbed/`
- `.plans/`
- optional `.temp/` validation artifacts

**Files Created/Deleted/Modified:**
- `.testbed/scripts/glass_shader_gui_3d_test.gd`
- `.testbed/scripts/glass_shader_panel_source.gd`
- related local tests/evidence files only if needed

**Status:** ⏳ Pending

**Results:** Pending.

---

### Task 2: QA the fix on the real click-only desktop path

**Bead ID:** `aerobeat-ui-kit-community-27h`  
**SubAgent:** `primary` (for `qa` workflow role)  
**Role:** `qa`  
**References:** `REF-02`, `REF-03`, `REF-06`, `REF-07`, `REF-08`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, validate the fix on the real GNOME Wayland + GRD click-only desktop workflow. Confirm whether the live scene now resolves an interactive target and publishes normalized contract events under bounded real-desktop clicks. If that succeeds, continue checking whether `press_end`, `taps`, `releases`, and toggle behavior now appear. Capture evidence and keep the truth labels conservative.

**Folders Created/Deleted/Modified:**
- `.temp/qa-evidence/`
- `.plans/`

**Files Created/Deleted/Modified:**
- QA evidence artifacts and summary notes

**Status:** ⏳ Pending

**Results:** Pending.

---

### Task 3: Audit what is actually proven after the live-path fix

**Bead ID:** `aerobeat-ui-kit-community-a7o`  
**SubAgent:** `primary` (for `auditor` workflow role)  
**Role:** `auditor`  
**References:** `REF-02`, `REF-03`, `REF-06`, `REF-07`, `REF-08`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, independently audit the current truth after the live-path target-resolution fix. Decide whether the real click-only desktop path now genuinely resolves targets and publishes normalized contract events, and whether that proof is enough to unblock or supersede bead `aerobeat-ui-kit-community-bd7`. Pass only if the evidence is real and the final label remains honest.

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