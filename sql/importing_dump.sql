/*Dump import process in the local machine*/
Conn sys as sysdba

create tablespace TBACNTS
datafile  'D:\Oracle\oradata\orcl\TBACNTS.dbf' size 1024m
autoextend on next 20m maxsize unlimited
segment space management auto
extent management local;

create tablespace TRBFES
datafile 'D:\Oracle\oradata\orcl\TRBFES.dbf' size 1024m
autoextend on next 20m maxsize unlimited
segment space management auto
extent management local;

create tablespace TBFES
datafile  'D:\Oracle\oradata\orcl\TBFES.dbf' size 1024m
autoextend on next 20m maxsize unlimited
segment space management auto
extent management local;

create tablespace  TBAML 
datafile  'D:\Oracle\oradata\orcl\TBAML.dbf' size 1024m
autoextend on next 20m maxsize unlimited
segment space management auto
extent management local;

create tablespace  DATA 
datafile 'D:\Oracle\oradata\orcl\DATA.dbf' size 1024m
autoextend on next 20m maxsize unlimited
segment space management auto
extent management local;

create tablespace  TBSTRAN
datafile 'D:\Oracle\oradata\orcl\TBSTRAN.dbf' size 1024m
autoextend on next 20m maxsize unlimited
segment space management auto
extent management local;

create tablespace  CBSINDEX
datafile 'D:\Oracle\oradata\orcl\CBSINDEX.dbf' size 1024m
autoextend on next 20m maxsize unlimited
segment space management auto
extent management local;

create tablespace  TBSSIGNATURE
datafile 'D:\Oracle\oradata\orcl\TBSSIGNATURE.dbf' size 1024m
autoextend on next 20m maxsize unlimited
segment space management auto
extent management local;

create tablespace  TBSIMAGE
datafile 'D:\Oracle\oradata\orcl\TBSIMAGE.dbf' size 1024m
autoextend on next 20m maxsize unlimited
segment space management auto
extent management local; ----------------------


create tablespace  TS_TRANS
datafile 'D:\Oracle\oradata\orcl\TS_TRANS.dbf' size 1024m
autoextend on next 20m maxsize unlimited
segment space management auto
extent management local;


CREATE USER SBUK_TEST_T IDENTIFIED BY SBUK_TEST_T DEFAULT TABLESPACE TBFES TEMPORARY TABLESPACE TEMP PROFILE DEFAULT ACCOUNT UNLOCK;

GRANT CONNECT TO SBUK_TEST_T;
GRANT RESOURCE TO SBUK_TEST_T;
ALTER USER SBUK_TEST_T DEFAULT ROLE ALL;
GRANT CREATE ANY SYNONYM TO SBUK_TEST_T;
GRANT CREATE ANY VIEW TO SBUK_TEST_T;
GRANT CREATE SEQUENCE TO SBUK_TEST_T;
GRANT CREATE SESSION TO SBUK_TEST_T;
GRANT CREATE TABLE TO SBUK_TEST_T;
GRANT CREATE VIEW TO SBUK_TEST_T;
GRANT CREATE type TO SBUK_TEST_T;
GRANT DEBUG ANY PROCEDURE TO SBUK_TEST_T;
GRANT DEBUG CONNECT SESSION TO SBUK_TEST_T;
GRANT UNLIMITED TABLESPACE TO SBUK_TEST_T;
GRANT IMP_FULL_database TO SBUK_TEST_T;
GRANT DBA TO SBUK_TEST_T;

GRANT READ, WRITE ON DIRECTORY SYS.DATA_PUMP_DIR TO SBUK_TEST_T;
GRANT EXECUTE ON SYS.DBMS_LOCK TO SBUK_TEST_T;
GRANT EXECUTE ON SYS.DBMS_SQLHASH TO SBUK_TEST_T;


ALTER USER SBUK_TEST_T QUOTA UNLIMITED ON DATA;
ALTER USER SBUK_TEST_T QUOTA UNLIMITED ON SYSTEM;
ALTER USER SBUK_TEST_T QUOTA UNLIMITED ON TBAML;
ALTER USER SBUK_TEST_T QUOTA UNLIMITED ON TBFES;
ALTER USER SBUK_TEST_T QUOTA UNLIMITED ON TBSTRAN;
ALTER USER SBUK_TEST_T QUOTA UNLIMITED ON USERS;

ALTER USER SBUK_TEST_T QUOTA UNLIMITED ON CBSINDEX;
ALTER USER SBUK_TEST_T QUOTA UNLIMITED ON TBACNTS;
ALTER USER SBUK_TEST_T QUOTA UNLIMITED ON TBSIMAGE;
ALTER USER SBUK_TEST_T QUOTA UNLIMITED ON TBSSIGNATURE;
ALTER USER SBUK_TEST_T QUOTA UNLIMITED ON TRBFES;
ALTER USER SBUK_TEST_T QUOTA UNLIMITED ON TS_TRANS;

GRANT READ, WRITE ON DIRECTORY SYS.DUMPDIR TO SBUK_TEST_T;

--whole dump(entering to the sys)

host (impdp SBUK_TEST_T/SBUK_TEST_T directory=DUMPDIR dumpfile=SBUK_TEST_300816.dmp logfile=IMP_SBUK_TEST_300816.log remap_schema=SBUK_TEST:SBUK_TEST_T transform=oid:n IGNORE='Y');

transform=segment_attributes:n


--without image table(entering to the sys)

host (impdp SBUK_TEST_T/SBUK_TEST_T directory=DUMPDIR dumpfile=SBUK_TEST_T_CBD_06_DEC_2014_BEFORE_MIGRATION.dmp logfile=IMP_SBUK_TEST_T_CBD_06_DEC_2014_BEFORE_MIGRATION.log remap_schema=SBUK_TEST_TUCTION:SBUK_TEST_T transform=oid:n IGNORE='Y') exclude=table:"in\('SPDOCIMAGE'\)");
