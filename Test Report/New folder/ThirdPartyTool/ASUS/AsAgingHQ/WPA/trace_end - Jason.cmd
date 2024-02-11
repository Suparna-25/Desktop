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