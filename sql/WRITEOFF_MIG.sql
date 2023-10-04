/* Formatted on 8/27/2023 11:26:14 AM (QP5 v5.388) */
--1. IMPORT DATA FROM EXCEL IN TABLE MIG_WRITEOFF

--2.Pass the voucher

--3.

INSERT INTO LNWRTOFF
    SELECT 1                            LNWRTOFF_ENTITY_NUM,
           IACLINK_INTERNAL_ACNUM       LNWRTOFF_ACNT_NUM,
           ROWNUM                       LNWRTOFF_SL_NUM,
           LNWRTOFF_WRTOFF_DATE         LNWRTOFF_WRTOFF_DATE,
           'BDT'                        LNWRTOFF_CURR_CODE,
           LNWRTOFF_WRTOFF_AMT          LNWRTOFF_WRTOFF_AMT,
           LNWRTOFF_PRIN_WRTOFF_AMT     LNWRTOFF_PRIN_WRTOFF_AMT,
           LNWRTOFF_INT_WRTOFF_AMT      LNWRTOFF_INT_WRTOFF_AMT,
           LNWRTOFF_CHG_WRTOFF_AMT      LNWRTOFF_CHG_WRTOFF_AMT,
           ''                           LNWRTOFF_SANC_BY,
           ''                           LNWRTOFF_SANC_ON,
           ''                           LNWRTOFF_SANC_REF_NUM,
           'Issue|68186'                LNWRTOFF_REMARKS1,     ---ISSUE NUMBER
           ''                           LNWRTOFF_REMARKS2,
           ''                           LNWRTOFF_REMARKS3,
           ''                           LNWRTOFF_ENTRY_TYPE,
           ''                           LNWRTOFF_SOURCE_KEY,
           :POST_TRAN_BRN,                                     ----BRANCH CODE
           :POST_TRAN_DATE,                                      -- BATCH DATE
           174                          POST_TRAN_BATCH_NUM,   ---BATCH NUMBER
           'INTELECT'                   LNWRTOFF_ENTD_BY,
           SYSDATE                      LNWRTOFF_ENTD_ON,
           NULL                         LNWRTOFF_LAST_MOD_BY,
           NULL                         LNWRTOFF_LAST_MOD_ON,
           'INTELECT'                   LNWRTOFF_AUTH_BY,
           SYSDATE                      LNWRTOFF_AUTH_ON,
           NULL                         LNWRTOFF_REJ_BY,
           NULL                         LNWRTOFF_REJ_ON,
           NULL                         LNWRTOFF_IBR_BRN_CODE,
           NULL                         LNWRTOFF_IBR_TRAN_CODE,
           NULL                         LNWRTOFF_INT_APP,
           NULL                         LNWRTOFF_INT_INCOME_AMT
      FROM MIG_WRITEOFF, iaclink
     WHERE     LNWRTOFF_ACNT_NUM = IACLINK_ACTUAL_ACNUM
           AND IACLINK_ENTITY_NUM = 1;

----------------WRITTEN-OFF-RECOVERY----------------------------------

SELECT LNWRTOFFREC_ENTITY_NUM         LNWRTOFFREC_ENTITY_NUM,
       IACLINK_INTERNAL_ACNUM         LNWRTOFFREC_LN_ACNUM,
       ROWNUM                         LNWRTOFFREC_RECOV_SL,
       LNWRTOFFREC_ENTRY_DATE         LNWRTOFFREC_ENTRY_DATE,
       LNWRTOFFREC_RECOV_CURR         LNWRTOFFREC_RECOV_CURR,
       LNWRTOFFREC_RECOV_AMT          LNWRTOFFREC_RECOV_AMT,
       LNWRTOFFREC_PRIN               LNWRTOFFREC_PRIN,
       LNWRTOFFREC_INT_ACCR           LNWRTOFFREC_INT_ACCR,
       LNWRTOFFREC_PENAL_INT_ACCR     LNWRTOFFREC_PENAL_INT_ACCR,
       LNWRTOFFREC_RECOV_BY           LNWRTOFFREC_RECOV_BY,
       LNWRTOFFREC_PAYMENT_DAYE       LNWRTOFFREC_PAYMENT_DAYE,
       LNWRTOFFREC_PAYMENT_MODE       LNWRTOFFREC_PAYMENT_MODE,
       LNWRTOFFREC_DB_ACNUM           LNWRTOFFREC_DB_ACNUM,
       LNWRTOFFREC_DB_GL_ACCESS       LNWRTOFFREC_DB_GL_ACCESS,
       LNWRTOFFREC_NOTES1             LNWRTOFFREC_NOTES1,
       LNWRTOFFREC_NOTES2             LNWRTOFFREC_NOTES2,
       LNWRTOFFREC_NOTES13            LNWRTOFFREC_NOTES3,
       LNWRTOFFREC_ENTD_BY            LNWRTOFFREC_ENTD_BY,
       SYSDATE                        LNWRTOFFREC_ENTD_ON,
       NULL                           LNWRTOFFREC_LAST_MOD_BY,
       NULL                           LNWRTOFFREC_LAST_MOD_ON,
       'INTELECT'                     LNWRTOFFREC_AUTH_BY,
       SYSDATE                        LNWRTOFFREC_AUTH_ON,
       NULL                           LNWRTOFFREC_REJ_BY,
       NULL                           LNWRTOFFREC_REJ_ON,
       NULL                           LNWRTOFFREC_TRANSTLMNT_INV_NUM,
       :POST_TRAN_BRN,
       :POST_TRAN_DATE,
       :POST_TRAN_BATCH_NUM
  FROM MIG_WRITEOFF_RECOV, iaclink
 WHERE LNWRTOFFREC_LN_ACNUM = IACLINK_ACTUAL_ACNUM 
 AND IACLINK_ENTITY_NUM = 1;



