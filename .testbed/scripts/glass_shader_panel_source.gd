extends Control

const BACKGROUND_IMAGE_PATH := "res://assets/images/perfect-hue-may-08-2026-hd.png"
const FRAME_ALPHA_BOOST := 0.18
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

const HYBRID_SHELL_DEFAULTS := {
	"hybrid_inner_border_brightness": 1.0,
	"hybrid_inner_border_alpha": 0.312,
	"hybrid_badge_fill_alpha": 0.18,
	"hybrid_badge_border_alpha": 0.267,
	"hybrid_badge_label_alpha": 0.9,
}

@onready var background: TextureRect = get_node_or_null("Background") as TextureRect
@onready var preview_button: Button = get_node_or_null("PreviewCenter/PreviewStack/PreviewButton") as Button
@onready var hybrid_mask_panel: Panel = get_node_or_null("PreviewCenter/PreviewStack/PreviewButton/HybridMaskPanel") as Panel
@onready var glass_fill: ColorRect = get_node_or_null("PreviewCenter/PreviewStack/PreviewButton/GlassFill") as ColorRect
@onready var preview_frame: Panel = get_node_or_null("PreviewCenter/PreviewStack/PreviewButton/PreviewFrame") as Panel
@onready var preview_inner_border: Panel = get_node_or_null("PreviewCenter/PreviewStack/PreviewButton/InnerBorderInset/PreviewInnerBorder") as Panel
@onready var preview_badge: PanelContainer = get_node_or_null("PreviewCenter/PreviewStack/PreviewButton/ContentMargin/ContentColumn/Badge") as PanelContainer
@onready var preview_badge_label: Label = get_node_or_null("PreviewCenter/PreviewStack/PreviewButton/ContentMargin/ContentColumn/Badge/BadgePadding/BadgeLabel") as Label
@onready var headline_label: Label = get_node_or_null("PreviewCenter/PreviewStack/PreviewButton/ContentMargin/ContentColumn/Headline") as Label
@onready var body_label: Label = get_node_or_null("PreviewCenter/PreviewStack/PreviewButton/ContentMargin/ContentColumn/Body") as Label
@onready var hint_label: Label = get_node_or_null("PreviewCenter/PreviewStack/PreviewButton/ContentMargin/ContentColumn/HintLabel") as Label
@onready var interaction_source_label: Label = get_node_or_null("PreviewCenter/PreviewStack/PreviewButton/ContentMargin/ContentColumn/InteractionStatePanel/InteractionStatePadding/InteractionStateColumn/InteractionSourceLabel") as Label
@onready var interaction_pointer_label: Label = get_node_or_null("PreviewCenter/PreviewStack/PreviewButton/ContentMargin/ContentColumn/InteractionStatePanel/InteractionStatePadding/InteractionStateColumn/InteractionPointerLabel") as Label
@onready var interaction_toggle_label: Label = get_node_or_null("PreviewCenter/PreviewStack/PreviewButton/ContentMargin/ContentColumn/InteractionStatePanel/InteractionStatePadding/InteractionStateColumn/InteractionToggleLabel") as Label
@onready var interaction_count_label: Label = get_node_or_null("PreviewCenter/PreviewStack/PreviewButton/ContentMargin/ContentColumn/InteractionStatePanel/InteractionStatePadding/InteractionStateColumn/InteractionCountLabel") as Label
@onready var content_margin: MarginContainer = get_node_or_null("PreviewCenter/PreviewStack/PreviewButton/ContentMargin") as MarginContainer
@onready var preview_backdrop_debug: Control = get_node_or_null("PreviewCenter/PreviewStack/PreviewBackdropDebug") as Control

var _shader_material: ShaderMaterial
var _frame_style: StyleBoxFlat
var _inner_border_style: StyleBoxFlat
var _badge_style: StyleBoxFlat
var _mask_style: StyleBoxFlat
var _background_texture: Texture2D
var _background_mode := DEFAULT_BACKGROUND_MODE
var _presentation_mode := PRESENTATION_MODE_2D
var _shell_corner_radius := 0.24
var _shell_edge_width := 2.4
var _shell_tint := Color(0.92, 0.96, 1.0, 0.22)
var _shell_edge_highlight := Color(1.0, 1.0, 1.0, 0.62)
var _hybrid_inner_border_brightness := float(HYBRID_SHELL_DEFAULTS["hybrid_inner_border_brightness"])
var _hybrid_inner_border_alpha := float(HYBRID_SHELL_DEFAULTS["hybrid_inner_border_alpha"])
var _hybrid_badge_fill_alpha := float(HYBRID_SHELL_DEFAULTS["hybrid_badge_fill_alpha"])
var _hybrid_badge_border_alpha := float(HYBRID_SHELL_DEFAULTS["hybrid_badge_border_alpha"])
var _hybrid_badge_label_alpha := float(HYBRID_SHELL_DEFAULTS["hybrid_badge_label_alpha"])
var _hover_active := false
var _press_active := false
var _drag_active := false
var _last_input_source := "waiting"
var _last_pointer_summary := "idle"
var _press_count := 0
var _release_count := 0
var _drag_count := 0
var _toggle_count := 0
var _mouse_event_count := 0
var _touch_event_count := 0
var _last_interaction_event: AeroUiInteractionEvent = null
var _ui_interactable: AeroUiInteractable
var _ui_listener: AeroUiInteractionListener
var _interaction_bus_path_override: NodePath = NodePath()
var _interaction_surface_id: StringName = DEFAULT_INTERACTION_SURFACE_ID
var _contract_surface_type_label := "hybrid_3d_gui"
var _contract_host_summary := "Hybrid world hits now feed AeroUiInteractionBus through HybridSubViewportInputAdapter. This card reacts to normalized phases instead of raw gui_input parsing."
var _contract_host_mode_label := "Hybrid contract proof"


func _ready() -> void:
	_background_texture = _load_background_texture()
	background.texture = _background_texture

	_shader_material = glass_fill.material as ShaderMaterial
	if _shader_material == null:
		push_error("Glass fill is missing its ShaderMaterial.")
		return

	_frame_style = preview_frame.get_theme_stylebox("panel") as StyleBoxFlat
	_inner_border_style = preview_inner_border.get_theme_stylebox("panel") as StyleBoxFlat
	_badge_style = preview_badge.get_theme_stylebox("panel") as StyleBoxFlat
	_mask_style = hybrid_mask_panel.get_theme_stylebox("panel") as StyleBoxFlat

	_configure_preview_button()
	_setup_contract_consumers()
	call_deferred("_bind_contract_consumers_to_runtime_bus")
	_sync_shell_state_from_shader()
	_apply_visual_state()
	preview_button.resized.connect(_sync_preview_shell)
	preview_inner_border.resized.connect(_sync_preview_shell)
	call_deferred("_sync_preview_shell")
	call_deferred("_refresh_interaction_debug")


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
	preview_button.toggle_mode = true
	preview_button.button_pressed = false
	preview_button.focus_mode = Control.FOCUS_NONE
	preview_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
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


func _setup_contract_consumers() -> void:
	if not is_instance_valid(preview_button):
		return

	var target_path := preview_button.get_path()
	if _ui_interactable == null:
		_ui_interactable = AeroUiInteractable.new()
		_ui_interactable.name = "AeroUiInteractable"
		add_child(_ui_interactable)
	if _ui_listener == null:
		_ui_listener = AeroUiInteractionListener.new()
		_ui_listener.name = "AeroUiInteractionListener"
		add_child(_ui_listener)

	for consumer in [_ui_interactable, _ui_listener]:
		consumer.bus_path = DEFAULT_INTERACTION_BUS_PATH
		consumer.surface_id_filter = _interaction_surface_id
		consumer.target_path_filter = target_path

	_bind_contract_consumers_to_runtime_bus()

	if not _ui_interactable.hovered_changed.is_connected(_on_interactable_hovered_changed):
		_ui_interactable.hovered_changed.connect(_on_interactable_hovered_changed)
	if not _ui_interactable.pressed_changed.is_connected(_on_interactable_pressed_changed):
		_ui_interactable.pressed_changed.connect(_on_interactable_pressed_changed)
	if not _ui_interactable.dragging_changed.is_connected(_on_interactable_dragging_changed):
		_ui_interactable.dragging_changed.connect(_on_interactable_dragging_changed)
	if not _ui_interactable.canceled.is_connected(_on_interactable_canceled):
		_ui_interactable.canceled.connect(_on_interactable_canceled)
	if not _ui_listener.interaction_event.is_connected(_on_listener_interaction_event):
		_ui_listener.interaction_event.connect(_on_listener_interaction_event)
	if not _ui_listener.tapped.is_connected(_on_listener_tapped):
		_ui_listener.tapped.connect(_on_listener_tapped)


func set_interaction_bus_path(bus_path: NodePath) -> void:
	_interaction_bus_path_override = bus_path
	_bind_contract_consumers_to_runtime_bus()


func configure_interaction_contract(config: Dictionary) -> void:
	if config.has("surface_id"):
		_interaction_surface_id = StringName(config["surface_id"])
	if config.has("surface_type_label"):
		_contract_surface_type_label = str(config["surface_type_label"])
	if config.has("host_summary"):
		_contract_host_summary = str(config["host_summary"])
	if config.has("mode_label"):
		_contract_host_mode_label = str(config["mode_label"])
	if config.has("interaction_bus_path"):
		set_interaction_bus_path(config["interaction_bus_path"])

	for consumer in [_ui_interactable, _ui_listener]:
		if is_instance_valid(consumer):
			consumer.surface_id_filter = _interaction_surface_id

	if is_node_ready():
		_refresh_interaction_debug()


func _bind_contract_consumers_to_runtime_bus() -> void:
	var bus := _resolve_interaction_bus()
	if bus == null:
		return

	for consumer in [_ui_interactable, _ui_listener]:
		if not is_instance_valid(consumer):
			continue
		consumer.bus_path = bus.get_path()
		var handler := Callable(consumer, "_on_bus_interaction_event")
		if not bus.interaction_event.is_connected(handler):
			bus.interaction_event.connect(handler)


func _resolve_interaction_bus() -> AeroUiInteractionBus:
	if _interaction_bus_path_override != NodePath():
		return get_node_or_null(_interaction_bus_path_override) as AeroUiInteractionBus

	var fallback_bus := get_node_or_null(DEFAULT_INTERACTION_BUS_PATH) as AeroUiInteractionBus
	if fallback_bus != null:
		return fallback_bus

	var ancestor: Node = self
	while ancestor != null:
		var bus := ancestor.get_node_or_null(INTERACTION_BUS_NODE_NAME) as AeroUiInteractionBus
		if bus != null:
			return bus
		ancestor = ancestor.get_parent()
	return null


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
	if preview_button == null or size.x <= 0.0 or size.y <= 0.0:
		return Rect2(0.0, 0.0, 1.0, 1.0)

	var rect := preview_button.get_global_rect()
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
	# Hybrid shell sync is intentionally limited to authored shell-alignment values.
	# The authored PreviewFrame highlight is overlay-owned and should not mirror hybrid body edge_color.
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

	var frame_corner_px := _shader_corner_radius_to_pixels(preview_button.size, _shell_corner_radius)
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
	_frame_style.border_color.a = clampf(_shell_edge_highlight.a + FRAME_ALPHA_BOOST, 0.28, 0.92)

	var is_hybrid_world := _presentation_mode == PRESENTATION_MODE_HYBRID_WORLD_SPACE
	if is_hybrid_world:
		# In hybrid world mode the front overlay owns the crisp rim/inner line only.
		# The frosted body fill must come exclusively from the world-space shader.
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
		_badge_style.bg_color = Color(1.0, 1.0, 1.0, _hybrid_badge_fill_alpha)
		_badge_style.border_color = Color(1.0, 1.0, 1.0, _hybrid_badge_border_alpha)
		if is_instance_valid(preview_badge_label):
			preview_badge_label.modulate = Color(1.0, 1.0, 1.0, _hybrid_badge_label_alpha)
	else:
		_inner_border_style.border_color = Color(1.0, 1.0, 1.0, clampf(0.08 + _shell_tint.a * 0.55, 0.08, 0.24))
		_badge_style.bg_color = Color(1.0, 1.0, 1.0, 0.08)
		_badge_style.border_color = Color(1.0, 1.0, 1.0, 0.14)
		if is_instance_valid(preview_badge_label):
			preview_badge_label.modulate = Color(1.0, 1.0, 1.0, 0.78)

	_mask_style.bg_color = Color(1.0, 1.0, 1.0, 1.0)
	_mask_style.border_width_left = 0
	_mask_style.border_width_top = 0
	_mask_style.border_width_right = 0
	_mask_style.border_width_bottom = 0
	_mask_style.shadow_size = 0
	_mask_style.shadow_color = Color(0.0, 0.0, 0.0, 0.0)
	_apply_interaction_accent()


func _sync_shell_state_from_shader() -> void:
	if _shader_material == null:
		return
	_shell_corner_radius = clampf(float(_shader_material.get_shader_parameter("corner_radius")), 0.0, 1.0)
	_shell_edge_width = maxf(0.0, float(_shader_material.get_shader_parameter("edge_width")))
	_shell_tint = _shader_material.get_shader_parameter("tint")
	_shell_edge_highlight = _shader_material.get_shader_parameter("edge_highlight")


func _apply_interaction_accent() -> void:
	if _frame_style == null or _inner_border_style == null or _badge_style == null:
		return

	var accent_strength := 0.0
	if preview_button.button_pressed:
		accent_strength = 1.0
	elif _press_active:
		accent_strength = 0.78
	elif _drag_active:
		accent_strength = 0.64
	elif _hover_active:
		accent_strength = 0.4

	if accent_strength > 0.0:
		_frame_style.border_color = _frame_style.border_color.lerp(TOGGLE_ON_ACCENT, accent_strength * 0.65)
		_inner_border_style.border_color = _inner_border_style.border_color.lerp(TOGGLE_ON_ACCENT, accent_strength * 0.55)
		_badge_style.border_color = _badge_style.border_color.lerp(TOGGLE_ON_ACCENT, accent_strength * 0.55)
		_badge_style.bg_color = _badge_style.bg_color.lerp(Color(TOGGLE_ON_ACCENT.r, TOGGLE_ON_ACCENT.g, TOGGLE_ON_ACCENT.b, 0.22), accent_strength * 0.65)


func _refresh_interaction_debug() -> void:
	if not is_node_ready():
		return

	var source_variant := _last_input_source
	var phase_text := "idle"
	var surface_text := String(_interaction_surface_id)
	var verification_status := "waiting"
	var verification_notes := "No normalized contract event received yet."
	if _last_interaction_event != null:
		source_variant = str(_last_interaction_event.source_variant)
		phase_text = str(_last_interaction_event.phase)
		surface_text = str(_last_interaction_event.surface_id)
		verification_status = str(_last_interaction_event.verification_status)
		verification_notes = str(_last_interaction_event.verification_notes)

	var source_suffix := "mouse %d • touch %d" % [_mouse_event_count, _touch_event_count]
	if is_instance_valid(interaction_source_label):
		interaction_source_label.text = "Source: %s (%s)" % [source_variant, source_suffix]
	if is_instance_valid(interaction_pointer_label):
		interaction_pointer_label.text = "Phase: %s • %s" % [phase_text, _last_pointer_summary]
	if is_instance_valid(interaction_toggle_label):
		interaction_toggle_label.text = "Surface: %s • Toggle: %s • taps %d" % [surface_text, "ON" if preview_button.button_pressed else "OFF", _toggle_count]
	if is_instance_valid(interaction_count_label):
		interaction_count_label.text = "Verification: %s • %s" % [verification_status, verification_notes]
	if is_instance_valid(preview_badge_label):
		preview_badge_label.text = "Contract Tap Armed" if preview_button.button_pressed else _contract_host_mode_label
	if is_instance_valid(headline_label):
		headline_label.text = "AeroBeat INPUT CONTRACT" if preview_button.button_pressed else "AeroBeat"
	if is_instance_valid(body_label):
		body_label.text = _contract_host_summary
	if is_instance_valid(hint_label):
		hint_label.text = "Counts: press %d • release %d • drag %d • hover %s • pressed %s • surface %s (%s)" % [_press_count, _release_count, _drag_count, "YES" if _hover_active else "NO", "YES" if _press_active else "NO", surface_text, _contract_surface_type_label]
	_sync_preview_shell()


func _on_interactable_hovered_changed(is_hovered: bool, event: AeroUiInteractionEvent) -> void:
	_hover_active = is_hovered
	_last_interaction_event = event
	_refresh_interaction_debug()


func _on_interactable_pressed_changed(is_pressed: bool, event: AeroUiInteractionEvent) -> void:
	_press_active = is_pressed
	_last_interaction_event = event
	_refresh_interaction_debug()


func _on_interactable_dragging_changed(is_dragging: bool, event: AeroUiInteractionEvent) -> void:
	_drag_active = is_dragging
	_last_interaction_event = event
	_refresh_interaction_debug()


func _on_interactable_canceled(event: AeroUiInteractionEvent) -> void:
	_hover_active = false
	_press_active = false
	_drag_active = false
	_last_interaction_event = event
	_last_pointer_summary = "cancel @ %.0f, %.0f" % [event.surface_position.x, event.surface_position.y]
	_refresh_interaction_debug()


func _on_listener_interaction_event(event: AeroUiInteractionEvent) -> void:
	_last_interaction_event = event
	_last_input_source = str(event.source_variant)
	_last_pointer_summary = "%s @ %.0f, %.0f" % [event.phase, event.surface_position.x, event.surface_position.y]

	match event.source_type:
		AeroUiInteractionTypes.SOURCE_TYPE_MOUSE:
			_mouse_event_count += 1
		AeroUiInteractionTypes.SOURCE_TYPE_TOUCH:
			_touch_event_count += 1
		_:
			pass

	match event.phase:
		AeroUiInteractionTypes.PHASE_PRESS_BEGIN:
			_press_count += 1
		AeroUiInteractionTypes.PHASE_PRESS_END:
			_release_count += 1
		AeroUiInteractionTypes.PHASE_DRAG_BEGIN, AeroUiInteractionTypes.PHASE_DRAG_MOVE:
			_drag_count += 1
		_:
			pass

	_refresh_interaction_debug()


func _on_listener_tapped(event: AeroUiInteractionEvent) -> void:
	_toggle_count += 1
	preview_button.button_pressed = not preview_button.button_pressed
	_last_interaction_event = event
	_last_pointer_summary = "tapped @ %.0f, %.0f" % [event.surface_position.x, event.surface_position.y]
	_refresh_interaction_debug()


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
