shader_type spatial;
render_mode vertex_lighting;


uniform sampler2D texture_albedo : hint_albedo;
uniform vec2 texture_scale = vec2(2.0, 2.0);

// angle, speed, wave length, steepness:
uniform vec3 wave_a = vec3(0.0, 2.1, 0.2);
uniform vec3 wave_b = vec3(0.0, 0.43, 0.25);
uniform vec3 wave_c = vec3(0.0, 0.6, 0.3);
uniform vec3 wave_d = vec3(0.0, 0.6, 0.3);

uniform float synced_time = 0.0;


const float PI = 3.14;


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
    float time = synced_time; //TIME;
   // time = 0.0;
    
    vec3 p = VERTEX.xyz;
    vec3 tangent = vec3(1, 0, 0);
    vec3 binormal = vec3(0, 0, 1);
    
    p += wave(wave_a, time, VERTEX.xyz, tangent, binormal);
    p += wave(wave_b, time, VERTEX.xyz, tangent, binormal);
    p += wave(wave_c, time, VERTEX.xyz, tangent, binormal);
    p += wave(wave_d, time, VERTEX.xyz, tangent, binormal);
    
    vec3 normal = normalize(cross(binormal, tangent));
    VERTEX.xyz = p;
    NORMAL = normal;
}

void fragment() {
    ALBEDO = vec3(0.0, 0.02, 0.1);
//    	ALPHA = 0.9;
    ROUGHNESS = 0.0;
    
//    vec4 albedo_tex = texture(texture_albedo, UV*texture_scale);
//    ALBEDO = albedo_tex.rgb;
}
