shader_type spatial;

render_mode unshaded, cull_front, depth_draw_never, skip_vertex_transform;

#include "usky_standard_atmosphere.gdshaderinc"

varying vec3 v_world_pos;

void vertex(){
	vec4 vert =  vec4(VERTEX.xyz, 0.0);
	VERTEX = (MODELVIEW_MATRIX * vert).xyz;
	POSITION = PROJECTION_MATRIX * MODELVIEW_MATRIX * vert;
	POSITION.z = 0.0;

	v_world_pos = (MODEL_MATRIX * vert).xyz;
}

void fragment(){
	vec3 worldPos = normalize(v_world_pos);

	vec3 horizonBlend = mix(vec3(0.0), vec3(1.0),
		smoothstep(-0.1, 1.0, dot(vec3(0.0, 1.0, 0.0),
	worldPos + vec3(0.0, horizon_level, 0.0))*10.0));

	vec3 scatter = atmosphericScattering(worldPos, horizonBlend);

	ALBEDO =scatter;
}