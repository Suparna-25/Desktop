

function kx_gl_get_gpu_mem_total()
  local gpu_mem_total = gh_renderer.get_gpu_memory_total_available_kb_nv()
  if (gpu_mem_total <= 0) then
    gpu_mem_total = gh_renderer.get_gpu_memory_total_available_kb_amd()
  end
  return gpu_mem_total
end


function kx_gl_get_gpu_mem_usage()
  local gpu_mem_usage = gh_renderer.get_gpu_memory_usage_kb_nv()
  if (gpu_mem_usage <= 0) then
    gpu_mem_usage = gh_renderer.get_gpu_memory_usage_kb_amd()
  end
  return gpu_mem_usage
end  
  

 


function kx_gl_osi_init()

  local vs_gl2=" \
#version 120 \
uniform mat4 gxl3d_ViewProjectionMatrix; \
uniform mat4 gxl3d_ModelMatrix; \
uniform vec4 gxl3d_Viewport; \
varying vec4 Vertex_UV; \
varying vec4 Vertex_Color; \
void main() \
{ \
  vec4 P = gl_Vertex; \
  vec4 Pw = gxl3d_ModelMatrix * P; \
  Pw.x = Pw.x - gxl3d_Viewport.z/2.0; \
  Pw.y = Pw.y + gxl3d_Viewport.w/2.0; \
  gl_Position = gxl3d_ViewProjectionMatrix * Pw; \
  Vertex_UV = gl_MultiTexCoord0; \
  Vertex_Color = gl_Color; \
}"

  local ps_gl2=" \
#version 120 \
uniform sampler2D tex0; \
varying vec4 Vertex_UV; \
varying vec4 Vertex_Color; \
void main (void) \
{ \
  vec2 uv = Vertex_UV.xy; \
  float t = texture2D(tex0,uv).r; \
  gl_FragColor = vec4(t * Vertex_Color.rgb, 1.0);  \
}"

  local vs_gl32=" \
#version 150 \
in vec4 gxl3d_Position;\
in vec4 gxl3d_TexCoord0;\
in vec4 gxl3d_Color;\
uniform mat4 gxl3d_ViewProjectionMatrix; \
uniform mat4 gxl3d_ModelMatrix; \
uniform vec4 gxl3d_Viewport; \
out vec4 Vertex_UV; \
out vec4 Vertex_Color; \
void main() \
{ \
  vec4 P = gxl3d_Position; \
  vec4 Pw = gxl3d_ModelMatrix * P; \
  Pw.x = Pw.x - gxl3d_Viewport.z/2.0; \
  Pw.y = Pw.y + gxl3d_Viewport.w/2.0; \
  gl_Position = gxl3d_ViewProjectionMatrix * Pw; \
  Vertex_UV = gxl3d_TexCoord0; \
  Vertex_Color = gxl3d_Color; \
}"

  local ps_gl32=" \
#version 150 \
uniform sampler2D tex0; \
in vec4 Vertex_UV; \
in vec4 Vertex_Color; \
out vec4 FragColor; \
void main (void) \
{ \
  vec2 uv = Vertex_UV.xy; \
  float t = texture(tex0,uv).r; \
  FragColor = vec4(t * Vertex_Color.rgb, 1.0);  \
}"

  local vs_gl30=" \
#version 130 \
in vec4 gxl3d_Position;\
in vec4 gxl3d_TexCoord0;\
in vec4 gxl3d_Color;\
uniform mat4 gxl3d_ViewProjectionMatrix; \
uniform mat4 gxl3d_ModelMatrix; \
uniform vec4 gxl3d_Viewport; \
out vec4 Vertex_UV; \
out vec4 Vertex_Color; \
void main() \
{ \
  vec4 P = gxl3d_Position; \
  vec4 Pw = gxl3d_ModelMatrix * P; \
  Pw.x = Pw.x - gxl3d_Viewport.z/2.0; \
  Pw.y = Pw.y + gxl3d_Viewport.w/2.0; \
  gl_Position = gxl3d_ViewProjectionMatrix * Pw; \
  Vertex_UV = gxl3d_TexCoord0; \
  Vertex_Color = gxl3d_Color; \
}"

  local ps_gl30=" \
#version 130 \
uniform sampler2D tex0; \
in vec4 Vertex_UV; \
in vec4 Vertex_Color; \
out vec4 FragColor; \
void main (void) \
{ \
  vec2 uv = Vertex_UV.xy; \
  float t = texture(tex0,uv).r; \
  FragColor = vec4(t * Vertex_Color.rgb, 1.0);  \
}"


  local vs_gles2=" \
attribute vec4 gxl3d_Position;\
attribute vec4 gxl3d_TexCoord0;\
attribute vec4 gxl3d_Color;\
uniform mat4 gxl3d_ViewProjectionMatrix; \
uniform mat4 gxl3d_ModelMatrix; \
uniform vec4 gxl3d_Viewport; \
varying vec4 Vertex_UV; \
varying vec4 Vertex_Color; \
void main() \
{ \
  vec4 P = gxl3d_Position; \
  vec4 Pw = gxl3d_ModelMatrix * P; \
  Pw.x = Pw.x - gxl3d_Viewport.z/2.0; \
  Pw.y = Pw.y + gxl3d_Viewport.w/2.0; \
  gl_Position = gxl3d_ViewProjectionMatrix * Pw; \
  Vertex_UV = gxl3d_TexCoord0; \
  Vertex_Color = gxl3d_Color; \
}"

  local ps_gles2=" \
uniform sampler2D tex0; \
varying highp vec4 Vertex_UV; \
varying highp vec4 Vertex_Color; \
void main (void) \
{ \
  highp vec2 uv = Vertex_UV.xy; \
  highp float t = texture2D(tex0,uv).r; \
  gl_FragColor = vec4(t * Vertex_Color.rgb, 1.0);  \
}"

  local vs = ""
  local ps = ""
  if (gh_renderer.is_opengl_es() == 1) then
    vs = vs_gles2
    ps = ps_gles2
  else
    if (gh_renderer.get_api_version_major() < 3) then
      vs = vs_gl2
      ps = ps_gl2
    else
      if (gh_renderer.get_api_version_major() == 3) then
      if (gh_renderer.get_api_version_minor() < 2) then
        vs = vs_gl30
        ps = ps_gl30
      else
        vs = vs_gl32
        ps = ps_gl32
      end
      end
      if (gh_renderer.get_api_version_minor() > 3) then
        vs = vs_gl32
        ps = ps_gl32
      end
    end
  end
  kx.font_prog = gh_gpu_program.create_v2("kx_font_program", vs, ps)
  

  kx.font_h1 = gh_font.create(kx.framework_dir .. "data/fonts/HACKED.ttf", 30, 512, 512)
  gh_font.build_texture(kx.font_h1)
  kx.font_h1_tex = gh_font.get_texture(kx.font_h1)

  kx.font_p = gh_font.create(kx.framework_dir .. "data/fonts/Hack-Regular.ttf", 18, 512, 512)
  gh_font.build_texture(kx.font_p)
  kx.font_p_tex = gh_font.get_texture(kx.font_p)
  
 
  
  
  
  
  
  
  local tex_vs_gl2=" \
#version 120 \
uniform mat4 gxl3d_ModelViewProjectionMatrix; \
varying vec4 Vertex_UV; \
varying vec4 Vertex_Color; \
void main() \
{ \
  gl_Position = gxl3d_ModelViewProjectionMatrix * gl_Vertex; \
  Vertex_UV = gl_MultiTexCoord0; \
  Vertex_Color = gl_Color; \
}"
  

  local tex_ps_gl2=" \
#version 120 \
uniform sampler2D tex0; \
varying vec4 Vertex_UV; \
varying vec4 Vertex_Color; \
void main (void) \
{ \
  vec2 uv = Vertex_UV.xy; \
  uv.y *= -1.0; \
  vec3 c = texture2D(tex0,uv).rgb; \
  //gl_FragColor = vec4(c * Vertex_Color.rgb, 1.0);  \
  gl_FragColor = vec4(c, 1.0);  \
}"

  local tex_vs_gl32=" \
#version 150 \
in vec4 gxl3d_Position;\
in vec4 gxl3d_TexCoord0;\
in vec4 gxl3d_Color;\
uniform mat4 gxl3d_ModelViewProjectionMatrix; \
out vec4 Vertex_UV; \
out vec4 Vertex_Color; \
void main() \
{ \
  gl_Position = gxl3d_ModelViewProjectionMatrix * gxl3d_Position; \
  Vertex_UV = gxl3d_TexCoord0; \
  Vertex_Color = gxl3d_Color; \
}"
  

  local tex_ps_gl32=" \
#version 150 \
uniform sampler2D tex0; \
in vec4 Vertex_UV; \
in vec4 Vertex_Color; \
out vec4 FragColor; \
void main (void) \
{ \
  vec2 uv = Vertex_UV.xy; \
  uv.y *= -1.0; \
  vec3 c = texture(tex0,uv).rgb; \
  FragColor = vec4(c * Vertex_Color.rgb, 1.0);  \
  //FragColor = vec4(c, 1.0);  \
}"

  local tex_vs_gl30=" \
#version 130 \
in vec4 gxl3d_Position;\
in vec4 gxl3d_TexCoord0;\
in vec4 gxl3d_Color;\
uniform mat4 gxl3d_ModelViewProjectionMatrix; \
out vec4 Vertex_UV; \
out vec4 Vertex_Color; \
void main() \
{ \
  gl_Position = gxl3d_ModelViewProjectionMatrix * gxl3d_Position; \
  Vertex_UV = gxl3d_TexCoord0; \
  Vertex_Color = gxl3d_Color; \
}"
  

  local tex_ps_gl30=" \
#version 130 \
uniform sampler2D tex0; \
in vec4 Vertex_UV; \
in vec4 Vertex_Color; \
out vec4 FragColor; \
void main (void) \
{ \
  vec2 uv = Vertex_UV.xy; \
  uv.y *= -1.0; \
  vec3 c = texture(tex0,uv).rgb; \
  FragColor = vec4(c * Vertex_Color.rgb, 1.0);  \
  //FragColor = vec4(c, 1.0);  \
}"

  local tex_vs_gles2=" \
attribute vec4 gxl3d_Position;\
attribute vec4 gxl3d_TexCoord0;\
attribute vec4 gxl3d_Color;\
uniform mat4 gxl3d_ModelViewProjectionMatrix; \
varying vec4 Vertex_UV; \
varying vec4 Vertex_Color; \
void main() \
{ \
  gl_Position = gxl3d_ModelViewProjectionMatrix * gxl3d_Position; \
  Vertex_UV = gxl3d_TexCoord0; \
  Vertex_Color = gxl3d_Color; \
}"
  

  local tex_ps_gles2=" \
uniform sampler2D tex0; \
varying highp vec4 Vertex_UV; \
varying highp vec4 Vertex_Color; \
void main (void) \
{ \
  highp vec2 uv = Vertex_UV.xy; \
  uv.y *= -1.0; \
  highp vec3 c = texture2D(tex0,uv).rgb; \
  gl_FragColor = vec4(c * Vertex_Color.rgb, 1.0);  \
}"


  vs = ""
  ps = ""
  
  if (gh_renderer.is_opengl_es() == 1) then
    vs = tex_vs_gles2
    ps = tex_ps_gles2
  else
    if (gh_renderer.get_api_version_major() < 3) then
      vs = tex_vs_gl2
      ps = tex_ps_gl2
    else
      if (gh_renderer.get_api_version_major() == 3) then
      if (gh_renderer.get_api_version_minor() < 2) then
        vs = tex_vs_gl30
        ps = tex_ps_gl30
      else
        vs = tex_vs_gl32
        ps = tex_ps_gl32
      end
      end
      if (gh_renderer.get_api_version_minor() > 3) then
        vs = tex_vs_gl32
        ps = tex_ps_gl32
      end
    end
  end
  
  kx.texture_prog = gh_gpu_program.create_v2("kx_texture_prog", vs, ps)
  gh_gpu_program.uniform1i(kx.texture_prog, "tex0", 0)
  
  
  local pixel_format = PF_U8_RGBA
  
  if (gh_renderer.is_opengl_es() == 1) then
    kx.tex_3dapi_logo = gh_texture.create_from_file_v5(kx.framework_dir .. "data/textures/gles.png", pixel_format)
    kx.logo_size.w = 180
    kx.logo_size.h = 62
  else
    kx.tex_3dapi_logo = gh_texture.create_from_file_v5(kx.framework_dir .. "data/textures/gl.png", pixel_format)
    kx.logo_size.w = 150
    kx.logo_size.h = 62
  end
  kx.logo_quad = gh_mesh.create_quad(kx.logo_size.w, kx.logo_size.h)
  
  
  
  
   
  
  
  kx.osi_info.renderer_name = gh_renderer.get_renderer_model()
  kx.osi_info.api_version = gh_renderer.get_api_version()

  kx.osi_info.vram_total = kx_gl_get_gpu_mem_total()
  kx.osi_info.vram_usage = kx_gl_get_gpu_mem_usage()
  
  
  local vsync_interval = gh_renderer.get_vsync()
  if (vsync_interval > 0) then
    kx.osi_info.vsync_status = "vsync: ON"
  else    
    kx.osi_info.vsync_status = "vsync: OFF"
  end
  

end




function kx_gl_osi_display(osi_info)

  gh_camera.bind(kx.camera_ortho)
  
  
  --[[
  local BLEND_FACTOR_ONE = 1
  local BLEND_FACTOR_SRC_ALPHA = 2
  local BLEND_FACTOR_ONE_MINUS_DST_ALPHA = 3
  local BLEND_FACTOR_ONE_MINUS_DST_COLOR = 4
  local BLEND_FACTOR_ONE_MINUS_SRC_ALPHA = 5
  local BLEND_FACTOR_DST_COLOR = 6
  local BLEND_FACTOR_DST_ALPHA = 7
  local BLEND_FACTOR_SRC_COLOR = 8
  local BLEND_FACTOR_ONE_MINUS_SRC_COLOR = 9
  gh_renderer.set_blending_state(1)
  gh_renderer.set_blending_factors(BLEND_FACTOR_ONE, BLEND_FACTOR_ONE)
  --]]

  -- gh_renderer.blending_on("additive")
  gh_renderer.blending_on("") -- defaut is additive: BLEND_FACTOR_ONE + BLEND_FACTOR_ONE

  gh_renderer.set_depth_test_state(0)
--gh_renderer.disable_state("GL_CULL_FACE")


  gh_gpu_program.bind(kx.font_prog)
  
  kx_osi_draw_text(osi_info)  

  
  --gh_renderer.set_blending_factors(BLEND_FACTOR_DST_COLOR, BLEND_FACTOR_ZERO)
  gh_gpu_program.bind(kx.texture_prog)
  gh_texture.bind(kx.tex_3dapi_logo, 0)
  gh_object.set_position(kx.logo_quad, kx.winW/2-kx.logo_size.w/2-10.0, -kx.winH/2+kx.logo_size.h/2+10, 0)
  gh_object.render(kx.logo_quad)

  gh_renderer.blending_off()
  
end



function kx_gl_osi_update(osi_info)
		
  -- nothing to do..
  
end


function kx_gl_osi_render(osi_info)
		
  gh_camera.bind(kx.camera_ortho)
  gh_renderer.blending_on("") -- defaut is additive: BLEND_FACTOR_ONE + BLEND_FACTOR_ONE
  gh_renderer.set_depth_test_state(0)

  gh_gpu_program.bind(kx.font_prog)

  gh_texture.bind(kx.font_h1_tex, 0)
  gh_font.render(kx.font_h1)

  gh_texture.bind(kx.font_p_tex, 0)
  gh_font.render(kx.font_p)
  
  gh_gpu_program.bind(kx.texture_prog)
  gh_texture.bind(kx.tex_3dapi_logo, 0)
  gh_object.set_position(kx.logo_quad, kx.winW/2-kx.logo_size.w/2-10.0, -kx.winH/2+kx.logo_size.h/2+10, 0)
  gh_object.render(kx.logo_quad)

  gh_renderer.blending_off()

 end




