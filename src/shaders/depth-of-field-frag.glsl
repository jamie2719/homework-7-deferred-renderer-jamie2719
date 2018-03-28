#version 300 es
precision highp float;

in vec2 fs_UV;
out vec4 out_Col;

uniform sampler2D u_frame;
uniform sampler2D u_depth;
uniform float u_Time;

void main()
{
//     float x = gl_FragCoord.x;
//     float y = gl_FragCoord.y;


    float kernelSize = 11.0;
    float kernel[] = float[](0.006849,	0.007239,	0.007559,	0.007795,	0.007941,	 0.00799,	0.007941,	0.007795,	0.007559,	0.007239,	0.006849,
			0.007239,	0.007653,	 0.00799,	 0.00824,	0.008394,	0.008446,	0.008394,	 0.00824,	 0.00799,	0.007653,	0.007239,
			0.007559,	 0.00799,	0.008342,	0.008604,	0.008764,	0.008819,	0.008764,	0.008604,	0.008342,	 0.00799,	0.007559,
			0.007795,	 0.00824,	0.008604,	0.008873,	0.009039,	0.009095,	0.009039,	0.008873,	0.008604,	 0.00824,	0.007795,
			0.007941,	0.008394,        0.008764,	0.009039,	0.009208,	0.009265,	0.009208,	0.009039,	0.008764,	0.008394,	0.007941,
			0.00799,        0.008446,        0.008819,	0.009095,	0.009265,	0.009322,	0.009265,	0.009095,	0.008819,	0.008446,	 0.00799,
			0.007941,	0.008394,        0.008764,	0.009039,	0.009208,	0.009265,	0.009208,	0.009039,	0.008764,	0.008394,	0.007941,
			0.007795,	 0.00824,	0.008604,	0.008873,	0.009039,	0.009095,	0.009039,	0.008873,	0.008604,	 0.00824,	0.007795,
			0.007559,	 0.00799,	0.008342,	0.008604,	0.008764,	0.008819,	0.008764,	0.008604,	0.008342,	 0.00799,	0.007559,
			0.007239,	0.007653,	 0.00799,	 0.00824,	0.008394,	0.008446,	0.008394,	 0.00824,	 0.00799,	0.007653,	0.007239,
			0.006849,	0.007239,	0.007559,	0.007795,	0.007941,	 0.00799,	0.007941,	0.007795,	0.007559,	0.007239,	0.006849);

    float sumR = 0.0;
    float sumG = 0.0;
    float sumB = 0.0;
    float x = fs_UV.x;
    float y = fs_UV.y;
    for(float row =  -kernelSize/2.0; row <= kernelSize/2.0; row++) {
        for(float col = -kernelSize/2.0; col <= kernelSize/2.0; col++) {
            float epsilon = .001;
            int index = int((col + kernelSize/2.0) + kernelSize * (row + kernelSize/2.0));
            float rowUV = y+row * epsilon;
            float colUV = x+col * epsilon;
            vec4 diffuseColor =  kernel[index] * texture(u_frame, vec2(colUV, rowUV));
            sumR += diffuseColor[0];
            sumG += diffuseColor[1];
            sumB += diffuseColor[2];
        }
    }
    
    vec4 unblurred = texture(u_frame, fs_UV);

    float currDepth = texture(u_depth, fs_UV).w;

    //if far enough away from camera, blur
    if(currDepth > .99) {
        out_Col = vec4(sumR, sumG, sumB, 1.0);
    }
    //if close enough to camera, keep clear
    else {
        out_Col = unblurred;
    }

    // out_Col = mix(texture(u_frame, fs_UV), vec4(sumR, sumG, sumB, 1.0), currDepth / 5.0);
    //out_Col = vec4(vec3(texture(u_depth, fs_UV).w), 1);

}
