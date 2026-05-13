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

**Status:** ⏳ Pending

**Results:** Pending.

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

**Status:** ⏳ Pending

**Results:** Pending.

---

## Final Results

**Status:** ⚠️ Partial

**What We Built:** Task 2 coder pass completed: the hybrid body shader now uses the authored mask as the sole silhouette/discard truth, pixel-space radius math for body shaping, and a richer body-frost composite tuned to subdue the backdrop more while preserving the authored overlay/rim/inner-line split. QA and audit are still pending.

**Reference Check:** `REF-05`, `REF-07`, `REF-08`, `REF-09`, `REF-10`, and `REF-11` were addressed in the implementation pass. `REF-06` was intentionally left unchanged.

**Commits:**
- `ab34189` - Fix hybrid glass body radius and frost pass

**Lessons Learned:** The body/shell mismatch was a silhouette ownership problem first and a tuning problem second; once the authored mask became the only clip truth, frost tuning could happen without fighting geometry drift.

---

*Drafted on 2026-05-13*
