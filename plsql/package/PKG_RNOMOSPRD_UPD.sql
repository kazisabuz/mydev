
CREATE OR REPLACE PACKAGE PKG_RNOMOSPRD_UPD IS

TYPE REC_TYPE IS RECORD(
    NOMENT_GLACC_CODE                EXTGL.EXTGL_ACCESS_CODE%TYPE,
    EXTGL_EXT_HEAD_DESCN             VARCHAR2(25),
    NOMENT_REF_NUM                   VARCHAR2(35),
    NOMENT_GROUP_CODE                VARCHAR2(6),
    NOMENT_ENTRY_DATE                VARCHAR2(15),
    NOMENT_CURR_CODE                 VARCHAR2(3),
    NOMENT_ORG_ENT_AMT               VARCHAR2(30),
    NOMENT_ORG_ENT_DB_CR             VARCHAR2(6),
    NOMENT_OS_BALANCE                VARCHAR2(30)
);

TYPE REC_TYPE_DEPT IS RECORD(
    NOMENT_GLACC_CODE                EXTGL.EXTGL_ACCESS_CODE%TYPE,
    EXTGL_EXT_HEAD_DESCN             VARCHAR2(25),
    NOMENT_REF_NUM                   VARCHAR2(35),
    NOMENT_GROUP_CODE                VARCHAR2(6),
    NOMENT_ENTRY_DATE                VARCHAR2(15),
    NOMENT_CURR_CODE                 VARCHAR2(3),
    NOMENT_ORG_ENT_AMT               VARCHAR2(100),
    NOMENT_ORG_ENT_DB_CR             VARCHAR2(6),
    NOMENT_OS_BALANCE                VARCHAR2(30),
    NOMENT_DEPT_CDOE                 VARCHAR2(6),
    NOMENT_DEPT_NAME                 VARCHAR2(250)
);

TYPE REC_TAB IS TABLE OF REC_TYPE;
TYPE REC_TAB_DEPT IS TABLE OF REC_TYPE_DEPT;

FUNCTION SP_RNOMOSPRD_UPD(P_ENTITY_NUM  NUMBER,
                            P_BRN_CODE    NUMBER,
                            P_GLACC_CODE  VARCHAR2,
                            P_NOMGRP_CODE VARCHAR2,
                            P_CUTOFF_DAYS VARCHAR2,
                            P_START_DATE  VARCHAR2) RETURN REC_TAB --RETURN VARCHAR2;
PIPELINED;

FUNCTION SP_RNOMOSPRD_UPD_DEPT(P_ENTITY_NUM  NUMBER,
                            P_BRN_CODE    NUMBER,
                            P_GLACC_CODE  VARCHAR2,
                            P_NOMGRP_CODE VARCHAR2,
                            P_CUTOFF_DAYS VARCHAR2,
                            P_START_DATE  VARCHAR2) RETURN REC_TAB_DEPT  --RETURN VARCHAR2;
PIPELINED;

END PKG_RNOMOSPRD_UPD;
/

 
CREATE OR REPLACE PACKAGE BODY PKG_RNOMOSPRD_UPD
IS
    RPT_DATA        PKG_RNOMOSPRD_UPD.REC_TYPE;
    RPT_DATA_DEPT   PKG_RNOMOSPRD_UPD.REC_TYPE_DEPT;
    V_SQL           CLOB;
    w_SQL           CLOB;
    err_mgs         VARCHAR2 (500);

    TYPE TEMP_RECORD IS RECORD
    (
        NOMENT_GLACC_CODE       EXTGL.EXTGL_ACCESS_CODE%TYPE,
        EXTGL_EXT_HEAD_DESCN    VARCHAR2 (25),
        NOMENT_REF_NUM          VARCHAR2 (35),
        NOMENT_GROUP_CODE       VARCHAR2 (6),
        NOMENT_ENTRY_DATE       VARCHAR2 (15),
        NOMENT_CURR_CODE        VARCHAR2 (3),
        NOMENT_ORG_ENT_AMT      VARCHAR2 (30),
        NOMENT_ORG_ENT_DB_CR    VARCHAR2 (6),
        NOMENT_OS_BALANCE       VARCHAR2 (30),
        POST_TRAN_BRN           NOMENTRY.POST_TRAN_BRN%TYPE,
        POST_TRAN_DATE          NOMENTRY.POST_TRAN_DATE%TYPE,
        POST_TRAN_BATCH_NUM     NOMENTRY.POST_TRAN_BATCH_NUM%TYPE,
        POST_TRAN_BATCH_SL      NOMENTRY.POST_TRAN_BATCH_SL%TYPE,
        NOMENT_YEAR             NOMENTRY.NOMENT_YEAR%TYPE
    );

    TYPE TABLEA IS TABLE OF TEMP_RECORD
        INDEX BY PLS_INTEGER;

    T_TEMP_REC      TABLEA;

    PROCEDURE CONSTRUCT_QUERY (P_ENTITY_NUM    NUMBER,
                               P_BRN_CODE      NUMBER,
                               P_GLACC_CODE    VARCHAR2,
                               P_NOMGRP_CODE   VARCHAR2,
                               P_CUTOFF_DAYS   VARCHAR2,
                               P_START_DATE    VARCHAR2)
    IS
    BEGIN
        V_SQL :=
               'SELECT NOMENT_GLACC_CODE,SUBSTR(EXTGL_EXT_HEAD_DESCN, 0, 25) EXTGL_EXT_HEAD_DESCN,
              (NOMENT_YEAR || ''/'' || NOMENT_ENTRY_NUM) NOMENT_REF_NUM,NOMENT_GROUP_CODE,
              TO_CHAR(NOMENT_ENTRY_DATE,''dd-Mon-YYYY'') NOMENT_ENTRY_DATE,NOMENT_CURR_CODE,
              SP_GETFORMAT(1,NOMENT_CURR_CODE,NOMENT_ORG_ENT_AMT)NOMENT_ORG_ENT_AMT,
              DECODE(NOMENT_ORG_ENT_DB_CR, ''C'', ''Credit'', ''D'', ''Debit'') NOMENT_ORG_ENT_DB_CR,
              SP_GETFORMAT(1,NOMENT_CURR_CODE,NOMENT_OS_BALANCE)NOMENT_OS_BALANCE,
              POST_TRAN_BRN,POST_TRAN_DATE,POST_TRAN_BATCH_NUM,POST_TRAN_BATCH_SL,NOMENT_YEAR
              FROM NOMENTRY, EXTGL WHERE NOMENT_ENTITY_NUM = '
            || P_ENTITY_NUM
            || ' AND NOMENT_GLACC_CODE = EXTGL_ACCESS_CODE AND NOMENT_BRN_CODE = '
            || P_BRN_CODE
            || ' AND NOMENT_OS_BALANCE <> 0 AND NOMENT_AUTH_ON IS NOT NULL';

        IF P_GLACC_CODE IS NOT NULL
        THEN
            V_SQL := V_SQL || ' AND NOMENT_GLACC_CODE = ' || P_GLACC_CODE;
        END IF;

        IF P_NOMGRP_CODE IS NOT NULL
        THEN
            V_SQL := V_SQL || ' AND NOMENT_GROUP_CODE = ' || P_NOMGRP_CODE;
        END IF;

        IF TO_NUMBER (P_CUTOFF_DAYS) > 0
        THEN
            V_SQL :=
                   V_SQL
                || ' AND NOMENT_ENTRY_DATE< = '
                || CHR (39)
                || P_START_DATE
                || CHR (39);
        END IF;

        V_SQL :=
               V_SQL
            || ' ORDER BY NOMENT_ENTRY_DATE,NOMENT_BRN_CODE,NOMENT_GLACC_CODE,NOMENT_YEAR,NOMENT_ENTRY_NUM';
    END CONSTRUCT_QUERY;

    FUNCTION SP_RNOMOSPRD_UPD (P_ENTITY_NUM    NUMBER,
                               P_BRN_CODE      NUMBER,
                               P_GLACC_CODE    VARCHAR2,
                               P_NOMGRP_CODE   VARCHAR2,
                               P_CUTOFF_DAYS   VARCHAR2,
                               P_START_DATE    VARCHAR2)
        RETURN REC_TAB                                       --RETURN VARCHAR2
        PIPELINED
    IS
    BEGIN
        CONSTRUCT_QUERY (P_ENTITY_NUM,
                         P_BRN_CODE,
                         P_GLACC_CODE,
                         P_NOMGRP_CODE,
                         P_CUTOFF_DAYS,
                         P_START_DATE);

        --DBMS_OUTPUT.put_line(V_SQL);

        EXECUTE IMMEDIATE V_SQL
            BULK COLLECT INTO T_TEMP_REC;

        IF T_TEMP_REC.COUNT > 0
        THEN
            FOR INDX IN T_TEMP_REC.FIRST .. T_TEMP_REC.LAST
            LOOP
                RPT_DATA.NOMENT_GLACC_CODE :=
                    T_TEMP_REC (INDX).NOMENT_GLACC_CODE;
                RPT_DATA.EXTGL_EXT_HEAD_DESCN :=
                    T_TEMP_REC (INDX).EXTGL_EXT_HEAD_DESCN;
                RPT_DATA.NOMENT_REF_NUM := T_TEMP_REC (INDX).NOMENT_REF_NUM;
                RPT_DATA.NOMENT_GROUP_CODE :=
                    T_TEMP_REC (INDX).NOMENT_GROUP_CODE;
                RPT_DATA.NOMENT_ENTRY_DATE :=
                    T_TEMP_REC (INDX).NOMENT_ENTRY_DATE;
                RPT_DATA.NOMENT_CURR_CODE :=
                    T_TEMP_REC (INDX).NOMENT_CURR_CODE;
                RPT_DATA.NOMENT_ORG_ENT_AMT :=
                    T_TEMP_REC (INDX).NOMENT_ORG_ENT_AMT;
                RPT_DATA.NOMENT_ORG_ENT_DB_CR :=
                    T_TEMP_REC (INDX).NOMENT_ORG_ENT_DB_CR;
                RPT_DATA.NOMENT_OS_BALANCE :=
                    T_TEMP_REC (INDX).NOMENT_OS_BALANCE;
                PIPE ROW (RPT_DATA);
            END LOOP;
        END IF;
    --RETURN NULL;
    END SP_RNOMOSPRD_UPD;

    FUNCTION SP_RNOMOSPRD_UPD_DEPT (P_ENTITY_NUM    NUMBER,
                                    P_BRN_CODE      NUMBER,
                                    P_GLACC_CODE    VARCHAR2,
                                    P_NOMGRP_CODE   VARCHAR2,
                                    P_CUTOFF_DAYS   VARCHAR2,
                                    P_START_DATE    VARCHAR2)
        RETURN REC_TAB_DEPT                                  --RETURN VARCHAR2
        PIPELINED
    IS
        W_DEPT_CODE   VARCHAR2 (20) := '';
        W_DEPT_NAME   VARCHAR2 (500) := '';
    BEGIN
        T_TEMP_REC.DELETE;
        CONSTRUCT_QUERY (P_ENTITY_NUM,
                         P_BRN_CODE,
                         P_GLACC_CODE,
                         P_NOMGRP_CODE,
                         P_CUTOFF_DAYS,
                         P_START_DATE);

        EXECUTE IMMEDIATE V_SQL
            BULK COLLECT INTO T_TEMP_REC;

        --DBMS_OUTPUT.PUT_LINE(V_SQL);
        IF T_TEMP_REC.COUNT > 0
        THEN
            FOR INDX IN T_TEMP_REC.FIRST .. T_TEMP_REC.LAST
            LOOP
                --
                --w_SQL := 'SELECT TRAN_DEPT_CODE,nvl((SELECT DEPTS_DEPT_NAME FROM DEPTS WHERE DEPTS_DEPT_CODE = TRAN_DEPT_CODE),'''')DEPTS_DEPT_NAME
                --                   FROM TRAN'||T_TEMP_REC(INDX).NOMENT_YEAR
                --                   || ' WHERE TRAN_BRN_CODE = ' ||  T_TEMP_REC(INDX).POST_TRAN_BRN
                --                   || ' AND TRAN_DATE_OF_TRAN = '|| CHR (39)|| T_TEMP_REC(INDX).POST_TRAN_DATE|| CHR (39)
                --                   || ' AND TRAN_BATCH_NUMBER = '|| T_TEMP_REC(INDX).POST_TRAN_BATCH_NUM
                --                   || ' AND TRAN_BATCH_SL_NUM = '||T_TEMP_REC(INDX).POST_TRAN_BATCH_SL;
                V_SQL :=
                       'SELECT TRAN_DEPT_CODE, DEPTS_DEPT_NAME
                   FROM  DEPTS,TRAN'
                    || T_TEMP_REC (INDX).NOMENT_YEAR
                    || ' WHERE DEPTS_DEPT_CODE =TRAN_DEPT_CODE
                    and  TRAN_BRN_CODE = :1'
                    || ' and TO_CHAR (TRAN_DATE_OF_TRAN, ''dd-Mon-YYYY'') = :2'
                    || ' AND TRAN_BATCH_NUMBER = :3'
                    || ' AND TRAN_BATCH_SL_NUM = :4'
                    || ' AND TRAN_ENTITY_NUM = :5';

                DBMS_OUTPUT.PUT_LINE (V_SQL);

                EXECUTE IMMEDIATE V_SQL
                    INTO W_DEPT_CODE, W_DEPT_NAME
                    USING T_TEMP_REC (INDX).POST_TRAN_BRN,
                          T_TEMP_REC (INDX).POST_TRAN_DATE,
                          T_TEMP_REC (INDX).POST_TRAN_BATCH_NUM,
                          T_TEMP_REC (INDX).POST_TRAN_BATCH_SL,
                          P_ENTITY_NUM;


                RPT_DATA_DEPT.NOMENT_DEPT_CDOE := W_DEPT_CODE;
                RPT_DATA_DEPT.NOMENT_DEPT_NAME := W_DEPT_NAME;
                RPT_DATA_DEPT.NOMENT_GLACC_CODE :=
                    T_TEMP_REC (INDX).NOMENT_GLACC_CODE;
                RPT_DATA_DEPT.EXTGL_EXT_HEAD_DESCN :=
                    T_TEMP_REC (INDX).EXTGL_EXT_HEAD_DESCN;
                RPT_DATA_DEPT.NOMENT_REF_NUM :=
                    T_TEMP_REC (INDX).NOMENT_REF_NUM;
                RPT_DATA_DEPT.NOMENT_GROUP_CODE :=
                    T_TEMP_REC (INDX).NOMENT_GROUP_CODE;
                RPT_DATA_DEPT.NOMENT_ENTRY_DATE :=
                    T_TEMP_REC (INDX).NOMENT_ENTRY_DATE;
                RPT_DATA_DEPT.NOMENT_CURR_CODE :=
                    T_TEMP_REC (INDX).NOMENT_CURR_CODE;
                RPT_DATA_DEPT.NOMENT_ORG_ENT_AMT :=
                    T_TEMP_REC (INDX).NOMENT_ORG_ENT_AMT;
                RPT_DATA_DEPT.NOMENT_ORG_ENT_DB_CR :=
                    T_TEMP_REC (INDX).NOMENT_ORG_ENT_DB_CR;
                RPT_DATA_DEPT.NOMENT_OS_BALANCE :=
                    T_TEMP_REC (INDX).NOMENT_OS_BALANCE;
                PIPE ROW (RPT_DATA_DEPT);
            END LOOP;
        END IF;
    --RETURN NULL;
    EXCEPTION
        WHEN OTHERS
        THEN
            err_mgs := SQLCODE || ' ' || SQLERRM;
            DBMS_OUTPUT.PUT_LINE (err_mgs);
    END SP_RNOMOSPRD_UPD_DEPT;
BEGIN
    NULL;
END PKG_RNOMOSPRD_UPD;
/
