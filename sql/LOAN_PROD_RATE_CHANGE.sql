/* Formatted on 9/1/2023 12:47:47 AM (QP5 v5.388) */
BEGIN
    FOR IDX IN (SELECT * FROM BACKUPTABLE.LNPRODIR_SMART_RATE)
    LOOP
        UPDATE LNPRODIR
           SET LNPRODIR_LATEST_EFF_DATE = '20-aug-2023',
               LNPRODIR_APPL_INT_RATE = IDX.APPLICABLE_INTEREST_RATE,
               LNPRODIR_CIRC_REF_NUM = IDX.CIRCULAR_REFERENCE_NUMBER,
               LNPRODIR_CIRC_REF_DATE = '20-aug-2023'
         WHERE     LNPRODIR_ENTITY_NUM = 1
               AND LNPRODIR_PROD_CODE = IDX.LOAN_PRODUCT_CODE
               AND LNPRODIR_AC_TYPE = IDX.ACCOUNT_TYPE
               AND LNPRODIR_AC_SUB_TYPE = IDX.ACCOUNT_SUB_TYPE;


        UPDATE LNPRODIRDTL
           SET LNPRODIRDTL_INT_RATE = IDX.APPLICABLE_INTEREST_RATE
         WHERE     LNPRODIRDTL_ENTITY_NUM = 1
               AND LNPRODIRDTL_PROD_CODE = IDX.LOAN_PRODUCT_CODE
               AND LNPRODIRDTL_AC_TYPE = IDX.ACCOUNT_TYPE
               AND LNPRODIRDTL_AC_SUB_TYPE = IDX.ACCOUNT_SUB_TYPE;
    END LOOP;
END;

INSERT INTO LNPRODIRDTLHIST
    SELECT 1                            LNPRODIRDTLH_ENTITY_NUM,
           LOAN_PRODUCT_CODE            LNPRODIRDTLH_PROD_CODE,
           'BDT'                        LNPRODIRDTLH_CURR_CODE,
           ACCOUNT_TYPE                 LNPRODIRDTLH_AC_TYPE,
           ACCOUNT_SUB_TYPE             LNPRODIRDTLH_AC_SUB_TYPE,
           0                            LNPRODIRDTLH_CYCLE_NUM,
           NULL                         LNPRODIRDTLH_SCHEME_CODE,
           NULL                         LNPRODIRDTLH_CLSEG_CODE,
           NULL                         LNPRODIRDTLH_TENOR_SLAB_CODE,
           0                            LNPRODIRDTLH_TENOR_SLAB_SL,
           '20-AUG-2023'                LNPRODIRDTLH_EFF_DATE,
           0                            LNPRODIRDTLH_AMT_SLAB_SL,
           APPLICABLE_INTEREST_RATE     LNPRODIRDTLH_INT_RATE
      FROM BACKUPTABLE.LNPRODIR_SMART_RATE;


INSERT INTO LNPRODIRHIST
    SELECT 1                             LNPRODIRH_ENTITY_NUM,
           LOAN_PRODUCT_CODE             LNPRODIRH_PROD_CODE,
           'BDT'                         LNPRODIRH_CURR_CODE,
           ACCOUNT_TYPE                  LNPRODIRH_AC_TYPE,
           ACCOUNT_SUB_TYPE              LNPRODIRH_AC_SUB_TYPE,
           0                             LNPRODIRH_CYCLE_NUM,
           NULL                          LNPRODIRH_SCHEME_CODE,
           NULL                          LNPRODIRH_CLSEG_CODE,
           NULL                          LNPRODIRH_TENOR_SLAB_CODE,
           0                             LNPRODIRH_TENOR_SLAB_SL,
           '20-AUG-2023'                 LNPRODIRH_EFF_DATE,
           NULL                          LNPRODIRH_AMT_SLAB_CODE,
           APPLICABLE_INTEREST_RATE      LNPRODIRH_APPL_INT_RATE,
           CIRCULAR_REFERENCE_NUMBER     LNPRODIRH_CIRC_REF_NUM,
           '20-AUG-2023'                 LNPRODIRH_CIRC_REF_DATE,
           NULL                          LNPRODIRH_REMARKS1,
           NULL                          LNPRODIRH_REMARKS2,
           NULL                          LNPRODIRH_REMARKS3,
           '40628'                       LNPRODIRH_ENTD_BY,
           SYSDATE                       LNPRODIRH_ENTD_ON,
           NULL                          LNPRODIRH_LAST_MOD_BY,
           NULL                          LNPRODIRH_LAST_MOD_ON,
           '40628'                       LNPRODIRH_AUTH_BY,
           SYSDATE                       LNPRODIRH_AUTH_ON,
           NULL                          TBA_MAIN_KEY,
           0                             LNPRODIRH_APPL_INT_RATE_EXPIRY
      FROM BACKUPTABLE.LNPRODIR_SMART_RATE;


BEGIN
    INSERT INTO ACC5 (acc_no)
        SELECT /*+ PARALLEL( 32) */
               ACNTS_INTERNAL_ACNUM
          FROM ACNTS, BACKUPTABLE.LNPRODIR_SMART_RATE
         WHERE     ACNTS_PROD_CODE = LOAN_PRODUCT_CODE
               AND ACNTS_AC_TYPE = ACCOUNT_TYPE
               AND ACNTS_AC_SUB_TYPE = ACCOUNT_SUB_TYPE
               AND ACNTS_ENTITY_NUM = 1
               AND ACNTS_INTERNAL_ACNUM NOT IN
                       (SELECT LNACIR_INTERNAL_ACNUM
                         FROM LNACIR, LNACIRS
                        WHERE     LNACIRS_ENTITY_NUM = 1
                              AND LNACIRS_INTERNAL_ACNUM =
                                  LNACIR_INTERNAL_ACNUM
                              AND LNACIR_ENTITY_NUM = 1
                              AND LNACIRS_AC_LEVEL_INT_REQD = '1'
                              AND ACNTS_ENTITY_NUM = 1)
               AND ACNTS_CLOSURE_DATE IS NULL;


    DELETE FROM
        LOANIADLY
          WHERE     RTMPLNIA_ACNT_NUM IN (SELECT ACC_NO FROM ACC5)
                AND RTMPLNIA_VALUE_DATE >= '20-AUG-2023';
/* Formatted on 9/1/2023 12:51:20 AM (QP5 v5.388) */
/* Formatted on 9/1/2023 1:43:44 AM (QP5 v5.388) */
BEGIN
    FOR idx IN (SELECT * FROM mbrn)
    LOOP
        UPDATE LOANACNTS
           SET LNACNT_RTMP_ACCURED_UPTO = '19-AUG-2023',
               LNACNT_RTMP_PROCESS_DATE = '19-AUG-2023'
         WHERE     LNACNT_ENTITY_NUM = 1
               AND LNACNT_INTERNAL_ACNUM IN
                       (SELECT /*+ PARALLEL( 32) */
                               DISTINCT ACC_NO
                         FROM ACC5, LOANIADLY
                        WHERE     RTMPLNIA_ACNT_NUM = acc_no
                              AND RTMPLNIA_BRN_CODE = idx.mbrn_code
                              AND RTMPLNIA_VALUE_DATE >= '20-AUG-2023');

        COMMIT;
    END LOOP;
END;
END;