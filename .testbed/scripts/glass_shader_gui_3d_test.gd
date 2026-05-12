extends Node3D

const SOURCE_2D_SCENE_PATH := "res://scenes/glass-shader-panel-source.tscn"
const HYBRID_SHADER_PATH := "res://assets/shaders/glass-panel-hybrid-3d.gdshader"
const UI_OVERLAY_SHADER_PATH := "res://assets/shaders/glass-panel-ui-overlay-3d.gdshader"
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
		"default": 0.60,
	},
	{
		"name": "body_frost_strength",
		"label": "body_frost_strength",
		"min": 0.0,
		"max": 1.0,
		"step": 0.01,
		"default": 0.78,
	},
	{
		"name": "background_subdue",
		"label": "background_subdue",
		"min": 0.0,
		"max": 1.0,
		"step": 0.01,
		"default": 0.62,
	},
	{
		"name": "interior_chroma",
		"label": "interior_chroma",
		"min": 0.0,
		"max": 1.0,
		"step": 0.01,
		"default": 0.16,
	},
	{
		"name": "world_rim_refraction",
		"label": "world_rim_refraction",
		"min": 0.0,
		"max": 1.0,
		"step": 0.01,
		"default": 0.14,
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
		"default": 0.08,
	},
	{
		"name": "face_highlight",
		"label": "face_highlight",
		"min": 0.0,
		"max": 0.4,
		"step": 0.01,
		"default": 0.06,
	},
	{
		"name": "face_veil_strength",
		"label": "face_veil_strength",
		"min": 0.0,
		"max": 1.0,
		"step": 0.01,
		"default": 0.34,
	},
	{
		"name": "perimeter_frost_boost",
		"label": "perimeter_frost_boost",
		"min": 0.0,
		"max": 0.5,
		"step": 0.01,
		"default": 0.18,
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
		"default": 0.04,
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
]

const HYBRID_COLOR_CONTROLS := [
	{
		"name": "tint",
		"label": "tint",
		"default": Color(0.95, 0.975, 1.0, 0.40),
	},
	{
		"name": "edge_color",
		"label": "edge_color",
		"default": Color(1.0, 1.0, 1.0, 0.22),
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

@onready var panel_pivot: Node3D = get_node_or_null("PanelPivot") as Node3D
@onready var panel_viewport: SubViewport = get_node_or_null("PanelPivot/PanelViewport") as SubViewport
@onready var mask_viewport: SubViewport = get_node_or_null("PanelPivot/MaskViewport") as SubViewport
@onready var panel_display: MeshInstance3D = get_node_or_null("PanelPivot/PanelDisplay") as MeshInstance3D
@onready var panel_ui_overlay: MeshInstance3D = get_node_or_null("PanelPivot/PanelUiOverlay") as MeshInstance3D
@onready var controls_list: VBoxContainer = get_node_or_null("CanvasLayer/OverlayRoot/SplitRoot/ControlsPanel/Margin/ControlsColumn/ControlsScroll/ControlsList") as VBoxContainer
@onready var status_label: RichTextLabel = get_node_or_null("CanvasLayer/OverlayRoot/SplitRoot/ControlsPanel/Margin/ControlsColumn/StatusPanel/StatusPadding/StatusLabel") as RichTextLabel

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


func _ready() -> void:
	if panel_pivot == null or panel_viewport == null or mask_viewport == null or panel_display == null or panel_ui_overlay == null:
		push_error("3D GUI glass test scene is missing one or more required nodes.")
		return

	_base_rotation = panel_pivot.rotation_degrees
	_configure_subviewport(panel_viewport)
	_configure_subviewport(mask_viewport)
	_mount_source_2d_scenes()
	_configure_panel_sources_for_hybrid()
	_apply_panel_materials()
	_build_controls()
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
	if not _is_overlay_parameter(parameter_name):
		_panel_material.set_shader_parameter(resolved["name"], resolved["value"])
	_apply_overlay_shader_parameter(parameter_name, value)
	if is_instance_valid(_mask_ui) and _mask_ui.has_method("set_shader_parameter"):
		var mask_parameter_name := parameter_name
		if parameter_name == "edge_color":
			mask_parameter_name = "edge_highlight"
		if mask_parameter_name in ["corner_radius", "edge_smoothness", "edge_width", "tint", "edge_highlight"]:
			_mask_ui.call("set_shader_parameter", mask_parameter_name, value)
	if parameter_name in ["corner_radius", "edge_smoothness", "edge_width"]:
		_sync_authored_card_rect()
	_sync_single_control_from_panel(parameter_name)
	_sync_single_control_from_panel(str(resolved["name"]))
	_refresh_status()


func get_panel_shader_parameter(parameter_name: String) -> Variant:
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
	_copy_source_shader_defaults_to_hybrid_material()
	_sync_authored_card_rect()
	panel_display.material_override = _panel_material
	panel_ui_overlay.material_override = _panel_ui_overlay_material


func _copy_source_shader_defaults_to_hybrid_material() -> void:
	if not is_instance_valid(_panel_ui) or not _panel_ui.has_method("get_shader_parameters"):
		return

	var params: Dictionary = _panel_ui.call("get_shader_parameters")
	var passthrough_parameters := {
		"blur": true,
		"warp_intensity": true,
		"strength_x": true,
		"strength_y": true,
		"offset_x": true,
		"offset_y": true,
		"corner_radius": true,
		"edge_smoothness": true,
		"edge_width": true,
	}
	for parameter_name in params.keys():
		if passthrough_parameters.has(parameter_name):
			set_panel_shader_parameter(str(parameter_name), params[parameter_name])


func _build_controls() -> void:
	for child in controls_list.get_children():
		child.queue_free()

	_float_sliders.clear()
	_color_pickers.clear()
	_background_mode_selector = null

	controls_list.add_child(_make_background_mode_control())

	var mode_note := Label.new()
	mode_note.text = "The hybrid path now uses two authored SubViewports: one supplies content-only UI, the other supplies a rounded card mask. The 3D shader owns the actual blur/refraction/tint/highlight and applies them only inside that authored card region."
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
		"[b]Hybrid 3D Glass Panel / Mask-Aware World Shader[/b]",
		"[color=#cbd5e1]Space[/color] auto rotation: %s" % ("ON" if auto_rotate else "OFF"),
		"[color=#cbd5e1]WASD / Arrows[/color] pitch and yaw the wrapper",
		"[color=#cbd5e1]R[/color] reset wrapper rotation",
		"[color=#cbd5e1]1 / 2 / 3 / 4[/color] source viewport background: %s" % _background_mode_name(get_preview_background_mode()),
		"",
		"Pitch: %.1f°" % panel_pivot.rotation_degrees.x,
		"Yaw: %.1f°" % panel_pivot.rotation_degrees.y,
		"",
		"This parity pass keeps the shared 2D source scene, but now separates the milky glass body from a crisp UI overlay. The body shader uses the authored mask to keep the face flatter and creamier, while the front overlay preserves text clarity and closer 2D-style UI color."
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
