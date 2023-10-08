CREATE OR REPLACE TRIGGER "TRIG_INSERT_TELBAL"       
   AFTER INSERT OR UPDATE OF TELBAL_GOOD_BALANCE,TELBAL_SOILED_BALANCE,TELBAL_CUT_BALANCE ON TELBAL
   FOR EACH ROW
declare
   W_TELBAL_BRN_CODE        NUMBER;
   W_TELBAL_CT_ID           VARCHAR2(8);
   W_TELBAL_AMT             NUMBER;
   W_EXCEED                 CHAR;
   W_ERR_MSG                VARCHAR2(1000);
   SYN_DT                   SPLITSTR;
   W_ALERT_REQ              BOOLEAN;
   W_CSOCLPM_TELLER_LMT_CHK CHAR;
 begin

       PKG_ENTITY.SP_SET_ENTITY_CODE(:NEW.TELBAL_ENTITY_NUM);


   W_TELBAL_BRN_CODE := :NEW.TELBAL_BRN_CODE;
   W_TELBAL_CT_ID    := :NEW.TELBAL_CT_ID;
   W_TELBAL_AMT      := :NEW.TELBAL_GOOD_BALANCE +
                        :NEW.TELBAL_SOILED_BALANCE + :NEW.TELBAL_CUT_BALANCE;

   <<PROCESS_CSOCLPM>>
   BEGIN
     W_ALERT_REQ := FALSE;
     SELECT CSOCLPM_TELLER_LMT_CHK
       INTO W_CSOCLPM_TELLER_LMT_CHK
       FROM CASHSOCLPM
      WHERE CSOCLPM_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND CSOCLPM_BRN_CODE = W_TELBAL_BRN_CODE;
     IF (TRIM(W_CSOCLPM_TELLER_LMT_CHK) = '1') THEN
       W_ALERT_REQ := TRUE;
     END IF;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       W_ALERT_REQ := FALSE;
   END PROCESS_CSOCLPM;
   IF (W_ALERT_REQ) THEN
     SP_CHK_TELLER_RET_LIMIT( PKG_ENTITY.FN_GET_ENTITY_CODE, W_TELBAL_BRN_CODE || '|' || W_TELBAL_CT_ID || '|' ||
                             W_TELBAL_AMT,
                             W_EXCEED,
                             W_ERR_MSG);
     IF (TRIM(W_ERR_MSG) IS NULL) THEN
       IF (W_EXCEED = '1') THEN
         PKG_ALERT_PROC.P_TEMP_SL := PKG_PB_GLOBAL.SP_GET_REPORT_SL(PKG_ENTITY.FN_GET_ENTITY_CODE);
         PKG_ALERT_PROC.GET_ALERT_MSG_SYNONYMS(PKG_ENTITY.FN_GET_ENTITY_CODE, 2, W_ERR_MSG);
         IF (TRIM(W_ERR_MSG) IS NULL) THEN
           IF (PKG_ALERT_PROC.SYNONIM_DTL.COUNT > 0) THEN
             FOR IX IN PKG_ALERT_PROC.SYNONIM_DTL.FIRST .. PKG_ALERT_PROC.SYNONIM_DTL.LAST LOOP
               SYN_DT := SPLIT(PKG_ENTITY.FN_GET_ENTITY_CODE, PKG_ALERT_PROC.SYNONIM_DTL(IX).W_SYNONIM_DTL,
                               '##');
               PKG_ALERT_PROC.SYNONIM_DTL(IX).W_SYNONIM_DTL := '';
               FOR IXX IN 1 .. SYN_DT.COUNT LOOP
                 IF (TRIM(SYN_DT(IXX)) = 'SYNTELLNAME') THEN
                   IF (TRIM(PKG_ALERT_PROC.SYNONIM_DTL(IX).W_SYNONIM_DTL) IS NULL) THEN
                     PKG_ALERT_PROC.SYNONIM_DTL(IX).W_SYNONIM_DTL := SYN_DT(IXX) || '@@' ||
                                                                     W_TELBAL_CT_ID;
                   ELSE
                     PKG_ALERT_PROC.SYNONIM_DTL(IX).W_SYNONIM_DTL := PKG_ALERT_PROC.SYNONIM_DTL(IX)
                                                                    .W_SYNONIM_DTL || '##' ||
                                                                     SYN_DT(IXX) || '@@' ||
                                                                     W_TELBAL_CT_ID;
                   END IF;
                 ELSIF (TRIM(SYN_DT(IXX)) = 'SYNTELLBRNDTL') THEN
                   IF (TRIM(PKG_ALERT_PROC.SYNONIM_DTL(IX).W_SYNONIM_DTL) IS NULL) THEN
                     PKG_ALERT_PROC.SYNONIM_DTL(IX).W_SYNONIM_DTL := SYN_DT(IXX) || '@@' ||
                                                                     W_TELBAL_BRN_CODE;
                   ELSE
                     PKG_ALERT_PROC.SYNONIM_DTL(IX).W_SYNONIM_DTL := PKG_ALERT_PROC.SYNONIM_DTL(IX)
                                                                    .W_SYNONIM_DTL || '##' ||
                                                                     SYN_DT(IXX) || '@@' ||
                                                                     W_TELBAL_BRN_CODE;
                   END IF;
                 END IF;
               END LOOP;
             END LOOP;

             PKG_ALERT_PROC.P_BRN_CODE     := W_TELBAL_BRN_CODE;
             PKG_ALERT_PROC.P_PROG_ID      := 'ECASHRP';
             PKG_ALERT_PROC.P_FROM_USER    := W_TELBAL_CT_ID;
             PKG_ALERT_PROC.P_SUBJECT_LINE := 'TELLER BALANCE LIMIT EXCEDED';
             PKG_ALERT_PROC.GET_ACTUAL_ALERT_MESSAGE(PKG_ENTITY.FN_GET_ENTITY_CODE);
             DBMS_OUTPUT.put_line(PKG_ALERT_PROC.P_TEMP_SL);
           END IF;
         END IF;
       END IF;
     END IF;
   END IF;
 end TRIG_INSERT_TELBAL;
/
