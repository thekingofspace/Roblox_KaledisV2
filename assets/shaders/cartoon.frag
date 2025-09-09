
#ifdef GL_ES
precision mediump float;
#endif

uniform vec3 cubeColor;
uniform Image tex;

vec4 effect(vec4 color, Image tex, vec2 texcoord, vec2 screenpos)
{
    vec4 texColor = Texel(tex, texcoord);

    return vec4(texColor.rgb * cubeColor, 1.0);
}
