#version 450

layout (location = 0) in vec4 v_color;
layout (location = 1) in vec4 v_texcoord;

layout (binding = 1) uniform sampler2D tex;

layout (location = 0) out vec4 FragColor;

void main()
{
  vec2 uv = v_texcoord.xy;
  float t = texture(tex, uv).r;
  FragColor = vec4(t * v_color.rgb, 1.0);
}
