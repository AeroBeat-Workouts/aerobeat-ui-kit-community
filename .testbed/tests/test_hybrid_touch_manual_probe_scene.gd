extends GutTest

const MANUAL_PROBE_SCENE := preload("res://qa_probes/hybrid_touch_provider_manual_probe.tscn")
const HYBRID_HOST_SCENE_PATH := "res://scenes/glass-shader-gui-3d-test.tscn"

func test_manual_probe_scene_wraps_hybrid_proof_host_and_reads_packaged_probe_snapshot() -> void:
	var probe = await _spawn_manual_probe_scene()
	var host = probe.wrapped_proof_host()
	var snapshot: Dictionary = probe._current_probe_snapshot()

	assert_eq(host.scene_file_path, HYBRID_HOST_SCENE_PATH)
	assert_eq(str(snapshot.get("source_variant", "")), "screen_touch")
	assert_eq(str(snapshot.get("surface_type", "")), "hybrid_3d_gui")
	assert_eq(str(snapshot.get("verification_status", "")), "unverified")
	assert_string_contains(probe.get_node("ProbeOverlay/OverlayRoot/Margin/Panel/Column/ProbeLabel").text, "verification status: unverified")

	probe.queue_free()


func test_manual_probe_scene_tracks_transcript_owner_hover_and_cancel_paths() -> void:
	var probe = await _spawn_manual_probe_scene()
	var host = probe.wrapped_proof_host()
	var press_pos = _screen_position_for_control_path(host, "PreviewCenter/PreviewStack/PrimaryCardButton/ContentMargin/ContentColumn/PrimaryActionButton")
	var drag_pos = press_pos + Vector2(80.0, 0.0)

	var press := InputEventScreenTouch.new()
	press.index = 0
	press.pressed = true
	press.position = press_pos
	assert_true(host._publish_screen_touch_to_contract(press))
	probe.refresh_probe_panel()

	var hold := InputEventScreenDrag.new()
	hold.index = 0
	hold.position = press_pos + Vector2(3.0, 0.0)
	hold.relative = Vector2(3.0, 0.0)
	hold.pressure = 1.0
	hold.velocity = Vector2(3.0, 0.0)
	assert_true(host._publish_screen_drag_to_contract(hold))

	var drag := InputEventScreenDrag.new()
	drag.index = 0
	drag.position = drag_pos
	drag.relative = drag_pos - hold.position
	drag.pressure = 1.0
	drag.velocity = drag.relative
	assert_true(host._publish_screen_drag_to_contract(drag))
	probe.refresh_probe_panel()

	var active_probe: Dictionary = probe._current_probe_snapshot()
	assert_eq(str(active_probe.get("owner_target_label", "")), "PrimaryActionButton")
	assert_eq(str(active_probe.get("live_target_label", "")), "PrimaryActionButton")
	assert_eq(str(active_probe.get("preferred_target_label", "")), "PrimaryActionButton")
	assert_eq(str(active_probe.get("state_phase", "")), "drag_begin")

	assert_true(probe.trigger_active_touch_cancel())
	var transcript: PackedStringArray = probe.recent_transcript_lines()
	assert_eq(transcript, PackedStringArray(["press_begin", "press_hold", "drag_begin", "cancel"]))
	assert_string_contains(probe.get_node("ProbeOverlay/OverlayRoot/Margin/Panel/Column/TranscriptLabel").text, "• cancel")
	assert_eq(str(probe._current_probe_snapshot().get("verification_status", "")), "unverified")

	probe.queue_free()


func _spawn_manual_probe_scene() -> Node:
	var scene := MANUAL_PROBE_SCENE.instantiate()
	add_child_autofree(scene)
	await get_tree().process_frame
	await get_tree().process_frame
	return scene


func _screen_position_for_control_path(host: Node, control_path: String) -> Vector2:
	var panel = host.get_node("PanelPivot/PanelViewport").get_child(0)
	var control = panel.get_node(control_path)
	var root_rect = panel.get_global_rect()
	var control_rect = control.get_global_rect()
	var authored_uv = ((control_rect.position + (control_rect.size * 0.5)) - root_rect.position) / root_rect.size
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
