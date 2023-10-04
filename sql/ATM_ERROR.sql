/* Formatted on 4/13/2023 11:14:48 AM (QP5 v5.388) */
INSERT INTO ATM_RESPONSE_FIELD_ARCHIVE (SYSTEM_TRACE_AUDIT_NUMBER,
                                        RETRIEVAL_REFERENCE_NUMBER,
                                        APPROVAL_CODE,
                                        TRANSACTION_DATE,
                                        REQUEST_DATE,
                                        FIELD_POSITION,
                                        FIELD_MEANING,
                                        FIELD_VALUE,
                                        ATM_REQUEST_ID)
     VALUES ( :1,
             :2,
             :3,
             :4,
             :5,
             :6,
             :7,
             :8,
             :9);
             
/* Formatted on 4/13/2023 12:02:08 PM (QP5 v5.388) */
SELECT *
  FROM ACNTS
 WHERE ACNTS_INTERNAL_ACNUM = :1 and ACNTS_ENTITY_NUM=1;
             
             UPDATE ACNTS
   SET ACNTS_INT_CALC_UPTO = :B2
 WHERE     ACNTS_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
       AND ACNTS_INTERNAL_ACNUM = :B1;
       
       
       
/* Formatted on 5/21/2023 3:33:39 PM (QP5 v5.388) */
INSERT INTO TRANTIME (TRANTIME_ENTITY_NUM,
                      TRANTIME_BRN_CODE,
                      TRANTIME_TRAN_DATE,
                      TRANTIME_PROCESS_TYPE,
                      TRANTIME_PURPOSE_CODE,
                      TRANTIME_ELAPSED_TIME,
                      TRANTIME_PROGRAM_ID)
     VALUES ( :1,
             :2,
             TO_DATE ( :3, 'DD-MM-YYYY'),
             :4,
             :5,
             :6,
             :7);
             
             
             
             /* Formatted on 5/21/2023 3:37:00 PM (QP5 v5.388) */
UPDATE ACNTS
   SET ACNTS_INT_CALC_UPTO = :B2
 WHERE     ACNTS_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
       AND ACNTS_INTERNAL_ACNUM = :B1;
       
       
       
       /* Formatted on 5/21/2023 3:37:24 PM (QP5 v5.388) */
INSERT INTO LOANIAPS (LOANIAPS_ENTITY_NUM,
                      LOANIAPS_BRN_CODE,
                      LOANIAPS_ACNT_NUM,
                      LOANIAPS_GRACE_END_DATE,
                      LOANIAPS_ACCRUAL_DATE,
                      LOANIAPS_PS_SERIAL,
                      LOANIAPS_NOT_DUE_AMT,
                      LOANIAPS_ENTRY_TYPE,
                      LOANIAPS_ACTUAL_DUE_DATE,
                      LOANIAPS_FINAL_DUE_AMT)
    (SELECT PKG_ENTITY.FN_GET_ENTITY_CODE,
            :B3,
            C.RTMPLNND_INTERNAL_ACNUM,
            C.RTMPLNND_GRACE_END_DATE,
            :B2,
            ROWNUM,
            C.RTMPLNND_NOT_DUE_AMT,
            C.RTMPLNND_ENTRY_TYPE,
            C.RTMPLNND_ACTUAL_DUE_DATE,
            C.RTMPLNND_FINAL_DUE_AMT
       FROM RTMPLNNOTDUE C
      WHERE C.RTMPLNND_INTERNAL_ACNUM = :B1);
      
      
      
      
      SP_QCUSTBROWSER
      
      /* Formatted on 5/21/2023 5:23:01 PM (QP5 v5.388) */
  SELECT *
    FROM TRAN2023
   WHERE     TRAN_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
         AND TRAN_BRN_CODE = :1
         AND TRAN_DATE_OF_TRAN = :2
         AND TRAN_BATCH_NUMBER = :3
ORDER BY TRAN_BATCH_SL_NUM
FOR UPDATE


/* Formatted on 5/22/2023 4:10:26 PM (QP5 v5.388) */
SELECT A.ACNTS_BRN_CODE,
       A.ACNTS_INTERNAL_ACNUM,
       A.ACNTS_CURR_CODE,
       A.ACNTS_PROD_CODE,
       A.ACNTS_AC_NAME1,
       PRODUCT_NAME
  FROM ACNTS A, PRODUCTS
 WHERE     A.ACNTS_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
       AND (   A.ACNTS_CLOSURE_DATE IS NULL
            OR A.ACNTS_CLOSURE_DATE > '01-MAY-23')
       AND A.ACNTS_PROD_CODE = PRODUCT_CODE
       AND PRODUCT_FOR_LOANS = '1'