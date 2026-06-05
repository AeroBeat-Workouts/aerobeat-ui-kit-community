extends GutTest

const SCREEN_HOST_SCENE := preload("res://scenes/glass-shader-test.tscn")
const HYBRID_HOST_SCENE := preload("res://scenes/glass-shader-gui-3d-test.tscn")
const YamlBundleIO := preload("res://scripts/aero_ui_glass_yaml_bundle_io.gd")
const HybridBodyConfig := preload("res://ui/configs/types/aero_ui_glass_hybrid_body_config.gd")


func test_screen_host_exports_and_reloads_a_yaml_panel_bundle() -> void:
	var host = SCREEN_HOST_SCENE.instantiate()
	add_child_autofree(host)
	await get_tree().process_frame
	await get_tree().process_frame

	host.set_shader_parameter("blur", 5.5)
	host.set_shader_parameter("chromatic_strength", 3.4)
	host._panel_view.get_badge_style_config().tint = Color(0.75, 0.88, 1.0, 1.0)
	host._panel_view.get_primary_button_style_config().background_tint = Color(0.8, 0.9, 1.0, 1.0)
	host._panel_view.get_primary_button_style_config().source_states["hover"]["scale"] = 1.02
	host._panel_view.get_primary_button_style_config().source_interactions["pressed"]["speed"] = 0.05
	host._panel_view.get_primary_button_style_config().source_interactions["pressed"]["ease_type"] = "crisp"
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
	assert_eq(loaded["badge_config"].tint, Color(0.75, 0.88, 1.0, 1.0))
	assert_eq(loaded["button_config"].background_tint, Color(0.8, 0.9, 1.0, 1.0))
	assert_almost_eq(float(loaded["button_config"].source_states["hover"]["scale"]), 1.02, 0.0001)
	assert_almost_eq(float(loaded["button_config"].source_interactions["pressed"]["speed"]), 0.05, 0.0001)
	assert_eq(str(loaded["button_config"].source_interactions["pressed"]["ease_type"]), "crisp")
	assert_true(String(loaded["panel_config"].badge_preset_path).ends_with("screen-panel-bundle.badge.yaml"))
	assert_true(String(loaded["panel_config"].primary_button_preset_path).ends_with("screen-panel-bundle.button.yaml"))
	assert_false(loaded.has("hybrid_shader_parameters"))


func test_hybrid_panel_bundle_does_not_round_trip_hidden_body_or_overlay_values() -> void:
	var host = HYBRID_HOST_SCENE.instantiate()
	add_child_autofree(host)
	await get_tree().process_frame
	await get_tree().process_frame

	host.set_panel_shader_parameter("body_frost_strength", 0.33)
	host.set_panel_shader_parameter("ui_overlay_brightness", 1.41)
	host.set_panel_shader_parameter("hybrid_badge_fill_alpha", 0.27)
	var export_path := "user://gut/yaml-bundles/hybrid-panel-bundle.yaml"
	var export_result := YamlBundleIO.export_panel_bundle(export_path, host._build_panel_yaml_export())

	assert_true(export_result.get("ok", false))
	var panel_yaml := FileAccess.get_file_as_string(ProjectSettings.globalize_path(YamlBundleIO.ensure_yaml_extension(export_path)))
	assert_eq(panel_yaml.find("testbed_hybrid_shader"), -1)
	assert_eq(panel_yaml.find("body_frost_strength"), -1)
	assert_eq(panel_yaml.find("ui_overlay_brightness"), -1)

	var loaded := YamlBundleIO.load_panel_bundle(export_path)
	assert_true(loaded.get("ok", false))
	assert_false(loaded.has("hybrid_shader_parameters"))
	assert_eq(loaded["badge_config"].hybrid_fill_alpha, 0.27)


func test_loading_panel_bundle_does_not_mutate_hybrid_body_values() -> void:
	var host = HYBRID_HOST_SCENE.instantiate()
	add_child_autofree(host)
	await get_tree().process_frame
	await get_tree().process_frame

	var export_path := "user://gut/yaml-bundles/hybrid-panel-load-no-body-mutation.yaml"
	host.set_panel_shader_parameter("hybrid_badge_fill_alpha", 0.29)
	assert_true(YamlBundleIO.export_panel_bundle(export_path, host._build_panel_yaml_export()).get("ok", false))

	host.set_panel_shader_parameter("body_frost_strength", 0.11)
	host.set_panel_shader_parameter("tint_strength", 0.22)
	host.set_panel_shader_parameter("hybrid_badge_fill_alpha", 0.05)
	host._load_panel_yaml_from_path(export_path)
	await get_tree().process_frame

	assert_almost_eq(float(host.get_panel_shader_parameter("body_frost_strength")), 0.11, 0.0001)
	assert_almost_eq(float(host.get_panel_shader_parameter("tint_strength")), 0.22, 0.0001)
	assert_almost_eq(float(host.get_panel_shader_parameter("hybrid_badge_fill_alpha")), 0.29, 0.0001)


func test_hybrid_body_yaml_round_trips_exact_body_floats_without_mutating_authored_or_overlay_state() -> void:
	var host = HYBRID_HOST_SCENE.instantiate()
	add_child_autofree(host)
	await get_tree().process_frame
	await get_tree().process_frame

	var authored_blur_before := float(host._panel_ui.get_panel_style_config().shader_parameters["blur"])
	var button_border_before := int(host._panel_ui.get_primary_button_style_config().border_width)
	host.set_panel_shader_parameter("tint_strength", 0.21)
	host.set_panel_shader_parameter("body_frost_strength", 0.32)
	host.set_panel_shader_parameter("background_subdue", 0.43)
	host.set_panel_shader_parameter("interior_chroma", 0.54)
	host.set_panel_shader_parameter("world_rim_refraction", 0.16)
	host.set_panel_shader_parameter("fresnel_power", 3.7)
	host.set_panel_shader_parameter("fresnel_strength", 0.28)
	host.set_panel_shader_parameter("face_highlight", 0.09)
	host.set_panel_shader_parameter("face_veil_strength", 0.47)
	host.set_panel_shader_parameter("perimeter_frost_boost", 0.19)
	host.set_panel_shader_parameter("ui_overlay_brightness", 1.41)
	host.set_panel_shader_parameter("ui_alpha_gain", 1.33)
	var body_export_path := "user://gut/yaml-bundles/hybrid-body.yaml"
	var export_result := YamlBundleIO.export_hybrid_body(body_export_path, host._build_hybrid_body_yaml_export())

	assert_true(export_result.get("ok", false))
	var loaded := YamlBundleIO.load_hybrid_body(body_export_path)
	assert_true(loaded.get("ok", false))
	var body_config: HybridBodyConfig = loaded["body_config"] as HybridBodyConfig
	assert_not_null(body_config)
	assert_almost_eq(float(body_config.material_parameters["tint_strength"]), 0.21, 0.0001)
	assert_almost_eq(float(body_config.material_parameters["body_frost_strength"]), 0.32, 0.0001)
	assert_almost_eq(float(body_config.material_parameters["background_subdue"]), 0.43, 0.0001)
	assert_almost_eq(float(body_config.material_parameters["interior_chroma"]), 0.54, 0.0001)
	assert_almost_eq(float(body_config.material_parameters["world_rim_refraction"]), 0.16, 0.0001)
	assert_almost_eq(float(body_config.material_parameters["fresnel_power"]), 3.7, 0.0001)
	assert_almost_eq(float(body_config.material_parameters["fresnel_strength"]), 0.28, 0.0001)
	assert_almost_eq(float(body_config.material_parameters["face_highlight"]), 0.09, 0.0001)
	assert_almost_eq(float(body_config.material_parameters["face_veil_strength"]), 0.47, 0.0001)
	assert_almost_eq(float(body_config.material_parameters["perimeter_frost_boost"]), 0.19, 0.0001)

	host.set_panel_shader_parameter("tint_strength", 0.91)
	host.set_panel_shader_parameter("body_frost_strength", 0.92)
	host.set_panel_shader_parameter("background_subdue", 0.93)
	host.set_panel_shader_parameter("interior_chroma", 0.94)
	host.set_panel_shader_parameter("world_rim_refraction", 0.95)
	host.set_panel_shader_parameter("fresnel_power", 6.6)
	host.set_panel_shader_parameter("fresnel_strength", 0.96)
	host.set_panel_shader_parameter("face_highlight", 0.18)
	host.set_panel_shader_parameter("face_veil_strength", 0.97)
	host.set_panel_shader_parameter("perimeter_frost_boost", 0.31)
	host.set_panel_shader_parameter("ui_overlay_brightness", 0.77)
	host.set_panel_shader_parameter("ui_alpha_gain", 0.88)
	host._panel_ui.get_panel_style_config().shader_parameters["blur"] = 8.8
	host._panel_ui.get_primary_button_style_config().border_width = 7

	host._load_hybrid_body_yaml_from_path(body_export_path)
	await get_tree().process_frame

	assert_almost_eq(float(host.get_panel_shader_parameter("tint_strength")), 0.21, 0.0001)
	assert_almost_eq(float(host.get_panel_shader_parameter("body_frost_strength")), 0.32, 0.0001)
	assert_almost_eq(float(host.get_panel_shader_parameter("background_subdue")), 0.43, 0.0001)
	assert_almost_eq(float(host.get_panel_shader_parameter("interior_chroma")), 0.54, 0.0001)
	assert_almost_eq(float(host.get_panel_shader_parameter("world_rim_refraction")), 0.16, 0.0001)
	assert_almost_eq(float(host.get_panel_shader_parameter("fresnel_power")), 3.7, 0.0001)
	assert_almost_eq(float(host.get_panel_shader_parameter("fresnel_strength")), 0.28, 0.0001)
	assert_almost_eq(float(host.get_panel_shader_parameter("face_highlight")), 0.09, 0.0001)
	assert_almost_eq(float(host.get_panel_shader_parameter("face_veil_strength")), 0.47, 0.0001)
	assert_almost_eq(float(host.get_panel_shader_parameter("perimeter_frost_boost")), 0.19, 0.0001)
	assert_almost_eq(float(host.get_panel_shader_parameter("ui_overlay_brightness")), 0.77, 0.0001)
	assert_almost_eq(float(host.get_panel_shader_parameter("ui_alpha_gain")), 0.88, 0.0001)
	assert_almost_eq(float(host._panel_ui.get_panel_style_config().shader_parameters["blur"]), 8.8, 0.0001)
	assert_eq(host._panel_ui.get_primary_button_style_config().border_width, 7)
	assert_almost_eq(authored_blur_before, 4.2, 0.0001)
	assert_eq(button_border_before, 2)
