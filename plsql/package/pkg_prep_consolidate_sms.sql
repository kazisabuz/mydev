/*<TOAD_FILE_CHUNK>*/
CREATE OR REPLACE PACKAGE PKG_PREP_CONSOLIDATE_SMS IS
  PROCEDURE SP_CONSOLIDATED_SMS(V_ENTITY_NUM IN NUMBER,
                                P_BRN_CODE   IN NUMBER DEFAULT 0);

  PROCEDURE START_BRNWISE(V_ENTITY_NUM IN NUMBER,
                          P_BRN_CODE   IN NUMBER DEFAULT 0);
END PKG_PREP_CONSOLIDATE_SMS;
/

/*<TOAD_FILE_CHUNK>*/
CREATE OR REPLACE PACKAGE BODY PKG_PREP_CONSOLIDATE_SMS IS
  W_PREV_DATE   DATE;
  BANK_CODE     NUMBER(3);
  W_BANK_NAME   VARCHAR2(50);
  W_ERR_MSG     VARCHAR2(200);
  W_SQL         VARCHAR2(4000);
  W_ENTITY_CODE NUMBER;
  W_USER_ID     VARCHAR2(8);
  W_CBD         DATE;
  L_BRN_CODE    NUMBER(6);

  V_CONCATE_SMS                 VARCHAR2(1000);
  V_MOBSMSCNSL_DEPINT_AMT        NUMBER (18, 2);
  v_SMSMAST_CD                   VARCHAR2(15);
  V_MOBSMSCNSL_SRCTAX_AMT       NUMBER (18, 2);
  V_MOBSMSCNSL_MNTCHG_AMT        NUMBER (18, 2);
  V_MOBSMSCNSL_EXCISDT_AMT       NUMBER (18, 2);
  V_MOBSMSCNSL_SMSCHG_AMT       NUMBER (18, 2);
  V_MOBSMSCNSL_VAT_MNTCHG_AMT NUMBER (18, 2);
  V_MOBSMSCNSL_SMS_VAT_AMT          NUMBER (18, 2);
  V_ATMCHG_AMT                     NUMBER (18, 2);
  V_ATM_VAT_AMT                     NUMBER (18, 2);
  V_CALL_CODE                   VARCHAR2(6);
  V_MOBILE_NUMBER               VARCHAR2(15);
  V_MOBILE_WITH_CODE            VARCHAR2(30);
  V_TRAN_BRN_CODE               NUMBER(8);
  V_ACC_NO_TXT                  VARCHAR2(50);
  V_ACNT_NUM                    NUMBER(14);
  V_ACNT_BAL                    NUMBER(18, 3);
  W_DUMMY_V                 VARCHAR2 (10);
    W_DUMMY_N                 NUMBER;
    W_DUMMY_D                 DATE;
    W_REC_AC_AUTH_BAL         NUMBER (18, 2);
    W_REC_AC_AVL_BAL          NUMBER (18, 2);
    V_AVL_BALANCE     NUMBER (18, 2);
    V_ERROR   VARCHAR2 (400);


      TYPE TY_LNP_REC IS RECORD
   (
     MOBSMSCNSL_BRN_CODE MOBSMSCONSOLQ.MOBSMSCNSL_BRN_CODE%TYPE , 
      MOBSMSCNSL_DATE     MOBSMSCONSOLQ.MOBSMSCNSL_DATE%TYPE ,
      SMSMAST_CD          VARCHAR2(20),
      MOBSMSCNSL_ACC_NUM MOBSMSCONSOLQ.MOBSMSCNSL_ACC_NUM%TYPE , 
      MOBSMSCNSL_MOB_NUM MOBSMSCONSOLQ.MOBSMSCNSL_MOB_NUM%TYPE ,                        
      MOBSMSCNSL_DEPINT_AMT MOBSMSCONSOLQ.MOBSMSCNSL_DEPINT_AMT%TYPE , 
      MOBSMSCNSL_SRCTAX_AMT MOBSMSCONSOLQ.MOBSMSCNSL_SRCTAX_AMT%TYPE , 
      MOBSMSCNSL_MNTCHG_AMT MOBSMSCONSOLQ.MOBSMSCNSL_MNTCHG_AMT%TYPE , 
      MOBSMSCNSL_EXCISDT_AMT MOBSMSCONSOLQ.MOBSMSCNSL_EXCISDT_AMT%TYPE ,
      MOBSMSCNSL_SMSCHG_AMT MOBSMSCONSOLQ.MOBSMSCNSL_SMSCHG_AMT%TYPE , 
      MOBSMSCNSL_DRCRD_MNTCHG_AMT MOBSMSCONSOLQ.MOBSMSCNSL_DRCRD_MNTCHG_AMT%TYPE , 
      MOBSMSCNSL_VAT_AMT MOBSMSCONSOLQ.MOBSMSCNSL_VAT_AMT%TYPE , 
      MOBSMSCNSL_ATMCHG_AMT    MOBSMSCONSOLQ.MOBSMSCNSL_ATMCHG_AMT%TYPE ,
      MOBSMSCNSL_ATM_VAT_AMT MOBSMSCONSOLQ.MOBSMSCNSL_ATM_VAT_AMT%TYPE
   );

   TYPE TAB_LNP_REC IS TABLE OF TY_LNP_REC
      INDEX BY PLS_INTEGER;

   LNP_REC                          TAB_LNP_REC;

  PROCEDURE INSERT_MOBSMSOUTQ(W_BRN_CODE   IN NUMBER,
                              W_SER_CODE   IN VARCHAR2,
                              W_MOBILE_NUM IN VARCHAR2,
                              W_SMS_TEXT   IN VARCHAR2,
                              W_INTNUM     IN NUMBER) IS
    W_PUSH NUMBER(2) := 1;
  BEGIN
    <<SMSPARAM>>
    BEGIN
      SELECT P.SMSPARAM_PUSH
        INTO W_PUSH
        FROM SMSPARAM P
       WHERE P.SMSPARAM_ENTITY_NUM = 1;
    EXCEPTION
      WHEN OTHERS THEN
        W_PUSH := 1;
    END SMSPARAM;
  
    PKG_INSERT_MOBSMSOUTQ.SP_INSERT_MOBSMSOUTQ(PKG_ENTITY.FN_GET_ENTITY_CODE,
                                               W_BRN_CODE,
                                               W_SER_CODE,
                                               SUBSTR(W_MOBILE_NUM, 1, 15),
                                               W_SMS_TEXT,
                                               0,
                                               SYSDATE,
                                               0,
                                               ' ',
                                               W_PUSH,
                                               W_INTNUM);
  END INSERT_MOBSMSOUTQ;
PROCEDURE CALL_SP_AVLBAL (P_ENTITY_CODE NUMBER, P_ACNT_NUM IN NUMBER)
    IS
    BEGIN
        SP_AVLBAL (P_ENTITY_CODE,
                   P_ACNT_NUM,
                   W_DUMMY_V,
                   W_REC_AC_AUTH_BAL,
                   W_DUMMY_N,
                   W_DUMMY_N,
                   W_DUMMY_N,
                   W_DUMMY_N,
                   W_DUMMY_N,
                   W_DUMMY_N,
                   W_DUMMY_N,
                   W_DUMMY_N,
                   W_REC_AC_AVL_BAL,
                   W_DUMMY_N,
                   W_DUMMY_N,
                   W_DUMMY_N,
                   W_DUMMY_N,
                   W_DUMMY_N,
                   W_DUMMY_N,
                   W_DUMMY_N,
                   W_DUMMY_N,
                   W_DUMMY_N,
                   W_DUMMY_N,
                   W_DUMMY_N,
                   W_DUMMY_D,
                   W_DUMMY_V,
                   W_DUMMY_D,
                   W_DUMMY_V,
                   W_DUMMY_V,
                   W_DUMMY_V,
                   W_DUMMY_V,
                   W_DUMMY_N,
                   W_DUMMY_N,
                   V_ERROR,
                   W_DUMMY_V,
                   W_DUMMY_N,
                   W_DUMMY_N,
                   W_DUMMY_N,
                   W_DUMMY_N,
                   W_DUMMY_N,
                   W_DUMMY_N,
                   W_DUMMY_N,
                   1,
                   1);


        V_AVL_BALANCE :=   W_REC_AC_AVL_BAL;
    END;

  PROCEDURE SP_CONSOLIDATED_SMS(V_ENTITY_NUM IN NUMBER,
                                P_BRN_CODE   IN NUMBER DEFAULT 0) IS
    W_DUMMY_CODE NUMBER(4);
    ERROR_MSG    VARCHAR2(1000);
    W_DEBIT_STR VARCHAR2(20); 
  BEGIN
    W_PREV_DATE := NULL;
      SELECT INS_OUR_BANK_CODE, INS_NAME_OF_BANK
      INTO BANK_CODE, W_BANK_NAME
      FROM INSTALL;
  
  
     W_SQL := 'SELECT MOBSMSCNSL_BRN_CODE,
                       MOBSMSCNSL_DATE,
                       CM.SMSMAST_CD,
                       MOBSMSCNSL_ACC_NUM,
                       MOBILE_NUMBER MOBSMSCNSL_MOB_NUM,
                       MOBSMSCNSL_DEPINT_AMT,
                       MOBSMSCNSL_SRCTAX_AMT,
                       MOBSMSCNSL_MNTCHG_AMT,
                       MOBSMSCNSL_EXCISDT_AMT,
                       MOBSMSCNSL_SMSCHG_AMT,
                       MOBSMSCNSL_DRCRD_MNTCHG_AMT,
                       MOBSMSCNSL_VAT_AMT,
                       MOBSMSCNSL_ATMCHG_AMT,
                       MOBSMSCNSL_ATM_VAT_AMT
                  FROM MOBSMSCONSOLQ, MOBILEREG M, SMSSVCMAST CM
                 WHERE     ENTITY_NUM = 1
                       AND MOBSMSCNSL_ACC_NUM = INT_ACNUM
                       AND M.ENTITY_NUM = CM.SMSMAST_ENTITY_NUM
                       AND M.ACTIVE = 0
                       AND M.MOBILEREG_AUTH_ON IS NOT NULL
                       AND M.SERVICE1 = 1
                       AND BRANCH_CODE = MOBSMSCNSL_BRN_CODE
                       AND M.SERVICE1_DEACTIVATED_ON IS NULL
                       AND M.SERVICE1 = CM.SERVICE_TYPE
                       AND CM.SMSMAST_SVC_CD = ''BULKSMS''
                       AND CM.SERVICE_STATUS = 0 ';

      IF (P_BRN_CODE > 0)
      THEN
        
         W_SQL := W_SQL || ' AND MOBSMSCNSL_BRN_CODE = ' || P_BRN_CODE;
      END IF;

     EXECUTE IMMEDIATE W_SQL
         BULK COLLECT INTO LNP_REC;
  
        
      IF LNP_REC.FIRST IS NOT NULL
      THEN
         FOR J IN LNP_REC.FIRST .. LNP_REC.LAST
         LOOP
      
      <<PROCIND_RECORD>>
      BEGIN
        V_MOBSMSCNSL_DEPINT_AMT       := LNP_REC(J).MOBSMSCNSL_DEPINT_AMT;
        V_MOBSMSCNSL_SRCTAX_AMT       := LNP_REC(J).MOBSMSCNSL_SRCTAX_AMT;
        V_MOBSMSCNSL_MNTCHG_AMT       := LNP_REC(J).MOBSMSCNSL_MNTCHG_AMT;
        V_MOBSMSCNSL_EXCISDT_AMT      := LNP_REC(J).MOBSMSCNSL_EXCISDT_AMT;
        V_MOBSMSCNSL_SMSCHG_AMT       := LNP_REC(J).MOBSMSCNSL_SMSCHG_AMT;
        V_MOBSMSCNSL_VAT_MNTCHG_AMT := LNP_REC(J).MOBSMSCNSL_DRCRD_MNTCHG_AMT;
        V_MOBSMSCNSL_SMS_VAT_AMT          := LNP_REC(J).MOBSMSCNSL_VAT_AMT;
        V_CONCATE_SMS                 := '';
        V_MOBILE_NUMBER               := LNP_REC(J).MOBSMSCNSL_MOB_NUM;
        v_SMSMAST_CD                   :=LNP_REC(J).SMSMAST_CD;
        V_ACNT_NUM                    := LNP_REC(J).MOBSMSCNSL_ACC_NUM;
        V_TRAN_BRN_CODE               := LNP_REC(J).MOBSMSCNSL_BRN_CODE;
        V_ATMCHG_AMT                   := LNP_REC(J).MOBSMSCNSL_ATMCHG_AMT;
        V_ATM_VAT_AMT                  := LNP_REC(J).MOBSMSCNSL_ATM_VAT_AMT;
        --V_ACNT_BAL                    := LNP_REC(J).ACNTBAL_AC_BAL;
        V_ACC_NO_TXT                  := facno(1, V_ACNT_NUM);
        V_ACC_NO_TXT                  := 'Your A/C ' ||
                                         SUBSTR(V_ACC_NO_TXT, 1, 4) ||
                                         '*****' ||
                                         SUBSTR(V_ACC_NO_TXT, 10) ||
                                         ' has been ';
        CALL_SP_AVLBAL(1,V_ACNT_NUM);
        W_DEBIT_STR := 'Debited for';
        
        IF (V_MOBSMSCNSL_DEPINT_AMT IS NOT NULL) AND
           V_MOBSMSCNSL_DEPINT_AMT > 0 THEN
          V_CONCATE_SMS := 'Credited for Interest: BDT ' ||
                           SP_GETFORMAT (V_ENTITY_NUM,
                                             'BDT ',V_MOBSMSCNSL_DEPINT_AMT) || ',';
        END IF;
      
        IF (V_MOBSMSCNSL_SRCTAX_AMT IS NOT NULL) AND
           V_MOBSMSCNSL_SRCTAX_AMT > 0 THEN
          V_CONCATE_SMS := V_CONCATE_SMS || '' || W_DEBIT_STR ||
                           ' TDS on Interest: BDT ' ||
                           SP_GETFORMAT (1,
                                             'BDT ',V_MOBSMSCNSL_SRCTAX_AMT) || ',';
          W_DEBIT_STR := '';                 
        END IF;
      
        IF (V_MOBSMSCNSL_MNTCHG_AMT IS NOT NULL) AND
           V_MOBSMSCNSL_MNTCHG_AMT > 0 THEN
          V_CONCATE_SMS := V_CONCATE_SMS || '' || W_DEBIT_STR ||
                           ' Maintenance Charge: BDT ' ||
                           SP_GETFORMAT (1,
                                             'BDT ',V_MOBSMSCNSL_MNTCHG_AMT) || ',';
         W_DEBIT_STR := '';
        END IF;
      
        IF (V_MOBSMSCNSL_EXCISDT_AMT IS NOT NULL) AND
           V_MOBSMSCNSL_EXCISDT_AMT > 0 THEN
          V_CONCATE_SMS := V_CONCATE_SMS || '' ||  W_DEBIT_STR ||
                           ' Excise Duty: BDT ' ||
                           SP_GETFORMAT (1,
                                             'BDT ',V_MOBSMSCNSL_EXCISDT_AMT) || ',';
         W_DEBIT_STR := '';
        END IF;
      
        IF (V_MOBSMSCNSL_SMSCHG_AMT IS NOT NULL) AND
           V_MOBSMSCNSL_SMSCHG_AMT > 0 THEN
          V_CONCATE_SMS := V_CONCATE_SMS || '' ||  W_DEBIT_STR ||
                          ' SMS Charge: BDT ' ||
                           SP_GETFORMAT (1,
                                             'BDT ',V_MOBSMSCNSL_SMSCHG_AMT) || ',';
         W_DEBIT_STR := '';
        END IF;
      
        IF (V_ATMCHG_AMT IS NOT NULL) AND
           V_ATMCHG_AMT > 0 THEN
          V_CONCATE_SMS := V_CONCATE_SMS || '' || W_DEBIT_STR ||
                           ' Debit Card Maintenance Charge: BDT ' ||
                           SP_GETFORMAT (1,
                                             'BDT ',V_ATMCHG_AMT);
         W_DEBIT_STR := '';
        END IF;
       
        IF (V_MOBSMSCNSL_SMS_VAT_AMT IS NOT NULL or V_MOBSMSCNSL_VAT_MNTCHG_AMT is not null OR V_ATM_VAT_AMT IS NOT NULL ) THEN
          V_CONCATE_SMS := V_CONCATE_SMS || ' Total VAT: BDT ' ||
                         SP_GETFORMAT (1,
                                             'BDT ',
                                               NVL(V_MOBSMSCNSL_VAT_MNTCHG_AMT,0)+NVL(V_MOBSMSCNSL_SMS_VAT_AMT,0)+NVL(V_ATM_VAT_AMT,0));
        END IF;
        
        V_CONCATE_SMS := V_CONCATE_SMS || '' || ' Closing Balance: BDT ' ||
                        SP_GETFORMAT (1,'BDT ', V_AVL_BALANCE);
      
        V_CONCATE_SMS := V_ACC_NO_TXT || V_CONCATE_SMS;
      
        V_CALL_CODE        := '88';
        V_MOBILE_WITH_CODE := V_CALL_CODE || V_MOBILE_NUMBER;
      
        INSERT_MOBSMSOUTQ(V_TRAN_BRN_CODE,
                         v_SMSMAST_CD,
                          V_MOBILE_WITH_CODE,
                          V_CONCATE_SMS,
                          V_ACNT_NUM);
      
      EXCEPTION
        WHEN OTHERS THEN
          ERROR_MSG := SQLERRM;
          INSERT INTO SMSALERTPROCERROR
            (SMSALERTPROCERROR_DATE, SMSALERTPROCERROR_ERROR)
          VALUES
            (SYSDATE,
             SUBSTR('PKG_BULK - ' || W_ERR_MSG || '-' || ERROR_MSG,
                    1,
                    300));
      END PROCIND_RECORD;
    END LOOP;
  END IF;
  END SP_CONSOLIDATED_SMS;


  PROCEDURE START_BRNWISE(V_ENTITY_NUM IN NUMBER,
                          P_BRN_CODE   IN NUMBER DEFAULT 0) IS
  
  BEGIN
        SP_CONSOLIDATED_SMS(V_ENTITY_NUM, P_BRN_CODE);
      
  EXCEPTION
     WHEN OTHERS THEN
       W_ERR_MSG:= substr((SQLCODE||' '|| SQLERRM),1, 200);
          INSERT INTO SMSALERTPROCERROR
            (SMSALERTPROCERROR_DATE, SMSALERTPROCERROR_ERROR)
          VALUES
            (SYSDATE, 'PKG_PREP_CONSOLIDATE_SMS - ' || W_ERR_MSG);
  END START_BRNWISE;

END PKG_PREP_CONSOLIDATE_SMS;
/

