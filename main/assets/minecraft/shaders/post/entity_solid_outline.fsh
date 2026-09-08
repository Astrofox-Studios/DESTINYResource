#version 330

uniform sampler2D InSampler;

layout(std140) uniform SamplerInfo {
    vec2 OutSize;
    vec2 InSize;
};

in vec2 texCoord;

out vec4 fragColor;

void main() {
    vec2 oneTexel = 1.0 / InSize;

    vec4 center = texture(InSampler, texCoord);
    vec4 left   = texture(InSampler, texCoord - vec2(oneTexel.x, 0.0));
    vec4 right  = texture(InSampler, texCoord + vec2(oneTexel.x, 0.0));
    vec4 up     = texture(InSampler, texCoord - vec2(0.0, oneTexel.y));
    vec4 down   = texture(InSampler, texCoord + vec2(0.0, oneTexel.y));

    // Edge = any alpha discontinuity between this texel and its neighbours.
    float edge = clamp(abs(center.a - left.a) + abs(center.a - right.a)
                     + abs(center.a - up.a)  + abs(center.a - down.a), 0.0, 1.0);

    // Take the glow colour from whichever sample is actually part of the entity,
    // at full brightness. Vanilla averages all five samples and multiplies by 0.2,
    // which is what produced the dark border.
    vec3 glow = center.a > 0.0 ? center.rgb
              : left.a   > 0.0 ? left.rgb
              : right.a  > 0.0 ? right.rgb
              : up.a     > 0.0 ? up.rgb
              :                  down.rgb;

    // Hard cutoff - full alpha or nothing, so the outline never fades out.
    fragColor = edge > 0.0 ? vec4(glow, 1.0) : vec4(0.0);
}
