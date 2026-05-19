extends RefCounted
class_name AeroUiGlassPanelConfigLoader

const DocumentLoader := preload("res://ui/configs/loaders/aero_ui_yaml_config_document_loader.gd")
const PanelConfig := preload("res://ui/configs/types/aero_ui_glass_panel_config.gd")
const BadgeConfigLoader := preload("res://ui/configs/loaders/aero_ui_glass_badge_config_loader.gd")
const PrimaryButtonConfigLoader := preload("res://ui/configs/loaders/aero_ui_glass_primary_button_config_loader.gd")


static func load_from_path(path: String) -> AeroUiGlassPanelConfig:
	return _build_config(_resolve_document(path, {}))


static func _resolve_document(path: String, visited: Dictionary) -> Dictionary:
	var normalized_path := DocumentLoader.resolve_reference_path(path, path)
	if normalized_path == "":
		push_error("Panel config loader received an empty path")
		return {}
	if visited.has(normalized_path):
		push_error("Detected recursive panel preset inheritance at %s" % normalized_path)
		return {}

	visited[normalized_path] = true
	var document := DocumentLoader.load_document(normalized_path)
	if document.is_empty():
		return {}

	var base: Dictionary = {}
	var extends_reference: Variant = document.get("extends", null)
	var resolved_extends: String = DocumentLoader.resolve_reference_path(extends_reference, normalized_path)
	if resolved_extends != "":
		base = _resolve_document(resolved_extends, visited)

	var merged := DocumentLoader.merge_documents(base, document)
	merged["__source_path"] = str(document.get("__source_path", normalized_path))
	return merged


static func _build_config(document: Dictionary) -> AeroUiGlassPanelConfig:
	var config := PanelConfig.new()
	if document.is_empty():
		return config

	if str(document.get("schema", "")) != PanelConfig.SCHEMA:
		push_error("Panel preset schema mismatch: %s" % document.get("schema", "<missing>"))
		return config
	if int(document.get("schema_version", 0)) != PanelConfig.SCHEMA_VERSION:
		push_error("Panel preset schema_version mismatch in %s" % document.get("__source_path", "<memory>"))
		return config

	config.source_path = str(document.get("__source_path", ""))
	config.variant = str(document.get("variant", config.variant))
	config.version = str(document.get("version", config.version))

	var shader_block := document.get("shader", {}) as Dictionary
	for parameter_name in config.shader_parameters.keys():
		if shader_block.has(parameter_name):
			config.shader_parameters[parameter_name] = _coerce_panel_shader_value(parameter_name, shader_block[parameter_name])

	var shell_block := document.get("shell", {}) as Dictionary
	config.frame_alpha_boost = float(shell_block.get("frame_alpha_boost", config.frame_alpha_boost))

	var presentation_block := document.get("presentation", {}) as Dictionary
	var hybrid_block := presentation_block.get("hybrid_world", {}) as Dictionary
	config.hybrid_inner_border_brightness = float(hybrid_block.get("inner_border_brightness", config.hybrid_inner_border_brightness))
	config.hybrid_inner_border_alpha = float(hybrid_block.get("inner_border_alpha", config.hybrid_inner_border_alpha))

	var parts_block := document.get("parts", {}) as Dictionary
	config.badge_preset_path = DocumentLoader.resolve_reference_path(parts_block.get("badge_preset", ""), config.source_path)
	config.primary_button_preset_path = DocumentLoader.resolve_reference_path(parts_block.get("primary_button_preset", ""), config.source_path)
	config.badge_config = BadgeConfigLoader.load_from_path(config.badge_preset_path)
	config.primary_button_config = PrimaryButtonConfigLoader.load_from_path(config.primary_button_preset_path)
	return config


static func _coerce_panel_shader_value(parameter_name: String, value: Variant) -> Variant:
	if parameter_name in ["tint", "edge_highlight"]:
		return _dictionary_to_color(value)
	return float(value)


static func _dictionary_to_color(value: Variant) -> Color:
	if value is Color:
		return value
	var raw := value as Dictionary if value is Dictionary else {}
	return Color(
		float(raw.get("r", 1.0)),
		float(raw.get("g", 1.0)),
		float(raw.get("b", 1.0)),
		float(raw.get("a", 1.0))
	)
