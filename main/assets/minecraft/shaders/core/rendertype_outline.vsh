#version 150
in vec3 Position;in vec4 Color;in vec2 UV0;uniform mat4 ModelViewMat;uniform mat4 ProjMat;out vec4 vertexColor;out vec2 texCoord0;void main(){gl_Position=ProjMat*ModelViewMat*vec4(Position,1.);vertexColor=Color;texCoord0=UV0;if(distance(vertexColor,vec4(170.,170.,170.,255.)/255.)<0.05)vertexColor=vec4(0.659,0.659,0.988,1.);}