extends Node3D

# Phase 2 proof-host cutover note:
# - This proof host now keeps only scene-specific world-ray acquisition, authored panel
#   composition, and touch/local proof glue for the hybrid 3D reference surface.
# - Reusable projected-surface helpers now come from aerobeat-spatial-ui-core.
# - Reusable mouse hover/capture/publication lifecycle now comes from
#   aerobeat-spatial-ui-mouse.
# - Reusable touch lifecycle/runtime continuity now comes from
#   aerobeat-spatial-ui-touch.
# - The canonical interaction contract still belongs to aerobeat-input-core.
const PANEL_VIEW_SCENE_PATH := "res://ui/views/aero_ui_glass_panel_view.tscn"
const HYBRID_SHADER_PATH := "res://assets/shaders/glass-panel-hybrid-3d.gdshader"
const UI_OVERLAY_SHADER_PATH := "res://assets/shaders/glass-panel-ui-overlay-3d.gdshader"
const PANEL_PRESET_DIALOG_DIRECTORY := "res://ui/presets/glass/panel"
const BADGE_PRESET_DIALOG_DIRECTORY := "res://ui/presets/glass/badge"
const BUTTON_PRESET_DIALOG_DIRECTORY := "res://ui/presets/glass/button/primary"
const HYBRID_SURFACE_ID: StringName = &"hybrid_glass_panel"
const HYBRID_SURFACE_TYPE: StringName = AeroUiInteractionTypes.SURFACE_TYPE_HYBRID_3D_GUI
const HYBRID_POINTER_MOUSE: StringName = &"mouse_0"
const PanelViewScript = preload("res://ui/views/aero_ui_glass_panel_view.gd")
const YamlBundleIO = preload("res://scripts/aero_ui_glass_yaml_bundle_io.gd")
const BadgeConfigLoader = preload("res://ui/configs/loaders/aero_ui_glass_badge_config_loader.gd")
const ButtonConfigLoader = preload("res://ui/configs/loaders/aero_ui_glass_primary_button_config_loader.gd")
const SpatialSurfaceDescriptorScript = preload("res://addons/aerobeat-spatial-ui-core/src/helpers/surfaces/aero_spatial_surface_descriptor.gd")
const SpatialProjectionHelperScript = preload("res://addons/aerobeat-spatial-ui-core/src/helpers/providers/aero_spatial_projection_helper.gd")
const SPATIAL_UI_MOUSE_PROVIDER_SCRIPT_PATH := "res://addons/aerobeat-spatial-ui-mouse/src/providers/mouse/aero_spatial_ui_mouse_provider.gd"
const SpatialUiMouseProviderScript = preload("res://addons/aerobeat-spatial-ui-mouse/src/providers/mouse/aero_spatial_ui_mouse_provider.gd")
const SpatialUiMouseProviderConfigScript = preload("res://addons/aerobeat-spatial-ui-mouse/src/providers/mouse/aero_spatial_ui_mouse_provider_config.gd")
const SpatialUiTouchProviderScript = preload("res://addons/aerobeat-spatial-ui-touch/src/providers/touch/aero_spatial_ui_touch_provider.gd")
const SpatialUiTouchProviderConfigScript = preload("res://addons/aerobeat-spatial-ui-touch/src/providers/touch/aero_spatial_ui_touch_provider_config.gd")

const AUTO_YAW_AMPLITUDE_DEG := 26.0
const AUTO_PITCH_AMPLITUDE_DEG := 10.0
const MAX_MANUAL_PITCH_DEG := 35.0
const MAX_MANUAL_YAW_DEG := 45.0

const HYBRID_FLOAT_CONTROLS := [
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
		"default": 1.3,
	},
	{
		"name": "tint_strength",
		"label": "tint_strength",
		"min": 0.0,
		"max": 1.0,
		"step": 0.01,
		"default": 0.66,
	},
	{
		"name": "body_frost_strength",
		"label": "body_frost_strength",
		"min": 0.0,
		"max": 1.0,
		"step": 0.01,
		"default": 0.85,
	},
	{
		"name": "background_subdue",
		"label": "background_subdue",
		"min": 0.0,
		"max": 1.0,
		"step": 0.01,
		"default": 0.86,
	},
	{
		"name": "interior_chroma",
		"label": "interior_chroma",
		"min": 0.0,
		"max": 1.0,
		"step": 0.01,
		"default": 0.24,
	},
	{
		"name": "world_rim_refraction",
		"label": "world_rim_refraction",
		"min": 0.0,
		"max": 1.0,
		"step": 0.01,
		"default": 0.09,
	},
	{
		"name": "fresnel_power",
		"label": "fresnel_power",
		"min": 0.5,
		"max": 8.0,
		"step": 0.1,
		"default": 5.0,
	},
	{
		"name": "fresnel_strength",
		"label": "fresnel_strength",
		"min": 0.0,
		"max": 2.0,
		"step": 0.01,
		"default": 0.04,
	},
	{
		"name": "face_highlight",
		"label": "face_highlight",
		"min": 0.0,
		"max": 0.4,
		"step": 0.01,
		"default": 0.015,
	},
	{
		"name": "face_veil_strength",
		"label": "face_veil_strength",
		"min": 0.0,
		"max": 1.0,
		"step": 0.01,
		"default": 0.18,
	},
	{
		"name": "perimeter_frost_boost",
		"label": "perimeter_frost_boost",
		"min": 0.0,
		"max": 0.5,
		"step": 0.01,
		"default": 0.08,
	},
	{
		"name": "ui_alpha_gain",
		"label": "ui_alpha_gain",
		"min": 0.0,
		"max": 2.0,
		"step": 0.01,
		"default": 1.0,
	},
	{
		"name": "ui_brightness",
		"label": "ui_brightness",
		"min": 0.2,
		"max": 2.0,
		"step": 0.01,
		"default": 1.01,
	},
	{
		"name": "ui_embed_strength",
		"label": "ui_embed_strength",
		"min": 0.0,
		"max": 0.3,
		"step": 0.01,
		"default": 0.01,
	},
	{
		"name": "ui_overlay_alpha",
		"label": "ui_overlay_alpha",
		"min": 0.0,
		"max": 2.0,
		"step": 0.01,
		"default": 1.08,
	},
	{
		"name": "ui_overlay_brightness",
		"label": "ui_overlay_brightness",
		"min": 0.2,
		"max": 2.0,
		"step": 0.01,
		"default": 1.06,
	},
	{
		"name": "ui_overlay_shadow_strength",
		"label": "ui_overlay_shadow_strength",
		"min": 0.0,
		"max": 0.25,
		"step": 0.01,
		"default": 0.015,
	},
	{
		"name": "ui_overlay_tint_mix",
		"label": "ui_overlay_tint_mix",
		"min": 0.0,
		"max": 0.3,
		"step": 0.01,
		"default": 0.02,
	},
	{
		"name": "hybrid_inner_border_brightness",
		"label": "hybrid_inner_border_brightness",
		"min": 0.0,
		"max": 2.0,
		"step": 0.01,
		"default": 1.0,
	},
	{
		"name": "hybrid_inner_border_alpha",
		"label": "hybrid_inner_border_alpha",
		"min": 0.0,
		"max": 1.0,
		"step": 0.01,
		"default": 0.312,
	},
	{
		"name": "hybrid_badge_fill_alpha",
		"label": "hybrid_badge_fill_alpha",
		"min": 0.0,
		"max": 1.0,
		"step": 0.01,
		"default": 0.18,
	},
	{
		"name": "hybrid_badge_border_alpha",
		"label": "hybrid_badge_border_alpha",
		"min": 0.0,
		"max": 1.0,
		"step": 0.01,
		"default": 0.267,
	},
	{
		"name": "hybrid_badge_label_alpha",
		"label": "hybrid_badge_label_alpha",
		"min": 0.0,
		"max": 1.0,
		"step": 0.01,
		"default": 0.9,
	},
]

const HYBRID_COLOR_CONTROLS := [
	{
		"name": "tint",
		"label": "tint",
		"default": Color(0.94, 0.968, 1.0, 0.44),
	},
	{
		"name": "edge_color",
		"label": "edge_color",
		"default": Color(1.0, 1.0, 1.0, 0.08),
	},
	{
		"name": "ui_overlay_tint",
		"label": "ui_overlay_tint",
		"default": Color(0.97, 0.985, 1.0, 1.0),
	},
]

const HYBRID_CONTROL_SECTIONS := [
	{
		"label": "Scene controls",
		"spacing_after": 18.0,
		"builders": ["_make_background_mode_control", "_make_preset_actions_block"],
	},
	{
		"label": "Glass body",
		"spacing_after": 18.0,
		"float_names": [
			"blur",
			"warp_intensity",
			"strength_x",
			"strength_y",
			"offset_x",
			"offset_y",
			"corner_radius",
			"edge_smoothness",
			"edge_width",
			"chromatic_strength",
			"tint_strength",
			"body_frost_strength",
			"background_subdue",
			"interior_chroma",
		],
	},
	{
		"label": "World lighting",
		"spacing_after": 18.0,
		"float_names": [
			"world_rim_refraction",
			"fresnel_power",
			"fresnel_strength",
			"face_highlight",
			"face_veil_strength",
			"perimeter_frost_boost",
		],
	},
	{
		"label": "UI embed + overlay",
		"spacing_after": 18.0,
		"float_names": [
			"ui_alpha_gain",
			"ui_brightness",
			"ui_embed_strength",
			"ui_overlay_alpha",
			"ui_overlay_brightness",
			"ui_overlay_shadow_strength",
			"ui_overlay_tint_mix",
		],
	},
	{
		"label": "Hybrid shell",
		"spacing_after": 18.0,
		"float_names": [
			"hybrid_inner_border_brightness",
			"hybrid_inner_border_alpha",
			"hybrid_badge_fill_alpha",
			"hybrid_badge_border_alpha",
			"hybrid_badge_label_alpha",
		],
	},
	{
		"label": "Color tuning",
		"spacing_after": 8.0,
		"color_names": ["tint", "edge_color", "ui_overlay_tint"],
	},
]

const PARAMETER_ALIASES := {
	"edge_highlight": {"target": "edge_color"},
	"edge_smoothness": {"target": "edge_softness", "scale": 0.01},
	"edge_width": {"target": "edge_width", "scale": 0.0075},
}

const PRESET_SECTION_PANEL := "panel"
const PRESET_SECTION_BADGE := "badge"
const PRESET_SECTION_BUTTON := "button"

const PANEL_PRESENTATION_FLOAT_PARAMETER_NAMES := [
	"hybrid_inner_border_brightness",
	"hybrid_inner_border_alpha",
]

const BADGE_FLOAT_PARAMETER_NAMES := [
	"hybrid_badge_fill_alpha",
	"hybrid_badge_border_alpha",
	"hybrid_badge_label_alpha",
]

const HYBRID_ONLY_FLOAT_PARAMETER_NAMES := [
	"tint_strength",
	"body_frost_strength",
	"background_subdue",
	"interior_chroma",
	"world_rim_refraction",
	"fresnel_power",
	"fresnel_strength",
	"face_highlight",
	"face_veil_strength",
	"perimeter_frost_boost",
	"ui_alpha_gain",
	"ui_brightness",
	"ui_embed_strength",
	"ui_overlay_alpha",
	"ui_overlay_brightness",
	"ui_overlay_shadow_strength",
	"ui_overlay_tint_mix",
]

const HYBRID_ONLY_COLOR_PARAMETER_NAMES := [
	"ui_overlay_tint",
]

const BADGE_EDITOR_BASE_CONTROLS := [
	{"name": "badge_base_fill_alpha", "label": "source_fill_alpha", "min": 0.0, "max": 1.0, "step": 0.01, "default": 0.08},
	{"name": "badge_base_border_alpha", "label": "source_border_alpha", "min": 0.0, "max": 1.0, "step": 0.01, "default": 0.14},
	{"name": "badge_base_label_alpha", "label": "source_label_alpha", "min": 0.0, "max": 1.0, "step": 0.01, "default": 0.78},
]

const BADGE_EDITOR_HYBRID_CONTROLS := [
	{"name": "badge_hybrid_fill_alpha", "label": "hybrid_fill_alpha", "min": 0.0, "max": 1.0, "step": 0.01, "default": 0.18},
	{"name": "badge_hybrid_border_alpha", "label": "hybrid_border_alpha", "min": 0.0, "max": 1.0, "step": 0.01, "default": 0.267},
	{"name": "badge_hybrid_label_alpha", "label": "hybrid_label_alpha", "min": 0.0, "max": 1.0, "step": 0.01, "default": 0.9},
]

const BADGE_EDITOR_COLOR_CONTROLS := [
	{"name": "badge_tint", "label": "tint", "default": Color(0.92, 0.96, 1.0, 1.0)},
]

const BUTTON_EDITOR_BASE_CONTROLS := [
	{"name": "button_border_width", "label": "border_width", "min": 0.0, "max": 8.0, "step": 1.0, "default": 2.0},
	{"name": "button_radius_delta", "label": "radius_delta", "min": 0.0, "max": 16.0, "step": 1.0, "default": 5.0},
]

const BUTTON_EDITOR_COLOR_CONTROLS := [
	{"name": "button_background_tint", "label": "background_tint", "default": Color(0.92, 0.96, 1.0, 1.0)},
	{"name": "button_interaction_tint", "label": "interaction_tint", "default": Color(0.4, 0.82, 1.0, 1.0)},
]

const BUTTON_EDITOR_HYBRID_CONTROLS := [
	{"name": "button_hybrid_label_alpha", "label": "label_alpha", "min": 0.0, "max": 1.0, "step": 0.01, "default": 0.98},
	{"name": "button_hybrid_meta_alpha", "label": "meta_alpha", "min": 0.0, "max": 1.0, "step": 0.01, "default": 0.7},
	{"name": "button_hybrid_hover_tint_strength", "label": "hover_tint_strength", "min": 0.0, "max": 1.0, "step": 0.01, "default": 0.34},
	{"name": "button_hybrid_hover_scale", "label": "hover_scale", "min": 0.9, "max": 1.1, "step": 0.001, "default": 1.012},
	{"name": "button_hybrid_hover_speed", "label": "hover_speed", "min": 0.0, "max": 0.4, "step": 0.01, "default": 0.12},
	{"name": "button_hybrid_pressed_tint_strength", "label": "pressed_tint_strength", "min": 0.0, "max": 1.0, "step": 0.01, "default": 0.72},
	{"name": "button_hybrid_pressed_scale", "label": "pressed_scale", "min": 0.9, "max": 1.1, "step": 0.001, "default": 0.988},
	{"name": "button_hybrid_pressed_speed", "label": "pressed_speed", "min": 0.0, "max": 0.4, "step": 0.01, "default": 0.08},
]

const BUTTON_EDITOR_OPTION_CONTROLS := [
	{"name": "button_hybrid_hover_ease_type", "label": "hover_ease_type", "default": "smooth", "options": [{"label": "Smooth", "value": "smooth"}, {"label": "Linear", "value": "linear"}, {"label": "Snappy", "value": "snappy"}, {"label": "Soft", "value": "soft"}, {"label": "Crisp", "value": "crisp"}]},
	{"name": "button_hybrid_pressed_ease_type", "label": "pressed_ease_type", "default": "snappy", "options": [{"label": "Smooth", "value": "smooth"}, {"label": "Linear", "value": "linear"}, {"label": "Snappy", "value": "snappy"}, {"label": "Soft", "value": "soft"}, {"label": "Crisp", "value": "crisp"}]},
]

const SECTION_SPACER_HEIGHT := 56.0

@export var auto_rotate := true
@export_range(0.0, 90.0, 0.1) var auto_rotate_speed_deg := 36.0
@export_range(0.0, 120.0, 0.1) var manual_rotate_speed_deg := 54.0

@onready var camera_3d: Camera3D = get_node_or_null("Camera3D") as Camera3D
@onready var panel_pivot: Node3D = get_node_or_null("PanelPivot") as Node3D
@onready var panel_viewport: SubViewport = get_node_or_null("PanelPivot/PanelViewport") as SubViewport
@onready var mask_viewport: SubViewport = get_node_or_null("PanelPivot/MaskViewport") as SubViewport
@onready var panel_display: MeshInstance3D = get_node_or_null("PanelPivot/PanelDisplay") as MeshInstance3D
@onready var panel_ui_overlay: MeshInstance3D = get_node_or_null("PanelPivot/PanelUiOverlay") as MeshInstance3D
@onready var panel_input_surface: Area3D = get_node_or_null("PanelPivot/PanelInputSurface") as Area3D
@onready var controls_list: VBoxContainer = get_node_or_null("CanvasLayer/OverlayRoot/SplitRoot/ControlsPanel/Margin/ControlsColumn/ControlsScroll/ControlsList") as VBoxContainer
@onready var interaction_bus: AeroUiInteractionBus = get_node_or_null("AeroUiInteractionBus") as AeroUiInteractionBus
@onready var hybrid_input_adapter: HybridSubViewportInputAdapter = get_node_or_null("HybridInputAdapter") as HybridSubViewportInputAdapter

var _panel_ui: AeroUiGlassPanelView
var _mask_ui: AeroUiGlassPanelView
var _panel_material: ShaderMaterial
var _panel_ui_overlay_material: ShaderMaterial
var _authored_glass_rect := Rect2(0.0, 0.0, 1.0, 1.0)
var _manual_pitch_deg := 0.0
var _manual_yaw_deg := 0.0
var _base_rotation := Vector3.ZERO
var _background_mode_selector: OptionButton
var _float_sliders: Dictionary = {}
var _color_pickers: Dictionary = {}
var _option_selectors: Dictionary = {}
var _preset_status_label: Label
var _contract_status_label: RichTextLabel
var _save_dialog: FileDialog
var _load_dialog: FileDialog
var _pending_save_section := PRESET_SECTION_PANEL
var _pending_load_section := PRESET_SECTION_PANEL
var _spatial_surface_descriptor: AeroSpatialSurfaceDescriptor
var _spatial_projection_helper: AeroSpatialProjectionHelper = SpatialProjectionHelperScript.new()
var _spatial_mouse_provider: AeroSpatialUiMouseProvider
var _spatial_touch_provider = null
var _last_release_target_path := ""
var _last_forwarded_panel_event := "waiting for normalized panel input"
var _last_contract_phase := "waiting"
var _last_contract_source_variant := "waiting"
var _last_contract_surface_id := String(HYBRID_SURFACE_ID)
var _last_contract_verification_status := "waiting"
var _last_contract_verification_notes := "No normalized interaction published yet."
var _last_contract_target_path := ""
var _mouse_provider_runtime_seam := "AeroSpatialUiMouseProvider (installed packaged seam)"


func _ready() -> void:
	if camera_3d == null or panel_pivot == null or panel_viewport == null or mask_viewport == null or panel_display == null or panel_ui_overlay == null or panel_input_surface == null:
		push_error("3D GUI glass test scene is missing one or more required nodes.")
		return

	_base_rotation = panel_pivot.rotation_degrees
	_configure_subviewport(panel_viewport)
	_configure_subviewport(mask_viewport)
	_mount_panel_views()
	_configure_panel_views_for_hybrid()
	_ensure_interaction_contract_nodes()
	_build_spatial_provider_runtime()
	_inject_panel_view_interaction_bus()
	_apply_panel_materials()
	_build_controls()
	_setup_preset_dialogs()
	call_deferred("_sync_controls_from_panel")
	call_deferred("_sync_authored_card_rect")
	_apply_panel_rotation()
	_refresh_status()


func _process(delta: float) -> void:
	var yaw_input := _axis_strength(KEY_LEFT, KEY_RIGHT, KEY_A, KEY_D)
	var pitch_input := _axis_strength(KEY_DOWN, KEY_UP, KEY_S, KEY_W)
	if yaw_input != 0.0 or pitch_input != 0.0:
		_manual_yaw_deg = clampf(_manual_yaw_deg + yaw_input * manual_rotate_speed_deg * delta, -MAX_MANUAL_YAW_DEG, MAX_MANUAL_YAW_DEG)
		_manual_pitch_deg = clampf(_manual_pitch_deg + pitch_input * manual_rotate_speed_deg * delta, -MAX_MANUAL_PITCH_DEG, MAX_MANUAL_PITCH_DEG)

	_apply_panel_rotation()
	_refresh_status()


func _unhandled_input(event: InputEvent) -> void:
	if _forward_world_panel_input(event):
		get_viewport().set_input_as_handled()
		_refresh_status()
		return

	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_SPACE:
				auto_rotate = !auto_rotate
			KEY_R:
				reset_manual_rotation()
			KEY_1:
				set_preview_background_mode(PanelViewScript.BACKGROUND_MODE_IMAGE)
			KEY_2:
				set_preview_background_mode(PanelViewScript.BACKGROUND_MODE_DEBUG)
			KEY_3:
				set_preview_background_mode(PanelViewScript.BACKGROUND_MODE_HYBRID)
			KEY_4:
				set_preview_background_mode(PanelViewScript.BACKGROUND_MODE_NONE)
			_:
				return
		_refresh_status()


func _ensure_interaction_contract_nodes() -> void:
	if interaction_bus == null:
		interaction_bus = AeroUiInteractionBus.new()
		interaction_bus.name = "AeroUiInteractionBus"
		add_child(interaction_bus)
	if hybrid_input_adapter == null:
		hybrid_input_adapter = HybridSubViewportInputAdapter.new()
		hybrid_input_adapter.name = "HybridInputAdapter"
		hybrid_input_adapter.bus_path = NodePath("../AeroUiInteractionBus")
		hybrid_input_adapter.surface_id = HYBRID_SURFACE_ID
		hybrid_input_adapter.surface_type = HYBRID_SURFACE_TYPE
		hybrid_input_adapter.drag_threshold_pixels = 12.0
		add_child(hybrid_input_adapter)
	hybrid_input_adapter.surface_pixel_size = Vector2(panel_viewport.size)
	if not interaction_bus.interaction_event.is_connected(_on_contract_interaction_event):
		interaction_bus.interaction_event.connect(_on_contract_interaction_event)


func _inject_panel_view_interaction_bus() -> void:
	if not is_instance_valid(interaction_bus):
		return
	var bus_path := interaction_bus.get_path()
	for source in [_panel_ui, _mask_ui]:
		if is_instance_valid(source):
			source.set_interaction_bus_path(bus_path)


func _build_spatial_provider_runtime() -> void:
	var mouse_config: AeroSpatialUiMouseProviderConfig = SpatialUiMouseProviderConfigScript.new()
	mouse_config.pointer_id = HYBRID_POINTER_MOUSE
	mouse_config.drag_threshold_pixels = hybrid_input_adapter.drag_threshold_pixels if hybrid_input_adapter != null else 12.0
	mouse_config.host_surface = "PanelInputSurface"
	mouse_config.target_resolution = "rect_target_specs"
	_spatial_mouse_provider = SpatialUiMouseProviderScript.new(mouse_config)

	var touch_config = SpatialUiTouchProviderConfigScript.new()
	touch_config.pointer_id_prefix = "touch_"
	touch_config.drag_threshold_pixels = hybrid_input_adapter.drag_threshold_pixels if hybrid_input_adapter != null else 12.0
	touch_config.host_surface = "PanelInputSurface"
	touch_config.target_resolution = "rect_target_specs"
	_spatial_touch_provider = SpatialUiTouchProviderScript.new(touch_config)
	_refresh_spatial_surface_descriptor()


func _refresh_spatial_surface_descriptor() -> void:
	if not is_instance_valid(_panel_ui) or panel_viewport == null:
		return
	if _spatial_surface_descriptor == null:
		_spatial_surface_descriptor = SpatialSurfaceDescriptorScript.new()
	var localized_target_specs: Array = []
	var root_rect := _panel_ui.get_global_rect()
	for spec_variant in _panel_ui.get_interaction_target_specs():
		if not (spec_variant is Dictionary):
			continue
		localized_target_specs.append((spec_variant as Dictionary).duplicate(true))
	_spatial_surface_descriptor.configure({
		"surface_id": HYBRID_SURFACE_ID,
		"surface_path": panel_input_surface.get_path() if is_instance_valid(panel_input_surface) else NodePath(),
		"viewport_path": panel_viewport.get_path(),
		"surface_pixel_size": root_rect.size,
		"authored_rect_normalized": _authored_glass_rect,
		"target_specs": localized_target_specs,
		"metadata": {
			"host_surface": "PanelInputSurface",
			"target_resolution": "rect_target_specs",
			"surface_size": _get_panel_surface_size(),
		},
	})


func _current_mouse_runtime_state() -> Dictionary:
	return _spatial_mouse_provider.describe_runtime_state() if _spatial_mouse_provider != null else {}


func _current_touch_runtime_state() -> Dictionary:
	return _spatial_touch_provider.describe_runtime_state() if _spatial_touch_provider != null else {}


func _current_touch_interaction_summary() -> Dictionary:
	return _spatial_touch_provider.describe_interaction_summary() if _spatial_touch_provider != null else {}


func _forward_world_panel_input(event: InputEvent) -> bool:
	# Reference-only host seam:
	# this repo still demonstrates the host-driven 3D path end-to-end so Phase 2 has a
	# stable extraction target. Reusable spatial helper/provider code should move out to
	# the spatial-ui repos instead of continuing to accumulate in ui-kit-community.
	if hybrid_input_adapter == null or panel_input_surface == null or camera_3d == null:
		return false

	if event is InputEventMouseButton:
		return _publish_mouse_button_to_contract(event)
	if event is InputEventMouseMotion:
		return _publish_mouse_motion_to_contract(event)
	if event is InputEventScreenTouch:
		return _publish_screen_touch_to_contract(event)
	if event is InputEventScreenDrag:
		return _publish_screen_drag_to_contract(event)
	return false


func _publish_mouse_button_to_contract(event: InputEventMouseButton) -> bool:
	if _spatial_mouse_provider == null or hybrid_input_adapter == null or _spatial_surface_descriptor == null:
		return false
	var published := _spatial_mouse_provider.publish_input_event(
		hybrid_input_adapter,
		_spatial_surface_descriptor,
		event,
		_screen_position_to_panel_hit(event.position),
		{"pointer_id": HYBRID_POINTER_MOUSE, "host_surface": "PanelInputSurface", "target_resolution": "rect_target_specs"}
	)
	if published:
		var state := _current_mouse_runtime_state()
		var projected_data: Dictionary = state.get("last_projected_data", {})
		_last_release_target_path = str(state.get("last_release_target_path", _last_release_target_path))
		if not projected_data.is_empty():
			_last_forwarded_panel_event = str(state.get("last_forwarded_panel_event", _last_forwarded_panel_event))
	return published


func _publish_mouse_motion_to_contract(event: InputEventMouseMotion) -> bool:
	if _spatial_mouse_provider == null or hybrid_input_adapter == null or _spatial_surface_descriptor == null:
		return false
	var published := _spatial_mouse_provider.publish_input_event(
		hybrid_input_adapter,
		_spatial_surface_descriptor,
		event,
		_screen_position_to_panel_hit(event.position),
		{"pointer_id": HYBRID_POINTER_MOUSE, "host_surface": "PanelInputSurface", "target_resolution": "rect_target_specs"}
	)
	if published:
		var state := _current_mouse_runtime_state()
		_last_release_target_path = str(state.get("last_release_target_path", _last_release_target_path))
		_last_forwarded_panel_event = str(state.get("last_forwarded_panel_event", _last_forwarded_panel_event))
	return published


func _publish_mouse_release_from_motion(event: InputEventMouseMotion, hit: Dictionary, live_target_path: NodePath) -> void:
	var synthetic_release := InputEventMouseButton.new()
	synthetic_release.button_index = MOUSE_BUTTON_LEFT
	synthetic_release.pressed = false
	synthetic_release.position = event.position
	synthetic_release.button_mask = event.button_mask
	_publish_mouse_button_to_contract(synthetic_release)
	var mouse_state := _current_mouse_runtime_state()
	var projected_data: Dictionary = mouse_state.get("last_projected_data", {})
	_last_forwarded_panel_event = "publish mouse release (motion button mask drop) -> %.0f, %.0f • hover %s • owner %s" % [
		Vector2(hit.get("viewport_position", projected_data.get("surface_position", Vector2.ZERO))).x,
		Vector2(hit.get("viewport_position", projected_data.get("surface_position", Vector2.ZERO))).y,
		_path_label(live_target_path),
		_path_label(mouse_state.get("capture_target_path", NodePath()))
	]


func _publish_screen_touch_to_contract(event: InputEventScreenTouch) -> bool:
	if _spatial_touch_provider == null or hybrid_input_adapter == null or _spatial_surface_descriptor == null:
		return false
	var published: bool = _spatial_touch_provider.publish_input_event(
		hybrid_input_adapter,
		_spatial_surface_descriptor,
		event,
		_screen_position_to_panel_hit(event.position),
		{"host_surface": "PanelInputSurface", "target_resolution": "rect_target_specs"}
	)
	if published:
		var summary := _current_touch_interaction_summary()
		_last_release_target_path = str(summary.get("last_release_target_path", _last_release_target_path))
		_last_forwarded_panel_event = str(summary.get("last_forwarded_panel_event", _last_forwarded_panel_event))
	return published


func _publish_screen_drag_to_contract(event: InputEventScreenDrag) -> bool:
	if _spatial_touch_provider == null or hybrid_input_adapter == null or _spatial_surface_descriptor == null:
		return false
	var published: bool = _spatial_touch_provider.publish_input_event(
		hybrid_input_adapter,
		_spatial_surface_descriptor,
		event,
		_screen_position_to_panel_hit(event.position),
		{"host_surface": "PanelInputSurface", "target_resolution": "rect_target_specs"}
	)
	if published:
		var summary := _current_touch_interaction_summary()
		_last_release_target_path = str(summary.get("last_release_target_path", _last_release_target_path))
		_last_forwarded_panel_event = str(summary.get("last_forwarded_panel_event", _last_forwarded_panel_event))
	return published


func _publish_projected_phase(
	phase: StringName,
	pointer_id: StringName,
	projected_data: Dictionary,
	overrides: Dictionary
) -> AeroUiInteractionEvent:
	return hybrid_input_adapter.publish_projected_phase(phase, pointer_id, projected_data, overrides)


func _screen_position_to_panel_hit(screen_position: Vector2) -> Dictionary:
	_refresh_spatial_surface_descriptor()
	var ray_origin := camera_3d.project_ray_origin(screen_position)
	var ray_direction := camera_3d.project_ray_normal(screen_position)
	var query := PhysicsRayQueryParameters3D.create(ray_origin, ray_origin + ray_direction * camera_3d.far)
	query.collide_with_areas = true
	query.collide_with_bodies = false

	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty() or hit.get("collider") != panel_input_surface:
		return {
			"hit": false,
			"screen_position": screen_position,
			"world_direction": ray_direction,
		}

	var local_hit: Vector3 = panel_input_surface.to_local(hit["position"])
	var panel_size := _get_panel_surface_size()
	if panel_size.x <= 0.0 or panel_size.y <= 0.0 or _spatial_surface_descriptor == null:
		return {"hit": false, "screen_position": screen_position, "world_direction": ray_direction}

	var panel_uv := Vector2(
		(local_hit.x / panel_size.x) + 0.5,
		0.5 - (local_hit.y / panel_size.y)
	)
	return _spatial_projection_helper.build_surface_hit(_spatial_surface_descriptor, panel_uv, {
		"screen_position": screen_position,
		"local_hit": local_hit,
		"world_position": hit["position"],
		"world_normal": hit.get("normal", Vector3.ZERO),
		"world_direction": ray_direction,
		"surface_size": panel_size,
	})


func _build_projected_data(
	screen_position: Vector2,
	hit: Dictionary,
	previous_projected: Dictionary = {},
	explicit_target_path: NodePath = NodePath(),
	live_target_path: NodePath = NodePath()
) -> Dictionary:
	_refresh_spatial_surface_descriptor()
	if _spatial_touch_provider == null or _spatial_surface_descriptor == null:
		return {}
	var context := {
		"host_surface": "PanelInputSurface",
		"target_resolution": "rect_target_specs",
	}
	return _spatial_touch_provider.build_projected_data_for_hit(
		_spatial_surface_descriptor,
		hit,
		context,
		previous_projected,
		explicit_target_path,
		live_target_path
	)


func _resolve_projected_target_path_from_hit(hit: Dictionary) -> NodePath:
	_refresh_spatial_surface_descriptor()
	if _spatial_touch_provider == null or _spatial_surface_descriptor == null:
		return NodePath()
	return _spatial_touch_provider.resolve_target_path_for_hit(_spatial_surface_descriptor, hit)


func _resolve_projected_target_path(surface_position: Vector2, surface_uv: Vector2 = Vector2(-1.0, -1.0)) -> NodePath:
	return _resolve_projected_target_path_from_hit({
		"authored_viewport_position": surface_position,
		"authored_uv": surface_uv,
		"viewport_position": surface_position,
		"surface_position": surface_position,
		"surface_normalized_position": surface_uv,
	})


func _normalize_panel_target_rect(rect: Rect2) -> Rect2:
	if _spatial_surface_descriptor == null:
		return Rect2()
	return _spatial_surface_descriptor.normalize_surface_rect(rect)


func _path_label(path: Variant) -> String:
	if path is NodePath and path == NodePath():
		return "none"
	var path_text := str(path)
	if path_text == "":
		return "none"
	return path_text.get_file()


func _on_contract_interaction_event(event: AeroUiInteractionEvent) -> void:
	if event.surface_id != HYBRID_SURFACE_ID:
		return
	_last_contract_phase = str(event.phase)
	_last_contract_source_variant = str(event.source_variant)
	_last_contract_surface_id = str(event.surface_id)
	_last_contract_verification_status = str(event.verification_status)
	_last_contract_verification_notes = str(event.verification_notes)
	_last_contract_target_path = str(event.target_path)
	_last_forwarded_panel_event = "%s • %s • %s" % [event.source_variant, event.phase, event.verification_status]


func _get_panel_surface_size() -> Vector2:
	if panel_display != null and panel_display.mesh is QuadMesh:
		return (panel_display.mesh as QuadMesh).size
	return Vector2(2.93, 1.577)


func set_auto_rotate_enabled(value: bool) -> void:
	auto_rotate = value
	_apply_panel_rotation()
	_refresh_status()


func set_manual_rotation(pitch_deg: float, yaw_deg: float) -> void:
	_manual_pitch_deg = clampf(pitch_deg, -MAX_MANUAL_PITCH_DEG, MAX_MANUAL_PITCH_DEG)
	_manual_yaw_deg = clampf(yaw_deg, -MAX_MANUAL_YAW_DEG, MAX_MANUAL_YAW_DEG)
	_apply_panel_rotation()
	_refresh_status()


func reset_manual_rotation() -> void:
	_manual_pitch_deg = 0.0
	_manual_yaw_deg = 0.0
	_apply_panel_rotation()
	_refresh_status()


func set_preview_background_mode(mode: int) -> void:
	if is_instance_valid(_panel_ui):
		_panel_ui.set_background_mode(mode)
	if is_instance_valid(_background_mode_selector):
		_select_background_mode(get_preview_background_mode())
	_refresh_status()


func get_preview_background_mode() -> int:
	if is_instance_valid(_panel_ui):
		return _panel_ui.get_background_mode()
	return PanelViewScript.BACKGROUND_MODE_NONE


func set_panel_shader_parameter(parameter_name: String, value: Variant) -> void:
	if _panel_material == null:
		return

	if _is_hybrid_shell_parameter(parameter_name):
		_sync_hybrid_shell({parameter_name: value})
		_sync_single_control_from_panel(parameter_name)
		_refresh_status()
		return

	var resolved: Dictionary = _resolve_parameter_alias(parameter_name, value)
	if not _is_overlay_parameter(parameter_name):
		_panel_material.set_shader_parameter(resolved["name"], resolved["value"])
	_apply_overlay_shader_parameter(parameter_name, value)
	_sync_hybrid_shell_parameter(parameter_name, value)
	if parameter_name == "corner_radius":
		_sync_authored_card_rect()
	_sync_single_control_from_panel(parameter_name)
	_sync_single_control_from_panel(str(resolved["name"]))
	_refresh_status()


func get_panel_shader_parameter(parameter_name: String) -> Variant:
	if _is_hybrid_shell_parameter(parameter_name):
		return _get_hybrid_shell_parameter(parameter_name)
	if _is_overlay_parameter(parameter_name):
		return _get_overlay_shader_parameter(parameter_name)

	if _panel_material == null:
		return null

	var alias: Variant = PARAMETER_ALIASES.get(parameter_name, null)
	if alias is Dictionary:
		var resolved_value: Variant = _panel_material.get_shader_parameter(str(alias["target"]))
		if alias.has("scale") and resolved_value is float:
			return float(resolved_value) / float(alias["scale"])
		return resolved_value

	return _panel_material.get_shader_parameter(parameter_name)


func _apply_overlay_shader_parameter(parameter_name: String, value: Variant) -> void:
	if _panel_ui_overlay_material == null:
		return
	if not _is_overlay_parameter(parameter_name):
		return
	_panel_ui_overlay_material.set_shader_parameter(parameter_name, value)


func _get_overlay_shader_parameter(parameter_name: String) -> Variant:
	if _panel_ui_overlay_material == null:
		return null
	if not _is_overlay_parameter(parameter_name):
		return null
	return _panel_ui_overlay_material.get_shader_parameter(parameter_name)


func _sync_hybrid_shell_parameter(parameter_name: String, value: Variant) -> void:
	var shell_updates: Dictionary = {}
	match parameter_name:
		"corner_radius", "edge_width", "tint":
			shell_updates[parameter_name] = value
		_:
			return
	_sync_hybrid_shell(shell_updates)


func _sync_hybrid_shell(shell_updates: Dictionary) -> void:
	for source in [_panel_ui, _mask_ui]:
		if is_instance_valid(source):
			source.sync_hybrid_shell(shell_updates)


func _get_hybrid_shell_parameter(parameter_name: String) -> Variant:
	if is_instance_valid(_panel_ui):
		return _panel_ui.get_hybrid_shell_parameter(parameter_name)
	return null


func _is_hybrid_shell_parameter(parameter_name: String) -> bool:
	return parameter_name.begins_with("hybrid_")


func _is_overlay_parameter(parameter_name: String) -> bool:
	return parameter_name.begins_with("ui_overlay_")


func _configure_subviewport(viewport: SubViewport) -> void:
	viewport.disable_3d = true
	viewport.transparent_bg = true
	viewport.gui_disable_input = true
	viewport.handle_input_locally = false
	viewport.msaa_2d = Viewport.MSAA_4X
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.size = Vector2i(1600, 900)
	if viewport == panel_viewport and hybrid_input_adapter != null:
		hybrid_input_adapter.surface_pixel_size = Vector2(viewport.size)


func _mount_panel_views() -> void:
	_panel_ui = _instantiate_panel_view(panel_viewport)
	_mask_ui = _instantiate_panel_view(mask_viewport)


func _instantiate_panel_view(target_viewport: SubViewport) -> AeroUiGlassPanelView:
	for child in target_viewport.get_children():
		child.queue_free()

	var packed: PackedScene = load(PANEL_VIEW_SCENE_PATH)
	if packed == null:
		push_error("Failed to load AeroUiGlassPanelView scene: %s" % PANEL_VIEW_SCENE_PATH)
		return null

	var instance := packed.instantiate() as AeroUiGlassPanelView
	if instance == null:
		push_error("AeroUiGlassPanelView scene did not instantiate as a Control root.")
		return null

	target_viewport.add_child(instance)
	instance.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return instance


func _configure_panel_views_for_hybrid() -> void:
	if is_instance_valid(_panel_ui):
		_panel_ui.set_presentation_mode(PanelViewScript.PRESENTATION_MODE_HYBRID_WORLD_SPACE)
		_panel_ui.set_background_mode(PanelViewScript.BACKGROUND_MODE_NONE)

	if is_instance_valid(_mask_ui):
		_mask_ui.set_presentation_mode(PanelViewScript.PRESENTATION_MODE_HYBRID_MASK)
		_mask_ui.set_background_mode(PanelViewScript.BACKGROUND_MODE_NONE)


func _apply_panel_materials() -> void:
	var shader: Shader = load(HYBRID_SHADER_PATH)
	if shader == null:
		push_error("Failed to load hybrid 3D glass shader: %s" % HYBRID_SHADER_PATH)
		return
	var overlay_shader: Shader = load(UI_OVERLAY_SHADER_PATH)
	if overlay_shader == null:
		push_error("Failed to load hybrid 3D UI overlay shader: %s" % UI_OVERLAY_SHADER_PATH)
		return

	_panel_material = ShaderMaterial.new()
	_panel_material.shader = shader
	_panel_ui_overlay_material = ShaderMaterial.new()
	_panel_ui_overlay_material.shader = overlay_shader
	for config in HYBRID_FLOAT_CONTROLS:
		set_panel_shader_parameter(str(config["name"]), config["default"])
	for config in HYBRID_COLOR_CONTROLS:
		set_panel_shader_parameter(str(config["name"]), config["default"])

	_panel_material.set_shader_parameter("flip_ui_vertical", false)
	_panel_material.set_shader_parameter("ui_shadow_strength", 0.02)
	_panel_material.set_shader_parameter("ui_texture", panel_viewport.get_texture())
	_panel_material.set_shader_parameter("mask_texture", mask_viewport.get_texture())
	_panel_ui_overlay_material.set_shader_parameter("flip_ui_vertical", false)
	_panel_ui_overlay_material.set_shader_parameter("ui_texture", panel_viewport.get_texture())
	_panel_ui_overlay_material.set_shader_parameter("mask_texture", mask_viewport.get_texture())
	_sync_authored_card_rect()
	panel_display.material_override = _panel_material
	panel_ui_overlay.material_override = _panel_ui_overlay_material


func _build_controls() -> void:
	for child in controls_list.get_children():
		child.queue_free()

	controls_list.add_theme_constant_override("separation", 24)
	_float_sliders.clear()
	_color_pickers.clear()
	_option_selectors.clear()
	_background_mode_selector = null
	_preset_status_label = null
	_contract_status_label = null

	_append_controls_section(_make_section_block("panel", [
		_make_background_mode_control(),
		_make_yaml_actions_block("", PRESET_SECTION_PANEL, "Root panel YAML with badge/button references."),
		_make_parameter_section("live shader values", PanelViewScript.FLOAT_CONTROLS, PanelViewScript.COLOR_CONTROLS),
		_make_filtered_parameter_section("hybrid presentation", HYBRID_FLOAT_CONTROLS, PANEL_PRESENTATION_FLOAT_PARAMETER_NAMES, [], []),
		_make_filtered_parameter_section("3d panel material", HYBRID_FLOAT_CONTROLS, HYBRID_ONLY_FLOAT_PARAMETER_NAMES, HYBRID_COLOR_CONTROLS, HYBRID_ONLY_COLOR_PARAMETER_NAMES),
	], SECTION_SPACER_HEIGHT))
	_append_controls_section(_make_section_block("badge", [
		_make_yaml_actions_block("", PRESET_SECTION_BADGE, "Badge component YAML."),
		_make_parameter_section("shared badge config", BADGE_EDITOR_BASE_CONTROLS, BADGE_EDITOR_COLOR_CONTROLS),
		_make_float_parameter_section("hybrid presentation", BADGE_EDITOR_HYBRID_CONTROLS),
	], SECTION_SPACER_HEIGHT))
	_append_controls_section(_make_section_block("primary button", [
		_make_yaml_actions_block("", PRESET_SECTION_BUTTON, "Primary button component YAML."),
		_make_parameter_section("shared button config", BUTTON_EDITOR_BASE_CONTROLS, BUTTON_EDITOR_COLOR_CONTROLS),
		_make_float_parameter_section("hybrid presentation + interaction", BUTTON_EDITOR_HYBRID_CONTROLS),
	], SECTION_SPACER_HEIGHT))
	_append_controls_section(_make_section_block("input debug", [
		_make_preset_status_block(),
		_make_contract_status_block(),
	], SECTION_SPACER_HEIGHT), false)

	var tail_spacer := Control.new()
	tail_spacer.custom_minimum_size = Vector2(0.0, 8.0)
	controls_list.add_child(tail_spacer)


func _make_background_mode_control() -> Control:
	var wrapper := VBoxContainer.new()
	wrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var label := Label.new()
	label.text = "preview background"
	wrapper.add_child(label)

	var selector := OptionButton.new()
	selector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	selector.add_item("AeroBeat image", PanelViewScript.BACKGROUND_MODE_IMAGE)
	selector.add_item("Debug pattern", PanelViewScript.BACKGROUND_MODE_DEBUG)
	selector.add_item("Hybrid overlay", PanelViewScript.BACKGROUND_MODE_HYBRID)
	selector.add_item("No background", PanelViewScript.BACKGROUND_MODE_NONE)
	selector.item_selected.connect(_on_background_mode_selected.bind(selector))
	wrapper.add_child(selector)
	_background_mode_selector = selector
	return wrapper


func _make_contract_status_block() -> Control:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var style := StyleBoxFlat.new()
	style.content_margin_left = 0.0
	style.content_margin_top = 0.0
	style.content_margin_right = 0.0
	style.content_margin_bottom = 0.0
	style.bg_color = Color(0.04, 0.05, 0.08, 0.82)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(1, 1, 1, 0.08)
	style.corner_radius_top_left = 14
	style.corner_radius_top_right = 14
	style.corner_radius_bottom_right = 14
	style.corner_radius_bottom_left = 14
	style.shadow_color = Color(0, 0, 0, 0.28)
	style.shadow_size = 18
	panel.add_theme_stylebox_override("panel", style)

	var padding := MarginContainer.new()
	padding.add_theme_constant_override("margin_left", 14)
	padding.add_theme_constant_override("margin_top", 12)
	padding.add_theme_constant_override("margin_right", 14)
	padding.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(padding)

	var status := RichTextLabel.new()
	status.custom_minimum_size = Vector2(0.0, 92.0)
	status.bbcode_enabled = true
	status.fit_content = true
	status.scroll_active = false
	padding.add_child(status)
	_contract_status_label = status
	return panel


func _append_controls_section(section: Control, include_spacer: bool = true) -> void:
	controls_list.add_child(section)
	if include_spacer:
		var spacer := Control.new()
		spacer.custom_minimum_size = Vector2(0.0, SECTION_SPACER_HEIGHT)
		controls_list.add_child(spacer)


func _make_section_block(title_text: String, blocks: Array, block_spacer_height: float = 0.0) -> Control:
	var wrapper := VBoxContainer.new()
	wrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wrapper.add_theme_constant_override("separation", 8)

	var title := Label.new()
	title.text = title_text
	wrapper.add_child(title)

	var visible_block_index := 0
	for block in blocks:
		if not (block is Control):
			continue
		if visible_block_index > 0 and block_spacer_height > 0.0:
			var spacer := Control.new()
			spacer.custom_minimum_size = Vector2(0.0, block_spacer_height)
			wrapper.add_child(spacer)
		wrapper.add_child(block)
		visible_block_index += 1

	return wrapper


func _make_float_parameter_section(title_text: String, float_configs: Array) -> Control:
	return _make_parameter_section(title_text, float_configs, [])


func _make_yaml_actions_block(title_text: String, section_key: String, subtitle_text: String = "") -> Control:
	var wrapper := VBoxContainer.new()
	wrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wrapper.add_theme_constant_override("separation", 8)

	if not title_text.is_empty():
		var title := Label.new()
		title.text = title_text
		wrapper.add_child(title)

	if not subtitle_text.is_empty():
		var subtitle := Label.new()
		subtitle.text = subtitle_text
		subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		subtitle.modulate = Color(1.0, 1.0, 1.0, 0.68)
		wrapper.add_child(subtitle)

	var button_row := HBoxContainer.new()
	button_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button_row.add_theme_constant_override("separation", 8)
	wrapper.add_child(button_row)

	var export_button := Button.new()
	export_button.text = "Export YAML"
	export_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	export_button.pressed.connect(_open_export_dialog_for_section.bind(section_key))
	button_row.add_child(export_button)

	var load_button := Button.new()
	load_button.text = "Load YAML"
	load_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	load_button.pressed.connect(_open_load_dialog_for_section.bind(section_key))
	button_row.add_child(load_button)

	return wrapper


func _make_parameter_section(title_text: String, float_configs: Array, color_configs: Array, option_configs: Array = []) -> Control:
	var wrapper := VBoxContainer.new()
	wrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wrapper.add_theme_constant_override("separation", 8)

	if not title_text.is_empty():
		var title := Label.new()
		title.text = title_text
		wrapper.add_child(title)

	for config in float_configs:
		wrapper.add_child(_make_float_control(config))
	for config in color_configs:
		wrapper.add_child(_make_color_control(config))
	for config in option_configs:
		wrapper.add_child(_make_option_control(config))

	return wrapper


func _make_filtered_parameter_section(title_text: String, float_source: Array, float_names: Array, color_source: Array, color_names: Array) -> Control:
	var wrapper := VBoxContainer.new()
	wrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wrapper.add_theme_constant_override("separation", 8)

	if not title_text.is_empty():
		var title := Label.new()
		title.text = title_text
		wrapper.add_child(title)

	for config in float_source:
		var parameter_name := str(config.get("name", ""))
		if float_names.has(parameter_name):
			wrapper.add_child(_make_float_control(config))

	for config in color_source:
		var parameter_name := str(config.get("name", ""))
		if color_names.has(parameter_name):
			wrapper.add_child(_make_color_control(config))

	return wrapper


func _make_preset_status_block() -> Control:
	var wrapper := VBoxContainer.new()
	wrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wrapper.add_theme_constant_override("separation", 4)

	var title := Label.new()
	title.text = "yaml status"
	wrapper.add_child(title)

	var status := Label.new()
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status.modulate = Color(1.0, 1.0, 1.0, 0.6)
	status.text = "Panel, badge, and primary button each target their authored YAML directly."
	wrapper.add_child(status)
	_preset_status_label = status

	return wrapper


func _make_float_control(config: Dictionary) -> Control:
	var wrapper := VBoxContainer.new()
	wrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var label := Label.new()
	label.text = str(config["label"])
	wrapper.add_child(label)

	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wrapper.add_child(row)

	var slider := HSlider.new()
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.min_value = float(config["min"])
	slider.max_value = float(config["max"])
	slider.step = float(config["step"])
	slider.value = float(config["default"])
	slider.value_changed.connect(_on_float_value_changed.bind(str(config["name"]), slider))
	row.add_child(slider)

	var value_label := Label.new()
	value_label.custom_minimum_size = Vector2(56.0, 0.0)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value_label.text = _format_float(slider.value)
	row.add_child(value_label)

	slider.set_meta("value_label", value_label)
	_float_sliders[str(config["name"])] = slider
	return wrapper


func _make_color_control(config: Dictionary) -> Control:
	var wrapper := VBoxContainer.new()
	wrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var label := Label.new()
	label.text = str(config["label"])
	wrapper.add_child(label)

	var picker := ColorPickerButton.new()
	picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	picker.custom_minimum_size = Vector2(0.0, 28.0)
	picker.color = config["default"]
	picker.color_changed.connect(_on_color_value_changed.bind(str(config["name"])))
	wrapper.add_child(picker)

	_color_pickers[str(config["name"])] = picker
	return wrapper


func _make_option_control(config: Dictionary) -> Control:
	var wrapper := VBoxContainer.new()
	wrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var label := Label.new()
	label.text = str(config["label"])
	wrapper.add_child(label)

	var selector := OptionButton.new()
	selector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var options := config.get("options", []) as Array
	for option in options:
		var option_dict := option as Dictionary
		selector.add_item(str(option_dict.get("label", option_dict.get("value", "option"))))
		selector.set_item_metadata(selector.item_count - 1, str(option_dict.get("value", "")))
	selector.item_selected.connect(_on_option_value_selected.bind(str(config["name"]), selector))
	wrapper.add_child(selector)

	_option_selectors[str(config["name"])] = selector
	return wrapper


func _on_option_value_selected(index: int, parameter_name: String, selector: OptionButton) -> void:
	var value := str(selector.get_item_metadata(index))
	_set_live_control_value(parameter_name, value)


func _setup_preset_dialogs() -> void:
	_ensure_preset_directory()
	if _save_dialog == null:
		_save_dialog = _create_preset_dialog(FileDialog.FILE_MODE_SAVE_FILE, "Export AeroUiGlass YAML")
		_save_dialog.file_selected.connect(_on_save_dialog_file_selected)
		add_child(_save_dialog)
	if _load_dialog == null:
		_load_dialog = _create_preset_dialog(FileDialog.FILE_MODE_OPEN_FILE, "Load AeroUiGlass YAML")
		_load_dialog.file_selected.connect(_on_load_dialog_file_selected)
		add_child(_load_dialog)


func _create_preset_dialog(file_mode: FileDialog.FileMode, title_text: String) -> FileDialog:
	var dialog := FileDialog.new()
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.file_mode = file_mode
	dialog.title = title_text
	dialog.use_native_dialog = true
	dialog.filters = PackedStringArray(["*.yaml, *.yml ; AeroUiGlass YAML"])
	dialog.current_dir = ProjectSettings.globalize_path(_preset_directory_for_section(PRESET_SECTION_PANEL))
	dialog.current_file = _default_filename_for_section(PRESET_SECTION_PANEL)
	return dialog


func _ensure_preset_directory() -> void:
	for directory in [PANEL_PRESET_DIALOG_DIRECTORY, BADGE_PRESET_DIALOG_DIRECTORY, BUTTON_PRESET_DIALOG_DIRECTORY]:
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))


func _on_background_mode_selected(index: int, selector: OptionButton) -> void:
	set_preview_background_mode(selector.get_item_id(index))


func _on_float_value_changed(value: float, parameter_name: String, slider: HSlider) -> void:
	_set_live_control_value(parameter_name, value)
	var value_label: Label = slider.get_meta("value_label") as Label
	if value_label:
		value_label.text = _format_float(value)


func _on_color_value_changed(color: Color, parameter_name: String) -> void:
	set_panel_shader_parameter(parameter_name, color)


func _open_export_dialog_for_section(section_key: String) -> void:
	_ensure_preset_directory()
	_pending_save_section = section_key
	_save_dialog.title = _export_dialog_title(section_key)
	_save_dialog.current_dir = ProjectSettings.globalize_path(_preset_directory_for_section(section_key))
	_save_dialog.current_file = _default_filename_for_section(section_key)
	_save_dialog.popup_centered_ratio(0.7)


func _open_load_dialog_for_section(section_key: String) -> void:
	_ensure_preset_directory()
	_pending_load_section = section_key
	_load_dialog.title = _load_dialog_title(section_key)
	_load_dialog.current_dir = ProjectSettings.globalize_path(_preset_directory_for_section(section_key))
	_load_dialog.current_file = _default_filename_for_section(section_key)
	_load_dialog.popup_centered_ratio(0.7)


func _preset_directory_for_section(section_key: String) -> String:
	match section_key:
		PRESET_SECTION_BADGE:
			return BADGE_PRESET_DIALOG_DIRECTORY
		PRESET_SECTION_BUTTON:
			return BUTTON_PRESET_DIALOG_DIRECTORY
		_:
			return PANEL_PRESET_DIALOG_DIRECTORY


func _default_filename_for_section(section_key: String) -> String:
	match section_key:
		PRESET_SECTION_BADGE:
			return "hybrid-badge.yaml"
		PRESET_SECTION_BUTTON:
			return "hybrid-primary-button.yaml"
		_:
			return "hybrid-panel.yaml"


func _export_dialog_title(section_key: String) -> String:
	match section_key:
		PRESET_SECTION_BADGE:
			return "Export AeroUiGlass Badge YAML"
		PRESET_SECTION_BUTTON:
			return "Export AeroUiGlass Primary Button YAML"
		_:
			return "Export Hybrid AeroUiGlass Panel YAML"


func _load_dialog_title(section_key: String) -> String:
	match section_key:
		PRESET_SECTION_BADGE:
			return "Load AeroUiGlass Badge YAML"
		PRESET_SECTION_BUTTON:
			return "Load AeroUiGlass Primary Button YAML"
		_:
			return "Load Hybrid AeroUiGlass Panel YAML"


func _on_save_dialog_file_selected(path: String) -> void:
	match _pending_save_section:
		PRESET_SECTION_BADGE:
			_export_badge_yaml_to_path(path)
		PRESET_SECTION_BUTTON:
			_export_button_yaml_to_path(path)
		_:
			_export_panel_yaml_to_path(path)


func _on_load_dialog_file_selected(path: String) -> void:
	match _pending_load_section:
		PRESET_SECTION_BADGE:
			_load_badge_yaml_from_path(path)
		PRESET_SECTION_BUTTON:
			_load_button_yaml_from_path(path)
		_:
			_load_panel_yaml_from_path(path)


func _export_panel_yaml_to_path(path: String) -> void:
	if not is_instance_valid(_panel_ui):
		_set_preset_status("Hybrid panel is not ready for YAML export.", true)
		return

	var result := YamlBundleIO.export_panel_bundle(path, _build_panel_yaml_export())
	if result.get("ok", false):
		_set_preset_status("Saved panel YAML to %s" % result["path"], false)
	else:
		_set_preset_status(str(result.get("error", "Failed to save panel YAML.")), true)


func _load_panel_yaml_from_path(path: String) -> void:
	var result := YamlBundleIO.load_panel_bundle(path)
	if not result.get("ok", false):
		_set_preset_status(str(result.get("error", "Failed to load panel YAML.")), true)
		return

	if not _apply_loaded_panel_yaml(result):
		_set_preset_status("Failed to apply panel YAML from %s" % path, true)
		return

	call_deferred("_sync_controls_from_panel")
	_set_preset_status("Loaded panel YAML from %s" % result.get("path", path), false)


func _build_panel_yaml_export() -> Dictionary:
	var panel_style_config := _panel_ui.get_panel_style_config() if is_instance_valid(_panel_ui) else null
	var badge_style_config := _panel_ui.get_badge_style_config() if is_instance_valid(_panel_ui) else null
	var button_style_config := _panel_ui.get_primary_button_style_config() if is_instance_valid(_panel_ui) else null
	var panel_shader_parameters: Dictionary = {}
	for parameter_name in ["blur", "warp_intensity", "strength_x", "strength_y", "offset_x", "offset_y", "corner_radius", "edge_smoothness", "edge_width", "chromatic_strength", "tint", "edge_highlight"]:
		panel_shader_parameters[parameter_name] = get_panel_shader_parameter(parameter_name)

	var hybrid_shader_parameters: Dictionary = {}
	for config in HYBRID_FLOAT_CONTROLS:
		var parameter_name := str(config["name"])
		if panel_shader_parameters.has(parameter_name) or parameter_name.begins_with("hybrid_"):
			continue
		hybrid_shader_parameters[parameter_name] = get_panel_shader_parameter(parameter_name)
	for config in HYBRID_COLOR_CONTROLS:
		var parameter_name := str(config["name"])
		if panel_shader_parameters.has(parameter_name) or parameter_name == "edge_color":
			continue
		hybrid_shader_parameters[parameter_name] = get_panel_shader_parameter(parameter_name)

	return {
		"panel_config": panel_style_config,
		"badge_config": badge_style_config,
		"button_config": button_style_config,
		"panel_shader_parameters": panel_shader_parameters,
		"panel_overrides": {
			"hybrid_inner_border_brightness": get_panel_shader_parameter("hybrid_inner_border_brightness"),
			"hybrid_inner_border_alpha": get_panel_shader_parameter("hybrid_inner_border_alpha"),
		},
		"badge_overrides": {
			"hybrid_fill_alpha": get_panel_shader_parameter("hybrid_badge_fill_alpha"),
			"hybrid_border_alpha": get_panel_shader_parameter("hybrid_badge_border_alpha"),
			"hybrid_label_alpha": get_panel_shader_parameter("hybrid_badge_label_alpha"),
		},
		"hybrid_shader_parameters": hybrid_shader_parameters,
	}


func _apply_loaded_panel_yaml(bundle: Dictionary) -> bool:
	var panel_config = bundle.get("panel_config", null)
	if panel_config == null:
		return false
	if not is_instance_valid(_panel_ui) or not is_instance_valid(_mask_ui):
		return false
	if _panel_ui.load_panel_style_bundle_from_path(str(bundle.get("path", ""))) == null:
		return false
	if _mask_ui.load_panel_style_bundle_from_path(str(bundle.get("path", ""))) == null:
		return false

	for parameter_name in panel_config.shader_parameters.keys():
		set_panel_shader_parameter(str(parameter_name), panel_config.shader_parameters[parameter_name])
	set_panel_shader_parameter("hybrid_inner_border_brightness", panel_config.hybrid_inner_border_brightness)
	set_panel_shader_parameter("hybrid_inner_border_alpha", panel_config.hybrid_inner_border_alpha)

	var badge_config = bundle.get("badge_config", null)
	if badge_config != null:
		set_panel_shader_parameter("hybrid_badge_fill_alpha", badge_config.hybrid_fill_alpha)
		set_panel_shader_parameter("hybrid_badge_border_alpha", badge_config.hybrid_border_alpha)
		set_panel_shader_parameter("hybrid_badge_label_alpha", badge_config.hybrid_label_alpha)

	var hybrid_shader_parameters: Dictionary = bundle.get("hybrid_shader_parameters", {}) as Dictionary
	for parameter_name in hybrid_shader_parameters.keys():
		set_panel_shader_parameter(str(parameter_name), hybrid_shader_parameters[parameter_name])
	return true


func _export_badge_yaml_to_path(path: String) -> void:
	if not is_instance_valid(_panel_ui):
		_set_preset_status("Hybrid panel is not ready for badge YAML export.", true)
		return
	var badge_config = _panel_ui.get_badge_style_config()
	if badge_config == null:
		_set_preset_status("Badge config is not ready for YAML export.", true)
		return
	var result := _write_yaml_section_document(path, YamlBundleIO._build_badge_document(badge_config, {
		"hybrid_fill_alpha": get_panel_shader_parameter("hybrid_badge_fill_alpha"),
		"hybrid_border_alpha": get_panel_shader_parameter("hybrid_badge_border_alpha"),
		"hybrid_label_alpha": get_panel_shader_parameter("hybrid_badge_label_alpha"),
	}))
	if result.get("ok", false):
		_set_preset_status("Saved badge YAML to %s" % result["path"], false)
	else:
		_set_preset_status(str(result.get("error", "Failed to save badge YAML.")), true)


func _load_badge_yaml_from_path(path: String) -> void:
	var badge_config = BadgeConfigLoader.load_from_path(path)
	if badge_config == null or badge_config.source_path == "":
		_set_preset_status("Failed to load badge YAML from %s" % path, true)
		return
	_apply_badge_config_to_host_views(badge_config)
	call_deferred("_sync_controls_from_panel")
	_set_preset_status("Loaded badge YAML from %s" % badge_config.source_path, false)


func _export_button_yaml_to_path(path: String) -> void:
	if not is_instance_valid(_panel_ui):
		_set_preset_status("Hybrid panel is not ready for button YAML export.", true)
		return
	var button_config = _panel_ui.get_primary_button_style_config()
	if button_config == null:
		_set_preset_status("Primary button config is not ready for YAML export.", true)
		return
	var result := _write_yaml_section_document(path, YamlBundleIO._build_button_document(button_config, {}))
	if result.get("ok", false):
		_set_preset_status("Saved primary button YAML to %s" % result["path"], false)
	else:
		_set_preset_status(str(result.get("error", "Failed to save primary button YAML.")), true)


func _load_button_yaml_from_path(path: String) -> void:
	var button_config = ButtonConfigLoader.load_from_path(path)
	if button_config == null or button_config.source_path == "":
		_set_preset_status("Failed to load primary button YAML from %s" % path, true)
		return
	_apply_button_config_to_host_views(button_config)
	_set_preset_status("Loaded primary button YAML from %s" % button_config.source_path, false)


func _write_yaml_section_document(path: String, document: Dictionary) -> Dictionary:
	var normalized_path := YamlBundleIO.ensure_yaml_extension(path)
	var directory_path := normalized_path.get_base_dir()
	if not directory_path.is_empty():
		var mkdir_error := DirAccess.make_dir_recursive_absolute(directory_path)
		if mkdir_error != OK:
			return {
				"ok": false,
				"error": "Failed to create YAML preset directory: %s" % directory_path,
				"code": mkdir_error,
			}
	return YamlBundleIO._write_yaml_document(normalized_path, document)


func _apply_badge_config_to_host_views(badge_config) -> void:
	for panel_view in [_panel_ui, _mask_ui]:
		if not is_instance_valid(panel_view):
			continue
		panel_view._badge_style_config = badge_config
		if panel_view._panel_style_config != null:
			panel_view._panel_style_config.badge_config = badge_config
			panel_view._panel_style_config.badge_preset_path = badge_config.source_path
		if is_instance_valid(panel_view.badge_view):
			panel_view.badge_view.set_badge_config(badge_config)
		var hybrid_badge_tokens: Dictionary = badge_config.get_tokens(true)
		panel_view._hybrid_badge_fill_alpha = float(hybrid_badge_tokens.get("fill_alpha", panel_view._hybrid_badge_fill_alpha))
		panel_view._hybrid_badge_border_alpha = float(hybrid_badge_tokens.get("border_alpha", panel_view._hybrid_badge_border_alpha))
		panel_view._hybrid_badge_label_alpha = float(hybrid_badge_tokens.get("label_alpha", panel_view._hybrid_badge_label_alpha))
		var is_hybrid_world: bool = panel_view.get_presentation_mode() == panel_view.PRESENTATION_MODE_HYBRID_WORLD_SPACE
		panel_view._refresh_badge_visual(is_hybrid_world)
		panel_view._refresh_primary_action_visual()


func _apply_button_config_to_host_views(button_config) -> void:
	for panel_view in [_panel_ui, _mask_ui]:
		if not is_instance_valid(panel_view):
			continue
		panel_view._primary_button_style_config = button_config
		if panel_view._panel_style_config != null:
			panel_view._panel_style_config.primary_button_config = button_config
			panel_view._panel_style_config.primary_button_preset_path = button_config.source_path
		panel_view._refresh_primary_action_visual()


func _get_live_control_value(parameter_name: String) -> Variant:
	match parameter_name:
		"badge_base_fill_alpha":
			return _panel_ui.get_badge_style_config().base_fill_alpha if is_instance_valid(_panel_ui) and _panel_ui.get_badge_style_config() != null else null
		"badge_base_border_alpha":
			return _panel_ui.get_badge_style_config().base_border_alpha if is_instance_valid(_panel_ui) and _panel_ui.get_badge_style_config() != null else null
		"badge_base_label_alpha":
			return _panel_ui.get_badge_style_config().base_label_alpha if is_instance_valid(_panel_ui) and _panel_ui.get_badge_style_config() != null else null
		"badge_hybrid_fill_alpha":
			return _panel_ui.get_badge_style_config().hybrid_fill_alpha if is_instance_valid(_panel_ui) and _panel_ui.get_badge_style_config() != null else null
		"badge_hybrid_border_alpha":
			return _panel_ui.get_badge_style_config().hybrid_border_alpha if is_instance_valid(_panel_ui) and _panel_ui.get_badge_style_config() != null else null
		"badge_hybrid_label_alpha":
			return _panel_ui.get_badge_style_config().hybrid_label_alpha if is_instance_valid(_panel_ui) and _panel_ui.get_badge_style_config() != null else null
		"badge_tint":
			return _panel_ui.get_badge_style_config().tint if is_instance_valid(_panel_ui) and _panel_ui.get_badge_style_config() != null else null
		"button_hybrid_label_alpha":
			return _panel_ui.get_primary_button_style_config().hybrid_label_alpha if is_instance_valid(_panel_ui) and _panel_ui.get_primary_button_style_config() != null else null
		"button_hybrid_meta_alpha":
			return _panel_ui.get_primary_button_style_config().hybrid_meta_alpha if is_instance_valid(_panel_ui) and _panel_ui.get_primary_button_style_config() != null else null
		"button_border_width":
			return float(_panel_ui.get_primary_button_style_config().border_width) if is_instance_valid(_panel_ui) and _panel_ui.get_primary_button_style_config() != null else null
		"button_radius_delta":
			return float(_panel_ui.get_primary_button_style_config().radius_delta) if is_instance_valid(_panel_ui) and _panel_ui.get_primary_button_style_config() != null else null
		"button_background_tint":
			return _panel_ui.get_primary_button_style_config().background_tint if is_instance_valid(_panel_ui) and _panel_ui.get_primary_button_style_config() != null else null
		"button_interaction_tint":
			return _panel_ui.get_primary_button_style_config().interaction_tint if is_instance_valid(_panel_ui) and _panel_ui.get_primary_button_style_config() != null else null
		"button_hybrid_hover_tint_strength":
			return _panel_ui.get_primary_button_style_config().hybrid_states.get("hover", {}).get("tint_strength", 0.0) if is_instance_valid(_panel_ui) and _panel_ui.get_primary_button_style_config() != null else null
		"button_hybrid_pressed_tint_strength":
			return _panel_ui.get_primary_button_style_config().hybrid_states.get("pressed", {}).get("tint_strength", 0.0) if is_instance_valid(_panel_ui) and _panel_ui.get_primary_button_style_config() != null else null
		"button_hybrid_hover_scale":
			return _panel_ui.get_primary_button_style_config().hybrid_states.get("hover", {}).get("scale", 1.0) if is_instance_valid(_panel_ui) and _panel_ui.get_primary_button_style_config() != null else null
		"button_hybrid_hover_speed":
			return _panel_ui.get_primary_button_style_config().hybrid_interactions.get("hover", {}).get("speed", 0.12) if is_instance_valid(_panel_ui) and _panel_ui.get_primary_button_style_config() != null else null
		"button_hybrid_hover_ease_type":
			return _panel_ui.get_primary_button_style_config().hybrid_interactions.get("hover", {}).get("ease_type", "smooth") if is_instance_valid(_panel_ui) and _panel_ui.get_primary_button_style_config() != null else null
		"button_hybrid_pressed_scale":
			return _panel_ui.get_primary_button_style_config().hybrid_states.get("pressed", {}).get("scale", 1.0) if is_instance_valid(_panel_ui) and _panel_ui.get_primary_button_style_config() != null else null
		"button_hybrid_pressed_speed":
			return _panel_ui.get_primary_button_style_config().hybrid_interactions.get("pressed", {}).get("speed", 0.08) if is_instance_valid(_panel_ui) and _panel_ui.get_primary_button_style_config() != null else null
		"button_hybrid_pressed_ease_type":
			return _panel_ui.get_primary_button_style_config().hybrid_interactions.get("pressed", {}).get("ease_type", "snappy") if is_instance_valid(_panel_ui) and _panel_ui.get_primary_button_style_config() != null else null
		_:
			return get_panel_shader_parameter(parameter_name)


func _set_live_control_value(parameter_name: String, value: Variant) -> void:
	match parameter_name:
		"badge_base_fill_alpha", "badge_base_border_alpha", "badge_base_label_alpha", "badge_hybrid_fill_alpha", "badge_hybrid_border_alpha", "badge_hybrid_label_alpha", "badge_tint":
			var badge_config = _panel_ui.get_badge_style_config() if is_instance_valid(_panel_ui) else null
			if badge_config == null:
				return
			match parameter_name:
				"badge_base_fill_alpha":
					badge_config.base_fill_alpha = float(value)
				"badge_base_border_alpha":
					badge_config.base_border_alpha = float(value)
				"badge_base_label_alpha":
					badge_config.base_label_alpha = float(value)
				"badge_hybrid_fill_alpha":
					badge_config.hybrid_fill_alpha = float(value)
				"badge_hybrid_border_alpha":
					badge_config.hybrid_border_alpha = float(value)
				"badge_hybrid_label_alpha":
					badge_config.hybrid_label_alpha = float(value)
				"badge_tint":
					badge_config.tint = value if value is Color else badge_config.tint
			_apply_badge_config_to_host_views(badge_config)
		"button_hybrid_label_alpha", "button_hybrid_meta_alpha", "button_border_width", "button_radius_delta", "button_background_tint", "button_interaction_tint", "button_hybrid_hover_tint_strength", "button_hybrid_pressed_tint_strength", "button_hybrid_hover_scale", "button_hybrid_hover_speed", "button_hybrid_hover_ease_type", "button_hybrid_pressed_scale", "button_hybrid_pressed_speed", "button_hybrid_pressed_ease_type":
			var button_config = _panel_ui.get_primary_button_style_config() if is_instance_valid(_panel_ui) else null
			if button_config == null:
				return
			match parameter_name:
				"button_hybrid_label_alpha":
					button_config.hybrid_label_alpha = float(value)
				"button_hybrid_meta_alpha":
					button_config.hybrid_meta_alpha = float(value)
				"button_border_width":
					button_config.border_width = int(round(float(value)))
				"button_radius_delta":
					button_config.radius_delta = int(round(float(value)))
				"button_background_tint":
					button_config.background_tint = value if value is Color else button_config.background_tint
				"button_interaction_tint":
					button_config.interaction_tint = value if value is Color else button_config.interaction_tint
				"button_hybrid_hover_tint_strength":
					button_config.hybrid_states["hover"]["tint_strength"] = float(value)
				"button_hybrid_pressed_tint_strength":
					button_config.hybrid_states["pressed"]["tint_strength"] = float(value)
				"button_hybrid_hover_scale":
					button_config.hybrid_states["hover"]["scale"] = float(value)
				"button_hybrid_hover_speed":
					button_config.hybrid_interactions["hover"]["speed"] = float(value)
				"button_hybrid_hover_ease_type":
					button_config.hybrid_interactions["hover"]["ease_type"] = str(value)
				"button_hybrid_pressed_scale":
					button_config.hybrid_states["pressed"]["scale"] = float(value)
				"button_hybrid_pressed_speed":
					button_config.hybrid_interactions["pressed"]["speed"] = float(value)
				"button_hybrid_pressed_ease_type":
					button_config.hybrid_interactions["pressed"]["ease_type"] = str(value)
			_apply_button_config_to_host_views(button_config)
		_:
			set_panel_shader_parameter(parameter_name, value)


func _set_preset_status(message: String, is_error: bool) -> void:
	if not is_instance_valid(_preset_status_label):
		return
	_preset_status_label.text = message
	_preset_status_label.modulate = Color(1.0, 0.72, 0.72, 0.95) if is_error else Color(1.0, 1.0, 1.0, 0.68)


func _sync_controls_from_panel() -> void:
	_select_background_mode(get_preview_background_mode())
	for config in PanelViewScript.FLOAT_CONTROLS:
		_sync_single_control_from_panel(str(config["name"]))
	for config in PanelViewScript.COLOR_CONTROLS:
		_sync_single_control_from_panel(str(config["name"]))
	for config in HYBRID_FLOAT_CONTROLS:
		_sync_single_control_from_panel(str(config["name"]))
	for config in HYBRID_COLOR_CONTROLS:
		var parameter_name := str(config["name"])
		if parameter_name == "edge_color":
			continue
		_sync_single_control_from_panel(parameter_name)
	for config in BADGE_EDITOR_BASE_CONTROLS:
		_sync_single_control_from_panel(str(config["name"]))
	for config in BADGE_EDITOR_HYBRID_CONTROLS:
		_sync_single_control_from_panel(str(config["name"]))
	for config in BADGE_EDITOR_COLOR_CONTROLS:
		_sync_single_control_from_panel(str(config["name"]))
	for config in BUTTON_EDITOR_BASE_CONTROLS:
		_sync_single_control_from_panel(str(config["name"]))
	for config in BUTTON_EDITOR_COLOR_CONTROLS:
		_sync_single_control_from_panel(str(config["name"]))
	for config in BUTTON_EDITOR_HYBRID_CONTROLS:
		_sync_single_control_from_panel(str(config["name"]))


func _sync_single_control_from_panel(parameter_name: String) -> void:
	var value: Variant = _get_live_control_value(parameter_name)
	if value == null:
		return

	if _float_sliders.has(parameter_name):
		var slider: HSlider = _float_sliders[parameter_name] as HSlider
		if slider and not is_equal_approx(slider.value, float(value)):
			slider.set_block_signals(true)
			slider.value = float(value)
			slider.set_block_signals(false)
			var value_label: Label = slider.get_meta("value_label") as Label
			if value_label:
				value_label.text = _format_float(slider.value)
		return

	if _option_selectors.has(parameter_name):
		var selector: OptionButton = _option_selectors[parameter_name] as OptionButton
		if selector:
			for index in range(selector.item_count):
				if str(selector.get_item_metadata(index)) == str(value):
					selector.set_block_signals(true)
					selector.select(index)
					selector.set_block_signals(false)
					break
		return

	if _color_pickers.has(parameter_name):
		var picker: ColorPickerButton = _color_pickers[parameter_name] as ColorPickerButton
		if picker and picker.color != value:
			picker.set_block_signals(true)
			picker.color = value
			picker.set_block_signals(false)


func _select_background_mode(mode: int) -> void:
	if not is_instance_valid(_background_mode_selector):
		return
	for index in range(_background_mode_selector.item_count):
		if _background_mode_selector.get_item_id(index) == mode:
			_background_mode_selector.select(index)
			return


func _sync_authored_card_rect() -> void:
	if _panel_material == null:
		return
	_authored_glass_rect = _get_authored_glass_rect()
	_refresh_spatial_surface_descriptor()
	var glass_rect := Vector4(_authored_glass_rect.position.x, _authored_glass_rect.position.y, _authored_glass_rect.size.x, _authored_glass_rect.size.y)
	_panel_material.set_shader_parameter("glass_rect", glass_rect)
	if _panel_ui_overlay_material != null:
		_panel_ui_overlay_material.set_shader_parameter("glass_rect", glass_rect)
	_sync_panel_surface_aspect()


func _get_authored_glass_rect() -> Rect2:
	var source := _mask_ui if is_instance_valid(_mask_ui) else _panel_ui
	if not is_instance_valid(source):
		return Rect2(0.0, 0.0, 1.0, 1.0)
	return source.get_preview_rect_normalized()


func _panel_uv_to_authored_uv(panel_uv: Vector2) -> Vector2:
	var rect := _authored_glass_rect
	return rect.position + panel_uv * rect.size


func _sync_panel_surface_aspect() -> void:
	var authored_aspect := _get_authored_surface_aspect()
	if authored_aspect <= 0.0:
		return
	var surface_width := _get_panel_surface_size().x
	if surface_width <= 0.0:
		return
	var surface_height := surface_width / authored_aspect
	_sync_quad_mesh_size(panel_display, Vector2(surface_width, surface_height))
	_sync_quad_mesh_size(panel_ui_overlay, Vector2(surface_width, surface_height))
	_sync_panel_input_shape(Vector2(surface_width, surface_height))


func _get_authored_surface_aspect() -> float:
	var rect := _get_authored_glass_rect()
	if rect.size.x <= 0.0 or rect.size.y <= 0.0:
		return 0.0
	var viewport_size := Vector2(panel_viewport.size) if panel_viewport != null else Vector2.ZERO
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return 0.0
	var authored_size_px := Vector2(rect.size.x * viewport_size.x, rect.size.y * viewport_size.y)
	if authored_size_px.y <= 0.0:
		return 0.0
	return authored_size_px.x / authored_size_px.y


func _sync_quad_mesh_size(instance: MeshInstance3D, size: Vector2) -> void:
	if instance == null or not (instance.mesh is QuadMesh):
		return
	var mesh := instance.mesh as QuadMesh
	mesh.size = size


func _sync_panel_input_shape(size: Vector2) -> void:
	if panel_input_surface == null:
		return
	var collision_shape := panel_input_surface.get_node_or_null("CollisionShape3D") as CollisionShape3D
	if collision_shape == null or not (collision_shape.shape is BoxShape3D):
		return
	var shape := collision_shape.shape as BoxShape3D
	shape.size = Vector3(size.x, size.y, shape.size.z)

func _apply_panel_rotation() -> void:
	if panel_pivot == null:
		return

	var pitch := _manual_pitch_deg
	var yaw := _manual_yaw_deg
	if auto_rotate:
		var phase := Time.get_ticks_msec() / 1000.0 * deg_to_rad(auto_rotate_speed_deg)
		pitch += sin(phase * 0.65 + 0.75) * AUTO_PITCH_AMPLITUDE_DEG
		yaw += sin(phase) * AUTO_YAW_AMPLITUDE_DEG

	panel_pivot.rotation_degrees = _base_rotation + Vector3(pitch, yaw, 0.0)


func _axis_strength(negative_primary: Key, positive_primary: Key, negative_secondary: Key, positive_secondary: Key) -> float:
	var positive := Input.is_key_pressed(positive_primary) or Input.is_key_pressed(positive_secondary)
	var negative := Input.is_key_pressed(negative_primary) or Input.is_key_pressed(negative_secondary)
	return float(positive) - float(negative)


func describe_mouse_verification_snapshot() -> Dictionary:
	var mouse_state := _current_mouse_runtime_state()
	return {
		"provider_lane": "mouse",
		"packaged_provider_active": _spatial_mouse_provider != null,
		"provider_runtime_source": _mouse_provider_runtime_seam,
		"provider_runtime_path": SPATIAL_UI_MOUSE_PROVIDER_SCRIPT_PATH,
		"source_variant": _last_contract_source_variant,
		"phase": _last_contract_phase,
		"target_path": _last_contract_target_path,
		"verification_status": _last_contract_verification_status,
		"verification_notes": _last_contract_verification_notes,
		"hover_target_path": str(mouse_state.get("hover_target_path", NodePath())),
		"capture_target_path": str(mouse_state.get("capture_target_path", NodePath())),
		"left_button_down": bool(mouse_state.get("left_button_down", false)),
		"last_live_target_path": str(mouse_state.get("last_live_target_path", NodePath())),
		"last_release_target_path": str(mouse_state.get("last_release_target_path", "")),
		"last_forwarded_panel_event": str(mouse_state.get("last_forwarded_panel_event", _last_forwarded_panel_event)),
	}


func _refresh_status() -> void:
	if _contract_status_label == null or panel_pivot == null:
		return

	var interaction_target := _current_interaction_target_label()
	var state_label := _current_interaction_state_label()
	var verification_snapshot := describe_mouse_verification_snapshot()
	var lines := [
		"[b]Hybrid input verification HUD[/b]",
		"[color=#cbd5e1]Interacting with:[/color] %s" % interaction_target,
		"[color=#cbd5e1]Current state:[/color] %s" % state_label,
		"[color=#cbd5e1]Provider lane:[/color] %s" % verification_snapshot.get("provider_lane", "mouse"),
		"[color=#cbd5e1]Packaged provider active:[/color] %s" % str(verification_snapshot.get("packaged_provider_active", false)),
		"[color=#cbd5e1]Provider seam:[/color] %s" % verification_snapshot.get("provider_runtime_source", "missing"),
		"[color=#cbd5e1]Source variant:[/color] %s" % verification_snapshot.get("source_variant", "waiting"),
		"[color=#cbd5e1]Phase:[/color] %s" % verification_snapshot.get("phase", "waiting"),
		"[color=#cbd5e1]Target path:[/color] %s" % _path_label(verification_snapshot.get("target_path", "")),
		"[color=#cbd5e1]Verification status:[/color] %s" % verification_snapshot.get("verification_status", "waiting"),
		"[color=#cbd5e1]Verification notes:[/color] %s" % verification_snapshot.get("verification_notes", "No normalized interaction published yet."),
		"",
		"[b]Mouse provider runtime snapshot[/b]",
		"hover_target_path = %s" % _path_label(verification_snapshot.get("hover_target_path", "")),
		"capture_target_path = %s" % _path_label(verification_snapshot.get("capture_target_path", "")),
		"left_button_down = %s" % str(verification_snapshot.get("left_button_down", false)),
		"last_live_target_path = %s" % _path_label(verification_snapshot.get("last_live_target_path", "")),
		"last_release_target_path = %s" % _path_label(verification_snapshot.get("last_release_target_path", "")),
		"last_forwarded_panel_event = %s" % verification_snapshot.get("last_forwarded_panel_event", "waiting for normalized panel input"),
	]
	_contract_status_label.text = "\n".join(lines)


func _current_interaction_target_label() -> String:
	var touch_summary := _current_touch_interaction_summary()
	var preferred_touch_target_path: NodePath = touch_summary.get("preferred_target_path", NodePath())
	if preferred_touch_target_path != NodePath():
		return str(touch_summary.get("preferred_target_label", _path_label(preferred_touch_target_path)))
	var mouse_state := _current_mouse_runtime_state()
	var capture_target_path: NodePath = mouse_state.get("capture_target_path", NodePath())
	var hover_target_path: NodePath = mouse_state.get("hover_target_path", NodePath())
	var live_target_path: NodePath = mouse_state.get("last_live_target_path", NodePath())
	if capture_target_path != NodePath():
		return _path_label(capture_target_path)
	if hover_target_path != NodePath():
		return _path_label(hover_target_path)
	if live_target_path != NodePath():
		return _path_label(live_target_path)
	if _last_contract_target_path != "":
		return _path_label(NodePath(_last_contract_target_path))
	return "none"


func _current_interaction_state_label() -> String:
	var touch_summary := _current_touch_interaction_summary()
	if bool(touch_summary.get("is_touch_active", false)):
		return "touch %s" % _phase_label(str(touch_summary.get("state_phase", _last_contract_phase)))
	var mouse_state := _current_mouse_runtime_state()
	if bool(mouse_state.get("left_button_down", false)) or bool(mouse_state.get("capture_active", false)):
		return "mouse %s" % _phase_label(_last_contract_phase)
	if bool(mouse_state.get("hover_active", false)):
		return "mouse hover"
	if _last_contract_phase != "waiting" and _last_contract_phase != "":
		return _phase_label(_last_contract_phase)
	return "idle"


func _phase_label(phase: String) -> String:
	match StringName(phase):
		AeroUiInteractionTypes.PHASE_PRESS_BEGIN:
			return "press"
		AeroUiInteractionTypes.PHASE_PRESS_HOLD:
			return "holding"
		AeroUiInteractionTypes.PHASE_DRAG_BEGIN:
			return "drag start"
		AeroUiInteractionTypes.PHASE_DRAG_MOVE:
			return "dragging"
		AeroUiInteractionTypes.PHASE_DRAG_END:
			return "drag end"
		AeroUiInteractionTypes.PHASE_PRESS_END:
			return "release"
		AeroUiInteractionTypes.PHASE_HOVER_ENTER, AeroUiInteractionTypes.PHASE_HOVER_MOVE:
			return "hover"
		AeroUiInteractionTypes.PHASE_HOVER_EXIT:
			return "hover exit"
		AeroUiInteractionTypes.PHASE_CANCEL:
			return "cancel"
		_:
			return phase if phase != "waiting" and phase != "" else "idle"


func _background_mode_name(mode: int) -> String:
	match mode:
		PanelViewScript.BACKGROUND_MODE_IMAGE:
			return "AeroBeat image"
		PanelViewScript.BACKGROUND_MODE_DEBUG:
			return "Debug pattern"
		PanelViewScript.BACKGROUND_MODE_HYBRID:
			return "Hybrid overlay"
		PanelViewScript.BACKGROUND_MODE_NONE:
			return "No background"
		_:
			return "Unknown"


func _resolve_parameter_alias(parameter_name: String, value: Variant) -> Dictionary:
	var alias: Variant = PARAMETER_ALIASES.get(parameter_name, null)
	if alias is Dictionary:
		var resolved_value: Variant = value
		if alias.has("scale") and value is float:
			resolved_value = float(value) * float(alias["scale"])
		return {
			"name": str(alias["target"]),
			"value": resolved_value,
		}

	return {
		"name": parameter_name,
		"value": value,
	}


func _join_string_array(values: Array) -> String:
	var parts: PackedStringArray = []
	for value in values:
		parts.append(str(value))
	return ", ".join(parts)


func _format_float(value: float) -> String:
	return "%0.3f" % value if absf(value) < 1.0 else "%0.2f" % value
