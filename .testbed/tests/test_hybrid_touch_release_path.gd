extends GutTest

const HYBRID_SCENE := preload("res://scenes/glass-shader-gui-3d-test.tscn")

func test_touch_release_completes_against_press_owner() -> void:
	var scene = await _spawn_hybrid_scene()
	var screen_pos = _primary_button_screen_position(scene)

	var press := InputEventScreenTouch.new()
	press.index = 0
	press.pressed = true
	press.position = screen_pos
	assert_true(scene._publish_screen_touch_to_contract(press))
	assert_eq(scene._last_contract_phase, "press_begin")

	var release := InputEventScreenTouch.new()
	release.index = 0
	release.pressed = false
	release.position = screen_pos
	assert_true(scene._publish_screen_touch_to_contract(release))
	assert_eq(scene._last_contract_phase, "press_end")
	assert_true(_primary_toggle_on(scene))
	assert_eq(_primary_card(scene).button_pressed, true)
	assert_string_contains(scene._last_release_target_path, "PrimaryActionButton")

	scene.queue_free()


func test_touch_drag_release_orders_drag_end_before_press_end() -> void:
	var scene = await _spawn_hybrid_scene()
	var events: Array = []
	scene.interaction_bus.interaction_event.connect(func(event):
		if event.surface_id == scene.HYBRID_SURFACE_ID:
			events.append(event)
	)

	var press_pos = _primary_button_screen_position(scene)
	var drag_pos = press_pos + Vector2(80.0, 0.0)

	var press := InputEventScreenTouch.new()
	press.index = 0
	press.pressed = true
	press.position = press_pos
	assert_true(scene._publish_screen_touch_to_contract(press))

	var drag := InputEventScreenDrag.new()
	drag.index = 0
	drag.position = drag_pos
	drag.relative = drag_pos - press_pos
	drag.pressure = 1.0
	drag.velocity = drag.relative
	assert_true(scene._publish_screen_drag_to_contract(drag))

	var release := InputEventScreenTouch.new()
	release.index = 0
	release.pressed = false
	release.position = Vector2(0.0, 0.0)
	assert_true(scene._publish_screen_touch_to_contract(release))

	var phases: Array[String] = []
	for event in events:
		phases.append(str(event.phase))
	assert_eq(phases, ["press_begin", "drag_begin", "drag_end", "press_end"])
	assert_string_contains(str(events[2].target_path), "PrimaryActionButton")
	assert_string_contains(str(events[3].target_path), "PrimaryActionButton")

	scene.queue_free()


func _spawn_hybrid_scene() -> Node:
	var scene = HYBRID_SCENE.instantiate()
	add_child_autofree(scene)
	await get_tree().process_frame
	await get_tree().process_frame
	scene.set_auto_rotate_enabled(false)
	return scene


func _primary_button_screen_position(scene: Node) -> Vector2:
	return _screen_position_for_control_path(scene, "PreviewCenter/PreviewStack/PrimaryCardButton/ContentMargin/ContentColumn/PrimaryActionButton")


func _screen_position_for_control_path(scene: Node, control_path: String) -> Vector2:
	var panel = scene.get_node("PanelPivot/PanelViewport").get_child(0)
	var control = panel.get_node(control_path)
	var root_rect = panel.get_global_rect()
	var control_rect = control.get_global_rect()
	var authored_uv = ((control_rect.position + (control_rect.size * 0.5)) - root_rect.position) / root_rect.size
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
