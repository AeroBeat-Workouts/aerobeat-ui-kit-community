# AeroBeat UI Kit Community

**Date:** 2026-06-03  
**Status:** Complete  
**Last Updated:** 2026-06-03 21:48 EDT  
**Blocked Reason:** None  
**Agent:** `cookie`

---

## Goal

Identify exactly where shader UID duplication exists after the repo-root shader move and define the cleanup seam before editing anything.

---

## Overview

The immediate need is discovery, not mutation. The likely conflict surface is the same physical shader files being visible to the `.testbed` project under more than one `res://` path after the root-asset move and the testbed addon mount.

This plan records the current investigation seam so a follow-up cleanup can be executed cleanly once Derrick confirms the intended path strategy.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Root shader ownership | `assets/shaders/` |
| `REF-02` | Testbed shader re-hook | `.testbed/assets/shaders` |
| `REF-03` | Testbed self-addon mount | `.testbed/addons/aerobeat-ui-kit-community` |
| `REF-04` | Testbed addon manifest | `.testbed/addons.jsonc` |

---

## Tasks

### Task 1: Investigate duplicate shader UID locations

**Bead ID:** `aerobeat-ui-kit-community-f0l`  
**SubAgent:** `primary` (for `research`)  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** Inspect the current duplicate-UID surface in `aerobeat-ui-kit-community` after the root shader move. Identify the exact paths under which the same shader UIDs are visible to the `.testbed` project, and explain whether the duplication is caused by the `.testbed/assets/shaders` re-hook, the `.testbed/addons/aerobeat-ui-kit-community` self-addon mount, or both.

**Folders Created/Deleted/Modified:**
- `None expected`

**Files Created/Deleted/Modified:**
- `Investigation only; no edits`

**Status:** ✅ Complete

**Results:** Duplicate shader UIDs exist because the same repo-root shader files are visible to the `.testbed` project under multiple resource paths: direct root ownership via `assets/shaders/*`, the `.testbed/assets/shaders -> ../../assets/shaders` re-hook, and the self-addon mount `.testbed/addons/aerobeat-ui-kit-community -> <repo-root>` which exposes the same files again under `res://addons/aerobeat-ui-kit-community/assets/shaders/*`. Confirmed duplicated UID-bearing shader files are `glass-shader.gdshader(.uid)`, `glass-panel-hybrid-3d.gdshader(.uid)`, and `glass-panel-ui-overlay-3d.gdshader(.uid)`.

---

## Final Results

**Status:** ✅ Complete

**What We Built:** Investigated the duplicate shader UID surface and established the root cause: the same repo-owned shader files were visible to `.testbed` through both the mistaken `.testbed/assets/shaders` re-hook and the intended self-addon mount.

**Reference Check:** `REF-01` through `REF-04` used for discovery. That discovery directly drove the follow-up addon-path refactor plan.

**Commits:**
- None.

**Lessons Learned:** The duplicate warnings were path-identity overlap, not a leftover removed-file problem. The right repair was to remove the extra shader visibility path and standardize `.testbed` on the addon-mounted contract.

---

*Completed on 2026-06-03*