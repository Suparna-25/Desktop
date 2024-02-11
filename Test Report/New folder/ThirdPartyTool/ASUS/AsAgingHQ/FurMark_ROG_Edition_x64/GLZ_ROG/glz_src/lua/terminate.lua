

if (logfile ~= nil) then
  logfile:close()
end

if (cpu.linux_cpu_file ~= nil) then
  cpu.linux_cpu_file:close()
end

if (cpu.rpi_temp_file ~= nil) then
  cpu.rpi_temp_file:close()
end


if (gh_utils.get_platform() == 1) then
  gh_utils.cpu_usage_cleanup()
end

gh_imgui.terminate()
