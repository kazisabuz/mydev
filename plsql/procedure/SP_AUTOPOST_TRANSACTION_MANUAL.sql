CREATE OR REPLACE PROCEDURE SP_AUTOPOST_TRANSACTION_MANUAL
(
P_TRAN_BRN_CODE NUMBER,
P_DEBIT_GL VARCHAR2,
P_CREDIT_GL VARCHAR2,
P_DEBIT_AMOUNT NUMBER,
P_CREDIT_AMOUNT NUMBER,
P_DEBIT_ACCOUNT NUMBER DEFAULT 0,
P_TRAN_CONTRACT_NUM_DR NUMBER DEFAULT 0,
P_TRAN_CONTRACT_NUM_CR NUMBER DEFAULT 0,
P_CREDIT_ACCOUNT NUMBER DEFAULT 0,
P_TRAN_ADVICE_NUM_DR NUMBER DEFAULT 0,
P_TRAN_ADVICE_DATE_DR DATE DEFAULT NULL,
P_TRAN_ADVICE_NUM_CR NUMBER DEFAULT 0,
P_TRAN_ADVICE_DATE_CR DATE DEFAULT NULL,
P_TRAN_CURRENCY VARCHAR2 DEFAULT  'BDT',
P_TERMINAL_ID VARCHAR2 DEFAULT  SYS_CONTEXT('USERENV', 'IP_ADDRESS'),
P_TRAN_USER VARCHAR2 DEFAULT  'INTELECT',
P_TRAN_NARATION VARCHAR2 DEFAULT 'Migration Correction',
P_DEPT_CODE  VARCHAR2 DEFAULT null,
P_BATCH_NUMBER OUT NUMBER
)
IS 
W_CURRENT_DATE DATE;
W_ERROR     VARCHAR2(1000);
W_BATCH_NUM NUMBER(5);
W_ERR_CODE  VARCHAR2(6);
BEGIN 
 
   IF P_DEBIT_AMOUNT<>P_CREDIT_AMOUNT THEN 
            RAISE_APPLICATION_ERROR(-20100,'Debit and Credit amount must be same');
   END IF;
   
   IF P_TRAN_ADVICE_NUM_DR>0 AND  P_TRAN_ADVICE_DATE_DR IS NULL THEN 
             RAISE_APPLICATION_ERROR(-20101,'Debit Transaction Advice Number Can Not Be Null.');
   END IF;
   
   IF P_TRAN_ADVICE_NUM_CR>0 AND  P_TRAN_ADVICE_DATE_CR IS NULL THEN 
             RAISE_APPLICATION_ERROR(-20101,'Credit Transaction Advice Number Can Not Be Null.');
   END IF;
   
  SELECT M.MN_CURR_BUSINESS_DATE INTO W_CURRENT_DATE FROM MAINCONT M;
  
  PKG_AUTOPOST.pv_userid                       := P_TRAN_USER;
  PKG_AUTOPOST.PV_BOPAUTHQ_REQ                 := false;
  PKG_AUTOPOST.PV_AUTH_DTLS_UPDATE_REQ         := false;
  PKG_AUTOPOST.PV_CALLED_BY_EOD_SOD            := 0;
  PKG_AUTOPOST.PV_EXCEP_CHECK_NOT_REQD         := false;
  PKG_AUTOPOST.PV_OVERDRAFT_CHK_REQD           := false;
  PKG_AUTOPOST.PV_ALLOW_ZERO_TRANAMT           := false;
  PKG_PROCESS_BOPAUTHQ.V_BOPAUTHQ_UPD          := false;
  PKG_AUTOPOST.pv_cancel_flag                  := false;
  PKG_AUTOPOST.pv_post_as_unauth_mod           := false;
  PKG_AUTOPOST.pv_clg_batch_closure            := false;
  PKG_AUTOPOST.pv_authorized_record_cancel     := false;
  PKG_AUTOPOST.PV_BACKDATED_TRAN_REQUIRED      := 0;
  PKG_AUTOPOST.PV_CLG_REGN_POSTING             := false;
  PKG_AUTOPOST.pv_fresh_batch_sl               := false;
  PKG_AUTOPOST.pv_tran_key.Tran_Brn_Code       := P_TRAN_BRN_CODE ;
  PKG_AUTOPOST.pv_tran_key.Tran_Date_Of_Tran   := W_CURRENT_DATE;
  PKG_AUTOPOST.pv_tran_key.Tran_Batch_Number   := 0;
  PKG_AUTOPOST.pv_tran_key.Tran_Batch_Sl_Num   := 0;
  PKG_AUTOPOST.PV_AUTO_AUTHORISE               := true;
  PKG_PB_GLOBAL.G_TERMINAL_ID                  := NVL(P_TERMINAL_ID, '10.10.7.149');
  PKG_POST_INTERFACE.G_BATCH_NUMBER_UPDATE_REQ := false;
  PKG_POST_INTERFACE.G_SRC_TABLE_AUTH_REJ_REQ  := false;
  PKG_AUTOPOST.PV_TRAN_ONLY_UNDO               := false;
  PKG_AUTOPOST.PV_OCLG_POSTING_FLG             := false;
  PKG_POST_INTERFACE.G_IBR_REQUIRED            := 0;
  -- PKG_PB_test.G_FORM_NAME                             := 'ETRAN';
  PKG_POST_INTERFACE.G_PGM_NAME := 'ETRAN';
  PKG_AUTOPOST.PV_USER_ROLE_CODE := '';
  PKG_AUTOPOST.PV_SUPP_TRAN_POST := FALSE;
  PKG_AUTOPOST.PV_FUTURE_TRANSACTION_ALLOWED := FALSE;
  PKG_AUTOPOST.pv_tranbat. TRANBAT_BRN_CODE := P_TRAN_BRN_CODE;
  PKG_AUTOPOST.pv_tranbat. TRANBAT_DATE_OF_TRAN := W_CURRENT_DATE;
  PKG_AUTOPOST.pv_tranbat. TRANBAT_BATCH_NUMBER := 0;
  PKG_AUTOPOST.pv_tranbat. TRANBAT_ENTRY_BRN_CODE := P_TRAN_BRN_CODE;
  PKG_AUTOPOST.pv_tranbat. TRANBAT_WITHDRAW_SLIP := '';
  PKG_AUTOPOST.pv_tranbat. TRANBAT_TOKEN_ISSUED := 0;
  PKG_AUTOPOST.pv_tranbat. TRANBAT_BACKOFF_SYS_CODE := '';
  PKG_AUTOPOST.pv_tranbat. TRANBAT_DEVICE_CODE := '';
  PKG_AUTOPOST.pv_tranbat. TRANBAT_DEVICE_UNIT_NUM := '';
  PKG_AUTOPOST.pv_tranbat. TRANBAT_CHANNEL_DT_TIME := NULL;
  PKG_AUTOPOST.pv_tranbat. TRANBAT_CHANNEL_UNIQ_NUM := '';
  PKG_AUTOPOST.pv_tranbat. TRANBAT_COST_CNTR_CODE := '';
  PKG_AUTOPOST.pv_tranbat. TRANBAT_SUB_COST_CNTR := '';
  PKG_AUTOPOST.pv_tranbat. TRANBAT_PROFIT_CNTR_CODE := '';
  PKG_AUTOPOST.pv_tranbat. TRANBAT_SUB_PROFIT_CNTR := '';
  PKG_AUTOPOST.pv_tranbat. TRANBAT_NUM_TRANS := 2;
  PKG_AUTOPOST.pv_tranbat. TRANBAT_BASE_CURR_TOT_CR := 0.0;
  PKG_AUTOPOST.pv_tranbat. TRANBAT_BASE_CURR_TOT_DB := 0.0;
  PKG_AUTOPOST.pv_tranbat. TRANBAT_CANCEL_BY := '';
  PKG_AUTOPOST.pv_tranbat. TRANBAT_CANCEL_ON := NULL;
  PKG_AUTOPOST.pv_tranbat. TRANBAT_CANCEL_REM1 := '';
  PKG_AUTOPOST.pv_tranbat. TRANBAT_CANCEL_REM2 := '';
  PKG_AUTOPOST.pv_tranbat. TRANBAT_CANCEL_REM3 := '';
  PKG_AUTOPOST.pv_tranbat. TRANBAT_SOURCE_TABLE := 'TRAN';
  PKG_AUTOPOST.pv_tranbat. TRANBAT_SOURCE_KEY := P_TRAN_BRN_CODE||W_CURRENT_DATE||'|0';
  PKG_AUTOPOST.pv_tranbat. TRANBAT_NARR_DTL1 :=SUBSTR(P_TRAN_NARATION,1,35);
  PKG_AUTOPOST.pv_tranbat. TRANBAT_NARR_DTL2 :=SUBSTR(P_TRAN_NARATION,36,35);
  PKG_AUTOPOST.pv_tranbat. TRANBAT_NARR_DTL3 :=SUBSTR(P_TRAN_NARATION,71,35);
  PKG_AUTOPOST.pv_tranbat. TRANBAT_AUTH_BY :=P_TRAN_USER;
  PKG_AUTOPOST.pv_tranbat. TRANBAT_AUTH_ON := NULL;
  PKG_AUTOPOST.pv_tranbat. TRANBAT_SHIFT_TO_TRAN_DATE := NULL;
  PKG_AUTOPOST.pv_tranbat. TRANBAT_SHIFT_TO_BAT_NUM := 0;
  PKG_AUTOPOST.pv_tranbat. TRANBAT_SHIFT_FROM_TRAN_DATE := NULL;
  PKG_AUTOPOST.pv_tranbat. TRANBAT_SHIFT_FROM_BAT_NUM := 0;
  PKG_AUTOPOST.pv_tranbat. TRANBAT_REV_TO_TRAN_DATE := NULL;
  PKG_AUTOPOST.pv_tranbat. TRANBAT_REV_TO_BAT_NUM := 0;
  PKG_AUTOPOST.PV_TRANBAT. TRANBAT_REV_FROM_TRAN_DATE := NULL;
  PKG_AUTOPOST.PV_TRANBAT. TRANBAT_REV_FROM_BAT_NUM := 0;

  PKG_AUTOPOST.PV_TRAN_REC(1).TRAN_BRN_CODE := P_TRAN_BRN_CODE;
  PKG_AUTOPOST.PV_TRAN_REC(1).TRAN_DEPT_CODE := P_DEPT_CODE; 
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_DATE_OF_TRAN := W_CURRENT_DATE;
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_BATCH_NUMBER := 0;
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_BATCH_SL_NUM := 0;
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_PROD_CODE := 0;
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_CODE := '';
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_VALUE_DATE := W_CURRENT_DATE;
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_ACING_BRN_CODE := P_TRAN_BRN_CODE;
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_INTERNAL_ACNUM := P_DEBIT_ACCOUNT;
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_CONTRACT_NUM := P_TRAN_CONTRACT_NUM_DR;
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_GLACC_CODE := P_DEBIT_GL;
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_DB_CR_FLG := 'D';
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_TYPE_OF_TRAN := '1';
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_CURR_CODE := P_TRAN_CURRENCY;
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_AMOUNT := P_DEBIT_AMOUNT;
 /* PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_BASE_CURR_CODE := 'GBP';
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_BASE_CURR_CONV_RATE := 1.78;
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_BASE_CURR_EQ_AMT := 168;  */
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_AMT_BRKUP := '0';
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_SERVICE_CODE := '';
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_CHARGE_CODE := '';
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_DELIVERY_CHANNEL_CODE := '';
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_DEVICE_CODE := '';
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_DEVICE_UNIT_NUMBER := '';
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_TRN_EXT_REF_NUMBER := '';
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_INSTR_CHQ_PFX := '';
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_INSTR_CHQ_NUMBER := 0;
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_INSTR_DATE := NULL;
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_PROFIT_CUST_CODE := 0;
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_REMITTANCE_CODE := '';
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_SIGN_COMB_SL := 0;
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_SIGN_VERIFIED_FLG := '';
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_LIMIT_CURR := '';
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_CRATE_TO_LIMIT_CURR := 0.0;
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_LIMIT_CURR_EQUIVALENT := 0.0;
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_ENTD_BY := P_TRAN_USER;
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_ENTD_ON := NULL;
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_LAST_MOD_BY := '';
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_LAST_MOD_ON := NULL;
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_FIRST_AUTH_BY := '';
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_FIRST_AUTH_ON := NULL;
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_AUTH_BY :=P_TRAN_USER;
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_AUTH_ON := NULL;
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_RISK_AUTH_BY := '';
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_RISK_AUTH_ON := NULL;
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_SYSTEM_POSTED_TRAN := '1';
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_CASHIER_ID := '';
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_CASH_TRAN_DATE := NULL;
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_CASH_TRAN_DAY_SL := 0;
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_AC_CANCEL_AMT := 0.0;
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_BC_CANCEL_AMT := 0.0;
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_INTERMED_VCR_FLG := '';
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_BACKOFF_SYS_CODE := '';
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_CHANNEL_DT_TIME := NULL;
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_CHANNEL_UNIQ_NUM := '';
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_COST_CNTR_CODE := '';
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_SUB_COST_CNTR := '';
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_PROFIT_CNTR_CODE := '';
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_SUB_PROFIT_CNTR := '';
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_NOM_AC_ENT_TYPE := '';
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_NOM_AC_PRE_ENT_YR := 0;
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_NOM_AC_REF_NUM := 0;
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_HOLD_REFNUM := 0;
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_ACNT_INVALID := '';
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_AVAILABLE_AC_BAL := 0.0;
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_AGENCY_BANK_CODE := '';
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_IBR_BRN_CODE := 0;
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_IBR_CODE := '';
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_ORIG_RESP := '';
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_IBR_YEAR := 0;
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_IBR_NUM := 0;
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_ADVICE_NUM :=NVL(P_TRAN_ADVICE_NUM_DR,0);
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_ADVICE_DATE := P_TRAN_ADVICE_DATE_DR;
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_TERMINAL_ID := '';
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_NARR_DTL1 :=SUBSTR(P_TRAN_NARATION,1,35);
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_NARR_DTL2 := SUBSTR(P_TRAN_NARATION,36,35);
  PKG_AUTOPOST.PV_TRAN_REC(1) . TRAN_NARR_DTL3 := SUBSTR(P_TRAN_NARATION,71,35);
  PKG_AUTOPOST.PV_TRANCMN_REC(1).TRANCMN_BATCH_SL_NUM := 1;
  PKG_AUTOPOST.PV_TRANCMN_REC(1).TRANCMN_DTL1 := '';
  PKG_AUTOPOST.PV_TRANCMN_REC(1).TRANCMN_DTL2 := '';
  PKG_AUTOPOST.PV_TRANCMN_REC(1).TRANCMN_DTL3 := '';
  PKG_AUTOPOST.PV_TRANCMN_REC(1).TRANCMN_DTL4 := '';
  PKG_AUTOPOST.PV_TRANCMN_REC(1).TRANCMN_DTL5 := '';  


  PKG_AUTOPOST.PV_TRAN_REC(2).TRAN_BRN_CODE := P_TRAN_BRN_CODE;
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_DATE_OF_TRAN := W_CURRENT_DATE;
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_BATCH_NUMBER := 0;
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_BATCH_SL_NUM := 0;
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_PROD_CODE := 0;
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_CODE := '';
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_VALUE_DATE := W_CURRENT_DATE;
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_ACING_BRN_CODE := P_TRAN_BRN_CODE;
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_INTERNAL_ACNUM := P_CREDIT_ACCOUNT;
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_CONTRACT_NUM := P_TRAN_CONTRACT_NUM_CR;
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_GLACC_CODE := P_CREDIT_GL;
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_DB_CR_FLG := 'C';
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_TYPE_OF_TRAN := '1';
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_CURR_CODE :=P_TRAN_CURRENCY;
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_AMOUNT := P_CREDIT_AMOUNT;
 /* PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_BASE_CURR_CODE := 'GBP';
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_BASE_CURR_CONV_RATE := 1;
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_BASE_CURR_EQ_AMT := '3778'; */
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_AMT_BRKUP := '0';
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_SERVICE_CODE := '';
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_CHARGE_CODE := '';
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_DELIVERY_CHANNEL_CODE := '';
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_DEVICE_CODE := '';
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_DEVICE_UNIT_NUMBER := '';
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_TRN_EXT_REF_NUMBER := '';
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_INSTR_CHQ_PFX := '';
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_INSTR_CHQ_NUMBER := 0;
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_INSTR_DATE := NULL;
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_PROFIT_CUST_CODE := 0;
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_REMITTANCE_CODE := '';
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_SIGN_COMB_SL := 0;
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_SIGN_VERIFIED_FLG := '';
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_LIMIT_CURR := '';
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_CRATE_TO_LIMIT_CURR := 0.0;
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_LIMIT_CURR_EQUIVALENT := 0.0;
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_ENTD_BY := P_TRAN_USER;
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_ENTD_ON := NULL;
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_LAST_MOD_BY := '';
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_LAST_MOD_ON := NULL;
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_FIRST_AUTH_BY := '';
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_FIRST_AUTH_ON := NULL;
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_AUTH_BY :=P_TRAN_USER;
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_AUTH_ON := NULL;
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_RISK_AUTH_BY := '';
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_RISK_AUTH_ON := NULL;
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_SYSTEM_POSTED_TRAN := '1';
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_CASHIER_ID := '';
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_CASH_TRAN_DATE := NULL;
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_CASH_TRAN_DAY_SL := 0;
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_AC_CANCEL_AMT := 0.0;
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_BC_CANCEL_AMT := 0.0;
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_INTERMED_VCR_FLG := '';
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_BACKOFF_SYS_CODE := '';
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_CHANNEL_DT_TIME := NULL;
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_CHANNEL_UNIQ_NUM := '';
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_COST_CNTR_CODE := '';
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_SUB_COST_CNTR := '';
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_PROFIT_CNTR_CODE := '';
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_SUB_PROFIT_CNTR := '';
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_NOM_AC_ENT_TYPE := '';
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_NOM_AC_PRE_ENT_YR := 0;
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_NOM_AC_REF_NUM := 0;
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_HOLD_REFNUM := 0;
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_ACNT_INVALID := '';
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_AVAILABLE_AC_BAL := 0.0;
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_AGENCY_BANK_CODE := '';
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_IBR_BRN_CODE := 0;
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_IBR_CODE := '';
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_ORIG_RESP := '';
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_IBR_YEAR := 0;
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_IBR_NUM := 0;
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_ADVICE_NUM := NVL(P_TRAN_ADVICE_NUM_CR,0);
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_ADVICE_DATE := P_TRAN_ADVICE_DATE_CR;
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_TERMINAL_ID := '';
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_NARR_DTL1 :=SUBSTR(P_TRAN_NARATION,1,35);
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_NARR_DTL2 := SUBSTR(P_TRAN_NARATION,36,35);
  PKG_AUTOPOST.PV_TRAN_REC(2) . TRAN_NARR_DTL3 := SUBSTR(P_TRAN_NARATION,71,35);
  PKG_AUTOPOST.PV_TRANCMN_REC(2).TRANCMN_BATCH_SL_NUM := 2;
  PKG_AUTOPOST.PV_TRANCMN_REC(2).TRANCMN_DTL1 := '';
  PKG_AUTOPOST.PV_TRANCMN_REC(2).TRANCMN_DTL2 := '';
  PKG_AUTOPOST.PV_TRANCMN_REC(2).TRANCMN_DTL3 := '';
  PKG_AUTOPOST.PV_TRANCMN_REC(2).TRANCMN_DTL4 := '';
  PKG_AUTOPOST.PV_TRANCMN_REC(2).TRANCMN_DTL5 := '';

  --PKG_PB_AUTOPOST.G_FORM_NAME := 'AUTORENEWAL';
  PKG_PB_AUTOPOST.G_FORM_NAME := 'ETRAN';

-- Calling AUTOPOST --
  PKG_POST_INTERFACE.SP_AUTOPOSTTRAN('1', --Entity Number
                                     'A', --User Mode
                                     2,   --No of transactions
                                     0,
                                     0,
                                     0,
                                     0,
                                     'N',
                                     W_ERR_CODE,
                                     W_ERROR,
                                     W_BATCH_NUM);
  --DBMS_OUTPUT.PUT_LINE('BATCH POSTED NUM');
  DBMS_OUTPUT.PUT_LINE( 'Batch no = ' || W_BATCH_NUM);
P_BATCH_NUMBER:=W_BATCH_NUM;
  DBMS_OUTPUT.PUT_LINE(W_ERR_CODE||W_ERROR||'Test aupost');

PKG_AUTOPOST.PV_TRAN_REC.DELETE;

/* RUNING BLOCK **********************

DECLARE
V_BATCH_NUMBER NUMBER;
BEGIN
   FOR IND IN (SELECT I.IACLINK_INTERNAL_ACNUM,AC_NUMBER,
                    I.IACLINK_BRN_CODE,
                    TO_BE_REVER1,
                    TO_BE_REVER2
               FROM IACLINK I, MANUAL_TRAN M
              WHERE I.IACLINK_ACTUAL_ACNUM = M.AC_NUMBER
              ORDER BY AC_NUMBER)
   LOOP
        SP_AUTOPOST_TRANSACTION_MANUAL(
                            IND.IACLINK_BRN_CODE, -- branch code
                            NULL, -- debit gl
                            '400101146', -- credit gl 
                            IND.TO_BE_REVER1, -- debit amount
                            IND.TO_BE_REVER1, -- credit amount 
                            IND.IACLINK_INTERNAL_ACNUM, -- debit account 
                            1, -- DR contract number
                            0, -- CR contract number
                            0, -- credit account
                            0, -- advice num debit
                            NULL,-- advice date debit 
                            0, -- advice num credit
                            NULL, -- advice date credit
                            'BDT', -- currency
                            '127.0.0.1', -- terminal id 
                            'INTELECT', -- user
                            'Interest Reversal', -- narration
                            V_BATCH_NUMBER -- BATCH NUMBER
                            );
                            
              UPDATE MANUAL_TRAN
        SET TO_BE_REVER1_BATCH=V_BATCH_NUMBER
        WHERE AC_NUMBER=IND.AC_NUMBER;
        
   END LOOP;
END;
*/

END;

/