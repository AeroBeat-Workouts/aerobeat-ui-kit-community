shader_type spatial;
render_mode blend_mix, depth_prepass_alpha, cull_disabled, unshaded, specular_disabled;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap, repeat_disable;
uniform sampler2D ui_texture : source_color, filter_linear_mipmap, repeat_disable;

uniform float blur : hint_range(0.0, 8.0) = 4.2;
uniform float refraction_strength : hint_range(0.0, 0.12, 0.001) = 0.028;
uniform float curvature : hint_range(0.0, 3.0, 0.01) = 1.2;
uniform float corner_radius : hint_range(0.0, 0.45, 0.001) = 0.18;
uniform float edge_softness : hint_range(0.001, 0.05, 0.001) = 0.012;
uniform float edge_width : hint_range(0.0, 0.2, 0.001) = 0.06;
uniform float chromatic_aberration : hint_range(0.0, 4.0, 0.1) = 1.7;

uniform vec4 tint : source_color = vec4(0.9, 0.95, 1.0, 0.34);
uniform float tint_strength : hint_range(0.0, 1.0, 0.01) = 0.28;
uniform vec4 edge_color : source_color = vec4(1.0, 1.0, 1.0, 0.72);
uniform float fresnel_power : hint_range(0.5, 8.0, 0.1) = 4.0;
uniform float fresnel_strength : hint_range(0.0, 2.0, 0.01) = 0.42;
uniform float face_highlight : hint_range(0.0, 0.4, 0.01) = 0.08;

uniform float ui_alpha_gain : hint_range(0.0, 2.0, 0.01) = 1.0;
uniform float ui_brightness : hint_range(0.2, 2.0, 0.01) = 1.0;
uniform float ui_shadow_strength : hint_range(0.0, 0.4, 0.01) = 0.08;
uniform bool flip_ui_vertical = false;

float rounded_box_sdf(vec2 p, vec2 half_extents, float radius) {
	vec2 q = abs(p) - half_extents + vec2(radius);
	return length(max(q, vec2(0.0))) + min(max(q.x, q.y), 0.0) - radius;
}

void fragment() {
	float radius = min(corner_radius, 0.49);
	vec2 local_uv = UV - vec2(0.5);
	vec2 half_extents = vec2(0.5 - radius);
	float sdf = rounded_box_sdf(local_uv, half_extents, radius);
	float mask = 1.0 - smoothstep(0.0, edge_softness, sdf);
	if (mask <= 0.001) {
		discard;
	}

	vec2 normalized_local = local_uv / max(half_extents, vec2(0.001));
	float radial = clamp(length(normalized_local), 0.0, 1.0);
	vec2 warp_dir = radial > 0.0001 ? normalized_local / radial : vec2(0.0, -1.0);

	vec3 view_dir = normalize(VIEW);
	vec3 normal_dir = normalize(NORMAL);
	float ndotv = clamp(abs(dot(normal_dir, view_dir)), 0.0, 1.0);
	float angle_rim = pow(1.0 - ndotv, 1.4);

	float interior_weight = pow(1.0 - radial, max(curvature, 0.001));
	vec2 refraction = warp_dir * refraction_strength * (interior_weight + angle_rim * 0.65);
	vec2 sample_uv = SCREEN_UV - refraction;

	vec2 screen_pixel_size = 1.0 / VIEWPORT_SIZE;
	vec2 chroma_offset = warp_dir * screen_pixel_size * chromatic_aberration * (0.3 + angle_rim * 0.7);
	float bg_r = textureLod(screen_texture, sample_uv - chroma_offset, blur).r;
	float bg_g = textureLod(screen_texture, sample_uv, blur).g;
	float bg_b = textureLod(screen_texture, sample_uv + chroma_offset, blur).b;
	vec3 background = vec3(bg_r, bg_g, bg_b);

	float distance_to_edge = max(-sdf, 0.0);
	float edge_band = 1.0 - smoothstep(edge_width, edge_width + edge_softness * 2.0, distance_to_edge);
	float fresnel = pow(1.0 - ndotv, fresnel_power);
	float face_sheen = face_highlight * (0.35 + interior_weight * 0.65) * (0.45 + angle_rim * 0.55);

	vec3 glass_color = mix(background, tint.rgb, tint_strength * tint.a);
	glass_color += edge_color.rgb * edge_color.a * edge_band;
	glass_color += edge_color.rgb * fresnel * fresnel_strength;
	glass_color += vec3(face_sheen);

	vec2 ui_uv = flip_ui_vertical ? vec2(UV.x, 1.0 - UV.y) : UV;
	vec4 ui_sample = texture(ui_texture, ui_uv);
	float ui_alpha = clamp(ui_sample.a * ui_alpha_gain, 0.0, 1.0) * mask;
	float ui_shadow = smoothstep(0.0, 0.55, ui_sample.a) * ui_shadow_strength;
	vec3 ui_rgb = ui_sample.rgb * ui_brightness;

	vec3 color = glass_color * (1.0 - ui_shadow);
	color = mix(color, ui_rgb, ui_alpha);
	color += edge_color.rgb * ui_shadow * 0.25;

	float glass_alpha = clamp(mask * (tint.a + edge_band * 0.22 + fresnel * 0.12), 0.05, 0.98);

	ALBEDO = color;
	EMISSION = edge_color.rgb * (edge_band * 0.12 + fresnel * fresnel_strength * 0.18) + ui_rgb * ui_alpha * 0.03;
	ALPHA = max(glass_alpha, ui_alpha);
}
