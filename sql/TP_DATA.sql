/* Formatted on 2/5/2023 6:53:52 PM (QP5 v5.388) */
  SELECT BRANCH_CODE,
         (SELECT MBRN_NAME
            FROM MBRN
           WHERE MBRN_CODE = BRANCH_CODE)    MBRN_NAME,
         MIG_END_DATE,
         NVL (AB.TOTAL_ACCOUNT, 0)           TOTAL_ACCOUNT
    FROM (  SELECT ACNTS_BRN_CODE, COUNT (*) TOTAL_ACCOUNT
              FROM ACNTRNPRHIST, ACNTS
             WHERE     ACTPH_ENTD_BY = 'MIG'
                   AND ACTPH_ACNT_NUM = ACNTS_INTERNAL_ACNUM
                   AND ACNTS_ENTITY_NUM = 1
          GROUP BY ACNTS_BRN_CODE) AB
         RIGHT OUTER JOIN MIG_DETAIL ON (AB.ACNTS_BRN_CODE = BRANCH_CODE)
ORDER BY MIG_END_DATE;



INSERT INTO ACNTRNPR
    SELECT IACLINK_INTERNAL_ACNUM                        ACTP_ACNT_NUM,
           TRUNC (SYSDATE)                               ACTP_LATEST_EFF_DATE,
           'Foreign Remittance'                          ACTP_SRC_FUND,
           5                                             ACTP_NOT_CASHR,
           5                                             ACTP_NOT_NONCASHR,
           5                                             ACTP_NOT_TFREMR,
           5                                             ACTP_NOT_NONTFREMR,
           20000                                         ACTP_MAXAMT_CASHR,
           20000                                         ACTP_MAXAMT_NCASHR,
           10000                                         ACTP_MAXAMT_TFREMR,
           10000                                         ACTP_MAXAMT_NONTFREMR,
           10000                                         ACTP_CUTOFF_LMT_CASHR,
           10000                                         ACTP_CUTOFF_LMT_NONCASHR,
           10000                                         ACTP_CUTOFF_LMT_TFREMR,
           10000                                         ACTP_CUTOFF_LMT_NONTFREMR,
           5                                             ACTP_NOT_CASHP,
           5                                             ACTP_NOT_NONCASHP,
           5                                             ACTP_NOT_TFREMP,
           5                                             ACTP_NOT_NONTFREMP,
           20000                                         ACTP_MAXAMT_CASHP,
           20000                                         ACTP_MAXAMT_NCASHP,
           20000                                         ACTP_MAXAMT_TFREMP,
           20000                                         ACTP_MAXAMT_NONTFREMP,
           0                                             ACTP_TOTAMT_CASHP,
           10000                                         ACTP_CUTOFF_LMT_CASHP,
           10000                                         ACTP_CUTOFF_LMT_NONCASHP,
           10000                                         ACTP_CUTOFF_LMT_TFREMP,
           10000                                         ACTP_CUTOFF_LMT_NONTFREMP,
           34                                            ACTP_BRN_CODE,
           0                                             ACTP_SUBBRN_CODE,
           'Documents collect against source of fund'    ACTP_SRC_FUND_DOC1,
           NULL                                          ACTP_SRC_FUND_DOC2,
           NULL                                          ACTP_SRC_FUND_DOC3,
           NULL                                          ACTP_SRC_FUND_DOC4,
           NULL                                          ACTP_SRC_FUND_DOC5,
           1                                             ACTP_SRC_FUND_DOC_VRFD
      FROM ACC4,
           temp_client,
           backuptable.indclients  i,
           iaclink
     WHERE     OLD_CLCODE = acc_no
           AND BRN_CODE = 34
           AND INDCLIENT_CODE = NEW_CLCODE
           AND IACLINK_ENTITY_NUM = 1
           AND IACLINK_CIF_NUMBER = NEW_CLCODE;



INSERT INTO ACNTRNPRHIST
    SELECT IACLINK_INTERNAL_ACNUM                        ACTP_ACNT_NUM,
           TRUNC (SYSDATE)                               ACTP_LATEST_EFF_DATE,
           'Foreign Remittance'                          ACTP_SRC_FUND,
           5                                             ACTP_NOT_CASHR,
           5                                             ACTP_NOT_NONCASHR,
           5                                             ACTP_NOT_TFREMR,
           5                                             ACTP_NOT_NONTFREMR,
           20000                                         ACTP_MAXAMT_CASHR,
           20000                                         ACTP_MAXAMT_NCASHR,
           10000                                         ACTP_MAXAMT_TFREMR,
           10000                                         ACTP_MAXAMT_NONTFREMR,
           10000                                         ACTP_CUTOFF_LMT_CASHR,
           10000                                         ACTP_CUTOFF_LMT_NONCASHR,
           10000                                         ACTP_CUTOFF_LMT_TFREMR,
           10000                                         ACTP_CUTOFF_LMT_NONTFREMR,
           5                                             ACTP_NOT_CASHP,
           5                                             ACTP_NOT_NONCASHP,
           5                                             ACTP_NOT_TFREMP,
           5                                             ACTP_NOT_NONTFREMP,
           20000                                         ACTP_MAXAMT_CASHP,
           20000                                         ACTP_MAXAMT_NCASHP,
           20000                                         ACTP_MAXAMT_TFREMP,
           20000                                         ACTP_MAXAMT_NONTFREMP,
           'MIG'                                         ACTPH_ENTD_BY,
           SYSDATE                                       ACTPH_ENTD_ON,
           NULL                                          ACTPH_LAST_MOD_BY,
           NULL                                          ACTPH_LAST_MOD_ON,
           'MIG'                                         ACTPH_AUTH_BY,
           SYSDATE                                       ACTPH_AUTH_ON,
           NULL                                          TBA_MAIN_KEY,
           10000                                         ACTP_CUTOFF_LMT_CASHP,
           10000                                         ACTP_CUTOFF_LMT_NONCASHP,
           10000                                         ACTP_CUTOFF_LMT_TFREMP,
           10000                                         ACTP_CUTOFF_LMT_NONTFREMP,
           34                                            ACTP_BRN_CODE,
           0                                             ACTP_SUBBRN_CODE,
           'Documents collect against source of fund'    ACTP_SRC_FUND_DOC1,
           NULL                                          ACTP_SRC_FUND_DOC2,
           NULL                                          ACTP_SRC_FUND_DOC3,
           NULL                                          ACTP_SRC_FUND_DOC4,
           NULL                                          ACTP_SRC_FUND_DOC5,
           1                                             ACTP_SRC_FUND_DOC_VRFD
      FROM ACC4,
           temp_client,
           backuptable.indclients  i,
           iaclink
     WHERE     OLD_CLCODE = acc_no
           AND BRN_CODE = 34
           AND INDCLIENT_CODE = NEW_CLCODE
           AND IACLINK_ENTITY_NUM = 1
           AND IACLINK_CIF_NUMBER = NEW_CLCODE