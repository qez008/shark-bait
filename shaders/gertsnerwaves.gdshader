shader_type spatial;
render_mode blend_add, unshaded;

uniform vec4 line_color : hint_color = vec4(0.0, 0.7, 1.0, 1.0);
uniform vec4 fill_color : hint_color = vec4(0.0, 0.1, 0.1, 1.0);

uniform sampler2D noise_pattern;

// angle, speed, wave length, steepness:
uniform vec3 wave_a = vec3(0.0, 2.1, 0.2);
uniform vec3 wave_b = vec3(0.0, 0.43, 0.25);
uniform vec3 wave_c = vec3(0.0, 0.6, 0.3);
uniform vec3 wave_d = vec3(0.0, 0.6, 0.3);

uniform float synced_time = 0.0;
uniform vec3 wave_offset = vec3(0.0, 0.0, 0.0);


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
    
    VERTEX.xyz = p - wave_offset;
    NORMAL = normal;
}

// https://www.ronja-tutorials.com/post/026-perlin-noise/
float surf(vec2 uv) {
    float noise = texture(noise_pattern, uv).x;
    noise = fract(noise * 20.0);
    float pixelNoiseChange = fwidth(noise);
    float heightLine = smoothstep(1.0 - pixelNoiseChange, 1.0, noise);
    heightLine += smoothstep(pixelNoiseChange, 0.0, noise);
    
    return heightLine;
}


float line(vec2 uv, float batt) {
    vec2 size = vec2(0.02);
    uv = abs(fract(uv) - 0.5);
    vec2 lines = smoothstep(size, vec2(0.0), uv);
    lines += smoothstep(size * 5.0, vec2(0.0), uv) * 0.4 * batt;
    return clamp(lines.x, 0.0, 3.0);
}


vec4 lines(vec2 uv) {
    vec2 offset = wave_offset.xz / 300.0;
    uv = (offset + uv) * 100.0;

    vec4 col = fill_color;
    float gridVal = line(uv, 1.0);
    col = mix(fill_color, line_color, gridVal);
    return col;
}


void fragment() {
//    NORMAL = normalize(cross(dFdx(VERTEX), dFdy(VERTEX)));
    
    vec2 offset = wave_offset.xz / 100.0;
    vec2 uv = (offset + UV);
    vec4 color = lines(UV);
    vec2 p = (UV - 0.5);
    float reverse_distance = 0.4 - distance(p, vec2(0.0));
    color *= vec4(clamp( reverse_distance*2. , 0.0 , 1.0 ));
    
    ALBEDO = color.rgb;
    
//    float depth = texture(DEPTH_TEXTURE, SCREEN_UV).x;
//    depth = depth * 2.0 - 1.0;
//    depth = PROJECTION_MATRIX[3][2] / (depth + PROJECTION_MATRIX[2][2]);
//    depth = depth + VERTEX.z;
//    depth = exp(-depth * 0.2);
//    ALPHA = clamp(1.0 - depth, 0.0, 1.0);
}
