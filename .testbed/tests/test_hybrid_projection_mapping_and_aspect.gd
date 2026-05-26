extends GutTest

const HYBRID_SCENE := preload("res://scenes/glass-shader-gui-3d-test.tscn")


func test_projected_target_lookup_remaps_panel_uv_into_authored_space() -> void:
	var scene := await _spawn_hybrid_scene()
	var panel := scene.get_node("PanelPivot/PanelViewport").get_child(0)
	var specs: Array = panel.get_interaction_target_specs()
	var target_button: Control = panel.get_node("PreviewCenter/PreviewStack/PrimaryCardButton/ContentMargin/ContentColumn/PrimaryActionButton")
	var root_rect: Rect2 = panel.get_global_rect()
	var button_rect: Rect2 = target_button.get_global_rect()
	var authored_px := (button_rect.position + (button_rect.size * 0.5)) - root_rect.position
	var authored_uv := authored_px / root_rect.size
	var glass_rect: Rect2 = scene._get_authored_glass_rect()
	var panel_uv := (authored_uv - glass_rect.position) / glass_rect.size
	var expected_target := _target_for_point(specs, authored_px)

	assert_ne(expected_target, NodePath())
	assert_true(panel_uv.x >= 0.0 and panel_uv.x <= 1.0)
	assert_true(panel_uv.y >= 0.0 and panel_uv.y <= 1.0)
	assert_eq(scene._resolve_projected_target_path_from_hit({
		"authored_viewport_position": authored_px,
		"authored_uv": authored_uv,
		"viewport_position": panel_uv * Vector2(scene.panel_viewport.size),
		"uv": panel_uv,
	}), expected_target)
	assert_ne(scene._resolve_projected_target_path(panel_uv * Vector2(scene.panel_viewport.size), panel_uv), expected_target)


func test_spatial_surface_descriptor_localizes_target_rects_to_panel_root() -> void:
	var scene := await _spawn_hybrid_scene()
	var panel := scene.get_node("PanelPivot/PanelViewport").get_child(0)
	var button: Control = panel.get_node("PreviewCenter/PreviewStack/PrimaryCardButton/ContentMargin/ContentColumn/PrimaryActionButton")
	var root_rect: Rect2 = panel.get_global_rect()
	var button_rect: Rect2 = button.get_global_rect()
	var localized_specs: Array = scene._localize_surface_target_specs(panel.get_interaction_target_specs(), root_rect)
	var primary_spec := _spec_for_target_key(localized_specs, "primary")

	assert_false(primary_spec.is_empty())
	assert_eq(primary_spec.get("rect", Rect2()), Rect2(button_rect.position - root_rect.position, button_rect.size))
	assert_true((primary_spec.get("rect", Rect2()) as Rect2).has_point(((button_rect.position + (button_rect.size * 0.5)) - root_rect.position)))


func test_screen_pixel_round_trip_uses_panel_plane_instead_of_collision_face() -> void:
	var scene := await _spawn_hybrid_scene()
	var panel := scene.get_node("PanelPivot/PanelViewport").get_child(0)
	var button: Control = panel.get_node("PreviewCenter/PreviewStack/PrimaryCardButton/ContentMargin/ContentColumn/PrimaryActionButton")
	var root_rect: Rect2 = panel.get_global_rect()
	var button_local_rect := Rect2(button.get_global_rect().position - root_rect.position, button.get_global_rect().size)
	var authored_samples := [
		Vector2(button_local_rect.position.x - 10.0, button_local_rect.position.y + 16.0),
		Vector2(button_local_rect.position.x - 10.0, button_local_rect.position.y + button_local_rect.size.y - 8.0),
		Vector2(button_local_rect.position.x + 16.0, button_local_rect.position.y + button_local_rect.size.y + 8.0),
	]

	for authored_position in authored_samples:
		assert_false(button_local_rect.has_point(authored_position), "Sanity check: authored sample should stay outside the real primary-button rect")
		var screen_position := _screen_position_for_authored_position(scene, authored_position)
		var hit: Dictionary = scene._screen_position_to_panel_hit(Vector2(round(screen_position.x), round(screen_position.y)))
		var resolved_target: NodePath = scene._resolve_projected_target_path_from_hit(hit)
		var recovered_authored_position: Vector2 = hit.get("authored_viewport_position", Vector2.ZERO)
		var raw_metadata: Dictionary = hit.get("raw_metadata", {})

		assert_true(bool(raw_metadata.get("panel_plane_intersection", false)), "Hybrid host should remap screen pixels against the actual panel plane, not the collision box face")
		assert_almost_eq(hit.get("local_hit", Vector3.ZERO).z, 0.0, 0.0005)
		assert_false(button_local_rect.has_point(recovered_authored_position), "Recovered authored-space point should stay outside the primary-button rect after pixel round-trip")
		assert_eq(resolved_target, NodePath(), "Screen-pixel round-trip just outside the button should not resolve to PrimaryActionButton")


func test_panel_surface_aspect_matches_authored_card_aspect() -> void:
	var scene := await _spawn_hybrid_scene()
	var display_mesh: QuadMesh = scene.panel_display.mesh as QuadMesh
	var overlay_mesh: QuadMesh = scene.panel_ui_overlay.mesh as QuadMesh
	var collision_shape: CollisionShape3D = scene.panel_input_surface.get_node("CollisionShape3D") as CollisionShape3D
	var shape: BoxShape3D = collision_shape.shape as BoxShape3D
	var authored_rect: Rect2 = scene._get_authored_glass_rect()
	var viewport_size := Vector2(scene.panel_viewport.size)
	var authored_size_px := Vector2(authored_rect.size.x * viewport_size.x, authored_rect.size.y * viewport_size.y)
	var authored_aspect := authored_size_px.x / authored_size_px.y
	var display_aspect := display_mesh.size.x / display_mesh.size.y
	var overlay_aspect := overlay_mesh.size.x / overlay_mesh.size.y
	var collision_aspect := shape.size.x / shape.size.y

	assert_almost_eq(scene._get_authored_surface_aspect(), authored_aspect, 0.0005)
	assert_almost_eq(display_aspect, authored_aspect, 0.0005)
	assert_almost_eq(overlay_aspect, authored_aspect, 0.0005)
	assert_almost_eq(collision_aspect, authored_aspect, 0.0005)
	assert_almost_eq(display_mesh.size.y, 2.93 / authored_aspect, 0.0005)


func _spawn_hybrid_scene() -> Node:
	var scene := HYBRID_SCENE.instantiate()
	add_child_autofree(scene)
	await get_tree().process_frame
	await get_tree().process_frame
	scene.set_auto_rotate_enabled(false)
	return scene


func _target_for_point(specs: Array, point: Vector2) -> NodePath:
	for spec_variant in specs:
		if not (spec_variant is Dictionary):
			continue
		var spec: Dictionary = spec_variant
		var rect: Rect2 = spec.get("rect", Rect2())
		if rect.has_point(point):
			return spec.get("target_path", NodePath())
	return NodePath()


func _screen_position_for_authored_position(scene: Node, authored_position: Vector2) -> Vector2:
	var root_rect: Rect2 = scene.get_node("PanelPivot/PanelViewport").get_child(0).get_global_rect()
	var authored_uv := authored_position / root_rect.size
	var glass_rect: Rect2 = scene._get_authored_glass_rect()
	var panel_uv := (authored_uv - glass_rect.position) / glass_rect.size
	var surface_size: Vector2 = scene._get_panel_surface_size()
	var local_hit := Vector3(
		(panel_uv.x - 0.5) * surface_size.x,
		(0.5 - panel_uv.y) * surface_size.y,
		0.0
	)
	var world_point = scene.panel_input_surface.to_global(local_hit)
	var camera: Camera3D = scene.get_node("Camera3D")
	return camera.unproject_position(world_point)


func _spec_for_target_key(specs: Array, target_key: String) -> Dictionary:
	for spec_variant in specs:
		if not (spec_variant is Dictionary):
			continue
		var spec: Dictionary = spec_variant
		if str(spec.get("target_key", "")) == target_key:
			return spec
	return {}
