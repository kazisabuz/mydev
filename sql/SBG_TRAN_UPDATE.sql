/*Update for the calculated interest amount. After the realtime calculation, customer requested to change the interest rate of the GL and we had to update the calculated records manually and pass the vouchers according to the newly calculated amount.*/

DECLARE
V_COUNT NUMBER :=0;
BEGIN
   FOR IDX
      IN (  SELECT TT.IBRNICDTL_RUN_NUMBER,
                   TT.IBRNICDTL_BRN_CODE,
                   TT.IBRNICDTL_GLACC_CODE,
                   TT.IBRNICDTL_CURR_CODE,
                   TT.IBRNICDTL_PROC_DATE,
                   SUM (NEW_IBRNICDTL_CR_INT_AMOUNT) SUM_CR_INT_AMT,
                   SUM (NEW_IBRNICDTL_DR_INT_AMOUNT) SUM_DR_INT_AMT
              FROM (SELECT T.*,
                             T.NEW_IBRNICDTL_CR_INT_AMOUNT
                           - T.IBRNICDTL_CR_INT_AMOUNT
                              DIFF_CR_INT_AMOUNT,
                             NEW_IBRNICDTL_DR_INT_AMOUNT
                           - IBRNICDTL_DB_INT_AMOUNT
                              DIFF_DR_INT_AMOUNT
                      FROM (SELECT IBRNICDTL_ENTITY_NUM,
                                   IBRNICDTL_RUN_NUMBER,
                                   IBRNICDTL_BRN_CODE,
                                   IBRNICDTL_GLACC_CODE,
                                   IBRNICDTL_CURR_CODE,
                                   IBRNICDTL_PROC_DATE,
                                   IBRNICDTL_FROM_DATE,
                                   IBRNICDTL_UPTO_DATE,
                                   IBRNICDTL_BALANCE,
                                   IBRNICDTL_CR_INT_RATE,
                                   CASE
                                      WHEN IBRNICDTL_CR_INT_RATE = 5 THEN 5.5
                                      ELSE 0
                                   END
                                      NEW_IBRNICDTL_CR_INT_RATE,
                                   IBRNICDTL_DB_INT_RATE,
                                   CASE
                                      WHEN IBRNICDTL_DB_INT_RATE = 5 THEN 5.5
                                      ELSE 0
                                   END
                                      NEW_IBRNICDTL_DR_INT_RATE,
                                   IBRNICDTL_NUM_OF_DAYS,
                                   IBRNICDTL_DB_PRODUCT,
                                   IBRNICDTL_CR_PRODUCT,
                                   IBRNICDTL_CR_INT_AMOUNT,
                                   CASE
                                      WHEN IBRNICDTL_CR_INT_RATE = 5
                                      THEN
                                         ROUND (
                                            (IBRNICDTL_CR_PRODUCT * 5.5 / 36000),
                                            0)
                                      ELSE
                                         0
                                   END
                                      NEW_IBRNICDTL_CR_INT_AMOUNT,
                                   IBRNICDTL_DB_INT_AMOUNT,
                                   CASE
                                      WHEN IBRNICDTL_DB_INT_RATE = 5
                                      THEN
                                         ROUND (
                                            (IBRNICDTL_DB_PRODUCT * 5.5 / 36000),
                                            0)
                                      ELSE
                                         0
                                   END
                                      NEW_IBRNICDTL_DR_INT_AMOUNT
                              FROM IBRNINTCALCDTL
                             WHERE IBRNICDTL_PROC_DATE >
                                      TO_DATE ('03/31/2017 00:00:00',
                                               'MM/DD/YYYY HH24:MI:SS')) T) TT
          GROUP BY TT.IBRNICDTL_RUN_NUMBER,
                   TT.IBRNICDTL_BRN_CODE,
                   TT.IBRNICDTL_GLACC_CODE,
                   TT.IBRNICDTL_CURR_CODE,
                   TT.IBRNICDTL_PROC_DATE)
   LOOP
      UPDATE IBRNINTCALC
         SET IBRNINTCALC_CR_BAL_INT = IDX.SUM_CR_INT_AMT,
             IBRNINTCALC_DB_BAL_INT = IDX.SUM_DR_INT_AMT
       WHERE     IBRNINTCALC_RUN_NUMBER = IDX.IBRNICDTL_RUN_NUMBER
             AND IBRNINTCALC_BRN_CODE = IDX.IBRNICDTL_BRN_CODE
             AND IBRNINTCALC_GLACC_CODE = IDX.IBRNICDTL_GLACC_CODE
             AND IBRNINTCALC_CURR_CODE = IDX.IBRNICDTL_CURR_CODE
             AND IBRNINTCALC_PROC_DATE = IDX.IBRNICDTL_PROC_DATE;
             
             V_COUNT:=V_COUNT+SQL%ROWCOUNT;
   END LOOP;
   dbms_output.put_line (V_COUNT);
END;




DECLARE
V_COUNT NUMBER :=0;

BEGIN
   FOR IDX
      IN (SELECT T.*,
                 T.NEW_IBRNICDTL_CR_INT_AMOUNT - T.IBRNICDTL_CR_INT_AMOUNT
                    DIFF_CR_INT_AMOUNT,
                 NEW_IBRNICDTL_DR_INT_AMOUNT - IBRNICDTL_DB_INT_AMOUNT
                    DIFF_DR_INT_AMOUNT
            FROM (SELECT IBRNICDTL_ENTITY_NUM,
                         IBRNICDTL_RUN_NUMBER,
                         IBRNICDTL_BRN_CODE,
                         IBRNICDTL_GLACC_CODE,
                         IBRNICDTL_CURR_CODE,
                         IBRNICDTL_DTL_SL_NUM,
                         IBRNICDTL_PROC_DATE,
                         IBRNICDTL_FROM_DATE,
                         IBRNICDTL_UPTO_DATE,
                         IBRNICDTL_BALANCE,
                         IBRNICDTL_CR_INT_RATE,
                         CASE
                            WHEN IBRNICDTL_CR_INT_RATE = 5 THEN 5.5
                            ELSE 0
                         END
                            NEW_IBRNICDTL_CR_INT_RATE,
                         IBRNICDTL_DB_INT_RATE,
                         CASE
                            WHEN IBRNICDTL_DB_INT_RATE = 5 THEN 5.5
                            ELSE 0
                         END
                            NEW_IBRNICDTL_DR_INT_RATE,
                         IBRNICDTL_NUM_OF_DAYS,
                         IBRNICDTL_DB_PRODUCT,
                         IBRNICDTL_CR_PRODUCT,
                         IBRNICDTL_CR_INT_AMOUNT,
                         CASE
                            WHEN IBRNICDTL_CR_INT_RATE = 5
                            THEN
                               ROUND ( (IBRNICDTL_CR_PRODUCT * 5.5 / 36000),
                                      0)
                            ELSE
                               0
                         END
                            NEW_IBRNICDTL_CR_INT_AMOUNT,
                         IBRNICDTL_DB_INT_AMOUNT,
                         CASE
                            WHEN IBRNICDTL_DB_INT_RATE = 5
                            THEN
                               ROUND ( (IBRNICDTL_DB_PRODUCT * 5.5 / 36000),
                                      0)
                            ELSE
                               0
                         END
                            NEW_IBRNICDTL_DR_INT_AMOUNT
                    FROM IBRNINTCALCDTL
                   WHERE IBRNICDTL_PROC_DATE >
                            TO_DATE ('03/31/2017 00:00:00',
                                     'MM/DD/YYYY HH24:MI:SS')) T)
   LOOP
      UPDATE IBRNINTCALCDTL
         SET IBRNICDTL_CR_INT_RATE = IDX.NEW_IBRNICDTL_CR_INT_RATE,
             IBRNICDTL_DB_INT_RATE = IDX.NEW_IBRNICDTL_DR_INT_RATE,
             IBRNICDTL_CR_INT_AMOUNT = IDX.NEW_IBRNICDTL_CR_INT_AMOUNT,
             IBRNICDTL_DB_INT_AMOUNT = IDX.NEW_IBRNICDTL_DR_INT_AMOUNT
       WHERE     IBRNICDTL_ENTITY_NUM = IDX.IBRNICDTL_ENTITY_NUM
             AND IBRNICDTL_RUN_NUMBER = IDX.IBRNICDTL_RUN_NUMBER
             AND IBRNICDTL_BRN_CODE = IDX.IBRNICDTL_BRN_CODE
             AND IBRNICDTL_GLACC_CODE = IDX.IBRNICDTL_GLACC_CODE
             AND IBRNICDTL_CURR_CODE = IDX.IBRNICDTL_CURR_CODE
             AND IBRNICDTL_PROC_DATE = IDX.IBRNICDTL_PROC_DATE
             AND IBRNICDTL_DTL_SL_NUM = IDX.IBRNICDTL_DTL_SL_NUM;
             
             V_COUNT:=V_COUNT+SQL%ROWCOUNT;
   END LOOP;
   
    dbms_output.put_line (V_COUNT);
END;






INSERT INTO AUTOPOST_TRAN_TEMP
SELECT NULL, NULL,  TT.IBRNICDTL_PROC_DATE,
         TT.IBRNICDTL_PROC_DATE,
         1,
         TT.IBRNICDTL_BRN_CODE,
         NULL,
         'D',
         '400104101',
         NULL,
         NULL,
         TT.IBRNICDTL_CURR_CODE,
         SUM (DIFF_CR_INT_AMOUNT)-  SUM (DIFF_DR_INT_AMOUNT) DIFF   
    FROM (SELECT T.*,
                 T.NEW_IBRNICDTL_CR_INT_AMOUNT - T.IBRNICDTL_CR_INT_AMOUNT
                    DIFF_CR_INT_AMOUNT,
                 NEW_IBRNICDTL_DR_INT_AMOUNT - IBRNICDTL_DB_INT_AMOUNT
                    DIFF_DR_INT_AMOUNT
            FROM (SELECT IBRNICDTL_ENTITY_NUM,
                         IBRNICDTL_RUN_NUMBER,
                         IBRNICDTL_BRN_CODE,
                         IBRNICDTL_GLACC_CODE,
                         IBRNICDTL_CURR_CODE,
                         IBRNICDTL_PROC_DATE,
                         IBRNICDTL_FROM_DATE,
                         IBRNICDTL_UPTO_DATE,
                         IBRNICDTL_BALANCE,
                         IBRNICDTL_CR_INT_RATE,
                         CASE
                            WHEN IBRNICDTL_CR_INT_RATE = 5 THEN 5.5
                            ELSE 0
                         END
                            NEW_IBRNICDTL_CR_INT_RATE,
                         IBRNICDTL_DB_INT_RATE,
                         CASE
                            WHEN IBRNICDTL_DB_INT_RATE = 5 THEN 5.5
                            ELSE 0
                         END
                            NEW_IBRNICDTL_DR_INT_RATE,
                         IBRNICDTL_NUM_OF_DAYS,
                         IBRNICDTL_DB_PRODUCT,
                         IBRNICDTL_CR_PRODUCT,
                         IBRNICDTL_CR_INT_AMOUNT,
                         CASE
                            WHEN IBRNICDTL_CR_INT_RATE = 5
                            THEN
                               ROUND ( (IBRNICDTL_CR_PRODUCT * 5.5 / 36000), 0)
                            ELSE
                               0
                         END
                            NEW_IBRNICDTL_CR_INT_AMOUNT,
                         IBRNICDTL_DB_INT_AMOUNT,
                         CASE
                            WHEN IBRNICDTL_DB_INT_RATE = 5
                            THEN
                               ROUND ( (IBRNICDTL_DB_PRODUCT * 5.5 / 36000), 0)
                            ELSE
                               0
                         END
                            NEW_IBRNICDTL_DR_INT_AMOUNT
                    FROM IBRNINTCALCDTL
                   WHERE IBRNICDTL_PROC_DATE >
                            TO_DATE ('03/31/2017 00:00:00',
                                     'MM/DD/YYYY HH24:MI:SS')) T) TT                                   
GROUP BY TT.IBRNICDTL_RUN_NUMBER,
         TT.IBRNICDTL_BRN_CODE,
         TT.IBRNICDTL_GLACC_CODE,
         TT.IBRNICDTL_CURR_CODE,
         TT.IBRNICDTL_PROC_DATE 
         HAVING SUM (DIFF_CR_INT_AMOUNT)-  SUM (DIFF_DR_INT_AMOUNT) > 0;
         
         
INSERT INTO AUTOPOST_TRAN_TEMP
SELECT NULL, NULL,  TT.IBRNICDTL_PROC_DATE,
         TT.IBRNICDTL_PROC_DATE,
         1,
         TT.IBRNICDTL_BRN_CODE,
         NULL,
         'C',
         '137101165',
         NULL,
         NULL,
         TT.IBRNICDTL_CURR_CODE,
         SUM (DIFF_CR_INT_AMOUNT)-  SUM (DIFF_DR_INT_AMOUNT) DIFF   
    FROM (SELECT T.*,
                 T.NEW_IBRNICDTL_CR_INT_AMOUNT - T.IBRNICDTL_CR_INT_AMOUNT
                    DIFF_CR_INT_AMOUNT,
                 NEW_IBRNICDTL_DR_INT_AMOUNT - IBRNICDTL_DB_INT_AMOUNT
                    DIFF_DR_INT_AMOUNT
            FROM (SELECT IBRNICDTL_ENTITY_NUM,
                         IBRNICDTL_RUN_NUMBER,
                         IBRNICDTL_BRN_CODE,
                         IBRNICDTL_GLACC_CODE,
                         IBRNICDTL_CURR_CODE,
                         IBRNICDTL_PROC_DATE,
                         IBRNICDTL_FROM_DATE,
                         IBRNICDTL_UPTO_DATE,
                         IBRNICDTL_BALANCE,
                         IBRNICDTL_CR_INT_RATE,
                         CASE
                            WHEN IBRNICDTL_CR_INT_RATE = 5 THEN 5.5
                            ELSE 0
                         END
                            NEW_IBRNICDTL_CR_INT_RATE,
                         IBRNICDTL_DB_INT_RATE,
                         CASE
                            WHEN IBRNICDTL_DB_INT_RATE = 5 THEN 5.5
                            ELSE 0
                         END
                            NEW_IBRNICDTL_DR_INT_RATE,
                         IBRNICDTL_NUM_OF_DAYS,
                         IBRNICDTL_DB_PRODUCT,
                         IBRNICDTL_CR_PRODUCT,
                         IBRNICDTL_CR_INT_AMOUNT,
                         CASE
                            WHEN IBRNICDTL_CR_INT_RATE = 5
                            THEN
                               ROUND ( (IBRNICDTL_CR_PRODUCT * 5.5 / 36000), 0)
                            ELSE
                               0
                         END
                            NEW_IBRNICDTL_CR_INT_AMOUNT,
                         IBRNICDTL_DB_INT_AMOUNT,
                         CASE
                            WHEN IBRNICDTL_DB_INT_RATE = 5
                            THEN
                               ROUND ( (IBRNICDTL_DB_PRODUCT * 5.5 / 36000), 0)
                            ELSE
                               0
                         END
                            NEW_IBRNICDTL_DR_INT_AMOUNT
                    FROM IBRNINTCALCDTL
                   WHERE IBRNICDTL_PROC_DATE >
                            TO_DATE ('03/31/2017 00:00:00',
                                     'MM/DD/YYYY HH24:MI:SS')) T) TT                                   
GROUP BY TT.IBRNICDTL_RUN_NUMBER,
         TT.IBRNICDTL_BRN_CODE,
         TT.IBRNICDTL_GLACC_CODE,
         TT.IBRNICDTL_CURR_CODE,
         TT.IBRNICDTL_PROC_DATE 
         HAVING SUM (DIFF_CR_INT_AMOUNT)-  SUM (DIFF_DR_INT_AMOUNT) > 0;         
         
         
         
         
INSERT INTO AUTOPOST_TRAN_TEMP
SELECT NULL, NULL, TT.IBRNICDTL_PROC_DATE,
         TT.IBRNICDTL_PROC_DATE,
         1,
         TT.IBRNICDTL_BRN_CODE,
         NULL,
         'D',
         '225122231',
         NULL,
         NULL,
         TT.IBRNICDTL_CURR_CODE,
         SUM (DIFF_CR_INT_AMOUNT)-  SUM (DIFF_DR_INT_AMOUNT) DIFF   
    FROM (SELECT T.*,
                 T.NEW_IBRNICDTL_CR_INT_AMOUNT - T.IBRNICDTL_CR_INT_AMOUNT
                    DIFF_CR_INT_AMOUNT,
                 NEW_IBRNICDTL_DR_INT_AMOUNT - IBRNICDTL_DB_INT_AMOUNT
                    DIFF_DR_INT_AMOUNT
            FROM (SELECT IBRNICDTL_ENTITY_NUM,
                         IBRNICDTL_RUN_NUMBER,
                         IBRNICDTL_BRN_CODE,
                         IBRNICDTL_GLACC_CODE,
                         IBRNICDTL_CURR_CODE,
                         IBRNICDTL_PROC_DATE,
                         IBRNICDTL_FROM_DATE,
                         IBRNICDTL_UPTO_DATE,
                         IBRNICDTL_BALANCE,
                         IBRNICDTL_CR_INT_RATE,
                         CASE
                            WHEN IBRNICDTL_CR_INT_RATE = 5 THEN 5.5
                            ELSE 0
                         END
                            NEW_IBRNICDTL_CR_INT_RATE,
                         IBRNICDTL_DB_INT_RATE,
                         CASE
                            WHEN IBRNICDTL_DB_INT_RATE = 5 THEN 5.5
                            ELSE 0
                         END
                            NEW_IBRNICDTL_DR_INT_RATE,
                         IBRNICDTL_NUM_OF_DAYS,
                         IBRNICDTL_DB_PRODUCT,
                         IBRNICDTL_CR_PRODUCT,
                         IBRNICDTL_CR_INT_AMOUNT,
                         CASE
                            WHEN IBRNICDTL_CR_INT_RATE = 5
                            THEN
                               ROUND ( (IBRNICDTL_CR_PRODUCT * 5.5 / 36000), 0)
                            ELSE
                               0
                         END
                            NEW_IBRNICDTL_CR_INT_AMOUNT,
                         IBRNICDTL_DB_INT_AMOUNT,
                         CASE
                            WHEN IBRNICDTL_DB_INT_RATE = 5
                            THEN
                               ROUND ( (IBRNICDTL_DB_PRODUCT * 5.5 / 36000), 0)
                            ELSE
                               0
                         END
                            NEW_IBRNICDTL_DR_INT_AMOUNT
                    FROM IBRNINTCALCDTL
                   WHERE IBRNICDTL_PROC_DATE >
                            TO_DATE ('03/31/2017 00:00:00',
                                     'MM/DD/YYYY HH24:MI:SS')) T) TT                                   
GROUP BY TT.IBRNICDTL_RUN_NUMBER,
         TT.IBRNICDTL_BRN_CODE,
         TT.IBRNICDTL_GLACC_CODE,
         TT.IBRNICDTL_CURR_CODE,
         TT.IBRNICDTL_PROC_DATE 
         HAVING SUM (DIFF_CR_INT_AMOUNT)-  SUM (DIFF_DR_INT_AMOUNT) < 0;         
         
         
INSERT INTO AUTOPOST_TRAN_TEMP
SELECT NULL, NULL,  TT.IBRNICDTL_PROC_DATE,
         TT.IBRNICDTL_PROC_DATE,
         1,
         TT.IBRNICDTL_BRN_CODE,
         NULL,
         'C',
         '300116101',
         NULL,
         NULL,
         TT.IBRNICDTL_CURR_CODE,
         SUM (DIFF_CR_INT_AMOUNT)-  SUM (DIFF_DR_INT_AMOUNT) DIFF   
    FROM (SELECT T.*,
                 T.NEW_IBRNICDTL_CR_INT_AMOUNT - T.IBRNICDTL_CR_INT_AMOUNT
                    DIFF_CR_INT_AMOUNT,
                 NEW_IBRNICDTL_DR_INT_AMOUNT - IBRNICDTL_DB_INT_AMOUNT
                    DIFF_DR_INT_AMOUNT
            FROM (SELECT IBRNICDTL_ENTITY_NUM,
                         IBRNICDTL_RUN_NUMBER,
                         IBRNICDTL_BRN_CODE,
                         IBRNICDTL_GLACC_CODE,
                         IBRNICDTL_CURR_CODE,
                         IBRNICDTL_PROC_DATE,
                         IBRNICDTL_FROM_DATE,
                         IBRNICDTL_UPTO_DATE,
                         IBRNICDTL_BALANCE,
                         IBRNICDTL_CR_INT_RATE,
                         CASE
                            WHEN IBRNICDTL_CR_INT_RATE = 5 THEN 5.5
                            ELSE 0
                         END
                            NEW_IBRNICDTL_CR_INT_RATE,
                         IBRNICDTL_DB_INT_RATE,
                         CASE
                            WHEN IBRNICDTL_DB_INT_RATE = 5 THEN 5.5
                            ELSE 0
                         END
                            NEW_IBRNICDTL_DR_INT_RATE,
                         IBRNICDTL_NUM_OF_DAYS,
                         IBRNICDTL_DB_PRODUCT,
                         IBRNICDTL_CR_PRODUCT,
                         IBRNICDTL_CR_INT_AMOUNT,
                         CASE
                            WHEN IBRNICDTL_CR_INT_RATE = 5
                            THEN
                               ROUND ( (IBRNICDTL_CR_PRODUCT * 5.5 / 36000), 0)
                            ELSE
                               0
                         END
                            NEW_IBRNICDTL_CR_INT_AMOUNT,
                         IBRNICDTL_DB_INT_AMOUNT,
                         CASE
                            WHEN IBRNICDTL_DB_INT_RATE = 5
                            THEN
                               ROUND ( (IBRNICDTL_DB_PRODUCT * 5.5 / 36000), 0)
                            ELSE
                               0
                         END
                            NEW_IBRNICDTL_DR_INT_AMOUNT
                    FROM IBRNINTCALCDTL
                   WHERE IBRNICDTL_PROC_DATE >
                            TO_DATE ('03/31/2017 00:00:00',
                                     'MM/DD/YYYY HH24:MI:SS')) T) TT                                   
GROUP BY TT.IBRNICDTL_RUN_NUMBER,
         TT.IBRNICDTL_BRN_CODE,
         TT.IBRNICDTL_GLACC_CODE,
         TT.IBRNICDTL_CURR_CODE,
         TT.IBRNICDTL_PROC_DATE 
         HAVING SUM (DIFF_CR_INT_AMOUNT)-  SUM (DIFF_DR_INT_AMOUNT) < 0;         
		 
		 
		 
		 
		 
BEGIN
FOR IDX IN (
SELECT  
ROW_NUMBER( )  OVER (PARTITION BY
BRN_CODE ORDER BY BRN_CODE) LEG_NO, T.*  FROM AUTOPOST_TRAN_TEMP T)

LOOP
UPDATE AUTOPOST_TRAN_TEMP SET LEG_SL=IDX.LEG_NO
WHERE TRAN_DATE= IDX.TRAN_DATE
AND VALUE_DATE=IDX.VALUE_DATE
AND BRN_CODE=IDX.BRN_CODE
AND DR_CR=IDX.DR_CR;
END LOOP;
END;


begin
for idx in (
select rownum r_num, t.* from (
select distinct TRAN_DATE, BRN_CODE  from AUTOPOST_TRAN_TEMP
order by BRN_CODE ) t) loop
update AUTOPOST_TRAN_TEMP set BATCH_SL = idx.r_num
where TRAN_DATE = idx.TRAN_DATE
and BRN_CODE = idx.BRN_CODE;
end loop;
end ;