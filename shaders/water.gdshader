shader_type spatial;
// Back faces are culled; the underwater effect draws the view from below.
render_mode blend_mix, cull_back;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;
uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;
uniform vec3 extinction_coefficients = vec3(0.65, 0.20, 0.08);
uniform vec3 scattering_color : source_color = vec3(0.03, 0.30, 0.42);
uniform float max_water_thickness = 20.0;

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

	float view_angle = clamp(abs(dot(normalize(NORMAL), normalize(VIEW))), 0.0, 1.0);
	float fresnel = 0.02 + 0.98 * pow(1.0 - view_angle, 5.0);

	// Refracted scene is already lit, so it is emitted; the engine adds sky reflections via specular IBL.
	EMISSION = scene_color * transmittance * (1.0 - fresnel);
	ALBEDO = in_scattering * (1.0 - fresnel);
	SPECULAR = 0.5;
	ROUGHNESS = 0.05;
	ALPHA = 1.0;
}
