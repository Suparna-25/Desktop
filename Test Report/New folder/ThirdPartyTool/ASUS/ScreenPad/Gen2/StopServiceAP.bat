@echo off
Sc query AsusScreenXpert | find "RUNNING"
if errorlevel 1 goto KILLAPP

Sc stop AsusScreenXpert                                    

:CheckMyService1
Timeout 1
Sc query AsusScreenXpert | find "STOPPED"                                   
if errorlevel 1 goto CheckMyService1

:KILLAPP
Taskkill /IM AsusInitialService.exe  /F
Taskkill /IM AsusScreenpadService.exe  /F
Taskkill /IM AsusScreenpad.exe  /F
Taskkill /IM AsusScreenpadQuickGuide.exe  /F

@echo on