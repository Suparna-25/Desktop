@echo off
set CSC_UUID=%1%A
call SSN_TP370QL\SMBIOS_Tool_Windows\SMBIOS_Write.bat UUID %CSC_UUID%
:end