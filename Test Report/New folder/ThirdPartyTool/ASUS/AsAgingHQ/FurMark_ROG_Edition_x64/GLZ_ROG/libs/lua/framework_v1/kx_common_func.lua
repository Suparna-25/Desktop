
function kx_osi_draw_text(osi_info)


  local y_offset = 20
  local x_offset = 10


  local f = 0
  local screen_width = kx.winW

  
  if (string.len(osi_info.demo_caption) > 0) then

    if (kx.renderer_type == RENDERER_VULKAN) then
      if (kx.pso_font_h1_valid == 0) then
        do return end
      end
      gh_renderer.vk_descriptorset_bind(kx.ds_font_h1)
      gh_renderer.pipeline_state_bind(kx.pso_font_h1)
      --gh_renderer.vk_descriptorset_update_resource_texture(ds, tex_res_index, tex_font_h1, sampler, tex_binding_point, VK_SHADER_STAGE_FRAGMENT)
      --gh_renderer.vk_descriptorset_update(ds)
    end
  
  
  f = kx.font_h1
    gh_font.clear(f)
    gh_font.text_2d(f, 10, kx.winH-30, 1, 0.8, 0, 1, osi_info.demo_caption)
    gh_font.update(f, 0)
    if (kx.renderer_type == RENDERER_OPENGL) then
      gh_texture.bind(kx.font_h1_tex, 0)
    end
    gh_font.render(f)
  end


  
  
  if (kx.renderer_type == RENDERER_VULKAN) then
    if (kx.pso_font_p_valid == 0) then
      do return end
    end
    gh_renderer.vk_descriptorset_bind(kx.ds_font_p)
    gh_renderer.pipeline_state_bind(kx.pso_font_p)
    --gh_renderer.vk_descriptorset_update_resource_texture(ds, tex_res_index, tex_font_p, sampler, tex_binding_point, VK_SHADER_STAGE_FRAGMENT)
    --gh_renderer.vk_descriptorset_update(ds)
  end
  
  
  f = kx.font_p
  gh_font.clear(f)
  
  local text = string.format("kx framework v%d.%d.%d", kx.version.major, kx.version.minor, kx.version.patch)
  gh_font.text_2d(f, 10, kx.winH-10, 0.5, 0.5, 0.0, 1.0, text)
  
  

  text = string.format("%.0f FPS", osi_info.fps)
  local text_width = gh_font.get_text_width(f, text)
  gh_font.text_2d(f, screen_width - text_width - 20, y_offset, 1, 1, 1, 1, text)
  y_offset = y_offset + 20

  text = string.format("%.2fms", osi_info.dt_ms)
  text_width = gh_font.get_text_width(f, text)
  gh_font.text_2d(f, screen_width - text_width - 20, y_offset, 1, 1, 1, 1, text)
  y_offset = y_offset + 20

  text = string.format("Frame: %.0f", osi_info.frames)
  text_width = gh_font.get_text_width(f, text)
  gh_font.text_2d(f, screen_width - text_width - 20, y_offset, 1, 1, 1, 1, text)
  y_offset = y_offset + 20


  if (kx.num_gpus > 0) then
    text = "avg  min   max  last"
    text_width = gh_font.get_text_width(f, text)
    gh_font.text_2d(f, screen_width - text_width - 20, y_offset, 1, 1, 1, 1, text)
    y_offset = y_offset + 20
    
    
    if ((kx.elapsed_time - kx.gpumon_last_time) > 1.0) then
      kx.gpumon_last_time = kx.elapsed_time
      
      gh_gml.update()
      
      local gpu, mem = gh_gml.get_usages(0)
      local gpu_usage = gpu
      osi_info.gpu_load_last = gpu_usage
      if (osi_info.gpu_load_max < gpu_usage) then
        osi_info.gpu_load_max = gpu_usage
      end
      if (osi_info.gpu_load_min > gpu_usage) then
        osi_info.gpu_load_min = gpu_usage
      end
      
      osi_info.gpu_load_counter = osi_info.gpu_load_counter + 1
      osi_info.gpu_load_sum = osi_info.gpu_load_sum + gpu
      osi_info.gpu_load_avg = osi_info.gpu_load_sum  / osi_info.gpu_load_counter
      
      osi_info.gpu_temp = gh_gml.get_temperatures(0)
      
      if (kx.renderer_type == RENDERER_OPENGL) then
        osi_info.vram_usage = kx_gl_get_gpu_mem_usage()
      end
      
    end
      
      text = string.format("GPU load: %.2f %.2f %.2f %.2f", osi_info.gpu_load_avg, osi_info.gpu_load_min, osi_info.gpu_load_max, osi_info.gpu_load_last)
      text_width = gh_font.get_text_width(f, text)
      gh_font.text_2d(f, screen_width - text_width - 20, y_offset, 0, 1, 0, 1, text)
      y_offset = y_offset + 20

      text = string.format("GPU temp: %.2f degC", osi_info.gpu_temp)
      text_width = gh_font.get_text_width(f, text)
      gh_font.text_2d(f, screen_width - text_width - 20, y_offset, 1, 0.5, 0, 1, text)
      y_offset = y_offset + 20
  end


  text = string.format("Time: %.3f sec", osi_info.elapsed_time)
  text_width = gh_font.get_text_width(f, text)
  gh_font.text_2d(f, screen_width - text_width - 20, y_offset, 1, 1, 1, 1, text)
  y_offset = y_offset + 20

  text = osi_info.renderer_name
  text_width = gh_font.get_text_width(f, text)
  gh_font.text_2d(f, screen_width - text_width - 20, y_offset, 1, 1, 1, 1, text)
  y_offset = y_offset + 20

  if (osi_info.vram_total > 0) then
    text = string.format("VRAM: %.0f MB (usage: %.0f MB)", osi_info.vram_total/1024, osi_info.vram_usage/1024)
    text_width = gh_font.get_text_width(f, text)
    gh_font.text_2d(f, screen_width - text_width - 20, y_offset, 1, 1, 1, 1, text)
    y_offset = y_offset + 20
   end

  text = osi_info.api_version
  text_width = gh_font.get_text_width(f, text)
  gh_font.text_2d(f, screen_width - text_width - 20, y_offset, 1, 1, 1, 1, text)
  y_offset = y_offset + 20
   
  --text = osi_info.vsync_status
  --text_width = gh_font.get_text_width(f, text)
  --gh_font.text_2d(f, screen_width - text_width - 20, y_offset, 1, 1, 1, 1, text)
  --y_offset = y_offset + 20

  text = string.format("Res: %.0fx%.0f", screen_width, kx.winH)
  text_width = gh_font.get_text_width(f, text)
  gh_font.text_2d(f, screen_width - text_width - 20, y_offset, 1, 1, 1, 1, text)
  y_offset = y_offset + 20
  
  
  for i=1, kx.user_texts_index do
    local t = kx.user_texts[i]
    gh_font.text_2d(f, t._x, t._y, t._r, t._g, t._b, t._a, t._text)
  end
  

  
  gh_font.update(f, 0)
  
  if (kx.renderer_type == RENDERER_OPENGL) then
    gh_texture.bind(kx.font_p_tex, 0)
  end

  gh_font.render(f)
  
end






function kx_osi_update_text(osi_info)

  local y_offset = 20
  local x_offset = 10


  local screen_width = kx.winW

  
  if (string.len(osi_info.demo_caption) > 0) then
    local f = kx.font_h1
    gh_font.clear(f)
    gh_font.text_2d(f, 10, kx.winH-30, 1, 0.8, 0, 1, osi_info.demo_caption)
    gh_font.update(f, 0)
  end

  
  
  local f = kx.font_p
  gh_font.clear(f)
  
  local text = string.format("kx framework v%d.%d.%d", kx.version.major, kx.version.minor, kx.version.patch)
  gh_font.text_2d(f, 10, kx.winH-10, 0.5, 0.5, 0.0, 1.0, text)
  
  ---[[
  text = string.format("%.0f FPS", osi_info.fps)
  local text_width = gh_font.get_text_width(f, text)
  gh_font.text_2d(f, screen_width - text_width - 20, y_offset, 1, 1, 1, 1, text)
  y_offset = y_offset + 20

  text = string.format("%.2fms", osi_info.dt_ms)
  text_width = gh_font.get_text_width(f, text)
  gh_font.text_2d(f, screen_width - text_width - 20, y_offset, 1, 1, 1, 1, text)
  y_offset = y_offset + 20

  text = string.format("Frame: %.0f", osi_info.frames)
  text_width = gh_font.get_text_width(f, text)
  gh_font.text_2d(f, screen_width - text_width - 20, y_offset, 1, 1, 1, 1, text)
  y_offset = y_offset + 20

  
  ---[[
  if (kx.num_gpus > 0) then
    text = "avg  min   max  last"
    text_width = gh_font.get_text_width(f, text)
    gh_font.text_2d(f, screen_width - text_width - 20, y_offset, 1, 1, 1, 1, text)
    y_offset = y_offset + 20
    
    
    if ((kx.elapsed_time - kx.gpumon_last_time) > 1.0) then
      kx.gpumon_last_time = kx.elapsed_time
      
      gh_gml.update()
      
      local gpu, mem = gh_gml.get_usages(0)
      local gpu_usage = gpu
      osi_info.gpu_load_last = gpu_usage
      if (osi_info.gpu_load_max < gpu_usage) then
        osi_info.gpu_load_max = gpu_usage
      end
      if (osi_info.gpu_load_min > gpu_usage) then
        osi_info.gpu_load_min = gpu_usage
      end
      
      osi_info.gpu_load_counter = osi_info.gpu_load_counter + 1
      osi_info.gpu_load_sum = osi_info.gpu_load_sum + gpu
      osi_info.gpu_load_avg = osi_info.gpu_load_sum  / osi_info.gpu_load_counter
      
      osi_info.gpu_temp = gh_gml.get_temperatures(0)
      
      if (kx.renderer_type == RENDERER_OPENGL) then
        osi_info.vram_usage = kx_gl_get_gpu_mem_usage()
      end
      
    end
      
      text = string.format("GPU load: %.2f %.2f %.2f %.2f", osi_info.gpu_load_avg, osi_info.gpu_load_min, osi_info.gpu_load_max, osi_info.gpu_load_last)
      text_width = gh_font.get_text_width(f, text)
      gh_font.text_2d(f, screen_width - text_width - 20, y_offset, 0, 1, 0, 1, text)
      y_offset = y_offset + 20

      text = string.format("GPU temp: %.2f degC", osi_info.gpu_temp)
      text_width = gh_font.get_text_width(f, text)
      gh_font.text_2d(f, screen_width - text_width - 20, y_offset, 1, 0.5, 0, 1, text)
      y_offset = y_offset + 20
  end
  --]]
  
  text = string.format("Time: %.3f sec", osi_info.elapsed_time)
  text_width = gh_font.get_text_width(f, text)
  gh_font.text_2d(f, screen_width - text_width - 20, y_offset, 1, 1, 1, 1, text)
  y_offset = y_offset + 20

  text = osi_info.renderer_name
  text_width = gh_font.get_text_width(f, text)
  gh_font.text_2d(f, screen_width - text_width - 20, y_offset, 1, 1, 1, 1, text)
  y_offset = y_offset + 20

  if (osi_info.vram_total > 0) then
    text = string.format("VRAM: %.0f MB (usage: %.0f MB)", osi_info.vram_total/1024, osi_info.vram_usage/1024)
    text_width = gh_font.get_text_width(f, text)
    gh_font.text_2d(f, screen_width - text_width - 20, y_offset, 1, 1, 1, 1, text)
    y_offset = y_offset + 20
  end

  text = osi_info.api_version
  text_width = gh_font.get_text_width(f, text)
  gh_font.text_2d(f, screen_width - text_width - 20, y_offset, 1, 1, 1, 1, text)
  y_offset = y_offset + 20
   
  --text = osi_info.vsync_status
  --text_width = gh_font.get_text_width(f, text)
  --gh_font.text_2d(f, screen_width - text_width - 20, y_offset, 1, 1, 1, 1, text)
  --y_offset = y_offset + 20



  text = string.format("Res: %.0f x %.0f", screen_width, kx.winH)
  --text = string.format("Res: %.0f x %.0f", winW, winH)
  --text = "Res: 800 x 400"
  text_width = gh_font.get_text_width(f, text)
  gh_font.text_2d(f, screen_width - text_width - 20, y_offset, 1, 1, 1, 1, text)
  y_offset = y_offset + 20
  
  ---[[
  for i=1, kx.user_texts_index do
    local t = kx.user_texts[i]
    gh_font.text_2d(f, t._x, t._y, t._r, t._g, t._b, t._a, t._text)
  end
    --]]
    
  gh_font.update(f, 0)
  
end







