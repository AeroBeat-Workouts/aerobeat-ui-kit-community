extends RefCounted
class_name AeroUiGlassPrimaryButtonConfig

const SCHEMA := "aero.ui.glass_primary_button"
const SCHEMA_VERSION := 1
const DEFAULT_STATE := {
	"fill_delta": 0.0,
	"border_delta": 0.0,
	"shadow_alpha": 0.0,
	"shadow_size": 0,
	"tint_strength": 0.0,
	"scale": 1.0,
}

var source_path := ""
var variant := "default"
var version := "v1"
var border_width := 2
var radius_delta := 5
var background_tint := Color(0.92, 0.96, 1.0, 1.0)
var interaction_tint := Color(0.4, 0.82, 1.0, 1.0)
var source_label_alpha := 0.95
var hybrid_label_alpha := 0.98
var source_meta_alpha := 0.66
var hybrid_meta_alpha := 0.7
var source_states := {
	"rest": {"fill_delta": 0.13, "border_delta": 0.38, "shadow_alpha": 0.0, "shadow_size": 0, "tint_strength": 0.0, "scale": 1.0},
	"hover": {"fill_delta": 0.17, "border_delta": 0.46, "shadow_alpha": 0.0, "shadow_size": 0, "tint_strength": 0.34, "scale": 1.01},
	"pressed": {"fill_delta": 0.22, "border_delta": 0.54, "shadow_alpha": 0.0, "shadow_size": 0, "tint_strength": 0.72, "scale": 0.988},
}
var hybrid_states := {
	"rest": {"fill_delta": 0.20, "border_delta": 0.39, "shadow_alpha": 0.18, "shadow_size": 10, "tint_strength": 0.0, "scale": 1.0},
	"hover": {"fill_delta": 0.25, "border_delta": 0.46, "shadow_alpha": 0.24, "shadow_size": 12, "tint_strength": 0.34, "scale": 1.012},
	"pressed": {"fill_delta": 0.31, "border_delta": 0.50, "shadow_alpha": 0.28, "shadow_size": 12, "tint_strength": 0.72, "scale": 0.988},
}


func get_state(is_hybrid_world: bool, phase: String) -> Dictionary:
	var source: Dictionary = hybrid_states if is_hybrid_world else source_states
	var state: Dictionary = source.get(phase, source.get("rest", DEFAULT_STATE)) as Dictionary
	return _duplicate_state(state)


func get_label_alpha(is_hybrid_world: bool) -> float:
	return hybrid_label_alpha if is_hybrid_world else source_label_alpha


func get_meta_alpha(is_hybrid_world: bool) -> float:
	return hybrid_meta_alpha if is_hybrid_world else source_meta_alpha


func _duplicate_state(state: Dictionary) -> Dictionary:
	return {
		"fill_delta": float(state.get("fill_delta", 0.0)),
		"border_delta": float(state.get("border_delta", 0.0)),
		"shadow_alpha": float(state.get("shadow_alpha", 0.0)),
		"shadow_size": int(state.get("shadow_size", 0)),
		"tint_strength": float(state.get("tint_strength", 0.0)),
		"scale": float(state.get("scale", 1.0)),
	}
