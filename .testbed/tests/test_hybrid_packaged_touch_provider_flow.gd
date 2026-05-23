extends GutTest

const HYBRID_SCENE := preload("res://scenes/glass-shader-gui-3d-test.tscn")
const INSTALLED_TOUCH_PROVIDER_PATH := "res://addons/aerobeat-spatial-ui-touch/src/providers/touch/aero_spatial_ui_touch_provider.gd"
const PACKAGED_RESOLVER_PATH := "res://addons/aerobeat-spatial-ui-core/src/helpers/providers/aero_spatial_rect_target_resolver.gd"

func test_installed_touch_provider_uses_packaged_helpers_without_reowning_world_hits() -> void:
	var provider_source := FileAccess.get_file_as_string(INSTALLED_TOUCH_PROVIDER_PATH)

	assert_ne(provider_source, "", "Expected the installed spatial touch provider script to be readable from the hidden testbed")
	assert_string_contains(provider_source, 'const RECT_TARGET_RESOLVER_SCRIPT_PATH := "%s"' % PACKAGED_RESOLVER_PATH)
	assert_string_contains(provider_source, "func _build_target_resolver():")
	assert_string_contains(provider_source, "var resolution_result = _target_resolver.resolve_target(surface, projected_hit)")
	assert_false(provider_source.contains("project_ray_origin"))
	assert_false(provider_source.contains("intersect_ray"))


func test_touch_press_flow_reports_packaged_provider_runtime_state_end_to_end() -> void:
	var scene = await _spawn_hybrid_scene()
	var screen_pos = _primary_button_screen_position(scene)

	var press := InputEventScreenTouch.new()
	press.index = 0
	press.pressed = true
	press.position = screen_pos
	assert_true(scene._publish_screen_touch_to_contract(press))

	var touch_state: Dictionary = scene._current_touch_runtime_state()
	var projected_data: Dictionary = touch_state.get("last_projected_data", {})
	var raw_metadata: Dictionary = projected_data.get("raw_metadata", {})

	assert_eq(scene._last_contract_phase, "press_begin")
	assert_string_contains(str(scene._last_contract_target_path), "PrimaryActionButton")
	assert_eq(raw_metadata.get("resolution_mode", ""), "rect_target_specs")
	assert_eq(raw_metadata.get("matched_target_key", ""), "primary")
	assert_string_contains(str(raw_metadata.get("published_target_path", "")), "PrimaryActionButton")
	assert_string_contains(str(raw_metadata.get("live_target_path", "")), "PrimaryActionButton")
	assert_eq(raw_metadata.get("target_resolution", ""), "rect_target_specs")
	assert_eq(raw_metadata.get("host_surface", ""), "PanelInputSurface")

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
