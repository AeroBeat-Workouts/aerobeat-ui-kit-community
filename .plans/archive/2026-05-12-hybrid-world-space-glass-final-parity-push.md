# AeroBeat UI Kit Community — Hybrid World-Space Glass Final Parity Push

**Date:** 2026-05-12  
**Status:** Stale  
**Agent:** Byte 🐈‍⬛

---

## Goal

Push the hybrid world-space glass panel as close as truthfully possible to the successful 2D glass shader look, with the specific target of a denser, creamier, more uniformly frosted plate while preserving the now-correct 2D-authored + 3D world-aware architecture.

---

## Overview

The previous architecture and parity passes solved the important structural problems. The dead-end old hybrid path was replaced with a correct world-aware hybrid architecture, and the later polish pass materially fixed the ghost/blurry curved-edge rectangle artifact by moving to an authored-mask approach and a closer 2D-style warp field. QA and audit both agreed that this current version is a meaningful improvement and “close enough for that polish/debug slice,” but not yet a true visual match.

The remaining gap is now narrow and aesthetic rather than architectural. Derrick’s goal for this pass is to see whether we can actually reach the successful 2D look closely enough to call it optimal. The known remaining differences are also clear: the hybrid version still reads more transparent, more fresnel/specular-heavy, and more scene-reactive than the flatter, denser, creamier 2D card. So this pass should focus specifically on visual density, frosting uniformity, and tone/response balance rather than reopening mask ownership or authored-card bounds.

The right approach is to treat the current hybrid shader as the correct foundation and run one more tightly scoped parity push. That means investigating which parts of the current 3D response are overpowering the 2D look, implementing targeted tuning/behavior changes to reduce excessive transparency/rim dominance while strengthening the frosted body, then validating directly against the 2D reference scene. If exact parity still cannot be reached without sacrificing truthful 3D world-space behavior, the audit should say so clearly.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | 2D glass reference scene | `.testbed/scenes/glass-shader-test.tscn` |
| `REF-02` | Current hybrid world-space scene | `.testbed/scenes/glass-shader-gui-3d-test.tscn` |
| `REF-03` | Current hybrid world-space shader | `.testbed/assets/shaders/glass-panel-hybrid-3d.gdshader` |
| `REF-04` | Current hybrid controller script | `.testbed/scripts/glass_shader_gui_3d_test.gd` |
| `REF-05` | Shared panel source scene | `.testbed/scenes/glass-shader-panel-source.tscn` |
| `REF-06` | Shared panel source script | `.testbed/scripts/glass_shader_panel_source.gd` |
| `REF-07` | Architecture pass plan/results | `.plans/2026-05-12-hybrid-world-space-glass.md` |
| `REF-08` | Parity/artifact polish plan/results | `.plans/2026-05-12-hybrid-world-space-glass-parity-polish.md` |
| `REF-09` | Latest QA evidence for current hybrid parity state | `.temp/qa-evidence/` |
| `REF-10` | Latest parity-polish commit | `437cadf` |

---

## Tasks

### Task 1: Investigate the remaining visual-parity gap in the current hybrid shader

**Bead ID:** `aerobeat-ui-kit-community-7j7`  
**SubAgent:** `primary` (for `research` workflow role)  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-09`, `REF-10`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, inspect the current hybrid shader path and QA evidence, then diagnose what still keeps the world-space panel from matching the denser, creamier, more uniformly frosted feel of the 2D reference. Focus specifically on transparency/body density, fresnel/specular dominance, frosting uniformity, and scene-reactive behavior. Produce a tight recommendation for one final parity push that preserves the correct hybrid architecture.

**Folders Created/Deleted/Modified:**
- `.plans/` (notes/results only if needed)

**Files Created/Deleted/Modified:**
- optional investigation notes if needed

**Status:** ✅ Complete

**Results:** Diagnosis completed and confirmed that the remaining gap is no longer architectural. The current hybrid shader still leans too far toward transparency, fresnel/rim/specular read, and live scene reactivity, while not leaning far enough toward dense interior body fill, creamy flatter frost, and embedded UI-in-glass feel. The recommended final push is a tight shader-only rebalance: keep the current dual-SubViewport + authored-mask + world-aware pipeline, but strengthen interior body-frost/body-density fill, reduce `world_rim_refraction`, fresnel contribution, and rim/emission dominance, and flatten interior scene variation/chromatic punch-through before fine-tuning UI integration. The diagnosis also notes a real ceiling: exact parity may remain impossible because the 2D version is a controlled screen-space plate while the hybrid version truthfully refracts a live 3D world at changing angles. Diagnosis note written at `.temp/7j7-final-parity-gap-diagnosis.md`.

---

### Task 2: Implement the final parity-push changes while preserving world-aware behavior

**Bead ID:** `aerobeat-ui-kit-community-1x8`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`, `REF-06`, `REF-09`, `REF-10`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, push the current hybrid world-space glass panel as close as truthfully possible to the 2D reference look without backing out the now-correct architecture. Specifically target a denser, creamier, more uniformly frosted body; reduce excessive transparency and over-dominant fresnel/specular response; and preserve the authored-card mask plus real 3D world-aware interaction.

**Folders Created/Deleted/Modified:**
- `.testbed/scenes/`
- `.testbed/scripts/`
- `.testbed/assets/shaders/`

**Files Created/Deleted/Modified:**
- `.testbed/assets/shaders/glass-panel-hybrid-3d.gdshader`
- `.testbed/scripts/glass_shader_gui_3d_test.gd`

**Status:** ✅ Complete

**Results:** The final parity-push implementation landed and was pushed in commit `9fd4d1b` (`Rebalance final hybrid glass parity pass`). This was a shader-only/material-balance pass that preserved the existing architecture while rebalancing the hybrid glass toward a denser, milkier face. The shader gained stronger interior body-frost controls (`body_frost_strength`, `background_subdue`, `interior_chroma`), substantially stronger face/body alpha, reduced rim/fresnel/refraction/emission dominance, and reduced interior chromatic/live-scene punch-through. The hybrid controller script was updated to expose the new hybrid-only tuning controls/defaults and stop blindly mirroring 2D tint/chroma/edge defaults into the hybrid material while still passing through the useful authored warp/card-shape parameters. The coder’s honest conclusion was that this gets materially closer than `437cadf`, but still does not truthfully reach full near-parity with the best 2D card.

---

### Task 3: QA the final parity push against the 2D reference

**Bead ID:** `aerobeat-ui-kit-community-gqu`  
**SubAgent:** `primary` (for `qa` workflow role)  
**Role:** `qa`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-09`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, run the 2D reference and the updated hybrid world-space scene in Godot and determine whether this final push gets the hybrid version close enough to the 2D look to count as near-parity. Be explicit about whether the frosted body is denser/creamier, whether transparency/rim dominance is reduced, and what still differs if the match is still incomplete.

**Folders Created/Deleted/Modified:**
- `.testbed/`

**Files Created/Deleted/Modified:**
- QA evidence artifacts if produced

**Status:** ⏳ Pending

**Results:** Awaiting QA execution.

---

### Task 4: Audit whether true near-parity was achieved or whether the ceiling has been reached

**Bead ID:** `aerobeat-ui-kit-community-8or`  
**SubAgent:** `primary` (for `auditor` workflow role)  
**Role:** `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-07`, `REF-08`, `REF-09`, `REF-10`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, audit the final parity push independently. Decide whether the hybrid world-space scene now truthfully reaches near-parity with the 2D reference while preserving the correct architecture, or whether the remaining difference appears to be a genuine ceiling of this approach. If parity still falls short, state clearly whether further tuning is likely worthwhile.

**Folders Created/Deleted/Modified:**
- `.plans/` (notes/results only if needed)

**Files Created/Deleted/Modified:**
- optional audit notes if needed

**Status:** ⏳ Pending

**Results:** Awaiting audit execution.

---

## Final Results

**Status:** ⚠️ Partial

**What We Built:** Executed one final shader-only parity push on top of the already-correct hybrid world-space architecture. The current hybrid panel now has a denser, milkier frosted face with reduced transparency dominance, reduced fresnel/rim/specular pull, and calmer interior scene response compared with the prior parity-polish version. This preserves the authored-card mask, dual-SubViewport setup, and truthful 3D world-aware behavior while pushing the material balance closer to the 2D reference than earlier commits did.

**Reference Check:** `REF-01` through `REF-10` are satisfied for the intent of this slice as far as implementation goes: the pass targeted the exact remaining material-balance gap and preserved the correct architecture. The unresolved point is not implementation direction but final truth-testing: the coder judged that even after this push, exact or full near-parity still likely remains beyond the truthful ceiling of the world-aware hybrid approach.

**Commits:**
- `9fd4d1b` - Rebalance final hybrid glass parity pass

**Lessons Learned:** After the architecture, mask ownership, and distortion-field issues were solved, the remaining gap became almost entirely about material balance: whether the hybrid face reads primarily as a dense frosted body or as a reactive refractive lens. This pass confirms that the last meaningful gains come from subordinating live-world optics to the frosted body rather than from more structural changes. It also strongly suggests there is a real ceiling where truthful world-aware 3D glass simply will not look exactly like a controlled 2D screen-space plate at all angles.

---

*Updated on 2026-05-12*
