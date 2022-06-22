*******************************************************************************
*
* Licensed Materials - Property of IBM
*
* Governed under the terms of the International
* License Agreement for Non-Warranted Sample Code.
*
* (C) COPYRIGHT International Business Machines Corp. 2009
* All Rights Reserved.
*
* US Government Users Restricted Rights - Use, duplication or
* disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
*
*******************************************************************************
This README file will take you through the scripts to install REST UDFs.


INTRODUCTION
============
This package intends to give DBAs and developers an idea on how to install REST
UDFs and how to query using the functions. 

we introduce extensions to SQL, in the form of User Defined Functions (UDFs) 
that access URL-addressable resources via HTTP directly from SQL statements. 
The UDFs are called the REST UDFs or the REST functions. With the new functions 
additional capabilities, already available in the RDBMS, such as SQL aggregation 
or XPath access, can be used to manipulate and store data retrieved from the Web. 
With the REST functions simple HTTP GET or POST requests can be issued

GETTING STARTED
===============
Please follow the steps listed below to setup the REST UDFs package:

1. This bundle is distributed as a zip file. To use on Windows platforms just
   extract the RESTUDFs.zip file on your file system. On Linux platforms please 
   unzip the RESTUDFs.zip file using "unzip -a -aa RESTUDFs.zip".

2. In Windows systems please make sure the DB2 command line processor
   environment is initialised! In Linux based systems please check that you are
   logged in with a user that has access to DB2 (db2inst1 is the default
   DB2 user)

  ,---------------------------------------------------------------------------,
  ' !!! IMPORTANT !!!                                                         '
  '                                                                           '
  ' Be aware that the start scripts may configure some of the DBMS            '
  ' parameters and it may STOP and RESTART the DBMS to ensure the DBMS        '
  ' can handle the jar stored procedure.                                      '
  '                                                                           '
  ' This bundle has been tested using DB2 9.7 and DB2 9.5 ESE in Linux and    '
  ' Windows platforms. You might find that it also runs well in Mac with DB2  '
  ' Express-C. Please follow Linux instructions if using with in Mac.         '
  '                                                                           '
  ' If you are worried about the scripts please review them before running!   '
  '---------------------------------------------------------------------------'

3. Run the start.bat on windows platforms,
   on Linux platforms please use start.sh.

   After this script has finished you should see the message:
   RESTUDFs configuration and sample run DONE!
  
   At this point everything is set up and you can take a look at the samples
   just created in the output folder. To check if the results created are
   correct, you can compare the sample output files in the output folder with the
   sample output in the samples folder.

   Becuase the queries get answer from the internet, the answers may be different.

   If something is wrong, please consult the log file located in logs/ to find 
   what went wrong. If you are unable to solve the problem please contact Susan 
   Malaika (malaika at us dot ibm dot com) for further clarification. Please do 
   attach the log file so it is easier to understand what might have gone wrong.

4. After running start.bat or start.sh, you want to run the sample queries again,
   you could run runQueriesOnly.bat or runQueriesOnly.sh to get new query results.

5. If you want to clean up the RESTUDFs package again please run
   the script cleanup.bat (on windows platforms) or cleanup.sh (on linux
   platforms)

DIRECTORY STRUCTURE
===================

licenses:         contains license information regarding this package

output:           contains the extracted output that is created with sample
                  queries in this bundle

output/samples:   contains a sample output to compare it with the results in
                  the output folder

ddl:              contains the actual scripts that will setup your environment and
		  sample queries. 

jar:              contains the jar files where the java user defined functions
                  reside

DATABASE DESIGN
===============
This industry bundle creates a database called REST which is defined as
Unicode. One tables is created: News.

DB2XML.NEWS
--------
                                                          Column
Column name                 schema    Data type name      Length     Scale Nulls
-------------------------- --------- ------------------- ---------- ----- ------
TITLE                      DB2XML	VARCHAR                 256     0 Yes
DESCRIPTION		   DB2XML	VARCHAR                1024     0 Yes
LINK                       DB2XML	VARCHAR                 255     0 Yes
PUBDATE			   DB2XML	VARCHAR                  20     0 Yes



Walk-through with queries:
==========================

Following the previous steps procedures can be called to execute the queries.
The examples below will get you started and work with the REST UDFs which are
registered by the start script. Make sure you have an existing connection to the
database (executing "DB2 CONNECT TO REST" will establish the connection).


Start by running:
db2

This will start a db2 command line

  1' Get the weather information for a specific location with latitude and 
     longitude from http://www.weather.gov/. The creation statememtn of this 
     getUSWeather function is in ddl/restUDFSamples.db2

db2 => values DB2XML.getUSWeather(37.1705,-121.7556, 3);

  ---*---


  2' Get the information for a specific location with latitude and 
     longitude from http://en.wikipedia.org/. The creation statememtn of this 
     wikipediasearch function is in ddl/restUDFSamples.db2

db2 => select * from table(DB2XML.wikipediasearch(37.1705,-121.7556,10)) t;

  ---*---


  3' Get the TimeZone information for a specific location with latitude and 
     longitude from http://ws.geonames.org/. The creation statememtn of this 
     getTimeZone function is in ddl/restUDFSamples.db2

db2 => select * from table(DB2XML.getTimeZone(37.1705,-121.7556)) t;

  ---*---


  4' Get the ranking for a specific location with latitude and 
     longitude from http://ws.geonames.org/. The creation statememtn of this 
     getElevation function is in ddl/restUDFSamples.db2

db2 => values DB2XML.getElevation(37.1705,-121.7556);

  ---*---


  5' Get the ranking for a specific location with latitude and 
     longitude from http://ws.geonames.org/. The creation statememtn of this 
     getPlaceInfo function is in ddl/restUDFSamples.db2

db2 => select * from table(DB2XML.getPlaceInfo('Irvine','92617','',10)) t;
  ---*---


  6' Get the ranking for a specific location with latitude and 
     longitude from http://ws.geonames.org/. The creation statememtn of this 
     getCountryInfo function is in ddl/restUDFSamples.db2

db2 => select * from table(DB2XML.getCountryInfo('EN','DE')) t;

  ---*---


  7' Get the BBC news feeds back as a table of one column (title).

db2 => SELECT *
>>   FROM XMLTABLE('$result/rss/channel/item' 
>>      PASSING XMLPARSE(
>>         DOCUMENT 
>>           DB2XML.HTTPGETBLOB('http://feeds.bbci.co.uk/news/world/rss.xml?edition=uk','')
>>      ) as "result"
>>         COLUMNS 
>>            title VARCHAR(128) PATH 'title'
>>   ) AS RESULT;

  ---*---


  8' Get the BBC news feeds back as a table of one column (title) and join with
     a local table DB2XML.NEWS on title, and return all infor from NEWS table.

db2 =>    SELECT DB2XML.NEWS.*
>>   FROM XMLTABLE('$result/rss/channel/item' 
>>      PASSING XMLPARSE(
>>         DOCUMENT 
>>           DB2XML.HTTPGETBLOB('http://feeds.bbci.co.uk/news/world/rss.xml?edition=uk','')
>>      ) as "result"
>>         COLUMNS 
>>            title VARCHAR(128) PATH 'title'
>>   ) AS RESULT, DB2XML.NEWS
>>   WHERE RESULT.TITLE = DB2XML.NEWS.TITLE;

  ---*---
