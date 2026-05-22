# AeroBeat UI Kit Community — GodotEnv Assets Symlink for Shader Pack

**Date:** 2026-05-22  
**Status:** Draft  
**Agent:** Byte 🐈‍⬛

---

## Goal

Update the testbed’s GodotEnv addon config so it can symlink the repo-root `/assets/` folder into the testbed, then sync to the latest remote commit that adds the 3D glass shader asset pack Derrick wants to try in person.

---

## Overview

The current `.testbed/addons.jsonc` only mounts Git-backed addons (`aerobeat-ui-core`, `aerobeat-input-core`, and `gut`). Derrick now wants the hidden testbed to see the repo-root `assets/` folder as well, specifically so the newly added 3D glass shader effects pack on `origin/main` can be exercised inside the testbed project. That means this task has two linked parts: first pull/sync the repo to include the newly added asset pack commit (`3c5823b` on `origin/main`), then adjust the GodotEnv config to expose the repo-root assets into the testbed in the right way.

Because this repo is currently `ahead 2, behind 1`, execution also needs to handle Git state carefully. There are local committed fixes plus untracked plan/probe files. The safe approach is to inspect how this repo currently expects local-folder mounts in `addons.jsonc`, update only the needed config entry, then validate the resulting symlink/mount behavior with the existing sync path rather than hand-editing generated testbed contents.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Current testbed GodotEnv config | `.testbed/addons.jsonc` |
| `REF-02` | Latest remote commit adding shader pack | `origin/main@3c5823b` |
| `REF-03` | Prior testbed addon-pin/sync work | `.plans/2026-05-16-testbed-addon-pin-refresh.md` |
| `REF-04` | GodotEnv/testbed sync expectations in this repo | local repo scripts/config discovered during execution |

---

## Tasks

### Task 1: Research the correct GodotEnv local-folder mount shape for repo-root assets

**Bead ID:** `aerobeat-ui-kit-community-fjn`  
**SubAgent:** `primary` (for `research` workflow role)  
**Role:** `research`  
**References:** `REF-01`, `REF-03`, `REF-04`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, inspect how `.testbed/addons.jsonc` and any related GodotEnv sync tooling expect local folder mounts or symlinked asset sources to be declared. Determine the correct config shape to expose the repo-root `/assets/` directory inside the hidden `.testbed` project without patching generated consumer state by hand.

**Folders Created/Deleted/Modified:**
- none unless notes are needed

**Files Created/Deleted/Modified:**
- optional notes only

**Status:** ⏳ Pending

**Results:** Awaiting execution.

---

### Task 2: Sync to latest remote and update `.testbed/addons.jsonc` to mount repo-root assets

**Bead ID:** `aerobeat-ui-kit-community-05s`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-04`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, safely integrate the latest remote commit that adds the new shader asset pack, then update `.testbed/addons.jsonc` so the testbed can symlink/mount the repo-root `/assets/` folder for in-person testing. Use the canonical sync path for generated addon state rather than hand-editing consumer mirrors.

**Folders Created/Deleted/Modified:**
- `.testbed/`
- repo root as needed for sync artifacts

**Files Created/Deleted/Modified:**
- `.testbed/addons.jsonc`
- any directly related sync/config file truly required

**Status:** ⏳ Pending

**Results:** Awaiting execution.

---

### Task 3: QA that the testbed now sees the repo-root assets pack correctly

**Bead ID:** `aerobeat-ui-kit-community-cir`  
**SubAgent:** `primary` (for `qa` workflow role)  
**Role:** `qa`  
**References:** `REF-01`, `REF-02`, `REF-04`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, verify that after sync the hidden `.testbed` project can see the repo-root assets folder and that the newly added 3D glass shader asset pack is available for use in the testbed. Be explicit about what path(s) became visible and how you verified them.

**Folders Created/Deleted/Modified:**
- `.temp/qa-evidence/` if useful

**Files Created/Deleted/Modified:**
- QA evidence artifacts only if produced

**Status:** ⏳ Pending

**Results:** Awaiting execution.

---

### Task 4: Audit the final sync/config state for correctness and cleanliness

**Bead ID:** `aerobeat-ui-kit-community-ygv`  
**SubAgent:** `primary` (for `auditor` workflow role)  
**Role:** `auditor`  
**References:** `REF-01`, `REF-02`, `REF-04`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, independently audit the final repo state: latest shader-pack commit integrated as intended, `.testbed/addons.jsonc` updated correctly for repo-root assets exposure, and no hand-edited generated consumer state relied on as the durable solution.

**Folders Created/Deleted/Modified:**
- `.plans/` if results update is needed

**Files Created/Deleted/Modified:**
- optional audit notes only

**Status:** ⏳ Pending

**Results:** Awaiting execution.

---

## Final Results

**Status:** ⏳ Pending

**What We Built:** Pending execution.

**Reference Check:** Pending execution.

**Commits:**
- Pending

**Lessons Learned:** Pending execution.

---

*Drafted on 2026-05-22*
