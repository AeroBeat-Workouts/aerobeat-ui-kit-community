extends GutTest

const PanelLoader := preload("res://ui/configs/loaders/aero_ui_glass_panel_config_loader.gd")
const BadgeLoader := preload("res://ui/configs/loaders/aero_ui_glass_badge_config_loader.gd")


func test_panel_bundle_loader_materializes_typed_child_configs() -> void:
	var config = PanelLoader.load_from_path("res://ui/presets/glass/panel/primary-card-source.v1.yaml")

	assert_eq(config.variant, "primary-card-source")
	assert_eq(config.version, "v1")
	assert_eq(config.source_path, "res://ui/presets/glass/panel/primary-card-source.v1.yaml")
	assert_eq(config.badge_preset_path, "res://ui/presets/glass/badge/default.yaml")
	assert_eq(config.primary_button_preset_path, "res://ui/presets/glass/button/primary/literal-badge.v1.yaml")
	assert_not_null(config.badge_config)
	assert_not_null(config.primary_button_config)
	assert_eq(config.badge_config.variant, "default")
	assert_eq(config.primary_button_config.variant, "literal-badge")
	assert_almost_eq(float(config.shader_parameters["blur"]), 4.2, 0.0001)
	assert_eq(config.shader_parameters["tint"], Color(0.92, 0.96, 1.0, 0.22))
	assert_almost_eq(config.frame_alpha_boost, 0.18, 0.0001)
	assert_almost_eq(config.hybrid_inner_border_alpha, 0.312, 0.0001)


func test_badge_loader_resolves_same_schema_extends_without_cross_schema_coupling() -> void:
	var config = BadgeLoader.load_from_path("res://tests/fixtures/ui/glass/badge/extended.yaml")
	var source_tokens := config.get_tokens(false)
	var hybrid_tokens := config.get_tokens(true)

	assert_eq(config.variant, "test-extended")
	assert_eq(config.version, "v2")
	assert_eq(int(source_tokens["radius"]), 12)
	assert_almost_eq(float(source_tokens["fill_alpha"]), 0.05, 0.0001)
	assert_almost_eq(float(source_tokens["border_alpha"]), 0.24, 0.0001)
	assert_almost_eq(float(source_tokens["label_alpha"]), 0.70, 0.0001)
	assert_almost_eq(float(hybrid_tokens["fill_alpha"]), 0.16, 0.0001)
	assert_almost_eq(float(hybrid_tokens["border_alpha"]), 0.22, 0.0001)
	assert_almost_eq(float(hybrid_tokens["label_alpha"]), 0.93, 0.0001)


func test_badge_loader_rejects_cross_schema_extends() -> void:
	var config = BadgeLoader.load_from_path("res://tests/fixtures/ui/glass/badge/cross_schema_extends_panel.yaml")
	var source_tokens := config.get_tokens(false)

	assert_push_error("Badge preset schema mismatch in res://tests/fixtures/ui/glass/panel/base.yaml: expected aero.ui.glass_badge, got aero.ui.glass_panel")
	assert_eq(config.variant, "default")
	assert_eq(config.version, "v1")
	assert_eq(config.source_path, "")
	assert_eq(int(source_tokens["radius"]), 14)
	assert_almost_eq(float(source_tokens["fill_alpha"]), 0.08, 0.0001)
	assert_almost_eq(float(source_tokens["border_alpha"]), 0.14, 0.0001)
	assert_almost_eq(float(source_tokens["label_alpha"]), 0.78, 0.0001)
