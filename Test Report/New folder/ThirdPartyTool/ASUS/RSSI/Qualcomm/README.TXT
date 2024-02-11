Usage of PETool package

1. Pre-request

The PETool is supposed to run on a Windows PE system with Qualcomm Atheros 
Wi-Fi chip attached.

2. Install the Qualcomm Atheros Wi-Fi driver by drvload command.

3. Disable and enable the device by devcon.

4. The usage of PEDiagUtility.exe
4.1 Register WlanMonHelper module:
run:
tool.bat /s

4.2. Add "SmartNetEnable" registry key
run:
1. get_id.bat
2. enable_smartnet.bat

5. restart device
run:
restart_dev.bat

6. Run PETool
PEDiagUtility Test <TestNo> [-LED <On/Off> ][-COEX_WLAN <On/Off>] [-d <output-file path>]

Example: 
 PEDiagUtility Test 6 -SSID PE_TEST -THRESHOLD -50 -DIFF 5

---------------------------------------------------------