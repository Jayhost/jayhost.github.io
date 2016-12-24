#ifdef GL_ES
#define LOWP lowp
precision mediump float;
#else
#define LOWP
#endif

//attributes from vertex shader
varying LOWP vec4 vColor;
varying vec2 vTexCoord;

//our texture samplers
uniform sampler2D u_texture;   //diffuse map
uniform sampler2D u_normals;   //normal map

//values used for shading algorithm...
uniform vec2 Resolution;      //resolution of screen
uniform vec3 LightPos;        //light position, normalized
uniform LOWP vec4 LightColor;      //light RGBA -- alpha is intensity
uniform LOWP vec4 AmbientColor;    //ambient RGBA -- alpha is intensity 
uniform vec3 Falloff;         //attenuation coefficients

void main() {
	//RGBA of our diffuse color
    	vec3 Sum = vec3(0.0);

	vec4 DiffuseColor = texture2D(u_texture, vTexCoord);
	//vec4 aColor = texture2D(u_normals, vTexCoord);
	//vec4 DiffuseColor = normalize(vec4(aColor.rgb,aColor.a) *2.0 -1.0);
	
	//RGB of our normal map
	vec3 NormalMap = texture2D(u_normals, vTexCoord).rgb;
	//vec3 NormalMap = texture2D(u_normals, vec2(0.9,0.9).rgb;
	//vec4 NormalMap = texture2D(u_texture, vec2(1.0,1.0);
	//vec3 NormalMap = vec3(0.1,0.1,0.1);
	float ExtraPos = 0.0;
	//	    ColorChange = vec3(0.5,0.0,0.9);
	vec3 ColorChange = vec3(0.5,0.0,0.0);
	for (int i = 0; i <= 2; i++){	//jaytest take out for loop for debug
	//The delta position of light
	vec3 LightDir = vec3(LightPos.xy - (gl_FragCoord.xy / Resolution.xy), LightPos.z);//jaytest
	    //vec3 LightDir = vec3(0.4);
	    LightDir.x += ExtraPos;
	  //Correct for aspect ratio
	    LightDir.x *= Resolution.x / Resolution.y;//this probably not coming through jaytest
	
	//Determine distance (used for attenuation) BEFORE we normalize our LightDir
	    float D = length(LightDir);//testing jay light here

	//normalize our vectors // start for loop

	    vec3 N = normalize(NormalMap * 2.0 - 1.0);
	    //vec3 N = normalize(NormalMap * 2.0 - 1.0) * vec3(0.0,(i+1*1),0.0);
	    //vec3 N = normalize(NormalMap * 2.0 - 1.0) * vec3((i+1*1),0.0,0.0);
	    vec3 L = normalize(LightDir);
	    //vec3 L = normalize(LightDir) * vec3(0.0,0.0,(i+1));
	    
	    //Pre-multiply light color with intensity
	    //Then perform "N dot L" to determine our diffuse term
	    //vec3 Diffuse = ((LightColor.rgb + ColorChange.rgb) * LightColor.a) * max(dot(N * 3.0, L), 0.0);
	    vec3 Diffuse = ((LightColor.rgb + ColorChange.rgb) * LightColor.a) * max(dot(N, L), 0.0);
	    //vec3 Diffuse = (LightColor.rgb * LightColor.a) * 
	    
	    //pre-multiply ambient color with intensity
	    vec3 Ambient = AmbientColor.rgb * AmbientColor.a;
	    
	    //calculate attenuation
	    float Attenuation = 1.0 / ( Falloff.x + (Falloff.y*D) + (Falloff.z*D*D) );
	    
	    //the calculation which brings it all together
	    vec3 Intensity = Ambient + Diffuse * Attenuation;
	    vec3 FinalColor = DiffuseColor.rgb * Intensity;
	    ExtraPos += 0.4;
	    //int i = 0;//jaytest
	    if (i == 0){
		//ColorChange = vec3(0.5,0.0,-0.9);
		ColorChange = vec3(0.5,0.3,0.9);
	    }else if (i == 1){
		ColorChange = vec3(0.5,0.0,0.9);
	    }else{
		//ColorChange = vec3(0.2,1.0,0.4);
		ColorChange = vec3(0.5,0.0,0.9);
	    }
	    Sum += FinalColor;
	}//jaytest take out forloop
	    vec4 finally = vColor * vec4(Sum, DiffuseColor.a);
	    //gl_FragColor = vec4(AmbientColor.rgb,1.0);
	    //gl_FragColor = vec4(AmbientColor.rgb * AmbientColor.a + FinalColor,1.0);
	gl_FragColor = finally - 0.2;
	//gl_FragColor = vec4(1.0);
	
	//gl_FragColor = vec4(Sum,1.0);
	    //vec3 N = normalize(NormalMap * 2.0 - 1.0);
	//gl_FragColor = vec4(DiffuseColor.rgb + (N / 12.0),0.0);
	//gl_FragColor = DiffuseColor;
	//gl_FragColor = vec4(0.5,0.5,0.5,1.0);
	    
	   

	//gl_FragColor.rgb = Ambient.rgb;
	//gl_FragColor.a = 1.0;
	
	//gl_FragColor = vec4(N,0.5);
	//gl_FragColor = 1.0 * vec4(FinalColor, DiffuseColor.a);
	//gl_FragColor = 1.0 * vec4(N,N,N, DiffuseColor.a); no       
	//gl_FragColor = 1.0 * vec4(N,N,N,N); no
}
