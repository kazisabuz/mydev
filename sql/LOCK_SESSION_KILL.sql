-------NORMAL SESSION-----
SELECT    'alter system kill session '''
       || S.SID
       || ', '
       || S.SERIAL#
       ||''''|| ';'
  FROM DBA_OBJECTS AO, V$SESSION S
 WHERE AO.OBJECT_ID = S.SID
 and s.osuser='kazi.sabuj';
 
---paramerter value
SELECT a.sql_text,
       b.name,
       b.position,
       b.datatype_string,
       b.value_string
  FROM v$sql_bind_capture b, v$sqlarea a
 WHERE b.sql_id = 'dpf3w96us2797' AND b.sql_id = a.sql_id;

---LOCK SESSION-------
SELECT    'alter system kill session '''
       || S.SID
       || ', '
       || S.SERIAL#
       ||''''|| ';'
  FROM V$LOCKED_OBJECT LO, DBA_OBJECTS AO, V$SESSION S
 WHERE AO.OBJECT_ID = LO.OBJECT_ID AND LO.SESSION_ID = S.SID;
 
 ----NEW--------
 SELECT O.OBJECT_NAME, S.SID, S.SERIAL#, P.SPID, S.PROGRAM,S.USERNAME,
S.MACHINE,S.PORT , S.LOGON_TIME,SQ.SQL_FULLTEXT 
FROM   DBA_OBJECTS O, V$SESSION S, 
V$PROCESS P, V$SQL SQ 
WHERE L.OBJECT_ID = O.OBJECT_ID 
AND L.SESSION_ID = S.SID AND S.PADDR = P.ADDR 
AND S.SQL_ADDRESS = SQ.ADDRESS;
 
 
 
  
SELECT s.*
  FROM V$SESSION s, DBA_DML_LOCKS
 WHERE SID = SESSION_ID
 and STATUS='ACTIVE';
 
 
 
/* Formatted on 24/12/2017 7:41:13 PM (QP5 v5.227.12220.39754) */
  SELECT A.SID BLOCKER, 'is blocking the session ', B.SID BLOCKEE
    FROM V$LOCK A, V$LOCK B
   WHERE A.BLOCK = 1 AND B.REQUEST > 0 AND A.ID1 = B.ID1 AND A.ID2 = B.ID2
ORDER BY A.SID;

-------------------------------------------------------
  SELECT S.INST_ID,
         S.SID,
         serial#,
            'ALTER SYSTEM KILL SESSION '''
         || S.SID
         || ','
         || serial#
         || ',@'
         || S.INST_ID
         || ''' IMMEDIATE;'
            KILL_STATEMENT,
         NOSBLOCKED,
         (SELECT SQL_FULLTEXT
            FROM V$SQLAREA A
           WHERE A.SQL_ID = S.SQL_ID)
            SQL_FULLTEXT,
         EVENT,
         USERNAME,
         STATUS,
         MACHINE,
         OSUSER,
         PROGRAM,
         NVL (SQL_ID, PREV_SQL_ID) SQL_ID,
         seconds_in_wait
    FROM GV$SESSION S,
         (  SELECT INST_ID, BLOCKING_SESSION, COUNT (BLOCKING_SESSION) NOSBLOCKED
              FROM GV$SESSION
             WHERE BLOCKING_SESSION IS NOT NULL
          GROUP BY INST_ID, BLOCKING_SESSION) BS
   WHERE S.INST_ID = BS.INST_ID AND S.SID = BS.BLOCKING_SESSION
  -- and SID in (1902,6193,5728)
ORDER BY NOSBLOCKED DESC;




-----------------------INACTIVE SESSION---------------------------
/* Formatted on 11/11/2021 12:24:36 PM (QP5 v5.252.13127.32867) */
SELECT /*+ PARALLEL( 16) */
      SCHEMA#,
       SCHEMANAME,
       OSUSER,
       PROCESS,
       MACHINE,
       PORT,
       TERMINAL,
       PROGRAM,
       SQL_TEXT,
       SQL_FULLTEXT,
       SQ.SQL_ID
  FROM V$SESSION S, V$SQL SQ
 WHERE     S.SQL_ADDRESS = SQ.ADDRESS
       AND SQ.SQL_ID = s.SQL_ID
       AND STATUS = 'INACTIVE'
       AND TRUNC (PREV_EXEC_START) = '11-nov-2021';
       
       
       
       
       /* Formatted on 11/11/2021 1:56:19 PM (QP5 v5.252.13127.32867) */
SELECT /*+ PARALLEL( 16) */
      SCHEMA#,
       SCHEMANAME,
       OSUSER,
       PROCESS,
       MACHINE,
       PORT,
       TERMINAL,
       PROGRAM,
       SQL_TEXT,
       SQL_FULLTEXT,
       SQ.SQL_ID,
       STATUS
  FROM V$SESSION S LEFT OUTER JOIN V$SQL SQ ON SQ.SQL_ID = s.SQL_ID
 WHERE     STATUS = 'INACTIVE'
       AND TRUNC (PREV_EXEC_START) = '11-nov-2021';
       
       
--------------------------------------------------------------------------
/* Formatted on 4/11/2023 11:03:10 AM (QP5 v5.388) */
SELECT se.inst_id,
       lk.SID,
       se.username,
       se.OSUser,
       se.Machine,
       DECODE (lk.TYPE,
               'TX', 'Transaction',
               'TM', 'DML',
               'UL', 'PL/SQL User Lock',
               lk.TYPE)                                        lock_type,
       DECODE (lk.lmode,
               0, 'None',
               1, 'Null',
               2, 'Row-S (SS)',
               3, 'Row-X (SX)',
               4, 'Share',
               5, 'S/Row-X (SSX)',
               6, 'Exclusive',
               TO_CHAR (lk.lmode))                             mode_held,
       DECODE (lk.request,
               0, 'None',
               1, 'Null',
               2, 'Row-S (SS)',
               3, 'Row-X (SX)',
               4, 'Share',
               5, 'S/Row-X (SSX)',
               6, 'Exclusive',
               TO_CHAR (lk.request))                           mode_requested,
       TO_CHAR (lk.id1)                                        lock_id1,
       TO_CHAR (lk.id2)                                        lock_id2,
       ob.owner,
       ob.object_type,
       ob.object_name,
       DECODE (lk.Block,  0, 'No',  1, 'Yes',  2, 'Global')    block,
       se.lockwait
  FROM GV$lock lk, dba_objects ob, GV$session se
 WHERE     lk.TYPE IN ('TX', 'TM', 'UL')
       AND lk.SID = se.SID
       AND lk.id1 = ob.object_id(+)
       AND lk.inst_id = se.inst_id;
       
       
       
CREATE OR REPLACE PROCEDURE SYS.SP_INACTIVE_SES_KILL
IS
BEGIN
   FOR IDX
      IN (SELECT    'ALTER SYSTEM KILL SESSION '''
                 || S.SID
                 || ','
                 || SERIAL#
                 || ',@'
                 || S.INST_ID
                 || ''' IMMEDIATE'
                    KILL_STATEMENT
            FROM GV$SESSION S
           WHERE     STATUS = 'INACTIVE'
                 AND OSUSER IN ('rbt', 'rpt')
                 AND LAST_CALL_ET > 60 * 60 * 2
                 AND S.SQL_ID IS NULL)
   LOOP
      BEGIN
         EXECUTE IMMEDIATE IDX.KILL_STATEMENT;
      END;
   END LOOP;
END;
/