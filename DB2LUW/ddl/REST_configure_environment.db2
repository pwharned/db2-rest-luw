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
-- Reset previous connections
CONNECT RESET;

-- Drop the database to ensure the creation of new copy
DROP DATABASE REST;

-- Creating database as unicode
CREATE DATABASE REST 
  USING CODESET UTF-8
  TERRITORY US;

-- Connect to the database we just created
CONNECT TO REST;

-- Create table
CREATE TABLE DB2XML.NEWS(
  TITLE VARCHAR(256),
  DESCRIPTION VARCHAR(1024),
  LINK VARCHAR(255),
  PUBDATE VARCHAR(20)
);

-- Reset the connection
CONNECT RESET;
