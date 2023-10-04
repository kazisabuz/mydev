/* Formatted on 8/1/2023 3:27:59 PM (QP5 v5.388) */
SELECT 1 BATCH_SL, ROWNUM LEG_SL, T.*
  FROM (  SELECT                                                 --1 BATCH_SL,
                 --ROWNUM LEG_SL,
                 '31-DEC-2022'
                     TRAN_DATE,
                 '31-DEC-2022'
                     VALUE_DATE,
                 '1'
                     SUPP_TRAN,
                 BRN_CODE,
                 BRN_CODE
                     ACING_BRN_CODE,
                 CASE WHEN SUM (CLOSING_BAL) > 0 THEN 'D' ELSE 'C' END
                     DR_CR,
                 GLACC_CODE
                     GLACC_CODE,
                 NULL
                     INT_AC_NO,
                 NULL
                     CONT_NO,
                 CURR_CODE,
                 ABS (SUM (CLOSING_BAL))
                     AC_AMOUNT,
                 ABS (SUM (CLOSING_BAL_BC))
                     BC_AMOUNT,
                 NULL
                     PRINCIPAL,
                 NULL
                     INTEREST,
                 NULL
                     CHARGE,
                 NULL
                     INST_PREFIX,
                 NULL
                     INST_NUM,
                 NULL
                     INST_DATE,
                 NULL
                     IBR_GL,
                 NULL
                     ORIG_RESP,
                 NULL
                     CONT_BRN_CODE,
                 NULL
                     ADV_NUM,
                 NULL
                     ADV_DATE,
                 NULL
                     IBR_CODE,
                 NULL
                     CAN_IBR_CODE,
                 'P/L transfer'
                     LEG_NARRATION,
                 'P/L transfer'
                     BATCH_NARRATION,
                 'INTELECT'
                     USER_ID,
                 NULL
                     TERMINAL_ID,
                 NULL
                     PROCESSED,
                 NULL
                     BATCH_NO,
                 NULL
                     ERR_MSG,
                 DEPT_CODE
            FROM GLDIVBAL
           WHERE     ENTITY_NUM = 1
                 AND BRN_CODE = 18
                 AND CLOSING_DATE <= '31-DEC-2022'       ---last year end date
                 AND SUBSTR (GLACC_CODE, 1, 3) IN ('300', '400')
        GROUP BY ENTITY_NUM,
                 BRN_CODE,
                 GLACC_CODE,
                 DEPT_CODE,
                 CURR_CODE
          HAVING SUM (CLOSING_BAL) * -1 <> 0
        UNION ALL
          SELECT                                                 --1 BATCH_SL,
                                                              --ROWNUM LEG_SL,
                 '31-DEC-2022'
                     TRAN_DATE,
                 '31-DEC-2022'
                     VALUE_DATE,
                 '1'
                     SUPP_TRAN,
                 BRN_CODE,
                 BRN_CODE
                     ACING_BRN_CODE,
                 CASE WHEN SUM (CLOSING_BAL) > 0 THEN 'C' ELSE 'D' END
                     DR_CR,
                 GLACC_CODE
                     GLACC_CODE,
                 NULL
                     INT_AC_NO,
                 NULL
                     CONT_NO,
                 CURR_CODE,
                 ABS (SUM (CLOSING_BAL))
                     AC_AMOUNT,
                 ABS (SUM (CLOSING_BAL_BC))
                     BC_AMOUNT,
                 NULL
                     PRINCIPAL,
                 NULL
                     INTEREST,
                 NULL
                     CHARGE,
                 NULL
                     INST_PREFIX,
                 NULL
                     INST_NUM,
                 NULL
                     INST_DATE,
                 NULL
                     IBR_GL,
                 NULL
                     ORIG_RESP,
                 NULL
                     CONT_BRN_CODE,
                 NULL
                     ADV_NUM,
                 NULL
                     ADV_DATE,
                 NULL
                     IBR_CODE,
                 NULL
                     CAN_IBR_CODE,
                 'P/L transfer'
                     LEG_NARRATION,
                 'P/L transfer'
                     BATCH_NARRATION,
                 'INTELECT'
                     USER_ID,
                 NULL
                     TERMINAL_ID,
                 NULL
                     PROCESSED,
                 NULL
                     BATCH_NO,
                 NULL
                     ERR_MSG,
                 NULL
                     DEPT_CODE
            FROM GLDIVBAL
           WHERE     ENTITY_NUM = 1
                 AND BRN_CODE = 18
                 AND CLOSING_DATE <= '31-DEC-2022'
                 AND SUBSTR (GLACC_CODE, 1, 3) IN ('300', '400')
        GROUP BY ENTITY_NUM,
                 BRN_CODE,
                 GLACC_CODE,
                 --DEPT_CODE,
                 CURR_CODE
          HAVING SUM (CLOSING_BAL) * -1 <> 0
        ORDER BY GLACC_CODE, DEPT_CODE) T;