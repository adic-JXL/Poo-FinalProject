shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform vec2 center = vec2(0.5, 0.5);
uniform float vignette_radius : hint_range(0.1, 1.5) = 0.56;
uniform float vignette_softness : hint_range(0.01, 1.0) = 0.28;
uniform float blur_strength : hint_range(0.0, 6.0) = 2.2;
uniform float edge_darkness : hint_range(0.0, 1.0) = 0.18;
uniform float tint_strength : hint_range(0.0, 1.0) = 0.12;
uniform float edge_desaturation : hint_range(0.0, 1.0) = 0.18;
uniform float aberration_strength : hint_range(0.0, 4.0) = 1.2;
uniform float pulse_strength : hint_range(0.0, 0.12) = 0.02;
uniform float pulse_speed : hint_range(0.0, 4.0) = 0.8;

void fragment() {
	vec2 uv = SCREEN_UV;
	vec4 base_color = textureLod(screen_texture, uv, 0.0);

	float aspect = SCREEN_PIXEL_SIZE.y / max(SCREEN_PIXEL_SIZE.x, 0.00001);
	vec2 radial_uv = uv - center;
	radial_uv.x *= aspect;
	float distance_to_center = length(radial_uv);

	float pulse = sin(TIME * pulse_speed) * pulse_strength * COLOR.a;
	float dynamic_radius = vignette_radius + pulse;
	float edge_mask = smoothstep(dynamic_radius, dynamic_radius + vignette_softness, distance_to_center);
	float intensity = clamp(edge_mask * COLOR.a, 0.0, 1.0);
	vec2 radial_dir = distance_to_center > 0.0001 ? normalize(radial_uv) : vec2(0.0);

	vec2 blur_offset = SCREEN_PIXEL_SIZE * blur_strength * (0.45 + intensity);
	vec4 blurred = base_color;
	blurred += textureLod(screen_texture, uv + vec2( blur_offset.x, 0.0), 0.0);
	blurred += textureLod(screen_texture, uv + vec2(-blur_offset.x, 0.0), 0.0);
	blurred += textureLod(screen_texture, uv + vec2(0.0,  blur_offset.y), 0.0);
	blurred += textureLod(screen_texture, uv + vec2(0.0, -blur_offset.y), 0.0);
	blurred += textureLod(screen_texture, uv + blur_offset, 0.0);
	blurred += textureLod(screen_texture, uv - blur_offset, 0.0);
	blurred += textureLod(screen_texture, uv + vec2( blur_offset.x, -blur_offset.y), 0.0);
	blurred += textureLod(screen_texture, uv + vec2(-blur_offset.x,  blur_offset.y), 0.0);
	blurred /= 9.0;

	vec3 tinted_blur = mix(blurred.rgb, blurred.rgb * COLOR.rgb * 2.2, tint_strength * intensity);
	float luma = dot(tinted_blur, vec3(0.299, 0.587, 0.114));
	vec3 dream_blur = mix(tinted_blur, vec3(luma), edge_desaturation * intensity);

	vec2 aberration_offset = radial_dir * SCREEN_PIXEL_SIZE * aberration_strength * (0.5 + intensity * 2.0);
	vec3 aberrated = vec3(
		textureLod(screen_texture, uv + aberration_offset, 0.0).r,
		textureLod(screen_texture, uv, 0.0).g,
		textureLod(screen_texture, uv - aberration_offset, 0.0).b
	);
	vec3 peripheral = mix(dream_blur, aberrated, 0.28 * intensity);
	vec3 final_rgb = mix(base_color.rgb, peripheral, intensity);
	final_rgb = mix(final_rgb, vec3(0.0), intensity * edge_darkness);

	COLOR = vec4(final_rgb, 1.0);
}
