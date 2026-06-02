# AeroBeat UI Kit Community — Input Core Adoption for Hybrid UI

**Date:** 2026-05-15  
**Status:** Stale  
**Agent:** Byte 🐈‍⬛

---

## Goal

Adopt the new `aerobeat-input-core` UI interaction contract into `aerobeat-ui-kit-community/.testbed` through GodotEnv and prove that the hybrid world-space UI path can consume the shared contract end-to-end instead of repo-local raw Godot input plumbing.

---

## Overview

`aerobeat-input-core` now owns the approved composition-first UI interaction abstraction: one normalized `AeroUiInteractionEvent`, one canonical `phase`, one shared `AeroUiInteractionBus`, adapter scaffolding for screen/hybrid/XR paths, and truthful verification metadata that keeps touch/XR explicitly unverified. Audit concluded that this is ready for targeted downstream adoption by `aerobeat-ui-kit-community`, but not yet ready to be described as fully verified production interaction infrastructure. The next slice is therefore not to redesign the contract again, but to integrate it into the actual hybrid host path we care about and prove the mouse-first world-space panel flow end-to-end.

This adoption pass belongs in `aerobeat-ui-kit-community` because that repo owns the current hybrid world-space 3D GUI testbed and the local projected-hit/viewport wiring that was previously built directly into the scene controller. The high-level objective is to replace that repo-local raw/event-specific path with the shared `input-core` contract seam. That means wiring the GodotEnv dependency, feeding projected hit/surface data into the `HybridSubViewportInputAdapter`, routing normalized events through the shared bus/helpers, and updating the test scene so it truthfully demonstrates that the contract works in practice.

There is also one explicit validation milestone attached to this plan: use the `ui-kit-community` integration pass to determine whether `screen_mouse` + `hybrid_3d_gui` can remain only `prototype` or whether we now have enough evidence to promote that path later. Touch/XR are not required to become verified in this slice, but the integration should leave their paths structurally intact and clearly documented as unverified.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Active hybrid input proof plan/results | `.plans/2026-05-15-hybrid-3d-gui-input-detection.md` |
| `REF-02` | Current hybrid 3D GUI test scene | `.testbed/scenes/glass-shader-gui-3d-test.tscn` |
| `REF-03` | Current hybrid 3D GUI controller | `.testbed/scripts/glass_shader_gui_3d_test.gd` |
| `REF-04` | Shared authored panel source scene | `.testbed/scenes/glass-shader-panel-source.tscn` |
| `REF-05` | Shared authored panel source script | `.testbed/scripts/glass_shader_panel_source.gd` |
| `REF-06` | Approved input-core contract rollout doc | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-input-core/docs/ui-interaction-contract-v1.md` |
| `REF-07` | Approved input-core proposal doc | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-input-core/docs/ui-interaction-contract-v1-proposal.md` |
| `REF-08` | Input-core implementation commit | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-input-core@94a2e42` |
| `REF-09` | Input-core rollout/docs commit | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-input-core@22c4666` |
| `REF-10` | Input-core adoption-readiness audit conclusion | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-input-core/.plans/2026-05-15-ui-input-abstraction-contract.md` |

---

## Tasks

### Task 1: Design the ui-kit-community adoption approach around the approved input-core contract

**Bead ID:** `aerobeat-ui-kit-community-2j0`  
**SubAgent:** `primary` (for `research` workflow role)  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-06`, `REF-07`, `REF-08`, `REF-09`, `REF-10`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, inspect the current hybrid input-proof implementation and design the cleanest adoption path for the approved `aerobeat-input-core` contract. Be explicit about GodotEnv dependency wiring, how the current projected-hit/viewport data should feed `HybridSubViewportInputAdapter`, what repo-local raw input code should be replaced versus retained as host-integration responsibility, and how the scene should prove that downstream UI now depends on the shared contract rather than raw Godot input classes.

**Folders Created/Deleted/Modified:**
- `.plans/`
- `.testbed/`

**Files Created/Deleted/Modified:**
- optional adoption notes if needed

**Status:** ⏳ Pending

**Results:** Awaiting design.

---

### Task 2: Integrate aerobeat-input-core into ui-kit-community and wire the hybrid adapter end-to-end

**Bead ID:** `aerobeat-ui-kit-community-h01`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`, `REF-06`, `REF-08`, `REF-09`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, adopt the approved `aerobeat-input-core` contract into the `.testbed` Godot project through GodotEnv and replace the current repo-local hybrid input proof wiring with the shared bus/adapter contract where appropriate. Feed the scene’s projected hit/surface data into `HybridSubViewportInputAdapter`, keep downstream widget behavior on the normalized contract path, and preserve truthful verification semantics (mouse can remain prototype unless evidence justifies more, touch/XR remain unverified).

**Folders Created/Deleted/Modified:**
- `.testbed/`
- project dependency/config files as needed for GodotEnv integration

**Files Created/Deleted/Modified:**
- `.testbed/scenes/glass-shader-gui-3d-test.tscn`
- `.testbed/scripts/glass_shader_gui_3d_test.gd`
- any GodotEnv/dependency wiring files needed for `aerobeat-input-core`
- any local helper files needed to consume the shared contract

**Status:** ⚠️ Partial

**Results:** The hybrid testbed adoption landed in commit `a438614` (`Integrate input-core contract into hybrid testbed`) and correctly wired the host side of the contract seam: `.testbed/addons.jsonc` now pins `aerobeat-input-core` to rollout commit `22c4666efe96ba64b0f23907202a411000d72d41`, and `.testbed/scripts/glass_shader_gui_3d_test.gd` keeps ray picking / world-hit projection / hover-capture continuity / target-path resolution local while publishing projected data through `HybridSubViewportInputAdapter`. The authored panel source was also refactored toward `AeroUiInteractable` / `AeroUiInteractionListener`, and coder validation passed (`godotenv addons install`, headless scene boots, GUT, `git diff --check`). However, QA found a real runtime integration gap: the panel-side consumer helpers do not actually subscribe to the bus successfully at runtime because the configured `HYBRID_BUS_PATH` in `glass_shader_panel_source.gd` resolves incorrectly from the consumer child nodes. Result: host-level normalized events and status text update, but the visible panel proof behavior is not yet contract-driven in practice. Mouse on `hybrid_3d_gui` must remain `prototype`; touch remains `unverified`.

---

### Task 3: QA the integrated contract in the hybrid world-space testbed

**Bead ID:** `aerobeat-ui-kit-community-fz3`  
**SubAgent:** `primary` (for `qa` workflow role)  
**Role:** `qa`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-06`, `REF-10`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, verify that the hybrid testbed now consumes the shared `aerobeat-input-core` contract end-to-end. Confirm that downstream widget behavior is driven by normalized phases/bus helpers rather than repo-local raw input parsing, and truthfully assess whether desktop mouse on `hybrid_3d_gui` is still only `prototype` or now sufficiently proven to consider later promotion.

**Folders Created/Deleted/Modified:**
- `.temp/qa-evidence/` if useful

**Files Created/Deleted/Modified:**
- QA evidence artifacts if produced

**Status:** ✅ Complete

**Results:** Initial QA found a real runtime bug, not just a confidence gap: the host-side input-core seam was active and publishing normalized events, but the panel proof was not consuming those bus events at runtime because the configured relative `HYBRID_BUS_PATH` in `.testbed/scripts/glass_shader_panel_source.gd` resolved incorrectly from the runtime location of `AeroUiInteractable` / `AeroUiInteractionListener`. A targeted fix then landed in commit `e43baa2` (`Fix hybrid input-core runtime bus hookup`). That fix added runtime bus rebinding in `glass_shader_panel_source.gd`, including `set_interaction_bus_path(bus_path)`, ancestor fallback resolution for `AeroUiInteractionBus`, and explicit consumer helper connection to the resolved bus. The host scene in `.testbed/scripts/glass_shader_gui_3d_test.gd` now injects the runtime bus path into both mounted panel-source instances after ensuring the contract nodes exist. Direct runtime verification after the fix confirmed the visible panel proof now changes state from normalized contract events end-to-end: panel-side consumers resolve `/root/GlassShaderGui3DTest/AeroUiInteractionBus`, and publishing normalized hover/press/release phases updates the panel itself rather than only host status text. Verified probe output included `BUTTON_AFTER=true`, `SOURCE_LABEL=Source: screen_mouse (mouse 3 • touch 0)`, `POINTER_LABEL=Phase: press_end • tapped @ 800, 450`, `TOGGLE_LABEL=Surface: hybrid_glass_panel • Toggle: ON • taps 1`, and `COUNT_LABEL=Verification: prototype ...`. The scene now proves downstream contract consumption while still truthfully keeping `screen_mouse` + `hybrid_3d_gui` at `prototype` and touch at `unverified`. 

---

### Task 4: Audit whether ui-kit-community can now treat input-core as the real contract seam

**Bead ID:** `aerobeat-ui-kit-community-5e9`  
**SubAgent:** `primary` (for `auditor` workflow role)  
**Role:** `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-06`, `REF-08`, `REF-09`, `REF-10`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, audit the input-core adoption independently. Decide whether the hybrid host path now genuinely uses `aerobeat-input-core` as the contract seam, whether host-integration responsibilities remain cleanly separated from downstream UI consumers, and whether the resulting truth justifies continuing adoption work on other UI surfaces.

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