/* Formatted on 7/10/2019 10:46:33 AM (QP5 v5.227.12220.39754) */
  SELECT REMCSP_TRAN_DATE,
         REMCSP_BRN_CODE,
         MBRN_NAME,
         CASE
            WHEN REMCSP_CASH_TYPE = '1' THEN 'SPOT CASH'
            WHEN REMCSP_CASH_TYPE = '2' THEN 'WEB CASH'
            WHEN REMCSP_CASH_TYPE = '3' THEN 'MANUAL WEB CASH'
            ELSE NULL
         END
            REMCSP_CASH_TYPE,
         FACNO (1, REMCSP_ACC_NUM) REMCSP_ACC_NUM,
         REMEXC_EXC_NAME,
         REMCSP_PIN,
         REMCSP_REF_NO,
         REMCSP_REF_DATE,
         --  REMCSP_CURR_CODE,
         POST_TRAN_BATCH_NUM,
         REMCSP_TRAN_AMOUNT TRAN_AMOUNT
    FROM MBRN, REMCASHPAY, REMEXCHOUSE
   WHERE     REMCSP_AUTH_BY IS NOT NULL
         AND REMCSP_BRN_CODE = MBRN_CODE
         AND REMCSP_TRAN_DATE BETWEEN '17-DEC-2017' AND '17-DEC-2017'
         AND REMCSP_ACC_NUM = REMEXC_ACC_NUM
         AND REMCSP_ACC_NUM IN
                (SELECT IACLINK_INTERNAL_ACNUM
                   FROM IACLINK
                  WHERE     IACLINK_ENTITY_NUM = 1
                        AND IACLINK_ACTUAL_ACNUM IN
                               ('0003433034541',
                                '0003433034822',
                                '0003433034351',
                                '0003433033915',
                                '0003433034566',
                                '0003433034698',
                                '0003433033634',
                                '0003433033543',
                                '0003402001635',
                                '0003433034888',
                                '0003402001631',
                                '0003433034293',
                                '0003433034632',
                                '0003402001618',
                                '0003402001611',
                                '0003433034194',
                                '0003433034599',
                                '0003402001609'))
ORDER BY REMCSP_TRAN_DATE ASC ,REMCSP_ACC_NUM ASC;




----------------

/* Formatted on 1/23/2020 4:35:24 PM (QP5 v5.227.12220.39754) */
  SELECT REMCSP_ENTRY_TYPE,sum(to_number(REMCSP_TRAN_AMOUNT))
    FROM MBRN, REMCASHPAY
   WHERE     REMCSP_AUTH_BY IS NOT NULL
         AND REMCSP_BRN_CODE = MBRN_CODE
         AND REMCSP_TRAN_DATE BETWEEN '1-JUL-2019' AND '31-DEC-2019'
         AND REMCSP_REJ_BY IS NULL
         AND REMCSP_CASH_TYPE IN ('1', '2', '3')
         and REMCSP_IS_REVERSED=0
 GROUP BY REMCSP_ENTRY_TYPE
order by  to_number(REMCSP_TRAN_AMOUNT) desc