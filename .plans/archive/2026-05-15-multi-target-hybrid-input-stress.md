# AeroBeat UI Kit Community — Multi-Target Hybrid Input Stress Slice

**Date:** 2026-05-15  
**Status:** Stale  
**Agent:** Byte 🐈‍⬛

---

## Goal

Pressure-test the approved `aerobeat-input-core` contract on a more adversarial hybrid world-space UI surface by expanding the current single-target proof into a multi-target hybrid test scene that validates target-path routing, hover transitions, and press/drag/release continuity across multiple interactive elements.

---

## Overview

At this point, `aerobeat-ui-kit-community` has two strong but bounded proofs: a hybrid single-target world-space proof and a screen-space 2D proof. Together they answer the first big question — the contract seam is reusable outside one weird hybrid test scene. What they do not answer yet is how the seam behaves when hybrid routing gets more complex. The next honest uncertainty is no longer “can the same downstream consumer pattern be reused?” but “does the host/consumer split remain clean when a hybrid surface must route between multiple interactive targets with more chances for hover, drag, and release edge cases?”

This slice therefore stays in the hybrid world-space path, but deliberately increases routing complexity while keeping the contract itself stable. The host scene should still own world-hit acquisition, UV/viewport projection, continuity policy, and target-path resolution. The shared contract should still own normalized phases, verification metadata, and downstream interaction behavior through `AeroUiInteractionBus`, `HybridSubViewportInputAdapter`, `AeroUiInteractable`, and `AeroUiInteractionListener`. The test scene should expand from one main `PreviewButton` to multiple distinct targets so we can observe whether target transitions and event ownership remain honest without reintroducing raw-input coupling or scene-specific hacks.

This plan is not a promotion pass for verification labels. Even if the multi-target stress test succeeds, the default stance should remain conservative: hybrid mouse stays `prototype` until there is stronger real interaction evidence, and touch remains `unverified`. The purpose here is battle-testing routing behavior and abstraction cleanliness, not overstating verification.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Completed hybrid adoption plan/results | `.plans/2026-05-15-input-core-adoption-for-hybrid-ui.md` |
| `REF-02` | Completed screen-space 2D adoption plan/results | `.plans/2026-05-15-input-core-adoption-for-screen-2d-ui.md` |
| `REF-03` | Hybrid adoption design note | `docs/notes/2026-05-15-input-core-hybrid-adoption-design.md` |
| `REF-04` | Screen-space 2D adoption design note | `docs/notes/2026-05-15-input-core-screen-2d-adoption-design.md` |
| `REF-05` | Approved input-core contract rollout doc | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-input-core/docs/ui-interaction-contract-v1.md` |
| `REF-06` | Current hybrid test scene | `.testbed/scenes/glass-shader-gui-3d-test.tscn` |
| `REF-07` | Current hybrid host controller | `.testbed/scripts/glass_shader_gui_3d_test.gd` |
| `REF-08` | Shared panel source scene | `.testbed/scenes/glass-shader-panel-source.tscn` |
| `REF-09` | Shared panel source script | `.testbed/scripts/glass_shader_panel_source.gd` |
| `REF-10` | Hybrid adoption commit | `.git@a438614` |
| `REF-11` | Hybrid runtime hookup fix commit | `.git@e43baa2` |
| `REF-12` | 2D proof commit | `.git@896770e` |

---

## Tasks

### Task 1: Design the multi-target hybrid stress path and target-routing proof

**Bead ID:** `aerobeat-ui-kit-community-dvb`  
**SubAgent:** `primary` (for `research` workflow role)  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-05`, `REF-06`, `REF-07`, `REF-08`, `REF-09`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, design the cleanest multi-target hybrid stress slice for the existing input-core contract seam. Identify how the current single-target hybrid proof should expand into multiple interactive targets, what target-path routing cases should be exercised, how hover transitions and capture continuity should be validated, and what scene/script changes are needed while keeping the host/consumer split clean.

**Folders Created/Deleted/Modified:**
- `.plans/`
- `docs/notes/` if useful
- `.testbed/`

**Files Created/Deleted/Modified:**
- optional design/adoption note

**Status:** ⏳ Pending

**Results:** Awaiting design.

---

### Task 2: Implement the multi-target hybrid routing stress proof

**Bead ID:** `aerobeat-ui-kit-community-dl7`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-05`, `REF-06`, `REF-07`, `REF-08`, `REF-09`, `REF-10`, `REF-11`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, implement a multi-target hybrid world-space proof that expands the existing single-target input-core seam into a more adversarial routing surface. Add multiple interactive targets, preserve local host ownership of ray/projection/continuity/target resolution, and ensure visible behavior across the targets is still driven by the shared contract through `HybridSubViewportInputAdapter`, `AeroUiInteractionBus`, `AeroUiInteractable`, and `AeroUiInteractionListener`.

**Folders Created/Deleted/Modified:**
- `.testbed/`

**Files Created/Deleted/Modified:**
- `.testbed/scenes/glass-shader-gui-3d-test.tscn`
- `.testbed/scripts/glass_shader_gui_3d_test.gd`
- `.testbed/scenes/glass-shader-panel-source.tscn`
- `.testbed/scripts/glass_shader_panel_source.gd`
- any minimal local helpers truly needed for multi-target routing proof

**Status:** ✅ Complete

**Results:** The multi-target hybrid stress proof landed in commit `85a0d97` (`Add multi-target hybrid input stress proof`). The shared panel source now contains three sibling contract targets — `PrimaryCardButton`, `SecondaryToggleChip`, and `DragStrip` — and `.testbed/scripts/glass_shader_panel_source.gd` now creates separate `AeroUiInteractable` / `AeroUiInteractionListener` pairs per target, filters each by its own `target_path`, and exposes visible target-specific behavior plus a shared routing summary panel. On the host side, `.testbed/scripts/glass_shader_gui_3d_test.gd` replaced the single hardcoded target-path resolver with projected multi-target lookup plus per-pointer owner-path continuity: hover target is resolved from projected panel coordinates, press locks an owner target path, drag/release continues publishing to the original owner target, and off-surface continuation reuses prior projected data. Coder-reported validation included headless Godot boot, a hybrid probe script covering distinct target resolution and ownership cases, and `git diff --check`; probe highlights showed primary/chip taps remaining isolated and strip drags retaining ownership even when hover moved across siblings. Verification labels remain truthful: hybrid mouse stays `prototype`, touch stays `unverified`. 

---

### Task 3: QA multi-target hybrid routing behavior under the shared contract seam

**Bead ID:** `aerobeat-ui-kit-community-o1u`  
**SubAgent:** `primary` (for `qa` workflow role)  
**Role:** `qa`  
**References:** `REF-01`, `REF-05`, `REF-06`, `REF-07`, `REF-09`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, verify the multi-target hybrid stress proof. Confirm that hover transitions between targets, target-path ownership, drag/release continuity, and visible state changes remain contract-driven and truthful under the more complex routing setup.

**Folders Created/Deleted/Modified:**
- `.temp/qa-evidence/` if useful

**Files Created/Deleted/Modified:**
- QA evidence artifacts if produced

**Status:** ✅ Complete

**Results:** QA passed with explicit scope limits. A headless end-to-end probe against the real hybrid scene confirmed that the multi-target stress proof behaves as designed: the shared panel exposes three distinct sibling contract targets (`PrimaryCardButton`, `SecondaryToggleChip`, `DragStrip`), the host resolves target paths dynamically via projected panel coordinates, and owner-path capture remains locked after press even while hover target truth changes during drag. Probe evidence showed target-isolated taps, strip drag ownership retained across sibling hover transitions, release over a different sibling still ending on the original owner, and off-surface continuation preserving owner-path truth. Runtime panel structure also confirmed the shared consumer shape stayed intact, with per-target interactable/listener pairs connected to the shared `AeroUiInteractionBus`. Repo-local validation passed (headless boot, GUT, `git diff --check`). Important limits remain truthful: QA evidence is still synthetic/headless rather than a live manual desktop pass, touch remains `unverified`, hybrid mouse remains `prototype`, and this proof applies to the authored three-target sibling layout rather than all future hybrid routing layouts by default.

---

### Task 4: Audit whether the hybrid seam is battle-tested enough for broader adoption work

**Bead ID:** `aerobeat-ui-kit-community-u37`  
**SubAgent:** `primary` (for `auditor` workflow role)  
**Role:** `auditor`  
**References:** `REF-01`, `REF-02`, `REF-05`, `REF-06`, `REF-07`, `REF-09`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, audit the completed multi-target hybrid stress slice independently. Decide whether the combined evidence from the hybrid single-target proof, the screen-space 2D proof, and this multi-target hybrid stress pass is strong enough to call the contract seam battle-tested for broader adoption work, while still keeping verification labels conservative where needed.

**Folders Created/Deleted/Modified:**
- `.plans/` (notes/results only if needed)

**Files Created/Deleted/Modified:**
- optional audit notes if produced

**Status:** ⏳ Pending

**Results:** Awaiting audit.

---

## Final Results

**Status:** ⏳ Pending

**What We Built:** Pending execution.

**Reference Check:** Pending execution.

**Commits:**
- Pending

**Lessons Learned:** Pending execution.

---

*Drafted on 2026-05-15*