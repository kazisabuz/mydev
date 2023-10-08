CREATE OR REPLACE TRIGGER TRIG_INSERT_ICLG          
   AFTER INSERT OR UPDATE OF ICLG_RTN_FLAG ON ICLG
   FOR EACH ROW
BEGIN
   PKG_ENTITY.SP_SET_ENTITY_CODE(:NEW.ICLG_ENTITY_NUM);

   IF NVL(:NEW.ICLG_RTN_FLAG,'0') = '1'  THEN
     PKG_ALERT.SP_INSERT_SMSALERT(:NEW.ICLG_ENTITY_NUM,
                                  'IR',
                                  0,
                                  SYSDATE,
                                  0,
                                  0,
                                  'ICLG',
                                  :NEW.ICLG_BRN_CODE || '|' ||
                                  TO_CHAR(:NEW.ICLG_CLG_DATE, 'DD-MM-YYYY') || '|' ||
                                  :NEW.ICLG_CLG_BATCH || '|' ||
                                  :NEW.ICLG_INST_SL,
                                  ' ');
   END IF;
 END TRIG_INSERT_ICLG;
/
