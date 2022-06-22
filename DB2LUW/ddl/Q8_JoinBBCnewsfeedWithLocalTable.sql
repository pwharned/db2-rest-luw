   SELECT DB2XML.NEWS.*
   FROM XMLTABLE('$result/rss/channel/item' 
      PASSING XMLPARSE(
         DOCUMENT 
           DB2XML.HTTPGETBLOB('http://feeds.bbci.co.uk/news/world/rss.xml?edition=uk','')
      ) as "result"
         COLUMNS 
            title VARCHAR(128) PATH 'title'
   ) AS RESULT, DB2XML.NEWS
   WHERE RESULT.TITLE = DB2XML.NEWS.TITLE;