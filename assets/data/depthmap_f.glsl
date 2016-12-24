#ifdef GL_ES
#define LOWP lowp
#define MED mediump
#define HIGH highp
precision mediump float;
#else
#define MED
#define LOWP
#define HIGH
#endif

uniform float u_cameraFar;

varying vec4 v_position;
uniform vec3 u_lightPosition;

void main()
{
	// Simple depth calculation, just the length of the vector light-current position
    gl_FragColor = vec4(length(v_position.xyz-u_lightPosition)/u_cameraFar);
    //gl_FragColor = vec4(1.0);
    //gl_FragColor = vec//vec4(length(v_position.xyz-u_lightPosition)/u_cameraFar);
        //vec4 finalColor;
    //float len = length(v_position.xyz-u_lightPosition)/u_cameraFar;
    //finalColor.rgb = vec3(1.0-len);
    //gl_FragColor = finalColor;    
    //gl_FragColor     = vec4(0.4);
	
}

