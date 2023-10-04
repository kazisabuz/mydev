CREATE OR REPLACE PACKAGE PKG_SINPROCESS IS

   
    PROCEDURE SP_SINPROCESS(V_ENTITY_NUM IN NUMBER,P_RUN_BRANCH IN NUMBER DEFAULT 0,
                            P_RUN_SIN_NO IN NUMBER DEFAULT 0);

  END PKG_SINPROCESS;
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/

CREATE OR REPLACE PACKAGE BODY PKG_SINPROCESS IS
    PROCEDURE SP_SINPROCESS(V_ENTITY_NUM IN NUMBER,P_RUN_BRANCH IN NUMBER DEFAULT 0,
                            P_RUN_SIN_NO IN NUMBER DEFAULT 0) IS
      PROCEDURE MOVE_EXCEP_ARRAY(V_SINEXCEP_EXCEP_CODE     IN VARCHAR2,
                                 V_SINEXCEP_INVOLVED_ACNUM IN NUMBER,
                                 V_SINEXCEP_EXCEP_CATG     IN CHAR,
                                 V_SINEXCEP_AC_BAL         IN NUMBER,
                                 V_SINEXCEP_REQD_AMT       IN NUMBER,
                                 V_SINEXCEP_ADDN_INFO      IN VARCHAR2 DEFAULT ' ');

      W_PROCESS_SL        NUMBER(6);
      W_CBD               DATE; --CURRENT BUSINES DATE
      W_PWD               DATE; --PREVIOUS WORKING DATE
      W_NWD               DATE; --NEXT WORKING DATE
      W_RUN_TYPE          VARCHAR2(2);
      W_RUN_BRANCH        NUMBER(6);
      W_RUN_SIN_NO        NUMBER(6);
      W_CBD_MONTH_LASTDAY NUMBER(1);
      W_CBD_WEEKDAY       CHAR;
      W_MONTH_LASTDAY     DATE;
      W_DUE_DATE          DATE;
      W_SINDB_EXE_FREQ    CHAR;
      W_LAST_DAY_MONTH    NUMBER(2);
      W_CURR_DATE_DAY     NUMBER(2);
      W_CURR_DATE_MONTH   NUMBER(2);
      W_CURR_DATE_YEAR    NUMBER(5);
      USR_EXCEPTION EXCEPTION;
      W_ERROR                        VARCHAR2(1300);
      W_SINEXECSTAT_STATUS_OF_EXEC   CHAR(1);
      W_HOLIDAY_START_DATE           DATE;
      W_HOLIDAY_END_DATE             DATE;
      W_SINEXECSTAT_NUM_EXEC_ATTMPTS NUMBER(5);
      W_SINSTAT_STATUS               CHAR(1);
      W_SINSTAT_STOP_EXEC_FROM_DT    DATE;
      W_SINSTAT_STOP_EXEC_UPTO_DT    DATE;
      W_SITYPECD_TRIGGER_TYPE        CHAR(1);
      W_TRIGGER_OK                   NUMBER(1);
      V_DUMMY_D                      DATE;
      W_AC_AUTH_BAL                  NUMBER(18,3);
      UNUSED_LIMIT                   NUMBER(18,3);
      W_TOT_LMT_AMT                  NUMBER(18,3);
      W_ACNTS_CLOSURE_DATE           DATE;
      V_DUMMY_N                      NUMBER;
      V_DUMMY_C                      VARCHAR2(30);
      W_SINEXMAP_TARGET_AC_CLOSED    VARCHAR2(6);
      W_SINEXMAP_TARGET_FRZ_ACNT     VARCHAR2(6);
      W_SINEXMAP_SRC_AC_CLOSED       VARCHAR2(6);
      W_SINEXMAP_SRC_FRZ_ACNT        VARCHAR2(6);
      W_SINEXMAP_SRC_INSUFF_FUNDS    VARCHAR2(6);
      W_SINEXMAP_CHGS_AC_CLOSED      VARCHAR2(6);
      W_SINEXMAP_CHGS_FRZ_ACNT       VARCHAR2(6);
      W_SINEXMAP_CHGS_INSUFF_FUNDS   VARCHAR2(8);
      W_EXCEPTION_IND                NUMBER(2);
      W_ABORT_FLAG                   CHAR(1);
      W_SIN_CURR_CODE                VARCHAR2(4);
      W_SIN_AMT                      NUMBER;
      W_TARGET_IND                   NUMBER(2);
      W_SOURCE_IND                   NUMBER(2);
      W_ACNTS_CR_FREEZED             CHAR(1);
      W_ACNTS_CURR_CODE              VARCHAR2(3);
      W_CHARGE_ADD_REQ               BOOLEAN;
      W_OVERDRAWAL_AMT               NUMBER(18,3);
      W_LIMIT_AVL                    CHAR(1);
      W_EACH_AMT                     NUMBER(18,3);
      W_AC_EFFBAL                    NUMBER(18,3);
      W_ACNTS_DB_FREEZED             CHAR(1);
      W_SICHG_SIN_CHG_CODE           VARCHAR(6);
      W_USR_BRN                      NUMBER;
      W_CMNPM_MID_RATE_TYPE_PUR      VARCHAR2(8);
      IDX                            NUMBER(5);
      W_ERR_CODE                     VARCHAR2(10);
      W_BATCH_NUMBER                 NUMBER;
      W_SINEXECLOG_TRY_SERIAL        NUMBER;
      W_REM_AMT                      NUMBER;
      W_SITYPECD_CREDIT_OPTION       VARCHAR(2);
      W_SINREMIT_REM_CODE            VARCHAR2(6);
      W_SINREMIT_DESP_MODE           CHAR(1);
      W_SINREMIT_REM_CURR            VARCHAR2(4);
      W_SINREMIT_REM_AMT             NUMBER;
      W_SITYPECD_TRAN_CODE           VARCHAR2(6);
      W_REMIT_ACCNUM                 NUMBER(14);
      W_CHARGE_AMOUNT_REMIT          NUMBER;
      W_SERVICE_AMOUNT_REMIT         NUMBER;
      W_SINREMIT_BENEF_CODE          VARCHAR(6);
      W_SINREMIT_BENF_NAME           VARCHAR2(50);
      W_SINREMIT_BENF_NAME1          VARCHAR2(65);
      W_SINREMIT_ON_ACCOUNT_OF       VARCHAR2(65);
      W_SINREMIT_DRAWN_BANK          VARCHAR2(6);
      W_SINREMIT_DRAWN_BRN           VARCHAR2(6);
      W_DDPOKEY                      VARCHAR2(35); --CHG ARUN 21-11-2007

      TYPE TY_SINDB_REC IS RECORD(
        V_SINDB_BRN_CODE            NUMBER(6),
        V_SINDB_SIN_NUM             NUMBER(8),
        V_SINDB_EXE_FREQ            CHAR(1),
        V_SINDB_START_DATE          DATE,
        V_SINDB_END_DATE            DATE,
        V_SINDB_WEEK_DAY            CHAR(1),
        V_SINDB_FORTNIGHT1          NUMBER(2),
        V_SINDB_FORTNIGHT2          NUMBER(2),
        V_SINDB_MON_DAY_CHOICE      CHAR(1),
        V_SINDB_MONTHLY_DAY         NUMBER(2),
        V_SINDB_MON_EXE_WEEKDAY     CHAR(1),
        V_SINDB_WEEK_SEQ_MON        NUMBER(1),
        V_SINDB_QHY_FREQ_MONTH      NUMBER(2),
        V_SINDB_QHY_FREQ_DAY        NUMBER(2),
        V_SINDB_HOLIDAY_CHOICE      CHAR(1),
        V_SINDB_TIME_CHOICE         CHAR(1),
        V_SINDB_EXEC_FAILURE_DAYS   NUMBER(2),
        V_SINDB_SI_TYPE             VARCHAR(6),
        V_SINDB_TRIGGER_CHK_ACNUM   NUMBER(14),
        V_SINDB_TRIGGER_AMT         NUMBER(18, 3),
        V_SINDB_BAL_TRIGGER_CHOICE  CHAR(1),
        V_SINDB_DISPOSAL_CURR       VARCHAR2(3),
        V_SINDB_DISPOSAL_TYPE       CHAR(1),
        V_SINDB_FIXED_AMT           NUMBER(18, 3),
        V_SINDB_FLOAT_AMT_CHOICE    CHAR(1),
        V_SINDB_RND_OFF_AMT_CHOICE  CHAR(1),
        V_SINDB_RND_OFF_FACTOR      NUMBER(9, 3),
        V_SINDB_SPECIFIED_BAL_AMT   NUMBER(18, 3),
        V_SINDB_CUT_OFF_BAL_SRC_AMT NUMBER(18, 3),
        V_SINDB_CHGS_RECOV_ACNUM    NUMBER(14),
        V_SINDB_REM_NOTES1          VARCHAR(35),
        V_SINDB_REM_NOTES2          VARCHAR(35),
        V_SINDB_REM_NOTES3          VARCHAR(35),
        V_SINDB_UAGENCY_PAYMENT     CHAR(1),
        V_SINDB_CLIENT_NUM          NUMBER(12));

      TYPE TAB_SINDB_REC IS TABLE OF TY_SINDB_REC INDEX BY PLS_INTEGER;
      SINDB_REC TAB_SINDB_REC;

      TYPE TY_EXCEP_ARRAY IS RECORD(
        EXCP_IND           NUMBER(2),
        EXCP_CODE          VARCHAR(6),
        EXCP_ACCNUM        NUMBER(14),
        EXCP_ACCBAL        NUMBER(18, 3),
        EXCP_REQAMO        NUMBER(18, 3),
        EXCP_SININTCAT     NUMBER(1),
        SINEXCEP_ADDN_INFO VARCHAR2(65) DEFAULT ' ');

      TYPE TAB_EXCEP_ARRAY IS TABLE OF TY_EXCEP_ARRAY INDEX BY PLS_INTEGER;

      EXCEP_ARRAY TAB_EXCEP_ARRAY;

      TYPE TY_ACC_DTL_ARRAY IS RECORD(
        ACC_DTL_SERIAL NUMBER(2),
        ACC_DTL_ACCNUM NUMBER(14),
        ACC_DTL_AMT    NUMBER(18, 3));

      TYPE TAB_ACC_DTL_ARRAY IS TABLE OF TY_ACC_DTL_ARRAY INDEX BY PLS_INTEGER;
      SOUCRCE_ACC_DTL TAB_ACC_DTL_ARRAY;
      TARGET_ACC_DTL  TAB_ACC_DTL_ARRAY;

      PROCEDURE CHECK_DORMANT_INOPERATIVE(W_EXCEP_CATG IN NUMBER) IS
        W_SINEXMAP_CODE VARCHAR2(6);
      BEGIN
        IF W_EXCEP_CATG = 1 THEN
          W_SINEXMAP_CODE := W_SINEXMAP_TARGET_FRZ_ACNT;
        ELSIF W_EXCEP_CATG = 2 THEN
          W_SINEXMAP_CODE := W_SINEXMAP_SRC_FRZ_ACNT;
        ELSIF W_EXCEP_CATG = 3 THEN
          W_SINEXMAP_CODE := W_SINEXMAP_CHGS_FRZ_ACNT;
        END IF;

        IF PKG_ACNTS_VALID.P_ACNTS_INOP_ACNT = '1' THEN
          MOVE_EXCEP_ARRAY(W_SINEXMAP_CODE,
                           PKG_ACNTS_VALID.P_ACNTS_INTERNAL_ACNUM,
                           W_EXCEP_CATG,
                           0,
                           0,
                           'Inoperative Account');
        END IF;
        IF PKG_ACNTS_VALID.P_ACNTS_DORMANT_ACNT = '1' THEN
          MOVE_EXCEP_ARRAY(W_SINEXMAP_CODE,
                           PKG_ACNTS_VALID.P_ACNTS_INTERNAL_ACNUM,
                           W_EXCEP_CATG,
                           0,
                           0,
                           'Dormant Account');
        END IF;
      END CHECK_DORMANT_INOPERATIVE;

      FUNCTION SP_GET_SIN_NUMBER RETURN VARCHAR2 IS
        W_ERR_STR VARCHAR2(200);
      BEGIN
        W_ERR_STR := '';
        <<READSINARRAY>>
        BEGIN
          W_ERR_STR := 'Sin Branch Code = ' || SINDB_REC(W_PROCESS_SL) .
                       V_SINDB_BRN_CODE || ' Sin Number = ' ||
                       SINDB_REC(W_PROCESS_SL) . V_SINDB_SIN_NUM;
        EXCEPTION
          WHEN OTHERS THEN
            W_ERR_STR := '';
        END READSINARRAY;
        RETURN W_ERR_STR;
      END SP_GET_SIN_NUMBER;

      PROCEDURE MOVE_EXCEP_ARRAY(V_SINEXCEP_EXCEP_CODE     IN VARCHAR2,
                                 V_SINEXCEP_INVOLVED_ACNUM IN NUMBER,
                                 V_SINEXCEP_EXCEP_CATG     IN CHAR,
                                 V_SINEXCEP_AC_BAL         IN NUMBER,
                                 V_SINEXCEP_REQD_AMT       IN NUMBER,
                                 V_SINEXCEP_ADDN_INFO      IN VARCHAR2 DEFAULT ' ') IS
      BEGIN
        W_EXCEPTION_IND := W_EXCEPTION_IND + 1;
        EXCEP_ARRAY(W_EXCEPTION_IND).EXCP_IND := W_EXCEPTION_IND;
        EXCEP_ARRAY(W_EXCEPTION_IND).EXCP_CODE := V_SINEXCEP_EXCEP_CODE;
        EXCEP_ARRAY(W_EXCEPTION_IND).EXCP_ACCNUM := V_SINEXCEP_INVOLVED_ACNUM;
        EXCEP_ARRAY(W_EXCEPTION_IND).EXCP_ACCBAL := V_SINEXCEP_AC_BAL;
        EXCEP_ARRAY(W_EXCEPTION_IND).EXCP_REQAMO := V_SINEXCEP_REQD_AMT;
        EXCEP_ARRAY(W_EXCEPTION_IND).EXCP_SININTCAT := V_SINEXCEP_EXCEP_CATG;
        EXCEP_ARRAY(W_EXCEPTION_IND).SINEXCEP_ADDN_INFO := V_SINEXCEP_ADDN_INFO;
      END MOVE_EXCEP_ARRAY;

      --************************************************************************************************
      PROCEDURE INIT_PARA IS --USING INITILIZE ALL THE VARIABLES
      BEGIN
        W_CBD                        := NULL;
        W_PWD                        := NULL;
        W_NWD                        := NULL;
        W_RUN_TYPE                   := NULL;
        W_RUN_BRANCH                 := 0;
        W_RUN_SIN_NO                 := 0;
        W_CBD_MONTH_LASTDAY          := 0;
        W_CBD_WEEKDAY                := 0;
        W_MONTH_LASTDAY              := NULL;
        W_LAST_DAY_MONTH             := 0;
        W_CURR_DATE_DAY              := 0;
        W_CURR_DATE_MONTH            := 0;
        W_CURR_DATE_YEAR             := 0;
        W_ERROR                      := NULL;
        W_SINEXMAP_TARGET_AC_CLOSED  := NULL;
        W_SINEXMAP_TARGET_FRZ_ACNT   := NULL;
        W_SINEXMAP_SRC_AC_CLOSED     := NULL;
        W_SINEXMAP_SRC_FRZ_ACNT      := NULL;
        W_SINEXMAP_SRC_INSUFF_FUNDS  := NULL;
        W_SINEXMAP_CHGS_AC_CLOSED    := NULL;
        W_SINEXMAP_CHGS_FRZ_ACNT     := NULL;
        W_SINEXMAP_CHGS_INSUFF_FUNDS := NULL;
        W_USR_BRN                    := 0;
        W_CMNPM_MID_RATE_TYPE_PUR    := NULL;
      END INIT_PARA;
      --************************************************************************************************
      PROCEDURE CHECK_INPUT IS --CHECK AND ASSIGN INPUT VALUES
      BEGIN
        W_CBD      := PKG_EODSOD_FLAGS.PV_CURRENT_DATE;
        W_RUN_TYPE := PKG_EODSOD_FLAGS.PV_EODSODFLAG;
        IF (P_RUN_BRANCH <> 0) THEN
          W_RUN_BRANCH := P_RUN_BRANCH;
        END IF;
        IF (P_RUN_SIN_NO <> 0) THEN
          W_RUN_SIN_NO := P_RUN_SIN_NO;
        END IF;
      END CHECK_INPUT;
      --************************************************************************************************
      PROCEDURE ASSIGN_DATES IS --ASSIGN PREVIOUS AND NEXT WORKING DAYS.
      BEGIN
        W_CBD_WEEKDAY := TO_CHAR(W_CBD,'D'); --GET WEEKDAY OF CURRENT BUSINESS DATE
        SELECT MN_PREV_BUSINESS_DATE INTO W_PWD FROM MAINCONT WHERE MN_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE ; --PREVIOUS WORKING DATE
        W_NWD             := PKG_PB_GLOBAL.FN_NEXTWORKINGDAY(PKG_ENTITY.FN_GET_ENTITY_CODE,0,W_CBD); --NECT WORKING DATE
        W_MONTH_LASTDAY   := LAST_DAY(W_CBD); --LAST DATE OF MONTH
        W_LAST_DAY_MONTH  := TO_CHAR(LAST_DAY(W_CBD),'DD'); --LAST DAY(DD) OF GIVEN CURRENT BUSINES DATE MONTH.
        W_CURR_DATE_DAY   := TO_CHAR(W_CBD,'DD'); --DAY FOR CURRENT BUSINESS DATE
        W_CURR_DATE_MONTH := TO_CHAR(W_CBD,'MM'); --MONTH FOR CURRENT BUSINESS DATE
        W_CURR_DATE_YEAR  := TO_CHAR(W_CBD,'YYYY'); --YEAR FOR CURRENT BUSINESS DATE
        IF (W_CBD = W_MONTH_LASTDAY) THEN
          W_CBD_MONTH_LASTDAY := 1;
        ELSE
          W_CBD_MONTH_LASTDAY := 0;
        END IF;
      END ASSIGN_DATES;
      --************************************************************************************************
      PROCEDURE READ_SINEXMAP IS --READ STANDARD INSTRUCTION EXCEPTION CODE MAP
      BEGIN
        SELECT SINEXMAP_TARGET_AC_CLOSED,
               SINEXMAP_TARGET_FRZ_ACNT,
               SINEXMAP_SRC_AC_CLOSED,
               SINEXMAP_SRC_FRZ_ACNT,
               SINEXMAP_SRC_INSUFF_FUNDS,
               SINEXMAP_CHGS_AC_CLOSED,
               SINEXMAP_CHGS_FRZ_ACNT,
               SINEXMAP_CHGS_INSUFF_FUNDS
          INTO W_SINEXMAP_TARGET_AC_CLOSED,
               W_SINEXMAP_TARGET_FRZ_ACNT,
               W_SINEXMAP_SRC_AC_CLOSED,
               W_SINEXMAP_SRC_FRZ_ACNT,
               W_SINEXMAP_SRC_INSUFF_FUNDS,
               W_SINEXMAP_CHGS_AC_CLOSED,
               W_SINEXMAP_CHGS_FRZ_ACNT,
               W_SINEXMAP_CHGS_INSUFF_FUNDS
          FROM SINEXMAP;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          W_ERROR := 'NO_DATA FOUND IN SINEXMAP';
          RAISE USR_EXCEPTION;
      END READ_SINEXMAP;
      --************************************************************************************************
      PROCEDURE READ_USER_BRANCH IS
      BEGIN
        SELECT USER_BRANCH_CODE
          INTO W_USR_BRN
          FROM USERS
         WHERE USER_ID = PKG_EODSOD_FLAGS.PV_USER_ID;
      END READ_USER_BRANCH;
      --************************************************************************************************
      PROCEDURE READ_CMNPARAM IS
      BEGIN
        SELECT CMNPM_MID_RATE_TYPE_PUR
          INTO W_CMNPM_MID_RATE_TYPE_PUR
          FROM CMNPARAM;
      END READ_CMNPARAM;
      --************************************************************************************************
      PROCEDURE INIT_LOOP_VARIABLE IS -- INITIALIZE LOOP VARIABLES
      BEGIN
        W_CHARGE_ADD_REQ               := FALSE;
        W_DUE_DATE                     := NULL;
        W_SINDB_EXE_FREQ               := NULL;
        W_SINEXECSTAT_STATUS_OF_EXEC   := NULL;
        W_HOLIDAY_START_DATE           := NULL;
        W_HOLIDAY_END_DATE             := NULL;
        W_SINEXECSTAT_NUM_EXEC_ATTMPTS := 0;
        W_SINSTAT_STATUS               := NULL;
        W_SINSTAT_STOP_EXEC_FROM_DT    := NULL;
        W_SINSTAT_STOP_EXEC_UPTO_DT    := NULL;
        W_TRIGGER_OK                   := 0;
        W_ACNTS_CLOSURE_DATE           := NULL;
        V_DUMMY_N                      := 0;
        V_DUMMY_C                      := NULL;
        W_TOT_LMT_AMT                  := 0;
        W_EXCEPTION_IND                := 0;
        W_ABORT_FLAG                   := NULL;
        W_SIN_CURR_CODE                := NULL;
        W_SIN_AMT                      := 0;
        W_TARGET_IND                   := 0;
        W_SOURCE_IND                   := 0;
        W_SITYPECD_TRAN_CODE           := '';
        W_CHARGE_AMOUNT_REMIT          := 0;
        W_SERVICE_AMOUNT_REMIT         := 0;
        W_SINREMIT_BENEF_CODE          := '';
        W_SINREMIT_BENF_NAME           := '';
        W_SINREMIT_BENF_NAME1          := '';
        W_SINREMIT_ON_ACCOUNT_OF       := '';
        W_SINREMIT_DRAWN_BANK          := '';
        W_SINREMIT_DRAWN_BRN           := '';
        W_DDPOKEY                      := ' '; --CHG ARUN 21-11-2007
      END INIT_LOOP_VARIABLE;
      --************************************************************************************************
      PROCEDURE WEEKLY_DUE_DATE(WEEKDAY_SIN IN CHAR) IS
        --FIND WEEKLY DUE DATE
        W_WEEKDAY1 CHAR;
        W_WEEKDAY2 CHAR;
      BEGIN
        W_WEEKDAY1 := W_CBD_WEEKDAY;
        W_WEEKDAY2 := WEEKDAY_SIN;
        W_DUE_DATE := W_CBD + (TO_NUMBER(W_WEEKDAY2) - TO_NUMBER(W_WEEKDAY1));
        -- IF(TO_NUMBER(W_WEEKDAY2) =TO_NUMBER(W_WEEKDAY1)) THEN
        --     RETURN W_CBD;
        -- ELSIF(TO_NUMBER(W_WEEKDAY2) =TO_NUMBER(W_WEEKDAY1))  THEN
        --  RETURN W_CBD + (TO_NUMBER(W_WEEKDAY2) -TO_NUMBER(W_WEEKDAY1));
        -- ELSE
        --   RETURN W_CBD + (TO_NUMBER(W_WEEKDAY1) -TO_NUMBER(W_WEEKDAY2));
        -- END IF;
        --IF(W_WEEKDAY2 >= W_WEEKDAY2) THEN
        --END IF;
      END WEEKLY_DUE_DATE;
      --************************************************************************************************
      FUNCTION FIND_DUEDAYS(GIVENDAY IN NUMBER) RETURN DATE IS
        W1_DUE_DATE DATE;
      BEGIN
        IF (GIVENDAY = 0) THEN
          W1_DUE_DATE := W_MONTH_LASTDAY;
        ELSE
          IF (GIVENDAY > W_LAST_DAY_MONTH) THEN
            W1_DUE_DATE := W_MONTH_LASTDAY;
          ELSE
            W1_DUE_DATE := TO_DATE(GIVENDAY || TO_CHAR(W_CBD,'-MM-YY'),
                                   'DD-MM-YY');
          END IF;
        END IF;
        RETURN W1_DUE_DATE;
      END FIND_DUEDAYS;
      --************************************************************************************************
      FUNCTION FIND_DUEDAYESWITHDATE(GIVENDAY IN NUMBER,GIVENDATE IN DATE)
        RETURN DATE IS
        W1_DUE_DATE DATE;
        WL_DAY      NUMBER(2);
      BEGIN
        IF (GIVENDAY = 0) THEN
          W1_DUE_DATE := LAST_DAY(GIVENDATE);
        ELSE
          WL_DAY := TO_CHAR(LAST_DAY(GIVENDATE),'DD');
          IF (GIVENDAY > WL_DAY) THEN
            W1_DUE_DATE := LAST_DAY(GIVENDATE);
          ELSE
            W1_DUE_DATE := TO_DATE(GIVENDAY || TO_CHAR(GIVENDATE,'-MM-YY'),
                                   'DD-MM-YY');
          END IF;
        END IF;
        RETURN W1_DUE_DATE;
      END FIND_DUEDAYESWITHDATE;
      --************************************************************************************************
      FUNCTION FIND_DUEANOTHERDAYS(GIVENDAY   IN NUMBER,
                                   WW_1_MONTH IN NUMBER,
                                   WW_1_YEAR  IN NUMBER) RETURN DATE IS
        W2_DUE_DATE DATE;
        WL_DAY      NUMBER(2);
      BEGIN
        IF (GIVENDAY = 0) THEN
          W2_DUE_DATE := LAST_DAY(TO_DATE('01 -' || WW_1_MONTH || '-' ||
                                          WW_1_YEAR,
                                          'DD-MM-YYYY'));
        ELSE
          WL_DAY := TO_CHAR(LAST_DAY(TO_DATE('01-' || WW_1_MONTH || '-' ||
                                             WW_1_YEAR,
                                             'DD-MM-YYYY')),
                            'DD');
          IF (GIVENDAY > WL_DAY) THEN
            W2_DUE_DATE := LAST_DAY(TO_DATE('01 -' || WW_1_MONTH || '-' ||
                                            WW_1_YEAR,
                                            'DD-MM-YYYY'));
          ELSE
            W2_DUE_DATE := TO_DATE(GIVENDAY || '-' || WW_1_MONTH || '-' ||
                                   WW_1_YEAR,
                                   'DD-MM-YYYY');
          END IF;
        END IF;
        RETURN W2_DUE_DATE;
      END FIND_DUEANOTHERDAYS;
      --************************************************************************************************
      PROCEDURE FORTNIGHTLY_DUE_DATE(FDAY1 IN NUMBER,FDAY2 IN NUMBER) IS
        --FIND FORTNIGHTLY DUE DATE
        W_DUE_DATE1 DATE;
        W_DUE_DATE2 DATE;
        DIFF1       NUMBER(3);
        DIFF2       NUMBER(3);
        W_1_MONTH   NUMBER(2);
        W_1_YEAR    NUMBER(5);
      BEGIN
        W_DUE_DATE1 := FIND_DUEDAYS(FDAY1); -- FIND FOURTNIGHT DAY#1
        W_DUE_DATE2 := FIND_DUEDAYS(FDAY2); -- FIND FOURTNIGHT DAY#2
        IF (W_DUE_DATE1 < W_CBD) THEN
          DIFF1 := W_CBD - W_DUE_DATE;
        ELSE
          DIFF1 := W_DUE_DATE1 - W_CBD;
        END IF;
        IF (W_DUE_DATE2 < W_CBD) THEN
          DIFF2 := W_CBD - W_DUE_DATE2;
        ELSE
          DIFF2 := W_DUE_DATE2 - W_CBD;
        END IF;
        IF (DIFF1 > DIFF2) THEN
          W_DUE_DATE := W_DUE_DATE2;
        ELSE
          W_DUE_DATE := W_DUE_DATE1;
        END IF;
        W_1_MONTH := W_CURR_DATE_MONTH;
        W_1_YEAR  := W_CURR_DATE_YEAR;
        IF (W_CURR_DATE_DAY <= 7) THEN
          IF (W_1_MONTH = 1) THEN
            W_1_MONTH := 12;
            W_1_YEAR  := W_1_YEAR - 1;
          ELSE
            W_1_MONTH := W_1_MONTH - 1;
          END IF;
          W_DUE_DATE2 := FIND_DUEANOTHERDAYS(FDAY2,W_1_MONTH,W_1_YEAR);
        ELSE
          IF (W_1_MONTH = 12) THEN
            W_1_MONTH := 1;
            W_1_YEAR  := W_1_YEAR + 1;
          ELSE
            W_1_MONTH := W_1_MONTH + 1;
          END IF;
          W_DUE_DATE2 := FIND_DUEANOTHERDAYS(FDAY1,W_1_MONTH,W_1_YEAR);
        END IF;
        IF (W_DUE_DATE < W_CBD) THEN
          DIFF1 := W_CBD - W_DUE_DATE;
        ELSE
          DIFF1 := W_DUE_DATE - W_CBD;
        END IF;
        IF (W_DUE_DATE2 < W_CBD) THEN
          DIFF2 := W_CBD - W_DUE_DATE2;
        ELSE
          DIFF2 := W_DUE_DATE2 - W_CBD;
        END IF;
        IF (DIFF1 > DIFF2) THEN
          W_DUE_DATE := W_DUE_DATE2;
        END IF;
      END FORTNIGHTLY_DUE_DATE;
      --************************************************************************************************
      FUNCTION MON_WEEK_SEQ_DAY_DUEDATE(WW_MONTH           IN NUMBER,
                                        WW_YEAR            IN NUMBER,
                                        WW_MON_EXE_WEEKDAY IN CHAR,
                                        WW_WEEK_SEQ_MON    IN NUMBER)
        RETURN DATE IS
        W_WEEKDAY1  CHAR;
        W_WEEKDAY2  CHAR;
        DIFF        NUMBER(2);
        W_TEMP_DATE DATE;
        W_COUNT     NUMBER(2);
        WW_DUE_DATE DATE;
      BEGIN
        WW_DUE_DATE := TO_DATE('01-' || WW_MONTH || '-' || WW_YEAR,
                               'DD-MM-YYYY');
        W_WEEKDAY1  := TO_CHAR(WW_DUE_DATE,'D');
        W_WEEKDAY2  := WW_MON_EXE_WEEKDAY;
        IF (TO_NUMBER(W_WEEKDAY2) >= TO_NUMBER(W_WEEKDAY1)) THEN
          DIFF := TO_NUMBER(W_WEEKDAY2) - TO_NUMBER(W_WEEKDAY1);
        ELSE
          DIFF := 7 + TO_NUMBER(W_WEEKDAY2) - TO_NUMBER(W_WEEKDAY1);
        END IF;
        WW_DUE_DATE := WW_DUE_DATE + DIFF;
        IF (WW_WEEK_SEQ_MON = 0) THEN
          WHILE (TO_NUMBER(TO_CHAR(WW_DUE_DATE,'MM')) = WW_MONTH AND
                TO_NUMBER(TO_CHAR(WW_DUE_DATE,'YYYY')) = WW_YEAR) LOOP
            W_TEMP_DATE := WW_DUE_DATE;
            WW_DUE_DATE := WW_DUE_DATE + 7;
          END LOOP;
          WW_DUE_DATE := W_TEMP_DATE;
        ELSE
          W_COUNT := WW_WEEK_SEQ_MON;
          W_COUNT := W_COUNT - 1;
          WHILE (W_COUNT > 0) LOOP
            WW_DUE_DATE := WW_DUE_DATE + 7;
            W_COUNT     := W_COUNT - 1;
          END LOOP;
          IF (NOT (TO_NUMBER(TO_CHAR(WW_DUE_DATE,'MM')) = WW_MONTH AND
              TO_NUMBER(TO_CHAR(WW_DUE_DATE,'YYYY')) = WW_YEAR)) THEN
            WW_DUE_DATE := NULL;
          END IF;
        END IF;
        RETURN WW_DUE_DATE;
      END MON_WEEK_SEQ_DAY_DUEDATE;
      --************************************************************************************************
      FUNCTION CHECKHOLDAYS(START_DAY IN DATE,END_DAY IN DATE) RETURN BOOLEAN IS
        TEMP_DATE DATE;
      BEGIN
        TEMP_DATE := START_DAY;
        WHILE (TEMP_DATE <= END_DAY) LOOP
          IF (PKG_PB_GLOBAL.FN_BRNDATEHOLIDAY(PKG_ENTITY.FN_GET_ENTITY_CODE,0,TEMP_DATE) <> 1) THEN
            RETURN FALSE;
          END IF;
          TEMP_DATE := TEMP_DATE + 1;
        END LOOP;
        RETURN TRUE;
      END CHECKHOLDAYS;
      --************************************************************************************************
      PROCEDURE MONTHLY_DUE_DATE(MON_CHOICE      IN CHAR,
                                 MON_DAY         IN NUMBER,
                                 MON_EXE_WEEKDAY IN CHAR,
                                 WEEK_SEQ_MON    IN NUMBER) IS
        --FIND MONTHLY DUE DATE
        W_DUE_DATE1 DATE;
        W_DUE_DATE2 DATE;
        W_1_MONTH   NUMBER(2);
        W_1_YEAR    NUMBER(5);
        DIFF1       NUMBER(3);
        DIFF2       NUMBER(3);
        --****************************------------
        PROCEDURE DATEGREAT23 IS
        BEGIN
          IF (W_CURR_DATE_DAY >= 23) THEN
            IF (W_1_MONTH = 12) THEN
              W_1_YEAR  := W_1_YEAR + 1;
              W_1_MONTH := 1;
            ELSE
              W_1_MONTH := W_1_MONTH + 1;
            END IF;
          ELSE
            IF (W_1_MONTH = 1) THEN
              W_1_YEAR  := W_1_YEAR - 1;
              W_1_MONTH := 12;
            ELSE
              W_1_MONTH := W_1_MONTH - 1;
            END IF;
          END IF;
        END DATEGREAT23;
        --*****************************-----------------
      BEGIN
  --ENTITY CODE COMMONLY ADDED - 06-11-2009  - BEG
          PKG_ENTITY.SP_SET_ENTITY_CODE(V_ENTITY_NUM);
  --ENTITY CODE COMMONLY ADDED - 06-11-2009  - END
        IF (MON_CHOICE = 1) THEN
          --FIXED DAY FOR EACH MONTH
          W_DUE_DATE1 := FIND_DUEDAYS(MON_DAY);
          W_1_YEAR    := W_CURR_DATE_YEAR;
          W_1_MONTH   := W_CURR_DATE_MONTH;
          DATEGREAT23; --CHECK DATE IS GRAEATER THEN 23 PROCESS
          W_DUE_DATE2 := FIND_DUEANOTHERDAYS(MON_DAY,W_1_MONTH,W_1_YEAR);
        ELSE
          --SPECIFIC WEEK DAY
          W_DUE_DATE1 := MON_WEEK_SEQ_DAY_DUEDATE(W_CURR_DATE_MONTH,
                                                  W_CURR_DATE_YEAR,
                                                  MON_EXE_WEEKDAY,
                                                  WEEK_SEQ_MON);
          W_1_YEAR    := W_CURR_DATE_YEAR;
          W_1_MONTH   := W_CURR_DATE_MONTH;
          DATEGREAT23; --CHECK DATE IS GRAEATER THEN 23 PROCESS
          W_DUE_DATE2 := MON_WEEK_SEQ_DAY_DUEDATE(W_1_MONTH,
                                                  W_1_YEAR,
                                                  MON_EXE_WEEKDAY,
                                                  WEEK_SEQ_MON);
        END IF;
        IF (W_DUE_DATE1 < W_CBD) THEN
          DIFF1 := W_CBD - W_DUE_DATE1;
        ELSE
          DIFF1 := W_DUE_DATE1 - W_CBD;
        END IF;
        IF (W_DUE_DATE2 < W_CBD) THEN
          DIFF2 := W_CBD - W_DUE_DATE2;
        ELSE
          DIFF2 := W_DUE_DATE2 - W_CBD;
        END IF;
        IF (DIFF1 > DIFF2) THEN
          W_DUE_DATE := W_DUE_DATE2;
        ELSE
          W_DUE_DATE := W_DUE_DATE1;
        END IF;
      END MONTHLY_DUE_DATE;
      --************************************************************************************************
      FUNCTION QHY_DUE_DATESDIFF(WW_YEAR          IN NUMBER,
                                 WW_QTR           IN NUMBER,
                                 W_QHY_FREQ_MONTH IN NUMBER,
                                 W_QHY_FREQ_DAY   IN NUMBER,
                                 W_QHY            IN CHAR) RETURN DATE IS
        WW_DUE_DATE DATE;
      BEGIN
        IF (W_QHY = 'Q') THEN
          IF (WW_QTR = 1) THEN
            WW_DUE_DATE := TO_DATE('01-01-' || WW_YEAR,'DD-MM-YYYY');
          ELSIF (WW_QTR = 2) THEN
            WW_DUE_DATE := TO_DATE('01-04-' || WW_YEAR,'DD-MM-YYYY');
          ELSIF (WW_QTR = 3) THEN
            WW_DUE_DATE := TO_DATE('01-07-' || WW_YEAR,'DD-MM-YYYY');
          ELSE
            WW_DUE_DATE := TO_DATE('01-10-' || WW_YEAR,'DD-MM-YYYY');
          END IF;
        ELSIF (W_QHY = 'H') THEN
          IF (WW_QTR = 1) THEN
            WW_DUE_DATE := TO_DATE('01-01-' || WW_YEAR,'DD-MM-YYYY');
          ELSE
            WW_DUE_DATE := TO_DATE('01-07-' || WW_YEAR,'DD-MM-YYYY');
          END IF;
        ELSIF (W_QHY = 'Y') THEN
          WW_DUE_DATE := TO_DATE('01-01-' || WW_YEAR,'DD-MM-YYYY');
        END IF;

        WW_DUE_DATE := ADD_MONTHS(WW_DUE_DATE,W_QHY_FREQ_MONTH - 1);
        WW_DUE_DATE := FIND_DUEDAYESWITHDATE(W_QHY_FREQ_DAY,WW_DUE_DATE);
        RETURN WW_DUE_DATE;
      END QHY_DUE_DATESDIFF;

      --************************************************************************************************

      PROCEDURE QUARTERLY_DUE_DATE(QHY_FREQ_MONTH IN NUMBER,
                                   QHY_FREQ_DAY   IN NUMBER) IS
        W_CUR_QTR      NUMBER(2);
        W_QTR_BEG_DATE DATE;
        NOD            NUMBER(2);
        W_1_YEAR       NUMBER(5);
        W_1_QTR        NUMBER(1);
        W_2_YEAR       NUMBER(5);
        W_2_QTR        NUMBER(1);
        W_DUE_DATE1    DATE;
        W_DUE_DATE2    DATE;
        DIFF1          NUMBER(3);
        DIFF2          NUMBER(3);
      BEGIN
        IF (W_CURR_DATE_MONTH < 4) THEN
          W_CUR_QTR      := 1;
          W_QTR_BEG_DATE := TO_DATE('01-01-' || W_CURR_DATE_YEAR,'DD-MM-YYYY');
        ELSIF (W_CURR_DATE_MONTH < 7) THEN
          W_CUR_QTR      := 2;
          W_QTR_BEG_DATE := TO_DATE('01-04-' || W_CURR_DATE_YEAR,'DD-MM-YYYY');
        ELSIF (W_CURR_DATE_MONTH < 10) THEN
          W_CUR_QTR      := 3;
          W_QTR_BEG_DATE := TO_DATE('01-07-' || W_CURR_DATE_YEAR,'DD-MM-YYYY');
        ELSE
          W_CUR_QTR      := 4;
          W_QTR_BEG_DATE := TO_DATE('01-10-' || W_CURR_DATE_YEAR,'DD-MM-YYYY');
        END IF;
        NOD      := W_CBD - W_QTR_BEG_DATE;
        W_1_YEAR := W_CURR_DATE_YEAR;
        W_1_QTR  := W_CUR_QTR;
        W_2_YEAR := W_CURR_DATE_YEAR;
        W_2_QTR  := W_CUR_QTR;
        IF (NOD < 7) THEN
          IF (W_1_QTR = 1) THEN
            W_1_YEAR := W_1_YEAR - 1;
            W_1_QTR  := 4;
          ELSE
            W_1_QTR := W_1_QTR - 1;
          END IF;
        ELSE
          IF (W_2_QTR = 4) THEN
            W_2_YEAR := W_2_YEAR + 1;
            W_2_QTR  := 1;
          ELSE
            W_2_QTR := W_2_QTR + 1;
          END IF;
        END IF;
        W_DUE_DATE1 := QHY_DUE_DATESDIFF(W_1_YEAR,
                                         W_1_QTR,
                                         QHY_FREQ_MONTH,
                                         QHY_FREQ_DAY,
                                         'Q');
        W_DUE_DATE2 := QHY_DUE_DATESDIFF(W_2_YEAR,
                                         W_2_QTR,
                                         QHY_FREQ_MONTH,
                                         QHY_FREQ_DAY,
                                         'Q');
        IF (W_DUE_DATE1 < W_CBD) THEN
          DIFF1 := W_CBD - W_DUE_DATE1;
        ELSE
          DIFF1 := W_DUE_DATE1 - W_CBD;
        END IF;
        IF (W_DUE_DATE2 < W_CBD) THEN
          DIFF2 := W_CBD - W_DUE_DATE2;
        ELSE
          DIFF2 := W_DUE_DATE2 - W_CBD;
        END IF;
        IF (DIFF1 > DIFF2) THEN
          W_DUE_DATE := W_DUE_DATE2;
        ELSE
          W_DUE_DATE := W_DUE_DATE1;
        END IF;
      END QUARTERLY_DUE_DATE;
      --************************************************************************************************

      PROCEDURE HALFYEARLY_DUE_DATE(QHY_FREQ_MONTH IN NUMBER,
                                    QHY_FREQ_DAY   IN NUMBER) IS
        W_CUR_HALF     NUMBER(2);
        W_HLF_BEG_DATE DATE;
        NOD            NUMBER(3);
        W_1_YEAR       NUMBER(5);
        W_1_HALF       NUMBER(1);
        W_2_YEAR       NUMBER(5);
        W_2_HALF       NUMBER(1);
        W_DUE_DATE1    DATE;
        W_DUE_DATE2    DATE;
        DIFF1          NUMBER(3);
        DIFF2          NUMBER(3);
      BEGIN
        IF (W_CURR_DATE_MONTH < 7) THEN
          W_CUR_HALF     := 1;
          W_HLF_BEG_DATE := TO_DATE('01-01-' || W_CURR_DATE_YEAR,'DD-MM-YYYY');
        ELSE
          W_CUR_HALF     := 2;
          W_HLF_BEG_DATE := TO_DATE('01-07-' || W_CURR_DATE_YEAR,'DD-MM-YYYY');
        END IF;
        NOD      := W_CBD - W_HLF_BEG_DATE;
        W_1_YEAR := W_CURR_DATE_YEAR;
        W_1_HALF := W_CUR_HALF;
        W_2_YEAR := W_CURR_DATE_YEAR;
        W_2_HALF := W_CUR_HALF;
        IF (NOD < 7) THEN
          IF (W_1_HALF = 1) THEN
            W_1_YEAR := W_1_YEAR - 1;
            W_1_HALF := 2;
          ELSE
            W_1_HALF := W_1_HALF - 1;
          END IF;
        ELSE
          IF (W_2_HALF = 2) THEN
            W_2_YEAR := W_2_YEAR + 1;
            W_2_HALF := 1;
          ELSE
            W_2_HALF := W_2_HALF + 1;
          END IF;
        END IF;
        W_DUE_DATE1 := QHY_DUE_DATESDIFF(W_1_YEAR,
                                         W_1_HALF,
                                         QHY_FREQ_MONTH,
                                         QHY_FREQ_DAY,
                                         'H');
        W_DUE_DATE2 := QHY_DUE_DATESDIFF(W_2_YEAR,
                                         W_2_HALF,
                                         QHY_FREQ_MONTH,
                                         QHY_FREQ_DAY,
                                         'H');
        IF (W_DUE_DATE1 < W_CBD) THEN
          DIFF1 := W_CBD - W_DUE_DATE1;
        ELSE
          DIFF1 := W_DUE_DATE1 - W_CBD;
        END IF;
        IF (W_DUE_DATE2 < W_CBD) THEN
          DIFF2 := W_CBD - W_DUE_DATE2;
        ELSE
          DIFF2 := W_DUE_DATE2 - W_CBD;
        END IF;
        IF (DIFF1 > DIFF2) THEN
          W_DUE_DATE := W_DUE_DATE2;
        ELSE
          W_DUE_DATE := W_DUE_DATE1;
        END IF;
      END HALFYEARLY_DUE_DATE;
      --************************************************************************************************

      PROCEDURE YEARLY_DUE_DATE(QHY_FREQ_MONTH IN NUMBER,
                                QHY_FREQ_DAY   IN NUMBER) IS
        W_BEG_DATE  DATE;
        NOD         NUMBER(3);
        W_1_YEAR    NUMBER(5);
        W_2_YEAR    NUMBER(5);
        W_DUE_DATE1 DATE;
        W_DUE_DATE2 DATE;
        DIFF1       NUMBER(3);
        DIFF2       NUMBER(3);
      BEGIN
        W_BEG_DATE := TO_DATE('01-01-' || W_CURR_DATE_YEAR,'DD-MM-YYYY');
        NOD        := W_CBD - W_BEG_DATE;
        IF (NOD < 7) THEN
          W_1_YEAR := W_CURR_DATE_YEAR - 1;
          W_2_YEAR := W_CURR_DATE_YEAR;
        ELSE
          W_1_YEAR := W_CURR_DATE_YEAR;
          W_2_YEAR := W_CURR_DATE_YEAR + 1;
        END IF;
        W_DUE_DATE1 := QHY_DUE_DATESDIFF(W_1_YEAR,
                                         1,
                                         QHY_FREQ_MONTH,
                                         QHY_FREQ_DAY,
                                         'Y');
        W_DUE_DATE2 := QHY_DUE_DATESDIFF(W_2_YEAR,
                                         1,
                                         QHY_FREQ_MONTH,
                                         QHY_FREQ_DAY,
                                         'Y');
        IF (W_DUE_DATE1 < W_CBD) THEN
          DIFF1 := W_CBD - W_DUE_DATE1;
        ELSE
          DIFF1 := W_DUE_DATE1 - W_CBD;
        END IF;
        IF (W_DUE_DATE2 < W_CBD) THEN
          DIFF2 := W_CBD - W_DUE_DATE2;
        ELSE
          DIFF2 := W_DUE_DATE2 - W_CBD;
        END IF;
        IF (DIFF1 > DIFF2) THEN
          W_DUE_DATE := W_DUE_DATE2;
        ELSE
          W_DUE_DATE := W_DUE_DATE1;
        END IF;
      END YEARLY_DUE_DATE;
      --************************************************************************************************
      PROCEDURE CALLSPAVAILBAL(ACCNUM IN NUMBER) IS
      BEGIN
        SP_AVLBAL(PKG_ENTITY.FN_GET_ENTITY_CODE,ACCNUM,
                  V_DUMMY_C,
                  W_AC_AUTH_BAL,
                  V_DUMMY_N,
                  V_DUMMY_N,
                  V_DUMMY_N,
                  V_DUMMY_N,
                  V_DUMMY_N,
                  V_DUMMY_N,
                  V_DUMMY_N,
                  V_DUMMY_N,
                  V_DUMMY_N,
                  W_AC_EFFBAL,
                  V_DUMMY_N,
                  V_DUMMY_N,
                  V_DUMMY_N,
                  V_DUMMY_N,
                  V_DUMMY_N,
                  V_DUMMY_N,
                  V_DUMMY_N,
                  V_DUMMY_N,
                  V_DUMMY_N,
                  V_DUMMY_N,
                  V_DUMMY_D,
                  V_DUMMY_C,
                  V_DUMMY_D,
                  V_DUMMY_C,
                  V_DUMMY_C,
                  V_DUMMY_C,
                  V_DUMMY_C,
                  V_DUMMY_N,
                  V_DUMMY_N,
                  W_ERROR,
                  V_DUMMY_C,
                  V_DUMMY_N,
                  V_DUMMY_N,
                  V_DUMMY_N,
                  V_DUMMY_N,
                  V_DUMMY_N,
                  V_DUMMY_N,
                  V_DUMMY_N,
                  V_DUMMY_N,
                  1);
      END CALLSPAVAILBAL;
      --************************************************************************************************
      PROCEDURE COM_SINDBDISPTRF_FLOAT12(CHOICE IN CHAR,K IN NUMBER) IS
      BEGIN
        W_SIN_AMT          := 0;
        W_ACNTS_CR_FREEZED := NULL;
        FOR IDX_REC_DEP IN (SELECT SINDBTRFDISP_ACNT_NUM
                              FROM SINDBTRFDISP
                              WHERE SINDBTRFDISP_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND  SINDBTRFDISP_BRN_CODE = SINDB_REC(K)
                            .V_SINDB_BRN_CODE
                               AND SINDBTRFDISP_SIN_NUM = SINDB_REC(K)
                            .V_SINDB_SIN_NUM
                             ORDER BY SINDBTRFDISP_DTL_SL) LOOP
          IF (IDX_REC_DEP.SINDBTRFDISP_ACNT_NUM > 0) THEN
            <<STARTREADACNTS>>
            BEGIN
              CALLSPAVAILBAL(IDX_REC_DEP.SINDBTRFDISP_ACNT_NUM);
              IF (TRIM(W_ERROR) IS NOT NULL) THEN
                RAISE USR_EXCEPTION;
              END IF;

              IF PKG_ACNTS_VALID.SP_CHECK_ACNT_STATUS(PKG_ENTITY.FN_GET_ENTITY_CODE,IDX_REC_DEP.SINDBTRFDISP_ACNT_NUM,
                                                      'C') = FALSE THEN
                W_ABORT_FLAG := '1';
                IF (PKG_ACNTS_VALID.P_ACNTS_CR_FREEZED = 1) THEN

                  MOVE_EXCEP_ARRAY(W_SINEXMAP_TARGET_FRZ_ACNT,
                                   IDX_REC_DEP.SINDBTRFDISP_ACNT_NUM,
                                   1,
                                   W_AC_AUTH_BAL,
                                   0);
                END IF;
                IF (PKG_ACNTS_VALID.P_ACNTS_CLOSURE_DATE IS NOT NULL) THEN
                  MOVE_EXCEP_ARRAY(W_SINEXMAP_TARGET_AC_CLOSED,
                                   IDX_REC_DEP.SINDBTRFDISP_ACNT_NUM,
                                   1,
                                   W_AC_AUTH_BAL,
                                   0);
                END IF;

                CHECK_DORMANT_INOPERATIVE(1);

                IF PKG_ACNTS_VALID.P_ACCOUNT_STATUS = '1' THEN
                  W_ERROR := 'TARGET ACCOUNT IS INVALID';
                  RAISE USR_EXCEPTION; --GOTO WRITEEXCEPTION; --
                END IF;

                GOTO START_SUBLOOP1;
              END IF;
              W_ACNTS_CURR_CODE := PKG_ACNTS_VALID.P_ACNTS_CURR_CODE;

            END STARTREADACNTS;

            IF (CHOICE = '1') THEN
              SP_LMTOVERDRAWAL(PKG_ENTITY.FN_GET_ENTITY_CODE,IDX_REC_DEP.SINDBTRFDISP_ACNT_NUM,
                               W_ACNTS_CURR_CODE,
                               W_CBD,
                               W_OVERDRAWAL_AMT,
                               W_LIMIT_AVL,
                               W_ERROR);
              IF (TRIM(W_ERROR) IS NOT NULL) THEN
                RAISE USR_EXCEPTION;
              END IF;
              IF (W_LIMIT_AVL = '1' AND W_OVERDRAWAL_AMT > 0 AND
                 W_AC_AUTH_BAL < 0) THEN
                W_EACH_AMT := W_OVERDRAWAL_AMT;
              ELSIF (W_LIMIT_AVL = '0' AND W_AC_AUTH_BAL < 0) THEN
                W_EACH_AMT := ABS(W_AC_AUTH_BAL);
              ELSE
                W_EACH_AMT := 0;
                GOTO ENDSUBLOOP;
              END IF;

            ELSIF (CHOICE = '2') THEN
              IF (W_AC_AUTH_BAL > 0 AND W_AC_AUTH_BAL >= SINDB_REC(K)
                 .V_SINDB_SPECIFIED_BAL_AMT) THEN
                W_ABORT_FLAG := '1';
                W_EACH_AMT   := 0;
              ELSE
                W_EACH_AMT := SINDB_REC(K)
                             .V_SINDB_SPECIFIED_BAL_AMT - W_AC_AUTH_BAL;
              END IF;
            END IF;

            IF (W_EACH_AMT <> 0) THEN
              W_EACH_AMT := FN_ROUNDOFF(PKG_ENTITY.FN_GET_ENTITY_CODE,W_EACH_AMT,
                                         SINDB_REC(K)
                                        .V_SINDB_RND_OFF_AMT_CHOICE,
                                        SINDB_REC(K).V_SINDB_RND_OFF_FACTOR);
            END IF;
            W_SIN_AMT := W_SIN_AMT + W_EACH_AMT;
            W_TARGET_IND := W_TARGET_IND + 1;
            TARGET_ACC_DTL(W_TARGET_IND).ACC_DTL_SERIAL := W_TARGET_IND;
            TARGET_ACC_DTL(W_TARGET_IND).ACC_DTL_ACCNUM := IDX_REC_DEP.SINDBTRFDISP_ACNT_NUM;
            TARGET_ACC_DTL(W_TARGET_IND).ACC_DTL_AMT := W_EACH_AMT;
          END IF;
          <<START_SUBLOOP1>>
          NULL;
        END LOOP;
        <<ENDSUBLOOP>>
        IF (W_TARGET_IND <= 0) THEN
          W_ABORT_FLAG := '1';
        ELSE
          DBMS_OUTPUT.PUT_LINE('TARGET ACCOUNT DETAILS');
          FOR N IN 1 .. W_TARGET_IND LOOP
            DBMS_OUTPUT.PUT_LINE(TARGET_ACC_DTL(N)
                                 .ACC_DTL_SERIAL || ' ' || TARGET_ACC_DTL(N)
                                 .ACC_DTL_ACCNUM || ' ' || TARGET_ACC_DTL(N)
                                 .ACC_DTL_AMT);
          END LOOP;
        END IF;
      END COM_SINDBDISPTRF_FLOAT12;
      --************************************************************************************************
      PROCEDURE COM_SINDBDFUNSRC_FLOAT45(CHOICE IN CHAR,K IN NUMBER) IS
      BEGIN
        W_SIN_AMT          := 0;
        W_ACNTS_DB_FREEZED := NULL;
        FOR IDX_REC_DEP IN (SELECT SINDBFSRC_ACNT_NUM
                              FROM SINDBFUNDSRC
                              WHERE SINDBFSRC_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND  SINDBFSRC_BRN_CODE = SINDB_REC(K)
                            .V_SINDB_BRN_CODE
                               AND SINDBFSRC_SIN_NUM = SINDB_REC(K)
                            .V_SINDB_SIN_NUM
                             ORDER BY SINDBFSRC_DTL_SL) LOOP
          IF (IDX_REC_DEP.SINDBFSRC_ACNT_NUM > 0) THEN
            <<STARTREADACNTS_SRC>>
            BEGIN
              CALLSPAVAILBAL(IDX_REC_DEP.SINDBFSRC_ACNT_NUM);
              IF (TRIM(W_ERROR) IS NOT NULL) THEN
                RAISE USR_EXCEPTION;
              END IF;

              IF PKG_ACNTS_VALID.SP_CHECK_ACNT_STATUS(PKG_ENTITY.FN_GET_ENTITY_CODE,IDX_REC_DEP.SINDBFSRC_ACNT_NUM,
                                                      'D') = FALSE THEN
                W_ABORT_FLAG := '1';

                IF (PKG_ACNTS_VALID.P_ACNTS_DB_FREEZED = '1') THEN

                  MOVE_EXCEP_ARRAY(W_SINEXMAP_SRC_FRZ_ACNT,
                                   IDX_REC_DEP.SINDBFSRC_ACNT_NUM,
                                   2,
                                   W_AC_EFFBAL,
                                   0);
                END IF;
                IF (PKG_ACNTS_VALID.P_ACNTS_CLOSURE_DATE IS NOT NULL) THEN

                  MOVE_EXCEP_ARRAY(W_SINEXMAP_SRC_AC_CLOSED,
                                   IDX_REC_DEP.SINDBFSRC_ACNT_NUM,
                                   2,
                                   W_AC_EFFBAL,
                                   0);
                END IF;

                CHECK_DORMANT_INOPERATIVE(2);

                IF PKG_ACNTS_VALID.P_ACCOUNT_STATUS = '1' THEN
                  W_ERROR := 'SOURCE ACCOUNT IS INVALID';
                  RAISE USR_EXCEPTION; --GOTO WRITEEXCEPTION; --
                END IF;

                GOTO START_SUBLOOP2;
              END IF;
            END STARTREADACNTS_SRC;

            IF (CHOICE = '4') THEN
              IF (W_AC_EFFBAL > 0) THEN
                W_EACH_AMT := W_AC_EFFBAL;
              ELSE
                W_EACH_AMT   := 0;
                W_ABORT_FLAG := 1;
              END IF;
            ELSIF (CHOICE = '5') THEN
              IF (W_AC_AUTH_BAL > 0 AND W_AC_AUTH_BAL > SINDB_REC(K)
                 .V_SINDB_CUT_OFF_BAL_SRC_AMT) THEN
                W_EACH_AMT := W_AC_AUTH_BAL - SINDB_REC(K)
                             .V_SINDB_CUT_OFF_BAL_SRC_AMT;
              ELSE
                W_EACH_AMT   := 0;
                W_ABORT_FLAG := '1';
              END IF;
            END IF;

            IF (W_EACH_AMT <> 0) THEN
              W_EACH_AMT := FN_ROUNDOFF(PKG_ENTITY.FN_GET_ENTITY_CODE,W_EACH_AMT,
                                         SINDB_REC(K)
                                        .V_SINDB_RND_OFF_AMT_CHOICE,
                                        SINDB_REC(K).V_SINDB_RND_OFF_FACTOR);
            END IF;
            W_SIN_AMT := W_SIN_AMT + W_EACH_AMT;
            W_SOURCE_IND := W_SOURCE_IND + 1;
            SOUCRCE_ACC_DTL(W_SOURCE_IND).ACC_DTL_SERIAL := W_SOURCE_IND;
            SOUCRCE_ACC_DTL(W_SOURCE_IND).ACC_DTL_ACCNUM := IDX_REC_DEP.SINDBFSRC_ACNT_NUM;
            SOUCRCE_ACC_DTL(W_SOURCE_IND).ACC_DTL_AMT := W_EACH_AMT;
          END IF;
          <<START_SUBLOOP2>>
          NULL;
        END LOOP;
        IF (W_SOURCE_IND <= 0) THEN
          W_ABORT_FLAG := '1';
        ELSE
          DBMS_OUTPUT.PUT_LINE('SOURCE ACCOUNT DETAILS');
          FOR N IN 1 .. W_SOURCE_IND LOOP
            DBMS_OUTPUT.PUT_LINE(SOUCRCE_ACC_DTL(N)
                                 .ACC_DTL_SERIAL || ' ' || SOUCRCE_ACC_DTL(N)
                                 .ACC_DTL_ACCNUM || ' ' || SOUCRCE_ACC_DTL(N)
                                 .ACC_DTL_AMT);
          END LOOP;
        END IF;
      END COM_SINDBDFUNSRC_FLOAT45;
      --************************************************************************************************
      --************************************************************************************************
      FUNCTION GETMAX_TRYSERIALSINEXECLOG(BRN IN NUMBER,SINNUM IN NUMBER)
        RETURN NUMBER IS
        MAXSL NUMBER;
      BEGIN
        SELECT NVL(MAX(SINEXECLOG_TRY_SERIAL),0) + 1
          INTO MAXSL
          FROM SINEXECLOG
          WHERE SINEXECLOG_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND  SINEXECLOG_BRN_CODE = BRN
           AND SINEXECLOG_SIN_NUM = SINNUM
           AND SINEXECLOG_DUE_DATE_OF_EXEC = W_DUE_DATE;
        RETURN MAXSL;
      END GETMAX_TRYSERIALSINEXECLOG;

      --************************************************************************************************
      PROCEDURE SINEXECLOG_UPDATE(BRN       IN NUMBER,
                                  SINNUM    IN NUMBER,
                                  POST_BRN  IN NUMBER,
                                  POST_DATE IN DATE,
                                  BATCH_NUM IN NUMBER,
                                  SIN_STAT  IN CHAR) IS
      BEGIN
        W_SINEXECLOG_TRY_SERIAL := 0;
        W_SINEXECLOG_TRY_SERIAL := GETMAX_TRYSERIALSINEXECLOG(BRN,SINNUM);
        INSERT INTO SINEXECLOG
        VALUES
          (  PKG_ENTITY.FN_GET_ENTITY_CODE ,BRN,
           SINNUM,
           W_DUE_DATE,
           W_SINEXECLOG_TRY_SERIAL,
           W_CBD,
           W_RUN_TYPE,
           SYSDATE,
           SIN_STAT,
           POST_BRN,
           POST_DATE,
           BATCH_NUM,
           W_DDPOKEY, --CHG ARUN 21-11-2007
           W_USR_BRN,
           PKG_EODSOD_FLAGS.PV_USER_ID);
      END SINEXECLOG_UPDATE;
      --************************************************************************************************
      PROCEDURE SINEXECEXCEP_UPDATE(BRN IN NUMBER,SINNUM IN NUMBER) IS
      BEGIN
        IF (W_EXCEPTION_IND > 0) THEN
          FOR N IN 1 .. W_EXCEPTION_IND LOOP
            INSERT INTO SINEXECEXCEP
            VALUES
              (  PKG_ENTITY.FN_GET_ENTITY_CODE ,BRN,
               SINNUM,
               W_DUE_DATE,
               W_SINEXECLOG_TRY_SERIAL,
               EXCEP_ARRAY(N).EXCP_IND,
               EXCEP_ARRAY(N).EXCP_CODE,
               EXCEP_ARRAY(N).EXCP_ACCNUM,
               EXCEP_ARRAY(N).EXCP_SININTCAT,
               EXCEP_ARRAY(N).EXCP_ACCBAL,
               EXCEP_ARRAY(N).EXCP_REQAMO,
               EXCEP_ARRAY(N).SINEXCEP_ADDN_INFO);
          END LOOP;
        END IF;
      END SINEXECEXCEP_UPDATE;
      --************************************************************************************************
      /*          PROCEDURE INSERT_SINEXECSTAT(BRN IN NUMBER, SINNUM IN NUMBER) IS
                     COU NUMBER(4);
                BEGIN
                     SELECT COUNT(*)
                     INTO   COU
                     FROM   SINEXECSTAT
                     WHERE  SINEXECSTAT_BRN_CODE = BRN AND
                            SINEXECSTAT_SIN_NUM = SINNUM AND
                            SINEXECSTAT_DUE_DATE_OF_EXEC = W_DUE_DATE;
                     IF (COU = 0) THEN
                          INSERT INTO SINEXECSTAT
                          VALUES
                               (BRN, SINNUM, W_DUE_DATE, ' ', NULL, ' ', 0);
                     END IF;
                END INSERT_SINEXECSTAT;
      */
      PROCEDURE UPDATE_SINEXECSTAT(BRN     IN NUMBER,
                                   SINNUM  IN NUMBER,
                                   EXECFLG CHAR) IS
      BEGIN
        <<INSERTSIN>>
        BEGIN
          INSERT INTO SINEXECSTAT
            (SINEXECSTAT_ENTITY_NUM,SINEXECSTAT_BRN_CODE,
             SINEXECSTAT_SIN_NUM,
             SINEXECSTAT_DUE_DATE_OF_EXEC,
             SINEXECSTAT_STATUS_OF_EXEC,
             SINEXECSTAT_LAST_EXEC_DATE,
             SINEXECSTAT_LAST_EXEC_FLG,
             SINEXECSTAT_NUM_EXEC_ATTMPTS)
          VALUES
            (  PKG_ENTITY.FN_GET_ENTITY_CODE ,BRN,SINNUM,W_DUE_DATE,EXECFLG,W_CBD,W_RUN_TYPE,1);
        EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
            UPDATE SINEXECSTAT
               SET SINEXECSTAT_STATUS_OF_EXEC   = EXECFLG,
                   SINEXECSTAT_LAST_EXEC_DATE   = W_CBD,
                   SINEXECSTAT_LAST_EXEC_FLG    = W_RUN_TYPE,
                   SINEXECSTAT_NUM_EXEC_ATTMPTS = SINEXECSTAT_NUM_EXEC_ATTMPTS + 1
               WHERE SINEXECSTAT_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND  SINEXECSTAT_BRN_CODE = BRN
               AND SINEXECSTAT_SIN_NUM = SINNUM
               AND SINEXECSTAT_DUE_DATE_OF_EXEC = W_DUE_DATE;
        END INSERTSIN;
      END UPDATE_SINEXECSTAT;
      --************************************************************************************************
      PROCEDURE POST_ARRAY_ASSIGN(BRN     IN NUMBER,
                                  GLCODE  IN VARCHAR2,
                                  ACCNUM  IN NUMBER,
                                  CDFLG   IN CHAR,
                                  AMTCURR IN VARCHAR,
                                  AMT     IN NUMBER,
                                  IDX     IN NUMBER) IS
      BEGIN
        IF (BRN <> 0) THEN
          PKG_AUTOPOST.PV_TRAN_REC(IDX).TRAN_ACING_BRN_CODE := BRN;  --AGK-CHN-28-APR-2009-ACING BRN MOVED
        END IF;
        IF (TRIM(GLCODE) IS NOT NULL) THEN
          PKG_AUTOPOST.PV_TRAN_REC(IDX).TRAN_GLACC_CODE := GLCODE;
        END IF;
        IF (ACCNUM <> 0) THEN
          PKG_AUTOPOST.PV_TRAN_REC(IDX).TRAN_INTERNAL_ACNUM := ACCNUM;
        END IF;

        IF (TRIM(CDFLG) IS NOT NULL) THEN
          PKG_AUTOPOST.PV_TRAN_REC(IDX).TRAN_DB_CR_FLG := CDFLG;
        END IF;
        IF (TRIM(AMTCURR) IS NOT NULL) THEN
          PKG_AUTOPOST.PV_TRAN_REC(IDX).TRAN_CURR_CODE := AMTCURR;
        END IF;
        PKG_AUTOPOST.PV_TRAN_REC(IDX).TRAN_AMOUNT := AMT;
      END POST_ARRAY_ASSIGN;
      --************************************************************************************************

      PROCEDURE ABORT_PROCESS(K IN NUMBER) IS
        W_TOT_CHGS       NUMBER(18,3);
        W_CHARGE_AMOUNT  NUMBER(18,3);
        W_SERVICE_AMOUNT NUMBER(18,3);
        W_CHARGE_CURR    VARCHAR2(3);
        W_AGNST_AMT      NUMBER(18,3);
        W_ACNTS_CHGS     NUMBER(18,3);
      BEGIN
        W_BATCH_NUMBER := 0;
        IF (W_ABORT_FLAG = '1' AND W_EXCEPTION_IND > 0) THEN
          <<STARTREADSICHG>>
          BEGIN
            SELECT SICHG_SIN_CHG_CODE
              INTO W_SICHG_SIN_CHG_CODE
              FROM SICHG
             WHERE SICHG_SIN_TYPE = SINDB_REC(K)
            .V_SINDB_SI_TYPE
               AND SICHG_EXEC_STATUS = 'F';
            IF (TRIM(W_SICHG_SIN_CHG_CODE) IS NOT NULL AND SINDB_REC(K)
               .V_SINDB_CHGS_RECOV_ACNUM > 0) THEN
              <<READACNTS_CHGACC>>
              BEGIN

                IF PKG_ACNTS_VALID.SP_CHECK_ACNT_STATUS(PKG_ENTITY.FN_GET_ENTITY_CODE,SINDB_REC(K)
                                                        .V_SINDB_CHGS_RECOV_ACNUM,
                                                        'D') = FALSE THEN
                  -- CALLSPAVAILBAL(SINDB_REC(K).V_SINDB_CHGS_RECOV_ACNUM);
                  -- IF(TRIM(W_ERROR) IS NOT NULL) THEN
                  --   RAISE USR_EXCEPTION;
                  --  END IF;
                  W_ABORT_FLAG := '1';

                  IF (PKG_ACNTS_VALID.P_ACNTS_DB_FREEZED = '1') THEN
                    MOVE_EXCEP_ARRAY(W_SINEXMAP_CHGS_FRZ_ACNT,
                                     SINDB_REC(K).V_SINDB_CHGS_RECOV_ACNUM,
                                     3,
                                     0,
                                     0);
                  END IF;
                  IF (PKG_ACNTS_VALID.P_ACNTS_CLOSURE_DATE IS NOT NULL) THEN
                    MOVE_EXCEP_ARRAY(W_SINEXMAP_CHGS_AC_CLOSED,
                                     SINDB_REC(K).V_SINDB_CHGS_RECOV_ACNUM,
                                     3,
                                     0,
                                     0);

                  END IF;

                  CHECK_DORMANT_INOPERATIVE(2);

                  IF PKG_ACNTS_VALID.P_ACCOUNT_STATUS = '1' THEN
                    W_ERROR := 'CHARGES ACCOUNT IS INVALID';
                    RAISE USR_EXCEPTION;
                  END IF;

                  GOTO UPDATELOG_PARA;
                END IF;

                W_ACNTS_CURR_CODE := PKG_ACNTS_VALID.P_ACNTS_CURR_CODE;
              END READACNTS_CHGACC;
            ELSE
              GOTO UPDATELOG_PARA;
            END IF;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              GOTO UPDATELOG_PARA;
          END STARTREADSICHG;
          W_TOT_CHGS := 0;
          IF (TRIM(W_SICHG_SIN_CHG_CODE) IS NOT NULL AND SINDB_REC(K)
             .V_SINDB_CHGS_RECOV_ACNUM > 0) THEN
            PKG_CHARGES.SP_GET_CHARGES(PKG_ENTITY.FN_GET_ENTITY_CODE,SINDB_REC(K).V_SINDB_CHGS_RECOV_ACNUM,
                                       W_ACNTS_CURR_CODE,
                                       W_SIN_AMT,
                                       W_SICHG_SIN_CHG_CODE,
                                       'N',
                                       W_CHARGE_CURR,
                                       W_CHARGE_AMOUNT,
                                       W_SERVICE_AMOUNT,
                                       V_DUMMY_N,
                                       V_DUMMY_N,
                                       V_DUMMY_N,
                                       W_ERROR);
            IF (TRIM(W_ERROR) IS NOT NULL) THEN
              RAISE USR_EXCEPTION;
            END IF;
            W_TOT_CHGS := W_CHARGE_AMOUNT + W_SERVICE_AMOUNT;
            IF (W_CHARGE_AMOUNT > 0) THEN
              IF (W_CHARGE_CURR = W_ACNTS_CURR_CODE) THEN
                W_ACNTS_CHGS := W_TOT_CHGS;
              ELSE
                SP_CALCAGNAMT(PKG_ENTITY.FN_GET_ENTITY_CODE,W_CHARGE_CURR,
                              W_ACNTS_CURR_CODE,
                              W_TOT_CHGS,
                              'M',
                              W_CBD,
                              '1',
                              W_CMNPM_MID_RATE_TYPE_PUR,
                              W_CMNPM_MID_RATE_TYPE_PUR,
                              W_AGNST_AMT,
                              V_DUMMY_N);
                W_ACNTS_CHGS := W_AGNST_AMT;
              END IF;
              PKG_AUTOPOST.PV_TRANBAT.TRANBAT_NARR_DTL1 := 'Standing Instruction Execution';
              PKG_AUTOPOST.PV_TRANBAT.TRANBAT_NARR_DTL2 := 'Failure Charges Recovered';
              PKG_AUTOPOST.PV_TRANBAT.TRANBAT_NARR_DTL3 := 'SI Number ' ||
                                                           SINDB_REC(K)
                                                          .V_SINDB_SIN_NUM;
              IDX := IDX + 1;
              PKG_AUTOPOST.PV_TRAN_REC(IDX).TRAN_CHARGE_CODE := W_SICHG_SIN_CHG_CODE;
              POST_ARRAY_ASSIGN(0,
                                ' ',
                                SINDB_REC(K).V_SINDB_CHGS_RECOV_ACNUM,
                                'D',
                                ' ',
                                W_ACNTS_CHGS,
                                IDX);

              PKG_CHGSSTAXPOST.SP_CHGSSTAXPOST(PKG_ENTITY.FN_GET_ENTITY_CODE,SINDB_REC(K).V_SINDB_BRN_CODE,
                                               W_SICHG_SIN_CHG_CODE,
                                               W_CHARGE_CURR,
                                               W_CHARGE_AMOUNT,
                                               W_SERVICE_AMOUNT,
                                               W_ERROR);
              IF (W_ERROR IS NOT NULL) THEN
                RAISE USR_EXCEPTION;
              END IF;
              IDX := PKG_AUTOPOST.PV_TRAN_REC.LAST;
              PKG_APOST_INTERFACE.SP_POST_SODEOD_BATCH(PKG_ENTITY.FN_GET_ENTITY_CODE,'A',
                                                       IDX,
                                                       0,
                                                       W_ERR_CODE,
                                                       W_ERROR,
                                                       W_BATCH_NUMBER);
              IF (W_ERR_CODE <> '0000') THEN
                W_ERROR := FN_GET_AUTOPOST_ERR_MSG(PKG_ENTITY.FN_GET_ENTITY_CODE);
                RAISE USR_EXCEPTION;
              END IF;

            END IF;
          END IF;

          <<UPDATELOG_PARA>>
          W_DDPOKEY := ' ';
          IF (W_BATCH_NUMBER <> 0) THEN
            SINEXECLOG_UPDATE(SINDB_REC(K).V_SINDB_BRN_CODE,
                              SINDB_REC(K).V_SINDB_SIN_NUM,
                              SINDB_REC(K).V_SINDB_BRN_CODE,
                              W_CBD,
                              W_BATCH_NUMBER,
                              'F');
          ELSE
            SINEXECLOG_UPDATE(SINDB_REC(K).V_SINDB_BRN_CODE,
                              SINDB_REC(K).V_SINDB_SIN_NUM,
                              0,
                              NULL,
                              0,
                              'F');
          END IF;
          SINEXECEXCEP_UPDATE(SINDB_REC(K).V_SINDB_BRN_CODE,
                              SINDB_REC(K).V_SINDB_SIN_NUM);
          /*                    INSERT_SINEXECSTAT(SINDB_REC(K) .V_SINDB_BRN_CODE,
                                                 SINDB_REC(K) .V_SINDB_SIN_NUM);
          */
          UPDATE_SINEXECSTAT(SINDB_REC(K).V_SINDB_BRN_CODE,
                             SINDB_REC(K).V_SINDB_SIN_NUM,
                             'F');
        END IF;
      END ABORT_PROCESS;
      --************************************************************************************************
      PROCEDURE SETTRANKEYVALUE(BRN_CODE IN NUMBER,CBD IN DATE) IS
      BEGIN
        PKG_AUTOPOST.PV_SYSTEM_POSTED_TRANSACTION := FALSE;
        PKG_AUTOPOST.PV_TRAN_KEY.TRAN_BRN_CODE    := BRN_CODE;
        --23-12-2008-rem      PKG_AUTOPOST.PV_TRAN_KEY.TRAN_DATE_OF_TRAN := CBD;
        PKG_AUTOPOST.PV_TRAN_KEY.TRAN_DATE_OF_TRAN := PKG_PB_GLOBAL.FN_GET_CURR_BUS_DATE(PKG_ENTITY.FN_GET_ENTITY_CODE);
        PKG_AUTOPOST.PV_TRAN_KEY.TRAN_BATCH_SL_NUM := 0;
        PKG_AUTOPOST.PV_TRAN_KEY.TRAN_BATCH_NUMBER := 0;
      END SETTRANKEYVALUE;
      --************************************************************************************************
      PROCEDURE SETTRANBATVALUE(BRN_CODE    IN NUMBER,
                                SIN_NUM     IN NUMBER,
                                DUE_DATE    IN DATE,
                                SIN_DB_REM1 IN VARCHAR2,
                                SIN_DB_REM2 IN VARCHAR2,
                                SIN_DB_REM3 IN VARCHAR2) IS
      BEGIN
        PKG_AUTOPOST.PV_TRANBAT.TRANBAT_SOURCE_TABLE := 'SINEXECSTAT';
        PKG_AUTOPOST.PV_TRANBAT.TRANBAT_SOURCE_KEY   := BRN_CODE || '|' ||
                                                        SIN_NUM || '|' ||
                                                        DUE_DATE;
        IF (TRIM(SIN_DB_REM1) IS NOT NULL) THEN
          PKG_AUTOPOST.PV_TRANBAT.TRANBAT_NARR_DTL1 := SIN_DB_REM1;
          IF (TRIM(SIN_DB_REM2) IS NOT NULL) THEN
            PKG_AUTOPOST.PV_TRANBAT.TRANBAT_NARR_DTL2 := SIN_DB_REM2;
            IF (TRIM(SIN_DB_REM3) IS NOT NULL) THEN
              PKG_AUTOPOST.PV_TRANBAT.TRANBAT_NARR_DTL3 := SIN_DB_REM3;
            END IF;
          END IF;
        ELSE
          PKG_AUTOPOST.PV_TRANBAT.TRANBAT_NARR_DTL1 := 'Standing Instruction Execution';
          PKG_AUTOPOST.PV_TRANBAT.TRANBAT_NARR_DTL2 := 'SI Number ' ||
                                                       SIN_NUM;
        END IF;
        -- PKG_AUTOPOST.PV_TRANBAT.setAutoauthorize(TRUE);
        --  PKG_AUTOPOST.PV_TRANBAT.batchupdaterequired(False);
      END SETTRANBATVALUE;

      --************************************************************************************************
      PROCEDURE DEBIT_FOR_SRCFNDAC(L IN NUMBER) IS
        W_TOT_SRC_AMT     NUMBER;
        W_S_IND           NUMBER;
        W_S_AMT           NUMBER;
        W_AVL_CHECK_REQ   BOOLEAN;
        W_REQ_OD_EXCEP    NUMBER(18,3);
        W_ACNUM_OD_EXCEP  NUMBER(14);
        W_ACCBAL_OD_EXCEP NUMBER(18,3);
      BEGIN
        W_REM_AMT     := W_SIN_AMT;
        W_TOT_SRC_AMT := 0;
        W_S_IND       := 0;

        FOR IDX_REC_DEP IN (SELECT SINDBFSRC_ACNT_NUM,
                                   SINDBFSRC_GL_BRN_CODE,
                                   SINDBFSRC_GLACC_CODE,
                                   SINDBFSRC_AMT_CURR,
                                   SINDBFSRC_AMT_TOBE_TRFD
                              FROM SINDBFUNDSRC
                              WHERE SINDBFSRC_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND  SINDBFSRC_BRN_CODE = SINDB_REC(L)
                            .V_SINDB_BRN_CODE
                               AND SINDBFSRC_SIN_NUM = SINDB_REC(L)
                            .V_SINDB_SIN_NUM
                             ORDER BY SINDBFSRC_DTL_SL) LOOP
          W_AVL_CHECK_REQ   := FALSE;
          W_REQ_OD_EXCEP    := 0;
          W_ACNUM_OD_EXCEP  := 0;
          W_ACCBAL_OD_EXCEP := 0;

          W_S_IND := W_S_IND + 1;

          IF (W_S_IND = 1) THEN
            W_REMIT_ACCNUM := IDX_REC_DEP.SINDBFSRC_ACNT_NUM;
          END IF;
          W_S_AMT := 0;

          IF (IDX_REC_DEP.SINDBFSRC_AMT_TOBE_TRFD <> 0) THEN
            W_S_AMT         := IDX_REC_DEP.SINDBFSRC_AMT_TOBE_TRFD;
            W_AVL_CHECK_REQ := TRUE;
          ELSIF (IDX_REC_DEP.SINDBFSRC_ACNT_NUM > 0 AND W_SOURCE_IND > 0) THEN
            FOR N IN 1 .. W_SOURCE_IND LOOP
              IF (IDX_REC_DEP.SINDBFSRC_ACNT_NUM = SOUCRCE_ACC_DTL(N)
                 .ACC_DTL_ACCNUM) THEN
                W_S_AMT := SOUCRCE_ACC_DTL(N).ACC_DTL_AMT;
                GOTO STEPCPROCESS;
              END IF;
            END LOOP;

            CALLSPAVAILBAL(IDX_REC_DEP.SINDBFSRC_ACNT_NUM);
            IF (TRIM(W_ERROR) IS NOT NULL) THEN
              RAISE USR_EXCEPTION;
            END IF;
            IF (W_REM_AMT <= W_AC_EFFBAL) THEN
              W_S_AMT := W_REM_AMT;
            ELSE
              W_S_AMT := W_AC_EFFBAL;
            END IF;
          ELSE
            W_S_AMT := W_REM_AMT;
          END IF;
          <<STEPCPROCESS>>
          BEGIN
            IF W_AVL_CHECK_REQ = TRUE THEN
              IF IDX_REC_DEP.SINDBFSRC_ACNT_NUM <> 0 THEN
                CALLSPAVAILBAL(IDX_REC_DEP.SINDBFSRC_ACNT_NUM);
                IF (TRIM(W_ERROR) IS NOT NULL) THEN
                  RAISE USR_EXCEPTION;
                END IF;
                IF (W_S_AMT > W_AC_EFFBAL) THEN
                  W_REQ_OD_EXCEP    := W_S_AMT;
                  W_ACNUM_OD_EXCEP  := IDX_REC_DEP.SINDBFSRC_ACNT_NUM;
                  W_ACCBAL_OD_EXCEP := W_AC_EFFBAL;

                  W_S_AMT := 0;
                END IF;
              END IF;
            END IF;

            IF IDX_REC_DEP.SINDBFSRC_ACNT_NUM <> 0 THEN
              IF PKG_ACNTS_VALID.SP_CHECK_ACNT_STATUS(PKG_ENTITY.FN_GET_ENTITY_CODE,IDX_REC_DEP.SINDBFSRC_ACNT_NUM,
                                                      'D') = FALSE THEN

                W_ABORT_FLAG := '1';

                IF (PKG_ACNTS_VALID.P_ACNTS_DB_FREEZED = 1) THEN
                  MOVE_EXCEP_ARRAY(W_SINEXMAP_SRC_FRZ_ACNT,
                                   IDX_REC_DEP.SINDBFSRC_ACNT_NUM,
                                   2,
                                   0,
                                   0);
                END IF;
                IF (PKG_ACNTS_VALID.P_ACNTS_CLOSURE_DATE IS NOT NULL) THEN
                  MOVE_EXCEP_ARRAY(W_SINEXMAP_SRC_AC_CLOSED,
                                   IDX_REC_DEP.SINDBFSRC_ACNT_NUM,
                                   2,
                                   0,
                                   0);
                END IF;

                CHECK_DORMANT_INOPERATIVE(2);

                IF PKG_ACNTS_VALID.P_ACCOUNT_STATUS = '1' THEN
                  W_ERROR := 'SOURCE ACCOUNT IS INVALID';
                  RAISE USR_EXCEPTION; --GOTO WRITEEXCEPTION; --
                END IF;
              END IF;
            END IF;

            IF (W_S_AMT > W_REM_AMT) THEN
              W_S_AMT := W_REM_AMT;
            END IF;

            IF (W_S_AMT > 0) THEN
              IDX := IDX + 1;
              -- Commented as per Requirement (agk-22-11-2007)                              PKG_AUTOPOST.PV_TRAN_REC(IDX).TRAN_VALUE_DATE := W_DUE_DATE;
              PKG_AUTOPOST.PV_TRAN_REC(IDX).TRAN_CODE := W_SITYPECD_TRAN_CODE;
              POST_ARRAY_ASSIGN(IDX_REC_DEP.SINDBFSRC_GL_BRN_CODE,
                                IDX_REC_DEP.SINDBFSRC_GLACC_CODE,
                                IDX_REC_DEP.SINDBFSRC_ACNT_NUM,
                                'D',
                                IDX_REC_DEP.SINDBFSRC_AMT_CURR,
                                W_S_AMT,
                                IDX);
            END IF;
            W_TOT_SRC_AMT := W_TOT_SRC_AMT + W_S_AMT;
            W_REM_AMT     := W_REM_AMT - W_S_AMT;
          END STEPCPROCESS;
        END LOOP;

        IF (W_REM_AMT <> 0) THEN
          W_ABORT_FLAG := '1';
          W_EXCEPTION_IND := W_EXCEPTION_IND + 1;
          EXCEP_ARRAY(W_EXCEPTION_IND).EXCP_IND := W_EXCEPTION_IND;
          EXCEP_ARRAY(W_EXCEPTION_IND).EXCP_CODE := W_SINEXMAP_SRC_INSUFF_FUNDS;
          IF W_ACNUM_OD_EXCEP > 0 THEN
            EXCEP_ARRAY(W_EXCEPTION_IND).EXCP_ACCNUM := W_ACNUM_OD_EXCEP;
            EXCEP_ARRAY(W_EXCEPTION_IND).EXCP_ACCBAL := W_ACCBAL_OD_EXCEP;
            EXCEP_ARRAY(W_EXCEPTION_IND).EXCP_REQAMO := W_REQ_OD_EXCEP;

          ELSE
            EXCEP_ARRAY(W_EXCEPTION_IND).EXCP_ACCNUM := 0;
            EXCEP_ARRAY(W_EXCEPTION_IND).EXCP_ACCBAL := 0;
            EXCEP_ARRAY(W_EXCEPTION_IND).EXCP_REQAMO := 0;
          END IF;
          EXCEP_ARRAY(W_EXCEPTION_IND).EXCP_SININTCAT := 2;
        END IF;
      END DEBIT_FOR_SRCFNDAC;
      --************************************************************************************************
      PROCEDURE CREDIT_FROM_UILITY_AGENCY(L IN NUMBER) IS
        W_SINDBUTIL_UAGENCY_CODE  VARCHAR2(6);
        W_SINDBUTIL_UAGSERV_CODE  VARCHAR2(6);
        W_UAGSERV_NODAL_BRN_ACNUM NUMBER(14);
        W_ACNTS_BRN_CODE          NUMBER(6);

      BEGIN
        <<READSINDBUTILPAY>>
        BEGIN
          SELECT SINDBUTIL_UAGENCY_CODE,SINDBUTIL_UAGSERV_CODE
            INTO W_SINDBUTIL_UAGENCY_CODE,W_SINDBUTIL_UAGSERV_CODE
            FROM SINDBUTILPAY
            WHERE SINDBUTIL_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND  SINDBUTIL_BRN_CODE = SINDB_REC(L)
          .V_SINDB_BRN_CODE
             AND SINDBUTIL_NUM = SINDB_REC(L).V_SINDB_SIN_NUM;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            W_ABORT_FLAG := '1';
            W_ERROR      := 'UTILITY AGENCY DETAILS NOT PRESENT';
        END READSINDBUTILPAY;

        IF (W_ABORT_FLAG <> '1') THEN
          <<READUAGSERVCD>>
          BEGIN
            SELECT UAGSERV_NODAL_BRN_ACNUM
              INTO W_UAGSERV_NODAL_BRN_ACNUM
              FROM UAGSERVCD
              WHERE UAGSERV_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND  UAGSERV_AGENCY_CODE = W_SINDBUTIL_UAGENCY_CODE
               AND UAGSERV_SERVICE_CODE = W_SINDBUTIL_UAGSERV_CODE;
            IF (W_UAGSERV_NODAL_BRN_ACNUM = 0) THEN
              W_ABORT_FLAG := '1';
              W_ERROR      := 'UTILITY NODAL ACCOUNT NUMBER NOT SPECIFIED';
            END IF;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              W_ABORT_FLAG := '1';
              W_ERROR      := 'UTILITY SERVICE CODE DETAILS NOT AVAILABLE';
          END READUAGSERVCD;
        END IF;

        IF (W_ABORT_FLAG <> '1') THEN
          <<READACNTSUTILI>>
          BEGIN

            IF PKG_ACNTS_VALID.SP_CHECK_ACNT_STATUS(PKG_ENTITY.FN_GET_ENTITY_CODE,W_UAGSERV_NODAL_BRN_ACNUM,
                                                    'C') = FALSE THEN
              W_ABORT_FLAG := '1';

              -- CALLSPAVAILBAL(SINDB_REC(K).V_SINDB_CHGS_RECOV_ACNUM);
              -- IF(TRIM(W_ERROR) IS NOT NULL) THEN
              --   RAISE USR_EXCEPTION;
              --  END IF;
              IF (PKG_ACNTS_VALID.P_ACNTS_CR_FREEZED = '1') THEN

                MOVE_EXCEP_ARRAY(W_SINEXMAP_TARGET_FRZ_ACNT,
                                 W_UAGSERV_NODAL_BRN_ACNUM,
                                 1,
                                 0,
                                 0);

              END IF;
              IF (TRIM(PKG_ACNTS_VALID.P_ACNTS_CLOSURE_DATE) IS NOT NULL) THEN

                MOVE_EXCEP_ARRAY(W_SINEXMAP_TARGET_AC_CLOSED,
                                 W_UAGSERV_NODAL_BRN_ACNUM,
                                 1,
                                 0,
                                 0);

              END IF;

              CHECK_DORMANT_INOPERATIVE(1);

              IF PKG_ACNTS_VALID.P_ACCOUNT_STATUS = '1' THEN
                W_ERROR := 'UTILITY TARGET ACCOUNT IS INVALID';
                RAISE USR_EXCEPTION;
              END IF;
            END IF;

            W_ACNTS_BRN_CODE  := PKG_ACNTS_VALID.P_ACNTS_BRN_CODE;
            W_ACNTS_CURR_CODE := PKG_ACNTS_VALID.P_ACNTS_CURR_CODE;
          END READACNTSUTILI;
        END IF;
        IF (W_ABORT_FLAG <> '1') THEN
          IDX := IDX + 1;
          -- Commented as per Requirement (agk-22-11-2007)                    PKG_AUTOPOST.PV_TRAN_REC(IDX).TRAN_VALUE_DATE := W_DUE_DATE;
          POST_ARRAY_ASSIGN(W_ACNTS_BRN_CODE,
                            ' ',
                            W_UAGSERV_NODAL_BRN_ACNUM,
                            'C',
                            W_ACNTS_CURR_CODE,
                            W_SIN_AMT,
                            IDX);
        END IF;
      END CREDIT_FROM_UILITY_AGENCY;
      --************************************************************************************************
      PROCEDURE CREDIT_FROM_TRANSFER(L IN NUMBER) IS
        W_T_IND            NUMBER;
        W_TOTAL_TARGET_AMT NUMBER;
        W_T_AMT            NUMBER;
      BEGIN
        W_T_IND            := 0;
        W_TOTAL_TARGET_AMT := 0;
        W_REM_AMT          := W_SIN_AMT;
        FOR IDX_REC_DEP IN (SELECT SINDBTRFDISP_ACNT_NUM,
                                   SINDBTRFDISP_GL_BRN_CODE,
                                   SINDBTRFDISP_GLACC_CODE,
                                   SINDBTRFDISP_AMT_CURR,
                                   SINDBTRFDISP_AMT_TOBE_TRFD
                              FROM SINDBTRFDISP
                              WHERE SINDBTRFDISP_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND  SINDBTRFDISP_BRN_CODE = SINDB_REC(L)
                            .V_SINDB_BRN_CODE
                               AND SINDBTRFDISP_SIN_NUM = SINDB_REC(L)
                            .V_SINDB_SIN_NUM
                             ORDER BY SINDBTRFDISP_DTL_SL) LOOP
          W_T_IND := W_T_IND + 1;

          W_T_AMT := 0;
          IF (IDX_REC_DEP.SINDBTRFDISP_AMT_TOBE_TRFD <> 0) THEN
            W_T_AMT := IDX_REC_DEP.SINDBTRFDISP_AMT_TOBE_TRFD;
          ELSIF (IDX_REC_DEP.SINDBTRFDISP_ACNT_NUM > 0 AND W_TARGET_IND > 0) THEN
            FOR N IN 1 .. W_TARGET_IND LOOP
              IF (IDX_REC_DEP.SINDBTRFDISP_ACNT_NUM = TARGET_ACC_DTL(N)
                 .ACC_DTL_ACCNUM) THEN
                W_T_AMT := TARGET_ACC_DTL(N).ACC_DTL_AMT;
                GOTO STEPVPROCESS;
              END IF;
            END LOOP;
            W_T_AMT := W_REM_AMT;
          ELSE
            W_T_AMT := W_REM_AMT;
          END IF;
          <<STEPVPROCESS>>
          IF (W_T_AMT > W_REM_AMT) THEN
            W_T_AMT := W_REM_AMT;
          END IF;

          IF IDX_REC_DEP.SINDBTRFDISP_ACNT_NUM <> 0 THEN
            IF PKG_ACNTS_VALID.SP_CHECK_ACNT_STATUS(PKG_ENTITY.FN_GET_ENTITY_CODE,IDX_REC_DEP.SINDBTRFDISP_ACNT_NUM,
                                                    'C') = FALSE THEN
              W_ABORT_FLAG := '1';
              IF (PKG_ACNTS_VALID.P_ACNTS_CR_FREEZED = 1) THEN

                MOVE_EXCEP_ARRAY(W_SINEXMAP_TARGET_FRZ_ACNT,
                                 IDX_REC_DEP.SINDBTRFDISP_ACNT_NUM,
                                 1,
                                 0,
                                 0);
              END IF;
              IF (PKG_ACNTS_VALID.P_ACNTS_CLOSURE_DATE IS NOT NULL) THEN
                W_ABORT_FLAG := '1';
                MOVE_EXCEP_ARRAY(W_SINEXMAP_TARGET_AC_CLOSED,
                                 IDX_REC_DEP.SINDBTRFDISP_ACNT_NUM,
                                 1,
                                 0,
                                 0);
              END IF;

              CHECK_DORMANT_INOPERATIVE(2);

              IF PKG_ACNTS_VALID.P_ACCOUNT_STATUS = '1' THEN
                W_ERROR := 'TARGET ACCOUNT IS INVALID';
                RAISE USR_EXCEPTION; --GOTO WRITEEXCEPTION; --
              END IF;
            END IF;
          END IF;

          IF (W_T_AMT > 0) THEN
            IDX := IDX + 1;
            -- Commented as per Requirement (agk-22-11-2007)                         PKG_AUTOPOST.PV_TRAN_REC(IDX).TRAN_VALUE_DATE := W_DUE_DATE;
            POST_ARRAY_ASSIGN(IDX_REC_DEP.SINDBTRFDISP_GL_BRN_CODE,
                              IDX_REC_DEP.SINDBTRFDISP_GLACC_CODE,
                              IDX_REC_DEP.SINDBTRFDISP_ACNT_NUM,
                              'C',
                              IDX_REC_DEP.SINDBTRFDISP_AMT_CURR,
                              W_T_AMT,
                              IDX);
          END IF;
          W_TOTAL_TARGET_AMT := W_TOTAL_TARGET_AMT + W_T_AMT;
          W_REM_AMT          := W_REM_AMT - W_T_AMT;
        END LOOP;
        IF (W_REM_AMT <> 0) THEN
          W_ABORT_FLAG := '1';
        END IF;
      END CREDIT_FROM_TRANSFER;
      --************************************************************************************************
      FUNCTION CONVERT_AGANST_CURR(CHG_CURR  IN VARCHAR2,
                                   ACNT_CURR IN VARCHAR2,
                                   W_AMT     IN NUMBER) RETURN NUMBER IS
        W_AGNST_AMT NUMBER;
      BEGIN
        IF (CHG_CURR <> ACNT_CURR) THEN
          SP_CALCAGNAMT(PKG_ENTITY.FN_GET_ENTITY_CODE,CHG_CURR,
                        ACNT_CURR,
                        W_AMT,
                        'M',
                        W_CBD,
                        '1',
                        W_CMNPM_MID_RATE_TYPE_PUR,
                        W_CMNPM_MID_RATE_TYPE_PUR,
                        W_AGNST_AMT,
                        V_DUMMY_N);
        ELSE
          W_AGNST_AMT := W_AMT;
        END IF;
        RETURN W_AGNST_AMT;

      END CONVERT_AGANST_CURR;
      --************************************************************************************************

      --Prasanth NS-CHN-23-12-2008-beg
      PROCEDURE READ_ACNTS_CHGACC_SUCC(L_ACCNUM          IN NUMBER,
                                       L_BRN_CODE        OUT NUMBER,
                                       L_CLOSURE_DATE    OUT DATE,
                                       L_DB_FREEZED      OUT VARCHAR2,
                                       L_ACNTS_CURR_CODE OUT VARCHAR2) IS
      BEGIN
        <<READACNTS_CHGACC_SUCC>>
        BEGIN
          SELECT ACNTS_BRN_CODE,
                 ACNTS_CLOSURE_DATE,
                 ACNTS_DB_FREEZED,
                 ACNTS_CURR_CODE
            INTO L_BRN_CODE,L_CLOSURE_DATE,L_DB_FREEZED,L_ACNTS_CURR_CODE
            FROM ACNTS
            WHERE ACNTS_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND  ACNTS_INTERNAL_ACNUM = L_ACCNUM;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            W_ERROR := 'CHARGES ACCOUNT IS INVALID';
            RAISE USR_EXCEPTION;
        END READACNTS_CHGACC_SUCC;
      END READ_ACNTS_CHGACC_SUCC;
      --Prasanth NS-CHN-23-12-2008-end

      PROCEDURE READCHGSFOR_SUCESS(L IN NUMBER) IS
        WS_SICHG_SIN_CHG_CODE      VARCHAR(6);
        W_SICHG_MAIL_CHG_CODE      VARCHAR(6);
        W_SICHG_COURIER_CHG_CODE   VARCHAR(6);
        W_SICHG_REMIT_CHG_REQD     CHAR(1);
        W_SICHG_REMIT_CHG_FACTOR   NUMBER;
        W_TOT_CHGES                NUMBER;
        W_CHARGE_CURR              VARCHAR2(4);
        W_CHARGE_AMOUNT            NUMBER;
        W_SERVICE_AMOUNT           NUMBER;
        W_REMOPRPM_ISS_COMMN_CHGCD VARCHAR(6);
        W_ACNTS_BRN_CODE           NUMBER(6);

      BEGIN
        W_TOT_CHGES          := 0;
        W_SINREMIT_REM_CODE  := '';
        W_SINREMIT_DESP_MODE := '';
        W_SINREMIT_REM_CURR  := '';

        IF (SINDB_REC(L).V_SINDB_CHGS_RECOV_ACNUM > 0) THEN
          <<READSICHGFORSUCESS>>
          BEGIN
            SELECT SICHG_SIN_CHG_CODE,
                   SICHG_MAIL_CHG_CODE,
                   SICHG_COURIER_CHG_CODE,
                   SICHG_REMIT_CHG_REQD,
                   SICHG_REMIT_CHG_FACTOR
              INTO WS_SICHG_SIN_CHG_CODE,
                   W_SICHG_MAIL_CHG_CODE,
                   W_SICHG_COURIER_CHG_CODE,
                   W_SICHG_REMIT_CHG_REQD,
                   W_SICHG_REMIT_CHG_FACTOR
              FROM SICHG
             WHERE SICHG_SIN_TYPE = SINDB_REC(L)
            .V_SINDB_SI_TYPE
               AND SICHG_EXEC_STATUS = 'S';
            IF (TRIM(WS_SICHG_SIN_CHG_CODE) IS NOT NULL) THEN
              --Prasanth NS-CHN-23-12-2008-beg
              READ_ACNTS_CHGACC_SUCC(SINDB_REC(L).V_SINDB_CHGS_RECOV_ACNUM,
                                     W_ACNTS_BRN_CODE,
                                     W_ACNTS_CLOSURE_DATE,
                                     W_ACNTS_DB_FREEZED,
                                     W_ACNTS_CURR_CODE);
              --Prasanth NS-CHN-23-12-2008-end

              PKG_CHARGES.SP_GET_CHARGES(PKG_ENTITY.FN_GET_ENTITY_CODE,SINDB_REC(L)
                                         .V_SINDB_CHGS_RECOV_ACNUM,
                                         W_ACNTS_CURR_CODE,
                                         W_SIN_AMT,
                                         WS_SICHG_SIN_CHG_CODE,
                                         'N',
                                         W_CHARGE_CURR,
                                         W_CHARGE_AMOUNT,
                                         W_SERVICE_AMOUNT,
                                         V_DUMMY_N,
                                         V_DUMMY_N,
                                         V_DUMMY_N,
                                         W_ERROR);
              IF (TRIM(W_ERROR) IS NOT NULL) THEN
                RAISE USR_EXCEPTION;
              END IF;

              IF W_CHARGE_AMOUNT + W_SERVICE_AMOUNT > 0 THEN
                W_TOT_CHGES := W_TOT_CHGES +
                               CONVERT_AGANST_CURR(W_CHARGE_CURR,
                                                   W_ACNTS_CURR_CODE,
                                                   W_CHARGE_AMOUNT +
                                                   W_SERVICE_AMOUNT);
              END IF;
              --IDX :=IDX+1;
              -- POST_ARRAY_ASSIGN(W_ACNTS_BRN_CODE,'???',0,'C',W_ACNTS_CURR_CODE,
              --                 W_CHARGE_AMOUNT,IDX);
              IF (W_CHARGE_AMOUNT + W_SERVICE_AMOUNT > 0) THEN
                PKG_CHGSSTAXPOST.SP_CHGSSTAXPOST(PKG_ENTITY.FN_GET_ENTITY_CODE,SINDB_REC(L)
                                                 .V_SINDB_BRN_CODE,
                                                 WS_SICHG_SIN_CHG_CODE,
                                                 W_CHARGE_CURR,
                                                 W_CHARGE_AMOUNT,
                                                 W_SERVICE_AMOUNT,
                                                 W_ERROR);
              END IF;
            END IF; --
            <<READREMITANCE>>
            BEGIN
              SELECT SINREMIT_REM_CODE,SINREMIT_DESP_MODE,SINREMIT_REM_CURR
                INTO W_SINREMIT_REM_CODE,
                     W_SINREMIT_DESP_MODE,
                     W_SINREMIT_REM_CURR
                FROM SINDBREMIT
                WHERE SINREMIT_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND  SINREMIT_BRN_CODE = SINDB_REC(L)
              .V_SINDB_BRN_CODE
                 AND SINREMIT_SIN_NUM = SINDB_REC(L).V_SINDB_SIN_NUM;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                W_SINREMIT_REM_CODE  := '';
                W_SINREMIT_DESP_MODE := '';
                W_SINREMIT_REM_CURR  := '';
            END READREMITANCE;

            IF ((W_SITYPECD_CREDIT_OPTION = 'DD' OR
               W_SITYPECD_CREDIT_OPTION = 'PO') AND
               W_SINREMIT_DESP_MODE = '2' AND
               TRIM(W_SICHG_MAIL_CHG_CODE) IS NOT NULL) THEN
              --DD/PO MAIL
              --Prasanth NS-CHN-23-12-2008-beg
              IF (TRIM(W_ACNTS_CURR_CODE) IS NULL) THEN
                READ_ACNTS_CHGACC_SUCC(SINDB_REC(L).V_SINDB_CHGS_RECOV_ACNUM,
                                       W_ACNTS_BRN_CODE,
                                       W_ACNTS_CLOSURE_DATE,
                                       W_ACNTS_DB_FREEZED,
                                       W_ACNTS_CURR_CODE);
              END IF;
              --Prasanth NS-CHN-23-12-2008-end

              PKG_CHARGES.SP_GET_CHARGES(PKG_ENTITY.FN_GET_ENTITY_CODE,SINDB_REC(L)
                                         .V_SINDB_CHGS_RECOV_ACNUM,
                                         W_ACNTS_CURR_CODE,
                                         W_SIN_AMT,
                                         W_SICHG_MAIL_CHG_CODE,
                                         'N',
                                         W_CHARGE_CURR,
                                         W_CHARGE_AMOUNT,
                                         W_SERVICE_AMOUNT,
                                         V_DUMMY_N,
                                         V_DUMMY_N,
                                         V_DUMMY_N,
                                         W_ERROR);
              IF (TRIM(W_ERROR) IS NOT NULL) THEN
                RAISE USR_EXCEPTION;
              END IF;

              IF W_CHARGE_AMOUNT + W_SERVICE_AMOUNT > 0 THEN
                W_TOT_CHGES := W_TOT_CHGES +
                               CONVERT_AGANST_CURR(W_CHARGE_CURR,
                                                   W_ACNTS_CURR_CODE,
                                                   W_CHARGE_AMOUNT +
                                                   W_SERVICE_AMOUNT);
              END IF;
              -- IDX :=IDX+1;
              -- POST_ARRAY_ASSIGN(W_ACNTS_BRN_CODE,'???',0,'C',W_ACNTS_CURR_CODE,
              --                 W_CHARGE_AMOUNT,IDX);
              IF (W_CHARGE_AMOUNT + W_SERVICE_AMOUNT > 0) THEN
                PKG_CHGSSTAXPOST.SP_CHGSSTAXPOST(PKG_ENTITY.FN_GET_ENTITY_CODE,SINDB_REC(L)
                                                 .V_SINDB_BRN_CODE,
                                                 W_SICHG_MAIL_CHG_CODE,
                                                 W_CHARGE_CURR,
                                                 W_CHARGE_AMOUNT,
                                                 W_SERVICE_AMOUNT,
                                                 W_ERROR);

                IF (W_ERROR IS NOT NULL) THEN
                  RAISE USR_EXCEPTION;
                END IF;
              END IF;

            END IF;

            IF ((W_SITYPECD_CREDIT_OPTION = 'DD' OR
               W_SITYPECD_CREDIT_OPTION = 'PO') AND
               W_SINREMIT_DESP_MODE = '1' AND
               TRIM(W_SICHG_COURIER_CHG_CODE) IS NOT NULL) THEN
              --DD/PO-QUERIER

              --Prasanth NS-CHN-23-12-2008-beg
              IF (TRIM(W_ACNTS_CURR_CODE) IS NULL) THEN
                READ_ACNTS_CHGACC_SUCC(SINDB_REC(L).V_SINDB_CHGS_RECOV_ACNUM,
                                       W_ACNTS_BRN_CODE,
                                       W_ACNTS_CLOSURE_DATE,
                                       W_ACNTS_DB_FREEZED,
                                       W_ACNTS_CURR_CODE);
              END IF;
              --Prasanth NS-CHN-23-12-2008-end

              PKG_CHARGES.SP_GET_CHARGES(PKG_ENTITY.FN_GET_ENTITY_CODE,SINDB_REC(L)
                                         .V_SINDB_CHGS_RECOV_ACNUM,
                                         W_ACNTS_CURR_CODE,
                                         W_SIN_AMT,
                                         W_SICHG_COURIER_CHG_CODE,
                                         'N',
                                         W_CHARGE_CURR,
                                         W_CHARGE_AMOUNT,
                                         W_SERVICE_AMOUNT,
                                         V_DUMMY_N,
                                         V_DUMMY_N,
                                         V_DUMMY_N,
                                         W_ERROR);
              IF (TRIM(W_ERROR) IS NOT NULL) THEN
                RAISE USR_EXCEPTION;
              END IF;
              IF W_CHARGE_AMOUNT + W_SERVICE_AMOUNT > 0 THEN
                W_TOT_CHGES := W_TOT_CHGES +
                               CONVERT_AGANST_CURR(W_CHARGE_CURR,
                                                   W_ACNTS_CURR_CODE,
                                                   W_CHARGE_AMOUNT +
                                                   W_SERVICE_AMOUNT);
              END IF;
              -- IDX :=IDX+1;
              -- POST_ARRAY_ASSIGN(W_ACNTS_BRN_CODE,'???',0,'C',W_ACNTS_CURR_CODE,
              --                  W_CHARGE_AMOUNT,IDX);
              IF (W_CHARGE_AMOUNT + W_SERVICE_AMOUNT > 0) THEN
                PKG_CHGSSTAXPOST.SP_CHGSSTAXPOST(PKG_ENTITY.FN_GET_ENTITY_CODE,SINDB_REC(L)
                                                 .V_SINDB_BRN_CODE,
                                                 W_SICHG_COURIER_CHG_CODE,
                                                 W_CHARGE_CURR,
                                                 W_CHARGE_AMOUNT,
                                                 W_SERVICE_AMOUNT,
                                                 W_ERROR);
                IF (W_ERROR IS NOT NULL) THEN
                  RAISE USR_EXCEPTION;
                END IF;
              END IF;
            END IF;

            IF (W_SICHG_REMIT_CHG_REQD = '1' AND
               (W_SITYPECD_CREDIT_OPTION = 'DD' OR
               W_SITYPECD_CREDIT_OPTION = 'PO')) THEN
              <<READREMOPRPM>>
              BEGIN
                SELECT REMOPRPM_ISS_COMMN_CHGCD
                  INTO W_REMOPRPM_ISS_COMMN_CHGCD
                  FROM REMOPRPM
                 WHERE REMOPRPM_REMIT_CODE = W_SINREMIT_REM_CODE
                   AND REMOPRPM_DCHANNEL_CODE = ' '
                   AND REMOPRPM_CURR_CODE = W_SINREMIT_REM_CURR;
                IF (TRIM(W_REMOPRPM_ISS_COMMN_CHGCD) IS NOT NULL) THEN
                  PKG_CHARGES.SP_GET_CHARGES(PKG_ENTITY.FN_GET_ENTITY_CODE,SINDB_REC(L)
                                             .V_SINDB_CHGS_RECOV_ACNUM,
                                             W_ACNTS_CURR_CODE,
                                             W_SIN_AMT,
                                             W_REMOPRPM_ISS_COMMN_CHGCD,
                                             'N',
                                             W_CHARGE_CURR,
                                             W_CHARGE_AMOUNT,
                                             W_SERVICE_AMOUNT,
                                             V_DUMMY_N,
                                             V_DUMMY_N,
                                             V_DUMMY_N,
                                             W_ERROR);
                  --W_CHARGE_AMOUNT:=CONVERT_AGANST_CURR(W_CHARGE_CURR,W_ACNTS_CURR_CODE,W_CHARGE_AMOUNT);
                  --W_SERVICE_AMOUNT:=CONVERT_AGANST_CURR(W_CHARGE_CURR,W_ACNTS_CURR_CODE,W_SERVICE_AMOUNT);
                  IF (W_SICHG_REMIT_CHG_FACTOR > 0) THEN
                    W_CHARGE_AMOUNT  := W_CHARGE_AMOUNT *
                                        W_SICHG_REMIT_CHG_FACTOR / 100;
                    W_CHARGE_AMOUNT  := TO_NUMBER(SP_GETFORMAT(PKG_ENTITY.FN_GET_ENTITY_CODE,W_ACNTS_CURR_CODE,
                                                               W_CHARGE_AMOUNT));
                    W_SERVICE_AMOUNT := W_SERVICE_AMOUNT *
                                        W_SICHG_REMIT_CHG_FACTOR / 100;
                    W_SERVICE_AMOUNT := TO_NUMBER(SP_GETFORMAT(PKG_ENTITY.FN_GET_ENTITY_CODE,W_ACNTS_CURR_CODE,
                                                               W_SERVICE_AMOUNT));
                  END IF;
                  W_CHARGE_AMOUNT_REMIT  := W_CHARGE_AMOUNT;
                  W_SERVICE_AMOUNT_REMIT := W_SERVICE_AMOUNT;

                  IF TRIM(W_SINREMIT_REM_CURR) = TRIM(W_ACNTS_CURR_CODE) THEN
                    W_CHARGE_ADD_REQ := TRUE;
                  END IF;

                  IF (W_CHARGE_AMOUNT + W_SERVICE_AMOUNT > 0) THEN
                    W_CHARGE_AMOUNT := CONVERT_AGANST_CURR(W_CHARGE_CURR,
                                                           W_ACNTS_CURR_CODE,
                                                           W_CHARGE_AMOUNT +
                                                           W_SERVICE_AMOUNT);
                  END IF;

                  W_TOT_CHGES := W_TOT_CHGES + W_CHARGE_AMOUNT;
                  -- IDX :=IDX+1;
                  -- POST_ARRAY_ASSIGN(W_ACNTS_BRN_CODE,'???',0,'C',W_ACNTS_CURR_CODE,
                  --               W_CHARGE_AMOUNT,IDX);
                  IF (W_CHARGE_AMOUNT_REMIT + W_SERVICE_AMOUNT_REMIT > 0) THEN
                    PKG_CHGSSTAXPOST.SP_CHGSSTAXPOST(PKG_ENTITY.FN_GET_ENTITY_CODE,SINDB_REC(L)
                                                     .V_SINDB_BRN_CODE,
                                                     W_REMOPRPM_ISS_COMMN_CHGCD,
                                                     W_CHARGE_CURR,
                                                     W_CHARGE_AMOUNT_REMIT,
                                                     W_SERVICE_AMOUNT_REMIT,
                                                     W_ERROR);
                    IF (W_ERROR IS NOT NULL) THEN
                      RAISE USR_EXCEPTION;
                    END IF;
                  END IF;

                END IF;

              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  NULL;
              END READREMOPRPM;
            END IF;
            IF (W_TOT_CHGES > 0) THEN
              CALLSPAVAILBAL(SINDB_REC(L).V_SINDB_CHGS_RECOV_ACNUM);
              IF (TRIM(W_ERROR) IS NOT NULL) THEN
                RAISE USR_EXCEPTION;
              END IF;

              IF PKG_ACNTS_VALID.SP_CHECK_ACNT_STATUS(PKG_ENTITY.FN_GET_ENTITY_CODE,SINDB_REC(L)
                                                      .V_SINDB_CHGS_RECOV_ACNUM,
                                                      'D') = FALSE THEN
                W_ABORT_FLAG := '1';

                IF (PKG_ACNTS_VALID.P_ACNTS_DB_FREEZED = '1') THEN
                  MOVE_EXCEP_ARRAY(W_SINEXMAP_CHGS_FRZ_ACNT,
                                   SINDB_REC(L).V_SINDB_CHGS_RECOV_ACNUM,
                                   3,
                                   W_AC_EFFBAL,
                                   0);

                END IF;
                IF (TRIM(PKG_ACNTS_VALID.P_ACNTS_CLOSURE_DATE) IS NOT NULL) THEN
                  MOVE_EXCEP_ARRAY(W_SINEXMAP_CHGS_AC_CLOSED,
                                   SINDB_REC(L).V_SINDB_CHGS_RECOV_ACNUM,
                                   3,
                                   W_AC_EFFBAL,
                                   0);
                END IF;

                CHECK_DORMANT_INOPERATIVE(3);

              END IF;
            END IF;
            IF (W_ABORT_FLAG <> '1') THEN
              IF (W_TOT_CHGES > W_AC_EFFBAL) THEN
                W_ABORT_FLAG := '1';
                MOVE_EXCEP_ARRAY(W_SINEXMAP_CHGS_INSUFF_FUNDS,
                                 SINDB_REC(L).V_SINDB_CHGS_RECOV_ACNUM,
                                 3,
                                 W_AC_EFFBAL,
                                 0);
              END IF;
            END IF;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              NULL;
          END READSICHGFORSUCESS;
        END IF;

        IF (W_ABORT_FLAG <> '1') THEN
          NULL;
          -- AUTOPOST_ARRAY_ASSIGN(ACCOUNT BRN CODE, SPACES,CHGSRECOVERYACNUM,'D', ACCOUNT CURRENCY,W_TOT_CHGS)
          IF (W_TOT_CHGES > 0) THEN
            IDX := PKG_AUTOPOST.PV_TRAN_REC.LAST;
            IDX := IDX + 1;
            POST_ARRAY_ASSIGN(W_ACNTS_BRN_CODE,
                              ' ',
                              SINDB_REC(L).V_SINDB_CHGS_RECOV_ACNUM,
                              'D',
                              W_ACNTS_CURR_CODE,
                              W_TOT_CHGES,
                              IDX);
          END IF;
          IDX := PKG_AUTOPOST.PV_TRAN_REC.LAST;
          IF (W_ABORT_FLAG <> '1') THEN
            PKG_APOST_INTERFACE.SP_POST_SODEOD_BATCH(PKG_ENTITY.FN_GET_ENTITY_CODE,'A',
                                                     IDX,
                                                     0,
                                                     W_ERR_CODE,
                                                     W_ERROR,
                                                     W_BATCH_NUMBER);
            IF (W_ERR_CODE <> '0000') THEN
              W_ERROR := FN_GET_AUTOPOST_ERR_MSG(PKG_ENTITY.FN_GET_ENTITY_CODE);
              RAISE USR_EXCEPTION;
            END IF;
          END IF;
        END IF;
        --END IF;
      END READCHGSFOR_SUCESS;

      --************************************************************************************************
      PROCEDURE READSINREMIT(L IN NUMBER) IS
      BEGIN
        SELECT SINREMIT_REM_CODE,
               SINREMIT_DESP_MODE,
               SINREMIT_REM_CURR,
               SINREMIT_REM_AMT,
               SINREMIT_BENEF_CODE,
               SINREMIT_BENF_NAME,
               SINREMIT_BENF_NAME1,
               SINREMIT_ON_ACCOUNT_OF,
               SINREMIT_DRAWN_BANK,
               SINREMIT_DRAWN_BRN
          INTO W_SINREMIT_REM_CODE,
               W_SINREMIT_DESP_MODE,
               W_SINREMIT_REM_CURR,
               W_SINREMIT_REM_AMT,
               W_SINREMIT_BENEF_CODE,
               W_SINREMIT_BENF_NAME,
               W_SINREMIT_BENF_NAME1,
               W_SINREMIT_ON_ACCOUNT_OF,
               W_SINREMIT_DRAWN_BANK,
               W_SINREMIT_DRAWN_BRN
          FROM SINDBREMIT
          WHERE SINREMIT_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND  SINREMIT_BRN_CODE = SINDB_REC(L)
        .V_SINDB_BRN_CODE
           AND SINREMIT_SIN_NUM = SINDB_REC(L).V_SINDB_SIN_NUM;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          W_ERROR := 'REMITANCE NOT PRESENT SINDBREMIT';
          RAISE USR_EXCEPTION;
      END READSINREMIT;
      --************************************************************************************************
      PROCEDURE UPDDATEDDPO(L IN NUMBER) IS
        W_ACNTS_AC_NAME1 VARCHAR(50);
      BEGIN
        PKG_DDPOUPDATE.DDPOISS_REC.DDPOISS_BRN_CODE   := SINDB_REC(L)
                                                        .V_SINDB_BRN_CODE;
        PKG_DDPOUPDATE.DDPOISS_REC.DDPOISS_REMIT_CODE := W_SINREMIT_REM_CODE;
        PKG_DDPOUPDATE.DDPOISS_REC.DDPOISS_ISSUE_DATE := W_CBD;

        PKG_DDPOUPDATE.DDPOISS_VALREC.DDPOISS_PUR_ACNT       := W_REMIT_ACCNUM;
        PKG_DDPOUPDATE.DDPOISS_VALREC.DDPOISS_PUR_CLIENT_NUM := SINDB_REC(L)
                                                               .V_SINDB_CLIENT_NUM;
        IF (W_REMIT_ACCNUM = 0) THEN
          PKG_DDPOUPDATE.DDPOISS_VALREC.DDPOISS_PUR_NAME := ' ';
        ELSE
          SELECT ACNTS_AC_NAME1
            INTO W_ACNTS_AC_NAME1
            FROM ACNTS
            WHERE ACNTS_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND  ACNTS_INTERNAL_ACNUM = W_REMIT_ACCNUM;
          PKG_DDPOUPDATE.DDPOISS_VALREC.DDPOISS_PUR_NAME := W_ACNTS_AC_NAME1;
        END IF;
        PKG_DDPOUPDATE.DDPOISS_VALREC.DDPOISS_INST_CURRENCY   := W_SINREMIT_REM_CURR;
        PKG_DDPOUPDATE.DDPOISS_VALREC.DDPOISS_TOT_INST_AMT    := W_SINREMIT_REM_AMT;
        PKG_DDPOUPDATE.DDPOISS_VALREC.DDPOISS_TOT_ACTUAL_COMM := W_CHARGE_AMOUNT_REMIT;
        PKG_DDPOUPDATE.DDPOISS_VALREC.DDPOISS_TOT_STAX_AMT    := W_SERVICE_AMOUNT_REMIT;

        PKG_DDPOUPDATE.DDPOISS_VALREC.DDPOISS_TOT_DB_AMT := W_SIN_AMT;

        IF W_CHARGE_ADD_REQ = TRUE THEN
          PKG_DDPOUPDATE.DDPOISS_VALREC.DDPOISS_TOT_DB_AMT := PKG_DDPOUPDATE.DDPOISS_VALREC.DDPOISS_TOT_DB_AMT +
                                                              NVL(W_CHARGE_AMOUNT_REMIT,
                                                                  0) +
                                                              NVL(W_SERVICE_AMOUNT_REMIT,
                                                                  0);
        END IF;
        IF (W_BATCH_NUMBER <> 0) THEN
          PKG_DDPOUPDATE.DDPOISS_VALREC.POST_TRAN_BRN       := SINDB_REC(L)
                                                              .V_SINDB_BRN_CODE;
          PKG_DDPOUPDATE.DDPOISS_VALREC.POST_TRAN_DATE      := W_CBD;
          PKG_DDPOUPDATE.DDPOISS_VALREC.POST_TRAN_BATCH_NUM := W_BATCH_NUMBER;
        END IF;
        PKG_DDPOUPDATE.DDPOISS_VALREC.DDPOISS_USER_ID           := PKG_EODSOD_FLAGS.PV_USER_ID;
        PKG_DDPOUPDATE.DDPOISSDTL_VALREC.DDPOISSDTL_INST_BANK   := W_SINREMIT_DRAWN_BANK;
        PKG_DDPOUPDATE.DDPOISSDTL_VALREC.DDPOISSDTL_INST_BRN    := W_SINREMIT_DRAWN_BRN;
        PKG_DDPOUPDATE.DDPOISSDTL_VALREC.DDPOISSDTL_BENEF_CODE  := W_SINREMIT_BENEF_CODE;
        PKG_DDPOUPDATE.DDPOISSDTL_VALREC.DDPOISSDTL_BENEF_NAME1 := W_SINREMIT_BENF_NAME;
        PKG_DDPOUPDATE.DDPOISSDTL_VALREC.DDPOISSDTL_BENEF_NAME2 := W_SINREMIT_BENF_NAME1;
        PKG_DDPOUPDATE.DDPOISSDTL_VALREC.DDPOISSDTL_ON_AC_OF    := W_SINREMIT_ON_ACCOUNT_OF;
        PKG_DDPOUPDATE.SP_DDPOUPDATE(PKG_ENTITY.FN_GET_ENTITY_CODE);
        W_DDPOKEY := PKG_DDPOUPDATE.DDPO_KEY; --CHG ARUN 21-11-2007
        IF (TRIM(PKG_DDPOUPDATE.DDPO_ERR_MSG) IS NOT NULL) THEN
          W_ERROR := PKG_DDPOUPDATE.DDPO_ERR_MSG;
          RAISE USR_EXCEPTION;
        END IF;
      END UPDDATEDDPO;
      --************************************************************************************************

      PROCEDURE POST_PROCESS(K IN NUMBER) IS
      BEGIN

        W_REM_AMT := 0;
        DEBIT_FOR_SRCFNDAC(K);
        IF W_ABORT_FLAG <> '1' THEN
          IF (SINDB_REC(K).V_SINDB_UAGENCY_PAYMENT = '1') THEN
            CREDIT_FROM_UILITY_AGENCY(K);
          ELSIF (W_SITYPECD_CREDIT_OPTION = 'T') THEN
            CREDIT_FROM_TRANSFER(K);
          ELSIF (W_SITYPECD_CREDIT_OPTION = 'DD' OR
                W_SITYPECD_CREDIT_OPTION = 'PO') THEN
            READSINREMIT(K);
            PKG_DDPO_CREDIT_POST.SP_DDPO_CREDIT_POST(PKG_ENTITY.FN_GET_ENTITY_CODE,SINDB_REC(K)
                                                     .V_SINDB_BRN_CODE,
                                                     W_SINREMIT_REM_CODE,
                                                     W_SINREMIT_REM_CURR,
                                                     W_SINREMIT_REM_AMT,
                                                     W_DUE_DATE);
          END IF;
          IF W_ABORT_FLAG <> '1' THEN
            READCHGSFOR_SUCESS(K);
          END IF;
        END IF;
        IF (W_ABORT_FLAG <> '1') THEN
          IF (W_SITYPECD_CREDIT_OPTION = 'DD' OR
             W_SITYPECD_CREDIT_OPTION = 'PO') THEN
            READSINREMIT(K);
            UPDDATEDDPO(K);
          END IF;
        END IF;
        IF (W_ABORT_FLAG = '1') THEN
          PKG_AUTOPOST.PV_TRAN_REC.DELETE;
          IDX := 0;
          ABORT_PROCESS(K);
        ELSE
          /*                    INSERT_SINEXECSTAT(SINDB_REC(K) .V_SINDB_BRN_CODE,
                                                 SINDB_REC(K) .V_SINDB_SIN_NUM);
          */
          UPDATE_SINEXECSTAT(SINDB_REC(K).V_SINDB_BRN_CODE,
                             SINDB_REC(K).V_SINDB_SIN_NUM,
                             'S');

          SINEXECLOG_UPDATE(SINDB_REC(K).V_SINDB_BRN_CODE,
                            SINDB_REC(K).V_SINDB_SIN_NUM,
                            SINDB_REC(K).V_SINDB_BRN_CODE,
                            W_CBD,
                            W_BATCH_NUMBER,
                            'S');
          NULL; --DISCUSS
        END IF;
      END POST_PROCESS;
      --************************************************************************************************
      PROCEDURE GET_STANDING_INS_INFO IS
        QURYSTR VARCHAR2(3300);
      BEGIN
        QURYSTR := 'SELECT SINDB_BRN_CODE, SINDB_SIN_NUM, SINDB_EXE_FREQ,
                   SINDB_START_DATE, SINDB_END_DATE, SINDB_WEEK_DAY,
                   SINDB_FORTNIGHT1, SINDB_FORTNIGHT2, SINDB_MON_DAY_CHOICE,
                   SINDB_MONTHLY_DAY, SINDB_MON_EXE_WEEKDAY, SINDB_WEEK_SEQ_MON,
                   SINDB_QHY_FREQ_MONTH, SINDB_QHY_FREQ_DAY, SINDB_HOLIDAY_CHOICE,
                   SINDB_TIME_CHOICE, SINDB_EXEC_FAILURE_DAYS,SINDB_SI_TYPE,
                   SINDB_TRIGGER_CHK_ACNUM, SINDB_TRIGGER_AMT,SINDB_BAL_TRIGGER_CHOICE,
                   SINDB_DISPOSAL_CURR, SINDB_DISPOSAL_TYPE,
                   SINDB_FIXED_AMT, SINDB_FLOAT_AMT_CHOICE,
                   SINDB_RND_OFF_AMT_CHOICE, SINDB_RND_OFF_FACTOR,
                   SINDB_SPECIFIED_BAL_AMT, SINDB_CUT_OFF_BAL_SRC_AMT,
                   SINDB_CHGS_RECOV_ACNUM,SINDB_REM_NOTES1,
                   SINDB_REM_NOTES2, SINDB_REM_NOTES3,SINDB_UAGENCY_PAYMENT,
                   SINDB_CLIENT_NUM
                    FROM SINDB WHERE SINDB_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND  SINDB_SIN_ENTRY_TYPE <> ''D''
                   AND SINDB_CANCEL_DATE IS NULL
                   AND ((SINDB_TIME_CHOICE <> ''2'' AND ' ||
                   CHR(39) || W_RUN_TYPE || CHR(39) ||
                   '=''S'')
                   OR (SINDB_TIME_CHOICE <> ''1'' AND ' ||
                   CHR(39) || W_RUN_TYPE || CHR(39) || '=''E''))';

        IF (W_RUN_BRANCH > 0) THEN
          QURYSTR := QURYSTR || ' AND SINDB_BRN_CODE=' || W_RUN_BRANCH;
        END IF;

        IF (W_RUN_SIN_NO > 0) THEN
          QURYSTR := QURYSTR || ' AND SINDB_SIN_NUM=' || W_RUN_SIN_NO;
        END IF;

        QURYSTR := QURYSTR || ' ORDER BY SINDB_SIN_NUM';

        EXECUTE IMMEDIATE QURYSTR BULK COLLECT
          INTO SINDB_REC;

        IF SINDB_REC.FIRST IS NOT NULL THEN

          FOR J IN SINDB_REC.FIRST .. SINDB_REC.LAST LOOP
            INIT_LOOP_VARIABLE;
            W_PROCESS_SL     := J;
            W_SINDB_EXE_FREQ := SINDB_REC(J).V_SINDB_EXE_FREQ;
            --****************************------------ find due date start
            IF (W_SINDB_EXE_FREQ = 'D') THEN
              W_DUE_DATE := W_CBD;
            ELSIF (W_SINDB_EXE_FREQ = 'W') THEN
              WEEKLY_DUE_DATE(SINDB_REC(J).V_SINDB_WEEK_DAY);
            ELSIF (W_SINDB_EXE_FREQ = 'F') THEN
              FORTNIGHTLY_DUE_DATE(SINDB_REC(J).V_SINDB_FORTNIGHT1,
                                   SINDB_REC(J).V_SINDB_FORTNIGHT2);
            ELSIF (W_SINDB_EXE_FREQ = 'M') THEN
              MONTHLY_DUE_DATE(SINDB_REC(J).V_SINDB_MON_DAY_CHOICE,
                               SINDB_REC(J).V_SINDB_MONTHLY_DAY,
                               SINDB_REC(J).V_SINDB_MON_EXE_WEEKDAY,
                               SINDB_REC(J).V_SINDB_WEEK_SEQ_MON);
            ELSIF (W_SINDB_EXE_FREQ = 'Q') THEN
              QUARTERLY_DUE_DATE(SINDB_REC(J).V_SINDB_QHY_FREQ_MONTH,
                                 SINDB_REC(J).V_SINDB_QHY_FREQ_DAY);
            ELSIF (W_SINDB_EXE_FREQ = 'H') THEN
              HALFYEARLY_DUE_DATE(SINDB_REC(J).V_SINDB_QHY_FREQ_MONTH,
                                  SINDB_REC(J).V_SINDB_QHY_FREQ_DAY);
            ELSIF (W_SINDB_EXE_FREQ = 'Y') THEN
              YEARLY_DUE_DATE(SINDB_REC(J).V_SINDB_QHY_FREQ_MONTH,
                              SINDB_REC(J).V_SINDB_QHY_FREQ_DAY);
            END IF;
            --****************************------------ find due date end

            --****************************------------ Already Sucess or Not(step13)
            <<START_SINEXECSTAT_PROCESS>>
            BEGIN
              SELECT SINEXECSTAT_STATUS_OF_EXEC
                INTO W_SINEXECSTAT_STATUS_OF_EXEC
                FROM SINEXECSTAT
                WHERE SINEXECSTAT_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND  SINEXECSTAT_BRN_CODE = SINDB_REC(J)
              .V_SINDB_BRN_CODE
                 AND SINEXECSTAT_SIN_NUM = SINDB_REC(J)
              .V_SINDB_SIN_NUM
                 AND SINEXECSTAT_DUE_DATE_OF_EXEC = W_DUE_DATE;
              IF (W_SINEXECSTAT_STATUS_OF_EXEC = 'S') THEN
                GOTO LOOP_START;
              END IF;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                W_ERROR := '';
            END START_SINEXECSTAT_PROCESS;

            --****************************------------
            --****************************------------ Check Holiday Choice(step14)
            IF (W_DUE_DATE < W_CBD) THEN
              IF (SINDB_REC(J).V_SINDB_HOLIDAY_CHOICE = 2) THEN
                GOTO STEP15PROCESS;
              ELSE
                GOTO STEP17PROCESS;
              END IF;
            ELSIF (W_DUE_DATE > W_CBD) THEN
              IF (SINDB_REC(J).V_SINDB_HOLIDAY_CHOICE = 1) THEN
                GOTO STEP15PROCESS;
              ELSE
                GOTO LOOP_START;
              END IF;
            END IF;
            --****************************------------
            --****************************------------   find holidaystart and end date(step15)
            <<STEP15PROCESS>>
            BEGIN
              IF (W_DUE_DATE < W_CBD) THEN
                W_HOLIDAY_START_DATE := W_DUE_DATE;
                W_HOLIDAY_END_DATE   := W_CBD - 1;
                GOTO STEP16PROCESS;
              ELSIF (W_DUE_DATE > W_CBD) THEN
                W_HOLIDAY_START_DATE := W_CBD + 1;
                W_HOLIDAY_END_DATE   := W_DUE_DATE;
                GOTO STEP16PROCESS;
              ELSE
                GOTO STEP18PROCESS;
              END IF;
            END STEP15PROCESS;
            --****************************------------
            --****************************------------all the days are holiday between holiday_start and end_date (step16)
            <<STEP16PROCESS>>
            BEGIN
              IF (CHECKHOLDAYS(W_HOLIDAY_START_DATE,W_HOLIDAY_END_DATE)) THEN
                GOTO STEP18PROCESS;
              ELSE
                IF (W_DUE_DATE < W_CBD) THEN
                  GOTO STEP17PROCESS;
                ELSE
                  GOTO LOOP_START;
                END IF;
              END IF;
            END STEP16PROCESS;
            --****************************------------
            --****************************------------ find number of retries (step17)
            <<STEP17PROCESS>>
            BEGIN
              <<STARTREADINEXECSTAT>>
              BEGIN
                SELECT SINEXECSTAT_NUM_EXEC_ATTMPTS
                  INTO W_SINEXECSTAT_NUM_EXEC_ATTMPTS
                  FROM SINEXECSTAT
                  WHERE SINEXECSTAT_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND  SINEXECSTAT_BRN_CODE = SINDB_REC(J)
                .V_SINDB_BRN_CODE
                   AND SINEXECSTAT_SIN_NUM = SINDB_REC(J)
                .V_SINDB_SIN_NUM
                   AND SINEXECSTAT_DUE_DATE_OF_EXEC = W_DUE_DATE;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  W_SINEXECSTAT_NUM_EXEC_ATTMPTS := 0;
              END STARTREADINEXECSTAT;

              --                              IF (W_SINEXECSTAT_NUM_EXEC_ATTMPTS <
              --                                 SINDB_REC(J) .V_SINDB_EXEC_FAILURE_DAYS)  THEN
              -- 30/10/2007-added
              IF (W_SINEXECSTAT_NUM_EXEC_ATTMPTS < SINDB_REC(J)
                 .V_SINDB_EXEC_FAILURE_DAYS) AND
                 NVL(W_SINEXECSTAT_NUM_EXEC_ATTMPTS,0) > 0 THEN
                GOTO STEP18PROCESS;
              ELSE
                GOTO LOOP_START;
              END IF;
            END STEP17PROCESS;
            --****************************------------
            --****************************------------find duedate is between start and end date(step18)
            <<STEP18PROCESS>>
            BEGIN
              IF (W_DUE_DATE >= SINDB_REC(J).V_SINDB_START_DATE) THEN
                IF (SINDB_REC(J).V_SINDB_END_DATE IS NOT NULL) THEN
                  IF (W_DUE_DATE <= SINDB_REC(J).V_SINDB_END_DATE) THEN
                    GOTO STEP19PROCESS;
                  ELSE
                    GOTO LOOP_START;
                  END IF;
                ELSE
                  GOTO STEP19PROCESS;
                END IF;
              ELSE
                GOTO LOOP_START;
              END IF;
            END STEP18PROCESS;
            --****************************------------
            --****************************------------check sinexection disable or not(step19)
            <<STEP19PROCESS>>
            BEGIN
              <<STARTREADSINSTATUS>>
              BEGIN
                SELECT SINSTAT_STATUS,
                       SINSTAT_STOP_EXEC_FROM_DT,
                       SINSTAT_STOP_EXEC_UPTO_DT
                  INTO W_SINSTAT_STATUS,
                       W_SINSTAT_STOP_EXEC_FROM_DT,
                       W_SINSTAT_STOP_EXEC_UPTO_DT
                  FROM SINSTATUS
                  WHERE SINSTAT_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND  SINSTAT_BRN_CODE = SINDB_REC(J)
                .V_SINDB_BRN_CODE
                   AND SINSTAT_SIN_NUM = SINDB_REC(J).V_SINDB_SIN_NUM;
                IF (W_SINSTAT_STATUS = 'E') THEN
                  GOTO STEP20PROCESS;
                END IF;
                IF (W_SINSTAT_STATUS = 'D') THEN
                  IF (W_DUE_DATE >= W_SINSTAT_STOP_EXEC_FROM_DT AND
                     W_SINSTAT_STOP_EXEC_UPTO_DT IS NULL) THEN
                    GOTO LOOP_START;
                  ELSIF (W_DUE_DATE >= W_SINSTAT_STOP_EXEC_FROM_DT AND
                        W_DUE_DATE <= W_SINSTAT_STOP_EXEC_UPTO_DT) THEN
                    GOTO LOOP_START;
                  ELSE
                    GOTO STEP20PROCESS;
                  END IF;
                END IF;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  W_SINSTAT_STATUS            := '';
                  W_SINSTAT_STOP_EXEC_FROM_DT := NULL;
                  W_SINSTAT_STOP_EXEC_UPTO_DT := NULL;
                  GOTO STEP20PROCESS;
              END STARTREADSINSTATUS;
            END STEP19PROCESS;
            --****************************------------
            --****************************------------ find standing instruction type code trigger type (step20)
            <<STEP20PROCESS>>
            BEGIN
              <<STARTREADSITYPECD>>
              BEGIN
                SELECT SITYPECD_TRIGGER_TYPE,
                       SITYPECD_CREDIT_OPTION,
                       SITYPECD_TRAN_CODE
                  INTO W_SITYPECD_TRIGGER_TYPE,
                       W_SITYPECD_CREDIT_OPTION,
                       W_SITYPECD_TRAN_CODE
                  FROM SITYPECD
                 WHERE SITYPECD_CODE = SINDB_REC(J).V_SINDB_SI_TYPE;
                IF (W_SITYPECD_TRIGGER_TYPE = 1) THEN
                  GOTO STEP22PROCESS;
                ELSE
                  GOTO STEP21PROCESS;
                END IF;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  W_ERROR := 'INVALID STANDING INSTRUCTION CODE';
                  GOTO WRITEEXCEPTION;
              END STARTREADSITYPECD;
            END STEP20PROCESS;
            --****************************------------
            --****************************------------Account trigger process start(step21)
            <<STEP21PROCESS>>
            BEGIN
              W_TRIGGER_OK := 1;
              IF (SINDB_REC(J).V_SINDB_TRIGGER_CHK_ACNUM = 0) THEN
                W_ERROR := 'TRIGGER ACCOUNT NUMBER NOT PRESENT';
                GOTO WRITEEXCEPTION;
              END IF;
              <<STARTREADACNTS>>
              BEGIN
                SELECT ACNTS_CLOSURE_DATE
                  INTO W_ACNTS_CLOSURE_DATE
                  FROM ACNTS
                  WHERE ACNTS_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND  ACNTS_INTERNAL_ACNUM = SINDB_REC(J)
                .V_SINDB_TRIGGER_CHK_ACNUM;
                IF (W_ACNTS_CLOSURE_DATE IS NOT NULL) THEN
                  W_ERROR := 'TRIGGER ACCOUNT NUMBER CLOSED';
                  GOTO WRITEEXCEPTION;
                END IF;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  W_ERROR := 'TRIGGER ACCOUNT NUMBER INVALID';
                  GOTO WRITEEXCEPTION;
              END STARTREADACNTS;
              SP_AVLBAL(PKG_ENTITY.FN_GET_ENTITY_CODE,SINDB_REC(J).V_SINDB_TRIGGER_CHK_ACNUM,
                        V_DUMMY_C,
                        W_AC_AUTH_BAL,
                        V_DUMMY_N,
                        V_DUMMY_N,
                        V_DUMMY_N,
                        V_DUMMY_N,
                        V_DUMMY_N,
                        V_DUMMY_N,
                        V_DUMMY_N,
                        V_DUMMY_N,
                        V_DUMMY_N,
                        V_DUMMY_N,
                        UNUSED_LIMIT,
                        V_DUMMY_N,
                        V_DUMMY_N,
                        V_DUMMY_N,
                        V_DUMMY_N,
                        V_DUMMY_N,
                        V_DUMMY_N,
                        V_DUMMY_N,
                        V_DUMMY_N,
                        V_DUMMY_N,
                        V_DUMMY_D,
                        V_DUMMY_C,
                        V_DUMMY_D,
                        V_DUMMY_C,
                        V_DUMMY_C,
                        V_DUMMY_C,
                        V_DUMMY_C,
                        W_TOT_LMT_AMT,
                        V_DUMMY_N,
                        W_ERROR,
                        V_DUMMY_C,
                        V_DUMMY_N,
                        V_DUMMY_N,
                        V_DUMMY_N,
                        V_DUMMY_N,
                        V_DUMMY_N,
                        V_DUMMY_N,
                        V_DUMMY_N,
                        V_DUMMY_N);
              IF (TRIM(W_ERROR) IS NOT NULL) THEN
                RAISE USR_EXCEPTION;
              END IF;
              IF (SINDB_REC(J).V_SINDB_BAL_TRIGGER_CHOICE = 1) THEN
                IF (W_TOT_LMT_AMT > 0 AND W_AC_AUTH_BAL < 0 AND
                   UNUSED_LIMIT = 0) THEN
                  W_TRIGGER_OK := 1;
                ELSIF (W_TOT_LMT_AMT = 0 AND W_AC_AUTH_BAL < 0) THEN
                  W_TRIGGER_OK := 1;
                ELSE
                  W_TRIGGER_OK := 0;
                END IF;
              ELSIF (SINDB_REC(J).V_SINDB_BAL_TRIGGER_CHOICE = 2) THEN
                IF (W_AC_AUTH_BAL > SINDB_REC(J).V_SINDB_TRIGGER_AMT) THEN
                  W_TRIGGER_OK := 1;
                ELSE
                  W_TRIGGER_OK := 0;
                END IF;
              ELSIF (SINDB_REC(J).V_SINDB_BAL_TRIGGER_CHOICE = 3) THEN
                IF (W_AC_AUTH_BAL < SINDB_REC(J).V_SINDB_TRIGGER_AMT) THEN
                  W_TRIGGER_OK := 1;
                ELSE
                  W_TRIGGER_OK := 0;
                END IF;
              ELSIF (SINDB_REC(J).V_SINDB_BAL_TRIGGER_CHOICE = 4) THEN
                IF (W_AC_AUTH_BAL > 0 AND W_AC_AUTH_BAL > SINDB_REC(J)
                   .V_SINDB_TRIGGER_AMT) THEN
                  W_TRIGGER_OK := 1;
                ELSE
                  W_TRIGGER_OK := 0;
                END IF;
              END IF;
              IF (W_TRIGGER_OK = 1) THEN
                GOTO STEP22PROCESS;
              ELSE
                GOTO LOOP_START;
              END IF;
            END STEP21PROCESS;
            --****************************------------
            <<STEP22PROCESS>>
            BEGIN
              W_ABORT_FLAG      := '0';
              W_EXCEPTION_IND   := 0;
              W_SIN_CURR_CODE   := SINDB_REC(J).V_SINDB_DISPOSAL_CURR;
              W_SIN_AMT         := 0;
              W_TARGET_IND      := 0;
              W_SOURCE_IND      := 0;
              W_ACNTS_CURR_CODE := NULL;
              W_OVERDRAWAL_AMT  := 0;
              W_AC_EFFBAL       := 0;
              W_LIMIT_AVL       := NULL;
              W_EACH_AMT        := 0;
              IDX               := 0;
              EXCEP_ARRAY.DELETE;
              TARGET_ACC_DTL.DELETE;
              SOUCRCE_ACC_DTL.DELETE;
              PKG_APOST_INTERFACE.SP_POSTING_BEGIN(PKG_ENTITY.FN_GET_ENTITY_CODE);
              SETTRANKEYVALUE(SINDB_REC(J).V_SINDB_BRN_CODE,W_CBD);
              SETTRANBATVALUE(SINDB_REC(J).V_SINDB_BRN_CODE,
                              SINDB_REC(J).V_SINDB_SIN_NUM,
                              W_DUE_DATE,
                              SINDB_REC(J).V_SINDB_REM_NOTES1,
                              SINDB_REC(J).V_SINDB_REM_NOTES2,
                              SINDB_REC(J).V_SINDB_REM_NOTES3);
              IF (SINDB_REC(J).V_SINDB_DISPOSAL_TYPE = '1') THEN
                W_SIN_AMT := SINDB_REC(J).V_SINDB_FIXED_AMT;
                GOTO STEP24PROCESS;
              ELSE
                GOTO STEP23PROCESS;
              END IF;
            END STEP22PROCESS;
            --****************************------------
            <<STEP23PROCESS>>
            BEGIN
              IF (SINDB_REC(J).V_SINDB_FLOAT_AMT_CHOICE = '1') THEN
                COM_SINDBDISPTRF_FLOAT12('1',J);
              ELSIF (SINDB_REC(J).V_SINDB_FLOAT_AMT_CHOICE = '2') THEN
                COM_SINDBDISPTRF_FLOAT12('2',J);
              ELSIF (SINDB_REC(J).V_SINDB_FLOAT_AMT_CHOICE = '3') THEN
                W_SIN_AMT := 0;
                CALLSPAVAILBAL(SINDB_REC(J).V_SINDB_TRIGGER_CHK_ACNUM);
                IF (TRIM(W_ERROR) IS NOT NULL) THEN
                  RAISE USR_EXCEPTION;
                END IF;
                IF (W_AC_AUTH_BAL <= SINDB_REC(J).V_SINDB_CUT_OFF_BAL_SRC_AMT) THEN
                  W_ABORT_FLAG := '1';
                  W_EACH_AMT   := 0;
                ELSE
                  W_EACH_AMT := W_AC_AUTH_BAL - SINDB_REC(J)
                               .V_SINDB_CUT_OFF_BAL_SRC_AMT;
                END IF;

                IF (W_EACH_AMT <> 0) THEN
                  W_EACH_AMT := FN_ROUNDOFF(PKG_ENTITY.FN_GET_ENTITY_CODE,W_EACH_AMT,
                                             SINDB_REC(J)
                                            .V_SINDB_RND_OFF_AMT_CHOICE,
                                             SINDB_REC(J)
                                            .V_SINDB_RND_OFF_FACTOR);
                END IF;

                W_SIN_AMT := W_SIN_AMT + W_EACH_AMT;
                W_TARGET_IND := W_TARGET_IND + 1;
                TARGET_ACC_DTL(W_TARGET_IND).ACC_DTL_SERIAL := W_TARGET_IND;
                TARGET_ACC_DTL(W_TARGET_IND).ACC_DTL_ACCNUM := SINDB_REC(J)
                                                              .V_SINDB_TRIGGER_CHK_ACNUM;
                TARGET_ACC_DTL(W_TARGET_IND).ACC_DTL_AMT := W_EACH_AMT;
              ELSIF (SINDB_REC(J).V_SINDB_FLOAT_AMT_CHOICE = '4') THEN
                COM_SINDBDFUNSRC_FLOAT45('4',J);
              ELSIF (SINDB_REC(J).V_SINDB_FLOAT_AMT_CHOICE = '5') THEN
                COM_SINDBDFUNSRC_FLOAT45('5',J);
              END IF;
              IF (W_ABORT_FLAG = '1') THEN
                ABORT_PROCESS(J);
                GOTO WRITEEXCEPTION;
              ELSE
                GOTO STEP24PROCESS;
              END IF;
            END STEP23PROCESS;
            --****************************------------
            <<STEP24PROCESS>>
            BEGIN
              POST_PROCESS(J);
            END STEP24PROCESS;
            --****************************------------
            <<WRITEEXCEPTION>>
            BEGIN
              IF (TRIM(W_ERROR) IS NOT NULL) THEN
                W_ERROR := W_ERROR || ' ' || SP_GET_SIN_NUMBER;

                PKG_PB_GLOBAL.DETAIL_ERRLOG(PKG_ENTITY.FN_GET_ENTITY_CODE,'X',W_ERROR,' ',0);

              END IF;
              W_ERROR      := NULL;
              W_TRIGGER_OK := 0;
            END WRITEEXCEPTION;

            <<LOOP_START>>
            DBMS_OUTPUT.PUT_LINE('--------');
            DBMS_OUTPUT.PUT_LINE('SIN_NO : ' || SINDB_REC(J).V_SINDB_SIN_NUM);
            DBMS_OUTPUT.PUT_LINE('SIN_BRANCH: ' || SINDB_REC(J)
                                 .V_SINDB_BRN_CODE);
            DBMS_OUTPUT.PUT_LINE('SIN_FREQUENCY: ' || SINDB_REC(J)
                                 .V_SINDB_EXE_FREQ);
            DBMS_OUTPUT.PUT_LINE('SINDB_WEEK_DAY: ' || SINDB_REC(J)
                                 .V_SINDB_WEEK_DAY);
            DBMS_OUTPUT.PUT_LINE('SINDB_FORTNIGHT1: ' || SINDB_REC(J)
                                 .V_SINDB_FORTNIGHT1);
            DBMS_OUTPUT.PUT_LINE('SINDB_FORTNIGHT2: ' || SINDB_REC(J)
                                 .V_SINDB_FORTNIGHT2);
            DBMS_OUTPUT.PUT_LINE('SINDB_MON_DAY_CHOICE: ' || SINDB_REC(J)
                                 .V_SINDB_MON_DAY_CHOICE);
            DBMS_OUTPUT.PUT_LINE('SINDB_MONTHLY_DAY: ' || SINDB_REC(J)
                                 .V_SINDB_MONTHLY_DAY);
            DBMS_OUTPUT.PUT_LINE('SINDB_MON_EXE_WEEKDAY: ' || SINDB_REC(J)
                                 .V_SINDB_MON_EXE_WEEKDAY);
            DBMS_OUTPUT.PUT_LINE('SINDB_WEEK_SEQ_MON: ' || SINDB_REC(J)
                                 .V_SINDB_WEEK_SEQ_MON);
            DBMS_OUTPUT.PUT_LINE('SINDB_QHY_FREQ_MONTH: ' || SINDB_REC(J)
                                 .V_SINDB_QHY_FREQ_MONTH);
            DBMS_OUTPUT.PUT_LINE('SINDB_QHY_FREQ_DAY: ' || SINDB_REC(J)
                                 .V_SINDB_QHY_FREQ_DAY);

            DBMS_OUTPUT.PUT_LINE('DUE_DATE: ' || W_DUE_DATE);
            DBMS_OUTPUT.PUT_LINE('--------');
          END LOOP;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          W_ERROR := TRIM(W_ERROR) || ' Error in GET_STANDING_INS_INFO' || ' ' ||
                     SP_GET_SIN_NUMBER || ' ' || SUBSTR(SQLERRM,1,500);

          RAISE USR_EXCEPTION;
      END GET_STANDING_INS_INFO;

      PROCEDURE DELETE_ARRAYS IS
      BEGIN
        EXCEP_ARRAY.DELETE;
        TARGET_ACC_DTL.DELETE;
        SOUCRCE_ACC_DTL.DELETE;
      END DELETE_ARRAYS;

    BEGIN
      <<START_PROCESS>>
      BEGIN

        INIT_PARA;
        CHECK_INPUT;
        ASSIGN_DATES;
        READ_SINEXMAP;
        READ_USER_BRANCH;
        READ_CMNPARAM;
        GET_STANDING_INS_INFO;
        DELETE_ARRAYS;

      EXCEPTION
        WHEN OTHERS THEN
          IF TRIM(W_ERROR) IS NULL THEN
            W_ERROR := 'Error in SP_SINPROCESS ' || SP_GET_SIN_NUMBER;
          END IF;
          PKG_EODSOD_FLAGS.PV_ERROR_MSG := W_ERROR;
          PKG_PB_GLOBAL.DETAIL_ERRLOG(PKG_ENTITY.FN_GET_ENTITY_CODE,'E',
                                      PKG_EODSOD_FLAGS.PV_ERROR_MSG,
                                      ' ',
                                      0);
          PKG_PB_GLOBAL.DETAIL_ERRLOG(PKG_ENTITY.FN_GET_ENTITY_CODE,'E',SUBSTR(SQLERRM,1,1000),' ',0);

      END START_PROCESS;
      PKG_EODSOD_FLAGS.PV_ERROR_MSG := TRIM(W_ERROR);
    END SP_SINPROCESS;
  END PKG_SINPROCESS;
/
