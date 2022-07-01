shader_type spatial;
render_mode unshaded;

uniform sampler2D noise;

const float PI = 3.14;

const vec3 bgColorDown = vec3(0.2, 0.1, 0.1);
const vec3 bgColorUp = vec3(0.1, 0.1, 0.2);

const vec3 P1ColorIn = vec3(1.0, 0.5, 0.0);
const vec3 P1ColorOut = vec3(1.0, 0.0, 0.0);

void fragment() {
  vec2 uv = UV * 1.0;

  float curve = 0.1 * sin((100.0 * texture(noise, uv).x * UV.x) + (2.0));// * TIME));

  float lineAShape = smoothstep(1.0 - clamp(abs(curve + fract(uv.y) - 0.5) * 1.0, 0., 1.), 1.0, 0.99);
  vec3  lineACol = (1.0 - lineAShape) * vec3(mix(P1ColorIn, P1ColorOut, lineAShape));

  ALBEDO = vec3(lineACol);
}