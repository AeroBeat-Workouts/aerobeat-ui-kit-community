# AeroBeat Spatial Provider Human Verification Harness Parity

**Date:** 2026-05-24  
**Status:** In Progress  
**Last Updated:** 2026-05-24 13:13 EDT
**Blocked Reason:** None  
**Agent:** `byte`

---

## Goal

Add truthful human-verifiable provider-owned testing scenes for the AeroBeat spatial input lanes so `aerobeat-spatial-ui-touch` and `aerobeat-spatial-ui-xr` reach the same architectural verification standard expected of the spatial family, while keeping `aerobeat-ui-kit-community` as downstream integration proof rather than provider-semantics ownership.

---

## Overview

We already hardened the spatial-family ownership split: `aerobeat-input-core` owns the canonical contract and native 2D bridge, `aerobeat-spatial-ui-core` owns shared helper infrastructure only, the concrete `aerobeat-spatial-ui-*` repos own lane-specific provider behavior, and `aerobeat-ui-kit-community` owns downstream proof-host composition rather than long-term provider semantics. The next step is to make that split human-verifiable.

The current mouse lane has a provider-owned verification harness, but it is still more of a semantic truth bench than a real hybrid-panel proof host. Touch and XR currently lack equivalent provider-owned human harness scenes entirely. This plan therefore focuses on the provider repos themselves: each lane should own a reusable human-verifiable harness that proves the packaged provider emits the right Aero contract semantics without leaning on `ui-kit-community` to reinvent provider behavior locally.

`aerobeat-ui-kit-community` should remain the downstream integration proof surface. It can validate that contract-aware UI primitives behave correctly when composed into a real hybrid host, but it should not be the first place where we discover whether a provider’s hover/press/drag/release/cancel semantics are truthful. Those semantics should already be proven inside the provider repo before they are consumed downstream.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Archived spatial family rollout plan and ownership baseline | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/.plans/archive/2026-05-22-spatial-ui-repo-family-architecture-and-rollout.md` |
| `REF-02` | Native-2D bridge vs host-driven spatial-provider semantic parity baseline | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/.plans/2026-05-22-native-2d-bridge-and-host-driven-3d-contract-architecture.md` |
| `REF-03` | Existing mouse provider harness scene | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-spatial-ui-mouse/.testbed/scenes/mouse_provider_verification_harness.tscn` |
| `REF-04` | Existing mouse provider harness script | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-spatial-ui-mouse/.testbed/scripts/mouse_provider_verification_harness.gd` |
| `REF-05` | Touch provider repo current runtime/testbed baseline | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-spatial-ui-touch` |
| `REF-06` | XR provider repo current runtime/testbed baseline | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-spatial-ui-xr` |
| `REF-07` | Reconciled downstream consumer proof baseline | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community` |

---

## Locked Planning Assumptions

- Provider-owned human verification belongs in the concrete provider repos, not in `aerobeat-spatial-ui-core`.
- `aerobeat-spatial-ui-core` stays helper-only and does not become a family-level end-to-end runtime/demo repo.
- `aerobeat-ui-kit-community` remains the downstream integration proof host and must not re-own provider semantics locally.
- Human-verifiable provider harnesses should prove lane behavior and contract publication truth, even if they do not use the full Aero glass visual style.
- The same semantic parity rules in `REF-02` still apply: hover/press/drag/release/cancel meaning must match the contract baseline.

---

## Tasks

### Task 1: Define the provider-harness parity standard from the current mouse lane

**Bead ID:** `aerobeat-ui-kit-community-3t1a` (research), `aerobeat-ui-kit-community-tj9t` (auditor)  
**SubAgent:** `primary` (for `research`)  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** Inspect the current mouse provider verification harness and define the target parity standard for provider-owned human verification across the spatial family. Document what is good enough to count as a provider-owned human-verifiable harness, what it must prove about contract semantics, what runtime/debug state it must expose, and what it explicitly does not need to own because that remains downstream consumer proof.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-spatial-ui-mouse/`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/` (notes only if needed)

**Files Created/Deleted/Modified:**
- `docs/notes/2026-05-24-spatial-provider-human-verification-harness-parity-standard.md`
- `.plans/2026-05-24-spatial-provider-human-verification-harness-parity.md`

**Status:** ✅ Complete

**Results:** Researched the current mouse lane harness (`REF-03`, `REF-04`) plus its repo-local support/tests and wrote the parity standard to `docs/notes/2026-05-24-spatial-provider-human-verification-harness-parity-standard.md`. The standard defines what counts as a provider-owned human-verifiable harness across the spatial family: provider repos must own a hidden `.testbed` harness that exercises the packaged provider directly, publishes through the canonical `aerobeat-input-core` contract path, exposes both normalized event truth and provider-owned runtime/debug truth, and pairs the scene with repo-local tests. It also locks the non-ownership boundary: these harnesses must not absorb world-hit acquisition, hybrid proof-scene composition, downstream host UX proof, canonical verification-status policy, or shared-helper ownership. The current mouse lane already provides the reference shape for this standard: synthetic projected-hit bench in the provider repo, packaged-provider identity/readout, runtime-state snapshot exposure, off-surface release coverage, and explicit non-promotion of `verification_status`. This gives touch and XR a concrete parity bar without widening into implementation or downstream UI-kit work. Auditor pass: reviewed against `REF-01`, `REF-02`, `REF-03`, and `REF-04`; the packet is durable and precise enough to guide touch/XR/mouse without reopening ownership confusion, clearly separates provider-owned harness proof from downstream `aerobeat-ui-kit-community` integration proof, states the required semantic/runtime/debug proof categories plus explicit non-ownership boundaries, and shows no hidden scope drift into making `aerobeat-spatial-ui-core` a runtime demo host or `aerobeat-ui-kit-community` the first semantic truth source again.

---

### Task 2: Implement a provider-owned human verification harness in `aerobeat-spatial-ui-touch`

**Bead ID:** `aerobeat-spatial-ui-touch-qp6` (coder), `aerobeat-spatial-ui-touch-kva` (qa), `aerobeat-spatial-ui-touch-c58` (auditor)  
**SubAgent:** `primary`  
**Role:** `coder` → `qa` → `auditor`  
**References:** `REF-02`, `REF-05`  
**Prompt:** Create the first truthful provider-owned human verification harness for `aerobeat-spatial-ui-touch`. The harness should let a human verify that the packaged touch provider is the runtime path in use and that it publishes the correct Aero contract semantics and truthful runtime state. Keep world-hit acquisition, proof-scene composition, and downstream integration proof out of this repo. Add only the minimum repo-local tests/docs needed to prove the harness and preserve `verification_status == unverified` truth where required.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-spatial-ui-touch/`

**Files Created/Deleted/Modified:**
- `.testbed/scenes/` provider-owned touch verification scene(s)
- `.testbed/scripts/` touch verification harness scripts
- `.testbed/tests/` touch verification tests
- supporting docs/README updates as needed

**Status:** ✅ Complete

**Results:** Implemented the first provider-owned touch human verification harness in `REF-05` while keeping world-hit acquisition, proof-scene composition, and downstream integration proof outside this repo. Added `.testbed/scenes/touch_provider_verification_harness.tscn` and `.testbed/scripts/touch_provider_verification_harness.gd`, which boot the packaged touch provider through the repo-local harness seam and expose a live HUD for packaged-provider identity, canonical contract publication truth (`source_variant`, `phase`, `target_path`, `verification_status`, `verification_notes`), and provider-owned runtime truth (`active_pointer_id`, `state_phase`, owner/live/preferred target continuity, `last_release_target_path`, `last_forwarded_panel_event`, projected-hit summary). Expanded `.testbed/tests/support/touch_provider_test_harness.gd` with shared runtime attachment and `describe_harness_snapshot()` so the human scene and tests both read the same provider-owned truth packet rather than rebuilding host state locally. Added `.testbed/tests/test_touch_provider_verification_harness_scene.gd` to assert that the harness proves the packaged touch runtime seam is in use and that `verification_status` stays unpromoted at `unverified`; also updated the manifest/runtime-boundary ownership markers plus README and the phase-3 packet status to document the new harness boundary. Repo-local validation run by coder: `godot --headless --path .testbed --import` ✅, `godot --headless --path .testbed --script addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit` ✅ (13/13 tests passing, 195 asserts). Commit pushed to `main`: `3395d59` (`Add touch provider verification harness`). QA pass re-ran both commands successfully and reviewed the harness/runtime seam against `REF-02` and `REF-05`: the scene instantiates the packaged touch provider through the shared repo-local harness seam (`.testbed/scripts/touch_provider_verification_harness.gd` preloads `.testbed/tests/support/touch_provider_test_harness.gd`, which loads `res://../src/providers/touch/aero_spatial_ui_touch_provider.gd` and exposes the same `describe_harness_snapshot()` path used by the tests); the HUD and tests report truthful provider identity plus canonical contract event truth (`source_variant == screen_touch`, `phase`, `target_path`, `verification_status == unverified`, and bus-delivered event continuity) without overclaiming verification; the provider-owned probe/runtime truth remains shared between the human harness and tests (`describe_harness_snapshot()` delegates to `provider.describe_verification_probe()` for owner/live/preferred target continuity, active pointer state, last release target, last forwarded panel event, and projected-hit metadata); and ownership boundaries stayed intact because the manifest/runtime-boundary/README all continue to declare no proof-host world-hit acquisition ownership, no proof-scene composition ownership, and no downstream proof-host ownership drift into the touch repo. Auditor pass: independently re-ran `godot --headless --path .testbed --import` and the full GUT suite (`godot --headless --path .testbed --script addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`) on `REF-05` current main at `3395d59`, with 13/13 tests and 195 asserts passing. Code and test audit confirmed the harness is a truthful provider-owned verification seam rather than a disguised downstream proof host: `.testbed/tests/support/touch_provider_test_harness.gd` instantiates the packaged touch provider directly, shares one provider-owned snapshot path with the human harness/tests, and only accepts synthetic surface/hit context instead of re-owning world-hit acquisition or proof-host composition; `.testbed/scenes/touch_provider_verification_harness.tscn` plus `.testbed/scripts/touch_provider_verification_harness.gd` expose packaged-provider identity, canonical contract publication truth, unpromoted `verification_status`, and provider runtime/debug truth to a human-readable HUD; `.testbed/tests/test_touch_provider_verification_harness_scene.gd` and `.testbed/tests/test_touch_provider_probe_snapshot.gd` durably prove packaged-provider identity, shared provider-owned snapshot truth, owner/live/preferred target continuity, release continuity, and `verification_status == unverified`; and `src/providers/touch/aero_spatial_ui_touch_manifest.gd`, `src/providers/touch/aero_spatial_ui_touch_runtime_boundary.gd`, `README.md`, and `test_touch_provider_dependency_boundary.gd` lock the non-ownership boundary around contract ownership, shared-helper ownership, world-hit acquisition, proof-scene composition, and downstream proof-host behavior. The plan’s prior coder/QA claims for this slice are accurate and durable.

---

### Task 3: Implement a provider-owned human verification harness in `aerobeat-spatial-ui-xr`

**Bead ID:** `aerobeat-spatial-ui-xr-4c1` (coder), `aerobeat-spatial-ui-xr-gtt` (qa), `aerobeat-spatial-ui-xr-n4k` (auditor)  
**SubAgent:** `primary`  
**Role:** `coder` → `qa` → `auditor`  
**References:** `REF-02`, `REF-06`  
**Prompt:** Create the first truthful provider-owned human verification harness for `aerobeat-spatial-ui-xr`. The harness should let a human verify that the packaged XR provider is the runtime path in use and that it publishes the correct Aero contract semantics and truthful runtime state, while keeping XR rig wiring, world-hit acquisition, and downstream proof-host composition outside the provider repo where appropriate.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-spatial-ui-xr/`

**Files Created/Deleted/Modified:**
- `.testbed/scenes/xr_provider_verification_harness.tscn`
- `.testbed/scripts/xr_provider_verification_harness.gd`
- `.testbed/tests/support/xr_provider_test_harness.gd`
- `.testbed/tests/test_xr_provider_verification_harness.gd`
- `README.md`

**Status:** ✅ Complete

**Results:** Implemented the first provider-owned XR human verification harness in `REF-06` without absorbing downstream ownership. Added `.testbed/scenes/xr_provider_verification_harness.tscn` and `.testbed/scripts/xr_provider_verification_harness.gd`, which instantiate the packaged `AeroSpatialUiXrProvider` via repo-local harness support and expose a live HUD plus synthetic-provider controls for hover, press, drag-to-secondary, release-off-surface, and interruption-only cancel. This keeps XR rig wiring, world-hit acquisition, and proof-host composition out of the provider repo while still letting a human verify packaged-provider identity, canonical contract publication (`source_variant`, `phase`, `target_path`, `verification_status`, `verification_notes`), and truthful runtime state (`owner/live target`, `locked_source_variant`, `last_release_target_path`, `last_terminal_result`, `last_interruption_reason`, `last_forwarded_panel_event`). Expanded `.testbed/tests/support/xr_provider_test_harness.gd` so both tests and the scene share one packaged-provider runtime seam, and added `.testbed/tests/test_xr_provider_verification_harness.gd` to assert harness truth for packaged-provider identity, unpromoted `verification_status == unverified`, release continuity, and interruption-only cancel semantics. Updated `README.md` with the new harness and the explicit verification workflow. Repo-local validation run by coder: `godot --headless --path .testbed --import` ✅, then `godot --headless --path .testbed --script addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit` ✅ (11/11 tests passing, including the new harness coverage). QA pass re-ran both commands successfully and reviewed the harness/runtime seam against `REF-02` and `REF-06`: the scene boots through the shared repo-local harness seam into the packaged `AeroSpatialUiXrProvider` (`.testbed/tests/support/xr_provider_test_harness.gd` preloads the installed provider script and `describe_snapshot()` reports `provider_runtime_seam = installed_packaged_provider` / `provider_runtime_source = AeroSpatialUiXrProvider`), contract truth remains canonical and unpromoted (`verification_status == unverified`, `verification_notes` preserved, `source_variant` / `phase` / `target_path` exposed through the bus path), release continuity remains truthful (`locked_source_variant` and `last_release_target_path` stay bound to the original press owner even when release arrives off-surface from `xr_direct` / `contact`), and cancel stays interruption-only (`publish_cancel("tracking_lost")` is the only terminal cancel path covered by the harness/tests). Ownership boundaries also stayed intact: the runtime boundary and README continue to declare no scene-specific XR rig setup, no proof-host world-hit acquisition ownership, and no proof-scene composition ownership. Auditor pass: independently re-ran `godot --headless --path .testbed --import` and the full GUT suite (`godot --headless --path .testbed --script addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`) on `REF-06` current main at `bf0335f`, with 11/11 tests and 227 asserts passing. Code and test audit confirmed the harness is a truthful provider-owned verification seam rather than a disguised downstream proof host: `.testbed/tests/support/xr_provider_test_harness.gd` instantiates the packaged provider directly, uses packaged shared helpers plus synthetic projected hits, and only accepts host-supplied surface/hit context instead of re-owning XR rig wiring or world-hit acquisition; `.testbed/scenes/xr_provider_verification_harness.tscn` and `.testbed/scripts/xr_provider_verification_harness.gd` expose packaged-provider identity, canonical contract publication truth, provider runtime/debug truth, unpromoted `verification_status`, release continuity, and interruption-only cancel semantics to a human-readable HUD; and `src/providers/xr/aero_spatial_ui_xr_manifest.gd`, `src/providers/xr/aero_spatial_ui_xr_runtime_boundary.gd`, `README.md`, and `test_xr_provider_dependency_boundary.gd` durably lock the non-ownership boundary around contract ownership, shared-helper ownership, XR rig wiring, world-hit acquisition, and proof-scene composition. The plan’s prior coder/QA claims for this slice are accurate and durable.

---

### Task 4: Audit the mouse lane against the new provider-harness standard

**Bead ID:** `aerobeat-spatial-ui-mouse-7xs` (research), `aerobeat-spatial-ui-mouse-8e6` (coder), `aerobeat-spatial-ui-mouse-6qb` (qa), `aerobeat-spatial-ui-mouse-dgj` (auditor)  
**SubAgent:** `primary`  
**Role:** `research` → `coder` → `qa` → `auditor`  
**References:** `REF-03`, `REF-04`  
**Prompt:** Compare the existing mouse provider harness against the newly defined provider-harness parity standard. If the mouse lane already satisfies the standard, document that clearly. If it falls short, make only the narrow changes needed so mouse, touch, and XR share the same harness expectations without turning the mouse repo into a downstream proof-host clone.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-spatial-ui-mouse/`

**Files Created/Deleted/Modified:**
- mouse harness scene/script/tests/docs only if parity adjustments are needed

**Status:** ✅ Complete

**Results:** Research assessment completed against the parity standard in `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/docs/notes/2026-05-24-spatial-provider-human-verification-harness-parity-standard.md` plus the current mouse harness scene/script (`REF-03`, `REF-04`), support harness, and repo-local tests/docs. Result: the mouse lane already satisfies the new provider-harness parity standard as written, so no code or harness follow-up is needed for mouse. The current provider repo already owns a hidden `.testbed` harness; it instantiates the packaged provider directly through `tests/support/mouse_provider_test_harness.gd` (`PROVIDER_SCRIPT_PATH`), uses synthetic projected hits and a configured `AeroSpatialSurfaceDescriptor` instead of downstream world-hit/proof-host ownership, publishes through the canonical `aerobeat-input-core` bus/adapter path, exposes the required human-readable HUD/event/runtime truth in `.testbed/scripts/mouse_provider_verification_harness.gd`, and pairs that harness with repo-local tests covering runtime-state truth, off-surface release continuity, dependency-boundary truth, and non-promoted `verification_status`. Narrow gap assessment: none relative to the new standard; mouse is the reference implementation the standard was derived from. The next work should stay focused on bringing touch and XR up to this already-met mouse baseline rather than reopening the mouse harness.

---

### Task 5: Document the trust boundary in `aerobeat-ui-kit-community`

**Bead ID:** `aerobeat-ui-kit-community-wfso` (coder), `aerobeat-ui-kit-community-ot9s` (qa), `aerobeat-ui-kit-community-cq2z` (auditor)  
**SubAgent:** `primary`  
**Role:** `coder` → `qa` → `auditor`  
**References:** `REF-01`, `REF-02`, `REF-07`  
**Prompt:** Add or refine lightweight docs/notes in `aerobeat-ui-kit-community` so the downstream proof-host repo explicitly states the new trust boundary: provider semantics are proven in the provider repos, while `ui-kit-community` proves composed contract-aware UI behavior in a downstream host. Keep this slice docs-only unless a tiny proof note or non-behavioral marker is needed.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/`

**Files Created/Deleted/Modified:**
- docs/notes only

**Status:** ✅ Complete

**Results:** Added a durable downstream trust-boundary note at `docs/notes/2026-05-24-ui-kit-community-provider-trust-boundary.md` and updated `README.md` so `aerobeat-ui-kit-community` now states the current spatial-family split explicitly from the consumer side. The new docs lock that provider repos (`aerobeat-spatial-ui-mouse`, `...-touch`, `...-xr`) must prove packaged-provider semantics and provider-owned runtime truth in their own repo-local harnesses/tests first, while this repo proves downstream installed-addon consumption, proof-host composition, and composed contract-aware UI behavior. The README also now reflects that the hidden testbed may intentionally pin `aerobeat-input-core` plus `aerobeat-spatial-ui-*` packages when validating downstream composition, rather than implying only `aerobeat-ui-core` belongs there. This slice stayed docs-only, aligns with `REF-01`, `REF-02`, and the provider-harness parity standard already recorded in Task 1, and does not widen into runtime or proof-scene implementation. QA pass: reviewed landed docs plus commit `69e8ab7` against `REF-01`, `REF-02`, and `REF-07`. `README.md` and `docs/notes/2026-05-24-ui-kit-community-provider-trust-boundary.md` clearly state that provider repos prove provider semantics and provider-owned runtime truth first in provider-owned harnesses/tests, while `aerobeat-ui-kit-community` proves downstream installed-addon consumption, proof-host composition, and contract-aware UI behavior instead of becoming the first semantic truth source. The slice remained docs-only in this repo (`README.md`, the new trust-boundary note, and the plan update only) with no runtime/proof-scene implementation added here, and the wording stays aligned with the locked spatial-family ownership split plus the new provider-harness standard. Auditor pass: reviewed the landed Task 5 diff at `69e8ab7` plus the current files (`README.md`, `docs/notes/2026-05-24-ui-kit-community-provider-trust-boundary.md`, and this plan) against `REF-01`, `REF-02`, `REF-07`, and the Task 1 parity standard note. The docs durably and accurately describe `aerobeat-ui-kit-community` as the downstream proof host while keeping provider semantics, provider runtime truth, canonical contract ownership, and shared spatial helper ownership in the provider/shared repos. The wording matches the locked spatial-family split and the provider-harness standard: provider repos prove packaged-provider semantics first in provider-owned harnesses/tests; this repo proves downstream composition, installed-addon consumption, and host-local proof wiring only. Scope stayed docs-only and did not widen into runtime or proof-scene work; the actual Task 5 diff touched only `README.md`, the new trust-boundary note, and the plan entry. The prior coder/QA claims are accurate, with one minor metadata caveat only: the task’s "Files Created/Deleted/Modified" bullet says `docs/notes only`, but the recorded results correctly reflect that `README.md` and the plan entry were also part of the docs-only slice.

---

## Final Results

**Status:** ⚠️ Draft

**What We Built:** Draft plan only.

**Reference Check:** Pending execution.

**Commits:**
- none yet

**Lessons Learned:** Pending execution.

---

*Drafted on 2026-05-24*
