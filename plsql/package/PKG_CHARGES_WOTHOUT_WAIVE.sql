CREATE OR REPLACE PACKAGE PKG_CHARGES_WOTHOUT_WAIVE
AS
   P_NOOF_DAYS_FACTOR   NUMBER (4) DEFAULT 0;

   PROCEDURE SP_GET_CHARGES (V_ENTITY_NUM            IN            NUMBER,
                             P_ACCOUNT_NUMBER        IN            NUMBER,
                             P_TRAN_CURR_CODE        IN            VARCHAR2,
                             P_TRAN_AMOUNT           IN            NUMBER,
                             P_CHARGE_CODE           IN            VARCHAR2,
                             P_CHG_TYPE              IN            VARCHAR2,
                             P_CHARGE_CURR_CODE         OUT NOCOPY VARCHAR2,
                             P_CHARGE_AMOUNT            OUT NOCOPY FLOAT,
                             P_SERVICE_AMOUNT           OUT NOCOPY FLOAT,
                             P_SERVICE_STAX_AMOUNT      OUT NOCOPY FLOAT,
                             P_SERVICE_ADDN_AMOUNT      OUT NOCOPY FLOAT,
                             P_SERVICE_CESS_AMOUNT      OUT NOCOPY FLOAT,
                             P_ERR_MSG                  OUT NOCOPY VARCHAR2);
END;
/

CREATE OR REPLACE PACKAGE BODY PKG_CHARGES_WOTHOUT_WAIVE
IS
   V_ACCOUNT_NUMBER              NUMBER (14);
   V_TRAN_CURR_CODE              VARCHAR2 (3);
   V_TRAN_AMOUNT                 NUMBER (18, 3);
   V_GLOB_ENTITY_NUM             NUMBER;
   V_AC_LEVEL_WAIVER_PRESENT     BOOLEAN;
   V_AC_LEVEL_WAIVER_REC_FOUND   BOOLEAN;

   V_CHARGE_CODE                 VARCHAR2 (6);
   V_CHARGE_CURR_CODE            VARCHAR2 (3);
   V_CHARGE_AMOUNT               FLOAT;
   V_ERR_MSG                     VARCHAR2 (100);
   V_ERROR_STATUS                NUMBER (1);
   V_SERVICE_AMOUNT              FLOAT;
   V_SERVICE_STAX_AMOUNT         FLOAT;
   V_SERVICE_ADDN_AMOUNT         FLOAT;
   V_SERVICE_CESS_AMOUNT         FLOAT;

   W_CHARGE_SQL                  VARCHAR2 (4300);
   W_CLIENT_CODE                 NUMBER (12);
   V_NOOF_DAYS_FACTOR            NUMBER (4);

   TYPE CHARGE_KEY IS RECORD
   (
      CHARGES_PROD_CODE     NUMBER (4),
      CHARGES_AC_TYPE       VARCHAR2 (5),
      CHARGES_ACSUB_TYPE    NUMBER (3),
      CHARGES_SCHEME_CODE   VARCHAR2 (6),
      CHARGES_CHG_TYPE      CHAR (1)
   );

   TYPE T_CHARGE_KEY IS TABLE OF CHARGE_KEY
      INDEX BY BINARY_INTEGER;

   W_INDEX                       NUMBER (5);

   V_CHARGE_KEY                  T_CHARGE_KEY;

   W_CHARGES_PROD_CODE           NUMBER (4);
   W_CHARGES_AC_TYPE             VARCHAR2 (5);
   W_CHARGES_ACSUB_TYPE          NUMBER (3);
   W_CHARGES_SCHEME_CODE         VARCHAR2 (6);
   W_CHARGES_CHG_TYPE            CHAR (1);

   W_ORIG_CHARGES_PROD_CODE      NUMBER (4);
   W_ORIG_CHARGES_AC_TYPE        VARCHAR2 (5);
   W_ORIG_CHARGES_ACSUB_TYPE     NUMBER (3);
   W_ORIG_CHARGES_SCHEME_CODE    VARCHAR2 (6);
   W_ORIG_CHARGES_CHG_TYPE       CHAR (1);

   W_CHARGE_ROW_POSTION          NUMBER (5);

   V_CHARGE_ROW                  CHARGES%ROWTYPE;
   V_DUMMY                       NUMBER (1);
   W_ACCOUNT_CURR_CODE           VARCHAR2 (3);

   FUNCTION GET_NOOF_DAYS_FACTOR (V_PROC_AMOUNT IN FLOAT)
      RETURN NUMBER
   IS
      V_TEMP_AMT   FLOAT;
   BEGIN
      V_TEMP_AMT := V_PROC_AMOUNT;

      IF NVL (V_NOOF_DAYS_FACTOR, 0) > 0
      THEN
         V_TEMP_AMT := (V_PROC_AMOUNT * V_NOOF_DAYS_FACTOR);
      END IF;

      RETURN V_TEMP_AMT;
   END;


   FUNCTION GET_MIN_MAX_AMOUNT (P_AMT IN FLOAT)
      RETURN FLOAT
   IS
      V_TEMP_AMT   FLOAT;
      P_AMOUNT     FLOAT;   
   BEGIN
      P_AMOUNT := P_AMT;
      IF P_AMOUNT IS NULL OR P_AMOUNT = 0
      THEN
         RETURN 0;
      END IF;

      P_AMOUNT := GET_NOOF_DAYS_FACTOR (P_AMOUNT);

      IF     V_CHARGE_ROW.CHARGES_OVERALL_MIN_AMT > 0
         AND P_AMOUNT < V_CHARGE_ROW.CHARGES_OVERALL_MIN_AMT
      THEN
         V_TEMP_AMT := V_CHARGE_ROW.CHARGES_OVERALL_MIN_AMT;
      ELSIF     V_CHARGE_ROW.CHARGES_OVERALL_MAX_AMT > 0
            AND P_AMOUNT > V_CHARGE_ROW.CHARGES_OVERALL_MAX_AMT
      THEN
         V_TEMP_AMT := V_CHARGE_ROW.CHARGES_OVERALL_MAX_AMT;
      ELSE
         V_TEMP_AMT := P_AMOUNT;
      END IF;

      RETURN (V_TEMP_AMT);
   END;

   FUNCTION GET_ROUNDOFF_AMT (P_AMOUNT IN FLOAT)
      RETURN FLOAT
   IS
      V_TMP_AMT     DOUBLE PRECISION DEFAULT 0;
      V_FRAC_PART   DOUBLE PRECISION DEFAULT 0;
   BEGIN
      IF P_AMOUNT IS NULL OR P_AMOUNT = 0
      THEN
         RETURN 0;
      ELSIF TRIM (V_CHARGE_ROW.CHARGES_RNDOFF_CHOICE) IS NULL
      THEN
         RETURN (P_AMOUNT);
      END IF;

      V_TMP_AMT := P_AMOUNT;
      V_TMP_AMT := V_TMP_AMT / V_CHARGE_ROW.CHARGES_RNDOFF_FACTOR;
      V_FRAC_PART := V_TMP_AMT - TRUNC (V_TMP_AMT);

      IF V_CHARGE_ROW.CHARGES_RNDOFF_CHOICE = 'L'
      THEN
         V_TMP_AMT := V_TMP_AMT - V_FRAC_PART;
      ELSIF V_CHARGE_ROW.CHARGES_RNDOFF_CHOICE = 'H'
      THEN
         IF V_FRAC_PART > 0
         THEN
            V_TMP_AMT := V_TMP_AMT + 1 - V_FRAC_PART;
         END IF;
      ELSIF V_CHARGE_ROW.CHARGES_RNDOFF_CHOICE = 'N'
      THEN
         IF V_FRAC_PART < 0.5
         THEN
            V_TMP_AMT := V_TMP_AMT - V_FRAC_PART;
         ELSE
            V_TMP_AMT := V_TMP_AMT - V_FRAC_PART + 1;
         END IF;
      END IF;

      V_TMP_AMT := V_TMP_AMT * V_CHARGE_ROW.CHARGES_RNDOFF_FACTOR;
      RETURN (V_TMP_AMT);
   END;

   PROCEDURE INIT_PARA
   IS
   BEGIN
      V_SERVICE_AMOUNT := 0;
      V_SERVICE_STAX_AMOUNT := 0;
      V_SERVICE_ADDN_AMOUNT := 0;
      V_SERVICE_CESS_AMOUNT := 0;
      W_CLIENT_CODE := 0;
      W_ACCOUNT_CURR_CODE := '';
      V_ACCOUNT_NUMBER := 0;
      V_TRAN_CURR_CODE := '';
      V_TRAN_AMOUNT := 0;
      V_CHARGE_CODE := '';
      V_CHARGE_CURR_CODE := '';
      V_CHARGE_AMOUNT := 0;
      V_ERR_MSG := '';
      V_ERROR_STATUS := 0;
      W_CHARGE_ROW_POSTION := 0;
      V_NOOF_DAYS_FACTOR := 0;
      V_NOOF_DAYS_FACTOR := NVL (PKG_CHARGES.P_NOOF_DAYS_FACTOR, 0);
      PKG_CHARGES.P_NOOF_DAYS_FACTOR := 0;
   END;

   FUNCTION GET_FIXED_PERCENT_CHGS (P_AMOUNT IN FLOAT)
      RETURN FLOAT
   IS
      V_PERCENT_AMT   FLOAT DEFAULT 0;
      V_CHG_AMT       FLOAT DEFAULT 0;
   BEGIN
      V_PERCENT_AMT := P_AMOUNT * V_CHARGE_ROW.CHARGES_CHGS_PERCENTAGE / 100;

      CASE V_CHARGE_ROW.CHARGES_COMBINATION_CHOICE
         WHEN '1'
         THEN
            V_CHG_AMT :=
               LEAST (NVL (V_CHARGE_ROW.CHARGES_FIXED_AMT, 0), V_PERCENT_AMT);
         WHEN '2'
         THEN
            V_CHG_AMT :=
               GREATEST (NVL (V_CHARGE_ROW.CHARGES_FIXED_AMT, 0),
                         V_PERCENT_AMT);
         ELSE
            V_CHG_AMT :=
               NVL (V_CHARGE_ROW.CHARGES_FIXED_AMT, 0) + V_PERCENT_AMT;
      END CASE;

      RETURN (GET_MIN_MAX_AMOUNT (V_CHG_AMT));
   END;

   FUNCTION CALC_TENOR_AMT (P_AMOUNT             IN FLOAT,
                            P_SLAB_FLG           IN CHAR,
                            P_PRE_AMOUNT         IN FLOAT,
                            P_REC_CHGSTENORAMT   IN CHGSTENORAMT%ROWTYPE)
      RETURN FLOAT
   IS
      V_TEMP_CHGS   FLOAT DEFAULT 0;
   BEGIN
      IF P_REC_CHGSTENORAMT.CHGAMT_FIXED_CHGS > 0
      THEN
         V_TEMP_CHGS := P_REC_CHGSTENORAMT.CHGAMT_FIXED_CHGS;
      ELSE
         IF P_REC_CHGSTENORAMT.CHGAMT_PER_AMT <> 0
         THEN
            IF P_SLAB_FLG = 'S'
            THEN
               V_TEMP_CHGS :=
                    (P_AMOUNT / P_REC_CHGSTENORAMT.CHGAMT_PER_AMT)
                  * P_REC_CHGSTENORAMT.CHGAMT_VAR_CHGS;
            ELSE
               V_TEMP_CHGS :=
                    (  (P_AMOUNT - P_PRE_AMOUNT)
                     / P_REC_CHGSTENORAMT.CHGAMT_PER_AMT)
                  * P_REC_CHGSTENORAMT.CHGAMT_VAR_CHGS;
            END IF;
         ELSE
            V_TEMP_CHGS := 0;
         END IF;

         IF     P_REC_CHGSTENORAMT.CHGAMT_MAX_CHGS > 0
            AND V_TEMP_CHGS > P_REC_CHGSTENORAMT.CHGAMT_MAX_CHGS
         THEN
            V_TEMP_CHGS := P_REC_CHGSTENORAMT.CHGAMT_MAX_CHGS;
         END IF;

         IF     P_REC_CHGSTENORAMT.CHGAMT_MIN_CHGS > 0
            AND V_TEMP_CHGS < P_REC_CHGSTENORAMT.CHGAMT_MIN_CHGS
         THEN
            V_TEMP_CHGS := P_REC_CHGSTENORAMT.CHGAMT_MIN_CHGS;
         END IF;
      END IF;

      RETURN (V_TEMP_CHGS);
   END;

   FUNCTION GET_TENOR_CHARGES (P_AMOUNT IN FLOAT)
      RETURN FLOAT
   IS
      V_UPTO_AMOUNT       CHGSTENORAMT.CHGAMT_UPTO_AMT%TYPE DEFAULT 0;
      V_PRE_UPTO_AMOUNT   CHGSTENORAMT.CHGAMT_UPTO_AMT%TYPE DEFAULT 0;
      V_CHGS_AMT          FLOAT DEFAULT 0;
   BEGIN
      FOR IDX_REC
         IN (  SELECT *
                 FROM CHGSTENORAMT
                WHERE     CHGAMT_ENTITY_NUM = V_GLOB_ENTITY_NUM
                      AND CHGAMT_CHG_CODE = V_CHARGE_CODE
                      AND CHGAMT_PROD_CODE =
                             V_CHARGE_KEY (W_CHARGE_ROW_POSTION).CHARGES_PROD_CODE
                      AND CHGAMT_AC_TYPE =
                             V_CHARGE_KEY (W_CHARGE_ROW_POSTION).CHARGES_AC_TYPE
                      AND CHGAMT_ACSUB_TYPE =
                             V_CHARGE_KEY (W_CHARGE_ROW_POSTION).CHARGES_ACSUB_TYPE
                      AND CHGAMT_SCHEME_CODE =
                             V_CHARGE_KEY (W_CHARGE_ROW_POSTION).CHARGES_SCHEME_CODE
                      AND CHGAMT_CHG_TYPE =
                             V_CHARGE_KEY (W_CHARGE_ROW_POSTION).CHARGES_CHG_TYPE
                      AND CHGAMT_CHG_CURR = V_CHARGE_CURR_CODE
                      AND CHGAMT_TENOR_SL = 1
             ORDER BY CHGAMT_AMT_SL)
      LOOP
         IF V_CHARGE_ROW.CHARGES_SLAB_AMT_CHOICE = 'A'
         THEN
            V_UPTO_AMOUNT := NVL (IDX_REC.CHGAMT_UPTO_AMT, 0);
         ELSE
            V_UPTO_AMOUNT := P_AMOUNT * IDX_REC.CHGAMT_UPTO_PER / 100;
         END IF;

         IF V_CHARGE_ROW.CHARGES_CHG_SLAB_CHOICE = 'S'
         THEN
            IF P_AMOUNT <= V_UPTO_AMOUNT OR V_UPTO_AMOUNT = 0
            THEN
               V_CHGS_AMT :=
                  CALC_TENOR_AMT (P_AMOUNT,
                                  'S',
                                  0,
                                  IDX_REC);
               EXIT;
            END IF;
         ELSE
            IF V_UPTO_AMOUNT >= 0
            THEN
               IF V_UPTO_AMOUNT <= P_AMOUNT AND V_UPTO_AMOUNT > 0
               THEN
                  V_CHGS_AMT :=
                       V_CHGS_AMT
                     + CALC_TENOR_AMT (V_UPTO_AMOUNT,
                                       'M',
                                       V_PRE_UPTO_AMOUNT,
                                       IDX_REC);

                  IF V_UPTO_AMOUNT = P_AMOUNT
                  THEN
                     EXIT;
                  END IF;
               ELSIF V_UPTO_AMOUNT = 0 OR V_UPTO_AMOUNT >= P_AMOUNT
               THEN
                  V_CHGS_AMT :=
                       V_CHGS_AMT
                     + CALC_TENOR_AMT (P_AMOUNT,
                                       'M',
                                       V_PRE_UPTO_AMOUNT,
                                       IDX_REC);
                  EXIT;
               END IF;
            END IF;
         END IF;

         V_PRE_UPTO_AMOUNT := V_UPTO_AMOUNT;
      END LOOP;

      RETURN (V_CHGS_AMT);
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         V_ERR_MSG :=
            'Tenor/Variable Charges not Defined for the Supplied Tenor';
         RETURN (0);
   END;

   FUNCTION GET_FIXED_TENOR_CHGS (P_AMOUNT IN FLOAT)
      RETURN FLOAT
   IS
      V_TENOR_CHG   FLOAT DEFAULT 0;
      V_CHG_AMT     FLOAT DEFAULT 0;
   BEGIN
      V_TENOR_CHG := GET_TENOR_CHARGES (P_AMOUNT);

      CASE V_CHARGE_ROW.CHARGES_COMBINATION_CHOICE
         WHEN '1'
         THEN
            V_CHG_AMT :=
               LEAST (NVL (V_CHARGE_ROW.CHARGES_FIXED_AMT, 0), V_TENOR_CHG);
         WHEN '2'
         THEN
            V_CHG_AMT :=
               GREATEST (NVL (V_CHARGE_ROW.CHARGES_FIXED_AMT, 0),
                         V_TENOR_CHG);
         ELSE
            V_CHG_AMT := NVL (V_CHARGE_ROW.CHARGES_FIXED_AMT, 0) + V_TENOR_CHG;
      END CASE;

      RETURN (GET_MIN_MAX_AMOUNT (V_CHG_AMT));
   END;

   PROCEDURE GET_CHARGE_CURR_CODE
   IS
      W_TEMP_CURR_CODE   VARCHAR2 (3);
   BEGIN
      W_TEMP_CURR_CODE := '';

      BEGIN
         SELECT C.CHGCD_CHG_CURR_CODE
           INTO W_TEMP_CURR_CODE
           FROM CHGCD C
          WHERE C.CHGCD_CHARGE_CODE = V_CHARGE_CODE;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            W_TEMP_CURR_CODE := '';
      END;

      IF TRIM (W_TEMP_CURR_CODE) IS NULL
      THEN
         V_CHARGE_CURR_CODE := V_TRAN_CURR_CODE;
      ELSE
         V_CHARGE_CURR_CODE := W_TEMP_CURR_CODE;
      END IF;
   END;

   FUNCTION CHECK_INPUT_VALUES
      RETURN BOOLEAN
   IS
   BEGIN
      V_DUMMY := 0;

      IF V_ACCOUNT_NUMBER = 0
      THEN
         W_ACCOUNT_CURR_CODE := ' ';
         W_CLIENT_CODE := 0;
      ELSE
         BEGIN
            SELECT 1, A.ACNTS_CURR_CODE, A.ACNTS_CLIENT_NUM
              INTO V_DUMMY, W_ACCOUNT_CURR_CODE, W_CLIENT_CODE
              FROM ACNTS A
             WHERE     ACNTS_ENTITY_NUM = V_GLOB_ENTITY_NUM
                   AND A.ACNTS_INTERNAL_ACNUM = V_ACCOUNT_NUMBER;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               V_ERR_MSG := 'Invalid Account Number';
               V_ERROR_STATUS := 1;
               RETURN FALSE;
         END;
      END IF;

      IF TRIM (V_TRAN_CURR_CODE) IS NULL AND V_TRAN_AMOUNT > 0
      THEN
         V_ERR_MSG := 'Transaction Currency Should be Specified';
         V_ERROR_STATUS := 1;
         RETURN FALSE;
      END IF;

      IF     V_TRAN_AMOUNT = 0
         AND TRIM (V_TRAN_CURR_CODE) IS NULL
         AND TRIM (V_CHARGE_CURR_CODE) IS NULL
      THEN
         V_CHARGE_CURR_CODE := W_ACCOUNT_CURR_CODE;
      END IF;

      IF TRIM (V_CHARGE_CODE) IS NULL
      THEN
         V_ERR_MSG := 'Charge Code Should be Specified';
         V_ERROR_STATUS := 1;
         RETURN FALSE;
      END IF;

      V_CHARGE_KEY.DELETE;

      RETURN TRUE;
   END;

   PROCEDURE PROCESS_FOR_CHARGE_AMOUNT
   IS
   BEGIN
      BEGIN
         SELECT *
           INTO V_CHARGE_ROW
           FROM CHARGES C
          WHERE     CHARGES_ENTITY_NUM = V_GLOB_ENTITY_NUM
                AND C.CHARGES_CHG_CODE = V_CHARGE_CODE
                AND C.CHARGES_PROD_CODE =
                       V_CHARGE_KEY (W_CHARGE_ROW_POSTION).CHARGES_PROD_CODE
                AND C.CHARGES_AC_TYPE =
                       V_CHARGE_KEY (W_CHARGE_ROW_POSTION).CHARGES_AC_TYPE
                AND C.CHARGES_ACSUB_TYPE =
                       V_CHARGE_KEY (W_CHARGE_ROW_POSTION).CHARGES_ACSUB_TYPE
                AND C.CHARGES_SCHEME_CODE =
                       V_CHARGE_KEY (W_CHARGE_ROW_POSTION).CHARGES_SCHEME_CODE
                AND C.CHARGES_CHG_TYPE =
                       V_CHARGE_KEY (W_CHARGE_ROW_POSTION).CHARGES_CHG_TYPE
                AND C.CHARGES_CHG_CURR = V_CHARGE_CURR_CODE;
      EXCEPTION
         WHEN OTHERS
         THEN
            V_CHARGE_ROW := NULL;
      END;
   END;

   PROCEDURE GET_BEGIN_VALUES
   IS
   BEGIN
      SELECT A.ACNTS_PROD_CODE,
             NVL (A.ACNTS_AC_TYPE, ' '),
             A.ACNTS_AC_SUB_TYPE,
             NVL (A.ACNTS_SCHEME_CODE, ' ')
        INTO W_CHARGES_PROD_CODE,
             W_CHARGES_AC_TYPE,
             W_CHARGES_ACSUB_TYPE,
             W_CHARGES_SCHEME_CODE
        FROM ACNTS A
       WHERE     ACNTS_ENTITY_NUM = V_GLOB_ENTITY_NUM
             AND A.ACNTS_INTERNAL_ACNUM = V_ACCOUNT_NUMBER;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         W_CHARGES_PROD_CODE := 0;
         W_CHARGES_AC_TYPE := ' ';
         W_CHARGES_ACSUB_TYPE := 0;
         W_CHARGES_SCHEME_CODE := ' ';
   END;

   PROCEDURE FIND_CHARGE_ROW_POSITION
   IS
   BEGIN
      W_CHARGE_ROW_POSTION := 0;

     <<LOOPC>>
      FOR IDX IN 1 .. V_CHARGE_KEY.COUNT
      LOOP
         IF     V_CHARGE_KEY (IDX).CHARGES_PROD_CODE = W_CHARGES_PROD_CODE
            AND V_CHARGE_KEY (IDX).CHARGES_AC_TYPE = W_CHARGES_AC_TYPE
            AND V_CHARGE_KEY (IDX).CHARGES_ACSUB_TYPE = W_CHARGES_ACSUB_TYPE
            AND V_CHARGE_KEY (IDX).CHARGES_SCHEME_CODE =
                   W_CHARGES_SCHEME_CODE
            AND V_CHARGE_KEY (IDX).CHARGES_CHG_TYPE = W_CHARGES_CHG_TYPE
         THEN
            W_CHARGE_ROW_POSTION := IDX;
            EXIT LOOPC;
         END IF;
      END LOOP;
   END;

   PROCEDURE SET_THE_WORKING_VALUES
   IS
   BEGIN
      W_CHARGES_PROD_CODE := W_ORIG_CHARGES_PROD_CODE;
      W_CHARGES_AC_TYPE := W_ORIG_CHARGES_AC_TYPE;
      W_CHARGES_ACSUB_TYPE := W_ORIG_CHARGES_ACSUB_TYPE;
      W_CHARGES_SCHEME_CODE := W_ORIG_CHARGES_SCHEME_CODE;
      W_CHARGES_CHG_TYPE := W_ORIG_CHARGES_CHG_TYPE;

      IF W_INDEX = 1
      THEN
         W_CHARGES_PROD_CODE := W_ORIG_CHARGES_PROD_CODE;
         W_CHARGES_AC_TYPE := W_ORIG_CHARGES_AC_TYPE;
         W_CHARGES_ACSUB_TYPE := W_ORIG_CHARGES_ACSUB_TYPE;
         W_CHARGES_SCHEME_CODE := W_ORIG_CHARGES_SCHEME_CODE;
         W_CHARGES_CHG_TYPE := W_ORIG_CHARGES_CHG_TYPE;
      ELSIF W_INDEX = 2
      THEN
         W_CHARGES_CHG_TYPE := 'A';
      ELSIF W_INDEX = 3
      THEN
         W_CHARGES_SCHEME_CODE := ' ';
      ELSIF W_INDEX = 4
      THEN
         W_CHARGES_SCHEME_CODE := ' ';
         W_CHARGES_CHG_TYPE := 'A';
      ELSIF W_INDEX = 5
      THEN
         W_CHARGES_ACSUB_TYPE := 0;
      ELSIF W_INDEX = 6
      THEN
         W_CHARGES_CHG_TYPE := 'A';
         W_CHARGES_ACSUB_TYPE := 0;
      ELSIF W_INDEX = 7
      THEN
         W_CHARGES_SCHEME_CODE := ' ';
         W_CHARGES_ACSUB_TYPE := 0;
      ELSIF W_INDEX = 8
      THEN
         W_CHARGES_SCHEME_CODE := ' ';
         W_CHARGES_CHG_TYPE := 'A';
         W_CHARGES_ACSUB_TYPE := 0;
      ELSIF W_INDEX = 9
      THEN
         W_CHARGES_AC_TYPE := ' ';
         W_CHARGES_ACSUB_TYPE := 0;
      ELSIF W_INDEX = 10
      THEN
         W_CHARGES_AC_TYPE := ' ';
         W_CHARGES_CHG_TYPE := 'A';
         W_CHARGES_ACSUB_TYPE := 0;
      ELSIF W_INDEX = 11
      THEN
         W_CHARGES_AC_TYPE := ' ';
         W_CHARGES_SCHEME_CODE := ' ';
         W_CHARGES_ACSUB_TYPE := 0;
      ELSIF W_INDEX = 12
      THEN
         W_CHARGES_AC_TYPE := ' ';
         W_CHARGES_SCHEME_CODE := ' ';
         W_CHARGES_CHG_TYPE := 'A';
         W_CHARGES_ACSUB_TYPE := 0;
      ELSIF W_INDEX = 13
      THEN
         W_CHARGES_PROD_CODE := 0;
      ELSIF W_INDEX = 14
      THEN
         W_CHARGES_PROD_CODE := 0;
         W_CHARGES_AC_TYPE := ' ';
         W_CHARGES_ACSUB_TYPE := 0;
      ELSIF W_INDEX = 15
      THEN
         W_CHARGES_PROD_CODE := 0;
         W_CHARGES_AC_TYPE := ' ';
         W_CHARGES_CHG_TYPE := 'A';
         W_CHARGES_ACSUB_TYPE := 0;
      ELSIF W_INDEX = 16
      THEN
         W_CHARGES_PROD_CODE := 0;
         W_CHARGES_AC_TYPE := ' ';
         W_CHARGES_SCHEME_CODE := ' ';
         W_CHARGES_ACSUB_TYPE := 0;
      ELSIF W_INDEX = 17
      THEN
         W_CHARGES_PROD_CODE := 0;
         W_CHARGES_AC_TYPE := ' ';
         W_CHARGES_SCHEME_CODE := ' ';
         W_CHARGES_CHG_TYPE := 'A';
         W_CHARGES_ACSUB_TYPE := 0;
      END IF;
   END;

   PROCEDURE PROCESS_GET_CHARGE_ROW
   IS
   BEGIN
      W_INDEX := 1;
      W_ORIG_CHARGES_PROD_CODE := W_CHARGES_PROD_CODE;
      W_ORIG_CHARGES_AC_TYPE := W_CHARGES_AC_TYPE;
      W_ORIG_CHARGES_ACSUB_TYPE := W_CHARGES_ACSUB_TYPE;
      W_ORIG_CHARGES_SCHEME_CODE := W_CHARGES_SCHEME_CODE;
      W_ORIG_CHARGES_CHG_TYPE := W_CHARGES_CHG_TYPE;

      WHILE W_CHARGE_ROW_POSTION = 0 AND W_INDEX <= 17
      LOOP
         SET_THE_WORKING_VALUES;
         FIND_CHARGE_ROW_POSITION;
         W_INDEX := W_INDEX + 1;
      END LOOP;

      IF W_CHARGE_ROW_POSTION <> 0
      THEN
         PROCESS_FOR_CHARGE_AMOUNT;

         CASE V_CHARGE_ROW.CHARGES_CHG_AMT_CHOICE
            WHEN '1'
            THEN
               -- Fixed Amount
               V_CHARGE_AMOUNT := NVL (V_CHARGE_ROW.CHARGES_FIXED_AMT, 0);
               V_CHARGE_AMOUNT := GET_NOOF_DAYS_FACTOR (V_CHARGE_AMOUNT);
            WHEN '2'
            THEN
               -- Percentage
               V_CHARGE_AMOUNT :=
                  (GET_MIN_MAX_AMOUNT (
                        V_TRAN_AMOUNT
                      * V_CHARGE_ROW.CHARGES_CHGS_PERCENTAGE
                      / 100));
            WHEN '3'
            THEN
               -- Tenor/Variable
               V_CHARGE_AMOUNT :=
                  (GET_MIN_MAX_AMOUNT (GET_TENOR_CHARGES (V_TRAN_AMOUNT)));
            WHEN '4'
            THEN
               -- Fixed Percentage
               V_CHARGE_AMOUNT := (GET_FIXED_PERCENT_CHGS (V_TRAN_AMOUNT));
            WHEN '5'
            THEN
               -- Fixed Tenor/Variable
               V_CHARGE_AMOUNT := (GET_FIXED_TENOR_CHGS (V_TRAN_AMOUNT));
            ELSE
               V_ERR_MSG := 'Incorrect Charge Amount Choice';
         END CASE;
      END IF;
   END;

   PROCEDURE GET_VALUES_FROM_CHARGES
   IS
   BEGIN
      EXECUTE IMMEDIATE W_CHARGE_SQL
         BULK COLLECT INTO V_CHARGE_KEY
         USING V_GLOB_ENTITY_NUM, V_CHARGE_CODE, V_CHARGE_CURR_CODE;

      IF V_CHARGE_KEY.COUNT > 0
      THEN
         GET_BEGIN_VALUES;
         PROCESS_GET_CHARGE_ROW;
      END IF;
   END;

   PROCEDURE PROCESS_FOR_CHARGE_CALC
   IS
   BEGIN
      IF CHECK_INPUT_VALUES = TRUE
      THEN
         GET_VALUES_FROM_CHARGES;
      END IF;
   END;

   PROCEDURE CHECK_FOR_CL_BAND_LVL_WAIVER
   IS
      W_REL_BAND_CODE       VARCHAR2 (6);
      W_CHARGE_PERCENTAGE   NUMBER (5, 2);
   BEGIN
      BEGIN
         W_REL_BAND_CODE := '';
         W_CHARGE_PERCENTAGE := 0;

         SELECT C.CLRELBAND_REL_BAND_CODE
           INTO W_REL_BAND_CODE
           FROM CLRELBAND C
          WHERE     CLRELBAND_ENTITY_NUM = V_GLOB_ENTITY_NUM
                AND C.CLRELBAND_CUST_NUM = W_CLIENT_CODE;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            W_REL_BAND_CODE := '';
      END;

      IF TRIM (W_REL_BAND_CODE) IS NOT NULL
      THEN
         BEGIN
            SELECT C.CRELBCHGDTL_WAIVE_PER
              INTO W_CHARGE_PERCENTAGE
              FROM CRELBCHGDTL C
             WHERE     CRELBCHGDTL_ENTITY_NUM = V_GLOB_ENTITY_NUM
                   AND C.CRELBCHGDTL_CUSTREL_BAND = W_REL_BAND_CODE
                   AND C.CRELBCHGDTL_CHG_CODE = V_CHARGE_CODE;

            V_AC_LEVEL_WAIVER_PRESENT := TRUE;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               W_CHARGE_PERCENTAGE := 0;
            WHEN OTHERS
            THEN
               W_CHARGE_PERCENTAGE := 0;
         END;
      END IF;

      IF V_AC_LEVEL_WAIVER_PRESENT = TRUE
      THEN
         V_CHARGE_AMOUNT :=
            V_CHARGE_AMOUNT - (V_CHARGE_AMOUNT * (W_CHARGE_PERCENTAGE / 100));

         IF V_CHARGE_AMOUNT < 0
         THEN
            V_CHARGE_AMOUNT := 0;
         END IF;
      END IF;
   END;

   PROCEDURE CHECK_FOR_CHGWAIVEDTL
   IS
      W_CLCHGWAIVDT_WAIVER_TYPE    CHAR (1);
      W_CLCHGWAIVDT_DISCOUNT_PER   NUMBER (4, 2);
   BEGIN
      V_AC_LEVEL_WAIVER_PRESENT := FALSE;
      V_AC_LEVEL_WAIVER_REC_FOUND := FALSE;
      CHECK_FOR_CL_BAND_LVL_WAIVER;

      IF V_AC_LEVEL_WAIVER_PRESENT = FALSE
      THEN        
         BEGIN
            SELECT CC.CLCHGWAIVDT_WAIVER_TYPE, CC.CLCHGWAIVDT_DISCOUNT_PER
              INTO W_CLCHGWAIVDT_WAIVER_TYPE, W_CLCHGWAIVDT_DISCOUNT_PER
              FROM CLCHGWAIVEDTL CC
             WHERE     CLCHGWAIVDT_ENTITY_NUM = V_GLOB_ENTITY_NUM
                   AND CC.CLCHGWAIVDT_CLIENT_NUM = 0
                   AND CC.CLCHGWAIVDT_INTERNAL_ACNUM = V_ACCOUNT_NUMBER
                   AND CC.CLCHGWAIVDT_CHARGE_CODE = V_CHARGE_CODE;

            IF SQL%FOUND
            THEN
               V_AC_LEVEL_WAIVER_REC_FOUND := TRUE;

               IF TRIM (W_CLCHGWAIVDT_WAIVER_TYPE) = 'F'
               THEN
                  V_CHARGE_AMOUNT := 0;
               ELSIF TRIM (W_CLCHGWAIVDT_WAIVER_TYPE) = 'P'
               THEN
                  V_CHARGE_AMOUNT :=
                       V_CHARGE_AMOUNT
                     - (V_CHARGE_AMOUNT * W_CLCHGWAIVDT_DISCOUNT_PER) / 100;
               END IF;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               V_CHARGE_AMOUNT := V_CHARGE_AMOUNT;
         END;

         IF V_AC_LEVEL_WAIVER_REC_FOUND = FALSE
         THEN
            BEGIN
               SELECT CC.CLCHGWAIVDT_WAIVER_TYPE, CC.CLCHGWAIVDT_DISCOUNT_PER
                 INTO W_CLCHGWAIVDT_WAIVER_TYPE, W_CLCHGWAIVDT_DISCOUNT_PER
                 FROM CLCHGWAIVEDTL CC
                WHERE     CLCHGWAIVDT_ENTITY_NUM = V_GLOB_ENTITY_NUM
                      AND CC.CLCHGWAIVDT_CLIENT_NUM = W_CLIENT_CODE
                      AND CC.CLCHGWAIVDT_INTERNAL_ACNUM = 0
                      AND CC.CLCHGWAIVDT_CHARGE_CODE = V_CHARGE_CODE;

               IF SQL%FOUND
               THEN
                  V_AC_LEVEL_WAIVER_REC_FOUND := TRUE;

                  IF TRIM (W_CLCHGWAIVDT_WAIVER_TYPE) = 'F'
                  THEN
                     V_CHARGE_AMOUNT := 0;
                  ELSIF TRIM (W_CLCHGWAIVDT_WAIVER_TYPE) = 'P'
                  THEN
                     V_CHARGE_AMOUNT :=
                          V_CHARGE_AMOUNT
                        -   (V_CHARGE_AMOUNT * W_CLCHGWAIVDT_DISCOUNT_PER)
                          / 100;
                  END IF;
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  V_CHARGE_AMOUNT := V_CHARGE_AMOUNT;
            END;
         END IF;
      END IF;
   END;

   PROCEDURE CHECK_FOR_SERVICE_CHARGE
   IS
   BEGIN
      PKG_SERVICE_CHARGE_CALC.SP_SERVICE_CHARGES (V_GLOB_ENTITY_NUM,
                                                  V_ACCOUNT_NUMBER,
                                                  V_CHARGE_CODE,
                                                  V_CHARGE_CURR_CODE,
                                                  V_CHARGE_AMOUNT,
                                                  V_SERVICE_AMOUNT,
                                                  V_SERVICE_STAX_AMOUNT,
                                                  V_SERVICE_ADDN_AMOUNT,
                                                  V_SERVICE_CESS_AMOUNT,
                                                  V_ERR_MSG);
   EXCEPTION
      WHEN OTHERS
      THEN
         V_ERR_MSG := 'Error in Service Calculation Processing';
   END;

   PROCEDURE SP_GET_CHARGES (V_ENTITY_NUM            IN            NUMBER,
                             P_ACCOUNT_NUMBER        IN            NUMBER,
                             P_TRAN_CURR_CODE        IN            VARCHAR2,
                             P_TRAN_AMOUNT           IN            NUMBER,
                             P_CHARGE_CODE           IN            VARCHAR2,
                             P_CHG_TYPE              IN            VARCHAR2,
                             P_CHARGE_CURR_CODE         OUT NOCOPY VARCHAR2,
                             P_CHARGE_AMOUNT            OUT NOCOPY FLOAT,
                             P_SERVICE_AMOUNT           OUT NOCOPY FLOAT,
                             P_SERVICE_STAX_AMOUNT      OUT NOCOPY FLOAT,
                             P_SERVICE_ADDN_AMOUNT      OUT NOCOPY FLOAT,
                             P_SERVICE_CESS_AMOUNT      OUT NOCOPY FLOAT,
                             P_ERR_MSG                  OUT NOCOPY VARCHAR2)
   IS
   BEGIN
      PKG_ENTITY.SP_SET_ENTITY_CODE (V_ENTITY_NUM);
      V_GLOB_ENTITY_NUM := V_ENTITY_NUM;
      INIT_PARA;

      BEGIN
         V_ACCOUNT_NUMBER := P_ACCOUNT_NUMBER;
         V_TRAN_CURR_CODE := P_TRAN_CURR_CODE;
         V_TRAN_AMOUNT := ABS (P_TRAN_AMOUNT);
         V_CHARGE_CODE := P_CHARGE_CODE;
         V_CHARGE_CURR_CODE := P_CHARGE_CURR_CODE;

         IF TRIM (V_CHARGE_CURR_CODE) IS NULL
         THEN
            V_CHARGE_CURR_CODE := V_TRAN_CURR_CODE;
         END IF;

         W_CHARGES_CHG_TYPE := P_CHG_TYPE;
         PROCESS_FOR_CHARGE_CALC;
      EXCEPTION
         WHEN OTHERS
         THEN
            V_ERR_MSG := 'Error in Charge Calculation Processing..';
            V_CHARGE_AMOUNT := 0;
            V_CHARGE_CURR_CODE := ' ';
      END;

--      IF V_CHARGE_AMOUNT > 0
--      THEN
--         CHECK_FOR_CHGWAIVEDTL;
--      END IF;

      V_CHARGE_AMOUNT := GET_ROUNDOFF_AMT (V_CHARGE_AMOUNT);

      IF V_CHARGE_AMOUNT > 0
      THEN
         CHECK_FOR_SERVICE_CHARGE;
      END IF;

      IF V_CHARGE_AMOUNT > 0
      THEN
         V_CHARGE_AMOUNT :=
            SP_GETFORMAT (V_GLOB_ENTITY_NUM,
                          V_CHARGE_CURR_CODE,
                          V_CHARGE_AMOUNT,
                          1);
      END IF;

      V_CHARGE_KEY.DELETE;
      V_CHARGE_ROW := NULL;

      P_CHARGE_AMOUNT := ABS (V_CHARGE_AMOUNT);

      GET_CHARGE_CURR_CODE;

      P_CHARGE_CURR_CODE := V_CHARGE_CURR_CODE;
      P_ERR_MSG := V_ERR_MSG;
      P_SERVICE_AMOUNT := V_SERVICE_AMOUNT;
      P_SERVICE_STAX_AMOUNT := V_SERVICE_STAX_AMOUNT;
      P_SERVICE_ADDN_AMOUNT := V_SERVICE_ADDN_AMOUNT;
      P_SERVICE_CESS_AMOUNT := V_SERVICE_CESS_AMOUNT;
   END;
BEGIN
   W_CHARGE_SQL :=
      'SELECT CHARGES_PROD_CODE,
                       CHARGES_AC_TYPE,
                       CHARGES_ACSUB_TYPE,
                       CHARGES_SCHEME_CODE,
                       CHARGES_CHG_TYPE FROM CHARGES C WHERE CHARGES_ENTITY_NUM = :1 AND C.CHARGES_CHG_CODE = :2 AND C.CHARGES_CHG_CURR = :3';
END;
/
