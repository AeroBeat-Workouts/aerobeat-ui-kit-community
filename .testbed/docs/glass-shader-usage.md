# Glass Shader Usage Guide

This repo supports two glass shader flows:

1. **2D frosted glass UI** — the canonical screen-space `CanvasItem` treatment used directly in the testbed UI.
2. **Hybrid 3D glass panel** — a world-space panel that composites authored 2D UI through the supported hybrid 3D shaders.

The older native-3D object glass proof has been removed on purpose. This guide documents only the supported paths that still exist in the repo.

## Source of truth in this repo

Use these files as the canonical references before copying the effect elsewhere.

### 2D frosted glass

- `.testbed/scenes/glass-shader-test.tscn` — working 2D test scene and node hierarchy
- `.testbed/scripts/glass_shader_test.gd` — live tuning UI, background mode switching, and shell/frame sync logic
- `.testbed/scripts/glass_debug_backdrop.gd` — diagnostic 2D backdrop for verifying blur and refraction
- `assets/shaders/glass-shader.gdshader` — the supported 2D glass shader

### Hybrid 3D glass panel

- `.testbed/scenes/glass-shader-gui-3d-test.tscn` — supported world-space hybrid panel proof scene
- `.testbed/scripts/glass_shader_gui_3d_test.gd` — host script for the hybrid panel, controls, and input verification HUD
- `.testbed/scripts/glass_3d_debug_backdrop.gd` — shared 3D diagnostic backdrop used by the hybrid scene
- `assets/shaders/glass-panel-hybrid-3d.gdshader` — supported hybrid world-space glass body shader
- `assets/shaders/glass-panel-ui-overlay-3d.gdshader` — supported UI overlay shader layered on the hybrid panel

### Project entry

- `.testbed/project.godot` — opens the hidden testbed project; the default launch scene is the 2D frosted glass proof

## Quick start

### 2D frosted glass flow

1. Open the hidden testbed:
   ```bash
   godot --editor --path .testbed
   ```
2. Open `.testbed/scenes/glass-shader-test.tscn`.
3. Run the scene.
4. Switch between `AeroBeat image`, `Debug pattern`, and `Hybrid overlay` backgrounds.
5. Tune `blur`, `warp_intensity`, `strength_x`, and `strength_y` while watching the background through the glass plate.

If those parameters visibly alter the sampled background inside the panel, the 2D glass effect is alive.

### Hybrid 3D flow

1. Open the hidden testbed:
   ```bash
   godot --editor --path .testbed
   ```
2. Open `.testbed/scenes/glass-shader-gui-3d-test.tscn`.
3. Run the scene.
4. Verify the panel renders authored UI through the hybrid material while the 3D debug backdrop remains visible behind it.
5. Use the scene controls to inspect world-space presentation, overlay readability, and input-contract status.

If the 3D panel shows the authored UI, the backdrop distortion responds to parameter changes, and the interaction HUD continues reporting normalized panel events, the supported hybrid path is wired correctly.

## What is actually implemented here

### 2D frosted glass pattern

The supported 2D pattern is a flat control host plus a dedicated shader-backed fill layer.

Typical structure:

- host `Button` or `Control`
- child `ColorRect` with the `ShaderMaterial`
- shell overlays for bevel / frame / inner border
- content nodes above the glass layer

That layering matters. The glass effect comes from the child `ColorRect` sampling the screen behind it. The host control remains responsible for layout and interaction.

### Hybrid 3D pattern

The supported 3D-facing path is not a standalone native spatial glass object anymore. It is a **hybrid** composition:

- authored 2D UI lives inside `SubViewport` content
- `.testbed/scenes/glass-shader-gui-3d-test.tscn` presents that UI on a world-space panel
- `glass-panel-hybrid-3d.gdshader` handles the supported glass body treatment
- `glass-panel-ui-overlay-3d.gdshader` handles the supported overlay pass
- `.testbed/scripts/glass_3d_debug_backdrop.gd` provides diagnostic world geometry so refraction and readability stay testable

Treat this repo as a reference for a 2D-first panel design that is then composited into 3D space, not as a generic native-3D glass material library.

## Build a new 2D glass control from scratch

1. Create a `Button` or `Control` that defines the plate size.
2. Add a child `ColorRect` that fills the host.
3. Assign a `ShaderMaterial` using `assets/shaders/glass-shader.gdshader`.
4. Add separate shell overlays for the frame and inner border.
5. Put text, badges, and other content above the glass layer.
6. Keep shell corner treatment synchronized with the shader radius.

In this repo, the canonical implementation details live in:

- `.testbed/scenes/glass-shader-test.tscn`
- `.testbed/scripts/glass_shader_test.gd`

## Validation backgrounds and why they matter

The 2D proof exposes three useful background modes:

- `AeroBeat image` — presentation / taste check
- `Debug pattern` — truth check for blur and refraction
- `Hybrid overlay` — realism plus diagnostic contrast

Use `Debug pattern` first when validating the effect. Pretty art can hide broken sampling or weak distortion.

The hybrid 3D proof serves a similar purpose by keeping a high-contrast procedural 3D backdrop behind the world-space panel.

## Parameter guidance

These values remain good starting points for the 2D frosted path:

- `blur = 4.2`
- `warp_intensity = 0.45`
- `strength_x = 14.0`
- `strength_y = 14.0`
- `corner_radius = 0.24`
- `tint = Color(0.92, 0.96, 1.0, 0.22)`
- `edge_highlight = Color(1.0, 1.0, 1.0, 0.62)`
- `edge_width = 2.4`

For the hybrid 3D path, use the scene defaults in `.testbed/scripts/glass_shader_gui_3d_test.gd` as the tuning baseline, because the supported material includes additional world-space, UI-embed, and overlay parameters beyond the 2D shader.

## Major gotchas

### 1) Layering can fake success

If the frame styling looks good but the background behind the glass does not visibly change, the shader path is not actually working.

### 2) Diagnostic backgrounds are mandatory

Use the 2D debug backdrop or the 3D debug backdrop to confirm the effect is truly sampling and distorting the scene.

### 3) Corner parity matters

Keep shader masking and shell geometry synchronized so the visible border treatment matches the glass silhouette.

### 4) Hybrid 3D is still a 2D-authored panel flow

Do not treat the surviving 3D support as a general native spatial object shader path. The supported path is specifically the hybrid world-space panel shown in `.testbed/scenes/glass-shader-gui-3d-test.tscn`.

## Suggested checklist

- [ ] 2D host control is flat and not fighting default button chrome
- [ ] Child `ColorRect` owns the 2D glass shader material
- [ ] Frame and inner border are separate overlay nodes
- [ ] Content sits above the glass layer
- [ ] `Debug pattern` clearly shows blur and warp differences
- [ ] `strength_x` and `strength_y` both change the interior distortion profile
- [ ] Corner treatment stays aligned between shader and shell
- [ ] Hybrid 3D panel still renders authored UI through the supported hybrid shaders
- [ ] Hybrid 3D input HUD still receives normalized panel events

## Where to start if you want to copy this into a new scene

For the 2D path, start with:

- `.testbed/scenes/glass-shader-test.tscn`
- `.testbed/scripts/glass_shader_test.gd`
- `assets/shaders/glass-shader.gdshader`

For the hybrid 3D path, start with:

- `.testbed/scenes/glass-shader-gui-3d-test.tscn`
- `.testbed/scripts/glass_shader_gui_3d_test.gd`
- `assets/shaders/glass-panel-hybrid-3d.gdshader`
- `assets/shaders/glass-panel-ui-overlay-3d.gdshader`

Those files are the shortest truthful path to the supported glass surfaces that remain in this repo.
