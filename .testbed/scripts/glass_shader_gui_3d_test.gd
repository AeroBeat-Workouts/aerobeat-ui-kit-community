extends Node3D

const SOURCE_2D_SCENE_PATH := "res://scenes/glass-shader-panel-source.tscn"
const HYBRID_SHADER_PATH := "res://assets/shaders/glass-panel-hybrid-3d.gdshader"
const UI_OVERLAY_SHADER_PATH := "res://assets/shaders/glass-panel-ui-overlay-3d.gdshader"
const PRESET_SOURCE_SCENE_PATH := "res://scenes/glass-shader-gui-3d-test.tscn"
const PRESET_DIALOG_DIRECTORY := "res://presets/glass/hybrid"
const DEFAULT_PRESET_FILENAME := "glass-shader-hybrid-3d-preset.json"
const BUNDLED_DEFAULT_PRESET_PATH := "res://presets/glass/hybrid/default.json"
const HYBRID_SURFACE_ID: StringName = &"hybrid_glass_panel"
const HYBRID_SURFACE_TYPE: StringName = AeroUiInteractionTypes.SURFACE_TYPE_HYBRID_3D_GUI
const HYBRID_POINTER_MOUSE: StringName = &"mouse_0"
const PanelSourceScript = preload("res://scripts/glass_shader_panel_source.gd")
const PresetIO = preload("res://scripts/glass_shader_preset_io.gd")

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

const PARAMETER_ALIASES := {
	"edge_highlight": {"target": "edge_color"},
	"edge_smoothness": {"target": "edge_softness", "scale": 0.01},
	"edge_width": {"target": "edge_width", "scale": 0.0075},
}

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
@onready var status_label: RichTextLabel = get_node_or_null("CanvasLayer/OverlayRoot/SplitRoot/ControlsPanel/Margin/ControlsColumn/StatusPanel/StatusPadding/StatusLabel") as RichTextLabel
@onready var interaction_bus: AeroUiInteractionBus = get_node_or_null("AeroUiInteractionBus") as AeroUiInteractionBus
@onready var hybrid_input_adapter: HybridSubViewportInputAdapter = get_node_or_null("HybridInputAdapter") as HybridSubViewportInputAdapter

var _panel_ui: Control
var _mask_ui: Control
var _panel_material: ShaderMaterial
var _panel_ui_overlay_material: ShaderMaterial
var _manual_pitch_deg := 0.0
var _manual_yaw_deg := 0.0
var _base_rotation := Vector3.ZERO
var _background_mode_selector: OptionButton
var _float_sliders: Dictionary = {}
var _color_pickers: Dictionary = {}
var _preset_status_label: Label
var _save_dialog: FileDialog
var _load_dialog: FileDialog
var _mouse_panel_capture := false
var _mouse_left_button_down := false
var _mouse_hover_active := false
var _mouse_hover_target_path: NodePath = NodePath()
var _mouse_owner_target_path: NodePath = NodePath()
var _last_mouse_projected_data: Dictionary = {}
var _active_touch_state: Dictionary = {}
var _last_surface_hover_hit := false
var _last_live_target_path: NodePath = NodePath()
var _last_release_target_path := ""
var _last_forwarded_panel_event := "waiting for normalized panel input"
var _last_contract_phase := "waiting"
var _last_contract_source_variant := "waiting"
var _last_contract_surface_id := String(HYBRID_SURFACE_ID)
var _last_contract_verification_status := "waiting"
var _last_contract_verification_notes := "No normalized interaction published yet."
var _last_contract_target_path := ""


func _ready() -> void:
	if camera_3d == null or panel_pivot == null or panel_viewport == null or mask_viewport == null or panel_display == null or panel_ui_overlay == null or panel_input_surface == null:
		push_error("3D GUI glass test scene is missing one or more required nodes.")
		return

	_base_rotation = panel_pivot.rotation_degrees
	_configure_subviewport(panel_viewport)
	_configure_subviewport(mask_viewport)
	_mount_source_2d_scenes()
	_configure_panel_sources_for_hybrid()
	_ensure_interaction_contract_nodes()
	_inject_panel_source_interaction_bus()
	_apply_panel_materials()
	_build_controls()
	_setup_preset_dialogs()
	_load_startup_default_preset()
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
				set_preview_background_mode(PanelSourceScript.BACKGROUND_MODE_IMAGE)
			KEY_2:
				set_preview_background_mode(PanelSourceScript.BACKGROUND_MODE_DEBUG)
			KEY_3:
				set_preview_background_mode(PanelSourceScript.BACKGROUND_MODE_HYBRID)
			KEY_4:
				set_preview_background_mode(PanelSourceScript.BACKGROUND_MODE_NONE)
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


func _inject_panel_source_interaction_bus() -> void:
	if not is_instance_valid(interaction_bus):
		return
	var bus_path := interaction_bus.get_path()
	for source in [_panel_ui, _mask_ui]:
		if is_instance_valid(source) and source.has_method("set_interaction_bus_path"):
			source.call("set_interaction_bus_path", bus_path)


func _forward_world_panel_input(event: InputEvent) -> bool:
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
	var hit := _screen_position_to_panel_hit(event.position)
	var has_hit: bool = bool(hit.get("hit", false))
	var live_target_path: NodePath = _resolve_projected_target_path(hit.get("viewport_position", Vector2.ZERO)) if has_hit else NodePath()
	_last_surface_hover_hit = has_hit
	_last_live_target_path = live_target_path

	if event.pressed and not has_hit:
		return false
	if not event.pressed and not has_hit and not _mouse_panel_capture:
		return false
	if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed and not _mouse_left_button_down:
		_last_forwarded_panel_event = "ignore duplicate mouse release"
		return has_hit

	_update_mouse_hover_target(event.position, hit, live_target_path)

	var published_target_path := live_target_path
	if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_mouse_left_button_down = true
		_mouse_owner_target_path = live_target_path
		_mouse_panel_capture = _mouse_owner_target_path != NodePath()
		published_target_path = _mouse_owner_target_path
	elif _mouse_panel_capture and _mouse_owner_target_path != NodePath():
		published_target_path = _mouse_owner_target_path

	if not event.pressed and event.button_index == MOUSE_BUTTON_LEFT and not _mouse_panel_capture and published_target_path == NodePath():
		_last_forwarded_panel_event = "surface release with no owner"
		return has_hit

	var projected_data := _build_projected_data(event.position, hit, _last_mouse_projected_data, published_target_path, live_target_path)
	hybrid_input_adapter.publish_from_input_event(event, projected_data, {"pointer_id": HYBRID_POINTER_MOUSE})
	_last_mouse_projected_data = projected_data
	if not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_mouse_left_button_down = false
		_last_release_target_path = str(projected_data.get("target_path", NodePath()))
		_mouse_panel_capture = false
		_mouse_owner_target_path = NodePath()
		if not has_hit:
			_update_mouse_hover_target(event.position, {}, NodePath())
	_last_forwarded_panel_event = "publish mouse %s -> %.0f, %.0f • %s" % [
		"press" if event.pressed else "release",
		projected_data["surface_position"].x,
		projected_data["surface_position"].y,
		_path_label(projected_data.get("target_path", NodePath()))
	]
	return true


func _publish_mouse_motion_to_contract(event: InputEventMouseMotion) -> bool:
	var hit := _screen_position_to_panel_hit(event.position)
	var has_hit: bool = bool(hit.get("hit", false))
	var live_target_path: NodePath = _resolve_projected_target_path(hit.get("viewport_position", Vector2.ZERO)) if has_hit else NodePath()
	_last_surface_hover_hit = has_hit
	_last_live_target_path = live_target_path

	if _mouse_left_button_down and (event.button_mask & MOUSE_BUTTON_MASK_LEFT) == 0:
		_publish_mouse_release_from_motion(event, hit, live_target_path)
		hit = _screen_position_to_panel_hit(event.position)
		has_hit = bool(hit.get("hit", false))
		live_target_path = _resolve_projected_target_path(hit.get("viewport_position", Vector2.ZERO)) if has_hit else NodePath()
		_last_surface_hover_hit = has_hit
		_last_live_target_path = live_target_path

	if not has_hit and not _mouse_panel_capture and _mouse_hover_target_path == NodePath():
		return false

	_update_mouse_hover_target(event.position, hit, live_target_path)

	if not _mouse_panel_capture and live_target_path == NodePath():
		_last_forwarded_panel_event = "surface motion -> no interactive target"
		return has_hit or _mouse_hover_active

	var published_target_path := _mouse_owner_target_path if _mouse_panel_capture and _mouse_owner_target_path != NodePath() else live_target_path
	var projected_data := _build_projected_data(event.position, hit, _last_mouse_projected_data, published_target_path, live_target_path)
	hybrid_input_adapter.publish_from_input_event(event, projected_data, {"pointer_id": HYBRID_POINTER_MOUSE})
	_last_mouse_projected_data = projected_data
	_last_forwarded_panel_event = "publish mouse motion -> %.0f, %.0f • hover %s • owner %s%s" % [
		projected_data["surface_position"].x,
		projected_data["surface_position"].y,
		_path_label(live_target_path),
		_path_label(_mouse_owner_target_path),
		" (captured)" if _mouse_panel_capture else ""
	]
	return true


func _publish_mouse_release_from_motion(event: InputEventMouseMotion, hit: Dictionary, live_target_path: NodePath) -> void:
	var synthetic_release := InputEventMouseButton.new()
	synthetic_release.button_index = MOUSE_BUTTON_LEFT
	synthetic_release.pressed = false
	synthetic_release.position = event.position
	synthetic_release.button_mask = event.button_mask
	_publish_mouse_button_to_contract(synthetic_release)
	_last_forwarded_panel_event = "publish mouse release (motion button mask drop) -> %.0f, %.0f • hover %s • owner %s" % [
		Vector2(hit.get("viewport_position", _last_mouse_projected_data.get("surface_position", Vector2.ZERO))).x,
		Vector2(hit.get("viewport_position", _last_mouse_projected_data.get("surface_position", Vector2.ZERO))).y,
		_path_label(live_target_path),
		_path_label(_mouse_owner_target_path)
	]


func _publish_screen_touch_to_contract(event: InputEventScreenTouch) -> bool:
	var pointer_id := StringName("touch_%s" % event.index)
	var previous_state: Dictionary = _active_touch_state.get(pointer_id, {})
	var previous_projected: Dictionary = previous_state.get("projected_data", {})
	var previous_owner: NodePath = previous_state.get("owner_target_path", NodePath())
	if event.canceled:
		if previous_projected.is_empty():
			return false
		_publish_projected_phase(AeroUiInteractionTypes.PHASE_CANCEL, pointer_id, previous_projected, {
			"source_type": AeroUiInteractionTypes.SOURCE_TYPE_TOUCH,
			"source_variant": AeroUiInteractionTypes.SOURCE_VARIANT_SCREEN_TOUCH,
			"button": AeroUiInteractionTypes.BUTTON_CONTACT,
			"primary": event.index == 0,
			"pressed": false,
			"raw_event_class": &"InputEventScreenTouch",
			"raw_metadata": {"index": event.index, "canceled": true}
		})
		_active_touch_state.erase(pointer_id)
		_last_forwarded_panel_event = "publish touch cancel #%d" % event.index
		return true

	var hit := _screen_position_to_panel_hit(event.position)
	var has_hit: bool = bool(hit.get("hit", false))
	var live_target_path: NodePath = _resolve_projected_target_path(hit.get("viewport_position", Vector2.ZERO)) if has_hit else NodePath()
	if event.pressed and (not has_hit or live_target_path == NodePath()):
		return false
	if not event.pressed and not has_hit and previous_projected.is_empty():
		return false

	var owner_target_path := previous_owner
	if event.pressed:
		owner_target_path = live_target_path
	var published_target_path := owner_target_path if owner_target_path != NodePath() else live_target_path
	var projected_data := _build_projected_data(event.position, hit, previous_projected, published_target_path, live_target_path)
	hybrid_input_adapter.publish_from_input_event(event, projected_data, {"pointer_id": pointer_id})
	if event.pressed:
		_active_touch_state[pointer_id] = {
			"projected_data": projected_data,
			"owner_target_path": owner_target_path,
		}
	else:
		_last_release_target_path = str(projected_data.get("target_path", NodePath()))
		_active_touch_state.erase(pointer_id)
	_last_forwarded_panel_event = "publish touch %s #%d -> %.0f, %.0f • %s" % [
		"press" if event.pressed else "release",
		event.index,
		projected_data["surface_position"].x,
		projected_data["surface_position"].y,
		_path_label(projected_data.get("target_path", NodePath()))
	]
	return true


func _publish_screen_drag_to_contract(event: InputEventScreenDrag) -> bool:
	var pointer_id := StringName("touch_%s" % event.index)
	var previous_state: Dictionary = _active_touch_state.get(pointer_id, {})
	if previous_state.is_empty():
		return false

	var previous_projected: Dictionary = previous_state.get("projected_data", {})
	var owner_target_path: NodePath = previous_state.get("owner_target_path", NodePath())
	var hit := _screen_position_to_panel_hit(event.position)
	var has_hit: bool = bool(hit.get("hit", false))
	var live_target_path: NodePath = _resolve_projected_target_path(hit.get("viewport_position", Vector2.ZERO)) if has_hit else NodePath()
	var projected_data := _build_projected_data(event.position, hit, previous_projected, owner_target_path, live_target_path)
	hybrid_input_adapter.publish_from_input_event(event, projected_data, {"pointer_id": pointer_id})
	_active_touch_state[pointer_id] = {
		"projected_data": projected_data,
		"owner_target_path": owner_target_path,
	}
	_last_forwarded_panel_event = "publish touch drag #%d -> %.0f, %.0f • owner %s • hover %s" % [
		event.index,
		projected_data["surface_position"].x,
		projected_data["surface_position"].y,
		_path_label(owner_target_path),
		_path_label(live_target_path)
	]
	return true


func _update_mouse_hover_target(screen_position: Vector2, hit: Dictionary, new_target_path: NodePath) -> void:
	if _mouse_hover_target_path == new_target_path:
		_mouse_hover_active = new_target_path != NodePath()
		return

	var previous_target_path := _mouse_hover_target_path
	if previous_target_path != NodePath():
		_publish_hover_phase(
			AeroUiInteractionTypes.PHASE_HOVER_EXIT,
			HYBRID_POINTER_MOUSE,
			screen_position,
			hit,
			_last_mouse_projected_data,
			previous_target_path,
			new_target_path
		)
	if new_target_path != NodePath():
		_publish_hover_phase(
			AeroUiInteractionTypes.PHASE_HOVER_ENTER,
			HYBRID_POINTER_MOUSE,
			screen_position,
			hit,
			_last_mouse_projected_data,
			new_target_path,
			new_target_path
		)
	_mouse_hover_target_path = new_target_path
	_mouse_hover_active = new_target_path != NodePath()


func _publish_hover_phase(
	phase: StringName,
	pointer_id: StringName,
	screen_position: Vector2,
	hit: Dictionary,
	previous_projected: Dictionary,
	target_path: NodePath,
	live_target_path: NodePath
) -> void:
	var projected_data := _build_projected_data(screen_position, hit, previous_projected, target_path, live_target_path)
	_publish_projected_phase(phase, pointer_id, projected_data, {
		"source_type": AeroUiInteractionTypes.SOURCE_TYPE_MOUSE,
		"source_variant": AeroUiInteractionTypes.SOURCE_VARIANT_SCREEN_MOUSE,
		"button": AeroUiInteractionTypes.BUTTON_PRIMARY,
		"primary": true,
		"pressed": false,
		"raw_event_class": &"HybridHoverProjection",
		"raw_metadata": {
			"host_phase": str(phase),
			"hover_continuity": "world_ray_projection",
			"live_target_path": str(live_target_path),
			"published_target_path": str(target_path),
		}
	})


func _publish_projected_phase(
	phase: StringName,
	pointer_id: StringName,
	projected_data: Dictionary,
	overrides: Dictionary
) -> AeroUiInteractionEvent:
	return hybrid_input_adapter.publish_projected_phase(phase, pointer_id, projected_data, overrides)


func _screen_position_to_panel_hit(screen_position: Vector2) -> Dictionary:
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
	if panel_size.x <= 0.0 or panel_size.y <= 0.0:
		return {"hit": false, "screen_position": screen_position, "world_direction": ray_direction}

	var uv := Vector2(
		(local_hit.x / panel_size.x) + 0.5,
		0.5 - (local_hit.y / panel_size.y)
	)
	if uv.x < 0.0 or uv.x > 1.0 or uv.y < 0.0 or uv.y > 1.0:
		return {"hit": false, "screen_position": screen_position, "world_direction": ray_direction}

	return {
		"hit": true,
		"screen_position": screen_position,
		"viewport_position": Vector2(uv.x * panel_viewport.size.x, uv.y * panel_viewport.size.y),
		"uv": uv,
		"local_hit": local_hit,
		"world_position": hit["position"],
		"world_normal": hit.get("normal", Vector3.ZERO),
		"world_direction": ray_direction,
		"surface_size": panel_size,
	}


func _build_projected_data(
	screen_position: Vector2,
	hit: Dictionary,
	previous_projected: Dictionary = {},
	explicit_target_path: NodePath = NodePath(),
	live_target_path: NodePath = NodePath()
) -> Dictionary:
	var projected_data: Dictionary = previous_projected.duplicate(true)
	var has_hit: bool = bool(hit.get("hit", false))
	var target_path := explicit_target_path
	if target_path == NodePath() and has_hit:
		target_path = _resolve_projected_target_path(hit.get("viewport_position", Vector2.ZERO))
	if target_path != NodePath():
		projected_data["target_path"] = target_path

	projected_data["screen_position"] = screen_position
	if has_hit:
		projected_data["surface_normalized_position"] = hit.get("uv", Vector2.ZERO)
		projected_data["surface_position"] = hit.get("viewport_position", Vector2.ZERO)
		projected_data["world_position"] = hit.get("world_position", Vector3.ZERO)
		projected_data["world_normal"] = hit.get("world_normal", Vector3.ZERO)
		projected_data["world_direction"] = hit.get("world_direction", Vector3.ZERO)
		projected_data["raw_metadata"] = {
			"host_surface": "PanelInputSurface",
			"uv": hit.get("uv", Vector2.ZERO),
			"local_hit": hit.get("local_hit", Vector3.ZERO),
			"surface_size": hit.get("surface_size", _get_panel_surface_size()),
			"target_resolution": "multi_target_panel_rect_lookup",
			"live_target_path": str(live_target_path),
			"published_target_path": str(target_path),
			"hover_target_path": str(_mouse_hover_target_path),
			"owner_target_path": str(_mouse_owner_target_path),
		}
	else:
		if not projected_data.has("surface_normalized_position"):
			projected_data["surface_normalized_position"] = Vector2.ZERO
		if not projected_data.has("surface_position"):
			projected_data["surface_position"] = Vector2.ZERO
		if not projected_data.has("world_position"):
			projected_data["world_position"] = Vector3.ZERO
		if not projected_data.has("world_normal"):
			projected_data["world_normal"] = Vector3.ZERO
		projected_data["world_direction"] = hit.get("world_direction", projected_data.get("world_direction", Vector3.ZERO))
		var raw_metadata: Dictionary = projected_data.get("raw_metadata", {}).duplicate(true)
		raw_metadata["off_surface_continuation"] = true
		raw_metadata["target_resolution"] = "multi_target_panel_rect_lookup"
		raw_metadata["live_target_path"] = str(live_target_path)
		raw_metadata["published_target_path"] = str(target_path)
		projected_data["raw_metadata"] = raw_metadata
	return projected_data


func _resolve_projected_target_path(surface_position: Vector2) -> NodePath:
	if not is_instance_valid(_panel_ui) or not _panel_ui.has_method("get_interaction_target_specs"):
		return NodePath()
	for spec_variant in _panel_ui.call("get_interaction_target_specs"):
		if not (spec_variant is Dictionary):
			continue
		var spec: Dictionary = spec_variant
		var rect: Rect2 = spec.get("rect", Rect2())
		if rect.has_point(surface_position):
			return spec.get("target_path", NodePath())
	return NodePath()


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
	return Vector2(2.93, 1.8)


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
	if is_instance_valid(_panel_ui) and _panel_ui.has_method("set_background_mode"):
		_panel_ui.call("set_background_mode", mode)
	if is_instance_valid(_background_mode_selector):
		_select_background_mode(get_preview_background_mode())
	_refresh_status()


func get_preview_background_mode() -> int:
	if is_instance_valid(_panel_ui) and _panel_ui.has_method("get_background_mode"):
		return _panel_ui.call("get_background_mode")
	return PanelSourceScript.BACKGROUND_MODE_NONE


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
		if is_instance_valid(source) and source.has_method("sync_hybrid_shell"):
			source.call("sync_hybrid_shell", shell_updates)


func _get_hybrid_shell_parameter(parameter_name: String) -> Variant:
	if is_instance_valid(_panel_ui) and _panel_ui.has_method("get_hybrid_shell_parameter"):
		return _panel_ui.call("get_hybrid_shell_parameter", parameter_name)
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


func _mount_source_2d_scenes() -> void:
	_panel_ui = _instantiate_source_scene(panel_viewport)
	_mask_ui = _instantiate_source_scene(mask_viewport)


func _instantiate_source_scene(target_viewport: SubViewport) -> Control:
	for child in target_viewport.get_children():
		child.queue_free()

	var packed: PackedScene = load(SOURCE_2D_SCENE_PATH)
	if packed == null:
		push_error("Failed to load source 2D glass shader scene: %s" % SOURCE_2D_SCENE_PATH)
		return null

	var instance := packed.instantiate() as Control
	if instance == null:
		push_error("Source 2D glass shader scene did not instantiate as a Control root.")
		return null

	target_viewport.add_child(instance)
	instance.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return instance


func _configure_panel_sources_for_hybrid() -> void:
	if is_instance_valid(_panel_ui):
		if _panel_ui.has_method("set_presentation_mode"):
			_panel_ui.call("set_presentation_mode", PanelSourceScript.PRESENTATION_MODE_HYBRID_WORLD_SPACE)
		if _panel_ui.has_method("set_background_mode"):
			_panel_ui.call("set_background_mode", PanelSourceScript.BACKGROUND_MODE_NONE)

	if is_instance_valid(_mask_ui):
		if _mask_ui.has_method("set_presentation_mode"):
			_mask_ui.call("set_presentation_mode", PanelSourceScript.PRESENTATION_MODE_HYBRID_MASK)
		if _mask_ui.has_method("set_background_mode"):
			_mask_ui.call("set_background_mode", PanelSourceScript.BACKGROUND_MODE_NONE)


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

	_float_sliders.clear()
	_color_pickers.clear()
	_background_mode_selector = null
	_preset_status_label = null

	controls_list.add_child(_make_background_mode_control())
	controls_list.add_child(_make_preset_actions_block())

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0.0, 8.0)
	controls_list.add_child(spacer)

	for config in HYBRID_FLOAT_CONTROLS:
		controls_list.add_child(_make_float_control(config))

	for config in HYBRID_COLOR_CONTROLS:
		controls_list.add_child(_make_color_control(config))

	var tail_spacer := Control.new()
	tail_spacer.custom_minimum_size = Vector2(0.0, 8.0)
	controls_list.add_child(tail_spacer)


func _make_background_mode_control() -> Control:
	var wrapper := VBoxContainer.new()
	wrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var label := Label.new()
	label.text = "source_preview_background"
	wrapper.add_child(label)

	var selector := OptionButton.new()
	selector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	selector.add_item("AeroBeat image", PanelSourceScript.BACKGROUND_MODE_IMAGE)
	selector.add_item("Debug pattern", PanelSourceScript.BACKGROUND_MODE_DEBUG)
	selector.add_item("Hybrid overlay", PanelSourceScript.BACKGROUND_MODE_HYBRID)
	selector.add_item("No background", PanelSourceScript.BACKGROUND_MODE_NONE)
	selector.item_selected.connect(_on_background_mode_selected.bind(selector))
	wrapper.add_child(selector)
	_background_mode_selector = selector
	return wrapper


func _make_preset_actions_block() -> Control:
	var wrapper := VBoxContainer.new()
	wrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wrapper.add_theme_constant_override("separation", 8)

	var title := Label.new()
	title.text = "preset_json"
	wrapper.add_child(title)

	var description := Label.new()
	description.text = "Save the current hybrid body and overlay controls to JSON or load them back into this world-space shader test scene."
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.modulate = Color(1.0, 1.0, 1.0, 0.68)
	wrapper.add_child(description)

	var button_row := HBoxContainer.new()
	button_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button_row.add_theme_constant_override("separation", 8)
	wrapper.add_child(button_row)

	var export_button := Button.new()
	export_button.text = "Export JSON"
	export_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	export_button.pressed.connect(_on_export_json_pressed)
	button_row.add_child(export_button)

	var load_button := Button.new()
	load_button.text = "Load JSON"
	load_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	load_button.pressed.connect(_on_load_json_pressed)
	button_row.add_child(load_button)

	var status := Label.new()
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status.modulate = Color(1.0, 1.0, 1.0, 0.6)
	status.text = "No preset loaded yet."
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


func _setup_preset_dialogs() -> void:
	_ensure_preset_directory()
	if _save_dialog == null:
		_save_dialog = _create_preset_dialog(FileDialog.FILE_MODE_SAVE_FILE, "Export Hybrid Shader Preset JSON")
		_save_dialog.file_selected.connect(_export_preset_to_path)
		add_child(_save_dialog)
	if _load_dialog == null:
		_load_dialog = _create_preset_dialog(FileDialog.FILE_MODE_OPEN_FILE, "Load Hybrid Shader Preset JSON")
		_load_dialog.file_selected.connect(_load_preset_from_path)
		add_child(_load_dialog)


func _create_preset_dialog(file_mode: FileDialog.FileMode, title_text: String) -> FileDialog:
	var dialog := FileDialog.new()
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.file_mode = file_mode
	dialog.title = title_text
	dialog.use_native_dialog = true
	dialog.filters = PackedStringArray(["*.json ; JSON preset"])
	dialog.current_dir = ProjectSettings.globalize_path(PRESET_DIALOG_DIRECTORY)
	dialog.current_file = DEFAULT_PRESET_FILENAME
	return dialog


func _ensure_preset_directory() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(PRESET_DIALOG_DIRECTORY))


func _on_background_mode_selected(index: int, selector: OptionButton) -> void:
	set_preview_background_mode(selector.get_item_id(index))


func _on_float_value_changed(value: float, parameter_name: String, slider: HSlider) -> void:
	set_panel_shader_parameter(parameter_name, value)
	var value_label: Label = slider.get_meta("value_label") as Label
	if value_label:
		value_label.text = _format_float(value)


func _on_color_value_changed(color: Color, parameter_name: String) -> void:
	set_panel_shader_parameter(parameter_name, color)


func _on_export_json_pressed() -> void:
	_ensure_preset_directory()
	_save_dialog.current_dir = ProjectSettings.globalize_path(PRESET_DIALOG_DIRECTORY)
	_save_dialog.current_file = DEFAULT_PRESET_FILENAME
	_save_dialog.popup_centered_ratio(0.7)


func _on_load_json_pressed() -> void:
	_ensure_preset_directory()
	_load_dialog.current_dir = ProjectSettings.globalize_path(PRESET_DIALOG_DIRECTORY)
	_load_dialog.popup_centered_ratio(0.7)


func _export_preset_to_path(path: String) -> void:
	var parameters := PresetIO.collect_parameters(
		HYBRID_FLOAT_CONTROLS,
		HYBRID_COLOR_CONTROLS,
		Callable(self, "get_panel_shader_parameter")
	)
	var envelope := PresetIO.build_preset_envelope(PresetIO.PRESET_KIND_HYBRID_3D, PRESET_SOURCE_SCENE_PATH, parameters)
	var result := PresetIO.write_preset_file(path, envelope)
	if result.get("ok", false):
		_set_preset_status("Saved preset to %s" % result["path"], false)
	else:
		_set_preset_status(str(result.get("error", "Failed to save preset.")), true)


func _load_preset_from_path(path: String) -> void:
	var result := PresetIO.load_and_apply_preset(
		path,
		PresetIO.PRESET_KIND_HYBRID_3D,
		HYBRID_FLOAT_CONTROLS,
		HYBRID_COLOR_CONTROLS,
		Callable(self, "set_panel_shader_parameter")
	)
	if not result.get("ok", false):
		_set_preset_status(str(result.get("error", "Failed to load preset.")), true)
		return

	call_deferred("_sync_controls_from_panel")
	_apply_loaded_preset_status(result, path, "Loaded preset from")


func _load_startup_default_preset() -> void:
	var result := PresetIO.load_and_apply_preset(
		BUNDLED_DEFAULT_PRESET_PATH,
		PresetIO.PRESET_KIND_HYBRID_3D,
		HYBRID_FLOAT_CONTROLS,
		HYBRID_COLOR_CONTROLS,
		Callable(self, "set_panel_shader_parameter")
	)
	if not result.get("ok", false):
		_set_preset_status("Bundled startup preset failed (%s). Using scene fallback defaults." % str(result.get("error", "unknown error")), true)
		return
	_apply_loaded_preset_status(result, BUNDLED_DEFAULT_PRESET_PATH, "Loaded bundled startup defaults from")


func _apply_loaded_preset_status(result: Dictionary, path: String, prefix: String) -> void:
	var ignored_keys: Array = result.get("ignored_keys", [])
	if ignored_keys.is_empty():
		_set_preset_status("%s %s" % [prefix, path], false)
	else:
		_set_preset_status("%s %s (ignored: %s)" % [prefix, path, _join_string_array(ignored_keys)], false)


func _set_preset_status(message: String, is_error: bool) -> void:
	if not is_instance_valid(_preset_status_label):
		return
	_preset_status_label.text = message
	_preset_status_label.modulate = Color(1.0, 0.72, 0.72, 0.95) if is_error else Color(1.0, 1.0, 1.0, 0.68)


func _sync_controls_from_panel() -> void:
	_select_background_mode(get_preview_background_mode())
	for config in HYBRID_FLOAT_CONTROLS:
		_sync_single_control_from_panel(str(config["name"]))
	for config in HYBRID_COLOR_CONTROLS:
		_sync_single_control_from_panel(str(config["name"]))


func _sync_single_control_from_panel(parameter_name: String) -> void:
	var value: Variant = get_panel_shader_parameter(parameter_name)
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
	var source := _mask_ui if is_instance_valid(_mask_ui) else _panel_ui
	if not is_instance_valid(source) or not source.has_method("get_preview_rect_normalized"):
		return

	var rect: Rect2 = source.call("get_preview_rect_normalized")
	var glass_rect := Vector4(rect.position.x, rect.position.y, rect.size.x, rect.size.y)
	_panel_material.set_shader_parameter("glass_rect", glass_rect)
	if _panel_ui_overlay_material != null:
		_panel_ui_overlay_material.set_shader_parameter("glass_rect", glass_rect)


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


func _refresh_status() -> void:
	if status_label == null or panel_pivot == null:
		return

	var lines := [
		"[b]Hybrid 3D Glass Panel / Input-Core Contract Proof[/b]",
		"[color=#cbd5e1]Space[/color] auto rotation: %s" % ("ON" if auto_rotate else "OFF"),
		"[color=#cbd5e1]WASD / Arrows[/color] pitch and yaw the wrapper",
		"[color=#cbd5e1]R[/color] reset wrapper rotation",
		"[color=#cbd5e1]1 / 2 / 3 / 4[/color] source viewport background: %s" % _background_mode_name(get_preview_background_mode()),
		"[color=#cbd5e1]Mouse / touch[/color] are ray-picked locally, projected into the panel surface, then published through HybridSubViewportInputAdapter.",
		"",
		"Pitch: %.1f°" % panel_pivot.rotation_degrees.x,
		"Yaw: %.1f°" % panel_pivot.rotation_degrees.y,
		"Mouse capture: %s" % ("ON" if _mouse_panel_capture else "OFF"),
		"Hover active: %s" % ("YES" if _mouse_hover_active else "NO"),
		"Surface currently hit: %s" % ("YES" if _last_surface_hover_hit else "NO"),
		"Hover target path: %s" % _path_label(_mouse_hover_target_path),
		"Active owner path: %s" % _path_label(_mouse_owner_target_path),
		"Live projected target: %s" % _path_label(_last_live_target_path),
		"Last release target: %s" % (_last_release_target_path if _last_release_target_path != "" else "none"),
		"Active touches: %d" % _active_touch_state.size(),
		"Published target path: %s" % (_last_contract_target_path if _last_contract_target_path != "" else "waiting"),
		"Source variant: %s" % _last_contract_source_variant,
		"Phase: %s" % _last_contract_phase,
		"Surface ID: %s" % _last_contract_surface_id,
		"Verification: %s" % _last_contract_verification_status,
		"Verification notes: %s" % _last_contract_verification_notes,
		"Last contract publish: %s" % _last_forwarded_panel_event,
		"",
		"Host-owned truth stays here: world ray picking, local hit -> UV -> viewport mapping, sibling target lookup, hover enter/exit truth, and per-pointer owner-path continuity. Normalized semantics stay on the shared input-core bus/adapter contract."
	]
	status_label.text = "\n".join(lines)


func _background_mode_name(mode: int) -> String:
	match mode:
		PanelSourceScript.BACKGROUND_MODE_IMAGE:
			return "AeroBeat image"
		PanelSourceScript.BACKGROUND_MODE_DEBUG:
			return "Debug pattern"
		PanelSourceScript.BACKGROUND_MODE_HYBRID:
			return "Hybrid overlay"
		PanelSourceScript.BACKGROUND_MODE_NONE:
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
