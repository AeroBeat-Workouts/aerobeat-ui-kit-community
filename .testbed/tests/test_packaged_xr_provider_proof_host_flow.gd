extends GutTest

const HARNESS_SCRIPT := preload("res://tests/support/xr_provider_proof_host_harness.gd")
const XR_PROOF_HOST_SCRIPT_PATH := "res://scripts/glass_shader_xr_provider_proof.gd"

func test_proof_host_routes_packaged_press_drag_release_and_cancel_through_consumer_owned_hits() -> void:
	var host_source := FileAccess.get_file_as_string(XR_PROOF_HOST_SCRIPT_PATH)
	assert_string_contains(host_source, "func _build_hit_for_target_key(target_key: String) -> Dictionary:")
	assert_string_contains(host_source, "func trigger_interruption(reason := \"tracking_lost\") -> bool:")
	assert_string_contains(host_source, '"host_surface": "XrProofPanelSurface"')

	var harness = HARNESS_SCRIPT.new()
	var scene = await harness.spawn(self)

	assert_true(scene.simulate_press_primary("xr_direct", "contact"))
	assert_true(scene.simulate_drag_to_secondary("xr_ray", "trigger"))

	var active_summary: Dictionary = scene._current_xr_interaction_summary()
	assert_true(bool(active_summary.get("is_xr_active", false)))
	assert_eq(str(active_summary.get("preferred_target_label", "")), "PrimaryActionButton")
	assert_eq(str(active_summary.get("live_target_label", "")), "SecondaryActionButton")
	assert_eq(str(active_summary.get("locked_source_variant", "")), "xr_direct")
	assert_eq(str(active_summary.get("active_button", "")), "contact")
	assert_eq(str(active_summary.get("state_phase", "")), "drag_begin")

	assert_true(scene.simulate_release_off_surface("xr_ray", "trigger"))
	var release_summary: Dictionary = scene._current_xr_interaction_summary()
	assert_false(bool(release_summary.get("is_xr_active", true)))
	assert_eq(str(release_summary.get("last_release_target_label", "")), "PrimaryActionButton")
	assert_eq(str(release_summary.get("last_terminal_result", "")), "release")
	assert_eq(str(release_summary.get("last_interruption_reason", "not-empty")), "")
	assert_string_contains(scene.get_summary_debug_text(), "last_terminal_result=release")

	assert_true(scene.simulate_press_primary("xr_ray", "trigger"))
	assert_true(scene.trigger_interruption("tracking_lost"))
	var cancel_summary: Dictionary = scene._current_xr_interaction_summary()
	assert_false(bool(cancel_summary.get("is_xr_active", true)))
	assert_eq(str(cancel_summary.get("last_terminal_result", "")), "cancel")
	assert_eq(str(cancel_summary.get("last_interruption_reason", "")), "tracking_lost")
	assert_eq(str(cancel_summary.get("verification_status", "")), "unverified")
	assert_string_contains(scene.get_summary_debug_text(), "last_interruption_reason=tracking_lost")
	assert_string_contains(scene.get_event_debug_text(), "tracking_lost")

	var events: Array = scene.get_captured_events()
	assert_eq(harness.event_phases(events), ["press_begin", "drag_begin", "drag_end", "press_end", "press_begin", "cancel"])
	assert_eq(str(events[0].verification_status), "unverified")
	assert_string_contains(str(events[2].target_path), "PrimaryActionButton")
	assert_string_contains(str(events[3].target_path), "PrimaryActionButton")
