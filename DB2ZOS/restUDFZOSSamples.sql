---------------------------------------------------------------------
-- Licensed Materials - Property of IBM
--
-- Governed under the terms of the International
-- License Agreement for Non-Warranted Sample Code.
--
-- (C) COPYRIGHT International Business Machines Corporation 2009
-- All Rights Reserved.
--
-- US Government Users Restricted Rights - Use, duplication or
-- disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
---------------------------------------------------------------------

 -----------------------------------------------------------------------
 -- get U.S. Weather
 -----------------------------------------------------------------------
SELECT DOC FROM XMLTABLE('$result//*[local-name()=''NDFDgenByDayResponse'']' 
              PASSING XMLPARSE (DOCUMENT DB2XML.HTTPPOSTCLOB('http://www.weather.gov/forecasts/xml/SOAP_server/ndfdXMLserver.php', CAST ('<httpHeader>
                             <header name="Content-Type" value="text/xml;charset=utf-8"/>
                             <header name="SOAPAction" value="&apos;http://www.weather.gov/forecasts/xml/DWMLgen/wsdl/ndfdXML.wsdl#NDFDgenByDay&apos;"/>
                          </httpHeader>' AS CLOB(1K)),
                          CAST(
'<soapenv:Envelope xmlns:q0="http://www.weather.gov/forecasts/xml/DWMLgen/schema/DWML.xsd" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <soapenv:Body>
    <ns0:NDFDgenByDay xmlns:ns0="http://www.weather.gov/forecasts/xml/DWMLgen/wsdl/ndfdXML.wsdl" soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
      <latitude xsi:type="xsd:decimal">' || CHAR('37.1705') || '</latitude>
      <longitude xsi:type="xsd:decimal">' || CHAR('-121.7556') || '</longitude>
      <startDate xsi:type="xsd:date">' || char(current date, ISO) || '</startDate>
      <numDays xsi:type="xsd:integer">' || CHAR('3') || '</numDays>
      <format xsi:type="q0:formatType">24 hourly</format>
    </ns0:NDFDgenByDay>
  </soapenv:Body>
</soapenv:Envelope>' 
AS CLOB(10k)
 ))) as "result"
 COLUMNS
 doc CLOB(100k) PATH '*[local-name()=''dwmlByDayOut'']'
 ) AS RESULT;

 -----------------------------------------------------------------------
 -- Wikipedia search
 ----------------------------------------------------------------------- 
 SELECT *
       FROM XMLTABLE('$result//*[local-name()=''entry'']' 
           PASSING 
              XMLPARSE(DOCUMENT 
                 DB2XML.HTTPGETBLOB(
                  CAST ('http://ws.geonames.org/findNearbyWikipedia?lat=37.1705&lng=-121.7556&maxRows=20' AS VARCHAR(255)), 
                 CAST(NULL AS CLOB(1K)))) as "result"
         COLUMNS 
              lang VARCHAR(3) PATH '*[local-name()=''lang'']',
              title VARCHAR(255) PATH '*[local-name()=''title'']',
              summary VARCHAR(1000) PATH '*[local-name()=''summary'']',
              population VARCHAR(20) PATH '*[local-name()=''population'']',
              elevation VARCHAR(5) PATH '*[local-name()=''elevation'']', 
              lat DECIMAL(18,15) PATH '*[local-name()=''lat'']',
              lng DECIMAL(18,15) PATH '*[local-name()=''lng'']',
              wikipediaUrl VARCHAR(255) PATH '*[local-name()=''wikipediaUrl'']',
              thumbnailImg VARCHAR(255) PATH '*[local-name()=''thumbnailImg'']',
              distance VARCHAR(20) PATH '*[local-name()=''distance'']'
       ) AS RESULT;
	   
 -----------------------------------------------------------------------
 -- get time zone
 -----------------------------------------------------------------------
 SELECT *
       FROM XMLTABLE('$result//*[local-name()=''timezone'']' 
           PASSING 
              XMLPARSE(DOCUMENT 
                 DB2XML.HTTPGETBLOB(
                  CAST ('http://ws.geonames.org/timezone?lat=37.1705&lng=-121.7556' AS VARCHAR(255)), 
                 CAST(NULL AS CLOB(1K)))) as "result"
         COLUMNS 
              countryCode VARCHAR(5) PATH '*[local-name()=''countryCode'']',
              countryName VARCHAR(50) PATH '*[local-name()=''countryName'']',
              lat DECIMAL(18,15) PATH '*[local-name()=''lat'']',
              lng DECIMAL(18,15) PATH '*[local-name()=''lng'']',
              timezoneId VARCHAR(20) PATH '*[local-name()=''timezoneId'']',
              dstOffset DECIMAL (4,2) PATH '*[local-name()=''dstOffset'']',
              gmtOffset DECIMAL (4,2) PATH '*[local-name()=''gmtOffset'']'
       ) AS RESULT;

 -----------------------------------------------------------------------
 -- get place info
 -----------------------------------------------------------------------
SELECT *
       FROM XMLTABLE('$result//*[local-name()=''code'']' 
           PASSING 
              XMLPARSE(DOCUMENT 
                 DB2XML.HTTPGETBLOB(
                  CAST ('http://ws.geonames.org/postalCodeSearch?' 
                    || 'placename=' 
                    || DB2XML.URLENCODE('San Jose', 'utf-8') 
                    || '&postalcode='
                    || DB2XML.URLENCODE('95123', 'utf-8')
                    || '&coutry='
                    || DB2XML.URLENCODE('us', 'utf-8') 
                    || '&maxRows=10' 
                  AS VARCHAR(2048)
                 ), 
                 CAST(NULL AS CLOB(1K)))) as "result"
         COLUMNS 
              postalCode VARCHAR(20) PATH '*[local-name()=''postalcode'']',
              name VARCHAR(50) PATH '*[local-name()=''name'']',
              countryCode VARCHAR(20) PATH '*[local-name()=''contryCode'']',
              lat DECIMAL(18,15) PATH '*[local-name()=''lat'']',
              lng DECIMAL(18,15) PATH '*[local-name()=''lng'']',
              adminCode1 VARCHAR(20) PATH '*[local-name()=''adminCode1'']',
              adminName1 VARCHAR(50) PATH '*[local-name()=''adminName1'']',
              adminCode2 VARCHAR(20) PATH '*[local-name()=''adminCode2'']',
              adminName2 VARCHAR(50) PATH '*[local-name()=''adminName2'']',
              adminCode3 VARCHAR(20) PATH '*[local-name()=''adminCode3'']',
              adminName3 VARCHAR(50) PATH '*[local-name()=''adminName3'']'
       ) AS RESULT;

 -----------------------------------------------------------------------
 -- get country info
 -----------------------------------------------------------------------	   
SELECT *
       FROM XMLTABLE('$result//*[local-name()=''country'']' 
           PASSING 
              XMLPARSE(DOCUMENT 
                 DB2XML.HTTPGETBLOB(
                  CAST ('http://ws.geonames.org/countryInfo?lang=' || DB2XML.URLENCODE('en','') || '&country=' || DB2XML.URLENCODE('us','') || '&type=XML' AS VARCHAR(255)), 
                 CAST(NULL AS CLOB(1K)))) as "result"
         COLUMNS 
              countryCode VARCHAR(5) PATH '*[local-name()=''countryCode'']',
              countryName VARCHAR(50) PATH '*[local-name()=''countryName'']',
              isoNumeric VARCHAR(4) PATH '*[local-name()=''isoNumeric'']',
              isoAlpha3 VARCHAR(3) PATH '*[local-name()=''isoAlpha3'']',
              fipsCode VARCHAR(5) PATH '*[local-name()=''fipsCode'']', 
              continent VARCHAR(5) PATH '*[local-name()=''continent'']',      
              capital VARCHAR(20) PATH '*[local-name()=''capital'']',
              areaInSqKm VARCHAR(20) PATH '*[local-name()=''areaInSqKm'']',
              population VARCHAR(20) PATH '*[local-name()=''population'']',   
              currencyCode VARCHAR(5) PATH '*[local-name()=''currencyCode'']',   
              languages VARCHAR(100) PATH '*[local-name()=''languages'']', 
              bBoxWest VARCHAR(20)  PATH '*[local-name()=''bBoxWest'']',  
              bBoxNorth VARCHAR(20)  PATH '*[local-name()=''bBoxNorth'']', 
              bBoxEast VARCHAR(20)  PATH '*[local-name()=''bBoxEast'']',  
              bBoxSouth VARCHAR(20)  PATH '*[local-name()=''bBoxSouth'']'
       ) AS RESULT;
       
 -----------------------------------------------------------------------
 -- get BBC RSS feed as XML
 -----------------------------------------------------------------------       
SELECT *
       FROM XMLTABLE('$result/*[local-name()=''rss'']/*[local-name()=''channel'']/*[local-name()=''item'']' 
           PASSING  
                 XMLPARSE(DOCUMENT DB2XML.HTTPGETBLOB('http://feeds.bbci.co.uk/news/world/rss.xml?edition=uk','')) as "result"
         COLUMNS 
              title VARCHAR(128) PATH '*[local-name()=''title'']',
              description VARCHAR(1024) PATH '*[local-name()=''description'']',
              link VARCHAR(255) PATH '*[local-name()=''link'']'
       ) AS RESULT;
       
 -----------------------------------------------------------------------
 -- get Google weather feed as XML
 ----------------------------------------------------------------------- 
 SELECT *
       FROM XMLTABLE('$result/*[local-name()=''xml_api_reply'']/*[local-name()=''weather'']/*[local-name()=''forecast_conditions'']' 
           PASSING  
                 XMLPARSE(DOCUMENT DB2XML.HTTPGETBLOB('http://www.google.com/ig/api?weather=san%20jose','')) as "result"
         COLUMNS 
              day VARCHAR(10) PATH '*[local-name()=''day_of_week'']/@data',
              low INTEGER PATH '*[local-name()=''low'']/@data',
              high INTEGER PATH '*[local-name()=''high'']/@data',
              condition VARCHAR(128) PATH '*[local-name()=''condition'']/@data'
       ) AS RESULT;
