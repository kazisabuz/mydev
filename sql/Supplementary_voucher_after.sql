/* Formatted on 24/08/2020 2:48:33 PM (QP5 v5.227.12220.39754) */
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
                FROM TRAN2022       -------------------------- TRAN table name
               WHERE     TRAN_ENTITY_NUM = 1
                     AND (TRAN_AMOUNT > 0 OR TRAN_BASE_CURR_EQ_AMT > 0)
                     AND TRAN_AUTH_ON IS NOT NULL
                     AND TRAN_DEPT_CODE IS NOT NULL
                      AND TRAN_DATE_OF_TRAN = '29-dec-2022' -------------------------- Date of supplementary voucher
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
               G2.TRAN_BC_AMOUNT);