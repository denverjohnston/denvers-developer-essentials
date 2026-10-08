shader_type sky;

uniform vec3 day_horizon: source_color = vec3(0.75, 0.82, 1.0);
uniform vec3 day_zenith: source_color = vec3(0.12, 0.35, 0.75);
uniform vec3 night_horizon: source_color = vec3(0.08, 0.11, 0.2);
uniform vec3 night_zenith: source_color = vec3(0.02, 0.04, 0.10);
uniform vec3 sunrise_horizon: source_color = vec3(0.92, 0.48, 0.5);
uniform vec3 sunrise_zenith: source_color = vec3(0.3, 0.48, 0.76);
uniform vec3 sunset_horizon: source_color = vec3(1.0, 0.28, 0.12);
uniform vec3 sunset_zenith: source_color = vec3(0.34, 0.16, 0.3);
uniform vec3 evening_horizon: source_color = vec3(0.08, 0.11, 0.26);
uniform vec3 evening_zenith: source_color = vec3(0.015, 0.025, 0.11);
uniform vec3 moon_color: source_color = vec3(0.72, 0.82, 1.0);
uniform float time_of_day: hint_range(0.0, 1.0) = 0.5;
uniform vec3 star_color: source_color = vec3(0.75, 0.82, 1.0);

void sky() {
	float horizon_blend = smoothstep(-0.7, 0.5, EYEDIR.y);
	float phase = fract(time_of_day);
	float sun_angle = 6.2831853 * (phase - 0.25);
	float sun_horizontal = cos(sun_angle);
	float sun_height = sin(sun_angle);
	vec3 sun_direction = vec3(
		0.0,
		sun_height,
		-sun_horizontal
	);
	float day_amount = smoothstep(-0.12, 0.1, sun_height);
	vec3 horizon_color;
	vec3 zenith_color;
	
	if (phase < 0.25) {
		horizon_color = night_horizon;
		zenith_color = night_zenith;
	} else if (phase < 0.27) {
		float blend = smoothstep(0.25, 0.27, phase);
		horizon_color = mix(night_horizon, sunrise_horizon, blend);
		zenith_color = mix(night_zenith, sunrise_zenith, blend);
	} else if (phase < 0.29) {
		horizon_color = sunrise_horizon;
		zenith_color = sunrise_zenith;
	} else if (phase < 0.33) {
		float blend = smoothstep(0.29, 0.33, phase);
		horizon_color = mix(sunrise_horizon, day_horizon, blend);
		zenith_color = mix(sunrise_zenith, day_zenith, blend);
	} else if (phase < 0.64) {
		horizon_color = day_horizon;
		zenith_color = day_zenith;
	} else if (phase < 0.72) {
		float blend = smoothstep(0.64, 0.72, phase);
		horizon_color = mix(day_horizon, sunset_horizon, blend);
		zenith_color = mix(day_zenith, sunset_zenith, blend);
	} else if (phase < 0.78) {
		horizon_color = sunset_horizon;
		zenith_color = sunset_zenith;
	} else if (phase < 0.82) {
		float blend = smoothstep(0.78, 0.82, phase);
		horizon_color = mix(sunset_horizon, evening_horizon, blend);
		zenith_color = mix(sunset_zenith, evening_zenith, blend);
	} else if (phase < 0.86) {
		horizon_color = evening_horizon;
		zenith_color = evening_zenith;
	} else if (phase < 0.9) {
		float blend = smoothstep(0.86, 0.9, phase);
		horizon_color = mix(evening_horizon, night_horizon, blend);
		zenith_color = mix(evening_zenith, night_zenith, blend);
	} else {
		horizon_color = night_horizon;
		zenith_color = night_zenith;
	}
	
	vec3 sky_color = mix(horizon_color, zenith_color, horizon_blend);
	float moon_visibility = 1.0;
	if (phase >= 0.22 && phase < 0.28) {
		moon_visibility = 1.0 - smoothstep(0.22, 0.28, phase);
	} else if (phase >= 0.28 && phase < 0.78) {
		moon_visibility = 0.0;
	} else if (phase >= 0.78 && phase < 0.84) {
		moon_visibility = smoothstep(0.78, 0.84, phase);
	}
	float sun_alignment = max(dot(normalize(EYEDIR), normalize(sun_direction)), 0.0);
	float sun_disc = smoothstep(0.9995, 0.9998, sun_alignment);
	float moon_alignment = max(dot(normalize(EYEDIR), -sun_direction), 0.0);
	float moon_disc = smoothstep(0.9999, 0.99998, moon_alignment);
	
	vec2 star_uv = vec2(
		atan(EYEDIR.z, EYEDIR.x) / 6.2831853 + 0.5,
		asin(clamp(EYEDIR.y, -1.0, 1.0)) / 3.14159265 + 0.5
	);
	vec2 star_grid = star_uv * vec2(256.0, 128.0);
	vec2 cell = floor(star_grid);
	vec2 local_pos = fract(star_grid);
	float seed = dot(cell, vec2(127.1, 311.7));
	float chance = fract(sin(seed) * 43758.5453);
	vec2 star_pos = fract(sin(vec2(seed + 1.0, seed + 2.0)) * 43758.5453);
	float radius = mix(0.012, 0.045, fract(sin(seed + 3.0) * 43758.5453));
	float stars = step(0.9, chance) * (1.0 - smoothstep(radius * 0.5, radius, length(local_pos - star_pos)));
	float night_amount = 1.0 - day_amount;
	
	COLOR = sky_color + sun_disc * day_amount + moon_color * moon_disc * moon_visibility + star_color * stars * night_amount;
}