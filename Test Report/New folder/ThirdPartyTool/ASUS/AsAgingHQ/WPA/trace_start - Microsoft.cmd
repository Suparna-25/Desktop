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

