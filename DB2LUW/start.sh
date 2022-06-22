#!/bin/sh 
# Licensed Materials - Property of IBM
#
# Governed under the terms of the International
# License Agreement for Non-Warranted Sample Code.
#
# (C) COPYRIGHT International Business Machines Corporation 2009
# All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
echo "Running REST sample"

dte=logs/$(date -u +%m-%d-%Y-%H.%M).log

echo "  . Starting DB2"

db2 connect reset > /dev/null
db2stop force > /dev/null

db2start >> $dte

echo "  . Checking DB2 version"
db2v=`db2level | sed 's/.*\(DB2 v[1-9].[0-9]\).*/\1/' | grep "DB2 v"`
echo "VERSION:" $db2v >> $dte
echo "    ." $db2v "detected"

echo "  . Configuring environment"

db2 -tvf ddl/REST_configure_environment.db2 >> $dte

echo "  . Registering UDFs"

db2 "CONNECT TO REST" >> $dte
echo "CALL SQLJ.REMOVE_JAR('restUDF')" >> $dte
db2 "CALL SQLJ.REMOVE_JAR('restUDF')"  > /dev/null
echo "Installing the JAR file" >> $dte
echo "CALL SQLJ.INSTALL_JAR('file:"$(pwd)"/jar/restUDF.jar', 'restUDF')" >> $dte
db2 "CALL SQLJ.INSTALL_JAR('file:"$(pwd)"/jar/restUDF.jar', 'restUDF')" >> $dte


echo "CALL SQLJ.REMOVE_JAR('restUDF')" >> $dte
db2 "CALL SQLJ.REMOVE_JAR('restUDF')"  > /dev/null
echo "CALL SQLJ.INSTALL_JAR('file:"$(pwd)"/jar/restUDF.jar', 'restUDF')" >> $dte
db2 "CALL SQLJ.INSTALL_JAR('file:"$(pwd)"/jar/restUDF.jar', 'restUDF')" >> $dte
db2 "CONNECT RESET" >> $dte
db2 -tvf ddl/REST_createUDFs.db2 >> $dte
db2 -td@ -vf ddl/restUDFSamples.db2 >> $dte

echo "  . Restarting DB2"
db2 "CONNECT RESET" >> $dte
db2stop force >> $dte
db2start >> $dte
db2 "CONNECT TO REST" >> $dte

echo "  . Populating the table"
db2 -tvf ddl/REST_populateTable.db2 >> $dte

db2 "CONNECT TO REST" >> $dte
#FOR %%A IN (output\*.*) DO DEL %%A



echo "    . Query 1"
#echo "<result_set>" > output/Q1_getUSWeather.txt
db2 "values DB2XML.getUSWeather(37.1705,-121.7556, 3)" > output/Q1_getUSWeather.txt
#echo "</result_set>" >> output/Q1_getUSWeather.txt

echo "    . Query 2"
#echo "<result_set>" > output/Q2_wikipediasearch.txt
db2  "select * from table(DB2XML.wikipediasearch(37.1705,-121.7556,10)) t" > output/Q2_wikipediasearch.txt
#echo "</result_set>" >> output/Q2_wikipediasearch.txt

echo "    . Query 3"
#echo "<result_set>" > output/Q3_getTimeZone.txt
db2  "select * from table(DB2XML.getTimeZone(37.1705,-121.7556)) t" > output/Q3_getTimeZone.txt
#echo "</result_set>" >> output/Q3_getTimeZone.txt

echo "    . Query 4"
#echo "<result_set>" > output/Q4_getElevation.txt
db2  "values DB2XML.getElevation(37.1705,-121.7556)" > output/Q4_getElevation.txt
#echo "</result_set>" >> output/Q4_getElevation.txt

echo "    . Query 5"
#echo "<result_set>" > output/Q5_getPlaceInfo.txt
db2	 "select * from table(DB2XML.getPlaceInfo('Irvine','92617','',10)) t" > output/Q5_getPlaceInfo.txt
#echo "</result_set>" >> output/Q5_getPlaceInfo.txt

echo "    . Query 6"
#echo "<result_set>" > output/Q6_getCountryInfo.txt
db2  "select * from table(DB2XML.getCountryInfo('EN','DE')) t" > output/Q6_getCountryInfo.txt
#echo "</result_set>" >> output/Q6_getCountryInfo.txt

echo "    . Query 7"
#echo "<result_set>" > output/Q7_GetBBCnewsfeed.txt
db2 -tvf ddl/Q7_GetBBCnewsfeed.sql > output/Q7_GetBBCnewsfeed.txt
#echo "</result_set>" >> output/Q7_GetBBCnewsfeed.txt

echo "    . Query 8"
#echo "<result_set>" > output/Q8_JoinBBCnewsfeedWithLocalTable.txt
db2 -tvf ddl/Q8_JoinBBCnewsfeedWithLocalTable.sql > output/Q8_JoinBBCnewsfeedWithLocalTable.txt
#echo "</result_set>" >> output/Q8_JoinBBCnewsfeedWithLocalTable.txt


db2 "CONNECT RESET" >> $dte

echo "RESTUDFs configuration and sample run DONE!"
echo "Please refer to" $dte "for a detailed log file"


