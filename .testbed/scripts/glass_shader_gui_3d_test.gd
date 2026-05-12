extends Node3D

const SOURCE_2D_SCENE_PATH := "res://scenes/glass-shader-test.tscn"
const BACKGROUND_MODE_IMAGE := 0
const BACKGROUND_MODE_DEBUG := 1
const BACKGROUND_MODE_HYBRID := 2

const AUTO_YAW_AMPLITUDE_DEG := 26.0
const AUTO_PITCH_AMPLITUDE_DEG := 10.0
const MAX_MANUAL_PITCH_DEG := 35.0
const MAX_MANUAL_YAW_DEG := 45.0

@export var auto_rotate := true
@export_range(0.0, 90.0, 0.1) var auto_rotate_speed_deg := 36.0
@export_range(0.0, 120.0, 0.1) var manual_rotate_speed_deg := 54.0

@onready var panel_pivot: Node3D = get_node_or_null("PanelPivot") as Node3D
@onready var panel_viewport: SubViewport = get_node_or_null("PanelPivot/PanelViewport") as SubViewport
@onready var panel_display: MeshInstance3D = get_node_or_null("PanelPivot/PanelDisplay") as MeshInstance3D
@onready var hud_label: RichTextLabel = get_node_or_null("CanvasLayer/HudMargin/HudPanel/HudPadding/HudLabel") as RichTextLabel

var _panel_ui: Control
var _manual_pitch_deg := 0.0
var _manual_yaw_deg := 0.0
var _base_rotation := Vector3.ZERO
var _background_mode := BACKGROUND_MODE_HYBRID


func _ready() -> void:
	if panel_pivot == null or panel_viewport == null or panel_display == null:
		push_error("3D GUI glass test scene is missing one or more required nodes.")
		return

	_base_rotation = panel_pivot.rotation_degrees
	_configure_panel_viewport()
	_mount_source_2d_scene()
	_apply_panel_texture()
	_apply_panel_rotation()
	_refresh_hud()


func _process(delta: float) -> void:
	var yaw_input := _axis_strength(KEY_LEFT, KEY_RIGHT, KEY_A, KEY_D)
	var pitch_input := _axis_strength(KEY_DOWN, KEY_UP, KEY_S, KEY_W)
	if yaw_input != 0.0 or pitch_input != 0.0:
		_manual_yaw_deg = clampf(_manual_yaw_deg + yaw_input * manual_rotate_speed_deg * delta, -MAX_MANUAL_YAW_DEG, MAX_MANUAL_YAW_DEG)
		_manual_pitch_deg = clampf(_manual_pitch_deg + pitch_input * manual_rotate_speed_deg * delta, -MAX_MANUAL_PITCH_DEG, MAX_MANUAL_PITCH_DEG)

	_apply_panel_rotation()
	_refresh_hud()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_SPACE:
				auto_rotate = !auto_rotate
			KEY_R:
				reset_manual_rotation()
			KEY_1:
				set_preview_background_mode(BACKGROUND_MODE_IMAGE)
			KEY_2:
				set_preview_background_mode(BACKGROUND_MODE_DEBUG)
			KEY_3:
				set_preview_background_mode(BACKGROUND_MODE_HYBRID)
			_:
				return
		_refresh_hud()


func set_auto_rotate_enabled(value: bool) -> void:
	auto_rotate = value
	_apply_panel_rotation()
	_refresh_hud()


func set_manual_rotation(pitch_deg: float, yaw_deg: float) -> void:
	_manual_pitch_deg = clampf(pitch_deg, -MAX_MANUAL_PITCH_DEG, MAX_MANUAL_PITCH_DEG)
	_manual_yaw_deg = clampf(yaw_deg, -MAX_MANUAL_YAW_DEG, MAX_MANUAL_YAW_DEG)
	_apply_panel_rotation()
	_refresh_hud()


func reset_manual_rotation() -> void:
	_manual_pitch_deg = 0.0
	_manual_yaw_deg = 0.0
	_apply_panel_rotation()
	_refresh_hud()


func set_preview_background_mode(mode: int) -> void:
	_background_mode = clampi(mode, BACKGROUND_MODE_IMAGE, BACKGROUND_MODE_HYBRID)
	if is_instance_valid(_panel_ui) and _panel_ui.has_method("set_background_mode"):
		_panel_ui.call("set_background_mode", _background_mode)
	_refresh_hud()


func get_preview_background_mode() -> int:
	return _background_mode


func _configure_panel_viewport() -> void:
	panel_viewport.disable_3d = true
	panel_viewport.transparent_bg = true
	panel_viewport.gui_disable_input = true
	panel_viewport.handle_input_locally = false
	panel_viewport.msaa_2d = Viewport.MSAA_4X
	panel_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	panel_viewport.size = Vector2i(1600, 900)


func _mount_source_2d_scene() -> void:
	for child in panel_viewport.get_children():
		child.queue_free()

	var packed: PackedScene = load(SOURCE_2D_SCENE_PATH)
	if packed == null:
		push_error("Failed to load source 2D glass shader scene: %s" % SOURCE_2D_SCENE_PATH)
		return

	_panel_ui = packed.instantiate() as Control
	if _panel_ui == null:
		push_error("Source 2D glass shader scene did not instantiate as a Control root.")
		return

	panel_viewport.add_child(_panel_ui)
	_panel_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	set_preview_background_mode(_background_mode)


func _apply_panel_texture() -> void:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.albedo_texture = panel_viewport.get_texture()
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	material.no_depth_test = false
	panel_display.material_override = material


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


func _refresh_hud() -> void:
	if hud_label == null or panel_pivot == null:
		return

	var lines := [
		"[b]3D GUI Panel / 2D Glass Shader Reuse[/b]",
		"[color=#cbd5e1]Space[/color] toggle auto rotation: %s" % ("ON" if auto_rotate else "OFF"),
		"[color=#cbd5e1]WASD / Arrows[/color] nudge pitch and yaw",
		"[color=#cbd5e1]R[/color] reset manual offset",
		"[color=#cbd5e1]1 / 2 / 3[/color] switch panel background: %s" % _background_mode_name(_background_mode),
		"",
		"Pitch: %.1f°" % panel_pivot.rotation_degrees.x,
		"Yaw: %.1f°" % panel_pivot.rotation_degrees.y,
		"",
		"This panel is the original 2D glass-shader test scene rendered into a SubViewport and mapped onto a rotating 3D quad. The refraction itself is still the canvas_item shader, not the native 3D glass shader.",
	]
	hud_label.text = "\n".join(lines)


func _background_mode_name(mode: int) -> String:
	match mode:
		BACKGROUND_MODE_IMAGE:
			return "AeroBeat image"
		BACKGROUND_MODE_DEBUG:
			return "Debug pattern"
		BACKGROUND_MODE_HYBRID:
			return "Hybrid overlay"
		_:
			return "Unknown"
