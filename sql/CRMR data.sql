/* Formatted on 8/6/2020 2:18:06 PM (QP5 v5.227.12220.39754) */
---cloumn 23------ 1st

SELECT COUNT (ACNTS_INTERNAL_ACNUM) nof_ac_having_excess_lmt,
       SUM (outstanding) outstanding_excess_lmt
  FROM (SELECT ACNTS_INTERNAL_ACNUM,
               LMTLINE_SANCTION_AMT,
               ABS (FN_GET_ASON_ACBAL (1,
                                       ACNTS_INTERNAL_ACNUM,
                                       'BDT',
                                       '30-JUN-2020',
                                       '06-AUG-2020'))
                  outstanding
          FROM ACASLLDTL, limitline, acnts
         WHERE     ACASLLDTL_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
               AND ACASLLDTL_LIMIT_LINE_NUM = LMTLINE_NUM
               AND LMTLINE_CLIENT_CODE = ACASLLDTL_CLIENT_NUM
               AND ACNTS_ENTITY_NUM = 1
               AND ACASLLDTL_ENTITY_NUM = 1
               )
 WHERE outstanding > LMTLINE_SANCTION_AMT;

--------cloumn 23------ 2nd

SELECT COUNT (ACNTS_INTERNAL_ACNUM) nof_ac_having_excess_lmt,
       SUM (outstanding) outstanding_excess_lmt
  FROM (SELECT ACNTS_INTERNAL_ACNUM,
               LMTLINE_SANCTION_AMT,
               ABS (FN_GET_ASON_ACBAL (1,
                                       ACNTS_INTERNAL_ACNUM,
                                       'BDT',
                                       '30-JUN-2020',
                                       '06-AUG-2020'))
                  outstanding
          FROM ACASLLDTL, limitline, acnts
         WHERE     ACASLLDTL_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
               AND ACASLLDTL_LIMIT_LINE_NUM = LMTLINE_NUM
               AND ACNTS_INTERNAL_ACNUM IN
                      (SELECT ACNTS_INTERNAL_ACNUM
                         FROM (SELECT ACNTS_INTERNAL_ACNUM,
                                      FN_GET_OD_AMT (1,
                                                     ACNTS_INTERNAL_ACNUM,
                                                     '30-JUN-2020',
                                                     '06-AUG-2020')
                                         Overdue_Amount
                                 FROM acnts, products
                                WHERE     ACNTS_ENTITY_NUM = 1
                                    --  AND ACNTS_BRN_CODE = 26
                                      AND PRODUCT_CODE = ACNTS_PROD_CODE
                                      AND PRODUCT_FOR_LOANS = 1)
                        WHERE NVL (Overdue_Amount, 0) <> 0)
               AND LMTLINE_CLIENT_CODE = ACASLLDTL_CLIENT_NUM
               AND ACNTS_ENTITY_NUM = 1
               AND ACASLLDTL_ENTITY_NUM = 1
              )
 WHERE outstanding > LMTLINE_SANCTION_AMT;
 
 
 
 
 /* Formatted on 8/6/2020 2:18:23 PM (QP5 v5.227.12220.39754) */
--column 24-------------- 1,2

SELECT t.*,(NVL (JAN_DUE, 0) - NVL (JUN_DUE, 0)) 
  FROM (SELECT ACNTS_INTERNAL_ACNUM,
               FN_GET_OD_MONTH_DATA (1, ACNTS_INTERNAL_ACNUM, '01-JAN-2020')
                  JAN_DUE,
               FN_GET_OD_MONTH_DATA (1, ACNTS_INTERNAL_ACNUM, '30-JUN-2020')
                  JUN_DUE,
               FN_GET_PAID_AMT (1, ACNTS_INTERNAL_ACNUM, '01-JAN-2020')
                  JAN_REC,
               FN_GET_PAID_AMT (1, ACNTS_INTERNAL_ACNUM, '30-JUN-2020')
                  JUN_REC,
               FN_GET_OD_AMT (1,
                              ACNTS_INTERNAL_ACNUM,
                              '30-JUN-2020',
                              '06-AUG-2020')
                  Overdue_Amount
          FROM acnts, products
         WHERE     ACNTS_ENTITY_NUM = 1
               AND ACNTS_BRN_CODE = 26
               AND PRODUCT_CODE = ACNTS_PROD_CODE
               AND PRODUCT_FOR_LOANS = 1)t
 WHERE (NVL (JAN_DUE, 0) - NVL (JUN_DUE, 0)) <> 0;