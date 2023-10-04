/* Formatted on 9/26/2021 5:42:01 PM (QP5 v5.149.1003.31008) */
  SELECT M2.MBRN_PARENT_ADMIN_CODE GM_OFFICE_CODE,
         (SELECT MM.MBRN_NAME
            FROM MBRN MM
           WHERE MM.MBRN_CODE = M2.MBRN_PARENT_ADMIN_CODE)
            GM_OFFICE,
         T2.*
    FROM (SELECT MBRN_PARENT_ADMIN_CODE CONTROLING_OFFICE_CODE,
                 (SELECT M.MBRN_NAME
                    FROM MBRN M
                   WHERE M.MBRN_CODE = MBRN.MBRN_PARENT_ADMIN_CODE)
                    CONTROLING_OFFICE,
                 T1.*
            FROM (SELECT TEMP_DATA.RPT_BRN_CODE,
                         TEMP_DATA.RPT_BRN_NAME,
                         TEMP_DATA.TOTAL_INCOME_EXPENSE,
                         CASE SIGN (TEMP_DATA.TOTAL_INCOME_EXPENSE)
                            WHEN 0 THEN 'NO INCOME EXPENSE'
                            WHEN 1 THEN 'Profit'
                            WHEN -1 THEN 'Loss'
                         END
                            PROFIT_LOASS
                    FROM (  SELECT RPT_BRN_CODE,
                                   RPT_BRN_NAME,
                                   SUM (RPT_HEAD_CREDIT_BAL)
                                   + SUM (RPT_HEAD_DEBIT_BAL)
                                      TOTAL_INCOME_EXPENSE
                              FROM INCOMEEXPENSE
                             WHERE RPT_ENTRY_DATE = :P_DATE    ---'27-12-2018'
                          GROUP BY RPT_BRN_CODE, RPT_BRN_NAME) TEMP_DATA
                   WHERE TEMP_DATA.RPT_BRN_CODE IN
                            (SELECT BRANCH_CODE FROM MIG_DETAIL)) T1,
                 MBRN
           WHERE MBRN_CODE = T1.RPT_BRN_CODE) T2,
         MBRN M2
   WHERE T2.CONTROLING_OFFICE_CODE = M2.MBRN_CODE
ORDER BY T2.RPT_BRN_CODE;



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
       TT.*
  FROM (SELECT TEMP_DATA.RPT_BRN_CODE,
               TEMP_DATA.RPT_BRN_NAME,
               TEMP_DATA.TOTAL_INCOME_EXPENSE,
               CASE SIGN (TEMP_DATA.TOTAL_INCOME_EXPENSE)
                  WHEN 0 THEN 'NO INCOME EXPENSE'
                  WHEN 1 THEN 'Profit'
                  WHEN -1 THEN 'Loss'
               END
                  PROFIT_LOASS
          FROM (  SELECT RPT_BRN_CODE,
                         RPT_BRN_NAME,
                         SUM (RPT_HEAD_CREDIT_BAL) + SUM (RPT_HEAD_DEBIT_BAL)
                            TOTAL_INCOME_EXPENSE
                    FROM INCOMEEXPENSE
                   WHERE RPT_ENTRY_DATE = :P_DATE              ---'27-12-2018'
                GROUP BY RPT_BRN_CODE, RPT_BRN_NAME) TEMP_DATA
         WHERE TEMP_DATA.RPT_BRN_CODE IN (SELECT BRANCH_CODE FROM MIG_DETAIL)) TT,
       MBRN_TREE1
 WHERE TT.RPT_BRN_CODE = BRANCH;

------------------------------------------BISINESS POSITION-------------------------

SELECT RPT_BRN_CODE,
       RPT_BRN_NAME,
       TOTAL_INCOME_EXPENSE,
       (SELECT SUM (RPT_HEAD_BAL)
          FROM INCOMEEXPENSE
         WHERE     RPT_ENTRY_DATE = :P_DATE
               AND CASHTYPE = '1'
               AND RPT_BRN_CODE = A.RPT_BRN_CODE
               AND RPT_HEAD_CODE IN
                      (SELECT RPTHDTHDDTL_HEAD_CODE
                         FROM RPTHEADTHDDTL
                        WHERE RPTHDTHDDTL_TOTAL_HEAD_CODE = '42TA'))
          "Int Income from Loans Advances",
       (FN_F12_HEAD_BAL (A.RPT_BRN_CODE,
                         :P_DATE,
                         'I0126',
                         'F42B'))
          "Interest Income from SBG",
       (SELECT SUM (RPT_HEAD_BAL)
          FROM INCOMEEXPENSE
         WHERE     RPT_ENTRY_DATE = :P_DATE
               AND CASHTYPE = '1'
               AND RPT_BRN_CODE = A.RPT_BRN_CODE
               AND RPT_HEAD_CODE IN
                      (SELECT RPTHDTHDDTL_HEAD_CODE
                         FROM RPTHEADTHDDTL
                        WHERE RPTHDTHDDTL_TOTAL_HEAD_CODE IN
                                 ('42AT', '42TD', '42TE', '42ITT', '42TG')))
          "Other Income",
       (SELECT SUM (RPT_HEAD_BAL)
          FROM INCOMEEXPENSE
         WHERE     RPT_ENTRY_DATE = :P_DATE
               AND CASHTYPE = '1'
               AND RPT_BRN_CODE = A.RPT_BRN_CODE
               AND RPT_HEAD_CODE IN
                      (SELECT RPTHDTHDDTL_HEAD_CODE
                         FROM RPTHEADTHDDTL
                        WHERE RPTHDTHDDTL_TOTAL_HEAD_CODE = 'F42CTI'))
          "Total Income",
       (SELECT SUM (RPT_HEAD_BAL)
          FROM INCOMEEXPENSE
         WHERE     RPT_ENTRY_DATE = :P_DATE
               AND CASHTYPE = '1'
               AND RPT_BRN_CODE = A.RPT_BRN_CODE
               AND RPT_HEAD_CODE IN
                      (SELECT RPTHDTHDDTL_HEAD_CODE
                         FROM RPTHEADTHDDTL
                        WHERE RPTHDTHDDTL_TOTAL_HEAD_CODE = '42TH1'))
          "Interest Expenses on Deposit",
       (FN_F12_HEAD_BAL (A.RPT_BRN_CODE,
                         :P_DATE,
                         'E1110',
                         'F42B'))
          "Interest Expenses on SBG",
       (FN_F12_HEAD_BAL (A.RPT_BRN_CODE,
                         :P_DATE,
                         'E1120',
                         'F42B'))
          "Rent Expenses",
       (SELECT SUM (RPT_HEAD_BAL)
          FROM INCOMEEXPENSE
         WHERE     RPT_ENTRY_DATE = :P_DATE
               AND CASHTYPE = '1'
               AND RPT_BRN_CODE = A.RPT_BRN_CODE
               AND RPT_HEAD_CODE IN
                      (SELECT RPTHDTHDDTL_HEAD_CODE
                         FROM RPTHEADTHDDTL
                        WHERE RPTHDTHDDTL_TOTAL_HEAD_CODE = '42TK'))
          BALANCE_ON_42TK,
       (SELECT SUM (RPT_HEAD_BAL)
          FROM INCOMEEXPENSE
         WHERE     RPT_ENTRY_DATE = :P_DATE
               AND CASHTYPE = '1'
               AND RPT_BRN_CODE = A.RPT_BRN_CODE
               AND RPT_HEAD_CODE IN
                      (SELECT RPTHDTHDDTL_HEAD_CODE
                         FROM RPTHEADTHDDTL
                        WHERE RPTHDTHDDTL_TOTAL_HEAD_CODE IN
                                 ('42TH2', '42TTEX', '42TL')))
          "Other Expenses",
       (SELECT SUM (RPT_HEAD_BAL)
          FROM INCOMEEXPENSE
         WHERE     RPT_ENTRY_DATE = :P_DATE
               AND CASHTYPE = '1'
               AND RPT_BRN_CODE = A.RPT_BRN_CODE
               AND RPT_HEAD_CODE IN
                      (SELECT RPTHDTHDDTL_HEAD_CODE
                         FROM RPTHEADTHDDTL
                        WHERE RPTHDTHDDTL_TOTAL_HEAD_CODE = 'F42CTEB'))
          "Total Expenses",
       (SELECT COUNT (USER_ID)
          FROM users
         WHERE TRIM (USER_SUSP_REL_FLAG) IS NULL
               AND USER_BRANCH_CODE = A.RPT_BRN_CODE)
          "Total Number of Employee",
       0 "Profit or Loss Per Employee",
       (SELECT SUM (RPT_HEAD_BAL)
          FROM statmentofaffairs
         WHERE     RPT_ENTRY_DATE = :P_DATE
               AND CASHTYPE = '1'
               AND RPT_BRN_CODE = A.RPT_BRN_CODE
               AND RPT_HEAD_CODE IN
                      (SELECT RPTHDTHDDTL_HEAD_CODE
                         FROM RPTHEADTHDDTL
                        WHERE RPTHDTHDDTL_TOTAL_HEAD_CODE IN ('ABC', 'TD')))
          "Total Deposit",
       0 "Deposit Per Employee",
       (SELECT SUM (RPT_HEAD_BAL)
          FROM statmentofaffairs
         WHERE     RPT_ENTRY_DATE = :P_DATE
               AND CASHTYPE = '1'
               AND RPT_BRN_CODE = A.RPT_BRN_CODE
               AND RPT_HEAD_CODE IN
                      (SELECT RPTHDTHDDTL_HEAD_CODE
                         FROM RPTHEADTHDDTL
                        WHERE RPTHDTHDDTL_TOTAL_HEAD_CODE = 'TK'))
          "Total Loans Advances",
       (SELECT SUM (RPT_HEAD_BAL)
          FROM statmentofaffairs
         WHERE     RPT_ENTRY_DATE = :P_DATE
               AND CASHTYPE = '1'
               AND RPT_BRN_CODE = A.RPT_BRN_CODE
               AND RPT_HEAD_CODE IN
                      (SELECT RPTHDTHDDTL_HEAD_CODE
                         FROM RPTHEADTHDDTL
                        WHERE RPTHDTHDDTL_TOTAL_HEAD_CODE = 'TK'))
       - (SELECT SUM (RPT_HEAD_BAL)
            FROM statmentofaffairs
           WHERE     RPT_ENTRY_DATE = :P_DATE
                 AND CASHTYPE = '1'
                 AND RPT_BRN_CODE = A.RPT_BRN_CODE
                 AND RPT_HEAD_CODE IN ('A0307', 'A0308'))
          "Total advance without staff",
       0 "Loans  Advances Per Employee",
       (SELECT SUM (RPT_HEAD_BAL)
          FROM statmentofaffairs
         WHERE     RPT_ENTRY_DATE = :P_DATE
               AND CASHTYPE = '1'
               AND RPT_BRN_CODE = A.RPT_BRN_CODE
               AND RPT_HEAD_CODE IN
                      ('L2101',
                       'L2103',
                       'L2105',
                       'L2106',
                       'L2107',
                       'L2110',
                       'L2111',
                       'L2112',
                       'L2607',
                       'L3013'))
       + (SELECT SUM (RPT_HEAD_BAL)
            FROM statmentofaffairs
           WHERE     RPT_ENTRY_DATE = :P_DATE
                 AND CASHTYPE = '1'
                 AND RPT_BRN_CODE = A.RPT_BRN_CODE
                 AND RPT_HEAD_CODE IN
                        (SELECT RPTHDTHDDTL_HEAD_CODE
                           FROM RPTHEADTHDDTL
                          WHERE RPTHDTHDDTL_TOTAL_HEAD_CODE = 'TD'))
          "No cost Deposit",
       0 "No costDeposit % on Tot Dep",
       (SELECT SUM (RPT_HEAD_BAL)
          FROM statmentofaffairs
         WHERE     RPT_ENTRY_DATE = :P_DATE
               AND CASHTYPE = '1'
               AND RPT_BRN_CODE = A.RPT_BRN_CODE
               AND RPT_HEAD_CODE IN ('L2002', 'L2005', 'L2102', 'L2119'))
          "Low cost Deposit",
       0 "Low cost Dep % on Total Dep",
       (SELECT SUM (RPT_HEAD_BAL)
          FROM statmentofaffairs
         WHERE     RPT_ENTRY_DATE = :P_DATE
               AND CASHTYPE = '1'
               AND RPT_BRN_CODE = A.RPT_BRN_CODE
               AND RPT_HEAD_CODE IN
                      ('L2001',
                       'L2003',
                       'L2004',
                       'L2006',
                       'L2008',
                       'L2009',
                       'L2010',
                       'L2011',
                       'L2012',
                       'L2013',
                       'L2014',
                       'L2015',
                       'L2016',
                       'L2017',
                       'L2018',
                       'L2019',
                       'L2020',
                       'L2021',
                       'L2022',
                       'L2024',
                       'L2113',
                       'L2114'))
          "High Cost Deposit",
       0 "High cost Dep % on tot Dep",
       (SELECT SUM (ABS (ACBAL))
          FROM CL_TMP_DATA
         WHERE     ACNTS_BRN_CODE = A.RPT_BRN_CODE
               AND ASSETCD_ASSET_CLASS = 'N'
               AND ASON_DATE = :P_DATE)
          "Total CL Amount",
       0 "% of CL"
  FROM (  SELECT RPT_BRN_CODE,
                 RPT_BRN_NAME,
                 SUM (RPT_HEAD_CREDIT_BAL) + SUM (RPT_HEAD_DEBIT_BAL)
                    TOTAL_INCOME_EXPENSE
            FROM INCOMEEXPENSE
           WHERE RPT_ENTRY_DATE = :P_DATE
                 AND RPT_BRN_CODE IN (SELECT mbrn_code FROM mbrn)
        GROUP BY RPT_BRN_CODE, RPT_BRN_NAME) A