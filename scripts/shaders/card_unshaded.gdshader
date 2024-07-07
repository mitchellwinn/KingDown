shader_type spatial;
render_mode unshaded;

uniform sampler2D sprite : filter_nearest_mipmap, source_color;
uniform sampler2D alpha : filter_nearest_mipmap, source_color;
uniform sampler2D screen : hint_screen_texture;
uniform float alpha_scalar;

void vertex() {

}

void fragment() {
	vec4 sprite_tex = texture(sprite, UV);
	vec4 alpha_tex = texture(alpha, UV);
	
	ALBEDO = sprite_tex.rgb;
	ALPHA = alpha_tex.a*alpha_scalar;

}

//void light() {
//
//}
