extends GutTest

const ADDONS_MANIFEST_PATH := "res://addons.jsonc"

func test_hidden_testbed_manifest_stays_ui_kit_focused() -> void:
	var manifest_text := FileAccess.get_file_as_string(ADDONS_MANIFEST_PATH)

	assert_ne(manifest_text, "", "Expected the hidden testbed manifest to be readable")
	assert_string_contains(manifest_text, '"aerobeat-ui-core"', "Expected the hidden testbed to pin aerobeat-ui-core for shared UI-kit validation")
	assert_false(manifest_text.contains('"aerobeat-core"'), "Hidden testbed must not pin aerobeat-core for this UI-kit-focused repo")

	var addon_keys := _extract_addon_keys(manifest_text)
	assert_eq(addon_keys, ["aerobeat-ui-core", "gut"], "Hidden testbed should only declare ui-kit-scoped dependencies")

func _extract_addon_keys(manifest_text: String) -> Array[String]:
	var keys: Array[String] = []
	var in_addons_block := false

	for raw_line in manifest_text.split("\n"):
		var line := raw_line.strip_edges()
		if line.begins_with("//") or line == "":
			continue
		if line.begins_with('"addons"'):
			in_addons_block = true
			continue
		if not in_addons_block:
			continue
		if line == "}":
			break
		if not (line.begins_with('"') and line.ends_with("{")):
			continue

		var closing_quote_index := line.find('"', 1)
		if closing_quote_index == -1:
			continue

		keys.append(line.substr(1, closing_quote_index - 1))

	return keys
