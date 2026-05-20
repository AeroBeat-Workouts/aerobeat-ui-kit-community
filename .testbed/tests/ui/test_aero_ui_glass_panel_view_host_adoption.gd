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
	"Panel, badge, and primary button each load or export their authored YAML directly.",
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
	assert_null(host._contract_status_label)
	_assert_forbidden_preset_copy_removed(host, BASE_FORBIDDEN_TEXT_SNIPPETS + SCREEN_ONLY_FORBIDDEN_TEXT_SNIPPETS)


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
