/* Formatted on 12/30/2021 1:19:06 PM (QP5 v5.252.13127.32867) */
------------atm charge not deduct ---------

SELECT ACNTS_BRN_CODE,
       ACNTS_PROD_CODE,
       FACNO (1, ACNTS_INTERNAL_ACNUM) ACCOUNT_NO,
       ACNTS_AC_NAME1 || ACNTS_AC_NAME2 ACCOUNT_NAME,
       ACNTS_AC_TYPE
  FROM CIFISS, ACNTS
 WHERE     CIFISS_ACC_NUM = ACNTS_INTERNAL_ACNUM
       AND ACNTS_ENTITY_NUM = 1
       AND ACNTS_CLOSURE_DATE IS NULL
       AND CIFISS_REJ_BY IS NULL
       AND ACNTS_AC_TYPE NOT IN (SELECT AC_TYPE FROM ATM_ACC_TYPE_EXC)
       AND CIFISS_AUTH_BY IS NOT NULL
       AND CIFISS_ACC_NUM NOT IN (SELECT ATM_CHG_REC_INTERNAL_ACNUM
                                    FROM ATM_CHG_REC
                                   WHERE     ATM_CHG_REC_ENTITY_NUM = 1
                                         AND ATM_CHG_REC_FIN_YEAR = 2021
                                         AND NVL (ATM_CHG_REC_CHARGE_AMT, 0) >
                                                0);


-------------atm vat not deduct------------------------------------------------------------------------------------------

SELECT ACNTS_BRN_CODE,
       ACNTS_PROD_CODE,
       FACNO (1, ACNTS_INTERNAL_ACNUM) ACCOUNT_NO,
       ACNTS_AC_NAME1 || ACNTS_AC_NAME2 ACCOUNT_NAME,
       ACNTS_AC_TYPE
  FROM ATM_CHG_REC, ACNTS
 WHERE     ATM_CHG_REC_ENTITY_NUM = 1
       AND ACNTS_AC_TYPE NOT IN (SELECT AC_TYPE FROM ATM_ACC_TYPE_EXC)
       AND ATM_CHG_REC_FIN_YEAR = 2021
       AND NVL (ATM_CHG_REC_VAT_AMT, 0) <= 0
       AND ATM_CHG_REC_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
       AND ACNTS_ENTITY_NUM = 1;



----------List of accounts which are registered for transaction alert but SMS charge not deducted --------

SELECT ACNTS_BRN_CODE,
       ACNTS_PROD_CODE,
       FACNO (1, ACNTS_INTERNAL_ACNUM) ACCOUNT_NO,
       ACNTS_AC_NAME1 || ACNTS_AC_NAME2 ACCOUNT_NAME,
       ACNTS_AC_TYPE
  FROM mobilereg, acnts
 WHERE     INT_ACNUM = ACNTS_INTERNAL_ACNUM
       AND ACNTS_ENTITY_NUM = 1
       AND ACNTS_CLOSURE_DATE IS NULL
       AND ACNTS_AC_TYPE NOT IN (SELECT AC_TYPE FROM SMS_ACC_TYPE_EXC)
       AND SERVICE1 = 1
       AND INT_ACNUM NOT IN (SELECT SMSCHARGE_INTERNAL_ACNUM
                               FROM SMSCHARGE
                              WHERE     SMSCHARGE_ENTITY_NUM = 1
                                    AND SMSCHARGE_SERVICE_TYPE = 1
                                    AND SMSCHARGE_FIN_YEAR = 2021
                                    AND SMSCHARGE_CHARGE_AMT > 0);



------List of accounts which are registered for Push Pull service but PUSH PULL charge not deducted from the account.

SELECT ACNTS_BRN_CODE,
       ACNTS_PROD_CODE,
       FACNO (1, ACNTS_INTERNAL_ACNUM) ACCOUNT_NO,
       ACNTS_AC_NAME1 || ACNTS_AC_NAME2 ACCOUNT_NAME,
       ACNTS_AC_TYPE
  FROM mobilereg, acnts
 WHERE     INT_ACNUM = ACNTS_INTERNAL_ACNUM
       AND ACNTS_ENTITY_NUM = 1
       AND ACNTS_CLOSURE_DATE IS NULL
       AND SERVICE2 = 1
       AND ACNTS_AC_TYPE NOT IN (SELECT AC_TYPE FROM SMS_ACC_TYPE_EXC)
       AND INT_ACNUM NOT IN (SELECT SMSCHARGE_INTERNAL_ACNUM
                               FROM SMSCHARGE
                              WHERE     SMSCHARGE_ENTITY_NUM = 1
                                    AND SMSCHARGE_SERVICE_TYPE = 2
                                    AND SMSCHARGE_FIN_YEAR = 2021
                                    AND SMSCHARGE_CHARGE_AMT > 0);


--------------List of account of which transaction alert service charge deducted but VAT not deducted

SELECT ACNTS_BRN_CODE,
       ACNTS_PROD_CODE,
       FACNO (1, ACNTS_INTERNAL_ACNUM) ACCOUNT_NO,
       ACNTS_AC_NAME1 || ACNTS_AC_NAME2 ACCOUNT_NAME,
       ACNTS_AC_TYPE
  FROM SMSCHARGE, ACNTS
 WHERE     SMSCHARGE_ENTITY_NUM = 1
       AND SMSCHARGE_FIN_YEAR = 2021
       AND ACNTS_AC_TYPE NOT IN (SELECT AC_TYPE FROM SMS_ACC_TYPE_EXC)
       AND SMSCHARGE_VAT_AMT <= 0
       AND ACNTS_ENTITY_NUM = 1
       AND ACNTS_INTERNAL_ACNUM = SMSCHARGE_INTERNAL_ACNUM
       AND SMSCHARGE_SERVICE_TYPE = 1;


-----List of account of where Pust Pull service charge deducted but VAT not deducted

SELECT ACNTS_BRN_CODE,
       ACNTS_PROD_CODE,
       FACNO (1, ACNTS_INTERNAL_ACNUM) ACCOUNT_NO,
       ACNTS_AC_NAME1 || ACNTS_AC_NAME2 ACCOUNT_NAME,
       ACNTS_AC_TYPE
  FROM SMSCHARGE, ACNTS
 WHERE     SMSCHARGE_ENTITY_NUM = 1
       AND SMSCHARGE_FIN_YEAR = 2021
       AND ACNTS_AC_TYPE NOT IN (SELECT AC_TYPE FROM SMS_ACC_TYPE_EXC)
       --AND SMSCHARGE_CHARGE_AMT <= 0
       AND SMSCHARGE_VAT_AMT <= 0
       AND ACNTS_ENTITY_NUM = 1
       AND ACNTS_BRN_CODE = 26
       AND ACNTS_INTERNAL_ACNUM = SMSCHARGE_INTERNAL_ACNUM
       AND SMSCHARGE_SERVICE_TYPE = 2;