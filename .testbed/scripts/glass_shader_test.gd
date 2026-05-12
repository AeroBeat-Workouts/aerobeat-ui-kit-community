extends Control

const SOURCE_SCENE_PATH := "res://scenes/glass-shader-panel-source.tscn"
const PanelSourceScript = preload("res://scripts/glass_shader_panel_source.gd")

@onready var controls_list: VBoxContainer = get_node_or_null("SplitRoot/ControlsPanel/Margin/ControlsColumn/ControlsScroll/ControlsList") as VBoxContainer
@onready var panel_source_host: Control = get_node_or_null("SplitRoot/PreviewArea/PreviewCenter/PanelSourceHost") as Control

var _panel_source: Control
var _background_mode_selector: OptionButton
var _float_sliders: Dictionary = {}
var _color_pickers: Dictionary = {}


func _ready() -> void:
	_mount_panel_source()
	_build_controls()
	call_deferred("_sync_controls_from_panel")


func set_background_mode(mode: int) -> void:
	if is_instance_valid(_panel_source) and _panel_source.has_method("set_background_mode"):
		_panel_source.call("set_background_mode", mode)
	if is_instance_valid(_background_mode_selector):
		_select_background_mode(mode)


func get_background_mode() -> int:
	if is_instance_valid(_panel_source) and _panel_source.has_method("get_background_mode"):
		return _panel_source.call("get_background_mode")
	return PanelSourceScript.DEFAULT_BACKGROUND_MODE


func set_shader_parameter(parameter_name: String, value: Variant) -> void:
	if is_instance_valid(_panel_source) and _panel_source.has_method("set_shader_parameter"):
		_panel_source.call("set_shader_parameter", parameter_name, value)
	_sync_single_control_from_panel(parameter_name)


func get_shader_parameter(parameter_name: String) -> Variant:
	if is_instance_valid(_panel_source) and _panel_source.has_method("get_shader_parameter"):
		return _panel_source.call("get_shader_parameter", parameter_name)
	return null


func _mount_panel_source() -> void:
	for child in panel_source_host.get_children():
		child.queue_free()

	var packed: PackedScene = load(SOURCE_SCENE_PATH)
	if packed == null:
		push_error("Failed to load panel source scene: %s" % SOURCE_SCENE_PATH)
		return

	_panel_source = packed.instantiate() as Control
	if _panel_source == null:
		push_error("Panel source scene did not instantiate as a Control root.")
		return

	panel_source_host.add_child(_panel_source)
	_panel_source.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _build_controls() -> void:
	for child in controls_list.get_children():
		child.queue_free()

	_float_sliders.clear()
	_color_pickers.clear()
	_background_mode_selector = null

	controls_list.add_child(_make_background_mode_control())

	var mode_note := Label.new()
	mode_note.text = "Use Debug Pattern, Hybrid Overlay, or No Background to inspect blur and refraction in different contexts."
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
	set_background_mode(selector.get_item_id(index))


func _on_float_value_changed(value: float, parameter_name: String, slider: HSlider) -> void:
	set_shader_parameter(parameter_name, value)
	var value_label: Label = slider.get_meta("value_label") as Label
	if value_label:
		value_label.text = _format_float(value)


func _on_color_value_changed(color: Color, parameter_name: String) -> void:
	set_shader_parameter(parameter_name, color)


func _sync_controls_from_panel() -> void:
	_select_background_mode(get_background_mode())
	for config in PanelSourceScript.FLOAT_CONTROLS:
		_sync_single_control_from_panel(str(config["name"]))
	for config in PanelSourceScript.COLOR_CONTROLS:
		_sync_single_control_from_panel(str(config["name"]))


func _sync_single_control_from_panel(parameter_name: String) -> void:
	var value: Variant = get_shader_parameter(parameter_name)
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


func _format_float(value: float) -> String:
	return "%0.2f" % value
