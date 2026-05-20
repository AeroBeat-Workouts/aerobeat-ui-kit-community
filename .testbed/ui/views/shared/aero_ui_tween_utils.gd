extends RefCounted
class_name AeroUiTweenUtils

const DEFAULT_EASE_TYPE := "smooth"


static func resolve_curve(ease_type: Variant) -> Dictionary:
	if ease_type is Dictionary:
		var ease_dict := ease_type as Dictionary
		return {
			"trans": int(ease_dict.get("trans", Tween.TRANS_SINE)),
			"ease": int(ease_dict.get("ease", Tween.EASE_OUT)),
		}
	if ease_type is int:
		return {
			"trans": Tween.TRANS_SINE,
			"ease": int(ease_type),
		}

	var key := str(ease_type).strip_edges().to_lower()
	match key:
		"", "smooth", "sine_out":
			return {"trans": Tween.TRANS_SINE, "ease": Tween.EASE_OUT}
		"linear":
			return {"trans": Tween.TRANS_LINEAR, "ease": Tween.EASE_IN_OUT}
		"in":
			return {"trans": Tween.TRANS_SINE, "ease": Tween.EASE_IN}
		"out":
			return {"trans": Tween.TRANS_SINE, "ease": Tween.EASE_OUT}
		"in_out":
			return {"trans": Tween.TRANS_SINE, "ease": Tween.EASE_IN_OUT}
		"quad_out", "soft":
			return {"trans": Tween.TRANS_QUAD, "ease": Tween.EASE_OUT}
		"back_out", "snappy":
			return {"trans": Tween.TRANS_BACK, "ease": Tween.EASE_OUT}
		"expo_out", "crisp":
			return {"trans": Tween.TRANS_EXPO, "ease": Tween.EASE_OUT}
		_:
			return {"trans": Tween.TRANS_SINE, "ease": Tween.EASE_OUT}


static func tween_canvas_item_alpha(host: Node, active_tween: Tween, item: CanvasItem, target_alpha: float, tween_speed: float, ease_type: Variant, callback: Callable = Callable()) -> Tween:
	if item == null:
		if callback.is_valid():
			callback.call_deferred()
		return null

	if is_instance_valid(active_tween):
		active_tween.kill()

	var clamped_alpha := clampf(target_alpha, 0.0, 1.0)
	var duration := maxf(0.0, tween_speed)
	if duration <= 0.0:
		item.modulate.a = clamped_alpha
		if callback.is_valid():
			callback.call_deferred()
		return null

	var curve := resolve_curve(ease_type)
	var tween := host.create_tween()
	tween.set_trans(int(curve["trans"]))
	tween.set_ease(int(curve["ease"]))
	tween.tween_property(item, ^"modulate:a", clamped_alpha, duration)
	if callback.is_valid():
		tween.finished.connect(callback, CONNECT_ONE_SHOT)
	return tween
