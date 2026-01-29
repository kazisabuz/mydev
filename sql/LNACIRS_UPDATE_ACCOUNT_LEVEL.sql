/*Update after migration*/
UPDATE LNACIRSHIST
   SET LNACIRSH_AC_LEVEL_INT_REQD = '1'
 WHERE     LNACIRSH_ENTD_BY = 'MIG'
       AND LNACIRSH_ENTITY_NUM = 1
       AND LNACIRSH_INTERNAL_ACNUM IN
              (SELECT ACNTS_INTERNAL_ACNUM
                 FROM ACNTS
                WHERE     ACNTS_ENTITY_NUM = 1
                      AND ACNTS_BRN_CODE = 1255
                      AND ACNTS_ENTD_BY = 'MIG'
                      AND ACNTS_CLOSURE_DATE IS NULL);


UPDATE LNACIRS
   SET LNACIRS_AC_LEVEL_INT_REQD = '1'
 WHERE     LNACIRS_REMARKS1 = 'MIGRATION'
       AND LNACIRS_ENTITY_NUM = 1
       AND LNACIRS_INTERNAL_ACNUM IN
              (SELECT ACNTS_INTERNAL_ACNUM
                 FROM ACNTS
                WHERE     ACNTS_ENTITY_NUM = 1
                      AND ACNTS_BRN_CODE = 1255
                      AND ACNTS_ENTD_BY = 'MIG'
                      AND ACNTS_CLOSURE_DATE IS NULL);



UPDATE LNACIRSHIST LN
   SET LN.LNACIRSH_AC_LEVEL_INT_REQD = '0'
 WHERE     LN.LNACIRSH_INTERNAL_ACNUM IN
              (SELECT L.LNACIRSH_INTERNAL_ACNUM
                 FROM LNACIRSHIST L, ACNTS A
                WHERE     L.LNACIRSH_INTERNAL_ACNUM = A.ACNTS_INTERNAL_ACNUM
                      AND A.ACNTS_ENTITY_NUM = 1
                      AND A.ACNTS_BRN_CODE = 1255
                      AND A.ACNTS_ENTD_BY = 'MIG'
                      AND A.ACNTS_CLOSURE_DATE IS NULL
                      AND A.ACNTS_PROD_CODE NOT IN
                             (SELECT P.LNPRD_PROD_CODE
                                FROM LNPRODPM P
                               WHERE P.LNPRD_DEPOSIT_LOAN = '1'))
       AND LN.LNACIRSH_ENTD_BY = 'MIG'
       AND LN.LNACIRSH_ENTITY_NUM = 1;


UPDATE LNACIRS LN
   SET LN.LNACIRS_AC_LEVEL_INT_REQD = '0'
 WHERE     LN.LNACIRS_INTERNAL_ACNUM IN
              (SELECT L.LNACIRS_INTERNAL_ACNUM
                 FROM LNACIRS L, ACNTS A
                WHERE     L.LNACIRS_INTERNAL_ACNUM = A.ACNTS_INTERNAL_ACNUM
                      AND A.ACNTS_ENTITY_NUM = 1
                      AND A.ACNTS_BRN_CODE = 1255
                      AND A.ACNTS_ENTD_BY = 'MIG'
                      AND A.ACNTS_CLOSURE_DATE IS NULL
                      AND A.ACNTS_PROD_CODE NOT IN
                             (SELECT P.LNPRD_PROD_CODE
                                FROM LNPRODPM P
                               WHERE P.LNPRD_DEPOSIT_LOAN = '1'))
       AND LN.LNACIRS_REMARKS1 = 'MIGRATION'
       AND LN.LNACIRS_ENTITY_NUM = 1;