-------------------------------------------------------------------
SELECT DISTINCT ACNTS_BRN_CODE ,ACNTS_PROD_CODE,I.IACLINK_ACTUAL_ACNUM ACTUAL_ACNUM,account_name,ACNTS_AC_TYPE,ED_PARCENTAND,ed_year
  FROM (SELECT DISTINCT
               ACNTS_BRN_CODE,
               ACNTS_INTERNAL_ACNUM,
               ACNTS_PROD_CODE,
               ACNTS_AC_NAME1 || ACNTS_AC_NAME2 account_name,
               ACNTS_AC_TYPE,
               CASE
                  WHEN CLCHGWAIVDT_WAIVER_TYPE = 'F'
                  THEN
                     '100'
                  WHEN CLCHGWAIVDT_WAIVER_TYPE = 'P'
                  THEN
                     TO_CHAR (CLCHGWAIVDT_DISCOUNT_PER)
                  ELSE
                     NULL
               END
                  ED_PARCENTAND,
               CASE WHEN CLCHGWAIV_WAIVE_REQD = 1 THEN 'YES' ELSE 'NO' END
                  WAIVER,ed_year
          FROM (SELECT DISTINCT CLCHGWAIVDT_CLIENT_NUM,
                                CLCHGWAIV_WAIVE_REQD,
                                CLCHGWAIVDT_DISCOUNT_PER,
                                CLCHGWAIVDT_WAIVER_TYPE,  ed_year
                  FROM (SELECT CLCHGWAIVDT_CLIENT_NUM,
                               CLCHGWAIV_WAIVE_REQD,
                               CLCHGWAIVDT_DISCOUNT_PER,
                               CLCHGWAIVDT_WAIVER_TYPE,to_char(CLCHGWAIVDT_LATEST_EFF_DATE,'YYYY') ed_year
                          FROM CLCHGWAIVEDTL, CLCHGWAIVER
                         WHERE     CLCHGWAIVDT_CHARGE_CODE = 'ED'
                               AND CLCHGWAIV_CLIENT_NUM =
                                      CLCHGWAIVDT_CLIENT_NUM
                               AND CLCHGWAIV_WAIVE_REQD = '1') W,
                       ACNTS A
                 WHERE     ACNTS_CLIENT_NUM = CLCHGWAIVDT_CLIENT_NUM
                 and A.ACNTS_AC_TYPE='SBST'
                     -- AND ACNTS_PROD_CODE  in (2101,2102,2103,2104,2105,2106,2107,2108 , 2109)
                       AND ACNTS_ENTITY_NUM = 1) W,
               ACNTS
         WHERE     CLCHGWAIVDT_CLIENT_NUM = ACNTS_CLIENT_NUM
               AND ACNTS_CLOSURE_DATE IS NULL
        UNION ALL
        SELECT DISTINCT
               ACNTS_BRN_CODE,
               ACNTS_INTERNAL_ACNUM,
               ACNTS_PROD_CODE,
               ACNTS_AC_NAME1 || ACNTS_AC_NAME2 account_name,
               ACNTS_AC_TYPE,
               CASE
                  WHEN CLCHGWAIVDT_WAIVER_TYPE = 'F'
                  THEN
                     '100'
                  WHEN CLCHGWAIVDT_WAIVER_TYPE = 'P'
                  THEN
                     TO_CHAR (CLCHGWAIVDT_DISCOUNT_PER)
                  ELSE
                     NULL
               END
                  ED_PARCENTAND,
               CASE WHEN CLCHGWAIV_WAIVE_REQD = 1 THEN 'YES' ELSE 'NO' END
                  WAIVER,ed_year
          FROM (SELECT DISTINCT CLCHGWAIVDT_INTERNAL_ACNUM,
                                CLCHGWAIV_WAIVE_REQD,
                                CLCHGWAIVDT_DISCOUNT_PER,
                                CLCHGWAIVDT_WAIVER_TYPE,  ed_year
                  FROM (SELECT DISTINCT CLCHGWAIVDT_INTERNAL_ACNUM,
                                        CLCHGWAIV_WAIVE_REQD,
                                        CLCHGWAIVDT_DISCOUNT_PER,
                                        CLCHGWAIVDT_WAIVER_TYPE,to_char(CLCHGWAIVDT_LATEST_EFF_DATE,'YYYY') ed_year
                          FROM CLCHGWAIVEDTL, CLCHGWAIVER
                         WHERE     CLCHGWAIVDT_CHARGE_CODE = 'ED'
                               AND CLCHGWAIVDT_INTERNAL_ACNUM =
                                      CLCHGWAIV_INTERNAL_ACNUM
                               AND CLCHGWAIV_WAIVE_REQD = '1') W,
                       ACNTS A
                 WHERE     ACNTS_INTERNAL_ACNUM = CLCHGWAIVDT_INTERNAL_ACNUM
               AND   A.ACNTS_AC_TYPE='SBST'
               and ACNTS_CLOSURE_DATE is null
                      -- AND ACNTS_PROD_CODE  in (2101,2102,2103,2104,2105,2106,2107,2108 , 2109)
                       AND ACNTS_ENTITY_NUM = 1
                       ) W,
               ACNTS
         WHERE     CLCHGWAIVDT_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
               AND ACNTS_CLOSURE_DATE IS NULL) A,
       IACLINK I
 WHERE     ACNTS_INTERNAL_ACNUM = IACLINK_INTERNAL_ACNUM
       AND IACLINK_ENTITY_NUM = 1
       ;


-------------------------------------------
/* Formatted on 6/8/2021 4:33:26 PM (QP5 v5.252.13127.32867) */
SELECT DISTINCT ACNTS_BRN_CODE,
                ACNTS_PROD_CODE,
                FACNO(1,CLCHGWAIVDT_INTERNAL_ACNUM) ACTUAL_ACNUM,
                ACNTS_AC_NAME1 || ACNTS_AC_NAME2 account_name,
                ACNTS_AC_TYPE,
                ED_PARCENTAND,
                ed_year
  FROM (SELECT CLCHGWAIVDT_INTERNAL_ACNUM,
               CLCHGWAIV_WAIVE_REQD,
               CLCHGWAIVDT_DISCOUNT_PER ED_PARCENTAND,
               CLCHGWAIVDT_WAIVER_TYPE,
               TO_CHAR (CLCHGWAIVDT_LATEST_EFF_DATE, 'YYYY') ed_year
          FROM CLCHGWAIVEDTL, CLCHGWAIVER
         WHERE     CLCHGWAIVDT_CHARGE_CODE = 'ED'
               AND CLCHGWAIV_INTERNAL_ACNUM = CLCHGWAIVDT_INTERNAL_ACNUM
               AND CLCHGWAIV_WAIVE_REQD = '1') W,
       ACNTS A
 WHERE     ACNTS_INTERNAL_ACNUM = CLCHGWAIVDT_INTERNAL_ACNUM
       AND ACNTS_PROD_CODE IN (2101,
                               2102,
                               2103,
                               2104,
                               2105,
                               2106,
                               2107,
                               2108,
                               2109)
       AND ACNTS_ENTITY_NUM = 1
       AND ACNTS_CLOSURE_DATE IS NULL;
       
       
/* Formatted on 8/23/2021 8:41:04 PM (QP5 v5.149.1003.31008) */
--------------------------YEAR WISE DATA--------------------

WITH ED_DEDUCT
        AS (  SELECT ACNTEXCAMT_INTERNAL_ACNUM,
                     ACNTEXCAMT_FIN_YEAR,
                     SUM (ACNTEXCAMT_EXCISE_AMT) ACNTEXCAMT_EXCISE_AMT
                FROM ACNTEXCISEAMT@DR
            GROUP BY ACNTEXCAMT_INTERNAL_ACNUM, ACNTEXCAMT_FIN_YEAR),
     ED_SHOULD_DEDUCT
        AS (  SELECT EXCISE_YEAR,
                     EXCISE_INTERNAL_ACNUM,
                     SUM (
                        FN_EXCISE_DUTY_CALc (1,
                                             EXCISE_YEAR,
                                             EXCISE_MAX_BALANCE))
                        NEW_EXCISE_AMT,
                     SUM (NEW_EXCISE_AMT) NEW_EXCISE_AMT_old,
                     SUM (NEW_VAT_AMOUNT) NEW_VAT_AMOUNT,sum(EXCISE_MAX_BALANCE) EXCISE_MAX_BALANCE
                FROM ACNTEXCISEAMT_RECALC_1920@DR
            GROUP BY EXCISE_YEAR, EXCISE_INTERNAL_ACNUM)
SELECT FACNO@DR (1, N.EXCISE_INTERNAL_ACNUM) ACCOUNT_NUM,
       N.EXCISE_YEAR,
       N.NEW_EXCISE_AMT,EXCISE_MAX_BALANCE,
       NEW_EXCISE_AMT_old, O.ACNTEXCAMT_EXCISE_AMT, (
       N.NEW_EXCISE_AMT-NVL(
       O.ACNTEXCAMT_EXCISE_AMT,0) ) amount_will_deduct
  FROM ED_DEDUCT O
       RIGHT OUTER JOIN ED_SHOULD_DEDUCT N
          ON (    O.ACNTEXCAMT_INTERNAL_ACNUM = N.EXCISE_INTERNAL_ACNUM
              AND O.ACNTEXCAMT_FIN_YEAR = N.EXCISE_YEAR)
              
              
              
/* Formatted on 8/24/2021 12:56:55 PM (QP5 v5.149.1003.31008) */
--------------------------YEAR WISE DATA--------------------

SELECT EXCISE_YEAR,
       NUM_OF_INSTALLMENT branch_code,
       ACNO_1 products_code,
       ACC_NO,
       GMO account_name,
       REPAY_FREQ account_type,
       PO_RO_CORP ED_percent,
       NEW_EXCISE_AMT,
       EXCISE_MAX_BALANCE,
     abs(  amount_will_deduct) amount_will_deduct
  FROM (WITH ED_DEDUCT
                AS (  SELECT ACNTEXCAMT_INTERNAL_ACNUM,
                             ACNTEXCAMT_FIN_YEAR,
                             SUM (ACNTEXCAMT_EXCISE_AMT) ACNTEXCAMT_EXCISE_AMT
                        FROM ACNTEXCISEAMT@DR
                    GROUP BY ACNTEXCAMT_INTERNAL_ACNUM, ACNTEXCAMT_FIN_YEAR),
             ED_SHOULD_DEDUCT
                AS (  SELECT EXCISE_YEAR,
                             EXCISE_INTERNAL_ACNUM,
                             SUM (
                                FN_EXCISE_DUTY_CALC@DR (1,
                                                        EXCISE_YEAR,
                                                        EXCISE_MAX_BALANCE))
                                NEW_EXCISE_AMT,
                             SUM (NEW_EXCISE_AMT) NEW_EXCISE_AMT_old,
                             SUM (NEW_VAT_AMOUNT) NEW_VAT_AMOUNT,
                             SUM (EXCISE_MAX_BALANCE) EXCISE_MAX_BALANCE
                        FROM ACNTEXCISEAMT_RECALC_1920@DR
                    GROUP BY EXCISE_YEAR, EXCISE_INTERNAL_ACNUM)
        SELECT FACNO@DR (1, N.EXCISE_INTERNAL_ACNUM) ACCOUNT_NUM,
               N.EXCISE_YEAR,
               N.NEW_EXCISE_AMT,
               EXCISE_MAX_BALANCE,
               NEW_EXCISE_AMT_old,
               O.ACNTEXCAMT_EXCISE_AMT,
               (NVL (O.ACNTEXCAMT_EXCISE_AMT, 0)-N.NEW_EXCISE_AMT )
                  amount_will_deduct
          FROM    ED_DEDUCT O
               RIGHT OUTER JOIN
                  ED_SHOULD_DEDUCT N
               ON (O.ACNTEXCAMT_INTERNAL_ACNUM = N.EXCISE_INTERNAL_ACNUM
                   AND O.ACNTEXCAMT_FIN_YEAR = N.EXCISE_YEAR)),
       sblprod_23062021.acc4
 WHERE ACCOUNT_NUM = acc_no