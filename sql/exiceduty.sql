/* Formatted on 12/18/2019 11:17:42 AM (QP5 v5.227.12220.39754) */
SELECT DISTINCT ACNTS_BRN_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_CODE = ACNTS_BRN_CODE)
          MBRN_NAME,
       FACNO (1, ACNTS_INTERNAL_ACNUM) ACCOUNT_NO,
       ACNTS_AC_TYPE,
       ACNTS_AC_SUB_TYPE,
       ACNTEXCAMT_EXCISE_AMT,ACNTEXCAMT_PROCESS_DATE
  FROM  ACNTS, ACNTEXCISEAMT
 WHERE     ACNTEXCAMT_ENTITY_NUM = 1
       -- AND SBCAINTPAY_BRN_CODE = 1180
       AND ACNTEXCAMT_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
     --  AND SBCACALC_INT_RATE > 3.5
       AND ACNTS_ENTITY_NUM = 1
    and    ACNTEXCAMT_ENTITY_NUM = 1
---AND ACNTEXCAMT_INTERNAL_ACNUM = 10101600004580
AND ACNTEXCAMT_FIN_YEAR = 2019
AND ACNTEXCAMT_EXCISE_AMT not in (150, 500, 2500, 12000 , 25000)
and ACNTEXCAMT_EXCISE_AMT<>0