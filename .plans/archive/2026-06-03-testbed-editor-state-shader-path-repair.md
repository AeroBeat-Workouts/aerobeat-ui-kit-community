# AeroBeat UI Kit Community

**Date:** 2026-06-03  
**Status:** Complete  
**Last Updated:** 2026-06-03 21:48 EDT  
**Blocked Reason:** None  
**Agent:** `cookie`

---

## Goal

Repair stale `.testbed` Godot editor state so it no longer points at the removed `res://assets/shaders/...` shader path and instead reflects the addon-mounted shader location.

---

## Overview

The live `.testbed` sources were already refactored to use `res://addons/aerobeat-ui-kit-community/assets/shaders/...`, and the duplicate-UID warning caused by the mistaken `.testbed/assets/shaders` bridge is gone. The remaining issue is stale generated/editor state under `.testbed/.godot/editor`, which still remembers the old shader path and causes the editor startup/load complaint.

The narrow repair path is to update or clear only the specific stale editor-state entries that reference `res://assets/shaders/...`, then re-run a lightweight import/startup validation to confirm the warning is gone. This should stay focused on tracked `.testbed/.godot/editor/*` state rather than broad cache purges unless the targeted repair proves insufficient.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Stale editor layout state with old shader path | `.testbed/.godot/editor/editor_layout.cfg` |
| `REF-02` | Current imported filesystem/editor cache truth | `.testbed/.godot/editor/filesystem_cache10` |
| `REF-03` | Correct live shader path contract | `.testbed/addons/aerobeat-ui-kit-community/assets/shaders/` |
| `REF-04` | Approved addon-path refactor plan | `.plans/2026-06-03-testbed-shader-addon-path-refactor.md` |

---

## Tasks

### Task 1: Inventory exact stale editor-state entries that still reference removed shader paths

**Bead ID:** `aerobeat-ui-kit-community-ava`  
**SubAgent:** `primary` (for `research`)  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** Claim the assigned bead on start. Inspect `.testbed/.godot/editor` state and inventory the exact entries still referencing removed `res://assets/shaders/...` paths. Distinguish stale generated/editor state from already-correct entries, and identify the narrowest safe edit/removal set needed to stop the stale shader load complaint without broad cache churn.

**Folders Created/Deleted/Modified:**
- `None expected`

**Files Created/Deleted/Modified:**
- `Inventory only; no edits`

**Status:** ✅ Complete

**Results:** Research confirmed only one editor-state file is stale for this issue: `.testbed/.godot/editor/editor_layout.cfg`. Exact stale entries are the `uncollapsed_paths` item containing `res://assets/shaders/`, `open_shaders=["res://assets/shaders/glass-shader.gdshader"]`, and `selected_shader="res://assets/shaders/glass-shader.gdshader"`. Research also confirmed `.testbed/.godot/editor/filesystem_cache10` is already correct for shader-path truth and should be left alone; it points at `res://addons/aerobeat-ui-kit-community/assets/shaders/...` for the live shader and only retains valid `.testbed/assets/images` state under `res://assets/`. Narrowest safe repair is to update or clear `open_shaders` and `selected_shader`, with optional hygiene cleanup of the stale `uncollapsed_paths` entry.

---

### Task 2: Repair stale `.testbed/.godot/editor` shader-path state

**Bead ID:** `aerobeat-ui-kit-community-o6x`  
**SubAgent:** `primary` (for `coder`)  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** Claim the assigned bead on start. Repair the stale `.testbed/.godot/editor` entries that still reference removed `res://assets/shaders/...` shader paths. Prefer the narrowest safe fix: update or clear only the specific stale editor-state entries needed so startup no longer attempts to open the removed shader path. Re-run lightweight `.testbed` validation and commit the repair.

**Folders Created/Deleted/Modified:**
- `.testbed/.godot/editor/`

**Files Created/Deleted/Modified:**
- `.testbed/.godot/editor/editor_layout.cfg`

**Status:** ✅ Complete

**Results:** Coder repaired `.testbed/.godot/editor/editor_layout.cfg` using the exact narrow repair set from Task 1: removed the stale `res://assets/shaders/` entry from `uncollapsed_paths`, updated `open_shaders` to `res://addons/aerobeat-ui-kit-community/assets/shaders/glass-shader.gdshader`, and updated `selected_shader` to that same addon-mounted path. Validation included lightweight headless editor startup plus headless import/startup. In the resulting output, Godot reopened the addon-mounted shader path and no `res://assets/shaders/...` load complaint appeared. Commit: `f6b5b1e` (`Fix stale testbed editor shader path state`). Because `.testbed/.godot/editor/editor_layout.cfg` is gitignored, the coder had to force-add it for the commit.

---

### Task 3: Audit editor-state repair truth

**Bead ID:** `aerobeat-ui-kit-community-1wb`  
**SubAgent:** `primary` (for `auditor`)  
**Role:** `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** Claim the assigned bead on start. Independently audit the editor-state repair. Confirm there are no remaining stale `.testbed/.godot/editor` references that cause startup to load the removed `res://assets/shaders/...` shader path, and verify lightweight `.testbed` startup/import behavior after the repair.

**Folders Created/Deleted/Modified:**
- `None expected`

**Files Created/Deleted/Modified:**
- `Audit evidence only if needed`

**Status:** ✅ Complete

**Results:** Audit passed. Auditor confirmed `.testbed/.godot/editor/editor_layout.cfg` no longer contains stale `res://assets/shaders/...` references for this issue, the repair stayed narrowly scoped to that single file, and lightweight headless editor startup/import no longer emits the removed-shader load complaint. Verbose startup truth showed the editor reopening `res://addons/aerobeat-ui-kit-community/assets/shaders/glass-shader.gdshader` instead of the removed path. Auditor closed `aerobeat-ui-kit-community-1wb` as passed.

---

## Final Results

**Status:** ✅ Complete

**What We Built:** Repaired the stale `.testbed/.godot/editor/editor_layout.cfg` shader restore state so the testbed editor now reopens the addon-mounted shader path instead of the removed `res://assets/shaders/...` path.

**Reference Check:** `REF-01` through `REF-04` satisfied. Final truth is that the tracked editor layout state now aligns with the addon-mounted shader contract already used by the live `.testbed` source files.

**Commits:**
- `f6b5b1e` - Fix stale testbed editor shader path state

**Lessons Learned:** The remaining warning after the addon-path refactor was pure editor-state drift, not a live source bug. A narrow one-file repair was enough; broader cache churn was unnecessary.

---

*Completed on 2026-06-03*