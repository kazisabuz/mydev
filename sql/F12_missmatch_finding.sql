/* Formatted on 6/30/2022 8:27:58 PM (QP5 v5.252.13127.32867) */
  SELECT  /*+ PARALLEL( 16) */ RPT_BRN_CODE,
         SUM (NVL (RPT_HEAD_CREDIT_BAL, 0) + NVL (RPT_HEAD_DEBIT_BAL, 0)),
         CASHTYPE
    FROM STATMENTOFAFFAIRS  
   WHERE     RPT_ENTRY_DATE = '30-sep-2023'
         AND NVL (RPT_HEAD_CREDIT_BAL, 0) + NVL (RPT_HEAD_DEBIT_BAL, 0) <> 0
GROUP BY RPT_BRN_CODE, CASHTYPE
  HAVING SUM (NVL (RPT_HEAD_CREDIT_BAL, 0) + NVL (RPT_HEAD_DEBIT_BAL, 0)) <>
            0
ORDER BY ABS (
            SUM (NVL (RPT_HEAD_CREDIT_BAL, 0) + NVL (RPT_HEAD_DEBIT_BAL, 0)));

---35139
210125101
116101101

 
---------- Start of the mismatch--------

  SELECT RPT_ENTRY_DATE,
         SUM (NVL (RPT_HEAD_CREDIT_BAL, 0) + NVL (RPT_HEAD_DEBIT_BAL, 0))
    FROM STATMENTOFAFFAIRS
   WHERE RPT_BRN_CODE = 20032
GROUP BY RPT_ENTRY_DATE
ORDER BY RPT_ENTRY_DATE DESC;   ---9713

1.

SELECT ACNTS_BRN_CODE,
       ACNTS_PROD_CODE,ACNTS_INTERNAL_ACNUM,
       FACNO (1, ACNTS_INTERNAL_ACNUM) AC_NUM,
       ACNTBAL_BC_BAL,
       ACNTS_CLOSURE_DATE
  FROM ACNTS, ACNTBAL
 WHERE     ACNTS_ENTITY_NUM = 1
       AND ACNTS_BRN_CODE    =20032
       AND ACNTS_CLOSURE_DATE IS NOT NULL
       AND ACNTBAL_ENTITY_NUM = 1
       AND ACNTBAL_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
       AND ACNTBAL_BC_BAL <> 0;





2.

/* Formatted on 9/30/2022 5:59:31 PM (QP5 v5.388) */
SELECT GLBBAL_BRANCH_CODE, GLBBAL_GLACC_CODE, GLBBAL_BC_BAL
  FROM GLBBAL
 WHERE     GLBBAL_ENTITY_NUM = 1
       AND GLBBAL_BRANCH_CODE = 20032
       AND GLBBAL_YEAR = 2023
       AND ABS (GLBBAL_BC_BAL) = 2000;
 
SELECT GLBALH_BRN_CODE, GLBALH_GLACC_CODE, GLBALH_BC_BAL
  FROM GLBALASONHIST
 WHERE     GLBALH_ENTITY_NUM = 1
       AND GLBALH_BRN_CODE = 18
       AND GLBALH_ASON_DATE = '01-jan-2022'
       AND ABS (GLBALH_BC_BAL) = 5594041.05;
       
       
select ACBALH_INTERNAL_ACNUM,ACBALH_BC_BAL from acnts,acbalasonhist
where ACBALH_ENTITY_NUM=1
and ACNTS_ENTITY_NUM=1
and  ACBALH_INTERNAL_ACNUM=ACNTS_INTERNAL_ACNUM
and ACNTS_BRN_CODE=18168
and  ACBALH_ASON_DATE='31-mar-2023'
AND ABS(ACBALH_BC_BAL)=99944.45;



SELECT ACNTS_INTERNAL_ACNUM,
       ACNTS_PROD_CODE,
       ACNTS_AC_TYPE,
       ACNTBAL_BC_BAL,
       ACNTS_CLOSURE_DATE
  FROM ACNTS, ACNTBAL
 WHERE     ACNTS_ENTITY_NUM = 1
       AND ACNTS_BRN_CODE = 20032 
       AND ACNTBAL_ENTITY_NUM = 1
       AND ACNTBAL_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
       AND ABS (ACNTBAL_BC_BAL) =  2000;
-----------------------------------------
/* Formatted on 11/7/2022 6:05:59 PM (QP5 v5.388) */
/* Formatted on 7/31/2023 6:16:49 PM (QP5 v5.388) */
SELECT ACNTS_BRN_CODE,
       ACNTS_INTERNAL_ACNUM,
       FACNO (1, ACNTS_INTERNAL_ACNUM)      ACCOUNT_NO,
       PRODUCT_CODE,
       FN_GET_ASON_ACBAL (1,
                          ACNTS_INTERNAL_ACNUM,
                          'BDT',
                          '30-sep-2023',
                          '30-sep-2023')    ACBAL,
       LNACMIS_NATURE_BORROWAL_AC           SME_CODE
  FROM ACNTS, PRODUCTS, LNACMIS
 WHERE     ACNTS_ENTITY_NUM = 1                       --27905730.9  27905730.9
       AND ACNTS_BRN_CODE = 20032
       AND ACNTS_PROD_CODE = PRODUCT_CODE
       AND PRODUCT_FOR_LOANS = 1
       AND LNACMIS_LATEST_EFF_DATE >= '31-aug-2023'
       AND LNACMIS_ENTITY_NUM = 1
       -- AND TRIM(LNACMIS_NATURE_BORROWAL_AC) IS NULL
       --AND PRODUCT_CODE >= 3000
       AND LNACMIS_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM;
-----------MIS CODE MISMATCH--------------------
/* Formatted on 5/3/2023 12:57:50 PM (QP5 v5.388) */
SELECT ACNTS_PROD_CODE,
       ACNTS_AC_TYPE,
       ACNTS_INTERNAL_ACNUM,
       FN_GET_ASON_ACBAL (1,
                          ACNTS_INTERNAL_ACNUM,
                          'BDT',
                          '29-sep-2023',
                          '30-sep-2023') ACCBAL
  FROM products, acnts
 WHERE     ACNTS_ENTITY_NUM = 1
       AND ACNTS_PROD_CODE = PRODUCT_CODE
       AND PRODUCT_FOR_LOANS = 1
       AND ACNTS_BRN_CODE = 46177
       -- AND ACNTS_OPENING_DATE >= '12-jan-2023'
       AND ACNTS_INTERNAL_ACNUM NOT IN (SELECT LNACMIS_INTERNAL_ACNUM
                                          FROM LNACMIS
                                         WHERE LNACMIS_ENTITY_NUM = 1);

/* Formatted on 5/3/2023 12:58:00 PM (QP5 v5.388) */
SELECT ACNTS_BRN_CODE,
       ACNTS_INTERNAL_ACNUM,
       ACNTS_PROD_CODE,
       FACNO (1, ACNTS_INTERNAL_ACNUM)                              AC_NUM,
       FN_BIS_GET_ASON_ACBAL (1,
                              ACNTS_INTERNAL_ACNUM,
                              'BDT',
                              '30-sep-2023',
                              '30-sep-2023')                        AC_BAL,
       (SELECT LNACMIS_NATURE_BORROWAL_AC
         FROM LNACMIS
        WHERE     LNACMIS_ENTITY_NUM = 1
              AND LNACMIS_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM)    SME_NONSME_CODE
  FROM ACNTS
 WHERE     ACNTS_ENTITY_NUM = 1
       AND ACNTS_BRN_CODE IN (46177)
       AND ACNTS_GLACC_CODE IN (SELECT RPTHDGLDTL_GLACC_CODE
                                  FROM RPTHEADGLDTL
                                 WHERE RPTHDGLDTL_ACNT_PARTIAL_SEL = '1')
       AND FN_BIS_GET_ASON_ACBAL (1,
                                  ACNTS_INTERNAL_ACNUM,
                                  'BDT',
                                  '30-sep-2023',
                                  '30-sep-2023') < 0
       AND (SELECT LNACMIS_NATURE_BORROWAL_AC
             FROM LNACMIS
            WHERE     LNACMIS_ENTITY_NUM = 1
                  AND LNACMIS_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM) NOT IN
               (SELECT RPTGRPIL_DTL_CODE
                  FROM RPTGRPIL
                 WHERE RPTGRPIL_GROUP_TYPE = 'M');


/* Formatted on 5/3/2023 12:58:36 PM (QP5 v5.388) */
SELECT DISTINCT ACNTS_BRN_CODE,
                ACNTS_INTERNAL_ACNUM,
                facno (1, ACNTS_INTERNAL_ACNUM)      account_no,
                ACNTS_PROD_CODE,
                ACNTS_AC_TYPE,
                ACNTS_AC_SUB_TYPE,
                LNACMISh_NATURE_BORROWAL_AC          SME_NONSME_CODE,
                FN_GET_ASON_ACBAL (1,
                                   ACNTS_INTERNAL_ACNUM,
                                   'BDT',
                                   '29-sep-2023',
                                   '30-sep-2023')    AC_BAL
  FROM acnts, lnacmishist
 WHERE     LNACMISh_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
       AND ACNTS_ENTITY_NUM = 1
       AND ACNTS_BRN_CODE = 46177
  and LNACMISH_EFF_DATE>='31-aug-2023';
--AND ACNTS_PROD_CODE IN (3003,3005);
--AND ACNTS_OPENING_DATE > ='30-SEP-2022';

3. check any account that have the difference amount.

4. check all the accounts from tran table and acntbal table .

-------------insert query--------------

SELECT RPT_BRN_CODE,
       RPT_BRN_NAME,
       TRUNC (SYSDATE) - 1,
       RPT_HEAD_DESCN,
       RPT_HEAD_SHORT_DESCN,
       RPT_HEAD_CODE,
       RPT_HEAD_CREDIT_BAL,
       RPT_HEAD_DEBIT_BAL,
       PRINT_BOLD,
       RPT_DEPOSITS,
       RPT_ADVANCES,
       RPT_INT_SUSPENSE,
       RPT_BILLS_PAYABLE,
       RPTHEAD_CLASSIFICATION,
       RPT_HEAD_BAL,
       RPT_HEAD_SL,
       RPT_SUB_TOT,
       SYSDATE,
       'F12'
  FROM TABLE (PKG_STATEMENT_OF_AFFAIRS_F12.GET_ASSETS_LIABILITIES (
                 'F12',
                 1,
                 --BRN.MBRN_CODE,
                 20032,
                 '29-sep-2023',
                 1))
 WHERE RPT_BRN_CODE <> 0;

----------------------------------------------------------
--- Accounts balance mismatch make sure all tran table include in script--------

SELECT *
  FROM (SELECT TRAN_BASE_CURR_CODE,
               TRAN_INTERNAL_ACNUM,
               CREDIT_AMT - DEBIT_AMT TRAN_BALANCE
          FROM (  SELECT TRAN_INTERNAL_ACNUM,
                         TRAN_BASE_CURR_CODE,
                         SUM (
                            CASE
                               WHEN TRAN_DB_CR_FLG = 'C' THEN TRAN_AMOUNT
                               ELSE 0
                            END)
                            CREDIT_AMT,
                         SUM (
                            CASE
                               WHEN TRAN_DB_CR_FLG = 'D' THEN TRAN_AMOUNT
                               ELSE 0
                            END)
                            DEBIT_AMT
                    FROM (SELECT *
                            FROM TRAN2014
                           WHERE     TRAN_ENTITY_NUM = 1
                                 AND TRAN_ACING_BRN_CODE = 49130
                                 AND TRAN_INTERNAL_ACNUM <> 0
                                 --AND TRAN_INTERNAL_ACNUM = 13613700001618
                                 AND TRAN_AUTH_ON IS NOT NULL
                          UNION ALL
                          SELECT *
                            FROM TRAN2015
                           WHERE     TRAN_ENTITY_NUM = 1
                                 AND TRAN_ACING_BRN_CODE = 49130
                                 AND TRAN_INTERNAL_ACNUM <> 0
                                 --AND TRAN_INTERNAL_ACNUM = 13613700001618
                                 AND TRAN_AUTH_ON IS NOT NULL
                          UNION ALL
                          SELECT *
                            FROM TRAN2016
                           WHERE     TRAN_ENTITY_NUM = 1
                                 AND TRAN_ACING_BRN_CODE = 49130
                                 AND TRAN_INTERNAL_ACNUM <> 0
                                 --AND TRAN_INTERNAL_ACNUM = 13613700001618
                                 AND TRAN_AUTH_ON IS NOT NULL
                          UNION ALL
                          SELECT *
                            FROM TRAN2017
                           WHERE     TRAN_ENTITY_NUM = 1
                                 AND TRAN_ACING_BRN_CODE = 49130
                                 AND TRAN_INTERNAL_ACNUM <> 0
                                 --AND TRAN_INTERNAL_ACNUM = 13613700001618
                                 AND TRAN_AUTH_ON IS NOT NULL
                          UNION ALL
                          SELECT *
                            FROM TRAN2018
                           WHERE     TRAN_ENTITY_NUM = 1
                                 AND TRAN_ACING_BRN_CODE = 49130
                                 AND TRAN_INTERNAL_ACNUM <> 0
                                 --AND TRAN_INTERNAL_ACNUM = 13613700001618
                                 AND TRAN_AUTH_ON IS NOT NULL
                          UNION ALL
                          SELECT *
                            FROM TRAN2019
                           WHERE     TRAN_ENTITY_NUM = 1
                                 AND TRAN_ACING_BRN_CODE = 49130
                                 AND TRAN_INTERNAL_ACNUM <> 0
                                 --AND TRAN_INTERNAL_ACNUM = 13613700001618
                                 AND TRAN_AUTH_ON IS NOT NULL
                          UNION ALL
                          SELECT *
                            FROM TRAN2020
                           WHERE     TRAN_ENTITY_NUM = 1
                                 AND TRAN_ACING_BRN_CODE = 49130
                                 AND TRAN_INTERNAL_ACNUM <> 0
                                 --AND TRAN_INTERNAL_ACNUM = 13613700001618
                                 AND TRAN_AUTH_ON IS NOT NULL
                          UNION ALL
                          SELECT *
                            FROM TRAN2021
                           WHERE     TRAN_ENTITY_NUM = 1
                                 AND TRAN_ACING_BRN_CODE = 49130
                                 AND TRAN_INTERNAL_ACNUM <> 0
                                 --AND TRAN_INTERNAL_ACNUM = 13613700001618
                                 AND TRAN_AUTH_ON IS NOT NULL
                          UNION ALL
                          SELECT *
                            FROM TRAN2022
                           WHERE     TRAN_ENTITY_NUM = 1
                                 AND TRAN_ACING_BRN_CODE = 49130
                                 AND TRAN_INTERNAL_ACNUM <> 0
                                 --AND TRAN_INTERNAL_ACNUM = 13613700001618
                                 AND TRAN_AUTH_ON IS NOT NULL
                                  UNION ALL
                          SELECT *
                            FROM TRAN2023
                           WHERE     TRAN_ENTITY_NUM = 1
                                 AND TRAN_ACING_BRN_CODE = 49130
                                 AND TRAN_INTERNAL_ACNUM <> 0
                                 --AND TRAN_INTERNAL_ACNUM = 13613700001618
                                 AND TRAN_AUTH_ON IS NOT NULL)
                GROUP BY TRAN_INTERNAL_ACNUM, TRAN_BASE_CURR_CODE)) A,
       (SELECT ACNTS_INTERNAL_ACNUM, ACNTBAL_CURR_CODE, ACNTBAL_BC_BAL
          FROM ACNTS, ACNTBAL
         WHERE     ACNTS_ENTITY_NUM = 1
               AND ACNTS_BRN_CODE = 49130
               AND ACNTS_CLOSURE_DATE IS NULL
               AND ACNTBAL_ENTITY_NUM = 1
               AND ACNTBAL_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
               --  AND ACNTBAL_CURR_CODE = 'BDT'
               AND ACNTBAL_BC_BAL <> 0) B
 WHERE     A.TRAN_INTERNAL_ACNUM = B.ACNTS_INTERNAL_ACNUM
       AND TRAN_BASE_CURR_CODE = ACNTBAL_CURR_CODE
       AND A.TRAN_BALANCE <> B.ACNTBAL_BC_BAL;



------ GL balance mismatch make sure all tran table include in script---------------

SELECT A.TRAN_BASE_CURR_CODE,
       A.TRAN_GLACC_CODE,
       A.TRAN_BALANCE,
       B.GLBBAL_BC_BAL,
       A.TRAN_BALANCE - B.GLBBAL_BC_BAL
  FROM (SELECT TRAN_BASE_CURR_CODE,
               TRAN_GLACC_CODE,
               CREDIT_AMT - DEBIT_AMT TRAN_BALANCE
          FROM (  SELECT TRAN_BASE_CURR_CODE,
                         TRAN_GLACC_CODE,
                         SUM (
                            CASE
                               WHEN TRAN_DB_CR_FLG = 'C'
                               THEN
                                  TRAN_BASE_CURR_EQ_AMT
                               ELSE
                                  0
                            END)
                            CREDIT_AMT,
                         SUM (
                            CASE
                               WHEN TRAN_DB_CR_FLG = 'D'
                               THEN
                                  TRAN_BASE_CURR_EQ_AMT
                               ELSE
                                  0
                            END)
                            DEBIT_AMT
                    FROM (SELECT *
                            FROM TRAN2014
                           WHERE     TRAN_ENTITY_NUM = 1
                                 AND TRAN_ACING_BRN_CODE = 49130
                                -- AND TRAN_CURR_CODE = 'BDT'
                                 AND TRAN_AUTH_ON IS NOT NULL
                          UNION ALL
                          SELECT *
                            FROM TRAN2015
                           WHERE     TRAN_ENTITY_NUM = 1
                                 AND TRAN_ACING_BRN_CODE = 49130
                               --  AND TRAN_CURR_CODE = 'BDT'
                                 AND TRAN_AUTH_ON IS NOT NULL
                          UNION ALL
                          SELECT *
                            FROM TRAN2016
                           WHERE     TRAN_ENTITY_NUM = 1
                                 AND TRAN_ACING_BRN_CODE = 49130
                                -- AND TRAN_CURR_CODE = 'BDT'
                                 AND TRAN_AUTH_ON IS NOT NULL
                          UNION ALL
                          SELECT *
                            FROM TRAN2017
                           WHERE     TRAN_ENTITY_NUM = 1
                                 AND TRAN_ACING_BRN_CODE = 49130
                               --  AND TRAN_CURR_CODE = 'BDT'
                                 AND TRAN_AUTH_ON IS NOT NULL
                          UNION ALL
                          SELECT *
                            FROM TRAN2018
                           WHERE     TRAN_ENTITY_NUM = 1
                                 AND TRAN_ACING_BRN_CODE = 49130
                               --  AND TRAN_CURR_CODE = 'BDT'
                                 AND TRAN_AUTH_ON IS NOT NULL
                          UNION ALL
                          SELECT *
                            FROM TRAN2019
                           WHERE     TRAN_ENTITY_NUM = 1
                                 AND TRAN_ACING_BRN_CODE = 49130
                                -- AND TRAN_CURR_CODE = 'BDT'
                                 AND TRAN_AUTH_ON IS NOT NULL
                          UNION ALL
                          SELECT *
                            FROM TRAN2020
                           WHERE     TRAN_ENTITY_NUM = 1
                                 AND TRAN_ACING_BRN_CODE = 49130
                                 --AND TRAN_CURR_CODE = 'BDT'
                                 AND TRAN_AUTH_ON IS NOT NULL
                          UNION ALL
                          SELECT *
                            FROM TRAN2021
                           WHERE     TRAN_ENTITY_NUM = 1
                                 AND TRAN_ACING_BRN_CODE = 49130
                                 --  AND TRAN_INTERNAL_ACNUM <> 0
                                 --AND TRAN_INTERNAL_ACNUM = 13613700001620032
                                 AND TRAN_AUTH_ON IS NOT NULL
                          UNION ALL
                          SELECT *
                            FROM TRAN2022
                           WHERE     TRAN_ENTITY_NUM = 1
                                 AND TRAN_ACING_BRN_CODE = 49130
                                -- AND  TRAN_GLACC_CODE in ('140126101','225116134')
                                 --AND TRAN_INTERNAL_ACNUM = 13613700001620032
                                 AND TRAN_AUTH_ON IS NOT NULL
                         UNION ALL
                          SELECT *
                            FROM TRAN2023
                           WHERE     TRAN_ENTITY_NUM = 1
                                 AND TRAN_ACING_BRN_CODE = 49130
                                --- AND  TRAN_GLACC_CODE in ('140126101','225116134')
                                 --AND TRAN_INTERNAL_ACNUM = 13613700001620032
                                 AND TRAN_AUTH_ON IS NOT NULL)
                GROUP BY TRAN_GLACC_CODE, TRAN_BASE_CURR_CODE)) A,
       (SELECT GLBBAL_CURR_CODE, GLBBAL_GLACC_CODE, GLBBAL_BC_BAL
          FROM GLBBAL
         WHERE     GLBBAL_ENTITY_NUM = 1
               AND GLBBAL_BRANCH_CODE = 49130
               AND GLBBAL_YEAR = 2023) B
 WHERE     A.TRAN_GLACC_CODE = B.GLBBAL_GLACC_CODE
       AND B.GLBBAL_CURR_CODE = A.TRAN_BASE_CURR_CODE
       AND A.TRAN_BALANCE <> B.GLBBAL_BC_BAL;



SELECT TRAN_DATE_OF_TRAN,
       A.TOTAL,
       B.GLBALH_BC_BAL,
       A.TOTAL - B.GLBALH_BC_BAL
  FROM (  SELECT TRAN_DATE_OF_TRAN,
                 CREDIT_AMT - DEBIT_AMT TRAN_BALANCE,
                 SUM (CREDIT_AMT - DEBIT_AMT) OVER (ORDER BY TRAN_DATE_OF_TRAN)
                    TOTAL
            FROM (  SELECT TRAN_DATE_OF_TRAN,
                           SUM (
                              CASE
                                 WHEN TRAN_DB_CR_FLG = 'C' THEN TRAN_AMOUNT
                                 ELSE 0
                              END)
                              CREDIT_AMT,
                           SUM (
                              CASE
                                 WHEN TRAN_DB_CR_FLG = 'D' THEN TRAN_AMOUNT
                                 ELSE 0
                              END)
                              DEBIT_AMT
                      FROM (SELECT *
                              FROM TRAN2017
                             WHERE     TRAN_ENTITY_NUM = 1
                                   AND TRAN_ACING_BRN_CODE = 20032
                                   AND TRAN_CURR_CODE = 'BDT'
                                   AND TRAN_GLACC_CODE = '205101101'
                                   AND TRAN_AUTH_ON IS NOT NULL
                            UNION ALL
                            SELECT *
                              FROM TRAN2020032
                             WHERE     TRAN_ENTITY_NUM = 1
                                   AND TRAN_ACING_BRN_CODE = 20032
                                   AND TRAN_CURR_CODE = 'BDT'
                                   AND TRAN_GLACC_CODE = '205101101'
                                   AND TRAN_AUTH_ON IS NOT NULL)
                  GROUP BY TRAN_DATE_OF_TRAN)
        ORDER BY TRAN_DATE_OF_TRAN) A,
       (SELECT *
          FROM GLBALASONHIST
         WHERE     GLBALH_ENTITY_NUM = 1
               AND GLBALH_GLACC_CODE = '205101101'
               AND GLBALH_BRN_CODE = 17012
               AND GLBALH_CURR_CODE = 'BDT') B
 WHERE     B.GLBALH_ASON_DATE = A.TRAN_DATE_OF_TRAN
       AND A.TOTAL <> B.GLBALH_BC_BAL