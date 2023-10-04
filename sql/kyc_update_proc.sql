/* Formatted on 3/29/2023 2:26:14 PM (QP5 v5.388) */
CREATE OR REPLACE PROCEDURE SBLPROD.SP_GEN_ACNTRNPR (P_FROM_BRANCH   NUMBER,
                                                     P_TO_BRANCH     NUMBER)
IS
    V_ASON_DATE   DATE;
    V_CBD         DATE;


    CURSOR BRN_SL IS
          SELECT *
            FROM (SELECT T.*, ROWNUM BRANCH_SL
                    FROM (  SELECT *
                              FROM MIG_DETAIL
                          ORDER BY BRANCH_CODE) T)
           WHERE BRANCH_SL BETWEEN P_FROM_BRANCH AND P_TO_BRANCH
        ORDER BY BRANCH_CODE;
BEGIN
    FOR IND IN BRN_SL
    LOOP
        FOR IDX
            IN (SELECT ACNTS_BRN_CODE,
                       ACNTS_INTERNAL_ACNUM,
                       ACNTS_PURPOSE_AC_OPEN,
                       ACNTS_SRC_FUND,
                       ACNTS_SRC_FUND_DOC1,
                       ACTPH_SRC_FUND,
                       ACTPH_SRC_FUND_DOC1
                 FROM acnts, ACNTRNPRHIST_BKP
                WHERE     TRIM (ACNTS_SRC_FUND_DOC1) IS NULL
                      AND ACNTS_CLOSURE_DATE IS NULL
                      AND ACNTS_INTERNAL_ACNUM = ACTPH_ACNT_NUM
                      AND ACNTS_BRN_CODE = ACTPH_BRN_CODE
                      AND ACNTS_BRN_CODE = IND.BRANCH_CODE
                      AND TRIM (ACTPH_SRC_FUND) IS NOT NULL
                      AND (   LENGTH (TRIM (ACNTS_SRC_FUND)) <= 3
                           OR TRIM (ACNTS_SRC_FUND) IS NULL)
                      AND TRIM (ACTPH_SRC_FUND_DOC1) IS NOT NULL
                      AND ACNTS_ENTITY_NUM = 1)
        LOOP
            UPDATE ACNTS
               SET ACNTS_SRC_FUND = IDX.ACTPH_SRC_FUND,
                   ACNTS_SRC_FUND_DOC1 = IDX.ACTPH_SRC_FUND_DOC1
             WHERE     ACNTS_ENTITY_NUM = 1
                   AND ACNTS_INTERNAL_ACNUM = IDX.ACNTS_INTERNAL_ACNUM
                   AND ACNTS_BRN_CODE = IDX.ACNTS_BRN_CODE;
        END LOOP;

        COMMIT;
    END LOOP;
END;
/
