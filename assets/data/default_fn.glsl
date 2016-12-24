#define positionFlag
#define colorFlag
#define normalFlag
#define lightingFlag
#define ambientCubemapFlag
#define numDirectionalLights 2
#define numPointLights 5
#define numSpotLights 0
#define texCoord0Flag
#define texCoord1Flag
#define diffuseColorFlag
#define specularColorFlag
#define emissiveColorFlag
#define shininessFlag


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

#if defined(specularTextureFlag) || defined(specularColorFlag)
#define specularFlag
#endif

#ifdef normalFlag
varying vec3 v_normal;
#endif //normalFlag

//my stuff
uniform float u_cameraFar;
uniform vec3 u_lightPosition;

uniform sampler2D u_depthMap;
uniform sampler2D u_normals;
uniform sampler2D u_randNormals;
varying vec2 v_texCoords0;
varying float v_intensity;
varying vec4 v_positionLightTrans;
uniform mat4 u_projViewTrans;
varying vec4 v_position;
//varying vec3 v_normal;


#if defined(colorFlag)
varying vec4 v_color;
#endif

#ifdef blendedFlag
varying float v_opacity;
#ifdef alphaTestFlag
varying float v_alphaTest;
#endif //alphaTestFlag
#endif //blendedFlag

#if defined(diffuseTextureFlag) || defined(specularTextureFlag)
#define textureFlag
#endif

#ifdef diffuseTextureFlag
varying MED vec2 v_diffuseUV;
#endif

#ifdef specularTextureFlag
varying MED vec2 v_specularUV;
#endif

#ifdef diffuseColorFlag
uniform vec4 u_diffuseColor;
#endif

#ifdef diffuseTextureFlag
uniform sampler2D u_diffuseTexture;
#endif

#ifdef specularColorFlag
uniform vec4 u_specularColor;
#endif

#ifdef specularTextureFlag
uniform sampler2D u_specularTexture;
#endif

#ifdef normalTextureFlag
uniform sampler2D u_normalTexture;
#endif

#ifdef lightingFlag
varying vec3 v_lightDiffuse;

#if	defined(ambientLightFlag) || defined(ambientCubemapFlag) || defined(sphericalHarmonicsFlag)
#define ambientFlag
#endif //ambientFlag

#ifdef specularFlag
varying vec3 v_lightSpecular;
#endif //specularFlag

#ifdef shadowMapFlag
uniform sampler2D u_shadowTexture;

uniform float u_shadowPCFOffset;
varying vec3 v_shadowMapUv;
#define separateAmbientFlag



float getShadowness(vec2 offset)
{
    const vec4 bitShifts = vec4(1.0, 1.0 / 255.0, 1.0 / 65025.0, 1.0 / 16581375.0);
    return step(v_shadowMapUv.z, dot(texture2D(u_shadowTexture, v_shadowMapUv.xy + offset), bitShifts));//+(1.0/255.0));
}

float getShadow()
{
	return (//getShadowness(vec2(0,0)) +
			getShadowness(vec2(u_shadowPCFOffset, u_shadowPCFOffset)) +
			getShadowness(vec2(-u_shadowPCFOffset, u_shadowPCFOffset)) +
			getShadowness(vec2(u_shadowPCFOffset, -u_shadowPCFOffset)) +
			getShadowness(vec2(-u_shadowPCFOffset, -u_shadowPCFOffset))) * 0.25;
}
#endif //shadowMapFlag

#if defined(ambientFlag) && defined(separateAmbientFlag)
varying vec3 v_ambientLight;
#endif //separateAmbientFlag

#endif //lightingFlag

#ifdef fogFlag
uniform vec4 u_fogColor;
varying float v_fog;
#endif // fogFlag

vec4 getPosition(in vec2 uv)
    {
	float z = texture2D(u_depthMap, uv).a; //v_texCoords0
	//blue tint float z = texture2D(u_depthMap, depth.xy).a;
	float x = uv.x * 2.0 - 1.0;
	float y = (1.0 - uv.y) * 2.0 - 1.0;
	vec4 position = vec4(x,y,z,1.0);// * inverse(u_projViewTrans);
	return position;
    }

vec3 getNorm(in vec2 uv)
{
    return v_normal;
    //return normalize(texture2D(u_normals, uv).xyz * 2.0 - 1.0);
}

vec2 getRandom(in vec2 uv)
{
    return normalize(texture2D(u_randNormals, 1280.0 * uv / 64.0).xy * 2.0 - 1.0);
}


float doAmbientOcclusion(in vec2 tcoord,in vec2 uv, in vec3 p, in vec3 cnorm)
{
    vec3 diff = getPosition(tcoord + uv).xyz - p;
    vec3 v = normalize(diff);
    float d = length(diff)* 0.1;//g_scale;
    //return max(0.0,dot(cnorm,v)- 0.5) * (0.5 / (0.5 + d));
    return max(0.0,dot(cnorm,v) + 0.0) * (1.0 / (1.0 + d));
    //return max(0.0,dot(cnorm,v)- 1.0)*(1.0/(1.0+d))* 1.0;//g_bias first then at end g_intensity;
}

void main() {

    vec3 p = getPosition(v_texCoords0).xyz;
    vec3 n = getNorm(v_texCoords0).xyz;
    vec2 rand = getRandom(v_texCoords0);
    float ao = 0.0;
    float rad = 0.9/p.z;//g_sample_rad/p.z;

    int iterations = 4;
    for (int j = 0; j < iterations; ++j)
    	{
    vec2 coord1 = reflect(vec2(j,j),rand)*rad;
    vec2 coord2 = vec2(coord1.x*0.707 - coord1.y*0.707,
    coord1.x*0.707 + coord1.y*0.707);

    ao += doAmbientOcclusion(v_texCoords0,coord1*0.25, p, n);
    ao += doAmbientOcclusion(v_texCoords0,coord2*0.5, p, n);
    ao += doAmbientOcclusion(v_texCoords0,coord1*0.75, p, n);
    ao += doAmbientOcclusion(v_texCoords0,coord2, p, n);
    }
    ao /= float(iterations)*4.0;
    //**END**//



	#if defined(normalFlag)
		vec3 normal = v_normal;
	#endif // normalFlag

	#if defined(diffuseTextureFlag) && defined(diffuseColorFlag) && defined(colorFlag)
		vec4 diffuse = texture2D(u_diffuseTexture, v_diffuseUV) * u_diffuseColor * v_color;
	#elif defined(diffuseTextureFlag) && defined(diffuseColorFlag)
		vec4 diffuse = texture2D(u_diffuseTexture, v_diffuseUV) * u_diffuseColor;
	#elif defined(diffuseTextureFlag) && defined(colorFlag)
		vec4 diffuse = texture2D(u_diffuseTexture, v_diffuseUV) * v_color;
	#elif defined(diffuseTextureFlag)
		vec4 diffuse = texture2D(u_diffuseTexture, v_diffuseUV);
	#elif defined(diffuseColorFlag) && defined(colorFlag)
	        vec4 diffuse = u_diffuseColor * v_color;
	#elif defined(diffuseColorFlag)
		vec4 diffuse = u_diffuseColor;
	#elif defined(colorFlag)
		vec4 diffuse = v_color;
	#else
		vec4 diffuse = vec4(1.0);
	#endif

	#if (!defined(lightingFlag))
		finalColor.rgb = diffuse.rgb;
	#elif (!defined(specularFlag))
		#if defined(ambientFlag) && defined(separateAmbientFlag)
			#ifdef shadowMapFlag
				finalColor.rgb = (diffuse.rgb * (v_ambientLight + getShadow() * v_lightDiffuse));
				//finalColor.rgb = texture2D(u_shadowTexture, v_shadowMapUv.xy);
			#else
				finalColor.rgb = (diffuse.rgb * (v_ambientLight + v_lightDiffuse));
			#endif //shadowMapFlag
		#else
			#ifdef shadowMapFlag
				finalColor.rgb = getShadow() * (diffuse.rgb * v_lightDiffuse);
			#else
				finalColor.rgb = (diffuse.rgb * v_lightDiffuse);
			#endif //shadowMapFlag
		#endif
	#else
		#if defined(specularTextureFlag) && defined(specularColorFlag)
			vec3 specular = texture2D(u_specularTexture, v_specularUV).rgb * u_specularColor.rgb * v_lightSpecular;
		#elif defined(specularTextureFlag)
			vec3 specular = texture2D(u_specularTexture, v_specularUV).rgb * v_lightSpecular;
		#elif defined(specularColorFlag)
			vec3 specular = u_specularColor.rgb * v_lightSpecular;
		#else
			vec3 specular = v_lightSpecular;
		#endif

		#if defined(ambientFlag) && defined(separateAmbientFlag)
			#ifdef shadowMapFlag
			finalColor.rgb = (diffuse.rgb * (getShadow() * v_lightDiffuse + v_ambientLight)) + specular;
				//finalColor.rgb = texture2D(u_shadowTexture, v_shadowMapUv.xy);
			#else
				finalColor.rgb = (diffuse.rgb * (v_lightDiffuse + v_ambientLight)) + specular;
			#endif //shadowMapFlag
		#else
			#ifdef shadowMapFlag
				finalColor.rgb = getShadow() * ((diffuse.rgb * v_lightDiffuse) + specular);
			#else
				finalColor.rgb = (diffuse.rgb * v_lightDiffuse) + specular;
			#endif //shadowMapFlag
		#endif
	#endif //lightingFlag

	#ifdef fogFlag
		finalColor.rgb = mix(finalColor.rgb, u_fogColor.rgb, v_fog);
	#endif // end fogFlag

	#ifdef blendedFlag
		finalColor.a = diffuse.a * v_opacity;
		#ifdef alphaTestFlag
			if (finalColor.a <= v_alphaTest)
				discard;
		#endif
	#else
		finalColor.a = 1.0;
	#endif

	vec4 finalColor;
	float len = length(v_position.xyz-u_lightPosition)/u_cameraFar;
	finalColor.rgb = diffuse.rgb + vec3(1.0 - len) + ao;
	finalColor.rgb = finalColor.rgb;


}
