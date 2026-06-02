# AeroBeat UI Kit Community — 2D Hover Exit and Hybrid Panel/Debug Parity

**Date:** 2026-05-22  
**Status:** Complete  
**Agent:** Byte 🐈‍⬛

---

## Goal

Fix the stuck hover behavior in the 2D glass shader test scene and bring the 3D hybrid test scene’s left-panel spacing plus bottom debug output back into parity with the cleaner 2D panel UX.

---

## Overview

This pass is tightly scoped to the `.testbed` proof scenes in `aerobeat-ui-kit-community`. The 2D issue looks like a host/input-contract continuity bug: `glass_shader_test.gd` tracks `_mouse_hover_active`, forwards mouse motion into `ScreenUiInputAdapter`, and only clears hover when a qualifying motion/release path happens. If hover is entering but never cleanly exiting, we need to verify whether the host stops publishing too early, whether exit events are suppressed when the pointer leaves the proof card, or whether the shared panel source is holding visual hover state after the contract state changes.

The 3D issues look like parity drift between the hybrid host controls and the established 2D controls. `glass_shader_gui_3d_test.gd` currently builds a long flat stack of controls with only a single spacer before the slider list, while the shared 2D panel/scene UX presents more visually separated sections. Its bottom status panel also exposes extra host-debug lines (`surface hit`, multiple target-path diagnostics, release ownership internals, etc.) that Derrick explicitly no longer wants. The safest fix is to compare the 3D host against the 2D host’s intended grouping and status scope, then reduce the hybrid panel to the same “current interaction + state” level of truth without losing necessary functionality.

This plan keeps the work in one repo-local slice: implementation, direct scene validation, then an independent audit. If implementation reveals the hover-exit bug actually lives in shared addon source rather than the local testbed host, the plan must be updated before broadening scope.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | 2D screen-space host scene/script (source of intended debug scope) | `.testbed/scenes/glass-shader-test.tscn` / `.testbed/scripts/glass_shader_test.gd` |
| `REF-02` | 3D hybrid host scene/script to bring back into parity | `.testbed/scenes/glass-shader-gui-3d-test.tscn` / `.testbed/scripts/glass_shader_gui_3d_test.gd` |
| `REF-03` | Shared authored panel source and interaction visuals | `.testbed/scenes/glass-shader-panel-source.tscn` / `.testbed/scripts/glass_shader_panel_source.gd` |
| `REF-04` | Prior hybrid input/manual mouse validation plan | `.plans/2026-05-16-hybrid-ui-manual-mouse-validation-and-audit.md` |
| `REF-05` | Prior screen-space input-core adoption plan/results | `.plans/2026-05-15-input-core-adoption-for-screen-2d-ui.md` |

---

## Tasks

### Task 1: Diagnose the 2D hover-exit bug and patch the host/shared UI path cleanly

**Bead ID:** `aerobeat-ui-kit-community-mpw`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-01`, `REF-03`, `REF-05`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, investigate why the button in `.testbed/scenes/glass-shader-test.tscn` visibly enters hover state but never leaves hover on mouse exit. Check whether the bug is in `.testbed/scripts/glass_shader_test.gd`, the screen input adapter wiring, or the shared panel-source visual contract path. Implement the narrowest truthful fix, keep the input-contract proof honest, and run repo-local validation appropriate to the changed scope.

**Folders Created/Deleted/Modified:**
- `.testbed/`

**Files Created/Deleted/Modified:**
- `.testbed/scripts/glass_shader_test.gd`

**Status:** ✅ Complete

**Results:** Root cause was local to `.testbed/scripts/glass_shader_test.gd`: the 2D host forwarded proof-card input from `_unhandled_input`, so once the real button consumed mouse motion the host could miss the hover-exit motion and leave the contract hover state latched. The fix was to switch the host callback to `_input`, which keeps the screen adapter receiving the motion required to publish hover exit honestly. Validation included a headless hover-enter/hover-exit contract probe, `godot --headless --path .testbed --quit`, and `git diff --check`. Landed in commit `1e3069b` (`Fix 2D hover exit contract routing`). `REF-01` and `REF-03` were satisfied without broadening into shared panel-source changes.

---

### Task 2: Restore hybrid left-panel section spacing and trim hybrid bottom debug output to 2D parity

**Bead ID:** `aerobeat-ui-kit-community-0zc`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, update the hybrid 3D test scene/UI so the left controls panel has the same clear section spacing/grouping feel as the 2D UI scene, and reduce the bottom input debug/status section to match the 2D scene’s intentionally limited scope: what is currently being interacted with and the current state, without the extra low-level internal debug lines Derrick called out.

**Folders Created/Deleted/Modified:**
- `.testbed/`

**Files Created/Deleted/Modified:**
- `.testbed/scripts/glass_shader_gui_3d_test.gd`
- `.testbed/scenes/glass-shader-gui-3d-test.tscn`

**Status:** ✅ Complete

**Results:** The hybrid host controls in `.testbed/scripts/glass_shader_gui_3d_test.gd` were regrouped from one long flat stack into explicit sections: `Scene controls`, `Glass body`, `World lighting`, `UI embed + overlay`, `Hybrid shell`, and `Color tuning`, with titled dividers plus `18px` inter-section spacing and a final `8px` tail spacer. The bottom hybrid status/debug block was reduced to the same tight scope Derrick wanted from the 2D scene: only `Interacting with:` and `Current state:`. The old low-level internal-debug lines were removed, and the scene status label minimum height in `.testbed/scenes/glass-shader-gui-3d-test.tscn` was reduced to `92`. Validation included headless project/scene boot passes. Landed in commit `1bb9075` (`Refine hybrid panel grouping and status`). `REF-01` and `REF-02` were satisfied.

---

### Task 3: QA both proof scenes manually against Derrick’s feedback

**Bead ID:** `aerobeat-ui-kit-community-awv`  
**SubAgent:** `primary` (for `qa` workflow role)  
**Role:** `qa`  
**References:** `REF-01`, `REF-02`, `REF-03`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, verify the 2D `glass-shader-test.tscn` button now exits hover cleanly, and verify the 3D `glass-shader-gui-3d-test.tscn` left panel has clearer section spacing plus a bottom debug/status section that matches the 2D scene’s reduced scope. Use the highest-fidelity validation path available and report any remaining parity gaps truthfully.

**Folders Created/Deleted/Modified:**
- `.temp/qa-evidence/`

**Files Created/Deleted/Modified:**
- `.temp/qa-evidence/2026-05-22-hover-and-hybrid-parity/runtime_probe.gd`
- `.temp/qa-evidence/2026-05-22-hover-and-hybrid-parity/runtime_probe_results.json`

**Status:** ✅ Complete

**Results:** QA verified all three requested feedback items via a repo-local headless runtime probe against the real `.testbed` scenes plus direct code/scene review. The probe confirmed 2D hover transitions now produce `hover_enter` then `hover_exit`, `_mouse_hover_active` drops back to `false`, and the target hover state flips `true -> false`. For the hybrid scene, QA confirmed the expected section titles and spacer rhythm (`18.0` x5 plus one `8.0` spacer) and verified that the bottom status block now renders only the title plus `Interacting with:` and `Current state:` while the old debug lines are absent. Evidence was saved at `.temp/qa-evidence/2026-05-22-hover-and-hybrid-parity/runtime_probe.gd` and `.temp/qa-evidence/2026-05-22-hover-and-hybrid-parity/runtime_probe_results.json`. The QA bead closed with reason `QA verified 2D hover exit and hybrid spacing/debug parity`.

---

### Task 4: Audit that the final state matches the requested feedback without hidden regressions

**Bead ID:** `aerobeat-ui-kit-community-t1h`  
**SubAgent:** `primary` (for `auditor` workflow role)  
**Role:** `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, independently audit the hover-exit fix and the hybrid panel/debug parity changes. Confirm the visible behavior matches Derrick’s feedback, the debug output is intentionally reduced rather than accidentally broken, and no obvious input-contract regression was introduced.

**Folders Created/Deleted/Modified:**
- `.plans/`

**Files Created/Deleted/Modified:**
- none

**Status:** ✅ Complete

**Results:** Independent audit passed. The auditor inspected the plan, both host scripts/scenes, the shared panel source, the QA evidence JSON, and commits `1e3069b` / `1bb9075`, then re-ran the runtime probe headless against the current checkout. Audit confirmed: (1) 2D hover now exits cleanly on mouse exit; (2) the hybrid left panel spacing/grouping improvement is real and matches the intended section model; (3) the trimmed hybrid status block is an intentional reduction, not a broken display; and (4) no obvious input-contract regression was introduced because the 2D change only altered host input entrypoint routing while the hybrid change stayed in grouping/status presentation. Caveat recorded: this was a strong targeted audit, not exhaustive exploratory coverage across every pointer/touch edge case. The audit bead closed with a pass reason.

---

## Final Results

**Status:** ✅ Complete

**What We Built:** Fixed the 2D proof scene’s stuck hover-exit behavior and restored cleaner parity in the hybrid proof scene by regrouping the left controls panel and trimming the bottom status/debug block to the intended 2D-style scope.

**Reference Check:** `REF-01` was satisfied directly in both implementation and parity review; `REF-02` was updated to match the requested grouped hybrid presentation and reduced status scope; `REF-03` remained truthful and unchanged for shared interaction visuals; `REF-04` and `REF-05` informed the audit/contract-safety check and no obvious regression was found.

**Commits:**
- `1e3069b` - Fix 2D hover exit contract routing
- `1bb9075` - Refine hybrid panel grouping and status

**Lessons Learned:** The 2D hover bug was not a shared visual-state problem; it was a host input-entrypoint problem. For these proof scenes, status/debug scope needs active parity policing or the hybrid host will naturally drift into exposing too many internals compared with the cleaner 2D reference.

---

*Drafted on 2026-05-22*
