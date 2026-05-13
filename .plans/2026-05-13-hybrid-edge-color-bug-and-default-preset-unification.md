# AeroBeat UI Kit Community — Hybrid Edge-Color Bug + Default Preset Unification

**Date:** 2026-05-13  
**Status:** Complete  
**Agent:** Byte 🐈‍⬛

---

## Goal

Fix the hybrid 3D GUI shader bug where nonzero `edge_color` intensity produces an unwanted white rectangular line across the center panel area, and unify both the 2D and hybrid test scenes so they load startup values from explicit default preset JSON files through the same preset-loading path.

---

## Overview

Derrick found a new hybrid-specific rendering bug: when `edge_color` has visible intensity, the hybrid 3D scene can show an obvious white rounded-rectangle line across the interior body region instead of restricting that energy to the intended shell/edge treatment. An initial implementation attempt assumed this was primarily a controller/ownership leak, but Derrick’s follow-up manual review confirmed the bug is still present when intensity is above zero. The latest manual tests sharpen the diagnosis further: even with `PanelUiOverlay` disabled, the interior rounded-rectangle artifact remains visible, and it correlates strongly with **`edge_width > 0`** and low **`blur`** values. That means the remaining bug is not in the overlay path at all; it is most likely coming from the hybrid body shader’s own edge band / edge-distance logic drawing an internal ring. This should be treated as a correctness issue, not tuning.

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

**Bead ID:** `aerobeat-ui-kit-community-90s` → follow-up `aerobeat-ui-kit-community-5d6` → follow-up `aerobeat-ui-kit-community-r1a` → follow-up `aerobeat-ui-kit-community-prh`  
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

**Bead ID:** `aerobeat-ui-kit-community-tka` → follow-up `aerobeat-ui-kit-community-mwf` → follow-up `aerobeat-ui-kit-community-pzq` → follow-up `aerobeat-ui-kit-community-445`  
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

**Results:** Follow-up implementation completed in two tight passes without reopening the solved silhouette / overlay / rim / inner-line ownership split. The earlier controller cleanup that stopped forwarding hybrid `edge_color` into the authored source scene’s `edge_highlight` remains in place, and the first follow-up bug fix landed in `glass_shader_panel_source.gd`: when the source scene is in `PRESENTATION_MODE_HYBRID_WORLD_SPACE`, the overlay-owned `PreviewFrame` now keeps its border visible while forcing its interior contribution off (`bg_color.a = 0`, `shadow_size = 0`, `shadow_color.a = 0`). That removed the accidental interior rounded-rectangle fill/shadow pass from the front overlay while preserving the crisp overlay rim and inner line.

Derrick’s next manual review then exposed a remaining darker center-slab artifact that was body-shader-owned rather than overlay-owned. The second follow-up fix therefore stayed entirely inside `glass-panel-hybrid-3d.gdshader`: the hybrid body shader still defines `mid_body`, but its direct participation was removed from the backdrop compression and body/tint/frost compositing path so the interior now reads from the continuous `interior` ramp instead of a second inset body band. Specifically, `mid_body` was removed from `subdued_background`, the secondary `compressed_background` mix, `face_veil`, `body_mix`, `tint_weighted_body`, `frost_core`, and the final `glass_color` frost mix, while the existing blur/refraction structure and rim ownership were otherwise preserved.

The manual preset dialogs now default into the repo-local preset tree instead of `user://` app data. `glass_shader_test.gd` now points its Export/Load dialogs at `res://presets/glass/2d`, and `glass_shader_gui_3d_test.gd` points at `res://presets/glass/hybrid`, both globalized to filesystem paths so the native dialogs open inside the tracked `.testbed/presets/glass/...` folders. Bundled startup defaults remain unchanged under `res://presets/glass/2d/default.json` and `res://presets/glass/hybrid/default.json`, and both scenes still use the shared `glass_shader_preset_io.gd` loader for startup + manual JSON import.

Derrick’s latest isolation pass then narrowed the remaining artifact to the hybrid BODY shader’s own `ui_underlay` path: the authored `PreviewFrame` border alpha inside `ui_texture` was still being re-embedded back into the frosted body, which explains why the ring survived with `PanelUiOverlay` disabled, scaled with `edge_width`, and became obvious at very low `blur`. The next follow-up therefore stayed shader-only in `glass-panel-hybrid-3d.gdshader`: `ui_underlay` is now multiplied by an interior-safe SDF mask built from `-sdf_px`, `edge_width_px`, and short-side-scaled padding/feather distances. Concretely, the body shader now suppresses underlay contribution across the shell border / inner-line zone (`shell_exclusion_px`, `shell_feather_px`, `ui_interior_mask`) while still allowing deeper interior UI embedding to survive farther inside the glass.

Repo-local validation for this slice passed with `godot --headless --path .testbed --import` and `godot --headless --path .testbed --script res://../.temp/validate_hybrid_edge_color_and_default_presets_2026_05_13.gd`. The hybrid validator still verifies the repo-local preset directories and overlay ownership split, and the new shader-only follow-up compiled cleanly through the headless import pass. A broader temp validator, `godot --headless --path .testbed --script res://../.temp/validate_task3_hybrid_defaults_2026_05_13.gd`, remains stale after upstream commit `e5a91d5` changed tracked hybrid default preset values (`tint_strength` now differs from the script’s hard-coded expectation), so it is not a trustworthy gate for this ring-focused shader-only slice. Follow-up implementation commits now include `bdfadee` (`Fix hybrid overlay fill and preset dialog defaults`), `80f16e9` (`Reduce hybrid center-slab body band`), and `Pending` for bead `aerobeat-ui-kit-community-445` (`Mask hybrid ui_underlay away from shell border`). Push status: pending at time of writing; see final results.

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

**What We Built:** Finished the hybrid interior-cleanup sequence in three truthful layers: first by disabling the overlay `PreviewFrame` interior fill/shadow in hybrid world mode while keeping the overlay border + inner line visible, then by removing the hybrid body shader’s extra `mid_body` weighting from the backdrop compression and body/tint/frost color path, and finally by masking the BODY shader’s `ui_underlay` away from the shell border / inner-line zone so the authored `ui_texture` border alpha no longer gets re-embedded into the frosted glass. The repo-local Export/Load dialog defaults under `.testbed/presets/glass/...` remain in place.

**Reference Check:** `REF-05` still enforces the intended hybrid ownership split directly in the authored source scene: overlay rim/inner-line stay on, overlay interior fill/shadow stay off, and the world shader continues to own the body fill/frost. `REF-07` now does two targeted cleanup jobs without disturbing the broader fuzzy-glass structure: it favors the continuous `interior` ramp over the extra `mid_body` band in the color/compression stack, and it gates `ui_underlay` with an interior-safe SDF mask so shell-border alpha from `ui_texture` no longer darkens/tints the body near the rim. `REF-03` / `REF-04` still use the shared preset-loading path for startup and manual preset load, and their native dialogs still default to repo-local preset directories instead of `user://`. `REF-06` continues to own the shared JSON import/export logic. `REF-10`’s earlier symptom was addressed by the controller/overlay fixes, and Derrick’s later low-blur / overlay-disabled isolation is addressed directly in `REF-07` by the new underlay mask.

**Commits:**
- `2a09100` - Fix hybrid edge color sync and unify default presets
- `bdfadee` - Fix hybrid overlay fill and preset dialog defaults
- `80f16e9` - Reduce hybrid center-slab body band
- `Pending` - Mask hybrid ui_underlay away from shell border
- `Pending` - Update plan for hybrid internal-ring follow-up

**Lessons Learned:** The controller-level `edge_color` forwarding cleanup was necessary but not sufficient, the overlay fill/shadow shutdown was still not the whole story, and even the center-slab trim did not fully explain a ring that survived with `PanelUiOverlay` disabled. The most precise remaining cause was the BODY shader re-embedding authored border alpha through `ui_underlay`; removing that ownership leak structurally is cleaner than chasing the symptom with preset tuning. Also, one repo-local temp validator is now stale relative to the latest default preset commit, so validation notes need to distinguish between slice-relevant gates and unrelated hard-coded expectation drift.

## Follow-up Research Addendum — center-slab artifact (post-manual review)

Derrick’s later manual review exposed one more artifact after the fuzzy-glass pass was improved: a darker inset center slab / secondary interior rounded-rectangle shape is still visible inside the hybrid panel. Re-checking the current repo state against that screenshot changes the most likely root cause.

The earlier overlay-remnant theory is no longer the strongest fit because `REF-05` already zeroes the authored `PreviewFrame` body contribution in hybrid world mode (`bg_color.a = 0.0`, `shadow_size = 0`, `shadow_color.a = 0.0`), and `REF-08` only renders existing `ui_texture` alpha rather than generating an extra interior slab. The remaining artifact is therefore most credibly body-shader-owned.

Most likely active source now: `REF-07` defines a second inset body region via `mid_body = smoothstep(0.16, 0.82, w) * (1.0 - smoothstep(0.78, 0.98, w))`, then reuses that band in the backdrop compression path and the body/tint/frost compositing stack (notably lines around the `subdued_background`, `compressed_background`, `body_mix`, `tint_weighted_body`, `frost_core`, and `glass_color` mixes). That stacked reuse can make the panel read as a separate darker slab instead of one continuous sheet of glass.

Smallest truthful fix for the remaining artifact: change only `REF-07` first. Remove or sharply reduce `mid_body` participation in the color/compression/body-mix path while keeping the existing blur/refraction/fuzzy-glass behavior, rim ownership, inner-line ownership, mask ownership, and preset flow intact. Prefer one continuous interior ramp (`interior`) plus the existing perimeter/edge terms over a second inset body band. If visual rebalance is still needed after that structural cleanup, use the hybrid default preset only as a follow-up trim pass, not as the primary fix.

Follow-up research notes were recorded in `.temp/2026-05-13-hybrid-center-slab-followup-research.md`.

## Follow-up Research Addendum — internal ring after PanelUiOverlay disable / low blur isolation

Derrick's next isolation pass sharpens the remaining symptom further:
- `PanelUiOverlay` disabled
- interior rounded-rectangle ring still present
- artifact appears when `edge_width > 0`
- artifact becomes very obvious when `blur` is very low / `0`

That changes the most credible root cause again. The remaining ring is now most likely **not** the separate front overlay mesh and **not primarily** the broad frost/compression stack (`mid_body`, `oblique_body`, `edge_proximity`, or `interior` mixes). The strongest code match is the hybrid BODY shader's own reuse of `ui_texture` alpha as an embedded underlay.

Relevant body-shader lines in `REF-07`:
- `ui_sample = texture(ui_texture, authored_uv)`
- `ui_alpha = clamp(ui_sample.a * ui_alpha_gain, 0.0, 1.0)`
- `ui_underlay = ui_alpha * ui_embed_strength`
- `glass_color = mix(glass_color, glass_color * (1.0 - ui_shadow) + tint.rgb * 0.025, ui_underlay)`

Relevant authored-shell lines in `REF-05`:
- `preview_frame.visible = _presentation_mode == PRESENTATION_MODE_2D or is_hybrid_world`
- `_sync_preview_shell()` still sets `PreviewFrame` border width from `_shell_edge_width`
- hybrid world mode only disables the frame fill/shadow; it intentionally keeps the border/inner line visible

That means `edge_width > 0` is currently doing **two** things at once:
1. widening the BODY shader's own SDF `edge` band, and
2. widening the authored `PreviewFrame` border inside `ui_texture`, which the BODY shader then re-embeds into the frosted glass via `ui_underlay` even when the separate `PanelUiOverlay` mesh is disabled.

This second path is the best explanation for the newly isolated symptom because it survives overlay-mesh disable, tracks `edge_width` directly, and becomes much easier to see as `blur` drops and the body stops hiding it behind heavier fuzz.

The direct SDF `edge` term in `REF-07` remains a plausible **secondary** contributor:
- `edge = 1.0 - smoothstep(0.0, edge_width_px, -sdf_px)`
- `glass_color = mix(glass_color, edge_color.rgb, edge * edge_color.a * 0.16)`

But that contribution is comparatively small, so it is less likely to be the main visible ring than the `ui_underlay` path under the current hybrid defaults.

### Recommended smallest truthful fix

Change only `REF-07` first.

Smallest truthful fix direction:
- keep the fuzzy glass / refraction / body behavior intact
- keep `REF-05` overlay ownership split intact
- keep `REF-08` untouched
- keep preset/default-loading work untouched
- stop the BODY shader from re-embedding shell-border alpha from `ui_texture`

Most practical body-shader-only fix:
- gate or suppress `ui_underlay` near the shell border using an interior-safe SDF mask so border/inner-line alpha remains overlay-owned only
- if a faint ring still survives after that, then do a tiny second-pass trim on the BODY shader's direct `edge` mix/emission term

What should remain untouched unless testing disproves this diagnosis:
- `REF-05` hybrid-world overlay fill/shadow shutdown
- `REF-08` front overlay shader
- `.testbed/scripts/glass_shader_gui_3d_test.gd`
- `.testbed/presets/glass/` default preset workflow

Follow-up research notes for this isolation pass were recorded in `.temp/2026-05-13-hybrid-internal-ring-followup-research.md`.

---

*Drafted on 2026-05-13*
