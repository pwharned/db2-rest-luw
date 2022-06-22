# Assets for enabling DB2 HTTP Rest capabilities on LUW

DB2 For Z/OS ships with some UDFS that allow users to make HTTP requests directly from DB2 like so:

`db2 "select db2xml.httpgetclob('https://www.ibm.com','') from sysibm.sysdummy1"`

The assets needed to set this up on DB2 LUW are in this directory. Simply download the directory to a LUW instance host or container and run the `start.sh`  script as `db2inst1`. Note that the UDFS will be created in a new `REST` database.