CREATE OR REPLACE TRIGGER MPGM_ID_CHK          
       BEFORE INSERT OR UPDATE OF  MPGM_ID ON MPGM
       FOR EACH ROW
BEGIN
          :new.MPGM_ID := UPPER(:new.MPGM_ID);
       END;
/
