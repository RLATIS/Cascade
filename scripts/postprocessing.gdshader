shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;

group_uniforms Chromatic_Aberration;
uniform vec2 r_displacement = vec2(3.0, 0.0);
uniform vec2 g_displacement = vec2(0.0, 0.0);
uniform vec2 b_displacement = vec2(-3.0, 0.0);

uniform float aura_size : hint_range(0.0, 50.0) = 12.0;
uniform float aura_intensity : hint_range(0.0, 2.0) = 0.6;
uniform vec4 aura_tint : source_color = vec4(1.0, 1.0, 1.0, 1.0);

vec3 get_aberration(vec2 uv, vec2 pixel_size) {
	float r = texture(screen_texture, uv + (pixel_size * r_displacement)).r;
	float g = texture(screen_texture, uv + (pixel_size * g_displacement)).g;
	float b = texture(screen_texture, uv + (pixel_size * b_displacement)).b;
	return vec3(r, g, b);
}

void fragment() {
	vec3 base_rgb = get_aberration(SCREEN_UV, SCREEN_PIXEL_SIZE);
	vec2 blur_step = SCREEN_PIXEL_SIZE * aura_size;
	vec3 blur_color = vec3(0.0);
	float total_weight = 0.0;

	for (float x = -4.0; x <= 4.0; x += 1.0) {
		for (float y = -4.0; y <= 4.0; y += 1.0) {
			vec2 offset = vec2(x, y);
			float dist = length(offset);

			if (dist <= 4.0) {
				float weight = 1.0 - (dist / 4.0);
				blur_color += get_aberration(SCREEN_UV + offset * blur_step, SCREEN_PIXEL_SIZE) * weight;
				total_weight += weight;
			}
		}
	}

	blur_color /= total_weight;

	vec3 final_rgb = base_rgb + (blur_color * aura_tint.rgb * aura_intensity);
	COLOR = vec4(final_rgb, 1.0);
}
