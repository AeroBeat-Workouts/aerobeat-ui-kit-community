extends GutTest

const HARNESS_SCRIPT := preload("res://tests/support/xr_provider_proof_host_harness.gd")
const XR_PROOF_SCENE := preload("res://scenes/glass-shader-xr-provider-proof.tscn")
const INSTALLED_XR_PROVIDER_PATH := "res://addons/aerobeat-spatial-ui-xr/src/providers/xr/aero_spatial_ui_xr_provider.gd"
const XR_PROOF_HOST_SCRIPT_PATH := "res://scripts/glass_shader_xr_provider_proof.gd"

func test_installed_xr_provider_exposes_summary_api_and_proof_host_consumes_it_directly() -> void:
	var provider_source := FileAccess.get_file_as_string(INSTALLED_XR_PROVIDER_PATH)
	var host_source := FileAccess.get_file_as_string(XR_PROOF_HOST_SCRIPT_PATH)

	assert_ne(provider_source, "", "Expected the installed XR provider script to be readable from the hidden testbed")
	assert_ne(host_source, "", "Expected the XR proof-host script to be readable from the hidden testbed")
	assert_string_contains(provider_source, "func describe_interaction_summary() -> Dictionary:")
	assert_string_contains(provider_source, '"last_terminal_result": _last_terminal_result')
	assert_string_contains(provider_source, '"last_interruption_reason": _last_interruption_reason')
	assert_string_contains(host_source, "return _spatial_xr_provider.describe_interaction_summary() if _spatial_xr_provider != null else {}")
	assert_string_contains(host_source, '"target_resolution": "rect_target_specs"')
	assert_string_contains(host_source, "func _build_hit_for_target_key(target_key: String) -> Dictionary:")
	assert_false(host_source.contains('"preferred_target_label":'))
	assert_false(host_source.contains('"last_terminal_result": "cancel"'))


func test_proof_host_hover_reads_packaged_summary_without_local_reassembly() -> void:
	var harness = HARNESS_SCRIPT.new()
	var scene = await harness.spawn(self)

	assert_true(scene.is_ready_for_proof())
	assert_true(scene.simulate_hover_primary("xr_ray", "trigger"))

	var summary: Dictionary = scene._current_xr_interaction_summary()
	assert_false(bool(summary.get("is_xr_active", true)))
	assert_eq(str(summary.get("preferred_target_label", "")), "PrimaryActionButton")
	assert_eq(str(summary.get("live_target_label", "")), "PrimaryActionButton")
	assert_eq(str(summary.get("locked_source_variant", "")), "xr_ray")
	assert_eq(str(summary.get("verification_status", "")), "unverified")
	assert_string_contains(scene.get_summary_debug_text(), "preferred_target=PrimaryActionButton")
	assert_string_contains(scene.get_event_debug_text(), "observe xr hover")
	var proof_instance := XR_PROOF_SCENE.instantiate()
	assert_eq(proof_instance.get_script().resource_path, XR_PROOF_HOST_SCRIPT_PATH)
	proof_instance.queue_free()
