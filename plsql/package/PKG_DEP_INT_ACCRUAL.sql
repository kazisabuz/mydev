CREATE OR REPLACE PACKAGE PKG_DEP_INT_ACCRUAL IS
 
 -- Public function and procedure declarations
 PROCEDURE START_DEP_ACCRUAL(P_ENTITY_NUM    IN NUMBER,
                            P_BRANCH    NUMBER DEFAULT 0,
                            P_DEP_AC_NUM NUMBER DEFAULT 0,
                            P_CONTRACT_REF NUMBER DEFAULT 0,
                            P_DOACCR_TILL_DT DATE DEFAULT NULL
 );
 PROCEDURE START_ACCR_BRNWISE(
                            P_ENTITY_NUM IN NUMBER,
                            P_BRN_CODE   IN NUMBER DEFAULT 0
 );

END PKG_DEP_INT_ACCRUAL;
/

CREATE OR REPLACE PACKAGE BODY PKG_DEP_INT_ACCRUAL
IS
   TYPE depCont IS RECORD
   (
      PBDCONT_BRN_CODE             PBDCONTRACT.PBDCONT_BRN_CODE%TYPE,
      PBDCONT_DEP_AC_NUM           PBDCONTRACT.PBDCONT_DEP_AC_NUM%TYPE,
      PBDCONT_CONT_NUM             PBDCONTRACT.PBDCONT_CONT_NUM%TYPE,
      PBDCONT_EFF_DATE             PBDCONTRACT.PBDCONT_EFF_DATE%TYPE,
      PBDCONT_AC_DEP_AMT           PBDCONTRACT.PBDCONT_AC_DEP_AMT%TYPE,
      PDBCONT_DEP_PRD_MONTHS       PBDCONTRACT.PDBCONT_DEP_PRD_MONTHS%TYPE,
      PBDCONT_DEP_PRD_DAYS         PBDCONTRACT.PBDCONT_DEP_PRD_DAYS%TYPE,
      PBDCONT_INT_ACCR_UPTO        PBDCONTRACT.PBDCONT_INT_ACCR_UPTO%TYPE,
      PBDCONT_ACTUAL_INT_RATE      PBDCONTRACT.PBDCONT_ACTUAL_INT_RATE%TYPE,
      PBDCONT_DISC_INT_RATE        PBDCONTRACT.PBDCONT_DISC_INT_RATE%TYPE,
      PBDCONT_PERIODICAL_INT_AMT   PBDCONTRACT.PBDCONT_PERIODICAL_INT_AMT%TYPE,
      PBDCONT_INT_PAY_FREQ         PBDCONTRACT.PBDCONT_INT_PAY_FREQ%TYPE,
      PBDCONT_MAT_DATE             PBDCONTRACT.PBDCONT_MAT_DATE%TYPE,
      PBDCONT_MAT_VALUE            PBDCONTRACT.PBDCONT_MAT_VALUE%TYPE,
      PBDCONT_INT_CALC_UPTO        PBDCONTRACT.PBDCONT_INT_CALC_UPTO%TYPE
   );

   TYPE ty_tab_depCont IS TABLE OF depCont
      INDEX BY PLS_INTEGER;

   TYPE tyIntPrdDtls IS RECORD
   (
      FROM_DATE          DATE,
      UPTO_DATE          DATE,
      NOD                NUMBER (5),
      FULL_PERIOD_FLAG   VARCHAR2 (1),
      PERIOD_INT_AMT     NUMBER (18, 3),
      ALREADY_ACCR_AMT   NUMBER (18, 3),
      PERIOD_END_FLAG    VARCHAR2 (1)
   );

   TYPE tblIntPrdDtls IS TABLE OF tyIntPrdDtls
      INDEX BY PLS_INTEGER;

   TYPE tyIntAccrDtls IS RECORD
   (
      BRN_CODE               PBDCONTRACT.PBDCONT_BRN_CODE%TYPE,
      DEP_AC_NUM             PBDCONTRACT.PBDCONT_DEP_AC_NUM%TYPE,
      CONT_NUM               PBDCONTRACT.PBDCONT_CONT_NUM%TYPE,
      ACCR_SL                NUMBER (5),
      CALC_FROM_DATE         DATE,
      CALC_UPTO_DATE         DATE,
      PREV_ACCR_UPTO         DATE,
      INT_ACCR_AMT           NUMBER (18, 3),
      DEPCAC_INT_ON_AMOUNT   NUMBER (18, 3),
      INT_PRD_END_FLAG       CHAR (1),
      CALC_PERIOD_NOD        NUMBER (5)
   );

   TYPE tblIntAccrDtls IS TABLE OF tyIntAccrDtls
      INDEX BY PLS_INTEGER;

   TYPE tyPwgen IS RECORD
   (
      PBDCONT_ACTUAL_INT_RATE   PBDCONTRACT.PBDCONT_ACTUAL_INT_RATE%TYPE,
      PBDCONT_EFF_DATE          PBDCONTRACT.PBDCONT_EFF_DATE%TYPE
   );

   TYPE tblPwgen IS TABLE OF tyPwgen
      INDEX BY PLS_INTEGER;

   v_pwgen                  tblPwgen;

   PWGEN_EFF_DATE           DATE;

   -- Pacakage level variable declarations
   --<VariableName> <Datatype>;
   --package level collection for interest period details
   pv_tblIntPrd             tblIntPrdDtls;
   --package level collection variable for interest accrued detais
   pv_tblIntAccr            tblIntAccrDtls;
   --package level collection variable for pwgen details
   pv_tblPwgen              tblPwgen;
   --pacakge level user exception variable
   E_USER_EXECPTION         EXCEPTION;
   V_GLOB_ENTITY_NUM        NUMBER (6);

   PV_IDX1                  NUMBER (5) := 0;
   PV_IDX2                  NUMBER (5) := 0;
   PV_RUN_NUMBER            NUMBER (8);
   PV_ERR_MSG               VARCHAR2 (2300);
   PV_CALC_FROM_DATE        DATE;
   PV_CALC_UPTO_DATE        DATE;
   PV_PREV_ACCR_DATE        DATE;
   PV_ORG_AC_AMT            PBDCONTRACT.PBDCONT_AC_DEP_AMT%TYPE;
   PV_ACT_INT_RATE          PBDCONTRACT.PBDCONT_ACTUAL_INT_RATE%TYPE;
   PV_CALC_CHOICE           DEPPROD.DEPPR_INT_CALC_CHOICE%TYPE;
   PV_CALC_DENOM            DEPPROD.DEPPR_INT_CALC_DENOM%TYPE;
   PV_PRD_CHOICE            DEPPROD.DEPPR_INT_PRD_CALC_CHOICE%TYPE;
   PV_DENOM                 NUMBER (14);
   PV_CALC_INT_AMT          NUMBER (18, 3);
   PV_MONTHS_BETN           NUMBER (18);
   PV_TRUNCATED_ACCR_DATE   DATE;
   PV_BROKEN_DAYS           NUMBER (5);

   --Forward declarations start
   --Ref: https://docs.oracle.com/cloud/latest/db112/LNPLS/subprograms.htm#LNPLS99896
   /*
   If nested subprograms in the same PL/SQL block invoke each other, then one requires a forward declaration, because a subprogram must be declared before it can be invoked.
   A forward declaration declares a nested subprogram but does not define it. You must define it later in the same block. The forward declaration and the definition must have the same subprogram heading. */

   FUNCTION UPDATE_CONTROL_TBL (P_BRANCH NUMBER, P_DOACCR_TILL_DT DATE)
      RETURN BOOLEAN;

   FUNCTION ADD_TO_INT_COLL (
      p_contract_rec    depCont,
      p_intrate         PBDCONTRACT.PBDCONT_ACTUAL_INT_RATE%TYPE,
      p_denom           NUMBER)
      RETURN BOOLEAN;

   FUNCTION UPDATE_CALC_AND_CALCBRK_TBLS
      RETURN BOOLEAN;

   FUNCTION GET_RUNNO
      RETURN NUMBER;

   FUNCTION FD_INT_ACCRUAL_CALC (
      p_contract_rec    depCont,
      p_ason_date       DATE,
      p_intrate         PBDCONTRACT.PBDCONT_ACTUAL_INT_RATE%TYPE,
      p_denom           NUMBER)
      RETURN BOOLEAN;

   FUNCTION REINV_INT_ACCRUAL_CALC (p_branch              IN     NUMBER,
                                    p_dep_acnum           IN     NUMBER,
                                    p_contract_ref        IN     NUMBER,
                                    p_mat_date            IN     DATE,
                                    p_mat_value           IN     NUMBER,
                                    p_prin_amt            IN     NUMBER,
                                    p_int_rate            IN     NUMBER,
                                    p_curr_accrual_date   IN     DATE,
                                    p_start_date          IN     DATE,
                                    p_end_date            IN     DATE,
                                    p_prev_accr_date      IN     DATE,
                                    p_denom               IN     NUMBER,
                                    p_freq                IN     NUMBER,
                                    p_int_Accr               OUT NUMBER)
      RETURN BOOLEAN;

   FUNCTION get_TDS_int (p_branch              IN     NUMBER,
                         p_dep_acnum           IN     NUMBER,
                         p_contract_ref        IN     NUMBER,
                         p_curr_accrual_date   IN     DATE,
                         p_mat_date            IN     DATE,
                         p_int_rate            IN     NUMBER,
                         p_denom               IN     NUMBER,
                         p_tot_tds                OUT NUMBER,
                         p_tds_int                OUT NUMBER)
      RETURN BOOLEAN;

   ----Forward declarations end

   -- Initialization
   PROCEDURE START_DEP_ACCRUAL (P_ENTITY_NUM       IN NUMBER,
                                P_BRANCH              NUMBER DEFAULT 0,
                                P_DEP_AC_NUM          NUMBER DEFAULT 0,
                                P_CONTRACT_REF        NUMBER DEFAULT 0,
                                P_DOACCR_TILL_DT      DATE DEFAULT NULL)
   IS
      V_INT_RATE                       PBDCONTRACT.PBDCONT_ACTUAL_INT_RATE%TYPE;
      V_DENOM                          NUMBER;
      V_QRY_STRING                     VARCHAR2 (2300);
      V_QRY_STRING_EXT                 VARCHAR2 (1000);
      V_QRY_STRING_ORG                 VARCHAR2 (2300);
      V_PROD_CODE                      ACNTS.ACNTS_PROD_CODE%TYPE;
      V_PREV_PROD_CODE                 ACNTS.ACNTS_PROD_CODE%TYPE;
      V_PRIN_AMT                       PBDCONTRACT.PBDCONT_AC_DEP_AMT%TYPE;
      V_PERD_INT                       PBDCONTRACT.PBDCONT_PERIODICAL_INT_AMT%TYPE;
      V_START_DATE                     DATE;
      V_END_DATE                       DATE;
      V_INT_ACCR_CALC                  NUMBER (18, 3);
      V_FREQ                           NUMBER;
      V_ATLEAST_ONE_ACCRUAL_HAPPENED   BOOLEAN;
      V_TABDEPCONT                     ty_tab_depCont;
      W_ATLEAST_ONE_ACCRUAL_HAPPENED   BOOLEAN;


      CURSOR CR_DEPPROD (
         V_PROD_CODE   IN NUMBER)
      IS
         SELECT DEPPR_PROD_CODE,
                DEPPR_TYPE_OF_DEP,
                DEPPR_INT_CALC_DENOM,
                DEPPR_INT_COMP_FREQ
           FROM DEPPROD
          WHERE     DEPPR_AUTH_ON IS NOT NULL
                AND DEPPR_TYPE_OF_DEP IN ('1', '2')
                AND (V_PROD_CODE = 0 OR V_PROD_CODE = DEPPR_PROD_CODE);
   BEGIN
      PKG_ENTITY.SP_SET_ENTITY_CODE (P_ENTITY_NUM);
      V_GLOB_ENTITY_NUM := P_ENTITY_NUM;

     <<CHECKPRODCODE>>
      BEGIN
         V_PROD_CODE := 0;

         IF P_DEP_AC_NUM <> 0
         THEN
            SELECT ACNTS_PROD_CODE
              INTO V_PROD_CODE
              FROM ACNTS
             WHERE     ACNTS_ENTITY_NUM = V_GLOB_ENTITY_NUM
                   AND ACNTS_INTERNAL_ACNUM = P_DEP_AC_NUM;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            V_PROD_CODE := 0;
      END CHECKPRODCODE;

      V_QRY_STRING_ORG :=
         'SELECT  T1.PBDCONT_BRN_CODE,
                    T1.PBDCONT_DEP_AC_NUM,
                    T1.PBDCONT_CONT_NUM,
                    T1.PBDCONT_EFF_DATE,
                    T1.PBDCONT_AC_DEP_AMT,
                    T1.PDBCONT_DEP_PRD_MONTHS,
                    T1.PBDCONT_DEP_PRD_DAYS,
                    T1.PBDCONT_INT_ACCR_UPTO,
                    T1.PBDCONT_ACTUAL_INT_RATE,
                    T1.PBDCONT_DISC_INT_RATE,
                    T1.PBDCONT_PERIODICAL_INT_AMT,
                    T1.PBDCONT_INT_PAY_FREQ,
                    T1.PBDCONT_MAT_DATE,
                    T1.PBDCONT_MAT_VALUE,
                    T1.PBDCONT_INT_CALC_UPTO
                    FROM
          PBDCONTRACT T1, ACNTS T2
          WHERE
            ACNTS_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
            AND PBDCONT_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
            AND T1.PBDCONT_DEP_AC_NUM=T2.ACNTS_INTERNAL_ACNUM
            AND T1.PBDCONT_CLOSURE_DATE IS NULL  AND T1.PBDCONT_AUTH_ON IS NOT NULL
            AND T2.ACNTS_PROD_CODE = :1';

      IF P_BRANCH <> 0
      THEN
         V_QRY_STRING_ORG :=
            V_QRY_STRING_ORG || ' AND PBDCONT_BRN_CODE = ' || P_BRANCH;
         V_QRY_STRING_ORG :=
            V_QRY_STRING_ORG || ' AND ACNTS_BRN_CODE = ' || P_BRANCH;
      END IF;

      IF P_DEP_AC_NUM <> 0
      THEN
         V_QRY_STRING_ORG :=
            V_QRY_STRING_ORG || ' AND PBDCONT_DEP_AC_NUM = ' || P_DEP_AC_NUM;
      END IF;

      IF P_CONTRACT_REF <> 0
      THEN
         V_QRY_STRING_ORG :=
            V_QRY_STRING_ORG || ' AND PBDCONT_CONT_NUM = ' || P_CONTRACT_REF;
      END IF;

      IF P_DEP_AC_NUM = 0
      THEN
         V_QRY_STRING_ORG :=
               V_QRY_STRING_ORG
            || ' AND PBDCONT_MAT_DATE > '
            || CHR (39)
            || PKG_EODSOD_FLAGS.PV_CURRENT_DATE
            || CHR (39);
      END IF;

      PV_RUN_NUMBER := GET_RUNNO;

      IF P_DOACCR_TILL_DT IS NOT NULL
      THEN
         PV_CALC_UPTO_DATE := P_DOACCR_TILL_DT;
      ELSE
         PV_CALC_UPTO_DATE := PKG_EODSOD_FLAGS.PV_CURRENT_DATE;
      END IF;

      --Insert into table depcalcctl
      IF NOT UPDATE_CONTROL_TBL (P_BRANCH, PV_CALC_UPTO_DATE)
      THEN
         RAISE E_USER_EXECPTION;
      END IF;

      -- For each Product in DEPPROD --type in ('1', '2')
      FOR each_prod IN CR_DEPPROD (V_PROD_CODE)
      LOOP
         V_PREV_PROD_CODE := each_prod.DEPPR_PROD_CODE;

         IF each_prod.DEPPR_INT_CALC_DENOM = 1
         THEN
            V_DENOM := 36000;
         ELSIF each_prod.DEPPR_INT_CALC_DENOM = 3
         THEN
            V_DENOM := 36600;
         ELSE
            V_DENOM := 36500;
         END IF;

         IF each_prod.DEPPR_INT_COMP_FREQ = 'M'
         THEN
            V_FREQ := 1;
         ELSIF each_prod.DEPPR_INT_COMP_FREQ = 'Q'
         THEN
            V_FREQ := 3;
         ELSIF each_prod.DEPPR_INT_COMP_FREQ = 'H'
         THEN
            V_FREQ := 6;
         ELSE
            V_FREQ := 12;
         END IF;

         IF pv_tblIntAccr IS NOT NULL
         THEN
            pv_tblIntAccr.DELETE;
         END IF;

         IF     each_prod.DEPPR_TYPE_OF_DEP = '1'
            AND P_DOACCR_TILL_DT IS NOT NULL
         THEN
            V_QRY_STRING_EXT :=
                  ' AND (PBDCONT_INT_ACCR_UPTO IS NULL OR PBDCONT_INT_ACCR_UPTO < '
               || CHR (39)
               || P_DOACCR_TILL_DT
               || CHR (39)
               || ')';
            V_QRY_STRING_EXT :=
               V_QRY_STRING_EXT || ' ORDER BY PBDCONT_BRN_CODE';
         ELSIF     each_prod.DEPPR_TYPE_OF_DEP = '2'
               AND P_DOACCR_TILL_DT IS NOT NULL
         THEN
            V_QRY_STRING_EXT :=
                  ' AND (PBDCONT_EFF_DATE IS NULL OR PBDCONT_EFF_DATE <= '
               || CHR (39)
               || P_DOACCR_TILL_DT
               || CHR (39)
               || ')';
            V_QRY_STRING_EXT :=
               V_QRY_STRING_EXT || ' ORDER BY PBDCONT_BRN_CODE';
         ELSE
            V_QRY_STRING_EXT := ' ORDER BY PBDCONT_BRN_CODE';
         END IF;

         V_QRY_STRING := V_QRY_STRING_ORG || V_QRY_STRING_EXT;

         EXECUTE IMMEDIATE V_QRY_STRING
            BULK COLLECT INTO V_TABDEPCONT
            USING each_prod.DEPPR_PROD_CODE;

         --For each valid PBDCONTRACT under a product
         FOR i IN 1 .. V_TABDEPCONT.COUNT
         LOOP
            IF PKG_PROCESS_CHECK.FN_IGNORE_ACNUM (
                  V_GLOB_ENTITY_NUM,
                  V_TABDEPCONT (i).PBDCONT_DEP_AC_NUM) = FALSE
            THEN
               IF    V_TABDEPCONT (i).PBDCONT_INT_ACCR_UPTO IS NULL
                  OR each_prod.DEPPR_TYPE_OF_DEP = '2'
               THEN
                  PV_CALC_FROM_DATE := V_TABDEPCONT (i).PBDCONT_EFF_DATE;
               ELSE
                  PV_CALC_FROM_DATE :=
                     V_TABDEPCONT (i).PBDCONT_INT_ACCR_UPTO + 1;
               END IF;

               PV_PREV_ACCR_DATE :=
                  NVL (V_TABDEPCONT (i).PBDCONT_INT_ACCR_UPTO,
                       V_TABDEPCONT (i).PBDCONT_EFF_DATE);

               IF PV_CALC_FROM_DATE > PKG_EODSOD_FLAGS.PV_CURRENT_DATE
               THEN
                  GOTO NEXT_CONTRACT;
               END IF;

               IF PV_CALC_UPTO_DATE >= V_TABDEPCONT (i).PBDCONT_MAT_DATE
               THEN
                  PV_CALC_UPTO_DATE := V_TABDEPCONT (i).PBDCONT_MAT_DATE - 1;
               END IF;

               --Interest rate
               IF V_TABDEPCONT (i).PBDCONT_INT_PAY_FREQ = 'M'
               THEN
                  V_INT_RATE :=
                     NVL (V_TABDEPCONT (i).PBDCONT_DISC_INT_RATE,
                          V_TABDEPCONT (i).PBDCONT_ACTUAL_INT_RATE);
               ELSE
                  V_INT_RATE :=
                     NVL (V_TABDEPCONT (i).PBDCONT_ACTUAL_INT_RATE,
                          V_TABDEPCONT (i).PBDCONT_DISC_INT_RATE);
               END IF;

              <<VARIABLE_INT_APPL>>
               BEGIN
                    SELECT P.PWGENPARAMD_INT_RATE, P.PWGENPARAMD_EFF_DATE
                      BULK COLLECT INTO v_pwgen
                      FROM PWGENPARAMDTL P
                     WHERE     P.PWGENPARAMD_ENTITY_NUM = V_GLOB_ENTITY_NUM
                           AND P.PWGENPARAMD_PROD_CODE =
                                  each_prod.DEPPR_PROD_CODE
                           AND P.PWGENPARAMD_TENOR_CHOICE =
                                  V_TABDEPCONT (i).PDBCONT_DEP_PRD_MONTHS
                  ORDER BY P.PWGENPARAMD_EFF_DATE DESC;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     NULL;
               END VARIABLE_INT_APPL;

               IF V_INT_RATE = 0 AND v_pwgen.COUNT > 0
               THEN
                  FOR J IN 1 .. v_pwgen.COUNT
                  LOOP
                     IF V_TABDEPCONT (i).PBDCONT_EFF_DATE >=
                           V_PWGEN (J).PBDCONT_EFF_DATE
                     THEN
                        PWGEN_EFF_DATE := V_PWGEN (J).PBDCONT_EFF_DATE;
                        V_INT_RATE := V_PWGEN (J).PBDCONT_ACTUAL_INT_RATE;
                        EXIT;
                     END IF;
                  END LOOP;
               END IF;

               IF     v_pwgen.COUNT > 0
                  AND V_INT_RATE <> V_TABDEPCONT (i).PBDCONT_ACTUAL_INT_RATE
               THEN
                  IF V_TABDEPCONT (i).PBDCONT_INT_PAY_FREQ = 'M'
                  THEN
                     V_TABDEPCONT (i).PBDCONT_PERIODICAL_INT_AMT :=
                          V_TABDEPCONT (i).PBDCONT_AC_DEP_AMT
                        * V_INT_RATE
                        * 1
                        / 1200;
                  ELSIF V_TABDEPCONT (i).PBDCONT_INT_PAY_FREQ = 'Q'
                  THEN
                     V_TABDEPCONT (i).PBDCONT_PERIODICAL_INT_AMT :=
                          V_TABDEPCONT (i).PBDCONT_AC_DEP_AMT
                        * V_INT_RATE
                        * 3
                        / 1200;
                  ELSIF V_TABDEPCONT (i).PBDCONT_INT_PAY_FREQ = 'H'
                  THEN
                     V_TABDEPCONT (i).PBDCONT_PERIODICAL_INT_AMT :=
                          V_TABDEPCONT (i).PBDCONT_AC_DEP_AMT
                        * V_INT_RATE
                        * 6
                        / 1200;
                  ELSIF V_TABDEPCONT (i).PBDCONT_INT_PAY_FREQ = 'Y'
                  THEN
                     V_TABDEPCONT (i).PBDCONT_PERIODICAL_INT_AMT :=
                          V_TABDEPCONT (i).PBDCONT_AC_DEP_AMT
                        * V_INT_RATE
                        * 12
                        / 1200;
                  END IF;
               END IF;


               IF each_prod.DEPPR_TYPE_OF_DEP = '1'
               THEN
                  --Initialize INT_PERD_DTLS collection

                  IF pv_tblIntPrd IS NOT NULL
                  THEN
                     pv_tblIntPrd.DELETE;
                     PV_IDX1 := 0;
                  END IF;

                  IF NOT FD_INT_ACCRUAL_CALC (V_TABDEPCONT (i),
                                              PV_CALC_UPTO_DATE,
                                              V_INT_RATE,
                                              V_DENOM)
                  THEN
                     NULL;
                  END IF;
               ELSIF each_prod.DEPPR_TYPE_OF_DEP = '2'
               THEN
                  IF NOT REINV_INT_ACCRUAL_CALC (
                            V_TABDEPCONT (i).PBDCONT_BRN_CODE,
                            V_TABDEPCONT (i).PBDCONT_DEP_AC_NUM,
                            V_TABDEPCONT (i).PBDCONT_CONT_NUM,
                            V_TABDEPCONT (i).PBDCONT_MAT_DATE,
                            V_TABDEPCONT (i).PBDCONT_MAT_VALUE,
                            V_TABDEPCONT (i).PBDCONT_AC_DEP_AMT,
                            V_INT_RATE,
                            PV_CALC_UPTO_DATE,
                            PV_CALC_FROM_DATE,
                            PV_CALC_UPTO_DATE,
                            PV_PREV_ACCR_DATE,
                            V_DENOM,
                            V_FREQ,
                            V_INT_ACCR_CALC)
                  THEN
                     NULL;
                  END IF;
               END IF;

              <<NEXT_CONTRACT>>
               NULL;
            END IF;
         END LOOP;          --For each valid PBDCONTRACT under a product - end

         IF pv_tblIntAccr.COUNT > 0
         THEN
            W_ATLEAST_ONE_ACCRUAL_HAPPENED := TRUE;

            IF NOT UPDATE_CALC_AND_CALCBRK_TBLS
            THEN
               W_ATLEAST_ONE_ACCRUAL_HAPPENED := FALSE;
               RAISE E_USER_EXECPTION;
            END IF;
         END IF;

         --CLEAR THE COLLECTION
         pv_tblIntAccr.DELETE;
         PV_IDX2 := 0;
      END LOOP;

      IF W_ATLEAST_ONE_ACCRUAL_HAPPENED = TRUE
      THEN
         IF P_DEP_AC_NUM = 0
         THEN
            PKG_DEP_ACCRUAL_POST.start_depacrr_post (V_GLOB_ENTITY_NUM,
                                                     P_branch,
                                                     pv_run_number,
                                                     FALSE);
         ELSE
            PKG_DEP_ACCRUAL_POST.start_depacrr_post (V_GLOB_ENTITY_NUM,
                                                     P_branch,
                                                     pv_run_number,
                                                     TRUE);
         END IF;

         IF PKG_EODSOD_FLAGS.PV_ERROR_MSG <> ' '
         THEN
            PV_ERR_MSG := PKG_EODSOD_FLAGS.PV_ERROR_MSG;
            W_ATLEAST_ONE_ACCRUAL_HAPPENED := FALSE;
            RAISE E_USER_EXECPTION;
         END IF;
      END IF;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         IF TRIM (PV_ERR_MSG) IS NULL
         THEN
            PV_ERR_MSG :=
                  'Error in start_deprip_accrual PROCEDURE.Error Msg: '
               || SUBSTR (SQLERRM, 1, 900);
         END IF;

         PKG_EODSOD_FLAGS.PV_ERROR_MSG := PV_ERR_MSG;
         PKG_PB_GLOBAL.DETAIL_ERRLOG (V_GLOB_ENTITY_NUM,
                                      'E',
                                      PV_ERR_MSG,
                                      ' ',
                                      0);
   --deppr_type_of_dep
   END START_DEP_ACCRUAL;

   FUNCTION UPDATE_CONTROL_TBL (P_BRANCH NUMBER, P_DOACCR_TILL_DT DATE)
      RETURN BOOLEAN
   IS
   BEGIN
      INSERT INTO DEPCALCCTL (DEPCTL_ENTITY_NUM,
                              DEPCALCCTL.DEPCTL_BRN_CODE,
                              DEPCTL_RUN_NUM,
                              DEPCTL_PROD_CODE,
                              DEPCTL_RUN_DATE,
                              DEPCTL_ACCRUAL_UPTO_DATE,
                              DEPCTL_RUN_BY,
                              DEPCTL_RUN_ON,
                              DEPCTL_POSTED_BY,
                              DEPCTL_POSTED_ON,
                              DEPCTL_POSTED_BATCH_NUM,
                              DEPCTL_POSTED_BRN,
                              DEPCTL_EXEC_TYPE)
           VALUES (V_GLOB_ENTITY_NUM,
                   P_BRANCH,
                   PV_RUN_NUMBER,
                   0,
                   PKG_PB_GLOBAL.FN_GET_CURR_BUS_DATE (V_GLOB_ENTITY_NUM),
                   P_DOACCR_TILL_DT,
                   PKG_EODSOD_FLAGS.PV_USER_ID, --/pkg_pb_global.g_get_ins_user_id
                   PKG_PB_GLOBAL.FN_GET_CURR_BUS_DATE (V_GLOB_ENTITY_NUM),
                   ' ',
                   NULL,
                   0,
                   0,
                   'A');

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         PV_ERR_MSG :=
               SUBSTR (SQLERRM, 1, 800)
            || '-'
            || 'ERROR WHILE INSERTING TO DEPCALCCTL FOR '
            || P_BRANCH
            || '/'
            || PV_RUN_NUMBER;
         PKG_EODSOD_FLAGS.PV_ERROR_MSG := PV_ERR_MSG;
         PKG_PB_GLOBAL.DETAIL_ERRLOG (V_GLOB_ENTITY_NUM, 'E', PV_ERR_MSG);
         RETURN FALSE;
   END;

   FUNCTION FD_INT_ACCRUAL_CALC (
      p_contract_rec    depCont,
      p_ason_date       DATE,
      p_intrate         PBDCONTRACT.PBDCONT_ACTUAL_INT_RATE%TYPE,
      p_denom           NUMBER)
      RETURN BOOLEAN
   IS
      v_int_freq               NUMBER (2);
      v_freq                   NUMBER (5);
      v_seed_date              DATE;
      v_intPrd_start_dt        DATE;
      v_intPrd_End_dt          DATE;
      v_temp_Start_dt          DATE;
      v_temp_End_dt            DATE;
      v_prev_end_dt            DATE;
      v_over                   NUMBER (1);
      v_brk_sl                 NUMBER (5);
      v_INT_ACCR_AMT           NUMBER (18, 3);
      v_LEAN_AMOUNT            NUMBER (18, 3) := 0.00;
      v_ACNT_AVGBAL            NUMBER (18, 3) := 0.00;
      v_nod                    NUMBER (5);

      V_ORG_AC_AMT             NUMBER (18, 3);
      V_ACT_INT_RATE           NUMBER (7, 5);
      V_CALC_CHOICE            CHAR (1);
      V_CALC_DENOM             CHAR (1);
      V_PRD_CHOICE             CHAR (1);
      V_INT_SPECIFIED_CHOICE   CHAR (1);
      V_BROKEN_DAYS            NUMBER (5);
      V_TRUNCATED_ACCR_DATE    DATE;
      V_DENOM                  NUMBER (14);
      V_CALC_INT_AMT           NUMBER (18, 3);
      V_MONTHS_BETN            NUMBER (18);

      TYPE REC_DEPIRHDT IS RECORD
      (
         DEPIRHDT_EFF_FROM_DATE   DATE,
         DEPIRHDT_EFF_UPTO_DATE   DATE,
         DEPIRHDT_INT_RATE        NUMBER (18, 3)
      );

      TYPE TT_REC_DEPIRHDT IS TABLE OF REC_DEPIRHDT
         INDEX BY PLS_INTEGER;

      T_REC_DEPIRHDT           TT_REC_DEPIRHDT;
      V_SQL_STAT               VARCHAR2 (4000);
   BEGIN
      IF p_contract_rec.PBDCONT_INT_PAY_FREQ = 'X'
      THEN
         PV_IDX1 := PV_IDX1 + 1;
         pv_tblIntPrd (PV_IDX1).From_date := p_contract_rec.PBDCONT_EFF_DATE;
         pv_tblIntPrd (PV_IDX1).UPTO_date :=
            p_contract_rec.PBDCONT_MAT_DATE - 1;
         pv_tblIntPrd (PV_IDX1).Full_period_flag := '1';
      ELSE
         IF p_contract_rec.PBDCONT_INT_PAY_FREQ = 'M'
         THEN
            v_int_freq := 1;
         ELSIF p_contract_rec.PBDCONT_INT_PAY_FREQ = 'Q'
         THEN
            v_int_freq := 3;
         ELSIF p_contract_rec.PBDCONT_INT_PAY_FREQ = 'H'
         THEN
            v_int_freq := 6;
         ELSIF p_contract_rec.PBDCONT_INT_PAY_FREQ = 'Y'
         THEN
            v_int_freq := 12;
         END IF;

         v_intPrd_start_dt := p_contract_rec.PBDCONT_EFF_DATE;
         v_seed_date := v_intPrd_start_dt;
         v_prev_end_dt := NULL;
         v_over := 0;
         v_freq := v_int_freq;

         WHILE v_over = 0
         LOOP
            v_temp_End_dt := fn_month_add (v_seed_date, v_freq);
            v_intPrd_End_dt := v_temp_End_dt - 1;

            IF v_intPrd_End_dt > p_contract_rec.PBDCONT_MAT_DATE
            THEN
               v_over := 1;
               PV_IDX1 := PV_IDX1 + 1;
               pv_tblIntPrd (PV_IDX1).From_date := v_intprd_start_dt;
               pv_tblIntPrd (PV_IDX1).UPTO_date :=
                  p_contract_rec.PBDCONT_MAT_DATE - 1;
               pv_tblIntPrd (PV_IDX1).Full_period_flag := '0';
               v_prev_end_dt := v_intPrd_End_dt; --Sriram B - 10-09-2009 - changed due to excess interest for 13 months deposit
            ELSE
               PV_IDX1 := PV_IDX1 + 1;
               pv_tblIntPrd (PV_IDX1).From_date := v_intPrd_start_dt;
               pv_tblIntPrd (PV_IDX1).UPTO_date := v_intPrd_End_dt;
               pv_tblIntPrd (PV_IDX1).Full_period_flag := '1';
               v_prev_end_dt := v_intPrd_End_dt;
               v_freq := v_freq + v_int_freq;
               v_intPrd_start_dt := v_temp_End_dt;

               IF v_intPrd_End_dt >= p_ason_date
               THEN
                  v_over := 1;
               END IF;
            END IF;
         END LOOP;

         IF (v_prev_end_dt IS NULL) OR (v_prev_end_dt < p_ason_date)
         THEN
            IF NOT (v_prev_end_dt >= p_contract_rec.PBDCONT_MAT_DATE - 1)
            THEN
               v_intPrd_start_dt := v_prev_end_dt + 1;
               v_intPrd_End_dt := p_contract_rec.PBDCONT_MAT_DATE - 1;
               PV_IDX1 := PV_IDX1 + 1;
               pv_tblIntPrd (PV_IDX1).From_date := v_intPrd_start_dt;
               pv_tblIntPrd (PV_IDX1).UPTO_date := v_intPrd_End_dt;
               pv_tblIntPrd (PV_IDX1).Full_period_flag := '0';
            END IF;
         END IF;
      END IF;

      IF NOT add_to_int_coll (p_contract_rec, p_intrate, p_denom)
      THEN
         RETURN FALSE;
      END IF;

      v_over := 0;
      v_brk_sl := 1;

      IF PV_CALC_UPTO_DATE >= PV_CALC_FROM_DATE
      THEN
         WHILE v_over = 0
         LOOP
            --get a INT_PERD_DTLS collection entry where pkg-calc-from-date lies between from and to dates
            --in the collection
            FOR i IN 1 .. PV_IDX1
            LOOP
               IF     pv_tblIntPrd (i).from_date <= PV_CALC_FROM_DATE
                  AND pv_tblIntPrd (i).upto_date >= PV_CALC_FROM_DATE
               THEN
                 <<GET_ACTUAL_INT>>
                  BEGIN
                     SELECT P.PBDCONT_AC_DEP_AMT,
                            P.PBDCONT_ACTUAL_INT_RATE,
                            D.DEPPR_INT_CALC_CHOICE,
                            D.DEPPR_INT_CALC_DENOM,
                            D.DEPPR_INT_PRD_CALC_CHOICE,
                            DEPPR_INT_SPECIFIED_CHOICE
                       INTO V_ORG_AC_AMT,
                            V_ACT_INT_RATE,
                            V_CALC_CHOICE,
                            V_CALC_DENOM,
                            V_PRD_CHOICE,
                            V_INT_SPECIFIED_CHOICE
                       FROM PBDCONTRACT P, DEPPROD D
                      WHERE     P.PBDCONT_ENTITY_NUM = V_GLOB_ENTITY_NUM
                            AND P.PBDCONT_DEP_AC_NUM =
                                   p_contract_rec.PBDCONT_DEP_AC_NUM
                            AND P.PBDCONT_CONT_NUM =
                                   p_contract_rec.PBDCONT_CONT_NUM
                            AND P.PBDCONT_BRN_CODE =
                                   p_contract_rec.PBDCONT_BRN_CODE
                            AND P.PBDCONT_PROD_CODE = D.DEPPR_PROD_CODE;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        pv_err_msg := SUBSTR (SQLERRM, 1, 500);
                        RAISE E_user_execption;
                  END GET_ACTUAL_INT;

                  IF V_CALC_DENOM = '1'
                  THEN
                     V_DENOM := 36000;
                  ELSIF V_CALC_DENOM = '2'
                  THEN
                     V_DENOM := 36500;
                  ELSIF V_CALC_DENOM = '3'
                  THEN
                     V_DENOM := 36600;
                  END IF;
                  
                  v_temp_End_dt := pv_tblIntPrd (i).upto_date;
                  v_temp_Start_dt := PV_CALC_FROM_DATE;
                  
                  IF PV_CALC_UPTO_DATE >= pv_tblIntPrd (i).upto_date
                  THEN
                     


                     IF V_INT_SPECIFIED_CHOICE = '2'
                     THEN
                        --- start of Account level profit calculation

                        V_NOD := v_temp_End_dt - v_temp_Start_dt + 1;

                        v_LEAN_AMOUNT :=
                           FN_GET_LEAN_AVG_BAL (
                              V_GLOB_ENTITY_NUM,
                              p_contract_rec.PBDCONT_DEP_AC_NUM,
                              v_temp_Start_dt,
                              v_temp_End_dt);

                        v_ACNT_AVGBAL :=
                           FN_GET_AVG_BAL_ISLAMIC (
                              V_GLOB_ENTITY_NUM,
                              p_contract_rec.PBDCONT_DEP_AC_NUM,
                              v_temp_Start_dt,
                              v_temp_End_dt);

                        IF v_LEAN_AMOUNT < 0
                        THEN
                           V_ORG_AC_AMT := v_ACNT_AVGBAL + v_LEAN_AMOUNT;
                        ELSE
                           V_ORG_AC_AMT := v_ACNT_AVGBAL;
                        END IF;

                        v_INT_ACCR_AMT :=
                           (V_ORG_AC_AMT * V_ACT_INT_RATE * V_NOD) / V_DENOM;

                        PV_IDX2 := PV_IDX2 + 1;
                        pv_tblIntAccr (PV_IDX2).BRN_CODE :=
                           p_contract_rec.PBDCONT_BRN_CODE;
                        pv_tblIntAccr (PV_IDX2).DEP_AC_NUM :=
                           p_contract_rec.PBDCONT_DEP_AC_NUM;
                        pv_tblIntAccr (PV_IDX2).CONT_NUM :=
                           p_contract_rec.PBDCONT_CONT_NUM;
                        pv_tblIntAccr (PV_IDX2).ACCR_SL := v_brk_sl;
                        pv_tblIntAccr (PV_IDX2).CALC_FROM_DATE :=
                           v_temp_Start_dt;
                        pv_tblIntAccr (PV_IDX2).CALC_UPTO_DATE :=
                           v_temp_End_dt;
                        pv_tblIntAccr (PV_IDX2).DEPCAC_INT_ON_AMOUNT :=
                           V_ORG_AC_AMT;
                        pv_tblIntAccr (PV_IDX2).INT_ACCR_AMT := v_INT_ACCR_AMT;
                        pv_tblintaccr (PV_IDX2).PREV_ACCR_UPTO :=
                           PV_PREV_ACCR_DATE;
                        pv_tblIntAccr (PV_IDX2).INT_PRD_END_FLAG := '1';
                     --- end of Account level profit calculation

                     ELSE
                        --- start of product level profit calculation
                        V_SQL_STAT :=
                           'SELECT DEPIRHDT_EFF_FROM_DATE, DEPIRHDT_EFF_UPTO_DATE, DEPIRHDT_INT_RATE
                     FROM TABLE (PKG_GET_DEPINTRATE.FN_GET_DEPINTRATE(:1,:2,:3, :4)) ORDER BY DEPIRHDT_EFF_FROM_DATE';

                        EXECUTE IMMEDIATE V_SQL_STAT
                           BULK COLLECT INTO T_REC_DEPIRHDT
                           USING V_GLOB_ENTITY_NUM,
                                 p_contract_rec.PBDCONT_DEP_AC_NUM,
                                 v_temp_Start_dt,
                                 v_temp_End_dt;

                        FOR IDX IN 1 .. T_REC_DEPIRHDT.COUNT
                        LOOP
                           V_ACT_INT_RATE :=
                              T_REC_DEPIRHDT (IDX).DEPIRHDT_INT_RATE;

                           V_NOD :=
                                T_REC_DEPIRHDT (IDX).DEPIRHDT_EFF_UPTO_DATE
                              - T_REC_DEPIRHDT (IDX).DEPIRHDT_EFF_FROM_DATE
                              + 1;

                           v_LEAN_AMOUNT :=
                              FN_GET_LEAN_AVG_BAL (
                                 V_GLOB_ENTITY_NUM,
                                 p_contract_rec.PBDCONT_DEP_AC_NUM,
                                 T_REC_DEPIRHDT (IDX).DEPIRHDT_EFF_FROM_DATE,
                                 T_REC_DEPIRHDT (IDX).DEPIRHDT_EFF_UPTO_DATE);

                           v_ACNT_AVGBAL :=
                              FN_GET_AVG_BAL_ISLAMIC (
                                 V_GLOB_ENTITY_NUM,
                                 p_contract_rec.PBDCONT_DEP_AC_NUM,
                                 T_REC_DEPIRHDT (IDX).DEPIRHDT_EFF_FROM_DATE,
                                 T_REC_DEPIRHDT (IDX).DEPIRHDT_EFF_UPTO_DATE);

                           IF v_LEAN_AMOUNT < 0
                           THEN
                              V_ORG_AC_AMT := v_ACNT_AVGBAL + v_LEAN_AMOUNT;
                           ELSE
                              V_ORG_AC_AMT := v_ACNT_AVGBAL;
                           END IF;

                           v_INT_ACCR_AMT :=
                                (V_ORG_AC_AMT * V_ACT_INT_RATE * V_NOD)
                              / V_DENOM;

                           PV_IDX2 := PV_IDX2 + 1;
                           pv_tblIntAccr (PV_IDX2).BRN_CODE :=
                              p_contract_rec.PBDCONT_BRN_CODE;
                           pv_tblIntAccr (PV_IDX2).DEP_AC_NUM :=
                              p_contract_rec.PBDCONT_DEP_AC_NUM;
                           pv_tblIntAccr (PV_IDX2).CONT_NUM :=
                              p_contract_rec.PBDCONT_CONT_NUM;
                           pv_tblIntAccr (PV_IDX2).ACCR_SL := v_brk_sl;
                           pv_tblIntAccr (PV_IDX2).CALC_FROM_DATE :=
                              T_REC_DEPIRHDT (IDX).DEPIRHDT_EFF_FROM_DATE;
                           pv_tblIntAccr (PV_IDX2).CALC_UPTO_DATE :=
                              T_REC_DEPIRHDT (IDX).DEPIRHDT_EFF_UPTO_DATE;
                           pv_tblIntAccr (PV_IDX2).DEPCAC_INT_ON_AMOUNT :=
                              V_ORG_AC_AMT;
                           pv_tblIntAccr (PV_IDX2).INT_ACCR_AMT :=
                              v_INT_ACCR_AMT;
                           pv_tblintaccr (PV_IDX2).PREV_ACCR_UPTO :=
                              PV_PREV_ACCR_DATE;
                           pv_tblIntAccr (PV_IDX2).INT_PRD_END_FLAG := '1';
                        END LOOP;
                     --- end of product level profit calculation

                     END IF;

                     IF PV_CALC_UPTO_DATE = pv_tblIntPrd (i).upto_date
                     THEN
                        v_over := 1;
                     ELSE
                        PV_CALC_FROM_DATE := v_temp_End_dt + 1;

                        IF PV_CALC_FROM_DATE > pv_tblIntPrd (i).upto_date
                        THEN
                           v_over := 1;
                        END IF;
                     END IF;
                  ELSE
                     V_BROKEN_DAYS := 0;
                     V_TRUNCATED_ACCR_DATE := '';

                     IF V_INT_SPECIFIED_CHOICE = '2'
                     THEN
                        --- start of Account level profit calculation

                        v_nod := PV_CALC_UPTO_DATE - PV_CALC_FROM_DATE + 1;

                        v_LEAN_AMOUNT :=
                           FN_GET_LEAN_AVG_BAL (
                              V_GLOB_ENTITY_NUM,
                              p_contract_rec.PBDCONT_DEP_AC_NUM,
                              PV_CALC_UPTO_DATE,
                              PV_CALC_FROM_DATE);

                        v_ACNT_AVGBAL :=
                           FN_GET_AVG_BAL_ISLAMIC (
                              V_GLOB_ENTITY_NUM,
                              p_contract_rec.PBDCONT_DEP_AC_NUM,
                              PV_CALC_UPTO_DATE,
                              PV_CALC_FROM_DATE);

                        IF v_LEAN_AMOUNT < 0
                        THEN
                           V_ORG_AC_AMT := v_ACNT_AVGBAL + v_LEAN_AMOUNT;
                        ELSE
                           V_ORG_AC_AMT := v_ACNT_AVGBAL;
                        END IF;

                        v_INT_ACCR_AMT :=
                           (V_ORG_AC_AMT * V_ACT_INT_RATE * V_NOD) / V_DENOM;

                        --- Comments for Islamic Banking
                        /*
                         IF v_nod = pv_tblIntPrd(i).nod THEN

                        v_INT_ACCR_AMT := (V_ORG_AC_AMT * V_ACT_INT_RATE * V_NOD) / V_DENOM;
                          ---v_INT_ACCR_AMT := nvl(pv_tblIntPrd(i).Period_int_amt, 0);
                        ELSE
                           IF V_CALC_CHOICE = 'D' THEN
                             V_NOD :=PV_CALC_UPTO_DATE - PV_CALC_FROM_DATE + 1;
                              V_CALC_INT_AMT := (V_ORG_AC_AMT * V_ACT_INT_RATE * V_NOD) / V_DENOM;
                           ELSIF V_CALC_CHOICE = 'M' THEN
                             V_MONTHS_BETN := trunc(months_between((PV_CALC_UPTO_DATE+1), PV_CALC_FROM_DATE));
                             V_NOD := V_MONTHS_BETN * 30;

                             V_CALC_INT_AMT := 0; --Init
                             IF V_PRD_CHOICE = '1' THEN
                               V_NOD  :=  PV_CALC_UPTO_DATE - PV_CALC_FROM_DATE + 1;
                             ELSIF V_PRD_CHOICE = '2' THEN
                                   IF V_MONTHS_BETN > 0 THEN
                                   V_NOD := V_MONTHS_BETN * 30;
                                    IF p_contract_rec.PBDCONT_INT_PAY_FREQ = 'X' THEN
                                     V_NOD  :=  PV_CALC_UPTO_DATE - PV_CALC_FROM_DATE + 1;
                                     V_CALC_INT_AMT := (nvl(pv_tblIntPrd(i).Period_int_amt, 0) / pv_tblIntPrd(i).nod) *
                                                      V_NOD;
                                    END IF;
                                   ELSE
                                   V_NOD  :=  PV_CALC_UPTO_DATE - PV_CALC_FROM_DATE + 1;
                                   V_CALC_INT_AMT := (nvl(pv_tblIntPrd(i).Period_int_amt, 0) / pv_tblIntPrd(i).nod) *
                                                      V_NOD; --Assign
                                   END IF;
                             ELSIF  V_PRD_CHOICE = '3' THEN
                               V_NOD  :=  PV_CALC_UPTO_DATE - PV_CALC_FROM_DATE + 1;
                             END IF;
                             IF  V_CALC_INT_AMT = 0 THEN --check
                              V_CALC_INT_AMT := (V_ORG_AC_AMT * V_ACT_INT_RATE * V_NOD) / V_DENOM;
                              IF V_BROKEN_DAYS > 0 THEN
                              V_CALC_INT_AMT := V_CALC_INT_AMT + ((nvl(pv_tblIntPrd(i).Period_int_amt, 0) / pv_tblIntPrd(i).nod) *V_BROKEN_DAYS);
                              END IF;
                             END IF;
                           END IF;

                            if V_CALC_CHOICE = '' THEN
                              v_INT_ACCR_AMT := (nvl(pv_tblIntPrd(i).Period_int_amt, 0) / pv_tblIntPrd(i).nod) *
                                                v_nod;
                            ELSE
                              v_INT_ACCR_AMT :=    V_CALC_INT_AMT ;
                             END IF;
                        END IF;
                        */
                        --- Comments for Islamic Banking

                        PV_IDX2 := PV_IDX2 + 1;
                        pv_tblIntAccr (PV_IDX2).BRN_CODE :=
                           p_contract_rec.PBDCONT_BRN_CODE;
                        pv_tblIntAccr (PV_IDX2).DEP_AC_NUM :=
                           p_contract_rec.PBDCONT_DEP_AC_NUM;
                        pv_tblIntAccr (PV_IDX2).CONT_NUM :=
                           p_contract_rec.PBDCONT_CONT_NUM;
                        pv_tblIntAccr (PV_IDX2).ACCR_SL := v_brk_sl;
                        pv_tblIntAccr (PV_IDX2).CALC_FROM_DATE :=
                           PV_CALC_FROM_DATE;
                        pv_tblIntAccr (PV_IDX2).CALC_UPTO_DATE :=
                           PV_CALC_UPTO_DATE;
                        pv_tblIntAccr (PV_IDX2).DEPCAC_INT_ON_AMOUNT :=
                           V_ORG_AC_AMT;
                        pv_tblIntAccr (PV_IDX2).INT_ACCR_AMT := v_INT_ACCR_AMT;
                        pv_tblIntAccr (PV_IDX2).INT_PRD_END_FLAG := '0';
                        pv_tblintaccr (PV_IDX2).PREV_ACCR_UPTO :=
                           PV_PREV_ACCR_DATE;
                        v_over := 1;
                     --- end of Account level profit calculation

                     ELSE
                        --- start of product level profit calculation
                        V_SQL_STAT :=
                           'SELECT DEPIRHDT_EFF_FROM_DATE, DEPIRHDT_EFF_UPTO_DATE, DEPIRHDT_INT_RATE
                     FROM TABLE (PKG_GET_DEPINTRATE.FN_GET_DEPINTRATE(:1,:2,:3, :4)) ORDER BY DEPIRHDT_EFF_FROM_DATE';

                        EXECUTE IMMEDIATE V_SQL_STAT
                           BULK COLLECT INTO T_REC_DEPIRHDT
                           USING V_GLOB_ENTITY_NUM,
                                 p_contract_rec.PBDCONT_DEP_AC_NUM,
                                 v_temp_Start_dt,
                                 v_temp_End_dt;

                        FOR IDX IN 1 .. T_REC_DEPIRHDT.COUNT
                        LOOP
                           V_ACT_INT_RATE :=
                              T_REC_DEPIRHDT (IDX).DEPIRHDT_INT_RATE;

                           V_NOD :=
                                T_REC_DEPIRHDT (IDX).DEPIRHDT_EFF_UPTO_DATE
                              - T_REC_DEPIRHDT (IDX).DEPIRHDT_EFF_FROM_DATE
                              + 1;

                           v_LEAN_AMOUNT :=
                              FN_GET_LEAN_AVG_BAL (
                                 V_GLOB_ENTITY_NUM,
                                 p_contract_rec.PBDCONT_DEP_AC_NUM,
                                 T_REC_DEPIRHDT (IDX).DEPIRHDT_EFF_FROM_DATE,
                                 T_REC_DEPIRHDT (IDX).DEPIRHDT_EFF_UPTO_DATE);

                           v_ACNT_AVGBAL :=
                              FN_GET_AVG_BAL_ISLAMIC (
                                 V_GLOB_ENTITY_NUM,
                                 p_contract_rec.PBDCONT_DEP_AC_NUM,
                                 T_REC_DEPIRHDT (IDX).DEPIRHDT_EFF_FROM_DATE,
                                 T_REC_DEPIRHDT (IDX).DEPIRHDT_EFF_UPTO_DATE);

                           IF v_LEAN_AMOUNT < 0
                           THEN
                              V_ORG_AC_AMT := v_ACNT_AVGBAL + v_LEAN_AMOUNT;
                           ELSE
                              V_ORG_AC_AMT := v_ACNT_AVGBAL;
                           END IF;

                           v_INT_ACCR_AMT :=
                                (V_ORG_AC_AMT * V_ACT_INT_RATE * V_NOD)
                              / V_DENOM;

                           PV_IDX2 := PV_IDX2 + 1;
                           pv_tblIntAccr (PV_IDX2).BRN_CODE :=
                              p_contract_rec.PBDCONT_BRN_CODE;
                           pv_tblIntAccr (PV_IDX2).DEP_AC_NUM :=
                              p_contract_rec.PBDCONT_DEP_AC_NUM;
                           pv_tblIntAccr (PV_IDX2).CONT_NUM :=
                              p_contract_rec.PBDCONT_CONT_NUM;
                           pv_tblIntAccr (PV_IDX2).ACCR_SL := v_brk_sl;
                           pv_tblIntAccr (PV_IDX2).CALC_FROM_DATE :=
                              T_REC_DEPIRHDT (IDX).DEPIRHDT_EFF_FROM_DATE;
                           pv_tblIntAccr (PV_IDX2).CALC_UPTO_DATE :=
                              T_REC_DEPIRHDT (IDX).DEPIRHDT_EFF_UPTO_DATE;
                           pv_tblIntAccr (PV_IDX2).DEPCAC_INT_ON_AMOUNT :=
                              V_ORG_AC_AMT;
                           pv_tblIntAccr (PV_IDX2).INT_ACCR_AMT :=
                              v_INT_ACCR_AMT;
                           pv_tblintaccr (PV_IDX2).PREV_ACCR_UPTO :=
                              PV_PREV_ACCR_DATE;
                           pv_tblIntAccr (PV_IDX2).INT_PRD_END_FLAG := '1';
                        END LOOP;
                        --- end of product level profit calculation
                        v_over := 1;

                     END IF;
                  END IF;
               END IF;

               v_brk_sl := v_brk_sl + 1;
            END LOOP;
         END LOOP;
      END IF;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         PV_ERR_MSG :=
               ' Error In FD_INT_ACCRUAL_CALC FUNCTION For- '
            || p_contract_rec.PBDCONT_BRN_CODE
            || '/'
            || facno (V_GLOB_ENTITY_NUM, p_contract_rec.PBDCONT_DEP_AC_NUM)
            || '/'
            || p_contract_rec.PBDCONT_CONT_NUM;
         PV_ERR_MSG := PV_ERR_MSG || SUBSTR (SQLERRM, 1, 500);
         PKG_EODSOD_FLAGS.PV_ERROR_MSG := PV_ERR_MSG;
         PKG_PB_GLOBAL.DETAIL_ERRLOG (
            V_GLOB_ENTITY_NUM,
            'E',
            PV_ERR_MSG,
            ' ',
            facno (V_GLOB_ENTITY_NUM, p_contract_rec.PBDCONT_DEP_AC_NUM));
         RETURN FALSE;
   END;

   FUNCTION REINV_INT_ACCRUAL_CALC (p_branch              IN     NUMBER,
                                    p_dep_acnum           IN     NUMBER,
                                    p_contract_ref        IN     NUMBER,
                                    p_mat_date            IN     DATE,
                                    p_mat_value           IN     NUMBER,
                                    p_prin_amt            IN     NUMBER,
                                    p_int_rate            IN     NUMBER,
                                    p_curr_accrual_date   IN     DATE,
                                    p_start_date          IN     DATE,
                                    p_end_date            IN     DATE,
                                    p_prev_accr_date      IN     DATE,
                                    p_denom               IN     NUMBER,
                                    p_freq                IN     NUMBER,
                                    p_int_Accr               OUT NUMBER)
      RETURN BOOLEAN
   IS
      l_num_of_days            NUMBER (5);
      l_num_of_mons            NUMBER (5);
      l_num_of_quaters         NUMBER (5);
      l_num_of_rem_mons        NUMBER (5);
      l_calc_value             NUMBER (18, 3);
      l_tot_int                NUMBER (18, 3);
      l_int                    NUMBER (18, 3);
      l_brk_int                NUMBER (18, 3);
      l_dep_ac_bal             NUMBER (18, 3);
      l_tot_tds                NUMBER (18, 3);
      l_tds_int                NUMBER (18, 3);
      l_accr_amt               NUMBER (18, 3) := 0;
      AC_CURR_CODE             CHAR (3);
      AC_AUTH_BAL              NUMBER;
      AC_UNAUTH_DBS            NUMBER;
      AC_UNAUTH_CRS            NUMBER;
      AC_FWDVAL_DBS            NUMBER;
      AC_FWDVAL_CRS            NUMBER;
      AC_TOT_BAL               NUMBER;
      AC_LIEN_AMT              NUMBER;
      HOLD_AMT                 NUMBER;
      MIN_BAL                  NUMBER;
      AC_AVLBAL                NUMBER;
      AC_EFFBAL                NUMBER;
      UNUSED_LIMIT             NUMBER;
      BC_AUTH_BAL              NUMBER;
      BC_UNAUTH_DBS            NUMBER;
      BC_UNAUTH_CRS            NUMBER;
      BC_FWDVAL_DBS            NUMBER;
      BC_FWDVAL_CRS            NUMBER;
      BC_TOT_BAL               NUMBER;
      BC_LIEN_AMT              NUMBER;
      AC_CLGVAL_DBS            NUMBER;
      AC_CLGVAL_CRS            NUMBER;
      AC_CLOSURE_DT            DATE;
      AC_ACNT_FREEZED          VARCHAR2 (5);
      AC_ACNT_AUTH_ON          DATE;
      AC_ACNT_DORMANT_ACNT     CHAR;
      AC_ACNT_INOP_ACNT        CHAR;
      AC_ACNT_DB_FREEZED       CHAR;
      AC_ACNT_CR_FREEZED       CHAR;
      P_TOT_LMT_AMT            NUMBER;
      P_EFF_BAL_WOT_LMT        NUMBER;
      P_ERR_MSG                VARCHAR2 (2000);

      P_ADV_PRIN_AC_BAL        NUMBER;
      P_ADV_INTRD_AC_BAL       NUMBER;
      P_ADV_CHARGE_AC_BAL      NUMBER;
      P_ADV_PRIN_BC_BAL        NUMBER;
      P_ADV_INTRD_BC_BAL       NUMBER;
      P_ADV_CHARGE_BC_BAL      NUMBER;
      V_ORG_AC_AMT             NUMBER (18, 3) := 0.00;
      V_ACT_INT_RATE           NUMBER (7, 5) := 0.00;
      v_LEAN_AMOUNT            NUMBER (18, 3) := 0.00;
      v_ACNT_AVGBAL            NUMBER (18, 3) := 0.00;
      V_DUMMY                  NUMBER (18, 3) := 0.00;
      V_INT_SPECIFIED_CHOICE   VARCHAR2 (10);

      TYPE REC_DEPIRHDT IS RECORD
      (
         DEPIRHDT_EFF_FROM_DATE   DATE,
         DEPIRHDT_EFF_UPTO_DATE   DATE,
         DEPIRHDT_INT_RATE        NUMBER (18, 3)
      );

      TYPE TT_REC_DEPIRHDT IS TABLE OF REC_DEPIRHDT
         INDEX BY PLS_INTEGER;

      T_REC_DEPIRHDT           TT_REC_DEPIRHDT;
      V_SQL_STAT               VARCHAR2 (4000);
   BEGIN
      /* maturity value is immaterial for Islamic Banking
        IF p_mat_date <= p_curr_accrual_date THEN
          l_tot_int := p_mat_value - p_prin_amt;
        ELSE


            BEGIN
                SELECT FLOOR(MONTHS_BETWEEN(p_end_date, p_start_date)),
                    p_end_date - (ADD_MONTHS(p_start_date, FLOOR(MONTHS_BETWEEN(p_end_date, p_start_date)))) INTO l_num_of_mons, l_num_of_days
                FROM dual;
            EXCEPTION
            WHEN OTHERS THEN
              PV_ERR_MSG  := substr(SQLERRM, 1, 500) || ' Error while getting Number of Months and Days in REINV_INT_ACCRUAL_CALC proc';
              PKG_EODSOD_FLAGS.PV_ERROR_MSG := PV_ERR_MSG;
              PKG_PB_GLOBAL.DETAIL_ERRLOG(V_GLOB_ENTITY_NUM, 'E',PV_ERR_MSG);
              RETURN FALSE;
            END;
            l_num_of_quaters  := FLOOR(l_num_of_mons / p_freq);
            l_num_of_rem_mons := l_num_of_mons - (l_num_of_quaters * p_freq);
            l_calc_value      := p_prin_amt;
            FOR i IN 1 .. l_num_of_quaters LOOP
                l_int        := (l_calc_value * p_int_rate * p_freq) / 1200;
                l_calc_value := l_calc_value + l_int;
            END LOOP;
            l_brk_int    := (l_calc_value * p_int_rate * l_num_of_rem_mons) / 1200 +
                          (l_calc_value * p_int_rate * l_num_of_days) / p_denom;
            l_calc_value := l_calc_value + l_brk_int;
            l_tot_int    := l_calc_value - p_prin_amt;
        END IF;
           */

      SELECT DEPPR_INT_SPECIFIED_CHOICE
        INTO V_INT_SPECIFIED_CHOICE
        FROM PBDCONTRACT P, DEPPROD D
       WHERE     P.PBDCONT_ENTITY_NUM = V_GLOB_ENTITY_NUM
             AND P.PBDCONT_DEP_AC_NUM = p_dep_acnum
             AND P.PBDCONT_CONT_NUM = p_contract_ref
             AND P.PBDCONT_BRN_CODE = p_branch
             AND P.PBDCONT_PROD_CODE = D.DEPPR_PROD_CODE;

      IF V_INT_SPECIFIED_CHOICE = '2'
      THEN
         V_ACT_INT_RATE := p_int_rate;
         l_num_of_days := p_end_date - p_start_date + 1;

         v_LEAN_AMOUNT :=
            FN_GET_LEAN_AVG_BAL (V_GLOB_ENTITY_NUM,
                                 p_dep_acnum,
                                 p_end_date,
                                 p_start_date);

         v_ACNT_AVGBAL :=
            FN_GET_AVG_BAL_ISLAMIC (V_GLOB_ENTITY_NUM,
                                    p_dep_acnum,
                                    p_end_date,
                                    p_start_date);

         IF v_LEAN_AMOUNT < 0
         THEN
            V_ORG_AC_AMT := v_ACNT_AVGBAL + v_LEAN_AMOUNT;
         ELSE
            V_ORG_AC_AMT := v_ACNT_AVGBAL;
         END IF;

         l_tot_int :=
            (V_ORG_AC_AMT * V_ACT_INT_RATE * l_num_of_days) / p_denom;
      ELSE
         V_SQL_STAT :=
            'SELECT DEPIRHDT_EFF_FROM_DATE, DEPIRHDT_EFF_UPTO_DATE, DEPIRHDT_INT_RATE
                             FROM TABLE (PKG_GET_DEPINTRATE.FN_GET_DEPINTRATE(:1,:2,:3, :4)) ORDER BY DEPIRHDT_EFF_FROM_DATE';

         EXECUTE IMMEDIATE V_SQL_STAT
            BULK COLLECT INTO T_REC_DEPIRHDT
            USING V_GLOB_ENTITY_NUM,
                  p_dep_acnum,
                  p_start_date,
                  p_end_date;

         FOR IDX IN 1 .. T_REC_DEPIRHDT.COUNT
         LOOP
            V_ACT_INT_RATE := T_REC_DEPIRHDT (IDX).DEPIRHDT_INT_RATE;

            l_num_of_days :=
                 T_REC_DEPIRHDT (IDX).DEPIRHDT_EFF_UPTO_DATE
               - T_REC_DEPIRHDT (IDX).DEPIRHDT_EFF_FROM_DATE
               + 1;

            v_LEAN_AMOUNT :=
               FN_GET_LEAN_AVG_BAL (
                  V_GLOB_ENTITY_NUM,
                  p_dep_acnum,
                  T_REC_DEPIRHDT (IDX).DEPIRHDT_EFF_FROM_DATE,
                  T_REC_DEPIRHDT (IDX).DEPIRHDT_EFF_UPTO_DATE);

            v_ACNT_AVGBAL :=
               FN_GET_AVG_BAL_ISLAMIC (
                  V_GLOB_ENTITY_NUM,
                  p_dep_acnum,
                  T_REC_DEPIRHDT (IDX).DEPIRHDT_EFF_FROM_DATE,
                  T_REC_DEPIRHDT (IDX).DEPIRHDT_EFF_UPTO_DATE);

            IF v_LEAN_AMOUNT < 0
            THEN
               V_ORG_AC_AMT := v_ACNT_AVGBAL + v_LEAN_AMOUNT;
            ELSE
               V_ORG_AC_AMT := v_ACNT_AVGBAL;
            END IF;

            l_tot_int :=
                 l_tot_int
               + (V_ORG_AC_AMT * V_ACT_INT_RATE * l_num_of_days) / p_denom;
         END LOOP;
      END IF;

      IF NOT get_TDS_int (p_branch,
                          p_dep_acnum,
                          p_contract_ref,
                          p_curr_accrual_date,
                          p_mat_date,
                          p_int_rate,
                          p_denom,
                          l_tot_tds,
                          l_tds_int)
      THEN
         RETURN FALSE;
      END IF;

     <<CALCULATE_ACCR_AMT>>
      BEGIN
         SELECT SUM (
                   DECODE (DEPIA.DEPIA_ENTRY_TYPE,
                           'IA', DEPIA.DEPIA_AC_INT_ACCR_AMT))
           INTO l_accr_amt
           FROM DEPIA
          WHERE     DEPIA_ENTITY_NUM = V_GLOB_ENTITY_NUM
                AND DEPIA.DEPIA_BRN_CODE = p_branch
                AND DEPIA.DEPIA_INTERNAL_ACNUM = p_dep_acnum
                AND DEPIA.DEPIA_CONTRACT_NUM = p_contract_ref
                AND DEPIA.DEPIA_ACCR_FROM_DATE >= p_start_date
                AND DEPIA.DEPIA_ACCR_UPTO_DATE <= p_curr_accrual_date;
      END CALCULATE_ACCR_AMT;

      SP_AVLBAL (V_GLOB_ENTITY_NUM,
                 p_DEP_acnum,
                 AC_CURR_CODE,
                 l_dep_ac_bal,
                 AC_UNAUTH_DBS,
                 AC_UNAUTH_CRS,
                 AC_FWDVAL_DBS,
                 AC_FWDVAL_CRS,
                 AC_TOT_BAL,
                 AC_LIEN_AMT,
                 HOLD_AMT,
                 MIN_BAL,
                 AC_AVLBAL,
                 AC_EFFBAL,
                 UNUSED_LIMIT,
                 BC_AUTH_BAL,
                 BC_UNAUTH_DBS,
                 BC_UNAUTH_CRS,
                 BC_FWDVAL_DBS,
                 BC_FWDVAL_CRS,
                 BC_TOT_BAL,
                 BC_LIEN_AMT,
                 AC_CLGVAL_DBS,
                 AC_CLGVAL_CRS,
                 AC_CLOSURE_DT,
                 AC_ACNT_FREEZED,
                 AC_ACNT_AUTH_ON,
                 AC_ACNT_DORMANT_ACNT,
                 AC_ACNT_INOP_ACNT,
                 AC_ACNT_DB_FREEZED,
                 AC_ACNT_CR_FREEZED,
                 P_TOT_LMT_AMT,
                 P_EFF_BAL_WOT_LMT,
                 P_ERR_MSG,
                 '0',
                 p_contract_ref,
                 P_ADV_PRIN_AC_BAL,
                 P_ADV_INTRD_AC_BAL,
                 P_ADV_CHARGE_AC_BAL,
                 V_DUMMY,
                 V_DUMMY,
                 V_DUMMY,
                 V_DUMMY,
                 P_ADV_PRIN_BC_BAL,
                 P_ADV_INTRD_BC_BAL,
                 P_ADV_CHARGE_BC_BAL,
                 V_DUMMY,
                 V_DUMMY,
                 V_DUMMY,
                 V_DUMMY,
                 '0',
                 0);
      p_int_Accr := l_tot_int - NVL (l_accr_amt, 0);

      IF p_int_Accr > 0
      THEN
         PV_IDX2 := PV_IDX2 + 1;
         pv_tblIntAccr (PV_IDX2).BRN_CODE := p_branch;
         pv_tblIntAccr (PV_IDX2).DEP_AC_NUM := p_dep_acnum;
         pv_tblIntAccr (PV_IDX2).CONT_NUM := p_contract_ref;
         pv_tblIntAccr (PV_IDX2).ACCR_SL := 1;
         pv_tblIntAccr (PV_IDX2).CALC_FROM_DATE := p_start_date;
         pv_tblIntAccr (PV_IDX2).CALC_UPTO_DATE := p_end_date;
         pv_tblintaccr (PV_IDX2).PREV_ACCR_UPTO := p_prev_accr_date;
         pv_tblIntAccr (PV_IDX2).DEPCAC_INT_ON_AMOUNT := V_ORG_AC_AMT;
         pv_tblIntAccr (PV_IDX2).INT_ACCR_AMT := p_int_Accr;
         pv_tblIntAccr (PV_IDX2).INT_PRD_END_FLAG := '0';
         pv_tblIntAccr (PV_IDX2).CALC_PERIOD_NOD :=
            p_end_date - p_prev_accr_date;
      END IF;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         PV_ERR_MSG :=
               ' Error In REINV_INT_ACCRUAL_CALC FUNCTION For- '
            || p_branch
            || '/'
            || facno (V_GLOB_ENTITY_NUM, p_DEP_acnum)
            || '/'
            || p_contract_ref;
         PV_ERR_MSG := PV_ERR_MSG || SUBSTR (SQLERRM, 1, 500);
         PKG_EODSOD_FLAGS.PV_ERROR_MSG := PV_ERR_MSG;
         PKG_PB_GLOBAL.DETAIL_ERRLOG (V_GLOB_ENTITY_NUM,
                                      'E',
                                      PV_ERR_MSG,
                                      ' ',
                                      facno (V_GLOB_ENTITY_NUM, p_DEP_acnum));
         RETURN FALSE;
   END;

   FUNCTION get_TDS_int (p_branch              IN     NUMBER,
                         p_dep_acnum           IN     NUMBER,
                         p_contract_ref        IN     NUMBER,
                         p_curr_accrual_date   IN     DATE,
                         p_mat_date            IN     DATE,
                         p_int_rate            IN     NUMBER,
                         p_denom               IN     NUMBER,
                         p_tot_tds                OUT NUMBER,
                         p_tds_int                OUT NUMBER)
      RETURN BOOLEAN
   IS
      l_t_num_of_days       NUMBER (5);
      l_t_num_of_mons       NUMBER (5);
      l_t_num_of_quaters    NUMBER (5);
      l_t_num_of_rem_mons   NUMBER (5);
      l_tds                 NUMBER (18, 3);
      l_t_calc_value        NUMBER (18, 3);
      l_t_brok_int          NUMBER (18, 3);
      l_each_int            NUMBER (18, 3);
      L_TAX_DEPIA           NUMBER (18, 3);
      finyr                 NUMBER (6);
      cbd                   DATE;
      l_int                 NUMBER (18, 3);
      l_t_start_date        PBDCONTRACT.PBDCONT_INT_ACCR_UPTO%TYPE;
      l_t_end_date          PBDCONTRACT.PBDCONT_INT_ACCR_UPTO%TYPE;
   BEGIN
      p_tot_tds := 0;
      L_TAX_DEPIA := 0;
      p_tds_int := 0;
      cbd := FN_GET_CURRENT_BUSINESS_DATE;
      finyr := SP_GETFINYEAR (V_GLOB_ENTITY_NUM, cbd);

      FOR TDSPIDT
         IN (SELECT TDSPIDT_DATE_OF_REC,
                    TDSPIDT_TDS_AMT,
                    TDSPIDT_SURCHARGE_AMT,
                    TDSPIDT_OTH_CHGS
               FROM TDSPIDTL
              WHERE     TDSPIDT_ENTITY_NUM = V_GLOB_ENTITY_NUM
                    AND TDSPIDT_BRN_CODE = p_branch
                    AND TDSPIDT_AC_NUM = p_dep_acnum
                    AND TDSPIDT_CONT_NUM = p_contract_ref)
      LOOP
         l_tds :=
              TDSPIDT.TDSPIDT_TDS_AMT
            + TDSPIDT.TDSPIDT_SURCHARGE_AMT
            + TDSPIDT.TDSPIDT_OTH_CHGS;
         l_t_start_date := TDSPIDT.TDSPIDT_DATE_OF_REC;
         l_t_end_date := p_curr_accrual_date;

         IF p_mat_date <= p_curr_accrual_date
         THEN
            l_t_end_date := p_mat_date - 1;
         END IF;

         p_tot_tds := p_tot_tds + l_tds;

         IF tdspidt.tdspidt_date_of_rec < l_t_end_date
         THEN
            BEGIN
               SELECT FLOOR (MONTHS_BETWEEN (l_t_end_date, l_t_start_date)),
                        l_t_end_date
                      - ADD_MONTHS (
                           l_t_start_date,
                           FLOOR (
                              MONTHS_BETWEEN (l_t_end_date, l_t_start_date)))
                 INTO l_t_num_of_mons, l_t_num_of_days
                 FROM DUAL;
            EXCEPTION
               WHEN OTHERS
               THEN
                  PV_ERR_MSG :=
                        ' Error in  get_TDS_int .While checking the no. of months and days For'
                     || p_branch
                     || '/'
                     || facno (V_GLOB_ENTITY_NUM, p_DEP_acnum)
                     || '/'
                     || p_contract_ref;
                  PV_ERR_MSG := PV_ERR_MSG || SUBSTR (SQLERRM, 1, 500);
                  PKG_EODSOD_FLAGS.PV_ERROR_MSG := PV_ERR_MSG;
                  PKG_PB_GLOBAL.DETAIL_ERRLOG (V_GLOB_ENTITY_NUM,
                                               'E',
                                               PV_ERR_MSG);

                  RETURN FALSE;
            END;

            l_t_num_of_quaters := FLOOR (l_t_num_of_mons / 3);
            l_t_num_of_rem_mons := l_t_num_of_mons - (l_t_num_of_quaters * 3);
            l_t_calc_value := l_tds;

            FOR i IN 1 .. l_t_num_of_quaters
            LOOP
               l_int := (l_t_calc_value * p_int_rate * 3) / 1200;
               l_t_calc_value := l_t_calc_value + l_int;
            END LOOP;

            l_t_brok_int :=
                 (l_t_calc_value * l_t_num_of_rem_mons * p_int_rate) / 1200
               + (l_t_calc_value * l_t_num_of_days * p_int_rate) / p_denom;
            l_t_calc_value := l_t_calc_value + l_t_brok_int;
            l_each_int := l_t_calc_value - l_tds;

            p_tds_int := p_tds_int + l_each_int;
         END IF;
      END LOOP;

      p_tds_int := CEIL (p_tds_int);

     <<TAX_ALREADY_DED>>
      BEGIN
         SELECT NVL (SUM (DEPIA_AC_INT_ACCR_AMT), 0)
           INTO L_TAX_DEPIA
           FROM DEPIA
          WHERE     DEPIA_ENTITY_NUM = V_GLOB_ENTITY_NUM
                AND DEPIA_BRN_CODE = p_branch
                AND DEPIA_INTERNAL_ACNUM = p_dep_acnum
                AND DEPIA_CONTRACT_NUM = p_contract_ref
                AND DEPIA_INT_ACCR_DB_CR = 'D'
                AND DEPIA_ENTRY_TYPE = 'TD';
      EXCEPTION
         WHEN OTHERS
         THEN
            p_tds_int := 0;
            p_tot_tds := 0;
      END TAX_ALREADY_DED;

      IF L_TAX_DEPIA > 0
      THEN
         p_tot_tds := L_TAX_DEPIA;
         p_tds_int := 0;
      ELSE
         p_tot_tds := 0;
         p_tds_int := 0;
      END IF;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         PV_ERR_MSG :=
               ' Error in GET_TDS_INTREST FUNCTION -For'
            || p_branch
            || '/'
            || facno (V_GLOB_ENTITY_NUM, p_DEP_acnum)
            || '/'
            || p_contract_ref;
         PV_ERR_MSG := PV_ERR_MSG || SUBSTR (SQLERRM, 1, 500);
         PKG_EODSOD_FLAGS.PV_ERROR_MSG := PV_ERR_MSG;
         PKG_PB_GLOBAL.DETAIL_ERRLOG (V_GLOB_ENTITY_NUM,
                                      'E',
                                      PV_ERR_MSG,
                                      ' ',
                                      facno (V_GLOB_ENTITY_NUM, p_DEP_acnum));
         RETURN FALSE;
   END;

   FUNCTION add_to_int_coll (
      p_contract_rec    depCont,
      p_intrate         pbdcontract.pbdcont_actual_int_rate%TYPE,
      p_denom           NUMBER)
      RETURN BOOLEAN
   IS
      v_nod                 NUMBER (5);
      v_already_accrd_amt   NUMBER (18, 3);
      v_broken_months       NUMBER DEFAULT 0;   --Sriram B - chn - 11-jun-2010
   BEGIN
      FOR i IN 1 .. PV_IDX1
      LOOP
         v_nod :=
            (pv_tblIntPrd (i).UPTO_date - pv_tblIntPrd (i).From_date) + 1;
         pv_tblIntPrd (i).NOD := v_nod;

         IF pv_tblIntPrd (i).full_period_flag = '1'
         THEN
            pv_tblIntPrd (i).Period_int_amt :=
               p_contract_rec.pbdcont_periodical_int_amt;
         ELSE
            --Sriram B - chn - 11-jun-2010 - beg - changed to handle if 13 months - for remaining month interest calculation should be for months not days
            --pv_tblIntPrd(i).Period_int_amt := p_contract_rec.pbdcont_ac_dep_amt * p_intrate * v_nod /
            --                                   p_denom;
            IF     p_contract_rec.pbdcont_dep_prd_days = 0
               AND (pv_tblIntPrd (i).UPTO_date + 1) =
                      p_contract_rec.PBDCONT_MAT_DATE
            THEN
               v_broken_months :=
                  MONTHS_BETWEEN ( (pv_tblIntPrd (i).UPTO_date + 1),
                                  (pv_tblIntPrd (i).From_date));
               pv_tblIntPrd (i).Period_int_amt :=
                    p_contract_rec.pbdcont_ac_dep_amt
                  * p_intrate
                  * v_broken_months
                  / 1200;
            ELSE
               pv_tblIntPrd (i).Period_int_amt :=
                    p_contract_rec.pbdcont_ac_dep_amt
                  * p_intrate
                  * v_nod
                  / p_denom;
            END IF;
         --Sriram B - chn - 11-jun-2010 - beg - changed to handle if 13 months - for remaining month interest calculation should be for months not days
         END IF;

         IF     pv_tblIntPrd (i).UPTO_date >= PV_CALC_FROM_DATE
            AND pv_tblIntPrd (i).UPTO_date <= PV_CALC_UPTO_DATE
         THEN
            BEGIN
               SELECT NVL (SUM (DEPIA_AC_INT_ACCR_AMT), 0)
                 INTO v_already_accrd_amt
                 FROM depia
                WHERE     DEPIA_ENTITY_NUM = V_GLOB_ENTITY_NUM
                      AND DEPIA_INTERNAL_ACNUM =
                             p_contract_rec.PBDCONT_DEP_AC_NUM
                      AND DEPIA_CONTRACT_NUM =
                             p_contract_rec.PBDCONT_CONT_NUM
                      AND DEPIA_ACCR_FROM_DATE >= pv_tblIntPrd (i).from_date
                      AND DEPIA_ACCR_UPTO_DATE <= pv_tblIntPrd (i).upto_date
                      AND depia_entry_type = 'IA';
            EXCEPTION
               WHEN OTHERS
               THEN
                  pv_err_msg :=
                        'Error while selecting already accrd amt. Error message:'
                     || SUBSTR (SQLERRM, 1, 900);
                  PKG_EODSOD_FLAGS.PV_ERROR_MSG := pv_err_msg;
                  PKG_PB_GLOBAL.DETAIL_ERRLOG (V_GLOB_ENTITY_NUM,
                                               'E',
                                               pv_err_msg);
                  RETURN FALSE; --error in selecting already accrued amt                            '
            END;

            pv_tblIntPrd (i).Already_accr_amt := v_already_accrd_amt;
            pv_tblIntPrd (i).Period_end_flag := '1';
         ELSE
            pv_tblIntPrd (i).Already_accr_amt := 0;
            pv_tblIntPrd (i).Period_end_flag := '0';
         END IF;
      END LOOP;

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         PKG_EODSOD_FLAGS.PV_ERROR_MSG :=
               'Error in add to int coll function. Error message:'
            || SUBSTR (SQLERRM, 1, 900);
         PKG_PB_GLOBAL.DETAIL_ERRLOG (V_GLOB_ENTITY_NUM,
                                      'E',
                                      PKG_EODSOD_FLAGS.PV_ERROR_MSG);
         RETURN FALSE;
   END;

   FUNCTION UPDATE_CALC_AND_CALCBRK_TBLS
      RETURN BOOLEAN
   IS
      CSIZE              NUMBER (10);
      PREV_ACNUM         PBDCONTRACT.PBDCONT_DEP_AC_NUM%TYPE := 0;
      PREV_CONT          PBDCONTRACT.PBDCONT_CONT_NUM%TYPE;
      PREV_ACCRUED_AMT   NUMBER (18, 3);
      V_IDX              NUMBER (10);
   BEGIN
      --iterate collection in-order to merge collection of same account
      CSIZE := pv_tblIntAccr.COUNT;

      FOR IDX IN 1 .. pv_tblIntAccr.COUNT
      LOOP
         IF     PREV_ACNUM <> 0
            AND TRIM (pv_tblIntAccr (IDX).DEP_AC_NUM) = PREV_ACNUM
            AND TRIM (pv_tblIntAccr (IDX).CONT_NUM) = PREV_CONT
         THEN
            PREV_ACCRUED_AMT :=
               PREV_ACCRUED_AMT + pv_tblIntAccr (IDX).INT_ACCR_AMT;
            pv_tblIntAccr (IDX).INT_ACCR_AMT := PREV_ACCRUED_AMT;
            pv_tblIntAccr.DELETE (IDX - 1);
            PREV_ACCRUED_AMT := 0;
         END IF;

         PREV_ACNUM := pv_tblIntAccr (IDX).DEP_AC_NUM;
         PREV_CONT := pv_tblIntAccr (IDX).CONT_NUM;
         PREV_ACCRUED_AMT := pv_tblIntAccr (IDX).INT_ACCR_AMT;
      END LOOP;

      CSIZE := pv_tblIntAccr.COUNT;

      V_IDX := pv_tblIntAccr.FIRST;

      WHILE V_IDX IS NOT NULL
      LOOP
         V_IDX := pv_tblIntAccr.NEXT (V_IDX);
      END LOOP;

      --FORALL IDX IN pv_tblIntAccr.FIRST .. pv_tblIntAccr.LAST
      FORALL IDX IN INDICES OF pv_tblIntAccr
         INSERT INTO DEPCALCAC (DEPCAC_ENTITY_NUM,
                                DEPCAC_BRN_CODE,
                                DEPCAC_RUN_NUM,
                                DEPCAC_INTERNAL_AC_NUM,
                                DEPCAC_CONTRACT_NUM,
                                DEPCAC_PREV_ACCR_UPTO_DATE,
                                DEPCAC_INT_ACCR_UPTO_DATE,
                                DEPCAC_AC_INT_ACCR_AMT,
                                DEPCAC_BC_INT_ACCR_AMT,
                                DEPCAC_CRATE_TO_BASE_CURR)
              VALUES (V_GLOB_ENTITY_NUM,
                      pv_tblIntAccr (IDX).BRN_CODE,
                      PV_RUN_NUMBER,
                      pv_tblIntAccr (IDX).DEP_AC_NUM,
                      pv_tblIntAccr (IDX).CONT_NUM,
                      pv_tblIntAccr (IDX).PREV_ACCR_UPTO,
                      pv_tblIntAccr (IDX).CALC_UPTO_DATE,
                      pv_tblIntAccr (IDX).INT_ACCR_AMT,
                      0,
                      0);

      FORALL IDX IN INDICES OF pv_tblIntAccr
         INSERT INTO DEPCALCBRK (DEPCBRK_ENTITY_NUM,
                                 DEPCBRK_BRN_CODE,
                                 DEPCBRK_RUN_NUM,
                                 DEPCBRK_INTERNAL_ACNUM,
                                 DEPCBRK_CONTRACT_NUM,
                                 DEPCBRK_BRK_SL,
                                 DEPCBRK_INT_ACCR_FROM_DATE,
                                 DEPCBRK_INT_ACCR_UPTO_DATE,
                                 DEPCBRK_INT_ACCR_AMT,
                                 DEPCBRK_INT_PERD_END_FLAG,
                                 DEPCBRK_CALC_PERIOD_NOD,
                                 DEPCBRK_INT_ON_AMOUNT)
              VALUES (V_GLOB_ENTITY_NUM,
                      pv_tblIntAccr (IDX).BRN_CODE,
                      PV_RUN_NUMBER,
                      pv_tblIntAccr (IDX).DEP_AC_NUM,
                      pv_tblIntAccr (IDX).CONT_NUM,
                      pv_tblIntAccr (IDX).ACCR_SL,
                      pv_tblIntAccr (IDX).CALC_FROM_DATE,
                      pv_tblIntAccr (IDX).CALC_UPTO_DATE,
                      pv_tblIntAccr (IDX).INT_ACCR_AMT,
                      pv_tblIntAccr (IDX).INT_PRD_END_FLAG,
                      pv_tblIntAccr (IDX).CALC_PERIOD_NOD,
                      pv_tblIntAccr (IDX).DEPCAC_INT_ON_AMOUNT);

      RETURN TRUE;
   END;

   PROCEDURE DELETE_TEMP_TABLE (W_DEL_RUN_NO IN NUMBER)
   IS
   BEGIN
      DELETE FROM DEPCALCCTL
            WHERE     DEPCTL_ENTITY_NUM = V_GLOB_ENTITY_NUM
                  AND DEPCTL_RUN_NUM = W_DEL_RUN_NO;

      DELETE FROM DEPCALCAC
            WHERE     DEPCAC_ENTITY_NUM = V_GLOB_ENTITY_NUM
                  AND DEPCAC_RUN_NUM = W_DEL_RUN_NO;

      DELETE FROM DEPCALCBRK
            WHERE     DEPCBRK_ENTITY_NUM = V_GLOB_ENTITY_NUM
                  AND DEPCBRK_RUN_NUM = W_DEL_RUN_NO;
   END DELETE_TEMP_TABLE;

   FUNCTION GET_RUNNO
      RETURN NUMBER
   IS
      W_RUN_NO   NUMBER (8);
   BEGIN
     <<READNUM>>
      BEGIN
         SELECT GENRUNNUM.NEXTVAL INTO W_RUN_NO FROM DUAL;
      END READNUM;

      DELETE_TEMP_TABLE (W_RUN_NO);
      RETURN W_RUN_NO;
   END GET_RUNNO;

   PROCEDURE START_ACCR_BRNWISE (P_ENTITY_NUM   IN NUMBER,
                                 P_BRN_CODE     IN NUMBER DEFAULT 0)
   IS
      L_BRN_CODE   MBRN.MBRN_CODE%TYPE;
   BEGIN
      PKG_ENTITY.SP_SET_ENTITY_CODE (P_ENTITY_NUM);
      PKG_PROCESS_CHECK.INIT_PROC_BRN_WISE (P_ENTITY_NUM, P_BRN_CODE);

      FOR IDX IN 1 .. PKG_PROCESS_CHECK.V_ACNTBRN.COUNT
      LOOP
         L_BRN_CODE := PKG_PROCESS_CHECK.V_ACNTBRN (IDX).LN_BRN_CODE;

         IF PKG_PROCESS_CHECK.CHK_BRN_ALREADY_PROCESSED (P_ENTITY_NUM,
                                                         L_BRN_CODE) = FALSE
         THEN
            START_DEP_ACCRUAL (P_ENTITY_NUM, L_BRN_CODE);

            IF TRIM (PKG_EODSOD_FLAGS.PV_ERROR_MSG) IS NULL
            THEN
               PKG_PROCESS_CHECK.INSERT_ROW_INTO_EODSODPROCBRN (P_ENTITY_NUM,
                                                                l_BRN_CODE);
            END IF;

            PKG_PROCESS_CHECK.CHECK_COMMIT_ROLLBACK_STATUS (
               V_GLOB_ENTITY_NUM);
         END IF;
      END LOOP;
   END START_ACCR_BRNWISE;
END PKG_DEP_INT_ACCRUAL;
/