shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled, fog_disabled;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;
uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;
uniform vec3 extinction_coefficients = vec3(0.65, 0.20, 0.08);
uniform vec3 scattering_color : source_color = vec3(0.03, 0.30, 0.42);
uniform vec4 reflection_color : source_color = vec4(0.48, 0.68, 0.80, 1.0);
uniform float light_level : hint_range(0.0, 1.0) = 1.0;
uniform vec3 water_plane_point = vec3(0.0, 1.275, 0.0);
uniform vec3 water_plane_normal = vec3(0.0, 1.0, 0.0);
uniform float max_water_thickness = 20.0;
uniform float distortion_strength = 0.0015;
uniform float wave_frequency = 34.0;
uniform float wave_speed = 1.4;

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	vec2 ripple = vec2(
		sin(SCREEN_UV.y * wave_frequency + TIME * wave_speed),
		cos(SCREEN_UV.x * wave_frequency * 0.8 - TIME * wave_speed)
	) * distortion_strength;
	vec2 sample_uv = SCREEN_UV + ripple;
	vec3 scene_color = texture(screen_texture, sample_uv).rgb;
	float raw_depth = texture(depth_texture, sample_uv).r;

	vec3 camera_world = (INV_VIEW_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
	vec3 plane_normal = normalize(water_plane_normal);
	float camera_side = dot(camera_world - water_plane_point, plane_normal);
	vec3 ndc = vec3(sample_uv * 2.0 - 1.0, max(raw_depth, 0.000001));
	vec4 scene_view_h = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	vec3 view_ray = normalize(scene_view_h.xyz);
	float scene_distance = max_water_thickness;
	if (raw_depth > 0.000001) {
		vec3 scene_view = scene_view_h.xyz / scene_view_h.w;
		scene_distance = length(scene_view);
		view_ray = normalize(scene_view);
	}
	vec3 ray_world = normalize((INV_VIEW_MATRIX * vec4(view_ray, 0.0)).xyz);
	float ray_plane_dot = dot(ray_world, plane_normal);
	float scene_side = camera_side + ray_plane_dot * scene_distance;
	bool camera_underwater = camera_side < 0.0;
	bool scene_underwater = scene_side < 0.0;
	bool crosses_surface = camera_underwater != scene_underwater;

	float distance_to_surface = scene_distance;
	if (abs(ray_plane_dot) > 0.0001) {
		distance_to_surface = clamp(-camera_side / ray_plane_dot, 0.0, scene_distance);
	}

	float water_thickness = 0.0;
	if (camera_underwater && scene_underwater) {
		water_thickness = scene_distance;
	} else if (crosses_surface) {
		water_thickness = camera_underwater
			? distance_to_surface
			: scene_distance - distance_to_surface;
	}
	water_thickness = min(water_thickness, max_water_thickness);
	vec3 transmittance = exp(-extinction_coefficients * water_thickness);
	vec3 in_scattering = scattering_color * light_level * (vec3(1.0) - transmittance);
	vec3 water_color = scene_color * transmittance + in_scattering;

	if (crosses_surface) {
		float cosine = clamp(abs(ray_plane_dot), 0.0, 1.0);
		float fresnel = 0.02 + 0.98 * pow(1.0 - cosine, 5.0);
		water_color = mix(water_color, reflection_color.rgb * light_level, fresnel);
	}

	ALBEDO = water_color;
	ALPHA = 1.0;
}