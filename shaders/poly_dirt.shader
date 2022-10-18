shader_type spatial;

uniform vec4 out_color : hint_color = vec4(0.0, 0.2, 1.0, 1.0);
uniform float metallic : hint_range(0.2,2.0) = 0.0;
uniform float specular : hint_range(0,2.0) = 0;
uniform float roughness : hint_range(0,2.0) = 0.2;
uniform float amount : hint_range(0,2.0) = 0.8;


float generateOffset(float x, float z, float val1, float val2) {
	float speed = 1.0;
	float radiansX = ((mod(x + z * x * val1, amount) / amount) + (speed) * mod(x * 0.8 + z, 1.5)) * 2.0 * 3.14;
	float radiansZ = ((mod(val2 * (z * x + x * z), amount) / amount) + (speed) * 2.0 * mod(x, 2.0)) * 2.0 * 3.14;
	
	return amount * 0.5 * (sin(radiansZ) + cos(radiansX));
}

vec3 applyDistortion(vec3 vertex, float time){
	float xd = generateOffset(vertex.x, vertex.z, 0.1, 1);
	float yd = generateOffset(vertex.x, vertex.z, 0.1, 0.1);
	float zd = generateOffset(vertex.x, vertex.z, 0.1, 1);
	return vertex + vec3(xd, yd, zd);
}

void vertex(){
	VERTEX = applyDistortion(VERTEX, 0);
}

void fragment(){
	NORMAL = normalize(cross(dFdx(VERTEX), dFdy(VERTEX)));
	METALLIC = metallic;
	SPECULAR = specular;
	ROUGHNESS = roughness;
	ALBEDO = out_color.xyz;
}