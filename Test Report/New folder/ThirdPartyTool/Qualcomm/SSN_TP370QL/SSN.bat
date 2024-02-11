@echo off
set CSC_SSN=%1
call SSN_TP370QL\SMBIOS_Tool_Windows\SMBIOS_Write.bat SSN %CSC_SSN%
:end