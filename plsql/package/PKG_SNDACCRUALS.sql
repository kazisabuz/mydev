
CREATE OR REPLACE PACKAGE "PKG_SNDACCRUALS"
IS
   PROCEDURE SP_SBCAACCRUALS (V_ENTITY_NUM    IN NUMBER,
                              V_ACNT_NUMBER   IN NUMBER);

   PROCEDURE PROC_BRN_WISE (V_ENTITY_NUM   IN NUMBER,
                            V_BRN_CODE     IN NUMBER DEFAULT 0);
END PKG_SNDACCRUALS;
/
DROP PACKAGE BODY PKG_SNDACCRUALS;

CREATE OR REPLACE PACKAGE BODY         PKG_SNDACCRUALS
IS
   /*
      Modification History
       ------------------------------------------------------------------------------------------
      Sl.            Description                              Mod By             Mod on
      -------------------------------------------------------------------------------------------
      -------------------------------------------------------------------------------------------

      */
    V_GLOB_ENTITY_NUM    NUMBER(6);
   W_SLAB_WISE_REQ                  CHAR (1);
   W_SLAB_CHOICE                    CHAR (1);
   P_PRODIRH_SLAB_REQ               CHAR (1);
   P_PRODIRH_SLAB_CHOICE            CHAR (1);
   PP_PRODUCT_CODE                  NUMBER (4);
   PP_ACNTS_AC_CURR_CODE            VARCHAR2 (3);
   PP_ACNTS_AC_TYPE                 VARCHAR2 (5);
   PP_ACNTS_AC_SUB_TYPE             NUMBER (3);
   PP_DRCR                          CHAR (1);
   PP_VDATE                         DATE;

   V_BRN_CAT                        VARCHAR2 (2);
   
  EX_DML_ERRORS EXCEPTION;
  PRAGMA EXCEPTION_INIT(EX_DML_ERRORS, -24381);
  W_BULK_COUNT NUMBER(10);
  
TYPE REC_MIN_TRNDATE IS RECORD(
        TRAN_INTERNAL_ACNUM NUMBER(14),
        TRAN_VAL_DATE DATE
);

TYPE TT_MIN_TRNDATE IS TABLE OF REC_MIN_TRNDATE INDEX BY PLS_INTEGER;
T_MIN_TRNDATE TT_MIN_TRNDATE;

TYPE REC_TRAN_FILTER_DATE IS RECORD(
        TRAN_INTERNAL_ACNUM NUMBER(14),
        TRAN_FILTER_DATE DATE
);

TYPE TT_TRAN_FILTER_DATE IS TABLE OF REC_TRAN_FILTER_DATE INDEX BY PLS_INTEGER;
T_TRAN_FILTER_DATE TT_TRAN_FILTER_DATE;

TYPE TT_BRANCH_REC IS RECORD(
MBRN_CATEGORY MBRN.MBRN_CATEGORY%TYPE,
MBRN_CODE MBRN.MBRN_CODE%TYPE);

TYPE TT_BRANCH_CAT IS TABLE OF TT_BRANCH_REC INDEX BY BINARY_INTEGER;

T_BRANCH_CAT TT_BRANCH_CAT;

TYPE TRAN_DAILY_BAL IS RECORD(
     TRAN_INTERNAL_ACNUM NUMBER(14),
    TRAN_VALUE_DATE DATE,
    TRAN_AMOUNT     NUMBER(18, 3));

TYPE TT_TRAN_DAY_LIST IS TABLE OF TRAN_DAILY_BAL INDEX BY PLS_INTEGER;

T_TRAN_DAY_LIST TT_TRAN_DAY_LIST;

   FUNCTION GET_ACC_SELECT_SQL (V_PROC_ACNUM IN NUMBER)
      RETURN VARCHAR2;

        V_PROCESS_BRN_cODE               NUMBER (6);

        TYPE R_ACCOUNT_LIST IS RECORD
        (ACNTS_INTERNAL_ACNUM NUMBER(14),
        RAPARAM_CRINT_ACCR_FREQ  VARCHAR2(1),
        RAPARAM_DBINT_ACCR_FREQ  VARCHAR2(1),
        INT_FROM_DATE DATE
        );

        TYPE T_ACCOUNT_LIST IS TABLE OF R_ACCOUNT_LIST INDEX BY BINARY_INTEGER;

       V_DUMMY_INTERNAL_ACNUM T_ACCOUNT_LIST;
       
--   TYPE T_INTERNAL_ACNUM IS TABLE OF NUMBER (14)
--      INDEX BY PLS_INTEGER;
--
--   V_INTERNAL_ACNUM                 T_INTERNAL_ACNUM;
--
--   V_DUMMY_INTERNAL_ACNUM           T_INTERNAL_ACNUM;
   P_CURRENT_DATE                   DATE;
   P_USER_ID                        VARCHAR2 (8);
   P_ACNT_NUMBER                    NUMBER (14);
   W_SCAN_FROM_DATE                 DATE;
   E_USEREXCEP                      EXCEPTION;
   E_SKIPEXCEP                      EXCEPTION;
   W_ERR_MSG                        VARCHAR2 (1000);
   V_PROCESS_START_DATE             DATE;
   W_SQL_SUB                        VARCHAR2 (500);
   W_GOBACK_TO_GLOBAL               NUMBER (1);
   W_PRODIR_RATE_AVL                BOOLEAN;
   P_AVG_BAL                        FLOAT;

   TYPE RC IS REF CURSOR;

   TYPE SB_DENOM IS TABLE OF NUMBER (3)
      INDEX BY VARCHAR2 (12);

   TYPE SB_PROD_CODE IS TABLE OF NUMBER (4)
      INDEX BY PLS_INTEGER;

   TYPE SB_TRAN_MIN_VALUE_DATE IS TABLE OF DATE
      INDEX BY VARCHAR2 (14);

   TYPE SB_VD_OPEN_TRAN_BALANCE IS TABLE OF NUMBER (18, 3)
      INDEX BY VARCHAR2 (14);

   TYPE SB_FUTURE_AC_NUMBER IS TABLE OF DATE
      INDEX BY VARCHAR2 (14);

   TYPE SB_PROD_INT_RATE IS TABLE OF VARCHAR2 (12)
      INDEX BY VARCHAR2 (16);

   TYPE SB_ACNT_INT_RATE IS TABLE OF VARCHAR2 (10)
      INDEX BY VARCHAR2 (15);

   TYPE SB_RAPARAM_CR_DB IS RECORD
   (
      M_CREDIT_FREQ   CHAR (1),
      M_DEBIT_FREQ    CHAR (1)
   );

   TYPE SB_ACNTS IS RECORD
   (
      M_INTERNAL_ACNUM           NUMBER (14),
      M_ACNTS_CLIENT_NUM         NUMBER (12),
      M_ACNTS_AC_TYPE            VARCHAR2 (5),
      M_ACNTS_AC_SUB_TYPE        NUMBER (3),
      M_ACNTS_AC_CURR_CODE       VARCHAR2 (3),
      M_ACNTS_PROD_CODE          NUMBER (4),
      M_ACNTS_INT_ACCR_UPTO      DATE,
      M_ACNTS_OPENING_DATE       DATE,
      M_ACNTS_BASE_DATE          DATE,
      M_ACNTS_INT_FLAG           CHAR (1),
      M_RAPARAM_INT_FOR_CR_BAL   CHAR (1),
      M_RAPARAM_INT_FOR_DB_BAL   CHAR (1),
      M_ACNTS_AC_BRN_CODE        NUMBER (6),
      M_RAPARAM_CRINT_BASIS      CHAR (1),
      M_RAPARAM_DBINT_BASIS      CHAR (1),
      -- Avinash-SONALI-12SEP2012 Begin
      M_RAOPER_MIN_BAL_FOR_INT   NUMBER (18, 3),
      M_TRAN_VALUE_DT DATE
   );

   -- Avinash-SONALI-12SEP2012 End
   TYPE TSBCACALC_INTERNAL_ACNUM IS TABLE OF NUMBER (14)
      INDEX BY PLS_INTEGER;

   TYPE TSB_RAPARAM_CR_DB IS TABLE OF SB_RAPARAM_CR_DB
      INDEX BY VARCHAR2 (5);

   TYPE TSB_ACNTS IS TABLE OF SB_ACNTS
      INDEX BY PLS_INTEGER;

   TYPE TSBCACALC_PREV_ACCR_UPTO_DATE IS TABLE OF DATE
      INDEX BY PLS_INTEGER;

   TYPE TSBCACALC_INT_ACCR_UPTO_DATE IS TABLE OF DATE
      INDEX BY PLS_INTEGER;

   TYPE TSBCACALC_TOT_PREV_DB_INT_AMT IS TABLE OF NUMBER (18, 9)
      INDEX BY PLS_INTEGER;

   TYPE TSBCACALC_TOT_PREV_CR_INT_AMT IS TABLE OF NUMBER (18, 9)
      INDEX BY PLS_INTEGER;

   TYPE TSBCACALC_TOT_NEW_DB_INT_AMT IS TABLE OF NUMBER (18, 9)
      INDEX BY PLS_INTEGER;

   TYPE TSBCACALC_TOT_NEW_CR_INT_AMT IS TABLE OF NUMBER (18, 9)
      INDEX BY PLS_INTEGER;

   TYPE TSBCACALC_AC_DB_INT_ACCR_AMT IS TABLE OF NUMBER (18, 9)
      INDEX BY PLS_INTEGER;

   TYPE TSBCACALC_BC_DB_INT_ACCR_AMT IS TABLE OF NUMBER (18, 9)
      INDEX BY PLS_INTEGER;

   TYPE TSBCACALC_DB_INT_BC_CRATE IS TABLE OF NUMBER (14, 9)
      INDEX BY PLS_INTEGER;

   TYPE TSBCACALC_AC_CR_INT_ACCR_AMT IS TABLE OF NUMBER (18, 9)
      INDEX BY PLS_INTEGER;

   TYPE TSBCACALC_BC_CR_INT_ACCR_AMT IS TABLE OF NUMBER (18, 9)
      INDEX BY PLS_INTEGER;

   TYPE TSBCACALC_CR_INT_BC_CRATE IS TABLE OF NUMBER (14, 9)
      INDEX BY PLS_INTEGER;

   TYPE TSBCACALC_INT_RATE IS TABLE OF NUMBER (11, 6)
      INDEX BY PLS_INTEGER;

   TYPE TSBCACBRK_INTERNAL_ACNUM IS TABLE OF NUMBER (14)
      INDEX BY PLS_INTEGER;

   TYPE TSBCACBRK_BREAKUP_DATE IS TABLE OF DATE
      INDEX BY PLS_INTEGER;

   TYPE TSBCACBRK_PREV_BALANCE IS TABLE OF NUMBER (18, 3)
      INDEX BY PLS_INTEGER;

   TYPE TSBCACBRK_NEW_BALANCE IS TABLE OF NUMBER (18, 3)
      INDEX BY PLS_INTEGER;

   TYPE TSBCACBRK_PREV_DB_INT IS TABLE OF NUMBER (18, 9)
      INDEX BY PLS_INTEGER;

   TYPE TSBCACBRK_PREV_CR_INT IS TABLE OF NUMBER (18, 9)
      INDEX BY PLS_INTEGER;

   TYPE TSBCACBRK_NEW_DB_INT IS TABLE OF NUMBER (18, 9)
      INDEX BY PLS_INTEGER;

   TYPE TSBCACBRK_NEW_CR_INT IS TABLE OF NUMBER (18, 9)
      INDEX BY PLS_INTEGER;

   V_DUMMY_STRING_CR                VARCHAR2 (100);
   V_DUMMY_STRING_DB                VARCHAR2 (100);
   V_SB_DENOM                       SB_DENOM;
   V_SB_PROD_CODE                   SB_PROD_CODE;
   V_SB_RAPARAM_CR_DB               TSB_RAPARAM_CR_DB;
   V_SB_ACNTS                       TSB_ACNTS;
   V_COUNT_SB                       PLS_INTEGER;
   V_COUNT_BRK                      PLS_INTEGER;
   V_SB_PROD_INT_RATE               SB_PROD_INT_RATE;
   V_SB_ACNT_INT_RATE               SB_ACNT_INT_RATE;
   V_SBCACALC_PREV_ACCR_UPTO_DATE   TSBCACALC_PREV_ACCR_UPTO_DATE;
   V_SBCACALC_INT_ACCR_UPTO_DATE    TSBCACALC_INT_ACCR_UPTO_DATE;
   V_SBCACALC_TOT_PREV_DB_INT_AMT   TSBCACALC_TOT_PREV_DB_INT_AMT;
   V_SBCACALC_TOT_PREV_CR_INT_AMT   TSBCACALC_TOT_PREV_CR_INT_AMT;
   V_SBCACALC_TOT_NEW_DB_INT_AMT    TSBCACALC_TOT_NEW_DB_INT_AMT;
   V_SBCACALC_TOT_NEW_CR_INT_AMT    TSBCACALC_TOT_NEW_CR_INT_AMT;
   V_SBCACALC_AC_DB_INT_ACCR_AMT    TSBCACALC_AC_DB_INT_ACCR_AMT;
   V_SBCACALC_BC_DB_INT_ACCR_AMT    TSBCACALC_BC_DB_INT_ACCR_AMT;
   V_SBCACALC_DB_INT_BC_CRATE       TSBCACALC_DB_INT_BC_CRATE;
   V_SBCACALC_AC_CR_INT_ACCR_AMT    TSBCACALC_AC_CR_INT_ACCR_AMT;
   V_SBCACALC_BC_CR_INT_ACCR_AMT    TSBCACALC_BC_CR_INT_ACCR_AMT;
   V_SBCACALC_CR_INT_BC_CRATE       TSBCACALC_CR_INT_BC_CRATE;
   V_SBCACALC_INT_RATE              TSBCACALC_INT_RATE;
   V_SBCACALC_INTERNAL_ACNUM        TSBCACALC_INTERNAL_ACNUM;
   V_SBCACBRK_INTERNAL_ACNUM        TSBCACBRK_INTERNAL_ACNUM;
   V_SBCACBRK_BREAKUP_DATE          TSBCACBRK_BREAKUP_DATE;
   V_SBCACBRK_PREV_BALANCE          TSBCACBRK_PREV_BALANCE;
   V_SBCACBRK_NEW_BALANCE           TSBCACBRK_NEW_BALANCE;
   V_SBCACBRK_PREV_DB_INT           TSBCACBRK_PREV_DB_INT;
   V_SBCACBRK_PREV_CR_INT           TSBCACBRK_PREV_CR_INT;
   V_SBCACBRK_NEW_DB_INT            TSBCACBRK_NEW_DB_INT;
   V_SBCACBRK_NEW_CR_INT            TSBCACBRK_NEW_CR_INT;

   V_SBCATEMP_INTERNAL_ACNUM        NUMBER (14);
   V_SBCATEMP_VALUE_DATE            DATE;
   V_SBCATEMP_PREV_BALANCE          NUMBER (18, 3);
   V_SBCATEMP_NEW_BALANCE           NUMBER (18, 3);
   V_SBCATEMP_PREV_DB_INT           NUMBER (18, 3);
   V_SBCATEMP_PREV_CR_INT           NUMBER (18, 3);
   V_SBCATEMP_NEW_DB_INT            NUMBER (18, 3);
   V_SBCATEMP_NEW_CR_INT            NUMBER (18, 3);

   W_PREV_BRN_CODE                  MBRN.MBRN_CODE%TYPE;
   W_BASE_INT_RATE                  VARCHAR2 (6);
   W_FINYEAR                        NUMBER (4);
   W_STARTMNTH                      NUMBER (1) := 0;
   W_SQL                            VARCHAR2 (4300);
   W_RUN_NO                         NUMBER (8);
   V_BRN_CODE                       NUMBER (6);
   V_PREV_BRN_CODE                  NUMBER (6);
   V_ACNTS_AC_CURR_CODE             VARCHAR2 (3);
   V_ACNTS_PROD_CODE                NUMBER (4);
   V_ACNTS_AC_TYPE                  VARCHAR2 (5);
   V_ACNTS_AC_SUB_TYPE              NUMBER (3);
   W_UPDATED_IN_TEMP                BOOLEAN;
   V_ACNTS_INT_ACCR_UPTO            DATE;
   V_ACNTS_INTERNAL_ACNUM           NUMBER (14);
   V_ACNTS_INT_FLAG                 CHAR (1);
   V_MINBAL_INT_ELIGIBILITY         RAOPERPARAM.RAOPER_MIN_BAL_INT_ELGIBILITY%TYPE;
   W_PRINCIPAL_AMT                  NUMBER;
   W_BREAK_UP_ADDED                 NUMBER;
   W_SKIP_UPDATION                  BOOLEAN;
   W_PRESENT_ACNT_WISE              CHAR (1);
   W_SLABWISE_INTEREST_RATE_CR      BOOLEAN;
   W_SLABWISE_INTEREST_RATE_DB      BOOLEAN;
   W_ACCOUNT_TYPE_FOUND             VARCHAR2 (5);
   W_ACCOUNT_STYPE_FOUND            NUMBER (3);
   W_INTEREST_RATE                  NUMBER;
   W_IA_UPTO_DATE                   DATE;
   W_EARLY_VALUE_DATE               DATE;
   W_PREV_BUS_DATE                  DATE;
   W_PROC_DATE                      DATE;
   W_OVER                           NUMBER;
   W_PREV_BAL                       NUMBER;
   W_NEW_BAL                        NUMBER;
   W_PREV_DB_INT                    NUMBER;
   W_PREV_CR_INT                    NUMBER;
   W_NEW_DB_INT                     NUMBER;
   W_NEW_CR_INT                     NUMBER;
   W_INT_FOR_CRBAL                  NUMBER;
   W_INT_FOR_DBBAL                  NUMBER;

   W_RAPARAM_CRINT_BASIS            CHAR (1);
   W_RAPARAM_DBINT_BASIS            CHAR (1);

   W_TOT_DB_INT                     NUMBER;
   W_TOT_CR_INT                     NUMBER;
   W_TOT_PREV_DB_INT                NUMBER;
   W_TOT_PREV_CR_INT                NUMBER;
   W_TOT_NEW_DB_INT                 NUMBER;
   W_TOT_NEW_CR_INT                 NUMBER;
   DBINT_BASIS                      NUMBER (3);
   CRINT_BASIS                      NUMBER (3);
   W_PROCESS_BACK_VALUE_DATE        BOOLEAN;
   V_MAX_VALUE_DATE                 DATE;
   W_TOT_INT_RATE                   NUMBER (7, 4);
   W_INTEREST_AMOUNT                NUMBER;
   V_PRODUCT_CODE                   NUMBER (4);
   W_SPACE                          CHAR (1);
   V_MAX_PRODIR_DATE                DATE;
   V_BREAK_UP_DATE                  DATE;
   V_ACCOUNT_NUMBER_STRING          VARCHAR2 (14);
   V_DUMMY_PROCESS_STRING           VARCHAR2 (100);
   V_PRODIR_STRING_CR               VARCHAR2 (100);
   V_ACNTIR_STRING_CR               VARCHAR2 (100);
   V_PRODIR_STRING_DB               VARCHAR2 (100);
   V_ACNTIR_STRING_DB               VARCHAR2 (100);
   V_PRODIR_ACSTYPE_SPACE_CR        VARCHAR2 (100);
   V_PRODIR_ACSTYPE_SPACE_DB        VARCHAR2 (100);
   V_PRODIR_ACTYPE_SPACE_CR         VARCHAR2 (100);
   V_PRODIR_ACTYPE_SPACE_DB         VARCHAR2 (100);

   W_MNTHEND                        NUMBER (1);
   W_QTREND                         NUMBER (1);
   W_HYREND                         NUMBER (1);
   W_YREND                          NUMBER (1);

PROCEDURE SET_MIN_TRAN_DATA(P_TRAN_YEAR NUMBER);

PROCEDURE SET_DAY_WISE_BALANCE(P_TRAN_YEAR NUMBER);


   PROCEDURE RECORD_EXCEPTION (W_EXCEPTION_DESC IN VARCHAR2)
   IS
   BEGIN
      PKG_PB_GLOBAL.DETAIL_ERRLOG (V_GLOB_ENTITY_NUM,
                                   'X',
                                   W_EXCEPTION_DESC,
                                   ' ',
                                   V_ACNTS_INTERNAL_ACNUM);
   END RECORD_EXCEPTION;

   PROCEDURE GET_INT_BASIS
   IS
      TYPE M_DENOM_TEMP IS RECORD
      (
         M_AC_SUB_CURR_CODE   VARCHAR2 (11),
         DB_INT_FLAG          CHAR (1),
         CR_INT_FLAG          CHAR (1)
      );

      TYPE TM_DENOM_TEMP IS TABLE OF M_DENOM_TEMP
         INDEX BY PLS_INTEGER;

      V_M_DENOM_TEMP   TM_DENOM_TEMP;
   BEGIN
      W_SQL :=
         'SELECT LPAD(RAOPER_AC_TYPE ,5,''0'') || LPAD(RAOPER_AC_SUB_TYPE  ,3,0) || RAOPER_CURR_CODE ,
                     RAOPER_DB_INT_CALCN_BASIS,
                     RAOPER_CR_INT_CALCN_BASIS
                     FROM RAOPERPARAM';

      EXECUTE IMMEDIATE W_SQL BULK COLLECT INTO V_M_DENOM_TEMP;

      FOR M_INDEX IN 1 .. V_M_DENOM_TEMP.COUNT
      LOOP
         CASE V_M_DENOM_TEMP (M_INDEX).DB_INT_FLAG
            WHEN '1'
            THEN
               V_SB_DENOM (
                  (V_M_DENOM_TEMP (M_INDEX).M_AC_SUB_CURR_CODE) || 'D') :=
                  360;
            WHEN '2'
            THEN
               V_SB_DENOM (
                  (V_M_DENOM_TEMP (M_INDEX).M_AC_SUB_CURR_CODE) || 'D') :=
                  365;
            WHEN '3'
            THEN
               V_SB_DENOM (
                  (V_M_DENOM_TEMP (M_INDEX).M_AC_SUB_CURR_CODE) || 'D') :=
                  366;
            ELSE
               V_SB_DENOM (
                  (V_M_DENOM_TEMP (M_INDEX).M_AC_SUB_CURR_CODE) || 'D') :=
                  360;
         END CASE;

         CASE V_M_DENOM_TEMP (M_INDEX).CR_INT_FLAG
            WHEN '1'
            THEN
               V_SB_DENOM (
                  (V_M_DENOM_TEMP (M_INDEX).M_AC_SUB_CURR_CODE) || 'C') :=
                  360;
            WHEN '2'
            THEN
               V_SB_DENOM (
                  (V_M_DENOM_TEMP (M_INDEX).M_AC_SUB_CURR_CODE) || 'C') :=
                  365;
            WHEN '3'
            THEN
               V_SB_DENOM (
                  (V_M_DENOM_TEMP (M_INDEX).M_AC_SUB_CURR_CODE) || 'C') :=
                  366;
            ELSE
               V_SB_DENOM (
                  (V_M_DENOM_TEMP (M_INDEX).M_AC_SUB_CURR_CODE) || 'C') :=
                  360;
         END CASE;
      END LOOP;

      V_M_DENOM_TEMP.DELETE;
   END GET_INT_BASIS;


   PROCEDURE DELETE_TEMP_TABLE (W_DEL_RUN_NO IN NUMBER)
   IS
   BEGIN
      DELETE FROM SBCACALCCTL S
            WHERE     SBCACTL_ENTITY_NUM = V_GLOB_ENTITY_NUM
                  AND S.SBCACTL_RUN_NUMBER = W_DEL_RUN_NO;

      DELETE FROM SBCACALC SS
            WHERE     SBCACALC_ENTITY_NUM = V_GLOB_ENTITY_NUM
                  AND SS.SBCACALC_RUN_NUMBER = W_DEL_RUN_NO;

      DELETE FROM SBCACALCBRK SSS
            WHERE     SBCACBRK_ENTITY_NUM = V_GLOB_ENTITY_NUM
                  AND SSS.SBCACBRK_RUN_NUMBER = W_DEL_RUN_NO;
   END DELETE_TEMP_TABLE;

   FUNCTION GET_RUNNO
      RETURN NUMBER
   IS
      V_SBCACTL_RUN_NUMBER   NUMBER (8);
   BEGIN
     <<READNUM>>
      BEGIN
         SELECT GENRUNNUM.NEXTVAL INTO W_RUN_NO FROM DUAL;
      END READNUM;

      DELETE_TEMP_TABLE (W_RUN_NO);

      RETURN W_RUN_NO;
   END GET_RUNNO;



   PROCEDURE WRITE_SBCACALCCTL_FILE
   IS
      RC_SBCALC              RC;
      V_SBCACTL_RUN_NUMBER   NUMBER (8);
   BEGIN
      INSERT INTO SBCACALCCTL (SBCACTL_ENTITY_NUM,
                               SBCACTL_RUN_NUMBER,
                               SBCACTL_INTERNAL_ACNUM,
                               SBCACTL_RUN_DATE,
                               SBCACTL_ACCRUAL_UPTO_DATE,
                               SBCACTL_RUN_BY,
                               SBCACTL_RUN_ON,
                               SBCACTL_POSTED_BY,
                               SBCACTL_POSTED_ON,
                               SBCACTL_POSTED_TO_BATCH_NUM,
                               SBCACTL_POSTED_TO_BRANCH)
           VALUES (V_GLOB_ENTITY_NUM,
                   W_RUN_NO,
                   P_ACNT_NUMBER,
                   P_CURRENT_DATE,
                   P_CURRENT_DATE,
                   TRIM (P_USER_ID),
                   P_CURRENT_DATE,
                   ' ',
                   NULL,
                   0,
                   0);
   END WRITE_SBCACALCCTL_FILE;


   PROCEDURE INIT_SBCACALC_ARRAY
   IS
   BEGIN
      V_SBCACALC_PREV_ACCR_UPTO_DATE (V_COUNT_SB) := NULL;
      V_SBCACALC_INT_ACCR_UPTO_DATE (V_COUNT_SB) := NULL;
      V_SBCACALC_TOT_PREV_DB_INT_AMT (V_COUNT_SB) := 0;
      V_SBCACALC_TOT_PREV_CR_INT_AMT (V_COUNT_SB) := 0;
      V_SBCACALC_TOT_NEW_DB_INT_AMT (V_COUNT_SB) := 0;
      V_SBCACALC_TOT_NEW_CR_INT_AMT (V_COUNT_SB) := 0;
      V_SBCACALC_AC_DB_INT_ACCR_AMT (V_COUNT_SB) := 0;
      V_SBCACALC_BC_DB_INT_ACCR_AMT (V_COUNT_SB) := 0;
      V_SBCACALC_DB_INT_BC_CRATE (V_COUNT_SB) := 0;
      V_SBCACALC_AC_CR_INT_ACCR_AMT (V_COUNT_SB) := 0;
      V_SBCACALC_BC_CR_INT_ACCR_AMT (V_COUNT_SB) := 0;
      V_SBCACALC_CR_INT_BC_CRATE (V_COUNT_SB) := 0;
      V_SBCACALC_INT_RATE (V_COUNT_SB) := 0;
   END INIT_SBCACALC_ARRAY;

   PROCEDURE WRITE_SBCACALCBRK
   IS
   BEGIN
      IF V_SBCACBRK_INTERNAL_ACNUM.COUNT > 0
      THEN
         FORALL M_INDEX IN 1 .. V_SBCACBRK_INTERNAL_ACNUM.COUNT
            INSERT INTO SBCACALCBRK (SBCACBRK_ENTITY_NUM,
                                     SBCACBRK_RUN_NUMBER,
                                     SBCACBRK_INTERNAL_ACNUM,
                                     SBCACBRK_BREAKUP_DATE,
                                     SBCACBRK_PREV_BALANCE,
                                     SBCACBRK_NEW_BALANCE,
                                     SBCACBRK_PREV_DB_INT,
                                     SBCACBRK_PREV_CR_INT,
                                     SBCACBRK_NEW_DB_INT,
                                     SBCACBRK_NEW_CR_INT)
                 VALUES (V_GLOB_ENTITY_NUM,
                         W_RUN_NO,
                         V_SBCACBRK_INTERNAL_ACNUM (M_INDEX),
                         V_SBCACBRK_BREAKUP_DATE (M_INDEX),
                         V_SBCACBRK_PREV_BALANCE (M_INDEX),
                         V_SBCACBRK_NEW_BALANCE (M_INDEX),
                         V_SBCACBRK_PREV_DB_INT (M_INDEX),
                         V_SBCACBRK_PREV_CR_INT (M_INDEX),
                         V_SBCACBRK_NEW_DB_INT (M_INDEX),
                         V_SBCACBRK_NEW_CR_INT (M_INDEX));
      END IF;
   END WRITE_SBCACALCBRK;



   PROCEDURE WRITE_SBCACALC_FILE
   IS
   BEGIN
      IF V_SBCACALC_INTERNAL_ACNUM.COUNT > 0
      THEN
         FORALL M_INDEX IN 1 .. V_SBCACALC_INTERNAL_ACNUM.COUNT
            INSERT INTO SBCACALC (SBCACALC_ENTITY_NUM,
                                  SBCACALC_RUN_NUMBER,
                                  SBCACALC_INTERNAL_ACNUM,
                                  SBCACALC_PREV_ACCR_UPTO_DATE,
                                  SBCACALC_INT_ACCR_UPTO_DATE,
                                  SBCACALC_TOT_PREV_DB_INT_AMT,
                                  SBCACALC_TOT_PREV_CR_INT_AMT,
                                  SBCACALC_TOT_NEW_DB_INT_AMT,
                                  SBCACALC_TOT_NEW_CR_INT_AMT,
                                  SBCACALC_AC_DB_INT_ACCR_AMT,
                                  SBCACALC_BC_DB_INT_ACCR_AMT,
                                  SBCACALC_DB_INT_BC_CRATE,
                                  SBCACALC_AC_CR_INT_ACCR_AMT,
                                  SBCACALC_BC_CR_INT_ACCR_AMT,
                                  SBCACALC_CR_INT_BC_CRATE,
                                  SBCACALC_INT_RATE)
                 VALUES (V_GLOB_ENTITY_NUM,
                         W_RUN_NO,
                         V_SBCACALC_INTERNAL_ACNUM (M_INDEX),
                         V_SBCACALC_PREV_ACCR_UPTO_DATE (M_INDEX),
                         V_SBCACALC_INT_ACCR_UPTO_DATE (M_INDEX),
                         V_SBCACALC_TOT_PREV_DB_INT_AMT (M_INDEX),
                         V_SBCACALC_TOT_PREV_CR_INT_AMT (M_INDEX),
                         V_SBCACALC_TOT_NEW_DB_INT_AMT (M_INDEX),
                         V_SBCACALC_TOT_NEW_CR_INT_AMT (M_INDEX),
                         V_SBCACALC_AC_DB_INT_ACCR_AMT (M_INDEX),
                         V_SBCACALC_BC_DB_INT_ACCR_AMT (M_INDEX),
                         V_SBCACALC_DB_INT_BC_CRATE (M_INDEX),
                         V_SBCACALC_AC_CR_INT_ACCR_AMT (M_INDEX),
                         V_SBCACALC_BC_CR_INT_ACCR_AMT (M_INDEX),
                         V_SBCACALC_CR_INT_BC_CRATE (M_INDEX),
                         V_SBCACALC_INT_RATE (M_INDEX));
      END IF;
   END WRITE_SBCACALC_FILE;


   PROCEDURE DESTROY_EACH_COLLECTION
   IS
   BEGIN
      V_SBCACALC_INTERNAL_ACNUM.DELETE;
      V_SBCACALC_PREV_ACCR_UPTO_DATE.DELETE;
      V_SBCACALC_INT_ACCR_UPTO_DATE.DELETE;
      V_SBCACALC_TOT_PREV_DB_INT_AMT.DELETE;
      V_SBCACALC_TOT_PREV_CR_INT_AMT.DELETE;
      V_SBCACALC_TOT_NEW_DB_INT_AMT.DELETE;
      V_SBCACALC_TOT_NEW_CR_INT_AMT.DELETE;
      V_SBCACALC_AC_DB_INT_ACCR_AMT.DELETE;
      V_SBCACALC_BC_DB_INT_ACCR_AMT.DELETE;
      V_SBCACALC_DB_INT_BC_CRATE.DELETE;
      V_SBCACALC_AC_CR_INT_ACCR_AMT.DELETE;
      V_SBCACALC_BC_CR_INT_ACCR_AMT.DELETE;
      V_SBCACALC_CR_INT_BC_CRATE.DELETE;
      V_SBCACALC_INT_RATE.DELETE;
      V_SBCACBRK_INTERNAL_ACNUM.DELETE;
      V_SBCACBRK_BREAKUP_DATE.DELETE;
      V_SBCACBRK_PREV_BALANCE.DELETE;
      V_SBCACBRK_NEW_BALANCE.DELETE;
      V_SBCACBRK_PREV_DB_INT.DELETE;
      V_SBCACBRK_PREV_CR_INT.DELETE;
      V_SBCACBRK_NEW_DB_INT.DELETE;
      V_SBCACBRK_NEW_CR_INT.DELETE;
   END DESTROY_EACH_COLLECTION;

   PROCEDURE RESET_VARIABLES
   IS
   BEGIN
      W_BREAK_UP_ADDED := '0';
      W_SKIP_UPDATION := FALSE;
      W_PRESENT_ACNT_WISE := '0';
      W_SLABWISE_INTEREST_RATE_CR := FALSE;
      W_SLABWISE_INTEREST_RATE_DB := FALSE;
      W_ACCOUNT_TYPE_FOUND := '';
      W_INTEREST_RATE := 0;
      W_IA_UPTO_DATE := NULL;
      W_EARLY_VALUE_DATE := NULL;
      W_PREV_BUS_DATE := NULL;
      W_PROC_DATE := NULL;
      W_OVER := 0;
      W_PREV_BAL := 0;
      W_NEW_BAL := 0;
      W_PREV_DB_INT := 0;
      W_PREV_CR_INT := 0;
      W_NEW_DB_INT := 0;
      W_NEW_CR_INT := 0;
      W_INT_FOR_CRBAL := 0;
      W_INT_FOR_DBBAL := 0;
      W_RAPARAM_CRINT_BASIS := '';
      W_RAPARAM_DBINT_BASIS := '';
      W_TOT_DB_INT := 0;
      W_TOT_CR_INT := 0;
      W_TOT_PREV_DB_INT := 0;
      W_TOT_PREV_CR_INT := 0;
      W_TOT_NEW_DB_INT := 0;
      W_TOT_NEW_CR_INT := 0;
   END RESET_VARIABLES;

   FUNCTION GET_VALUE_DATE_PREV_MONTH (W_VALUE_DATE IN DATE)
      RETURN NUMBER
   IS
      V_TRAN_BALANCE   NUMBER (18, 3);
      RC_ACNTPREV      RC;
      W_FROM_DATE      DATE;
   BEGIN
      W_FROM_DATE :=
         W_VALUE_DATE - TO_NUMBER (TO_CHAR (W_VALUE_DATE, 'DD')) + 1;

      W_SQL :='select SUM(DECODE(TRAN_DB_CR_FLG,'
         || CHR (39)
         || 'C'
         || CHR (39)
         || ',TRAN_AMOUNT,0))- SUM(DECODE(TRAN_DB_CR_FLG,'
         || CHR (39)
         || 'D'
         || CHR (39)
         || ',TRAN_AMOUNT,0))
       AS tranbalance from TRAN'
         || SP_GETFINYEAR (V_GLOB_ENTITY_NUM, P_CURRENT_DATE)
         || ' where TRAN_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND  '
         || ' Tran_Value_date < '
         || CHR (39)
         || W_FROM_DATE
         || CHR (39)
         || ' and TRAN_INTERNAL_ACNUM = '
         || V_ACNTS_INTERNAL_ACNUM
         || ' and TRAN_DATE_OF_TRAN >= '
         || CHR (39)
         || W_SCAN_FROM_DATE
         || CHR (39)
         || ' and TRAN_AUTH_ON is not null';

      OPEN RC_ACNTPREV FOR W_SQL;

      FETCH RC_ACNTPREV INTO V_TRAN_BALANCE;

      IF RC_ACNTPREV%FOUND
      THEN
         RETURN NVL (V_TRAN_BALANCE, 0);
      ELSE
         RETURN 0;
      END IF;

      CLOSE RC_ACNTPREV;
   END GET_VALUE_DATE_PREV_MONTH;

   FUNCTION GET_TRANBAL (VALUE_DATE IN DATE, PREVNEW IN CHAR)
      RETURN NUMBER
   IS
      RC_TRANBAL      RC;
      W_PREV_YEAR     NUMBER (4);
      W_FROM_DATE     DATE;
      TBAL            NUMBER (18, 3);
      V_TRANBALANCE   NUMBER (18, 3);
   BEGIN
      W_PREV_YEAR := W_FINYEAR - 1;
      W_FROM_DATE := VALUE_DATE - TO_NUMBER (TO_CHAR (VALUE_DATE, 'DD')) + 1;
      TBAL := 0;

      IF TRIM (PREVNEW) = 'P'
      THEN
      W_SQL :='SELECT SUM(TRAN_AMOUNT) tranbalance
                      FROM TRAN_DAILY_BAL
                      WHERE TRAN_INTERNAL_ACNUM=:1
                      AND  TRAN_VALUE_DATE>=:2
                      AND  TRAN_VALUE_DATE<=:3
                      AND  TRAN_VALUE_DATE<:4';
            --         W_SQL :=
            --               'select (SUM(DECODE(TRAN_DB_CR_FLG,'
            --            || CHR (39)
            --            || 'C'
            --            || CHR (39)
            --            || ',TRAN_AMOUNT,0))- SUM(DECODE(TRAN_DB_CR_FLG,'
            --            || CHR (39)
            --            || 'D'
            --            || CHR (39)
            --            || ',TRAN_AMOUNT,0)))
            --                 as tranbalance from TRAN'
            --            || W_PREV_YEAR
            --            || ' where TRAN_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND
            --                 Tran_Value_date >=                                                                         :1
            --                 AND Tran_value_date <=                                                                     :2
            --                 AND TRAN_INTERNAL_ACNUM =                                                                  :3
            --                 AND TRAN_DATE_OF_TRAN <                                                                    :4
            --                 AND TRAN_AUTH_ON is not null';
      ELSIF TRIM (PREVNEW) = 'N'
      THEN
      
      W_SQL :='SELECT SUM(TRAN_AMOUNT) tranbalance
                      FROM TRAN_DAILY_BAL
                      WHERE TRAN_INTERNAL_ACNUM=:1
                      AND  TRAN_VALUE_DATE>=:2
                      AND  TRAN_VALUE_DATE<=:3
                      AND  TRAN_VALUE_DATE<=:4';
        --         W_SQL :=
        --               'select (SUM(DECODE(TRAN_DB_CR_FLG,'
        --            || CHR (39)
        --            || 'C'
        --            || CHR (39)
        --            || ',TRAN_AMOUNT,0))- SUM(DECODE(TRAN_DB_CR_FLG,'
        --            || CHR (39)
        --            || 'D'
        --            || CHR (39)
        --            || ',TRAN_AMOUNT,0)))
        --                 as tranbalance from TRAN'
        --            || W_PREV_YEAR
        --            || ' where TRAN_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND
        --                 Tran_Value_date >=                                                                         :1
        --                 AND Tran_value_date <=                                                                     :2
        --                 AND TRAN_INTERNAL_ACNUM =                                                                  :3
        --                 AND TRAN_DATE_OF_TRAN <=                                                                   :4
        --                 AND TRAN_AUTH_ON is not null';
      END IF;

      OPEN RC_TRANBAL FOR W_SQL
         USING V_ACNTS_INTERNAL_ACNUM,
                W_FROM_DATE,
               VALUE_DATE,
               P_CURRENT_DATE;

      FETCH RC_TRANBAL INTO V_TRANBALANCE;

      IF RC_TRANBAL%FOUND
      THEN
         TBAL := TBAL + NVL (V_TRANBALANCE, 0);
      END IF;

      CLOSE RC_TRANBAL;

--      V_TRANBALANCE := 0;
--
--      IF TRIM (PREVNEW) = 'P'
--      THEN
--         W_SQL :=
--               'select (SUM(DECODE(TRAN_DB_CR_FLG,'
--            || CHR (39)
--            || 'C'
--            || CHR (39)
--            || ',TRAN_AMOUNT,0))- SUM(DECODE(TRAN_DB_CR_FLG,'
--            || CHR (39)
--            || 'D'
--            || CHR (39)
--            || ',TRAN_AMOUNT,0)))
--                 as tranbalance from TRAN'
--            || W_FINYEAR
--            || ' where TRAN_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND
--
--                  Tran_Value_date >=                                                                       :1
--                  AND Tran_value_date <=                                                                   :2
--                  AND TRAN_INTERNAL_ACNUM =                                                                :3
--                  AND TRAN_DATE_OF_TRAN <                                                                  :4
--                  AND TRAN_AUTH_ON is not null';
--      ELSIF TRIM (PREVNEW) = 'N'
--      THEN
--         W_SQL :=
--               'select (SUM(DECODE(TRAN_DB_CR_FLG,'
--            || CHR (39)
--            || 'C'
--            || CHR (39)
--            || ',TRAN_AMOUNT,0))- SUM(DECODE(TRAN_DB_CR_FLG,'
--            || CHR (39)
--            || 'D'
--            || CHR (39)
--            || ',TRAN_AMOUNT,0)))
--                 as tranbalance from TRAN'
--            || W_FINYEAR
--            || ' where TRAN_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND
--
--                 Tran_Value_date >=                                                                        :1
--                 AND Tran_value_date <=                                                                    :2
--                 AND TRAN_INTERNAL_ACNUM =                                                                 :3
--                 AND TRAN_DATE_OF_TRAN <=                                                                  :4
--                 AND TRAN_AUTH_ON is not null';
--      END IF;
--
--      OPEN RC_TRANBAL FOR W_SQL
--         USING W_FROM_DATE, VALUE_DATE,
--               V_ACNTS_INTERNAL_ACNUM,
--               P_CURRENT_DATE;
--
--      FETCH RC_TRANBAL INTO V_TRANBALANCE;
--
--      IF RC_TRANBAL%FOUND
--      THEN
--         TBAL := NVL (TBAL, 0) + NVL (V_TRANBALANCE, 0);
--      END IF;
--
--      CLOSE RC_TRANBAL;

      RETURN NVL (TBAL, 0);
      
   END GET_TRANBAL;

   FUNCTION GET_BALANCE (W_PROC_DATE IN DATE, PREVNEW IN CHAR)
      RETURN NUMBER
   IS
      RC_ACNTVDB                 RC;
      V_ACNTVBBAL_AC_OP_CR_SUM   NUMBER (18, 3);
      V_ACNTVBBAL_AC_OP_DB_SUM   NUMBER (18, 3);
      OPBAL                      NUMBER (18, 3);
      TRANBAL                    NUMBER (18, 3);
      W_ACNT_YEAR                NUMBER (4);
      W_ACNT_MONTH               NUMBER (2);
   BEGIN
      W_ACNT_YEAR :=
         SP_GETFINYEAR (V_GLOB_ENTITY_NUM, W_PROC_DATE);
      W_ACNT_MONTH := TO_NUMBER (TO_CHAR (W_PROC_DATE, 'MM'));
      W_SQL := 'SELECT ACNTVBBAL_AC_OPNG_CR_SUM,ACNTVBBAL_AC_OPNG_DB_SUM FROM ACNTVDBBAL
                 WHERE ACNTVBBAL_ENTITY_NUM = :ENTITY_NUM
                 AND  ACNTVBBAL_INTERNAL_ACNUM =:1
                AND ACNTVBBAL_CURR_CODE=:2
                AND ACNTVBBAL_YEAR =:3
                AND ACNTVBBAL_MONTH =:4';

      OPEN RC_ACNTVDB FOR W_SQL
         USING V_GLOB_ENTITY_NUM, V_ACNTS_INTERNAL_ACNUM,
               V_ACNTS_AC_CURR_CODE,
               W_ACNT_YEAR,
               W_ACNT_MONTH;

      FETCH RC_ACNTVDB
      INTO V_ACNTVBBAL_AC_OP_CR_SUM, V_ACNTVBBAL_AC_OP_DB_SUM;

      IF RC_ACNTVDB%FOUND
      THEN
         OPBAL :=NVL (V_ACNTVBBAL_AC_OP_CR_SUM, 0)- NVL (V_ACNTVBBAL_AC_OP_DB_SUM, 0);

         IF TRIM (PREVNEW) = 'P'
         THEN
            IF W_PROC_DATE < W_SCAN_FROM_DATE
            THEN
               IF    TO_NUMBER (TO_CHAR (P_CURRENT_DATE, 'MM')) <>
                        TO_NUMBER (TO_CHAR (W_EARLY_VALUE_DATE, 'MM'))
                  OR TO_NUMBER (
                        SP_GETFINYEAR (V_GLOB_ENTITY_NUM,
                                       P_CURRENT_DATE)) <>
                        TO_NUMBER (
                           SP_GETFINYEAR (V_GLOB_ENTITY_NUM,
                                          W_EARLY_VALUE_DATE))
               THEN
                  OPBAL :=OPBAL-NVL(GET_VALUE_DATE_PREV_MONTH (W_PROC_DATE), 0);
               END IF;
            END IF;
         END IF;
      END IF;

      TRANBAL := GET_TRANBAL (W_PROC_DATE, PREVNEW);

      RETURN NVL (OPBAL, 0) + NVL (TRANBAL, 0);
   END GET_BALANCE;

   FUNCTION GET_SLAB_INT_RATES (W_BALANCE       IN NUMBER,
                                DRCR            IN CHAR,
                                EFFDATE         IN DATE,
                                W_INT_BASIS     IN NUMBER,
                                W_SLAB_CHOICE   IN CHAR)
      RETURN NUMBER
   IS
      RC_ACNTIRSL            RC;
      W_BREAK_BALANCE        NUMBER;
      W_PREV_SLAB_AMOUNT     NUMBER;
      V_UPTOAMT              ACNTIRSLAB.ACNTIRS_UPTO_AMOUNT%TYPE;
      V_SLAB_DIFF_INT_RATE   ACNTIRSLAB.ACNTIRS_INT_RATE%TYPE;
   BEGIN
      W_INTEREST_AMOUNT := 0;
      W_PREV_SLAB_AMOUNT := 0;
      W_BREAK_BALANCE := W_BALANCE;
      W_SQL :=
            'SELECT ACNTIRSH_UPTO_AMOUNT,ACNTIRSH_INT_RATE FROM acntirslabHIST 
              WHERE  ACNTIRSH_ENTITY_NUM =:1 
               AND ACNTIRSH_INTERNAL_ACNUM =:2 
               AND ACNTIRSH_INT_DB_CR_FLG =:3 
               AND ACNTIRSH_EFF_DATE  =:4
               ORDER BY ACNTIRSH_DTL_SL';

      OPEN RC_ACNTIRSL FOR W_SQL USING V_GLOB_ENTITY_NUM,V_ACNTS_INTERNAL_ACNUM, DRCR,EFFDATE ;

      LOOP
         FETCH RC_ACNTIRSL
         INTO V_UPTOAMT, V_SLAB_DIFF_INT_RATE;

         EXIT WHEN RC_ACNTIRSL%NOTFOUND;

         IF TRIM (W_SLAB_CHOICE) = 'S'
         THEN
            IF (V_UPTOAMT > W_BALANCE) OR (V_UPTOAMT = 0)
            THEN
               W_INTEREST_AMOUNT :=
                  (  (W_BALANCE * (V_SLAB_DIFF_INT_RATE) * 1)
                   / (W_INT_BASIS * 100.00));
               RETURN V_SLAB_DIFF_INT_RATE;
            END IF;
         ELSE
            IF V_UPTOAMT = 0
            THEN
               W_INTEREST_AMOUNT :=
                    W_INTEREST_AMOUNT
                  + (  (W_BREAK_BALANCE * (V_SLAB_DIFF_INT_RATE) * 1)
                     / (W_INT_BASIS * 100.00));
               RETURN V_SLAB_DIFF_INT_RATE;
            ELSIF V_UPTOAMT > W_BALANCE
            THEN
               W_INTEREST_AMOUNT :=
                    W_INTEREST_AMOUNT
                  + (  (W_BREAK_BALANCE * (V_SLAB_DIFF_INT_RATE) * 1)
                     / (W_INT_BASIS * 100.00));
               RETURN V_SLAB_DIFF_INT_RATE;
            ELSE
               W_INTEREST_AMOUNT :=
                    W_INTEREST_AMOUNT
                  + (  (  (V_UPTOAMT - W_PREV_SLAB_AMOUNT)
                        * (V_SLAB_DIFF_INT_RATE)
                        * 1)
                     / (W_INT_BASIS * 100.00));
               W_BREAK_BALANCE := W_BALANCE - V_UPTOAMT;
               W_PREV_SLAB_AMOUNT := V_UPTOAMT;
            END IF;
         END IF;
      END LOOP;

      RETURN 0;
   END GET_SLAB_INT_RATES;

   --Check in Account Type starts here
   PROCEDURE CHECK_IN_AC_TYPE (W_ACTUAL_BALANCE   IN NUMBER,
                               W_BALANCE          IN NUMBER,
                               DRCR_FLAG          IN CHAR,
                               VDATE              IN DATE,
                               W_INT_BASIS        IN NUMBER)
   IS
      RC_ACNTIR                    RC;
      V_ACNTIR_AC_LEVEL_INT_RATE   CHAR (1);
      V_ACNTIR_INT_RATE            NUMBER (7, 5);
      V_ACNTIR_SLAB_REQ            CHAR (1);
      V_ACNTIR_SLAB_CHOICE         CHAR (1);
      V_ACNTIR_EFF_DATE            DATE;
   BEGIN
      W_TOT_INT_RATE := 0;


      IF VDATE = P_CURRENT_DATE AND NVL (P_ACNT_NUMBER, 0) = 0
      THEN
         W_SQL :=
            'select ACNTIR_LATEST_EFF_DATE, ACNTIR_AC_LEVEL_INT_RATE,ACNTIR_INT_RATE, ACNTIR_SLAB_REQ,ACNTIR_SLAB_CHOICE  FROM ACNTIR where ACNTIR_ENTITY_NUM = :1 AND  ACNTIR_INTERNAL_ACNUM = :2
                and ACNTIR_INT_DB_CR_FLG = :2';

         OPEN RC_ACNTIR FOR W_SQL
            USING V_GLOB_ENTITY_NUM, V_ACNTS_INTERNAL_ACNUM, TRIM (DRCR_FLAG);
      ELSE
         W_SQL :=
            'select ACNTIRH_EFF_DATE,ACNTIRH_AC_LEVEL_INT_RATE,ACNTIRH_INT_RATE,ACNTIRH_SLAB_REQ,ACNTIRH_SLAB_CHOICE from ACNTIRHIST where ACNTIRH_ENTITY_NUM = :1 AND  ACNTIRH_INTERNAL_ACNUM = :2
                  and ACNTIRH_INT_DB_CR_FLG = :3 and ACNTIRH_EFF_DATE = (select max(ACNTIRH_EFF_DATE)
                 from ACNTIRHIST where ACNTIRH_ENTITY_NUM =:4 AND  ACNTIRH_INTERNAL_ACNUM = :5 and ACNTIRH_INT_DB_CR_FLG = :6 and ACNTIRH_EFF_DATE <= :7)';

         OPEN RC_ACNTIR FOR W_SQL
            USING V_GLOB_ENTITY_NUM,
                    V_ACNTS_INTERNAL_ACNUM,
                  TRIM (DRCR_FLAG),
                  V_GLOB_ENTITY_NUM,
                  V_ACNTS_INTERNAL_ACNUM,
                  TRIM (DRCR_FLAG),
                  VDATE;
      END IF;

      FETCH RC_ACNTIR
      INTO V_ACNTIR_EFF_DATE,
           V_ACNTIR_AC_LEVEL_INT_RATE,
           V_ACNTIR_INT_RATE,
           V_ACNTIR_SLAB_REQ,
           V_ACNTIR_SLAB_CHOICE;

      IF RC_ACNTIR%FOUND
      THEN
         IF V_ACNTIR_AC_LEVEL_INT_RATE = '1'
         THEN
            W_PRESENT_ACNT_WISE := '1';
         END IF;
      END IF;

      IF W_PRESENT_ACNT_WISE = '1'
      THEN
         W_TOT_INT_RATE := V_ACNTIR_INT_RATE;
      END IF;

      IF NVL (V_ACNTIR_SLAB_REQ, '0') = '1'
      THEN
         W_TOT_INT_RATE :=
            GET_SLAB_INT_RATES (W_ACTUAL_BALANCE,
                                DRCR_FLAG,
                                V_ACNTIR_EFF_DATE,
                                W_INT_BASIS,
                                V_ACNTIR_SLAB_CHOICE);
      ELSE
         IF W_TOT_INT_RATE <> 0
         THEN
            W_INTEREST_AMOUNT :=
               (W_ACTUAL_BALANCE * W_TOT_INT_RATE * 1) / (W_INT_BASIS * 100);
         END IF;
      END IF;

      CLOSE RC_ACNTIR;
   END CHECK_IN_AC_TYPE;

   --Check in Account Type ends here

   FUNCTION READ_PRODIRHIST (P_PRODUCT_CODE         IN VARCHAR2,
                             P_ACNTS_AC_CURR_CODE   IN VARCHAR2,
                             P_ACNTS_AC_TYPE        IN VARCHAR2,
                             P_ACNTS_AC_SUB_TYPE    IN NUMBER,
                             P_DRCR                 IN VARCHAR2,
                             P_VDATE                IN DATE)
      RETURN NUMBER
   IS
      V_INTEREST_RATE   NUMBER (7, 5);
   BEGIN
      PP_PRODUCT_CODE := P_PRODUCT_CODE;
      PP_ACNTS_AC_CURR_CODE := P_ACNTS_AC_CURR_CODE;
      PP_ACNTS_AC_TYPE := P_ACNTS_AC_TYPE;
      PP_ACNTS_AC_SUB_TYPE := P_ACNTS_AC_SUB_TYPE;
      PP_DRCR := P_DRCR;

      W_GOBACK_TO_GLOBAL := 0;
      V_INTEREST_RATE := 0;

     <<READPRODIR>>
      BEGIN
         W_PRODIR_RATE_AVL := FALSE;

         SELECT PRODIRH_EFF_DATE,
                PRODIRH_INT_RATE,
                PRODIRH_GOBACK_GLOBAL_INT,
                NVL (PRODIRH_SLAB_REQ, 0),
                NVL (PRODIRH_SLAB_CHOICE, 0)
           INTO PP_VDATE,
                V_INTEREST_RATE,
                W_GOBACK_TO_GLOBAL,
                W_SLAB_WISE_REQ,
                W_SLAB_CHOICE
           FROM PRODIRHIST
          WHERE     PRODIRH_ENTITY_NUM = V_GLOB_ENTITY_NUM
                AND PRODIRH_PROD_CODE = P_PRODUCT_CODE
                AND PRODIRH_CURR_CODE = P_ACNTS_AC_CURR_CODE
                AND PRODIRH_AC_TYPE = P_ACNTS_AC_TYPE
                AND PRODIRH_ACSUB_TYPE = P_ACNTS_AC_SUB_TYPE
                AND PRODIRH_INT_DB_CR_FLG = P_DRCR
                AND PRODIRH_BRANCH_CAT = V_BRN_CAT
                AND PRODIRH_EFF_DATE =
                       (SELECT MAX (PRODIRH_EFF_DATE)
                          FROM PRODIRHIST
                         WHERE     PRODIRH_ENTITY_NUM =
                                      V_GLOB_ENTITY_NUM
                               AND PRODIRH_PROD_CODE = P_PRODUCT_CODE
                               AND PRODIRH_CURR_CODE = P_ACNTS_AC_CURR_CODE
                               AND PRODIRH_AC_TYPE = P_ACNTS_AC_TYPE
                               AND PRODIRH_ACSUB_TYPE = P_ACNTS_AC_SUB_TYPE
                               AND PRODIRH_INT_DB_CR_FLG = P_DRCR
                               AND PRODIRH_BRANCH_CAT = V_BRN_CAT
                               AND PRODIRH_EFF_DATE <= P_VDATE);

         IF SQL%FOUND
         THEN
            W_PRODIR_RATE_AVL := TRUE;
         ELSE
            W_PRODIR_RATE_AVL := FALSE;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            V_INTEREST_RATE := 0;
            W_PRODIR_RATE_AVL := FALSE;
      END READPRODIR;

      RETURN NVL (V_INTEREST_RATE, 0);
   END READ_PRODIRHIST;

   FUNCTION GET_MAX_DATE_PRODIR_RATE (DRCR IN CHAR, VDATE IN DATE)
      RETURN NUMBER
   IS
      W_INTEREST_RATE   NUMBER (7, 5);
   BEGIN
      W_INTEREST_RATE := 0;
      W_PRODIR_RATE_AVL := FALSE;

      W_INTEREST_RATE :=
         READ_PRODIRHIST (V_PRODUCT_CODE,
                          V_ACNTS_AC_CURR_CODE,
                          V_ACNTS_AC_TYPE,
                          V_ACNTS_AC_SUB_TYPE,
                          TRIM (DRCR),
                          VDATE);

      IF W_PRODIR_RATE_AVL = FALSE
      THEN
         W_ACCOUNT_STYPE_FOUND := 0;
         W_INTEREST_RATE :=
            READ_PRODIRHIST (V_PRODUCT_CODE,
                             V_ACNTS_AC_CURR_CODE,
                             V_ACNTS_AC_TYPE,
                             W_ACCOUNT_STYPE_FOUND,
                             TRIM (DRCR),
                             VDATE);

         IF W_PRODIR_RATE_AVL = FALSE
         THEN
            W_ACCOUNT_TYPE_FOUND := W_SPACE;
            W_INTEREST_RATE :=
               READ_PRODIRHIST (V_PRODUCT_CODE,
                                V_ACNTS_AC_CURR_CODE,
                                W_ACCOUNT_TYPE_FOUND,
                                W_ACCOUNT_STYPE_FOUND,
                                TRIM (DRCR),
                                VDATE);
         END IF;
      END IF;

      IF W_GOBACK_TO_GLOBAL = 1
      THEN
         W_ACCOUNT_STYPE_FOUND := 0;
         W_ACCOUNT_TYPE_FOUND := ' ';
         W_INTEREST_RATE :=
            READ_PRODIRHIST (V_PRODUCT_CODE,
                             V_ACNTS_AC_CURR_CODE,
                             W_ACCOUNT_TYPE_FOUND,
                             W_ACCOUNT_STYPE_FOUND,
                             TRIM (DRCR),
                             VDATE);
      END IF;

      RETURN W_INTEREST_RATE;
   END GET_MAX_DATE_PRODIR_RATE;

   FUNCTION GET_SLAB_RATE_FOR_PROD (W_BALANCE       IN NUMBER,
                                    DRCR            IN CHAR,
                                    EFFDATE         IN DATE,
                                    W_INT_BASIS     IN NUMBER,
                                    W_SLAB_CHOICE   IN CHAR)
      RETURN NUMBER
   IS
      RC_PRODIRSL                RC;
      W_BREAK_BALANCE            NUMBER;
      W_PREV_SLAB_AMOUNT         NUMBER;
      V_PRODIRSL_UPTO_AMOUNT     PRODIRSLAB.PRODIRS_UPTO_AMOUNT%TYPE;
      V_PRODIRSL_SLAB_INT_RATE   PRODIRSLAB.PRODIRS_INT_RATE%TYPE;
   BEGIN
      W_BREAK_BALANCE := W_BALANCE;
      W_INTEREST_AMOUNT := 0;
      W_PREV_SLAB_AMOUNT := 0;


      W_SQL := 'Select PRODIRSH_UPTO_AMOUNT,PRODIRSH_INT_RATE from  PRODIRSLABHIST where
                     PRODIRSH_ENTITY_NUM=:ENTITY_NUM
                     AND PRODIRSH_PROD_CODE = :PRODUCT_CODE
                     AND PRODIRSH_CURR_CODE  = :ACNTS_AC_CURR_CODE
                     AND PRODIRSH_AC_TYPE  =:ACNTS_AC_TYPE
                     AND PRODIRSH_ACSUB_TYPE   =:ACNTS_AC_SUB_TYPE
                     AND PRODIRSH_INT_DB_CR_FLG =:DRCR
                     AND PRODIRSH_BRANCH_CAT =:BRN_CAT
                     AND PRODIRSH_EFF_DATE =:VDATE 
                     ORDER BY PRODIRSH_DTL_SL';


      OPEN RC_PRODIRSL FOR W_SQL USING V_GLOB_ENTITY_NUM, PP_PRODUCT_CODE,PP_ACNTS_AC_CURR_CODE,PP_ACNTS_AC_TYPE,PP_ACNTS_AC_SUB_TYPE,PP_DRCR,V_BRN_CAT,PP_VDATE;

      LOOP
         FETCH RC_PRODIRSL
         INTO V_PRODIRSL_UPTO_AMOUNT, V_PRODIRSL_SLAB_INT_RATE;

         EXIT WHEN RC_PRODIRSL%NOTFOUND;

         IF TRIM (W_SLAB_CHOICE) = 'S'
         THEN
            IF    (V_PRODIRSL_UPTO_AMOUNT > W_BALANCE)
               OR (V_PRODIRSL_UPTO_AMOUNT = 0)
            THEN
               W_INTEREST_AMOUNT :=
                  (  (W_BALANCE * (V_PRODIRSL_SLAB_INT_RATE) * 1)
                   / --29-12-2010-REM                                       (1200.00));
                     (W_INT_BASIS * 100.00));
               RETURN V_PRODIRSL_SLAB_INT_RATE;
            END IF;
         ELSE
            IF V_PRODIRSL_UPTO_AMOUNT = 0
            THEN
               W_INTEREST_AMOUNT :=
                    W_INTEREST_AMOUNT
                  + (  (W_BREAK_BALANCE * (V_PRODIRSL_SLAB_INT_RATE) * 1)
                     / (W_INT_BASIS * 100.00));
               RETURN V_PRODIRSL_SLAB_INT_RATE;
            ELSIF V_PRODIRSL_UPTO_AMOUNT >= W_BALANCE
            THEN
               W_INTEREST_AMOUNT :=
                    W_INTEREST_AMOUNT
                  + (  (W_BREAK_BALANCE * (V_PRODIRSL_SLAB_INT_RATE) * 1)
                     / (W_INT_BASIS * 100.00));
               RETURN V_PRODIRSL_SLAB_INT_RATE;
            ELSE
               W_INTEREST_AMOUNT :=
                    W_INTEREST_AMOUNT
                  + (  (  (V_PRODIRSL_UPTO_AMOUNT - W_PREV_SLAB_AMOUNT)
                        * (V_PRODIRSL_SLAB_INT_RATE)
                        * 1)
                     / (W_INT_BASIS * 100.00));
               W_BREAK_BALANCE := W_BALANCE - V_PRODIRSL_UPTO_AMOUNT;
               W_PREV_SLAB_AMOUNT := V_PRODIRSL_UPTO_AMOUNT;
            END IF;
         END IF;
      END LOOP;

      RETURN 0;
   END GET_SLAB_RATE_FOR_PROD;

   PROCEDURE GET_INT_RATE_PRODWISE (W_BALANCE     IN NUMBER,
                                    DRCR_FLAG     IN CHAR,
                                    VDATE         IN DATE,
                                    W_INT_BASIS   IN NUMBER)
   IS
      RC_PRODWISE         RC;
      V_PRODIR_INT_RATE   NUMBER (7, 5);
      W_GOBACK_GLOBAL     NUMBER (1);
   BEGIN
      V_MAX_PRODIR_DATE := NULL;
      W_ACCOUNT_TYPE_FOUND := '';
      W_ACCOUNT_STYPE_FOUND := 0;
      W_GOBACK_GLOBAL := 0;
      W_PRODIR_RATE_AVL := FALSE;
      W_SLAB_CHOICE := '';
      W_SLAB_WISE_REQ := '';

      --14-11-2007-REM          IF VDATE = P_CURRENT_DATE THEN
      IF VDATE = P_CURRENT_DATE AND NVL (P_ACNT_NUMBER, 0) = 0
      THEN
         IF DRCR_FLAG = 'C'
         THEN
            IF V_SB_PROD_INT_RATE.EXISTS (V_PRODIR_STRING_CR) = TRUE
            THEN
               W_PRODIR_RATE_AVL := TRUE;
               V_PRODIR_INT_RATE :=
                  TO_NUMBER (
                     SUBSTR (TRIM (V_SB_PROD_INT_RATE (V_PRODIR_STRING_CR)),
                             1,
                             9));
               W_GOBACK_GLOBAL :=
                  TO_NUMBER (
                     SUBSTR (TRIM (V_SB_PROD_INT_RATE (V_PRODIR_STRING_CR)),
                             10,
                             1));
               --15-08-2010-beg
               W_SLAB_WISE_REQ :=
                  TO_NUMBER (
                     SUBSTR (TRIM (V_SB_PROD_INT_RATE (V_PRODIR_STRING_CR)),
                             11,
                             1));
               -- NEELS-MDS-08-DEC-2010 BEG
               /*                           W_SLAB_CHOICE   := TO_NUMBER(SUBSTR(TRIM(V_SB_PROD_INT_RATE(V_PRODIR_STRING_CR)),
                                                                                12,
                                                                                1)); */
               W_SLAB_CHOICE :=
                  SUBSTR (TRIM (V_SB_PROD_INT_RATE (V_PRODIR_STRING_CR)),
                          12,
                          1);


               IF W_GOBACK_GLOBAL = '1'
               THEN
                  W_PRODIR_RATE_AVL := FALSE;
                  V_PRODIR_INT_RATE := 0;

                  IF V_SB_PROD_INT_RATE.EXISTS (V_PRODIR_ACTYPE_SPACE_CR) =
                        TRUE
                  THEN
                     W_PRODIR_RATE_AVL := TRUE;
                     V_PRODIR_INT_RATE :=
                        TO_NUMBER (
                           SUBSTR (
                              TRIM (
                                 V_SB_PROD_INT_RATE (
                                    V_PRODIR_ACTYPE_SPACE_CR)),
                              1,
                              9));

                     W_SLAB_WISE_REQ :=
                        TO_NUMBER (
                           SUBSTR (
                              TRIM (
                                 V_SB_PROD_INT_RATE (
                                    V_PRODIR_ACTYPE_SPACE_CR)),
                              11,
                              1));

                     W_SLAB_CHOICE :=
                        SUBSTR (
                           TRIM (
                              V_SB_PROD_INT_RATE (V_PRODIR_ACTYPE_SPACE_CR)),
                           12,
                           1);
                  END IF;
               END IF;
            ELSIF V_SB_PROD_INT_RATE.EXISTS (V_PRODIR_ACSTYPE_SPACE_CR) =
                     TRUE
            THEN
               W_PRODIR_RATE_AVL := TRUE;
               V_PRODIR_INT_RATE :=
                  TO_NUMBER (
                     SUBSTR (
                        TRIM (V_SB_PROD_INT_RATE (V_PRODIR_ACSTYPE_SPACE_CR)),
                        1,
                        9));
               W_GOBACK_GLOBAL :=
                  TO_NUMBER (
                     SUBSTR (
                        TRIM (V_SB_PROD_INT_RATE (V_PRODIR_ACSTYPE_SPACE_CR)),
                        10,
                        1));
               --15-08-2010-beg
               W_SLAB_WISE_REQ :=
                  TO_NUMBER (
                     SUBSTR (
                        TRIM (V_SB_PROD_INT_RATE (V_PRODIR_ACSTYPE_SPACE_CR)),
                        11,
                        1));
               -- NEELS-MDS-08-DEC-2010 BEG
               /*                           W_SLAB_CHOICE   := TO_NUMBER(SUBSTR(TRIM(V_SB_PROD_INT_RATE(V_PRODIR_ACSTYPE_SPACE_CR)),
                                                                                12,
                                                                                1)); */
               W_SLAB_CHOICE :=
                  SUBSTR (
                     TRIM (V_SB_PROD_INT_RATE (V_PRODIR_ACSTYPE_SPACE_CR)),
                     12,
                     1);

               -- NEELS-MDS-08-DEC-2010 END
               --15-08-2010-end

               IF W_GOBACK_GLOBAL = '1'
               THEN
                  W_PRODIR_RATE_AVL := FALSE;
                  V_PRODIR_INT_RATE := 0;

                  IF V_SB_PROD_INT_RATE.EXISTS (V_PRODIR_ACTYPE_SPACE_CR) =
                        TRUE
                  THEN
                     W_PRODIR_RATE_AVL := TRUE;
                     V_PRODIR_INT_RATE :=
                        TO_NUMBER (
                           SUBSTR (
                              TRIM (
                                 V_SB_PROD_INT_RATE (
                                    V_PRODIR_ACTYPE_SPACE_CR)),
                              1,
                              9));
                     --15-08-2010-beg
                     W_SLAB_WISE_REQ :=
                        TO_NUMBER (
                           SUBSTR (
                              TRIM (
                                 V_SB_PROD_INT_RATE (
                                    V_PRODIR_ACTYPE_SPACE_CR)),
                              11,
                              1));
                     -- NEELS-MDS-08-DEC-2010 BEG
                     /*                           W_SLAB_CHOICE   := TO_NUMBER(SUBSTR(TRIM(V_SB_PROD_INT_RATE(V_PRODIR_ACTYPE_SPACE_CR)),
                                                                                      12,
                                                                                      1)); */
                     W_SLAB_CHOICE :=
                        SUBSTR (
                           TRIM (
                              V_SB_PROD_INT_RATE (V_PRODIR_ACTYPE_SPACE_CR)),
                           12,
                           1);
                  -- NEELS-MDS-08-DEC-2010 END
                  --15-08-2010-end
                  END IF;
               END IF;
            ELSIF V_SB_PROD_INT_RATE.EXISTS (V_PRODIR_ACTYPE_SPACE_CR) = TRUE
            THEN
               W_PRODIR_RATE_AVL := TRUE;
               V_PRODIR_INT_RATE :=
                  TO_NUMBER (
                     SUBSTR (
                        TRIM (V_SB_PROD_INT_RATE (V_PRODIR_ACTYPE_SPACE_CR)),
                        1,
                        9));
               W_GOBACK_GLOBAL :=
                  TO_NUMBER (
                     SUBSTR (
                        TRIM (V_SB_PROD_INT_RATE (V_PRODIR_ACTYPE_SPACE_CR)),
                        10,
                        1));
               --15-08-2010-beg
               W_SLAB_WISE_REQ :=
                  TO_NUMBER (
                     SUBSTR (
                        TRIM (V_SB_PROD_INT_RATE (V_PRODIR_ACTYPE_SPACE_CR)),
                        11,
                        1));
               -- NEELS-MDS-08-DEC-2010 BEG
               /*                           W_SLAB_CHOICE   := TO_NUMBER(SUBSTR(TRIM(V_SB_PROD_INT_RATE(V_PRODIR_ACTYPE_SPACE_CR)),
                                                                                12,
                                                                                1)); */
               W_SLAB_CHOICE :=
                  SUBSTR (
                     TRIM (V_SB_PROD_INT_RATE (V_PRODIR_ACTYPE_SPACE_CR)),
                     12,
                     1);
            -- NEELS-MDS-08-DEC-2010 END
            --15-08-2010-end
            ELSE
               V_PRODIR_INT_RATE := 0;
            END IF;
         ELSE
            IF V_SB_PROD_INT_RATE.EXISTS (V_PRODIR_STRING_DB) = TRUE
            THEN
               W_PRODIR_RATE_AVL := TRUE;
               V_PRODIR_INT_RATE :=
                  TO_NUMBER (
                     SUBSTR (TRIM (V_SB_PROD_INT_RATE (V_PRODIR_STRING_DB)),
                             1,
                             9));
               W_GOBACK_GLOBAL :=
                  TO_NUMBER (
                     SUBSTR (TRIM (V_SB_PROD_INT_RATE (V_PRODIR_STRING_DB)),
                             10,
                             1));
               --15-08-2010-beg
               W_SLAB_WISE_REQ :=
                  TO_NUMBER (
                     SUBSTR (TRIM (V_SB_PROD_INT_RATE (V_PRODIR_STRING_DB)),
                             11,
                             1));
               -- NEELS-MDS-08-DEC-2010 BEG
               /*                           W_SLAB_CHOICE   := TO_NUMBER(SUBSTR(TRIM(V_SB_PROD_INT_RATE(V_PRODIR_STRING_DB)),
                                                                                12,
                                                                                1)); */
               W_SLAB_CHOICE :=
                  SUBSTR (TRIM (V_SB_PROD_INT_RATE (V_PRODIR_STRING_DB)),
                          12,
                          1);

               -- NEELS-MDS-08-DEC-2010 END
               --15-08-2010-end

               IF W_GOBACK_GLOBAL = '1'
               THEN
                  W_PRODIR_RATE_AVL := FALSE;
                  V_PRODIR_INT_RATE := 0;

                  IF V_SB_PROD_INT_RATE.EXISTS (V_PRODIR_ACTYPE_SPACE_DB) =
                        TRUE
                  THEN
                     W_PRODIR_RATE_AVL := TRUE;
                     V_PRODIR_INT_RATE :=
                        TO_NUMBER (
                           SUBSTR (
                              TRIM (
                                 V_SB_PROD_INT_RATE (
                                    V_PRODIR_ACTYPE_SPACE_DB)),
                              1,
                              9));
                     --15-08-2010-beg
                     W_SLAB_WISE_REQ :=
                        TO_NUMBER (
                           SUBSTR (
                              TRIM (
                                 V_SB_PROD_INT_RATE (
                                    V_PRODIR_ACTYPE_SPACE_DB)),
                              11,
                              1));
                     -- NEELS-MDS-08-DEC-2010 BEG
                     /*                                     W_SLAB_CHOICE   := TO_NUMBER(SUBSTR(TRIM(V_SB_PROD_INT_RATE(V_PRODIR_ACTYPE_SPACE_DB)),
                                                                                                12,
                                                                                                1)); */
                     W_SLAB_CHOICE :=
                        SUBSTR (
                           TRIM (
                              V_SB_PROD_INT_RATE (V_PRODIR_ACTYPE_SPACE_DB)),
                           12,
                           1);
                  -- NEELS-MDS-08-DEC-2010 END
                  --15-08-2010-end
                  END IF;
               END IF;
            ELSIF V_SB_PROD_INT_RATE.EXISTS (V_PRODIR_ACSTYPE_SPACE_DB) =
                     TRUE
            THEN
               W_PRODIR_RATE_AVL := TRUE;
               V_PRODIR_INT_RATE :=
                  TO_NUMBER (
                     SUBSTR (
                        TRIM (V_SB_PROD_INT_RATE (V_PRODIR_ACSTYPE_SPACE_DB)),
                        1,
                        9));
               W_GOBACK_GLOBAL :=
                  TO_NUMBER (
                     SUBSTR (
                        TRIM (V_SB_PROD_INT_RATE (V_PRODIR_ACSTYPE_SPACE_DB)),
                        10,
                        1));
               --15-08-2010-beg
               W_SLAB_WISE_REQ :=
                  TO_NUMBER (
                     SUBSTR (
                        TRIM (V_SB_PROD_INT_RATE (V_PRODIR_ACSTYPE_SPACE_DB)),
                        11,
                        1));
               -- NEELS-MDS-08-DEC-2010 BEG
               /*                           W_SLAB_CHOICE   := TO_NUMBER(SUBSTR(TRIM(V_SB_PROD_INT_RATE(V_PRODIR_ACSTYPE_SPACE_DB)),
                                                                                12,
                                                                                1)); */
               W_SLAB_CHOICE :=
                  SUBSTR (
                     TRIM (V_SB_PROD_INT_RATE (V_PRODIR_ACSTYPE_SPACE_DB)),
                     12,
                     1);

               -- NEELS-MDS-08-DEC-2010 END
               --15-08-2010-end
               IF W_GOBACK_GLOBAL = '1'
               THEN
                  W_PRODIR_RATE_AVL := FALSE;
                  V_PRODIR_INT_RATE := 0;

                  IF V_SB_PROD_INT_RATE.EXISTS (V_PRODIR_ACTYPE_SPACE_DB) =
                        TRUE
                  THEN
                     W_PRODIR_RATE_AVL := TRUE;
                     V_PRODIR_INT_RATE :=
                        TO_NUMBER (
                           SUBSTR (
                              TRIM (
                                 V_SB_PROD_INT_RATE (
                                    V_PRODIR_ACTYPE_SPACE_DB)),
                              1,
                              9));

                     W_SLAB_WISE_REQ :=
                        TO_NUMBER (
                           SUBSTR (
                              TRIM (
                                 V_SB_PROD_INT_RATE (
                                    V_PRODIR_ACTYPE_SPACE_DB)),
                              11,
                              1));

                     W_SLAB_CHOICE :=
                        SUBSTR (
                           TRIM (
                              V_SB_PROD_INT_RATE (V_PRODIR_ACTYPE_SPACE_DB)),
                           12,
                           1);
                  END IF;
               END IF;
            ELSIF V_SB_PROD_INT_RATE.EXISTS (V_PRODIR_ACTYPE_SPACE_DB) = TRUE
            THEN
               W_PRODIR_RATE_AVL := TRUE;
               V_PRODIR_INT_RATE :=
                  TO_NUMBER (
                     SUBSTR (
                        TRIM (V_SB_PROD_INT_RATE (V_PRODIR_ACTYPE_SPACE_DB)),
                        1,
                        9));
               W_GOBACK_GLOBAL :=
                  TO_NUMBER (
                     SUBSTR (
                        TRIM (V_SB_PROD_INT_RATE (V_PRODIR_ACTYPE_SPACE_DB)),
                        10,
                        1));

               W_SLAB_WISE_REQ :=
                  TO_NUMBER (
                     SUBSTR (
                        TRIM (V_SB_PROD_INT_RATE (V_PRODIR_ACTYPE_SPACE_DB)),
                        11,
                        1));

               W_SLAB_CHOICE :=
                  SUBSTR (
                     TRIM (V_SB_PROD_INT_RATE (V_PRODIR_ACTYPE_SPACE_DB)),
                     12,
                     1);
            ELSE
               V_PRODIR_INT_RATE := 0;
            END IF;
         END IF;

         IF NVL (W_SLAB_WISE_REQ, 0) = '1'
         THEN
            V_PRODIR_INT_RATE :=
               GET_MAX_DATE_PRODIR_RATE (TRIM (DRCR_FLAG), VDATE);
         END IF;

         W_TOT_INT_RATE := V_PRODIR_INT_RATE;
      ELSE
         V_PRODIR_INT_RATE :=
            GET_MAX_DATE_PRODIR_RATE (TRIM (DRCR_FLAG), VDATE);
         W_TOT_INT_RATE := V_PRODIR_INT_RATE;
      END IF;

      IF W_SLAB_WISE_REQ = '1'
      THEN
         V_PRODIR_INT_RATE :=
            GET_SLAB_RATE_FOR_PROD (ABS (W_BALANCE),
                                    DRCR_FLAG,
                                    VDATE,
                                    W_INT_BASIS,
                                    W_SLAB_CHOICE);
         W_TOT_INT_RATE := V_PRODIR_INT_RATE;
      ELSE
         IF V_PRODIR_INT_RATE <> 0
         THEN
            W_INTEREST_AMOUNT :=
               (W_BALANCE * W_TOT_INT_RATE * 1) / (W_INT_BASIS * 100);
         ELSE
            W_INTEREST_AMOUNT := 0;
         END IF;
      END IF;
   END GET_INT_RATE_PRODWISE;

   FUNCTION GET_INT_AMOUNT (W_ACTUAL_BALANCE   IN NUMBER,
                            W_BALANCE          IN NUMBER,
                            DRCR_FLAG          IN CHAR,
                            VDATE              IN DATE,
                            W_INT_BASIS        IN NUMBER)
      RETURN NUMBER
   IS
   BEGIN
      W_INTEREST_AMOUNT := 0;
      W_BASE_INT_RATE := 0;
      W_TOT_INT_RATE := 0;
      W_PRESENT_ACNT_WISE := '0';
      CHECK_IN_AC_TYPE (ABS (W_ACTUAL_BALANCE),
                        ABS (W_ACTUAL_BALANCE),
                        DRCR_FLAG,
                        VDATE,
                        W_INT_BASIS);

      IF W_PRESENT_ACNT_WISE = '0'
      THEN
         GET_INT_RATE_PRODWISE (ABS (W_ACTUAL_BALANCE),
                                DRCR_FLAG,
                                VDATE,
                                W_INT_BASIS);

         IF W_PRODIR_RATE_AVL = FALSE
         THEN
            RECORD_EXCEPTION (
                  'Interest Rate Not Specified for Prod Code = '
               || V_ACNTS_PROD_CODE
               || '  Curr Code = '
               || V_ACNTS_AC_CURR_CODE
               || ' Ac Type = '
               || V_ACNTS_AC_TYPE
               || ' Sub Type = '
               || V_ACNTS_AC_SUB_TYPE
               || ' Process Date = '
               || VDATE);
            W_SKIP_UPDATION := TRUE;
            RAISE E_SKIPEXCEP;
         END IF;
      END IF;

      IF NVL (W_SLAB_WISE_REQ, 0) = '1'
      THEN
         W_INTEREST_RATE := W_TOT_INT_RATE;
         W_INTEREST_AMOUNT :=
            (W_ACTUAL_BALANCE * W_INTEREST_RATE * 1) / (W_INT_BASIS * 100); --  Added Noor
         RETURN W_INTEREST_AMOUNT;
      ELSE
         IF W_TOT_INT_RATE <= 0
         THEN
            RETURN 0;
         ELSE
            W_INTEREST_RATE := W_TOT_INT_RATE;
            W_INTEREST_AMOUNT :=
               (W_ACTUAL_BALANCE * W_INTEREST_RATE * 1) / (W_INT_BASIS * 100); --  Added Noor
            RETURN W_INTEREST_AMOUNT;
         END IF;
      END IF;
   END GET_INT_AMOUNT;

   PROCEDURE UPDATE_SBCALC_ARRAY
   IS
   BEGIN
      V_SBCACBRK_BREAKUP_DATE (V_COUNT_BRK) := V_BREAK_UP_DATE;
      V_SBCACBRK_PREV_BALANCE (V_COUNT_BRK) := W_PREV_BAL;
      V_SBCACBRK_NEW_BALANCE (V_COUNT_BRK) := W_NEW_BAL;
      V_SBCACBRK_PREV_DB_INT (V_COUNT_BRK) := W_PREV_DB_INT;
      V_SBCACBRK_PREV_CR_INT (V_COUNT_BRK) := W_PREV_CR_INT;
      V_SBCACBRK_NEW_DB_INT (V_COUNT_BRK) := W_NEW_DB_INT;
      V_SBCACBRK_NEW_CR_INT (V_COUNT_BRK) := W_NEW_CR_INT;

      V_SBCACALC_TOT_PREV_DB_INT_AMT (V_COUNT_SB) :=
         V_SBCACALC_TOT_PREV_DB_INT_AMT (V_COUNT_SB) + W_PREV_DB_INT;
      V_SBCACALC_TOT_PREV_CR_INT_AMT (V_COUNT_SB) :=
         V_SBCACALC_TOT_PREV_CR_INT_AMT (V_COUNT_SB) + W_PREV_CR_INT;
      V_SBCACALC_TOT_NEW_DB_INT_AMT (V_COUNT_SB) :=
         V_SBCACALC_TOT_NEW_DB_INT_AMT (V_COUNT_SB) + W_NEW_DB_INT;
      V_SBCACALC_TOT_NEW_CR_INT_AMT (V_COUNT_SB) :=
         V_SBCACALC_TOT_NEW_CR_INT_AMT (V_COUNT_SB) + W_NEW_CR_INT;
      V_SBCACALC_AC_DB_INT_ACCR_AMT (V_COUNT_SB) :=
           V_SBCACALC_AC_DB_INT_ACCR_AMT (V_COUNT_SB)
         + W_NEW_DB_INT
         - W_PREV_DB_INT;
      V_SBCACALC_BC_DB_INT_ACCR_AMT (V_COUNT_SB) := 0;
      V_SBCACALC_AC_CR_INT_ACCR_AMT (V_COUNT_SB) :=
           V_SBCACALC_AC_CR_INT_ACCR_AMT (V_COUNT_SB)
         + W_NEW_CR_INT
         - W_PREV_CR_INT;
      V_SBCACALC_BC_CR_INT_ACCR_AMT (V_COUNT_SB) := 0;
      V_SBCACALC_CR_INT_BC_CRATE (V_COUNT_SB) := 0;
      V_SBCACALC_INT_RATE (V_COUNT_SB) := W_TOT_INT_RATE;
      V_COUNT_BRK := V_COUNT_BRK + 1;
      W_BREAK_UP_ADDED := '1';
   END UPDATE_SBCALC_ARRAY;

   PROCEDURE PROCESS_SBCATEMP_FILE
   IS
    V_SQL                    VARCHAR2(4000);
   BEGIN
      V_SBCATEMP_INTERNAL_ACNUM := V_ACNTS_INTERNAL_ACNUM;
      V_SBCATEMP_VALUE_DATE := W_PROC_DATE;
      V_SBCATEMP_PREV_BALANCE := 0;
      V_SBCATEMP_NEW_BALANCE := 0;
      V_SBCATEMP_PREV_DB_INT := 0;
      V_SBCATEMP_PREV_CR_INT := 0;
      V_SBCATEMP_NEW_DB_INT := 0;
      V_SBCATEMP_NEW_CR_INT := 0;
      W_PREV_DB_INT := 0;
      W_PREV_CR_INT := 0;
      W_NEW_DB_INT := 0;
      W_NEW_CR_INT := 0;

-- GETTING THE BRANCH CATEGORY FOR THE GIVEN ACCOUNT NUMBER AND ENTITY NUMBER ADDED BY RAJIB
        BEGIN
            IF T_BRANCH_CAT.EXISTS(V_BRN_CODE)= TRUE THEN
                 V_BRN_CAT:= T_BRANCH_CAT(V_BRN_CODE).MBRN_CATEGORY;
            ELSE
              BEGIN
                V_SQL:='SELECT M.MBRN_CATEGORY FROM MBRN M WHERE M.MBRN_ENTITY_NUM=:1 AND M.MBRN_CODE =:2';
                  EXECUTE IMMEDIATE V_SQL INTO V_BRN_CAT USING V_GLOB_ENTITY_NUM, V_BRN_CODE;

              T_BRANCH_CAT(V_BRN_CODE).MBRN_CATEGORY:=V_BRN_CAT;
                    EXCEPTION
                        WHEN OTHERS THEN
                        V_BRN_CAT:=' ';
                        T_BRANCH_CAT(V_BRN_CODE).MBRN_CATEGORY:=V_BRN_CAT;
             END;
          END IF;
        END;
--
--      V_BRN_CAT :=
--         FN_GET_BRANCH_CAT (V_SBCATEMP_INTERNAL_ACNUM,
--                            V_GLOB_ENTITY_NUM);

      IF DBINT_BASIS = 0 AND CRINT_BASIS = 0
      THEN
         RETURN;
      END IF;

      IF TRIM (V_ACNTS_INT_FLAG) = '0'
      THEN
         IF W_PREV_BAL > 0
         THEN
            W_PREV_BAL := 0;
         END IF;

         IF W_NEW_BAL > 0
         THEN
            W_NEW_BAL := 0;
         END IF;
      END IF;

      IF W_PREV_BAL <> W_NEW_BAL
      THEN
         W_PRINCIPAL_AMT := ABS (W_PREV_BAL);

         -- Avinash-SONALI-12SEP2012 Begin
         IF W_PRINCIPAL_AMT < V_MINBAL_INT_ELIGIBILITY
         THEN
            W_PREV_BAL := 0;
         END IF;

         -- Avinash-SONALI-12SEP2012 End
         IF W_PREV_BAL < 0
         THEN
            IF TRIM (W_INT_FOR_DBBAL) = '1' AND W_RAPARAM_DBINT_BASIS = 'D'
            THEN
               W_PREV_DB_INT :=
                  GET_INT_AMOUNT (W_PREV_BAL,
                                  P_AVG_BAL,
                                  'D',
                                  V_SBCATEMP_VALUE_DATE,
                                  DBINT_BASIS);
            END IF;
         ELSIF W_PREV_BAL > 0
         THEN
            IF TRIM (W_INT_FOR_CRBAL) = '1' AND W_RAPARAM_CRINT_BASIS = 'D'
            THEN
               W_PREV_CR_INT :=
                  GET_INT_AMOUNT (W_PREV_BAL,
                                  P_AVG_BAL,
                                  'C',
                                  V_SBCATEMP_VALUE_DATE,
                                  CRINT_BASIS);
            END IF;
         END IF;

         IF     TRIM (W_INT_FOR_DBBAL) = '1'
            AND W_TOT_INT_RATE = 0
            AND W_PREV_BAL <> 0
         THEN
            W_UPDATED_IN_TEMP := FALSE;
         END IF;

         W_PRINCIPAL_AMT := ABS (W_NEW_BAL);

         -- Avinash-SONALI-12SEP2012 Begin
         IF W_PRINCIPAL_AMT < V_MINBAL_INT_ELIGIBILITY
         THEN
            W_NEW_BAL := 0;
         END IF;

         -- Avinash-SONALI-12SEP2012 End

         IF W_NEW_BAL < 0
         THEN
            IF TRIM (W_INT_FOR_DBBAL) = '1' AND W_RAPARAM_DBINT_BASIS = 'D'
            THEN
               W_NEW_DB_INT :=
                  GET_INT_AMOUNT (W_NEW_BAL,
                                  P_AVG_BAL,
                                  'D',
                                  V_SBCATEMP_VALUE_DATE,
                                  DBINT_BASIS);
            END IF;
         ELSIF W_NEW_BAL > 0
         THEN
            IF TRIM (W_INT_FOR_CRBAL) = '1' AND W_RAPARAM_CRINT_BASIS = 'D'
            THEN
               W_NEW_CR_INT :=
                  GET_INT_AMOUNT (W_NEW_BAL,
                                  P_AVG_BAL,
                                  'C',
                                  V_SBCATEMP_VALUE_DATE,
                                  CRINT_BASIS);
            END IF;
         END IF;
      END IF;

      IF     TRIM (W_INT_FOR_CRBAL) = '1'
         AND W_TOT_INT_RATE = 0
         AND W_NEW_BAL <> 0
      THEN
         W_UPDATED_IN_TEMP := FALSE;
      END IF;

      -- DBMS_OUTPUT.PUT_LINE(  V_SBCATEMP_INTERNAL_ACNUM  || '[' || V_SBCATEMP_VALUE_DATE || ']' || W_NEW_CR_INT );


      IF W_SKIP_UPDATION = FALSE
      THEN
         V_SBCACBRK_INTERNAL_ACNUM (V_COUNT_BRK) := V_SBCATEMP_INTERNAL_ACNUM;
         V_BREAK_UP_DATE := V_SBCATEMP_VALUE_DATE;
         UPDATE_SBCALC_ARRAY;
      END IF;
   END PROCESS_SBCATEMP_FILE;

   FUNCTION GET_MIN_VALUE_DATE_FROM_TRAN (P_SCAN_FROM_DATE IN DATE)
      RETURN DATE
   IS
      W_DUMMY_DATE   DATE;
   BEGIN
      W_SQL :=
            'SELECT MIN(TRAN_VALUE_DATE) FROM  TRAN'
         || SP_GETFINYEAR (V_GLOB_ENTITY_NUM, P_SCAN_FROM_DATE)
         || ' WHERE TRAN_ENTITY_NUM = :ENTITY_CODE AND  TRAN_DATE_OF_TRAN >= :1
                       AND TRAN_INTERNAL_ACNUM       = :2 AND TRAN_AUTH_ON IS NOT NULL';

      EXECUTE IMMEDIATE W_SQL
         INTO W_DUMMY_DATE
         USING V_GLOB_ENTITY_NUM, P_SCAN_FROM_DATE, V_ACNTS_INTERNAL_ACNUM;

      RETURN W_DUMMY_DATE;
   END GET_MIN_VALUE_DATE_FROM_TRAN;

   FUNCTION GET_MIN_VALUE_DATE (W_ACNUM IN NUMBER)
      RETURN DATE
   IS
      W_DUMMY_MIN_VAUE_DATE   DATE;
   BEGIN
      W_SCAN_FROM_DATE := NULL;

      IF    V_SB_RAPARAM_CR_DB (V_ACNTS_AC_TYPE).M_CREDIT_FREQ = 'D'
         OR V_SB_RAPARAM_CR_DB (V_ACNTS_AC_TYPE).M_DEBIT_FREQ = 'D'
      THEN
         W_SCAN_FROM_DATE := P_CURRENT_DATE;
      ELSIF    V_SB_RAPARAM_CR_DB (V_ACNTS_AC_TYPE).M_CREDIT_FREQ = 'M'
            OR V_SB_RAPARAM_CR_DB (V_ACNTS_AC_TYPE).M_DEBIT_FREQ = 'M'
      THEN
         W_SCAN_FROM_DATE :=
            PKG_PB_GLOBAL.SP_FORM_START_DATE (V_GLOB_ENTITY_NUM,
                                              P_CURRENT_DATE,
                                              'M');
      ELSIF    V_SB_RAPARAM_CR_DB (V_ACNTS_AC_TYPE).M_CREDIT_FREQ = 'Q'
            OR V_SB_RAPARAM_CR_DB (V_ACNTS_AC_TYPE).M_DEBIT_FREQ = 'Q'
      THEN
         W_SCAN_FROM_DATE :=
            PKG_PB_GLOBAL.SP_FORM_START_DATE (V_GLOB_ENTITY_NUM,
                                              P_CURRENT_DATE,
                                              'Q');
      ELSIF    V_SB_RAPARAM_CR_DB (V_ACNTS_AC_TYPE).M_CREDIT_FREQ = 'H'
            OR V_SB_RAPARAM_CR_DB (V_ACNTS_AC_TYPE).M_DEBIT_FREQ = 'H'
      THEN
         W_SCAN_FROM_DATE :=PKG_PB_GLOBAL.SP_FORM_START_DATE (V_GLOB_ENTITY_NUM,
                                              P_CURRENT_DATE,
                                              'H');
      ELSIF    V_SB_RAPARAM_CR_DB (V_ACNTS_AC_TYPE).M_CREDIT_FREQ = 'Y'
            OR V_SB_RAPARAM_CR_DB (V_ACNTS_AC_TYPE).M_DEBIT_FREQ = 'Y'
      THEN
         W_SCAN_FROM_DATE :=PKG_PB_GLOBAL.SP_FORM_START_DATE (V_GLOB_ENTITY_NUM,
                                              P_CURRENT_DATE,
                                              'Y');
      END IF;

      W_DUMMY_MIN_VAUE_DATE := GET_MIN_VALUE_DATE_FROM_TRAN (W_SCAN_FROM_DATE);

      IF W_DUMMY_MIN_VAUE_DATE IS NULL
      THEN
         W_DUMMY_MIN_VAUE_DATE := P_CURRENT_DATE;
      END IF;

      RETURN W_DUMMY_MIN_VAUE_DATE;
   END GET_MIN_VALUE_DATE;

   PROCEDURE INITIALIZE_SBCACALC_ROW
   IS
   BEGIN
      V_SBCACALC_TOT_PREV_DB_INT_AMT (V_COUNT_SB) := 0;
      V_SBCACALC_TOT_PREV_CR_INT_AMT (V_COUNT_SB) := 0;
      V_SBCACALC_TOT_NEW_DB_INT_AMT (V_COUNT_SB) := 0;
      V_SBCACALC_TOT_NEW_CR_INT_AMT (V_COUNT_SB) := 0;
      V_SBCACALC_AC_DB_INT_ACCR_AMT (V_COUNT_SB) := 0;
      V_SBCACALC_BC_DB_INT_ACCR_AMT (V_COUNT_SB) := 0;
      V_SBCACALC_AC_CR_INT_ACCR_AMT (V_COUNT_SB) := 0;
      V_SBCACALC_BC_CR_INT_ACCR_AMT (V_COUNT_SB) := 0;
      V_SBCACALC_CR_INT_BC_CRATE (V_COUNT_SB) := 0;
   END INITIALIZE_SBCACALC_ROW;

   PROCEDURE PROCESS_FOR_ACCOUNTS
   IS
      W_TEMP_PROC_DATE   DATE;
      W_PROC_DATE1       DATE;
      W_PROC_DATE2       DATE;
      MIG_DATE           DATE;
      MIG__AMT           NUMBER (18, 3);
   BEGIN
      INIT_SBCACALC_ARRAY;

      FOR V_INDEX IN 1 .. V_SB_ACNTS.COUNT
      LOOP
         V_BRN_CODE := V_SB_ACNTS (V_INDEX).M_ACNTS_AC_BRN_CODE;

         IF W_PREV_BRN_CODE = 0
         THEN
            W_PREV_BRN_CODE := V_BRN_CODE;
         END IF;

         IF W_PREV_BRN_CODE <> V_BRN_CODE
         THEN
            IF V_COUNT_SB > 1
            THEN
               WRITE_SBCACALCBRK;
               WRITE_SBCACALC_FILE;
               DESTROY_EACH_COLLECTION;
            END IF;

            V_COUNT_SB := 1;
            V_COUNT_BRK := 1;
            INIT_SBCACALC_ARRAY;
            W_PREV_BRN_CODE := V_BRN_CODE;
         END IF;

         P_AVG_BAL := 0.0;
         V_ACNTS_INTERNAL_ACNUM := V_SB_ACNTS (V_INDEX).M_INTERNAL_ACNUM;
         V_ACNTS_AC_CURR_CODE := V_SB_ACNTS (V_INDEX).M_ACNTS_AC_CURR_CODE;
         V_ACNTS_AC_TYPE := V_SB_ACNTS (V_INDEX).M_ACNTS_AC_TYPE;
         V_ACNTS_AC_SUB_TYPE := V_SB_ACNTS (V_INDEX).M_ACNTS_AC_SUB_TYPE;
         V_ACNTS_INT_FLAG := V_SB_ACNTS (V_INDEX).M_ACNTS_INT_FLAG;
         V_ACNTS_PROD_CODE := V_SB_ACNTS (V_INDEX).M_ACNTS_PROD_CODE;
         V_PRODUCT_CODE := V_ACNTS_PROD_CODE;

         V_MINBAL_INT_ELIGIBILITY :=
            V_SB_ACNTS (V_INDEX).M_RAOPER_MIN_BAL_FOR_INT;

         RESET_VARIABLES;

         W_INT_FOR_CRBAL :=
            TRIM (V_SB_ACNTS (V_INDEX).M_RAPARAM_INT_FOR_CR_BAL);
         W_INT_FOR_DBBAL :=
            TRIM (V_SB_ACNTS (V_INDEX).M_RAPARAM_INT_FOR_DB_BAL);

         W_RAPARAM_CRINT_BASIS :=
            TRIM (V_SB_ACNTS (V_INDEX).M_RAPARAM_CRINT_BASIS);
         W_RAPARAM_DBINT_BASIS :=
            TRIM (V_SB_ACNTS (V_INDEX).M_RAPARAM_DBINT_BASIS);

         V_DUMMY_STRING_CR :=
               LPAD (V_SB_ACNTS (V_INDEX).M_ACNTS_AC_TYPE, 5, '0')
            || LPAD (V_SB_ACNTS (V_INDEX).M_ACNTS_AC_SUB_TYPE, 3, 0)
            || V_SB_ACNTS (V_INDEX).M_ACNTS_AC_CURR_CODE
            || 'C';
         V_DUMMY_STRING_DB :=
               LPAD (V_SB_ACNTS (V_INDEX).M_ACNTS_AC_TYPE, 5, '0')
            || LPAD (V_SB_ACNTS (V_INDEX).M_ACNTS_AC_SUB_TYPE, 3, 0)
            || V_SB_ACNTS (V_INDEX).M_ACNTS_AC_CURR_CODE
            || 'D';

         IF V_SB_DENOM.EXISTS (V_DUMMY_STRING_DB)
         THEN
            DBINT_BASIS := V_SB_DENOM (V_DUMMY_STRING_DB);
         END IF;

         IF V_SB_DENOM.EXISTS (V_DUMMY_STRING_DB)
         THEN
            CRINT_BASIS := V_SB_DENOM (V_DUMMY_STRING_CR);
         END IF;

         V_ACNTS_INTERNAL_ACNUM := V_SB_ACNTS (V_INDEX).M_INTERNAL_ACNUM;

         V_ACNTS_AC_CURR_CODE := V_SB_ACNTS (V_INDEX).M_ACNTS_AC_CURR_CODE;

         V_PRODIR_STRING_CR :=
               LPAD (V_SB_ACNTS (V_INDEX).M_ACNTS_PROD_CODE, 4, 0)
            || V_SB_ACNTS (V_INDEX).M_ACNTS_AC_CURR_CODE
            || LPAD (V_SB_ACNTS (V_INDEX).M_ACNTS_AC_TYPE, 5, '0')
            || LPAD (V_SB_ACNTS (V_INDEX).M_ACNTS_AC_SUB_TYPE, 3, '0')
            || '1';

         V_PRODIR_STRING_DB :=
               LPAD (V_SB_ACNTS (V_INDEX).M_ACNTS_PROD_CODE, 4, 0)
            || V_SB_ACNTS (V_INDEX).M_ACNTS_AC_CURR_CODE
            || LPAD (V_SB_ACNTS (V_INDEX).M_ACNTS_AC_TYPE, 5, '0')
            || LPAD (V_SB_ACNTS (V_INDEX).M_ACNTS_AC_SUB_TYPE, 3, '0')
            || '0';

         V_PRODIR_ACSTYPE_SPACE_CR :=
               LPAD (V_SB_ACNTS (V_INDEX).M_ACNTS_PROD_CODE, 4, 0)
            || V_SB_ACNTS (V_INDEX).M_ACNTS_AC_CURR_CODE
            || LPAD (V_SB_ACNTS (V_INDEX).M_ACNTS_AC_TYPE, 5, '0')
            || '000'
            || '1';

         V_PRODIR_ACSTYPE_SPACE_DB :=
               LPAD (V_SB_ACNTS (V_INDEX).M_ACNTS_PROD_CODE, 4, 0)
            || V_SB_ACNTS (V_INDEX).M_ACNTS_AC_CURR_CODE
            || LPAD (V_SB_ACNTS (V_INDEX).M_ACNTS_AC_TYPE, 5, '0')
            || '000'
            || '0';

         V_PRODIR_ACTYPE_SPACE_CR :=
               LPAD (V_SB_ACNTS (V_INDEX).M_ACNTS_PROD_CODE, 4, 0)
            || V_SB_ACNTS (V_INDEX).M_ACNTS_AC_CURR_CODE
            || '00000'
            || '000'
            || '1';

         V_PRODIR_ACTYPE_SPACE_DB :=
               LPAD (V_SB_ACNTS (V_INDEX).M_ACNTS_PROD_CODE, 4, 0)
            || V_SB_ACNTS (V_INDEX).M_ACNTS_AC_CURR_CODE
            || '00000'
            || '000'
            || '0';


        <<CHECK_ACCURUAL_DATE>>
         V_ACNTS_INT_ACCR_UPTO := V_SB_ACNTS (V_INDEX).M_ACNTS_INT_ACCR_UPTO;

         V_PROCESS_START_DATE := NULL;

         IF V_ACNTS_INT_ACCR_UPTO IS NULL
         THEN
            IF V_SB_ACNTS (V_INDEX).M_ACNTS_BASE_DATE IS NULL
            THEN
               V_PROCESS_START_DATE :=
                  V_SB_ACNTS (V_INDEX).M_ACNTS_OPENING_DATE - 1;
            ELSE
               IF V_SB_ACNTS (V_INDEX).M_ACNTS_OPENING_DATE >
                     V_SB_ACNTS (V_INDEX).M_ACNTS_BASE_DATE
               THEN
                  V_PROCESS_START_DATE :=
                     V_SB_ACNTS (V_INDEX).M_ACNTS_OPENING_DATE - 1;
               ELSE
                  V_PROCESS_START_DATE :=
                     V_SB_ACNTS (V_INDEX).M_ACNTS_BASE_DATE - 1;
               END IF;
            END IF;
         ELSE
            V_PROCESS_START_DATE := V_ACNTS_INT_ACCR_UPTO;
         END IF;

         V_PROCESS_START_DATE := V_PROCESS_START_DATE + 1;

         ---W_EARLY_VALUE_DATE := GET_MIN_VALUE_DATE (V_ACNTS_INTERNAL_ACNUM);
         
         W_EARLY_VALUE_DATE:=V_SB_ACNTS (V_INDEX).M_TRAN_VALUE_DT;

         IF V_PROCESS_START_DATE > W_EARLY_VALUE_DATE
         THEN
            W_PROC_DATE := V_PROCESS_START_DATE;        -- W_EARLY_VALUE_DATE;
         ELSE
            W_PROC_DATE := V_PROCESS_START_DATE;
         END IF;

        <<DOPROCESS>>
         BEGIN
            SELECT TO_CHAR (TRUNC (TRUNC (P_CURRENT_DATE, 'MM'), 'MM'),
                            'DD-MON-YYYY')
                      START_DATE,
                   LAST_DAY (P_CURRENT_DATE)
              INTO W_PROC_DATE1, W_PROC_DATE2
              FROM DUAL;

            SP_GET_AVG_BAL (1,
                            V_ACNTS_PROD_CODE,
                            V_ACNTS_INTERNAL_ACNUM,
                            V_ACNTS_AC_CURR_CODE,
                            W_PROC_DATE1,
                            W_PROC_DATE2,
                            P_AVG_BAL,
                            W_ERR_MSG);
            -- SNDPROD
            W_TEMP_PROC_DATE := W_PROC_DATE;

           <<MIG_DETAILS_INFO>>
            BEGIN
               MIG_DATE := NULL;
               MIG__AMT := 0;

               SELECT SNDPROD_MIG_DATE, SNDPROD_AMT
                 INTO MIG_DATE, MIG__AMT
                 FROM SNDPROD
                WHERE     SNDPROD_INTERNAL_ACNUM = V_ACNTS_INTERNAL_ACNUM
                      AND TO_CHAR (SNDPROD_MIG_DATE, 'MON-YY') =
                             TO_CHAR (W_PROC_DATE, 'MON-YY');
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  MIG__AMT := 0.0;
                  MIG_DATE := NULL;
            END MIG_DETAILS_INFO;

            IF MIG__AMT > 0
            THEN
               W_NEW_BAL := MIG__AMT;
               W_PROC_DATE := MIG_DATE - 1;
               PROCESS_SBCATEMP_FILE;
            END IF;

            W_PROC_DATE := W_TEMP_PROC_DATE;

            --
            WHILE W_PROC_DATE <= P_CURRENT_DATE
            LOOP
               W_PREV_BAL := 0;
               W_NEW_BAL := 0;
               W_PREV_CR_INT := 0;
               W_PREV_DB_INT := 0;
               W_SKIP_UPDATION := FALSE;

               --IF W_PROC_DATE < V_PROCESS_START_DATE THEN
               --     W_PREV_BAL := GET_BALANCE(W_PROC_DATE,
               --ELSE
               --     W_PREV_BAL := 0;
               --END IF;

               W_NEW_BAL := GET_BALANCE (W_PROC_DATE, 'N');
               PROCESS_SBCATEMP_FILE;
               W_PROC_DATE := W_PROC_DATE + 1;
            END LOOP;


            IF W_BREAK_UP_ADDED = '1'
            THEN
               V_SBCACALC_INTERNAL_ACNUM (V_COUNT_SB) :=
                  V_SB_ACNTS (V_INDEX).M_INTERNAL_ACNUM;

               IF V_SB_ACNTS (V_INDEX).M_ACNTS_INT_ACCR_UPTO IS NULL
               THEN
                  V_SBCACALC_PREV_ACCR_UPTO_DATE (V_COUNT_SB) :=
                     V_SB_ACNTS (V_INDEX).M_ACNTS_OPENING_DATE - 1;
               ELSE
                  V_SBCACALC_PREV_ACCR_UPTO_DATE (V_COUNT_SB) :=
                     V_SB_ACNTS (V_INDEX).M_ACNTS_INT_ACCR_UPTO;
               END IF;

               V_SBCACALC_INT_ACCR_UPTO_DATE (V_COUNT_SB) := P_CURRENT_DATE;
               V_COUNT_SB := V_COUNT_SB + 1;
               INIT_SBCACALC_ARRAY;
            END IF;
         EXCEPTION
            WHEN E_SKIPEXCEP
            THEN
               INITIALIZE_SBCACALC_ROW;
               RECORD_EXCEPTION (
                     'Account Number Not Processed '
                  || FACNO (V_GLOB_ENTITY_NUM,
                            V_ACNTS_INTERNAL_ACNUM));
         END DOPROCESS;
      END LOOP;


      IF V_COUNT_SB > 1
      THEN
         W_PREV_BRN_CODE := V_BRN_CODE;
         WRITE_SBCACALCBRK;
         WRITE_SBCACALC_FILE;
         DESTROY_EACH_COLLECTION;
      END IF;

      V_COUNT_SB := 1;
      V_COUNT_BRK := 1;
   END PROCESS_FOR_ACCOUNTS;

   PROCEDURE FORM_COMMON_SQL
   IS
   BEGIN
      W_SQL_SUB := '';
      W_SQL_SUB :=' and (RAPARAM_DBINT_ACCR_FREQ = ''D'' OR RAPARAM_CRINT_ACCR_FREQ = ''D''';

      IF W_MNTHEND = 1
      THEN
         W_SQL_SUB := W_SQL_SUB|| ' OR RAPARAM_DBINT_ACCR_FREQ = ''M'' OR RAPARAM_CRINT_ACCR_FREQ = ''M''';
      END IF;

      IF W_QTREND = 1
      THEN
         W_SQL_SUB :=W_SQL_SUB || ' OR RAPARAM_DBINT_ACCR_FREQ = ''Q'' OR RAPARAM_CRINT_ACCR_FREQ = ''Q''';
      END IF;

      IF W_HYREND = 1
      THEN
         W_SQL_SUB := W_SQL_SUB|| ' OR RAPARAM_DBINT_ACCR_FREQ = ''H'' OR RAPARAM_CRINT_ACCR_FREQ = ''H''';
      END IF;

      IF W_YREND = 1
      THEN
         W_SQL_SUB :=W_SQL_SUB|| 'OR RAPARAM_DBINT_ACCR_FREQ = ''Y'' OR RAPARAM_CRINT_ACCR_FREQ = ''Y'' ';
      END IF;

      W_SQL_SUB := W_SQL_SUB || ')';
   END FORM_COMMON_SQL;
   
   
    PROCEDURE SET_DAY_WISE_BALANCE(P_TRAN_YEAR NUMBER) IS
    V_DAY_BALSQL VARCHAR2(3000);
    BEGIN
        V_DAY_BALSQL:='SELECT TRAN_INTERNAL_ACNUM, TRAN_VALUE_DATE,(SUM (DECODE (TRAN_DB_CR_FLG, ''C'', TRAN_AMOUNT, 0))-SUM (DECODE (TRAN_DB_CR_FLG, ''D'', TRAN_AMOUNT, 0))) AS TRANBALANCE 
                                   FROM TRAN'||P_TRAN_YEAR||' T, PROCACNUM P
                                   WHERE P.PROC_INTERNAL_ACNUM=T.TRAN_INTERNAL_ACNUM
                                   AND TRAN_ENTITY_NUM = :ENTITY_NUM 
                                   AND TRAN_VALUE_DATE >= TRUNC(INT_FROM_DATE,''MM'')
                                   AND TRAN_VALUE_DATE <= :END_DATE
                                   AND TRAN_DATE_OF_TRAN <= :END_DATE
                                   AND TRAN_AUTH_ON IS NOT NULL
                            GROUP BY TRAN_INTERNAL_ACNUM, TRAN_VALUE_DATE';

               EXECUTE IMMEDIATE V_DAY_BALSQL BULK COLLECT
                  INTO T_TRAN_DAY_LIST USING V_GLOB_ENTITY_NUM,P_CURRENT_DATE,P_CURRENT_DATE;

                FORALL IND IN   T_TRAN_DAY_LIST.FIRST .. T_TRAN_DAY_LIST.LAST
                    INSERT INTO TRAN_DAILY_BAL(TRAN_INTERNAL_ACNUM, TRAN_VALUE_DATE, TRAN_AMOUNT) 
                    VALUES (T_TRAN_DAY_LIST(IND).TRAN_INTERNAL_ACNUM, T_TRAN_DAY_LIST(IND).TRAN_VALUE_DATE, T_TRAN_DAY_LIST(IND).TRAN_AMOUNT);
         EXCEPTION
                  WHEN OTHERS THEN 
                  W_ERR_MSG:='Error in set date balanc.'||SUBSTR(SQLERRM,1,2000);            
    END;

PROCEDURE SET_MIN_TRAN_DATA(P_TRAN_YEAR NUMBER) IS 
 V_MIN_TRN_SQL VARCHAR2(3000);
 V_TRNFILT_SQL VARCHAR2(3000);
 BEGIN
  
   BEGIN
   V_TRNFILT_SQL:='SELECT  P.PROC_INTERNAL_ACNUM, SF_FORM_START_DATE_SND (P.RAOPERPARAM_AMT_RESTRIC,
                                               P.PROAC_NOTICE_VIOLATE,
                                               :ENTITY_NUM,
                                               :ASON_DATE) TRN_FILTER_DATE 
                              FROM PROCACNUM P';
                              
           EXECUTE IMMEDIATE V_TRNFILT_SQL BULK COLLECT INTO T_TRAN_FILTER_DATE
           USING  V_GLOB_ENTITY_NUM,P_CURRENT_DATE;
           
          FORALL IND IN  T_TRAN_FILTER_DATE.FIRST .. T_TRAN_FILTER_DATE.LAST 
                UPDATE PROCACNUM
                      SET TRAN_FILTER_DATE=T_TRAN_FILTER_DATE(IND).TRAN_FILTER_DATE
                WHERE  PROC_INTERNAL_ACNUM=T_TRAN_FILTER_DATE(IND).TRAN_INTERNAL_ACNUM 
                    AND PROCACNUM_ENTITY_NUM=V_GLOB_ENTITY_NUM;
        EXCEPTION
        WHEN EX_DML_ERRORS THEN
        W_BULK_COUNT:=SQL%BULK_EXCEPTIONS.COUNT;
        W_ERR_MSG:=W_BULK_COUNT||' ROWS FAILED IN INSERT PROCACNUM ';
        DBMS_OUTPUT.PUT_LINE(W_BULK_COUNT||' ROWS FAILED IN INSERT PROCACNUM ');
        FOR I IN 1 .. W_BULK_COUNT LOOP
                DBMS_OUTPUT.PUT_LINE('Error: ' || I ||' Array Index: ' || SQL%BULK_EXCEPTIONS(I).ERROR_INDEX ||' Message: ' || SQLERRM(-SQL%BULK_EXCEPTIONS(I).ERROR_CODE));
        END LOOP;
   END;
 
   BEGIN
    V_MIN_TRN_SQL:='SELECT TRAN_INTERNAL_ACNUM, MIN (TRAN_VALUE_DATE)
                                  FROM TRAN'||P_TRAN_YEAR||' T, PROCACNUM P
                                 WHERE  P.PROC_INTERNAL_ACNUM=T.TRAN_INTERNAL_ACNUM
                                       AND TRAN_ENTITY_NUM = :1
                                       AND TRAN_DATE_OF_TRAN >=P.TRAN_FILTER_DATE
                                       AND TRAN_AUTH_ON IS NOT NULL
                                GROUP BY TRAN_INTERNAL_ACNUM';

  EXECUTE IMMEDIATE V_MIN_TRN_SQL BULK COLLECT
                 INTO T_MIN_TRNDATE USING V_GLOB_ENTITY_NUM;
                 
          FORALL IND IN   T_MIN_TRNDATE.FIRST .. T_MIN_TRNDATE.LAST 
                UPDATE PROCACNUM
                      SET TRAN_VALUE_DT=T_MIN_TRNDATE(IND).TRAN_VAL_DATE
                WHERE  PROC_INTERNAL_ACNUM=T_MIN_TRNDATE(IND).TRAN_INTERNAL_ACNUM
                     AND PROCACNUM_ENTITY_NUM=V_GLOB_ENTITY_NUM;
 EXCEPTION
          WHEN OTHERS THEN 
          W_ERR_MSG:='Error in set minimum transaction date.'||SUBSTR(SQLERRM,1,2000);            
 END;
END;


   PROCEDURE CALC_INTEREST_ACCOUNTS
   IS
   BEGIN
   
           BEGIN
           SET_MIN_TRAN_DATA(TO_NUMBER(TO_CHAR(P_CURRENT_DATE,'YYYY')));
           SET_DAY_WISE_BALANCE(TO_NUMBER(TO_CHAR(P_CURRENT_DATE,'YYYY')));
           END;
           
      W_SQL :='SELECT A.ACNTS_INTERNAL_ACNUM, A.ACNTS_CLIENT_NUM, A.ACNTS_AC_TYPE,
            A.ACNTS_AC_SUB_TYPE, A.ACNTS_CURR_CODE, A.ACNTS_PROD_CODE, A.ACNTS_INT_ACCR_UPTO,
            A.ACNTS_OPENING_DATE, A.ACNTS_BASE_DATE, A.ACNTS_CREDIT_INT_REQD,
            B.RAPARAM_INT_FOR_CR_BAL, B.RAPARAM_INT_FOR_DB_BAL, A.ACNTS_BRN_CODE ,
            B.RAPARAM_CRINT_BASIS,B.RAPARAM_DBINT_BASIS, RAOPM.RAOPER_MIN_BAL_INT_ELGIBILITY,P.TRAN_VALUE_DT
            FROM ACNTS A, RAPARAM B, PROCACNUM P, RAOPERPARAM RAOPM, PWGENPARAM PW
            WHERE PROCACNUM_ENTITY_NUM = :PROC_ENTITY_CODE 
               AND ACNTS_ENTITY_NUM = :ACNTS_ENTITY_CODE 
               AND A.ACNTS_CLOSURE_DATE IS NULL 
               AND B.RAPARAM_AC_TYPE = A.ACNTS_AC_TYPE 
               AND A.ACNTS_PROD_CODE = PW.PWGENPARAM_PROD_CODE 
                AND  (A.ACNTS_INT_ACCR_UPTO IS NULL
                 OR  A.ACNTS_INT_ACCR_UPTO < :1)  
                 AND  A.ACNTS_INTERNAL_ACNUM = P.PROC_INTERNAL_ACNUM 
                 AND RAOPM.RAOPER_AC_TYPE = A.ACNTS_AC_TYPE 
                 AND RAOPM.RAOPER_AC_SUB_TYPE = A.ACNTS_AC_SUB_TYPE          
                 AND RAOPM.RAOPER_CURR_CODE = A.ACNTS_CURR_CODE
                 AND  PW.PWGENPARAM_SND_PROD = :2 ';

      --A.ACNTS_INTERNAL_ACNUM IN (''10000200003420'',''10000200003417'') '
      -- A.ACNTS_INTERNAL_ACNUM IN (''11612100004815'')
      -- A.ACNTS_INTERNAL_ACNUM IN (''11601400001788'')          AND
      -- A.ACNTS_INTERNAL_ACNUM IN (''11612100004996'')          AND

      EXECUTE IMMEDIATE W_SQL
         BULK COLLECT INTO V_SB_ACNTS
         USING V_GLOB_ENTITY_NUM,V_GLOB_ENTITY_NUM, P_CURRENT_DATE, '1';
         
      IF V_SB_ACNTS.COUNT > 0
      THEN
         V_COUNT_SB := 1;
         V_COUNT_BRK := 1;
         W_PREV_BRN_CODE := 0;

         PROCESS_FOR_ACCOUNTS;
      END IF;

      V_SB_ACNTS.DELETE;
   END CALC_INTEREST_ACCOUNTS;

   PROCEDURE GET_RUNNING_ACCOUNT_PRODUCTS
   IS
      TYPE P_AC_DUMMY IS RECORD
      (
         M_AC_TYPES      VARCHAR2 (5),
         M_CREDIT_FREQ   CHAR (1),
         M_DEBIT_FREQ    CHAR (1)
      );

      TYPE TP_AC_DUMMY IS TABLE OF P_AC_DUMMY
         INDEX BY PLS_INTEGER;

      V_AC_DUMMY   TP_AC_DUMMY;
   BEGIN
      W_SQL :='SELECT B.ACTYPE_CODE, A.RAPARAM_CRINT_ACCR_FREQ, A.RAPARAM_DBINT_ACCR_FREQ 
                      FROM RAPARAM A, ACTYPES B, PRODUCTS C 
                      WHERE PRODUCT_FOR_RUN_ACS = 1 
                      AND B.ACTYPE_CODE = A.RAPARAM_AC_TYPE 
                      AND B.ACTYPE_PROD_CODE = C.PRODUCT_CODE 
                      AND  ((A.RAPARAM_INT_FOR_CR_BAL = 1
                      AND A.RAPARAM_CRINT_BASIS = :1) 
                      OR (A.RAPARAM_INT_FOR_DB_BAL = 1 AND A.RAPARAM_DBINT_BASIS = :2))';

      EXECUTE IMMEDIATE W_SQL BULK COLLECT INTO V_AC_DUMMY USING 'D', 'D';

      IF V_AC_DUMMY.COUNT > 0
      THEN
         FOR M_INDEX IN 1 .. V_AC_DUMMY.COUNT
         LOOP
            V_SB_RAPARAM_CR_DB (V_AC_DUMMY (M_INDEX).M_AC_TYPES).M_CREDIT_FREQ :=
               V_AC_DUMMY (M_INDEX).M_CREDIT_FREQ;
            V_SB_RAPARAM_CR_DB (V_AC_DUMMY (M_INDEX).M_AC_TYPES).M_DEBIT_FREQ :=
               V_AC_DUMMY (M_INDEX).M_DEBIT_FREQ;
         END LOOP;
      END IF;

      V_AC_DUMMY.DELETE;
   END GET_RUNNING_ACCOUNT_PRODUCTS;

   PROCEDURE DELETE_STATIC_ARRAY
   IS
   BEGIN
      V_SB_DENOM.DELETE;
      V_SB_PROD_INT_RATE.DELETE;
      V_SB_ACNT_INT_RATE.DELETE;
      V_SB_RAPARAM_CR_DB.DELETE;
   END DELETE_STATIC_ARRAY;

   PROCEDURE DESTROY_ACCOUNT_ARRAY
   IS
   BEGIN
      V_SB_ACNTS.DELETE;
   END DESTROY_ACCOUNT_ARRAY;


   PROCEDURE POPULATE_PROD_INT_RATES
   IS
      TYPE PROD_DUMMMY IS RECORD
      (
         M_PROD_CUST_CURR            VARCHAR2 (16),
         M_PRODIR_INT_RATE           NUMBER (7, 5),
         M_PRODIR_EFF_DATE           DATE,
         PRODIRH_GOBACK_GLOBAL_INT   CHAR (1),
         PRODIR_SLAB_REQ             CHAR (1),
         PRODIR_SLAB_CHOICE          CHAR (1)
      );

      TYPE TPROD_DUMMMY IS TABLE OF PROD_DUMMMY
         INDEX BY PLS_INTEGER;

      M_PROD_DUMMMY   TPROD_DUMMMY;
   BEGIN
      W_SQL :=
            'SELECT LPAD(PRODIR_PROD_CODE,4,0) ||
                  PRODIR_CURR_CODE      ||
                  LPAD(DECODE(TRIM(PRODIR_AC_TYPE),'''',''0'',TRIM(PRODIR_AC_TYPE)) , 5,''0'') ||
                   LPAD(DECODE(TRIM(PRODIR_ACSUB_TYPE),'''',''0'',TRIM(PRODIR_ACSUB_TYPE)) , 3,''0'') ||
                  DECODE(PRODIR_INT_DB_CR_FLG , ''C'',1,0),
                        PRODIR_INT_RATE,
                        PRODIR_LATEST_EFF_DATE,
                        PRODIR_GOBACK_GLOBAL_INT,
                        NVL(PRODIR_SLAB_REQ,0),
                        NVL(PRODIR_SLAB_CHOICE,0)
                         FROM PRODIR 
                       WHERE PRODIR_ENTITY_NUM = :ENTITY_CODE 
                        AND  PRODIR_LATEST_EFF_DATE <= :CURR_DATE
                        ORDER BY PRODIR_LATEST_EFF_DATE ';

      EXECUTE IMMEDIATE W_SQL BULK COLLECT INTO M_PROD_DUMMMY USING V_GLOB_ENTITY_NUM,P_CURRENT_DATE;

      IF M_PROD_DUMMMY.COUNT > 0
      THEN
         FOR M_INDEX IN 1 .. M_PROD_DUMMMY.COUNT
         LOOP
            V_SB_PROD_INT_RATE (
               TRIM (M_PROD_DUMMMY (M_INDEX).M_PROD_CUST_CURR)) :=
                  (TO_CHAR (M_PROD_DUMMMY (M_INDEX).M_PRODIR_INT_RATE,
                            'S000.0000'))
               || M_PROD_DUMMMY (M_INDEX).PRODIRH_GOBACK_GLOBAL_INT
               || M_PROD_DUMMMY (M_INDEX).PRODIR_SLAB_REQ
               || M_PROD_DUMMMY (M_INDEX).PRODIR_SLAB_CHOICE;
         END LOOP;
      END IF;

      M_PROD_DUMMMY.DELETE;
   END POPULATE_PROD_INT_RATES;

   PROCEDURE GET_COMMON_VALUES
   IS
   BEGIN
      W_MNTHEND := 0;
      W_QTREND := 0;
      W_HYREND := 0;
      W_YREND := 0;

      W_FINYEAR :=SP_GETFINYEAR (V_GLOB_ENTITY_NUM, P_CURRENT_DATE);

      IF GET_MQHY_MON (V_GLOB_ENTITY_NUM, P_CURRENT_DATE, 'M') =
            1
      THEN
         W_MNTHEND := 1;
      END IF;

      IF W_MNTHEND = 1
      THEN
         W_QTREND :=
            GET_MQHY_MON (V_GLOB_ENTITY_NUM, P_CURRENT_DATE, 'Q');
         W_HYREND :=
            GET_MQHY_MON (V_GLOB_ENTITY_NUM, P_CURRENT_DATE, 'H');
         W_YREND :=
            GET_MQHY_MON (V_GLOB_ENTITY_NUM, P_CURRENT_DATE, 'Y');
      END IF;

      POPULATE_PROD_INT_RATES;
      GET_RUNNING_ACCOUNT_PRODUCTS;
      GET_INT_BASIS;
   END GET_COMMON_VALUES;

   PROCEDURE PROCESS_FOR_INT_CALC (V_BRN_CODE IN NUMBER)
   IS
   BEGIN
     <<CHECKSBACCR>>
      BEGIN
         W_RUN_NO := GET_RUNNO;

         PKG_EODSOD_FLAGS.PV_RUN_NUMBER := W_RUN_NO;

         W_SPACE := ' ';
         WRITE_SBCACALCCTL_FILE;
         CALC_INTEREST_ACCOUNTS;

         PKG_EODSOD_FLAGS.PV_ERROR_MSG := W_ERR_MSG;

         IF TRIM (W_ERR_MSG) IS NULL
         THEN
            PKG_SNDACCRPOST.SP_SNDACCRPOST (V_GLOB_ENTITY_NUM);
         END IF;

         DESTROY_ACCOUNT_ARRAY;
      EXCEPTION
         WHEN OTHERS
         THEN
            DESTROY_ACCOUNT_ARRAY;

            IF TRIM (W_ERR_MSG) IS NULL
            THEN
               W_ERR_MSG := SUBSTR (SQLERRM, 1, 1000);
            END IF;

            PKG_EODSOD_FLAGS.PV_ERROR_MSG :=
               SUBSTR (
                     W_ERR_MSG
                  || ' Account Number -'
                  || FACNO (V_GLOB_ENTITY_NUM,
                            V_ACNTS_INTERNAL_ACNUM),
                  1,
                  1000);
            PKG_PB_GLOBAL.DETAIL_ERRLOG (V_GLOB_ENTITY_NUM,
                                         'E',
                                         W_ERR_MSG,
                                         ' ',
                                         V_ACNTS_INTERNAL_ACNUM);
            PKG_PB_GLOBAL.DETAIL_ERRLOG (V_GLOB_ENTITY_NUM,
                                         'E',
                                         SUBSTR (SQLERRM, 1, 1000),
                                         ' ',
                                         0);
      END CHECKSBACCR;
   END PROCESS_FOR_INT_CALC;

   PROCEDURE SP_SBCAACCRUALS (V_ENTITY_NUM    IN NUMBER,
                              V_ACNT_NUMBER   IN NUMBER)
   IS
   BEGIN
      --ENTITY CODE COMMONLY ADDED - 06-11-2009  - BEG
      PKG_ENTITY.SP_SET_ENTITY_CODE (V_ENTITY_NUM);
      V_GLOB_ENTITY_NUM:=V_ENTITY_NUM;
      --ENTITY CODE COMMONLY ADDED - 06-11-2009  - END
      V_PROCESS_BRN_cODE := 0;
      W_ERR_MSG := '';
      P_CURRENT_DATE := PKG_EODSOD_FLAGS.PV_CURRENT_DATE;

      P_USER_ID := PKG_EODSOD_FLAGS.PV_USER_ID;
      P_ACNT_NUMBER := V_ACNT_NUMBER;
      GET_COMMON_VALUES;

      W_SQL := GET_ACC_SELECT_SQL (P_ACNT_NUMBER);

      EXECUTE IMMEDIATE W_SQL
         BULK COLLECT INTO V_DUMMY_INTERNAL_ACNUM
        USING V_GLOB_ENTITY_NUM, P_CURRENT_DATE,'M','M',P_ACNT_NUMBER,V_GLOB_ENTITY_NUM,PKG_EODSOD_FLAGS.PV_EODSODFLAG,PKG_EODSOD_FLAGS.PV_PROCESS_NAME,PKG_EODSOD_FLAGS.PV_CURRENT_DATE;
--
--         USING V_GLOB_ENTITY_NUM, P_CURRENT_DATE,
--               'M',
--               'M',
--               P_ACNT_NUMBER;
--               
--      FOR DACNTS IN 1 .. V_DUMMY_INTERNAL_ACNUM.COUNT
--      LOOP
--        <<INSERTPROCACNUM>>
--         BEGIN
--            INSERT INTO PROCACNUM (PROCACNUM_ENTITY_NUM, PROC_INTERNAL_ACNUM)
--                 VALUES (V_GLOB_ENTITY_NUM, V_ACNT_NUMBER);
--         END INSERTPROCACNUM;
--      END LOOP;
      
      BEGIN
            FORALL I IN V_DUMMY_INTERNAL_ACNUM.FIRST .. V_DUMMY_INTERNAL_ACNUM.LAST
        INSERT INTO PROCACNUM(PROCACNUM_ENTITY_NUM, PROC_INTERNAL_ACNUM,RAOPERPARAM_AMT_RESTRIC, PROAC_NOTICE_VIOLATE,INT_FROM_DATE)
                                    VALUES(V_GLOB_ENTITY_NUM,V_DUMMY_INTERNAL_ACNUM(I).ACNTS_INTERNAL_ACNUM,V_DUMMY_INTERNAL_ACNUM(I).RAPARAM_CRINT_ACCR_FREQ,V_DUMMY_INTERNAL_ACNUM(I).RAPARAM_DBINT_ACCR_FREQ,V_DUMMY_INTERNAL_ACNUM(I).INT_FROM_DATE);

        EXCEPTION
        WHEN EX_DML_ERRORS THEN
        W_BULK_COUNT:=SQL%BULK_EXCEPTIONS.COUNT;
        W_ERR_MSG:=W_BULK_COUNT||' ROWS FAILED IN INSERT PROCACNUM ';
        DBMS_OUTPUT.PUT_LINE(W_BULK_COUNT||' ROWS FAILED IN INSERT PROCACNUM ');
        FOR I IN 1 .. W_BULK_COUNT LOOP
                DBMS_OUTPUT.PUT_LINE('Error: ' || I ||' Array Index: ' || SQL%BULK_EXCEPTIONS(I).ERROR_INDEX ||' Message: ' || SQLERRM(-SQL%BULK_EXCEPTIONS(I).ERROR_CODE));
        END LOOP;
    END;
                
      V_DUMMY_INTERNAL_ACNUM.DELETE;
     IF W_ERR_MSG IS NULL THEN 
      PROCESS_FOR_INT_CALC (V_PROCESS_BRN_cODE);
      DELETE_STATIC_ARRAY;
     END IF;
   END SP_SBCAACCRUALS;

   PROCEDURE DESTROY_ARRAYS
   IS
   BEGIN
      NULL;
   END DESTROY_ARRAYS;

   FUNCTION GET_ACC_SELECT_SQL (V_PROC_ACNUM IN NUMBER)
      RETURN VARCHAR2
   IS
      W_DUMMY_SQL   VARCHAR2 (4300);
      W_IGNOR_ACCOUNT VARCHAR2(4000);
   BEGIN
      W_DUMMY_SQL := '';
      FORM_COMMON_SQL;
      W_DUMMY_SQL :='SELECT A.ACNTS_INTERNAL_ACNUM ACNTS_INTERNAL_ACNUM, B.RAPARAM_AC_TYPE RAPARAM_AC_TYPE
      FROM ACNTS A, RAPARAM B, ACTYPES C, PRODUCTS D 
      WHERE ACNTS_ENTITY_NUM = :ENTITY_NUM
         AND  D.PRODUCT_FOR_RUN_ACS =1 
         AND D.PRODUCT_FOR_LOANS <>  1 
         AND A.ACNTS_PROD_CODE = D.PRODUCT_CODE 
         AND A.ACNTS_CLOSURE_DATE IS NULL 
         AND C.ACTYPE_CODE = B.RAPARAM_AC_TYPE 
         AND C.ACTYPE_PROD_CODE = D.PRODUCT_CODE 
         AND B.RAPARAM_AC_TYPE = A.ACNTS_AC_TYPE 
         AND (A.ACNTS_INT_ACCR_UPTO IS NULL OR A.ACNTS_INT_ACCR_UPTO < :1)  
         AND (B.RAPARAM_INT_FOR_CR_BAL  = 1 OR B.RAPARAM_INT_FOR_DB_BAL = 1) 
         AND (B.RAPARAM_CRINT_BASIS = :2  OR B.RAPARAM_DBINT_BASIS = :3)';

      IF NVL (V_PROC_ACNUM, 0) = 0
      THEN
         W_DUMMY_SQL := W_DUMMY_SQL || W_SQL_SUB;
         W_DUMMY_SQL := W_DUMMY_SQL || ' AND A.ACNTS_BRN_CODE = :4';
      ELSE
         W_DUMMY_SQL := W_DUMMY_SQL || ' AND A.ACNTS_INTERNAL_ACNUM = :4';
      END IF;
      
      W_IGNOR_ACCOUNT:='MINUS
                                    SELECT E.PROC_INTERNAL_ACNUM, A.ACNTS_AC_TYPE
                                      FROM EODSODIGACNT E, ACNTS A
                                      WHERE E.PROC_INTERNAL_ACNUM=A.ACNTS_INTERNAL_ACNUM
                                      AND PROC_ENTITY_NUM = :4
                                      AND  PROC_TYPE = :5
                                       AND PROC_NAME = :6
                                       AND PROC_DATE = :7
                                       AND PROC_CONTRACT_NUM = 0';
                                       
    W_DUMMY_SQL:=W_DUMMY_SQL||W_IGNOR_ACCOUNT;
    
    W_DUMMY_SQL:= 'SELECT A.ACNTS_INTERNAL_ACNUM, R.RAPARAM_CRINT_ACCR_FREQ, R.RAPARAM_DBINT_ACCR_FREQ,
                                                        CASE  WHEN ACNTS_INT_ACCR_UPTO IS NOT NULL
                                                          THEN
                                                             ACNTS_INT_ACCR_UPTO + 1
                                                          WHEN ACNTS_BASE_DATE IS NULL
                                                          THEN
                                                             ACNTS_OPENING_DATE
                                                          WHEN ACNTS_OPENING_DATE >= ACNTS_BASE_DATE
                                                          THEN
                                                             ACNTS_BASE_DATE
                                                          ELSE
                                                             ACNTS_OPENING_DATE
                                                       END
                                                          INT_FROM_DATE
                                FROM RAPARAM R, ('||W_DUMMY_SQL||') A, ACNTS AC
                                WHERE R.RAPARAM_AC_TYPE= A.RAPARAM_AC_TYPE
                                AND A.ACNTS_INTERNAL_ACNUM=AC.ACNTS_INTERNAL_ACNUM';
      RETURN W_DUMMY_SQL;

   END GET_ACC_SELECT_SQL;

   PROCEDURE PROC_BRN_WISE (V_ENTITY_NUM   IN NUMBER,
                            V_BRN_CODE     IN NUMBER DEFAULT 0)
   IS
      W_BRN_CODE        NUMBER (6);
      W_ACCOUNT_COUNT   NUMBER (10);
      C1 RC;
   BEGIN
      --ENTITY CODE COMMONLY ADDED - 06-11-2009  - BEG
      PKG_ENTITY.SP_SET_ENTITY_CODE (V_ENTITY_NUM);
      V_GLOB_ENTITY_NUM:=V_ENTITY_NUM;
     --ENTITY CODE COMMONLY ADDED - 06-11-2009  - END
     <<PROCESSBRNWISE>>
      BEGIN
         W_BRN_CODE := 0;
         P_ACNT_NUMBER := 0;
         V_PROCESS_BRN_cODE := 0;
         W_ERR_MSG := '';
         P_CURRENT_DATE := PKG_EODSOD_FLAGS.PV_CURRENT_DATE;

         P_USER_ID := PKG_EODSOD_FLAGS.PV_USER_ID;

         GET_COMMON_VALUES;
         FORM_COMMON_SQL;
         PKG_PROCESS_CHECK.INIT_PROC_BRN_WISE (V_GLOB_ENTITY_NUM,V_BRN_CODE);

         V_DUMMY_INTERNAL_ACNUM.DELETE;

         FOR IDX IN 1 .. PKG_PROCESS_CHECK.V_ACNTBRN.COUNT
         LOOP
            W_BRN_CODE := PKG_PROCESS_CHECK.V_ACNTBRN (IDX).LN_BRN_CODE;

            IF PKG_PROCESS_CHECK.CHK_BRN_ALREADY_PROCESSED (V_GLOB_ENTITY_NUM,W_BRN_CODE) = FALSE
            THEN
               W_ACCOUNT_COUNT := 0;

               W_SQL := GET_ACC_SELECT_SQL (0);

              W_ACCOUNT_COUNT  := PKG_PROCESS_CHECK.W_ACCOUNT_LIMIT;

                OPEN C1 FOR W_SQL 
                USING V_GLOB_ENTITY_NUM, P_CURRENT_DATE,'D','D',W_BRN_CODE,V_GLOB_ENTITY_NUM,PKG_EODSOD_FLAGS.PV_EODSODFLAG,PKG_EODSOD_FLAGS.PV_PROCESS_NAME,PKG_EODSOD_FLAGS.PV_CURRENT_DATE;
                
                LOOP
                
                IF W_ACCOUNT_COUNT >0 THEN
                    FETCH C1
                    BULK COLLECT INTO V_DUMMY_INTERNAL_ACNUM LIMIT W_ACCOUNT_COUNT ;
                 ELSE
                  FETCH C1
                    BULK COLLECT INTO V_DUMMY_INTERNAL_ACNUM LIMIT 2000;
                 END IF;
                
                BEGIN
                        FORALL I IN V_DUMMY_INTERNAL_ACNUM.FIRST .. V_DUMMY_INTERNAL_ACNUM.LAST
                    INSERT INTO PROCACNUM(PROCACNUM_ENTITY_NUM, PROC_INTERNAL_ACNUM,RAOPERPARAM_AMT_RESTRIC, PROAC_NOTICE_VIOLATE,INT_FROM_DATE)
                                                VALUES(V_GLOB_ENTITY_NUM,V_DUMMY_INTERNAL_ACNUM(I).ACNTS_INTERNAL_ACNUM,V_DUMMY_INTERNAL_ACNUM(I).RAPARAM_CRINT_ACCR_FREQ,V_DUMMY_INTERNAL_ACNUM(I).RAPARAM_DBINT_ACCR_FREQ,V_DUMMY_INTERNAL_ACNUM(I).INT_FROM_DATE);
                    EXCEPTION
                    WHEN EX_DML_ERRORS THEN
                    W_BULK_COUNT:=SQL%BULK_EXCEPTIONS.COUNT;
                    W_ERR_MSG:=W_BULK_COUNT||' ROWS FAILED IN INSERT PROCACNUM ';
                    DBMS_OUTPUT.PUT_LINE(W_BULK_COUNT||' ROWS FAILED IN INSERT PROCACNUM ');
                    FOR I IN 1 .. W_BULK_COUNT LOOP
                            DBMS_OUTPUT.PUT_LINE('Error: ' || I ||' Array Index: ' || SQL%BULK_EXCEPTIONS(I).ERROR_INDEX ||' Message: ' || SQLERRM(-SQL%BULK_EXCEPTIONS(I).ERROR_CODE));
                    END LOOP;
                END;
                
                IF W_ERR_MSG IS NULL THEN 

                 PROCESS_FOR_INT_CALC (W_BRN_CODE);
                 
                 END IF;

                 IF TRIM (W_ERR_MSG) IS NOT NULL
                 THEN
                    PKG_EODSOD_FLAGS.PV_ERROR_MSG := W_ERR_MSG;
                 END IF;

                 PKG_PROCESS_CHECK.CHECK_COMMIT_ROLLBACK_STATUS ( V_GLOB_ENTITY_NUM);

                 EXIT WHEN C1%NOTFOUND;

             END LOOP;
               V_DUMMY_INTERNAL_ACNUM.DELETE;
               --31-08-2008-CHANGES
               -- THIS IS FOR HANDLING REAMAINING LAST RECORED IN THE ABOVE LOOP;
               --PROCESS_FOR_INT_CALC (W_BRN_CODE);

               IF TRIM (W_ERR_MSG) IS NOT NULL
               THEN
                  PKG_EODSOD_FLAGS.PV_ERROR_MSG := W_ERR_MSG;
               END IF;

               IF TRIM (PKG_EODSOD_FLAGS.PV_ERROR_MSG) IS NULL
               THEN
                  PKG_PROCESS_CHECK.INSERT_ROW_INTO_EODSODPROCBRN (
                     V_GLOB_ENTITY_NUM,
                     W_BRN_CODE);
               END IF;

               PKG_PROCESS_CHECK.CHECK_COMMIT_ROLLBACK_STATUS (
                  V_GLOB_ENTITY_NUM);
            END IF;
         END LOOP;

         DELETE_STATIC_ARRAY;
         PKG_PROCESS_CHECK.DESTROY_BRN_WISE (V_GLOB_ENTITY_NUM);
      EXCEPTION
         WHEN OTHERS
         THEN
            DELETE_STATIC_ARRAY;
            V_DUMMY_INTERNAL_ACNUM.DELETE;
            PKG_PROCESS_CHECK.DESTROY_BRN_WISE (
               V_GLOB_ENTITY_NUM);
            DESTROY_ARRAYS;

            IF TRIM (W_ERR_MSG) IS NULL
            THEN
               W_ERR_MSG := SUBSTR (SQLERRM, 1, 900);
            END IF;

            IF W_BRN_CODE <> 0
            THEN
               W_ERR_MSG := W_ERR_MSG || ' Process Brn Code ' || W_BRN_CODE;
            END IF;

            PKG_EODSOD_FLAGS.PV_ERROR_MSG := W_ERR_MSG;
            PKG_PB_GLOBAL.DETAIL_ERRLOG (V_GLOB_ENTITY_NUM,
                                         'E',
                                         W_ERR_MSG,
                                         ' ',
                                         0);
      END PROCESSBRNWISE;
   END PROC_BRN_WISE;
END PKG_SNDACCRUALS;
/
