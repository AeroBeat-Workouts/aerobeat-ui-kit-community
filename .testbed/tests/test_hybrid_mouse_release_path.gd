extends GutTest

const HYBRID_SCENE := preload("res://scenes/glass-shader-gui-3d-test.tscn")

func test_explicit_mouse_release_completes_primary_toggle() -> void:
	var scene := await _spawn_hybrid_scene()
	var screen_pos := _panel_center_screen_position(scene)

	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = screen_pos
	assert_true(scene._publish_mouse_button_to_contract(press))
	assert_eq(scene._last_contract_phase, "press_begin")

	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.pressed = false
	release.position = screen_pos
	assert_true(scene._publish_mouse_button_to_contract(release))
	assert_eq(scene._last_contract_phase, "press_end")
	assert_string_contains(_primary_toggle_label(scene), "Primary toggle: ON")
	assert_string_contains(_primary_toggle_label(scene), "taps 1")
	assert_string_contains(_primary_toggle_label(scene), "releases 1")

	scene.queue_free()


func test_mouse_motion_button_mask_drop_synthesizes_release_completion() -> void:
	var scene := await _spawn_hybrid_scene()
	var screen_pos := _panel_center_screen_position(scene)

	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = screen_pos
	assert_true(scene._publish_mouse_button_to_contract(press))

	var motion_hold := InputEventMouseMotion.new()
	motion_hold.position = screen_pos + Vector2(1, 0)
	motion_hold.relative = Vector2(1, 0)
	motion_hold.button_mask = MOUSE_BUTTON_MASK_LEFT
	assert_true(scene._publish_mouse_motion_to_contract(motion_hold))
	assert_eq(scene._last_contract_phase, "press_hold")

	var motion_release := InputEventMouseMotion.new()
	motion_release.position = screen_pos + Vector2(2, 0)
	motion_release.relative = Vector2(1, 0)
	motion_release.button_mask = 0
	assert_true(scene._publish_mouse_motion_to_contract(motion_release))
	assert_eq(scene._last_contract_phase, "hover_move")
	assert_false(scene._mouse_left_button_down)
	assert_false(scene._mouse_panel_capture)
	assert_string_contains(_primary_toggle_label(scene), "Primary toggle: ON")
	assert_string_contains(_primary_toggle_label(scene), "taps 1")
	assert_string_contains(_primary_toggle_label(scene), "releases 1")

	scene.queue_free()


func _spawn_hybrid_scene() -> Node:
	var scene := HYBRID_SCENE.instantiate()
	add_child_autofree(scene)
	await get_tree().process_frame
	await get_tree().process_frame
	scene.set_auto_rotate_enabled(false)
	return scene


func _panel_center_screen_position(scene: Node) -> Vector2:
	var surface: Area3D = scene.get_node("PanelPivot/PanelInputSurface")
	var camera: Camera3D = scene.get_node("Camera3D")
	return camera.unproject_position(surface.global_position)


func _primary_toggle_label(scene: Node) -> String:
	var panel := scene.get_node("PanelPivot/PanelViewport").get_child(0)
	return panel.interaction_toggle_label.text
