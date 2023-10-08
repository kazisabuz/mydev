CREATE OR REPLACE FUNCTION FN_GET_PRIME_CUST (
    P_CLIENT_CODE          NUMBER DEFAULT 0,
    P_INTERNAL_AC_NUMBER   NUMBER)
    RETURN NUMBER
IS
    W_INTERNAL_ACNUM      ACNTS.ACNTS_INTERNAL_ACNUM%TYPE;
    W_COUNT               NUMBER (2) := 0;
    W_RETURN              NUMBER (1) := 0;
    W_ERROR               VARCHAR2 (500);
    W_ERR_CODE            NUMBER (4);
    W_ERR_MSG             VARCHAR2 (500);
    W_AVAIL_BALANCE       ACNTBAL.ACNTBAL_BC_BAL%TYPE := 0;
    W_PRIMECUST_TYPE      PRIMECUST.PRIMECUST_TYPE%TYPE;
    W_PRIMECUST_MIN_AMT   PRIMECUST.PRIMECUST_MIN_AMT%TYPE;
    W_CURR_CODE           ACNTS.ACNTS_CURR_CODE%TYPE;
    W_ENTITY_NUMBER       NUMBER (3);
    W_PRODUCT_CODE        NUMBER (4);
    W_CLIENTS_TYPE_FLG    CHAR (1);
BEGIN
    W_ENTITY_NUMBER := FN_GET_ENTITY;

    BEGIN
        SELECT PRIMECUST_TYPE, PRIMECUST_MIN_AMT
          INTO W_PRIMECUST_TYPE, W_PRIMECUST_MIN_AMT
          FROM PRIMECUST
         WHERE PRIMECUST_TYPE = 'C';
    EXCEPTION
        WHEN OTHERS
        THEN
            W_ERR_CODE := SQLCODE;
            W_ERR_MSG := SUBSTR (SQLERRM, 1, 400);
            W_ERROR :=
                   'ERROR CODE: '
                || W_ERR_CODE
                || ' ERROR MESSAGE: '
                || W_ERR_MSG;
    END;


    IF P_CLIENT_CODE <> 0
    THEN
        BEGIN
            BEGIN
                SELECT CLIENTS_TYPE_FLG
                  INTO W_CLIENTS_TYPE_FLG
                  FROM CLIENTS
                 WHERE CLIENTS_CODE = P_CLIENT_CODE;
            END;

            IF W_CLIENTS_TYPE_FLG = 'I'
            THEN
                SELECT COUNT (*)
                  INTO W_COUNT
                  FROM INDCLIENTS
                 WHERE     INDCLIENT_CODE = P_CLIENT_CODE
                       AND TRIM (INDCLIENT_PRIME_CUSTOMER) IS NOT NULL;
            ELSIF W_CLIENTS_TYPE_FLG = 'J'
            THEN
                FOR IND IN (SELECT JNTCLDTL_INDIV_CLIENT_CODE
                              FROM JOINTCLIENTSDTL
                             WHERE JNTCLDTL_CLIENT_CODE = P_CLIENT_CODE)
                LOOP
                    SELECT COUNT (*)
                      INTO W_COUNT
                      FROM INDCLIENTS
                     WHERE     INDCLIENT_CODE =
                               IND.JNTCLDTL_INDIV_CLIENT_CODE
                           AND TRIM (INDCLIENT_PRIME_CUSTOMER) IS NOT NULL;

                    EXIT WHEN W_COUNT > 0;
                END LOOP;
            END IF;

            IF W_COUNT > 0
            THEN
                W_RETURN := 1;
            END IF;
        EXCEPTION
            WHEN OTHERS
            THEN
                W_ERR_CODE := SQLCODE;
                W_ERR_MSG := SUBSTR (SQLERRM, 1, 400);
                W_ERROR :=
                       'ERROR CODE: '
                    || W_ERR_CODE
                    || ' ERROR MESSAGE: '
                    || W_ERR_MSG;
        END;

      -- DBMS_OUTPUT.PUT_LINE (W_PRIMECUST_MIN_AMT);

        IF W_RETURN = 0
        THEN
            BEGIN
                FOR IDX
                    IN (SELECT ACNTS_INTERNAL_ACNUM,
                               ACNTS_CURR_CODE,
                               ACNTS_PROD_CODE
                         FROM ACNTS, PRODUCTS
                        WHERE     ACNTS_ENTITY_NUM = W_ENTITY_NUMBER
                              AND ACNTS_CLIENT_NUM = P_CLIENT_CODE
                              AND PRODUCT_CODE = ACNTS_PROD_CODE
                              AND PRODUCT_FOR_DEPOSITS = 1
                              AND ACNTS_CLOSURE_DATE IS NULL)
                LOOP
                    W_PRODUCT_CODE := IDX.ACNTS_PROD_CODE;
                    W_INTERNAL_ACNUM := IDX.ACNTS_INTERNAL_ACNUM;
                    W_CURR_CODE := IDX.ACNTS_CURR_CODE;

                    --DBMS_OUTPUT.PUT_LINE (W_PRODUCT_CODE);
                   --DBMS_OUTPUT.PUT_LINE (W_INTERNAL_ACNUM);

                    BEGIN
                        IF W_PRIMECUST_TYPE IS NULL
                        THEN
                            SELECT PRIMECUST_TYPE, PRIMECUST_MIN_AMT
                              INTO W_PRIMECUST_TYPE, W_PRIMECUST_MIN_AMT
                              FROM PRIMECUST
                             WHERE PRIMECUST_PROD_CODE = W_PRODUCT_CODE;
                        END IF;
                    END;


                    W_AVAIL_BALANCE :=
                          W_AVAIL_BALANCE
                        + FN_GET_ASON_ACBAL (
                              W_ENTITY_NUMBER,
                              W_INTERNAL_ACNUM,
                              W_CURR_CODE,
                              FN_GET_CURRBUSS_DATE (1, W_CURR_CODE),
                              FN_GET_CURRBUSS_DATE (1, W_CURR_CODE));


                    --DBMS_OUTPUT.PUT_LINE (W_AVAIL_BALANCE);
                END LOOP;

                IF W_AVAIL_BALANCE >= W_PRIMECUST_MIN_AMT
                THEN
                    W_RETURN := 1;
                END IF;
            EXCEPTION
                WHEN OTHERS
                THEN
                    W_ERR_CODE := SQLCODE;
                    W_ERR_MSG := SUBSTR (SQLERRM, 1, 400);
                    W_ERROR :=
                           'ERROR CODE: '
                        || W_ERR_CODE
                        || ' ERROR MESSAGE: '
                        || W_ERR_MSG;
            END;
        END IF;
    END IF;

    IF W_RETURN = 0 AND P_INTERNAL_AC_NUMBER <> 0
    THEN
        BEGIN
            SELECT ACNTS_INTERNAL_ACNUM, ACNTS_CURR_CODE, ACNTS_PROD_CODE
              INTO W_INTERNAL_ACNUM, W_CURR_CODE, W_PRODUCT_CODE
              FROM ACNTS
             WHERE     ACNTS_ENTITY_NUM = W_ENTITY_NUMBER
                   AND ACNTS_INTERNAL_ACNUM = P_INTERNAL_AC_NUMBER;


            BEGIN
                IF W_PRIMECUST_TYPE IS NULL
                THEN
                    SELECT PRIMECUST_TYPE, PRIMECUST_MIN_AMT
                      INTO W_PRIMECUST_TYPE, W_PRIMECUST_MIN_AMT
                      FROM PRIMECUST
                     WHERE PRIMECUST_PROD_CODE = W_PRODUCT_CODE;
                END IF;
            END;


            W_AVAIL_BALANCE :=
                FN_GET_ASON_ACBAL (W_ENTITY_NUMBER,
                                   W_INTERNAL_ACNUM,
                                   W_CURR_CODE,
                                   FN_GET_CURRBUSS_DATE (1, W_CURR_CODE),
                                   FN_GET_CURRBUSS_DATE (1, W_CURR_CODE));


            IF W_AVAIL_BALANCE >= W_PRIMECUST_MIN_AMT
            THEN
                W_RETURN := 1;
            END IF;
        EXCEPTION
            WHEN OTHERS
            THEN
                W_ERR_CODE := SQLCODE;
                W_ERR_MSG := SUBSTR (SQLERRM, 1, 400);
                W_ERROR :=
                       'ERROR CODE: '
                    || W_ERR_CODE
                    || ' ERROR MESSAGE: '
                    || W_ERR_MSG;
        END;
    END IF;

    RETURN W_RETURN;
END;
/
