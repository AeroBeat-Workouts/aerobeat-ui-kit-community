extends RefCounted
class_name AeroUiGlassHybridBodyConfig

const SCHEMA := "aero.ui.glass_hybrid_body"
const SCHEMA_VERSION := 1
const BODY_FLOAT_PARAMETER_NAMES := [
	"tint_strength",
	"body_frost_strength",
	"background_subdue",
	"interior_chroma",
	"world_rim_refraction",
	"fresnel_power",
	"fresnel_strength",
	"face_highlight",
	"face_veil_strength",
	"perimeter_frost_boost",
]

var source_path := ""
var variant := "hybrid-3d-body"
var version := "v1"
var material_parameters := {
	"tint_strength": 0.66,
	"body_frost_strength": 0.85,
	"background_subdue": 0.86,
	"interior_chroma": 0.24,
	"world_rim_refraction": 0.09,
	"fresnel_power": 5.0,
	"fresnel_strength": 0.04,
	"face_highlight": 0.015,
	"face_veil_strength": 0.18,
	"perimeter_frost_boost": 0.08,
}
