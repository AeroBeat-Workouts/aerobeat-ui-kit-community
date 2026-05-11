# Glass Shader Usage Guide

This repo includes a Godot testbed for a screen-sampling “glass” UI treatment. This guide explains the pattern that is actually implemented here, how to build new 2D UI from it, how to verify that the effect is really working, and how to adapt the same ideas for 3D-facing panels without pretending this repo already ships a finished 3D version.

## Source of truth in this repo

Use these files as the canonical reference before copying the effect elsewhere:

- `.testbed/scenes/glass-shader-test.tscn` — the working test scene and node hierarchy
- `.testbed/scripts/glass_shader_test.gd` — live tuning UI, background mode switching, and shell/frame sync logic
- `.testbed/scripts/glass_debug_backdrop.gd` — the debug backdrop used to make blur and refraction obvious
- `.testbed/assets/shaders/glass-shader.gdshader` — the shader itself
- `.testbed/project.godot` — opens the hidden testbed project and currently launches the glass test scene

## Quick start

If you just want a working starting point, do this:

1. Open the hidden testbed:
   ```bash
   godot --editor --path .testbed
   ```
2. Open `.testbed/scenes/glass-shader-test.tscn`.
3. Copy the `PreviewButton` subtree if you want the same 2D pattern.
4. Keep this structure:
   - a flat parent `Button`
   - a child `ColorRect` that fills the button and holds the `ShaderMaterial`
   - separate overlay shell nodes for the outer bevel/frame and inner outline
5. Run the scene and switch `preview_background` to `Debug pattern` or `Hybrid overlay`.
6. Tune `blur`, `warp_intensity`, `strength_x`, and `strength_y` while watching the background *through* the plate, not just the border styling.

If those parameters visibly change the background inside the glass plate, the real effect is alive.

## What is actually implemented here

The implemented 2D pattern is not “put the shader directly on a button and call it done.” The current working structure is:

- `PreviewButton` (`Button`)
  - `flat = true`
  - button theme states replaced with `StyleBoxEmpty`
  - acts as the interaction host and layout box
- `GlassFill` (`ColorRect`)
  - stretched to fill the button
  - owns the `ShaderMaterial`
  - is the actual screen-sampling glass layer
- `PreviewFrame` (`Panel`)
  - outer bevel/highlight shell
- `InnerBorderInset` + `PreviewInnerBorder` (`Panel`)
  - inner outline shell
- content nodes on top
  - badge, title, body text, hint text

That layering matters. The glass effect is created by the child `ColorRect` sampling the screen beneath it. The button itself stays visually flat and mostly exists so the control behaves like a normal Godot UI element.

## Build a new 2D glass control from scratch

### 1) Create the interaction host

Create a `Button` or another `Control` that will define the panel size.

For a clickable element, follow the repo’s pattern:

- use a `Button`
- set `flat = true`
- replace `normal`, `hover`, `pressed`, `focus`, and `disabled` styleboxes with `StyleBoxEmpty`
- keep text/content in child controls instead of relying on the button’s built-in chrome

This is what `glass_shader_test.gd` does in `_configure_preview_button()`.

### 2) Add the shader layer as a child `ColorRect`

Inside the host control, add a `ColorRect` that fills the parent:

- anchors preset: full rect
- `mouse_filter = Ignore`
- assign a `ShaderMaterial`
- point it at `.testbed/assets/shaders/glass-shader.gdshader`

This `ColorRect` is the true glass plate.

### 3) Add the shell overlays

Add separate shell nodes above the shader layer:

- outer frame/bevel panel
- inset inner border panel

In this repo, those use `StyleBoxFlat` resources instead of baking every visual detail into the shader. That split is intentional:

- shader handles blur/refraction/tint/highlight response
- shell panels handle readable bevel/outline structure

### 4) Add content on top

Put labels, badges, icons, and layout containers above the shell layers. Keep them separate from the shader node so the glass stays a background treatment for the control, not the text itself.

### 5) Sync corner treatment with the shader

If you expose `corner_radius`, do not hardcode a shell radius unrelated to the shader. In this repo, `_sync_preview_shell()` converts the normalized shader radius into pixel radii derived from actual control size.

That is required for parity between:

- `GlassFill` shader mask
- `PreviewFrame`
- `PreviewInnerBorder`

## Live-tuning workflow in this repo

The intended workflow is the testbed scene, not blind asset editing.

1. Open `.testbed/scenes/glass-shader-test.tscn`.
2. Run the scene.
3. Use the left-side control rail built by `.testbed/scripts/glass_shader_test.gd`.
4. Change one parameter at a time.
5. Verify the result against `Debug pattern` and `Hybrid overlay` modes.
6. Once the glass behavior is correct, evaluate whether it still looks good against the AeroBeat image background.

Why this matters:

- the image background is good for taste and composition
- the debug background is good for truth
- hybrid mode is good for confirming the effect still reads over a more realistic art backdrop

## Preview background modes and why they matter

The testbed exposes three preview modes:

### AeroBeat image

Uses the background image only.

Use this for:

- final presentation feel
- checking whether the glass fits the AeroBeat palette
- judging the full composition

Do **not** rely on this mode alone to decide whether blur/refraction is working. Some images are too forgiving and can hide weak distortion.

### Debug pattern

Uses the scripted backdrop from `.testbed/scripts/glass_debug_backdrop.gd`.

Use this for:

- verifying blur really softens the background
- verifying warp/refraction really bends visible lines and blocks
- verifying `strength_x` and `strength_y` are changing the interior distortion profile

This is the best truth-check mode because it contains bands, checker cells, diagonals, circles, and hard-edged blocks that make distortion obvious.

### Hybrid overlay

Shows the AeroBeat image plus the debug pattern overlay.

Use this for:

- checking realism and legibility together
- confirming the effect survives over a textured/art-directed background
- catching cases where the shader technically works in debug mode but becomes too subtle in production-looking art

## Parameter guide

These descriptions are grounded in the current shader and testbed.

### `blur`

Controls mip-based blur on the sampled background.

- lower values keep the background sharper
- higher values frost the background more strongly
- easiest to judge in `Debug pattern` mode

Recommended starting point from the scene: `4.2`

### `warp_intensity`

Controls how strongly the sampled background is displaced.

- lower values feel flatter/calmer
- higher values create more obvious bulging/refraction
- if this looks dead, verify layering first

Recommended starting point: `0.45`

### `strength_x`

Controls the horizontal concentration profile of the warp.

- changing it alters how the distortion distributes across the X axis
- strong differences are easiest to see against vertical lines or hard-edged blocks

Recommended starting point: `14.0`

### `strength_y`

Controls the vertical concentration profile of the warp.

- this was specifically repaired in this repo so it produces meaningful visible change
- compare low and high values in `Debug pattern` or `Hybrid overlay`
- look for the distortion changing across the plate interior, not just edge styling

Recommended starting point: `14.0`

### `corner_radius`

Normalized radius value for the glass shape.

- `0.0` = square corners
- `1.0` = maximum roundness allowed by the control size
- the script syncs frame and inner border radii to match this behavior

Recommended starting point: `0.24`

### `tint`

Color and opacity mixed over the sampled background.

- RGB sets the glass hue
- alpha sets the tint amount
- too much alpha can make the panel feel painted instead of glass

Recommended starting point: `Color(0.92, 0.96, 1.0, 0.22)`

### `edge_highlight`

Controls the bright edge contribution.

- use it to make the plate silhouette readable
- too much can turn the look into a stylized outline instead of subtle glass

Recommended starting point: `Color(1.0, 1.0, 1.0, 0.62)`

### `edge_width`

Controls the width of the shader edge highlight region.

- larger values make the edge treatment thicker
- the script also uses it when syncing the outer frame thickness

Recommended starting point: `2.4`

### Background mode selection

Pick the background mode based on what you are testing:

- use `Debug pattern` when validating actual glass/refraction behavior
- use `Hybrid overlay` when tuning toward shipping visuals without losing diagnostic contrast
- use `AeroBeat image` last, for final taste checks

## Major gotchas we found

### 1) Layering can make the shader look “alive” when it is not

The biggest failure mode was node layering. Earlier in the work, the shell/frame styling was visible while the actual screen-sampling layer was effectively hidden behind the stack. That made `corner_radius` and `tint` appear responsive, but `blur`, `warp_intensity`, `strength_x`, and `strength_y` looked weak or dead.

Rule: if the background beneath the plate is not visibly changing, the glass is not really working yet.

### 2) Always verify against a diagnostic background

A pretty art background can hide broken distortion. The debug backdrop exists because you need high-contrast lines, blocks, and shapes to tell whether the shader is really sampling and bending the image beneath it.

Rule: validate behavior in `Debug pattern`, then validate taste in `Hybrid overlay` / `AeroBeat image`.

### 3) `strength_y` needed a real repair

This repo specifically fixed a weak vertical-response problem. The shader now uses axis-normalized coordinates and per-axis distance shaping so `strength_y` changes are visible across the plate interior.

Rule: if vertical response seems too subtle again after future edits, inspect shader math before assuming the control is “good enough.”

### 4) Corner-radius parity is easy to get wrong

The shader uses normalized radius logic based on control size. Hardcoded frame radii will drift out of sync, especially near max roundness.

Rule: derive shell radii from actual control geometry using the same effective size-based logic as the shader.

### 5) Simpler shell treatment worked better here

This repo ended up with a simpler two-layer visible shell treatment:

- the inner glass rectangle / shader-backed fill with inner outline
- the outer bevel/frame

Extra shadow rectangles were removed on purpose.

Rule: let the shader and two clear shell layers do the work before adding more decorative layers.

## Recommended setup defaults for new 2D elements

If you are making a new element and want a safe starting point, begin near the current scene defaults:

- `blur = 4.2`
- `warp_intensity = 0.45`
- `strength_x = 14.0`
- `strength_y = 14.0`
- `corner_radius = 0.24`
- `tint = Color(0.92, 0.96, 1.0, 0.22)`
- `edge_highlight = Color(1.0, 1.0, 1.0, 0.62)`
- `edge_width = 2.4`

Then test in this order:

1. `Debug pattern`
2. `Hybrid overlay`
3. `AeroBeat image`

## Practical adaptation guidance for 3D-facing UI and panels

This repo does **not** contain a validated finished 3D implementation. The guidance below is adaptation advice based on the same ideas, not a claim that 3D panel support here is complete.

### What transfers well

The following concepts do transfer:

- a separate glass layer should sample or approximate the scene behind it
- a clear shell structure still matters for readability
- debug backgrounds / high-contrast verification are still necessary
- normalized corner and edge systems should stay consistent across the visible layers

### Likely Godot adaptation approaches

For 3D-facing panels in Godot, a practical direction is:

1. Build the panel content in 2D first, where this repo’s pattern is already proven.
2. Present that UI on a `SubViewport` or texture-backed surface if the panel must live in 3D space.
3. Recreate the glass shell as either:
   - a 2D glass layer within the viewport content, or
   - a 3D material/shader on the panel surface that samples the rendered scene or a captured background texture
4. Keep a separate shell/highlight treatment instead of asking a single material to solve all readability problems.
5. Test against geometric backgrounds with lines, blocks, and contrast changes before judging it on polished art.

### What not to overclaim

Do not document or present this repo as already shipping:

- a production 3D glass panel system
- validated 3D scene-refraction behavior
- a drop-in XR/mobile/web equivalent

Use this repo as the 2D source pattern and adaptation reference, not as evidence of finished 3D support.

## Suggested checklist when creating a new element

- [ ] Host control is flat and not fighting the shader with default button chrome
- [ ] Child `ColorRect` holds the `ShaderMaterial`
- [ ] Glass layer fills the full intended plate area
- [ ] Frame and inner border are separate overlay nodes
- [ ] Content sits above the glass, not inside the shader layer
- [ ] `Debug pattern` clearly shows blur and warp differences
- [ ] `strength_x` and `strength_y` both produce visible interior changes
- [ ] `corner_radius` stays aligned between shader, frame, and inner border
- [ ] `Hybrid overlay` still reads well over realistic art
- [ ] The final result still works with the simplified two-layer shell treatment

## Where to start if you want to copy this into a new scene

Start by duplicating or studying:

- the `PreviewButton` subtree in `.testbed/scenes/glass-shader-test.tscn`
- `_configure_preview_button()` in `.testbed/scripts/glass_shader_test.gd`
- `_sync_preview_shell()` in `.testbed/scripts/glass_shader_test.gd`
- the shader uniforms in `.testbed/assets/shaders/glass-shader.gdshader`

That combination is the shortest truthful path to building a new glass-flavored 2D control in this repo.
