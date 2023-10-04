 SELECT  *
  FROM (  SELECT TO_CHAR (T.TRAN_ENTD_ON, 'hh24') hou,
                 TRAN_ENTD_ON,
                 COUNT (DISTINCT (TRAN_BATCH_NUMBER))
            FROM tran2018 T
           WHERE     TRUNC (T.TRAN_ENTD_ON) =
                        TO_DATE ('07-JAN-2018', 'DD-MON-YYYY HH12:MI:SS')
                 AND TRAN_ENTITY_NUM = 1
        GROUP BY T.TRAN_ENTD_ON
        ORDER BY T.TRAN_ENTD_ON) S
 WHERE hou = 11;
 
 
  SELECT t.*
  FROM (  SELECT TO_CHAR (T.TRAN_ENTD_ON, 'mi') hou,
                 TRAN_ENTD_ON,
                 COUNT (DISTINCT (TRAN_BATCH_NUMBER))
            FROM tran2018 T
           WHERE     TRUNC (T.TRAN_ENTD_ON) =
                        TO_DATE ('07-JAN-2018', 'DD-MON-YYYY HH12:MI:SS')
                 AND TRAN_ENTITY_NUM = 1
        GROUP BY T.TRAN_ENTD_ON
        ORDER BY T.TRAN_ENTD_ON) t
 WHERE hou = 11