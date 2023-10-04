DROP PACKAGE RBL_REPORT.PKG_SBS3_DATA_RETURN;

CREATE OR REPLACE PACKAGE RBL_REPORT.PKG_SBS3_DATA_RETURN IS

  TYPE REC_TYPE IS RECORD(
    DATED                 VARCHAR2(20),
    FI_ID                 NUMBER(2),
    FI_BRANCH_ID          VARCHAR2(8),
    SL_NO                 NUMBER(10),
    ACCOUNT_ID            IACLINK.IACLINK_ACTUAL_ACNUM%TYPE,
    DATE_OF_BIRTH         VARCHAR2 (10),
    GENDER_CODE           NUMBER (4),
    UNIQUE_ID             VARCHAR2 (100),
    E_TIN                 CLIENTS.CLIENTS_PAN_GIR_NUM%TYPE,
    E_BIN                 CLIENTS.CLIENTS_VIN_NUM%TYPE,
    NATURE_OF_LOAN        NUMBER(2),
    ECO_SECTOR_ID         VARCHAR2(20),
    ECO_PURPOSE_ID        VARCHAR2(20),
    COLLATERAL_ID         VARCHAR2(20),
    COLLATERAL_VALUE      VARCHAR2(20),
    LOAN_CLASS_ID         ASSETCD.ASSETCD_BSR_CODE%TYPE,
    INDUSTRY_SCALE_ID     NUMBER (18, 3),
    PRODUCT_TYPE_ID       ACNTS.ACNTS_PROD_CODE%TYPE,
    INTEREST_RATE         LNACIR.LNACIR_APPL_INT_RATE%TYPE,
    SANCTION_LIMIT        NUMBER (18,3),
    DISBURSEMENT_DATE     VARCHAR2 (20),
    EXPIRY_DATE           VARCHAR2 (20),
    OPENING_BALANCE       NUMBER(18,3),
    DISBURSED_AMOUNT      NUMBER(18,3),
    CHARGED_INTEREST      NUMBER(18,3),
    ACCRUED_INTEREST      NUMBER(18,3),
    OTHERS_BAL            NUMBER(18,3),
    RECOVERY_AMOUNT       NUMBER(18,3),
    WAIVER_AMOUNT         NUMBER(18,3),
    WRITE_OFF_AMOUNT      NUMBER(18,3),
    OUTSTANDING_AMOUNT    NUMBER(18,3),
    OVERDUE_AMOUNT        NUMBER(18,3)) ;



    V_BANK_CODE INSTALL.INS_OUR_BANK_CODE%TYPE ;


  TYPE REC_TAB IS TABLE OF REC_TYPE;

  FUNCTION GET_BRANCH_WISE(P_ENTITY_NUM NUMBER,
                           P_BRN_CODE   NUMBER,
                           P_FROM_DATE  DATE,
                           P_TO_DATE    DATE) RETURN REC_TAB
    PIPELINED;
  --RETURN VARCHAR2;

END PKG_SBS3_DATA_RETURN;

/

DROP PACKAGE BODY RBL_REPORT.PKG_SBS3_DATA_RETURN;

CREATE OR REPLACE PACKAGE BODY RBL_REPORT.PKG_SBS3_DATA_RETURN
IS
   TEMP_DATA                PKG_SBS3_DATA_RETURN.REC_TYPE;
   TEMP_DATA1               PKG_SBS3_DATA_RETURN.REC_TYPE;

   TYPE TEMP_RECORD IS RECORD
   (
      T_ACNTS_BRN_CODE              ACNTS.ACNTS_BRN_CODE%TYPE,
      T_AC_NUM                      ACNTS.ACNTS_INTERNAL_ACNUM%TYPE,
      T_CLIENT_CODE                 ACNTS.ACNTS_CLIENT_NUM%TYPE,
      T_CLIENT_PAN_GIR_NUM          CLIENTS.CLIENTS_PAN_GIR_NUM%TYPE,
      T_CLIENTS_VIN_NUM             CLIENTS.CLIENTS_VIN_NUM%TYPE,
      T_ACNTS_CURR_CODE             ACNTS.ACNTS_CURR_CODE%TYPE,
      T_CLIENTS_SECTOR_CODE         CLIENTS.CLIENTS_SEGMENT_CODE%TYPE,
      T_PROD_CODE                   PRODUCTS.PRODUCT_CODE%TYPE,
      T_INT_RATE                    NUMBER (8, 5),
      T_SECURITY_CODE               VARCHAR2 (100),
      T_DB_CR_TOTAL                 VARCHAR2 (1000),
      T_OD_AMT                      NUMBER (18, 3),
      T_PRODUCT_FOR_RUN_ACS         NUMBER,
      T_ACNTS_CLOSURE_DATE          DATE,
      T_ACNTS_OPENING_DATE          DATE);

   TYPE TABLEA IS TABLE OF TEMP_RECORD
      INDEX BY PLS_INTEGER;

   T_TEMP_REC               TABLEA;


       TYPE TEMP_GL_RECORD IS RECORD
   (
      T_AC_NUM                ACNTS.ACNTS_INTERNAL_ACNUM%TYPE,
      T_CLIENT_CODE           ACNTS.ACNTS_CLIENT_NUM%TYPE,
      T_AC_NAME               VARCHAR2 (200),
      T_CURR_CODE             ACNTS.ACNTS_CURR_CODE%TYPE,
      T_SECTOR_CODE           CLIENTS.CLIENTS_SEGMENT_CODE%TYPE,
      T_PROD_NAME             PRODUCTS.PRODUCT_NAME%TYPE,
      T_LOAN_CODE             RPTHEADGLDTL.RPTHDGLDTL_CODE%TYPE,
      T_PROD_CODE             PRODUCTS.PRODUCT_CODE%TYPE,
      T_INT_RATE              NUMBER (8, 5),
      T_SECURITY_CODE         VARCHAR2 (100),
      T_DB_CR_TOTAL           VARCHAR2 (1000),
      T_OD_AMT                NUMBER (18, 3),
      --T_OUTSTANDING_BAL       NUMBER (18, 3),
      T_BORROWER_CODE         CLIENTS.CLIENTS_BORROWER_CODE%TYPE,
      T_FIS_CODE              CLIENTS.CLIENTS_FIS_CODE%TYPE,
      T_PRODUCT_FOR_RUN_ACS   NUMBER,
      T_ACNTS_CLOSURE_DATE    DATE
   );

   TYPE TABLGL IS TABLE OF TEMP_GL_RECORD
      INDEX BY PLS_INTEGER;


   T_TEMPGL_REC               TABLGL;

   V_EXP_DATE               DATE;
   V_LIMIT_RESCH_DATE       DATE;
   V_LIMIT_RESCH_AMT        NUMBER (18, 3);
   V_DISB_AMT               NUMBER (18, 3);
   V_LIMIT_LINE_NUM         NUMBER (8);
   W_LIM_CLIENT             NUMBER (8);
   V_LIMIT_SAUTH_CODE       LIMITLINE.LMTLINE_SAUTH_CODE%TYPE;
   V_EFF_DATE               LIMITLINE.LMTLINE_LIMIT_EFF_DATE%TYPE;
   V_FIRST_SANC_LIMIT       NUMBER (18, 3);
   V_FIRST_SANC_DATE        VARCHAR2 (20);
   V_ENHNC_AMT              NUMBER (18, 3);
   W_COUNTER                NUMBER (4);
   V_APPROVAL_AUTH          VARCHAR2 (100);
   V_TEMP_FLAG              CHAR (1);
   V_NEWEAL_TIME            NUMBER (4);
   V_CBD                    DATE;
   V_GLOB_ENTITY_NUM        NUMBER;
   W_BRN_CODE               NUMBER (6);

   --Reschedule Account.
   V_IS_RESCHEDULE_ACC      CHAR (1);
   V_RESCHEDULE_AMT         NUMBER (18, 3);
   V_RESCHEDULE_SANC_DATE   DATE;
   V_DISBURSE_DATE          DATE;

   ---    LAD
   V_IS_LAD_ACC             BOOLEAN;
   W_INTERNAL_ACNUM         VARCHAR2 (20);
   W_ASON_DATE              DATE;
   W_TOT_SEC_AMT_AC         NUMBER (18, 3);
   W_TOT_SEC_AMT_BC         NUMBER (18, 3);
   W_SEC_NUM                VARCHAR2 (1000);
   W_SEC_AMT_ACNT_CURR      NUMBER (18, 3);

   W_SEC_TYPE               SECRCPT.SECRCPT_SEC_TYPE%TYPE;
   W_SEC_CURR_CODE          SECRCPT.SECRCPT_CURR_CODE%TYPE;
   W_SECURED_VALUE          SECRCPT.SECRCPT_SECURED_VALUE%TYPE;

   W_SEC_TYPE_STR           VARCHAR2 (1000);
   W_SEC_NUM_STR            VARCHAR2 (1000);
   W_REMARKS                VARCHAR2 (500);

   -- ALAM
   FUNCTION GET_LAD_SECURED_VALUE
      RETURN NUMBER
   IS
      W_PROD_CODE        VARCHAR2 (10) := '';

      W_DEP_ACC          VARCHAR2 (20) := '';
      W_ACC_BAL          NUMBER (18, 3) := 0;
      W_CNT              NUMBER := 0;
      W_BASE_CURR_CODE   VARCHAR2 (4);
   BEGIN
      V_IS_LAD_ACC := FALSE;
      W_CNT := 0;
      W_BASE_CURR_CODE := 'BDT';

      SELECT ACNTS_PROD_CODE
        INTO W_PROD_CODE
        FROM ACNTS A
       WHERE A.ACNTS_ENTITY_NUM = V_GLOB_ENTITY_NUM
       AND A.ACNTS_BRN_CODE = W_BRN_CODE
       AND A.ACNTS_INTERNAL_ACNUM = W_INTERNAL_ACNUM;

      SELECT COUNT (*)
        INTO W_CNT
        FROM LADPRODMAP LNMAP
       WHERE LNMAP.LADPRODMAP_PROD_CODE = W_PROD_CODE;

      --DBMS_OUTPUT.PUT_LINE(W_PROD_CODE || '  W_CNT = ' || W_CNT);

      IF W_CNT > 0
      THEN
         V_IS_LAD_ACC := TRUE;

        <<DEP_ACC_AMT>>
         BEGIN
            FOR DEP_ACC
               IN (SELECT LADDTL_DEP_ACNT_NUM
                     FROM LADACNTDTL LNDTL
                    WHERE LNDTL.LADDTL_ENTITY_NUM = V_GLOB_ENTITY_NUM
                    AND LNDTL.LADDTL_INTERNAL_ACNUM = W_INTERNAL_ACNUM)
            LOOP
               W_ACC_BAL :=
                    W_ACC_BAL
                  + FN_GET_ASON_ACBAL (1,
                                       DEP_ACC.LADDTL_DEP_ACNT_NUM,
                                       W_BASE_CURR_CODE,
                                       W_ASON_DATE,         -- NEEDS TO CHANGE
                                       V_CBD);              -- NEEDS TO CHANGE
            END LOOP;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               W_DEP_ACC := 0;
         END DEP_ACC_AMT;
      ELSE
         W_ACC_BAL := 0;
         V_IS_LAD_ACC := FALSE;
      END IF;

      RETURN W_ACC_BAL;
   END GET_LAD_SECURED_VALUE;

   --*****

  FUNCTION GET_ADDRESS (P_ACCOUNT_NUMBER NUMBER, P_ADDRESS_TYPE VARCHAR2)
       RETURN VARCHAR2
    AS
       V_TOTAL_ADDRESS   VARCHAR2 (200);
    BEGIN
       SELECT   REPLACE(ADDRDTLS_ADDR1
              || ADDRDTLS_ADDR2
              || ADDRDTLS_ADDR3
              || ADDRDTLS_ADDR4
              || ADDRDTLS_ADDR5, '-', ',')
         INTO V_TOTAL_ADDRESS
         FROM CLIENTS, ACNTS, ADDRDTLS
        WHERE     CLIENTS_CODE = ACNTS_CLIENT_NUM
              AND ACNTS_ENTITY_NUM = 1
              AND ACNTS_INTERNAL_ACNUM = P_ACCOUNT_NUMBER
              AND CLIENTS_ADDR_INV_NUM = ADDRDTLS_INV_NUM
              AND ADDRDTLS_ADDR_TYPE = P_ADDRESS_TYPE;
       RETURN V_TOTAL_ADDRESS;
    EXCEPTION
       WHEN OTHERS
       THEN
          RETURN '';
END GET_ADDRESS;

   FUNCTION GET_CL_DATE (P_ACCOUNT_NUMBER NUMBER, P_TO_DATE DATE)
      RETURN DATE
   AS
      V_CL_DATE   DATE;
   BEGIN
      SELECT NVL (MIN (ASSETCLSH_NPA_DATE), NULL)
        INTO V_CL_DATE
        FROM ASSETCLSHIST A
       WHERE     A.ASSETCLSH_ENTITY_NUM = 1
             AND A.ASSETCLSH_INTERNAL_ACNUM = P_ACCOUNT_NUMBER
             AND A.ASSETCLSH_EFF_DATE >
                    (SELECT NVL (MAX (ASSETCLSH_EFF_DATE), '01-JAN-1000')
                       FROM ASSETCLSHIST
                      WHERE     ASSETCLSH_ENTITY_NUM = 1
                            AND ASSETCLSH_INTERNAL_ACNUM = P_ACCOUNT_NUMBER
                            AND ASSETCLSH_EFF_DATE <= P_TO_DATE
                            AND ASSETCLSH_ASSET_CODE IN ('UC', 'SM'))
             AND A.ASSETCLSH_EFF_DATE <= P_TO_DATE;

      RETURN V_CL_DATE;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END GET_CL_DATE;


   FUNCTION GET_METHOD_OF_PAYMENT (P_ACCOUNT_NUMBER NUMBER)
      RETURN NUMBER
   AS
      V_MODE_OF_PAYMENT      NUMBER := 3;
      V_ACCOUNT_CREATED_BY   VARCHAR2 (8);
      V_OPENING_DATE         DATE;
      V_FIN_YEAR             NUMBER (4);
      V_SQL                  VARCHAR2 (2000);
   BEGIN
      SELECT ACNTS_OPENING_DATE, ACNTS_ENTD_BY
        INTO V_OPENING_DATE, V_ACCOUNT_CREATED_BY
        FROM ACNTS
       WHERE ACNTS_ENTITY_NUM = 1 AND ACNTS_INTERNAL_ACNUM = P_ACCOUNT_NUMBER;

      IF V_ACCOUNT_CREATED_BY = 'MIG'
      THEN
         V_MODE_OF_PAYMENT := 3;
      ELSE
         V_FIN_YEAR := TO_CHAR (V_OPENING_DATE, 'YYYY');

         BEGIN
            V_SQL :=
                  'SELECT T.TRAN_TYPE_OF_TRAN
  FROM TRAN'
               || V_FIN_YEAR
               || ' T, TRANADV'
               || V_FIN_YEAR
               || ' TT
 WHERE     T.TRAN_ENTITY_NUM = TT.TRANADV_ENTITY_NUM
       AND T.TRAN_BRN_CODE = TT.TRANADV_BRN_CODE
       AND T.TRAN_DATE_OF_TRAN = TT.TRANADV_DATE_OF_TRAN
       AND T.TRAN_BATCH_NUMBER = TT.TRANADV_BATCH_NUMBER
       AND T.TRAN_BATCH_SL_NUM = TT.TRANADV_BATCH_SL_NUM
       AND T.TRAN_ENTITY_NUM = 1
       AND T.TRAN_INTERNAL_ACNUM = :1
       AND (T.TRAN_DATE_OF_TRAN, T.TRAN_BATCH_NUMBER) IN
              (SELECT MIN (T1.TRAN_DATE_OF_TRAN), MIN (T1.TRAN_BATCH_NUMBER)
                 FROM TRAN'
               || V_FIN_YEAR
               || ' T1
                WHERE     T1.TRAN_ENTITY_NUM = 1
                      AND T1.TRAN_INTERNAL_ACNUM = :2
                      AND T1.TRAN_DB_CR_FLG = ''D'')
       AND T.TRAN_DB_CR_FLG = ''D''
       AND TT.TRANADV_PRIN_AC_AMT > 0';

            EXECUTE IMMEDIATE V_SQL
               INTO V_MODE_OF_PAYMENT
               USING P_ACCOUNT_NUMBER, P_ACCOUNT_NUMBER;
         EXCEPTION
            WHEN OTHERS
            THEN
               V_MODE_OF_PAYMENT := 3;
         END;
      END IF;

      RETURN V_MODE_OF_PAYMENT;
   END GET_METHOD_OF_PAYMENT;



   FUNCTION FN_GET_RUN_PRINCIPLE_ACBAL (V_ENTITY_NUM       IN NUMBER,
                                        P_INTERNAL_ACNUM   IN NUMBER,
                                        P_ASON_DATE        IN DATE)
      RETURN NUMBER
   IS
      V_ASON_AC_BAL   NUMBER (18, 3) := 0;
      W_MONTH         NUMBER (2);
      W_MON           CHAR (3);
      W_YEAR          NUMBER (4);
   BEGIN
      PKG_ENTITY.SP_SET_ENTITY_CODE (V_ENTITY_NUM);
      W_MONTH := TO_NUMBER (TO_CHAR (P_ASON_DATE + 1, 'mm'));
      W_YEAR := SP_GETFINYEAR (V_ENTITY_NUM, P_ASON_DATE + 1);


      SELECT ABS (ADVVDBBAL_PRIN_AC_OPBAL)
        INTO V_ASON_AC_BAL
        FROM ADVVDBBAL
       WHERE     ADVVDBBAL_ENTITY_NUM = 1
             AND ADVVDBBAL_INTERNAL_ACNUM = P_INTERNAL_ACNUM
             AND ADVVDBBAL_YEAR = W_YEAR
             AND ADVVDBBAL_MONTH = W_MONTH;

      RETURN V_ASON_AC_BAL;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 0;
   END FN_GET_RUN_PRINCIPLE_ACBAL;


   FUNCTION GET_RUNNING_ACCOUNT_DISB (V_ENTITY_NUM       IN NUMBER,
                                   P_INTERNAL_ACNUM   IN NUMBER,
                                   P_FROM_DATE           DATE,
                                   P_TO_DATE             DATE)
   RETURN NUMBER
AS
   V_OUT_CURR_BAL            NUMBER (18, 3);
   V_OUT_PREV_BAL            NUMBER (18, 3);
   V_INT_ON_THE_DATE_RANGE   NUMBER;
   V_RETURN_VALUE            NUMBER;
   V_SQL                     VARCHAR2 (3000);
BEGIN
   BEGIN
      V_SQL :=
         'SELECT
ABS((SELECT NVL(ACNTBBAL_BC_OPNG_CR_SUM - ACNTBBAL_BC_OPNG_DB_SUM, 0) FROM ACNTBBAL WHERE ACNTBBAL_ENTITY_NUM = :1
AND ACNTBBAL_INTERNAL_ACNUM = :P_AC_NUM
AND ACNTBBAL_CURR_CODE = ''BDT''
AND ACNTBBAL_YEAR = TO_NUMBER(TO_CHAR(:P_TO_DATE + 1, ''YYYY''))
AND ACNTBBAL_MONTH = TO_NUMBER(TO_CHAR(:P_TO_DATE + 1, ''MM'')))) CURRENT_OUTSTANDING  ,
ABS((SELECT NVL(ACNTBBAL_BC_OPNG_CR_SUM - ACNTBBAL_BC_OPNG_DB_SUM, 0) FROM ACNTBBAL WHERE ACNTBBAL_ENTITY_NUM = :1
AND ACNTBBAL_INTERNAL_ACNUM = :P_AC_NUM
AND ACNTBBAL_CURR_CODE = ''BDT''
AND ACNTBBAL_YEAR = TO_NUMBER(TO_CHAR(:P_FROM_DATE, ''YYYY''))
AND ACNTBBAL_MONTH = TO_NUMBER(TO_CHAR(:P_FROM_DATE, ''MM'')))) PREVIOUS_OUTSTANDING
FROM DUAL ';

      EXECUTE IMMEDIATE V_SQL
         INTO V_OUT_CURR_BAL, V_OUT_PREV_BAL
         USING V_ENTITY_NUM,
               P_INTERNAL_ACNUM,
               P_TO_DATE,
               P_TO_DATE,
               V_ENTITY_NUM,
               P_INTERNAL_ACNUM,
               P_FROM_DATE,
               P_FROM_DATE;
   EXCEPTION
      WHEN OTHERS
      THEN
         V_OUT_CURR_BAL := 0;
         V_OUT_PREV_BAL := 0;
   END;

   BEGIN
      SELECT SUM(ABS (LNINTAPPL_ACT_INT_AMT))
        INTO V_INT_ON_THE_DATE_RANGE
        FROM LNINTAPPL
       WHERE     LNINTAPPL_ENTITY_NUM = V_ENTITY_NUM
             AND LNINTAPPL_BRN_CODE= W_BRN_CODE
             AND LNINTAPPL_ACNT_NUM = P_INTERNAL_ACNUM
             AND LNINTAPPL_APPL_DATE >= P_FROM_DATE
             AND LNINTAPPL_APPL_DATE <= P_TO_DATE;
   EXCEPTION
      WHEN OTHERS
      THEN
         V_INT_ON_THE_DATE_RANGE := 0;
   END;

   V_RETURN_VALUE := V_OUT_CURR_BAL - V_OUT_PREV_BAL - V_INT_ON_THE_DATE_RANGE;

   IF V_RETURN_VALUE < 0
   THEN
      RETURN 0;
   ELSE
      RETURN V_RETURN_VALUE;
   END IF;
END GET_RUNNING_ACCOUNT_DISB;


   FUNCTION GET_DISB_AMT (P_AC_NUM           NUMBER,
                          P_RUN_CONT_FLAG    NUMBER,
                          P_FROM_DATE        DATE,
                          P_TO_DATE          DATE)
      RETURN NUMBER
   AS
      V_SQL                 VARCHAR2 (2000);
      V_TOTAL_DISB_AMOUNT   NUMBER;
   BEGIN
      IF P_RUN_CONT_FLAG = 1
      THEN
         --EXECUTE IMMEDIATE V_SQL INTO V_TOTAL_DISB_AMOUNT USING P_AC_NUM,P_TO_DATE, P_TO_DATE,P_AC_NUM,P_FROM_DATE, P_FROM_DATE ;
         V_TOTAL_DISB_AMOUNT := GET_RUNNING_ACCOUNT_DISB(V_GLOB_ENTITY_NUM, P_AC_NUM, P_FROM_DATE, P_TO_DATE);
           -- FN_GET_RUN_PRINCIPLE_ACBAL (1, P_AC_NUM, P_TO_DATE);
      ELSE
         SELECT SUM (LNACDISB_DISB_AMT)
           INTO V_TOTAL_DISB_AMOUNT
           FROM LNACDISB
          WHERE     LNACDISB_ENTITY_NUM = 1
                AND LNACDISB_INTERNAL_ACNUM = P_AC_NUM
                AND LNACDISB_DISB_ON <= P_TO_DATE
                AND LNACDISB_AUTH_BY IS NOT NULL;
      END IF;

      RETURN V_TOTAL_DISB_AMOUNT;
   END GET_DISB_AMT;


   FUNCTION GET_DEFAULT_STS (P_AC_NUM NUMBER)
      RETURN VARCHAR2
   AS
      V_DEFAULT_STS   VARCHAR2 (5);
   BEGIN
      BEGIN
         SELECT CASE WHEN COUNTER >= 1 THEN 'YES' ELSE 'NO' END DEFAULTER
           INTO V_DEFAULT_STS
           FROM (SELECT COUNT (1) COUNTER
                   FROM ASSETCLS AH
                  WHERE   AH.ASSETCLS_ENTITY_NUM = V_GLOB_ENTITY_NUM
                  AND  AH.ASSETCLS_INTERNAL_ACNUM = P_AC_NUM
                        AND AH.ASSETCLS_NPA_DATE IS NOT NULL);
      EXCEPTION
         WHEN OTHERS
         THEN
            V_DEFAULT_STS := 'NO';
      END;
      RETURN V_DEFAULT_STS;
   END GET_DEFAULT_STS;



   FUNCTION GET_DEFAULT_IN_LIFE (P_AC_NUM NUMBER)
      RETURN VARCHAR2
   AS
      V_DEFAULT_IN_LIFE   VARCHAR2 (5);
   BEGIN
      BEGIN
         SELECT CASE WHEN COUNTER >= 1 THEN 'YES' ELSE 'NO' END DEFAULTER
           INTO V_DEFAULT_IN_LIFE
           FROM (SELECT COUNT (1) COUNTER
                   FROM ASSETCLSHIST AH
                  WHERE   AH.ASSETCLSH_ENTITY_NUM = V_GLOB_ENTITY_NUM
                        AND  AH.ASSETCLSH_INTERNAL_ACNUM = P_AC_NUM
                        AND AH.ASSETCLSH_NPA_DATE IS NOT NULL);
      EXCEPTION
         WHEN OTHERS
         THEN
            V_DEFAULT_IN_LIFE := 'NO';
      END;

      RETURN V_DEFAULT_IN_LIFE;
   END GET_DEFAULT_IN_LIFE;


   FUNCTION GET_CUMULTV_RECOV (P_AC_NUM           NUMBER,
                               P_RUN_CONT_FLAG    NUMBER,
                               P_FROM_DATE        DATE,
                               P_TO_DATE          DATE,
                               P_EXP_DATE         DATE)
      RETURN NUMBER
   AS
      V_SQL                    VARCHAR2 (2000);
      V_CUMULTV_RECOV_AMOUNT   NUMBER := 0;
      V_CREDIT_BEFORE_EXPIRY   NUMBER;
      W_YEAR                   NUMBER;
   BEGIN
      IF P_RUN_CONT_FLAG = 1
      THEN
          IF P_EXP_DATE > P_TO_DATE THEN
                 V_SQL :=
                    'SELECT   (SELECT NVL (
                            (SELECT NVL (ACNTBBAL_BC_OPNG_CR_SUM, 0) CR
                               FROM ACNTBBAL
                              WHERE     ACNTBBAL_ENTITY_NUM = 1
                                    AND ACNTBBAL_INTERNAL_ACNUM = :1
                                    AND ACNTBBAL_YEAR =
                                           TO_NUMBER (TO_CHAR (:2 + 1, ''YYYY''))
                                    AND ACNTBBAL_MONTH =
                                           TO_NUMBER (TO_CHAR (:3 + 1, ''MM''))),
                            0)
                    FROM DUAL)
               - (SELECT NVL (
                            (SELECT NVL (ACNTBBAL_BC_OPNG_CR_SUM, 0) CR
                               FROM ACNTBBAL
                              WHERE     ACNTBBAL_ENTITY_NUM = 1
                                    AND ACNTBBAL_INTERNAL_ACNUM = :4
                                    AND ACNTBBAL_YEAR =
                                           TO_NUMBER (TO_CHAR (:5, ''YYYY''))
                                    AND ACNTBBAL_MONTH =
                                           TO_NUMBER (TO_CHAR (:6, ''MM''))),
                            0)
                    FROM DUAL)
                  TOTAL_RECOVERY_BALANCE
          FROM DUAL';

                 EXECUTE IMMEDIATE V_SQL
                    INTO V_CUMULTV_RECOV_AMOUNT
                    USING P_AC_NUM,
                          P_TO_DATE,
                          P_TO_DATE,
                          P_AC_NUM,
                          P_EXP_DATE,
                          P_EXP_DATE;

                 BEGIN
                    W_YEAR := TO_NUMBER (TO_CHAR (P_EXP_DATE, 'YYYY'));
                    V_SQL :=
                          'SELECT NVL( SUM(TRAN_AMOUNT), 0) FROM TRAN'
                       || W_YEAR
                       || ' WHERE TRAN_ENTITY_NUM = 1
        AND TRAN_INTERNAL_ACNUM = :1
        AND TRAN_DATE_OF_TRAN BETWEEN TRUNC( :2, ''MM'') AND :3
        AND TRAN_DB_CR_FLG = ''C''';

                    EXECUTE IMMEDIATE V_SQL
                       INTO V_CREDIT_BEFORE_EXPIRY
                       USING P_AC_NUM, P_EXP_DATE, P_EXP_DATE;
                 EXCEPTION
                    WHEN OTHERS
                    THEN
                       V_CREDIT_BEFORE_EXPIRY := 0;
                 END;

                 V_CUMULTV_RECOV_AMOUNT :=
                    V_CUMULTV_RECOV_AMOUNT - V_CREDIT_BEFORE_EXPIRY;
          END IF ;
      ELSE
         V_SQL :=
            'SELECT NVL (
          (SELECT NVL (ACNTBBAL_BC_OPNG_CR_SUM, 0) FROM_DATE_BALANCE
             FROM ACNTBBAL
            WHERE     ACNTBBAL_ENTITY_NUM = 1
                  AND ACNTBBAL_INTERNAL_ACNUM = :1
                  AND ACNTBBAL_YEAR = TO_NUMBER (TO_CHAR (:2 + 1, ''YYYY''))
                  AND ACNTBBAL_MONTH = TO_NUMBER (TO_CHAR (:3 + 1, ''MM''))),
          0)
          TOTAL_CREDIT
  FROM DUAL';

         EXECUTE IMMEDIATE V_SQL
            INTO V_CUMULTV_RECOV_AMOUNT
            USING P_AC_NUM, P_TO_DATE, P_TO_DATE;
      END IF;

      RETURN ABS(V_CUMULTV_RECOV_AMOUNT);
   END GET_CUMULTV_RECOV;

   FUNCTION GET_OUTSTANDING_BALANCE (P_AC_NUM NUMBER, P_FIN_YEAR NUMBER , P_FIN_MONTH NUMBER ) RETURN NUMBER
   AS
   V_OUTSTANDING_BAL NUMBER(18,3);
   BEGIN
   BEGIN

   SELECT NVL(NVL(ACNTBBAL_AC_OPNG_CR_SUM, 0) -
               NVL(ACNTBBAL_BC_OPNG_DB_SUM, 0),
               0) INTO V_OUTSTANDING_BAL
               FROM ACNTBBAL WHERE ACNTBBAL_ENTITY_NUM = 1
               AND ACNTBBAL_INTERNAL_ACNUM = P_AC_NUM
               AND ACNTBBAL_YEAR = P_FIN_YEAR
               AND ACNTBBAL_MONTH = P_FIN_MONTH;
   EXCEPTION WHEN OTHERS THEN
       V_OUTSTANDING_BAL := 0;
   END ;
   IF V_OUTSTANDING_BAL > 0 THEN
    V_OUTSTANDING_BAL := 0 ;
   END IF ;
   RETURN V_OUTSTANDING_BAL;
   END GET_OUTSTANDING_BALANCE ;


   FUNCTION GET_RECOVERY_FORMULA (P_AC_NUM           NUMBER,
                                  P_RUN_CONT_FLAG    NUMBER,
                                  P_FROM_DATE        DATE,
                                  P_TO_DATE          DATE,
                                  P_EXP_DATE         DATE)
      RETURN NUMBER
   AS
      V_SQL                    VARCHAR2 (2000);
      V_TOTAL_PRIN_CR_AMOUNT   NUMBER := 0;
      W_YEAR                   NUMBER (4);
      V_CREDIT_BEFORE_EXPIRY   NUMBER := 0;
   BEGIN
      IF P_RUN_CONT_FLAG = 1
      THEN
      /*
         IF P_TO_DATE < P_EXP_DATE
         THEN                        --- --- continious before expiry date----
            V_SQL :=
               'SELECT   (SELECT NVL (
                    (SELECT NVL (ACNTBBAL_BC_OPNG_CR_SUM, 0) - NVL (ACNTBBAL_BC_OPNG_DB_SUM, 0) FROM_DATE_BALANCE
                       FROM ACNTBBAL
                      WHERE     ACNTBBAL_ENTITY_NUM = 1
                            AND ACNTBBAL_INTERNAL_ACNUM = :1
                            AND ACNTBBAL_YEAR =
                                   TO_NUMBER (TO_CHAR (:2, ''YYYY''))
                            AND ACNTBBAL_MONTH =
                                   TO_NUMBER (TO_CHAR (:3, ''MM''))),
                    0)
            FROM DUAL)
       - (SELECT NVL (
                    (SELECT NVL (ACNTBBAL_BC_OPNG_CR_SUM, 0) - NVL (ACNTBBAL_BC_OPNG_DB_SUM, 0) TO_DATE_BALANCE
                       FROM ACNTBBAL
                      WHERE     ACNTBBAL_ENTITY_NUM = 1
                            AND ACNTBBAL_INTERNAL_ACNUM = :4
                            AND ACNTBBAL_YEAR =
                                   TO_NUMBER (TO_CHAR (:5 + 1, ''YYYY''))
                            AND ACNTBBAL_MONTH =
                                   TO_NUMBER (TO_CHAR (:6 + 1, ''MM''))),
                    0)
            FROM DUAL)
          TOTAL_RECOVERY_BALANCE
  FROM DUAL';

            EXECUTE IMMEDIATE V_SQL
               INTO V_TOTAL_PRIN_CR_AMOUNT
               USING P_AC_NUM,
                     P_FROM_DATE,
                     P_FROM_DATE,
                     P_AC_NUM,
                     P_TO_DATE,
                     P_TO_DATE;

            V_TOTAL_PRIN_CR_AMOUNT := (-1) * V_TOTAL_PRIN_CR_AMOUNT;

            IF V_TOTAL_PRIN_CR_AMOUNT < 0
            THEN
               V_TOTAL_PRIN_CR_AMOUNT := 0;
            END IF;
         ELSE  */
         IF P_TO_DATE > P_EXP_DATE    THEN                        --- continious after expiry date----
            V_SQL :=
               'SELECT   (SELECT NVL (
                    (SELECT NVL (ACNTBBAL_BC_OPNG_CR_SUM, 0) CR
                       FROM ACNTBBAL
                      WHERE     ACNTBBAL_ENTITY_NUM = 1
                            AND ACNTBBAL_INTERNAL_ACNUM = :1
                            AND ACNTBBAL_YEAR =
                                   TO_NUMBER (TO_CHAR (:2 + 1, ''YYYY''))
                            AND ACNTBBAL_MONTH =
                                   TO_NUMBER (TO_CHAR (:3 + 1, ''MM''))),
                    0)
            FROM DUAL)
       - (SELECT NVL (
                    (SELECT NVL (ACNTBBAL_BC_OPNG_CR_SUM, 0) CR
                       FROM ACNTBBAL
                      WHERE     ACNTBBAL_ENTITY_NUM = 1
                            AND ACNTBBAL_INTERNAL_ACNUM = :4
                            AND ACNTBBAL_YEAR =
                                   TO_NUMBER (TO_CHAR (:5, ''YYYY''))
                            AND ACNTBBAL_MONTH =
                                   TO_NUMBER (TO_CHAR (:6, ''MM''))),
                    0)
            FROM DUAL)
          TOTAL_RECOVERY_BALANCE
  FROM DUAL';

            EXECUTE IMMEDIATE V_SQL
               INTO V_TOTAL_PRIN_CR_AMOUNT
               USING P_AC_NUM,
                     P_TO_DATE,
                     P_TO_DATE,
                     P_AC_NUM,
                     P_EXP_DATE,
                     P_EXP_DATE;

            BEGIN
               W_YEAR := TO_NUMBER (TO_CHAR (P_EXP_DATE, 'YYYY'));
               V_SQL :=
                     'SELECT NVL( SUM(TRAN_AMOUNT), 0) FROM TRAN'
                  || W_YEAR
                  || ' WHERE TRAN_ENTITY_NUM = 1
AND TRAN_INTERNAL_ACNUM = :1
AND TRAN_DATE_OF_TRAN BETWEEN TRUNC( :2, ''MM'') AND :3
AND TRAN_DB_CR_FLG = ''C''';

               EXECUTE IMMEDIATE V_SQL
                  INTO V_CREDIT_BEFORE_EXPIRY
                  USING P_AC_NUM, P_EXP_DATE, P_EXP_DATE;
            EXCEPTION
               WHEN OTHERS
               THEN
                  V_CREDIT_BEFORE_EXPIRY := 0;
            END;

            V_TOTAL_PRIN_CR_AMOUNT :=
               V_TOTAL_PRIN_CR_AMOUNT - V_CREDIT_BEFORE_EXPIRY;
         END IF;
      ELSE                                                       --- term loan
         V_SQL :=
            'SELECT   (SELECT NVL (
                    (SELECT NVL (ACNTBBAL_BC_OPNG_CR_SUM, 0) CR
                       FROM ACNTBBAL
                      WHERE     ACNTBBAL_ENTITY_NUM = 1
                            AND ACNTBBAL_INTERNAL_ACNUM = :1
                            AND ACNTBBAL_YEAR =
                                   TO_NUMBER (TO_CHAR (:2 + 1, ''YYYY''))
                            AND ACNTBBAL_MONTH =
                                   TO_NUMBER (TO_CHAR (:3 + 1, ''MM''))),
                    0)
            FROM DUAL)
       - (SELECT NVL (
                    (SELECT NVL (ACNTBBAL_BC_OPNG_CR_SUM, 0) CR
                       FROM ACNTBBAL
                      WHERE     ACNTBBAL_ENTITY_NUM = 1
                            AND ACNTBBAL_INTERNAL_ACNUM = :4
                            AND ACNTBBAL_YEAR =
                                   TO_NUMBER (TO_CHAR (:5, ''YYYY''))
                            AND ACNTBBAL_MONTH =
                                   TO_NUMBER (TO_CHAR (:6, ''MM''))),
                    0)
            FROM DUAL)
          TOTAL_RECOVERY_BALANCE
  FROM DUAL';

         EXECUTE IMMEDIATE V_SQL
            INTO V_TOTAL_PRIN_CR_AMOUNT
            USING P_AC_NUM,
                  P_TO_DATE,
                  P_TO_DATE,
                  P_AC_NUM,
                  P_FROM_DATE,
                  P_FROM_DATE;
      END IF;

      RETURN ABS(V_TOTAL_PRIN_CR_AMOUNT);
   END GET_RECOVERY_FORMULA;



   FUNCTION GET_PRIN_DB_AMT (P_AC_NUM           NUMBER,
                          P_RUN_CONT_FLAG    NUMBER,
                          P_FROM_DATE        DATE,
                          P_TO_DATE          DATE)
   RETURN NUMBER
AS
   V_SQL                     VARCHAR2 (2000);
   V_TOTAL_PRIN_DB_AMOUNT    NUMBER;
   V_MAX_BAL_ON_DATE_RANGE   NUMBER;
   V_PREV_OUT_BAL NUMBER;
   V_INT_ON_THE_DATE_RANGE NUMBER ;
BEGIN
   IF P_RUN_CONT_FLAG = 1
   THEN
      BEGIN
         SELECT ABS (MIN (ACBALH_BC_BAL))
           INTO V_MAX_BAL_ON_DATE_RANGE
           FROM ACBALASONHIST_MAX_TRAN
          WHERE     ACBALH_ENTITY_NUM = V_GLOB_ENTITY_NUM
                AND ACBALH_INTERNAL_ACNUM = P_AC_NUM
                AND ACBALH_ASON_DATE >= P_FROM_DATE
                AND ACBALH_ASON_DATE <= P_TO_DATE;
      EXCEPTION
         WHEN OTHERS
         THEN
            SELECT ABS (ACBALH_BC_BAL)
              INTO V_MAX_BAL_ON_DATE_RANGE
              FROM ACBALASONHIST
             WHERE     ACBALH_ENTITY_NUM = V_GLOB_ENTITY_NUM
                   AND ACBALH_INTERNAL_ACNUM = P_AC_NUM
                   AND ACBALH_ASON_DATE =
                          (SELECT MAX (ACBALH_ASON_DATE)
                             FROM ACBALASONHIST
                            WHERE     ACBALH_ENTITY_NUM = V_GLOB_ENTITY_NUM
                                  AND ACBALH_INTERNAL_ACNUM = P_AC_NUM
                                  AND ACBALH_ASON_DATE <= P_FROM_DATE);


      END;

      BEGIN
      SELECT NVL (
                    (SELECT NVL (ACNTBBAL_BC_OPNG_CR_SUM, 0) - NVL (ACNTBBAL_BC_OPNG_DB_SUM, 0)
                       FROM ACNTBBAL
                      WHERE     ACNTBBAL_ENTITY_NUM = V_GLOB_ENTITY_NUM
                            AND ACNTBBAL_INTERNAL_ACNUM = P_AC_NUM
                            AND ACNTBBAL_YEAR =
                                   TO_NUMBER (TO_CHAR (P_FROM_DATE, 'YYYY'))
                            AND ACNTBBAL_MONTH =
                                   TO_NUMBER (TO_CHAR (P_FROM_DATE, 'MM'))),0) INTO V_PREV_OUT_BAL FROM DUAL;
      EXCEPTION WHEN OTHERS THEN
        V_PREV_OUT_BAL := 0 ;
      END ;
      V_PREV_OUT_BAL := ABS(V_PREV_OUT_BAL);

      BEGIN
      SELECT SUM(ABS (LNINTAPPL_ACT_INT_AMT))
        INTO V_INT_ON_THE_DATE_RANGE
        FROM LNINTAPPL
       WHERE     LNINTAPPL_ENTITY_NUM = V_GLOB_ENTITY_NUM
             AND LNINTAPPL_BRN_CODE= W_BRN_CODE
             AND LNINTAPPL_ACNT_NUM = P_AC_NUM
             AND LNINTAPPL_APPL_DATE >= P_FROM_DATE
             AND LNINTAPPL_APPL_DATE <= P_TO_DATE;
        EXCEPTION
      WHEN OTHERS
      THEN
         V_INT_ON_THE_DATE_RANGE := 0;
        END;

      V_TOTAL_PRIN_DB_AMOUNT := V_MAX_BAL_ON_DATE_RANGE - V_PREV_OUT_BAL - V_INT_ON_THE_DATE_RANGE;
   ELSE
      V_SQL :=
         'SELECT
        (SELECT NVL(
        (SELECT NVL(ADVBBAL_PRIN_AC_DB_OPBAL,0) CR FROM ADVBBAL
        WHERE ADVBBAL_ENTITY_NUM =1
        AND ADVBBAL_INTERNAL_ACNUM = :1
        AND ADVBBAL_YEAR = TO_NUMBER(TO_CHAR (:2+1,''YYYY''))
        AND ADVBBAL_MONTH = TO_NUMBER(TO_CHAR(:3+1,''MM'')) ),0) FROM DUAL ) -
        (SELECT NVL(
        (SELECT NVL(ADVBBAL_PRIN_AC_DB_OPBAL,0) CR FROM ADVBBAL
        WHERE ADVBBAL_ENTITY_NUM =1
        AND ADVBBAL_INTERNAL_ACNUM = :4
        AND ADVBBAL_YEAR = TO_NUMBER(TO_CHAR (:5,''YYYY''))
        AND ADVBBAL_MONTH = TO_NUMBER(TO_CHAR(:6,''MM'')) ),0) FROM DUAL) TOTAL_DEBIT_BALANCE FROM DUAL ';

      EXECUTE IMMEDIATE V_SQL
         INTO V_TOTAL_PRIN_DB_AMOUNT
         USING P_AC_NUM,
               P_TO_DATE,
               P_TO_DATE,
               P_AC_NUM,
               P_FROM_DATE,
               P_FROM_DATE;
   END IF;

   RETURN ABS (V_TOTAL_PRIN_DB_AMOUNT);
END GET_PRIN_DB_AMT;



   PROCEDURE GET_TOT_SEC_AMT_CBD
   IS
      V_LAD_SEC_AMT   NUMBER (18, 3);
   BEGIN
      W_SEC_TYPE_STR := '';
      W_SEC_NUM_STR := '';
      W_TOT_SEC_AMT_AC := 0;
      V_LAD_SEC_AMT := GET_LAD_SECURED_VALUE;

      IF V_IS_LAD_ACC
      THEN
         W_SEC_TYPE_STR := 'LAD';
         W_TOT_SEC_AMT_AC := V_LAD_SEC_AMT;
      ELSE
         FOR IDX_REC_SECBAL
            IN (SELECT SECAGMTBAL_ASSIGN_PERC, SECAGMTBAL_SEC_NUM
                  FROM SECASSIGNMTBAL
                 WHERE     SECAGMTBAL_ENTITY_NUM = 1
                       AND SECAGMTBAL_CLIENT_NUM = W_LIM_CLIENT
                       AND SECAGMTBAL_LIMIT_LINE_NUM = V_LIMIT_LINE_NUM)
         LOOP
            W_SEC_NUM := IDX_REC_SECBAL.SECAGMTBAL_SEC_NUM;

           <<FETCH_SECRCPT>>
            BEGIN
               SELECT SECRCPT_SEC_TYPE,
                      SECRCPT_CURR_CODE,
                      SECRCPT_SECURED_VALUE
                 INTO W_SEC_TYPE, W_SEC_CURR_CODE, W_SECURED_VALUE
                 FROM SECRCPT
                WHERE     SECRCPT_ENTITY_NUM = 1
                      AND SECRCPT_SECURITY_NUM = W_SEC_NUM;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  W_SECURED_VALUE := 0;
            END FETCH_SECRCPT;

            W_SEC_AMT_ACNT_CURR := W_SECURED_VALUE;
            W_TOT_SEC_AMT_AC := W_TOT_SEC_AMT_AC + W_SEC_AMT_ACNT_CURR;
            W_SEC_TYPE_STR := W_SEC_TYPE_STR || '  ' || W_SEC_TYPE || ' , ';
            W_SEC_NUM_STR := W_SEC_NUM_STR     --|| '  ' || W_SEC_NUM || ' , '
                                          ;
         END LOOP;
      END IF;
   END GET_TOT_SEC_AMT_CBD;


FUNCTION GET_PERIOD_OF_ARREAR (P_AC_NUM           NUMBER,
                               P_RUN_CONT_FLAG    NUMBER,
                               P_FROM_DATE        DATE,
                               P_TO_DATE          DATE,
                               P_EXP_DATE         DATE,
                               P_LNACRSDTL_REPAY_AMT NUMBER)
   RETURN NUMBER
AS
   V_PERIOD_OF_ARREAR   NUMBER;
   V_OD_DATE DATE ;
   V_OD_AMT NUMBER ;
BEGIN
   IF P_RUN_CONT_FLAG = '1'
   THEN
      V_PERIOD_OF_ARREAR := FLOOR (MONTHS_BETWEEN (P_TO_DATE, P_EXP_DATE ));

      IF V_PERIOD_OF_ARREAR < 0
      THEN
         V_PERIOD_OF_ARREAR := 0;
      END IF;
   ELSE
   BEGIN
      SELECT LNODHIST_OD_AMT INTO V_OD_AMT FROM LNODHIST L WHERE L.LNODHIST_ENTITY_NUM = V_GLOB_ENTITY_NUM
      AND L.LNODHIST_INTERNAL_ACNUM = P_AC_NUM
      AND L.LNODHIST_EFF_DATE = (
      SELECT MAX(LNODHIST_EFF_DATE) FROM LNODHIST WHERE LNODHIST_ENTITY_NUM = V_GLOB_ENTITY_NUM
      AND LNODHIST_INTERNAL_ACNUM = P_AC_NUM
      --AND LNODHIST_EFF_DATE <= P_TO_DATE
      );
      IF V_OD_AMT = 0 THEN
      RETURN 0;
      END IF ;
      V_PERIOD_OF_ARREAR := FLOOR (V_OD_AMT/P_LNACRSDTL_REPAY_AMT);
      EXCEPTION
      WHEN OTHERS THEN
      RETURN 0;
     END ;
   END IF;

   RETURN V_PERIOD_OF_ARREAR;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN 0;
END GET_PERIOD_OF_ARREAR;
--Added
 FUNCTION GET_SCHEME_CODE(P_ENTIY NUMBER, P_ACCOUNT_NUMBER NUMBER)
   RETURN VARCHAR2 AS
   V_ACNTS_AC_TYPE     VARCHAR2(5);
   V_ACNTS_AC_SUB_TYPE NUMBER(3) := 0;
   V_ACTYPE_DESCN      VARCHAR2(100);
   V_ACSUB_DESCN       VARCHAR2(100);

 BEGIN
   SELECT ACNTS_AC_TYPE, ACNTS_AC_SUB_TYPE, ACTYPE_DESCN
     INTO V_ACNTS_AC_TYPE, V_ACNTS_AC_SUB_TYPE, V_ACTYPE_DESCN
     FROM ACTYPES AP, ACNTS A
    WHERE A.ACNTS_ENTITY_NUM = P_ENTIY
      AND A.ACNTS_AC_TYPE = AP.ACTYPE_CODE
      AND A.ACNTS_INTERNAL_ACNUM = P_ACCOUNT_NUMBER;

   IF (V_ACNTS_AC_SUB_TYPE = 0) THEN
     RETURN V_ACTYPE_DESCN;
   ELSE
     SELECT ACSUB_DESCN
       INTO V_ACSUB_DESCN
       FROM ACSUBTYPES AP
      WHERE AP.ACSUB_ACTYPE_CODE = V_ACNTS_AC_TYPE
        AND AP.ACSUB_SUBTYPE_CODE = V_ACNTS_AC_SUB_TYPE;
     RETURN V_ACSUB_DESCN;
   END IF;
 EXCEPTION
   WHEN OTHERS THEN
     RETURN '';
 END GET_SCHEME_CODE;

--
   FUNCTION GET_BRANCH_WISE (P_ENTITY_NUM    NUMBER,
                             P_BRN_CODE      NUMBER,
                             P_FROM_DATE     DATE,
                             P_TO_DATE       DATE)
      RETURN REC_TAB
      PIPELINED
   IS
      ---RETURN VARCHAR2 IS
      V_WRTOFF_DATE                    DATE;
      V_WRTOFF_APPROVAL_AUTH           VARCHAR2 (100);
      W_SL_NO                          NUMBER := 0;
      V_CL_MIS_CODE                    VARCHAR2 (20);
      V_CL_ECO_CODE                    VARCHAR2 (20);
      V_CL_SME_CODE                    VARCHAR2 (20);
      V_CL_SEG_CODE                    VARCHAR2 (20);
      V_CL_SEC_CODE                    VARCHAR2 (20);

      V_LNACRSDTL_REPAY_FROM_DATE      DATE;
      V_LNACRSDTL_REPAY_FREQ           CHAR (1);
      V_LNACRSDTL_REPAY_AMT            NUMBER (18, 3);
      V_LNACRSDTL_NUM_OF_INSTALLMENT   NUMBER (5);
      V_NEXT_INSTLMNT_DATE             DATE;
      V_LAST_INSTLMNT_DATE             DATE;
      V_INSTLMNT_LEFT                  NUMBER (5);
      V_WRITEOFF_CHECK                 NUMBER;
      V_PREV_BRN_CODE                  MBRN.MBRN_CODE%TYPE;
      V_BRN_SBS_CODE                   MBRN.MBRN_BSR_CODE%TYPE;
      V_HO_DIVISION_NAME               MBRN.MBRN_NAME%TYPE;
      W_SQL_QUERY                      CLOB;
      V_FIN_YEAR                       NUMBER;
      V_FIN_MONTH                      NUMBER;
      V_FROM_DATE                      DATE;
      V_TO_DATE                        DATE;
      V_DEBIT_CASH                     NUMBER (18, 3);
      V_DEBIT_INT                      NUMBER (18, 3);
      V_DEBIT_OTHERS                   NUMBER (18, 3);
      V_CREDIT_CASH                    NUMBER (18, 3);
      V_CREDIT_INT                     NUMBER (18, 3);
      V_CREDIT_OTHERS                  NUMBER (18, 3);
      V_FIN_YEAR_TRAN                  NUMBER;
      V_FATHER_NAME                    VARCHAR2 (100);
      V_MOTHER_NAME                    VARCHAR2 (100);
      V_SPOUSE_NAME                    VARCHAR2 (100);
      V_CLIENTS_GENDER                 CHAR (1);
      V_CLIENTS_GENDER_CODE            NUMBER(4);
      V_DATE_OF_BIRTH                  VARCHAR2 (100);
      V_BIRTH_PLACE                    VARCHAR2 (100);
      V_CNTRY_CODE                     VARCHAR2 (10);
      V_BIRTH_COUNTRY                  VARCHAR2 (100);
      V_NID_NO                         VARCHAR2 (30);
      V_TIN_NO                         VARCHAR2 (30);
      V_OTHER_DOCU_TYP                 VARCHAR2 (30);
      V_OTHER_DOCU_NO                  VARCHAR2 (30);
      V_OTHER_DOCU_DATE                VARCHAR2 (30);
      V_OTHER_DOCU_CNTRY               VARCHAR2 (30);
      V_OCCUPN_CODE                    VARCHAR2 (6);
      V_EMPLOYEE_NUM                   VARCHAR2 (15);
      V_CLIENT_OCCUP                   VARCHAR2 (35);
      V_CNTRY_NAME                     VARCHAR2 (35);
      V_ADDR_TYPE                      VARCHAR2 (5);
      V_POST_CODE                      VARCHAR2 (6);
      V_MOBILE_NUM                     VARCHAR2 (15);
      V_LOC_NAME                       VARCHAR2 (50);
      V_DIST_NAME                      VARCHAR2 (50);
      V_CLASSIFICTN_CODE               ASSETCD.ASSETCD_BSR_CODE%TYPE;
      V_SCHEME_CODE                    LOANACNTS.LNACNT_PURPOSE_CODE%TYPE;
      V_PR_BAL                         NUMBER (18, 3);
      V_INT_BAL                        NUMBER (18, 3);
      V_OTH_BAL                        NUMBER (18, 3);
      V_NO_ENC                         NUMBER;
      V_ERROR                          VARCHAR2 (100);
      V_CLOSURE_DATE                   DATE ;
      V_ADDRESS_TEST                   VARCHAR2(200);
      W_DUMMY_BAL                      NUMBER(18,3);
      W_SUSP_ERR_MSG                   VARCHAR2(1000);
      W_DUMMY_SUSP_BAL                 NUMBER(18,3);
      V_RESCH_TIME                     NUMBER(3);
      V_RESCH_DATE                     DATE;
      V_RESCH_APPROV_AUTH              VARCHAR2(50);
      W_TOT_INT_DB_MIG                 NUMBER(18,3);
      W_TOT_INT_DB                     NUMBER(18,3);
      W_TOT_CHGS_DB                    NUMBER(18,3);
      V_AMT_PAID_SINCE_SANC            NUMBER(18,3);
      V_INST_FREQ_MULTP                NUMBER(18,3);
      V_PERIOD_OF_AREARS               NUMBER(18,3);
      V_TMP_PER_REPAY                  NUMBER(18,3);
      V_INT_RECV                       NUMBER(18,3);
      V_MAX_APPLIED_DATE               DATE ;
      V_FIRST_DAY_YEAR                 DATE ;
      OS_AMT NUMBER(18,3);
      SANC_LIMIT_AMT NUMBER(18,3);
      DP_AMT NUMBER(18,3);
      LIMIT_AMT NUMBER(18,3);
      OD_AMT NUMBER(18,3);
      OD_DATE1 VARCHAR2(20);
      PRIN_OD_AMT NUMBER(18,3);
      PRIN_OD_DATE1 VARCHAR2(20);
      INT_OD_AMT NUMBER(18,3);
      INT_OD_DATE1 VARCHAR2(20);
      CHGS_OD_AMT NUMBER(18,3);
      CHGS_OD_DATE1 VARCHAR2(20);
      ERROR_MSG VARCHAR2(1000);
      V_AFFAIR_CODE VARCHAR2(100);
      V_DISB_DATE   DATE;
      V_WRITE_OFF_AMT NUMBER(18,3);
      V_ACCRUED_INT_AMT NUMBER (18,3);
      V_NATURE_OF_LOAN  NUMBER(1);
      V_OPENING_BALANCE  NUMBER(18,3);
      V_START_ACCRUE_DATE DATE;
      V_BRANCH_ID         VARCHAR2(7 BYTE);
      V_RECOV_AMT         NUMBER(18,3);

   BEGIN
      PKG_ENTITY.SP_SET_ENTITY_CODE (P_ENTITY_NUM);
      V_GLOB_ENTITY_NUM := PKG_ENTITY.FN_GET_ENTITY_CODE;
      V_PREV_BRN_CODE := 0;
      V_FROM_DATE := TO_DATE (P_FROM_DATE, 'DD-MM-YYYY');
      V_TO_DATE := TO_DATE (P_TO_DATE, 'DD-MM-YYYY');
      W_ASON_DATE := TO_DATE (P_TO_DATE, 'DD-MM-YYYY');
      W_BRN_CODE := NVL (TRIM (P_BRN_CODE), 0);

      V_FIN_YEAR_TRAN := TO_CHAR (P_TO_DATE, 'YYYY');
      V_FIN_YEAR := TO_NUMBER (TO_CHAR (P_TO_DATE + 1, 'YYYY'));
      V_FIN_MONTH := TO_NUMBER (TO_CHAR (P_TO_DATE + 1, 'MM'));

      SELECT MN_CURR_BUSINESS_DATE INTO V_CBD FROM MAINCONT;

      SELECT INS_OUR_BANK_CODE INTO V_BANK_CODE
     FROM INSTALL  ;

      IF V_BANK_CODE = 200 THEN
          V_AFFAIR_CODE := 'F12';
      ELSE
          V_AFFAIR_CODE := 'RSOAB' ;
      END IF ;

      T_TEMP_REC.DELETE;

      W_SQL_QUERY :=
            ' SELECT A.ACNTS_BRN_CODE,
            A.ACNTS_INTERNAL_ACNUM,
       A.ACNTS_CLIENT_NUM,
       C.CLIENTS_PAN_GIR_NUM,
       C.CLIENTS_VIN_NUM,
       NVL(ACNTS_CURR_CODE, ''BDT''),
       NVL(C.CLIENTS_SEGMENT_CODE, '' ''),
       NVL(PRODUCT_CODE, ''0''),
       NVL(CASE
             WHEN (SELECT LNACIRS_AC_LEVEL_INT_REQD
                     FROM LNACIRS
                    WHERE LNACIRS_ENTITY_NUM = :V_ENTITY_NUM
                      AND LNACIRS_INTERNAL_ACNUM = A.ACNTS_INTERNAL_ACNUM) = ''1'' AND (SELECT INS_OUR_BANK_CODE FROM INSTALL ) = 200 THEN
              (SELECT LNACIR_APPL_INT_RATE
                 FROM LNACIR
                WHERE LNACIR_ENTITY_NUM = :V_ENTITY_NUM
                  AND LNACIR_INTERNAL_ACNUM = A.ACNTS_INTERNAL_ACNUM)
             WHEN (SELECT INS_OUR_BANK_CODE FROM INSTALL ) = 200 THEN
              (SELECT LL.LNPRODIRDTL_INT_RATE
                 FROM LNPRODIRDTL LL
                WHERE LNPRODIRDTL_ENTITY_NUM = :V_ENTITY_NUM
                  AND LL.LNPRODIRDTL_PROD_CODE = A.ACNTS_PROD_CODE
                  AND LL.LNPRODIRDTL_CURR_CODE = A.ACNTS_CURR_CODE
                  AND LL.LNPRODIRDTL_AC_TYPE = A.ACNTS_AC_TYPE
                  AND LL.LNPRODIRDTL_AC_SUB_TYPE = A.ACNTS_AC_SUB_TYPE)
           END,
           0),
       NVL(TRIM(FN_GET_SECURITY_CODE(:V_ENTITY_NUM,
                                             A.ACNTS_CLIENT_NUM,
                                             A.ACNTS_BRN_CODE,
                                             A.ACNTS_INTERNAL_ACNUM,
                                             A.ACNTS_PROD_CODE)),
           '' ''),
           (SELECT TO_CHAR(NVL(SUM(CASE
                         WHEN TR.TRAN_DB_cR_FLG = ''D'' AND TR.TRAN_TYPE_OF_TRAN = 3 THEN
                          TRA.TRANADV_PRIN_AC_AMT
                         ELSE
                          0
                       END),
                   0)) || ''A'' ||

               TO_CHAR(NVL(SUM(CASE
                         WHEN TR.TRAN_DB_cR_FLG = ''D'' THEN
                          TRA.TRANADV_INTRD_AC_AMT
                         ELSE
                          0
                       END),
                   0)) || ''B'' ||
               TO_CHAR(NVL((SUM(CASE
                          WHEN TR.TRAN_DB_cR_FLG = ''D'' THEN
                           TRA.TRANADV_CHARGE_AC_AMT
                          ELSE
                           0
                        END) + SUM(CASE
                                      WHEN TR.TRAN_DB_cR_FLG = ''D'' THEN
                                       TRA.TRANADV_PRIN_AC_AMT
                                      ELSE
                                       0
                                    END) -
                   SUM(CASE
                          WHEN TR.TRAN_DB_cR_FLG = ''D'' AND TR.TRAN_TYPE_OF_TRAN = 3 THEN
                           TRA.TRANADV_PRIN_AC_AMT
                          ELSE
                           0
                        END)),
                   0)) || ''C'' || TO_CHAR(NVL(SUM(CASE
                                          WHEN TR.TRAN_DB_cR_FLG = ''C'' AND TR.TRAN_TYPE_OF_TRAN = 3 THEN
                                           TRA.TRANADV_PRIN_AC_AMT
                                          ELSE
                                           0
                                        END),
                                    0)) || ''D'' ||
               TO_CHAR(NVL(SUM(CASE
                         WHEN TR.TRAN_DB_cR_FLG = ''C'' THEN
                          TRA.TRANADV_INTRD_AC_AMT
                         ELSE
                          0
                       END),
                   0)) || ''E'' || TO_CHAR(NVL((SUM(CASE
                                           WHEN TR.TRAN_DB_cR_FLG = ''C'' THEN
                                            TRA.TRANADV_CHARGE_AC_AMT
                                           ELSE
                                            0
                                         END) ),
                                    0)) || ''F''
              FROM TRANADV'
         || V_FIN_YEAR_TRAN
         || ' TRA , TRAN'
         || V_FIN_YEAR_TRAN
         || '  TR
         WHERE TRA.TRANADV_ENTITY_NUM = :V_ENTITY_NUM
        AND TR.TRAN_ENTITY_NUM = :V_ENTITY_NUM
           AND TRA.TRANADV_BRN_CODE = TR.TRAN_ACING_BRN_CODE
           AND TRA.TRANADV_DATE_OF_TRAN = TR.TRAN_DATE_OF_TRAN
           AND TRA.TRANADV_BATCH_NUMBER = TR.TRAN_BATCH_NUMBER
           AND TRA.TRANADV_BATCH_SL_NUM = TR.TRAN_BATCH_SL_NUM
           AND TRA.TRANADV_BRN_CODE = A.ACNTS_BRN_CODE
           AND TR.TRAN_INTERNAL_ACNUM = A.ACNTS_INTERNAL_ACNUM
           AND TR.TRAN_DATE_OF_TRAN BETWEEN :V_FROM_DATE AND :V_TO_DATE
           AND TR.TRAN_AUTH_ON IS NOT NULL
           AND (NVL(TR.TRAN_AC_CANCEL_AMT, 0) = 0 OR
               NVL(TR.TRAN_BC_CANCEL_AMT, 0) = 0)),
       NVL((SELECT LNOD_OD_AMT
             FROM LNOD
            WHERE LNOD_ENTITY_NUM = :V_ENTITY_NUM
              AND LNOD_INTERNAL_ACNUM = A.ACNTS_INTERNAL_ACNUM),
           0),
       PRODUCT_FOR_RUN_ACS,
       A.ACNTS_CLOSURE_DATE,
       A.ACNTS_OPENING_DATE
  FROM PRODUCTS P, ACNTS A, CLIENTS C, LOANACNTS--, ACNTBBAL Q
 WHERE A.ACNTS_ENTITY_NUM = :V_ENTITY_NUM
   AND LNACNT_ENTITY_NUM = A.ACNTS_ENTITY_NUM
   AND LNACNT_INTERNAL_ACNUM = A.ACNTS_INTERNAL_ACNUM
   AND P.PRODUCT_CODE = A.ACNTS_PROD_CODE
   AND P.PRODUCT_FOR_LOANS = ''1''
   AND C.CLIENTS_CODE = A.ACNTS_CLIENT_NUM
   AND A.ACNTS_AUTH_ON IS NOT NULL
   AND (A.ACNTS_CLOSURE_DATE IS NULL OR A.ACNTS_CLOSURE_DATE >= :V_FROM_DATE)';

      IF W_BRN_CODE <> 0
      THEN
         W_SQL_QUERY :=
            W_SQL_QUERY || TO_CLOB (' AND A.ACNTS_BRN_CODE = ' || W_BRN_CODE);
      END IF;


      W_SQL_QUERY :=
            W_SQL_QUERY
         || TO_CLOB (
               ' ORDER BY A.ACNTS_BRN_CODE, A.ACNTS_INTERNAL_ACNUM , P.PRODUCT_CODE ');

      --dbms_output.put_line (W_SQL_QUERY);

      EXECUTE IMMEDIATE W_SQL_QUERY
         BULK COLLECT INTO T_TEMP_REC
         USING V_GLOB_ENTITY_NUM,
               V_GLOB_ENTITY_NUM,
               V_GLOB_ENTITY_NUM,
               V_GLOB_ENTITY_NUM,
               V_GLOB_ENTITY_NUM,
               V_GLOB_ENTITY_NUM,
               P_FROM_DATE,
               P_TO_DATE,
               V_GLOB_ENTITY_NUM,
               V_GLOB_ENTITY_NUM,
               P_FROM_DATE;

      IF T_TEMP_REC.FIRST IS NOT NULL
      THEN
         FOR REC IN T_TEMP_REC.FIRST .. T_TEMP_REC.LAST
         LOOP

            V_WRITEOFF_CHECK := 0;
            V_CLOSURE_DATE := '' ;

            SELECT COUNT(*)
               INTO V_WRITEOFF_CHECK
               FROM LNWRTOFF
              WHERE LNWRTOFF_ENTITY_NUM = V_GLOB_ENTITY_NUM
              AND LNWRTOFF_ACNT_NUM = T_TEMP_REC(REC).T_AC_NUM;


            V_LIMIT_SAUTH_CODE := NULL;
            V_APPROVAL_AUTH := NULL;
            W_SL_NO := W_SL_NO + 1;
            W_LIM_CLIENT := T_TEMP_REC (REC).T_CLIENT_CODE;
            W_INTERNAL_ACNUM := T_TEMP_REC (REC).T_AC_NUM;
            V_CLOSURE_DATE := T_TEMP_REC (REC).T_ACNTS_CLOSURE_DATE ;


            TEMP_DATA.DATED := TO_CHAR(P_TO_DATE, 'DD-MM-YYYY');

            IF V_BANK_CODE = 200 THEN
               TEMP_DATA.FI_ID := 15;
            ELSE
               TEMP_DATA.FI_ID := 14;
            END IF ;

        --FI BRANCH ID

           IF V_BANK_CODE = 200

           THEN
            SELECT SUBSTR(M.MBRN_BSR_CODE,3)
            INTO V_BRN_SBS_CODE
            FROM MBRN M
            WHERE M.MBRN_ENTITY_NUM=V_GLOB_ENTITY_NUM
            AND M.MBRN_CODE = W_BRN_CODE;

           TEMP_DATA.FI_BRANCH_ID:= V_BRN_SBS_CODE;

           ELSE
             SELECT M.MBRN_BSR_CODE
             INTO V_BRN_SBS_CODE
             FROM MBRN M
             WHERE M.MBRN_ENTITY_NUM=V_GLOB_ENTITY_NUM
             AND M.MBRN_CODE = W_BRN_CODE;

            TEMP_DATA.FI_BRANCH_ID := V_BRN_SBS_CODE;

           END IF ;

            --TEMP_DATA.FI_BRANCH_ID := '015' || TO_CHAR(T_TEMP_REC (REC).T_ACNTS_BRN_CODE);  --Need to change here

            TEMP_DATA.SL_NO := W_SL_NO;

            TEMP_DATA.ACCOUNT_ID := FACNO (1, W_INTERNAL_ACNUM) ;

            TEMP_DATA.PRODUCT_TYPE_ID := T_TEMP_REC (REC).T_PROD_CODE;

            TEMP_DATA.ECO_SECTOR_ID := T_TEMP_REC (REC).T_CLIENTS_SECTOR_CODE;

            TEMP_DATA.UNIQUE_ID := TRIM(SUBSTR(FN_GET_PIDWITHTYPE ( W_LIM_CLIENT ), INSTR(FN_GET_PIDWITHTYPE ( W_LIM_CLIENT ), '-') + 1));

            TEMP_DATA.E_TIN := T_TEMP_REC (REC).T_CLIENT_PAN_GIR_NUM;

            TEMP_DATA.E_BIN := T_TEMP_REC (REC).T_CLIENTS_VIN_NUM;

            GET_TOT_SEC_AMT_CBD;

            TEMP_DATA.COLLATERAL_VALUE := W_TOT_SEC_AMT_AC;


          IF V_BANK_CODE = 200 THEN
                TEMP_DATA.INTEREST_RATE := T_TEMP_REC (REC).T_INT_RATE;
          ELSE
            PKG_LOANINTRATEASON.SP_LOANINTRATEASON(V_GLOB_ENTITY_NUM, W_INTERNAL_ACNUM,P_TO_DATE, 1);
            TEMP_DATA.INTEREST_RATE := PKG_LOANINTRATEASON.V_SINGLE_INT_RATE;

          END IF ;

			TEMP_DATA.COLLATERAL_ID := T_TEMP_REC (REC).T_SECURITY_CODE;

            TEMP_DATA.OUTSTANDING_AMOUNT := ABS(GET_OUTSTANDING_BALANCE(W_INTERNAL_ACNUM,V_FIN_YEAR, V_FIN_MONTH));

			OD_AMT:=FN_GET_OD_AMT(V_GLOB_ENTITY_NUM, W_INTERNAL_ACNUM, P_TO_DATE, V_CBD);
            TEMP_DATA.OVERDUE_AMOUNT := OD_AMT;


            SELECT SUBSTR (T_TEMP_REC (REC).T_DB_CR_TOTAL,
                           1,
                           INSTR (T_TEMP_REC (REC).T_DB_CR_TOTAL, 'A') - 1),
                   SUBSTR (
                      T_TEMP_REC (REC).T_DB_CR_TOTAL,
                      INSTR (T_TEMP_REC (REC).T_DB_CR_TOTAL, 'A') + 1,
                        INSTR (T_TEMP_REC (REC).T_DB_CR_TOTAL, 'B')
                      - INSTR (T_TEMP_REC (REC).T_DB_CR_TOTAL, 'A')
                      - 1),
                   SUBSTR (
                      T_TEMP_REC (REC).T_DB_CR_TOTAL,
                      INSTR (T_TEMP_REC (REC).T_DB_CR_TOTAL, 'B') + 1,
                        INSTR (T_TEMP_REC (REC).T_DB_CR_TOTAL, 'C')
                      - INSTR (T_TEMP_REC (REC).T_DB_CR_TOTAL, 'B')
                      - 1),
                   SUBSTR (
                      T_TEMP_REC (REC).T_DB_CR_TOTAL,
                      INSTR (T_TEMP_REC (REC).T_DB_CR_TOTAL, 'C') + 1,
                        INSTR (T_TEMP_REC (REC).T_DB_CR_TOTAL, 'D')
                      - INSTR (T_TEMP_REC (REC).T_DB_CR_TOTAL, 'C')
                      - 1),
                   SUBSTR (
                      T_TEMP_REC (REC).T_DB_CR_TOTAL,
                      INSTR (T_TEMP_REC (REC).T_DB_CR_TOTAL, 'D') + 1,
                        INSTR (T_TEMP_REC (REC).T_DB_CR_TOTAL, 'E')
                      - INSTR (T_TEMP_REC (REC).T_DB_CR_TOTAL, 'D')
                      - 1),
                   SUBSTR (
                      T_TEMP_REC (REC).T_DB_CR_TOTAL,
                      INSTR (T_TEMP_REC (REC).T_DB_CR_TOTAL, 'E') + 1,
                        INSTR (T_TEMP_REC (REC).T_DB_CR_TOTAL, 'F')
                      - INSTR (T_TEMP_REC (REC).T_DB_CR_TOTAL, 'E')
                      - 1)
              INTO V_DEBIT_CASH,
                   V_DEBIT_INT,
                   V_DEBIT_OTHERS,
                   V_CREDIT_CASH,
                   V_CREDIT_INT,
                   V_CREDIT_OTHERS
              FROM DUAL;

              TEMP_DATA.CHARGED_INTEREST := V_DEBIT_INT;

            -- LIMIT LINE
            BEGIN
               SELECT LMTLINE_DATE_OF_SANCTION,
                      LMTLINE_SANCTION_AMT,
                      LMTLINE_LIMIT_EXPIRY_DATE,
                      LMTLINE_NUM,
                      LMTLINE_SAUTH_CODE
                 INTO V_LIMIT_RESCH_DATE,
                      V_LIMIT_RESCH_AMT,
                      V_EXP_DATE,
                      V_LIMIT_LINE_NUM,
                      V_LIMIT_SAUTH_CODE
                 FROM LIMITLINE
                WHERE     LMTLINE_CLIENT_CODE =
                             T_TEMP_REC (REC).T_CLIENT_CODE
                      AND LIMITLINE.LMTLINE_NUM =
                             (SELECT ACASLLDTL.ACASLLDTL_LIMIT_LINE_NUM
                                FROM ACASLLDTL
                               WHERE ACASLLDTL_INTERNAL_ACNUM =
                                        W_INTERNAL_ACNUM);

               TEMP_DATA.EXPIRY_DATE := TO_CHAR (TO_DATE(V_EXP_DATE), 'DD-MM-YYYY');
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  TEMP_DATA.EXPIRY_DATE := ' ';
                  V_LIMIT_RESCH_DATE := NULL;
                  V_LIMIT_RESCH_AMT := 0;
                  V_EXP_DATE := NULL;
                  V_LIMIT_LINE_NUM := NULL;
            END;

            BEGIN
               SELECT SAUTH_NAME
                 INTO V_APPROVAL_AUTH
                 FROM SAUTH
                WHERE     SAUTH_ENTITY_NUM = V_GLOB_ENTITY_NUM
                      AND SAUTH_CODE = V_LIMIT_SAUTH_CODE;
            EXCEPTION
               WHEN OTHERS
               THEN
                  V_APPROVAL_AUTH := NULL;
            END;


            V_APPROVAL_AUTH := NULL;
            V_LIMIT_SAUTH_CODE := NULL;

            -- END

            -- LIMITLINEHIST
            BEGIN
               SELECT COUNT (1)
                 INTO W_COUNTER
                 FROM LIMITLINEHIST
                WHERE   LIMLNEHIST_ENTITY_NUM = V_GLOB_ENTITY_NUM
                AND  LIMLNEHIST_CLIENT_CODE =
                             T_TEMP_REC (REC).T_CLIENT_CODE
                      AND LIMLNEHIST_LIMIT_LINE_NUM =
                             (SELECT ACASLLDTL.ACASLLDTL_LIMIT_LINE_NUM
                                FROM ACASLLDTL
                               WHERE ACASLLDTL_ENTITY_NUM = V_GLOB_ENTITY_NUM
                               AND ACASLLDTL_INTERNAL_ACNUM =
                                        W_INTERNAL_ACNUM)
                      AND LIMLNEHIST_EFF_DATE <= P_TO_DATE;

               IF W_COUNTER > 1
               THEN
                  V_NEWEAL_TIME := W_COUNTER - 1;

                  SELECT LIMLNEHIST_SAUTH_CODE,
                         LIMLNEHIST_EFF_DATE,
                         MIN_SANC_AMT,
                         MIN_SANC_DATE
                    INTO V_LIMIT_SAUTH_CODE,
                         V_EFF_DATE,
                         V_FIRST_SANC_LIMIT,
                         V_FIRST_SANC_DATE
                    FROM (  SELECT L.LIMLNEHIST_SAUTH_CODE,
                                   L.LIMLNEHIST_EFF_DATE,
                                   LEAD (LIMLNEHIST_SANCTION_AMT,
                                         V_NEWEAL_TIME)
                                   OVER (ORDER BY LIMLNEHIST_EFF_DATE ASC)
                                      MIN_SANC_AMT,
                                   LEAD (LIMLNEHIST_DATE_OF_SANCTION,
                                         V_NEWEAL_TIME)
                                   OVER (ORDER BY LIMLNEHIST_EFF_DATE ASC)
                                      MIN_SANC_DATE,
                                     LIMLNEHIST_SANCTION_AMT
                                   - LEAD (LIMLNEHIST_SANCTION_AMT, 1)
                                     OVER (ORDER BY LIMLNEHIST_EFF_DATE ASC)
                                      ENHANCEMENT
                              FROM LIMITLINEHIST L
                             WHERE   LIMLNEHIST_ENTITY_NUM = V_GLOB_ENTITY_NUM
                                   AND  LIMLNEHIST_CLIENT_CODE =
                                          T_TEMP_REC (REC).T_CLIENT_CODE
                                   AND LIMLNEHIST_LIMIT_LINE_NUM =
                                          (SELECT ACASLLDTL.ACASLLDTL_LIMIT_LINE_NUM
                                             FROM ACASLLDTL
                                            WHERE ACASLLDTL_ENTITY_NUM = V_GLOB_ENTITY_NUM
                                            AND ACASLLDTL_INTERNAL_ACNUM =
                                                     W_INTERNAL_ACNUM)
                                   AND LIMLNEHIST_EFF_DATE <= P_TO_DATE
                          ORDER BY LIMLNEHIST_EFF_DATE DESC) A
                   WHERE A.MIN_SANC_DATE IS NOT NULL;

              --for enhancement

                   SELECT  ENHANCEMENT
                    INTO V_ENHNC_AMT
                    FROM (  SELECT L.LIMLNEHIST_SAUTH_CODE,
                                   L.LIMLNEHIST_EFF_DATE,
                                   LEAD (LIMLNEHIST_SANCTION_AMT,
                                         V_NEWEAL_TIME)
                                   OVER (ORDER BY LIMLNEHIST_EFF_DATE DESC)
                                      MIN_SANC_AMT,
                                   LEAD (LIMLNEHIST_DATE_OF_SANCTION,
                                         V_NEWEAL_TIME)
                                   OVER (ORDER BY LIMLNEHIST_EFF_DATE DESC)
                                      MIN_SANC_DATE,
                                     LIMLNEHIST_SANCTION_AMT
                                   - LEAD (LIMLNEHIST_SANCTION_AMT, 1)
                                     OVER (ORDER BY LIMLNEHIST_EFF_DATE DESC)
                                      ENHANCEMENT
                              FROM LIMITLINEHIST L
                             WHERE   LIMLNEHIST_ENTITY_NUM = V_GLOB_ENTITY_NUM
                                   AND  LIMLNEHIST_CLIENT_CODE =
                                          T_TEMP_REC (REC).T_CLIENT_CODE
                                   AND LIMLNEHIST_LIMIT_LINE_NUM =
                                          (SELECT ACASLLDTL.ACASLLDTL_LIMIT_LINE_NUM
                                             FROM ACASLLDTL
                                            WHERE ACASLLDTL_ENTITY_NUM = V_GLOB_ENTITY_NUM
                                            AND ACASLLDTL_INTERNAL_ACNUM =
                                                     W_INTERNAL_ACNUM)
                                   AND LIMLNEHIST_EFF_DATE <= P_TO_DATE
                          ORDER BY LIMLNEHIST_EFF_DATE DESC) A
                   WHERE A.MIN_SANC_DATE IS NOT NULL;

                  BEGIN
                     SELECT SAUTH_NAME
                       INTO V_APPROVAL_AUTH
                       FROM SAUTH
                      WHERE     SAUTH_ENTITY_NUM = 1
                            AND SAUTH_CODE = V_LIMIT_SAUTH_CODE;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        V_APPROVAL_AUTH := NULL;
                  END;
               ELSIF W_COUNTER = 1
               THEN
                  SELECT LIMLNEHIST_DATE_OF_SANCTION, LIMLNEHIST_SANCTION_AMT
                    INTO V_FIRST_SANC_DATE, V_FIRST_SANC_LIMIT
                    FROM LIMITLINEHIST
                   WHERE  LIMLNEHIST_ENTITY_NUM =  V_GLOB_ENTITY_NUM
                         AND  LIMLNEHIST_CLIENT_CODE =
                                T_TEMP_REC (REC).T_CLIENT_CODE
                         AND LIMLNEHIST_EFF_DATE =
                                (SELECT MIN (
                                           LIMITLINEHIST.LIMLNEHIST_EFF_DATE)
                                   FROM LIMITLINEHIST
                                  WHERE  LIMLNEHIST_ENTITY_NUM =  V_GLOB_ENTITY_NUM
                                        AND   LIMLNEHIST_CLIENT_CODE =
                                               T_TEMP_REC (REC).T_CLIENT_CODE
                                        AND LIMITLINEHIST.LIMLNEHIST_LIMIT_LINE_NUM =
                                               (SELECT ACASLLDTL.ACASLLDTL_LIMIT_LINE_NUM
                                                  FROM ACASLLDTL
                                                 WHERE ACASLLDTL_ENTITY_NUM = V_GLOB_ENTITY_NUM
                                                        AND ACASLLDTL_INTERNAL_ACNUM = W_INTERNAL_ACNUM))
                         AND LIMITLINEHIST.LIMLNEHIST_LIMIT_LINE_NUM =
                                (SELECT ACASLLDTL.ACASLLDTL_LIMIT_LINE_NUM
                                   FROM ACASLLDTL
                                  WHERE ACASLLDTL_ENTITY_NUM = V_GLOB_ENTITY_NUM
                                  AND ACASLLDTL_INTERNAL_ACNUM =  W_INTERNAL_ACNUM);

                  V_LIMIT_SAUTH_CODE := NULL;
                  V_EFF_DATE := NULL;
                  V_ENHNC_AMT := NULL;
                  V_APPROVAL_AUTH := NULL;
                  V_NEWEAL_TIME := 0;
               ELSE
                  V_FIRST_SANC_LIMIT := NULL;
                  V_FIRST_SANC_DATE := NULL;
                  V_LIMIT_SAUTH_CODE := NULL;
                  V_APPROVAL_AUTH := NULL;
                  V_EFF_DATE := NULL;
                  V_ENHNC_AMT := NULL;
                  V_NEWEAL_TIME := 0;
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  V_FIRST_SANC_LIMIT := NULL;
                  V_FIRST_SANC_DATE := NULL;
                  V_LIMIT_SAUTH_CODE := NULL;
                  V_APPROVAL_AUTH := NULL;
                  V_EFF_DATE := NULL;
                  V_ENHNC_AMT := NULL;
                  V_NEWEAL_TIME := NULL;
            END;


            TEMP_DATA.SANCTION_LIMIT := V_FIRST_SANC_LIMIT;

             BEGIN
               SELECT COUNT (*)
                 INTO V_NO_ENC
                 FROM (  SELECT LIMLNEHIST_CLIENT_CODE,
                                LIMLNEHIST_LIMIT_LINE_NUM,
                                LIMLNEHIST_EFF_DATE,
                                LIMLNEHIST_DATE_OF_SANCTION,
                                LIMLNEHIST_SANCTION_AMT,
                                LEAD (LIMLNEHIST_SANCTION_AMT, 1)
                                   OVER (ORDER BY LIMLNEHIST_EFF_DATE DESC)
                                   ENHANCEMENT
                           FROM LIMITLINEHIST
                          WHERE     LIMLNEHIST_ENTITY_NUM = 1
                                AND LIMLNEHIST_CLIENT_CODE =
                                       T_TEMP_REC (REC).T_CLIENT_CODE
                                AND LIMLNEHIST_LIMIT_LINE_NUM =
                                       (SELECT ACASLLDTL.ACASLLDTL_LIMIT_LINE_NUM
                                          FROM ACASLLDTL
                                         WHERE ACASLLDTL_ENTITY_NUM = V_GLOB_ENTITY_NUM
                                         AND ACASLLDTL_INTERNAL_ACNUM =
                                                  W_INTERNAL_ACNUM)
                                AND LIMLNEHIST_EFF_DATE <= P_TO_DATE
                                AND LIMLNEHIST_AUTH_BY IS NOT NULL
                       ORDER BY LIMLNEHIST_EFF_DATE DESC) AA
                WHERE NVL (LIMLNEHIST_SANCTION_AMT - ENHANCEMENT, 0) = 0;
            EXCEPTION
               WHEN OTHERS
               THEN
                  V_NO_ENC := 0;
            END;


         --Nature of Loan
            BEGIN

            IF T_TEMP_REC (REC).T_ACNTS_OPENING_DATE BETWEEN P_FROM_DATE AND P_TO_DATE
            THEN
            V_NATURE_OF_LOAN := 1;           --New
            ELSIF V_IS_RESCHEDULE_ACC = 1
            THEN V_NATURE_OF_LOAN := 4;      --Recheduled
            ELSIF  V_ENHNC_AMT > 0 AND T_TEMP_REC (REC).T_PRODUCT_FOR_RUN_ACS = 1
            THEN
            V_NATURE_OF_LOAN := 6;          --Enhancemnet
            ELSIF V_NO_ENC > 1
            THEN
            V_NATURE_OF_LOAN := 3;          --renewal
            ELSE V_NATURE_OF_LOAN := 2;     --current
            END IF;
            END;

            TEMP_DATA.NATURE_OF_LOAN := V_NATURE_OF_LOAN;


            --Disbursement Date


            BEGIN
               IF T_TEMP_REC (REC).T_PRODUCT_FOR_RUN_ACS = 1
               THEN
                     V_DISB_DATE := TO_CHAR (TO_DATE (V_FIRST_SANC_DATE), 'DD-MM-YYYY');
               ELSE
                    SELECT MIN (D.LNACDISB_DISB_ON)
                    INTO V_DISB_DATE
                    FROM LNACDISB D
                    WHERE     D.LNACDISB_ENTITY_NUM = V_GLOB_ENTITY_NUM
                    AND D.LNACDISB_INTERNAL_ACNUM = W_INTERNAL_ACNUM;

                    IF V_DISB_DATE IS NULL
                    THEN
                     BEGIN
                        SELECT A.ACNTINWTRF_DATE_OF_TRANSFR
                        INTO V_DISB_DATE
                        FROM ACNTINWTRF A
                        WHERE     A.ACNTINWTRF_ENTITY_NUM = V_GLOB_ENTITY_NUM
                        AND A.ACNTINWTRF_BRN_CODE = W_BRN_CODE
                        AND A.ACNTINWTRF_DEP_AC_NUM = W_INTERNAL_ACNUM;
                    EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                        V_DISB_DATE := NULL;
                    END;
                END IF;
            END IF;
        EXCEPTION
            WHEN OTHERS
            THEN
            V_DISB_DATE := NULL;
       END;

            TEMP_DATA.DISBURSEMENT_DATE := TO_CHAR(V_DISB_DATE,'DD-MM-YYYY');


            ---- CLASSIFICATION_CODE  assetcls
            BEGIN
               SELECT NVL (TRIM (ASSETCD_BSR_CODE), ' ')
                 INTO V_CLASSIFICTN_CODE
                 FROM ASSETCLS, ASSETCD
                WHERE     ASSETCLS_ENTITY_NUM = V_GLOB_ENTITY_NUM
                      AND ASSETCLS_INTERNAL_ACNUM = W_INTERNAL_ACNUM
                      AND ASSETCD_CODE = ASSETCLS_ASSET_CODE;
            EXCEPTION
               WHEN OTHERS
               THEN
                  V_CLASSIFICTN_CODE := NULL;
            END;

            TEMP_DATA.LOAN_CLASS_ID := V_CLASSIFICTN_CODE;


            BEGIN
               SELECT LNACRS_REPH_ON_AMT,
                      LNACRS_REPHASEMENT_ENTRY,
                      LNACRS_SANC_DATE
                 INTO V_RESCHEDULE_AMT,
                      V_IS_RESCHEDULE_ACC,
                      V_RESCHEDULE_SANC_DATE
                 FROM LNACRS
                WHERE LNACRS_ENTITY_NUM = V_GLOB_ENTITY_NUM
                AND LNACRS_INTERNAL_ACNUM = W_INTERNAL_ACNUM;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  V_RESCHEDULE_AMT := NULL;
                  V_IS_RESCHEDULE_ACC := NULL;
                  V_RESCHEDULE_SANC_DATE := NULL;
            END;

            -- DISBURSE

            V_DISB_AMT :=
               GET_DISB_AMT (W_INTERNAL_ACNUM,
                             T_TEMP_REC (REC).T_PRODUCT_FOR_RUN_ACS,
                             P_FROM_DATE,
                             P_TO_DATE);

            SELECT MIN (D.LNACDISB_DISB_ON)
              INTO V_DISBURSE_DATE
              FROM LNACDISB D
             WHERE D.LNACDISB_ENTITY_NUM = V_GLOB_ENTITY_NUM
             AND D.LNACDISB_INTERNAL_ACNUM = W_INTERNAL_ACNUM;

            IF V_DISBURSE_DATE IS NULL
            THEN
               BEGIN
                  SELECT A.ACNTINWTRF_DATE_OF_TRANSFR
                    INTO V_DISBURSE_DATE
                    FROM ACNTINWTRF A
                   WHERE A.ACNTINWTRF_ENTITY_NUM = V_GLOB_ENTITY_NUM
                   AND A.ACNTINWTRF_BRN_CODE = W_BRN_CODE
                   AND A.ACNTINWTRF_DEP_AC_NUM = W_INTERNAL_ACNUM;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     V_DISBURSE_DATE := NULL;
               END;
            END IF;


            IF V_IS_RESCHEDULE_ACC = 1
            THEN
               TEMP_DATA.DISBURSED_AMOUNT := V_RESCHEDULE_AMT;
            ELSE

               TEMP_DATA.DISBURSED_AMOUNT := V_DISB_AMT;
            END IF;



            BEGIN
            SELECT NVL(ABS(LNTOTINTDB_TOT_INT_DB_AMT),0) INTO W_TOT_INT_DB_MIG FROM LNTOTINTDBMIG WHERE LNTOTINTDB_ENTITY_NUM = V_GLOB_ENTITY_NUM
                    AND LNTOTINTDB_INTERNAL_ACNUM = W_INTERNAL_ACNUM ;
            EXCEPTION WHEN OTHERS THEN
                W_TOT_INT_DB_MIG := 0;
            END ;

            BEGIN

            SELECT ABS(ADVBBAL_INTRD_BC_DB_OPBAL),
            ABS(ADVBBAL_CHARGE_BC_DB_OPBAL)
            INTO W_TOT_INT_DB, W_TOT_CHGS_DB
            FROM ADVBBAL
            WHERE ADVBBAL_ENTITY_NUM = V_GLOB_ENTITY_NUM
            AND ADVBBAL_INTERNAL_ACNUM = W_INTERNAL_ACNUM
            AND ADVBBAL_CURR_CODE = T_TEMP_REC (REC).T_ACNTS_CURR_CODE
            AND ADVBBAL_YEAR = TO_NUMBER(TO_CHAR(P_TO_DATE + 1, 'YYYY'))
            AND ADVBBAL_MONTH = TO_NUMBER(TO_CHAR(P_TO_DATE + 1, 'MM')) ;
            EXCEPTION WHEN OTHERS THEN
                W_TOT_INT_DB := 0 ;
                W_TOT_CHGS_DB := 0 ;
            END ;

            --RECOVERY AMOUNT

            V_RECOV_AMT:= FN_GET_PAID_AMT(V_GLOB_ENTITY_NUM, W_INTERNAL_ACNUM, P_TO_DATE);
            TEMP_DATA.RECOVERY_AMOUNT := V_RECOV_AMT;

            -- W_TOT_INT_DB and W_TOT_CHGS_DB has value. To match with CL4 report we fixed the values with 0 as it is in the CL4 report.
            /*
            V_AMT_PAID_SINCE_SANC := ABS(V_DISB_AMT) + ABS(W_TOT_INT_DB_MIG) + 0 + 0 - ABS(GET_OUTSTANDING_BALANCE(W_INTERNAL_ACNUM,V_FIN_YEAR, V_FIN_MONTH));
            IF V_AMT_PAID_SINCE_SANC > 0 AND T_TEMP_REC (REC).T_PRODUCT_FOR_RUN_ACS = 0 THEN
                TEMP_DATA.RECOVERY_AMOUNT := V_AMT_PAID_SINCE_SANC;
            ELSE
                TEMP_DATA.RECOVERY_AMOUNT := 0;
            END IF ;
           */

            --- advbal balance
            BEGIN
            SELECT ABS(ADVBBAL_PRIN_BC_OPBAL), ABS(ADVBBAL_INTRD_BC_OPBAL) , ABS(ADVBBAL_CHARGE_BC_OPBAL)
            INTO V_PR_BAL, V_INT_BAL, V_OTH_BAL
                FROM ADVBBAL
                WHERE     ADVBBAL_ENTITY_NUM = V_GLOB_ENTITY_NUM
                    AND ADVBBAL_INTERNAL_ACNUM = W_INTERNAL_ACNUM
                    AND ADVBBAL_CURR_CODE = T_TEMP_REC (REC).T_ACNTS_CURR_CODE
                    AND ADVBBAL_YEAR = TO_NUMBER (TO_CHAR (P_TO_DATE + 1, 'YYYY'))
                    AND ADVBBAL_MONTH = TO_NUMBER (TO_CHAR (P_TO_DATE + 1, 'MM'));

            IF  V_PR_BAL > 0 THEN
                V_PR_BAL := 0 ;
            END IF ;

            IF  V_INT_BAL > 0 THEN
                V_INT_BAL := 0 ;
            END IF ;

            IF  V_OTH_BAL > 0 THEN
                V_OTH_BAL := 0 ;
            END IF ;

            EXCEPTION
               WHEN OTHERS
               THEN
                  V_PR_BAL := 0;
                  V_INT_BAL := 0;
                  V_OTH_BAL := 0;
            END;

            TEMP_DATA.OTHERS_BAL := ABS(V_OTH_BAL);


          ---Accrued Interest

           BEGIN

           SELECT LNACNT_INT_APPLIED_UPTO_DATE
           INTO V_START_ACCRUE_DATE
           FROM LOANACNTS
           WHERE LNACNT_ENTITY_NUM=V_GLOB_ENTITY_NUM
           AND LNACNT_INTERNAL_ACNUM=W_INTERNAL_ACNUM
           AND LNACNT_INT_APPLIED_UPTO_DATE BETWEEN P_FROM_DATE AND P_TO_DATE;

           EXCEPTION
           WHEN OTHERS
           THEN
           V_START_ACCRUE_DATE := NULL;
           END;

           BEGIN

           IF V_START_ACCRUE_DATE IS NULL
           THEN V_START_ACCRUE_DATE:= P_FROM_DATE;
           END IF;

           SELECT ROUND(NVL (ABS (SUM (LOANIAMRR_INT_AMT)), 0),2) ACCRUED_INT_AMT
           INTO V_ACCRUED_INT_AMT
           FROM LOANIAMRR
           WHERE LOANIAMRR_ENTITY_NUM = V_GLOB_ENTITY_NUM
           AND LOANIAMRR_BRN_CODE = W_BRN_CODE
           AND LOANIAMRR_ACNT_NUM = W_INTERNAL_ACNUM
           AND LOANIAMRR_ACCRUAL_DATE BETWEEN V_START_ACCRUE_DATE AND P_TO_DATE ;

           EXCEPTION WHEN OTHERS
           THEN
           V_ACCRUED_INT_AMT := 0;
           END;

           TEMP_DATA.ACCRUED_INTEREST :=V_ACCRUED_INT_AMT ;

            BEGIN
               SELECT  LNACMIS_SUB_INDUS_CODE,LNACMIS_NATURE_BORROWAL_AC
                 INTO V_CL_ECO_CODE,V_CL_SME_CODE
                 FROM LNACMIS
                WHERE LNACMIS_ENTITY_NUM = V_GLOB_ENTITY_NUM
                AND LNACMIS_INTERNAL_ACNUM = W_INTERNAL_ACNUM;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  V_CL_ECO_CODE := '';
                  V_CL_SME_CODE := '';

            END;


            TEMP_DATA.ECO_PURPOSE_ID := V_CL_ECO_CODE;
            TEMP_DATA.INDUSTRY_SCALE_ID := V_CL_SME_CODE;

            --
            --WRITE-OFF
            BEGIN

            SELECT NVL(SUM(LNWRTOFF_WRTOFF_AMT),0)
            INTO V_WRITE_OFF_AMT
            FROM LNWRTOFF
            WHERE LNWRTOFF_ENTITY_NUM=V_GLOB_ENTITY_NUM
            AND LNWRTOFF_ACNT_NUM=W_INTERNAL_ACNUM
            AND LNWRTOFF_WRTOFF_DATE BETWEEN P_FROM_DATE AND P_TO_DATE ;

            EXCEPTION
               WHEN OTHERS
               THEN
                  V_WRITE_OFF_AMT := 0;
            END;


            TEMP_DATA.WRITE_OFF_AMOUNT := V_WRITE_OFF_AMT;

            --END WRITE-OFF

            -- --- Gender Code and date of birth ---

            BEGIN
               SELECT TRIM (INDCLIENT_SEX),
                      TRIM (INDCLIENT_BIRTH_DATE)
                 INTO V_CLIENTS_GENDER,
                      V_DATE_OF_BIRTH
                 FROM INDCLIENTS
                WHERE INDCLIENT_CODE = T_TEMP_REC (REC).T_CLIENT_CODE;
            EXCEPTION
               WHEN OTHERS
               THEN
                  V_CLIENTS_GENDER := NULL;
                  V_DATE_OF_BIRTH := NULL;

            END;

            IF V_CLIENTS_GENDER = 'M'
            THEN V_CLIENTS_GENDER_CODE := 1001;
            ELSIF V_CLIENTS_GENDER='F'
            THEN V_CLIENTS_GENDER_CODE := 1002;
            ELSIF V_CLIENTS_GENDER='T'
            THEN V_CLIENTS_GENDER_CODE := 1003;
            ELSE
            V_CLIENTS_GENDER_CODE:= NULL;

            END IF;

            TEMP_DATA.GENDER_CODE := V_CLIENTS_GENDER_CODE;

            TEMP_DATA.DATE_OF_BIRTH := TO_CHAR (TO_DATE(V_DATE_OF_BIRTH), 'DD-MM-YYYY');

            ---Waiver Amount

            TEMP_DATA.WAIVER_AMOUNT := 0;

            --Opening balance



            V_OPENING_BALANCE := FN_GET_ASON_ACBAL(V_GLOB_ENTITY_NUM, W_INTERNAL_ACNUM, T_TEMP_REC (REC).T_ACNTS_CURR_CODE, P_FROM_DATE-1,V_CBD);

            IF V_OPENING_BALANCE >0
            THEN
            TEMP_DATA.OPENING_BALANCE := 0;
            ELSE
            TEMP_DATA.OPENING_BALANCE :=ABS(V_OPENING_BALANCE);
            END IF;



            PIPE ROW (TEMP_DATA);
            W_REMARKS := '';
            V_CLOSURE_DATE := '' ;
         END LOOP;
      END IF;


       --GL_PART
     BEGIN
     T_TEMP_REC.DELETE;

     --TEMP_DATA1.DELETE;
      W_SQL_QUERY := 'SELECT EXTGL_ACCESS_CODE ACC_NUMBER,
      0 T_CLIENT_CODE,
      RPAD (
                           NVL (
                              TRIM (
                                 REGEXP_REPLACE (EXTGL_EXT_HEAD_DESCN,
                                                 ''[^[:print:]]'',
                                                 '' '')),
                              '' ''),
                           100,
                           '' '')  T_AC_NAME ,
      NULL T_CURR_CODE,
      NULL T_SECTOR_CODE ,
      NULL T_PROD_NAME ,
      CASE WHEN E.EXTGL_ACCESS_CODE IN (''211140120'') THEN ''A0304'' ELSE NVL((GET_F12_CODE(E.EXTGL_ACCESS_CODE)), ''F12'') END T_LOAN_CODE ,
      0 T_PROD_CODE ,
      0 T_INT_RATE ,
      NULL T_SECURITY_CODE ,
      NULL T_DB_CR_TOTAL,
      0 T_OD_AMT,
      --T_OUTSTANDING_BAL
      0 T_BORROWER_CODE ,
      0 T_FIS_CODE ,
      0 T_PRODUCT_FOR_RUN_ACS ,
      NULL T_ACNTS_CLOSURE_DATE
FROM RPTHEAD H,RPTHEADGLDTL D,EXTGL E,GLMAST G,GLBBAL,MBRN
              WHERE
                    D.RPTHDGLDTL_GLACC_CODE = E.EXTGL_ACCESS_CODE
                    AND E.EXTGL_GL_HEAD = G.GL_NUMBER
                    AND D.RPTHDGLDTL_CODE IN(''LSBS3'')
                    AND G.GL_CLOSURE_DATE IS NULL
                    AND EXTGL_ACCESS_CODE = GLBBAL_GLACC_CODE
                    AND GLBBAL_ENTITY_NUM = :V_ENTITY_NUM
                    AND GLBBAL_BRANCH_CODE = :P_BRANCH_CODE
                    AND H.RPTHEAD_CODE = D.RPTHDGLDTL_CODE
                    AND MBRN_CODE = GLBBAL_BRANCH_CODE
                    AND GLBBAL_YEAR = TO_NUMBER (TO_CHAR (:P_TO_DATE, ''YYYY''))';


      EXECUTE IMMEDIATE W_SQL_QUERY
         BULK COLLECT INTO T_TEMPGL_REC
         USING V_GLOB_ENTITY_NUM,
               P_BRN_CODE,
               P_FROM_DATE;

      IF T_TEMPGL_REC.FIRST IS NOT NULL
      THEN
         FOR REC IN T_TEMPGL_REC.FIRST .. T_TEMPGL_REC.LAST
         LOOP
           W_SL_NO := W_SL_NO + 1;

           TEMP_DATA1.SL_NO := W_SL_NO;

           TEMP_DATA1.OUTSTANDING_AMOUNT:= ABS(FN_BIS_GET_ASON_GLBAL (
                  V_GLOB_ENTITY_NUM,
                  P_BRN_CODE,
                  T_TEMPGL_REC(REC).T_AC_NUM,
                  CASE
                     WHEN TRIM (T_TEMPGL_REC(REC).T_CURR_CODE ) IS NULL THEN 'BDT'
                     ELSE T_TEMPGL_REC(REC).T_CURR_CODE
                  END,
                  P_TO_DATE,
                  TO_DATE (FN_GET_CURRBUSS_DATE (1, NULL))));

           TEMP_DATA1.ACCOUNT_ID := LPAD (T_TEMPGL_REC(REC).T_AC_NUM,13,'0');

           TEMP_DATA1.DATED := TO_CHAR(P_TO_DATE, 'DD-MM-YYYY');

           TEMP_DATA1.FI_ID := 15;
           TEMP_DATA1.FI_BRANCH_ID :='015' || TO_CHAR(P_BRN_CODE);

           PIPE ROW (TEMP_DATA1);
           END LOOP;
           END IF;
      END ;
      --GL_PART


   END GET_BRANCH_WISE;
BEGIN
   NULL;
END PKG_SBS3_DATA_RETURN;

/
