shader_type canvas_item;

uniform float speed : hint_range(0.1, 5.0) = 1.0;
uniform vec4 col1 : source_color = vec4(0.05, 0.02, 0.15, 0.5);
uniform vec4 col2 : source_color = vec4(0.2, 0.05, 0.4, 0.5);

void fragment() {
	float wave = sin(UV.x * 10.0 + TIME * speed) * cos(UV.y * 10.0 + TIME * speed);
	// float wave = sin(UV.x * 10.0 + TIME * speed) * cos(UV.y * 10.0 + TIME * speed) - tan(UV.y * 5.0 + TIME * speed);

	vec4 finalcol = mix(col1, col2, wave * 0.5 + 0.5);
	COLOR = finalcol;
}
