# AeroBeat UI Kit Community Downscope Alignment

**Date:** 2026-05-01  
**Status:** In Progress  
**Agent:** Chip 🐱‍💻

---

## Goal

Align `aerobeat-ui-kit-community` with the downscoped AeroBeat v1 UI/product truth so the shared community visual layer reflects desktop-first current scope without implying broader present-tense platform or gameplay-input parity.

---

## Overview

With `aerobeat-ui-core` now aligned, the next likely drift surface is the shared community UI kit layer. This repo may carry shell-facing wording, examples, testbed assumptions, or styling conventions that still speak too broadly about current desktop/mobile/web/XR parity or blur gameplay input with UI navigation concerns.

This slice starts with a repo-local audit so we can see whether the repo only needs scope-language cleanup or whether deeper shared UI-kit/testbed surfaces still encode the older worldview.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Active plan for this repo-local cleanup slice | `.plans/2026-05-01-aerobeat-ui-kit-community-downscope-alignment.md` |
| `REF-02` | Updated AeroBeat docs source of truth | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-docs` |
| `REF-03` | Parent coordination plan and matrix | `/home/derrick/.openclaw/workspace/projects/openclaw-chip/.plans/2026-05-01-aerobeat-polyrepo-downscope-audit.md` |
| `REF-04` | Recently aligned UI/input/core surfaces | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-core` |

---

## Tasks

### Task 1: Audit `aerobeat-ui-kit-community` for stale downscope assumptions

**Bead ID:** `aerobeat-ui-kit-community-vfu`  
**SubAgent:** `primary`  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** Audit this repo against the updated docs and aligned shared UI/input/core surfaces. Identify stale ui-kit assumptions such as broad current shell/platform parity, UI-facing gameplay-input coupling, or docs/examples/tests that fail to distinguish desktop-first current scope from future/deprioritized mobile/web/XR paths. Do not edit yet; produce an execution-ready list.

**Folders Created/Deleted/Modified:**
- `.plans/`
- `docs/`
- `src/`
- `tests/`

**Files Created/Deleted/Modified:**
- `.plans/2026-05-01-aerobeat-ui-kit-community-downscope-alignment.md`
- `docs/**`
- `src/**`
- `tests/**`

**Status:** ✅ Complete

**Results:** Completed the stale UI-kit-scope audit. Main findings: there is no deep runtime/code contract drift, but the repo still has one important stale dev/test dependency (`aerobeat-core` pinned in `.testbed/addons.jsonc`), overly generic repo-positioning language in `README.md`, broad metadata wording in `plugin.cfg`, and only a placeholder test in `.testbed/tests/test_example.gd` rather than a real scope guard. The approved next step is a small coder slice: remove the stale dependency, replace the scaffold test with a manifest/scope guard, and tighten README/plugin wording around desktop-first current scope and no gameplay-input coupling.

---

### Task 2: Apply the repo cleanup and scope alignment

**Bead ID:** `aerobeat-ui-kit-community-04z`  
**SubAgent:** `primary`  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** After the audit/action list is approved, update this repo so its shared ui-kit docs/examples/tests match the downscoped AeroBeat v1 UI/product truth. Commit and push by default.

**Folders Created/Deleted/Modified:**
- `.plans/`
- `docs/`
- `src/`
- `tests/`

**Files Created/Deleted/Modified:**
- `.plans/2026-05-01-aerobeat-ui-kit-community-downscope-alignment.md`
- `docs/**`
- `src/**`
- `tests/**`

**Status:** ✅ Complete

**Results:** Applied the downscope UI-kit alignment. The coder pass removed the stale `aerobeat-core` pin from `.testbed/addons.jsonc`, replaced the placeholder GUT scaffold in `.testbed/tests/test_example.gd` with a repo-specific guardrail that asserts `aerobeat-ui-core` is present and `aerobeat-core` is absent, rewrote `README.md` to position the repo as the default community visual layer with desktop/PC current priority and future/deprioritized mobile/web/XR shells, and tightened `plugin.cfg` so it no longer implies broad current parity across shells/editions. Validation passed after installing testbed deps/importing resources and running the hidden GUT suite. Changes were committed/pushed as `09b7f68` (`Align ui-kit community with desktop-first scope`). Upstream dependency copies under `.testbed/addons/` and `.testbed/.addons/` still contain their own `aerobeat-core` references inside `aerobeat-ui-core`, but those were intentionally left alone because they belong to the dependency repo, not this repo’s committed source surface.

---

### Task 3: QA and audit the alignment

**Bead ID:** `aerobeat-ui-kit-community-rrm` (QA), `aerobeat-ui-kit-community-8e4` (Auditor)  
**SubAgent:** `primary`  
**Role:** `qa` then `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** Independently verify that this repo reflects desktop-first current scope, future/deprioritized other shells, and the UI-vs-gameplay-input distinction without reasserting old parity assumptions.

**Folders Created/Deleted/Modified:**
- `.plans/`
- `docs/`
- `src/`
- `tests/`

**Files Created/Deleted/Modified:**
- `.plans/2026-05-01-aerobeat-ui-kit-community-downscope-alignment.md`
- `docs/**`
- `src/**`
- `tests/**`

**Status:** ✅ Complete

**Results:** QA passed with no fixes required and the auditor independently approved the slice. Final verified state: the repo no longer teaches a foundational dependency on `aerobeat-core`; desktop/PC is clearly the current UI priority; mobile/web/XR are framed as future/deprioritized rather than equal current peers; gameplay input remains distinct from UI/menu visual concerns; `.testbed/addons.jsonc` now declares only `aerobeat-ui-core` and `gut`; and `.testbed/tests/test_example.gd` now acts as a real manifest-boundary guard. The hidden GUT suite passed through both QA and audit.

---

## Final Results

**Status:** ✅ Complete

**What We Built:** Completed the `aerobeat-ui-kit-community` downscope slice by removing the stale `aerobeat-core` testbed dependency, replacing the placeholder test with a real manifest-boundary guard, and tightening README/plugin wording around desktop-first current scope and no gameplay-input coupling.

**Reference Check:** Repo is aligned to the downscoped UI/product truth and audited complete.

**Commits:**
- `09b7f68` - Align ui-kit community with desktop-first scope

**Lessons Learned:** Shared visual/UI-kit layers can quietly reintroduce old scope assumptions through examples and positioning language even when lower-level UI-core is clean, so even small manifest/test scaffolds deserve audit attention.

---

*Completed on 2026-05-01*