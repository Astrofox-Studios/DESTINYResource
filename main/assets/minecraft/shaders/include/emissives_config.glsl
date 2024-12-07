// PackSquash issue workarounds, remove when not necessary
#ifndef EMISSIVE
#define EMISSIVE ;
#endif
#ifndef UNLIT
#define UNLIT ;
#endif
#ifndef NO_NORMAL_SHADING
#define NO_NORMAL_SHADING ;
#endif
#ifndef HALF_EMISSIVE
#define HALF_EMISSIVE ;
#endif
#ifndef ALPHA
#define ALPHA(x, y) ;
#endif
// End PackSquash issue workarounds

EMISSIVE

UNLIT
    ALPHA(252, 255)
    ALPHA(251, 255)
    ALPHA(235, 235)
    ALPHA(231, 231)
    ALPHA(202, 202)
    ALPHA(201, 201)
    ALPHA(200, 200)
    ALPHA(182, 182)
    ALPHA(181, 181)
    ALPHA(152, 152)
    ALPHA(142, 142)
    ALPHA(141, 141)
    ALPHA(102, 102)
    ALPHA(101, 101)
    ALPHA(82, 82)
    ALPHA(52,  52)
    ALPHA(22,  22)

NO_NORMAL_SHADING
    ALPHA(253, 255)
    ALPHA(250, 255)
    ALPHA(233, 233)
    ALPHA(230, 230)
    ALPHA(203, 203)
    ALPHA(183, 183)
    ALPHA(180, 180)
    ALPHA(153, 153)
    ALPHA(143, 143)
    ALPHA(140, 140)
    ALPHA(103, 103)
    ALPHA(100, 100)
    ALPHA(53,  53)
    ALPHA(23,  23)

HALF_EMISSIVE
    ALPHA(247, 255)

// PackSquash issue workaround
#define EMISSIVES_CONFIG_H
