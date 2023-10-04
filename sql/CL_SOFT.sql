/* Formatted on 8/31/2022 8:08:19 PM (QP5 v5.388) */
---ACNTBAL

SELECT                                                            --BRANCH_HO,
       GMO_BRANCH
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
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = TT.BRN_CODE)
           BRANCH_NAME,
       BRN_CODE,
       PROD_CODE,
       ACC_NO,
       AC_TYPE,
       TO_CHAR (AC_NAME)
           AC_NAME,
       CL_STATUS_IN_CL_SOFT,
       CL_STATUS_IN_CBS,
       ELIGIBLE_SECURITY_IN_CL_SOFT,
       ELIGIBLE_SECURITY_IN_CBS,
       OUTSTANDING_BAL_CL_SOFT,
       OUTSTANDING_BAL_CBS
  FROM (SELECT /*+ PARALLEL( 16) */
               ACNTS_BRN_CODE                       BRN_CODE,
               ACNTS_PROD_CODE                      PROD_CODE,
               ACC_NO,
               ACNTS_AC_TYPE                        AC_TYPE,
               ACNTS_AC_NAME1 || ACNTS_AC_NAME2     AC_NAME,
               ELIGIBLE_SECURITY_IN_CL_SOFT,
               get_secured_value (ACNTS_INTERNAL_ACNUM,
                                  '30-jun-2022',
                                  '04-sep-2022',
                                  'BDT')            ELIGIBLE_SECURITY_IN_CBS,
               CL_STATUS                            CL_STATUS_IN_CL_SOFT,
               ASSETCLS_ASSET_CODE                  CL_STATUS_IN_CBS,
               OUTSTANDING_BAL                      OUTSTANDING_BAL_CL_SOFT,
               FN_GET_ASON_ACBAL (1,
                                  ACNTS_INTERNAL_ACNUM,
                                  'BDT',
                                  '30-jun-2022',
                                  '04-sep-2022')    OUTSTANDING_BAL_CBS
          FROM BACKUPTABLE.ACCOUNT_LIST,
               iaclink,
               acnts,
               assetcls
         WHERE     acc_no = IACLINK_ACTUAL_ACNUM
               AND ASSETCLS_ENTITY_NUM = 1
               AND IACLINK_ENTITY_NUM = 1
               AND ACNTS_INTERNAL_ACNUM = ASSETCLS_INTERNAL_ACNUM
               AND IACLINK_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
               AND ACNTS_ENTITY_NUM = 1) TT,
       MBRN_TREE1
 WHERE TT.BRN_CODE = BRANCH --AND GMO_BRANCH IN (20998, 27995)
 ;

---------------NOT IN CBS------------

  SELECT                                                          --BRANCH_HO,
         GMO_BRANCH
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
           WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = TT.BRN_CODE)
             BRANCH_NAME,
         BRN_CODE,
         NULL PROD_CODE,
         ACC_NO,
      null   AC_TYPE,
      
           null  AC_NAME,
         CL_STATUS_IN_CL_SOFT,
         NULL
             CL_STATUS_IN_CBS,
         ELIGIBLE_SECURITY_IN_CL_SOFT,
         0
             ELIGIBLE_SECURITY_IN_CBS,
         OUTSTANDING_BAL_CL_SOFT,
         0
             OUTSTANDING_BAL_CBS
    FROM (SELECT SUBSTR (acc_no, 1, 6)     BRN_CODE,
                 -- ACNTS_PROD_CODE PROD_CODE,
                 ACC_NO,
                 ELIGIBLE_SECURITY_IN_CL_SOFT,
                 CL_STATUS                 CL_STATUS_IN_CL_SOFT,
                 OUTSTANDING_BAL           OUTSTANDING_BAL_CL_SOFT
            FROM BACKUPTABLE.ACCOUNT_LIST
           WHERE acc_no NOT IN (SELECT IACLINK_ACTUAL_ACNUM
                                  FROM iaclink
                                 WHERE IACLINK_ENTITY_NUM = 1)) TT,
         MBRN_TREE1
   WHERE TT.BRN_CODE = BRANCH
ORDER BY GMO_BRANCH;

----SECURITY BALANCE

                                                           --BRANCH_HO,

  SELECT /*+ PARALLEL( 16) */
         GMO_BRANCH
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
           WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = TT.BRN_CODE)
             BRANCH_NAME,
         BRN_CODE,
         PROD_CODE,
         ACC_NO,
         AC_TYPE,
         TO_CHAR (AC_NAME)
             AC_NAME,
         ELIGIBLE_SECURITY_IN_CL_SOFT,
         ELIGIBLE_SECURITY_IN_CBS,
         FEB_SECURITY_IN_CBS,
         acnt_bal
    FROM (SELECT ACNTS_BRN_CODE                       BRN_CODE,
                 ACNTS_PROD_CODE                      PROD_CODE,
                 ACC_NO,
                 ACNTS_AC_TYPE                        AC_TYPE,
                 ACNTS_AC_NAME1 || ACNTS_AC_NAME2     AC_NAME,
                 ELIGIBLE_SECURITY_IN_CL_SOFT,
                 get_secured_value (ACNTS_INTERNAL_ACNUM,
                                    '30-jun-2022',
                                    '01-sep-2022',
                                    'BDT')            FEB_SECURITY_IN_CBS,
                 ELIGIBLE_SECURITY_IN_CBS,
                 FN_GET_ASON_ACBAL (1,
                                    ACNTS_INTERNAL_ACNUM,
                                    'BDT',
                                    '30-jun-2022',
                                    '01-sep-2022')    acnt_bal
            FROM backuptable.ACCOUNT_LIST, iaclink, acnts
           WHERE     acc_no = IACLINK_ACTUAL_ACNUM
                 AND IACLINK_ENTITY_NUM = 1
                 AND IACLINK_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                 AND ACNTS_ENTITY_NUM = 1) TT,
         MBRN_TREE1
   WHERE TT.BRN_CODE = BRANCH
ORDER BY GMO_BRANCH;



SELECT                                                            --BRANCH_HO,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = BRANCH_GMO)
           GMO_NAME,
       BRANCH_GMO,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = BRANCH_PO)
           PO_NAME,
       BRANCH_PO,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = TT.BRN_CODE)
           BRANCH_NAME,
       BRN_CODE,
       PROD_CODE,
       ACC_NO,
       AC_TYPE,
       TO_CHAR (AC_NAME)
           AC_NAME,
       acnt_bal
  FROM (SELECT ACNTS_BRN_CODE                       BRN_CODE,
               ACNTS_PROD_CODE                      PROD_CODE,
               ACC_NO,
               ACNTS_AC_TYPE                        AC_TYPE,
               ACNTS_AC_NAME1 || ACNTS_AC_NAME2     AC_NAME,
               FN_GET_ASON_ACBAL (1,
                                  ACNTS_INTERNAL_ACNUM,
                                  'BDT',
                                  '30-jun-2022',
                                  '01-sep-2022')    acnt_bal
          FROM acc4, iaclink, acnts
         WHERE     acc_no = IACLINK_ACTUAL_ACNUM
               AND IACLINK_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
               AND ACNTS_ENTITY_NUM = 1) TT,
       MBRN_TREE2  MB
 WHERE TT.BRN_CODE = MB.BRANCH_CODE;