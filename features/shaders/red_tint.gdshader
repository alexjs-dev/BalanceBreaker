shader_type canvas_item;

uniform float tint_strength : hint_range(0.0, 1.0) = 0.5;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	vec3 purple_tint = vec3(0.6, 0.0, 1.0); // R, G, B for purple
	tex_color.rgb = mix(tex_color.rgb, purple_tint, tint_strength);
	COLOR = tex_color * tex_color.a;
}
