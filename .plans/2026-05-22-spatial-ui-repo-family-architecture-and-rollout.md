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

### Task 7: Phase 0 bootstrap cleanup in `aerobeat-spatial-ui-core`

**Bead ID:** `aerobeat-spatial-ui-core-7pg` (coder), `aerobeat-spatial-ui-core-o55` (qa), `aerobeat-spatial-ui-core-atf` (auditor)  
**SubAgent:** `primary`  
**Role:** `coder` → `qa` → `auditor`  
**References:** `REF-08`, `REF-11`  
**Prompt:** Clean Phase 0 bootstrap residue from `aerobeat-spatial-ui-core` only. Claim bead `aerobeat-spatial-ui-core-7pg` on start with `bd update aerobeat-spatial-ui-core-7pg --status in_progress --json`. Remove stale input-driver/bootstrap identity from README/plugin/testbed/template files, align naming and package metadata with the planned `spatial-ui-core` role, and stop before feature extraction or contract-bridge implementation. Run relevant repo-local validation, commit/push by default, and close the coder bead with a clear reason when done so QA can take over.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-spatial-ui-core/`

**Files Created/Deleted/Modified:**
- `README.md`
- `plugin.cfg`
- `.testbed/addons.jsonc`
- `.testbed/tests/test_example.gd`
- `.testbed/project.godot`
- any other stale bootstrap-identify files found during Phase 0 cleanup only

**Status:** ✅ Audit passed

**Results:** Coder cleanup landed in commit `b7a28746abfe92fd08a4a83b6b4bb740e8972475` and was pushed to `main`. QA independently reran import and GUT validation successfully (`2/2`), confirmed the repo truthfully presents itself as `AeroBeat Spatial UI Core`, verified the helper-layer-only boundary, and confirmed it does not claim contract ownership. `.testbed/addons.jsonc` is now a Phase 0 baseline with only `gut` as the pinned dev/test dependency. Independent audit then passed: `HEAD` and `origin/main` match `b7a2874`, no meaningful stale bootstrap/input-driver identity remains in the targeted repo-local files, and the repo was judged fully within Phase 0 scope with no drift into contract or provider ownership. The non-failing `ObjectDB instances leaked at exit` warning reproduced during headless import and continues to look tied to Godot/GUT editor-plugin startup/shutdown rather than repo-specific cleanup logic.

---

### Task 8: Phase 0 bootstrap cleanup in `aerobeat-spatial-ui-mouse`

**Bead ID:** `aerobeat-spatial-ui-mouse-05s` (coder), `aerobeat-spatial-ui-mouse-0rt` (qa), `aerobeat-spatial-ui-mouse-qgj` (auditor)  
**SubAgent:** `primary`  
**Role:** `coder` → `qa` → `auditor`  
**References:** `REF-08`, `REF-11`  
**Prompt:** Clean Phase 0 bootstrap residue from `aerobeat-spatial-ui-mouse` only. Claim bead `aerobeat-spatial-ui-mouse-05s` on start with `bd update aerobeat-spatial-ui-mouse-05s --status in_progress --json`. Remove stale input-driver/bootstrap identity from README/plugin/testbed/template files, align naming and package metadata with the planned `spatial-ui-mouse` role, and stop before feature extraction or contract-bridge implementation. Run relevant repo-local validation, commit/push by default, and close the coder bead with a clear reason when done so QA can take over.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-spatial-ui-mouse/`

**Files Created/Deleted/Modified:**
- `README.md`
- `plugin.cfg`
- `.testbed/addons.jsonc`
- `.testbed/tests/test_example.gd`
- `.testbed/project.godot`
- any other stale bootstrap-identify files found during Phase 0 cleanup only

**Status:** ✅ Audit passed

**Results:** Coder cleanup landed in commit `c5ef6df` and was pushed to `origin/main`. QA independently reran validation successfully (headless import, `godotenv addons install`, GUT `2/2` with 5 asserts), confirmed the repo truthfully presents itself as `AeroBeat Spatial UI Mouse`, verified the manifest/testbed/package identity, and confirmed no premature mouse-provider implementation was added during Phase 0. Independent audit then passed: the repo stayed within Phase 0 cleanup scope, no meaningful stale bootstrap/input-driver identity remains in tracked repo files, and commit `c5ef6df` was judged sufficient to close the repo’s Phase 0 slice. The import-time `ObjectDB instances leaked at exit` warning still reproduces during `--import`, but it continues to look like generic tooling noise rather than repo-specific cleanup fallout.

---

### Task 9: Phase 0 bootstrap cleanup in `aerobeat-template-spatial-ui`

**Bead ID:** `oc-xw3` (coder), `oc-f0h` (qa), `oc-87m` (auditor)  
**SubAgent:** `primary`  
**Role:** `coder` → `qa` → `auditor`  
**References:** `REF-09`, `REF-10`, `REF-11`  
**Prompt:** Clean Phase 0 bootstrap residue from `aerobeat-template-spatial-ui` only. Claim bead `oc-xw3` on start with `bd update oc-xw3 --status in_progress --json`. Remove stale input-driver/bootstrap identity from README/plugin/testbed/template files, resolve duplicate license residue, add missing workflow/template scaffolding expected for the spatial-ui template repo, and stop before creating new concrete adapter functionality. Run relevant repo-local validation, commit/push by default, and close the coder bead with a clear reason when done so QA can take over.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-template-spatial-ui/`

**Files Created/Deleted/Modified:**
- `README.md`
- `plugin.cfg`
- `.testbed/addons.jsonc`
- `.testbed/tests/test_example.gd`
- `.testbed/project.godot`
- `LICENSE` / `LICENSE.md` cleanup
- workflow/template scaffolding files needed for parity with the family plan
- any other stale bootstrap-identity files found during Phase 0 cleanup only

**Status:** ✅ Audit passed

**Results:** Coder cleanup landed in commit `8ccb438` and was pushed to `origin/main`. QA independently reran install/import/GUT validation successfully (`2/2`), confirmed the repo reads correctly as a spatial UI adapter template rather than a concrete provider or contract owner, verified duplicate-license cleanup left only canonical `LICENSE.md`, and verified the expected workflow scaffolding is present. Independent audit then passed: commit `8ccb438` stayed within Phase 0 scope, no meaningful stale bootstrap/input-driver identity remains in tracked repo files, the template framing and ownership boundaries are stated correctly, and the workflow/license/testbed cleanup was judged sufficient to close the repo’s Phase 0 slice. The import-time `ObjectDB instances leaked at exit` warning reproduced again and still appears tied to generic Godot/GUT/plugin unload behavior rather than template-repo-specific residue.

---

## Phase 1 Planning — Freeze the ownership boundary in code

Phase 0 is complete across all three new repos. The next slice is not feature extraction yet; it is the code-level boundary freeze that makes later extraction harder to do wrong.

The goal of Phase 1 is to encode the architecture decisions into package structure, placeholder runtime surfaces, manifests, and tests so future implementation has obvious guardrails:
- `aerobeat-input-core` remains the only contract owner and the only home of the native 2D bridge
- `aerobeat-spatial-ui-core` gains helper-layer scaffolding only
- `aerobeat-spatial-ui-mouse` gains concrete-provider scaffolding only, with dependency truth pointing back to `input-core` + `spatial-ui-core`
- `aerobeat-template-spatial-ui` is updated only as needed to template the Phase 1 boundary correctly rather than the old bootstrap shape
- `aerobeat-ui-kit-community` remains the proving ground and must not continue to accumulate long-term spatial-input infrastructure

### Task 10: Freeze helper-layer-only boundaries in `aerobeat-spatial-ui-core`

**Bead ID:** `aerobeat-spatial-ui-core-izw` (coder), `aerobeat-spatial-ui-core-0nx` (qa), `aerobeat-spatial-ui-core-lcw` (auditor)  
**SubAgent:** `primary`  
**Role:** `coder` → `qa` → `auditor`  
**References:** `REF-01`, `REF-02`, `REF-08`, `REF-11`  
**Prompt:** Create the Phase 1 boundary-freeze slice in `aerobeat-spatial-ui-core`. Add only helper-layer package structure, placeholder classes/scripts, and tests/docs needed to make the repo’s responsibility concrete in code. Do not add canonical contract types, native 2D bridge logic, event taxonomy ownership, or concrete mouse-provider behavior. The output should make it hard for future work to drift this repo into `input-core` ownership.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-spatial-ui-core/`

**Files Created/Deleted/Modified:**
- package/runtime scaffolding files for helper-layer-only spatial infrastructure
- tests/docs/manifest files that encode the boundary explicitly
- no contract-owner or concrete-provider files

**Status:** ⏳ Coder complete / QA pending

**Results:** Coder boundary-freeze work landed in commit `109e14c` and was pushed to `origin/main`. The repo now encodes a helper-layer-only runtime boundary through new placeholder helper scaffolding (`src/helpers/...`), a dedicated boundary note at `docs/phase-1-boundary-freeze.md`, and expanded tests asserting this repo does not own contract types, native 2D bridge logic, event taxonomy, or concrete mouse-provider behavior. Validation passed with headless import and GUT (`4/4`). The known Godot 4.6.2 `ObjectDB instances leaked at exit` warning still reproduces during import and remains non-blocking toolchain noise.

---

### Task 11: Freeze concrete-provider boundaries in `aerobeat-spatial-ui-mouse`

**Bead ID:** `aerobeat-spatial-ui-mouse-nsa` (coder), `aerobeat-spatial-ui-mouse-q87` (qa), `aerobeat-spatial-ui-mouse-clv` (auditor)  
**SubAgent:** `primary`  
**Role:** `coder` → `qa` → `auditor`  
**References:** `REF-01`, `REF-02`, `REF-08`, `REF-11`  
**Prompt:** Create the Phase 1 boundary-freeze slice in `aerobeat-spatial-ui-mouse`. Add only the minimal package/runtime scaffolding, dependency truth, and tests/docs needed to establish this repo as the mouse-driven spatial provider lane on top of `aerobeat-input-core` and `aerobeat-spatial-ui-core`. Do not extract real provider behavior yet and do not redefine the canonical interaction contract.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-spatial-ui-mouse/`

**Files Created/Deleted/Modified:**
- package/runtime scaffolding files for the concrete mouse-provider lane
- tests/docs/manifest files that encode the boundary explicitly
- no extracted hybrid proof logic yet

**Status:** ⏳ Coder complete / QA pending

**Results:** Coder boundary-freeze work landed in commit `d2bac51` and was pushed to `origin/main`. The repo now encodes the mouse-driven spatial provider lane through new placeholder runtime scaffolding in `src/providers/mouse/`, a dedicated boundary note at `docs/phase-1-boundary-freeze.md`, and expanded tests asserting this repo does not own canonical contract types, native 2D bridge logic, or extracted hybrid proof behavior. Validation passed with `godotenv addons install`, headless import, and GUT (`4/4`, `26` asserts). The known Godot 4.6.2 `ObjectDB instances leaked at exit` warning still reproduces during import and remains non-blocking toolchain noise.

---

### Task 12: Update `aerobeat-template-spatial-ui` to template the Phase 1 boundary

**Bead ID:** `oc-7se` (coder), `oc-v4c` (qa), `oc-vkp` (auditor)  
**SubAgent:** `primary`  
**Role:** `coder` → `qa` → `auditor`  
**References:** `REF-08`, `REF-10`, `REF-11`  
**Prompt:** Update `aerobeat-template-spatial-ui` only as needed so it templates the Phase 1 ownership boundary correctly. That means concrete spatial-adapter structure, dependency truth, and docs/tests that point to `input-core` as contract owner and `spatial-ui-core` as shared-helper owner. Do not turn the template into a real adapter implementation.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-template-spatial-ui/`

**Files Created/Deleted/Modified:**
- template/package/runtime scaffolding files as needed for Phase 1 parity
- tests/docs/manifest/template metadata reflecting the proper boundary

**Status:** ⏳ Coder complete / QA pending

**Results:** Coder boundary-freeze work landed in commit `6d1fb12` and was pushed to `origin/main`. The repo now encodes template-only spatial-adapter boundary truth through new placeholder scaffolding in `src/template/`, a dedicated boundary note at `docs/phase-1-boundary-freeze.md`, and expanded docs/tests/plugin metadata asserting downstream ownership (`aerobeat-input-core` for the contract, `aerobeat-spatial-ui-core` for shared helpers) and non-ownership of concrete adapter behavior. Validation passed with `godotenv addons install`, headless import, and GUT (`4/4`, `32` asserts). The known Godot 4.6.2 `ObjectDB instances leaked at exit` warning still reproduces during import and remains non-blocking toolchain noise.

---

### Task 13: Freeze the ownership boundary from the consumer/reference side

**Bead ID:** `aerobeat-ui-kit-community-b0v` (coder), `aerobeat-ui-kit-community-cd8` (qa), `aerobeat-ui-kit-community-pfo` (auditor)  
**SubAgent:** `primary`  
**Role:** `coder` → `qa` → `auditor`  
**References:** `REF-03`, `REF-04`, `REF-05`, `REF-06`, `REF-08`  
**Prompt:** In the current proof/reference repos, make the ownership boundary explicit enough that future extraction work has a stable reference point. This may include small docs/code annotations or TODO markers in `aerobeat-ui-kit-community` and, if truly necessary, minimal non-behavioral boundary notes in the relevant source locations. Do not perform extraction yet. The goal is to freeze where contract ownership, helper-layer ownership, and future provider ownership currently live before Phase 2 starts moving code.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/`
- any other owning repo only if strictly required for boundary clarity

**Files Created/Deleted/Modified:**
- reference docs/comments/notes or narrowly scoped boundary markers only
- no feature extraction

**Status:** ✅ Audit passed

**Results:** Coder boundary-freeze work landed in commit `dd1a555df6aca1aa358ed10c2f78fd33e2cc9afe` and was pushed to `origin/main`. The repo now includes a dedicated consumer/reference-side boundary note at `docs/notes/2026-05-22-phase-1-ownership-boundary-freeze-reference.md` plus non-behavioral ownership comments in `.testbed/scripts/glass_shader_test.gd` and `.testbed/scripts/glass_shader_gui_3d_test.gd`. These changes freeze that `aerobeat-input-core` owns the canonical contract/native 2D bridge, `aerobeat-ui-core` owns reusable consumer/binding behavior, and `aerobeat-ui-kit-community` currently contains only temporary proof/reference host glue pending later extraction. QA independently verified the touched scope is docs/comment-only, confirmed no executable behavior changed in the 2D or hybrid proof hosts, and reran import plus short headless scene smoke checks successfully. Independent audit then passed: the commit remained docs/comment-only, `HEAD` and `origin/main` both match `dd1a555`, and the new boundary note/comments truthfully mark current proof-host glue as temporary reference truth rather than long-term provider ownership. The known Godot 4.6.2 `ObjectDB instances leaked at exit` warning still reproduces during import/headless smoke and remains non-blocking toolchain noise.

---

## Phase 2 Planning — First real extraction pass

With Phase 1 complete, the next slice is the first true code extraction out of `aerobeat-ui-kit-community` into the new repo family. The intent is to move reusable spatial infrastructure into the correct repos without collapsing the ownership boundary we just froze.

The Phase 2 success condition is a thin vertical slice where:
- reusable helper-layer spatial abstractions live in `aerobeat-spatial-ui-core`
- reusable mouse-provider-specific spatial logic lives in `aerobeat-spatial-ui-mouse`
- `aerobeat-ui-kit-community` consumes those extracted packages for the current proof/reference path instead of continuing to own long-term spatial infrastructure
- `aerobeat-input-core` remains the sole owner of the canonical contract, event taxonomy, bus, and native 2D bridge
- semantic parity with the native 2D bridge remains aligned with `REF-08`

### Task 14: Extract the first reusable helper-layer slice into `aerobeat-spatial-ui-core`

**Bead ID:** `aerobeat-spatial-ui-core-d9q` (coder), `aerobeat-spatial-ui-core-lwv` (qa), `aerobeat-spatial-ui-core-y44` (auditor)  
**SubAgent:** `primary`  
**Role:** `coder` → `qa` → `auditor`  
**References:** `REF-04`, `REF-05`, `REF-06`, `REF-08`, `REF-11`  
**Prompt:** Extract the first reusable helper-layer slice into `aerobeat-spatial-ui-core`. Move only genuinely shared spatial helper abstractions that belong in the helper layer. Do not move canonical contract ownership, native 2D bridge behavior, event taxonomy, or concrete mouse-provider behavior into this repo. The result should create a usable shared layer that Phase 2 mouse extraction can build on.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-spatial-ui-core/`

**Files Created/Deleted/Modified:**
- helper-layer runtime files/tests/docs/manifests needed for the extracted shared slice
- no contract-owner or mouse-specific ownership drift

**Status:** ✅ Audit passed after retry

**Results:** Coder extraction work initially landed in commit `ec9ccf7` and was pushed to `main`, but independent audit failed the slice on downstream package-consumability because runtime scripts still used repo-local `res://../src/...` pathing that broke when consumed as an installed addon. The retry coder pass then landed in commit `9131047` and was pushed to `origin/main`. That retry repaired the helper-layer internal script loading to be package-safe, updated tests to exercise the staged installed-addon copy instead of repo-root helper paths, added a dedicated downstream-style installed-addon smoke validator at `.testbed/scripts/validate_installed_addon_paths.gd`, updated CI to stage the package into `.testbed/addons/aerobeat-spatial-ui-core` before import/test, and documented the staged-addon validation flow in `README.md`. Retry QA passed, and independent audit then passed after confirming the helper layer now loads and executes correctly from an installed-addon path in both the staged testbed flow and an isolated consumer-style check. Caveats retained: repo-local tests still contain a few `res://../...` references for test-only access to repo docs/plugin metadata, and staged addon validation may emit non-fatal `.uid` regeneration warnings.

---

### Task 15: Extract the first mouse-provider slice into `aerobeat-spatial-ui-mouse`

**Bead ID:** `aerobeat-spatial-ui-mouse-8uj` (coder), `aerobeat-spatial-ui-mouse-hpn` (qa), `aerobeat-spatial-ui-mouse-2y6` (auditor)  
**SubAgent:** `primary`  
**Role:** `coder` → `qa` → `auditor`  
**References:** `REF-04`, `REF-05`, `REF-08`, `REF-11`  
**Prompt:** Extract the first reusable mouse-provider slice into `aerobeat-spatial-ui-mouse` on top of `aerobeat-input-core` and `aerobeat-spatial-ui-core`. Move only mouse-provider-specific spatial logic that belongs in this lane. Do not redefine the canonical interaction contract, do not move native 2D bridge logic here, and do not leave long-term provider ownership stranded in `ui-kit-community`.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-spatial-ui-mouse/`

**Files Created/Deleted/Modified:**
- mouse-provider runtime files/tests/docs/manifests needed for the extracted slice
- no contract-owner or native-2D drift

**Status:** ⏳ QA complete / audit pending

**Results:** Coder extraction work landed in commit `980f524a3810048c7d1ba0811ccfa48a62b9aeb5` and was pushed to `main`. The repo now contains the first real mouse-provider slice: projected-surface hover enter/exit publication, press ownership/capture continuity, captured motion publication, release handling, and synthetic release when motion drops the left-button mask. Canonical contract ownership, native 2D bridge logic, and world-hit acquisition all remain outside this repo by design. Validation passed including `godotenv addons install`, `git diff --check`, headless import, and GUT (`5/5`). QA independently passed the slice and confirmed the provider-local rect-target lookup fallback is acceptably narrow and documented for this phase. One documented caveat remains: that fallback duplicates logic that should be removed once the shared helper package path issue is fully retired from the downstream consumer path.

---

### Task 16: Cut the proof/reference host in `aerobeat-ui-kit-community` over to the extracted packages

**Bead ID:** `aerobeat-ui-kit-community-ls2` (coder), `aerobeat-ui-kit-community-6q4` (qa), `aerobeat-ui-kit-community-uqk` (auditor)  
**SubAgent:** `primary`  
**Role:** `coder` → `qa` → `auditor`  
**References:** `REF-03`, `REF-04`, `REF-05`, `REF-06`, `REF-08`  
**Prompt:** Update `aerobeat-ui-kit-community` so the proof/reference host consumes the extracted Phase 2 spatial helper/provider packages instead of continuing to own the long-term spatial infrastructure locally. Preserve behavior and semantic parity, keep remaining scene-local glue only where it is truly proof-specific, and document any intentionally deferred extraction seams.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/`

**Files Created/Deleted/Modified:**
- proof/reference host files, manifests, docs, and local glue as needed for the consumer cutover
- no contract-owner drift

**Status:** ✅ Audit passed

**Results:** Coder cutover work landed in commit `abd77bc` and was pushed to `main`. The hybrid proof host now consumes `aerobeat-spatial-ui-core` and `aerobeat-spatial-ui-mouse` packages instead of keeping local ownership of the extracted mouse hover/capture/publication lifecycle. The cutover updated `.testbed/addons.jsonc`, rewired `.testbed/scripts/glass_shader_gui_3d_test.gd`, refreshed repo-local runtime/dependency tests, and documented intentionally deferred seams in `docs/notes/2026-05-22-phase-2-proof-host-cutover-deferred-seams.md`. QA independently confirmed the host now delegates through the extracted provider types, verified the intended local seams remain only world-ray acquisition/touch-path/compatibility-wrapper glue, and reran the cutover-focused suite successfully (`11/11`, `106` asserts). Independent audit then passed and confirmed `HEAD`/`origin/main` both match `abd77bc`, the host now truly consumes the extracted spatial packages for the mouse-provider path, and the remaining local seams are intentional rather than scope drift. One unrelated pre-existing full-suite failure remains in `res://tests/ui/test_aero_ui_glass_config_loaders.gd` and is not part of the spatial cutover slice.

---

## Active Blockers / Guardrails

1. **Do not let `spatial-ui-core` drift into contract ownership.** It is helper-layer only.
2. **Do not let native 2D and spatial providers publish divergent meanings.** The semantic parity matrix in `REF-08` is the baseline.
3. **Do not let `ui-kit-community` remain the long-term owner of spatial mouse glue.** It must become a consumer/example repo over time.
4. **Treat the `ObjectDB instances leaked at exit` warning as known Godot 4.6.2 toolchain noise unless a later phase produces contrary evidence.** It is not a current blocker.

---

## Final Results

**Status:** ✅ Phase 0 Complete / ✅ Phase 1 Complete / ✅ Phase 2 Complete

**What We Built:** A durable cross-repo planning package for the `aerobeat-spatial-ui-*` family, then completed and audit-closed the full Phase 0 bootstrap cleanup across `aerobeat-spatial-ui-core`, `aerobeat-spatial-ui-mouse`, and `aerobeat-template-spatial-ui`, followed by a full Phase 1 boundary freeze across those repos plus the consumer/reference side in `aerobeat-ui-kit-community`, followed by the first real Phase 2 extraction/cutover pass: shared helper extraction into `aerobeat-spatial-ui-core`, mouse-provider extraction into `aerobeat-spatial-ui-mouse`, and proof-host cutover in `aerobeat-ui-kit-community`.

**Reference Check:** `REF-01` and `REF-02` remain the canonical input-contract references. `REF-03` through `REF-07` explain the proof-scene motivation and the desktop-truth failures that justified the architecture shift. `REF-08` durably captures the native 2D bridge and semantic parity rules. `REF-09` and `REF-11` grounded the family plan against real local repo patterns and the actual freshly cloned repos rather than guesses.

**Commits:**
- `b7a28746abfe92fd08a4a83b6b4bb740e8972475` - Phase 0 bootstrap cleanup in `aerobeat-spatial-ui-core`
- `c5ef6df` - Phase 0 bootstrap cleanup in `aerobeat-spatial-ui-mouse`
- `8ccb438` - Clean spatial UI template bootstrap residue
- `109e14c` - Freeze spatial UI core helper-layer boundary
- `d2bac51` - Freeze mouse spatial UI Phase 1 boundaries
- `6d1fb12` - Freeze Phase 1 spatial adapter template boundary
- `dd1a555df6aca1aa358ed10c2f78fd33e2cc9afe` - Freeze Phase 1 ownership boundary references
- `ec9ccf7` - Extract first shared spatial helper layer
- `9131047` - Fix package-safe helper layer script loading
- `980f524a3810048c7d1ba0811ccfa48a62b9aeb5` - Extract first mouse-provider slice
- `abd77bc` - Cut over proof host to spatial packages

**Lessons Learned:** The architecture direction itself was sound, but the first planning package was not durable enough. The key hardening lessons were: write the ownership boundary explicitly, prevent `spatial-ui-core` from becoming a second contract repo, record the semantic parity matrix before implementation, inspect the real cloned repos instead of trusting the old template bootstrap, and separate repo-identity cleanup from later feature extraction so the rollout stays auditable.

**Next Slice:** Execute **Phase 3**: retire temporary duplication and remaining deferred seams where possible, prove the packaged resolver path end-to-end in consumer usage without local fallbacks, and continue migrating any remaining reusable proof-host spatial glue out of `aerobeat-ui-kit-community` while preserving semantic parity from `REF-08`.

---

*Phase 0 completed and Phase 1 planned on 2026-05-22*
