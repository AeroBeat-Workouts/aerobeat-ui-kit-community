extends GutTest

const SUPPORT := preload("res://tests/support/hybrid_mouse_test_support.gd")

func test_mouse_off_surface_release_completes_against_press_owner_and_clears_runtime() -> void:
	var support = SUPPORT.new()
	var scene = await support.spawn_hybrid_scene(self)
	var screen_pos = support.primary_button_screen_position(scene)
	var off_surface_pos := Vector2(0.0, 0.0)

	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = screen_pos
	assert_true(scene._publish_mouse_button_to_contract(press))

	var motion := InputEventMouseMotion.new()
	motion.position = off_surface_pos
	motion.relative = off_surface_pos - screen_pos
	motion.button_mask = MOUSE_BUTTON_MASK_LEFT
	assert_true(scene._publish_mouse_motion_to_contract(motion))

	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.pressed = false
	release.position = off_surface_pos
	assert_true(scene._publish_mouse_button_to_contract(release))

	var mouse_state: Dictionary = scene._current_mouse_runtime_state()
	var projected_data: Dictionary = mouse_state.get("last_projected_data", {})
	var raw_metadata: Dictionary = projected_data.get("raw_metadata", {})
	assert_eq(scene._last_contract_phase, "press_end")
	assert_true(support.primary_toggle_on(scene))
	assert_eq(support.primary_card(scene).button_pressed, true)
	assert_false(bool(mouse_state.get("left_button_down", true)))
	assert_false(bool(mouse_state.get("capture_active", true)))
	assert_false(bool(mouse_state.get("hover_active", true)))
	assert_string_contains(str(mouse_state.get("last_release_target_path", "")), "PrimaryActionButton")
	assert_true(bool(raw_metadata.get("off_surface_continuation", false)))
	assert_string_contains(str(raw_metadata.get("published_target_path", "")), "PrimaryActionButton")
	assert_string_contains(str(scene.describe_mouse_verification_snapshot().get("last_forwarded_panel_event", "")), "publish mouse release")
