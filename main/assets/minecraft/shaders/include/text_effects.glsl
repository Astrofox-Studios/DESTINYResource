#version 150
#if defined(RENDERTYPE_TEXT) || defined(RENDERTYPE_TEXT_INTENSITY)

struct TextData {
    vec2 uv;                // (input and output) texture uv coordinate
    vec4 color;             // (input and output) color of the text
    float alpha;            // (input and output) transparency of the text

    vec4 overlayColor;      // (output) color layer that will overlayed on the text
    vec4 backColor;         // (output) color layer that will be placed behind the text
    bool shouldScale;       // (output) set to true if the text character's quad needs to be scaled up, used in moving effects

    vec2 uvMin;             // (input) text character uv bounds within the atlas
    vec2 uvMax;             // (input) text character uv bounds within the atlas
    vec2 uvCenter;          // (input) uv coords of the center of the text character
    vec2 position;          // (input) position of the fragment on the screen, in UI pixels
    vec2 characterPosition; // (input) podiyion of the text character on the screen, in UI pixels
    vec2 localPosition;     // (input) coordinates ranging from 0-1 over the quad of a single character
    bool isShadow;          // (input) set to true if rendering the shadow of the text
};

TextData textData;

#define TEXT_EFFECT(r, g, b) return true; case ((uint(r/4) << 16) | (uint(g/4) << 8) | (uint(b/4))):

bool uvBoundsCheck(vec2 uv, vec2 uvMin, vec2 uvMax) {
    const float error = 0.0001;
    return uv.x > textData.uvMin.x + error && uv.y > textData.uvMin.y + error && uv.x < textData.uvMax.x - error && uv.y < textData.uvMax.y - error;
}

vec3 textSdf() {
    vec3 value = vec3(0.0, 0.0, 1.0);

    vec2 texelSize = 1.0 / vec2(256.0);
    for(int x = -1; x <= 1; x++) {
        for(int y = -1; y <= 1; y++) {
            vec2 uv = textData.uv + vec2(x, y) * texelSize;
            if(!uvBoundsCheck(uv, textData.uvMin, textData.uvMax)) continue;

            vec4 s = texture(Sampler0, uv);
            if(s.a >= 0.1) {
                vec3 v = vec3(fract(uv * 256.0), 0.0);

                if(x == 0) v.x = 0.0;
                if(y == 0) v.y = 0.0;
                if(x > 0) v.x = 1.0-v.x;
                if(y > 0) v.y = 1.0-v.y;

                v.z = length(v.xy);

                if(v.z < value.z) value = v;
            }
        }
    }
    return value;
}

void override_text_color(vec4 color) {
    textData.color = color;
    if(textData.isShadow) textData.color.rgb *= 0.25;
}

void override_text_color(vec3 color) {
    textData.color.rgb = color;
    if(textData.isShadow) textData.color.rgb *= 0.25;
}

void override_shadow_color(vec4 color) {
    if(textData.isShadow) {
        textData.color = color;
        textData.backColor.rgb = color.rgb;
        textData.overlayColor.a = 0.0;
    }
}

void override_shadow_color(vec3 color) {
    override_shadow_color(vec4(color, 1.0));
}

void remove_text_shadow() {
    if(textData.isShadow) textData.color.a = 0.0;
}

void apply_vertical_shadow() {
    if(textData.isShadow) {
        textData.uv.x += 1.0 / 256.0;
        textData.shouldScale = true;
    }
}

void apply_waving_movement(float speed, float frequency) {
    textData.uv.y += sin(textData.characterPosition.x * 0.1 * frequency - GameTime * 7500.0 * speed) / 256.0;
    textData.shouldScale = true;
}

void apply_waving_movement(float speed) {
    apply_waving_movement(speed, 1.0);
}

void apply_waving_movement() {
    apply_waving_movement(1.0, 1.0);
}

void apply_shaking_movement() {
    float noiseX = noise(textData.characterPosition.x + textData.characterPosition.y + GameTime * 32000.0) - 0.5;
    float noiseY = noise(textData.characterPosition.x - textData.characterPosition.y + GameTime * 32000.0) - 0.5;
    textData.shouldScale = true;

    textData.uv += vec2(noiseX, noiseY) / 256.0;
}

void apply_iterating_movement(float speed, float space) {
    float x = mod(textData.characterPosition.x * 0.4 - GameTime * 18000.0 * speed, (5.0 * space) * TAU);
    if(x > TAU) x = TAU;
    textData.uv.y += (-cos(x) * 0.5 + 0.5) / 256.0;
    textData.shouldScale = true;
}

void apply_iterating_movement() {
    apply_iterating_movement(1.0, 1.0);
}

void apply_flipping_movement(float speed, float space) {
    float t = mod((textData.characterPosition.x * 0.4 - GameTime  * 18000.0 * speed) / TAU, 5.0 * space);
    textData.uv.x = textData.uvCenter.x + (textData.uv.x - textData.uvCenter.x) / (cos(TAU * min(t, 1.0)));
    textData.uv.y = textData.uvCenter.y + (textData.uv.y - textData.uvCenter.y) / (1.0 + 0.1 * sin(TAU * min(t, 1.0)));
    textData.shouldScale = true;
}

void apply_flipping_movement() {
    apply_flipping_movement(1.0, 1.0);
}

void apply_skewing_movement(float speed) {
    float t = GameTime * 1600.0 * speed;

    textData.uv.x = mix(textData.uv.x, textData.uv.x + sin(TAU * t * 0.5) / 256.0, 1.0 - textData.localPosition.y);
    textData.uv.y = mix(textData.uv.y, textData.uvMax.y, -(0.3 + 0.5 * cos(TAU * t)));
    textData.shouldScale = true;
}

void apply_skewing_movement() { 
    apply_skewing_movement(1.0);
}

void apply_growing_movement(float speed) {
    vec2 offset = vec2(0.0, 5.0 / 256.0);
    textData.uv = (textData.uv - textData.uvCenter - offset) * (sin(GameTime * 12800.0 * speed) * 0.15 + 0.85) + textData.uvCenter + offset;
    textData.shouldScale = true;
}

void apply_growing_movement() {
    apply_growing_movement(1.0);
}

void apply_outline(vec3 color) {
    textData.shouldScale = true;

    if(textData.isShadow) {
        color *= 0.25;
        textData.color.rgb = color;
    } 

    vec2 texelSize = 1.0 / vec2(256.0);

    for(int x = -1; x <= 1; x++) {
        for(int y = -1; y <= 1; y++) {
            if(x == 0 && y == 0) continue;

            vec2 uv = textData.uv + vec2(x, y) * texelSize;
            if(!uvBoundsCheck(uv, textData.uvMin, textData.uvMax)) continue;

            vec4 s = texture(Sampler0, uv);
            if(s.a >= 0.1) { textData.backColor = vec4(color, 1.0); return; }
        }
    }
}

void apply_thin_outline(vec3 color) {
    textData.shouldScale = true;

    if(textData.isShadow) {
        color *= 0.25;
        textData.color.rgb = color;
    } 
    
    vec2 texelSize = 0.5 / vec2(256.0);

    for(int x = -1; x <= 1; x++) {
        for(int y = -1; y <= 1; y++) {
            if(x == 0 && y == 0) continue;

            vec2 uv = textData.uv + vec2(x, y) * texelSize;
            if(!uvBoundsCheck(uv, textData.uvMin, textData.uvMax)) continue;

            vec4 s = texture(Sampler0, uv);
            if(s.a >= 0.1) { textData.backColor = vec4(color, 1.0); return; }
        }
    }
}


void apply_gradient(vec3 color1, vec3 color2) {
    textData.color.rgb = mix(color1, color2, (textData.uv.y - textData.uvMin.y) / (textData.uvMax.y - textData.uvMin.y));
    if(textData.isShadow) textData.color.rgb *= 0.25;
}

void apply_scrolling_gradient(vec3 color1, vec3 color2, float speed) {
    float t = fract(0.1 * (textData.position.x) * 0.03 - GameTime * 300.0 * speed);
    textData.color.rgb = mix(color1, color2, t);
    if(textData.isShadow) textData.color.rgb *= 0.25;
}

void apply_scrolling_gradient(vec3 color1, vec3 color2) {
    apply_scrolling_gradient(color1, color2, 1.0);
}

void apply_rainbow() {
    textData.color.rgb = hsvToRgb(vec3(0.005 * (textData.position.x + textData.position.y) - GameTime * 300.0, 0.7, 1.0));
    if(textData.isShadow) textData.color.rgb *= 0.25;
}

void apply_shimmer(float speed, float intensity) {
    if(textData.isShadow) return;
    float f = textData.localPosition.x + textData.localPosition.y - GameTime * 6400.0 * speed;
    
    if(mod(f, 5) < 0.75) textData.overlayColor = vec4(1.0, 1.0, 1.0, intensity);
}

void apply_shimmer(){
    apply_shimmer(1.0, 0.5);
}

void apply_chromatic_abberation() {
    textData.shouldScale = true;
    float noiseX = noise(GameTime * 12000.0) - 0.5;
    float noiseY = noise(GameTime * 12000.0 + 19732.134) - 0.5;
    vec2 offset = vec2(0.5 / 256, 0.0) + vec2(0.5, 1.0) * vec2(noiseX, noiseY) / 256;

    vec2 uv = textData.uv + offset;
    vec4 s1 = texture(Sampler0, uv);
    s1.rgb *= s1.a;
    if(!uvBoundsCheck(uv, textData.uvMin, textData.uvMax)) s1 = vec4(0.0);

    uv = textData.uv - offset;
    vec4 s2 = texture(Sampler0, uv);
    s2.rgb *= s2.a;
    if(!uvBoundsCheck(uv, textData.uvMin, textData.uvMax)) s2 = vec4(0.0);

    textData.backColor = (s1 * vec4(1.0, 0.25, 0.0, 1.0)) + (s2 * vec4(0.0, 0.75, 1.0, 1.0));
    textData.backColor.rgb *= textData.color.rgb;
}

void apply_metalic(vec3 lightColor, vec3 darkColor) {
    int y = int(floor((textData.uv.y - textData.uvMin.y) * 256.0));
    
    if(y > 3) textData.color.rgb = darkColor;
    if(y == 3) textData.color.rgb = lightColor + 0.25;
    if(y < 3) textData.color.rgb = lightColor;

    if(textData.isShadow) textData.color.rgb *= 0.25;
}

void apply_metalic(vec3 color) {
    int y = int(floor((textData.uv.y - textData.uvMin.y) * 256.0));
    
    if(y > 3) textData.color.rgb = color * 0.7;
    if(y == 3) textData.color.rgb = color + 0.25;
    if(y < 3) textData.color.rgb = color;

    if(textData.isShadow) textData.color.rgb *= 0.25;
}

void apply_fire() {
    textData.shouldScale = true;
    if(textData.isShadow) return;

    float h = fract(textData.uv.y * 256.0);
    vec2 uv = textData.uv + vec2(0.0, 1.0 / 256);
    if(!uvBoundsCheck(uv, textData.uvMin, textData.uvMax)) return;
    vec4 s = texture(Sampler0, uv);
    if(s.a > 0.1) {
        float f = noise(textData.localPosition * 32.0 + vec2(0.0, GameTime * 6400.0)) * 0.5 + 0.5;
        f -= (1.0 - sqrt(h)) * 0.8;

        if(f > 0.5)
        textData.backColor = vec4(mix(vec3(1.0, 0.2, 0.2), vec3(1.0, 0.7, 0.3), (f - 0.5) / 0.5), 1.0);
    }
}

void apply_fade(float speed) {
    textData.color.a = mix(textData.color.a, 0.0, sin(GameTime * 1200 * speed * PI) * 0.5 + 0.5);
}

void apply_fade() {
    apply_fade(1.0);
}

void apply_fade(vec3 color, float speed) {
    if(textData.isShadow) color *= 0.25;

    textData.color.rgb = mix(textData.color.rgb, color, sin(GameTime * 1200 * speed * PI) * 0.5 + 0.5);
}

void apply_fade(vec3 color) {
    apply_fade(color, 1.0);
}

void apply_blinking(float speed){
    if(sin(GameTime * 3200 * speed * PI) < 0.0) { textData.color.a = 0.0; textData.backColor.a = 0.0; textData.overlayColor.a = 0.0; }
}

void apply_blinking() {
    apply_blinking(1.0);
}

void apply_glowing() {
    if(textData.isShadow) textData.color = vec4(0.0);
    vec3 d = textSdf();
    textData.backColor = vec4(1.0, 1.0, 1.0, (1.0 - d.z) * (1.0 - d.z));
}

void apply_lesbian_pride() {
    int y = int(floor((textData.uv.y - textData.uvMin.y) * 256.0));

    if(y <  3) textData.color.rgb = vec3(0.839, 0.161, 0.000);
    if(y == 3) textData.color.rgb = vec3(1.000, 0.608, 0.333);
    if(y == 4) textData.color.rgb = vec3(1.000, 1.000, 1.000);
    if(y == 5) textData.color.rgb = vec3(0.831, 0.384, 0.647);
    if(y >  5) textData.color.rgb = vec3(0.647, 0.000, 0.384);

    if(textData.isShadow) textData.color.rgb *= 0.25;
}

void apply_mlm_pride() {
    int y = int(floor((textData.uv.y - textData.uvMin.y) * 256.0));

    if(y <  3) textData.color.rgb = vec3(0.000, 0.584, 0.525);
    if(y == 3) textData.color.rgb = vec3(0.412, 0.941, 0.686);
    if(y == 4) textData.color.rgb = vec3(1.000, 1.000, 1.000);
    if(y == 5) textData.color.rgb = vec3(0.510, 0.698, 1.000);
    if(y >  5) textData.color.rgb = vec3(0.271, 0.153, 0.627);

    if(textData.isShadow) textData.color.rgb *= 0.25;
}

void apply_bisexual_pride() {
    int y = int(floor((textData.uv.y - textData.uvMin.y) * 256.0));

    if(y <  4) textData.color.rgb = vec3(0.843, 0.000, 0.443);
    if(y == 4) textData.color.rgb = vec3(0.612, 0.306, 0.592);
    if(y >  4) textData.color.rgb = vec3(0.000, 0.208, 0.663);

    if(textData.isShadow) textData.color.rgb *= 0.25;
}

void apply_transgender_pride() {
    int y = int(floor((textData.uv.y - textData.uvMin.y) * 256.0));

    if(y <  3) textData.color.rgb = vec3(0.357, 0.812, 0.980);
    if(y == 3) textData.color.rgb = vec3(0.961, 0.671, 0.725);
    if(y == 4) textData.color.rgb = vec3(1.000, 1.000, 1.000);
    if(y == 5) textData.color.rgb = vec3(0.961, 0.671, 0.725);
    if(y >  5) textData.color.rgb = vec3(0.357, 0.812, 0.980);

    if(textData.isShadow) textData.color.rgb *= 0.25;
}

void apply_pride() {
    int y = int(floor((textData.uv.y - textData.uvMin.y) * 256.0));

    if(y <  2) textData.color.rgb = vec3(1.000, 0.012, 0.012);
    if(y == 2) textData.color.rgb = vec3(1.000, 0.549, 0.000);
    if(y == 3) textData.color.rgb = vec3(1.000, 0.929, 0.000);
    if(y == 4) textData.color.rgb = vec3(0.000, 0.502, 0.149);
    if(y == 5) textData.color.rgb = vec3(0.000, 0.302, 1.000);
    if(y >  5) textData.color.rgb = vec3(0.459, 0.027, 0.529);

    if(textData.isShadow) textData.color.rgb *= 0.25;
}

void apply_pansexual_pride() {
    int y = int(floor((textData.uv.y - textData.uvMin.y) * 256.0));

    if(y <  3) textData.color.rgb = vec3(1.000, 0.129, 0.549);
    if(y == 3) textData.color.rgb = vec3(1.000, 0.847, 0.000);
    if(y == 4) textData.color.rgb = vec3(1.000, 0.847, 0.000);
    if(y >  4) textData.color.rgb = vec3(0.129, 0.694, 1.000);

    if(textData.isShadow) textData.color.rgb *= 0.25;
}

void apply_asexual_pride() {
    int y = int(floor((textData.uv.y - textData.uvMin.y) * 256.0));

    if(y <  3) textData.color.rgb = vec3(0.100, 0.100, 0.100);
    if(y == 3) textData.color.rgb = vec3(0.639, 0.639, 0.639);
    if(y == 4) textData.color.rgb = vec3(1.000, 1.000, 1.000);
    if(y >  4) textData.color.rgb = vec3(0.502, 0.000, 0.502);

    if(textData.isShadow) textData.color.rgb *= 0.25;
}

void apply_aromantic_pride() {
    int y = int(floor((textData.uv.y - textData.uvMin.y) * 256.0));

    if(y <  3) textData.color.rgb = vec3(0.047, 0.655, 0.294);
    if(y == 3) textData.color.rgb = vec3(0.584, 0.796, 0.451);
    if(y == 4) textData.color.rgb = vec3(1.000, 1.000, 1.000);
    if(y == 5) textData.color.rgb = vec3(0.639, 0.639, 0.639);
    if(y >  5) textData.color.rgb = vec3(0.100, 0.100, 0.100);

    if(textData.isShadow) textData.color.rgb *= 0.25;
}

void apply_non_binary_pride() {
    int y = int(floor((textData.uv.y - textData.uvMin.y) * 256.0));

    if(y <  3) textData.color.rgb = vec3(1.000, 0.957, 0.173);
    if(y == 3) textData.color.rgb = vec3(1.000, 1.000, 1.000);
    if(y == 4) textData.color.rgb = vec3(0.616, 0.349, 0.824);
    if(y >  4) textData.color.rgb = vec3(0.100, 0.100, 0.100);

    if(textData.isShadow) textData.color.rgb *= 0.25;
}

bool applyTextEffects() {
    uint vertexColorId = textData.isShadow ? colorId(textData.color) : colorId(floor(textData.color * 255.5 / 4.0) / 255.5);
    switch(vertexColorId >> 8) { 
        case 0xFFFFFFFFu:

    #moj_import<text_effects_config.glsl>
    
        return true; 
    } 
    return false;
}

#define SPHEYA_PACK_9

#ifdef FSH
flat in float vctfx_applyTextEffect;
flat in float vctfx_isShadow;
flat in float vctfx_isGui;
flat in float vctfx_changedScale;

in vec4 vctfx_screenPos;
in vec3 vctfx_viewPos;
in vec2 vctfx_faceCoord;
in float vctfx_side;

in vec3 vctfx_t0;
in vec3 vctfx_t1;
in vec3 vctfx_p0;
in vec3 vctfx_p1;
in vec4 vctfx_vp0;
in vec4 vctfx_vp1;
in vec4 vctfx_vp2;

bool applySpheyaPack9() {
    if(vctfx_applyTextEffect < 0.5) return false;
    
    vec4 textureSample = vec4(0.0);
    if(vctfx_changedScale < 0.5) {
        textureSample = texture(Sampler0, texCoord0);
        if(textureSample.a < 0.1) discard;
    }

    vec2 pMin = min(vctfx_p0.xy / vctfx_p0.z, vctfx_p1.xy / vctfx_p1.z);
    vec2 pMax = max(vctfx_p0.xy / vctfx_p0.z, vctfx_p1.xy / vctfx_p1.z);
    vec3 vp0 = vctfx_vp0.xyz / vctfx_vp0.w;
    vec3 vp1 = vctfx_vp1.xyz / vctfx_vp1.w;
    vec3 vp2 = vctfx_vp2.xyz / vctfx_vp2.w;
    textData.uvMin = min(vctfx_t0.xy / vctfx_t0.z, vctfx_t1.xy / vctfx_t1.z);
    textData.uvMax = max(vctfx_t0.xy / vctfx_t0.z, vctfx_t1.xy / vctfx_t1.z);
    textData.uvCenter = (textData.uvMin + textData.uvMax) * 0.5;

    vec3 up = vp2 - vp1;
    vec3 left = vp2 - vp0;
    vec3 origin = vp0 - up;
    if(vctfx_side == 0.0) {
        vec3 tmp = up;
        up = -left;
        left = -tmp;
    }
    vec2 lenSq = vec2(dot(left, left), dot(up, up));

    if(vctfx_changedScale > 0.5) {
        textData.localPosition = (vctfx_screenPos.xy - pMin) / (pMax - pMin);
        textData.localPosition.y = 1.0 - textData.localPosition.y;
        textData.uv = textData.uvMin + (textData.uvMax - textData.uvMin) * textData.localPosition;
    }else{
        textData.localPosition = vctfx_faceCoord;
        textData.uv = texCoord0;
    }


    if((abs(up.x) < 0.0001 && abs(up.z) < 0.0001 && abs(left.y) < 0.0001 && abs(up.z) < 0.0001) || vctfx_isGui > 0.5) {
        textData.characterPosition = 0.5 * (pMax + pMin) * (textData.uvMax - textData.uvMin) * 256.0 / (pMax - pMin);
        textData.position = vctfx_screenPos.xy * (textData.uvMax - textData.uvMin) * 256.0 / (pMax - pMin);
    }else{
        textData.characterPosition = vec2(dot(left, origin), dot(up, origin)) * (textData.uvMax - textData.uvMin) * 256.0 / lenSq;
        textData.position =  vec2(dot(left, vctfx_viewPos), dot(up, vctfx_viewPos)) * (textData.uvMax - textData.uvMin) * 256.0 / lenSq;
    }

    textData.isShadow = vctfx_isShadow > 0.5;
    textData.color = vec4(baseColor.rgb, 1.0);
    textData.alpha = baseColor.a;

    if(vctfx_isShadow > 0.5)
        textData.characterPosition += vec2(-1, +1);

    applyTextEffects();
    if(vctfx_changedScale > 0.5)
        if(uvBoundsCheck(textData.uv, textData.uvMin, textData.uvMax))
            textureSample = texture(Sampler0, textData.uv);

    fragColor = textData.color * textureSample;
    fragColor = vec4(mix(textData.backColor.rgb, fragColor.rgb, fragColor.a), 1.0 - (1.0 - fragColor.a) * (1.0 - textData.backColor.a));
    fragColor.a *= textData.alpha;
    fragColor.rgb = mix(fragColor.rgb, textData.overlayColor.rgb, textData.overlayColor.a);
    fragColor *= lightColor * ColorModulator;

    if(fragColor.a == 0.0) discard;
    return true;
}
#endif

#ifdef VSH
flat out float vctfx_applyTextEffect;
flat out float vctfx_isShadow;
flat out float vctfx_isGui;
flat out float vctfx_changedScale;

out vec4 vctfx_screenPos;
out vec3 vctfx_viewPos;
out vec2 vctfx_faceCoord;
out float vctfx_side;

out vec3 vctfx_t0;
out vec3 vctfx_t1;
out vec3 vctfx_p0;
out vec3 vctfx_p1;
out vec3 vctfx_p2;
out vec4 vctfx_vp0;
out vec4 vctfx_vp1;
out vec4 vctfx_vp2;

bool applySpheyaPack9() {
    vctfx_applyTextEffect = 0.0;
    vctfx_t0 = vec3(0.0);
    vctfx_t1 = vec3(0.0);
    vctfx_p0 = vec3(0.0);
    vctfx_p1 = vec3(0.0);
    vctfx_vp0 = vec4(0.0);
    vctfx_vp1 = vec4(0.0);
    vctfx_vp2 = vec4(0.0);
    vctfx_side = 0.0;

    textData.isShadow = ProjMat[3][3] != 0.0 && fract(Position.z) < 0.01 && Position.z != 2000.0;
    textData.color = Color;
    textData.shouldScale = false;
    vctfx_isShadow = textData.isShadow ? 1.0 : 0.0;
    vctfx_isGui = ProjMat[3][3] != 0.0 ? 1.0 : 0.0;
    vctfx_viewPos = mat3(ModelViewMat) * Position;

    if(!applyTextEffects())
        return false;

    int vertexId = gl_VertexID % 4;
    if(vertexId == 0) { vctfx_t0 = vec3(UV0, 1.0); vctfx_p0 = vec3(gl_Position.xy, 1.0); vctfx_vp0 = vec4(vctfx_viewPos, 1.0); }
    if(vertexId == 1) { vctfx_vp2 = vec4(vctfx_viewPos, 1.0); }
    if(vertexId == 2) { vctfx_t1 = vec3(UV0, 1.0); vctfx_p1 = vec3(gl_Position.xy, 1.0); vctfx_vp1 = vec4(vctfx_viewPos, 1.0); }
    if(vertexId == 3) { vctfx_vp2 = vec4(vctfx_viewPos, 1.0); vctfx_side = 1.0; }

    vctfx_faceCoord = vec2[](vec2(0.0, 1.0), vec2(0.0, 0.0), vec2(1.0, 0.0), vec2(1.0, 1.0))[vertexId];

    vctfx_changedScale = 0.0;
    if(textData.shouldScale) {
        gl_Position.xy += 0.2 * (vctfx_faceCoord * 2.0 - 1.0);
        vctfx_changedScale = 1.0;
    }

    vctfx_screenPos = gl_Position;
    vctfx_applyTextEffect = 1.0;
    return true;
}
#endif

#endif