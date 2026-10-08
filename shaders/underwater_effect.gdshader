shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;
uniform vec4 underwater_tint : source_color = vec4(0.02, 0.24, 0.32, 1.0);
uniform float tint_strength = 0.32;
uniform float distortion_strength = 0.0015;
uniform float wave_frequency = 34.0;
uniform float wave_speed = 1.4;

void fragment() {
	float effect_opacity = COLOR.a;
	vec2 uv = SCREEN_UV;
	vec2 ripple = vec2(
		sin(uv.y * wave_frequency + TIME * wave_speed),
		cos(uv.x * wave_frequency * 0.8 - TIME * wave_speed)
	);
	vec3 scene_color = texture(screen_texture, uv + ripple * distortion_strength).rgb;
	
	COLOR = vec4(mix(scene_color, underwater_tint.rgb, tint_strength), effect_opacity);
}