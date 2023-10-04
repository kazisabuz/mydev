/* Formatted on 4/25/2022 3:56:08 PM (QP5 v5.252.13127.32867) */
SELECT GMO_BRANCH GMO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = GMO_BRANCH)
          GMO_NAME,
       PO_BRANCH PO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = PO_BRANCH)
          PO_NAME,
       tt.*
  FROM (SELECT ACNTS_BRN_CODE,
               mbrn_name,
               ACNTS_PROD_CODE,
               facno (1, ACNTS_INTERNAL_ACNUM) account_no,
               ACNTS_AC_TYPE,
               ACNTS_AC_SUB_TYPE,
               ACNTS_AC_NAME1,
               LIMLNEHIST_LIMIT_LINE_NUM,
               LIMLNEHIST_EFF_DATE,
               LIMLNEHIST_DATE_OF_SANCTION,
               LIMLNEHIST_SANCTION_AMT,
               LIMLNEHIST_LIMIT_EXPIRY_DATE,
               fn_get_ason_acbal (1,
                                  ACNTS_INTERNAL_ACNUM,
                                  'BDT',
                                  '24-APR-2022',
                                  '25-APR-2022')
                  ACCBAL
          FROM LIMITLINEHIST,
               ACASLLDTL,
               acnts,
               mbrn
         WHERE     LIMLNEHIST_ENTITY_NUM = 1
               AND mbrn_code = ACNTS_BRN_CODE
               AND LIMLNEHIST_CLIENT_CODE = ACASLLDTL_CLIENT_NUM
               AND LIMLNEHIST_LIMIT_LINE_NUM = ACASLLDTL_LIMIT_LINE_NUM
               AND ACASLLDTL_ENTITY_NUM = 1
               AND ACASLLDTL_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
               AND LIMLNEHIST_LIMIT_EXPIRY_DATE <=
                      LIMLNEHIST_DATE_OF_SANCTION
               AND ACNTS_ENTITY_NUM = 1
               AND ACNTS_CLOSURE_DATE IS NULL) TT,
       MBRN_TREE
 WHERE TT.ACNTS_BRN_CODE = BRANCH;


SELECT GMO_BRANCH GMO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = GMO_BRANCH)
          GMO_NAME,
       PO_BRANCH PO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = PO_BRANCH)
          PO_NAME,
       tt.*
  FROM (SELECT ACNTS_BRN_CODE,
               mbrn_name,
               ACNTS_PROD_CODE,
               facno (1, ACNTS_INTERNAL_ACNUM) account_no,
               ACNTS_AC_TYPE,
               ACNTS_AC_SUB_TYPE,
               ACNTS_AC_NAME1,
               LNACMIS_SEC_TYPE
          FROM mbrn,LNACMIS, ACNTS
         WHERE     ACNTS_ENTITY_NUM = 1
               AND ACNTS_INTERNAL_ACNUM = LNACMIS_INTERNAL_ACNUM
               AND ACNTS_CLOSURE_DATE IS NULL
               AND LNACMIS_ENTITY_NUM = 1
                AND mbrn_code = ACNTS_BRN_CODE
               AND NVL (TRIM (LNACMIS_SEC_TYPE), '#') NOT IN (    SELECT REGEXP_SUBSTR (
                                                                            LNMISMAPPM_SECURITY_CODE,
                                                                            '[^|]+',
                                                                            1,
                                                                            LEVEL)
                                                                            COL
                                                                    FROM LNMISMAPPM
                                                              CONNECT BY LEVEL <=
                                                                              LENGTH (
                                                                                 LNMISMAPPM_SECURITY_CODE)
                                                                            - LENGTH (
                                                                                 REPLACE (
                                                                                    LNMISMAPPM_SECURITY_CODE,
                                                                                    '|'))))
       TT,
       MBRN_TREE
 WHERE TT.ACNTS_BRN_CODE = BRANCH;