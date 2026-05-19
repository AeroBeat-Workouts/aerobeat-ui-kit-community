# Glass UI YAML seam notes

This folder holds the first narrow YAML-backed seam for the glass UI family.

## Current ownership split

- `res://ui/views/aero_ui_glass_panel_view.gd` / `res://ui/views/aero_ui_glass_panel_view.tscn` are now the canonical panel runtime/view owner described in the architecture docs.
- The canonical panel view composes and applies typed config objects into the existing scene/material tree.
- `res://scripts/glass_shader_panel_source.gd` and `res://scenes/glass-shader-panel-source.tscn` remain only as transitional compatibility aliases over the canonical panel view while older paths are retired.
- Authored style ownership now lives in YAML preset files plus the schema-specific config loaders/types under `res://ui/configs/`.
- The panel preset at `res://ui/presets/glass/panel/default.yaml` is the current entrypoint and may reference badge and primary-button presets through `parts`.

## Current loader / YAML subset limits

The current implementation is intentionally narrow and only supports the subset needed by the first seam:

- a single YAML document whose root is a mapping
- indentation-based nested mappings
- inline dictionaries like `{ r: 1.0, g: 1.0, b: 1.0, a: 0.5 }`
- inline arrays like `[a, b, c]`
- quoted or unquoted scalar values, plus booleans / `null` / numbers
- comments introduced with `#`
- same-schema `extends` chains resolved by schema-specific loaders

Not supported yet:

- block list syntax (`- item`)
- anchors / aliases / tags
- multiline scalars
- multi-document YAML
- generalized schema hardening beyond the first seam's explicit checks

## Current validation stance

- Schema-specific loaders currently enforce `schema`, `schema_version`, recursion safety, and same-schema-only `extends`.
- Unknown fields are not broadly rejected yet; fields only matter when a schema-specific loader reads them.
- Deeper schema validation, migration helpers, and stricter unknown-field handling are intentionally deferred until the repo has more authored preset pressure.

## Explicitly deferred follow-up work

- removing the remaining legacy `glass_shader_panel_source` compatibility wrapper/scene aliases once downstream callers no longer need them
- broader loader hardening and migration helpers
- layout metrics migration from `.tscn` into YAML
- human visual/workflow review of the extracted panel/button/badge runtime stack
- broader hybrid/world-space migration
