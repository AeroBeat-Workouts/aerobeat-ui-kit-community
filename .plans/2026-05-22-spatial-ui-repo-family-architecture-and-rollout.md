# AeroBeat Spatial UI Repo Family — Architecture and Rollout

**Date:** 2026-05-22  
**Status:** In Progress  
**Agent:** Byte 🐈‍⬛

---

## Goal

Plan the new `aerobeat-spatial-ui-*` repo family thoroughly enough that we can implement it across multiple repos with clear ownership, matching licensing/template conventions, updated documentation, and a migration path away from scene-local hybrid input glue.

---

## Overview

Derrick has set the product direction clearly: ordinary 2D UI should bridge native Godot interaction into the shared Aero interaction contract, while spatial/world/XR UI should use reusable contract-aware spatial input providers instead of per-scene bespoke logic. The new repo family should follow the same Aero style as `aerobeat-input-core`: a contract-owning baseline already exists in `input-core`, and the new family should contribute a shared spatial-provider layer plus focused concrete adapters that fulfill that contract without redefining it.

The proposed starting family is:
- `aerobeat-spatial-ui-core`
- `aerobeat-spatial-ui-mouse`
- `aerobeat-template-spatial-ui`

Future repos like `aerobeat-spatial-ui-touch` and `aerobeat-spatial-ui-xr` are expected later, but the first planning pass should already leave room for them in naming, architecture, docs, and repo template conventions. This is a cross-repo architecture rollout, not just a single implementation task. It touches current source repos (`aerobeat-input-core`, `aerobeat-ui-core`, `aerobeat-ui-kit-community`), the docs repo (`aerobeat-docs`), and the newly created GitHub repos that need licensing/readme/template setup.

The final planning hardening pass added three crucial constraints:
1. `aerobeat-spatial-ui-core` must stay **strictly helper-layer only** and must not become a second contract/bus/taxonomy repo parallel to `aerobeat-input-core`.
2. The planning package must be durable enough to survive a fresh context; therefore this file now records the closed-bead conclusions directly.
3. The new repos are not clean starting points: they still carry stale input-driver bootstrap identity, which must be treated as an explicit pre-implementation cleanup phase.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Shared UI interaction contract v1 | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-input-core/docs/ui-interaction-contract-v1.md` |
| `REF-02` | Contract proposal / design intent | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-input-core/docs/ui-interaction-contract-v1-proposal.md` |
| `REF-03` | Current 2D proof host wiring | `/workspace/projects/aerobeat/aerobeat-ui-kit-community/.testbed/scripts/glass_shader_test.gd` |
| `REF-04` | Current hybrid 3D proof host wiring | `/workspace/projects/aerobeat/aerobeat-ui-kit-community/.testbed/scripts/glass_shader_gui_3d_test.gd` |
| `REF-05` | Current screen adapter implementation | `/workspace/projects/aerobeat/aerobeat-ui-kit-community/.testbed/addons/aerobeat-input-core/src/ui/adapters/screen_ui_input_adapter.gd` |
| `REF-06` | Current UI-core contract consumer/binding layer | `/workspace/projects/aerobeat/aerobeat-ui-kit-community/.testbed/addons/aerobeat-ui-core/scripts/contract/aero_ui_contract_target_binding.gd` and `/workspace/projects/aerobeat/aerobeat-ui-kit-community/.testbed/addons/aerobeat-ui-core/scripts/base/aero_contract_consumer_view_base.gd` |
| `REF-07` | Desktop-truth hover bug architecture findings | `/workspace/projects/aerobeat/aerobeat-ui-kit-community/.plans/2026-05-22-desktop-truth-2d-hover-bug-and-hybrid-shader-review.md` |
| `REF-08` | Native 2D bridge / host-driven 3D architecture plan | `/workspace/projects/aerobeat/aerobeat-ui-kit-community/.plans/2026-05-22-native-2d-bridge-and-host-driven-3d-contract-architecture.md` |
| `REF-09` | Existing local repos available for comparison | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-input-core`, `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-core`, `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-docs` |
| `REF-10` | New GitHub repos provided by Derrick | `https://github.com/AeroBeat-Workouts/aerobeat-spatial-ui-core`, `https://github.com/AeroBeat-Workouts/aerobeat-spatial-ui-mouse`, `https://github.com/AeroBeat-Workouts/aerobeat-template-spatial-ui` |
| `REF-11` | Freshly cloned local repos for direct inspection | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-spatial-ui-core`, `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-spatial-ui-mouse`, `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-template-spatial-ui` |

---

## Locked Architecture Decisions

### Family meaning

- `aerobeat-input-core` remains the **only** canonical owner of:
  - normalized event shape
  - source/surface/phase taxonomy
  - interaction bus
  - verification-status truth model
  - native 2D bridge path
- `aerobeat-spatial-ui-core` is **not** a second contract repo. It must stay helper-layer only:
  - projected surface/provider abstractions
  - world/surface target-resolution conventions
  - hover/capture helper policies for spatial surfaces
  - reusable utilities shared by mouse/touch/xr spatial adapters
- `aerobeat-spatial-ui-mouse` is the first concrete spatial provider:
  - desktop mouse
  - world hit/raycast logic
  - projected mapping into UI surface coordinates
  - mouse-specific hover ownership / capture / drag behavior on spatial surfaces
  - publication into the existing `input-core` contract
- `aerobeat-ui-core` remains the reusable consumer/binding side.
- `aerobeat-ui-kit-community` becomes proof/demo/building-block composition, not long-term spatial input infrastructure.

### Thin-split rule

The template/core/mouse split is coherent only if it stays thin and strict:
- `template-spatial-ui` templates **concrete adapter repos**
- `spatial-ui-core` holds **shared provider helpers only**
- `spatial-ui-mouse` is the **first concrete provider**
- no duplication of contract taxonomy or consumer semantics across the new family

### Semantic parity rule

The native 2D bridge and the spatial providers must publish the same meanings for:
- hover ownership transitions
- press ownership
- drag begin/end
- release-outside behavior
- cancel behavior
- target retargeting during motion
- idle derivation

The detailed parity matrix is recorded in `REF-08` and is treated as the required semantic baseline before implementation starts.

---

## Open Questions Resolved During Planning

1. **Should `aerobeat-spatial-ui-core` define only the spatial-surface layer or also shared utilities?**  
   It should define the spatial-surface/provider helper layer and shared provider utilities, but not the canonical contract/bus/taxonomy.

2. **Should the native 2D bridge remain in `aerobeat-input-core`?**  
   Yes. Native 2D is generic contract-publication infrastructure, not spatial UI infrastructure.

3. **How much hybrid proof logic should migrate immediately?**  
   Enough to create a thin vertical slice proving the 3D glass panel through `aerobeat-spatial-ui-mouse`; the rest can remain temporarily in `ui-kit-community` until generalized.

4. **What licensing/template baseline should be copied?**  
   Match the modern `aerobeat-input-core` package pattern: MPL 2.0 `LICENSE.md`, hidden `.testbed/`, GodotEnv manifest/workflow, plugin package structure.

5. **How should docs categorize the new family?**  
   Near the UI lane, not the gameplay-input-provider lane.

6. **What minimum proof/demo scenes should each new repo ship with?**  
   Core should have at least one proof/demo surface; mouse should have a real spatial mouse demo scene; template should ship a minimal spatial adapter shell.

---

## Tasks

### Task 1: Define the repo-family architecture and responsibility boundaries

**Bead ID:** `aerobeat-ui-kit-community-vye`  
**SubAgent:** `primary` (for `research` workflow role)  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`, `REF-06`, `REF-07`, `REF-08`  
**Prompt:** Produce the architecture specification for the `aerobeat-spatial-ui-*` family. Clarify what belongs in `aerobeat-spatial-ui-core`, what belongs in `aerobeat-spatial-ui-mouse`, what stays in `aerobeat-input-core`, what stays in `aerobeat-ui-core`, and what remains scene-local in `aerobeat-ui-kit-community`. Explicitly account for the distinction between native 2D bridge behavior and spatial/world/XR input-provider behavior.

**Folders Created/Deleted/Modified:**
- planning/design notes only as needed

**Files Created/Deleted/Modified:**
- optional architecture notes only

**Status:** ✅ Complete

**Results:** The architecture boundary is now locked. `aerobeat-input-core` keeps the canonical contract and the native 2D bridge. `aerobeat-spatial-ui-core` is helper-layer only for spatial-provider infrastructure. `aerobeat-spatial-ui-mouse` is the first concrete spatial mouse provider. `aerobeat-ui-core` stays consumer-side. `aerobeat-ui-kit-community` remains proof/demo/building-block composition rather than long-term interaction infrastructure.

---

### Task 2: Define repo scaffolding, licensing, README, and template requirements

**Bead ID:** `aerobeat-ui-kit-community-3go`  
**SubAgent:** `primary` (for `research` workflow role)  
**Role:** `research`  
**References:** `REF-09`, `REF-10`  
**Prompt:** Compare the new repo family expectations against the existing `aerobeat-input-core` repo/template conventions and define exactly what each new repo needs: license, README structure, badges/sections, template metadata, starter GodotEnv/testbed expectations, and what the template repo should provide to downstream spatial-ui repos.

**Folders Created/Deleted/Modified:**
- planning/design notes only as needed

**Files Created/Deleted/Modified:**
- optional scaffolding notes only

**Status:** ✅ Complete

**Results:** The family should follow the modern Aero package pattern: MPL 2.0 `LICENSE.md`, repo-root package boundary, hidden `.testbed/`, GodotEnv manifest and CI, repo-local tests, optional manual scenes, and `plugin.cfg`. `aerobeat-template-spatial-ui` should template concrete adapter repos, not the shared core. This pass also established the expected README structure and template responsibilities, later refined by direct clone inspection.

---

### Task 3: Define rollout order and cross-repo migration plan

**Bead ID:** `aerobeat-ui-kit-community-9aw`  
**SubAgent:** `primary` (for `research` / `architect` workflow role)  
**Role:** `research`  
**References:** `REF-07`, `REF-08`, `REF-09`, `REF-10`  
**Prompt:** Create a stepwise rollout/migration plan covering: new repo bootstrap, extraction of reusable spatial mouse logic from the hybrid proof, where the native 2D bridge lands, how `ui-kit-community` evolves from proof scenes to reusable building blocks, how `aerobeat-docs` gets updated, and what order minimizes contract drift and duplicated work.

**Folders Created/Deleted/Modified:**
- planning/design notes only as needed

**Files Created/Deleted/Modified:**
- optional migration notes only

**Status:** ✅ Complete

**Results:** The rollout sequence is now defined as: **Phase 0** bootstrap cleanup, **Phase 1** freeze the ownership boundary in code, **Phase 2** extract reusable spatial mouse logic, **Phase 3** migrate `ui-kit-community` to consume packages instead of owning glue, **Phase 4** harden docs and template output. The recommended first implementation milestone is a thin vertical slice: clean/bootstrap `spatial-ui-core` and `spatial-ui-mouse`, define the minimal shared surface API, extract enough mouse logic to drive the existing 3D proof, and in parallel land the native 2D bridge direction in `aerobeat-input-core`.

---

### Task 4: Define docs-repo impact and required public architecture updates

**Bead ID:** `aerobeat-ui-kit-community-rj9`  
**SubAgent:** `primary` (for `research` workflow role)  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-09`, `REF-10`  
**Prompt:** Identify exactly what `aerobeat-docs` must say after this shift: repo table additions, architecture direction, repo-family purpose, relationship between `input-core`, `ui-core`, `ui-kit-community`, and `spatial-ui-*`, plus any onboarding guidance for future mouse/touch/xr adapter repos.

**Folders Created/Deleted/Modified:**
- planning/design notes only as needed

**Files Created/Deleted/Modified:**
- optional docs-impact notes only

**Status:** ✅ Complete

**Results:** `aerobeat-docs` needs repository-map additions, architecture wording updates, workflow/onboarding guidance, and API stubs for the new family. The public docs must state clearly that `input-core` owns the canonical UI interaction contract, `ui-core` owns reusable consumer-side helpers, `ui-kit-community` is a proof/visual-kit repo, and `spatial-ui-*` is the reusable family for world/hybrid/XR UI adapters.

---

### Task 5: Audit the overall plan for naming, scope, and contract-drift risks

**Bead ID:** `aerobeat-ui-kit-community-9rg`  
**SubAgent:** `primary` (for `auditor` workflow role)  
**Role:** `auditor`  
**References:** `REF-01`, `REF-02`, `REF-08`, `REF-09`, `REF-10`  
**Prompt:** Independently audit the proposed `aerobeat-spatial-ui-*` family plan. Check for naming confusion, duplicated responsibility with existing repos, risks of scene-local logic leaking back in, risk of native-2D and spatial-provider semantics drifting apart, and whether the template/core/mouse split is coherent at this stage.

**Folders Created/Deleted/Modified:**
- `.plans/` if results update is needed

**Files Created/Deleted/Modified:**
- optional audit notes only

**Status:** ✅ Complete

**Results:** The first audit failed for three valid reasons: the plan package was not durable enough, `spatial-ui-core` vs `input-core` was too fuzzy, and the semantic parity matrix was not written down explicitly. Those failure conditions were addressed by hardening both active plans, locking the ownership boundary durably, and recording the semantic parity rules explicitly. The rerun audit then passed and confirmed the planning package is now strong enough to end planning, land the plane, and reopen implementation in a fresh context. Remaining caveats are now treated as Phase 0 implementation blockers rather than planning gaps: stale input-driver bootstrap residue still exists in the three new repos and must be cleaned before extraction work begins.
---

### Task 6: Inspect the freshly cloned spatial-ui repos for stale template cleanup requirements

**Bead ID:** `aerobeat-ui-kit-community-z2x`  
**SubAgent:** `primary` (for `research` workflow role)  
**Role:** `research`  
**References:** `REF-09`, `REF-10`  
**Prompt:** Inspect the freshly cloned local repos `aerobeat-spatial-ui-core`, `aerobeat-spatial-ui-mouse`, and `aerobeat-template-spatial-ui` directly. Identify exactly which files, workflows, README sections, plugin metadata, and template leftovers still reflect the old input-driver bootstrap and therefore must be cleaned up or replaced before implementation starts.

**Folders Created/Deleted/Modified:**
- planning/design notes only as needed

**Files Created/Deleted/Modified:**
- optional inspection notes only

**Status:** ✅ Complete

**Results:** Direct inspection confirmed the new repos still carry stale input-driver bootstrap identity. Across the family, the concrete stale footprint is concentrated in `README.md`, `plugin.cfg`, `.testbed/addons.jsonc`, `.testbed/tests/test_example.gd`, and `.testbed/project.godot`. `aerobeat-template-spatial-ui` is also missing workflow scaffolding and contains duplicate `LICENSE` + `LICENSE.md`. This makes bootstrap cleanup an explicit Phase 0 blocker before implementation starts.

---

## Pre-Implementation Blockers

The audit identified these blockers, which are now explicitly recorded here:

1. **Do not let `spatial-ui-core` drift into contract ownership.** It is helper-layer only.
2. **Do not start implementation until stale bootstrap identity is cleaned** from the three new repos.
3. **Do not let native 2D and spatial providers publish divergent meanings.** The semantic parity matrix in `REF-08` is the baseline.
4. **Do not let `ui-kit-community` remain the long-term owner of spatial mouse glue.** It must become a consumer/example repo over time.

---

## Final Results

**Status:** ✅ Planning Complete / Ready for Phase 0 Implementation

**What We Built:** A durable cross-repo planning package for the `aerobeat-spatial-ui-*` family: ownership boundaries, scaffolding/template expectations, docs impact, cloned-repo cleanup checklist, rollout sequencing, explicit pre-implementation blockers, and a passing independent audit after hardening.

**Reference Check:** `REF-01` and `REF-02` remain the canonical input-contract references. `REF-03` through `REF-07` explain the proof-scene motivation and the desktop-truth failures that justified the architecture shift. `REF-08` durably captures the native 2D bridge and semantic parity rules. `REF-09` and `REF-11` grounded the family plan against real local repo patterns and the actual freshly cloned repos rather than guesses.

**Commits:**
- none yet; this was planning/hardening work only

**Lessons Learned:** The architecture direction itself was sound, but the first planning package was not durable enough. The key hardening lessons were: write the ownership boundary explicitly, prevent `spatial-ui-core` from becoming a second contract repo, record the semantic parity matrix before implementation, and inspect the real cloned repos instead of trusting the old template bootstrap.

**Next Slice:** Begin **Phase 0** only: clean bootstrap residue from `aerobeat-spatial-ui-core`, `aerobeat-spatial-ui-mouse`, and `aerobeat-template-spatial-ui` before any feature extraction or bridge implementation work.

---

*Planning completed and audit-passed on 2026-05-22; ready to reopen implementation in a fresh context*
