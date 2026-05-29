shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_opaque, blend_mix;

uniform sampler2D noise_texture : hint_default_white;
uniform vec4 color_bottom : source_color = vec4(1.0, 0.2, 0.0, 1.0);
uniform vec4 color_top : source_color = vec4(1.0, 0.8, 0.0, 0.0);
uniform float flame_speed : hint_range(0.1, 5.0) = 2.0;
uniform float flame_distortion : hint_range(0.0, 1.0) = 0.3;
uniform float flame_height : hint_range(0.1, 2.0) = 1.0;

void fragment() {
	vec2 uv = UV;
	
	// animate upward scroll
	float time_offset = TIME * flame_speed;
	
	// sample noise twice at different scales for turbulence
	vec2 noise_uv1 = uv + vec2(0.0, -time_offset * 0.5);
	vec2 noise_uv2 = uv * 2.0 + vec2(0.1, -time_offset * 0.8);
	float noise1 = texture(noise_texture, noise_uv1).r;
	float noise2 = texture(noise_texture, noise_uv2).r;
	float noise = (noise1 + noise2) * 0.5;
	
	// distort UVs horizontally based on noise
	uv.x += (noise - 0.5) * flame_distortion;
	
	// flame shape — wide at bottom narrow at top
	float flame_shape = 1.0 - uv.y;
	flame_shape = pow(flame_shape, 0.5);
	
	// edge fade — narrow the flame horizontally toward top
	float edge_fade = 1.0 - abs(uv.x - 0.5) * 2.0;
	edge_fade = pow(max(edge_fade, 0.0), 1.0 + uv.y * 2.0);
	
	// combine for final alpha
	float alpha = flame_shape * edge_fade * noise * flame_height;
	alpha = clamp(alpha, 0.0, 1.0);
	
	// color gradient bottom to top
	vec4 color = mix(color_bottom, color_top, uv.y);
	
	ALBEDO = color.rgb;
	ALPHA = alpha;
	EMISSION = color.rgb * alpha * 2.0;
}