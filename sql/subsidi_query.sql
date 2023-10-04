/* Formatted on 6/8/2022 3:42:55 PM (QP5 v5.252.13127.32867) */
  SELECT ACNTS_BRN_CODE,
         mbrn_name,
         PRODUCT_CODE,LNINTAPPL_APPL_DATE,
         SUM (LNINTAPPL_ACT_INT_AMT) total_int_apply,
         SUM (DEDUCTED_AMT) block_transfer,
         SUM (AMT_RECOVERED) block_recover
    FROM deduct_int, mbrn
   WHERE ACNTS_BRN_CODE = mbrn_code AND PRODUCT_CODE = 2220
GROUP BY ACNTS_BRN_CODE, mbrn_name, PRODUCT_CODE,LNINTAPPL_APPL_DATE
order by 1 asc;




SELECT d.ACNTS_BRN_CODE,
         mbrn_name,ACTUAL_NUM,ACNTS_AC_NAME1|| ACNTS_AC_NAME2 account_name,
         PRODUCT_CODE,LNINTAPPL_APPL_DATE,
           (LNINTAPPL_ACT_INT_AMT) total_int_apply,
           (DEDUCTED_AMT) block_transfer,
           (AMT_RECOVERED) block_recover
    FROM deduct_int d, mbrn,acnts a
   WHERE d.ACNTS_BRN_CODE = mbrn_code AND PRODUCT_CODE = 2220
   and d.ACNTS_INTERNAL_ACNUM=a.ACNTS_INTERNAL_ACNUM
 order by 1 asc;