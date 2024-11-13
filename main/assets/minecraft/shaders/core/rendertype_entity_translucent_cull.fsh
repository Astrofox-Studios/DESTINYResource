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
in vec2 texCoord0;
in vec2 texCoord1;

in vec4 lightMapValue;
in vec4 normalLightValue;

flat in int hideVertex;

out vec4 fragColor;

void main() {
    vec4 color = texture(Sampler0, texCoord0);

    // If hideVertex equal to 1 (true).
    // If vertextDistance is more than 800 it's a UI item.
    if(hideVertex == 1 && vertexDistance <= 800) {
        float alpha = textureLod(Sampler0, texCoord0, 0.0).a;
        
        // Discard if the alpha of the pixel is of value of 254, 251, 250, 201, 181, 180, 141, 140, 101, 100.
        // 254, 201, 101 are normal.
        // 251 is for emissive.
        if(alpha == 254.0 / 255.0 || alpha == 251.0 / 255.0 || alpha == 250.0 / 255.0 || alpha == 201.0 / 255.0 || alpha == 181.0 / 255.0 || alpha == 180.0 / 255.0 || alpha == 141.0 / 255.0 || alpha == 140.0 / 255.0 || alpha == 101.0 / 255.0 || alpha == 100.0 / 255.0) {
            discard;
        }
    }

    color = applyLighting(getAlpha(color.a), color * vertexColor, normalLightValue, lightMapValue);
    if (color.a < 0.1) {
        discard;
    }
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor) * ColorModulator;
}
