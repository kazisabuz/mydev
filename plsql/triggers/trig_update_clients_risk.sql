CREATE OR REPLACE TRIGGER TRIG_UPDATE_CLIENTS_RISK          
    BEFORE UPDATE
    OF CLIENTS_RISK_CATEGORIZATION
    ON CLIENTS
    FOR EACH ROW
BEGIN
    IF (:NEW.CLIENTS_RISK_CATEGORIZATION <> :OLD.CLIENTS_RISK_CATEGORIZATION) THEN
      FOR IDX IN (SELECT ACNTS_ENTITY_NUM,ACNTS_INTERNAL_ACNUM
                    FROM ACNTS A
                   WHERE   A.ACNTS_CLIENT_NUM = :NEW.CLIENTS_CODE) LOOP
        <<UPDATEAMLACNTCLTURNOVER>>
        BEGIN
          UPDATE AMLACNTCL B
             SET B.AMLACNTCL_RISK_CATE = :NEW.CLIENTS_RISK_CATEGORIZATION
           WHERE B.AMLACNTCL_ENTITY_NUM = IDX.ACNTS_ENTITY_NUM AND B.AMLACNTCL_INTERNAL_ACNUM = IDX.ACNTS_INTERNAL_ACNUM;
/*          UPDATE AMLACTURNOVER C
             SET C.ACTOVER_CLIENT_RISK_CATG = :NEW.CLIENTS_RISK_CATEGORIZATION
           WHERE C.ACTOVER_INTERNAL_ACNUM = IDX.ACNTS_INTERNAL_ACNUM; */ -- AGK - CHN-06-APR-2010, IF STATUS CHANGED, IT WILL BE APPLICABLE ONLY FROM NEXT DAY
        END UPDATEAMLACNTCLTURNOVER;
      END LOOP;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20998,
                              'Error in updating risk cat changing - AMLACTURNOVER - TRIG_UPDATE_CLIENTS_RISK');
  END TRIG_UPDATE_CLIENTS_RISK;
/