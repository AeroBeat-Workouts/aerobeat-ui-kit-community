class_name AeroUiGlassPrimaryButtonView
extends Button

const PrimaryButtonConfigScript := preload("res://ui/configs/types/aero_ui_glass_primary_button_config.gd")
const TweenUtilsScript := preload("res://ui/views/shared/aero_ui_tween_utils.gd")

@onready var primary_action_body: PanelContainer = get_node_or_null("PrimaryActionBodyInset/PrimaryActionBodyAlign/PrimaryActionBody") as PanelContainer
@onready var primary_action_label: Label = get_node_or_null("PrimaryActionBodyInset/PrimaryActionBodyAlign/PrimaryActionBody/PrimaryActionBodyPadding/PrimaryActionTextColumn/PrimaryActionLabel") as Label
@onready var primary_action_meta: Label = get_node_or_null("PrimaryActionBodyInset/PrimaryActionBodyAlign/PrimaryActionBody/PrimaryActionBodyPadding/PrimaryActionTextColumn/PrimaryActionMeta") as Label

var _action_style: StyleBoxFlat
var _alpha_tween: Tween
var _visual_tween: Tween
var _last_visual_phase := "rest"
var _last_is_hybrid_world := false
var _has_applied_visual_state := false


func _ready() -> void:
	_configure_button_theme()
	_ensure_action_style()


func refresh_theme() -> void:
	_configure_button_theme()
	_ensure_action_style()


func TweenAlpha(target_alpha: float, tweenSpeed: float, easeType: Variant, callback: Callable = Callable()) -> void:
	_alpha_tween = TweenUtilsScript.tween_canvas_item_alpha(self, _alpha_tween, self, target_alpha, tweenSpeed, easeType, callback)


func apply_visual_state(state: Dictionary, is_hybrid_world: bool, badge_tokens: Dictionary, button_style_config: PrimaryButtonConfigScript, shell_tint: Color, accent_color: Color) -> void:
	if not is_instance_valid(primary_action_body):
		return
	_ensure_action_style()

	var hovered := bool(state.get("hovered", false))
	var is_pressed_state := bool(state.get("pressed", false))
	var is_toggle_on := bool(state.get("toggle_on", false))
	var visual_phase := _resolve_visual_phase(hovered, is_pressed_state)
	var presentation_changed := _has_applied_visual_state and _last_is_hybrid_world != is_hybrid_world
	var resolved_state := _button_state(button_style_config, is_hybrid_world, visual_phase)

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
	var label_alpha := button_style_config.get_label_alpha(is_hybrid_world) if button_style_config != null else (0.98 if is_hybrid_world else 0.95)
	var meta_alpha := button_style_config.get_meta_alpha(is_hybrid_world) if button_style_config != null else (0.7 if is_hybrid_world else 0.66)
	var is_active := visual_phase != "rest" or is_toggle_on
	var label_tint := Color(1.0, 1.0, 1.0, 1.0).lerp(interaction_tint, tint_strength * (0.85 if is_active else 0.0))
	var meta_tint := Color(1.0, 1.0, 1.0, 1.0).lerp(interaction_tint, tint_strength * 0.72)
	var transition_profile := _resolve_transition_profile(button_style_config, is_hybrid_world, visual_phase)
	var target_style := _build_action_stylebox(fill_alpha, resolved_fill_tint, resolved_border_tint, border_alpha, shadow_alpha, shadow_size, is_hybrid_world, badge_tokens, button_style_config, shell_tint)
	var target_label_modulate := Color(label_tint.r, label_tint.g, label_tint.b, 0.99 if is_active else label_alpha)
	var target_meta_modulate := Color(meta_tint.r, meta_tint.g, meta_tint.b, meta_alpha)
	var target_scale := Vector2.ONE * body_scale

	scale = Vector2.ONE
	if not _has_applied_visual_state or presentation_changed:
		_apply_visual_snapshot(target_style, target_scale, target_label_modulate, target_meta_modulate)
	else:
		_tween_visual_snapshot(target_style, target_scale, target_label_modulate, target_meta_modulate, transition_profile)

	_last_visual_phase = visual_phase
	_last_is_hybrid_world = is_hybrid_world
	_has_applied_visual_state = true


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


func _ensure_action_style() -> void:
	if not is_instance_valid(primary_action_body):
		return
	if _action_style != null:
		return
	var existing := primary_action_body.get_theme_stylebox("panel") as StyleBoxFlat
	_action_style = existing.duplicate() if existing != null else StyleBoxFlat.new()
	primary_action_body.add_theme_stylebox_override("panel", _action_style)


func _build_action_stylebox(fill_alpha: float, fill_tint: Color, border_tint: Color, border_alpha: float, shadow_alpha: float, shadow_size: int, is_hybrid_world: bool, badge_tokens: Dictionary, button_style_config: PrimaryButtonConfigScript, shell_tint: Color) -> StyleBoxFlat:
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
	_set_all_corner_radii(style, action_radius)
	style.shadow_size = shadow_size
	style.shadow_color = Color(border_tint.r, border_tint.g, border_tint.b, shadow_alpha)
	return style


func _button_state(button_style_config: PrimaryButtonConfigScript, is_hybrid_world: bool, phase: String) -> Dictionary:
	if button_style_config == null:
		return {"fill_delta": 0.0, "border_delta": 0.0, "shadow_alpha": 0.0, "shadow_size": 0, "tint_strength": 0.0, "scale": 1.0}
	return button_style_config.get_state(is_hybrid_world, phase)


func _resolve_visual_phase(hovered: bool, is_pressed_state: bool) -> String:
	if is_pressed_state:
		return "pressed"
	if hovered:
		return "hover"
	return "rest"


func _resolve_transition_profile(button_style_config: PrimaryButtonConfigScript, is_hybrid_world: bool, target_phase: String) -> Dictionary:
	if button_style_config == null:
		return {"speed": 0.0, "ease_type": TweenUtilsScript.DEFAULT_EASE_TYPE}
	var interaction_phase := "hover"
	if target_phase == "pressed" or _last_visual_phase == "pressed":
		interaction_phase = "pressed"
	return button_style_config.get_interaction_tween(is_hybrid_world, interaction_phase)


func _apply_visual_snapshot(target_style: StyleBoxFlat, target_scale: Vector2, target_label_modulate: Color, target_meta_modulate: Color) -> void:
	_apply_stylebox_snapshot(target_style)
	primary_action_body.scale = target_scale
	if is_instance_valid(primary_action_label):
		primary_action_label.modulate = target_label_modulate
	if is_instance_valid(primary_action_meta):
		primary_action_meta.modulate = target_meta_modulate


func _tween_visual_snapshot(target_style: StyleBoxFlat, target_scale: Vector2, target_label_modulate: Color, target_meta_modulate: Color, transition_profile: Dictionary) -> void:
	var duration := maxf(0.0, float(transition_profile.get("speed", 0.0)))
	var ease_type: Variant = transition_profile.get("ease_type", TweenUtilsScript.DEFAULT_EASE_TYPE)
	if duration <= 0.0:
		_apply_visual_snapshot(target_style, target_scale, target_label_modulate, target_meta_modulate)
		return

	if is_instance_valid(_visual_tween):
		_visual_tween.kill()
	var curve := TweenUtilsScript.resolve_curve(ease_type)
	_visual_tween = create_tween()
	_visual_tween.set_trans(int(curve["trans"]))
	_visual_tween.set_ease(int(curve["ease"]))
	_visual_tween.set_parallel()
	_visual_tween.tween_property(_action_style, ^"bg_color", target_style.bg_color, duration)
	_visual_tween.tween_property(_action_style, ^"border_color", target_style.border_color, duration)
	_visual_tween.tween_property(_action_style, ^"shadow_color", target_style.shadow_color, duration)
	_visual_tween.tween_property(_action_style, ^"shadow_size", target_style.shadow_size, duration)
	_visual_tween.tween_property(primary_action_body, ^"scale", target_scale, duration)
	if is_instance_valid(primary_action_label):
		_visual_tween.tween_property(primary_action_label, ^"modulate", target_label_modulate, duration)
	if is_instance_valid(primary_action_meta):
		_visual_tween.tween_property(primary_action_meta, ^"modulate", target_meta_modulate, duration)
	_apply_stylebox_shape(target_style)


func _apply_stylebox_snapshot(target_style: StyleBoxFlat) -> void:
	_apply_stylebox_colors(target_style)
	_apply_stylebox_shape(target_style)


func _apply_stylebox_colors(target_style: StyleBoxFlat) -> void:
	if _action_style == null:
		return
	_action_style.bg_color = target_style.bg_color
	_action_style.border_color = target_style.border_color
	_action_style.shadow_color = target_style.shadow_color
	_action_style.shadow_size = target_style.shadow_size


func _apply_stylebox_shape(target_style: StyleBoxFlat) -> void:
	if _action_style == null:
		return
	_action_style.border_width_left = target_style.border_width_left
	_action_style.border_width_top = target_style.border_width_top
	_action_style.border_width_right = target_style.border_width_right
	_action_style.border_width_bottom = target_style.border_width_bottom
	_action_style.corner_radius_top_left = target_style.corner_radius_top_left
	_action_style.corner_radius_top_right = target_style.corner_radius_top_right
	_action_style.corner_radius_bottom_right = target_style.corner_radius_bottom_right
	_action_style.corner_radius_bottom_left = target_style.corner_radius_bottom_left


func _set_all_corner_radii(style: StyleBoxFlat, radius: int) -> void:
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_right = radius
	style.corner_radius_bottom_left = radius
