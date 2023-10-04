CREATE OR REPLACE PACKAGE PKG_RD_ACCRUAL IS
 
  PV_EXCESS_INT NUMBER(18,3) DEFAULT 0;
  FUNCTION FN_GET_VALUE RETURN NUMBER;

    PROCEDURE SP_RD_INTCALC(V_ENTITY_NUM IN NUMBER,P_ASON_DATE  IN DATE DEFAULT NULL,
                            P_RUN_NUMBER IN NUMBER DEFAULT 0,
                            P_RD_AC_NUM  IN NUMBER DEFAULT 0,
                            P_FROM_BRN   IN NUMBER DEFAULT 0,
                            P_UPTO_BRN   IN NUMBER DEFAULT 0,
                            P_PROD_CODE  IN NUMBER DEFAULT 0,
                            P_INT_RATE   IN  NUMBER DEFAULT 0);


    PROCEDURE start_RD_accr_brnwise(V_ENTITY_NUM IN NUMBER,P_brn_code IN NUMBER DEFAULT 0);

  END PKG_RD_ACCRUAL;
/

CREATE OR REPLACE PACKAGE BODY PKG_RD_ACCRUAL AS

    PROCEDURE SP_RD_INTCALC(V_ENTITY_NUM IN NUMBER,P_ASON_DATE  IN DATE DEFAULT NULL,
                            P_RUN_NUMBER IN NUMBER DEFAULT 0,
                            P_RD_AC_NUM  IN NUMBER DEFAULT 0,
                            P_FROM_BRN   IN NUMBER DEFAULT 0,
                            P_UPTO_BRN   IN NUMBER DEFAULT 0,
                            P_PROD_CODE  IN NUMBER DEFAULT 0,
                            P_INT_RATE   IN NUMBER DEFAULT 0) IS


      E_USEREXCEP EXCEPTION;
      V_ERR_MSG        VARCHAR2(2300);
      V_CBD            DATE;
      V_SQL            VARCHAR2(2300);
      V_START_DATE     DATE := NULL;
      V_ASON_DATE      DATE := NULL;
      V_YEAR_DIFF      NUMBER(6) DEFAULT 0;
      V_RDINS_BAL      NUMBER(18, 3) DEFAULT 0;
      V_CHARGES_BAL    NUMBER(18, 3) DEFAULT 0; 
      V_NO_DEFAULTS    NUMBER(5); --Added by Manoj
      V_ACNTBAL_AC_BAL NUMBER(18, 3) DEFAULT 0;
      V_TO_DATE        DATE := NULL;
      V_DUE_BAL        NUMBER(18, 3) DEFAULT 0;
      V_NOOF_INST_PAID NUMBER(4) DEFAULT 0;

      V_PBDCONT_TWDS_INST NUMBER(18, 3) DEFAULT 0;
      V_RDINS_INT_CR      NUMBER(18, 3) DEFAULT 0;
      V_RD_INT_NOW        NUMBER(18, 3) DEFAULT 0;
      V_INT_AMT           NUMBER(18, 3) DEFAULT 0;
      V_NOOF_DAYS         NUMBER(4) DEFAULT 0;
      V_BAL_DAYS          NUMBER(4) DEFAULT 0;
      V_RDSL              NUMBER(6) DEFAULT 0;
      V_RDINS_FREQ        CHAR(1) DEFAULT ' ';
      V_NOC               INTEGER DEFAULT 0;  
      V_REM               INTEGER DEFAULT 0;  
      V_INT_RATE          DOUBLE PRECISION DEFAULT 0;
      V_FACTOR            DOUBLE PRECISION DEFAULT 0;
      V_NUMERATOR         DOUBLE PRECISION DEFAULT 0;
      V_DENOMINATOR       DOUBLE PRECISION DEFAULT 0;
      V_BREAK_INT          NUMBER(18,3) DEFAULT 0;
      V_MAT_VALUE         NUMBER(18, 3) DEFAULT 0;
      V_CALC_SL           NUMBER(6) DEFAULT 0;
      V_BRK_SL            NUMBER(6) DEFAULT 0;
      V_RD_SL             NUMBER(6) DEFAULT 0;
      V_CTL               NUMBER(6) DEFAULT 0;
      V_EFF_DATE          DATE := NULL;
      V_RUN_NUMBER        NUMBER(8) DEFAULT 0;
      V_TOT_INST_PAID     NUMBER(18, 3) DEFAULT 0;
      V_CALC_INS          NUMBER(18, 3) DEFAULT 0;
      V_REM_AMT           NUMBER(18, 3) DEFAULT 0;
      V_SUM_MAT_VAL       NUMBER(18, 3) DEFAULT 0;
      V_DEPPR_PROD_CODE   NUMBER(4) DEFAULT 0;

      W_PREV_DATE      DATE := NULL;
      W_SBAL           NUMBER(18, 3) DEFAULT 0;
      W_CURR_MIN_BAL   NUMBER(18, 3) DEFAULT 0;
      W_CURR_YYMM      NUMBER(6) DEFAULT 0;
      W_DEPEFF_YYMM    NUMBER(6) DEFAULT 0;
      W_ASON_YYMM      NUMBER(6) DEFAULT 0;
      W_PERD           INTEGER DEFAULT 0;
      W_INT_TBC        NUMBER(18, 3) DEFAULT 0;
      W_INT_NTBC       NUMBER(18, 3) DEFAULT 0;
      W_TOT_INT        NUMBER(18, 3) DEFAULT 0;
      W_INT            NUMBER(18, 3) DEFAULT 0;
      W_PREV_DATE_YYMM NUMBER(6) DEFAULT 0;
      W_TRDATE_YYMM    NUMBER(6) DEFAULT 0;
      W_BETWEEN_MONTHS NUMBER(3) DEFAULT 0; --Sriram B - chn - 14-04-08  --AGK-26-MAY-2008 NUMBER(2) CHANGED
      V_PREV_MM        NUMBER(2); --Sriram B - chn - 18-04-08
      V_CURR_MM        NUMBER(2); --Sriram B - chn - 18-04-08
      V_PREV_yyyy      NUMBER(4); --Sriram B - chn - 18-04-08
      V_CURR_yyyy      NUMBER(4); --Sriram B - chn - 18-04-08
      W_ERRORMSG       VARCHAR2(1800);
      --Sriram B - chn - 24-03-2009 - beg
      V_BRK_MONTHS     NUMBER DEFAULT 0;
      V_BRK_DAYS       NUMBER DEFAULT 0;
      V_BROKEN_INT     DOUBLE PRECISION DEFAULT 0;
      V_DENOM                       NUMBER DEFAULT 0;
      --Sriram B - chn - 24-03-2009 - end
      V_COMP_FREQ NUMBER; -- ADDED BY BIBHU ON 24-08-2012
      V_NO_OF_COMP NUMBER;  -- ADDED BY BIBHU ON 24-08-2012
      V_NOC_RD DOUBLE PRECISION DEFAULT 0;  -- ADDED BY BIBHU ON 24-08-2012 --Modified by Manoj
      -- ADDED BY BIBHU ON 17-03-2013 BEGIN
      V_EFF_INT_RATE NUMBER(7,5);
      V_RED_FACTOR NUMBER;
      V_CALC_AMT   NUMBER(18,3);
      V_FINAL_CALC_AMT NUMBER(18,3);
      V_SIMPLE_INT NUMBER(18,3);
      V_NO_OF_INSTS_PAID NUMBER;
      V_SIMPLE_FACTOR DOUBLE PRECISION DEFAULT 0;
      V_FREQ_FACTOR NUMBER;
      V_RUN_PERD  NUMBER;
      V_RUN_DAYS  NUMBER;
      V_DENOM_SIMPLE NUMBER;

      V_NOD  NUMBER:=0;
      v_LEAN_AMOUNT  NUMBER(18,3):=0;
      v_ACNT_AVGBAL  NUMBER(18,3):=0;
      V_ORG_AC_AMT  NUMBER(18,3):=0;
      V_ACT_INT_RATE NUMBER(7,5);
      -- ADDED BY BIBHU ON 17-03-2013 END
            FUNCTION GET_ROUND_OFF_VALUE(AMOUNT      IN FLOAT,
                                   P_PROD_CODE IN NUMBER,
                                   P_CURR_CODE IN VARCHAR2,
                                   W_ERRORMSG  OUT VARCHAR2

                                   ) RETURN FLOAT ;

      -- ADDED BY BIBHU ON 17-03-2013 END
      TYPE PBDCONT IS RECORD(
        PBDCONT_BRN_CODE        NUMBER(6),
        PBDCONT_DEP_AC_NUM      NUMBER(14),
        PBDCONT_CONT_NUM        NUMBER(8),
        PBDCONT_EFF_DATE        DATE,
        PBDCONT_MAT_DATE        DATE,
        PBDCONT_INT_ACCR_UPTO   DATE,
        PBDCONT_ACTUAL_INT_RATE NUMBER(7, 5),
        DEPPR_INT_COMP_FREQ     CHAR(1),
        PBDCONT_FREQ_OF_DEP     CHAR(1),
        DEPPR_PROD_CODE         NUMBER(4),
        PBDCONT_AC_DEP_AMT      NUMBER(18, 3),
        PBDCONT_DEP_CURR        VARCHAR2(3),
        DEPPR_INT_CALC_DENOM    CHAR(1),  --Sriram B - chn - 15-05-08 - added
        DEPPR_RDINT_CALC_BASIS  CHAR(1),
        DEPPR_INT_SPECIFIED_CHOICE CHAR(1)); -- ADDED BY BIBHU ON 17-03-2013

        --Sriram B - chn - 24-03-2009 - added DEPPR_INT_CALC_DENOM

      --gkash chn 22-11-2007 beg
      v_int_accr_from DATE;
      v_int_accr_upto DATE;
      --gkash chn 22-11-2007 end
      TYPE TABPBDCONT IS TABLE OF PBDCONT INDEX BY PLS_INTEGER;
      V_PBDCONT TABPBDCONT;

       TYPE REC_DEPIRHDT IS RECORD
       (
          DEPIRHDT_EFF_FROM_DATE   DATE,
          DEPIRHDT_EFF_UPTO_DATE   DATE,
          DEPIRHDT_INT_RATE        NUMBER (18, 3)
       );

       TYPE TT_REC_DEPIRHDT IS TABLE OF REC_DEPIRHDT INDEX BY PLS_INTEGER;

       T_REC_DEPIRHDT TT_REC_DEPIRHDT;
       V_SQL_STAT VARCHAR2(4000);


      TYPE CUMMBAL IS RECORD(
        RDINS_RD_AC_NUM      NUMBER(14),
        RDINS_EFF_DATE       DATE,
        RDINS_TWDS_INSTTLMNT NUMBER(18, 3));
      TYPE TABCUMMBAL IS TABLE OF CUMMBAL INDEX BY PLS_INTEGER;
      V_CUMMBAL TABCUMMBAL;

      TYPE RDMONMINBAL IS RECORD(
        RDINS_EFF_DATE      DATE,
        --Sriram B - chn - 07-july-2010 RDINS_ENTRY_DAY_SL  NUMBER(4),
        RDINS_TWDS_INSTLMNT NUMBER(18, 3));
      TYPE TABRDMONMINBAL IS TABLE OF RDMONMINBAL INDEX BY PLS_INTEGER;
      V_RDMONMINBAL TABRDMONMINBAL;

      TYPE RDMINBAL IS RECORD(
        RDYYMM    NUMBER(6),
        MONMINBAL NUMBER(18, 3));
      TYPE TABRDMINBAL IS TABLE OF RDMINBAL INDEX BY PLS_INTEGER;
      V_RDMINBAL TABRDMINBAL;

      TYPE TABDEPCALCBRK IS TABLE OF DEPCALCBRK%ROWTYPE INDEX BY PLS_INTEGER;
      V_DEPCALCBRK TABDEPCALCBRK;

      TYPE TABDEPCALC IS TABLE OF DEPCALCAC%ROWTYPE INDEX BY PLS_INTEGER;
      V_DEPCALC TABDEPCALC;

      TYPE TABRDCALC IS TABLE OF RDCALC%ROWTYPE INDEX BY PLS_INTEGER;
      V_RDCALC TABRDCALC;

      TYPE TABDEPCALCCTL IS TABLE OF DEPCALCCTL%ROWTYPE INDEX BY PLS_INTEGER;
      V_DEPCALCCTL TABDEPCALCCTL;

      PROCEDURE UPDATE_DEPCALC IS
        RECCOUNT PLS_INTEGER;
      BEGIN
        FOR IDX IN 1 ..  V_DEPCALC .Count
           LOOP
               V_DEPCALC (IDX).DEPCAC_ENTITY_NUM := PKG_ENTITY.FN_GET_ENTITY_CODE;
         END LOOP;
        FORALL RECCOUNT IN 1 .. V_DEPCALC.COUNT
          INSERT INTO DEPCALCAC VALUES V_DEPCALC (RECCOUNT);
      EXCEPTION
        WHEN OTHERS THEN
          V_ERR_MSG := 'Error in UPDATE_DEPCALC ' || '-' || SUBSTR(SQLERRM, 1, 500);
          RAISE E_USEREXCEP;
      END UPDATE_DEPCALC;

      PROCEDURE UPDATE_DEPCALCBRK IS
        RECCOUNT PLS_INTEGER;
      BEGIN
        FOR IDX IN 1 ..  V_DEPCALCBRK .Count
           LOOP
               V_DEPCALCBRK (IDX).DEPCBRK_ENTITY_NUM := PKG_ENTITY.FN_GET_ENTITY_CODE;
         END LOOP;
        FORALL RECCOUNT IN 1 .. V_DEPCALCBRK.COUNT
          INSERT INTO DEPCALCBRK VALUES V_DEPCALCBRK (RECCOUNT);

        dbms_output.put_line(V_DEPCALCBRK(1).DEPCBRK_BRN_CODE);
        dbms_output.put_line(V_DEPCALCBRK(1).DEPCBRK_RUN_NUM);
        dbms_output.put_line(V_DEPCALCBRK(1).DEPCBRK_INTERNAL_ACNUM);
        dbms_output.put_line(V_DEPCALCBRK(1).DEPCBRK_CONTRACT_NUM);

      EXCEPTION
        WHEN OTHERS THEN
          V_ERR_MSG := 'Error in UPDATE_DEPCALCBRK ' || '-' || SUBSTR(SQLERRM, 1, 500);
          RAISE E_USEREXCEP;
      END UPDATE_DEPCALCBRK;

      PROCEDURE UPDATE_RDCALC IS
        RECCOUNT PLS_INTEGER;
      BEGIN
        FOR IDX IN 1 ..  V_RDCALC .Count
           LOOP
               V_RDCALC (IDX).RDCALC_ENTITY_NUM := PKG_ENTITY.FN_GET_ENTITY_CODE;
         END LOOP;
        FORALL RECCOUNT IN 1 .. V_RDCALC.COUNT
          INSERT INTO RDCALC VALUES V_RDCALC (RECCOUNT);

      EXCEPTION
        WHEN OTHERS THEN
          V_ERR_MSG := 'Error in UPDATE_RDCALC ' || '-' || SUBSTR(SQLERRM, 1, 500);
          RAISE E_USEREXCEP;
      END UPDATE_RDCALC;

      PROCEDURE UPDATE_DEPCALCCTL IS
        RECCOUNT PLS_INTEGER;
      BEGIN
        FOR IDX IN 1 ..  V_DEPCALCCTL .Count
           LOOP
               V_DEPCALCCTL (IDX).DEPCTL_ENTITY_NUM := PKG_ENTITY.FN_GET_ENTITY_CODE;
         END LOOP;
        FORALL RECCOUNT IN 1 .. V_DEPCALCCTL.COUNT
          INSERT INTO DEPCALCCTL VALUES V_DEPCALCCTL (RECCOUNT);

      EXCEPTION
        WHEN OTHERS THEN
          V_ERR_MSG := 'Error in UPDATE_DEPCALCCTL ' || '-' || SUBSTR(SQLERRM, 1, 500);
          RAISE E_USEREXCEP;
      END UPDATE_DEPCALCCTL;

  /* Sriram B - chn - 12-05-09 - removed beg
      --Sriram B - chn - 25-03-2009 - beg
      PROCEDURE UPDATE_TMPRDIRRBRK IS
  --      RECCOUNT PLS_INTEGER;
      BEGIN
           INSERT INTO TMPRDIRRBRK SELECT * FROM RTMPRDINTACCR;
      EXCEPTION
        WHEN OTHERS THEN
          V_ERR_MSG := 'Error in UPDATE_TMPRDIRRBRK ' || '-' || SUBSTR(SQLERRM, 1, 500);
          RAISE E_USEREXCEP;
      END UPDATE_TMPRDIRRBRK;
        --Sriram B - chn - 25-03-2009 - end
  -- Sriram B - chn - 12-05-09 - end */

      PROCEDURE DEPCALC_COLL(IDX IN NUMBER) IS
      BEGIN
        V_CALC_SL := V_CALC_SL + 1;
        V_DEPCALC(V_CALC_SL).DEPCAC_BRN_CODE := V_PBDCONT(IDX).PBDCONT_BRN_CODE;
        V_DEPCALC(V_CALC_SL).DEPCAC_RUN_NUM := V_RUN_NUMBER;
        V_DEPCALC(V_CALC_SL).DEPCAC_INTERNAL_AC_NUM := V_PBDCONT(IDX).PBDCONT_DEP_AC_NUM;
        V_DEPCALC(V_CALC_SL).DEPCAC_CONTRACT_NUM := 0;
        V_DEPCALC(V_CALC_SL).DEPCAC_PREV_ACCR_UPTO_DATE := V_PBDCONT(IDX).PBDCONT_INT_ACCR_UPTO;
        V_DEPCALC(V_CALC_SL).DEPCAC_INT_ACCR_UPTO_DATE := V_TO_DATE;
        V_DEPCALC(V_CALC_SL).DEPCAC_AC_INT_ACCR_AMT := V_RD_INT_NOW;
        V_DEPCALC(V_CALC_SL).DEPCAC_BC_INT_ACCR_AMT := V_RD_INT_NOW;
        V_DEPCALC(V_CALC_SL).DEPCAC_CRATE_TO_BASE_CURR := 1;

      EXCEPTION
        WHEN OTHERS THEN
          V_ERR_MSG := 'Error in DEPCALC_COLL ' || V_PBDCONT(IDX)
                      .PBDCONT_DEP_AC_NUM || '-' || V_PBDCONT(IDX)
                      .PBDCONT_CONT_NUM || '-' || SUBSTR(SQLERRM, 1, 500);
          RAISE E_USEREXCEP;
      END DEPCALC_COLL;

      PROCEDURE DEPCALCBRK_COLL(IDX IN NUMBER) IS
      BEGIN
        V_BRK_SL := V_BRK_SL + 1;
        V_DEPCALCBRK(V_BRK_SL).DEPCBRK_BRN_CODE := V_PBDCONT(IDX).PBDCONT_BRN_CODE;
        V_DEPCALCBRK(V_BRK_SL).DEPCBRK_RUN_NUM := V_RUN_NUMBER;
        V_DEPCALCBRK(V_BRK_SL).DEPCBRK_INTERNAL_ACNUM := V_PBDCONT(IDX).PBDCONT_DEP_AC_NUM;
        V_DEPCALCBRK(V_BRK_SL).DEPCBRK_CONTRACT_NUM := 0;
        V_DEPCALCBRK(V_BRK_SL).DEPCBRK_BRK_SL := 1;
        V_DEPCALCBRK(V_BRK_SL).DEPCBRK_INT_ACCR_FROM_DATE := V_INT_ACCR_FROM;
        V_DEPCALCBRK(V_BRK_SL).DEPCBRK_INT_ACCR_UPTO_DATE := V_INT_ACCR_UPTO;
        V_DEPCALCBRK(V_BRK_SL).DEPCBRK_INT_ACCR_AMT := V_RD_INT_NOW;
        V_DEPCALCBRK(V_BRK_SL).DEPCBRK_CALC_PERIOD_NOD := (V_TO_DATE - V_START_DATE);
        V_DEPCALCBRK(V_BRK_SL).DEPCBRK_INT_PERD_END_FLAG := 0;
        V_DEPCALCBRK(V_BRK_SL).DEPCBRK_INT_ON_AMOUNT := V_ORG_AC_AMT;
      EXCEPTION
        WHEN OTHERS THEN
          V_ERR_MSG := 'Error in DEPCALCBRK_COLL ' || V_PBDCONT(IDX)
                      .PBDCONT_DEP_AC_NUM || '-' || V_PBDCONT(IDX)
                      .PBDCONT_CONT_NUM || '-' || SUBSTR(SQLERRM, 1, 500);
          RAISE E_USEREXCEP;
      END DEPCALCBRK_COLL;

      PROCEDURE RDCALC_COLL(IDX IN NUMBER) IS
      BEGIN
        V_RD_SL := V_RD_SL + 1;
        V_RDCALC(V_RD_SL).RDCALC_BRN_CODE := V_PBDCONT(IDX).PBDCONT_BRN_CODE;
        V_RDCALC(V_RD_SL).RDCALC_DEP_AC_NUM := V_PBDCONT(IDX).PBDCONT_DEP_AC_NUM;
        V_RDCALC(V_RD_SL).RDCALC_CALC_DATE := V_CBD;
        V_RDCALC(V_RD_SL).RDCALC_AS_ON_DATE := V_ASON_DATE;
        V_RDCALC(V_RD_SL).RDCALC_RUN_NUM := V_RUN_NUMBER;
        V_RDCALC(V_RD_SL).RDCALC_NOI := V_NOOF_INST_PAID;
        V_RDCALC(V_RD_SL).RDCALC_TOT_AMT_PAID := V_RDINS_BAL;
        V_RDCALC(V_RD_SL).RDCALC_REM_MON := V_REM;
        V_SUM_MAT_VAL := V_SUM_MAT_VAL + V_MAT_VALUE;
        V_RDCALC(V_RD_SL).RDCALC_MV_ASON_DATE := V_SUM_MAT_VAL;
        V_RDCALC(V_RD_SL).RDCALC_TOT_INT := V_INT_AMT;
        V_RDCALC(V_RD_SL).RDCALC_INT_BAL := V_RDINS_INT_CR;
        V_RDCALC(V_RD_SL).RDCALC_INT_ACCR := V_RD_INT_NOW;

      EXCEPTION
        WHEN OTHERS THEN
          V_ERR_MSG := 'Error in RDCALC_COLL ' || V_PBDCONT(IDX)
                      .PBDCONT_DEP_AC_NUM || '-' || V_PBDCONT(IDX)
                      .PBDCONT_CONT_NUM || '-' || SUBSTR(SQLERRM, 1, 500);
          RAISE E_USEREXCEP;
      END RDCALC_COLL;

      PROCEDURE DEPCALCCTL_COLL(IDX IN NUMBER) IS
      BEGIN
        V_CTL := V_CTL + 1;
        V_DEPCALCCTL(V_CTL).DEPCTL_BRN_CODE := 0;
        V_DEPCALCCTL(V_CTL).DEPCTL_RUN_NUM := V_RUN_NUMBER;
        V_DEPCALCCTL(V_CTL).DEPCTL_PROD_CODE := 0;
        V_DEPCALCCTL(V_CTL).DEPCTL_RUN_DATE := V_CBD;
        V_DEPCALCCTL(V_CTL).DEPCTL_ACCRUAL_UPTO_DATE := V_TO_DATE;
        --V_DEPCALCCTL(V_CTL).DEPCTL_RUN_BY := P_USER_ID;
        V_DEPCALCCTL(V_CTL).DEPCTL_RUN_BY := pkg_eodsod_flags.PV_USER_ID;
        V_DEPCALCCTL(V_CTL).DEPCTL_RUN_ON := V_CBD;
        V_DEPCALCCTL(V_CTL).DEPCTL_POSTED_BY := '';
        V_DEPCALCCTL(V_CTL).DEPCTL_POSTED_ON := NULL;
        V_DEPCALCCTL(V_CTL).DEPCTL_POSTED_BATCH_NUM := 0;
        V_DEPCALCCTL(V_CTL).DEPCTL_POSTED_BRN := 0;
        V_DEPCALCCTL(V_CTL).DEPCTL_EXEC_TYPE := 'A';

      EXCEPTION
        WHEN OTHERS THEN
          V_ERR_MSG := 'Error in DEPCALCCTL_COLL ' || V_PBDCONT(IDX)
                      .PBDCONT_DEP_AC_NUM || '-' || V_PBDCONT(IDX)
                      .PBDCONT_CONT_NUM || '-' || SUBSTR(SQLERRM, 1, 500);
          RAISE E_USEREXCEP;
      END DEPCALCCTL_COLL;

      PROCEDURE CALC_MAT_VALUE(IDX IN NUMBER) IS -- CALLED FROM REGULAR_INT_PAY

      BEGIN
        V_RDINS_FREQ := V_PBDCONT(IDX).PBDCONT_FREQ_OF_DEP;

        --V_NOOF_INST_PAID:=V_NOOF_INST_PAID-1; -- Sriram B - chn - 26-mar-2009

      /*  IF V_RDINS_FREQ = 'M' THEN
          W_PERD := V_NOOF_INST_PAID;
        ELSIF V_RDINS_FREQ = 'Q' THEN
          W_PERD := V_NOOF_INST_PAID * 3;
        ELSIF V_RDINS_FREQ = 'H' THEN
          W_PERD := V_NOOF_INST_PAID * 6;
        ELSIF V_RDINS_FREQ = 'Y' THEN
          W_PERD := V_NOOF_INST_PAID * 12;
        END IF; */ -- COMMENTED BY BIBHU ON 24-08-2012

      --  W_PERD := V_NOOF_INST_PAID; -- ADDED BY BIBHU ON 24-08-2012
      /*  IF V_CBD < V_PBDCONT(IDX).PBDCONT_MAT_DATE  then  --Sriram B - chn - 17-04-2009
              W_PERD:=W_PERD-1; --Sriram B - chn - 26-03-2009
        END IF; */ -- COMMENTED BY BIBHU ON 24-08-2012

        --sriram temp V_NOC         := (W_PERD / 3);
        -- ADDED BY BIBHU ON 24-08-2012 BEGIN
        IF V_PBDCONT(IDX).DEPPR_INT_COMP_FREQ = 'M' THEN
          V_NO_OF_COMP := 12;
        ELSIF V_PBDCONT(IDX).DEPPR_INT_COMP_FREQ = 'Q' THEN
          V_NO_OF_COMP := 4;
        ELSIF V_PBDCONT(IDX).DEPPR_INT_COMP_FREQ = 'H' THEN
          V_NO_OF_COMP := 2;
        ELSIF V_PBDCONT(IDX).DEPPR_INT_COMP_FREQ = 'Y' THEN
          V_NO_OF_COMP := 1;
        END IF;
/* Old maturity calculation process commented
        V_NOC_RD         := W_PERD / V_COMP_FREQ;
        V_INT_RATE    := (V_PBDCONT(IDX).PBDCONT_ACTUAL_INT_RATE /(100*V_NO_OF_COMP));
        V_FACTOR      := POWER((1 + V_INT_RATE), (1 /V_COMP_FREQ));
        V_NUMERATOR   := ((V_PBDCONT_TWDS_INST) * (POWER((1 + V_INT_RATE), V_NOC_RD) - 1));
        V_DENOMINATOR := (1 - (1 / V_FACTOR));
        V_MAT_VALUE   := (V_NUMERATOR / V_DENOMINATOR); */

        V_DENOMINATOR := 100 * (12/V_COMP_FREQ);
        V_MAT_VALUE := 0;
        FOR IDN IN 1..W_PERD LOOP

          V_NUMERATOR := V_PBDCONT_TWDS_INST* power((1+(V_PBDCONT(IDX).PBDCONT_ACTUAL_INT_RATE/V_DENOMINATOR)),(IDN/V_COMP_FREQ));
          V_MAT_VALUE := V_MAT_VALUE + V_NUMERATOR;
        END LOOP;

         V_BREAK_INT := 0;

         IF V_NO_DEFAULTS > 0 THEN
          FOR IDN IN 1..V_NO_DEFAULTS LOOP
            V_NUMERATOR := V_PBDCONT_TWDS_INST* power((1+(V_PBDCONT(IDX).PBDCONT_ACTUAL_INT_RATE/V_DENOMINATOR)),(IDN/V_COMP_FREQ));
            V_BREAK_INT := V_BREAK_INT + V_NUMERATOR;
            END LOOP;
            V_BREAK_INT := V_BREAK_INT - (V_NO_DEFAULTS*V_PBDCONT_TWDS_INST);
         END IF;

        V_MAT_VALUE:= V_MAT_VALUE - V_BREAK_INT;

       v_int_accr_upto := (add_months(V_PBDCONT(IDX).PBDCONT_EFF_DATE, W_PERD)-1); --Modified by Manoj 13-JUN-13

      EXCEPTION
        WHEN OTHERS THEN
          V_ERR_MSG := 'Error in CALC_MAT_VALUE ' || V_PBDCONT(IDX)
                      .PBDCONT_DEP_AC_NUM || '-' || V_PBDCONT(IDX)
                      .PBDCONT_CONT_NUM || '-' || SUBSTR(SQLERRM, 1, 500);
          RAISE E_USEREXCEP;
      END CALC_MAT_VALUE;

      PROCEDURE REGULAR_INT_PAY(IDX IN NUMBER) IS -- CALLED FROM MAIN
      BEGIN
         -- ADDED BY BIBHU ON 17-03-2013 BEGIN
        IF V_PBDCONT(IDX).DEPPR_RDINT_CALC_BASIS = 'S' THEN

         IF V_PBDCONT(IDX).DEPPR_INT_CALC_DENOM = '1' THEN
               V_DENOM_SIMPLE := 360;
            ELSIF V_PBDCONT(IDX).DEPPR_INT_CALC_DENOM = '2' THEN
               V_DENOM_SIMPLE := 365;
            ELSIF V_PBDCONT(IDX).DEPPR_INT_CALC_DENOM = '3' THEN
               V_DENOM_SIMPLE := 366;
               ELSE
                 V_DENOM_SIMPLE := 365;
            END IF;

        IF V_PBDCONT(IDX).PBDCONT_FREQ_OF_DEP = 'M' THEN
        V_FREQ_FACTOR := 1;
        ELSIF V_PBDCONT(IDX).PBDCONT_FREQ_OF_DEP = 'Q' THEN
        V_FREQ_FACTOR := 3;
        ELSIF V_PBDCONT(IDX).PBDCONT_FREQ_OF_DEP = 'H' THEN
        V_FREQ_FACTOR := 6;
        ELSIF  V_PBDCONT(IDX).PBDCONT_FREQ_OF_DEP = 'Y' THEN
        V_FREQ_FACTOR := 12;
        ELSE
          V_FREQ_FACTOR := 3;
        END IF;

        V_EFF_INT_RATE := V_PBDCONT(IDX).PBDCONT_ACTUAL_INT_RATE/100;
        V_RED_FACTOR := 0;
        V_CALC_AMT := 0;
        V_FINAL_CALC_AMT := 0;
        V_SIMPLE_INT := 0;
        V_SIMPLE_FACTOR := 0;
        V_NO_OF_INSTS_PAID := floor(V_RDINS_BAL /V_PBDCONT_TWDS_INST);
        V_RUN_PERD := TRUNC(MONTHS_BETWEEN (V_ASON_DATE,V_PBDCONT(IDX).PBDCONT_EFF_DATE));
        V_RUN_DAYS := V_ASON_DATE - (ADD_MONTHS(V_ASON_DATE, V_RUN_PERD));

        IF V_NO_OF_INSTS_PAID > 0 THEN
        FOR INX IN 1..V_NO_OF_INSTS_PAID  LOOP

           V_SIMPLE_FACTOR := 1 + (V_EFF_INT_RATE * (V_RUN_PERD - V_RED_FACTOR)/12);
           V_CALC_AMT := V_CALC_AMT + V_PBDCONT_TWDS_INST * V_SIMPLE_FACTOR;
           V_RED_FACTOR := V_RED_FACTOR + V_FREQ_FACTOR;

        END LOOP;
        END IF;

        IF V_CALC_AMT > V_RDINS_BAL THEN
        V_FINAL_CALC_AMT := V_CALC_AMT - V_RDINS_BAL;
        ELSE
        V_FINAL_CALC_AMT := 0;
        END IF;

        IF V_RUN_DAYS > 0 THEN
          V_SIMPLE_INT := V_RDINS_BAL * V_EFF_INT_RATE * (V_RUN_DAYS/V_DENOM_SIMPLE);
          V_FINAL_CALC_AMT := V_FINAL_CALC_AMT + V_SIMPLE_INT;
        END IF;
        V_INT_AMT := V_FINAL_CALC_AMT;

          ELSE
          -- ADDED BY BIBHU ON 17-03-2013 END
        CALC_MAT_VALUE(IDX);
       -- V_INT_AMT := V_MAT_VALUE - V_DUE_BAL; Commented by Manoj 05dec2013
      V_INT_AMT:= V_MAT_VALUE - (W_PERD*V_PBDCONT_TWDS_INST);


       IF V_CBD < V_PBDCONT(IDX).PBDCONT_MAT_DATE  then  --Sriram B - chn - 17-04-2009
            --Sriram B - chn - 24-03-2009 - beg
            V_BRK_MONTHS:= TRUNC(MONTHS_BETWEEN(v_ason_date,(v_int_accr_upto+1 )));
         --   V_BRK_DAYS:= v_ason_date - (ADD_MONTHS(v_int_accr_upto, V_BRK_MONTHS));
          V_BRK_DAYS:= v_ason_date - v_int_accr_upto + 1; --ADDED BY MANOJ 12JUL2013
            IF V_PBDCONT(IDX).DEPPR_INT_CALC_DENOM = '1' THEN
               V_DENOM := 36000;
            ELSIF V_PBDCONT(IDX).DEPPR_INT_CALC_DENOM = '2' THEN
               V_DENOM := 36500;
            ELSIF V_PBDCONT(IDX).DEPPR_INT_CALC_DENOM = '3' THEN
               V_DENOM := 36600;
            END IF;

            V_BROKEN_INT := --((V_MAT_VALUE * V_PBDCONT(IDX).PBDCONT_ACTUAL_INT_RATE * V_BRK_MONTHS) / 1200) + --COMMENTED BY MANOJ
                                ((V_MAT_VALUE * V_PBDCONT(IDX).PBDCONT_ACTUAL_INT_RATE * V_BRK_DAYS) / V_DENOM);
            --Sriram B - chn - 25-03-2009-beg
        END IF;     --Sriram B - cuired hn - 17-04-2009
        V_BROKEN_INT := 0; --Break days Calculation not required . Comment it if required. Added by Manoj 05122013
        V_INT_AMT:=V_INT_AMT+V_BROKEN_INT;
        END IF; -- ADDED BY BIBHU ON 17-03-2013

        IF v_ason_date < V_PBDCONT(IDX).PBDCONT_MAT_DATE THEN
          v_int_accr_upto := v_ason_date;
        ELSE
          v_int_accr_upto := V_PBDCONT(IDX).PBDCONT_MAT_DATE - 1;
        END IF;

        V_INT_AMT := ROUND(NVL(V_INT_AMT, 0), 3); --FOR UPDATE




      EXCEPTION
        WHEN OTHERS THEN
          IF V_ERR_MSG IS NULL THEN
            V_ERR_MSG := 'Error in REGULAR_INT_PAY ' || V_PBDCONT(IDX)
                        .PBDCONT_DEP_AC_NUM || '-' || V_PBDCONT(IDX)
                        .PBDCONT_CONT_NUM || '-' || SUBSTR(SQLERRM, 1, 500);
          END IF;
          RAISE E_USEREXCEP;
      END REGULAR_INT_PAY;

      PROCEDURE COMPUTEINTIRR(IDX IN NUMBER) IS
        -- CALLED FROM IRREGULAR_INST_PAY
        W_TEMP_SER NUMBER DEFAULT 0; --Sriram B - chn - 15-04-08
      BEGIN
        W_INT_TBC  := 0;
        W_INT_NTBC := 0;
        W_TOT_INT  := 0;
        W_INT      := 0;

        FOR IRR_IDX IN 1 .. V_RDMINBAL.COUNT LOOP
          --          W_INT     := ((V_RDMINBAL(IRR_IDX).MONMINBAL + W_INT_TBC) * V_PBDCONT(IDX)
          --                       .PBDCONT_ACTUAL_INT_RATE) / 1200;
          IF P_RD_AC_NUM = 0 THEN
            W_INT := ((V_RDMINBAL(IRR_IDX).MONMINBAL + W_INT_TBC) * V_PBDCONT(IDX)
                     .PBDCONT_ACTUAL_INT_RATE) / 1200;
          ELSE
            W_INT := ((V_RDMINBAL(IRR_IDX).MONMINBAL + W_INT_TBC) * P_INT_RATE) / 1200;
          END IF;
          W_TOT_INT := W_TOT_INT + W_INT;
        /*  IF V_RDMINBAL(IRR_IDX).RDYYMM = 3 OR V_RDMINBAL(IRR_IDX).RDYYMM = 9 THEN
            W_INT_NTBC := W_INT_NTBC + W_INT;
            W_INT_TBC  := W_INT_TBC + W_INT_NTBC;
            W_INT_NTBC := 0;
          ELSE
            W_INT_NTBC := W_INT_NTBC + W_INT;
          END IF; */ -- COMMENTED BY BIBHU ON 24-08-2012
          -- ADDED BY BIBHU ON 24-08-2012 BEGIN
         IF MOD(IRR_IDX,V_COMP_FREQ) = 0 THEN
            W_INT_NTBC := W_INT_NTBC + W_INT;
            W_INT_TBC  := W_INT_TBC + W_INT_NTBC;
            W_INT_NTBC := 0;
          ELSE
            W_INT_NTBC := W_INT_NTBC + W_INT;
            END IF;
           -- ADDED BY BIBHU ON 24-08-2012 END
          --Sriram B - chn - 15-04-08 - beg
          SELECT GENRUNNUM.NEXTVAL INTO W_TEMP_SER FROM DUAL;

          IF V_RDMINBAL(IRR_IDX).MONMINBAL > 0 THEN
            INSERT INTO RTMPRDINTACCR
              (RTMPRDINTACCR_INTERNAL_ACNUM,
               RTMPRDINTACCR_ASON_DATE,
               RTMPRDINTACCR_TEMP_SER,
               RTMPRDINTACCR_YYYYMM,
               RTMPRDINTACCR_MIN_BAL,
               RTMPRDINTACCR_INTEREST_AMT)
            VALUES
              (V_PBDCONT(IDX).PBDCONT_DEP_AC_NUM,
               V_CBD, --Sriram B - chn - 26-may-08 V_ASON_DATE,
               W_TEMP_SER,
               V_RDMINBAL(IRR_IDX).RDYYMM,
               V_RDMINBAL(IRR_IDX).MONMINBAL,
               W_TOT_INT);

          END IF;



          --Sriram B - chn - 15-04-08 - end
        END LOOP;
        V_INT_AMT := W_TOT_INT; --FOR UPDATE

      EXCEPTION
        WHEN OTHERS THEN
          V_ERR_MSG := 'Error in COMPUTEINTIRR ' || V_PBDCONT(IDX)
                      .PBDCONT_DEP_AC_NUM || '-' || V_PBDCONT(IDX)
                      .PBDCONT_CONT_NUM || '-' || SUBSTR(SQLERRM, 1, 500);
          RAISE E_USEREXCEP;
      END COMPUTEINTIRR;

      PROCEDURE UPDATE_MONMINBAL(IDX IN NUMBER) IS -- CALLED FROM PROCESS_CHANGE
      BEGIN
        W_DEPEFF_YYMM := 0;
        W_ASON_YYMM   := 0;

        W_DEPEFF_YYMM := TO_CHAR(V_PBDCONT(IDX).PBDCONT_EFF_DATE, 'YYYY') * 100 +
                         TO_CHAR(V_PBDCONT(IDX).PBDCONT_EFF_DATE, 'MM');
        W_ASON_YYMM   := TO_CHAR(V_ASON_DATE, 'YYYY') * 100 + TO_CHAR(V_ASON_DATE, 'MM');
        IF (W_CURR_YYMM = W_DEPEFF_YYMM) AND TO_CHAR(V_EFF_DATE, 'DD') > 1 THEN
          W_CURR_MIN_BAL := 0;
        ELSIF (W_CURR_YYMM = W_ASON_YYMM) THEN
          --Sriram B - chn - 12-04-08 IF TO_CHAR(V_ASON_DATE, 'DD') = TO_CHAR(LAST_DAY(V_ASON_DATE), 'DD') THEN
          IF TO_CHAR(V_ASON_DATE, 'DD') <> TO_CHAR(LAST_DAY(V_ASON_DATE), 'DD') THEN
            W_CURR_MIN_BAL := 0;
          END IF;
        END IF;

        V_RDSL := V_RDSL + 1;
        V_RDMINBAL(V_RDSL).RDYYMM := W_CURR_YYMM;
        V_RDMINBAL(V_RDSL).MONMINBAL := W_CURR_MIN_BAL;

      EXCEPTION
        WHEN OTHERS THEN
          V_ERR_MSG := 'Error in UPDATE_MONMINBAL ' || V_PBDCONT(IDX)
                      .PBDCONT_DEP_AC_NUM || '-' || V_PBDCONT(IDX)
                      .PBDCONT_CONT_NUM || '-' || SUBSTR(SQLERRM, 1, 500);
          RAISE E_USEREXCEP;
      END UPDATE_MONMINBAL;

      PROCEDURE PROCESS_CHANGE(RD_IDX IN NUMBER, IDX IN NUMBER) IS --CALLED FROM GET_RDMONMINBAL
      BEGIN
        V_PREV_MM   := 0; --added on - 18-04-08
        V_CURR_MM   := 0; --added on - 18-04-08
        V_PREV_YYYY := 0;
        V_CURR_YYYY := 0;

        IF W_PREV_DATE IS NULL THEN
          IF TO_CHAR(V_RDMONMINBAL(RD_IDX).RDINS_EFF_DATE, 'DD') > 10 THEN
            W_CURR_MIN_BAL := 0;
            W_CURR_YYMM    := TO_CHAR(V_RDMONMINBAL(RD_IDX).RDINS_EFF_DATE, 'YYYY') * 100 +
                              TO_CHAR(V_RDMONMINBAL(RD_IDX).RDINS_EFF_DATE, 'MM');
          ELSE
            IF TO_CHAR(V_RDMONMINBAL(RD_IDX).RDINS_EFF_DATE, 'DD') = 10 THEN
              W_CURR_MIN_BAL := V_RDMONMINBAL(RD_IDX).RDINS_TWDS_INSTLMNT;
              W_CURR_YYMM    := TO_CHAR(V_RDMONMINBAL(RD_IDX).RDINS_EFF_DATE, 'YYYY') * 100 +
                                TO_CHAR(V_RDMONMINBAL(RD_IDX).RDINS_EFF_DATE, 'MM');
            END IF;
          END IF;
          W_PREV_DATE := V_RDMONMINBAL(RD_IDX).RDINS_EFF_DATE;
        ELSE
          W_PREV_DATE_YYMM := TO_CHAR(W_PREV_DATE, 'YYYY') * 100 + TO_CHAR(W_PREV_DATE, 'MM');
          W_TRDATE_YYMM    := TO_CHAR(V_RDMONMINBAL(RD_IDX).RDINS_EFF_DATE, 'YYYY') * 100 +
                              TO_CHAR(V_RDMONMINBAL(RD_IDX).RDINS_EFF_DATE, 'MM');
          V_START_DATE     := W_PREV_DATE;
          IF W_PREV_DATE_YYMM = W_TRDATE_YYMM THEN
            IF TO_CHAR(W_PREV_DATE, 'DD') < 10 AND
               TO_CHAR(V_RDMONMINBAL(RD_IDX).RDINS_EFF_DATE, 'DD') >= 10 THEN
              W_CURR_MIN_BAL := W_SBAL;
              W_CURR_YYMM    := W_PREV_DATE_YYMM;
            ELSIF TO_CHAR(W_PREV_DATE, 'DD') >= 10 THEN
              IF W_SBAL < W_CURR_MIN_BAL THEN
                W_CURR_MIN_BAL := W_SBAL;
              END IF;
            END IF;
          ELSE
            --UPDATE_MONMINBAL(IDX); --Changes  -- Sriram B - chn - 12-04-08
            -- Sriram B - chn - 14-04-08 - beg
            --added on - 18-04-08 - beg

            V_PREV_MM := TO_CHAR(V_START_DATE, 'MM');
            V_CURR_MM := TO_CHAR(V_RDMONMINBAL(RD_IDX).RDINS_EFF_DATE, 'MM');

            V_PREV_YYYY := TO_CHAR(V_START_DATE, 'YYYY');
            V_CURR_YYYY := TO_CHAR(V_RDMONMINBAL(RD_IDX).RDINS_EFF_DATE, 'YYYY');
            --Sriram B - chn - 18-07-08 - beg
            /*
            IF (V_CURR_MM < V_PREV_MM) THEN
              V_CURR_MM := V_CURR_MM + 12;
            END IF;

            W_BETWEEN_MONTHS := ABS(V_CURR_MM - V_PREV_MM);
            IF ABS(V_CURR_YYYY - V_PREV_YYYY) > 1 THEN
              W_BETWEEN_MONTHS := W_BETWEEN_MONTHS + (((V_CURR_YYYY - V_PREV_YYYY) - 1) * 12);
            END IF;
            */
            W_BETWEEN_MONTHS := ((V_CURR_YYYY * 12) + V_CURR_MM) - ((V_PREV_YYYY * 12) + V_PREV_MM);
            --Sriram B - chn - 18-07-08 - end
            --added on - 18-04-08 - end

            --removed on 18-04-08 W_BETWEEN_MONTHS := MONTHS_BETWEEN(V_RDMONMINBAL(RD_IDX).RDINS_EFF_DATE, V_START_DATE);
            --W_PREV_DATE_YYMM := TO_CHAR(V_START_DATE, 'YYYY') * 100 + ((TO_CHAR(V_START_DATE, 'MM')));
            --WHILE (V_START_DATE < V_RDMONMINBAL(RD_IDX).RDINS_EFF_DATE) LOOP
            FOR IDX_BAL IN 1 .. W_BETWEEN_MONTHS LOOP
              --W_PREV_DATE_YYMM := TO_CHAR(V_START_DATE, 'YYYY') * 100 + (TO_CHAR(ADD_MONTHS(V_START_DATE,1), 'MM'));
              --V_BAL_DAYS       := TO_CHAR(LAST_DAY(V_START_DATE), 'DD');
              V_START_DATE     := ADD_MONTHS(V_START_DATE, 1);
              W_PREV_DATE_YYMM := TO_CHAR(V_START_DATE, 'YYYY') * 100 + TO_CHAR(V_START_DATE, 'MM');
              W_CURR_YYMM      := W_PREV_DATE_YYMM;
              W_CURR_MIN_BAL   := W_SBAL;
              UPDATE_MONMINBAL(IDX);
            END LOOP;
            IF TO_CHAR(V_RDMONMINBAL(RD_IDX).RDINS_EFF_DATE, 'DD') >= 10 THEN
              W_CURR_MIN_BAL := W_SBAL;
              W_CURR_YYMM    := W_TRDATE_YYMM;
            END IF;
            W_PREV_DATE := V_RDMONMINBAL(RD_IDX).RDINS_EFF_DATE;
          END IF;
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
          IF V_ERR_MSG IS NULL THEN
            V_ERR_MSG := 'Error in PROCESS_CHANGE ' || V_PBDCONT(IDX)
                        .PBDCONT_DEP_AC_NUM || '-' || V_PBDCONT(IDX)
                        .PBDCONT_CONT_NUM || '-' || SUBSTR(SQLERRM, 1, 500);
          END IF;
          RAISE E_USEREXCEP;
      END PROCESS_CHANGE;

      PROCEDURE GET_RDMONMINBAL(IDX IN NUMBER) IS -- CALLED FROM IRREGULAR_INST_PAY
      BEGIN
        W_SBAL := 0;
        V_RDMONMINBAL.DELETE;

---Sriram B - chn - 07-july-2010 -  Beg (Getting the installment Balance more then one installment payment)
/*        SELECT RDINS_EFF_DATE, RDINS_ENTRY_DAY_SL, RDINS_TWDS_INSTLMNT BULK COLLECT
          INTO V_RDMONMINBAL
          FROM RDINS
          WHERE RDINS_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND  RDINS_RD_AC_NUM = V_PBDCONT(IDX).PBDCONT_DEP_AC_NUM
           AND RDINS_EFF_DATE <= V_ASON_DATE
           AND RDINS_AMT_OF_PYMT > 0
         ORDER BY RDINS_EFF_DATE;
*/
        SELECT RDINS_EFF_DATE, Sum(RDINS_TWDS_INSTLMNT) BULK COLLECT
          INTO V_RDMONMINBAL
          FROM RDINS
          WHERE RDINS_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND  RDINS_RD_AC_NUM = V_PBDCONT(IDX).PBDCONT_DEP_AC_NUM
           AND RDINS_EFF_DATE <= V_ASON_DATE
           AND RDINS_AMT_OF_PYMT > 0
         GROUP BY RDINS_EFF_DATE
         ORDER BY RDINS_EFF_DATE;
---Sriram B - chn - 07-july-2010 -  end (Getting the installment Balance more then one installment payment)

        --Sriram B - chn - 28-jul-2008 - RDINS_ENTRY_DATE changed to RDINS_EFF_DATE
        --Sriram B - chn - order by RDINS_EFF_DATE
        W_CURR_MIN_BAL   := 0;
        W_CURR_YYMM      := 0;
        W_PREV_DATE_YYMM := 0;
        W_TRDATE_YYMM    := 0;
        V_BAL_DAYS       := 0;
        W_PREV_DATE_YYMM := 0;

        FOR RD_IDX IN 1 .. V_RDMONMINBAL.COUNT LOOP
          IF V_RDMONMINBAL(RD_IDX).RDINS_EFF_DATE <> W_PREV_DATE OR (W_PREV_DATE IS NULL) THEN
            PROCESS_CHANGE(RD_IDX, IDX);
            W_SBAL := W_SBAL + V_RDMONMINBAL(RD_IDX).RDINS_TWDS_INSTLMNT;
          END IF;
          --Sriram B - chn - 11-04-08 - beg
          IF V_RDMONMINBAL.COUNT = RD_IDX THEN
            --removed - 18-04-08 W_BETWEEN_MONTHS := MONTHS_BETWEEN(V_ASON_DATE, W_PREV_DATE);

            --added on - 18-04-08 - beg

            V_PREV_MM   := 0;
            V_CURR_MM   := 0;
            V_PREV_YYYY := 0;
            V_CURR_YYYY := 0;

            V_PREV_MM := TO_CHAR(W_PREV_DATE, 'MM');
            V_CURR_MM := TO_CHAR(V_ASON_DATE, 'MM');

            V_PREV_YYYY := TO_CHAR(W_PREV_DATE, 'YYYY');
            V_CURR_YYYY := TO_CHAR(V_ASON_DATE, 'YYYY');

            /*
            IF (V_CURR_MM < V_PREV_MM) THEN
              V_CURR_MM := V_CURR_MM + 12;
            END IF;
            */
            /*
            W_BETWEEN_MONTHS := ABS(V_CURR_MM - V_PREV_MM);
            IF ABS(V_CURR_YYYY - V_PREV_YYYY) > 1 THEN
              W_BETWEEN_MONTHS := W_BETWEEN_MONTHS + (((V_CURR_YYYY - V_PREV_YYYY) - 1) * 12);
            END IF;
            */
            --Sriram B - chn - 18-07-08 - beg
            W_BETWEEN_MONTHS := ((V_CURR_YYYY * 12) + V_CURR_MM) - ((V_PREV_YYYY * 12) + V_PREV_MM);

            --Sriram B - chn - 18-07-08 - end
            --added on - 18-04-08 - end

            FOR IDX_BAL IN 1 .. W_BETWEEN_MONTHS LOOP
              W_PREV_DATE      := ADD_MONTHS(W_PREV_DATE, 1);
              W_PREV_DATE_YYMM := TO_CHAR(W_PREV_DATE, 'YYYY') * 100 + TO_CHAR(W_PREV_DATE, 'MM');
              W_CURR_YYMM      := W_PREV_DATE_YYMM;
              W_CURR_MIN_BAL   := W_SBAL;
              UPDATE_MONMINBAL(IDX);
            END LOOP;
          END IF;
          --Sriram B - chn - 11-04-08 - end
        END LOOP;
      EXCEPTION
        WHEN OTHERS THEN
          IF V_ERR_MSG IS NULL THEN
            V_ERR_MSG := 'Error in GET_RDMONMINBAL ' || V_PBDCONT(IDX)
                        .PBDCONT_DEP_AC_NUM || '-' || V_PBDCONT(IDX)
                        .PBDCONT_CONT_NUM || '-' || SUBSTR(SQLERRM, 1, 500);
          END IF;
          RAISE E_USEREXCEP;
      END GET_RDMONMINBAL;

      PROCEDURE IRREGULAR_INST_PAY(IDX IN NUMBER) IS -- CALLED FROM MAIN
      BEGIN
        V_CUMMBAL.DELETE;
        V_RDMINBAL.DELETE;
        V_RDSL      := 0;
        W_PREV_DATE := NULL;
        --gkash chn 27-12-2007 beg
        -- v_int_accr_upto should be updated with the v_ason_date
        --Sriram B - chn - 16-may-2008 - beg
        --v_int_accr_upto := v_ason_date;
        IF v_ason_date < V_PBDCONT(IDX).PBDCONT_MAT_DATE THEN
          v_int_accr_upto := v_ason_date;
        ELSE
          v_int_accr_upto := V_PBDCONT(IDX).PBDCONT_MAT_DATE - 1;
        END IF;
        --Sriram B - chn - 16-may-2008 - end
        --gkash chn 27-12-2007 end
        -- ADDED BY BIBHU ON 17-03-2013 BEGIN
        IF V_PBDCONT(IDX).DEPPR_RDINT_CALC_BASIS = 'S' THEN

        IF V_PBDCONT(IDX).DEPPR_INT_CALC_DENOM = '1' THEN
               V_DENOM_SIMPLE := 360;
            ELSIF V_PBDCONT(IDX).DEPPR_INT_CALC_DENOM = '2' THEN
               V_DENOM_SIMPLE := 365;
            ELSIF V_PBDCONT(IDX).DEPPR_INT_CALC_DENOM = '3' THEN
               V_DENOM_SIMPLE := 366;
               ELSE
                 V_DENOM_SIMPLE := 365;
            END IF;

        IF V_PBDCONT(IDX).PBDCONT_FREQ_OF_DEP = 'M' THEN
        V_FREQ_FACTOR := 1;
        ELSIF V_PBDCONT(IDX).PBDCONT_FREQ_OF_DEP = 'Q' THEN
        V_FREQ_FACTOR := 3;
        ELSIF V_PBDCONT(IDX).PBDCONT_FREQ_OF_DEP = 'H' THEN
        V_FREQ_FACTOR := 6;
        ELSIF  V_PBDCONT(IDX).PBDCONT_FREQ_OF_DEP = 'Y' THEN
        V_FREQ_FACTOR := 12;
        ELSE
          V_FREQ_FACTOR := 3;
        END IF;

        V_EFF_INT_RATE := V_PBDCONT(IDX).PBDCONT_ACTUAL_INT_RATE/100;
        V_RED_FACTOR := 0;
        V_CALC_AMT := 0;
        V_FINAL_CALC_AMT := 0;
        V_SIMPLE_INT := 0;
        V_SIMPLE_FACTOR := 0;
        V_NO_OF_INSTS_PAID := floor(V_RDINS_BAL /V_PBDCONT_TWDS_INST);
        V_RUN_PERD := TRUNC(MONTHS_BETWEEN (V_ASON_DATE,V_PBDCONT(IDX).PBDCONT_EFF_DATE));
        V_RUN_DAYS := V_ASON_DATE - (ADD_MONTHS(V_ASON_DATE, V_RUN_PERD));

        IF V_NO_OF_INSTS_PAID > 0 THEN
        FOR INX IN 1..V_NO_OF_INSTS_PAID  LOOP

           V_SIMPLE_FACTOR := 1 + (V_EFF_INT_RATE * (V_RUN_PERD - V_RED_FACTOR)/12);
           V_CALC_AMT := V_CALC_AMT + V_PBDCONT_TWDS_INST * V_SIMPLE_FACTOR;
           V_RED_FACTOR := V_RED_FACTOR + V_FREQ_FACTOR;

        END LOOP;
        END IF;

        IF V_CALC_AMT > V_RDINS_BAL THEN
        V_FINAL_CALC_AMT := V_CALC_AMT - V_RDINS_BAL;
        ELSE
        V_FINAL_CALC_AMT := 0;
        END IF;

        IF V_RUN_DAYS > 0 THEN
          V_SIMPLE_INT := V_RDINS_BAL * V_EFF_INT_RATE * (V_RUN_DAYS/V_DENOM_SIMPLE);
          V_FINAL_CALC_AMT := V_FINAL_CALC_AMT + V_SIMPLE_INT;
        END IF;
        V_INT_AMT := V_FINAL_CALC_AMT;

          ELSE
        -- ADDED BY BIBHU ON 17-03-2013 END

        GET_RDMONMINBAL(IDX); --Changes
        COMPUTEINTIRR(IDX);
        END IF; -- ADDED BY BIBHU ON 17-03-2013
      EXCEPTION
        WHEN OTHERS THEN
          IF V_ERR_MSG IS NULL THEN
            V_ERR_MSG := 'Error in IRREGULAR_INST_PAY ' || V_PBDCONT(IDX)
                        .PBDCONT_DEP_AC_NUM || '-' || V_PBDCONT(IDX)
                        .PBDCONT_CONT_NUM || '-' || SUBSTR(SQLERRM, 1, 500);
          END IF;
          RAISE E_USEREXCEP;
      END IRREGULAR_INST_PAY;

      --Sriram B - chn - 15-05-08 - beg
      FUNCTION GET_ROUND_OFF_VALUE(AMOUNT      IN FLOAT,
                                   P_PROD_CODE IN NUMBER,
                                   P_CURR_CODE IN VARCHAR2,
                                   W_ERRORMSG  OUT VARCHAR2

                                   ) RETURN FLOAT IS
        W_DEPPRCUR_INT_RND_OFF_CHOICE CHAR := '';
        W_DEPPRCUR_INT_RND_OFF_FACTOR NUMBER(9, 3) := 0;
        W_ROUND_OFF_VALUE             NUMBER(18, 3) := 0;
      BEGIN

        <<READ_DEPPRODCURR>>
        BEGIN

          SELECT DEPPRCUR_INT_RND_OFF_CHOICE, DEPPRCUR_INT_RND_OFF_FACTOR
            INTO W_DEPPRCUR_INT_RND_OFF_CHOICE, W_DEPPRCUR_INT_RND_OFF_FACTOR
            FROM DEPPRODCUR
           WHERE DEPPRCUR_PROD_CODE = P_PROD_CODE
             AND DEPPRCUR_CURR_CODE = P_CURR_CODE;

        EXCEPTION
          WHEN OTHERS THEN
            IF TRIM(W_ERRORMSG) IS NULL THEN
              W_ERRORMSG := 'ERROR IN PKG_RD_ACCRUAL WHILE READ_DEPPRODCURR' ||
                            SUBSTR(SQLERRM, 1, 400);
            END IF;

        END READ_DEPPRODCURR;

        <<ROUND_OFF>>
        BEGIN
          W_ROUND_OFF_VALUE := FN_ROUNDOFF(PKG_ENTITY.FN_GET_ENTITY_CODE,AMOUNT,
                                           W_DEPPRCUR_INT_RND_OFF_CHOICE,
                                           W_DEPPRCUR_INT_RND_OFF_FACTOR);
          RETURN W_ROUND_OFF_VALUE;

        EXCEPTION
          WHEN OTHERS THEN
            IF TRIM(W_ERRORMSG) IS NULL THEN
              W_ERRORMSG := 'ERROR IN PKG_RD_ACCRUAL WHILE CALLING FN_ROUNDOFF' ||
                            SUBSTR(SQLERRM, 1, 400);
            END IF;
        END ROUND_OFF;

      END GET_ROUND_OFF_VALUE;
      --Sriram B - chn - 15-05-08 - end

      PROCEDURE FIND_NOOF_INST_PAID(P_START_DATE    IN DATE,
                                    P_TO_DATE       IN DATE,
                                    P_INT_COMP_FREQ IN CHARACTER,
                                    P_MAT_DATE      IN DATE,
                                    V_AC_NUM        IN NUMBER) IS

  --ADDED P_MAT_DATE Sriram B - chn - 22-09-2009
     W_TO_DATE DATE; -- ADDED BY BIBHU ON 04-10-2012
      BEGIN
        V_START_DATE     := P_START_DATE;
        V_NOOF_DAYS      := 0;
        V_NOOF_INST_PAID := 0;
        -- ADDED BY BIBHU ON 04-10-2012 BEGIN
        IF P_TO_DATE >= P_MAT_DATE THEN
          W_TO_DATE := P_MAT_DATE - 1 ;
          ELSE
            W_TO_DATE := P_TO_DATE;
           END IF;
        -- ADDED BY BIBHU ON 04-2012 END
        WHILE (V_START_DATE <= W_TO_DATE) LOOP  -- MODIFIED BY BIBHU ON 04-10-2012 --MODIFIED BY MANOJ
          IF P_INT_COMP_FREQ = 'M' THEN
            V_START_DATE := ADD_MONTHS(V_START_DATE, 1);
          ELSIF P_INT_COMP_FREQ = 'Q' THEN
            V_START_DATE := ADD_MONTHS(V_START_DATE, 3);
          ELSIF P_INT_COMP_FREQ = 'H' THEN
            V_START_DATE := ADD_MONTHS(V_START_DATE, 6);
          ELSIF P_INT_COMP_FREQ = 'Y' THEN
            V_START_DATE := ADD_MONTHS(V_START_DATE, 12);
          END IF;
          --Sriram B - chn - 22-09-2009 - beg
          --V_NOOF_INST_PAID := V_NOOF_INST_PAID + 1;

        --Sriram B - chn - 29-jun-2010 - beg  -- If Start date goes beyond mat date then mat date assigned to start date for last inst
        IF V_START_DATE > P_MAT_DATE THEN
           V_START_DATE:=P_MAT_DATE;
        END IF;
        --Sriram B - chn - 29-jun-2010 - beg

          IF V_START_DATE <= P_MAT_DATE THEN   --Sriram B - chn - 04-02-2010 - checked with = also
            --IF V_START_DATE <= W_TO_DATE THEN
           V_NOOF_INST_PAID := V_NOOF_INST_PAID + 1;
           --END IF;
          END IF;
          --Sriram B - chn - 22-09-2009 - end

        END LOOP;
      EXCEPTION
        WHEN OTHERS THEN
          IF V_ERR_MSG IS NULL THEN
            V_ERR_MSG := 'Error in FIND_NOOF_INST_PAID ' || '-' ||V_AC_NUM|| SUBSTR(SQLERRM, 1, 500);
          END IF;
          RAISE E_USEREXCEP;
      END FIND_NOOF_INST_PAID;

      PROCEDURE GET_DEPIA_INT(IDX IN NUMBER) IS
      BEGIN
        SELECT NVL(SUM(DECODE(DEPIA_INT_ACCR_DB_CR, 'C', DEPIA_AC_INT_ACCR_AMT)), 0)
          INTO V_RDINS_INT_CR
          FROM DEPIA
          WHERE DEPIA_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND  DEPIA_BRN_CODE = V_PBDCONT(IDX).PBDCONT_BRN_CODE
           AND DEPIA_INTERNAL_ACNUM = V_PBDCONT(IDX).PBDCONT_DEP_AC_NUM
           AND DEPIA_CONTRACT_NUM = V_PBDCONT(IDX).PBDCONT_CONT_NUM;
      EXCEPTION
        WHEN OTHERS THEN
          V_ERR_MSG                     := 'Error in GET_DEPIA_INT ' || '-' ||
                                           SUBSTR(SQLERRM, 1, 500);
          PKG_EODSOD_FLAGS.PV_ERROR_MSG := V_ERR_MSG;
          PKG_PB_GLOBAL.DETAIL_ERRLOG(PKG_ENTITY.FN_GET_ENTITY_CODE,'E', V_ERR_MSG, ' ', 0);
      END GET_DEPIA_INT;

      PROCEDURE INIT_PARA IS
      BEGIN
        V_ACNTBAL_AC_BAL    := 0;
        V_PBDCONT_TWDS_INST := 0;
        V_RDINS_BAL         := 0;
        V_CHARGES_BAL       := 0; --Added by Manoj 14 JUN 13
        V_NO_DEFAULTS       := 0; --Added by Manoj 05 dec 2013
        V_BREAK_INT          := 0;
        W_PERD              := 0;
        V_MAT_VALUE         := 0;
        V_DUE_BAL           := 0;
        V_RDINS_BAL         := 0;
        V_RDINS_INT_CR      := 0;
        V_INT_AMT           := 0;
        V_RD_INT_NOW        := 0;
        V_NOC               := 0;
        V_REM               := 0;
        V_INT_RATE          := 0;
        V_NUMERATOR         := 0;
        V_DENOMINATOR       := 0;
        V_REM_AMT           := 0;
        V_TOT_INST_PAID     := 0;
        V_CALC_INS          := 0;
        V_NOD:=0;
        W_ERRORMSG          := '';
      END INIT_PARA;
      --gkash chn 28-10-2008 beg for runnumber changes
      PROCEDURE DELETE_TEMP_TABLE(W_DEL_RUN_NO IN NUMBER) IS
      BEGIN
         DELETE FROM DEPCALCCTL S WHERE DEPCTL_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND  S.DEPCTL_RUN_NUM = W_DEL_RUN_NO;
         DELETE FROM DEPCALCAC SS WHERE DEPCAC_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND  SS.DEPCAC_RUN_NUM = W_DEL_RUN_NO;
         DELETE FROM DEPCALCBRK SSS WHERE DEPCBRK_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND  SSS.DEPCBRK_RUN_NUM = W_DEL_RUN_NO;
      END DELETE_TEMP_TABLE;

      FUNCTION GET_RUNNO RETURN NUMBER IS
        W_RUN_NO NUMBER(8);
      BEGIN
        <<READNUM>>
        BEGIN
          SELECT GENRUNNUM.NEXTVAL INTO W_RUN_NO FROM DUAL;
        END READNUM;

        DELETE_TEMP_TABLE(W_RUN_NO);

        RETURN W_RUN_NO;
      END GET_RUNNO;

    BEGIN
        PKG_ENTITY.SP_SET_ENTITY_CODE(V_ENTITY_NUM);

      <<RDINTCALC>>
      V_DEPPR_PROD_CODE := 0;
      V_PBDCONT.DELETE;
      v_cbd := pkg_eodsod_flags.PV_CURRENT_DATE;

      IF P_ASON_DATE IS NULL THEN

        V_ASON_DATE := V_CBD;

      ELSE
        V_ASON_DATE := P_ASON_DATE;
      END IF;

      IF P_RUN_NUMBER = 0 THEN

        v_run_number := get_runno;
      ELSE
        V_RUN_NUMBER := P_RUN_NUMBER;
      END IF;

      BEGIN

        V_SQL := 'SELECT PBDCONT_BRN_CODE,PBDCONT_DEP_AC_NUM,PBDCONT_CONT_NUM,PBDCONT_EFF_DATE,PBDCONT_MAT_DATE,
                 PBDCONT_INT_ACCR_UPTO,PBDCONT_ACTUAL_INT_RATE,DEPPR_INT_COMP_FREQ,
                 PBDCONT_FREQ_OF_DEP,DEPPR_PROD_CODE,PBDCONT_AC_DEP_AMT,PBDCONT_DEP_CURR,DEPPR_INT_CALC_DENOM,DEPPR_RDINT_CALC_BASIS,DEPPR_INT_SPECIFIED_CHOICE
                  FROM PBDCONTRACT,ACNTS,DEPPROD WHERE ACNTS_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND PBDCONT_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND
                 PBDCONT_DEP_AC_NUM=ACNTS_INTERNAL_ACNUM AND
                 DEPPR_PROD_CODE=ACNTS_PROD_CODE AND
                 DEPPR_TYPE_OF_DEP= ' || CHR(39) || 3 || CHR(39) ||
                 ' AND
                 PBDCONT_CLOSURE_DATE IS NULL AND PBDCONT_TRF_TO_OD_ON IS NULL AND
                 PBDCONT_AUTH_ON IS NOT NULL AND
                 PBDCONT_REJ_ON IS NULL';
        -- ADDED BY BIBHU ON 17-03-2013 END

        -- Sriram B - chn - 24-03-2009 - added DEPPR_INT_CALC_DENOM
        --P_RD_AC_NUM:= '11612100000150';
        IF P_ASON_DATE IS NOT NULL THEN
          V_SQL := V_SQL || ' AND PBDCONT_EFF_DATE <= ' || CHR(39) || P_ASON_DATE || CHR(39);
        END IF;
        IF P_RD_AC_NUM > 0 THEN
          V_SQL := V_SQL || ' AND PBDCONT_DEP_AC_NUM = ' || P_RD_AC_NUM;
        END IF;
        IF P_FROM_BRN > 0 AND P_UPTO_BRN > 0 THEN
          V_SQL := V_SQL || ' AND PBDCONT_BRN_CODE >= ' || P_FROM_BRN || ' AND PBDCONT_BRN_CODE <= ' ||
                   P_UPTO_BRN;
        ELSIF P_FROM_BRN > 0 AND P_UPTO_BRN = 0 THEN
          V_SQL := V_SQL || ' AND PBDCONT_BRN_CODE = ' || P_FROM_BRN;
        ELSIF P_FROM_BRN = 0 AND P_UPTO_BRN > 0 THEN
          V_SQL := V_SQL || ' AND PBDCONT_BRN_CODE = ' || P_FROM_BRN;
        END IF;
        IF P_PROD_CODE > 0 THEN
          V_SQL := V_SQL || ' AND ACNTS_PROD_CODE = ' || P_PROD_CODE;
        END IF;
        V_SQL := V_SQL ||
                 ' ORDER BY DEPPR_PROD_CODE,PBDCONT_BRN_CODE,PBDCONT_DEP_AC_NUM,PBDCONT_EFF_DATE';

        EXECUTE IMMEDIATE V_SQL BULK COLLECT
          INTO V_PBDCONT;

        FOR IDX IN 1 .. V_PBDCONT.COUNT LOOP
          V_YEAR_DIFF  := 0;
          V_EFF_DATE   := V_PBDCONT(IDX).PBDCONT_EFF_DATE;
          V_START_DATE := V_PBDCONT(IDX).PBDCONT_EFF_DATE;

          IF V_PBDCONT(IDX).PBDCONT_INT_ACCR_UPTO IS NULL THEN
            v_int_accr_from := V_PBDCONT(IDX).PBDCONT_EFF_DATE;
          ELSE
            v_int_accr_from := V_PBDCONT(IDX).PBDCONT_INT_ACCR_UPTO + 1;
          END IF;

          IF V_INT_ACCR_FROM >= V_PBDCONT(IDX).PBDCONT_MAT_DATE THEN
            GOTO NEXTLOOP;
          END IF;

          IF pkg_process_check.FN_IGNORE_ACNUM(PKG_ENTITY.FN_GET_ENTITY_CODE,V_PBDCONT(IDX).pbdcont_dep_ac_num) = FALSE THEN

            INIT_PARA;
            IF V_PBDCONT(IDX).DEPPR_INT_COMP_FREQ = 'M' THEN
              V_COMP_FREQ := 1;
              ELSIF V_PBDCONT(IDX).DEPPR_INT_COMP_FREQ = 'Q' THEN
              V_COMP_FREQ := 3;
              ELSIF V_PBDCONT(IDX).DEPPR_INT_COMP_FREQ = 'H' THEN
              V_COMP_FREQ := 6;
              ELSIF V_PBDCONT(IDX).DEPPR_INT_COMP_FREQ = 'Y' THEN
              V_COMP_FREQ := 12;
              ELSE
                V_COMP_FREQ := 3;
              END IF;
            <<ACNTBALREC>>

             IF V_PBDCONT(IDX).DEPPR_INT_CALC_DENOM = '1' THEN
               V_DENOM := 36000;
             ELSIF V_PBDCONT(IDX).DEPPR_INT_CALC_DENOM = '2' THEN
               V_DENOM := 36500;
             ELSIF V_PBDCONT(IDX).DEPPR_INT_CALC_DENOM = '3' THEN
               V_DENOM := 36600;
             END IF;

            BEGIN
              SELECT ACNTBAL_AC_BAL
                INTO V_ACNTBAL_AC_BAL
                FROM ACNTBAL
                WHERE ACNTBAL_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
                AND  ACNTBAL_INTERNAL_ACNUM = V_PBDCONT(IDX).PBDCONT_DEP_AC_NUM;

            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                GOTO NEXTLOOP;
              WHEN OTHERS THEN
                V_ERR_MSG := 'Error in ACNTBALREC for ' || V_PBDCONT(IDX)
                            .PBDCONT_DEP_AC_NUM || '-' || SUBSTR(SQLERRM, 1, 500);
                RAISE E_USEREXCEP;
            END ACNTBALREC;

            <<RDINSREC>>
            BEGIN
              SELECT SUM(RDINS_TWDS_INSTLMNT + NVL(RDINS_TWDS_INT, 0))
                INTO V_RDINS_BAL
                FROM RDINS
                WHERE RDINS_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND  RDINS_RD_AC_NUM = V_PBDCONT(IDX).PBDCONT_DEP_AC_NUM;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                GOTO NEXTLOOP;
              WHEN OTHERS THEN
                V_ERR_MSG := 'Error in RDINSREC ' || V_PBDCONT(IDX)
                            .PBDCONT_DEP_AC_NUM || '-' || SUBSTR(SQLERRM, 1, 500);
                RAISE E_USEREXCEP;
            END RDINSREC;
            V_PBDCONT_TWDS_INST := V_PBDCONT(IDX).PBDCONT_AC_DEP_AMT; --Changed
            IF (NVL(V_RDINS_BAL, 0) = 0 AND NVL(V_ACNTBAL_AC_BAL, 0) = 0) THEN
              V_ERR_MSG := 'Account Balance and Installment balance do not match for ' ||
                           FACNO(PKG_ENTITY.FN_GET_ENTITY_CODE,V_PBDCONT(IDX).PBDCONT_DEP_AC_NUM) || '-' || V_PBDCONT(IDX)
                          .PBDCONT_CONT_NUM;
              PKG_PB_GLOBAL.DETAIL_ERRLOG(PKG_ENTITY.FN_GET_ENTITY_CODE,'X', V_ERR_MSG, ' ', V_PBDCONT(IDX).PBDCONT_DEP_AC_NUM);

              GOTO NEXTLOOP;
            ELSE
              V_START_DATE := V_PBDCONT(IDX).PBDCONT_EFF_DATE;

              IF V_ASON_DATE >= V_PBDCONT(IDX).PBDCONT_MAT_DATE THEN
                --to date for update
                V_TO_DATE   := V_PBDCONT(IDX).PBDCONT_MAT_DATE - 1;
                V_ASON_DATE := V_TO_DATE; --Sriram B - chn - 26-may-08
              ELSE
                IF P_ASON_DATE IS NULL THEN
                  V_ASON_DATE := V_CBD;
                ELSE
                  V_ASON_DATE := P_ASON_DATE;
                END IF;
                V_TO_DATE := V_ASON_DATE;
              END IF;

              FIND_NOOF_INST_PAID(V_START_DATE, V_TO_DATE, V_PBDCONT(IDX).PBDCONT_FREQ_OF_DEP,V_PBDCONT(IDX).PBDCONT_MAT_DATE,V_PBDCONT(IDX)
                            .PBDCONT_DEP_AC_NUM);
              V_DUE_BAL := V_NOOF_INST_PAID * V_PBDCONT_TWDS_INST;
              <<RDINSBALREC>>
              BEGIN
                SELECT SUM(RDINS_TWDS_INSTLMNT),SUM (RDINS_TWDS_PENAL_CHGS) --Added by Manoj 14 JUN 13
                  INTO V_RDINS_BAL, V_CHARGES_BAL --Added by Manoj 14 JUN 13
                  FROM RDINS
                  WHERE RDINS_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND  -- V_RDINS_INT_CR FOR UPDATE
                 RDINS_RD_AC_NUM = V_PBDCONT(IDX).PBDCONT_DEP_AC_NUM
                 AND RDINS_EFF_DATE <= V_ASON_DATE;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  GOTO NEXTLOOP;
                WHEN OTHERS THEN
                  V_ERR_MSG := 'Error in RDINSBALREC ' || V_PBDCONT(IDX)
                              .PBDCONT_DEP_AC_NUM || V_ASON_DATE || '-' || SUBSTR(SQLERRM, 1, 500);
                  RAISE E_USEREXCEP;
              END RDINSBALREC;
              --Added by Manoj 13-JUN-13
              W_PERD := V_NOOF_INST_PAID;

              IF V_RDINS_BAL < V_DUE_BAL THEN

              V_DUE_BAL :=V_RDINS_BAL;
              V_NOOF_INST_PAID:=V_RDINS_BAL/V_PBDCONT_TWDS_INST;
              V_NO_DEFAULTS := W_PERD - V_NOOF_INST_PAID;
              END IF;

             IF V_RDINS_BAL > V_DUE_BAL THEN
                V_NOOF_INST_PAID:=V_RDINS_BAL/V_PBDCONT_TWDS_INST;
                V_DUE_BAL := V_RDINS_BAL;
               V_NO_DEFAULTS := 0;
              END IF;

             IF v_ason_date < V_PBDCONT(IDX).PBDCONT_MAT_DATE THEN
                 v_int_accr_upto := v_ason_date;
                ELSE
                 v_int_accr_upto := V_PBDCONT(IDX).PBDCONT_MAT_DATE - 1;
             END IF;

             if V_PBDCONT(IDX).DEPPR_INT_SPECIFIED_CHOICE='2' then

                V_NOD  :=  v_int_accr_upto - v_int_accr_from + 1;

                v_LEAN_AMOUNT:= FN_GET_LEAN_AVG_BAL(PKG_ENTITY.FN_GET_ENTITY_CODE,V_PBDCONT(IDX).PBDCONT_DEP_AC_NUM,v_int_accr_from,v_int_accr_upto);

                v_ACNT_AVGBAL:= FN_GET_AVG_BAL_ISLAMIC (PKG_ENTITY.FN_GET_ENTITY_CODE, V_PBDCONT(IDX).PBDCONT_DEP_AC_NUM,v_int_accr_from,v_int_accr_upto);

                V_ACT_INT_RATE := V_PBDCONT(IDX).PBDCONT_ACTUAL_INT_RATE;

                if v_LEAN_AMOUNT<0 then
                V_ORG_AC_AMT := v_ACNT_AVGBAL+v_LEAN_AMOUNT;
                else
                V_ORG_AC_AMT := v_ACNT_AVGBAL;
                end if;

                V_RD_INT_NOW := (V_ORG_AC_AMT * V_ACT_INT_RATE * V_NOD) / V_DENOM;

               IF V_RD_INT_NOW > 0 THEN
                  V_RD_INT_NOW := GET_ROUND_OFF_VALUE(V_RD_INT_NOW,
                                                      V_PBDCONT(IDX).DEPPR_PROD_CODE,
                                                      V_PBDCONT(IDX).PBDCONT_DEP_CURR,
                                                      W_ERRORMSG);

                END IF;


                IF V_CTL = 0 THEN
                  DEPCALCCTL_COLL(IDX);
                  UPDATE_DEPCALCCTL;
                END IF;

                IF V_RD_INT_NOW > 0 THEN
                  DEPCALC_COLL(IDX);
                  DEPCALCBRK_COLL(IDX);
                  RDCALC_COLL(IDX);
                  V_DEPPR_PROD_CODE := V_PBDCONT(IDX).DEPPR_PROD_CODE;
                END IF;

              else
                 V_SQL_STAT:='SELECT DEPIRHDT_EFF_FROM_DATE, DEPIRHDT_EFF_UPTO_DATE, DEPIRHDT_INT_RATE
                                     FROM TABLE (PKG_GET_DEPINTRATE.FN_GET_DEPINTRATE(:1,:2,:3, :4)) ORDER BY DEPIRHDT_EFF_FROM_DATE';

                    EXECUTE IMMEDIATE V_SQL_STAT BULK COLLECT
                    INTO T_REC_DEPIRHDT USING
                    PKG_ENTITY.FN_GET_ENTITY_CODE,V_PBDCONT(IDX).PBDCONT_DEP_AC_NUM,v_int_accr_from,v_int_accr_upto;

                   FOR IDX_RATE IN 1 .. T_REC_DEPIRHDT.COUNT
                   LOOP

                    V_ACT_INT_RATE := T_REC_DEPIRHDT (IDX_RATE).DEPIRHDT_INT_RATE;

                    V_NOD  :=  T_REC_DEPIRHDT (IDX_RATE).DEPIRHDT_EFF_UPTO_DATE - T_REC_DEPIRHDT (IDX_RATE).DEPIRHDT_EFF_FROM_DATE + 1;

                    V_LEAN_AMOUNT:= FN_GET_LEAN_AVG_BAL(PKG_ENTITY.FN_GET_ENTITY_CODE,V_PBDCONT(IDX).PBDCONT_DEP_AC_NUM,T_REC_DEPIRHDT (IDX_RATE).DEPIRHDT_EFF_FROM_DATE ,T_REC_DEPIRHDT (IDX_RATE).DEPIRHDT_EFF_UPTO_DATE);

                    V_ACNT_AVGBAL:= FN_GET_AVG_BAL_ISLAMIC (PKG_ENTITY.FN_GET_ENTITY_CODE, V_PBDCONT(IDX).PBDCONT_DEP_AC_NUM,T_REC_DEPIRHDT (IDX_RATE).DEPIRHDT_EFF_FROM_DATE ,T_REC_DEPIRHDT (IDX_RATE).DEPIRHDT_EFF_UPTO_DATE);

                    IF V_LEAN_AMOUNT<0 THEN
                     V_ORG_AC_AMT := V_ACNT_AVGBAL+V_LEAN_AMOUNT;
                    ELSE
                     V_ORG_AC_AMT := V_ACNT_AVGBAL;
                    END IF;

                    V_RD_INT_NOW := (V_ORG_AC_AMT * V_ACT_INT_RATE * V_NOD) / V_DENOM;

                       IF V_RD_INT_NOW > 0 THEN
                          V_RD_INT_NOW := GET_ROUND_OFF_VALUE(V_RD_INT_NOW,
                                                              V_PBDCONT(IDX).DEPPR_PROD_CODE,
                                                              V_PBDCONT(IDX).PBDCONT_DEP_CURR,
                                                              W_ERRORMSG);

                        END IF;


                    IF V_CTL = 0 THEN
                      DEPCALCCTL_COLL(IDX);
                      UPDATE_DEPCALCCTL;
                    END IF;

                    IF V_RD_INT_NOW > 0 THEN
                      DEPCALC_COLL(IDX);
                      DEPCALCBRK_COLL(IDX);
                      RDCALC_COLL(IDX);
                      V_DEPPR_PROD_CODE := V_PBDCONT(IDX).DEPPR_PROD_CODE;
                    END IF;

                    END LOOP;

             END IF;

              --- Comments for Islamic Banking

              /*
              --Added by Manoj 13-JUN-13
              IF V_RDINS_BAL <> V_DUE_BAL THEN
                PV_EXCESS_INT:=0;
                IRREGULAR_INST_PAY(IDX);

                GET_DEPIA_INT(IDX);

                <<GET_ROUND_VALUE>>
                BEGIN
                  V_INT_AMT := GET_ROUND_OFF_VALUE(V_INT_AMT,
                                                   V_PBDCONT(IDX).DEPPR_PROD_CODE,
                                                   V_PBDCONT(IDX).PBDCONT_DEP_CURR,
                                                   W_ERRORMSG);
                END GET_ROUND_VALUE;
                IF (TRIM(W_ERRORMSG) IS NOT NULL) THEN
                  RAISE E_USEREXCEP;
                END IF;
                --Sriram B - chn - 07-05-08 - end
                IF V_INT_AMT >= V_RDINS_INT_CR THEN
                  V_RD_INT_NOW := V_INT_AMT - V_RDINS_INT_CR;
                ELSE
                  --Sriram B - chn - 09-jul-08 V_RD_INT_NOW := V_INT_AMT;
                  V_RD_INT_NOW := 0;
                  PV_EXCESS_INT:=(V_RDINS_INT_CR-V_INT_AMT); --Sriram B - chn - 26-10-2010
                END IF;
                IF V_RD_INT_NOW > 0 THEN
                  V_RD_INT_NOW := GET_ROUND_OFF_VALUE(V_RD_INT_NOW,
                                                      V_PBDCONT(IDX).DEPPR_PROD_CODE,
                                                      V_PBDCONT(IDX).PBDCONT_DEP_CURR,
                                                      W_ERRORMSG);

                END IF;
              ELSE
                REGULAR_INT_PAY(IDX);

                GET_DEPIA_INT(IDX);

                <<GET_ROUND_VALUE>>
                BEGIN
                  V_INT_AMT := GET_ROUND_OFF_VALUE(V_INT_AMT,
                                                   V_PBDCONT(IDX).DEPPR_PROD_CODE,
                                                   V_PBDCONT(IDX).PBDCONT_DEP_CURR,
                                                   W_ERRORMSG);
                END GET_ROUND_VALUE;
                IF (TRIM(W_ERRORMSG) IS NOT NULL) THEN
                  RAISE E_USEREXCEP;
                END IF;

                IF V_INT_AMT >= V_RDINS_INT_CR THEN
                  V_RD_INT_NOW := V_INT_AMT - V_RDINS_INT_CR;
                ELSE
                  --Sriram B - chn - 09-jul-08 V_RD_INT_NOW := V_INT_AMT;
                  V_RD_INT_NOW := 0;
                END IF;
                IF V_RD_INT_NOW > 0 THEN
                  --Added by MAnoj 14 JUN 13
                  IF V_CHARGES_BAL > 0 THEN
                    V_RD_INT_NOW := V_RD_INT_NOW - V_CHARGES_BAL;
                  END IF;

                  V_RD_INT_NOW := GET_ROUND_OFF_VALUE(V_RD_INT_NOW,
                                                      V_PBDCONT(IDX).DEPPR_PROD_CODE,
                                                      V_PBDCONT(IDX).PBDCONT_DEP_CURR,
                                                      W_ERRORMSG);
                END IF;
              END IF;*/
              --- Comments for Islamic Banking
            END IF;

          END IF;
          <<NEXTLOOP>>
          NULL;
        END LOOP;

        IF V_CALC_SL > 0 THEN
          UPDATE_DEPCALC;
          UPDATE_DEPCALCBRK;
          UPDATE_RDCALC;

          V_SUM_MAT_VAL := 0;
          V_CALC_SL     := 0;
          V_BRK_SL      := 0;
          V_RD_SL       := 0;
          V_CTL         := 0;
          PKG_DEPACCR_POST.start_rdaccr_post(PKG_ENTITY.FN_GET_ENTITY_CODE,P_FROM_BRN,P_UPTO_BRN,V_RUN_NUMBER);
        END IF;

      EXCEPTION
        WHEN E_USEREXCEP THEN
          PKG_EODSOD_FLAGS.PV_ERROR_MSG := V_ERR_MSG;
          PKG_PB_GLOBAL.DETAIL_ERRLOG(PKG_ENTITY.FN_GET_ENTITY_CODE,'E', V_ERR_MSG, ' ', 0);
        WHEN OTHERS THEN
          V_ERR_MSG                     := 'Error in RD Profit Calculation ' || '-' ||
                                           SUBSTR(SQLERRM, 1, 500);
          PKG_EODSOD_FLAGS.PV_ERROR_MSG := V_ERR_MSG;
          PKG_PB_GLOBAL.DETAIL_ERRLOG(PKG_ENTITY.FN_GET_ENTITY_CODE,'E', V_ERR_MSG, ' ', 0);
      END RDPENALCALC;
    END SP_RD_INTCALC;

    PROCEDURE start_RD_accr_brnwise(V_ENTITY_NUM IN NUMBER,P_brn_code IN NUMBER DEFAULT 0) IS
      L_BRN_CODE NUMBER(6);
    BEGIN

      PKG_ENTITY.SP_SET_ENTITY_CODE(V_ENTITY_NUM);
      PKG_PROCESS_CHECK.INIT_PROC_BRN_WISE(PKG_ENTITY.FN_GET_ENTITY_CODE,P_BRN_CODE);
      FOR IDX IN 1 .. PKG_PROCESS_CHECK.V_ACNTBRN.COUNT LOOP
        L_BRN_CODE := PKG_PROCESS_CHECK.V_ACNTBRN(IDX).LN_BRN_CODE;
        IF PKG_PROCESS_CHECK.CHK_BRN_ALREADY_PROCESSED(PKG_ENTITY.FN_GET_ENTITY_CODE,L_BRN_CODE) = FALSE THEN

          SP_RD_INTCALC(PKG_ENTITY.FN_GET_ENTITY_CODE,NULL, 0, 0, L_BRN_CODE);

          IF TRIM(PKG_EODSOD_FLAGS.PV_ERROR_MSG) IS NULL THEN
            PKG_PROCESS_CHECK.INSERT_ROW_INTO_EODSODPROCBRN(PKG_ENTITY.FN_GET_ENTITY_CODE,l_BRN_CODE);
          END IF;

          PKG_PROCESS_CHECK.CHECK_COMMIT_ROLLBACK_STATUS(PKG_ENTITY.FN_GET_ENTITY_CODE);
        END IF;
      END LOOP;
    END start_RD_accr_brnwise;

    FUNCTION FN_GET_VALUE RETURN NUMBER IS
    BEGIN
      RETURN PV_EXCESS_INT;
    END FN_GET_VALUE;
  END PKG_RD_ACCRUAL;
/