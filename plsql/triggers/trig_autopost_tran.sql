CREATE OR REPLACE TRIGGER TRIG_AUTOPOST_TRAN
   BEFORE INSERT OR UPDATE
   ON AUTOPOST_TRAN
   FOR EACH ROW
DECLARE
   W_NON_CBS_BRN   NUMBER;
BEGIN
   BEGIN
      SELECT COUNT (*)
        INTO W_NON_CBS_BRN
        FROM MBRN
       WHERE MBRN_CODE = :NEW.BRN_CODE;

      IF W_NON_CBS_BRN = 0
      THEN
         RAISE_APPLICATION_ERROR (
            -20100,
            'You can not insert non cbs branch ' || :NEW.BRN_CODE||' for account '||:NEW.INT_AC_NO);
      END IF;

      SELECT COUNT (*)
        INTO W_NON_CBS_BRN
        FROM MBRN
       WHERE MBRN_CODE = :NEW.ACING_BRN_CODE;

      IF W_NON_CBS_BRN = 0
      THEN
         RAISE_APPLICATION_ERROR (
            -20101,
            'You can not insert non cbs branch ' || :NEW.ACING_BRN_CODE||' for account '||:NEW.INT_AC_NO);
      END IF;
   END;
END;
/
