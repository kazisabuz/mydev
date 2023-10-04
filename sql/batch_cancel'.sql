------------Batch cancel-----------------------------------------------------------
/* Formatted on 9/22/2021 5:13:56 PM (QP5 v5.149.1003.31008) */
BEGIN
   FOR IDX
      IN (SELECT DISTINCT TRAN_BRN_CODE,
                          TRAN_BATCH_NUMBER,
                          TRAN_DATE_OF_TRAN
            FROM tran2023
           WHERE     TRAN_DATE_OF_TRAN = '29-jun-2022'
                  AND TRAN_BATCH_NUMBER IN (202)
                  AND TRAN_ENTITY_NUM=1
                  AND TRAN_BRN_CODE =4051)
   LOOP
      SP_TRAN_CANCEL (1,
                      IDX.TRAN_BRN_CODE,
                      idx.TRAN_DATE_OF_TRAN,
                      IDX.TRAN_BATCH_NUMBER,
                      'INTELECT');
   END LOOP;
END;


 ----UNAUTHORIZED BATCH-------------
 
/* Formatted on 12/31/2022 8:35:17 AM (QP5 v5.388) */
BEGIN
    FOR IDX
        IN (SELECT DISTINCT
                   TRAN_BRN_CODE, TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER
             FROM TRAN2022
            WHERE     TRAN_ENTITY_NUM = 1
                  AND TRAN_AMOUNT <> 0
                  AND TRAN_AUTH_BY IS NULL)
    LOOP
        TEST_ABOPAUTHQ_AUTHORIZE (IDX.TRAN_BRN_CODE,
                                  IDX.TRAN_DATE_OF_TRAN,
                                  IDX.TRAN_BATCH_NUMBER);
        COMMIT;
    END LOOP;
END;