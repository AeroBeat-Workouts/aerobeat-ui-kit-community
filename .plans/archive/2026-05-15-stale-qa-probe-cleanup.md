# AeroBeat UI Kit Community — Stale QA Probe Cleanup

**Date:** 2026-05-15  
**Status:** Stale  
**Agent:** Byte 🐈‍⬛

---

## Goal

Clean up the stale temporary QA probe artifacts in `aerobeat-ui-kit-community` that still assume the pre-extraction direct-child consumer layout, so future QA does not produce false negatives against the now-correct `ui-core` binding-owned architecture.

---

## Overview

The contract-consumer extraction into `aerobeat-ui-core` was approved and audited as the correct long-term boundary. The one immediate follow-up required by audit is not product work but QA hygiene: some older temporary probes in `ui-kit-community/.temp/qa-evidence/` still look for direct-child `AeroUiInteractable` / `AeroUiInteractionListener` nodes under the panel root. After the extraction, those consumers are now owned under `AeroUiContractTargetBinding` nodes, so the old probes are stale by design and can report false failures.

This cleanup belongs in `aerobeat-ui-kit-community`, because that repo owns the temporary QA artifacts and their current assumptions. The slice should be deliberately small: identify the stale probes, either update them to the binding-owned architecture or remove/replace them if they no longer serve a useful purpose, then run a minimal validation pass to make sure QA tooling matches the real architecture again. After that, we can land the plane with a clean handoff.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | UI-core extraction plan/results | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-core/.plans/2026-05-15-ui-contract-consumer-extraction.md` |
| `REF-02` | Current extracted panel consumer script | `.testbed/scripts/glass_shader_panel_source.gd` |
| `REF-03` | Current hybrid host script | `.testbed/scripts/glass_shader_gui_3d_test.gd` |
| `REF-04` | Current screen 2D host script | `.testbed/scripts/glass_shader_test.gd` |
| `REF-05` | Current temporary QA evidence folder | `.temp/qa-evidence/` |

---

## Tasks

### Task 1: Identify stale QA probes and choose update vs remove strategy

**Bead ID:** `aerobeat-ui-kit-community-ash`  
**SubAgent:** `primary` (for `research` workflow role)  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, inspect `.temp/qa-evidence/` and identify which temporary QA probes still assume the pre-extraction direct-child consumer layout. Recommend which ones should be updated to the binding-owned architecture versus removed/replaced, and keep the cleanup scope minimal.

**Folders Created/Deleted/Modified:**
- `.plans/`
- `.temp/qa-evidence/`

**Files Created/Deleted/Modified:**
- optional cleanup note if useful

**Status:** ✅ Complete

**Results:** Research identified the minimum hygiene slice required after UI-core extraction: update the retained useful contract probes in `.temp/qa-evidence/` to the new binding-owned architecture, remove clearly obsolete pre-extraction debug probes, and leave the architecture-aligned smoke validator `.temp/qa/validate_contract_consumer_adoption.gd` intact. Cleanup note written to `docs/notes/2026-05-15-stale-qa-probe-cleanup-note.md`.

---

### Task 2: Apply the stale QA probe cleanup

**Bead ID:** `aerobeat-ui-kit-community-19a`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-02`, `REF-03`, `REF-04`, `REF-05`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, update or remove the stale temporary QA probes that still assume direct-child consumer nodes. Keep the cleanup tightly scoped to QA artifact hygiene, and ensure any retained probes match the binding-owned architecture introduced by `aerobeat-ui-core` extraction.

**Folders Created/Deleted/Modified:**
- `.temp/qa-evidence/`

**Files Created/Deleted/Modified:**
- stale QA probe artifacts in `.temp/qa-evidence/`
- any small replacement/updated validation probes if needed

**Status:** ✅ Complete

**Results:** The stale QA-probe cleanup landed in commit `1ff58d5` (`Clean up stale QA probes`). The retained useful probes in `.temp/qa-evidence/` were updated to the binding-owned contract-consumer layout (`hybrid_contract_probe.gd`, `screen_2d_contract_probe.gd`, `multi_target_hybrid_qa_probe.gd`), including replacing stale direct-child consumer assumptions with `AeroUiContractTargetBinding`-based checks and refreshing their JSON outputs. Clearly obsolete pre-extraction debug probes (`check_bus_path.gd`, `check_contract_retry.gd`, `inspect_contract_flow.gd`, `inspect_contract_flow_2.gd`, `inspect_contract_flow_rebind.gd`) were removed from the working tree instead of being ported. The architecture-aligned smoke test `.temp/qa/validate_contract_consumer_adoption.gd` was intentionally left untouched. Coder validation re-ran the retained probes and `git diff --check`, and no production scene/runtime files were touched.

---

### Task 3: QA the cleanup and confirm no false-negative artifact drift remains

**Bead ID:** `aerobeat-ui-kit-community-7gb`  
**SubAgent:** `primary` (for `qa` workflow role)  
**Role:** `qa`  
**References:** `REF-02`, `REF-05`  
**Prompt:** Verify that the stale temporary QA artifact assumptions are gone and that the retained probes match the binding-owned contract-consumer layout. Confirm this is hygiene cleanup only, not product behavior change.

**Folders Created/Deleted/Modified:**
- `.temp/qa-evidence/` if needed

**Files Created/Deleted/Modified:**
- QA evidence artifacts if produced

**Status:** ✅ Complete

**Results:** QA passed for the intended hygiene scope. The retained updated probes now match the binding-owned architecture, the obsolete pre-extraction direct-child probes are gone, the architecture smoke validator remains aligned, and the old false-negative direct-child layout mismatch is no longer present in the current truth-carrying probes. QA also confirmed that the cleanup commit touched temp-only artifacts and did not modify production behavior. Some other older `.temp` artifacts remain stale outside this exact cleanup slice, but they are out-of-scope leftovers rather than regressions in the fixed probes.

---

### Task 4: Audit cleanup completeness and handoff readiness

**Bead ID:** `aerobeat-ui-kit-community-xom`  
**SubAgent:** `primary` (for `auditor` workflow role)  
**Role:** `auditor`  
**References:** `REF-01`, `REF-05`  
**Prompt:** Audit the stale QA probe cleanup and decide whether the repo is now clean enough to land the plane without carrying known false-negative artifact drift forward.

**Folders Created/Deleted/Modified:**
- `.plans/`

**Files Created/Deleted/Modified:**
- optional audit notes if produced

**Status:** ✅ Complete

**Results:** Audit passed for the intended cleanup slice and explicitly cleared it as safe to land the plane. The specific false-negative direct-child consumer mismatch is fixed for the retained probes and the architecture-aligned smoke validator. Remaining older `.temp` probes are now just truthful out-of-scope historical/debug artifacts and should not be treated as authoritative without re-auditing them against the current binding-owned architecture.

---

## Final Results

**Status:** ✅ Complete

**What We Built:** Cleaned up the stale temporary QA probes left behind by the UI-core extraction so the retained contract probes now validate the binding-owned consumer shape instead of the old direct-child layout.

**Reference Check:** The cleanup stayed scoped to temp QA artifacts, left production scene/runtime code untouched, and preserved `.temp/qa/validate_contract_consumer_adoption.gd` as the architecture-aligned smoke test.

**Commits:**
- `1ff58d5` - Clean up stale QA probes

**Lessons Learned:** When extracting architecture, cleanup of truth-carrying QA probes matters almost as much as the code move itself. Old temp probes can easily become false-negative traps if they preserve pre-extraction node-shape assumptions.

---

*Drafted on 2026-05-15*