/* Formatted on 10/19/2021 2:53:25 PM (QP5 v5.149.1003.31008) */
SELECT TRAN_ACING_BRN_CODE  ,TRAN_BRN_CODE,
       TRAN_DATE_OF_TRAN,
       TRAN_BATCH_NUMBER,
       PRODUCT_CODE,
       PRODUCT_NAME,
       ACNTS_AC_TYPE,
       facno (1, TRAN_INTERNAL_ACNUM) account_no,
       ACNTS_AC_NAME1 || ACNTS_AC_NAME2 account_name,
       TRAN_AMOUNT RECOVERY_AMOUNT
  FROM tran2021 t, acnts a, products p
 WHERE     TRAN_ENTITY_NUM = 1
       AND TRAN_ACING_BRN_CODE = 26
       AND ACNTS_INTERNAL_ACNUM = TRAN_INTERNAL_ACNUM
       AND TRAN_INTERNAL_ACNUM <> 0
       AND ACNTS_ENTITY_NUM = 1
       AND p.product_code = a.acnts_prod_code
       AND p.product_for_loans = 1
       AND t.tran_db_cr_flg = 'C'
       AND T.TRAN_AMOUNT <> 0
       AND T.TRAN_DATE_OF_TRAN BETWEEN '01-SEP-2021' AND '30-SEP-2021'
       AND T.TRAN_AUTH_BY IS NOT NULL