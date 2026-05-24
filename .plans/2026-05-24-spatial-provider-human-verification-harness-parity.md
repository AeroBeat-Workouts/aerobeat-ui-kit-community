# AeroBeat Spatial Provider Human Verification Harness Parity

**Date:** 2026-05-24  
**Status:** In Progress  
**Last Updated:** 2026-05-24 11:40 EDT  
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

**Status:** ⏳ Pending

**Results:** Pending.

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
- `.testbed/scenes/` provider-owned XR verification scene(s)
- `.testbed/scripts/` XR verification harness scripts
- `.testbed/tests/` XR verification tests
- supporting docs/README updates as needed

**Status:** ⏳ Pending

**Results:** Pending.

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

**Status:** ⏳ Pending

**Results:** Pending.

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
