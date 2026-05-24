extends GutTest

const SUPPORT := preload("res://tests/support/hybrid_mouse_test_support.gd")

func test_verification_hud_exposes_contract_fields_and_mouse_runtime_snapshot() -> void:
	var support = SUPPORT.new()
	var scene = await support.spawn_hybrid_scene(self)
	var screen_pos = support.primary_button_screen_position(scene)

	var motion := InputEventMouseMotion.new()
	motion.position = screen_pos
	motion.relative = Vector2.ZERO
	motion.button_mask = 0
	assert_true(scene._publish_mouse_motion_to_contract(motion))

	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = screen_pos
	assert_true(scene._publish_mouse_button_to_contract(press))

	var snapshot: Dictionary = scene.describe_mouse_verification_snapshot()
	assert_eq(str(snapshot.get("provider_lane", "")), "mouse")
	assert_true(bool(snapshot.get("packaged_provider_active", false)))
	assert_string_contains(str(snapshot.get("provider_runtime_source", "")), "AeroSpatialUiMouseProvider")
	assert_eq(str(snapshot.get("source_variant", "")), "screen_mouse")
	assert_eq(str(snapshot.get("phase", "")), "press_begin")
	assert_string_contains(str(snapshot.get("target_path", "")), "PrimaryActionButton")
	assert_eq(str(snapshot.get("verification_status", "")), "prototype")
	assert_string_contains(str(snapshot.get("verification_notes", "")), "not fully proven")
	assert_string_contains(str(snapshot.get("hover_target_path", "")), "PrimaryActionButton")
	assert_string_contains(str(snapshot.get("capture_target_path", "")), "PrimaryActionButton")
	assert_true(bool(snapshot.get("left_button_down", false)))
	assert_string_contains(str(snapshot.get("last_live_target_path", "")), "PrimaryActionButton")
	assert_eq(str(snapshot.get("last_release_target_path", "not-yet")), "")
	assert_string_contains(str(snapshot.get("last_forwarded_panel_event", "")), "publish mouse press")
	assert_string_contains(scene._contract_status_label.text, "Hybrid input verification HUD")
	assert_string_contains(scene._contract_status_label.text, "Packaged provider active")
	assert_string_contains(scene._contract_status_label.text, "hover_target_path")
