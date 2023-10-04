    SELECT DEPOSITE.ACNTS_BRN_CODE,(select m.mbrn_name from mbrn m where m.mbrn_code=DEPOSITE.ACNTS_BRN_CODE ) Branch_name,
         DEPOSITE.DEPOSIT_INTERNAL_ACNUM,
         DEPOSITE.DEPOSIT_BALANCE,
         loan.LOAN_INTERNAL_ACNUM,
         loan.LOAN_BALANCE
    FROM (  SELECT ACNTS_BRN_CODE,
                   COUNT (ACNTS_INTERNAL_ACNUM) DEPOSIT_INTERNAL_ACNUM,
                   SUM (NVL (FN_GET_ASON_ACBAL (1,
                                             ACNTS_INTERNAL_ACNUM,
                                             'BDT',
                                             '31-DEC-2017',
                                             '31-DEC-2017'),
                             0))
                      DEPOSIT_BALANCE
              FROM ACNTS, PRODUCTS
             WHERE     ACNTS_PROD_CODE = PRODUCT_CODE
                   -- AND ACNTS_INTERNAL_ACNUM = ACBALH_INTERNAL_ACNUM
                   AND PRODUCT_FOR_DEPOSITS = '1'
                  -- AND PRODUCT_FOR_RUN_ACS = '0'
                   AND ACNTS_ENTITY_NUM = 1
                   -- AND ACBALH_ENTITY_NUM = 1
                   AND ACNTS_OPENING_DATE <= '31-DEC-2017'
          --AND ACBALH_ASON_DATE <='31-DE-2017'
          GROUP BY ACNTS_BRN_CODE) DEPOSITE
         FULL OUTER JOIN
         (  SELECT ACNTS_BRN_CODE,
                   COUNT (ACNTS_INTERNAL_ACNUM) LOAN_INTERNAL_ACNUM,
                   SUM (NVL (FN_GET_ASON_ACBAL (1,
                                             ACNTS_INTERNAL_ACNUM,
                                             'BDT',
                                             '31-DEC-2017',
                                             '31-DEC-2017'),
                             0))
                      LOAN_BALANCE
              FROM ACNTS, PRODUCTS
             WHERE     ACNTS_PROD_CODE = PRODUCT_CODE
                  -- AND ACNTS_INTERNAL_ACNUM = ACBALH_INTERNAL_ACNUM
                   AND PRODUCT_FOR_LOANS = '1'
                   AND ACNTS_ENTITY_NUM = 1
                   --AND ACBALH_ENTITY_NUM = 1
                   AND ACNTS_OPENING_DATE <= '31-DEC-2017'
                   --AND ACBALH_ASON_DATE <= '31-DEC-2017'
          GROUP BY ACNTS_BRN_CODE) LOAN
            ON (DEPOSITE.ACNTS_BRN_CODE = LOAN.ACNTS_BRN_CODE)
ORDER BY LOAN.ACNTS_BRN_CODE;


-------------------income_expense-----------------
SELECT TEMP_DATA.RPT_BRN_CODE,
       TEMP_DATA.TOTAL_INCOME_EXPENSE,
       CASE SIGN (TEMP_DATA.TOTAL_INCOME_EXPENSE)
          WHEN 0 THEN 'NO INCOME EXPENSE'
          WHEN 1 THEN 'Profit'
          WHEN -1 THEN 'Loss'
       END
          PROFIT_LOSS
  FROM (  SELECT RPT_BRN_CODE,
                 SUM (RPT_HEAD_CREDIT_BAL) + SUM (RPT_HEAD_DEBIT_BAL)
                    TOTAL_INCOME_EXPENSE
            FROM INCOMEEXPENSE
           WHERE RPT_ENTRY_DATE = '31-MAR-2018'
        -- AND RPT_BRN_CODE <>18
        GROUP BY RPT_BRN_CODE) TEMP_DATA
 WHERE TOTAL_INCOME_EXPENSE <> 0;
 
  MBRN_LINK_SERV_MAIN_BRN
 
 
 --------------------------controlling office
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
                   WHERE RPT_ENTRY_DATE = :P_DATE
                GROUP BY RPT_BRN_CODE, RPT_BRN_NAME) TEMP_DATA
         WHERE TEMP_DATA.RPT_BRN_CODE IN (SELECT BRANCH_CODE FROM MIG_DETAIL)) T1,
       MBRN
 WHERE MBRN_CODE = T1.RPT_BRN_CODE) T2 , MBRN M2
 WHERE T2.CONTROLING_OFFICE_CODE = M2.MBRN_CODE
ORDER BY T2.RPT_BRN_CODE;



-------------------------------------------------
SELECT  GET_F12_CODE(ACNTS_GLACC_CODE) F12_CODE, 
       ACNTS_PROD_CODE,
       FN_BIS_GETINTEREST(ACNTS_INTERNAL_ACNUM) INTEREST_RATE,
       SUM (NVL (FN_GET_ASON_ACBAL (1,
                                    ACNTS_INTERNAL_ACNUM,
                                    'BDT',
                                    '1-JAN-2018',
                                    '1-JAN-2018'),
                 0))
          LOAN_BALANCE
  FROM  ACNTS,PRODUCTS
 WHERE  ACNTS_ENTITY_NUM = 1
 AND    ACNTS_PROD_CODE = PRODUCT_CODE
 AND    PRODUCT_FOR_LOANS =1
        AND ACNTS_BRN_CODE = 1065
GROUP BY GET_F12_CODE(ACNTS_GLACC_CODE),ACNTS_PROD_CODE, FN_BIS_GETINTEREST(ACNTS_INTERNAL_ACNUM)
ORDER BY ACNTS_PROD_CODE;



----------------------------LOANS--------------------------
SELECT ACNTS_BRN_CODE,
     MBRN_NAME,
     facno(1,ACNTS_INTERNAL_ACNUM) account_number,
     LOAN_TYPE,
     SANCTION_AMOUNT,
     OUTSTANDING_BALANCE
FROM (  SELECT /*+ PARALLEL( 8) */ACNTS_BRN_CODE,ACNTS_INTERNAL_ACNUM,
              
               CASE
                  WHEN PRODUCT_FOR_RUN_ACS = 0 THEN 'Term loan'
                  ELSE 'Continious Loan'
               END
                  LOAN_TYPE,
               NVL(SUM (LMTLINE_SANCTION_AMT),0) SANCTION_AMOUNT,
               SUM (
                  (SELECT NVL(ACBALH_BC_BAL,0)
                     FROM ACBALASONHIST A
                    WHERE     A.ACBALH_ENTITY_NUM = 1
                          AND A.ACBALH_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                          AND A.ACBALH_ASON_DATE =
                                 (SELECT MAX (ACBALH_ASON_DATE)
                                    FROM ACBALASONHIST
                                   WHERE     ACBALH_ENTITY_NUM = 1
                                         AND ACBALH_INTERNAL_ACNUM =
                                                ACNTS_INTERNAL_ACNUM
                                         AND ACBALH_ASON_DATE <=
                                                '31-JAN-2018')))
                  OUTSTANDING_BALANCE
               
          FROM ACNTS,
               PRODUCTS,
               LIMITLINE,
               ACASLLDTL,assetcls 
         WHERE     ACNTS_ENTITY_NUM = 1
               AND (   ACNTS_CLOSURE_DATE IS NULL
                    OR ACNTS_CLOSURE_DATE >= '31-JAN-2018')
               AND PRODUCT_CODE = ACNTS_PROD_CODE
               AND PRODUCT_FOR_LOANS = 1
               AND ACASLLDTL_ENTITY_NUM = 1
               AND ASSETCLS_ENTITY_NUM=1
               AND ASSETCLS_INTERNAL_ACNUM=ACNTS_INTERNAL_ACNUM
               AND ASSETCLS_ASSET_CODE='UC'
               AND LMTLINE_ENTITY_NUM = 1
               AND ACNTS_BRN_CODE = LMTLINE_HOME_BRANCH
               AND ACASLLDTL_CLIENT_NUM = LMTLINE_CLIENT_CODE
               AND LMTLINE_NUM = ACASLLDTL_LIMIT_LINE_NUM
               AND ACASLLDTL_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
               AND ACNTS_CLIENT_NUM = LMTLINE_CLIENT_CODE
                and ACNTS_BRN_CODE in(33068, 18259, 52019, 7054, 35121, 18044, 19133,  49122, 32011, 19158, 6130, 46045, 48116, 36137, 19117, 19166, 1024)
               AND ACNTS_CLOSURE_DATE IS NULL
               AND ACNTS_PROD_CODE NOT IN
                      (2101, 2102, 2103, 2104, 2105, 2106, 2107, 2108, 2109,2031,2042) -- Staff Loan
      GROUP BY ACNTS_BRN_CODE, PRODUCT_FOR_RUN_ACS,ACNTS_INTERNAL_ACNUM
      ORDER BY ACNTS_BRN_CODE, PRODUCT_FOR_RUN_ACS) A,
     MBRN
WHERE A.ACNTS_BRN_CODE = MBRN_CODE AND OUTSTANDING_BALANCE<>0 ;


-------------DATE_WISE-----------------
SELECT
     ACBALH_ASON_DATE,
     LOAN_TYPE,
    SUM( SANCTION_AMOUNT) SANCTION_AMOUNT,
     SUM(OUTSTANDING_BALANCE) OUTSTANDING_BALANCE
FROM (  SELECT /*+ PARALLEL( 8) */ACNTS_INTERNAL_ACNUM,
              
               CASE
                  WHEN PRODUCT_FOR_RUN_ACS = 0 THEN 'Term loan'
                  ELSE 'Continious Loan'
               END
                  LOAN_TYPE,
               NVL(SUM (LMTLINE_SANCTION_AMT),0) SANCTION_AMOUNT,
               SUM (
                  (SELECT NVL(ACBALH_BC_BAL,0)
                     FROM ACBALASONHIST A
                    WHERE     A.ACBALH_ENTITY_NUM = 1
                          AND A.ACBALH_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                          AND A.ACBALH_ASON_DATE =
                                 (SELECT MAX (ACBALH_ASON_DATE)
                                    FROM ACBALASONHIST
                                   WHERE     ACBALH_ENTITY_NUM = 1
                                         AND ACBALH_INTERNAL_ACNUM =
                                                ACNTS_INTERNAL_ACNUM
                                         AND ACBALH_ASON_DATE <=
                                                '30-APR-2018')))
                  OUTSTANDING_BALANCE
               
          FROM ACNTS,
               PRODUCTS,
               LIMITLINE,
               ACASLLDTL,assetcls 
         WHERE     ACNTS_ENTITY_NUM = 1
               AND (   ACNTS_CLOSURE_DATE IS NULL
                    OR ACNTS_CLOSURE_DATE >= '30-APR-2018')
               AND PRODUCT_CODE = ACNTS_PROD_CODE
               AND PRODUCT_FOR_LOANS = 1
               AND ACASLLDTL_ENTITY_NUM = 1
               AND ASSETCLS_ENTITY_NUM=1
               AND ASSETCLS_INTERNAL_ACNUM=ACNTS_INTERNAL_ACNUM
               AND ASSETCLS_ASSET_CODE='UC'
               AND LMTLINE_ENTITY_NUM = 1
               AND ACNTS_BRN_CODE = LMTLINE_HOME_BRANCH
               AND ACASLLDTL_CLIENT_NUM = LMTLINE_CLIENT_CODE
               AND LMTLINE_NUM = ACASLLDTL_LIMIT_LINE_NUM
               AND ACASLLDTL_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
               AND ACNTS_CLIENT_NUM = LMTLINE_CLIENT_CODE
              --  and ACNTS_BRN_CODE in(33068, 18259, 52019, 7054, 35121, 18044, 19133,  49122, 32011, 19158, 6130, 46045, 48116, 36137, 19117, 19166, 1024)
               AND ACNTS_CLOSURE_DATE IS NULL
               AND ACNTS_PROD_CODE NOT IN
                       (2101, 2102, 2103, 2104, 2105, 2106, 2107, 2108, 2109,2031,2042) -- Staff Loan
      GROUP BY  PRODUCT_FOR_RUN_ACS,ACNTS_INTERNAL_ACNUM
      ORDER BY  PRODUCT_FOR_RUN_ACS) A,
     ACBALASONHIST
WHERE  OUTSTANDING_BALANCE<>0 
and a.ACNTS_INTERNAL_ACNUM=ACBALH_INTERNAL_ACNUM
and ACBALH_ASON_DATE between '01-APR-2018' AND '30-APR-2018'
group by ACBALH_ASON_DATE,     LOAN_TYPE
ORDER BY ACBALH_ASON_DATE;