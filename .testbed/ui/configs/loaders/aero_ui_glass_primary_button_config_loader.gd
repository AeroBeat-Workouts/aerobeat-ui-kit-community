extends RefCounted
class_name AeroUiGlassPrimaryButtonConfigLoader

const DocumentLoader := preload("res://ui/configs/loaders/aero_ui_yaml_config_document_loader.gd")
const ButtonConfig := preload("res://ui/configs/types/aero_ui_glass_primary_button_config.gd")


static func load_from_path(path: String) -> AeroUiGlassPrimaryButtonConfig:
	return _build_config(_resolve_document(path, {}))


static func _resolve_document(path: String, visited: Dictionary) -> Dictionary:
	var normalized_path := DocumentLoader.resolve_reference_path(path, path)
	if normalized_path == "":
		push_error("Primary button config loader received an empty path")
		return {}
	if visited.has(normalized_path):
		push_error("Detected recursive primary button preset inheritance at %s" % normalized_path)
		return {}

	visited[normalized_path] = true
	var document := DocumentLoader.load_document(normalized_path)
	if document.is_empty():
		return {}
	if not DocumentLoader.validate_document_schema(document, ButtonConfig.SCHEMA, "Primary button"):
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


static func _build_config(document: Dictionary) -> AeroUiGlassPrimaryButtonConfig:
	var config := ButtonConfig.new()
	if document.is_empty():
		return config

	if str(document.get("schema", "")) != ButtonConfig.SCHEMA:
		push_error("Primary button preset schema mismatch: %s" % document.get("schema", "<missing>"))
		return config
	if int(document.get("schema_version", 0)) != ButtonConfig.SCHEMA_VERSION:
		push_error("Primary button preset schema_version mismatch in %s" % document.get("__source_path", "<memory>"))
		return config

	config.source_path = str(document.get("__source_path", ""))
	config.variant = str(document.get("variant", config.variant))
	config.version = str(document.get("version", config.version))

	var button_block := document.get("button", {}) as Dictionary
	var label_block := document.get("label", {}) as Dictionary
	var meta_block := document.get("meta", {}) as Dictionary
	var states_block := document.get("states", {}) as Dictionary
	var presentation_block := document.get("presentation", {}) as Dictionary
	var interaction_block := document.get("interaction", {}) as Dictionary
	var source_interaction := interaction_block.get("source_2d", {}) as Dictionary
	var hybrid_interaction := interaction_block.get("hybrid_world", {}) as Dictionary
	var hybrid_presentation := presentation_block.get("hybrid_world", {}) as Dictionary
	var tint_block := document.get("tint", {}) as Dictionary

	config.border_width = int(button_block.get("border_width", config.border_width))
	config.radius_delta = int(button_block.get("radius_delta", config.radius_delta))
	if not tint_block.is_empty():
		var background_tint_block := tint_block.get("background", {}) as Dictionary
		if not background_tint_block.is_empty():
			config.background_tint = Color(
				float(background_tint_block.get("r", config.background_tint.r)),
				float(background_tint_block.get("g", config.background_tint.g)),
				float(background_tint_block.get("b", config.background_tint.b)),
				float(background_tint_block.get("a", config.background_tint.a))
			)
		var interaction_tint_block := tint_block.get("interaction", {}) as Dictionary
		if not interaction_tint_block.is_empty():
			config.interaction_tint = Color(
				float(interaction_tint_block.get("r", config.interaction_tint.r)),
				float(interaction_tint_block.get("g", config.interaction_tint.g)),
				float(interaction_tint_block.get("b", config.interaction_tint.b)),
				float(interaction_tint_block.get("a", config.interaction_tint.a))
			)
	config.source_label_alpha = float(label_block.get("alpha", config.source_label_alpha))
	config.source_meta_alpha = float(meta_block.get("alpha", config.source_meta_alpha))
	config.hybrid_label_alpha = float(hybrid_presentation.get("label_alpha", config.hybrid_label_alpha))
	config.hybrid_meta_alpha = float(hybrid_presentation.get("meta_alpha", config.hybrid_meta_alpha))
	config.source_states = _build_state_map(states_block.get("source_2d", {}), config.source_states)
	config.hybrid_states = _build_state_map(states_block.get("hybrid_world", {}), config.hybrid_states)
	config.source_interactions = _build_interaction_map(source_interaction, config.source_interactions)
	config.hybrid_interactions = _build_interaction_map(hybrid_interaction, config.hybrid_interactions)
	return config


static func _build_state_map(raw_states: Variant, fallback: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	var source := raw_states as Dictionary if raw_states is Dictionary else {}
	for phase in ["rest", "hover", "pressed"]:
		var fallback_state := fallback.get(phase, ButtonConfig.DEFAULT_STATE) as Dictionary
		var raw_state := source.get(phase, {}) as Dictionary
		result[phase] = {
			"fill_delta": float(raw_state.get("fill_delta", fallback_state.get("fill_delta", 0.0))),
			"border_delta": float(raw_state.get("border_delta", fallback_state.get("border_delta", 0.0))),
			"shadow_alpha": float(raw_state.get("shadow_alpha", fallback_state.get("shadow_alpha", 0.0))),
			"shadow_size": int(raw_state.get("shadow_size", fallback_state.get("shadow_size", 0))),
			"tint_strength": float(raw_state.get("tint_strength", fallback_state.get("tint_strength", 0.0))),
			"scale": float(raw_state.get("scale", fallback_state.get("scale", 1.0))),
		}
	return result


static func _build_interaction_map(raw_interaction: Variant, fallback: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	var source := raw_interaction as Dictionary if raw_interaction is Dictionary else {}
	for phase in ["hover", "pressed"]:
		var fallback_interaction := fallback.get(phase, ButtonConfig.DEFAULT_INTERACTION_TWEEN) as Dictionary
		var raw_phase := source.get(phase, {}) as Dictionary
		result[phase] = {
			"speed": float(raw_phase.get("speed", fallback_interaction.get("speed", ButtonConfig.DEFAULT_INTERACTION_TWEEN["speed"]))),
			"ease_type": str(raw_phase.get("ease_type", fallback_interaction.get("ease_type", ButtonConfig.DEFAULT_INTERACTION_TWEEN["ease_type"]))),
		}
	return result
