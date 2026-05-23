extends GutTest

const HARNESS_SCRIPT := preload("res://tests/support/xr_packaged_provider_test_harness.gd")
const INSTALLED_XR_PROVIDER_PATH := "res://addons/aerobeat-spatial-ui-xr/src/providers/xr/aero_spatial_ui_xr_provider.gd"
const PACKAGED_RESOLVER_PATH := "res://addons/aerobeat-spatial-ui-core/src/helpers/providers/aero_spatial_rect_target_resolver.gd"

func test_installed_xr_provider_uses_packaged_helpers_without_reowning_host_world_hits() -> void:
	var provider_source := FileAccess.get_file_as_string(INSTALLED_XR_PROVIDER_PATH)

	assert_ne(provider_source, "", "Expected the installed spatial XR provider script to be readable from the hidden testbed")
	assert_string_contains(provider_source, 'const RECT_TARGET_RESOLVER_SCRIPT_PATH := "%s"' % PACKAGED_RESOLVER_PATH)
	assert_string_contains(provider_source, 'const SUPPORTED_SOURCE_VARIANTS := [')
	assert_string_contains(provider_source, '"xr_ray"')
	assert_string_contains(provider_source, '"xr_direct"')
	assert_string_contains(provider_source, "func publish_pointer_update(")
	assert_string_contains(provider_source, "func resolve_target_path_for_hit(surface, projected_hit: Dictionary) -> NodePath:")
	assert_string_contains(provider_source, "func build_projected_data_for_hit(")
	assert_string_contains(provider_source, "var resolution_result = _target_resolver.resolve_target(surface, projected_hit)")
	assert_false(provider_source.contains("project_ray_origin"))
	assert_false(provider_source.contains("intersect_ray"))
	assert_false(provider_source.contains("XROrigin3D"))
	assert_false(provider_source.contains("XRController3D"))

func test_packaged_xr_provider_preserves_owner_continuity_variant_truth_and_release_order() -> void:
	var harness = HARNESS_SCRIPT.new()
	var runtime = await harness.spawn(self, 12.0)
	var provider = runtime["provider"]
	var adapter = runtime["adapter"]
	var surface = runtime["surface"]
	var events: Array = runtime["events"]

	var press_hit := harness.build_hit(surface, Vector2(0.20, 0.20), Vector2(200.0, 200.0))
	assert_true(provider.publish_pointer_update(adapter, surface, harness.make_press("xr_right", "xr_direct", "contact"), press_hit))

	var drag_begin_hit := harness.build_hit(surface, Vector2(0.24, 0.20), Vector2(240.0, 200.0))
	assert_true(provider.publish_pointer_update(adapter, surface, harness.make_move("xr_right", "xr_ray", "trigger"), drag_begin_hit))
	assert_eq(str(events[1].phase), "drag_begin")
	assert_eq(str(events[1].source_variant), "xr_direct")
	assert_eq(str(events[1].button), "contact")

	var drag_move_hit := harness.build_hit(surface, Vector2(0.70, 0.20), Vector2(700.0, 200.0))
	assert_true(provider.publish_pointer_update(adapter, surface, harness.make_move("xr_right", "xr_ray", "trigger"), drag_move_hit))
	assert_eq(str(events[2].phase), "drag_move")
	assert_eq(str(events[2].target_path), "Root/PrimaryActionButton")
	assert_eq(str(events[2].source_variant), "xr_direct")
	assert_eq(str(events[2].verification_status), "unverified")
	assert_eq(str(events[2].raw_metadata.get("live_target_path", "")), "Root/SecondaryActionButton")

	assert_true(provider.publish_pointer_update(
		adapter,
		surface,
		harness.make_release("xr_right", "xr_ray", "trigger"),
		harness.build_off_surface_hit(Vector2(900.0, 900.0))
	))

	assert_eq(harness.event_phases(events), ["press_begin", "drag_begin", "drag_move", "drag_end", "press_end"])
	assert_eq(str(events[3].target_path), "Root/PrimaryActionButton")
	assert_eq(str(events[4].target_path), "Root/PrimaryActionButton")
	assert_eq(str(events[4].source_variant), "xr_direct")
