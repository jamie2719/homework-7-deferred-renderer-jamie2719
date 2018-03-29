#version 300 es
precision highp float;

uniform mat4 u_Model;
uniform mat4 u_ModelPrev;
uniform mat4 u_ModelInvTr;  

uniform mat4 u_View;   
uniform mat4 u_Proj; 
uniform mat4 u_ProjPrev;
uniform mat4 u_ViewPrev;
uniform float u_Time;

in vec4 vs_Pos;
in vec4 vs_Nor;
in vec4 vs_Col;
in vec2 vs_UV;

out vec4 fs_Pos;
out vec4 fs_PosCurr;
out vec4 fs_PosPrev;
out vec4 fs_Nor;            
out vec4 fs_Col;           
out vec2 fs_UV;
out float depth;

void main()
{
    fs_Col = vs_Col;
    fs_UV = vs_UV;
    fs_UV.y = 1.0 - fs_UV.y;

    vec4 transformedPos = vec4(vs_Pos.x + 4.0 * cos(u_Time), vs_Pos.y + 1.2 * sin(u_Time), vs_Pos.z, 1);



    // fragment info is in view space
    mat3 invTranspose = mat3(u_ModelInvTr);
    mat3 view = mat3(u_View);
    fs_Nor = vec4(view * invTranspose * vec3(vs_Nor), 0);
    vec4 temp = u_View * u_Model * transformedPos;
    vec4 tempPrev = u_ViewPrev * u_ModelPrev * transformedPos;
    fs_Pos = temp;

    temp = u_Proj * temp;
    fs_PosCurr = temp;
    tempPrev = u_ProjPrev * temp;
    fs_PosPrev = tempPrev;
    depth = temp.z / temp.w;

    //


    
    gl_Position = u_Proj * u_View * u_Model * transformedPos;
}
