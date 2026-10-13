shader_type sky;

uniform sampler2D cloud_noise : repeat_enable;

void sky() {
	vec2 uv = vec2(
		atan(EYEDIR.z, EYEDIR.x) / (1.0 * PI) + 0.5,
		asin(EYEDIR.y) / PI + 0.5
	);
	uv.x += TIME * 0.005;
	
	float noise = texture(cloud_noise, uv * 1.0).r;
	float cloud_mask = smoothstep(0.58, 0.72, noise);
	
	float height = EYEDIR.y + 0.5;
	float gradient = smoothstep(0.0, 1.0, height);
	
	COLOR = mix(vec3(1.0, 1.0, 1.0), vec3(0.0, 0.3, 0.8), gradient);
	COLOR = mix(COLOR, vec3(1.0, 1.0, 1.0), cloud_mask);
}
