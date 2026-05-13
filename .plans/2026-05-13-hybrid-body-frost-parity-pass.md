# AeroBeat UI Kit Community — Hybrid Body Frost Parity Pass

**Date:** 2026-05-13  
**Status:** In Progress  
**Agent:** Byte 🐈‍⬛

---

## Goal

Fix the hybrid body-layer shape mismatch so the frosted interior radius matches the exterior panel shell, then improve the 3D frosted body read so it lands materially closer to the 2D glass card without reopening hybrid-default ownership or the authored overlay/rim/inner-line solution.

---

## Overview

Yesterday’s passes successfully isolated the remaining visual problem. The hybrid world-space path now has the right ownership boundaries, the old hidden default coupling is gone in practice, and the sharp shell treatment is no longer being procedurally faked by the 3D body shader. Instead, the authored overlay path now carries the white outer rim and crisp inner edge line much more truthfully. That means the previous mushy “the whole 3D card feels wrong” diagnosis has collapsed into a much narrower and more actionable target: the body frost itself.

Derrick’s latest screenshots sharpen the remaining problem further. There is now a clearly visible **shape mismatch** between the exterior glass shell and the interior frosted body mask: when `corner_radius` is increased, the outer shell keeps only a slight radius while the interior frosted region is cut away dramatically, so the body no longer tracks the panel’s true silhouette. At `corner_radius = 0`, that mismatch collapses away, which strongly suggests the body-mask radius math and the visible shell radius are being derived differently. That needs to be treated as a first-class correctness bug, not merely a cosmetic tuning issue.

Even after that, the 3D body still lags the 2D reference in density, richness, and colored frosted read. It still lets background geometry show through too strongly and does not yet produce the same creamy/colored/softly layered body feel that the 2D card gets from its composite treatment. This pass should therefore avoid reopening solved seams. It should keep the authored overlay/rim/inner-line behavior stable and focus on (1) making the body-mask silhouette match the panel exterior and (2) improving the body shader’s face treatment, transmission, distortion balance, tint/frost layering, and any supporting composition changes that affect only the body read.

The main truth constraint for this pass is discipline: if a promising experiment starts degrading the now-good rim/inner-line behavior, that is a regression, not progress. We only keep changes that improve the body frost while preserving the current shell/detail gains.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Hybrid scene controller script | `.testbed/scripts/glass_shader_gui_3d_test.gd` |
| `REF-02` | Shared 2D source script | `.testbed/scripts/glass_shader_panel_source.gd` |
| `REF-03` | Hybrid world-space scene | `.testbed/scenes/glass-shader-gui-3d-test.tscn` |
| `REF-04` | 2D reference scene | `.testbed/scenes/glass-shader-test.tscn` |
| `REF-05` | Current hybrid body shader | `.testbed/assets/shaders/glass-panel-hybrid-3d.gdshader` |
| `REF-06` | Current hybrid UI overlay shader | `.testbed/assets/shaders/glass-panel-ui-overlay-3d.gdshader` |
| `REF-07` | Prior full decoupling + line parity plan/results | `.plans/2026-05-12-full-hybrid-decoupling-and-frost-line-parity.md` |
| `REF-08` | Prior Unity-inspiration body/overlay split plan/results | `.plans/2026-05-12-hybrid-world-space-glass-unity-inspiration-pass.md` |
| `REF-09` | Prior user screenshot showing 2D vs current 3D comparison | `/home/derrick/.openclaw/workspace/.temp/nerve-uploads/2026/05/13/image-073fa4ac.png` |
| `REF-10` | Latest screenshot: `corner_radius = 0.18`, showing frosted body radius cut much more aggressively than exterior shell radius | `/home/derrick/.openclaw/workspace/.temp/nerve-uploads/2026/05/13/image-fa2ec327.png` |
| `REF-11` | Latest screenshot: `corner_radius = 0.0`, showing the mismatch collapse when radius is removed | `/home/derrick/.openclaw/workspace/.temp/nerve-uploads/2026/05/13/image-0b61f0c4.png` |

Use `REF-07` as the source of truth for what is already solved and should not be reopened. Use `REF-08` as a reminder that crisp-overlay separation was useful, but a milky straight-on veil regression is not acceptable. Use `REF-10` and `REF-11` as the primary correctness references for the body/shell radius mismatch.

---

## Tasks

### Task 1: Research the body/shell radius mismatch and the cleanest body-only parity direction

**Bead ID:** `aerobeat-ui-kit-community-zz8`  
**SubAgent:** `primary` (for `research` workflow role)  
**Role:** `research`  
**References:** `REF-03`, `REF-04`, `REF-05`, `REF-06`, `REF-07`, `REF-08`, `REF-09`, `REF-10`, `REF-11`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, analyze the current hybrid body shader and masking/silhouette path versus the 2D reference and Derrick’s latest screenshots. First diagnose why `corner_radius` produces a much more aggressive interior frosted cutout than the visible exterior shell radius. Then propose the best body-only parity direction that fixes that shape mismatch and improves frosted density/richness/colored read without regressing the already-improved authored overlay rim/inner-line behavior. Be explicit about which shader terms, mask math, or composition layers should change and which should be left alone.

**Folders Created/Deleted/Modified:**
- `.plans/` (notes/results only if needed)
- `.temp/`

**Files Created/Deleted/Modified:**
- `.temp/aerobeat-ui-kit-community-zz8-radius-frost-notes.md`

**Status:** ✅ Complete

**Results:** Research isolated the radius bug to a duplicated-silhouette unit mismatch between the authored shell/mask path and the procedural body mask in `REF-05` + `REF-02`. In `glass_shader_panel_source.gd`, the visible shell and hybrid mask convert `corner_radius` to pixels as `corner_radius * 0.5 * min(width, height)`, so the shell radius is defined by the short side. But in `glass-panel-hybrid-3d.gdshader`, the body pass interprets the same scalar directly in normalized quad UV space (`radius = corner_radius`, `half_extents = vec2(0.5 - radius)`), then multiplies that procedural rounded-box mask against the authored mask (`mask = authored_mask * card_mask`). On this rectangular card, that makes the body mask much rounder/smaller than the shell, so the frosted body cuts inward far more aggressively whenever `corner_radius > 0`; `REF-10` shows that mismatch clearly, and `REF-11` confirms it collapses when both masks become plain rectangles at zero radius. The cleanest fix path is not to keep fighting the procedural silhouette by eye, but to make the authored mask the only true silhouette for discard/alpha and recompute any body SDF used for `w`, `edge_proximity`, or interior/perimeter shaping in the same pixel-space model as the authored shell (derive `panel_size_px` from `glass_rect.zw * VIEWPORT_SIZE`, convert `corner_radius` to `radius_px`, and build the rounded-box SDF in pixel/aspect-correct units). That path fixes correctness first and prevents future shell/body drift. For the follow-up parity direction, the body pass should stay body-only: keep the authored overlay, sharp white rim, crisp inner line, and `sync_hybrid_shell()` ownership model untouched; improve density/richness by increasing interior background subduing, tint-weighted colored frost, and interior compositing depth rather than reviving a flatter white face veil or stronger body-generated edge whites. Main regression risks: if the procedural SDF still drives final alpha/discard, the silhouette bug survives; if density is pushed mainly through `face_veil_strength`, the shader can regress back toward the previously rejected milky straight-on haze from `REF-08`; and if perimeter/fresnel terms are pushed too far, the body pass will start competing with the already-good authored overlay/rim/inner-line solution. Concise notes were saved to `.temp/aerobeat-ui-kit-community-zz8-radius-frost-notes.md`.

---

### Task 2: Implement the radius fix and the best body-frost pass without reopening solved overlay/detail behavior

**Bead ID:** `aerobeat-ui-kit-community-lm3`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-01`, `REF-03`, `REF-04`, `REF-05`, `REF-06`, `REF-07`, `REF-08`, `REF-09`, `REF-10`, `REF-11`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, implement the best next body-only parity pass. First fix the correctness issue where the frosted interior radius/mask cuts inward much more aggressively than the exterior panel shell when `corner_radius` is nonzero. Then improve the frosted body’s density, richness, tint/compositing feel, and straight-on read toward the 2D reference while preserving the current authored overlay, sharp white rim, and crisp inner edge line behavior. Do not reopen hybrid-default decoupling or move rim/inner-line responsibility back into the body shader.

**Folders Created/Deleted/Modified:**
- `.testbed/assets/shaders/`
- `.testbed/scripts/`

**Files Created/Deleted/Modified:**
- `.testbed/assets/shaders/glass-panel-hybrid-3d.gdshader`
- `.testbed/scripts/glass_shader_gui_3d_test.gd`

**Status:** ✅ Complete

**Results:** Implemented the body-only parity pass directly in `REF-05` while leaving `REF-06` untouched. The radius correctness bug was fixed by removing the procedural rounded-box mask from final discard/alpha ownership and recomputing the helper rounded-box SDF in pixel/aspect-correct panel space derived from `glass_rect.zw * VIEWPORT_SIZE` and `corner_radius * 0.5 * min(panel_size_px.x, panel_size_px.y)`. That makes the authored mask the only true silhouette for body discard/alpha, so nonzero `corner_radius` no longer lets a smaller normalized-UV body mask cut inward harder than the visible shell. The same corrected SDF is still used for body-only shaping (`w`, `edge`, perimeter/interior weighting, and warp/frost falloff), which preserves the shell/detail ownership split from `REF-07`. The body frost read was then pushed closer to `REF-09`/`REF-10` by increasing default body density/subduing/tint richness in `REF-05` + `REF-01`: stronger tint/body/background-subdue defaults, a lower face-veil contribution to avoid the rejected flat milky veil from `REF-08`, and a deeper composite that blends blurred/chromatically shifted background, neutralized/compressed backdrop, tint-weighted body color, and a richer interior frost core without reassigning rim/inner-line work back to the body pass. Repo-local validation completed via (1) `godot --path .testbed --headless --script res://../.temp/validate_hybrid_load.gd`, which successfully loaded `REF-03`, instantiated the hybrid scene, and toggled `corner_radius` across `0.18`, `0.0`, and `0.24` with the new shader path active and no parse/runtime errors, and (2) a numeric sanity check confirming the old normalized-UV interpretation would have produced ~`93.6px` / `57.6px` effective radius at `corner_radius=0.18` for this panel while the new pixel-space path now matches the authored shell at `28.8px` on both axes. Commit hash: `ab34189`. 

---

### Task 3: QA the radius fix and body-frost change against the 2D reference and latest screenshots

**Bead ID:** `aerobeat-ui-kit-community-ynw`  
**SubAgent:** `primary` (for `qa` workflow role)  
**Role:** `qa`  
**References:** `REF-03`, `REF-04`, `REF-05`, `REF-06`, `REF-07`, `REF-09`, `REF-10`, `REF-11`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, verify whether the new pass fixes the body/exterior radius mismatch and improves the frosted body materially toward the 2D reference while preserving the already-good shell treatment. Be explicit about whether the frosted interior silhouette now matches the visible panel shell at nonzero `corner_radius`, plus background read-through, body density/richness, color/frost feel, and whether the rim/inner-line behavior stayed stable.

**Folders Created/Deleted/Modified:**
- `.temp/qa-evidence/` if evidence is collected

**Files Created/Deleted/Modified:**
- optional QA evidence artifacts

**Status:** ✅ Complete

**Results:** QA verified the landed pass against `REF-09`, `REF-10`, and `REF-11` using fresh Godot captures saved under `.temp/qa-evidence/2026-05-13-hybrid-body-frost-pass/`. At nonzero radius, the old body/shell silhouette bug appears fixed in practice: the new `corner_radius = 0.18` and `0.24` debug captures show the frosted body now following the authored shell instead of collapsing inward to a much smaller rounded capsule (`hybrid-debug-radius-018-front-crop.png`, `hybrid-debug-radius-024-front-crop.png`), which is a clear improvement over `REF-10`. At `corner_radius = 0.0`, the expected collapse behavior still reads sensibly: body and shell both resolve to the same rectangular footprint with no residual mismatch (`hybrid-debug-radius-000-front-crop.png`), matching the logic demonstrated in `REF-11`. Visually, the body frost is materially closer to the 2D reference from `REF-09` than the prior 3D state: the interior now has more density, more colored/creamy frost, and less raw background read-through, especially in the front hybrid overlay comparison (`2d-reference-crop.png` vs `hybrid-overlay-radius-018-front-crop.png`). It still does not fully reach the 2D card’s richness or polish — the 3D body remains a bit flatter/greyer and lets the debug geometry read slightly harder than the 2D source, especially away from the center and at angle (`hybrid-overlay-radius-018-angled-crop.png`) — but it is now in the right neighborhood instead of obviously under-frosted. The authored overlay behavior stayed stable: the sharp white rim and crisp inner line remain intact and are still clearly being carried by the overlay path rather than getting blurred out by the body pass, with no obvious regression in the front or angled captures. Supplemental viewport artifacts and a simple artifact index were also saved in the same evidence folder; QA added only temporary capture scripts under `.temp/` and made no product-code changes.

---

### Task 4: Audit whether this pass fixes the radius bug and genuinely improves the body without rebreaking solved seams

**Bead ID:** `aerobeat-ui-kit-community-e0j`  
**SubAgent:** `primary` (for `auditor` workflow role)  
**Role:** `auditor`  
**References:** `REF-03`, `REF-04`, `REF-05`, `REF-06`, `REF-07`, `REF-08`, `REF-09`, `REF-10`, `REF-11`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, audit the body-frost pass independently. Confirm whether it fixes the body/exterior radius mismatch and makes the 3D body more truthful to the 2D card without reintroducing old problems in default ownership, authored overlay responsibility, rim sharpness, or inner-line crispness.

**Folders Created/Deleted/Modified:**
- `.plans/` (notes/results only if needed)

**Files Created/Deleted/Modified:**
- optional audit notes if needed

**Status:** ✅ Complete

**Results:** Independent audit passes this slice as complete for its intended scope. The core correctness bug from `REF-10` is genuinely fixed, not merely tuned around: `REF-05` now discards strictly on `authored_mask` and no longer multiplies final alpha/discard by a second procedural rounded-box mask, so the old duplicated-silhouette failure mode is removed in code rather than cosmetically hidden. The remaining rounded-box SDF is now rebuilt in panel pixel space from `glass_rect.zw * VIEWPORT_SIZE` and `corner_radius * 0.5 * min(panel_size_px.x, panel_size_px.y)`, which matches the shell math used in `REF-02`; that makes the helper shape suitable for interior weighting/edge falloff without being a second silhouette owner. The visual evidence agrees with the code path: the new `hybrid-debug-radius-018-front-crop.png` and `hybrid-debug-radius-024-front-crop.png` show the frosted body tracking the authored shell footprint instead of collapsing inward into the smaller capsule visible in `REF-10`, while `hybrid-debug-radius-000-front-crop.png` still collapses cleanly to the shared rectangular case like `REF-11`. On frost quality, the body is materially improved over the prior under-frosted 3D state: the front and angled overlay captures show more density, more colored frost, and less harsh background read-through than before, while the shader diff confirms that gain came from stronger background subduing / tint-weighted body compositing and a reduced `face_veil_strength` rather than reintroducing the rejected flat milky veil from `REF-08`. The pass does not fully equal the 2D richness in `REF-09` — the 3D body still reads a bit flatter/greyer and some debug geometry remains more legible than in the 2D card — but that is now a follow-up polish gap, not a blocker for this slice. Overlay ownership also stays intact: `REF-06` was not changed, the crisp white rim and inner line are still visibly authored-overlay responsibilities in the QA crops, and the body shader’s edge white contribution was actually softened rather than promoted. Based on code inspection plus artifact review, this bead should pass and close for the intended slice: silhouette ownership is corrected, the duplicated-mask bug is removed, the body frost is meaningfully better without the milky regression, and the preserved overlay/rim/inner-line separation remains truthful.

---

## Final Results

**Status:** ✅ Complete

**What We Built:** The landed pass fixes the hybrid body/shell radius mismatch by making the authored mask the only silhouette/discard owner and moving the helper rounded-box SDF onto the same pixel-space radius model as the authored shell. It also improves the 3D body frost materially with denser, more colored, more backdrop-subduing body compositing while preserving the authored overlay split that carries the sharp white rim and crisp inner line.

**Reference Check:** `REF-10` and `REF-11` are satisfied for the targeted correctness bug: the nonzero-radius inward body cut is gone and the zero-radius case still collapses cleanly. `REF-07` remains respected because overlay/detail ownership was not reopened. `REF-08` remains respected because the body did not regress back into the rejected milky front-face veil; the shader change explicitly lowered `face_veil_strength` while increasing density through deeper body compositing instead. `REF-09` is only partially matched aesthetically: the 3D body is now clearly closer, but still a bit flatter/greyer than the 2D card. That remaining richness gap is acceptable as a future polish follow-up rather than a blocker for this slice. `REF-06` stayed intentionally unchanged and still owns the crisp overlay behavior.

**Commits:**
- `ab34189` - Fix hybrid glass body radius and frost pass
- `79249b2` - Update hybrid body frost pass plan results

**Lessons Learned:** This fix only became trustworthy once silhouette ownership was made singular. Matching the body helper math to the authored shell’s pixel-space radius removed the correctness trap, and reducing face-veil reliance was the right way to improve frost without reviving the old milky regression.

---

*Drafted on 2026-05-13*
