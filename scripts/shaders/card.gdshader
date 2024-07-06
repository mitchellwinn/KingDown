shader_type spatial;
//render_mode unshaded;

uniform sampler2D sprite_normal : filter_nearest, hint_normal;
uniform sampler2D sprite : filter_nearest, source_color;
uniform sampler2D screen : hint_screen_texture;

void vertex() {

}

void fragment() {
	vec4 sprite_tex = texture(sprite, UV);
	vec4 normal_tex = texture(sprite_normal, UV);
	vec4 mixed_color = mix(sprite_tex, normal_tex, 0.1);
	NORMAL_MAP = (normal_tex.xyz * 0.5);
	NORMAL_MAP_DEPTH = 0.25;
	ALBEDO = mixed_color.rgb;
	ALPHA = sprite_tex.a;
	METALLIC = 1.0;
	ROUGHNESS = 0.2;

}

//void light() {
//
//}
