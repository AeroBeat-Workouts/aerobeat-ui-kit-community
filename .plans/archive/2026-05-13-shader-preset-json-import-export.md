# AeroBeat UI Kit Community — Shader Preset JSON Import/Export for 2D and Hybrid Test Scenes

**Date:** 2026-05-13  
**Status:** Stale  
**Agent:** Byte 🐈‍⬛

---

## Goal

Add import/export buttons to both the 2D and hybrid shader test scenes so the current shader key/value set can be saved to JSON and loaded back from JSON, then compare the current strong 2D body solution against the in-progress hybrid 3D body path to explain and, if possible, reduce the remaining frosted-interior parity gap.

---

## Overview

Derrick wants faster experimentation in both the 2D and hybrid shader test scenes. The practical feature request is straightforward: each test scene should expose a way to export the current shader parameters to JSON and load them back from JSON. The buttons should live in the existing left-hand control panel in both scenes, replacing the bottom explanatory paragraph area rather than adding a new floating UI region. That should make it much easier to preserve promising looks, move settings between runs, and compare 2D/hybrid tuning states without manually re-entering values.

There is also a deeper technical question attached to the request: why does the hybrid frosted interior body still feel fundamentally different from the 2D version even when the same general knobs exist? The likely answer is not “because 3D is magical,” but because the body portion of the hybrid path is not actually running the same compositing pipeline as the 2D card. The 2D version and the hybrid version sample, mask, blur, composite, and layer their sources differently, and the body in particular now deliberately owns a narrower responsibility than the 2D full-card shader. This should be verified against the actual scene/shader code before answering confidently.

Derrick also wants this plan to go one step further than explanation. If the coder can compare the current successful 2D body treatment against the current hybrid 3D body treatment and identify a concrete body-only path to close the remaining frosted-interior gap, that should be included here too. This should stay disciplined: no reopening the solved silhouette or overlay/rim/inner-line ownership seams, and no pretending subtle no-op tweaks are progress. But if there is a real body-only parity improvement available after comparing the two implementations directly, this is the right time to try it.

This slice should therefore do three things in order: first, inspect the current 2D and hybrid test-scene control plumbing to determine the cleanest way to add JSON import/export without destabilizing the shader playground UI; second, implement and verify the buttons; third, compare the 2D-vs-hybrid body paths concretely and either recommend or land the most credible body-only parity improvement based on the actual pipeline rather than hand-waving.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | 2D shader test scene | `.testbed/scenes/glass-shader-test.tscn` |
| `REF-02` | Hybrid shader test scene | `.testbed/scenes/glass-shader-gui-3d-test.tscn` |
| `REF-03` | 2D test controller script | `.testbed/scripts/glass_shader_test.gd` |
| `REF-04` | Hybrid test controller script | `.testbed/scripts/glass_shader_gui_3d_test.gd` |
| `REF-05` | 2D source/shared panel script | `.testbed/scripts/glass_shader_panel_source.gd` |
| `REF-06` | 2D shader | `.testbed/assets/shaders/glass-panel.gdshader` |
| `REF-07` | Hybrid body shader | `.testbed/assets/shaders/glass-panel-hybrid-3d.gdshader` |
| `REF-08` | Hybrid overlay shader | `.testbed/assets/shaders/glass-panel-ui-overlay-3d.gdshader` |
| `REF-09` | Derrick’s latest near-parity screenshot | `/home/derrick/.openclaw/workspace/.temp/nerve-uploads/2026/05/13/image-b113ef1e.png` |

---

## Tasks

### Task 1: Research the cleanest import/export integration points and the true 2D-vs-hybrid body gap

**Bead ID:** `aerobeat-ui-kit-community-053`  
**SubAgent:** `primary` (for `research` workflow role)  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`, `REF-06`, `REF-07`, `REF-08`, `REF-09`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, inspect the 2D and hybrid shader test scenes/scripts and determine the cleanest way to add buttons for exporting current shader key/values to JSON and loading them back from JSON. Also inspect the actual 2D and hybrid shader/compositing paths and explain why the hybrid frosted interior body still differs from the 2D body even when many controls look similar. Compare the current successful 2D body treatment directly against the current hybrid 3D body path and recommend concrete body-only strategies to close the remaining parity gap without reopening solved silhouette or overlay/rim/inner-line ownership. Be concrete about scene plumbing, file-dialog flow, parameter ownership, where the body logic genuinely diverges, and what improvement paths look credible versus likely no-op tuning.

**Folders Created/Deleted/Modified:**
- `.plans/` (results updated)
- `.temp/`

**Files Created/Deleted/Modified:**
- `.plans/2026-05-13-shader-preset-json-import-export.md`
- `.temp/aerobeat-ui-kit-community-053-research-notes.md`

**Status:** ✅ Complete

**Results:** Research completed. The real 2D body reference is `res://assets/shaders/glass-shader.gdshader` via `glass-shader-panel-source.tscn`, not `glass-panel.gdshader`. For JSON preset import/export, the cleanest path is to keep both scenes’ existing dynamic control-generation intact and add a shared left-rail preset-actions block driven by a new helper such as `res://scripts/glass_shader_preset_io.gd`, while leaving per-scene file-dialog ownership in `glass_shader_test.gd` and `glass_shader_gui_3d_test.gd`. The helper should serialize/deserialze typed preset dictionaries, convert `Color` values to/from JSON-safe objects, validate a `schema_version` plus `preset_kind`, and store UI-facing parameter names rather than internal hybrid alias names. Recommended storage: `user://shader-presets/{2d,hybrid}/`, using one save dialog plus one load dialog per scene root with `*.json` filters. Recommended schema envelope: `schema_version`, `preset_kind`, `source_scene`, `saved_at`, and a `parameters` object containing floats plus RGBA color objects.

On the body-frost question, the remaining gap is now genuinely a **body-composite** gap, not a silhouette/rim/inner-line ownership problem. The current architecture already correctly splits responsibilities: the authored mask owns silhouette/discard, the overlay shader owns the sharp white rim + crisp inner line + UI clarity, and the hybrid body shader owns frost/refraction/body depth only. That means the 3D body is no longer attempting to reproduce the full 2D card composite by itself. The 2D reference gets its strong look from the combination of `GlassFill` + authored `PreviewFrame` + authored `PreviewInnerBorder` + foreground content, while the hybrid body intentionally stops short so it does not steal shell/detail ownership back from the overlay. Even where knobs look similar, the visible result differs because the hybrid body samples the real 3D world through `screen_texture` with angle-aware terms (`VIEW`, `NORMAL`, `ndotv`, `angle_rim`, fresnel, world-rim refraction), whereas the 2D shader samples a controlled screen-space backdrop and produces a flatter, more stable plate.

The clearest technical limiter is still backdrop compression: the hybrid body is better than earlier passes, but it still preserves more real-world contrast/geometry in the interior than the 2D card, especially at angle, so it reads a bit greyer/flatter rather than creamy/frosted. The most credible body-only next steps are: (1) push `subdued_background` / `neutral_background` / `compressed_background` harder before tint is reapplied, so the interior loses more high-frequency world structure; (2) deepen the center-to-mid-body frost weighting rather than relying on stronger `face_veil_strength`; (3) if angle-aware behavior is kept, feed it into interior backdrop suppression/body depth rather than brighter body-owned edge lift; and optionally (4) test a very low-frequency interior-only secondary blur/composite lobe. The likely no-op or misleading directions are more `face_veil_strength`, more perimeter/fresnel/body-edge whitening, or tiny scalar nudges that do not materially change interior backdrop compression. Concise research notes were saved at `.temp/aerobeat-ui-kit-community-053-research-notes.md`.

---

### Task 2: Implement JSON export/import in both shader test scenes

**Bead ID:** `aerobeat-ui-kit-community-9n9`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, implement JSON export/import buttons in both the 2D and hybrid shader test scenes so the current shader key/value set can be saved and loaded. Put the buttons in the existing left-hand control panel in both scenes, replacing the bottom explanatory paragraph area (the existing shader/parity explanation text) rather than creating a separate UI region. Preserve existing experimentation controls, keep the UX simple, and avoid breaking the current parameter-edit flow.

**Folders Created/Deleted/Modified:**
- `.testbed/scripts/`
- `.plans/`

**Files Created/Deleted/Modified:**
- `.testbed/scripts/glass_shader_test.gd`
- `.testbed/scripts/glass_shader_gui_3d_test.gd`
- `.testbed/scripts/glass_shader_preset_io.gd`
- `.plans/2026-05-13-shader-preset-json-import-export.md`

**Status:** ✅ Complete

**Results:** Implemented shader preset JSON export/import in both test-scene controllers without disturbing the existing dynamic slider/color generation or adding a floating UI region. In both left-hand rails, the old explanatory paragraph block was replaced with a `preset_json` actions block containing `Export JSON`, `Load JSON`, and a small inline status label. FileDialog ownership stays in the scene controllers (`REF-03`, `REF-04`): each scene now creates one save dialog plus one load dialog, rooted to `user://shader-presets/2d` or `user://shader-presets/hybrid`, with `*.json` filtering and scene-specific default filenames.

A new shared helper at `.testbed/scripts/glass_shader_preset_io.gd` now owns JSON envelope creation, pretty JSON writing, schema/preset-kind validation, parameter normalization, and Color <-> RGBA-object conversion. The saved envelope uses `schema_version`, `preset_kind`, `source_scene`, `saved_at`, and `parameters`, and it intentionally stores UI-facing parameter names only. The 2D scene serializes values through `get_shader_parameter` / `set_shader_parameter`, while the hybrid scene serializes through `get_panel_shader_parameter` / `set_panel_shader_parameter`, so hybrid alias/scaling details stay internal and control syncing remains truthful. Unknown keys are ignored on load with an inline status message rather than hard-failing the whole import.

Repo-local validation passed with both (1) `godot --headless --path .testbed --import` and (2) `godot --headless --path .testbed --script res://../.temp/validate_shader_preset_json_io_2026_05_13.gd`. The validation script instantiated both scenes, changed representative float and color parameters, exported JSON presets, mutated the values, reloaded the saved presets, and confirmed round-trip restoration in both the 2D and hybrid cases, including the hybrid `edge_smoothness` alias path. Final commit hash: `4977325`. Push status: pushed to `origin/main`.

---

### Task 3: Compare 2D vs hybrid body treatment and attempt one credible body-only parity improvement if warranted

**Bead ID:** `aerobeat-ui-kit-community-m5d`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-03`, `REF-04`, `REF-05`, `REF-06`, `REF-07`, `REF-08`, `REF-09`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, compare the current strong 2D frosted-body treatment against the current hybrid 3D body path and identify the most credible body-only route to close the remaining parity gap. If there is a clear, low-risk improvement that preserves the solved silhouette and overlay/rim/inner-line ownership, implement one targeted body-only pass. If there is not a credible implementation path yet, document the strongest candidate solutions instead of forcing a noisy tweak. Be explicit about what is structurally different, what is merely parameter drift, and what should not be touched.

**Folders Created/Deleted/Modified:**
- `.testbed/scripts/`
- `.plans/` (results/documentation)
- `.temp/`

**Files Created/Deleted/Modified:**
- `.testbed/scripts/glass_shader_gui_3d_test.gd`
- `.plans/2026-05-13-shader-preset-json-import-export.md`
- `.temp/validate_task3_hybrid_defaults_2026_05_13.gd`

**Status:** ✅ Complete

**Results:** Implemented one credible body-only parity fix, but the real divergence turned out to be **runtime parameter drift**, not another missing shader branch. Comparing the current strong 2D source path (`REF-03` / `REF-05` / `REF-06`) against the live hybrid boot path (`REF-04` / `REF-07`) confirmed the structural gap remains what Task 1 already documented: the 2D card’s body is part of a flatter controlled screen-space composite, while the hybrid body samples a live 3D world and intentionally leaves silhouette/rim/inner-line ownership to the authored mask + overlay. The clearest *actionable* divergence inside the current hybrid body path, though, was that `glass_shader_gui_3d_test.gd` was still force-applying the **older pre-polish body defaults** at startup (`tint_strength=0.62`, `body_frost_strength=0.82`, `background_subdue=0.82`, `interior_chroma=0.22`, `face_veil_strength=0.22`, `perimeter_frost_boost=0.10`) even though the current body shader in `REF-07` had already moved to a stronger interior-compression / deeper mid-body frost balance (`0.66`, `0.85`, `0.86`, `0.24`, `0.18`, `0.08`). In practice, the hybrid scene was therefore not booting into the latest intended body treatment.

The landed fix updates only those hybrid startup defaults in `REF-04`, which is disciplined and low-risk because it keeps the solved ownership seams intact while finally letting the runtime use the current body balance already encoded in `REF-07`. This specifically follows the preferred direction from Task 1: more interior backdrop compression/subduing and deeper center/mid-body frost weighting, with **less** reliance on `face_veil_strength` and body-side perimeter lift. Nothing touched the authored-mask discard path, nothing changed the overlay shader in `REF-08`, and shell/edge ownership was not reopened. Repo-local validation passed via `godot --path .testbed --headless --script res://../.temp/validate_final_body_frost_polish_pass.gd` and `godot --path .testbed --headless --script res://../.temp/validate_task3_hybrid_defaults_2026_05_13.gd`, confirming both scenes still load and the hybrid scene now boots with the intended body defaults. Commit/push status recorded after git handoff.

---

### Task 4: QA JSON export/import and any body-only parity improvement

**Bead ID:** `aerobeat-ui-kit-community-6u0`  
**SubAgent:** `primary` (for `qa` workflow role)  
**Role:** `qa`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-06`, `REF-07`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, verify that both shader test scenes can export current shader settings to JSON and load them back correctly. Confirm that the expected shader parameters round-trip and that the existing controls still behave correctly after load. If Task 3 lands a body-only parity change, verify whether it is a real visual improvement and whether silhouette/overlay/rim/inner-line behavior stayed intact.

**Folders Created/Deleted/Modified:**
- `.temp/qa-evidence/2026-05-13-shader-preset-json-import-export/`

**Files Created/Deleted/Modified:**
- `.temp/qa_shader_preset_and_hybrid_defaults_2026_05_13.gd`
- `.temp/qa-evidence/2026-05-13-shader-preset-json-import-export/report.json`
- `.temp/qa-evidence/2026-05-13-shader-preset-json-import-export/2d-roundtrip.json`
- `.temp/qa-evidence/2026-05-13-shader-preset-json-import-export/hybrid-roundtrip.json`
- `.temp/qa-evidence/2026-05-13-shader-preset-json-import-export/2d-full-scene.png`
- `.temp/qa-evidence/2026-05-13-shader-preset-json-import-export/2d-left-panel.png`
- `.temp/qa-evidence/2026-05-13-shader-preset-json-import-export/2d-preview-area.png`
- `.temp/qa-evidence/2026-05-13-shader-preset-json-import-export/hybrid-full-scene.png`
- `.temp/qa-evidence/2026-05-13-shader-preset-json-import-export/hybrid-left-panel.png`
- `.temp/qa-evidence/2026-05-13-shader-preset-json-import-export/hybrid-preview-area.png`
- `.temp/qa-evidence/2026-05-13-shader-preset-json-import-export/hybrid-new-defaults-front.png`
- `.temp/qa-evidence/2026-05-13-shader-preset-json-import-export/hybrid-new-defaults-front-crop.png`

**Status:** ✅ Complete

**Results:** QA completed against `4977325`, `b1c5b1d`, and `a44ce27` using the highest-fidelity non-interactive path available in this environment: live Godot scene instantiation plus runtime parameter mutation/restore checks, JSON file inspection, control-tree inspection, and captured UI evidence under `.temp/qa-evidence/2026-05-13-shader-preset-json-import-export/`. A dedicated QA script at `.temp/qa_shader_preset_and_hybrid_defaults_2026_05_13.gd` verified both scenes end-to-end.

JSON workflow verdict: **PASS in both scenes**. In the 2D scene (`REF-03`), QA changed representative float and color values (`blur=5.6`, `strength_x=19.4`, `tint=(0.31, 0.45, 0.95, 0.29)`), exported to `.temp/qa-evidence/2026-05-13-shader-preset-json-import-export/2d-roundtrip.json`, mutated them away, reloaded the preset, and confirmed the shader values restored exactly and the bound slider/color-picker controls resynced correctly. The saved envelope contains the expected top-level keys: `schema_version`, `preset_kind`, `source_scene`, `saved_at`, and `parameters`.

The hybrid scene (`REF-04`) also **PASSed** round-trip QA. QA changed `background_subdue=0.91`, `edge_smoothness=1.73`, and `ui_overlay_tint=(0.91, 0.97, 1.0, 1.0)`, exported to `.temp/qa-evidence/2026-05-13-shader-preset-json-import-export/hybrid-roundtrip.json`, mutated them away, reloaded the preset, and confirmed all three values restored correctly. This also truth-checked the hybrid alias path: the UI-facing `edge_smoothness=1.73` persisted/restored through JSON while the underlying shader parameter resolved to `edge_softness=0.0173`, and the visible slider/value-label state stayed in sync after load. Neither scene reported ignored keys during the clean round-trip case.

Left-panel UX verdict: **landed as requested**. Evidence crops `2d-left-panel.png` and `hybrid-left-panel.png` show the preset actions block directly below the preview-background selector in the existing left rail, with `Export JSON` and `Load JSON` buttons plus inline status text. The old bottom explanatory text area was not kept as a separate extra block in that slot; it has been replaced by the preset block in both testers. The hybrid scene still keeps its separate lower status/help panel, which is appropriate and was already part of that test scene’s layout.

Hybrid runtime-defaults verdict: **aligned to the intended newer body-frost balance**. QA captured the live startup values and confirmed they now match the intended newer defaults exactly: `tint_strength=0.66`, `body_frost_strength=0.85`, `background_subdue=0.86`, `interior_chroma=0.24`, `face_veil_strength=0.18`, and `perimeter_frost_boost=0.08`. These match the expected post-fix values and no longer drift to the older runtime set (`0.62`, `0.82`, `0.82`, `0.22`, `0.22`, `0.10`). See `report.json` plus `hybrid-new-defaults-front.png` / `hybrid-new-defaults-front-crop.png` in the QA evidence folder.

Practical-improvement verdict: **real but modest**. This does not solve the deeper structural 2D-vs-hybrid body-composite difference by itself, so it should not be oversold as a full parity breakthrough. But it is more than a bookkeeping sync: the new startup state meaningfully biases the hybrid body toward the intended stronger interior frost/subdued-background balance and away from the older, slightly weaker/murkier startup mix. In plain terms, the fix makes the scene boot into the better-tuned look Derrick was already converging on, rather than an outdated drifted state. That is worthwhile, but it is still a configuration-alignment improvement inside the current architecture, not a new compositing capability.

Behavior-regression verdict: **no regressions found** in the solved ownership seams. The current hybrid evidence still shows the authored silhouette intact, the overlay/rim/inner-line stack still present and crisp, and no QA sign that the JSON workflow or runtime-default sync disturbed those pieces. The change touched startup defaults, not the authored mask discard path or overlay shader ownership, and observed output remains consistent with that expectation.

Remaining gap: the hybrid body still does not fully match the flatter, creamier 2D body because the underlying world-aware body pipeline remains structurally different. QA therefore considers Task 3’s fix a keeper as a runtime-defaults correction, but not the final answer to full 2D body parity.

---

### Task 5: Audit the implementation and document the truthful answer about why the body still differs

**Bead ID:** `aerobeat-ui-kit-community-3ox`  
**SubAgent:** `primary` (for `auditor` workflow role)  
**Role:** `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`, `REF-06`, `REF-07`, `REF-08`, `REF-09`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, audit the JSON import/export implementation and independently truth-check the explanation for why the hybrid frosted interior body still differs from the 2D shader. Confirm what is structurally different versus what is just tuning. Also truth-check whether any Task 3 body-only parity attempt is a real keeper or just noise.

**Folders Created/Deleted/Modified:**
- `.plans/` (notes/results only if needed)

**Files Created/Deleted/Modified:**
- optional audit notes if needed

**Status:** ✅ Complete

**Results:** Independent audit confirmed the JSON preset feature is correctly implemented and truthfully documented. The shared helper in `REF-03` / `REF-04` / `glass_shader_preset_io.gd` writes a sane envelope (`schema_version`, `preset_kind`, `source_scene`, `saved_at`, `parameters`), preserves UI-facing parameter names, round-trips floats plus colors, and keeps the hybrid alias/scaling path internal. QA evidence under `.temp/qa-evidence/2026-05-13-shader-preset-json-import-export/` shows **PASS in both scenes**: the 2D preset restored representative float + color values and resynced live controls/value labels, and the hybrid preset restored representative body + overlay values including the `edge_smoothness` → `edge_softness` alias path (`resolved_edge_softness=0.0173`). The left-panel placement also matches Derrick’s request: `2d-left-panel.png` and `hybrid-left-panel.png` show the `preset_json` block in the existing left control rail directly under the background selector, occupying the old explanatory-text slot rather than adding a separate floating panel.

The explanation for the remaining body gap is also directionally correct, but it needs to stay framed as a **structural pipeline difference** rather than a nearly-solved tuning issue. The 2D reference shader in `glass-shader.gdshader` is a single flat screen-space card composite. The hybrid path deliberately splits responsibilities: `glass-panel-hybrid-3d.gdshader` owns the frosted body/refracted world sample, while `glass-panel-ui-overlay-3d.gdshader` separately preserves the crisp rim / inner-line / UI overlay. That means the hybrid body is not trying to reproduce the full 2D composite by itself, and it samples a live 3D `screen_texture` with view-angle terms (`VIEW`, `NORMAL`, `ndotv`, fresnel, world-rim refraction) that the 2D card simply does not have. So the documented explanation is substantially true: the remaining difference is not just “wrong knob values,” it is that the hybrid body is a different, world-aware body-composite architecture.

The runtime-defaults sync from `a44ce27` is real, but the audit verdict is narrower than “meaningful parity breakthrough.” The hybrid scene now boots with the intended newer default set (`tint_strength=0.66`, `body_frost_strength=0.85`, `background_subdue=0.86`, `interior_chroma=0.24`, `face_veil_strength=0.18`, `perimeter_frost_boost=0.08`) instead of the older drifted startup values, so this is a valid **configuration-correctness fix** and worth keeping. However, the evidence for a materially visible body-frost improvement is weak on the reproducible capture path here: fresh old-vs-new startup crops differ only by tiny pixel deltas, and the separate final-polish evidence folder remains pixel-identical to its prior baseline for the checked front/angled/debug crops. So this should be described as “the runtime now matches the intended tuned defaults” rather than “the body parity gap is meaningfully closed.” Silhouette / overlay / rim / inner-line ownership stayed intact throughout.

---

## Final Results

**Status:** ✅ Complete

**What We Built:** Shader preset JSON export/import is complete in both the 2D and hybrid test scenes, with the controls placed in the requested left-hand panel location and validated by round-trip QA. The slice also produced a truthful answer about the remaining hybrid-vs-2D body gap: the gap is still primarily architectural, not merely leftover slider drift.

**Reference Check:** `REF-03`, `REF-04`, and the QA evidence confirm the preset workflow and left-rail placement. `REF-07` and `REF-08` support the explanation that the hybrid body and overlay intentionally split responsibilities, so the hybrid body alone cannot exactly equal the flatter 2D card composite from `REF-06`. `REF-09` remains a useful visual target, but current evidence does not justify claiming that the runtime-default sync materially achieved that parity.

**Commits:**
- `4977325` - Add shader preset JSON import/export
- `b1c5b1d` - Update plan with preset export commit hash
- `a44ce27` - Sync hybrid body frost runtime defaults

**Lessons Learned:** JSON preset sharing was the solid win in this slice. The hybrid body-frost startup sync is still worth keeping, but it should be interpreted as runtime/default alignment inside the existing architecture, not as proof that the deeper 2D-vs-hybrid body-composite gap is solved.

---

*Drafted on 2026-05-13*
