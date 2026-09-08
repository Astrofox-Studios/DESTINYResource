#version 330

#moj_import <minecraft:dynamictransforms.glsl>

uniform sampler2D Sampler0;

in vec2 texCoord0;

out vec4 fragColor;

void main() {
    vec4 color = texture(Sampler0, texCoord0);
    if (color.a == 0.0) {
        discard;
    }

    if (color.r == 37.0 / 255.0 && color.g == 40.0 / 255.0 && color.b == 30.0 / 255.0) {
        color = vec4(0.0, 0.0, 0.0, 0.0);
    }
    if (color.r == 38.0 / 255.0 && color.g == 26.0 / 255.0 && color.b == 28.0 / 255.0) {
        color = vec4(1.0, 1.0, 1.0, 0.125);
    }

    fragColor = color * ColorModulator;
}
