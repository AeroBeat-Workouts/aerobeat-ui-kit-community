extends GutTest

const HYBRID_SCENE := preload("res://scenes/glass-shader-gui-3d-test.tscn")

func test_explicit_mouse_release_completes_primary_toggle() -> void:
	var scene = await _spawn_hybrid_scene()
	var screen_pos = _primary_button_screen_position(scene)

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
	assert_true(_primary_toggle_on(scene))
	assert_eq(_primary_card(scene).button_pressed, true)
	assert_string_contains(scene._last_release_target_path, "PrimaryActionButton")
	var release_snapshot: Dictionary = scene.describe_mouse_verification_snapshot()
	assert_eq(str(release_snapshot.get("verification_status", "")), "prototype")
	assert_eq(str(release_snapshot.get("capture_target_path", "not-empty")), "")
	assert_false(bool(release_snapshot.get("left_button_down", true)))
	assert_string_contains(str(release_snapshot.get("last_release_target_path", "")), "PrimaryActionButton")

	scene.queue_free()


func test_mouse_motion_button_mask_drop_synthesizes_release_completion() -> void:
	var scene = await _spawn_hybrid_scene()
	var screen_pos = _primary_button_screen_position(scene)

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
	var mouse_state: Dictionary = scene._current_mouse_runtime_state()
	assert_false(bool(mouse_state.get("left_button_down", true)))
	assert_false(bool(mouse_state.get("capture_active", true)))
	assert_true(_primary_toggle_on(scene))
	assert_eq(_primary_card(scene).button_pressed, true)
	assert_string_contains(scene._last_release_target_path, "PrimaryActionButton")
	var motion_release_snapshot: Dictionary = scene.describe_mouse_verification_snapshot()
	assert_eq(str(motion_release_snapshot.get("verification_status", "")), "prototype")
	assert_eq(str(motion_release_snapshot.get("capture_target_path", "not-empty")), "")
	assert_false(bool(motion_release_snapshot.get("left_button_down", true)))
	assert_string_contains(str(motion_release_snapshot.get("last_release_target_path", "")), "PrimaryActionButton")

	scene.queue_free()


func _spawn_hybrid_scene() -> Node:
	var scene = HYBRID_SCENE.instantiate()
	add_child_autofree(scene)
	await get_tree().process_frame
	await get_tree().process_frame
	scene.set_auto_rotate_enabled(false)
	return scene


func _primary_button_screen_position(scene: Node) -> Vector2:
	var panel = scene.get_node("PanelPivot/PanelViewport").get_child(0)
	var button = panel.get_node("PreviewCenter/PreviewStack/PrimaryCardButton/ContentMargin/ContentColumn/PrimaryActionButton")
	var root_rect = panel.get_global_rect()
	var button_rect = button.get_global_rect()
	var authored_uv = ((button_rect.position + (button_rect.size * 0.5)) - root_rect.position) / root_rect.size
	var glass_rect = scene._get_authored_glass_rect()
	var panel_uv = (authored_uv - glass_rect.position) / glass_rect.size
	var surface_size = scene._get_panel_surface_size()
	var local_hit = Vector3(
		(panel_uv.x - 0.5) * surface_size.x,
		(0.5 - panel_uv.y) * surface_size.y,
		0.0
	)
	var world_point = scene.panel_input_surface.to_global(local_hit)
	var camera: Camera3D = scene.get_node("Camera3D")
	return camera.unproject_position(world_point)


func _primary_toggle_on(scene: Node) -> bool:
	var panel = scene.get_node("PanelPivot/PanelViewport").get_child(0)
	return bool(panel._target_state("primary").get("toggle_on", false))


func _primary_card(scene: Node) -> Button:
	var panel = scene.get_node("PanelPivot/PanelViewport").get_child(0)
	return panel.get_node("PreviewCenter/PreviewStack/PrimaryCardButton") as Button
