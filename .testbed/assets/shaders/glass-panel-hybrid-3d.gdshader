shader_type spatial;
render_mode blend_mix, depth_prepass_alpha, cull_disabled, unshaded, specular_disabled;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap, repeat_disable;
uniform sampler2D ui_texture : source_color, filter_linear_mipmap, repeat_disable;
uniform sampler2D mask_texture : source_color, filter_linear, repeat_disable;

uniform vec4 glass_rect = vec4(0.3375, 0.32222223, 0.325, 0.35555556);

uniform float blur : hint_range(0.0, 8.0) = 4.2;
uniform float warp_intensity : hint_range(0.0, 1.0) = 0.45;
uniform float strength_x : hint_range(0.0, 50.0) = 14.0;
uniform float strength_y : hint_range(0.0, 50.0) = 14.0;
uniform float offset_x : hint_range(-1.0, 1.0) = 0.03;
uniform float offset_y : hint_range(-1.0, 1.0) = 0.0;

uniform float corner_radius : hint_range(0.0, 1.0) = 0.24;
uniform float edge_softness : hint_range(0.001, 0.05, 0.001) = 0.011;
uniform float edge_width : hint_range(0.0, 0.08, 0.001) = 0.018;
uniform float chromatic_strength : hint_range(0.0, 5.0, 0.1) = 1.3;

uniform vec4 tint : source_color = vec4(0.94, 0.968, 1.0, 0.44);
uniform float tint_strength : hint_range(0.0, 1.0, 0.01) = 0.66;
uniform float body_frost_strength : hint_range(0.0, 1.0, 0.01) = 0.85;
uniform float background_subdue : hint_range(0.0, 1.0, 0.01) = 0.86;
uniform float interior_chroma : hint_range(0.0, 1.0, 0.01) = 0.24;
uniform float face_veil_strength : hint_range(0.0, 1.0, 0.01) = 0.18;
uniform float perimeter_frost_boost : hint_range(0.0, 0.5, 0.01) = 0.08;
uniform vec4 edge_color : source_color = vec4(1.0, 1.0, 1.0, 0.08);
uniform float world_rim_refraction : hint_range(0.0, 1.0, 0.01) = 0.09;
uniform float fresnel_power : hint_range(0.5, 8.0, 0.1) = 5.0;
uniform float fresnel_strength : hint_range(0.0, 2.0, 0.01) = 0.04;
uniform float face_highlight : hint_range(0.0, 0.4, 0.01) = 0.015;

uniform float ui_alpha_gain : hint_range(0.0, 2.0, 0.01) = 1.0;
uniform float ui_brightness : hint_range(0.2, 2.0, 0.01) = 1.01;
uniform float ui_shadow_strength : hint_range(0.0, 0.4, 0.01) = 0.02;
uniform float ui_embed_strength : hint_range(0.0, 0.3, 0.01) = 0.01;
uniform bool flip_ui_vertical = false;

float rounded_box_sdf(vec2 p, vec2 half_extents, float radius) {
	vec2 q = abs(p) - half_extents + vec2(radius);
	return length(max(q, vec2(0.0))) + min(max(q.x, q.y), 0.0) - radius;
}

float luminance(vec3 color) {
	return dot(color, vec3(0.299, 0.587, 0.114));
}

void fragment() {
	vec2 panel_uv = flip_ui_vertical ? vec2(UV.x, 1.0 - UV.y) : UV;
	vec2 authored_uv = glass_rect.xy + panel_uv * glass_rect.zw;
	float authored_mask = texture(mask_texture, authored_uv).a;
	if (authored_mask <= 0.001) {
		discard;
	}

	vec2 panel_size_px = max(glass_rect.zw * VIEWPORT_SIZE, vec2(1.0));
	float short_side_px = max(1.0, min(panel_size_px.x, panel_size_px.y));
	float radius_px = min(corner_radius, 0.49) * 0.5 * short_side_px;
	vec2 local_px = (panel_uv - vec2(0.5)) * panel_size_px;
	vec2 half_extents_px = max(panel_size_px * 0.5 - vec2(radius_px), vec2(0.0));
	float sdf_px = rounded_box_sdf(local_px, half_extents_px, radius_px);
	float edge_softness_px = max(edge_softness * short_side_px * 0.5, 0.75);
	float edge_width_px = max(edge_width * short_side_px * 0.45, 1.0);
	float shape_support = 1.0 - smoothstep(0.0, edge_softness_px, sdf_px);

	float max_dist_px = max(1.0, min(half_extents_px.x, half_extents_px.y));
	float w = clamp(-sdf_px / max_dist_px, 0.0, 1.0);
	vec2 centered_ratio = local_px / max(panel_size_px * 0.5, vec2(1.0));
	vec2 uv_dir = length(centered_ratio) > 0.001 ? normalize(centered_ratio) : vec2(0.0, 1.0);
	vec2 axis_distance = abs(centered_ratio);

	float exp_x = exp(-strength_x * pow(axis_distance.x + offset_x, 2.0));
	float exp_y = exp(-strength_y * pow(axis_distance.y + offset_y, 2.0));
	vec2 axis_profile = vec2(exp_x, exp_y) * w;

	vec3 view_dir = normalize(VIEW);
	vec3 normal_dir = normalize(NORMAL);
	float ndotv = clamp(abs(dot(normal_dir, view_dir)), 0.0, 1.0);
	float angle_rim = pow(1.0 - ndotv, 1.4);

	float edge_proximity = 1.0 - w;
	float interior = smoothstep(0.10, 0.94, w);
	float mid_body = smoothstep(0.16, 0.82, w) * (1.0 - smoothstep(0.78, 0.98, w));
	float perimeter_band = smoothstep(0.24, 1.0, edge_proximity);
	float oblique_body = angle_rim * (0.10 + interior * 0.24 + mid_body * 0.18);
	vec2 warp_offset = uv_dir * axis_profile * warp_intensity / 10.0;
	warp_offset *= 1.0 + angle_rim * edge_proximity * world_rim_refraction;
	vec2 sample_uv = SCREEN_UV - warp_offset;

	vec2 screen_pixel_size = 1.0 / VIEWPORT_SIZE;
	float chroma_weight = mix(interior_chroma * (0.94 + interior * 0.08), 0.86, edge_proximity);
	vec2 chroma_offset = uv_dir * chroma_weight * chromatic_strength * screen_pixel_size;

	float interior_blur = blur + 1.2 + interior * (background_subdue * 3.2 + body_frost_strength * 0.95) + oblique_body * 0.75 + face_veil_strength * 0.45;
	float perimeter_blur = blur + 0.48 + perimeter_band * perimeter_frost_boost * 0.9;
	float outer_blur = blur + 3.1 + background_subdue * 2.8 + interior * 1.4 + oblique_body * 0.35;
	vec3 background = vec3(
		textureLod(screen_texture, sample_uv - chroma_offset, perimeter_blur).r,
		textureLod(screen_texture, sample_uv, interior_blur).g,
		textureLod(screen_texture, sample_uv + chroma_offset, perimeter_blur).b
	);
	vec3 background_soft = textureLod(screen_texture, sample_uv, outer_blur).rgb;
	vec3 subdued_background = mix(background, background_soft, 0.58 + interior * background_subdue * 0.38 + mid_body * 0.08 + oblique_body * 0.18);
	subdued_background = mix(subdued_background, background_soft, interior * 0.08 + oblique_body * 0.12);
	float subdued_luma = luminance(subdued_background);
	vec3 neutral_background = vec3(subdued_luma);
	vec3 compressed_background = mix(neutral_background, subdued_background, 0.48 + interior_chroma * 0.22 + interior * 0.07 - oblique_body * 0.10);
	compressed_background = mix(compressed_background, subdued_background * 0.88 + neutral_background * 0.12, 0.30 + interior * background_subdue * 0.20 + mid_body * 0.08 + oblique_body * 0.10);

	float edge = 1.0 - smoothstep(0.0, edge_width_px, -sdf_px);
	edge *= step(sdf_px, 0.0) * shape_support;
	float fresnel = pow(1.0 - ndotv, fresnel_power);
	float face_sheen = smoothstep(0.78, 0.10, panel_uv.y) * face_highlight * (0.22 + interior * 0.42);
	float face_veil = face_veil_strength * (0.10 + interior * 0.18 + mid_body * 0.08 + smoothstep(0.88, 0.20, panel_uv.y) * 0.08);
	float edge_face_lift = perimeter_band * perimeter_frost_boost * (0.18 + angle_rim * 0.10);

	float body_mix = clamp(tint.a + tint_strength * 0.18 + body_frost_strength * (0.35 + interior * 0.27 + mid_body * 0.05) + oblique_body * 0.10 + face_veil * 0.06 + edge_face_lift * 0.03, 0.0, 0.985);
	vec3 tint_weighted_body = mix(compressed_background, tint.rgb, 0.24 + tint_strength * 0.20 + interior * 0.13 + mid_body * 0.06 + oblique_body * 0.08);
	vec3 frost_core = mix(tint_weighted_body, tint.rgb, interior * (0.22 + body_frost_strength * 0.20) + mid_body * 0.08 + oblique_body * 0.08 + face_veil * 0.04);
	vec3 glass_color = mix(compressed_background, tint_weighted_body, body_mix);
	glass_color = mix(glass_color, frost_core, interior * (0.24 + body_frost_strength * 0.20) + mid_body * 0.06 + oblique_body * 0.08);
	glass_color = mix(glass_color, edge_color.rgb, edge * edge_color.a * 0.16);
	glass_color += edge_color.rgb * fresnel * fresnel_strength * (0.06 + edge_proximity * 0.12);
	glass_color += vec3(face_sheen);

	vec4 ui_sample = texture(ui_texture, authored_uv);
	float ui_alpha = clamp(ui_sample.a * ui_alpha_gain, 0.0, 1.0);
	float ui_shadow = smoothstep(0.0, 0.6, ui_alpha) * ui_shadow_strength;
	float ui_underlay = ui_alpha * ui_embed_strength;
	glass_color = mix(glass_color, glass_color * (1.0 - ui_shadow) + tint.rgb * 0.025, ui_underlay);

	float glass_alpha = clamp(authored_mask * (0.38 + tint.a * 0.92 + interior * body_frost_strength * 0.34 + face_veil * 0.04 + edge * 0.02), 0.32, 0.992);

	ALBEDO = glass_color;
	EMISSION = edge_color.rgb * (edge * 0.008 + fresnel * fresnel_strength * 0.018) + tint.rgb * face_sheen * 0.08;
	ALPHA = max(glass_alpha, ui_alpha * 0.02);
}
