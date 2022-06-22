@echo off
rem Licensed Materials - Property of IBM
rem
rem Governed under the terms of the International
rem License Agreement for Non-Warranted Sample Code.
rem
rem (C) COPYRIGHT International Business Machines Corporation 2009
rem All Rights Reserved.
rem
rem US Government Users Restricted Rights - Use, duplication or
rem disclosure restricted by GSA ADP Schedule Contract with IBM Corp.

rem This bat file must be invoked from DB2 Command Line Processor
rem Running it on Win explorer will not give the expected result
@echo off

echo Running REST sample

set dte=logs\rest.log

echo   . Starting DB2

db2 connect reset > nul
db2stop force > nul

db2start > %dte%

echo   . Checking DB2 version
db2level | findstr "9.7" > nul
if %errorlevel%==0 (
  set db2v=DB2 v9.7
) else (
  set db2v=DB2 v9.5 or inferior
)
echo VERSION: %db2v% >> %dte%
echo     . %db2v% detected


echo   . Configuring environment

db2 -tvf ddl/REST_configure_environment.db2 >> %dte%

echo   . Registering UDFs

db2 "CONNECT TO REST" >> %dte%
db2 CALL SQLJ.REMOVE_JAR('restUDF') >> %dte%
db2 "CALL SQLJ.REMOVE_JAR('restUDF')"  > nul
echo Installing the JAR file >> %dte%
echo CALL SQLJ.INSTALL_JAR('file:jar/restUDF.jar', 'restUDF') >> %dte%
db2 "CALL SQLJ.INSTALL_JAR('file:jar/restUDF.jar', 'restUDF')" >> %dte%


db2 CALL SQLJ.REMOVE_JAR('restUDF') >> %dte%
db2 "CALL SQLJ.REMOVE_JAR('restUDF')"  > nul
echo CALL SQLJ.INSTALL_JAR('file:jar/restUDF.jar', 'restUDF') >> %dte%
db2 "CALL SQLJ.INSTALL_JAR('file:jar/restUDF.jar', 'restUDF')" >> %dte%
db2 "CONNECT RESET" >> %dte%
db2 -tvf ddl/REST_createUDFs.db2 >> %dte%
db2 -td@ -vf ddl/restUDFSamples.db2 >> %dte%


echo   . Restarting DB2
db2 "CONNECT RESET" > nul
db2stop force >> %dte%
db2start >> %dte%
db2 "CONNECT TO REST" >> %dte%

echo   . Populating the table
db2 -tvf ddl/REST_populateTable.db2 >> %dte%

db2 "CONNECT TO REST" >> %dte%
FOR %%A IN (output\*.*) DO DEL %%A

echo     . Query 1
db2 "values DB2XML.getUSWeather(37.1705,-121.7556, 3)" > output/Q1_getUSWeather.txt

echo     . Query 2 
db2  "select * from table(DB2XML.wikipediasearch(37.1705,-121.7556,10)) t" > output/Q2_wikipediasearch.txt

echo     . Query 3
db2  "select * from table(DB2XML.getTimeZone(37.1705,-121.7556)) t" > output/Q3_getTimeZone.txt

echo     . Query 4
db2  "values DB2XML.getElevation(37.1705,-121.7556)" > output/Q4_getElevation.txt

echo     . Query 5
db2	 "select * from table(DB2XML.getPlaceInfo('Irvine','92617','',10)) t" > output/Q5_getPlaceInfo.txt

echo     . Query 6
db2  "select * from table(DB2XML.getCountryInfo('EN','DE')) t" > output/Q6_getCountryInfo.txt

echo     . Query 7
db2 -tvf ddl/Q7_GetBBCnewsfeed.sql >> output/Q7_GetBBCnewsfeed.txt

echo     . Query 8
db2 -tvf ddl/Q8_JoinBBCnewsfeedWithLocalTable.sql >> output/Q8_JoinBBCnewsfeedWithLocalTable.txt


db2 "CONNECT RESET" >> %dte%

echo RESTUDFs configuration and sample run DONE!
echo Please refer to "%dte%" for a detailed log file
