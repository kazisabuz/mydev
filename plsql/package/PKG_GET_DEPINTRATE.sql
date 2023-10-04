CREATE OR REPLACE PACKAGE PKG_GET_DEPINTRATE
IS
   TYPE REC_RETURN_TABLE IS RECORD
   (
      DEPIRHDT_EFF_FROM_DATE   DATE,
      DEPIRHDT_EFF_UPTO_DATE   DATE,
      DEPIRHDT_INT_RATE        NUMBER (18, 3)
   );

   TYPE TY_RETURN_TABLE IS TABLE OF REC_RETURN_TABLE;

   FUNCTION FN_GET_DEPINTRATE (P_ENTITY_CODE       NUMBER,
                               P_ACCOUNT_NUMBER    NUMBER,
                               P_FROM_DATE         DATE,
                               P_TO_DATE           DATE)
      RETURN TY_RETURN_TABLE
      PIPELINED;
--RETURN VARCHAR2;
END;
/

CREATE OR REPLACE PACKAGE BODY PKG_GET_DEPINTRATE
IS
   FUNCTION FN_GET_DEPINTRATE (P_ENTITY_CODE       NUMBER,
                               P_ACCOUNT_NUMBER    NUMBER,
                               P_FROM_DATE         DATE,
                               P_TO_DATE           DATE)
      RETURN TY_RETURN_TABLE
      PIPELINED
   --RETURN VARCHAR2
   IS
      RET_RETURN_TABLE   REC_RETURN_TABLE;

      V_ERRM             VARCHAR2 (4000);
      V_SLAB_SL          NUMBER;
      V_TENOR_SL         NUMBER;
      V_SLAB_AMOUNT      NUMBER;
      V_SLAB_FLAG        CHAR;
      V_TENOR_FLAG       CHAR;
      V_EFFECTIVE_DATE   DATE;
      V_PERIOD           NUMBER;
      V_ASKED_TENOR      NUMBER := 0;
   BEGIN
      FOR ACNT_REC
         IN (SELECT PBDCONT_EFF_DATE,
                    PBDCONT_MAT_DATE,
                    PBDCONT_AC_DEP_AMT,
                    PDBCONT_DEP_PRD_MONTHS,
                    ACNTS_PROD_CODE,
                    ACNTS_AC_TYPE,
                    ACNTS_AC_SUB_TYPE,
                    ACNTS_CURR_CODE
               FROM PBDCONTRACT, ACNTS
              WHERE     ACNTS_ENTITY_NUM = PBDCONT_ENTITY_NUM
                    AND ACNTS_INTERNAL_ACNUM = PBDCONT_DEP_AC_NUM
                    AND PBDCONT_ENTITY_NUM = P_ENTITY_CODE
                    AND PBDCONT_DEP_AC_NUM = P_ACCOUNT_NUMBER
                    AND ACNTS_INTERNAL_ACNUM = P_ACCOUNT_NUMBER)
      LOOP
         FOR IDX_REC_DEP
            IN (  SELECT DEPIRTAMTH_SLAB_SL,
                         DEPIRTAMTH_UPTO_AMT,
                         DEPIRTAMTH_INCLUDE_FLG
                    FROM DEPIRTENORAMTHIST
                   WHERE     DEPIRTAMTH_PROD_CODE = ACNT_REC.ACNTS_PROD_CODE
                         AND DEPIRTAMTH_CURR_CODE = ACNT_REC.ACNTS_CURR_CODE
                         AND DEPIRTAMTH_EFF_DATE =
                                (SELECT MAX (DEPIRTAMTH_EFF_DATE)
                                   FROM DEPIRTENORAMTHIST
                                  WHERE     DEPIRTAMTH_PROD_CODE =
                                               ACNT_REC.ACNTS_PROD_CODE
                                        AND DEPIRTAMTH_CURR_CODE =
                                               ACNT_REC.ACNTS_CURR_CODE
                                        AND DEPIRTAMTH_EFF_DATE <=
                                               ACNT_REC.PBDCONT_EFF_DATE)
                ORDER BY DEPIRTAMTH_SLAB_SL)
         LOOP
            V_SLAB_SL := 0;

            IF IDX_REC_DEP.DEPIRTAMTH_SLAB_SL > 0
            THEN
               V_SLAB_AMOUNT := IDX_REC_DEP.DEPIRTAMTH_UPTO_AMT;
               V_SLAB_FLAG := IDX_REC_DEP.DEPIRTAMTH_INCLUDE_FLG;

               IF V_SLAB_FLAG = 'E'
               THEN
                  IF ACNT_REC.PBDCONT_AC_DEP_AMT < V_SLAB_AMOUNT
                  THEN
                     V_SLAB_SL := IDX_REC_DEP.DEPIRTAMTH_SLAB_SL;
                     EXIT;
                  END IF;
               ELSE
                  IF V_SLAB_FLAG = 'I'
                  THEN
                     IF ACNT_REC.PBDCONT_AC_DEP_AMT <= V_SLAB_AMOUNT
                     THEN
                        V_SLAB_SL := IDX_REC_DEP.DEPIRTAMTH_SLAB_SL;
                        EXIT;
                     END IF;
                  END IF;
               END IF;
            END IF;
         END LOOP;


         FOR IDX_REC_DEP
            IN (  SELECT DEPIRTSH_TENOR_SL,
                         DEPIRTSH_TENOR_PERIOD,
                         DEPIRTSH_TENOR_FLG,
                         DEPIRTSH_INCLUDE_FLG
                    FROM DEPIRTENORTSHIST
                   WHERE     DEPIRTSH_PROD_CODE = ACNT_REC.ACNTS_PROD_CODE
                         AND DEPIRTSH_CURR_CODE = ACNT_REC.ACNTS_CURR_CODE
                         AND DEPIRTSH_EFF_DATE =
                                (SELECT MAX (DEPIRTSH_EFF_DATE)
                                   FROM DEPIRTENORTSHIST
                                  WHERE     DEPIRTSH_PROD_CODE =
                                               ACNT_REC.ACNTS_PROD_CODE
                                        AND DEPIRTSH_CURR_CODE =
                                               ACNT_REC.ACNTS_CURR_CODE
                                        AND DEPIRTSH_EFF_DATE <=
                                               ACNT_REC.PBDCONT_EFF_DATE)
                ORDER BY DEPIRTSH_TENOR_SL)
         LOOP
            IF IDX_REC_DEP.DEPIRTSH_TENOR_SL > 0
            THEN
               V_TENOR_SL := 0;
               V_PERIOD := IDX_REC_DEP.DEPIRTSH_TENOR_PERIOD;
               V_TENOR_FLAG := IDX_REC_DEP.DEPIRTSH_TENOR_FLG;

               IF V_TENOR_FLAG = 'M'
               THEN
                  V_ASKED_TENOR :=
                     ROUND (
                        MONTHS_BETWEEN (ACNT_REC.PBDCONT_MAT_DATE,
                                        ACNT_REC.PBDCONT_EFF_DATE));
               ELSE
                  V_ASKED_TENOR :=
                     (ACNT_REC.PBDCONT_MAT_DATE - ACNT_REC.PBDCONT_EFF_DATE);
               END IF;

               IF IDX_REC_DEP.DEPIRTSH_INCLUDE_FLG = 'E'
               THEN
                  IF V_ASKED_TENOR < V_PERIOD
                  THEN
                     V_TENOR_SL := IDX_REC_DEP.DEPIRTSH_TENOR_SL;
                     EXIT;
                  END IF;
               ELSE
                  IF IDX_REC_DEP.DEPIRTSH_INCLUDE_FLG = 'I'
                  THEN
                     IF V_ASKED_TENOR <= V_PERIOD
                     THEN
                        V_TENOR_SL := IDX_REC_DEP.DEPIRTSH_TENOR_SL;
                        EXIT;
                     END IF;
                  END IF;
               END IF;
            END IF;
         END LOOP;

         --DBMS_OUTPUT.PUT_LINE(ACNT_REC.PBDCONT_EFF_DATE);

         FOR REC_INT
            IN (SELECT DEPIRHDT_AC_TYPE,
                       DEPIRHDT_AC_SUB_TYPE,
                       DEPIRHDT_INT_RATE,
                       (CASE
                           WHEN DEPIRHDT_EFF_DATE < ACNT_REC.PBDCONT_EFF_DATE
                           THEN
                              ACNT_REC.PBDCONT_EFF_DATE
                           ELSE
                              DEPIRHDT_EFF_DATE
                        END)
                          DEPIRHDT_EFF_FROM_DATE,
                       COALESCE (
                            LEAD (DEPIRHDT_EFF_DATE, 1)
                               OVER (ORDER BY DEPIRHDT_EFF_DATE)
                          - 1,
                          P_TO_DATE)
                          DEPIRHDT_EFF_UPTO_DATE
                  FROM DEPIRHDT
                 WHERE     DEPIRHDT_ENTITY_NUM = P_ENTITY_CODE
                       AND DEPIRHDT_PROD_CODE = ACNT_REC.ACNTS_PROD_CODE
                       AND DEPIRHDT_CURR_CODE = ACNT_REC.ACNTS_CURR_CODE
                       AND DEPIRHDT_AMT_SLAB_SL = V_SLAB_SL
                       AND DEPIRHDT_TENOR_SL = V_TENOR_SL
                       AND DEPIRHDT_EFF_DATE BETWEEN (SELECT MAX (
                                                                DEPIRHDT_EFF_DATE)
                                                        FROM DEPIRHDT
                                                       WHERE     DEPIRHDT_ENTITY_NUM =
                                                                    P_ENTITY_CODE
                                                             AND DEPIRHDT_PROD_CODE =
                                                                    ACNT_REC.ACNTS_PROD_CODE
                                                             AND DEPIRHDT_CURR_CODE =
                                                                    ACNT_REC.ACNTS_CURR_CODE
                                                             AND DEPIRHDT_AMT_SLAB_SL =
                                                                    V_SLAB_SL
                                                             AND DEPIRHDT_TENOR_SL =
                                                                    V_TENOR_SL
                                                             AND DEPIRHDT_EFF_DATE <=
                                                                    ACNT_REC.PBDCONT_EFF_DATE)
                                                 AND P_TO_DATE)
         LOOP
            IF TRIM (REC_INT.DEPIRHDT_AC_TYPE) IS NOT NULL
            THEN
               IF TRIM (REC_INT.DEPIRHDT_AC_TYPE) = ACNT_REC.ACNTS_AC_TYPE
               THEN
                  IF TRIM (REC_INT.DEPIRHDT_AC_SUB_TYPE) IS NOT NULL
                  THEN
                     IF TRIM (REC_INT.DEPIRHDT_AC_SUB_TYPE) =
                           ACNT_REC.ACNTS_AC_SUB_TYPE
                     THEN
                        RET_RETURN_TABLE.DEPIRHDT_EFF_FROM_DATE :=
                           REC_INT.DEPIRHDT_EFF_FROM_DATE;
                        RET_RETURN_TABLE.DEPIRHDT_INT_RATE :=
                           REC_INT.DEPIRHDT_INT_RATE;

                        RET_RETURN_TABLE.DEPIRHDT_EFF_UPTO_DATE :=
                           REC_INT.DEPIRHDT_EFF_UPTO_DATE;
                        PIPE ROW (RET_RETURN_TABLE);
                     END IF;
                  ELSE
                     RET_RETURN_TABLE.DEPIRHDT_EFF_FROM_DATE :=
                        REC_INT.DEPIRHDT_EFF_FROM_DATE;

                     RET_RETURN_TABLE.DEPIRHDT_EFF_UPTO_DATE :=
                        REC_INT.DEPIRHDT_EFF_UPTO_DATE;
                     RET_RETURN_TABLE.DEPIRHDT_INT_RATE :=
                        REC_INT.DEPIRHDT_INT_RATE;
                     PIPE ROW (RET_RETURN_TABLE);
                  END IF;
               END IF;
            ELSE
               RET_RETURN_TABLE.DEPIRHDT_EFF_FROM_DATE :=
                  REC_INT.DEPIRHDT_EFF_FROM_DATE;
               RET_RETURN_TABLE.DEPIRHDT_INT_RATE := REC_INT.DEPIRHDT_INT_RATE;

               RET_RETURN_TABLE.DEPIRHDT_EFF_UPTO_DATE :=
                  REC_INT.DEPIRHDT_EFF_UPTO_DATE;
               PIPE ROW (RET_RETURN_TABLE);
            END IF;
         END LOOP;
      END LOOP;

      RETURN;
   --RETURN ' VARCHAR2 ';

   EXCEPTION
      WHEN OTHERS
      THEN
         V_ERRM := SQLERRM;
         DBMS_OUTPUT.PUT_LINE (V_ERRM);
   END;
END;
/