BEGIN
   DELETE FROM SMS_REMAIN_BRN;

   FOR IND
      IN (SELECT SMSCHARGE_BRN_CODE, SMSCHARGE_POST_TRAN_BATCH_NUM
           FROM (SELECT DISTINCT
                        SMSCHARGE_BRN_CODE, SMSCHARGE_POST_TRAN_BATCH_NUM
                   FROM SMSCHARGE
                  WHERE     SMSCHARGE_FIN_YEAR = 2021
                        AND SMSCHARGE_PROCESS_DATE = '30-JUN-2021'
                        AND SMSCHARGE_SERVICE_TYPE = '2'
                 MINUS
                 SELECT DISTINCT (N.TRAN_BRN_CODE), TRAN_BATCH_NUMBER
                   FROM TRAN2021 N
                  WHERE     N.TRAN_DATE_OF_TRAN = '30-JUN-2021'
                        AND N.TRAN_NARR_DTL1 = 'SMS Charge(Push Pull)'
                        AND TRAN_ENTITY_NUM = 1))
   LOOP
      INSERT INTO SMS_REMAIN_BRN (BRANCH_CODE, COMPLETED)
           VALUES (IND.SMSCHARGE_BRN_CODE, 0);

      DELETE FROM SMSCHARGE
            WHERE     SMSCHARGE_FIN_YEAR = 2021
                  AND SMSCHARGE_PROCESS_DATE = '30-JUN-2021'
                  AND SMSCHARGE_SERVICE_TYPE = '2'
                  AND SMSCHARGE_POST_TRAN_BATCH_NUM =
                         IND.SMSCHARGE_POST_TRAN_BATCH_NUM;
   END LOOP;
   COMMIT;
END;