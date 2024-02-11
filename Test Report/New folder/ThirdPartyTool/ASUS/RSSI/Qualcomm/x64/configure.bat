@echo off
@rem #
@rem # Script to configure registry keys for PETool
@rem #
@rem # $DateTime: 05/22/2015 $
@rem # $Author: guoyongh $

if /i "%1" equ "help" (
	echo:
    goto usage
)

if /i "%1" equ "" (
    echo: 
    echo ERROR: no command
    goto usage
)

rem set DeviceID=PCI\VEN_168C&DEV_0034&SUBSYS_03001028
set DeviceID=PCI\VEN_168C
set DevConExe=devcon.exe

if /i "%1" equ "print" (
	echo:
    call :getDriverKey
    goto :EOF
)

if /i "%1" equ "enable" (
	if /i "%2" equ "smartnet" (
		echo:
		echo INFO: Enable SmartNet registry key
		call :enableSmartNet
		goto :EOF
	)
)

rem ---------------------------------------------------------------------------
rem WLAN GET DRIVER KEY
rem ---------------------------------------------------------------------------
:getDriverKey
echo INFO: Try to find driver key for "%DeviceID%"
for /f %%a in ('reg query HKLM\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318} /f "%DeviceID%" /d /s') DO (
	set "p1=%%a"
	call :queryDeviceDriverKey
)
set "p1="
call :printDriverKey
goto :EOF
:queryDeviceDriverKey
if /i "%p1:~0,96%" equ "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}" (
	set driverKey=%p1:~0,101%
	goto :EOF
)
goto :EOF
:printDriverKey
echo INFO: The driver key is "%driverkey%
goto :EOF

:enableSmartNet
reg add "%driverKey%" /v SmartNetEnable /t REG_DWORD /d 1 /f
"DevConExe% disable "%DeviceID%*"
"DevConExe% enable "%DeviceID%*"
goto :EOF

:usage
echo:
echo USAGE: %0 [Command] [Parameter]
echo:
echo The following commands are available
echo help                       - Displays a list of commands.
echo print                      - Print the driver key.
echo enable  smartnet           - Enable SmartNetEnable registry key
echo For example: %0 enable smartnet
exit /b 2