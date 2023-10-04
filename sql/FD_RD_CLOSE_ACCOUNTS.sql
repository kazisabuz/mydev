/* Formatted on 9/25/2023 12:41:09 PM (QP5 v5.388) */
BEGIN
    FOR IDX IN (SELECT * FROM MIG_DETAIL)
    LOOP
        FOR IDZ
            IN (SELECT ACNTS_INTERNAL_ACNUM,PBDCONT_CLOSURE_DATE
                 FROM (SELECT ACNTS_INTERNAL_ACNUM,
                              ACNTS_PROD_CODE,
                              ACNTS_AC_TYPE,
                              ACNTS_CLOSURE_DATE,
                              PBDCONT_CLOSURE_DATE,
                              PBDCONT_CONT_NUM,
                              FN_GET_ASON_ACBAL (1,
                                                 ACNTS_INTERNAL_ACNUM,
                                                 'BDT',
                                                 '12-JUN-2022',
                                                 '12-JUN-2022')    ACBAL
                         FROM ACNTS, PBDCONTRACT
                        WHERE     ACNTS_CLOSURE_DATE IS NULL
                              AND PBDCONT_CLOSURE_DATE IS NOT NULL
                              and ACNTS_ENTITY_NUM=1
                              and PBDCONT_ENTITY_NUM=1
                              AND PBDCONT_BRN_CODE = ACNTS_BRN_CODE
                              AND ACNTS_BRN_CODE = idx.branch_code
                              AND ACNTS_INTERNAL_ACNUM = PBDCONT_DEP_AC_NUM
                              AND (ACNTS_INTERNAL_ACNUM, PBDCONT_CONT_NUM) IN
                                      (  SELECT PBDCONT_DEP_AC_NUM,
                                                MAX (PBDCONT_CONT_NUM)
                                          FROM PBDCONTRACT
                                      GROUP BY PBDCONT_DEP_AC_NUM))
                WHERE ACBAL = 0)
        LOOP
            UPDATE ACNTS
               SET ACNTS_CLOSURE_DATE = IDZ.PBDCONT_CLOSURE_DATE
             WHERE ACNTS_INTERNAL_ACNUM = IDZ.ACNTS_INTERNAL_ACNUM
             and PBDCONT_ENTITY_NUM=1;
        END LOOP;
    END LOOP;
END;