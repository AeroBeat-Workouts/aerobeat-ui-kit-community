extends SceneTree

const OUT_DIR := "/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/.temp/qa-evidence"
const OUT_JSON := OUT_DIR + "/multi_target_hybrid_qa_probe.json"
const SCENE_PATH := "res://scenes/glass-shader-gui-3d-test.tscn"
const PRIMARY_KEY := "primary"
const CHIP_KEY := "chip"
const STRIP_KEY := "strip"
const REQUIRED_NAMES := ["PrimaryCardButton", "SecondaryToggleChip", "DragStrip"]
const REQUIRED_KEYS := [PRIMARY_KEY, CHIP_KEY, STRIP_KEY]

var _scene_root: Node3D
var _events: Array = []

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	call_deferred("_run")


func _run() -> void:
	var packed: PackedScene = load(SCENE_PATH)
	if packed == null:
		_fail_and_quit({"ok": false, "error": "Failed to load scene %s" % SCENE_PATH})
		return

	_scene_root = packed.instantiate() as Node3D
	if _scene_root == null:
		_fail_and_quit({"ok": false, "error": "Scene did not instantiate as Node3D"})
		return

	root.add_child(_scene_root)
	await _settle_frames(20)

	var report := await _collect_report()
	_write_report(report)
	print(JSON.stringify(report, "\t"))
	quit(0 if bool(report.get("ok", false)) else 2)


func _collect_report() -> Dictionary:
	var scene := _scene_root
	scene.call("set_auto_rotate_enabled", false)
	scene.call("reset_manual_rotation")
	await _settle_frames(8)

	var panel_ui: Control = scene.get("_panel_ui") as Control
	var bus: AeroUiInteractionBus = scene.get("interaction_bus") as AeroUiInteractionBus
	var adapter: HybridSubViewportInputAdapter = scene.get("hybrid_input_adapter") as HybridSubViewportInputAdapter
	if panel_ui == null or bus == null or adapter == null:
		return {
			"ok": false,
			"error": "Missing runtime panel/contract nodes",
		}

	if not bus.interaction_event.is_connected(_on_bus_event):
		bus.interaction_event.connect(_on_bus_event)

	var target_specs: Array = panel_ui.call("get_interaction_target_specs") as Array
	var target_map: Dictionary = _map_target_specs(target_specs)
	var target_names: Array = []
	for spec in target_specs:
		target_names.append(str(spec.get("target_name", "")))

	var centers: Dictionary = {}
	var hit_probes: Dictionary = {}
	for key in REQUIRED_KEYS:
		var spec: Dictionary = target_map.get(key, {})
		if spec.is_empty():
			continue
		var surface_position: Vector2 = (spec.get("rect", Rect2()) as Rect2).get_center()
		var screen_position: Vector2 = _surface_to_screen(scene, surface_position)
		centers[key] = {
			"surface_position": _vec2_to_dict(surface_position),
			"screen_position": _vec2_to_dict(screen_position),
			"target_path": String(spec.get("target_path", NodePath())),
			"target_name": str(spec.get("target_name", "")),
		}
		var hit: Dictionary = scene.call("_screen_position_to_panel_hit", screen_position) as Dictionary
		var resolved_path: NodePath = scene.call("_resolve_projected_target_path", hit.get("viewport_position", Vector2.ZERO))
		hit_probes[key] = {
			"hit": bool(hit.get("hit", false)),
			"viewport_position": _vec2_to_dict(hit.get("viewport_position", Vector2.ZERO)),
			"resolved_target_path": String(resolved_path),
			"matches_expected": String(resolved_path) == String(spec.get("target_path", NodePath())),
		}

	var baseline := _capture_state(scene, panel_ui)

	await _hover_to(scene, centers[CHIP_KEY]["screen_position"])
	var after_hover_chip := _capture_state(scene, panel_ui)
	await _hover_to(scene, centers[PRIMARY_KEY]["screen_position"])
	var after_hover_primary := _capture_state(scene, panel_ui)
	await _hover_to(scene, centers[STRIP_KEY]["screen_position"])
	var after_hover_strip := _capture_state(scene, panel_ui)

	await _tap(scene, centers[PRIMARY_KEY]["screen_position"])
	var after_primary_tap := _capture_state(scene, panel_ui)

	await _tap(scene, centers[CHIP_KEY]["screen_position"])
	var after_chip_tap := _capture_state(scene, panel_ui)

	var drag_positions := [
		centers[STRIP_KEY]["screen_position"],
		centers[PRIMARY_KEY]["screen_position"],
		centers[CHIP_KEY]["screen_position"],
	]
	await _drag(scene, drag_positions)
	var after_cross_sibling_drag := _capture_state(scene, panel_ui)

	var outside := Vector2(1540.0, 120.0)
	var strip_drag_surface := _dict_to_vec2(centers[STRIP_KEY]["surface_position"]) + Vector2(180.0, 0.0)
	var strip_drag_screen := _surface_to_screen(scene, strip_drag_surface)
	await _drag(scene, [centers[STRIP_KEY]["screen_position"], _vec2_to_dict(strip_drag_screen)], outside)
	var after_offsurface_release := _capture_state(scene, panel_ui)

	var binding_report := _collect_binding_report(panel_ui, bus)
	var event_checks := _derive_event_checks(target_map)
	var state_checks := {
		"has_three_sibling_targets": _contains_all(target_names, REQUIRED_NAMES) and target_specs.size() == 3,
		"dynamic_resolution_hits_all_targets": bool(hit_probes[PRIMARY_KEY]["matches_expected"]) and bool(hit_probes[CHIP_KEY]["matches_expected"]) and bool(hit_probes[STRIP_KEY]["matches_expected"]),
		"hover_transitions_visible": after_hover_chip["summary_hover"].contains("SecondaryToggleChip") and after_hover_primary["summary_hover"].contains("PrimaryCardButton") and after_hover_strip["summary_hover"].contains("DragStrip"),
		"primary_tap_isolated": after_primary_tap["target_states"][PRIMARY_KEY]["tap_count"] == 1 and after_primary_tap["target_states"][CHIP_KEY]["tap_count"] == 0,
		"chip_tap_isolated": after_chip_tap["target_states"][PRIMARY_KEY]["tap_count"] == 1 and after_chip_tap["target_states"][CHIP_KEY]["tap_count"] == 1,
		"strip_drag_no_transfer": after_cross_sibling_drag["target_states"][STRIP_KEY]["drag_count"] >= 2 and after_cross_sibling_drag["target_states"][STRIP_KEY]["tap_count"] == 0 and after_cross_sibling_drag["target_states"][CHIP_KEY]["tap_count"] == 1,
		"offsurface_release_keeps_owner": after_offsurface_release["last_release_target_path"] == centers[STRIP_KEY]["target_path"] and after_offsurface_release["target_states"][PRIMARY_KEY]["tap_count"] == 1 and after_offsurface_release["target_states"][CHIP_KEY]["tap_count"] == 1 and after_offsurface_release["target_states"][STRIP_KEY]["tap_count"] == 0,
		"shared_consumer_shape_still_contract_driven": _binding_report_matches_specs(binding_report, target_specs),
		"verification_labels_still_conservative": after_offsurface_release["summary_phase"].contains("prototype") and after_offsurface_release["hint_label"].contains("Touch remains unverified") and after_offsurface_release["hint_label"].contains("hybrid mouse remains prototype"),
	}

	var all_checks := {}
	all_checks.merge(state_checks)
	all_checks.merge(event_checks)

	var ok := _all_true(all_checks)
	return {
		"ok": ok,
		"scene": SCENE_PATH,
		"target_specs": target_specs,
		"target_names": target_names,
		"centers": centers,
		"hit_probes": hit_probes,
		"baseline": baseline,
		"after_hover_chip": after_hover_chip,
		"after_hover_primary": after_hover_primary,
		"after_hover_strip": after_hover_strip,
		"after_primary_tap": after_primary_tap,
		"after_chip_tap": after_chip_tap,
		"after_cross_sibling_drag": after_cross_sibling_drag,
		"after_offsurface_release": after_offsurface_release,
		"binding_report": binding_report,
		"event_sample": _events,
		"event_checks": event_checks,
		"state_checks": state_checks,
		"all_checks": all_checks,
	}


func _collect_binding_report(panel_ui: Node, bus: AeroUiInteractionBus) -> Dictionary:
	var bindings: Array = []
	var target_names: Array = []
	var target_keys: Array = []
	var all_connected := true
	var bus_path := String(bus.get_path()) if bus != null else ""
	for child in panel_ui.get_children():
		if not (child is AeroUiContractTargetBinding):
			continue
		var binding := child as AeroUiContractTargetBinding
		var interactable_connected := bus != null and binding.interactable != null and bus.interaction_event.is_connected(Callable(binding.interactable, "_on_bus_interaction_event"))
		var listener_connected := bus != null and binding.listener != null and bus.interaction_event.is_connected(Callable(binding.listener, "_on_bus_interaction_event"))
		all_connected = all_connected and interactable_connected and listener_connected and String(binding.bus_path) == bus_path
		bindings.append({
			"binding_name": String(binding.name),
			"target_key": binding.target_key,
			"target_name": binding.target_label,
			"target_path": String(binding.get_target_path()),
			"bus_path": String(binding.bus_path),
			"interactable_name": String(binding.interactable.name) if binding.interactable != null else "",
			"listener_name": String(binding.listener.name) if binding.listener != null else "",
			"interactable_connected": interactable_connected,
			"listener_connected": listener_connected,
		})
		target_names.append(binding.target_label)
		target_keys.append(binding.target_key)
	return {
		"binding_count": bindings.size(),
		"target_names": target_names,
		"target_keys": target_keys,
		"bindings": bindings,
		"all_connected": all_connected and not bindings.is_empty(),
		"has_required_names": _contains_all(target_names, REQUIRED_NAMES),
		"has_required_keys": _contains_all(target_keys, REQUIRED_KEYS),
	}


func _binding_report_matches_specs(binding_report: Dictionary, specs: Array) -> bool:
	var spec_names := _spec_names(specs)
	var spec_keys := _spec_keys(specs)
	return int(binding_report.get("binding_count", 0)) == specs.size() \
		and bool(binding_report.get("all_connected", false)) \
		and _contains_all(binding_report.get("target_names", []), spec_names) \
		and _contains_all(binding_report.get("target_keys", []), spec_keys)


func _spec_names(specs: Array) -> Array:
	var names: Array = []
	for spec_variant in specs:
		if spec_variant is Dictionary:
			names.append(str((spec_variant as Dictionary).get("target_name", "")))
	return names


func _spec_keys(specs: Array) -> Array:
	var keys: Array = []
	for spec_variant in specs:
		if spec_variant is Dictionary:
			keys.append(str((spec_variant as Dictionary).get("target_key", "")))
	return keys


func _derive_event_checks(target_map: Dictionary) -> Dictionary:
	var primary_path := String(target_map.get(PRIMARY_KEY, {}).get("target_path", NodePath()))
	var chip_path := String(target_map.get(CHIP_KEY, {}).get("target_path", NodePath()))
	var strip_path := String(target_map.get(STRIP_KEY, {}).get("target_path", NodePath()))
	var checks := {
		"hover_enter_seen_for_multiple_targets": false,
		"drag_hover_can_change_while_owner_stays_strip": false,
		"release_over_different_sibling_keeps_strip_owner": false,
		"offsurface_release_marks_continuation": false,
		"raw_metadata_uses_dynamic_resolution_marker": false,
	}
	var hover_targets := {}
	for index in range(_events.size()):
		var event: Dictionary = _events[index]
		if event["phase"] == "hover_enter":
			hover_targets[event["target_path"]] = true
		if event["raw_metadata"].get("target_resolution", "") == "multi_target_panel_rect_lookup":
			checks["raw_metadata_uses_dynamic_resolution_marker"] = true
		if event["phase"] == "drag_move" and event["target_path"] == strip_path:
			var live_target := str(event["raw_metadata"].get("live_target_path", ""))
			if live_target == primary_path or live_target == chip_path:
				checks["drag_hover_can_change_while_owner_stays_strip"] = true
		if event["phase"] == "press_end" and event["target_path"] == strip_path:
			var live_target := str(event["raw_metadata"].get("live_target_path", ""))
			if live_target == chip_path:
				checks["release_over_different_sibling_keeps_strip_owner"] = true
			if bool(event["raw_metadata"].get("off_surface_continuation", false)):
				checks["offsurface_release_marks_continuation"] = true
	checks["hover_enter_seen_for_multiple_targets"] = hover_targets.has(primary_path) and hover_targets.has(chip_path) and hover_targets.has(strip_path)
	return checks


func _map_target_specs(target_specs: Array) -> Dictionary:
	var target_map := {}
	for spec_variant in target_specs:
		if not (spec_variant is Dictionary):
			continue
		var spec: Dictionary = spec_variant
		target_map[str(spec.get("target_key", ""))] = spec
	return target_map


func _capture_state(scene: Node, panel_ui: Control) -> Dictionary:
	var target_states_src: Dictionary = panel_ui.get("_target_states")
	var target_states := {}
	for key in target_states_src.keys():
		var state: Dictionary = target_states_src[key]
		target_states[str(key)] = {
			"target_path": String(state.get("target_path", NodePath())),
			"hovered": bool(state.get("hovered", false)),
			"pressed": bool(state.get("pressed", false)),
			"dragging": bool(state.get("dragging", false)),
			"press_count": int(state.get("press_count", 0)),
			"release_count": int(state.get("release_count", 0)),
			"drag_count": int(state.get("drag_count", 0)),
			"tap_count": int(state.get("tap_count", 0)),
			"toggle_on": bool(state.get("toggle_on", false)),
			"progress": float(state.get("progress", 0.0)),
		}

	return {
		"summary_hover": _label_text(panel_ui, "PreviewCenter/PreviewStack/HybridSummaryPanel/SummaryPadding/SummaryColumn/HoverTargetLabel"),
		"summary_owner": _label_text(panel_ui, "PreviewCenter/PreviewStack/HybridSummaryPanel/SummaryPadding/SummaryColumn/OwnerTargetLabel"),
		"summary_release": _label_text(panel_ui, "PreviewCenter/PreviewStack/HybridSummaryPanel/SummaryPadding/SummaryColumn/ReleaseTargetLabel"),
		"summary_phase": _label_text(panel_ui, "PreviewCenter/PreviewStack/HybridSummaryPanel/SummaryPadding/SummaryColumn/PhaseSummaryLabel"),
		"summary_counts": _label_text(panel_ui, "PreviewCenter/PreviewStack/HybridSummaryPanel/SummaryPadding/SummaryColumn/CountsSummaryLabel"),
		"primary_pointer": _label_text(panel_ui, "PreviewCenter/PreviewStack/PrimaryCardButton/ContentMargin/ContentColumn/InteractionStatePanel/InteractionStatePadding/InteractionStateColumn/InteractionPointerLabel"),
		"primary_toggle": _label_text(panel_ui, "PreviewCenter/PreviewStack/PrimaryCardButton/ContentMargin/ContentColumn/InteractionStatePanel/InteractionStatePadding/InteractionStateColumn/InteractionToggleLabel"),
		"chip_state": _label_text(panel_ui, "PreviewCenter/PreviewStack/SecondaryToggleChip/ChipColumn/ChipStateLabel"),
		"strip_state": _label_text(panel_ui, "PreviewCenter/PreviewStack/DragStrip/StripPadding/StripColumn/StripStateLabel"),
		"hint_label": _label_text(panel_ui, "PreviewCenter/PreviewStack/PrimaryCardButton/ContentMargin/ContentColumn/HintLabel"),
		"mouse_owner_target_path": String(scene.get("_mouse_owner_target_path")),
		"mouse_hover_target_path": String(scene.get("_mouse_hover_target_path")),
		"last_release_target_path": String(scene.get("_last_release_target_path")),
		"target_states": target_states,
	}


func _label_text(root_node: Node, path: String) -> String:
	var label := root_node.get_node_or_null(path) as Label
	return label.text if label != null else ""


func _surface_to_screen(scene: Node, surface_position: Vector2) -> Vector2:
	var panel_input_surface := scene.get_node("PanelPivot/PanelInputSurface") as Area3D
	var camera := scene.get_node("Camera3D") as Camera3D
	var surface_size: Vector2 = scene.call("_get_panel_surface_size")
	var uv := Vector2(surface_position.x / 1600.0, surface_position.y / 900.0)
	var local := Vector3((uv.x - 0.5) * surface_size.x, (0.5 - uv.y) * surface_size.y, 0.0)
	var world := panel_input_surface.global_transform * local
	return camera.unproject_position(world)


func _hover_to(scene: Node, point_dict: Dictionary) -> void:
	var point := _dict_to_vec2(point_dict)
	scene.call("_unhandled_input", _mouse_motion(point, Vector2.ZERO))
	await _settle_frames(2)


func _tap(scene: Node, point_dict: Dictionary) -> void:
	var point := _dict_to_vec2(point_dict)
	scene.call("_unhandled_input", _mouse_motion(point, Vector2.ZERO))
	await _settle_frames(1)
	scene.call("_unhandled_input", _mouse_button(point, true))
	await _settle_frames(1)
	scene.call("_unhandled_input", _mouse_button(point, false))
	await _settle_frames(2)


func _drag(scene: Node, point_dicts: Array, release_override: Variant = null) -> void:
	if point_dicts.is_empty():
		return
	var first := _dict_to_vec2(point_dicts[0])
	scene.call("_unhandled_input", _mouse_motion(first, Vector2.ZERO))
	await _settle_frames(1)
	scene.call("_unhandled_input", _mouse_button(first, true))
	await _settle_frames(1)
	var previous := first
	for index in range(1, point_dicts.size()):
		var point := _dict_to_vec2(point_dicts[index])
		scene.call("_unhandled_input", _mouse_motion(point, point - previous))
		previous = point
		await _settle_frames(1)
	var release_point := previous
	if release_override != null:
		release_point = release_override if release_override is Vector2 else _dict_to_vec2(release_override)
		scene.call("_unhandled_input", _mouse_motion(release_point, release_point - previous))
		await _settle_frames(1)
	scene.call("_unhandled_input", _mouse_button(release_point, false))
	await _settle_frames(2)


func _mouse_motion(position: Vector2, relative: Vector2) -> InputEventMouseMotion:
	var event := InputEventMouseMotion.new()
	event.position = position
	event.global_position = position
	event.relative = relative
	event.velocity = Vector2.ZERO
	return event


func _mouse_button(position: Vector2, pressed: bool) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.position = position
	event.global_position = position
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	return event


func _on_bus_event(event: AeroUiInteractionEvent) -> void:
	_events.append({
		"phase": str(event.phase),
		"target_path": String(event.target_path),
		"source_variant": str(event.source_variant),
		"verification_status": str(event.verification_status),
		"surface_position": _vec2_to_dict(event.surface_position),
		"raw_metadata": event.raw_metadata.duplicate(true),
	})


func _contains_all(values: Array, required: Array) -> bool:
	for item in required:
		if item not in values:
			return false
	return true


func _all_true(dict: Dictionary) -> bool:
	for value in dict.values():
		if not bool(value):
			return false
	return true


func _dict_to_vec2(value: Variant) -> Vector2:
	if value is Vector2:
		return value
	if value is Dictionary:
		return Vector2(float(value.get("x", 0.0)), float(value.get("y", 0.0)))
	return Vector2.ZERO


func _vec2_to_dict(value: Variant) -> Dictionary:
	var vec := value as Vector2
	return {"x": vec.x, "y": vec.y}


func _write_report(report: Dictionary) -> void:
	var file := FileAccess.open(OUT_JSON, FileAccess.WRITE)
	if file == null:
		push_error("Failed to write report to %s" % OUT_JSON)
		return
	file.store_string(JSON.stringify(report, "\t"))
	file.close()


func _fail_and_quit(report: Dictionary) -> void:
	_write_report(report)
	print(JSON.stringify(report, "\t"))
	quit(2)


func _settle_frames(count: int) -> void:
	for _i in range(count):
		await process_frame
