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
CONNECT TO REST;

DELETE FROM DB2XML.NEWS;

INSERT INTO DB2XML.NEWS
SELECT *
   FROM XMLTABLE('$result/rss/channel/item' 
      PASSING XMLPARSE(
         DOCUMENT 
           DB2XML.HTTPGETBLOB('http://feeds.bbci.co.uk/news/world/rss.xml?edition=uk','')
      ) as "result"
         COLUMNS 
            title VARCHAR(128) PATH 'title',
            description VARCHAR(1024) PATH 'description',
            link VARCHAR(255) PATH 'link',
			pubDate VARCHAR(20) PATH 'substring(pubDate, 1, 16)'
   ) AS RESULT
WHERE RESULT.TITLE LIKE 'A%' OR RESULT.TITLE LIKE 'B%';


-- Reset the connection
CONNECT RESET;