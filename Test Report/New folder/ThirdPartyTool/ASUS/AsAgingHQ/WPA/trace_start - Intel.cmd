::
:: Batch file to start tracing.
::

::
:: Enable kernel logger
::
xperf -on PROC_THREAD+LOADER+INTERRUPT+DPC+CSWITCH+IDLE_STATES+TIMER+CLOCKINT+IPI+POWER+0x40100000+0x44000000 -stackwalk TimerSetPeriodic+TimerSetOneShot+CSwitch+readythread -clocktype perfcounter -buffersize 1024 -minbuffers 256

@echo off

::
:: List of other providers that we are interested in.
::
set providers=Microsoft-Windows-PDC+Microsoft-Windows-Kernel-Power+Microsoft-Windows-Kernel-Processor-Power+Microsoft-Windows-Kernel-Acpi+5412704E-B2E1-4624-8FFD-55777B8F7373+Microsoft-Windows-Battery+Microsoft-Windows-BrokerInfrastructure+802ec45a-1e99-4b83-9920-87c98277ba9d:0x200:5

@echo on

::
:: Enable the providers
::
xperf -start power -on %providers% -buffersize 1024 -minbuffers 256
xperf -capturestate power %providers%

