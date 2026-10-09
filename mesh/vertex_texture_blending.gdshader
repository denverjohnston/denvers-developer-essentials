shader_type spatial;

uniform sampler2D tex_r : source_color, filter_linear_mipmap;
uniform sampler2D tex_g : source_color, filter_linear_mipmap;
uniform sampler2D tex_b : source_color, filter_linear_mipmap;
uniform float uv_scale = 6.0;

void fragment() {
	vec3 weights = COLOR.rgb;
	float total = weights.r + weights.g + weights.b;
	weights /= max(total, 0.0001); // Normalize weights, prevent division by 0
	vec3 albedo = texture(tex_r, UV * uv_scale).rgb * weights.r
				+ texture(tex_g, UV * uv_scale).rgb * weights.g
				+ texture(tex_b, UV * uv_scale).rgb * weights.b;
	ALBEDO = albedo;
}