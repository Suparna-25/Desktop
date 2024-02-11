GL-Z > OpenGL/Vulkan Information Utility
Copyright (c)2018 Geeks3D, All rights reserved.
https://geeks3d.com/glz/
contact: 
- jegx@geeks3d.com 
- @JeGX


***************************************************
THIS SOFTWARE IS PROVIDED 'AS-IS', WITHOUT ANY 
EXPRESS OR IMPLIED WARRANTY. IN NO EVENT WILL 
THE AUTHOR BE HELD LIABLE FOR ANY DAMAGES ARISING 
FROM THE USE OF THIS SOFTWARE.
***************************************************
GL-Z is a simple OpenGL and Vulkan information utility.
Depending on the platform, GL-Z displays the following data:

- Windows: 
  - CPU monitoring* 
  - OpenGL info
  - Vulkan info
  - GPU monitoring

- Linux: 
  - CPU monitoring
  - OpenGL info
  - Vulkan info
  - GPU monitoring

- Raspberry Pi (Raspbian): 
  - CPU monitoring
  - OpenGL info

- Tinker Board: 
  - CPU monitoring
  - OpenGL info

- macOS
  - OpenGL info



(*): On Windows 10, the CPU monitoring initialization can last
     up to 20 seconds the first time... 


On Linux based platforms, just launch one of the following shell 
scripts:

- START_GLZ.sh : launch GL-Z in monitoring mode (default).
  In this mode, GL-Z does not eat CPU or GPU cycles. 
  Perfect for monitoring needs.

- START_GLZ_CPU_Monitoring.sh : launch GL-Z in CPU monitoring mode.
  In this mode, GL-Z does not eat CPU or GPU cycles and displays
  the CPU monitoring window only.

- START_GLZ_GLMEM.sh : launch GL-Z in OpenGL memory usage monitoring mode.


GL-Z is coded with GeeXLab.
More information about GeeXLab can be found here:
https://geeks3d.com/geexlab/
@GeeXLab
