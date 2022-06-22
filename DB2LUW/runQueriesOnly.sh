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

#FOR %%A IN (output\*.*) DO DEL %%A
echo "Running sample queries"
db2start > /dev/null
db2 connect reset > /dev/null
db2 "CONNECT TO REST" > /dev/null


echo "    . Query 1"
db2 "values DB2XML.getUSWeather(37.1705,-121.7556, 3)" > output/Q1_getUSWeather.txt


echo "    . Query 2"
db2  "select * from table(DB2XML.wikipediasearch(37.1705,-121.7556,10)) t" > output/Q2_wikipediasearch.txt


echo "    . Query 3"
db2  "select * from table(DB2XML.getTimeZone(37.1705,-121.7556)) t" > output/Q3_getTimeZone.txt


echo "    . Query 4"
db2  "values DB2XML.getElevation(37.1705,-121.7556)" > output/Q4_getElevation.txt


echo "    . Query 5"
db2	 "select * from table(DB2XML.getPlaceInfo('Irvine','92617','',10)) t" > output/Q5_getPlaceInfo.txt


echo "    . Query 6"
db2  "select * from table(DB2XML.getCountryInfo('EN','DE')) t" > output/Q6_getCountryInfo.txt


echo "    . Query 7"
db2 -tvf ddl/Q7_GetBBCnewsfeed.sql > output/Q7_GetBBCnewsfeed.txt


echo "    . Query 8"
db2 -tvf ddl/Q8_JoinBBCnewsfeedWithLocalTable.sql > output/Q8_JoinBBCnewsfeedWithLocalTable.txt



db2 "CONNECT RESET" > /dev/null
echo "========================================="
echo "sample queries run done!"



