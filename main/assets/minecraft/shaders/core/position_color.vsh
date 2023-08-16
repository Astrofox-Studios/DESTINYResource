#version 150
#define TOOLTIP_Z_MIN -0.6
#define TOOLTIP_Z_MAX -0.199
in vec3 Position;out vec4 position;in vec4 Color;out float dis;uniform mat4 ModelViewMat;uniform mat4 ProjMat;out vec4 vertexColor;void main(){gl_Position=ProjMat*ModelViewMat*vec4(Position,1.);position=gl_Position;dis=0.;if(position.y>3.||position.y<-3.||(position.x<-1.25||position.x>1.25)&&position.z>TOOLTIP_Z_MIN&&position.z<TOOLTIP_Z_MAX)dis=100000000.;vertexColor=Color;}