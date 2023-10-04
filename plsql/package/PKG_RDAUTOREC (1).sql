CREATE OR REPLACE PACKAGE PKG_RDAUTOREC
IS
   PROCEDURE START_RDAUTOREC (
      V_ENTITY_NUM   IN ENTITYNUM.ENTITYNUM_NUMBER%TYPE,
      P_BRN_CODE     IN MBRN.MBRN_CODE%TYPE DEFAULT 0,
      P_DEP_AC_NUM   IN PBDCONTRACT.PBDCONT_DEP_AC_NUM%TYPE DEFAULT 0,
      P_REC_DATE     IN MAINCONT.MN_CURR_BUSINESS_DATE%TYPE DEFAULT NULL);

   PROCEDURE START_RDAUTOREC_BRNWISE (
      V_ENTITY_NUM   IN ENTITYNUM.ENTITYNUM_NUMBER%TYPE,
      P_BRN_CODE     IN MBRN.MBRN_CODE%TYPE DEFAULT 0,
      P_DEP_AC_NUM   IN PBDCONTRACT.PBDCONT_DEP_AC_NUM%TYPE DEFAULT 0);
END;
/

CREATE OR REPLACE PACKAGE BODY PKG_RDAUTOREC
IS
   PKG_ERR_MSG              VARCHAR2 (2300);
   E_USEREXCEP              EXCEPTION;

   TYPE ACNT_DETAILS_T IS RECORD
   (
      ENTITY_NUM                 ENTITYNUM.ENTITYNUM_NUMBER%TYPE,
      BRN_CODE                   MBRN.MBRN_CODE%TYPE,
      PROD_CODE                  PRODUCTS.PRODUCT_CODE%TYPE,
      INT_ACNT_NUM               IACLINK.IACLINK_INTERNAL_ACNUM%TYPE,
      AC_TYPE                    ACNTS.ACNTS_AC_TYPE%TYPE,
      AC_SUB_TYPE                ACNTS.ACNTS_AC_SUB_TYPE%TYPE,
      CONT_NUM                   PBDCONTRACT.PBDCONT_CONT_NUM%TYPE,
      AC_NAME                    ACNTS.ACNTS_AC_NAME1%TYPE,
      RD_ACNT_CR_FRZ             ACNTS.ACNTS_CR_FREEZED%TYPE,
      DEP_CURR                   PBDCONTRACT.PBDCONT_DEP_CURR%TYPE,
      INST_AMT                   PBDCONTRACT.PBDCONT_AC_DEP_AMT%TYPE,
      FREQ_OF_DEP                PKG_COMMON_TYPES.NUMBER_T,
      EFF_DATE                   PBDCONTRACT.PBDCONT_EFF_DATE%TYPE,
      TOT_NO_OF_INST             PBDCONTRACT.PBDCONT_NO_OF_INST%TYPE,
      MAT_DATE                   PBDCONTRACT.PBDCONT_MAT_DATE%TYPE,
      MAT_VALUE                  PBDCONTRACT.PBDCONT_MAT_VALUE%TYPE,
      INST_PAY_OPTION            PBDCONTRACT.PBDCONT_INST_PAY_OPTION%TYPE,
      PROD_CUTOFF_DAY            DEPPROD.DEPPR_INST_CUTOFF_DAY%TYPE,
      AUTO_RECV_REQD             PBDCONTRACT.PBDCONT_AUTO_INST_REC_REQD%TYPE,
      AUTO_RECV_DAY              PBDCONTRACT.PBDCONT_INST_REC_DAY%TYPE,
      AUTO_RECV_ACNT             PBDCONTRACT.PBDCONT_INST_REC_FROM_AC%TYPE,
      REC_ACNT_CLIENT_NO         ACNTS.ACNTS_CLIENT_NUM%TYPE,
      REC_ACNT_DR_FRZ            ACNTS.ACNTS_DB_FREEZED%TYPE,
      REC_ACNT_CURR_CODE         ACNTS.ACNTS_CURR_CODE%TYPE,
      REC_ACNT_CLOSE_DATE        ACNTS.ACNTS_CLOSURE_DATE%TYPE,
      PENAL_BASED_ON_PENAL_DEF   DEPPROD.DEPPR_PENALTY_BSD_ON_PEN_DEF%TYPE,
      PENAL_CHGCD                DEPPROD.DEPPR_RD_PENAL_CHGCD%TYPE,
      AUTO_REC_CHGCD             DEPPROD.DEPPR_RDREC_CHGCD%TYPE,
      AUTO_REC_CHGCD_TYPE        CHGCD.CHGCD_CHG_TYPE%TYPE,
      AUTO_REC_CHGCD_INCOME_GL   CHGCD.CHGCD_CR_INCOME_HEAD%TYPE,
      AUTO_REC_CHGCD_VAT_CODE    CHGCD.CHGCD_SERVICE_TAX_CODE%TYPE,
      AUTO_REC_CHGCD_VAT_GL      STAXACPM.STAXACPM_STAX_RCVD_HEAD%TYPE,
      NO_OF_MONTHS_ELAPSED       PKG_COMMON_TYPES.NUMBER_T,
      TOT_INST_PAID_UPTO         PKG_COMMON_TYPES.NUMBER_T,
      TOT_AMT_PAID_UPTO          PKG_COMMON_TYPES.AMOUNT_T,
      TOT_INST_AMT_PAID_UPTO     PKG_COMMON_TYPES.AMOUNT_T,
      TOT_PENAL_AMT_PAID_UPTO    PKG_COMMON_TYPES.AMOUNT_T,
      TOT_INT_AMT_PAID_UPTO      PKG_COMMON_TYPES.AMOUNT_T,
      ACNT_BAL                   ACNTBAL.ACNTBAL_BC_BAL%TYPE,
      NO_OF_INST_DUE             PKG_COMMON_TYPES.NUMBER_T,
      NO_OF_INST_OVERDUE         PKG_COMMON_TYPES.NUMBER_T
   );

   TYPE ACNT_DETAILS_TT IS TABLE OF ACNT_DETAILS_T
      INDEX BY PLS_INTEGER;


   TYPE RDINS_TABLE IS TABLE OF RDINS%ROWTYPE
      INDEX BY PLS_INTEGER;

   W_RDINS_REC              RDINS_TABLE;

   TYPE REC_ACNT_BOOKED_BAL_TT IS TABLE OF ACNTBAL.ACNTBAL_AC_BAL%TYPE
      INDEX BY VARCHAR2 (14);

   REC_ACNT_BOOKED_BAL      REC_ACNT_BOOKED_BAL_TT;


   TYPE REC_PENAL_ACNT_TT IS TABLE OF PBDCONTRACT.PBDCONT_DEP_AC_NUM%TYPE
      INDEX BY PLS_INTEGER;

   REC_PENAL_ACNT           REC_PENAL_ACNT_TT;

   W_INDEX_NUMBER           NUMBER DEFAULT 0;

   --T_REC_PENAL_ACNT REC_PENAL_ACNT ;

   W_REC_DATE               MAINCONT.MN_CURR_BUSINESS_DATE%TYPE;
   P_CBD                    MAINCONT.MN_CURR_BUSINESS_DATE%TYPE;
   V_ONE_INST               NUMBER := 0;
   W_COUNT                  PKG_COMMON_TYPES.NUMBER_T := 1;
   IDX                      PKG_COMMON_TYPES.NUMBER_T := 0;
   IDX_RDINS                PKG_COMMON_TYPES.NUMBER_T := 0;

   V_SHADOW_BAL_AVAILABLE   NUMBER;
   W_DUMMY_V                VARCHAR2 (10);
   W_DUMMY_N                NUMBER;
   W_DUMMY_D                DATE;
   W_REC_AC_AUTH_BAL        NUMBER (18, 3);

   W_DSA_COUNT              NUMBER := 0;
   W_LOCK_ENTITY            NUMBER := 0;

   FUNCTION AUTOPOSTINT (P_ENTITY_NUM   IN ENTITYNUM.ENTITYNUM_NUMBER%TYPE,
                         P_BRANCH       IN MBRN.MBRN_CODE%TYPE)
      RETURN BOOLEAN;

   FUNCTION UPDATE_RDINS
      RETURN BOOLEAN;

   PROCEDURE UPDATE_PARA (P_ENTITY_NUM   IN ENTITYNUM.ENTITYNUM_NUMBER%TYPE,
                          P_BRANCH       IN MBRN.MBRN_CODE%TYPE);

   PROCEDURE CREATE_RDINS (P_ACNT_DETAILS IN ACNT_DETAILS_T)
   IS
      TYPE RDODPENALDEFDTLS IS RECORD
      (
         RDODPENALDEFDTL_RUN_PERIOD       RDODPENALDEFDTL.RDODPENALDEFDTL_RUN_PERIOD%TYPE,
         RDODPENALDEFDTL_INCLUDE_FLG      RDODPENALDEFDTL.RDODPENALDEFDTL_INCLUDE_FLG%TYPE,
         RDODPENALDEFDTL_PENAL_APPL       RDODPENALDEFDTL.RDODPENALDEFDTL_PENAL_APPL%TYPE,
         RDODPENALDEFDTL_MAX_DF_ST_CHG    RDODPENALDEFDTL.RDODPENALDEFDTL_MAX_DF_ST_CHG%TYPE,
         RDODPENALDEFDTL_PENAL_INT_RATE   RDODPENALDEFDTL.RDODPENALDEFDTL_PENAL_INT_RATE%TYPE
      );

      TYPE TABRDODPENDEFDTLS IS TABLE OF RDODPENALDEFDTLS
         INDEX BY PLS_INTEGER;

      V_TABRDODPENDEFDTLS       TABRDODPENDEFDTLS;

      -- TOTAL INST. CALCULATION VARIABLES
      V_TOT_RECV_AMT            PKG_COMMON_TYPES.AMOUNT_T := 0;
      V_TOT_INST_AMT            PKG_COMMON_TYPES.AMOUNT_T := 0;
      V_TOT_PENAL_AMT           PKG_COMMON_TYPES.AMOUNT_T := 0;

      -- OD CALCULATION VARIABLES
      V_TOT_OD_RECV_AMT         PKG_COMMON_TYPES.AMOUNT_T := 0;
      V_TMP_OD_RECV_AMT         PKG_COMMON_TYPES.AMOUNT_T := 0;
      V_TMP_TOT_PENAL_AMT       PKG_COMMON_TYPES.AMOUNT_T := 0;
      V_TOT_OD_INST_AMT         PKG_COMMON_TYPES.AMOUNT_T := 0;
      V_TMP_TOT_OD_INST_AMT     PKG_COMMON_TYPES.AMOUNT_T := 0;
      W_NO_OF_INST_OD           PKG_COMMON_TYPES.NUMBER_T;
      V_TEMP_NOOF_ODINST        PKG_COMMON_TYPES.NUMBER_T;

      -- REGULAR INST. CALCULATION VARIABLES
      V_TOT_REG_RECV_AMT        PKG_COMMON_TYPES.NUMBER_T := 0;
      V_TOT_REG_INST_RECV_AMT   PKG_COMMON_TYPES.NUMBER_T := 0;

      W_NO_OF_INST_DUE          PKG_COMMON_TYPES.NUMBER_T;
      W_REC_ACNT_BAL            ACNTBAL.ACNTBAL_AC_BAL%TYPE := 0;
      W_INST_AMT                PBDCONTRACT.PBDCONT_AC_DEP_AMT%TYPE;
      V_PENALTY_RATE            RDODPENALDEFDTL.RDODPENALDEFDTL_PENAL_INT_RATE%TYPE;
      V_PENAL_CHGCD_AMT         PKG_COMMON_TYPES.AMOUNT_T := 0;

      V_AUTO_RECV_CHG_AMT       PKG_COMMON_TYPES.AMOUNT_T := 0;
      V_RECV_CHG_AMT            PKG_COMMON_TYPES.AMOUNT_T := 0;
      V_RECV_VAT_AMT            PKG_COMMON_TYPES.AMOUNT_T := 0;

      V_DAY_SL                  RDINS.RDINS_ENTRY_DAY_SL%TYPE := 1;

      PROCEDURE GET_PENALTY_RATE (P_ACNT_DETAILS IN ACNT_DETAILS_T)
      IS
         V_PENAL_RATE   RDODPENALDEFDTL.RDODPENALDEFDTL_PENAL_INT_RATE%TYPE
                           := 0;
      BEGIN
           SELECT D.RDODPENALDEFDTL_RUN_PERIOD,
                  TRIM (D.RDODPENALDEFDTL_INCLUDE_FLG),
                  D.RDODPENALDEFDTL_PENAL_APPL,
                  D.RDODPENALDEFDTL_MAX_DF_ST_CHG,
                  D.RDODPENALDEFDTL_PENAL_INT_RATE
             BULK COLLECT INTO V_TABRDODPENDEFDTLS
             FROM RDODPENALDEFDTL D
            WHERE     D.RDODPENALDEFDTL_ENTITY_NUM = P_ACNT_DETAILS.ENTITY_NUM
                  AND D.RDODPENALDEFDTL_PROD_CODE = P_ACNT_DETAILS.PROD_CODE
                  AND TRIM (D.RDODPENALDEFDTL_AC_TYPE) =
                         TRIM (P_ACNT_DETAILS.AC_TYPE)
                  AND D.RDODPENALDEFDTL_ACSUB_TYPE =
                         NVL (P_ACNT_DETAILS.AC_SUB_TYPE, 0)
                  AND D.RDODPENALDEFDTL_CURR_CODE = P_ACNT_DETAILS.DEP_CURR
                  AND NVL (TRIM (D.RDODPENALDEFDTL_PENAL_APPL), '0') = '1'
                  AND D.RDODPENALDEFDTL_LAT_EFF_DATE =
                         (SELECT MAX (E.RDODPENALDEFDTL_LAT_EFF_DATE)
                            FROM RDODPENALDEFDTL E
                           WHERE     E.RDODPENALDEFDTL_ENTITY_NUM =
                                        P_ACNT_DETAILS.ENTITY_NUM
                                 AND E.RDODPENALDEFDTL_PROD_CODE =
                                        P_ACNT_DETAILS.PROD_CODE
                                 AND TRIM (E.RDODPENALDEFDTL_AC_TYPE) =
                                        TRIM (P_ACNT_DETAILS.AC_TYPE)
                                 AND E.RDODPENALDEFDTL_ACSUB_TYPE =
                                        NVL (P_ACNT_DETAILS.AC_SUB_TYPE, 0)
                                 AND E.RDODPENALDEFDTL_CURR_CODE =
                                        P_ACNT_DETAILS.DEP_CURR
                                 AND NVL (TRIM (E.RDODPENALDEFDTL_PENAL_APPL),
                                          '0') = '1'
                                 AND E.RDODPENALDEFDTL_LAT_EFF_DATE <=
                                        W_REC_DATE)
         ORDER BY D.RDODPENALDEFDTL_SL ASC;

         IF V_TABRDODPENDEFDTLS.COUNT > 0
         THEN
            FOR INDX IN V_TABRDODPENDEFDTLS.FIRST .. V_TABRDODPENDEFDTLS.LAST
            LOOP
               IF V_TABRDODPENDEFDTLS (INDX).RDODPENALDEFDTL_INCLUDE_FLG =
                     'I'
               THEN
                  IF P_ACNT_DETAILS.NO_OF_MONTHS_ELAPSED <=
                        V_TABRDODPENDEFDTLS (INDX).RDODPENALDEFDTL_RUN_PERIOD
                  THEN
                     V_PENAL_RATE :=
                        V_TABRDODPENDEFDTLS (INDX).RDODPENALDEFDTL_PENAL_INT_RATE;
                     EXIT;
                  END IF;
               ELSIF V_TABRDODPENDEFDTLS (INDX).RDODPENALDEFDTL_INCLUDE_FLG =
                        'E'
               THEN
                  IF P_ACNT_DETAILS.NO_OF_MONTHS_ELAPSED <
                        V_TABRDODPENDEFDTLS (INDX).RDODPENALDEFDTL_RUN_PERIOD
                  THEN
                     V_PENAL_RATE :=
                        V_TABRDODPENDEFDTLS (INDX).RDODPENALDEFDTL_PENAL_INT_RATE;
                     EXIT;
                  END IF;
               END IF;
            END LOOP;

            V_PENALTY_RATE := NVL (V_PENAL_RATE, 0);
         END IF;
      END;

      PROCEDURE GET_PENAL_CHGCD_AMT (P_ACNT_DETAILS IN ACNT_DETAILS_T)
      IS
         V_CHG_TYPE      CHGCD.CHGCD_CHG_TYPE%TYPE;
         V_CHG_CURR      CURRENCY.CURR_CODE%TYPE;
         V_SERVAMT       FLOAT;
         V_STAX_AMOUNT   FLOAT;
         V_ADD_AMOUNT    FLOAT;
         V_CESS_AMOUNT   FLOAT;
         V_ERR_MSG       PKG_COMMON_TYPES.STRING_T;
      BEGIN
         IF TRIM (P_ACNT_DETAILS.PENAL_CHGCD) IS NOT NULL
         THEN
            BEGIN
               SELECT CHGCD_CHG_TYPE
                 INTO V_CHG_TYPE
                 FROM CHGCD
                WHERE TRIM (CHGCD_CHARGE_CODE) =
                         TRIM (P_ACNT_DETAILS.PENAL_CHGCD);

               PKG_CHARGES.SP_GET_CHARGES (P_ACNT_DETAILS.ENTITY_NUM,
                                           P_ACNT_DETAILS.INT_ACNT_NUM,
                                           P_ACNT_DETAILS.DEP_CURR,
                                           P_ACNT_DETAILS.INST_AMT,
                                           TRIM (P_ACNT_DETAILS.PENAL_CHGCD),
                                           V_CHG_TYPE,
                                           V_CHG_CURR,
                                           V_PENAL_CHGCD_AMT,
                                           V_SERVAMT,
                                           V_STAX_AMOUNT,
                                           V_ADD_AMOUNT,
                                           V_CESS_AMOUNT,
                                           V_ERR_MSG);
            EXCEPTION
               WHEN OTHERS
               THEN
                  V_PENAL_CHGCD_AMT := 0;
            END;
         END IF;
      END;

      PROCEDURE GET_RECV_CHGCD_AMT (P_ACNT_DETAILS IN ACNT_DETAILS_T)
      IS
         V_CHG_CURR      CURRENCY.CURR_CODE%TYPE;
         V_SERVAMT       FLOAT;
         V_STAX_AMOUNT   FLOAT;
         V_ADD_AMOUNT    FLOAT;
         V_CESS_AMOUNT   FLOAT;
         V_ERR_MSG       PKG_COMMON_TYPES.STRING_T;
      BEGIN
         IF     TRIM (P_ACNT_DETAILS.AUTO_REC_CHGCD) IS NOT NULL
            AND TRIM (P_ACNT_DETAILS.AUTO_REC_CHGCD_INCOME_GL) IS NOT NULL
         THEN
            BEGIN
               PKG_CHARGES.SP_GET_CHARGES (
                  P_ACNT_DETAILS.ENTITY_NUM,
                  P_ACNT_DETAILS.INT_ACNT_NUM,
                  P_ACNT_DETAILS.DEP_CURR,
                  P_ACNT_DETAILS.INST_AMT,
                  TRIM (P_ACNT_DETAILS.AUTO_REC_CHGCD),
                  P_ACNT_DETAILS.AUTO_REC_CHGCD_TYPE,
                  V_CHG_CURR,
                  V_RECV_CHG_AMT,
                  V_SERVAMT,
                  V_RECV_VAT_AMT,
                  V_ADD_AMOUNT,
                  V_CESS_AMOUNT,
                  V_ERR_MSG);

               DBMS_OUTPUT.PUT_LINE ('CHARGE CALC ERROR: ' || V_ERR_MSG);

               V_RECV_CHG_AMT := ROUND (V_RECV_CHG_AMT);

               IF     TRIM (P_ACNT_DETAILS.AUTO_REC_CHGCD_VAT_CODE)
                         IS NOT NULL
                  AND (P_ACNT_DETAILS.AUTO_REC_CHGCD_VAT_GL) IS NOT NULL
               THEN
                  V_RECV_VAT_AMT := ROUND (V_RECV_VAT_AMT);
               ELSE
                  V_RECV_VAT_AMT := 0;
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  V_RECV_CHG_AMT := 0;
                  V_RECV_VAT_AMT := 0;
            END;
         END IF;
      END;



      FUNCTION GET_PENALTY_AMT (
         P_ACNT_DETAILS    IN ACNT_DETAILS_T,
         P_NO_OF_OD_INST   IN PKG_COMMON_TYPES.NUMBER_T,
         P_TOT_OD_INST     IN PKG_COMMON_TYPES.NUMBER_T)
         RETURN PKG_COMMON_TYPES.AMOUNT_T
      IS
         V_PENAL_AMT_PER_OD_INST   PKG_COMMON_TYPES.AMOUNT_T := 0;
         V_PENALTY_AMT             PKG_COMMON_TYPES.AMOUNT_T := 0;
         V_NOOF_OD_INST            PKG_COMMON_TYPES.AMOUNT_T
                                      := P_NO_OF_OD_INST;
         V_TOT_NOOF_OD_INST        PKG_COMMON_TYPES.AMOUNT_T := P_TOT_OD_INST;
      BEGIN
         IF P_ACNT_DETAILS.PENAL_BASED_ON_PENAL_DEF = '1'
         THEN
            V_PENAL_AMT_PER_OD_INST :=
               ROUND (
                  (P_ACNT_DETAILS.INST_AMT * (V_PENALTY_RATE / 100) * 1) / 12);
         ELSIF (    P_ACNT_DETAILS.PENAL_BASED_ON_PENAL_DEF = '0'
                AND TRIM (P_ACNT_DETAILS.PENAL_CHGCD) IS NOT NULL)
         THEN
            V_PENAL_AMT_PER_OD_INST := V_PENAL_CHGCD_AMT;
         END IF;

         WHILE V_NOOF_OD_INST > 0
         LOOP
            V_PENALTY_AMT :=
               V_PENALTY_AMT + (V_TOT_NOOF_OD_INST * V_PENAL_AMT_PER_OD_INST);
            V_NOOF_OD_INST := V_NOOF_OD_INST - 1;
            V_TOT_NOOF_OD_INST := V_TOT_NOOF_OD_INST - 1;
         END LOOP;

         RETURN ROUND (NVL (V_PENALTY_AMT, 0));
      END;
   BEGIN
      W_NO_OF_INST_OD := P_ACNT_DETAILS.NO_OF_INST_OVERDUE;
      W_NO_OF_INST_DUE := P_ACNT_DETAILS.NO_OF_INST_DUE;
      W_INST_AMT := P_ACNT_DETAILS.INST_AMT;

      --- Start account locking for multiple account tagging

      BEGIN
         SELECT COUNT (PBDCONT_INST_REC_FROM_AC)
           INTO W_DSA_COUNT
           FROM PBDCONTRACT
          WHERE     PBDCONT_INST_REC_FROM_AC = P_ACNT_DETAILS.AUTO_RECV_ACNT
                AND PBDCONT_CLOSURE_DATE IS NULL;
      END;

      IF NVL (W_DSA_COUNT, 0) > 1
      THEN
         SELECT ACNTBAL_ENTITY_NUM
           INTO W_LOCK_ENTITY
           FROM ACNTBAL
          WHERE     ACNTBAL_ENTITY_NUM = P_ACNT_DETAILS.ENTITY_NUM
                AND ACNTBAL_INTERNAL_ACNUM = P_ACNT_DETAILS.AUTO_RECV_ACNT
         FOR UPDATE;
      END IF;

      --- End of account locking for multiple account tagging

      BEGIN
         SP_AVLBAL (P_ACNT_DETAILS.ENTITY_NUM,
                    P_ACNT_DETAILS.AUTO_RECV_ACNT,
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
                    W_REC_ACNT_BAL,
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
                    PKG_ERR_MSG,
                    W_DUMMY_V,
                    W_DUMMY_N,
                    W_DUMMY_N,
                    W_DUMMY_N,
                    W_DUMMY_N,
                    W_DUMMY_N,
                    W_DUMMY_N,
                    W_DUMMY_N,
                    1);

         IF (TRIM (PKG_ERR_MSG) IS NOT NULL)
         THEN
            RAISE E_USEREXCEP;
         END IF;
      END;

      IF REC_ACNT_BOOKED_BAL.EXISTS (TO_CHAR (P_ACNT_DETAILS.AUTO_RECV_ACNT)) =
            FALSE
      THEN
         REC_ACNT_BOOKED_BAL (TO_CHAR (P_ACNT_DETAILS.AUTO_RECV_ACNT)) :=
            W_REC_ACNT_BAL;
      ELSE
         REC_ACNT_BOOKED_BAL (TO_CHAR (P_ACNT_DETAILS.AUTO_RECV_ACNT)) :=
            LEAST (
               W_REC_ACNT_BAL,
               NVL (
                  REC_ACNT_BOOKED_BAL (
                     TO_CHAR (P_ACNT_DETAILS.AUTO_RECV_ACNT)),
                  0));
      END IF;

      W_REC_ACNT_BAL :=
         NVL (REC_ACNT_BOOKED_BAL (TO_CHAR (P_ACNT_DETAILS.AUTO_RECV_ACNT)),
              0);

      -- W_REC_ACNT_BAL := W_REC_ACNT_BAL - 7500;

      GET_RECV_CHGCD_AMT (P_ACNT_DETAILS);

      V_AUTO_RECV_CHG_AMT := V_RECV_CHG_AMT + V_RECV_VAT_AMT;

      -- ideally the following penalty calculation stuff should be moved to
      -- a common procedure that can be used from ERDINS like programs too.
      IF W_NO_OF_INST_OD > 0
      THEN
         IF P_ACNT_DETAILS.PENAL_BASED_ON_PENAL_DEF = '1'
         THEN
            GET_PENALTY_RATE (P_ACNT_DETAILS);
         ELSIF TRIM (P_ACNT_DETAILS.PENAL_CHGCD) IS NOT NULL
         THEN
            GET_PENAL_CHGCD_AMT (P_ACNT_DETAILS);
         END IF;

         V_TEMP_NOOF_ODINST := W_NO_OF_INST_OD;

         WHILE V_TEMP_NOOF_ODINST > 0
         LOOP
            V_TMP_TOT_OD_INST_AMT := W_INST_AMT * V_TEMP_NOOF_ODINST;

            IF W_REC_ACNT_BAL >=
                  (V_TMP_TOT_OD_INST_AMT + V_AUTO_RECV_CHG_AMT)
            THEN
               V_TMP_TOT_PENAL_AMT :=
                  GET_PENALTY_AMT (P_ACNT_DETAILS,
                                   V_TEMP_NOOF_ODINST,
                                   W_NO_OF_INST_OD);

               IF W_REC_ACNT_BAL >=
                     (  V_TMP_TOT_OD_INST_AMT
                      + V_AUTO_RECV_CHG_AMT
                      + V_TMP_TOT_PENAL_AMT)
               THEN
                  V_TMP_OD_RECV_AMT :=
                     V_TMP_TOT_OD_INST_AMT + V_TMP_TOT_PENAL_AMT;
                  EXIT;
               END IF;
            END IF;

            V_TEMP_NOOF_ODINST := V_TEMP_NOOF_ODINST - 1;
         END LOOP;

         W_INDEX_NUMBER := W_INDEX_NUMBER + 1;

         REC_PENAL_ACNT (W_INDEX_NUMBER) := P_ACNT_DETAILS.INT_ACNT_NUM;
      END IF;

      IF V_TMP_OD_RECV_AMT > 0
      THEN
         V_TOT_OD_RECV_AMT := V_TMP_OD_RECV_AMT + V_AUTO_RECV_CHG_AMT;
         V_TOT_OD_INST_AMT := V_TMP_TOT_OD_INST_AMT;
         V_TOT_PENAL_AMT := V_TMP_TOT_PENAL_AMT;

         W_REC_ACNT_BAL := W_REC_ACNT_BAL - V_TOT_OD_RECV_AMT;
         REC_ACNT_BOOKED_BAL (TO_CHAR (P_ACNT_DETAILS.AUTO_RECV_ACNT)) :=
              NVL (
                 REC_ACNT_BOOKED_BAL (
                    TO_CHAR (P_ACNT_DETAILS.AUTO_RECV_ACNT)),
                 0)
            - V_TOT_OD_RECV_AMT;
      END IF;

      -- REGULAR INSTALLMENT
      IF     (W_NO_OF_INST_DUE - W_NO_OF_INST_OD) > 0
         AND (TO_NUMBER (TO_CHAR (W_REC_DATE, 'DD')) >=
                 P_ACNT_DETAILS.AUTO_RECV_DAY)
      THEN
         V_TOT_REG_INST_RECV_AMT :=
            (W_NO_OF_INST_DUE - W_NO_OF_INST_OD) * W_INST_AMT;

         IF V_TOT_OD_RECV_AMT <= 0
         THEN
            V_TOT_REG_RECV_AMT :=
               V_TOT_REG_INST_RECV_AMT + V_AUTO_RECV_CHG_AMT;
         ELSE
            V_TOT_REG_RECV_AMT := V_TOT_REG_INST_RECV_AMT;
         END IF;

         IF W_REC_ACNT_BAL < V_TOT_REG_RECV_AMT
         THEN
            V_TOT_REG_RECV_AMT := 0;
            V_TOT_REG_INST_RECV_AMT := 0;
         ELSE
            W_REC_ACNT_BAL := W_REC_ACNT_BAL - V_TOT_REG_RECV_AMT;
            REC_ACNT_BOOKED_BAL (TO_CHAR (P_ACNT_DETAILS.AUTO_RECV_ACNT)) :=
                 NVL (
                    REC_ACNT_BOOKED_BAL (
                       TO_CHAR (P_ACNT_DETAILS.AUTO_RECV_ACNT)),
                    0)
               - V_TOT_REG_RECV_AMT;
         END IF;
      END IF;

      V_TOT_RECV_AMT := V_TOT_OD_RECV_AMT + V_TOT_REG_RECV_AMT;
      V_TOT_INST_AMT := V_TOT_OD_INST_AMT + V_TOT_REG_INST_RECV_AMT;

      IF V_TOT_RECV_AMT > 0
      THEN
         -- ATTEMPT RECOVERY
         BEGIN
            IF W_COUNT = 1
            THEN
               PKG_APOST_INTERFACE.SP_POSTING_BEGIN (
                  P_ACNT_DETAILS.ENTITY_NUM);
            END IF;

            -- DEBIT LEGS
            IDX := IDX + 1;
            PKG_AUTOPOST.PV_TRAN_REC (IDX).TRAN_INTERNAL_ACNUM :=
               P_ACNT_DETAILS.AUTO_RECV_ACNT;
            PKG_AUTOPOST.PV_TRAN_REC (IDX).TRAN_DB_CR_FLG := 'D';
            PKG_AUTOPOST.PV_TRAN_REC (IDX).TRAN_VALUE_DATE := W_REC_DATE;
            PKG_AUTOPOST.PV_TRAN_REC (IDX).TRAN_AMOUNT := V_TOT_RECV_AMT;
            PKG_AUTOPOST.PV_TRAN_REC (IDX).TRAN_CURR_CODE :=
               P_ACNT_DETAILS.DEP_CURR;
            PKG_AUTOPOST.PV_TRAN_REC (IDX).TRAN_NARR_DTL1 :=
               'Inst. Recovered For ';
            PKG_AUTOPOST.PV_TRAN_REC (IDX).TRAN_NARR_DTL2 :=
               FACNO (P_ACNT_DETAILS.ENTITY_NUM, P_ACNT_DETAILS.INT_ACNT_NUM);
            PKG_AUTOPOST.PV_TRAN_REC (IDX).TRAN_NARR_DTL3 :=
               ' Recovery Date : ' || W_REC_DATE;

            -- CREDIT LEGS
            IDX := IDX + 1;
            PKG_AUTOPOST.PV_TRAN_REC (IDX).TRAN_INTERNAL_ACNUM :=
               P_ACNT_DETAILS.INT_ACNT_NUM;
            PKG_AUTOPOST.PV_TRAN_REC (IDX).TRAN_DB_CR_FLG := 'C';
            PKG_AUTOPOST.PV_TRAN_REC (IDX).TRAN_AMOUNT := V_TOT_INST_AMT;
            PKG_AUTOPOST.PV_TRAN_REC (IDX).TRAN_CURR_CODE :=
               P_ACNT_DETAILS.DEP_CURR;
            PKG_AUTOPOST.PV_TRAN_REC (IDX).TRAN_VALUE_DATE := W_REC_DATE;
            PKG_AUTOPOST.PV_TRAN_REC (IDX).TRAN_NARR_DTL1 :=
               'Auto Inst. Recovery From ';
            PKG_AUTOPOST.PV_TRAN_REC (IDX).TRAN_NARR_DTL2 :=
               FACNO (P_ACNT_DETAILS.ENTITY_NUM,
                      P_ACNT_DETAILS.AUTO_RECV_ACNT);

            IF V_TOT_PENAL_AMT > 0
            THEN
               IDX := IDX + 1;
               PKG_AUTOPOST.PV_TRAN_REC (IDX).TRAN_INTERNAL_ACNUM :=
                  P_ACNT_DETAILS.INT_ACNT_NUM;
               PKG_AUTOPOST.PV_TRAN_REC (IDX).TRAN_DB_CR_FLG := 'C';
               PKG_AUTOPOST.PV_TRAN_REC (IDX).TRAN_AMOUNT := V_TOT_PENAL_AMT;
               PKG_AUTOPOST.PV_TRAN_REC (IDX).TRAN_CURR_CODE :=
                  P_ACNT_DETAILS.DEP_CURR;
               PKG_AUTOPOST.PV_TRAN_REC (IDX).TRAN_VALUE_DATE := W_REC_DATE;
               PKG_AUTOPOST.PV_TRAN_REC (IDX).TRAN_NARR_DTL1 :=
                  'Auto Penalty Recovery From ';
               PKG_AUTOPOST.PV_TRAN_REC (IDX).TRAN_NARR_DTL2 :=
                  FACNO (P_ACNT_DETAILS.ENTITY_NUM,
                         P_ACNT_DETAILS.AUTO_RECV_ACNT);
            END IF;

            IF     V_AUTO_RECV_CHG_AMT > 0
               AND V_RECV_CHG_AMT > 0
               AND TRIM (P_ACNT_DETAILS.AUTO_REC_CHGCD_INCOME_GL) IS NOT NULL
               AND TRIM (P_ACNT_DETAILS.AUTO_REC_CHGCD_VAT_GL) IS NOT NULL
            THEN
               IDX := IDX + 1;
               PKG_AUTOPOST.PV_TRAN_REC (IDX).TRAN_GLACC_CODE :=
                  P_ACNT_DETAILS.AUTO_REC_CHGCD_INCOME_GL;
               PKG_AUTOPOST.PV_TRAN_REC (IDX).TRAN_DB_CR_FLG := 'C';
               PKG_AUTOPOST.PV_TRAN_REC (IDX).TRAN_AMOUNT := V_RECV_CHG_AMT;
               PKG_AUTOPOST.PV_TRAN_REC (IDX).TRAN_CURR_CODE :=
                  P_ACNT_DETAILS.DEP_CURR;
               PKG_AUTOPOST.PV_TRAN_REC (IDX).TRAN_VALUE_DATE := W_REC_DATE;
               PKG_AUTOPOST.PV_TRAN_REC (IDX).TRAN_NARR_DTL1 :=
                  'RD Auto Inst. Charge Recovery ';
               PKG_AUTOPOST.PV_TRAN_REC (IDX).TRAN_NARR_DTL2 :=
                     'For '
                  || FACNO (P_ACNT_DETAILS.ENTITY_NUM,
                            P_ACNT_DETAILS.INT_ACNT_NUM);

               IF     V_RECV_VAT_AMT > 0
                  AND TRIM (P_ACNT_DETAILS.AUTO_REC_CHGCD_VAT_GL) IS NOT NULL
               THEN
                  IDX := IDX + 1;
                  PKG_AUTOPOST.PV_TRAN_REC (IDX).TRAN_GLACC_CODE :=
                     P_ACNT_DETAILS.AUTO_REC_CHGCD_VAT_GL;
                  PKG_AUTOPOST.PV_TRAN_REC (IDX).TRAN_DB_CR_FLG := 'C';
                  PKG_AUTOPOST.PV_TRAN_REC (IDX).TRAN_AMOUNT := V_RECV_VAT_AMT;
                  PKG_AUTOPOST.PV_TRAN_REC (IDX).TRAN_CURR_CODE :=
                     P_ACNT_DETAILS.DEP_CURR;
                  PKG_AUTOPOST.PV_TRAN_REC (IDX).TRAN_VALUE_DATE := W_REC_DATE;
                  PKG_AUTOPOST.PV_TRAN_REC (IDX).TRAN_NARR_DTL1 :=
                     'RD Auto Inst. VAT Recovery ';
                  PKG_AUTOPOST.PV_TRAN_REC (IDX).TRAN_NARR_DTL2 :=
                        'For '
                     || FACNO (P_ACNT_DETAILS.ENTITY_NUM,
                               P_ACNT_DETAILS.INT_ACNT_NUM);
               END IF;
            END IF;

            V_ONE_INST := 1;
            W_COUNT := W_COUNT + 1;
         END;

         BEGIN
            SELECT NVL (MAX (RDINS_ENTRY_DAY_SL), 0) + 1
              INTO V_DAY_SL
              FROM RDINS
             WHERE     RDINS_ENTITY_NUM = P_ACNT_DETAILS.ENTITY_NUM
                   AND RDINS_RD_AC_NUM = P_ACNT_DETAILS.INT_ACNT_NUM
                   AND RDINS_ENTRY_DATE = W_REC_DATE;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               NULL;
         END;

         BEGIN
            IDX_RDINS := IDX_RDINS + 1;
            W_RDINS_REC (IDX_RDINS).RDINS_ENTITY_NUM :=
               P_ACNT_DETAILS.ENTITY_NUM;
            W_RDINS_REC (IDX_RDINS).RDINS_RD_AC_NUM :=
               P_ACNT_DETAILS.INT_ACNT_NUM;
            W_RDINS_REC (IDX_RDINS).RDINS_ENTRY_DATE := W_REC_DATE;
            W_RDINS_REC (IDX_RDINS).RDINS_ENTRY_DAY_SL := V_DAY_SL;
            W_RDINS_REC (IDX_RDINS).RDINS_EFF_DATE := W_REC_DATE;
            W_RDINS_REC (IDX_RDINS).RDINS_AMT_OF_PYMT := V_TOT_RECV_AMT;
            W_RDINS_REC (IDX_RDINS).RDINS_TWDS_INSTLMNT := V_TOT_INST_AMT;
            W_RDINS_REC (IDX_RDINS).RDINS_TWDS_PENAL_CHGS := V_TOT_PENAL_AMT;
            W_RDINS_REC (IDX_RDINS).RDINS_TWDS_INT := 0;
            W_RDINS_REC (IDX_RDINS).RDINS_REM1 := 'Auto Recovery for ';
            W_RDINS_REC (IDX_RDINS).RDINS_REM2 :=
               SUBSTR (P_ACNT_DETAILS.AC_NAME, 1, 35);
            W_RDINS_REC (IDX_RDINS).RDINS_REM3 := 'DUE DATE : ' || W_REC_DATE;
            W_RDINS_REC (IDX_RDINS).RDINS_TRANSTL_INV_NUM := 0;

            W_RDINS_REC (IDX_RDINS).RDINS_ENTD_BY :=
               PKG_EODSOD_FLAGS.PV_USER_ID;
            W_RDINS_REC (IDX_RDINS).RDINS_ENTD_ON :=
               PKG_EODSOD_FLAGS.PV_CURRENT_DATE;
            W_RDINS_REC (IDX_RDINS).RDINS_AUTH_BY :=
               PKG_EODSOD_FLAGS.PV_USER_ID;
            W_RDINS_REC (IDX_RDINS).RDINS_AUTH_ON :=
               PKG_EODSOD_FLAGS.PV_CURRENT_DATE;
            W_RDINS_REC (IDX_RDINS).RDINS_REJ_BY := NULL;
            W_RDINS_REC (IDX_RDINS).RDINS_REJ_ON := NULL;
            W_RDINS_REC (IDX_RDINS).RDINS_LAST_MOD_BY := NULL;
            W_RDINS_REC (IDX_RDINS).RDINS_LAST_MOD_ON := NULL;
            W_RDINS_REC (IDX_RDINS).RDINS_TWDS_CHG := NVL (V_RECV_CHG_AMT, 0);
            W_RDINS_REC (IDX_RDINS).RDINS_TWDS_VAT := NVL (V_RECV_VAT_AMT, 0);
         EXCEPTION
            WHEN OTHERS
            THEN
               PKG_ERR_MSG := 'Error in COLLECTION_ADDING_RDINS';
               RAISE E_USEREXCEP;
         END;
      END IF;
   END;

   FUNCTION CHECK_ACNTS_STATUS (P_ACNT_DETAILS IN ACNT_DETAILS_T)
      RETURN PKG_COMMON_TYPES.STRING_T
   IS
      V_ERR_MSG   PKG_COMMON_TYPES.STRING_T;
   BEGIN
      IF P_ACNT_DETAILS.REC_ACNT_CLOSE_DATE IS NOT NULL
      THEN
         V_ERR_MSG :=
               'Recovery AC: '
            || FACNO (P_ACNT_DETAILS.ENTITY_NUM,
                      P_ACNT_DETAILS.AUTO_RECV_ACNT)
            || ' Closed';
      ELSIF    P_ACNT_DETAILS.RD_ACNT_CR_FRZ = '1'
            OR P_ACNT_DETAILS.REC_ACNT_DR_FRZ = '1'
      THEN
         IF P_ACNT_DETAILS.RD_ACNT_CR_FRZ = '1'
         THEN
            V_ERR_MSG := 'CR Freezed';
         ELSIF P_ACNT_DETAILS.REC_ACNT_DR_FRZ = '1'
         THEN
            V_ERR_MSG :=
                  'DR Freezed For Recovery AC: '
               || FACNO (P_ACNT_DETAILS.ENTITY_NUM,
                         P_ACNT_DETAILS.AUTO_RECV_ACNT);
         END IF;
      ELSIF P_ACNT_DETAILS.NO_OF_INST_DUE <= 0
      THEN
         V_ERR_MSG := 'No Installment Due';
      ELSIF P_ACNT_DETAILS.ACNT_BAL < P_ACNT_DETAILS.INST_AMT
      THEN
         V_ERR_MSG :=
               'Balance Not Available in Recovery AC: '
            || FACNO (P_ACNT_DETAILS.ENTITY_NUM,
                      P_ACNT_DETAILS.AUTO_RECV_ACNT);
      END IF;

      RETURN V_ERR_MSG;
   END;

   PROCEDURE START_RDAUTOREC_BRNWISE (
      V_ENTITY_NUM   IN ENTITYNUM.ENTITYNUM_NUMBER%TYPE,
      P_BRN_CODE     IN MBRN.MBRN_CODE%TYPE DEFAULT 0,
      P_DEP_AC_NUM   IN PBDCONTRACT.PBDCONT_DEP_AC_NUM%TYPE DEFAULT 0)
   IS
      L_BRN_CODE   MBRN.MBRN_CODE%TYPE;
   BEGIN
      PKG_ENTITY.SP_SET_ENTITY_CODE (V_ENTITY_NUM);
      PKG_PROCESS_CHECK.INIT_PROC_BRN_WISE (V_ENTITY_NUM, P_BRN_CODE);

      FOR IDK IN 1 .. PKG_PROCESS_CHECK.V_ACNTBRN.COUNT
      LOOP
         L_BRN_CODE := PKG_PROCESS_CHECK.V_ACNTBRN (IDK).LN_BRN_CODE;

         IF PKG_PROCESS_CHECK.CHK_BRN_ALREADY_PROCESSED (V_ENTITY_NUM,
                                                         L_BRN_CODE) = FALSE
         THEN
            BEGIN
               START_RDAUTOREC (V_ENTITY_NUM, L_BRN_CODE, P_DEP_AC_NUM);

               IF TRIM (PKG_EODSOD_FLAGS.PV_ERROR_MSG) IS NULL
               THEN
                  PKG_PROCESS_CHECK.INSERT_ROW_INTO_EODSODPROCBRN (
                     V_ENTITY_NUM,
                     l_BRN_CODE);
               END IF;

               PKG_PROCESS_CHECK.CHECK_COMMIT_ROLLBACK_STATUS (V_ENTITY_NUM);
            EXCEPTION
               WHEN OTHERS
               THEN
                  IF TRIM (PKG_ERR_MSG) IS NULL
                  THEN
                     PKG_ERR_MSG := SUBSTR (SQLERRM, 1, 1000);
                  END IF;

                  PKG_EODSOD_FLAGS.PV_ERROR_MSG := PKG_ERR_MSG;
                  PKG_PB_GLOBAL.DETAIL_ERRLOG (V_ENTITY_NUM,
                                               'E',
                                               PKG_ERR_MSG || 2,
                                               ' ',
                                               0);
                  PKG_AUTOPOST.PV_TRAN_REC.DELETE;
            END;
         END IF;
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF TRIM (PKG_ERR_MSG) IS NULL
         THEN
            PKG_ERR_MSG := SUBSTR (SQLERRM, 1, 1000);
         END IF;

         PKG_EODSOD_FLAGS.PV_ERROR_MSG := PKG_ERR_MSG;
         PKG_PB_GLOBAL.DETAIL_ERRLOG (V_ENTITY_NUM,
                                      'E',
                                      PKG_ERR_MSG || 2,
                                      ' ',
                                      0);
         PKG_AUTOPOST.PV_TRAN_REC.DELETE;
   END;

   PROCEDURE START_RDAUTOREC (
      V_ENTITY_NUM   IN ENTITYNUM.ENTITYNUM_NUMBER%TYPE,
      P_BRN_CODE     IN MBRN.MBRN_CODE%TYPE DEFAULT 0,
      P_DEP_AC_NUM   IN PBDCONTRACT.PBDCONT_DEP_AC_NUM%TYPE DEFAULT 0,
      P_REC_DATE     IN MAINCONT.MN_CURR_BUSINESS_DATE%TYPE DEFAULT NULL)
   IS
      V_ACNT_DETAILS   ACNT_DETAILS_TT;
   BEGIN
      PKG_ENTITY.SP_SET_ENTITY_CODE (V_ENTITY_NUM);
      P_CBD := PKG_PB_GLOBAL.FN_GET_CURR_BUS_DATE (V_ENTITY_NUM);

      IF P_REC_DATE IS NULL
      THEN
         W_REC_DATE := P_CBD;
      ELSE
         W_REC_DATE := P_REC_DATE;
      END IF;

        SELECT V_ENTITY_NUM ENTITY_NUM,
               Q.*,
               CASE
                  WHEN (    Q.INST_PAY_OPTION = '3'
                        AND TO_NUMBER (TO_CHAR (W_REC_DATE, 'DD')) <=
                               Q.PROD_CUTOFF_DAY)
                  THEN
                     CASE
                        WHEN (Q.NO_OF_INST_DUE - 1) < 0 THEN 0
                        ELSE (Q.NO_OF_INST_DUE - 1)
                     END
                  WHEN (Q.INST_PAY_OPTION = '1')
                  THEN
                     CASE
                        WHEN (Q.NO_OF_INST_DUE - 1) < 0 THEN 0
                        ELSE (Q.NO_OF_INST_DUE - 1)
                     END
                  ELSE
                     Q.NO_OF_INST_DUE
               END
                  NO_OF_INST_OVERDUE
          BULK COLLECT INTO V_ACNT_DETAILS
          FROM (SELECT O.*,
                       CASE
                          WHEN (   O.TOT_INST_PAID_UPTO >= O.TOT_NO_OF_INST
                                OR TRUNC (
                                      O.NO_OF_MONTHS_ELAPSED / O.FREQ_OF_DEP) <=
                                      O.TOT_INST_PAID_UPTO)
                          THEN
                             0
                          ELSE
                             (  TRUNC (O.NO_OF_MONTHS_ELAPSED / O.FREQ_OF_DEP)
                              - O.TOT_INST_PAID_UPTO)
                       END
                          NO_OF_INST_DUE
                  FROM (SELECT M.*,
                               CASE
                                  WHEN M.INST_AMT <> 0
                                  THEN
                                     NVL (
                                        TRUNC (
                                             N.TOT_INST_AMT_PAID_UPTO
                                           / M.INST_AMT),
                                        0)
                                  ELSE
                                     0
                               END
                                  TOT_INST_PAID_UPTO,
                               NVL (N.TOT_AMT_PAID_UPTO, 0) TOT_AMT_PAID_UPTO,
                               NVL (N.TOT_INST_AMT_PAID_UPTO, 0)
                                  TOT_INST_AMT_PAID_UPTO,
                               NVL (N.TOT_PENAL_AMT_PAID_UPTO, 0)
                                  TOT_PENAL_AMT_PAID_UPTO,
                               NVL (N.TOT_INT_AMT_PAID_UPTO, 0)
                                  TOT_INT_AMT_PAID_UPTO,
                               B.ACNTBAL_BC_BAL ACNT_BAL
                          FROM (SELECT P.PBDCONT_BRN_CODE BRN_CODE,
                                       P.PBDCONT_PROD_CODE PROD_CODE,
                                       P.PBDCONT_DEP_AC_NUM INT_ACNT_NUM,
                                       TRIM (A.ACNTS_AC_TYPE) AC_TYPE,
                                       NVL (A.ACNTS_AC_SUB_TYPE, 0) AC_SUB_TYPE,
                                       P.PBDCONT_CONT_NUM CONT_NUM,
                                       TRIM (A.ACNTS_AC_NAME1) AC_NAME,
                                       NVL (TRIM (A.ACNTS_CR_FREEZED), '0')
                                          RD_ACNT_CR_FRZ,
                                       P.PBDCONT_DEP_CURR DEP_CURR,
                                       CASE
                                          WHEN NVL (P.PBDCONT_BC_DEP_AMT, 0) =
                                                  0
                                          THEN
                                             NVL (P.PBDCONT_AC_DEP_AMT, 0)
                                          ELSE
                                             NVL (P.PBDCONT_BC_DEP_AMT, 0)
                                       END
                                          INST_AMT,
                                       DECODE (
                                          NVL (TRIM (P.PBDCONT_FREQ_OF_DEP),
                                               'M'),
                                          'M', 1,
                                          'Q', 3,
                                          'H', 6,
                                          'Y', 12,
                                          1)
                                          FREQ_OF_DEP,
                                       P.PBDCONT_EFF_DATE EFF_DATE,
                                       P.PBDCONT_NO_OF_INST TOT_NO_OF_INST,
                                       P.PBDCONT_MAT_DATE MAT_DATE,
                                       P.PBDCONT_MAT_VALUE MAT_VALUE,
                                       CASE
                                          WHEN TRIM (P.PBDCONT_INST_PAY_OPTION)
                                                  IS NULL
                                          THEN
                                             NVL (TRIM (D.DEPPR_RD_DAY_OPTION),
                                                  '1')
                                          ELSE
                                             TRIM (P.PBDCONT_INST_PAY_OPTION)
                                       END
                                          INST_PAY_OPTION,
                                       NVL (TRIM (D.DEPPR_INST_CUTOFF_DAY), 0)
                                          PROD_CUTOFF_DAY,
                                       NVL (
                                          TRIM (P.PBDCONT_AUTO_INST_REC_REQD),
                                          '0')
                                          AUTO_RECV_REQD,
                                       NVL (P.PBDCONT_INST_REC_DAY, 0)
                                          AUTO_RECV_DAY,
                                       NVL (P.PBDCONT_INST_REC_FROM_AC, 0)
                                          AUTO_RECV_ACNT,
                                       (SELECT S.ACNTS_CLIENT_NUM
                                          FROM ACNTS S
                                         WHERE     S.ACNTS_ENTITY_NUM =
                                                      V_ENTITY_NUM
                                               AND S.ACNTS_INTERNAL_ACNUM =
                                                      P.PBDCONT_INST_REC_FROM_AC)
                                          REC_ACNT_CLIENT_NO,
                                       (SELECT NVL (TRIM (S.ACNTS_DB_FREEZED),
                                                    '0')
                                          FROM ACNTS S
                                         WHERE     S.ACNTS_ENTITY_NUM =
                                                      V_ENTITY_NUM
                                               AND S.ACNTS_INTERNAL_ACNUM =
                                                      P.PBDCONT_INST_REC_FROM_AC)
                                          REC_ACNT_DR_FRZ,
                                       (SELECT TRIM (S.ACNTS_CURR_CODE)
                                          FROM ACNTS S
                                         WHERE     S.ACNTS_ENTITY_NUM =
                                                      V_ENTITY_NUM
                                               AND S.ACNTS_INTERNAL_ACNUM =
                                                      P.PBDCONT_INST_REC_FROM_AC)
                                          REC_ACNT_CURR_CODE,
                                       (SELECT S.ACNTS_CLOSURE_DATE
                                          FROM ACNTS S
                                         WHERE     S.ACNTS_ENTITY_NUM =
                                                      V_ENTITY_NUM
                                               AND S.ACNTS_INTERNAL_ACNUM =
                                                      P.PBDCONT_INST_REC_FROM_AC)
                                          REC_ACNT_CLOSE_DATE,
                                       NVL (
                                          TRIM (D.DEPPR_PENALTY_BSD_ON_PEN_DEF),
                                          '0')
                                          PENAL_BASED_ON_PENAL_DEF,
                                       TRIM (D.DEPPR_RD_PENAL_CHGCD)
                                          PENAL_CHGCD,
                                       TRIM (D.DEPPR_RDREC_CHGCD)
                                          AUTO_REC_CHGCD,
                                       CASE
                                          WHEN TRIM (D.DEPPR_RDREC_CHGCD)
                                                  IS NOT NULL
                                          THEN
                                             (SELECT TRIM (CHGCD_CHG_TYPE)
                                                FROM CHGCD
                                               WHERE TRIM (CHGCD_CHARGE_CODE) =
                                                        TRIM (
                                                           D.DEPPR_RDREC_CHGCD))
                                          ELSE
                                             NULL
                                       END
                                          AUTO_REC_CHGCD_TYPE,
                                       CASE
                                          WHEN TRIM (D.DEPPR_RDREC_CHGCD)
                                                  IS NOT NULL
                                          THEN
                                             (SELECT TRIM (
                                                        CHGCD_CR_INCOME_HEAD)
                                                FROM CHGCD
                                               WHERE TRIM (CHGCD_CHARGE_CODE) =
                                                        TRIM (
                                                           D.DEPPR_RDREC_CHGCD))
                                          ELSE
                                             NULL
                                       END
                                          AUTO_REC_CHGCD_INCOME_GL,
                                       CASE
                                          WHEN TRIM (D.DEPPR_RDREC_CHGCD)
                                                  IS NOT NULL
                                          THEN
                                             (SELECT TRIM (
                                                        CHGCD_SERVICE_TAX_CODE)
                                                FROM CHGCD
                                               WHERE TRIM (CHGCD_CHARGE_CODE) =
                                                        TRIM (
                                                           D.DEPPR_RDREC_CHGCD))
                                          ELSE
                                             NULL
                                       END
                                          AUTO_REC_CHGCD_VAT_CODE,
                                       CASE
                                          WHEN TRIM (D.DEPPR_RDREC_CHGCD)
                                                  IS NOT NULL
                                          THEN
                                             (SELECT TRIM (
                                                        STAXACPM_STAX_RCVD_HEAD)
                                                FROM CHGCD, STAXACPM
                                               WHERE     CHGCD_SERVICE_TAX_CODE =
                                                            STAXACPM_TAX_CODE(+)
                                                     AND TRIM (
                                                            CHGCD_CHARGE_CODE) =
                                                            TRIM (
                                                               D.DEPPR_RDREC_CHGCD))
                                          ELSE
                                             NULL
                                       END
                                          AUTO_REC_CHGCD_VAT_GL,
                                       CASE
                                          WHEN ABS (
                                                  ROUND (
                                                     MONTHS_BETWEEN (
                                                        TRUNC (
                                                           P.PBDCONT_EFF_DATE,
                                                           'MON'),
                                                        LAST_DAY (W_REC_DATE)))) >
                                                  P.PDBCONT_DEP_PRD_MONTHS
                                          THEN
                                             P.PDBCONT_DEP_PRD_MONTHS
                                          ELSE
                                             ABS (
                                                ROUND (
                                                   MONTHS_BETWEEN (
                                                      TRUNC (
                                                         P.PBDCONT_EFF_DATE,
                                                         'MON'),
                                                      LAST_DAY (W_REC_DATE))))
                                       END
                                          NO_OF_MONTHS_ELAPSED
                                  FROM DEPPROD D, PBDCONTRACT P, ACNTS A
                                 WHERE     NVL (TRIM (D.DEPPR_TYPE_OF_DEP),
                                                '0') = '3'
                                       AND D.DEPPR_PROD_CODE =
                                              P.PBDCONT_PROD_CODE
                                       AND P.PBDCONT_ENTITY_NUM =
                                              A.ACNTS_ENTITY_NUM
                                       AND P.PBDCONT_BRN_CODE =
                                              A.ACNTS_BRN_CODE
                                       AND P.PBDCONT_DEP_AC_NUM =
                                              A.ACNTS_INTERNAL_ACNUM
                                       AND P.PBDCONT_ENTITY_NUM = V_ENTITY_NUM
                                       AND A.ACNTS_ENTITY_NUM = V_ENTITY_NUM
                                       AND P.PBDCONT_BRN_CODE =
                                              DECODE (NVL (P_BRN_CODE, 0),
                                                      0, P.PBDCONT_BRN_CODE,
                                                      P_BRN_CODE)
                                       AND A.ACNTS_BRN_CODE =
                                              DECODE (NVL (P_BRN_CODE, 0),
                                                      0, A.ACNTS_BRN_CODE,
                                                      P_BRN_CODE)
                                       AND P.PBDCONT_DEP_AC_NUM =
                                              DECODE (NVL (P_DEP_AC_NUM, 0),
                                                      0, P.PBDCONT_DEP_AC_NUM,
                                                      P_DEP_AC_NUM)
                                       AND A.ACNTS_INTERNAL_ACNUM =
                                              DECODE (
                                                 NVL (P_DEP_AC_NUM, 0),
                                                 0, A.ACNTS_INTERNAL_ACNUM,
                                                 P_DEP_AC_NUM)
                                       AND (   P.PBDCONT_CLOSURE_DATE IS NULL
                                            OR A.ACNTS_CLOSURE_DATE IS NULL)
                                       AND NVL (
                                              TRIM (
                                                 P.PBDCONT_AUTO_INST_REC_REQD),
                                              '0') = '1'
                                       AND NVL (P.PBDCONT_INST_REC_FROM_AC, 0) <>
                                              0) M,
                               (  SELECT /*+ PARALLEL(R,8) */
                                        R.RDINS_RD_AC_NUM ACNT_NO,
                                         ROUND (
                                              SUM (
                                                 NVL (R.RDINS_TWDS_INSTLMNT, 0))
                                            + SUM (
                                                 NVL (R.RDINS_TWDS_PENAL_CHGS, 0))
                                            + SUM (NVL (R.RDINS_TWDS_INT, 0)))
                                            TOT_AMT_PAID_UPTO,
                                         ROUND (SUM (R.RDINS_TWDS_INSTLMNT))
                                            TOT_INST_AMT_PAID_UPTO,
                                         ROUND (SUM (R.RDINS_TWDS_PENAL_CHGS))
                                            TOT_PENAL_AMT_PAID_UPTO,
                                         ROUND (SUM (R.RDINS_TWDS_INT))
                                            TOT_INT_AMT_PAID_UPTO
                                    FROM RDINS R
                                   WHERE     R.RDINS_ENTITY_NUM = V_ENTITY_NUM
                                         AND R.RDINS_AUTH_ON IS NOT NULL
                                GROUP BY R.RDINS_RD_AC_NUM) N,
                               ACNTBAL B
                         WHERE     M.INT_ACNT_NUM = N.ACNT_NO(+)
                               AND M.AUTO_RECV_ACNT =
                                      B.ACNTBAL_INTERNAL_ACNUM(+)
                               AND M.REC_ACNT_CURR_CODE = B.ACNTBAL_CURR_CODE
                               AND B.ACNTBAL_ENTITY_NUM = V_ENTITY_NUM) O) Q
      ORDER BY Q.BRN_CODE, Q.PROD_CODE;

      FOR I IN 1 .. V_ACNT_DETAILS.COUNT
      LOOP
         PKG_ERR_MSG := CHECK_ACNTS_STATUS (V_ACNT_DETAILS (I));

         IF TRIM (PKG_ERR_MSG) IS NOT NULL
         THEN
            PKG_PB_GLOBAL.DETAIL_ERRLOG (V_ENTITY_NUM,
                                         'X',
                                         PKG_ERR_MSG,
                                         NULL,
                                         V_ACNT_DETAILS (I).INT_ACNT_NUM);
            PKG_ERR_MSG := NULL;
         ELSIF V_ACNT_DETAILS (I).NO_OF_INST_DUE > 0
         THEN
            CREATE_RDINS (V_ACNT_DETAILS (I));
         END IF;
      END LOOP;

      IF V_ONE_INST = 1
      THEN
         UPDATE_PARA (V_ENTITY_NUM, P_BRN_CODE);
      END IF;

      V_ACNT_DETAILS.DELETE;
      V_ONE_INST := 0;
      W_COUNT := 1;
      IDX := 0;
      IDX_RDINS := 0;
      W_INDEX_NUMBER := 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF TRIM (PKG_ERR_MSG) IS NULL
         THEN
            PKG_ERR_MSG :=
               'Error in start_rdautorec (PKG_ENTITY.FN_GET_ENTITY_CODE,RD Installmet Recovery) ';
         ELSE
            PKG_ERR_MSG := SUBSTR (SQLERRM, 1, 1000);
         END IF;

         PKG_EODSOD_FLAGS.PV_ERROR_MSG := PKG_ERR_MSG;
         PKG_PB_GLOBAL.DETAIL_ERRLOG (V_ENTITY_NUM,
                                      'E',
                                      PKG_ERR_MSG || 4,
                                      ' ',
                                      0);
         V_ACNT_DETAILS.DELETE;
         PKG_AUTOPOST.PV_TRAN_REC.DELETE;
   END;

   FUNCTION AUTOPOSTINT (P_ENTITY_NUM   IN ENTITYNUM.ENTITYNUM_NUMBER%TYPE,
                         P_BRANCH       IN MBRN.MBRN_CODE%TYPE)
      RETURN BOOLEAN
   IS
      W_ERR_CODE    NUMBER;
      W_BATCH_NUM   NUMBER (7);

      PROCEDURE SET_TRAN_KEY_VALUES
      IS
      BEGIN
         PKG_AUTOPOST.PV_TRAN_KEY.TRAN_BRN_CODE := P_BRANCH;
         PKG_AUTOPOST.PV_TRAN_KEY.TRAN_DATE_OF_TRAN := W_REC_DATE;
         PKG_AUTOPOST.PV_TRAN_KEY.TRAN_BATCH_NUMBER := 0;
         PKG_AUTOPOST.PV_TRAN_KEY.TRAN_BATCH_SL_NUM := 0;
         PKG_AUTOPOST.PV_AUTO_AUTHORISE := FALSE;
      END;

      PROCEDURE SET_TRANBAT_VALUES
      IS
      BEGIN
         PKG_AUTOPOST.PV_TRANBAT.TRANBAT_SOURCE_TABLE := 'RDINS';
         PKG_AUTOPOST.PV_TRANBAT.TRANBAT_SOURCE_KEY :=
            P_BRANCH || '|' || P_CBD;
         PKG_AUTOPOST.PV_TRANBAT.TRANBAT_NARR_DTL1 :=
            'RD Auto Inst. Recovery. ';
         PKG_AUTOPOST.PV_TRANBAT.TRANBAT_NARR_DTL2 :=
            'Recovery Date: ' || W_REC_DATE;
      END;
   BEGIN
      SET_TRAN_KEY_VALUES;
      SET_TRANBAT_VALUES;

      PKG_APOST_INTERFACE.SP_POST_SODEOD_BATCH (
         PKG_ENTITY.FN_GET_ENTITY_CODE,
         'A',
         IDX,
         0,
         W_ERR_CODE,
         PKG_ERR_MSG,
         W_BATCH_NUM);

      IF (W_ERR_CODE <> '0000')
      THEN
         PKG_ERR_MSG :=
            FN_GET_AUTOPOST_ERR_MSG (PKG_ENTITY.FN_GET_ENTITY_CODE);
         RAISE E_USEREXCEP;
      END IF;

      PKG_APOST_INTERFACE.SP_POSTING_END (PKG_ENTITY.FN_GET_ENTITY_CODE);

      FOR RDINS_IDX IN 1 .. W_RDINS_REC.COUNT
      LOOP
         W_RDINS_REC (RDINS_IDX).POST_TRAN_BRN := P_BRANCH;
         W_RDINS_REC (RDINS_IDX).POST_TRAN_DATE := W_REC_DATE;
         W_RDINS_REC (RDINS_IDX).POST_TRAN_BATCH_NUM := W_BATCH_NUM;
      END LOOP;

      IDX := 0;
      V_ONE_INST := 0;
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF TRIM (PKG_ERR_MSG) IS NULL
         THEN
            PKG_ERR_MSG := 'error in AutoPostInt function for ';
            PKG_ERR_MSG := PKG_ERR_MSG || P_BRANCH;
         END IF;

         PKG_EODSOD_FLAGS.PV_ERROR_MSG := PKG_ERR_MSG;
         PKG_PB_GLOBAL.DETAIL_ERRLOG (P_ENTITY_NUM,
                                      'E',
                                      PKG_ERR_MSG || 5,
                                      ' ');

         RETURN FALSE;
   END;


   FUNCTION UPDATE_PBDCONTRACT
      RETURN BOOLEAN
   IS
   BEGIN
      FORALL ID IN 1 .. REC_PENAL_ACNT.COUNT
         UPDATE PBDCONTRACT
            SET PBDCONT_RD_REGULARITY = 0
          WHERE PBDCONT_DEP_AC_NUM = REC_PENAL_ACNT (ID);

      REC_PENAL_ACNT.DELETE;
      W_INDEX_NUMBER := 0;
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         PKG_ERR_MSG :=
               'error in UPDATING PBCONTRACT TABLE   '
            || SUBSTR (SQLERRM, 1, 500);
         RETURN FALSE;
   END;

   FUNCTION UPDATE_RDINS
      RETURN BOOLEAN
   IS
   BEGIN
      FORALL RDINX_IDX IN 1 .. W_RDINS_REC.COUNT
         INSERT INTO RDINS
              VALUES W_RDINS_REC (RDINX_IDX);

      W_RDINS_REC.DELETE;
      IDX_RDINS := 0;
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         PKG_ERR_MSG :=
            'error in INSERTING RDINS TABLE   ' || SUBSTR (SQLERRM, 1, 500);
         RETURN FALSE;
   END;

   PROCEDURE UPDATE_PARA (P_ENTITY_NUM   IN ENTITYNUM.ENTITYNUM_NUMBER%TYPE,
                          P_BRANCH       IN MBRN.MBRN_CODE%TYPE)
   IS
   BEGIN
      --  Call AutoPostInt
      IF NOT AUTOPOSTINT (P_ENTITY_NUM, P_BRANCH)
      THEN
         RAISE E_USEREXCEP;
      END IF;

      IF NOT UPDATE_RDINS
      THEN
         RAISE E_USEREXCEP;
      END IF;

      IF NOT UPDATE_PBDCONTRACT
      THEN
         RAISE E_USEREXCEP;
      END IF;
   END;
END;
/