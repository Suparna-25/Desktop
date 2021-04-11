@echo off &setlocal enabledelayedexpansion

Sc query AsusScreenXpert | find "STOPPED"                                   
if errorlevel 1 goto END2

Sc start AsusScreenXpert
set /a num=0
:CheckMyService2
Timeout 1
set /a num+=1
if !num! equ 10 (goto END2) else (echo !num!)
Sc query AsusScreenXpert | find "RUNNING"                                   
if errorlevel 1 goto CheckMyService2

:END2
@echo on
