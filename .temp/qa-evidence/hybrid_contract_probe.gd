extends SceneTree

const OUT_DIR := "/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/.temp/qa-evidence"
const OUT_JSON := OUT_DIR + "/hybrid_contract_probe.json"
const SCENE_PATH := "res://scenes/glass-shader-gui-3d-test.tscn"
const PRIMARY_CARD_PATH := NodePath("PreviewCenter/PreviewStack/PrimaryCardButton")
const SOURCE_LABEL_PATH := NodePath("PreviewCenter/PreviewStack/PrimaryCardButton/ContentMargin/ContentColumn/InteractionStatePanel/InteractionStatePadding/InteractionStateColumn/InteractionSourceLabel")
const POINTER_LABEL_PATH := NodePath("PreviewCenter/PreviewStack/PrimaryCardButton/ContentMargin/ContentColumn/InteractionStatePanel/InteractionStatePadding/InteractionStateColumn/InteractionPointerLabel")
const TOGGLE_LABEL_PATH := NodePath("PreviewCenter/PreviewStack/PrimaryCardButton/ContentMargin/ContentColumn/InteractionStatePanel/InteractionStatePadding/InteractionStateColumn/InteractionToggleLabel")
const VERIFICATION_LABEL_PATH := NodePath("PreviewCenter/PreviewStack/PrimaryCardButton/ContentMargin/ContentColumn/InteractionStatePanel/InteractionStatePadding/InteractionStateColumn/InteractionCountLabel")
const HEADLINE_PATH := NodePath("PreviewCenter/PreviewStack/PrimaryCardButton/ContentMargin/ContentColumn/Headline")
const BADGE_LABEL_PATH := NodePath("PreviewCenter/PreviewStack/PrimaryCardButton/ContentMargin/ContentColumn/Badge/BadgePadding/BadgeLabel")
const HINT_LABEL_PATH := NodePath("PreviewCenter/PreviewStack/PrimaryCardButton/ContentMargin/ContentColumn/HintLabel")
const STATUS_LABEL_PATH := NodePath("CanvasLayer/OverlayRoot/SplitRoot/ControlsPanel/Margin/ControlsColumn/StatusPanel/StatusPadding/StatusLabel")
const POINTER_ID: StringName = &"mouse_qa"
const REQUIRED_TARGET_NAMES := ["PrimaryCardButton", "SecondaryToggleChip", "DragStrip"]

var _scene_root: Node3D

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
	await _settle_frames(12)

	var report := await _collect_report()
	_write_report(report)
	print(JSON.stringify(report, "\t"))
	quit(0 if bool(report.get("ok", false)) else 2)


func _collect_report() -> Dictionary:
	var scene := _scene_root
	var bus := scene.get("interaction_bus") as AeroUiInteractionBus
	var adapter := scene.get("hybrid_input_adapter") as Node
	var panel_ui := scene.get("_panel_ui") as Control
	var mask_ui := scene.get("_mask_ui") as Control
	var status_label := scene.get_node_or_null(STATUS_LABEL_PATH) as RichTextLabel

	var primary_card := panel_ui.get_node_or_null(PRIMARY_CARD_PATH) as Button if panel_ui != null else null
	var source_label := panel_ui.get_node_or_null(SOURCE_LABEL_PATH) as Label if panel_ui != null else null
	var pointer_label := panel_ui.get_node_or_null(POINTER_LABEL_PATH) as Label if panel_ui != null else null
	var toggle_label := panel_ui.get_node_or_null(TOGGLE_LABEL_PATH) as Label if panel_ui != null else null
	var verification_label := panel_ui.get_node_or_null(VERIFICATION_LABEL_PATH) as Label if panel_ui != null else null
	var headline_label := panel_ui.get_node_or_null(HEADLINE_PATH) as Label if panel_ui != null else null
	var badge_label := panel_ui.get_node_or_null(BADGE_LABEL_PATH) as Label if panel_ui != null else null
	var hint_label := panel_ui.get_node_or_null(HINT_LABEL_PATH) as Label if panel_ui != null else null

	var bus_path: NodePath = bus.get_path() if bus != null else NodePath()
	var resolved_bus: Variant = panel_ui.call("_resolve_interaction_bus") if panel_ui != null and panel_ui.has_method("_resolve_interaction_bus") else null
	var resolved_bus_path: NodePath = resolved_bus.get_path() if resolved_bus != null else NodePath()
	var panel_specs: Array = panel_ui.call("get_interaction_target_specs") as Array if panel_ui != null and panel_ui.has_method("get_interaction_target_specs") else []
	var mask_specs: Array = mask_ui.call("get_interaction_target_specs") as Array if mask_ui != null and mask_ui.has_method("get_interaction_target_specs") else []
	var panel_bindings := _collect_binding_report(panel_ui, bus, REQUIRED_TARGET_NAMES)
	var mask_bindings := _collect_binding_report(mask_ui, bus, REQUIRED_TARGET_NAMES)

	var baseline := _capture_panel_state(primary_card, source_label, pointer_label, toggle_label, verification_label, headline_label, badge_label, hint_label, status_label)

	var connection_report := {
		"panel_override_bus_path": String(panel_ui.get("_interaction_bus_path_override")) if panel_ui != null else "",
		"mask_override_bus_path": String(mask_ui.get("_interaction_bus_path_override")) if mask_ui != null else "",
		"panel_resolved_bus_path": String(resolved_bus_path),
		"scene_bus_path": String(bus_path),
		"panel_bindings": panel_bindings,
		"mask_bindings": mask_bindings,
		"panel_target_specs": panel_specs,
		"mask_target_specs": mask_specs,
	}

	if adapter == null or primary_card == null:
		return {
			"ok": false,
			"error": "Missing runtime nodes for probe",
			"connection_report": connection_report,
			"baseline": baseline
		}

	var target_path := primary_card.get_path()
	var base_projected := {
		"target_path": target_path,
		"surface_normalized_position": Vector2(0.50, 0.50),
		"surface_position": Vector2(800.0, 450.0),
		"screen_position": Vector2(640.0, 360.0),
		"world_position": Vector3.ZERO,
		"world_normal": Vector3.FORWARD,
		"world_direction": Vector3.BACK,
		"raw_metadata": {
			"qa_probe": true,
			"target_resolution": "primary_card_path",
			"host_surface": "QA synthetic projection"
		}
	}

	var tap_sequence := [
		AeroUiInteractionTypes.PHASE_HOVER_ENTER,
		AeroUiInteractionTypes.PHASE_PRESS_BEGIN,
		AeroUiInteractionTypes.PHASE_PRESS_END
	]
	for phase in tap_sequence:
		adapter.call("publish_projected_phase", phase, POINTER_ID, base_projected, {
			"source_type": AeroUiInteractionTypes.SOURCE_TYPE_MOUSE,
			"source_variant": AeroUiInteractionTypes.SOURCE_VARIANT_SCREEN_MOUSE,
			"button": AeroUiInteractionTypes.BUTTON_PRIMARY,
			"primary": true,
			"is_synthetic": true,
			"raw_event_class": &"QaSyntheticProjectedPhase"
		})
		await _settle_frames(1)

	var after_tap := _capture_panel_state(primary_card, source_label, pointer_label, toggle_label, verification_label, headline_label, badge_label, hint_label, status_label)

	var drag_begin_projected := base_projected.duplicate(true)
	drag_begin_projected["surface_position"] = Vector2(820.0, 470.0)
	drag_begin_projected["surface_normalized_position"] = Vector2(0.5125, 0.5222)
	var drag_move_projected := base_projected.duplicate(true)
	drag_move_projected["surface_position"] = Vector2(920.0, 560.0)
	drag_move_projected["surface_normalized_position"] = Vector2(0.5750, 0.6222)

	var drag_sequence := [
		{"phase": AeroUiInteractionTypes.PHASE_PRESS_BEGIN, "data": base_projected},
		{"phase": AeroUiInteractionTypes.PHASE_DRAG_BEGIN, "data": drag_begin_projected},
		{"phase": AeroUiInteractionTypes.PHASE_DRAG_MOVE, "data": drag_move_projected},
		{"phase": AeroUiInteractionTypes.PHASE_DRAG_END, "data": drag_move_projected},
		{"phase": AeroUiInteractionTypes.PHASE_PRESS_END, "data": drag_move_projected}
	]
	for step in drag_sequence:
		adapter.call("publish_projected_phase", step["phase"], POINTER_ID, step["data"], {
			"source_type": AeroUiInteractionTypes.SOURCE_TYPE_MOUSE,
			"source_variant": AeroUiInteractionTypes.SOURCE_VARIANT_SCREEN_MOUSE,
			"button": AeroUiInteractionTypes.BUTTON_PRIMARY,
			"primary": true,
			"is_synthetic": true,
			"raw_event_class": &"QaSyntheticProjectedPhase"
		})
		await _settle_frames(1)

	var after_drag := _capture_panel_state(primary_card, source_label, pointer_label, toggle_label, verification_label, headline_label, badge_label, hint_label, status_label)

	var checks := {
		"bus_resolved_to_scene_bus": String(resolved_bus_path) == String(bus_path) and String(bus_path) != "",
		"panel_bindings_match_specs": _binding_report_matches_specs(panel_bindings, panel_specs),
		"mask_bindings_match_specs": _binding_report_matches_specs(mask_bindings, mask_specs),
		"panel_consumers_connected": bool(panel_bindings.get("all_connected", false)),
		"mask_consumers_connected": bool(mask_bindings.get("all_connected", false)),
		"panel_source_label_changed": baseline["source_label"] != after_tap["source_label"] and after_tap["source_label"].contains("screen_mouse"),
		"panel_pointer_label_changed": baseline["pointer_label"] != after_tap["pointer_label"] and after_tap["pointer_label"].contains("press_end"),
		"panel_toggle_label_changed": baseline["toggle_label"] != after_tap["toggle_label"] and after_tap["toggle_label"].contains("Primary toggle: ON") and after_tap["toggle_label"].contains("taps 1") and after_tap["toggle_label"].contains("releases 1"),
		"panel_verification_label_changed": baseline["verification_label"] != after_tap["verification_label"] and after_tap["verification_label"].contains("Verification: prototype"),
		"panel_badge_changed": baseline["badge_label"] != after_tap["badge_label"] and after_tap["badge_label"] == "Primary armed",
		"panel_headline_changed": baseline["headline_label"] != after_tap["headline_label"] and after_tap["headline_label"] == "AeroBeat INPUT CONTRACT",
		"panel_drag_counts_changed": after_drag["toggle_label"].contains("taps 1") and after_drag["toggle_label"].contains("releases 2"),
		"drag_did_not_increment_taps": after_drag["toggle_label"].contains("taps 1")
	}

	var ok := true
	for value in checks.values():
		if not bool(value):
			ok = false
			break

	return {
		"ok": ok,
		"scene": SCENE_PATH,
		"connection_report": connection_report,
		"baseline": baseline,
		"after_tap": after_tap,
		"after_drag": after_drag,
		"checks": checks
	}


func _collect_binding_report(root_node: Node, bus: AeroUiInteractionBus, required_target_names: Array) -> Dictionary:
	var bindings: Array = []
	var target_names: Array = []
	var target_keys: Array = []
	var all_connected := true
	var bus_path := String(bus.get_path()) if bus != null else ""
	if root_node != null:
		for child in root_node.get_children():
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
		"has_required_target_names": _contains_all(target_names, required_target_names),
	}


func _binding_report_matches_specs(binding_report: Dictionary, specs: Array) -> bool:
	var spec_names := _spec_names(specs)
	return int(binding_report.get("binding_count", 0)) == specs.size() \
		and bool(binding_report.get("all_connected", false)) \
		and _contains_all(binding_report.get("target_names", []), spec_names)


func _spec_names(specs: Array) -> Array:
	var names: Array = []
	for spec_variant in specs:
		if spec_variant is Dictionary:
			names.append(str((spec_variant as Dictionary).get("target_name", "")))
	return names


func _contains_all(values: Array, required: Array) -> bool:
	for item in required:
		if item not in values:
			return false
	return true


func _capture_panel_state(
	primary_card: Button,
	source_label: Label,
	pointer_label: Label,
	toggle_label: Label,
	verification_label: Label,
	headline_label: Label,
	badge_label: Label,
	hint_label: Label,
	status_label: RichTextLabel
) -> Dictionary:
	return {
		"button_pressed": primary_card.button_pressed if primary_card != null else false,
		"source_label": source_label.text if source_label != null else "",
		"pointer_label": pointer_label.text if pointer_label != null else "",
		"toggle_label": toggle_label.text if toggle_label != null else "",
		"verification_label": verification_label.text if verification_label != null else "",
		"headline_label": headline_label.text if headline_label != null else "",
		"badge_label": badge_label.text if badge_label != null else "",
		"hint_label": hint_label.text if hint_label != null else "",
		"status_label": status_label.text if status_label != null else ""
	}


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
