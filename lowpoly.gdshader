shader_type spatial;

uniform vec4 color;
uniform sampler2D tex;
uniform float height_range = 0;

void vertex() {
	// Called for every vertex the material is visible on.
	VERTEX = vec3(VERTEX.x, texture(tex, UV).g * float(height_range), VERTEX.z);
}

void fragment() {
	// Called for every pixel the material is visible on.
	NORMAL = vec3(5, 1, 1) * normalize(cross(dFdx(VERTEX), dFdy(VERTEX)));
	// green color
	vec3 material_color = color.rgb;
	ALBEDO = material_color;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
