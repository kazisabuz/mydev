/*Business of the customers has been changed and due to that they needed some reports of the existing accounts. */
SELECT *
  FROM (SELECT FACNO (1, ACNTS_INTERNAL_ACNUM) ACNTS_INTERNAL_ACNUM,
               ACNTS_OPENING_DATE OPEN_DATE,
               MIG_END_DATE MIGRATION_DATE,
               LMTLINE_DATE_OF_SANCTION SANCTION_DATE,
               LMTLINE_LIMIT_EXPIRY_DATE EXPIRY_DATE,
               (SELECT SUM (LA.LNINTAPPL_ACT_INT_AMT)
                  FROM LNINTAPPL LA
                 WHERE     LA.LNINTAPPL_ENTITY_NUM = 1
                       AND LA.LNINTAPPL_BRN_CODE = A.ACNTS_BRN_CODE
                       AND LA.LNINTAPPL_ACNT_NUM = A.ACNTS_INTERNAL_ACNUM
                       AND LA.LNINTAPPL_APPL_DATE <= '31-DEC-2017')
                  TOTAL_INT_APPL,
                 ACBALH_BC_BAL
               - (SELECT SUM (LA.LNINTAPPL_ACT_INT_AMT)
                    FROM LNINTAPPL LA
                   WHERE     LA.LNINTAPPL_ENTITY_NUM = 1
                         AND LA.LNINTAPPL_BRN_CODE = A.ACNTS_BRN_CODE
                         AND LA.LNINTAPPL_ACNT_NUM = A.ACNTS_INTERNAL_ACNUM
                         AND LA.LNINTAPPL_APPL_DATE <= '31-DEC-2017')
                  OS_BAL_BEFORE_CBS,
               ACBALH_BC_BAL OS_BAL_AFTER_APPLY,
               ACBALH_BC_BAL - LNINTAPPL_ACT_INT_AMT OS_BAL_BEFORE_APPLY,
               LNINTAPPL_ACT_INT_AMT INT_APPLIED_IN_YE,
               LMTLINE_SANCTION_AMT,
               (SELECT R.LOANIAMRR_INT_AMT
                  FROM LOANIAMRR R
                 WHERE     R.LOANIAMRR_ENTITY_NUM = 1
                       AND R.LOANIAMRR_BRN_CODE = M.BRANCH_CODE
                       AND R.LOANIAMRR_ACNT_NUM = A.ACNTS_INTERNAL_ACNUM
                       AND R.LOANIAMRR_VALUE_DATE = M.MIG_END_DATE)
                  MIG_INT_AMT_GIVEN,
               (SELECT AST.ASSETCLSH_ASSET_CODE
                  FROM ASSETCLSHIST AST
                 WHERE     AST.ASSETCLSH_ENTITY_NUM = 1
                       AND AST.ASSETCLSH_INTERNAL_ACNUM =
                              A.ACNTS_INTERNAL_ACNUM
                       AND AST.ASSETCLSH_ENTD_BY LIKE 'MIG')
                  ASSET_CODE_MIG,
               NVL (
                  (SELECT SUM (LNACDISB_DISB_AMT)
                     FROM LNACDISB
                    WHERE     LNACDISB_ENTITY_NUM = 1
                          AND LNACDISB_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                          AND LNACDISB_AUTH_BY IS NOT NULL),
                  0)
                  DISB_AMT,
               NVL (
                  (SELECT LNTOTINTDB_TOT_INT_DB_AMT
                     FROM LNTOTINTDBMIG
                    WHERE     LNTOTINTDB_ENTITY_NUM = 1
                          AND LNTOTINTDB_INTERNAL_ACNUM =
                                 A.ACNTS_INTERNAL_ACNUM),
                  0)
                  INT_APPLIED_BEFORE_MIG
          FROM ACNTS A,
               LOANACNTS L,
               LNPRODPM LM,
               LNINTAPPL LL,
               ACBALASONHIST BAL,
               MIG_DETAIL M,
               ACASLLDTL ASL,
               LIMITLINE LT
         WHERE     A.ACNTS_ENTITY_NUM = 1
               AND A.ACNTS_ENTITY_NUM = 1
               AND L.LNACNT_ENTITY_NUM = 1
               AND LL.LNINTAPPL_ENTITY_NUM = 1
               AND BAL.ACBALH_ENTITY_NUM = 1
               AND ASL.ACASLLDTL_ENTITY_NUM = 1
               AND LT.LMTLINE_ENTITY_NUM = 1
               AND ACNTS_INTERNAL_ACNUM = LNACNT_INTERNAL_ACNUM
               AND ACNTS_BRN_CODE = LNINTAPPL_BRN_CODE
               AND ACNTS_PROD_CODE = LNPRD_PROD_CODE
               AND LNPRD_SHORT_TERM_LOAN = 1
               AND ACNTS_CLOSURE_DATE IS NULL
               AND LNINTAPPL_ACNT_NUM = ACNTS_INTERNAL_ACNUM
               AND ACBALH_ENTITY_NUM = 1
               AND ACBALH_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
               AND ACBALH_ASON_DATE = '31-DEC-2017'
               AND LNINTAPPL_APPL_DATE = '31-DEC-2017'
               AND BRANCH_CODE = ACNTS_BRN_CODE
               --AND ACNTS_BRN_CODE = 2048
               AND ACASLLDTL_ENTITY_NUM = 1
               AND ACASLLDTL_CLIENT_NUM = LMTLINE_CLIENT_CODE
               AND ACASLLDTL_LIMIT_LINE_NUM = LMTLINE_NUM
               AND ACASLLDTL_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM)
 WHERE    ABS (INT_APPLIED_BEFORE_MIG) + ABS (TOTAL_INT_APPL) >
             ABS (DISB_AMT)
       OR (    ABS (NVL (OS_BAL_BEFORE_APPLY, 0)) > LMTLINE_SANCTION_AMT * 2
           AND OS_BAL_BEFORE_APPLY < 0) ;
		   
		   
		   
		   
SELECT TT.*, ABS (INT_APPLIED_BEFORE_MIG) + ABS (TOTAL_INT_APPL) TOTAL_INTEREST_CALCULATED,  ABS (INT_APPLIED_BEFORE_MIG) + ABS (TOTAL_INT_APPL) - TT.DISB_AMT EXTRA_AMOUNT
  FROM (SELECT FACNO (1, ACNTS_INTERNAL_ACNUM) ACNTS_INTERNAL_ACNUM,
               ACNTS_OPENING_DATE OPEN_DATE,
               MIG_END_DATE MIGRATION_DATE,
               LMTLINE_DATE_OF_SANCTION SANCTION_DATE,
               LMTLINE_LIMIT_EXPIRY_DATE EXPIRY_DATE,
               (SELECT SUM (LA.LNINTAPPL_ACT_INT_AMT)
                  FROM LNINTAPPL LA
                 WHERE     LA.LNINTAPPL_ENTITY_NUM = 1
                       AND LA.LNINTAPPL_BRN_CODE = A.ACNTS_BRN_CODE
                       AND LA.LNINTAPPL_ACNT_NUM = A.ACNTS_INTERNAL_ACNUM
                       AND LA.LNINTAPPL_APPL_DATE <= '31-DEC-2017')
                  TOTAL_INT_APPL,
                 ACBALH_BC_BAL
               - (SELECT SUM (LA.LNINTAPPL_ACT_INT_AMT)
                    FROM LNINTAPPL LA
                   WHERE     LA.LNINTAPPL_ENTITY_NUM = 1
                         AND LA.LNINTAPPL_BRN_CODE = A.ACNTS_BRN_CODE
                         AND LA.LNINTAPPL_ACNT_NUM = A.ACNTS_INTERNAL_ACNUM
                         AND LA.LNINTAPPL_APPL_DATE <= '31-DEC-2017')
                  OS_BAL_BEFORE_CBS,
               ACBALH_BC_BAL OS_BAL_AFTER_APPLY,
               ACBALH_BC_BAL - LNINTAPPL_ACT_INT_AMT OS_BAL_BEFORE_APPLY,
               LNINTAPPL_ACT_INT_AMT INT_APPLIED_IN_YE,
               LMTLINE_SANCTION_AMT,
               (SELECT R.LOANIAMRR_INT_AMT
                  FROM LOANIAMRR R
                 WHERE     R.LOANIAMRR_ENTITY_NUM = 1
                       AND R.LOANIAMRR_BRN_CODE = M.BRANCH_CODE
                       AND R.LOANIAMRR_ACNT_NUM = A.ACNTS_INTERNAL_ACNUM
                       AND R.LOANIAMRR_VALUE_DATE = M.MIG_END_DATE)
                  MIG_INT_AMT_GIVEN,
               (SELECT AST.ASSETCLSH_ASSET_CODE
                  FROM ASSETCLSHIST AST
                 WHERE     AST.ASSETCLSH_ENTITY_NUM = 1
                       AND AST.ASSETCLSH_INTERNAL_ACNUM =
                              A.ACNTS_INTERNAL_ACNUM
                       AND AST.ASSETCLSH_ENTD_BY LIKE 'MIG')
                  ASSET_CODE_MIG,
               NVL (
                  (SELECT SUM (LNACDISB_DISB_AMT)
                     FROM LNACDISB
                    WHERE     LNACDISB_ENTITY_NUM = 1
                          AND LNACDISB_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                          AND LNACDISB_AUTH_BY IS NOT NULL),
                  0)
                  DISB_AMT,
               NVL (
                  (SELECT LNTOTINTDB_TOT_INT_DB_AMT
                     FROM LNTOTINTDBMIG
                    WHERE     LNTOTINTDB_ENTITY_NUM = 1
                          AND LNTOTINTDB_INTERNAL_ACNUM =
                                 A.ACNTS_INTERNAL_ACNUM),
                  0)
                  INT_APPLIED_BEFORE_MIG
          FROM ACNTS A,
               LOANACNTS L,
               LNPRODPM LM,
               LNINTAPPL LL,
               ACBALASONHIST BAL,
               MIG_DETAIL M,
               ACASLLDTL ASL,
               LIMITLINE LT
         WHERE     A.ACNTS_ENTITY_NUM = 1
               AND A.ACNTS_ENTITY_NUM = 1
               AND L.LNACNT_ENTITY_NUM = 1
               AND LL.LNINTAPPL_ENTITY_NUM = 1
               AND BAL.ACBALH_ENTITY_NUM = 1
               AND ASL.ACASLLDTL_ENTITY_NUM = 1
               AND LT.LMTLINE_ENTITY_NUM = 1
               AND ACNTS_INTERNAL_ACNUM = LNACNT_INTERNAL_ACNUM
               AND ACNTS_BRN_CODE = LNINTAPPL_BRN_CODE
               AND ACNTS_PROD_CODE = LNPRD_PROD_CODE
               AND LNPRD_SHORT_TERM_LOAN = 1
               AND ACNTS_CLOSURE_DATE IS NULL
               AND LNINTAPPL_ACNT_NUM = ACNTS_INTERNAL_ACNUM
               AND ACBALH_ENTITY_NUM = 1
               AND ACBALH_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
               AND ACBALH_ASON_DATE = '31-DEC-2017'
               AND LNINTAPPL_APPL_DATE = '31-DEC-2017'
               AND BRANCH_CODE = ACNTS_BRN_CODE
               --AND ACNTS_BRN_CODE = 2048
               AND ACASLLDTL_ENTITY_NUM = 1
               AND ACASLLDTL_CLIENT_NUM = LMTLINE_CLIENT_CODE
               AND ACASLLDTL_LIMIT_LINE_NUM = LMTLINE_NUM
               AND ACASLLDTL_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM) TT
 WHERE    ABS (INT_APPLIED_BEFORE_MIG) + ABS (TOTAL_INT_APPL) >
             ABS (DISB_AMT) 
          AND ABS (OS_BAL_AFTER_APPLY) > 2 *  LMTLINE_SANCTION_AMT 
          AND ABS(ROUND(MIG_INT_AMT_GIVEN, 0) ) < ABS(INT_APPLIED_IN_YE)