---------- Temporary GL Transfer from Parking GL ----------------


INSERT INTO AUTOPOST_TRAN
SELECT 1 BATCH_SL,
       ROWNUM LEG_SL,
       '31-DEC-2019' TRAN_DATE,
       '31-DEC-2019' VALUE_DATE,
       '1' SUPP_TRAN,
       18 BRN_CODE,
       18 ACING_BRN_CODE,
       DECODE(SIGN(PLTRF_GL_BAL) , -1 , 'D', 'C') DR_CR,
       PLTRF_GLACC_CODE GLACC_CODE,
       0 INT_AC_NO,
       NULL CONT_NO,
       PLTRF_CURR_CODE CURR_CODE,
       ABS(PLTRF_GL_BAL ) AC_AMOUNT,
       ABS(PLTRF_GL_BC_BAL) BC_AMOUNT,
       NULL PRINCIPAL,
       NULL INTEREST,
       NULL CHARGE,
       NULL INST_PREFIX,
       NULL INST_NUM,
       NULL INST_DATE,
       NULL IBR_GL,
       NULL ORIG_RESP,
       NULL CONT_BRN_CODE,
       NULL ADV_NUM,
       NULL ADV_DATE,
       NULL IBR_CODE,
       NULL CAN_IBR_CODE,
       'Temporary GL Transfer' LEG_NARRATION,
       'Temporary GL Transfer' BATCH_NARRATION,
       'INTELECT' USER_ID,
       NULL TERMINAL_ID,
       NULL PROCESSED,
       NULL BATCH_NO,
       NULL ERR_MSG,
       NULL DEPT_CODE
  FROM PLTRF
 WHERE     PLTRF_ENTITY_NUM = 1
       AND PLTRF_TRF_DATE = '31-DEC-2019'
       AND PLTRF_BRN_CODE = 18
       AND PLTRF_GLACC_CODE IN (  SELECT GLACC_CODE --, DEPT_CODE , SUM(CLOSING_BAL_BC)
                                    FROM GLDIVBAL
                                   WHERE     ENTITY_NUM = 1
                                         AND BRN_CODE = 18
                                         AND CLOSING_DATE <= '31-DEC-2019'
                                GROUP BY GLACC_CODE, DEPT_CODE); 
								
-------------- Add a record for parking GL balance. 


---------	Division wise balance transfer -----

					
INSERT INTO AUTOPOST_TRAN
select 1 BATCH_SL,
       ROWNUM LEG_SL, 
       tt.* from (
SELECT --1 BATCH_SL,
       --ROWNUM LEG_SL,
       '31-DEC-2019' TRAN_DATE,
       '31-DEC-2019' VALUE_DATE,
       '1' SUPP_TRAN,
       18 BRN_CODE,
       18 ACING_BRN_CODE,
       DECODE(SIGN(SUM (CLOSING_BAL_BC)) , -1 , 'C', 'D') DR_CR,
       GLACC_CODE GLACC_CODE,
       0 INT_AC_NO,
       NULL CONT_NO,
       'BDT' CURR_CODE,
       ABS(SUM (CLOSING_BAL_BC) ) AC_AMOUNT,
       ABS(SUM (CLOSING_BAL_BC)) BC_AMOUNT,
       NULL PRINCIPAL,
       NULL INTEREST,
       NULL CHARGE,
       NULL INST_PREFIX,
       NULL INST_NUM,
       NULL INST_DATE,
       NULL IBR_GL,
       NULL ORIG_RESP,
       NULL CONT_BRN_CODE,
       NULL ADV_NUM,
       NULL ADV_DATE,
       NULL IBR_CODE,
       NULL CAN_IBR_CODE,
       'HO PnL Transfer' LEG_NARRATION,
       'HO PnL Transfer' BATCH_NARRATION,
       'INTELECT' USER_ID,
       NULL TERMINAL_ID,
       NULL PROCESSED,
       NULL BATCH_NO,
       NULL ERR_MSG,
       DEPT_CODE DEPT_CODE
  FROM GLDIVBAL
   WHERE     ENTITY_NUM = 1
         AND BRN_CODE = 18
         AND CLOSING_DATE <= '31-DEC-2019'
         AND GLACC_CODE IN (SELECT PLTRF_GLACC_CODE
                              FROM PLTRF
                             WHERE     PLTRF_ENTITY_NUM = 1
                                   AND PLTRF_TRF_DATE = '31-DEC-2019'
                                   AND PLTRF_BRN_CODE = 18)
GROUP BY GLACC_CODE, DEPT_CODE
HAVING SUM (CLOSING_BAL_BC) <> 0
ORDER BY GLACC_CODE, DEPT_CODE ) tt  ;




-------------- P/L transfer without division -----------

INSERT INTO AUTOPOST_TRAN
select 1 BATCH_SL,
       ROWNUM + 526 LEG_SL, 
       tt.* from (
SELECT --1 BATCH_SL,
       --ROWNUM LEG_SL,
       '31-DEC-2019' TRAN_DATE,
       '31-DEC-2019' VALUE_DATE,
       '1' SUPP_TRAN,
       18 BRN_CODE,
       18 ACING_BRN_CODE,
       DECODE(SIGN((A.PLTRF_GL_BC_BAL - B.CLOSING_BAL_BC)) , -1 , 'C', 'D') DR_CR,
       A.PLTRF_GLACC_CODE GLACC_CODE,
       0 INT_AC_NO,
       NULL CONT_NO,
       'BDT' CURR_CODE,
       ABS(A.PLTRF_GL_BC_BAL - B.CLOSING_BAL_BC) AC_AMOUNT,
       ABS(A.PLTRF_GL_BC_BAL - B.CLOSING_BAL_BC) BC_AMOUNT,
       NULL PRINCIPAL,
       NULL INTEREST,
       NULL CHARGE,
       NULL INST_PREFIX,
       NULL INST_NUM,
       NULL INST_DATE,
       NULL IBR_GL,
       NULL ORIG_RESP,
       NULL CONT_BRN_CODE,
       NULL ADV_NUM,
       NULL ADV_DATE,
       NULL IBR_CODE,
       NULL CAN_IBR_CODE,
       'HO PnL Transfer' LEG_NARRATION,
       'HO PnL Transfer' BATCH_NARRATION,
       'INTELECT' USER_ID,
       NULL TERMINAL_ID,
       NULL PROCESSED,
       NULL BATCH_NO,
       NULL ERR_MSG,
       NULL DEPT_CODE
  FROM (SELECT PLTRF_GLACC_CODE, PLTRF_GL_BC_BAL
          FROM PLTRF
         WHERE     PLTRF_ENTITY_NUM = 1
               AND PLTRF_TRF_DATE = '31-DEC-2019'
               AND PLTRF_BRN_CODE = 18) A,
       (  SELECT GLACC_CODE, SUM (CLOSING_BAL_BC) CLOSING_BAL_BC
            FROM GLDIVBAL
           WHERE     ENTITY_NUM = 1
                 AND BRN_CODE = 18
                 AND CLOSING_DATE <= '31-DEC-2019'
                 AND GLACC_CODE IN (SELECT PLTRF_GLACC_CODE
                                      FROM PLTRF
                                     WHERE     PLTRF_ENTITY_NUM = 1
                                           AND PLTRF_TRF_DATE = '31-DEC-2019'
                                           AND PLTRF_BRN_CODE = 18)
        GROUP BY GLACC_CODE
          HAVING SUM (CLOSING_BAL_BC) <> 0
        ORDER BY GLACC_CODE) B
 WHERE     A.PLTRF_GLACC_CODE = B.GLACC_CODE
       AND A.PLTRF_GL_BC_BAL - B.CLOSING_BAL_BC <> 0) tt ;


 -------------- Add a record for parking GL balance. ----------------
 
 
 
 
 -------------- Update GLDIVBAL table ---------------- 
 
 
 MERGE INTO GLDIVBAL G1
     USING (  SELECT TRAN_ENTITY_NUM,
                     TRAN_ACING_BRN_CODE,
                     TRAN_GLACC_CODE,
                     TRAN_CURR_CODE,
                     TRAN_DEPT_CODE,
                     TRAN_DATE_OF_TRAN,
                       NVL (SUM (DECODE (TRAN_DB_CR_FLG, 'C', TRAN_AMOUNT)), 0)
                     - NVL (SUM (DECODE (TRAN_DB_CR_FLG, 'D', TRAN_AMOUNT)), 0)
                        TRAN_AMOUNT,
                       NVL (
                          SUM (
                             DECODE (TRAN_DB_CR_FLG,
                                     'C', TRAN_BASE_CURR_EQ_AMT)),
                          0)
                     - NVL (
                          SUM (
                             DECODE (TRAN_DB_CR_FLG,
                                     'D', TRAN_BASE_CURR_EQ_AMT)),
                          0)
                        TRAN_BC_AMOUNT
                FROM TRAN2019
               WHERE     TRAN_ENTITY_NUM = 1
                     AND (TRAN_AMOUNT > 0 OR TRAN_BASE_CURR_EQ_AMT > 0)
                     AND TRAN_AUTH_ON IS NOT NULL
                     AND TRAN_DEPT_CODE IS NOT NULL
                     AND TRAN_DATE_OF_TRAN = '31-DEC-2019'
            GROUP BY TRAN_ENTITY_NUM,
                     TRAN_ACING_BRN_CODE,
                     TRAN_GLACC_CODE,
                     TRAN_CURR_CODE,
                     TRAN_DEPT_CODE,
                     TRAN_DATE_OF_TRAN) G2
        ON (    G1.ENTITY_NUM = G2.TRAN_ENTITY_NUM
            AND G1.BRN_CODE = G2.TRAN_ACING_BRN_CODE
            AND G1.GLACC_CODE = G2.TRAN_GLACC_CODE
            AND G1.CURR_CODE = G2.TRAN_CURR_CODE
            AND G1.DEPT_CODE = G2.TRAN_DEPT_CODE
            AND G1.CLOSING_DATE = G2.TRAN_DATE_OF_TRAN)
WHEN MATCHED
THEN
   UPDATE SET
      G1.CLOSING_BAL = G2.TRAN_AMOUNT, G1.CLOSING_BAL_BC = G2.TRAN_BC_AMOUNT
WHEN NOT MATCHED
THEN
   INSERT     (ENTITY_NUM,
               BRN_CODE,
               GLACC_CODE,
               CURR_CODE,
               DEPT_CODE,
               CLOSING_DATE,
               CLOSING_BAL,
               CLOSING_BAL_BC)
       VALUES (G2.TRAN_ENTITY_NUM,
               G2.TRAN_ACING_BRN_CODE,
               G2.TRAN_GLACC_CODE,
               G2.TRAN_CURR_CODE,
               G2.TRAN_DEPT_CODE,
               G2.TRAN_DATE_OF_TRAN,
               G2.TRAN_AMOUNT,
               G2.TRAN_BC_AMOUNT)