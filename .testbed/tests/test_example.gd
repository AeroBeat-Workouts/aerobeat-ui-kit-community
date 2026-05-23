extends GutTest

const ADDONS_MANIFEST_PATH := "res://addons.jsonc"

func test_hidden_testbed_manifest_stays_ui_kit_focused() -> void:
	var manifest_text := FileAccess.get_file_as_string(ADDONS_MANIFEST_PATH)

	assert_ne(manifest_text, "", "Expected the hidden testbed manifest to be readable")
	assert_string_contains(manifest_text, '"aerobeat-ui-core"', "Expected the hidden testbed to pin aerobeat-ui-core for shared UI-kit validation")
	assert_false(manifest_text.contains('"aerobeat-core"'), "Hidden testbed must not pin aerobeat-core for this UI-kit-focused repo")
	assert_string_contains(manifest_text, '"aerobeat-input-core"', "Hybrid contract proof should pin aerobeat-input-core in the hidden testbed")

	var addon_keys := _extract_addon_keys(manifest_text)
	assert_string_contains(manifest_text, '"aerobeat-spatial-ui-core"', "Hybrid spatial cutover should pin aerobeat-spatial-ui-core in the hidden testbed")
	assert_string_contains(manifest_text, '"aerobeat-spatial-ui-mouse"', "Hybrid spatial cutover should pin aerobeat-spatial-ui-mouse in the hidden testbed")
	assert_string_contains(manifest_text, '"aerobeat-spatial-ui-touch"', "Hybrid touch cutover should pin aerobeat-spatial-ui-touch in the hidden testbed")
	assert_string_contains(manifest_text, '"checkout": "54a8d036323a9cc4c367dcebcd1381fa260eede0"', "Hybrid consumer proof should pin the packaged resolver-capable aerobeat-spatial-ui-mouse commit")
	assert_string_contains(manifest_text, '"checkout": "187c7a4414651f588dba690e82ea46966adbc89f"', "Hybrid touch proof should pin the packaged touch-provider probe-helper seam commit")
	assert_eq(addon_keys, ["aerobeat-ui-kit-community", "aerobeat-ui-core", "aerobeat-input-core", "aerobeat-spatial-ui-core", "aerobeat-spatial-ui-mouse", "aerobeat-spatial-ui-touch", "gut"], "Hidden testbed should only declare the repo-local package plus approved shared interaction-contract/spatial-provider dependencies")

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
