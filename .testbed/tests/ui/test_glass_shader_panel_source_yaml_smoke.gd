extends GutTest

const PANEL_SCENE := preload("res://scenes/glass-shader-panel-source.tscn")


func test_source_scene_loads_yaml_backed_style_bundle_on_startup() -> void:
	var panel = PANEL_SCENE.instantiate()
	add_child_autofree(panel)
	await get_tree().process_frame
	await get_tree().process_frame

	assert_not_null(panel._panel_style_config)
	assert_not_null(panel._badge_style_config)
	assert_not_null(panel._primary_button_style_config)
	assert_eq(panel._panel_style_config.source_path, "res://ui/presets/glass/panel/primary-card-source.v1.yaml")
	assert_eq(panel._badge_style_config.source_path, "res://ui/presets/glass/badge/default.yaml")
	assert_eq(panel._primary_button_style_config.source_path, "res://ui/presets/glass/button/primary/literal-badge.v1.yaml")
	assert_almost_eq(float(panel.get_shader_parameter("blur")), 4.2, 0.0001)
	assert_eq(panel.get_shader_parameter("tint"), Color(0.92, 0.96, 1.0, 0.22))
	assert_almost_eq(float(panel.get_hybrid_shell_parameter("hybrid_inner_border_alpha")), 0.312, 0.0001)
	assert_almost_eq(float(panel.get_hybrid_shell_parameter("hybrid_badge_label_alpha")), 0.9, 0.0001)

	var action_style := panel.primary_action_body.get_theme_stylebox("panel") as StyleBoxFlat
	assert_not_null(action_style)
	assert_eq(action_style.border_width_left, 2)
	assert_eq(action_style.corner_radius_top_left, 19)

	panel.set_presentation_mode(panel.PRESENTATION_MODE_HYBRID_WORLD_SPACE)
	await get_tree().process_frame
	assert_almost_eq(panel.preview_badge_label.modulate.a, 0.9, 0.0001)
	assert_almost_eq(panel.primary_action_label.modulate.a, 0.98, 0.0001)
