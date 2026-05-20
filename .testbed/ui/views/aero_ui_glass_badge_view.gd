class_name AeroUiGlassBadgeView
extends PanelContainer

const BadgeConfigScript := preload("res://ui/configs/types/aero_ui_glass_badge_config.gd")
const TweenUtilsScript := preload("res://ui/views/shared/aero_ui_tween_utils.gd")

@onready var badge_label: Label = get_node_or_null("BadgePadding/BadgeLabel") as Label

var _badge_style: StyleBoxFlat
var _badge_style_config: BadgeConfigScript
var _alpha_tween: Tween


func _ready() -> void:
	refresh_theme()


func refresh_theme() -> void:
	_badge_style = get_theme_stylebox("panel") as StyleBoxFlat


func TweenAlpha(target_alpha: float, tweenSpeed: float, easeType: Variant, callback: Callable = Callable()) -> void:
	_alpha_tween = TweenUtilsScript.tween_canvas_item_alpha(self, _alpha_tween, self, target_alpha, tweenSpeed, easeType, callback)


func set_badge_config(config: BadgeConfigScript) -> void:
	_badge_style_config = config


func get_badge_tokens(is_hybrid_world: bool) -> Dictionary:
	if _badge_style_config != null:
		return _badge_style_config.get_tokens(is_hybrid_world)
	if is_hybrid_world:
		return {
			"fill_alpha": 0.18,
			"border_alpha": 0.267,
			"label_alpha": 0.9,
			"radius": 14,
			"tint": Color(0.92, 0.96, 1.0, 1.0),
		}
	return {
		"fill_alpha": 0.08,
		"border_alpha": 0.14,
		"label_alpha": 0.78,
		"radius": 14,
		"tint": Color(0.92, 0.96, 1.0, 1.0),
	}


func apply_visual_state(tokens: Dictionary) -> void:
	if _badge_style == null:
		refresh_theme()
	if _badge_style == null:
		return

	var radius := int(tokens.get("radius", 14))
	var tint: Color = tokens.get("tint", Color(0.92, 0.96, 1.0, 1.0)) if tokens.get("tint", null) is Color else Color(0.92, 0.96, 1.0, 1.0)
	_badge_style.bg_color = Color(tint.r, tint.g, tint.b, float(tokens.get("fill_alpha", 0.08)))
	_badge_style.border_color = Color(tint.r, tint.g, tint.b, float(tokens.get("border_alpha", 0.14)))
	_badge_style.corner_radius_top_left = radius
	_badge_style.corner_radius_top_right = radius
	_badge_style.corner_radius_bottom_right = radius
	_badge_style.corner_radius_bottom_left = radius
	if is_instance_valid(badge_label):
		badge_label.modulate = Color(tint.r, tint.g, tint.b, float(tokens.get("label_alpha", 0.78)))
