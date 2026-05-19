extends GutTest

const SCREEN_HOST_SCENE := preload("res://scenes/glass-shader-test.tscn")
const HYBRID_HOST_SCENE := preload("res://scenes/glass-shader-gui-3d-test.tscn")
const CANONICAL_PANEL_VIEW_SCRIPT_PATH := "res://ui/views/aero_ui_glass_panel_view.gd"


func test_screen_host_mounts_canonical_aeroui_glass_panel_view() -> void:
	var host = SCREEN_HOST_SCENE.instantiate()
	add_child_autofree(host)
	await get_tree().process_frame
	await get_tree().process_frame

	assert_not_null(host._panel_view)
	assert_true(host._panel_view is AeroUiGlassPanelView)
	assert_eq(host._panel_view.get_script().resource_path, CANONICAL_PANEL_VIEW_SCRIPT_PATH)


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
