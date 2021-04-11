@echo off

cd C:\Factory_Tools\SMBIOS_Tool_Windows\

if "%1"=="SSN" (
  SET STRING=01,07,S,
  SET STRING_2=03,07,S,
) else if "%1"=="ISN" (
  SET STRING=02,07,S,
) else if "%1"=="UUID" (
  SET STRING=01,08,S,
) else (
  echo SMBIOS_Write.bat {Item} {Value}
  echo Item: SSN
  echo       ISN
  echo       UUID
  GOTO :EOF
)

set VALUE=%2

IF EXIST temp (
	del temp
)

REM Check if existing SMBIOS

IF NOT EXIST \\?\harddisk4partition1\OEM\SMBIOS.CFG (
	copy SMBIOS_org.CFG SMBIOS\SMBIOS.CFG /y >nul
	echo NOT EXIST SMBIOS in DPP, Provision first...
	QCFactoryTool.exe /PROVISION SMBIOS /TYPE OEM
	echo Now Write Value...
)

REM Write SMBIOS INFO

copy \\?\harddisk4partition1\OEM\SMBIOS.CFG . /y >nul


if "%1"=="SSN" (

	for /f "tokens=1* delims=:" %%i in ('findstr /n ".*" SMBIOS.CFG') do (
		if "%%j"=="" (echo.>>temp) else (
			echo %%j| findstr %STRING%>nul&&(call echo %STRING%"%VALUE%">>temp)||(echo %%j>>temp)
		)
	)
	copy temp SMBIOS.CFG /y >nul&&del temp
	
	for /f "tokens=1* delims=:" %%i in ('findstr /n ".*" SMBIOS.CFG') do (
		if "%%j"=="" (echo.>>temp) else (
			echo %%j| findstr %STRING_2%>nul&&(call echo %STRING_2%"%VALUE%">>temp)||(echo %%j>>temp)
		)
	)
	
	copy temp SMBIOS.CFG /y >nul&&del temp

) else if "%1"=="ISN" (
	
	for /f "tokens=1* delims=:" %%i in ('findstr /n ".*" SMBIOS.CFG') do (
		if "%%j"=="" (echo.>>temp) else (
			echo %%j| findstr %STRING%>nul&&(call echo %STRING%"%VALUE%">>temp)||(echo %%j>>temp)
		)
	)
	copy temp SMBIOS.CFG /y >nul&&del temp
	
) else if "%1"=="UUID" (

	for /f "tokens=1* delims=:" %%i in ('findstr /n ".*" SMBIOS.CFG') do (
		if "%%j"=="" (echo.>>temp) else (
			echo %%j| findstr %STRING%>nul&&(call echo %STRING%"%VALUE%">>temp)||(echo %%j>>temp)
		)
	)
	copy temp SMBIOS.CFG /y >nul&&del temp

)

copy SMBIOS.CFG SMBIOS /y >nul
QCFactoryTool.exe /PROVISION SMBIOS /TYPE OEM
del SMBIOS.CFG

:end
