      SELECT /*+PARALLEL(16) */

            ACNTS_ENTITY_NUM,
            ACNTS_BRN_CODE,
            ACNTS_INTERNAL_ACNUM,
            TRAN_WEEK,
            TRAN_MONTH_YEAR,
            SUM (NUMBER_OF_TRAN) NUMBER_OF_TRAN,
            MAX (MAX_WITHWRAL) MAX_WITHWRAL
       FROM (  SELECT ACNTS_ENTITY_NUM,
                      ACNTS_BRN_CODE,
                      ACNTS_INTERNAL_ACNUM,
                      TO_NUMBER (TO_CHAR (T.TRAN_DATE_OF_TRAN, 'DD'))
                         TRAN_DAY_NUMBER,
                      TO_CHAR (T.TRAN_DATE_OF_TRAN, 'MON-YYYY') TRAN_MONTH_YEAR,
                      COUNT (TRAN_INTERNAL_ACNUM) NUMBER_OF_TRAN,
                      SUM (TRAN_AMOUNT) TRAN_AMOUNT,
                      MAX (TRAN_AMOUNT) MAX_WITHWRAL,
                      (CASE
                          WHEN TO_NUMBER (TO_CHAR (T.TRAN_DATE_OF_TRAN, 'DD')) BETWEEN 1
                                                                                   AND 7
                          THEN
                             '1'
                          WHEN TO_NUMBER (TO_CHAR (T.TRAN_DATE_OF_TRAN, 'DD')) BETWEEN 8
                                                                                   AND 14
                          THEN
                             '2'
                          WHEN TO_NUMBER (TO_CHAR (T.TRAN_DATE_OF_TRAN, 'DD')) BETWEEN 15
                                                                                   AND 21
                          THEN
                             '3'
                          WHEN TO_NUMBER (TO_CHAR (T.TRAN_DATE_OF_TRAN, 'DD')) BETWEEN 22
                                                                                   AND 28
                          THEN
                             '4'
                          ELSE
                             '5'
                       END)
                         TRAN_WEEK
                 FROM TRAN2018 T, ACNTS A, RAPARAM R
                WHERE     A.ACNTS_INTERNAL_ACNUM = T.TRAN_INTERNAL_ACNUM
                      AND A.ACNTS_AC_TYPE = R.RAPARAM_AC_TYPE
                      AND A.ACNTS_ENTITY_NUM = T.TRAN_ENTITY_NUM
                      AND A.ACNTS_CLOSURE_DATE IS NULL
                      AND TO_NUMBER (TO_CHAR (T.TRAN_DATE_OF_TRAN, 'DD')) <= '31'
                      AND TO_NUMBER (TO_CHAR (T.TRAN_DATE_OF_TRAN, 'DD')) >= '1'
                      AND R.RAPARAM_INT_FOR_CR_BAL = '1'
                      AND (   R.RAPARAM_CRINT_PROD_BASIS = '1'
                           OR R.RAPARAM_CRINT_PROD_BASIS = '2')
                      AND R.RAPARAM_CRINT_BASIS = 'M'
                      AND (RAPARAM_CRINT_ACCR_FREQ = 'M')
                      AND T.TRAN_DB_CR_FLG = 'D'
                      AND T.TRAN_SYSTEM_POSTED_TRAN = '0'
                      AND T.TRAN_AUTH_ON IS NOT NULL
                      AND (TRIM (T.TRAN_NOTICE_REF_NUM) IS NULL)
                      AND (T.TRAN_AMOUNT > 0 OR T.TRAN_BASE_CURR_EQ_AMT > 0)
                      AND T.TRAN_AUTH_ON IS NOT NULL
                      AND T.TRAN_ENTD_BY <> 'MIG'
                      AND TRAN_DATE_OF_TRAN BETWEEN (CASE
                                                        WHEN A.ACNTS_MMB_INT_ACCR_UPTO
                                                                IS NOT NULL
                                                        THEN
                                                             A.ACNTS_MMB_INT_ACCR_UPTO
                                                           + 1
                                                        WHEN A.ACNTS_BASE_DATE
                                                                IS NULL
                                                        THEN
                                                           A.ACNTS_OPENING_DATE
                                                        WHEN A.ACNTS_OPENING_DATE >=
                                                                A.ACNTS_BASE_DATE
                                                        THEN
                                                           A.ACNTS_BASE_DATE
                                                        ELSE
                                                           A.ACNTS_OPENING_DATE
                                                     END)
                                                AND '28-FEB-18'  and ACNTS_BRN_CODE=1065
             GROUP BY ACNTS_ENTITY_NUM,
                      ACNTS_BRN_CODE,
                      ACNTS_INTERNAL_ACNUM,
                      TO_NUMBER (TO_CHAR (T.TRAN_DATE_OF_TRAN, 'DD')),
                      TO_CHAR (T.TRAN_DATE_OF_TRAN, 'MON-YYYY')
             ORDER BY 1, 2)
   GROUP BY ACNTS_ENTITY_NUM,
            ACNTS_BRN_CODE,
            ACNTS_INTERNAL_ACNUM,
            TRAN_WEEK,
            TRAN_MONTH_YEAR