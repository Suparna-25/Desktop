

function InitBkgProg()

  local vs_gl32=" \
#version 150 \
in vec4 gxl3d_Position; \
in vec4 gxl3d_TexCoord0; \
uniform mat4 gxl3d_ModelViewProjectionMatrix; \
uniform vec4 uvtiling; \
out vec4 v_uv; \
void main() \
{	 \
  gl_Position = gxl3d_ModelViewProjectionMatrix * gxl3d_Position; \
  v_uv = gxl3d_TexCoord0 * uvtiling; \
}"

  local ps_gl32=" \
#version 150 \
uniform sampler2D tex0; \
uniform int do_texturing; \
uniform float time; \
uniform vec2 resolution; \
in vec4 v_uv; \
out vec4 FragColor; \
void main(void) \
{ \
  vec2 uv0 = v_uv.xy; \
  uv0.y *= -1.0; \
  vec4 bkgtex = vec4(1.0); \
  if (do_texturing == 1) \
    bkgtex = texture(tex0, uv0); \
  vec2 uv = 4.0 * (gl_FragCoord.xy / resolution.xy) - 3.0; \
  float col=0.0; \
  float i=1.0; \
  vec2 spec = vec2(0.05, 0.40); \
  uv.x += sin(i*20.0 + spec.x*5.0*time*6.0 + uv.y*1.5) * spec.y; \
  col += abs(0.05/uv.x) * spec.y; \
  float a = ((0.1 +  uv.y + 2.0) + 1.0) * 0.5; \
  FragColor = vec4(col + 0.1 * uv.y + 0.2, col + 0.4 * uv.y + 0.2, col + 0.9 * uv.y + 0.2, 1.0) * 0.4 + bkgtex * 0.9; \
  //FragColor = vec4(col + 0.9 * uv.y, col + 0.1 * uv.y, col + 0.1 * uv.y, 1.0) * 0.7; \
}"

  local ps_gl32_tex=" \
#version 150 \
uniform sampler2D tex0; \
uniform int do_texturing; \
uniform float time; \
uniform vec2 resolution; \
in vec4 v_uv; \
out vec4 FragColor; \
void main(void) \
{ \
  vec2 uv = v_uv.xy; \
  //vec4 tcolor = vec4(0.2, 0.2, 0.2, 1.0); \
  vec4 tcolor = vec4(uv.y*0.9, 0.2, 0.2, 1.0); \
  if (do_texturing == 1) \
  { \
    uv.y *= -1.0; \
    tcolor = texture(tex0, uv); \
  } \
  FragColor = tcolor; \
}"


  local vs_gl21=" \
#version 120 \
uniform mat4 gxl3d_ModelViewProjectionMatrix; \
uniform vec4 uvtiling; \
varying vec4 v_uv; \
void main() \
{	 \
  gl_Position = gxl3d_ModelViewProjectionMatrix * gl_Vertex; \
  v_uv = gl_MultiTexCoord0 * uvtiling; \
}"

  local ps_gl21=" \
#version 120 \
uniform sampler2D tex0; \
uniform int do_texturing; \
uniform float time; \
uniform vec2 resolution; \
varying vec4 v_uv; \
void main(void) \
{ \
  vec2 uv0 = v_uv.xy; \
  uv0.y *= -1.0; \
  vec4 bkgtex = vec4(1.0); \
  if (do_texturing == 1) \
    bkgtex = texture2D(tex0, uv0); \
  vec2 uv = 4.0 * (gl_FragCoord.xy / resolution.xy) - 3.0; \
  float col=0.0; \
  float i=1.0; \
  vec2 spec = vec2(0.05, 0.40); \
  uv.x += sin(i*20.0 + spec.x*5.0*time*6.0 + uv.y*1.5) * spec.y; \
  col += abs(0.05/uv.x) * spec.y; \
  float a = ((0.1 +  uv.y + 2.0) + 1.0) * 0.5; \
  gl_FragColor = vec4(col+0.9 * uv.y, col+0.1 * uv.y, col+0.1 * uv.y, 1.0-a*0.25) * 0.4 + bkgtex * 0.9; \
}"

  local ps_gl21_tex=" \
#version 120 \
uniform sampler2D tex0; \
uniform int do_texturing; \
uniform float time; \
uniform vec2 resolution; \
varying vec4 v_uv; \
void main(void) \
{ \
  vec2 uv = v_uv.xy; \
  vec4 tcolor = vec4(uv.y*0.9, 0.2, 0.2, 1.0); \
  if (do_texturing == 1) \
  { \
    uv.y *= -1.0; \
    tcolor = texture2D(tex0, uv); \
  } \
  gl_FragColor = tcolor; \
}"


  local vs_gles2=" \
attribute vec4 gxl3d_Position;\
attribute vec4 gxl3d_TexCoord0;\
uniform mat4 gxl3d_ModelViewProjectionMatrix; \
uniform vec4 uvtiling; \
varying vec4 v_uv; \
void main() \
{	 \
  gl_Position = gxl3d_ModelViewProjectionMatrix * gxl3d_Position; \
  v_uv = gxl3d_TexCoord0 * uvtiling; \
}"

  local ps_gles2=" \
uniform sampler2D tex0; \
uniform int do_texturing; \
uniform highp float time; \
uniform highp vec2 resolution; \
varying highp vec4 v_uv; \
void main(void) \
{ \
  highp vec2 uv0 = v_uv.xy; \
  uv0.y *= -1.0; \
  highp vec4 bkgtex = vec4(1.0); \
  if (do_texturing == 1) \
    bkgtex = texture2D(tex0, uv0); \
  highp vec2 uv = 4.0 * (gl_FragCoord.xy / resolution.xy) - 3.0; \
  highp float col=0.0; \
  highp float i=1.0; \
  highp vec2 spec = vec2(0.05, 0.40); \
  uv.x += sin(i*20.0 + spec.x*5.0*time*6.0 + uv.y*1.5) * spec.y; \
  col += abs(0.05/uv.x) * spec.y; \
  highp float a = ((0.1 +  uv.y + 2.0) + 1.0) * 0.5; \
  gl_FragColor = vec4(col+0.9 * uv.y, col+0.1 * uv.y, col+0.1 * uv.y, 1.0-a*0.25) * 0.4 + bkgtex * 0.9; \
}"

  local ps_gles2_tex=" \
uniform sampler2D tex0; \
uniform int do_texturing; \
uniform highp float time; \
uniform highp vec2 resolution; \
varying highp vec4 v_uv; \
void main(void) \
{ \
  highp vec2 uv = v_uv.xy; \
  highp vec4 tcolor = vec4(uv.y*0.9, 0.2, 0.2, 1.0); \
  if (do_texturing == 1) \
  { \
    uv.y *= -1.0; \
    tcolor = texture2D(tex0, uv); \
  } \
  gl_FragColor = tcolor; \
}"

  local vs = ""
  local ps = ""
  if (gh_renderer.is_opengl_es() == 1) then
    vs = vs_gles2
    ps = ps_gles2
    if (monitoring_mode == 1) then
      ps = ps_gles2_tex
    end
  else
    if (gh_renderer.get_api_version_major() < 3) then
      vs = vs_gl21
      ps = ps_gl21
      if (monitoring_mode == 1) then
        ps = ps_gl21_tex
      end
    else
      vs = vs_gl32
      ps = ps_gl32
      if (monitoring_mode == 1) then
        ps = ps_gl32_tex
      end
    end
  end
  
  --print("vs = " .. vs)
  --print("ps = " .. ps)

  local prog = gh_gpu_program.create_v2("bkg_prog", vs, ps)
  return prog
end






