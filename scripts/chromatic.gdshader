shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;

uniform vec2 r_displacement = vec2(3.0, 0.0);
uniform vec2 g_displacement = vec2(0.0, 0.0);
uniform vec2 b_displacement = vec2(-3.0, 0.0);

void fragment() {
	vec2 r_uv = SCREEN_UV + (SCREEN_PIXEL_SIZE * r_displacement);
	vec2 g_uv = SCREEN_UV + (SCREEN_PIXEL_SIZE * g_displacement);
	vec2 b_uv = SCREEN_UV + (SCREEN_PIXEL_SIZE * b_displacement);
	
	float r = texture(screen_texture, r_uv).r;
	float g = texture(screen_texture, g_uv).g;
	float b = texture(screen_texture, b_uv).b;
	
	COLOR = vec4(r, g, b, 1.0);
}
