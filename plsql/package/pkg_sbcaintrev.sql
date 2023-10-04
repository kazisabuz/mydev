/*<TOAD_FILE_CHUNK>*/
CREATE OR REPLACE PACKAGE PKG_SBCAINTREV
IS


   PROCEDURE SP_SBCAINTREV (P_ENTITY_NUM       IN NUMBER,
                            P_BRN_CODE         IN NUMBER DEFAULT 0,
                            P_INTERNAL_ACNUM   IN NUMBER DEFAULT 0);

   PROCEDURE SP_SBCAINTREV_BRN_WISE (P_ENTITY_NUM   IN NUMBER,
                                     P_BRN_CODE     IN NUMBER DEFAULT 0);
END PKG_SBCAINTREV;
/

CREATE OR REPLACE PACKAGE BODY PKG_SBCAINTREV
IS
   -- AUTHOR  : rajib.pradhan
   -- CREATED :24/06/2015
   -- PURPOSE :reverse interest accrual amount for sb accounts who has interest rate 0
   E_USEREXCEP                 EXCEPTION;
   W_ENTITY_NUMBER             NUMBER;
   W_CBD                       DATE;
   W_ERROR                     VARCHAR2 (1300);
   W_BRN_CODE                  NUMBER (6);
   W_INTERNAL_ACNUM            NUMBER (14);
   W_PASS_INTERNAL_ACNUM       NUMBER (14);
   W_USER_ID                   VARCHAR2 (8);
   W_TOT_DB_INT                NUMBER;
   W_TOT_ACTUAL_CR_INT         NUMBER;
   W_TOT_ACTUAL_DB_INT         NUMBER;
   W_DB_INT                    NUMBER;
   W_ACTUAL_DB_INT             NUMBER;
   W_DBINT_RNDOFF_REQD         CHAR (1);
   W_DIFF_DB_INT               NUMBER;
   W_DBINT_RNDOFF_FACTOR       NUMBER (9, 3);
   W_DBINT_RNDOFF_CHOICE       CHAR (1);
   W_BELOW_MINIMUM             BOOLEAN;
   W_DB_MIN_INT_AMT            NUMBER (18, 3);
   W_DB_AC_MIN_AMOUNT          NUMBER (18, 3);
   W_BELOW_MINIMUM_AC_AMOUNT   NUMBER (18, 3);
   W_PROCESS_DATE              DATE;
   IDX                         NUMBER;
   W_BASE_CURR_CODE            VARCHAR2(6);


    TYPE REC_SBCA_ACC IS RECORD(
      V_ACNTS_BRN_CODE              NUMBER(6),
      V_ACNTS_INTERNAL_ACNUM        NUMBER(14),
      V_ACNTS_OPENING_DATE          DATE,
      V_ACNTS_INT_DBCR_UPTO         DATE,
      V_ACNTS_CURR_CODE             VARCHAR2(3 BYTE),
      V_ACNTS_PROD_CODE             NUMBER,
      V_RAPARAM_INT_FOR_DB_BAL      CHAR(1 BYTE),
      V_RAPARAM_INT_FOR_CR_BAL      CHAR(1 BYTE),
      V_RAOPER_DBINT_RNDOFF_REQD    CHAR(1 BYTE),
      V_RAOPER_DBINT_RNDOFF_FACTOR  NUMBER(9,3),
      V_RAOPER_DBINT_RNDOFF_CHOICE  CHAR(1 BYTE),
      V_RAOPER_DB_MIN_INT_AMT       NUMBER(18,3),
      V_RAPARAM_DBINT_INCOME_GL     VARCHAR2(15 BYTE),
      V_RAPARAM_DBINT_ACCRUAL_GL    VARCHAR2(15 BYTE),
      V_RAOPER_CRINT_RNDOFF_REQD    CHAR(1 BYTE),
      V_RAOPER_CRINT_RNDOFF_FACTOR  NUMBER(9,3),
      V_RAOPER_CRINT_RNDOFF_CHOICE  CHAR(1 BYTE),
      V_RAOPER_CR_MIN_INT_AMT       NUMBER(18,3),
      V_RAPARAM_CRINT_ACCRUAL_GL    VARCHAR2(15 BYTE),
      V_RAPARAM_CRINT_EXP_GL        VARCHAR2(15 BYTE),
      V_RAPARAM_DBINT_RECOV_FREQ    CHAR(1 BYTE),
      V_RAPARAM_CRINT_CREDIT_FREQ   CHAR(1 BYTE),
      V_TOTAL_CR_INT                NUMBER,
      V_TOTAL_DR_INT                NUMBER,
      V_TOTAL_ACTUAL_CR_INT         NUMBER,
      V_TOTAL_ACTUAL_DR_INT         NUMBER);

    TYPE TT_REC_SBCA_ACC IS TABLE OF REC_SBCA_ACC INDEX BY PLS_INTEGER;

    T_REC_SBCA_ACC TT_REC_SBCA_ACC;

    W_POST_ARRAY_INDEX NUMBER:=0;
    W_ERROR_MESSAGE    VARCHAR2(1000);

    W_DEBIT_GL         VARCHAR2(100);
    W_CREDIT_GL        VARCHAR2(100);
    W_TOTAL_AMOUNT     NUMBER(18,3):=0;
    W_INT_AMOUNT     NUMBER(18,3):=0;
    W_TOTAL_INT_AMOUNT     NUMBER(18,3):=0;
    W_PRODUCT_CODE     NUMBER(10);


   PROCEDURE SP_SBCAINTREV (P_ENTITY_NUM       IN NUMBER,
                            P_BRN_CODE         IN NUMBER DEFAULT 0,
                            P_INTERNAL_ACNUM   IN NUMBER DEFAULT 0)
   IS
   BEGIN
      NULL;
   END;

   ------------------------------- for voucher posting -----------------------------

  PROCEDURE SET_TRAN_KEY_VALUES(P_ACCOUNT_BRANCH IN NUMBER, P_BUSINESS_DATE DATE) IS
  BEGIN
    PKG_AUTOPOST.PV_SYSTEM_POSTED_TRANSACTION  := TRUE;
    PKG_AUTOPOST.PV_TRAN_KEY.TRAN_BRN_CODE := P_ACCOUNT_BRANCH;
    PKG_AUTOPOST.PV_TRAN_KEY.TRAN_DATE_OF_TRAN := P_BUSINESS_DATE;
    PKG_AUTOPOST.PV_TRAN_KEY.TRAN_BATCH_NUMBER := 0;
    PKG_AUTOPOST.PV_TRAN_KEY.TRAN_BATCH_SL_NUM := 0;
  END SET_TRAN_KEY_VALUES;

  PROCEDURE SET_TRANBAT_VALUES IS
  BEGIN
    PKG_AUTOPOST.PV_TRANBAT.TRANBAT_SOURCE_TABLE := 'SBCAIA';
    PKG_AUTOPOST.PV_TRANBAT.TRANBAT_SOURCE_KEY   := 'PKG_SBCAINTREV';

    PKG_AUTOPOST.PV_TRANBAT.TRANBAT_NARR_DTL1 := 'SBCAIA Accrual Reversal';
  END SET_TRANBAT_VALUES;

  PROCEDURE MOVE_POST_ARRAY_VALUES(P_DB_CR_FLG    IN CHAR,
                                   P_CURR_CODE    IN VARCHAR2,
                                   P_TRAN_AMOUNT  IN NUMBER,
                                   P_AC_BRN_CODE  IN NUMBER,
                                   P_GL_CODE IN VARCHAR2,
                                   P_PROD_CODE    IN NUMBER) IS
  BEGIN
    W_POST_ARRAY_INDEX := W_POST_ARRAY_INDEX + 1;
    PKG_AUTOPOST.PV_TRAN_REC(W_POST_ARRAY_INDEX).TRAN_DB_CR_FLG := P_DB_CR_FLG;
    PKG_AUTOPOST.PV_TRAN_REC(W_POST_ARRAY_INDEX).TRAN_CURR_CODE := P_CURR_CODE;
    PKG_AUTOPOST.PV_TRAN_REC(W_POST_ARRAY_INDEX).TRAN_AMOUNT := P_TRAN_AMOUNT;
    PKG_AUTOPOST.PV_TRAN_REC(W_POST_ARRAY_INDEX).TRAN_ACING_BRN_CODE := P_AC_BRN_CODE;
    PKG_AUTOPOST.PV_TRAN_REC(W_POST_ARRAY_INDEX).TRAN_GLACC_CODE := P_GL_CODE;
    PKG_AUTOPOST.PV_TRAN_REC(W_POST_ARRAY_INDEX).TRAN_NARR_DTL1 := 'SBCA Accrual Reversal ';
    PKG_AUTOPOST.PV_TRAN_REC(W_POST_ARRAY_INDEX).TRAN_NARR_DTL2 := 'Prod Code - ' ||P_PROD_CODE;
    PKG_AUTOPOST.PV_TRAN_REC(W_POST_ARRAY_INDEX).TRAN_NARR_DTL3 := 'Curr Code - ' ||P_CURR_CODE;
  END MOVE_POST_ARRAY_VALUES;

  PROCEDURE POST_TRANSACTION(P_ACCOUNT_BRANCH NUMBER) IS
  W_ERROR_CODE VARCHAR2(100);
  W_ERROR VARCHAR2(1000);
  W_BATCH_NUM NUMBER;
  BEGIN
    PKG_APOST_INTERFACE.SP_POST_SODEOD_BATCH(W_ENTITY_NUMBER,
                                             'A',
                                             W_POST_ARRAY_INDEX,
                                             0,
                                             W_ERROR_CODE,
                                             W_ERROR,
                                             W_BATCH_NUM);
    PKG_AUTOPOST.PV_TRAN_REC.DELETE;

    IF (W_ERROR_CODE <> '0000') THEN
      W_ERROR_MESSAGE := SUBSTR('Process Brn Code -  '||W_ERROR_CODE||' '|| P_ACCOUNT_BRANCH || ' ' || FN_GET_AUTOPOST_ERR_MSG(W_ENTITY_NUMBER),1,1000);
      RAISE E_USEREXCEP;
    END IF;

  END POST_TRANSACTION;

  PROCEDURE POST_BRN_WISE_TRANSACTION(P_ACCOUNT_BRANCH IN NUMBER) IS
  BEGIN

    SET_TRAN_KEY_VALUES(P_ACCOUNT_BRANCH,W_CBD);
    SET_TRANBAT_VALUES;

    IF W_POST_ARRAY_INDEX > 0 THEN
      POST_TRANSACTION(P_ACCOUNT_BRANCH);
    END IF;
    PKG_APOST_INTERFACE.SP_POSTING_END(W_ENTITY_NUMBER);

    W_POST_ARRAY_INDEX := 0;
    W_INT_AMOUNT:=0;
    W_TOTAL_INT_AMOUNT:=0;
    W_TOTAL_AMOUNT:=0;

  END POST_BRN_WISE_TRANSACTION;

------------------------------- for voucher posting -----------------------------

 PROCEDURE INSERT_SBCAIA_ROW_PARA(P_ENTITY_NUMBER NUMBER,
                                  P_BRN       IN NUMBER,
                                  P_ACNUM     IN NUMBER,
                                  P_DBCR      IN CHAR,
                                  P_ACCR_DBCR IN CHAR,
                                  P_INT_AMT   IN NUMBER,
                                  P_SBCAIA_ACTUAL_ACCR_AMT IN NUMBER ,
                                  P_FROM_DATE IN DATE,
                                  P_UPTO_DATE IN DATE) IS

      V_MAXSL NUMBER;
    BEGIN

        SELECT NVL(MAX(SBCAIA_DAY_SL),0) + 1
          INTO V_MAXSL
          FROM SBCAIA
          WHERE SBCAIA_ENTITY_NUM = P_ENTITY_NUMBER
          AND SBCAIA_BRN_CODE = P_BRN
           AND SBCAIA_INTERNAL_ACNUM = P_ACNUM
           AND SBCAIA_CR_DB_INT_FLG = P_DBCR
           AND SBCAIA_DATE_OF_ENTRY = W_CBD;

        INSERT INTO SBCAIA
          (SBCAIA_ENTITY_NUM,SBCAIA_BRN_CODE,
           SBCAIA_INTERNAL_ACNUM,
           SBCAIA_CR_DB_INT_FLG,
           SBCAIA_DATE_OF_ENTRY,
           SBCAIA_DAY_SL,
           SBCAIA_PREV_INT_ACCR_UPTO_DT,
           SBCAIA_INT_ACCR_UPTO_DT,
           SBCAIA_TOT_PREV_INT_AMT,
           SBCAIA_TOT_NEW_INT_AMT,
           SBCAIA_AC_INT_ACCR_AMT,
           SBCAIA_BC_INT_ACCR_AMT,
           SBCAIA_BC_CONV_RATE,
           SBCAIA_INT_ACCR_DB_CR,
           SBCAIA_FROM_DATE,
           SBCAIA_UPTO_DATE,
           SBCAIA_ACCR_POSTED_BY,
           SBCAIA_ACCR_POSTED_ON,
           SBCAIA_LAST_MOD_BY,
           SBCAIA_LAST_MOD_ON,
           SBCAIA_INT_RATE,
           SBCAIA_SOURCE_TABLE,
           SBCAIA_SOURCE_KEY,
           SBCAIA_AC_INT_ACTUAL_ACCR_AMT,
           SBCAIA_BC_INT_ACTUAL_ACCR_AMT)
        VALUES
          (P_ENTITY_NUMBER ,
           P_BRN,
           P_ACNUM,
           P_DBCR,
           W_CBD,
           V_MAXSL,
           NULL,
           NULL,
           0,
           0,
           ABS(P_INT_AMT),
           ABS(P_INT_AMT),
           0,
           P_ACCR_DBCR,
           P_FROM_DATE,
           P_UPTO_DATE,
           W_USER_ID,
           SYSDATE,
           '',
           NULL,
           0,
           'SBCAINTREV',
           ' ',
           ABS(P_SBCAIA_ACTUAL_ACCR_AMT),
           ABS(P_SBCAIA_ACTUAL_ACCR_AMT));

          BEGIN
          UPDATE ACNTS
           SET ACNTS_INT_DBCR_UPTO = P_UPTO_DATE , ACNTS_MMB_INT_ACCR_UPTO=P_UPTO_DATE, ACNTS_INT_ACCR_UPTO=P_UPTO_DATE
           WHERE ACNTS_ENTITY_NUM = P_ENTITY_NUMBER
           AND  ACNTS_INTERNAL_ACNUM = P_ACNUM;
          END;


    EXCEPTION
      WHEN OTHERS THEN
        W_ERROR := 'Error in Creating SBCAIA '||SQLERRM;
        RAISE E_USEREXCEP;
    END INSERT_SBCAIA_ROW_PARA;


   PROCEDURE START_INT_REV(P_ENTITY_NUM   IN NUMBER,
                           P_BRN_CODE     IN NUMBER DEFAULT 0)
   IS
    V_ACCOUNTS_SQL CLOB;
    V_DBCR         VARCHAR2(1);
    V_ACCR_DBCR    VARCHAR2(1);
   BEGIN
    V_ACCOUNTS_SQL:='SELECT * FROM
            (
            SELECT ACNTS_BRN_CODE,
                   ACNTS_INTERNAL_ACNUM,
                   ACNTS_OPENING_DATE,
                   ACNTS_INT_DBCR_UPTO,
                   ACNTS_CURR_CODE,
                   ACNTS_PROD_CODE,
                   RAPARAM_INT_FOR_DB_BAL,
                   RAPARAM_INT_FOR_CR_BAL,
                   RAOPER_DBINT_RNDOFF_REQD,
                   RAOPER_DBINT_RNDOFF_FACTOR,
                   RAOPER_DBINT_RNDOFF_CHOICE,
                   RAOPER_DB_MIN_INT_AMT,
                   RAPARAM_DBINT_INCOME_GL,
                   RAPARAM_DBINT_ACCRUAL_GL,
                   RAOPER_CRINT_RNDOFF_REQD,
                   RAOPER_CRINT_RNDOFF_FACTOR,
                   RAOPER_CRINT_RNDOFF_CHOICE,
                   RAOPER_CR_MIN_INT_AMT,
                   RAPARAM_CRINT_ACCRUAL_GL,
                   RAPARAM_CRINT_EXP_GL,
                   RAPARAM_DBINT_RECOV_FREQ,
                   RAPARAM_CRINT_CREDIT_FREQ,
                   (NVL(SUM(DECODE(SBCAIA_INT_ACCR_DB_CR,''C'',ABS(SBCAIA_AC_INT_ACCR_AMT))),0))-(
                   NVL(SUM(DECODE(SBCAIA_INT_ACCR_DB_CR,''D'',ABS(SBCAIA_AC_INT_ACCR_AMT))),0)) TOTAL_CR_INT,
                   (NVL(SUM(DECODE(SBCAIA_INT_ACCR_DB_CR,''D'',ABS(SBCAIA_AC_INT_ACCR_AMT))),0))-
                   (NVL(SUM(DECODE(SBCAIA_INT_ACCR_DB_CR,''C'',ABS(SBCAIA_AC_INT_ACCR_AMT))),0)) TOTAL_DR_INT,
                   (NVL(SUM(DECODE(SBCAIA_INT_ACCR_DB_CR,''C'',ABS(SBCAIA_AC_INT_ACTUAL_ACCR_AMT))),0))-(
                   NVL(SUM(DECODE(SBCAIA_INT_ACCR_DB_CR,''D'',ABS(SBCAIA_AC_INT_ACTUAL_ACCR_AMT))),0)) TOTAL_ACTUAL_CR_INT,
                   (NVL(SUM(DECODE(SBCAIA_INT_ACCR_DB_CR,''D'',ABS(SBCAIA_AC_INT_ACTUAL_ACCR_AMT))),0))-(
                   NVL(SUM(DECODE(SBCAIA_INT_ACCR_DB_CR,''C'',ABS(SBCAIA_AC_INT_ACTUAL_ACCR_AMT))),0)) TOTAL_ACTUAL_DR_INT
              FROM ACNTS A,
                   RAOPERPARAM RA,
                   RAPARAM RP,
                   ACNTIR IR,
                   SBCAIA IA
             WHERE     A.ACNTS_ENTITY_NUM = :ENTITY_NUMBER
                   AND A.ACNTS_ENTITY_NUM = IR.ACNTIR_ENTITY_NUM
                   AND IR.ACNTIR_ENTITY_NUM=:ENTITY_NUMBER
                   AND IA.SBCAIA_ENTITY_NUM=:ENTITY_NUMBER
                   AND A.ACNTS_INTERNAL_ACNUM = IR.ACNTIR_INTERNAL_ACNUM
                   AND IA.SBCAIA_ENTITY_NUM=A.ACNTS_ENTITY_NUM
                   AND IA.SBCAIA_BRN_CODE= A.ACNTS_BRN_CODE
                   AND IA.SBCAIA_INTERNAL_ACNUM=A.ACNTS_INTERNAL_ACNUM
                   AND IR.ACNTIR_INT_DB_CR_FLG=''C''
                   and nvl(trim(ACNTIR_SLAB_REQ),0)=''0''
                   AND IA.SBCAIA_DATE_OF_ENTRY <= :W_CBD
                   AND IA.SBCAIA_BRN_CODE=:BRANCH_CODE
                   AND A.ACNTS_BRN_CODE=:BRANCH_CODE
                   AND IR.ACNTIR_INT_RATE = 0
                   AND A.ACNTS_AC_TYPE = RAPARAM_AC_TYPE
                   AND A.ACNTS_AC_TYPE = RAOPER_AC_TYPE
                   AND A.ACNTS_AC_SUB_TYPE = RAOPER_AC_SUB_TYPE
                   AND A.ACNTS_CURR_CODE = RAOPER_CURR_CODE
                   AND A.ACNTS_CLOSURE_DATE IS NULL
            GROUP BY ACNTS_BRN_CODE,
                   ACNTS_INTERNAL_ACNUM,
                   ACNTS_OPENING_DATE,
                   ACNTS_INT_DBCR_UPTO,
                   ACNTS_CURR_CODE,
                   ACNTS_PROD_CODE,
                   RAPARAM_INT_FOR_DB_BAL,
                   RAPARAM_INT_FOR_CR_BAL,
                   RAOPER_DBINT_RNDOFF_REQD,
                   RAOPER_DBINT_RNDOFF_FACTOR,
                   RAOPER_DBINT_RNDOFF_CHOICE,
                   RAOPER_DB_MIN_INT_AMT,
                   RAPARAM_DBINT_INCOME_GL,
                   RAPARAM_DBINT_ACCRUAL_GL,
                   RAOPER_CRINT_RNDOFF_REQD,
                   RAOPER_CRINT_RNDOFF_FACTOR,
                   RAOPER_CRINT_RNDOFF_CHOICE,
                   RAOPER_CR_MIN_INT_AMT,
                   RAPARAM_CRINT_ACCRUAL_GL,
                   RAPARAM_CRINT_EXP_GL,
                   RAPARAM_DBINT_RECOV_FREQ,
                   RAPARAM_CRINT_CREDIT_FREQ)
            WHERE TOTAL_CR_INT>=1 OR TOTAL_DR_INT>=1';

     EXECUTE IMMEDIATE V_ACCOUNTS_SQL BULK COLLECT INTO T_REC_SBCA_ACC
     USING P_ENTITY_NUM,P_ENTITY_NUM,P_ENTITY_NUM, W_CBD, P_BRN_CODE, P_BRN_CODE;

     FOR IND IN 1 .. T_REC_SBCA_ACC.COUNT LOOP

       IF T_REC_SBCA_ACC(IND).V_TOTAL_CR_INT>0 THEN

       W_INT_AMOUNT:=T_REC_SBCA_ACC(IND).V_TOTAL_CR_INT;

       W_TOTAL_INT_AMOUNT:=T_REC_SBCA_ACC(IND).V_TOTAL_ACTUAL_CR_INT;

       W_TOTAL_AMOUNT:=W_TOTAL_AMOUNT+W_INT_AMOUNT;

       W_DEBIT_GL:=T_REC_SBCA_ACC(IND).V_RAPARAM_CRINT_ACCRUAL_GL;
       W_CREDIT_GL:=T_REC_SBCA_ACC(IND).V_RAPARAM_CRINT_EXP_GL;

       V_DBCR      :='C';
       V_ACCR_DBCR :='D';

       ELSE

       W_INT_AMOUNT:=T_REC_SBCA_ACC(IND).V_TOTAL_DR_INT;

       W_TOTAL_INT_AMOUNT:=T_REC_SBCA_ACC(IND).V_TOTAL_ACTUAL_DR_INT;

       W_TOTAL_AMOUNT:=W_TOTAL_AMOUNT+W_INT_AMOUNT;

       W_DEBIT_GL:=T_REC_SBCA_ACC(IND).V_RAPARAM_CRINT_EXP_GL;
       W_CREDIT_GL:=T_REC_SBCA_ACC(IND).V_RAPARAM_CRINT_ACCRUAL_GL;

       V_DBCR      :='D';
       V_ACCR_DBCR :='C';

       END IF;

       W_PRODUCT_CODE:=T_REC_SBCA_ACC(IND).V_ACNTS_PROD_CODE;

       INSERT_SBCAIA_ROW_PARA(P_ENTITY_NUMBER   =>P_ENTITY_NUM,
                              P_BRN             =>T_REC_SBCA_ACC(IND).V_ACNTS_BRN_CODE,
                              P_ACNUM           =>T_REC_SBCA_ACC(IND).V_ACNTS_INTERNAL_ACNUM,
                              P_DBCR            =>V_DBCR,
                              P_ACCR_DBCR       =>V_ACCR_DBCR,
                              P_INT_AMT         =>W_INT_AMOUNT,
                              P_SBCAIA_ACTUAL_ACCR_AMT =>W_TOTAL_INT_AMOUNT,
                              P_FROM_DATE       =>T_REC_SBCA_ACC(IND).V_ACNTS_INT_DBCR_UPTO,
                              P_UPTO_DATE       =>W_CBD);


      IF IND>1 THEN

           IF T_REC_SBCA_ACC(IND-1).V_RAPARAM_CRINT_ACCRUAL_GL<>T_REC_SBCA_ACC(IND).V_RAPARAM_CRINT_ACCRUAL_GL
              OR T_REC_SBCA_ACC(IND-1).V_RAPARAM_CRINT_EXP_GL<>T_REC_SBCA_ACC(IND).V_RAPARAM_CRINT_EXP_GL THEN

              W_DEBIT_GL:=T_REC_SBCA_ACC(IND-1).V_RAPARAM_CRINT_ACCRUAL_GL;
              W_CREDIT_GL:=T_REC_SBCA_ACC(IND-1).V_RAPARAM_CRINT_EXP_GL;

               BEGIN
                ------------ MOVE TO DEBIT TRANSACTION
                MOVE_POST_ARRAY_VALUES(P_DB_CR_FLG => 'D',
                                       P_CURR_CODE =>W_BASE_CURR_CODE,
                                       P_TRAN_AMOUNT =>W_TOTAL_AMOUNT-W_INT_AMOUNT,
                                       P_AC_BRN_CODE =>P_BRN_CODE,
                                       P_GL_CODE =>W_DEBIT_GL,
                                       P_PROD_CODE =>W_PRODUCT_CODE);
               END;


               BEGIN
                ------------ MOVE TO CREDIT TRANSACTION
                MOVE_POST_ARRAY_VALUES(P_DB_CR_FLG => 'C',
                                       P_CURR_CODE =>W_BASE_CURR_CODE,
                                       P_TRAN_AMOUNT =>W_TOTAL_AMOUNT-W_INT_AMOUNT,
                                       P_AC_BRN_CODE =>P_BRN_CODE,
                                       P_GL_CODE =>W_CREDIT_GL,
                                       P_PROD_CODE =>W_PRODUCT_CODE);
               END;

              W_TOTAL_AMOUNT:=W_INT_AMOUNT;

            END IF;

      END IF;

      END LOOP;


     IF W_TOTAL_AMOUNT>0 THEN

       BEGIN
        ------------ MOVE TO DEBIT TRANSACTION
        MOVE_POST_ARRAY_VALUES(P_DB_CR_FLG => 'D',
                               P_CURR_CODE =>W_BASE_CURR_CODE,
                               P_TRAN_AMOUNT =>W_TOTAL_AMOUNT,
                               P_AC_BRN_CODE =>P_BRN_CODE,
                               P_GL_CODE =>W_DEBIT_GL,
                               P_PROD_CODE =>W_PRODUCT_CODE);
       END;


       BEGIN
        ------------ MOVE TO CREDIT TRANSACTION
        MOVE_POST_ARRAY_VALUES(P_DB_CR_FLG => 'C',
                               P_CURR_CODE =>W_BASE_CURR_CODE,
                               P_TRAN_AMOUNT =>W_TOTAL_AMOUNT,
                               P_AC_BRN_CODE =>P_BRN_CODE,
                               P_GL_CODE =>W_CREDIT_GL,
                               P_PROD_CODE =>W_PRODUCT_CODE);
       END;

      W_TOTAL_AMOUNT:=0;
     END IF;

     BEGIN

      IF W_POST_ARRAY_INDEX>0 THEN

        POST_BRN_WISE_TRANSACTION(P_BRN_CODE);

      END IF;

     END;

   END;

   PROCEDURE SP_SBCAINTREV_BRN_WISE (P_ENTITY_NUM   IN NUMBER,
                                     P_BRN_CODE     IN NUMBER DEFAULT 0)
   IS
   BEGIN
      PKG_ENTITY.SP_SET_ENTITY_CODE (P_ENTITY_NUM);
      W_ENTITY_NUMBER:=P_ENTITY_NUM;

      W_CBD := PKG_EODSOD_FLAGS.PV_CURRENT_DATE;

      W_USER_ID := PKG_EODSOD_FLAGS.PV_USER_ID;

      W_BASE_CURR_CODE   := PKG_PB_GLOBAL.FN_GET_INS_BASE_CURR(W_ENTITY_NUMBER);

      W_BRN_CODE:= P_BRN_CODE;

     <<START_PROC>>
      BEGIN

            PKG_PROCESS_CHECK.INIT_PROC_BRN_WISE (W_ENTITY_NUMBER,W_BRN_CODE);

            FOR IDX IN 1 .. PKG_PROCESS_CHECK.V_ACNTBRN.COUNT
            LOOP
               W_BRN_CODE := PKG_PROCESS_CHECK.V_ACNTBRN (IDX).LN_BRN_CODE;

               IF PKG_PROCESS_CHECK.CHK_BRN_ALREADY_PROCESSED (W_ENTITY_NUMBER,W_BRN_CODE) = FALSE THEN
                  START_INT_REV (W_ENTITY_NUMBER,W_BRN_CODE);

                  IF TRIM (PKG_EODSOD_FLAGS.PV_ERROR_MSG) IS NULL
                  THEN
                     PKG_PROCESS_CHECK.INSERT_ROW_INTO_EODSODPROCBRN (W_ENTITY_NUMBER,W_BRN_CODE);
                  END IF;

                  PKG_PROCESS_CHECK.CHECK_COMMIT_ROLLBACK_STATUS (W_ENTITY_NUMBER);

               END IF;
            END LOOP;

      EXCEPTION
         WHEN OTHERS
         THEN
            IF TRIM (W_ERROR) IS NULL
            THEN
               W_ERROR :=
                  SUBSTR ('Error in SP_SBCAINTPAY_BRN_WISE ' || SQLERRM,
                          1,
                          1000);
            END IF;

            PKG_EODSOD_FLAGS.PV_ERROR_MSG := W_ERROR;
            PKG_PB_GLOBAL.DETAIL_ERRLOG (P_ENTITY_NUM,
                                         'E',
                                         PKG_EODSOD_FLAGS.PV_ERROR_MSG,
                                         ' ',
                                         0);
            PKG_PB_GLOBAL.DETAIL_ERRLOG (P_ENTITY_NUM,
                                         'E',
                                         SUBSTR (SQLERRM, 1, 1000),
                                         ' ',
                                         0);
            RAISE E_USEREXCEP;
      END START_PROC;
   END;
END PKG_SBCAINTREV;
/



