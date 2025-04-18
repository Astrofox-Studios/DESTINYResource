#version 150
#define VSH
#define RENDERTYPE_TEXT

// These are inputs and outputs to the shader
// If you are merging with a shader, put any inputs and outputs that they have, but are not here already, in the list below
in vec3 Position;
in vec4 Color;
in vec2 UV0;

uniform sampler2D Sampler0;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform float GameTime;
uniform vec2 ScreenSize;

out vec4 baseColor;
out vec4 lightColor;
out vec4 vertexColor;
out vec2 texCoord0;

#moj_import <spheya_packs_impl.glsl>

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    baseColor = Color;
    lightColor = vec4(1.0);
    vertexColor = baseColor * lightColor;
    texCoord0 = UV0;

    if(applySpheyaPacks()) return;

    // When merging with another shader, you should put the code in their main() function below here
}
