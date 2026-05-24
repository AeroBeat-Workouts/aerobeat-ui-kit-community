extends GutTest

const SUPPORT := preload("res://tests/support/hybrid_mouse_test_support.gd")
const INSTALLED_MOUSE_PROVIDER_PATH := "res://addons/aerobeat-spatial-ui-mouse/src/providers/mouse/aero_spatial_ui_mouse_provider.gd"

func test_hybrid_scene_reads_installed_packaged_mouse_provider_runtime_snapshot() -> void:
	var support = SUPPORT.new()
	var scene = await support.spawn_hybrid_scene(self)
	var screen_pos = support.primary_button_screen_position(scene)

	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = screen_pos
	assert_true(scene._publish_mouse_button_to_contract(press))

	var drag := InputEventMouseMotion.new()
	drag.position = screen_pos + Vector2(120.0, 0.0)
	drag.relative = Vector2(120.0, 0.0)
	drag.button_mask = MOUSE_BUTTON_MASK_LEFT
	assert_true(scene._publish_mouse_motion_to_contract(drag))

	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.pressed = false
	release.position = screen_pos + Vector2(120.0, 0.0)
	assert_true(scene._publish_mouse_button_to_contract(release))

	var snapshot: Dictionary = scene.describe_mouse_verification_snapshot()
	assert_eq(str(snapshot.get("provider_lane", "")), "mouse")
	assert_true(bool(snapshot.get("packaged_provider_active", false)))
	assert_eq(str(snapshot.get("provider_runtime_source", "")), "AeroSpatialUiMouseProvider (installed packaged seam)")
	assert_eq(str(snapshot.get("provider_runtime_path", "")), INSTALLED_MOUSE_PROVIDER_PATH)
	assert_eq(str(snapshot.get("source_variant", "")), "screen_mouse")
	assert_eq(str(snapshot.get("phase", "")), "press_end")
	assert_string_contains(str(snapshot.get("target_path", "")), "PrimaryActionButton")
	assert_eq(str(snapshot.get("verification_status", "")), "prototype")
	assert_string_contains(str(snapshot.get("verification_notes", "")), "not fully proven")
	assert_string_contains(str(snapshot.get("hover_target_path", "")), "PrimaryActionButton")
	assert_eq(str(snapshot.get("capture_target_path", "not-empty")), "")
	assert_false(bool(snapshot.get("left_button_down", true)))
	assert_string_contains(str(snapshot.get("last_live_target_path", "")), "PrimaryActionButton")
	assert_string_contains(str(snapshot.get("last_release_target_path", "")), "PrimaryActionButton")
	assert_string_contains(str(snapshot.get("last_forwarded_panel_event", "")), "publish mouse release")
