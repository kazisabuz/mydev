CREATE OR REPLACE TRIGGER TRIG_INSERT_OCLGRTN          
   AFTER INSERT ON OCLGRTN
   FOR EACH ROW
BEGIN
   PKG_ENTITY.SP_SET_ENTITY_CODE(:NEW.OCLGRTN_ENTITY_NUM);

   IF INSERTING THEN
     PKG_ALERT.SP_INSERT_SMSALERT(:NEW.OCLGRTN_ENTITY_NUM,
                                  'OR',
                                  0,
                                  SYSDATE,
                                  0,
                                  0,
                                  'OCLGRTN',
                                  :NEW.OCLGRTN_BRN_CODE || '|' ||
                                  TO_CHAR(:NEW.OCLGRTN_CLG_DATE, 'DD-MM-YYYY') || '|' ||
                                  :NEW.OCLGRTN_CLG_BATCH || '|' ||
                                  :NEW.OCLGRTN_DTL_SL,
                                  ' ');
   END IF;
 END TRIG_INSERT_OCLGRTN;
/
