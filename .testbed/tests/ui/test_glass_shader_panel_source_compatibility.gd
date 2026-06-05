extends GutTest

const LEGACY_PANEL_SOURCE_SCENE := preload("res://scenes/glass-shader-panel-source.tscn")


func test_legacy_panel_source_scene_remains_a_compatibility_alias_of_the_canonical_panel_view() -> void:
	var panel = LEGACY_PANEL_SOURCE_SCENE.instantiate()
	add_child_autofree(panel)
	await get_tree().process_frame
	await get_tree().process_frame

	assert_true(panel is AeroUiGlassPanelView)
	assert_eq(panel.name, "GlassShaderPanelSource")
	assert_eq(panel.get_script().resource_path, "res://scripts/glass_shader_panel_source.gd")
	assert_not_null(panel.badge_view)
	assert_not_null(panel.primary_button_view)
	assert_eq(panel.badge_view.get_script().resource_path, "res://ui/views/aero_ui_glass_badge_view.gd")
	assert_eq(panel.primary_button_view.get_script().resource_path, "res://ui/views/aero_ui_glass_primary_button_view.gd")
	assert_eq(panel._panel_style_config.source_path, "res://ui/presets/glass/panel/2d-glass-shader.default.yaml")
