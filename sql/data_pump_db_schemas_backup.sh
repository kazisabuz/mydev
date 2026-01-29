ORACLE_BASE=/u01/app/oracle; export ORACLE_BASE
ORACLE_HOME=/u01/app/oracle/product/11.2.0/db_1; export ORACLE_HOME
ORACLE_SID=ORTBDB; export ORACLE_SID
ORACLE_TERM=xterm; export ORACLE_TERM
PATH=/usr/sbin:$PATH; export PATH
PATH=$ORACLE_HOME/bin:$PATH; export PATH
SET_DATE=`date '+%Y%m%d%H%M%S'` export SET_DATE
SCHEMA_NAME=$1
DMP_FILE=$SCHEMA_NAME_$SET_DATE-%U.dmp
LOG_FILE=$SCHEMA_NAME_$SET_DATE.log

expdp  "'/ as sysdba'"  schemas=$SCHEMA_NAME directory=DUMPDIR parallel=4 dumpfile=$DMP_FILE logfile=$LOG_FILE EXCLUDE=TABLE:\"LIKE \'SPDOCIMAGE\'\"

#######

