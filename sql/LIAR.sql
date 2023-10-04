/* Formatted on 8/4/2022 5:08:47 PM (QP5 v5.252.13127.32867) */
SELECT facno (1, LNINSTRECV_INTERNAL_ACNUM) loan_acnts,
       LNINSTRECV_REPAY_AMT,
       facno (1, LNINSTRECV_RECOV_FROM_ACNT) casa_acnts,
       fn_get_ason_acbal (1,
                          LNINSTRECV_RECOV_FROM_ACNT,
                          'BDT',
                          '05-AUG-2022',
                          '05-AUG-2022')
          ACBAL
  FROM LNINSTRECV
 WHERE LNINSTRECV_REPAY_DATE = '05-aug-2022'