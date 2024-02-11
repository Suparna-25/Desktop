::
:: Batch file to start tracing.
::

::
:: Enable kernel logger
::

::
:: List of other providers that we are interested in.
::
set providers=Microsoft-Windows-PDC+Microsoft-Windows-Kernel-Power+Microsoft-Windows-Kernel-Processor-Power+Microsoft-Windows-Kernel-Acpi+Microsoft-Windows-Kernel-Pep+Microsoft-Windows-Battery+Microsoft-Windows-BrokerInfrastructure+Microsoft-Windows-UserModePowerService+Microsoft-Windows-SleepStudy+Microsoft-Windows-ProcessStateManager+Microsoft-Windows-Win32k+Microsoft-Windows-DesktopWindowManager-Diag+Microsoft-Windows-Display+Microsoft-Windows-NDIS+Microsoft-Windows-WLAN-AutoConfig+Microsoft-Windows-Dhcp-Client+Microsoft-Windows-NetworkProfile+Microsoft-Windows-PushNotifications-Platform+Microsoft-Windows-Network-Connection-Broker+Microsoft-Windows-TCPIP

xperf -on PROC_THREAD+LOADER+INTERRUPT+DPC+CSWITCH+IDLE_STATES+TIMER+CLOCKINT+IPI+POWER+0x40100000+0x44000000 -stackwalk TimerSetPeriodic+TimerSetOneShot+CSwitch+readythread -clocktype perfcounter -buffersize 1024 -minbuffers 1024

::
:: Enable the providers
::
xperf -start power -on %providers% -buffersize 1024 -minbuffers 1024
xperf -capturestate power %providers%

::
:: Power test for Connected Standby
::
pwrtest /cs /c:5 /p:120 /d:60

::
:: End tracing
::

xperf -flush
xperf -stop
xperf -flush power
xperf -stop power
FOR /F "DELIMS=" %%T IN ('TIME /T') DO SET @TIME=%%T
 FOR /F "TOKENS=2" %%D IN ('DATE /T') DO SET @DATE=%%D
 FOR /F "TOKENS=1-4 DELIMS=-/ " %%D IN ('DATE /T') DO (
     SET @DAY=%%D
     SET @DD=%%F
     SET @MM=%%E
     SET @YYYY=%%G
 )
 SET @HOUR=%@TIME:~0,2%
 SET @SUFFIX=%@TIME:~6,2%
 IF /I "%@SUFFIX%"=="AM" IF %@HOUR% EQU 12 SET @HOUR=00
 IF /I "%@SUFFIX%"=="PM" IF %@HOUR% LSS 12 SET /A @HOUR=%@HOUR% + 12
 SET @NOW=%@HOUR%%@TIME:~3,2%
 SET @NOW=%@NOW: =0%
 SET @TODAY=%@YYYY%-%@MM%-%@DD%

xperf -merge   \kernel.etl     \user.etl mytrace%@DD%-%@MM%-%@YYYY%_%@NOW%.etl


