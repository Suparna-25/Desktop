@echo off
cd /d %~dp0
set path=%path%;%~dp0

call stopserviceAP.bat
GTModuleTest.exe
echo %ERRORLEVEL%

call startservice.bat
