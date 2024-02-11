

local app_dir = gh_utils.get_app_dir() 		
local demo_dir = gh_utils.get_demo_dir() 		
local lib_dir = gh_utils.get_scripting_libs_dir() 	

dofile(lib_dir .. "lua/imgui.lua")	


_APP_NAME = "GL-Z ROG Edition"
_APP_VERSION = { major=0, minor=4, patch=1, str="0.4.1"}

    

winW, winH = gh_window.getsize(0)



gh_renderer.set_vsync(1)
gh_renderer.set_scissor_state(1)

last_time = gh_utils.get_elapsed_time()



logfilename = app_dir .. "logdata.csv"
logfile = nil


is_gles = gh_renderer.is_opengl_es()


--
-- platform: 
-- 1 = windows
-- 2 = macos
-- 3 = linux
-- 4 = rpi
-- 5 = tinker board
--
function mouse_get_position()
  local mx, my = gh_input.mouse_getpos()
  
  --if (gh_utils.get_platform() == 2) then -- OSX     
  --  local w, h = gh_window.getsize(0)
  --  my = h - my
  --end
    
  if ((is_gles == 1) and (gh_utils.get_platform() == 4)) then -- RPi+GLES
    local w, h = gh_window.getsize(0)
    mx = mx + w/2
    my = -(my - h/2) 
  end
  
  return mx, my
end    






--======================================================================================
-- Background
--======================================================================================

--local filename = demo_dir .. "data/brigitte_by_liang_xing-dc9mi61.jpg"
local filename = background_image
local PF_U8_RGB = 1
local PF_U8_RGBA = 3
local PF_F32_RGBA = 6
local pixel_format = PF_U8_RGBA
local gen_mipmaps = 0
local compressed_texture = 0

render_bkg = 0
bkg_tex = 0

if (filename ~= "") then
  bkg_tex = gh_texture.create_from_file_v6(filename, pixel_format, gen_mipmaps, compressed_texture)

  if (bkg_tex > 0) then
    render_bkg = 1
  end  
end






dofile(demo_dir .. "lua/init_shaders.lua")	
bkg_prog = InitBkgProg()

quad = gh_mesh.create_quad(2, 2)



--======================================================================================
-- ImGui init
--======================================================================================


gh_imgui.init()
imgui_window_hovered = 0


gh_imgui.set_style_colors("dark")


title_bg = {r=0, g=0, b=0, a=0}
title_bg.r, title_bg.g, title_bg.b, title_bg.a = gh_imgui.get_color(IMGUI_TITLE_BG_COLOR)

title_bg_actv = {r=0, g=0, b=0, a=0}
title_bg_actv.r, title_bg_actv.g, title_bg_actv.b, title_bg_actv.a = gh_imgui.get_color(IMGUI_TITLE_BG_ACTIVE_COLOR)

window_bg = {r=0.2, g=0.2, b=0.2, a=1.0}
--window_bg = {r=0, g=0, b=0, a=0}
--window_bg.r, window_bg.g, window_bg.b, window_bg.a = gh_imgui.get_color(IMGUI_WINDOW_BG_COLOR)

  



--[[
gh_imgui.set_color(IMGUI_WINDOW_BG_COLOR, 0.1, 0.1, 0.1, 0.6)
--gh_imgui.set_color(IMGUI_WINDOW_BG_COLOR, 0.8, 0.8, 0.8, 0.25)
gh_imgui.set_color(IMGUI_RESIZE_GRIP_COLOR, 0.1, 0.1, 0.1, 0.0)
gh_imgui.set_color(IMGUI_RESIZE_GRIP_ACTIVE_COLOR, 0.1, 0.1, 0.1, 0.0)

gh_imgui.set_color(IMGUI_TITLE_BG_COLOR, 0.6, 0.3, 0.1, 1.0)
gh_imgui.set_color(IMGUI_TITLE_BG_ACTIVE_COLOR, 0.8, 0.4, 0.2, 1.0)

gh_imgui.set_color(IMGUI_CLOSE_BUTTON_COLOR, 0.4, 0.4, 0.4, 1.0)
gh_imgui.set_color(IMGUI_CLOSE_BUTTON_HOVERED_COLOR, 0.6, 0.6, 0.6, 1.0)
gh_imgui.set_color(IMGUI_CLOSE_BUTTON_ACTIVE_COLOR, 0.8, 0.8, 0.8, 1.0)


gh_imgui.set_color(IMGUI_FRAME_BG_COLOR, 0.5, 0.5, 0.5, 1.0)
gh_imgui.set_color(IMGUI_FRAME_BG_HOVERED_COLOR, 0.6, 0.6, 0.6, 1.0)
gh_imgui.set_color(IMGUI_FRAME_BG_ACTIVE_COLOR, 0.4, 0.6, 0.4, 1.0)

gh_imgui.set_color(IMGUI_BORDER_COLOR, 0.3, 0.3, 0.3, 1.0)

gh_imgui.set_color(IMGUI_POPUP_BG_COLOR, 0.7, 0.7, 0.7, 1.0)

gh_imgui.set_color(IMGUI_CHECK_MARK_COLOR, 0.0, 0.0, 0.0, 1.0)

gh_imgui.set_color(IMGUI_SCROLLBAR_BG_COLOR, 0.7, 0.7, 0.7, 1.0)
gh_imgui.set_color(IMGUI_SCROLLBAR_GRAB_COLOR, 0.5, 0.5, 0.5, 1.0)
gh_imgui.set_color(IMGUI_SCROLLBAR_GRAB_HOVERED_COLOR, 0.5, 0.5, 0.4, 1.0)

gh_imgui.set_color(IMGUI_SEPARATOR_COLOR, 0.6, 0.6, 0.6, 0.5)

gh_imgui.set_color(IMGUI_COLOR_BUTTON, 0.2, 0.1, 0.1, 1.0)
gh_imgui.set_color(IMGUI_COLOR_BUTTON_HOVERED, 0.9, 0.9, 0.3, 1.0)


gh_imgui.set_color(IMGUI_TEXT_COLOR, 1.0, 1.0, 1.0, 1.0)

gh_imgui.set_color(IMGUI_FRAME_BG_COLOR, 0.1, 0.1, 0.0, 1.0)

--]]






--======================================================================================
-- CPU utils - Windows only
--======================================================================================
-- platform: 
-- 1 = windows
-- 2 = macos
-- 3 = linux
-- 4 = rpi
-- 5 = tinker board
--

cpu = {
  display_window = 0,
  info_supported = 0,
  is_linux = 0,
  is_windows = 0,
  is_rpi = 0,
  is_macos=0,
  name = "",
  rpi_hardware = "",
  rpi_core_temp = 0,
  rpi_temp_color_ramp = {
    {r=0.0, g=1.0, b=0.0},  
    {r=0.2, g=1.0, b=0.0}, 
    {r=0.5, g=1.0, b=0.0},
    {r=1.0, g=1.0, b=0.0},
    {r=1.0, g=0.8, b=0.0},
    {r=1.0, g=0.6, b=0.0},
    {r=1.0, g=0.5, b=0.0},
    {r=1.0, g=0.4, b=0.0},
    {r=1.0, g=0.3, b=0.0},
    {r=1.0, g=0.2, b=0.0},
    {r=1.0, g=0.0, b=0.0}
  },
  rpi_temp_file = nil,
  log_data = 0,
  speed=0,
  core_count = 0,
  phys_core_count = 0,
  mem_size = 0,
  usage_supported = 0,
  usage = {},
  linux_cores = {},
  linux_cpu_file = nil,
  overall_usage = 0,
  windows_wmi_initialized = 0, -- WMI initialization is insanely slow...
  wmi_init_done = 0
}



if (gh_utils.get_platform() == 2) then -- OSX     
  cpu.is_macos = 1
end  



if ((gh_utils.get_platform() == 3) or (gh_utils.get_platform() == 4) or (gh_utils.get_platform() == 5)) then
  cpu.is_linux = 1
end  

if (gh_utils.get_platform() == 4) then
  cpu.is_rpi = 1
end  

if (gh_utils.get_platform() == 1)  then
  cpu.is_windows = 1
end  




if (show_cpu_box == 1) then

  if ((cpu.is_windows == 1) or (cpu.is_linux == 1)) then
    cpu.info_supported = 1
    cpu.name = gh_utils.cpu_get_name()
    cpu.speed = gh_utils.cpu_get_speed_mhz()
    cpu.mem_size = gh_utils.cpu_get_mem_size_mb()
  end


  -- Windows platform
  --
  if (cpu.is_windows == 1) then

    if (enable_cpu_usage_on_windows == 1) then
      gh_utils.shared_variable_create("wmi_init_done")
      gh_utils.shared_variable_set_value_4i("wmi_init_done", 0, 0, 0, 0)

      local threaded = 1
      gh_utils.exe_script("wmi", threaded)
    
    else
      cpu.windows_wmi_initialized = 1
    
    end
  end  


  -- Linux or rpi platforms
  --
  if (cpu.is_linux == 1) then

    dofile(demo_dir .. "lua/init_linux_cpu.lua")	

    Linux_CPU_Init(cpu)

    if (cpu.core_count > 0) then
      cpu.usage_supported = 1
    end
    
    RPi_Read_Temperature(cpu)
    
  end  


  if ((cpu.info_supported == 1) or (cpu.usage_supported == 1)) then
    cpu.display_window = 1
  end
end






-- Mouse display on RPi + GLES
--
if ((cpu.is_rpi==1) and (is_gles == 1)) then
  dofile(demo_dir .. "lua/init_mouse_rpi.lua")	
  mouse_init()
end

-- The camera_ortho is used to draw the mouse quad.
--
camera_ortho = gh_camera.create_ortho(-winW/2, winW/2, -winH/2, winH/2, 1.0, 10.0)
gh_camera.set_viewport(camera_ortho, 0, 0, winW, winH)
gh_camera.set_position(camera_ortho, 0, 0, 4)









--======================================================================================
-- OpenGLinfo
--======================================================================================

gl = {
  renderer = "",
  vendor = "",
  version = "",
  max_texture_size=0,
  caps = {},
  cap_index = 0,
  extdb = {},
  num_glext = 0,
  extensions = {},
  num_extensions = 0,
  glx = 0,
  glx_svr_extensions = {},
  glx_svr_num_extensions = 0,
  glx_clt_extensions = {},
  glx_clt_num_extensions = 0,
  glx_version_major = 0,
  glx_version_minor = 0,
  glx_svr_vendor_str = "",
  glx_client_vendor_str = "",
  glx_renderer_vendor_id_str = "",
  glx_renderer_device_id_str = "",
  glx_renderer_vendor_id = 0,
  glx_renderer_device_id = 0,
  glx_renderer_version_major = 0,
  glx_renderer_version_minor = 0,
  glx_renderer_version_patch = 0,
  glx_renderer_accelerated = 0,
  glx_renderer_video_memory = 0,
  glx_renderer_uma = 0
  
  
}


if (show_gl_renderer_box == 1) then

  gl.renderer = gh_renderer.get_renderer_model()
  gl.vendor = gh_renderer.get_renderer_vendor()
  gl.version = gh_renderer.get_api_version()



  if ((gh_utils.get_platform() == 3) or (gh_utils.get_platform() == 4)) then
    gl.glx = 1

    local GLX_RENDERER_ATTRIBUTE_INFO_SVR_VENDOR_STR = 1
    local GLX_RENDERER_ATTRIBUTE_INFO_SVR_VERSION_STR = 2
    local GLX_RENDERER_ATTRIBUTE_INFO_CLIENT_VENDOR_STR = 3
    local GLX_RENDERER_ATTRIBUTE_INFO_CLIENT_VERSION_STR = 4
    local GLX_RENDERER_ATTRIBUTE_INFO_GLX_VERSION_MAJOR = 5
    local GLX_RENDERER_ATTRIBUTE_INFO_GLX_VERSION_MINOR = 6
    local GLX_RENDERER_ATTRIBUTE_INFO_VENDOR_ID = 7
    local GLX_RENDERER_ATTRIBUTE_INFO_DEVICE_ID = 8
    local GLX_RENDERER_ATTRIBUTE_INFO_VENDOR_ID_STR = 9
    local GLX_RENDERER_ATTRIBUTE_INFO_DEVICE_ID_STR = 10
    local GLX_RENDERER_ATTRIBUTE_INFO_VERSION_MAJOR = 11
    local GLX_RENDERER_ATTRIBUTE_INFO_VERSION_MINOR = 12
    local GLX_RENDERER_ATTRIBUTE_INFO_VERSION_PATCH = 13
    local GLX_RENDERER_ATTRIBUTE_INFO_ACCELERATED = 14
    local GLX_RENDERER_ATTRIBUTE_INFO_VIDEO_MEMORY = 15
    local GLX_RENDERER_ATTRIBUTE_INFO_UMA = 16

    gl.glx_version_major = gh_renderer.glx_get_renderer_info_int(GLX_RENDERER_ATTRIBUTE_INFO_GLX_VERSION_MAJOR)
    gl.glx_version_minor = gh_renderer.glx_get_renderer_info_int(GLX_RENDERER_ATTRIBUTE_INFO_GLX_VERSION_MINOR)

    gl.glx_svr_vendor_str = gh_renderer.glx_get_renderer_info_str(GLX_RENDERER_ATTRIBUTE_INFO_SVR_VENDOR_STR)
    gl.glx_client_vendor_str = gh_renderer.glx_get_renderer_info_str(GLX_RENDERER_ATTRIBUTE_INFO_CLIENT_VENDOR_STR)
    
    gl.glx_renderer_vendor_id_str = gh_renderer.glx_get_renderer_info_str(GLX_RENDERER_ATTRIBUTE_INFO_VENDOR_ID_STR)
    gl.glx_renderer_device_id_str = gh_renderer.glx_get_renderer_info_str(GLX_RENDERER_ATTRIBUTE_INFO_DEVICE_ID_STR)
    gl.glx_renderer_vendor_id = gh_renderer.glx_get_renderer_info_int(GLX_RENDERER_ATTRIBUTE_INFO_VENDOR_ID)
    gl.glx_renderer_device_id = gh_renderer.glx_get_renderer_info_int(GLX_RENDERER_ATTRIBUTE_INFO_DEVICE_ID)
    
    gl.glx_renderer_version_major = gh_renderer.glx_get_renderer_info_int(GLX_RENDERER_ATTRIBUTE_INFO_VERSION_MAJOR)
    gl.glx_renderer_version_minor = gh_renderer.glx_get_renderer_info_int(GLX_RENDERER_ATTRIBUTE_INFO_VERSION_MINOR)
    gl.glx_renderer_version_patch = gh_renderer.glx_get_renderer_info_int(GLX_RENDERER_ATTRIBUTE_INFO_VERSION_PATCH)
    
    gl.glx_renderer_accelerated = gh_renderer.glx_get_renderer_info_int(GLX_RENDERER_ATTRIBUTE_INFO_ACCELERATED)
    gl.glx_renderer_video_memory = gh_renderer.glx_get_renderer_info_int(GLX_RENDERER_ATTRIBUTE_INFO_VIDEO_MEMORY)
    gl.glx_renderer_uma = gh_renderer.glx_get_renderer_info_int(GLX_RENDERER_ATTRIBUTE_INFO_UMA)
    
    
    
    
    gl.glx_svr_num_extensions = gh_renderer.glx_get_server_num_extensions()
    for i=1, gl.glx_svr_num_extensions do
      local ename = gh_renderer.glx_get_server_extension(i-1)
      gl.glx_svr_extensions[i] = ename
    end
    
    gl.glx_clt_num_extensions = gh_renderer.glx_get_client_num_extensions()
    for i=1, gl.glx_clt_num_extensions do
      local ename = gh_renderer.glx_get_client_extension(i-1)
      gl.glx_clt_extensions[i] = ename
    end
    
  end



  function ReadGLCap(cap_name)
    x, y, z, w = gh_renderer.get_capability_4i(cap_name)
    local cap = {name=cap_name, cx=x, cy=y, cz=z, cw=w}
    gl.cap_index = gl.cap_index + 1
    gl.caps[gl.cap_index] = cap
  end


  ReadGLCap("GL_MAX_VERTEX_ATTRIBS")
  ReadGLCap("GL_MAX_TEXTURE_SIZE")
  ReadGLCap("GL_MAX_TEXTURE_IMAGE_UNITS")
  ReadGLCap("GL_MAX_COLOR_ATTACHMENTS")
  ReadGLCap("GL_MAX_VIEWPORT_DIMS")
  ReadGLCap("GL_MAX_SAMPLES")
  ReadGLCap("GL_MAX_TESS_GEN_LEVEL")
  ReadGLCap("GL_MAX_PATCH_VERTICES")
  ReadGLCap("GL_MAX_COMPUTE_WORK_GROUP_SIZE")

end








if (show_gl_extensions_box == 1) then

  function GetExtensionVersion(ext_name)
    local i=1
    for i=1, gl.num_glext do
      local ss, ee = string.find(gl.extdb[i], ext_name)
      if (ss ~= nil) then
        return gl.extdb[i]
      end
    end
    return nil
  end

  function IsOpenGL3Extension(ext_name)
    local ss, ee = string.find(ext_name, "OpenGL 3")
    if (ss ~= nil) then
      return 1
    end
    return 0
  end

  function IsOpenGL4Extension(ext_name)
    local ss, ee = string.find(ext_name, "OpenGL 4")
    if (ss ~= nil) then
      return 1
    end
    return 0
  end

  function GetExtensionColor(ext_name)
    local r = 1.0
    local g = 1.0
    local b = 1.0
    local ss = string.find(ext_name, "GL_ARB_")
    if (ss ~= nil) then
      ss = string.find(ext_name, "OpenGL 4.6")
      if (ss ~= nil) then
        r = 1.0
        g = 1.0
        b = 0.2
      else
        ss = string.find(ext_name, "OpenGL 4.5")
        if (ss ~= nil) then
          r = 0.1
          g = 0.8
          b = 1.0
        else
          ss = string.find(ext_name, "OpenGL 4")
          if (ss ~= nil) then
            r = 1.0
            g = 0.8
            b = 0.6      
          else
            ss = string.find(ext_name, "OpenGL 3")
            if (ss ~= nil) then
              r = 1.0
              g = 0.8
              b = 0.6      
            else
              r = 1.0
              g = 1.0
              b = 1.0
            end
          end
        end
      end
    else
      local ss = string.find(ext_name, "GL_EXT_")
      if (ss ~= nil) then
        r = 0.9
        g = 0.9
        b = 1.0
      end
      local ss = string.find(ext_name, "GL_NV_")
      if (ss ~= nil) then
        r = 0.5
        g = 1.0
        b = 0.2
      end
      local ss = string.find(ext_name, "GL_AMD_")
      if (ss ~= nil) then
        r = 1.0
        g = 0.2
        b = 0.0
      end
    end
    return r, g, b
  end  


  -- The gl.ext file contains OpenGL 3 and 4 extensions with 
  -- OpenGL version for each extension.
  --

  print("OpenGL extensions DB loading...")

  local i=1
  local filename = demo_dir .. "data/gl.ext"
  for line in io.lines(filename) do
    gl.extdb[i] = line
    i = i+1
  end
  gl.num_glext = i-1

  print("OpenGL extensions init...")

  -- Loading of all OpenGL extensions exposed by the graphics driver.
  --
  gl.num_extensions = gh_renderer.get_num_opengl_extensions()
  for i=1, gl.num_extensions do
    local ename = gh_renderer.get_opengl_extension(i-1)
    
    -- If the extension name has an OpenGL version description, 
    -- update the extension name.
    --
    local ext_name = GetExtensionVersion(ename)
    if (ext_name == nil) then
      ext_name = ename
    end
    gl.extensions[i] = ext_name
  end

  print("OpenGL extensions init OK.")

end









--======================================================================================
-- Vulkan info
--======================================================================================


function GetNewVKGPU()
  local gpu = {
    name = "",
    device_type = 0,
    device_type_str = "",
    device_id = 0,
    vendor_id = 0,
    api_version_major = 0,
    api_version_minor = 0,
    api_version_patch = 0,
    num_extensions = 0,
    extensions = {},
    num_layers = 0,
    layers = {},
    num_heaps = 0,
    heaps = {}
  }
  
  return gpu
end


vk = {
  inst_extensions = {},
  num_inst_extensions = 0,
  inst_layers = {},
  num_inst_layers = 0,
  gpus = {},
  num_gpus = 0
}

function VKGetDeviceTypeStr(devtype)
  if (devtype == 1) then
    return "VK_PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU"
  elseif (devtype == 2) then
    return "VK_PHYSICAL_DEVICE_TYPE_DISCRETE_GPU"
  elseif (devtype == 3) then
    return "VK_PHYSICAL_DEVICE_TYPE_VIRTUAL_GPU"
  elseif (devtype == 4) then
    return "VK_PHYSICAL_DEVICE_TYPE_CPU"
  end
  return "VK_PHYSICAL_DEVICE_TYPE_OTHER" -- 0
end  





if (show_vk_instance_box == 1) then
  print("Vulkan instance init...")

  vk.num_inst_extensions = gh_renderer.vk_instance_get_num_extensions()
  for i=1, vk.num_inst_extensions do
    local name = gh_renderer.vk_instance_get_extension_name(i-1)
    vk.inst_extensions[i] = name
  end  

  vk.num_inst_layers = gh_renderer.vk_instance_get_num_layers()
  for i=1, vk.num_inst_layers do
    local name = gh_renderer.vk_instance_get_layer_name(i-1)
    vk.inst_layers[i] = name
  end  

end



if (show_vk_devices_box == 1) then

  vk.num_gpus = gh_renderer.vk_get_num_gpus()
  for i=1, vk.num_gpus do
    local gpu = GetNewVKGPU()
    vk.gpus[i] = gpu
    gpu.name = gh_renderer.vk_gpu_get_name(i-1)
    gpu.device_type = gh_renderer.vk_gpu_get_device_type(i-1)
    gpu.device_type_str = VKGetDeviceTypeStr(gpu.device_type)
    gpu.vendor_id, gpu.device_id = gh_renderer.vk_gpu_get_device_id(i-1)
    gpu.api_version_major, gpu.api_version_minor, gpu.api_version_patch = gh_renderer.vk_gpu_get_api_version(i-1)
    gpu.num_extensions = gh_renderer.vk_gpu_get_num_extensions(i-1)
    for j=1, gpu.num_extensions do
      local ename = gh_renderer.vk_gpu_get_extension_name(i-1, j-1)
      gpu.extensions[j] = ename
    end
    gpu.num_layers = gh_renderer.vk_gpu_get_num_layers(i-1)
    for j=1, gpu.num_layers do
      local lname = gh_renderer.vk_gpu_get_layer_name(i-1, j-1)
      gpu.layers[j] = lname
    end
    gpu.num_heaps = gh_renderer.vk_gpu_get_num_memory_heaps(i-1)
    for j=1, gpu.num_heaps do
      local size = gh_renderer.vk_gpu_get_heap_size(i-1, j-1)
      gpu.heaps[j] = size
    end
    
  end  

end





--======================================================================================
-- GPU monitoring 
--======================================================================================

print("GPU monitoring init...")


do_gpu_monitoring = 0
gpu_monitoring_supported = 0


function GetNewGMLGPU()
  local gpu = {
    name = "",
    codename = "",
    driver = "",
    cores = 0,
    tmus = 0,
    rops = 0,
    device_id = 0,
    vendor_id = 0,
    subdevice_id = 0,
    subvendor_id = 0,
    core_clock = 0,
    mem_clock = 0,
    core_temp = 0,
    core_usage = 0,
    power_target = 0,
    power = 0,
    plotline_index = -1,
    plotline_max_values = 64,
    plotline_cur_pos = 0,
    core_temp_values = {},
    core_temp_num_values = 0,
    values_count = 0
  }
  
  return gpu
end


gml = {
  num_gpus = 0,
  gpus = {}


}




if (show_gpu_box == 1) then
  -- get_gpu_config is available in GeeXLab 0.23.1+
  --
  if (_G["gh_gml"]["get_gpu_config"] ~= nil) then

    gml.num_gpus = gh_gml.get_num_gpus()
    for i=1, gml.num_gpus do
      local gpu = GetNewGMLGPU()
      gml.gpus[i] = gpu
      gpu.name = gh_gml.get_gpu_fullname(i-1)
      gpu.codename = gh_gml.get_gpu_codename(i-1)
      gpu.driver = gh_gml.get_gpu_driver(i-1)
      gpu.core_clock, gpu.mem_clock = gh_gml.get_clocks(i-1)
      gpu.cores, gpu.tmus, gpu.rops = gh_gml.get_gpu_config(i-1)
      gpu.vendor_id, gpu.device_id, gpu.subvendor_id, gpu.subdevice_id = gh_gml.get_pci_identifiers(i-1)
      gpu.core_temp = gh_gml.get_temperatures(i-1)
      gpu.core_usage = gh_gml.get_usages(i-1)
      gpu.power_target = gh_gml.gpu_power_get_power_limit(i-1)
      gpu.plotline_index = gh_imgui.plotline_create("##plotline::gpu"..i, gpu.plotline_max_values)
      
      
      -- GPU monitoring on Windows or Linux and on GeForce or Radeon.
      --
      if ((cpu.is_windows == 1) or (cpu.is_linux == 1)) then
  			if ((gpu.vendor_id==4318) or (gpu.vendor_id==4098)) then
  				do_gpu_monitoring = 1
  				gpu_monitoring_supported = 1
  			end
  		end
    end

  end
end


hw_polling_interval = 1.0 -- in seconds
lastime_hw_polling = 0




function ExportData()
  local filename = app_dir .. "glz_export.txt"

  if (cpu.is_macos == 1) then
    filename = demo_dir .. "../glz_export.txt"
  end  

  local file = io.open(filename, "w+")
  
  file:write("\n======================================================")
  file:write(string.format("\n%s %d.%d.%d", _APP_NAME, _APP_VERSION.major, _APP_VERSION.minor, _APP_VERSION.patch))
  file:write("\nwww.geeks3d.com/glz/")
  file:write("\n======================================================")
  file:write("\n\n")
  
  
  if (cpu.is_linux == 1) then
    file:write("\n======================================================")
    file:write("\nCPU")
    file:write("\n======================================================")
    file:write("\n- CPU: " .. cpu.name)
    if (cpu.is_rpi == 1) then
      file:write("\n- SoC: " .. cpu.rpi_hardware)
      file:write("\n- temperature: " .. cpu.rpi_core_temp .. "°C")
    end
    file:write("\n- cores: " .. cpu.core_count)
  end

  if (cpu.is_windows == 1) then
    file:write("\n======================================================")
    file:write("\nCPU")
    file:write("\n======================================================")
    file:write("\n- CPU: " .. cpu.name)
    file:write(string.format("\n- cores: %dC/%dT", cpu.phys_core_count, cpu.core_count))
    file:write("\n- speed: " .. cpu.speed .. " MHz")
    file:write("\n- memory: " .. cpu.mem_size .. "MB")
  end
  
  
  if (gml.num_gpus > 0) then
    file:write("\n======================================================")
    file:write("\nGPU")
    file:write("\n======================================================")
    for i=1, gml.num_gpus do
      local gpu = gml.gpus[i]
      file:write("\n------------------------------")
      file:write(string.format("\n- GPU %d: %s", i, gpu.name))
      file:write(string.format("\n- codename: %s", gpu.codename))
      file:write(string.format("\n- deviceID: %4X-%4X", gpu.vendor_id, gpu.device_id))
      if (cpu.is_macos == 0) then
        file:write(string.format("\n- config (cores/TMUs/ROPs): %d/%d/%d", gpu.cores, gpu.tmus, gpu.rops))
        file:write(string.format("\n- driver: %s", gpu.driver))
      end
      if (gpu.power_target > 0) then
        file:write("\n- power target: " .. gpu.power_target .. " %% TDP")
      end
    end
  end
  
  
 
  
  
  file:write("\n======================================================")
  file:write("\nOpenGL")
  file:write("\n======================================================")
  file:write("\n- GL_RENDERER: " .. gl.renderer)
  file:write("\n- GL_VENDOR: " .. gl.vendor)
  file:write("\n- GL_VERSION: " .. gl.version)
  for i=1, gl.cap_index do
    local cap = gl.caps[i]
    local str = string.format("- %s: %d", cap.name, cap.cx)
    file:write("\n" .. str)
  end

  file:write("\n---------------------------------")
  file:write(string.format("\n- # of OpenGL extensions: %d", gl.num_extensions))
  for i=1, gl.num_extensions do
    local ext_name = gl.extensions[i]
    file:write(string.format("\n  %03d/ %s", i, ext_name))
  end


  if (gl.glx == 1) then
    file:write("\n---------------------------------")
    file:write(string.format("\n- GLX_VERSION: %d.%d", gl.glx_version_major, gl.glx_version_minor))
    
    file:write(string.format("\n- GLX_VENDOR server: %s", gl.glx_svr_vendor_str))
    file:write(string.format("\n- GLX_VENDOR client: %s", gl.glx_client_vendor_str))
    
    file:write(string.format("\n- GLX_RENDERER_VENDOR_ID_MESA: %s (0x%4X)", gl.glx_renderer_vendor_id_str, gl.glx_renderer_vendor_id))
    file:write(string.format("\n- GLX_RENDERER_DEVICE_ID_MESA: %s (0x%4X)", gl.glx_renderer_device_id_str, gl.glx_renderer_device_id))
    
    file:write(string.format("\n- GLX_RENDERER_VERSION_MESA: %d.%d.%d", gl.glx_renderer_version_major, gl.glx_renderer_version_minor, gl.glx_renderer_version_patch))
    file:write(string.format("\n- GLX_RENDERER_ATTRIBUTE_INFO_ACCELERATED: %d", gl.glx_renderer_accelerated))
    file:write(string.format("\n- GLX_RENDERER_ATTRIBUTE_INFO_VIDEO_MEMORY: %d MB", gl.glx_renderer_video_memory))
    file:write(string.format("\n- GLX_RENDERER_ATTRIBUTE_INFO_UMA: %d", gl.glx_renderer_uma))

    file:write("\n---------------------------------")
    file:write(string.format("\n- # of GXL server extensions: %d", gl.glx_svr_num_extensions))
    for i=1, gl.glx_svr_num_extensions do
      local ext_name = gl.glx_svr_extensions[i]
      file:write(string.format("\n  %03d/ %s", i, ext_name))
    end
    
    file:write("\n---------------------------------")
    file:write(string.format("\n- # of GXL client extensions: %d", gl.glx_clt_num_extensions))
    for i=1, gl.glx_clt_num_extensions do
      local ext_name = gl.glx_clt_extensions[i]
      file:write(string.format("\n  %03d/ %s", i, ext_name))
    end
    
  end
  
  
  
  if (vk.num_inst_extensions > 0) then
  
    file:write("\n======================================================")
    file:write("\nVulkan Instance")
    file:write("\n======================================================")

    file:write(string.format("\n- # of extensions: %d", vk.num_inst_extensions))
    for i=1, vk.num_inst_extensions do
      local ext_name = vk.inst_extensions[i]
      file:write(string.format("\n  %03d/ %s", i, ext_name))
    end

    file:write(string.format("\n- # of layers: %d", vk.num_inst_layers))
    for i=1, vk.num_inst_layers do
      local ext_name = vk.inst_layers[i]
      file:write(string.format("\n  %03d/ %s", i, ext_name))
    end
  
  end
  
  
  if (vk.num_gpus > 0) then
  
    for i=1, vk.num_gpus do
      local gpu = vk.gpus[i]
  
      file:write("\n---------------------------------")
      file:write(string.format("\nVulkan physical device (GPU) %d", i))
      file:write("\n---------------------------------")
     
      file:write("\n- name: " .. gpu.name)
      file:write("\n- type: " .. gpu.device_type_str)
      file:write(string.format("\n- deviceID: %4X-%4X", gpu.vendor_id, gpu.device_id))
      file:write(string.format("\n- API version: %d.%d.%d", gpu.api_version_major, gpu.api_version_minor, gpu.api_version_patch))
      
      file:write("\n---------------------------------")
      file:write(string.format("\n- # of memory heaps: %d", gpu.num_heaps))
      for j=1, gpu.num_heaps do
        local size = gpu.heaps[j]
        file:write(string.format("\n  heap %d - size %d MB", j, size))
      end
      
      file:write("\n---------------------------------")
      file:write(string.format("\n- # of extensions: %d", gpu.num_extensions))
      for j=1, gpu.num_extensions do
        local ext_name = gpu.extensions[j]
        file:write(string.format("\n  %03d/ %s", j, ext_name))
      end
      
      file:write("\n---------------------------------")
      file:write(string.format("\n# of layers: %d", gpu.num_layers))
      for j=1, gpu.num_layers do
        local layer_name = gpu.layers[j]
        file:write(string.format("\n  %03d/ %s", j, layer_name))
      end

    end
  
  end
  
  
  file:close()
end



function WriteCredits(uptimestr)
  gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)
  gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)
  
  gh_imgui.text_rgba("Uptime: " .. uptimestr, 0.5, 0.5, 0.5, 1.0)
  
  gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)
  gh_imgui.text_rgba(string.format("%s v%d.%d.%d", _APP_NAME, _APP_VERSION.major, _APP_VERSION.minor, _APP_VERSION.patch), 0.5, 0.5, 0.5, 1.0)
  gh_imgui.text_rgba("www.geeks3d.com/glz/", 0.5, 0.5, 0.5, 1.0)
  gh_imgui.text_rgba(string.format("(C)2018 Geeks3D - @Geeks3D"), 0.5, 0.5, 0.5, 1.0)
end



print("init.lua OK.")



