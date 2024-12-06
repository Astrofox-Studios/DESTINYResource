#version 150

// Input variables
in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;

// Uniforms
uniform sampler2D Sampler0, Sampler2;
uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform float GameTime;

// Output variables
out float vertexDistance;
flat out vec4 vertexColor;
out vec2 texCoord0;

void main() {
    vec4 vertex = vec4(Position, 1.0);

    // Check if Color matches specific values
    if (Color.xyz == vec3(255., 85., 85.) / 255.) {
        // Set vertex position
        gl_Position = ProjMat * ModelViewMat * vertex;

        // Set vertex color
        if (Position.z == 0. && gl_VertexID <= 6 && gl_Position.x > 0.95)
            vertexColor = vec4(0);
        else
            vertexColor = Color * texelFetch(Sampler2, UV2 / 16, 0);
    } else if (Color.xyz == vec3(255., 255., 254.) / 255.) {
        // Set vertex position
        gl_Position = ProjMat * ModelViewMat * vertex;

        // Set vertex color with dynamic variation
        vertexColor = ((.6 + .6 * cos(6. * (gl_Position.x + GameTime * 1000.) + vec4(0, 23, 21, 1))) + vec4(0., 0., 0., 1.)) * texelFetch(Sampler2, UV2 / 16, 0);
    } else if (Color.xyz == vec3(255., 255., 253.) / 255. || Color.xyz == vec3(255., 255., 252.) / 255.) {
        // Set vertex position
        gl_Position = ProjMat * ModelViewMat * vertex;

        // Set vertex color
        vertexColor = ((.6 + .6 * cos(6. * (gl_Position.x + GameTime * 1000.) + vec4(0, 23, 21, 1))) + vec4(0., 0., 0., 1.)) * texelFetch(Sampler2, UV2 / 16, 0);

        // Adjust y position based on time
        gl_Position.y = gl_Position.y + sin(GameTime * 12000. + (gl_Position.x * 6)) / 150.;
    } else if (Color.xyz == vec3(255., 255., 251.) / 255. || Color.xyz == vec3(255., 254., 254.) / 255.) {
        // Set vertex color
        vertexColor = Color * texelFetch(Sampler2, UV2 / 16, 0);

        // Adjust y position based on time
        float vertexId = mod(gl_VertexID, 4.0);
        if (vertex.z <= 0.) {
            if (vertexId == 3. || vertexId == 0.)
                vertex.y += cos(GameTime * 12000. / 4) * 0.1;
            vertex.y += max(cos(GameTime * 12000. / 4) * 0.1, 0.);
        } else {
            if (vertexId == 3. || vertexId == 0.)
                vertex.y -= cos(GameTime * 12000. / 4) * 3;
            vertex.y -= max(cos(GameTime * 12000. / 4) * 4, 0.);
        }
        // Set vertex position
        gl_Position = ProjMat * ModelViewMat * vertex;
    } else {
        // Set vertex position
        gl_Position = ProjMat * ModelViewMat * vertex;

        // Set vertex color
        vertexColor = Color * texelFetch(Sampler2, UV2 / 16, 0);
    }

    // Calculate vertex distance
    vertexDistance = length((ModelViewMat * vertex).xyz);

    // Set texture coordinate
    texCoord0 = UV0;

    // ----- everything above this is the whole vanilla shader, everything below this is added -----
	
	// how it works: choose a text overlay color that you'll never use (i used total yellow, R255 G255 B0 or #FFFF00)
	// any text overlayed with that color will display without a shadow using the below two lines of code
	// (minecraft's built-in yellow is more pale than this so it'll still have a shadow)
	// note: a png used in a font can still have #FFFF00 in it and will not affect the text shadow, we're only looking at the overlay colors
	
	// first: if the text is overlayed with our selected color, override vertexColor to ignore the "Color" parameter (the overlay color)
	//        this is so that the text doesn't actually show up yellow
	//        IMPORTANT: the colors aren't quite exact so we check for a color *very close* to #FFFF00
	if (Color.r > 250/255. && Color.g > 250/255. && Color.b < 5/255.) vertexColor = texelFetch(Sampler2, UV2 / 16, 0);
	
	// second: if the overlay color is this specific darkened yellow then it's a shadow of the above color -
	//         set the vertexColor to zero including the alpha value so it'll be invisible
	//         i just had to identify this specific color through a bit of trial and error (60-65 red and green, 0-5 blue)
	else if (Color.r > 60/255. && Color.r < 65/255. && Color.g > 60/255. && Color.g < 65/255. && Color.b < 5/255.) vertexColor = vec4(0);
}