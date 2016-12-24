
//"in" attributes from our SpriteBatch
attribute vec4 a_color;
attribute vec2 a_texCoord0;
attribute vec2 a_position;

//combined projection and view matrix
uniform mat4 u_projTrans;

//"out" varyings to our fragment shader
varying vec4 vColor;
varying vec2 vTexCoord;
 
void main() {
	vColor = a_color;
	vTexCoord = a_texCoord0;
	gl_Position = u_projTrans * vec4(a_position, 0.0, 1.0);
}
