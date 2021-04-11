



function kx_vk_command_buffer_create()
  local cmd = gh_renderer.command_list_create(0)
  return cmd
end  

function kx_vk_command_buffer_open(cmd)
  gh_renderer.command_list_open(cmd)
end  

function kx_vk_get_command_buffer()
  return kx.cmdbuffer
end  

function kx_vk_command_buffer_exe(cmd, waitgpu)
  gh_renderer.command_list_close(cmd)
  gh_renderer.command_list_execute(cmd)
  if (waitgpu == 1) then
    gh_renderer.wait_for_gpu()
  end
end  




function kx_vk_init_begin()

  kx.cmdbuffer = kx_vk_command_buffer_create()
  --kx_vk_command_buffer_open(kx.cmdbuffer)
 
end


function kx_vk_init_end()

  --kx_vk_command_buffer_exe(kx.cmdbuffer, 1)
  kx_vk_uniform_buffer_update_font(kx.ub0)

end




function kx_vk_frame_begin(r, g, b)

  gh_renderer.command_list_open(kx.cmdbuffer)
  gh_renderer.clear_color_depth_buffers(r, g, b, 1.0, 1.0)
  gh_renderer.vk_command_list_render_pass_begin(kx.cmdbuffer, 0)
  
  gh_renderer.set_viewport_scissor(0, 0, kx.winW, kx.winH)

end  


function kx_vk_frame_end()

  gh_renderer.vk_command_list_render_pass_end(kx.cmdbuffer)
  gh_renderer.command_list_close(kx.cmdbuffer)
  gh_renderer.command_list_execute(kx.cmdbuffer)
 
end  








--[[

Uniform buffer structure in the vertex shader:

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

--]]

function kx_vk_update_camera_transform(cam, ub)
  local vec4_size = 16
  local buffer_offset_bytes = vec4_size
  gh_gpu_buffer.set_matrix4x4(ub, buffer_offset_bytes, cam, "camera_view_projection")
end

function kx_vk_update_object_transform(obj, ub, block_index)
  local vec4_size = 16 -- viewport
  local mat4x4_size = 64 -- camera
  local block_size = mat4x4_size 
  local buffer_offset_bytes = vec4_size + mat4x4_size + (block_size * block_index)
  gh_gpu_buffer.set_matrix4x4(ub, buffer_offset_bytes, obj, "object_global_transform")
end

function kx_vk_update_viewport_transform(vp, ub)
  local buffer_offset_bytes = 0
  gh_gpu_buffer.set_value_4f(ub, buffer_offset_bytes, vp.x, vp.y, vp.w, vp.h)
end

function kx_vk_uniform_buffer_create(ub_size)
  --local vec4_size = 4*4 -- one vec4
  --local mat4x4_size = 16*4 -- one matrix
  --block_size = mat4x4_size * 2 -- two matrices
  --local num_font_objects = 1
  --local ub_size = vec4_size + (block_size * num_font_objects)
  local ub = gh_gpu_buffer.create("UNIFORM", "NONE", ub_size, "")
  gh_gpu_buffer.bind(ub)
  gh_gpu_buffer.map(ub)
  return ub
end  


function kx_vk_uniform_buffer_cleanup(ub)

  gh_gpu_buffer.unmap(ub)

end


function kx_vk_uniform_buffer_update_font(ub)
  local viewport = {x=0, y=0, w=kx.winW, h=kx.winH}
  --print("kx_vk_uniform_buffer_update_font - w=" .. kx.winW .. " - h=" .. kx.winH )
  kx_vk_update_viewport_transform(viewport, ub)
  kx_vk_update_camera_transform(kx.camera_ortho, ub)
end






------------------------------------------------------------------------
--
function kx_vk_resize()

  kx_vk_uniform_buffer_update_font(kx.ub0)

end


------------------------------------------------------------------------
--
function kx_vk_terminate()
  kx_vk_uniform_buffer_cleanup(kx.ub0)
  kx.ub0 = 0
end  





------------------------------------------------------------------------
--
function kx_vk_osi_init()

  ------------------------------------------------------------------------
  --
  kx.ub0 = kx_vk_uniform_buffer_create(512)
  
  
   --kx_vk_uniform_buffer_update_font(kx.ub0)
 
  
  
  ------------------------------------------------------------------------
  --
  local gpu_index = gh_renderer.get_current_gpu()
  kx.osi_info.renderer_name = gh_renderer.vk_gpu_get_name(gpu_index)
  local major, minor, patch = gh_renderer.vk_gpu_get_api_version(gpu_index)
  kx.osi_info.api_version = string.format("Vulkan %d.%d.%d", major, minor, patch)


  -----------------------------------------------------------------------
  --
  kx.font_h1 = gh_font.create(kx.framework_dir .. "data/fonts/HACKED.ttf", 30, 512, 512)
  gh_font.build_texture(kx.font_h1)
  kx.font_h1_tex = gh_font.get_texture(kx.font_h1)
  

  kx.font_p = gh_font.create(kx.framework_dir .. "data/fonts/Hack-Regular.ttf", 20, 512, 512)
  gh_font.build_texture(kx.font_p)
  kx.font_p_tex = gh_font.get_texture(kx.font_p)

  -- Init static text.
  --
  --[[
  r, g, b = gh_utils.hex_color_to_rgb("#ffff00")
  gh_font.clear(font_p)
  gh_font.text_2d(font_p, 20, 60, r, g, b, 1.0, "GeeXLab + Vulkan API")
  gh_font.update(font_p, 0)
  --]]


  -----------------------------------------------------------------------
  --
  local vertex_shader = kx.framework_dir .. "data/spirv/06-vs.spv"
  local pixel_shader = kx.framework_dir .. "data/spirv/06-ps.spv"
  kx.font_prog = gh_gpu_program.vk_create_from_spirv_module_file("kx_font_prog",   vertex_shader, "main",     pixel_shader, "main",    "", "",    "", "",     "", "",    "", "") 


  -----------------------------------------------------------------------
  --
  kx.sampler = gh_renderer.texture_sampler_create("LINEAR", "CLAMP", 0.0, 0)
   



  -----------------------------------------------------------------------
  --

  kx.ds_font_p = gh_renderer.vk_descriptorset_create()
  local ub_binding_point_ = 0
  gh_renderer.vk_descriptorset_add_resource_gpu_buffer(kx.ds_font_p, kx.ub0, ub_binding_point_, VK_SHADER_STAGE_VERTEX)
  local tex_binding_point_ = 1
  gh_renderer.vk_descriptorset_add_resource_texture(kx.ds_font_p, kx.font_p_tex, kx.sampler, tex_binding_point_, VK_SHADER_STAGE_FRAGMENT)
  gh_renderer.vk_descriptorset_build(kx.ds_font_p)
  gh_renderer.vk_descriptorset_update(kx.ds_font_p)



  kx.ds_font_h1 = gh_renderer.vk_descriptorset_create()
  ub_binding_point_ = 0
  gh_renderer.vk_descriptorset_add_resource_gpu_buffer(kx.ds_font_h1, kx.ub0, ub_binding_point_, VK_SHADER_STAGE_VERTEX)
  tex_binding_point_= 1
  gh_renderer.vk_descriptorset_add_resource_texture(kx.ds_font_h1, kx.font_h1_tex, kx.sampler, tex_binding_point_, VK_SHADER_STAGE_FRAGMENT)
  gh_renderer.vk_descriptorset_build(kx.ds_font_h1)
  gh_renderer.vk_descriptorset_update(kx.ds_font_h1)



  -----------------------------------------------------------------------
  --

  kx.pso_font_p = gh_renderer.pipeline_state_create("pso_font_p", kx.font_prog, "")
  local pso = kx.pso_font_p
  gh_renderer.pipeline_state_set_attrib_4i(pso, "DEPTH_TEST", 0, 0, 0, 0)
  gh_renderer.pipeline_state_set_attrib_4i(pso, "FILL_MODE", POLYGON_MODE_SOLID, 0, 0, 0)
  gh_renderer.pipeline_state_set_attrib_4i(pso, "PRIMITIVE_TYPE", PRIMITIVE_TRIANGLE, 0, 0, 0)
  gh_renderer.pipeline_state_set_attrib_4i(pso, "CULL_MODE", POLYGON_FACE_NONE, 0, 0, 0)
  gh_renderer.pipeline_state_set_attrib_4i(pso, "CCW", 0, 0, 0, 0)
  gh_renderer.pipeline_state_set_attrib_4i(pso, "BLENDING", 1, 0, 0, 0)
  gh_renderer.pipeline_state_set_attrib_4i(pso, "BLENDING_FACTORS_COLOR", BLEND_FACTOR_ONE, BLEND_FACTOR_ONE, 0, 0)
  kx.pso_font_p_valid = gh_renderer.vk_pipeline_state_build(pso, kx.ds_font_p)


  kx.pso_font_h1 = gh_renderer.pipeline_state_create("pso_font_h1", kx.font_prog, "")
  pso = kx.pso_font_h1
  gh_renderer.pipeline_state_set_attrib_4i(pso, "DEPTH_TEST", 0, 0, 0, 0)
  gh_renderer.pipeline_state_set_attrib_4i(pso, "FILL_MODE", POLYGON_MODE_SOLID, 0, 0, 0)
  gh_renderer.pipeline_state_set_attrib_4i(pso, "PRIMITIVE_TYPE", PRIMITIVE_TRIANGLE, 0, 0, 0)
  gh_renderer.pipeline_state_set_attrib_4i(pso, "CULL_MODE", POLYGON_FACE_NONE, 0, 0, 0)
  gh_renderer.pipeline_state_set_attrib_4i(pso, "CCW", 0, 0, 0, 0)
  gh_renderer.pipeline_state_set_attrib_4i(pso, "BLENDING", 1, 0, 0, 0)
  gh_renderer.pipeline_state_set_attrib_4i(pso, "BLENDING_FACTORS_COLOR", BLEND_FACTOR_ONE, BLEND_FACTOR_ONE, 0, 0)
  kx.pso_font_h1_valid = gh_renderer.vk_pipeline_state_build(pso, kx.ds_font_h1)
  
  
  
  
  
  
  
  
  
  

  ---[[
  local pixel_format = PF_U8_RGBA
  kx.tex_3dapi_logo = gh_texture.create_from_file_v5(kx.framework_dir .. "data/textures/vk.png", pixel_format)
  kx.logo_size.w = 150
  kx.logo_size.h = 40
  kx.logo_quad = gh_mesh.create_quad(kx.logo_size.w, kx.logo_size.h)

  
  vertex_shader = kx.framework_dir .. "data/spirv/03-vs.spv"
  pixel_shader = kx.framework_dir .. "data/spirv/03-ps.spv"
  kx.texture_prog = gh_gpu_program.vk_create_from_spirv_module_file("kx_texture_prog",   vertex_shader, "main",     pixel_shader, "main",    "", "",    "", "",     "", "",    "", "") 

  

  kx.ds_tex = gh_renderer.vk_descriptorset_create()
  ub_binding_point_ = 0
  gh_renderer.vk_descriptorset_add_resource_gpu_buffer(kx.ds_tex, kx.ub0, ub_binding_point_, VK_SHADER_STAGE_VERTEX)
  tex_binding_point_ = 1
  gh_renderer.vk_descriptorset_add_resource_texture(kx.ds_tex, kx.tex_3dapi_logo, kx.sampler, tex_binding_point_, VK_SHADER_STAGE_FRAGMENT)
  gh_renderer.vk_descriptorset_build(kx.ds_tex)
  gh_renderer.vk_descriptorset_update(kx.ds_tex)

  kx.pso_tex = gh_renderer.pipeline_state_create("kx_pso_tex", kx.texture_prog, "")
  pso = kx.pso_tex
  gh_renderer.pipeline_state_set_attrib_4i(pso, "DEPTH_TEST", 0, 0, 0, 0)
  gh_renderer.pipeline_state_set_attrib_4i(pso, "FILL_MODE", POLYGON_MODE_SOLID, 0, 0, 0)
  gh_renderer.pipeline_state_set_attrib_4i(pso, "PRIMITIVE_TYPE", PRIMITIVE_TRIANGLE, 0, 0, 0)
  gh_renderer.pipeline_state_set_attrib_4i(pso, "CULL_MODE", POLYGON_FACE_NONE, 0, 0, 0)
  gh_renderer.pipeline_state_set_attrib_4i(pso, "CCW", 0, 0, 0, 0)
  gh_renderer.pipeline_state_set_attrib_4i(pso, "BLENDING", 1, 0, 0, 0)
  gh_renderer.pipeline_state_set_attrib_4i(pso, "BLENDING_FACTORS_COLOR", BLEND_FACTOR_ONE, BLEND_FACTOR_ONE, 0, 0)
  kx.pso_tex_valid = gh_renderer.vk_pipeline_state_build(pso, kx.ds_tex)
  --]]
  

end



------------------------------------------------------------------------
--
function kx_vk_osi_display(osi_info)
		
  -- We update only font_h1 transform because font_p will use the same transform.
  --
  kx_vk_update_object_transform(kx.font_h1, kx.ub0, 0)
  
  kx_osi_draw_text(osi_info)  


  if (kx.pso_tex_valid == 1) then
    gh_renderer.vk_descriptorset_bind(kx.ds_tex)
    gh_renderer.pipeline_state_bind(kx.pso_tex)
    gh_object.set_position(kx.logo_quad, kx.winW/2-kx.logo_size.w/2-10.0, -kx.winH/2+kx.logo_size.h/2+10, 0)
    kx_vk_update_object_transform(kx.logo_quad, kx.ub0, 1) -- Index = 1 ... 
    gh_object.render(kx.logo_quad)
  end
  
end





function kx_vk_osi_update(osi_info)
		
  -- We update only font_h1 transform because font_p will use the same transform.
  --
  kx_vk_update_object_transform(kx.font_h1, kx.ub0, 0)

  kx_vk_uniform_buffer_update_font(kx.ub0)

  if (kx.pso_tex_valid == 1) then
    gh_object.set_position(kx.logo_quad, kx.winW/2-kx.logo_size.w/2-10.0, -kx.winH/2+kx.logo_size.h/2+10, 0)
    kx_vk_update_object_transform(kx.logo_quad, kx.ub0, 1) -- Index = 1 ... 
  end
  
end


function kx_vk_osi_render(osi_info)
  
  if ((kx.pso_font_h1_valid==1) and (string.len(osi_info.demo_caption) > 0)) then
    gh_renderer.vk_descriptorset_bind(kx.ds_font_h1)
    gh_renderer.pipeline_state_bind(kx.pso_font_h1)
    --gh_texture.bind(kx.font_h1_tex, 0)
    gh_font.render(kx.font_h1)
  end


  if (kx.pso_font_p_valid == 1) then
    gh_renderer.vk_descriptorset_bind(kx.ds_font_p)
    gh_renderer.pipeline_state_bind(kx.pso_font_p)
    gh_font.render(kx.font_p)
  end
  
  
  if (kx.pso_tex_valid == 1) then
    gh_renderer.vk_descriptorset_bind(kx.ds_tex)
    gh_renderer.pipeline_state_bind(kx.pso_tex)
    gh_object.render(kx.logo_quad)
  end
  
end
