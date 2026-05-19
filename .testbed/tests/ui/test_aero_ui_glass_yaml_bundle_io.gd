extends GutTest

const SCREEN_HOST_SCENE := preload("res://scenes/glass-shader-test.tscn")
const HYBRID_HOST_SCENE := preload("res://scenes/glass-shader-gui-3d-test.tscn")
const YamlBundleIO := preload("res://scripts/aero_ui_glass_yaml_bundle_io.gd")


func test_screen_host_exports_and_reloads_a_yaml_panel_bundle() -> void:
	var host = SCREEN_HOST_SCENE.instantiate()
	add_child_autofree(host)
	await get_tree().process_frame
	await get_tree().process_frame

	host.set_shader_parameter("blur", 5.5)
	host.set_shader_parameter("chromatic_strength", 3.4)
	var export_path := "user://gut/yaml-bundles/screen-panel-bundle.yaml"
	var export_result := YamlBundleIO.export_panel_bundle(export_path, {
		"panel_config": host._panel_view.get_panel_style_config(),
		"badge_config": host._panel_view.get_badge_style_config(),
		"button_config": host._panel_view.get_primary_button_style_config(),
		"panel_shader_parameters": host._panel_view.get_shader_parameters(),
	})

	assert_true(export_result.get("ok", false))
	assert_true(FileAccess.file_exists(ProjectSettings.globalize_path(YamlBundleIO.ensure_yaml_extension(export_path))))
	assert_true(FileAccess.file_exists(ProjectSettings.globalize_path(YamlBundleIO.ensure_yaml_extension("user://gut/yaml-bundles/screen-panel-bundle.badge"))))
	assert_true(FileAccess.file_exists(ProjectSettings.globalize_path(YamlBundleIO.ensure_yaml_extension("user://gut/yaml-bundles/screen-panel-bundle.button"))))

	var loaded := YamlBundleIO.load_panel_bundle(export_path)
	assert_true(loaded.get("ok", false))
	assert_eq(loaded["panel_config"].shader_parameters["blur"], 5.5)
	assert_eq(loaded["panel_config"].shader_parameters["chromatic_strength"], 3.4)
	assert_true(String(loaded["panel_config"].badge_preset_path).ends_with("screen-panel-bundle.badge.yaml"))
	assert_true(String(loaded["panel_config"].primary_button_preset_path).ends_with("screen-panel-bundle.button.yaml"))


func test_hybrid_host_exports_hybrid_only_material_values_inside_yaml_bundle() -> void:
	var host = HYBRID_HOST_SCENE.instantiate()
	add_child_autofree(host)
	await get_tree().process_frame
	await get_tree().process_frame

	host.set_panel_shader_parameter("body_frost_strength", 0.33)
	host.set_panel_shader_parameter("ui_overlay_brightness", 1.41)
	host.set_panel_shader_parameter("hybrid_badge_fill_alpha", 0.27)
	var export_path := "user://gut/yaml-bundles/hybrid-panel-bundle.yaml"
	var export_result := YamlBundleIO.export_panel_bundle(export_path, host._build_hybrid_yaml_bundle_export())

	assert_true(export_result.get("ok", false))
	var loaded := YamlBundleIO.load_panel_bundle(export_path)
	assert_true(loaded.get("ok", false))
	assert_eq(loaded["hybrid_shader_parameters"]["body_frost_strength"], 0.33)
	assert_eq(loaded["hybrid_shader_parameters"]["ui_overlay_brightness"], 1.41)
	assert_eq(loaded["badge_config"].hybrid_fill_alpha, 0.27)
