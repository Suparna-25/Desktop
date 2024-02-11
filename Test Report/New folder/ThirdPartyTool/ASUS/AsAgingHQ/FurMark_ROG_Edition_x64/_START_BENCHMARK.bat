@echo off

rem ===========================================================
rem Command line options:
rem -furmark_torus or -rog03          => OpenGL test
rem -furmark_torus_memtest or -rog07  => OpenGL test + GPU memtest
rem -furmark_torus_vk or -rog04       => Vulkan test
rem -furmark_rog_vk  or -rog02        => Vulkan test
rem -furmark_rog or -rog01            => OpenGL test
rem -scene02  or -rog08               => OpenGL test
rem -tessmark_vk or -rog06            => Vulkan test
rem -tessmark or -rog05               => OpenGL test
rem -tessmark_tesslevel=x             => tessellation level: from 1.0 to 64.0
rem -gpu_index=x                      => zero-based GPU index for Vulkan tests (first GPU is 0). 
rem -width=w                          => window width
rem -height=h                         => window height
rem -fullscreen                       => fullscreen mode enabled
rem -benchmark                        => benchmark mode (60 seconds)
rem -scan                             => starts the artifact scanner
rem -tempgraph                        => displays the temperature graph
rem -nogpumon                         => disables the gpu monitoring
rem ===========================================================


echo ASUS FurMark ROG Edition
echo -------------------------
echo Benchmarking...


rem --------------------------------------------------------------------------
rem ROG FurMark with ROG logo - OpenGL
FurMark_ROG_Edition_x64.exe -nogui -width=1920 -height=1080 -furmark_rog -benchmark -fullscreen
rem --------------------------------------------------------------------------



rem --------------------------------------------------------------------------
rem ROG FurMark with ROG logo - Vulkan
rem - first GPU: -gpu_index=0
rem - second GPU: -gpu_index=1
rem - third GPU: -gpu_index=2
rem FurMark_ROG_Edition_x64.exe -nogui -width=1920 -height=1080 -furmark_rog_vk -gpu_index=0 -benchmark -fullscreen
rem --------------------------------------------------------------------------



rem --------------------------------------------------------------------------
rem Original FurMark settings - OpenGL
rem FurMark_ROG_Edition_x64.exe -nogui -width=1920 -height=1080 -furmark_torus -benchmark -fullscreen
rem FurMark_ROG_Edition_x64.exe -nogui -width=2560 -height=1440 -furmark_torus -benchmark -fullscreen
rem FurMark_ROG_Edition_x64.exe -nogui -width=3840 -height=2160 -furmark_torus -benchmark -fullscreen
rem --------------------------------------------------------------------------



rem --------------------------------------------------------------------------
rem Original FurMark settings - Vulkan
rem - first GPU: -gpu_index=0
rem - second GPU: -gpu_index=1
rem - third GPU: -gpu_index=2
rem FurMark_ROG_Edition_x64.exe -nogui -width=1920 -height=1080 -furmark_torus_vk -gpu_index=0 -benchmark -fullscreen
rem --------------------------------------------------------------------------



rem --------------------------------------------------------------------------
rem TessMark - OpenGL
rem FurMark_ROG_Edition_x64.exe -nogui -width=1920 -height=1080 -tessmark -benchmark -fullscreen
rem --------------------------------------------------------------------------

rem --------------------------------------------------------------------------
rem TessMark - Vulkan
rem - first GPU: -gpu_index=0
rem - second GPU: -gpu_index=1
rem - third GPU: -gpu_index=2
rem FurMark_ROG_Edition_x64.exe -nogui -width=1920 -height=1080 -tessmark_vk -gpu_index=0 -benchmark -fullscreen
rem --------------------------------------------------------------------------


