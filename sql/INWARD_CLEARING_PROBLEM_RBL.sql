/* Formatted on 6/11/2023 5:20:16 PM (QP5 v5.388) */
INSERT INTO BOPAUTHQ (BOPAUTHQ_ENTITY_NUM,
                      BOPAUTHQ_TRAN_BRN_CODE,
                      BOPAUTHQ_TRAN_DATE_OF_TRAN,
                      BOPAUTHQ_TRAN_BATCH_NUMBER,
                      BOPAUTHQ_TRAN_BATCH_SL_NUM,
                      BOPAUTHQ_PGM_ID,
                      BOPAUTHQ_MODULE_CODE,
                      BOPAUTHQ_SOURCE_TABLE,
                      BOPAUTHQ_SOURCE_KEY_VALUE,
                      BOPAUTHQ_ASSOCIATE_AC_NUM,
                      BOPAUTHQ_ASSOCIATE_CLIENT_NUM,
                      BOPAUTHQ_TRANBAT_NARR1,
                      BOPAUTHQ_TRANBAT_NARR2,
                      BOPAUTHQ_TRANBAT_NARR3,
                      BOPAUTHQ_ENTD_BY,
                      BOPAUTHQ_ENTD_ON,
                      BOPAUTHQ_AMT_INVOLVED_IN_BC,
                      BOPAUTHQ_RISK_AUTH_REQ,
                      BOPAUTHQ_DBL_AUTH_REQ,
                      BOPAUTHQ_ENTRY_STATUS,
                      BOPAUTHQ_RISK_AUTH_REJ_BY,
                      BOPAUTHQ_RISK_AUTH_STATUS,
                      BOPAUTHQ_RISK_NOTES1,
                      BOPAUTHQ_RISK_NOTES2,
                      BOPAUTHQ_RISK_NOTES3,
                      BOPAUTHQ_FIRST_AUTH_REJ_BY,
                      BOPAUTHQ_FIRST_AUTH_STATUS,
                      BOPAUTHQ_FIRST_NOTES1,
                      BOPAUTHQ_FIRST_NOTES2,
                      BOPAUTHQ_FIRST_NOTES3,
                      BOPAUTHQ_FINAL_AUTH_REJ_BY,
                      BOPAUTHQ_FINAL_AUTH_REJ_ON,
                      BOPAUTHQ_FINAL_AUTH_STATUS,
                      BOPAUTHQ_FINAL_NOTES1,
                      BOPAUTHQ_FINAL_NOTES2,
                      BOPAUTHQ_FINAL_NOTES3,
                      BOPAUTHQ_TOTAL_STEPS,
                      BOPAUTHQ_CURRENT_STEP,
                      BOPAUTHQ_SUBBRN_CODE)
    SELECT TRANBAT_ENTITY_NUM,
           TRANBAT_BRN_CODE,
           TRANBAT_DATE_OF_TRAN,
           TRANBAT_BATCH_NUMBER,
           0,
           'ETRAN',
           'TRAN',
           'TRAN',
           B.TRANBAT_SOURCE_KEY,
           TRAN_INTERNAL_ACNUM,
           TRAN_PROFIT_CUST_CODE,
           TRANBAT_NARR_DTL1,
           TRANBAT_NARR_DTL2,
           TRANBAT_NARR_DTL3,
           TRAN_ENTD_BY,
           TRAN_ENTD_ON,
           TRANBAT_BASE_CURR_TOT_DB,
           '0',
           '0',
           'N',
           ' ',
           ' ',
           ' ',
           ' ',
           ' ',
           ' ',
           ' ',
           ' ',
           ' ',
           ' ',
           '',
           '',
           '',
           ' ',
           ' ',
           ' ',
           1,
           1,
           0
      FROM TRAN2023 T, TRANBAT2023 B
     WHERE     T.TRAN_ENTITY_NUM = B.TRANBAT_ENTITY_NUM
           AND T.TRAN_BRN_CODE = B.TRANBAT_BRN_CODE
           AND T.TRAN_DATE_OF_TRAN = B.TRANBAT_DATE_OF_TRAN
           AND T.TRAN_BATCH_NUMBER = B.TRANBAT_BATCH_NUMBER
           AND T.TRAN_ENTITY_NUM = 1
           AND TRAN_BATCH_SL_NUM = 1
           AND TRANBAT_SOURCE_TABLE = 'ICLG'
           AND T.TRAN_BRN_CODE = :TRAN_BRN_CODE
           AND TRAN_BATCH_NUMBER = :TRAN_BATCH_NUMBER
           AND T.TRAN_DATE_OF_TRAN = :tran_date;

----------------------------
UPDATE TRANBAT2023
   SET TRANBAT_SOURCE_TABLE = 'TRAN'
 WHERE     TRANBAT_BRN_CODE = :TRAN_BRN_CODE
       AND TRANBAT_BATCH_NUMBER = :TRAN_BATCH_NUMBER
       AND TRANBAT_DATE_OF_TRAN = :tran_date;


---REJECT THE BATCH FROM ABOPAUTHQ

--------------------------------------
UPDATE ICLGBATCH
   SET ICLGBAT_STATUS = 'C',
       ICLGBAT_CLOSED_DATE = :tran_date,
       ICLGBAT_CLOSED_BY = 'INTEELCT'
 WHERE     ICLGBAT_BRN_CODE = :TRAN_BRN_CODE
       AND POST_TRAN_BATCH_NUM = :TRAN_BATCH_NUMBER
       AND ICLGBAT_CLG_DATE = :tran_date;