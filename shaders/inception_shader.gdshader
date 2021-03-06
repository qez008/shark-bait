shader_type canvas_item;
render_mode unshaded;


// Author @patriciogv - 2015
// http://patriciogonzalezvivo.com

uniform int NUM_OCTAVES = 3;
uniform vec2 u_resolution = vec2(1.0);
uniform sampler2D noise_tex;

float random (in vec2 _st) {
    return fract(sin(dot(_st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

// Based on Morgan McGuire @morgan3d
// https://www.shadertoy.com/view/4dS3Wd
float noise (in vec2 _st) {
//    return texture(noise_tex, _st).x;
    
    vec2 i = floor(_st);
    vec2 f = fract(_st);

    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}


float fbm ( in vec2 _st) {
    float v = 0.0;
    float a = 0.5;
    vec2 shift = vec2(100.0);
    // Rotate to reduce axial bias
    mat2 rot = mat2( vec2(cos(0.5), sin(0.5)) , vec2(-sin(0.5), cos(0.50)) );
    for (int i = 0; i < NUM_OCTAVES; ++i) {
        v += a * noise(_st);
        _st = rot * _st * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}

vec3 lines(float noise_val) {
    noise_val = fract(noise_val * 20.0);
    float pixelNoiseChange = 0.1;
    float heightLine = smoothstep(1.0 - pixelNoiseChange, 1.0, noise_val);
    heightLine += smoothstep(pixelNoiseChange, 0.0, noise_val);
    
    return vec3(heightLine);    
}

void fragment() {
    vec2 st = UV / u_resolution.xy * 3.0;
    vec3 color = vec3(0.0);

    vec2 q = vec2(0.);
    q.x = fbm( st + 0.00 * TIME);
    q.y = fbm( st + vec2(1.0));

    vec2 r = vec2(0.);
    r.x = fbm( st + 1.0 * q + vec2(1.7,9.2) + 0.15 * TIME);
    r.y = fbm( st + 1.0 * q + vec2(8.3,2.8) + 0.126 * TIME);

    float f = fbm(st+r);

    color = mix( vec3(0.101961, 0.619608, 0.666667) , vec3(0.666667, 0.666667, 0.498039) , clamp((f * f) * 4.0, 0.0, 1.0) );
    color = mix( color , vec3(0.0, 0.0, 0.164706) , clamp(length(q), 0.0, 1.0) );
    color = mix( color , vec3(0.666667, 1.0, 1.0) , clamp(abs(r.x), 0.0, 1.0) );
    
//    COLOR = vec4( (f*f*f + .6*f*f + .5*f) * color , 1.0 );
    COLOR = vec4( lines(f) , 1.0 );
}