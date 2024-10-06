#version 150
uniform sampler2D DiffuseSampler;in vec2 texCoord;in vec2 oneTexel;uniform vec2 InSize;uniform vec2 BlurDir;uniform float Radius;out vec4 fragColor;void main(){vec4 total=texture(DiffuseSampler,texCoord+oneTexel*-Radius*BlurDir)+texture(DiffuseSampler,texCoord)+texture(DiffuseSampler,texCoord+oneTexel*Radius*BlurDir);fragColor=vec4(total.xyz/3.,total.w);}