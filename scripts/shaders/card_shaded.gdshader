shader_type spatial;
//render_mode unshaded;

uniform sampler2D sprite_normal : filter_linear_mipmap, hint_normal;
uniform sampler2D sprite : filter_nearest_mipmap, source_color;
uniform sampler2D alpha : filter_nearest_mipmap, source_color;
uniform sampler2D screen : hint_screen_texture;
uniform float Shift_Hue;
uniform float roughness;
uniform float alpha_scalar;

void vertex() {

}

void fragment() {
	vec4 sprite_tex = texture(sprite, UV);
	vec4 alpha_tex = texture(alpha, UV);
	vec4 normal_tex = texture(sprite_normal, UV);
	vec3 input_color = sprite_tex.rgb;
	
// VectorFunc:2
	vec3 color_hsv;
	{
		vec3 c = input_color;
		vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
		vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
		vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
		float d = q.x - min(q.w, q.y);
		float e = 1.0e-10;
		color_hsv=vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
	}

	color_hsv.x = mod((color_hsv.x + Shift_Hue + (NORMAL.r+normal_tex.b)*2.3), 1.0f);

// VectorFunc:5
	vec3 color_rgb;
	{
		vec3 c = color_hsv;
		vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
		vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
		color_rgb=c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
	}	
	
	NORMAL_MAP = (normal_tex.xyz);
	NORMAL_MAP_DEPTH = .250;
	ALBEDO = color_rgb;
	ALPHA = alpha_tex.a*alpha_scalar;
	METALLIC = 1.0;
	ROUGHNESS = roughness;

}

//void light() {
//
//}
