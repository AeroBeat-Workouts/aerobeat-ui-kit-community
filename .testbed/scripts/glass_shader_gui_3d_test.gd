extends Node3D

const SOURCE_2D_SCENE_PATH := "res://scenes/glass-shader-panel-source.tscn"
const HYBRID_SHADER_PATH := "res://assets/shaders/glass-panel-hybrid-3d.gdshader"
const PanelSourceScript = preload("res://scripts/glass_shader_panel_source.gd")

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
		"name": "refraction_strength",
		"label": "refraction_strength",
		"min": 0.0,
		"max": 0.12,
		"step": 0.001,
		"default": 0.028,
	},
	{
		"name": "curvature",
		"label": "curvature",
		"min": 0.0,
		"max": 3.0,
		"step": 0.01,
		"default": 1.2,
	},
	{
		"name": "corner_radius",
		"label": "corner_radius",
		"min": 0.0,
		"max": 0.45,
		"step": 0.001,
		"default": 0.18,
	},
	{
		"name": "edge_width",
		"label": "edge_width",
		"min": 0.0,
		"max": 0.2,
		"step": 0.001,
		"default": 0.06,
	},
	{
		"name": "chromatic_aberration",
		"label": "chromatic_aberration",
		"min": 0.0,
		"max": 4.0,
		"step": 0.1,
		"default": 1.7,
	},
	{
		"name": "tint_strength",
		"label": "tint_strength",
		"min": 0.0,
		"max": 1.0,
		"step": 0.01,
		"default": 0.28,
	},
	{
		"name": "fresnel_power",
		"label": "fresnel_power",
		"min": 0.5,
		"max": 8.0,
		"step": 0.1,
		"default": 4.0,
	},
	{
		"name": "fresnel_strength",
		"label": "fresnel_strength",
		"min": 0.0,
		"max": 2.0,
		"step": 0.01,
		"default": 0.42,
	},
	{
		"name": "face_highlight",
		"label": "face_highlight",
		"min": 0.0,
		"max": 0.4,
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
		"default": 1.0,
	},
]

const HYBRID_COLOR_CONTROLS := [
	{
		"name": "tint",
		"label": "tint",
		"default": Color(0.9, 0.95, 1.0, 0.34),
	},
	{
		"name": "edge_color",
		"label": "edge_color",
		"default": Color(1.0, 1.0, 1.0, 0.72),
	},
]

const PARAMETER_ALIASES := {
	"warp_intensity": {"target": "refraction_strength", "scale": 0.0622222222},
	"chromatic_strength": {"target": "chromatic_aberration", "scale": 0.7727272727},
	"edge_highlight": {"target": "edge_color"},
}

@export var auto_rotate := true
@export_range(0.0, 90.0, 0.1) var auto_rotate_speed_deg := 36.0
@export_range(0.0, 120.0, 0.1) var manual_rotate_speed_deg := 54.0

@onready var panel_pivot: Node3D = get_node_or_null("PanelPivot") as Node3D
@onready var panel_viewport: SubViewport = get_node_or_null("PanelPivot/PanelViewport") as SubViewport
@onready var panel_display: MeshInstance3D = get_node_or_null("PanelPivot/PanelDisplay") as MeshInstance3D
@onready var controls_list: VBoxContainer = get_node_or_null("CanvasLayer/OverlayRoot/SplitRoot/ControlsPanel/Margin/ControlsColumn/ControlsScroll/ControlsList") as VBoxContainer
@onready var status_label: RichTextLabel = get_node_or_null("CanvasLayer/OverlayRoot/SplitRoot/ControlsPanel/Margin/ControlsColumn/StatusPanel/StatusPadding/StatusLabel") as RichTextLabel

var _panel_ui: Control
var _panel_material: ShaderMaterial
var _manual_pitch_deg := 0.0
var _manual_yaw_deg := 0.0
var _base_rotation := Vector3.ZERO
var _background_mode_selector: OptionButton
var _float_sliders: Dictionary = {}
var _color_pickers: Dictionary = {}


func _ready() -> void:
	if panel_pivot == null or panel_viewport == null or panel_display == null:
		push_error("3D GUI glass test scene is missing one or more required nodes.")
		return

	_base_rotation = panel_pivot.rotation_degrees
	_configure_panel_viewport()
	_mount_source_2d_scene()
	_configure_panel_source_for_hybrid()
	_apply_panel_material()
	_build_controls()
	call_deferred("_sync_controls_from_panel")
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

	var resolved: Dictionary = _resolve_parameter_alias(parameter_name, value)
	_panel_material.set_shader_parameter(resolved["name"], resolved["value"])
	_sync_single_control_from_panel(parameter_name)
	_sync_single_control_from_panel(str(resolved["name"]))
	_refresh_status()


func get_panel_shader_parameter(parameter_name: String) -> Variant:
	if _panel_material == null:
		return null

	var alias: Variant = PARAMETER_ALIASES.get(parameter_name, null)
	if alias is Dictionary:
		var resolved_value: Variant = _panel_material.get_shader_parameter(str(alias["target"]))
		if alias.has("scale") and resolved_value is float:
			return float(resolved_value) / float(alias["scale"])
		return resolved_value

	return _panel_material.get_shader_parameter(parameter_name)


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


func _configure_panel_source_for_hybrid() -> void:
	if not is_instance_valid(_panel_ui):
		return

	if _panel_ui.has_method("set_presentation_mode"):
		_panel_ui.call("set_presentation_mode", PanelSourceScript.PRESENTATION_MODE_HYBRID_WORLD_SPACE)
	if _panel_ui.has_method("set_background_mode"):
		_panel_ui.call("set_background_mode", PanelSourceScript.BACKGROUND_MODE_NONE)


func _apply_panel_material() -> void:
	var shader: Shader = load(HYBRID_SHADER_PATH)
	if shader == null:
		push_error("Failed to load hybrid 3D glass shader: %s" % HYBRID_SHADER_PATH)
		return

	_panel_material = ShaderMaterial.new()
	_panel_material.shader = shader
	for config in HYBRID_FLOAT_CONTROLS:
		_panel_material.set_shader_parameter(str(config["name"]), config["default"])
	for config in HYBRID_COLOR_CONTROLS:
		_panel_material.set_shader_parameter(str(config["name"]), config["default"])

	_panel_material.set_shader_parameter("edge_softness", 0.012)
	_panel_material.set_shader_parameter("ui_shadow_strength", 0.08)
	_panel_material.set_shader_parameter("flip_ui_vertical", false)
	_panel_material.set_shader_parameter("ui_texture", panel_viewport.get_texture())
	panel_display.material_override = _panel_material


func _build_controls() -> void:
	for child in controls_list.get_children():
		child.queue_free()

	_float_sliders.clear()
	_color_pickers.clear()
	_background_mode_selector = null

	controls_list.add_child(_make_background_mode_control())

	var mode_note := Label.new()
	mode_note.text = "The SubViewport now supplies authored UI/chrome only. The panel mesh shader samples the real 3D screen behind it and composites the 2D UI texture on top. Use No background for the truthful path; the other modes are comparison aids."
	mode_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	mode_note.modulate = Color(1.0, 1.0, 1.0, 0.68)
	controls_list.add_child(mode_note)

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


func _on_background_mode_selected(index: int, selector: OptionButton) -> void:
	set_preview_background_mode(selector.get_item_id(index))


func _on_float_value_changed(value: float, parameter_name: String, slider: HSlider) -> void:
	set_panel_shader_parameter(parameter_name, value)
	var value_label: Label = slider.get_meta("value_label") as Label
	if value_label:
		value_label.text = _format_float(value)


func _on_color_value_changed(color: Color, parameter_name: String) -> void:
	set_panel_shader_parameter(parameter_name, color)


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
		"[b]Hybrid 3D Glass Panel / World-Aware Shader[/b]",
		"[color=#cbd5e1]Space[/color] auto rotation: %s" % ("ON" if auto_rotate else "OFF"),
		"[color=#cbd5e1]WASD / Arrows[/color] pitch and yaw the wrapper",
		"[color=#cbd5e1]R[/color] reset wrapper rotation",
		"[color=#cbd5e1]1 / 2 / 3 / 4[/color] source viewport background: %s" % _background_mode_name(get_preview_background_mode()),
		"",
		"Pitch: %.1f°" % panel_pivot.rotation_degrees.x,
		"Yaw: %.1f°" % panel_pivot.rotation_degrees.y,
		"",
		"This replacement path keeps UI authored in the shared 2D panel scene, disables the old canvas-item GlassFill inside the SubViewport, and lets the 3D panel shader own the actual refraction, tint, edge highlight, and world-behind-glass distortion."
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


func _format_float(value: float) -> String:
	return "%0.3f" % value if absf(value) < 1.0 else "%0.2f" % value
