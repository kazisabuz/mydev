/* Formatted on 2/22/2022 6:44:19 PM (QP5 v5.252.13127.32867) */
DELETE FROM AUTOPOST_TRAN;

INSERT INTO AUTOPOST_TRAN
   SELECT 1 BATCH_SL, ROWNUM LEG_SL, T.*
     FROM (  SELECT                                              --1 BATCH_SL,
                                                              --ROWNUM LEG_SL,
                    '31-DEC-2021' TRAN_DATE,
                    '31-DEC-2021' VALUE_DATE,
                    '1' SUPP_TRAN,
                    BRN_CODE,
                    BRN_CODE ACING_BRN_CODE,
                    CASE WHEN SUM (CLOSING_BAL) > 0 THEN 'D' ELSE 'C' END DR_CR,
                    GLACC_CODE GLACC_CODE,
                    NULL INT_AC_NO,
                    NULL CONT_NO,
                    CURR_CODE,
                    ABS (SUM (CLOSING_BAL)) AC_AMOUNT,
                    ABS (SUM (CLOSING_BAL)) BC_AMOUNT,
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
                    'P/L transfer' LEG_NARRATION,
                    'P/L transfer' BATCH_NARRATION,
                    'INTELECT' USER_ID,
                    NULL TERMINAL_ID,
                    NULL PROCESSED,
                    NULL BATCH_NO,
                    NULL ERR_MSG,
                    DEPT_CODE
               FROM GLDIVBAL
              WHERE     ENTITY_NUM = 1
                    AND BRN_CODE = 18
                    AND CLOSING_DATE <= '31-DEC-2021'
                    AND SUBSTR (GLACC_CODE, 1, 3) IN ('300', '400')
           GROUP BY ENTITY_NUM,
                    BRN_CODE,
                    GLACC_CODE,
                    DEPT_CODE,
                    CURR_CODE
             HAVING SUM (CLOSING_BAL) * -1 <> 0
           UNION ALL
             SELECT --1 BATCH_SL,
                    --ROWNUM LEG_SL,
                    '31-DEC-2021' TRAN_DATE,
                    '31-DEC-2021' VALUE_DATE,
                    '1' SUPP_TRAN,
                    BRN_CODE,
                    BRN_CODE ACING_BRN_CODE,
                    CASE WHEN SUM (CLOSING_BAL) > 0 THEN 'C' ELSE 'D' END DR_CR,
                    GLACC_CODE GLACC_CODE,
                    NULL INT_AC_NO,
                    NULL CONT_NO,
                    CURR_CODE,
                    ABS (SUM (CLOSING_BAL)) AC_AMOUNT,
                    ABS (SUM (CLOSING_BAL)) BC_AMOUNT,
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
                    'P/L transfer' LEG_NARRATION,
                    'P/L transfer' BATCH_NARRATION,
                    'INTELECT' USER_ID,
                    NULL TERMINAL_ID,
                    NULL PROCESSED,
                    NULL BATCH_NO,
                    NULL ERR_MSG,
                    NULL DEPT_CODE
               FROM GLDIVBAL
              WHERE     ENTITY_NUM = 1
                    AND BRN_CODE = 18
                    AND CLOSING_DATE <= '31-DEC-2021'
                    AND SUBSTR (GLACC_CODE, 1, 3) IN ('300', '400')
           GROUP BY ENTITY_NUM,
                    BRN_CODE,
                    GLACC_CODE,
                    --DEPT_CODE,
                    CURR_CODE
             HAVING SUM (CLOSING_BAL) * -1 <> 0
           ORDER BY GLACC_CODE, DEPT_CODE) T;



MERGE INTO GLDIVBAL G1
     USING (  SELECT TRAN_ENTITY_NUM,
                     TRAN_ACING_BRN_CODE,
                     TRAN_GLACC_CODE,
                     TRAN_CURR_CODE,
                     TRAN_DEPT_CODE,
                     TRAN_DATE_OF_TRAN,
                     NVL (SUM (DECODE (TRAN_DB_CR_FLG, 'C', TRAN_AMOUNT)), 0)-NVL (SUM (DECODE (TRAN_DB_CR_FLG, 'D', TRAN_AMOUNT)), 0) TRAN_AMOUNT,
                     NVL (SUM (DECODE (TRAN_DB_CR_FLG, 'C', TRAN_BASE_CURR_EQ_AMT)), 0)-NVL (SUM (DECODE (TRAN_DB_CR_FLG, 'D', TRAN_BASE_CURR_EQ_AMT)), 0) TRAN_BC_AMOUNT
                 FROM TRAN2021  WHERE TRAN_ENTITY_NUM = 1 AND (TRAN_AMOUNT > 0 OR TRAN_BASE_CURR_EQ_AMT > 0) AND TRAN_AUTH_ON IS NOT NULL
                 AND TRAN_DEPT_CODE IS NOT NULL AND TRAN_DATE_OF_TRAN = '31-DEC-2021'
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
   UPDATE SET G1 .CLOSING_BAL = G2.TRAN_AMOUNT,
              G1.CLOSING_BAL_BC = G2.TRAN_BC_AMOUNT
WHEN NOT MATCHED
THEN
   INSERT (ENTITY_NUM, BRN_CODE, GLACC_CODE, CURR_CODE, DEPT_CODE, CLOSING_DATE, CLOSING_BAL, CLOSING_BAL_BC)
              VALUES (G2.TRAN_ENTITY_NUM,
                      G2.TRAN_ACING_BRN_CODE,
                      G2.TRAN_GLACC_CODE,
                      G2.TRAN_CURR_CODE,
                      G2.TRAN_DEPT_CODE,
                      G2.TRAN_DATE_OF_TRAN,
                      G2.TRAN_AMOUNT,
                      G2.TRAN_BC_AMOUNT)