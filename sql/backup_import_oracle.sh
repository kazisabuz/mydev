#!/bin/bash

# Set Oracle Environment Variables
export ORACLE_SID=XE
export ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe
export PATH=$ORACLE_HOME/bin:$PATH

# Variables
SCHEMA_NAME="SBL_CBS"
BACKUP_DIR="/u01/app/oracle/dumpdir"
TIMESTAMP=$(date +"%M%H%d%m%Y")  # MIHHDDMMYYYY format
NEW_SCHEMA="${SCHEMA_NAME}_${TIMESTAMP}"
DUMP_FILE="${SCHEMA_NAME}_backup_${TIMESTAMP}.dmp"


echo "Deleting previous dump files..."
find "$BACKUP_DIR" -type f -name "${SCHEMA_NAME}_backup*" -exec rm -f {} \;


# Step 1: Drop the previous schema if it exists
echo "Dropping previous schema if exists: ${SCHEMA_NAME}_*" 
sqlplus -s system/oracle@localhost:1521/XE <<EOF
SET HEADING OFF;
SET FEEDBACK OFF;
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM dba_users WHERE username LIKE '${SCHEMA_NAME}_%';
    IF v_count > 0 THEN
        FOR rec IN (SELECT username FROM dba_users WHERE username LIKE '${SCHEMA_NAME}_%') LOOP
            EXECUTE IMMEDIATE 'DROP USER ' || rec.username || ' CASCADE';
        END LOOP;
    END IF;
END;
/
EXIT;
EOF

# Step 2: Export the Schema
echo "Starting Export of Schema: ${SCHEMA_NAME}"
expdp system/oracle@XE \
    schemas=${SCHEMA_NAME} \
    directory=DUMPDIR \
    dumpfile=${DUMP_FILE} \
    logfile=${SCHEMA_NAME}_backup_${TIMESTAMP}.log

# Step 3: Move Backup File to Permanent Location
mv "${BACKUP_DIR}/${DUMP_FILE}" "${BACKUP_DIR}/${DUMP_FILE}"

# Step 4: Create New Schema for Import
echo "Creating new schema: ${NEW_SCHEMA}"
sqlplus -s system/oracle@localhost:1521/XE <<EOF
CREATE USER ${NEW_SCHEMA} IDENTIFIED BY oracle;
GRANT CONNECT, RESOURCE, DBA TO ${NEW_SCHEMA};
EXIT;
EOF

# Step 5: Import the Dump into New Schema
echo "Importing Dump into: ${NEW_SCHEMA}"
impdp system/oracle@XE \
    remap_schema=${SCHEMA_NAME}:${NEW_SCHEMA} \
    directory=DUMPDIR \
    dumpfile=${DUMP_FILE} \
    logfile=${NEW_SCHEMA}_import.log

echo "Import completed. New schema: ${NEW_SCHEMA} is now available."
