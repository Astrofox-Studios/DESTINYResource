#define ALPHA(value, override) if(alpha == value) return override;

#define EMISSIVE int checkEmissive(int alpha) {
#define UNLIT return -1; } int checkUnlit(int alpha) {
#define NO_NORMAL_SHADING return -1; } int checkNoNormalShading(int alpha) {
#define HALF_EMISSIVE return -1; } int checkHalfEmissive(int alpha) {

#moj_import <emissives_config.glsl>

// Wrapped in #ifdef to work around a PackSquash issue
#ifdef EMISSIVES_CONFIG_H
return -1; }
#endif

int getAlpha(float a) {
    return int(round(a * 255.00));
}

vec4 applyLighting(int alpha, vec4 albedo, vec4 normalLighting, vec4 lightmap) {

    int unlit           = checkUnlit(alpha);
    int noNormalShading = checkNoNormalShading(alpha);
    int emissive        = checkEmissive(alpha);
    int halfEmissive    = checkHalfEmissive(alpha);

    if(unlit != -1) {
        albedo.a = unlit / 255.0;
        return albedo;
    }

    if(noNormalShading != -1) {
        albedo.a = noNormalShading / 255.0;;
        return albedo * lightmap;
    }

    if(emissive != -1) {
        albedo.a = emissive / 255.0;
        return albedo * normalLighting;
    }

    if(halfEmissive != -1) {
        albedo.a = halfEmissive / 255.0;
        return albedo * mix(normalLighting * lightmap, vec4(1.0), 0.5);
    }

    return albedo * normalLighting * lightmap;

}
