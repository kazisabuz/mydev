CREATE OR REPLACE FUNCTION FN_GET_MAX_TRAN (P_ENTITY_CODE      NUMBER,
                                            P_BRN_CODE         NUMBER,
                                            P_INTERNAL_ACNUM   NUMBER,
                                            P_MONTH            VARCHAR,
                                            P_YEAR             NUMBER,
                                            P_TRAN_TYPE        VARCHAR,
                                            P_DRCR_FLAG        CHAR)
    RETURN NUMBER
IS
    V_ENTITY_CODE           IACLINK.IACLINK_ENTITY_NUM%TYPE := P_ENTITY_CODE;
    V_BRN_CODE              IACLINK.IACLINK_BRN_CODE%TYPE := P_BRN_CODE;
    V_INTERNAL_ACNUM        IACLINK.IACLINK_INTERNAL_ACNUM%TYPE
                                := P_INTERNAL_ACNUM;
    V_MONTH                 VARCHAR2 (4) := P_MONTH;
    V_YEAR                  NUMBER (4) := P_YEAR;
    V_TRAN_TYPE             VARCHAR2 (7) := P_TRAN_TYPE;
    V_DRCR_FLAG             CHAR (1) := P_DRCR_FLAG;
    V_MAX_TRANSFER_DEBIT    NUMBER (18, 3);
    V_MAX_TRANSFER_CREDIT   NUMBER (18, 3);
    V_MAX_CASH_DB_AMT       NUMBER (18, 3);
    V_MAX_CASH_CR_AMT       NUMBER (18, 3);
    V_RETURN_VALUE          NUMBER (18, 3);
    W_SQL                   VARCHAR2 (4000);
BEGIN
    W_SQL :=
           'SELECT   
        GREATEST(MAX(NVL(ACNTTRANPAMT_TRANSFER_DB_AMT,0)),MAX(NVL(ACNTTRANPAMT_CLEARING_DB_AMT,0)), MAX(NVL(ACNTTRANPAMT_TRADE_DB_AMT,0))) MAX_TRANSFER_DEBIT ,
        GREATEST( MAX(NVL(ACNTTRANPAMT_TRANSFER_CR_AMT,0)),MAX(NVL(ACNTTRANPAMT_CLEARING_CR_AMT,0)),MAX(NVL(ACNTTRANPAMT_TRADE_CR_AMT,0)))  MAX_TRANSFER_CREDIT ,
        MAX(NVL(ACNTTRANPAMT_CASH_DB_AMT,0))  MAX_CASH_DB_AMT ,
        MAX(NVL(ACNTTRANPAMT_CASH_CR_AMT,0))  MAX_CASH_CR_AMT 
        FROM  (
        SELECT  TRAN_INTERNAL_ACNUM,
           TRAN_TYPE_OF_TRAN,
           DECODE (TRAN_TYPE_OF_TRAN,1,DECODE(TRAN_DB_CR_FLG,''D'',MAX(NVL(TRAN_BASE_CURR_EQ_AMT,0)))) ACNTTRANPAMT_TRANSFER_DB_AMT,
           DECODE (TRAN_TYPE_OF_TRAN,1,DECODE(TRAN_DB_CR_FLG,''C'',MAX(NVL(TRAN_BASE_CURR_EQ_AMT,0)))) ACNTTRANPAMT_TRANSFER_CR_AMT,
           DECODE (TRAN_TYPE_OF_TRAN,3,DECODE(TRAN_DB_CR_FLG,''D'',MAX(NVL(TRAN_BASE_CURR_EQ_AMT,0)))) ACNTTRANPAMT_CASH_DB_AMT,
           DECODE (TRAN_TYPE_OF_TRAN,3,DECODE(TRAN_DB_CR_FLG,''C'',MAX(NVL(TRAN_BASE_CURR_EQ_AMT,0)))) ACNTTRANPAMT_CASH_CR_AMT,
           DECODE (TRAN_TYPE_OF_TRAN,2,DECODE(TRAN_DB_CR_FLG,''D'',MAX(NVL(TRAN_BASE_CURR_EQ_AMT,0)))) ACNTTRANPAMT_CLEARING_DB_AMT,
           DECODE (TRAN_TYPE_OF_TRAN,2,DECODE(TRAN_DB_CR_FLG,''C'',MAX(NVL(TRAN_BASE_CURR_EQ_AMT,0)))) ACNTTRANPAMT_CLEARING_CR_AMT,
           DECODE (TRAN_TYPE_OF_TRAN,NULL,DECODE(TRAN_DB_CR_FLG,''D'',MAX(NVL(TRAN_BASE_CURR_EQ_AMT,0)))) ACNTTRANPAMT_TRADE_DB_AMT,
           DECODE (TRAN_TYPE_OF_TRAN,NULL,DECODE(TRAN_DB_CR_FLG,''C'',MAX(NVL(TRAN_BASE_CURR_EQ_AMT,0)))) ACNTTRANPAMT_TRADE_CR_AMT
        FROM PRODUCTS, TRAN'
        || V_YEAR
        || '
        WHERE  PRODUCT_CODE = TRAN_PROD_CODE
           AND TRAN_ENTITY_NUM = :V_ENTITY_CODE
           AND TRAN_ACING_BRN_CODE = :V_BRN_CODE 
           AND TO_CHAR(TRAN_DATE_OF_TRAN,''MON'') = :V_MONTH
           AND PRODUCT_FOR_RUN_ACS = ''1''
           AND TRAN_INTERNAL_ACNUM = :V_INTERNAL_ACNUM
           AND TRAN_SYSTEM_POSTED_TRAN = ''0''
           AND TRAN_AUTH_ON IS NOT NULL
        GROUP BY   TRAN_INTERNAL_ACNUM,
           TRAN_TYPE_OF_TRAN, TRAN_DB_CR_FLG)
         ';
--DBMS_OUTPUT.PUT_LINE(W_SQL);
    EXECUTE IMMEDIATE W_SQL
        INTO V_MAX_TRANSFER_DEBIT,
             V_MAX_TRANSFER_CREDIT,
             V_MAX_CASH_DB_AMT,
             V_MAX_CASH_CR_AMT
        USING V_ENTITY_CODE,
              V_BRN_CODE,
              V_MONTH,
              V_INTERNAL_ACNUM;

    IF V_TRAN_TYPE = 'CASH' AND V_DRCR_FLAG = 'D'
    THEN
        V_RETURN_VALUE := V_MAX_CASH_DB_AMT;
    ELSIF V_TRAN_TYPE = 'CASH' AND V_DRCR_FLAG = 'C'
    THEN
        V_RETURN_VALUE := V_MAX_CASH_CR_AMT;
    ELSIF V_TRAN_TYPE = 'NONCASH' AND V_DRCR_FLAG = 'D'
    THEN
        V_RETURN_VALUE := V_MAX_TRANSFER_DEBIT;
    ELSIF V_TRAN_TYPE = 'NONCASH' AND V_DRCR_FLAG = 'C'
    THEN
        V_RETURN_VALUE := V_MAX_TRANSFER_CREDIT;
        ELSE NULL;
    END IF;

    RETURN V_RETURN_VALUE;
END;
/
