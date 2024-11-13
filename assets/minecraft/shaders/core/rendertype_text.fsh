#version 150
<<<<<<< HEAD:main/assets/minecraft/shaders/core/rendertype_text.fsh
#moj_import<fog.glsl>
=======

#moj_import <fog.glsl>
>>>>>>> 1.21.1:assets/minecraft/shaders/core/rendertype_text.fsh

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
<<<<<<< HEAD:main/assets/minecraft/shaders/core/rendertype_text.fsh
uniform float FogStart,FogEnd;
uniform vec4 FogColor;

in float vertexDistance;
flat in vec4 vertexColor;
in vec2 texCoord0;
out vec4 fragColor;

void main() {
    vec4 v=texture(Sampler0,texCoord0)*vertexColor*ColorModulator;
    if(v.a<.1){
        discard;
    }
    fragColor=linear_fog(v,vertexDistance,FogStart,FogEnd,FogColor);
}
=======
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

in float vertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;

out vec4 fragColor;

void main() {
    vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;
    if (color.a < 0.1) {
        discard;
    }
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}
>>>>>>> 1.21.1:assets/minecraft/shaders/core/rendertype_text.fsh
