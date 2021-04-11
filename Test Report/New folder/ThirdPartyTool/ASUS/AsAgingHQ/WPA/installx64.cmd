::
:: Batch file to install wpa external bits for EEAP partners.
::

@echo off

set curdir=%cd%
set arch=AMD64

::
:: Install the right WPT.
::
@echo on
@echo ++++++++++++++++
@echo Installing WPT.
@echo ++++++++++++++++
@echo off

start /wait installers\WPTx64-x86_en-us.msi
set copyflag=1

@echo off
set err=%errorlevel%
if %err% NEQ 0 (
    echo !!!!!!!!!!!!!!!!!!!!!!!!!!!
    echo Error during installation.
    echo !!!!!!!!!!!!!!!!!!!!!!!!!!!
    goto :EOF
) else if %copyflag% NEQ 1 (
    @echo on
    @echo +++++++++++++++++++++++++
    @echo Installation successful.
    @echo +++++++++++++++++++++++++
    @echo off
    goto :EOF
) 

::
:: Figureout the location where WPT is installed
::
@echo off
FOR /F "tokens=3,4,5,6,7,8 delims== " %%A IN ('reg query hkcr\wpa\shell\open\command') DO set wpapath=%%A %%B %%C %%D %%E %%F
set wpapath=%wpapath:~0,-7%

::
:: Copy additional plugins into the WPT installation.
::
copy /y bin\AMD64\*.dll "%wpapath%"

::
:: Setup perfcore.ini properly.
::
echo perf_ppm.dll >> "%wpapath%"perfcore.ini


@echo on
@echo +++++++++++++++++++++++++
@echo Installation successful.
@echo +++++++++++++++++++++++++
@echo off
