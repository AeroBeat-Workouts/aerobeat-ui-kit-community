class_name AeroUiGlassPanelView
extends AeroContractConsumerViewBase

# Canonical runtime/view owner for the AeroUiGlass panel architecture.
#
# The YAML-authored style contract lives in typed config objects and preset files; this view
# consumes those configs and owns runtime composition/application. Legacy
# `glass_shader_panel_source` paths exist only as narrow compatibility aliases around this view,
# but `AeroUiGlassPanelView` is the runtime source of truth.
const AeroUiGlassPanelConfigLoader := preload("res://ui/configs/loaders/aero_ui_glass_panel_config_loader.gd")
const AeroUiGlassPanelConfig := preload("res://ui/configs/types/aero_ui_glass_panel_config.gd")
const AeroUiGlassBadgeConfig := preload("res://ui/configs/types/aero_ui_glass_badge_config.gd")
const AeroUiGlassPrimaryButtonConfig := preload("res://ui/configs/types/aero_ui_glass_primary_button_config.gd")
const AeroUiGlassBadgeView := preload("res://ui/views/aero_ui_glass_badge_view.gd")
const AeroUiGlassPrimaryButtonView := preload("res://ui/views/aero_ui_glass_primary_button_view.gd")

const BACKGROUND_IMAGE_PATH := "res://assets/images/perfect-hue-may-08-2026-hd.png"
const DEFAULT_PANEL_STYLE_BUNDLE_PATH := "res://ui/presets/glass/panel/default.yaml"
const TOGGLE_ON_ACCENT := Color(0.4, 0.82, 1.0, 1.0)
const DEFAULT_INTERACTION_SURFACE_ID: StringName = &"hybrid_glass_panel"
const DEFAULT_INTERACTION_BUS_PATH := NodePath("../../../AeroUiInteractionBus")
const INTERACTION_BUS_NODE_NAME := ^"AeroUiInteractionBus"

const BACKGROUND_MODE_IMAGE := 0
const BACKGROUND_MODE_DEBUG := 1
const BACKGROUND_MODE_HYBRID := 2
const BACKGROUND_MODE_NONE := 3
const DEFAULT_BACKGROUND_MODE := BACKGROUND_MODE_HYBRID

const PRESENTATION_MODE_2D := 0
const PRESENTATION_MODE_HYBRID_WORLD_SPACE := 1
const PRESENTATION_MODE_HYBRID_MASK := 2

const TARGET_PRIMARY := "primary"
const TARGET_LABELS := {
	TARGET_PRIMARY: "PrimaryActionButton",
}

const FLOAT_CONTROLS := [
	{
		"name": "blur",
		"label": "blur",
		"min": 0.0,
		"max": 8.0,
		"step": 0.1,
		"default": 4.2,
	},
	{
		"name": "warp_intensity",
		"label": "warp_intensity",
		"min": 0.0,
		"max": 1.0,
		"step": 0.01,
		"default": 0.45,
	},
	{
		"name": "strength_x",
		"label": "strength_x",
		"min": 0.0,
		"max": 50.0,
		"step": 0.1,
		"default": 14.0,
	},
	{
		"name": "strength_y",
		"label": "strength_y",
		"min": 0.0,
		"max": 50.0,
		"step": 0.1,
		"default": 14.0,
	},
	{
		"name": "offset_x",
		"label": "offset_x",
		"min": -1.0,
		"max": 1.0,
		"step": 0.01,
		"default": 0.03,
	},
	{
		"name": "offset_y",
		"label": "offset_y",
		"min": -1.0,
		"max": 1.0,
		"step": 0.01,
		"default": 0.0,
	},
	{
		"name": "corner_radius",
		"label": "corner_radius",
		"min": 0.0,
		"max": 1.0,
		"step": 0.01,
		"default": 0.24,
	},
	{
		"name": "edge_smoothness",
		"label": "edge_smoothness",
		"min": 0.5,
		"max": 3.0,
		"step": 0.01,
		"default": 1.1,
	},
	{
		"name": "edge_width",
		"label": "edge_width",
		"min": 0.0,
		"max": 10.0,
		"step": 0.1,
		"default": 2.4,
	},
	{
		"name": "chromatic_strength",
		"label": "chromatic_strength",
		"min": 0.0,
		"max": 5.0,
		"step": 0.1,
		"default": 2.2,
	},
]

const COLOR_CONTROLS := [
	{
		"name": "tint",
		"label": "tint",
		"default": Color(0.92, 0.96, 1.0, 0.22),
	},
	{
		"name": "edge_highlight",
		"label": "edge_highlight",
		"default": Color(1.0, 1.0, 1.0, 0.62),
	},
]

@onready var background: TextureRect = get_node_or_null("Background") as TextureRect
@onready var primary_card_button: Button = get_node_or_null("PreviewCenter/PreviewStack/PrimaryCardButton") as Button
@onready var hybrid_mask_panel: Panel = get_node_or_null("PreviewCenter/PreviewStack/PrimaryCardButton/HybridMaskPanel") as Panel
@onready var glass_fill: ColorRect = get_node_or_null("PreviewCenter/PreviewStack/PrimaryCardButton/GlassFill") as ColorRect
@onready var preview_frame: Panel = get_node_or_null("PreviewCenter/PreviewStack/PrimaryCardButton/PreviewFrame") as Panel
@onready var preview_inner_border: Panel = get_node_or_null("PreviewCenter/PreviewStack/PrimaryCardButton/InnerBorderInset/PreviewInnerBorder") as Panel
@onready var badge_view: AeroUiGlassBadgeView = get_node_or_null("PreviewCenter/PreviewStack/PrimaryCardButton/ContentMargin/ContentColumn/Badge") as AeroUiGlassBadgeView
@onready var preview_badge: PanelContainer = badge_view
@onready var preview_badge_label: Label = badge_view.badge_label if is_instance_valid(badge_view) else null
@onready var primary_button_view: AeroUiGlassPrimaryButtonView = get_node_or_null("PreviewCenter/PreviewStack/PrimaryCardButton/ContentMargin/ContentColumn/PrimaryActionButton") as AeroUiGlassPrimaryButtonView
@onready var primary_action_button: Button = primary_button_view
@onready var primary_action_body: PanelContainer = primary_button_view.primary_action_body if is_instance_valid(primary_button_view) else null
@onready var primary_action_label: Label = primary_button_view.primary_action_label if is_instance_valid(primary_button_view) else null
@onready var primary_action_meta: Label = primary_button_view.primary_action_meta if is_instance_valid(primary_button_view) else null
@onready var headline_label: Label = get_node_or_null("PreviewCenter/PreviewStack/PrimaryCardButton/ContentMargin/ContentColumn/Headline") as Label
@onready var body_label: Label = get_node_or_null("PreviewCenter/PreviewStack/PrimaryCardButton/ContentMargin/ContentColumn/Body") as Label
@onready var content_margin: MarginContainer = get_node_or_null("PreviewCenter/PreviewStack/PrimaryCardButton/ContentMargin") as MarginContainer
@onready var preview_backdrop_debug: Control = get_node_or_null("PreviewCenter/PreviewStack/PreviewBackdropDebug") as Control


var _shader_material: ShaderMaterial
var _frame_style: StyleBoxFlat
var _inner_border_style: StyleBoxFlat
var _mask_style: StyleBoxFlat
var _background_texture: Texture2D
var _background_mode := DEFAULT_BACKGROUND_MODE
var _presentation_mode := PRESENTATION_MODE_2D
var _panel_style_config: AeroUiGlassPanelConfig
var _badge_style_config: AeroUiGlassBadgeConfig
var _primary_button_style_config: AeroUiGlassPrimaryButtonConfig
var _shell_corner_radius := 0.24
var _shell_edge_width := 2.4
var _shell_tint := Color(0.92, 0.96, 1.0, 0.22)
var _shell_edge_highlight := Color(1.0, 1.0, 1.0, 0.62)
var _frame_alpha_boost := 0.18
var _hybrid_inner_border_brightness := 1.0
var _hybrid_inner_border_alpha := 0.312
var _hybrid_badge_fill_alpha := 0.18
var _hybrid_badge_border_alpha := 0.267
var _hybrid_badge_label_alpha := 0.9
var _last_interaction_event: AeroUiInteractionEvent = null


func _ready() -> void:
	interaction_surface_id = DEFAULT_INTERACTION_SURFACE_ID
	interaction_surface_type_label = "hybrid_3d_gui"
	contract_host_summary = "Canonical AeroUiGlassPanelView with one centered primary target visible in both the 2D and 3D test scenes."
	contract_mode_label = "AeroUiGlassPanelView"

	_background_texture = _load_background_texture()
	background.texture = _background_texture

	_shader_material = glass_fill.material as ShaderMaterial
	if _shader_material == null:
		push_error("Glass fill is missing its ShaderMaterial.")
		return

	_frame_style = preview_frame.get_theme_stylebox("panel") as StyleBoxFlat
	_inner_border_style = preview_inner_border.get_theme_stylebox("panel") as StyleBoxFlat
	if is_instance_valid(badge_view):
		badge_view.refresh_theme()
	_mask_style = hybrid_mask_panel.get_theme_stylebox("panel") as StyleBoxFlat
	_load_startup_panel_style_bundle()

	_configure_primary_card_button()
	super._ready()
	_sync_shell_state_from_shader()
	_apply_visual_state()
	primary_card_button.resized.connect(_sync_preview_shell)
	preview_inner_border.resized.connect(_sync_preview_shell)
	call_deferred("_sync_preview_shell")
	call_deferred("_refresh_interaction_debug")


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		if is_instance_valid(primary_card_button):
			_configure_primary_card_button()
		if is_instance_valid(badge_view):
			badge_view.refresh_theme()


func _build_contract_targets() -> void:
	register_contract_target(TARGET_PRIMARY, primary_action_button, {
		"target_label": TARGET_LABELS[TARGET_PRIMARY],
		"user_state": {"toggle_on": false},
	})


func configure_interaction_contract(config: Dictionary) -> void:
	super.configure_interaction_contract(config)
	if is_node_ready():
		_refresh_interaction_debug()


func _get_default_interaction_bus_path() -> NodePath:
	return DEFAULT_INTERACTION_BUS_PATH


func _get_interaction_bus_node_path() -> NodePath:
	return INTERACTION_BUS_NODE_NAME


func _load_background_texture() -> Texture2D:
	var image := Image.load_from_file(ProjectSettings.globalize_path(BACKGROUND_IMAGE_PATH))
	if image == null or image.is_empty():
		push_error("Unable to load background image at %s" % BACKGROUND_IMAGE_PATH)
		return null
	return ImageTexture.create_from_image(image)


func _configure_primary_card_button() -> void:
	primary_card_button.flat = true
	primary_card_button.toggle_mode = true
	primary_card_button.button_pressed = false
	primary_card_button.focus_mode = Control.FOCUS_NONE
	primary_card_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	primary_card_button.mouse_default_cursor_shape = Control.CURSOR_ARROW
	primary_card_button.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.96))
	primary_card_button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0, 0.96))
	primary_card_button.add_theme_color_override("font_pressed_color", Color(1.0, 1.0, 1.0, 0.96))
	primary_card_button.add_theme_color_override("font_focus_color", Color(1.0, 1.0, 1.0, 0.96))
	primary_card_button.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.28))
	primary_card_button.add_theme_constant_override("outline_size", 2)

	var empty := StyleBoxEmpty.new()
	primary_card_button.add_theme_stylebox_override("normal", empty)
	primary_card_button.add_theme_stylebox_override("hover", empty)
	primary_card_button.add_theme_stylebox_override("pressed", empty)
	primary_card_button.add_theme_stylebox_override("focus", empty)
	primary_card_button.add_theme_stylebox_override("disabled", empty)


func set_background_mode(mode: int) -> void:
	_background_mode = clampi(mode, BACKGROUND_MODE_IMAGE, BACKGROUND_MODE_NONE)
	if is_node_ready():
		_apply_visual_state()


func get_background_mode() -> int:
	return _background_mode


func set_presentation_mode(mode: int) -> void:
	_presentation_mode = clampi(mode, PRESENTATION_MODE_2D, PRESENTATION_MODE_HYBRID_MASK)
	if is_node_ready():
		_apply_visual_state()


func get_presentation_mode() -> int:
	return _presentation_mode


func get_preview_rect_normalized() -> Rect2:
	if primary_card_button == null or size.x <= 0.0 or size.y <= 0.0:
		return Rect2(0.0, 0.0, 1.0, 1.0)

	var rect := primary_card_button.get_global_rect()
	return Rect2(rect.position / size, rect.size / size)


func set_shader_parameter(parameter_name: String, value: Variant) -> void:
	if _shader_material == null:
		return
	_shader_material.set_shader_parameter(parameter_name, value)
	if parameter_name in ["corner_radius", "edge_width", "tint", "edge_highlight"]:
		_sync_shell_state_from_shader()
	_sync_preview_shell()


func get_shader_parameter(parameter_name: String) -> Variant:
	if _shader_material == null:
		return null
	return _shader_material.get_shader_parameter(parameter_name)


func set_shader_parameters(parameters: Dictionary) -> void:
	for parameter_name in parameters.keys():
		set_shader_parameter(str(parameter_name), parameters[parameter_name])


func sync_hybrid_shell(parameters: Dictionary) -> void:
	if parameters.has("corner_radius"):
		_shell_corner_radius = clampf(float(parameters["corner_radius"]), 0.0, 1.0)
	if parameters.has("edge_width"):
		_shell_edge_width = maxf(0.0, float(parameters["edge_width"]))
	if parameters.has("tint") and parameters["tint"] is Color:
		_shell_tint = parameters["tint"]
	if parameters.has("edge_highlight") and parameters["edge_highlight"] is Color:
		_shell_edge_highlight = parameters["edge_highlight"]
	if parameters.has("hybrid_inner_border_brightness"):
		_hybrid_inner_border_brightness = clampf(float(parameters["hybrid_inner_border_brightness"]), 0.0, 2.0)
	if parameters.has("hybrid_inner_border_alpha"):
		_hybrid_inner_border_alpha = clampf(float(parameters["hybrid_inner_border_alpha"]), 0.0, 1.0)
	if parameters.has("hybrid_badge_fill_alpha"):
		_hybrid_badge_fill_alpha = clampf(float(parameters["hybrid_badge_fill_alpha"]), 0.0, 1.0)
	if parameters.has("hybrid_badge_border_alpha"):
		_hybrid_badge_border_alpha = clampf(float(parameters["hybrid_badge_border_alpha"]), 0.0, 1.0)
	if parameters.has("hybrid_badge_label_alpha"):
		_hybrid_badge_label_alpha = clampf(float(parameters["hybrid_badge_label_alpha"]), 0.0, 1.0)
	_sync_preview_shell()


func get_hybrid_shell_parameter(parameter_name: String) -> Variant:
	match parameter_name:
		"hybrid_inner_border_brightness":
			return _hybrid_inner_border_brightness
		"hybrid_inner_border_alpha":
			return _hybrid_inner_border_alpha
		"hybrid_badge_fill_alpha":
			return _hybrid_badge_fill_alpha
		"hybrid_badge_border_alpha":
			return _hybrid_badge_border_alpha
		"hybrid_badge_label_alpha":
			return _hybrid_badge_label_alpha
		_:
			return null


func get_shader_parameters() -> Dictionary:
	var values: Dictionary = {}
	for config in FLOAT_CONTROLS:
		var parameter_name := str(config["name"])
		values[parameter_name] = get_shader_parameter(parameter_name)
	for config in COLOR_CONTROLS:
		var parameter_name := str(config["name"])
		values[parameter_name] = get_shader_parameter(parameter_name)
	return values


func reset_shader_parameters_to_defaults() -> void:
	for config in FLOAT_CONTROLS:
		set_shader_parameter(str(config["name"]), config["default"])
	for config in COLOR_CONTROLS:
		set_shader_parameter(str(config["name"]), config["default"])


func get_panel_style_config() -> AeroUiGlassPanelConfig:
	return _panel_style_config


func get_badge_style_config() -> AeroUiGlassBadgeConfig:
	return _badge_style_config


func get_primary_button_style_config() -> AeroUiGlassPrimaryButtonConfig:
	return _primary_button_style_config


func apply_panel_style_bundle(config: AeroUiGlassPanelConfig) -> void:
	if config == null:
		return
	_panel_style_config = config
	_badge_style_config = config.badge_config
	_primary_button_style_config = config.primary_button_config
	if is_instance_valid(badge_view) and _badge_style_config != null:
		badge_view.set_badge_config(_badge_style_config)
	_apply_panel_style_config(_panel_style_config)
	_refresh_primary_action_visual()
	_refresh_interaction_debug()


func load_panel_style_bundle_from_path(path: String) -> AeroUiGlassPanelConfig:
	var config := AeroUiGlassPanelConfigLoader.load_from_path(path)
	if config == null or config.source_path == "":
		return null
	apply_panel_style_bundle(config)
	return config


func _load_startup_panel_style_bundle() -> void:
	var config := AeroUiGlassPanelConfigLoader.load_from_path(DEFAULT_PANEL_STYLE_BUNDLE_PATH)
	if config == null or config.source_path == "":
		return
	apply_panel_style_bundle(config)


func _apply_panel_style_config(config: AeroUiGlassPanelConfig) -> void:
	if config == null:
		return
	# The panel config owns the authored shell/shader contract and component preset references.
	# This runtime host applies those values onto the existing scene nodes/materials.
	_frame_alpha_boost = config.frame_alpha_boost
	_hybrid_inner_border_brightness = config.hybrid_inner_border_brightness
	_hybrid_inner_border_alpha = config.hybrid_inner_border_alpha
	if config.badge_config != null:
		if is_instance_valid(badge_view):
			badge_view.set_badge_config(config.badge_config)
		var hybrid_badge_tokens := config.badge_config.get_tokens(true)
		_hybrid_badge_fill_alpha = float(hybrid_badge_tokens.get("fill_alpha", _hybrid_badge_fill_alpha))
		_hybrid_badge_border_alpha = float(hybrid_badge_tokens.get("border_alpha", _hybrid_badge_border_alpha))
		_hybrid_badge_label_alpha = float(hybrid_badge_tokens.get("label_alpha", _hybrid_badge_label_alpha))
	set_shader_parameters(config.shader_parameters)


func _apply_visual_state() -> void:
	var is_mask_mode := _presentation_mode == PRESENTATION_MODE_HYBRID_MASK
	var is_hybrid_world := _presentation_mode == PRESENTATION_MODE_HYBRID_WORLD_SPACE

	if is_mask_mode:
		background.visible = false
		preview_backdrop_debug.visible = false
		preview_backdrop_debug.modulate = Color(1.0, 1.0, 1.0, 1.0)
	else:
		match _background_mode:
			BACKGROUND_MODE_DEBUG:
				background.visible = false
				preview_backdrop_debug.visible = true
				preview_backdrop_debug.modulate = Color(1.0, 1.0, 1.0, 1.0)
			BACKGROUND_MODE_HYBRID:
				background.visible = true
				preview_backdrop_debug.visible = true
				preview_backdrop_debug.modulate = Color(1.0, 1.0, 1.0, 0.74)
			BACKGROUND_MODE_NONE:
				background.visible = false
				preview_backdrop_debug.visible = false
				preview_backdrop_debug.modulate = Color(1.0, 1.0, 1.0, 1.0)
			_:
				background.visible = true
				preview_backdrop_debug.visible = false
				preview_backdrop_debug.modulate = Color(1.0, 1.0, 1.0, 1.0)

	glass_fill.visible = _presentation_mode == PRESENTATION_MODE_2D
	preview_frame.visible = _presentation_mode == PRESENTATION_MODE_2D or is_hybrid_world
	preview_inner_border.visible = _presentation_mode == PRESENTATION_MODE_2D or is_hybrid_world
	content_margin.visible = not is_mask_mode
	hybrid_mask_panel.visible = is_mask_mode
	_refresh_interaction_debug()


func _sync_preview_shell() -> void:
	if _shader_material == null:
		return

	var frame_corner_px := _shader_corner_radius_to_pixels(primary_card_button.size, _shell_corner_radius)
	var inner_corner_px := _shader_corner_radius_to_pixels(preview_inner_border.size, _shell_corner_radius)
	var border_width := maxi(1, int(round(maxf(1.0, _shell_edge_width * 1.35))))

	_set_all_corner_radii(_frame_style, frame_corner_px)
	_set_all_corner_radii(_inner_border_style, inner_corner_px)
	_set_all_corner_radii(_mask_style, frame_corner_px)

	_frame_style.border_width_left = border_width
	_frame_style.border_width_top = border_width
	_frame_style.border_width_right = border_width
	_frame_style.border_width_bottom = border_width
	_frame_style.border_color = _shell_edge_highlight.lightened(0.05)
	_frame_style.border_color.a = clampf(_shell_edge_highlight.a + _frame_alpha_boost, 0.28, 0.92)

	var is_hybrid_world := _presentation_mode == PRESENTATION_MODE_HYBRID_WORLD_SPACE
	if is_hybrid_world:
		_frame_style.bg_color = Color(_shell_tint.r, _shell_tint.g, _shell_tint.b, 0.0)
		_frame_style.shadow_size = 0
		_frame_style.shadow_color = Color(_shell_edge_highlight.r, _shell_edge_highlight.g, _shell_edge_highlight.b, 0.0)
	else:
		_frame_style.bg_color = Color(_shell_tint.r, _shell_tint.g, _shell_tint.b, clampf(_shell_tint.a * 0.28, 0.03, 0.12))
		_frame_style.shadow_size = maxi(6, int(round(5.0 + _shell_edge_width * 2.0)))
		_frame_style.shadow_color = Color(_shell_edge_highlight.r, _shell_edge_highlight.g, _shell_edge_highlight.b, clampf(_shell_edge_highlight.a * 0.18, 0.04, 0.18))

	if is_hybrid_world:
		_inner_border_style.border_color = Color(
			_hybrid_inner_border_brightness,
			_hybrid_inner_border_brightness,
			_hybrid_inner_border_brightness,
			_hybrid_inner_border_alpha
		)
		_refresh_badge_visual(true)
	else:
		_inner_border_style.border_color = Color(1.0, 1.0, 1.0, clampf(0.08 + _shell_tint.a * 0.55, 0.08, 0.24))
		_refresh_badge_visual(false)

	_mask_style.bg_color = Color(1.0, 1.0, 1.0, 1.0)
	_mask_style.border_width_left = 0
	_mask_style.border_width_top = 0
	_mask_style.border_width_right = 0
	_mask_style.border_width_bottom = 0
	_mask_style.shadow_size = 0
	_mask_style.shadow_color = Color(0.0, 0.0, 0.0, 0.0)
	_refresh_primary_action_visual()


func _sync_shell_state_from_shader() -> void:
	if _shader_material == null:
		return
	_shell_corner_radius = clampf(float(_shader_material.get_shader_parameter("corner_radius")), 0.0, 1.0)
	_shell_edge_width = maxf(0.0, float(_shader_material.get_shader_parameter("edge_width")))
	_shell_tint = _shader_material.get_shader_parameter("tint")
	_shell_edge_highlight = _shader_material.get_shader_parameter("edge_highlight")


func _apply_primary_card_accent() -> void:
	if _frame_style == null or _inner_border_style == null:
		return

	var state := _target_state(TARGET_PRIMARY)
	var accent_strength := 0.0
	if bool(state.get("toggle_on", false)):
		accent_strength = 1.0
	elif bool(state.get("pressed", false)):
		accent_strength = 0.78
	elif bool(state.get("dragging", false)):
		accent_strength = 0.64
	elif bool(state.get("hovered", false)):
		accent_strength = 0.4

	if accent_strength > 0.0:
		_frame_style.border_color = _frame_style.border_color.lerp(TOGGLE_ON_ACCENT, accent_strength * 0.65)
		_inner_border_style.border_color = _inner_border_style.border_color.lerp(TOGGLE_ON_ACCENT, accent_strength * 0.55)
		if is_instance_valid(badge_view):
			badge_view.apply_accent(TOGGLE_ON_ACCENT, accent_strength)


func _refresh_primary_action_visual() -> void:
	if not is_instance_valid(primary_button_view):
		return

	var is_hybrid_world := _presentation_mode == PRESENTATION_MODE_HYBRID_WORLD_SPACE
	primary_button_view.apply_visual_state(
		_target_state(TARGET_PRIMARY),
		is_hybrid_world,
		_get_badge_tokens(is_hybrid_world),
		_primary_button_style_config,
		_shell_tint,
		TOGGLE_ON_ACCENT
	)


func _refresh_badge_visual(is_hybrid_world: bool) -> void:
	if not is_instance_valid(badge_view):
		return
	var badge_tokens := _hybrid_badge_visual_tokens() if is_hybrid_world else _get_badge_tokens(false)
	badge_view.apply_visual_state(badge_tokens)


func _hybrid_badge_visual_tokens() -> Dictionary:
	var hybrid_badge_tokens := _get_badge_tokens(true).duplicate()
	hybrid_badge_tokens["fill_alpha"] = _hybrid_badge_fill_alpha
	hybrid_badge_tokens["border_alpha"] = _hybrid_badge_border_alpha
	hybrid_badge_tokens["label_alpha"] = _hybrid_badge_label_alpha
	return hybrid_badge_tokens


func _get_badge_tokens(is_hybrid_world: bool) -> Dictionary:
	if is_instance_valid(badge_view):
		return badge_view.get_badge_tokens(is_hybrid_world)
	if _badge_style_config != null:
		return _badge_style_config.get_tokens(is_hybrid_world)
	if is_hybrid_world:
		return {
			"fill_alpha": _hybrid_badge_fill_alpha,
			"border_alpha": _hybrid_badge_border_alpha,
			"label_alpha": _hybrid_badge_label_alpha,
			"radius": 14,
		}
	return {
		"fill_alpha": 0.08,
		"border_alpha": 0.14,
		"label_alpha": 0.78,
		"radius": 14,
	}


func _refresh_target_views() -> void:
	_refresh_interaction_debug()


func _refresh_interaction_debug() -> void:
	if not is_node_ready():
		return

	var primary_state := _target_state(TARGET_PRIMARY)
	var primary_event: AeroUiInteractionEvent = primary_state.get("last_event") as AeroUiInteractionEvent
	var phase_text := "idle"
	var surface_text := String(interaction_surface_id)
	if primary_event != null:
		phase_text = str(primary_event.phase)
		surface_text = str(primary_event.surface_id)
	elif _last_interaction_event != null:
		phase_text = str(_last_interaction_event.phase)
		surface_text = str(_last_interaction_event.surface_id)

	_sync_preview_shell()


func _on_contract_target_interaction(binding: AeroUiContractTargetBinding, event: AeroUiInteractionEvent) -> void:
	_last_interaction_event = event
	_refresh_target_visual(binding.target_key)


func _on_contract_target_tapped(binding: AeroUiContractTargetBinding, event: AeroUiInteractionEvent) -> void:
	if binding.target_key == TARGET_PRIMARY:
		binding.user_state["toggle_on"] = not bool(binding.user_state.get("toggle_on", false))
		primary_card_button.button_pressed = bool(binding.user_state["toggle_on"])
	_notify_contract_target_state_changed(binding)
	_last_interaction_event = event
	_refresh_target_visual(binding.target_key)


func _on_contract_target_canceled(binding: AeroUiContractTargetBinding, event: AeroUiInteractionEvent) -> void:
	_refresh_target_visual(binding.target_key)


func _on_contract_target_state_changed(binding: AeroUiContractTargetBinding) -> void:
	_refresh_target_visual(binding.target_key)


func _refresh_target_visual(target_key: String) -> void:
	match target_key:
		TARGET_PRIMARY:
			_refresh_primary_action_visual()
			_refresh_interaction_debug()
		_:
			_refresh_interaction_debug()


func _display_target_name(target_path_text: String) -> String:
	if target_path_text == "":
		return "none"
	var target_key := str(_path_to_target_key.get(target_path_text, ""))
	if target_key != "":
		return str(TARGET_LABELS[target_key])
	return target_path_text.get_file()


func _target_state(target_key: String) -> Dictionary:
	return _target_states.get(target_key, {}) as Dictionary


func _shader_corner_radius_to_pixels(control_size: Vector2, corner_radius: float) -> int:
	var clamped_radius := clampf(corner_radius, 0.0, 1.0)
	var max_corner_px := minf(control_size.x, control_size.y) * 0.5
	return int(round(clamped_radius * max_corner_px))


func _set_all_corner_radii(stylebox: StyleBoxFlat, radius: int) -> void:
	if stylebox == null:
		return
	stylebox.corner_radius_top_left = radius
	stylebox.corner_radius_top_right = radius
	stylebox.corner_radius_bottom_right = radius
	stylebox.corner_radius_bottom_left = radius
