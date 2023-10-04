CREATE OR REPLACE FUNCTION FN_ISS_HEAD_BAL (P_BRANCH_CODE     NUMBER,
                                            P_ASON_DATE       DATE,
                                            P_RPT_HEAD_CODE   VARCHAR2,
                                            P_LAYOUT_CODE     VARCHAR2)
    RETURN NUMBER
IS
    V_OUTBAL          NUMBER (18, 2);
    V_RPT_HEAD_CODE   VARCHAR2 (10000) := P_RPT_HEAD_CODE;
    RPT_CODE          VARCHAR2 (1000);
    DELIMITER         VARCHAR2 (1) := '+';
    W_SQL             VARCHAR2 (1000);
    V_ERROR_CODE      NUMBER;
    V_ERROR_MESSAGE   VARCHAR2 (4000);
BEGIN
    RPT_CODE := REPLACE (V_RPT_HEAD_CODE, DELIMITER, ''',''');

    RPT_CODE := '''' || RPT_CODE || '''';

    IF P_LAYOUT_CODE = 'F12'
    THEN
        IF P_BRANCH_CODE <> 0
        THEN
            W_SQL := ' SELECT SUM (RPT_HEAD_BAL)
              --INTO V_OUTBAL
              FROM STATMENTOFAFFAIRS
             WHERE     RPT_BRN_CODE = :P_BRANCH_CODE
                   AND RPT_ENTRY_DATE = :P_ASON_DATE
                   AND CASHTYPE = ''1''
                   AND RPT_HEAD_CODE in('||RPT_CODE||')';


            EXECUTE IMMEDIATE W_SQL
                INTO V_OUTBAL
                USING P_BRANCH_CODE, P_ASON_DATE;

            DBMS_OUTPUT.PUT_LINE (W_SQL);
            DBMS_OUTPUT.PUT_LINE (P_BRANCH_CODE || P_ASON_DATE || RPT_CODE);
        ELSE
            W_SQL := ' SELECT SUM (RPT_HEAD_BAL)
               FROM STATMENTOFAFFAIRS
             WHERE     RPT_ENTRY_DATE = P_ASON_DATE
                    AND CASHTYPE = ''1''
                    AND RPT_HEAD_CODE IN ('||RPT_CODE||')';
                    
                    EXECUTE IMMEDIATE W_SQL
                INTO V_OUTBAL
                USING  P_ASON_DATE;
                   
        END IF;
    ELSIF P_LAYOUT_CODE = 'F42B'
    THEN
        IF P_BRANCH_CODE <> 0
        THEN
            W_SQL := 'SELECT SUM (RPT_HEAD_BAL)
               FROM INCOMEEXPENSE
             WHERE     RPT_BRN_CODE = P_BRANCH_CODE
                   AND RPT_ENTRY_DATE = P_ASON_DATE
                   AND CASHTYPE = ''1''
                   AND RPT_HEAD_CODE IN ('||RPT_CODE||')';
                   
                   EXECUTE IMMEDIATE W_SQL
                INTO V_OUTBAL
                USING P_BRANCH_CODE, P_ASON_DATE;
                   
        ELSE
            W_SQL := 'SELECT SUM (RPT_HEAD_BAL)
               FROM INCOMEEXPENSE
             WHERE       RPT_ENTRY_DATE = P_ASON_DATE
                   AND CASHTYPE = ''1''
                   AND RPT_HEAD_CODE IN ('||RPT_CODE||')';
                   
                   EXECUTE IMMEDIATE W_SQL
                INTO V_OUTBAL
                USING   P_ASON_DATE;
        END IF;
    END IF;

    RETURN V_OUTBAL;
    
EXCEPTION
    WHEN OTHERS
    THEN
        V_ERROR_CODE := SQLCODE;
        V_ERROR_MESSAGE := SQLERRM;
        DBMS_OUTPUT.PUT_LINE ('Error Code: ' || V_ERROR_CODE);
        DBMS_OUTPUT.PUT_LINE ('Error Message: ' || V_ERROR_MESSAGE);
        RETURN NULL;
END;
/
