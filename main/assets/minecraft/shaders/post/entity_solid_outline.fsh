#version 330

uniform sampler2D InSampler;

layout(std140) uniform SamplerInfo {
    vec2 OutSize;
    vec2 InSize;
};

in vec2 texCoord;

out vec4 fragColor;

// How far the outline extends past the entity silhouette, in texels.
const int RADIUS = 3;
// Opacity of the tint that fills the silhouette itself.
const float FILL_ALPHA = 0.22;

void main() {
    vec2 oneTexel = 1.0 / InSize;

    vec4 center = texture(InSampler, texCoord);

    // Dilate the silhouette by RADIUS texels, keeping the colour of whichever
    // sample is both part of the entity and closest to this texel. Vanilla
    // averages all five samples and multiplies by 0.2, which is what produced
    // the dark border.
    float bestDist = float(RADIUS) + 1.0;
    vec3 glow = center.rgb;
    for (int y = -RADIUS; y <= RADIUS; y++) {
        for (int x = -RADIUS; x <= RADIUS; x++) {
            float dist = length(vec2(x, y));
            if (dist > float(RADIUS) || dist >= bestDist) {
                continue;
            }
            vec4 s = texture(InSampler, texCoord + vec2(x, y) * oneTexel);
            if (s.a > 0.0) {
                bestDist = dist;
                glow = s.rgb;
            }
        }
    }

    if (bestDist > float(RADIUS)) {
        // Nothing glowing anywhere near this texel.
        fragColor = vec4(0.0);
    } else if (center.a > 0.0) {
        // Inside the silhouette: a low-opacity overlay in the glow colour.
        fragColor = vec4(glow, FILL_ALPHA);
    } else {
        // The ring itself - full alpha, so the outline never fades out.
        fragColor = vec4(glow, 1.0);
    }
}
