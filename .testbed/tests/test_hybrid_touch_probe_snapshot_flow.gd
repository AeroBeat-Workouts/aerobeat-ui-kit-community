extends GutTest

const MANUAL_PROBE_SCENE := preload("res://qa_probes/hybrid_touch_provider_manual_probe.tscn")
const INSTALLED_TOUCH_PROVIDER_PATH := "res://addons/aerobeat-spatial-ui-touch/src/providers/touch/aero_spatial_ui_touch_provider.gd"
const HYBRID_HOST_SCRIPT_PATH := "res://scripts/glass_shader_gui_3d_test.gd"
const MANUAL_PROBE_SCRIPT_PATH := "res://qa_probes/hybrid_touch_provider_manual_probe.gd"

func test_installed_touch_provider_snapshot_seam_stays_packaged_while_world_hit_stays_host_local() -> void:
	var provider_source := FileAccess.get_file_as_string(INSTALLED_TOUCH_PROVIDER_PATH)
	var host_source := FileAccess.get_file_as_string(HYBRID_HOST_SCRIPT_PATH)
	var probe_source := FileAccess.get_file_as_string(MANUAL_PROBE_SCRIPT_PATH)

	assert_ne(provider_source, "")
	assert_ne(host_source, "")
	assert_ne(probe_source, "")
	assert_string_contains(provider_source, "func describe_verification_probe() -> Dictionary:")
	assert_string_contains(provider_source, '"verification_status": VERIFICATION_STATUS')
	assert_false(provider_source.contains("project_ray_origin"))
	assert_false(provider_source.contains("intersect_ray"))
	assert_string_contains(host_source, "func _current_touch_verification_probe() -> Dictionary:")
	assert_string_contains(host_source, "func _screen_position_to_panel_hit(screen_position: Vector2) -> Dictionary:")
	assert_string_contains(host_source, "camera_3d.project_ray_origin(screen_position)")
	assert_string_contains(host_source, "direct_space_state.intersect_ray(query)")
	assert_string_contains(probe_source, "return proof_host._current_touch_verification_probe() if proof_host != null else {}")
	assert_false(probe_source.contains("project_ray_origin"))
	assert_false(probe_source.contains("intersect_ray"))


func test_manual_probe_reads_installed_addon_snapshot_without_rebuilding_provider_state() -> void:
	var probe = await _spawn_manual_probe_scene()
	var host = probe.wrapped_proof_host()
	var press_pos = _primary_button_screen_position(host)

	var press := InputEventScreenTouch.new()
	press.index = 0
	press.pressed = true
	press.position = press_pos
	assert_true(host._publish_screen_touch_to_contract(press))
	probe.refresh_probe_panel()

	var snapshot: Dictionary = probe._current_probe_snapshot()
	assert_eq(str(snapshot.get("active_pointer_id", "")), "touch_0")
	assert_eq(str(snapshot.get("owner_target_label", "")), "PrimaryActionButton")
	assert_eq(str(snapshot.get("live_target_label", "")), "PrimaryActionButton")
	assert_eq(str(snapshot.get("source_variant", "")), "screen_touch")
	assert_eq(str(snapshot.get("surface_type", "")), "hybrid_3d_gui")
	assert_eq(str(snapshot.get("verification_status", "")), "unverified")
	assert_string_contains(probe.get_node("ProbeOverlay/OverlayRoot/Margin/Panel/Column/ProbeLabel").text, "owner target: PrimaryActionButton")

	probe.queue_free()


func _spawn_manual_probe_scene() -> Node:
	var scene := MANUAL_PROBE_SCENE.instantiate()
	add_child_autofree(scene)
	await get_tree().process_frame
	await get_tree().process_frame
	return scene


func _primary_button_screen_position(host: Node) -> Vector2:
	var panel = host.get_node("PanelPivot/PanelViewport").get_child(0)
	var button = panel.get_node("PreviewCenter/PreviewStack/PrimaryCardButton/ContentMargin/ContentColumn/PrimaryActionButton")
	var root_rect = panel.get_global_rect()
	var button_rect = button.get_global_rect()
	var authored_uv = ((button_rect.position + (button_rect.size * 0.5)) - root_rect.position) / root_rect.size
	var glass_rect = host._get_authored_glass_rect()
	var panel_uv = (authored_uv - glass_rect.position) / glass_rect.size
	var surface_size = host._get_panel_surface_size()
	var local_hit = Vector3(
		(panel_uv.x - 0.5) * surface_size.x,
		(0.5 - panel_uv.y) * surface_size.y,
		0.0
	)
	var world_point = host.panel_input_surface.to_global(local_hit)
	var camera: Camera3D = host.get_node("Camera3D")
	return camera.unproject_position(world_point)
