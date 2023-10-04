/* Formatted on 10/19/2021 3:45:35 PM (QP5 v5.149.1003.31008) */
  SELECT TRAN_ACING_BRN_CODE BRN_CODE,
         MBRN_NAME,
         account_no,
         DATE_30JUN2021,
         DATE_31DEC2020,
         DATE_30JUN2020,
         TRAN_DB_CR_FLG,
         SUM (TRAN_AMOUNT),
         NARRATION,
         ACNTS_CLOSURE_DATE
    FROM (SELECT TRAN_ACING_BRN_CODE,
                 (SELECT MBRN_NAME
                    FROM MBRN
                   WHERE MBRN_CODE = TRAN_ACING_BRN_CODE)
                    MBRN_NAME,
                 facno (1, TRAN_INTERNAL_ACNUM) account_no,
                 TO_CHAR (TRAN_DATE_OF_TRAN) DATE_30JUN2021,
                 '' DATE_31DEC2020,
                 '' DATE_30JUN2020,
                 TRAN_DB_CR_FLG,
                 TRAN_AMOUNT,
                 UPPER (TRAN_NARR_DTL1 || TRAN_NARR_DTL2 || TRAN_NARR_DTL3)
                    NARRATION,
                 ACNTS_CLOSURE_DATE
            FROM tran2021, acnts
           WHERE     TRAN_INTERNAL_ACNUM <> 0
                 AND ACNTS_INTERNAL_ACNUM = TRAN_INTERNAL_ACNUM
                 AND TRAN_DATE_OF_TRAN = '30-jun-2021'
                 AND TRAN_ACING_BRN_CODE = 26
                 AND TRAN_NARR_DTL1 = 'Covid rectification'
                 AND ACNTS_ENTITY_NUM = 1
                 AND TRAN_ENTITY_NUM = 1
          UNION ALL
          SELECT TRAN_ACING_BRN_CODE,
                 (SELECT MBRN_NAME
                    FROM MBRN
                   WHERE MBRN_CODE = TRAN_ACING_BRN_CODE)
                    MBRN_NAME,
                 facno (1, TRAN_INTERNAL_ACNUM) account_no,
                 '' DATE_30JUN2021,
                 TO_CHAR (TRAN_DATE_OF_TRAN) DATE_31DEC2020,
                 '' DATE_30JUN2020,
                 TRAN_DB_CR_FLG,
                 TRAN_AMOUNT,
                 UPPER (TRAN_NARR_DTL1 || TRAN_NARR_DTL2 || TRAN_NARR_DTL3)
                    NARRATION,
                 ACNTS_CLOSURE_DATE
            FROM tran2020, acnts
           WHERE     TRAN_INTERNAL_ACNUM <> 0
                 AND ACNTS_INTERNAL_ACNUM = TRAN_INTERNAL_ACNUM
                 AND TRAN_DATE_OF_TRAN = '31-DEC-2020'
                 AND TRAN_ACING_BRN_CODE = 26
                 AND UPPER (TRAN_NARR_DTL1 || TRAN_NARR_DTL2 || TRAN_NARR_DTL3) LIKE
                        '%APRIL AND MAY%'
                 AND ACNTS_ENTITY_NUM = 1
                 AND TRAN_ENTITY_NUM = 1
          UNION ALL
          SELECT TRAN_ACING_BRN_CODE,
                 (SELECT MBRN_NAME
                    FROM MBRN
                   WHERE MBRN_CODE = TRAN_ACING_BRN_CODE)
                    MBRN_NAME,
                 facno (1, TRAN_INTERNAL_ACNUM) account_no,
                 '' DATE_30JUN2021,
                 '' DATE_31DEC2020,
                 TO_CHAR (TRAN_DATE_OF_TRAN) DATE_30JUN2020,
                 TRAN_DB_CR_FLG,
                 TRAN_AMOUNT,
                 UPPER (TRAN_NARR_DTL1 || TRAN_NARR_DTL2 || TRAN_NARR_DTL3)
                    NARRATION,
                 ACNTS_CLOSURE_DATE
            FROM tran2020, acnts
           WHERE     TRAN_INTERNAL_ACNUM <> 0
                 AND ACNTS_INTERNAL_ACNUM = TRAN_INTERNAL_ACNUM
                 AND TRAN_DATE_OF_TRAN = '30-jun-2020'
                 AND TRAN_ACING_BRN_CODE = 26
                 AND UPPER (TRAN_NARR_DTL1 || TRAN_NARR_DTL2 || TRAN_NARR_DTL3) LIKE
                        '%BB CIRCULAR NO. 23%'
                 AND ACNTS_ENTITY_NUM = 1
                 AND TRAN_ENTITY_NUM = 1)
GROUP BY TRAN_ACING_BRN_CODE,
         MBRN_NAME,
         account_no,
         DATE_30JUN2021,
         DATE_31DEC2020,
         DATE_30JUN2020,
         TRAN_DB_CR_FLG,
         ACNTS_CLOSURE_DATE,
         NARRATION