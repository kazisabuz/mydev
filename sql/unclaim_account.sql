/* Formatted on 6/15/2023 4:07:58 PM (QP5 v5.388) */
SELECT *
  FROM (SELECT ACNTS_BRN_CODE,
               account_number,
               account_name,
               PRODUCT_CODE,
               PRODUCT_NAME,
               ACNTS_AC_TYPE,
               AC_BAL,
               TRAN_LAST_DATE,
               NONSYS_TRAN_LAST_DATE,
               TRUNC (
                   MONTHS_BETWEEN (TO_DATE ('21-jun-2023'), TRAN_LAST_DATE))    NOF_MONTH
          FROM (SELECT ACNTS_BRN_CODE,
                       facno (1, ACNTS_INTERNAL_ACNUM)
                           account_number,
                       ACNTS_AC_NAME1 || ACNTS_AC_NAME2
                           account_name,
                       PRODUCT_CODE,
                       PRODUCT_NAME,
                       ACNTS_AC_TYPE,
                       FN_BIS_GET_ASON_ACBAL (1,
                                              ACNTS_INTERNAL_ACNUM,
                                              'BDT',
                                              '21-JUN-2023',
                                              '21-JUN-2023')
                           AC_BAL,
                       NVL (ACNTS_NONSYS_LAST_DATE, ACNTS_OPENING_DATE)
                           TRAN_LAST_DATE,
                       ACNTS_NONSYS_LAST_DATE
                           NONSYS_TRAN_LAST_DATE
                  FROM acnts a, products
                 WHERE     (   A.ACNTS_CLOSURE_DATE IS NULL
                            OR A.ACNTS_CLOSURE_DATE > '21-JUN-2023')
                       AND PRODUCT_FOR_DEPOSITS = 1
                       AND ACNTS_BRN_CODE = 34
                       AND ACNTS_ENTITY_NUM = 1
                       AND PRODUCT_CODE IN (1096)
                       AND ACNTS_PROD_CODE = PRODUCT_CODE))
 WHERE NOF_MONTH >= 120
 AND AC_BAL=0;
 
 ----------------------------------------
 INSERT INTO ACNTSTATUS
SELECT 1                               ACNTSTATUS_ENTITY_NUM,
       ACNTS_INTERNAL_ACNUM            ACNTSTATUS_INTERNAL_ACNUM,
       '30-JUN-2023'                   ACNTSTATUS_EFF_DATE,
       'D'                             ACNTSTATUS_FLG,
       'Mail: Thursday, June 15, '     ACNTSTATUS_REMARKS1,
       '2023 2:14 PM'                  ACNTSTATUS_REMARKS2,
       NULL                            ACNTSTATUS_REMARKS3,
       'INTELECT'                      ACNTSTATUS_ENTD_BY,
       SYSDATE                         ACNTSTATUS_ENTD_ON,
       NULL                            ACNTSTATUS_LAST_MOD_BY,
       NULL                            ACNTSTATUS_LAST_MOD_ON
  FROM (SELECT ACNTS_BRN_CODE,
               ACNTS_INTERNAL_ACNUM,
               account_name,
               PRODUCT_CODE,
               PRODUCT_NAME,
               ACNTS_AC_TYPE,
               AC_BAL,
               TRAN_LAST_DATE,
               NONSYS_TRAN_LAST_DATE,
               TRUNC (
                   MONTHS_BETWEEN (TO_DATE ('30-jun-2023'), TRAN_LAST_DATE))    NOF_MONTH
          FROM (SELECT ACNTS_BRN_CODE,
                       facno (1, ACNTS_INTERNAL_ACNUM)
                           account_number,
                       ACNTS_INTERNAL_ACNUM,
                       ACNTS_AC_NAME1 || ACNTS_AC_NAME2
                           account_name,
                       PRODUCT_CODE,
                       PRODUCT_NAME,
                       ACNTS_AC_TYPE,
                       FN_BIS_GET_ASON_ACBAL (1,
                                              ACNTS_INTERNAL_ACNUM,
                                              'BDT',
                                              '30-JUN-2023',
                                              '02-JUL-2023')
                           AC_BAL,
                       NVL (ACNTS_NONSYS_LAST_DATE, ACNTS_OPENING_DATE)
                           TRAN_LAST_DATE,
                       ACNTS_NONSYS_LAST_DATE
                           NONSYS_TRAN_LAST_DATE
                  FROM acnts a, products
                 WHERE     (   A.ACNTS_CLOSURE_DATE IS NULL
                            OR A.ACNTS_CLOSURE_DATE > '30-JUN-2023')
                       AND PRODUCT_FOR_DEPOSITS = 1
                       AND ACNTS_BRN_CODE = 34
                       AND ACNTS_ENTITY_NUM = 1
                       AND PRODUCT_CODE IN (1096, 1091, 1033)
                       AND ACNTS_PROD_CODE = PRODUCT_CODE))
 WHERE NOF_MONTH >= 120 AND AC_BAL = 0