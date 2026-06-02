# AeroBeat UI Kit Community

**Date:** 2026-05-20  
**Status:** Stale  
**Agent:** Cookie 🍪

---

## Goal

Stabilize the Screen 2D info/debug panel so interaction updates do not cause visible text reflow or checkbox-width jitter.

---

## Overview

Derrick’s latest feedback is about layout stability rather than interaction correctness. The current info panel is too narrow, so changing runtime text causes the content to wrap and jump between lines. That makes the panel feel unstable during hover/press testing even when the underlying interaction state is correct.

There is a second alignment issue in the checkbox rows: checked vs unchecked states do not occupy the same visual width, so toggling them shifts nearby text. This slice should make the panel feel visually locked in place during state changes by widening the info panel and normalizing checkbox layout so state toggles do not push labels around.

This pass should preserve the recently landed good behavior: minimal input debug readout, proper hover-exit reset, larger section spacing, distinct hover vs pressed behavior, shared `TweenAlpha()` support, and the higher-level child fanout/controller path.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Screen 2D testing scene / info panel layout script | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/.testbed/scripts/glass_shader_test.gd` |
| `REF-02` | Latest active follow-up plan covering hover-exit/warning cleanup baseline | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/.plans/2026-05-20-screen-2d-glass-ui-feedback-pass-followup.md` |

---

## Tasks

### Task 1: Stabilize info panel width and checkbox row layout

**Bead ID:** `aerobeat-ui-kit-community-29w`  
**SubAgent:** `primary` (for `coder`)  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`  
**Prompt:** Implement the 2026-05-20 info-panel layout stability pass in `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community` against bead `aerobeat-ui-kit-community-29w`. Claim the bead on start with `bd update aerobeat-ui-kit-community-29w --status in_progress --json`. Increase the width of the Screen 2D info/debug panel enough that the current runtime text no longer jumps between lines during interaction updates. Also fix checkbox row layout so checked vs unchecked states occupy stable width and do not push adjacent text around when toggled. Preserve the current minimal input debug readout and the rest of the recent AeroUiGlass interaction improvements. Add/update tests if appropriate, run relevant validation, commit/push to `main` by default, and leave a concise handoff.

**Folders Created/Deleted/Modified:**
- `.testbed/scripts/`
- `.testbed/tests/ui/`

**Files Created/Deleted/Modified:**
- `.testbed/scripts/glass_shader_test.gd`
- any directly related UI test files needed for coverage

**Status:** ⏳ Pending

**Results:** Not started.

---

### Task 2: QA layout stability under live state changes

**Bead ID:** `aerobeat-ui-kit-community-u8n`  
**SubAgent:** `primary` (for `qa`)  
**Role:** `qa`  
**References:** `REF-01`, `REF-02`  
**Prompt:** QA the info-panel layout stability pass on bead `aerobeat-ui-kit-community-u8n` after coder handoff. Claim the bead on start with `bd update aerobeat-ui-kit-community-u8n --status in_progress --json`. Verify in the highest-fidelity path available that the info/debug panel text no longer wraps/jumps during interaction updates and that checkbox state changes no longer push nearby text around. Confirm the minimal input debug readout still works and prior hover/pressed behavior remains intact.

**Folders Created/Deleted/Modified:**
- `.testbed/`
- `.temp/qa-evidence/` (if needed)

**Files Created/Deleted/Modified:**
- QA evidence artifacts only if needed

**Status:** ⏳ Pending

**Results:** Not started.

---

### Task 3: Audit the layout stability pass

**Bead ID:** `aerobeat-ui-kit-community-e6y`  
**SubAgent:** `primary` (for `auditor`)  
**Role:** `auditor`  
**References:** `REF-01`, `REF-02`  
**Prompt:** Audit the info-panel layout stability pass on bead `aerobeat-ui-kit-community-e6y` after QA. Claim the bead on start with `bd update aerobeat-ui-kit-community-e6y --status in_progress --json`. Independently truth-check that the info/debug panel no longer jumps due to wrapping and that checkbox toggles no longer shift nearby text, while preserving the recent interaction-state improvements.

**Folders Created/Deleted/Modified:**
- repo inspection only

**Files Created/Deleted/Modified:**
- none expected unless audit evidence is added

**Status:** ⏳ Pending

**Results:** Not started.

---

## Final Results

**Status:** ⏳ Pending

**What We Built:** Pending execution.

**Reference Check:** Pending execution.

**Commits:**
- Pending

**Lessons Learned:** Pending execution.

---

*Completed on Pending*
