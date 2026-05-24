# AeroBeat UI Kit Community

**Date:** 2026-05-16  
**Status:** Draft  
**Agent:** Byte 🐈‍⬛

---

## Goal

Refresh the `.testbed/addons.jsonc` addon pins in `aerobeat-ui-kit-community` so the testbed points at the latest intended AeroBeat addon commits.

---

## Overview

The immediate ask is to update the testbed’s GodotEnv addon pins rather than keep troubleshooting an older pinned `aerobeat-ui-core` checkout. Right now `.testbed/addons.jsonc` points `aerobeat-ui-core` at `b5c6222`, while the local owning repo is already at `f2ed54296117da90c1462699d3705ca4e30783ea`. `aerobeat-input-core` is already pinned to `22c4666efe96ba64b0f23907202a411000d72d41`, which currently matches the local repo HEAD.

This plan is intentionally narrow: update the addon pin(s), validate that the file is correct and consistent with the intended latest commits, and then audit the result. We are not solving the broader hybrid click bug in this slice; this is just dependency pin refresh for the hidden testbed.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Current testbed addon pins | `.testbed/addons.jsonc` |
| `REF-02` | Latest local `aerobeat-ui-core` HEAD | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-core@f2ed54296117da90c1462699d3705ca4e30783ea` |
| `REF-03` | Latest local `aerobeat-input-core` HEAD | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-input-core@22c4666efe96ba64b0f23907202a411000d72d41` |

---

## Tasks

### Task 1: Update the testbed addon pins to the intended latest commits

**Bead ID:** `aerobeat-ui-kit-community-d76`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, update `.testbed/addons.jsonc` so the testbed points at the intended latest addon commits. At minimum, refresh `aerobeat-ui-core` from the older `b5c6222` pin to the latest intended commit. Confirm whether `aerobeat-input-core` also needs a pin change or is already current. Keep the change narrow, validate the file shape, and commit/push before handoff unless concretely blocked.

**Folders Created/Deleted/Modified:**
- `.testbed/`
- `.plans/`

**Files Created/Deleted/Modified:**
- `.testbed/addons.jsonc`

**Status:** ⏳ Pending

**Results:** Pending.

---

### Task 2: QA the pin refresh and confirm the testbed now references the intended commits

**Bead ID:** `Pending`  
**SubAgent:** `primary` (for `qa` workflow role)  
**Role:** `qa`  
**References:** `REF-01`, `REF-02`, `REF-03`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, verify that `.testbed/addons.jsonc` now references the intended latest commits and remains valid for GodotEnv consumption. If practical, verify the file values directly against the sibling repo HEADs.

**Folders Created/Deleted/Modified:**
- `.plans/`

**Files Created/Deleted/Modified:**
- optional QA notes if needed

**Status:** ⏳ Pending

**Results:** Pending.

---

### Task 3: Audit whether the pin refresh is correct and narrowly scoped

**Bead ID:** `Pending`  
**SubAgent:** `primary` (for `auditor` workflow role)  
**Role:** `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, audit the addon pin refresh independently. Confirm the file now points at the intended latest commits and that the change stayed narrowly scoped to the dependency pin update.

**Folders Created/Deleted/Modified:**
- `.plans/`

**Files Created/Deleted/Modified:**
- optional audit notes if needed

**Status:** ⏳ Pending

**Results:** Pending.

---

## Final Results

**Status:** ⏳ Pending

**What We Built:** Pending execution.

**Reference Check:** Pending execution.

**Commits:**
- Pending

**Lessons Learned:** Pending execution.

---

*Drafted on 2026-05-16*