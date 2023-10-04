DECLARE
   LIBCAC   NUMBER (10, 2);
   ROWCAC   NUMBER (10, 2);
   BUFCAC   NUMBER (10, 2);
   REDLOG   NUMBER (10, 2);
   SPSIZE   NUMBER;
   BLKBUF   NUMBER;
   LOGBUF   NUMBER;
BEGIN
   SELECT VALUE
     INTO REDLOG
     FROM V$SYSSTAT
    WHERE NAME = 'redo log space requests';

   SELECT 100 * (SUM (PINS) - SUM (RELOADS)) / SUM (PINS)
     INTO LIBCAC
     FROM V$LIBRARYCACHE;

   SELECT 100 * (SUM (GETS) - SUM (GETMISSES)) / SUM (GETS)
     INTO ROWCAC
     FROM V$ROWCACHE;

   SELECT 100 * (CUR.VALUE + CON.VALUE - PHYS.VALUE)
          / (CUR.VALUE + CON.VALUE)
     INTO BUFCAC
     FROM V$SYSSTAT CUR,
          V$SYSSTAT CON,
          V$SYSSTAT PHYS,
          V$STATNAME NCU,
          V$STATNAME NCO,
          V$STATNAME NPH
    WHERE CUR.STATISTIC# = NCU.STATISTIC#
      AND NCU.NAME = 'db block gets'
      AND CON.STATISTIC# = NCO.STATISTIC#
      AND NCO.NAME = 'consistent gets'
      AND PHYS.STATISTIC# = NPH.STATISTIC#
      AND NPH.NAME = 'physical reads';

   SELECT VALUE
     INTO SPSIZE
     FROM V$PARAMETER
    WHERE NAME = 'shared_pool_size';

   SELECT VALUE
     INTO BLKBUF
     FROM V$PARAMETER
    WHERE NAME = 'db_block_buffers';

   SELECT VALUE
     INTO LOGBUF
     FROM V$PARAMETER
    WHERE NAME = 'log_buffer';

   DBMS_OUTPUT.PUT_LINE ('>                   SGA CACHE STATISTICS');
   DBMS_OUTPUT.PUT_LINE ('>                   ********************');
   DBMS_OUTPUT.PUT_LINE ('>              SQL Cache Hit rate = ' || LIBCAC);
   DBMS_OUTPUT.PUT_LINE ('>             Dict Cache Hit rate = ' || ROWCAC);
   DBMS_OUTPUT.PUT_LINE ('>           Buffer Cache Hit rate = ' || BUFCAC);
   DBMS_OUTPUT.PUT_LINE ('>         Redo Log space requests = ' || REDLOG);
   DBMS_OUTPUT.PUT_LINE ('> ');
   DBMS_OUTPUT.PUT_LINE ('>                     INIT.ORA SETTING');
   DBMS_OUTPUT.PUT_LINE ('>                     ****************');
   DBMS_OUTPUT.PUT_LINE (   '>               Shared Pool Size = '
                         || SPSIZE
                         || ' Bytes'
                        );
   DBMS_OUTPUT.PUT_LINE (   '>                DB Block Buffer = '
                         || BLKBUF
                         || ' Blocks'
                        );
   DBMS_OUTPUT.PUT_LINE (   '>                    Log Buffer  = '
                         || LOGBUF
                         || ' Bytes'
                        );
   DBMS_OUTPUT.PUT_LINE ('> ');

   IF LIBCAC < 99
   THEN
      DBMS_OUTPUT.PUT_LINE
           ('*** HINT: Library Cache too low! Increase the Shared Pool Size.');
   END IF;

   IF ROWCAC < 85
   THEN
      DBMS_OUTPUT.PUT_LINE
               ('*** HINT: Row Cache too low! Increase the Shared Pool Size.');
   END IF;

   IF BUFCAC < 90
   THEN
      DBMS_OUTPUT.PUT_LINE
         ('*** HINT: Buffer Cache too low! Increase the DB Block Buffer value.'
         );
   END IF;

   IF REDLOG > 100
   THEN
      DBMS_OUTPUT.PUT_LINE ('*** HINT: Log Buffer value is rather low!');
   END IF;
END;
/