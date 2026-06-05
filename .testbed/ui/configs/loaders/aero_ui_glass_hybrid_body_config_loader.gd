extends RefCounted
class_name AeroUiGlassHybridBodyConfigLoader

const DocumentLoader := preload("res://ui/configs/loaders/aero_ui_yaml_config_document_loader.gd")
const HybridBodyConfig := preload("res://ui/configs/types/aero_ui_glass_hybrid_body_config.gd")


static func load_from_path(path: String) -> HybridBodyConfig:
	return _build_config(_resolve_document(path, {}))


static func _resolve_document(path: String, visited: Dictionary) -> Dictionary:
	var normalized_path := DocumentLoader.resolve_reference_path(path, path)
	if normalized_path == "":
		push_error("Hybrid body config loader received an empty path")
		return {}
	if visited.has(normalized_path):
		push_error("Detected recursive hybrid body preset inheritance at %s" % normalized_path)
		return {}

	visited[normalized_path] = true
	var document := DocumentLoader.load_document(normalized_path)
	if document.is_empty():
		return {}
	if not DocumentLoader.validate_document_schema(document, HybridBodyConfig.SCHEMA, "Hybrid body"):
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


static func _build_config(document: Dictionary) -> HybridBodyConfig:
	var config := HybridBodyConfig.new()
	if document.is_empty():
		return config

	if str(document.get("schema", "")) != HybridBodyConfig.SCHEMA:
		push_error("Hybrid body preset schema mismatch: %s" % document.get("schema", "<missing>"))
		return config
	if int(document.get("schema_version", 0)) != HybridBodyConfig.SCHEMA_VERSION:
		push_error("Hybrid body preset schema_version mismatch in %s" % document.get("__source_path", "<memory>"))
		return config

	config.source_path = str(document.get("__source_path", ""))
	config.variant = str(document.get("variant", config.variant))
	config.version = str(document.get("version", config.version))

	var material_block := document.get("material", {}) as Dictionary
	for parameter_name in config.material_parameters.keys():
		if material_block.has(parameter_name):
			config.material_parameters[parameter_name] = float(material_block[parameter_name])
	return config
