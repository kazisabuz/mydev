CREATE OR REPLACE FUNCTION FN_GET_INTRATE_RUN_ACS_NEW (
   P_AC_NUM        IN NUMBER,
   P_PROD_CD       IN NUMBER,
   P_AC_CURR       IN VARCHAR2,
   P_AC_TYPE       IN VARCHAR2,
   P_AC_SUB_TYPE   IN VARCHAR2,
   P_INT_TYPE      IN CHAR DEFAULT 'C',
   P_ASON_DATE     IN DATE)
   RETURN NUMBER
IS
   W_IN_RATE            PRODIRHIST.PRODIRH_INT_RATE%TYPE := 0;
   W_AC_LEVEL_INT_RATE  ACNTIRHIST.ACNTIRH_AC_LEVEL_INT_RATE%TYPE;
   W_ENTITY_NUM         ENTITYNUM.ENTITYNUM_NUMBER%TYPE;
   W_BRN_CAT            BRNCAT.BRNCAT_CODE%TYPE;
   W_SLAB_REQD          PRODIRHIST.PRODIRH_SLAB_REQ%TYPE;
   W_SLAB_CHOICE        PRODIRHIST.PRODIRH_SLAB_CHOICE%TYPE := 'S';
   W_AC_BAL             ACNTBAL.ACNTBAL_AC_BAL%TYPE := 0;
   W_AC_BAL_CHECKED     PKG_COMMON_TYPES.SINGLE_CHAR := '0';

   PROCEDURE GET_EFF_BAL_ASON
   IS
   BEGIN
      BEGIN
         SELECT NVL(A.ACBALH_AC_BAL, 0)
           INTO W_AC_BAL
           FROM ACBALASONHIST A
          WHERE     A.ACBALH_ENTITY_NUM = W_ENTITY_NUM
                AND A.ACBALH_INTERNAL_ACNUM = P_AC_NUM
                AND A.ACBALH_ASON_DATE =
                       (SELECT MAX (B.ACBALH_ASON_DATE)
                          FROM ACBALASONHIST B
                         WHERE     B.ACBALH_ENTITY_NUM = A.ACBALH_ENTITY_NUM
                               AND B.ACBALH_INTERNAL_ACNUM =
                                      A.ACBALH_INTERNAL_ACNUM
                               AND B.ACBALH_ASON_DATE <= P_ASON_DATE);

         W_AC_BAL_CHECKED := '1';
      EXCEPTION
         WHEN OTHERS
         THEN
            W_AC_BAL_CHECKED := '1';
      END;
   END;

   PROCEDURE CHECK_PRODUCTLEVEL4_INTRATE
   IS
   BEGIN
      W_IN_RATE := 0;

      SELECT P.PRODIRH_INT_RATE, P.PRODIRH_SLAB_REQ, P.PRODIRH_SLAB_CHOICE
        INTO W_IN_RATE, W_SLAB_REQD, W_SLAB_CHOICE
        FROM PRODIRHIST P
       WHERE     P.PRODIRH_INT_DB_CR_FLG = P_INT_TYPE
             AND P.PRODIRH_PROD_CODE = P_PROD_CD
             AND P.PRODIRH_BRANCH_CAT = W_BRN_CAT
             AND P.PRODIRH_EFF_DATE =
                    (SELECT MAX (PRODIRH_EFF_DATE)
                       FROM PRODIRHIST
                      WHERE     PRODIRH_EFF_DATE <= P_ASON_DATE
                            AND PRODIRH_INT_DB_CR_FLG =
                                   P.PRODIRH_INT_DB_CR_FLG
                            AND PRODIRH_PROD_CODE = P.PRODIRH_PROD_CODE
                            AND PRODIRH_BRANCH_CAT = P.PRODIRH_BRANCH_CAT);

      IF     NVL (TRIM (W_SLAB_REQD), '0') = '1'
         AND NVL (TRIM (W_SLAB_CHOICE), 'S') = 'S'
      THEN
         IF W_AC_BAL_CHECKED = '0'
         THEN
            GET_EFF_BAL_ASON;
         END IF;

         IF W_AC_BAL_CHECKED = '1'
         THEN
            FOR REC
               IN (  SELECT PRODIRSH_UPTO_AMOUNT, PRODIRSH_INT_RATE
                       FROM PRODIRSLABHIST P
                      WHERE     PRODIRSH_ENTITY_NUM = W_ENTITY_NUM
                            AND PRODIRSH_BRANCH_CAT = W_BRN_CAT
                            AND PRODIRSH_PROD_CODE = P_PROD_CD
                            AND PRODIRSH_INT_DB_CR_FLG = P_INT_TYPE
                            AND PRODIRSH_EFF_DATE =
                                   (SELECT MAX (PRODIRSH_EFF_DATE)
                                      FROM PRODIRSLABHIST H
                                     WHERE     H.PRODIRSH_EFF_DATE <=
                                                  P_ASON_DATE
                                           AND H.PRODIRSH_ENTITY_NUM =
                                                  P.PRODIRSH_ENTITY_NUM
                                           AND H.PRODIRSH_BRANCH_CAT =
                                                  P.PRODIRSH_BRANCH_CAT
                                           AND H.PRODIRSH_PROD_CODE =
                                                  P.PRODIRSH_PROD_CODE
                                           AND H.PRODIRSH_INT_DB_CR_FLG =
                                                  P.PRODIRSH_INT_DB_CR_FLG)
                   ORDER BY PRODIRSH_DTL_SL)
            LOOP
               IF W_AC_BAL <= REC.PRODIRSH_UPTO_AMOUNT
               THEN
                  W_IN_RATE := REC.PRODIRSH_INT_RATE;
                  EXIT;
               END IF;
            END LOOP;
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         W_IN_RATE := 0;
   END;

   PROCEDURE CHECK_PRODUCTLEVEL3_INTRATE
   IS
   BEGIN
      W_IN_RATE := 0;

      SELECT P.PRODIRH_INT_RATE, P.PRODIRH_SLAB_REQ, P.PRODIRH_SLAB_CHOICE
        INTO W_IN_RATE, W_SLAB_REQD, W_SLAB_CHOICE
        FROM PRODIRHIST P
       WHERE     P.PRODIRH_INT_DB_CR_FLG = P_INT_TYPE
             AND P.PRODIRH_PROD_CODE = P_PROD_CD
             AND P.PRODIRH_BRANCH_CAT = W_BRN_CAT
             AND P.PRODIRH_CURR_CODE = P_AC_CURR
             AND TRIM (PRODIRH_AC_TYPE) IS NULL
             AND PRODIRH_ACSUB_TYPE = 0
             AND P.PRODIRH_EFF_DATE =
                    (SELECT MAX (PRODIRH_EFF_DATE)
                       FROM PRODIRHIST
                      WHERE     PRODIRH_EFF_DATE <= P_ASON_DATE
                            AND PRODIRH_INT_DB_CR_FLG =
                                   P.PRODIRH_INT_DB_CR_FLG
                            AND TRIM (PRODIRH_AC_TYPE) IS NULL
                            AND PRODIRH_ACSUB_TYPE = 0
                            AND PRODIRH_PROD_CODE = P.PRODIRH_PROD_CODE
                            AND PRODIRH_BRANCH_CAT = P.PRODIRH_BRANCH_CAT
                            AND PRODIRH_CURR_CODE = P.PRODIRH_CURR_CODE);

      IF     NVL (TRIM (W_SLAB_REQD), '0') = '1'
         AND NVL (TRIM (W_SLAB_CHOICE), 'S') = 'S'
      THEN
         IF W_AC_BAL_CHECKED = '0'
         THEN
            GET_EFF_BAL_ASON;
         END IF;

         IF W_AC_BAL_CHECKED = '1'
         THEN
            FOR REC
               IN (  SELECT PRODIRSH_UPTO_AMOUNT, PRODIRSH_INT_RATE
                       FROM PRODIRSLABHIST P
                      WHERE     PRODIRSH_ENTITY_NUM = W_ENTITY_NUM
                            AND PRODIRSH_BRANCH_CAT = W_BRN_CAT
                            AND PRODIRSH_PROD_CODE = P_PROD_CD
                            AND PRODIRSH_CURR_CODE = P_AC_CURR
                            AND TRIM (PRODIRSH_AC_TYPE) IS NULL
                            AND PRODIRSH_ACSUB_TYPE = 0
                            AND PRODIRSH_INT_DB_CR_FLG = P_INT_TYPE
                            AND PRODIRSH_EFF_DATE =
                                   (SELECT MAX (PRODIRSH_EFF_DATE)
                                      FROM PRODIRSLABHIST H
                                     WHERE     H.PRODIRSH_EFF_DATE <=
                                                  P_ASON_DATE
                                           AND H.PRODIRSH_ENTITY_NUM =
                                                  P.PRODIRSH_ENTITY_NUM
                                           AND H.PRODIRSH_BRANCH_CAT =
                                                  P.PRODIRSH_BRANCH_CAT
                                           AND H.PRODIRSH_PROD_CODE =
                                                  P.PRODIRSH_PROD_CODE
                                           AND H.PRODIRSH_CURR_CODE =
                                                  P.PRODIRSH_CURR_CODE
                                           AND TRIM (H.PRODIRSH_AC_TYPE)
                                                  IS NULL
                                           AND H.PRODIRSH_ACSUB_TYPE =
                                                  P.PRODIRSH_ACSUB_TYPE
                                           AND H.PRODIRSH_INT_DB_CR_FLG =
                                                  P.PRODIRSH_INT_DB_CR_FLG)
                   ORDER BY PRODIRSH_DTL_SL)
            LOOP
               IF W_AC_BAL <= REC.PRODIRSH_UPTO_AMOUNT
               THEN
                  W_IN_RATE := REC.PRODIRSH_INT_RATE;
                  EXIT;
               END IF;
            END LOOP;
         END IF;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         CHECK_PRODUCTLEVEL4_INTRATE;
      WHEN TOO_MANY_ROWS
      THEN
         W_IN_RATE := 0;
   END;

   PROCEDURE CHECK_PRODUCTLEVEL2_INTRATE
   IS
   BEGIN
      W_IN_RATE := 0;

      SELECT P.PRODIRH_INT_RATE, P.PRODIRH_SLAB_REQ, P.PRODIRH_SLAB_CHOICE
        INTO W_IN_RATE, W_SLAB_REQD, W_SLAB_CHOICE
        FROM PRODIRHIST P
       WHERE     P.PRODIRH_INT_DB_CR_FLG = P_INT_TYPE
             AND P.PRODIRH_PROD_CODE = P_PROD_CD
             AND P.PRODIRH_BRANCH_CAT = W_BRN_CAT
             AND P.PRODIRH_CURR_CODE = P_AC_CURR
             AND P.PRODIRH_AC_TYPE = P_AC_TYPE
             AND P.PRODIRH_EFF_DATE =
                    (SELECT MAX (PRODIRH_EFF_DATE)
                       FROM PRODIRHIST
                      WHERE     PRODIRH_EFF_DATE <= P_ASON_DATE
                            AND PRODIRH_INT_DB_CR_FLG =
                                   P.PRODIRH_INT_DB_CR_FLG
                            AND PRODIRH_PROD_CODE = P.PRODIRH_PROD_CODE
                            AND PRODIRH_BRANCH_CAT = P.PRODIRH_BRANCH_CAT
                            AND PRODIRH_CURR_CODE = P.PRODIRH_CURR_CODE
                            AND PRODIRH_AC_TYPE = P.PRODIRH_AC_TYPE);

      IF     NVL (TRIM (W_SLAB_REQD), '0') = '1'
         AND NVL (TRIM (W_SLAB_CHOICE), 'S') = 'S'
      THEN
         IF W_AC_BAL_CHECKED = '0'
         THEN
            GET_EFF_BAL_ASON;
         END IF;

         IF W_AC_BAL_CHECKED = '1'
         THEN
            FOR REC
               IN (  SELECT PRODIRSH_UPTO_AMOUNT, PRODIRSH_INT_RATE
                       FROM PRODIRSLABHIST P
                      WHERE     PRODIRSH_ENTITY_NUM = W_ENTITY_NUM
                            AND PRODIRSH_BRANCH_CAT = W_BRN_CAT
                            AND PRODIRSH_PROD_CODE = P_PROD_CD
                            AND PRODIRSH_CURR_CODE = P_AC_CURR
                            AND PRODIRSH_AC_TYPE = P_AC_TYPE
                            AND PRODIRSH_INT_DB_CR_FLG = P_INT_TYPE
                            AND PRODIRSH_EFF_DATE =
                                   (SELECT MAX (PRODIRSH_EFF_DATE)
                                      FROM PRODIRSLABHIST H
                                     WHERE     H.PRODIRSH_EFF_DATE <=
                                                  P_ASON_DATE
                                           AND H.PRODIRSH_ENTITY_NUM =
                                                  P.PRODIRSH_ENTITY_NUM
                                           AND H.PRODIRSH_BRANCH_CAT =
                                                  P.PRODIRSH_BRANCH_CAT
                                           AND H.PRODIRSH_PROD_CODE =
                                                  P.PRODIRSH_PROD_CODE
                                           AND H.PRODIRSH_CURR_CODE =
                                                  P.PRODIRSH_CURR_CODE
                                           AND H.PRODIRSH_AC_TYPE =
                                                  P.PRODIRSH_AC_TYPE
                                           AND H.PRODIRSH_INT_DB_CR_FLG =
                                                  P.PRODIRSH_INT_DB_CR_FLG)
                   ORDER BY PRODIRSH_DTL_SL)
            LOOP
               IF W_AC_BAL <= REC.PRODIRSH_UPTO_AMOUNT
               THEN
                  W_IN_RATE := REC.PRODIRSH_INT_RATE;
                  EXIT;
               END IF;
            END LOOP;
         END IF;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         CHECK_PRODUCTLEVEL3_INTRATE;
      WHEN TOO_MANY_ROWS
      THEN
         W_IN_RATE := 0;
   END;

   PROCEDURE CHECK_PRODUCTLEVEL1_INTRATE
   IS
   BEGIN
      W_IN_RATE := 0;

      SELECT P.PRODIRH_INT_RATE, P.PRODIRH_SLAB_REQ, P.PRODIRH_SLAB_CHOICE
        INTO W_IN_RATE, W_SLAB_REQD, W_SLAB_CHOICE
        FROM PRODIRHIST P
       WHERE     P.PRODIRH_INT_DB_CR_FLG = P_INT_TYPE
             AND P.PRODIRH_PROD_CODE = P_PROD_CD
             AND P.PRODIRH_BRANCH_CAT = W_BRN_CAT
             AND P.PRODIRH_CURR_CODE = P_AC_CURR
             AND P.PRODIRH_AC_TYPE = P_AC_TYPE
             AND P.PRODIRH_ACSUB_TYPE = P_AC_SUB_TYPE
             AND P.PRODIRH_EFF_DATE =
                    (SELECT MAX (PRODIRH_EFF_DATE)
                       FROM PRODIRHIST
                      WHERE     PRODIRH_EFF_DATE <= P_ASON_DATE
                            AND PRODIRH_INT_DB_CR_FLG =
                                   P.PRODIRH_INT_DB_CR_FLG
                            AND PRODIRH_PROD_CODE = P.PRODIRH_PROD_CODE
                            AND PRODIRH_BRANCH_CAT = P.PRODIRH_BRANCH_CAT
                            AND PRODIRH_CURR_CODE = P.PRODIRH_CURR_CODE
                            AND PRODIRH_AC_TYPE = P.PRODIRH_AC_TYPE
                            AND PRODIRH_ACSUB_TYPE = P.PRODIRH_ACSUB_TYPE);

      IF     NVL (TRIM (W_SLAB_REQD), '0') = '1'
         AND NVL (TRIM (W_SLAB_CHOICE), 'S') = 'S'
      THEN
         GET_EFF_BAL_ASON;

         IF W_AC_BAL_CHECKED = '1'
         THEN
            FOR REC
               IN (  SELECT PRODIRSH_UPTO_AMOUNT, PRODIRSH_INT_RATE
                       FROM PRODIRSLABHIST P
                      WHERE     PRODIRSH_ENTITY_NUM = W_ENTITY_NUM
                            AND PRODIRSH_BRANCH_CAT = W_BRN_CAT
                            AND PRODIRSH_PROD_CODE = P_PROD_CD
                            AND PRODIRSH_CURR_CODE = P_AC_CURR
                            AND PRODIRSH_AC_TYPE = P_AC_TYPE
                            AND PRODIRSH_ACSUB_TYPE = P_AC_SUB_TYPE
                            AND PRODIRSH_INT_DB_CR_FLG = P_INT_TYPE
                            AND PRODIRSH_EFF_DATE =
                                   (SELECT MAX (PRODIRSH_EFF_DATE)
                                      FROM PRODIRSLABHIST H
                                     WHERE     H.PRODIRSH_EFF_DATE <=
                                                  P_ASON_DATE
                                           AND H.PRODIRSH_ENTITY_NUM =
                                                  P.PRODIRSH_ENTITY_NUM
                                           AND H.PRODIRSH_BRANCH_CAT =
                                                  P.PRODIRSH_BRANCH_CAT
                                           AND H.PRODIRSH_PROD_CODE =
                                                  P.PRODIRSH_PROD_CODE
                                           AND H.PRODIRSH_CURR_CODE =
                                                  P.PRODIRSH_CURR_CODE
                                           AND H.PRODIRSH_AC_TYPE =
                                                  P.PRODIRSH_AC_TYPE
                                           AND H.PRODIRSH_ACSUB_TYPE =
                                                  P.PRODIRSH_ACSUB_TYPE
                                           AND H.PRODIRSH_INT_DB_CR_FLG =
                                                  P.PRODIRSH_INT_DB_CR_FLG)
                   ORDER BY PRODIRSH_DTL_SL)
            LOOP
               IF W_AC_BAL <= REC.PRODIRSH_UPTO_AMOUNT
               THEN
                  W_IN_RATE := REC.PRODIRSH_INT_RATE;
                  EXIT;
               END IF;
            END LOOP;
         END IF;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         CHECK_PRODUCTLEVEL2_INTRATE;
      WHEN TOO_MANY_ROWS
      THEN
         W_IN_RATE := 0;
   END;

BEGIN
   W_IN_RATE := 0;

   IF (P_INT_TYPE <> 'D' AND P_INT_TYPE <> 'C')
   THEN
      W_IN_RATE := 0;
      RETURN (W_IN_RATE);
   END IF;

   SELECT A.ACNTS_ENTITY_NUM
     INTO W_ENTITY_NUM
     FROM ACNTS A
    WHERE A.ACNTS_INTERNAL_ACNUM = P_AC_NUM;

   W_BRN_CAT := FN_GET_BRANCH_CAT (P_AC_NUM, W_ENTITY_NUM);

  <<ACNTIR>>
   BEGIN
      SELECT A.ACNTIRH_INT_RATE,A.ACNTIRH_AC_LEVEL_INT_RATE
        INTO W_IN_RATE , W_AC_LEVEL_INT_RATE
        FROM ACNTIRHIST A
       WHERE     A.ACNTIRH_INT_DB_CR_FLG = P_INT_TYPE
             AND A.ACNTIRH_INTERNAL_ACNUM = P_AC_NUM
             AND A.ACNTIRH_EFF_DATE =
                    (SELECT MAX (ACNTIRH_EFF_DATE)
                       FROM ACNTIRHIST
                      WHERE     ACNTIRH_EFF_DATE <= P_ASON_DATE
                            AND ACNTIRH_INT_DB_CR_FLG =
                                   A.ACNTIRH_INT_DB_CR_FLG
                            AND ACNTIRH_INTERNAL_ACNUM =
                                   A.ACNTIRH_INTERNAL_ACNUM);

    IF W_AC_LEVEL_INT_RATE = '0' THEN
     CHECK_PRODUCTLEVEL1_INTRATE;
    END IF;

   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         CHECK_PRODUCTLEVEL1_INTRATE;
   END ACNTIR;

   RETURN W_IN_RATE;
END FN_GET_INTRATE_RUN_ACS_NEW;
/
