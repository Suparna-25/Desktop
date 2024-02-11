
local elapsed_time = gh_utils.get_elapsed_time()
local dt = elapsed_time - last_time
last_time = elapsed_time




function modulo(a, b)
  return a - math.floor(a/b)*b
end





function gl_read_gpu_memory_load()
  local gpu_mem_usage = gh_renderer.get_gpu_memory_usage_kb_nv() / 1024
  if (gpu_mem_usage <= 0) then
    gpu_mem_usage = gh_renderer.get_gpu_memory_usage_kb_amd() / 1024
  end
  return gpu_mem_usage
end  

function gl_read_gpu_memory_size()
  local gpu_mem_total = gh_renderer.get_gpu_memory_total_available_kb_nv() /1024
  if (gpu_mem_total <= 0) then
    gpu_mem_total = gh_renderer.get_gpu_memory_total_available_kb_amd() / 1024
  end
  return gpu_mem_total
end









local uptime = gh_utils.get_uptime()
local hours = math.floor(uptime / 3600)
local minutes = math.floor(modulo(uptime, 3600) / 60)
local seconds = math.floor(modulo(uptime, 60))
local uptime_str = string.format("%.2d:%.2d:%.2d", hours, minutes, seconds)

local display_credits = 1


local display_3d_api_windows = 1
local display_gpumon = 0

if ((gh_utils.get_platform() == 1) or (gh_utils.get_platform() == 3)) then
  display_gpumon = 1
end


if (cpumon_only == 1) then
  display_3d_api_windows = 0
  display_gpumon = 0
end  








gh_renderer.set_viewport_scissor(0, 0, winW, winH)
-- fast bkg clear (black)
gh_renderer.clear_color_depth_buffers(0.2, 0.2, 0.2, 1.0, 1.0)

gh_renderer.set_depth_test_state(0)




if (render_bkg == 1) then
  gh_gpu_program.bind(bkg_prog)
  gh_gpu_program.uniform1i(bkg_prog, "tex0", 0)
  gh_gpu_program.uniform4f(bkg_prog, "uvtiling", 0)

  if (bkg_tex > 0) then
    gh_texture.bind(bkg_tex, 0)
    gh_gpu_program.uniform1i(bkg_prog, "do_texturing", 1)
    gh_gpu_program.uniform4f(bkg_prog, "uvtiling", uvtiling_u, uvtiling_v, 0.0, 1.0)
  else 
    gh_gpu_program.uniform1i(bkg_prog, "do_texturing", 0)
  end  

  -- If real monitoring mode, the static background image.
  if (monitoring_mode == 0) then
    gh_gpu_program.uniform1f(bkg_prog, "time", elapsed_time)
    gh_gpu_program.uniform2f(bkg_prog, "resolution", winW, winH)
  end
  gh_object.render(quad)
end  









local read_hw_sensors = 0
if ((elapsed_time - lastime_hw_polling) > hw_polling_interval) then
  lastime_hw_polling = elapsed_time
  read_hw_sensors = 1
end





local LEFT_BUTTON = 1
local mouse_left_button = gh_input.mouse_get_button_state(LEFT_BUTTON) 
local RIGHT_BUTTON = 2
local mouse_right_button = gh_input.mouse_get_button_state(RIGHT_BUTTON) 

--local mouse_x, mouse_y = gh_input.mouse_get_position()
local mouse_x, mouse_y = mouse_get_position()
  
local mouse_quad_x = mouse_x - winW/2
local mouse_quad_y = -(mouse_y - winH/2) 



local mouse_wheel = 0

local mouse_wheel_delta = gh_input.mouse_get_wheel_delta()
if (mouse_wheel_delta > 0) then
  mouse_wheel = mouse_wheel + 1
elseif (mouse_wheel_delta < 0) then
  mouse_wheel = mouse_wheel - 1
end  
gh_input.mouse_reset_wheel_delta()



----------------------------------------------------------------------------
-- ImGui beginning ---------------------------------------------------------
--


---[[


local display_window_info = 0



gh_imgui.frame_begin_v2(winW, winH, mouse_x, mouse_y, mouse_left_button, mouse_right_button, mouse_wheel, dt)


local mainbar_height = 0

if (display_main_menu == 1) then

  -- Main menu: fullscreen menu bar.
  --
  if (gh_imgui.menu_begin_main_bar() == 1) then

    mainbar_height = 20

    local enabled = 1
    if (gh_imgui.menu_begin("File", enabled) == 1) then
    
      local item_selected = 0
      local item_enabled = 1

      if (gh_imgui.menu_item("Export all data", "", item_selected, item_enabled) == 1) then
        ExportData()
      end

      if (gh_imgui.menu_item("Show log file", "", item_selected, item_enabled) == 1) then
        if (cpu.is_macos == 1) then
          local demo_dir = gh_utils.get_demo_dir()
          gh_utils.open_url(demo_dir .. "../_geexlab_log.txt")
        else
          local app_dir = gh_utils.get_app_dir()
          gh_utils.open_url(app_dir .. "_geexlab_log.txt")
        end  
      end


      if (cpu.is_macos == 0) then -- There is a crash on macOS when stopping the demo this way...
        if (gh_imgui.menu_item("Quit", "", item_selected, item_enabled) == 1) then
          gh_utils.stop_demo()
        end
      end

      gh_imgui.menu_end()
    end

    if (cpu.is_macos == 0) then
      if (gh_imgui.menu_begin("Tools", enabled) == 1) then
      
        local item_selected = 0
        local item_enabled = 1
        
        if (cpu.log_data == 0) then
          if (gh_imgui.menu_item("Log data (OFF)", "", item_selected, item_enabled) == 1) then
            cpu.log_data = 1
          end
        else
          if (gh_imgui.menu_item("Log data (ON)", "", item_selected, item_enabled) == 1) then
            cpu.log_data = 0
          end
        end
        
        
        if (gpu_monitoring_supported == 1) then
					if (do_gpu_monitoring == 0) then
						if (gh_imgui.menu_item("GPU monitoring (OFF)", "", item_selected, item_enabled) == 1) then
							do_gpu_monitoring = 1
						end
					else
						if (gh_imgui.menu_item("GPU monitoring (ON)", "", item_selected, item_enabled) == 1) then
							do_gpu_monitoring = 0
						end
					end
				end
      
        gh_imgui.menu_end()
      end
    end

    gh_imgui.menu_end_main_bar()
  end
end















local hovered = 0


local pos_size_flag_always = 1 -- Always set the pos and/or size
local pos_size_flag_once = 2 -- Set the pos and/or size once per runtime session (only the first call with succeed)
local pos_size_flag_first_use_ever = 4  -- Set the pos and/or size if the window has no saved data (if doesn't exist in the .ini file)
local pos_size_flag_appearing = 8  -- Set the pos and/or size if the window is appearing after being hidden/inactive (or the first time)




function clamp(x, lowerlimit, upperlimit)
  if (x < lowerlimit) then
    x = lowerlimit
  end
  if (x > upperlimit) then
    x = upperlimit
  end
  return x
end

function smoothstep(edge0, edge1, x)
  --  Scale, bias and saturate x to 0..1 range
  x = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0)
  -- Evaluate polynomial
  return x * x * (3 - 2 * x)
end

-----------------------------------------------------------------------------------------------
-- CPU 
-----------------------------------------------------------------------------------------------

---[[

local gpu_data = ""

if ((show_cpu_box == 1) and (cpu.display_window == 1)) then

  gh_imgui.set_color(IMGUI_TITLE_BG_COLOR, title_bg.r, title_bg.g, title_bg.b, title_bg.a)
  gh_imgui.set_color(IMGUI_TITLE_BG_ACTIVE_COLOR, title_bg_actv.r, title_bg_actv.g, title_bg_actv.b, title_bg_actv.a)
  gh_imgui.set_color(IMGUI_WINDOW_BG_COLOR, window_bg.r, window_bg.g, window_bg.b, window_alpha)
  
  --gh_imgui.set_color(IMGUI_WINDOW_BG_COLOR, window_bg.r, window_bg.g, window_bg.b, window_alpha)
  gh_imgui.set_color(IMGUI_WINDOW_BG_COLOR, 0.1, 0.1, 0.1, window_alpha)


--[[
  gh_imgui.set_color(IMGUI_TITLE_BG_COLOR, 0.0, 0.0, 0.0, 1.0)
  gh_imgui.set_color(IMGUI_TITLE_BG_ACTIVE_COLOR, 0.2, 0.2, 0.3, 1.0)
  
  if (cpumon_only == 1) then
    gh_imgui.set_color(IMGUI_WINDOW_BG_COLOR, 0.05, 0.1, 0.1, 0.5)
  else
    gh_imgui.set_color(IMGUI_WINDOW_BG_COLOR, 0.05, 0.05, 0.05, window_alpha)
  end
  --]]

  local window_flags = 0
  
  local is_open = 0
  if (cpumon_only == 1) then
    --ImGuiWindowFlags_NoResize = 2 -- Disable user resizing with the lower-right grip
    --ImGuiWindowFlags_NoMove = 4 -- Disable user moving the window
    window_flags = 6
    is_open = gh_imgui.window_begin("GL-Z > CPU / GPU monitoring", winW, winH, 0, mainbar_height, window_flags, pos_size_flag_always, pos_size_flag_always)
  else
    is_open = gh_imgui.window_begin("CPU", 320, 360, 6, mainbar_height, window_flags, pos_size_flag_first_use_ever, pos_size_flag_first_use_ever)
  end
  
  
  if (is_open == 1) then

    if ((cpu.is_windows == 1) and (cpu.info_supported == 1)) then
      gh_imgui.text_rgba("CPU: " .. cpu.name, 1.0, 1.0, 0.0, 1.0)
      gh_imgui.text_rgba("- speed: " .. cpu.speed .. " MHz", 1.0, 1.0, 0.0, 1.0)
      gh_imgui.text_rgba("- memory: " .. cpu.mem_size .. "MB", 1.0, 1.0, 0.0, 1.0)
    end
    
    
    
    
    
    

    
    if ((cpu.is_windows == 1) and (cpu.windows_wmi_initialized == 0)) then
      
      cpu.wmi_init_done = gh_utils.shared_variable_get_value_4i("wmi_init_done")
      if (cpu.wmi_init_done == 1) then
      
        cpu.core_count = gh_utils.cpu_usage_get_core_count()

        print("cpu.core_count: " .. cpu.core_count)

        if (cpu.core_count > 0) then
          cpu.usage_supported = 1
        end

        cpu.phys_core_count = gh_utils.cpu_usage_get_physical_core_count()


        print("gh_utils.cpu_usage_update()...")
        gh_utils.cpu_usage_update()
        print("gh_utils.cpu_usage_update() OK.")
        local overall_usage = 0
        for c=1, cpu.core_count do
          local usage = gh_utils.cpu_usage_get_core_usage(c-1)
          --local usage = 0
          cpu.usage[c] = usage
          overall_usage = overall_usage + usage
        end
        cpu.overall_usage = overall_usage / cpu.core_count
        
        cpu.windows_wmi_initialized = 1
      else
        gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)
        gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)
        gh_imgui.text_rgba("initializing CPU monitor...", 0.7, 0.7, 0.7, 1.0)
        gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)
        gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)
      
      end
    end

    
        
    
    
    
  
  
    if (cpu.usage_supported == 1) then

      if (cpu.is_windows == 1) then
        gh_imgui.text_rgba(string.format("- cores: %dC/%dT", cpu.phys_core_count, cpu.core_count), 1.0, 1.0, 0.0, 1.0)

        if (read_hw_sensors == 1) then
          
          if (cpu.windows_wmi_initialized == 1) then
            gh_utils.cpu_usage_update()
            local overall_usage = 0
            for c=1, cpu.core_count do
              local usage = gh_utils.cpu_usage_get_core_usage(c-1)
              cpu.usage[c] = usage
              overall_usage = overall_usage + usage
            end
            cpu.overall_usage = overall_usage / cpu.core_count
          end
        end  
      end
      
      
      if (cpu.is_linux == 1) then
        gh_imgui.text_rgba("- CPU: " .. cpu.name, 1.0, 1.0, 0.2, 1.0)
        gh_imgui.text_rgba("- cores: " .. cpu.core_count, 1.0, 1.0, 0.2, 1.0)
        if (cpu.is_rpi == 1) then
          gh_imgui.text_rgba("- SoC: " .. cpu.rpi_hardware, 0.9, 0.9, 0.9, 1.0)
        end

        if (read_hw_sensors == 1) then
          Linux_CPU_Update(cpu)
          RPi_Read_Temperature(cpu)
        end
      end


      gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)
      gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)
      gh_imgui.text_rgba(string.format("Overall CPU usage %.1f", cpu.overall_usage) .. " %%", 1.0, 1.0, 1.0, 1.0)

      gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)
      gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)

      --gh_imgui.set_color(IMGUI_FRAME_BG_COLOR, 0.2, 0.2, 0.2, 0.70)
      --gh_imgui.set_color(IMGUI_PLOTHISTOGRAM_COLOR, 0.0, 0.5, 1.0, 1.0)
      
      gh_imgui.set_color(IMGUI_FRAME_BG_COLOR, 0.4, 0.4, 0.4, 1.0)
      gh_imgui.set_color(IMGUI_PLOTHISTOGRAM_COLOR, 0.0, 0.6, 1.0, 1.0)

      local max_cores = cpu.core_count
      local core_start = 1
      if (cpu.is_linux == 1) then
        -- On linux, there are n cores + one entry for overall usage.
        -- The overall usage is the first entry.
        max_cores = cpu.core_count+1
        core_start = 2
      end
      
      for c=core_start, max_cores do
        local u = cpu.usage[c]
        gh_imgui.progress_bar(u/100.0, 0, 0, string.format("%.1f %%", u))
      end
      --gh_imgui.set_color(IMGUI_FRAME_BG_COLOR, 0.1, 0.1, 0.1, 1.0)
    end
  
  
    if (cpu.rpi_core_temp > 0) then
      gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)
      gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)
      gh_imgui.text_rgba(string.format("Core temperature"), 1.0, 1.0, 1.0, 1.0)
      local t = cpu.rpi_core_temp/100.0
      --local ri = math.floor(t*10.0)
      --ri = clamp(ri, 1, 10)
      --local col = cpu.rpi_temp_color_ramp[ri]
      --local k = smoothstep(0.30, 0.70, t)
      --gh_imgui.set_color(IMGUI_PLOTHISTOGRAM_COLOR, col.r, col.g, col.b, 1.0)
      --gh_imgui.set_color(IMGUI_PLOTHISTOGRAM_COLOR, 1.0, 0.5, 0.0, 1.0)
      
      --gh_imgui.set_color(IMGUI_FRAME_BG_COLOR, 0.2, 0.2, 0.2, 0.70)
      gh_imgui.set_color(IMGUI_PLOTHISTOGRAM_COLOR, 0.9, 0.4, 0.2, 1.0)
      gh_imgui.progress_bar(t, 0, 0, string.format("%.1f °C", cpu.rpi_core_temp))
      gh_imgui.set_color(IMGUI_FRAME_BG_COLOR, 0.1, 0.1, 0.1, 1.0)
      
      
      --gh_imgui.set_color(IMGUI_FRAME_BG_COLOR, 0.4, 0.4, 0.5, 1.0)
      
      --cpu.rpi_log_temperature = gh_imgui.checkbox("Log temperature", cpu.rpi_log_temperature)
      --if (cpu.rpi_log_temperature == 1) then
      --  print(string.format("CPU temp: %.1f °C", cpu.rpi_core_temp))
      --end
      
      --gh_imgui.set_color(IMGUI_FRAME_BG_COLOR, 0.1, 0.1, 0.0, 1.0)
      
    end
  


    
    if (cpumon_include_gpumon == 1) then
    
      if ((do_gpu_monitoring == 1) and (read_hw_sensors == 1)) then
        gh_gml.update()
      end
        
      for i=1, gml.num_gpus do
        local gpu = gml.gpus[i]
        
        -- NVIDIA (4318) or AMD (4098) GPUs
        if ((gpu.vendor_id==4318) or (gpu.vendor_id==4098)) then
        
          if (read_hw_sensors == 1) then
            --gpu.core_temp = gh_gml.get_temperatures(i-1)
            local core_temp = gh_gml.get_temperatures(i-1)
            gpu.core_temp = core_temp
            gpu.core_usage = gh_gml.get_usages(i-1)
            gpu.power_target = gh_gml.gpu_power_get_power_limit(i-1)
            gpu.power = gh_gml.gpu_power_get_current_value(i-1)
            gpu.core_clock, gpu.mem_clock = gh_gml.get_clocks(i-1)
          end
        
          gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)
          gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)
          gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)
          gh_imgui.widget(IMGUI_WIDGET_SEPARATOR)
        
          gh_imgui.text_rgba(string.format("GPU %d: %s (%4X-%4X)", i, gpu.name, gpu.vendor_id, gpu.device_id), 1.0, 1.0, 0.0, 1.0)
          --gh_imgui.text_rgba(string.format("codename: %s", gpu.codename), 1.0, 0.8, 0.0, 1.0)
          gh_imgui.text_rgba(string.format("cores/TMUs/ROPs: %d / %d / %d", gpu.cores, gpu.tmus, gpu.rops), 1.0, 1.0, 0.5, 1.0)
          gh_imgui.text_rgba(string.format("driver: %s", gpu.driver), 1.0, 1.0, 0.5, 1.0)


					if (do_gpu_monitoring == 1) then

						if (gpu.power_target > 0) then
							gh_imgui.text_rgba(string.format("power: %.1f (target: %.1f)", gpu.power, gpu.power_target) .. " %% TDP", 1.0, 0.5, 0.0, 1.0)
						end
						gh_imgui.text_rgba("clock speeds - core: " .. gpu.core_clock .. "MHz, mem: " .. gpu.mem_clock .. "MHz", 0.4, 0.75, 1.0, 1.0)
					
						gh_imgui.set_color(IMGUI_PLOTHISTOGRAM_COLOR, 0.0, 1.0, 0.0, 1.0)
						gh_imgui.text_rgba("core usage: " .. gpu.core_usage .. "%%", 0.0, 1.0, 0.0, 1.0)
						local pbval = gpu.core_usage/100.0
						gh_imgui.progress_bar(pbval, 0, 0, string.format("%.1f", gpu.core_usage) .. " %")


						gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)
						gh_imgui.set_color(IMGUI_PLOTHISTOGRAM_COLOR, 1.0, 0.3, 0.0, 1.0)
						gh_imgui.text_rgba("core temperature: " .. gpu.core_temp .. "°C", 1.0, 0.3, 0.0, 1.0)
						pbval = gpu.core_temp/120.0
						gh_imgui.progress_bar(pbval, 0, 0, string.format("%.1f°C", gpu.core_temp))
						
						if (i > 1) then
							gpu_data = gpu_data .. string.format(", %s, %.1f, %.1f", gpu.name, gpu.core_usage, gpu.core_temp)
						else
							gpu_data = string.format("%s, %.1f, %.1f", gpu.name, gpu.core_usage, gpu.core_temp)
						end
					end
        end
      end
    end
    
    
    
    
    
    
    
    
  
  

    if (display_window_info == 1) then
      gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)
      gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)
      posx, poy, sizex, sizey = gh_imgui.get_window_pos_size()
      gh_imgui.text_rgba(string.format("%d  %d  %d  %d", posx, poy, sizex, sizey), 0.5, 0.5, 0.5, 1.0)
    end
    
    
    
    
    gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)
    gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)

    gh_imgui.widget(IMGUI_WIDGET_SEPARATOR)
    --gh_imgui.set_color(IMGUI_FRAME_BG_COLOR, 0.7, 0.7, 0.7, 1.0)
    --cpu.log_data = gh_imgui.checkbox("Log data", cpu.log_data)
   
    if ((read_hw_sensors == 1) and (cpu.log_data == 1)) then
      if (logfile == nil) then
        logfile = io.open(logfilename, "w+")
      end
      if (logfile ~= nil) then
        local data = string.format("%.1f, %.1f", cpu.overall_usage, cpu.rpi_core_temp)
        if (gpu_data:len() > 0) then
          data = "\n" .. uptime_str .. ", " .. data .. ", " .. gpu_data
        end
        logfile:write(data)
        logfile:flush()
        --logfile:close()
      end
      --print(string.format("CPU - usage: %.1f %% - temperature: %.1f °C", cpu.overall_usage, cpu.rpi_core_temp))
    end
    --gh_imgui.set_color(IMGUI_FRAME_BG_COLOR, 0.1, 0.1, 0.0, 1.0)
    
    
    if (display_credits == 1) then
      WriteCredits(uptime_str)
      display_credits = 0
    end
    
  
  end
  
  gh_imgui.window_end()
end

--]]



-----------------------------------------------------------------------------------------------
-- OpenGL renderer
-----------------------------------------------------------------------------------------------


if (display_3d_api_windows == 1) then


  --window_alpha = 0.25

  if (show_gl_renderer_box_fullscreen == 1) then
    gh_imgui.set_color(IMGUI_TEXT_COLOR, 1.0, 0.4, 0.0, 1.0)
    gh_imgui.set_color(IMGUI_TITLE_BG_COLOR, 0.2, 0.2, 0.2, 1.0)
    gh_imgui.set_color(IMGUI_TITLE_BG_ACTIVE_COLOR, 0.1, 0.1, 0.1, 1.0)
    gh_imgui.set_color(IMGUI_WINDOW_BG_COLOR, 0.2, 0.0, 0.0, window_alpha)
  else
    gh_imgui.set_color(IMGUI_TEXT_COLOR, 1.0, 1.0, 1.0, 1.0)
    gh_imgui.set_color(IMGUI_TITLE_BG_COLOR, 0.1, 0.4, 0.6, 1.0)
    gh_imgui.set_color(IMGUI_TITLE_BG_ACTIVE_COLOR, 0.1, 0.5, 0.8, 1.0)
    gh_imgui.set_color(IMGUI_WINDOW_BG_COLOR, 0.05, 0.3, 0.5, window_alpha)
  end    


  local w_pos_y = mainbar_height+10
  if (cpu.display_window == 1) then
    w_pos_y = 350
  end

  if (show_gl_renderer_box == 1) then
  
    local window_flags = 0
    local pos_flag = pos_size_flag_first_use_ever
    local size_flag = pos_size_flag_first_use_ever

    local box_w = 360
    local box_h = 300
    local box_x = 40
    local box_y = w_pos_y
    local window_name = "OpenGL Renderer"

    if (show_gl_renderer_box_fullscreen == 1) then

      window_name = "OpenGL Renderer##glmem"

      --ImGuiWindowFlags_NoResize = 2 -- Disable user resizing with the lower-right grip
      --ImGuiWindowFlags_NoMove = 4 -- Disable user moving the window
      window_flags = 6
      pos_flag = pos_size_flag_always
      size_flag = pos_size_flag_always

      box_w = winW
      box_h = winH
      box_x = 0
      box_y = 0
    end

    local is_open = gh_imgui.window_begin(window_name, box_w, box_h, box_x, box_y, window_flags, pos_flag, size_flag)

    if (is_open == 1) then
      if (gh_imgui.is_window_hovered() == 1) then
        imgui_window_hovered = 1
      else	
        imgui_window_hovered = 0
      end	

      gh_imgui.set_color(IMGUI_TEXT_COLOR, 1.0, 1.0, 1.0, 1.0)


      local window_w = gh_imgui.get_content_region_available_width()


      gh_imgui.text_rgba("GL_RENDERER: " .. gl.renderer, 1.0, 1.0, 0.0, 1.0)
      gh_imgui.text_rgba("GL_VENDOR: " .. gl.vendor, 1.0, 0.85, 0.0, 1.0)
      gh_imgui.text_rgba("GL_VERSION: " .. gl.version, 1.0, 0.7, 0.0, 1.0)


      gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)
      gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)
      gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)
      gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)


      local gl_gpu_memory_size = gl_read_gpu_memory_size()
      if (gl_gpu_memory_size > 0) then
        gh_imgui.text_rgba(string.format("OpenGL memory size: %.0f MB", gl_gpu_memory_size), 0.0, 1.0, 1.0, 1.0)
      end
      gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)
      gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)
      local gl_gpu_memory_load = gl_read_gpu_memory_load()
      if (gl_gpu_memory_load > 0) then
        local percent = gl_gpu_memory_load * 100 / gl_gpu_memory_size
        --gh_imgui.text_rgba(string.format("OpenGL memory usage: %.0f MB (%.0f", gl_gpu_memory_load, percent) .. "%%)", 0.8, 0.8, 1.0, 1.0)
        gh_imgui.text_rgba("OpenGL memory usage:", 1.0, 0.6, 0.0, 1.0)
        local x = percent / 100.0
        --local x = 0.8
        gh_imgui.set_color(IMGUI_PLOTHISTOGRAM_COLOR, 1.0, 0.5, 0.0, 0.8)
        gh_imgui.set_color(IMGUI_FRAME_BG_COLOR, 0.4, 0.4, 0.4, 0.6)
        gh_imgui.set_color(IMGUI_TEXT_COLOR, 1.0, 1.0, 1.0, 1.0)

        local widget_width = window_w * 0.8
        gh_imgui.push_item_width(widget_width)
        gh_imgui.progress_bar(x, 0, 0, string.format("%.0f MB / %.0f%%", gl_gpu_memory_load, percent))
        gh_imgui.pop_item_width()

      end



      if (show_gl_renderer_box_show_caps == 1) then
        gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)
        gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)
        for i=1, gl.cap_index do
          local cap = gl.caps[i]
          local str = string.format("> %s: %d", cap.name, cap.cx)
          if (cap.cy > 0) then
            str = str .. string.format(" %d", cap.cy)
          end
          if (cap.cz > 0) then
            str = str .. string.format(" %d", cap.cz)
          end
          if (cap.cw > 0) then
            str = str .. string.format(" %d", cap.cw)
          end
          gh_imgui.text(str)
        end
      end




      
      
      --if (gh_imgui.button("Export data", 100, 20) == 1) then
      --  ExportData()
      --end


      if (display_window_info == 1) then
        gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)
        gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)
        posx, poy, sizex, sizey = gh_imgui.get_window_pos_size()
        gh_imgui.text_rgba(string.format("%d  %d  %d  %d", posx, poy, sizex, sizey), 0.5, 0.5, 0.5, 1.0)
        gh_imgui.text_rgba(string.format("%d  %d", winW, winH), 0.5, 0.5, 0.5, 1.0)
      end
      
      
      
      if (display_credits == 1) then
        gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)
        gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)
        gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)
        gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)
        WriteCredits(uptime_str)
        display_credits = 0
      end
      

      if (show_gl_renderer_box_show_alpha_slider == 1) then
        gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)
        gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)
        gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)
        gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)
        gh_imgui.text_rgba("Windows alpha", 0.6, 0.6, 0.6, 1.0)
        window_alpha = gh_imgui.slider_1f("##windowalpha",  window_alpha,   0.0, 1.0, 1.0)
      end
      
      
      
    end

    gh_imgui.window_end()

  end

  -----------------------------------------------------------------------------------------------
  -- OpenGL extensions
  -----------------------------------------------------------------------------------------------

  if (show_gl_extensions_box == 1) then

    local window_flags = 0

    w_pos_y = 280
    if (cpu.display_window == 1) then
      w_pos_y = 500
    end

    local is_open = gh_imgui.window_begin("OpenGL Extensions", 410, 440, 10, w_pos_y, window_flags, pos_size_flag_first_use_ever, pos_size_flag_first_use_ever)

    if (is_open == 1) then
    
      gh_imgui.text_rgba(string.format("# of extensions: %d", gl.num_extensions), 1.0, 1.0, 0.0, 1.0)

      for i=1, gl.num_extensions do
        local ext_name = gl.extensions[i]
        local r, g, b = GetExtensionColor(ext_name)
        gh_imgui.text_rgba(string.format("%03d> %s", i, ext_name), r, g, b, 1.0)
      end


      if (display_window_info == 1) then
        posx, poy, sizex, sizey = gh_imgui.get_window_pos_size()
        gh_imgui.text_rgba(string.format("%d  %d  %d  %d", posx, poy, sizex, sizey), 0.5, 0.5, 0.5, 1.0)
      end  
    
    end

    gh_imgui.window_end()

  end




  -----------------------------------------------------------------------------------------------
  -- X11 / GLX info
  -----------------------------------------------------------------------------------------------

  if (show_gl_extensions_box == 1) then

    if (gl.glx == 1) then

      local is_open = gh_imgui.window_begin("GLX info", 410, 440, 30, 320, window_flags, pos_size_flag_first_use_ever, pos_size_flag_first_use_ever)

      if (is_open == 1) then
        gh_imgui.text_rgba(string.format("- GLX_VERSION: %d.%d", gl.glx_version_major, gl.glx_version_minor), 1.0, 1.0, 0.0, 1.0)
        
        gh_imgui.text_rgba(string.format("- GLX_VENDOR server: %s", gl.glx_svr_vendor_str), 1.0, 1.0, 1.0, 1.0)
        gh_imgui.text_rgba(string.format("- GLX_VENDOR client: %s", gl.glx_client_vendor_str), 1.0, 1.0, 1.0, 1.0)
        
        if (gl.glx_renderer_vendor_id > 0) then
  				gh_imgui.text_rgba(string.format("- GLX_RENDERER_VENDOR_ID_MESA: %s (0x%4X)", gl.glx_renderer_vendor_id_str, gl.glx_renderer_vendor_id), 1.0, 1.0, 0.0, 1.0)
  				gh_imgui.text_rgba(string.format("- GLX_RENDERER_DEVICE_ID_MESA: %s (0x%4X)", gl.glx_renderer_device_id_str, gl.glx_renderer_device_id), 1.0, 1.0, 0.0, 1.0)
  				
  				gh_imgui.text_rgba(string.format("- GLX_RENDERER_VERSION_MESA: %d.%d.%d", gl.glx_renderer_version_major, gl.glx_renderer_version_minor, gl.glx_renderer_version_patch), 1.0, 0.8, 0.0, 1.0)
  				gh_imgui.text_rgba(string.format("- GLX_RENDERER_ATTRIBUTE_INFO_ACCELERATED: %d", gl.glx_renderer_accelerated), 0.8, 0.8, 0.8, 1.0)
  				gh_imgui.text_rgba(string.format("- GLX_RENDERER_ATTRIBUTE_INFO_VIDEO_MEMORY: %d MB", gl.glx_renderer_video_memory), 1.0, 1.0, 1.0, 1.0)
  				gh_imgui.text_rgba(string.format("- GLX_RENDERER_ATTRIBUTE_INFO_UMA: %d", gl.glx_renderer_uma), 0.8, 0.8, 0.8, 1.0)
  			end
        
        
        gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)
        gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)
        gh_imgui.text_rgba(string.format("# of GXL server extensions: %d", gl.glx_svr_num_extensions), 1.0, 1.0, 0.0, 1.0)
        for i=1, gl.glx_svr_num_extensions do
          local ext_name = gl.glx_svr_extensions[i]
          gh_imgui.text_rgba(string.format("%03d> %s", i, ext_name), 0.2, 0.9, 0.5, 1.0)
        end
        
        gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)
        gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)
        gh_imgui.text_rgba(string.format("# of GXL client extensions: %d", gl.glx_clt_num_extensions), 1.0, 1.0, 0.0, 1.0)
        for i=1, gl.glx_clt_num_extensions do
          local ext_name = gl.glx_clt_extensions[i]
          gh_imgui.text_rgba(string.format("%03d> %s", i, ext_name), 0.2, 0.9, 0.5, 1.0)
        end
        
      end

      gh_imgui.window_end()
    end

  end




  -----------------------------------------------------------------------------------------------
  -- Vulkan instance
  -----------------------------------------------------------------------------------------------

  ---[[

  if (show_vk_instance_box == 1) then

    if (vk.num_inst_extensions > 0) then

      gh_imgui.set_color(IMGUI_WINDOW_BG_COLOR, 84/255, 10/255, 14/255, window_alpha)
      gh_imgui.set_color(IMGUI_TITLE_BG_COLOR, 164/255, 30/255, 34/255, 1.0)
      gh_imgui.set_color(IMGUI_TITLE_BG_ACTIVE_COLOR, 194/255, 60/255, 44/255, 1.0)


      local window_flags = 0
      local is_open = gh_imgui.window_begin("Vulkan - Instance Extensions/Layers", 350, 200, 390, 10, window_flags, pos_size_flag_first_use_ever, pos_size_flag_first_use_ever)

      if (is_open == 1) then
        gh_imgui.text_rgba(string.format("# of extensions: %d", vk.num_inst_extensions), 1.0, 1.0, 0.0, 1.0)

        for i=1, vk.num_inst_extensions do
          local ext_name = vk.inst_extensions[i]
          gh_imgui.text_rgba(string.format("%03d> %s", i, ext_name), 1.0, 0.5, 0.0, 1.0)
        end

        gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)
        gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)

        gh_imgui.text_rgba(string.format("# of layers: %d", vk.num_inst_layers), 1.0, 1.0, 0.0, 1.0)

        for i=1, vk.num_inst_layers do
          local ext_name = vk.inst_layers[i]
          gh_imgui.text_rgba(string.format("%03d> %s", i, ext_name), 1.0, 0.5, 0.0, 1.0)
        end
        
        
        if (display_window_info == 1) then
          posx, poy, sizex, sizey = gh_imgui.get_window_pos_size()
          gh_imgui.text_rgba(string.format("%d  %d  %d  %d", posx, poy, sizex, sizey), 0.5, 0.5, 0.5, 1.0)
        end
        
      end
      
      gh_imgui.window_end()
    end

  end


  -----------------------------------------------------------------------------------------------
  -- Vulkan devices
  -----------------------------------------------------------------------------------------------


  if (show_vk_devices_box == 1) then

    if (vk.num_gpus > 0) then

      for i=1, vk.num_gpus do
        local gpu = vk.gpus[i]
        local window_flags = 0
        local window_name = "Vulkan - Physical Device " .. i
        local is_open = gh_imgui.window_begin(window_name, 350, 300, 360 + (i-1)*50, 110 + (i-1)*200, window_flags, pos_size_flag_first_use_ever, pos_size_flag_first_use_ever)

        if (is_open == 1) then
          gh_imgui.text_rgba("name: " .. gpu.name, 1.0, 1.0, 0.0, 1.0)
          gh_imgui.text_rgba("type: " .. gpu.device_type_str, 1.0, 1.0, 0.0, 1.0)
          gh_imgui.text_rgba(string.format("deviceID: %4X-%4X", gpu.vendor_id, gpu.device_id), 1.0, 1.0, 0.0, 1.0)
          gh_imgui.text_rgba(string.format("API version: %d.%d.%d", gpu.api_version_major, gpu.api_version_minor, gpu.api_version_patch), 1.0, 1.0, 0.0, 1.0)
          gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)
          gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)
          


          gh_imgui.text_rgba(string.format("# of memory heaps: %d", gpu.num_heaps), 1.0, 1.0, 0.0, 1.0)
          for j=1, gpu.num_heaps do
            local size = gpu.heaps[j]
            gh_imgui.text_rgba(string.format("heap %d - size %d MB", j, size), 1.0, 0.5, 0.0, 1.0)
          end
              
          
          gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)
          gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)
          
          
          gh_imgui.text_rgba(string.format("# of extensions: %d", gpu.num_extensions), 1.0, 1.0, 0.0, 1.0)
          for j=1, gpu.num_extensions do
            local ext_name = gpu.extensions[j]
            gh_imgui.text_rgba(string.format("%03d> %s", j, ext_name), 1.0, 0.5, 0.0, 1.0)
          end
          
          gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)
          gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)

          gh_imgui.text_rgba(string.format("# of layers: %d", gpu.num_layers), 1.0, 1.0, 0.0, 1.0)
          for j=1, gpu.num_layers do
            local layer_name = gpu.layers[j]
            gh_imgui.text_rgba(string.format("%03d> %s", j, layer_name), 1.0, 0.5, 0.0, 1.0)
          end
       
        
          -- vk_shader_core_properties_amd_get_value() is not implemented because vkGetPhysicalDeviceProperties2() Vulkan function
          -- currently crashes on Radeon GPUs with Adrenalin 18.3.4.
          --
          if (gpu.vendor_id == 4098) then
          
            gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)
            gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)

            local T = {
              "shaderEngineCount",
              "shaderArraysPerEngineCount",
              "computeUnitsPerShaderArray"
            }
            
            local n = #T
            for j=1, n do
              local name = T[j]
              local x = gh_renderer.vk_shader_core_properties_amd_get_value(i-1, name)
              gh_imgui.text_rgba(name .. ": " .. x, 1.0, 1.0, 0.0, 1.0)
            end
            
          end

           
            
          if (display_window_info == 1) then
            posx, poy, sizex, sizey = gh_imgui.get_window_pos_size()
            gh_imgui.text_rgba(string.format("%d  %d  %d  %d", posx, poy, sizex, sizey), 0.5, 0.5, 0.5, 1.0)
          end
        
        end
            
        gh_imgui.window_end()
      end
      
    end

    --]]

  end

end





-----------------------------------------------------------------------------------------------
-- GPU monitoring
-----------------------------------------------------------------------------------------------

if (show_gpu_box == 1) then

  if ((display_gpumon == 1) and (gml.num_gpus > 0)) then

    --gh_imgui.set_color(IMGUI_TITLE_BG_COLOR, 0.6, 0.6, 0.6, 1.0)
    --gh_imgui.set_color(IMGUI_TITLE_BG_ACTIVE_COLOR, 0.8, 0.7, 0.6, 1.0)
    --gh_imgui.set_color(IMGUI_WINDOW_BG_COLOR, 0.3, 0.3, 0.3, window_alpha)
    
    
    gh_imgui.set_color(IMGUI_TITLE_BG_COLOR, title_bg.r, title_bg.g, title_bg.b, title_bg.a)
    gh_imgui.set_color(IMGUI_TITLE_BG_ACTIVE_COLOR, title_bg_actv.r, title_bg_actv.g, title_bg_actv.b, title_bg_actv.a)
    gh_imgui.set_color(IMGUI_WINDOW_BG_COLOR, window_bg.r, window_bg.g, window_bg.b, window_alpha)
    
    
    if ((do_gpu_monitoring == 1) and (read_hw_sensors == 1)) then
      gh_gml.update()
    end

    
    for i=1, gml.num_gpus do
      local gpu = gml.gpus[i]
      local window_flags = 0
      local window_name = "GPU monitoring - GPU " .. i
      local is_open = gh_imgui.window_begin(window_name, 250, 300, 360 + (i-1)*100, 600 + (i-1)*60, window_flags, pos_size_flag_first_use_ever, pos_size_flag_first_use_ever)
      
      if (is_open == 1) then
      
        local widget_width = gh_imgui.get_content_region_available_width()
        
        
        
        if (read_hw_sensors == 1) then

          --gpu.core_temp = gh_gml.get_temperatures(i-1)
          local core_temp = gh_gml.get_temperatures(i-1)
          gpu.core_temp = core_temp
          
          --[[
          gpu.core_temp_num_values = gpu.core_temp_num_values + 1
          gpu.core_temp_values[gpu.core_temp_num_values] = core_temp
          
          local num_values = gpu.core_temp_num_values;
          if (num_values > gpu.plotline_max_values) then
            num_values = gpu.plotline_max_values;
          end
          
          gpu.values_count = num_values
          
          for k=0, num_values-1 do
            --local x = 2.0 * math.cos(elapsed_time + k*0.1) * math.sin(k * 3.14159 / 180.0)
            local x = gpu.core_temp_values[gpu.core_temp_num_values-k]
            gh_imgui.plotline_set_value1f(gpu.plotline_index, num_values-k-1, x)
          end
          --]]

          gpu.core_usage = gh_gml.get_usages(i-1)
          gpu.power_target = gh_gml.gpu_power_get_power_limit(i-1)
          gpu.power = gh_gml.gpu_power_get_current_value(i-1)
          
          gpu.core_clock, gpu.mem_clock = gh_gml.get_clocks(i-1)
          
        end
        
        
        
        gh_imgui.text_rgba(string.format("[ %s ]", gpu.name), 1.0, 1.0, 0.0, 1.0)
        gh_imgui.text_rgba(string.format("- deviceID: %4X-%4X", gpu.vendor_id, gpu.device_id), 1.0, 1.0, 0.0, 1.0)
        gh_imgui.text_rgba(string.format("- codename: %s", gpu.codename), 1.0, 0.8, 0.0, 1.0)
        gh_imgui.text_rgba(string.format("- cores/TMUs/ROPs: %d/%d/%d", gpu.cores, gpu.tmus, gpu.rops), 1.0, 1.0, 0.5, 1.0)
        gh_imgui.text_rgba(string.format("- driver: %s", gpu.driver), 1.0, 1.0, 0.5, 1.0)
        
        
        
  			if (do_gpu_monitoring == 1) then
        
  				-- NVIDIA (4318) or AMD (4098) GPUs
  				if ((gpu.vendor_id==4318) or (gpu.vendor_id==4098)) then
  				
  					--gpu.do_monitoring = gh_imgui.checkbox("Monitoring", gpu.do_monitoring)
  				
  					if (gpu.power_target > 0) then
  						gh_imgui.text_rgba(string.format("- power: %.1f (target: %.1f)", gpu.power, gpu.power_target) .. " %% TDP", 1.0, 0.5, 0.0, 1.0)
  					end
  				
  					gh_imgui.text_rgba("- core clock: " .. gpu.core_clock .. "MHz", 0.4, 0.75, 1.0, 1.0)
  					gh_imgui.text_rgba("- mem clocks: " .. gpu.mem_clock .. "MHz", 0.4, 0.75, 1.0, 1.0)
  			
  					gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)
  					gh_imgui.set_color(IMGUI_PLOTHISTOGRAM_COLOR, 0.0, 1.0, 0.0, 1.0)
  					gh_imgui.text_rgba("core usage: " .. gpu.core_usage .. "%%", 0.0, 1.0, 0.0, 1.0)
  					local pbval = gpu.core_usage/100.0
  					gh_imgui.progress_bar(pbval, 0, 0, string.format("%.1f", gpu.core_usage))


  					gh_imgui.widget(IMGUI_WIDGET_VERTICAL_SPACING)
  					gh_imgui.set_color(IMGUI_PLOTHISTOGRAM_COLOR, 1.0, 0.3, 0.0, 1.0)
  					gh_imgui.text_rgba("core temperature: " .. gpu.core_temp .. "°C", 1.0, 0.3, 0.0, 1.0)
  					pbval = gpu.core_temp/120.0
  					gh_imgui.progress_bar(pbval, 0, 0, string.format("%.1f°C", gpu.core_temp))

  				
  					--[[
  					if (gpu.values_count > 0) then
  						local ptype = 0 -- 0=line  -  1=histogram
  						local overlay = "GPU core temperature"
  						local values_offset = 0
  						local scale_min = 0.0
  						local scale_max = 100.0
  						local graph_size_x = widget_width

  						local graph_size_y = 100.0
  						
  						--gh_imgui.push_item_width(widget_width)
  						gh_imgui.set_color(IMGUI_PLOTLINES_COLOR, 1.0, 0.4, 0.0, 1.0)
  						gh_imgui.set_color(IMGUI_FRAME_BG_COLOR, 0.0, 0.1, 0.2, 0.4)
  									
  						gh_imgui.plotline_draw_v2(gpu.plotline_index, ptype, overlay, gpu.values_count, values_offset, scale_min, scale_max, graph_size_x, graph_size_y)
  						--gh_imgui.pop_item_width()
  					end
  					--]]
  				end
  			end
        
        if (display_window_info == 1) then
          posx, poy, sizex, sizey = gh_imgui.get_window_pos_size()
          gh_imgui.text_rgba(string.format("%d  %d  %d  %d", posx, poy, sizex, sizey), 0.5, 0.5, 0.5, 1.0)
        end
        
      end
      
      gh_imgui.window_end()
      
    end
  end
end



gh_imgui.frame_end()

--
-- ImGui end ---------------------------------------------------------------
----------------------------------------------------------------------------


--]]



--gh_utils.thread_sleep(20)



if ((cpu.is_rpi==1) and (is_gles == 1)) then
  mouse_draw(camera_ortho, mouse_quad_x, mouse_quad_y)
end

