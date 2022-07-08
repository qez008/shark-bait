shader_type spatial;
//render_mode ;

uniform int NUM_OCTAVES = 3;
uniform float num_lines = 30.0;
uniform float line_width = 0.1;
uniform float noise_scale = 1.0;
uniform float treshold : hint_range(0.0, 1.0) = 0.12;

uniform float seed = 0.0;

uniform float y_off = 0.0;

uniform vec4 line_color : hint_color = vec4(0.0, 0.7, 1.0, 1.0);
uniform vec4 fill_color : hint_color = vec4(0.0, 0.1, 0.1, 1.0);

// angle, speed, wave length, steepness:
uniform vec3 wave_a = vec3(0., 1., 0.);
uniform vec3 wave_b = vec3(0., 1., 0.);
uniform vec3 wave_c = vec3(0., 1., 0.);
uniform vec3 wave_d = vec3(0., 1., 0.);

uniform float synced_time = 0.0;
uniform vec3 wave_offset = vec3(0.0, 0.0, 0.0);

uniform float mesh_size = 40.;


const float PI = 3.141593;


/*
    Gerstner wave:
    https://catlikecoding.com/unity/tutorials/flow/waves/
*/
vec3 wave(vec3 wave, float time, vec3 p, inout vec3 tangent, inout vec3 binormal) {
    // extract parameters from wave vector:
    float angle = wave.x;
    float wave_length = wave.y;
    float steepness = wave.z;
    
    float k = 2.0 * PI / wave_length;
    float c = sqrt(9.8 / k);
    vec2 d = vec2(sin(angle), cos(angle));
    float f = k * (dot(d, p.xz) - c * time);
    float a = steepness / k;
            
    tangent += vec3(
        -d.x * d.x * (steepness * sin(f)),
        d.x * (steepness * cos(f)),
        -d.x * d.y * (steepness * sin(f))
    );
    binormal += vec3(
        -d.x * d.y * (steepness * sin(f)),
        d.y * (steepness * cos(f)),
        -d.y * d.y * (steepness * sin(f))
    );
    return vec3(
        d.x * (a * cos(f)),
        a * sin(f),
        d.y * (a * cos(f))
    );
}

void vertex() {
    
    float time = synced_time;
    vec3 vtx = VERTEX.xyz + wave_offset; 
    vec3 p = vtx;
    vec3 tangent = vec3(1, 0, 0);
    vec3 binormal = vec3(0, 0, 1);
    
    p += wave(wave_a, time, vtx, tangent, binormal);
    p += wave(wave_b, time, vtx, tangent, binormal);
    p += wave(wave_c, time, vtx, tangent, binormal);
    p += wave(wave_d, time, vtx, tangent, binormal);
    
    vec3 normal = normalize(cross(binormal, tangent));
    
    VERTEX.xyz = p * vec3(1., (5. + y_off) / 5., 1.) - wave_offset + vec3(0.0, y_off, 0.0);
    NORMAL = normal;
}


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
    noise_val = fract(noise_val * num_lines);
    float heightLine = smoothstep(1.0 - line_width, 1.0, noise_val);
    heightLine += smoothstep(line_width, 0.0, noise_val);
    
    return vec3(heightLine);    
}

vec3 surface_pattern(float dist, vec2 uv, float time) {
    vec2 st = uv + wave_offset.xz / mesh_size + vec2(seed);
    st *= noise_scale;
    vec3 color = vec3(0.0);

    vec2 q = vec2(0.);
    q.x = fbm( st + 0.00 * time);
    q.y = fbm( st + vec2(1.0));

    vec2 r = vec2(0.);
    r.x = fbm( st + 1.0 * q + vec2(1.7,9.2) + 0.15 * time);
    r.y = fbm( st + 1.0 * q + vec2(8.3,2.8) + 0.126 * time);

    float f = fbm(st+r);
    
    return vec3(lines(f)) * line_color.rgb * (treshold - dist) / treshold;
}

void fragment() {
    float t = synced_time * 2.0;
    
    ALBEDO = fill_color.rgb;
    
    float dist = distance((UV - 0.5), vec2(0.0));
    if (dist < treshold) {
        ALBEDO += surface_pattern(dist, UV, t);// * normalize(cross(dFdx(VERTEX), dFdy(VERTEX)));
    }
    
    NORMAL = normalize(cross(dFdx(VERTEX), dFdy(VERTEX)));
//    ALBEDO = fill_color.rgb;
    METALLIC = 0.0;
    ROUGHNESS = 0.3;
    SPECULAR = 0.1;
    
//    ALPHA = clamp(1. - pow(dist * 2., 2), 0., 1.);
//    float depth;
//    float depth = texture(DEPTH_TEXTURE, SCREEN_UV).r;
//    depth = depth * 2.0 - 1.0;
//    depth = PROJECTION_MATRIX[3][2] / (depth + PROJECTION_MATRIX[2][2]);
//    depth = depth + VERTEX.z;
//    depth = exp(-depth * 0.5);
//    ALPHA = clamp(1.0 - depth, 0.0, 1.0);
}
