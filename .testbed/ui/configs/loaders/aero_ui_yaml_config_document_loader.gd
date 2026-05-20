extends RefCounted
class_name AeroUiYamlConfigDocumentLoader

# Intentionally narrow helper for the first YAML-backed seam.
# Supported today: mapping-root documents, indentation-based nested mappings,
# inline arrays/dictionaries, scalar values, comments, and path resolution.
# Deferred on purpose: block-list syntax, anchors/aliases, multiline scalars,
# multi-document YAML, and broader schema hardening beyond schema-specific loaders.
const PRESET_ROOT := "res://ui/presets"


static func load_document(path: String) -> Dictionary:
	var normalized_path := _normalize_resource_path(path)
	if normalized_path == "":
		push_error("AeroUiYamlConfigDocumentLoader.load_document received an empty path")
		return {}

	if not FileAccess.file_exists(normalized_path):
		push_error("YAML preset does not exist: %s" % normalized_path)
		return {}

	var raw_text := FileAccess.get_file_as_string(normalized_path)
	if raw_text == "":
		push_error("YAML preset was empty or unreadable: %s" % normalized_path)
		return {}

	var parsed := _parse_mapping_document(raw_text)
	if parsed.is_empty():
		push_error("Failed to parse YAML preset: %s" % normalized_path)
		return {}

	parsed["__source_path"] = normalized_path
	return parsed


static func merge_documents(base: Dictionary, override: Dictionary) -> Dictionary:
	var merged := _deep_copy_dictionary(base)
	for key_variant in override.keys():
		var key := str(key_variant)
		if key == "extends" or key == "__source_path":
			continue

		var incoming: Variant = override[key_variant]
		if merged.has(key) and merged[key] is Dictionary and incoming is Dictionary:
			merged[key] = merge_documents(merged[key] as Dictionary, incoming as Dictionary)
		else:
			merged[key] = _deep_copy_variant(incoming)
	return merged


static func resolve_reference_path(reference_value: Variant, current_path: String) -> String:
	if not (reference_value is String):
		return ""

	var raw_reference := String(reference_value).strip_edges()
	if raw_reference == "" or raw_reference == "null":
		return ""

	var candidate := raw_reference
	if candidate.begins_with("res://"):
		return _ensure_yaml_extension(candidate)
	if candidate.begins_with("./") or candidate.begins_with("../"):
		return _ensure_yaml_extension(_normalize_resource_path(current_path.get_base_dir().path_join(candidate)))
	if candidate.begins_with("/"):
		return _ensure_yaml_extension(candidate)
	return _ensure_yaml_extension(PRESET_ROOT.path_join(candidate))


static func validate_document_schema(document: Dictionary, expected_schema: String, config_family_name: String) -> bool:
	if document.is_empty():
		return false

	var actual_schema := str(document.get("schema", ""))
	if actual_schema == expected_schema:
		return true

	var source_path := str(document.get("__source_path", "<memory>"))
	var actual_label := actual_schema if actual_schema != "" else "<missing>"
	push_error("%s preset schema mismatch in %s: expected %s, got %s" % [config_family_name, source_path, expected_schema, actual_label])
	return false


static func _parse_mapping_document(text: String) -> Dictionary:
	var root: Dictionary = {}
	var stack: Array[Dictionary] = [{"indent": -1, "container": root}]

	for raw_line in text.split("\n"):
		var line := _strip_comment(raw_line.rstrip("\r"))
		if line.strip_edges() == "":
			continue

		var indent := _indent_width(line)
		var trimmed := line.strip_edges()
		var colon_index := _find_top_level_delimiter(trimmed, ":")
		if colon_index == -1:
			push_error("Unsupported YAML line (missing top-level colon): %s" % trimmed)
			return {}

		var key := trimmed.substr(0, colon_index).strip_edges()
		var value_text := trimmed.substr(colon_index + 1).strip_edges()
		while not stack.is_empty() and indent <= int(stack[-1]["indent"]):
			stack.pop_back()
		if stack.is_empty():
			push_error("Malformed indentation while parsing YAML line: %s" % trimmed)
			return {}

		var container := stack[-1]["container"] as Dictionary
		if value_text == "":
			var child: Dictionary = {}
			container[key] = child
			stack.append({"indent": indent, "container": child})
		else:
			container[key] = _parse_value(value_text)

	return root


static func _parse_value(text: String) -> Variant:
	var trimmed := text.strip_edges()
	if trimmed.begins_with("[") and trimmed.ends_with("]"):
		return _parse_inline_array(trimmed)
	if trimmed.begins_with("{") and trimmed.ends_with("}"):
		return _parse_inline_dictionary(trimmed)
	if trimmed.begins_with('"') and trimmed.ends_with('"'):
		return trimmed.substr(1, trimmed.length() - 2)
	if trimmed.begins_with("'") and trimmed.ends_with("'"):
		return trimmed.substr(1, trimmed.length() - 2)

	match trimmed:
		"true":
			return true
		"false":
			return false
		"null", "~":
			return null

	if trimmed.is_valid_int():
		return int(trimmed)
	if trimmed.is_valid_float():
		return float(trimmed)
	return trimmed


static func _parse_inline_array(text: String) -> Array:
	var body := text.substr(1, text.length() - 2).strip_edges()
	if body == "":
		return []

	var values: Array = []
	for token in _split_top_level(body, ","):
		values.append(_parse_value(token))
	return values


static func _parse_inline_dictionary(text: String) -> Dictionary:
	var body := text.substr(1, text.length() - 2).strip_edges()
	if body == "":
		return {}

	var values: Dictionary = {}
	for entry in _split_top_level(body, ","):
		var colon_index := _find_top_level_delimiter(entry, ":")
		if colon_index == -1:
			continue
		var key := entry.substr(0, colon_index).strip_edges()
		var value_text := entry.substr(colon_index + 1).strip_edges()
		values[key] = _parse_value(value_text)
	return values


static func _split_top_level(text: String, delimiter: String) -> Array[String]:
	var parts: Array[String] = []
	var current := ""
	var bracket_depth := 0
	var brace_depth := 0
	var in_single_quote := false
	var in_double_quote := false

	for i in text.length():
		var character := text[i]
		match character:
			"'":
				if not in_double_quote:
					in_single_quote = not in_single_quote
			'"':
				if not in_single_quote:
					in_double_quote = not in_double_quote
			"[":
				if not in_single_quote and not in_double_quote:
					bracket_depth += 1
			"]":
				if not in_single_quote and not in_double_quote:
					bracket_depth = max(bracket_depth - 1, 0)
			"{":
				if not in_single_quote and not in_double_quote:
					brace_depth += 1
			"}":
				if not in_single_quote and not in_double_quote:
					brace_depth = max(brace_depth - 1, 0)
			_:
				pass

		if character == delimiter and bracket_depth == 0 and brace_depth == 0 and not in_single_quote and not in_double_quote:
			parts.append(current.strip_edges())
			current = ""
		else:
			current += character

	if current.strip_edges() != "":
		parts.append(current.strip_edges())
	return parts


static func _find_top_level_delimiter(text: String, delimiter: String) -> int:
	var bracket_depth := 0
	var brace_depth := 0
	var in_single_quote := false
	var in_double_quote := false

	for i in text.length():
		var character := text[i]
		match character:
			"'":
				if not in_double_quote:
					in_single_quote = not in_single_quote
			'"':
				if not in_single_quote:
					in_double_quote = not in_double_quote
			"[":
				if not in_single_quote and not in_double_quote:
					bracket_depth += 1
			"]":
				if not in_single_quote and not in_double_quote:
					bracket_depth = max(bracket_depth - 1, 0)
			"{":
				if not in_single_quote and not in_double_quote:
					brace_depth += 1
			"}":
				if not in_single_quote and not in_double_quote:
					brace_depth = max(brace_depth - 1, 0)
			_:
				pass

		if character == delimiter and bracket_depth == 0 and brace_depth == 0 and not in_single_quote and not in_double_quote:
			return i
	return -1


static func _strip_comment(line: String) -> String:
	var bracket_depth := 0
	var brace_depth := 0
	var in_single_quote := false
	var in_double_quote := false

	for i in line.length():
		var character := line[i]
		match character:
			"'":
				if not in_double_quote:
					in_single_quote = not in_single_quote
			'"':
				if not in_single_quote:
					in_double_quote = not in_double_quote
			"[":
				if not in_single_quote and not in_double_quote:
					bracket_depth += 1
			"]":
				if not in_single_quote and not in_double_quote:
					bracket_depth = max(bracket_depth - 1, 0)
			"{":
				if not in_single_quote and not in_double_quote:
					brace_depth += 1
			"}":
				if not in_single_quote and not in_double_quote:
					brace_depth = max(brace_depth - 1, 0)
			"#":
				if bracket_depth == 0 and brace_depth == 0 and not in_single_quote and not in_double_quote:
					return line.substr(0, i)
	return line


static func _indent_width(line: String) -> int:
	var width := 0
	for i in line.length():
		if line[i] != " ":
			break
		width += 1
	return width


static func _ensure_yaml_extension(path: String) -> String:
	return path if path.ends_with(".yaml") else "%s.yaml" % path


static func _normalize_resource_path(path: String) -> String:
	if path == "":
		return ""
	return ProjectSettings.localize_path(ProjectSettings.globalize_path(path))


static func _deep_copy_dictionary(value: Dictionary) -> Dictionary:
	var copy: Dictionary = {}
	for key in value.keys():
		copy[key] = _deep_copy_variant(value[key])
	return copy


static func _deep_copy_array(value: Array) -> Array:
	var copy: Array = []
	for item in value:
		copy.append(_deep_copy_variant(item))
	return copy


static func _deep_copy_variant(value: Variant) -> Variant:
	if value is Dictionary:
		return _deep_copy_dictionary(value as Dictionary)
	if value is Array:
		return _deep_copy_array(value as Array)
	return value
