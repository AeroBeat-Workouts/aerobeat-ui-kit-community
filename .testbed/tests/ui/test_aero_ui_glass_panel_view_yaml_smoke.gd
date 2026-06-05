extends GutTest

const CANONICAL_PANEL_VIEW_SCENE := preload("res://ui/views/aero_ui_glass_panel_view.tscn")


func test_canonical_panel_view_scene_loads_yaml_backed_style_bundle_on_startup() -> void:
	var panel = CANONICAL_PANEL_VIEW_SCENE.instantiate()
	add_child_autofree(panel)
	await get_tree().process_frame
	await get_tree().process_frame

	assert_not_null(panel._panel_style_config)
	assert_not_null(panel._badge_style_config)
	assert_not_null(panel._primary_button_style_config)
	assert_not_null(panel.badge_view)
	assert_not_null(panel.primary_button_view)
	assert_eq(panel.get_script().resource_path, "res://ui/views/aero_ui_glass_panel_view.gd")
	assert_eq(panel.badge_view.get_script().resource_path, "res://ui/views/aero_ui_glass_badge_view.gd")
	assert_eq(panel.primary_button_view.get_script().resource_path, "res://ui/views/aero_ui_glass_primary_button_view.gd")
	assert_eq(panel._panel_style_config.source_path, "res://ui/presets/glass/panel/hybrid-3d/default.yaml")
	assert_eq(panel._badge_style_config.source_path, "res://ui/presets/glass/panel/hybrid-3d/badge.yaml")
	assert_eq(panel._primary_button_style_config.source_path, "res://ui/presets/glass/panel/hybrid-3d/primary-button.yaml")
	assert_almost_eq(float(panel.get_shader_parameter("blur")), 4.2, 0.0001)
	assert_eq(panel.get_shader_parameter("tint"), Color(0.92, 0.96, 1.0, 0.22))
	assert_almost_eq(float(panel.get_hybrid_shell_parameter("hybrid_inner_border_alpha")), 0.312, 0.0001)
	assert_almost_eq(float(panel.get_hybrid_shell_parameter("hybrid_badge_label_alpha")), 0.9, 0.0001)
	assert_eq(panel.get_badge_style_config().tint, Color(0.92, 0.96, 1.0, 1.0))
	assert_eq(panel.get_primary_button_style_config().background_tint, Color(0.92, 0.96, 1.0, 1.0))

	var action_style := panel.primary_action_body.get_theme_stylebox("panel") as StyleBoxFlat
	assert_not_null(action_style)
	assert_eq(action_style.border_width_left, 2)
	assert_eq(action_style.corner_radius_top_left, 19)

	panel._target_states[panel.TARGET_PRIMARY] = {
		"hovered": true,
		"pressed": false,
		"dragging": false,
		"toggle_on": false,
	}
	panel._refresh_primary_action_visual()
	await get_tree().create_timer(0.15).timeout
	panel._sync_preview_shell()
	var frame_border_before := panel.preview_frame.get_theme_stylebox("panel") as StyleBoxFlat
	var badge_border_before := panel.preview_badge.get_theme_stylebox("panel") as StyleBoxFlat
	assert_false(frame_border_before.border_color.is_equal_approx(panel.TOGGLE_ON_ACCENT))
	assert_false(badge_border_before.border_color.is_equal_approx(panel.TOGGLE_ON_ACCENT))
	assert_true(panel.primary_action_body.scale.x > 1.0)
	var hover_scale: float = panel.primary_action_body.scale.x

	panel._target_states[panel.TARGET_PRIMARY] = {
		"hovered": true,
		"pressed": true,
		"dragging": false,
		"toggle_on": false,
	}
	panel._refresh_primary_action_visual()
	await get_tree().create_timer(0.12).timeout
	assert_true(panel.primary_action_body.scale.x < hover_scale)

	panel._target_states[panel.TARGET_PRIMARY] = {
		"hovered": false,
		"pressed": false,
		"dragging": false,
		"toggle_on": true,
	}
	panel._refresh_primary_action_visual()
	await get_tree().create_timer(0.15).timeout
	assert_almost_eq(panel.primary_action_body.scale.x, 1.0, 0.0001)

	var tween_state := {"finished": false}
	panel.TweenAlphaChildren(0.35, 0.0, "linear", func() -> void:
		tween_state["finished"] = true
	)
	await get_tree().process_frame
	assert_true(bool(tween_state["finished"]))
	assert_almost_eq(panel.badge_view.modulate.a, 0.35, 0.0001)
	assert_almost_eq(panel.primary_button_view.modulate.a, 0.35, 0.0001)

	panel.set_presentation_mode(panel.PRESENTATION_MODE_HYBRID_WORLD_SPACE)
	await get_tree().process_frame
	assert_almost_eq(panel.preview_badge_label.modulate.a, 0.9, 0.0001)
	assert_almost_eq(panel.primary_action_label.modulate.a, 0.99, 0.0001)
