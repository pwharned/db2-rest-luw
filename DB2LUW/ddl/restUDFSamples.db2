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

-- Connect to database
CONNECT TO REST@

SET CURRENT SCHEMA = 'DB2XML'@

--DROP FUNCTION getPlaceInfo@
--DROP FUNCTION getElevation@
--DROP FUNCTION getTimeZone@
--DROP FUNCTION getCountryInfo@
--DROP FUNCTION wikipediaSearch@
--DROP FUNCTION getUSWeather@
--DROP FUNCTION getYahooMapUrl@
--DROP FUNCTION getYahooTrafficInfo@



CREATE FUNCTION getUSWeather(lat DECIMAL(18,15), lng DECIMAL(18,15), numDays integer)
RETURNS CLOB(100K)

F1: BEGIN ATOMIC

RETURN SELECT * FROM XMLTABLE('$result//*[local-name()="NDFDgenByDayResponse"]' 
              PASSING XMLPARSE (DOCUMENT DB2XML.HTTPPOSTBLOB('http://www.weather.gov/forecasts/xml/SOAP_server/ndfdXMLserver.php', XMLPARSE(DOCUMENT '<httpHeader>
                             <header name="Content-Type" value="text/xml;charset=utf-8"/>
                             <header name="SOAPAction" value="&apos;http://www.weather.gov/forecasts/xml/DWMLgen/wsdl/ndfdXML.wsdl#NDFDgenByDay&apos;"/>
                          </httpHeader>'),
                          CAST(
'<soapenv:Envelope xmlns:q0="http://www.weather.gov/forecasts/xml/DWMLgen/schema/DWML.xsd" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <soapenv:Body>
    <ns0:NDFDgenByDay xmlns:ns0="http://www.weather.gov/forecasts/xml/DWMLgen/wsdl/ndfdXML.wsdl" soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
      <latitude xsi:type="xsd:decimal">' || CHAR(lat) || '</latitude>
      <longitude xsi:type="xsd:decimal">' || CHAR(lng) || '</longitude>
      <startDate xsi:type="xsd:date">' || char(current date, ISO) || '</startDate>
      <numDays xsi:type="xsd:integer">' || CHAR(numDays) || '</numDays>
      <format xsi:type="q0:formatType">24 hourly</format>
    </ns0:NDFDgenByDay>
  </soapenv:Body>
</soapenv:Envelope>' 
AS BLOB(10k)
 ))) as "result"
 COLUMNS
 doc CLOB(100k) PATH '*[local-name()="dwmlByDayOut"]'
 ) AS RESULT;

END@ 

-------------------------------------------------------------------------------
--  sample query 1 getUSWeather: values getUSWeather(37.1705,-121.7556, 3)
--  sample query 1 getUSWeather: values getUSWeather(41.0836,-73.8171, 3)
-------------------------------------------------------------------------------
	

CREATE FUNCTION wikipediaSearch (lat DECIMAL(18,15), lng DECIMAL(18,15), maxRows INTEGER)
RETURNS TABLE (lang VARCHAR(3),
              title VARCHAR(255),
              summary VARCHAR(1000),
              population VARCHAR(20),
              elevation VARCHAR(5), 
              lat DECIMAL(18,15),
              lng DECIMAL(18,15),
              wikipediaUrl VARCHAR(255),
              thumbnailImg VARCHAR(255),
              distance VARCHAR(20)
)

F1: BEGIN ATOMIC

RETURN SELECT *
       FROM XMLTABLE('$result//*[local-name()="entry"]' 
           PASSING 
              XMLPARSE(DOCUMENT 
                 DB2XML.HTTPGETBLOB(
                  CAST ('http://api.geonames.org/findNearbyWikipedia?username=xmltest&lat=' || DB2XML.URLENCODE(CHAR(lat),'') || '&lng=' || DB2XML.URLENCODE(CHAR(lng),'') || '&maxRows=' || CAST (maxRows AS CHAR(4)) AS VARCHAR(255)), 
                 XMLPARSE(DOCUMENT '<httpHeader/>'))) as "result"
         COLUMNS 
              lang VARCHAR(3) PATH '*[local-name()="lang"]',
              title VARCHAR(255) PATH '*[local-name()="title"]',
              summary VARCHAR(1000) PATH '*[local-name()="summary"]',
              population VARCHAR(20) PATH '*[local-name()="population"]',
              elevation VARCHAR(5) PATH '*[local-name()="elevation"]', 
              lat DECIMAL(18,15) PATH '*[local-name()="lat"]',
              lng DECIMAL(18,15) PATH '*[local-name()="lng"]',
              wikipediaUrl VARCHAR(255) PATH '*[local-name()="wikipediaUrl"]',
              thumbnailImg VARCHAR(255) PATH '*[local-name()="thumbnailImg"]',
              distance VARCHAR(20) PATH '*[local-name()="distance"]'
       ) AS RESULT;

END@

-------------------------------------------------------------------------------
--  sample query 2 wikipediasearch:  select * from table(wikipediasearch(37.1705,-121.7556,10)) t
--  sample query 2 wikipediasearch:  select * from table(wikipediasearch(41.0836,-73.8171,10)) t
--  http://api.geonames.org/findNearbyWikipedia?lat=37.1705&lng=-121.7556&maxRows=10
--  http://api.geonames.org/findNearbyWikipedia?lat=41.0836&lng=-73.8171&maxRows=10
-------------------------------------------------------------------------------


CREATE FUNCTION getTimeZone(lat DECIMAL(18,15), lng DECIMAL(18,15))
RETURNS TABLE (countryCode VARCHAR(5),
               countryName VARCHAR(50),
               lat DECIMAL(18,15),
               lng DECIMAL(18,15),
               timezoneId VARCHAR(20),
               dstOffset DECIMAL (4,2),
               gmtOffset DECIMAL (4,2)
               )

F1: BEGIN ATOMIC

RETURN SELECT *
       FROM XMLTABLE('$result//*[local-name()="timezone"]' 
           PASSING 
              XMLPARSE(DOCUMENT 
                 DB2XML.HTTPGETBLOB(
                  CAST ('http://api.geonames.org/timezone?username=xmltest&lat=' || DB2XML.URLENCODE(CHAR(lat),'') || '&lng=' || DB2XML.URLENCODE(CHAR(lng),'') AS VARCHAR(255)), 
                 XMLPARSE(DOCUMENT '<httpHeader/>'))) as "result"
         COLUMNS 
              countryCode VARCHAR(5) PATH '*[local-name()="countryCode"]',
              countryName VARCHAR(50) PATH '*[local-name()="countryName"]',
              lat DECIMAL(18,15) PATH '*[local-name()="lat"]',
              lng DECIMAL(18,15) PATH '*[local-name()="lng"]',
              timezoneId VARCHAR(20) PATH '*[local-name()="timezoneId"]',
              dstOffset DECIMAL (4,2) PATH '*[local-name()="dstOffset"]',
              gmtOffset DECIMAL (4,2) PATH '*[local-name()="gmtOffset"]'
       ) AS RESULT;

END@ 


-------------------------------------------------------------------------------
--  sample query 3 getTimeZone:  select * from table(getTimeZone(37.1705,-121.7556)) t
--  http://api.geonames.org/timezone?lat=37.1705&lng=-121.7556
-------------------------------------------------------------------------------


CREATE FUNCTION getElevation(lat DECIMAL(18,15), lng DECIMAL(18,15))
RETURNS VARCHAR(10)

F1: BEGIN ATOMIC

RETURN cast (substr(DB2XML.HTTPGETCLOB(
       CAST ('http://api.geonames.org/gtopo30?username=xmltest&lat=' || DB2XML.URLENCODE(CHAR(lat),'') || '&lng=' || DB2XML.URLENCODE(CHAR(lng),'') AS VARCHAR(255))
        , XMLPARSE(DOCUMENT '<httpHeader/>')), 1, 5) AS VARCHAR(10));

END@ 

-------------------------------------------------------------------------------
--  sample query 4 getElevation: values getElevation(37.1705,-121.7556)
-------------------------------------------------------------------------------


CREATE FUNCTION getPlaceInfo(placeName VARCHAR(255),
                             postalCode VARCHAR(20),
                             country VARCHAR(20),
                             maxRows INTEGER)
	RETURNS TABLE (postalCode VARCHAR(20),
                   name VARCHAR(50),
                   countryCode VARCHAR(5),
                   lat DECIMAL(18,15),
                   lng DECIMAL(18,15),
                   adminCode1 VARCHAR(10),
                   adminName1 VARCHAR(50),
                   adminCode2 VARCHAR(10),
                   adminName2 VARCHAR(50),
                   adminCode3 VARCHAR(10),
                   adminName3 VARCHAR(50)
                   )
F1: BEGIN ATOMIC

    RETURN SELECT *
       FROM XMLTABLE('$result//*[local-name()="code"]' 
           PASSING 
              XMLPARSE(DOCUMENT 
                 DB2XML.HTTPGETBLOB(
                  CAST ('http://api.geonames.org/postalCodeSearch?username=xmltest&' 
                    || 'placename=' 
                    || DB2XML.URLENCODE(placeName, 'utf-8') 
                    || '&postalcode='
                    || DB2XML.URLENCODE(postalCode, 'utf-8')
                    || '&coutry='
                    || DB2XML.URLENCODE(country, 'utf-8') 
                    || '&maxRows='
                    || CAST (maxRows as CHAR(4))
                  AS VARCHAR(2048)
                 ), 
                 XMLPARSE(DOCUMENT '<httpHeader/>'))) as "result"
         COLUMNS 
              postalCode VARCHAR(20) PATH '*[local-name()="postalcode"]',
              name VARCHAR(50) PATH '*[local-name()="name"]',
              countryCode VARCHAR(20) PATH '*[local-name()="countryCode"]',
              lat DECIMAL(18,15) PATH '*[local-name()="lat"]',
              lng DECIMAL(18,15) PATH '*[local-name()="lng"]',
              adminCode1 VARCHAR(20) PATH '*[local-name()="adminCode1"]',
              adminName1 VARCHAR(50) PATH '*[local-name()="adminName1"]',
              adminCode2 VARCHAR(20) PATH '*[local-name()="adminCode2"]',
              adminName2 VARCHAR(50) PATH '*[local-name()="adminName2"]',
              adminCode3 VARCHAR(20) PATH '*[local-name()="adminCode3"]',
              adminName3 VARCHAR(50) PATH '*[local-name()="adminName3"]'
       ) AS RESULT;

END@

-------------------------------------------------------------------------------
--  sample query 5 getPlaceInfo: select * from table(getPlaceInfo('San Jose','95141','',10)) t
--  http://api.geonames.org/postalCodeSearch?placename=San+Jose&postalcode=95141&coutry=&maxRows=10
-------------------------------------------------------------------------------

CREATE FUNCTION getCountryInfo(language VARCHAR(5), country VARCHAR(5))
RETURNS TABLE (countryCode VARCHAR(5),
               countryName VARCHAR(50),
               isoNumeric VARCHAR(4),
               isoAlpha3 VARCHAR(3),
               fipsCode VARCHAR(5), 
               continent VARCHAR(5),      
               capital VARCHAR(20),
               areaInSqKm VARCHAR(20),
               population VARCHAR(20),   
               currencyCode VARCHAR(5),   
               languages VARCHAR(100), 
               bBoxWest VARCHAR(20),  
               bBoxNorth VARCHAR(20), 
               bBoxEast VARCHAR(20),  
               bBoxSouth VARCHAR(20)

               )

F1: BEGIN ATOMIC

RETURN SELECT *
       FROM XMLTABLE('$result//*[local-name()="country"]' 
           PASSING 
              XMLPARSE(DOCUMENT 
                 DB2XML.HTTPGETBLOB(
                  CAST ('http://api.geonames.org/countryInfo?username=xmltest&lang=' || DB2XML.URLENCODE(language,'') || '&country=' || DB2XML.URLENCODE(country,'') || '&type=XML' AS VARCHAR(255)), 
                 XMLPARSE(DOCUMENT '<httpHeader/>'))) as "result"
         COLUMNS 
              countryCode VARCHAR(5) PATH '*[local-name()="countryCode"]',
              countryName VARCHAR(50) PATH '*[local-name()="countryName"]',
              isoNumeric VARCHAR(4) PATH '*[local-name()="isoNumeric"]',
              isoAlpha3 VARCHAR(3) PATH '*[local-name()="isoAlpha3"]',
              fipsCode VARCHAR(5) PATH '*[local-name()="fipsCode"]', 
              continent VARCHAR(5) PATH '*[local-name()="continent"]',      
              capital VARCHAR(20) PATH '*[local-name()="capital"]',
              areaInSqKm VARCHAR(20) PATH '*[local-name()="areaInSqKm"]',
              population VARCHAR(20) PATH '*[local-name()="population"]',   
              currencyCode VARCHAR(5) PATH '*[local-name()="currencyCode"]',   
              languages VARCHAR(100) PATH '*[local-name()="languages"]', 
              bBoxWest VARCHAR(20)  PATH '*[local-name()="bBoxWest"]',  
              bBoxNorth VARCHAR(20)  PATH '*[local-name()="bBoxNorth"]', 
              bBoxEast VARCHAR(20)  PATH '*[local-name()="bBoxEast"]',  
              bBoxSouth VARCHAR(20)  PATH '*[local-name()="bBoxSouth"]'
       ) AS RESULT;

END@

-------------------------------------------------------------------------------
--  sample query 6 getCountryInfo:  select * from table(getCountryInfo('EN','DE')) t
--  http://api.geonames.org/countryInfo?lang=EN&country=DE&type=XML
-------------------------------------------------------------------------------



---- a federation example ------------------------------------------------------------------------------------------------
-- select getElevation(t.lat,t.lng), getYahooMapUrl(t.lat,t.lng), t.* from table(getPlaceInfo('San Jose','95141','',10)) t
--------------------------------------------------------------------------------------------------------------------------

-- Disconnect from database
CONNECT RESET@