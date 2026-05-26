extends GutTest

const HYBRID_SCENE := preload("res://scenes/glass-shader-gui-3d-test.tscn")
const INSTALLED_MOUSE_PROVIDER_PATH := "res://addons/aerobeat-spatial-ui-mouse/src/providers/mouse/aero_spatial_ui_mouse_provider.gd"
const PACKAGED_RESOLVER_PATH := "res://addons/aerobeat-spatial-ui-core/src/helpers/providers/aero_spatial_rect_target_resolver.gd"


func test_installed_mouse_provider_uses_packaged_rect_resolver() -> void:
	var provider_source := FileAccess.get_file_as_string(INSTALLED_MOUSE_PROVIDER_PATH)

	assert_ne(provider_source, "", "Expected the installed spatial mouse provider script to be readable from the hidden testbed")
	assert_string_contains(provider_source, 'const RECT_TARGET_RESOLVER_SCRIPT_PATH := "%s"' % PACKAGED_RESOLVER_PATH, "Installed spatial mouse provider should load the packaged rect resolver from aerobeat-spatial-ui-core")
	assert_string_contains(provider_source, "func _build_target_resolver():", "Installed spatial mouse provider should build a packaged resolver instead of inlining local rect-walk ownership")
	assert_string_contains(provider_source, "var resolution_result = _target_resolver.resolve_target(surface, projected_hit)", "Installed spatial mouse provider should delegate target lookup through the packaged resolver")
	assert_false(provider_source.contains("for spec_variant in surface.duplicate_target_specs()"), "Installed spatial mouse provider should not keep a local rect-target fallback loop")


func test_mouse_press_flow_reports_packaged_resolver_metadata_end_to_end() -> void:
	var scene = await _spawn_hybrid_scene()
	var screen_pos = _primary_button_screen_position(scene)

	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = screen_pos
	assert_true(scene._publish_mouse_button_to_contract(press))

	var mouse_state: Dictionary = scene._current_mouse_runtime_state()
	var projected_data: Dictionary = mouse_state.get("last_projected_data", {})
	var raw_metadata: Dictionary = projected_data.get("raw_metadata", {})

	assert_eq(scene._last_contract_phase, "press_begin")
	assert_string_contains(str(scene._last_contract_target_path), "PrimaryActionButton")
	assert_eq(raw_metadata.get("resolution_mode", ""), "rect_target_specs", "Packaged resolver should still publish the shared rect-target resolution mode")
	assert_eq(raw_metadata.get("matched_target_key", ""), "primary", "Packaged resolver should identify the authored target key from this proof scene through the shared helper path")
	assert_string_contains(str(raw_metadata.get("published_target_path", "")), "PrimaryActionButton")
	assert_string_contains(str(raw_metadata.get("live_target_path", "")), "PrimaryActionButton")
	assert_eq(raw_metadata.get("target_resolution", ""), "rect_target_specs", "Projected metadata should preserve the shared target-resolution label")
	assert_eq(raw_metadata.get("host_surface", ""), "PanelInputSurface")

	scene.queue_free()


func test_non_button_panel_hit_does_not_resolve_to_primary_action_button() -> void:
	var scene = await _spawn_hybrid_scene()
	var panel = scene.get_node("PanelPivot/PanelViewport").get_child(0)
	var root_rect: Rect2 = panel.get_global_rect()
	var button = panel.get_node("PreviewCenter/PreviewStack/PrimaryCardButton/ContentMargin/ContentColumn/PrimaryActionButton")
	var button_rect: Rect2 = button.get_global_rect()
	var glass_rect: Rect2 = scene._get_authored_glass_rect()
	var non_button_authored_uv := glass_rect.position + (glass_rect.size * Vector2(0.18, 0.2))
	var non_button_authored_position := non_button_authored_uv * root_rect.size

	assert_false(Rect2(button_rect.position - root_rect.position, button_rect.size).has_point(non_button_authored_position))
	assert_eq(scene._resolve_projected_target_path_from_hit({
		"authored_viewport_position": non_button_authored_position,
		"authored_uv": non_button_authored_uv,
		"viewport_position": non_button_authored_position,
		"surface_position": non_button_authored_position,
	}), NodePath(), "A non-button authored-space point should not resolve to the primary action button")

	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = _screen_position_for_authored_position(scene, non_button_authored_position)
	assert_true(scene._publish_mouse_button_to_contract(press))
	assert_false(str(scene._last_contract_target_path).contains("PrimaryActionButton"))
	assert_ne(scene._current_mouse_runtime_state().get("last_projected_data", {}).get("raw_metadata", {}).get("matched_target_key", ""), "primary")

	scene.queue_free()


func _spawn_hybrid_scene() -> Node:
	var scene := HYBRID_SCENE.instantiate()
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
	var authored_position = (button_rect.position + (button_rect.size * 0.5)) - root_rect.position
	return _screen_position_for_authored_position(scene, authored_position)


func _screen_position_for_authored_position(scene: Node, authored_position: Vector2) -> Vector2:
	var root_rect: Rect2 = scene.get_node("PanelPivot/PanelViewport").get_child(0).get_global_rect()
	var authored_uv := authored_position / root_rect.size
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
