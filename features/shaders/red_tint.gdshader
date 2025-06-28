shader_type canvas_item;
render_mode blend_mix; // For Godot 4 – optional in 3.x

uniform float tint_strength : hint_range(0.0, 1.0) = 0.5;
uniform vec3 tint_color : source_color = vec3(0.6, 0.0, 1.0); // Purple

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	tex_color.rgb = mix(tex_color.rgb, tint_color, tint_strength);
	COLOR = vec4(tex_color.rgb, tex_color.a); // Preserve alpha
}
