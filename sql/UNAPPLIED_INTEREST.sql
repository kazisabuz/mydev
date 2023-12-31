/* Formatted on 7/5/2020 8:04:25 PM (QP5 v5.227.12220.39754) */
  SELECT FACNO (1, ACNTS_INTERNAL_ACNUM) AC_NUM,
         ACNTS_BRN_CODE BRANCH_CODE,
         ACNTS_PROD_CODE PRODUCT_CODE,
         ACNTS_AC_TYPE ACCOUNT_TYPE,
         ACNTS_AC_NAME1 || ACNTS_AC_NAME2 ACCOUNT_NAME,
         DECODE (ACNTS_CLOSURE_DATE, NULL, 'Open', 'Closed') ACCOUNT_STATUS,
         ASSETCLSH_ASSET_CODE CL_STATUS,
         0 INTEREST_ACCRUE_AMOUNT,
         ACNTS_OPENING_DATE ACCOUNT_OPEN_DATE,
         MIG_END_DATE MIGRATION_DATE
    FROM ASSETCLSHIST,
         ACNTS,
         MIG_DETAIL M,
         BRN_LIST B
   WHERE     ASSETCLSH_ENTITY_NUM = 1
         AND ASSETCLSH_ASSET_CODE IN ('BL', 'ST')
         AND ASSETCLSH_REMARKS IN ('MIGRATION', 'NORMAL LOAN ACCOUNT')
         AND ASSETCLSH_ENTD_BY = 'MIG'
         AND ASSETCLSH_INTERNAL_ACNUM NOT IN
                (SELECT LOANIAMRR_ACNT_NUM
                   FROM LOANIAMRR, MIG_DETAIL
                  WHERE     LOANIAMRR_ENTITY_NUM = 1
                        AND LOANIAMRR_BRN_CODE = BRANCH_CODE
                        AND LOANIAMRR_VALUE_DATE = LOANIAMRR_ACCRUAL_DATE
                        AND LOANIAMRR_ACCRUAL_DATE = MIG_END_DATE
                        AND LOANIAMRR_INT_AMT_RND <> 0)
         AND ACNTS_ENTITY_NUM = 1
         AND ACNTS_INTERNAL_ACNUM = ASSETCLSH_INTERNAL_ACNUM
         AND M.BRANCH_CODE = ACNTS_BRN_CODE
         AND B.BRANCH_CODE = ACNTS_BRN_CODE
ORDER BY 2, 3, 1