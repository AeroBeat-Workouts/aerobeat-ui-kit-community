extends RefCounted

const TYPE_TO_KIND := {
	"image_background": "image",
	"video_background": "video",
	"glb_environment": "glb",
	"splat": "splat",
}

static func resolve_request(yaml_path: String, context: Dictionary = {}) -> Dictionary:
	var trimmed_path := yaml_path.strip_edges()
	if trimmed_path.is_empty():
		return _error("invalid_environment_yaml", "Environment YAML path is empty.", false)

	var absolute_path := _to_absolute_path(trimmed_path)
	if absolute_path.is_empty() or not FileAccess.file_exists(absolute_path):
		return _error("environment_yaml_missing", "Environment YAML file does not exist: %s" % trimmed_path, false)

	var yaml_record := _parse_simple_yaml_file(absolute_path)
	if yaml_record.is_empty():
		return _error("invalid_environment_yaml", "Environment YAML could not be parsed: %s" % absolute_path, false)

	var schema_id := String(yaml_record.get("schemaId", yaml_record.get("schema_id", ""))).strip_edges()
	if schema_id == "aerobeat.workout-package.v1" or yaml_record.has("setOrder"):
		return _resolve_workout_request(absolute_path, yaml_record, context)

	return _resolve_environment_request(absolute_path, yaml_record, context)

static func _resolve_workout_request(workout_yaml_path: String, workout_record: Dictionary, context: Dictionary) -> Dictionary:
	var set_order := workout_record.get("setOrder", []) as Array
	if set_order.is_empty():
		return _error("workout_set_order_missing", "Workout YAML does not define any setOrder entries: %s" % workout_yaml_path, false)
	var set_id := String(set_order[0]).strip_edges()
	var package_dir := workout_yaml_path.get_base_dir()
	var set_path := package_dir.path_join("sets").path_join("%s.yaml" % set_id)
	if not FileAccess.file_exists(set_path):
		return _error("workout_set_missing", "Workout set YAML does not exist: %s" % set_path, false)
	var set_record := _parse_simple_yaml_file(set_path)
	var environment_id := String(set_record.get("preferredEnvironmentId", set_record.get("fallbackEnvironmentId", ""))).strip_edges()
	if environment_id.is_empty():
		return _error("workout_environment_missing", "Workout set YAML did not resolve a preferredEnvironmentId: %s" % set_path, false)
	var environment_path := package_dir.path_join("environments").path_join("%s.yaml" % environment_id)
	if not FileAccess.file_exists(environment_path):
		return _error("workout_environment_record_missing", "Environment YAML does not exist: %s" % environment_path, false)
	var result := _resolve_environment_request(environment_path, _parse_simple_yaml_file(environment_path), context)
	if result.get("ok", false):
		var request := Dictionary(result.get("request", {})).duplicate(true)
		var metadata := Dictionary(request.get("metadata", {})).duplicate(true)
		metadata["workout_yaml_path"] = workout_yaml_path
		metadata["set_yaml_path"] = set_path
		metadata["set_id"] = set_id
		request["metadata"] = metadata
		result["request"] = request
	return result

static func _resolve_environment_request(environment_yaml_path: String, yaml_record: Dictionary, context: Dictionary) -> Dictionary:
	var environment_id := String(yaml_record.get("environmentId", "")).strip_edges()
	var environment_type := String(yaml_record.get("type", "")).strip_edges()
	var resource_path := String(yaml_record.get("resourcePath", "")).strip_edges()
	if environment_id.is_empty() or environment_type.is_empty() or resource_path.is_empty():
		return _error("invalid_environment_yaml", "Environment YAML is missing environmentId, type, or resourcePath: %s" % environment_yaml_path, false)

	var kind := String(TYPE_TO_KIND.get(environment_type, "")).strip_edges()
	if kind.is_empty():
		return _error("unsupported_environment_type", "Unsupported environment type '%s' in %s" % [environment_type, environment_yaml_path], false)

	var record_dir := environment_yaml_path.get_base_dir()
	var request := {
		"request_id": String(context.get("request_id", "")).strip_edges(),
		"kind": kind,
		"asset_path": _resolve_relative_path(record_dir, resource_path),
		"config_path": _resolve_relative_path(record_dir, String(yaml_record.get("configPath", context.get("config_path", ""))).strip_edges()),
		"fit_mode": String(context.get("fit_mode", "cover")).strip_edges(),
		"context": context.duplicate(true),
		"metadata": {
			"source": "environment_yaml",
			"environment_id": environment_id,
			"environment_name": String(yaml_record.get("environmentName", environment_id)).strip_edges(),
			"environment_record_path": environment_yaml_path,
			"environment_type": environment_type,
			"resource_path": resource_path,
			"resolved_from_yaml_path": environment_yaml_path,
		},
	}
	return {
		"ok": true,
		"request": request,
		"summary": _request_summary(request),
	}

static func _request_summary(request: Dictionary) -> String:
	var metadata := Dictionary(request.get("metadata", {}))
	return "%s • %s" % [
		String(metadata.get("environment_name", metadata.get("environment_id", request.get("kind", "environment")))),
		String(request.get("kind", "")),
	]

static func _parse_simple_yaml_file(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var root: Dictionary = {}
	var current_array_key := ""
	while not file.eof_reached():
		var raw_line := file.get_line()
		var line := raw_line.strip_edges()
		if line.is_empty() or line.begins_with("#"):
			continue
		if line.begins_with("-") and not current_array_key.is_empty():
			var entries := root.get(current_array_key, []) as Array
			entries.append(line.trim_prefix("-").strip_edges())
			root[current_array_key] = entries
			continue
		current_array_key = ""
		var colon_index := line.find(":")
		if colon_index < 0:
			continue
		var key := line.substr(0, colon_index).strip_edges()
		var value := line.substr(colon_index + 1).strip_edges()
		if value.is_empty():
			current_array_key = key
			root[key] = []
		else:
			root[key] = value.trim_prefix('"').trim_suffix('"')
	return root

static func _resolve_relative_path(base_dir: String, path_value: String) -> String:
	var trimmed := path_value.strip_edges()
	if trimmed.is_empty():
		return ""
	if trimmed.begins_with("res://") or trimmed.begins_with("user://"):
		return _to_absolute_path(trimmed)
	if trimmed.is_absolute_path():
		return trimmed
	return base_dir.path_join(trimmed).simplify_path()

static func _to_absolute_path(path_value: String) -> String:
	var trimmed := path_value.strip_edges()
	if trimmed.begins_with("res://") or trimmed.begins_with("user://"):
		return ProjectSettings.globalize_path(trimmed)
	return trimmed

static func _error(code: String, message: String, recoverable: bool) -> Dictionary:
	return {
		"ok": false,
		"error_code": code,
		"message": message,
		"recoverable": recoverable,
	}
