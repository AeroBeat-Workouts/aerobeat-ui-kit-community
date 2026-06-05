extends Node3D

const PANEL_VIEW_SCENE := preload("res://ui/views/screen_2d_glass_panel_view.tscn")
const BUS_SCRIPT := preload("res://addons/aerobeat-input-core/src/ui/ui_interaction_bus.gd")
const ADAPTER_SCRIPT := preload("res://addons/aerobeat-input-core/src/ui/adapters/xr_ui_input_adapter.gd")
const SURFACE_DESCRIPTOR_SCRIPT := preload("res://addons/aerobeat-spatial-ui-core/src/helpers/surfaces/aero_spatial_surface_descriptor.gd")
const PROJECTION_HELPER_SCRIPT := preload("res://addons/aerobeat-spatial-ui-core/src/helpers/providers/aero_spatial_projection_helper.gd")
const XR_PROVIDER_SCRIPT := preload("res://addons/aerobeat-spatial-ui-xr/src/providers/xr/aero_spatial_ui_xr_provider.gd")
const XR_PROVIDER_CONFIG_SCRIPT := preload("res://addons/aerobeat-spatial-ui-xr/src/providers/xr/aero_spatial_ui_xr_provider_config.gd")

const SURFACE_ID: StringName = &"xr_world_ui"
const SURFACE_TYPE: StringName = &"world_3d"
const DEFAULT_SURFACE_SIZE := Vector2(2.93, 1.577)
const TARGET_PRIMARY := "primary"
const TARGET_SECONDARY := "secondary"

var interaction_bus
var xr_input_adapter
var panel_viewport: SubViewport
var panel_ui: Control
var panel_input_surface: Area3D
var summary_label: Label
var event_label: Label
var verification_label: Label
var interrupt_button: Button

var _projection_helper = PROJECTION_HELPER_SCRIPT.new()
var _spatial_surface_descriptor = null
var _spatial_xr_provider = null
var _captured_events: Array = []
var _target_specs_by_key: Dictionary = {}
var _last_contract_phase := "waiting"
var _last_contract_target_path := "none"
var _last_contract_verification_status := "waiting"

func _ready() -> void:
	_ensure_scene_nodes()
	call_deferred("_finish_setup")


func is_ready_for_proof() -> bool:
	return _spatial_xr_provider != null and _spatial_surface_descriptor != null and is_instance_valid(panel_ui)


func get_captured_events() -> Array:
	return _captured_events


func _current_xr_runtime_state() -> Dictionary:
	return _spatial_xr_provider.describe_runtime_state() if _spatial_xr_provider != null else {}


func _current_xr_interaction_summary() -> Dictionary:
	return _spatial_xr_provider.describe_interaction_summary() if _spatial_xr_provider != null else {}


func simulate_hover_primary(source_variant := "xr_ray", button := "trigger") -> bool:
	return _publish_xr_pointer_update(_make_hover_packet("xr_right", source_variant, button), _build_hit_for_target_key(TARGET_PRIMARY))


func simulate_press_primary(source_variant := "xr_ray", button := "trigger") -> bool:
	return _publish_xr_pointer_update(_make_press_packet("xr_right", source_variant, button), _build_hit_for_target_key(TARGET_PRIMARY))


func simulate_hover_secondary(source_variant := "xr_ray", button := "trigger") -> bool:
	return _publish_xr_pointer_update(_make_hover_packet("xr_right", source_variant, button), _build_hit_for_target_key(TARGET_SECONDARY))


func simulate_drag_to_secondary(source_variant := "xr_ray", button := "trigger") -> bool:
	return _publish_xr_pointer_update(_make_move_packet("xr_right", source_variant, button), _build_hit_for_target_key(TARGET_SECONDARY))


func simulate_release_off_surface(source_variant := "xr_ray", button := "trigger") -> bool:
	return _publish_xr_pointer_update(_make_release_packet("xr_right", source_variant, button), _build_off_surface_hit(Vector2(900.0, 900.0)))


func trigger_interruption(reason := "tracking_lost") -> bool:
	return _publish_xr_pointer_update(
		_make_cancel_packet("xr_right", "xr_ray", "trigger", reason),
		_build_off_surface_hit(Vector2(256.0, 256.0)),
		{"interruption_reason": reason}
	)


func get_summary_debug_text() -> String:
	return summary_label.text if is_instance_valid(summary_label) else ""


func get_event_debug_text() -> String:
	return event_label.text if is_instance_valid(event_label) else ""


func _finish_setup() -> void:
	interaction_bus = BUS_SCRIPT.new()
	interaction_bus.name = "AeroUiInteractionBus"
	add_child(interaction_bus)
	interaction_bus.interaction_event.connect(_on_interaction_event)

	xr_input_adapter = ADAPTER_SCRIPT.new()
	xr_input_adapter.name = "XrUiInputAdapter"
	xr_input_adapter.bus_path = NodePath("../AeroUiInteractionBus")
	xr_input_adapter.surface_id = SURFACE_ID
	xr_input_adapter.surface_type = SURFACE_TYPE
	xr_input_adapter.default_source_variant = &"xr_ray"
	add_child(xr_input_adapter)

	panel_ui = PANEL_VIEW_SCENE.instantiate()
	panel_ui.name = "PanelUi"
	panel_viewport.add_child(panel_ui)
	await get_tree().process_frame
	await get_tree().process_frame
	_install_secondary_target()
	panel_ui.configure_interaction_contract({
		"surface_id": SURFACE_ID,
		"surface_type_label": "world_3d",
		"host_summary": "Dedicated downstream XR proof host consuming packaged provider summary output.",
		"mode_label": "XR Provider Proof",
		"interaction_bus_path": interaction_bus.get_path(),
	})
	panel_ui.refresh_contract_bindings()
	_refresh_spatial_surface_descriptor()

	var config = XR_PROVIDER_CONFIG_SCRIPT.new()
	config.host_surface = "XrProofPanelSurface"
	config.target_resolution = "rect_target_specs"
	_spatial_xr_provider = XR_PROVIDER_SCRIPT.new(config)
	_refresh_status()


func _ensure_scene_nodes() -> void:
	if get_node_or_null("Camera3D") == null:
		var camera := Camera3D.new()
		camera.name = "Camera3D"
		camera.transform.origin = Vector3(0.0, 0.0, 4.5)
		add_child(camera)
	if get_node_or_null("PanelInputSurface") == null:
		panel_input_surface = Area3D.new()
		panel_input_surface.name = "PanelInputSurface"
		add_child(panel_input_surface)
		var shape := CollisionShape3D.new()
		shape.name = "CollisionShape3D"
		shape.shape = BoxShape3D.new()
		(shape.shape as BoxShape3D).size = Vector3(DEFAULT_SURFACE_SIZE.x, DEFAULT_SURFACE_SIZE.y, 0.05)
		panel_input_surface.add_child(shape)
	else:
		panel_input_surface = get_node("PanelInputSurface") as Area3D
	if get_node_or_null("PanelViewport") == null:
		panel_viewport = SubViewport.new()
		panel_viewport.name = "PanelViewport"
		panel_viewport.size = Vector2i(1000, 1000)
		panel_viewport.transparent_bg = true
		panel_viewport.disable_3d = true
		panel_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		add_child(panel_viewport)
	else:
		panel_viewport = get_node("PanelViewport") as SubViewport
	if get_node_or_null("StatusCanvas") == null:
		var canvas := CanvasLayer.new()
		canvas.name = "StatusCanvas"
		add_child(canvas)
		var margin := MarginContainer.new()
		margin.name = "Margin"
		margin.offset_left = 24.0
		margin.offset_top = 24.0
		margin.offset_right = 560.0
		margin.offset_bottom = 360.0
		canvas.add_child(margin)
		var box := VBoxContainer.new()
		box.name = "Box"
		margin.add_child(box)
		verification_label = Label.new()
		verification_label.name = "VerificationLabel"
		box.add_child(verification_label)
		summary_label = Label.new()
		summary_label.name = "SummaryLabel"
		summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		box.add_child(summary_label)
		event_label = Label.new()
		event_label.name = "EventLabel"
		event_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		box.add_child(event_label)
		interrupt_button = Button.new()
		interrupt_button.name = "InterruptButton"
		interrupt_button.text = "Trigger XR Cancel"
		interrupt_button.pressed.connect(func(): trigger_interruption("debug_interrupt"))
		box.add_child(interrupt_button)
	else:
		var canvas = get_node("StatusCanvas")
		verification_label = canvas.get_node("Margin/Box/VerificationLabel") as Label
		summary_label = canvas.get_node("Margin/Box/SummaryLabel") as Label
		event_label = canvas.get_node("Margin/Box/EventLabel") as Label
		interrupt_button = canvas.get_node("Margin/Box/InterruptButton") as Button


func _install_secondary_target() -> void:
	var content_column := panel_ui.get_node_or_null("PreviewCenter/PreviewStack/PrimaryCardButton/ContentMargin/ContentColumn") as Control
	if content_column == null:
		return
	var existing := content_column.get_node_or_null("SecondaryActionButton") as Button
	if existing == null:
		existing = Button.new()
		existing.name = "SecondaryActionButton"
		existing.text = "Secondary Action"
		content_column.add_child(existing)
	panel_ui.register_contract_target(TARGET_SECONDARY, existing, {"target_label": "SecondaryActionButton", "user_state": {"toggle_on": false}})


func _refresh_spatial_surface_descriptor() -> void:
	if not is_instance_valid(panel_ui):
		return
	if _spatial_surface_descriptor == null:
		_spatial_surface_descriptor = SURFACE_DESCRIPTOR_SCRIPT.new()
	var localized_target_specs: Array = []
	_target_specs_by_key.clear()
	for spec_variant in panel_ui.get_interaction_target_specs():
		if not (spec_variant is Dictionary):
			continue
		var spec := (spec_variant as Dictionary).duplicate(true)
		localized_target_specs.append(spec)
		_target_specs_by_key[str(spec.get("target_key", ""))] = spec
	_spatial_surface_descriptor.configure({
		"surface_id": SURFACE_ID,
		"surface_path": panel_input_surface.get_path() if is_instance_valid(panel_input_surface) else NodePath(),
		"viewport_path": panel_viewport.get_path(),
		"surface_pixel_size": Vector2(panel_viewport.size),
		"authored_rect_normalized": Rect2(0.0, 0.0, 1.0, 1.0),
		"target_specs": localized_target_specs,
		"metadata": {
			"host_surface": "XrProofPanelSurface",
			"target_resolution": "rect_target_specs",
			"surface_size": DEFAULT_SURFACE_SIZE,
		},
	})


func _build_hit_for_target_key(target_key: String) -> Dictionary:
	var spec: Dictionary = _target_specs_by_key.get(target_key, {})
	if spec.is_empty():
		return _build_off_surface_hit()
	var rect: Rect2 = spec.get("rect", Rect2())
	var viewport_size := Vector2(panel_viewport.size)
	var center := rect.position + (rect.size * 0.5)
	var authored_uv := Vector2(center.x / maxf(viewport_size.x, 1.0), center.y / maxf(viewport_size.y, 1.0))
	return _build_hit_for_authored_uv(authored_uv, center)


func _build_hit_for_authored_uv(authored_uv: Vector2, screen_position: Vector2 = Vector2.ZERO) -> Dictionary:
	return _projection_helper.build_surface_hit(_spatial_surface_descriptor, authored_uv, {
		"screen_position": screen_position,
		"world_position": Vector3(authored_uv.x, authored_uv.y, 0.0),
		"world_normal": Vector3.UP,
		"world_direction": Vector3.FORWARD,
		"surface_size": DEFAULT_SURFACE_SIZE,
	})


func _build_off_surface_hit(screen_position: Vector2 = Vector2.ZERO) -> Dictionary:
	return {
		"hit": false,
		"screen_position": screen_position,
		"world_direction": Vector3.FORWARD,
	}


func _publish_xr_pointer_update(pointer_update: Dictionary, projected_hit: Dictionary, context: Dictionary = {}) -> bool:
	if not is_ready_for_proof():
		return false
	_refresh_spatial_surface_descriptor()
	var merged_context := {
		"host_surface": "XrProofPanelSurface",
		"target_resolution": "rect_target_specs",
	}
	for key in context.keys():
		merged_context[key] = context[key]
	var published: bool = bool(_spatial_xr_provider.publish_pointer_update(
		xr_input_adapter,
		_spatial_surface_descriptor,
		pointer_update,
		projected_hit,
		merged_context
	))
	_refresh_status()
	return published


func _make_hover_packet(pointer_id: String, source_variant: String, button: String) -> Dictionary:
	return {
		"pointer_id": pointer_id,
		"pressed": false,
		"primary": true,
		"source_variant": source_variant,
		"button": button,
		"raw_event_class": &"xr_pointer_update",
		"raw_metadata": {"pointer_id": pointer_id, "source_variant": source_variant, "button": button},
	}


func _make_press_packet(pointer_id: String, source_variant: String, button: String) -> Dictionary:
	var packet := _make_hover_packet(pointer_id, source_variant, button)
	packet["pressed"] = true
	return packet


func _make_move_packet(pointer_id: String, source_variant: String, button: String) -> Dictionary:
	var packet := _make_hover_packet(pointer_id, source_variant, button)
	packet["pressed"] = true
	return packet


func _make_release_packet(pointer_id: String, source_variant: String, button: String) -> Dictionary:
	return _make_hover_packet(pointer_id, source_variant, button)


func _make_cancel_packet(pointer_id: String, source_variant: String, button: String, reason: String) -> Dictionary:
	var packet := _make_hover_packet(pointer_id, source_variant, button)
	packet["canceled"] = true
	packet["interruption_reason"] = reason
	var metadata: Dictionary = packet.get("raw_metadata", {})
	metadata["interruption_reason"] = reason
	metadata["canceled"] = true
	packet["raw_metadata"] = metadata
	return packet


func _on_interaction_event(event) -> void:
	_captured_events.append(event)
	_last_contract_phase = str(event.phase)
	_last_contract_target_path = str(event.target_path)
	_last_contract_verification_status = str(event.verification_status)
	_refresh_status()


func _refresh_status() -> void:
	var summary := _current_xr_interaction_summary()
	if is_instance_valid(verification_label):
		verification_label.text = "verification_status=%s" % str(summary.get("verification_status", _last_contract_verification_status))
	if is_instance_valid(summary_label):
		summary_label.text = "\n".join([
			"active_pointer_id=%s" % str(summary.get("active_pointer_id", "")),
			"active_phase=%s" % str(summary.get("state_phase", "")),
			"active_source_variant=%s" % str(summary.get("locked_source_variant", "")),
			"active_button=%s" % str(summary.get("active_button", "")),
			"preferred_target=%s" % str(summary.get("preferred_target_label", "none")),
			"owner_target=%s" % str(summary.get("owner_target_label", "none")),
			"live_target=%s" % str(summary.get("live_target_label", "none")),
			"last_release_target=%s" % str(summary.get("last_release_target_label", "none")),
			"last_terminal_result=%s" % str(summary.get("last_terminal_result", "")),
			"last_interruption_reason=%s" % str(summary.get("last_interruption_reason", "")),
		])
	if is_instance_valid(event_label):
		event_label.text = "last_event=%s\nlast_target=%s\nprovider=%s" % [
			_last_contract_phase,
			_last_contract_target_path,
			str(summary.get("last_forwarded_panel_event", "")),
		]
