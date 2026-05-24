extends RefCounted

const HYBRID_SCENE := preload("res://scenes/glass-shader-gui-3d-test.tscn")

func spawn_hybrid_scene(test_case: GutTest) -> Node:
	var scene = HYBRID_SCENE.instantiate()
	test_case.add_child_autofree(scene)
	await test_case.get_tree().process_frame
	await test_case.get_tree().process_frame
	scene.set_auto_rotate_enabled(false)
	return scene

func screen_position_for_control_path(scene: Node, control_path: String) -> Vector2:
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

func primary_button_screen_position(scene: Node) -> Vector2:
	return screen_position_for_control_path(scene, "PreviewCenter/PreviewStack/PrimaryCardButton/ContentMargin/ContentColumn/PrimaryActionButton")

func primary_toggle_on(scene: Node) -> bool:
	var panel = scene.get_node("PanelPivot/PanelViewport").get_child(0)
	return bool(panel._target_state("primary").get("toggle_on", false))

func primary_card(scene: Node) -> Button:
	var panel = scene.get_node("PanelPivot/PanelViewport").get_child(0)
	return panel.get_node("PreviewCenter/PreviewStack/PrimaryCardButton") as Button
