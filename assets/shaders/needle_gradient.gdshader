shader_type spatial;
render_mode unshaded, cull_disabled;

uniform vec4 color_top : source_color = vec4(1.0, 0.0, 0.0, 1.0);   // red - north
uniform vec4 color_bottom : source_color = vec4(0.0, 0.0, 1.0, 1.0); // blue - south

void fragment() {
    // UV.y goes 0 (bottom) to 1 (top)
    ALBEDO = mix(color_bottom.rgb, color_top.rgb, UV.y);
}