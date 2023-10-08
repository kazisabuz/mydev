CREATE OR REPLACE TRIGGER TRIG_INS_UPD_LNDISBINTIM          
 AFTER INSERT  ON LNDISBINTIM
   FOR EACH ROW
declare
   W_APPL_YEAR    NUMBER;
   W_APPL_SL      NUMBER;
   LNGRP_AVL      BOOLEAN;
   W_ERR_MSG      VARCHAR2(1000);
   W_USR_ENTED_BY VARCHAR2(8);
   W_CLIENT_NUM   NUMBER;
   SYN_DT         SPLITSTR;

   PROCEDURE PROCESS_COMMON IS
   BEGIN
     FOR IX IN PKG_ALERT_PROC.SYNONIM_DTL.FIRST .. PKG_ALERT_PROC.SYNONIM_DTL.LAST LOOP
       SYN_DT := SPLIT(PKG_ENTITY.FN_GET_ENTITY_CODE, PKG_ALERT_PROC.SYNONIM_DTL(IX).W_SYNONIM_DTL, '##');
       PKG_ALERT_PROC.SYNONIM_DTL(IX).W_SYNONIM_DTL := '';
       FOR IXX IN 1 .. SYN_DT.COUNT LOOP
         IF (TRIM(SYN_DT(IXX)) = 'SYNCLIENTNAME') THEN
           IF (TRIM(PKG_ALERT_PROC.SYNONIM_DTL(IX).W_SYNONIM_DTL) IS NULL) THEN
             PKG_ALERT_PROC.SYNONIM_DTL(IX).W_SYNONIM_DTL := SYN_DT(IXX) || '@@' ||
                                                             W_CLIENT_NUM;
           ELSE
             PKG_ALERT_PROC.SYNONIM_DTL(IX).W_SYNONIM_DTL := PKG_ALERT_PROC.SYNONIM_DTL(IX)
                                                            .W_SYNONIM_DTL || '##' ||
                                                             SYN_DT(IXX) || '@@' ||
                                                             W_CLIENT_NUM;
           END IF;
         ELSIF (TRIM(SYN_DT(IXX)) = 'SYNAPPLNUM') THEN
           IF (TRIM(PKG_ALERT_PROC.SYNONIM_DTL(IX).W_SYNONIM_DTL) IS NULL) THEN
             PKG_ALERT_PROC.SYNONIM_DTL(IX).W_SYNONIM_DTL := SYN_DT(IXX) || '@@' ||
                                                             W_APPL_YEAR || '|' ||
                                                             W_APPL_SL;
           ELSE
             PKG_ALERT_PROC.SYNONIM_DTL(IX).W_SYNONIM_DTL := PKG_ALERT_PROC.SYNONIM_DTL(IX)
                                                            .W_SYNONIM_DTL || '##' ||
                                                             SYN_DT(IXX) || '@@' ||
                                                             W_APPL_YEAR || '|' ||
                                                             W_APPL_SL;
           END IF;
         END IF;
       END LOOP;
     END LOOP;
   END PROCESS_COMMON;

 begin
   LNGRP_AVL      := FALSE;
   W_APPL_YEAR    := :NEW.LNDISBINTIM_LNAPPL_YR;
   W_APPL_SL      := :NEW.LNDISBINTIM_LNAPPL_SL_NUM;
   W_USR_ENTED_BY := :NEW.LNDISBINTIM_ENTD_BY;


       PKG_ENTITY.SP_SET_ENTITY_CODE(:NEW.LNDISBINTIM_ENTITY_NUM);



   FOR IDX IN (SELECT LNAPGRPREQ_CLIENT_CODE
                 FROM LNAPGRPREQ
                WHERE LNAPGRPREQ_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND  LNAPGRPREQ_YEAR = W_APPL_YEAR
                  AND LNAPGRPREQ_SL_NUM = W_APPL_SL) LOOP
     LNGRP_AVL                := TRUE;
     PKG_ALERT_PROC.P_TEMP_SL := PKG_PB_GLOBAL.SP_GET_REPORT_SL(PKG_ENTITY.FN_GET_ENTITY_CODE);
     PKG_ALERT_PROC.GET_ALERT_MSG_SYNONYMS(PKG_ENTITY.FN_GET_ENTITY_CODE, 1, W_ERR_MSG);
     W_CLIENT_NUM := IDX.LNAPGRPREQ_CLIENT_CODE;
     IF (TRIM(W_ERR_MSG) IS NULL) THEN
       IF (PKG_ALERT_PROC.SYNONIM_DTL.COUNT > 0) THEN
         PROCESS_COMMON;
       END IF;
     END IF;
     PKG_ALERT_PROC.P_USER_LIST    := IDX.LNAPGRPREQ_CLIENT_CODE;
     PKG_ALERT_PROC.P_PROG_ID      := 'ELNAPPLICATION';
     PKG_ALERT_PROC.P_FROM_USER    := W_USR_ENTED_BY;
     PKG_ALERT_PROC.P_SUBJECT_LINE := 'Loan Sanction Alert Message';
     PKG_ALERT_PROC.GET_ACTUAL_ALERT_MESSAGE(PKG_ENTITY.FN_GET_ENTITY_CODE);
     DBMS_OUTPUT.put_line(PKG_ALERT_PROC.P_TEMP_SL);

   END LOOP;
   IF (LNGRP_AVL = FALSE) THEN
     SELECT LNAPPL_FIRST_APPLICANT
       INTO W_CLIENT_NUM
       FROM LNAPPL
      WHERE LNAPPL_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND  LNAPPL_YEAR = W_APPL_YEAR
        AND LNAPPL_SL_NUM = W_APPL_SL;

     PKG_ALERT_PROC.P_TEMP_SL := PKG_PB_GLOBAL.SP_GET_REPORT_SL(PKG_ENTITY.FN_GET_ENTITY_CODE);
     PKG_ALERT_PROC.GET_ALERT_MSG_SYNONYMS(PKG_ENTITY.FN_GET_ENTITY_CODE, 1, W_ERR_MSG);

     IF (TRIM(W_ERR_MSG) IS NULL) THEN
       IF (PKG_ALERT_PROC.SYNONIM_DTL.COUNT > 0) THEN
         PROCESS_COMMON;
       END IF;
     END IF;
     PKG_ALERT_PROC.P_USER_LIST    := W_CLIENT_NUM;
     PKG_ALERT_PROC.P_PROG_ID      := 'ELNAPPLICATION';
     PKG_ALERT_PROC.P_FROM_USER    := W_USR_ENTED_BY;
     PKG_ALERT_PROC.P_SUBJECT_LINE := 'Loan Sanction Alert Message';
     PKG_ALERT_PROC.GET_ACTUAL_ALERT_MESSAGE(PKG_ENTITY.FN_GET_ENTITY_CODE);
     DBMS_OUTPUT.put_line(PKG_ALERT_PROC.P_TEMP_SL);
   END IF;
 end TRIG_INS_UPD_LNDISPINTIM;
/
