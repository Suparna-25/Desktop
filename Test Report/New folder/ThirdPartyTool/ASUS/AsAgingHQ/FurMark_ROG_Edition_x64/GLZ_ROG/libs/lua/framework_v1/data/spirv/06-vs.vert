#version 450

#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable


struct ObjectData
{ 
  mat4 ModelMatrix;
};

layout (std140, binding = 0) uniform uniforms_t
{ 
  vec4 Viewport;
  mat4 ViewProjectionMatrix;
  ObjectData T[2];
} ub;


layout (location = 0) in vec4 vposition;
layout (location = 1) in vec4 vtexcoord;
layout (location = 2) in vec4 vnormal;
layout (location = 3) in vec4 vcolor;

layout (location = 0) out vec4 v_color;
layout (location = 1) out vec4 v_texcoord;

out gl_PerVertex 
{
  vec4 gl_Position;
  
};

void main()
{

  vec4 P = vposition;
  vec4 Pw = ub.T[0].ModelMatrix * P;
  Pw.x = Pw.x - ub.Viewport.z/2;
  Pw.y = Pw.y + ub.Viewport.w/2;
  gl_Position = ub.ViewProjectionMatrix * Pw;		
  
  // GL->VK conventions
  gl_Position.y = -gl_Position.y;
  gl_Position.z = (gl_Position.z + gl_Position.w) / 2.0;
  
  v_color = vcolor;
  v_texcoord = vtexcoord;
}
