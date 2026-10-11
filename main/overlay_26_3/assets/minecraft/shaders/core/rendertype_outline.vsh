#version 330
#extension GL_ARB_separate_shader_objects : require

#include <minecraft:dynamictransforms.glsl>
#include <minecraft:projection.glsl>

layout(location = 0) in vec3 Position;
layout(location = 1) in vec4 Color;
layout(location = 2) in vec2 UV0;

layout(location = 0) out vec4 vertexColor;
layout(location = 1) out vec2 texCoord0;

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    vertexColor = Color;
    texCoord0 = UV0;

    // Recolour the default grey glow outline to the pack's purple
    if (distance(vertexColor, vec4(170.0, 170.0, 170.0, 255.0) / 255.0) < 0.05) {
        vertexColor = vec4(0.659, 0.659, 0.988, 1.0);
    }
}
