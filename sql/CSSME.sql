/* Formatted on 9/26/2021 5:27:20 PM (QP5 v5.149.1003.31008) */
SELECT                                                            --BRANCH_HO,
      GMO_BRANCH GMO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = GMO_BRANCH)
          GMO_NAME,
       PO_BRANCH PO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = PO_BRANCH)
          PO_NAME,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = TT.ACNTS_BRN_CODE)
          BRANCH_NAME,
       TT.*
  FROM (SELECT ACNTS_BRN_CODE,
               IACLINK_ACTUAL_ACNUM account_no,
               ACNTS_AC_NAME1 || ACNTS_AC_NAME2 account_name,
               ACNTS_AC_TYPE,
               ACNTS_CLOSURE_DATE CLOSURE_DATE,
               (SELECT DEDUCTED_AMT
                  FROM deduct_int
                 WHERE ACTUAL_NUM = IACLINK_ACTUAL_ACNUM
                       AND LNINTAPPL_APPL_DATE = '30-sep-2020')
                  DEDUCTED_AMT_SEP,
               (SELECT DEDUCTED_AMT
                  FROM deduct_int
                 WHERE ACTUAL_NUM = IACLINK_ACTUAL_ACNUM
                       AND LNINTAPPL_APPL_DATE = '31-dec-2020')
                  DEDUCTED_AMT_DEC,
               (SELECT DEDUCTED_AMT
                  FROM deduct_int
                 WHERE ACTUAL_NUM = IACLINK_ACTUAL_ACNUM
                       AND LNINTAPPL_APPL_DATE = '31-MAR-2021')
                  DEDUCTED_AMT_MAR,
               (SELECT DEDUCTED_AMT
                  FROM deduct_int
                 WHERE ACTUAL_NUM = IACLINK_ACTUAL_ACNUM
                       AND LNINTAPPL_APPL_DATE = '30-JUN-2021')
                  DEDUCTED_AMT_JUN
          FROM acnts, iaclink, acc4
         WHERE     ACNTS_ENTITY_NUM = 1
               AND IACLINK_ENTITY_NUM = 1
               AND IACLINK_ACTUAL_ACNUM = ACC_NO
               AND IACLINK_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
               AND ACNTS_CLOSURE_DATE IS NOT NULL) TT,
       MBRN_TREE1
 WHERE TT.ACNTS_BRN_CODE = BRANCH