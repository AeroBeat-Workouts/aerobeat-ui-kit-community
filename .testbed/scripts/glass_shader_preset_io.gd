extends RefCounted

const SCHEMA_VERSION := 1
const PRESET_KIND_2D := "glass_shader_2d"
const PRESET_KIND_HYBRID_3D := "glass_shader_hybrid_3d"


static func collect_parameters(float_controls: Array, color_controls: Array, getter: Callable) -> Dictionary:
	var parameters: Dictionary = {}
	for config in float_controls:
		var parameter_name := str(config["name"])
		parameters[parameter_name] = float(getter.call(parameter_name))
	for config in color_controls:
		var parameter_name := str(config["name"])
		parameters[parameter_name] = _color_to_json_safe(getter.call(parameter_name))
	return parameters


static func build_preset_envelope(preset_kind: String, source_scene: String, parameters: Dictionary) -> Dictionary:
	return {
		"schema_version": SCHEMA_VERSION,
		"preset_kind": preset_kind,
		"source_scene": source_scene,
		"saved_at": Time.get_datetime_string_from_system(true, true),
		"parameters": parameters,
	}


static func write_preset_file(path: String, envelope: Dictionary) -> Dictionary:
	var normalized_path := ensure_json_extension(path)
	var directory_path := normalized_path.get_base_dir()
	if not directory_path.is_empty():
		var mkdir_error := DirAccess.make_dir_recursive_absolute(directory_path)
		if mkdir_error != OK:
			return {
				"ok": false,
				"error": "Failed to create preset directory: %s" % directory_path,
				"code": mkdir_error,
			}

	var file := FileAccess.open(normalized_path, FileAccess.WRITE)
	if file == null:
		return {
			"ok": false,
			"error": "Failed to open preset for writing: %s" % normalized_path,
			"code": FileAccess.get_open_error(),
		}

	file.store_string(JSON.stringify(envelope, "\t"))
	return {
		"ok": true,
		"path": normalized_path,
	}


static func load_and_normalize_preset(path: String, expected_preset_kind: String, float_controls: Array, color_controls: Array) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {
			"ok": false,
			"error": "Failed to open preset for reading: %s" % path,
			"code": FileAccess.get_open_error(),
		}

	var parse: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parse) != TYPE_DICTIONARY:
		return {
			"ok": false,
			"error": "Preset JSON must decode to an object.",
		}

	var envelope: Dictionary = parse as Dictionary
	if int(envelope.get("schema_version", -1)) != SCHEMA_VERSION:
		return {
			"ok": false,
			"error": "Unsupported schema_version: %s" % str(envelope.get("schema_version", null)),
		}

	var preset_kind := str(envelope.get("preset_kind", ""))
	if preset_kind != expected_preset_kind:
		return {
			"ok": false,
			"error": "Preset kind mismatch. Expected %s, got %s." % [expected_preset_kind, preset_kind],
		}

	var raw_parameters: Variant = envelope.get("parameters", null)
	if typeof(raw_parameters) != TYPE_DICTIONARY:
		return {
			"ok": false,
			"error": "Preset is missing a parameters object.",
		}

	var normalized: Dictionary = _normalize_parameters(raw_parameters as Dictionary, float_controls, color_controls)
	if not normalized.get("ok", false):
		return normalized

	return {
		"ok": true,
		"path": path,
		"envelope": envelope,
		"parameters": normalized["parameters"],
		"ignored_keys": normalized["ignored_keys"],
	}


static func apply_parameters(parameters: Dictionary, setter: Callable) -> void:
	for parameter_name in parameters.keys():
		setter.call(str(parameter_name), parameters[parameter_name])


static func ensure_json_extension(path: String) -> String:
	if path.get_extension().to_lower() == "json":
		return path
	return "%s.json" % path


static func _normalize_parameters(raw_parameters: Dictionary, float_controls: Array, color_controls: Array) -> Dictionary:
	var allowed_float_names: Dictionary = {}
	var allowed_color_names: Dictionary = {}
	for config in float_controls:
		allowed_float_names[str(config["name"])] = true
	for config in color_controls:
		allowed_color_names[str(config["name"])] = true

	var normalized: Dictionary = {}
	var ignored_keys: Array[String] = []

	for parameter_name in raw_parameters.keys():
		var key := str(parameter_name)
		var value: Variant = raw_parameters[parameter_name]
		if allowed_float_names.has(key):
			if not (value is float or value is int):
				return {
					"ok": false,
					"error": "Parameter %s must be numeric." % key,
				}
			normalized[key] = float(value)
		elif allowed_color_names.has(key):
			var decoded: Variant = _json_safe_to_color(value)
			if decoded == null:
				return {
					"ok": false,
					"error": "Parameter %s must be an RGBA object." % key,
				}
			normalized[key] = decoded
		else:
			ignored_keys.append(key)

	return {
		"ok": true,
		"parameters": normalized,
		"ignored_keys": ignored_keys,
	}


static func _color_to_json_safe(value: Variant) -> Dictionary:
	var color: Color = value as Color
	return {
		"r": color.r,
		"g": color.g,
		"b": color.b,
		"a": color.a,
	}


static func _json_safe_to_color(value: Variant) -> Variant:
	if typeof(value) != TYPE_DICTIONARY:
		return null
	var color_data := value as Dictionary
	for channel in ["r", "g", "b", "a"]:
		if not color_data.has(channel):
			return null
		var channel_value: Variant = color_data[channel]
		if not (channel_value is float or channel_value is int):
			return null
	return Color(
		float(color_data["r"]),
		float(color_data["g"]),
		float(color_data["b"]),
		float(color_data["a"])
	)
