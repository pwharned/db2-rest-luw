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

rem This bat file must be executed on the DB2 Command Line Processer
rem in order to work properly. Starting the file through Windows 
rem Explorer or Windows Command line will not give the expected 
rem results.
@echo off

db2 "connect reset" >> %dte%
db2 "force application all" >> %dte%

echo DELETE REST SAMPLE DATABASE
echo.
echo This will DELETE the REST industry bundle. If you wish to
echo continue press any key otherwise terminate the script by using
echo CTRL-C and confirm the cancellation.
pause


db2 "drop database rest" >> %dte%

echo ======================================================
echo REST SAMPLE database has been DELETED!
