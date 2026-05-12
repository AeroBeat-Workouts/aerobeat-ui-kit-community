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
uniform float chromatic_strength : hint_range(0.0, 5.0, 0.1) = 2.2;

uniform vec4 tint : source_color = vec4(0.92, 0.96, 1.0, 0.22);
uniform float tint_strength : hint_range(0.0, 1.0, 0.01) = 0.28;
uniform vec4 edge_color : source_color = vec4(1.0, 1.0, 1.0, 0.62);
uniform float world_rim_refraction : hint_range(0.0, 1.0, 0.01) = 0.55;
uniform float fresnel_power : hint_range(0.5, 8.0, 0.1) = 4.0;
uniform float fresnel_strength : hint_range(0.0, 2.0, 0.01) = 0.42;
uniform float face_highlight : hint_range(0.0, 0.4, 0.01) = 0.10;

uniform float ui_alpha_gain : hint_range(0.0, 2.0, 0.01) = 1.0;
uniform float ui_brightness : hint_range(0.2, 2.0, 0.01) = 1.0;
uniform float ui_shadow_strength : hint_range(0.0, 0.4, 0.01) = 0.06;
uniform bool flip_ui_vertical = false;

float rounded_box_sdf(vec2 p, vec2 half_extents, float radius) {
	vec2 q = abs(p) - half_extents + vec2(radius);
	return length(max(q, vec2(0.0))) + min(max(q.x, q.y), 0.0) - radius;
}

void fragment() {
	vec2 panel_uv = flip_ui_vertical ? vec2(UV.x, 1.0 - UV.y) : UV;
	vec2 authored_uv = glass_rect.xy + panel_uv * glass_rect.zw;
	float authored_mask = texture(mask_texture, authored_uv).a;
	if (authored_mask <= 0.001) {
		discard;
	}

	vec2 rect_uv = panel_uv;
	vec2 local_uv = rect_uv - vec2(0.5);
	float radius = min(corner_radius, 0.49);
	vec2 half_extents = vec2(0.5 - radius);
	float sdf = rounded_box_sdf(local_uv, half_extents, radius);
	float card_mask = 1.0 - smoothstep(0.0, edge_softness, sdf);
	float mask = clamp(authored_mask * card_mask, 0.0, 1.0);
	if (mask <= 0.001) {
		discard;
	}

	float max_dist = min(half_extents.x, half_extents.y) * 0.5;
	float w = clamp(-sdf / max_dist, 0.0, 1.0);
	vec2 centered_ratio = local_uv * 2.0;
	vec2 uv_dir = length(centered_ratio) > 0.001 ? normalize(centered_ratio) : vec2(0.0, 1.0);
	vec2 axis_distance = abs(centered_ratio);

	float exp_x = exp(-strength_x * pow(axis_distance.x + offset_x, 2.0));
	float exp_y = exp(-strength_y * pow(axis_distance.y + offset_y, 2.0));
	vec2 axis_profile = vec2(exp_x, exp_y) * w;

	vec3 view_dir = normalize(VIEW);
	vec3 normal_dir = normalize(NORMAL);
	float ndotv = clamp(abs(dot(normal_dir, view_dir)), 0.0, 1.0);
	float angle_rim = pow(1.0 - ndotv, 1.4);

	vec2 warp_offset = uv_dir * axis_profile * warp_intensity / 10.0;
	warp_offset *= 1.0 + angle_rim * world_rim_refraction;
	vec2 sample_uv = SCREEN_UV - warp_offset;

	float edge_proximity = 1.0 - w;
	vec2 screen_pixel_size = 1.0 / VIEWPORT_SIZE;
	vec2 chroma_offset = uv_dir * edge_proximity * chromatic_strength * screen_pixel_size;

	float bg_r = textureLod(screen_texture, sample_uv - chroma_offset, blur).r;
	float bg_g = textureLod(screen_texture, sample_uv, blur).g;
	float bg_b = textureLod(screen_texture, sample_uv + chroma_offset, blur).b;
	vec3 background = vec3(bg_r, bg_g, bg_b);

	float edge = 1.0 - smoothstep(0.0, edge_width, -sdf);
	edge *= step(sdf, 0.0);
	float fresnel = pow(1.0 - ndotv, fresnel_power);
	float face_sheen = smoothstep(0.45, 0.0, rect_uv.y) * face_highlight * w;

	vec3 glass_color = mix(background, tint.rgb, tint.a + tint_strength * 0.25);
	glass_color = mix(glass_color, edge_color.rgb, edge * edge_color.a);
	glass_color += edge_color.rgb * fresnel * fresnel_strength;
	glass_color += vec3(face_sheen);

	vec4 ui_sample = texture(ui_texture, authored_uv);
	float ui_alpha = clamp(ui_sample.a * ui_alpha_gain, 0.0, 1.0);
	float ui_shadow = smoothstep(0.0, 0.6, ui_alpha) * ui_shadow_strength;
	vec3 ui_rgb = ui_sample.rgb * ui_brightness;

	vec3 color = glass_color * (1.0 - ui_shadow);
	color = mix(color, ui_rgb, ui_alpha);
	color += edge_color.rgb * ui_shadow * 0.18;

	float glass_alpha = clamp(mask * (tint.a + edge * 0.18 + fresnel * 0.10), 0.05, 0.98);

	ALBEDO = color;
	EMISSION = edge_color.rgb * (edge * 0.12 + fresnel * fresnel_strength * 0.16) + ui_rgb * ui_alpha * 0.02;
	ALPHA = max(glass_alpha, ui_alpha);
}
