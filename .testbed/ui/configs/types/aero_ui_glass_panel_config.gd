extends RefCounted
class_name AeroUiGlassPanelConfig

const SCHEMA := "aero.ui.glass_panel"
const SCHEMA_VERSION := 1

var source_path := ""
var variant := "default"
var version := "v1"
var shader_parameters := {
	"blur": 4.2,
	"warp_intensity": 0.45,
	"strength_x": 14.0,
	"strength_y": 14.0,
	"offset_x": 0.03,
	"offset_y": 0.0,
	"corner_radius": 0.24,
	"edge_smoothness": 1.1,
	"edge_width": 2.4,
	"chromatic_strength": 2.2,
	"tint": Color(0.92, 0.96, 1.0, 0.22),
	"edge_highlight": Color(1.0, 1.0, 1.0, 0.62),
}
var frame_alpha_boost := 0.18
var hybrid_inner_border_brightness := 1.0
var hybrid_inner_border_alpha := 0.312
var badge_preset_path := ""
var primary_button_preset_path := ""
var badge_config: AeroUiGlassBadgeConfig
var primary_button_config: AeroUiGlassPrimaryButtonConfig
