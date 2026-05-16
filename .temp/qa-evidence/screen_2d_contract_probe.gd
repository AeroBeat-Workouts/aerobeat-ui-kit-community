extends SceneTree

const TEST_SCENE := preload("res://scenes/glass-shader-test.tscn")
const PANEL_SOURCE_SCENE := preload("res://scenes/glass-shader-panel-source.tscn")
const OUT_JSON := "/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/.temp/qa-evidence/screen_2d_contract_probe.json"
const PRIMARY_CARD_PATH := "PreviewCenter/PreviewStack/PrimaryCardButton"
const REQUIRED_TARGET_NAMES := ["PrimaryCardButton", "SecondaryToggleChip", "DragStrip"]

func _initialize() -> void:
	var result := {
		"scene_probe": await _probe_screen_scene(),
		"shared_panel_configs": await _probe_shared_panel_configs(),
	}
	DirAccess.make_dir_recursive_absolute(OUT_JSON.get_base_dir())
	var file := FileAccess.open(OUT_JSON, FileAccess.WRITE)
	if file == null:
		push_error("Failed to open %s" % OUT_JSON)
		quit(1)
		return
	file.store_string(JSON.stringify(result, "\t"))
	file.close()
	print("WROTE=%s" % OUT_JSON)
	print(JSON.stringify(result, "\t"))
	quit(0 if _result_ok(result) else 2)


func _probe_screen_scene() -> Dictionary:
	var scene := TEST_SCENE.instantiate() as Control
	root.add_child(scene)
	await _settle(8)

	var proof_button := scene.get("_proof_button") as Control
	var bus := scene.get_node("SplitRoot/PreviewArea/PreviewCenter/PanelSourceHost/AeroUiInteractionBus") as AeroUiInteractionBus
	var adapter := scene.get("screen_input_adapter") as Node
	var panel_source := scene.get("_panel_source") as Control
	var binding_report := _collect_binding_report(panel_source, bus)
	var source_label: Label = proof_button.get_node("ContentMargin/ContentColumn/InteractionStatePanel/InteractionStatePadding/InteractionStateColumn/InteractionSourceLabel") as Label
	var pointer_label: Label = proof_button.get_node("ContentMargin/ContentColumn/InteractionStatePanel/InteractionStatePadding/InteractionStateColumn/InteractionPointerLabel") as Label
	var toggle_label: Label = proof_button.get_node("ContentMargin/ContentColumn/InteractionStatePanel/InteractionStatePadding/InteractionStateColumn/InteractionToggleLabel") as Label
	var count_label: Label = proof_button.get_node("ContentMargin/ContentColumn/InteractionStatePanel/InteractionStatePadding/InteractionStateColumn/InteractionCountLabel") as Label
	var badge_label: Label = proof_button.get_node("ContentMargin/ContentColumn/Badge/BadgePadding/BadgeLabel") as Label
	var body_label: Label = proof_button.get_node("ContentMargin/ContentColumn/Body") as Label
	var hint_label: Label = proof_button.get_node("ContentMargin/ContentColumn/HintLabel") as Label
	var status_label: RichTextLabel = scene.get("_contract_status_label") as RichTextLabel
	var center := proof_button.get_global_rect().get_center()
	var outside := proof_button.get_global_rect().end + Vector2(32.0, 24.0)

	var baseline := _capture_labels(source_label, pointer_label, toggle_label, count_label, badge_label, body_label, hint_label, status_label, scene, adapter, bus, proof_button, binding_report)

	scene._unhandled_input(_mouse_motion(center, Vector2.ZERO))
	await _settle(2)
	var after_hover := _capture_labels(source_label, pointer_label, toggle_label, count_label, badge_label, body_label, hint_label, status_label, scene, adapter, bus, proof_button, binding_report)

	scene._unhandled_input(_mouse_button(center, true))
	await _settle(2)
	var after_press := _capture_labels(source_label, pointer_label, toggle_label, count_label, badge_label, body_label, hint_label, status_label, scene, adapter, bus, proof_button, binding_report)

	scene._unhandled_input(_mouse_motion(outside, outside - center))
	await _settle(2)
	var after_drag_outside := _capture_labels(source_label, pointer_label, toggle_label, count_label, badge_label, body_label, hint_label, status_label, scene, adapter, bus, proof_button, binding_report)

	scene._unhandled_input(_mouse_button(outside, false))
	await _settle(2)
	var after_release := _capture_labels(source_label, pointer_label, toggle_label, count_label, badge_label, body_label, hint_label, status_label, scene, adapter, bus, proof_button, binding_report)

	scene._unhandled_input(_screen_touch(center, 3, true))
	await _settle(2)
	scene._unhandled_input(_screen_drag(outside, outside - center, 3))
	await _settle(2)
	scene._unhandled_input(_screen_touch(outside, 3, false))
	await _settle(2)
	var after_touch := _capture_labels(source_label, pointer_label, toggle_label, count_label, badge_label, body_label, hint_label, status_label, scene, adapter, bus, proof_button, binding_report)

	var result := {
		"binding_report": binding_report,
		"baseline": baseline,
		"after_hover": after_hover,
		"after_press": after_press,
		"after_drag_outside": after_drag_outside,
		"after_release": after_release,
		"after_touch": after_touch,
		"assertions": {
			"bus_present": bus != null,
			"adapter_present": adapter != null,
			"proof_button_present": proof_button != null,
			"binding_layout_matches_specs": _binding_report_matches_specs(binding_report, panel_source.call("get_interaction_target_specs") as Array),
			"hover_updates_source_label": after_hover["source_label"].contains("screen_mouse"),
			"hover_updates_pointer_label": after_hover["pointer_label"].contains("hover_"),
			"press_updates_phase": after_press["pointer_label"].contains("press_begin"),
			"drag_updates_phase": after_drag_outside["pointer_label"].contains("drag_") or after_drag_outside["pointer_label"].contains("press_hold"),
			"release_updates_primary_release_count": after_release["toggle_label"].contains("Primary toggle: OFF") and after_release["toggle_label"].contains("releases 1") and after_release["badge_label"] == "Screen contract proof",
			"release_host_and_card_agree_on_source": after_release["status_label"].contains("Source variant: screen_mouse") and after_release["source_label"].contains("screen_mouse"),
			"release_host_and_card_agree_on_phase": after_release["status_label"].contains("Phase: press_end") and after_release["pointer_label"].contains("press_end"),
			"release_host_status_preserves_surface_id": after_release["status_label"].contains("Surface ID: screen_glass_panel") and after_release["proof_button_path"].contains("PrimaryCardButton"),
			"release_host_and_card_agree_on_verification": after_release["status_label"].contains("Verification: prototype") and after_release["count_label"].contains("Verification: prototype"),
			"touch_updates_source_label": after_touch["source_label"].contains("screen_touch"),
			"touch_updates_verification_to_unverified": after_touch["count_label"].contains("Verification: unverified") and after_touch["status_label"].contains("Verification: unverified"),
			"host_glue_summary_mentions_small_scope": after_release["status_label"].contains("Host-owned truth stays small here"),
		}
	}

	scene.queue_free()
	await _settle(2)
	return result


func _probe_shared_panel_configs() -> Dictionary:
	var results := {}
	results["screen_glass_panel"] = await _probe_panel_surface(&"screen_glass_panel", "screen_2d", "Screen contract proof")
	results["hybrid_glass_panel"] = await _probe_panel_surface(&"hybrid_glass_panel", "hybrid_3d_gui", "Hybrid contract proof")
	return results


func _probe_panel_surface(surface_id: StringName, surface_type_label: String, mode_label: String) -> Dictionary:
	var host := Control.new()
	host.name = "Host_%s" % String(surface_id)
	root.add_child(host)
	var bus := AeroUiInteractionBus.new()
	bus.name = "AeroUiInteractionBus"
	host.add_child(bus)

	var panel := PANEL_SOURCE_SCENE.instantiate() as Control
	host.add_child(panel)
	await _settle(4)
	panel.call("set_interaction_bus_path", bus.get_path())
	panel.call("configure_interaction_contract", {
		"surface_id": surface_id,
		"surface_type_label": surface_type_label,
		"mode_label": mode_label,
		"host_summary": "%s summary" % mode_label,
	})
	await _settle(4)

	var primary_card := panel.get_node(PRIMARY_CARD_PATH) as Button
	var source_label: Label = primary_card.get_node("ContentMargin/ContentColumn/InteractionStatePanel/InteractionStatePadding/InteractionStateColumn/InteractionSourceLabel") as Label
	var pointer_label: Label = primary_card.get_node("ContentMargin/ContentColumn/InteractionStatePanel/InteractionStatePadding/InteractionStateColumn/InteractionPointerLabel") as Label
	var toggle_label: Label = primary_card.get_node("ContentMargin/ContentColumn/InteractionStatePanel/InteractionStatePadding/InteractionStateColumn/InteractionToggleLabel") as Label
	var count_label: Label = primary_card.get_node("ContentMargin/ContentColumn/InteractionStatePanel/InteractionStatePadding/InteractionStateColumn/InteractionCountLabel") as Label
	var badge_label: Label = primary_card.get_node("ContentMargin/ContentColumn/Badge/BadgePadding/BadgeLabel") as Label
	var body_label: Label = primary_card.get_node("ContentMargin/ContentColumn/Body") as Label
	var hint_label: Label = primary_card.get_node("ContentMargin/ContentColumn/HintLabel") as Label
	var binding_report := _collect_binding_report(panel, bus)

	bus.publish({
		"source_type": AeroUiInteractionTypes.SOURCE_TYPE_MOUSE,
		"source_variant": AeroUiInteractionTypes.SOURCE_VARIANT_SCREEN_MOUSE,
		"surface_type": StringName(surface_type_label),
		"surface_id": surface_id,
		"phase": AeroUiInteractionTypes.PHASE_PRESS_END,
		"target_path": primary_card.get_path(),
		"screen_position": Vector2(800, 450),
		"surface_position": Vector2(800, 450),
		"surface_normalized_position": Vector2(0.5, 0.5),
		"button": AeroUiInteractionTypes.BUTTON_PRIMARY,
		"pressed": false,
		"is_synthetic": true,
	})
	await _settle(4)

	var result := {
		"resolved_bus_path": str(panel.call("_resolve_interaction_bus").get_path()),
		"binding_report": binding_report,
		"source_label": source_label.text,
		"pointer_label": pointer_label.text,
		"toggle_label": toggle_label.text,
		"count_label": count_label.text,
		"badge_label": badge_label.text,
		"body_label": body_label.text,
		"hint_label": hint_label.text,
		"assertions": {
			"binding_layout_matches_specs": _binding_report_matches_specs(binding_report, panel.call("get_interaction_target_specs") as Array),
			"source_mentions_mouse": source_label.text.contains("screen_mouse"),
			"toggle_reflects_primary_release": toggle_label.text.contains("Primary toggle: ON") and toggle_label.text.contains("taps 1") and toggle_label.text.contains("releases 1"),
			"count_mentions_verification": count_label.text.contains("Verification: prototype"),
			"badge_matches_current_primary_state": badge_label.text == "Primary armed",
			"body_uses_host_summary": body_label.text == "%s summary" % mode_label,
			"hint_keeps_current_guidance": hint_label.text.contains("Touch remains unverified") and hint_label.text.contains("hybrid mouse remains prototype"),
		}
	}

	host.queue_free()
	await _settle(2)
	return result


func _collect_binding_report(panel: Control, bus: AeroUiInteractionBus) -> Dictionary:
	var bindings: Array = []
	var target_names: Array = []
	var target_keys: Array = []
	var all_connected := true
	var bus_path := String(bus.get_path()) if bus != null else ""
	for child in panel.get_children():
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
		"has_required_target_names": _contains_all(target_names, REQUIRED_TARGET_NAMES),
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


func _result_ok(result: Dictionary) -> bool:
	if not _all_true(result["scene_probe"]["assertions"]):
		return false
	for config in result["shared_panel_configs"].values():
		if not _all_true(config["assertions"]):
			return false
	return true


func _all_true(values: Dictionary) -> bool:
	for value in values.values():
		if not bool(value):
			return false
	return true


func _capture_labels(source_label: Label, pointer_label: Label, toggle_label: Label, count_label: Label, badge_label: Label, body_label: Label, hint_label: Label, status_label: RichTextLabel, scene: Node, adapter: Node, bus: Node, proof_button: Control, binding_report: Dictionary) -> Dictionary:
	return {
		"source_label": source_label.text,
		"pointer_label": pointer_label.text,
		"toggle_label": toggle_label.text,
		"count_label": count_label.text,
		"badge_label": badge_label.text,
		"body_label": body_label.text,
		"hint_label": hint_label.text,
		"status_label": status_label.text,
		"mouse_capture": scene.get("_mouse_card_capture"),
		"mouse_hover_active": scene.get("_mouse_hover_active"),
		"active_touch_capture_size": (scene.get("_active_touch_capture") as Dictionary).size(),
		"adapter_parent_path": str(adapter.get_parent().get_path()) if adapter != null and adapter.get_parent() != null else "",
		"bus_path": str(bus.get_path()),
		"proof_button_path": str(proof_button.get_path()),
		"binding_report": binding_report,
	}


func _mouse_motion(position: Vector2, relative: Vector2) -> InputEventMouseMotion:
	var event := InputEventMouseMotion.new()
	event.position = position
	event.global_position = position
	event.relative = relative
	return event


func _mouse_button(position: Vector2, pressed: bool) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.position = position
	event.global_position = position
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	return event


func _screen_touch(position: Vector2, index: int, pressed: bool) -> InputEventScreenTouch:
	var event := InputEventScreenTouch.new()
	event.position = position
	event.index = index
	event.pressed = pressed
	return event


func _screen_drag(position: Vector2, relative: Vector2, index: int) -> InputEventScreenDrag:
	var event := InputEventScreenDrag.new()
	event.position = position
	event.relative = relative
	event.index = index
	return event


func _settle(count: int) -> void:
	for _i in range(count):
		await process_frame
