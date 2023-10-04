CREATE OR REPLACE PACKAGE PKG_DATA_CORRECTOR IS
  PROCEDURE SP_DATA_CORRECTION(P_CODE      IN VARCHAR,
                               P_QUERY_STR IN VARCHAR,
                               P_OLD_DATA  IN VARCHAR,
                               P_NEW_DATA  IN VARCHAR,
                               P_BRN_CODE  IN NUMBER,
                               P_REMARKS   IN VARCHAR,
                               P_ENTD_ON   IN DATE,
                               P_ENTD_BY   IN VARCHAR,
                               P_ERR_MSG   OUT VARCHAR,
                               P_SHOW_MSG  OUT VARCHAR);

  PROCEDURE SP_DATA_QUERY(P_CODE      IN VARCHAR,
                          P_QUERY_STR IN VARCHAR,
                          P_BRN_CODE  IN NUMBER,
                          P_RLV_DATA  OUT VARCHAR,
                          P_UPD_DATA  OUT VARCHAR,
                          P_ERR_MSG   OUT VARCHAR);

END PKG_DATA_CORRECTOR;
/

CREATE OR REPLACE PACKAGE BODY PKG_DATA_CORRECTOR
IS
   TYPE CTR_STRING IS TABLE OF VARCHAR2 (1000)
      INDEX BY BINARY_INTEGER;

   TYPE OLD_DATA_STRING IS TABLE OF VARCHAR2 (1000)
      INDEX BY BINARY_INTEGER;

   TYPE NEW_DATA_STRING IS TABLE OF VARCHAR2 (1000)
      INDEX BY BINARY_INTEGER;

   TYPE DATA_TYPE_STRING IS TABLE OF VARCHAR2 (1000)
      INDEX BY BINARY_INTEGER;

   TYPE MAND_OPT_STRING IS TABLE OF VARCHAR2 (1000)
      INDEX BY BINARY_INTEGER;

   TYPE FIELD_DESC_STRING IS TABLE OF VARCHAR2 (1000)
      INDEX BY BINARY_INTEGER;

   TYPE FILTER_DATA_STRING IS TABLE OF VARCHAR2 (1000)
      INDEX BY BINARY_INTEGER;

   TYPE FILTER_BRN_IDNT_STRING IS TABLE OF VARCHAR2 (1000)
      INDEX BY BINARY_INTEGER;

   TYPE COMMON_FILTER_STRING IS TABLE OF VARCHAR2 (1000)
      INDEX BY BINARY_INTEGER;

   V_QRY_UPD_CODE           VARCHAR2 (10);
   V_QUERY_STR              VARCHAR2 (2000);
   V_OLD_DATA               VARCHAR2 (2000);
   V_NEW_DATA               VARCHAR2 (2000);
   V_UPD_DATA_TYPES         VARCHAR2 (20);
   V_QRY_DATA_TYPES         VARCHAR2 (20);
   V_BRN_FILTER_TYP         VARCHAR2 (20);
   V_QRY_FIELD_DESC         VARCHAR2 (2000);
   V_UPD_FIELD_DESC         VARCHAR2 (2000);
   V_UPD_MAND_OPT           VARCHAR2 (20);
   V_CONF_BRN_QRY           VARCHAR2 (1000);
   V_CONF_RLVQRY            VARCHAR2 (2000);
   V_CONF_UPDQRY            VARCHAR2 (2000);

   --V_BRN_IDNT_QRY   --Noor
   V_ERR_MSG                VARCHAR2 (100);
   V_SHOW_MSG               VARCHAR2 (300);
   V_EMPTY_MSG              VARCHAR2 (100) := ' Should Not be Blank';
   V_DATE_FMT               VARCHAR (10) := 'DD/MM/YYYY';
   V_DATE_TIME_FMT          VARCHAR (30) := 'dd/mm/yyyy hh24:mi:ss';
   V_YEAR_FMT               VARCHAR (30) := 'Year Format Should Be - YYYY';
   V_NO_OF_MAX_VAL          NUMBER (2) := 10;
   V_NO_OF_SEP_VAL          NUMBER (2);
   V_BRN_CODE               NUMBER (6);
   V_CBD                    DATE;
   V_REMARKS                VARCHAR2 (250);
   V_ENTD_BY                VARCHAR2 (10);
   V_ENTD_ON                DATE;
   HO_BRN                   NUMBER (1);
   V_ENTITY_NUM             NUMBER;
   V_GLOB_ENTITY_NUM        NUMBER;
   W_CBD                    DATE := PKG_EODSOD_FLAGS.PV_CURRENT_DATE;

   T_CTR_STRING             CTR_STRING;
   T_OLD_DATA_STRING        OLD_DATA_STRING;
   T_NEW_DATA_STRING        NEW_DATA_STRING;
   T_DATA_TYPE_STRING       DATA_TYPE_STRING;
   T_MAND_OPT_STRING        MAND_OPT_STRING;
   T_FIELD_DESC_STRING      FIELD_DESC_STRING;
   T_FILTER_DATA_STRING     FILTER_DATA_STRING;
   T_FILTER_BRN_IDNT_STR    FILTER_BRN_IDNT_STRING;
   T_COMMON_FILTER_STRING   COMMON_FILTER_STRING;

   ----------------------------------------------------------------------------------------------------

   FUNCTION GETSTRING (SOURCE_STRING    IN VARCHAR2,
                       FIELD_POSITION   IN NUMBER,
                       UNTERMINATED     IN BOOLEAN DEFAULT FALSE,
                       DELIMITER        IN VARCHAR2 DEFAULT ',')
      RETURN VARCHAR2
   IS
      IPTREND           PLS_INTEGER := 0;
      IPTRSTART         PLS_INTEGER := 0;
      VCSOURCESTRCOPY   VARCHAR2 (4000) := SOURCE_STRING;
   BEGIN
      IF UNTERMINATED
      THEN
         VCSOURCESTRCOPY := VCSOURCESTRCOPY || DELIMITER;
      END IF;

      IF FIELD_POSITION > 1
      THEN
         IPTRSTART :=
              INSTR (VCSOURCESTRCOPY,
                     DELIMITER,
                     1,
                     FIELD_POSITION - 1)
            + LENGTH (DELIMITER);
      ELSE
         IPTRSTART := 1;
      END IF;

      IPTREND :=
         INSTR (VCSOURCESTRCOPY,
                DELIMITER,
                1,
                FIELD_POSITION);
      RETURN SUBSTR (VCSOURCESTRCOPY, IPTRSTART, (IPTREND - IPTRSTART));
   END GETSTRING;

   --------------------------------------------------------------------------------------------------

   PROCEDURE INIT_CONFIGURATION
   IS
   BEGIN
      V_NO_OF_SEP_VAL := 0;
      V_ERR_MSG := NULL;

      SELECT DATACTRCONF_COND,
             DATACTRCONF_C_DTYP,
             DATACTRCONF_UPDDATA,
             DATACTRCONF_DTTYPE,
             DATACTRCONF_MANDOPT,
             DATACTRCONF_RLVQRY,
             DATACTRCONF_UPDQRY,
             DATACTRCONF_BRN_QRY,
             DATACTRCONF_BRNQ_DTP
        INTO V_QRY_FIELD_DESC,
             V_QRY_DATA_TYPES,
             V_UPD_FIELD_DESC,
             V_UPD_DATA_TYPES,
             V_UPD_MAND_OPT,
             V_CONF_RLVQRY,
             V_CONF_UPDQRY,
             V_CONF_BRN_QRY,
             V_BRN_FILTER_TYP
        FROM DATACTRCONF
       WHERE DATACTRCONF_ID = V_QRY_UPD_CODE;
   END INIT_CONFIGURATION;

   -----------------------------------------------------------------------------------------------------

   PROCEDURE PARSE_UPDATED_DATA
   IS
   BEGIN
      FOR I IN 1 .. V_NO_OF_MAX_VAL
      LOOP
         T_FILTER_DATA_STRING (I) :=
            GETSTRING (V_QUERY_STR,
                       I,
                       TRUE,
                       '|');
         T_CTR_STRING (I) :=
            GETSTRING (V_QUERY_STR,
                       I,
                       TRUE,
                       '|');
         T_OLD_DATA_STRING (I) :=
            GETSTRING (V_OLD_DATA,
                       I,
                       TRUE,
                       '|');
         T_NEW_DATA_STRING (I) :=
            GETSTRING (V_NEW_DATA,
                       I,
                       TRUE,
                       '|');
         T_DATA_TYPE_STRING (I) :=
            GETSTRING (V_UPD_DATA_TYPES,
                       I,
                       TRUE,
                       '|');
         T_MAND_OPT_STRING (I) :=
            GETSTRING (V_UPD_MAND_OPT,
                       I,
                       TRUE,
                       '|');
         T_FIELD_DESC_STRING (I) :=
            GETSTRING (V_UPD_FIELD_DESC,
                       I,
                       TRUE,
                       '|');
         T_FILTER_BRN_IDNT_STR (I) :=
            GETSTRING (V_BRN_FILTER_TYP,
                       I,
                       TRUE,
                       '|');
      END LOOP;
   END PARSE_UPDATED_DATA;

   ------------------------------------------------------------------------------------------------------
   PROCEDURE PARSE_QUERY_DATA
   IS
   BEGIN
      FOR I IN 1 .. V_NO_OF_MAX_VAL
      LOOP
         T_FILTER_DATA_STRING (I) :=
            GETSTRING (V_QUERY_STR,
                       I,
                       TRUE,
                       '|');
         T_NEW_DATA_STRING (I) :=
            GETSTRING (V_QUERY_STR,
                       I,
                       TRUE,
                       '|');
         T_DATA_TYPE_STRING (I) :=
            GETSTRING (V_QRY_DATA_TYPES,
                       I,
                       TRUE,
                       '|');
         T_MAND_OPT_STRING (I) := 1;
         T_FIELD_DESC_STRING (I) :=
            GETSTRING (V_QRY_FIELD_DESC,
                       I,
                       TRUE,
                       '|');
         T_FILTER_BRN_IDNT_STR (I) :=
            GETSTRING (V_BRN_FILTER_TYP,
                       I,
                       TRUE,
                       '|');
      END LOOP;
   END PARSE_QUERY_DATA;

   --------------------------------------------------------------------------------------------------------
   PROCEDURE VALIDATE_DATA_TYPES
   IS
      V_DATA_TYPE   VARCHAR2 (25);
      V_NEW_NUM     NUMBER;
      V_DATE        DATE;
   BEGIN
      FOR J IN T_DATA_TYPE_STRING.FIRST .. T_DATA_TYPE_STRING.LAST
      LOOP
         BEGIN
            -- Number Validation
            IF T_DATA_TYPE_STRING (J) = 'N'
            THEN
               IF T_MAND_OPT_STRING (J) = 1 AND T_NEW_DATA_STRING (J) IS NULL
               THEN
                  V_ERR_MSG := T_FIELD_DESC_STRING (J) || V_EMPTY_MSG;
               ELSE
                  V_DATA_TYPE := 'Numeric';
                  V_NO_OF_SEP_VAL := V_NO_OF_SEP_VAL + 1;
                  V_NEW_NUM := TO_NUMBER (T_NEW_DATA_STRING (J));
               END IF;
            ELSIF T_DATA_TYPE_STRING (J) = 'D'
            THEN
               IF T_MAND_OPT_STRING (J) = 1 AND T_NEW_DATA_STRING (J) IS NULL
               THEN
                  V_ERR_MSG := T_FIELD_DESC_STRING (J) || V_EMPTY_MSG;
               ELSE
                  V_DATA_TYPE := 'Date [' || V_DATE_FMT || ']';
                  V_NO_OF_SEP_VAL := V_NO_OF_SEP_VAL + 1;
                  V_DATE := TO_DATE (T_NEW_DATA_STRING (J), V_DATE_FMT);

                  IF (LENGTH (TO_NUMBER (TO_CHAR (V_DATE, 'YYYY'))) < 4)
                  THEN
                     V_ERR_MSG := V_YEAR_FMT;
                  END IF;
               END IF;
            ELSIF T_DATA_TYPE_STRING (J) = 'S'
            THEN
               IF T_MAND_OPT_STRING (J) = 1 AND T_NEW_DATA_STRING (J) IS NULL
               THEN
                  V_ERR_MSG := T_FIELD_DESC_STRING (J) || V_EMPTY_MSG;
               END IF;

               V_NO_OF_SEP_VAL := V_NO_OF_SEP_VAL + 1;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               V_ERR_MSG :=
                     T_FIELD_DESC_STRING (J)
                  || ' shoud be a'
                  || ' '
                  || V_DATA_TYPE;
         END;

         IF V_ERR_MSG IS NOT NULL
         THEN
            EXIT;
         END IF;
      END LOOP;
   END VALIDATE_DATA_TYPES;

   -----------------------------------------------------------------------------------------------------
   PROCEDURE INSERT_LOG
   IS
   BEGIN
      IF V_ERR_MSG IS NULL
      THEN
         INSERT INTO DATACTRLOG (DATACTRLOG_ID,
                                 DATACTRLOG_CBD,
                                 DATACTRLOG_OLD_DATA,
                                 DATACTRLOG_NEW_DATA,
                                 DATACTRLOG_DATA_FOR,
                                 DATACTRLOG_REMARKS,
                                 DATACTRLOG_ENTD_BY,
                                 DATACTRLOG_ENTD_ON,
                                 DATACTRLOG_QRY_DATA)
              VALUES (V_QRY_UPD_CODE,
                      V_CBD,
                      V_OLD_DATA,
                      V_NEW_DATA,
                      V_UPD_FIELD_DESC,
                      V_REMARKS,
                      V_ENTD_BY,
                      V_ENTD_ON,
                      T_CTR_STRING (1));

         COMMIT;
      ELSE
         ROLLBACK;
      END IF;
   END INSERT_LOG;
   ----------------------------------UPDATE FOR ETFTRAN TEXT FILE GENERATION -----------------------------------------------
  PROCEDURE UPDATE_ETFTRAN_TXT_FILE_GEN IS
  
   BEGIN
    IF (T_OLD_DATA_STRING(1) = T_NEW_DATA_STRING(1)) THEN
      V_ERR_MSG := 'DATA ALREADY EXIST';
    END IF;
     BEGIN
      IF V_ERR_MSG IS NULL THEN
        BEGIN
          PKG_TF_SUPPORT.SP_TFTRANTEXTFILEGEN(PKG_ENTITY.FN_GET_ENTITY_CODE,
                                              T_OLD_DATA_STRING(2),
                                              TO_DATE(T_OLD_DATA_STRING(3), V_DATE_FMT),
                                              T_OLD_DATA_STRING(4),
                                              T_NEW_DATA_STRING(1),
                                              V_ERR_MSG);
        EXCEPTION
          WHEN OTHERS THEN
            V_ERR_MSG := 'ERRON IN UPDATE_ETFTRAN_TXT_FILE_GEN' || ' ' || SQLERRM;
     END;
     END IF;
    END;
   END UPDATE_ETFTRAN_TXT_FILE_GEN;
   
   PROCEDURE UPDATE_ETRAN_TO_ETFTRAN IS
   BEGIN
     BEGIN
       PKG_TF_SUPPORT.SP_TRANTOTFTRANTRANSFER(PKG_ENTITY.FN_GET_ENTITY_CODE,
                                              T_OLD_DATA_STRING(1),
                                              T_OLD_DATA_STRING(2),
                                              T_OLD_DATA_STRING(3),
                                              T_OLD_DATA_STRING(5),
                                              TO_DATE(T_OLD_DATA_STRING(6), V_DATE_TIME_FMT),
                                              T_OLD_DATA_STRING(7),
                                              TO_DATE(T_OLD_DATA_STRING(8), V_DATE_TIME_FMT),
                                              T_NEW_DATA_STRING(1),
                                              T_NEW_DATA_STRING(2),
                                              UPPER(T_NEW_DATA_STRING(3)),
                                              T_NEW_DATA_STRING(4),
                                              T_NEW_DATA_STRING(5),
                                              TO_DATE(T_NEW_DATA_STRING(6), V_DATE_FMT),
                                              V_ERR_MSG);
       EXCEPTION
       WHEN OTHERS THEN
         V_ERR_MSG := 'ERROR IN UPDATE_ETRAN_TO_ETFTRAN' || ' ' || SQLERRM;
     END;
   END UPDATE_ETRAN_TO_ETFTRAN;
   ------------------------------------UPDATE BTB EXISTING EXPROT LC OR ORDER---------------------------
   PROCEDURE UPDATE_BTB_EXISTING_EXPLCORDER IS
     V_EXPORTLCORD_STATUS CHAR(1);
   BEGIN
     BEGIN
       IF ((T_OLD_DATA_STRING(5) = T_NEW_DATA_STRING(1)) AND (T_OLD_DATA_STRING(6) = T_NEW_DATA_STRING(2)) AND
          (T_OLD_DATA_STRING(7) = T_NEW_DATA_STRING(3)) AND (T_OLD_DATA_STRING(8) = T_NEW_DATA_STRING(4))) THEN
         V_ERR_MSG := 'EXPORT LC/ORDER ALREDY EXISTED';
       ELSE
         IF UPPER(T_NEW_DATA_STRING(5)) = 'LC' THEN
           V_EXPORTLCORD_STATUS := 'L';
         ELSIF UPPER(T_NEW_DATA_STRING(5)) = 'ORDER' THEN
           V_EXPORTLCORD_STATUS := 'O';
         END IF;
       END IF;
       IF V_ERR_MSG IS NULL THEN
         BEGIN
           PKG_TF_SUPPORT.SP_BTBEXPORDCHANGE(PKG_ENTITY.FN_GET_ENTITY_CODE,
                                             T_OLD_DATA_STRING(1),
                                             T_OLD_DATA_STRING(2),
                                             T_OLD_DATA_STRING(3),
                                             T_OLD_DATA_STRING(4),
                                             T_NEW_DATA_STRING(1),
                                             T_NEW_DATA_STRING(2),
                                             T_NEW_DATA_STRING(3),
                                             T_NEW_DATA_STRING(4),
                                             V_EXPORTLCORD_STATUS,
                                             V_ERR_MSG);
         EXCEPTION
           WHEN OTHERS THEN
             V_ERR_MSG := 'ERRON IN UPDATE_BTB_EXISTING_EXPLCORDER' || ' ' || SQLERRM;
         END;
       END IF;
     END;
   END UPDATE_BTB_EXISTING_EXPLCORDER;
   PROCEDURE UPDATE_EXPLC_VARIANCE_AMT IS
   BEGIN
     PKG_TF_SUPPORT.SP_EXTOLERENCE(PKG_ENTITY.FN_GET_ENTITY_CODE,
                                   T_OLD_DATA_STRING(1),
                                   T_OLD_DATA_STRING(2),
                                   T_OLD_DATA_STRING(3),
                                   T_OLD_DATA_STRING(4),
                                   T_NEW_DATA_STRING(1),
                                   T_NEW_DATA_STRING(2),
                                   V_ERR_MSG);
   EXCEPTION
     WHEN OTHERS THEN
       V_ERR_MSG := 'ERRON IN UPDATE_EXPLC_VARIANCE_AMT' || ' ' || SQLERRM;
   END UPDATE_EXPLC_VARIANCE_AMT;
   PROCEDURE UPDATE_BTB_PAYMENT_INCURR IS
   BEGIN
     PKG_TF_SUPPORT.SP_BTBPAYINCURR(PKG_ENTITY.FN_GET_ENTITY_CODE,
                                    T_OLD_DATA_STRING(1),
                                    T_OLD_DATA_STRING(2),
                                    T_OLD_DATA_STRING(3),
                                    T_OLD_DATA_STRING(4),
                                    T_NEW_DATA_STRING(1),
                                    V_ERR_MSG);
   EXCEPTION
     WHEN OTHERS THEN
       V_ERR_MSG := 'ERRON IN UPDATE_EXPLC_VARIANCE_AMT' || ' ' || SQLERRM;
   END UPDATE_BTB_PAYMENT_INCURR;
  PROCEDURE UPDATE_LCAF_DATA_OLC IS
  BEGIN
    IF ((T_OLD_DATA_STRING(5) = T_NEW_DATA_STRING(1)) AND (T_OLD_DATA_STRING(6) = T_NEW_DATA_STRING(2))) THEN
      V_ERR_MSG := 'DATA ALREADY EXISTED';
    END IF;
    BEGIN
      IF V_ERR_MSG IS NULL THEN
        BEGIN
          PKG_TF_SUPPORT.SP_OLCLCAFDATECHANGE(PKG_ENTITY.FN_GET_ENTITY_CODE,
                                              T_OLD_DATA_STRING(1),
                                              T_OLD_DATA_STRING(2),
                                              T_OLD_DATA_STRING(3),
                                              T_OLD_DATA_STRING(4),
                                              T_NEW_DATA_STRING(1),
                                              TO_DATE(T_NEW_DATA_STRING(2), V_DATE_FMT),
                                              V_ERR_MSG);
        EXCEPTION
          WHEN OTHERS THEN
            V_ERR_MSG := 'ERRON IN UPDATE_LCAF_DATA_OLC' || ' ' || SQLERRM;
        END;
      END IF;
    END;
  END UPDATE_LCAF_DATA_OLC;
   ------------------------------------ UPDATE Repayment Schedule----------------------------------------------------------
   PROCEDURE UPDATE_REPAYMENT_SCH
   IS
      V_INTERNAL_ACNUM     NUMBER (14);
      V_LIMIT_SANC_DATE    DATE;
      V_LIMIT_SANC_AMT     NUMBER (18, 3);
      V_LIMIT_EXP_DATE     DATE;
      V_REPAY_START_DATE   DATE;
      V_REPAY_END_DATE     DATE;
      V_REPAY_FREQ         VARCHAR2 (50);
      V_REPAY_SIZE         NUMBER (18, 3);
      V_NOI                NUMBER (3);
      V_TOT_AMT            NUMBER (18, 3);
   BEGIN
      V_REPAY_START_DATE := TO_DATE (T_NEW_DATA_STRING (1), V_DATE_FMT);
      V_NOI := TO_NUMBER (T_NEW_DATA_STRING (2));
      V_REPAY_FREQ := UPPER (T_NEW_DATA_STRING (3));
      V_REPAY_SIZE := TO_NUMBER (T_NEW_DATA_STRING (4));

      IF V_REPAY_FREQ NOT IN ('M',
                              'Q',
                              'H',
                              'Y',
                              'X')
      THEN
         V_ERR_MSG := 'Repayment Frequency should be any of M,Q,H,Y,X.';
         RETURN;
      END IF;

      SELECT IACLINK_INTERNAL_ACNUM
        INTO V_INTERNAL_ACNUM
        FROM IACLINK
       WHERE IACLINK_ACTUAL_ACNUM = T_CTR_STRING (1);

      BEGIN
         SELECT LMTLINE_LIMIT_EXPIRY_DATE,
                L.LMTLINE_DATE_OF_SANCTION,
                L.LMTLINE_SANCTION_AMT
           INTO V_LIMIT_EXP_DATE, V_LIMIT_SANC_DATE, V_LIMIT_SANC_AMT
           FROM ACASLLDTL A, LIMITLINE L
          WHERE     A.ACASLLDTL_ENTITY_NUM = 1
                AND L.LMTLINE_ENTITY_NUM = 1
                AND A.ACASLLDTL_INTERNAL_ACNUM = V_INTERNAL_ACNUM
                AND A.ACASLLDTL_CLIENT_NUM = L.LMTLINE_CLIENT_CODE
                AND A.ACASLLDTL_LIMIT_LINE_NUM = L.LMTLINE_NUM;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            V_ERR_MSG := 'Limit Details not Found.';
            RETURN;
      END;

      IF ( (V_REPAY_FREQ = 'X') AND (V_REPAY_START_DATE <> V_LIMIT_EXP_DATE))
      THEN
         V_ERR_MSG :=
            'For On-Closure, Repayment start date should be the Expiry date.';
         RETURN;
      END IF;

      IF V_REPAY_START_DATE <= V_LIMIT_SANC_DATE
      THEN
         V_ERR_MSG :=
            'Repayment start date should be greater than Sanction date.';
         RETURN;
      END IF;

      IF V_REPAY_SIZE < 0 OR V_REPAY_SIZE > V_LIMIT_SANC_AMT
      THEN
         V_ERR_MSG :=
            'Repayment Size Could not be Negative or greater than Sanction amount.';
         RETURN;
      END IF;

      V_TOT_AMT := V_NOI * V_REPAY_SIZE;

      IF V_TOT_AMT < V_LIMIT_SANC_AMT
      THEN
         V_ERR_MSG :=
            'Total Repayment amount should not be Less than Sanction amount.';
         RETURN;
      END IF;

      IF V_TOT_AMT >= (V_LIMIT_SANC_AMT * 3)
      THEN
         V_ERR_MSG :=
            'Total Repayment amount should not triplate of Sanction amount.';
         RETURN;
      END IF;

      IF (V_REPAY_FREQ = 'M')
      THEN
         V_REPAY_END_DATE :=
            ADD_MONTHS (V_REPAY_START_DATE, (1 * (V_NOI - 1)));
      ELSIF (V_REPAY_FREQ = 'Q')
      THEN
         V_REPAY_END_DATE :=
            ADD_MONTHS (V_REPAY_START_DATE, (3 * (V_NOI - 1)));
      ELSIF (V_REPAY_FREQ = 'H')
      THEN
         V_REPAY_END_DATE :=
            ADD_MONTHS (V_REPAY_START_DATE, (6 * (V_NOI - 1)));
      ELSIF (V_REPAY_FREQ = 'Y')
      THEN
         V_REPAY_END_DATE :=
            ADD_MONTHS (V_REPAY_START_DATE, (12 * (V_NOI - 1)));
      ELSIF (V_REPAY_FREQ = 'X')
      THEN
         V_REPAY_END_DATE := V_LIMIT_EXP_DATE;
      END IF;

      IF V_REPAY_END_DATE > V_LIMIT_EXP_DATE
      THEN
         V_ERR_MSG :=
               'Repayment end date becomes greater than Limit Expiry Date ('
            || V_LIMIT_EXP_DATE
            || ')';
         RETURN;
      END IF;

      UPDATE LNACRSDTL
         SET LNACRSDTL_REPAY_FROM_DATE = V_REPAY_START_DATE,
             LNACRSDTL_NUM_OF_INSTALLMENT = V_NOI,
             LNACRSDTL_REPAY_FREQ = V_REPAY_FREQ,
             LNACRSDTL_REPAY_AMT = V_REPAY_SIZE,
             LNACRSDTL_TOT_REPAY_AMT = V_TOT_AMT,
             LNACRSDTL_LIMIT_EXP_DATE = V_REPAY_END_DATE
       WHERE     LNACRSDTL_ENTITY_NUM = 1
             AND LNACRSDTL_INTERNAL_ACNUM = V_INTERNAL_ACNUM;

      UPDATE LNACRSHDTL
         SET LNACRSHDTL_REPAY_FROM_DATE = V_REPAY_START_DATE,
             LNACRSHDTL_NUM_OF_INSTALLMENT = V_NOI,
             LNACRSHDTL_REPAY_AMT = V_REPAY_SIZE,
             LNACRSHDTL_REPAY_FREQ = V_REPAY_FREQ,
             LNACRSHDTL_TOT_REPAY_AMT = V_TOT_AMT,
             LNACRSHDTL_LIMIT_EXP_DATE = V_REPAY_END_DATE
       WHERE     LNACRSHDTL_ENTITY_NUM = 1
             AND LNACRSHDTL_INTERNAL_ACNUM = V_INTERNAL_ACNUM
             AND LNACRSHDTL_EFF_DATE =
                    (SELECT MAX (LNACRSHDTL_EFF_DATE)
                       FROM LNACRSHDTL L
                      WHERE L.LNACRSHDTL_INTERNAL_ACNUM = V_INTERNAL_ACNUM);
   END UPDATE_REPAYMENT_SCH;

   ----------------------------------- UPDATE Expiry Date ----------------------------------------------------------------
   PROCEDURE UPDATE_EXPIRY_DATE
   IS
      V_INTERNAL_ACNUM    NUMBER (14);
      V_LIMIT_SANC_DATE   DATE;
      V_LIMIT_EXP_DATE    DATE;
      V_CLIENT_CODE       NUMBER (12);
      V_LIMIT_LINE        NUMBER (6);
   BEGIN
      V_LIMIT_EXP_DATE := TO_DATE (T_NEW_DATA_STRING (1), V_DATE_FMT);

      SELECT IACLINK_INTERNAL_ACNUM
        INTO V_INTERNAL_ACNUM
        FROM IACLINK
       WHERE IACLINK_ACTUAL_ACNUM = T_CTR_STRING (1);

      BEGIN
         SELECT L.LMTLINE_DATE_OF_SANCTION,
                A.ACASLLDTL_CLIENT_NUM,
                A.ACASLLDTL_LIMIT_LINE_NUM
           INTO V_LIMIT_SANC_DATE, V_CLIENT_CODE, V_LIMIT_LINE
           FROM ACASLLDTL A, LIMITLINE L
          WHERE     A.ACASLLDTL_ENTITY_NUM = 1
                AND L.LMTLINE_ENTITY_NUM = 1
                AND A.ACASLLDTL_INTERNAL_ACNUM = V_INTERNAL_ACNUM
                AND A.ACASLLDTL_CLIENT_NUM = L.LMTLINE_CLIENT_CODE
                AND A.ACASLLDTL_LIMIT_LINE_NUM = L.LMTLINE_NUM;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            V_ERR_MSG := 'Limit Details not Found.';
            RETURN;
      END;

      IF V_LIMIT_EXP_DATE <= V_LIMIT_SANC_DATE
      THEN
         V_ERR_MSG :=
               'Expiry Date should be greater than Sanction Date ('
            || V_LIMIT_SANC_DATE
            || ')';
         RETURN;
      END IF;

      UPDATE LIMITLINE
         SET LIMITLINE.LMTLINE_LIMIT_EXPIRY_DATE = V_LIMIT_EXP_DATE
       WHERE     LIMITLINE.LMTLINE_ENTITY_NUM = 1
             AND LIMITLINE.LMTLINE_CLIENT_CODE = V_CLIENT_CODE
             AND LIMITLINE.LMTLINE_NUM = V_LIMIT_LINE;

      UPDATE LIMITLINEHIST L
         SET L.LIMLNEHIST_LIMIT_EXPIRY_DATE = V_LIMIT_EXP_DATE
       WHERE     L.LIMLNEHIST_ENTITY_NUM = 1
             AND L.LIMLNEHIST_CLIENT_CODE = V_CLIENT_CODE
             AND L.LIMLNEHIST_LIMIT_LINE_NUM = V_LIMIT_LINE
             AND L.LIMLNEHIST_EFF_DATE =
                    (SELECT MAX (L.LIMLNEHIST_EFF_DATE)
                       FROM LIMITLINEHIST L
                      WHERE     L.LIMLNEHIST_ENTITY_NUM = 1
                            AND L.LIMLNEHIST_CLIENT_CODE = V_CLIENT_CODE
                            AND L.LIMLNEHIST_LIMIT_LINE_NUM = V_LIMIT_LINE);
   END UPDATE_EXPIRY_DATE;

   --------------------------------------------interest recalculation---------------------------
   PROCEDURE UPDATE_LNACIRECAL_ACC
   IS
      V_ENTITY_NUM          NUMBER;
      V_RECALC_START_DATE   DATE;
      V_ACC_NO              VARCHAR2 (14);
      V_UPTO_DATE           DATE;
      V_UPTO_DT             VARCHAR2 (15);
      CBD                   DATE;
      CBD_STR               VARCHAR2 (15);
      P_ERROR_MSG           VARCHAR2 (1300);
      V_IA_DATE             DATE;
      V_PROD_CODE           NUMBER (4);
      V_CUR_CODE            VARCHAR2 (3);
      V_AC_OPEN_DATE        DATE;
   BEGIN
      V_ENTITY_NUM := 1;
      V_ACC_NO := V_QUERY_STR;
      V_RECALC_START_DATE := TO_DATE (T_NEW_DATA_STRING (1), 'DD-MM-YYYY');
      CBD := PKG_PB_GLOBAL.FN_GET_CURR_BUS_DATE (1);
      P_ERROR_MSG := '';
      V_ERR_MSG := '';
      V_AC_OPEN_DATE := TO_DATE (T_OLD_DATA_STRING (1), 'DD-MM-YYYY');
      V_IA_DATE := TO_DATE (T_OLD_DATA_STRING (3), 'DD-MM-YYYY');
      V_PROD_CODE := T_OLD_DATA_STRING (5);
      V_CUR_CODE := T_OLD_DATA_STRING (6);



      --      SELECT DECODE (SIGN (V_IA_DATE - CBD), 1, V_IA_DATE, CBD)
      --        INTO V_UPTO_DATE
      --        FROM (SELECT V_IA_DATE + 1 AS V_IA_DATE,
      --                     PKG_LN_RPT_UTILITY.GET_QUARTER_FIRST_DATE (CBD) AS CBD
      --                FROM DUAL);


      IF V_RECALC_START_DATE < V_UPTO_DATE
      THEN
         SELECT TO_CHAR (V_UPTO_DATE, 'DD/MM/YYYY') INTO V_UPTO_DT FROM DUAL;

         V_ERR_MSG := 'Date Should be greater than equal to ' || V_UPTO_DT;
         RETURN;
      END IF;


      IF V_RECALC_START_DATE > CBD
      THEN
         SELECT TO_CHAR (CBD, 'DD/MM/YYYY') INTO CBD_STR FROM DUAL;

         V_ERR_MSG := 'Date Should be less than equal to ' || CBD_STR;
         RETURN;
      END IF;



      PKG_LN_UTILITY.UPDATE_LNACIRECAL_INDV_ACC (V_ENTITY_NUM,
                                                 V_ENTD_BY,
                                                 V_BRN_CODE,
                                                 V_ACC_NO,
                                                 V_PROD_CODE,
                                                 V_CUR_CODE,
                                                 V_AC_OPEN_DATE,
                                                 V_RECALC_START_DATE,
                                                 P_ERROR_MSG);

      IF TRIM (P_ERROR_MSG) IS NOT NULL
      THEN
         V_ERR_MSG := P_ERROR_MSG;
         RETURN;
      END IF;
   END UPDATE_LNACIRECAL_ACC;

   -----------------------------------------------------------------------------------------------------

   ---------------product code change added by sabuj----------------------------------------
   PROCEDURE PRODUCT_CODE_CHANGE
   IS
      V_BRANCH_CODE              NUMBER;
      V_INTERNAL_ACNUM           NUMBER (14);
      V_PREV_PRD_CODE            NUMBER;
      V_PREV_ACC_TYPE            VARCHAR2 (10);
      V_PREV_AC_SUB_TYPE         VARCHAR2 (10);
      V_NEW_PRD_CODE             NUMBER;
      V_NEW_ACC_TYPE             VARCHAR2 (10);
      V_NEW_AC_SUB_TYPE          VARCHAR2 (10);
      V_BATCH_NUMBER             NUMBER;
      V_BALANCE_TRANSFER_BATCH   NUMBER;                       -- BATCH NUMBER
      V_PREVIOUS_ACCRUAL_BATCH   NUMBER;                       -- BATCH NUMBER
      V_NEW_ACCRUAL_BATCH        NUMBER;
      V_PRODUCT_TYPE             VARCHAR2 (10) := '0';
      V_LOAN_TYPE                VARCHAR2 (10) := '0';
      V_NARRATION                VARCHAR2 (1000) := 'Product code change';
      V_ERROR_MSG                VARCHAR2 (1000);
      V_EFFECTIVE_DATE           DATE;
   BEGIN
      BEGIN
         SELECT IACLINK_BRN_CODE BRANCH_CODE,
                ACNTS_INTERNAL_ACNUM,
                A.ACNTS_PROD_CODE,
                A.ACNTS_AC_TYPE,
                A.ACNTS_AC_SUB_TYPE,
                PRODUCT_FOR_LOANS,
                PRODUCT_FOR_RUN_ACS
           INTO V_BRANCH_CODE,
                V_INTERNAL_ACNUM,
                V_PREV_PRD_CODE,
                V_PREV_ACC_TYPE,
                V_PREV_AC_SUB_TYPE,
                V_PRODUCT_TYPE,
                V_LOAN_TYPE
           FROM PRODUCTS, IACLINK I, ACNTS A
          WHERE     ACNTS_ENTITY_NUM = 1
                AND I.IACLINK_INTERNAL_ACNUM = A.ACNTS_INTERNAL_ACNUM
                AND PRODUCT_CODE = ACNTS_PROD_CODE
                AND I.IACLINK_ENTITY_NUM = A.ACNTS_ENTITY_NUM
                AND I.IACLINK_ACTUAL_ACNUM = T_CTR_STRING (1);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            V_ERR_MSG := 'Account info not found';
            RETURN;
      END;


      BEGIN
         V_NEW_PRD_CODE := T_NEW_DATA_STRING (1);
         V_NEW_ACC_TYPE := T_NEW_DATA_STRING (2);
         V_NEW_AC_SUB_TYPE := T_NEW_DATA_STRING (3);
         V_EFFECTIVE_DATE := TO_DATE (T_NEW_DATA_STRING (4), 'DD-MM-YYYY');

         IF V_PRODUCT_TYPE = '1'
         THEN
            SP_PRODUCT_CODE_CHANGE (V_BRANCH_CODE,
                                    T_CTR_STRING (1),                       --
                                    V_PREV_ACC_TYPE,                        --
                                    V_NEW_ACC_TYPE,                         --
                                    V_PREV_AC_SUB_TYPE,                     --
                                    V_NEW_AC_SUB_TYPE,                      --
                                    V_PREV_PRD_CODE,                        --
                                    V_NEW_PRD_CODE,                         --
                                    V_NARRATION,
                                    V_BALANCE_TRANSFER_BATCH,               --
                                    V_PREVIOUS_ACCRUAL_BATCH,               --
                                    V_NEW_ACCRUAL_BATCH,
                                    V_ERR_MSG                               --
                                             );
         ELSE
            SP_PRODUCT_CODE_CHANGE_DEP (V_BRANCH_CODE,
                                        T_CTR_STRING (1),                   --
                                        V_PREV_ACC_TYPE,                    --
                                        V_NEW_ACC_TYPE,                     --
                                        V_PREV_AC_SUB_TYPE,                 --
                                        V_NEW_AC_SUB_TYPE,                  --
                                        V_PREV_PRD_CODE,                    --
                                        V_NEW_PRD_CODE,                     --
                                        V_EFFECTIVE_DATE,
                                        V_NARRATION,
                                        V_BALANCE_TRANSFER_BATCH,           --
                                        V_PREVIOUS_ACCRUAL_BATCH,           --
                                        V_NEW_ACCRUAL_BATCH,
                                        V_ERR_MSG                           --
                                                 );
         END IF;

         IF V_LOAN_TYPE = '1' AND V_PRODUCT_TYPE = '1'
         THEN
            V_SHOW_MSG :=
               'Please update repayment reschedule by EDATACORRECTOR';
         END IF;
      END;
   EXCEPTION
      WHEN OTHERS
      THEN
         V_ERR_MSG :=
               'Error in product code change  '
            || V_ERROR_MSG
            || ' '
            || SQLERRM
            || ' '
            || SQLCODE;
   END PRODUCT_CODE_CHANGE;

   ---Branch signin added by sabuj----------------------
   PROCEDURE SP_BRANCH_SIGNIN
   IS
      V_BRANCH_CODE       NUMBER;
      V_NEW_BRANCH_CODE   NUMBER;
      V_BRANCH_STATUS     NUMBER;
   BEGIN
      W_CBD := PKG_PB_GLOBAL.FN_GET_CURR_BUS_DATE (1);

      V_NEW_BRANCH_CODE := T_CTR_STRING (1);
      V_GLOB_ENTITY_NUM := 1;

      SELECT COUNT (*)
        INTO V_BRANCH_CODE
        FROM MBRN
       WHERE MBRN_CODE = V_NEW_BRANCH_CODE;

      SELECT COUNT (*)
        INTO V_BRANCH_STATUS
        FROM BRNSTATUS
       WHERE     BRNSTATUS_ENTITY_NUM = V_GLOB_ENTITY_NUM
             AND BRNSTATUS_BRN_CODE = V_NEW_BRANCH_CODE
             AND BRNSTATUS_CURR_DATE = W_CBD
             AND BRNSTATUS_STATUS = 'I';

      IF V_BRANCH_CODE = 0
      THEN
         V_ERR_MSG := 'Invalid Branch Code';
      ELSIF V_BRANCH_STATUS > 0
      THEN
         V_ERR_MSG := 'Branch Already Signin';
         RETURN;
      END IF;

      UPDATE BRNSTATUS
         SET BRNSTATUS_STATUS = 'I',
             BRNSTATUS_SIGN_OUT = NULL,
             BRNSTATUS_SIGNOUT_USER_ID = NULL
       WHERE     BRNSTATUS_BRN_CODE = V_NEW_BRANCH_CODE
             AND BRNSTATUS_CURR_DATE = W_CBD;
   EXCEPTION
      WHEN OTHERS
      THEN
         V_ERR_MSG := 'Error in SP_BRANCH_SIGNIN';
         RETURN;
   END SP_BRANCH_SIGNIN;


   ---Branch Cash open added by sabuj----------------------
   PROCEDURE SP_CASH_SIGNIN
   IS
      V_BRANCH_CODE       NUMBER;
      V_NEW_BRANCH_CODE   NUMBER;
      V_BRANCH_STATUS     NUMBER;
   BEGIN
      W_CBD := PKG_PB_GLOBAL.FN_GET_CURR_BUS_DATE (1);

      V_NEW_BRANCH_CODE := T_NEW_DATA_STRING (1);
      V_GLOB_ENTITY_NUM := 1;

      SELECT COUNT (*)
        INTO V_BRANCH_CODE
        FROM MBRN
       WHERE MBRN_CODE = V_NEW_BRANCH_CODE;

      SELECT COUNT (*)
        INTO V_BRANCH_STATUS
        FROM CASHCTL
       WHERE     CASHCTL_ENTITY_NUM = V_GLOB_ENTITY_NUM
             AND CASHCTL_BRN_CODE = V_NEW_BRANCH_CODE
             AND CASHCTL_DATE = W_CBD
             AND  CASHCTL_STATUS = 'O' and  CASHCTL_CLOSING_INIT_BY IS NULL;

      IF V_BRANCH_CODE = 0
      THEN
         V_ERR_MSG := 'Invalid Branch Code';
      ELSIF V_BRANCH_STATUS > 0
      THEN
         V_ERR_MSG := 'Cash Already Open';
         RETURN;
      END IF;

      UPDATE CASHCTL
         SET CASHCTL_STATUS = 'O',
             CASHCTL_CLOSING_INIT_FLAG = 0,
             CASHCTL_CLOSING_INIT_BY = NULL,
             CASHCTL_CLOSING_INT_ON = NULL,
             CASHCTL_CLOSED_BY = NULL,
             CASHCTL_CLOSED_ON = NULL
       WHERE     CASHCTL_ENTITY_NUM = V_GLOB_ENTITY_NUM
             AND CASHCTL_BRN_CODE = V_NEW_BRANCH_CODE
             AND CASHCTL_DATE = W_CBD;
   EXCEPTION
      WHEN OTHERS
      THEN
         V_ERR_MSG := 'Error in SP_CASH_SIGNIN';
         RETURN;
   END SP_CASH_SIGNIN;

   -----------Teller Signin Added by Sabuj--------------------
   PROCEDURE SP_TELLER_SIGNIN
   IS
      V_BRANCH_CODE       NUMBER;
      V_NEW_BRANCH_CODE   NUMBER;
      V_TELLER_STATUS     NUMBER;
      V_TELLER_ID         VARCHAR2 (10);
      V_TELLER_COUNT      NUMBER;
   BEGIN
      W_CBD := PKG_PB_GLOBAL.FN_GET_CURR_BUS_DATE (1);

      V_NEW_BRANCH_CODE := T_NEW_DATA_STRING (1);
      V_TELLER_ID := T_NEW_DATA_STRING (2);
      V_GLOB_ENTITY_NUM := 1;

      SELECT COUNT (*)
        INTO V_BRANCH_CODE
        FROM MBRN
       WHERE MBRN_CODE = V_NEW_BRANCH_CODE;

      SELECT COUNT (*)
        INTO V_TELLER_COUNT
        FROM USERS
       WHERE USER_ID = V_TELLER_ID AND USER_BRANCH_CODE = V_NEW_BRANCH_CODE;

      SELECT COUNT (*)
        INTO V_TELLER_STATUS
        FROM CASHSIGNINOUT
       WHERE     CASHSIGN_DATE = W_CBD
             AND CASHSIGN_USER_ID = V_TELLER_ID
             AND CASHSIGN_SIGNED_OUT = 0
             AND CASHSIGN_BRN_CODE = V_NEW_BRANCH_CODE
             AND CASHSIGN_SIGNOUT_DATE_TIME IS NULL;


      IF V_BRANCH_CODE = 0
      THEN
         V_ERR_MSG := 'Invalid Branch Code';
         RETURN;
      ELSIF V_TELLER_COUNT = 0
      THEN
         V_ERR_MSG := 'Invalid Teller ID';
         RETURN;
      ELSIF V_TELLER_STATUS = 1
      THEN
         V_ERR_MSG := 'Teller ID Already Signin';
         RETURN;
      END IF;

      UPDATE CASHSIGNINOUT
         SET CASHSIGN_SIGNED_OUT = 0, CASHSIGN_SIGNOUT_DATE_TIME = NULL
       WHERE     CASHSIGN_DATE = W_CBD
             AND CASHSIGN_USER_ID = V_TELLER_ID
             AND CASHSIGN_BRN_CODE = V_NEW_BRANCH_CODE;

      UPDATE CASHSIGNPOS
         SET CASHSIGNPOS_STATUS = 1
       WHERE     CASHSIGNPOS_DATE = W_CBD
             AND CASHSIGNPOS_BRN_CODE = V_NEW_BRANCH_CODE
             AND CASHSIGNPOS_USER_ID = V_TELLER_ID;
   EXCEPTION
      WHEN OTHERS
      THEN
         V_ERR_MSG := 'Error in SP_TELLER_SIGNIN';
         RETURN;
   END SP_TELLER_SIGNIN;

   ---------Clients ID change added by Sabuj----------------
   PROCEDURE SP_CLIENTS_CHANGE
   IS
      V_BRANCH_CODE           NUMBER;
      V_ACTUAL_ACNUM          VARCHAR2 (14);
      V_CURRENT_CLIENT_CODE   NUMBER (14);
      V_NEW_CLIENT_CODE       NUMBER (14);
      V_PRODUCT_FOR_LOANS     NUMBER;
   BEGIN
      V_ACTUAL_ACNUM := T_CTR_STRING (1);
      V_NEW_CLIENT_CODE := T_CTR_STRING (2);
      V_GLOB_ENTITY_NUM := 1;

      BEGIN
         SELECT IACLINK_ACTUAL_ACNUM, IACLINK_CIF_NUMBER, PRODUCT_FOR_LOANS
           INTO V_ACTUAL_ACNUM, V_CURRENT_CLIENT_CODE, V_PRODUCT_FOR_LOANS
           FROM IACLINK, PRODUCTS
          WHERE     IACLINK_ENTITY_NUM = V_GLOB_ENTITY_NUM
                AND PRODUCT_CODE = IACLINK_PROD_CODE
                AND IACLINK_ACTUAL_ACNUM = V_ACTUAL_ACNUM;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            V_ERR_MSG := 'Inavalid Account';
      END;

      V_ACTUAL_ACNUM := T_NEW_DATA_STRING (1);
      V_NEW_CLIENT_CODE := T_NEW_DATA_STRING (2);

      IF V_PRODUCT_FOR_LOANS = '1'
      THEN
         SP_LOAN_CLIENT_CODE_CHANGE (V_ACTUAL_ACNUM,
                                     V_CURRENT_CLIENT_CODE,
                                     V_NEW_CLIENT_CODE);
      ELSE
         SP_SAVINGS_CLIENT_CODE_CHANGE (V_ACTUAL_ACNUM,
                                        V_CURRENT_CLIENT_CODE,
                                        V_NEW_CLIENT_CODE);
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         V_ERR_MSG := 'Error in SP_CLIENTS_CHANGE';
   END SP_CLIENTS_CHANGE;

   -----------Batch Narration Update Added by Sabuj--------------------
   PROCEDURE SP_BATCH_NARRATION_UPDATE
   IS
      V_BRANCH_CODE      NUMBER;
      V_BATCH_NO         NUMBER;
      V_NEW_NARRATION1   VARCHAR2 (35);
      V_NEW_NARRATION2   VARCHAR2 (35);
      V_NEW_NARRATION3   VARCHAR2 (35);
      V_BATCH_COUNT      NUMBER;
      V_BRANCH_COUNT     NUMBER;
      W_FIN_YEAR         NUMBER := 0;
      W_SQL_TRAN         VARCHAR2 (3000);
      W_SQL_TRANBAT      VARCHAR2 (3000);
   BEGIN
      W_CBD := PKG_PB_GLOBAL.FN_GET_CURR_BUS_DATE (1);

      V_BRANCH_CODE := T_CTR_STRING (1);
      V_BATCH_NO := T_CTR_STRING (2);
      V_NEW_NARRATION1 := SUBSTR (T_NEW_DATA_STRING (1), 1, 35);
      V_NEW_NARRATION2 := SUBSTR (T_NEW_DATA_STRING (1), 36, 35);
      V_NEW_NARRATION3 := SUBSTR (T_NEW_DATA_STRING (1), 71, 35);
      V_GLOB_ENTITY_NUM := 1;
      W_FIN_YEAR :=
         SP_GETFINYEAR (
            V_GLOB_ENTITY_NUM,
            PKG_PB_GLOBAL.FN_GET_CURR_BUS_DATE (V_GLOB_ENTITY_NUM));

      SELECT COUNT (*)
        INTO V_BRANCH_COUNT
        FROM MBRN
       WHERE MBRN_CODE = V_BRANCH_CODE;

      SELECT BOPAUTHQ_TRAN_BATCH_NUMBER
        INTO V_BATCH_COUNT
        FROM bopauthq
       WHERE     BOPAUTHQ_ENTITY_NUM = V_GLOB_ENTITY_NUM
             AND BOPAUTHQ_TRAN_DATE_OF_TRAN = W_CBD
             AND BOPAUTHQ_TRAN_BRN_CODE = V_BRANCH_CODE
             AND BOPAUTHQ_TRAN_BATCH_NUMBER = V_BATCH_NO;

      IF V_BRANCH_COUNT = 0
      THEN
         V_ERR_MSG := 'Invalid Branch Code';
         RETURN;
      ELSIF V_BATCH_COUNT = 0
      THEN
         V_ERR_MSG := 'Invalid Batch';
         RETURN;
      END IF;

      UPDATE bopauthq
         SET BOPAUTHQ_TRANBAT_NARR1 = V_NEW_NARRATION1,
             BOPAUTHQ_TRANBAT_NARR2 = V_NEW_NARRATION2,
             BOPAUTHQ_TRANBAT_NARR3 = V_NEW_NARRATION3
       WHERE     BOPAUTHQ_ENTITY_NUM = V_GLOB_ENTITY_NUM
             AND BOPAUTHQ_TRAN_DATE_OF_TRAN = W_CBD
             AND BOPAUTHQ_TRAN_BRN_CODE = V_BRANCH_CODE
             AND BOPAUTHQ_TRAN_BATCH_NUMBER = V_BATCH_NO;

      W_SQL_TRAN :=
            'UPDATE TRAN'
         || W_FIN_YEAR
         || ' SET TRAN_NARR_DTL1= '
         || ''''
         || V_NEW_NARRATION1
         || ''''
         || ',TRAN_NARR_DTL2='
         || ''''
         || V_NEW_NARRATION2
         || ''''
         || ', TRAN_NARR_DTL3='
         || ''''
         || V_NEW_NARRATION3
         || ''''
         || '
  WHERE TRAN_ENTITY_NUM = :1
AND TRAN_BRN_CODE = :2
AND TRAN_BATCH_NUMBER = :3
AND TRAN_DATE_OF_TRAN = :4';

      W_SQL_TRANBAT :=
            'UPDATE TRANBAT'
         || W_FIN_YEAR
         || ' SET TRANBAT_NARR_DTL1= '
         || ''''
         || V_NEW_NARRATION1
         || ''''
         || ',TRANBAT_NARR_DTL2='
         || ''''
         || V_NEW_NARRATION2
         || ''''
         || ', TRANBAT_NARR_DTL3='
         || ''''
         || V_NEW_NARRATION3
         || ''''
         || '
  WHERE TRANBAT_ENTITY_NUM = :1
AND TRANBAT_BRN_CODE = :2
AND TRANBAT_BATCH_NUMBER = :3
AND TRANBAT_DATE_OF_TRAN = :4';

      -- DBMS_OUTPUT.put_line ('sql1 ' || W_SQL_TRAN);
      -- DBMS_OUTPUT.put_line ('sql2 ' || W_SQL_TRANbat);

      EXECUTE IMMEDIATE W_SQL_TRAN
         USING V_GLOB_ENTITY_NUM,
               V_BRANCH_CODE,
               V_BATCH_NO,
               W_CBD;

      EXECUTE IMMEDIATE W_SQL_TRANBAT
         USING V_GLOB_ENTITY_NUM,
               V_BRANCH_CODE,
               V_BATCH_NO,
               W_CBD;
   EXCEPTION
      WHEN OTHERS
      THEN
         V_ERR_MSG := 'Error in SP_BATCH_NARRATION_UPDATE ' || SQLERRM;
         RETURN;
   END SP_BATCH_NARRATION_UPDATE;

   ----------clearing button active added by sabuj
   PROCEDURE SP_CLEARING_BUTTON_ACTIVE
   IS
      V_BRANCH_CODE       NUMBER;
      V_NEW_BRANCH_CODE   NUMBER;
      V_BRANCH_STATUS     NUMBER;
   BEGIN
      W_CBD := PKG_PB_GLOBAL.FN_GET_CURR_BUS_DATE (1);

      V_NEW_BRANCH_CODE := T_CTR_STRING (1);
      V_GLOB_ENTITY_NUM := 1;

      SELECT COUNT (*)
        INTO V_BRANCH_CODE
        FROM MBRN
       WHERE MBRN_CODE = V_NEW_BRANCH_CODE;

      SELECT COUNT (*)
        INTO V_BRANCH_STATUS
        FROM CLEARING_STATE
       WHERE     BRANCH_CODE = V_NEW_BRANCH_CODE
             AND TO_CHAR (PROCESS_DATE, 'DD-MM-YYYY') =
                    TO_CHAR (W_CBD, 'DD-MM-YYYY');

      IF V_BRANCH_CODE = 0
      THEN
         V_ERR_MSG := 'Invalid Branch Code';
      END IF;

      UPDATE CLEARING_STATE
         SET CLEARING_PROCESS_STATUS = 'PARTIALLY_POST_PROCESSED'
       WHERE BRANCH_CODE = V_NEW_BRANCH_CODE AND TRUNC (PROCESS_DATE) = W_CBD;

      V_SHOW_MSG := 'Please Login Again';
   EXCEPTION
      WHEN OTHERS
      THEN
         V_ERR_MSG := 'Error in SP_CLEARING_BUTTON_ACTIVE';
         RETURN;
   END SP_CLEARING_BUTTON_ACTIVE;

   -----RD balance segregations added by Sabuj-----------

   PROCEDURE SP_RD_BAL_SEGREGATIONS
   IS
      V_INTERNAL_ACC   NUMBER (14);
      V_ACTUAL_ACC     VARCHAR2 (20);
      V_EFF_DATE       DATE;
      V_COUNT          NUMBER;
      V_CLOSE_STATUS   NUMBER;
   BEGIN
      W_CBD := PKG_PB_GLOBAL.FN_GET_CURR_BUS_DATE (1);

      V_ACTUAL_ACC := T_CTR_STRING (1);
      V_EFF_DATE := TO_DATE (T_CTR_STRING (2), 'DD-MM-YYYY');
      V_GLOB_ENTITY_NUM := 1;

      SELECT COUNT (*)
        INTO V_COUNT
        FROM IACLINK
       WHERE     IACLINK_ENTITY_NUM = V_GLOB_ENTITY_NUM
             AND IACLINK_ACTUAL_ACNUM = V_ACTUAL_ACC;



      IF V_COUNT = 0
      THEN
         V_ERR_MSG := 'Invalid Account Number';
      END IF;

      SELECT IACLINK_INTERNAL_ACNUM
        INTO V_INTERNAL_ACC
        FROM IACLINK
       WHERE     IACLINK_ENTITY_NUM = V_GLOB_ENTITY_NUM
             AND IACLINK_ACTUAL_ACNUM = V_ACTUAL_ACC;

      SELECT COUNT (*)
        INTO V_CLOSE_STATUS
        FROM PBDCONTRACT
       WHERE     PBDCONT_ENTITY_NUM = V_GLOB_ENTITY_NUM
             AND PBDCONT_DEP_AC_NUM = V_INTERNAL_ACC
             AND PBDCONT_CLOSURE_DATE IS NOT NULL;

      IF V_CLOSE_STATUS > 0
      THEN
         V_ERR_MSG := 'Account is closed.';
         RETURN;
      END IF;

      UPDATE acnts
         SET ACNTS_OPENING_DATE = T_NEW_DATA_STRING (1)
       WHERE     ACNTS_ENTITY_NUM = V_GLOB_ENTITY_NUM
             AND ACNTS_INTERNAL_ACNUM = V_INTERNAL_ACC;

      UPDATE PBDCONTRACT
         SET PBDCONT_DEP_OPEN_DATE = T_NEW_DATA_STRING (1),
             PBDCONT_EFF_DATE = T_NEW_DATA_STRING (1),
             PBDCONT_MAT_DATE = T_NEW_DATA_STRING (2)
       WHERE     PBDCONT_ENTITY_NUM = V_GLOB_ENTITY_NUM
             AND PBDCONT_DEP_AC_NUM = V_INTERNAL_ACC;

      UPDATE RDINS
         SET RDINS_TWDS_INSTLMNT = NVL (T_NEW_DATA_STRING (3), 0),
             RDINS_TWDS_INT = NVL (T_NEW_DATA_STRING (4), 0),
             RDINS_TWDS_PENAL_CHGS = NVL (T_NEW_DATA_STRING (5), 0),
             RDINS_AMT_OF_PYMT =
                  NVL (T_NEW_DATA_STRING (1), 0)
                + NVL (T_NEW_DATA_STRING (2), 0)
                + NVL (T_NEW_DATA_STRING (3), 0),
             RDINS_REM1 = SUBSTR (V_REMARKS, 1, 35),
             RDINS_REM2 = SUBSTR (V_REMARKS, 36, 35),
             RDINS_REM3 = SUBSTR (V_REMARKS, 71, 35),
             RDINS_LAST_MOD_BY = V_ENTD_BY,
             RDINS_LAST_MOD_ON = SYSDATE
       WHERE     RDINS_RD_AC_NUM = V_INTERNAL_ACC
             AND RDINS_ENTRY_DATE = V_EFF_DATE;
   EXCEPTION
      WHEN OTHERS
      THEN
         V_ERR_MSG :=
            'Error in SP_RD_BAL_SEGREGATIONS ' || SQLCODE || ' ' || SQLERRM;
         RETURN;
   END SP_RD_BAL_SEGREGATIONS;

   PROCEDURE SP_ACCOUNT_REOPEN
   IS
      V_INTERNAL_ACC       NUMBER (14);
      V_ACTUAL_ACC         VARCHAR2 (20);
      V_CONT_NO            NUMBER;
      V_COUNT              NUMBER;
      V_CLOSE_STATUS       NUMBER;
      V_FOR_DEPOSITS       CHAR (1);
      V_FOR_LOANS          CHAR (1);
      V_FOR_RUN_ACS        CHAR (1);
      V_CONTRACT_ALLOWED   CHAR (1);
   BEGIN
      W_CBD := PKG_PB_GLOBAL.FN_GET_CURR_BUS_DATE (1);

      V_ACTUAL_ACC := T_CTR_STRING (1);
      V_CONT_NO := NVL (T_NEW_DATA_STRING (2), 0);
      V_GLOB_ENTITY_NUM := 1;

      SELECT COUNT (*)
        INTO V_COUNT
        FROM IACLINK
       WHERE     IACLINK_ENTITY_NUM = V_GLOB_ENTITY_NUM
             AND IACLINK_ACTUAL_ACNUM = V_ACTUAL_ACC;



      IF V_COUNT = 0
      THEN
         V_ERR_MSG := 'Invalid Account Number';
      END IF;

      SELECT IACLINK_INTERNAL_ACNUM,
             PRODUCT_FOR_DEPOSITS,
             PRODUCT_FOR_LOANS,
             PRODUCT_FOR_RUN_ACS,
             PRODUCT_CONTRACT_ALLOWED
        INTO V_INTERNAL_ACC,
             V_FOR_DEPOSITS,
             V_FOR_LOANS,
             V_FOR_RUN_ACS,
             V_CONTRACT_ALLOWED
        FROM IACLINK, PRODUCTS
       WHERE     IACLINK_ENTITY_NUM = V_GLOB_ENTITY_NUM
             AND PRODUCT_CODE = IACLINK_PROD_CODE
             AND IACLINK_ACTUAL_ACNUM = V_ACTUAL_ACC;

      IF V_CONTRACT_ALLOWED = 1
      THEN
         IF V_CONT_NO = 0
         THEN
            V_ERR_MSG :=
               'Please mention contract no for contract base account.';
         END IF;
      END IF;

      IF V_FOR_DEPOSITS = '1' AND V_FOR_RUN_ACS = '0'
      THEN
         SELECT COUNT (*)
           INTO V_CLOSE_STATUS
           FROM PBDCONTRACT
          WHERE     PBDCONT_ENTITY_NUM = V_GLOB_ENTITY_NUM
                AND PBDCONT_DEP_AC_NUM = V_INTERNAL_ACC
                AND PBDCONT_CONT_NUM = V_CONT_NO
                AND PBDCONT_CLOSURE_DATE IS NULL;
      ELSIF V_FOR_DEPOSITS = '1' AND V_FOR_RUN_ACS = '1'
      THEN
         SELECT COUNT (*)
           INTO V_CLOSE_STATUS
           FROM ACNTS
          WHERE     ACNTS_ENTITY_NUM = V_GLOB_ENTITY_NUM
                AND ACNTS_INTERNAL_ACNUM = V_INTERNAL_ACC
                AND ACNTS_CLOSURE_DATE IS NULL;
      END IF;

      IF V_CLOSE_STATUS > 0
      THEN
         V_ERR_MSG := 'Account Already Open.';
         RETURN;
      END IF;

      IF V_FOR_DEPOSITS = 1 AND V_FOR_RUN_ACS = 1
      THEN
         UPDATE acnts
            SET ACNTS_CLOSURE_DATE = NULL
          WHERE     ACNTS_ENTITY_NUM = V_GLOB_ENTITY_NUM
                AND ACNTS_INTERNAL_ACNUM = V_INTERNAL_ACC;

         DELETE FROM ACNTCLS
               WHERE     ACNTCLS_ENTITY_NUM = V_GLOB_ENTITY_NUM
                     AND ACNTCLS_INTERNAL_ACNUM = V_INTERNAL_ACC;
      ELSIF V_FOR_DEPOSITS = 1 AND V_FOR_RUN_ACS = 0
      THEN
         UPDATE acnts
            SET ACNTS_CLOSURE_DATE = NULL
          WHERE     ACNTS_ENTITY_NUM = V_GLOB_ENTITY_NUM
                AND ACNTS_INTERNAL_ACNUM = V_INTERNAL_ACC;

         UPDATE PBDCONTRACT
            SET PBDCONT_CLOSURE_DATE = NULL
          WHERE     PBDCONT_ENTITY_NUM = V_GLOB_ENTITY_NUM
                AND PBDCONT_DEP_AC_NUM = V_INTERNAL_ACC
                AND PBDCONT_CONT_NUM = V_CONT_NO;

         DELETE FROM DEPCLS
               WHERE     DEPCLS_ENTITY_NUM = V_GLOB_ENTITY_NUM
                     AND DEPCLS_DEP_AC_NUM = V_INTERNAL_ACC
                     AND DEPCLS_CONT_NUM = V_CONT_NO;
      ELSIF V_FOR_LOANS = 1
      THEN
         UPDATE acnts
            SET ACNTS_CLOSURE_DATE = NULL
          WHERE     ACNTS_ENTITY_NUM = V_GLOB_ENTITY_NUM
                AND ACNTS_INTERNAL_ACNUM = V_INTERNAL_ACC;

         DELETE FROM LNACCLS
               WHERE     LNACCLS_ENTITY_NUM = V_GLOB_ENTITY_NUM
                     AND LNACCLS_INTERNAL_ACNUM = V_INTERNAL_ACC;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         V_ERR_MSG :=
            'Error in SP_ACCOUNT_REOPEN ' || SQLCODE || ' ' || SQLERRM;
         RETURN;
   END SP_ACCOUNT_REOPEN;

   ---Account Close Malrk Added by Sabuj
   PROCEDURE SP_ACCOUNT_CLOSE_MARK
   IS
      V_INTERNAL_ACC       NUMBER (14);
      V_ACTUAL_ACC         VARCHAR2 (20);
      V_CONT_NO            NUMBER;
      V_COUNT              NUMBER;
      V_CLOSE_STATUS       NUMBER;
      V_FOR_DEPOSITS       CHAR (1);
      V_FOR_LOANS          CHAR (1);
      V_FOR_RUN_ACS        CHAR (1);
      V_CONTRACT_ALLOWED   CHAR (1);
      v_accbal             NUMBER (18, 2);
      v_cr_dr_sum          NUMBER (18, 2);
   BEGIN
      W_CBD := PKG_PB_GLOBAL.FN_GET_CURR_BUS_DATE (1);

      V_ACTUAL_ACC := T_CTR_STRING (1);
      V_CONT_NO := NVL (T_NEW_DATA_STRING (2), 0);
      V_GLOB_ENTITY_NUM := 1;

      SELECT COUNT (*)
        INTO V_COUNT
        FROM IACLINK
       WHERE     IACLINK_ENTITY_NUM = V_GLOB_ENTITY_NUM
             AND IACLINK_ACTUAL_ACNUM = V_ACTUAL_ACC;



      IF V_COUNT = 0
      THEN
         V_ERR_MSG := 'Invalid Account Number';
      END IF;

      SELECT IACLINK_INTERNAL_ACNUM,
             PRODUCT_FOR_DEPOSITS,
             PRODUCT_FOR_LOANS,
             PRODUCT_FOR_RUN_ACS
        INTO V_INTERNAL_ACC,
             V_FOR_DEPOSITS,
             V_FOR_LOANS,
             V_FOR_RUN_ACS
        FROM IACLINK, PRODUCTS
       WHERE     IACLINK_ENTITY_NUM = V_GLOB_ENTITY_NUM
             AND PRODUCT_CODE = IACLINK_PROD_CODE
             AND IACLINK_ACTUAL_ACNUM = V_ACTUAL_ACC;

      IF V_FOR_LOANS = 1
      THEN
         v_accbal :=
            NVL (FN_GET_WRITEOFF_BAL (1,
                                      V_INTERNAL_ACC,
                                      W_CBD,                     ----ason date
                                      'O'),
                 0);
      END IF;

      IF v_accbal <> 0
      THEN
         V_ERR_MSG := 'Loan Accounts have write-off balance cant closed';
         return;
      END IF;

      SELECT COUNT (*)
        INTO V_CLOSE_STATUS
        FROM ACNTS
       WHERE     ACNTS_ENTITY_NUM = V_GLOB_ENTITY_NUM
             AND ACNTS_INTERNAL_ACNUM = V_INTERNAL_ACC
             AND ACNTS_CLOSURE_DATE IS NOT NULL;

      IF V_CLOSE_STATUS > 0
      THEN
         V_ERR_MSG := 'Account Already Closed.';
         RETURN;
      END IF;

      SELECT ACNTBAL_BC_CUR_DB_SUM + ACNTBAL_BC_CUR_CR_SUM + ACNTBAL_BC_BAL
        INTO v_cr_dr_sum
        FROM acntbal
       WHERE     ACNTBAL_ENTITY_NUM = V_GLOB_ENTITY_NUM
             AND ACNTBAL_INTERNAL_ACNUM = V_INTERNAL_ACC;


      IF v_cr_dr_sum <> 0
      THEN
         V_ERR_MSG := 'Account has balance/tran Cant close from the backend';
         RETURN;
      END IF;

      UPDATE acnts
         SET ACNTS_CLOSURE_DATE = W_CBD
       WHERE     ACNTS_ENTITY_NUM = V_GLOB_ENTITY_NUM
             AND ACNTS_INTERNAL_ACNUM = V_INTERNAL_ACC;
   EXCEPTION
      WHEN OTHERS
      THEN
         V_ERR_MSG :=
            'Error in SP_ACCOUNT_CLOSE_MARK ' || SQLCODE || ' ' || SQLERRM;
         RETURN;
   END SP_ACCOUNT_CLOSE_MARK;

   --Clients convert coporate to individual Added by Sabuj
   PROCEDURE SP_CLIENTS_CONVERT
   IS
      V_INTERNAL_ACC       NUMBER (14);
      V_ACTUAL_ACC         VARCHAR2 (20);
      V_CONT_NO            NUMBER;
      V_COUNT              NUMBER;
      V_CLOSE_STATUS       NUMBER;
      V_FOR_DEPOSITS       CHAR (1);
      V_FOR_LOANS          CHAR (1);
      V_FOR_RUN_ACS        CHAR (1);
      V_CONTRACT_ALLOWED   CHAR (1);
      v_accbal             NUMBER (18, 2);
      v_cr_dr_sum          NUMBER (18, 2);
   BEGIN
      W_CBD := PKG_PB_GLOBAL.FN_GET_CURR_BUS_DATE (1);

      V_ACTUAL_ACC := T_CTR_STRING (1);
      -- V_CONT_NO := NVL (T_NEW_DATA_STRING (2), 0);
      V_GLOB_ENTITY_NUM := 1;

      SELECT COUNT (*)
        INTO V_COUNT
        FROM CLIENTS
       WHERE CLIENTS_CODE = T_CTR_STRING (1) AND CLIENTS_TYPE_FLG = 'C';



      IF V_COUNT = 0
      THEN
         V_ERR_MSG := 'Invalid Client';
      END IF;



      SELECT COUNT (*)
        INTO V_COUNT
        FROM CLIENTS
       WHERE CLIENTS_CODE = T_CTR_STRING (1) AND CLIENTS_TYPE_FLG <> 'C';

      IF V_COUNT > 0
      THEN
         V_ERR_MSG := 'Only corporate clients are allowed';
      END IF;

      INSERT INTO INDCLIENTS (INDCLIENT_CODE,
                              INDCLIENT_FIRST_NAME,
                              INDCLIENT_LAST_NAME,
                              INDCLIENT_SUR_NAME,
                              INDCLIENT_MIDDLE_NAME,
                              INDCLIENT_WKSEC_CODE,
                              INDCLIENT_FATHER_NAME,
                              INDCLIENT_BIRTH_DATE,
                              INDCLIENT_BIRTH_PLACE_CODE,
                              INDCLIENT_BIRTH_PLACE_NAME,
                              INDCLIENT_SEX,
                              INDCLIENT_MARITAL_STATUS,
                              INDCLIENT_RELIGN_CODE,
                              INDCLIENT_NATNL_CODE,
                              INDCLIENT_RESIDENT_STATUS,
                              INDCLIENT_LANG_CODE,
                              INDCLIENT_ILLITERATE_CUST,
                              INDCLIENT_DISABLED,
                              INDCLIENT_FADDR_REQD,
                              INDCLIENT_TEL_RES,
                              INDCLIENT_TEL_OFF,
                              INDCLIENT_TEL_OFF1,
                              INDCLIENT_EXTN_NUM,
                              INDCLIENT_TEL_GSM,
                              INDCLIENT_TEL_FAX,
                              INDCLIENT_EMAIL_ADDR1,
                              INDCLIENT_EMAIL_ADDR2,
                              INDCLIENT_EMPLOY_TYPE,
                              INDCLIENT_RETIRE_PENS_FLG,
                              INDCLIENT_RELATION_BANK_FLG,
                              INDCLIENT_EMPLOYEE_NUM,
                              INDCLIENT_OCCUPN_CODE,
                              INDCLIENT_EMP_COMPANY,
                              INDCLIENT_EMP_CMP_NAME,
                              INDCLIENT_EMP_CMP_ADDR1,
                              INDCLIENT_EMP_CMP_ADDR2,
                              INDCLIENT_EMP_CMP_ADDR3,
                              INDCLIENT_EMP_CMP_ADDR4,
                              INDCLIENT_EMP_CMP_ADDR5,
                              INDCLIENT_DESIG_CODE,
                              INDCLIENT_WORK_SINCE_DATE,
                              INDCLIENT_RETIREMENT_DATE,
                              INDCLIENT_BC_ANNUAL_INCOME,
                              INDCLIENT_ANNUAL_INCOME_SLAB,
                              INDCLIENT_ACCOM_TYPE,
                              INDCLIENT_ACCOM_OTHERS,
                              INDCLIENT_OWNS_TWO_WHEELER,
                              INDCLIENT_OWNS_CAR,
                              INDCLIENT_INSUR_POLICY_INFO,
                              INDCLIENT_DEATH_DATE,
                              INDCLIENT_PID_INV_NUM,
                              INDCLIENT_POVERTY_FLG,
                              INDCLIENT_MOTHER_NAME,
                              INDCLIENT_VISA_TYPE,
                              INDCLIENT_VISAEXP_DATE,
                              INDCLIENT_TERROR_INV,
                              INDCLIENT_ACTION_DTLS1,
                              INDCLIENT_ACTION_DTLS2,
                              INDCLIENT_ACTION_DTLS3,
                              INDCLIENT_ADDR_VERIF_DTLS1,
                              INDCLIENT_ADDR_VERIF_DTLS2,
                              INDCLIENT_RISK_SCORE,
                              INDCLIENT_ENLSTD_SNCTN_LIST)
         SELECT CLIENTS_CODE INDCLIENT_CODE,
                SUBSTR (CLIENTS_NAME, 1, 24) INDCLIENT_FIRST_NAME,
                SUBSTR (CLIENTS_NAME, 25, 17) INDCLIENT_LAST_NAME,
                SUBSTR (CLIENTS_NAME, 43, 10) INDCLIENT_SUR_NAME,
                NULL INDCLIENT_MIDDLE_NAME,
                NULL INDCLIENT_WKSEC_CODE,
                NULL INDCLIENT_FATHER_NAME,
                NULL INDCLIENT_BIRTH_DATE,
                NULL INDCLIENT_BIRTH_PLACE_CODE,
                NULL INDCLIENT_BIRTH_PLACE_NAME,
                NULL INDCLIENT_SEX,
                NULL INDCLIENT_MARITAL_STATUS,
                NULL INDCLIENT_RELIGN_CODE,
                NULL INDCLIENT_NATNL_CODE,
                NULL INDCLIENT_RESIDENT_STATUS,
                NULL INDCLIENT_LANG_CODE,
                NULL INDCLIENT_ILLITERATE_CUST,
                NULL INDCLIENT_DISABLED,
                NULL INDCLIENT_FADDR_REQD,
                NULL INDCLIENT_TEL_RES,
                NULL INDCLIENT_TEL_OFF,
                NULL INDCLIENT_TEL_OFF1,
                NULL INDCLIENT_EXTN_NUM,
                NULL INDCLIENT_TEL_GSM,
                NULL INDCLIENT_TEL_FAX,
                NULL INDCLIENT_EMAIL_ADDR1,
                NULL INDCLIENT_EMAIL_ADDR2,
                NULL INDCLIENT_EMPLOY_TYPE,
                NULL INDCLIENT_RETIRE_PENS_FLG,
                NULL INDCLIENT_RELATION_BANK_FLG,
                NULL INDCLIENT_EMPLOYEE_NUM,
                NULL INDCLIENT_OCCUPN_CODE,
                NULL INDCLIENT_EMP_COMPANY,
                NULL INDCLIENT_EMP_CMP_NAME,
                NULL INDCLIENT_EMP_CMP_ADDR1,
                NULL INDCLIENT_EMP_CMP_ADDR2,
                NULL INDCLIENT_EMP_CMP_ADDR3,
                NULL INDCLIENT_EMP_CMP_ADDR4,
                NULL INDCLIENT_EMP_CMP_ADDR5,
                NULL INDCLIENT_DESIG_CODE,
                NULL INDCLIENT_WORK_SINCE_DATE,
                NULL INDCLIENT_RETIREMENT_DATE,
                NULL INDCLIENT_BC_ANNUAL_INCOME,
                NULL INDCLIENT_ANNUAL_INCOME_SLAB,
                NULL INDCLIENT_ACCOM_TYPE,
                NULL INDCLIENT_ACCOM_OTHERS,
                NULL INDCLIENT_OWNS_TWO_WHEELER,
                NULL INDCLIENT_OWNS_CAR,
                NULL INDCLIENT_INSUR_POLICY_INFO,
                NULL INDCLIENT_DEATH_DATE,
                NULL INDCLIENT_PID_INV_NUM,
                NULL INDCLIENT_POVERTY_FLG,
                NULL INDCLIENT_MOTHER_NAME,
                NULL INDCLIENT_VISA_TYPE,
                NULL INDCLIENT_VISAEXP_DATE,
                NULL INDCLIENT_TERROR_INV,
                NULL INDCLIENT_ACTION_DTLS1,
                NULL INDCLIENT_ACTION_DTLS2,
                NULL INDCLIENT_ACTION_DTLS3,
                NULL INDCLIENT_ADDR_VERIF_DTLS1,
                NULL INDCLIENT_ADDR_VERIF_DTLS2,
                NULL INDCLIENT_RISK_SCORE,
                NULL INDCLIENT_ENLSTD_SNCTN_LIST
           FROM CLIENTS
          WHERE CLIENTS_CODE = T_CTR_STRING (1);

      UPDATE CLIENTS C
         SET CLIENTS_TYPE_FLG = 'I'
       WHERE C.CLIENTS_CODE = T_CTR_STRING (1);

      INSERT INTO CORPCLIENTS_BKP (CORPCL_CLIENT_CODE,
                                   CORPCL_CLIENT_NAME,
                                   CORPCL_RESIDENT_STATUS,
                                   CORPCL_ORGN_QUALIFIER,
                                   CORPCL_SWIFT_CODE,
                                   CORPCL_INDUS_CODE,
                                   CORPCL_SUB_INDUS_CODE,
                                   CORPCL_NATURE_OF_BUS1,
                                   CORPCL_NATURE_OF_BUS2,
                                   CORPCL_NATURE_OF_BUS3,
                                   CORPCL_INVEST_PM_CURR,
                                   CORPCL_INVEST_PM_AMT,
                                   CORPCL_CAPITAL_CURR,
                                   CORPCL_AUTHORIZED_CAPITAL,
                                   CORPCL_ISSUED_CAPITAL,
                                   CORPCL_PAIDUP_CAPITAL,
                                   CORPCL_NETWORTH_AMT,
                                   CORPCL_INCORP_DATE,
                                   CORPCL_INCORP_CNTRY,
                                   CORPCL_REG_NUM,
                                   CORPCL_REG_DATE,
                                   CORPCL_REG_AUTHORITY,
                                   CORPCL_REG_EXPIRY_DATE,
                                   CORPCL_REG_OFF_ADDR1,
                                   CORPCL_REG_OFF_ADDR2,
                                   CORPCL_REG_OFF_ADDR3,
                                   CORPCL_REG_OFF_ADDR4,
                                   CORPCL_REG_OFF_ADDR5,
                                   CORPCL_TF_CLIENT,
                                   CORPCL_VOSTRO_EXCG_HOUSE,
                                   CORPCL_IMP_EXP_CODE,
                                   CORPCL_COM_BUS_IDENTIFIER,
                                   CORPCL_BUS_ENTITY_IDENTIFIER,
                                   CORPCL_YEARS_IN_BUSINESS,
                                   CORPCL_BC_GROSS_TURNOVER,
                                   CORPCL_EMPLOYEE_SIZE,
                                   CORPCL_NUM_OFFICES,
                                   CORPCL_SCHEDULED_BANK,
                                   CORPCL_SOVEREIGN_FLG,
                                   CORPCL_TYPE_OF_SOVEREIGN,
                                   CORPCL_CNTRY_CODE,
                                   CORPCL_CENTRAL_STATE_FLG,
                                   CORPCL_PUBLIC_SECTOR_FLG,
                                   CORPCL_PRIMARY_DLR_FLG,
                                   CORPCL_MULTILATERAL_BANK,
                                   CORPCL_CONNP_INV_NUM,
                                   CORPCL_TYPE_OF_BANK,
                                   CORPCL_TYPE_OF_COOP_BANK,
                                   CORPCL_BANK_CODE,
                                   CORPCL_WKSEC_CODE,
                                   CORPCL_BAL_SHEET_TOTAL,
                                   CORPCL_EXP_CODE,
                                   CORPCL_EMAIL_ADDR,
                                   CORPCL_TERROR_INV,
                                   CORPCL_ACTION_DTLS1,
                                   CORPCL_ACTION_DTLS2,
                                   CORPCL_ACTION_DTLS3,
                                   CORPCL_ADDR_VERIF_DTLS1,
                                   CORPCL_ADDR_VERIF_DTLS2,
                                   CORPCL_BUSI_TYPE,
                                   CORPCL_RISK_SCORE)
         SELECT CORPCL_CLIENT_CODE,
                CORPCL_CLIENT_NAME,
                CORPCL_RESIDENT_STATUS,
                CORPCL_ORGN_QUALIFIER,
                CORPCL_SWIFT_CODE,
                CORPCL_INDUS_CODE,
                CORPCL_SUB_INDUS_CODE,
                CORPCL_NATURE_OF_BUS1,
                CORPCL_NATURE_OF_BUS2,
                CORPCL_NATURE_OF_BUS3,
                CORPCL_INVEST_PM_CURR,
                CORPCL_INVEST_PM_AMT,
                CORPCL_CAPITAL_CURR,
                CORPCL_AUTHORIZED_CAPITAL,
                CORPCL_ISSUED_CAPITAL,
                CORPCL_PAIDUP_CAPITAL,
                CORPCL_NETWORTH_AMT,
                CORPCL_INCORP_DATE,
                CORPCL_INCORP_CNTRY,
                CORPCL_REG_NUM,
                CORPCL_REG_DATE,
                CORPCL_REG_AUTHORITY,
                CORPCL_REG_EXPIRY_DATE,
                CORPCL_REG_OFF_ADDR1,
                CORPCL_REG_OFF_ADDR2,
                CORPCL_REG_OFF_ADDR3,
                CORPCL_REG_OFF_ADDR4,
                CORPCL_REG_OFF_ADDR5,
                CORPCL_TF_CLIENT,
                CORPCL_VOSTRO_EXCG_HOUSE,
                CORPCL_IMP_EXP_CODE,
                CORPCL_COM_BUS_IDENTIFIER,
                CORPCL_BUS_ENTITY_IDENTIFIER,
                CORPCL_YEARS_IN_BUSINESS,
                CORPCL_BC_GROSS_TURNOVER,
                CORPCL_EMPLOYEE_SIZE,
                CORPCL_NUM_OFFICES,
                CORPCL_SCHEDULED_BANK,
                CORPCL_SOVEREIGN_FLG,
                CORPCL_TYPE_OF_SOVEREIGN,
                CORPCL_CNTRY_CODE,
                CORPCL_CENTRAL_STATE_FLG,
                CORPCL_PUBLIC_SECTOR_FLG,
                CORPCL_PRIMARY_DLR_FLG,
                CORPCL_MULTILATERAL_BANK,
                CORPCL_CONNP_INV_NUM,
                CORPCL_TYPE_OF_BANK,
                CORPCL_TYPE_OF_COOP_BANK,
                CORPCL_BANK_CODE,
                CORPCL_WKSEC_CODE,
                CORPCL_BAL_SHEET_TOTAL,
                CORPCL_EXP_CODE,
                CORPCL_EMAIL_ADDR,
                CORPCL_TERROR_INV,
                CORPCL_ACTION_DTLS1,
                CORPCL_ACTION_DTLS2,
                CORPCL_ACTION_DTLS3,
                CORPCL_ADDR_VERIF_DTLS1,
                CORPCL_ADDR_VERIF_DTLS2,
                CORPCL_BUSI_TYPE,
                CORPCL_RISK_SCORE
           FROM CORPCLIENTS
          WHERE CORPCL_CLIENT_CODE = T_CTR_STRING (1);

      DELETE FROM CORPCLIENTS
            WHERE CORPCL_CLIENT_CODE = T_CTR_STRING (1);
   EXCEPTION
      WHEN OTHERS
      THEN
         V_ERR_MSG :=
            'Error in SP_CLIENTS_CONVERT ' || SQLCODE || ' ' || SQLERRM;
         RETURN;
   END SP_CLIENTS_CONVERT;

   PROCEDURE SP_FDR_DATA_CORRECTION
   IS
      V_INTERNAL_ACC   NUMBER (14);
      V_ACTUAL_ACC     VARCHAR2 (20);
      V_CONT_NO        NUMBER;
      V_COUNT          NUMBER;
      V_CLOSE_STATUS   NUMBER;
      v_mat_value number(18,2);
      v_ped_int number(18,2);
   BEGIN
      W_CBD := PKG_PB_GLOBAL.FN_GET_CURR_BUS_DATE (1);

      V_ACTUAL_ACC := T_CTR_STRING (1);
      V_CONT_NO := T_CTR_STRING (2);
      V_GLOB_ENTITY_NUM := 1;
     v_mat_value:=  T_NEW_DATA_STRING (4);
     v_ped_int:= T_NEW_DATA_STRING (5);

      SELECT IACLINK_INTERNAL_ACNUM
        INTO V_INTERNAL_ACC
        FROM IACLINK, PBDCONTRACT
       WHERE     IACLINK_ENTITY_NUM = V_GLOB_ENTITY_NUM
             AND PBDCONT_DEP_AC_NUM = IACLINK_INTERNAL_ACNUM
             AND PBDCONT_ENTITY_NUM = V_GLOB_ENTITY_NUM
             AND PBDCONT_CONT_NUM = V_CONT_NO
             AND IACLINK_ACTUAL_ACNUM = V_ACTUAL_ACC
             AND PBDCONT_CLOSURE_DATE IS NULL;



      IF V_INTERNAL_ACC IS NULL
      THEN
         V_ERR_MSG := 'Invalid Account Number/Account is closed';
      END IF;

      --      SELECT IACLINK_INTERNAL_ACNUM
      --        INTO V_INTERNAL_ACC
      --        FROM IACLINK
      --       WHERE     IACLINK_ENTITY_NUM = V_GLOB_ENTITY_NUM
      --             AND IACLINK_ACTUAL_ACNUM = V_ACTUAL_ACC;

      IF TO_DATE (T_NEW_DATA_STRING (1), 'DD-MM-YYYY') >=
            TO_DATE (T_NEW_DATA_STRING (2), 'DD-MM-YYYY')
      THEN
         V_ERR_MSG := 'Effective date should be less maturity date';
      ELSIF T_NEW_DATA_STRING (6) > T_NEW_DATA_STRING (5)
      THEN
         V_ERR_MSG := 'Periodical amount can not grater than maturity amount';
      END IF;

      UPDATE PBDCONTRACT
         SET PBDCONT_EFF_DATE = TO_DATE (T_NEW_DATA_STRING (1), 'DD-MM-YYYY'),
             PBDCONT_MAT_DATE = TO_DATE (T_NEW_DATA_STRING (2), 'DD-MM-YYYY'),
             PBDCONT_STD_INT_RATE = T_NEW_DATA_STRING (3),
             PBDCONT_ACTUAL_INT_RATE = T_NEW_DATA_STRING (3),
             PBDCONT_MAT_VALUE = v_mat_value,
             PBDCONT_PERIODICAL_INT_AMT = v_ped_int,
             PBDCONT_LAST_MOD_BY = V_ENTD_BY,
             PBDCONT_LAST_MOD_ON = SYSDATE
       WHERE     PBDCONT_DEP_AC_NUM = V_INTERNAL_ACC
             AND PBDCONT_ENTITY_NUM = V_GLOB_ENTITY_NUM
             AND PBDCONT_CONT_NUM = V_CONT_NO;
             
            -- Effective Date | Maturity Date | Rate | Maturity Value | Periodical Amount
   EXCEPTION
      WHEN OTHERS
      THEN
         V_ERR_MSG :=
            'Error in SP_FDR_DATA_CORRECTION ' || SQLCODE || ' ' || SQLERRM;
         RETURN;
   END SP_FDR_DATA_CORRECTION;

   ----Loan Accrual reversal added by Sabuj--------

   PROCEDURE SP_SBHL_ACCRUAL_REVERSAL
   IS
      V_INTERNAL_ACC   NUMBER (14);
      V_ACTUAL_ACC     VARCHAR2 (20);
      V_EFF_DATE       DATE;
      V_COUNT          NUMBER;
      V_CLOSE_STATUS   NUMBER;
      W_BATCH_NO       NUMBER;
   BEGIN
      W_CBD := PKG_PB_GLOBAL.FN_GET_CURR_BUS_DATE (1);

      V_ACTUAL_ACC := T_CTR_STRING (1);
      V_GLOB_ENTITY_NUM := 1;

      SELECT IACLINK_INTERNAL_ACNUM
        INTO V_INTERNAL_ACC
        FROM PRODUCTS, IACLINK
       WHERE     IACLINK_PROD_CODE = PRODUCT_CODE
             AND PRODUCT_FOR_LOANS = 1
             AND IACLINK_ENTITY_NUM = V_GLOB_ENTITY_NUM
             AND IACLINK_ACTUAL_ACNUM = V_ACTUAL_ACC;



      IF V_INTERNAL_ACC IS NULL
      THEN
         V_ERR_MSG := 'Invalid Account Number Or Only Loan account allowed';
         RETURN;
      END IF;

      SELECT COUNT (*)
        INTO V_CLOSE_STATUS
        FROM ACNTS
       WHERE     ACNTS_ENTITY_NUM = 1
             AND ACNTS_INTERNAL_ACNUM = V_INTERNAL_ACC
             AND ACNTS_CLOSURE_DATE IS NOT NULL;

      IF V_CLOSE_STATUS > 0
      THEN
         V_ERR_MSG := 'Account is closed.';
         RETURN;
      END IF;

      BEGIN
         SP_LOAN_ACCRUAL_REVERSAL (
            V_ACTUAL_ACC,
            TO_DATE (T_NEW_DATA_STRING (2), 'DD-MM-YYYY'),
            T_NEW_DATA_STRING (1),
            V_ENTD_BY,
            V_REMARKS,
            W_BATCH_NO);
         V_SHOW_MSG := 'Batch Number Is ' || W_BATCH_NO;
      EXCEPTION
         WHEN OTHERS
         THEN
            V_ERR_MSG :=
                  'Error in SP_LOAN_ACCRUAL_REVERSAL '
               || SQLCODE
               || ' '
               || SQLERRM;
            RETURN;
      END;
   EXCEPTION
      WHEN OTHERS
      THEN
         V_ERR_MSG :=
            'Error in SP_SBHL_ACCRUAL_REVERSAL ' || SQLCODE || ' ' || SQLERRM;
         RETURN;
   END SP_SBHL_ACCRUAL_REVERSAL;

   ----LIEN REVOKE added by Sabuj-----------

   PROCEDURE SP_LIEN_REVOKE
   IS
      V_INTERNAL_ACC     NUMBER (14);
      V_ACTUAL_ACC       VARCHAR2 (20);
      V_EXIST_LIEN_AMT   NUMBER (18, 2);
      V_COUNT            NUMBER;
      V_CLOSE_STATUS     NUMBER;
      V_LIEN_AMOUNT      NUMBER (18, 2);
   BEGIN
      W_CBD := PKG_PB_GLOBAL.FN_GET_CURR_BUS_DATE (1);

      V_ACTUAL_ACC := T_CTR_STRING (1);
      -- V_EXIST_LIEN_AMT := T_CTR_STRING (2);
      V_GLOB_ENTITY_NUM := 1;
      V_LIEN_AMOUNT := NVL (T_NEW_DATA_STRING (1), 0);

      SELECT COUNT (*)
        INTO V_COUNT
        FROM IACLINK
       WHERE     IACLINK_ENTITY_NUM = V_GLOB_ENTITY_NUM
             AND IACLINK_ACTUAL_ACNUM = V_ACTUAL_ACC;



      IF V_COUNT = 0
      THEN
         V_ERR_MSG := 'Invalid Account Number';
      END IF;

      SELECT IACLINK_INTERNAL_ACNUM
        INTO V_INTERNAL_ACC
        FROM IACLINK
       WHERE     IACLINK_ENTITY_NUM = V_GLOB_ENTITY_NUM
             AND IACLINK_ACTUAL_ACNUM = V_ACTUAL_ACC;

      SELECT NVL (ACNTBAL_BC_LIEN_AMT, 0)
        INTO V_EXIST_LIEN_AMT
        FROM ACNTBAL
       WHERE     ACNTBAL_INTERNAL_ACNUM = V_INTERNAL_ACC
             AND ACNTBAL_ENTITY_NUM = V_GLOB_ENTITY_NUM;

      UPDATE DEPACCLIEN
         SET DEPACLIEN_REVOKED_ON = W_CBD
       WHERE     DEPACLIEN_DEP_AC_NUM = V_INTERNAL_ACC
             AND DEPACLIEN_ENTITY_NUM = V_GLOB_ENTITY_NUM;

      UPDATE ACNTLIEN
         SET ACNTLIEN_REVOKED_ON = W_CBD
       WHERE     ACNTLIEN_ENTITY_NUM = V_GLOB_ENTITY_NUM
             AND ACNTLIEN_INTERNAL_ACNUM = V_INTERNAL_ACC;

      DELETE FROM LADDEPLINK
            WHERE     LADDEPLNK_ENTITY_NUM = V_GLOB_ENTITY_NUM
                  AND LADDEPLNK_INTERNAL_ACNUM = V_INTERNAL_ACC;

      IF V_EXIST_LIEN_AMT <> 0
      THEN
         UPDATE ACNTBAL
            SET ACNTBAL_AC_LIEN_AMT =0,
                ACNTBAL_BC_LIEN_AMT =0
          WHERE     ACNTBAL_INTERNAL_ACNUM = V_INTERNAL_ACC
                AND ACNTBAL_ENTITY_NUM = V_GLOB_ENTITY_NUM;


         UPDATE ACNTCBAL
            SET ACNTCBAL_AC_LIEN_AMT =
                   NVL (ACNTCBAL_AC_LIEN_AMT, 0) - V_LIEN_AMOUNT,
                ACNTCBAL_BC_LIEN_AMT =
                   NVL (ACNTCBAL_BC_LIEN_AMT, 0) - V_LIEN_AMOUNT
          WHERE     ACNTCBAL_INTERNAL_ACNUM = V_INTERNAL_ACC
                AND ACNTCBAL_ENTITY_NUM = V_GLOB_ENTITY_NUM;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         V_ERR_MSG := 'Error in SP_LIEN_REVOKE ' || SQLCODE || ' ' || SQLERRM;
         RETURN;
   END SP_LIEN_REVOKE;

   FUNCTION CONCATE_QUERY_FILTERS (
      P_ACT_QRY                 VARCHAR,
      T_COMMON_FILTER_STRING    COMMON_FILTER_STRING)
      RETURN VARCHAR2
   IS
      V_SQL          VARCHAR2 (1250);
      V_INSTR        NUMBER (7);
      V_START        VARCHAR2 (1250);
      V_END          VARCHAR2 (1250);
      V_ACT_QRY      VARCHAR2 (1250);
      V_QUERY_DATA   VARCHAR2 (1000);
   BEGIN
      V_ACT_QRY := P_ACT_QRY;

      FOR I IN 1 .. V_NO_OF_SEP_VAL
      LOOP
         V_INSTR :=
            INSTR (V_ACT_QRY,
                   '?',
                   1,
                   1);
         V_START := SUBSTR (V_ACT_QRY, 1, V_INSTR - 1);
         V_END :=
            NVL (SUBSTR (V_ACT_QRY, V_INSTR + 1, LENGTH (V_ACT_QRY)), ' ');

         IF TRIM (T_COMMON_FILTER_STRING (I)) = 'S'
         THEN
            V_ACT_QRY :=
                  V_START
               || CHR (39)
               || TRIM (T_FILTER_DATA_STRING (I))
               || CHR (39)
               || V_END;
         ELSIF TRIM (T_COMMON_FILTER_STRING (I)) = 'D'
         THEN
            V_ACT_QRY :=
                  V_START
               || 'TO_DATE('
               || CHR (39)
               || TRIM (T_FILTER_DATA_STRING (I))
               || CHR (39)
               || ', '
               || CHR (39)
               || V_DATE_FMT
               || CHR (39)
               || ')'
               || V_END;
         ELSIF TRIM (T_COMMON_FILTER_STRING (I)) = 'N'
         THEN
            V_ACT_QRY := V_START || TRIM (T_FILTER_DATA_STRING (I)) || V_END;
         END IF;
      END LOOP;

      RETURN V_ACT_QRY;
   END CONCATE_QUERY_FILTERS;


   ---------------------------------------------------------------------------------------------------------

   FUNCTION GET_DATA_TO_UPDATE (P_QRY_TYPE CHAR)
      RETURN VARCHAR2
   IS
      V_ACT_QRY      VARCHAR2 (1250);
      V_QUERY_DATA   VARCHAR2 (1000);
   BEGIN
      T_COMMON_FILTER_STRING.DELETE;

      FOR I IN 1 .. V_NO_OF_SEP_VAL
      LOOP
         T_COMMON_FILTER_STRING (I) := T_DATA_TYPE_STRING (I);
      END LOOP;


      IF P_QRY_TYPE = 'R'
      THEN
         V_ACT_QRY :=
            CONCATE_QUERY_FILTERS (V_CONF_RLVQRY, T_COMMON_FILTER_STRING);
      ELSIF P_QRY_TYPE = 'U'
      THEN
         V_ACT_QRY :=
            CONCATE_QUERY_FILTERS (V_CONF_UPDQRY, T_COMMON_FILTER_STRING);
      END IF;


      EXECUTE IMMEDIATE V_ACT_QRY INTO V_QUERY_DATA;

      RETURN V_QUERY_DATA;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         V_ERR_MSG := 'No Data Found.';
         RETURN '';
   END GET_DATA_TO_UPDATE;


   ----------------------------------------------------------------------------------------------------------

   PROCEDURE VALIDATE_BRN_HIERARCHY
   IS
      V_CNT          NUMBER (2);
      V_ACT_QRY      VARCHAR2 (1250);
      V_QUERY_DATA   VARCHAR2 (1000);
   BEGIN
      T_COMMON_FILTER_STRING.DELETE;

      IF TRIM (V_CONF_BRN_QRY) IS NULL
      THEN
         RETURN;
      END IF;


      FOR I IN 1 .. V_NO_OF_SEP_VAL
      LOOP
         T_COMMON_FILTER_STRING (I) := T_FILTER_BRN_IDNT_STR (I);
      END LOOP;

      V_ACT_QRY :=
         CONCATE_QUERY_FILTERS (V_CONF_BRN_QRY, T_COMMON_FILTER_STRING);

      EXECUTE IMMEDIATE V_ACT_QRY INTO V_QUERY_DATA;

      IF TO_NUMBER (V_QUERY_DATA) <> TO_NUMBER (V_BRN_CODE)
      THEN
         SELECT CASE
                   WHEN NVL (M.MBRN_PARENT_ADMIN_CODE, 0) = 0 THEN '1'
                   ELSE '0'
                END
                   HO_BRN
           INTO HO_BRN
           FROM MBRN M
          WHERE M.MBRN_CODE = V_BRN_CODE;

         IF HO_BRN = 0
         THEN
            SELECT COUNT (*)
              INTO V_CNT
              FROM (  SELECT BRNLISTDTL_LIST_NUM
                        FROM BRNLISTDTL, DATACTRCONF
                       WHERE     DATACTRCONF_BRNLIST_NUM = BRNLISTDTL_LIST_NUM
                             AND DATACTRCONF_ID = V_QRY_UPD_CODE
                             AND BRNLISTDTL_BRN_CODE IN (V_QUERY_DATA,
                                                         V_BRN_CODE)
                    GROUP BY BRNLISTDTL_LIST_NUM
                      HAVING COUNT (BRNLISTDTL_LIST_NUM) > 1);

            IF V_CNT = 0
            THEN
               V_ERR_MSG :=
                     'This branch is Not Authorized to Update data of Branch '
                  || V_QUERY_DATA;
            END IF;
         ELSE
            V_ERR_MSG := '';
         END IF;
      ELSE
         V_ERR_MSG := '';
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         V_ERR_MSG := 'No Data Found.';
   END VALIDATE_BRN_HIERARCHY;

   -----------------------------NOOR-------------------------------------------------------------------------

   PROCEDURE SP_DATA_QUERY (P_CODE        IN     VARCHAR,
                            P_QUERY_STR   IN     VARCHAR,
                            P_BRN_CODE    IN     NUMBER,
                            P_RLV_DATA       OUT VARCHAR,
                            P_UPD_DATA       OUT VARCHAR,
                            P_ERR_MSG        OUT VARCHAR)
   IS
   BEGIN
      V_QRY_UPD_CODE := P_CODE;
      V_BRN_CODE := P_BRN_CODE;
      V_QUERY_STR := P_QUERY_STR;
      INIT_CONFIGURATION;
      PARSE_QUERY_DATA;
      VALIDATE_DATA_TYPES;
      VALIDATE_BRN_HIERARCHY;

      IF V_ERR_MSG IS NULL
      THEN
         P_RLV_DATA := GET_DATA_TO_UPDATE ('R');
         P_UPD_DATA := GET_DATA_TO_UPDATE ('U');
      END IF;

      P_ERR_MSG := V_ERR_MSG;
   END SP_DATA_QUERY;
   
   ------------- RTGSTRYRST CODE BLOCK ----------
   
    
   PROCEDURE UPDATE_RTGS_TRY_COUNT IS
   V_TRY_COUNT NUMBER(3);
 BEGIN
 
   V_TRY_COUNT := TO_NUMBER(T_NEW_DATA_STRING(1));
 
   IF V_TRY_COUNT != 0 THEN
     V_ERR_MSG := 'Set the Try Count 0.';
     RETURN;
   END IF;
 
   UPDATE RTGINQPE
      SET TRY_NO = V_TRY_COUNT
    WHERE INVENTORY_NO = T_CTR_STRING(1);
 
 END UPDATE_RTGS_TRY_COUNT;
   -------------------------------------------------------------------------------------------

   PROCEDURE SP_DATA_CORRECTION (P_CODE        IN     VARCHAR,
                                 P_QUERY_STR   IN     VARCHAR,
                                 P_OLD_DATA    IN     VARCHAR,
                                 P_NEW_DATA    IN     VARCHAR,
                                 P_BRN_CODE    IN     NUMBER,
                                 P_REMARKS     IN     VARCHAR,
                                 P_ENTD_ON     IN     DATE,
                                 P_ENTD_BY     IN     VARCHAR,
                                 P_ERR_MSG        OUT VARCHAR,
                                 P_SHOW_MSG       OUT VARCHAR)
   IS
   BEGIN
      V_QRY_UPD_CODE := P_CODE;
      V_QUERY_STR := P_QUERY_STR;
      V_OLD_DATA := P_OLD_DATA;
      V_NEW_DATA := P_NEW_DATA;
      V_BRN_CODE := P_BRN_CODE;
      V_CBD := PKG_PB_GLOBAL.FN_GET_CURR_BUS_DATE (1);
      V_REMARKS := P_REMARKS;
      V_ENTD_BY := P_ENTD_BY;
      V_ENTD_ON := P_ENTD_ON;
      V_SHOW_MSG := NULL;
      INIT_CONFIGURATION;
      PARSE_UPDATED_DATA;
      VALIDATE_DATA_TYPES;
      VALIDATE_BRN_HIERARCHY;

      IF V_ERR_MSG IS NOT NULL
      THEN
         P_ERR_MSG := V_ERR_MSG;
         RETURN;
      END IF;

      IF V_SHOW_MSG IS NOT NULL
      THEN
         P_SHOW_MSG := V_SHOW_MSG;
         RETURN;
      END IF;

      IF P_CODE = 'LNREPAYUPD'
      THEN
         UPDATE_REPAYMENT_SCH;
      ELSIF P_CODE = 'LNLMTEXPDT'
      THEN
         UPDATE_EXPIRY_DATE;
      ELSIF P_CODE = 'LNACIRECAL'
      THEN
         UPDATE_LNACIRECAL_ACC;
      END IF;

      IF P_CODE = 'PRDCHG'
      THEN
         PRODUCT_CODE_CHANGE;
      END IF;

      IF P_CODE = 'BRNSTATUS'
      THEN
         SP_BRANCH_SIGNIN;
      END IF;

      IF P_CODE = 'CASHOPEN'
      THEN
         SP_CASH_SIGNIN;
      END IF;

      IF P_CODE = 'TELLERSIGN'
      THEN
         SP_TELLER_SIGNIN;
      END IF;

      IF P_CODE = 'CLDCHANGE'
      THEN
         SP_CLIENTS_CHANGE;
      END IF;

      IF P_CODE = 'BATCHNRR'
      THEN
         SP_BATCH_NARRATION_UPDATE;
      END IF;

      IF P_CODE = 'CLRBTNACT'
      THEN
         SP_CLEARING_BUTTON_ACTIVE;
      END IF;

      IF P_CODE = 'RDBALSG'
      THEN
         SP_RD_BAL_SEGREGATIONS;
      END IF;

      IF P_CODE = 'ACNTOPEN'
      THEN
         SP_ACCOUNT_REOPEN;
      END IF;

      IF P_CODE = 'LNINTRATE'
      THEN
         SP_SBHL_ACCRUAL_REVERSAL;
      END IF;

      IF P_CODE = 'FDRCORR'
      THEN
         SP_FDR_DATA_CORRECTION;
      END IF;

      IF P_CODE = 'LIENREVOKE'
      THEN
         SP_LIEN_REVOKE;
      END IF;

      IF P_CODE = 'ACNTCLOSE'
      THEN
         SP_ACCOUNT_CLOSE_MARK;
      END IF;

      IF P_CODE = 'CORPCLDTRF'
      THEN
         SP_CLIENTS_CONVERT;
      END IF;

      IF P_CODE = 'TFTRTXTRPT'
      THEN
        UPDATE_ETFTRAN_TXT_FILE_GEN;
      END IF;
      IF P_CODE = 'TRANTFTRAN'
      THEN
        UPDATE_ETRAN_TO_ETFTRAN;
      END IF;
      IF P_CODE='TFBTBLOCNG'
      THEN
        UPDATE_BTB_EXISTING_EXPLCORDER;
      END IF;
      IF P_CODE='TFEXPLCVAR'
      THEN
        UPDATE_EXPLC_VARIANCE_AMT;
      END IF;
      IF P_CODE='TFBTBPAYIN'
      THEN
        UPDATE_BTB_PAYMENT_INCURR;
      END IF;
      IF P_CODE = 'TFLCAFDATE' 
      THEN
        UPDATE_LCAF_DATA_OLC;
      END IF;
      IF P_CODE = 'RTGSTRYRST' 
      THEN
        UPDATE_RTGS_TRY_COUNT;
      END IF;
      V_CBD := PKG_PB_GLOBAL.FN_GET_CURR_BUS_DATE (1);
      V_REMARKS := P_REMARKS;
      V_ENTD_BY := P_ENTD_BY;
      V_ENTD_ON := P_ENTD_ON;
      INSERT_LOG;
      P_ERR_MSG := V_ERR_MSG;
      P_SHOW_MSG := V_SHOW_MSG;
   END SP_DATA_CORRECTION;
END PKG_DATA_CORRECTOR;
/
