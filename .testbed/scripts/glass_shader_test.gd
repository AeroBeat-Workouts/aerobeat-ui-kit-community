extends Control

# Phase 1 ownership-boundary freeze note:
# - The canonical interaction contract, event taxonomy, bus, and native 2D bridge
#   ownership remain in aerobeat-input-core.
# - This proof host may keep narrow reference wiring to the contract for now, but it
#   must not grow into a second contract owner.
# - Phase 2 should extract only reusable bridge/provider logic into owning repos while
#   leaving this scene as a consumer/example surface.
const PANEL_VIEW_SCENE_PATH := "res://scenes/screen-2d-glass-panel-source.tscn"
const PANEL_PRESET_DIALOG_DIRECTORY := "res://ui/presets/glass/panel"
const BADGE_PRESET_DIALOG_DIRECTORY := "res://ui/presets/glass/badge"
const BUTTON_PRESET_DIALOG_DIRECTORY := "res://ui/presets/glass/button/primary"
const SCREEN_SURFACE_ID: StringName = &"screen_glass_panel"
const SCREEN_SURFACE_TYPE: StringName = AeroUiInteractionTypes.SURFACE_TYPE_SCREEN_2D
const PREVIEW_BUTTON_PATH := NodePath("PreviewCenter/PreviewStack/PrimaryCardButton/ContentMargin/ContentColumn/PrimaryActionButton")
const PanelViewScript = preload("res://ui/views/aero_ui_glass_panel_view.gd")
const YamlBundleIO = preload("res://scripts/aero_ui_glass_yaml_bundle_io.gd")
const BadgeConfigLoader = preload("res://ui/configs/loaders/aero_ui_glass_badge_config_loader.gd")
const ButtonConfigLoader = preload("res://ui/configs/loaders/aero_ui_glass_primary_button_config_loader.gd")

const PRESET_SECTION_PANEL := "panel"
const PRESET_SECTION_BADGE := "badge"
const PRESET_SECTION_BUTTON := "button"
const INFO_PANEL_MIN_WIDTH := 440.0
const SECTION_SPACER_HEIGHT := 56.0

const BADGE_EDITOR_CONTROLS := [
	{"name": "badge_base_fill_alpha", "label": "fill_alpha", "min": 0.0, "max": 1.0, "step": 0.01, "default": 0.08},
	{"name": "badge_base_border_alpha", "label": "border_alpha", "min": 0.0, "max": 1.0, "step": 0.01, "default": 0.14},
	{"name": "badge_base_label_alpha", "label": "label_alpha", "min": 0.0, "max": 1.0, "step": 0.01, "default": 0.78},
]

const BADGE_EDITOR_COLOR_CONTROLS := [
	{"name": "badge_tint", "label": "tint", "default": Color(0.92, 0.96, 1.0, 1.0)},
]

const BUTTON_EDITOR_CONTROLS := [
	{"name": "button_source_label_alpha", "label": "label_alpha", "min": 0.0, "max": 1.0, "step": 0.01, "default": 0.95},
	{"name": "button_source_meta_alpha", "label": "meta_alpha", "min": 0.0, "max": 1.0, "step": 0.01, "default": 0.66},
	{"name": "button_border_width", "label": "border_width", "min": 0.0, "max": 8.0, "step": 1.0, "default": 2.0},
	{"name": "button_radius_delta", "label": "radius_delta", "min": 0.0, "max": 16.0, "step": 1.0, "default": 5.0},
	{"name": "button_source_hover_tint_strength", "label": "hover_tint_strength", "min": 0.0, "max": 1.0, "step": 0.01, "default": 0.34},
	{"name": "button_source_hover_scale", "label": "hover_scale", "min": 0.9, "max": 1.1, "step": 0.001, "default": 1.01},
	{"name": "button_source_hover_speed", "label": "hover_speed", "min": 0.0, "max": 0.4, "step": 0.01, "default": 0.12},
	{"name": "button_source_pressed_tint_strength", "label": "pressed_tint_strength", "min": 0.0, "max": 1.0, "step": 0.01, "default": 0.72},
	{"name": "button_source_pressed_scale", "label": "pressed_scale", "min": 0.9, "max": 1.1, "step": 0.001, "default": 0.988},
	{"name": "button_source_pressed_speed", "label": "pressed_speed", "min": 0.0, "max": 0.4, "step": 0.01, "default": 0.08},
]

const BUTTON_EDITOR_OPTION_CONTROLS := [
	{"name": "button_source_hover_ease_type", "label": "hover_ease_type", "default": "smooth", "options": [{"label": "Smooth", "value": "smooth"}, {"label": "Linear", "value": "linear"}, {"label": "Snappy", "value": "snappy"}, {"label": "Soft", "value": "soft"}, {"label": "Crisp", "value": "crisp"}]},
	{"name": "button_source_pressed_ease_type", "label": "pressed_ease_type", "default": "snappy", "options": [{"label": "Smooth", "value": "smooth"}, {"label": "Linear", "value": "linear"}, {"label": "Snappy", "value": "snappy"}, {"label": "Soft", "value": "soft"}, {"label": "Crisp", "value": "crisp"}]},
]

const BUTTON_EDITOR_COLOR_CONTROLS := [
	{"name": "button_background_tint", "label": "background_tint", "default": Color(0.92, 0.96, 1.0, 1.0)},
	{"name": "button_interaction_tint", "label": "interaction_tint", "default": Color(0.4, 0.82, 1.0, 1.0)},
]

@onready var split_root: HSplitContainer = get_node_or_null("SplitRoot") as HSplitContainer
@onready var controls_panel: PanelContainer = get_node_or_null("SplitRoot/ControlsPanel") as PanelContainer
@onready var controls_list: VBoxContainer = get_node_or_null("SplitRoot/ControlsPanel/Margin/ControlsColumn/ControlsScroll/ControlsList") as VBoxContainer
@onready var panel_view_host: Control = get_node_or_null("SplitRoot/PreviewArea/PreviewCenter/PanelSourceHost") as Control
@onready var interaction_bus: AeroUiInteractionBus = get_node_or_null("SplitRoot/PreviewArea/PreviewCenter/PanelSourceHost/AeroUiInteractionBus") as AeroUiInteractionBus
@onready var screen_input_adapter: ScreenUiInputAdapter = get_node_or_null("SplitRoot/PreviewArea/PreviewCenter/PanelSourceHost/ScreenUiInputAdapter") as ScreenUiInputAdapter

var _panel_view: AeroUiGlassPanelView
var _proof_button: Control
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
var _mouse_hover_active: bool:
	get:
		return _is_native_hover_active()
var _last_pointer_screen_position := Vector2.ZERO
var _last_forwarded_panel_event := "waiting for normalized panel input"
var _last_contract_phase := "waiting"
var _last_contract_source_variant := "waiting"
var _last_contract_surface_id := String(SCREEN_SURFACE_ID)
var _last_contract_verification_status := "waiting"
var _last_contract_verification_notes := "No normalized interaction published yet."
var _last_contract_target_path := ""


func _ready() -> void:
	_configure_info_panel_layout()
	_mount_panel_view()
	_ensure_interaction_contract_nodes()
	_configure_panel_view_contract()
	_rewire_native_2d_bridge()
	_build_controls()
	_setup_preset_dialogs()
	call_deferred("_sync_controls_from_panel")
	call_deferred("_refresh_contract_status")


func _input(event: InputEvent) -> void:
	if _forward_native_bridge_fallback(event):
		get_viewport().set_input_as_handled()
		_refresh_contract_status()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_MOUSE_EXIT:
		_publish_native_hover_clear("window_mouse_exit")


func _configure_info_panel_layout() -> void:
	if is_instance_valid(controls_panel):
		controls_panel.custom_minimum_size.x = INFO_PANEL_MIN_WIDTH
	if is_instance_valid(split_root):
		split_root.split_offset = int(INFO_PANEL_MIN_WIDTH)


func set_background_mode(mode: int) -> void:
	if is_instance_valid(_panel_view):
		_panel_view.set_background_mode(mode)
	if is_instance_valid(_background_mode_selector):
		_select_background_mode(mode)


func get_background_mode() -> int:
	if is_instance_valid(_panel_view):
		return _panel_view.get_background_mode()
	return PanelViewScript.DEFAULT_BACKGROUND_MODE


func set_shader_parameter(parameter_name: String, value: Variant) -> void:
	if is_instance_valid(_panel_view):
		_panel_view.set_shader_parameter(parameter_name, value)
	_sync_single_control_from_panel(parameter_name)


func get_shader_parameter(parameter_name: String) -> Variant:
	if is_instance_valid(_panel_view):
		return _panel_view.get_shader_parameter(parameter_name)
	return null


func _mount_panel_view() -> void:
	_detach_contract_nodes_from_panel_view()
	if is_instance_valid(_panel_view):
		_panel_view.queue_free()
		_panel_view = null
	_proof_button = null

	var packed: PackedScene = load(PANEL_VIEW_SCENE_PATH)
	if packed == null:
		push_error("Failed to load AeroUiGlassPanelView scene: %s" % PANEL_VIEW_SCENE_PATH)
		return

	_panel_view = packed.instantiate() as AeroUiGlassPanelView
	if _panel_view == null:
		push_error("AeroUiGlassPanelView scene did not instantiate as a Control root.")
		return

	panel_view_host.add_child(_panel_view)
	_panel_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_proof_button = _panel_view.get_node_or_null(PREVIEW_BUTTON_PATH) as Control
	_attach_contract_nodes_to_proof_button()
	_rewire_native_2d_bridge()


func _detach_contract_nodes_from_panel_view() -> void:
	for contract_node in [screen_input_adapter, interaction_bus]:
		if not is_instance_valid(contract_node):
			continue
		var parent: Node = contract_node.get_parent()
		if parent != null and parent != panel_view_host:
			parent.remove_child(contract_node)
			panel_view_host.add_child(contract_node)


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
	# Consumer-side reference seam only:
	# this scene wires the proof card to the shared input-core contract objects, while
	# reusable contract ownership stays in aerobeat-input-core and consumer binding
	# behavior stays in aerobeat-ui-core.
	if interaction_bus == null:
		interaction_bus = AeroUiInteractionBus.new()
		interaction_bus.name = "AeroUiInteractionBus"
		panel_view_host.add_child(interaction_bus)
	if screen_input_adapter == null:
		screen_input_adapter = ScreenUiInputAdapter.new()
		screen_input_adapter.name = "ScreenUiInputAdapter"
		panel_view_host.add_child(screen_input_adapter)

	screen_input_adapter.bus_path = interaction_bus.get_path()
	screen_input_adapter.surface_id = SCREEN_SURFACE_ID
	screen_input_adapter.surface_type = SCREEN_SURFACE_TYPE
	screen_input_adapter.drag_threshold_pixels = 12.0
	screen_input_adapter.emit_hover_events = true
	# This proof scene publishes only through its native 2D bridge callbacks.
	# Leaving the adapter's own global _input subscription enabled lets unrelated
	# viewport clicks (for example, the left controls panel scrollbar) mutate the
	# adapter press state and confuse the proof-host fallback ownership checks.
	screen_input_adapter.set_process_input(false)
	_attach_contract_nodes_to_proof_button()

	if not interaction_bus.interaction_event.is_connected(_on_contract_interaction_event):
		interaction_bus.interaction_event.connect(_on_contract_interaction_event)


func _configure_panel_view_contract() -> void:
	if not is_instance_valid(_panel_view):
		return
	if is_instance_valid(interaction_bus):
		_panel_view.set_interaction_bus_path(interaction_bus.get_path())
	_panel_view.configure_interaction_contract({
		"surface_id": SCREEN_SURFACE_ID,
		"surface_type_label": String(SCREEN_SURFACE_TYPE),
		"mode_label": "Screen contract proof",
		"host_summary": "Native 2D Control truth now feeds AeroUiInteractionBus through ScreenUiInputAdapter. This host only relays native target and empty-target transition events instead of owning manual hover / press capture.",
	})


func _rewire_native_2d_bridge() -> void:
	if not is_instance_valid(_proof_button):
		return
	var gui_input_callable := Callable(self, "_on_proof_button_gui_input")
	if not _proof_button.gui_input.is_connected(gui_input_callable):
		_proof_button.gui_input.connect(gui_input_callable)
	var mouse_enter_callable := Callable(self, "_on_proof_button_mouse_entered")
	if not _proof_button.mouse_entered.is_connected(mouse_enter_callable):
		_proof_button.mouse_entered.connect(mouse_enter_callable)
	var mouse_exit_callable := Callable(self, "_on_proof_button_mouse_exited")
	if not _proof_button.mouse_exited.is_connected(mouse_exit_callable):
		_proof_button.mouse_exited.connect(mouse_exit_callable)


func _on_proof_button_gui_input(event: InputEvent) -> void:
	if _publish_native_targeted_event(event):
		get_viewport().set_input_as_handled()
		_refresh_contract_status()


func _on_proof_button_mouse_entered() -> void:
	_publish_native_hover_enter("mouse_entered")


func _on_proof_button_mouse_exited() -> void:
	if _has_native_mouse_press_owner():
		return
	_publish_native_hover_clear("mouse_exited")


func _publish_native_targeted_event(event: InputEvent) -> bool:
	if screen_input_adapter == null or not is_instance_valid(_proof_button):
		return false
	var normalized_event := _normalize_proof_button_gui_input_event(event)
	_remember_pointer_position(normalized_event)
	var published := _publish_to_screen_adapter(
		normalized_event,
		_native_bridge_metadata({
			"target_resolution": "native_control_bridge",
			"native_control_event": "gui_input",
			"native_control_coordinates": "control_local_to_viewport",
		}),
		_proof_button.get_path()
	)
	if not published:
		return false
	_last_forwarded_panel_event = "native target publish -> %s" % _describe_input_event(event)
	return true


func _normalize_proof_button_gui_input_event(event: InputEvent) -> InputEvent:
	if not is_instance_valid(_proof_button):
		return event
	if event is InputEventMouseMotion:
		var normalized_motion := (event as InputEventMouseMotion).duplicate() as InputEventMouseMotion
		normalized_motion.position = _proof_button.get_global_transform_with_canvas() * event.position
		return normalized_motion
	if event is InputEventMouseButton:
		var normalized_button := (event as InputEventMouseButton).duplicate() as InputEventMouseButton
		normalized_button.position = _proof_button.get_global_transform_with_canvas() * event.position
		return normalized_button
	return event


func _forward_native_bridge_fallback(event: InputEvent) -> bool:
	if screen_input_adapter == null or not is_instance_valid(_proof_button):
		return false
	if event is InputEventMouseMotion:
		return _publish_native_mouse_motion_fallback(event)
	if event is InputEventMouseButton:
		return _publish_native_mouse_button_fallback(event)
	if event is InputEventScreenDrag:
		return _publish_native_touch_drag_fallback(event)
	if event is InputEventScreenTouch:
		return _publish_native_touch_release_fallback(event)
	return false


func _publish_native_mouse_motion_fallback(event: InputEventMouseMotion) -> bool:
	if not _has_native_mouse_press_owner() or _is_screen_position_inside_proof_button(event.position):
		return false
	_remember_pointer_position(event)
	var published := _publish_to_screen_adapter(event, _native_bridge_metadata({
		"target_resolution": "native_control_bridge",
		"native_control_transition": "off_target_motion",
	}), NodePath())
	if not published:
		return false
	_last_forwarded_panel_event = "native empty-target publish -> %s" % _describe_input_event(event)
	return true


func _publish_native_mouse_button_fallback(event: InputEventMouseButton) -> bool:
	if event.button_index != MOUSE_BUTTON_LEFT:
		return false
	if event.pressed or not _has_native_mouse_press_owner():
		return false
	_remember_pointer_position(event)
	var published := _publish_to_screen_adapter(event, _native_bridge_metadata({
		"target_resolution": "native_control_bridge",
		"native_control_transition": "off_target_release",
	}), NodePath())
	if not published:
		return false
	if _is_native_hover_active():
		_publish_native_hover_clear("off_target_release_cleanup")
	_last_forwarded_panel_event = "native empty-target publish -> %s" % _describe_input_event(event)
	return true


func _publish_native_touch_drag_fallback(event: InputEventScreenDrag) -> bool:
	if not _has_native_touch_owner(event.index):
		return false
	if _is_screen_position_inside_proof_button(event.position):
		return false
	_remember_pointer_position(event)
	var published := _publish_to_screen_adapter(event, _native_bridge_metadata({
		"target_resolution": "native_control_bridge",
		"native_control_transition": "off_target_drag",
	}), NodePath())
	if not published:
		return false
	_last_forwarded_panel_event = "native empty-target publish -> %s" % _describe_input_event(event)
	return true


func _publish_native_touch_release_fallback(event: InputEventScreenTouch) -> bool:
	if event.pressed or not _has_native_touch_owner(event.index):
		return false
	if _is_screen_position_inside_proof_button(event.position):
		return false
	_remember_pointer_position(event)
	var published := _publish_to_screen_adapter(event, _native_bridge_metadata({
		"target_resolution": "native_control_bridge",
		"native_control_transition": "off_target_release",
	}), NodePath())
	if not published:
		return false
	_last_forwarded_panel_event = "native empty-target publish -> %s" % _describe_input_event(event)
	return true


func _publish_native_hover_enter(reason: String) -> void:
	if screen_input_adapter == null or not is_instance_valid(_proof_button):
		return
	if _is_native_hover_active():
		return
	var hover_enter := _create_synthetic_hover_motion_event()
	if _publish_to_screen_adapter(hover_enter, _native_bridge_metadata({
		"target_resolution": "native_control_bridge",
		"synthetic_hover_enter": true,
		"native_control_transition": reason,
	}), _proof_button.get_path()):
		_last_forwarded_panel_event = "native target publish -> synthetic hover enter (%s)" % reason
		_refresh_contract_status()


func _publish_native_hover_clear(reason: String) -> void:
	if screen_input_adapter == null or not is_instance_valid(_proof_button):
		return
	if not _is_native_hover_active() and not _has_native_mouse_press_owner():
		return
	var hover_exit := _create_synthetic_hover_motion_event()
	if reason == "window_mouse_exit":
		hover_exit.position = Vector2(-1.0, -1.0)
	if _publish_to_screen_adapter(hover_exit, _native_bridge_metadata({
		"target_resolution": "native_control_bridge",
		"synthetic_hover_exit": true,
		"native_control_transition": reason,
	}), NodePath()):
		_last_forwarded_panel_event = "native empty-target publish -> synthetic hover exit (%s)" % reason
		_refresh_contract_status()


func _create_synthetic_hover_motion_event() -> InputEventMouseMotion:
	var hover_event := InputEventMouseMotion.new()
	hover_event.position = _resolve_native_hover_screen_position()
	hover_event.relative = Vector2.ZERO
	return hover_event


func _resolve_native_hover_screen_position() -> Vector2:
	if is_instance_valid(_proof_button):
		var pointer_position := get_viewport().get_mouse_position()
		if _is_screen_position_inside_proof_button(pointer_position):
			return pointer_position
		return _proof_button.get_global_rect().get_center()
	return _last_pointer_screen_position


func _publish_to_screen_adapter(event: InputEvent, metadata: Dictionary = {}, target_path: NodePath = NodePath()) -> bool:
	if screen_input_adapter == null or not is_instance_valid(_proof_button):
		return false
	var merged_metadata := metadata.duplicate(true)
	merged_metadata["respect_empty_target_path"] = true
	return screen_input_adapter.publish_input_event(event, target_path, merged_metadata)


func _native_bridge_metadata(extra_metadata: Dictionary = {}) -> Dictionary:
	var metadata := {
		"host_surface": "screen_2d_native_button",
		"bridge_lane": "native_2d",
	}
	for key in extra_metadata.keys():
		metadata[key] = extra_metadata[key]
	return metadata


func _publish_mouse_motion_to_contract(event: InputEventMouseMotion) -> bool:
	if _is_screen_position_inside_proof_button(event.position):
		return _publish_native_targeted_event(event)
	return _publish_native_mouse_motion_fallback(event)


func _publish_mouse_button_to_contract(event: InputEventMouseButton) -> bool:
	if _is_screen_position_inside_proof_button(event.position):
		return _publish_native_targeted_event(event)
	return _publish_native_mouse_button_fallback(event)


func _publish_screen_touch_to_contract(event: InputEventScreenTouch) -> bool:
	if event.pressed and _is_screen_position_inside_proof_button(event.position):
		return _publish_native_targeted_event(event)
	return _publish_native_touch_release_fallback(event)


func _publish_screen_drag_to_contract(event: InputEventScreenDrag) -> bool:
	if _is_screen_position_inside_proof_button(event.position):
		return _publish_native_targeted_event(event)
	return _publish_native_touch_drag_fallback(event)


func _get_native_hover_pointer_state() -> Dictionary:
	if screen_input_adapter == null:
		return {}
	return screen_input_adapter._pointer_states.get(screen_input_adapter._hover_pointer_id, {})


func _native_mouse_state_targets_proof_button(pointer_state: Dictionary) -> bool:
	if not is_instance_valid(_proof_button):
		return false
	var proof_button_path: NodePath = _proof_button.get_path()
	if proof_button_path == NodePath():
		return false
	for candidate_key: StringName in [&"owner_target_path", &"target_path", &"hover_target_path"]:
		var candidate: NodePath = pointer_state.get(candidate_key, NodePath()) as NodePath
		if candidate == proof_button_path:
			return true
	return false


func _is_native_hover_active() -> bool:
	var pointer_state := _get_native_hover_pointer_state()
	return bool(pointer_state.get("hovering", false)) and _native_mouse_state_targets_proof_button(pointer_state)


func _has_native_mouse_press_owner() -> bool:
	var pointer_state := _get_native_hover_pointer_state()
	return bool(pointer_state.get("pressed", false)) and _native_mouse_state_targets_proof_button(pointer_state)


func _has_native_touch_owner(pointer_index: int) -> bool:
	if screen_input_adapter == null:
		return false
	var pointer_id := StringName("touch_%s" % pointer_index)
	return screen_input_adapter._pointer_states.has(pointer_id) \
		and bool(screen_input_adapter._pointer_states[pointer_id].get("pressed", false))


func _remember_pointer_position(event: InputEvent) -> void:
	if event is InputEventMouseButton or event is InputEventMouseMotion or event is InputEventScreenTouch or event is InputEventScreenDrag:
		_last_pointer_screen_position = event.position


func _is_screen_position_inside_proof_button(screen_position: Vector2) -> bool:
	if not is_instance_valid(_proof_button):
		return false
	return _proof_button.get_global_rect().has_point(screen_position)


func _describe_input_event(event: InputEvent) -> String:
	if event is InputEventMouseMotion:
		return "mouse motion"
	if event is InputEventMouseButton:
		return "mouse %s" % ("press" if event.pressed else "release")
	if event is InputEventScreenDrag:
		return "touch drag #%d" % event.index
	if event is InputEventScreenTouch:
		return "touch %s #%d" % [("press" if event.pressed else "release"), event.index]
	return event.get_class()


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

	_refresh_contract_status()


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
	]))
	_append_controls_section(_make_section_block("badge", [
		_make_yaml_actions_block("", PRESET_SECTION_BADGE, "Badge component YAML."),
		_make_parameter_section("live badge values", BADGE_EDITOR_CONTROLS, BADGE_EDITOR_COLOR_CONTROLS),
	]))
	_append_controls_section(_make_section_block("primary button", [
		_make_yaml_actions_block("", PRESET_SECTION_BUTTON, "Primary button component YAML."),
		_make_parameter_section("live button values", BUTTON_EDITOR_CONTROLS, BUTTON_EDITOR_COLOR_CONTROLS, BUTTON_EDITOR_OPTION_CONTROLS),
	]))
	_append_controls_section(_make_section_block("input debug", [
		_make_contract_status_block(),
	]), false)

	var tail_spacer := Control.new()
	tail_spacer.custom_minimum_size = Vector2(0.0, 8.0)
	controls_list.add_child(tail_spacer)

	_refresh_contract_status()


func _make_contract_status_block() -> Control:
	var wrapper := VBoxContainer.new()
	wrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var status := RichTextLabel.new()
	status.fit_content = true
	status.scroll_active = false
	status.bbcode_enabled = false
	status.custom_minimum_size = Vector2(0.0, 164.0)
	status.modulate = Color(1.0, 1.0, 1.0, 0.86)
	wrapper.add_child(status)
	_contract_status_label = status

	return wrapper


func _append_controls_section(section: Control, include_spacer: bool = true) -> void:
	controls_list.add_child(section)
	if include_spacer:
		var spacer := Control.new()
		spacer.custom_minimum_size = Vector2(0.0, SECTION_SPACER_HEIGHT)
		controls_list.add_child(spacer)


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


func _make_section_block(title_text: String, blocks: Array) -> Control:
	var wrapper := VBoxContainer.new()
	wrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wrapper.add_theme_constant_override("separation", 8)

	var title := Label.new()
	title.text = title_text
	wrapper.add_child(title)

	for block in blocks:
		if block is Control:
			wrapper.add_child(block)

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


func _on_option_value_selected(index: int, parameter_name: String, selector: OptionButton) -> void:
	var value := str(selector.get_item_metadata(index))
	_set_live_control_value(parameter_name, value)


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
	status.text = "Panel, badge, and primary button each load or export their authored YAML directly."
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
	set_background_mode(selector.get_item_id(index))


func _on_float_value_changed(value: float, parameter_name: String, slider: HSlider) -> void:
	_set_live_control_value(parameter_name, value)
	var value_label: Label = slider.get_meta("value_label") as Label
	if value_label:
		value_label.text = _format_float(value)


func _on_color_value_changed(color: Color, parameter_name: String) -> void:
	set_shader_parameter(parameter_name, color)


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
			return "2d-glass-shader.default.badge.yaml"
		PRESET_SECTION_BUTTON:
			return "2d-glass-shader.default.button.yaml"
		_:
			return "2d-glass-shader.default.yaml"


func _export_dialog_title(section_key: String) -> String:
	match section_key:
		PRESET_SECTION_BADGE:
			return "Export AeroUiGlass Badge YAML"
		PRESET_SECTION_BUTTON:
			return "Export AeroUiGlass Primary Button YAML"
		_:
			return "Export AeroUiGlass Panel YAML"


func _load_dialog_title(section_key: String) -> String:
	match section_key:
		PRESET_SECTION_BADGE:
			return "Load AeroUiGlass Badge YAML"
		PRESET_SECTION_BUTTON:
			return "Load AeroUiGlass Primary Button YAML"
		_:
			return "Load AeroUiGlass Panel YAML"


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
	if not is_instance_valid(_panel_view):
		_set_preset_status("Panel view is not ready for YAML export.", true)
		return

	var panel_config := _panel_view.get_panel_style_config()
	var badge_config := _panel_view.get_badge_style_config()
	var button_config := _panel_view.get_primary_button_style_config()
	var panel_shader_parameters := _panel_view.get_shader_parameters()
	var result := YamlBundleIO.export_panel_bundle(path, {
		"panel_config": panel_config,
		"badge_config": badge_config,
		"button_config": button_config,
		"panel_shader_parameters": panel_shader_parameters,
	})
	if result.get("ok", false):
		_set_preset_status("Saved panel YAML to %s" % result["path"], false)
	else:
		_set_preset_status(str(result.get("error", "Failed to save panel YAML.")), true)


func _load_panel_yaml_from_path(path: String) -> void:
	if not is_instance_valid(_panel_view):
		_set_preset_status("Panel view is not ready for YAML import.", true)
		return

	var panel_config := _panel_view.load_panel_style_bundle_from_path(path)
	if panel_config == null or panel_config.source_path == "":
		_set_preset_status("Failed to load panel YAML from %s" % path, true)
		return

	call_deferred("_sync_controls_from_panel")
	_set_preset_status("Loaded panel YAML from %s" % panel_config.source_path, false)


func _export_badge_yaml_to_path(path: String) -> void:
	if not is_instance_valid(_panel_view):
		_set_preset_status("Panel view is not ready for badge YAML export.", true)
		return
	var badge_config = _panel_view.get_badge_style_config()
	if badge_config == null:
		_set_preset_status("Badge config is not ready for YAML export.", true)
		return
	var result := _write_yaml_section_document(path, YamlBundleIO._build_badge_document(badge_config, {}))
	if result.get("ok", false):
		_set_preset_status("Saved badge YAML to %s" % result["path"], false)
	else:
		_set_preset_status(str(result.get("error", "Failed to save badge YAML.")), true)


func _load_badge_yaml_from_path(path: String) -> void:
	if not is_instance_valid(_panel_view):
		_set_preset_status("Panel view is not ready for badge YAML import.", true)
		return
	var badge_config = BadgeConfigLoader.load_from_path(path)
	if badge_config == null or badge_config.source_path == "":
		_set_preset_status("Failed to load badge YAML from %s" % path, true)
		return
	_apply_badge_config_to_panel_view(_panel_view, badge_config)
	_set_preset_status("Loaded badge YAML from %s" % badge_config.source_path, false)


func _export_button_yaml_to_path(path: String) -> void:
	if not is_instance_valid(_panel_view):
		_set_preset_status("Panel view is not ready for button YAML export.", true)
		return
	var button_config = _panel_view.get_primary_button_style_config()
	if button_config == null:
		_set_preset_status("Primary button config is not ready for YAML export.", true)
		return
	var result := _write_yaml_section_document(path, YamlBundleIO._build_button_document(button_config, {}))
	if result.get("ok", false):
		_set_preset_status("Saved primary button YAML to %s" % result["path"], false)
	else:
		_set_preset_status(str(result.get("error", "Failed to save primary button YAML.")), true)


func _load_button_yaml_from_path(path: String) -> void:
	if not is_instance_valid(_panel_view):
		_set_preset_status("Panel view is not ready for button YAML import.", true)
		return
	var button_config = ButtonConfigLoader.load_from_path(path)
	if button_config == null or button_config.source_path == "":
		_set_preset_status("Failed to load primary button YAML from %s" % path, true)
		return
	_apply_button_config_to_panel_view(_panel_view, button_config)
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


func _apply_badge_config_to_panel_view(panel_view: AeroUiGlassPanelView, badge_config) -> void:
	if panel_view == null or badge_config == null:
		return
	panel_view._badge_style_config = badge_config
	if panel_view._panel_style_config != null:
		panel_view._panel_style_config.badge_config = badge_config
		panel_view._panel_style_config.badge_preset_path = badge_config.source_path
	if is_instance_valid(panel_view.badge_view):
		panel_view.badge_view.set_badge_config(badge_config)
	var is_hybrid_world := panel_view.get_presentation_mode() == panel_view.PRESENTATION_MODE_HYBRID_WORLD_SPACE
	panel_view._refresh_badge_visual(is_hybrid_world)
	panel_view._refresh_primary_action_visual()


func _apply_button_config_to_panel_view(panel_view: AeroUiGlassPanelView, button_config) -> void:
	if panel_view == null or button_config == null:
		return
	panel_view._primary_button_style_config = button_config
	if panel_view._panel_style_config != null:
		panel_view._panel_style_config.primary_button_config = button_config
		panel_view._panel_style_config.primary_button_preset_path = button_config.source_path
	panel_view._refresh_primary_action_visual()


func _get_live_control_value(parameter_name: String) -> Variant:
	match parameter_name:
		"badge_base_fill_alpha":
			return _panel_view.get_badge_style_config().base_fill_alpha if is_instance_valid(_panel_view) and _panel_view.get_badge_style_config() != null else null
		"badge_base_border_alpha":
			return _panel_view.get_badge_style_config().base_border_alpha if is_instance_valid(_panel_view) and _panel_view.get_badge_style_config() != null else null
		"badge_base_label_alpha":
			return _panel_view.get_badge_style_config().base_label_alpha if is_instance_valid(_panel_view) and _panel_view.get_badge_style_config() != null else null
		"badge_tint":
			return _panel_view.get_badge_style_config().tint if is_instance_valid(_panel_view) and _panel_view.get_badge_style_config() != null else null
		"button_source_label_alpha":
			return _panel_view.get_primary_button_style_config().source_label_alpha if is_instance_valid(_panel_view) and _panel_view.get_primary_button_style_config() != null else null
		"button_source_meta_alpha":
			return _panel_view.get_primary_button_style_config().source_meta_alpha if is_instance_valid(_panel_view) and _panel_view.get_primary_button_style_config() != null else null
		"button_border_width":
			return float(_panel_view.get_primary_button_style_config().border_width) if is_instance_valid(_panel_view) and _panel_view.get_primary_button_style_config() != null else null
		"button_radius_delta":
			return float(_panel_view.get_primary_button_style_config().radius_delta) if is_instance_valid(_panel_view) and _panel_view.get_primary_button_style_config() != null else null
		"button_background_tint":
			return _panel_view.get_primary_button_style_config().background_tint if is_instance_valid(_panel_view) and _panel_view.get_primary_button_style_config() != null else null
		"button_interaction_tint":
			return _panel_view.get_primary_button_style_config().interaction_tint if is_instance_valid(_panel_view) and _panel_view.get_primary_button_style_config() != null else null
		"button_source_hover_tint_strength":
			return _panel_view.get_primary_button_style_config().source_states.get("hover", {}).get("tint_strength", 0.0) if is_instance_valid(_panel_view) and _panel_view.get_primary_button_style_config() != null else null
		"button_source_pressed_tint_strength":
			return _panel_view.get_primary_button_style_config().source_states.get("pressed", {}).get("tint_strength", 0.0) if is_instance_valid(_panel_view) and _panel_view.get_primary_button_style_config() != null else null
		"button_source_hover_scale":
			return _panel_view.get_primary_button_style_config().source_states.get("hover", {}).get("scale", 1.0) if is_instance_valid(_panel_view) and _panel_view.get_primary_button_style_config() != null else null
		"button_source_hover_speed":
			return _panel_view.get_primary_button_style_config().source_interactions.get("hover", {}).get("speed", 0.12) if is_instance_valid(_panel_view) and _panel_view.get_primary_button_style_config() != null else null
		"button_source_hover_ease_type":
			return _panel_view.get_primary_button_style_config().source_interactions.get("hover", {}).get("ease_type", "smooth") if is_instance_valid(_panel_view) and _panel_view.get_primary_button_style_config() != null else null
		"button_source_pressed_scale":
			return _panel_view.get_primary_button_style_config().source_states.get("pressed", {}).get("scale", 1.0) if is_instance_valid(_panel_view) and _panel_view.get_primary_button_style_config() != null else null
		"button_source_pressed_speed":
			return _panel_view.get_primary_button_style_config().source_interactions.get("pressed", {}).get("speed", 0.08) if is_instance_valid(_panel_view) and _panel_view.get_primary_button_style_config() != null else null
		"button_source_pressed_ease_type":
			return _panel_view.get_primary_button_style_config().source_interactions.get("pressed", {}).get("ease_type", "snappy") if is_instance_valid(_panel_view) and _panel_view.get_primary_button_style_config() != null else null
		_:
			return get_shader_parameter(parameter_name)


func _set_live_control_value(parameter_name: String, value: Variant) -> void:
	match parameter_name:
		"badge_base_fill_alpha", "badge_base_border_alpha", "badge_base_label_alpha", "badge_tint":
			var badge_config = _panel_view.get_badge_style_config() if is_instance_valid(_panel_view) else null
			if badge_config == null:
				return
			match parameter_name:
				"badge_base_fill_alpha":
					badge_config.base_fill_alpha = float(value)
				"badge_base_border_alpha":
					badge_config.base_border_alpha = float(value)
				"badge_base_label_alpha":
					badge_config.base_label_alpha = float(value)
				"badge_tint":
					badge_config.tint = value if value is Color else badge_config.tint
			_apply_badge_config_to_panel_view(_panel_view, badge_config)
		"button_source_label_alpha", "button_source_meta_alpha", "button_border_width", "button_radius_delta", "button_background_tint", "button_interaction_tint", "button_source_hover_tint_strength", "button_source_pressed_tint_strength", "button_source_hover_scale", "button_source_hover_speed", "button_source_hover_ease_type", "button_source_pressed_scale", "button_source_pressed_speed", "button_source_pressed_ease_type":
			var button_config = _panel_view.get_primary_button_style_config() if is_instance_valid(_panel_view) else null
			if button_config == null:
				return
			match parameter_name:
				"button_source_label_alpha":
					button_config.source_label_alpha = float(value)
				"button_source_meta_alpha":
					button_config.source_meta_alpha = float(value)
				"button_border_width":
					button_config.border_width = int(round(float(value)))
				"button_radius_delta":
					button_config.radius_delta = int(round(float(value)))
				"button_background_tint":
					button_config.background_tint = value if value is Color else button_config.background_tint
				"button_interaction_tint":
					button_config.interaction_tint = value if value is Color else button_config.interaction_tint
				"button_source_hover_tint_strength":
					button_config.source_states["hover"]["tint_strength"] = float(value)
				"button_source_pressed_tint_strength":
					button_config.source_states["pressed"]["tint_strength"] = float(value)
				"button_source_hover_scale":
					button_config.source_states["hover"]["scale"] = float(value)
				"button_source_hover_speed":
					button_config.source_interactions["hover"]["speed"] = float(value)
				"button_source_hover_ease_type":
					button_config.source_interactions["hover"]["ease_type"] = str(value)
				"button_source_pressed_scale":
					button_config.source_states["pressed"]["scale"] = float(value)
				"button_source_pressed_speed":
					button_config.source_interactions["pressed"]["speed"] = float(value)
				"button_source_pressed_ease_type":
					button_config.source_interactions["pressed"]["ease_type"] = str(value)
			_apply_button_config_to_panel_view(_panel_view, button_config)
		_:
			set_shader_parameter(parameter_name, value)


func _set_preset_status(message: String, is_error: bool) -> void:
	if not is_instance_valid(_preset_status_label):
		return
	_preset_status_label.text = message
	_preset_status_label.modulate = Color(1.0, 0.72, 0.72, 0.95) if is_error else Color(1.0, 1.0, 1.0, 0.68)


func _sync_controls_from_panel() -> void:
	_select_background_mode(get_background_mode())
	for config in PanelViewScript.FLOAT_CONTROLS:
		_sync_single_control_from_panel(str(config["name"]))
	for config in PanelViewScript.COLOR_CONTROLS:
		_sync_single_control_from_panel(str(config["name"]))
	for config in BADGE_EDITOR_CONTROLS:
		_sync_single_control_from_panel(str(config["name"]))
	for config in BADGE_EDITOR_COLOR_CONTROLS:
		_sync_single_control_from_panel(str(config["name"]))
	for config in BUTTON_EDITOR_CONTROLS:
		_sync_single_control_from_panel(str(config["name"]))
	for config in BUTTON_EDITOR_COLOR_CONTROLS:
		_sync_single_control_from_panel(str(config["name"]))
	for config in BUTTON_EDITOR_OPTION_CONTROLS:
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


func _refresh_contract_status() -> void:
	if not is_instance_valid(_contract_status_label):
		return

	_contract_status_label.text = "Hovered target: %s\nInteraction state: %s" % [
		_get_hovered_target_debug_text(),
		_get_interaction_state_debug_text(),
	]


func _get_hovered_target_debug_text() -> String:
	if not is_instance_valid(_panel_view):
		return "none"

	for binding_variant in _panel_view.get_contract_target_bindings():
		var binding := binding_variant as AeroUiContractTargetBinding
		if binding == null or not binding.is_hovered:
			continue
		return _display_debug_target_name(binding)
	return "none"


func _get_interaction_state_debug_text() -> String:
	if not is_instance_valid(_panel_view):
		return "idle"

	for binding_variant in _panel_view.get_contract_target_bindings():
		var binding := binding_variant as AeroUiContractTargetBinding
		if binding == null:
			continue
		if binding.is_pressed:
			return "pressed"
		if binding.is_hovered:
			return "hover"
	return "idle"


func _display_debug_target_name(binding: AeroUiContractTargetBinding) -> String:
	if binding == null:
		return "none"
	if not binding.target_label.is_empty():
		return binding.target_label
	if binding.control != null:
		return binding.control.name
	return binding.target_key if not binding.target_key.is_empty() else "none"


func _join_string_array(values: Array) -> String:
	var parts: PackedStringArray = []
	for value in values:
		parts.append(str(value))
	return ", ".join(parts)


func _format_float(value: float) -> String:
	return "%0.2f" % value
