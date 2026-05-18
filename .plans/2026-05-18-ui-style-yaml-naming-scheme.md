# AeroBeat UI Kit Community — UI Style YAML Naming Scheme

**Date:** 2026-05-18  
**Status:** Draft  
**Agent:** Cookie 🍪

---

## Goal

Define a clean naming scheme and YAML-based config approach for UI style/effect resources so panel, badge, button, and related effects can have independent schemas and grow in complexity without cross-coupling.

---

## Overview

Derrick wants to move away from shared mutable style state and toward effect-specific configuration that is easier to reason about, easier to comment, and easier to evolve. The key architectural choice already settled in discussion is: do not force a universal schema too early. Instead, each script/shader/material effect should own its own YAML shape, loader, and config object, while still sharing lower-level shader/helper infrastructure where that actually makes sense.

The immediate work is design-oriented: choose naming conventions for classes/resources/loaders/files and define how YAML should map onto effect-specific config objects. A likely direction is names like `AeroUiPrimaryButton`, `AeroUiPanel`, and related effect-scoped loaders/resources, but the plan should pressure-test whether those names should refer to runtime views, config resources, loaders, or style/effect bundles so the system stays consistent instead of ambiguous.

Because this affects future UI architecture, the design should be explicit about separation of concerns: runtime view/component names, config resource names, loader/parser names, and preset file names should each follow a predictable pattern. The result should be a concrete proposal Derrick can review before implementation.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Current shared panel source scene | `.testbed/scenes/glass-shader-panel-source.tscn` |
| `REF-02` | Current shared panel source script | `.testbed/scripts/glass_shader_panel_source.gd` |
| `REF-03` | Preset split planning/history for hybrid defaults | `.plans/2026-05-18-hybrid-default-preset-v1-v2-split.md` |
| `REF-04` | Prior discussion direction: unique per-effect config instead of one universal schema | Current chat context |

---

## Tasks

### Task 1: Audit current naming/config pressure points and propose naming axes

**Bead ID:** `aerobeat-ui-kit-community-1uk`  
**SubAgent:** `primary` (for `research` workflow role)  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, inspect the current panel/button/badge script organization and propose a naming scheme for effect-specific YAML configs. Clarify naming for runtime component classes, config resource classes, loader/parser classes, preset files, and any inheritance/variant naming. Evaluate example names like `AeroUiPrimaryButton`, `AeroUiPanel`, etc., and recommend a consistent convention.

**Folders Created/Deleted/Modified:**
- optional `.temp/`

**Files Created/Deleted/Modified:**
- `.temp/aerobeat-ui-kit-community-1uk-research-notes.md`

**Status:** ✅ Complete

**Results:** Research concluded that the naming problem should be treated as four distinct domains so runtime classes, config objects, loaders, and preset files stop colliding. The strongest recommendation is to keep runtime composites ending in `View`, typed YAML-derived objects ending in `Config`, and file entrypoints ending in `ConfigLoader`, while avoiding ambiguous bare names like `AeroUiPanel`. Example preferred names include `AeroUiGlassPanelView`, `AeroUiPrimaryButton`, `AeroUiGlassPanelConfig`, `AeroUiPrimaryButtonConfig`, and `AeroUiPrimaryButtonConfigLoader`. Notes were written to `.temp/aerobeat-ui-kit-community-1uk-research-notes.md`.

---

### Task 2: Write the concrete YAML schema + naming proposal

**Bead ID:** `aerobeat-ui-kit-community-86m`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`, write a concrete proposal describing the naming scheme and YAML config architecture for effect-specific UI style/effect definitions. Include class/resource/loader/file naming, recommended folder structure, example YAML, and how effect-specific schemas should evolve independently.

**Folders Created/Deleted/Modified:**
- `docs/architecture/`

**Files Created/Deleted/Modified:**
- `docs/architecture/ui-style-yaml-config-architecture.md`

**Status:** ✅ Complete

**Results:** A durable proposal document was created at `docs/architecture/ui-style-yaml-config-architecture.md` and pushed to `main` in commit `865862c`. The proposal formalizes four separate naming domains — runtime classes, typed config objects, loaders, and preset files — and recommends explicit effect-qualified names such as `AeroUiGlassPanelView`, `AeroUiGlassPanelConfig`, and `AeroUiGlassPanelConfigLoader` instead of ambiguous bare names like `AeroUiPanel`. It also defines the intended use of `schema_version`, `variant`, `version`, and `extends`, recommends effect-family-first preset folders, and explains how to map the YAML approach onto the current `glass_shader_panel_source` world without forcing a premature universal schema.

---

### Task 3: QA the proposal for clarity and consistency

**Bead ID:** `aerobeat-ui-kit-community-iyd`  
**SubAgent:** `primary` (for `qa` workflow role)  
**Role:** `qa`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** Review the YAML naming/config proposal for clarity, consistency, and practical usability. Confirm whether the naming scheme clearly separates runtime classes, config resources, loaders, and preset files, and whether the per-effect-schema approach is documented clearly enough to implement safely later.

**Folders Created/Deleted/Modified:**
- `.temp/qa-evidence/`

**Files Created/Deleted/Modified:**
- `.temp/qa-evidence/aerobeat-ui-kit-community-iyd-qa-notes.md`

**Status:** ✅ Complete

**Results:** QA approved the proposal. Review confirmed that the architecture doc clearly separates runtime classes, config objects, loaders, and preset files; documents the per-effect-schema approach clearly enough to implement later; uses effect-qualified names like `AeroUiGlassPanelView`, `AeroUiGlassPanelConfig`, and `AeroUiGlassPanelConfigLoader` consistently; and defines `schema_version`, `variant`, `version`, and `extends` with distinct, non-contradictory responsibilities. QA’s only non-blocking note is that earlier plan/research notes still mention a shorter runtime name like `AeroUiPrimaryButton`, while the final proposal standardizes on more explicit effect-qualified names like `AeroUiGlassPrimaryButtonView`.

---

### Task 4: Audit the proposal

**Bead ID:** `aerobeat-ui-kit-community-e1r`  
**SubAgent:** `primary` (for `auditor` workflow role)  
**Role:** `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** Independently audit the final YAML naming/config proposal. Confirm it aligns with Derrick’s preference for per-effect schemas, supports comments/readability via YAML, and avoids the ambiguity/coupling problems seen in the current style approach.

**Folders Created/Deleted/Modified:**
- optional audit notes

**Files Created/Deleted/Modified:**
- optional audit notes if needed

**Status:** ⏳ Pending

**Results:** Pending.

---

## Final Results

**Status:** ⏳ Pending

**What We Built:** Pending execution.

**Reference Check:** Pending execution.

**Commits:**
- Pending

**Lessons Learned:** Pending execution.

---

*Drafted on 2026-05-18*
