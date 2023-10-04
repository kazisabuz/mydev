DROP PACKAGE SBLPROD.PKG_MARGIN_LIABILITY;

CREATE OR REPLACE PACKAGE SBLPROD.PKG_MARGIN_LIABILITY IS
  ---PURPOSE : Outward LC Liability And Margin Register

  TYPE REC_RETURN_TABLE IS RECORD(
    OLC_BRN_CODE                NUMBER(6),
    OLC_LC_TYPE                 VARCHAR2(6),
    OLC_LC_YEAR                 NUMBER(4),
    OLC_LC_SL                   NUMBER(6),
    OLC_CUST_NUM                NUMBER(12),
    LC_ACCOUNT_NAME             VARCHAR2(500),
    LC_ACCOUNT_NO               NUMBER(14),
    LC_ACCOUNT_HOLDER_ADDRESS   VARCHAR2(500),
    LC_LIMIT                    NUMBER(18, 3),
    LC_MARGIN                   NUMBER(18, 3),
    LC_SANCTION                 VARCHAR2(50),
    LC_WROTH                    VARCHAR2(50),
    LC_DATE                     DATE,
    LC_NUMBER                   VARCHAR2(40),
    LC_BENEFICARY_CODE          VARCHAR2(40),
    LC_PARTICULAR               VARCHAR2(150),
    LC_FOREIGN_DEBIT_CURRENCY   VARCHAR2(3),
    LC_FOREIGN_DEBIT_AMOUNT     NUMBER(18, 3),
    LC_FOREIGN_CONTRA_DATE      DATE,
    LC_FOREIGN_CREDIT_CURRENCY  VARCHAR2(3),
    LC_FOREIGN_CREDIT_AMOUNT    NUMBER,
    LC_LIABILITY_DEBIT_AMOUNT   NUMBER(18, 3),
    LC_LIABILITY_CONTRA_DATE    DATE,
    LC_LIABILITY_CREDIT_AMOUNT  NUMBER(18, 3),
    LC_LIABILITY_BALANCE_AMOUNT NUMBER(18, 3),
    LC_MARGIN_PERCENTAGE        NUMBER(18, 3),
    LC_MARGIN_DEBIT_AMOUNT      NUMBER(18, 3),
    LC_MARGIN_CONTRA_DATE       DATE,
    LC_MARGIN_CREDIT_AMOUNT     NUMBER(18, 3),
    LC_MARGIN_BALANCE_AMOUNT    NUMBER(18, 3),
    LC_REMARKS                  VARCHAR2(50),
    OLC_ENTD_ON                 DATE);

  TYPE TY_RETURN_TABLE IS TABLE OF REC_RETURN_TABLE;

  FUNCTION GET_MARGIN_LIABILITY_DATA(P_ENTITYNUMBER  NUMBER,
                                     P_BRANCH_CODE   NUMBER,
                                     P_CLIENT        NUMBER,
                                     P_ACCOUNTNUMBER NUMBER,
                                     P_AS_ON_DATE    DATE,
                                     P_LC_REF_NO     VARCHAR2 DEFAULT '',
                                     P_LC_TYPE       VARCHAR2 DEFAULT '',
                                     P_LC_YEAR       NUMBER DEFAULT '',
                                     P_LC_SL         NUMBER DEFAULT '',
                                     P_TENOR_TYPE    VARCHAR2 DEFAULT '') RETURN TY_RETURN_TABLE
    PIPELINED;
  --RETURN VARCHAR2;

  FUNCTION GET_OS_LC_AMT(P_ENTITYNUMBER NUMBER,
                         P_BRANCH_CODE  NUMBER,
                         P_LC_TYPE      VARCHAR2,
                         P_LC_YEAR      NUMBER,
                         P_LC_SL        NUMBER,
                         P_AS_ON_DATE   DATE) RETURN NUMBER;

  FUNCTION GET_OS_LC_LIABILITY_AMT(P_ENTITYNUMBER NUMBER,
                                   P_BRANCH_CODE  NUMBER,
                                   P_LC_TYPE      VARCHAR2,
                                   P_LC_YEAR      NUMBER,
                                   P_LC_SL        NUMBER,
                                   P_AS_ON_DATE   DATE) RETURN NUMBER;

  FUNCTION GET_CASH_MARGIN_REC_AMT(P_ENTITYNUMBER NUMBER,
                                   P_BRANCH_CODE  NUMBER,
                                   P_LC_TYPE      VARCHAR2,
                                   P_LC_YEAR      NUMBER,
                                   P_LC_SL        NUMBER,
                                   P_AS_ON_DATE   DATE) RETURN NUMBER;

  FUNCTION GET_GRADUAL_CASH_MAR_REC_AMT(P_ENTITYNUMBER NUMBER,
                                        P_BRANCH_CODE  NUMBER,
                                        P_LC_TYPE      VARCHAR2,
                                        P_LC_YEAR      NUMBER,
                                        P_LC_SL        NUMBER,
                                        P_AS_ON_DATE   DATE) RETURN NUMBER;

  FUNCTION GET_SG_MARGIN_REC_AMT(P_ENTITYNUMBER  NUMBER,
                                 P_BRANCH_CODE   NUMBER,
                                 P_LC_TYPE       VARCHAR2,
                                 P_LC_YEAR       NUMBER,
                                 P_LC_SL         NUMBER,
                                 P_AS_ON_DATE    DATE,
                                 P_BILL_WISE_REQ CHAR DEFAULT '0',
                                 P_BILL_BRN_CODE NUMBER DEFAULT 0,
                                 P_BILL_TYPE     VARCHAR2 DEFAULT '',
                                 P_BILL_YEAR     NUMBER DEFAULT 0,
                                 P_BILL_SERIAL   NUMBER DEFAULT 0) RETURN NUMBER;

  FUNCTION GET_EXPORT_CASH_MAR_REC_AMT(P_ENTITYNUMBER NUMBER,
                                       P_BRANCH_CODE  NUMBER,
                                       P_LC_TYPE      VARCHAR2,
                                       P_LC_YEAR      NUMBER,
                                       P_LC_SL        NUMBER,
                                       P_AS_ON_DATE   DATE) RETURN NUMBER;

  FUNCTION GET_TOT_CASH_MAR_RECOVER_AMT(P_ENTITYNUMBER NUMBER,
                                        P_BRANCH_CODE  NUMBER,
                                        P_LC_TYPE      VARCHAR2,
                                        P_LC_YEAR      NUMBER,
                                        P_LC_SL        NUMBER,
                                        P_AS_ON_DATE   DATE) RETURN NUMBER;

  FUNCTION GET_CASH_MAR_RELEASE_AMT(P_ENTITYNUMBER NUMBER,
                                    P_BRANCH_CODE  NUMBER,
                                    P_LC_TYPE      VARCHAR2,
                                    P_LC_YEAR      NUMBER,
                                    P_LC_SL        NUMBER,
                                    P_AS_ON_DATE   DATE) RETURN NUMBER;

  FUNCTION GET_SG_MAR_RELEASE_AMT(P_ENTITYNUMBER  NUMBER,
                                  P_BRANCH_CODE   NUMBER,
                                  P_LC_TYPE       VARCHAR2,
                                  P_LC_YEAR       NUMBER,
                                  P_LC_SL         NUMBER,
                                  P_AS_ON_DATE    DATE,
                                  P_BILL_WISE_REQ CHAR DEFAULT '0',
                                  P_BILL_BRN_CODE NUMBER DEFAULT 0,
                                  P_BILL_TYPE     VARCHAR2 DEFAULT '',
                                  P_BILL_YEAR     NUMBER DEFAULT 0,
                                  P_BILL_SERIAL   NUMBER DEFAULT 0) RETURN NUMBER;

  FUNCTION GET_TOT_CASH_MAR_RELEASE_AMT(P_ENTITYNUMBER NUMBER,
                                        P_BRANCH_CODE  NUMBER,
                                        P_LC_TYPE      VARCHAR2,
                                        P_LC_YEAR      NUMBER,
                                        P_LC_SL        NUMBER,
                                        P_AS_ON_DATE   DATE) RETURN NUMBER;

  FUNCTION GET_LC_CASH_MARGIN_AMT_BAL(P_ENTITYNUMBER NUMBER,
                                      P_BRANCH_CODE  NUMBER,
                                      P_LC_TYPE      VARCHAR2,
                                      P_LC_YEAR      NUMBER,
                                      P_LC_SL        NUMBER,
                                      P_AS_ON_DATE   DATE) RETURN NUMBER;

  FUNCTION GET_TOT_DEP_MAR_RECOVER_AMT(P_ENTITYNUMBER NUMBER,
                                       P_BRANCH_CODE  NUMBER,
                                       P_LC_TYPE      VARCHAR2,
                                       P_LC_YEAR      NUMBER,
                                       P_LC_SL        NUMBER,
                                       P_AS_ON_DATE   DATE) RETURN NUMBER;

  FUNCTION GET_TOT_DEP_MAR_RELEASE_AMT(P_ENTITYNUMBER NUMBER,
                                       P_BRANCH_CODE  NUMBER,
                                       P_LC_TYPE      VARCHAR2,
                                       P_LC_YEAR      NUMBER,
                                       P_LC_SL        NUMBER,
                                       P_AS_ON_DATE   DATE) RETURN NUMBER;

  FUNCTION GET_LC_DEP_MARGIN_AMT_BAL(P_ENTITYNUMBER NUMBER,
                                     P_BRANCH_CODE  NUMBER,
                                     P_LC_TYPE      VARCHAR2,
                                     P_LC_YEAR      NUMBER,
                                     P_LC_SL        NUMBER,
                                     P_AS_ON_DATE   DATE) RETURN NUMBER;

  FUNCTION GET_TOT_SEC_MAR_RECOVER_AMT(P_ENTITYNUMBER NUMBER,
                                       P_BRANCH_CODE  NUMBER,
                                       P_LC_TYPE      VARCHAR2,
                                       P_LC_YEAR      NUMBER,
                                       P_LC_SL        NUMBER,
                                       P_AS_ON_DATE   DATE) RETURN NUMBER;

  FUNCTION GET_TOT_SEC_MAR_RELEASE_AMT(P_ENTITYNUMBER NUMBER,
                                       P_BRANCH_CODE  NUMBER,
                                       P_LC_TYPE      VARCHAR2,
                                       P_LC_YEAR      NUMBER,
                                       P_LC_SL        NUMBER,
                                       P_AS_ON_DATE   DATE) RETURN NUMBER;

  FUNCTION GET_LC_SEC_MARGIN_AMT_BAL(P_ENTITYNUMBER NUMBER,
                                     P_BRANCH_CODE  NUMBER,
                                     P_LC_TYPE      VARCHAR2,
                                     P_LC_YEAR      NUMBER,
                                     P_LC_SL        NUMBER,
                                     P_AS_ON_DATE   DATE) RETURN NUMBER;

  FUNCTION GET_TOT_MARGIN_RECOVER_AMT(P_ENTITYNUMBER NUMBER,
                                      P_BRANCH_CODE  NUMBER,
                                      P_LC_TYPE      VARCHAR2,
                                      P_LC_YEAR      NUMBER,
                                      P_LC_SL        NUMBER,
                                      P_AS_ON_DATE   DATE) RETURN NUMBER;

  FUNCTION GET_TOT_MARGIN_RELEASE_AMT(P_ENTITYNUMBER NUMBER,
                                      P_BRANCH_CODE  NUMBER,
                                      P_LC_TYPE      VARCHAR2,
                                      P_LC_YEAR      NUMBER,
                                      P_LC_SL        NUMBER,
                                      P_AS_ON_DATE   DATE) RETURN NUMBER;

  FUNCTION GET_LC_TOT_MARGIN_AMT_BAL(P_ENTITYNUMBER NUMBER,
                                     P_BRANCH_CODE  NUMBER,
                                     P_LC_TYPE      VARCHAR2,
                                     P_LC_YEAR      NUMBER,
                                     P_LC_SL        NUMBER,
                                     P_AS_ON_DATE   DATE) RETURN NUMBER;

END;
/
DROP PACKAGE BODY SBLPROD.PKG_MARGIN_LIABILITY;

CREATE OR REPLACE PACKAGE BODY SBLPROD.PKG_MARGIN_LIABILITY IS
  FUNCTION GET_MARGIN_LIABILITY_DATA(P_ENTITYNUMBER  NUMBER,
                                     P_BRANCH_CODE   NUMBER,
                                     P_CLIENT        NUMBER,
                                     P_ACCOUNTNUMBER NUMBER,
                                     P_AS_ON_DATE    DATE,
                                     P_LC_REF_NO     VARCHAR2 DEFAULT '',
                                     P_LC_TYPE       VARCHAR2 DEFAULT '',
                                     P_LC_YEAR       NUMBER DEFAULT '',
                                     P_LC_SL         NUMBER DEFAULT '',
                                     P_TENOR_TYPE    VARCHAR2 DEFAULT '') RETURN TY_RETURN_TABLE
    PIPELINED
  --RETURN VARCHAR2
   IS
    TEMP_DATE               DATE;
    SIGHT_DATES             VARCHAR2(1000);
    USANCE_DATES            VARCHAR2(1000);
    SIGHT_CNT               NUMBER;
    USANCE_CNT              NUMBER;
    V_SQL_STAT              CLOB;
    V_SQL_MAR               CLOB;
    V_SQL_PAY               CLOB;
    V_SQL_REL               CLOB;
    V_SQL_BILL_PAY          CLOB;
    COUNT_PAYMENT           NUMBER;
    MARGIN_RELEADE          NUMBER;
    MARGIN_RECOVER          NUMBER;
    V_SQL_STAT_AMD          CLOB;
    V_SQL_STAT_CAN          CLOB;
    V_SQL_STAT_CAN_MAN      CLOB;
    V_SQL_STAT_OBPAYDISB    CLOB;
    V_SQL_STAT_OBFREEMARGIN CLOB;
    COUNT_AMNT              NUMBER;
    COUNT_AMNTMARGIN        NUMBER;
  
    RET_RETURN_TABLE REC_RETURN_TABLE;
  
    TYPE REC_FETCH_TABLE IS RECORD(
      OLC_ENTITY_NUM              NUMBER(4),
      OLC_BRN_CODE                NUMBER(6),
      OLC_LC_TYPE                 VARCHAR2(6),
      OLC_LC_YEAR                 NUMBER(4),
      OLC_LC_SL                   NUMBER(6),
      OLC_CUST_NUM                NUMBER(12),
      LC_ACCOUNT_NAME             VARCHAR2(500),
      LC_ACCOUNT_NO               NUMBER(14),
      LC_ACCOUNT_HOLDER_ADDRESS   VARCHAR2(500),
      LC_LIMIT                    NUMBER(18, 3),
      LC_MARGIN                   NUMBER(18, 3),
      LC_SANCTION                 VARCHAR2(50),
      LC_WROTH                    VARCHAR2(50),
      LC_DATE                     DATE,
      LC_NUMBER                   VARCHAR2(40),
      LC_BENEFICARY_CODE          VARCHAR2(40),
      LC_PARTICULAR               VARCHAR2(150),
      LC_FOREIGN_DEBIT_CURRENCY   VARCHAR2(3),
      LC_FOREIGN_DEBIT_AMOUNT     NUMBER(18, 3),
      LC_FOREIGN_CONTRA_DATE      DATE,
      LC_FOREIGN_CREDIT_CURRENCY  VARCHAR2(3),
      LC_FOREIGN_CREDIT_AMOUNT    NUMBER,
      LC_LIABILITY_DEBIT_AMOUNT   NUMBER(18, 3),
      LC_LIABILITY_CONTRA_DATE    DATE,
      LC_LIABILITY_CREDIT_AMOUNT  NUMBER(18, 3),
      LC_LIABILITY_BALANCE_AMOUNT NUMBER(18, 3),
      LC_MARGIN_PERCENTAGE        NUMBER(18, 3),
      LC_MARGIN_DEBIT_AMOUNT      NUMBER(18, 3),
      LC_MARGIN_CONTRA_DATE       DATE,
      LC_MARGIN_CREDIT_AMOUNT     NUMBER(18, 3),
      LC_MARGIN_BALANCE_AMOUNT    NUMBER(18, 3),
      LC_REMARKS                  VARCHAR2(50),
      OLC_ENTD_ON                 DATE);
  
    TYPE TT_FETCH_TABLE IS TABLE OF REC_FETCH_TABLE INDEX BY PLS_INTEGER;
    T_FETCH_TABLE TT_FETCH_TABLE;
  
    TYPE REC_FETCH_TABLE_PAY IS RECORD(
      LC_FOREIGN_CREDIT_CURRENCY VARCHAR2(3),
      LC_DATE                    DATE,
      LC_FOREIGN_CREDIT_AMOUNT   NUMBER(18, 3),
      LC_LIABILITY_CREDIT_AMOUNT NUMBER(18, 3),
      OLC_ENTD_ON                DATE);
  
    TYPE TT_FETCH_TABLE_PAY IS TABLE OF REC_FETCH_TABLE_PAY INDEX BY PLS_INTEGER;
    T_FETCH_TABLE_PAY TT_FETCH_TABLE_PAY;
  
    TYPE REC_FETCH_TABLE_MAR IS RECORD(
      LC_ACCOUNT_NAME           VARCHAR2(500),
      LC_ACCOUNT_NO             NUMBER(14),
      LC_ACCOUNT_HOLDER_ADDRESS VARCHAR2(500),
      LC_NUMBER                 VARCHAR2(40),
      LC_BENEFICARY_CODE        VARCHAR2(40),
      OLC_CUST_NUM              NUMBER(12),
      LC_DATE                   DATE,
      LC_MARGIN_CREDIT_AMOUNT   NUMBER(18, 3),
      OLC_ENTD_ON               DATE);
  
    TYPE TT_FETCH_TABLE_MAR IS TABLE OF REC_FETCH_TABLE_MAR INDEX BY PLS_INTEGER;
    T_FETCH_TABLE_MAR TT_FETCH_TABLE_MAR;
  
    TYPE REC_FETCH_TABLE_REL IS RECORD(
      LC_DATE                DATE,
      LC_MARGIN_DEBIT_AMOUNT NUMBER(18, 3),
      OLC_ENTD_ON            DATE);
  
    TYPE TT_FETCH_TABLE_REL IS TABLE OF REC_FETCH_TABLE_REL INDEX BY PLS_INTEGER;
    T_FETCH_TABLE_REL TT_FETCH_TABLE_REL;
  
    TYPE REC_FETCH_TABLE_AMD IS RECORD(
      OLCA_ENHANCEMNT_REDUCN      CHAR(1),
      OLC_ENTITY_NUM              NUMBER(4),
      OLC_BRN_CODE                NUMBER(6),
      OLC_LC_TYPE                 VARCHAR2(6),
      OLC_LC_YEAR                 NUMBER(4),
      OLC_LC_SL                   NUMBER(6),
      OLC_CUST_NUM                NUMBER(12),
      LC_ACCOUNT_NAME             VARCHAR2(500),
      LC_ACCOUNT_NO               NUMBER(14),
      LC_ACCOUNT_HOLDER_ADDRESS   VARCHAR2(500),
      LC_LIMIT                    NUMBER(18, 3),
      LC_MARGIN                   NUMBER(18, 3),
      LC_SANCTION                 VARCHAR2(50),
      LC_WROTH                    VARCHAR2(50),
      LC_DATE                     DATE,
      LC_NUMBER                   VARCHAR2(40),
      LC_BENEFICARY_CODE          VARCHAR2(40),
      LC_PARTICULAR               VARCHAR2(150),
      LC_FOREIGN_DEBIT_CURRENCY   VARCHAR2(3),
      LC_FOREIGN_DEBIT_AMOUNT     NUMBER(18, 3),
      LC_FOREIGN_CONTRA_DATE      DATE,
      LC_FOREIGN_CREDIT_CURRENCY  VARCHAR2(3),
      LC_FOREIGN_CREDIT_AMOUNT    NUMBER,
      LC_LIABILITY_DEBIT_AMOUNT   NUMBER(18, 3),
      LC_LIABILITY_CONTRA_DATE    DATE,
      LC_LIABILITY_CREDIT_AMOUNT  NUMBER(18, 3),
      LC_LIABILITY_BALANCE_AMOUNT NUMBER(18, 3),
      LC_MARGIN_PERCENTAGE        NUMBER(18, 3),
      LC_MARGIN_DEBIT_AMOUNT      NUMBER(18, 3),
      LC_MARGIN_CONTRA_DATE       DATE,
      LC_MARGIN_CREDIT_AMOUNT     NUMBER(18, 3),
      LC_MARGIN_BALANCE_AMOUNT    NUMBER(18, 3),
      LC_REMARKS                  VARCHAR2(50),
      OLC_ENTD_ON                 DATE);
  
    TYPE TT_FETCH_TABLE_AMD IS TABLE OF REC_FETCH_TABLE_AMD INDEX BY PLS_INTEGER;
    T_FETCH_TABLE_AMD TT_FETCH_TABLE_AMD;
  
    V_ERRM     VARCHAR2(4000);
    LC_REMARKS VARCHAR2(20);
  
    TYPE REC_FETCH_TABLE_CAN IS RECORD(
      OLC_ENTITY_NUM              NUMBER(4),
      OLC_BRN_CODE                NUMBER(6),
      OLC_LC_TYPE                 VARCHAR2(6),
      OLC_LC_YEAR                 NUMBER(4),
      OLC_LC_SL                   NUMBER(6),
      OLC_CUST_NUM                NUMBER(12),
      LC_ACCOUNT_NAME             VARCHAR2(500),
      LC_ACCOUNT_NO               NUMBER(14),
      LC_ACCOUNT_HOLDER_ADDRESS   VARCHAR2(500),
      LC_LIMIT                    NUMBER(18, 3),
      LC_MARGIN                   NUMBER(18, 3),
      LC_SANCTION                 VARCHAR2(50),
      LC_WROTH                    VARCHAR2(50),
      LC_DATE                     DATE,
      LC_NUMBER                   VARCHAR2(40),
      LC_BENEFICARY_CODE          VARCHAR2(40),
      LC_PARTICULAR               VARCHAR2(150),
      LC_FOREIGN_DEBIT_CURRENCY   VARCHAR2(3),
      LC_FOREIGN_DEBIT_AMOUNT     NUMBER(18, 3),
      LC_FOREIGN_CONTRA_DATE      DATE,
      LC_FOREIGN_CREDIT_CURRENCY  VARCHAR2(3),
      LC_FOREIGN_CREDIT_AMOUNT    NUMBER,
      LC_LIABILITY_DEBIT_AMOUNT   NUMBER(18, 3),
      LC_LIABILITY_CONTRA_DATE    DATE,
      LC_LIABILITY_CREDIT_AMOUNT  NUMBER(18, 3),
      LC_LIABILITY_BALANCE_AMOUNT NUMBER(18, 3),
      LC_MARGIN_PERCENTAGE        NUMBER(18, 3),
      LC_MARGIN_DEBIT_AMOUNT      NUMBER(18, 3),
      LC_MARGIN_CONTRA_DATE       DATE,
      LC_MARGIN_CREDIT_AMOUNT     NUMBER(18, 3),
      LC_MARGIN_BALANCE_AMOUNT    NUMBER(18, 3),
      LC_REMARKS                  VARCHAR2(50),
      OLC_ENTD_ON                 DATE);
  
    TYPE TT_FETCH_TABLE_CAN IS TABLE OF REC_FETCH_TABLE_CAN INDEX BY PLS_INTEGER;
    T_FETCH_TABLE_CAN TT_FETCH_TABLE_CAN;
  
    TYPE REC_FETCH_TABLE_CAN_MAN IS RECORD(
      OLCMNRV_DB_CR_FLG           CHAR(1),
      OLC_ENTITY_NUM              NUMBER(4),
      OLC_BRN_CODE                NUMBER(6),
      OLC_LC_TYPE                 VARCHAR2(6),
      OLC_LC_YEAR                 NUMBER(4),
      OLC_LC_SL                   NUMBER(6),
      OLC_CUST_NUM                NUMBER(12),
      LC_ACCOUNT_NAME             VARCHAR2(500),
      LC_ACCOUNT_NO               NUMBER(14),
      LC_ACCOUNT_HOLDER_ADDRESS   VARCHAR2(500),
      LC_LIMIT                    NUMBER(18, 3),
      LC_MARGIN                   NUMBER(18, 3),
      LC_SANCTION                 VARCHAR2(50),
      LC_WROTH                    VARCHAR2(50),
      LC_DATE                     DATE,
      LC_NUMBER                   VARCHAR2(40),
      LC_BENEFICARY_CODE          VARCHAR2(40),
      LC_PARTICULAR               VARCHAR2(150),
      LC_FOREIGN_DEBIT_CURRENCY   VARCHAR2(3),
      LC_FOREIGN_DEBIT_AMOUNT     NUMBER(18, 3),
      LC_FOREIGN_CONTRA_DATE      DATE,
      LC_FOREIGN_CREDIT_CURRENCY  VARCHAR2(3),
      LC_FOREIGN_CREDIT_AMOUNT    NUMBER,
      LC_LIABILITY_DEBIT_AMOUNT   NUMBER(18, 3),
      LC_LIABILITY_CONTRA_DATE    DATE,
      LC_LIABILITY_CREDIT_AMOUNT  NUMBER(18, 3),
      LC_LIABILITY_BALANCE_AMOUNT NUMBER(18, 3),
      LC_MARGIN_PERCENTAGE        NUMBER(18, 3),
      LC_MARGIN_DEBIT_AMOUNT      NUMBER(18, 3),
      LC_MARGIN_CONTRA_DATE       DATE,
      LC_MARGIN_CREDIT_AMOUNT     NUMBER(18, 3),
      LC_MARGIN_BALANCE_AMOUNT    NUMBER(18, 3),
      LC_REMARKS                  VARCHAR2(50),
      OLC_ENTD_ON                 DATE);
  
    TYPE TT_FETCH_TABLE_CAN_MAN IS TABLE OF REC_FETCH_TABLE_CAN_MAN INDEX BY PLS_INTEGER;
    T_FETCH_TABLE_CAN_MAN TT_FETCH_TABLE_CAN_MAN;
  
    V_SQL_SHIP CLOB;
    TYPE REC_FETCH_TABLE_SHIP IS RECORD(
      LC_DATE                 DATE,
      LC_MARGIN_CREDIT_AMOUNT NUMBER(18, 3),
      OLC_ENTD_ON             DATE);
  
    TYPE TT_FETCH_TABLE_SHIP IS TABLE OF REC_FETCH_TABLE_SHIP INDEX BY PLS_INTEGER;
    T_FETCH_TABLE_SHIP TT_FETCH_TABLE_SHIP;
  
    TYPE REC_FETCH_TABLE_OBPAYDISB IS RECORD(
      BRANCH_CODE          NUMBER(6),
      CLIENTS_NUMBER       NUMBER(12),
      CLIENTS_NAME         VARCHAR2(500),
      CLIENTS_ADDRESS      VARCHAR2(500),
      MARGIN_REC_DATE      DATE,
      MARGIN_CREDIT_AMOUNT NUMBER(18, 3),
      MARGIN_ENTD_ON       DATE);
    TYPE TT_FETCH_TABLE_OBPAYDISB IS TABLE OF REC_FETCH_TABLE_OBPAYDISB INDEX BY PLS_INTEGER;
    T_FETCH_TABLE_OBPAYDISB TT_FETCH_TABLE_OBPAYDISB;
  
    TYPE REC_FETCH_TABLE_OBFREEMARGIN IS RECORD(
      LC_ACCOUNT_NAME           VARCHAR2(500),
      LC_ACCOUNT_NO             NUMBER(14),
      LC_ACCOUNT_HOLDER_ADDRESS VARCHAR2(500),
      LC_NUMBER                 VARCHAR2(40),
      LC_BENEFICARY_CODE        VARCHAR2(40),
      OLC_CUST_NUM              NUMBER(12),
      LC_DATE                   DATE,
      LC_MARGIN_CREDIT_AMOUNT   NUMBER(18, 3),
      OLC_ENTD_ON               DATE,
      OLC_BRN_CODE              NUMBER(6),
      OLC_LC_TYPE               VARCHAR2(6),
      OLC_LC_YEAR               NUMBER(4),
      OLC_LC_SL                 NUMBER(6));
  
    TYPE TT_FETCH_TABLE_OBFREEMARGIN IS TABLE OF REC_FETCH_TABLE_OBFREEMARGIN INDEX BY PLS_INTEGER;
    T_FETCH_TABLE_OBFREEMARGIN TT_FETCH_TABLE_OBFREEMARGIN;
  
  BEGIN
    BEGIN
      V_SQL_STAT := 'SELECT OLC_ENTITY_NUM, OLC_BRN_CODE, OLC_LC_TYPE, OLC_LC_YEAR, OLC_LC_SL,
        OLC_CUST_NUM, CLIENTS_NAME AS LC_ACCOUNT_NAME, FACNO(1,OLC_CUST_LIAB_ACC) AS LC_ACCOUNT_NO,
         CLIENTS_ADDR1 AS LC_ACCOUNT_HOLDER_ADDRESS, OLC_TOT_LIAB_LIM_CURR AS LC_LIMIT,
         OLC_PERC_OF_INS_VALUE_CVRD AS  LC_MARGIN, '' '' LC_SANCTION, '' '' LC_WROTH,
         DECODE(O.POST_TRAN_DATE, NULL, TRUNC(O.OLC_ENTD_ON), O.POST_TRAN_DATE) AS LC_DATE, NVL (OLC_CORR_REF_NUM, '' '') AS LC_NUMBER,
         NVL (OLC_BENEF_CODE, '' '') AS LC_BENEFICARY_CODE, '' '' AS LC_PARTICULAR,
         OLC_LC_CURR_CODE AS LC_FOREIGN_DEBIT_CURRENCY, OLC_TOT_LIAB_LC_CURR AS LC_FOREIGN_DEBIT_AMOUNT,
         OLC_LC_DATE AS LC_FOREIGN_CONTRA_DATE, '' '' AS LC_FOREIGN_CREDIT_CURRENCY,
        0 AS LC_FOREIGN_CREDIT_AMOUNT, OLC_TOT_LIAB_BASE_CURR AS LC_LIABILITY_DEBIT_AMOUNT,
        OLC_LC_DATE AS LC_LIABILITY_CONTRA_DATE, 0 AS LC_LIABILITY_CREDIT_AMOUNT,
        0 AS LC_LIABILITY_BALANCE_AMOUNT, (SELECT OM.OLCM_MARGIN_PERC FROM OLCMAR OM WHERE OM.OLCM_BRN_CODE=O.OLC_BRN_CODE
        AND OM.OLCM_LC_TYPE=O.OLC_LC_TYPE AND OM.OLCM_LC_YEAR=O.OLC_LC_YEAR AND OM.OLCM_LC_SL=O.OLC_LC_SL AND
        OLCM_TXN_TYPE=''L'' AND  OLCM_TXN_SL=1) AS LC_MARGIN_PERCENTAGE, 0 AS LC_MARGIN_DEBIT_AMOUNT,
        OLC_LC_DATE AS LC_MARGIN_CONTRA_DATE, (SELECT OLCM_MARGIN_AMT FROM OLCMAR WHERE OLCM_BRN_CODE=O.OLC_BRN_CODE
        AND OLCM_LC_TYPE=O.OLC_LC_TYPE AND OLCM_LC_YEAR=O.OLC_LC_YEAR AND OLCM_LC_SL=O.OLC_LC_SL AND OLCM_TXN_TYPE=''L''
        AND OLCM_TXN_SL=1) AS LC_MARGIN_CREDIT_AMOUNT, 0 AS LC_MARGIN_BALANCE_AMOUNT, '' '' AS LC_REMARKS, OLC_ENTD_ON
        FROM OLC O JOIN CLIENTS C ON (O.OLC_CUST_NUM=C.CLIENTS_CODE) JOIN OLCTENORS OT
    ON (O.OLC_ENTITY_NUM = OT.OLCT_ENTITY_NUM AND
       O.OLC_BRN_CODE = OT.OLCT_BRN_CODE
    AND O.OLC_LC_TYPE=OT.OLCT_LC_TYPE AND
    O.OLC_LC_YEAR=OT.OLCT_LC_YEAR AND
    O.OLC_LC_SL=OT.OLCT_LC_SL) WHERE O.OLC_ENTITY_NUM=:1 AND O.OLC_BRN_CODE=:2 AND OLC_AUTH_ON IS NOT NULL ';
    
      IF P_CLIENT IS NOT NULL THEN
        V_SQL_STAT := V_SQL_STAT || ' AND C.CLIENTS_CODE =' || P_CLIENT;
      END IF;
    
      IF P_ACCOUNTNUMBER IS NOT NULL THEN
        V_SQL_STAT := V_SQL_STAT || ' AND FACNO(1,OLC_CUST_LIAB_ACC) =' || P_ACCOUNTNUMBER;
      END IF;
    
      IF P_AS_ON_DATE IS NOT NULL THEN
        V_SQL_STAT := V_SQL_STAT || ' AND DECODE(O.POST_TRAN_DATE, NULL, TRUNC(O.OLC_ENTD_ON), O.POST_TRAN_DATE) <= ' || CHR(39) || P_AS_ON_DATE ||
                      CHR(39) || ' ';
      END IF;
    
      IF P_LC_REF_NO IS NOT NULL THEN
        V_SQL_STAT := V_SQL_STAT || ' AND OLC_CORR_REF_NUM = ' || CHR(39) || P_LC_REF_NO || CHR(39) || ' ';
      END IF;
    
      IF P_LC_TYPE IS NOT NULL THEN
        V_SQL_STAT := V_SQL_STAT || ' AND OLC_LC_TYPE = ' || CHR(39) || P_LC_TYPE || CHR(39) || ' ';
      END IF;
    
      IF P_LC_YEAR IS NOT NULL THEN
        V_SQL_STAT := V_SQL_STAT || ' AND OLC_LC_YEAR = ' || P_LC_YEAR || ' ';
      END IF;
    
      IF P_LC_SL IS NOT NULL THEN
        V_SQL_STAT := V_SQL_STAT || ' AND OLC_LC_SL = ' || P_LC_SL || ' ';
      END IF;
    
      IF TO_CHAR(P_TENOR_TYPE) IS NOT NULL THEN
        V_SQL_STAT := V_SQL_STAT || ' AND OLCT_TENOR_TYPE = ' || CHR(39) || P_TENOR_TYPE || CHR(39);
      END IF;
    
      --DBMS_OUTPUT.PUT_LINE('OLC QUERY :   ' || V_SQL_STAT);
      EXECUTE IMMEDIATE V_SQL_STAT BULK COLLECT
        INTO T_FETCH_TABLE
        USING P_ENTITYNUMBER, P_BRANCH_CODE;
    
      -----****START LC LOOP-----*******---------------
    
      FOR I IN T_FETCH_TABLE.FIRST .. T_FETCH_TABLE.LAST LOOP
        COUNT_AMNTMARGIN := 0;
        SIGHT_DATES      := '';
        USANCE_DATES     := '';
        SIGHT_CNT        := 0;
        USANCE_CNT       := 0;
      
        RET_RETURN_TABLE.OLC_ENTD_ON               := T_FETCH_TABLE(I).OLC_ENTD_ON;
        RET_RETURN_TABLE.LC_ACCOUNT_NAME           := T_FETCH_TABLE(I).LC_ACCOUNT_NAME;
        RET_RETURN_TABLE.LC_ACCOUNT_NO             := T_FETCH_TABLE(I).LC_ACCOUNT_NO;
        RET_RETURN_TABLE.LC_ACCOUNT_HOLDER_ADDRESS := T_FETCH_TABLE(I).LC_ACCOUNT_HOLDER_ADDRESS;
        RET_RETURN_TABLE.LC_LIMIT                  := T_FETCH_TABLE(I).LC_LIMIT;
        RET_RETURN_TABLE.LC_MARGIN                 := T_FETCH_TABLE(I).LC_MARGIN;
        RET_RETURN_TABLE.LC_SANCTION               := T_FETCH_TABLE(I).LC_SANCTION;
        RET_RETURN_TABLE.LC_WROTH                  := T_FETCH_TABLE(I).LC_WROTH;
        RET_RETURN_TABLE.LC_DATE                   := T_FETCH_TABLE(I).LC_DATE;
        RET_RETURN_TABLE.LC_NUMBER                 := T_FETCH_TABLE(I).LC_NUMBER;
        RET_RETURN_TABLE.LC_BENEFICARY_CODE        := T_FETCH_TABLE(I).LC_BENEFICARY_CODE;
        RET_RETURN_TABLE.OLC_CUST_NUM              := T_FETCH_TABLE(I).OLC_CUST_NUM;
        RET_RETURN_TABLE.OLC_BRN_CODE              := T_FETCH_TABLE(I).OLC_BRN_CODE;
        RET_RETURN_TABLE.OLC_LC_TYPE               := T_FETCH_TABLE(I).OLC_LC_TYPE;
        RET_RETURN_TABLE.OLC_LC_YEAR               := T_FETCH_TABLE(I).OLC_LC_YEAR;
        RET_RETURN_TABLE.OLC_LC_SL                 := T_FETCH_TABLE(I).OLC_LC_SL;
        RET_RETURN_TABLE.LC_FOREIGN_DEBIT_CURRENCY := T_FETCH_TABLE(I).LC_FOREIGN_DEBIT_CURRENCY;
        RET_RETURN_TABLE.LC_FOREIGN_DEBIT_AMOUNT   := T_FETCH_TABLE(I).LC_FOREIGN_DEBIT_AMOUNT;
        ---START CONTRA_DATE
        SELECT MAX(CONTRA_DATE)
        INTO   RET_RETURN_TABLE.LC_FOREIGN_CONTRA_DATE
        FROM   (SELECT MAX(IBPAY.IBPAY_ENTRY_DATE) CONTRA_DATE
                 FROM   IBILL IBILL
                 INNER  JOIN IBPAY IBPAY
                 ON     (IBILL.IBILL_ENTITY_NUM = IBPAY.IBPAY_ENTITY_NUM AND IBILL.IBILL_BRN_CODE = IBPAY.IBPAY_BRN_CODE AND
                        IBILL.IBILL_BILL_TYPE = IBPAY.IBPAY_BILL_TYPE AND IBILL.IBILL_BILL_YEAR = IBPAY.IBPAY_BILL_YEAR AND
                        IBILL.IBILL_BILL_SL = IBPAY.IBPAY_BILL_SL)
                 WHERE  IBPAY.IBPAY_AUTH_ON IS NOT NULL
                 AND    IBILL.IBILL_ENTITY_NUM = T_FETCH_TABLE(I).OLC_ENTITY_NUM
                 AND    IBILL.IBILL_BRN_CODE = T_FETCH_TABLE(I).OLC_BRN_CODE
                 AND    IBILL.IBILL_OLC_TYPE = T_FETCH_TABLE(I).OLC_LC_TYPE
                 AND    IBILL.IBILL_OLC_YEAR = T_FETCH_TABLE(I).OLC_LC_YEAR
                 AND    IBILL.IBILL_OLC_SL = T_FETCH_TABLE(I).OLC_LC_SL
                 AND    IBILL.IBILL_TENOR_TYPE = 'S'
                 UNION ALL
                 SELECT MAX(IBILLACC.IBACC_ENTRY_DATE) CONTRA_DATE
                 FROM   IBILL
                 INNER  JOIN IBILLACC
                 ON     (IBILL.IBILL_ENTITY_NUM = IBILLACC.IBACC_ENTITY_NUM AND IBILL.IBILL_BRN_CODE = IBILLACC.IBACC_BRN_CODE AND
                        IBILL.IBILL_BILL_TYPE = IBILLACC.IBACC_BILL_TYPE AND IBILL.IBILL_BILL_YEAR = IBILLACC.IBACC_BILL_YEAR AND
                        IBILL.IBILL_OLC_SL = IBILLACC.IBACC_BILL_SL)
                 WHERE  IBILLACC.IBACC_AUTH_ON IS NOT NULL
                 AND    IBILL.IBILL_ENTITY_NUM = T_FETCH_TABLE(I).OLC_ENTITY_NUM
                 AND    IBILL.IBILL_BRN_CODE = T_FETCH_TABLE(I).OLC_BRN_CODE
                 AND    IBILL.IBILL_OLC_TYPE = T_FETCH_TABLE(I).OLC_LC_TYPE
                 AND    IBILL.IBILL_OLC_YEAR = T_FETCH_TABLE(I).OLC_LC_YEAR
                 AND    IBILL.IBILL_OLC_SL = T_FETCH_TABLE(I).OLC_LC_SL
                 AND    IBILL.IBILL_TENOR_TYPE = 'U');
        RET_RETURN_TABLE.LC_LIABILITY_CONTRA_DATE := RET_RETURN_TABLE.LC_FOREIGN_CONTRA_DATE;
        ---END CONTRA_DATE
      
        RET_RETURN_TABLE.LC_FOREIGN_CREDIT_CURRENCY  := T_FETCH_TABLE(I).LC_FOREIGN_CREDIT_CURRENCY;
        RET_RETURN_TABLE.LC_FOREIGN_CREDIT_AMOUNT    := T_FETCH_TABLE(I).LC_FOREIGN_CREDIT_AMOUNT;
        RET_RETURN_TABLE.LC_LIABILITY_DEBIT_AMOUNT   := T_FETCH_TABLE(I).LC_LIABILITY_DEBIT_AMOUNT;
        RET_RETURN_TABLE.LC_LIABILITY_CREDIT_AMOUNT  := T_FETCH_TABLE(I).LC_LIABILITY_CREDIT_AMOUNT;
        RET_RETURN_TABLE.LC_LIABILITY_BALANCE_AMOUNT := T_FETCH_TABLE(I).LC_LIABILITY_BALANCE_AMOUNT;
      
        ---FOR RCOVER MARGIN
        SELECT NVL(SUM((SELECT NVL(SUM(OLCCM_MRGN_AMT_RCVRY_CURR), 0) AMOUNT_COUNT
                         FROM   OLCCASHMAR C
                         WHERE  C.OLCCM_BRN_CODE = T_FETCH_TABLE(I).OLC_BRN_CODE
                         AND    C.OLCCM_LC_TYPE = T_FETCH_TABLE(I).OLC_LC_TYPE
                         AND    C.OLCCM_LC_YEAR = T_FETCH_TABLE(I).OLC_LC_YEAR
                         AND    C.OLCCM_LC_SL = T_FETCH_TABLE(I).OLC_LC_SL
                         AND    TRIM(DECODE(C.POST_TRAN_DATE, NULL, TRUNC(C.OLCCM_ENTD_ON), C.POST_TRAN_DATE)) = T_FETCH_TABLE(I).LC_DATE
                         AND    C.OLCCM_AUTH_ON IS NOT NULL) + (SELECT NVL(SUM(OLCDEPMAR_LIEN_AMT_DEP_CURR), 0) AMOUNT_COUNT
                                                                FROM   OLCDEPMAR D
                                                                WHERE  D.OLCDEPMAR_BRN_CODE = T_FETCH_TABLE(I).OLC_BRN_CODE
                                                                AND    D.OLCDEPMAR_LC_TYPE = T_FETCH_TABLE(I).OLC_LC_TYPE
                                                                AND    D.OLCDEPMAR_LC_YEAR = T_FETCH_TABLE(I).OLC_LC_YEAR
                                                                AND    D.OLCDEPMAR_LC_SL = T_FETCH_TABLE(I).OLC_LC_SL
                                                                AND    TRIM(TRUNC(D.OLCDEPMAR_ENTD_ON)) = T_FETCH_TABLE(I).LC_DATE
                                                                AND    D.OLCDEPMAR_AUTH_ON IS NOT NULL)),
                    0) AS AMOUNT_COUNT
        INTO   MARGIN_RECOVER
        FROM   DUAL;
      
        IF (MARGIN_RECOVER > 0) THEN
          RET_RETURN_TABLE.LC_PARTICULAR          := 'Liability and Margin Held';
          RET_RETURN_TABLE.LC_MARGIN_PERCENTAGE   := T_FETCH_TABLE(I).LC_MARGIN_PERCENTAGE;
          RET_RETURN_TABLE.LC_MARGIN_DEBIT_AMOUNT := 0;
        
          --START MARGIN_CONTRA_DATE
          SELECT MAX(LC_DATE)
          INTO   RET_RETURN_TABLE.LC_MARGIN_CONTRA_DATE
          FROM   (SELECT MAX(TRUNC(OLCDEPMARR_ENTD_ON)) AS LC_DATE
                   FROM   OLCDEPMARREL
                   WHERE  OLCDEPMARR_BRN_CODE = T_FETCH_TABLE(I).OLC_BRN_CODE
                   AND    OLCDEPMARR_LC_TYPE = T_FETCH_TABLE(I).OLC_LC_TYPE
                   AND    OLCDEPMARR_LC_YEAR = T_FETCH_TABLE(I).OLC_LC_YEAR
                   AND    OLCDEPMARR_LC_SL = T_FETCH_TABLE(I).OLC_LC_SL
                   AND    OLCDEPMARR_AUTH_ON IS NOT NULL
                   UNION ALL
                   SELECT MAX(DECODE(POST_TRAN_DATE, NULL, TRUNC(OLCCMR_ENTD_ON), POST_TRAN_DATE)) AS LC_DATE
                   FROM   OLCCASHMARREL OLCDEPMARR_REL_AMT
                   WHERE  OLCCMR_BRN_CODE = T_FETCH_TABLE(I).OLC_BRN_CODE
                   AND    OLCCMR_LC_TYPE = T_FETCH_TABLE(I).OLC_LC_TYPE
                   AND    OLCCMR_LC_YEAR = T_FETCH_TABLE(I).OLC_LC_YEAR
                   AND    OLCCMR_LC_SL = T_FETCH_TABLE(I).OLC_LC_SL
                   AND    OLCCMR_AUTH_ON IS NOT NULL);
          --END FOR  LC_MARGIN_CONTRA_DATE
        
          -- RET_RETURN_TABLE.LC_MARGIN_CREDIT_AMOUNT:= MARGIN_RECOVER;
          RET_RETURN_TABLE.LC_MARGIN_CREDIT_AMOUNT  := T_FETCH_TABLE(I).LC_MARGIN_CREDIT_AMOUNT;
          RET_RETURN_TABLE.LC_MARGIN_BALANCE_AMOUNT := 0;
        
        ELSE
          RET_RETURN_TABLE.LC_PARTICULAR := 'Liability Held';
          --------FOR MARGIN
          RET_RETURN_TABLE.LC_MARGIN_PERCENTAGE     := 0;
          RET_RETURN_TABLE.LC_MARGIN_DEBIT_AMOUNT   := 0;
          RET_RETURN_TABLE.LC_MARGIN_CONTRA_DATE    := NULL;
          RET_RETURN_TABLE.LC_MARGIN_CREDIT_AMOUNT  := 0;
          RET_RETURN_TABLE.LC_MARGIN_BALANCE_AMOUNT := 0;
        END IF;
      
        RET_RETURN_TABLE.LC_REMARKS := T_FETCH_TABLE(I).LC_REMARKS;
        PIPE ROW(RET_RETURN_TABLE);
        ----------UPDATE LC TABLE FOR A PARTICULAR LC--------------
      
        ------******---START AMEDMENT BEGIN---****------
      
        BEGIN
          SELECT COUNT(*)
          INTO   COUNT_AMNT
          FROM   OLCAMD
          WHERE  OLCA_BRN_CODE = T_FETCH_TABLE(I).OLC_BRN_CODE
          AND    OLCA_LC_TYPE = T_FETCH_TABLE(I).OLC_LC_TYPE
          AND    OLCA_LC_YEAR = T_FETCH_TABLE(I).OLC_LC_YEAR
          AND    OLCA_LC_SL = T_FETCH_TABLE(I).OLC_LC_SL;
        
          IF COUNT_AMNT > 0 THEN
            V_SQL_STAT_AMD := 'SELECT OLCA_ENHANCEMNT_REDUCN, OLC_ENTITY_NUM, OLC_BRN_CODE, OLC_LC_TYPE, OLC_LC_YEAR,
                         OLC_LC_SL, OLC_CUST_NUM, CLIENTS_NAME AS LC_ACCOUNT_NAME, FACNO(1,OLC_CUST_LIAB_ACC) AS LC_ACCOUNT_NO,
                         CLIENTS_ADDR1 AS LC_ACCOUNT_HOLDER_ADDRESS, OLC_TOT_LIAB_LIM_CURR AS LC_LIMIT, OLC_PERC_OF_INS_VALUE_CVRD AS  LC_MARGIN,
                         '''' LC_SANCTION, '''' LC_WROTH, DECODE(AM.POST_TRAN_DATE, NULL, TRUNC(AM.OLCA_ENTD_ON), AM.POST_TRAN_DATE) AS LC_DATE, NVL (OLC_CORR_REF_NUM, '' '') AS LC_NUMBER,
                         NVL (OLCA_BENEF_CODE, '''') AS LC_BENEFICARY_CODE, '''' AS LC_PARTICULAR, OLCA_LC_CURR_CODE AS LC_FOREIGN_DEBIT_CURRENCY,
                         NVL(L.OLCLD_TXN_AMT,0) AS LC_FOREIGN_DEBIT_AMOUNT, OLCA_ENTRY_DATE AS LC_FOREIGN_CONTRA_DATE,
                         OLCA_LC_CURR_CODE AS LC_FOREIGN_CREDIT_CURRENCY, NVL(OLCA_ADD_LIAB_LC_CURR,0) AS LC_FOREIGN_CREDIT_AMOUNT,
                         OLCA_ADD_LIAB_BASE_CURR AS LC_LIABILITY_DEBIT_AMOUNT, OLCA_ENTRY_DATE AS LC_LIABILITY_CONTRA_DATE,
                         NVL(OLCA_TOT_LIAB_LIM_CURR,0) AS LC_LIABILITY_CREDIT_AMOUNT, 0 AS LC_LIABILITY_BALANCE_AMOUNT,
                         OLCM_MARGIN_PERC AS LC_MARGIN_PERCENTAGE, 0 AS LC_MARGIN_DEBIT_AMOUNT, OLCA_ENTRY_DATE AS LC_MARGIN_CONTRA_DATE,
                         (OLCM_MARGIN_AMT) AS LC_MARGIN_CREDIT_AMOUNT, 0 AS LC_MARGIN_BALANCE_AMOUNT, '''' AS LC_REMARKS, OLCA_ENTD_ON AS OLC_ENTD_ON
                         FROM OLCAMD AM
                         JOIN OLCLED L ON (OLCA_ENTITY_NUM = OLCLD_ENTITY_NUM AND OLCA_BRN_CODE=OLCLD_BRN_CODE AND OLCA_LC_TYPE=OLCLD_LC_TYPE AND OLCA_LC_YEAR=OLCLD_LC_YEAR
                         AND OLCA_LC_SL=OLCLD_LC_SL AND OLCA_AMD_SL=OLCLD_TXN_SL AND OLCA_ENHANCEMNT_REDUCN=OLCLD_RED_ENH AND OLCLD_TXN_TYPE=''A'' )
                         JOIN OLC O ON (OLCA_ENTITY_NUM = OLC_ENTITY_NUM AND OLCA_BRN_CODE=OLC_BRN_CODE AND OLCA_LC_TYPE=OLC_LC_TYPE AND OLCA_LC_YEAR=OLC_LC_YEAR AND OLCA_LC_SL=OLC_LC_SL)
                         JOIN CLIENTS ON (O.OLC_CUST_NUM=CLIENTS.CLIENTS_CODE)
                         LEFT JOIN OLCMAR OM ON (O.OLC_ENTITY_NUM=OM.OLCM_ENTITY_NUM AND O.OLC_BRN_CODE=OM.OLCM_BRN_CODE AND O.OLC_LC_TYPE = OM.OLCM_LC_TYPE
                         AND O.OLC_LC_YEAR=OM.OLCM_LC_YEAR AND O.OLC_LC_SL=OM.OLCM_LC_SL and OLCM_TXN_TYPE=''A'' AND AM.OLCA_AMD_SL=OM.OLCM_TXN_SL ) JOIN OLCTENORS OT
                         ON (O.OLC_ENTITY_NUM = OT.OLCT_ENTITY_NUM AND O.OLC_BRN_CODE = OT.OLCT_BRN_CODE AND O.OLC_LC_TYPE=OT.OLCT_LC_TYPE AND O.OLC_LC_YEAR=OT.OLCT_LC_YEAR AND O.OLC_LC_SL=OT.OLCT_LC_SL)
                         WHERE OLC_AUTH_ON IS NOT NULL AND OLCA_AUTH_ON IS NOT NULL AND OLCA_ENTITY_NUM =:1 AND O.OLC_BRN_CODE=:2 AND O.OLC_LC_TYPE=:3 AND O.OLC_LC_YEAR=:4 AND O.OLC_LC_SL=:5 ';
          
            IF TO_CHAR(P_TENOR_TYPE) IS NOT NULL THEN
              V_SQL_STAT_AMD := V_SQL_STAT_AMD || ' AND OLCT_TENOR_TYPE = ' || CHR(39) || P_TENOR_TYPE || CHR(39);
            END IF;
          
            IF P_AS_ON_DATE IS NOT NULL THEN
              V_SQL_STAT_AMD := V_SQL_STAT_AMD || ' AND DECODE(AM.POST_TRAN_DATE, NULL, TRUNC(OLCA_ENTD_ON), AM.POST_TRAN_DATE) <= ' || CHR(39) ||
                                P_AS_ON_DATE || CHR(39) || ' ';
            END IF;
          
            BEGIN
              --DBMS_OUTPUT.PUT_LINE('OLCAMD QUERY :   ' || V_SQL_STAT_AMD);
              EXECUTE IMMEDIATE V_SQL_STAT_AMD BULK COLLECT
                INTO T_FETCH_TABLE_AMD
                USING P_ENTITYNUMBER, P_BRANCH_CODE, T_FETCH_TABLE(I).OLC_LC_TYPE, T_FETCH_TABLE(I).OLC_LC_YEAR, T_FETCH_TABLE(I).OLC_LC_SL;
            
              FOR M IN T_FETCH_TABLE_AMD.FIRST .. T_FETCH_TABLE_AMD.LAST LOOP
                RET_RETURN_TABLE.OLC_ENTD_ON               := T_FETCH_TABLE_AMD(M).OLC_ENTD_ON;
                RET_RETURN_TABLE.LC_ACCOUNT_NAME           := T_FETCH_TABLE_AMD(M).LC_ACCOUNT_NAME;
                RET_RETURN_TABLE.LC_ACCOUNT_NO             := T_FETCH_TABLE_AMD(M).LC_ACCOUNT_NO;
                RET_RETURN_TABLE.LC_ACCOUNT_HOLDER_ADDRESS := T_FETCH_TABLE_AMD(M).LC_ACCOUNT_HOLDER_ADDRESS;
                RET_RETURN_TABLE.LC_LIMIT                  := T_FETCH_TABLE_AMD(M).LC_LIMIT;
                RET_RETURN_TABLE.LC_MARGIN                 := T_FETCH_TABLE_AMD(M).LC_MARGIN;
                RET_RETURN_TABLE.LC_SANCTION               := T_FETCH_TABLE_AMD(M).LC_SANCTION;
                RET_RETURN_TABLE.LC_WROTH                  := T_FETCH_TABLE_AMD(M).LC_WROTH;
                RET_RETURN_TABLE.LC_DATE                   := T_FETCH_TABLE_AMD(M).LC_DATE;
                RET_RETURN_TABLE.LC_NUMBER                 := T_FETCH_TABLE_AMD(M).LC_NUMBER;
                RET_RETURN_TABLE.LC_BENEFICARY_CODE        := T_FETCH_TABLE_AMD(M).LC_BENEFICARY_CODE;
                RET_RETURN_TABLE.OLC_CUST_NUM              := T_FETCH_TABLE_AMD(M).OLC_CUST_NUM;
                RET_RETURN_TABLE.OLC_BRN_CODE              := T_FETCH_TABLE_AMD(M).OLC_BRN_CODE;
                RET_RETURN_TABLE.OLC_LC_TYPE               := T_FETCH_TABLE_AMD(M).OLC_LC_TYPE;
                RET_RETURN_TABLE.OLC_LC_YEAR               := T_FETCH_TABLE_AMD(M).OLC_LC_YEAR;
                RET_RETURN_TABLE.OLC_LC_SL                 := T_FETCH_TABLE_AMD(M).OLC_LC_SL;
              
                IF (T_FETCH_TABLE_AMD(M).OLCA_ENHANCEMNT_REDUCN = 'E') THEN
                  RET_RETURN_TABLE.LC_FOREIGN_DEBIT_CURRENCY := T_FETCH_TABLE_AMD(M).LC_FOREIGN_DEBIT_CURRENCY;
                  RET_RETURN_TABLE.LC_FOREIGN_DEBIT_AMOUNT   := T_FETCH_TABLE_AMD(M).LC_FOREIGN_DEBIT_AMOUNT;
                
                  SELECT MAX(IBPAY.IBPAY_ENTRY_DATE)
                  INTO   RET_RETURN_TABLE.LC_FOREIGN_CONTRA_DATE
                  FROM   IBILL IBILL
                  INNER  JOIN IBPAY IBPAY
                  ON     (IBILL.IBILL_ENTITY_NUM = IBPAY.IBPAY_ENTITY_NUM AND IBILL.IBILL_BRN_CODE = IBPAY.IBPAY_BRN_CODE AND
                         IBILL.IBILL_BILL_TYPE = IBPAY.IBPAY_BILL_TYPE AND IBILL.IBILL_BILL_YEAR = IBPAY.IBPAY_BILL_YEAR AND
                         IBILL.IBILL_BILL_SL = IBPAY.IBPAY_BILL_SL)
                  WHERE  IBPAY.IBPAY_AUTH_ON IS NOT NULL
                  AND    IBILL.IBILL_ENTITY_NUM = P_ENTITYNUMBER
                  AND    IBILL.IBILL_BRN_CODE = T_FETCH_TABLE(I).OLC_BRN_CODE
                  AND    IBILL.IBILL_OLC_TYPE = T_FETCH_TABLE(I).OLC_LC_TYPE
                  AND    IBILL.IBILL_OLC_YEAR = T_FETCH_TABLE(I).OLC_LC_YEAR
                  AND    IBILL.IBILL_OLC_SL = T_FETCH_TABLE(I).OLC_LC_SL;
                  RET_RETURN_TABLE.LC_FOREIGN_CREDIT_CURRENCY := NULL;
                  RET_RETURN_TABLE.LC_FOREIGN_CREDIT_AMOUNT   := 0;
                  RET_RETURN_TABLE.LC_LIABILITY_DEBIT_AMOUNT  := T_FETCH_TABLE_AMD(M).LC_LIABILITY_DEBIT_AMOUNT;
                  SELECT MAX(IBPAY.IBPAY_ENTRY_DATE)
                  INTO   RET_RETURN_TABLE.LC_LIABILITY_CONTRA_DATE
                  FROM   IBILL IBILL
                  INNER  JOIN IBPAY IBPAY
                  ON     (IBILL.IBILL_ENTITY_NUM = IBPAY.IBPAY_ENTITY_NUM AND IBILL.IBILL_BRN_CODE = IBPAY.IBPAY_BRN_CODE AND
                         IBILL.IBILL_BILL_TYPE = IBPAY.IBPAY_BILL_TYPE AND IBILL.IBILL_BILL_YEAR = IBPAY.IBPAY_BILL_YEAR AND
                         IBILL.IBILL_BILL_SL = IBPAY.IBPAY_BILL_SL)
                  WHERE  IBPAY.IBPAY_AUTH_ON IS NOT NULL
                  AND    IBILL.IBILL_ENTITY_NUM = P_ENTITYNUMBER
                  AND    IBILL.IBILL_BRN_CODE = T_FETCH_TABLE(I).OLC_BRN_CODE
                  AND    IBILL.IBILL_OLC_TYPE = T_FETCH_TABLE(I).OLC_LC_TYPE
                  AND    IBILL.IBILL_OLC_YEAR = T_FETCH_TABLE(I).OLC_LC_YEAR
                  AND    IBILL.IBILL_OLC_SL = T_FETCH_TABLE(I).OLC_LC_SL;
                
                  RET_RETURN_TABLE.LC_LIABILITY_CREDIT_AMOUNT  := 0;
                  RET_RETURN_TABLE.LC_LIABILITY_BALANCE_AMOUNT := 0;
                
                  IF (T_FETCH_TABLE_AMD(M).LC_MARGIN_CREDIT_AMOUNT > 0) THEN
                    RET_RETURN_TABLE.LC_PARTICULAR           := 'Liability and Margin Held -A';
                    RET_RETURN_TABLE.LC_MARGIN_CREDIT_AMOUNT := T_FETCH_TABLE_AMD(M).LC_MARGIN_CREDIT_AMOUNT;
                  ELSE
                    RET_RETURN_TABLE.LC_PARTICULAR           := 'Liability Held -A';
                    RET_RETURN_TABLE.LC_MARGIN_CREDIT_AMOUNT := 0;
                  END IF;
                ELSIF (T_FETCH_TABLE_AMD(M).OLCA_ENHANCEMNT_REDUCN = 'R') THEN
                  RET_RETURN_TABLE.LC_FOREIGN_DEBIT_CURRENCY   := NULL;
                  RET_RETURN_TABLE.LC_FOREIGN_DEBIT_AMOUNT     := 0;
                  RET_RETURN_TABLE.LC_FOREIGN_CONTRA_DATE      := T_FETCH_TABLE(I).LC_DATE;
                  RET_RETURN_TABLE.LC_FOREIGN_CREDIT_CURRENCY  := T_FETCH_TABLE_AMD(M).LC_FOREIGN_CREDIT_CURRENCY;
                  RET_RETURN_TABLE.LC_FOREIGN_CREDIT_AMOUNT    := T_FETCH_TABLE_AMD(M).LC_FOREIGN_DEBIT_AMOUNT;
                  RET_RETURN_TABLE.LC_LIABILITY_DEBIT_AMOUNT   := 0;
                  RET_RETURN_TABLE.LC_LIABILITY_CONTRA_DATE    := T_FETCH_TABLE(I).LC_DATE;
                  RET_RETURN_TABLE.LC_LIABILITY_CREDIT_AMOUNT  := T_FETCH_TABLE_AMD(M).LC_LIABILITY_CREDIT_AMOUNT;
                  RET_RETURN_TABLE.LC_LIABILITY_BALANCE_AMOUNT := 0;
                  IF (T_FETCH_TABLE_AMD(M).LC_MARGIN_CREDIT_AMOUNT > 0) THEN
                    RET_RETURN_TABLE.LC_PARTICULAR           := 'Liability Reversed and Margin Held -A';
                    RET_RETURN_TABLE.LC_MARGIN_CREDIT_AMOUNT := T_FETCH_TABLE_AMD(M).LC_MARGIN_CREDIT_AMOUNT;
                    SELECT MAX(LC_DATE)
                    INTO   RET_RETURN_TABLE.LC_MARGIN_CONTRA_DATE
                    FROM   (SELECT MAX(TRUNC(OLCDEPMARR_ENTD_ON)) AS LC_DATE
                             FROM   OLCDEPMARREL
                             WHERE  OLCDEPMARR_BRN_CODE = T_FETCH_TABLE(I).OLC_BRN_CODE
                             AND    OLCDEPMARR_LC_TYPE = T_FETCH_TABLE(I).OLC_LC_TYPE
                             AND    OLCDEPMARR_LC_YEAR = T_FETCH_TABLE(I).OLC_LC_YEAR
                             AND    OLCDEPMARR_LC_SL = T_FETCH_TABLE(I).OLC_LC_SL
                             AND    OLCDEPMARR_AUTH_ON IS NOT NULL
                             UNION ALL
                             SELECT MAX(DECODE(POST_TRAN_DATE, NULL, TRUNC(OLCCMR_ENTD_ON), POST_TRAN_DATE)) AS LC_DATE
                             FROM   OLCCASHMARREL OLCDEPMARR_REL_AMT
                             WHERE  OLCCMR_BRN_CODE = T_FETCH_TABLE(I).OLC_BRN_CODE
                             AND    OLCCMR_LC_TYPE = T_FETCH_TABLE(I).OLC_LC_TYPE
                             AND    OLCCMR_LC_YEAR = T_FETCH_TABLE(I).OLC_LC_YEAR
                             AND    OLCCMR_LC_SL = T_FETCH_TABLE(I).OLC_LC_SL
                             AND    OLCCMR_AUTH_ON IS NOT NULL);
                  ELSE
                    RET_RETURN_TABLE.LC_PARTICULAR           := 'Liability Reversed -A';
                    RET_RETURN_TABLE.LC_MARGIN_CREDIT_AMOUNT := 0;
                    RET_RETURN_TABLE.LC_MARGIN_CONTRA_DATE   := NULL;
                  END IF;
                ELSE
                  RET_RETURN_TABLE.LC_LIABILITY_DEBIT_AMOUNT   := 0;
                  RET_RETURN_TABLE.LC_LIABILITY_CONTRA_DATE    := NULL;
                  RET_RETURN_TABLE.LC_LIABILITY_CREDIT_AMOUNT  := 0;
                  RET_RETURN_TABLE.LC_LIABILITY_BALANCE_AMOUNT := 0;
                  IF (T_FETCH_TABLE_AMD(M).LC_MARGIN_CREDIT_AMOUNT > 0) THEN
                    RET_RETURN_TABLE.LC_MARGIN_CREDIT_AMOUNT := T_FETCH_TABLE_AMD(M).LC_MARGIN_CREDIT_AMOUNT;
                    RET_RETURN_TABLE.LC_PARTICULAR           := 'Margin Held -A';
                  ELSE
                    RET_RETURN_TABLE.LC_MARGIN_CREDIT_AMOUNT := 0;
                    RET_RETURN_TABLE.LC_PARTICULAR           := '';
                  END IF;
                END IF;
              
                RET_RETURN_TABLE.LC_MARGIN_PERCENTAGE     := T_FETCH_TABLE_AMD(M).LC_MARGIN_PERCENTAGE;
                RET_RETURN_TABLE.LC_MARGIN_DEBIT_AMOUNT   := 0;
                RET_RETURN_TABLE.LC_MARGIN_BALANCE_AMOUNT := 0;
              
                IF (RET_RETURN_TABLE.LC_LIABILITY_CREDIT_AMOUNT > 0 OR RET_RETURN_TABLE.LC_LIABILITY_DEBIT_AMOUNT > 0 OR
                   (T_FETCH_TABLE_AMD(M).LC_MARGIN_CREDIT_AMOUNT > 0)) THEN
                  PIPE ROW(RET_RETURN_TABLE);
                END IF;
              END LOOP;
            EXCEPTION
              WHEN VALUE_ERROR THEN
                NULL;
              WHEN NO_DATA_FOUND THEN
                NULL;
              WHEN OTHERS THEN
                V_ERRM := 'Error: ' || SQLERRM;
            END;
          END IF;
        END;
        --**************---END  OLCAMDMENT -----***********************--
      
        --******-START MARGIN RECOVERY  OTHER DATE NOT LC DATE----*****------
        BEGIN
          V_SQL_MAR := 'SELECT CLIENTS_NAME AS LC_ACCOUNT_NAME, FACNO(1,OLC_CUST_LIAB_ACC) AS LC_ACCOUNT_NO,
                    CLIENTS_ADDR1 AS LC_ACCOUNT_HOLDER_ADDRESS, NVL (OLC_CORR_REF_NUM, '' '') AS LC_NUMBER,
                    NVL (OLC_BENEF_CODE, '' '') AS LC_BENEFICARY_CODE, OLC_CUST_NUM,DECODE(LO.POST_TRAN_DATE, NULL, TRUNC(LO.OLCCM_ENTD_ON), LO.POST_TRAN_DATE) AS LC_DATE,
                    SUM(NVL(OLCCM_MRGN_AMT_RCVRY_CURR,0))  LC_MARGIN_CREDIT_AMOUNT, MAX(LO.OLCCM_ENTD_ON)  OLC_ENTD_ON
                    FROM  OLCCASHMAR LO INNER JOIN OLC L ON (
                    LO.OLCCM_ENTITY_NUM=L.OLC_ENTITY_NUM AND LO.OLCCM_BRN_CODE=L.OLC_BRN_CODE AND
                    LO.OLCCM_LC_TYPE=L.OLC_LC_TYPE AND LO.OLCCM_LC_YEAR=L.OLC_LC_YEAR AND LO.OLCCM_LC_SL=L.OLC_LC_SL)
                    JOIN CLIENTS C ON (L.OLC_CUST_NUM=C.CLIENTS_CODE)
                    JOIN OLCTENORS OT ON (L.OLC_ENTITY_NUM = OT.OLCT_ENTITY_NUM AND L.OLC_BRN_CODE = OT.OLCT_BRN_CODE AND L.OLC_LC_TYPE=OT.OLCT_LC_TYPE AND
                    L.OLC_LC_YEAR=OT.OLCT_LC_YEAR AND L.OLC_LC_SL=OT.OLCT_LC_SL)
                    WHERE LO.OLCCM_ENTITY_NUM =:1 AND LO.OLCCM_BRN_CODE=:2 AND LO.OLCCM_LC_TYPE =:3 AND LO.OLCCM_LC_YEAR =:4
                    AND LO.OLCCM_LC_SL =:5 AND LO.OLCCM_IS_GRADUAL_MARGIN=1 AND LO.OLCCM_AUTH_ON IS NOT NULL ';
        
          IF TO_CHAR(P_TENOR_TYPE) IS NOT NULL THEN
            V_SQL_MAR := V_SQL_MAR || ' AND OLCT_TENOR_TYPE = ' || CHR(39) || P_TENOR_TYPE || CHR(39);
          END IF;
        
          IF P_AS_ON_DATE IS NOT NULL THEN
            V_SQL_MAR := V_SQL_MAR || ' AND DECODE(LO.POST_TRAN_DATE, NULL, TRUNC(LO.OLCCM_ENTD_ON), LO.POST_TRAN_DATE) <= ' || CHR(39) ||
                         P_AS_ON_DATE || CHR(39) || ' ';
          END IF;
        
          V_SQL_MAR := V_SQL_MAR ||
                       ' GROUP BY OLCCM_ENTRY_DATE, CLIENTS_NAME,OLC_CUST_LIAB_ACC,CLIENTS_ADDR1,OLC_CORR_REF_NUM,OLC_BENEF_CODE,OLC_CUST_NUM,LO.POST_TRAN_DATE,LO.OLCCM_ENTD_ON ';
          --DBMS_OUTPUT.PUT_LINE('Margin QUERY :   ' || V_SQL_MAR);
          EXECUTE IMMEDIATE V_SQL_MAR BULK COLLECT
            INTO T_FETCH_TABLE_MAR
            USING T_FETCH_TABLE(I).OLC_ENTITY_NUM, T_FETCH_TABLE(I).OLC_BRN_CODE, T_FETCH_TABLE(I).OLC_LC_TYPE, T_FETCH_TABLE(I).OLC_LC_YEAR, T_FETCH_TABLE(I).OLC_LC_SL;
          BEGIN
            FOR J IN T_FETCH_TABLE_MAR.FIRST .. T_FETCH_TABLE_MAR.LAST LOOP
              RET_RETURN_TABLE.OLC_ENTD_ON                 := T_FETCH_TABLE_MAR(J).OLC_ENTD_ON;
              RET_RETURN_TABLE.LC_ACCOUNT_NAME             := T_FETCH_TABLE_MAR(J).LC_ACCOUNT_NAME;
              RET_RETURN_TABLE.LC_ACCOUNT_NO               := T_FETCH_TABLE_MAR(J).LC_ACCOUNT_NO;
              RET_RETURN_TABLE.LC_ACCOUNT_HOLDER_ADDRESS   := T_FETCH_TABLE_MAR(J).LC_ACCOUNT_HOLDER_ADDRESS;
              RET_RETURN_TABLE.LC_LIMIT                    := 0;
              RET_RETURN_TABLE.LC_MARGIN                   := 0;
              RET_RETURN_TABLE.LC_SANCTION                 := NULL;
              RET_RETURN_TABLE.LC_WROTH                    := NULL;
              RET_RETURN_TABLE.LC_DATE                     := T_FETCH_TABLE_MAR(J).LC_DATE;
              RET_RETURN_TABLE.LC_NUMBER                   := T_FETCH_TABLE_MAR(J).LC_NUMBER;
              RET_RETURN_TABLE.LC_BENEFICARY_CODE          := T_FETCH_TABLE_MAR(J).LC_BENEFICARY_CODE;
              RET_RETURN_TABLE.OLC_CUST_NUM                := T_FETCH_TABLE_MAR(J).OLC_CUST_NUM;
              RET_RETURN_TABLE.OLC_BRN_CODE                := T_FETCH_TABLE(I).OLC_BRN_CODE;
              RET_RETURN_TABLE.OLC_LC_TYPE                 := T_FETCH_TABLE(I).OLC_LC_TYPE;
              RET_RETURN_TABLE.OLC_LC_YEAR                 := T_FETCH_TABLE(I).OLC_LC_YEAR;
              RET_RETURN_TABLE.OLC_LC_SL                   := T_FETCH_TABLE(I).OLC_LC_SL;
              RET_RETURN_TABLE.LC_FOREIGN_DEBIT_CURRENCY   := NULL;
              RET_RETURN_TABLE.LC_FOREIGN_DEBIT_AMOUNT     := 0;
              RET_RETURN_TABLE.LC_FOREIGN_CONTRA_DATE      := NULL;
              RET_RETURN_TABLE.LC_FOREIGN_CREDIT_CURRENCY  := NULL;
              RET_RETURN_TABLE.LC_FOREIGN_CREDIT_AMOUNT    := 0;
              RET_RETURN_TABLE.LC_LIABILITY_DEBIT_AMOUNT   := 0;
              RET_RETURN_TABLE.LC_LIABILITY_CONTRA_DATE    := NULL;
              RET_RETURN_TABLE.LC_LIABILITY_CREDIT_AMOUNT  := 0;
              RET_RETURN_TABLE.LC_LIABILITY_BALANCE_AMOUNT := 0;
              RET_RETURN_TABLE.LC_PARTICULAR               := 'Margin Held-Gradual';
              RET_RETURN_TABLE.LC_MARGIN_PERCENTAGE        := 0;
              RET_RETURN_TABLE.LC_MARGIN_DEBIT_AMOUNT      := 0;
            
              SELECT MAX(LC_DATE)
              INTO   RET_RETURN_TABLE.LC_MARGIN_CONTRA_DATE
              FROM   (SELECT MAX(TRUNC(OLCDEPMARR_ENTD_ON)) AS LC_DATE
                       FROM   OLCDEPMARREL
                       WHERE  OLCDEPMARR_BRN_CODE = T_FETCH_TABLE(I).OLC_BRN_CODE
                       AND    OLCDEPMARR_LC_TYPE = T_FETCH_TABLE(I).OLC_LC_TYPE
                       AND    OLCDEPMARR_LC_YEAR = T_FETCH_TABLE(I).OLC_LC_YEAR
                       AND    OLCDEPMARR_LC_SL = T_FETCH_TABLE(I).OLC_LC_SL
                       AND    OLCDEPMARR_AUTH_ON IS NOT NULL
                       UNION ALL
                       SELECT MAX(DECODE(POST_TRAN_DATE, NULL, TRUNC(OLCCMR_ENTD_ON), POST_TRAN_DATE)) AS LC_DATE
                       FROM   OLCCASHMARREL OLCDEPMARR_REL_AMT
                       WHERE  OLCCMR_BRN_CODE = T_FETCH_TABLE(I).OLC_BRN_CODE
                       AND    OLCCMR_LC_TYPE = T_FETCH_TABLE(I).OLC_LC_TYPE
                       AND    OLCCMR_LC_YEAR = T_FETCH_TABLE(I).OLC_LC_YEAR
                       AND    OLCCMR_LC_SL = T_FETCH_TABLE(I).OLC_LC_SL
                       AND    OLCCMR_AUTH_ON IS NOT NULL);
            
              RET_RETURN_TABLE.LC_MARGIN_CREDIT_AMOUNT  := T_FETCH_TABLE_MAR(J).LC_MARGIN_CREDIT_AMOUNT;
              RET_RETURN_TABLE.LC_MARGIN_BALANCE_AMOUNT := 0;
              RET_RETURN_TABLE.LC_REMARKS               := T_FETCH_TABLE(I).LC_REMARKS;
              PIPE ROW(RET_RETURN_TABLE);
            END LOOP;
          EXCEPTION
            WHEN VALUE_ERROR THEN
              NULL;
            WHEN NO_DATA_FOUND THEN
              NULL;
            WHEN OTHERS THEN
              NULL;
          END;
        END;
        -- End Margin Recovery Other than LC Date
      
        --**************---START  SHIPPING GRUANTEE -----***********************--
        BEGIN
          V_SQL_SHIP := ' SELECT DECODE(S.POST_TRAN_DATE, NULL, TRUNC(S.SG_ENTD_ON), S.POST_TRAN_DATE) AS LC_DATE, SUM(R.SGCM_MRGN_AMT_RCVRY_CURR) LC_MARGIN_CREDIT_AMOUNT,SG_OPEN_DATE AS OLC_ENTD_ON
                   FROM SGISS S JOIN SGCASHMAR R ON (S.SG_ENTITY_NUM = R.SGCM_ENTITY_NUM AND S.SG_BRN_CODE = R.SGCM_BRN_CODE AND S.SG_CODE = R.SGCM_SG_TYPE AND S.SG_YEAR = R.SGCM_SG_YEAR AND S.SG_SERIAL = R.SGCM_SG_SL) WHERE S.SG_ENTITY_NUM=:1 AND S.SG_BRN_CODE=:2 AND S.SG_OLC_TYPE=:3 AND S.SG_OLC_YEAR=:4 AND
                   S.SG_OLC_SL=:5 AND S.SG_AUTH_ON IS NOT NULL AND R.SGCM_AUTH_ON IS NOT NULL ';
        
          IF P_AS_ON_DATE IS NOT NULL THEN
            V_SQL_SHIP := V_SQL_SHIP || ' AND DECODE(S.POST_TRAN_DATE, NULL, TRUNC(S.SG_ENTD_ON), S.POST_TRAN_DATE) <= ' || CHR(39) || P_AS_ON_DATE ||
                          CHR(39) || ' ';
          END IF;
        
          V_SQL_SHIP := V_SQL_SHIP || ' GROUP  BY S.SG_OPEN_DATE,S.POST_TRAN_DATE,S.SG_ENTD_ON ';
          --DBMS_OUTPUT.PUT_LINE('Shipping Guarantee QUERY :   ' || V_SQL_SHIP);
          EXECUTE IMMEDIATE V_SQL_SHIP BULK COLLECT
            INTO T_FETCH_TABLE_SHIP
            USING T_FETCH_TABLE(I).OLC_ENTITY_NUM, T_FETCH_TABLE(I).OLC_BRN_CODE, T_FETCH_TABLE(I).OLC_LC_TYPE, T_FETCH_TABLE(I).OLC_LC_YEAR, T_FETCH_TABLE(I).OLC_LC_SL;
          BEGIN
            FOR S IN T_FETCH_TABLE_SHIP.FIRST .. T_FETCH_TABLE_SHIP.LAST LOOP
              SELECT MAX(SG_ENTD_ON) AS OLC_ENTD_ON
              INTO   RET_RETURN_TABLE.OLC_ENTD_ON
              FROM   SGISS S
              WHERE  S.SG_ENTITY_NUM = T_FETCH_TABLE(I).OLC_ENTITY_NUM
              AND    S.SG_BRN_CODE = T_FETCH_TABLE(I).OLC_BRN_CODE
              AND    S.SG_OLC_TYPE = T_FETCH_TABLE(I).OLC_LC_TYPE
              AND    S.SG_OLC_YEAR = T_FETCH_TABLE(I).OLC_LC_YEAR
              AND    S.SG_OLC_SL = T_FETCH_TABLE(I).OLC_LC_SL
              AND    SG_OPEN_DATE = T_FETCH_TABLE_SHIP(S).LC_DATE;
            
              RET_RETURN_TABLE.LC_ACCOUNT_NAME             := T_FETCH_TABLE(I).LC_ACCOUNT_NAME;
              RET_RETURN_TABLE.LC_ACCOUNT_NO               := T_FETCH_TABLE(I).LC_ACCOUNT_NO;
              RET_RETURN_TABLE.LC_ACCOUNT_HOLDER_ADDRESS   := T_FETCH_TABLE(I).LC_ACCOUNT_HOLDER_ADDRESS;
              RET_RETURN_TABLE.LC_LIMIT                    := T_FETCH_TABLE(I).LC_LIMIT;
              RET_RETURN_TABLE.LC_MARGIN                   := T_FETCH_TABLE(I).LC_MARGIN;
              RET_RETURN_TABLE.LC_SANCTION                 := T_FETCH_TABLE(I).LC_SANCTION;
              RET_RETURN_TABLE.LC_WROTH                    := T_FETCH_TABLE(I).LC_WROTH;
              RET_RETURN_TABLE.LC_DATE                     := T_FETCH_TABLE_SHIP(S).LC_DATE;
              RET_RETURN_TABLE.LC_NUMBER                   := T_FETCH_TABLE(I).LC_NUMBER;
              RET_RETURN_TABLE.LC_BENEFICARY_CODE          := T_FETCH_TABLE(I).LC_BENEFICARY_CODE;
              RET_RETURN_TABLE.OLC_CUST_NUM                := T_FETCH_TABLE(I).OLC_CUST_NUM;
              RET_RETURN_TABLE.OLC_BRN_CODE                := T_FETCH_TABLE(I).OLC_BRN_CODE;
              RET_RETURN_TABLE.OLC_LC_TYPE                 := T_FETCH_TABLE(I).OLC_LC_TYPE;
              RET_RETURN_TABLE.OLC_LC_YEAR                 := T_FETCH_TABLE(I).OLC_LC_YEAR;
              RET_RETURN_TABLE.OLC_LC_SL                   := T_FETCH_TABLE(I).OLC_LC_SL;
              RET_RETURN_TABLE.LC_FOREIGN_DEBIT_CURRENCY   := NULL;
              RET_RETURN_TABLE.LC_FOREIGN_DEBIT_AMOUNT     := 0;
              RET_RETURN_TABLE.LC_FOREIGN_CONTRA_DATE      := NULL;
              RET_RETURN_TABLE.LC_FOREIGN_CREDIT_CURRENCY  := NULL;
              RET_RETURN_TABLE.LC_FOREIGN_CREDIT_AMOUNT    := 0;
              RET_RETURN_TABLE.LC_LIABILITY_CONTRA_DATE    := NULL;
              RET_RETURN_TABLE.LC_LIABILITY_CREDIT_AMOUNT  := 0;
              RET_RETURN_TABLE.LC_LIABILITY_BALANCE_AMOUNT := 0;
              IF T_FETCH_TABLE_SHIP(S).LC_MARGIN_CREDIT_AMOUNT > 0 THEN
                RET_RETURN_TABLE.LC_PARTICULAR := 'Liability and Margin Held-SH';
              ELSE
                RET_RETURN_TABLE.LC_PARTICULAR := 'Liability Held-SH';
              END IF;
            
              SELECT MAX(SGCMR_RELEASE_DATE)
              INTO   RET_RETURN_TABLE.LC_MARGIN_CONTRA_DATE
              FROM   SGCASHMARREL R
              INNER  JOIN SGISS S
              ON     (R.SGCMR_ENTITY_NUM = S.SG_ENTITY_NUM AND R.SGCMR_BRN_CODE = S.SG_BRN_CODE AND R.SGCMR_TYPE = S.SG_CODE AND
                     R.SGCMR_YEAR = S.SG_YEAR AND R.SGCMR_SL = S.SG_SERIAL)
              WHERE  S.SG_ENTITY_NUM = T_FETCH_TABLE(I).OLC_ENTITY_NUM
              AND    S.SG_BRN_CODE = T_FETCH_TABLE(I).OLC_BRN_CODE
              AND    S.SG_OLC_TYPE = T_FETCH_TABLE(I).OLC_LC_TYPE
              AND    S.SG_OLC_YEAR = T_FETCH_TABLE(I).OLC_LC_YEAR
              AND    S.SG_OLC_SL = T_FETCH_TABLE(I).OLC_LC_SL
              AND    SG_AUTH_ON IS NOT NULL;
            
              SELECT SUM(SG_LIAB_AMT), AVG(SG_MARGIN_REQ)
              INTO   RET_RETURN_TABLE.LC_LIABILITY_DEBIT_AMOUNT, RET_RETURN_TABLE.LC_MARGIN_PERCENTAGE
              FROM   SGISS S
              WHERE 
              
               S.SG_ENTITY_NUM = T_FETCH_TABLE(I).OLC_ENTITY_NUM
               AND    S.SG_BRN_CODE = T_FETCH_TABLE(I).OLC_BRN_CODE
               AND    S.SG_OLC_TYPE = T_FETCH_TABLE(I).OLC_LC_TYPE
               AND    S.SG_OLC_YEAR = T_FETCH_TABLE(I).OLC_LC_YEAR
               AND    S.SG_OLC_SL = T_FETCH_TABLE(I).OLC_LC_SL
               AND    SG_AUTH_ON IS NOT NULL;
            
              RET_RETURN_TABLE.LC_MARGIN_DEBIT_AMOUNT   := 0;
              RET_RETURN_TABLE.LC_MARGIN_CREDIT_AMOUNT  := T_FETCH_TABLE_SHIP(S).LC_MARGIN_CREDIT_AMOUNT;
              RET_RETURN_TABLE.LC_MARGIN_BALANCE_AMOUNT := 0;
              RET_RETURN_TABLE.LC_REMARKS               := T_FETCH_TABLE(I).LC_REMARKS;
              PIPE ROW(RET_RETURN_TABLE);
            END LOOP;
          EXCEPTION
            WHEN VALUE_ERROR THEN
              NULL;
            WHEN NO_DATA_FOUND THEN
              NULL;
            WHEN OTHERS THEN
              NULL;
          END;
        END;
        --**************---END  SHIPPING GRUANTEE -----***********************--
      
        ---***************---START OF PAYMENT---********************************-
        BEGIN
          SELECT COUNT(*)
          INTO   COUNT_PAYMENT
          FROM   IBILL IBILL
          JOIN   IBPAY IBPAY
          ON     (IBILL.IBILL_ENTITY_NUM = IBPAY.IBPAY_ENTITY_NUM AND IBILL.IBILL_BRN_CODE = IBPAY.IBPAY_BRN_CODE AND
                 IBILL.IBILL_BILL_TYPE = IBPAY.IBPAY_BILL_TYPE AND IBILL.IBILL_BILL_YEAR = IBPAY.IBPAY_BILL_YEAR AND
                 IBILL.IBILL_BILL_SL = IBPAY.IBPAY_BILL_SL)
          WHERE  IBPAY.IBPAY_AUTH_ON IS NOT NULL
          AND    IBILL_TENOR_TYPE = 'S'
          AND    IBILL.IBILL_ENTITY_NUM = T_FETCH_TABLE(I).OLC_ENTITY_NUM
          AND    IBILL.IBILL_BRN_CODE = T_FETCH_TABLE(I).OLC_BRN_CODE
          AND    IBILL.IBILL_OLC_TYPE = T_FETCH_TABLE(I).OLC_LC_TYPE
          AND    IBILL.IBILL_OLC_YEAR = T_FETCH_TABLE(I).OLC_LC_YEAR
          AND    IBILL.IBILL_OLC_SL = T_FETCH_TABLE(I).OLC_LC_SL;
        
          IF (COUNT_PAYMENT > 0) THEN
            V_SQL_PAY := ' SELECT IBILL.IBILL_BILL_CURR  AS LC_FOREIGN_CREDIT_CURRENCY, DECODE(IBPAY.POST_TRAN_DATE,NULL,TRUNC(IBPAY.IBPAY_ENTD_ON),IBPAY.POST_TRAN_DATE) AS LC_DATE,
      SUM(IBPAY.IBPAY_PAY_AMT)  AS LC_FOREIGN_CREDIT_AMOUNT, SUM(IBPAY.IBPAY_LC_LIAB_REVERSE_AMT) AS LC_LIABILITY_CREDIT_AMOUNT,
      NULL AS OLC_ENTD_ON FROM IBILL IBILL INNER JOIN IBPAY IBPAY ON( IBILL.IBILL_ENTITY_NUM=IBPAY.IBPAY_ENTITY_NUM AND
      IBILL.IBILL_BRN_CODE=IBPAY.IBPAY_BRN_CODE AND IBILL.IBILL_BILL_TYPE=IBPAY.IBPAY_BILL_TYPE AND IBILL.IBILL_BILL_YEAR=IBPAY.IBPAY_BILL_YEAR AND
      IBILL.IBILL_BILL_SL=IBPAY.IBPAY_BILL_SL) WHERE IBPAY.IBPAY_AUTH_ON IS NOT NULL AND IBILL_TENOR_TYPE  = ''S'' AND
        IBILL.IBILL_ENTITY_NUM=:1 AND IBILL.IBILL_BRN_CODE=:2  AND IBILL.IBILL_OLC_TYPE=:3 AND IBILL.IBILL_OLC_YEAR=:4 AND
        IBILL.IBILL_OLC_SL=:5 ';
          
            IF P_AS_ON_DATE IS NOT NULL THEN
              V_SQL_PAY := V_SQL_PAY || ' AND DECODE(IBPAY.POST_TRAN_DATE, NULL, TRUNC(IBPAY.IBPAY_ENTD_ON), IBPAY.POST_TRAN_DATE) <= ' || CHR(39) ||
                           P_AS_ON_DATE || CHR(39) || ' ';
            END IF;
          
            V_SQL_PAY := V_SQL_PAY || ' GROUP BY IBILL_BILL_CURR,IBPAY.POST_TRAN_DATE,IBPAY.IBPAY_ENTD_ON ';
            --DBMS_OUTPUT.PUT_LINE('Import Bill Payment QUERY :   ' || V_SQL_PAY);
            EXECUTE IMMEDIATE V_SQL_PAY BULK COLLECT
              INTO T_FETCH_TABLE_PAY
              USING T_FETCH_TABLE(I).OLC_ENTITY_NUM, T_FETCH_TABLE(I).OLC_BRN_CODE, T_FETCH_TABLE(I).OLC_LC_TYPE, T_FETCH_TABLE(I).OLC_LC_YEAR, T_FETCH_TABLE(I).OLC_LC_SL;
            BEGIN
              FOR K IN T_FETCH_TABLE_PAY.FIRST .. T_FETCH_TABLE_PAY.LAST LOOP
              
                RET_RETURN_TABLE.LC_FOREIGN_CREDIT_CURRENCY := T_FETCH_TABLE_PAY(K).LC_FOREIGN_CREDIT_CURRENCY;
                RET_RETURN_TABLE.LC_FOREIGN_CREDIT_AMOUNT   := T_FETCH_TABLE_PAY(K).LC_FOREIGN_CREDIT_AMOUNT;
                RET_RETURN_TABLE.LC_LIABILITY_CREDIT_AMOUNT := T_FETCH_TABLE_PAY(K).LC_LIABILITY_CREDIT_AMOUNT;
                SELECT MAX(IBPAY_ENTD_ON)
                INTO   RET_RETURN_TABLE.OLC_ENTD_ON
                FROM   IBILL IBILL
                INNER  JOIN IBPAY IBPAY
                ON     (IBILL.IBILL_ENTITY_NUM = IBPAY.IBPAY_ENTITY_NUM AND IBILL.IBILL_BRN_CODE = IBPAY.IBPAY_BRN_CODE AND
                       IBILL.IBILL_BILL_TYPE = IBPAY.IBPAY_BILL_TYPE AND IBILL.IBILL_BILL_YEAR = IBPAY.IBPAY_BILL_YEAR AND
                       IBILL.IBILL_BILL_SL = IBPAY.IBPAY_BILL_SL)
                WHERE  IBPAY.IBPAY_AUTH_ON IS NOT NULL
                AND    IBILL.IBILL_ENTITY_NUM = T_FETCH_TABLE(I).OLC_ENTITY_NUM
                AND    IBILL.IBILL_BRN_CODE = T_FETCH_TABLE(I).OLC_BRN_CODE
                AND    IBILL.IBILL_OLC_TYPE = T_FETCH_TABLE(I).OLC_LC_TYPE
                AND    IBILL.IBILL_OLC_YEAR = T_FETCH_TABLE(I).OLC_LC_YEAR
                AND    IBILL.IBILL_OLC_SL = T_FETCH_TABLE(I).OLC_LC_SL;
              
                RET_RETURN_TABLE.LC_ACCOUNT_NAME           := T_FETCH_TABLE(I).LC_ACCOUNT_NAME;
                RET_RETURN_TABLE.LC_ACCOUNT_NO             := T_FETCH_TABLE(I).LC_ACCOUNT_NO;
                RET_RETURN_TABLE.LC_ACCOUNT_HOLDER_ADDRESS := T_FETCH_TABLE(I).LC_ACCOUNT_HOLDER_ADDRESS;
                RET_RETURN_TABLE.LC_LIMIT                  := T_FETCH_TABLE(I).LC_LIMIT;
                RET_RETURN_TABLE.LC_MARGIN                 := T_FETCH_TABLE(I).LC_MARGIN;
                RET_RETURN_TABLE.LC_SANCTION               := T_FETCH_TABLE(I).LC_SANCTION;
                RET_RETURN_TABLE.LC_WROTH                  := T_FETCH_TABLE(I).LC_WROTH;
              
                RET_RETURN_TABLE.OLC_LC_TYPE := T_FETCH_TABLE(I).OLC_LC_TYPE;
                RET_RETURN_TABLE.OLC_LC_YEAR := T_FETCH_TABLE(I).OLC_LC_YEAR;
                RET_RETURN_TABLE.OLC_LC_SL   := T_FETCH_TABLE(I).OLC_LC_SL;
              
                RET_RETURN_TABLE.LC_DATE := T_FETCH_TABLE_PAY(K).LC_DATE;
                -- Code To Keep Payment Or Acceptance Date
                IF (SIGHT_CNT > 0) THEN
                  SIGHT_DATES := SIGHT_DATES || ',' || CHR(39) || TO_CHAR(T_FETCH_TABLE_PAY(K).LC_DATE, 'DD-MON-YYYY') || CHR(39);
                ELSE
                  SIGHT_DATES := CHR(39) || TO_CHAR(T_FETCH_TABLE_PAY(K).LC_DATE, 'DD-MON-YYYY') || CHR(39);
                END IF;
                SIGHT_CNT := SIGHT_CNT + 1;
              
                RET_RETURN_TABLE.LC_NUMBER                   := T_FETCH_TABLE(I).LC_NUMBER;
                RET_RETURN_TABLE.LC_BENEFICARY_CODE          := T_FETCH_TABLE(I).LC_BENEFICARY_CODE;
                RET_RETURN_TABLE.LC_PARTICULAR               := 'Liability Reversed-S';
                RET_RETURN_TABLE.LC_FOREIGN_DEBIT_CURRENCY   := '';
                RET_RETURN_TABLE.LC_FOREIGN_DEBIT_AMOUNT     := 0;
                RET_RETURN_TABLE.LC_FOREIGN_CONTRA_DATE      := T_FETCH_TABLE(I).LC_DATE;
                RET_RETURN_TABLE.LC_LIABILITY_DEBIT_AMOUNT   := 0;
                RET_RETURN_TABLE.LC_LIABILITY_CONTRA_DATE    := T_FETCH_TABLE(I).LC_DATE;
                RET_RETURN_TABLE.LC_LIABILITY_BALANCE_AMOUNT := 0;
                RET_RETURN_TABLE.LC_FOREIGN_CREDIT_CURRENCY  := T_FETCH_TABLE_PAY(K).LC_FOREIGN_CREDIT_CURRENCY;
                RET_RETURN_TABLE.LC_FOREIGN_CREDIT_AMOUNT    := T_FETCH_TABLE_PAY(K).LC_FOREIGN_CREDIT_AMOUNT;
                RET_RETURN_TABLE.LC_LIABILITY_CREDIT_AMOUNT  := T_FETCH_TABLE_PAY(K).LC_LIABILITY_CREDIT_AMOUNT;
                RET_RETURN_TABLE.LC_REMARKS                  := T_FETCH_TABLE(I).LC_REMARKS;
              
                /*SELECT NVL(SUM((SELECT NVL(SUM(OLCDEPMARR_REL_AMT), 0) AMOUNT
                                 FROM   OLCDEPMARREL D
                                 WHERE  D.OLCDEPMARR_BRN_CODE = T_FETCH_TABLE(I).OLC_BRN_CODE
                                 AND    D.OLCDEPMARR_LC_TYPE = T_FETCH_TABLE(I).OLC_LC_TYPE
                                 AND    D.OLCDEPMARR_LC_YEAR = T_FETCH_TABLE(I).OLC_LC_YEAR
                                 AND    D.OLCDEPMARR_LC_SL = T_FETCH_TABLE(I).OLC_LC_SL
                                 AND    TRUNC(D.OLCDEPMARR_ENTD_ON) = T_FETCH_TABLE_PAY(K).LC_DATE
                                 AND    D.OLCDEPMARR_AUTH_ON IS NOT NULL) +
                                (SELECT NVL(SUM(OLCCMR_MRGN_AMT_PYMNT_CURR), 0) AMOUNT
                                 FROM   OLCCASHMARREL C
                                 WHERE  C.OLCCMR_BRN_CODE = T_FETCH_TABLE(I).OLC_BRN_CODE
                                 AND    C.OLCCMR_LC_TYPE = T_FETCH_TABLE(I).OLC_LC_TYPE
                                 AND    C.OLCCMR_LC_YEAR = T_FETCH_TABLE(I).OLC_LC_YEAR
                                 AND    C.OLCCMR_LC_SL = T_FETCH_TABLE(I).OLC_LC_SL
                                 AND    DECODE(C.POST_TRAN_DATE,NULL,TRUNC(C.OLCCMR_ENTD_ON),C.POST_TRAN_DATE) = T_FETCH_TABLE_PAY(K).LC_DATE
                                 AND    C.OLCCMR_AUTH_ON IS NOT NULL)),
                            0) AS LC_MARGIN_DEBIT_AMOUNT
                INTO   MARGIN_RELEADE
                FROM   DUAL;*/
              
                /*IF (MARGIN_RELEADE > 0) THEN
                  RET_RETURN_TABLE.LC_MARGIN_PERCENTAGE     := 0;
                  RET_RETURN_TABLE.LC_MARGIN_DEBIT_AMOUNT   := MARGIN_RELEADE;
                  RET_RETURN_TABLE.LC_MARGIN_CONTRA_DATE    := T_FETCH_TABLE(I).LC_DATE;
                  RET_RETURN_TABLE.LC_MARGIN_CREDIT_AMOUNT  := 0;
                  RET_RETURN_TABLE.LC_MARGIN_BALANCE_AMOUNT := 0;
                  RET_RETURN_TABLE.LC_PARTICULAR            := 'Liability and Margin Reversed-S';
                ELSE*/
                RET_RETURN_TABLE.LC_MARGIN_PERCENTAGE     := 0;
                RET_RETURN_TABLE.LC_MARGIN_DEBIT_AMOUNT   := 0;
                RET_RETURN_TABLE.LC_MARGIN_CONTRA_DATE    := NULL;
                RET_RETURN_TABLE.LC_MARGIN_CREDIT_AMOUNT  := 0;
                RET_RETURN_TABLE.LC_MARGIN_BALANCE_AMOUNT := 0;
                --END IF;
                PIPE ROW(RET_RETURN_TABLE);
              END LOOP;
            EXCEPTION
              WHEN VALUE_ERROR THEN
                NULL;
              WHEN NO_DATA_FOUND THEN
                NULL;
              WHEN OTHERS THEN
                NULL;
            END;
          ELSE
            SELECT COUNT(*)
            INTO   COUNT_PAYMENT
            FROM   IBILL IBILL
            INNER  JOIN IBILLACC AC
            ON     (IBILL.IBILL_ENTITY_NUM = AC.IBACC_ENTITY_NUM AND IBILL.IBILL_BRN_CODE = AC.IBACC_BRN_CODE AND
                   IBILL.IBILL_BILL_TYPE = AC.IBACC_BILL_TYPE AND IBILL.IBILL_BILL_YEAR = AC.IBACC_BILL_YEAR AND
                   IBILL.IBILL_BILL_SL = AC.IBACC_BILL_SL)
            WHERE  AC.IBACC_AUTH_ON IS NOT NULL
            AND    IBILL_TENOR_TYPE = 'U'
            AND    IBILL.IBILL_ENTITY_NUM = T_FETCH_TABLE(I).OLC_ENTITY_NUM
            AND    IBILL.IBILL_BRN_CODE = T_FETCH_TABLE(I).OLC_BRN_CODE
            AND    IBILL.IBILL_OLC_TYPE = T_FETCH_TABLE(I).OLC_LC_TYPE
            AND    IBILL.IBILL_OLC_YEAR = T_FETCH_TABLE(I).OLC_LC_YEAR
            AND    IBILL.IBILL_OLC_SL = T_FETCH_TABLE(I).OLC_LC_SL;
          
            IF (COUNT_PAYMENT > 0) THEN
              V_SQL_PAY := 'SELECT IBILL.IBILL_BILL_CURR  AS LC_FOREIGN_CREDIT_CURRENCY, DECODE(AC.POST_TRAN_DATE,NULL,TRUNC(AC.IBACC_ENTD_ON),AC.POST_TRAN_DATE) AS LC_DATE,
                      SUM(IBILL.IBILL_BILL_AMOUNT )  AS LC_FOREIGN_CREDIT_AMOUNT, SUM(AC.IBACC_LC_LIAB_REVERSE_AMT) AS LC_LIABILITY_CREDIT_AMOUNT,
                      NULL AS OLC_ENTD_ON FROM IBILL IBILL INNER JOIN IBILLACC AC ON( IBILL.IBILL_ENTITY_NUM=AC.IBACC_ENTITY_NUM AND
                      IBILL.IBILL_BRN_CODE=AC.IBACC_BRN_CODE AND IBILL.IBILL_BILL_TYPE=AC.IBACC_BILL_TYPE AND IBILL.IBILL_BILL_YEAR=AC.IBACC_BILL_YEAR AND
                      IBILL.IBILL_BILL_SL=AC.IBACC_BILL_SL) WHERE AC.IBACC_AUTH_ON IS NOT NULL AND IBILL_TENOR_TYPE  = ''U'' AND
                      IBILL.IBILL_ENTITY_NUM=:1 AND IBILL.IBILL_BRN_CODE=:2 AND IBILL.IBILL_OLC_TYPE=:3 AND IBILL.IBILL_OLC_YEAR=:4 AND
                      IBILL.IBILL_OLC_SL=:5  ';
            
              IF P_AS_ON_DATE IS NOT NULL THEN
                V_SQL_PAY := V_SQL_PAY || ' AND DECODE(AC.POST_TRAN_DATE, NULL, TRUNC(AC.IBACC_ENTD_ON), AC.POST_TRAN_DATE) <= ' || CHR(39) ||
                             P_AS_ON_DATE || CHR(39) || ' ';
              END IF;
            
              V_SQL_PAY := V_SQL_PAY || ' GROUP BY IBILL_BILL_CURR,AC.POST_TRAN_DATE,AC.IBACC_ENTD_ON ';
              --DBMS_OUTPUT.PUT_LINE('IBILLACC QUERY :   ' || V_SQL_PAY);
              EXECUTE IMMEDIATE V_SQL_PAY BULK COLLECT
                INTO T_FETCH_TABLE_PAY
                USING T_FETCH_TABLE(I).OLC_ENTITY_NUM, T_FETCH_TABLE(I).OLC_BRN_CODE, T_FETCH_TABLE(I).OLC_LC_TYPE, T_FETCH_TABLE(I).OLC_LC_YEAR, T_FETCH_TABLE(I).OLC_LC_SL;
              BEGIN
                FOR K IN T_FETCH_TABLE_PAY.FIRST .. T_FETCH_TABLE_PAY.LAST LOOP
                  RET_RETURN_TABLE.LC_FOREIGN_CREDIT_CURRENCY := T_FETCH_TABLE_PAY(K).LC_FOREIGN_CREDIT_CURRENCY;
                  RET_RETURN_TABLE.LC_FOREIGN_CREDIT_AMOUNT   := T_FETCH_TABLE_PAY(K).LC_FOREIGN_CREDIT_AMOUNT;
                  RET_RETURN_TABLE.LC_LIABILITY_CREDIT_AMOUNT := T_FETCH_TABLE_PAY(K).LC_LIABILITY_CREDIT_AMOUNT;
                  SELECT MAX(IBPAY_ENTD_ON)
                  INTO   RET_RETURN_TABLE.OLC_ENTD_ON
                  FROM   IBILL IBILL
                  INNER  JOIN IBPAY IBPAY
                  ON     (IBILL.IBILL_ENTITY_NUM = IBPAY.IBPAY_ENTITY_NUM AND IBILL.IBILL_BRN_CODE = IBPAY.IBPAY_BRN_CODE AND
                         IBILL.IBILL_BILL_TYPE = IBPAY.IBPAY_BILL_TYPE AND IBILL.IBILL_BILL_YEAR = IBPAY.IBPAY_BILL_YEAR AND
                         IBILL.IBILL_BILL_SL = IBPAY.IBPAY_BILL_SL)
                  WHERE  IBPAY.IBPAY_AUTH_ON IS NOT NULL
                  AND    IBILL.IBILL_ENTITY_NUM = T_FETCH_TABLE(I).OLC_ENTITY_NUM
                  AND    IBILL.IBILL_BRN_CODE = T_FETCH_TABLE(I).OLC_BRN_CODE
                  AND    IBILL.IBILL_OLC_TYPE = T_FETCH_TABLE(I).OLC_LC_TYPE
                  AND    IBILL.IBILL_OLC_YEAR = T_FETCH_TABLE(I).OLC_LC_YEAR
                  AND    IBILL.IBILL_OLC_SL = T_FETCH_TABLE(I).OLC_LC_SL;
                
                  RET_RETURN_TABLE.LC_ACCOUNT_NAME           := T_FETCH_TABLE(I).LC_ACCOUNT_NAME;
                  RET_RETURN_TABLE.LC_ACCOUNT_NO             := T_FETCH_TABLE(I).LC_ACCOUNT_NO;
                  RET_RETURN_TABLE.LC_ACCOUNT_HOLDER_ADDRESS := T_FETCH_TABLE(I).LC_ACCOUNT_HOLDER_ADDRESS;
                  RET_RETURN_TABLE.LC_LIMIT                  := T_FETCH_TABLE(I).LC_LIMIT;
                  RET_RETURN_TABLE.LC_MARGIN                 := T_FETCH_TABLE(I).LC_MARGIN;
                  RET_RETURN_TABLE.LC_SANCTION               := T_FETCH_TABLE(I).LC_SANCTION;
                  RET_RETURN_TABLE.LC_WROTH                  := T_FETCH_TABLE(I).LC_WROTH;
                
                  RET_RETURN_TABLE.OLC_LC_TYPE := T_FETCH_TABLE(I).OLC_LC_TYPE;
                  RET_RETURN_TABLE.OLC_LC_YEAR := T_FETCH_TABLE(I).OLC_LC_YEAR;
                  RET_RETURN_TABLE.OLC_LC_SL   := T_FETCH_TABLE(I).OLC_LC_SL;
                  RET_RETURN_TABLE.LC_DATE     := T_FETCH_TABLE_PAY(K).LC_DATE;
                
                  -- Code To Keep Payment Or Acceptance Date
                  IF (USANCE_CNT > 0) THEN
                    USANCE_DATES := USANCE_DATES || ',' || CHR(39) || TO_CHAR(T_FETCH_TABLE_PAY(K).LC_DATE, 'DD-MON-YYYY') || CHR(39);
                  ELSE
                    USANCE_DATES := CHR(39) || TO_CHAR(T_FETCH_TABLE_PAY(K).LC_DATE, 'DD-MON-YYYY') || CHR(39);
                  END IF;
                  USANCE_CNT := USANCE_CNT + 1;
                
                  RET_RETURN_TABLE.LC_NUMBER                   := T_FETCH_TABLE(I).LC_NUMBER;
                  RET_RETURN_TABLE.LC_BENEFICARY_CODE          := T_FETCH_TABLE(I).LC_BENEFICARY_CODE;
                  RET_RETURN_TABLE.LC_PARTICULAR               := 'Liability Reversed-U';
                  RET_RETURN_TABLE.LC_FOREIGN_DEBIT_CURRENCY   := '';
                  RET_RETURN_TABLE.LC_FOREIGN_DEBIT_AMOUNT     := 0;
                  RET_RETURN_TABLE.LC_FOREIGN_CONTRA_DATE      := T_FETCH_TABLE(I).LC_DATE;
                  RET_RETURN_TABLE.LC_LIABILITY_DEBIT_AMOUNT   := 0;
                  RET_RETURN_TABLE.LC_LIABILITY_CONTRA_DATE    := T_FETCH_TABLE(I).LC_DATE;
                  RET_RETURN_TABLE.LC_LIABILITY_BALANCE_AMOUNT := 0;
                  RET_RETURN_TABLE.LC_FOREIGN_CREDIT_CURRENCY  := T_FETCH_TABLE_PAY(K).LC_FOREIGN_CREDIT_CURRENCY;
                  RET_RETURN_TABLE.LC_FOREIGN_CREDIT_AMOUNT    := T_FETCH_TABLE_PAY(K).LC_FOREIGN_CREDIT_AMOUNT;
                  RET_RETURN_TABLE.LC_LIABILITY_CREDIT_AMOUNT  := T_FETCH_TABLE_PAY(K).LC_LIABILITY_CREDIT_AMOUNT;
                  RET_RETURN_TABLE.LC_REMARKS                  := T_FETCH_TABLE(I).LC_REMARKS;
                  /*SELECT NVL(SUM((SELECT NVL(SUM(OLCDEPMARR_REL_AMT), 0) AMOUNT
                                   FROM   OLCDEPMARREL D
                                   WHERE  D.OLCDEPMARR_BRN_CODE = T_FETCH_TABLE(I).OLC_BRN_CODE
                                   AND    D.OLCDEPMARR_LC_TYPE = T_FETCH_TABLE(I).OLC_LC_TYPE
                                   AND    D.OLCDEPMARR_LC_YEAR = T_FETCH_TABLE(I).OLC_LC_YEAR
                                   AND    D.OLCDEPMARR_LC_SL = T_FETCH_TABLE(I).OLC_LC_SL
                                   AND    TRUNC(D.OLCDEPMARR_ENTD_ON) = T_FETCH_TABLE_PAY(K).LC_DATE
                                   AND    D.OLCDEPMARR_AUTH_ON IS NOT NULL) +
                                  (SELECT NVL(SUM(OLCCMR_MRGN_AMT_PYMNT_CURR), 0) AMOUNT
                                   FROM   OLCCASHMARREL C
                                   WHERE  C.OLCCMR_BRN_CODE = T_FETCH_TABLE(I).OLC_BRN_CODE
                                   AND    C.OLCCMR_LC_TYPE = T_FETCH_TABLE(I).OLC_LC_TYPE
                                   AND    C.OLCCMR_LC_YEAR = T_FETCH_TABLE(I).OLC_LC_YEAR
                                   AND    C.OLCCMR_LC_SL = T_FETCH_TABLE(I).OLC_LC_SL
                                   AND    DECODE(C.POST_TRAN_DATE,NULL,TRUNC(C.OLCCMR_ENTD_ON),C.POST_TRAN_DATE) = T_FETCH_TABLE_PAY(K).LC_DATE
                                   AND    C.OLCCMR_AUTH_ON IS NOT NULL)),
                              0) AS LC_MARGIN_DEBIT_AMOUNT
                  INTO   MARGIN_RELEADE
                  FROM   DUAL;*/
                
                  /*IF (MARGIN_RELEADE > 0) THEN
                    RET_RETURN_TABLE.LC_MARGIN_PERCENTAGE     := 0;
                    RET_RETURN_TABLE.LC_MARGIN_DEBIT_AMOUNT   := MARGIN_RELEADE;
                    RET_RETURN_TABLE.LC_MARGIN_CONTRA_DATE    := T_FETCH_TABLE(I).LC_DATE;
                    RET_RETURN_TABLE.LC_MARGIN_CREDIT_AMOUNT  := 0;
                    RET_RETURN_TABLE.LC_MARGIN_BALANCE_AMOUNT := 0;
                    RET_RETURN_TABLE.LC_PARTICULAR            := 'Liability and Margin Reversed-U';
                  ELSE*/
                  RET_RETURN_TABLE.LC_MARGIN_PERCENTAGE     := 0;
                  RET_RETURN_TABLE.LC_MARGIN_DEBIT_AMOUNT   := 0;
                  RET_RETURN_TABLE.LC_MARGIN_CONTRA_DATE    := NULL;
                  RET_RETURN_TABLE.LC_MARGIN_CREDIT_AMOUNT  := 0;
                  RET_RETURN_TABLE.LC_MARGIN_BALANCE_AMOUNT := 0;
                  --END IF;
                  PIPE ROW(RET_RETURN_TABLE);
                END LOOP;
              EXCEPTION
                WHEN VALUE_ERROR THEN
                  NULL;
                WHEN NO_DATA_FOUND THEN
                  NULL;
                WHEN OTHERS THEN
                  NULL;
              END;
            END IF;
          END IF;
        END;
        ---***************---END OF PAYMENT---********************************-
      
        ---START FOR MARGIN RELEASE
        BEGIN
        
          V_SQL_REL := 'SELECT LC_DATE, NVL(SUM(LC_MARGIN_CREDIT_AMOUNT), 0) LC_MARGIN_CREDIT_AMOUNT,
                     LC_DATE AS OLC_ENTD_ON FROM (SELECT TRUNC(ODMR.OLCDEPMARR_ENTD_ON) AS LC_DATE,
                     NVL(SUM(OLCDEPMARR_REL_AMT), 0) AS LC_MARGIN_CREDIT_AMOUNT  FROM OLCDEPMARREL ODMR
                     WHERE OLCDEPMARR_ENTITY_NUM =:1 AND OLCDEPMARR_BRN_CODE = :2 AND OLCDEPMARR_LC_TYPE = :3 AND OLCDEPMARR_LC_YEAR = :4 AND OLCDEPMARR_LC_SL = :5 ';
        
          /*IF (TRIM(SIGHT_DATES) IS NOT NULL) THEN
            V_SQL_REL := V_SQL_REL || ' AND OLCDEPMARR_DATE_OF_ENTRY NOT IN (' || SIGHT_DATES || ') ';
          END IF;
          IF (TRIM(USANCE_DATES) IS NOT NULL) THEN
            V_SQL_REL := V_SQL_REL || ' AND OLCDEPMARR_DATE_OF_ENTRY NOT IN (' || USANCE_DATES || ') ';
          END IF;*/
        
          IF P_AS_ON_DATE IS NOT NULL THEN
            V_SQL_REL := V_SQL_REL || ' AND TRUNC(ODMR.OLCDEPMARR_ENTD_ON) <= ' || CHR(39) || P_AS_ON_DATE || CHR(39) || ' ';
          END IF;
        
          V_SQL_REL := V_SQL_REL ||
                       ' AND OLCDEPMARR_AUTH_ON IS NOT NULL GROUP BY ODMR.OLCDEPMARR_ENTD_ON
                    UNION ALL
                    SELECT DECODE(OCMR.POST_TRAN_DATE,NULL,TRUNC(OCMR.OLCCMR_ENTD_ON),OCMR.POST_TRAN_DATE) AS LC_DATE, NVL(SUM(OLCCMR_MRGN_AMT_PYMNT_CURR), 0) AS LC_MARGIN_CREDIT_AMOUNT FROM OLCCASHMARREL OCMR
                     WHERE OLCCMR_ENTITY_NUM =:9 AND OLCCMR_BRN_CODE = :10 AND OLCCMR_LC_TYPE = :11 AND OLCCMR_LC_YEAR = :12 AND OLCCMR_LC_SL = :13 ';
        
          /*IF (TRIM(SIGHT_DATES) IS NOT NULL) THEN
            V_SQL_REL := V_SQL_REL || ' AND OLCCMR_RELEASE_DATE NOT IN  (' || SIGHT_DATES || ') ';
          END IF;
          IF (TRIM(USANCE_DATES) IS NOT NULL) THEN
            V_SQL_REL := V_SQL_REL || ' AND OLCCMR_RELEASE_DATE NOT IN  (' || USANCE_DATES || ') ';
          END IF;*/
          IF P_AS_ON_DATE IS NOT NULL THEN
            V_SQL_REL := V_SQL_REL || ' AND DECODE(OCMR.POST_TRAN_DATE, NULL, TRUNC(OCMR.OLCCMR_ENTD_ON), OCMR.POST_TRAN_DATE) <= ' || CHR(39) ||
                         P_AS_ON_DATE || CHR(39) || ' ';
          END IF;
        
          V_SQL_REL := V_SQL_REL || ' AND OLCCMR_AUTH_ON IS NOT NULL GROUP BY OCMR.POST_TRAN_DATE,OCMR.OLCCMR_ENTD_ON) GROUP BY LC_DATE ';
          --DBMS_OUTPUT.PUT_LINE('Margin Release QUERY :   ' || V_SQL_REL);
          EXECUTE IMMEDIATE V_SQL_REL BULK COLLECT
            INTO T_FETCH_TABLE_REL
            USING P_ENTITYNUMBER, T_FETCH_TABLE(I).OLC_BRN_CODE, T_FETCH_TABLE(I).OLC_LC_TYPE, T_FETCH_TABLE(I).OLC_LC_YEAR, T_FETCH_TABLE(I).OLC_LC_SL, P_ENTITYNUMBER, T_FETCH_TABLE(I).OLC_BRN_CODE, T_FETCH_TABLE(I).OLC_LC_TYPE, T_FETCH_TABLE(I).OLC_LC_YEAR, T_FETCH_TABLE(I).OLC_LC_SL;
          BEGIN
            FOR L IN T_FETCH_TABLE_REL.FIRST .. T_FETCH_TABLE_REL.LAST LOOP
              SELECT MAX(OLC_ENTD_ON)
              INTO   RET_RETURN_TABLE.OLC_ENTD_ON
              FROM   ((SELECT MAX(OLCCMR_ENTD_ON) AS OLC_ENTD_ON
                        FROM   OLCCASHMARREL
                        WHERE  OLCCMR_BRN_CODE = T_FETCH_TABLE(I).OLC_BRN_CODE
                        AND    OLCCMR_LC_TYPE = T_FETCH_TABLE(I).OLC_LC_TYPE
                        AND    OLCCMR_LC_YEAR = T_FETCH_TABLE(I).OLC_LC_YEAR
                        AND    OLCCMR_LC_SL = T_FETCH_TABLE(I).OLC_LC_SL
                        AND    OLCCMR_AUTH_ON IS NOT NULL) UNION ALL
                       (SELECT MAX(OLCDEPMARR_DATE_OF_ENTRY) AS OLC_ENTD_ON
                        FROM   OLCDEPMARREL
                        WHERE  OLCDEPMARR_BRN_CODE = T_FETCH_TABLE(I).OLC_BRN_CODE
                        AND    OLCDEPMARR_LC_TYPE = T_FETCH_TABLE(I).OLC_LC_TYPE
                        AND    OLCDEPMARR_LC_YEAR = T_FETCH_TABLE(I).OLC_LC_YEAR
                        AND    OLCDEPMARR_LC_SL = T_FETCH_TABLE(I).OLC_LC_SL));
            
              RET_RETURN_TABLE.LC_ACCOUNT_NAME             := T_FETCH_TABLE(I).LC_ACCOUNT_NAME;
              RET_RETURN_TABLE.LC_ACCOUNT_NO               := T_FETCH_TABLE(I).LC_ACCOUNT_NO;
              RET_RETURN_TABLE.LC_ACCOUNT_HOLDER_ADDRESS   := T_FETCH_TABLE(I).LC_ACCOUNT_HOLDER_ADDRESS;
              RET_RETURN_TABLE.LC_LIMIT                    := T_FETCH_TABLE(I).LC_LIMIT;
              RET_RETURN_TABLE.LC_MARGIN                   := T_FETCH_TABLE(I).LC_MARGIN;
              RET_RETURN_TABLE.LC_SANCTION                 := T_FETCH_TABLE(I).LC_SANCTION;
              RET_RETURN_TABLE.LC_WROTH                    := T_FETCH_TABLE(I).LC_WROTH;
              RET_RETURN_TABLE.OLC_LC_TYPE                 := T_FETCH_TABLE(I).OLC_LC_TYPE;
              RET_RETURN_TABLE.OLC_LC_YEAR                 := T_FETCH_TABLE(I).OLC_LC_YEAR;
              RET_RETURN_TABLE.OLC_LC_SL                   := T_FETCH_TABLE(I).OLC_LC_SL;
              RET_RETURN_TABLE.LC_DATE                     := T_FETCH_TABLE_REL(L).LC_DATE;
              RET_RETURN_TABLE.LC_NUMBER                   := T_FETCH_TABLE(I).LC_NUMBER;
              RET_RETURN_TABLE.LC_BENEFICARY_CODE          := T_FETCH_TABLE(I).LC_BENEFICARY_CODE;
              RET_RETURN_TABLE.LC_FOREIGN_DEBIT_CURRENCY   := '';
              RET_RETURN_TABLE.LC_FOREIGN_DEBIT_AMOUNT     := 0;
              RET_RETURN_TABLE.LC_FOREIGN_CONTRA_DATE      := NULL;
              RET_RETURN_TABLE.LC_FOREIGN_CREDIT_CURRENCY  := '';
              RET_RETURN_TABLE.LC_FOREIGN_CREDIT_AMOUNT    := '';
              RET_RETURN_TABLE.LC_LIABILITY_DEBIT_AMOUNT   := 0;
              RET_RETURN_TABLE.LC_LIABILITY_CONTRA_DATE    := NULL;
              RET_RETURN_TABLE.LC_LIABILITY_CREDIT_AMOUNT  := 0;
              RET_RETURN_TABLE.LC_LIABILITY_BALANCE_AMOUNT := 0;
              RET_RETURN_TABLE.LC_MARGIN_PERCENTAGE        := T_FETCH_TABLE(I).LC_MARGIN_PERCENTAGE;
              RET_RETURN_TABLE.LC_MARGIN_DEBIT_AMOUNT      := T_FETCH_TABLE_REL(L).LC_MARGIN_DEBIT_AMOUNT;
              RET_RETURN_TABLE.LC_MARGIN_CONTRA_DATE       := T_FETCH_TABLE(I).LC_DATE;
              RET_RETURN_TABLE.LC_MARGIN_CREDIT_AMOUNT     := 0;
              RET_RETURN_TABLE.LC_MARGIN_BALANCE_AMOUNT    := 0;
              RET_RETURN_TABLE.LC_PARTICULAR               := 'Margin Reversed';
              RET_RETURN_TABLE.LC_REMARKS                  := T_FETCH_TABLE(I).LC_REMARKS;
              PIPE ROW(RET_RETURN_TABLE);
            END LOOP;
          EXCEPTION
            WHEN VALUE_ERROR THEN
              NULL;
            WHEN NO_DATA_FOUND THEN
              NULL;
            WHEN OTHERS THEN
              NULL;
          END;
        EXCEPTION
          WHEN VALUE_ERROR THEN
            NULL;
          WHEN NO_DATA_FOUND THEN
            NULL;
          WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error In Margin Release Block : ' || SQLERRM);
        END;
        --END FOR MARGIN RELEASE
      
        ---START FOR SHIPPING GUARANTEE MARGIN RELEASE
        BEGIN
          V_SQL_REL := 'SELECT MAX(DECODE(R.POST_TRAN_DATE, NULL, TRUNC(R.SGCMR_ENTD_ON), R.POST_TRAN_DATE)) LC_DATE,NVL(SUM(SGCMR_MRGN_AMT_RELEASED),0) LC_MARGIN_DEBIT_AMOUNT,NULL  AS OLC_ENTD_ON FROM SGCASHMARREL R
                  INNER JOIN SGISS S ON(R.SGCMR_ENTITY_NUM=S.SG_ENTITY_NUM AND R.SGCMR_BRN_CODE=S.SG_BRN_CODE AND
                  R.SGCMR_TYPE=S.SG_CODE AND R.SGCMR_YEAR=S.SG_YEAR AND R.SGCMR_SL=S.SG_SERIAL) WHERE
                  S.SG_BRN_CODE=:1 AND S.SG_OLC_TYPE=:2  AND S.SG_OLC_YEAR=:3 AND S.SG_OLC_SL=:4  AND S.SG_AUTH_ON IS NOT NULL AND R.SGCMR_AUTH_ON IS NOT NULL ';
        
          IF P_AS_ON_DATE IS NOT NULL THEN
            V_SQL_REL := V_SQL_REL || ' AND DECODE(R.POST_TRAN_DATE, NULL, TRUNC(R.SGCMR_ENTD_ON), R.POST_TRAN_DATE) <= ' || CHR(39) || P_AS_ON_DATE ||
                         CHR(39) || ' ';
          END IF;
          --DBMS_OUTPUT.PUT_LINE('SG Margin Release QUERY :   ' || V_SQL_REL);
          EXECUTE IMMEDIATE V_SQL_REL BULK COLLECT
            INTO T_FETCH_TABLE_REL
            USING T_FETCH_TABLE(I).OLC_BRN_CODE, T_FETCH_TABLE(I).OLC_LC_TYPE, T_FETCH_TABLE(I).OLC_LC_YEAR, T_FETCH_TABLE(I).OLC_LC_SL;
          BEGIN
            FOR L IN T_FETCH_TABLE_REL.FIRST .. T_FETCH_TABLE_REL.LAST LOOP
              IF T_FETCH_TABLE_REL(L).LC_MARGIN_DEBIT_AMOUNT > 0 THEN
                RET_RETURN_TABLE.LC_ACCOUNT_NAME             := T_FETCH_TABLE(I).LC_ACCOUNT_NAME;
                RET_RETURN_TABLE.LC_ACCOUNT_NO               := T_FETCH_TABLE(I).LC_ACCOUNT_NO;
                RET_RETURN_TABLE.LC_ACCOUNT_HOLDER_ADDRESS   := T_FETCH_TABLE(I).LC_ACCOUNT_HOLDER_ADDRESS;
                RET_RETURN_TABLE.LC_LIMIT                    := T_FETCH_TABLE(I).LC_LIMIT;
                RET_RETURN_TABLE.LC_MARGIN                   := T_FETCH_TABLE(I).LC_MARGIN;
                RET_RETURN_TABLE.LC_SANCTION                 := T_FETCH_TABLE(I).LC_SANCTION;
                RET_RETURN_TABLE.LC_WROTH                    := T_FETCH_TABLE(I).LC_WROTH;
                RET_RETURN_TABLE.OLC_LC_TYPE                 := T_FETCH_TABLE(I).OLC_LC_TYPE;
                RET_RETURN_TABLE.OLC_LC_YEAR                 := T_FETCH_TABLE(I).OLC_LC_YEAR;
                RET_RETURN_TABLE.OLC_LC_SL                   := T_FETCH_TABLE(I).OLC_LC_SL;
                RET_RETURN_TABLE.LC_DATE                     := T_FETCH_TABLE_REL(L).LC_DATE;
                RET_RETURN_TABLE.LC_NUMBER                   := T_FETCH_TABLE(I).LC_NUMBER;
                RET_RETURN_TABLE.LC_BENEFICARY_CODE          := T_FETCH_TABLE(I).LC_BENEFICARY_CODE;
                RET_RETURN_TABLE.LC_FOREIGN_DEBIT_CURRENCY   := '';
                RET_RETURN_TABLE.LC_FOREIGN_DEBIT_AMOUNT     := 0;
                RET_RETURN_TABLE.LC_FOREIGN_CONTRA_DATE      := NULL;
                RET_RETURN_TABLE.LC_FOREIGN_CREDIT_CURRENCY  := '';
                RET_RETURN_TABLE.LC_FOREIGN_CREDIT_AMOUNT    := '';
                RET_RETURN_TABLE.LC_LIABILITY_DEBIT_AMOUNT   := 0;
                RET_RETURN_TABLE.LC_LIABILITY_CONTRA_DATE    := NULL;
                RET_RETURN_TABLE.LC_LIABILITY_CREDIT_AMOUNT  := 0;
                RET_RETURN_TABLE.LC_LIABILITY_BALANCE_AMOUNT := 0;
              
                SELECT AVG(NVL(SG_MARGIN_REQ, 0))
                INTO   RET_RETURN_TABLE.LC_MARGIN_PERCENTAGE
                FROM   SGISS S
                WHERE  S.SG_BRN_CODE = T_FETCH_TABLE(I).OLC_BRN_CODE
                AND    S.SG_OLC_TYPE = T_FETCH_TABLE(I).OLC_LC_TYPE
                AND    S.SG_OLC_YEAR = T_FETCH_TABLE(I).OLC_LC_YEAR
                AND    S.SG_OLC_SL = T_FETCH_TABLE(I).OLC_LC_SL;
              
                SELECT MAX(SG_ENTD_ON)
                INTO   RET_RETURN_TABLE.OLC_ENTD_ON
                FROM   SGISS S
                WHERE  S.SG_BRN_CODE = T_FETCH_TABLE(I).OLC_BRN_CODE
                AND    S.SG_OLC_TYPE = T_FETCH_TABLE(I).OLC_LC_TYPE
                AND    S.SG_OLC_YEAR = T_FETCH_TABLE(I).OLC_LC_YEAR
                AND    S.SG_OLC_SL = T_FETCH_TABLE(I).OLC_LC_SL;
              
                RET_RETURN_TABLE.LC_MARGIN_DEBIT_AMOUNT   := T_FETCH_TABLE_REL(L).LC_MARGIN_DEBIT_AMOUNT;
                RET_RETURN_TABLE.LC_MARGIN_CONTRA_DATE    := T_FETCH_TABLE(I).LC_DATE;
                RET_RETURN_TABLE.LC_MARGIN_CREDIT_AMOUNT  := 0;
                RET_RETURN_TABLE.LC_MARGIN_BALANCE_AMOUNT := 0;
                RET_RETURN_TABLE.LC_PARTICULAR            := 'Margin Reversed-SH';
                RET_RETURN_TABLE.LC_REMARKS               := T_FETCH_TABLE(I).LC_REMARKS;
                PIPE ROW(RET_RETURN_TABLE);
              END IF;
            END LOOP;
          EXCEPTION
            WHEN VALUE_ERROR THEN
              NULL;
            WHEN NO_DATA_FOUND THEN
              NULL;
            WHEN OTHERS THEN
              NULL;
          END;
        END;
        --END FOR MARGIN RELEASE SHIPPINT GRANTEE
      
      END LOOP;
      -----****END LC LOOP-----*******---------------
    EXCEPTION
      WHEN VALUE_ERROR THEN
        NULL;
      WHEN NO_DATA_FOUND THEN
        NULL;
      WHEN OTHERS THEN
        V_ERRM := 'Error In LC Main Block : ' || SQLERRM;
    END;
    --------******--------END  FOR OLC---------****************-------
  
    ----****************-------START FOR  CANCELATION-----***************************
    BEGIN
      V_SQL_STAT_CAN := 'SELECT OLC_ENTITY_NUM, OLC_BRN_CODE, OLC_LC_TYPE, OLC_LC_YEAR, OLC_LC_SL, OLC_CUST_NUM, CLIENTS_NAME AS LC_ACCOUNT_NAME,
         FACNO(1,OLC_CUST_LIAB_ACC) AS LC_ACCOUNT_NO, CLIENTS_ADDR1 AS LC_ACCOUNT_HOLDER_ADDRESS, OLC_TOT_LIAB_LIM_CURR AS LC_LIMIT,
         OLC_PERC_OF_INS_VALUE_CVRD AS  LC_MARGIN, '' '' LC_SANCTION, '' '' LC_WROTH, DECODE(C.POST_TRAN_DATE, NULL, TRUNC(C.OLCCN_ENTD_ON), C.POST_TRAN_DATE) AS LC_DATE, NVL (OLC_CORR_REF_NUM, '' '') AS LC_NUMBER,
         NVL (OLC_BENEF_CODE, '' '') AS LC_BENEFICARY_CODE, '' '' AS LC_PARTICULAR, '' '' AS LC_FOREIGN_DEBIT_CURRENCY,
         0 AS LC_FOREIGN_DEBIT_AMOUNT, OLC_LC_DATE AS LC_FOREIGN_CONTRA_DATE, OLC_LC_CURR_CODE AS LC_FOREIGN_CREDIT_CURRENCY,
         OLCCN_TOT_LIAB_REV_LC_CURR AS LC_FOREIGN_CREDIT_AMOUNT, 0  AS LC_LIABILITY_DEBIT_AMOUNT, OLC_LC_DATE AS LC_LIABILITY_CONTRA_DATE,
         OLCCN_TOT_LIAB_REV_BASE_CURR AS LC_LIABILITY_CREDIT_AMOUNT, 0 AS LC_LIABILITY_BALANCE_AMOUNT, 0  AS LC_MARGIN_PERCENTAGE,
         0 AS LC_MARGIN_DEBIT_AMOUNT, NULL AS LC_MARGIN_CONTRA_DATE, 0  AS LC_MARGIN_CREDIT_AMOUNT, 0 AS LC_MARGIN_BALANCE_AMOUNT,
         '' '' AS LC_REMARKS, OLCCN_ENTD_ON AS OLC_ENTD_ON FROM OLCCAN C
         INNER JOIN OLC O
         ON(C.OLCCN_ENTITY_NUM=O.OLC_ENTITY_NUM AND C.OLCCN_BRN_CODE=O.OLC_BRN_CODE AND C.OLCCN_LC_TYPE=O.OLC_LC_TYPE AND
         C.OLCCN_LC_YEAR=O.OLC_LC_YEAR AND C.OLCCN_LC_SL=O.OLC_LC_SL )
         JOIN CLIENTS CL ON (O.OLC_CUST_NUM=CL.CLIENTS_CODE)
         JOIN OLCTENORS OT ON (O.OLC_ENTITY_NUM = OT.OLCT_ENTITY_NUM AND O.OLC_BRN_CODE = OT.OLCT_BRN_CODE AND O.OLC_LC_TYPE=OT.OLCT_LC_TYPE AND
         O.OLC_LC_YEAR=OT.OLCT_LC_YEAR AND O.OLC_LC_SL=OT.OLCT_LC_SL)
         WHERE OLC_AUTH_ON IS NOT NULL AND OLCCN_AUTH_ON IS NOT NULL AND OLC_BRN_CODE=:1 ';
    
      IF TO_CHAR(P_TENOR_TYPE) IS NOT NULL THEN
        V_SQL_STAT_CAN := V_SQL_STAT_CAN || ' AND OLCT_TENOR_TYPE = ' || CHR(39) || P_TENOR_TYPE || CHR(39);
      END IF;
    
      IF P_CLIENT IS NOT NULL THEN
        V_SQL_STAT_CAN := V_SQL_STAT_CAN || ' AND CLIENTS_CODE =' || P_CLIENT;
      END IF;
    
      IF P_ACCOUNTNUMBER IS NOT NULL THEN
        V_SQL_STAT_CAN := V_SQL_STAT_CAN || ' AND FACNO(1,OLC_CUST_LIAB_ACC) =' || P_ACCOUNTNUMBER;
      END IF;
    
      IF P_AS_ON_DATE IS NOT NULL THEN
        V_SQL_STAT_CAN := V_SQL_STAT_CAN || ' AND DECODE(C.POST_TRAN_DATE, NULL, TRUNC(C.OLCCN_ENTD_ON), C.POST_TRAN_DATE) <= ' || CHR(39) ||
                          P_AS_ON_DATE || CHR(39) || ' ';
      END IF;
    
      IF P_LC_REF_NO IS NOT NULL THEN
        V_SQL_STAT_CAN := V_SQL_STAT_CAN || ' AND OLC_CORR_REF_NUM = ' || CHR(39) || P_LC_REF_NO || CHR(39) || ' ';
      END IF;
    
      IF P_LC_TYPE IS NOT NULL THEN
        V_SQL_STAT_CAN := V_SQL_STAT_CAN || ' AND OLCCN_LC_TYPE = ' || CHR(39) || P_LC_TYPE || CHR(39) || ' ';
      END IF;
    
      IF P_LC_YEAR IS NOT NULL THEN
        V_SQL_STAT_CAN := V_SQL_STAT_CAN || ' AND OLCCN_LC_YEAR = ' || P_LC_YEAR || ' ';
      END IF;
    
      IF P_LC_SL IS NOT NULL THEN
        V_SQL_STAT_CAN := V_SQL_STAT_CAN || ' AND OLCCN_LC_SL = ' || P_LC_SL || ' ';
      END IF;
    
      --DBMS_OUTPUT.PUT_LINE('OLCCAN QUERY :   ' || V_SQL_STAT_CAN);
      EXECUTE IMMEDIATE V_SQL_STAT_CAN BULK COLLECT
        INTO T_FETCH_TABLE_CAN
        USING P_BRANCH_CODE;
      BEGIN
        FOR Q IN T_FETCH_TABLE_CAN.FIRST .. T_FETCH_TABLE_CAN.LAST LOOP
          RET_RETURN_TABLE.OLC_ENTD_ON               := T_FETCH_TABLE_CAN(Q).OLC_ENTD_ON;
          RET_RETURN_TABLE.LC_ACCOUNT_NAME           := T_FETCH_TABLE_CAN(Q).LC_ACCOUNT_NAME;
          RET_RETURN_TABLE.LC_ACCOUNT_NO             := T_FETCH_TABLE_CAN(Q).LC_ACCOUNT_NO;
          RET_RETURN_TABLE.LC_ACCOUNT_HOLDER_ADDRESS := T_FETCH_TABLE_CAN(Q).LC_ACCOUNT_HOLDER_ADDRESS;
          RET_RETURN_TABLE.LC_LIMIT                  := T_FETCH_TABLE_CAN(Q).LC_LIMIT;
          RET_RETURN_TABLE.LC_MARGIN                 := T_FETCH_TABLE_CAN(Q).LC_MARGIN;
          RET_RETURN_TABLE.LC_SANCTION               := T_FETCH_TABLE_CAN(Q).LC_SANCTION;
          RET_RETURN_TABLE.LC_WROTH                  := T_FETCH_TABLE_CAN(Q).LC_WROTH;
          RET_RETURN_TABLE.LC_DATE                   := T_FETCH_TABLE_CAN(Q).LC_DATE;
          RET_RETURN_TABLE.LC_NUMBER                 := T_FETCH_TABLE_CAN(Q).LC_NUMBER;
          RET_RETURN_TABLE.LC_BENEFICARY_CODE        := T_FETCH_TABLE_CAN(Q).LC_BENEFICARY_CODE;
          RET_RETURN_TABLE.OLC_CUST_NUM              := T_FETCH_TABLE_CAN(Q).OLC_CUST_NUM;
          RET_RETURN_TABLE.OLC_BRN_CODE              := T_FETCH_TABLE_CAN(Q).OLC_BRN_CODE;
          RET_RETURN_TABLE.OLC_LC_TYPE               := T_FETCH_TABLE_CAN(Q).OLC_LC_TYPE;
          RET_RETURN_TABLE.OLC_LC_YEAR               := T_FETCH_TABLE_CAN(Q).OLC_LC_YEAR;
          RET_RETURN_TABLE.OLC_LC_SL                 := T_FETCH_TABLE_CAN(Q).OLC_LC_SL;
          RET_RETURN_TABLE.LC_FOREIGN_DEBIT_CURRENCY := T_FETCH_TABLE_CAN(Q).LC_FOREIGN_DEBIT_CURRENCY;
          RET_RETURN_TABLE.LC_FOREIGN_DEBIT_AMOUNT   := T_FETCH_TABLE_CAN(Q).LC_FOREIGN_DEBIT_AMOUNT;
        
          SELECT OLC_LC_DATE
          INTO   RET_RETURN_TABLE.LC_FOREIGN_CONTRA_DATE
          FROM   OLC
          WHERE  OLC_BRN_CODE = T_FETCH_TABLE_CAN(Q).OLC_BRN_CODE
          AND    OLC_LC_TYPE = T_FETCH_TABLE_CAN(Q).OLC_LC_TYPE
          AND    OLC_LC_YEAR = T_FETCH_TABLE_CAN(Q).OLC_LC_YEAR
          AND    OLC_LC_SL = T_FETCH_TABLE_CAN(Q).OLC_LC_SL;
        
          RET_RETURN_TABLE.LC_LIABILITY_CONTRA_DATE    := RET_RETURN_TABLE.LC_FOREIGN_CONTRA_DATE;
          RET_RETURN_TABLE.LC_FOREIGN_CREDIT_CURRENCY  := T_FETCH_TABLE_CAN(Q).LC_FOREIGN_CREDIT_CURRENCY;
          RET_RETURN_TABLE.LC_FOREIGN_CREDIT_AMOUNT    := T_FETCH_TABLE_CAN(Q).LC_FOREIGN_CREDIT_AMOUNT;
          RET_RETURN_TABLE.LC_LIABILITY_DEBIT_AMOUNT   := T_FETCH_TABLE_CAN(Q).LC_LIABILITY_DEBIT_AMOUNT;
          RET_RETURN_TABLE.LC_LIABILITY_CREDIT_AMOUNT  := T_FETCH_TABLE_CAN(Q).LC_LIABILITY_CREDIT_AMOUNT;
          RET_RETURN_TABLE.LC_LIABILITY_BALANCE_AMOUNT := T_FETCH_TABLE_CAN(Q).LC_LIABILITY_BALANCE_AMOUNT;
          RET_RETURN_TABLE.LC_PARTICULAR               := 'Liability Reversed -C';
          RET_RETURN_TABLE.LC_MARGIN_PERCENTAGE        := 0;
          RET_RETURN_TABLE.LC_MARGIN_DEBIT_AMOUNT      := 0;
          RET_RETURN_TABLE.LC_MARGIN_CONTRA_DATE       := NULL;
          RET_RETURN_TABLE.LC_MARGIN_CREDIT_AMOUNT     := 0;
          RET_RETURN_TABLE.LC_MARGIN_BALANCE_AMOUNT    := 0;
          RET_RETURN_TABLE.LC_REMARKS                  := T_FETCH_TABLE_CAN(Q).LC_REMARKS;
        
          PIPE ROW(RET_RETURN_TABLE);
        END LOOP;
      EXCEPTION
        WHEN VALUE_ERROR THEN
          NULL;
        WHEN NO_DATA_FOUND THEN
          NULL;
        WHEN OTHERS THEN
          V_ERRM := 'Error In LC Cancellation Block : ' || SQLERRM;
      END;
    END;
    ----****************-------END FOR  CANCELATION-----***************************
  
    ----****************-------START FOR MANUAL REVERSAL-----***************************
    BEGIN
      V_SQL_STAT_CAN_MAN := 'SELECT OLCMNRV_DB_CR_FLG, OLC_ENTITY_NUM, OLC_BRN_CODE, OLC_LC_TYPE, OLC_LC_YEAR,
                         OLC_LC_SL, OLC_CUST_NUM, CLIENTS_NAME AS LC_ACCOUNT_NAME, FACNO(1,OLC_CUST_LIAB_ACC)
                         AS LC_ACCOUNT_NO, CLIENTS_ADDR1 AS LC_ACCOUNT_HOLDER_ADDRESS, OLC_TOT_LIAB_LIM_CURR AS LC_LIMIT,
                         OLC_PERC_OF_INS_VALUE_CVRD AS  LC_MARGIN, '' '' LC_SANCTION, '' '' LC_WROTH,DECODE(C.POST_TRAN_DATE, NULL, TRUNC(C.OLCMNRV_ENTD_ON), C.POST_TRAN_DATE) AS LC_DATE,
                         NVL(OLC_CORR_REF_NUM, '' '') AS LC_NUMBER, NVL (OLC_BENEF_CODE, '' '') AS LC_BENEFICARY_CODE,
                         '' '' AS LC_PARTICULAR, '' '' AS LC_FOREIGN_DEBIT_CURRENCY, 0 AS LC_FOREIGN_DEBIT_AMOUNT,
                         OLC_LC_DATE AS LC_FOREIGN_CONTRA_DATE, OLC_LC_CURR_CODE  AS LC_FOREIGN_CREDIT_CURRENCY,
                         OLCMNRV_REV_AMT_LC_CURR AS LC_FOREIGN_CREDIT_AMOUNT, 0  AS LC_LIABILITY_DEBIT_AMOUNT,
                         OLC_LC_DATE AS LC_LIABILITY_CONTRA_DATE, OLCMNRV_REV_AMT_BASE_CURR AS LC_LIABILITY_CREDIT_AMOUNT,
                         0 AS LC_LIABILITY_BALANCE_AMOUNT, 0  AS LC_MARGIN_PERCENTAGE, 0 AS LC_MARGIN_DEBIT_AMOUNT,
                         NULL AS LC_MARGIN_CONTRA_DATE, 0  AS LC_MARGIN_CREDIT_AMOUNT, 0 AS LC_MARGIN_BALANCE_AMOUNT,
                         '' '' AS LC_REMARKS, OLCMNRV_ENTD_ON AS OLC_ENTD_ON FROM OLCMANREV C
                         INNER JOIN OLC O
                         ON(C.OLCMNRV_ENTITY_NUM=O.OLC_ENTITY_NUM AND C.OLCMNRV_BRN_CODE=O.OLC_BRN_CODE AND
                         C.OLCMNRV_LC_TYPE=O.OLC_LC_TYPE AND C.OLCMNRV_LC_YEAR=O.OLC_LC_YEAR AND C.OLCMNRV_LC_SL=O.OLC_LC_SL )
                         JOIN CLIENTS CL ON (O.OLC_CUST_NUM=CL.CLIENTS_CODE)
                         JOIN OLCTENORS OT ON (O.OLC_ENTITY_NUM = OT.OLCT_ENTITY_NUM AND O.OLC_BRN_CODE = OT.OLCT_BRN_CODE
                         AND O.OLC_LC_TYPE=OT.OLCT_LC_TYPE AND O.OLC_LC_YEAR=OT.OLCT_LC_YEAR AND O.OLC_LC_SL=OT.OLCT_LC_SL)
                         WHERE OLC_AUTH_ON IS NOT NULL AND OLCMNRV_AUTH_BY IS NOT NULL AND OLC_BRN_CODE=:1 ';
    
      IF TO_CHAR(P_TENOR_TYPE) IS NOT NULL THEN
        V_SQL_STAT_CAN_MAN := V_SQL_STAT_CAN_MAN || ' AND OLCT_TENOR_TYPE = ' || CHR(39) || P_TENOR_TYPE || CHR(39);
      END IF;
    
      IF P_CLIENT IS NOT NULL THEN
        V_SQL_STAT_CAN_MAN := V_SQL_STAT_CAN_MAN || ' AND CLIENTS_CODE =' || P_CLIENT;
      END IF;
    
      IF P_ACCOUNTNUMBER IS NOT NULL THEN
        V_SQL_STAT_CAN_MAN := V_SQL_STAT_CAN_MAN || ' AND FACNO(1,OLC_CUST_LIAB_ACC) =' || P_ACCOUNTNUMBER;
      END IF;
    
      IF P_AS_ON_DATE IS NOT NULL THEN
        V_SQL_STAT_CAN_MAN := V_SQL_STAT_CAN_MAN || ' AND DECODE(C.POST_TRAN_DATE, NULL, TRUNC(C.OLCMNRV_ENTD_ON), C.POST_TRAN_DATE) <= ' || CHR(39) ||
                              P_AS_ON_DATE || CHR(39) || ' ';
      END IF;
    
      IF P_LC_REF_NO IS NOT NULL THEN
        V_SQL_STAT_CAN_MAN := V_SQL_STAT_CAN_MAN || ' AND OLC_CORR_REF_NUM = ' || CHR(39) || P_LC_REF_NO || CHR(39) || ' ';
      END IF;
    
      IF P_LC_TYPE IS NOT NULL THEN
        V_SQL_STAT_CAN_MAN := V_SQL_STAT_CAN_MAN || ' AND OLCMNRV_LC_TYPE = ' || CHR(39) || P_LC_TYPE || CHR(39) || ' ';
      END IF;
    
      IF P_LC_YEAR IS NOT NULL THEN
        V_SQL_STAT_CAN_MAN := V_SQL_STAT_CAN_MAN || ' AND OLCMNRV_LC_YEAR = ' || P_LC_YEAR || ' ';
      END IF;
    
      IF P_LC_SL IS NOT NULL THEN
        V_SQL_STAT_CAN_MAN := V_SQL_STAT_CAN_MAN || ' AND OLCMNRV_LC_SL = ' || P_LC_SL || ' ';
      END IF;
    
      --DBMS_OUTPUT.PUT_LINE('OLCMANREV QUERY :   ' || V_SQL_STAT_CAN_MAN);
      EXECUTE IMMEDIATE V_SQL_STAT_CAN_MAN BULK COLLECT
        INTO T_FETCH_TABLE_CAN_MAN
        USING P_BRANCH_CODE;
      BEGIN
        FOR Q IN T_FETCH_TABLE_CAN_MAN.FIRST .. T_FETCH_TABLE_CAN_MAN.LAST LOOP
          RET_RETURN_TABLE.OLC_ENTD_ON               := T_FETCH_TABLE_CAN_MAN(Q).OLC_ENTD_ON;
          RET_RETURN_TABLE.LC_ACCOUNT_NAME           := T_FETCH_TABLE_CAN_MAN(Q).LC_ACCOUNT_NAME;
          RET_RETURN_TABLE.LC_ACCOUNT_NO             := T_FETCH_TABLE_CAN_MAN(Q).LC_ACCOUNT_NO;
          RET_RETURN_TABLE.LC_ACCOUNT_HOLDER_ADDRESS := T_FETCH_TABLE_CAN_MAN(Q).LC_ACCOUNT_HOLDER_ADDRESS;
          RET_RETURN_TABLE.LC_LIMIT                  := T_FETCH_TABLE_CAN_MAN(Q).LC_LIMIT;
          RET_RETURN_TABLE.LC_MARGIN                 := T_FETCH_TABLE_CAN_MAN(Q).LC_MARGIN;
          RET_RETURN_TABLE.LC_SANCTION               := T_FETCH_TABLE_CAN_MAN(Q).LC_SANCTION;
          RET_RETURN_TABLE.LC_WROTH                  := T_FETCH_TABLE_CAN_MAN(Q).LC_WROTH;
          RET_RETURN_TABLE.LC_DATE                   := T_FETCH_TABLE_CAN_MAN(Q).LC_DATE;
          RET_RETURN_TABLE.LC_NUMBER                 := T_FETCH_TABLE_CAN_MAN(Q).LC_NUMBER;
          RET_RETURN_TABLE.LC_BENEFICARY_CODE        := T_FETCH_TABLE_CAN_MAN(Q).LC_BENEFICARY_CODE;
          RET_RETURN_TABLE.OLC_CUST_NUM              := T_FETCH_TABLE_CAN_MAN(Q).OLC_CUST_NUM;
          RET_RETURN_TABLE.OLC_BRN_CODE              := T_FETCH_TABLE_CAN_MAN(Q).OLC_BRN_CODE;
          RET_RETURN_TABLE.OLC_LC_TYPE               := T_FETCH_TABLE_CAN_MAN(Q).OLC_LC_TYPE;
          RET_RETURN_TABLE.OLC_LC_YEAR               := T_FETCH_TABLE_CAN_MAN(Q).OLC_LC_YEAR;
          RET_RETURN_TABLE.OLC_LC_SL                 := T_FETCH_TABLE_CAN_MAN(Q).OLC_LC_SL;
          RET_RETURN_TABLE.LC_FOREIGN_DEBIT_CURRENCY := T_FETCH_TABLE_CAN_MAN(Q).LC_FOREIGN_DEBIT_CURRENCY;
        
          SELECT OLC_LC_DATE
          INTO   RET_RETURN_TABLE.LC_FOREIGN_CONTRA_DATE
          FROM   OLC
          WHERE  OLC_BRN_CODE = T_FETCH_TABLE_CAN_MAN(Q).OLC_BRN_CODE
          AND    OLC_LC_TYPE = T_FETCH_TABLE_CAN_MAN(Q).OLC_LC_TYPE
          AND    OLC_LC_YEAR = T_FETCH_TABLE_CAN_MAN(Q).OLC_LC_YEAR
          AND    OLC_LC_SL = T_FETCH_TABLE_CAN_MAN(Q).OLC_LC_SL;
          RET_RETURN_TABLE.LC_LIABILITY_CONTRA_DATE    := RET_RETURN_TABLE.LC_FOREIGN_CONTRA_DATE;
          RET_RETURN_TABLE.LC_FOREIGN_CREDIT_CURRENCY  := T_FETCH_TABLE_CAN_MAN(Q).LC_FOREIGN_CREDIT_CURRENCY;
          RET_RETURN_TABLE.LC_LIABILITY_BALANCE_AMOUNT := T_FETCH_TABLE_CAN_MAN(Q).LC_LIABILITY_BALANCE_AMOUNT;
        
          IF (UPPER(T_FETCH_TABLE_CAN_MAN(Q).OLCMNRV_DB_CR_FLG) = 'C') THEN
            RET_RETURN_TABLE.LC_FOREIGN_DEBIT_AMOUNT    := 0;
            RET_RETURN_TABLE.LC_FOREIGN_CREDIT_AMOUNT   := T_FETCH_TABLE_CAN_MAN(Q).LC_FOREIGN_CREDIT_AMOUNT;
            RET_RETURN_TABLE.LC_LIABILITY_DEBIT_AMOUNT  := 0;
            RET_RETURN_TABLE.LC_LIABILITY_CREDIT_AMOUNT := T_FETCH_TABLE_CAN_MAN(Q).LC_LIABILITY_CREDIT_AMOUNT;
            RET_RETURN_TABLE.LC_PARTICULAR              := 'Liability Reversed - MR';
          ELSE
            RET_RETURN_TABLE.LC_FOREIGN_DEBIT_AMOUNT    := T_FETCH_TABLE_CAN_MAN(Q).LC_FOREIGN_CREDIT_AMOUNT;
            RET_RETURN_TABLE.LC_FOREIGN_CREDIT_AMOUNT   := 0;
            RET_RETURN_TABLE.LC_LIABILITY_DEBIT_AMOUNT  := T_FETCH_TABLE_CAN_MAN(Q).LC_LIABILITY_CREDIT_AMOUNT;
            RET_RETURN_TABLE.LC_LIABILITY_CREDIT_AMOUNT := 0;
            RET_RETURN_TABLE.LC_PARTICULAR              := 'Liability Held - MR';
          END IF;
          RET_RETURN_TABLE.LC_MARGIN_PERCENTAGE     := 0;
          RET_RETURN_TABLE.LC_MARGIN_DEBIT_AMOUNT   := 0;
          RET_RETURN_TABLE.LC_MARGIN_CONTRA_DATE    := NULL;
          RET_RETURN_TABLE.LC_MARGIN_CREDIT_AMOUNT  := 0;
          RET_RETURN_TABLE.LC_MARGIN_BALANCE_AMOUNT := 0;
          RET_RETURN_TABLE.LC_REMARKS               := T_FETCH_TABLE_CAN_MAN(Q).LC_REMARKS;
        
          PIPE ROW(RET_RETURN_TABLE);
        END LOOP;
      
      EXCEPTION
        WHEN VALUE_ERROR THEN
          NULL;
        WHEN NO_DATA_FOUND THEN
          NULL;
        WHEN OTHERS THEN
          V_ERRM := 'Error In LC Manual Reversal Block : ' || SQLERRM;
      END;
    END;
    ----****************-------END FOR MANUAL REVERSAL-----***************************
  
    ----****************-------START Margin Build Up From Export-----***************************
    IF (P_ACCOUNTNUMBER IS NULL AND P_LC_REF_NO IS NULL AND P_LC_TYPE IS NULL AND TO_CHAR(P_TENOR_TYPE) IS NULL) THEN
    
      BEGIN
        V_SQL_STAT_OBPAYDISB := 'SELECT D.OBPAYD_BRN_CODE, O.OBILL_CLIENT_CODE, CLIENTS_NAME, CLIENTS_ADDR1 CLIENTS_ADDRESS, D.POST_TRAN_DATE MARGIN_REC_DATE, SUM(NVL(D.OBPAYD_MRGN_AMT_RCVRY_CURR, 0)) MARGIN_CREDIT_AMOUNT, MAX(D.OBPAYD_ENTD_ON) OBPAYD_ENTD_ON
                FROM   OBPAYDISB D, OBILL O, CLIENTS C WHERE D.OBPAYD_ENTITY_NUM = O.OBILL_ENTITY_NUM AND D.OBPAYD_BRN_CODE = OBILL_BRN_CODE AND D.OBPAYD_BILL_TYPE = OBILL_TYPE
                AND D.OBPAYD_BILL_YEAR = OBILL_YEAR AND D.OBPAYD_BILL_SL = OBILL_NO AND O.OBILL_CLIENT_CODE = C.CLIENTS_CODE AND D.OBPAYD_ENTITY_NUM =:1 AND D.OBPAYD_MRGN_AMT_RCVRY_CURR <> 0 AND D.OBPAYD_AUTH_ON IS NOT NULL ';
      
        IF P_BRANCH_CODE IS NOT NULL THEN
          V_SQL_STAT_OBPAYDISB := V_SQL_STAT_OBPAYDISB || ' AND D.OBPAYD_BRN_CODE = ' || P_BRANCH_CODE;
        END IF;
      
        IF P_CLIENT IS NOT NULL THEN
          V_SQL_STAT_OBPAYDISB := V_SQL_STAT_OBPAYDISB || ' AND O.OBILL_CLIENT_CODE = ' || P_CLIENT;
        END IF;
      
        IF P_AS_ON_DATE IS NOT NULL THEN
          V_SQL_STAT_OBPAYDISB := V_SQL_STAT_OBPAYDISB || ' AND DECODE(D.POST_TRAN_DATE, NULL, TRUNC(D.OBPAYD_ENTD_ON), D.POST_TRAN_DATE) <= ' ||
                                  CHR(39) || P_AS_ON_DATE || CHR(39) || ' ';
        END IF;
      
        V_SQL_STAT_OBPAYDISB := V_SQL_STAT_OBPAYDISB ||
                                ' GROUP BY D.OBPAYD_BRN_CODE, O.OBILL_CLIENT_CODE, CLIENTS_NAME, CLIENTS_ADDR1, D.POST_TRAN_DATE ';
        --DBMS_OUTPUT.PUT_LINE(' Export Bill Disburesement Margin Held Query : ' || V_SQL_STAT_OBPAYDISB);
        EXECUTE IMMEDIATE V_SQL_STAT_OBPAYDISB BULK COLLECT
          INTO T_FETCH_TABLE_OBPAYDISB
          USING P_ENTITYNUMBER;
        BEGIN
          FOR J IN T_FETCH_TABLE_OBPAYDISB.FIRST .. T_FETCH_TABLE_OBPAYDISB.LAST LOOP
            IF T_FETCH_TABLE_OBPAYDISB(J).MARGIN_CREDIT_AMOUNT > 0 THEN
              RET_RETURN_TABLE.OLC_ENTD_ON                 := T_FETCH_TABLE_OBPAYDISB(J).MARGIN_ENTD_ON;
              RET_RETURN_TABLE.LC_ACCOUNT_NAME             := T_FETCH_TABLE_OBPAYDISB(J).CLIENTS_NAME;
              RET_RETURN_TABLE.LC_ACCOUNT_NO               := '';
              RET_RETURN_TABLE.LC_ACCOUNT_HOLDER_ADDRESS   := T_FETCH_TABLE_OBPAYDISB(J).CLIENTS_ADDRESS;
              RET_RETURN_TABLE.LC_LIMIT                    := 0;
              RET_RETURN_TABLE.LC_MARGIN                   := 0;
              RET_RETURN_TABLE.LC_SANCTION                 := NULL;
              RET_RETURN_TABLE.LC_WROTH                    := NULL;
              RET_RETURN_TABLE.LC_DATE                     := T_FETCH_TABLE_OBPAYDISB(J).MARGIN_REC_DATE;
              RET_RETURN_TABLE.LC_NUMBER                   := '';
              RET_RETURN_TABLE.LC_BENEFICARY_CODE          := '';
              RET_RETURN_TABLE.OLC_CUST_NUM                := T_FETCH_TABLE_OBPAYDISB(J).CLIENTS_NUMBER;
              RET_RETURN_TABLE.OLC_BRN_CODE                := T_FETCH_TABLE_OBPAYDISB(J).BRANCH_CODE;
              RET_RETURN_TABLE.OLC_LC_TYPE                 := '';
              RET_RETURN_TABLE.OLC_LC_YEAR                 := 0;
              RET_RETURN_TABLE.OLC_LC_SL                   := 0;
              RET_RETURN_TABLE.LC_FOREIGN_DEBIT_CURRENCY   := NULL;
              RET_RETURN_TABLE.LC_FOREIGN_DEBIT_AMOUNT     := 0;
              RET_RETURN_TABLE.LC_FOREIGN_CONTRA_DATE      := NULL;
              RET_RETURN_TABLE.LC_FOREIGN_CREDIT_CURRENCY  := NULL;
              RET_RETURN_TABLE.LC_FOREIGN_CREDIT_AMOUNT    := 0;
              RET_RETURN_TABLE.LC_LIABILITY_DEBIT_AMOUNT   := 0;
              RET_RETURN_TABLE.LC_LIABILITY_CONTRA_DATE    := NULL;
              RET_RETURN_TABLE.LC_LIABILITY_CREDIT_AMOUNT  := 0;
              RET_RETURN_TABLE.LC_LIABILITY_BALANCE_AMOUNT := 0;
              RET_RETURN_TABLE.LC_PARTICULAR               := 'Margin Build Up From Export';
              RET_RETURN_TABLE.LC_MARGIN_PERCENTAGE        := 0;
              RET_RETURN_TABLE.LC_MARGIN_DEBIT_AMOUNT      := 0;
              RET_RETURN_TABLE.LC_MARGIN_CREDIT_AMOUNT     := T_FETCH_TABLE_OBPAYDISB(J).MARGIN_CREDIT_AMOUNT;
              RET_RETURN_TABLE.LC_MARGIN_BALANCE_AMOUNT    := 0;
              RET_RETURN_TABLE.LC_REMARKS                  := '';
              PIPE ROW(RET_RETURN_TABLE);
            END IF;
          END LOOP;
        EXCEPTION
          WHEN VALUE_ERROR THEN
            NULL;
          WHEN NO_DATA_FOUND THEN
            NULL;
          WHEN OTHERS THEN
            NULL;
        END;
      END;
    END IF;
    ----****************-------End Margin Build Up From Export-----***************************
  
    ----****************-----Start Export Margin Transferred to Import LC-----***************************
    BEGIN
      V_SQL_STAT_OBFREEMARGIN := 'SELECT CLIENTS_NAME AS LC_ACCOUNT_NAME, FACNO(1, OLC_CUST_LIAB_ACC) AS LC_ACCOUNT_NO, CLIENTS_ADDR1 AS LC_ACCOUNT_HOLDER_ADDRESS,
                  NVL(OLC_CORR_REF_NUM, '' '') AS LC_NUMBER, NVL(OLC_BENEF_CODE, '' '') AS LC_BENEFICARY_CODE, OLC_CUST_NUM, DECODE(OB.POST_TRAN_DATE,NULL,TRUNC(OB.OBFRM_ENTD_ON),OB.POST_TRAN_DATE) LC_DATE,
                  SUM(NVL(OBD.OBFRMD_MARGIN_ADDED, 0)) LC_MARGIN_CREDIT_AMOUNT, MAX(OB.OBFRM_ENTD_ON) OLC_ENTD_ON, OBD.OBFRMD_LC_BRN_CODE, OBD.OBFRMD_LC_TYPE, OBD.OBFRMD_LC_YEAR, OBD.OBFRMD_LC_SL
                  FROM OBFREEMARGIN OB, OBFREEMARGINDTL OBD, OLC L, CLIENTS C, OLCTENORS OT WHERE  OB.OBFRM_ENTITY_NUM = OBD.OBFRMD_ENTITY_NUM
                  AND OB.OBFRM_BRN_CODE = OBD.OBFRMD_BRN_CODE AND OB.OBFRM_CUST_CODE = OBD.OBFRMD_CUST_CODE AND OB.OBFRM_ENTRY_SL = OBD.OBFRMD_ENTRY_SL
                  AND OBD.OBFRMD_ENTITY_NUM = L.OLC_ENTITY_NUM AND OBD.OBFRMD_LC_BRN_CODE = L.OLC_BRN_CODE AND OBD.OBFRMD_LC_TYPE = L.OLC_LC_TYPE
                  AND OBD.OBFRMD_LC_YEAR = L.OLC_LC_YEAR AND OBD.OBFRMD_LC_SL = L.OLC_LC_SL AND OB.OBFRM_CUST_CODE = C.CLIENTS_CODE
                  AND L.OLC_ENTITY_NUM = OT.OLCT_ENTITY_NUM AND L.OLC_BRN_CODE = OT.OLCT_BRN_CODE AND L.OLC_LC_TYPE = OT.OLCT_LC_TYPE
                  AND L.OLC_LC_YEAR = OT.OLCT_LC_YEAR AND L.OLC_LC_SL = OT.OLCT_LC_SL AND OB.OBFRM_AUTH_ON IS NOT NULL AND OBD.OBFRMD_ENTITY_NUM = :1 ';
    
      IF P_BRANCH_CODE IS NOT NULL THEN
        V_SQL_STAT_OBFREEMARGIN := V_SQL_STAT_OBFREEMARGIN || ' AND OBD.OBFRMD_LC_BRN_CODE = ' || P_BRANCH_CODE;
      END IF;
    
      IF P_CLIENT IS NOT NULL THEN
        V_SQL_STAT_OBFREEMARGIN := V_SQL_STAT_OBFREEMARGIN || ' AND OBD.OBFRMD_CUST_CODE = ' || P_CLIENT;
      END IF;
    
      IF P_ACCOUNTNUMBER IS NOT NULL THEN
        V_SQL_STAT_OBFREEMARGIN := V_SQL_STAT_OBFREEMARGIN || ' AND FACNO(1,OLC_CUST_LIAB_ACC) =' || P_ACCOUNTNUMBER;
      END IF;
    
      IF P_AS_ON_DATE IS NOT NULL THEN
        V_SQL_STAT_OBFREEMARGIN := V_SQL_STAT_OBFREEMARGIN || ' AND DECODE(OB.POST_TRAN_DATE,NULL,TRUNC(OB.OBFRM_ENTD_ON),OB.POST_TRAN_DATE) <= ' ||
                                   CHR(39) || P_AS_ON_DATE || CHR(39) || ' ';
      END IF;
    
      IF P_LC_REF_NO IS NOT NULL THEN
        V_SQL_STAT_OBFREEMARGIN := V_SQL_STAT_OBFREEMARGIN || ' AND OLC_CORR_REF_NUM = ' || CHR(39) || P_LC_REF_NO || CHR(39) || ' ';
      END IF;
    
      IF P_LC_TYPE IS NOT NULL THEN
        V_SQL_STAT_OBFREEMARGIN := V_SQL_STAT_OBFREEMARGIN || ' AND OBD.OBFRMD_LC_TYPE = ' || CHR(39) || P_LC_TYPE || CHR(39) || ' ';
      END IF;
    
      IF P_LC_YEAR IS NOT NULL THEN
        V_SQL_STAT_OBFREEMARGIN := V_SQL_STAT_OBFREEMARGIN || ' AND OBD.OBFRMD_LC_YEAR = ' || P_LC_YEAR || ' ';
      END IF;
    
      IF P_LC_SL IS NOT NULL THEN
        V_SQL_STAT_OBFREEMARGIN := V_SQL_STAT_OBFREEMARGIN || ' AND OBD.OBFRMD_LC_SL = ' || P_LC_SL || ' ';
      END IF;
    
      IF TO_CHAR(P_TENOR_TYPE) IS NOT NULL THEN
        V_SQL_STAT_OBFREEMARGIN := V_SQL_STAT_OBFREEMARGIN || ' AND OLCT_TENOR_TYPE = ' || CHR(39) || P_TENOR_TYPE || CHR(39);
      END IF;
    
      V_SQL_STAT_OBFREEMARGIN := V_SQL_STAT_OBFREEMARGIN ||
                                 ' GROUP BY CLIENTS_NAME,OLC_CUST_LIAB_ACC,CLIENTS_ADDR1,OLC_CORR_REF_NUM,OLC_BENEF_CODE,OLC_CUST_NUM, OB.POST_TRAN_DATE, OB.OBFRM_ENTD_ON, OBD.OBFRMD_LC_BRN_CODE, OBD.OBFRMD_LC_TYPE, OBD.OBFRMD_LC_YEAR, OBD.OBFRMD_LC_SL ';
    
      EXECUTE IMMEDIATE V_SQL_STAT_OBFREEMARGIN BULK COLLECT
        INTO T_FETCH_TABLE_OBFREEMARGIN
        USING P_ENTITYNUMBER;
      BEGIN
        FOR J IN T_FETCH_TABLE_OBFREEMARGIN.FIRST .. T_FETCH_TABLE_OBFREEMARGIN.LAST LOOP
          IF T_FETCH_TABLE_OBFREEMARGIN(J).LC_MARGIN_CREDIT_AMOUNT > 0 THEN
            IF (P_ACCOUNTNUMBER IS NULL AND P_LC_REF_NO IS NULL AND P_LC_TYPE IS NULL AND TO_CHAR(P_TENOR_TYPE) IS NULL) THEN
              RET_RETURN_TABLE.OLC_ENTD_ON                 := T_FETCH_TABLE_OBFREEMARGIN(J).OLC_ENTD_ON;
              RET_RETURN_TABLE.LC_ACCOUNT_NAME             := T_FETCH_TABLE_OBFREEMARGIN(J).LC_ACCOUNT_NAME;
              RET_RETURN_TABLE.LC_ACCOUNT_NO               := '';
              RET_RETURN_TABLE.LC_ACCOUNT_HOLDER_ADDRESS   := T_FETCH_TABLE_OBFREEMARGIN(J).LC_ACCOUNT_HOLDER_ADDRESS;
              RET_RETURN_TABLE.LC_LIMIT                    := 0;
              RET_RETURN_TABLE.LC_MARGIN                   := 0;
              RET_RETURN_TABLE.LC_SANCTION                 := NULL;
              RET_RETURN_TABLE.LC_WROTH                    := NULL;
              RET_RETURN_TABLE.LC_DATE                     := T_FETCH_TABLE_OBFREEMARGIN(J).LC_DATE;
              RET_RETURN_TABLE.LC_NUMBER                   := '';
              RET_RETURN_TABLE.LC_BENEFICARY_CODE          := '';
              RET_RETURN_TABLE.OLC_CUST_NUM                := T_FETCH_TABLE_OBFREEMARGIN(J).OLC_CUST_NUM;
              RET_RETURN_TABLE.OLC_BRN_CODE                := T_FETCH_TABLE_OBFREEMARGIN(J).OLC_BRN_CODE;
              RET_RETURN_TABLE.OLC_LC_TYPE                 := '';
              RET_RETURN_TABLE.OLC_LC_YEAR                 := 0;
              RET_RETURN_TABLE.OLC_LC_SL                   := 0;
              RET_RETURN_TABLE.LC_FOREIGN_DEBIT_CURRENCY   := NULL;
              RET_RETURN_TABLE.LC_FOREIGN_DEBIT_AMOUNT     := 0;
              RET_RETURN_TABLE.LC_FOREIGN_CONTRA_DATE      := NULL;
              RET_RETURN_TABLE.LC_FOREIGN_CREDIT_CURRENCY  := NULL;
              RET_RETURN_TABLE.LC_FOREIGN_CREDIT_AMOUNT    := 0;
              RET_RETURN_TABLE.LC_LIABILITY_DEBIT_AMOUNT   := 0;
              RET_RETURN_TABLE.LC_LIABILITY_CONTRA_DATE    := NULL;
              RET_RETURN_TABLE.LC_LIABILITY_CREDIT_AMOUNT  := 0;
              RET_RETURN_TABLE.LC_LIABILITY_BALANCE_AMOUNT := 0;
              RET_RETURN_TABLE.LC_PARTICULAR               := 'Margin Transferred To Import LC';
              RET_RETURN_TABLE.LC_MARGIN_PERCENTAGE        := 0;
              RET_RETURN_TABLE.LC_MARGIN_DEBIT_AMOUNT      := T_FETCH_TABLE_OBFREEMARGIN(J).LC_MARGIN_CREDIT_AMOUNT;
              RET_RETURN_TABLE.LC_MARGIN_CREDIT_AMOUNT     := 0;
              RET_RETURN_TABLE.LC_MARGIN_BALANCE_AMOUNT    := 0;
              RET_RETURN_TABLE.LC_REMARKS                  := '';
              PIPE ROW(RET_RETURN_TABLE);
            END IF;
          
            RET_RETURN_TABLE.OLC_ENTD_ON                 := T_FETCH_TABLE_OBFREEMARGIN(J).OLC_ENTD_ON;
            RET_RETURN_TABLE.LC_ACCOUNT_NAME             := T_FETCH_TABLE_OBFREEMARGIN(J).LC_ACCOUNT_NAME;
            RET_RETURN_TABLE.LC_ACCOUNT_NO               := T_FETCH_TABLE_OBFREEMARGIN(J).LC_ACCOUNT_NO;
            RET_RETURN_TABLE.LC_ACCOUNT_HOLDER_ADDRESS   := T_FETCH_TABLE_OBFREEMARGIN(J).LC_ACCOUNT_HOLDER_ADDRESS;
            RET_RETURN_TABLE.LC_LIMIT                    := 0;
            RET_RETURN_TABLE.LC_MARGIN                   := 0;
            RET_RETURN_TABLE.LC_SANCTION                 := NULL;
            RET_RETURN_TABLE.LC_WROTH                    := NULL;
            RET_RETURN_TABLE.LC_DATE                     := T_FETCH_TABLE_OBFREEMARGIN(J).LC_DATE;
            RET_RETURN_TABLE.LC_NUMBER                   := T_FETCH_TABLE_OBFREEMARGIN(J).LC_NUMBER;
            RET_RETURN_TABLE.LC_BENEFICARY_CODE          := T_FETCH_TABLE_OBFREEMARGIN(J).LC_BENEFICARY_CODE;
            RET_RETURN_TABLE.OLC_CUST_NUM                := T_FETCH_TABLE_OBFREEMARGIN(J).OLC_CUST_NUM;
            RET_RETURN_TABLE.OLC_BRN_CODE                := T_FETCH_TABLE_OBFREEMARGIN(J).OLC_BRN_CODE;
            RET_RETURN_TABLE.OLC_LC_TYPE                 := T_FETCH_TABLE_OBFREEMARGIN(J).OLC_LC_TYPE;
            RET_RETURN_TABLE.OLC_LC_YEAR                 := T_FETCH_TABLE_OBFREEMARGIN(J).OLC_LC_YEAR;
            RET_RETURN_TABLE.OLC_LC_SL                   := T_FETCH_TABLE_OBFREEMARGIN(J).OLC_LC_SL;
            RET_RETURN_TABLE.LC_FOREIGN_DEBIT_CURRENCY   := NULL;
            RET_RETURN_TABLE.LC_FOREIGN_DEBIT_AMOUNT     := 0;
            RET_RETURN_TABLE.LC_FOREIGN_CONTRA_DATE      := NULL;
            RET_RETURN_TABLE.LC_FOREIGN_CREDIT_CURRENCY  := NULL;
            RET_RETURN_TABLE.LC_FOREIGN_CREDIT_AMOUNT    := 0;
            RET_RETURN_TABLE.LC_LIABILITY_DEBIT_AMOUNT   := 0;
            RET_RETURN_TABLE.LC_LIABILITY_CONTRA_DATE    := NULL;
            RET_RETURN_TABLE.LC_LIABILITY_CREDIT_AMOUNT  := 0;
            RET_RETURN_TABLE.LC_LIABILITY_BALANCE_AMOUNT := 0;
            RET_RETURN_TABLE.LC_PARTICULAR               := 'Margin Held from Export';
            RET_RETURN_TABLE.LC_MARGIN_PERCENTAGE        := 0;
            RET_RETURN_TABLE.LC_MARGIN_DEBIT_AMOUNT      := 0;
            RET_RETURN_TABLE.LC_MARGIN_CREDIT_AMOUNT     := T_FETCH_TABLE_OBFREEMARGIN(J).LC_MARGIN_CREDIT_AMOUNT;
            RET_RETURN_TABLE.LC_MARGIN_BALANCE_AMOUNT    := 0;
            RET_RETURN_TABLE.LC_REMARKS                  := '';
            PIPE ROW(RET_RETURN_TABLE);
          END IF;
        END LOOP;
      EXCEPTION
        WHEN VALUE_ERROR THEN
          NULL;
        WHEN NO_DATA_FOUND THEN
          NULL;
        WHEN OTHERS THEN
          NULL;
      END;
    END;
    ----****************-----End Export Margin Transferred to Import LC/Release Margin-----***************************
  
    ----****************-----Start Export Margin Release to Customer Account-----***************************
    IF (P_ACCOUNTNUMBER IS NULL AND P_LC_REF_NO IS NULL AND P_LC_TYPE IS NULL AND TO_CHAR(P_TENOR_TYPE) IS NULL) THEN
      BEGIN
        V_SQL_STAT_OBFREEMARGIN := 'SELECT CLIENTS_NAME AS LC_ACCOUNT_NAME, 0 AS LC_ACCOUNT_NO, CLIENTS_ADDR1 AS LC_ACCOUNT_HOLDER_ADDRESS, '' '' AS LC_NUMBER, '' '' AS LC_BENEFICARY_CODE,
                              OB.OBFRM_CUST_CODE OLC_CUST_NUM, DECODE(OB.POST_TRAN_DATE, NULL, TRUNC(OB.OBFRM_ENTD_ON), OB.POST_TRAN_DATE) LC_DATE, SUM(NVL(OB.OBFRM_TOL_MARGIN_REL_AMT, 0)) LC_MARGIN_CREDIT_AMOUNT,
                              MAX(OB.OBFRM_ENTD_ON) OLC_ENTD_ON, OB.OBFRM_BRN_CODE OLC_BRN_CODE, '' '' OLC_LC_TYPE, 0 OLC_LC_YEAR, 0 OLC_LC_SL
                              FROM   OBFREEMARGIN OB, CLIENTS C WHERE  OB.OBFRM_CUST_CODE = C.CLIENTS_CODE AND OB.OBFRM_MARGIN_UTIL_OPTION = ''R'' AND OB.OBFRM_AUTH_ON IS NOT NULL
                              AND    OB.OBFRM_ENTITY_NUM = :1 ';
      
        IF P_BRANCH_CODE IS NOT NULL THEN
          V_SQL_STAT_OBFREEMARGIN := V_SQL_STAT_OBFREEMARGIN || ' AND OB.OBFRM_BRN_CODE = ' || P_BRANCH_CODE;
        END IF;
      
        IF P_CLIENT IS NOT NULL THEN
          V_SQL_STAT_OBFREEMARGIN := V_SQL_STAT_OBFREEMARGIN || ' AND OB.OBFRM_CUST_CODE = ' || P_CLIENT;
        END IF;
      
        IF P_AS_ON_DATE IS NOT NULL THEN
          V_SQL_STAT_OBFREEMARGIN := V_SQL_STAT_OBFREEMARGIN ||
                                     ' AND DECODE(OB.POST_TRAN_DATE, NULL, TRUNC(OB.OBFRM_ENTD_ON), OB.POST_TRAN_DATE) <= ' || CHR(39) ||
                                     P_AS_ON_DATE || CHR(39) || ' ';
        END IF;
      
        V_SQL_STAT_OBFREEMARGIN := V_SQL_STAT_OBFREEMARGIN ||
                                   ' GROUP  BY CLIENTS_NAME, CLIENTS_ADDR1, OBFRM_CUST_CODE, OB.POST_TRAN_DATE, OB.OBFRM_ENTD_ON, OBFRM_BRN_CODE ';
        EXECUTE IMMEDIATE V_SQL_STAT_OBFREEMARGIN BULK COLLECT
          INTO T_FETCH_TABLE_OBFREEMARGIN
          USING P_ENTITYNUMBER;
        BEGIN
          FOR K IN T_FETCH_TABLE_OBFREEMARGIN.FIRST .. T_FETCH_TABLE_OBFREEMARGIN.LAST LOOP
            IF T_FETCH_TABLE_OBFREEMARGIN(K).LC_MARGIN_CREDIT_AMOUNT > 0 THEN
              RET_RETURN_TABLE.OLC_ENTD_ON                 := T_FETCH_TABLE_OBFREEMARGIN(K).OLC_ENTD_ON;
              RET_RETURN_TABLE.LC_ACCOUNT_NAME             := T_FETCH_TABLE_OBFREEMARGIN(K).LC_ACCOUNT_NAME;
              RET_RETURN_TABLE.LC_ACCOUNT_NO               := '';
              RET_RETURN_TABLE.LC_ACCOUNT_HOLDER_ADDRESS   := T_FETCH_TABLE_OBFREEMARGIN(K).LC_ACCOUNT_HOLDER_ADDRESS;
              RET_RETURN_TABLE.LC_LIMIT                    := 0;
              RET_RETURN_TABLE.LC_MARGIN                   := 0;
              RET_RETURN_TABLE.LC_SANCTION                 := NULL;
              RET_RETURN_TABLE.LC_WROTH                    := NULL;
              RET_RETURN_TABLE.LC_DATE                     := T_FETCH_TABLE_OBFREEMARGIN(K).LC_DATE;
              RET_RETURN_TABLE.LC_NUMBER                   := '';
              RET_RETURN_TABLE.LC_BENEFICARY_CODE          := '';
              RET_RETURN_TABLE.OLC_CUST_NUM                := T_FETCH_TABLE_OBFREEMARGIN(K).OLC_CUST_NUM;
              RET_RETURN_TABLE.OLC_BRN_CODE                := T_FETCH_TABLE_OBFREEMARGIN(K).OLC_BRN_CODE;
              RET_RETURN_TABLE.OLC_LC_TYPE                 := '';
              RET_RETURN_TABLE.OLC_LC_YEAR                 := 0;
              RET_RETURN_TABLE.OLC_LC_SL                   := 0;
              RET_RETURN_TABLE.LC_FOREIGN_DEBIT_CURRENCY   := NULL;
              RET_RETURN_TABLE.LC_FOREIGN_DEBIT_AMOUNT     := 0;
              RET_RETURN_TABLE.LC_FOREIGN_CONTRA_DATE      := NULL;
              RET_RETURN_TABLE.LC_FOREIGN_CREDIT_CURRENCY  := NULL;
              RET_RETURN_TABLE.LC_FOREIGN_CREDIT_AMOUNT    := 0;
              RET_RETURN_TABLE.LC_LIABILITY_DEBIT_AMOUNT   := 0;
              RET_RETURN_TABLE.LC_LIABILITY_CONTRA_DATE    := NULL;
              RET_RETURN_TABLE.LC_LIABILITY_CREDIT_AMOUNT  := 0;
              RET_RETURN_TABLE.LC_LIABILITY_BALANCE_AMOUNT := 0;
              RET_RETURN_TABLE.LC_PARTICULAR               := 'Margin Released To Customer';
              RET_RETURN_TABLE.LC_MARGIN_PERCENTAGE        := 0;
              RET_RETURN_TABLE.LC_MARGIN_DEBIT_AMOUNT      := T_FETCH_TABLE_OBFREEMARGIN(K).LC_MARGIN_CREDIT_AMOUNT;
              RET_RETURN_TABLE.LC_MARGIN_CREDIT_AMOUNT     := 0;
              RET_RETURN_TABLE.LC_MARGIN_BALANCE_AMOUNT    := 0;
              RET_RETURN_TABLE.LC_REMARKS                  := '';
              PIPE ROW(RET_RETURN_TABLE);
            END IF;
          END LOOP;
        EXCEPTION
          WHEN VALUE_ERROR THEN
            NULL;
          WHEN NO_DATA_FOUND THEN
            NULL;
          WHEN OTHERS THEN
            NULL;
        END;
      END;
    END IF;
    ----****************-----End Export Margin Release to Customer Account-----***************************
  
  END;

  FUNCTION GET_OS_LC_AMT(P_ENTITYNUMBER NUMBER,
                         P_BRANCH_CODE  NUMBER,
                         P_LC_TYPE      VARCHAR2,
                         P_LC_YEAR      NUMBER,
                         P_LC_SL        NUMBER,
                         P_AS_ON_DATE   DATE) RETURN NUMBER IS
    OS_LC_AMT NUMBER(18, 3) := 0;
    TEMP_AMT  NUMBER(18, 3) := 0;
  BEGIN
    SELECT NVL((NN.OLCA_AMENDED_AMT + OLC_LC_AMOUNT), 0)
    INTO   TEMP_AMT
    FROM   (SELECT O.OLC_LC_AMOUNT, O.OLC_LIAB_OCCURED_BASE_CURR
             FROM   OLC O
             WHERE  O.OLC_ENTITY_NUM = P_ENTITYNUMBER
             AND    O.OLC_BRN_CODE = P_BRANCH_CODE
             AND    O.OLC_LC_TYPE = P_LC_TYPE
             AND    O.OLC_LC_YEAR = P_LC_YEAR
             AND    O.OLC_LC_SL = P_LC_SL
             AND    O.POST_TRAN_DATE <= P_AS_ON_DATE
             GROUP  BY O.OLC_LC_AMOUNT, O.OLC_LIAB_OCCURED_BASE_CURR) N
    LEFT   JOIN (SELECT NVL(SUM(DECODE(OLCA_ENHANCEMNT_REDUCN, 'E', OA.OLCA_EN_RED_AMT_WITHOUT_DEV, -OA.OLCA_EN_RED_AMT_WITHOUT_DEV)), 0) OLCA_AMENDED_AMT
                 FROM   OLCAMD OA
                 WHERE  OA.OLCA_ENTITY_NUM = P_ENTITYNUMBER
                 AND    OA.OLCA_BRN_CODE = P_BRANCH_CODE
                 AND    OA.OLCA_LC_TYPE = P_LC_TYPE
                 AND    OA.OLCA_LC_YEAR = P_LC_YEAR
                 AND    OA.OLCA_LC_SL = P_LC_SL
                 AND    OA.POST_TRAN_DATE <= P_AS_ON_DATE
                 AND    OA.OLCA_AUTH_BY IS NOT NULL) NN
    ON     (1 = 1);
  
    OS_LC_AMT := TEMP_AMT;
  
    SELECT NVL(SUM(OLCCN_TOT_LIAB_REV_LC_CURR), 0)
    INTO   TEMP_AMT
    FROM   OLCCAN O
    WHERE  O.OLCCN_ENTITY_NUM = P_ENTITYNUMBER
    AND    O.OLCCN_BRN_CODE = P_BRANCH_CODE
    AND    O.OLCCN_LC_TYPE = P_LC_TYPE
    AND    O.OLCCN_LC_YEAR = P_LC_YEAR
    AND    O.OLCCN_LC_SL = P_LC_SL
    AND    O.POST_TRAN_DATE <= P_AS_ON_DATE;
  
    IF (TEMP_AMT > 0) THEN
      OS_LC_AMT := 0;
    ELSE
      SELECT NVL(SUM(I.IBILL_BILL_AMOUNT), 0)
      INTO   TEMP_AMT
      FROM   IBILL I, IBILLACC A
      WHERE  I.IBILL_ENTITY_NUM = IBACC_ENTITY_NUM
      AND    I.IBILL_BRN_CODE = IBACC_BRN_CODE
      AND    I.IBILL_BILL_TYPE = IBACC_BILL_TYPE
      AND    I.IBILL_BILL_YEAR = IBACC_BILL_YEAR
      AND    I.IBILL_BILL_SL = IBACC_BILL_SL
      AND    I.IBILL_ENTITY_NUM = P_ENTITYNUMBER
      AND    I.IBILL_BRN_CODE = P_BRANCH_CODE
      AND    I.IBILL_OLC_TYPE = P_LC_TYPE
      AND    I.IBILL_OLC_YEAR = P_LC_YEAR
      AND    I.IBILL_OLC_SL = P_LC_SL
      AND    A.POST_TRAN_DATE <= P_AS_ON_DATE
      AND    A.IBACC_AUTH_ON IS NOT NULL;
    
      OS_LC_AMT := OS_LC_AMT - TEMP_AMT;
    
      SELECT NVL(SUM(IP.IBPAY_PAY_AMT), 0)
      INTO   TEMP_AMT
      FROM   IBILL IB, IBPAY IP
      WHERE  IB.IBILL_ENTITY_NUM = IP.IBPAY_ENTITY_NUM
      AND    IB.IBILL_BRN_CODE = IP.IBPAY_BRN_CODE
      AND    IB.IBILL_BILL_TYPE = IP.IBPAY_BILL_TYPE
      AND    IB.IBILL_BILL_YEAR = IP.IBPAY_BILL_YEAR
      AND    IB.IBILL_BILL_SL = IP.IBPAY_BILL_SL
      AND    IP.IBPAY_AUTH_BY IS NOT NULL
      AND    IBILL_ENTITY_NUM = P_ENTITYNUMBER
      AND    IBILL_BRN_CODE = P_BRANCH_CODE
      AND    IBILL_OLC_TYPE = P_LC_TYPE
      AND    IBILL_OLC_YEAR = P_LC_YEAR
      AND    IBILL_OLC_SL = P_LC_SL
      AND    IP.POST_TRAN_DATE <= P_AS_ON_DATE;
    
      OS_LC_AMT := OS_LC_AMT - TEMP_AMT;
    
      SELECT NVL(SUM(DECODE(O.OLCMNRV_DB_CR_FLG, 'D', -O.OLCMNRV_REV_AMT_LC_CURR, O.OLCMNRV_REV_AMT_LC_CURR)), 0)
      INTO   TEMP_AMT
      FROM   OLCMANREV O
      WHERE  O.OLCMNRV_ENTITY_NUM = P_ENTITYNUMBER
      AND    O.OLCMNRV_BRN_CODE = P_BRANCH_CODE
      AND    O.OLCMNRV_LC_TYPE = P_LC_TYPE
      AND    O.OLCMNRV_LC_YEAR = P_LC_YEAR
      AND    O.OLCMNRV_LC_SL = P_LC_SL
      AND    O.POST_TRAN_DATE <= P_AS_ON_DATE;
    
      OS_LC_AMT := OS_LC_AMT - TEMP_AMT;
    END IF;
    RETURN ROUND(OS_LC_AMT, 2);
  END;

  FUNCTION GET_OS_LC_LIABILITY_AMT(P_ENTITYNUMBER NUMBER,
                                   P_BRANCH_CODE  NUMBER,
                                   P_LC_TYPE      VARCHAR2,
                                   P_LC_YEAR      NUMBER,
                                   P_LC_SL        NUMBER,
                                   P_AS_ON_DATE   DATE) RETURN NUMBER IS
    OS_LC_LIABILITY_AMT NUMBER(18, 3) := 0;
    TEMP_AMT            NUMBER(18, 3) := 0;
  BEGIN
    SELECT NVL(O.OLC_LIAB_OCCURED_BASE_CURR, 0)
    INTO   TEMP_AMT
    FROM   OLC O
    WHERE  O.OLC_ENTITY_NUM = P_ENTITYNUMBER
    AND    O.OLC_BRN_CODE = P_BRANCH_CODE
    AND    O.OLC_LC_TYPE = P_LC_TYPE
    AND    O.OLC_LC_YEAR = P_LC_YEAR
    AND    O.OLC_LC_SL = P_LC_SL
    AND    O.POST_TRAN_DATE <= P_AS_ON_DATE;
  
    OS_LC_LIABILITY_AMT := TEMP_AMT;
  
    SELECT NVL(SUM(OLCCN_TOT_LIAB_REV_BASE_CURR), 0)
    INTO   TEMP_AMT
    FROM   OLCCAN O
    WHERE  O.OLCCN_ENTITY_NUM = P_ENTITYNUMBER
    AND    O.OLCCN_BRN_CODE = P_BRANCH_CODE
    AND    O.OLCCN_LC_TYPE = P_LC_TYPE
    AND    O.OLCCN_LC_YEAR = P_LC_YEAR
    AND    O.OLCCN_LC_SL = P_LC_SL
    AND    O.POST_TRAN_DATE <= P_AS_ON_DATE;
  
    OS_LC_LIABILITY_AMT := OS_LC_LIABILITY_AMT - TEMP_AMT;
  
    SELECT NVL(SUM(IBACC_LC_LIAB_REVERSE_AMT), 0)
    INTO   TEMP_AMT
    FROM   IBILL I, IBILLACC A
    WHERE  I.IBILL_ENTITY_NUM = IBACC_ENTITY_NUM
    AND    I.IBILL_BRN_CODE = IBACC_BRN_CODE
    AND    I.IBILL_BILL_TYPE = IBACC_BILL_TYPE
    AND    I.IBILL_BILL_YEAR = IBACC_BILL_YEAR
    AND    I.IBILL_BILL_SL = IBACC_BILL_SL
    AND    I.IBILL_ENTITY_NUM = P_ENTITYNUMBER
    AND    I.IBILL_BRN_CODE = P_BRANCH_CODE
    AND    I.IBILL_OLC_TYPE = P_LC_TYPE
    AND    I.IBILL_OLC_YEAR = P_LC_YEAR
    AND    I.IBILL_OLC_SL = P_LC_SL
    AND    A.POST_TRAN_DATE <= P_AS_ON_DATE
    AND    A.IBACC_AUTH_ON IS NOT NULL;
  
    OS_LC_LIABILITY_AMT := OS_LC_LIABILITY_AMT - TEMP_AMT;
  
    SELECT NVL(SUM(IP.IBPAY_LC_LIAB_REVERSE_AMT), 0)
    INTO   TEMP_AMT
    FROM   IBILL IB, IBPAY IP
    WHERE  IB.IBILL_ENTITY_NUM = IP.IBPAY_ENTITY_NUM
    AND    IB.IBILL_BRN_CODE = IP.IBPAY_BRN_CODE
    AND    IB.IBILL_BILL_TYPE = IP.IBPAY_BILL_TYPE
    AND    IB.IBILL_BILL_YEAR = IP.IBPAY_BILL_YEAR
    AND    IB.IBILL_BILL_SL = IP.IBPAY_BILL_SL
    AND    IP.IBPAY_AUTH_BY IS NOT NULL
    AND    IBILL_ENTITY_NUM = P_ENTITYNUMBER
    AND    IBILL_BRN_CODE = P_BRANCH_CODE
    AND    IBILL_OLC_TYPE = P_LC_TYPE
    AND    IBILL_OLC_YEAR = P_LC_YEAR
    AND    IBILL_OLC_SL = P_LC_SL
    AND    IP.POST_TRAN_DATE <= P_AS_ON_DATE;
  
    OS_LC_LIABILITY_AMT := OS_LC_LIABILITY_AMT - TEMP_AMT;
  
    SELECT NVL(SUM(DECODE(O.OLCMNRV_DB_CR_FLG, 'D', -O.OLCMNRV_REV_AMT_BASE_CURR, O.OLCMNRV_REV_AMT_BASE_CURR)), 0)
    INTO   TEMP_AMT
    FROM   OLCMANREV O
    WHERE  O.OLCMNRV_ENTITY_NUM = P_ENTITYNUMBER
    AND    O.OLCMNRV_BRN_CODE = P_BRANCH_CODE
    AND    O.OLCMNRV_LC_TYPE = P_LC_TYPE
    AND    O.OLCMNRV_LC_YEAR = P_LC_YEAR
    AND    O.OLCMNRV_LC_SL = P_LC_SL
    AND    O.POST_TRAN_DATE <= P_AS_ON_DATE;
  
    OS_LC_LIABILITY_AMT := OS_LC_LIABILITY_AMT - TEMP_AMT;
    RETURN ROUND(OS_LC_LIABILITY_AMT, 2);
  END;

  FUNCTION GET_CASH_MARGIN_REC_AMT(P_ENTITYNUMBER NUMBER,
                                   P_BRANCH_CODE  NUMBER,
                                   P_LC_TYPE      VARCHAR2,
                                   P_LC_YEAR      NUMBER,
                                   P_LC_SL        NUMBER,
                                   P_AS_ON_DATE   DATE) RETURN NUMBER IS
    CASH_MARGIN_REC_AMT NUMBER(18, 3) := 0;
  BEGIN
    SELECT NVL(SUM(OLCCM_MRGN_AMT_RCVRY_CURR), 0) CASH_MARGIN_REC_AMT
    INTO   CASH_MARGIN_REC_AMT
    FROM   OLCCASHMAR O
    WHERE  O.OLCCM_ENTITY_NUM = P_ENTITYNUMBER
    AND    OLCCM_BRN_CODE = P_BRANCH_CODE
    AND    OLCCM_LC_TYPE = P_LC_TYPE
    AND    OLCCM_LC_YEAR = P_LC_YEAR
    AND    OLCCM_LC_SL = P_LC_SL
    AND    O.POST_TRAN_DATE <= P_AS_ON_DATE
    AND    OLCCM_AUTH_ON IS NOT NULL
    AND    O.OLCCM_IS_GRADUAL_MARGIN <> '1';
    RETURN NVL(CASH_MARGIN_REC_AMT, 0);
  END;

  FUNCTION GET_GRADUAL_CASH_MAR_REC_AMT(P_ENTITYNUMBER NUMBER,
                                        P_BRANCH_CODE  NUMBER,
                                        P_LC_TYPE      VARCHAR2,
                                        P_LC_YEAR      NUMBER,
                                        P_LC_SL        NUMBER,
                                        P_AS_ON_DATE   DATE) RETURN NUMBER IS
    GRADUAL_CASH_MARGIN_REC_AMT NUMBER(18, 3) := 0;
  BEGIN
    SELECT NVL(SUM(OLCCM_MRGN_AMT_RCVRY_CURR), 0) GRADUAL_CASH_MARGIN_REC_AMT
    INTO   GRADUAL_CASH_MARGIN_REC_AMT
    FROM   OLCCASHMAR O
    WHERE  O.OLCCM_ENTITY_NUM = P_ENTITYNUMBER
    AND    OLCCM_BRN_CODE = P_BRANCH_CODE
    AND    OLCCM_LC_TYPE = P_LC_TYPE
    AND    OLCCM_LC_YEAR = P_LC_YEAR
    AND    OLCCM_LC_SL = P_LC_SL
    AND    O.POST_TRAN_DATE <= P_AS_ON_DATE
    AND    OLCCM_AUTH_ON IS NOT NULL
    AND    O.OLCCM_IS_GRADUAL_MARGIN = '1';
  
    RETURN NVL(GRADUAL_CASH_MARGIN_REC_AMT, 0);
  END;

  FUNCTION GET_SG_MARGIN_REC_AMT(P_ENTITYNUMBER  NUMBER,
                                 P_BRANCH_CODE   NUMBER,
                                 P_LC_TYPE       VARCHAR2,
                                 P_LC_YEAR       NUMBER,
                                 P_LC_SL         NUMBER,
                                 P_AS_ON_DATE    DATE,
                                 P_BILL_WISE_REQ CHAR DEFAULT '0',
                                 P_BILL_BRN_CODE NUMBER DEFAULT 0,
                                 P_BILL_TYPE     VARCHAR2 DEFAULT '',
                                 P_BILL_YEAR     NUMBER DEFAULT 0,
                                 P_BILL_SERIAL   NUMBER DEFAULT 0) RETURN NUMBER IS
    SG_MARGIN_REC_AMT NUMBER(18, 3) := 0;
  BEGIN
    IF P_BILL_WISE_REQ = '1' THEN
      SELECT NVL(SUM(SGCM_MRGN_AMT_RCVRY_CURR), 0) SG_MARGIN_REC_AMT
      INTO   SG_MARGIN_REC_AMT
      FROM   IBILL IB, IBILLSG IBS, SGISS S, SGCASHMAR SGM
      WHERE  IB.IBILL_ENTITY_NUM = IBS.IBILLSG_ENTITY_NUM
      AND    IB.IBILL_BRN_CODE = IBS.IBILLSG_BRN_CODE
      AND    IB.IBILL_BILL_TYPE = IBS.IBILLSG_BILL_TYPE
      AND    IB.IBILL_BILL_YEAR = IBS.IBILLSG_BILL_YEAR
      AND    IB.IBILL_BILL_SL = IBS.IBILLSG_BILL_SL
      AND    IBS.IBILLSG_ENTITY_NUM = S.SG_ENTITY_NUM
      AND    IBS.IBILLSG_BRN_CODE = S.SG_BRN_CODE
      AND    IBS.IBILLSG_SG_TYPE = S.SG_CODE
      AND    IBS.IBILLSG_SG_YEAR = S.SG_YEAR
      AND    IBS.IBILLSG_SG_SL = S.SG_SERIAL
      AND    S.SG_ENTITY_NUM = SGM.SGCM_ENTITY_NUM
      AND    S.SG_BRN_CODE = SGM.SGCM_BRN_CODE
      AND    S.SG_CODE = SGM.SGCM_SG_TYPE
      AND    S.SG_YEAR = SGM.SGCM_SG_YEAR
      AND    S.SG_SERIAL = SGM.SGCM_SG_SL
      AND    S.SG_ENTITY_NUM = P_ENTITYNUMBER
      AND    S.SG_BRN_CODE = P_BRANCH_CODE
      AND    S.SG_OLC_TYPE = P_LC_TYPE
      AND    S.SG_OLC_YEAR = P_LC_YEAR
      AND    S.SG_OLC_SL = P_LC_SL
      AND    IBS.IBILLSG_BRN_CODE = P_BILL_BRN_CODE
      AND    IBS.IBILLSG_BILL_TYPE = P_BILL_TYPE
      AND    IBS.IBILLSG_BILL_YEAR = P_BILL_YEAR
      AND    IBS.IBILLSG_BILL_SL = P_BILL_SERIAL
      AND    SGM.POST_TRAN_DATE <= P_AS_ON_DATE
      AND    SGM.SGCM_AUTH_ON IS NOT NULL
      AND    SGM.SGCM_REJ_ON IS NULL;
    ELSE
      SELECT NVL(SUM(SGCM_MRGN_AMT_RCVRY_CURR), 0) SG_MARGIN_REC_AMT
      INTO   SG_MARGIN_REC_AMT
      FROM   SGISS S, SGCASHMAR M
      WHERE  S.SG_ENTITY_NUM = M.SGCM_ENTITY_NUM
      AND    S.SG_BRN_CODE = M.SGCM_BRN_CODE
      AND    S.SG_CODE = M.SGCM_SG_TYPE
      AND    S.SG_YEAR = M.SGCM_SG_YEAR
      AND    S.SG_SERIAL = M.SGCM_SG_SL
      AND    S.SG_ENTITY_NUM = P_ENTITYNUMBER
      AND    S.SG_BRN_CODE = P_BRANCH_CODE
      AND    S.SG_OLC_TYPE = P_LC_TYPE
      AND    S.SG_OLC_YEAR = P_LC_YEAR
      AND    S.SG_OLC_SL = P_LC_SL
      AND    M.POST_TRAN_DATE <= P_AS_ON_DATE
      AND    M.SGCM_AUTH_ON IS NOT NULL;
    END IF;
    RETURN NVL(SG_MARGIN_REC_AMT, 0);
  END;

  FUNCTION GET_EXPORT_CASH_MAR_REC_AMT(P_ENTITYNUMBER NUMBER,
                                       P_BRANCH_CODE  NUMBER,
                                       P_LC_TYPE      VARCHAR2,
                                       P_LC_YEAR      NUMBER,
                                       P_LC_SL        NUMBER,
                                       P_AS_ON_DATE   DATE) RETURN NUMBER IS
    EXPORT_CASH_MARGIN_REC_AMT NUMBER(18, 3) := 0;
  BEGIN
    SELECT SUM(NVL(OBD.OBFRMD_MARGIN_ADDED, 0)) EXPORT_CASH_MARGIN_REC_AMT
    INTO   EXPORT_CASH_MARGIN_REC_AMT
    FROM   OBFREEMARGIN OB, OBFREEMARGINDTL OBD
    WHERE  OB.OBFRM_ENTITY_NUM = OBD.OBFRMD_ENTITY_NUM
    AND    OB.OBFRM_BRN_CODE = OBD.OBFRMD_BRN_CODE
    AND    OB.OBFRM_CUST_CODE = OBD.OBFRMD_CUST_CODE
    AND    OB.OBFRM_ENTRY_SL = OBD.OBFRMD_ENTRY_SL
    AND    OBD.OBFRMD_ENTITY_NUM = P_ENTITYNUMBER
    AND    OBD.OBFRMD_LC_BRN_CODE = P_BRANCH_CODE
    AND    OBD.OBFRMD_LC_TYPE = P_LC_TYPE
    AND    OBD.OBFRMD_LC_YEAR = P_LC_YEAR
    AND    OBD.OBFRMD_LC_SL = P_LC_SL
    AND    OB.OBFRM_ENTRY_DATE <= P_AS_ON_DATE
    AND    OB.OBFRM_AUTH_ON IS NOT NULL;
    RETURN NVL(EXPORT_CASH_MARGIN_REC_AMT, 0);
  END;

  FUNCTION GET_TOT_CASH_MAR_RECOVER_AMT(P_ENTITYNUMBER NUMBER,
                                        P_BRANCH_CODE  NUMBER,
                                        P_LC_TYPE      VARCHAR2,
                                        P_LC_YEAR      NUMBER,
                                        P_LC_SL        NUMBER,
                                        P_AS_ON_DATE   DATE) RETURN NUMBER IS
    CASH_MAR_RECOVER_AMT NUMBER(18, 3) := 0;
  BEGIN
    CASH_MAR_RECOVER_AMT := GET_CASH_MARGIN_REC_AMT(P_ENTITYNUMBER, P_BRANCH_CODE, P_LC_TYPE, P_LC_YEAR, P_LC_SL, P_AS_ON_DATE) +
                            GET_GRADUAL_CASH_MAR_REC_AMT(P_ENTITYNUMBER, P_BRANCH_CODE, P_LC_TYPE, P_LC_YEAR, P_LC_SL, P_AS_ON_DATE) +
                            GET_SG_MARGIN_REC_AMT(P_ENTITYNUMBER, P_BRANCH_CODE, P_LC_TYPE, P_LC_YEAR, P_LC_SL, P_AS_ON_DATE) +
                            GET_EXPORT_CASH_MAR_REC_AMT(P_ENTITYNUMBER, P_BRANCH_CODE, P_LC_TYPE, P_LC_YEAR, P_LC_SL, P_AS_ON_DATE);
    RETURN NVL(CASH_MAR_RECOVER_AMT, 0);
  END;

  FUNCTION GET_CASH_MAR_RELEASE_AMT(P_ENTITYNUMBER NUMBER,
                                    P_BRANCH_CODE  NUMBER,
                                    P_LC_TYPE      VARCHAR2,
                                    P_LC_YEAR      NUMBER,
                                    P_LC_SL        NUMBER,
                                    P_AS_ON_DATE   DATE) RETURN NUMBER IS
    CASH_MARGIN_RELEASE_AMT NUMBER(18, 3) := 0;
  BEGIN
    SELECT NVL(SUM(OLCCMR_MRGN_AMT_PYMNT_CURR), 0) CASH_MARGIN_RELEASE_AMT
    INTO   CASH_MARGIN_RELEASE_AMT
    FROM   OLCCASHMARREL OCR
    WHERE  OCR.OLCCMR_ENTITY_NUM = P_ENTITYNUMBER
    AND    OLCCMR_BRN_CODE = P_BRANCH_CODE
    AND    OLCCMR_LC_TYPE = P_LC_TYPE
    AND    OLCCMR_LC_YEAR = P_LC_YEAR
    AND    OLCCMR_LC_SL = P_LC_SL
    AND    OCR.POST_TRAN_DATE <= P_AS_ON_DATE
    AND    OLCCMR_AUTH_ON IS NOT NULL;
    RETURN NVL(CASH_MARGIN_RELEASE_AMT, 0);
  END;

  FUNCTION GET_SG_MAR_RELEASE_AMT(P_ENTITYNUMBER  NUMBER,
                                  P_BRANCH_CODE   NUMBER,
                                  P_LC_TYPE       VARCHAR2,
                                  P_LC_YEAR       NUMBER,
                                  P_LC_SL         NUMBER,
                                  P_AS_ON_DATE    DATE,
                                  P_BILL_WISE_REQ CHAR DEFAULT '0',
                                  P_BILL_BRN_CODE NUMBER DEFAULT 0,
                                  P_BILL_TYPE     VARCHAR2 DEFAULT '',
                                  P_BILL_YEAR     NUMBER DEFAULT 0,
                                  P_BILL_SERIAL   NUMBER DEFAULT 0) RETURN NUMBER IS
    SG_MARGIN_RELEASE_AMT NUMBER(18, 3) := 0;
  BEGIN
    IF P_BILL_WISE_REQ = '1' THEN
      SELECT NVL(SUM(SGCMR_MRGN_AMT_RELEASED), 0) SG_MARGIN_RELEASE_AMT
      INTO   SG_MARGIN_RELEASE_AMT
      FROM   IBILL IB, IBILLSG IBS, SGISS S, SGCASHMARREL SGR
      WHERE  IB.IBILL_ENTITY_NUM = IBS.IBILLSG_ENTITY_NUM
      AND    IB.IBILL_BRN_CODE = IBS.IBILLSG_BRN_CODE
      AND    IB.IBILL_BILL_TYPE = IBS.IBILLSG_BILL_TYPE
      AND    IB.IBILL_BILL_YEAR = IBS.IBILLSG_BILL_YEAR
      AND    IB.IBILL_BILL_SL = IBS.IBILLSG_BILL_SL
      AND    IBS.IBILLSG_ENTITY_NUM = S.SG_ENTITY_NUM
      AND    IBS.IBILLSG_BRN_CODE = S.SG_BRN_CODE
      AND    IBS.IBILLSG_SG_TYPE = S.SG_CODE
      AND    IBS.IBILLSG_SG_YEAR = S.SG_YEAR
      AND    IBS.IBILLSG_SG_SL = S.SG_SERIAL
      AND    S.SG_ENTITY_NUM = SGR.SGCMR_ENTITY_NUM
      AND    S.SG_BRN_CODE = SGR.SGCMR_BRN_CODE
      AND    S.SG_CODE = SGR.SGCMR_TYPE
      AND    S.SG_YEAR = SGR.SGCMR_YEAR
      AND    S.SG_SERIAL = SGR.SGCMR_SL
      AND    S.SG_ENTITY_NUM = P_ENTITYNUMBER
      AND    S.SG_BRN_CODE = P_BRANCH_CODE
      AND    S.SG_OLC_TYPE = P_LC_TYPE
      AND    S.SG_OLC_YEAR = P_LC_YEAR
      AND    S.SG_OLC_SL = P_LC_SL
      AND    IBS.IBILLSG_BRN_CODE = P_BILL_BRN_CODE
      AND    IBS.IBILLSG_BILL_TYPE = P_BILL_TYPE
      AND    IBS.IBILLSG_BILL_YEAR = P_BILL_YEAR
      AND    IBS.IBILLSG_BILL_SL = P_BILL_SERIAL
      AND    SGR.POST_TRAN_DATE <= P_AS_ON_DATE
      AND    SGR.SGCMR_AUTH_ON IS NOT NULL
      AND    SGR.SGCMR_REJ_ON IS NULL;
    ELSE
      SELECT NVL(SUM(SGCMR_MRGN_AMT_RELEASED), 0) SG_MARGIN_RELEASE_AMT
      INTO   SG_MARGIN_RELEASE_AMT
      FROM   SGCASHMARREL R, SGISS S
      WHERE  R.SGCMR_ENTITY_NUM = S.SG_ENTITY_NUM
      AND    R.SGCMR_BRN_CODE = S.SG_BRN_CODE
      AND    R.SGCMR_TYPE = S.SG_CODE
      AND    R.SGCMR_YEAR = S.SG_YEAR
      AND    R.SGCMR_SL = S.SG_SERIAL
      AND    R.SGCMR_ENTITY_NUM = P_ENTITYNUMBER
      AND    S.SG_BRN_CODE = P_BRANCH_CODE
      AND    S.SG_OLC_TYPE = P_LC_TYPE
      AND    S.SG_OLC_YEAR = P_LC_YEAR
      AND    S.SG_OLC_SL = P_LC_SL
      AND    R.POST_TRAN_DATE <= P_AS_ON_DATE
      AND    R.SGCMR_AUTH_ON IS NOT NULL;
    END IF;
    RETURN NVL(SG_MARGIN_RELEASE_AMT, 0);
  END;

  FUNCTION GET_TOT_CASH_MAR_RELEASE_AMT(P_ENTITYNUMBER NUMBER,
                                        P_BRANCH_CODE  NUMBER,
                                        P_LC_TYPE      VARCHAR2,
                                        P_LC_YEAR      NUMBER,
                                        P_LC_SL        NUMBER,
                                        P_AS_ON_DATE   DATE) RETURN NUMBER IS
    CASH_MARGIN_RELEASE_AMT NUMBER(18, 3) := 0;
  BEGIN
    CASH_MARGIN_RELEASE_AMT := GET_CASH_MAR_RELEASE_AMT(P_ENTITYNUMBER, P_BRANCH_CODE, P_LC_TYPE, P_LC_YEAR, P_LC_SL, P_AS_ON_DATE) +
                               GET_SG_MAR_RELEASE_AMT(P_ENTITYNUMBER, P_BRANCH_CODE, P_LC_TYPE, P_LC_YEAR, P_LC_SL, P_AS_ON_DATE);
  
    RETURN NVL(CASH_MARGIN_RELEASE_AMT, 0);
  END;

  FUNCTION GET_LC_CASH_MARGIN_AMT_BAL(P_ENTITYNUMBER NUMBER,
                                      P_BRANCH_CODE  NUMBER,
                                      P_LC_TYPE      VARCHAR2,
                                      P_LC_YEAR      NUMBER,
                                      P_LC_SL        NUMBER,
                                      P_AS_ON_DATE   DATE) RETURN NUMBER IS
    CASH_MARGIN_AMT_BAL NUMBER(18, 3) := 0;
  BEGIN
    CASH_MARGIN_AMT_BAL := GET_TOT_CASH_MAR_RECOVER_AMT(P_ENTITYNUMBER, P_BRANCH_CODE, P_LC_TYPE, P_LC_YEAR, P_LC_SL, P_AS_ON_DATE) -
                           GET_TOT_CASH_MAR_RELEASE_AMT(P_ENTITYNUMBER, P_BRANCH_CODE, P_LC_TYPE, P_LC_YEAR, P_LC_SL, P_AS_ON_DATE);
    RETURN NVL(CASH_MARGIN_AMT_BAL, 0);
  END;

  FUNCTION GET_TOT_DEP_MAR_RECOVER_AMT(P_ENTITYNUMBER NUMBER,
                                       P_BRANCH_CODE  NUMBER,
                                       P_LC_TYPE      VARCHAR2,
                                       P_LC_YEAR      NUMBER,
                                       P_LC_SL        NUMBER,
                                       P_AS_ON_DATE   DATE) RETURN NUMBER IS
    DEP_MARGIN_RECOVER_AMT NUMBER(18, 3) := 0;
  BEGIN
    SELECT NVL(SUM(DM.OLCDEPMAR_LIEN_AMT_DEP_CURR), 0) DEP_MARGIN_RECOVER_AMT
    INTO   DEP_MARGIN_RECOVER_AMT
    FROM   OLCDEPMAR DM
    WHERE  DM.OLCDEPMAR_ENTITY_NUM = P_ENTITYNUMBER
    AND    DM.OLCDEPMAR_BRN_CODE = P_BRANCH_CODE
    AND    DM.OLCDEPMAR_LC_TYPE = P_LC_TYPE
    AND    DM.OLCDEPMAR_LC_YEAR = P_LC_YEAR
    AND    DM.OLCDEPMAR_LC_SL = P_LC_SL
    AND    DM.OLCDEPMAR_DATE_OF_ENTRY <= P_AS_ON_DATE
    AND    DM.OLCDEPMAR_AUTH_ON IS NOT NULL;
    RETURN NVL(DEP_MARGIN_RECOVER_AMT, 0);
  END;

  FUNCTION GET_TOT_DEP_MAR_RELEASE_AMT(P_ENTITYNUMBER NUMBER,
                                       P_BRANCH_CODE  NUMBER,
                                       P_LC_TYPE      VARCHAR2,
                                       P_LC_YEAR      NUMBER,
                                       P_LC_SL        NUMBER,
                                       P_AS_ON_DATE   DATE) RETURN NUMBER IS
    DEP_MARGIN_RELEASE_AMT NUMBER(18, 3) := 0;
  BEGIN
    SELECT NVL(SUM(OLCDEPMARR_REL_AMT), 0) DEP_MARGIN_RELEASE_AMT
    INTO   DEP_MARGIN_RELEASE_AMT
    FROM   OLCDEPMARREL DMR
    WHERE  DMR.OLCDEPMARR_ENTITY_NUM = P_ENTITYNUMBER
    AND    OLCDEPMARR_BRN_CODE = P_BRANCH_CODE
    AND    OLCDEPMARR_LC_TYPE = P_LC_TYPE
    AND    OLCDEPMARR_LC_YEAR = P_LC_YEAR
    AND    OLCDEPMARR_LC_SL = P_LC_SL
    AND    DMR.OLCDEPMARR_DATE_OF_ENTRY <= P_AS_ON_DATE
    AND    OLCDEPMARR_AUTH_ON IS NOT NULL;
    RETURN NVL(DEP_MARGIN_RELEASE_AMT, 0);
  END;

  FUNCTION GET_LC_DEP_MARGIN_AMT_BAL(P_ENTITYNUMBER NUMBER,
                                     P_BRANCH_CODE  NUMBER,
                                     P_LC_TYPE      VARCHAR2,
                                     P_LC_YEAR      NUMBER,
                                     P_LC_SL        NUMBER,
                                     P_AS_ON_DATE   DATE) RETURN NUMBER IS
    DEP_MARGIN_AMT_BAL NUMBER(18, 3) := 0;
  BEGIN
    DEP_MARGIN_AMT_BAL := GET_TOT_DEP_MAR_RECOVER_AMT(P_ENTITYNUMBER, P_BRANCH_CODE, P_LC_TYPE, P_LC_YEAR, P_LC_SL, P_AS_ON_DATE) -
                          GET_TOT_DEP_MAR_RELEASE_AMT(P_ENTITYNUMBER, P_BRANCH_CODE, P_LC_TYPE, P_LC_YEAR, P_LC_SL, P_AS_ON_DATE);
    RETURN NVL(DEP_MARGIN_AMT_BAL, 0);
  END;

  FUNCTION GET_TOT_SEC_MAR_RECOVER_AMT(P_ENTITYNUMBER NUMBER,
                                       P_BRANCH_CODE  NUMBER,
                                       P_LC_TYPE      VARCHAR2,
                                       P_LC_YEAR      NUMBER,
                                       P_LC_SL        NUMBER,
                                       P_AS_ON_DATE   DATE) RETURN NUMBER IS
    SEC_MARGIN_RECOVER_AMT NUMBER(18, 3) := 0;
  BEGIN
    SELECT NVL(SUM(O.OLCSECMAR_LIEN_AMT_MAR_CURR), 0) SEC_MARGIN_RECOVER_AMT
    INTO   SEC_MARGIN_RECOVER_AMT
    FROM   OLCSECMAR O
    WHERE  O.OLCSECMAR_ENTITY_NUM = P_ENTITYNUMBER
    AND    O.OLCSECMAR_BRN_CODE = P_BRANCH_CODE
    AND    O.OLCSECMAR_LC_TYPE = P_LC_TYPE
    AND    O.OLCSECMAR_LC_YEAR = P_LC_YEAR
    AND    O.OLCSECMAR_LC_SL = P_LC_SL
    AND    O.OLCSECMAR_DATE_OF_ENTRY <= P_AS_ON_DATE
    AND    O.OLCSECMAR_AUTH_ON IS NOT NULL;
    RETURN NVL(SEC_MARGIN_RECOVER_AMT, 0);
  END;

  FUNCTION GET_TOT_SEC_MAR_RELEASE_AMT(P_ENTITYNUMBER NUMBER,
                                       P_BRANCH_CODE  NUMBER,
                                       P_LC_TYPE      VARCHAR2,
                                       P_LC_YEAR      NUMBER,
                                       P_LC_SL        NUMBER,
                                       P_AS_ON_DATE   DATE) RETURN NUMBER IS
    SEC_MARGIN_RELEASE_AMT NUMBER(18, 3) := 0;
  BEGIN
    -- Currently No Option is available in Trade Finance to release security margin.
    -- It is available only in Core. So, Development is needed only if Client requires such feature.
    RETURN NVL(SEC_MARGIN_RELEASE_AMT, 0);
  END;

  FUNCTION GET_LC_SEC_MARGIN_AMT_BAL(P_ENTITYNUMBER NUMBER,
                                     P_BRANCH_CODE  NUMBER,
                                     P_LC_TYPE      VARCHAR2,
                                     P_LC_YEAR      NUMBER,
                                     P_LC_SL        NUMBER,
                                     P_AS_ON_DATE   DATE) RETURN NUMBER IS
    SEC_MARGIN_AMT_BAL NUMBER(18, 3) := 0;
  BEGIN
    SEC_MARGIN_AMT_BAL := GET_TOT_SEC_MAR_RECOVER_AMT(P_ENTITYNUMBER, P_BRANCH_CODE, P_LC_TYPE, P_LC_YEAR, P_LC_SL, P_AS_ON_DATE) -
                          GET_TOT_SEC_MAR_RELEASE_AMT(P_ENTITYNUMBER, P_BRANCH_CODE, P_LC_TYPE, P_LC_YEAR, P_LC_SL, P_AS_ON_DATE);
    RETURN NVL(SEC_MARGIN_AMT_BAL, 0);
  END;

  FUNCTION GET_TOT_MARGIN_RECOVER_AMT(P_ENTITYNUMBER NUMBER,
                                      P_BRANCH_CODE  NUMBER,
                                      P_LC_TYPE      VARCHAR2,
                                      P_LC_YEAR      NUMBER,
                                      P_LC_SL        NUMBER,
                                      P_AS_ON_DATE   DATE) RETURN NUMBER IS
    TOT_MARGIN_RECOVER_AMT NUMBER(18, 3) := 0;
  BEGIN
    TOT_MARGIN_RECOVER_AMT := GET_TOT_CASH_MAR_RECOVER_AMT(P_ENTITYNUMBER, P_BRANCH_CODE, P_LC_TYPE, P_LC_YEAR, P_LC_SL, P_AS_ON_DATE) +
                              GET_TOT_DEP_MAR_RECOVER_AMT(P_ENTITYNUMBER, P_BRANCH_CODE, P_LC_TYPE, P_LC_YEAR, P_LC_SL, P_AS_ON_DATE) +
                              GET_TOT_SEC_MAR_RECOVER_AMT(P_ENTITYNUMBER, P_BRANCH_CODE, P_LC_TYPE, P_LC_YEAR, P_LC_SL, P_AS_ON_DATE);
    RETURN NVL(TOT_MARGIN_RECOVER_AMT, 0);
  END;

  FUNCTION GET_TOT_MARGIN_RELEASE_AMT(P_ENTITYNUMBER NUMBER,
                                      P_BRANCH_CODE  NUMBER,
                                      P_LC_TYPE      VARCHAR2,
                                      P_LC_YEAR      NUMBER,
                                      P_LC_SL        NUMBER,
                                      P_AS_ON_DATE   DATE) RETURN NUMBER IS
    TOT_MARGIN_RELEASE_AMT NUMBER(18, 3) := 0;
  BEGIN
    TOT_MARGIN_RELEASE_AMT := GET_TOT_CASH_MAR_RELEASE_AMT(P_ENTITYNUMBER, P_BRANCH_CODE, P_LC_TYPE, P_LC_YEAR, P_LC_SL, P_AS_ON_DATE) +
                              GET_TOT_DEP_MAR_RELEASE_AMT(P_ENTITYNUMBER, P_BRANCH_CODE, P_LC_TYPE, P_LC_YEAR, P_LC_SL, P_AS_ON_DATE) +
                              GET_TOT_SEC_MAR_RELEASE_AMT(P_ENTITYNUMBER, P_BRANCH_CODE, P_LC_TYPE, P_LC_YEAR, P_LC_SL, P_AS_ON_DATE);
    RETURN NVL(TOT_MARGIN_RELEASE_AMT, 0);
  END;

  FUNCTION GET_LC_TOT_MARGIN_AMT_BAL(P_ENTITYNUMBER NUMBER,
                                     P_BRANCH_CODE  NUMBER,
                                     P_LC_TYPE      VARCHAR2,
                                     P_LC_YEAR      NUMBER,
                                     P_LC_SL        NUMBER,
                                     P_AS_ON_DATE   DATE) RETURN NUMBER IS
    LC_TOT_MARGIN_AMT_BAL NUMBER(18, 3) := 0;
  BEGIN
    LC_TOT_MARGIN_AMT_BAL := GET_TOT_MARGIN_RECOVER_AMT(P_ENTITYNUMBER, P_BRANCH_CODE, P_LC_TYPE, P_LC_YEAR, P_LC_SL, P_AS_ON_DATE) -
                             GET_TOT_MARGIN_RELEASE_AMT(P_ENTITYNUMBER, P_BRANCH_CODE, P_LC_TYPE, P_LC_YEAR, P_LC_SL, P_AS_ON_DATE);
    RETURN NVL(LC_TOT_MARGIN_AMT_BAL, 0);
  END;

END PKG_MARGIN_LIABILITY;
/
