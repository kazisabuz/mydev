/* Formatted on 7/13/2023 4:24:36 PM (QP5 v5.388) */
SELECT RTMPLNACBAL_INTERNAL_ACNUM, RTMPLNACBAL_BAL
  FROM rtmplnacbal@dr
 WHERE RTMPLNACBAL_BRN_CODE = 6064 AND RTMPLNACBAL_TMP_SER = 481337 and RTMPLNACBAL_BAL<>0
MINUS
SELECT ACNTS_INTERNAL_ACNUM, ACBAL
  FROM cl_tmp_data@dr
 WHERE ASON_DATE = '30-jun-2023' AND ACNTS_BRN_CODE = 6064;
 
 
 
 /* Formatted on 7/13/2023 4:30:51 PM (QP5 v5.388) */
SELECT facno@dr (1, ACNTBAL_INTERNAL_ACNUM) account_no, ACNTBAL_BC_BAL
  FROM lnwrtoff@dr, acntbal@dr t
 WHERE     LNWRTOFF_ACNT_NUM = ACNTBAL_INTERNAL_ACNUM
       AND LNWRTOFF_ACNT_NUM IN (10606400003108,
                                 10606400003112,
                                 10606400003116,
                                 10606400003654,
                                 10606400004382,
                                 10606400004721,
                                 10606400026094,
                                 10606400026352,
                                 10606400026393,
                                 10606400026530,
                                 10606400026736,
                                 10606400026974)