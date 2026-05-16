# AeroBeat UI Kit Community — Input Core Adoption for Screen-Space 2D UI

**Date:** 2026-05-15  
**Status:** Draft  
**Agent:** Byte 🐈‍⬛

---

## Goal

Adopt the approved `aerobeat-input-core` interaction contract into a plain screen-space 2D UI slice inside `aerobeat-ui-kit-community/.testbed`, so we prove the contract works cleanly outside the hybrid world-space path before moving on to a planned multi-target hybrid stress pass.

---

## Overview

We already proved that `aerobeat-input-core` can serve as the real contract seam for the current hybrid world-space glass panel testbed. That gives us one validated path where the host scene owns raycast/projection glue and downstream UI consumes normalized contract events. But that proof alone is not enough to say the contract is generally reusable. The next smart move is to test the same contract in a simpler environment: a normal screen-space 2D UI where there is no world-hit math, no SubViewport projection, and no hybrid-specific routing burden. If the contract is sound, it should feel even cleaner here.

This slice belongs in `aerobeat-ui-kit-community` because that repo already owns the hidden `.testbed` where shared UI adoption proofs live. The purpose is to wire a 2D panel through `AeroUiInteractionBus`, `ScreenUiInputAdapter`, and `AeroUiInteractable` / `AeroUiInteractionListener`, and to prove that visible widget behavior reacts to normalized phases rather than raw `gui_input` parsing. The result should give us a baseline screen-space reference implementation that is easier to reason about than the hybrid path and serves as a second strong signal that the contract is reusable.

This plan also deliberately records the next step after this one: a separate **multi-target hybrid adoption slice**. That later slice should pressure-test target routing, hover transitions between multiple elements, and more complex hybrid target-path resolution. We are not doing that work in this plan, but we are planning for it explicitly so the 2D proof is understood as step two of a broader contract hardening sequence, not the finish line.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Completed hybrid input-core adoption plan/results | `.plans/2026-05-15-input-core-adoption-for-hybrid-ui.md` |
| `REF-02` | Hybrid adoption design note | `docs/notes/2026-05-15-input-core-hybrid-adoption-design.md` |
| `REF-03` | Approved input-core contract rollout doc | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-input-core/docs/ui-interaction-contract-v1.md` |
| `REF-04` | Approved input-core proposal doc | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-input-core/docs/ui-interaction-contract-v1-proposal.md` |
| `REF-05` | Input-core implementation commit | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-input-core@94a2e42` |
| `REF-06` | Input-core rollout/docs commit | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-input-core@22c4666` |
| `REF-07` | Input-core hybrid hookup fix commit | `.git@e43baa2` |
| `REF-08` | Current hybrid host scene/controller for comparison | `.testbed/scenes/glass-shader-gui-3d-test.tscn` / `.testbed/scripts/glass_shader_gui_3d_test.gd` |
| `REF-09` | Current authored panel source script for comparison | `.testbed/scripts/glass_shader_panel_source.gd` |
| `REF-10` | Testbed dependency manifest | `.testbed/addons.jsonc` |

---

## Tasks

### Task 1: Design the screen-space 2D adoption path using the approved input-core contract

**Bead ID:** `aerobeat-ui-kit-community-svt`  
**SubAgent:** `primary` (for `research` workflow role)  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-08`, `REF-09`, `REF-10`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, inspect the current `.testbed` structure and design the cleanest screen-space 2D adoption slice for `aerobeat-input-core`. Identify the best candidate 2D panel/surface to use, how `AeroUiInteractionBus` and `ScreenUiInputAdapter` should be introduced, which visible proof elements should react to normalized phases, and what should be demonstrated so this slice clearly proves contract reuse outside the hybrid path.

**Folders Created/Deleted/Modified:**
- `.plans/`
- `.testbed/`
- `docs/notes/` if useful

**Files Created/Deleted/Modified:**
- optional design/adoption note

**Status:** ⏳ Pending

**Results:** Awaiting design.

---

### Task 2: Implement the screen-space 2D input-core adoption slice in `.testbed`

**Bead ID:** `aerobeat-ui-kit-community-gqm`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-03`, `REF-05`, `REF-06`, `REF-09`, `REF-10`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, implement a plain screen-space 2D UI proof that consumes `aerobeat-input-core` through `AeroUiInteractionBus`, `ScreenUiInputAdapter`, and `AeroUiInteractable` / `AeroUiInteractionListener`. Ensure the visible proof behavior is driven by normalized contract phases and verification metadata rather than raw `gui_input` parsing as the source of truth. Keep this slice simple and explicit; it should be the clean baseline counterpart to the hybrid adoption proof.

**Folders Created/Deleted/Modified:**
- `.testbed/`

**Files Created/Deleted/Modified:**
- candidate screen-space scene/script files selected by Task 1
- any minimal local proof helpers if truly needed
- dependency/config files only if needed

**Status:** ✅ Complete

**Results:** The screen-space 2D input-core proof landed in commit `896770e` (`Add screen 2D input-core contract proof`). The existing 2D host scene now contains scene-local `AeroUiInteractionBus` and `ScreenUiInputAdapter`, and `.testbed/scripts/glass_shader_test.gd` keeps only a small host glue layer: it mounts the shared panel source, resolves the `PreviewButton` target path, publishes mouse/touch into `ScreenUiInputAdapter.publish_input_event(...)`, provides minimal capture continuity for interactions that begin on the card, and exposes a host-side normalized contract status readout. The shared panel source script was generalized so the same consumer-side contract proof now works for both `hybrid_glass_panel` and `screen_glass_panel`, while preserving contract-driven visible behavior through `AeroUiInteractable` / `AeroUiInteractionListener` instead of raw `gui_input` or native button signals as the seam. Coder-reported validation included headless editor boot, headless screen-mouse and screen-touch smoke probes, and `git diff --check`; the proof remains truthful with `screen_mouse` + `screen_2d` at `prototype` and touch at `unverified`. 

---

### Task 3: QA the screen-space 2D contract proof and compare it to the hybrid path

**Bead ID:** `aerobeat-ui-kit-community-5tp`  
**SubAgent:** `primary` (for `qa` workflow role)  
**Role:** `qa`  
**References:** `REF-01`, `REF-03`, `REF-09`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, verify that the new screen-space 2D proof really consumes `aerobeat-input-core` end-to-end and that its visible behavior is contract-driven. Compare the resulting simplicity and clarity against the hybrid path, and truthfully assess what is proven here versus what still remains specifically hybrid-only or unverified.

**Folders Created/Deleted/Modified:**
- `.temp/qa-evidence/` if useful

**Files Created/Deleted/Modified:**
- QA evidence artifacts if produced

**Status:** ✅ Complete

**Results:** QA passed with conservative scope. The new screen-space 2D host was verified to contain and use `AeroUiInteractionBus` + `ScreenUiInputAdapter`, and the host-side glue in `.testbed/scripts/glass_shader_test.gd` stayed meaningfully smaller than the hybrid path: mount the shared panel, resolve the `PreviewButton` target path, publish mouse/touch through `ScreenUiInputAdapter.publish_input_event(...)`, and preserve only minimal continuity for interactions that begin on-card. Headless runtime probes confirmed that visible UI proof state is contract-driven end-to-end in the 2D host: source label, phase/pointer summary, toggle/tap state, verification label, and host readout vs in-card readout all update from normalized contract events. QA also confirmed the shared panel source script now works cleanly for both `screen_glass_panel` and `hybrid_glass_panel`, and that the `PreviewButton` is not secretly using direct mouse input as the proof seam. Repo-local validation passed (`git diff --check`, headless import, GUT tests). Important limits remain truthful: this is still primarily headless/synthetic-event validation, touch behavior is still unverified, and `screen_mouse` + `screen_2d` should remain `prototype` for now rather than being promoted.

---

### Task 4: Audit whether the contract is now battle-tested enough to justify the planned multi-target hybrid slice

**Bead ID:** `aerobeat-ui-kit-community-fqd`  
**SubAgent:** `primary` (for `auditor` workflow role)  
**Role:** `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-08`, `REF-09`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, audit the completed screen-space 2D adoption slice independently. Decide whether the combined evidence from the hybrid proof plus this new 2D proof is strong enough to justify the next planned multi-target hybrid stress pass, and identify the minimum technical questions that follow-on slice should be designed to answer.

**Folders Created/Deleted/Modified:**
- `.plans/` (notes/results only if needed)

**Files Created/Deleted/Modified:**
- optional audit notes if produced

**Status:** ⏳ Pending

**Results:** Awaiting audit.

---

## Planned Follow-On (not executed in this plan)

### Multi-target hybrid adoption stress slice

This plan intentionally queues a later follow-on slice after the 2D proof completes. That follow-on should:
- use a hybrid/world-space surface again
- include multiple interactive targets instead of one main `PreviewButton`
- test target-path routing across multiple elements
- test hover transitions between targets
- test whether the same host/panel split still holds without special-casing a single control
- keep verification labels conservative unless stronger evidence is gathered

This follow-on should be written as its own dedicated plan after the current 2D slice completes.

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