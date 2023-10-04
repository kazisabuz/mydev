/*<TOAD_FILE_CHUNK>*/
CREATE OR REPLACE PACKAGE PKG_FD_RD_MANUAL_MARK
IS
   -- Author  : kazi sabuj
   -- Created : 25-09-2023
   -- Purpose : manually close mark all scheme account whose all contracts are closed
 

   PROCEDURE START_BRNWISE (V_ENTITY_CODE   IN NUMBER,
                            P_BRN_CODE      IN NUMBER DEFAULT 0);
END PKG_FD_RD_MANUAL_MARK;
/

/*<TOAD_FILE_CHUNK>*/
/* Formatted on 9/26/2023 11:59:22 AM (QP5 v5.388) */
CREATE OR REPLACE PACKAGE BODY PKG_FD_RD_MANUAL_MARK
IS
    -- Author  : kazi sabuj
    -- Created : 25-09-2023
    -- Purpose : manually close mark all scheme account whose all contracts are closed
    V_ENTITY_NUM   NUMBER (5);
    V_USER_ID      VARCHAR2 (8);
    V_CBD          DATE;
    V_ERROR        VARCHAR2 (1000);


    PROCEDURE SP_FD_RD_MANUAL_MARK (P_ENTITY_NUM   NUMBER,
                                    P_BRN_CODE     NUMBER,
                                    P_ASON_DATE    DATE)
    IS
        V_ERR_MSG              VARCHAR2 (1000);
        W_TEST_ACNUM_PREV      VARCHAR2 (60);
        W_TEST_ACNUM           VARCHAR2 (60);
        W_SQL                  VARCHAR2 (4300);

        TYPE R_ACNT_STATUS IS RECORD
        (
            V_INTERNAL_ACNUM    NUMBER (14),
            V_CLOSE_DATE        DATE
        );

        TYPE IT_ACNT_STATUS IS TABLE OF R_ACNT_STATUS;

        ITT_ACNT_STATUS        IT_ACNT_STATUS;

        TYPE IT_ACNT_STATUS_CHECK IS TABLE OF R_ACNT_STATUS
            INDEX BY VARCHAR2 (14);

        T_ACNTS_STATUS_CHECK   IT_ACNT_STATUS_CHECK;
    BEGIN
        W_SQL := '  
SELECT ACNTS_INTERNAL_ACNUM, PBDCONT_CLOSURE_DATE
  FROM ACNTS,
       PBDCONTRACT,
       depprod,
       acntbal
 WHERE     ACNTS_CLOSURE_DATE IS NULL
       AND PBDCONT_ENTITY_NUM = :1
       AND ACNTS_ENTITY_NUM = :2
       AND DEPPR_TYPE_OF_DEP = ''1''
       AND DEPPR_PROD_CODE = ACNTS_PROD_CODE
       AND ACNTBAL_ENTITY_NUM = :3
       AND ACNTBAL_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
       AND ACNTS_PROD_CODE = PBDCONT_PROD_CODE
       AND ACNTBAL_BC_BAL = 0
       AND PBDCONT_CLOSURE_DATE IS NOT NULL
       AND PBDCONT_BRN_CODE = ACNTS_BRN_CODE
       AND PBDCONT_CLOSURE_DATE <= :cbd
       AND ACNTS_BRN_CODE = :4
       AND ACNTS_INTERNAL_ACNUM = PBDCONT_DEP_AC_NUM
       AND (ACNTS_INTERNAL_ACNUM, PBDCONT_CONT_NUM) IN
               (  SELECT PBDCONT_DEP_AC_NUM, MAX (PBDCONT_CONT_NUM)
                   FROM PBDCONTRACT
                  WHERE     PBDCONT_ENTITY_NUM = :5
                        AND PBDCONT_BRN_CODE = ACNTS_BRN_CODE
               GROUP BY PBDCONT_DEP_AC_NUM)';

        EXECUTE IMMEDIATE W_SQL
            BULK COLLECT INTO ITT_ACNT_STATUS
            USING P_ENTITY_NUM,
                  P_ENTITY_NUM,
                  P_ENTITY_NUM,
                  P_ASON_DATE,
                  P_BRN_CODE,
                  P_ENTITY_NUM;

        IF ITT_ACNT_STATUS.EXISTS (1) = TRUE
        THEN
            FORALL IDX IN 1 .. ITT_ACNT_STATUS.COUNT
                UPDATE ACNTS
                   SET ACNTS_CLOSURE_DATE =
                           ITT_ACNT_STATUS (IDX).V_CLOSE_DATE
                 WHERE     ACNTS_ENTITY_NUM = P_ENTITY_NUM
                       AND ACNTS_INTERNAL_ACNUM =
                           ITT_ACNT_STATUS (IDX).V_INTERNAL_ACNUM;


            ITT_ACNT_STATUS.DELETE;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            IF TRIM (V_ERR_MSG) IS NULL
            THEN
                V_ERR_MSG := 'ERROR IN SP_FD_RD_MANUAL_MARK ' || SQLERRM;
                DBMS_OUTPUT.PUT_LINE (SQLERRM);
            END IF;

            PKG_EODSOD_FLAGS.PV_ERROR_MSG := V_ERR_MSG;
            V_ERROR := V_ERR_MSG;
            PKG_PB_GLOBAL.DETAIL_ERRLOG (V_ENTITY_NUM,
                                         'E',
                                         PKG_EODSOD_FLAGS.PV_ERROR_MSG,
                                         '',
                                         0);
            PKG_PB_GLOBAL.DETAIL_ERRLOG (
                V_ENTITY_NUM,
                'E',
                   SUBSTR (SQLERRM, 1, 1000)
                || ' '
                || W_TEST_ACNUM_PREV
                || ' '
                || W_TEST_ACNUM,
                ' ',
                0);
    END SP_FD_RD_MANUAL_MARK;

    PROCEDURE CHECK_INPUT_VALUES
    IS
    BEGIN
        IF V_ENTITY_NUM = 0
        THEN
            V_ERROR := 'ENTITY NUMBER IS NOT SPECIFIED';
        END IF;

        IF V_USER_ID IS NULL
        THEN
            V_ERROR := 'USER ID IS NOT SPECIFIED';
        END IF;

        IF V_CBD IS NULL
        THEN
            V_ERROR := 'CURRENT BUSINESS DATE IS NOT SPECIFIED';
        END IF;
    END;


    PROCEDURE START_BRNWISE (V_ENTITY_CODE   IN NUMBER,
                             P_BRN_CODE      IN NUMBER DEFAULT 0)
    IS
        L_BRN_CODE   NUMBER (6);
    BEGIN
        V_ENTITY_NUM := V_ENTITY_CODE;
        V_USER_ID := PKG_EODSOD_FLAGS.PV_USER_ID;
        V_CBD := PKG_EODSOD_FLAGS.PV_CURRENT_DATE;

        CHECK_INPUT_VALUES;

        IF V_ERROR IS NULL
        THEN
            PKG_PROCESS_CHECK.INIT_PROC_BRN_WISE (V_ENTITY_NUM, P_BRN_CODE);

            FOR IDX IN 1 .. PKG_PROCESS_CHECK.V_ACNTBRN.COUNT
            LOOP
                L_BRN_CODE := PKG_PROCESS_CHECK.V_ACNTBRN (IDX).LN_BRN_CODE;

                IF PKG_PROCESS_CHECK.CHK_BRN_ALREADY_PROCESSED (V_ENTITY_NUM,
                                                                L_BRN_CODE) =
                   FALSE
                THEN
                    SP_FD_RD_MANUAL_MARK (V_ENTITY_NUM, L_BRN_CODE, V_CBD);

                    IF TRIM (PKG_EODSOD_FLAGS.PV_ERROR_MSG) IS NULL
                    THEN
                        PKG_PROCESS_CHECK.INSERT_ROW_INTO_EODSODPROCBRN (
                            V_ENTITY_NUM,
                            L_BRN_CODE);
                    END IF;

                    PKG_PROCESS_CHECK.CHECK_COMMIT_ROLLBACK_STATUS (
                        V_ENTITY_NUM);
                END IF;
            END LOOP;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            NULL;
        WHEN OTHERS
        THEN
            IF V_ERROR IS NOT NULL
            THEN
                V_ERROR :=
                    SUBSTR ('ERROR IN PKG_FD_RD_MANUAL_MARK ' || SQLERRM,
                            1,
                            500);
            END IF;

            PKG_EODSOD_FLAGS.PV_ERROR_MSG := V_ERROR;
            PKG_PB_GLOBAL.DETAIL_ERRLOG (V_ENTITY_NUM,
                                         'E',
                                         PKG_EODSOD_FLAGS.PV_ERROR_MSG,
                                         ' ',
                                         0);
            PKG_PB_GLOBAL.DETAIL_ERRLOG (V_ENTITY_NUM,
                                         'E',
                                         SUBSTR (SQLERRM, 1, 1000),
                                         ' ',
                                         0);
            PKG_PB_GLOBAL.DETAIL_ERRLOG (V_ENTITY_NUM,
                                         'X',
                                         V_ENTITY_NUM,
                                         ' ',
                                         0);
    END;
END PKG_FD_RD_MANUAL_MARK;
/

