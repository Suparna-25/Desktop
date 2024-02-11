
if (gh_utils.get_platform() == 1)  then
  print("gh_utils.cpu_usage_init()...")
  gh_utils.cpu_usage_init()
  print("gh_utils.cpu_usage_init() Ok.")
  gh_utils.shared_variable_set_value_4i("wmi_init_done", 1, 0, 0, 0)
end  

