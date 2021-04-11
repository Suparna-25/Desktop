@echo off

cd %cd%

%cd%\NewWBT\WBT.exe -n 14 /w 80 < %cd%\NewWBT\clear_2ndname.dat > %cd%\NewWBT\a.txt

echo %errorlevel%

EXIT /B %errorlevel%
