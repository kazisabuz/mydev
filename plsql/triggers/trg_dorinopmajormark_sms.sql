CREATE OR REPLACE TRIGGER TRG_DORINOPMAJORMARK_SMS
   BEFORE UPDATE OF ACNTS_DORMANT_ACNT, ACNTS_MINOR_ACNT
   ON ACNTS
   FOR EACH ROW
DECLARE
   V_AC_NUM         NUMBER;
   V_BRN_CODE       NUMBER;
   V_CBD            DATE;
   V_DORMANT_ACNT   CHAR (1);
   V_MINOR_ACNT     CHAR (1);

BEGIN
   V_AC_NUM := :NEW.ACNTS_INTERNAL_ACNUM;
   V_BRN_CODE := :NEW.ACNTS_BRN_CODE;
   V_DORMANT_ACNT := :NEW.ACNTS_DORMANT_ACNT;
   V_MINOR_ACNT := :NEW.ACNTS_MINOR_ACNT;
   V_CBD := PKG_PB_GLOBAL.FN_GET_CURR_BUS_DATE (:NEW.ACNTS_ENTITY_NUM);

   IF V_DORMANT_ACNT = '1' AND :OLD.ACNTS_DORMANT_ACNT = '0'
   THEN
      INSERT INTO SMSALERTQ (SMSALERTQ_ENTITY_NUM,
                             SMSALERTQ_TYPE,
                             SMSALERTQ_BRN_CODE,
                             SMSALERTQ_DATE_OF_TRAN,
                             SMSALERTQ_BATCH_NUMBER,
                             SMSALERTQ_BATCH_SL_NUM,
                             SMSALERTQ_SRC_TABLE,
                             SMSALERTQ_SRC_KEY,
                             SMSALERTQ_DISP_TEXT,
                             SMSALERTQ_REQ_TIME)
           VALUES (:NEW.ACNTS_ENTITY_NUM,
                   'AC',
                   V_BRN_CODE,
                   V_CBD,
                   0,
                   0,
                   'DORMNT',
                   V_AC_NUM,
                   ' ',
                   SYSDATE);
   END IF;


   IF V_MINOR_ACNT = '0' AND :OLD.ACNTS_MINOR_ACNT = '1'
   THEN
      INSERT INTO SMSALERTQ (SMSALERTQ_ENTITY_NUM,
                             SMSALERTQ_TYPE,
                             SMSALERTQ_BRN_CODE,
                             SMSALERTQ_DATE_OF_TRAN,
                             SMSALERTQ_BATCH_NUMBER,
                             SMSALERTQ_BATCH_SL_NUM,
                             SMSALERTQ_SRC_TABLE,
                             SMSALERTQ_SRC_KEY,
                             SMSALERTQ_DISP_TEXT,
                             SMSALERTQ_REQ_TIME)
           VALUES (:NEW.ACNTS_ENTITY_NUM,
                   'AC',
                   V_BRN_CODE,
                   V_CBD,
                   0,
                   0,
                   'MAJOR',
                   V_AC_NUM,
                   ' ',
                   SYSDATE);
   END IF;
END TRG_DORINOPMAJORMARK_SMS;
/
