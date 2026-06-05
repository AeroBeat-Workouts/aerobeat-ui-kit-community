shader_type spatial;
render_mode blend_mix, depth_prepass_alpha, cull_disabled, unshaded, specular_disabled;

uniform sampler2D ui_texture : source_color, filter_linear, repeat_disable;
uniform sampler2D mask_texture : source_color, filter_linear, repeat_disable;

uniform vec4 glass_rect = vec4(0.3375, 0.32222223, 0.325, 0.35555556);
uniform float ui_overlay_alpha : hint_range(0.0, 2.0, 0.01) = 1.08;
uniform float ui_overlay_brightness : hint_range(0.2, 2.0, 0.01) = 1.06;
uniform float ui_overlay_shadow_strength : hint_range(0.0, 0.25, 0.01) = 0.015;
uniform float ui_overlay_tint_mix : hint_range(0.0, 0.3, 0.01) = 0.02;
uniform vec4 ui_overlay_tint : source_color = vec4(0.96, 0.98, 1.0, 1.0);
uniform bool flip_ui_vertical = false;

void fragment() {
	vec2 panel_uv = flip_ui_vertical ? vec2(UV.x, 1.0 - UV.y) : UV;
	vec2 authored_uv = glass_rect.xy + panel_uv * glass_rect.zw;
	float authored_mask = texture(mask_texture, authored_uv).a;
	vec4 ui_sample = texture(ui_texture, authored_uv);
	float ui_alpha = clamp(ui_sample.a * authored_mask * ui_overlay_alpha, 0.0, 1.0);
	if (ui_alpha <= 0.001) {
		discard;
	}

	float ui_shadow = smoothstep(0.0, 0.7, ui_alpha) * ui_overlay_shadow_strength;
	vec3 ui_rgb = mix(ui_sample.rgb * ui_overlay_brightness, ui_overlay_tint.rgb * ui_overlay_brightness, ui_overlay_tint_mix * ui_alpha);
	ui_rgb *= 1.0 - ui_shadow;

	ALBEDO = ui_rgb;
	EMISSION = ui_rgb * ui_alpha * 0.01;
	ALPHA = ui_alpha;
}
