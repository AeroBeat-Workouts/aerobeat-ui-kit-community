# AeroBeat UI Kit Community — Hybrid Default Preset v1/v2 Split

**Date:** 2026-05-18  
**Status:** Complete  
**Agent:** Cookie 🍪

---

## Goal

Clone the older hybrid `default.json` glass preset into `default-v1.json`, preserve the newer current version as `default-v2.json`, and leave both available side-by-side so Derrick can iterate on a new lighting/color balance without losing the older frosted-glass baseline.

---

## Overview

The latest hybrid preset fix solved the whiteout problem, but it also changed the look enough that Derrick wants both generations preserved for comparison and follow-up tuning. This is a good fit for a small, explicit preset split rather than destructive editing. The key detail is choosing the right historical `default.json` version to represent the older frosted-glass look, then copying the current version into a clearly named `default-v2.json` so both versions can be loaded or diffed directly.

This work should stay small and reversible: identify the old commit, write `default-v1.json` from that historical content, write `default-v2.json` from current `main`, and keep the current `default.json` untouched unless the implementation step discovers a strong reason to alias or document it differently.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Current hybrid default preset path | `.testbed/presets/glass/hybrid/default.json` |
| `REF-02` | Recent whiteout/ordering fix commit that changed current preset | `7e27eeb` |
| `REF-03` | Older default preset history to mine for v1 | `git log -- .testbed/presets/glass/hybrid/default.json` |

---

## Tasks

### Task 1: Identify the correct historical default preset for v1

**Bead ID:** `aerobeat-ui-kit-community-8u0`  
**SubAgent:** `primary` (for `research` workflow role)  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, inspect the git history for `.testbed/presets/glass/hybrid/default.json` and determine which historical version should be treated as the older frosted-glass baseline for `default-v1.json`, versus the current version that should become `default-v2.json`. Report the exact commit(s) and why the chosen baseline is the right split point.

**Folders Created/Deleted/Modified:**
- optional `.temp/`

**Files Created/Deleted/Modified:**
- `.temp/aerobeat-ui-kit-community-8u0-research-notes.md`

**Status:** ✅ Complete

**Results:** Research confirmed Derrick’s provided commit is the correct split point. Commit `ff6b7b71a93282f113898c6929ccad5845296f0d` contains the historical `.testbed/presets/glass/hybrid/default.json` snapshot that should become `default-v1.json`, while current `main` should become `default-v2.json`. The preset file does differ from current `main` exactly as expected after the recent hybrid retune, and the first subsequent commit that changed the preset file is `7e27eeb` (`Fix hybrid glass button contrast and control ordering`). Notes were written to `.temp/aerobeat-ui-kit-community-8u0-research-notes.md`, and the exact retrieval commands were recorded for the coder.

---

### Task 2: Create `default-v1.json` and `default-v2.json`

**Bead ID:** `aerobeat-ui-kit-community-bnr`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, create `.testbed/presets/glass/hybrid/default-v1.json` from the selected older historical preset and `.testbed/presets/glass/hybrid/default-v2.json` from the current `default.json`. Keep the files cleanly formatted and commit/push the result to `main` by default.

**Folders Created/Deleted/Modified:**
- `.testbed/presets/glass/hybrid/`

**Files Created/Deleted/Modified:**
- `.testbed/presets/glass/hybrid/default-v1.json`
- `.testbed/presets/glass/hybrid/default-v2.json`

**Status:** ✅ Complete

**Results:** Implementation landed and was pushed to `main` in commit `34313e7`. `default-v1.json` was created exactly from commit `ff6b7b71a93282f113898c6929ccad5845296f0d` at `.testbed/presets/glass/hybrid/default.json`, and `default-v2.json` was created exactly from the current `main` working copy of `.testbed/presets/glass/hybrid/default.json`. Validation confirmed the split is exact: historical `git show ... default.json` matched `default-v1.json` with no diff output, and current `default.json` matched `default-v2.json` byte-for-byte with identical SHA-256 hashes for `default-v2.json` and current `default.json`.

---

### Task 3: QA the split for correctness

**Bead ID:** `aerobeat-ui-kit-community-6dt`  
**SubAgent:** `primary` (for `qa` workflow role)  
**Role:** `qa`  
**References:** `REF-01`, `REF-02`, `REF-03`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, verify that `default-v1.json` matches the intended historical preset and that `default-v2.json` matches the current `default.json` on `main`. Confirm the split is exact and usable for later tuning work.

**Folders Created/Deleted/Modified:**
- optional `.temp/qa-evidence/`

**Files Created/Deleted/Modified:**
- `.temp/qa-evidence/aerobeat-ui-kit-community-6dt-qa.md`
- `.temp/qa-evidence/default-v1-vs-historical.diff`
- `.temp/qa-evidence/default-v2-vs-current.diff`

**Status:** ✅ Complete

**Results:** QA approved the split based on exact diff/hash verification. `default-v1.json` and the historical preset snapshot from commit `ff6b7b71a93282f113898c6929ccad5845296f0d` have identical SHA-256 hashes and zero diff output, while `default-v2.json` and the current `default.json` on `main` likewise have identical SHA-256 hashes and zero diff output. The split is exact and ready for later tuning work.

---

### Task 4: Audit the preset split

**Bead ID:** `aerobeat-ui-kit-community-nnn`  
**SubAgent:** `primary` (for `auditor` workflow role)  
**Role:** `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, independently audit the new `default-v1.json` / `default-v2.json` split and confirm the two files represent the intended old and current preset generations accurately.

**Folders Created/Deleted/Modified:**
- `.temp/qa-evidence/`

**Files Created/Deleted/Modified:**
- `.temp/qa-evidence/aerobeat-ui-kit-community-6dt-qa.md`
- `.temp/qa-evidence/default-v1-vs-historical.diff`
- `.temp/qa-evidence/default-v2-vs-current.diff`

**Status:** ✅ Complete

**Results:** Final audit passed. `default-v1.json` exactly matches the historical preset snapshot from commit `ff6b7b71a93282f113898c6929ccad5845296f0d`, `default-v2.json` exactly matches the current `default.json` on `main`, and the current `default.json` remained untouched by the split.

---

## Final Results

**Status:** ✅ Complete

**What We Built:** A clean historical/current preset split for the hybrid default preset family, with `default-v1.json` preserving the older frosted-glass baseline and `default-v2.json` preserving the current corrected preset while leaving `default.json` in place.

**Reference Check:** `REF-01` remained the canonical current file, `REF-02` captured the retuned current generation, and `REF-03` was resolved exactly to the historical split point Derrick specified.

**Commits:**
- `34313e7` - Create hybrid default-v1.json and default-v2.json
- `ce82235` - Document hybrid preset fixes and preset split plans

**Lessons Learned:** When Derrick knows the exact historical split point, use the commit as the source of truth instead of re-litigating history discovery.

---

*Drafted on 2026-05-18*
