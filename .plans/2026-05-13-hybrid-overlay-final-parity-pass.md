# AeroBeat UI Kit Community — Hybrid Overlay Final Parity Pass

**Date:** 2026-05-13  
**Status:** In Progress  
**Agent:** Byte 🐈‍⬛

---

## Goal

Close the remaining hybrid-vs-2D parity gap by improving the overlay-side treatment: make the `Shader Preview` chip/background read closer to the 2D version and make the inner rounded-rectangle line bright/light like the 2D scene, without introducing blur/smear into the rest of the text/UI. Also expose the new hybrid-world overlay accent values as real controls/preset keys so Derrick can tweak and save/load them from the test UI instead of relying on hardcoded script values.

---

## Overview

Derrick’s latest side-by-side comparison shows that the hybrid panel is now extremely close overall. The remaining differences no longer look like body-glass architecture problems. Instead, they are narrow overlay-composition issues. Two symptoms stand out: the `Shader Preview` rounded rectangle is darker in the hybrid view, and the inner rounded rectangle line around the panel is darker than the light/white line in the 2D reference. Derrick also found an important control-coupling problem: pushing `ui_overlay_tint` can brighten those elements somewhat, but it also creates an unwanted blur/smear effect across the other UI/text elements.

That strongly suggests the remaining gap is not “find the perfect global tint.” It suggests the hybrid overlay still lacks enough separation between line treatment, chip/background treatment, and overall UI/text embedding. This pass should therefore stay away from reopening body-glass work unless absolutely forced by evidence. The highest-value next move is to inspect the current overlay composition path and identify the smallest truthful way to brighten the chip and inner line independently, while preserving text clarity and the now-good glass/body result.

Derrick’s follow-up confirmed one more usability requirement: these hybrid-only overlay accent lifts should not stay hidden as hardcoded script values. They should become explicit tweakable values visible in the left-hand controls and included in preset JSON round-trips, so experimentation can happen from the UI rather than from code edits.

This should be treated as a manual-review slice again unless Derrick later asks for the full QA/audit loop.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Hybrid overlay shader | `.testbed/assets/shaders/glass-panel-ui-overlay-3d.gdshader` |
| `REF-02` | Hybrid body shader | `.testbed/assets/shaders/glass-panel-hybrid-3d.gdshader` |
| `REF-03` | Hybrid scene controller | `.testbed/scripts/glass_shader_gui_3d_test.gd` |
| `REF-04` | Shared 2D panel/source script | `.testbed/scripts/glass_shader_panel_source.gd` |
| `REF-05` | 2D reference scene | `.testbed/scenes/glass-shader-test.tscn` |
| `REF-06` | Hybrid scene | `.testbed/scenes/glass-shader-gui-3d-test.tscn` |
| `REF-07` | Latest side-by-side screenshot: hybrid left, 2D right | `/home/derrick/.openclaw/workspace/.temp/nerve-uploads/2026/05/13/image-881baefb.png` |
| `REF-08` | Active prior follow-up plan/results | `.plans/2026-05-13-hybrid-edge-color-bug-and-default-preset-unification.md` |

---

## Tasks

### Task 1: Research the remaining overlay-side parity gap

**Bead ID:** `aerobeat-ui-kit-community-ehv`  
**SubAgent:** `primary` (for `research` workflow role)  
**Role:** `research`  
**References:** `REF-01`, `REF-03`, `REF-04`, `REF-05`, `REF-06`, `REF-07`, `REF-08`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, inspect the remaining hybrid-vs-2D parity gap focused on the overlay side. Derrick reports that the `Shader Preview` rounded rectangle is darker in hybrid and the inner rounded panel line is dark instead of light like the 2D version. He can brighten them somewhat by changing `ui_overlay_tint`, but that causes a blur/smear effect across the other UI/text. Determine the cleanest explanation of the current control coupling and the smallest truthful fix path that brightens the chip/background and inner line without blurring the rest of the overlay.

**Folders Created/Deleted/Modified:**
- `.plans/` (notes/results only if needed)
- `.temp/` if needed

**Files Created/Deleted/Modified:**
- `.plans/2026-05-13-hybrid-overlay-final-parity-pass.md`
- `.temp/2026-05-13-hybrid-overlay-final-parity-research.md`

**Status:** ✅ Complete

**Results:** Research complete. The most likely cause of the remaining coupling is that `REF-01` (`glass-panel-ui-overlay-3d.gdshader`) only receives a single flattened `ui_texture` from the authored source scene, so its controls (`ui_overlay_alpha`, `ui_overlay_brightness`, `ui_overlay_tint_mix`, `ui_overlay_tint`, shadow) are global image-wide transforms rather than semantic controls for specific overlay parts. In practice that means the same front-overlay pass is reprocessing the `Shader Preview` badge, the inner rounded line, and the text glyph edges together. Raising overlay tint/brightness therefore lifts the chip and inner line only by also reprocessing the rest of the alpha-bearing UI, which is why Derrick sees unwanted wash/softness/smear rather than a clean isolated brightening.

The remaining darkness itself appears to be authored overlay styling, not another body-glass architecture bug. In `REF-04` (`glass_shader_panel_source.gd`), the hybrid-world shell still keeps the `PreviewInnerBorder` conservative via `clampf(0.08 + _shell_tint.a * 0.55, 0.08, 0.24)`, and the `Shader Preview` badge continues to use the static scene style values from `REF-05` (`glass-shader-panel-source.tscn`) — badge fill alpha `0.08`, badge border alpha `0.14`, badge label alpha `0.78`. Those values are acceptable in the 2D source composition, but in hybrid world mode they sit over the darker/tinted body result and therefore read dimmer than the 2D reference.

Smallest truthful fix path: keep `REF-02` (hybrid body shader) and `REF-01` (front overlay shader) structurally untouched, and instead add hybrid-world-specific authored accent tuning in `REF-04`. Concretely, brighten the `PreviewInnerBorder` directly in hybrid world mode and add direct hybrid-world styling for the `Shader Preview` badge (its panel background, border, and if needed label alpha) so those elements can be lifted independently without globally re-tinting all UI/text. This should be done in `glass_shader_panel_source.gd` with new node references for the badge panel/label and a small branch/helper in `_sync_preview_shell()` or an adjacent shell-style sync method. What should remain untouched unless tests disprove this diagnosis: the current body/frost/rim behavior in `REF-02`, the front overlay shader structure in `REF-01`, the controller/plumbing in `REF-03`, and the already-correct hybrid-world `PreviewFrame` fill/shadow shutdown in `REF-04`. Concise notes were recorded in `.temp/2026-05-13-hybrid-overlay-final-parity-research.md`.

---

### Task 2: Implement the overlay-side parity fix

**Bead ID:** `aerobeat-ui-kit-community-257` → follow-up `aerobeat-ui-kit-community-89c`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-06`, `REF-07`, `REF-08`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, implement the smallest truthful overlay-side parity fix that makes the `Shader Preview` chip and the inner rounded rectangle line read closer to the 2D reference without introducing blur/smear across the rest of the UI/text. Also expose the new hybrid-only overlay accent values as real tweakable controls/preset keys in the left panel and JSON workflow so Derrick can modify them directly. Preserve the now-good body/glass behavior and avoid reopening silhouette/default-preset work unless required.

**Folders Created/Deleted/Modified:**
- `.testbed/scripts/`
- `.plans/`

**Files Created/Deleted/Modified:**
- `.testbed/scripts/glass_shader_panel_source.gd`
- `.testbed/scripts/glass_shader_gui_3d_test.gd`
- `.testbed/presets/glass/hybrid/default.json`
- `.plans/2026-05-13-hybrid-overlay-final-parity-pass.md`

**Status:** ✅ Complete

**Results:** Initial parity lift landed in commit `036413b` (`Brighten hybrid preview badge and inner border`) by moving the remaining chip/inner-line brightening into `REF-04` (`glass_shader_panel_source.gd`) as authored hybrid-world styling instead of pushing harder on the global overlay shader controls in `REF-01`. That preserved the body/glass result and avoided the blur/smear side effect Derrick saw when brightening through `ui_overlay_*`.

Follow-up bead `aerobeat-ui-kit-community-89c` then converted those hybrid-only accent lifts from hardcoded authored values into real left-panel controls and preset keys without changing the truthful model. `REF-03` (`glass_shader_gui_3d_test.gd`) now exposes five hybrid-only sliders — `hybrid_inner_border_brightness`, `hybrid_inner_border_alpha`, `hybrid_badge_fill_alpha`, `hybrid_badge_border_alpha`, and `hybrid_badge_label_alpha` — and routes them through the same save/load JSON workflow as the rest of the hybrid scene controls. `REF-04` now stores those values explicitly, applies them only in hybrid world mode, and still restores the original 2D-authored values (`0.08` fill, `0.14` border, `0.78` label, original inner-border formula) outside hybrid world mode so the shared 2D source remains sane/truthful.

The bundled hybrid startup preset at `res://presets/glass/hybrid/default.json` was updated to include those new keys with the exact values that preserve the current visual result: inner border brightness `1.0`, inner border alpha `0.312`, badge fill alpha `0.18`, badge border alpha `0.267`, badge label alpha `0.9`. Repo-local validation for this slice was a headless Godot parse/run smoke on both the 2D and hybrid scenes: `godot --headless --path .testbed --scene res://scenes/glass-shader-test.tscn --quit-after 2` and `godot --headless --path .testbed --scene res://scenes/glass-shader-gui-3d-test.tscn --quit-after 2`; both exited cleanly with no script/runtime errors. The follow-up exposure pass landed on `main` in commit `92df7d6` (`Expose hybrid overlay accent controls`) and was pushed to `origin/main`.

---

### Task 3: QA the overlay-side parity fix

**Bead ID:** `Skipped by user`  
**SubAgent:** `primary` (for `qa` workflow role)  
**Role:** `qa`  
**References:** `REF-01`, `REF-03`, `REF-05`, `REF-06`, `REF-07`  
**Prompt:** Skipped for this slice at Derrick’s request; Derrick will review the result in person instead of running the normal QA lane.

**Folders Created/Deleted/Modified:**
- none

**Files Created/Deleted/Modified:**
- none

**Status:** ⏭️ Skipped by user

**Results:** QA intentionally skipped by Derrick for this slice so he can manually review the result in person.

---

### Task 4: Audit the overlay-side parity fix

**Bead ID:** `Skipped by user`  
**SubAgent:** `primary` (for `auditor` workflow role)  
**Role:** `auditor`  
**References:** `REF-01`, `REF-03`, `REF-05`, `REF-06`, `REF-07`  
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

**What We Built:** The hybrid scene now keeps the authored overlay-side parity lift while also exposing the hybrid-only accent values as real left-panel sliders and preset JSON keys. Derrick can tune the hybrid inner border brightness/alpha plus the badge fill/border/label alphas directly from the test UI, and the bundled startup preset preserves the current intended visual result.

**Reference Check:** `REF-01` and `REF-02` remained structurally untouched for this follow-up; the behavior change stayed in `REF-03`/`REF-04` plus the bundled hybrid preset. `REF-04` now applies the accent values only in hybrid world mode and restores the original 2D-authored styling otherwise, which satisfies the “keep 2D sane/truthful” requirement. `REF-06` startup defaults still come from `res://presets/glass/hybrid/default.json`, now with the new keys present.

**Commits:**
- `036413b` - Brighten hybrid preview badge and inner border
- `92df7d6` - Expose hybrid overlay accent controls

**Lessons Learned:** Once the hybrid scene depends on authored overlay-only compensation, the values should be surfaced as explicit hybrid controls early instead of leaving them hidden in script formulas; that keeps parity work tweakable without reopening the global overlay shader coupling problem.

---

*Drafted on 2026-05-13*
