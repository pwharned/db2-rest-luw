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

db2 connect reset > /dev/null
db2 force application all > /dev/null

echo "DELETE REST SAMPLE SAMPLE"
echo " "
echo "This will DELETE the REST  industry bundle. If you wish to"
echo "continue press ENTER otherwise terminate the script by using"
echo "CTRL-C and confirm the cancellation."
read -p ""


db2 drop database rest > /dev/null

echo "========================================="
echo "REST  SAMPLE database has been DELETED!"




