CREATE OR REPLACE PACKAGE PKG_ATM_TRNPOST_SHDW is
  PROCEDURE PROC_TRNPOST(P_ENTITY_NUM IN NUMBER, P_RET OUT NUMBER);
end PKG_ATM_TRNPOST_SHDW;

/

CREATE OR REPLACE PACKAGE BODY PKG_ATM_TRNPOST_SHDW is

  PROCEDURE PROC_TRNPOST(P_ENTITY_NUM IN NUMBER, P_RET OUT NUMBER) IS
    E_USEREXCEP EXCEPTION;
    W_ERROR       VARCHAR2(1000);
    W_CBD         DATE;
    W_VOUCHER_NO  NUMBER(7);
    W_INT_ACC     NUMBER(15);
    W_AMOUNT      NUMBER(15, 3);
    W_ACC_NUM     VARCHAR(20);
    W_CURR        VARCHAR2(3);
    W_ADVICE_NO   NUMBER(7);
    W_ADVICE_DATE DATE;
    W_RET         NUMBER(15);
	W_DR_CR       CHAR(1);
    FUNCTION FN_GET_SHDW_BAL(VAR_INT_ACCTNO IN NUMBER,
                             VAR_ACCT_CCY   IN VARCHAR2) RETURN NUMBER IS

      VAR_SHBAL_ACCT NUMBER(20) := 1;
    BEGIN
      SELECT SHBAL_INTERNAL_ACNUM
        INTO VAR_SHBAL_ACCT
        FROM SHBAL
       WHERE SHBAL_ENTITY_NUM = 1
         AND SHBAL_INTERNAL_ACNUM = VAR_INT_ACCTNO
         AND SHBAL_ACCT_CCY = VAR_ACCT_CCY;
      RETURN VAR_SHBAL_ACCT;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN 1;
    END FN_GET_SHDW_BAL;

    FUNCTION FN_UPDT_SHBAL_DB(VAR_FN_INTACNO IN NUMBER,
                              W_FAC_CCY      VARCHAR2,
                              W_TRN_AMT_ACY  IN NUMBER) RETURN NUMBER IS
      VAR_FN_SHDWACCT NUMBER(14);
    BEGIN
      VAR_FN_SHDWACCT := FN_GET_SHDW_BAL(VAR_FN_INTACNO, W_FAC_CCY);
      IF VAR_FN_SHDWACCT <> 1 THEN
        UPDATE SHBAL
           SET SHBAL_BAL    = SHBAL_BAL - W_TRN_AMT_ACY,
               SHBAL_TOT_DB = SHBAL_TOT_DB + W_TRN_AMT_ACY
         WHERE SHBAL_ENTITY_NUM = 1
           AND SHBAL_INTERNAL_ACNUM = VAR_FN_INTACNO
           AND SHBAL_ACCT_CCY = W_FAC_CCY;
        RETURN 0;
      ELSE
        RETURN 1;
      END IF;
    END FN_UPDT_SHBAL_DB;

    FUNCTION FN_UPDT_SHBAL_CR(VAR_FN_INTACNO IN NUMBER,
                              W_FAC_CCY      VARCHAR2,
                              W_TRN_AMT_ACY  IN NUMBER) RETURN NUMBER IS

      VAR_FN_SHDWACCT NUMBER(14);
    BEGIN
      VAR_FN_SHDWACCT := FN_GET_SHDW_BAL(VAR_FN_INTACNO, W_FAC_CCY);
      IF VAR_FN_SHDWACCT <> 1 THEN
        UPDATE SHBAL
           SET SHBAL_BAL    = SHBAL_BAL + W_TRN_AMT_ACY,
               SHBAL_TOT_CR = SHBAL_TOT_CR + W_TRN_AMT_ACY
         WHERE SHBAL_ENTITY_NUM = 1
           AND SHBAL_INTERNAL_ACNUM = VAR_FN_INTACNO
           AND SHBAL_ACCT_CCY = W_FAC_CCY;
        RETURN 0;
      ELSE
        RETURN 1;
      END IF;

    END FN_UPDT_SHBAL_CR;

    PROCEDURE SYNC_WITH_PRD_SCHEMA IS
      P_ERROR_MESSAGE VARCHAR2(1000);
    BEGIN

      FOR IDX IN (SELECT M.SYSTEM_TRACE_AUDIT_NUMBER,
                         M.RETRIEVAL_REFERENCE_NUMBER,
                         M.ATM_REQUEST_ID,
                         M.SHADOW_TRAN_REF,
                         M.REVERSAL
                    FROM ATM_TRANSACTION_SHADOW_ARCHIVE M
                   WHERE M.PROCESSED = '0') LOOP

        P_ERROR_MESSAGE := NULL;
        W_VOUCHER_NO    := 0;
        W_INT_ACC       := 0;
        W_CURR          := 'BDT';
        W_ACC_NUM       := NULL;
        W_RET           := 0;

        BEGIN
          SELECT M.ACCOUNT_NUMBER, M.CURRENCY, M.AMOUNT
            INTO W_ACC_NUM, W_CURR, W_AMOUNT
            FROM ATM_TRANSACTION M
           WHERE M.ATM_REQUEST_ID = IDX.ATM_REQUEST_ID
           AND ( M.BATCH_NUMBER IS NULL OR M.BATCH_NUMBER =0) ;
          IF W_ACC_NUM IS NOT NULL THEN
            SELECT M.IACLINK_INTERNAL_ACNUM
              INTO W_INT_ACC
              FROM IACLINK M
             WHERE M.IACLINK_ACTUAL_ACNUM = W_ACC_NUM;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            CONTINUE;
            
        END;
        
        
        <<UPDATE_API_TRANSACTION_DATE>>
         BEGIN 
          UPDATE API_TRANSACTION T
             SET T.TRAN_DATE = W_CBD
           WHERE T.BATCH_SL = IDX.SHADOW_TRAN_REF;
          
          IF W_INT_ACC > 0 THEN
			
			SELECT SUM(T.AC_AMOUNT), MAX(DR_CR) KEEP (DENSE_RANK FIRST ORDER BY T.INT_AC_NO) INTO  
			W_AMOUNT, W_DR_CR  FROM API_TRANSACTION T
			WHERE T.BATCH_SL = IDX.SHADOW_TRAN_REF
			AND  T.INT_AC_NO = W_INT_ACC;
		  
            IF IDX.REVERSAL = '1' OR W_DR_CR = 'C' THEN
              W_RET := FN_UPDT_SHBAL_DB(W_INT_ACC, W_CURR, W_AMOUNT);
            ELSE
              W_RET := FN_UPDT_SHBAL_CR(W_INT_ACC, W_CURR, W_AMOUNT);
            END IF;
           END IF; 
           
          COMMIT;
           
           EXCEPTION
          WHEN OTHERS THEN
            NULL;
         END UPDATE_API_TRANSACTION_DATE;
        

        SP_API_TRAN_POST(P_ENTITY_NUM,
                         IDX.SHADOW_TRAN_REF,
                         W_VOUCHER_NO,
                         W_ADVICE_NO,
                         W_ADVICE_DATE,
                         P_ERROR_MESSAGE);                                    
        IF (P_ERROR_MESSAGE IS NULL AND W_VOUCHER_NO > 0) THEN
          UPDATE ATM_TRANSACTION M
             SET M.BATCH_NUMBER      = W_VOUCHER_NO,
                 M.TRANSACTION_DATE  = W_CBD,
                 M.SHADOW_SETTLEMENT = 1
           WHERE M.ATM_REQUEST_ID = IDX.ATM_REQUEST_ID;
          UPDATE ATM_TRANSACTION_SHADOW_ARCHIVE M
             SET M.PROCESSED = 1
           WHERE M.ATM_REQUEST_ID = IDX.ATM_REQUEST_ID;       
        
          /*IF W_INT_ACC > 0 THEN
            IF IDX.REVERSAL = '1' THEN
              W_RET := FN_UPDT_SHBAL_CR(W_INT_ACC, W_CURR, W_AMOUNT);
            ELSE
              W_RET := FN_UPDT_SHBAL_DB(W_INT_ACC, W_CURR, W_AMOUNT);
            END IF;
            IF W_RET = 1 THEN
              INSERT INTO ATM_ERROR_ARCHIVE
                (RETRIEVAL_REFERENCE_NUMBER,
                 SYSTEM_TRACE_AUDIT_NUMBER,
                 TRANSACTION_DATE,
                 ATM_REQUEST_ID,
                 ERROR_MESSAGE)
              VALUES
                (IDX.RETRIEVAL_REFERENCE_NUMBER,
                 IDX.SYSTEM_TRACE_AUDIT_NUMBER,
                 W_CBD,
                 IDX.ATM_REQUEST_ID,
                 'NOT FOUND SHADOW BAL RECORD');
            END IF;
          END IF;*/
          COMMIT;
        ELSE
          <<REVERSE_SHBAL_TABLE_BALANCE>>
          BEGIN
             IF W_INT_ACC > 0 THEN
                IF IDX.REVERSAL = '1' THEN
                  UPDATE SHBAL
                    SET SHBAL_BAL    = SHBAL_BAL + W_AMOUNT,
                        SHBAL_TOT_DB = SHBAL_TOT_DB - W_AMOUNT
                  WHERE SHBAL_ENTITY_NUM = 1
                    AND SHBAL_INTERNAL_ACNUM = W_INT_ACC
                    AND SHBAL_ACCT_CCY = W_CURR;
                ELSE
                    UPDATE SHBAL
                    SET SHBAL_BAL    = SHBAL_BAL - W_AMOUNT,
                        SHBAL_TOT_CR = SHBAL_TOT_CR - W_AMOUNT
                  WHERE SHBAL_ENTITY_NUM = 1
                    AND SHBAL_INTERNAL_ACNUM = W_INT_ACC
                    AND SHBAL_ACCT_CCY = W_CURR;
                END IF;     
             END IF;   
          END REVERSE_SHBAL_TABLE_BALANCE;
 
          INSERT INTO ATM_ERROR_ARCHIVE
            (RETRIEVAL_REFERENCE_NUMBER,
             SYSTEM_TRACE_AUDIT_NUMBER,
             TRANSACTION_DATE,
             ATM_REQUEST_ID,
             ERROR_CODE,
             ERROR_MESSAGE)
          VALUES
            (IDX.RETRIEVAL_REFERENCE_NUMBER,
             IDX.SYSTEM_TRACE_AUDIT_NUMBER,
             W_CBD,
             IDX.ATM_REQUEST_ID,
             '002',
             P_ERROR_MESSAGE);
           COMMIT;
        END IF;
      END LOOP;

    EXCEPTION
      WHEN OTHERS THEN
        W_ERROR := 'SHADOW SYNC FAILED : ' || SQLERRM;
        RAISE E_USEREXCEP;
    END SYNC_WITH_PRD_SCHEMA;

  BEGIN
    <<POSTING>>
    BEGIN
      PKG_ENTITY.SP_SET_ENTITY_CODE(P_ENTITY_NUM);
      W_CBD := PKG_PB_GLOBAL.FN_GET_CURR_BUS_DATE(PKG_ENTITY.FN_GET_ENTITY_CODE);
       SYNC_WITH_PRD_SCHEMA;
       P_RET := 0;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        W_ERROR := W_ERROR || SQLERRM;
        BEGIN
          INSERT INTO ATM_ERROR_ARCHIVE
            (ERROR_CODE, ERROR_MESSAGE)
          VALUES
            ('001', W_ERROR);
          P_RET := 1;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
    END POSTING;
  END PROC_TRNPOST;
END PKG_ATM_TRNPOST_SHDW;

/
