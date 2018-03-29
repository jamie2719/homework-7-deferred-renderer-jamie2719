#version 300 es
precision highp float;

in vec2 fs_UV;
in vec4 fs_Pos;
out vec4 out_Col;

uniform sampler2D u_frame;
uniform sampler2D u_depth;
uniform sampler2D u_velocity;
uniform float u_Time;
uniform mat4 u_viewPrev;

void main()
{
    vec4 color = texture(u_frame, fs_UV);
    // out_Col = color;
    vec4 velocity = texture(u_velocity, fs_UV);
    velocity = normalize(velocity);
    vec2 currUV = fs_UV + velocity.xy * .005;
    float numSamples = 20.0;
    for(float i = 1.0; i < numSamples; i++, currUV += velocity.xy * .005) {
        // Sample the color buffer along the velocity vector.
        vec4 currColor = texture(u_frame, currUV);
        // Add the current color to our color sum.
        color += currColor;
    }
//Average all of the samples to get the final blur color.
  out_Col = color / numSamples;

}
