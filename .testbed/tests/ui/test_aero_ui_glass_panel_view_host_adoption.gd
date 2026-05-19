extends GutTest

const SCREEN_HOST_SCENE := preload("res://scenes/glass-shader-test.tscn")
const HYBRID_HOST_SCENE := preload("res://scenes/glass-shader-gui-3d-test.tscn")
const CANONICAL_PANEL_VIEW_SCRIPT_PATH := "res://ui/views/aero_ui_glass_panel_view.gd"
const PANEL_YAML_PATH := "res://ui/presets/glass/panel/primary-card-source.v1.yaml"
const STARTUP_STATUS_TEXT := "Startup is using the YAML-backed panel defaults. Load a JSON preset to compare overrides manually."
const HYBRID_STARTUP_STATUS_TEXT := "Startup is using the YAML-backed panel defaults. Load a JSON preset to compare hybrid overrides manually."


func _assert_yaml_backed_panel_defaults(panel: AeroUiGlassPanelView) -> void:
	assert_not_null(panel._panel_style_config)
	assert_eq(panel._panel_style_config.source_path, PANEL_YAML_PATH)


func test_screen_host_mounts_canonical_aeroui_glass_panel_view() -> void:
	var host = SCREEN_HOST_SCENE.instantiate()
	add_child_autofree(host)
	await get_tree().process_frame
	await get_tree().process_frame

	assert_not_null(host._panel_view)
	assert_true(host._panel_view is AeroUiGlassPanelView)
	assert_eq(host._panel_view.get_script().resource_path, CANONICAL_PANEL_VIEW_SCRIPT_PATH)
	_assert_yaml_backed_panel_defaults(host._panel_view)
	assert_eq(host._preset_status_label.text, STARTUP_STATUS_TEXT)


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
	assert_eq(host._preset_status_label.text, HYBRID_STARTUP_STATUS_TEXT)
