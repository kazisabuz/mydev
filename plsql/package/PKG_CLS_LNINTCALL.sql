CREATE OR REPLACE PACKAGE BODY PKG_CLS_LNINTCALL IS

    PROCEDURE SP_CLS_LNINTCALL(V_ENTITY_NUM IN NUMBER,P_INTERNAL_ACNUM       IN NUMBER,
                           P_BRN_CODE             IN NUMBER,
                           P_ACCTUAL_PROCESS_DATE IN DATE,
                           P_CBD                  IN DATE,
                           P_USER_ID              IN VARCHAR2,
                           P_BATCH_NUM            OUT VARCHAR2,
                           P_ERRMSG               OUT VARCHAR2) IS
      W_ERRORMSG      VARCHAR2(1800);
      W_INT_APPL_FREQ CHAR(1);
      W_BATCH_NUM     NUMBER DEFAULT 0;
      V_REVERSAL_BATCH_NUM NUMBER DEFAULT 0;
      USR_EXCEPTION EXCEPTION;
      PROCEDURE CHECK_INPUT IS
      BEGIN
        IF (P_INTERNAL_ACNUM IS NULL OR P_INTERNAL_ACNUM = 0) THEN
          W_ERRORMSG := 'ACCOUNT NUMBER SHOULD NOT BE ZERO';
        ELSIF (P_BRN_CODE IS NULL OR P_BRN_CODE = 0) THEN
          W_ERRORMSG := 'BRANCH CODE SHOULD NOT BE ZERO';
        ELSIF (P_ACCTUAL_PROCESS_DATE IS NULL) THEN
          W_ERRORMSG := 'ACTUAL PROCESS DATE SHOULD NOT BE NULL';
        ELSIF (P_CBD IS NULL) THEN
          W_ERRORMSG := 'CURRENT BUSSINESS DATE SHOULD NOT BE NULL';
        ELSIF (TRIM(P_USER_ID) IS NULL) THEN
          W_ERRORMSG := 'USER ID SHOULD NOT BE NULL';
        END IF;
      END CHECK_INPUT;
    BEGIN
  --ENTITY CODE COMMONLY ADDED - 06-11-2009  - BEG
        PKG_ENTITY.SP_SET_ENTITY_CODE(V_ENTITY_NUM);
  --ENTITY CODE COMMONLY ADDED - 06-11-2009  - END
      W_BATCH_NUM := 0; -- ADDED BY BIBHU ON 29-11-2012
      <<STARTPROCESS>>
      BEGIN
        W_ERRORMSG := '';
        CHECK_INPUT;
        IF (TRIM(W_ERRORMSG) IS NOT NULL) THEN
          RAISE USR_EXCEPTION;
        END IF;

        PKG_LNACCRUE_REV_PROC.PROC_INT_CALC(PKG_ENTITY.FN_GET_ENTITY_CODE,P_BRN_CODE,
         P_INTERNAL_ACNUM, P_CBD,P_USER_ID,0,3); --- 3 For BL Loan
        V_REVERSAL_BATCH_NUM := FN_GET_AUTOPOST_BATCH_NUMBER(PKG_ENTITY.FN_GET_ENTITY_CODE);

        W_ERRORMSG := PKG_EODSOD_FLAGS.PV_ERROR_MSG;

        IF (TRIM(W_ERRORMSG) IS NOT NULL) THEN
            V_REVERSAL_BATCH_NUM := 0;
            P_BATCH_NUM := 0;
            RAISE USR_EXCEPTION;
        END IF;

        PKG_EODSOD_FLAGS.PV_PROCESS_NAME := 'SP_LNINTCALL';
        PKG_EODSOD_FLAGS.PV_USER_ID      := P_USER_ID;
        PKG_EODSOD_FLAGS.PV_CURRENT_DATE := P_ACCTUAL_PROCESS_DATE;
        PKG_LOAN_CLS_ACCR_PROCESS.W_CALL_FROM_LNINITCALL:=TRUE;                 ----- added by rajib.pradhan for improve performance
        PKG_LOAN_CLS_ACCR_PROCESS.PROC_INT_CALC_FOR_CLS(PKG_ENTITY.FN_GET_ENTITY_CODE,P_BRN_CODE, P_INTERNAL_ACNUM,W_BATCH_NUM);
        W_ERRORMSG := PKG_EODSOD_FLAGS.PV_ERROR_MSG;
        IF (TRIM(W_ERRORMSG) IS NOT NULL) THEN
          P_BATCH_NUM := 0; -- ADDED BY BIBHU ON 29-11-2012
          RAISE USR_EXCEPTION;
        -- ADDED BY BIBHU ON 29-11-2012 BEGIN
        ELSE
          /*IF W_BATCH_NUM IS NULL THEN
          P_BATCH_NUM := 0;
          ELSE
           P_BATCH_NUM := W_BATCH_NUM;
           END IF;*/


          IF nvl(V_REVERSAL_BATCH_NUM, 0) != 0 AND nvl(W_BATCH_NUM, 0) != 0 THEN
            P_BATCH_NUM := V_REVERSAL_BATCH_NUM||','||W_BATCH_NUM;
          END IF;
          IF nvl(V_REVERSAL_BATCH_NUM, 0) = 0 AND nvl(W_BATCH_NUM, 0) != 0 THEN
            P_BATCH_NUM := W_BATCH_NUM;
          END IF;
          IF nvl(V_REVERSAL_BATCH_NUM, 0) = 0 AND nvl(W_BATCH_NUM, 0) = 0 THEN
            P_BATCH_NUM := 0;
          END IF;

        -- ADDED BY BIBHU ON 29-11-2012 END
        END IF;
        --Prasanth NS-12-09-2009-beg
        <<GET_FREQ_FLG>>
        BEGIN
          SELECT LNPRD_INT_APPL_FREQ
            INTO W_INT_APPL_FREQ
            FROM LNPRODPM L
           WHERE L.LNPRD_PROD_CODE =
                 (SELECT ACNTS_PROD_CODE
                    FROM ACNTS
                    WHERE ACNTS_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND  ACNTS_INTERNAL_ACNUM = P_INTERNAL_ACNUM);
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            W_INT_APPL_FREQ := '';
        END GET_FREQ_FLG;
        --Prasanth NS-12-09-2009-end

        --Prasanth NS-12-09-2009-ADDED
        IF (W_INT_APPL_FREQ <> 'I') THEN
          PKG_EODSOD_FLAGS.PV_CURRENT_DATE  := P_CBD;
          PKG_EODSOD_FLAGS.PV_PREVIOUS_DATE := P_ACCTUAL_PROCESS_DATE; --ARUNMUGESH 27-12-2007 ADD
          PKG_LNINTAPPLY.SP_INTAPPLY(PKG_ENTITY.FN_GET_ENTITY_CODE,P_BRN_CODE, 0, ' ', P_INTERNAL_ACNUM);
          W_ERRORMSG := PKG_EODSOD_FLAGS.PV_ERROR_MSG; --AGK-10-SEP-2008-ADD
          IF (TRIM(W_ERRORMSG) IS NOT NULL) THEN
            RAISE USR_EXCEPTION;
          END IF;
        END IF;

        --Prasanth NS-12-09-2009-beg
        IF (W_INT_APPL_FREQ = 'I') THEN
          PKG_EODSOD_FLAGS.PV_PROCESS_NAME := 'PKG_LNIARNDOFFPOST.SP_LNIARNDOFFPOST';
          PKG_LNIARNDOFFPOST.SP_LNIARNDOFFPOST(PKG_ENTITY.FN_GET_ENTITY_CODE,P_BRN_CODE,
                                               0,
                                               P_INTERNAL_ACNUM);
          W_ERRORMSG := PKG_EODSOD_FLAGS.PV_ERROR_MSG;
          IF (TRIM(W_ERRORMSG) IS NOT NULL) THEN
            RAISE USR_EXCEPTION;
          END IF;

          PKG_EODSOD_FLAGS.PV_PROCESS_NAME := 'PKG_LNODIFREQ.SP_LNODIFREQ';
          PKG_LNODIFREQ.SP_LNODIFREQ(PKG_ENTITY.FN_GET_ENTITY_CODE,P_BRN_CODE, 0, P_INTERNAL_ACNUM);
          W_ERRORMSG := PKG_EODSOD_FLAGS.PV_ERROR_MSG;
          IF (TRIM(W_ERRORMSG) IS NOT NULL) THEN
            RAISE USR_EXCEPTION;
          END IF;

          PKG_EODSOD_FLAGS.PV_PROCESS_NAME := 'PKG_LN_PENALCALC.SP_CALC_PENALTY';
          PKG_LN_PENALCALC.SP_CALC_PENALTY(PKG_ENTITY.FN_GET_ENTITY_CODE,P_BRN_CODE, P_INTERNAL_ACNUM);
          W_ERRORMSG := PKG_EODSOD_FLAGS.PV_ERROR_MSG;
          IF (TRIM(W_ERRORMSG) IS NOT NULL) THEN
            RAISE USR_EXCEPTION;
          END IF;
        END IF;
		--IF nvl(W_BATCH_NUM, 0) > 0 THEN
		IF (TRIM(W_ERRORMSG) IS NULL) THEN
			DELETE FROM RTMPLNIA R WHERE R.RTMPLNIA_ACNT_NUM = P_INTERNAL_ACNUM AND R.RTMPLNIA_VALUE_DATE <= P_ACCTUAL_PROCESS_DATE;
		END IF;
        --Prasanth NS-12-09-2009-end
      EXCEPTION
        WHEN OTHERS THEN
          IF TRIM(W_ERRORMSG) IS NULL THEN
            W_ERRORMSG := 'ERROR IN SP_LNINTCALL ' || SUBSTR(SQLERRM, 1, 400);
          END IF;
      END STARTPROCESS;
      P_ERRMSG := W_ERRORMSG;
    END SP_CLS_LNINTCALL;
END PKG_CLS_LNINTCALL;

/