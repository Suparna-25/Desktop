@echo off

cd C:\Factory_Tools\SMBIOS_Tool_Windows\

if "%1"=="SSN" (
  SET POSITION=73
) else if "%1"=="ISN" (
  SET POSITION=84
) else if "%1"=="UUID" (
  SET POSITION=74
) else (
  echo SMBIOS_Read.bat {Item}
  echo Item: SSN
  echo       ISN
  echo       UUID
  GOTO :EOF
)

REM Check if existing SMBIOS

IF NOT EXIST \\?\harddisk4partition1\OEM\SMBIOS.CFG (
	echo ERROR: Device doesn't be provisioned SMBIOS
	GOTO :EOF
)

REM Write SMBIOS INFO

copy \\?\harddisk4partition1\OEM\SMBIOS.CFG . /y >nul


if "%1"=="SSN" (

	@for /f  "tokens=1* delims=:" %%i in ('findstr /n .* SMBIOS.CFG' ) do (
		if %%i equ %POSITION% (	
		
			set SSN_RESULT=%%j
			
		)
	)

) else if "%1"=="ISN" (

	@for /f  "tokens=1* delims=:" %%i in ('findstr /n .* SMBIOS.CFG' ) do (
		if %%i equ %POSITION% (	
		
			set ISN_RESULT=%%j
			
		)
	)

) else if "%1"=="UUID" (

	for /f  "tokens=1* delims=:" %%i in ('findstr /n .* SMBIOS.CFG' ) do (
		if %%i equ %POSITION% (
			
			set UUID_RESULT=%%j
			
		)
	)
)

if "%1"=="SSN" (
  echo %SSN_RESULT:~9,15%
) else if "%1"=="ISN" (
  echo %ISN_RESULT:~9,17%
) else if "%1"=="UUID" (
  echo %UUID_RESULT:~9,16%
) else (
  echo SMBIOS_Read.bat {Item}
  echo Item: SSN
  echo       ISN
  echo       UUID
  GOTO :EOF
)

del SMBIOS.CFG

:end
