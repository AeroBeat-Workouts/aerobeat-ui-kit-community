extends RefCounted

const PanelLoader := preload("res://ui/configs/loaders/aero_ui_glass_panel_config_loader.gd")
const HybridBodyLoader := preload("res://ui/configs/loaders/aero_ui_glass_hybrid_body_config_loader.gd")
const DocumentLoader := preload("res://ui/configs/loaders/aero_ui_yaml_config_document_loader.gd")
const PanelConfig := preload("res://ui/configs/types/aero_ui_glass_panel_config.gd")
const BadgeConfig := preload("res://ui/configs/types/aero_ui_glass_badge_config.gd")
const ButtonConfig := preload("res://ui/configs/types/aero_ui_glass_primary_button_config.gd")
const HybridBodyConfig := preload("res://ui/configs/types/aero_ui_glass_hybrid_body_config.gd")

const YAML_EXTENSION := ".yaml"


static func load_panel_bundle(path: String) -> Dictionary:
	var normalized_path := _normalize_bundle_path(ensure_yaml_extension(path))
	var panel_config: PanelConfig = PanelLoader.load_from_path(normalized_path)
	if panel_config == null or panel_config.source_path == "":
		return {
			"ok": false,
			"error": "Failed to load AeroUiGlass panel YAML: %s" % normalized_path,
		}

	var document := DocumentLoader.load_document(normalized_path)
	if document.is_empty():
		return {
			"ok": false,
			"error": "Failed to read AeroUiGlass panel YAML document: %s" % normalized_path,
		}

	return {
		"ok": true,
		"path": normalized_path,
		"document": document,
		"panel_config": panel_config,
		"badge_config": panel_config.badge_config,
		"button_config": panel_config.primary_button_config,
	}


static func export_panel_bundle(path: String, bundle: Dictionary) -> Dictionary:
	var normalized_path := _normalize_bundle_path(ensure_yaml_extension(path))
	var panel_config: PanelConfig = bundle.get("panel_config") as PanelConfig
	var badge_config: BadgeConfig = bundle.get("badge_config") as BadgeConfig
	var button_config: ButtonConfig = bundle.get("button_config") as ButtonConfig
	if panel_config == null or badge_config == null or button_config == null:
		return {
			"ok": false,
			"error": "Export bundle is missing one or more AeroUiGlass config objects.",
		}

	var directory_path := normalized_path.get_base_dir()
	if not directory_path.is_empty():
		var mkdir_error := DirAccess.make_dir_recursive_absolute(directory_path)
		if mkdir_error != OK:
			return {
				"ok": false,
				"error": "Failed to create YAML preset directory: %s" % directory_path,
				"code": mkdir_error,
			}

	var file_stem := normalized_path.get_file().trim_suffix(".%s" % normalized_path.get_extension())
	var badge_filename := "%s.badge.yaml" % file_stem
	var button_filename := "%s.button.yaml" % file_stem
	var badge_path := directory_path.path_join(badge_filename)
	var button_path := directory_path.path_join(button_filename)

	var panel_document := _build_panel_document(panel_config, bundle.get("panel_shader_parameters", {}), bundle.get("panel_overrides", {}), "./%s" % badge_filename, "./%s" % button_filename)
	var badge_document := _build_badge_document(badge_config, bundle.get("badge_overrides", {}))
	var button_document := _build_button_document(button_config, bundle.get("button_overrides", {}))

	var panel_write := _write_yaml_document(normalized_path, panel_document)
	if not panel_write.get("ok", false):
		return panel_write
	var badge_write := _write_yaml_document(badge_path, badge_document)
	if not badge_write.get("ok", false):
		return badge_write
	var button_write := _write_yaml_document(button_path, button_document)
	if not button_write.get("ok", false):
		return button_write

	return {
		"ok": true,
		"path": normalized_path,
		"panel_path": normalized_path,
		"badge_path": badge_path,
		"button_path": button_path,
	}


static func load_hybrid_body(path: String) -> Dictionary:
	var normalized_path := _normalize_bundle_path(ensure_yaml_extension(path))
	var body_config: HybridBodyConfig = HybridBodyLoader.load_from_path(normalized_path)
	if body_config == null or body_config.source_path == "":
		return {
			"ok": false,
			"error": "Failed to load AeroUiGlass hybrid body YAML: %s" % normalized_path,
		}

	return {
		"ok": true,
		"path": normalized_path,
		"body_config": body_config,
	}


static func export_hybrid_body(path: String, body_config: HybridBodyConfig, body_overrides: Dictionary = {}) -> Dictionary:
	var normalized_path := _normalize_bundle_path(ensure_yaml_extension(path))
	if body_config == null:
		return {
			"ok": false,
			"error": "Export body config is missing the AeroUiGlass hybrid body config object.",
		}

	var directory_path := normalized_path.get_base_dir()
	if not directory_path.is_empty():
		var mkdir_error := DirAccess.make_dir_recursive_absolute(directory_path)
		if mkdir_error != OK:
			return {
				"ok": false,
				"error": "Failed to create YAML preset directory: %s" % directory_path,
				"code": mkdir_error,
			}

	var body_document := _build_hybrid_body_document(body_config, body_overrides)
	var body_write := _write_yaml_document(normalized_path, body_document)
	if not body_write.get("ok", false):
		return body_write

	return {
		"ok": true,
		"path": normalized_path,
	}


static func ensure_yaml_extension(path: String) -> String:
	if path.get_extension().to_lower() in ["yaml", "yml"]:
		return path
	return "%s%s" % [path, YAML_EXTENSION]


static func _normalize_bundle_path(path: String) -> String:
	if path.begins_with("user://"):
		return ProjectSettings.globalize_path(path)
	return path


static func _build_panel_document(panel_config: PanelConfig, shader_parameters: Dictionary, panel_overrides: Dictionary, badge_reference: String, button_reference: String) -> Dictionary:
	var resolved_shader_parameters := panel_config.shader_parameters.duplicate(true)
	for key_variant in shader_parameters.keys():
		resolved_shader_parameters[str(key_variant)] = shader_parameters[key_variant]

	return {
		"schema": PanelConfig.SCHEMA,
		"schema_version": PanelConfig.SCHEMA_VERSION,
		"variant": str(panel_overrides.get("variant", panel_config.variant)),
		"version": str(panel_overrides.get("version", panel_config.version)),
		"shader": _panel_shader_document(resolved_shader_parameters),
		"shell": {
			"frame_alpha_boost": float(panel_overrides.get("frame_alpha_boost", panel_config.frame_alpha_boost)),
		},
		"presentation": {
			"hybrid_world": {
				"inner_border_brightness": float(panel_overrides.get("hybrid_inner_border_brightness", panel_config.hybrid_inner_border_brightness)),
				"inner_border_alpha": float(panel_overrides.get("hybrid_inner_border_alpha", panel_config.hybrid_inner_border_alpha)),
			},
		},
		"parts": {
			"badge_preset": badge_reference,
			"primary_button_preset": button_reference,
		},
	}


static func _panel_shader_document(shader_parameters: Dictionary) -> Dictionary:
	var document: Dictionary = {}
	for key in ["blur", "warp_intensity", "strength_x", "strength_y", "offset_x", "offset_y", "corner_radius", "edge_smoothness", "edge_width", "chromatic_strength"]:
		document[key] = float(shader_parameters.get(key, 0.0))
	for key in ["tint", "edge_highlight"]:
		document[key] = _color_to_document(shader_parameters.get(key, Color.WHITE))
	return document


static func _build_badge_document(badge_config: BadgeConfig, badge_overrides: Dictionary) -> Dictionary:
	return {
		"schema": BadgeConfig.SCHEMA,
		"schema_version": BadgeConfig.SCHEMA_VERSION,
		"variant": str(badge_overrides.get("variant", badge_config.variant)),
		"version": str(badge_overrides.get("version", badge_config.version)),
		"badge": {
			"corner_radius_px": int(badge_overrides.get("base_radius", badge_config.base_radius)),
		},
		"surface": {
			"fill_alpha": float(badge_overrides.get("base_fill_alpha", badge_config.base_fill_alpha)),
			"border_alpha": float(badge_overrides.get("base_border_alpha", badge_config.base_border_alpha)),
		},
		"label": {
			"alpha": float(badge_overrides.get("base_label_alpha", badge_config.base_label_alpha)),
		},
		"tint": _color_to_document(badge_overrides.get("tint", badge_config.tint)),
		"presentation": {
			"hybrid_world": {
				"fill_alpha": float(badge_overrides.get("hybrid_fill_alpha", badge_config.hybrid_fill_alpha)),
				"border_alpha": float(badge_overrides.get("hybrid_border_alpha", badge_config.hybrid_border_alpha)),
				"label_alpha": float(badge_overrides.get("hybrid_label_alpha", badge_config.hybrid_label_alpha)),
			},
		},
	}


static func _build_button_document(button_config: ButtonConfig, button_overrides: Dictionary) -> Dictionary:
	return {
		"schema": ButtonConfig.SCHEMA,
		"schema_version": ButtonConfig.SCHEMA_VERSION,
		"variant": str(button_overrides.get("variant", button_config.variant)),
		"version": str(button_overrides.get("version", button_config.version)),
		"button": {
			"border_width": int(button_overrides.get("border_width", button_config.border_width)),
			"radius_delta": int(button_overrides.get("radius_delta", button_config.radius_delta)),
		},
		"tint": {
			"background": _color_to_document(button_overrides.get("background_tint", button_config.background_tint)),
			"interaction": _color_to_document(button_overrides.get("interaction_tint", button_config.interaction_tint)),
		},
		"label": {
			"alpha": float(button_overrides.get("source_label_alpha", button_config.source_label_alpha)),
		},
		"meta": {
			"alpha": float(button_overrides.get("source_meta_alpha", button_config.source_meta_alpha)),
		},
		"states": {
			"source_2d": _state_map_document(button_overrides.get("source_states", button_config.source_states) as Dictionary),
			"hybrid_world": _state_map_document(button_overrides.get("hybrid_states", button_config.hybrid_states) as Dictionary),
		},
		"interaction": {
			"source_2d": _interaction_map_document(button_overrides.get("source_interactions", button_config.source_interactions) as Dictionary),
			"hybrid_world": _interaction_map_document(button_overrides.get("hybrid_interactions", button_config.hybrid_interactions) as Dictionary),
		},
		"presentation": {
			"hybrid_world": {
				"label_alpha": float(button_overrides.get("hybrid_label_alpha", button_config.hybrid_label_alpha)),
				"meta_alpha": float(button_overrides.get("hybrid_meta_alpha", button_config.hybrid_meta_alpha)),
			},
		},
	}


static func _build_hybrid_body_document(body_config: HybridBodyConfig, body_overrides: Dictionary) -> Dictionary:
	var material_document: Dictionary = {}
	for parameter_name in body_config.material_parameters.keys():
		material_document[parameter_name] = float(body_overrides.get(parameter_name, body_config.material_parameters[parameter_name]))

	return {
		"schema": HybridBodyConfig.SCHEMA,
		"schema_version": HybridBodyConfig.SCHEMA_VERSION,
		"variant": str(body_overrides.get("variant", body_config.variant)),
		"version": str(body_overrides.get("version", body_config.version)),
		"material": material_document,
	}


static func _state_map_document(states: Dictionary) -> Dictionary:
	var document: Dictionary = {}
	for phase in ["rest", "hover", "pressed"]:
		var state := states.get(phase, ButtonConfig.DEFAULT_STATE) as Dictionary
		document[phase] = {
			"fill_delta": float(state.get("fill_delta", 0.0)),
			"border_delta": float(state.get("border_delta", 0.0)),
			"shadow_alpha": float(state.get("shadow_alpha", 0.0)),
			"shadow_size": int(state.get("shadow_size", 0)),
			"tint_strength": float(state.get("tint_strength", 0.0)),
			"scale": float(state.get("scale", 1.0)),
		}
	return document


static func _interaction_map_document(interactions: Dictionary) -> Dictionary:
	var document: Dictionary = {}
	for phase in ["hover", "pressed"]:
		var interaction := interactions.get(phase, ButtonConfig.DEFAULT_INTERACTION_TWEEN) as Dictionary
		document[phase] = {
			"speed": float(interaction.get("speed", ButtonConfig.DEFAULT_INTERACTION_TWEEN["speed"])),
			"ease_type": str(interaction.get("ease_type", ButtonConfig.DEFAULT_INTERACTION_TWEEN["ease_type"])),
		}
	return document


static func _write_yaml_document(path: String, document: Dictionary) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return {
			"ok": false,
			"error": "Failed to open YAML preset for writing: %s" % path,
			"code": FileAccess.get_open_error(),
		}
	file.store_string(_serialize_yaml_mapping(document))
	return {
		"ok": true,
		"path": path,
	}


static func _serialize_yaml_mapping(document: Dictionary, indent: int = 0) -> String:
	var lines: PackedStringArray = []
	for key_variant in document.keys():
		var key := str(key_variant)
		var value: Variant = document[key_variant]
		_append_yaml_line(lines, key, value, indent)
	return "\n".join(lines) + "\n"


static func _append_yaml_line(lines: PackedStringArray, key: String, value: Variant, indent: int) -> void:
	var prefix := " ".repeat(indent)
	if value is Dictionary:
		var dictionary_value := value as Dictionary
		if dictionary_value.is_empty():
			lines.append("%s%s: {}" % [prefix, key])
			return
		if _should_render_inline_dictionary(dictionary_value):
			lines.append("%s%s: %s" % [prefix, key, _inline_dictionary(dictionary_value)])
			return
		lines.append("%s%s:" % [prefix, key])
		for child_key_variant in dictionary_value.keys():
			_append_yaml_line(lines, str(child_key_variant), dictionary_value[child_key_variant], indent + 2)
		return
	if value is Array:
		lines.append("%s%s: %s" % [prefix, key, _inline_array(value as Array)])
		return
	lines.append("%s%s: %s" % [prefix, key, _scalar_to_yaml(value)])


static func _should_render_inline_dictionary(value: Dictionary) -> bool:
	if _looks_like_color_dictionary(value):
		return true
		
	for child_value in value.values():
		if child_value is Dictionary or child_value is Array:
			return false
	return value.size() <= 4


static func _inline_dictionary(value: Dictionary) -> String:
	var parts: PackedStringArray = []
	for key_variant in value.keys():
		parts.append("%s: %s" % [str(key_variant), _scalar_to_yaml(value[key_variant])])
	return "{ %s }" % ", ".join(parts)


static func _inline_array(value: Array) -> String:
	var parts: PackedStringArray = []
	for item in value:
		parts.append(_scalar_to_yaml(item))
	return "[ %s ]" % ", ".join(parts)


static func _scalar_to_yaml(value: Variant) -> String:
	if value == null:
		return "null"
	if value is bool:
		return "true" if value else "false"
	if value is float:
		return str(value)
	if value is int:
		return str(value)
	var text := str(value)
	if text == "" or text.contains(":") or text.contains("#") or text.begins_with(" ") or text.ends_with(" "):
		return '"%s"' % text.replace('"', '\\"')
	return text


static func _color_to_document(value: Variant) -> Dictionary:
	var color: Color = value if value is Color else Color.WHITE
	return {
		"r": color.r,
		"g": color.g,
		"b": color.b,
		"a": color.a,
	}


static func _looks_like_color_dictionary(value: Variant) -> bool:
	if not (value is Dictionary):
		return false
	var raw := value as Dictionary
	for channel in ["r", "g", "b", "a"]:
		if not raw.has(channel):
			return false
	return true


static func _deep_copy_dictionary(value: Dictionary) -> Dictionary:
	var copy: Dictionary = {}
	for key_variant in value.keys():
		var key := str(key_variant)
		var child: Variant = value[key_variant]
		if child is Dictionary:
			copy[key] = _deep_copy_dictionary(child as Dictionary)
		elif child is Array:
			copy[key] = (child as Array).duplicate(true)
		else:
			copy[key] = child
	return copy
