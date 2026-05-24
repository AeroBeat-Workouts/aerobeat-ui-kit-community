extends Node

const MAX_TRANSCRIPT_LINES := 12

@onready var proof_host = get_node("HybridProofHost")
@onready var probe_label: RichTextLabel = get_node("ProbeOverlay/OverlayRoot/Margin/Panel/Column/ProbeLabel") as RichTextLabel
@onready var transcript_label: RichTextLabel = get_node("ProbeOverlay/OverlayRoot/Margin/Panel/Column/TranscriptLabel") as RichTextLabel
@onready var cancel_button: Button = get_node("ProbeOverlay/OverlayRoot/Margin/Panel/Column/CancelButton") as Button

var _transcript_lines: Array[String] = []

func _ready() -> void:
	await get_tree().process_frame
	if proof_host != null:
		proof_host.set_auto_rotate_enabled(false)
		if proof_host.interaction_bus != null and not proof_host.interaction_bus.interaction_event.is_connected(_on_contract_interaction_event):
			proof_host.interaction_bus.interaction_event.connect(_on_contract_interaction_event)
	if cancel_button != null and not cancel_button.pressed.is_connected(_on_cancel_button_pressed):
		cancel_button.pressed.connect(_on_cancel_button_pressed)
	refresh_probe_panel()

func refresh_probe_panel() -> void:
	var probe := _current_probe_snapshot()
	probe_label.text = _format_probe(probe)
	transcript_label.text = "[b]Recent contract phases[/b]\n%s" % ("\n".join(_bulletize(_transcript_lines)) if not _transcript_lines.is_empty() else "• none")
	cancel_button.disabled = not bool(probe.get("is_touch_active", false))

func wrapped_proof_host() -> Node:
	return proof_host

func _current_probe_snapshot() -> Dictionary:
	return proof_host._current_touch_verification_probe() if proof_host != null else {}

func recent_transcript_lines() -> PackedStringArray:
	return PackedStringArray(_transcript_lines)

func trigger_active_touch_cancel() -> bool:
	var probe := _current_probe_snapshot()
	if not bool(probe.get("is_touch_active", false)):
		return false
	var pointer_id := str(probe.get("active_pointer_id", ""))
	var index := _pointer_index_from_id(pointer_id)
	if index < 0:
		return false
	var event := InputEventScreenTouch.new()
	event.index = index
	event.pressed = false
	event.canceled = true
	var projected_data: Dictionary = probe.get("last_projected_data", {})
	event.position = Vector2(projected_data.get("screen_position", Vector2.ZERO))
	var published: bool = proof_host._publish_screen_touch_to_contract(event) if proof_host != null else false
	refresh_probe_panel()
	return published

func _on_contract_interaction_event(event) -> void:
	if proof_host == null or event.surface_id != proof_host.HYBRID_SURFACE_ID:
		return
	_transcript_lines.append(str(event.phase))
	if _transcript_lines.size() > MAX_TRANSCRIPT_LINES:
		_transcript_lines = _transcript_lines.slice(_transcript_lines.size() - MAX_TRANSCRIPT_LINES, _transcript_lines.size())
	refresh_probe_panel()

func _on_cancel_button_pressed() -> void:
	trigger_active_touch_cancel()

func _pointer_index_from_id(pointer_id: String) -> int:
	if not pointer_id.begins_with("touch_"):
		return -1
	return int(pointer_id.trim_prefix("touch_"))

func _bulletize(values: Array[String]) -> PackedStringArray:
	var lines := PackedStringArray()
	for value in values:
		lines.append("• %s" % value)
	return lines

func _format_probe(probe: Dictionary) -> String:
	return "\n".join([
		"[b]Touch provider manual probe[/b]",
		"owner target: %s" % str(probe.get("owner_target_label", "none")),
		"live target: %s" % str(probe.get("live_target_label", "none")),
		"preferred target: %s" % str(probe.get("preferred_target_label", "none")),
		"state phase: %s" % str(probe.get("state_phase", "")),
		"active pointer: %s" % str(probe.get("active_pointer_id", "")),
		"last release: %s" % str(probe.get("last_release_target_path", "")),
		"source variant: %s" % str(probe.get("source_variant", "")),
		"surface type: %s" % str(probe.get("surface_type", "")),
		"verification status: %s" % str(probe.get("verification_status", "")),
		"forwarded event: %s" % str(probe.get("last_forwarded_panel_event", "")),
	])
