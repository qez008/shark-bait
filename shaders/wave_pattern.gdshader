shader_type spatial;

render_mode cull_back, diffuse_burley, specular_toon;

uniform sampler2D noise_pattern;

uniform vec4 fill_color : hint_color = vec4(vec3(0.1), 1.0);
uniform vec4 line_color : hint_color = vec4(vec3(0.5), 1.0);


// https://www.ronja-tutorials.com/post/026-perlin-noise/
float surf(vec2 uv) {
    float noise = texture(noise_pattern, uv).x;
    noise = fract(noise * 10.0);
    float pixelNoiseChange = fwidth(noise);
    float heightLine = smoothstep(1.0 - pixelNoiseChange, 1.0, noise);
    heightLine += smoothstep(pixelNoiseChange, 0.0, noise);
    
    return heightLine;
}

void fragment() {
    float surf = surf(UV);
    vec4 color = (1.0 - surf) * fill_color + surf * line_color;
    ALBEDO = color.xyz;
//    ALBEDO = texture(noise_pattern, UV).xyz;
}
