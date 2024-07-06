shader_type spatial;
//render_mode unshaded;

uniform sampler2D sprite : filter_nearest, source_color;
uniform sampler2D screen : hint_screen_texture;

void vertex() {

}

void fragment() {
	vec4 sprite_tex = texture(sprite, UV);
	ALBEDO = sprite_tex.rgb;
}

//void light() {
//
//}
