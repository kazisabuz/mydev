/*<TOAD_FILE_CHUNK>*/
/* Formatted on 8/22/2023 5:11:10 PM (QP5 v5.388) */
CREATE OR REPLACE PACKAGE PKG_RTAX
/*
Author: kaz.sabuj
Purpose: excise duty details
*/
IS
    TYPE REC_TYPE IS RECORD
    (
        MBRN_CODE              NUMBER,
        MBRN_NAME              VARCHAR2 (500),
        ACNAME                 VARCHAR2 (500),
        ACNUM                  VARCHAR2 (20),
        CONT_NUM               NUMBER,
        REC_DATE               DATE,
        ED_AMT                 NUMBER (18, 2),
        REMARKS                VARCHAR2 (500),
        OPEN_DATE              DATE,
        CLOSE_DATE             DATE,
        ACNTSEXCISE_MAX_BAL    NUMBER (18, 2),
        WAIVER_TYPE            VARCHAR2 (20),
        WAIVER_PERCENT         NUMBER (18, 2),
        EFF_DATE               DATE,
        SYS_CHARGE_AMOUNT      NUMBER (18, 2)
    );                                                                  -- 141

    V_BANK_CODE   INSTALL.INS_OUR_BANK_CODE%TYPE;


    TYPE REC_TAB IS TABLE OF REC_TYPE;

    FUNCTION GET_BRANCH_WISE (P_ENTITY_NUM     NUMBER,
                              P_BRN_CODE       NUMBER,
                              P_INTERNAL_ACC   NUMBER,
                              P_FROM_DATE      DATE,
                              P_TO_DATE        DATE)
        RETURN REC_TAB
        PIPELINED;
---RETURN VARCHAR2;

END PKG_RTAX;



CREATE OR REPLACE PACKAGE BODY PKG_RTAX
IS
    TEMP_DATA               PKG_RTAX.REC_TYPE;



    TYPE TEMP_RECORD IS RECORD
    (
        MBRN_CODE         NUMBER,
        MBRN_NAME         VARCHAR2 (500),
        ACNUM             VARCHAR2 (20),
        ACNAME            VARCHAR2 (500),
        CONT_NUM          NUMBER,
        REC_DATE          DATE,
        ED_AMT            NUMBER (18, 2),
        OPEN_DATE         DATE,
        CLOSE_DATE        DATE,
        MAX_AMT           NUMBER (18, 2),
        INTERNAL_ACNUM    NUMBER (14),
        FIN_YEAR          NUMBER,
        client_id         NUMBER (10),
        REMARKS           VARCHAR2 (500),
        V_CURR_CODE       VARCHAR2 (10)
    );


    TYPE TABLEA IS TABLE OF TEMP_RECORD
        INDEX BY PLS_INTEGER;

    T_TEMP_REC              TABLEA;
    V_WAIVER_TYPE           VARCHAR2 (20) := '';
    V_WAIVER_PERCENT        NUMBER (18, 2) := '';
    V_EFF_DATE              DATE := '';
    W_CHARGE_CURR_CODE      VARCHAR2 (10) := '';
    W_CHARGE_AMOUNT         NUMBER (18, 2) := '';
    W_SERVICE_AMOUNT        NUMBER (18, 2) := '';
    W_SERVICE_STAX_AMOUNT   NUMBER (18, 2) := '';
    W_SERVICE_ADDN_AMOUNT   NUMBER (18, 2) := '';
    W_SERVICE_CESS_AMOUNT   NUMBER (18, 2) := '';
    W_ERR_MSG               VARCHAR2 (500) := '';

    TYPE TY_ED IS RECORD
    (
        V_ED_AMT     NUMBER (18, 2),
        V_MAX_AMT    NUMBER (18, 2),
        REC_DATE     DATE
    );

    TYPE TTY_ED IS TABLE OF TY_ED
        INDEX BY PLS_INTEGER;

    TTTY_ED                 TTY_ED;

    FUNCTION GET_BRANCH_WISE (P_ENTITY_NUM     NUMBER,
                              P_BRN_CODE       NUMBER,
                              P_INTERNAL_ACC   NUMBER,
                              P_FROM_DATE      DATE,
                              P_TO_DATE        DATE)
        RETURN REC_TAB
        PIPELINED
    -- RETURN VARCHAR2
    IS
        W_SQL_QUERY   CLOB := '';
    BEGIN
        V_WAIVER_TYPE := '';
        V_WAIVER_PERCENT := '';
        V_EFF_DATE := '';
        W_SQL_QUERY :=
            '
WITH
    ED
    AS
        (SELECT M.MBRN_CODE,
                M.MBRN_NAME,
                (A.ACNTS_AC_NAME1 || A.ACNTS_AC_NAME2)
                    ACNAME,
                   FACNO ( ACNTS_ENTITY_NUM, A.ACNTS_INTERNAL_ACNUM)
                || ''/''
                || AE.ACNTSEXCISE_CONT_NUM
                    ACNUM,
                ACNTSEXCISE_INTERNAL_ACNUM ACNTEXCAMT_INTERNAL_ACNUM,
                AE.ACNTSEXCISE_CONT_NUM
                    CONT_NUM,
                TO_CHAR (AE.ACNTSEXCISE_CLOSURE_DATE, ''DD-MON-YYYY'')
                    REC_DATE,
                AE.ACNTSEXCISE_EXCISE_AMT
                    ED_AMT,
                TO_CHAR (A.ACNTS_OPENING_DATE, ''DD-MON-YYYY'')
                    OPEN_DATE,
                TO_CHAR (A.ACNTS_CLOSURE_DATE, ''DD-MON-YYYY'')
                    CLOSE_DATE,
                ACNTSEXCISE_EXCISE_ON_AMT
                    ACNTSEXCISE_MAX_BAL,
                ACNTSEXCISE_CLOSURE_DATE,
                ACNTSEXCISE_FIN_YEAR FIN_YEAR,ACNTS_CLIENT_NUM,null narration,ACNTS_CURR_CODE
           FROM ACNTSEXCISEBONUS AE, ACNTS A, MBRN M
          WHERE     A.ACNTS_INTERNAL_ACNUM = AE.ACNTSEXCISE_INTERNAL_ACNUM
                AND ACNTS_ENTITY_NUM = :1
                AND A.ACNTS_BRN_CODE = :2
                AND AE.ACNTSEXCISE_INTERNAL_ACNUM = :3
                AND M.MBRN_CODE = A.ACNTS_BRN_CODE
                AND A.ACNTS_BRN_CODE = ACNTSEXCISE_BRN_CODE
                AND AE.POST_TRAN_DATE BETWEEN :4 AND :5
         UNION ALL
         SELECT M.MBRN_CODE,
                M.MBRN_NAME,
                (A.ACNTS_AC_NAME1 || A.ACNTS_AC_NAME2)
                    ACNAME,
                FACNO ( ACNTS_ENTITY_NUM, A.ACNTS_INTERNAL_ACNUM)
                    ACNUM,
                ACNTEXCAMT_INTERNAL_ACNUM,
                AC.ACNTSEXCISE_CONT_NUM
                    CONT_NUM,
                TO_CHAR (AC.ACNTEXCAMT_PROCESS_DATE, ''DD-MON-YYYY'')
                    REC_DATE,
                AC.ACNTEXCAMT_EXCISE_AMT
                    ED_AMT,
                TO_CHAR (A.ACNTS_OPENING_DATE, ''DD-MON-YYYY'')
                    OPEN_DATE,
                TO_CHAR (A.ACNTS_CLOSURE_DATE, ''DD-MON-YYYY'')
                    CLOSE_DATE,
                ACNTSEXCISE_MAX_BAL,
                ACNTEXCAMT_PROCESS_DATE,
                ACNTEXCAMT_FIN_YEAR FIN_YEAR,ACNTS_CLIENT_NUM,null narration,ACNTS_CURR_CODE
           FROM ACNTEXCISEAMT AC, ACNTS A, MBRN M
          WHERE     A.ACNTS_INTERNAL_ACNUM = AC.ACNTEXCAMT_INTERNAL_ACNUM
                AND ACNTEXCAMT_ENTITY_NUM = :1
                AND AC.ACNTEXCAMT_BRN_CODE = :2
                AND A.ACNTS_INTERNAL_ACNUM = :3
                AND M.MBRN_CODE = A.ACNTS_BRN_CODE
                AND A.ACNTS_BRN_CODE = ACNTEXCAMT_BRN_CODE
                AND AC.ACNTEXCAMT_PROCESS_DATE BETWEEN :4
                                                   AND :5
                                                   UNION ALL
         SELECT M.MBRN_CODE,
                M.MBRN_NAME,
                (A.ACNTS_AC_NAME1 || A.ACNTS_AC_NAME2)
                    ACNAME,
                FACNO (ACNTS_ENTITY_NUM, A.ACNTS_INTERNAL_ACNUM)
                    ACNUM,
                ACNTS_INTERNAL_ACNUM,
                AC.HOVERING_CONTRACT_NUM
                    CONT_NUM,
                TO_CHAR (AC.HOVERING_DATE_OF_ENTRY, ''DD-MON-YYYY'')
                    REC_DATE,
                HOVERING_TOT_RECOVERY_AMT
                    ED_AMT,
                TO_CHAR (A.ACNTS_OPENING_DATE, ''DD-MON-YYYY'')
                    OPEN_DATE,
                TO_CHAR (A.ACNTS_CLOSURE_DATE, ''DD-MON-YYYY'')
                    CLOSE_DATE,
                0
                    ACNTSEXCISE_MAX_BAL,
                HOVERING_DATE_OF_ENTRY,
                HOVERING_YEAR
                    FIN_YEAR,
                ACNTS_CLIENT_NUM,HOVERING_RECOVERY_NARR1||HOVERING_RECOVERY_NARR2||HOVERING_RECOVERY_NARR3 narration,ACNTS_CURR_CODE
           FROM HOVERING AC, ACNTS A, MBRN M
          WHERE     A.ACNTS_INTERNAL_ACNUM = AC.HOVERING_RECOVERY_FROM_ACNT
                AND ACNTS_ENTITY_NUM = :1
                AND AC.HOVERING_BRN_CODE = :2
                AND A.ACNTS_INTERNAL_ACNUM = :3
                AND M.MBRN_CODE = A.ACNTS_BRN_CODE
                and HOVERING_CHG_CODE=''ED''
                AND A.ACNTS_BRN_CODE = HOVERING_BRN_CODE
                AND HOVERING_TOT_RECOVERY_AMT <> 0
                AND AC.HOVERING_DATE_OF_ENTRY BETWEEN :4 AND :5)
SELECT MBRN_CODE,
       MBRN_NAME,
       ACNUM,
       ACNAME,
       CONT_NUM,
       REC_DATE,
       ED_AMT,
       OPEN_DATE,
       CLOSE_DATE,
       ACNTSEXCISE_MAX_BAL,
       ACNTEXCAMT_INTERNAL_ACNUM,
       FIN_YEAR,ACNTS_CLIENT_NUM,
       narration,ACNTS_CURR_CODE
  FROM ED ORDER BY REC_DATE ';

        EXECUTE IMMEDIATE W_SQL_QUERY
            BULK COLLECT INTO T_TEMP_REC
            USING P_ENTITY_NUM,
                  P_BRN_CODE,
                  P_INTERNAL_ACC,
                  P_FROM_DATE,
                  P_TO_DATE,
                  P_ENTITY_NUM,
                  P_BRN_CODE,
                  P_INTERNAL_ACC,
                  P_FROM_DATE,
                  P_TO_DATE,
                  P_ENTITY_NUM,
                  P_BRN_CODE,
                  P_INTERNAL_ACC,
                  P_FROM_DATE,
                  P_TO_DATE;


        IF T_TEMP_REC.FIRST IS NOT NULL
        THEN
            FOR REC IN T_TEMP_REC.FIRST .. T_TEMP_REC.LAST
            LOOP
                BEGIN
                    SELECT DISTINCT
                           CASE
                               WHEN CLCHGWAIVDTHIST_WAIVER_TYPE = 'F'
                               THEN
                                   'Full'
                               ELSE
                                   'Partial'
                           END,
                           CASE
                               WHEN CLCHGWAIVDTHIST_WAIVER_TYPE = 'F'
                               THEN
                                   100
                               ELSE
                                   CLCHGWAIVDTHIST_DISCOUNT_PER
                           END,
                           CLCHGWAIVDTHIST_EFF_DATE
                      INTO V_waiver_type, V_WAIVER_PERCENT, V_EFF_DATE
                      FROM CLCHGWAIVEDTLHIST, CLCHGWAIVERHIST
                     WHERE     CLCHGWAIVDTHIST_ENTITY_NUM = P_ENTITY_NUM
                           AND CLCHGWAIVHIST_INT_ACNUM =
                               CLCHGWAIVDTHIST_INT_ACNUM
                           AND CLCHGWAIVHIST_CLIENT_NUM =
                               CLCHGWAIVDTHIST_CLIENT_NUM
                           AND (   CLCHGWAIVHIST_INT_ACNUM =
                                   T_TEMP_REC (REC).INTERNAL_ACNUM
                                OR CLCHGWAIVDTHIST_CLIENT_NUM =
                                   T_TEMP_REC (REC).client_id)
                           AND CLCHGWAIVDTHIST_CHARGE_CODE = 'ED'
                           AND CLCHGWAIVHIST_WAIVE_REQD = '1'
                           AND TO_CHAR (CLCHGWAIVHIST_EFF_DATE, 'YYYY') =
                               T_TEMP_REC (REC).FIN_YEAR;
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        V_waiver_type := '';
                        V_WAIVER_PERCENT := '';
                        V_EFF_DATE := '';
                END;

                PKG_CHARGES_WOTHOUT_WAIVE.SP_GET_CHARGES (
                    1,
                    T_TEMP_REC (REC).INTERNAL_ACNUM,
                    T_TEMP_REC (REC).V_CURR_CODE,
                    T_TEMP_REC (REC).MAX_AMT,
                    'ED',
                    'V',
                    W_CHARGE_CURR_CODE,
                    W_CHARGE_AMOUNT,
                    W_SERVICE_AMOUNT,
                    W_SERVICE_STAX_AMOUNT,
                    W_SERVICE_ADDN_AMOUNT,
                    W_SERVICE_CESS_AMOUNT,
                    W_ERR_MSG);

                TEMP_DATA.REC_DATE := T_TEMP_REC (REC).REC_DATE;
                TEMP_DATA.ED_AMT := T_TEMP_REC (REC).ED_AMT;
                TEMP_DATA.ACNTSEXCISE_MAX_BAL := T_TEMP_REC (REC).MAX_AMT;
                TEMP_DATA.MBRN_CODE := T_TEMP_REC (REC).MBRN_CODE;
                TEMP_DATA.MBRN_NAME := T_TEMP_REC (REC).MBRN_NAME;
                TEMP_DATA.ACNAME := T_TEMP_REC (REC).ACNAME;
                TEMP_DATA.ACNUM := T_TEMP_REC (REC).ACNUM;
                TEMP_DATA.OPEN_DATE := T_TEMP_REC (REC).OPEN_DATE;
                TEMP_DATA.CLOSE_DATE := T_TEMP_REC (REC).CLOSE_DATE;
                TEMP_DATA.REMARKS := T_TEMP_REC (REC).REMARKS;
                TEMP_DATA.SYS_CHARGE_AMOUNT := W_CHARGE_AMOUNT;

                IF (T_TEMP_REC (REC).ED_AMT = 0 AND V_waiver_type IS NOT NULL)
                THEN
                    TEMP_DATA.WAIVER_TYPE := V_WAIVER_TYPE;
                    TEMP_DATA.WAIVER_PERCENT := V_WAIVER_PERCENT;
                    TEMP_DATA.EFF_DATE := V_EFF_DATE;
                END IF;



                PIPE ROW (TEMP_DATA);
            END LOOP;

            TEMP_DATA.WAIVER_TYPE := '';
            TEMP_DATA.WAIVER_PERCENT := '';
            TEMP_DATA.EFF_DATE := '';
            TEMP_DATA.SYS_CHARGE_AMOUNT := '';
        END IF;

        T_TEMP_REC.delete;
        --- TEMP_DATA.DELETE;
        -- REC_TAB.delete;
        V_WAIVER_TYPE := '';
        V_WAIVER_PERCENT := '';
        V_EFF_DATE := '';
        W_CHARGE_CURR_CODE := '';
        W_CHARGE_AMOUNT := '';
        W_SERVICE_AMOUNT := '';
        W_SERVICE_STAX_AMOUNT := '';
        W_SERVICE_ADDN_AMOUNT := '';
        W_SERVICE_CESS_AMOUNT := '';
        W_ERR_MSG := '';
    EXCEPTION
        WHEN OTHERS
        THEN
            NULL;
    --- DBMS_OUTPUT.PUT_LINE (SQLERRM || SQLCODE);
    END;
END;