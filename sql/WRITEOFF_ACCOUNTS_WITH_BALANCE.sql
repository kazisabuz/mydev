/* Formatted on 7/3/2023 3:05:51 PM (QP5 v5.388) */
SELECT GMO_BRANCH
           GMO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = GMO_BRANCH)
           GMO_NAME,
       PO_BRANCH
           PO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = PO_BRANCH)
           PO_NAME,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = ACNTS_BRN_CODE)
           mbrn_name,
       tt.*
  FROM (SELECT /*+ PARALLEL( 16) */ ACNTS_BRN_CODE,
               facno (1, LNWRTOFF_ACNT_NUM)         account_bal,
               FN_GET_WRITEOFF_BAL (1,
                                    LNWRTOFF_ACNT_NUM,
                                    '30-JUN-2023',               ----ason date
                                    'O')            PENDING_AMT,
               fn_get_ason_acbal (1,
                                  LNWRTOFF_ACNT_NUM,
                                  'BDT',
                                  '30-JUN-2023',
                                  '03-JUL-2023')    acctbal
          FROM LNWRTOFF, acnts
         WHERE     ACNTS_ENTITY_NUM = 1
               AND LNWRTOFF_ENTITY_NUM = 1
               AND ACNTS_INTERNAL_ACNUM = LNWRTOFF_ACNT_NUM) tt,
       MBRN_TREE
 WHERE     TT.ACNTS_BRN_CODE = BRANCH
       AND acctbal <> 0
       AND GMO_BRANCH IN (50995,
                          18994,
                          46995,
                          6999,
                          56993)