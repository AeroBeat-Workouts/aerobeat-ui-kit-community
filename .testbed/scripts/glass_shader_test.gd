extends Control

const SOURCE_SCENE_PATH := "res://scenes/glass-shader-panel-source.tscn"
const PRESET_SOURCE_SCENE_PATH := "res://scenes/glass-shader-test.tscn"
const PRESET_DIALOG_DIRECTORY := "res://presets/glass/2d"
const DEFAULT_PRESET_FILENAME := "glass-shader-2d-preset.json"
const BUNDLED_DEFAULT_PRESET_PATH := "res://presets/glass/2d/default.json"
const SCREEN_SURFACE_ID: StringName = &"screen_glass_panel"
const SCREEN_SURFACE_TYPE: StringName = AeroUiInteractionTypes.SURFACE_TYPE_SCREEN_2D
const PREVIEW_BUTTON_PATH := NodePath("PreviewCenter/PreviewStack/PrimaryCardButton/ContentMargin/ContentColumn/PrimaryActionButton")
const PanelSourceScript = preload("res://scripts/glass_shader_panel_source.gd")
const PresetIO = preload("res://scripts/glass_shader_preset_io.gd")

@onready var controls_list: VBoxContainer = get_node_or_null("SplitRoot/ControlsPanel/Margin/ControlsColumn/ControlsScroll/ControlsList") as VBoxContainer
@onready var panel_source_host: Control = get_node_or_null("SplitRoot/PreviewArea/PreviewCenter/PanelSourceHost") as Control
@onready var interaction_bus: AeroUiInteractionBus = get_node_or_null("SplitRoot/PreviewArea/PreviewCenter/PanelSourceHost/AeroUiInteractionBus") as AeroUiInteractionBus
@onready var screen_input_adapter: ScreenUiInputAdapter = get_node_or_null("SplitRoot/PreviewArea/PreviewCenter/PanelSourceHost/ScreenUiInputAdapter") as ScreenUiInputAdapter

var _panel_source: Control
var _proof_button: Control
var _background_mode_selector: OptionButton
var _float_sliders: Dictionary = {}
var _color_pickers: Dictionary = {}
var _preset_status_label: Label
var _contract_status_label: RichTextLabel
var _save_dialog: FileDialog
var _load_dialog: FileDialog
var _mouse_card_capture := false
var _mouse_hover_active := false
var _active_touch_capture: Dictionary = {}
var _last_forwarded_panel_event := "waiting for normalized panel input"
var _last_contract_phase := "waiting"
var _last_contract_source_variant := "waiting"
var _last_contract_surface_id := String(SCREEN_SURFACE_ID)
var _last_contract_verification_status := "waiting"
var _last_contract_verification_notes := "No normalized interaction published yet."
var _last_contract_target_path := ""


func _ready() -> void:
	_mount_panel_source()
	_ensure_interaction_contract_nodes()
	_configure_panel_source_contract()
	_build_controls()
	_setup_preset_dialogs()
	_load_startup_default_preset()
	call_deferred("_sync_controls_from_panel")
	call_deferred("_refresh_contract_status")


func _unhandled_input(event: InputEvent) -> void:
	if _forward_screen_panel_input(event):
		get_viewport().set_input_as_handled()
		_refresh_contract_status()


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
	_detach_contract_nodes_from_panel_source()
	if is_instance_valid(_panel_source):
		_panel_source.queue_free()
		_panel_source = null
	_proof_button = null

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
	_proof_button = _panel_source.get_node_or_null(PREVIEW_BUTTON_PATH) as Control
	_attach_contract_nodes_to_proof_button()


func _detach_contract_nodes_from_panel_source() -> void:
	for contract_node in [screen_input_adapter, interaction_bus]:
		if not is_instance_valid(contract_node):
			continue
		var parent: Node = contract_node.get_parent()
		if parent != null and parent != panel_source_host:
			parent.remove_child(contract_node)
			panel_source_host.add_child(contract_node)


func _attach_contract_nodes_to_proof_button() -> void:
	if not is_instance_valid(_proof_button) or not is_instance_valid(screen_input_adapter):
		return
	var parent: Node = screen_input_adapter.get_parent()
	if parent != _proof_button:
		if parent != null:
			parent.remove_child(screen_input_adapter)
		_proof_button.add_child(screen_input_adapter)
	if is_instance_valid(interaction_bus):
		screen_input_adapter.bus_path = interaction_bus.get_path()


func _ensure_interaction_contract_nodes() -> void:
	if interaction_bus == null:
		interaction_bus = AeroUiInteractionBus.new()
		interaction_bus.name = "AeroUiInteractionBus"
		panel_source_host.add_child(interaction_bus)
	if screen_input_adapter == null:
		screen_input_adapter = ScreenUiInputAdapter.new()
		screen_input_adapter.name = "ScreenUiInputAdapter"
		panel_source_host.add_child(screen_input_adapter)

	screen_input_adapter.bus_path = interaction_bus.get_path()
	screen_input_adapter.surface_id = SCREEN_SURFACE_ID
	screen_input_adapter.surface_type = SCREEN_SURFACE_TYPE
	screen_input_adapter.drag_threshold_pixels = 12.0
	screen_input_adapter.emit_hover_events = true
	_attach_contract_nodes_to_proof_button()

	if not interaction_bus.interaction_event.is_connected(_on_contract_interaction_event):
		interaction_bus.interaction_event.connect(_on_contract_interaction_event)


func _configure_panel_source_contract() -> void:
	if not is_instance_valid(_panel_source):
		return
	if is_instance_valid(interaction_bus) and _panel_source.has_method("set_interaction_bus_path"):
		_panel_source.call("set_interaction_bus_path", interaction_bus.get_path())
	if _panel_source.has_method("configure_interaction_contract"):
		_panel_source.call("configure_interaction_contract", {
			"surface_id": SCREEN_SURFACE_ID,
			"surface_type_label": String(SCREEN_SURFACE_TYPE),
			"mode_label": "Screen contract proof",
			"host_summary": "Screen-space host routing now feeds AeroUiInteractionBus through ScreenUiInputAdapter. This card reacts to normalized hover / press / drag / tap phases instead of raw gui_input parsing.",
		})


func _forward_screen_panel_input(event: InputEvent) -> bool:
	if screen_input_adapter == null or not is_instance_valid(_proof_button):
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
	var inside_card := _is_screen_position_inside_proof_card(event.position)
	if event.pressed and not inside_card:
		return false
	if not event.pressed and not inside_card and not _mouse_card_capture:
		return false

	var published := _publish_to_screen_adapter(event, {
		"host_surface": "screen_2d_card",
		"target_resolution": "preview_button_path",
		"capture_continuity": _mouse_card_capture,
	})
	if not published:
		return false

	if event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and inside_card:
			_mouse_card_capture = true
		elif not event.pressed:
			_mouse_card_capture = false
			if not inside_card:
				_mouse_hover_active = false

	_last_forwarded_panel_event = "publish mouse %s -> proof card%s" % ["press" if event.pressed else "release", " (captured)" if _mouse_card_capture and not inside_card else ""]
	return true


func _publish_mouse_motion_to_contract(event: InputEventMouseMotion) -> bool:
	var inside_card := _is_screen_position_inside_proof_card(event.position)
	if not inside_card and not _mouse_card_capture and not _mouse_hover_active:
		return false

	var published := _publish_to_screen_adapter(event, {
		"host_surface": "screen_2d_card",
		"target_resolution": "preview_button_path",
		"capture_continuity": _mouse_card_capture,
	})
	if not published:
		return false

	if inside_card:
		_mouse_hover_active = true
	elif not _mouse_card_capture:
		_mouse_hover_active = false

	_last_forwarded_panel_event = "publish mouse motion -> proof card%s" % (" (captured)" if _mouse_card_capture and not inside_card else "")
	return true


func _publish_screen_touch_to_contract(event: InputEventScreenTouch) -> bool:
	var pointer_id := event.index
	var has_capture := _active_touch_capture.has(pointer_id)
	var inside_card := _is_screen_position_inside_proof_card(event.position)
	if event.pressed and not inside_card:
		return false
	if not event.pressed and not inside_card and not has_capture:
		return false

	var published := _publish_to_screen_adapter(event, {
		"host_surface": "screen_2d_card",
		"target_resolution": "preview_button_path",
		"capture_continuity": has_capture,
	})
	if not published:
		return false

	if event.pressed:
		_active_touch_capture[pointer_id] = true
	else:
		_active_touch_capture.erase(pointer_id)

	_last_forwarded_panel_event = "publish touch %s #%d -> proof card%s" % ["press" if event.pressed else "release", event.index, " (captured)" if has_capture and not inside_card else ""]
	return true


func _publish_screen_drag_to_contract(event: InputEventScreenDrag) -> bool:
	var pointer_id := event.index
	if not _active_touch_capture.has(pointer_id):
		return false

	var inside_card := _is_screen_position_inside_proof_card(event.position)
	var published := _publish_to_screen_adapter(event, {
		"host_surface": "screen_2d_card",
		"target_resolution": "preview_button_path",
		"capture_continuity": true,
		"inside_card": inside_card,
	})
	if not published:
		return false

	_last_forwarded_panel_event = "publish touch drag #%d -> proof card%s" % [event.index, " (captured)" if not inside_card else ""]
	return true


func _publish_to_screen_adapter(event: InputEvent, metadata: Dictionary = {}) -> bool:
	if screen_input_adapter == null or not is_instance_valid(_proof_button):
		return false
	return screen_input_adapter.publish_input_event(event, _proof_button.get_path(), metadata)


func _is_screen_position_inside_proof_card(screen_position: Vector2) -> bool:
	if not is_instance_valid(_proof_button):
		return false
	return _proof_button.get_global_rect().has_point(screen_position)


func _on_contract_interaction_event(event: AeroUiInteractionEvent) -> void:
	if event.surface_id != SCREEN_SURFACE_ID:
		return

	_last_contract_phase = str(event.phase)
	_last_contract_source_variant = str(event.source_variant)
	_last_contract_surface_id = str(event.surface_id)
	_last_contract_verification_status = str(event.verification_status)
	_last_contract_verification_notes = str(event.verification_notes)
	_last_contract_target_path = str(event.target_path)
	_last_forwarded_panel_event = "%s • %s • %s" % [event.source_variant, event.phase, event.verification_status]

	match event.phase:
		AeroUiInteractionTypes.PHASE_HOVER_ENTER:
			_mouse_hover_active = true
		AeroUiInteractionTypes.PHASE_HOVER_EXIT, AeroUiInteractionTypes.PHASE_CANCEL:
			_mouse_hover_active = false
		_:
			pass

	_refresh_contract_status()


func _build_controls() -> void:
	for child in controls_list.get_children():
		child.queue_free()

	_float_sliders.clear()
	_color_pickers.clear()
	_background_mode_selector = null
	_preset_status_label = null
	_contract_status_label = null

	controls_list.add_child(_make_background_mode_control())
	controls_list.add_child(_make_preset_actions_block())

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0.0, 8.0)
	controls_list.add_child(spacer)

	for config in PanelSourceScript.FLOAT_CONTROLS:
		controls_list.add_child(_make_float_control(config))

	for config in PanelSourceScript.COLOR_CONTROLS:
		controls_list.add_child(_make_color_control(config))

	controls_list.add_child(_make_contract_status_block())

	var tail_spacer := Control.new()
	tail_spacer.custom_minimum_size = Vector2(0.0, 8.0)
	controls_list.add_child(tail_spacer)

	_refresh_contract_status()


func _make_contract_status_block() -> Control:
	var wrapper := VBoxContainer.new()
	wrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wrapper.add_theme_constant_override("separation", 8)

	var title := Label.new()
	title.text = "screen_input_contract"
	wrapper.add_child(title)

	var status := RichTextLabel.new()
	status.fit_content = true
	status.scroll_active = false
	status.bbcode_enabled = false
	status.custom_minimum_size = Vector2(0.0, 164.0)
	status.modulate = Color(1.0, 1.0, 1.0, 0.86)
	wrapper.add_child(status)
	_contract_status_label = status

	return wrapper


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


func _make_preset_actions_block() -> Control:
	var wrapper := VBoxContainer.new()
	wrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wrapper.add_theme_constant_override("separation", 8)

	var title := Label.new()
	title.text = "preset_json"
	wrapper.add_child(title)

	var description := Label.new()
	description.text = "Save the current slider and color values to JSON or load them back into this 2D shader tester."
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


func _setup_preset_dialogs() -> void:
	_ensure_preset_directory()
	if _save_dialog == null:
		_save_dialog = _create_preset_dialog(FileDialog.FILE_MODE_SAVE_FILE, "Export Shader Preset JSON")
		_save_dialog.file_selected.connect(_export_preset_to_path)
		add_child(_save_dialog)
	if _load_dialog == null:
		_load_dialog = _create_preset_dialog(FileDialog.FILE_MODE_OPEN_FILE, "Load Shader Preset JSON")
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
	set_background_mode(selector.get_item_id(index))


func _on_float_value_changed(value: float, parameter_name: String, slider: HSlider) -> void:
	set_shader_parameter(parameter_name, value)
	var value_label: Label = slider.get_meta("value_label") as Label
	if value_label:
		value_label.text = _format_float(value)


func _on_color_value_changed(color: Color, parameter_name: String) -> void:
	set_shader_parameter(parameter_name, color)


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
		PanelSourceScript.FLOAT_CONTROLS,
		PanelSourceScript.COLOR_CONTROLS,
		Callable(self, "get_shader_parameter")
	)
	var envelope := PresetIO.build_preset_envelope(PresetIO.PRESET_KIND_2D, PRESET_SOURCE_SCENE_PATH, parameters)
	var result := PresetIO.write_preset_file(path, envelope)
	if result.get("ok", false):
		_set_preset_status("Saved preset to %s" % result["path"], false)
	else:
		_set_preset_status(str(result.get("error", "Failed to save preset.")), true)


func _load_preset_from_path(path: String) -> void:
	var result := PresetIO.load_and_apply_preset(
		path,
		PresetIO.PRESET_KIND_2D,
		PanelSourceScript.FLOAT_CONTROLS,
		PanelSourceScript.COLOR_CONTROLS,
		Callable(self, "set_shader_parameter")
	)
	if not result.get("ok", false):
		_set_preset_status(str(result.get("error", "Failed to load preset.")), true)
		return

	call_deferred("_sync_controls_from_panel")
	_apply_loaded_preset_status(result, path, "Loaded preset from")


func _load_startup_default_preset() -> void:
	var result := PresetIO.load_and_apply_preset(
		BUNDLED_DEFAULT_PRESET_PATH,
		PresetIO.PRESET_KIND_2D,
		PanelSourceScript.FLOAT_CONTROLS,
		PanelSourceScript.COLOR_CONTROLS,
		Callable(self, "set_shader_parameter")
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


func _refresh_contract_status() -> void:
	if not is_instance_valid(_contract_status_label):
		return

	var lines := [
		"Screen 2D Glass Panel / Input-Core Contract Proof",
		"",
		"Source variant: %s" % _last_contract_source_variant,
		"Phase: %s" % _last_contract_phase,
		"Surface ID: %s" % _last_contract_surface_id,
		"Surface type: %s" % String(SCREEN_SURFACE_TYPE),
		"Target path: %s" % (_last_contract_target_path if _last_contract_target_path != "" else "waiting"),
		"Mouse capture: %s" % ("ON" if _mouse_card_capture else "OFF"),
		"Hover active: %s" % ("YES" if _mouse_hover_active else "NO"),
		"Active touches: %d" % _active_touch_capture.size(),
		"Last contract publish: %s" % _last_forwarded_panel_event,
	]
	_contract_status_label.text = "\n".join(lines)


func _join_string_array(values: Array) -> String:
	var parts: PackedStringArray = []
	for value in values:
		parts.append(str(value))
	return ", ".join(parts)


func _format_float(value: float) -> String:
	return "%0.2f" % value
