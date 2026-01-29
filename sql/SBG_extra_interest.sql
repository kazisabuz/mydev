/*Rectification of the inter branch interest calculation process.*/
----- Step 1 : Prepare the voucher for the extra interest...

INSERT INTO AUTOPOST_TRAN_TEMP
SELECT 
NULL,
NULL,
AA.IBRNICDTL_PROC_DATE,
AA.IBRNICDTL_PROC_DATE,
1,
AA.IBRNICDTL_BRN_CODE,
AA.IBRNICDTL_BRN_CODE,
'C',
'400104101',
0,
0,
'BDT',
(AA.TOTAL_DB_AMT - AA.TOTAL_CR_AMT) TOTAL_AMT
  FROM (  SELECT A.IBRNICDTL_BRN_CODE,
                 A.IBRNICDTL_PROC_DATE,
                 SUM (A.IBRNICDTL_NEW_CR_INT_AMOUNT) - SUM(IBRNICDTL_CR_INT_AMOUNT) TOTAL_CR_AMT,
                 SUM (A.IBRNICDTL_NEW_DB_INT_AMOUNT) - SUM(IBRNICDTL_DB_INT_AMOUNT) TOTAL_DB_AMT
            FROM (SELECT IBRNICDTL_ENTITY_NUM,
                         IBRNICDTL_RUN_NUMBER,
                         IBRNICDTL_BRN_CODE,
                         IBRNICDTL_GLACC_CODE,
                         IBRNICDTL_CURR_CODE,
                         IBRNICDTL_PROC_DATE,
                         IBRNICDTL_DTL_SL_NUM,
                         IBRNICDTL_FROM_DATE,
                         IBRNICDTL_UPTO_DATE,
                         IBRNICDTL_BALANCE,
                         IBRNICDTL_CR_INT_RATE,
                         CASE
                            WHEN IBRNICDTL_CR_INT_RATE = 5.5 THEN 5.5
                            WHEN IBRNICDTL_CR_INT_RATE = 0 THEN 0
                         END
                            IBRNICDTL_NEW_CR_INT_RATE,
                         IBRNICDTL_DB_INT_RATE,
                         CASE
                            WHEN IBRNICDTL_DB_INT_RATE = 6.5 THEN 6
                            WHEN IBRNICDTL_DB_INT_RATE = 0 THEN 0
                         END
                            IBRNICDTL_NEW_DB_INT_RATE,
                         IBRNICDTL_NUM_OF_DAYS,
                         IBRNICDTL_DB_PRODUCT,
                         IBRNICDTL_CR_PRODUCT,
                         IBRNICDTL_CR_INT_AMOUNT,
                         CASE
                            WHEN IBRNICDTL_CR_PRODUCT > 0
                            THEN
                               ROUND (
                                  (IBRNICDTL_CR_PRODUCT * 5.5) / (100 * 360),
                                  0)
                            WHEN IBRNICDTL_CR_PRODUCT = 0
                            THEN
                               0
                         END
                            IBRNICDTL_NEW_CR_INT_AMOUNT,
                         IBRNICDTL_DB_INT_AMOUNT,
                         CASE
                            WHEN IBRNICDTL_DB_PRODUCT > 0
                            THEN
                               ROUND (
                                  (IBRNICDTL_DB_PRODUCT * 6) / (100 * 360),
                                  0)
                            WHEN IBRNICDTL_DB_PRODUCT = 0
                            THEN
                               0
                         END
                            IBRNICDTL_NEW_DB_INT_AMOUNT
                    FROM IBRNINTCALCDTL
                   WHERE IBRNICDTL_PROC_DATE = '31-JAN-2018') A
        GROUP BY A.IBRNICDTL_BRN_CODE,
        A.IBRNICDTL_PROC_DATE) AA
      WHERE (AA.TOTAL_DB_AMT - AA.TOTAL_CR_AMT) > 0;
      
      --------------------------------------------------------
      
INSERT INTO AUTOPOST_TRAN_TEMP      
SELECT 
NULL,
NULL,
AA.IBRNICDTL_PROC_DATE,
AA.IBRNICDTL_PROC_DATE,
1,
AA.IBRNICDTL_BRN_CODE,
AA.IBRNICDTL_BRN_CODE,
'D',
'137101165',
0,
0,
'BDT',
(AA.TOTAL_DB_AMT - AA.TOTAL_CR_AMT) TOTAL_AMT
  FROM (  SELECT A.IBRNICDTL_BRN_CODE,
                 A.IBRNICDTL_PROC_DATE,
                 SUM (A.IBRNICDTL_NEW_CR_INT_AMOUNT) - SUM(IBRNICDTL_CR_INT_AMOUNT) TOTAL_CR_AMT,
                 SUM (A.IBRNICDTL_NEW_DB_INT_AMOUNT) - SUM(IBRNICDTL_DB_INT_AMOUNT) TOTAL_DB_AMT
            FROM (SELECT IBRNICDTL_ENTITY_NUM,
                         IBRNICDTL_RUN_NUMBER,
                         IBRNICDTL_BRN_CODE,
                         IBRNICDTL_GLACC_CODE,
                         IBRNICDTL_CURR_CODE,
                         IBRNICDTL_PROC_DATE,
                         IBRNICDTL_DTL_SL_NUM,
                         IBRNICDTL_FROM_DATE,
                         IBRNICDTL_UPTO_DATE,
                         IBRNICDTL_BALANCE,
                         IBRNICDTL_CR_INT_RATE,
                         CASE
                            WHEN IBRNICDTL_CR_INT_RATE = 5.5 THEN 5.5
                            WHEN IBRNICDTL_CR_INT_RATE = 0 THEN 0
                         END
                            IBRNICDTL_NEW_CR_INT_RATE,
                         IBRNICDTL_DB_INT_RATE,
                         CASE
                            WHEN IBRNICDTL_DB_INT_RATE = 6.5 THEN 6
                            WHEN IBRNICDTL_DB_INT_RATE = 0 THEN 0
                         END
                            IBRNICDTL_NEW_DB_INT_RATE,
                         IBRNICDTL_NUM_OF_DAYS,
                         IBRNICDTL_DB_PRODUCT,
                         IBRNICDTL_CR_PRODUCT,
                         IBRNICDTL_CR_INT_AMOUNT,
                         CASE
                            WHEN IBRNICDTL_CR_PRODUCT > 0
                            THEN
                               ROUND (
                                  (IBRNICDTL_CR_PRODUCT * 5.5) / (100 * 360),
                                  0)
                            WHEN IBRNICDTL_CR_PRODUCT = 0
                            THEN
                               0
                         END
                            IBRNICDTL_NEW_CR_INT_AMOUNT,
                         IBRNICDTL_DB_INT_AMOUNT,
                         CASE
                            WHEN IBRNICDTL_DB_PRODUCT > 0
                            THEN
                               ROUND (
                                  (IBRNICDTL_DB_PRODUCT * 6) / (100 * 360),
                                  0)
                            WHEN IBRNICDTL_DB_PRODUCT = 0
                            THEN
                               0
                         END
                            IBRNICDTL_NEW_DB_INT_AMOUNT
                    FROM IBRNINTCALCDTL
                   WHERE IBRNICDTL_PROC_DATE = '31-JAN-2018') A
        GROUP BY A.IBRNICDTL_BRN_CODE,
        A.IBRNICDTL_PROC_DATE) AA
      WHERE (AA.TOTAL_DB_AMT - AA.TOTAL_CR_AMT) > 0;
      
      
      ----------------------------------------------------
      
      
INSERT INTO AUTOPOST_TRAN_TEMP      
SELECT 
NULL,
NULL,
AA.IBRNICDTL_PROC_DATE,
AA.IBRNICDTL_PROC_DATE,
1,
AA.IBRNICDTL_BRN_CODE,
AA.IBRNICDTL_BRN_CODE,
'C',
'225122231',
0,
0,
'BDT',
ABS(AA.TOTAL_DB_AMT - AA.TOTAL_CR_AMT) TOTAL_AMT
  FROM (  SELECT A.IBRNICDTL_BRN_CODE,
                 A.IBRNICDTL_PROC_DATE,
                 SUM (A.IBRNICDTL_NEW_CR_INT_AMOUNT) - SUM(IBRNICDTL_CR_INT_AMOUNT) TOTAL_CR_AMT,
                 SUM (A.IBRNICDTL_NEW_DB_INT_AMOUNT) - SUM(IBRNICDTL_DB_INT_AMOUNT) TOTAL_DB_AMT
            FROM (SELECT IBRNICDTL_ENTITY_NUM,
                         IBRNICDTL_RUN_NUMBER,
                         IBRNICDTL_BRN_CODE,
                         IBRNICDTL_GLACC_CODE,
                         IBRNICDTL_CURR_CODE,
                         IBRNICDTL_PROC_DATE,
                         IBRNICDTL_DTL_SL_NUM,
                         IBRNICDTL_FROM_DATE,
                         IBRNICDTL_UPTO_DATE,
                         IBRNICDTL_BALANCE,
                         IBRNICDTL_CR_INT_RATE,
                         CASE
                            WHEN IBRNICDTL_CR_INT_RATE = 5.5 THEN 5.5
                            WHEN IBRNICDTL_CR_INT_RATE = 0 THEN 0
                         END
                            IBRNICDTL_NEW_CR_INT_RATE,
                         IBRNICDTL_DB_INT_RATE,
                         CASE
                            WHEN IBRNICDTL_DB_INT_RATE = 6.5 THEN 6
                            WHEN IBRNICDTL_DB_INT_RATE = 0 THEN 0
                         END
                            IBRNICDTL_NEW_DB_INT_RATE,
                         IBRNICDTL_NUM_OF_DAYS,
                         IBRNICDTL_DB_PRODUCT,
                         IBRNICDTL_CR_PRODUCT,
                         IBRNICDTL_CR_INT_AMOUNT,
                         CASE
                            WHEN IBRNICDTL_CR_PRODUCT > 0
                            THEN
                               ROUND (
                                  (IBRNICDTL_CR_PRODUCT * 5.5) / (100 * 360),
                                  0)
                            WHEN IBRNICDTL_CR_PRODUCT = 0
                            THEN
                               0
                         END
                            IBRNICDTL_NEW_CR_INT_AMOUNT,
                         IBRNICDTL_DB_INT_AMOUNT,
                         CASE
                            WHEN IBRNICDTL_DB_PRODUCT > 0
                            THEN
                               ROUND (
                                  (IBRNICDTL_DB_PRODUCT * 6) / (100 * 360),
                                  0)
                            WHEN IBRNICDTL_DB_PRODUCT = 0
                            THEN
                               0
                         END
                            IBRNICDTL_NEW_DB_INT_AMOUNT
                    FROM IBRNINTCALCDTL
                   WHERE IBRNICDTL_PROC_DATE = '31-JAN-2018') A
        GROUP BY A.IBRNICDTL_BRN_CODE,
        A.IBRNICDTL_PROC_DATE) AA
      WHERE (AA.TOTAL_DB_AMT - AA.TOTAL_CR_AMT)<0;
      
      ----------------------------------------------------
      
INSERT INTO AUTOPOST_TRAN_TEMP      
SELECT 
NULL,
NULL,
AA.IBRNICDTL_PROC_DATE,
AA.IBRNICDTL_PROC_DATE,
1,
AA.IBRNICDTL_BRN_CODE,
AA.IBRNICDTL_BRN_CODE,
'D',
'300116101',
0,
0,
'BDT',
ABS(AA.TOTAL_DB_AMT - AA.TOTAL_CR_AMT) TOTAL_AMT
  FROM (  SELECT A.IBRNICDTL_BRN_CODE,
                 A.IBRNICDTL_PROC_DATE,
                 SUM (A.IBRNICDTL_NEW_CR_INT_AMOUNT) - SUM(IBRNICDTL_CR_INT_AMOUNT) TOTAL_CR_AMT,
                 SUM (A.IBRNICDTL_NEW_DB_INT_AMOUNT) - SUM(IBRNICDTL_DB_INT_AMOUNT) TOTAL_DB_AMT
            FROM (SELECT IBRNICDTL_ENTITY_NUM,
                         IBRNICDTL_RUN_NUMBER,
                         IBRNICDTL_BRN_CODE,
                         IBRNICDTL_GLACC_CODE,
                         IBRNICDTL_CURR_CODE,
                         IBRNICDTL_PROC_DATE,
                         IBRNICDTL_DTL_SL_NUM,
                         IBRNICDTL_FROM_DATE,
                         IBRNICDTL_UPTO_DATE,
                         IBRNICDTL_BALANCE,
                         IBRNICDTL_CR_INT_RATE,
                         CASE
                            WHEN IBRNICDTL_CR_INT_RATE = 5.5 THEN 5.5
                            WHEN IBRNICDTL_CR_INT_RATE = 0 THEN 0
                         END
                            IBRNICDTL_NEW_CR_INT_RATE,
                         IBRNICDTL_DB_INT_RATE,
                         CASE
                            WHEN IBRNICDTL_DB_INT_RATE = 6.5 THEN 6
                            WHEN IBRNICDTL_DB_INT_RATE = 0 THEN 0
                         END
                            IBRNICDTL_NEW_DB_INT_RATE,
                         IBRNICDTL_NUM_OF_DAYS,
                         IBRNICDTL_DB_PRODUCT,
                         IBRNICDTL_CR_PRODUCT,
                         IBRNICDTL_CR_INT_AMOUNT,
                         CASE
                            WHEN IBRNICDTL_CR_PRODUCT > 0
                            THEN
                               ROUND (
                                  (IBRNICDTL_CR_PRODUCT * 5.5) / (100 * 360),
                                  0)
                            WHEN IBRNICDTL_CR_PRODUCT = 0
                            THEN
                               0
                         END
                            IBRNICDTL_NEW_CR_INT_AMOUNT,
                         IBRNICDTL_DB_INT_AMOUNT,
                         CASE
                            WHEN IBRNICDTL_DB_PRODUCT > 0
                            THEN
                               ROUND (
                                  (IBRNICDTL_DB_PRODUCT * 6) / (100 * 360),
                                  0)
                            WHEN IBRNICDTL_DB_PRODUCT = 0
                            THEN
                               0
                         END
                            IBRNICDTL_NEW_DB_INT_AMOUNT
                    FROM IBRNINTCALCDTL
                   WHERE IBRNICDTL_PROC_DATE = '31-JAN-2018') A
        GROUP BY A.IBRNICDTL_BRN_CODE,
        A.IBRNICDTL_PROC_DATE) AA
      WHERE (AA.TOTAL_DB_AMT - AA.TOTAL_CR_AMT) < 0;

	  
	  
	  
----- Step 2 : Update for the table -----
	  
BEGIN
   FOR IDX
      IN (SELECT ROW_NUMBER () OVER (PARTITION BY BRN_CODE ORDER BY BRN_CODE)
                    LEG_NO,
                 T.*
            FROM AUTOPOST_TRAN_TEMP T)
   LOOP
      UPDATE AUTOPOST_TRAN_TEMP
         SET LEG_SL = IDX.LEG_NO
       WHERE     TRAN_DATE = IDX.TRAN_DATE
             AND VALUE_DATE = IDX.VALUE_DATE
             AND BRN_CODE = IDX.BRN_CODE
             AND DR_CR = IDX.DR_CR;
   END LOOP;
END;


BEGIN
   FOR idx IN (SELECT ROWNUM r_num, t.*
                 FROM (  SELECT DISTINCT TRAN_DATE, BRN_CODE
                           FROM AUTOPOST_TRAN_TEMP
                       ORDER BY BRN_CODE) t)
   LOOP
      UPDATE AUTOPOST_TRAN_TEMP
         SET BATCH_SL = idx.r_num
       WHERE TRAN_DATE = idx.TRAN_DATE AND BRN_CODE = idx.BRN_CODE;
   END LOOP;
END;


--insert data from AUTOPOST_TRAN_TEMP table to AUTOPOST_TRAN table ......

UPDATE AUTOPOST_TRAN SET 
LEG_NARRATION = 'SBG extra intrerest', BATCH_NARRATION = 'SBG extra intrerest', USER_ID = 'INTELECT' ;







-- Step 3 : ----------------------- Update in the main table ---------------------------




DECLARE
V_COUNT NUMBER := 0;
BEGIN
   FOR IDX
      IN (SELECT AA.IBRNICDTL_BRN_CODE,
                 AA.IBRNICDTL_PROC_DATE,
                 AA.TOTAL_CR_AMT,
                 AA.TOTAL_DB_AMT,
                 (AA.TOTAL_DB_AMT - AA.TOTAL_CR_AMT) TOTAL_AMT
            FROM (  SELECT A.IBRNICDTL_BRN_CODE,
                           A.IBRNICDTL_PROC_DATE,
                           SUM (A.IBRNICDTL_NEW_CR_INT_AMOUNT) TOTAL_CR_AMT,
                           SUM (A.IBRNICDTL_NEW_DB_INT_AMOUNT) TOTAL_DB_AMT
                      FROM (SELECT IBRNICDTL_ENTITY_NUM,
                                   IBRNICDTL_RUN_NUMBER,
                                   IBRNICDTL_BRN_CODE,
                                   IBRNICDTL_GLACC_CODE,
                                   IBRNICDTL_CURR_CODE,
                                   IBRNICDTL_PROC_DATE,
                                   IBRNICDTL_DTL_SL_NUM,
                                   IBRNICDTL_FROM_DATE,
                                   IBRNICDTL_UPTO_DATE,
                                   IBRNICDTL_BALANCE,
                                   IBRNICDTL_CR_INT_RATE,
                                   CASE
                                      WHEN IBRNICDTL_CR_INT_RATE = 5 THEN 5.5
                                      WHEN IBRNICDTL_CR_INT_RATE = 0 THEN 0
                                   END
                                      IBRNICDTL_NEW_CR_INT_RATE,
                                   IBRNICDTL_DB_INT_RATE,
                                   CASE
                                      WHEN IBRNICDTL_DB_INT_RATE = 5 THEN 5.5
                                      WHEN IBRNICDTL_DB_INT_RATE = 0 THEN 0
                                   END
                                      IBRNICDTL_NEW_DB_INT_RATE,
                                   IBRNICDTL_NUM_OF_DAYS,
                                   IBRNICDTL_DB_PRODUCT,
                                   IBRNICDTL_CR_PRODUCT,
                                   IBRNICDTL_CR_INT_AMOUNT,
                                   CASE
                                      WHEN IBRNICDTL_CR_PRODUCT > 0
                                      THEN
                                         ROUND (
                                              (IBRNICDTL_CR_PRODUCT * 5.5)
                                            / 36000,
                                            0)
                                      WHEN IBRNICDTL_CR_PRODUCT = 0
                                      THEN
                                         0
                                   END
                                      IBRNICDTL_NEW_CR_INT_AMOUNT,
                                   IBRNICDTL_DB_INT_AMOUNT,
                                   CASE
                                      WHEN IBRNICDTL_DB_PRODUCT > 0
                                      THEN
                                         ROUND (
                                              (IBRNICDTL_DB_PRODUCT * 5.5)
                                            / 36000,
                                            0)
                                      WHEN IBRNICDTL_DB_PRODUCT = 0
                                      THEN
                                         0
                                   END
                                      IBRNICDTL_NEW_DB_INT_AMOUNT
                              FROM IBRNINTCALCDTL
                             WHERE IBRNICDTL_PROC_DATE =
                                      TO_DATE ('07/31/2017 00:00:00',
                                               'MM/DD/YYYY HH24:MI:SS')) A
                  GROUP BY A.IBRNICDTL_BRN_CODE, A.IBRNICDTL_PROC_DATE) AA)
   LOOP
      UPDATE IBRNINTCALC
         SET IBRNINTCALC_DB_BAL_INT = IDX.TOTAL_AMT,
             IBRNINTCALC_CR_BAL_INT = 0,
             IBRNINTCALC_CR_BAL_INT_RND = 0,
             IBRNINTCALC_DB_BAL_INT_RND = IDX.TOTAL_AMT
       WHERE     IDX.TOTAL_AMT > 0
             AND IBRNINTCALC_BRN_CODE = IDX.IBRNICDTL_BRN_CODE
             AND IBRNINTCALC_PROC_DATE = IDX.IBRNICDTL_PROC_DATE;
             V_COUNT := V_COUNT + SQL%ROWCOUNT ;
      UPDATE IBRNINTCALC
         SET IBRNINTCALC_DB_BAL_INT = 0,
             IBRNINTCALC_CR_BAL_INT = ABS (IDX.TOTAL_AMT),
             IBRNINTCALC_CR_BAL_INT_RND = ABS (IDX.TOTAL_AMT),
             IBRNINTCALC_DB_BAL_INT_RND = 0
       WHERE     IDX.TOTAL_AMT < 0
             AND IBRNINTCALC_BRN_CODE = IDX.IBRNICDTL_BRN_CODE
             AND IBRNINTCALC_PROC_DATE = IDX.IBRNICDTL_PROC_DATE;
             V_COUNT := V_COUNT + SQL%ROWCOUNT ;
   END LOOP;
   DBMS_OUTPUT.PUT_LINE (V_COUNT);
END;
    
	
	
	
-- Step 4 :------------------ Update in the detail table -----------------------


DECLARE
V_COUNT NUMBER := 0;
BEGIN
   FOR IDX
      IN (SELECT IBRNICDTL_ENTITY_NUM,
                 IBRNICDTL_RUN_NUMBER,
                 IBRNICDTL_BRN_CODE,
                 IBRNICDTL_GLACC_CODE,
                 IBRNICDTL_CURR_CODE,
                 IBRNICDTL_PROC_DATE,
                 IBRNICDTL_DTL_SL_NUM,
                 IBRNICDTL_FROM_DATE,
                 IBRNICDTL_UPTO_DATE,
                 IBRNICDTL_BALANCE,
                 IBRNICDTL_CR_INT_RATE,
                 CASE
                    WHEN IBRNICDTL_CR_INT_RATE = 5 THEN 5.5
                    WHEN IBRNICDTL_CR_INT_RATE = 0 THEN 0
                 END
                    NEW_CR_INT_RATE,
                 IBRNICDTL_DB_INT_RATE,
                 CASE
                    WHEN IBRNICDTL_DB_INT_RATE = 5 THEN 5.5
                    WHEN IBRNICDTL_DB_INT_RATE = 0 THEN 0
                 END
                    NEW_DB_INT_RATE,
                 IBRNICDTL_NUM_OF_DAYS,
                 IBRNICDTL_DB_PRODUCT,
                 IBRNICDTL_CR_PRODUCT,
                 IBRNICDTL_CR_INT_AMOUNT,
                 CASE
                    WHEN IBRNICDTL_CR_PRODUCT > 0
                    THEN
                       ROUND ( (IBRNICDTL_CR_PRODUCT * 5.5) / 36000, 0)
                    WHEN IBRNICDTL_CR_PRODUCT = 0
                    THEN
                       0
                 END
                    NEW_CR_INT_AMOUNT,
                 IBRNICDTL_DB_INT_AMOUNT,
                 CASE
                    WHEN IBRNICDTL_DB_PRODUCT > 0
                    THEN
                       ROUND ( (IBRNICDTL_DB_PRODUCT * 5.5) / 36000, 0)
                    WHEN IBRNICDTL_DB_PRODUCT = 0
                    THEN
                       0
                 END
                    NEW_DB_INT_AMOUNT
            FROM IBRNINTCALCDTL
           WHERE IBRNICDTL_PROC_DATE =
                    TO_DATE ('07/31/2017 00:00:00', 'MM/DD/YYYY HH24:MI:SS'))
   LOOP
      UPDATE IBRNINTCALCDTL
         SET IBRNICDTL_CR_INT_RATE = IDX.NEW_CR_INT_RATE,
             IBRNICDTL_DB_INT_RATE = IDX.NEW_DB_INT_RATE,
             IBRNICDTL_CR_INT_AMOUNT = IDX.NEW_CR_INT_AMOUNT,
             IBRNICDTL_DB_INT_AMOUNT = IDX.NEW_DB_INT_AMOUNT
       WHERE     IBRNICDTL_ENTITY_NUM = IDX.IBRNICDTL_ENTITY_NUM
       AND IBRNICDTL_RUN_NUMBER = IDX.IBRNICDTL_RUN_NUMBER
             AND IBRNICDTL_BRN_CODE = IDX.IBRNICDTL_BRN_CODE
             AND IBRNICDTL_PROC_DATE = IDX.IBRNICDTL_PROC_DATE
             AND IBRNICDTL_DTL_SL_NUM = IDX.IBRNICDTL_DTL_SL_NUM
             AND IBRNICDTL_FROM_DATE = IDX.IBRNICDTL_FROM_DATE
             AND IBRNICDTL_UPTO_DATE = IDX.IBRNICDTL_UPTO_DATE;
             V_COUNT := V_COUNT + SQL%ROWCOUNT ;
   END LOOP;
   DBMS_OUTPUT.PUT_LINE (V_COUNT);
END; 
