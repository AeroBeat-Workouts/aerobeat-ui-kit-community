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

const TARGET_PRIMARY := "primary"
const TARGET_CHIP := "chip"
const TARGET_STRIP := "strip"
const TARGET_LABELS := {
	TARGET_PRIMARY: "PrimaryCardButton",
	TARGET_CHIP: "SecondaryToggleChip",
	TARGET_STRIP: "DragStrip",
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

const HYBRID_SHELL_DEFAULTS := {
	"hybrid_inner_border_brightness": 1.0,
	"hybrid_inner_border_alpha": 0.312,
	"hybrid_badge_fill_alpha": 0.18,
	"hybrid_badge_border_alpha": 0.267,
	"hybrid_badge_label_alpha": 0.9,
}

@onready var background: TextureRect = get_node_or_null("Background") as TextureRect
@onready var primary_card_button: Button = get_node_or_null("PreviewCenter/PreviewStack/PrimaryCardButton") as Button
@onready var hybrid_mask_panel: Panel = get_node_or_null("PreviewCenter/PreviewStack/PrimaryCardButton/HybridMaskPanel") as Panel
@onready var glass_fill: ColorRect = get_node_or_null("PreviewCenter/PreviewStack/PrimaryCardButton/GlassFill") as ColorRect
@onready var preview_frame: Panel = get_node_or_null("PreviewCenter/PreviewStack/PrimaryCardButton/PreviewFrame") as Panel
@onready var preview_inner_border: Panel = get_node_or_null("PreviewCenter/PreviewStack/PrimaryCardButton/InnerBorderInset/PreviewInnerBorder") as Panel
@onready var preview_badge: PanelContainer = get_node_or_null("PreviewCenter/PreviewStack/PrimaryCardButton/ContentMargin/ContentColumn/Badge") as PanelContainer
@onready var preview_badge_label: Label = get_node_or_null("PreviewCenter/PreviewStack/PrimaryCardButton/ContentMargin/ContentColumn/Badge/BadgePadding/BadgeLabel") as Label
@onready var headline_label: Label = get_node_or_null("PreviewCenter/PreviewStack/PrimaryCardButton/ContentMargin/ContentColumn/Headline") as Label
@onready var body_label: Label = get_node_or_null("PreviewCenter/PreviewStack/PrimaryCardButton/ContentMargin/ContentColumn/Body") as Label
@onready var hint_label: Label = get_node_or_null("PreviewCenter/PreviewStack/PrimaryCardButton/ContentMargin/ContentColumn/HintLabel") as Label
@onready var interaction_source_label: Label = get_node_or_null("PreviewCenter/PreviewStack/PrimaryCardButton/ContentMargin/ContentColumn/InteractionStatePanel/InteractionStatePadding/InteractionStateColumn/InteractionSourceLabel") as Label
@onready var interaction_pointer_label: Label = get_node_or_null("PreviewCenter/PreviewStack/PrimaryCardButton/ContentMargin/ContentColumn/InteractionStatePanel/InteractionStatePadding/InteractionStateColumn/InteractionPointerLabel") as Label
@onready var interaction_toggle_label: Label = get_node_or_null("PreviewCenter/PreviewStack/PrimaryCardButton/ContentMargin/ContentColumn/InteractionStatePanel/InteractionStatePadding/InteractionStateColumn/InteractionToggleLabel") as Label
@onready var interaction_count_label: Label = get_node_or_null("PreviewCenter/PreviewStack/PrimaryCardButton/ContentMargin/ContentColumn/InteractionStatePanel/InteractionStatePadding/InteractionStateColumn/InteractionCountLabel") as Label
@onready var content_margin: MarginContainer = get_node_or_null("PreviewCenter/PreviewStack/PrimaryCardButton/ContentMargin") as MarginContainer
@onready var preview_backdrop_debug: Control = get_node_or_null("PreviewCenter/PreviewStack/PreviewBackdropDebug") as Control

@onready var secondary_toggle_chip: Button = get_node_or_null("PreviewCenter/PreviewStack/SecondaryToggleChip") as Button
@onready var chip_label: Label = get_node_or_null("PreviewCenter/PreviewStack/SecondaryToggleChip/ChipColumn/ChipLabel") as Label
@onready var chip_state_label: Label = get_node_or_null("PreviewCenter/PreviewStack/SecondaryToggleChip/ChipColumn/ChipStateLabel") as Label
@onready var drag_strip: PanelContainer = get_node_or_null("PreviewCenter/PreviewStack/DragStrip") as PanelContainer
@onready var drag_strip_fill: ColorRect = get_node_or_null("PreviewCenter/PreviewStack/DragStrip/StripPadding/StripColumn/StripTrack/StripFill") as ColorRect
@onready var drag_strip_handle: Panel = get_node_or_null("PreviewCenter/PreviewStack/DragStrip/StripPadding/StripColumn/StripTrack/StripHandle") as Panel
@onready var drag_strip_state_label: Label = get_node_or_null("PreviewCenter/PreviewStack/DragStrip/StripPadding/StripColumn/StripStateLabel") as Label
@onready var hybrid_summary_panel: PanelContainer = get_node_or_null("PreviewCenter/PreviewStack/HybridSummaryPanel") as PanelContainer
@onready var summary_hover_label: Label = get_node_or_null("PreviewCenter/PreviewStack/HybridSummaryPanel/SummaryPadding/SummaryColumn/HoverTargetLabel") as Label
@onready var summary_owner_label: Label = get_node_or_null("PreviewCenter/PreviewStack/HybridSummaryPanel/SummaryPadding/SummaryColumn/OwnerTargetLabel") as Label
@onready var summary_release_label: Label = get_node_or_null("PreviewCenter/PreviewStack/HybridSummaryPanel/SummaryPadding/SummaryColumn/ReleaseTargetLabel") as Label
@onready var summary_phase_label: Label = get_node_or_null("PreviewCenter/PreviewStack/HybridSummaryPanel/SummaryPadding/SummaryColumn/PhaseSummaryLabel") as Label
@onready var summary_counts_label: Label = get_node_or_null("PreviewCenter/PreviewStack/HybridSummaryPanel/SummaryPadding/SummaryColumn/CountsSummaryLabel") as Label

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
var _last_interaction_event: AeroUiInteractionEvent = null
var _interaction_bus_path_override: NodePath = NodePath()
var _interaction_surface_id: StringName = DEFAULT_INTERACTION_SURFACE_ID
var _contract_surface_type_label := "hybrid_3d_gui"
var _contract_host_summary := "Hybrid world hits now feed AeroUiInteractionBus through HybridSubViewportInputAdapter. Multiple sibling controls stay bus-driven without raw gui_input parsing."
var _contract_host_mode_label := "Hybrid multi-target contract proof"
var _target_states: Dictionary = {}
var _path_to_target_key: Dictionary = {}
var _summary_hover_target_path := ""
var _summary_owner_target_path := ""
var _summary_last_release_target_path := ""
var _summary_last_phase := "idle"
var _summary_source_variant := "waiting"
var _summary_verification_status := "waiting"


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

	_configure_primary_card_button()
	_configure_secondary_chip()
	_configure_drag_strip()
	_setup_contract_consumers()
	call_deferred("_bind_contract_consumers_to_runtime_bus")
	_sync_shell_state_from_shader()
	_apply_visual_state()
	primary_card_button.resized.connect(_sync_preview_shell)
	preview_inner_border.resized.connect(_sync_preview_shell)
	secondary_toggle_chip.resized.connect(_refresh_secondary_chip_visual)
	drag_strip.resized.connect(_refresh_drag_strip_visual)
	call_deferred("_sync_preview_shell")
	call_deferred("_refresh_target_views")
	call_deferred("_refresh_interaction_debug")


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED and is_instance_valid(primary_card_button):
		_configure_primary_card_button()
		_configure_secondary_chip()
		_configure_drag_strip()


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
	primary_card_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
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


func _configure_secondary_chip() -> void:
	secondary_toggle_chip.flat = true
	secondary_toggle_chip.toggle_mode = true
	secondary_toggle_chip.button_pressed = false
	secondary_toggle_chip.focus_mode = Control.FOCUS_NONE
	secondary_toggle_chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	secondary_toggle_chip.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	secondary_toggle_chip.add_theme_constant_override("outline_size", 0)
	var empty := StyleBoxEmpty.new()
	secondary_toggle_chip.add_theme_stylebox_override("normal", empty)
	secondary_toggle_chip.add_theme_stylebox_override("hover", empty)
	secondary_toggle_chip.add_theme_stylebox_override("pressed", empty)
	secondary_toggle_chip.add_theme_stylebox_override("focus", empty)
	secondary_toggle_chip.add_theme_stylebox_override("disabled", empty)


func _configure_drag_strip() -> void:
	drag_strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	drag_strip.mouse_default_cursor_shape = Control.CURSOR_HSIZE


func _setup_contract_consumers() -> void:
	_target_states.clear()
	_path_to_target_key.clear()
	_register_target_contract(TARGET_PRIMARY, primary_card_button)
	_register_target_contract(TARGET_CHIP, secondary_toggle_chip)
	_register_target_contract(TARGET_STRIP, drag_strip)
	_bind_contract_consumers_to_runtime_bus()


func _register_target_contract(target_key: String, control: Control) -> void:
	if not is_instance_valid(control):
		return

	var interactable := AeroUiInteractable.new()
	interactable.name = "%sInteractable" % TARGET_LABELS[target_key]
	add_child(interactable)
	var listener := AeroUiInteractionListener.new()
	listener.name = "%sListener" % TARGET_LABELS[target_key]
	add_child(listener)
	var target_path := control.get_path()

	for consumer in [interactable, listener]:
		consumer.bus_path = DEFAULT_INTERACTION_BUS_PATH
		consumer.surface_id_filter = _interaction_surface_id
		consumer.target_path_filter = target_path

	_target_states[target_key] = {
		"control": control,
		"interactable": interactable,
		"listener": listener,
		"target_path": target_path,
		"hovered": false,
		"pressed": false,
		"dragging": false,
		"press_count": 0,
		"release_count": 0,
		"drag_count": 0,
		"tap_count": 0,
		"toggle_on": false,
		"last_event": null,
		"last_source_variant": "waiting",
	}
	_path_to_target_key[str(target_path)] = target_key

	if not interactable.hovered_changed.is_connected(_on_target_hovered_changed):
		interactable.hovered_changed.connect(_on_target_hovered_changed.bind(target_key))
	if not interactable.pressed_changed.is_connected(_on_target_pressed_changed):
		interactable.pressed_changed.connect(_on_target_pressed_changed.bind(target_key))
	if not interactable.dragging_changed.is_connected(_on_target_dragging_changed):
		interactable.dragging_changed.connect(_on_target_dragging_changed.bind(target_key))
	if not interactable.canceled.is_connected(_on_target_canceled):
		interactable.canceled.connect(_on_target_canceled.bind(target_key))
	if not listener.interaction_event.is_connected(_on_target_listener_interaction_event):
		listener.interaction_event.connect(_on_target_listener_interaction_event.bind(target_key))
	if not listener.tapped.is_connected(_on_target_listener_tapped):
		listener.tapped.connect(_on_target_listener_tapped.bind(target_key))


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

	for state in _target_states.values():
		for consumer in [state.get("interactable"), state.get("listener")]:
			if is_instance_valid(consumer):
				consumer.surface_id_filter = _interaction_surface_id

	if is_node_ready():
		_refresh_interaction_debug()


func _bind_contract_consumers_to_runtime_bus() -> void:
	var bus := _resolve_interaction_bus()
	if bus == null:
		return

	for state in _target_states.values():
		for consumer in [state.get("interactable"), state.get("listener")]:
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
	if primary_card_button == null or size.x <= 0.0 or size.y <= 0.0:
		return Rect2(0.0, 0.0, 1.0, 1.0)

	var rect := primary_card_button.get_global_rect()
	return Rect2(rect.position / size, rect.size / size)


func get_interaction_target_specs() -> Array:
	var specs: Array = []
	for target_key in [TARGET_PRIMARY, TARGET_CHIP, TARGET_STRIP]:
		var state: Dictionary = _target_states.get(target_key, {})
		var control := state.get("control") as Control
		if not is_instance_valid(control):
			continue
		specs.append({
			"target_key": target_key,
			"target_name": TARGET_LABELS[target_key],
			"target_path": state.get("target_path", NodePath()),
			"rect": control.get_global_rect(),
		})
	return specs


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
	secondary_toggle_chip.visible = not is_mask_mode
	drag_strip.visible = not is_mask_mode
	if is_instance_valid(hybrid_summary_panel):
		hybrid_summary_panel.visible = not is_mask_mode
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
	_frame_style.border_color.a = clampf(_shell_edge_highlight.a + FRAME_ALPHA_BOOST, 0.28, 0.92)

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
	_apply_primary_card_accent()
	_refresh_secondary_chip_visual()
	_refresh_drag_strip_visual()


func _sync_shell_state_from_shader() -> void:
	if _shader_material == null:
		return
	_shell_corner_radius = clampf(float(_shader_material.get_shader_parameter("corner_radius")), 0.0, 1.0)
	_shell_edge_width = maxf(0.0, float(_shader_material.get_shader_parameter("edge_width")))
	_shell_tint = _shader_material.get_shader_parameter("tint")
	_shell_edge_highlight = _shader_material.get_shader_parameter("edge_highlight")


func _apply_primary_card_accent() -> void:
	if _frame_style == null or _inner_border_style == null or _badge_style == null:
		return

	var state: Dictionary = _target_states.get(TARGET_PRIMARY, {})
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
		_badge_style.border_color = _badge_style.border_color.lerp(TOGGLE_ON_ACCENT, accent_strength * 0.55)
		_badge_style.bg_color = _badge_style.bg_color.lerp(Color(TOGGLE_ON_ACCENT.r, TOGGLE_ON_ACCENT.g, TOGGLE_ON_ACCENT.b, 0.22), accent_strength * 0.65)


func _refresh_secondary_chip_visual() -> void:
	if not is_instance_valid(secondary_toggle_chip):
		return
	var state: Dictionary = _target_states.get(TARGET_CHIP, {})
	var hovered := bool(state.get("hovered", false))
	var pressed := bool(state.get("pressed", false))
	var toggled := bool(state.get("toggle_on", false))
	var accent := Color(0.46, 0.86, 1.0, 1.0) if toggled else Color(1.0, 1.0, 1.0, 1.0)
	secondary_toggle_chip.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
	secondary_toggle_chip.modulate = Color(1.0, 1.0, 1.0, 0.98)
	secondary_toggle_chip.add_theme_color_override("font_color", accent if toggled or hovered else Color(1.0, 1.0, 1.0, 0.92))
	secondary_toggle_chip.add_theme_color_override("font_hover_color", accent)
	secondary_toggle_chip.add_theme_color_override("font_pressed_color", accent.lightened(0.08))
	secondary_toggle_chip.scale = Vector2.ONE * (0.985 if pressed else 1.0)
	if is_instance_valid(chip_label):
		chip_label.text = "SECONDARY CHIP %s" % ("ON" if toggled else "OFF")
		chip_label.modulate = accent if toggled or hovered else Color(1.0, 1.0, 1.0, 0.9)
	if is_instance_valid(chip_state_label):
		chip_state_label.text = "hover %s • press %d • taps %d" % ["YES" if hovered else "NO", int(state.get("press_count", 0)), int(state.get("tap_count", 0))]
		chip_state_label.modulate = Color(1.0, 1.0, 1.0, 0.68 if not pressed else 0.9)


func _refresh_drag_strip_visual() -> void:
	if not is_instance_valid(drag_strip_fill) or not is_instance_valid(drag_strip_handle) or not is_instance_valid(drag_strip):
		return
	var state: Dictionary = _target_states.get(TARGET_STRIP, {})
	var progress := clampf(float(state.get("progress", 0.12)), 0.0, 1.0)
	var track_rect: Rect2 = (drag_strip_fill.get_parent() as Control).get_rect()
	drag_strip_fill.size.x = track_rect.size.x * progress
	drag_strip_handle.position.x = clampf(track_rect.size.x * progress - drag_strip_handle.size.x * 0.5, 0.0, track_rect.size.x - drag_strip_handle.size.x)
	var dragging := bool(state.get("dragging", false))
	var hovered := bool(state.get("hovered", false))
	var accent := Color(0.44, 0.84, 1.0, 0.95) if dragging else Color(1.0, 1.0, 1.0, 0.78 if hovered else 0.52)
	drag_strip_fill.color = accent
	drag_strip_handle.modulate = Color(1.0, 1.0, 1.0, 0.96 if dragging or hovered else 0.7)
	if is_instance_valid(drag_strip_state_label):
		drag_strip_state_label.text = "owner test: %.0f%% • drags %d • releases %d" % [progress * 100.0, int(state.get("drag_count", 0)), int(state.get("release_count", 0))]


func _refresh_target_views() -> void:
	_refresh_secondary_chip_visual()
	_refresh_drag_strip_visual()
	_refresh_interaction_debug()


func _refresh_interaction_debug() -> void:
	if not is_node_ready():
		return

	var primary_state: Dictionary = _target_states.get(TARGET_PRIMARY, {})
	var primary_event: AeroUiInteractionEvent = primary_state.get("last_event") as AeroUiInteractionEvent
	var phase_text := "idle"
	var surface_text := String(_interaction_surface_id)
	var verification_status := _summary_verification_status
	var verification_notes := "No normalized contract event received yet."
	var source_variant := _summary_source_variant
	if primary_event != null:
		phase_text = str(primary_event.phase)
		surface_text = str(primary_event.surface_id)
		verification_status = str(primary_event.verification_status)
		verification_notes = str(primary_event.verification_notes)
		source_variant = str(primary_event.source_variant)
	elif _last_interaction_event != null:
		phase_text = str(_last_interaction_event.phase)
		surface_text = str(_last_interaction_event.surface_id)
		verification_status = str(_last_interaction_event.verification_status)
		verification_notes = str(_last_interaction_event.verification_notes)
		source_variant = str(_last_interaction_event.source_variant)

	if is_instance_valid(interaction_source_label):
		interaction_source_label.text = "Primary source: %s • hover %s" % [source_variant, "YES" if bool(primary_state.get("hovered", false)) else "NO"]
	if is_instance_valid(interaction_pointer_label):
		interaction_pointer_label.text = "Primary phase: %s • owner %s" % [phase_text, _display_target_name(_summary_owner_target_path)]
	if is_instance_valid(interaction_toggle_label):
		interaction_toggle_label.text = "Primary toggle: %s • taps %d • releases %d" % ["ON" if bool(primary_state.get("toggle_on", false)) else "OFF", int(primary_state.get("tap_count", 0)), int(primary_state.get("release_count", 0))]
	if is_instance_valid(interaction_count_label):
		interaction_count_label.text = "Verification: %s • %s" % [verification_status, verification_notes]
	if is_instance_valid(preview_badge_label):
		preview_badge_label.text = "Primary armed" if bool(primary_state.get("toggle_on", false)) else _contract_host_mode_label
	if is_instance_valid(headline_label):
		headline_label.text = "AeroBeat INPUT CONTRACT" if bool(primary_state.get("toggle_on", false)) else "AeroBeat"
	if is_instance_valid(body_label):
		body_label.text = _contract_host_summary
	if is_instance_valid(hint_label):
		hint_label.text = "Hover can move between siblings. Press ownership stays locked to its origin target until release. Touch remains unverified; hybrid mouse remains prototype."

	if is_instance_valid(summary_hover_label):
		summary_hover_label.text = "Hover target: %s" % _display_target_name(_summary_hover_target_path)
	if is_instance_valid(summary_owner_label):
		summary_owner_label.text = "Active owner: %s" % _display_target_name(_summary_owner_target_path)
	if is_instance_valid(summary_release_label):
		summary_release_label.text = "Last release: %s" % _display_target_name(_summary_last_release_target_path)
	if is_instance_valid(summary_phase_label):
		summary_phase_label.text = "Last phase: %s • %s • %s" % [_summary_last_phase, _summary_source_variant, _summary_verification_status]
	if is_instance_valid(summary_counts_label):
		summary_counts_label.text = "Primary taps %d • Chip taps %d • Strip drags %d" % [
			int(_target_states.get(TARGET_PRIMARY, {}).get("tap_count", 0)),
			int(_target_states.get(TARGET_CHIP, {}).get("tap_count", 0)),
			int(_target_states.get(TARGET_STRIP, {}).get("drag_count", 0)),
		]

	_sync_preview_shell()


func _on_target_hovered_changed(is_hovered: bool, event: AeroUiInteractionEvent, target_key: String) -> void:
	var state: Dictionary = _target_states.get(target_key, {})
	state["hovered"] = is_hovered
	state["last_event"] = event
	_target_states[target_key] = state
	_refresh_target_visual(target_key)


func _on_target_pressed_changed(is_pressed: bool, event: AeroUiInteractionEvent, target_key: String) -> void:
	var state: Dictionary = _target_states.get(target_key, {})
	state["pressed"] = is_pressed
	state["last_event"] = event
	_target_states[target_key] = state
	_refresh_target_visual(target_key)


func _on_target_dragging_changed(is_dragging: bool, event: AeroUiInteractionEvent, target_key: String) -> void:
	var state: Dictionary = _target_states.get(target_key, {})
	state["dragging"] = is_dragging
	state["last_event"] = event
	_target_states[target_key] = state
	if target_key == TARGET_STRIP:
		_update_drag_strip_progress_from_event(event)
	_refresh_target_visual(target_key)


func _on_target_canceled(event: AeroUiInteractionEvent, target_key: String) -> void:
	var state: Dictionary = _target_states.get(target_key, {})
	state["hovered"] = false
	state["pressed"] = false
	state["dragging"] = false
	state["last_event"] = event
	_target_states[target_key] = state
	_summary_owner_target_path = ""
	_summary_last_phase = str(event.phase)
	_summary_source_variant = str(event.source_variant)
	_summary_verification_status = str(event.verification_status)
	_refresh_target_visual(target_key)


func _on_target_listener_interaction_event(event: AeroUiInteractionEvent, target_key: String) -> void:
	var state: Dictionary = _target_states.get(target_key, {})
	state["last_event"] = event
	state["last_source_variant"] = str(event.source_variant)
	match event.phase:
		AeroUiInteractionTypes.PHASE_PRESS_BEGIN:
			state["press_count"] = int(state.get("press_count", 0)) + 1
			_summary_owner_target_path = str(event.target_path)
		AeroUiInteractionTypes.PHASE_PRESS_END:
			state["release_count"] = int(state.get("release_count", 0)) + 1
			_summary_last_release_target_path = str(event.target_path)
			_summary_owner_target_path = ""
		AeroUiInteractionTypes.PHASE_DRAG_BEGIN, AeroUiInteractionTypes.PHASE_DRAG_MOVE:
			state["drag_count"] = int(state.get("drag_count", 0)) + 1
			if target_key == TARGET_STRIP:
				_update_drag_strip_progress_from_event(event)
		AeroUiInteractionTypes.PHASE_HOVER_ENTER:
			_summary_hover_target_path = str(event.target_path)
		AeroUiInteractionTypes.PHASE_HOVER_EXIT:
			if _summary_hover_target_path == str(event.target_path):
				_summary_hover_target_path = ""
		_:
			pass
	_target_states[target_key] = state
	_last_interaction_event = event
	_summary_last_phase = str(event.phase)
	_summary_source_variant = str(event.source_variant)
	_summary_verification_status = str(event.verification_status)
	_refresh_target_visual(target_key)


func _on_target_listener_tapped(event: AeroUiInteractionEvent, target_key: String) -> void:
	var state: Dictionary = _target_states.get(target_key, {})
	state["tap_count"] = int(state.get("tap_count", 0)) + 1
	state["last_event"] = event
	if target_key == TARGET_PRIMARY:
		state["toggle_on"] = not bool(state.get("toggle_on", false))
		primary_card_button.button_pressed = bool(state["toggle_on"])
	elif target_key == TARGET_CHIP:
		state["toggle_on"] = not bool(state.get("toggle_on", false))
		secondary_toggle_chip.button_pressed = bool(state["toggle_on"])
	_target_states[target_key] = state
	_last_interaction_event = event
	_summary_last_phase = "tapped"
	_refresh_target_visual(target_key)


func _update_drag_strip_progress_from_event(event: AeroUiInteractionEvent) -> void:
	var state: Dictionary = _target_states.get(TARGET_STRIP, {})
	var rect := drag_strip.get_global_rect()
	if rect.size.x <= 0.0:
		return
	var progress := clampf((event.surface_position.x - rect.position.x) / rect.size.x, 0.0, 1.0)
	state["progress"] = progress
	_target_states[TARGET_STRIP] = state


func _refresh_target_visual(target_key: String) -> void:
	match target_key:
		TARGET_PRIMARY:
			_refresh_interaction_debug()
		TARGET_CHIP:
			_refresh_secondary_chip_visual()
			_refresh_interaction_debug()
		TARGET_STRIP:
			_refresh_drag_strip_visual()
			_refresh_interaction_debug()
		_:
			_refresh_interaction_debug()


func _display_target_name(target_path_text: String) -> String:
	if target_path_text == "":
		return "none"
	var target_key: String = str(_path_to_target_key.get(target_path_text, ""))
	if target_key != "":
		return str(TARGET_LABELS[target_key])
	return target_path_text.get_file()


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
