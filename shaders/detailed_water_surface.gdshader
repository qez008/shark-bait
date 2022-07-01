shader_type spatial;
render_mode blend_add, unshaded, vertex_lighting;

uniform int NUM_OCTAVES = 3;
uniform vec2 u_resolution = vec2(1.0);
uniform sampler2D noise_tex;

uniform vec4 line_color : hint_color = vec4(0.0, 0.7, 1.0, 1.0);
uniform vec4 fill_color : hint_color = vec4(0.0, 0.1, 0.1, 1.0);

// angle, speed, wave length, steepness:
uniform vec3 wave_a = vec3(0., 1., 0.);
uniform vec3 wave_b = vec3(0., 1., 0.);
uniform vec3 wave_c = vec3(0., 1., 0.);
uniform vec3 wave_d = vec3(0., 1., 0.);

uniform float synced_time = 0.0;
uniform vec3 wave_offset = vec3(0.0, 0.0, 0.0);

uniform float distance_fade_min = 90;
uniform float distance_fade_max = 70;


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


bool fade(vec3 vtx, vec4 frg) {
    float fade_distance = -vtx.z;
	float fade = clamp( smoothstep(distance_fade_min, distance_fade_max, fade_distance) , 0.0 , 1.0 );
	int x = int(frg.x) % 4;
	int y = int(frg.y) % 4;
	int index = x + y * 4;
	float limit = 0.0;

	if (x < 8) {
		if (index == 0) limit = 0.0625;
		if (index == 1) limit = 0.5625;
		if (index == 2) limit = 0.1875;
		if (index == 3) limit = 0.6875;
		if (index == 4) limit = 0.8125;
		if (index == 5) limit = 0.3125;
		if (index == 6) limit = 0.9375;
		if (index == 7) limit = 0.4375;
		if (index == 8) limit = 0.25;
		if (index == 9) limit = 0.75;
		if (index == 10) limit = 0.125;
		if (index == 11) limit = 0.625;
		if (index == 12) limit = 1.0;
		if (index == 13) limit = 0.5;
		if (index == 14) limit = 0.875;
		if (index == 15) limit = 0.375;
	}
   
    return fade < limit;
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
    noise_val = fract(noise_val * 20.0);
    float pixelNoiseChange = 0.1;
    float heightLine = smoothstep(1.0 - pixelNoiseChange, 1.0, noise_val);
    heightLine += smoothstep(pixelNoiseChange, 0.0, noise_val);
    
    return vec3(heightLine);    
}

void fragment() {
    float t = synced_time;
    vec2 st = UV + wave_offset.xz / 30.;
    st *= 3.;
    vec3 color = vec3(0.0);

    vec2 q = vec2(0.);
    q.x = fbm( st + 0.00 * t);
    q.y = fbm( st + vec2(1.0));

    vec2 r = vec2(0.);
    r.x = fbm( st + 1.0 * q + vec2(1.7,9.2) + 0.15 * t);
    r.y = fbm( st + 1.0 * q + vec2(8.3,2.8) + 0.126 * t);

    float f = fbm(st+r);

    color = mix( vec3(0.101961, 0.619608, 0.666667) , vec3(0.666667, 0.666667, 0.498039) , clamp((f * f) * 4.0, 0.0, 1.0) );
    color = mix( color , vec3(0.0, 0.0, 0.164706) , clamp(length(q), 0.0, 1.0) );
    color = mix( color , vec3(0.666667, 1.0, 1.0) , clamp(abs(r.x), 0.0, 1.0) );
    
    float dist = distance(UV, vec2(0.5));
    
    ALBEDO = vec3(lines(f)) * line_color.rgb;
    
    if (fade(VERTEX, FRAGCOORD)) 
        discard;
}
