class_name AeroUiGlassPrimaryButtonView
extends Button

const AeroUiGlassPrimaryButtonConfig := preload("res://ui/configs/types/aero_ui_glass_primary_button_config.gd")
@onready var primary_action_body: PanelContainer = get_node_or_null("PrimaryActionBodyInset/PrimaryActionBodyAlign/PrimaryActionBody") as PanelContainer
@onready var primary_action_label: Label = get_node_or_null("PrimaryActionBodyInset/PrimaryActionBodyAlign/PrimaryActionBody/PrimaryActionBodyPadding/PrimaryActionTextColumn/PrimaryActionLabel") as Label
@onready var primary_action_meta: Label = get_node_or_null("PrimaryActionBodyInset/PrimaryActionBodyAlign/PrimaryActionBody/PrimaryActionBodyPadding/PrimaryActionTextColumn/PrimaryActionMeta") as Label


func _ready() -> void:
	_configure_button_theme()


func refresh_theme() -> void:
	_configure_button_theme()


func apply_visual_state(state: Dictionary, is_hybrid_world: bool, badge_tokens: Dictionary, button_style_config: AeroUiGlassPrimaryButtonConfig, shell_tint: Color, accent_color: Color) -> void:
	if not is_instance_valid(primary_action_body):
		return

	var hovered := bool(state.get("hovered", false))
	var pressed := bool(state.get("pressed", false))
	var toggled := bool(state.get("toggle_on", false))
	var active := toggled or pressed
	var base_state := _button_state(button_style_config, is_hybrid_world, "rest")
	var resolved_state := base_state.duplicate(true)
	if hovered:
		resolved_state = _merge_button_state(resolved_state, _button_state(button_style_config, is_hybrid_world, "hover"))
	if active:
		resolved_state = _merge_button_state(resolved_state, _button_state(button_style_config, is_hybrid_world, "pressed"))

	var fill_alpha: float = float(badge_tokens["fill_alpha"]) + float(resolved_state.get("fill_delta", 0.0))
	var border_alpha: float = float(badge_tokens["border_alpha"]) + float(resolved_state.get("border_delta", 0.0))
	var shadow_alpha: float = float(resolved_state.get("shadow_alpha", 0.0))
	var shadow_size: int = int(resolved_state.get("shadow_size", 0))
	var tint_strength: float = clampf(float(resolved_state.get("tint_strength", 0.0)), 0.0, 1.0)
	var body_scale: float = maxf(0.9, float(resolved_state.get("scale", 1.0)))
	var background_tint := button_style_config.background_tint if button_style_config != null else shell_tint
	var interaction_tint := button_style_config.interaction_tint if button_style_config != null else accent_color
	var resolved_fill_tint := background_tint.lerp(interaction_tint, tint_strength)
	var resolved_border_tint := Color(1.0, 1.0, 1.0, 1.0).lerp(interaction_tint, tint_strength)
	var body_style := _build_action_stylebox(fill_alpha, resolved_fill_tint, resolved_border_tint, border_alpha, shadow_alpha, shadow_size, is_hybrid_world, badge_tokens, button_style_config, shell_tint)
	primary_action_body.add_theme_stylebox_override("panel", body_style)
	if is_instance_valid(primary_action_label):
		var label_alpha := button_style_config.get_label_alpha(is_hybrid_world) if button_style_config != null else (0.98 if is_hybrid_world else 0.95)
		var label_tint := Color(1.0, 1.0, 1.0, 1.0).lerp(interaction_tint, tint_strength * (0.85 if hovered or active else 0.0))
		primary_action_label.modulate = Color(label_tint.r, label_tint.g, label_tint.b, 0.99 if hovered or active else label_alpha)
	if is_instance_valid(primary_action_meta):
		var meta_alpha := button_style_config.get_meta_alpha(is_hybrid_world) if button_style_config != null else (0.7 if is_hybrid_world else 0.66)
		var meta_tint := Color(1.0, 1.0, 1.0, 1.0).lerp(interaction_tint, tint_strength * 0.72)
		primary_action_meta.modulate = Color(meta_tint.r, meta_tint.g, meta_tint.b, meta_alpha)
	scale = Vector2.ONE
	primary_action_body.scale = Vector2.ONE * body_scale


func _configure_button_theme() -> void:
	flat = true
	focus_mode = Control.FOCUS_NONE
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	add_theme_constant_override("outline_size", 0)
	add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.0))
	add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.0))
	add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0, 0.0))
	add_theme_color_override("font_pressed_color", Color(1.0, 1.0, 1.0, 0.0))
	add_theme_color_override("font_focus_color", Color(1.0, 1.0, 1.0, 0.0))

	var empty := StyleBoxEmpty.new()
	add_theme_stylebox_override("normal", empty)
	add_theme_stylebox_override("hover", empty)
	add_theme_stylebox_override("pressed", empty)
	add_theme_stylebox_override("focus", empty)
	add_theme_stylebox_override("disabled", empty)


func _build_action_stylebox(fill_alpha: float, fill_tint: Color, border_tint: Color, border_alpha: float, shadow_alpha: float, shadow_size: int, is_hybrid_world: bool, badge_tokens: Dictionary, button_style_config: AeroUiGlassPrimaryButtonConfig, shell_tint: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	var fill_color := Color(fill_tint.r, fill_tint.g, fill_tint.b, clampf(fill_alpha, 0.0, 0.44 if is_hybrid_world else 0.24))
	if not is_hybrid_world:
		fill_color = fill_color.lerp(Color(shell_tint.r, shell_tint.g, shell_tint.b, fill_color.a), 0.12)
	style.bg_color = fill_color
	var border_width := button_style_config.border_width if button_style_config != null else 2
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.border_color = Color(border_tint.r, border_tint.g, border_tint.b, clampf(border_alpha, 0.0, 0.76))
	var radius_delta := button_style_config.radius_delta if button_style_config != null else 5
	var action_radius := int(badge_tokens["radius"]) + radius_delta
	style.corner_radius_top_left = action_radius
	style.corner_radius_top_right = action_radius
	style.corner_radius_bottom_right = action_radius
	style.corner_radius_bottom_left = action_radius
	style.shadow_size = shadow_size
	style.shadow_color = Color(border_tint.r, border_tint.g, border_tint.b, shadow_alpha)
	return style


func _button_state(button_style_config: AeroUiGlassPrimaryButtonConfig, is_hybrid_world: bool, phase: String) -> Dictionary:
	if button_style_config == null:
		return {"fill_delta": 0.0, "border_delta": 0.0, "shadow_alpha": 0.0, "shadow_size": 0, "tint_strength": 0.0, "scale": 1.0}
	return button_style_config.get_state(is_hybrid_world, phase)


func _merge_button_state(base_state: Dictionary, override_state: Dictionary) -> Dictionary:
	var merged := base_state.duplicate(true)
	merged["fill_delta"] = maxf(float(base_state.get("fill_delta", 0.0)), float(override_state.get("fill_delta", base_state.get("fill_delta", 0.0))))
	merged["border_delta"] = maxf(float(base_state.get("border_delta", 0.0)), float(override_state.get("border_delta", base_state.get("border_delta", 0.0))))
	merged["shadow_alpha"] = maxf(float(base_state.get("shadow_alpha", 0.0)), float(override_state.get("shadow_alpha", base_state.get("shadow_alpha", 0.0))))
	merged["shadow_size"] = max(int(base_state.get("shadow_size", 0)), int(override_state.get("shadow_size", base_state.get("shadow_size", 0))))
	merged["tint_strength"] = maxf(float(base_state.get("tint_strength", 0.0)), float(override_state.get("tint_strength", base_state.get("tint_strength", 0.0))))
	merged["scale"] = float(override_state.get("scale", base_state.get("scale", 1.0)))
	return merged
