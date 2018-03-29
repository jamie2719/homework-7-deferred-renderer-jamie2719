#version 300 es
precision highp float;

in vec4 fs_Pos;
in vec4 fs_Nor;
in vec4 fs_Col;
in vec2 fs_UV;
in float depth;
in vec4 fs_PosCurr;
in vec4 fs_PosPrev;

out vec4 fragColor[3]; // The data in the ith index of this array of outputs
                       // is passed to the ith index of OpenGLRenderer's
                       // gbTargets array, which is an array of textures.
                       // This lets us output different types of data,
                       // such as albedo, normal, and position, as
                       // separate images from a single render pass.


uniform sampler2D tex_Color;


void main() {
    vec4 a = (fs_PosCurr / fs_PosCurr.w) * 0.5 + 0.5;
    vec4 b = (fs_PosPrev / fs_PosPrev.w) * 0.5 + 0.5;
    vec4 currVelocity = a - b;


    // Presently, the provided shader passes "nothing" to the first
    // two gbuffers and basic color to the third.

    vec3 col = texture(tex_Color, fs_UV).rgb;

    // if using textures, inverse gamma correct
    col = pow(col, vec3(2.2));

   // float depth;

    fragColor[0] = vec4(vec3(fs_Nor), depth); //World-space surface normal of the fragment and camera space depth
    fragColor[1] = currVelocity; 
    fragColor[2] = vec4(col, 1.0); //albedo (base color) of the fragment
}
