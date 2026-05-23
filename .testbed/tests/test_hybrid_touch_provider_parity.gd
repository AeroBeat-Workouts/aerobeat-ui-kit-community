extends GutTest

const HYBRID_SCENE := preload("res://scenes/glass-shader-gui-3d-test.tscn")

func test_touch_provider_preserves_entry_policy_cancel_truth_and_unverified_metadata() -> void:
	var scene = await _spawn_hybrid_scene()
	var events: Array = []
	scene.interaction_bus.interaction_event.connect(func(event):
		if event.surface_id == scene.HYBRID_SURFACE_ID:
			events.append(event)
	)

	var off_surface_press := InputEventScreenTouch.new()
	off_surface_press.index = 0
	off_surface_press.pressed = true
	off_surface_press.position = Vector2(0.0, 0.0)
	assert_false(scene._publish_screen_touch_to_contract(off_surface_press))
	assert_eq(int(scene._current_touch_runtime_state().get("active_pointer_count", -1)), 0)

	var press_pos = _primary_button_screen_position(scene)
	var press := InputEventScreenTouch.new()
	press.index = 0
	press.pressed = true
	press.position = press_pos
	assert_true(scene._publish_screen_touch_to_contract(press))

	var small_drag := InputEventScreenDrag.new()
	small_drag.index = 0
	small_drag.position = press_pos + Vector2(3.0, 0.0)
	small_drag.relative = Vector2(3.0, 0.0)
	small_drag.pressure = 1.0
	small_drag.velocity = Vector2(3.0, 0.0)
	assert_true(scene._publish_screen_drag_to_contract(small_drag))
	assert_eq(scene._last_contract_phase, "press_hold")

	var cancel := InputEventScreenTouch.new()
	cancel.index = 0
	cancel.pressed = false
	cancel.canceled = true
	cancel.position = press_pos + Vector2(3.0, 0.0)
	assert_true(scene._publish_screen_touch_to_contract(cancel))
	assert_eq(scene._last_contract_phase, "cancel")
	assert_eq(int(scene._current_touch_runtime_state().get("active_pointer_count", -1)), 0)

	assert_eq(str(events[0].source_variant), "screen_touch")
	assert_eq(str(events[0].surface_type), "hybrid_3d_gui")
	assert_eq(str(events[0].verification_status), "unverified")
	assert_eq(str(events[2].target_path), str(events[0].target_path))

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
