extends Node3D

const AUTO_YAW_AMPLITUDE_DEG := 26.0
const AUTO_PITCH_AMPLITUDE_DEG := 10.0
const MAX_MANUAL_PITCH_DEG := 35.0
const MAX_MANUAL_YAW_DEG := 45.0

@export var auto_rotate := true
@export_range(0.0, 90.0, 0.1) var auto_rotate_speed_deg := 36.0
@export_range(0.0, 120.0, 0.1) var manual_rotate_speed_deg := 54.0

@onready var panel_pivot: Node3D = get_node_or_null("PanelPivot") as Node3D
@onready var hud_label: RichTextLabel = get_node_or_null("CanvasLayer/HudMargin/HudPanel/HudPadding/HudLabel") as RichTextLabel

var _manual_pitch_deg := 0.0
var _manual_yaw_deg := 0.0
var _base_rotation := Vector3.ZERO


func _ready() -> void:
	if panel_pivot == null:
		push_error("PanelPivot is missing from the 3D glass test scene.")
		return
	_base_rotation = panel_pivot.rotation_degrees
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
	if hud_label == null:
		return

	var lines := [
		"[b]3D Glass Panel Test[/b]",
		"[color=#cbd5e1]Space[/color] toggle auto rotation: %s" % ("ON" if auto_rotate else "OFF"),
		"[color=#cbd5e1]WASD / Arrows[/color] nudge pitch and yaw",
		"[color=#cbd5e1]R[/color] reset manual offset",
		"",
		"Pitch: %.1f°" % panel_pivot.rotation_degrees.x,
		"Yaw: %.1f°" % panel_pivot.rotation_degrees.y,
		"",
		"Look for the wall bands, grid lines, spheres, and diagonal bars to stay visible through the glass face while the box depth and edge rim catch light at oblique angles.",
	]
	hud_label.text = "\n".join(lines)
