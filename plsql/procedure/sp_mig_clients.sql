CREATE OR REPLACE PROCEDURE SP_MIG_CLIENTS(P_BRANCH_CODE NUMBER,
                                           P_ERR_MSG     OUT VARCHAR2) IS

  /*
    Author:S.Rajalakshmi
    Date  :
  
  
  List of  Table/s Referred
  
   1. MIG_CLIENTCONTACTS
   2. MIG_CLIENTS
   3. MIG_CLIENTSBKDTL
   4. MIG_CONNPINFO
   5. MIG_PIDDOCS
  
  List of Tables Updated
  
    1. CLIENTS
    2. CLIENTSBKDTL
    3. INDCLIENTS
    4. CLIENTSCONTACTS
    5. CONNPINFO
    6. PIDDOCS
    7. CORPCLIENTS
    8. CLIENTNUM
    9.CLIENTSFADDR
    10.ADDRDTLS
    11.corpclineact;
  
      Modification History
      -----------------------------------------------------------------------------------------
      Sl.            Description                                    Mod By             Mod on
      -----------------------------------------------------------------------------------------
    */
  TYPE RC IS REF CURSOR;
  RCCLIENTS RC;
  TYPE CLIENTS_MIG IS RECORD(
    MIG_CLIENT_CODE       NUMBER(12),
    MIG_TYPE_FLG          CHAR(1),
    MIG_HOME_BRN_CODE     NUMBER(6),
    TITLE_CODE            VARCHAR2(4),
    FIRST_NAME            VARCHAR2(24),
    LAST_NAME             VARCHAR2(24),
    SUR_NAME              VARCHAR2(24),
    MIDDLE_NAME           VARCHAR2(24),
    NAME1                 VARCHAR2(100),
    CLIENT_FATHER_NAME    VARCHAR2(50),
    CONST_CODE            NUMBER(6),
    ADDR1                 VARCHAR2(35),
    ADDR2                 VARCHAR2(35),
    ADDR3                 VARCHAR2(35),
    ADDR4                 VARCHAR2(35),
    ADDR5                 VARCHAR2(35),
    LOCN_CODE             VARCHAR2(6),
    CUST_CATG             VARCHAR2(6),
    CUST_SUB_CATG         VARCHAR2(6),
    SEGMENT_CODE          VARCHAR2(6),
    BUSDIVN_CODE          VARCHAR2(3),
    RISK_CNTRY            VARCHAR2(2),
    NUM_OF_DOCS           NUMBER(2),
    CONT_PERSON_AVL       CHAR(1),
    CR_LIMITS_OTH_BK      CHAR(1),
    ACS_WITH_OTH_BK       CHAR(1),
    OPENING_DATE          DATE,
    GROUP_CODE            VARCHAR2(6),
    PAN_GIR_NUM           VARCHAR2(35),
    IT_STAT_CODE          VARCHAR2(6),
    IT_SUB_STAT_CODE      VARCHAR2(6),
    EXEMP_IN_TDS          CHAR(1),
    EXEMP_TDS_PER         NUMBER(8, 5),
    EXEMP_REM1            VARCHAR2(35),
    EXEMP_REM2            VARCHAR2(35),
    EXEMP_REM3            VARCHAR2(35),
    BSR_TYPE_FLG          CHAR(1),
    RISK_CATEGORIZATION   CHAR(1),
    BIRTH_DATE            DATE,
    BIRTH_PLACE_CODE      VARCHAR2(6),
    BIRTH_PLACE_NAME      VARCHAR2(50),
    SEX                   CHAR(1),
    MARITAL_STATUS        CHAR(1),
    RELIGN_CODE           VARCHAR2(2),
    NATNL_CODE            VARCHAR2(2),
    RESIDENT_STATUS       CHAR(1),
    LANG_CODE             VARCHAR2(6),
    ILLITERATE_CUST       CHAR(1),
    DISABLED              CHAR(1),
    FADDR_REQD            CHAR(1),
    TEL_RES               VARCHAR2(15),
    TEL_OFF               VARCHAR2(15),
    TEL_OFF1              VARCHAR2(15),
    EXTN_NUM              NUMBER(5),
    TEL_GSM               VARCHAR2(15),
    TEL_FAX               VARCHAR2(15),
    EMAIL_ADDR1           VARCHAR2(65),
    EMAIL_ADDR2           VARCHAR2(65),
    EMPLOY_TYPE           CHAR(1),
    RETIRE_PENS_FLG       CHAR(1),
    RELATION_BANK_FLG     CHAR(1),
    EMPLOYEE_NUM          VARCHAR2(15),
    OCCUPN_CODE           VARCHAR2(6),
    EMP_COMPANY           VARCHAR2(6),
    EMP_CMP_NAME          VARCHAR2(50),
    EMP_CMP_ADDR1         VARCHAR2(35),
    EMP_CMP_ADDR2         VARCHAR2(35),
    EMP_CMP_ADDR3         VARCHAR2(35),
    EMP_CMP_ADDR4         VARCHAR2(35),
    EMP_CMP_ADDR5         VARCHAR2(35),
    DESIG_CODE            VARCHAR2(6),
    WORK_SINCE_DATE       DATE,
    RETIREMENT_DATE       DATE,
    BC_ANNUAL_INCOME      NUMBER(18, 3),
    ANNUAL_INCOME_SLAB    CHAR(1),
    ACCOM_TYPE            CHAR(1),
    ACCOM_OTHERS          VARCHAR2(35),
    OWNS_TWO_WHEELER      CHAR(1),
    OWNS_CAR              CHAR(1),
    INSUR_POLICY_INFO     CHAR(1),
    DEATH_DATE            DATE,
    PID_INV_NUM           NUMBER(10),
    ORGN_QUALIER          CHAR(1),
    SWIFT_CODE            VARCHAR2(12),
    INDUS_CODE            VARCHAR2(6),
    SUB_INDUS_CODE        VARCHAR2(6),
    NATURE_OF_BUS1        VARCHAR2(50),
    NATURE_OF_BUS2        VARCHAR2(50),
    NATURE_OF_BUS3        VARCHAR2(50),
    INVEST_PM_CURR        VARCHAR2(3),
    INVEST_PM_AMT         NUMBER(18, 3),
    CAPITAL_CURR          VARCHAR2(3),
    AUTHORIZED_CAPITAL    NUMBER(18, 3),
    ISSUED_CAPITAL        NUMBER(18, 3),
    PAIDUP_CAPITAL        NUMBER(18, 3),
    NETWORTH_AMT          NUMBER(18, 3),
    INCORP_DATE           DATE,
    INCORP_CNTRY          VARCHAR2(2),
    REG_NUM               VARCHAR2(25),
    REG_DATE              DATE,
    REG_AUTHORITY         VARCHAR2(50),
    REG_EXPIRY_DATE       DATE,
    REG_OFF_ADDR1         VARCHAR2(35),
    REG_OFF_ADDR2         VARCHAR2(35),
    REG_OFF_ADDR3         VARCHAR2(35),
    REG_OFF_ADDR4         VARCHAR2(35),
    REG_OFF_ADDR5         VARCHAR2(35),
    TF_CLIENT             CHAR(1),
    VOSTRO_EXCG_HOUSE     CHAR(1),
    IMP_EXP_CODE          VARCHAR2(15),
    COM_BUS_IDENTIFIER    VARCHAR2(15),
    BUS_ENTITY_IDENTIFIER VARCHAR2(15),
    YEARS_IN_BUSINESS     NUMBER(3),
    BC_GROSS_TURNOVER     NUMBER(18, 3),
    EMPLOYEE_SIZE         NUMBER(6),
    NUM_OFFICES           NUMBER(6),
    SCHEDULED_BANK        CHAR(1),
    SOVEREIGN_FLG         CHAR(1),
    TYPE_OF_SOVEREIGN     CHAR(1),
    CNTRY_CODE1           VARCHAR2(2),
    CENTRAL_STATE_FLG     CHAR(1),
    PUBLIC_SECTOR_FLG     CHAR(1),
    PRIMARY_DLR_FLG       CHAR(1),
    MULTILATERAL_BANK     CHAR(1),
    ENTD_BY               VARCHAR2(8),
    ENTD_ON               DATE,
    FORN_ADDR1            VARCHAR2(35),
    FORN_ADDR2            VARCHAR2(35),
    FORN_ADDR3            VARCHAR2(35),
    FORN_ADDR4            VARCHAR2(35),
    FORN_ADDR5            VARCHAR2(35),
    CNTRY_CODE2           VARCHAR2(2),
    FORN_RES_TEL          VARCHAR2(15),
    FORN_OFF_TEL          VARCHAR2(15),
    FORN_EXTN_NUM         NUMBER(5),
    GSM_NUM               VARCHAR2(15),
    MEMBERSHIP_NUM        NUMBER(12),
    CLIENTS_ITFORM        VARCHAR2(6),
    CLIENTS_RECPT_DATE    DATE,
    CLIENTS_DECEASED_APPL VARCHAR2(1));

  W_ER_CODE    VARCHAR2(5);
  W_ER_DESC    VARCHAR2(1000);
  W_SRC_KEY    VARCHAR2(1000);
  W_NULL       VARCHAR2(10);
  W_ENTITY_NUM NUMBER(3) := GET_OTN.ENTITY_NUMBER;
  W_FLAG       NUMBER(1) := 0; --RAMESH M ON 29/03/2012
  TYPE IN_CLIENTS_MIG IS TABLE OF CLIENTS_MIG INDEX BY PLS_INTEGER;
  V_IN_CLIENTS_MIG IN_CLIENTS_MIG;

  TYPE GEN_CLIENT IS RECORD(
    BRN_CODE   NUMBER(6),
    OLD_CLCODE NUMBER(20),
    ENTD_BY    VARCHAR2(8),
    ENTD_ON    DATE);
  TYPE IN_GEN_CLIENT IS TABLE OF GEN_CLIENT INDEX BY PLS_INTEGER;

  V_GEN_CLIENT IN_GEN_CLIENT;
  W_CL_CODE    NUMBER(12);
  W_OLD_CLN    NUMBER(12);
  W_PID_INVNUM NUMBER(10);
  W_CURR_CODE  VARCHAR2(3) := 'BDT'; --shamsudeen-chn-24may2012-changed INR to BDT

  -- W_CCNT         NUMBER(10) := 1;
  -- W_PCNT         NUMBER(10) := 1;
  W_LOC_CODE     VARCHAR2(6);
  W_BUS_DIV_CODE VARCHAR2(3);
  W_CUST_CAT     VARCHAR2(6);
  --W_CNT           NUMBER(6) := 0;
  W_PNT           NUMBER(6) := 0;
  W_LAST_NUM_USED NUMBER(10);
  W_ADDR_INVNUM   NUMBER(10);
  W_CONNP_NUM     NUMBER(10);
  W_CURR_DATE     DATE;
  W_ENTD_BY       VARCHAR2(8) := 'MIG';
  W_RESIDENT_STAT CHAR(1) := 'R';
  W_PAN_GIR_NUM   VARCHAR2(35);

  MYEXCEPTION EXCEPTION;

  FUNCTION GET_NEWCLN(BRNNUM NUMBER, OLDCLN NUMBER) RETURN NUMBER IS
    W_NEW_CLCODE NUMBER(20);
    W_MYERR      VARCHAR2(500);
  BEGIN
    SELECT NEW_CLCODE
      INTO W_NEW_CLCODE
      FROM TEMP_CLIENT
     WHERE OLD_CLCODE = OLDCLN
       AND BRN_CODE = BRNNUM;
    RETURN W_NEW_CLCODE;
  EXCEPTION
    WHEN OTHERS THEN
      W_MYERR := SQLERRM;
      DBMS_OUTPUT.PUT_LINE('OLD CLIENT CODE ' || OLDCLN || W_MYERR);
      RETURN 0;
  END GET_NEWCLN;

  PROCEDURE POST_ERR_LOG(W_SOURCE_KEY VARCHAR2,
                         W_START_DATE DATE,
                         W_ERROR_CODE VARCHAR2,
                         W_ERROR      VARCHAR2) IS
    --   PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    INSERT INTO MIG_ERRORLOG
      (MIG_ERR_SRC_KEY,
       MIG_ERR_DTL_SL,
       MIG_ERR_MIGDATE,
       MIG_ERR_CODE,
       MIG_ERR_DESC)
    VALUES
      (W_SOURCE_KEY,
       (SELECT NVL(MAX(MIG_ERR_DTL_SL), 0) + 1
          FROM MIG_ERRORLOG P
         WHERE P.MIG_ERR_MIGDATE = W_START_DATE),
       W_START_DATE,
       W_ERROR_CODE,
       W_ERROR);
    COMMIT;
  END POST_ERR_LOG;

  -- RAMESH M : PIDDOCS
  PROCEDURE SP_MIG_PIDDOCS IS
    V_PID_NUM      NUMBER(10);
    V_INV_LAST_NUM NUMBER(10);
    --PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    SELECT INVNUM_LAST_NUM_USED
      INTO V_INV_LAST_NUM
      FROM INVNUM
     WHERE INVNUM_SOURCE_TYPE = 'P';
  
    FOR IDX IN (SELECT INDCLIENT_CODE
                  FROM INDCLIENTS
                 WHERE INDCLIENT_CODE NOT IN
                       (SELECT P.PIDDOCS_SOURCE_KEY FROM PIDDOCS P)) LOOP
    
      V_INV_LAST_NUM := V_INV_LAST_NUM + 1;
    
      INSERT INTO PIDDOCS
        (PIDDOCS_INV_NUM,
         PIDDOCS_DOC_SL,
         PIDDOCS_PID_TYPE,
         PIDDOCS_DOCID_NUM,
         PIDDOCS_FOR_ADDR_PROOF,
         PIDDOCS_FOR_IDENTITY_CHK,
         PIDDOCS_SOURCE_KEY)
      VALUES
        (V_INV_LAST_NUM,
         1,
         '99',
         IDX.INDCLIENT_CODE,
         1,
         1,
         IDX.INDCLIENT_CODE);
    
      UPDATE INDCLIENTS
         SET INDCLIENT_PID_INV_NUM = V_INV_LAST_NUM
       WHERE INDCLIENT_CODE = IDX.INDCLIENT_CODE;
    
      V_PID_NUM := V_INV_LAST_NUM;
      W_CL_CODE := IDX.INDCLIENT_CODE;
    END LOOP;
  
    UPDATE INVNUM
       SET INVNUM_LAST_NUM_USED = V_PID_NUM
     WHERE INVNUM_SOURCE_TYPE = 'P';
    --COMMIT;
  END SP_MIG_PIDDOCS;
  -- RAMESH M : PIDDOCS

  PROCEDURE MIGRATE_CLIENTS IS
  BEGIN
  
    -- DBMS_OUTPUT.PUT_LINE(V_IN_CLIENTS_MIG.COUNT);
    W_NULL := NULL;
    IF V_IN_CLIENTS_MIG.COUNT > 0 THEN
      FOR IDX IN V_IN_CLIENTS_MIG.FIRST .. V_IN_CLIENTS_MIG.LAST LOOP
      
        W_CL_CODE := GET_NEWCLN(V_IN_CLIENTS_MIG(IDX).MIG_HOME_BRN_CODE,
                                V_IN_CLIENTS_MIG(IDX).MIG_CLIENT_CODE);
      
        --  dbms_output.put_line(W_CL_CODE);
      
        IF W_CL_CODE > 0 THEN
        
          <<IN_CLIENTNUM>>
          BEGIN
            INSERT INTO CLIENTNUM VALUES (W_CL_CODE);
          EXCEPTION
            WHEN OTHERS THEN
              W_ER_CODE := 'CL1';
              W_ER_DESC := 'INSERT-CLIENTNUM-CLIENTS ' || SQLERRM;
              W_SRC_KEY := P_BRANCH_CODE || '-' || W_CL_CODE;
              POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
          END IN_CLIENTNUM;
        
          IF V_IN_CLIENTS_MIG(IDX)
           .MIG_TYPE_FLG = 'I' OR V_IN_CLIENTS_MIG(IDX).MIG_TYPE_FLG = 'J' THEN
            W_BUS_DIV_CODE := '01';
          ELSIF V_IN_CLIENTS_MIG(IDX).MIG_TYPE_FLG = 'C' THEN
            W_BUS_DIV_CODE := '02';
          END IF;
        
          IF V_IN_CLIENTS_MIG(IDX).MIG_TYPE_FLG = 'C' THEN
            W_CUST_CAT := 'C';
          ELSE
            W_CUST_CAT := 'R';
          END IF;
        
          W_PAN_GIR_NUM := V_IN_CLIENTS_MIG(IDX).PAN_GIR_NUM;
        
          <<IN_CLIENTS>>
          BEGIN
          
            W_ADDR_INVNUM := W_ADDR_INVNUM + 1;
            EXECUTE IMMEDIATE 'INSERT INTO ADDRDTLS
            (
              ADDRDTLS_INV_NUM,
              ADDRDTLS_ADDR_SL,
              ADDRDTLS_ADDR_TYPE,
              ADDRDTLS_CMP_TPARTY_NAME,
              ADDRDTLS_ADDR1,
              ADDRDTLS_ADDR2,
              ADDRDTLS_ADDR3,
              ADDRDTLS_ADDR4,
              ADDRDTLS_ADDR5,
              ADDRDTLS_PIN_ZIP_CODE,
              ADDRDTLS_LOCN_CODE,
              ADDRDTLS_CNTRY_CODE,
              ADDRDTLS_PHONE_NUM1,
              ADDRDTLS_PHONE_NUM2,
              ADDRDTLS_MOBILE_NUM,
              ADDRDTLS_STAYING_MTH,
              ADDRDTLS_STAYING_YEAR,
              ADDRDTLS_CURR_ADDR,
              ADDRDTLS_PERM_ADDR,
              ADDRDTLS_COMM_ADDR,
              ADDRDTLS_SOURCE_TABLE,
              ADDRDTLS_SOURCE_KEY,
              ADDRDTLS_PGM_ID,
              ADDRDTLS_EFF_FROM_DATE,
              ADDRDTLS_INVALID_FROM_DATE
            )
            VALUES
            (
              :1,
              :2,
              :3,:4,
             :5,
               :6,
               :7,
               :8,
               :9,
               :10,
               :11,
               :12,
               :13,:14,:15,:16,:17,:18,:19,:20,:21,:21,:22,:23,:24
            )'
              USING W_ADDR_INVNUM, 1, '01', W_NULL, V_IN_CLIENTS_MIG(IDX).ADDR1, V_IN_CLIENTS_MIG(IDX).ADDR2, V_IN_CLIENTS_MIG(IDX).ADDR3, V_IN_CLIENTS_MIG(IDX).ADDR4, V_IN_CLIENTS_MIG(IDX).ADDR5, W_NULL, W_LOC_CODE, 'BD', W_NULL, W_NULL, V_IN_CLIENTS_MIG(IDX).TEL_GSM, W_NULL, W_NULL, 1, 1, 1, 'CLIENTS', W_CL_CODE, 'MINDCLIENTS', V_IN_CLIENTS_MIG(IDX).OPENING_DATE, W_NULL; --shamsudeen-chn-24may2012-changed IN to BD
          
            EXECUTE IMMEDIATE 'INSERT INTO CLIENTS
              (CLIENTS_CODE,
               CLIENTS_TYPE_FLG,
               CLIENTS_HOME_BRN_CODE,
               CLIENTS_TITLE_CODE,
               CLIENTS_NAME,
               CLIENTS_ALPHA_ID,
               CLIENTS_CONST_CODE,
               CLIENTS_ADDR1,
               CLIENTS_ADDR2,
               CLIENTS_ADDR3,
               CLIENTS_ADDR4,
               CLIENTS_ADDR5,
               CLIENTS_LOCN_CODE,
               CLIENTS_CUST_CATG,
               CLIENTS_CUST_SUB_CATG,
               CLIENTS_SEGMENT_CODE,
               CLIENTS_BUSDIVN_CODE,
               CLIENTS_RISK_CNTRY,
               CLIENTS_NUM_OF_DOCS,
               CLIENTS_CONT_PERSON_AVL,
               CLIENTS_CR_LIMITS_OTH_BK,
               CLIENTS_ACS_WITH_OTH_BK,
               CLIENTS_OPENING_DATE,
               CLIENTS_ARM_CODE,
               CLIENTS_GROUP_CODE,
               CLIENTS_PAN_GIR_NUM,
               CLIENTS_IT_STAT_CODE,
               CLIENTS_IT_SUB_STAT_CODE,
               CLIENTS_EXEMP_IN_TDS,
               CLIENTS_EXEMP_TDS_PER,
               CLIENTS_EXEMP_REM1,
               CLIENTS_EXEMP_REM2,
               CLIENTS_EXEMP_REM3,
               CLIENTS_BSR_TYPE_FLG,
               CLIENTS_RISK_CATEGORIZATION,
               CLIENTS_CREATION_STATUS,
               CLIENTS_ENTD_BY,
               CLIENTS_ENTD_ON,
               CLIENTS_LAST_MOD_BY,
               CLIENTS_LAST_MOD_ON,
               CLIENTS_AUTH_BY,
               CLIENTS_AUTH_ON,
               CLIENTS_PREOPEN_ENTD_BY,
               CLIENTS_PREOPEN_ENTD_ON,
               CLIENTS_PREOPEN_LAST_MOD_BY,
               CLIENTS_PREOPEN_LAST_MOD_ON,
               TBA_MAIN_KEY,
               CLIENTS_ADDR_INV_NUM,
               CLIENTS_DECEASED_APPL)
            VALUES
              (:1,
               :2,
               :3,
               :4,
               :5,
               :6,
               :7,
               :8,
               :9,
               :10,
               :11,
               :12,
               :13,
               :14,
               :15,
               :16,
               :17,
               :18,
               :19,
               :20,
               :21,
               :22,
               :23,
               :24,
               :25,
               :26,
               :27,
               :28,
               :29,
               :30,
               :31,
               :32,
               :33,
               :34,
               :35,
               :36,
               :37,
               :38,
               :39,
               :40,
               :41,
               :42,
               :43,
               :44,
               :45,
               :46,
               :47,
               :48,
               :49
              )'
              USING W_CL_CODE, V_IN_CLIENTS_MIG(IDX).MIG_TYPE_FLG, P_BRANCH_CODE, V_IN_CLIENTS_MIG(IDX).TITLE_CODE, V_IN_CLIENTS_MIG(IDX).NAME1, W_NULL, V_IN_CLIENTS_MIG(IDX).CONST_CODE, V_IN_CLIENTS_MIG(IDX).ADDR1, V_IN_CLIENTS_MIG(IDX).ADDR2, V_IN_CLIENTS_MIG(IDX).ADDR3, V_IN_CLIENTS_MIG(IDX).ADDR4, V_IN_CLIENTS_MIG(IDX).ADDR5, W_LOC_CODE, V_IN_CLIENTS_MIG(IDX).CUST_CATG, V_IN_CLIENTS_MIG(IDX).CUST_SUB_CATG, V_IN_CLIENTS_MIG(IDX).SEGMENT_CODE, W_BUS_DIV_CODE, 'BD', V_IN_CLIENTS_MIG(IDX).NUM_OF_DOCS, V_IN_CLIENTS_MIG(IDX).CONT_PERSON_AVL, V_IN_CLIENTS_MIG(IDX).CR_LIMITS_OTH_BK, V_IN_CLIENTS_MIG(IDX).ACS_WITH_OTH_BK, V_IN_CLIENTS_MIG(IDX).OPENING_DATE, W_NULL, V_IN_CLIENTS_MIG(IDX).GROUP_CODE, V_IN_CLIENTS_MIG(IDX).PAN_GIR_NUM, V_IN_CLIENTS_MIG(IDX).IT_STAT_CODE, V_IN_CLIENTS_MIG(IDX).IT_SUB_STAT_CODE, V_IN_CLIENTS_MIG(IDX).EXEMP_IN_TDS, V_IN_CLIENTS_MIG(IDX).EXEMP_TDS_PER, V_IN_CLIENTS_MIG(IDX).EXEMP_REM1, V_IN_CLIENTS_MIG(IDX).EXEMP_REM2, V_IN_CLIENTS_MIG(IDX).EXEMP_REM3, W_CUST_CAT, NVL(V_IN_CLIENTS_MIG(IDX).RISK_CATEGORIZATION, 2), 'F', W_ENTD_BY, W_CURR_DATE, W_NULL, W_NULL, W_ENTD_BY, W_CURR_DATE, W_NULL, W_NULL, W_NULL, W_NULL, W_NULL, W_ADDR_INVNUM, NVL(V_IN_CLIENTS_MIG(IDX).CLIENTS_DECEASED_APPL, 0); --shamsudeen-chn-24may2012-changed IN to BD
          EXCEPTION
            WHEN OTHERS THEN
              W_ER_CODE := 'CL2';
              W_ER_DESC := 'INSERT-CLIENTS-CLIENTS ' || SQLERRM;
              W_SRC_KEY := P_BRANCH_CODE || '-' || W_CL_CODE;
              POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
          END IN_CLIENT;
        
          --S.Karthik-31-AUG-2010-Beg
          IF V_IN_CLIENTS_MIG(IDX).CLIENTS_ITFORM IS NOT NULL THEN
            INSERT INTO ITFORMS
              (ITFORM_ENTITY_NUM,
               ITFORM_SOURCE_TABLE,
               ITFORM_SOURCE_KEY,
               ITFORM_ACCOUNT_NUMBER,
               ITFORM_FORM_RCPT_DATE,
               ITFORM_DOC_CODE)
            VALUES
              (W_ENTITY_NUM,
               'INDCLIENTS',
               W_CL_CODE,
               0,
               V_IN_CLIENTS_MIG(IDX).CLIENTS_RECPT_DATE,
               V_IN_CLIENTS_MIG(IDX).CLIENTS_ITFORM);
          END IF;
          --S.Karthik-31-AUG-2010-End
        
          IF V_IN_CLIENTS_MIG(IDX).MIG_TYPE_FLG = 'I' THEN
            <<IN_INDCLIENTS>>
            BEGIN
              EXECUTE IMMEDIATE 'INSERT INTO INDCLIENTS
                (INDCLIENT_CODE,
                 INDCLIENT_FIRST_NAME,
                 INDCLIENT_LAST_NAME,
                 INDCLIENT_SUR_NAME,
                 INDCLIENT_MIDDLE_NAME,
                 INDCLIENT_WKSEC_CODE,
                 INDCLIENT_FATHER_NAME,
                 INDCLIENT_BIRTH_DATE,
                 INDCLIENT_BIRTH_PLACE_CODE,
                 INDCLIENT_BIRTH_PLACE_NAME,
                 INDCLIENT_SEX,
                 INDCLIENT_MARITAL_STATUS,
                 INDCLIENT_RELIGN_CODE,
                 INDCLIENT_NATNL_CODE,
                 INDCLIENT_RESIDENT_STATUS,
                 INDCLIENT_LANG_CODE,
                 INDCLIENT_ILLITERATE_CUST,
                 INDCLIENT_DISABLED,
                 INDCLIENT_FADDR_REQD,
                 INDCLIENT_TEL_RES,
                 INDCLIENT_TEL_OFF,
                 INDCLIENT_TEL_OFF1,
                 INDCLIENT_EXTN_NUM,
                 INDCLIENT_TEL_GSM,
                 INDCLIENT_TEL_FAX,
                 INDCLIENT_EMAIL_ADDR1,
                 INDCLIENT_EMAIL_ADDR2,
                 INDCLIENT_EMPLOY_TYPE,
                 INDCLIENT_RETIRE_PENS_FLG,
                 INDCLIENT_RELATION_BANK_FLG,
                 INDCLIENT_EMPLOYEE_NUM,
                 INDCLIENT_OCCUPN_CODE,
                 INDCLIENT_EMP_COMPANY,
                 INDCLIENT_EMP_CMP_NAME,
                 INDCLIENT_EMP_CMP_ADDR1,
                 INDCLIENT_EMP_CMP_ADDR2,
                 INDCLIENT_EMP_CMP_ADDR3,
                 INDCLIENT_EMP_CMP_ADDR4,
                 INDCLIENT_EMP_CMP_ADDR5,
                 INDCLIENT_DESIG_CODE,
                 INDCLIENT_WORK_SINCE_DATE,
                 INDCLIENT_RETIREMENT_DATE,
                 INDCLIENT_BC_ANNUAL_INCOME,
                 INDCLIENT_ANNUAL_INCOME_SLAB,
                 INDCLIENT_ACCOM_TYPE,
                 INDCLIENT_ACCOM_OTHERS,
                 INDCLIENT_OWNS_TWO_WHEELER,
                 INDCLIENT_OWNS_CAR,
                 INDCLIENT_INSUR_POLICY_INFO,
                 INDCLIENT_DEATH_DATE,
                 INDCLIENT_PID_INV_NUM)
              VALUES
                (
                :1,
:2,
:3,
:4,
:5,
:6,
:7,
:8,
:9,
:10,
:11,
:12,
:13,
:14,
:15,
:16,
:17,
:18,
:19,
:20,
:21,
:22,
:23,
:24,
:25,
:26,
:27,
:28,
:29,
:30,
:31,
:32,
:33,
:34,
:35,
:36,
:37,
:38,
:39,
:40,
:41,
:42,
:43,
:44,
:45,
:46,
:47,
:48,
:49,
:50,
:51
                )'
                USING W_CL_CODE, V_IN_CLIENTS_MIG(IDX).FIRST_NAME, V_IN_CLIENTS_MIG(IDX).LAST_NAME, V_IN_CLIENTS_MIG(IDX).SUR_NAME, V_IN_CLIENTS_MIG(IDX).MIDDLE_NAME, W_NULL, NVL(V_IN_CLIENTS_MIG(IDX).CLIENT_FATHER_NAME, '.'), V_IN_CLIENTS_MIG(IDX).BIRTH_DATE, V_IN_CLIENTS_MIG(IDX).BIRTH_PLACE_CODE, V_IN_CLIENTS_MIG(IDX).BIRTH_PLACE_NAME, V_IN_CLIENTS_MIG(IDX).SEX, V_IN_CLIENTS_MIG(IDX).MARITAL_STATUS, V_IN_CLIENTS_MIG(IDX).RELIGN_CODE, V_IN_CLIENTS_MIG(IDX).NATNL_CODE, W_RESIDENT_STAT, V_IN_CLIENTS_MIG(IDX).LANG_CODE, V_IN_CLIENTS_MIG(IDX).ILLITERATE_CUST, V_IN_CLIENTS_MIG(IDX).DISABLED, V_IN_CLIENTS_MIG(IDX).FADDR_REQD, V_IN_CLIENTS_MIG(IDX).TEL_RES, V_IN_CLIENTS_MIG(IDX).TEL_OFF, V_IN_CLIENTS_MIG(IDX).TEL_OFF1, V_IN_CLIENTS_MIG(IDX).EXTN_NUM, V_IN_CLIENTS_MIG(IDX).TEL_GSM, V_IN_CLIENTS_MIG(IDX).TEL_FAX, V_IN_CLIENTS_MIG(IDX).EMAIL_ADDR1, V_IN_CLIENTS_MIG(IDX).EMAIL_ADDR2, V_IN_CLIENTS_MIG(IDX).EMPLOY_TYPE, V_IN_CLIENTS_MIG(IDX).RETIRE_PENS_FLG, V_IN_CLIENTS_MIG(IDX).RELATION_BANK_FLG, V_IN_CLIENTS_MIG(IDX).EMPLOYEE_NUM, NVL(V_IN_CLIENTS_MIG(IDX).OCCUPN_CODE, 99), V_IN_CLIENTS_MIG(IDX).EMP_COMPANY, V_IN_CLIENTS_MIG(IDX).EMP_CMP_NAME, V_IN_CLIENTS_MIG(IDX).EMP_CMP_ADDR1, V_IN_CLIENTS_MIG(IDX).EMP_CMP_ADDR2, V_IN_CLIENTS_MIG(IDX).EMP_CMP_ADDR3, V_IN_CLIENTS_MIG(IDX).EMP_CMP_ADDR4, V_IN_CLIENTS_MIG(IDX).EMP_CMP_ADDR5, V_IN_CLIENTS_MIG(IDX).DESIG_CODE, V_IN_CLIENTS_MIG(IDX).WORK_SINCE_DATE, V_IN_CLIENTS_MIG(IDX).RETIREMENT_DATE, V_IN_CLIENTS_MIG(IDX).BC_ANNUAL_INCOME, V_IN_CLIENTS_MIG(IDX).ANNUAL_INCOME_SLAB, V_IN_CLIENTS_MIG(IDX).ACCOM_TYPE, V_IN_CLIENTS_MIG(IDX).ACCOM_OTHERS, V_IN_CLIENTS_MIG(IDX).OWNS_TWO_WHEELER, V_IN_CLIENTS_MIG(IDX).OWNS_CAR, V_IN_CLIENTS_MIG(IDX).INSUR_POLICY_INFO, V_IN_CLIENTS_MIG(IDX).DEATH_DATE, V_IN_CLIENTS_MIG(IDX).PID_INV_NUM;
            EXCEPTION
              WHEN OTHERS THEN
                W_ER_CODE := 'CL3';
                W_ER_DESC := 'INSERT-INDCLIENTS-CLIENTS ' || SQLERRM;
                W_SRC_KEY := P_BRANCH_CODE || '-' || W_CL_CODE;
                POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
            END IN_INDCLIENTS;
          END IF;
        
          IF V_IN_CLIENTS_MIG(IDX).FORN_ADDR1 = 'Y' THEN
          
            <<IN_CLIENTADDR>>
            BEGIN
              EXECUTE IMMEDIATE 'INSERT INTO CLIENTSFADDR
                (CLFADDR_CLIENT_CODE,
                 CLFADDR_FORN_ADDR1,
                 CLFADDR_FORN_ADDR2,
                 CLFADDR_FORN_ADDR3,
                 CLFADDR_FORN_ADDR4,
                 CLFADDR_FORN_ADDR5,
                 CLFADDR_CNTRY_CODE,
                 CLFADDR_FORN_RES_TEL,
                 CLFADDR_FORN_OFF_TEL,
                 CLFADDR_FORN_EXTN_NUM,
                 CLFADDR_GSM_NUM)
              VALUES
                (
                :1,
                 :2,
                 :3,
                 :4,
                 :5,
                 :6,
                 :7,
                 :8,
                 :9,
                 :10,
                )
                '
                USING W_CL_CODE, V_IN_CLIENTS_MIG(IDX).FORN_ADDR1, V_IN_CLIENTS_MIG(IDX).FORN_ADDR2, V_IN_CLIENTS_MIG(IDX).FORN_ADDR3, V_IN_CLIENTS_MIG(IDX).FORN_ADDR4, V_IN_CLIENTS_MIG(IDX).FORN_ADDR5, V_IN_CLIENTS_MIG(IDX).CNTRY_CODE1, V_IN_CLIENTS_MIG(IDX).FORN_RES_TEL, V_IN_CLIENTS_MIG(IDX).FORN_OFF_TEL, V_IN_CLIENTS_MIG(IDX).FORN_EXTN_NUM, V_IN_CLIENTS_MIG(IDX).GSM_NUM;
            EXCEPTION
              WHEN OTHERS THEN
                W_ER_CODE := 'CL4';
                W_ER_DESC := 'INSERT-CLIENTADDR-CLIENTS ' || SQLERRM;
                W_SRC_KEY := P_BRANCH_CODE || '-' || W_CL_CODE;
                POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
            END IN_CLIENTADDR;
          END IF;
          --  END IF;
        
          IF V_IN_CLIENTS_MIG(IDX).MIG_TYPE_FLG = 'C' THEN
            <<IN_CORPCLIENT>>
            BEGIN
              EXECUTE IMMEDIATE 'INSERT INTO CORPCLIENTS
                (CORPCL_CLIENT_CODE,
                 CORPCL_CLIENT_NAME,
                 CORPCL_RESIDENT_STATUS,
                 CORPCL_ORGN_QUALIFIER,
                 CORPCL_SWIFT_CODE,
                 CORPCL_INDUS_CODE,
                 CORPCL_SUB_INDUS_CODE,
                 CORPCL_NATURE_OF_BUS1,
                 CORPCL_NATURE_OF_BUS2,
                 CORPCL_NATURE_OF_BUS3,
                 CORPCL_INVEST_PM_CURR,
                 CORPCL_INVEST_PM_AMT,
                 CORPCL_CAPITAL_CURR,
                 CORPCL_AUTHORIZED_CAPITAL,
                 CORPCL_ISSUED_CAPITAL,
                 CORPCL_PAIDUP_CAPITAL,
                 CORPCL_NETWORTH_AMT,
                 CORPCL_INCORP_DATE,
                 CORPCL_INCORP_CNTRY,
                 CORPCL_REG_NUM,
                 CORPCL_REG_DATE,
                 CORPCL_REG_AUTHORITY,
                 CORPCL_REG_EXPIRY_DATE,
                 CORPCL_REG_OFF_ADDR1,
                 CORPCL_REG_OFF_ADDR2,
                 CORPCL_REG_OFF_ADDR3,
                 CORPCL_REG_OFF_ADDR4,
                 CORPCL_REG_OFF_ADDR5,
                 CORPCL_TF_CLIENT,
                 CORPCL_VOSTRO_EXCG_HOUSE,
                 CORPCL_IMP_EXP_CODE,
                 CORPCL_COM_BUS_IDENTIFIER,
                 CORPCL_BUS_ENTITY_IDENTIFIER,
                 CORPCL_YEARS_IN_BUSINESS,
                 CORPCL_BC_GROSS_TURNOVER,
                 CORPCL_EMPLOYEE_SIZE,
                 CORPCL_NUM_OFFICES,
                 CORPCL_SCHEDULED_BANK,
                 CORPCL_SOVEREIGN_FLG,
                 CORPCL_TYPE_OF_SOVEREIGN,
                 CORPCL_CNTRY_CODE,
                 CORPCL_CENTRAL_STATE_FLG,
                 CORPCL_PUBLIC_SECTOR_FLG,
                 CORPCL_PRIMARY_DLR_FLG,
                 CORPCL_MULTILATERAL_BANK,
                 CORPCL_CONNP_INV_NUM,
                 CORPCL_TYPE_OF_BANK,
                 CORPCL_TYPE_OF_COOP_BANK)
              VALUES
                (
                 :1,
                 :2,
                 :3,
                 :4,
                 :5,
                 :6,
                 :7,
                 :8,
                 :9,
                 :10,
                 :11,
                 :12,
                 :13,
                 :14,
                 :15,
                 :16,
                 :17,
                 :18,
                 :19,
                 :20,
                 :21,
                 :22,
                 :23,
                 :24,
                 :25,
                 :26,
                 :27,
                 :28,
                 :29,
                 :30,
                 :31,
                 :32,
                 :33,
                 :34,
                 :35,
                 :36,
                 :37,
                 :38,
                 :39,
                 :40,
                 :41,
                 :42,
                 :43,
                 :44,
                 :45,
                 :46,
                 :47,
                 :48
                )'
                USING W_CL_CODE, V_IN_CLIENTS_MIG(IDX).FIRST_NAME, W_RESIDENT_STAT, V_IN_CLIENTS_MIG(IDX).ORGN_QUALIER, V_IN_CLIENTS_MIG(IDX).SWIFT_CODE, V_IN_CLIENTS_MIG(IDX).INDUS_CODE, V_IN_CLIENTS_MIG(IDX).SUB_INDUS_CODE, V_IN_CLIENTS_MIG(IDX).NATURE_OF_BUS1, V_IN_CLIENTS_MIG(IDX).NATURE_OF_BUS2, V_IN_CLIENTS_MIG(IDX).NATURE_OF_BUS3, V_IN_CLIENTS_MIG(IDX).INVEST_PM_CURR, V_IN_CLIENTS_MIG(IDX).INVEST_PM_AMT, NVL(V_IN_CLIENTS_MIG(IDX).CAPITAL_CURR, W_CURR_CODE), V_IN_CLIENTS_MIG(IDX).AUTHORIZED_CAPITAL, V_IN_CLIENTS_MIG(IDX).ISSUED_CAPITAL, V_IN_CLIENTS_MIG(IDX).PAIDUP_CAPITAL, V_IN_CLIENTS_MIG(IDX).NETWORTH_AMT, V_IN_CLIENTS_MIG(IDX).INCORP_DATE, V_IN_CLIENTS_MIG(IDX).INCORP_CNTRY, V_IN_CLIENTS_MIG(IDX).REG_NUM, V_IN_CLIENTS_MIG(IDX).REG_DATE, V_IN_CLIENTS_MIG(IDX).REG_AUTHORITY, V_IN_CLIENTS_MIG(IDX).REG_EXPIRY_DATE, V_IN_CLIENTS_MIG(IDX).REG_OFF_ADDR1, V_IN_CLIENTS_MIG(IDX).REG_OFF_ADDR2, V_IN_CLIENTS_MIG(IDX).REG_OFF_ADDR3, V_IN_CLIENTS_MIG(IDX).REG_OFF_ADDR4, V_IN_CLIENTS_MIG(IDX).REG_OFF_ADDR5, V_IN_CLIENTS_MIG(IDX).TF_CLIENT, V_IN_CLIENTS_MIG(IDX).VOSTRO_EXCG_HOUSE, V_IN_CLIENTS_MIG(IDX).IMP_EXP_CODE, V_IN_CLIENTS_MIG(IDX).COM_BUS_IDENTIFIER, V_IN_CLIENTS_MIG(IDX).BUS_ENTITY_IDENTIFIER, V_IN_CLIENTS_MIG(IDX).YEARS_IN_BUSINESS, V_IN_CLIENTS_MIG(IDX).BC_GROSS_TURNOVER, V_IN_CLIENTS_MIG(IDX).EMPLOYEE_SIZE, V_IN_CLIENTS_MIG(IDX).NUM_OFFICES, V_IN_CLIENTS_MIG(IDX).SCHEDULED_BANK, V_IN_CLIENTS_MIG(IDX).SOVEREIGN_FLG, V_IN_CLIENTS_MIG(IDX).TYPE_OF_SOVEREIGN, V_IN_CLIENTS_MIG(IDX).CNTRY_CODE1, V_IN_CLIENTS_MIG(IDX).CENTRAL_STATE_FLG, V_IN_CLIENTS_MIG(IDX).PUBLIC_SECTOR_FLG, V_IN_CLIENTS_MIG(IDX).PRIMARY_DLR_FLG, V_IN_CLIENTS_MIG(IDX).MULTILATERAL_BANK, V_IN_CLIENTS_MIG(IDX).PID_INV_NUM, W_NULL, W_NULL;
            EXCEPTION
              WHEN OTHERS THEN
                W_ER_CODE := 'CL5';
                W_ER_DESC := 'INSERT-CORPCLIENTS-CLIENTS ' || SQLERRM;
                W_SRC_KEY := P_BRANCH_CODE || '-' || W_CL_CODE;
                POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
            END IN_CORPCLIENT;
          END IF;
        
          FOR CONTIDX IN (SELECT CLCONTACT_CLIENT_SL,
                                 CLCONTACT_PERSON_NAME,
                                 CLCONTACT_DESIG_CODE,
                                 CLCONTACT_RES_PHONE,
                                 CLCONTACT_OFF_PHONE,
                                 CLCONTACT_OFF_EXTN_NUM,
                                 CLCONTACT_GSM
                            FROM MIG_CLIENTCONTACTS
                           WHERE CLCONTACT_CLIENT_CODE = V_IN_CLIENTS_MIG(IDX)
                                .MIG_CLIENT_CODE) LOOP
          
            <<IN_CLIENTCONTACT>>
            BEGIN
              EXECUTE IMMEDIATE 'INSERT INTO CLIENTSCONTACTS
                (CLCONTACT_CLIENT_CODE,
                 CLCONTACT_CLIENT_SL,
                 CLCONTACT_PERSON_NAME,
                 CLCONTACT_DESIG_CODE,
                 CLCONTACT_RES_PHONE,
                 CLCONTACT_OFF_PHONE,
                 CLCONTACT_OFF_EXTN_NUM,
                 CLCONTACT_GSM)
              VALUES
                (
                 :1,
                 :2,
                 :3,
                 :4,
                 :5,
                 :6,
                 :7,
                 :8
                )'
                USING W_CL_CODE, CONTIDX.CLCONTACT_CLIENT_SL, CONTIDX.CLCONTACT_PERSON_NAME, CONTIDX.CLCONTACT_DESIG_CODE, CONTIDX.CLCONTACT_RES_PHONE, CONTIDX.CLCONTACT_OFF_PHONE, CONTIDX.CLCONTACT_OFF_EXTN_NUM, CONTIDX.CLCONTACT_GSM;
            EXCEPTION
              WHEN OTHERS THEN
                W_ER_CODE := 'CL6';
                W_ER_DESC := 'INSERT-CLIENTCONTACTS-CLIENTS ' || SQLERRM;
                W_SRC_KEY := P_BRANCH_CODE || '-' || W_CL_CODE;
                POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
            END IN_CLIENTCONTACT;
          END LOOP;
        
          FOR BKIDX IN (SELECT CLBKDTL_BK_SL,
                               CLBKDTL_BANK_NAME,
                               CLBKDTL_BRN_NAME,
                               CLBKDTL_OTH_ACNT_NUMBER,
                               CLBKDTL_TYPE_FACILITIES
                          FROM MIG_CLIENTSBKDTL
                         WHERE CLBKDTL_CLIENT_CODE = V_IN_CLIENTS_MIG(IDX)
                              .MIG_CLIENT_CODE) LOOP
            <<IN_CLIENTBK>>
            BEGIN
              EXECUTE IMMEDIATE 'INSERT INTO CLIENTSBKDTL
                (CLBKDTL_CLIENT_CODE,
                 CLBKDTL_BK_SL,
                 CLBKDTL_BANK_NAME,
                 CLBKDTL_BRN_NAME,
                 CLBKDTL_OTH_ACNT_NUMBER,
                 CLBKDTL_TYPE_FACILITIES)
              VALUES
                (
                 :1,
                 :2,
                 :3,
                 :4,
                 :5,
                 :6
                )'
                USING W_CL_CODE, BKIDX.CLBKDTL_BK_SL, BKIDX.CLBKDTL_BANK_NAME, BKIDX.CLBKDTL_BRN_NAME, BKIDX.CLBKDTL_OTH_ACNT_NUMBER, BKIDX.CLBKDTL_TYPE_FACILITIES;
            EXCEPTION
              WHEN OTHERS THEN
                W_ER_CODE := 'CL7';
                W_ER_DESC := 'INSERT-CLIENTBKDTL-CLIENTS ' || SQLERRM;
                W_SRC_KEY := P_BRANCH_CODE || '-' || W_CL_CODE;
                POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
            END IN_CLIENTBK;
          END LOOP;
        
          W_PID_INVNUM := 0;
          IF W_PAN_GIR_NUM IS NOT NULL AND W_PAN_GIR_NUM <> '0' THEN
            W_LAST_NUM_USED := W_LAST_NUM_USED + 1;
            <<IN_PIDDOC>>
            BEGIN
              EXECUTE IMMEDIATE 'INSERT INTO PIDDOCS
                (PIDDOCS_INV_NUM,
                 PIDDOCS_DOC_SL,
                 PIDDOCS_PID_TYPE,
                 PIDDOCS_DOCID_NUM,
                 PIDDOCS_CARD_NUM,
                 PIDDOCS_ISSUE_DATE,
                 PIDDOCS_ISSUE_PLACE,
                 PIDDOCS_ISSUE_AUTHORITY,
                 PIDDOCS_ISSUE_CNTRY,
                 PIDDOCS_EXP_DATE,
                 PIDDOCS_SPONSOR_NAME,
                 PIDDOCS_SPONSOR_ADDR1,
                 PIDDOCS_SPONSOR_ADDR2,
                 PIDDOCS_SPONSOR_ADDR3,
                 PIDDOCS_SPONSOR_ADDR4,
                 PIDDOCS_SPONSOR_ADDR5,
                 PIDDOCS_FOR_ADDR_PROOF,
                 PIDDOCS_FOR_IDENTITY_CHK,
                 PIDDOCS_SOURCE_TABLE,
                 PIDDOCS_SOURCE_KEY)
              VALUES
                (
                 :1,
                 :2,
                 :3,
                 :4,
                 :5,
                 :6,
                 :7,
                 :8,
                 :9,
                 :10,
                 :11,
                 :12,
                 :13,
                 :14,
                 :15,
                 :16,
                 :17,
                 :18,
                 :19,
                 :20
                )'
                USING W_LAST_NUM_USED, 1, 'PAN', W_PAN_GIR_NUM, W_NULL, W_NULL, W_NULL, W_NULL, W_NULL, W_NULL, W_NULL, W_NULL, W_NULL, W_NULL, W_NULL, W_NULL, '1', '1', 'INDCLIENTS', W_CL_CODE;
              EXECUTE IMMEDIATE 'UPDATE INDCLIENTS
             SET INDCLIENT_PID_INV_NUM = :1
           WHERE INDCLIENT_CODE = :2'
                USING W_LAST_NUM_USED, W_CL_CODE;
            
              W_PID_INVNUM := W_LAST_NUM_USED;
            
            EXCEPTION
              WHEN OTHERS THEN
                W_ER_CODE := 'CL9';
                W_ER_DESC := 'INSERT-PIDDOCS-CLIENTS ' || SQLERRM;
                W_SRC_KEY := P_BRANCH_CODE || '-' || W_CL_CODE;
                POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
            END IN_PIDDOC;
          END IF;
          --Added by Ramesh M
          /* SELECT OLD_CLCODE INTO W_OLD_CLN FROM TEMP_CLIENT
          WHERE  NEW_CLCODE=W_CL_CODE;*/
          --ADDED BY RAMESH M  ON 29/03/2012
          W_OLD_CLN := V_IN_CLIENTS_MIG(IDX).MIG_CLIENT_CODE;
          W_FLAG    := 0;
          FOR PDX IN (SELECT PIDDOCS_CLIENTS_CODE,
                             PIDDOCS_DOC_SL,
                             PIDDOCS_PID_TYPE,
                             PIDDOCS_DOCID_NUM,
                             PIDDOCS_CARD_NUM,
                             PIDDOCS_ISSUE_DATE,
                             PIDDOCS_ISSUE_PLACE,
                             PIDDOCS_ISSUE_AUTHORITY,
                             PIDDOCS_ISSUE_CNTRY,
                             PIDDOCS_EXP_DATE,
                             PIDDOCS_SPONSOR_NAME,
                             PIDDOCS_SPONSOR_ADDR1,
                             PIDDOCS_SPONSOR_ADDR2,
                             PIDDOCS_SPONSOR_ADDR3,
                             PIDDOCS_SPONSOR_ADDR4,
                             PIDDOCS_SPONSOR_ADDR5,
                             PIDDOCS_FOR_ADDR_PROOF,
                             PIDDOCS_FOR_IDENTITY_CHK
                        FROM MIG_PIDDOCS
                       WHERE PIDDOCS_CLIENTS_CODE = W_OLD_CLN) LOOP
            IF PDX.PIDDOCS_PID_TYPE IS NOT NULL THEN
              --RAMESH M
              IF W_FLAG = 0 THEN
                --RAMESH M
                IF W_PAN_GIR_NUM IS NULL or W_PAN_GIR_NUM = '0' THEN
                  W_LAST_NUM_USED := W_LAST_NUM_USED + 1;
                  W_FLAG          := 1;
                END IF;
              END IF;
              <<IN_PIDDOC2>>
              BEGIN
                INSERT INTO PIDDOCS
                  (PIDDOCS_INV_NUM,
                   PIDDOCS_DOC_SL,
                   PIDDOCS_PID_TYPE,
                   PIDDOCS_DOCID_NUM,
                   PIDDOCS_CARD_NUM,
                   PIDDOCS_ISSUE_DATE,
                   PIDDOCS_ISSUE_PLACE,
                   PIDDOCS_ISSUE_AUTHORITY,
                   PIDDOCS_ISSUE_CNTRY,
                   PIDDOCS_EXP_DATE,
                   PIDDOCS_SPONSOR_NAME,
                   PIDDOCS_SPONSOR_ADDR1,
                   PIDDOCS_SPONSOR_ADDR2,
                   PIDDOCS_SPONSOR_ADDR3,
                   PIDDOCS_SPONSOR_ADDR4,
                   PIDDOCS_SPONSOR_ADDR5,
                   PIDDOCS_FOR_ADDR_PROOF,
                   PIDDOCS_FOR_IDENTITY_CHK,
                   PIDDOCS_SOURCE_TABLE,
                   PIDDOCS_SOURCE_KEY)
                VALUES
                  (W_LAST_NUM_USED,
                   (SELECT NVL(MAX(PIDDOCS_DOC_SL), 0) + 1
                      FROM PIDDOCS
                     WHERE PIDDOCS_INV_NUM = W_LAST_NUM_USED
                       AND PIDDOCS_SOURCE_KEY = W_CL_CODE),
                   PDX.PIDDOCS_PID_TYPE,
                   PDX.PIDDOCS_DOCID_NUM,
                   PDX.PIDDOCS_CARD_NUM,
                   PDX.PIDDOCS_ISSUE_DATE,
                   PDX.PIDDOCS_ISSUE_PLACE,
                   PDX.PIDDOCS_ISSUE_AUTHORITY,
                   PDX.PIDDOCS_ISSUE_CNTRY,
                   PDX.PIDDOCS_EXP_DATE,
                   PDX.PIDDOCS_SPONSOR_NAME,
                   PDX.PIDDOCS_SPONSOR_ADDR1,
                   PDX.PIDDOCS_SPONSOR_ADDR2,
                   PDX.PIDDOCS_SPONSOR_ADDR3,
                   PDX.PIDDOCS_SPONSOR_ADDR4,
                   PDX.PIDDOCS_SPONSOR_ADDR5,
                   PDX.PIDDOCS_FOR_ADDR_PROOF,
                   PDX.PIDDOCS_FOR_IDENTITY_CHK,
                   'INDCLIENTS',
                   W_CL_CODE);
              
                IF W_PAN_GIR_NUM IS NULL or W_PAN_GIR_NUM = '0' THEN
                  EXECUTE IMMEDIATE 'UPDATE INDCLIENTS
                   SET INDCLIENT_PID_INV_NUM = :1
                   WHERE INDCLIENT_CODE = :2'
                    USING W_LAST_NUM_USED, W_CL_CODE;
                END IF;
              EXCEPTION
                WHEN OTHERS THEN
                  W_ER_CODE := 'CL10';
                  W_ER_DESC := 'INSERT-PIDDOCS-CLIENTS ' || SQLERRM;
                  W_SRC_KEY := P_BRANCH_CODE || '-' || W_CL_CODE;
                  POST_ERR_LOG(W_SRC_KEY,
                               W_CURR_DATE,
                               W_ER_CODE,
                               W_ER_DESC);
              END IN_PIDDOC2;
            END IF;
          END LOOP;
          --Added by Ramesh M Ends
        
          W_PNT := W_PNT + 1;
        
          --      W_LAST_NUM_USED := 0;
          /*
          FOR CDX IN (SELECT CONNP_AC_CLIENT_FLAG,
                             CONNP_ACCOUNT_NUMBER,
                             CONNP_SERIAL,
                             CONNP_CONN_ROLE,
                             CONNP_CONN_ACNUM,
                             CONNP_CONN_CLIENT_NUM,
                             CONNP_CLIENT_NAME,
                             CONNP_DATE_OF_BIRTH,
                             CONNP_CLIENT_DEPT,
                             CONNP_DESIG_CODE,
                             CONNP_CLIENT_ADDR1,
                             CONNP_CLIENT_ADDR2,
                             CONNP_CLIENT_ADDR3,
                             CONNP_CLIENT_ADDR4,
                             CONNP_CLIENT_ADDR5,
                             CONNP_CLIENT_CNTRY,
                             CONNP_NATURE_OF_GUARDIAN,
                             CONNP_GUARDIAN_FOR,
                             CONNP_GUARDIAN_FOR_CLIENT,
                             CONNP_RELATIONSHIP_INFO,
                             CONNP_RES_TEL,
                             CONNP_OFF_TEL,
                             CONNP_GSM_NUM,
                             CONNP_EMAIL_ADDR,
                             CONNP_REM1,
                             CONNP_REM2,
                             CONNP_REM3,
                             CONNP_SHARE_HOLD_PER
                        FROM MIG_CONNPINFO
                       WHERE CONNP_CLIENT_CODE = V_IN_CLIENTS_MIG(IDX)
                      .MIG_CLIENT_CODE) LOOP
          
            IF CDX.CONNP_AC_CLIENT_FLAG = 'C' THEN
          
              <<IN_CONNPINFO>>
              BEGIN
                w_connp_num := w_connp_num + 1;
                execute immediate 'INSERT INTO CONNPINFO
                  (CONNP_INV_NUM,
                   CONNP_CONN_ROLE,
                   CONNP_SL,
                   CONNP_INTERNAL_ACNUM,
                   CONNP_CLIENT_NUM,
                   CONNP_CLIENT_NAME,
                   CONNP_DATE_OF_BIRTH,
                   CONNP_CLIENT_DEPT,
                   CONNP_DESIG_CODE,
                   CONNP_CLIENT_ADDR1,
                   CONNP_CLIENT_ADDR2,
                   CONNP_CLIENT_ADDR3,
                   CONNP_CLIENT_ADDR4,
                   CONNP_CLIENT_ADDR5,
                   CONNP_CLIENT_CNTRY,
                   CONNP_NATURE_OF_GUARDIAN,
                   CONNP_GUARDIAN_FOR,
                   CONNP_GUARDIAN_FOR_CLIENT,
                   CONNP_RELATIONSHIP_INFO,
                   CONNP_RES_TEL,
                   CONNP_OFF_TEL,
                   CONNP_GSM_NUM,
                   CONNP_EMAIL_ADDR,
                   CONNP_REM1,
                   CONNP_REM2,
                   CONNP_REM3,
                   CONNP_SHARE_HOLD_PER,
                   CONNP_PID_INV_NUM,
                   CONNP_SOURCE_TABLE,
                   CONNP_SOURCE_KEY)
                VALUES
                  (
                   :1,
                   :2,
                   :3,
                   :4,
                   :5,
                   :6,
                   :7,
                   :8,
                   :9,
                   :10,
                   :11,
                   :12,
                   :13,
                   :14,
                   :15,
                   :16,
                   :17,
                   :18,
                   :19,
                   :20,
                   :21,
                   :22,
                   :23,
                   :24,
                   :25,
                   :26,
                   :27,
                   :28,
                   :29,
                   :30
                  )'
                  using w_connp_num, CDX.CONNP_CONN_ROLE, CDX.CONNP_SERIAL, 0, --CDX.CONNP_ACCOUNT_NUMBER,
                W_CL_CODE, --CDX.CONNP_CONN_CLIENT_NUM,
                CDX.CONNP_CLIENT_NAME, CDX.CONNP_DATE_OF_BIRTH, CDX.CONNP_CLIENT_DEPT, CDX.CONNP_DESIG_CODE, CDX.CONNP_CLIENT_ADDR1, CDX.CONNP_CLIENT_ADDR2, CDX.CONNP_CLIENT_ADDR3, CDX.CONNP_CLIENT_ADDR4, CDX.CONNP_CLIENT_ADDR5, CDX.CONNP_CLIENT_CNTRY, CDX.CONNP_NATURE_OF_GUARDIAN, CDX.CONNP_GUARDIAN_FOR, CDX.CONNP_GUARDIAN_FOR_CLIENT, CDX.CONNP_RELATIONSHIP_INFO, CDX.CONNP_RES_TEL, CDX.CONNP_OFF_TEL, CDX.CONNP_GSM_NUM, CDX.CONNP_EMAIL_ADDR, CDX.CONNP_REM1, CDX.CONNP_REM2, CDX.CONNP_REM3, CDX.CONNP_SHARE_HOLD_PER, W_PID_INVNUM, 'CORPCLIENTS', W_CL_CODE;
                W_CNT := W_CNT + 1;
              EXCEPTION
                WHEN OTHERS THEN
                  W_ER_CODE := 'CL11';
                  W_ER_DESC := 'INSERT-CONPINFO-CLIENTS ' || SQLERRM;
                  W_SRC_KEY := P_BRANCH_CODE || '-' || W_CL_CODE;
                  POST_ERR_LOG(W_SRC_KEY,
                               W_CURR_DATE,
                               W_ER_CODE,
                               W_ER_DESC);
              END IN_CONNPINFO;
            END IF;
          END LOOP;
             */
        
        END IF;
      
      END LOOP;
    END IF;
  
    --COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      P_ERR_MSG := SQLERRM || 'MAIN';
      ---ROLLBACK;
  
  END MIGRATE_CLIENTS;
BEGIN
  DBMS_OUTPUT.ENABLE(9000000);
  --W_CNT := 1;
  W_PNT := 1;
  SELECT MN_CURR_BUSINESS_DATE INTO W_CURR_DATE FROM MAINCONT;

  <<MIG_CHECK>>
  BEGIN
    SELECT TO_NUMBER(CLIENTS_HOME_BRN_CODE),
           TO_NUMBER(CLIENTS_CODE),
           'MIG' MIG_ENTD_BY,
           '01-APR-2009' MIG_ENTD_ON BULK COLLECT
      INTO V_GEN_CLIENT
      FROM MIG_CLIENTS
     WHERE CLIENTS_HOME_BRN_CODE = P_BRANCH_CODE;
  
  EXCEPTION
    WHEN OTHERS THEN
      P_ERR_MSG := SQLERRM || ' No Data Found in Mig_clients ';
      ROLLBACK;
  END MIG_CHECK;

  --dbms_output.put_line(V_IN_CLIENTS_MIG.count);

  IF V_GEN_CLIENT.COUNT > 0 THEN
    FOR IDX IN V_GEN_CLIENT.FIRST .. V_GEN_CLIENT.LAST LOOP
    
      SP_MIG_CLIENTCODE('A',
                        V_GEN_CLIENT(IDX).ENTD_BY,
                        V_GEN_CLIENT(IDX).ENTD_ON,
                        W_CL_CODE,
                        P_ERR_MSG);
      IF P_ERR_MSG IS NOT NULL THEN
        W_ER_CODE := 'CL11';
        W_ER_DESC := 'ERROR IN CLIENTCODE GENERATING IN CLIENTS' || SQLERRM;
        W_SRC_KEY := P_BRANCH_CODE || '-' || W_CL_CODE;
        POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
      END IF;
    
      EXECUTE IMMEDIATE 'INSERT INTO TEMP_CLIENT
      VALUES
        (
         :1,:2,:3
        )'
        USING V_GEN_CLIENT(IDX).BRN_CODE, V_GEN_CLIENT(IDX).OLD_CLCODE, W_CL_CODE;
    END LOOP;
  END IF;

  EXECUTE IMMEDIATE 'SELECT MBRN_LOCN_CODE FROM MBRN WHERE MBRN_ENTITY_NUM=:1 and MBRN_CODE =:2'
    INTO W_LOC_CODE
    USING W_ENTITY_NUM, P_BRANCH_CODE;

  SELECT INVNUM_LAST_NUM_USED
    INTO W_LAST_NUM_USED
    FROM INVNUM
   WHERE INVNUM_SOURCE_TYPE = 'P';

  SELECT INVNUM_LAST_NUM_USED
    INTO W_ADDR_INVNUM
    FROM INVNUM
   WHERE INVNUM_SOURCE_TYPE = 'A';

  SELECT INVNUM_LAST_NUM_USED
    INTO W_CONNP_NUM
    FROM INVNUM
   WHERE INVNUM_SOURCE_TYPE = 'C';

  --SELECT INS_BASE_CURR_CODE INTO W_BASE_CURR FROM INSTALL;
  OPEN RCCLIENTS FOR '  SELECT
         CLIENTS_CODE ,
         CLIENTS_TYPE_FLG ,
         CLIENTS_HOME_BRN_CODE,
         clients_TITLE_CODE,
         CLIENT_FIRST_NAME,
         CLIENT_LAST_NAME,
         CLIENT_SUR_NAME,
         CLIENT_MIDDLE_NAME,
         NVL(TRIM(CLIENTS_NAME), TRIM(CLIENT_FIRST_NAME)) CLIENTS_NAME,
         CLIENT_FATHER_NAME,
         CLIENTS_CONST_CODE,
         CLIENTS_ADDR1,
         CLIENTS_ADDR2,
         CLIENTS_ADDR3,
         CLIENTS_ADDR4,
         CLIENTS_ADDR5,
         CLIENTS_LOCN_CODE,
         CLIENTS_CUST_CATG,
         CLIENTS_CUST_SUB_CATG,
         CLIENTS_SEGMENT_CODE,
         CLIENTS_BUSDIVN_CODE,
         CLIENTS_RISK_CNTRY,
         CLIENTS_NUM_OF_DOCS,
         CLIENTS_CONT_PERSON_AVL,
         CLIENTS_CR_LIMITS_OTH_BK,
         CLIENTS_ACS_WITH_OTH_BK,
         CLIENTS_OPENING_DATE,
         CLIENTS_GROUP_CODE,
         CLIENTS_PAN_GIR_NUM,
         CLIENTS_IT_STAT_CODE,
         CLIENTS_IT_SUB_STAT_CODE,
         CLIENTS_EXEMP_IN_TDS,
         CLIENTS_EXEMP_TDS_PER,
         CLIENTS_EXEMP_REM1,
         CLIENTS_EXEMP_REM2,
         CLIENTS_EXEMP_REM3,
         CLIENTS_BSR_TYPE_FLG,
         CLIENTS_RISK_CATEGORIZATION,
         CLIENTS_BIRTH_DATE,
         CLIENTS_BIRTH_PLACE_CODE,
         CLIENTS_BIRTH_PLACE_NAME,
         CLIENTS_SEX,
         CLIENTS_MARITAL_STATUS,
         CLIENTS_RELIGN_CODE,
         CLIENTS_NATNL_CODE,
         CLIENTS_RESIDENT_STATUS,
         CLIENTS_LANG_CODE,
         CLIENTS_ILLITERATE_CUST,
         CLIENTS_DISABLED,
         CLIENTS_FADDR_REQD,
         CLIENTS_TEL_RES,
         CLIENTS_TEL_OFF,
         CLIENTS_TEL_OFF1,
         CLIENTS_EXTN_NUM,
         CLIENTS_TEL_GSM,
         CLIENTS_TEL_FAX,
         CLIENTS_EMAIL_ADDR1,
         CLIENTS_EMAIL_ADDR2,
         CLIENTS_EMPLOY_TYPE,
         CLIENTS_RETIRE_PENS_FLG,
         CLIENTS_RELATION_BANK_FLG,
         CLIENTS_EMPLOYEE_NUM,
         CLIENTS_OCCUPN_CODE,
         CLIENTS_EMP_COMPANY,
         CLIENTS_EMP_CMP_NAME,
         CLIENTS_EMP_CMP_ADDR1,
         CLIENTS_EMP_CMP_ADDR2,
         CLIENTS_EMP_CMP_ADDR3,
         CLIENTS_EMP_CMP_ADDR4,
         CLIENTS_EMP_CMP_ADDR5,
         CLIENTS_DESIG_CODE,
         CLIENTS_WORK_SINCE_DATE,
         CLIENTS_RETIREMENT_DATE,
         CLIENTS_BC_ANNUAL_INCOME,
         CLIENTS_ANNUAL_INCOME_SLAB,
         CLIENTS_ACCOM_TYPE,
         CLIENTS_ACCOM_OTHERS,
         CLIENTS_OWNS_TWO_WHEELER,
         CLIENTS_OWNS_CAR,
         CLIENTS_INSUR_POLICY_INFO,
         CLIENTS_DEATH_DATE,
         CLIENTS_PID_INV_NUM,
        CLIENTS_ORGN_QUALIFIER,
        CLIENTS_SWIFT_CODE,
        CLIENTS_INDUS_CODE,
        CLIENTS_SUB_INDUS_CODE,
        CLIENTS_NATURE_OF_BUS1,
        CLIENTS_NATURE_OF_BUS2,
        CLIENTS_NATURE_OF_BUS3,
        CLIENTS_INVEST_PM_CURR  ,
        CLIENTS_INVEST_PM_AMT  ,
        CLIENTS_CAPITAL_CURR  ,
        CLIENTS_AUTHORIZED_CAPITAL  ,
        CLIENTS_ISSUED_CAPITAL  ,
        CLIENTS_PAIDUP_CAPITAL  ,
        CLIENTS_NETWORTH_AMT  ,
        CLIENTS_INCORP_DATE  ,
        CLIENTS_INCORP_CNTRY  ,
        CLIENTS_REG_NUM  ,
        CLIENTS_REG_DATE  ,
        CLIENTS_REG_AUTHORITY  ,
        CLIENTS_REG_EXPIRY_DATE  ,
        CLIENTS_REG_OFF_ADDR1  ,
        CLIENTS_REG_OFF_ADDR2  ,
        CLIENTS_REG_OFF_ADDR3  ,
        CLIENTS_REG_OFF_ADDR4  ,
        CLIENTS_REG_OFF_ADDR5  ,
        CLIENTS_TF_CLIENT  ,
        CLIENTS_VOSTRO_EXCG_HOUSE  ,
        CLIENTS_IMP_EXP_CODE  ,
        CLIENTS_COM_BUS_IDENTIFIER  ,
        CLIENTS_BUS_ENTITY_IDENTIFIER  ,
        CLIENTS_YEARS_IN_BUSINESS  ,
        CLIENTS_BC_GROSS_TURNOVER  ,
        CLIENTS_EMPLOYEE_SIZE  ,
        CLIENTS_NUM_OFFICES  ,
        CLIENTS_SCHEDULED_BANK  ,
        CLIENTS_SOVEREIGN_FLG  ,
        CLIENTS_TYPE_OF_SOVEREIGN  ,
        CLIENTS_CNTRY_CODE  ,
        CLIENTS_CENTRAL_STATE_FLG  ,
        CLIENTS_PUBLIC_SECTOR_FLG  ,
        CLIENTS_PRIMARY_DLR_FLG  ,
        CLIENTS_MULTILATERAL_BANK  ,
        CLIENTS_ENTD_BY  ,
        CLIENTS_ENTD_ON  ,
        CLIENTS_FORN_ADDR1  ,
        CLIENTS_FORN_ADDR2  ,
        CLIENTS_FORN_ADDR3  ,
        CLIENTS_FORN_ADDR4  ,
        CLIENTS_FORN_ADDR5  ,
        CLIENTS_CNTRY_CODE2  ,
        CLIENTS_FORN_RES_TEL  ,
        CLIENTS_FORN_OFF_TEL  ,
        CLIENTS_FORN_EXTN_NUM  ,
        CLIENTS_GSM_NUM  ,
        CLIENTS_MEMBERSHIP_NUM  ,
        CLIENTS_ITFORM,
        CLIENTS_RECPT_DATE,
        CLIENTS_DECEASED_APPL
    FROM MIG_CLIENTS
   WHERE CLIENTS_HOME_BRN_CODE =' || P_BRANCH_CODE;

  -- Open Cursor for the SQL
  LOOP
    P_ERR_MSG := '0';
    -- FETCH INTO VAR BULK COLLECT WITH LIMIT
    FETCH RCCLIENTS BULK COLLECT
      INTO V_IN_CLIENTS_MIG LIMIT 10000;
    EXIT WHEN V_IN_CLIENTS_MIG.COUNT = 0 OR P_ERR_MSG <> '0';
    MIGRATE_CLIENTS;
    IF P_ERR_MSG <> '0' THEN
      RAISE MYEXCEPTION;
    END IF;
    COMMIT;
  END LOOP;

  UPDATE INVNUM
     SET INVNUM_LAST_NUM_USED = W_LAST_NUM_USED
   WHERE INVNUM_SOURCE_TYPE = 'P';

  UPDATE INVNUM
     SET INVNUM_LAST_NUM_USED = W_ADDR_INVNUM
   WHERE INVNUM_SOURCE_TYPE = 'A';

  INSERT INTO CORPCLINEACT
    SELECT CLIENTS_CODE, 1, 50
      FROM CLIENTS
     WHERE CLIENTS.CLIENTS_TYPE_FLG = 'C';

  UPDATE INDCLIENTS SET INDCLIENT_RELATION_BANK_FLG = 'N';

  UPDATE INDCLIENTS SET INDCLIENTS.INDCLIENT_EXTN_NUM = 0;
  -- RAMESH M ON 24/MAY/12 (PIDDOCS)
  DECLARE
  BEGIN
    SP_MIG_PIDDOCS;
  EXCEPTION
    WHEN OTHERS THEN
      W_ER_CODE := 'CL9';
      W_ER_DESC := 'INSERT-PIDDOCS-CLIENTS ' || SQLERRM;
      W_SRC_KEY := P_BRANCH_CODE || '-' || W_CL_CODE;
      POST_ERR_LOG(W_SRC_KEY, W_CURR_DATE, W_ER_CODE, W_ER_DESC);
  END;
  --RAMESH M 24/MAY/2012
  COMMIT;

  /*
  
  Default Updates
  update corpclients set corpcl_incorp_date=(select
  min(acnts_opening_date) from acnts where acnts.acnts_client_num=corpclients.corpcl_client_code)
  ,corpcl_incorp_cntry='IN',
  corpcl_bc_gross_turnover=1,corpcl_indus_code=decode(corpcl_indus_code,null,'50',corpcl_indus_code),
  corpcl_employee_size=1,corpclients.corpcl_orgn_qualifier='O';
  
  update clients set clients.clients_it_stat_code='OC'
  where clients.clients_type_flg='C';
  
    For clients and jointclients
    TRUNCATE TABLE TEMP_CLIENT;
    TRUNCATE TABLE CLIENTS;
    TRUNCATE TABLE CLIENTSBKDTL;
    TRUNCATE TABLE INDCLIENTS;
    TRUNCATE TABLE CLIENTSCONTACTS;
    TRUNCATE TABLE CONNPINFO;
    TRUNCATE TABLE PIDDOCS;
    TRUNCATE TABLE JOINTCLIENTS;
    TRUNCATE TABLE JOINTCLIENTSDTL;
    TRUNCATE TABLE CORPCLIENTS;
    TRUNCATE TABLE CLIENTNUM;
    Truncate table ADDRDTLS;
    Truncate table corpclineact;
    */

EXCEPTION
  WHEN MYEXCEPTION THEN
    ROLLBACK;
  WHEN OTHERS THEN
    P_ERR_MSG := SQLERRM || 'MAIN - CURSOR ';
    ROLLBACK;
END SP_MIG_CLIENTS;
/
