/* Formatted on 3/31/2022 6:35:47 PM (QP5 v5.252.13127.32867) */
INSERT INTO ACNTRNPR
   SELECT ACNTS_INTERNAL_ACNUM,
          TRUNC (SYSDATE) ACTP_LATEST_EFF_DATE,
          CASE
             WHEN ACNTS_AC_TYPE = 'SBSS'
             THEN
                'Govt. Bhata'
             WHEN ACNTS_AC_TYPE IN ('SBS', 'SSAO')
             THEN
                'Scholarship and Family income'
             WHEN ACNTS_AC_TYPE = 'SBST'
             THEN
                'Salary From Service'
             WHEN ACNTS_AC_TYPE IN ('CAGOV', 'SBGOV', 'SNDS')
             THEN
                'Govtment Fund'
             WHEN ACNTS_AC_TYPE IN ('CAOFF', 'CACOL')
             THEN
                'Official Collection'
             ELSE
                NULL
          END
             ACTP_SRC_FUND,
          10 ACTP_NOT_CASHR,
          10 ACTP_NOT_NONCASHR,
          10 ACTP_NOT_TFREMR,
          10 ACTP_NOT_NONTFREMR,
          100000 ACTP_MAXAMT_CASHR,
          100000 ACTP_MAXAMT_NCASHR,
          100000 ACTP_MAXAMT_TFREMR,
          100000 ACTP_MAXAMT_NONTFREMR,
          100000 ACTP_CUTOFF_LMT_CASHR,
          100000 ACTP_CUTOFF_LMT_NONCASHR,
          100000 ACTP_CUTOFF_LMT_TFREMR,
          100000 ACTP_CUTOFF_LMT_NONTFREMR,
          10 ACTP_NOT_CASHP,
          10 ACTP_NOT_NONCASHP,
          10 ACTP_NOT_TFREMP,
          10 ACTP_NOT_NONTFREMP,
          100000 ACTP_MAXAMT_CASHP,
          100000 ACTP_MAXAMT_NCASHP,
          100000 ACTP_MAXAMT_TFREMP,
          100000 ACTP_MAXAMT_NONTFREMP,
          10 ACTP_TOTAMT_CASHP,
          100000 ACTP_CUTOFF_LMT_CASHP,
          100000 ACTP_CUTOFF_LMT_NONCASHP,
          100000 ACTP_CUTOFF_LMT_TFREMP,
          100000 ACTP_CUTOFF_LMT_NONTFREMP,
          ACNTS_BRN_CODE ACTP_BRN_CODE,
          0 ACTP_SUBBRN_CODE,
          'Documents Collected' ACTP_SRC_FUND_DOC1,
          NULL ACTP_SRC_FUND_DOC2,
          NULL ACTP_SRC_FUND_DOC3,
          NULL ACTP_SRC_FUND_DOC4,
          NULL ACTP_SRC_FUND_DOC5,
          1 ACTP_SRC_FUND_DOC_VRFD
     FROM ACNTS, PRODUCTS
    WHERE     ACNTS_BRN_CODE IN (23259,
                                 23184,
                                 17160,
                                 33167)
          AND ACNTS_ENTITY_NUM = 1
          AND ACNTS_PROD_CODE = PRODUCT_CODE
          AND ACNTS_CLOSURE_DATE IS NULL
          AND PRODUCT_FOR_DEPOSITS = 1
          AND PRODUCT_FOR_RUN_ACS = 1
          AND ACNTS_INTERNAL_ACNUM NOT IN (SELECT ACTP_ACNT_NUM FROM ACNTRNPR);


INSERT INTO ACNTRNPRHIST
   SELECT ACNTS_INTERNAL_ACNUM ACTPH_ACNT_NUM,
          TRUNC (SYSDATE) ACTPH_LATEST_EFF_DATE,
          CASE
             WHEN ACNTS_AC_TYPE = 'SBSS'
             THEN
                'Govt. Bhata'
             WHEN ACNTS_AC_TYPE IN ('SBS', 'SSAO')
             THEN
                'Scholarship and Family income'
             WHEN ACNTS_AC_TYPE = 'SBST'
             THEN
                'Salary From Service'
             WHEN ACNTS_AC_TYPE IN ('CAGOV', 'SBGOV', 'SNDS')
             THEN
                'Govtment Fund'
             WHEN ACNTS_AC_TYPE IN ('CAOFF', 'CACOL')
             THEN
                'Official Collection'
             ELSE
                NULL
          END
             ACTPH_SRC_FUND,
          10 ACTPH_NOT_CASHR,
          10 ACTPH_NOT_NONCASHR,
          10 ACTPH_NOT_TFREMR,
          10 ACTPH_NOT_NONTFREMR,
          100000 ACTPH_MAXAMT_CASHR,
          100000 ACTPH_MAXAMT_NCASHR,
          100000 ACTPH_MAXAMT_TFREMR,
          100000 ACTPH_MAXAMT_NONTFREMR,
          100000 ACTPH_CUTOFF_LMT_CASHR,
          100000 ACTPH_CUTOFF_LMT_NONCASHR,
          100000 ACTPH_CUTOFF_LMT_TFREMR,
          100000 ACTPH_CUTOFF_LMT_NONTFREMR,
          10 ACTPH_NOT_CASHP,
          10 ACTPH_NOT_NONCASHP,
          10 ACTPH_NOT_TFREMP,
          10 ACTPH_NOT_NONTFREMP,
          100000 ACTPH_MAXAMT_CASHP,
          100000 ACTPH_MAXAMT_NCASHP,
          100000 ACTPH_MAXAMT_TFREMP,
          100000 ACTPH_MAXAMT_NONTFREMP,
          'INTELECT' ACTPH_ENTD_BY,
          SYSDATE ACTPH_ENTD_ON,
          NULL ACTPH_LAST_MOD_BY,
          NULL ACTPH_LAST_MOD_ON,
          'INTELECT' ACTPH_AUTH_BY,
          SYSDATE ACTPH_AUTH_ON,
          NULL TBA_MAIN_KEY,
          100000 ACTPH_CUTOFF_LMT_CASHP,
          100000 ACTPH_CUTOFF_LMT_NONCASHP,
          100000 ACTPH_CUTOFF_LMT_TFREMP,
          100000 ACTPH_CUTOFF_LMT_NONTFREMP,
          ACNTS_BRN_CODE ACTPH_BRN_CODE,
          0 ACTPH_SUBBRN_CODE,
          'Documents Collected' ACTPH_SRC_FUND_DOC1,
          NULL ACTPH_SRC_FUND_DOC2,
          NULL ACTPH_SRC_FUND_DOC3,
          NULL ACTPH_SRC_FUND_DOC4,
          NULL ACTPH_SRC_FUND_DOC5,
          1 ACTPH_SRC_FUND_DOC_VRFD
     FROM ACNTS, PRODUCTS
    WHERE     ACNTS_BRN_CODE IN (23259,
                                 23184,
                                 17160,
                                 33167)
          AND ACNTS_ENTITY_NUM = 1
          AND ACNTS_PROD_CODE = PRODUCT_CODE
          AND ACNTS_CLOSURE_DATE IS NULL
          AND PRODUCT_FOR_DEPOSITS = 1
          AND PRODUCT_FOR_RUN_ACS = 1
          AND ACNTS_INTERNAL_ACNUM NOT IN (SELECT ACTPH_ACNT_NUM
                                             FROM ACNTRNPRHIST);



------------------------------------------------------------------------------------------------------------

INSERT INTO BACKUPTABLE.MIG_ACNTRNPR
   SELECT ACTP_ACNT_NUM,
          ACTP_LATEST_EFF_DATE,
          SUBSTR (ACTP_SRC_FUND, 1, 50),
          SUBSTR (ACTP_NOT_CASHR, 1, 3),
          SUBSTR (ACTP_NOT_NONCASHR, 1, 3),
          SUBSTR (ACTP_NOT_TFREMR, 1, 3),
          SUBSTR (ACTP_NOT_NONTFREMR, 1, 3),
          SUBSTR (ACTP_MAXAMT_CASHR, 1, 15),
          SUBSTR (ACTP_MAXAMT_NCASHR, 1, 15),
          SUBSTR (ACTP_MAXAMT_TFREMR, 1, 15),
          ACTP_MAXAMT_NONTFREMR,
          SUBSTR (ACTP_CUTOFF_LMT_CASHR, 1, 15),
          SUBSTR (ACTP_CUTOFF_LMT_NONCASHR, 1, 15),
          SUBSTR (ACTP_CUTOFF_LMT_TFREMR, 1, 15),
          ACTP_CUTOFF_LMT_NONTFREMR,
          SUBSTR (ACTP_NOT_CASHP, 1, 3),
          SUBSTR (ACTP_NOT_NONCASHP, 1, 3),
          SUBSTR (ACTP_NOT_TFREMP, 1, 3),
          SUBSTR (ACTP_NOT_NONTFREMP, 1, 3),
          SUBSTR (ACTP_MAXAMT_CASHP, 1, 3),
          SUBSTR (ACTP_MAXAMT_NCASHP, 1, 3),
          SUBSTR (ACTP_MAXAMT_TFREMP, 1, 15),
          SUBSTR (ACTP_MAXAMT_NONTFREMP, 1, 15),
          SUBSTR (ACTP_TOTAMT_CASHP, 1, 15),
          SUBSTR (ACTP_CUTOFF_LMT_CASHP, 1, 15),
          SUBSTR (ACTP_CUTOFF_LMT_NONCASHP, 1, 15),
          SUBSTR (ACTP_CUTOFF_LMT_TFREMP, 1, 3),
          SUBSTR (ACTP_CUTOFF_LMT_NONTFREMP, 1, 3)
     FROM BACKUPTABLE.MIG_ACNTRNPRBKPP
    WHERE ACTP_LATEST_EFF_DATE IS NOT NULL;



INSERT INTO ACNTRNPR
   SELECT *
     FROM (SELECT DISTINCT IACLINK_INTERNAL_ACNUM ACTP_ACNT_NUM,
                           ACTP_LATEST_EFF_DATE,
                           ACTP_SRC_FUND,
                           ACTP_NOT_CASHR,
                           ACTP_NOT_NONCASHR,
                           ACTP_NOT_TFREMR,
                           ACTP_NOT_NONTFREMR,
                           ACTP_MAXAMT_CASHR,
                           ACTP_MAXAMT_NCASHR,
                           ACTP_MAXAMT_TFREMR,
                           ACTP_MAXAMT_NONTFREMR,
                           ACTP_CUTOFF_LMT_CASHR,
                           ACTP_CUTOFF_LMT_NONCASHR,
                           ACTP_CUTOFF_LMT_TFREMR,
                           ACTP_CUTOFF_LMT_NONTFREMR,
                           ACTP_NOT_CASHP,
                           ACTP_NOT_NONCASHP,
                           ACTP_NOT_TFREMP,
                           ACTP_NOT_NONTFREMP,
                           ACTP_MAXAMT_CASHP,
                           ACTP_MAXAMT_NCASHP,
                           ACTP_MAXAMT_TFREMP,
                           ACTP_MAXAMT_NONTFREMP,
                           ACTP_TOTAMT_CASHP,
                           ACTP_CUTOFF_LMT_CASHP,
                           ACTP_CUTOFF_LMT_NONCASHP,
                           ACTP_CUTOFF_LMT_TFREMP,
                           ACTP_CUTOFF_LMT_NONTFREMP
             FROM BACKUPTABLE.MIG_ACNTRNPR, IACLINK
            WHERE IACLINK_ACTUAL_ACNUM = TRIM (ACTP_ACNT_NUM)) A
    WHERE A.ACTP_ACNT_NUM NOT IN (SELECT ACTP_ACNT_NUM FROM ACNTRNPR);



INSERT INTO ACNTRNPRHIST
   SELECT *
     FROM (SELECT IACLINK_INTERNAL_ACNUM ACTPH_ACNT_NUM,
                  A.ACTP_LATEST_EFF_DATE ACTPH_LATEST_EFF_DATE,
                  A.ACTP_SRC_FUND ACTPH_SRC_FUND,
                  A.ACTP_NOT_CASHR ACTPH_NOT_CASHR,
                  A.ACTP_NOT_NONCASHR ACTPH_NOT_NONCASHR,
                  A.ACTP_NOT_TFREMR ACTPH_NOT_TFREMR,
                  A.ACTP_NOT_NONTFREMR ACTPH_NOT_NONTFREMR,
                  A.ACTP_MAXAMT_CASHR ACTPH_MAXAMT_CASHR,
                  A.ACTP_MAXAMT_NCASHR ACTPH_MAXAMT_NCASHR,
                  A.ACTP_MAXAMT_TFREMR ACTPH_MAXAMT_TFREMR,
                  A.ACTP_MAXAMT_NONTFREMR ACTPH_MAXAMT_NONTFREMR,
                  A.ACTP_CUTOFF_LMT_CASHR ACTPH_CUTOFF_LMT_CASHR,
                  A.ACTP_CUTOFF_LMT_NONCASHR ACTPH_CUTOFF_LMT_NONCASHR,
                  A.ACTP_CUTOFF_LMT_TFREMR ACTPH_CUTOFF_LMT_TFREMR,
                  A.ACTP_CUTOFF_LMT_NONTFREMR ACTPH_CUTOFF_LMT_NONTFREMR,
                  A.ACTP_NOT_CASHP ACTPH_NOT_CASHP,
                  A.ACTP_NOT_NONCASHP ACTPH_NOT_NONCASHP,
                  A.ACTP_NOT_TFREMP ACTPH_NOT_TFREMP,
                  A.ACTP_NOT_NONTFREMP ACTPH_NOT_NONTFREMP,
                  A.ACTP_MAXAMT_CASHP ACTPH_MAXAMT_CASHP,
                  A.ACTP_MAXAMT_NCASHP ACTPH_MAXAMT_NCASHP,
                  A.ACTP_MAXAMT_TFREMP ACTPH_MAXAMT_TFREMP,
                  A.ACTP_MAXAMT_NONTFREMP ACTPH_MAXAMT_NONTFREMP,
                  'MIG' ACTPH_ENTD_BY,
                  SYSDATE ACTPH_ENTD_ON,
                  NULL ACTPH_LAST_MOD_BY,
                  NULL ACTPH_LAST_MOD_ON,
                  'MIG' ACTPH_AUTH_BY,
                  SYSDATE ACTPH_AUTH_ON,
                  NULL TBA_MAIN_KEY,
                  A.ACTP_CUTOFF_LMT_CASHP ACTPH_CUTOFF_LMT_CASHP,
                  A.ACTP_CUTOFF_LMT_NONCASHP ACTPH_CUTOFF_LMT_NONCASHP,
                  A.ACTP_CUTOFF_LMT_TFREMP ACTPH_CUTOFF_LMT_TFREMP,
                  A.ACTP_CUTOFF_LMT_NONTFREMP ACTPH_CUTOFF_LMT_NONTFREMP
             FROM BACKUPTABLE.MIG_ACNTRNPR A, IACLINK
            WHERE IACLINK_ACTUAL_ACNUM = TRIM (ACTP_ACNT_NUM)) B
    WHERE B.ACTPH_ACNT_NUM NOT IN (SELECT ACTPH_ACNT_NUM FROM ACNTRNPRHIST);


-----------------------

  SELECT ACTP_ACNT_NUM, ACTP_LATEST_EFF_DATE, COUNT (*)                     --
    FROM BACKUPTABLE.MIG_ACNTRNPR
GROUP BY ACTP_ACNT_NUM, ACTP_LATEST_EFF_DATE
  HAVING COUNT (*) > 1;

DELETE FROM BACKUPTABLE.MIG_ACNTRNPR
      WHERE ROWID IN (SELECT ROWID
                        FROM (SELECT ROWID,
                                     ROW_NUMBER ()
                                     OVER (
                                        PARTITION BY ACTP_ACNT_NUM,
                                                     ACTP_LATEST_EFF_DATE
                                        ORDER BY ACTP_LATEST_EFF_DATE)
                                        DUP
                                FROM BACKUPTABLE.MIG_ACNTRNPR)
                       WHERE DUP > 1);