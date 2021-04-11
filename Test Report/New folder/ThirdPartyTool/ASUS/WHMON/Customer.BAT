@echo off
echo Customer 1.01 >>%logFile%

:start
WHMON.EXE /EXE DIO6.DAT 
IF ERRORLEVEL 1 GOTO FAIL
IF ERRORLEVEL 0 GOTO PASS

echo *** This is a demo *** >>%logFile%


:fail
echo.
echo ****************************************
echo *** DIO test fail ***
echo *** DIO test fail *** >>%logFile%
echo ****************************************
ATRET.EXE 255
EXIT

:pass
echo.
echo ********************
echo *** DIO test PASS ***
echo *** DIO test PASS *** >>%logFile%
echo ********************
ATRET.EXE 0
EXIT