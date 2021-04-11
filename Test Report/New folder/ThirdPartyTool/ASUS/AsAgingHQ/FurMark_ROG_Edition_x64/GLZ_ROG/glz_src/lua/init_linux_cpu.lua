--[[
GeeXLab - GL-Z
CPU monitoring - Linux / Raspbian
--]]  





-- https://www.raspberrypi.org/visualising-core-load-on-the-pi-2/ 
-- https://github.com/davidsblog/rCPU
-- http://phoxis.org/2013/09/05/finding-overall-and-per-core-cpu-utilization/
--
--[[
+-------+------------+-------------------------------------------------------+
|   1   |    cpuxxx  |   CPU                                                 |
+-------+------------+-------------------------------------------------------+
|   2   |    user    |   Time spent in user mode                             |
+-------+------------+-------------------------------------------------------+
|   3   |    nice    |   Time spent in user mode with low priority           |
+-------+------------+-------------------------------------------------------+
|   4   |   system   |   Time spent in system mode                           |
+-------+------------+-------------------------------------------------------+
|   5   |    idle    |   Time spent in idle task                             |
+-------+------------+-------------------------------------------------------+
|   6   |   iowait   |   Time waiting for I/O to complete                    |
+-------+------------+-------------------------------------------------------+
|   7   |     irq    |   Time servicing interrupts                           |
+-------+------------+-------------------------------------------------------+
|   8   |   softirq  |   Time servicing softirqs                             |
+-------+------------+-------------------------------------------------------+
|   9   |    steal   |   Time spent in other OSes when in virtualized env    |
+-------+------------+-------------------------------------------------------+
|  10   |    quest   |   Time spent running a virtual CPU for guest OS       |
+-------+------------+-------------------------------------------------------+
|  11   | quest_nice |   Time spent running niced guest                      |
+-------+------------+-------------------------------------------------------+
--]]

function Linux_CPU_Read_Num_Cores(cpu_file)
  local num_cores = 0
  cpu_file:seek("set", 0)
  local quit = 0
  while (quit == 0) do
    local line = cpu_file:read()
    if not line then break end
    if (line:find("cpu", 1) == nil) then
      break
    end
    if (line:find("cpu%d", 1) ~= nil) then
      num_cores = num_cores + 1
    end
  end
  return num_cores
end  

function Linux_CPU_Read_Stat(cpu)
  cpu.linux_cpu_file:seek("set", 0)
  for c=1, cpu.core_count+1 do 
    local line = cpu.linux_cpu_file:read()
    local core = cpu.linux_cores[c]
    local sep = " "
    local matchfunc = string.gmatch(line, "([^"..sep.."]+)")
    local i=1
    for str in matchfunc do
      if (i == 1) then
        core.fields[i] = str
      else
        local x = tonumber(str)
        core.fields[i] = x
      end
      i = i+1
    end
    core.num_fields = i-1
  end
end  


function Linux_CPU_Update_Ticks(cpu)
  for c=1, cpu.core_count+1 do 
    local core = cpu.linux_cores[c]
    local k=0
    local total_tick = 0
    for k=2, core.num_fields do
      total_tick = total_tick + core.fields[k]
    end 
    core.total_dtick = total_tick - core.prev_total_tick
    core.prev_total_tick = total_tick
  
    local idle_tick = core.fields[5]
    core.idle_dtick = idle_tick - core.prev_idle_tick
    core.prev_idle_tick = idle_tick

    core.usage =  ((core.total_dtick - core.idle_dtick) / core.total_dtick) * 100
  end
end  



function Linux_CPU_New_Core()
  local core = { fields={}, num_fields=0, total_dtick=0, prev_total_tick=0, idle_dtick=0, prev_idle_tick=0, usage=0 }
  return core
end  


function Linux_CPU_Init(cpu)
  
--[[  
processor	: 0
model name	: ARMv7 Processor rev 4 (v7l)
BogoMIPS	: 38.40
Features	: half thumb fastmult vfp edsp neon vfpv3 tls vfpv4 idiva idivt vfpd32 lpae evtstrm crc32 
CPU implementer	: 0x41
CPU architecture: 7
CPU variant	: 0x0
CPU part	: 0xd03
CPU revision	: 4

Hardware	: BCM2835

--]]
  
  local cpuinfo_file = io.open("/proc/cpuinfo", "r")
  if (cpuinfo_file ~= nil) then
    cpuinfo_file:seek("set", 0)
    local quit = 0
    local cpu_name_found = 0
    while (quit == 0) do
      local line = cpuinfo_file:read()
      if not line then break end
      if ((cpu_name_found == 0) and (line:find("model name") ~= nil)) then
        cpu.name = line:sub(14)
        print("CPU name: " .. cpu.name)
        cpu_name_found = 1
      end
      if (line:find("Hardware") ~= nil) then
        cpu.rpi_hardware = line:sub(12)
        print("Hardware: " .. cpu.rpi_hardware)
      end
    end
    cpuinfo_file:close()
  end
  

  
  
  

  cpu.linux_cpu_file = io.open("/proc/stat", "r")
  if (cpu.linux_cpu_file ~= nil) then
    cpu.core_count = Linux_CPU_Read_Num_Cores(cpu.linux_cpu_file)
    print("Linux_CPU_Init() - cpu.core_count: " .. cpu.core_count-1)

    for c=1, cpu.core_count+1 do
      cpu.linux_cores[c] = Linux_CPU_New_Core()
      cpu.usage[c] = 0
    end

    Linux_CPU_Read_Stat(cpu)
    Linux_CPU_Update_Ticks(cpu)
    
    for c=2, cpu.core_count+1 do
      local core = cpu.linux_cores[c]
      local usage = core.usage
      cpu.usage[c] = usage
    end
    cpu.overall_usage = cpu.linux_cores[1].usage
  end
    
  cpu.rpi_temp_file = io.open("/sys/class/thermal/thermal_zone0/temp", "r")
  
  
end


function Linux_CPU_Update(cpu)
  if (cpu.linux_cpu_file ~= nil) then
    cpu.linux_cpu_file:flush()
    Linux_CPU_Read_Stat(cpu)
    Linux_CPU_Update_Ticks(cpu)
    
    for c=2, cpu.core_count+1 do
      local core = cpu.linux_cores[c]
      local usage = core.usage
      cpu.usage[c] = usage
    end
    cpu.overall_usage = cpu.linux_cores[1].usage
  end
end


function RPi_Read_Temperature(cpu)
  
  if (cpu.rpi_temp_file ~= nil) then
    cpu.rpi_temp_file:flush()
    cpu.rpi_temp_file:seek("set", 0)
    local line = cpu.rpi_temp_file:read()
    --print(line)
    cpu.rpi_core_temp = tonumber(line) / 1000
    --print(string.format("CPU temp: %.1f °C", cpu.rpi_core_temp))
  end
  
end

