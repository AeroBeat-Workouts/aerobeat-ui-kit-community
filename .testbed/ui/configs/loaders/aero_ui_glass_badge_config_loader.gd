extends RefCounted
class_name AeroUiGlassBadgeConfigLoader

const DocumentLoader := preload("res://ui/configs/loaders/aero_ui_yaml_config_document_loader.gd")
const BadgeConfig := preload("res://ui/configs/types/aero_ui_glass_badge_config.gd")


static func load_from_path(path: String) -> AeroUiGlassBadgeConfig:
	return _build_config(_resolve_document(path, {}))


static func _resolve_document(path: String, visited: Dictionary) -> Dictionary:
	var normalized_path := DocumentLoader.resolve_reference_path(path, path)
	if normalized_path == "":
		push_error("Badge config loader received an empty path")
		return {}
	if visited.has(normalized_path):
		push_error("Detected recursive badge preset inheritance at %s" % normalized_path)
		return {}

	visited[normalized_path] = true
	var document := DocumentLoader.load_document(normalized_path)
	if document.is_empty():
		return {}
	if not DocumentLoader.validate_document_schema(document, BadgeConfig.SCHEMA, "Badge"):
		return {}

	var base: Dictionary = {}
	var extends_reference: Variant = document.get("extends", null)
	var resolved_extends: String = DocumentLoader.resolve_reference_path(extends_reference, normalized_path)
	if resolved_extends != "":
		base = _resolve_document(resolved_extends, visited)
		if base.is_empty():
			return {}

	var merged := DocumentLoader.merge_documents(base, document)
	merged["__source_path"] = str(document.get("__source_path", normalized_path))
	return merged


static func _build_config(document: Dictionary) -> AeroUiGlassBadgeConfig:
	var config := BadgeConfig.new()
	if document.is_empty():
		return config

	if str(document.get("schema", "")) != BadgeConfig.SCHEMA:
		push_error("Badge preset schema mismatch: %s" % document.get("schema", "<missing>"))
		return config
	if int(document.get("schema_version", 0)) != BadgeConfig.SCHEMA_VERSION:
		push_error("Badge preset schema_version mismatch in %s" % document.get("__source_path", "<memory>"))
		return config

	config.source_path = str(document.get("__source_path", ""))
	config.variant = str(document.get("variant", config.variant))
	config.version = str(document.get("version", config.version))

	var badge_block := document.get("badge", {}) as Dictionary
	var surface_block := document.get("surface", {}) as Dictionary
	var label_block := document.get("label", {}) as Dictionary
	var presentation_block := document.get("presentation", {}) as Dictionary
	var hybrid_block := presentation_block.get("hybrid_world", {}) as Dictionary

	config.base_radius = int(badge_block.get("corner_radius_px", config.base_radius))
	config.base_fill_alpha = float(surface_block.get("fill_alpha", config.base_fill_alpha))
	config.base_border_alpha = float(surface_block.get("border_alpha", config.base_border_alpha))
	config.base_label_alpha = float(label_block.get("alpha", config.base_label_alpha))
	config.hybrid_fill_alpha = float(hybrid_block.get("fill_alpha", config.hybrid_fill_alpha))
	config.hybrid_border_alpha = float(hybrid_block.get("border_alpha", config.hybrid_border_alpha))
	config.hybrid_label_alpha = float(hybrid_block.get("label_alpha", config.hybrid_label_alpha))
	return config
