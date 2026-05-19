extends GutTest

const LEGACY_PANEL_SOURCE_SCENE := preload("res://scenes/glass-shader-panel-source.tscn")


func test_legacy_panel_source_scene_still_exposes_the_legacy_script_path_for_compatibility() -> void:
	var panel = LEGACY_PANEL_SOURCE_SCENE.instantiate()
	add_child_autofree(panel)
	await get_tree().process_frame
	await get_tree().process_frame

	assert_true(panel is AeroUiGlassPanelView)
	assert_eq(panel.get_script().resource_path, "res://scripts/glass_shader_panel_source.gd")
	assert_not_null(panel.badge_view)
	assert_not_null(panel.primary_button_view)
