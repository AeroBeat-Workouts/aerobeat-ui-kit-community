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

## Phase 3 Planning — Resolver truth and deferred-seam retirement

With the first extraction/cutover loop complete, the next slice is to remove the temporary proving crutches that were acceptable in Phase 2 but should not survive as long-term architecture. The most important remaining caveat is the provider-local rect-target fallback in `aerobeat-spatial-ui-mouse`; it was explicitly tolerated only until the packaged resolver path could be proven end-to-end in real consumer usage.

The Phase 3 success condition is:
- the consumer path proves packaged resolver usage end-to-end without relying on provider-local fallback logic
- any shared resolver/helper logic that still belongs in `aerobeat-spatial-ui-core` is promoted there cleanly
- `aerobeat-ui-kit-community` sheds any remaining reusable proof-host spatial glue that no longer needs to stay local
- semantic parity with the native 2D bridge remains aligned with `REF-08`
- deferred seams are either retired or narrowed/documented as truly scene-specific host ownership

### Task 17: Retire provider-local fallback and prove shared resolver ownership in `aerobeat-spatial-ui-mouse`

**Bead ID:** `aerobeat-spatial-ui-mouse-zbh` (coder), `aerobeat-spatial-ui-mouse-cft` (qa), `aerobeat-spatial-ui-mouse-opv` (auditor)  
**SubAgent:** `primary`  
**Role:** `coder` → `qa` → `auditor`  
**References:** `REF-04`, `REF-05`, `REF-08`, `REF-11`  
**Prompt:** Execute the first Phase 3 provider cleanup in `aerobeat-spatial-ui-mouse`. Claim the assigned bead on start. Remove or retire the documented temporary provider-local rect-target fallback where possible, keeping only ownership that truly belongs in the concrete mouse-provider lane. If shared resolver or target-resolution support is still needed, move that shared responsibility into the proper helper-layer path instead of leaving it duplicated here. Prove the package can be consumed by a real downstream-style path without relying on local fallbacks. Preserve canonical-contract ownership in `aerobeat-input-core` and preserve semantic parity with `REF-08`.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-spatial-ui-mouse/`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-spatial-ui-core/` only if shared helper promotion is strictly required

**Files Created/Deleted/Modified:**
- provider/helper runtime files, tests, docs, manifests as needed for fallback retirement and packaged-resolver proof
- no contract-owner or native-2D drift

**Status:** ✅ Audit passed

**Results:** Coder work landed in commit `54a8d03` and was pushed to `main`. The temporary provider-local rect-target fallback was removed from `aerobeat-spatial-ui-mouse`, and `AeroSpatialUiMouseProvider` now resolves targets through the packaged `AeroSpatialRectTargetResolver` from `aerobeat-spatial-ui-core` instead of maintaining local duplication. The repo gained downstream-style staged-addon smoke validation and CI coverage for the installed-addon path. QA independently passed on commit `54a8d03` after forcing a fresh `.testbed` dependency restore, re-importing cleanly, rerunning GUT (`5/5`), staging the addon in downstream-style installed-addon form, running the dedicated installed-addon smoke validator, and running a direct runtime probe that confirmed `resolver_path=res://addons/aerobeat-spatial-ui-core/src/helpers/providers/aero_spatial_rect_target_resolver.gd`, `press_target_path=PreviewCenter/PrimaryActionButton`, and `press_matched_target_key=primary_action`. Independent audit then passed and confirmed `HEAD` and `origin/main` both match `54a8d03`, the old local rect-walk fallback ownership logic is truly gone from the mouse-provider path, the shared resolver ownership now genuinely lives in `aerobeat-spatial-ui-core`, and no contract-owner or native-2D drift was introduced. The remaining caveat is ergonomic rather than architectural: repo-root GUT and staged self-addon validation cannot coexist in the same live workbench state without duplicate global-class collisions, so local validation currently requires keeping those states separate. That caveat does not block closure of this Phase 3 mouse-repo slice.

---

### Task 18: Tighten the consumer path in `aerobeat-ui-kit-community` around the packaged resolver flow

**Bead ID:** `aerobeat-ui-kit-community-tu2` (coder), `aerobeat-ui-kit-community-sz6` (qa), `aerobeat-ui-kit-community-9v2` (auditor)  
**SubAgent:** `primary`  
**Role:** `coder` → `qa` → `auditor`  
**References:** `REF-03`, `REF-04`, `REF-06`, `REF-08`  
**Prompt:** Execute the consumer-side Phase 3 cutover tightening in `aerobeat-ui-kit-community`. Claim the assigned bead on start. Update the proof/reference host so it proves the packaged resolver path end-to-end without leaning on local fallback seams. Continue migrating any remaining reusable proof-host spatial glue out of this repo where that glue no longer needs to stay host-owned. Keep only truly scene-specific ownership local, and document any intentionally retained seam precisely.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/`

**Files Created/Deleted/Modified:**
- proof/reference host files, manifests, docs, and local glue as needed for Phase 3 resolver-truth verification
- no contract-owner drift

**Status:** ✅ Audit passed

**Results:** Coder work landed in commit `cd6c61a` and was pushed to `main`. The hidden testbed’s `aerobeat-spatial-ui-mouse` pin was bumped to the packaged-resolver commit `54a8d036323a9cc4c367dcebcd1381fa260eede0` so the consumer workbench actually installs the resolver-fixed provider. The repo gained consumer-proof coverage that inspects the installed addon payload under `res://addons/...`, asserts the installed mouse provider loads the packaged rect resolver from `aerobeat-spatial-ui-core`, asserts no local rect-target fallback loop remains in the installed provider, and runs a live hybrid press path that verifies runtime metadata through the consumer path. The intentionally retained local seams are now documented precisely as world-ray acquisition, touch glue, and probe-facing compatibility wrappers. QA independently passed on commit `cd6c61a` and verified that the proof host is exercising installed-addon paths under `res://addons/...` rather than repo-local provider/resolver copies, that the installed provider no longer contains the old `duplicate_target_specs` fallback loop, and that the live hybrid press path preserves runtime metadata including `resolution_mode=rect_target_specs`, `target_resolution=rect_target_specs`, `host_surface=PanelInputSurface`, and a `PrimaryActionButton` target path. Independent audit then passed and confirmed the manifest pin truly drives the consumer workbench onto the resolver-fixed packaged provider, the installed-addon path is the active path being exercised, the remaining local wrappers delegate to packaged resolver/helper code instead of re-owning fallback logic, and no contract-owner or native-2D drift was introduced. The pre-existing untracked `.plans/` and `.testbed/qa_probes/` dirt remained untouched. Background suite failures in `res://tests/ui/test_aero_ui_glass_config_loaders.gd` and `res://tests/ui/test_aero_ui_glass_panel_view_yaml_smoke.gd` remain out of scope for this bead.

---

## Phase 4 Planning — Docs and template hardening after packaged-resolver cutover

With Phases 0 through 3 now audit-closed, the next clear slice is to harden the durable public architecture/docs/template story so future work reuses the packaged spatial lanes correctly instead of drifting back into proof-host ownership. The implementation truth has moved; now the documentation and template guidance need to match that truth precisely.

The Phase 4 success condition is:
- `aerobeat-docs` states the final ownership split clearly for the spatial UI family
- the docs explain the packaged resolver flow and the remaining intentionally local seams without ambiguity
- the template repo reflects the post-Phase-3 guidance well enough that future adapter repos do not recreate the old fallback/ownership confusion
- future touch/XR lanes are clearly framed as separate provider lanes rather than hidden consumer-repo glue

### Task 19: Harden public architecture docs for the spatial UI family in `aerobeat-docs`

**Bead ID:** `aerobeat-docs-2cz` (coder), `aerobeat-docs-jg3` (qa), `aerobeat-docs-0r7` (auditor)  
**SubAgent:** `primary`  
**Role:** `coder` → `qa` → `auditor`  
**References:** `REF-01`, `REF-02`, `REF-08`, `REF-09`, `REF-11`  
**Prompt:** Update `aerobeat-docs` so the public architecture story matches the now-audited repo truth. The docs should describe the `aerobeat-spatial-ui-*` family, make the final ownership split explicit (`input-core`, `ui-core`, `spatial-ui-core`, `spatial-ui-mouse`, `ui-kit-community`), explain the packaged resolver flow, and record that touch/XR extraction belongs in separate provider lanes rather than hidden proof-host glue. Keep the docs durable and precise rather than speculative.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-docs/`

**Files Created/Deleted/Modified:**
- architecture/repository-map and related docs as needed
- no implementation repo behavior changes

**Status:** ✅ Audit passed after retry

**Results:** The first docs pass landed in commit `f9f6113`, but QA found a real content-truth mismatch: several docs still overstated `aerobeat-spatial-ui-core` as a contract/bridge/resolver owner and documented inaccurate repo shapes. The coder retry then landed in commit `92963f0` and was pushed to `main`. That retry removed wording implying `aerobeat-spatial-ui-core` owns the UI interaction contract, native 2D bridge, or concrete packaged resolver runtime; reframed `aerobeat-spatial-ui-core` as helper-layer only for shared surface/projection/target-resolution/hover-capture helpers; reasserted `aerobeat-input-core` as the canonical UI interaction contract owner and native 2D bridge owner; reasserted `aerobeat-spatial-ui-mouse` as the concrete packaged mouse provider lane; and corrected the spatial UI repo-shape examples to match the audited extracted layouts (`src/helpers/...` and `src/providers/mouse/...`). QA rerun then passed on commit `92963f0` and confirmed no active architecture doc still implies `aerobeat-spatial-ui-core` owns the canonical UI interaction contract, native 2D bridge, or concrete provider/runtime lane; confirmed the repo-family framing and packaged-flow wording remain intact; confirmed camera-only v1 gameplay wording is still correct; and confirmed touch/XR are framed as future explicit provider lanes. Independent audit then passed and confirmed the five corrected architecture docs now match the audited repo truth, the documented spatial-ui repo layouts match the real extracted `src/helpers/...` and `src/providers/mouse/...` shapes, and Task 19 can be considered done. Remaining MkDocs warning noise and nav omissions remain outside this bead’s scope.

---

### Task 20: Harden `aerobeat-template-spatial-ui` for post-Phase-3 adapter guidance

**Bead ID:** `oc-cid` (coder), `oc-6ja` (qa), `oc-9wd` (auditor)  
**SubAgent:** `primary`  
**Role:** `coder` → `qa` → `auditor`  
**References:** `REF-08`, `REF-10`, `REF-11`  
**Prompt:** Update `aerobeat-template-spatial-ui` only as needed so the template reflects the post-Phase-3 architecture truth. Future adapter repos should inherit the packaged helper/provider ownership split cleanly, avoid local fallback ownership, and point touch/XR authors toward separate provider lanes instead of consumer-repo glue.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-template-spatial-ui/`

**Files Created/Deleted/Modified:**
- template docs/README/tests/metadata as needed for post-Phase-3 guidance
- no concrete adapter behavior implementation

**Status:** ✅ Audit passed

**Results:** Coder work landed in commit `2a6c4f2` and was pushed to `main`. The template docs now reflect the post-Phase-3 ownership truth explicitly: `aerobeat-input-core` owns the contract/native 2D bridge, `aerobeat-spatial-ui-core` owns shared packaged helper/resolver seams, generated repos should own one concrete provider lane each, consumer repos should not become the long-term home of provider-local fallbacks or cross-provider glue, and touch/XR work is pointed toward separate provider repos instead of consumer-repo glue. The inert template metadata/runtime-boundary stubs were updated to encode the same ownership split, and repo-local tests were expanded to guard against fallback/glue drift. Touched files: `README.md`, `docs/phase-1-boundary-freeze.md`, `src/template/aero_spatial_ui_adapter_template_config.gd`, `src/template/aero_spatial_ui_adapter_template_manifest.gd`, `src/template/aero_spatial_ui_adapter_template_provider.gd`, `src/template/aero_spatial_ui_adapter_template_runtime_boundary.gd`, and `.testbed/tests/test_example.gd`. QA independently passed on commit `2a6c4f2` and confirmed the docs plus inert `src/template/` stubs preserve the intended ownership split, the repo still reads clearly as a template rather than a real provider implementation, `plugin.cfg` still presents it as a template, and repo-local validation passed again with headless import plus GUT (`4/4`). Independent audit then passed and confirmed the template still reads as a template rather than a real provider implementation, the touched tests/metadata reinforce the same ownership truth without hidden drift, and Task 20 can be considered done. The only caveat remained the already-known non-fatal Godot `ObjectDB instances leaked at exit` warning during headless import.

---

## Phase 5 Planning — Touch provider extraction readiness

With Phases 0 through 4 now audit-closed, the next clearest architecture-risk area is the still-local touch-path glue called out during the packaged-resolver cutover. Before opening a concrete touch-provider repo or extraction pass, we need a durable readiness plan that turns the currently local touch proof path into an explicit provider-lane roadmap instead of letting it remain consumer-repo glue by inertia.

The Phase 5 success condition is:
- the remaining touch-path local glue is inventoried precisely
- ownership boundaries are defined for a future touch provider lane without disturbing the already-closed mouse/resolver path
- the extraction prerequisites are explicit enough that a future implementation pass can proceed without re-litigating ownership
- `aerobeat-ui-kit-community` keeps only truly proof-scene/local touch seams until that provider lane exists

### Task 21: Define touch-provider extraction readiness from the current proof host

**Bead ID:** `aerobeat-ui-kit-community-brq` (research), `aerobeat-ui-kit-community-8jv` (auditor)  
**SubAgent:** `primary`  
**Role:** `research` → `auditor`  
**References:** `REF-04`, `REF-06`, `REF-08`  
**Prompt:** Inspect the current touch-path proof glue in `aerobeat-ui-kit-community` and define the extraction-readiness plan for a future touch spatial provider lane. Inventory exactly what still remains local, what belongs in a future dedicated provider repo, what would still stay proof-host-local, and what dependencies or semantic-parity risks must be preserved relative to `REF-08`. Keep this as a durable planning/readiness slice, not a speculative implementation.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/`
- optional notes/docs only in other owning repos if strictly needed

**Files Created/Deleted/Modified:**
- plan-linked notes/docs only as needed for touch extraction readiness
- no production behavior changes yet

**Status:** ⏳ Research complete / audit pending

**Results:** Research landed in commit `6787f40` and was pushed to `main`. The readiness pass concluded that the repo is ready for a dedicated touch-provider lane from an ownership/planning standpoint, but not ready for a blind code lift. A durable note at `docs/notes/2026-05-23-phase-5-touch-provider-readiness.md` now inventories the still-local touch path in `.testbed/scripts/glass_shader_gui_3d_test.gd`, separates future touch-provider ownership from proof-host-local seams, and records the key semantic-parity risks that must stay aligned with `REF-08`: press-owner `press_end.target_path`, separate hover vs press/drag ownership, `drag_end` before `press_end`, `cancel` only for broken continuity, and no contract duplication outside `aerobeat-input-core`. It also records that touch should remain truthfully `unverified` until real device validation exists.

---

### Task 22: Define the first executable touch-provider extraction packet

**Bead ID:** `aerobeat-ui-kit-community-xqg` (research), `aerobeat-ui-kit-community-olm` (auditor)  
**SubAgent:** `primary`  
**Role:** `research` → `auditor`  
**References:** `REF-04`, `REF-06`, `REF-08`  
**Prompt:** Convert the Phase 5 touch-provider readiness findings into the first executable extraction packet. Identify the minimal vertical slice for a future dedicated touch-provider lane, name the exact source functions/seams that would move first, name the validation needed to preserve semantic parity with `REF-08`, and spell out what should remain host-local in `aerobeat-ui-kit-community` after that first touch extraction step. Keep this as a durable execution packet, not implementation yet.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/`
- optional notes/docs only in other owning repos if strictly needed

**Files Created/Deleted/Modified:**
- plan-linked notes/docs only as needed for touch extraction packet
- no production behavior changes yet

**Status:** ✅ Audit passed

**Results:** Research landed in commit `b6d8ac5` and was pushed to `main`. A durable execution packet at `docs/notes/2026-05-23-phase-5-touch-provider-first-extraction-packet.md` now defines the minimum truthful first slice for a future dedicated touch-provider lane: extract the reusable touch lifecycle/provider runtime while keeping world-ray/world-hit acquisition host-local in `aerobeat-ui-kit-community`. The packet names the first move seams from `.testbed/scripts/glass_shader_gui_3d_test.gd`: `_active_touch_state`, the touch-routing branches in `_forward_world_panel_input(...)`, `_publish_screen_touch_to_contract(...)`, `_publish_screen_drag_to_contract(...)`, `_publish_projected_phase(...)` as the explicit provider-owned phase seam, and provider-owned or provider-composed wrappers around `_build_projected_data(...)` and `_resolve_projected_target_path_from_hit(...)`. It also names the explicit keep-local list after slice 1 and records the validation/parity checklist that must remain aligned with `REF-08`, the mouse-lane structure, packaged helper-layer composition, installed-addon consumer proof, and the still-unverified touch truth. Independent audit then passed and confirmed the packet defines the minimum truthful first slice, the named move seams and keep-local seams map correctly to current host code, the parity checklist is sufficient, and no contract duplication or speculative implementation drift was introduced. The key follow-up risk called out by audit is the absence of a touch-specific installed-addon/parity test packet today.

---

### Task 23: Define the touch-provider parity and installed-addon test packet

**Bead ID:** `aerobeat-ui-kit-community-63a` (research), `aerobeat-ui-kit-community-cn5` (auditor)  
**SubAgent:** `primary`  
**Role:** `research` → `auditor`  
**References:** `REF-04`, `REF-06`, `REF-08`  
**Prompt:** Define the parity/test packet that should exist before or alongside the first touch-provider extraction implementation. Name the exact assertions, fixture/probe expectations, installed-addon proof steps, and semantic-parity checks needed so touch extraction can be judged against `REF-08` and the mouse-lane structure instead of intuition. Keep this as a durable execution packet, not implementation yet.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/`
- optional notes/docs only in other owning repos if strictly needed

**Files Created/Deleted/Modified:**
- plan-linked notes/docs only as needed for parity/test packet
- no production behavior changes yet

**Status:** ⏳ Research complete / audit pending

**Results:** Research landed in commit `4e054af` and was pushed to `main`. A durable execution packet at `docs/notes/2026-05-23-phase-5-touch-provider-parity-test-packet.md` now defines the exact parity/test scaffold that should exist before or alongside the first touch-provider extraction implementation. It names the recommended slice-1 consumer-side tests (`test_hybrid_touch_release_path.gd`, `test_hybrid_touch_provider_parity.gd`, `test_hybrid_packaged_touch_provider_flow.gd`), the future provider-repo test inventory, the installed-addon downstream proof recipe, and the explicit pass/fail assertions against `REF-08` and the mouse-lane structure. Core must-pass assertions recorded include: `press_end.target_path` staying the original press owner, `drag_end` occurring before `press_end`, release-outside with continuity producing `press_end` rather than `cancel`, off-surface press without continuity not publishing, touch remaining `unverified`, and the installed packaged provider being the exercised downstream path.

---

### Task 24: Define the dedicated touch-provider repo bootstrap packet

**Bead ID:** `aerobeat-ui-kit-community-7ai` (research), `aerobeat-ui-kit-community-jgd` (auditor)  
**SubAgent:** `primary`  
**Role:** `research` → `auditor`  
**References:** `REF-04`, `REF-06`, `REF-08`  
**Prompt:** Define the repo-bootstrap packet for the future dedicated touch spatial provider lane. Name the intended repo shape, package/runtime boundary files, minimum docs/tests/manifest scaffolding, dependency truth against `aerobeat-input-core` and `aerobeat-spatial-ui-core`, and the exact first-slice bootstrap expectations so the next implementation lane can start without reopening ownership questions. Keep this as a durable execution packet, not implementation yet.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/`
- optional notes/docs only in other owning repos if strictly needed

**Files Created/Deleted/Modified:**
- plan-linked notes/docs only as needed for bootstrap packet
- no production behavior changes yet

**Status:** ⏳ Research complete / audit pending

**Results:** Research landed in commit `b05fddb` and was pushed to `main`. A durable bootstrap packet at `docs/notes/2026-05-23-phase-5-touch-provider-bootstrap-packet.md` now defines the intended future touch-lane repo as `aerobeat-spatial-ui-touch`, recommends a `src/providers/touch/` runtime boundary mirroring the existing family pattern, names the minimum boundary files (`aero_spatial_ui_touch_provider.gd`, `..._config.gd`, `..._runtime_boundary.gd`, `..._manifest.gd`), and pins the minimum docs/tests/manifest scaffolding needed to start the lane without reopening ownership questions. The packet also includes an explicit dependency/ownership truth table: `aerobeat-input-core` owns the canonical contract and `HybridSubViewportInputAdapter`, `aerobeat-spatial-ui-core` owns the shared helper layer, the future touch repo owns only reusable touch lifecycle/runtime semantics, and `aerobeat-ui-kit-community` keeps world-hit acquisition plus downstream installed-addon proof. It further records the exact first-slice expectation: move touch lifecycle/runtime semantics only, not camera ray/physics hit acquisition, proof-scene composition, or contract/helper ownership.

---

## Phase 6 Planning — New touch/XR repo intake and bootstrap activation

With `aerobeat-spatial-ui-touch` and `aerobeat-spatial-ui-xr` now created on GitHub, the next slice is to bring them into the local workspace and inspect how much bootstrap residue or scaffolding gap remains before implementation work begins. Touch is the immediate active lane; XR is future-facing, but now needs to be accounted for in the repo family instead of left theoretical.

### Task 25: Clone and inspect the newly created touch/XR spatial UI repos

**Bead ID:** `aerobeat-ui-kit-community-brk0` (research), `aerobeat-ui-kit-community-luzt` (auditor)  
**SubAgent:** `primary`  
**Role:** `research` → `auditor`  
**References:** `REF-08`, `REF-10`, `REF-11`  
**Prompt:** Clone the newly created GitHub repos `aerobeat-spatial-ui-touch` and `aerobeat-spatial-ui-xr` into the local AeroBeat workspace, inspect their current scaffold state against the existing spatial-ui family expectations and the new touch bootstrap packet, and report exactly what bootstrap cleanup or boundary hardening work should happen next. Do not implement the providers yet; this is intake/inspection and local availability work.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-spatial-ui-touch/`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-spatial-ui-xr/`

**Files Created/Deleted/Modified:**
- cloned repos only unless a durable inspection note is truly needed

**Status:** ✅ Audit passed

**Results:** Research cloned both repos successfully into the local workspace: `aerobeat-spatial-ui-touch` at `075e167` and `aerobeat-spatial-ui-xr` at `5cac485`. A durable intake note was added at `docs/notes/2026-05-23-phase-6-touch-xr-repo-intake.md`. Inspection found both repos are still raw template copies rather than truthful concrete provider repos: `README.md` still says `AeroBeat Spatial UI Adapter Template`, `plugin.cfg` still names/describes the template, `docs/phase-1-boundary-freeze.md` still freezes template ownership instead of lane-specific ownership, only `src/template/` exists, and `.testbed/tests/test_example.gd` still asserts template identity. Independent audit then passed and confirmed those identity/scaffold gaps are real, both repos match their GitHub remotes exactly, and activating touch first is the correct next step because touch already has the closed readiness/extraction/parity/bootstrap packet stack while XR does not yet.

---

### Task 26: Phase 0/1 bootstrap cleanup and identity conversion in `aerobeat-spatial-ui-touch`

**Bead ID:** `aerobeat-spatial-ui-touch-lha` (coder), `aerobeat-spatial-ui-touch-6b7` (qa), `aerobeat-spatial-ui-touch-asm` (auditor)  
**SubAgent:** `primary`  
**Role:** `coder` → `qa` → `auditor`  
**References:** `REF-08`, `REF-10`, `REF-11`  
**Prompt:** Convert `aerobeat-spatial-ui-touch` from raw template copy into a truthful touch-lane repo bootstrap, using the Phase 5 bootstrap packet as the source of truth. This slice is still bootstrap/boundary work, not touch-provider implementation: fix repo identity, boundary docs, manifest/plugin/testbed naming, and lay down the minimum `src/providers/touch/` scaffold and test/docs placeholders required by the bootstrap packet without adding the real provider behavior yet.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-spatial-ui-touch/`

**Files Created/Deleted/Modified:**
- README / plugin / docs / testbed / boundary scaffold files needed to convert template identity into truthful touch-lane bootstrap state
- no real touch provider implementation yet

**Status:** ⏳ QA rerun complete / audit pending

**Results:** Coder work landed in commit `b7ff2fd` and was pushed to `main`. `aerobeat-spatial-ui-touch` was converted from a raw template copy into a mostly truthful touch-lane bootstrap repo: repo identity/docs/plugin text now describe the touch spatial UI provider bootstrap instead of a generic template; `src/template/` placeholders were replaced by a new `src/providers/touch/` scaffold (`aero_spatial_ui_touch_provider.gd`, `..._config.gd`, `..._runtime_boundary.gd`, `..._manifest.gd`); the Phase 2 extraction stub and named touch-semantic test scaffolding were added without implementing real provider behavior; and `.testbed/addons.jsonc` was updated to truthfully pin `aerobeat-input-core`, `aerobeat-spatial-ui-core`, and `gut`. QA then found one real remaining identity leak: `.testbed/project.godot` still named itself `AeroBeat Spatial UI Template Testbed`, and that template identity showed up in validation output paths. The coder retry landed in commit `38dc5dc` and changed `.testbed/project.godot` to `AeroBeat Spatial UI Touch Testbed`. QA rerun then passed on `38dc5dc` and confirmed the remaining template identity leak is gone, runtime/output surfaces now present as `AeroBeat Spatial UI Touch Testbed`, bootstrap-only/non-implementation truth still holds, ownership truth remains intact, and repo-local tests still pass (`7/7`). The only notable caveat carried into audit is a pre-existing `godotenv addons install` refusal caused by a modified vendored addon checkout in `.testbed/addons/aerobeat-input-core`, which QA judged unrelated to the identity cleanup itself.

---

### Task 27: Extract the first real touch lifecycle/runtime slice into `aerobeat-spatial-ui-touch`

**Bead ID:** `aerobeat-spatial-ui-touch-3i2` (coder), `aerobeat-spatial-ui-touch-k92` (qa), `aerobeat-spatial-ui-touch-c9u` (auditor)  
**SubAgent:** `primary`  
**Role:** `coder` → `qa` → `auditor`  
**References:** `REF-04`, `REF-06`, `REF-08`  
**Prompt:** Implement the first truthful touch-provider extraction slice in `aerobeat-spatial-ui-touch` using the closed readiness/extraction/parity/bootstrap packets as the source of truth. Move reusable touch lifecycle/runtime behavior into the touch repo while keeping world-hit acquisition, proof-scene composition, and other host-local seams in `aerobeat-ui-kit-community`. Preserve `REF-08` semantics and the touch `unverified` truth. Add only the minimum consumer-side and repo-local changes needed to prove the slice.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-spatial-ui-touch/`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/` only where needed for consumer proof hookup

**Files Created/Deleted/Modified:**
- touch provider/runtime files, tests, docs, and consumer proof glue needed for slice 1
- no contract-owner or shared-helper-owner drift

**Status:** ⏳ QA complete / audit pending

**Results:** Coder work landed in `aerobeat-spatial-ui-touch` commit `9fc9cf0` and `aerobeat-ui-kit-community` commit `c7b7f89`, both pushed to `main`. The first truthful extracted touch-provider runtime slice now lives in `aerobeat-spatial-ui-touch`, while `aerobeat-ui-kit-community`’s hybrid proof host was cut over to the packaged installed touch provider. Host-local world-hit acquisition and proof-scene composition remained in the proof host, contract ownership remained in `aerobeat-input-core`, shared helper ownership remained in `aerobeat-spatial-ui-core`, and `screen_touch + hybrid_3d_gui` stayed truthfully `unverified`. QA independently passed and confirmed the extracted slice is real runtime behavior rather than placeholder scaffolding, the installed-addon touch provider path is truly the exercised downstream path, release-outside stays `press_end` rather than `cancel`, `drag_end` arrives before `press_end`, and press ownership stays on the original press target even when live/hover target changes. QA reran relevant validation in both repos: `aerobeat-spatial-ui-touch` passed `7/7` tests with `99` asserts, and the downstream UI-kit touch proof tests passed individually (`2/2`, `2/2`, and `1/1`) while confirming the packaged addon hash matches the source touch provider exactly. Non-blocking environment warnings remained limited to known Godot import noise and `.beads` permission warnings.

---

## Phase 7 Planning — Deepen touch extraction after slice 1

With the first real touch-runtime slice now audit-closed, the next honest slice is to continue moving reusable touch-provider behavior out of the proof host without crossing the ownership lines that were just proven. The remaining target is the next provider-owned seam around touch continuity/runtime state composition, while keeping world-hit acquisition and proof-scene composition local.

### Task 28: Extract the next touch-provider seam while preserving host-local world-hit ownership

**Bead ID:** `aerobeat-spatial-ui-touch-8cz` (coder), `aerobeat-spatial-ui-touch-2jh` (qa), `aerobeat-spatial-ui-touch-6l0` (auditor)  
**SubAgent:** `primary`  
**Role:** `coder` → `qa` → `auditor`  
**References:** `REF-04`, `REF-06`, `REF-08`  
**Prompt:** Continue the touch extraction in `aerobeat-spatial-ui-touch` by moving the next reusable provider-owned seam out of `aerobeat-ui-kit-community` and into the touch repo, while preserving all already-closed ownership boundaries. Keep world-hit acquisition, proof-scene composition, and contract/helper ownership where they belong. Add only the minimum downstream changes and tests needed to prove the deeper extraction slice.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-spatial-ui-touch/`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/` only where needed for consumer proof hookup

**Files Created/Deleted/Modified:**
- touch provider/runtime files, tests, docs, and consumer proof glue needed for the next extraction seam
- no contract-owner, shared-helper-owner, or host-world-hit-owner drift

**Status:** ✅ Audit passed

**Results:** Coder work landed in `aerobeat-spatial-ui-touch` commit `187c7a4` and `aerobeat-ui-kit-community` commit `7a91bd8`, both pushed to `main`. The next reusable touch-provider seam moved out of the proof host and into `aerobeat-spatial-ui-touch`: the provider now owns public helper entrypoints for target resolution from a projected hit and projected-data assembly from a projected hit, the UI-kit proof host’s probe wrappers were cut over to thin delegation through the packaged touch provider, and the host-local packaged touch resolver instance was removed from the proof host. World-hit acquisition, proof-scene composition, contract ownership, shared-helper ownership, and touch `unverified` truth stayed where they belong. QA independently passed and confirmed the delegated probe-wrapper path is really active: `_resolve_projected_target_path_from_hit(...)` and `_build_projected_data(...)` now return through packaged touch-provider helpers, host-local packaged touch resolver ownership is gone, and metadata/diagnostics stayed truthful (`resolution_mode=rect_target_specs`, `matched_target_key=primary`, `host_surface=PanelInputSurface`, `target_resolution=rect_target_specs`, plus correct published/live/owner target paths). Independent audit then passed and confirmed the delegated seam is truly extracted into `aerobeat-spatial-ui-touch`, the consumer proof host now delegates through the packaged provider for those wrapper paths, ownership boundaries are still clean, and the slice should be considered done. The remaining caveats are unchanged and out of scope for this slice: a pre-existing local `godotenv addons install` refusal in `aerobeat-spatial-ui-touch` due to modified vendored addon state, and the unrelated full-suite config-loader failure still present in `aerobeat-ui-kit-community`.

---

### Task 29: Extract the next touch continuity/owner-state seam into `aerobeat-spatial-ui-touch`

**Bead ID:** `aerobeat-spatial-ui-touch-8b7` (coder), `aerobeat-spatial-ui-touch-6zg` (qa), `aerobeat-spatial-ui-touch-0tp` (auditor)  
**SubAgent:** `primary`  
**Role:** `coder` → `qa` → `auditor`  
**References:** `REF-04`, `REF-06`, `REF-08`  
**Prompt:** Continue touch extraction by moving the next provider-owned continuity/owner-state seam out of `aerobeat-ui-kit-community` and into `aerobeat-spatial-ui-touch`, while keeping world-hit acquisition, proof-scene composition, contract ownership, and shared-helper ownership in their current homes. Preserve downstream packaged proof and `unverified` touch truth.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-spatial-ui-touch/`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/` only where needed for consumer proof hookup

**Files Created/Deleted/Modified:**
- touch runtime/provider files, tests, docs, and consumer proof glue needed for the next continuity/owner-state seam
- no contract-owner, shared-helper-owner, or host-world-hit-owner drift

**Status:** ⏸️ Coder complete / QA-audit deferred for fresh-context continuation

**Results:** Coder work landed in `aerobeat-spatial-ui-touch` commit `dedcc8b` and `aerobeat-ui-kit-community` commit `83e8de4`, both pushed to `main`. The next provider-owned touch continuity/owner-state seam moved out of `aerobeat-ui-kit-community`: `aerobeat-spatial-ui-touch` now publishes active owner/live-target summary fields from provider-owned runtime state, and the proof host now consumes those provider summaries for touch status/target labeling instead of interpreting `active_touch_state` locally. World-hit acquisition, proof-scene composition, contract ownership, shared-helper ownership, and `unverified` touch truth remained where they belong. Validation passed in `aerobeat-spatial-ui-touch` (`8/8`) and the relevant touch-related coverage passed in `aerobeat-ui-kit-community`, though the repo still has the same unrelated pre-existing full-suite config-loader failure outside this slice. Derrick explicitly requested wrap-up after current in-flight subagents finished, so QA/audit follow-on for this seam is intentionally deferred to the next fresh-context continuation.

---

### Task 30: Define the XR spatial UI packet stack from repo bootstrap through first extraction proof

**Bead ID:** `aerobeat-ui-kit-community-948c` (research), `aerobeat-ui-kit-community-26ea` (auditor)  
**SubAgent:** `primary`  
**Role:** `research` → `auditor`  
**References:** `REF-04`, `REF-08`, `REF-10`, `REF-11`  
**Prompt:** Build the XR packet stack using the now-proven touch lane as the pattern. Define XR readiness, first extraction packet, parity/test packet, and repo bootstrap expectations for `aerobeat-spatial-ui-xr`, without implementing XR provider code yet. Keep ownership boundaries aligned with the existing spatial-ui family.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/`
- optional notes/docs only elsewhere if strictly needed

**Files Created/Deleted/Modified:**
- durable notes/docs for XR packet stack only
- no runtime behavior changes yet

**Status:** ✅ Audit passed

**Results:** Research produced a planning-only XR packet stack in `aerobeat-spatial-ui-xr/docs/phase-2-xr-packet-stack.md`, committed and pushed as `b3457c8`. The packet stack defines XR readiness, the first extraction packet, the parity/test packet, and repo bootstrap expectations using the now-proven touch lane as the pattern. It records that XR should move only XR-specific lifecycle/runtime behavior into `aerobeat-spatial-ui-xr`, while proof-host XR rig wiring, world-hit acquisition, and authored scene composition remain in the consumer/proof repo. It also pins required parity truth: `source_type == xr`, stable `source_variant` (`xr_ray` / `xr_direct`), `verification_status == unverified` until live validation changes upstream truth, `drag_end` before `press_end`, owner continuity preserved, `cancel` reserved for interrupted continuity, and downstream installed-addon proof required. Independent audit then passed and confirmed the XR packet stack is concrete enough for future work, keeps ownership lines in the correct repos, and defines a coherent implementation order without reopening settled ownership questions.

---

### Task 31: Bootstrap cleanup and identity conversion in `aerobeat-spatial-ui-xr`

**Bead ID:** `aerobeat-spatial-ui-xr-pgc` (coder), `aerobeat-spatial-ui-xr-4fu` (qa), `aerobeat-spatial-ui-xr-e6p` (auditor)  
**SubAgent:** `primary`  
**Role:** `coder` → `qa` → `auditor`  
**References:** `REF-04`, `REF-08`, `REF-10`, `REF-11`  
**Prompt:** Convert `aerobeat-spatial-ui-xr` from raw template copy into a truthful XR-lane bootstrap repo, using the closed XR packet stack as the source of truth. This slice is bootstrap/boundary work only, not XR-provider implementation: fix repo identity, boundary docs, manifest/plugin/testbed naming, and lay down the minimum `src/providers/xr/` scaffold and test/docs placeholders required by the XR packet stack without adding real XR runtime behavior yet.

**Folders Created/Deleted/Modified:**
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-spatial-ui-xr/`

**Files Created/Deleted/Modified:**
- README / plugin / docs / testbed / boundary scaffold files needed to convert template identity into truthful XR-lane bootstrap state
- no real XR provider implementation yet

**Status:** ⏸️ Coder complete / QA deferred for fresh-context continuation

**Results:** Coder work landed in commit `363f52f` and was pushed to `main`. `aerobeat-spatial-ui-xr` was converted from raw template copy into a truthful XR bootstrap repo: repo identity/docs/plugin text now describe the XR spatial UI bootstrap lane; template-boundary scaffolding was replaced by inert `src/providers/xr/` bootstrap files aligned to the XR packet-stack ownership line; XR-specific bootstrap/boundary test scaffolding replaced the old template test; and `.testbed` manifest/project identity were updated accordingly. Validation passed with `godotenv addons install`, headless import, and GUT (`5` scripts, `8` tests, `74` asserts, all passing). Derrick explicitly requested wrap-up after the current in-flight subagents finished, so QA/audit follow-on for this XR bootstrap slice is intentionally deferred to the next fresh-context continuation rather than spawning more lanes in this session.

---

## Active Blockers / Guardrails

1. **Do not let `spatial-ui-core` drift into contract ownership.** It is helper-layer only.
2. **Do not let native 2D and spatial providers publish divergent meanings.** The semantic parity matrix in `REF-08` is the baseline.
3. **Do not let `ui-kit-community` remain the long-term owner of spatial mouse glue.** It must become a consumer/example repo over time.
4. **Treat the `ObjectDB instances leaked at exit` warning as known Godot 4.6.2 toolchain noise unless a later phase produces contrary evidence.** It is not a current blocker.

---

## Final Results

**Status:** ✅ Phase 0 Complete / ✅ Phase 1 Complete / ✅ Phase 2 Complete / ✅ Phase 3 Complete / ✅ Phase 4 Complete

**What We Built:** A durable cross-repo planning package for the `aerobeat-spatial-ui-*` family, then completed and audit-closed the full Phase 0 bootstrap cleanup across `aerobeat-spatial-ui-core`, `aerobeat-spatial-ui-mouse`, and `aerobeat-template-spatial-ui`, followed by a full Phase 1 boundary freeze across those repos plus the consumer/reference side in `aerobeat-ui-kit-community`, followed by the first real Phase 2 extraction/cutover pass: shared helper extraction into `aerobeat-spatial-ui-core`, mouse-provider extraction into `aerobeat-spatial-ui-mouse`, and proof-host cutover in `aerobeat-ui-kit-community`, followed by a fully audit-closed Phase 3 that removed the provider-local fallback from `aerobeat-spatial-ui-mouse`, proved packaged resolver ownership through downstream-style installed-addon validation, and tightened `aerobeat-ui-kit-community` so the proof host demonstrates the packaged resolver route end-to-end on the consumer side while narrowing the remaining local seams explicitly, followed by a fully audit-closed Phase 4 that hardened both the public architecture docs and the spatial adapter template so future work inherits the correct post-Phase-3 ownership split instead of drifting back toward consumer-repo fallback ownership.

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
