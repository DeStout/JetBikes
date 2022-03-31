/*
	放射状ブラーエフェクト by あるる（きのもと　結衣） @arlez80
	Radial Blur Effect by Yui Kinomoto

	MIT License
*/
shader_type spatial;
//render_mode unshaded;

varying mat4 CAMERA;


// 発射中央部
uniform vec2 blur_center = vec2( 0.5, 0.5 );
// ブラー強度
uniform float blur_power : hint_range( 0.0, 1.0 ) = 0.01;
// サンプリング回数
uniform int sampling_count : hint_range( 1, 64 ) = 6;

void vertex () {
	POSITION = vec4(VERTEX, 1.0);
	
	CAMERA = CAMERA_MATRIX;
}

void fragment()
{
	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).x;
	vec3 ndc = vec3(SCREEN_UV, depth) * 2.0 - 1.0;
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
//	vec4 view = vec4(ndc, 1.0);
	view.xyz /= view.w;
	float linear_depth = -view.z;
	vec4 world = CAMERA * INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
//	vec4 world = CAMERA * vec4(ndc, 1.0);
	vec3 world_position = world.xyz / world.w;
	
	ALBEDO = world_position;
	
	
	
//	vec2 direction = SCREEN_UV - blur_center;
//	vec3 c = vec3( 0.0, 0.0, 0.0 );
//	float f = 1.0 / float( sampling_count );
//
//	for( int i=0; i < sampling_count; i++ ) {
//		c += texture( SCREEN_TEXTURE, SCREEN_UV - blur_power * direction * float(i) ).rgb * f;
//	}
//	ALBEDO = c;
}