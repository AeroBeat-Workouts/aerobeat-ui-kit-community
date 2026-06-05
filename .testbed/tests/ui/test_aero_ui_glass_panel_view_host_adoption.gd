extends GutTest

const SCREEN_HOST_SCENE := preload("res://scenes/glass-shader-test.tscn")
const HYBRID_HOST_SCENE := preload("res://scenes/glass-shader-gui-3d-test.tscn")
const SCREEN_PANEL_VIEW_SCRIPT_PATH := "res://ui/views/screen_2d_glass_panel_view.gd"
const HYBRID_PANEL_VIEW_SCRIPT_PATH := "res://ui/views/aero_ui_glass_panel_view.gd"
const SCREEN_PANEL_YAML_PATH := "res://ui/presets/glass/panel/screen-2d/default.yaml"
const HYBRID_PANEL_YAML_PATH := "res://ui/presets/glass/panel/hybrid-3d/default.yaml"
const SCREEN_STATUS_TEXT := "Panel bundle export writes the root panel YAML plus linked badge/button sidecars. Component buttons still target their authored YAML directly."
const HYBRID_STATUS_TEXT := SCREEN_STATUS_TEXT
const BASE_FORBIDDEN_TEXT_SNIPPETS := [
	"Export or import an AeroUiGlass",
	"Startup is YAML-only",
]
const SCREEN_ONLY_FORBIDDEN_TEXT_SNIPPETS := [
	"interaction status",
	"Screen 2D Glass Panel / Input-Core Contract Proof",
	"Source variant:",
	"Phase:",
	"Surface ID:",
	"Surface type:",
	"Target path:",
	"Mouse capture:",
	"Hover active:",
	"Active touches:",
	"Last contract publish:",
	"Panel, badge, and primary button each load or export their YAML directly.",
]


func _assert_yaml_backed_panel_defaults(panel: AeroUiGlassPanelView, expected_path: String) -> void:
	assert_not_null(panel._panel_style_config)
	assert_eq(panel._panel_style_config.source_path, expected_path)


func _make_local_mouse_motion(local_position: Vector2) -> InputEventMouseMotion:
	var event := InputEventMouseMotion.new()
	event.position = local_position
	event.relative = Vector2.ZERO
	return event


func _make_local_mouse_button(local_position: Vector2, pressed: bool) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	event.position = local_position
	return event


func _collect_visible_label_text(node: Node, texts: Array[String]) -> void:
	if node is Label:
		texts.append((node as Label).text)
	for child in node.get_children():
		_collect_visible_label_text(child, texts)


func _assert_forbidden_preset_copy_removed(root: Node, snippets: Array) -> void:
	var texts: Array[String] = []
	_collect_visible_label_text(root, texts)
	for snippet in snippets:
		var found := false
		for text in texts:
			if text.find(snippet) != -1:
				found = true
				break
		assert_false(found, "Preset helper copy should not contain: %s" % snippet)


func test_screen_host_mounts_canonical_aeroui_glass_panel_view() -> void:
	var host = SCREEN_HOST_SCENE.instantiate()
	add_child_autofree(host)
	await get_tree().process_frame
	await get_tree().process_frame

	assert_not_null(host._panel_view)
	assert_true(host._panel_view is AeroUiGlassPanelView)
	assert_eq(host._panel_view.get_script().resource_path, SCREEN_PANEL_VIEW_SCRIPT_PATH)
	_assert_yaml_backed_panel_defaults(host._panel_view, SCREEN_PANEL_YAML_PATH)
	assert_not_null(host._preset_status_label)
	assert_eq(host._preset_status_label.text, SCREEN_STATUS_TEXT)
	assert_not_null(host._contract_status_label)
	assert_eq(host._contract_status_label.text, "Hovered target: none\nInteraction state: idle")
	assert_gte(host.controls_panel.custom_minimum_size.x, host.INFO_PANEL_MIN_WIDTH)
	assert_eq(host.split_root.split_offset, int(host.INFO_PANEL_MIN_WIDTH))
	_assert_forbidden_preset_copy_removed(host, BASE_FORBIDDEN_TEXT_SNIPPETS + SCREEN_ONLY_FORBIDDEN_TEXT_SNIPPETS)


func test_screen_host_input_debug_readout_stays_two_lines_during_hover_updates() -> void:
	var host = SCREEN_HOST_SCENE.instantiate()
	add_child_autofree(host)
	await get_tree().process_frame
	await get_tree().process_frame

	var status: RichTextLabel = host._contract_status_label
	assert_not_null(status)
	var idle_height := status.get_content_height()
	var button := host._proof_button as Control
	assert_not_null(button)

	host._on_proof_button_mouse_entered()
	await get_tree().process_frame
	await get_tree().process_frame

	assert_eq(status.text, "Hovered target: PrimaryActionButton\nInteraction state: hover")
	assert_eq(status.get_content_height(), idle_height)


func test_screen_host_disables_adapter_global_input_capture_and_keeps_manual_bridge() -> void:
	var host = SCREEN_HOST_SCENE.instantiate()
	add_child_autofree(host)
	await get_tree().process_frame
	await get_tree().process_frame

	assert_not_null(host.screen_input_adapter)
	assert_false(host.screen_input_adapter.is_processing_input())

	var button := host._proof_button as Control
	assert_not_null(button)
	var hover := _make_local_mouse_motion(button.size * 0.5)
	assert_true(host._publish_native_targeted_event(hover))
	await get_tree().process_frame
	assert_eq(host._contract_status_label.text, "Hovered target: PrimaryActionButton\nInteraction state: hover")


func test_screen_host_ignores_foreign_adapter_press_state_when_deciding_off_target_motion_ownership() -> void:
	var host = SCREEN_HOST_SCENE.instantiate()
	add_child_autofree(host)
	await get_tree().process_frame
	await get_tree().process_frame

	var controls_panel := host.get_node("SplitRoot/ControlsPanel") as Control
	assert_not_null(controls_panel)
	var pointer_id = host.screen_input_adapter._hover_pointer_id
	host.screen_input_adapter._pointer_states[pointer_id] = {
		"pressed": true,
		"dragging": false,
		"hovering": false,
		"hover_target_path": controls_panel.get_path(),
		"owner_target_path": controls_panel.get_path(),
		"target_path": controls_panel.get_path(),
		"press_screen_position": Vector2(20.0, 20.0),
		"last_screen_position": Vector2(20.0, 20.0),
		"last_surface_position": Vector2.ZERO,
		"button": AeroUiInteractionTypes.BUTTON_PRIMARY,
	}

	assert_false(host._has_native_mouse_press_owner())
	var off_target_motion := InputEventMouseMotion.new()
	off_target_motion.position = Vector2(32.0, 32.0)
	off_target_motion.relative = Vector2(4.0, 0.0)
	off_target_motion.button_mask = MOUSE_BUTTON_MASK_LEFT
	assert_false(host._publish_native_mouse_motion_fallback(off_target_motion))
	assert_false(host._last_forwarded_panel_event.begins_with("native empty-target publish"))


func test_screen_host_mouse_entered_publishes_explicit_hover_for_contract_bound_button() -> void:
	var host = SCREEN_HOST_SCENE.instantiate()
	add_child_autofree(host)
	await get_tree().process_frame
	await get_tree().process_frame

	host._on_proof_button_mouse_entered()
	await get_tree().process_frame
	await get_tree().process_frame

	assert_eq(host._contract_status_label.text, "Hovered target: PrimaryActionButton\nInteraction state: hover")
	assert_eq(host._panel_view.primary_button_view._last_visual_phase, "hover")
	assert_eq(host._last_contract_phase, "hover_enter")
	assert_string_contains(host._last_forwarded_panel_event, "synthetic hover enter")


func test_hybrid_host_mounts_canonical_aeroui_glass_panel_view_in_both_subviewports() -> void:
	var host = HYBRID_HOST_SCENE.instantiate()
	add_child_autofree(host)
	await get_tree().process_frame
	await get_tree().process_frame

	assert_not_null(host._panel_ui)
	assert_not_null(host._mask_ui)
	assert_true(host._panel_ui is AeroUiGlassPanelView)
	assert_true(host._mask_ui is AeroUiGlassPanelView)
	assert_eq(host._panel_ui.get_script().resource_path, HYBRID_PANEL_VIEW_SCRIPT_PATH)
	assert_eq(host._mask_ui.get_script().resource_path, HYBRID_PANEL_VIEW_SCRIPT_PATH)
	assert_eq(host._panel_ui.get_presentation_mode(), host._panel_ui.PRESENTATION_MODE_HYBRID_WORLD_SPACE)
	assert_eq(host._mask_ui.get_presentation_mode(), host._mask_ui.PRESENTATION_MODE_HYBRID_MASK)
	_assert_yaml_backed_panel_defaults(host._panel_ui, HYBRID_PANEL_YAML_PATH)
	_assert_yaml_backed_panel_defaults(host._mask_ui, HYBRID_PANEL_YAML_PATH)
	assert_eq(host._preset_status_label.text, HYBRID_STATUS_TEXT)
	_assert_forbidden_preset_copy_removed(host, BASE_FORBIDDEN_TEXT_SNIPPETS)


func test_screen_host_release_outside_card_emits_hover_exit_and_returns_idle() -> void:
	var host = SCREEN_HOST_SCENE.instantiate()
	add_child_autofree(host)
	await get_tree().process_frame
	await get_tree().process_frame

	var button := host._proof_button as Control
	assert_not_null(button)
	var rect := button.get_global_rect()
	var local_inside := button.size * 0.5
	var outside := rect.position + Vector2(rect.size.x + 24.0, rect.size.y * 0.5)

	var hover := _make_local_mouse_motion(local_inside)
	assert_true(host._publish_native_targeted_event(hover))
	await get_tree().process_frame
	assert_eq(host._contract_status_label.text, "Hovered target: PrimaryActionButton\nInteraction state: hover")
	assert_eq(host._panel_view.primary_button_view._last_visual_phase, "hover")

	var press := _make_local_mouse_button(local_inside, true)
	assert_true(host._publish_native_targeted_event(press))
	await get_tree().process_frame
	assert_eq(host._contract_status_label.text, "Hovered target: PrimaryActionButton\nInteraction state: pressed")

	host._on_proof_button_mouse_exited()
	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.pressed = false
	release.position = outside
	assert_true(host._publish_native_mouse_button_fallback(release))
	await get_tree().process_frame
	assert_eq(host._contract_status_label.text, "Hovered target: none\nInteraction state: idle")
	assert_eq(host._panel_view.primary_button_view._last_visual_phase, "rest")
	assert_eq(host._last_contract_phase, "hover_exit")


func test_screen_host_gui_input_local_coordinates_are_normalized_to_viewport_hover() -> void:
	var host = SCREEN_HOST_SCENE.instantiate()
	add_child_autofree(host)
	await get_tree().process_frame
	await get_tree().process_frame

	var button := host._proof_button as Control
	assert_not_null(button)
	var local_inside := button.size * 0.5
	var expected_screen_position := button.get_global_transform_with_canvas() * local_inside

	var hover := _make_local_mouse_motion(local_inside)
	host._on_proof_button_gui_input(hover)
	await get_tree().process_frame
	await get_tree().process_frame

	assert_eq(host._contract_status_label.text, "Hovered target: PrimaryActionButton\nInteraction state: hover")
	var hover_state: Dictionary = host.screen_input_adapter._pointer_states.get(host.screen_input_adapter._hover_pointer_id, {})
	assert_eq(hover_state.get("last_screen_position", Vector2.ZERO), expected_screen_position)
	assert_eq(hover_state.get("last_surface_position", Vector2.ZERO), local_inside)


func test_screen_host_input_release_outside_card_emits_hover_exit_and_returns_idle() -> void:
	var host = SCREEN_HOST_SCENE.instantiate()
	add_child_autofree(host)
	await get_tree().process_frame
	await get_tree().process_frame

	var button := host._proof_button as Control
	assert_not_null(button)
	var rect := button.get_global_rect()
	var local_inside := button.size * 0.5
	var outside := rect.position + Vector2(rect.size.x + 24.0, rect.size.y * 0.5)

	var hover := _make_local_mouse_motion(local_inside)
	host._on_proof_button_gui_input(hover)
	await get_tree().process_frame
	assert_eq(host._contract_status_label.text, "Hovered target: PrimaryActionButton\nInteraction state: hover")

	var press := _make_local_mouse_button(local_inside, true)
	host._on_proof_button_gui_input(press)
	await get_tree().process_frame
	assert_eq(host._contract_status_label.text, "Hovered target: PrimaryActionButton\nInteraction state: pressed")

	host._on_proof_button_mouse_exited()
	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.pressed = false
	release.position = outside
	assert_true(host._publish_mouse_button_to_contract(release))
	await get_tree().process_frame
	assert_eq(host._contract_status_label.text, "Hovered target: none\nInteraction state: idle")
	assert_eq(host._panel_view.primary_button_view._last_visual_phase, "rest")
	assert_eq(host._last_contract_phase, "hover_exit")


func test_screen_host_window_mouse_exit_clears_hover_and_returns_idle() -> void:
	var host = SCREEN_HOST_SCENE.instantiate()
	add_child_autofree(host)
	await get_tree().process_frame
	await get_tree().process_frame

	var button := host._proof_button as Control
	assert_not_null(button)
	var hover := _make_local_mouse_motion(button.size * 0.5)
	host._on_proof_button_gui_input(hover)
	await get_tree().process_frame
	assert_eq(host._contract_status_label.text, "Hovered target: PrimaryActionButton\nInteraction state: hover")
	assert_eq(host._panel_view.primary_button_view._last_visual_phase, "hover")

	host._notification(NOTIFICATION_WM_MOUSE_EXIT)
	await get_tree().process_frame
	assert_eq(host._contract_status_label.text, "Hovered target: none\nInteraction state: idle")
	assert_eq(host._panel_view.primary_button_view._last_visual_phase, "rest")
	assert_eq(host._last_contract_phase, "hover_exit")
