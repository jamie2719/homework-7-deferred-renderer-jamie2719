#version 300 es
precision highp float;

#define EPS 0.0001
#define PI 3.1415962

in vec2 fs_UV;
out vec4 out_Col;

uniform sampler2D u_gb0;
uniform sampler2D u_gb1;
uniform sampler2D u_gb2;

uniform float u_Time;

uniform mat4 u_View;
uniform vec4 u_CamPos;   


void main() { 
	// read from GBuffers

	vec4 gb2 = texture(u_gb2, fs_UV);
	vec4 gb0 = texture(u_gb0, fs_UV);

	 // Calculate the diffuse term for Lambert shading
	vec3 lightPos = vec3(5, 5, 0);  // Compute the direction in which the light source lies

    float diffuseTerm = dot(normalize(gb0.xyz), normalize(lightPos));
    // Avoid negative lighting values
    diffuseTerm = clamp(diffuseTerm, 0.0, 1.0);

	float ambientTerm = 0.2;

    float lightIntensity = diffuseTerm + ambientTerm;

	vec3 col = gb2.xyz;

	// Compute final shaded color
    out_Col = vec4(col * lightIntensity, 1.0);

	



   

      //Add a small float value to the color multiplier
                                                        //to simulate ambient lighting. This ensures that faces that are not
                                                        //lit by our point light are not completely black.


}