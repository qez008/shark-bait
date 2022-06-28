shader_type spatial;
render_mode vertex_lighting;

uniform vec4 grid_color : hint_color = vec4(0.0, 0.7, 1.0, 1.0);
uniform vec4 fill_color : hint_color = vec4(0.0, 0.1, 0.1, 1.0);

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

float grid(vec2 uv, float batt) {
    vec2 size = vec2(0.02);
//    uv += vec2(0.0, batt + 0.05);
    uv = abs(fract(uv) - 0.5);
    vec2 lines = smoothstep(size, vec2(0.0), uv);
    lines += smoothstep(size * 5.0, vec2(0.0), uv) * 0.4 * batt;
    return clamp(lines.x + lines.y, 0.0, 3.0);
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
    col = mix(fill_color, grid_color, gridVal);
    return col;
}

float circle(vec2 _st, float _radius){
    vec2 pos = vec2(0.5) - _st;
    return smoothstep(1.0 - _radius, 1.0 - _radius + _radius * 0.2, 1.0 - dot(pos, pos) * PI);
}


void fragment() {
//    vec2 st = fract(UV * 1000.0);
//    vec3 color = vec3(1.0 - circle(st, 0.3));
//    ALBEDO = color;
    vec4 color = lines(UV);
    ALBEDO = color.rgb;
//    ALPHA = color.a;
}
