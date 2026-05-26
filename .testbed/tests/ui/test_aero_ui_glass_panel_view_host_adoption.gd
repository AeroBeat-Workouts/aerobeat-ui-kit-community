extends GutTest

const SCREEN_HOST_SCENE := preload("res://scenes/glass-shader-test.tscn")
const HYBRID_HOST_SCENE := preload("res://scenes/glass-shader-gui-3d-test.tscn")
const CANONICAL_PANEL_VIEW_SCRIPT_PATH := "res://ui/views/aero_ui_glass_panel_view.gd"
const PANEL_YAML_PATH := "res://ui/presets/glass/panel/default.yaml"
const HYBRID_STATUS_TEXT := "Panel, badge, and primary button each target their authored YAML directly."
const BASE_FORBIDDEN_TEXT_SNIPPETS := [
	"Export or import an AeroUiGlass",
	"Startup is YAML-only",
	"bundle",
]
const SCREEN_ONLY_FORBIDDEN_TEXT_SNIPPETS := [
	"yaml status",
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


func _assert_yaml_backed_panel_defaults(panel: AeroUiGlassPanelView) -> void:
	assert_not_null(panel._panel_style_config)
	assert_eq(panel._panel_style_config.source_path, PANEL_YAML_PATH)


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
	assert_eq(host._panel_view.get_script().resource_path, CANONICAL_PANEL_VIEW_SCRIPT_PATH)
	_assert_yaml_backed_panel_defaults(host._panel_view)
	assert_null(host._preset_status_label)
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
	assert_eq(host._panel_ui.get_script().resource_path, CANONICAL_PANEL_VIEW_SCRIPT_PATH)
	assert_eq(host._mask_ui.get_script().resource_path, CANONICAL_PANEL_VIEW_SCRIPT_PATH)
	assert_eq(host._panel_ui.get_presentation_mode(), host._panel_ui.PRESENTATION_MODE_HYBRID_WORLD_SPACE)
	assert_eq(host._mask_ui.get_presentation_mode(), host._mask_ui.PRESENTATION_MODE_HYBRID_MASK)
	_assert_yaml_backed_panel_defaults(host._panel_ui)
	_assert_yaml_backed_panel_defaults(host._mask_ui)
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
	var inside := rect.get_center()
	var outside := rect.position + Vector2(rect.size.x + 24.0, rect.size.y * 0.5)

	var hover := InputEventMouseMotion.new()
	hover.position = inside
	hover.relative = Vector2.ZERO
	assert_true(host._publish_native_targeted_event(hover))
	await get_tree().process_frame
	assert_eq(host._contract_status_label.text, "Hovered target: PrimaryActionButton\nInteraction state: hover")
	assert_eq(host._panel_view.primary_button_view._last_visual_phase, "hover")

	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = inside
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


func test_screen_host_input_release_outside_card_emits_hover_exit_and_returns_idle() -> void:
	var host = SCREEN_HOST_SCENE.instantiate()
	add_child_autofree(host)
	await get_tree().process_frame
	await get_tree().process_frame

	var button := host._proof_button as Control
	assert_not_null(button)
	var rect := button.get_global_rect()
	var inside := rect.get_center()
	var outside := rect.position + Vector2(rect.size.x + 24.0, rect.size.y * 0.5)

	var hover := InputEventMouseMotion.new()
	hover.position = inside
	hover.relative = Vector2.ZERO
	host._on_proof_button_gui_input(hover)
	await get_tree().process_frame
	assert_eq(host._contract_status_label.text, "Hovered target: PrimaryActionButton\nInteraction state: hover")

	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = inside
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
	var hover := InputEventMouseMotion.new()
	hover.position = button.get_global_rect().get_center()
	hover.relative = Vector2.ZERO
	host._on_proof_button_gui_input(hover)
	await get_tree().process_frame
	assert_eq(host._contract_status_label.text, "Hovered target: PrimaryActionButton\nInteraction state: hover")
	assert_eq(host._panel_view.primary_button_view._last_visual_phase, "hover")

	host._notification(NOTIFICATION_WM_MOUSE_EXIT)
	await get_tree().process_frame
	assert_eq(host._contract_status_label.text, "Hovered target: none\nInteraction state: idle")
	assert_eq(host._panel_view.primary_button_view._last_visual_phase, "rest")
	assert_eq(host._last_contract_phase, "hover_exit")
