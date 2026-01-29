ORACLE_BASE=/u01/app/oracle; export ORACLE_BASE
ORACLE_HOME=/u01/app/oracle/product/11.2.0/db_1; export ORACLE_HOME
ORACLE_SID=ORTBDB; export ORACLE_SID
ORACLE_TERM=xterm; export ORACLE_TERM
PATH=/usr/sbin:$PATH; export PATH
PATH=$ORACLE_HOME/bin:$PATH; export PATH
SET_DATE=`date '+%Y%m%d%H%M%S'` export SET_DATE
new_schema=$1
old_schema=$2
DMP_FILE=$3-%U.dmp

impdp  "'/ as sysdba'"  schemas=$old_schema directory=DUMPDIR parallel=4 dumpfile=$DMP_FILE logfile=implog$SET_DATE remap_schema=$old_schema:$new_schema transform=oid:n

#######
