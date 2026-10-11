#version 330
#extension GL_ARB_separate_shader_objects : require

#include <minecraft:dynamictransforms.glsl>
#include <minecraft:projection.glsl>

layout(location = 0) in vec3 Position;
layout(location = 1) in vec2 UV0;

uniform sampler2D Sampler0;

layout(location = 0) out vec2 texCoord0;

const vec2 corners[4] = vec2[4](vec2(1.0, 0.0), vec2(0.0, 0.0), vec2(0.0, 1.0), vec2(1.0, 1.0));

vec4 getVertexColor(sampler2D tex, int vertexID, vec2 coords) {
    vec2 size = 1.0 / textureSize(tex, 0);
    return textureLod(tex, coords - (corners[vertexID % 4] - 0.5) * size, -9999.0);
}

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);
    texCoord0 = UV0;

    // Marker colours: shift the quad aside so it isn't drawn where it was placed
    vec4 color = getVertexColor(Sampler0, gl_VertexIndex, texCoord0);
    if (color.r == 38.0 / 255.0 && color.g == 26.0 / 255.0 && color.b == 28.0 / 255.0) {
        gl_Position = ProjMat * ModelViewMat * vec4(Position + vec3(-5.0, 0.0, 0.0), 1.0);
    } else if (color.r == 37.0 / 255.0 && color.g == 40.0 / 255.0 && color.b == 30.0 / 255.0) {
        gl_Position = ProjMat * ModelViewMat * vec4(Position + vec3(-5.0, 0.0, 0.0), 1.0);
    }
}
