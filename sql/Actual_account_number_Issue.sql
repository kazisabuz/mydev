---- Account Numbers with balance -----------------------------
---- Some of the accounts here is duplicate with balance......

SELECT TEST_TABLE.*, ACNTBAL_BC_BAL FROM ACNTBAL ,
(SELECT IACLINK_ENTITY_NUM, IACLINK_INTERNAL_ACNUM, IACLINK_ACTUAL_ACNUM, 
  ROW_NUMBER() OVER (
                    PARTITION BY IACLINK_ACTUAL_ACNUM
                    ORDER BY
                       IACLINK_INTERNAL_ACNUM) SL
    FROM IACLINK
   WHERE     IACLINK_ENTITY_NUM = 1
         AND IACLINK_ACTUAL_ACNUM IN
                (  SELECT I.IACLINK_ACTUAL_ACNUM
                     FROM IACLINK I
                 GROUP BY I.IACLINK_ACTUAL_ACNUM
                   HAVING COUNT (I.IACLINK_INTERNAL_ACNUM) > 1)) TEST_TABLE
WHERE TEST_TABLE.IACLINK_ENTITY_NUM = 1
AND TEST_TABLE.IACLINK_INTERNAL_ACNUM = ACNTBAL_INTERNAL_ACNUM
AND ACNTBAL_ENTITY_NUM = 1
AND ACNTBAL_BC_BAL <> 0
ORDER BY IACLINK_ACTUAL_ACNUM, ACNTBAL_INTERNAL_ACNUM



---- Account Numbers with zero balance -----------------------
---- The second query has some accounts that have zero balance. But they both have transaction.....
--1.
SELECT * FROM 
(SELECT IACLINK_ENTITY_NUM,
       IACLINK_INTERNAL_ACNUM,
       IACLINK_ACTUAL_ACNUM,
       ROW_NUMBER ()
       OVER (PARTITION BY IACLINK_ACTUAL_ACNUM
             ORDER BY IACLINK_INTERNAL_ACNUM)
          SL
  FROM IACLINK
 WHERE     IACLINK_ENTITY_NUM = 1
       AND IACLINK_ACTUAL_ACNUM IN
              (  SELECT I.IACLINK_ACTUAL_ACNUM
                   FROM IACLINK I
                   WHERE I.IACLINK_ACTUAL_ACNUM NOT IN (
                   SELECT TEST_TABLE_1.IACLINK_ACTUAL_ACNUM
                 FROM ACNTBAL AC,
                      (SELECT IACLINK_ENTITY_NUM,
                              IACLINK_INTERNAL_ACNUM,
                              IACLINK_ACTUAL_ACNUM,
                              ROW_NUMBER ()
                              OVER (PARTITION BY IACLINK_ACTUAL_ACNUM
                                    ORDER BY IACLINK_INTERNAL_ACNUM)
                                 SL
                         FROM IACLINK III
                        WHERE     III.IACLINK_ENTITY_NUM = 1
                              AND III.IACLINK_ACTUAL_ACNUM IN
                                     (  SELECT II.IACLINK_ACTUAL_ACNUM
                                          FROM IACLINK II
                                      GROUP BY II.IACLINK_ACTUAL_ACNUM
                                        HAVING COUNT (
                                                  II.IACLINK_INTERNAL_ACNUM) >
                                                  1)) TEST_TABLE_1
                WHERE     TEST_TABLE_1.IACLINK_ENTITY_NUM = 1
                      AND TEST_TABLE_1.IACLINK_INTERNAL_ACNUM =
                             ACNTBAL_INTERNAL_ACNUM
                      AND AC.ACNTBAL_ENTITY_NUM = 1
                      AND AC.ACNTBAL_BC_BAL <> 0                   
                   )
               GROUP BY I.IACLINK_ACTUAL_ACNUM
                 HAVING COUNT (I.IACLINK_INTERNAL_ACNUM) > 1)) TEST_TABLE
                 WHERE TEST_TABLE.SL = 1;
                 
--2.                 
SELECT IA.IACLINK_ACTUAL_ACNUM, AB.* FROM IACLINK IA, ACNTBAL AB WHERE IA.IACLINK_ACTUAL_ACNUM IN (            
  SELECT I.IACLINK_ACTUAL_ACNUM
                   FROM IACLINK I
                   WHERE I.IACLINK_ACTUAL_ACNUM NOT IN (
                   SELECT TEST_TABLE_1.IACLINK_ACTUAL_ACNUM
                 FROM ACNTBAL AC,
                      (SELECT IACLINK_ENTITY_NUM,
                              IACLINK_INTERNAL_ACNUM,
                              IACLINK_ACTUAL_ACNUM,
                              ROW_NUMBER ()
                              OVER (PARTITION BY IACLINK_ACTUAL_ACNUM
                                    ORDER BY IACLINK_INTERNAL_ACNUM)
                                 SL
                         FROM IACLINK III
                        WHERE     III.IACLINK_ENTITY_NUM = 1
                              AND III.IACLINK_ACTUAL_ACNUM IN
                                     (  SELECT II.IACLINK_ACTUAL_ACNUM
                                          FROM IACLINK II
                                      GROUP BY II.IACLINK_ACTUAL_ACNUM
                                        HAVING COUNT (
                                                  II.IACLINK_INTERNAL_ACNUM) >
                                                  1)) TEST_TABLE_1
                WHERE     TEST_TABLE_1.IACLINK_ENTITY_NUM = 1
                      AND TEST_TABLE_1.IACLINK_INTERNAL_ACNUM =
                             ACNTBAL_INTERNAL_ACNUM
                      AND AC.ACNTBAL_ENTITY_NUM = 1
                      AND AC.ACNTBAL_BC_BAL <> 0                   
                   )
               GROUP BY I.IACLINK_ACTUAL_ACNUM
                 HAVING COUNT (I.IACLINK_INTERNAL_ACNUM) > 1)
                 AND ACNTBAL_ENTITY_NUM = IACLINK_ENTITY_NUM AND ACNTBAL_INTERNAL_ACNUM = IACLINK_INTERNAL_ACNUM 
                 ORDER BY IA.IACLINK_ACTUAL_ACNUM , AB.ACNTBAL_INTERNAL_ACNUM ;
				 
				 
				 
				 
				 
				 
--------------- Product Code of the accounts-----------

SELECT DISTINCT IACLINK_PROD_CODE FROM IACLINK WHERE IACLINK_ACTUAL_ACNUM IN (
SELECT I.IACLINK_ACTUAL_ACNUM
                     FROM IACLINK I
                 GROUP BY I.IACLINK_ACTUAL_ACNUM
                   HAVING COUNT (I.IACLINK_INTERNAL_ACNUM) > 1) ;
				   
				   
				   
---------------Opening Date -----------------

SELECT * FROM ACNTS WHERE ACNTS_INTERNAL_ACNUM IN (
SELECT IACLINK_INTERNAL_ACNUM FROM IACLINK WHERE IACLINK_ACTUAL_ACNUM IN (
SELECT I.IACLINK_ACTUAL_ACNUM
                     FROM IACLINK I
                 GROUP BY I.IACLINK_ACTUAL_ACNUM
                   HAVING COUNT (I.IACLINK_INTERNAL_ACNUM) > 1))
                   ORDER BY ACNTS_OPENING_DATE;
				   
				   
				   
				   
SELECT *
    FROM (SELECT ACNTS_ENTITY_NUM,
                 ACNTS_INTERNAL_ACNUM,
                 ACNTS_OPENING_DATE,
                 I.IACLINK_ACTUAL_ACNUM,
                 ROW_NUMBER ()
                 OVER (PARTITION BY I.IACLINK_ACTUAL_ACNUM
                       ORDER BY ACNTS_OPENING_DATE)
                    SL
            FROM ACNTS, IACLINK I
           WHERE     ACNTS_ENTITY_NUM = 1
                 AND ACNTS_INTERNAL_ACNUM = I.IACLINK_INTERNAL_ACNUM
                 AND I.IACLINK_ENTITY_NUM = 1
                 AND I.IACLINK_ACTUAL_ACNUM IN (  SELECT IACLINK_ACTUAL_ACNUM
                                                    FROM IACLINK
                                                GROUP BY IACLINK_ACTUAL_ACNUM
                                                  HAVING COUNT (*) > 1)) TT
   WHERE TT.SL > 1
ORDER BY TT.ACNTS_OPENING_DATE
				   
				   
				   

---------------- One account is duplicated during migration-------------------
---------------- MIG --------------------


SELECT IACLINK_ACTUAL_ACNUM , COUNT(*) FROM ACNTS , IACLINK
WHERE ACNTS_ENTITY_NUM = 1 AND ACNTS_INTERNAL_ACNUM = IACLINK_INTERNAL_ACNUM
AND IACLINK_ENTITY_NUM = 1
AND ACNTS_ENTD_BY = 'MIG'
GROUP BY IACLINK_ACTUAL_ACNUM
HAVING COUNT(*) > 1 ;






-----------------------------------===============================================----------------------------------------



SELECT II.IACLINK_INTERNAL_ACNUM, II.IACLINK_ACTUAL_ACNUM, ROW_NUMBER () OVER (PARTITION BY II.IACLINK_ACTUAL_ACNUM
                       ORDER BY II.IACLINK_INTERNAL_ACNUM) SL,   AA.ACNTBAL_BC_BAL FROM IACLINK II ,ACNTBAL AA,
(SELECT TEST_TABLE.*, ACNTBAL_BC_BAL 
    FROM ACNTBAL,
         (SELECT IACLINK_ENTITY_NUM,
                 IACLINK_INTERNAL_ACNUM,
                 IACLINK_ACTUAL_ACNUM,
                 ROW_NUMBER ()
                 OVER (PARTITION BY IACLINK_ACTUAL_ACNUM
                       ORDER BY IACLINK_INTERNAL_ACNUM)
                    SL
            FROM IACLINK
           WHERE     IACLINK_ENTITY_NUM = 1
                 AND IACLINK_ACTUAL_ACNUM IN
                        (  SELECT I.IACLINK_ACTUAL_ACNUM
                             FROM IACLINK I
                         GROUP BY I.IACLINK_ACTUAL_ACNUM
                           HAVING COUNT (
                                     I.IACLINK_INTERNAL_ACNUM) > 1)) TEST_TABLE
   WHERE     TEST_TABLE.IACLINK_ENTITY_NUM = 1
         AND TEST_TABLE.IACLINK_INTERNAL_ACNUM = ACNTBAL_INTERNAL_ACNUM
         AND ACNTBAL_ENTITY_NUM = 1
         AND ACNTBAL_BC_BAL <> 0) TEMP_DATA 
WHERE II.IACLINK_ENTITY_NUM = 1
AND  II.IACLINK_ACTUAL_ACNUM = TEMP_DATA.IACLINK_ACTUAL_ACNUM
AND AA.ACNTBAL_ENTITY_NUM = 1
AND  AA.ACNTBAL_INTERNAL_ACNUM = II.IACLINK_INTERNAL_ACNUM 
ORDER BY II.IACLINK_ACTUAL_ACNUM, SL