shader_type canvas_item;

// Captures everything rendered behind this ColorRect
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

// Adjust these in the Inspector to change the look
uniform float aura_size : hint_range(0.0, 50.0) = 12.0;
uniform float aura_intensity : hint_range(0.0, 2.0) = 0.6;
uniform vec4 aura_tint : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
	vec2 pixel_size = SCREEN_PIXEL_SIZE * aura_size;
	vec4 original_color = texture(screen_texture, SCREEN_UV);
	vec4 blur_color = vec4(0.0);
	float total_weight = 0.0;

	// Samples surrounding pixels to create a soft, static gradient falloff
	for (float x = -4.0; x <= 4.0; x += 1.0) {
		for (float y = -4.0; y <= 4.0; y += 1.0) {
			vec2 offset = vec2(x, y);
			float dist = length(offset);
			
			// Circular gradient falloff
			if (dist <= 4.0) {
				float weight = 1.0 - (dist / 4.0);
				blur_color += texture(screen_texture, SCREEN_UV + offset * pixel_size) * weight;
				total_weight += weight;
			}
		}
	}

	blur_color /= total_weight;

	// Blends the glowing aura on top of the original screen
	vec3 final_rgb = original_color.rgb + (blur_color.rgb * aura_tint.rgb * aura_intensity);
	COLOR = vec4(final_rgb, original_color.a);
}
