shader_type spatial;

uniform float tile_scale = 8.0;
uniform vec4 color_a: source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 color_b: source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
	vec2 tile = floor(UV * tile_scale);
	float blend_factor = mod(tile.x + tile.y, 2.0);
	ALBEDO = mix(color_a.rgb, color_b.rgb, blend_factor);
}