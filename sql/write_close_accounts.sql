/* Formatted on 4/11/2023 1:44:20 PM (QP5 v5.388) */
SELECT *
  FROM (SELECT facno (1, LNWRTOFF_ACNT_NUM)         account_bal,
               FN_GET_WRITEOFF_BAL (1,
                                    LNWRTOFF_ACNT_NUM,
                                    '31-mar-2023',               ----ason date
                                    'O')            PENDING_AMT,
               fn_get_ason_acbal (1,
                                  LNWRTOFF_ACNT_NUM,
                                  'BDT',
                                  '31-mar-2023',
                                  '11-apr-2023')    acctbal,
               ACNTS_CLOSURE_DATE
          FROM LNWRTOFF, ACNTS
         WHERE     ACNTS_ENTITY_NUM = 1
               AND ACNTS_BRN_CODE IN
                       (SELECT BRANCH
                         FROM MBRN_TREE, MBRN
                        WHERE     BRANCH = MBRN_CODE
                              AND GMO_BRANCH IN (50995, 18994))
               AND ACNTS_INTERNAL_ACNUM = LNWRTOFF_ACNT_NUM
               AND ACNTS_CLOSURE_DATE IS NOT NULL)
 WHERE PENDING_AMT <> 0;