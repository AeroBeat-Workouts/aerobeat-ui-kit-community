@tool
extends "res://ui/views/aero_ui_glass_panel_view.gd"

const SCREEN_2D_PANEL_STYLE_BUNDLE_PATH := "res://ui/presets/glass/panel/2d-glass-shader.default.yaml"


func _ready() -> void:
	super._ready()
	contract_host_summary = "Dedicated screen-space AeroUiGlass proof view for the 2D glass shader example."
	contract_mode_label = "Screen2DGlassPanelView"


func _load_startup_panel_style_bundle() -> void:
	var config := PanelConfigLoaderScript.load_from_path(SCREEN_2D_PANEL_STYLE_BUNDLE_PATH)
	if config == null or config.source_path == "":
		return
	apply_panel_style_bundle(config)
