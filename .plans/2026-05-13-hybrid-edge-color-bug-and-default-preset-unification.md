# AeroBeat UI Kit Community — Hybrid Edge-Color Bug + Default Preset Unification

**Date:** 2026-05-13  
**Status:** Complete  
**Agent:** Byte 🐈‍⬛

---

## Goal

Fix the hybrid 3D GUI shader bug where nonzero `edge_color` intensity produces an unwanted white rectangular line across the center panel area, and unify both the 2D and hybrid test scenes so they load startup values from explicit default preset JSON files through the same preset-loading path.

---

## Overview

Derrick found a new hybrid-specific rendering bug: when `edge_color` has visible intensity, the hybrid 3D scene can show an obvious white rounded-rectangle line across the interior body region instead of restricting that energy to the intended shell/edge treatment. The screenshot suggests a body/overlay ownership leak or an incorrect use of the shell-aligned shape signal inside the hybrid body pass. This should be treated as a correctness issue, not tuning.

Derrick also wants the 2D and hybrid test scenes to stop using two different default-loading models. Right now the 2D side effectively boots from the live source scene/material state, while the hybrid side explicitly applies controller-array defaults at startup. That split is awkward now that JSON import/export exists. The cleaner direction is to define one explicit default preset JSON file per scene/shader flavor and have both scenes load startup values through the same JSON preset-loading path, so experimentation, reset/default behavior, and startup behavior all share one mechanism.

This slice should therefore do two tightly related things: (1) diagnose and fix the hybrid `edge_color` interior white-rectangle bug without reopening solved silhouette/overlay ownership seams, and (2) unify default loading so both scenes read their startup values from explicit default preset JSON files using the existing preset loader machinery.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | 2D shader test scene | `.testbed/scenes/glass-shader-test.tscn` |
| `REF-02` | Hybrid shader test scene | `.testbed/scenes/glass-shader-gui-3d-test.tscn` |
| `REF-03` | 2D test controller script | `.testbed/scripts/glass_shader_test.gd` |
| `REF-04` | Hybrid test controller script | `.testbed/scripts/glass_shader_gui_3d_test.gd` |
| `REF-05` | Shared panel/source script | `.testbed/scripts/glass_shader_panel_source.gd` |
| `REF-06` | Preset IO helper | `.testbed/scripts/glass_shader_preset_io.gd` |
| `REF-07` | Hybrid body shader | `.testbed/assets/shaders/glass-panel-hybrid-3d.gdshader` |
| `REF-08` | Hybrid overlay shader | `.testbed/assets/shaders/glass-panel-ui-overlay-3d.gdshader` |
| `REF-09` | Latest JSON preset workflow plan/results | `.plans/2026-05-13-shader-preset-json-import-export.md` |
| `REF-10` | Screenshot of hybrid `edge_color` interior white-rectangle bug | `/home/derrick/.openclaw/workspace/.temp/nerve-uploads/2026/05/13/image-70cff4d9.png` |

---

## Tasks

### Task 1: Research the hybrid `edge_color` bug and the cleanest default-preset unification path

**Bead ID:** `aerobeat-ui-kit-community-90s`  
**SubAgent:** `primary` (for `research` workflow role)  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`, `REF-06`, `REF-07`, `REF-08`, `REF-09`, `REF-10`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, investigate why nonzero `edge_color` intensity in the hybrid 3D GUI scene produces a white rounded-rectangle line through the center/body region. Identify the cleanest fix that preserves current silhouette, overlay, rim, and inner-line ownership. Also determine the cleanest way to unify startup default loading for both the 2D and hybrid scenes so each loads from an explicit default preset JSON file using the existing preset IO path instead of maintaining separate startup-default systems.

**Folders Created/Deleted/Modified:**
- `.plans/` (notes/results only if needed)
- `.temp/` if needed

**Files Created/Deleted/Modified:**
- `.plans/2026-05-13-hybrid-edge-color-bug-and-default-preset-unification.md`
- `.temp/2026-05-13-hybrid-edge-color-and-default-preset-research.md`

**Status:** ✅ Complete

**Results:** Research complete. The most credible cause of the white interior rounded/rectangular line is not a primary SDF leak inside `REF-07`, but a controller-level ownership leak in `REF-04`: when the hybrid scene updates `edge_color`, `_sync_hybrid_shell_parameter()` also forwards that value as `edge_highlight` into the shared authored source scene. `REF-05` then applies that value to the authored `PreviewFrame` border (`_frame_style.border_color` plus alpha), so increasing hybrid-body `edge_color` also brightens the overlay-owned frame line rendered inside `glass_rect`. In the hybrid composition that authored frame sits inset inside the broader frosted body, which matches `REF-10`: a bright white rounded rectangle appears through the interior body region.

The smallest truthful fix is therefore to stop syncing hybrid `edge_color` into the authored shell/frame highlight path. Recommended implementation target: remove or gate the `"edge_color" -> "edge_highlight"` branch in `REF-04` (`glass_shader_gui_3d_test.gd::_sync_hybrid_shell_parameter()`), while keeping only shell-aligned sync inputs such as `corner_radius`, `edge_width`, and optionally `tint`. That preserves the intended ownership split already established in the current architecture: the authored mask keeps silhouette/discard ownership, the authored overlay keeps the sharp rim/inner-line/UI clarity, and the hybrid body shader keeps frost/refraction/fresnel energy. Optional cleanup: remove the now-misleading legacy alias `"edge_highlight": {"target": "edge_color"}` in `REF-04` if nothing still relies on it, and add a clarifying comment in `REF-05` that authored frame highlight is overlay-owned rather than body-edge-owned.

For startup-default unification, the cleanest architecture is to make explicit repo-tracked JSON files under `res://` the single authoritative startup source for both scenes, while leaving `user://shader-presets/{2d,hybrid}/` for ad-hoc user save/load. Recommended bundled default locations: `res://presets/glass/2d/default.json` and `res://presets/glass/hybrid/default.json` (or an equivalent repo-tracked `.testbed` subfolder, as long as both are `res://` assets). Both `REF-03` and `REF-04` should load startup defaults through the same path after materials/viewports are mounted and before the deferred control sync: instantiate scene/material state, build controls/dialogs, call the shared preset loader in `REF-06` (`load_and_normalize_preset(...)` plus `apply_parameters(...)`), then `call_deferred("_sync_controls_from_panel")`. Scene-embedded shader values and controller-array `default` entries should remain only as range/fallback metadata, not as competing startup-default systems. Concise research notes were written to `.temp/2026-05-13-hybrid-edge-color-and-default-preset-research.md`. 

---

### Task 2: Implement the hybrid `edge_color` bug fix and default-preset unification

**Bead ID:** `aerobeat-ui-kit-community-tka`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`, `REF-06`, `REF-07`, `REF-08`, `REF-09`, `REF-10`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, fix the hybrid `edge_color` interior white-rectangle bug and unify default loading so both the 2D and hybrid test scenes load startup values from explicit default preset JSON files through the shared preset-loading path. Preserve existing JSON import/export UX, keep the solved silhouette/overlay ownership seams intact, and avoid introducing a third defaulting system.

**Folders Created/Deleted/Modified:**
- `.testbed/scripts/`
- `.testbed/assets/shaders/` if needed
- `.testbed/` preset/default data path(s)
- `.plans/`

**Files Created/Deleted/Modified:**
- `.testbed/scripts/glass_shader_test.gd`
- `.testbed/scripts/glass_shader_gui_3d_test.gd`
- `.testbed/scripts/glass_shader_panel_source.gd` if needed
- `.testbed/scripts/glass_shader_preset_io.gd` if needed
- `.testbed/assets/shaders/glass-panel-hybrid-3d.gdshader` and/or `.testbed/assets/shaders/glass-panel-ui-overlay-3d.gdshader` if needed
- default preset JSON files for 2D and hybrid startup values

**Status:** ✅ Complete

**Results:** Implemented both requested changes without reopening the solved silhouette / overlay / rim / inner-line ownership split. For the hybrid white interior rounded-rectangle bug, the fix stayed at the controller boundary instead of the shaders: `glass_shader_gui_3d_test.gd` no longer forwards hybrid `edge_color` into the authored source scene’s `edge_highlight`, so increasing hybrid body edge energy no longer brightens the overlay-owned `PreviewFrame` border inside the panel body. `glass_shader_panel_source.gd` now also documents that the authored frame highlight is overlay-owned and should not mirror hybrid body `edge_color`.

Startup default loading is now unified through the shared preset path in both scene controllers. Repo-tracked bundled defaults now live at `res://presets/glass/2d/default.json` and `res://presets/glass/hybrid/default.json` (repo paths `.testbed/presets/glass/2d/default.json` and `.testbed/presets/glass/hybrid/default.json`). Both `glass_shader_test.gd` and `glass_shader_gui_3d_test.gd` now build their scene/material state, build controls/dialogs, then call the shared preset helper in `glass_shader_preset_io.gd` to load-and-apply the bundled default preset before the deferred control sync. Manual JSON load now uses that same shared `load_and_apply_preset(...)` path as startup, so there is one preset-loading mechanism instead of separate startup-vs-manual paths. The existing `user://shader-presets/2d` and `user://shader-presets/hybrid` save/load UX remains intact.

Repo-local validation passed with `godot --headless --path .testbed --import`, `godot --headless --path .testbed --script res://../.temp/validate_shader_preset_json_io_2026_05_13.gd`, and `godot --headless --path .testbed --script res://../.temp/validate_hybrid_edge_color_and_default_presets_2026_05_13.gd`. The last validation script specifically verified (1) both scenes boot from the bundled default preset values and (2) changing hybrid `edge_color` no longer restyles the authored preview-frame border, while `edge_width` still syncs shell width as intended. Implementation commit hash: `2a09100` (`Fix hybrid edge color sync and unify default presets`). Push status: pushed to `origin/main`. 

---

### Task 3: QA the edge-color fix and the unified default-loading flow

**Bead ID:** `Skipped by user`  
**SubAgent:** `primary` (for `qa` workflow role)  
**Role:** `qa`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-06`, `REF-07`, `REF-08`, `REF-10`  
**Prompt:** Skipped for this slice at Derrick’s request; Derrick will review the result in person instead of running the normal QA lane.

**Folders Created/Deleted/Modified:**
- none

**Files Created/Deleted/Modified:**
- none

**Status:** ⏭️ Skipped by user

**Results:** QA intentionally skipped by Derrick for this slice so he can manually review the result in person.

---

### Task 4: Audit the bug fix and the unified default-loading architecture

**Bead ID:** `Skipped by user`  
**SubAgent:** `primary` (for `auditor` workflow role)  
**Role:** `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`, `REF-06`, `REF-07`, `REF-08`, `REF-09`, `REF-10`  
**Prompt:** Skipped for this slice at Derrick’s request; Derrick will review the result in person instead of running the normal audit lane.

**Folders Created/Deleted/Modified:**
- none

**Files Created/Deleted/Modified:**
- none

**Status:** ⏭️ Skipped by user

**Results:** Audit intentionally skipped by Derrick for this slice so he can manually review the result in person.

---

## Final Results

**Status:** ✅ Complete

**What We Built:** Fixed the hybrid `edge_color` ownership leak that was brightening the authored interior rounded rectangle, and unified both the 2D and hybrid startup shader defaults so they now load from explicit bundled preset JSON files through the shared preset loader before syncing controls.

**Reference Check:** `REF-03` / `REF-04` now use the same preset-loading path for startup and manual preset load. `REF-05` still owns the authored shell/frame presentation, but it no longer receives hybrid `edge_color` as overlay highlight input. `REF-06` now exposes the shared `load_and_apply_preset(...)` helper used by both scenes. `REF-10`’s reported symptom is addressed by removing the controller-level `edge_color` -> `edge_highlight` leak while preserving shell sync for `corner_radius`, `edge_width`, and `tint`.

**Commits:**
- `2a09100` - Fix hybrid edge color sync and unify default presets

**Lessons Learned:** The cleanest fix was to treat the white interior frame as an ownership bug, not a shader-tuning bug. Once startup defaults and manual preset loads share the same helper path, bundled `res://` defaults can become the authoritative startup source while the existing `user://` preset workflow stays unchanged.

---

*Drafted on 2026-05-13*
