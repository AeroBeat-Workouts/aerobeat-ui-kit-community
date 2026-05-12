extends Node3D

const SOURCE_2D_SCENE_PATH := "res://scenes/glass-shader-panel-source.tscn"
const PanelSourceScript = preload("res://scripts/glass_shader_panel_source.gd")

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
@onready var controls_list: VBoxContainer = get_node_or_null("CanvasLayer/OverlayRoot/SplitRoot/ControlsPanel/Margin/ControlsColumn/ControlsScroll/ControlsList") as VBoxContainer
@onready var status_label: RichTextLabel = get_node_or_null("CanvasLayer/OverlayRoot/SplitRoot/ControlsPanel/Margin/ControlsColumn/StatusPanel/StatusPadding/StatusLabel") as RichTextLabel

var _panel_ui: Control
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
	_apply_panel_texture()
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
	return PanelSourceScript.DEFAULT_BACKGROUND_MODE


func set_panel_shader_parameter(parameter_name: String, value: Variant) -> void:
	if is_instance_valid(_panel_ui) and _panel_ui.has_method("set_shader_parameter"):
		_panel_ui.call("set_shader_parameter", parameter_name, value)
	_sync_single_control_from_panel(parameter_name)
	_refresh_status()


func get_panel_shader_parameter(parameter_name: String) -> Variant:
	if is_instance_valid(_panel_ui) and _panel_ui.has_method("get_shader_parameter"):
		return _panel_ui.call("get_shader_parameter", parameter_name)
	return null


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


func _apply_panel_texture() -> void:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.albedo_texture = panel_viewport.get_texture()
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	material.no_depth_test = false
	panel_display.material_override = material


func _build_controls() -> void:
	for child in controls_list.get_children():
		child.queue_free()

	_float_sliders.clear()
	_color_pickers.clear()
	_background_mode_selector = null

	controls_list.add_child(_make_background_mode_control())

	var mode_note := Label.new()
	mode_note.text = "These wrapper controls drive the standalone 2D source scene inside the SubViewport."
	mode_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	mode_note.modulate = Color(1.0, 1.0, 1.0, 0.68)
	controls_list.add_child(mode_note)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0.0, 8.0)
	controls_list.add_child(spacer)

	for config in PanelSourceScript.FLOAT_CONTROLS:
		controls_list.add_child(_make_float_control(config))

	for config in PanelSourceScript.COLOR_CONTROLS:
		controls_list.add_child(_make_color_control(config))

	var tail_spacer := Control.new()
	tail_spacer.custom_minimum_size = Vector2(0.0, 8.0)
	controls_list.add_child(tail_spacer)


func _make_background_mode_control() -> Control:
	var wrapper := VBoxContainer.new()
	wrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var label := Label.new()
	label.text = "preview_background"
	wrapper.add_child(label)

	var selector := OptionButton.new()
	selector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	selector.add_item("AeroBeat image", PanelSourceScript.BACKGROUND_MODE_IMAGE)
	selector.add_item("Debug pattern", PanelSourceScript.BACKGROUND_MODE_DEBUG)
	selector.add_item("Hybrid overlay", PanelSourceScript.BACKGROUND_MODE_HYBRID)
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
	value_label.custom_minimum_size = Vector2(48.0, 0.0)
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
	for config in PanelSourceScript.FLOAT_CONTROLS:
		_sync_single_control_from_panel(str(config["name"]))
	for config in PanelSourceScript.COLOR_CONTROLS:
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
		"[b]3D GUI Panel / 2D Glass Shader Reuse[/b]",
		"[color=#cbd5e1]Space[/color] auto rotation: %s" % ("ON" if auto_rotate else "OFF"),
		"[color=#cbd5e1]WASD / Arrows[/color] pitch and yaw the wrapper",
		"[color=#cbd5e1]R[/color] reset wrapper rotation",
		"[color=#cbd5e1]1 / 2 / 3[/color] panel background: %s" % _background_mode_name(get_preview_background_mode()),
		"",
		"Pitch: %.1f°" % panel_pivot.rotation_degrees.x,
		"Yaw: %.1f°" % panel_pivot.rotation_degrees.y,
		"",
		"This is still the 2D canvas_item glass shader rendered into a SubViewport and mapped onto a rotating 3D quad. It is intentionally not the native 3D glass shader path."
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
		_:
			return "Unknown"


func _format_float(value: float) -> String:
	return "%0.2f" % value
