# UI Style YAML Naming + Config Architecture Proposal

**Status:** Proposed  
**Date:** 2026-05-18

## Goal

Define a naming scheme and YAML config architecture for effect-specific UI style definitions so runtime views, typed config objects, loaders, and preset files can evolve independently without collapsing into one universal schema too early.

## Core decision

Treat these as **separate naming domains**:

1. **Runtime classes** — scene-backed Controls and composites used at runtime
2. **Config objects** — typed Godot-side objects/materialized data derived from YAML
3. **Loaders** — file entrypoints that validate, migrate, normalize, and build typed config objects
4. **Preset files** — authored YAML files on disk

That separation is the main guardrail. It prevents names like `AeroUiPanel` from becoming ambiguous between a runtime widget, a config resource, a file format, and a loader.

---

## Recommended naming scheme

### 1) Runtime classes

**Rule:** runtime composites end in `View`.

Use:
- `AeroUiGlassPanelView`
- `AeroUiGlassBadgeView`
- `AeroUiGlassPrimaryButtonView`

If a class is a true reusable interactive control rather than a larger composite view, it may omit `View` only when the role is unambiguous and the team wants that pattern consistently across runtime controls. For this UI-style work, the safest default is still to keep the effect-qualified composite name with `View`.

Recommended runtime pattern:
- `AeroUi<Effect><Component>View`
- optional semantic specialization before `View`

Examples:
- `AeroUiGlassPanelView`
- `AeroUiGlassBadgeView`
- `AeroUiGlassPrimaryButtonView`
- `AeroUiSolidPrimaryButtonView` if a second effect family exists later

Why:
- `View` clearly means "runtime assembled object in a scene tree"
- `Glass` makes the effect family explicit
- `PrimaryButton` vs `Badge` vs `Panel` keeps component contracts separate

### 2) YAML-derived typed objects

**Rule:** typed objects derived from YAML end in `Config`.

Use:
- `AeroUiGlassPanelConfig`
- `AeroUiGlassBadgeConfig`
- `AeroUiGlassPrimaryButtonConfig`

Recommended config pattern:
- `AeroUi<Effect><Component>Config`

Why:
- the type name tells you the schema contract immediately
- it avoids config/runtime name collisions
- it allows panel, badge, and button schemas to differ without pretending they are interchangeable

### 3) File entrypoints / loaders

**Rule:** file entrypoints/loaders end in `ConfigLoader`.

Use:
- `AeroUiGlassPanelConfigLoader`
- `AeroUiGlassBadgeConfigLoader`
- `AeroUiGlassPrimaryButtonConfigLoader`

Recommended loader pattern:
- `AeroUi<Effect><Component>ConfigLoader`

Why:
- the public job is not just YAML parsing
- loaders should own schema validation, defaults, migration, normalization, and `extends` resolution
- `ConfigLoader` is clearer than a vague `PresetIO` or `Parser`

### 4) Preset files

**Rule:** preset files are lowercase and path-oriented, not class-oriented.

Use names like:
- `default.yaml`
- `frosted.yaml`
- `frosted.v2.yaml`
- `cta.yaml`
- `quiet.yaml`

Why:
- files should communicate authored variant identity, not duplicate code type names
- version suffixes belong to authored preset evolution, not runtime class names

---

## Recommended folder structure

Use **effect family first**, then component family, then variants.

```text
ui/
  configs/
    loaders/
      aero_ui_glass_panel_config_loader.gd
      aero_ui_glass_badge_config_loader.gd
      aero_ui_glass_primary_button_config_loader.gd
    types/
      aero_ui_glass_panel_config.gd
      aero_ui_glass_badge_config.gd
      aero_ui_glass_primary_button_config.gd
  views/
    aero_ui_glass_panel_view.gd
    aero_ui_glass_badge_view.gd
    aero_ui_glass_primary_button_view.gd
  presets/
    glass/
      panel/
        default.yaml
        frosted.yaml
        frosted.v2.yaml
      badge/
        default.yaml
        status.yaml
      button/
        primary/
          default.yaml
          cta.yaml
          cta.v2.yaml
```

### Why this structure

- `glass/` groups an effect family without forcing badge/button/panel into one schema
- `panel/`, `badge/`, and `button/primary/` remain separate contracts
- loaders/types/views live in code-land, presets live in authored-data land
- future families like `solid/`, `neon/`, or `outline/` can be added without redesigning the tree

### Optional target split when contracts truly diverge

If 2D and hybrid/world-space definitions become meaningfully different contracts, split under the component folder instead of polluting every class name:

```text
ui/presets/glass/panel/2d/default.yaml
ui/presets/glass/panel/hybrid/default.yaml
```

Only do this when the schema itself differs enough to justify separate loaders or config branches.

---

## Schema philosophy

Do **not** force one universal `AeroUiStyleConfig` schema.

Instead:
- `AeroUiGlassPanelConfig` owns panel-related fields
- `AeroUiGlassBadgeConfig` owns badge-related fields
- `AeroUiGlassPrimaryButtonConfig` owns button-related fields
- shared lower-level shapes may still exist for common substructures if they are actually shared in practice

Good examples of reusable substructures:
- color/tint blocks
- border tokens
- shadow blocks
- state overrides
- shader parameter maps

Bad idea right now:
- one giant universal object trying to describe every panel, badge, button, shader, and world-space edge case in one file format

---

## Recommended YAML envelope

Every effect-specific YAML file should have a small common envelope, then a schema-specific body.

### Shared top-level fields

```yaml
schema: aero.ui.glass_panel
schema_version: 1
variant: frosted
version: v1
extends: glass/panel/default
```

### Field guidance

#### `schema`
- Identifies the contract family
- Recommended values:
  - `aero.ui.glass_panel`
  - `aero.ui.glass_badge`
  - `aero.ui.glass_primary_button`
- Use this to route files to the right loader

#### `schema_version`
- Version of the **loader contract**, not the art direction
- Bump only when parsing/validation/field-shape compatibility changes
- Example: renaming `shader` to `glass_shader`, or changing a scalar field into a nested object

#### `variant`
- Human-meaningful preset identity within a schema
- Examples: `default`, `frosted`, `status`, `cta`, `quiet`
- This is what designers and implementers discuss most of the time

#### `version`
- Revision of the authored preset within the same schema/version family
- Use values like `v1`, `v2`, `v3`
- Good for durable preset evolution and migration history
- Does **not** replace `schema_version`

#### `extends`
- Inheritance from another preset of the **same schema family**
- Use for override layering, not cross-component composition
- Good:
  - badge preset extends another badge preset
  - panel preset extends another panel preset
- Bad:
  - button preset extends a panel preset directly

### Inheritance rule

`extends` should resolve within the same schema family. If you need shared data across panel, badge, and button, put that shared data into a nested common block or a reusable token file handled explicitly by the loader. Do not fake cross-schema inheritance.

---

## Example YAML — panel

```yaml
schema: aero.ui.glass_panel
schema_version: 1
variant: default
version: v1
extends: null

layout:
  min_size: [420, 220]
  content_padding: [24, 20, 24, 20]
  corner_radius: 0.24

shader:
  blur: 4.2
  warp_intensity: 0.45
  strength_x: 14.0
  strength_y: 14.0
  offset_x: 0.03
  offset_y: 0.0
  edge_width: 2.4
  edge_smoothness: 1.1
  chromatic_strength: 2.2
  tint: { r: 0.92, g: 0.96, b: 1.0, a: 0.22 }
  edge_highlight: { r: 1.0, g: 1.0, b: 1.0, a: 0.62 }

shell:
  frame_alpha_boost: 0.18
  frame_fill_alpha: 0.08
  inner_border_alpha: 0.20

presentation:
  targets:
    source_2d:
      enabled: true
    hybrid_world:
      enabled: true
      inner_border_brightness: 1.0
      inner_border_alpha: 0.312
```

### Typed destination
- `AeroUiGlassPanelConfig`
- loaded by `AeroUiGlassPanelConfigLoader`
- consumed by `AeroUiGlassPanelView`

---

## Example YAML — badge

```yaml
schema: aero.ui.glass_badge
schema_version: 1
variant: status
version: v1
extends: glass/badge/default

badge:
  text_transform: uppercase
  padding: [10, 6, 10, 6]
  corner_radius_px: 14

surface:
  fill: { r: 1.0, g: 1.0, b: 1.0, a: 0.08 }
  border: { r: 1.0, g: 1.0, b: 1.0, a: 0.14 }
  border_width: 1

label:
  color: { r: 1.0, g: 1.0, b: 1.0, a: 0.78 }
  font_weight: semibold

presentation:
  hybrid_world:
    fill_alpha: 0.18
    border_alpha: 0.267
    label_alpha: 0.9
```

### Typed destination
- `AeroUiGlassBadgeConfig`
- loaded by `AeroUiGlassBadgeConfigLoader`
- consumed by `AeroUiGlassBadgeView`

---

## Example YAML — primary button

```yaml
schema: aero.ui.glass_primary_button
schema_version: 1
variant: cta
version: v2
extends: glass/button/primary/default

button:
  min_height: 56
  content_padding: [18, 14, 18, 14]
  corner_radius_px: 19

label:
  text_alpha: 0.95
  hover_text_alpha: 0.99
  active_tint: { r: 0.4, g: 0.82, b: 1.0, a: 1.0 }

meta:
  text_alpha: 0.66
  hybrid_text_alpha: 0.70

surface:
  base_fill_alpha: 0.08
  base_border_alpha: 0.14
  border_width: 2

states:
  source_2d:
    rest:
      fill_delta: 0.13
      border_delta: 0.38
    hover:
      fill_delta: 0.17
      border_delta: 0.46
    pressed:
      fill_delta: 0.22
      border_delta: 0.54

  hybrid_world:
    rest:
      fill_delta: 0.20
      border_delta: 0.39
      shadow_alpha: 0.18
      shadow_size: 10
    hover:
      fill_delta: 0.25
      border_delta: 0.46
      shadow_alpha: 0.24
      shadow_size: 12
    pressed:
      fill_delta: 0.31
      border_delta: 0.50
      shadow_alpha: 0.28
      shadow_size: 12
```

### Typed destination
- `AeroUiGlassPrimaryButtonConfig`
- loaded by `AeroUiGlassPrimaryButtonConfigLoader`
- consumed by `AeroUiGlassPrimaryButtonView`

---

## Mapping from the legacy `glass_shader_panel_source` world

The runtime/view migration is now materially in place:

- `.testbed/ui/views/aero_ui_glass_panel_view.gd` is the canonical **runtime composite/controller**
- `.testbed/ui/views/aero_ui_glass_badge_view.gd` is the canonical badge runtime/view
- `.testbed/ui/views/aero_ui_glass_primary_button_view.gd` is the canonical primary-button runtime/view
- `.testbed/scripts/aero_ui_glass_yaml_bundle_io.gd` is the active **YAML bundle import/export helper**
- authored defaults and manual save/load now live in the YAML preset family under `res://ui/presets/glass/...`
- `.testbed/scripts/glass_shader_panel_source.gd` and `.testbed/scenes/glass-shader-panel-source.tscn` now exist only as compatibility aliases over the canonical panel view

### Current mapping

#### Canonical runtime ownership
- `AeroUiGlassPanelView` owns panel runtime composition and YAML-backed config application
- `AeroUiGlassBadgeView` owns badge rendering/state application
- `AeroUiGlassPrimaryButtonView` owns primary-button rendering/state application

#### Compatibility surface
Keep the legacy `glass_shader_panel_source` script/scene path only for downstream references that have not been retired yet.

#### Config composition
The panel runtime can still compose separate authored data responsibilities into distinct config objects without collapsing them back into one legacy runtime surface.

Example conceptual split:
- `AeroUiGlassPanelConfig`
  - shared glass shader + panel shell + presentation target settings
- `AeroUiGlassBadgeConfig`
  - badge fill/border/label tokens
- `AeroUiGlassPrimaryButtonConfig`
  - action body, state deltas, text/meta emphasis

The runtime view can still compose all three.

### Important constraint

This proposal does **not** require one universal file that contains panel + badge + button forever.

Two valid implementation paths:

#### Path A — separate files
- panel YAML loads panel config
- badge YAML loads badge config
- button YAML loads button config
- the view composes them explicitly

#### Path B — panel-owned bundle with nested references
- panel YAML remains the entrypoint
- it references badge/button presets by path or preset id
- loaders materialize the nested config objects separately

Either path is acceptable. The important part is that the **schemas remain distinct**, even if a parent preset references multiple children.

### Example bundle style without universal schema pressure

```yaml
schema: aero.ui.glass_panel
schema_version: 1
variant: primary_card
version: v1

parts:
  badge_preset: glass/badge/status
  primary_button_preset: glass/button/primary/cta
```

This keeps `aero.ui.glass_panel` as the panel contract while allowing composition of other effect-specific contracts.

---

## Loader responsibilities

Each `ConfigLoader` should do more than decode YAML.

### Minimum responsibilities
- verify `schema`
- verify `schema_version`
- resolve `extends`
- merge inherited values predictably
- validate field types and required sections
- normalize defaults
- reject unknown dangerous fields or record them intentionally
- return a typed `Config` object, not just a raw `Dictionary`

### Shared helper allowed
A low-level shared helper is fine, for example:
- `AeroUiYamlConfigDocumentLoader`
- `AeroUiYamlMergeUtils`

But do not make that helper the public contract for all effect families. The public entrypoints should still be schema-specific loaders.

### Current implementation note for the first seam

The first live seam in this repo is intentionally narrower than the full target architecture:

- the canonical runtime now lives under `ui/views/`, while `glass_shader_panel_source.gd` is retained only as a legacy compatibility script path
- the panel YAML preset is the current bundle entrypoint and composes badge/button typed configs rather than making the compatibility layer the authored-style owner
- the current YAML helper only supports the subset needed by these presets (mapping-root documents, nested mappings, inline arrays/dictionaries, scalar values, comments, and same-schema `extends`)
- broader loader productization work is still deferred, including unknown-field rejection, deeper schema validation, migration helpers, and richer YAML feature support

That is acceptable for the current seam because the main architectural rule already holds: canonical runtime composition, typed configs, schema-specific loaders, and authored preset files are separate concerns, and the remaining legacy path is compatibility-only rather than the conceptual owner.

---

## Pitfalls to avoid

### 1) Ambiguous bare names
Avoid:
- `AeroUiPanel`
- `AeroUiBadge`
- `AeroUiPrimaryButton` as both runtime and config type names

Prefer:
- `AeroUiGlassPanelView`
- `AeroUiGlassPanelConfig`
- `AeroUiGlassPanelConfigLoader`

### 2) One universal style schema too early
Avoid a giant object like:
- `AeroUiStyleConfig`

That path usually produces optional-field soup and unclear ownership.

### 3) Mixing schema version with art revision
Avoid treating these as synonyms:
- `schema_version: 2`
- `version: v2`

They solve different problems.

### 4) Cross-schema inheritance through `extends`
Avoid:
- button extends panel
- badge extends button

Use composition or nested references instead.

### 5) Forcing rendering target into every name
Avoid names like:
- `AeroUiGlassPanelHybridWorldSpacePrimaryVariantConfig`

Only encode target in the type name if it is truly a different contract. Prefer target-specific sections in the YAML body first.

### 6) Using preset filenames as the primary source of schema truth
The loader should trust `schema` and `schema_version`, not only path shape.

---

## Recommended default decisions

If the repo starts implementing this architecture, the safest defaults are:

- runtime composites end in `View`
- YAML-derived typed objects end in `Config`
- file entrypoints/loaders end in `ConfigLoader`
- effect family comes before component family in preset folders
- `schema_version` tracks loader compatibility only
- `variant` names the look/role humans talk about
- `version` tracks authored preset revisions
- `extends` stays within the same schema family
- composition is preferred over cross-schema inheritance

---

## Concrete recommendation summary

### Use these names as the baseline
- `AeroUiGlassPanelView`
- `AeroUiGlassPanelConfig`
- `AeroUiGlassPanelConfigLoader`
- `AeroUiGlassBadgeView`
- `AeroUiGlassBadgeConfig`
- `AeroUiGlassBadgeConfigLoader`
- `AeroUiGlassPrimaryButtonView`
- `AeroUiGlassPrimaryButtonConfig`
- `AeroUiGlassPrimaryButtonConfigLoader`

### Use these folder roots
- `ui/views/`
- `ui/configs/types/`
- `ui/configs/loaders/`
- `ui/presets/glass/...`

### Use this architectural stance
- separate naming domains
- separate effect-specific schemas
- shared helpers only where they are truly shared
- composition allowed, universal schema not required

That gives the project a durable path forward from the current `glass_shader_panel_source` setup without painting future UI effects into one giant schema corner.