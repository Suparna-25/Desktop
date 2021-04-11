--[[
Quick tutorial:

- In the INIT script: 

local lib_dir = gh_utils.get_scripting_libs_dir()     
dofile(lib_dir .. "lua/libfont/libfont1.lua")    


- In the FRAME script:

libfont_clear()
libfont_print(20, 20, 1, 1, 0, 1, "Hello in Yellow")
libfont_print(20, 40, 1, 0, 0, 1, "Hello in Red")
libfont_render()
--]]



_libfont_initialized = 0
_libfont_font = 0
_libfont_texture = 0
_libfont_camera_ortho = 0
_libfont_gpu_program = 0


function _libfont_init_gpu_program()
  if (_libfont_gpu_program > 0) then
    return
  end
  
  local vs_gl3=" \
  in vec4 gxl3d_Position; \
  in vec4 gxl3d_TexCoord0; \
  in vec4 gxl3d_Color; \
  uniform mat4 gxl3d_ModelViewProjectionMatrix; \
  uniform vec4 gxl3d_Viewport; \
  out vec4 Vertex_UV; \
  out vec4 Vertex_Color; \
  void main() \
  { \
    vec4 V = vec4(gxl3d_Position.xyz, 1); \
    V.x = V.x - gxl3d_Viewport.z / 2.0; \
    V.y = V.y + gxl3d_Viewport.w / 2.0; \
    gl_Position = gxl3d_ModelViewProjectionMatrix * V; \
    Vertex_UV = gxl3d_TexCoord0; \
    Vertex_Color = gxl3d_Color; \
  }"
    
  local ps_gl3=" \
  uniform sampler2D tex0; \
  in vec4 Vertex_UV; \
  in vec4 Vertex_Color; \
  out vec4 FragColor; \
  void main (void) \
  { \
    vec2 uv = Vertex_UV.xy; \
    float t = texture(tex0,uv).r; \
    FragColor = vec4(t * Vertex_Color.rgb, Vertex_Color.a * t); \
  }"
    
  local vs_gl2=" \
  #version 120 \
  attribute vec4 gxl3d_Position; \
  attribute vec4 gxl3d_TexCoord0; \
  attribute vec4 gxl3d_Color; \
  uniform mat4 gxl3d_ModelViewProjectionMatrix; \
  uniform vec4 gxl3d_Viewport; \
  varying vec4 Vertex_UV; \
  varying vec4 Vertex_Color; \
  void main() \
  { \
    vec4 V = vec4(gxl3d_Position.xyz, 1); \
    V.x = V.x - gxl3d_Viewport.z / 2.0; \
    V.y = V.y + gxl3d_Viewport.w / 2.0; \
    gl_Position = gl_ModelViewProjectionMatrix * V;		 \
    Vertex_UV = gxl3d_TexCoord0; \
    Vertex_Color = gxl3d_Color; \
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
    gl_FragColor = vec4(t * Vertex_Color.rgb, Vertex_Color.a * t); \
  }"
  
  
  
  local vs_gles2=" \
  attribute vec4 gxl3d_Position; \
  attribute vec4 gxl3d_TexCoord0; \
  attribute vec4 gxl3d_Color; \
  uniform mat4 gxl3d_ModelViewProjectionMatrix; \
  uniform vec4 gxl3d_Viewport; \
  varying vec4 Vertex_UV; \
  varying vec4 Vertex_Color; \
  void main() \
  { \
    vec4 V = vec4(gxl3d_Position.xyz, 1.0); \
    V.x = V.x - gxl3d_Viewport.z / 2.0; \
    V.y = V.y + gxl3d_Viewport.w / 2.0; \
    gl_Position = gxl3d_ModelViewProjectionMatrix * V;		 \
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
    gl_FragColor = vec4(t * Vertex_Color.rgb, Vertex_Color.a * t); \
  }"
  
  if ((gh_utils.get_platform() == 4) and (gh_renderer.is_opengl_es() == 1)) then
    -- Raspberry Pi
    _libfont_gpu_program = gh_gpu_program.create_v2("libfont_gpu_program",vs_gles2, ps_gles2)
  else
    local vs = ""
    local ps = ""
    if (gh_renderer.get_api_version_major() > 3) then
      vs = "#version 150\n" .. vs_gl3
      ps = "#version 150\n" .. ps_gl3
      _libfont_gpu_program = gh_gpu_program.create_v2("libfont_gpu_program", vs, ps)
    
    elseif (gh_renderer.get_api_version_major() == 3) then
    
      if (gh_renderer.is_opengl_es() == 1) then
          vs = vs_gles2
          ps = ps_gles2
      else
        if (gh_renderer.get_api_version_minor() < 2) then
          vs = "#version 130\n" .. vs_gl3
          ps = "#version 130\n" .. ps_gl3
        else
          vs = "#version 150\n" .. vs_gl3
          ps = "#version 150\n" .. ps_gl3
        end
      end
      _libfont_gpu_program = gh_gpu_program.create_v2("libfont_gpu_program", vs, ps)
    else
      _libfont_gpu_program = gh_gpu_program.create_v2("libfont_gpu_program", vs_gl2, ps_gl2)
    end
  end

  gh_gpu_program.uniform1i(_libfont_gpu_program, "tex0", 0)



end  


function _libfont_init()
  if (_libfont_initialized == 0) then
    _libfont_init_gpu_program()

    local win_w, win_h = gh_window.getsize(0)
    _libfont_camera_ortho = gh_camera.create_ortho(-win_w/2, win_w/2, -win_h/2, win_h/2, 1.0, 10.0)
    gh_camera.set_viewport(_libfont_camera_ortho, 0, 0, win_w, win_h)
    gh_camera.set_position(_libfont_camera_ortho, 0, 0, 4)
    gh_camera.set_lookat(_libfont_camera_ortho, 0, 0, 0, 1)


    local lib_dir = gh_utils.get_scripting_libs_dir()     
    _libfont_font = gh_font.create(lib_dir .. "lua/libfont/roboto/Roboto-Regular.ttf", 20, 512, 512)
    gh_font.build_texture(_libfont_font)
    _libfont_texture = gh_font.get_texture(_libfont_font)


    _libfont_initialized = 1
  end
end


--[[
-- libfont_kill is not necessary.
--
function libfont_kill()
  if (_libfont_font > 0) then
    gh_utils.ftgl_font_kill(_libfont_font)
  end
end
--]]



function _libfont_resize(w, h)
  gh_camera.update_ortho(_libfont_camera_ortho, -w/2, w/2, -h/2, h/2, 1.0, 10.0)
  gh_camera.set_viewport(_libfont_camera_ortho, 0, 0, w, h)
end


function libfont_get_text_width(text)
  _libfont_init()
  return gh_font.get_text_width(_libfont_font, text)
end  


function libfont_clear()
  _libfont_init()
  gh_font.clear(_libfont_font)
end  

function libfont_print(x, y, r, g, b, a, text)
  _libfont_init()
  gh_font.text_2d(_libfont_font, x, y, r, g, b, a, text)
end  

function libfont_render()
  _libfont_init()

  gh_renderer.set_depth_test_state(0)
  gh_renderer.blending_on("") -- defaut is additive: BLEND_FACTOR_ONE + BLEND_FACTOR_ONE

  local win_w, win_h = gh_window.getsize(0)
  _libfont_resize(win_w, win_h)

  gh_camera.bind(_libfont_camera_ortho)
  gh_gpu_program.bind(_libfont_gpu_program)
  gh_texture.bind(_libfont_texture, 0)

  gh_font.update(_libfont_font, 0)
  gh_font.render(_libfont_font)

  gh_renderer.blending_off()
  gh_renderer.set_depth_test_state(1)
end
