
--[[

Version 0.1.7 - 2018.01.02
-------------------------------
! added OpenGL ES 2 support.
  Details in kx_gl.lua
  

Version 0.1.6 - 2017.09.09
-------------------------------
! GPU monitoring is only enabled on Windows.
  Details in kx_init_begin().


Version 0.1.5 - 2017.07.20
-------------------------------
! updated kx_vk_command_buffer_exe() by removing the call to 
  vk_command_list_pipeline_barrier().


  Version 0.1.4 - 2017.06.29
-------------------------------
* fixed a bug in kx_osi_draw_text(): the kx_gl_get_gpu_mem_usage() function
  was called with a Vulkan renderer. 


Version 0.1.3 - 2017.06.17
-------------------------------
* fixed a bug in kx_vk_resize(): the GPU buffer update was missing. 


Version 0.1.2
----------------
+ added support for Vulkan baked command buffers
   by decouplig OSI update and rendering phases.

  
Version 0.1.1
----------------
- fixed a bug in kx_resize (winW
  and winH were not updated)


--]]

------------------------------------------------------------------------------
--

-- widely used variables in GeeXLab demos...
winW = 0
winH = 0


kx = {
    winW = 0,
    winH = 0,
    
    version = {major=0, minor=1, patch=7},
    
    user_texts = {},
    user_texts_index = 0,
    
    renderer_type = 1, -- opengl
    api_name = "OpenGL",
    
    framework_dir = "",
    
    is_key_down = 0,
    do_animation = 1,
    display_osi = 1,
    
    time_animation_toggle_key = 25, -- KC_P
    osi_toggle_key = 23, -- KC_I 
        
    camera = 0,
    camera_fov = 60.0,
    camera_znear = 1.0,
    camera_zfar = 1000.0,    

    camera_ortho = 0,
    
    elapsed_time = 0.0,
    elapsed_time2 = 0.0,
    last_time = 0.0,
    frame_time = 0.0,
    frame_time2 = 0.0,
    fps_time = 0.0,
    fps_frames = 0.0,
    fps = 0,
    
    num_gpus = 0,
    gpumon_interval = 1.0,
    gpumon_last_time = 0.0,
    
    font_prog = 0,
    font_h1 = 0,
    font_h1_tex = 0,
    font_p = 0,
    font_p_tex = 0,
    
    texture_prog = 0,
    tex_3dapi_logo = 0,
    logo_size = {w=0, h=0},
    logo_quad = 0,
    
    cmdbuffer = 0,
    ub0 = 0, --vulkan
    sampler = 0,
    ds_font_p = 0,
    ds_font_h1 = 0,
    pso_font_p = 0,
    pso_font_p_valid = 0,
    pso_font_h1 = 0,
    pso_font_h1_valid = 0,
    ds_tex = 0,
    pso_tex = 0,
    pso_tex_valid = 0,
    
    osi_info = nil,
}



function kx_init_osi_info()
  local info = {demo_caption="",
                 renderer_name="", 
                 api_version="", 
                 vram_total=0, 
                 vram_usage=0, 
                 frames=0, 
                 fps=0, 
                 dt_ms=0, 
                 elapsed_time=0, 
                 gpu_load_avg=0, 
                 gpu_load_min=100, 
                 gpu_load_max=0, 
                 gpu_load_last=0, 
                 gpu_load_counter=0, 
                 gpu_load_sum=0, 
                 gpu_temp=0,
                 vsync_status = ""
                }

  kx.osi_info = info
end  


------------------------------------------------------------------------------
--
function kx_init_begin(framework_dir)

  dofile(framework_dir .. "common_defines.lua")
  
  kx.renderer_type = gh_renderer.get_type()
  
  kx_init_osi_info()
  
  kx.framework_dir = framework_dir

  winW, winH =  gh_window.getsize(0)
  kx.winW = winW
  kx.winH = winH

  kx.camera = kx_camera_create(kx.winW, kx.winH, kx.camera_fov, kx.camera_znear, kx.camera_zfar)
  kx.camera_ortho = kx_camera_ortho_create_v1(kx.winW, kx.winH)
  
  kx.elapsed_time = gh_utils.get_elapsed_time()
  kx.last_time = kx.elapsed_time
  
    
  local platform_windows = 1 
  --local platform_osx = 2 
  --local platform_linux = 3 
  --local platform_rpi = 4 
  if (gh_utils.get_platform() == platform_windows) then
    -- On Linux, there are some jumps every second caused by 
    -- gh_gml.update(). The GPU monitoring works fine on Windows only
    -- that's why it's enabled on this platform.
    -- If kx.num_gpus > 0, the GPU monitoring is enabled.
    --
	kx.num_gpus = gh_gml.get_num_gpus()
  end

  dofile(framework_dir .. "kx_common_func.lua")
 
  if (kx.renderer_type == RENDERER_OPENGL) then
    kx.api_name = "OpenGL"
    dofile(framework_dir .. "kx_gl.lua")
    kx_gl_osi_init()
    gh_renderer.set_depth_test_state(1)

  elseif (kx.renderer_type == RENDERER_VULKAN) then
    kx.api_name = "Vulkan"
    dofile(framework_dir .. "kx_vk.lua")
    kx_vk_init_begin()
    kx_vk_osi_init()  
    kx_vk_init_end()

  elseif (kx.renderer_type == RENDERER_DIRECT3D_12) then
    kx.api_name = "Direct3D 12"
  -- TODO
  end
  
  
  
  -- Default caption/title.
  kx.osi_info.demo_caption = kx.api_name .. " demo"
  
  gh_renderer.set_vsync(0)
  
  
end



------------------------------------------------------------------------------
--
function kx_init_end()
  -- print("kx_init_end() ok")
end







------------------------------------------------------------------------------
--
function kx_get_version()
  return kx.version.major, kx.version.minor, kx.version.patch
end




------------------------------------------------------------------------------
--
function kx_get_api_name()
  return kx.api_name
end  



------------------------------------------------------------------------------
--
function kx_set_main_title(title)
  kx.osi_info.demo_caption = title
end  



------------------------------------------------------------------------------
--
function kx_frame_begin(r, g, b)

  local elapsed_time = gh_utils.get_elapsed_time()
  kx_update_time(elapsed_time)
  
  kx_reset_text()
  
  if (kx.renderer_type == RENDERER_OPENGL) then
    gh_renderer.clear_color_depth_buffers(r, g, b, 1.0, 1.0)

  elseif (kx.renderer_type == RENDERER_VULKAN) then
    kx_vk_frame_begin(r, g, b)  

  --elseif (kx.renderer_type == RENDERER_DIRECT3D_12) then
    -- TODO
  end
  
end

------------------------------------------------------------------------------
--
function kx_frame_end(display_osi)

  if (display_osi == 1) then
    if (kx.renderer_type == RENDERER_OPENGL) then
      kx_gl_osi_display(kx.osi_info)  
    
    elseif (kx.renderer_type == RENDERER_VULKAN) then
      kx_vk_osi_display(kx.osi_info)  
    
    --elseif (kx.renderer_type == RENDERER_DIRECT3D_12) then
      -- TODO
    end
  end

  
  if (kx.renderer_type == RENDERER_VULKAN) then
      kx_vk_frame_end()      

  --elseif (kx.renderer_type == RENDERER_DIRECT3D_12) then
  -- TODO
  end

end






------------------------------------------------------------------------------
--
function kx_frame_begin_v2()

  local elapsed_time = gh_utils.get_elapsed_time()
  kx_update_time(elapsed_time)
  
  kx_reset_text()
  
end


------------------------------------------------------------------------------
--
function kx_frame_end_v2()


end




------------------------------------------------------------------------------
--
function kx_osi_update()

  kx_osi_update_text(kx.osi_info)  
  
  if (kx.renderer_type == RENDERER_OPENGL) then
    kx_gl_osi_update(kx.osi_info)
  
  elseif (kx.renderer_type == RENDERER_VULKAN) then
    kx_vk_osi_update(kx.osi_info)
  end
   
 end
  


------------------------------------------------------------------------------
--
function kx_osi_render()

    if (kx.renderer_type == RENDERER_OPENGL) then
      kx_gl_osi_render(kx.osi_info)  
    
    elseif (kx.renderer_type == RENDERER_VULKAN) then
      kx_vk_osi_render(kx.osi_info)  
    
    end

 end





------------------------------------------------------------------------------
--
function kx_update_time(elapsed_time)
  local dt = elapsed_time - kx.last_time
  kx.last_time = elapsed_time
  local dt_ms = dt * 1000.0
  kx.elapsed_time = kx.elapsed_time + dt
  kx.frame_time = dt
  kx.frame_time2 = dt

  kx.fps_time = kx.fps_time + dt
  if (kx.fps_time >= 1.0) then
    kx.fps_time = 0.0
    kx.fps = kx.fps_frames
    kx.fps_frames = 0
    kx.osi_info.fps = kx.fps
  end
  
  kx.fps_frames = kx.fps_frames + 1
  kx.osi_info.frames = kx.osi_info.frames + 1
  kx.osi_info.elapsed_time = elapsed_time
  kx.osi_info.dt_ms = dt_ms
  
  if (kx.do_animation == 1) then
    kx.elapsed_time2 = kx.elapsed_time2 + dt
    kx.frame_time2 = dt
  else
    kx.frame_time2 = 0.0
  end
  
end


------------------------------------------------------------------------------
--
function kx_gettime()
  return kx.elapsed_time2
end  

function kx_getdt()
  return kx.frame_time2
end  

------------------------------------------------------------------------------
--
function kx_get_camera()
  return kx.camera
end  

------------------------------------------------------------------------------
--
function kx_get_ortho_camera()
  return kx.camera_ortho
end  



------------------------------------------------------------------------------
--
function kx_resize()
  
  winW, winH = gh_window.getsize(0)
  kx.winW = winW
  kx.winH = winH
  kx_camera_resize(kx.camera, kx.winW, kx.winH, kx.camera_fov, kx.camera_znear, kx.camera_zfar)  
  kx_camera_ortho_resize_v1(kx.camera_ortho, kx.winW, kx.winH)
  
  
  if (kx.renderer_type == RENDERER_VULKAN) then
    kx_vk_resize()  
  end
  
end


------------------------------------------------------------------------------
--
function kx_terminate()
  if (kx.renderer_type == RENDERER_VULKAN) then
    kx_vk_terminate()  
  end
end



------------------------------------------------------------------------------
--
function kx_write_text(x, y, r, g, b, a, text)
  local t = {_x=x, _y=y, _r=r, _g=g, _b=b, _a=a, _text=text} 
  kx.user_texts_index = kx.user_texts_index + 1
  kx.user_texts[kx.user_texts_index] = t
end

function kx_set_demo_caption(text)
  kx.osi_info.demo_caption = text
end

function kx_reset_text()
  for k in pairs (kx.user_texts) do
    kx.user_texts[k] = nil
  end  
  kx.user_texts_index = 0
end



------------------------------------------------------------------------------
--
function kx_camera_create(w, h, fov, znear, zfar)
  local aspect = 1.333
  if (h > 0) then
    aspect = w / h
  end  
  local c = gh_camera.create_persp(fov, aspect, znear, zfar)
  gh_camera.set_viewport(c, 0, 0, w, h)
  gh_camera.setpos(c, 0, 0, 20)
  gh_camera.setlookat(c, 0, 0, 0, 1)
  gh_camera.setupvec(c, 0, 1, 0, 0)
  return c
end

function kx_camera_resize(c, w, h, fov, znear, zfar)
  local aspect = 1.333
  if (h > 0) then
    aspect = w / h
  end  
  gh_camera.update_persp(c, fov, aspect, znear, zfar)
  gh_camera.set_viewport(c, 0, 0, w, h)
end  

function kx_camera_ortho_create_v1(w, h)
  local c = gh_camera.create_ortho(-w/2, w/2, -h/2, h/2, 1.0, 10.0)
  gh_camera.set_viewport(c, 0, 0, w, h)
  gh_camera.set_position(c, 0, 0, 4)
  return c
end

function kx_camera_ortho_create_v2(w, h, left, right, bottom, top, znear, zfar)
  local c = gh_camera.create_ortho(left, right, bottom, top, znear, zfar)
  gh_camera.set_viewport(c, 0, 0, w, h)
  gh_camera.set_position(c, 0, 0, 4)
  return c
end

function kx_camera_ortho_resize_v1(c, w, h)
  gh_camera.update_ortho(c, -w/2, w/2, -h/2, h/2, 1.0, 10.0)
  gh_camera.set_viewport(c, 0, 0, w, h)
end  

function kx_camera_ortho_resize_v2(w, h, left, right, bottom, top, znear, zfar)
  gh_camera.update_ortho(c, left, right, bottom, top, znear, zfar)
  gh_camera.set_viewport(c, 0, 0, w, h)
end



------------------------------------------------------------------------------
--
function kx_mouse_get_position()
  local mx, my = gh_input.mouse_getpos()
  
  if (gh_utils.get_platform() == 2) then -- OSX     
    w, h = gh_window.getsize(0)
    my = h - my
  end
    
  if (gh_utils.get_platform() == 4) then -- RPi
    local w, h = gh_window.getsize(0)
    mx = mx + w/2
    my = -(my - h/2) 
  end
  
  return mx, my
end    



------------------------------------------------------------------------------
--
function kx_check_input()

  local platform_windows = 1 
  --local platform_osx = 2 
  --local platform_linux = 3 
  --local platform_rpi = 4 
  if (gh_utils.get_platform() == platform_windows) then
    gh_window.keyboard_update_buffer(0)
  end

   
  if (kx.is_key_down==0) then
    if (gh_input.keyboard_is_key_down(kx.time_animation_toggle_key) == 1) then
      kx.is_key_down = 1
      if (kx.do_animation == 1) then
        kx.do_animation = 0
      else
        kx.do_animation = 1
      end
    end
    
    if (gh_input.keyboard_is_key_down(kx.osi_toggle_key) == 1) then
      kx.is_key_down = 1
      if (kx.display_osi == 1) then
        kx.display_osi = 0
      else
        kx.display_osi = 1
      end
    end
  end  
    
  if (kx.is_key_down==1) then
    if (gh_input.keyboard_is_key_down(kx.time_animation_toggle_key) == 0 and gh_input.keyboard_is_key_down(kx.osi_toggle_key) == 0) then
      kx.is_key_down = 0
    end
  end  

end

------------------------------------------------------------------------------
--
function kx_get_osi_state()
  return kx.display_osi
end


------------------------------------------------------------------------------
-- Default key is P or 25
function kx_set_time_animation_toggle_key(k)
  kx.time_animation_toggle_key = k
end

------------------------------------------------------------------------------
-- Default key is I or 23
function kx_set_osi_toggle_key(k)
  kx.osi_toggle_key = k
end

