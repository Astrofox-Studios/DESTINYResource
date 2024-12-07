#version 150

#moj_import <fog.glsl>

#moj_import <emissives_config_impl.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

in float vertexDistance;
in vec4 vertexColor;
in vec4 lightMapColor;
in vec4 overlayColor;
in vec2 texCoord0;

in vec4 normalLightValue;

out vec4 fragColor;

void main() {
    vec4 color = texture(Sampler0, texCoord0);
    if (color.a < 0.1) {
        discard;
    }
    color = applyLighting(getAlpha(color.a), mix(overlayColor, color * vertexColor, overlayColor.a), normalLightValue, lightMapColor);
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor) * ColorModulator;
}
