# AeroBeat UI Kit Community

**Date:** 2026-06-03  
**Status:** Complete  
**Last Updated:** 2026-06-03 21:48 EDT  
**Blocked Reason:** None  
**Agent:** `cookie`

---

## Goal

Remove the mistaken `.testbed/assets/shaders` re-hook and refactor `.testbed` scripts/scenes/docs to load shaders from the repo-root addon mount path `res://addons/aerobeat-ui-kit-community/assets/shaders/...` instead.

---

## Overview

The current duplicate-UID warnings are coming from an incorrect path strategy in `.testbed`: the same shader files are visible both through a direct `.testbed/assets/shaders` bridge and through the intended self-addon mount at `.testbed/addons/aerobeat-ui-kit-community`.

Derrick confirmed the correct contract: `.testbed/assets/` should no longer contain a `shaders` folder at all. The canonical shader path inside `.testbed` should be the godotenv-provided addon mount, meaning live testbed references need to be updated from `res://assets/shaders/...` to `res://addons/aerobeat-ui-kit-community/assets/shaders/...`, then the stray `.testbed/assets/shaders` bridge should be removed and the project re-validated.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Correct `.testbed` addon manifest contract | `.testbed/addons.jsonc` |
| `REF-02` | Mistaken shader bridge to remove | `.testbed/assets/shaders` |
| `REF-03` | Supported shader docs and path references | `.testbed/docs/glass-shader-usage.md` |
| `REF-04` | Hybrid script path references | `.testbed/scripts/glass_shader_gui_3d_test.gd` |
| `REF-05` | Scene/material path references | `.testbed/ui/views/aero_ui_glass_panel_view.tscn` |

---

## Tasks

### Task 1: Inventory all `.testbed` references that still assume `res://assets/shaders/...`

**Bead ID:** `aerobeat-ui-kit-community-dqv`  
**SubAgent:** `primary` (for `research`)  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`  
**Prompt:** Claim the assigned bead on start. Inspect `aerobeat-ui-kit-community` and inventory every live `.testbed` reference that still assumes shader paths under `res://assets/shaders/...`. Confirm the exact set of files that must be edited to use `res://addons/aerobeat-ui-kit-community/assets/shaders/...`, and verify there are no additional hidden path assumptions beyond scripts/scenes/docs.

**Folders Created/Deleted/Modified:**
- `None expected`

**Files Created/Deleted/Modified:**
- `Inventory only; no edits`

**Status:** ✅ Complete

**Results:** Research confirmed the exact live source edit set is only `.testbed/scripts/glass_shader_gui_3d_test.gd`, `.testbed/ui/views/aero_ui_glass_panel_view.tscn`, and `.testbed/docs/glass-shader-usage.md`, all of which still assume `res://assets/shaders/...` or `assets/shaders/...`. It also confirmed the mistaken `.testbed/assets/shaders` symlink must be removed. No additional old-path assumptions were found in `.testbed/tests/**`, `.testbed/ui/presets/**`, `.testbed/ui/configs/**`, `.testbed/project.godot`, or `.testbed/addons.jsonc`. Historical plan files and generated `.godot` state were intentionally excluded from the live edit set.

---

### Task 2: Refactor `.testbed` shader references to the addon mount and remove the mistaken bridge

**Bead ID:** `aerobeat-ui-kit-community-15p`  
**SubAgent:** `primary` (for `coder`)  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`  
**Prompt:** Claim the assigned bead on start. Update `aerobeat-ui-kit-community` so `.testbed` loads supported shaders from `res://addons/aerobeat-ui-kit-community/assets/shaders/...` instead of `res://assets/shaders/...`. Edit every confirmed live script/scene/doc reference, remove the mistaken `.testbed/assets/shaders` bridge entirely, and run relevant repo-local validation to confirm the `.testbed` still imports and resolves the supported shaders correctly. Commit the implementation and report the hash.

**Folders Created/Deleted/Modified:**
- `.testbed/assets/`
- `.testbed/scripts/`
- `.testbed/ui/views/`
- `.testbed/docs/`

**Files Created/Deleted/Modified:**
- `.testbed/assets/shaders` (delete)
- `.testbed/scripts/glass_shader_gui_3d_test.gd`
- `.testbed/ui/views/aero_ui_glass_panel_view.tscn`
- `.testbed/docs/glass-shader-usage.md`

**Status:** ✅ Complete

**Results:** Coder removed the mistaken `.testbed/assets/shaders` symlink entirely and updated the confirmed live `.testbed` surfaces to the addon-mounted shader path `res://addons/aerobeat-ui-kit-community/assets/shaders/...` (and doc-relative `addons/aerobeat-ui-kit-community/assets/shaders/...`). Validation included a headless Godot import/startup pass against `.testbed`. The prior duplicate-UID warning associated with the extra `.testbed/assets/shaders` visibility path did not appear after symlink removal. One residual startup load failure for `res://assets/shaders/glass-shader.gdshader` was observed and is likely stale editor/layout state rather than a remaining live source reference. Commit: `e853e9c43827b18ad74fbc3301718eb4b706268d` (`Refactor testbed shader paths to addon mount`).

---

### Task 3: Audit addon-path truth and duplicate-UID cleanup result

**Bead ID:** `aerobeat-ui-kit-community-5gf`  
**SubAgent:** `primary` (for `auditor`)  
**Role:** `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`  
**Prompt:** Claim the assigned bead on start. Independently audit the addon-path refactor. Confirm `.testbed/assets/shaders` is gone, all live `.testbed` shader references now use `res://addons/aerobeat-ui-kit-community/assets/shaders/...`, the supported shaders still resolve/import, and the duplicate-UID warning caused by the extra `.testbed/assets/shaders` visibility path is eliminated or truthfully characterized if any residual warning remains.

**Folders Created/Deleted/Modified:**
- `None expected`

**Files Created/Deleted/Modified:**
- `Audit evidence only if needed`

**Status:** ✅ Complete

**Results:** Audit passed. Auditor confirmed `.testbed/assets/shaders` is gone, the live intended-scope `.testbed` sources now use the addon-mounted shader path, and no remaining live intended-scope references to `res://assets/shaders/...` remain once generated/editor noise is excluded. Headless import and quit both succeeded against `.testbed`. The prior duplicate-UID warning tied to the extra `.testbed/assets/shaders` visibility path did not reappear. Auditor also confirmed the remaining `res://assets/shaders/glass-shader.gdshader` complaint came only from stale editor layout state in `.testbed/.godot/editor/editor_layout.cfg`, not from live source. Auditor closed `aerobeat-ui-kit-community-5gf` as passed.

---

## Final Results

**Status:** ✅ Complete

**What We Built:** Removed the mistaken `.testbed/assets/shaders` bridge, rewired the live `.testbed` script/scene/doc surfaces to load shaders from `res://addons/aerobeat-ui-kit-community/assets/shaders/...`, and eliminated the duplicate-UID warning caused by the extra shader visibility path.

**Reference Check:** `REF-01` through `REF-05` satisfied. The final truthful state is that live `.testbed` shader consumers now rely on the self-addon mount rather than any direct `.testbed/assets/shaders` path.

**Commits:**
- `e853e9c43827b18ad74fbc3301718eb4b706268d` - Refactor testbed shader paths to addon mount

**Lessons Learned:** The right fix was path unification, not UID manipulation: once repo-owned shaders moved to root ownership, `.testbed` needed to consume them exclusively through the godotenv-provided addon mount. The residual stale shader complaint turned out to be editor-state drift, which was intentionally handled in a follow-up plan instead of being papered over here.

---

*Completed on 2026-06-03*