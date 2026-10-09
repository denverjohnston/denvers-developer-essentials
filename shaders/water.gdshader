shader_type spatial;
// Back faces are culled; the underwater effect draws the view from below.
render_mode blend_mix, cull_back;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;
uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;
uniform vec3 extinction_coefficients = vec3(0.65, 0.20, 0.08);
uniform vec3 scattering_color : source_color = vec3(0.03, 0.30, 0.42);
uniform float max_water_thickness = 20.0;
uniform float wave_amplitude = 0.02;
uniform float wave_length = 1.5;
uniform float wave_speed = 1.0;

// Returns (height, d/dx, d/dz) of standing waves at world position p; they oscillate in place, not travel.
vec3 wave(vec2 p) {
	vec2 dirs[4] = vec2[](vec2(1.0, 0.0), vec2(0.0, 1.0), normalize(vec2(1.0, 1.0)), normalize(vec2(1.0, -1.0)));
	float amps[4] = float[](1.0, 0.8, 0.6, 0.5);
	float freqs[4] = float[](1.0, 1.3, 1.9, 2.6);
	float offsets[4] = float[](0.0, 1.7, 3.1, 4.6);
	vec3 result = vec3(0.0);
	for (int i = 0; i < 4; i++) {
		float k = 6.2831853 / wave_length * freqs[i];
		float phase = dot(dirs[i], p) * k + offsets[i];
		float pulse = sin(TIME * wave_speed * freqs[i] + offsets[i] * 2.0);
		float a = wave_amplitude * amps[i];
		result.x += a * sin(phase) * pulse;
		result.yz += a * k * cos(phase) * pulse * dirs[i];
	}
	return result;
}

void vertex() {
	vec3 w = wave((MODEL_MATRIX * vec4(VERTEX, 1.0)).xz);
	VERTEX.y += w.x;
	NORMAL = normalize(vec3(-w.y, 1.0, -w.z));
}

void fragment() {
	float raw_depth = texture(depth_texture, SCREEN_UV).r;
	vec3 surface_world = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec3 surface_normal_world = normalize((MODEL_MATRIX * vec4(0.0, 1.0, 0.0, 0.0)).xyz);

	float water_thickness = 0.0;
	if (raw_depth > 0.000001) {
		vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, raw_depth);
		vec4 scene_view_h = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
		vec3 scene_view = scene_view_h.xyz / scene_view_h.w;
		vec3 scene_world = (INV_VIEW_MATRIX * vec4(scene_view, 1.0)).xyz;
		bool scene_is_underwater = dot(scene_world - surface_world, surface_normal_world) < 0.0;
		if (scene_is_underwater) {
			water_thickness = length(scene_view - VERTEX);
		}
	}
	water_thickness = min(water_thickness, max_water_thickness);

	vec3 transmittance = exp(-extinction_coefficients * water_thickness);
	vec3 scene_color = texture(screen_texture, SCREEN_UV).rgb;
	vec3 in_scattering = scattering_color * (vec3(1.0) - transmittance);

	// Refracted scene is already lit, so it is emitted; the engine lights the scattering and adds a faint sky reflection.
	EMISSION = scene_color * transmittance;
	ALBEDO = in_scattering;
	SPECULAR = 0.2;
	ROUGHNESS = 0.3;
	ALPHA = 1.0;
}
