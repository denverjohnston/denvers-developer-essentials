shader_type spatial;

uniform vec4 deep_color : source_color = vec4(0.02, 0.20, 0.28, 1.0);
uniform vec4 light_color : source_color = vec4(0.12, 0.55, 0.58, 1.0);

uniform float wave_scale = 8.0;
uniform float wave_speed = 1.2;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 p = UV * wave_scale;
	float wave = sin((p.x + p.y * 0.6) * 6.0 + TIME * wave_speed);
	float blend = smoothstep(-0.2, 0.7, wave);
	
	ALBEDO = mix(deep_color.rgb, light_color.rgb, blend);
	ROUGHNESS = 0.2;
	METALLIC = 0.0;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
