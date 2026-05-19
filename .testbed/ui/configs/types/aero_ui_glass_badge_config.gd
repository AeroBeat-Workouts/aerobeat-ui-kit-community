extends RefCounted
class_name AeroUiGlassBadgeConfig

const SCHEMA := "aero.ui.glass_badge"
const SCHEMA_VERSION := 1

var source_path := ""
var variant := "default"
var version := "v1"
var base_fill_alpha := 0.08
var base_border_alpha := 0.14
var base_label_alpha := 0.78
var base_radius := 14
var hybrid_fill_alpha := 0.18
var hybrid_border_alpha := 0.267
var hybrid_label_alpha := 0.9


func get_tokens(is_hybrid_world: bool) -> Dictionary:
	if is_hybrid_world:
		return {
			"fill_alpha": hybrid_fill_alpha,
			"border_alpha": hybrid_border_alpha,
			"label_alpha": hybrid_label_alpha,
			"radius": base_radius,
		}
	return {
		"fill_alpha": base_fill_alpha,
		"border_alpha": base_border_alpha,
		"label_alpha": base_label_alpha,
		"radius": base_radius,
	}
