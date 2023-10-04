--------------------CLASSIFIED LOAN ACCOUNT BALANCE
SELECT SUM (TRAN_AMOUNT)                                     ---10004083773.92
  FROM ASSETCLS, TRAN2018
 WHERE     TRAN_INTERNAL_ACNUM = ASSETCLS_INTERNAL_ACNUM
       AND TRAN_ENTITY_NUM = 1
       AND ASSETCLS_ASSET_CODE IN ('DF', 'SS', 'BL')
       AND TRAN_DB_CR_FLG = 'C'
       AND ASSETCLS_ENTITY_NUM = 1
       -- AND TRAN_DATE_OF_TRAN BETWEEN '01-OCT-2018' AND '28-DEC-2018'
       AND TRAN_AUTH_BY IS NOT NULL;

---------------RESCHEDULE LOAN-------------------
 SELECT MBRN_CODE,
         MBRN_NAME,
         PO_CODE,
         (SELECT MBRN_NAME
            FROM MBRN
           WHERE MBRN_CODE = PO_CODE)
            PO_NAME,
         GMO_CODE,
         (SELECT MBRN_NAME
            FROM MBRN
           WHERE MBRN_CODE = GMO_CODE)
            GMO_NAME,
         SUM (LNACRS_REPH_ON_AMT) TOTAL_AMOUNT
    FROM (SELECT MBRN_CODE,
                 MBRN_NAME,
                 (SELECT MBRN_PARENT_ADMIN_CODE
                    FROM MBRN
                   WHERE MBRN_CODE = TT.MBRN_CODE)
                    "PO_CODE",
                 (SELECT MBRN_PARENT_ADMIN_CODE
                    FROM MBRN
                   WHERE MBRN_CODE IN (SELECT MBRN_PARENT_ADMIN_CODE
                                         FROM MBRN
                                        WHERE MBRN_CODE = TT.MBRN_CODE))
                    "GMO_CODE",
                 LNACRS_REPH_ON_AMT
            FROM LNACRS, ACNTS, MBRN TT
           WHERE     LNACRS_ENTITY_NUM = 1
                 AND LNACRS_REPHASEMENT_ENTRY = '1'
                 AND LNACRS_PURPOSE = 'R'
                 AND LNACRS_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                 AND ACNTS_BRN_CODE = MBRN_CODE
                 AND ACNTS_ENTITY_NUM = 1
                 AND LNACRS_LATEST_EFF_DATE BETWEEN '01-DEC-2018'AND '29-DEC-2018' order by LNACRS_LATEST_EFF_DATE desc)
GROUP BY MBRN_CODE,
         MBRN_NAME,
         PO_CODE,
         GMO_CODE
         ORDER BY MBRN_CODE asc;
--------------
SELECT MBRN_CODE,
         MBRN_NAME,
         PO_CODE,
         (SELECT MBRN_NAME
            FROM MBRN
           WHERE MBRN_CODE = PO_CODE)
            PO_NAME,
         GMO_CODE,
         (SELECT MBRN_NAME
            FROM MBRN
           WHERE MBRN_CODE = GMO_CODE)
            GMO_NAME,
         SUM (LNACRS_REPH_ON_AMT) TOTAL_AMOUNT
    FROM (SELECT MBRN_CODE,
                 MBRN_NAME,
                 (SELECT MBRN_PARENT_ADMIN_CODE
                    FROM MBRN
                   WHERE MBRN_CODE = TT.MBRN_CODE)
                    "PO_CODE",
                 (SELECT MBRN_PARENT_ADMIN_CODE
                    FROM MBRN
                   WHERE MBRN_CODE IN (SELECT MBRN_PARENT_ADMIN_CODE
                                         FROM MBRN
                                        WHERE MBRN_CODE = TT.MBRN_CODE))
                    "GMO_CODE",
                 LNACRS_REPH_ON_AMT
            FROM LNACRS, ACNTS, MBRN TT
           WHERE     LNACRS_ENTITY_NUM = 1
                 AND LNACRS_REPHASEMENT_ENTRY = 1
                 AND LNACRS_PURPOSE = 'R'
                 AND LNACRS_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                 AND ACNTS_BRN_CODE = MBRN_CODE
                 AND ACNTS_ENTITY_NUM = 1
                 AND LNACRS_LATEST_EFF_DATE BETWEEN '01-JAN-2018'AND '29-DEC-2018')
GROUP BY MBRN_CODE,
         MBRN_NAME,
         PO_CODE,
         GMO_CODE
         ORDER BY MBRN_CODE;
         
         
         
---------------------------SHOSSO LOAN----------------------------------------------------------------
SELECT SUM (
          (SELECT NVL (ACBALH_BC_BAL, 0)
             FROM ACBALASONHIST A
            WHERE     A.ACBALH_ENTITY_NUM = 1
                  AND A.ACBALH_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                  AND A.ACBALH_ASON_DATE =
                         (SELECT MAX (ACBALH_ASON_DATE)
                            FROM ACBALASONHIST
                           WHERE     ACBALH_ENTITY_NUM = 1
                                 AND ACBALH_INTERNAL_ACNUM =
                                        ACNTS_INTERNAL_ACNUM
                                 AND ACBALH_ASON_DATE <= '29-DEC-2018')))
  FROM acnts, assetcls
 WHERE     ACNTS_INTERNAL_ACNUM = ASSETCLS_INTERNAL_ACNUM
       AND ASSETCLS_ENTITY_NUM = 1
       AND ASSETCLS_ASSET_CODE <> 'UC'
       AND ACNTS_PROD_CODE = 2501
       and ACNTS_CLOSURE_DATE is null
       and ACNTS_ENTITY_NUM=1;

-------INTEREST SUSPENSE BALANCE---------------------
  SELECT MBRN_CODE,
         MBRN_NAME,
         PO_CODE,
         (SELECT MBRN_NAME
            FROM MBRN
           WHERE MBRN_CODE = PO_CODE)
            PO_NAME,
         GMO_CODE,
         (SELECT MBRN_NAME
            FROM MBRN
           WHERE MBRN_CODE = GMO_CODE)
            GMO_NAME,
         SUM (GL_BALANCE) GL_BALANCE
    FROM (SELECT MBRN_CODE,
                 MBRN_NAME,
                 (SELECT MBRN_PARENT_ADMIN_CODE
                    FROM MBRN
                   WHERE MBRN_CODE = TT.MBRN_CODE)
                    "PO_CODE",
                 (SELECT MBRN_PARENT_ADMIN_CODE
                    FROM MBRN
                   WHERE MBRN_CODE IN (SELECT MBRN_PARENT_ADMIN_CODE
                                         FROM MBRN
                                        WHERE MBRN_CODE = TT.MBRN_CODE))
                    "GMO_CODE",
                 NVL (GLBBAL_BC_BAL, 0) GL_BALANCE
            FROM GLBBAL, MBRN TT
           WHERE     GLBBAL_ENTITY_NUM = 1
                 AND GLBBAL_GLACC_CODE = '140107101'
                 AND GLBBAL_YEAR = 2018
                 AND GLBBAL_BRANCH_CODE = MBRN_CODE
                 AND GLBBAL_BC_BAL <> 0)
GROUP BY MBRN_CODE,
         MBRN_NAME,
         PO_CODE,
         GMO_CODE
         ORDER BY MBRN_CODE;
-------------------------PROFIT LOSS BRANCH
SELECT M2.MBRN_PARENT_ADMIN_CODE GM_OFFICE_CODE,
(SELECT MM.MBRN_NAME FROM MBRN MM WHERE MM.MBRN_CODE = M2.MBRN_PARENT_ADMIN_CODE) GM_OFFICE, T2.* FROM 
( SELECT MBRN_PARENT_ADMIN_CODE CONTROLING_OFFICE_CODE,
       (SELECT M.MBRN_NAME
          FROM MBRN M
         WHERE M.MBRN_CODE = MBRN.MBRN_PARENT_ADMIN_CODE) CONTROLING_OFFICE,
       T1.*
  FROM (SELECT TEMP_DATA.RPT_BRN_CODE,
               TEMP_DATA.RPT_BRN_NAME,
               TEMP_DATA.TOTAL_INCOME_EXPENSE,
               CASE SIGN (TEMP_DATA.TOTAL_INCOME_EXPENSE)
                  WHEN 0 THEN 'NO INCOME EXPENSE'
                  WHEN 1 THEN 'Profit'
                  WHEN -1 THEN 'Loss'
               END PROFIT_LOASS
          FROM (  SELECT RPT_BRN_CODE,
                         RPT_BRN_NAME,
                         SUM (RPT_HEAD_CREDIT_BAL) + SUM (RPT_HEAD_DEBIT_BAL)
                            TOTAL_INCOME_EXPENSE
                    FROM INCOMEEXPENSE
                   WHERE RPT_ENTRY_DATE = :P_DATE ---'27-12-2018'
                GROUP BY RPT_BRN_CODE, RPT_BRN_NAME) TEMP_DATA
         WHERE TEMP_DATA.RPT_BRN_CODE IN (SELECT BRANCH_CODE FROM MIG_DETAIL)) T1,
       MBRN
 WHERE MBRN_CODE = T1.RPT_BRN_CODE) T2 , MBRN M2
 WHERE T2.CONTROLING_OFFICE_CODE = M2.MBRN_CODE
ORDER BY T2.RPT_BRN_CODE;