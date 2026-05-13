# AeroBeat UI Kit Community — Hybrid Edge-Color Bug + Default Preset Unification

**Date:** 2026-05-13  
**Status:** Complete  
**Agent:** Byte 🐈‍⬛

---

## Goal

Fix the hybrid 3D GUI shader bug where nonzero `edge_color` intensity produces an unwanted white rectangular line across the center panel area, and unify both the 2D and hybrid test scenes so they load startup values from explicit default preset JSON files through the same preset-loading path.

---

## Overview

Derrick found a new hybrid-specific rendering bug: when `edge_color` has visible intensity, the hybrid 3D scene can show an obvious white rounded-rectangle line across the interior body region instead of restricting that energy to the intended shell/edge treatment. An initial implementation attempt assumed this was primarily a controller/ownership leak, but Derrick’s follow-up manual review confirmed the bug is still present when intensity is above zero. That means the problem is not fully solved yet and likely still involves active shader/compositing behavior in addition to or instead of controller forwarding. This should be treated as a correctness issue, not tuning.

Derrick also wants the 2D and hybrid test scenes to stop using two different default-loading models. Right now both scenes do load bundled default preset JSONs, but the manual load/export dialogs still default to `user://` app-data locations. Derrick wants the practical workflow centered in the repo itself so experimentation assets stay easy to inspect and commit. The cleaner direction is to define one explicit default preset JSON file per scene/shader flavor and have both scenes load startup values through the same JSON preset-loading path, while also making the manual export/load dialogs default into the repo-local `.testbed/presets` tree rather than local app-data storage.

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

**Bead ID:** `aerobeat-ui-kit-community-90s` → follow-up `aerobeat-ui-kit-community-5d6`  
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

**Results:** Research complete, with a follow-up correction after Derrick manually verified the bug was still present. The earlier `edge_color -> edge_highlight` forwarding leak was real, but it was not the whole story. The most credible remaining active cause is in `REF-05`, not the hybrid body SDF in `REF-07`: in `PRESENTATION_MODE_HYBRID_WORLD_SPACE`, the authored `PreviewFrame` still renders through the front UI overlay mesh, and that frame is not border-only. `_sync_preview_shell()` gives it a semi-opaque background fill (`_frame_style.bg_color`) plus shadow, so the overlay keeps drawing an inset rounded rectangle over the frosted body even after the direct `edge_color -> edge_highlight` sync was removed. That matches `REF-10` more closely than a pure edge-band leak in the body shader.

The smallest truthful fix is therefore to preserve overlay ownership of the sharp rim, crisp inner line, and UI clarity, but remove overlay ownership of any interior body fill in hybrid world mode. Recommended implementation target: branch in `REF-05` (`glass_shader_panel_source.gd`) so that when `_presentation_mode == PRESENTATION_MODE_HYBRID_WORLD_SPACE`, `preview_frame` remains visible for the border but its background alpha is forced to `0.0` and its shadow is disabled (`shadow_size = 0`, shadow alpha `0.0`). Keep `preview_inner_border` visible. That preserves the current ownership split cleanly: authored mask for silhouette/discard, hybrid shader for body fill/frost/refraction, overlay for rim/inner-line/UI only. The earlier `edge_color -> edge_highlight` fix in `REF-04` remains worth keeping as a secondary ownership cleanup, but it is not sufficient on its own.

For preset dialogs, the cleanest repo-local path handling is to keep bundled startup defaults under `res://presets/glass/2d/default.json` and `res://presets/glass/hybrid/default.json`, but stop defaulting manual Export/Load dialogs to `user://shader-presets/...`. Instead, point dialog defaults into the repo-local presets tree under `res://presets` (globalized to the filesystem), preferably scene-specific subfolders: `res://presets/glass/2d` for the 2D tester and `res://presets/glass/hybrid` for the hybrid tester. If Derrick prefers landing at the broader tree root first, both dialogs can instead open at `res://presets` while still prefilling the appropriate default filename. Concise follow-up notes were written to `.temp/2026-05-13-hybrid-edge-color-followup-research.md`. 

---

### Task 2: Implement the hybrid `edge_color` bug fix and default-preset unification

**Bead ID:** `aerobeat-ui-kit-community-tka` → follow-up `aerobeat-ui-kit-community-mwf`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`, `REF-06`, `REF-07`, `REF-08`, `REF-09`, `REF-10`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, fix the hybrid `edge_color` interior white-rectangle bug and unify default loading so both the 2D and hybrid test scenes load startup values from explicit default preset JSON files through the shared preset-loading path. Also update the manual Export/Load dialog defaults so they open into the repo-local `.testbed/presets` tree rather than `user://` app-data paths. Preserve existing JSON import/export UX, keep the solved silhouette/overlay ownership seams intact, and avoid introducing a third defaulting system.

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

**Results:** Follow-up implementation completed without reopening the solved silhouette / overlay / rim / inner-line ownership split. The earlier controller cleanup that stopped forwarding hybrid `edge_color` into the authored source scene’s `edge_highlight` remains in place, but the actual remaining bug fix landed in `glass_shader_panel_source.gd`: when the source scene is in `PRESENTATION_MODE_HYBRID_WORLD_SPACE`, the overlay-owned `PreviewFrame` now keeps its border visible while forcing its interior contribution off (`bg_color.a = 0`, `shadow_size = 0`, `shadow_color.a = 0`). That removes the accidental interior rounded-rectangle fill/shadow pass from the front overlay while preserving the crisp overlay rim and inner line.

The manual preset dialogs now default into the repo-local preset tree instead of `user://` app data. `glass_shader_test.gd` now points its Export/Load dialogs at `res://presets/glass/2d`, and `glass_shader_gui_3d_test.gd` points at `res://presets/glass/hybrid`, both globalized to filesystem paths so the native dialogs open inside the tracked `.testbed/presets/glass/...` folders. Bundled startup defaults remain unchanged under `res://presets/glass/2d/default.json` and `res://presets/glass/hybrid/default.json`, and both scenes still use the shared `glass_shader_preset_io.gd` loader for startup + manual JSON import.

Repo-local validation passed with `godot --headless --path .testbed --import`, `godot --headless --path .testbed --script res://../.temp/validate_shader_preset_json_io_2026_05_13.gd`, and `godot --headless --path .testbed --script res://../.temp/validate_hybrid_edge_color_and_default_presets_2026_05_13.gd`. The hybrid validation was expanded to verify (1) both scenes boot from the bundled default preset values, (2) both manual preset dialogs default to the repo-local preset directories, and (3) hybrid `PreviewFrame` fill/shadow stay disabled while `edge_color` changes no longer restyle the overlay border and `edge_width` still syncs shell width. Follow-up implementation commit hash: `bdfadee` (`Fix hybrid overlay fill and preset dialog defaults`). Push status: pushed to `origin/main`.

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

**What We Built:** Finished the remaining hybrid `edge_color` bug fix by disabling the overlay `PreviewFrame` interior fill/shadow in hybrid world mode while keeping the overlay border + inner line visible, and moved the manual Export/Load dialog defaults into the repo-local preset folders under `.testbed/presets/glass/...`.

**Reference Check:** `REF-05` now enforces the intended hybrid ownership split directly in the authored source scene: overlay rim/inner-line stay on, overlay interior fill/shadow stay off, and the world shader continues to own the body fill/frost. `REF-03` / `REF-04` still use the shared preset-loading path for startup and manual preset load, but their native dialogs now default to repo-local preset directories instead of `user://`. `REF-06` continues to own the shared JSON import/export logic. `REF-10`’s reported symptom is addressed by combining the earlier controller-level `edge_color` forwarding cleanup with the new hybrid overlay fill/shadow shutdown.

**Commits:**
- `2a09100` - Fix hybrid edge color sync and unify default presets
- `bdfadee` - Fix hybrid overlay fill and preset dialog defaults

**Lessons Learned:** The controller-level `edge_color` forwarding cleanup was necessary but not sufficient. The final bug was an ownership/compositing issue in the authored overlay frame: once hybrid mode stops that overlay from painting its own interior fill and shadow, the body shader can own the panel interior cleanly while the repo-local preset folders remain the practical place for manual import/export work.

---

*Drafted on 2026-05-13*
