extends Control

const BACKGROUND_IMAGE_PATH := "res://assets/images/perfect-hue-may-08-2026-hd.png"
const FRAME_ALPHA_BOOST := 0.18

const BACKGROUND_MODE_IMAGE := 0
const BACKGROUND_MODE_DEBUG := 1
const BACKGROUND_MODE_HYBRID := 2
const DEFAULT_BACKGROUND_MODE := BACKGROUND_MODE_HYBRID

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
@onready var preview_button: Button = get_node_or_null("PreviewCenter/PreviewStack/PreviewButton") as Button
@onready var glass_fill: ColorRect = get_node_or_null("PreviewCenter/PreviewStack/PreviewButton/GlassFill") as ColorRect
@onready var preview_frame: Panel = get_node_or_null("PreviewCenter/PreviewStack/PreviewButton/PreviewFrame") as Panel
@onready var preview_inner_border: Panel = get_node_or_null("PreviewCenter/PreviewStack/PreviewButton/InnerBorderInset/PreviewInnerBorder") as Panel
@onready var preview_backdrop_debug: Control = get_node_or_null("PreviewCenter/PreviewStack/PreviewBackdropDebug") as Control

var _shader_material: ShaderMaterial
var _frame_style: StyleBoxFlat
var _inner_border_style: StyleBoxFlat
var _background_texture: Texture2D
var _background_mode := DEFAULT_BACKGROUND_MODE


func _ready() -> void:
	_background_texture = _load_background_texture()
	background.texture = _background_texture

	_shader_material = glass_fill.material as ShaderMaterial
	if _shader_material == null:
		push_error("Glass fill is missing its ShaderMaterial.")
		return

	_frame_style = preview_frame.get_theme_stylebox("panel") as StyleBoxFlat
	_inner_border_style = preview_inner_border.get_theme_stylebox("panel") as StyleBoxFlat

	_configure_preview_button()
	_apply_background_mode(_background_mode)
	preview_button.resized.connect(_sync_preview_shell)
	preview_inner_border.resized.connect(_sync_preview_shell)
	call_deferred("_sync_preview_shell")


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED and is_instance_valid(preview_button):
		_configure_preview_button()


func _load_background_texture() -> Texture2D:
	var image := Image.load_from_file(ProjectSettings.globalize_path(BACKGROUND_IMAGE_PATH))
	if image == null or image.is_empty():
		push_error("Unable to load background image at %s" % BACKGROUND_IMAGE_PATH)
		return null
	return ImageTexture.create_from_image(image)


func _configure_preview_button() -> void:
	preview_button.flat = true
	preview_button.focus_mode = Control.FOCUS_NONE
	preview_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	preview_button.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.96))
	preview_button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0, 0.96))
	preview_button.add_theme_color_override("font_pressed_color", Color(1.0, 1.0, 1.0, 0.96))
	preview_button.add_theme_color_override("font_focus_color", Color(1.0, 1.0, 1.0, 0.96))
	preview_button.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.28))
	preview_button.add_theme_constant_override("outline_size", 2)

	var empty := StyleBoxEmpty.new()
	preview_button.add_theme_stylebox_override("normal", empty)
	preview_button.add_theme_stylebox_override("hover", empty)
	preview_button.add_theme_stylebox_override("pressed", empty)
	preview_button.add_theme_stylebox_override("focus", empty)
	preview_button.add_theme_stylebox_override("disabled", empty)


func set_background_mode(mode: int) -> void:
	_apply_background_mode(mode)


func get_background_mode() -> int:
	return _background_mode


func set_shader_parameter(parameter_name: String, value: Variant) -> void:
	if _shader_material == null:
		return
	_shader_material.set_shader_parameter(parameter_name, value)
	_sync_preview_shell()


func get_shader_parameter(parameter_name: String) -> Variant:
	if _shader_material == null:
		return null
	return _shader_material.get_shader_parameter(parameter_name)


func set_shader_parameters(parameters: Dictionary) -> void:
	for parameter_name in parameters.keys():
		set_shader_parameter(str(parameter_name), parameters[parameter_name])


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


func _apply_background_mode(mode: int) -> void:
	_background_mode = clampi(mode, BACKGROUND_MODE_IMAGE, BACKGROUND_MODE_HYBRID)
	match _background_mode:
		BACKGROUND_MODE_DEBUG:
			background.visible = false
			preview_backdrop_debug.visible = true
			preview_backdrop_debug.modulate = Color(1.0, 1.0, 1.0, 1.0)
		BACKGROUND_MODE_HYBRID:
			background.visible = true
			preview_backdrop_debug.visible = true
			preview_backdrop_debug.modulate = Color(1.0, 1.0, 1.0, 0.74)
		_:
			background.visible = true
			preview_backdrop_debug.visible = false
			preview_backdrop_debug.modulate = Color(1.0, 1.0, 1.0, 1.0)


func _sync_preview_shell() -> void:
	if _shader_material == null:
		return

	var corner_radius := float(_shader_material.get_shader_parameter("corner_radius"))
	var edge_width := float(_shader_material.get_shader_parameter("edge_width"))
	var tint: Color = _shader_material.get_shader_parameter("tint")
	var edge_highlight: Color = _shader_material.get_shader_parameter("edge_highlight")

	var frame_corner_px := _shader_corner_radius_to_pixels(preview_button.size, corner_radius)
	var inner_corner_px := _shader_corner_radius_to_pixels(preview_inner_border.size, corner_radius)
	var border_width := maxi(1, int(round(maxf(1.0, edge_width * 1.35))))

	_set_all_corner_radii(_frame_style, frame_corner_px)
	_set_all_corner_radii(_inner_border_style, inner_corner_px)

	_frame_style.border_width_left = border_width
	_frame_style.border_width_top = border_width
	_frame_style.border_width_right = border_width
	_frame_style.border_width_bottom = border_width
	_frame_style.bg_color = Color(tint.r, tint.g, tint.b, clampf(tint.a * 0.28, 0.03, 0.12))
	_frame_style.border_color = edge_highlight.lightened(0.05)
	_frame_style.border_color.a = clampf(edge_highlight.a + FRAME_ALPHA_BOOST, 0.28, 0.92)
	_frame_style.shadow_size = maxi(6, int(round(5.0 + edge_width * 2.0)))
	_frame_style.shadow_color = Color(edge_highlight.r, edge_highlight.g, edge_highlight.b, clampf(edge_highlight.a * 0.18, 0.04, 0.18))

	_inner_border_style.border_color = Color(1.0, 1.0, 1.0, clampf(0.08 + tint.a * 0.55, 0.08, 0.24))


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
