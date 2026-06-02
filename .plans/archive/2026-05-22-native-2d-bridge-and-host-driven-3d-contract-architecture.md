# AeroBeat UI Kit Community — Native 2D Bridge and Host-Driven 3D Contract Architecture

**Date:** 2026-05-22  
**Status:** Complete  
**Agent:** Byte 🐈‍⬛

---

## Goal

Restructure the interaction-contract architecture so normal 2D Godot UI uses native Godot input/state as the detection source and bridges that into the shared contracts, while hybrid 3D/XR/non-native surfaces remain host-driven and publish the same shared contract semantics explicitly.

---

## Overview

The desktop-truth hover bug work made the abstraction problem visible: for plain 2D Godot UI, we replaced mature built-in `Control` / `Button` hover and press handling with a custom forwarded-input ownership model. That made the 2D proof behave more like the hybrid 3D proof, but it also recreated logic Godot already solves natively and introduced fragile hover-owner bugs.

The architecture conclusion is now clear. The shared interaction contract should define normalized semantics (`hover_enter`, `hover_exit`, `press_begin`, `press_end`, `drag_*`, `cancel`, etc.), but it should not require all surfaces to detect input the same way. Native 2D UI should let Godot detect hover/press/focus and then translate those built-in transitions into the contract bus. Hybrid 3D/XR should keep host-side hit testing, projection, hover ownership, and explicit publish calls because Godot does not natively understand world-hit projection into a SubViewport UI.

The critical refinement from the final planning hardening pass is that these decisions are now written down durably instead of living only in chat/subagent output. This plan is now the authoritative summary of the native-2D bridge direction, the ownership boundary, and the semantic parity rules that must hold before implementation starts.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Shared input-contract definition | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-input-core/docs/ui-interaction-contract-v1.md` |
| `REF-02` | Contract proposal / design notes | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-input-core/docs/ui-interaction-contract-v1-proposal.md` |
| `REF-03` | Current 2D testbed host wiring | `.testbed/scripts/glass_shader_test.gd` |
| `REF-04` | Current hybrid 3D host wiring | `.testbed/scripts/glass_shader_gui_3d_test.gd` |
| `REF-05` | Input-core 2D adapter | `.testbed/addons/aerobeat-input-core/src/ui/adapters/screen_ui_input_adapter.gd` |
| `REF-06` | UI-core contract target binding / consumer base | `.testbed/addons/aerobeat-ui-core/scripts/contract/aero_ui_contract_target_binding.gd` and `.testbed/addons/aerobeat-ui-core/scripts/base/aero_contract_consumer_view_base.gd` |
| `REF-07` | Current desktop-truth hover bug plan/results | `.plans/2026-05-22-desktop-truth-2d-hover-bug-and-hybrid-shader-review.md` |

---

## Locked Architecture Decisions

### Repo ownership boundary

- **`aerobeat-input-core`** owns the canonical interaction contract:
  - `AeroUiInteractionEvent`
  - `AeroUiInteractionBus`
  - event/source/surface/phase taxonomy
  - verification-status model
  - native 2D bridge path
- **`aerobeat-ui-core`** owns reusable UI-side contract consumption:
  - target bindings
  - consumer base/helpers
  - interaction-state aggregation
  - reusable UI-facing behavior driven by normalized events
- **`aerobeat-ui-kit-community`** should not remain the long-term home of interaction infrastructure. It should become:
  - proof/demo scenes
  - reusable visual building blocks
  - example composition hosts
- **Hybrid/world/XR detection** remains host/provider driven because Godot does not natively solve world-hit → UI-target resolution.
- **Native 2D detection** should be Godot-driven because Godot already owns hover/press truth for ordinary `Control` / `BaseButton` UI.

### Detection-vs-publication split

- 2D native UI:
  - Godot detects
  - bridge publishes to contract
- 3D/XR/spatial UI:
  - host/provider detects
  - provider publishes to contract
- Both paths converge on the same `AeroUiInteractionBus` event semantics.

---

## Semantic Parity Matrix

These semantics are now treated as the required parity target for both the native 2D bridge and future spatial providers.

| Contract phase | Native 2D source-of-truth | Spatial source-of-truth | Ownership rule |
| --- | --- | --- | --- |
| `hover_enter` | `Control`/`BaseButton` native hover enter or hovered-target transition | projected target transition none/other → target | publish for the new hover owner only on ownership change |
| `hover_move` | mouse motion while hovered and not pressed | projected motion while same hover owner remains active and not pressed | publish for current hover owner |
| `hover_exit` | native hover exit or hovered-target transition target → none/other | projected target transition target → none/other | publish for previous hover owner before any new `hover_enter` |
| `press_begin` | native press truth on pressed control | projected press truth on hit target | target is the **press owner** |
| `press_hold` | motion while pressed and drag threshold not crossed | same | target remains press owner |
| `drag_begin` | threshold crossed after active press owner | same | target becomes/continues drag owner, usually same as press owner |
| `drag_move` | continued motion while dragging | same | drag owner remains captured |
| `drag_end` | release after dragging was active | same | publish before `press_end` |
| `press_end` | release after active press owner | same | target remains **press owner**, not current hover owner |
| `cancel` | interrupted lifecycle: control hidden/freed/disabled, pointer continuity lost, scene teardown, modal takeover | interrupted lifecycle or provider continuity loss | clear active press/drag state without pretending to be ordinary release |

### Additional policy decisions

- **Idle is derived, not emitted.** Idle means no hover owner, no active press owner, no active drag owner.
- **Release outside should normally stay `press_end`, not `cancel`,** unless lifecycle continuity was actually broken.
- **`press_end.target_path` must remain the press owner** so downstream tap/activation derivation stays stable.
- **Hover ownership and press/drag ownership are separate.** Hover may move independently while a press owner remains captured.
- **Target normalization should resolve to the nearest contract-bound target,** not incidental deep child nodes.

---

## Tasks

### Task 1: Research and define the responsibility boundary for native-2D bridge vs host-driven 3D/XR

**Bead ID:** `aerobeat-ui-kit-community-xie`  
**SubAgent:** `primary` (for `research` workflow role)  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`, `REF-06`  
**Prompt:** Compare the current 2D forwarded-input path with the current hybrid 3D path and define the intended long-term boundary: which responsibilities belong in `aerobeat-input-core`, which belong in `aerobeat-ui-core`, and which should stay scene-local in `aerobeat-ui-kit-community`. Focus especially on how a native 2D bridge should publish contract events without re-implementing hover detection.

**Folders Created/Deleted/Modified:**
- none unless notes are needed

**Files Created/Deleted/Modified:**
- optional design notes only

**Status:** ✅ Complete

**Results:** Boundary is now locked. `aerobeat-input-core` keeps the canonical interaction contract, event taxonomy, bus, and native 2D bridge. `aerobeat-ui-core` stays detection-agnostic and owns reusable UI-side bindings/consumers. `aerobeat-ui-kit-community` should shrink to proof/demo/building-block composition rather than long-term input glue. Native 2D should stop acting like projected input and publish contract events from Godot-native `Control`/`BaseButton` truth instead of manual hover reconstruction.

---

### Task 2: Design the native 2D bridge event-mapping model

**Bead ID:** `aerobeat-ui-kit-community-4sr`  
**SubAgent:** `primary` (for `research` workflow role)  
**Role:** `research`  
**References:** `REF-01`, `REF-03`, `REF-05`, `REF-06`, `REF-07`  
**Prompt:** Specify how normal Godot 2D `Control` / `Button` interaction should map into the shared contract bus: which native signals/events/states should produce `hover_enter`, `hover_exit`, `press_begin`, `press_end`, drag phases, cancel behavior, target ownership, and idle semantics. Call out any semantic mismatches that need explicit policy decisions so 2D and hybrid 3D still publish compatible contract meanings.

**Folders Created/Deleted/Modified:**
- none unless notes are needed

**Files Created/Deleted/Modified:**
- optional design notes only

**Status:** ✅ Complete

**Results:** Native 2D should publish the same contract phases but derive them from native control truth. The bridge must track separate hover owner, press owner, and drag owner. `hover_exit` publishes on target transition, `press_end` stays tied to the original press owner, drag phases come from native press + motion threshold logic, and `cancel` is reserved for interrupted lifecycle rather than ordinary release-outside. The explicit semantic matrix above captures the required parity.

---

### Task 3: Define the migration plan for repo ownership and implementation order

**Bead ID:** `aerobeat-ui-kit-community-683`  
**SubAgent:** `primary` (for `research` / `architect` workflow role)  
**Role:** `research`  
**References:** `REF-01`, `REF-05`, `REF-06`, `REF-07`  
**Prompt:** Produce a stepwise migration plan covering where code changes should land first (input-core, ui-core, ui-kit-community), how to preserve the working hybrid 3D path while swapping 2D to a native-event bridge, and what regression coverage / QA layers should exist before deprecating the current 2D forwarded-input path.

**Folders Created/Deleted/Modified:**
- none unless notes are needed

**Files Created/Deleted/Modified:**
- optional migration notes only

**Status:** ⏳ Pending

**Results:** This plan is now superseded by the broader cross-repo rollout plan in `.plans/2026-05-22-spatial-ui-repo-family-architecture-and-rollout.md`, which folds the native 2D bridge direction into the new spatial-ui family rollout. Use that plan as the authoritative migration sequence.

---

### Task 4: Audit the proposed architecture for hidden complexity or contract drift risk

**Bead ID:** `aerobeat-ui-kit-community-bus`  
**SubAgent:** `primary` (for `auditor` workflow role)  
**Role:** `auditor`  
**References:** `REF-01`, `REF-02`, `REF-05`, `REF-06`, `REF-07`  
**Prompt:** Independently review the proposed native-2D bridge / host-driven-3D architecture and identify any hidden risks: duplicated semantics, contract drift, missing phases, XR implications, or places where native 2D and host-driven 3D might diverge in ways that would surprise downstream consumers.

**Folders Created/Deleted/Modified:**
- `.plans/` if results update is needed

**Files Created/Deleted/Modified:**
- optional audit notes only

**Status:** ⏳ Pending

**Results:** The architecture-level audit concerns were folded into the broader spatial-ui family audit. The most important findings were: make `spatial-ui-core` helper-only rather than a second contract repo, write the semantic matrix durably, and do not begin implementation until stale bootstrap identity is cleaned from the new repos.

---

## Final Results

**Status:** ✅ Complete

**What We Built:** A durable architecture decision package for the native 2D bridge / host-driven 3D split. The plan now records the repo ownership boundary, the detection-vs-publication split, and the semantic parity matrix needed so native 2D and future spatial providers can publish the same interaction contract without re-implementing identical low-level detection.

**Reference Check:** `REF-01` and `REF-02` remain the canonical contract references in `aerobeat-input-core`. `REF-03` through `REF-05` provided the proof of what is currently wrong in the 2D path and what is currently working in the hybrid 3D path. `REF-06` confirmed that downstream contract consumers already stay detection-agnostic. `REF-07` provided the desktop-truth evidence that justified the architectural change.

**Commits:**
- none yet; this plan was a design hardening pass

**Lessons Learned:** The problem was not that Godot cannot handle ordinary 2D interaction. The problem was that the 2D proof replaced native detection with a projected-input style state machine and then drifted from the contract semantics we actually wanted. The durable fix is architectural: native 2D should detect natively and publish semantically; spatial/world/XR providers should detect non-natively and publish the same semantics.

---

*Completed on 2026-05-22*
