# AeroBeat UI Kit Community

**Date:** 2026-06-03  
**Status:** Complete  
**Last Updated:** 2026-06-03 21:13 EDT  
**Blocked Reason:** None  
**Agent:** `cookie`

---

## Goal

Prune the deprecated 3D object glass shader path from `aerobeat-ui-kit-community`, keep only the 2D frosted glass shader and the hybrid 3D shader, clean up stale `.testbed` scenes/scripts/docs, and re-hook the remaining testbed surfaces so the repo still boots and demonstrates the supported UI shader paths cleanly.

---

## Overview

Derrick has already moved the shader assets from `/.testbed/assets/` into the repo-root `/assets/` folder. This slice finishes that refactor by removing the legacy 3D object glass shader path and then cleaning up the `.testbed` test harness so it only reflects the supported UI-facing shader surfaces.

The risky part is not the deletions themselves; it is the follow-through. Scenes, attached scripts, preload paths, docs, and any shared debug helpers may still point at the removed shader or the removed test scene. The execution pass should therefore first inventory references, then remove the obsolete 3D-object path, then repair the surviving 2D + hybrid testbed wiring, and finally verify the `.testbed` still imports and the intended scenes/scripts are internally consistent.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Root shader inventory after Derrick's asset move | `assets/shaders/` |
| `REF-02` | Current testbed scene inventory | `.testbed/scenes/` |
| `REF-03` | Current testbed script inventory | `.testbed/scripts/` |
| `REF-04` | Current testbed doc inventory | `.testbed/docs/` |
| `REF-05` | Active usage/readme doc that may need truth cleanup | `.testbed/docs/glass-shader-usage.md` |

Use these IDs in implementation notes and audit results so we can prove the remaining supported shader surfaces are exactly the intended ones.

---

## Tasks

### Task 1: Inventory stale 3D-object glass references and define the exact deletion set

**Bead ID:** `aerobeat-ui-kit-community-259`  
**SubAgent:** `primary` (for `research`)  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`  
**Prompt:** Inspect `aerobeat-ui-kit-community` for every reference to the deprecated 3D object glass shader path. Claim the assigned bead on start. Produce a precise inventory covering shader files, `.testbed/scenes`, `.testbed/scripts`, docs, and any preload/resource references that will break after deletion. Do not edit yet; identify the exact files that must be removed versus rewired so only the 2D frosted shader and the hybrid 3D shader remain supported.

**Folders Created/Deleted/Modified:**
- `None expected`

**Files Created/Deleted/Modified:**
- `Inventory only; no file edits performed`

**Status:** ✅ Complete

**Results:** Inventory completed. Confirmed safe deletion set is `assets/shaders/glass-panel-3d.gdshader` + UID, `.testbed/scenes/glass-shader-3d-test.tscn`, and `.testbed/scripts/glass_shader_3d_test.gd` + UID. Confirmed `assets/shaders/glass-panel-ui-overlay-3d.gdshader` is part of the supported hybrid path and must stay. Confirmed `.testbed/scripts/glass_3d_debug_backdrop.gd` is shared by `.testbed/scenes/glass-shader-gui-3d-test.tscn`, so it must not be deleted unless explicitly renamed/rewired. Primary required truth cleanup file is `.testbed/docs/glass-shader-usage.md`, which still documents the deprecated native 3D path. Research also found only generated/stale `.testbed/.godot/editor/*` references beyond that. Validated against `REF-01` through `REF-05`.

---

### Task 2: Remove deprecated shader/scene/script/doc surfaces and re-hook surviving paths

**Bead ID:** `aerobeat-ui-kit-community-0xk`  
**SubAgent:** `primary` (for `coder`)  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`  
**Prompt:** Using the approved inventory, claim the assigned bead on start and implement the prune/refactor in `aerobeat-ui-kit-community`. Remove the deprecated 3D object glass shader artifacts, delete the obsolete `.testbed/scenes/glass-shader-3d-test.tscn` path, remove the now-unused `.testbed/scripts/glass_shader_3d_test.gd` path, prune stale/outdated `.testbed/docs/glass-shader-usage.md` references to the removed native-3D path, and re-hook surviving scenes/scripts/resource paths so the testbed truthfully represents only the supported 2D frosted and hybrid 3D shader flows. Keep `assets/shaders/glass-panel-ui-overlay-3d.gdshader` because it is part of the supported hybrid path. Keep `.testbed/scripts/glass_3d_debug_backdrop.gd` unless you deliberately rename/rewire it, because it is still used by the hybrid scene. Run relevant repo-local validation and prepare commit-ready results.

**Folders Created/Deleted/Modified:**
- `assets/shaders/`
- `.testbed/scenes/`
- `.testbed/scripts/`
- `.testbed/docs/`
- `.testbed/assets/`

**Files Created/Deleted/Modified:**
- `assets/shaders/glass-panel-3d.gdshader`
- `assets/shaders/glass-panel-3d.gdshader.uid`
- `.testbed/scenes/glass-shader-3d-test.tscn`
- `.testbed/scripts/glass_shader_3d_test.gd`
- `.testbed/scripts/glass_shader_3d_test.gd.uid`
- `.testbed/docs/glass-shader-usage.md`
- `.testbed/assets/shaders` (symlink to `../../assets/shaders`)
- `Any surviving scene/script/doc files that need path or truth updates`

**Status:** ✅ Complete

**Results:** Coder removed the deprecated native-3D shader proof path: `assets/shaders/glass-panel-3d.gdshader` + UID, `.testbed/scenes/glass-shader-3d-test.tscn`, and `.testbed/scripts/glass_shader_3d_test.gd` + UID. Kept the supported hybrid artifacts intact, including `assets/shaders/glass-panel-hybrid-3d.gdshader`, `assets/shaders/glass-panel-ui-overlay-3d.gdshader`, and `.testbed/scripts/glass_3d_debug_backdrop.gd`. Rewrote `.testbed/docs/glass-shader-usage.md` so it now documents only the supported 2D frosted and hybrid 3D flows. Re-hooked `.testbed` shader resolution by adding `.testbed/assets/shaders -> ../../assets/shaders` so existing `res://assets/shaders/...` references still resolve after shader ownership moved to repo root. Validation passed with headless Godot import after the symlink re-hook. Commit: `48f36ac` (`Prune deprecated glass shader proof path`). Remaining noted warning: duplicate UID warnings between `.testbed` asset paths and packaged addon shader copies; coder intentionally did not widen scope into that cleanup.

---

### Task 3: Verify `.testbed` truth after the prune

**Bead ID:** `aerobeat-ui-kit-community-gmh`  
**SubAgent:** `primary` (for `auditor`)  
**Role:** `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`  
**Prompt:** Claim the assigned bead on start and independently audit the completed prune in `aerobeat-ui-kit-community`. Confirm the deprecated 3D object glass shader path is fully gone, the remaining supported shader set is exactly the 2D frosted glass shader plus the hybrid 3D shader, and the surviving `.testbed` scenes/scripts/docs are internally consistent with those two supported paths. Validate import/boot behavior or other repo-local truth checks as available, then either close the bead with a reason or report the exact remaining gap.

**Folders Created/Deleted/Modified:**
- `None expected`

**Files Created/Deleted/Modified:**
- `Audit evidence only if needed`

**Status:** ✅ Complete

**Results:** Audit passed against commit `48f36ac`. Auditor confirmed the deprecated native-3D proof path is fully removed, the remaining shader set in `assets/shaders/` is exactly the supported 2D frosted shader plus hybrid body and hybrid overlay shaders (with matching `.uid` files), and `.testbed/docs/glass-shader-usage.md` now documents only the supported 2D + hybrid flows. Auditor also confirmed `.testbed/assets/shaders -> ../../assets/shaders` is present and correct, surviving `.testbed` references resolve through that re-hook, and headless Godot import succeeds with exit status `0`. Material residual risk recorded: duplicate UID warnings still exist between `res://assets/shaders/*` and packaged addon copies under `res://addons/aerobeat-ui-kit-community/assets/shaders/*`, but that does not block this cleanup slice. Auditor closed both `aerobeat-ui-kit-community-0xk` and `aerobeat-ui-kit-community-gmh` as complete.

---

## Final Results

**Status:** ✅ Complete

**What We Built:** Removed the deprecated native-3D glass shader proof path from `aerobeat-ui-kit-community`, kept only the supported 2D frosted and hybrid 3D shader stack, rewrote the testbed usage doc to match that truth, and re-hooked `.testbed` shader resolution back to the repo-root `assets/shaders` ownership via `.testbed/assets/shaders -> ../../assets/shaders`.

**Reference Check:** `REF-01` through `REF-05` satisfied. Final truth is that the supported shader set is exactly `glass-shader.gdshader`, `glass-panel-hybrid-3d.gdshader`, and `glass-panel-ui-overlay-3d.gdshader`, while the removed native-3D proof files no longer exist outside generated editor state.

**Commits:**
- `48f36ac` - Prune deprecated glass shader proof path
- `18d65a9` - Finalize glass shader prune execution plan

**Lessons Learned:** The functional cleanup was simple, but the important seam was path ownership: once shaders moved to repo root, `.testbed` still needed an explicit shader-path bridge to preserve existing `res://assets/shaders/...` references without reintroducing duplicate source ownership. A remaining follow-up, if needed later, is cleaning duplicate UID warnings caused by packaged addon shader copies.

---

*Completed on 2026-06-03*