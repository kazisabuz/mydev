CREATE OR REPLACE TRIGGER TRIG_INS_BRNLIMITEXCD          
   after insert on brnlimitexcd
   for each row
declare
   W_BRLIMITEXCD_BRN_CODE NUMBER;
   W_BRLIMITEXCD_CURR     VARCHAR2(3);
   W_BRLIMITEXCD_DATE     DATE;
   W_ERR_MSG              VARCHAR2(1000);
   W_BRLIMITEXCD_ENTD_BY  VARCHAR2(8);
   SYN_DT                 SPLITSTR;

   W_ALERT_REQ                 BOOLEAN;
   W_CSM_BRN_CSH_LMT_ALERT_REQ CHAR;

 begin

       PKG_ENTITY.SP_SET_ENTITY_CODE(:NEW.BRLIMITEXCD_ENTITY_NUM);


   W_BRLIMITEXCD_BRN_CODE := :NEW.BRLIMITEXCD_BRN_CODE;
   W_BRLIMITEXCD_DATE     := :NEW.BRLIMITEXCD_DATE;
   W_BRLIMITEXCD_CURR     := :NEW.BRLIMITEXCD_CURR;
   W_BRLIMITEXCD_ENTD_BY  := :NEW.BRLIMITEXCD_ENTD_BY;

   <<PROCESS_CSOCLPM>>
   BEGIN
     W_ALERT_REQ := FALSE;
     SELECT CSOCLPM_BRN_CSH_LMT_ALERT_REQ
       INTO W_CSM_BRN_CSH_LMT_ALERT_REQ
       FROM CASHSOCLPM
      WHERE CSOCLPM_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND  CSOCLPM_BRN_CODE = W_BRLIMITEXCD_BRN_CODE;
     IF (TRIM(W_CSM_BRN_CSH_LMT_ALERT_REQ) = '1') THEN
       W_ALERT_REQ := TRUE;
     END IF;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       W_ALERT_REQ := FALSE;
   END PROCESS_CSOCLPM;

   IF (W_ALERT_REQ) THEN
     PKG_ALERT_PROC.P_TEMP_SL := PKG_PB_GLOBAL.SP_GET_REPORT_SL(PKG_ENTITY.FN_GET_ENTITY_CODE);
     PKG_ALERT_PROC.GET_ALERT_MSG_SYNONYMS(PKG_ENTITY.FN_GET_ENTITY_CODE,3, W_ERR_MSG);
     IF (TRIM(W_ERR_MSG) IS NULL) THEN

       IF (PKG_ALERT_PROC.SYNONIM_DTL.COUNT > 0) THEN
         PKG_ALERT_PROC.P_CURR_AMT := :NEW.BRLIMITEXCD_BR_LIMIT;
         FOR IX IN PKG_ALERT_PROC.SYNONIM_DTL.FIRST .. PKG_ALERT_PROC.SYNONIM_DTL.LAST LOOP
           SYN_DT := SPLIT(PKG_ENTITY.FN_GET_ENTITY_CODE,PKG_ALERT_PROC.SYNONIM_DTL(IX).W_SYNONIM_DTL,
                           '##');
           PKG_ALERT_PROC.SYNONIM_DTL(IX).W_SYNONIM_DTL := '';
           FOR IXX IN 1 .. SYN_DT.COUNT LOOP
             IF (TRIM(SYN_DT(IXX)) = 'SYNTELLBRNDTL') THEN
               IF (TRIM(PKG_ALERT_PROC.SYNONIM_DTL(IX).W_SYNONIM_DTL) IS NULL) THEN
                 PKG_ALERT_PROC.SYNONIM_DTL(IX).W_SYNONIM_DTL := SYN_DT(IXX) || '@@' ||
                                                                 W_BRLIMITEXCD_BRN_CODE;
               ELSE
                 PKG_ALERT_PROC.SYNONIM_DTL(IX).W_SYNONIM_DTL := PKG_ALERT_PROC.SYNONIM_DTL(IX)
                                                                .W_SYNONIM_DTL || '##' ||
                                                                 SYN_DT(IXX) || '@@' ||
                                                                 W_BRLIMITEXCD_BRN_CODE;
               END IF;
             ELSIF (TRIM(SYN_DT(IXX)) = 'SYNTELLCURRCODE') THEN
               IF (TRIM(PKG_ALERT_PROC.SYNONIM_DTL(IX).W_SYNONIM_DTL) IS NULL) THEN
                 PKG_ALERT_PROC.SYNONIM_DTL(IX).W_SYNONIM_DTL := SYN_DT(IXX) || '@@' ||
                                                                 W_BRLIMITEXCD_CURR;
               ELSE
                 PKG_ALERT_PROC.SYNONIM_DTL(IX).W_SYNONIM_DTL := PKG_ALERT_PROC.SYNONIM_DTL(IX)
                                                                .W_SYNONIM_DTL || '##' ||
                                                                 SYN_DT(IXX) || '@@' ||
                                                                 W_BRLIMITEXCD_CURR;
               END IF;
             ELSIF (TRIM(SYN_DT(IXX)) = 'SYNTELLAMOUNT') THEN
               IF (TRIM(PKG_ALERT_PROC.SYNONIM_DTL(IX).W_SYNONIM_DTL) IS NULL) THEN
                 PKG_ALERT_PROC.SYNONIM_DTL(IX).W_SYNONIM_DTL := SYN_DT(IXX) || '@@' ||
                                                                 W_BRLIMITEXCD_CURR;
               ELSE
                 PKG_ALERT_PROC.SYNONIM_DTL(IX).W_SYNONIM_DTL := PKG_ALERT_PROC.SYNONIM_DTL(IX)
                                                                .W_SYNONIM_DTL || '##' ||
                                                                 SYN_DT(IXX) || '@@' ||
                                                                 W_BRLIMITEXCD_CURR;
               END IF;
             ELSIF (TRIM(SYN_DT(IXX)) = 'SYNTELLCBD') THEN
               IF (TRIM(PKG_ALERT_PROC.SYNONIM_DTL(IX).W_SYNONIM_DTL) IS NULL) THEN
                 PKG_ALERT_PROC.SYNONIM_DTL(IX).W_SYNONIM_DTL := SYN_DT(IXX) || '@@' ||
                                                                 W_BRLIMITEXCD_CURR;
               ELSE
                 PKG_ALERT_PROC.SYNONIM_DTL(IX).W_SYNONIM_DTL := PKG_ALERT_PROC.SYNONIM_DTL(IX)
                                                                .W_SYNONIM_DTL || '##' ||
                                                                 SYN_DT(IXX) || '@@' ||
                                                                 W_BRLIMITEXCD_CURR;
               END IF;
             END IF;
           END LOOP;
         END LOOP;
         PKG_ALERT_PROC.P_BRN_CODE     := W_BRLIMITEXCD_BRN_CODE;
         PKG_ALERT_PROC.P_PROG_ID      := 'ECASHCLS';
         PKG_ALERT_PROC.P_FROM_USER    := W_BRLIMITEXCD_ENTD_BY;
         PKG_ALERT_PROC.P_SUBJECT_LINE := 'Branch cash retention limit Alert message';
         PKG_ALERT_PROC.GET_ACTUAL_ALERT_MESSAGE(PKG_ENTITY.FN_GET_ENTITY_CODE);
         DBMS_OUTPUT.put_line(PKG_ALERT_PROC.P_TEMP_SL);
       END IF;
     END IF;
   END IF;
 end TRIG_INS_BRNLIMITEXCD;
/
