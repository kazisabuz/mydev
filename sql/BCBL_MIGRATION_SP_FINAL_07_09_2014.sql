/*Full data extraction script for the BCBL. Data will be extracted from staller system(ERA infotech)*/

DROP TABLE MIG_DATA_COLLECT_ERROR;

CREATE TABLE MIG_DATA_COLLECT_ERROR
(
  MIG_BRANCH_CODE  NUMBER(6),
  MIG_SQLERRCODE   VARCHAR2(10 BYTE),
  MIG_SQL_ERRM     VARCHAR2(4000 BYTE),
  TABLE_NAME       VARCHAR2(300 BYTE)
)
TABLESPACE TBAML;

CREATE TABLE BCBL_CHART_ACCOUNT(HEAD_CODE VARCHAR2(300), ACOUNT_CODE VARCHAR2(300),    ACCOUNT_NAME  VARCHAR2(300),   DB_CR_CLASS  VARCHAR2(300),   GEN_SUB_FLAG  VARCHAR2(300),   ACCTTYPE VARCHAR2(300), INTELLECT_GL NUMBER(10))

-- AFTER CREATE THIS TABLE PLEASE UPLOAD CHART ACCOUNT LIST EXCEL FILE 

CREATE OR REPLACE PROCEDURE SP_MIGRATION_DATA_CROSSMATCH
IS 
BEGIN

        -- UPDATING ACCOUNT INTELLECT GL INFORMATION WITH CURRENT ACCOUNT INFORMATION
    BEGIN
        DECLARE
        CURSOR C1 IS 
        SELECT * FROM PRODUCTS;
        BEGIN
        FOR I IN C1 LOOP
        UPDATE MIG_ACCOUNT_CROSS_MATCH
        SET INT_AC_GL_CODE=I.PRODUCT_GLACC_CODE
        WHERE INT_AC_PROD_CODE=I.PRODUCT_CODE;
        END LOOP;
        END;

    END;

    BEGIN
        -- UPDATING ACCOUNT INTELLECT GL INFORMATION WITH CURRENT ACCOUNT INFORMATION
        DECLARE
        CURSOR C1 IS 
        SELECT DISTINCT ACTYPE, GLCODE 
        FROM STLBAS.STFACCUR;
        BEGIN
        FOR I IN C1 LOOP
        UPDATE MIG_ACCOUNT_CROSS_MATCH
        SET STL_AC_GL_CODE=I.GLCODE
        WHERE STL_AC_TYPE=I.ACTYPE;
        END LOOP;
        END;
    END;
    
    BEGIN
            
        ------------- GL LIST MAPING AND FINDING NEW GL------------------
        DECLARE
        V_STL_GL_CODE VARCHAR2(300);
        V_ACCTNAME VARCHAR2(300);
        CURSOR C1 IS 
        SELECT * FROM MIG_GLOP_BAL;
        BEGIN
        FOR I IN C1 LOOP
        BEGIN
        SELECT STL_GL_CODE
        INTO V_STL_GL_CODE
        FROM MIG_STL_GL_MAPING
        WHERE STL_GL_CODE=I.GLOP_GL_HEAD;

         IF V_STL_GL_CODE IS NOT NULL THEN
          UPDATE MIG_STL_GL_MAPING
          SET STL_BALANCE=I.GLOP_BALANCE, MAP_DATE=SYSDATE, STATUS='Y'
         WHERE STL_GL_CODE=I.GLOP_GL_HEAD;
         END IF;
        EXCEPTION 
                WHEN NO_DATA_FOUND THEN
                
                BEGIN
                  SELECT ACCTNAME
                  INTO V_ACCTNAME
                  FROM  STLBAS.STCHRTAC
                  WHERE ACCTCODE=I.GLOP_GL_HEAD;
                  
                  EXCEPTION 
                        WHEN NO_DATA_FOUND THEN 
                        V_ACCTNAME:='GL NAME NOT FOUND IN STLBAS';
                        WHEN OTHERS THEN 
                        V_ACCTNAME:='OTHERS ERROR'||SQLCODE;
                END; 
                
                    INSERT INTO MIG_STL_GL_MAPING(INT_GL_CODE, STL_GL_CODE, INT_BALANCE, STL_BALANCE, STATUS, NARATION, MAP_DATE)
                    VALUES (NULL,I.GLOP_GL_HEAD,NULL,I.GLOP_BALANCE,'N',V_ACCTNAME,SYSDATE);
         END;
        END LOOP;
        END;
    END;
    
    --- UPDATING NEW GL USING BCBL GL MAPING EXCEL FILE 
    BEGIN

        ---------------- NEW GL MAPING -----------------------
        BEGIN
        FOR I IN (SELECT INTELLECT_GL, ACOUNT_CODE
        FROM BCBL_CHART_ACCOUNT SA, MIG_STL_GL_MAPING NA
        WHERE SA.ACOUNT_CODE=NA.STL_GL_CODE
        AND STATUS = 'N'
        AND INTELLECT_GL NOT LIKE '%,%' 
        AND INTELLECT_GL IS NOT NULL) LOOP

        UPDATE MIG_STL_GL_MAPING
        SET INT_GL_CODE=I.INTELLECT_GL
        WHERE STL_GL_CODE=I.ACOUNT_CODE
        AND STATUS = 'N'
        AND INT_GL_CODE IS NULL;

        COMMIT;
        END LOOP;
        END;
    END;
    
    BEGIN

---------------- GL MAPING FOR GL OPBAL-----------------------

        DECLARE 
        CURSOR C1 IS 
        SELECT * FROM MIG_GLOP_BAL;
        BEGIN
        FOR I IN C1 LOOP
        UPDATE MIG_GLOP_BAL
        SET GLOP_GL_HEAD=NVL((SELECT INT_GL_CODE
        FROM MIG_STL_GL_MAPING
        WHERE STL_GL_CODE=I.GLOP_GL_HEAD),GLOP_GL_HEAD)
        WHERE GLOP_GL_HEAD=I.GLOP_GL_HEAD;
        END LOOP;
        END;

---------------- GL MAPING FOR ACNTS-----------------------
        DECLARE
        CURSOR C1 IS 
        SELECT * FROM MIG_ACCOUNT_CROSS_MATCH;
        BEGIN
        FOR I IN C1 LOOP
        UPDATE MIG_ACNTS
        SET ACNTS_PROD_CODE=I.INT_AC_PROD_CODE,
        ACNTS_AC_TYPE=I.INT_AC_TYPE,
        ACNTS_GLACC_CODE=I.INT_AC_GL_CODE
        WHERE ACNTS_AC_TYPE=I.STL_AC_TYPE;
        END LOOP;
        END;

---------------- GL MAPING FOR ACOPBAL -----------------------
        DECLARE 
        CURSOR C1 IS 
        SELECT * FROM MIG_ACNTS;
        BEGIN
        FOR I IN C1 LOOP
        UPDATE MIG_ACOP_BAL
        SET ACOP_GL_HEAD=I.ACNTS_GLACC_CODE
        WHERE ACOP_AC_NUM=I.ACNTS_ACNUM;
        END LOOP;
        END;
    
    END;
    
    BEGIN
        ----------------------   DEPIA CONTRA POSTING -------------
        DECLARE
        CURSOR C1 IS 
        SELECT * FROM MIG_DEPIA
        WHERE DEPIA_ENTRY_TYPE='IP';
        BEGIN
        FOR I IN C1 LOOP
        INSERT INTO MIG_DEPIA(DEPIA_BRN_CODE, DEPIA_ACCOUNTNUM, DEPIA_CONTRACT_NUM, DEPIA_DATE_OF_ENTRY, DEPIA_DAY_SL, DEPIA_AC_INT_ACCR_AMT, DEPIA_INT_ACCR_DB_CR, DEPIA_BC_INT_ACCR_AMT, DEPIA_ACCR_FROM_DATE, DEPIA_ACCR_UPTO_DATE, DEPIA_ENTRY_TYPE, DEPIA_PREV_YR_INT_ACCR)
        VALUES (I.DEPIA_BRN_CODE, I.DEPIA_ACCOUNTNUM, I.DEPIA_CONTRACT_NUM, I.DEPIA_DATE_OF_ENTRY, I.DEPIA_DAY_SL, I.DEPIA_AC_INT_ACCR_AMT, 'C', I.DEPIA_BC_INT_ACCR_AMT, I.DEPIA_ACCR_FROM_DATE, I.DEPIA_ACCR_UPTO_DATE, 'IA', I.DEPIA_PREV_YR_INT_ACCR);
        END LOOP;
        COMMIT;
            EXCEPTION 
                    WHEN OTHERS THEN 
                    DBMS_OUTPUT.PUT_LINE(SQLERRM);
        END;

    END;
    COMMIT;
END;

/
CREATE OR REPLACE PROCEDURE MIG_BCBL_DATA_EXTRACT (
   P_BRANCH_CODE     IN VARCHAR2,
   P_MONTH_END       IN DATE,
   P_LAST_INT_POST   IN DATE,
   P_MIG_DATE        IN DATE)
IS
   V_ERRCODE   VARCHAR2 (3000);
   V_ERRM      VARCHAR2 (3000);
BEGIN
   BEGIN
      DBMS_OUTPUT.PUT_LINE ('STARTING DATA INSERT INTO MIG_CLIENTS TABLE');

      INSERT INTO BCBL.MIG_CLIENTS (CLIENTS_CODE,
                                        CLIENTS_TYPE_FLG,
                                        CLIENTS_HOME_BRN_CODE,
                                        CLIENTS_TITLE_CODE,
                                        CLIENT_FIRST_NAME,
                                        CLIENT_LAST_NAME,
                                        CLIENT_SUR_NAME,
                                        CLIENT_MIDDLE_NAME,
                                        CLIENTS_NAME,
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
                                        CLIENTS_INVEST_PM_CURR,
                                        CLIENTS_INVEST_PM_AMT,
                                        CLIENTS_CAPITAL_CURR,
                                        CLIENTS_AUTHORIZED_CAPITAL,
                                        CLIENTS_ISSUED_CAPITAL,
                                        CLIENTS_PAIDUP_CAPITAL,
                                        CLIENTS_NETWORTH_AMT,
                                        CLIENTS_INCORP_DATE,
                                        CLIENTS_INCORP_CNTRY,
                                        CLIENTS_REG_NUM,
                                        CLIENTS_REG_DATE,
                                        CLIENTS_REG_AUTHORITY,
                                        CLIENTS_REG_EXPIRY_DATE,
                                        CLIENTS_REG_OFF_ADDR1,
                                        CLIENTS_REG_OFF_ADDR2,
                                        CLIENTS_REG_OFF_ADDR3,
                                        CLIENTS_REG_OFF_ADDR4,
                                        CLIENTS_REG_OFF_ADDR5,
                                        CLIENTS_TF_CLIENT,
                                        CLIENTS_VOSTRO_EXCG_HOUSE,
                                        CLIENTS_IMP_EXP_CODE,
                                        CLIENTS_COM_BUS_IDENTIFIER,
                                        CLIENTS_BUS_ENTITY_IDENTIFIER,
                                        CLIENTS_YEARS_IN_BUSINESS,
                                        CLIENTS_BC_GROSS_TURNOVER,
                                        CLIENTS_EMPLOYEE_SIZE,
                                        CLIENTS_NUM_OFFICES,
                                        CLIENTS_SCHEDULED_BANK,
                                        CLIENTS_SOVEREIGN_FLG,
                                        CLIENTS_TYPE_OF_SOVEREIGN,
                                        CLIENTS_CNTRY_CODE,
                                        CLIENTS_CENTRAL_STATE_FLG,
                                        CLIENTS_PUBLIC_SECTOR_FLG,
                                        CLIENTS_PRIMARY_DLR_FLG,
                                        CLIENTS_MULTILATERAL_BANK,
                                        CLIENTS_ENTD_BY,
                                        CLIENTS_ENTD_ON,
                                        CLIENTS_FORN_ADDR1,
                                        CLIENTS_FORN_ADDR2,
                                        CLIENTS_FORN_ADDR3,
                                        CLIENTS_FORN_ADDR4,
                                        CLIENTS_FORN_ADDR5,
                                        CLIENTS_CNTRY_CODE2,
                                        CLIENTS_FORN_RES_TEL,
                                        CLIENTS_FORN_OFF_TEL,
                                        CLIENTS_FORN_EXTN_NUM,
                                        CLIENTS_GSM_NUM,
                                        CLIENTS_MEMBERSHIP_NUM,
                                        CLIENTS_ITFORM,
                                        CLIENTS_RECPT_DATE)
         SELECT NVL (C.CUSCOD, '999999999999'),                 --CLEINTS_CODE
                (CASE
                    WHEN C.GENDER = 'M'
                    THEN
                       'I'
                    WHEN C.GENDER = 'F'
                    THEN
                       'I'
                    WHEN C.GENDER = 'C'
                    THEN
                       'C'
                    WHEN C.GENDER IS NULL AND (C.CUSNMG IS NOT NULL)
                         OR (C.CUSDOB IS NOT NULL)
                    THEN
                       'I'
                    ELSE
                       'C'
                 END)
                   CUSTYPE,                                 --CLIENTS_TYPE_FLG
                P_BRANCH_CODE OPRBRANCD, --CLIENTS_HOME_BRN_CODE
                DECODE (C.GENDER,  'M', 1,  'F', 3,  8) TITLE, --CLIENTS_TITLE_CODE  (Stelar data should correct before migration)
                SUBSTR (TRIM (C.cusnmf), 1, 24) CUSFNAME,  --CLIENT_FIRST_NAME
                SUBSTR (TRIM (C.cusnml), 1, 24) CUSLNAME,   --CLIENT_LAST_NAME
                '',                                          --CLIENT_SUR_NAME
                '',                                       --CLIENT_MIDDLE_NAME
                SUBSTR (TRIM (C.cusnmf || ' ' || C.cusnml), 1, 100) CUSNAME, --CLIENTS_NAME
                TRIM (C.cusnmg) FNAME,                    --CLIENT_FATHER_NAME
                (CASE C.CUSTYP
                    WHEN 'IMP' THEN 2
                    WHEN 'COR' THEN 2
                    WHEN 'SIG' THEN 2
                    WHEN 'DIR' THEN 2
                    ELSE 1
                 END)
                   CUSCAT,                                --CLIENTS_CONST_CODE
                SUBSTR (TRIM (C.addrs1), 1, 35) add1,          --CLIENTS_ADDR1
                SUBSTR (TRIM (C.addrs1), 36, 15)
                || SUBSTR (TRIM (C.addrs2), 1, 20)
                   add2,                                       --CLIENTS_ADDR2
                SUBSTR (TRIM (C.addrs2), 21, 15)
                || SUBSTR (TRIM (C.addrs2), 37, 14)
                   add3,                                       --CLIENTS_ADDR3
                SUBSTR (TRIM (C.addrs3), 1, 35) add4,          --CLIENTS_ADDR4
                SUBSTR (TRIM (C.addrs4), 1, 35) add5,          --CLIENTS_ADDR5
                '99',            --CLIENTS_LOCN_CODE  BCBL_VALIDATION LOCATION
                '3',                                       --CLIENTS_CUST_CATG
                '12340', --CLIENTS_CUST_SUB_CATG -- BCBL_VALIDATION CLIENTSUBCATS
                '123499',   --CLIENTS_SEGMENT_CODE -- BCBL_VALIDATION SEGMENTS
                '99',        --CLIENTS_BUSDIVN_CODE -- BCBL_VALIDATION BUSDIVN
                'BD',                                     --CLIENTS_RISK_CNTRY
                1,                                       --CLIENTS_NUM_OF_DOCS
                '0',                                 --CLIENTS_CONT_PERSON_AVL
                '0',                                --CLIENTS_CR_LIMITS_OTH_BK
                '0',                                 --CLIENTS_ACS_WITH_OTH_BK
                C.TIMSTAMP,                             --CLIENTS_OPENING_DATE
                '',                                       --CLIENTS_GROUP_CODE
                '.',                                     --CLIENTS_PAN_GIR_NUM
                '99',                                   --CLIENTS_IT_STAT_CODE
                NULL,  --CLIENTS_IT_SUB_STAT_CODE -- BCBL_VALIDATION ITSUBSTAT
                '0',                                    --CLIENTS_EXEMP_IN_TDS
                0,                                     --CLIENTS_EXEMP_TDS_PER
                '',                                       --CLIENTS_EXEMP_REM1
                '',                                       --CLIENTS_EXEMP_REM2
                '',                                       --CLIENTS_EXEMP_REM3
                '',                                     --CLIENTS_BSR_TYPE_FLG
                '3',                             --CLIENTS_RISK_CATEGORIZATION
                NVL (C.CUSDOB, '01-JAN-1901') CUSDOB,     --CLIENTS_BIRTH_DATE
                '99',                               --CLIENTS_BIRTH_PLACE_CODE
                C.CITYNM,                           --CLIENTS_BIRTH_PLACE_NAME
                DECODE (C.GENDER,  'M', 'M',  'F', 'F',  'M'),   --CLIENTS_SEX
                DECODE (C.marsts,
                        'SNG', 'S',
                        'DVR', 'S',
                        'MAR', 'M',
                        'WID', 'M',
                        'S'),                        -- CLIENTS_MARITAL_STATUS
                (CASE C.RELCOD
                    WHEN 'ISL' THEN '1'
                    WHEN 'MUS' THEN '1'
                    WHEN 'HIN' THEN '2'
                    WHEN 'CHR' THEN '3'
                    WHEN 'BUD' THEN '5'
                    ELSE '99'
                 END),                                   --CLIENTS_RELIGN_CODE
                (CASE C.natcod
                    WHEN 'AMR' THEN 'US'
                    WHEN 'BEL' THEN 'BE'
                    WHEN 'BNG' THEN 'BD'
                    WHEN 'CHI' THEN 'CN'
                    WHEN 'EGY' THEN 'EG'
                    WHEN 'NEP' THEN 'NP'
                    WHEN 'SIN' THEN 'SG'
                    ELSE 'OT'
                 END),                                    --CLIENTS_NATNL_CODE
                DECODE (C.natcod, 'BNG', 'R', 'N') RESCOD, --CLIENTS_RESIDENT_STATUS
                DECODE (C.natcod, 'BNG', '01', '03') LNGCOD, --CLIENTS_LANG_CODE LANGUAGES
                '0',                                 --CLIENTS_ILLITERATE_CUST
                '0',                                        --CLIENTS_DISABLED
                '0',                                      --CLIENTS_FADDR_REQD
                SUBSTR (TRIM (C.teleno), 1, 15),             --CLIENTS_TEL_RES
                SUBSTR (TRIM (C.teleno), 1, 15),             --CLIENTS_TEL_OFF
                '',                                         --CLIENTS_TEL_OFF1
                0,                                          --CLIENTS_EXTN_NUM
                SUBSTR (TRIM (C.moblno), 1, 15),             --CLIENTS_TEL_GSM
                SUBSTR (TRIM (C.faxno), 1, 15),              --CLIENTS_TEL_FAX
                C.MAILID,                                --CLIENTS_EMAIL_ADDR1
                '',                                      --CLIENTS_EMAIL_ADDR2
                'N',                                     --CLIENTS_EMPLOY_TYPE
                'O',                                 --CLIENTS_RETIRE_PENS_FLG
                (CASE C.CUSTYP WHEN 'STF' THEN 'E' ELSE 'N' END), --CLIENTS_RELATION_BANK_FLG
                0,                                      --CLIENTS_EMPLOYEE_NUM
                --OCCUPATION
                DECODE (C.OCCCOD,
                        'ATY', 13,
                        'BSN', 5,
                        'CEO', 1,
                        'CON', 1,
                        'DOC', 2,
                        'ENG', 3,
                        'GEM', 12,
                        'INA', 1,
                        'MGR', 1,
                        'PEM', 1,
                        'SEC', 12,
                        'OTH', 99,
                        99)
                   OCPCOD,                               --CLIENTS_OCCUPN_CODE
                '',                                      --CLIENTS_EMP_COMPANY
                '',                                     --CLIENTS_EMP_CMP_NAME
                '',                                    --CLIENTS_EMP_CMP_ADDR1
                '',                                    --CLIENTS_EMP_CMP_ADDR2
                '',                                    --CLIENTS_EMP_CMP_ADDR3
                '',                                    --CLIENTS_EMP_CMP_ADDR4
                '',                                    --CLIENTS_EMP_CMP_ADDR5
                '',                                       --CLIENTS_DESIG_CODE
                '',                                  --CLIENTS_WORK_SINCE_DATE
                '',                                  --CLIENTS_RETIREMENT_DATE
                100000,                             --CLIENTS_BC_ANNUAL_INCOME
                1,                                --CLIENTS_ANNUAL_INCOME_SLAB
                6,                                        --CLIENTS_ACCOM_TYPE
                'OTHERS',                               --CLIENTS_ACCOM_OTHERS
                '0',                                --CLIENTS_OWNS_TWO_WHEELER
                '0',                                        --CLIENTS_OWNS_CAR
                '2',                               --CLIENTS_INSUR_POLICY_INFO
                '',                                       --CLIENTS_DEATH_DATE
                1,                                       --CLIENTS_PID_INV_NUM
                'O',                                  --CLIENTS_ORGN_QUALIFIER
                '',                                       --CLIENTS_SWIFT_CODE
                'G',        --CLIENTS_INDUS_CODE -- BCBL_VALIDATION INDUSTRIES
                '',                                   --CLIENTS_SUB_INDUS_CODE
                '',                                   --CLIENTS_NATURE_OF_BUS1
                '',                                   --CLIENTS_NATURE_OF_BUS2
                '',                                   --CLIENTS_NATURE_OF_BUS3
                'BDT',                                --CLIENTS_INVEST_PM_CURR
                0,                                     --CLIENTS_INVEST_PM_AMT
                'BDT',                                  --CLIENTS_CAPITAL_CURR
                0,                                --CLIENTS_AUTHORIZED_CAPITAL
                0,                                    --CLIENTS_ISSUED_CAPITAL
                0,                                    --CLIENTS_PAIDUP_CAPITAL
                0,                                      --CLIENTS_NETWORTH_AMT
                '',                                      --CLIENTS_INCORP_DATE
                'BD',                                   --CLIENTS_INCORP_CNTRY
                '',                                          --CLIENTS_REG_NUM
                '',                                         --CLIENTS_REG_DATE
                '',                                    --CLIENTS_REG_AUTHORITY
                '',                                  --CLIENTS_REG_EXPIRY_DATE
                '',                                    --CLIENTS_REG_OFF_ADDR1
                '',                                    --CLIENTS_REG_OFF_ADDR2
                '',                                    --CLIENTS_REG_OFF_ADDR3
                '',                                    --CLIENTS_REG_OFF_ADDR4
                '',                                    --CLIENTS_REG_OFF_ADDR5
                '0',                                       --CLIENTS_TF_CLIENT
                '0',                               --CLIENTS_VOSTRO_EXCG_HOUSE
                '',                                     --CLIENTS_IMP_EXP_CODE
                '',                               --CLIENTS_COM_BUS_IDENTIFIER
                '',                            --CLIENTS_BUS_ENTITY_IDENTIFIER
                1,                                 --CLIENTS_YEARS_IN_BUSINESS
                1,                                 --CLIENTS_BC_GROSS_TURNOVER
                1,                                     --CLIENTS_EMPLOYEE_SIZE
                0,                                       --CLIENTS_NUM_OFFICES
                '0',                                  --CLIENTS_SCHEDULED_BANK
                '0',                                   --CLIENTS_SOVEREIGN_FLG
                NULL,                              --CLIENTS_TYPE_OF_SOVEREIGN
                'BD',                                     --CLIENTS_CNTRY_CODE
                'S',                               --CLIENTS_CENTRAL_STATE_FLG
                '',                                --CLIENTS_PUBLIC_SECTOR_FLG
                '',                                  --CLIENTS_PRIMARY_DLR_FLG
                '0',                               --CLIENTS_MULTILATERAL_BANK
                C.OPRSTAMP,                                  --CLIENTS_ENTD_BY
                C.TIMSTAMP,                                  --CLIENTS_ENTD_ON
                '',                                       --CLIENTS_FORN_ADDR1
                '',                                       --CLIENTS_FORN_ADDR2
                '',                                       --CLIENTS_FORN_ADDR3
                '',                                       --CLIENTS_FORN_ADDR4
                '',                                       --CLIENTS_FORN_ADDR5
                'BD',                                    --CLIENTS_CNTRY_CODE2
                '',                                     --CLIENTS_FORN_RES_TEL
                '',                                     --CLIENTS_FORN_OFF_TEL
                0,                                     --CLIENTS_FORN_EXTN_NUM
                '0',                                         --CLIENTS_GSM_NUM
                0,                                    --CLIENTS_MEMBERSHIP_NUM
                '0',                                          --CLIENTS_ITFORM
                ''                                        --CLIENTS_RECPT_DATE
           FROM STLBAS.STCUSMAS C
          WHERE NVL (C.OPRBRA, SUBSTR (C.OPRSTAMP, 1, 3)) = P_BRANCH_CODE;

      -- Note: Insert this client info '00021053' of 030 Branch with 040 branch

      BEGIN
         UPDATE MIG_CLIENTS
            SET MIG_CLIENTS.CLIENTS_TYPE_OF_SOVEREIGN = 'L'
          WHERE MIG_CLIENTS.CLIENTS_TYPE_FLG = 'C';
      END;

      DBMS_OUTPUT.
       PUT_LINE (
         'COMPLETE MIG_CLIENTS TABLE ' || SQL%ROWCOUNT || ' ROWS INSERTED');
   EXCEPTION
      WHEN OTHERS
      THEN
         V_ERRCODE := SQLCODE;
         V_ERRM := SQLERRM;

         INSERT
           INTO MIG_DATA_COLLECT_ERROR (MIG_BRANCH_CODE,
                                        MIG_SQLERRCODE,
                                        MIG_SQL_ERRM, TABLE_NAME)
         VALUES (P_BRANCH_CODE, V_ERRCODE, V_ERRM,'MIG_CLIENTS');
   END;

   BEGIN
      DBMS_OUTPUT.PUT_LINE ('STARTING DATA INSERT INTO MIG_ACNTS TABLE');

      INSERT INTO BCBL.MIG_ACNTS (ACNTS_ACNUM,
                                      ACNTS_BRN_CODE,
                                      ACNTS_CLIENT_NUM,
                                      ACNTS_PROD_CODE,
                                      ACNTS_AC_TYPE,
                                      ACNTS_AC_SUB_TYPE, -- BCBL_VALIDATION need to change must be follow acsubtypes
                                      ACNTS_SCHEME_CODE,
                                      ACNTS_OPENING_DATE,
                                      ACNTS_AC_NAME1,
                                      ACNTS_AC_NAME2,
                                      ACNTS_SHORT_NAME,
                                      ACNTS_AC_ADDR1,
                                      ACNTS_AC_ADDR2,
                                      ACNTS_AC_ADDR3,
                                      ACNTS_AC_ADDR4,
                                      ACNTS_AC_ADDR5,
                                      ACNTS_LOCN_CODE,
                                      ACNTS_CURR_CODE,
                                      ACNTS_GLACC_CODE,
                                      ACNTS_SALARY_ACNT,
                                      ACNTS_PASSBK_REQD,
                                      ACNTS_DCHANNEL_CODE,
                                      ACNTS_MKT_CHANNEL_CODE,
                                      ACNTS_MKT_BY_STAFF,
                                      ACNTS_MKT_BY_BRN,
                                      ACNTS_DSA_CODE,
                                      ACNTS_MODE_OF_OPERN,
                                      ACNTS_MOPR_ADDN_INFO,
                                      ACNTS_REPAYABLE_TO,
                                      ACNTS_SPECIAL_ACNT,
                                      ACNTS_NOMINATION_REQD,
                                      ACNTS_CREDIT_INT_REQD,
                                      ACNTS_MINOR_ACNT,
                                      ACNTS_POWER_OF_ATTORNEY,
                                      ACNTS_NUM_SIG_COMB,
                                      ACNTS_TELLER_OPERN,
                                      ACNTS_ATM_OPERN,
                                      ACNTS_CALL_CENTER_OPERN,
                                      ACNTS_INET_OPERN,
                                      ACNTS_CR_CARDS_ALLOWED,
                                      ACNTS_KIOSK_BANKING,
                                      ACNTS_SMS_OPERN,
                                      ACNTS_OD_ALLOWED,
                                      ACNTS_CHQBK_REQD,
                                      ACNTS_BUSDIVN_CODE,
                                      ACNTS_BASE_DATE,
                                      ACNTS_INOP_ACNT,
                                      ACNTS_DORMANT_ACNT,
                                      ACNTS_LAST_TRAN_DATE,
                                      ACNTS_INT_CALC_UPTO,
                                      ACNTS_INT_ACCR_UPTO,
                                      ACNTS_INT_DBCR_UPTO,
                                      ACNTS_TRF_TO_OVERDUE,
                                      ACNTS_DB_FREEZED,
                                      ACNTS_CR_FREEZED,
                                      ACNTS_LAST_CHQBK_ISSUED,
                                      ACNTS_CLOSURE_DATE,
                                      ACNTMAIL_ADDR_CHOICE,
                                      ACNTMAIL_THIRD_PARTY,
                                      ACNTMAIL_OTH_TITLE,
                                      ACNTMAIL_OTH_NAME,
                                      ACNTMAIL_OTH_ADDR1,
                                      ACNTMAIL_OTH_ADDR2,
                                      ACNTMAIL_OTH_ADDR3,
                                      ACNTMAIL_OTH_ADDR4,
                                      ACNTMAIL_OTH_ADDR5,
                                      ACNTMAIL_STMT_REQD,
                                      ACNTMAIL_STMT_FREQ,
                                      ACNTMAIL_STMT_PRINT_OPTION,
                                      ACNTMAIL_WEEKDAY_STMT,
                                      ACNTS_ENTD_BY,
                                      ACNTS_ENTD_ON,
                                      ACNTS_FREEZED_ON,
                                      ACNTS_FREEZE_REQ_BY1,
                                      ACNTS_FREEZE_REQ_BY2,
                                      ACNTS_FREEZE_REQ_BY3,
                                      ACNTS_FREEZE_REQ_BY4,
                                      ACNTS_REASON1,
                                      ACNTS_REASON2,
                                      ACNTS_REASON3,
                                      ACNTS_REASON4)
         SELECT SUBSTR (ACTNUM, 1, 3) || '0'
                || (CASE ACTYPE
                       WHEN 'S01' THEN '318'
                       WHEN 'S02' THEN '310'
                       WHEN 'D25' THEN '410'
                       WHEN 'D26' THEN '420'
                       ELSE SUBSTR (ACTNUM, 4, 3)
                    END)
                || '0'
                || SUBSTR (ACTNUM, 7)
                   actnum,                                       --ACNTS_ACNUM
                TO_NUMBER (STFACMAS.BRANCD) brancd,           --ACNTS_BRN_CODE
                STFACMAS.CUSCOD,                            --ACNTS_CLIENT_NUM
                SUBSTR (actnum, 4, 3),                       --ACNTS_PROD_CODE
                STFACMAS.ACTYPE,                               --ACNTS_AC_TYPE
                NULL, --ACNTS_AC_SUB_TYPE   -- BCBL_VALIDATION need to change must be follow acsubtypes
                '99',                                      --ACNTS_SCHEME_CODE
                STFACMAS.OPNDAT,                          --ACNTS_OPENING_DATE
                (SELECT SUBSTR (TRIM (stfacmas.acttit), 1, 50) FROM DUAL)
                   name1,                                     --ACNTS_AC_NAME1
                (SELECT SUBSTR (TRIM (stfacmas.acttit), 51, 30) FROM DUAL)
                   name2,                                     --ACNTS_AC_NAME2
                '',                                         --ACNTS_SHORT_NAME
                (SELECT SUBSTR (
                           TRIM (
                              REPLACE (
                                    stcusmas.addrs1
                                 || ''
                                 || stcusmas.addrs2
                                 || ''
                                 || stcusmas.addrs3,
                                 'Ÿ',
                                 '')),
                           1,
                           35)
                   FROM DUAL)
                   add1,                                      --ACNTS_AC_ADDR1
                (SELECT SUBSTR (
                           TRIM (
                              REPLACE (
                                    stcusmas.addrs1
                                 || ''
                                 || stcusmas.addrs2
                                 || ''
                                 || stcusmas.addrs3,
                                 'Ÿ',
                                 '')),
                           36,
                           35)
                   FROM DUAL)
                   add2,                                      --ACNTS_AC_ADDR2
                (SELECT SUBSTR (
                           TRIM (
                              REPLACE (
                                    stcusmas.addrs1
                                 || ''
                                 || stcusmas.addrs2
                                 || ''
                                 || stcusmas.addrs3,
                                 'Ÿ',
                                 '')),
                           71,
                           10)
                   FROM DUAL)
                   add3,                                      --ACNTS_AC_ADDR3
                '',                                           --ACNTS_AC_ADDR4
                '',                                           --ACNTS_AC_ADDR5
                '99',                             --ACNTS_LOCN_CODE   LOCATION
                STFACMAS.CURCDE,                             --ACNTS_CURR_CODE
                (SELECT GLCODE
                   FROM STLBAS.stfaccur
                  WHERE     brancd = STFACMAS.BRANCD
                        AND actype = stfacmas.actype
                        AND typcde = 'GEN'
                        AND CURCDE = 'BDT')
                   glac_code,                               --ACNTS_GLACC_CODE
                '0',                                       --ACNTS_SALARY_ACNT
                '0',                                       --ACNTS_PASSBK_REQD
                'ATM',                                   --ACNTS_DCHANNEL_CODE
                '01',                                 --ACNTS_MKT_CHANNEL_CODE
                '0',                                      --ACNTS_MKT_BY_STAFF
                '0',                                        --ACNTS_MKT_BY_BRN
                NULL,                                         --ACNTS_DSA_CODE
                (CASE STFACMAS.OPRINS
                    WHEN 'SIN' THEN '01'
                    WHEN 'AN2' THEN '01'
                    WHEN 'AN3' THEN '01'
                    WHEN 'EOS' THEN '01'
                    WHEN NULL THEN '01'
                    ELSE '07'
                 END)
                   mod_of_oprn,                          --ACNTS_MODE_OF_OPERN
                '',                                     --ACNTS_MOPR_ADDN_INFO
                1,                                        --ACNTS_REPAYABLE_TO
                '0',                                      --ACNTS_SPECIAL_ACNT
                '0',                                   --ACNTS_NOMINATION_REQD
                '1',                                   --ACNTS_CREDIT_INT_REQD
                (CASE stfacmas.minor WHEN 'N' THEN '0' ELSE '1' END)
                   minor_actn,                              --ACNTS_MINOR_ACNT
                '0',                                 --ACNTS_POWER_OF_ATTORNEY
                1,                                        --ACNTS_NUM_SIG_COMB
                '0',                                      --ACNTS_TELLER_OPERN
                '1',                                         --ACNTS_ATM_OPERN
                '0',                                 --ACNTS_CALL_CENTER_OPERN
                '0',                                        --ACNTS_INET_OPERN
                '0',                                  --ACNTS_CR_CARDS_ALLOWED
                '0',                                     --ACNTS_KIOSK_BANKING
                '1',                                         --ACNTS_SMS_OPERN
                (CASE STFACMAS.ODLIMT
                    WHEN 'Y' THEN '1'
                    WHEN 'N' THEN '0'
                    ELSE '0'
                 END)
                   od_allowed,                              --ACNTS_OD_ALLOWED
                (CASE STFACMAS.CHKBOK
                    WHEN 'Y' THEN '1'
                    WHEN 'N' THEN '0'
                    ELSE '0'
                 END)
                   chkbk_reqd,                              --ACNTS_CHQBK_REQD
                'H',                                      --ACNTS_BUSDIVN_CODE
                '',                                          --ACNTS_BASE_DATE
                (CASE STFACMAS.LASSTS WHEN 'INO' THEN '1' ELSE '0' END)
                   inop_actn,                                --ACNTS_INOP_ACNT
                (CASE STFACMAS.LASSTS WHEN 'DMT' THEN '1' ELSE '0' END)
                   dormant_actn,                          --ACNTS_DORMANT_ACNT
                NVL (
                   (SELECT MAX (docdat)
                      FROM STLBAS.stfetran
                     WHERE     brancd = stfacmas.brancd
                           AND actype = stfacmas.actype
                           AND actnum = stfacmas.actnum),
                   OPNDAT)
                   last_tran_date,                      --ACNTS_LAST_TRAN_DATE
                '',                                      --ACNTS_INT_CALC_UPTO
                '',                                      --ACNTS_INT_ACCR_UPTO
                '',                                      --ACNTS_INT_DBCR_UPTO
                '',                                     --ACNTS_TRF_TO_OVERDUE
                DECODE (ALLTRN,  'B', '0',  'C', '1',  'D', '0'), --ACNTS_DB_FREEZED BCBL_VALIDATION
                DECODE (ALLTRN,  'B', '0',  'C', '0',  'D', '1'), --ACNTS_CR_FREEZED BCBL_VALIDATION
                '',                                  --ACNTS_LAST_CHQBK_ISSUED
                '',                                       --ACNTS_CLOSURE_DATE
                'C',                                    --ACNTMAIL_ADDR_CHOICE
                '',                                     --ACNTMAIL_THIRD_PARTY
                '',                                       --ACNTMAIL_OTH_TITLE
                '',                                        --ACNTMAIL_OTH_NAME
                '',                                       --ACNTMAIL_OTH_ADDR1
                '',                                       --ACNTMAIL_OTH_ADDR2
                '',                                       --ACNTMAIL_OTH_ADDR3
                '',                                       --ACNTMAIL_OTH_ADDR4
                '',                                       --ACNTMAIL_OTH_ADDR5
                '1',                                      --ACNTMAIL_STMT_REQD
                'M',                                      --ACNTMAIL_STMT_FREQ
                'B',                              --ACNTMAIL_STMT_PRINT_OPTION
                '',                                    --ACNTMAIL_WEEKDAY_STMT
                STFACMAS.OPRSTAMP,                             --ACNTS_ENTD_BY
                STFACMAS.TIMSTAMP,                             --ACNTS_ENTD_ON
                DECODE (ALLTRN,  'C', STFACMAS.OPNDAT,  'D', STFACMAS.OPNDAT), --ACNTS_FREEZED_ON
                '',                                     --ACNTS_FREEZE_REQ_BY1
                '',                                     --ACNTS_FREEZE_REQ_BY2
                '',                                     --ACNTS_FREEZE_REQ_BY3
                '',                                     --ACNTS_FREEZE_REQ_BY4
                'MIGRATION',                                   --ACNTS_REASON1
                '',                                            --ACNTS_REASON2
                '',                                            --ACNTS_REASON3
                ''                                             --ACNTS_REASON4
           FROM STLBAS.stfacmas, STLBAS.stcusmas
          WHERE     stcusmas.cuscod = stfacmas.cuscod
                AND stfacmas.brancd = P_BRANCH_CODE
                AND stfacmas.actnum <> P_BRANCH_CODE || '21099999'
                AND stfacmas.acstat NOT IN ('TRF', 'CLS')
                AND CLSDAT IS NULL        -- ACCOUNT CLOSED NO NEED TO COLLECT
                --AND stfacmas.ACTYPE = 'C02'
                AND stfacmas.actype NOT LIKE 'R%';

      DBMS_OUTPUT.
       PUT_LINE (
         'COMPLETE MIG_ACNTS TABLE ' || SQL%ROWCOUNT || ' ROWS INSERTED');
   EXCEPTION
      WHEN OTHERS
      THEN
         V_ERRCODE := SQLCODE;
         V_ERRM := SQLERRM;

         INSERT
           INTO MIG_DATA_COLLECT_ERROR (MIG_BRANCH_CODE,
                                        MIG_SQLERRCODE,
                                        MIG_SQL_ERRM, TABLE_NAME)
         VALUES (P_BRANCH_CODE, V_ERRCODE, V_ERRM,'MIG_ACNTS');
   END;

   BEGIN
      DBMS_OUTPUT.PUT_LINE ('STARTING DATA INSERT INTO MIG_CLIENTS TABLE');

      INSERT INTO BCBL.MIG_CLIENTS (CLIENTS_CODE,
                                        CLIENTS_TYPE_FLG,
                                        CLIENTS_HOME_BRN_CODE,
                                        CLIENTS_TITLE_CODE,
                                        CLIENT_FIRST_NAME,
                                        CLIENT_LAST_NAME,
                                        CLIENT_SUR_NAME,
                                        CLIENT_MIDDLE_NAME,
                                        CLIENTS_NAME,
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
                                        CLIENTS_INVEST_PM_CURR,
                                        CLIENTS_INVEST_PM_AMT,
                                        CLIENTS_CAPITAL_CURR,
                                        CLIENTS_AUTHORIZED_CAPITAL,
                                        CLIENTS_ISSUED_CAPITAL,
                                        CLIENTS_PAIDUP_CAPITAL,
                                        CLIENTS_NETWORTH_AMT,
                                        CLIENTS_INCORP_DATE,
                                        CLIENTS_INCORP_CNTRY,
                                        CLIENTS_REG_NUM,
                                        CLIENTS_REG_DATE,
                                        CLIENTS_REG_AUTHORITY,
                                        CLIENTS_REG_EXPIRY_DATE,
                                        CLIENTS_REG_OFF_ADDR1,
                                        CLIENTS_REG_OFF_ADDR2,
                                        CLIENTS_REG_OFF_ADDR3,
                                        CLIENTS_REG_OFF_ADDR4,
                                        CLIENTS_REG_OFF_ADDR5,
                                        CLIENTS_TF_CLIENT,
                                        CLIENTS_VOSTRO_EXCG_HOUSE,
                                        CLIENTS_IMP_EXP_CODE,
                                        CLIENTS_COM_BUS_IDENTIFIER,
                                        CLIENTS_BUS_ENTITY_IDENTIFIER,
                                        CLIENTS_YEARS_IN_BUSINESS,
                                        CLIENTS_BC_GROSS_TURNOVER,
                                        CLIENTS_EMPLOYEE_SIZE,
                                        CLIENTS_NUM_OFFICES,
                                        CLIENTS_SCHEDULED_BANK,
                                        CLIENTS_SOVEREIGN_FLG,
                                        CLIENTS_TYPE_OF_SOVEREIGN,
                                        CLIENTS_CNTRY_CODE,
                                        CLIENTS_CENTRAL_STATE_FLG,
                                        CLIENTS_PUBLIC_SECTOR_FLG,
                                        CLIENTS_PRIMARY_DLR_FLG,
                                        CLIENTS_MULTILATERAL_BANK,
                                        CLIENTS_ENTD_BY,
                                        CLIENTS_ENTD_ON,
                                        CLIENTS_FORN_ADDR1,
                                        CLIENTS_FORN_ADDR2,
                                        CLIENTS_FORN_ADDR3,
                                        CLIENTS_FORN_ADDR4,
                                        CLIENTS_FORN_ADDR5,
                                        CLIENTS_CNTRY_CODE2,
                                        CLIENTS_FORN_RES_TEL,
                                        CLIENTS_FORN_OFF_TEL,
                                        CLIENTS_FORN_EXTN_NUM,
                                        CLIENTS_GSM_NUM,
                                        CLIENTS_MEMBERSHIP_NUM,
                                        CLIENTS_ITFORM,
                                        CLIENTS_RECPT_DATE)
         SELECT NVL (C.CUSCOD, '999999999999'),                 --CLEINTS_CODE
                (CASE
                    WHEN C.GENDER = 'M'
                    THEN
                       'I'
                    WHEN C.GENDER = 'F'
                    THEN
                       'I'
                    WHEN C.GENDER = 'C'
                    THEN
                       'C'
                    WHEN C.GENDER IS NULL AND (C.CUSNMG IS NOT NULL)
                         OR (C.CUSDOB IS NOT NULL)
                    THEN
                       'I'
                    ELSE
                       'C'
                 END)
                   CUSTYPE,                                 --CLIENTS_TYPE_FLG
                P_BRANCH_CODE OPRBRANCD, --CLIENTS_HOME_BRN_CODE
                DECODE (C.GENDER,  'M', 1,  'F', 3,  8) TITLE, --CLIENTS_TITLE_CODE  (Stelar data should correct before migration)
                SUBSTR (TRIM (C.cusnmf), 1, 24) CUSFNAME,  --CLIENT_FIRST_NAME
                SUBSTR (TRIM (C.cusnml), 1, 24) CUSLNAME,   --CLIENT_LAST_NAME
                '',                                          --CLIENT_SUR_NAME
                '',                                       --CLIENT_MIDDLE_NAME
                SUBSTR (TRIM (C.cusnmf || ' ' || C.cusnml), 1, 100) CUSNAME, --CLIENTS_NAME
                TRIM (C.cusnmg) FNAME,                    --CLIENT_FATHER_NAME
                (CASE C.CUSTYP
                    WHEN 'IMP' THEN 2
                    WHEN 'COR' THEN 2
                    WHEN 'SIG' THEN 2
                    WHEN 'DIR' THEN 2
                    ELSE 1
                 END)
                   CUSCAT,                                --CLIENTS_CONST_CODE
                SUBSTR (TRIM (C.addrs1), 1, 35) add1,          --CLIENTS_ADDR1
                SUBSTR (TRIM (C.addrs1), 36, 15)
                || SUBSTR (TRIM (C.addrs2), 1, 20)
                   add2,                                       --CLIENTS_ADDR2
                SUBSTR (TRIM (C.addrs2), 21, 15)
                || SUBSTR (TRIM (C.addrs2), 37, 14)
                   add3,                                       --CLIENTS_ADDR3
                SUBSTR (TRIM (C.addrs3), 1, 35) add4,          --CLIENTS_ADDR4
                SUBSTR (TRIM (C.addrs4), 1, 35) add5,          --CLIENTS_ADDR5
                '99',            --CLIENTS_LOCN_CODE  BCBL_VALIDATION LOCATION
                '3',                                       --CLIENTS_CUST_CATG
                '12340', --CLIENTS_CUST_SUB_CATG -- BCBL_VALIDATION CLIENTSUBCATS
                '123499',   --CLIENTS_SEGMENT_CODE -- BCBL_VALIDATION SEGMENTS
                '99',        --CLIENTS_BUSDIVN_CODE -- BCBL_VALIDATION BUSDIVN
                'BD',                                     --CLIENTS_RISK_CNTRY
                1,                                       --CLIENTS_NUM_OF_DOCS
                '0',                                 --CLIENTS_CONT_PERSON_AVL
                '0',                                --CLIENTS_CR_LIMITS_OTH_BK
                '0',                                 --CLIENTS_ACS_WITH_OTH_BK
                C.TIMSTAMP,                             --CLIENTS_OPENING_DATE
                '',                                       --CLIENTS_GROUP_CODE
                '.',                                     --CLIENTS_PAN_GIR_NUM
                '99',                                   --CLIENTS_IT_STAT_CODE
                NULL,  --CLIENTS_IT_SUB_STAT_CODE -- BCBL_VALIDATION ITSUBSTAT
                '0',                                    --CLIENTS_EXEMP_IN_TDS
                0,                                     --CLIENTS_EXEMP_TDS_PER
                '',                                       --CLIENTS_EXEMP_REM1
                '',                                       --CLIENTS_EXEMP_REM2
                '',                                       --CLIENTS_EXEMP_REM3
                '',                                     --CLIENTS_BSR_TYPE_FLG
                '3',                             --CLIENTS_RISK_CATEGORIZATION
                NVL (C.CUSDOB, '01-JAN-1901') CUSDOB,     --CLIENTS_BIRTH_DATE
                '99',                               --CLIENTS_BIRTH_PLACE_CODE
                C.CITYNM,                           --CLIENTS_BIRTH_PLACE_NAME
                DECODE (C.GENDER,  'M', 'M',  'F', 'F',  'M'),   --CLIENTS_SEX
                DECODE (C.marsts,
                        'SNG', 'S',
                        'DVR', 'S',
                        'MAR', 'M',
                        'WID', 'M',
                        'S'),                        -- CLIENTS_MARITAL_STATUS
                (CASE C.RELCOD
                    WHEN 'ISL' THEN '1'
                    WHEN 'MUS' THEN '1'
                    WHEN 'HIN' THEN '2'
                    WHEN 'CHR' THEN '3'
                    WHEN 'BUD' THEN '5'
                    ELSE '99'
                 END),                                   --CLIENTS_RELIGN_CODE
                (CASE C.natcod
                    WHEN 'AMR' THEN 'US'
                    WHEN 'BEL' THEN 'BE'
                    WHEN 'BNG' THEN 'BD'
                    WHEN 'CHI' THEN 'CN'
                    WHEN 'EGY' THEN 'EG'
                    WHEN 'NEP' THEN 'NP'
                    WHEN 'SIN' THEN 'SG'
                    ELSE 'OT'
                 END),                                    --CLIENTS_NATNL_CODE
                DECODE (C.natcod, 'BNG', 'R', 'N') RESCOD, --CLIENTS_RESIDENT_STATUS
                DECODE (C.natcod, 'BNG', '01', '03') LNGCOD, --CLIENTS_LANG_CODE LANGUAGES
                '0',                                 --CLIENTS_ILLITERATE_CUST
                '0',                                        --CLIENTS_DISABLED
                '0',                                      --CLIENTS_FADDR_REQD
                SUBSTR (TRIM (C.teleno), 1, 15),             --CLIENTS_TEL_RES
                SUBSTR (TRIM (C.teleno), 1, 15),             --CLIENTS_TEL_OFF
                '',                                         --CLIENTS_TEL_OFF1
                0,                                          --CLIENTS_EXTN_NUM
                SUBSTR (TRIM (C.moblno), 1, 15),             --CLIENTS_TEL_GSM
                SUBSTR (TRIM (C.faxno), 1, 15),              --CLIENTS_TEL_FAX
                C.MAILID,                                --CLIENTS_EMAIL_ADDR1
                '',                                      --CLIENTS_EMAIL_ADDR2
                'N',                                     --CLIENTS_EMPLOY_TYPE
                'O',                                 --CLIENTS_RETIRE_PENS_FLG
                (CASE C.CUSTYP WHEN 'STF' THEN 'E' ELSE 'N' END), --CLIENTS_RELATION_BANK_FLG
                0,                                      --CLIENTS_EMPLOYEE_NUM
                --OCCUPATION
                DECODE (C.OCCCOD,
                        'ATY', 13,
                        'BSN', 5,
                        'CEO', 1,
                        'CON', 1,
                        'DOC', 2,
                        'ENG', 3,
                        'GEM', 12,
                        'INA', 1,
                        'MGR', 1,
                        'PEM', 1,
                        'SEC', 12,
                        'OTH', 99,
                        99)
                   OCPCOD,                               --CLIENTS_OCCUPN_CODE
                '',                                      --CLIENTS_EMP_COMPANY
                '',                                     --CLIENTS_EMP_CMP_NAME
                '',                                    --CLIENTS_EMP_CMP_ADDR1
                '',                                    --CLIENTS_EMP_CMP_ADDR2
                '',                                    --CLIENTS_EMP_CMP_ADDR3
                '',                                    --CLIENTS_EMP_CMP_ADDR4
                '',                                    --CLIENTS_EMP_CMP_ADDR5
                '',                                       --CLIENTS_DESIG_CODE
                '',                                  --CLIENTS_WORK_SINCE_DATE
                '',                                  --CLIENTS_RETIREMENT_DATE
                100000,                             --CLIENTS_BC_ANNUAL_INCOME
                1,                                --CLIENTS_ANNUAL_INCOME_SLAB
                6,                                        --CLIENTS_ACCOM_TYPE
                'OTHERS',                               --CLIENTS_ACCOM_OTHERS
                '0',                                --CLIENTS_OWNS_TWO_WHEELER
                '0',                                        --CLIENTS_OWNS_CAR
                '2',                               --CLIENTS_INSUR_POLICY_INFO
                '',                                       --CLIENTS_DEATH_DATE
                1,                                       --CLIENTS_PID_INV_NUM
                'O',                                  --CLIENTS_ORGN_QUALIFIER
                '',                                       --CLIENTS_SWIFT_CODE
                'G',        --CLIENTS_INDUS_CODE -- BCBL_VALIDATION INDUSTRIES
                '',                                   --CLIENTS_SUB_INDUS_CODE
                '',                                   --CLIENTS_NATURE_OF_BUS1
                '',                                   --CLIENTS_NATURE_OF_BUS2
                '',                                   --CLIENTS_NATURE_OF_BUS3
                'BDT',                                --CLIENTS_INVEST_PM_CURR
                0,                                     --CLIENTS_INVEST_PM_AMT
                'BDT',                                  --CLIENTS_CAPITAL_CURR
                0,                                --CLIENTS_AUTHORIZED_CAPITAL
                0,                                    --CLIENTS_ISSUED_CAPITAL
                0,                                    --CLIENTS_PAIDUP_CAPITAL
                0,                                      --CLIENTS_NETWORTH_AMT
                '',                                      --CLIENTS_INCORP_DATE
                'BD',                                   --CLIENTS_INCORP_CNTRY
                '',                                          --CLIENTS_REG_NUM
                '',                                         --CLIENTS_REG_DATE
                '',                                    --CLIENTS_REG_AUTHORITY
                '',                                  --CLIENTS_REG_EXPIRY_DATE
                '',                                    --CLIENTS_REG_OFF_ADDR1
                '',                                    --CLIENTS_REG_OFF_ADDR2
                '',                                    --CLIENTS_REG_OFF_ADDR3
                '',                                    --CLIENTS_REG_OFF_ADDR4
                '',                                    --CLIENTS_REG_OFF_ADDR5
                '0',                                       --CLIENTS_TF_CLIENT
                '0',                               --CLIENTS_VOSTRO_EXCG_HOUSE
                '',                                     --CLIENTS_IMP_EXP_CODE
                '',                               --CLIENTS_COM_BUS_IDENTIFIER
                '',                            --CLIENTS_BUS_ENTITY_IDENTIFIER
                1,                                 --CLIENTS_YEARS_IN_BUSINESS
                1,                                 --CLIENTS_BC_GROSS_TURNOVER
                1,                                     --CLIENTS_EMPLOYEE_SIZE
                0,                                       --CLIENTS_NUM_OFFICES
                '0',                                  --CLIENTS_SCHEDULED_BANK
                '0',                                   --CLIENTS_SOVEREIGN_FLG
                NULL,                              --CLIENTS_TYPE_OF_SOVEREIGN
                'BD',                                     --CLIENTS_CNTRY_CODE
                'S',                               --CLIENTS_CENTRAL_STATE_FLG
                '',                                --CLIENTS_PUBLIC_SECTOR_FLG
                '',                                  --CLIENTS_PRIMARY_DLR_FLG
                '0',                               --CLIENTS_MULTILATERAL_BANK
                C.OPRSTAMP,                                  --CLIENTS_ENTD_BY
                C.TIMSTAMP,                                  --CLIENTS_ENTD_ON
                '',                                       --CLIENTS_FORN_ADDR1
                '',                                       --CLIENTS_FORN_ADDR2
                '',                                       --CLIENTS_FORN_ADDR3
                '',                                       --CLIENTS_FORN_ADDR4
                '',                                       --CLIENTS_FORN_ADDR5
                'BD',                                    --CLIENTS_CNTRY_CODE2
                '',                                     --CLIENTS_FORN_RES_TEL
                '',                                     --CLIENTS_FORN_OFF_TEL
                0,                                     --CLIENTS_FORN_EXTN_NUM
                '0',                                         --CLIENTS_GSM_NUM
                0,                                    --CLIENTS_MEMBERSHIP_NUM
                '0',                                          --CLIENTS_ITFORM
                ''                                        --CLIENTS_RECPT_DATE
           FROM STLBAS.STCUSMAS C
          WHERE CUSCOD IN (SELECT ACNTS_CLIENT_NUM
                                        FROM MIG_ACNTS
                                        MINUS
                                        SELECT CLIENTS_CODE
                                        FROM MIG_CLIENTS);

      -- Note: Insert this client info '00021053' of 030 Branch with 040 branch

      BEGIN
         UPDATE MIG_CLIENTS
            SET MIG_CLIENTS.CLIENTS_TYPE_OF_SOVEREIGN = 'L'
          WHERE MIG_CLIENTS.CLIENTS_TYPE_FLG = 'C';
      END;

      DBMS_OUTPUT.
       PUT_LINE (
         'COMPLETE MIG_CLIENTS TABLE ' || SQL%ROWCOUNT || ' ROWS INSERTED');
   EXCEPTION
      WHEN OTHERS
      THEN
         V_ERRCODE := SQLCODE;
         V_ERRM := SQLERRM;

         INSERT
           INTO MIG_DATA_COLLECT_ERROR (MIG_BRANCH_CODE,
                                        MIG_SQLERRCODE,
                                        MIG_SQL_ERRM, TABLE_NAME)
         VALUES (P_BRANCH_CODE, V_ERRCODE, V_ERRM,'MIG_CLIENTS');
   END;


   BEGIN
      DBMS_OUTPUT.PUT_LINE ('STARTING DATA INSERT INTO MIG_CONNPINFO TABLE');

      INSERT INTO BCBL.MIG_CONNPINFO (CONNP_AC_CLIENT_FLAG,
                                          CONNP_CLIENT_CODE,
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
                                          CONNP_SHARE_HOLD_PER)
         SELECT 'A',
                STCUSMAS.CUSCOD,
                SUBSTR (STFACMAS.ACTNUM, 1, 3) || '0'
                || (CASE STFACMAS.ACTYPE
                       WHEN 'S01' THEN '318'
                       WHEN 'S02' THEN '310'
                       WHEN 'D25' THEN '410'
                       WHEN 'D26' THEN '420'
                       ELSE SUBSTR (STFACMAS.ACTNUM, 4, 3)
                    END)
                || '0'
                || SUBSTR (STFACMAS.ACTNUM, 7)
                   ACTNUM,
                1,
                '01',
                '',
                STFACMAS.INCUST,
                STCUSMAS.CUSNMF,
                '',                                             -- CLIENT NAME
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                'BD',
                '',
                '0',
                '',
                '',
                '',
                '',
                '',
                '',
                STCUSMAS.OPRSTAMP,
                '',
                '',
                0
           FROM STLBAS.STCUSMAS, STLBAS.STFACMAS
          WHERE     STCUSMAS.CUSCOD = STFACMAS.INCUST --AND STCUSMAS.CUSTYP in ( 'IMP', 'COR', 'SIG', 'DIR') AND stfacmas.oprins='JNT'
                AND STFACMAS.ACSTAT NOT IN ('TRF', 'CLS')
                AND CLSDAT IS NULL
                AND SUBSTR (STFACMAS.ACTNUM, 1, 3) = P_BRANCH_CODE;

      DBMS_OUTPUT.
       PUT_LINE (
         'COMPLETE MIG_CONNPINFO TABLE ' || SQL%ROWCOUNT || ' ROWS INSERTED');
   EXCEPTION
      WHEN OTHERS
      THEN
         V_ERRCODE := SQLCODE;
         V_ERRM := SQLERRM;

         INSERT
           INTO MIG_DATA_COLLECT_ERROR (MIG_BRANCH_CODE,
                                        MIG_SQLERRCODE,
                                        MIG_SQL_ERRM,TABLE_NAME)
         VALUES (P_BRANCH_CODE, V_ERRCODE, V_ERRM,'MIG_CONNPINFO');
   END;

   BEGIN
      DBMS_OUTPUT.PUT_LINE ('STARTING DATA INSERT INTO MIG_PIDDOCS TABLE');

      INSERT INTO BCBL.MIG_PIDDOCS (PIDDOCS_CLIENTS_CODE,
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
                                        PIDDOCS_FOR_IDENTITY_CHK)
         SELECT STDOCDTL.CUSCOD,
                1,
                STDOCDTL.DOCUCD,
                STDOCDTL.DOCUNO,
                '',
                STDOCDTL.ISSDAT,
                STDOCDTL.PISSUE,
                '',
                'BD',
                STDOCDTL.EXPDAT,
                (SELECT sponam
                   FROM stlbas.stcusmas
                  WHERE stcusmas.cuscod = stdocdtl.cuscod),
                '',
                '',
                '',
                '',
                '',
                (CASE STDOCDTL.DOCUCD WHEN 'TIN' THEN '0' ELSE '1' END),
                (CASE STDOCDTL.DOCUCD WHEN 'TIN' THEN '0' ELSE '1' END)
           FROM STLBAS.STDOCDTL
          WHERE STDOCDTL.CUSCOD IN
                   (SELECT CUSCOD
                      FROM STLBAS.STCUSMAS C
                     WHERE NVL (C.OPRBRA,
                                SUBSTR (C.OPRSTAMP, 1, 3)) = P_BRANCH_CODE);

      DBMS_OUTPUT.
       PUT_LINE (
         'COMPLETE MIG_PIDDOCS TABLE ' || SQL%ROWCOUNT || ' ROWS INSERTED');
   EXCEPTION
      WHEN OTHERS
      THEN
         V_ERRCODE := SQLCODE;
         V_ERRM := SQLERRM;

         INSERT
           INTO MIG_DATA_COLLECT_ERROR (MIG_BRANCH_CODE,
                                        MIG_SQLERRCODE,
                                        MIG_SQL_ERRM,TABLE_NAME)
         VALUES (P_BRANCH_CODE, V_ERRCODE, V_ERRM,'MIG_PIDDOCS');
   END;

   BEGIN
      DBMS_OUTPUT.PUT_LINE ('STARTING DATA INSERT INTO MIG_ACNTLIEN TABLE');

      INSERT INTO BCBL.MIG_ACNTLIEN (ACNTLIEN_ACNUM,
                                         ACNTLIEN_LIEN_SL,
                                         ACNTLIEN_LIEN_DATE,
                                         ACNTLIEN_LIEN_AMOUNT,
                                         ACNTLIEN_LIEN_TO_BRN,
                                         ACNTLIEN_LIEN_TO_ACNUM,
                                         ACNTLIEN_REASON1,
                                         ACNTLIEN_REVOKED_ON,
                                         ACNTLIEN_ENTD_BY,
                                         ACNTLIEN_ENTD_ON)
         SELECT LIEN_ACNUM,
                ROWNUM LIEN_SL,
                TRUNC (TIMSTAMP) LIEN_DATE,
                CURVAL LIEN_AMOUNT,
                TO_NUMBER (BRANCD) LIEN_TO_BR,
                LIEN_TO_ACNUM,
                CASE REASON
                   WHEN 'LOD' THEN 'LINE ON OVER DRAFT'
                   WHEN 'LOG' THEN 'LIEN ON GUARANTEE'
                   WHEN 'LON' THEN 'LIEN ON LOAN'
                   WHEN 'OTH' THEN 'LIEN ON OTHERS'
                END
                   REASON,
                '' REVOKED_DATE,
                OPRSTAMP ENTD_BY,
                TIMSTAMP ENTD_BY
           FROM (  SELECT D.BRANCD,
                          D.ACTYPE,
                             SUBSTR (D.ACTNUM, 1, 3)
                          || '0'
                          || SUBSTR (D.ACTNUM, 4, 3)
                          || '0'
                          || SUBSTR (D.ACTNUM, 7)
                             LIEN_TO_ACNUM,                  -- added by rajib
                          D.SERNUM,
                          (SELECT    SUBSTR (ACTNUM, 1, 3)
                                  || '0'
                                  || SUBSTR (ACTNUM, 4, 3)
                                  || '0'
                                  || SUBSTR (ACTNUM, 7) -- added by rajib on 13/03/14
                             FROM stlbas.STFACMAS
                            WHERE BRANCD = D.BRANCD AND CUSCOD = D.CUSTID
                                  AND LPAD (FDRNUM, 10, 0) =
                                         LPAD (D.CERTNO, 10, 0))
                             LIEN_ACNUM,
                          (SELECT LIENST
                             FROM stlbas.STFACMAS
                            WHERE BRANCD = D.BRANCD AND CUSCOD = D.CUSTID
                                  AND LPAD (FDRNUM, 10, 0) =
                                         LPAD (D.CERTNO, 10, 0))
                             REASON,
                          D.SECTYP,
                          D.CURVAL,
                          D.CERTNO,
                          D.CUSTID,
                          D.OPRSTAMP,
                          D.TIMSTAMP
                     FROM stlbas.STLOANSD D, stlbas.STFACMAS C
                    WHERE     D.brancd = P_BRANCH_CODE
                          AND D.BRANCD = C.BRANCD
                          AND D.ACTYPE = C.ACTYPE
                          AND D.ACTNUM = C.ACTNUM
                          AND C.ACSTAT NOT IN ('TRF', 'CLS')
                          AND CLSDAT IS NULL
                          AND D.SECTYP = 'FDR'
                 ORDER BY D.BRANCD, D.ACTNUM)
          WHERE REASON <> 'NON';

      DBMS_OUTPUT.
       PUT_LINE (
         'COMPLETE MIG_ACNTLIEN TABLE ' || SQL%ROWCOUNT || ' ROWS INSERTED');
   EXCEPTION
      WHEN OTHERS
      THEN
         V_ERRCODE := SQLCODE;
         V_ERRM := SQLERRM;

         INSERT
           INTO MIG_DATA_COLLECT_ERROR (MIG_BRANCH_CODE,
                                        MIG_SQLERRCODE,
                                        MIG_SQL_ERRM,TABLE_NAME)
         VALUES (P_BRANCH_CODE, V_ERRCODE, V_ERRM,'MIG_ACNTLIEN');
   END;

   /*  -- Not required --
    BEGIN
       DBMS_OUTPUT.PUT_LINE ('STARTING DATA INSERT INTO MIG_TDSPIDTL TABLE');

       INSERT INTO BCBL.MIG_TDSPIDTL (TDSPIDT_BRN_CODE,
                                          TDSPIDT_CUST_CODE,
                                          TDSPIDT_CURR,
                                          TDSPIDT_FIN_YR,
                                          TDSPIDT_DATE_OF_REC,
                                          TDSPIDT_AC_NUM,
                                          TDSPIDT_CONT_NUM,
                                          TDSPIDT_SL,
                                          TDSPIDT_TOT_INT_CR,
                                          TDSPIDT_TDS_AMT,
                                          TDSPIDT_SURCHARGE_AMT,
                                          TDSPIDT_TDS_REC,
                                          TDSPIDT_SURCHARGE_REC,
                                          TDSPIDT_OTH_BRN_TDS,
                                          TDSPIDT_OTH_CHGS_REC,
                                          TDSPIDT_OTH_CHGS)
          SELECT TO_NUMBER (STFETRAN.BRANCD),
                 STFACMAS.CUSCOD,
                 STFETRAN.CURCDE,
                 TO_NUMBER (TO_CHAR (STFETRAN.DOCDAT, 'YYYY')) TDSPIDT_FIN_YR,
                 STFETRAN.DOCDAT,
                 SUBSTR (STFETRAN.ACTNUM, 1, 3) || '0'
                 || (CASE STFETRAN.ACTYPE
                        WHEN 'S01' THEN '318'
                        WHEN 'S02' THEN '310'
                        WHEN 'D25' THEN '410'
                        WHEN 'D26' THEN '420'
                        ELSE SUBSTR (STFETRAN.ACTNUM, 4, 3)
                     END)
                 || '0'
                 || SUBSTR (STFETRAN.ACTNUM, 7),
                 1,
                 1,
                 0,
                 STFETRAN.DBAMLC,
                 0,
                 STFETRAN.DBAMLC,
                 0,
                 '0',
                 0,
                 0
            FROM STLBAS.STFETRAN, STLBAS.STFACMAS
           WHERE     STFETRAN.brancd = STFACMAS.brancd
                 AND STFETRAN.BRANCD = P_BRANCH_CODE
                 AND STFETRAN.actype = STFACMAS.actype
                 AND STFETRAN.actnum = STFACMAS.actnum
                 AND STFACMAS.ACSTAT NOT IN ('TRF', 'CLS')
                 AND STFACMAS.CLSDAT IS NULL
                 AND STFETRAN.oprcod = 'ITX';

       DBMS_OUTPUT.
        PUT_LINE (
          'COMPLETE MIG_TDSPIDTL TABLE ' || SQL%ROWCOUNT || ' ROWS INSERTED');
    EXCEPTION
       WHEN OTHERS
       THEN
          V_ERRCODE := SQLCODE;
          V_ERRM := SQLERRM;

          INSERT
            INTO MIG_DATA_COLLECT_ERROR (MIG_BRANCH_CODE,
                                         MIG_SQLERRCODE,
                                         MIG_SQL_ERRM)
          VALUES (P_BRANCH_CODE, V_ERRCODE, V_ERRM);
    END;
   */

   BEGIN
      DBMS_OUTPUT.
       PUT_LINE ('STARTING DATA INSERT INTO MIG_PBDCONTRACT (FD) TABLE');

      INSERT INTO BCBL.MIG_PBDCONTRACT (MIGDEP_BRN_CODE,
                                            MIGDEP_DEP_AC_NUM,
                                            MIGDEP_CONT_NUM,
                                            MIGDEP_PROD_CODE,
                                            MIGDEP_DEP_OPEN_DATE,
                                            MIGDEP_EFF_DATE,
                                            MIGDEP_DEP_CURR,
                                            MIGDEP_UNIT_AMT,
                                            MIGDEP_AC_DEP_AMT,
                                            MIGDEP_BC_DEP_AMT,
                                            MIGDEP_DEP_UNITS,
                                            MIGDEP_DEP_PRD_MONTHS,
                                            MIGDEP_DEP_PRD_DAYS,
                                            MIGDEP_MAT_DATE,
                                            MIGDEP_STD_INT_RATE,
                                            MIGDEP_ACTUAL_INT_RATE,
                                            MIGDEP_MAT_VALUE,
                                            MIGDEP_MAT_VALUE_PER_UNIT,
                                            MIGDEP_INT_PAY_FREQ,
                                            MIGDEP_DISC_INT_RATE,
                                            MIGDEP_PERIODICAL_INT_AMT,
                                            MIGDEP_RENEWAL,
                                            MIGDEP_TRF_FROM_ANOTHER_BRN,
                                            MIGDEP_TRF_FROM_BRN,
                                            MIGDEP_TRF_DEP_AC_NUM,
                                            MIGDEP_TRF_CONT_NUM,
                                            MIGDEP_TOT_AMT_TRFD,
                                            MIGDEP_INT_POR_OF_AMT_TRFD,
                                            MIGDEP_IBR_ADV_NUM,
                                            MIGDEP_IBR_ADV_DATE,
                                            MIGDEP_IBR_TYPE_CODE,
                                            MIGDEP_TRANSTLMNT_INV_NUM,
                                            MIGDEP_AUTO_INT_PAYMENT,
                                            MIGDEP_STLMNT_OPTION,
                                            MIGDEP_RENEWAL_OPTION,
                                            MIGDEP_NUM_AUTO_RENEWALS,
                                            MIGDEP_INT_CR_TO_ACNT,
                                            MIGDEP_DEP_DUE_NOTICE_REQD,
                                            MIGDEP_FREQ_OF_DEP,
                                            MIGDEP_NO_OF_INST,
                                            MIGDEP_INST_PAY_OPTION,
                                            MIGDEP_AUTO_INST_REC_REQD,
                                            MIGDEP_INST_REC_FROM_AC,
                                            MIGDEP_INST_REC_DAY,
                                            MIGDEP_COLL_CODE,
                                            MIGDEP_INT_ACCR_UPTO,
                                            MIGDEP_CLOSURE_DATE,
                                            MIGDEP_TRF_TO_OD_ON,
                                            MIGDEP_INT_PAID_UPTO,
                                            MIGDEP_COMPLETED_ROLLOVERS,
                                            MIGDEP_EXCLUDE_DAY_FLAG,
                                            MIGDEP_PER_INT_UNIT_AMT,
                                            MIGDEP_BAL_DEP_UNITS,
                                            MIGDEP_BAL_PER_UNIT,
                                            MIGDEP_TOT_BAL_FOR_REM_UNITS,
                                            MIGDEP_AC_INT_ACCR_AMT,
                                            MIGDEP_BC_INT_ACCR_AMT,
                                            MIGDEP_AC_INT_PAY_AMT,
                                            MIGDEP_BC_INT_PAY_AMT,
                                            MIGDEP_BK_DT_OP_REASON,
                                            MIGDEP_INT_CALC_UPTO,
                                            MIGDEP_INT_CALC_AMT,
                                            MIGDEP_INT_CALC_AMT_PAYABLE,
                                            MIGDEP_INT_CALC_PAYABLE_UPTO,
                                            MIGDEP_CONT_AMT,
                                            MIGDEP_INT_CR_AC_NUM,
                                            MIGDEP_CLOSURE_STL_AC_NUM,
                                            MIGDEP_LIEN_DATE,
                                            MIGDEP_AC_LIEN_AMT,
                                            MIGDEP_LIEN_TO_BRN,
                                            MIGDEP_LIEN_TO_ACNUM,
                                            MIGDEP_TRF_ON,
                                            MIGDEP_INT_BAL,
                                            MIGDEP_AMT_TRF_OD,
                                            MIGDEP_PREV_YEAR_INT,
                                            MIGDEP_NOMINATION_REQD,
                                            MIGDEP_REG_DATE,
                                            MIGDEP_MANUAL_REF_NUM,
                                            MIGDEP_CUST_LTR_REF_DATE,
                                            MIGDEP_CUST_CODE,
                                            MIGDEP_NOMINEE_NAME,
                                            MIGDEP_DOB,
                                            MIGDEP_GUAR_CUST_CODE,
                                            MIGDEP_GUAR_CUST_NAME,
                                            MIGDEP_NATURE_OF_GUAR,
                                            MIGDEP_RELATIONSHIP,
                                            MIGDEP_ADDR1,
                                            MIGDEP_ADDR2,
                                            MIGDEP_ADDR3,
                                            MIGDEP_ADDR4,
                                            MIGDEP_ADDR5,
                                            MIGDEP_REMARKS,
                                            MIGDEP_ENTD_BY,
                                            MIGDEP_ENTD_ON,
                                            MIGDEP_RECPT_NUM,
                                            MIGDEP_RECOVER_AMT,
                                            MIGDEP_STLMNT_FLAG,
                                            MIGDEP_PROV_CALC_ON,
                                            MIGDEP_CURR_PROV_AMT)
         SELECT TO_NUMBER (f.BRANCD),                        --MIGDEP_BRN_CODE
                SUBSTR (F.ACTNUM, 1, 3) || '0'
                || (CASE F.ACTYPE
                       WHEN 'S01' THEN '318'
                       WHEN 'S02' THEN '310'
                       WHEN 'D25' THEN '410'
                       WHEN 'D26' THEN '420'
                       ELSE SUBSTR (F.ACTNUM, 4, 3)
                    END)
                || '0'
                || SUBSTR (F.ACTNUM, 7)
                   actnum,                                 --MIGDEP_DEP_AC_NUM
                1,                                           --MIGDEP_CONT_NUM
                SUBSTR (f.ACTNUM, 4, 3) PROD_CODE,         -- MIGDEP_PROD_CODE
                CASE WHEN f.MATFLG = 'R' THEN f.DRENDT ELSE f.OPNDAT END
                   OPEN_DATE,                           --MIGDEP_DEP_OPEN_DATE
                CASE WHEN f.MATFLG = 'R' THEN f.DRENDT ELSE f.OPNDAT END
                   EFF_DATE,                                 --MIGDEP_EFF_DATE
                f.CURCDE,                                    --MIGDEP_DEP_CURR
                0,                                           --MIGDEP_UNIT_AMT
                f.DEPAMT,                                  --MIGDEP_AC_DEP_AMT
                f.DEPAMT,                                  --MIGDEP_BC_DEP_AMT
                0,                                          --MIGDEP_DEP_UNITS
                CASE f.lperod
                   WHEN 'M' THEN f.NODAYS
                   WHEN 'Y' THEN f.NODAYS * 12
                END
                   NOMNTHS,                            --MIGDEP_DEP_PRD_MONTHS
                0,                                       --MIGDEP_DEP_PRD_DAYS
                ADD_MONTHS (
                   (CASE WHEN f.MATFLG = 'R' THEN f.DRENDT ELSE f.OPNDAT END),
                   CASE f.lperod
                      WHEN 'M' THEN f.NODAYS
                      WHEN 'Y' THEN f.NODAYS * 12
                   END)
                   MATDAT,                                   --MIGDEP_MAT_DATE
                f.CRIRTE,                                --MIGDEP_STD_INT_RATE
                f.CRIRTE,                             --MIGDEP_ACTUAL_INT_RATE
                ROUND (f.MATAMT),                           --MIGDEP_MAT_VALUE
                0,                                 --MIGDEP_MAT_VALUE_PER_UNIT
                'X',                      --MIGDEP_INT_PAY_FREQ (anniversery?)
                0,                                      --MIGDEP_DISC_INT_RATE
                CASE f.actype
                   WHEN 'D23' THEN ROUND ( (f.DEPAMT * f.CRIRTE) / 1200)
                   ELSE ROUND (f.MATAMT - f.DEPAMT)
                END
                   PERIODICAL_INT_AMT, --MIGDEP_PERIODICAL_INT_AMT (Formula: (P * INTRATE)/1200 )
                '0',                                          --MIGDEP_RENEWAL
                '0',                             --MIGDEP_TRF_FROM_ANOTHER_BRN
                NULL,                                    --MIGDEP_TRF_FROM_BRN
                '',                                    --MIGDEP_TRF_DEP_AC_NUM
                0,                                       --MIGDEP_TRF_CONT_NUM
                0,                                       --MIGDEP_TOT_AMT_TRFD
                0,                                --MIGDEP_INT_POR_OF_AMT_TRFD
                0,                                        --MIGDEP_IBR_ADV_NUM
                '',                                      --MIGDEP_IBR_ADV_DATE
                '',                                     --MIGDEP_IBR_TYPE_CODE
                0,                                 --MIGDEP_TRANSTLMNT_INV_NUM
                1,                                   --MIGDEP_AUTO_INT_PAYMENT
                'R',                                    --MIGDEP_STLMNT_OPTION
                CASE f.MATACT WHEN 'R' THEN 1 WHEN 'I' THEN 2 END, --MIGDEP_RENEWAL_OPTION
                99,                                 --MIGDEP_NUM_AUTO_RENEWALS
                '1',                                   --MIGDEP_INT_CR_TO_ACNT
                '0',                              --MIGDEP_DEP_DUE_NOTICE_REQD
                '',                                       --MIGDEP_FREQ_OF_DEP
                '',                                        --MIGDEP_NO_OF_INST
                '',                                   --MIGDEP_INST_PAY_OPTION
                '',                                --MIGDEP_AUTO_INST_REC_REQD
                '',                                  --MIGDEP_INST_REC_FROM_AC
                '',                                      --MIGDEP_INST_REC_DAY
                '',                                         --MIGDEP_COLL_CODE
                CASE
                   WHEN (CASE
                            WHEN f.MATFLG = 'R' THEN f.DRENDT
                            ELSE f.OPNDAT
                         END) < P_MONTH_END THEN P_MONTH_END
                   ELSE NULL
                END,                                    --MIGDEP_INT_ACCR_UPTO
                '',                                      --MIGDEP_CLOSURE_DATE
                '',                                      --MIGDEP_TRF_TO_OD_ON
                CASE
                   WHEN (CASE
                            WHEN f.MATFLG = 'R' THEN f.DRENDT
                            ELSE f.OPNDAT
                         END) < P_MONTH_END THEN P_MONTH_END
                   ELSE NULL
                END,                                    --MIGDEP_INT_PAID_UPTO
                0,                                --MIGDEP_COMPLETED_ROLLOVERS
                '1',                                 --MIGDEP_EXCLUDE_DAY_FLAG
                '',                                  --MIGDEP_PER_INT_UNIT_AMT
                '',                                     --MIGDEP_BAL_DEP_UNITS
                '',                                      --MIGDEP_BAL_PER_UNIT
                '',                             --MIGDEP_TOT_BAL_FOR_REM_UNITS
                (SELECT  (NVL (SUM (criamt), 0))
                   FROM STLBAS.STDEPINT
                  WHERE     BRANCD = F.BRANCD
                        AND ACTNUM = F.ACTNUM
                        AND ACTYPE = F.ACTYPE
                        AND POSTFLG IN ('N', 'Y'))
                   INT_ACCR_AMT,   --MIGDEP_AC_INT_ACCR_AMT -- BCBL_VALIDATION
                (SELECT  (NVL (SUM (criamt), 0))
                   FROM STLBAS.STDEPINT
                  WHERE     BRANCD = F.BRANCD
                        AND ACTNUM = F.ACTNUM
                        AND ACTYPE = F.ACTYPE
                        AND POSTFLG IN ('N', 'Y'))
                   BC_INT_ACR_AMT, --MIGDEP_BC_INT_ACCR_AMT -- BCBL_VALIDATION
                (SELECT  (NVL (SUM (criamt), 0))
                   FROM STLBAS.STDEPINT
                  WHERE     BRANCD = F.BRANCD
                        AND ACTNUM = F.ACTNUM
                        AND ACTYPE = F.ACTYPE
                        AND POSTFLG = 'Y')
                   INT_PAY_AMT,     --MIGDEP_AC_INT_PAY_AMT -- BCBL_VALIDATION
                (SELECT  (NVL (SUM (criamt), 0))
                   FROM STLBAS.STDEPINT
                  WHERE     BRANCD = F.BRANCD
                        AND ACTNUM = F.ACTNUM
                        AND ACTYPE = F.ACTYPE
                        AND POSTFLG = 'Y')
                   BC_INT_PAY_AMT,  --MIGDEP_BC_INT_PAY_AMT -- BCBL_VALIDATION
                'N/A',                                --MIGDEP_BK_DT_OP_REASON
                CASE
                   WHEN (CASE
                            WHEN f.MATFLG = 'R' THEN f.DRENDT
                            ELSE f.OPNDAT
                         END) < P_MONTH_END THEN P_MONTH_END
                   ELSE NULL
                END,                                    --MIGDEP_INT_CALC_UPTO
                0,                                       --MIGDEP_INT_CALC_AMT
                0,                               --MIGDEP_INT_CALC_AMT_PAYABLE
                CASE
                   WHEN (CASE
                            WHEN f.MATFLG = 'R' THEN f.DRENDT
                            ELSE f.OPNDAT
                         END) < P_MONTH_END THEN P_MONTH_END
                   ELSE NULL
                END,                            --MIGDEP_INT_CALC_PAYABLE_UPTO
                f.DEPAMT,                                    --MIGDEP_CONT_AMT
                SUBSTR (F.CRACNO, 1, 3) || '0'
                || (CASE F.CRACTY
                       WHEN 'S01' THEN '318'
                       WHEN 'S02' THEN '310'
                       WHEN 'D25' THEN '410'
                       WHEN 'D26' THEN '420'
                       ELSE SUBSTR (F.CRACNO, 4, 3)
                    END)
                || '0'
                || SUBSTR (F.CRACNO, 7)
                   CRACNO,                              --MIGDEP_INT_CR_AC_NUM
                SUBSTR (F.CRACNO, 1, 3) || '0'
                || (CASE F.CRACTY
                       WHEN 'S01' THEN '318'
                       WHEN 'S02' THEN '310'
                       WHEN 'D25' THEN '410'
                       WHEN 'D26' THEN '420'
                       ELSE SUBSTR (F.CRACNO, 4, 3)
                    END)
                || '0'
                || SUBSTR (F.CRACNO, 7)
                   CRACNO,                         --MIGDEP_CLOSURE_STL_AC_NUM
                f.LINTDT,                                   --MIGDEP_LIEN_DATE
                f.DEPAMT,                                 --MIGDEP_AC_LIEN_AMT
                CASE WHEN f.LINTDT IS NOT NULL THEN TO_NUMBER (f.BRANCD) END
                   LIEN_TO_BRN,                           --MIGDEP_LIEN_TO_BRN
                (SELECT SUBSTR (ACTNUM, 1, 3) || '0'
                        || (CASE F.ACTYPE
                               WHEN 'S01' THEN '318'
                               WHEN 'S02' THEN '310'
                               WHEN 'D25' THEN '410'
                               WHEN 'D26' THEN '420'
                               ELSE SUBSTR (ACTNUM, 4, 3)
                            END)
                        || '0'
                        || SUBSTR (ACTNUM, 7)
                           LIEN_TO_ACNUM
                   FROM STLBAS.STLOANSD
                  WHERE     BRANCD = f.BRANCD
                        AND CUSTID = f.CUSCOD
                        AND LPAD (CERTNO, 10, 0) = LPAD (f.FDRNUM, 10, 0))
                   LIEN_TO_ACNUM,                       --MIGDEP_LIEN_TO_ACNUM
                '',                                            --MIGDEP_TRF_ON
                '',                                           --MIGDEP_INT_BAL
                '',                                        --MIGDEP_AMT_TRF_OD
                0,                                      --MIGDEP_PREV_YEAR_INT
                '0',                                  --MIGDEP_NOMINATION_REQD
                '',                                          --MIGDEP_REG_DATE
                '',                                    --MIGDEP_MANUAL_REF_NUM
                '',                                 --MIGDEP_CUST_LTR_REF_DATE
                f.CUSCOD,                                   --MIGDEP_CUST_CODE
                '',                                      --MIGDEP_NOMINEE_NAME
                '',                                               --MIGDEP_DOB
                NULL,                                  --MIGDEP_GUAR_CUST_CODE
                '',                                    --MIGDEP_GUAR_CUST_NAME
                'N',                                   --MIGDEP_NATURE_OF_GUAR
                '',                                      --MIGDEP_RELATIONSHIP
                '',                                             --MIGDEP_ADDR1
                '',                                             --MIGDEP_ADDR2
                '',                                             --MIGDEP_ADDR3
                '',                                             --MIGDEP_ADDR4
                '',                                             --MIGDEP_ADDR5
                '',                                            --IGDEP_REMARKS
                f.OPRSTAMP,                                   --MIGDEP_ENTD_BY
                f.TIMSTAMP,                                   --MIGDEP_ENTD_ON
                SUBSTR (f.ACTNUM, 7),                       --MIGDEP_RECPT_NUM
                0,                                        --MIGDEP_RECOVER_AMT
                'C',                                      --MIGDEP_STLMNT_FLAG
                P_MONTH_END,                             --MIGDEP_PROV_CALC_ON
                0 CUR_PRV_AMT                           --MIGDEP_CURR_PROV_AMT
           FROM STLBAS.stfacmas f
          WHERE     f.brancd = P_BRANCH_CODE
                AND f.actype IN (SELECT actype
                                   FROM STLBAS.stfeacty
                                  WHERE depnat = 'F')
                AND f.ACSTAT NOT IN ('TRF', 'CLS')
                AND f.CLSDAT IS NULL
                AND f.curbal <> 0;


      DBMS_OUTPUT.
       PUT_LINE (
            'COMPLETE MIG_PBDCONTRACT (FD) TABLE '
         || SQL%ROWCOUNT
         || ' ROWS INSERTED');
   EXCEPTION
      WHEN OTHERS
      THEN
         V_ERRCODE := SQLCODE;
         V_ERRM := SQLERRM;

         INSERT
           INTO MIG_DATA_COLLECT_ERROR (MIG_BRANCH_CODE,
                                        MIG_SQLERRCODE,
                                        MIG_SQL_ERRM,TABLE_NAME)
         VALUES (P_BRANCH_CODE, V_ERRCODE, V_ERRM,'MIG_PBDCONTRACT(FD)');
   END;


   BEGIN
      DBMS_OUTPUT.
       PUT_LINE ('STARTING DATA INSERT INTO MIG_PBDCONTRACT  (RD) TABLE');

      INSERT INTO BCBL.MIG_PBDCONTRACT (MIGDEP_BRN_CODE,
                                            MIGDEP_DEP_AC_NUM,
                                            MIGDEP_CONT_NUM,
                                            MIGDEP_PROD_CODE,
                                            MIGDEP_DEP_OPEN_DATE,
                                            MIGDEP_EFF_DATE,
                                            MIGDEP_DEP_CURR,
                                            MIGDEP_UNIT_AMT,
                                            MIGDEP_AC_DEP_AMT,
                                            MIGDEP_BC_DEP_AMT,
                                            MIGDEP_DEP_UNITS,
                                            MIGDEP_DEP_PRD_MONTHS,
                                            MIGDEP_DEP_PRD_DAYS,
                                            MIGDEP_MAT_DATE,
                                            MIGDEP_STD_INT_RATE,
                                            MIGDEP_ACTUAL_INT_RATE,
                                            MIGDEP_MAT_VALUE,
                                            MIGDEP_MAT_VALUE_PER_UNIT,
                                            MIGDEP_INT_PAY_FREQ,
                                            MIGDEP_DISC_INT_RATE,
                                            MIGDEP_PERIODICAL_INT_AMT,
                                            MIGDEP_RENEWAL,
                                            MIGDEP_TRF_FROM_ANOTHER_BRN,
                                            MIGDEP_TRF_FROM_BRN,
                                            MIGDEP_TRF_DEP_AC_NUM,
                                            MIGDEP_TRF_CONT_NUM,
                                            MIGDEP_TOT_AMT_TRFD,
                                            MIGDEP_INT_POR_OF_AMT_TRFD,
                                            MIGDEP_IBR_ADV_NUM,
                                            MIGDEP_IBR_ADV_DATE,
                                            MIGDEP_IBR_TYPE_CODE,
                                            MIGDEP_TRANSTLMNT_INV_NUM,
                                            MIGDEP_AUTO_INT_PAYMENT,
                                            MIGDEP_STLMNT_OPTION,
                                            MIGDEP_RENEWAL_OPTION,
                                            MIGDEP_NUM_AUTO_RENEWALS,
                                            MIGDEP_INT_CR_TO_ACNT,
                                            MIGDEP_DEP_DUE_NOTICE_REQD,
                                            MIGDEP_FREQ_OF_DEP,
                                            MIGDEP_NO_OF_INST,
                                            MIGDEP_INST_PAY_OPTION,
                                            MIGDEP_AUTO_INST_REC_REQD,
                                            MIGDEP_INST_REC_FROM_AC,
                                            MIGDEP_INST_REC_DAY,
                                            MIGDEP_COLL_CODE,
                                            MIGDEP_INT_ACCR_UPTO,
                                            MIGDEP_CLOSURE_DATE,
                                            MIGDEP_TRF_TO_OD_ON,
                                            MIGDEP_INT_PAID_UPTO,
                                            MIGDEP_COMPLETED_ROLLOVERS,
                                            MIGDEP_EXCLUDE_DAY_FLAG,
                                            MIGDEP_PER_INT_UNIT_AMT,
                                            MIGDEP_BAL_DEP_UNITS,
                                            MIGDEP_BAL_PER_UNIT,
                                            MIGDEP_TOT_BAL_FOR_REM_UNITS,
                                            MIGDEP_AC_INT_ACCR_AMT,
                                            MIGDEP_BC_INT_ACCR_AMT,
                                            MIGDEP_AC_INT_PAY_AMT,
                                            MIGDEP_BC_INT_PAY_AMT,
                                            MIGDEP_BK_DT_OP_REASON,
                                            MIGDEP_INT_CALC_UPTO,
                                            MIGDEP_INT_CALC_AMT,
                                            MIGDEP_INT_CALC_AMT_PAYABLE,
                                            MIGDEP_INT_CALC_PAYABLE_UPTO,
                                            MIGDEP_CONT_AMT,
                                            MIGDEP_INT_CR_AC_NUM,
                                            MIGDEP_CLOSURE_STL_AC_NUM,
                                            MIGDEP_LIEN_DATE,
                                            MIGDEP_AC_LIEN_AMT,
                                            MIGDEP_LIEN_TO_BRN,
                                            MIGDEP_LIEN_TO_ACNUM,
                                            MIGDEP_TRF_ON,
                                            MIGDEP_INT_BAL,
                                            MIGDEP_AMT_TRF_OD,
                                            MIGDEP_PREV_YEAR_INT,
                                            MIGDEP_NOMINATION_REQD,
                                            MIGDEP_REG_DATE,
                                            MIGDEP_MANUAL_REF_NUM,
                                            MIGDEP_CUST_LTR_REF_DATE,
                                            MIGDEP_CUST_CODE,
                                            MIGDEP_NOMINEE_NAME,
                                            MIGDEP_DOB,
                                            MIGDEP_GUAR_CUST_CODE,
                                            MIGDEP_GUAR_CUST_NAME,
                                            MIGDEP_NATURE_OF_GUAR,
                                            MIGDEP_RELATIONSHIP,
                                            MIGDEP_ADDR1,
                                            MIGDEP_ADDR2,
                                            MIGDEP_ADDR3,
                                            MIGDEP_ADDR4,
                                            MIGDEP_ADDR5,
                                            MIGDEP_REMARKS,
                                            MIGDEP_ENTD_BY,
                                            MIGDEP_ENTD_ON,
                                            MIGDEP_RECPT_NUM,
                                            MIGDEP_RECOVER_AMT,
                                            MIGDEP_STLMNT_FLAG,
                                            MIGDEP_PROV_CALC_ON,
                                            MIGDEP_CURR_PROV_AMT)
         SELECT TO_NUMBER (f.BRANCD),                       ---MIGDEP_BRN_CODE
                SUBSTR (F.ACTNUM, 1, 3) || '0'
                || (CASE F.ACTYPE
                       WHEN 'S01' THEN '318'
                       WHEN 'S02' THEN '310'
                       WHEN 'D25' THEN '410'
                       WHEN 'D26' THEN '420'
                       ELSE SUBSTR (F.ACTNUM, 4, 3)
                    END)
                || '0'
                || SUBSTR (F.ACTNUM, 7)
                   actnum,                                 --MIGDEP_DEP_AC_NUM
                0,                                           --MIGDEP_CONT_NUM
                SUBSTR (f.ACTNUM, 4, 3) PROD_CODE,         -- MIGDEP_PROD_CODE
                f.OPNDAT,                               --MIGDEP_DEP_OPEN_DATE
                f.OPNDAT,                                    --MIGDEP_EFF_DATE
                f.CURCDE,                                    --MIGDEP_DEP_CURR
                0,                                           --MIGDEP_UNIT_AMT
                f.INSAMT,                                  --MIGDEP_AC_DEP_AMT
                f.INSAMT,                                  --MIGDEP_BC_DEP_AMT
                0,                                          --MIGDEP_DEP_UNITS
                CASE f.lperod
                   WHEN 'M' THEN f.NODAYS
                   WHEN 'Y' THEN f.NODAYS * 12
                END
                   NOMNTHS,                            --MIGDEP_DEP_PRD_MONTHS
                '',                                      --MIGDEP_DEP_PRD_DAYS
                ADD_MONTHS (
                   OPNDAT,
                   CASE f.lperod
                      WHEN 'M' THEN f.NODAYS
                      WHEN 'Y' THEN f.NODAYS * 12
                   END)
                   MATDAT,                                   --MIGDEP_MAT_DATE
                f.CRIRTE,                                --MIGDEP_STD_INT_RATE
                f.CRIRTE,                             --MIGDEP_ACTUAL_INT_RATE
                ROUND (f.MATAMT),                           --MIGDEP_MAT_VALUE
                0,                                 --MIGDEP_MAT_VALUE_PER_UNIT
                'X',                                     --MIGDEP_INT_PAY_FREQ
                0,                                      --MIGDEP_DISC_INT_RATE
                0,                                 --MIGDEP_PERIODICAL_INT_AMT
                '0',                                          --MIGDEP_RENEWAL
                '0',                             --MIGDEP_TRF_FROM_ANOTHER_BRN
                NULL,                                    --MIGDEP_TRF_FROM_BRN
                '',                                    --MIGDEP_TRF_DEP_AC_NUM
                0,                                       --MIGDEP_TRF_CONT_NUM
                0,                                       --MIGDEP_TOT_AMT_TRFD
                0,                                --MIGDEP_INT_POR_OF_AMT_TRFD
                0,                                        --MIGDEP_IBR_ADV_NUM
                '',                                      --MIGDEP_IBR_ADV_DATE
                '',                                     --MIGDEP_IBR_TYPE_CODE
                0,                                 --MIGDEP_TRANSTLMNT_INV_NUM
                1,                                   --MIGDEP_AUTO_INT_PAYMENT
                'C',                                    --MIGDEP_STLMNT_OPTION
                '',                                    --MIGDEP_RENEWAL_OPTION
                0,                                  --MIGDEP_NUM_AUTO_RENEWALS
                '1',                                   --MIGDEP_INT_CR_TO_ACNT
                '0',                              --MIGDEP_DEP_DUE_NOTICE_REQD
                f.INSFRQ,                                 --MIGDEP_FREQ_OF_DEP
                CASE f.lperod
                   WHEN 'M' THEN f.NODAYS
                   WHEN 'Y' THEN f.NODAYS * 12
                END
                   NO_OF_INST,                             --MIGDEP_NO_OF_INST
                '1',                                  --MIGDEP_INST_PAY_OPTION
                (CASE f.autrec WHEN 'Y' THEN '1' ELSE '0' END), --MIGDEP_AUTO_INST_REC_REQD
                '',                                  --MIGDEP_INST_REC_FROM_AC
                0,                                       --MIGDEP_INST_REC_DAY
                '',                                         --MIGDEP_COLL_CODE
                CASE
                   WHEN F.OPNDAT < P_MONTH_END THEN P_MONTH_END
                   ELSE NULL
                END,                    --MIGDEP_INT_ACCR_UPTO BCBL_VALIDATION
                '',                                      --MIGDEP_CLOSURE_DATE
                '',                                      --MIGDEP_TRF_TO_OD_ON
                CASE
                   WHEN F.OPNDAT < P_MONTH_END THEN P_MONTH_END
                   ELSE NULL
                END,                 --MIGDEP_INT_PAID_UPTO -- BCBL_VALIDATION
                0,                                --MIGDEP_COMPLETED_ROLLOVERS
                '1',                                 --MIGDEP_EXCLUDE_DAY_FLAG
                '',                                  --MIGDEP_PER_INT_UNIT_AMT
                '',                                     --MIGDEP_BAL_DEP_UNITS
                '',                                      --MIGDEP_BAL_PER_UNIT
                '',                             --MIGDEP_TOT_BAL_FOR_REM_UNITS
                (SELECT  (SUM (NVL (criamt, 0)))
                   FROM STLBAS.STDEPINT
                  WHERE     BRANCD = F.BRANCD
                        AND STDEPINT.ACTYPE = F.ACTYPE
                        AND ACTNUM = F.ACTNUM
                        AND POSTFLG IN ('N', 'Y'))
                   INT_ACCR_AMT,                      --MIGDEP_AC_INT_ACCR_AMT
                (SELECT  (SUM (NVL (criamt, 0)))
                   FROM STLBAS.STDEPINT
                  WHERE     BRANCD = F.BRANCD
                        AND STDEPINT.ACTYPE = F.ACTYPE
                        AND ACTNUM = F.ACTNUM
                        AND POSTFLG = 'N')
                   BC_INT_ACR_AMT,                    --MIGDEP_BC_INT_ACCR_AMT
                (SELECT  (SUM (NVL (criamt, 0)))
                   FROM STLBAS.STDEPINT
                  WHERE     BRANCD = F.BRANCD
                        AND ACTNUM = F.ACTNUM
                        AND POSTFLG = 'Y')
                   INT_PAY_AMT,                        --MIGDEP_AC_INT_PAY_AMT
                (SELECT  (SUM (NVL (criamt, 0)))
                   FROM STLBAS.STDEPINT
                  WHERE     BRANCD = F.BRANCD
                        AND ACTNUM = F.ACTNUM
                        AND POSTFLG = 'Y')
                   BC_INT_PAY_AMT,                     --MIGDEP_BC_INT_PAY_AMT
                'N/A',                                --MIGDEP_BK_DT_OP_REASON
                CASE
                   WHEN F.OPNDAT < P_MONTH_END THEN P_MONTH_END
                   ELSE NULL
                END,                                    --MIGDEP_INT_CALC_UPTO
                0,                                       --MIGDEP_INT_CALC_AMT
                0,                               --MIGDEP_INT_CALC_AMT_PAYABLE
                CASE
                   WHEN F.OPNDAT < P_MONTH_END THEN P_MONTH_END
                   ELSE NULL
                END,                            --MIGDEP_INT_CALC_PAYABLE_UPTO
                f.DEPAMT,                                    --MIGDEP_CONT_AMT
                SUBSTR (F.CRACNO, 1, 3) || '0'
                || (CASE F.CRACTY
                       WHEN 'S01' THEN '318'
                       WHEN 'S02' THEN '310'
                       WHEN 'D25' THEN '410'
                       WHEN 'D26' THEN '420'
                       ELSE SUBSTR (F.CRACNO, 4, 3)
                    END)
                || '0'
                || SUBSTR (F.CRACNO, 7)
                   CRACNO,                              --MIGDEP_INT_CR_AC_NUM
                SUBSTR (F.CRACNO, 1, 3) || '0'
                || (CASE F.CRACTY
                       WHEN 'S01' THEN '318'
                       WHEN 'S02' THEN '310'
                       WHEN 'D25' THEN '410'
                       WHEN 'D26' THEN '420'
                       ELSE SUBSTR (F.CRACNO, 4, 3)
                    END)
                || '0'
                || SUBSTR (F.CRACNO, 7)
                   CRACNO,                         --MIGDEP_CLOSURE_STL_AC_NUM
                '',                                         --MIGDEP_LIEN_DATE
                '',                                       --MIGDEP_AC_LIEN_AMT
                '',                                       --MIGDEP_LIEN_TO_BRN
                '',                                     --MIGDEP_LIEN_TO_ACNUM
                '',                                            --MIGDEP_TRF_ON
                '',                                           --MIGDEP_INT_BAL
                '',                                        --MIGDEP_AMT_TRF_OD
                0,                                      --MIGDEP_PREV_YEAR_INT
                '0',                                  --MIGDEP_NOMINATION_REQD
                '',                                          --MIGDEP_REG_DATE
                '',                                    --MIGDEP_MANUAL_REF_NUM
                '',                                 --MIGDEP_CUST_LTR_REF_DATE
                f.CUSCOD,                                   --MIGDEP_CUST_CODE
                '',                                      --MIGDEP_NOMINEE_NAME
                '',                                               --MIGDEP_DOB
                NULL,                                  --MIGDEP_GUAR_CUST_CODE
                '',                                    --MIGDEP_GUAR_CUST_NAME
                'N',                                   --MIGDEP_NATURE_OF_GUAR
                '',                                      --MIGDEP_RELATIONSHIP
                '',                                             --MIGDEP_ADDR1
                '',                                             --MIGDEP_ADDR2
                '',                                             --MIGDEP_ADDR3
                '',                                             --MIGDEP_ADDR4
                '',                                             --MIGDEP_ADDR5
                '',                                            --IGDEP_REMARKS
                f.OPRSTAMP,                                   --MIGDEP_ENTD_BY
                f.TIMSTAMP,                                   --MIGDEP_ENTD_ON
                SUBSTR (f.ACTNUM, 7),                       --MIGDEP_RECPT_NUM
                0,                                        --MIGDEP_RECOVER_AMT
                'C',                                      --MIGDEP_STLMNT_FLAG
                P_MONTH_END,                             --MIGDEP_PROV_CALC_ON
                0 CUR_PRV_AMT                           --MIGDEP_CURR_PROV_AMT
           FROM STLBAS.STFACMAS f
          WHERE     f.brancd = P_BRANCH_CODE
                AND f.ACSTAT NOT IN ('TRF', 'CLS')
                AND f.CLSDAT IS NULL
                AND f.curbal <> 0
                AND f.actype IN (SELECT DISTINCT actype
                                   FROM STLBAS.stfeacty
                                  WHERE depnat = 'R');

      BEGIN
         UPDATE MIG_PBDCONTRACT
            SET MIG_PBDCONTRACT.MIGDEP_INT_CR_AC_NUM = NULL,
                MIG_PBDCONTRACT.MIGDEP_CLOSURE_STL_AC_NUM = NULL
          WHERE MIG_PBDCONTRACT.MIGDEP_INT_CR_AC_NUM = '00';

         UPDATE MIG_PBDCONTRACT
            SET MIG_PBDCONTRACT.MIGDEP_CLOSURE_STL_AC_NUM = NULL
          WHERE MIG_PBDCONTRACT.MIGDEP_CLOSURE_STL_AC_NUM = '00';
      END;

      DBMS_OUTPUT.
       PUT_LINE (
            'COMPLETED MIG_PBDCONTRACT (RD) TABLE '
         || SQL%ROWCOUNT
         || ' ROWS INSERTED');
   EXCEPTION
      WHEN OTHERS
      THEN
         V_ERRCODE := SQLCODE;
         V_ERRM := SQLERRM;

         INSERT
           INTO MIG_DATA_COLLECT_ERROR (MIG_BRANCH_CODE,
                                        MIG_SQLERRCODE,
                                        MIG_SQL_ERRM,TABLE_NAME)
         VALUES (P_BRANCH_CODE, V_ERRCODE, V_ERRM,'MIG_PBDCONTRACT (RD)');
   END;


   BEGIN
      DBMS_OUTPUT.PUT_LINE ('STARTING DATA INSERT INTO MIG_RDINS TABLE');

      INSERT INTO BCBL.MIG_RDINS (RDINS_RD_AC_NUM,
                                      RDINS_ENTRY_DATE,
                                      RDINS_ENTRY_DAY_SL,
                                      RDINS_EFF_DATE,
                                      RDINS_AMT_OF_PYMT,
                                      RDINS_TWDS_INSTLMNT,
                                      RDINS_TWDS_PENAL_CHGS,
                                      RDINS_TWDS_INT,
                                      RDINS_REM1,
                                      RDINS_TRANSTL_INV_NUM,
                                      RDINS_ENTD_BY,
                                      RDINS_ENTD_ON)
         SELECT SUBSTR (S.actnum, 1, 3) || '0'
                || CASE S.ACTYPE
                      WHEN 'D25' THEN '410'
                      WHEN 'D26' THEN '420'
                      ELSE SUBSTR (S.actnum, 4, 3)
                   END
                || '0'
                || SUBSTR (S.actnum, 7)
                   RD_AC_NUM,
                P_MIG_DATE ENTRY_DATE,
                1 ENTRY_DAY_SL,
                S.STRDTE EFF_DATE,
                (  SELECT SUM (fet.cramlc) - SUM (fet.dbamlc)
                     FROM STLBAS.stfetran fet
                    WHERE     fet.actype = F.actype
                          AND fet.actnum = F.actnum
                          AND fet.docdat <= P_MIG_DATE
                 GROUP BY fet.actnum)
                   AMT_OF_PYMT,
                S.TOTAMT TWDS_INSTLMNT,
                0 PENAL_CHGS,
                (F.CURBAL - S.TOTAMT) TWDS_INT,
                '' REM1,
                '' INV_NUM,
                'MIG' ENTD_BY,
                SYSDATE ENTD_ON
           FROM STLBAS.STFACMAS F, STLBAS.STDEPSCH S
          WHERE     F.BRANCD = S.BRANCD
                AND F.ACTYPE = S.ACTYPE
                AND F.ACTNUM = S.ACTNUM
                AND f.brancd = P_BRANCH_CODE
                AND F.ACSTAT NOT IN ('TRF', 'CLS')
                AND F.CLSDAT IS NULL;

      DBMS_OUTPUT.
       PUT_LINE (
         'COMPLETE MIG_RDINS TABLE ' || SQL%ROWCOUNT || ' ROWS INSERTED');
   EXCEPTION
      WHEN OTHERS
      THEN
         V_ERRCODE := SQLCODE;
         V_ERRM := SQLERRM;

         INSERT
           INTO MIG_DATA_COLLECT_ERROR (MIG_BRANCH_CODE,
                                        MIG_SQLERRCODE,
                                        MIG_SQL_ERRM,TABLE_NAME)
         VALUES (P_BRANCH_CODE, V_ERRCODE, V_ERRM,'MIG_RDINS');
   END;


   BEGIN
      DBMS_OUTPUT.PUT_LINE ('STARTING DATA INSERT INTO MIG_DDPO TABLE');

      BEGIN
         INSERT INTO BCBL.MIG_DDPO (DDPOISS_BRN_CODE,
                                        DDPOISS_REMIT_CODE,
                                        DDPOISS_ISSUE_DATE,
                                        DDPOISS_PUR_ACNT,
                                        DDPOISS_PUR_CLIENT_NUM,
                                        DDPOISS_PUR_NAME,
                                        DDPOISS_PUR_MODE,
                                        DDPOISS_INST_CURRENCY,
                                        DDPOISS_INST_BANK,
                                        DDPOISS_INST_BRN,
                                        DDPOISS_INST_AMT,
                                        DDPOISS_ACTUAL_COMMN,
                                        DDPOISS_ACTUAL_STAX,
                                        DDPOISS_BENEF_CODE,
                                        DDPOISS_BENEF_NAME1,
                                        DDPOISS_BENEF_NAME2,
                                        DDPOISS_ON_AC_OF,
                                        DDPOISS_INST_NUM_PFX,
                                        DDPOISS_INST_NUM,
                                        DDPOISS_LAST_PRNT_BY,
                                        DDPOISS_LAST_PRNT_DATETIME,
                                        DDPOISS_ENTD_BY,
                                        DDPOISS_ENTD_ON,
                                        DDPOISS_PAYMENT_DATE,
                                        DDPOISS_ADVICE_DATE)
            SELECT TO_NUMBER (r.BRANCD),
                   DECODE (r.actype,
                           'R07', 'PO',
                           'R08', 'PO',
                           'R03', 'DD',
                           'R04', 'DD',
                           ''),
                   r.DOCDAT,
                   '',
                   r.DBACNO,
                   SUBSTR (r.SENDNM, 1, 50),
                   CASE r.DOCTYP WHEN 'DC' THEN '1' ELSE '3' END PUR_MODE,
                   'BDT',
                   'BCBL',
                   TO_NUMBER (r.brancd),
                   r.RMTAMT,
                   ROUND (r.CHGAMT / 1.15) ACTUAL_COMMN,
                   (r.CHGAMT - ROUND (r.CHGAMT / 1.15)) ACTUAL_STAX,
                   '',
                   SUBSTR (r.BENFC1, 1, 50),
                   SUBSTR (r.BENFC2, 1, 50),
                   '',
                   DECODE (r.actype,
                           'R07', 'PO',
                           'R08', 'PO',
                           'R03', 'DD',
                           'R04', 'DD',
                           '')
                      INST_NUM_PFX,
                   TO_NUMBER (SUBSTR (r.refnum, 2, 15)) INST_NUM,
                   R.OPRSTAMP,
                   r.TIMSTAMP,
                   r.oprstamp,
                   r.timstamp,
                   '',
                   ''
              FROM STLBAS.STREMITT r
             WHERE r.brancd = P_BRANCH_CODE AND ACTYPE IN ('R03', 'R07')
                   AND REFNUM NOT IN
                          (SELECT REFNUM
                             FROM STLBAS.STREMITT
                            WHERE brancd = P_BRANCH_CODE
                                  AND ACTYPE IN ('R04', 'R08'));

         DBMS_OUTPUT.
          PUT_LINE (
            'COMPLETE MIG_DDPO TABLE ' || SQL%ROWCOUNT || ' ROWS INSERTED');
      EXCEPTION
         WHEN OTHERS
         THEN
            V_ERRCODE := SQLCODE;
            V_ERRM := SQLERRM;

            INSERT
              INTO MIG_DATA_COLLECT_ERROR (MIG_BRANCH_CODE,
                                           MIG_SQLERRCODE,
                                           MIG_SQL_ERRM,TABLE_NAME)
            VALUES (P_BRANCH_CODE, V_ERRCODE, V_ERRM,'MIG_DDPO');
      END;

      BEGIN
         DBMS_OUTPUT.PUT_LINE ('STARTING DATA INSERT INTO MIG_CHEQUE TABLE');

         INSERT INTO BCBL.MIG_CHEQUE (CBISS_ACNUM,
                                          CBISS_ISSUE_DATE,
                                          CBISS_ISSUE_DAY_SL,
                                          CBISS_CBTYPE_CODE,
                                          CBISS_CHQBK_SIZE,
                                          CBISS_CHQBK_PREFIX,
                                          CBISS_FROM_LEAF_NUM,
                                          CBISS_UPTO_LEAF_NUM,
                                          CBISS_SELF_TPRTY,
                                          CBISS_REM1,
                                          CBISS_CHGS_AMT,
                                          CBISS_SERVICE_TAX_AMT,
                                          CBISS_ENTD_BY,
                                          CBISS_ENTD_ON)
            SELECT SUBSTR (STCHQDTL.ACTNUM, 1, 3) || '0'
                   || (CASE STCHQDTL.ACTYPE
                          WHEN 'S01' THEN '318'
                          WHEN 'S02' THEN '310'
                          WHEN 'D25' THEN '410'
                          WHEN 'D26' THEN '420'
                          ELSE SUBSTR (STCHQDTL.ACTNUM, 4, 3)
                       END)
                   || '0'
                   || SUBSTR (STCHQDTL.ACTNUM, 7)
                      actnum,
                   stfchqis.docdat,
                   1 issue_day_srl,
                   (CASE
                       WHEN SUBSTR (stfchqis.actype, 1, 1) = 'S' THEN '1'
                       WHEN stfchqis.actype = 'C01' THEN '2'
                       --WHEN '135' '' THEN '3'
                    WHEN stfchqis.actype = 'C03' THEN '4'
                       --WHEN '261' THEN '5'
                    WHEN stfchqis.actype IN ('C02', 'C09') THEN '6'
                       ELSE '1'
                    END)
                      cbtype_code,
                   1 no_of_leaf,                            --stfchqis.noleaf,
                   stfchqis.chqser,
                   (SELECT (REGEXP_REPLACE (stchqdtl.CHQNUM, '[a-zA-Z]', ''))
                      FROM DUAL)
                      from_leaf_num,
                   (SELECT (REGEXP_REPLACE (stchqdtl.CHQNUM, '[a-zA-Z]', ''))
                      FROM DUAL)
                      to_leaf_num,
                   'S' self_tprty,
                   '',
                   0,
                   0,
                   stfchqis.oprstamp,
                   stfchqis.timstamp
              FROM STLBAS.STCHQDTL, STLBAS.STFCHQIS
             WHERE     STFCHQIS.BRANCD = P_BRANCH_CODE
                   AND STCHQDTL.BRANCD = STFCHQIS.BRANCD
                   AND STCHQDTL.DOCTYP = STFCHQIS.DOCTYP
                   AND STCHQDTL.DOCNUM = STFCHQIS.DOCNUM
                   --AND STCHQDTL.ACTNUM=STFCHQIS.ACTNUM
                   AND STFCHQIS.STSFLG = 'I'
                   AND STCHQDTL.STSFLG = 'A'
                   AND STCHQDTL.ACTNUM  IN
                          (SELECT STFACMAS.ACTNUM -- ADDED BY RAJIB FOR FILTER CLOSE ACCOUNT
                             FROM STLBAS.STFACMAS
                            WHERE     BRANCD = P_BRANCH_CODE
                                  AND ACSTAT NOT IN ('TRF', 'CLS')
                                  AND CLSDAT IS NULL);

         DBMS_OUTPUT.
          PUT_LINE (
            'COMPLETE  MIG_CHEQUE TABLE ' || SQL%ROWCOUNT || ' ROWS INSERTED');
      EXCEPTION
         WHEN OTHERS
         THEN
            V_ERRCODE := SQLCODE;
            V_ERRM := SQLERRM;

            INSERT
              INTO MIG_DATA_COLLECT_ERROR (MIG_BRANCH_CODE,
                                           MIG_SQLERRCODE,
                                           MIG_SQL_ERRM,TABLE_NAME)
            VALUES (P_BRANCH_CODE, V_ERRCODE, V_ERRM,'MIG_CHEQUE');
      END;

      BEGIN
         DBMS_OUTPUT.PUT_LINE ('STARTING DATA INSERT INTO MIG_STOPCHQ TABLE');

         INSERT INTO BCBL.MIG_STOPCHQ (STOPCHQ_ACNUM,
                                           STOPCHQ_ENTRY_DATE,
                                           STOPCHQ_DAY_SL,
                                           STOPCHQ_CLIENT_LTR_REF_NO,
                                           STOPCHQ_CLIENT_LTR_DATE,
                                           STOPCHQ_FROM_CHQ_NUM,
                                           STOPCHQ_NUM_CHQS_STOPPED,
                                           STOPCHQ_CHQ_AMT,
                                           STOPCHQ_CHQ_DATE,
                                           STOPCHQ_CHQ_BENEF_NAME,
                                           STOPCHQ_REASON1,
                                           STOPCHQ_CHGS_CURR,
                                           STOPCHQ_CHGS_AMT,
                                           STOPCHQ_SERVICE_TAX_AMT,
                                           STOPCHQ_ENTD_BY,
                                           STOPCHQ_ENTD_ON)
            SELECT SUBSTR (STCHQDTL.ACTNUM, 1, 3) || '0'
                   || (CASE STCHQDTL.ACTYPE
                          WHEN 'S01' THEN '318'
                          WHEN 'S02' THEN '310'
                          WHEN 'D25' THEN '410'
                          WHEN 'D26' THEN '420'
                          ELSE SUBSTR (STCHQDTL.ACTNUM, 4, 3)
                       END)
                   || '0'
                   || SUBSTR (STCHQDTL.ACTNUM, 7)
                      actnum,
                   stchqdtl.docdat,
                   1 issue_day_srl,
                   1 CLIENT_LTR_REF_NO,
                   TRUNC (STCHQDTL.timstamp) CLIENT_LTR_DATE,
                   (SELECT (REGEXP_REPLACE (stchqdtl.chqnum, '[a-zA-Z]', ''))
                      FROM DUAL)
                      from_chq_num,
                   1 num_chq_stopped,
                   stchqdtl.isamlc,
                   stchqdtl.issdat,
                   stchqdtl.issuto,
                   NVL (stchqdtl.reason, 'STOP'),
                   'BDT',
                   0,
                   0,
                   stchqdtl.oprstamp,
                   stchqdtl.timstamp
              FROM STLBAS.STCHQDTL, STLBAS.STFACMAS
             WHERE     STCHQDTL.BRANCD = STFACMAS.BRANCD
                   AND STCHQDTL.ACTYPE = STFACMAS.ACTYPE
                   AND STCHQDTL.ACTNUM = STFACMAS.ACTNUM
                   AND STCHQDTL.BRANCD = P_BRANCH_CODE
                   AND STCHQDTL.STSFLG = 'S'
                   AND ACSTAT NOT IN ('TRF', 'CLS')
                   AND CLSDAT IS NULL;

         DBMS_OUTPUT.
          PUT_LINE (
            'COMPLETE MIG_STOPCHQ TABLE ' || SQL%ROWCOUNT || ' ROWS INSERTED');
      EXCEPTION
         WHEN OTHERS
         THEN
            V_ERRCODE := SQLCODE;
            V_ERRM := SQLERRM;

            INSERT
              INTO MIG_DATA_COLLECT_ERROR (MIG_BRANCH_CODE,
                                           MIG_SQLERRCODE,
                                           MIG_SQL_ERRM,TABLE_NAME)
            VALUES (P_BRANCH_CODE, V_ERRCODE, V_ERRM,'MIG_STOPCHQ');
      END;

      BEGIN
         DBMS_OUTPUT.PUT_LINE ('STARTING DATA INSERT INTO MIG_LNACNT TABLE');

         INSERT INTO BCBL.MIG_LNACNT (LNACNT_ACNUM,
                                          LNACNT_BRN_CODE,
                                          LNACNT_CLIENT_NUM,
                                          LNACNT_PURPOSE_CODE,
                                          LNACNT_LAST_AOD_GIVEN_ON,
                                          LNACNT_NEXT_AOD_DUE_ON,
                                          LNACNT_DISB_TYPE,
                                          LNACNT_SUBSIDY_AVAILABLE,
                                          LNACNT_AUTO_INSTALL_RECOV_REQD,
                                          LNACNT_RECOV_ACNT_NUM1,
                                          LNACNT_RECOV_ACNT_NUM2,
                                          LNACNT_RECOV_ACNT_NUM3,
                                          LNACNT_RECOV_ACNT_NUM4,
                                          LNACNT_RECOV_ACNT_NUM5,
                                          LNACNT_RECOV_ACNT_NUM6,
                                          LNACNT_RECOV_ACNT_NUM7,
                                          LNACNT_RECOV_ACNT_NUM8,
                                          LNACNT_RECOV_ACNT_NUM9,
                                          LNACNT_RECOV_ACNT_NUM10,
                                          LNACNT_INT_ACCR_UPTO,
                                          LNACNT_INT_APPLIED_UPTO_DATE,
                                          LNACNT_LIMIT_SANCTION_DATE,
                                          LNACNT_LIMIT_SANCTION_REF_NUM,
                                          LNACNT_LIMIT_EFF_DATE,
                                          LNACNT_LIMIT_EXPIRY_DATE,
                                          LNACNT_REVOLVING_LIMIT,
                                          LNACNT_SAUTH_CODE,
                                          LNACNT_SANCTION_CURR,
                                          LNACNT_SANCTION_AMT,
                                          LNACNT_LIMIT_AVL_ON_DATE,
                                          LNACNT_SEC_LIMIT_LINE,
                                          LNACNT_SEC_AMT_REQD,
                                          LNACNT_DP_REQD,
                                          LNACNT_DP_AMT,
                                          LNACNT_DP_VALID_UPTO,
                                          LNACNT_DUE_DATE_REVIEW,
                                          LNACNT_LIMIT_CURR_DISB_MADE,
                                          LNACNT_OUTSTANDING_BALANCE,
                                          LNACNT_PRIN_OS,
                                          LNACNT_INT_OS,
                                          LNACNT_CHG_OS,
                                          LNACNT_ASSET_STAT,
                                          LNACNT_DATE_OF_NPA,
                                          LNACNT_NPA_IDENTIFIED_DATE,
                                          LNACNT_TOT_SUSPENSE_BALANCE,
                                          LNACNT_INT_SUSP_BALANCE,
                                          LNACNT_CHG_SUSP_BALANCE,
                                          LNACNT_TOT_PROV_HELD,
                                          LNACNT_WRITTEN_OFF_AMT,
                                          LNACNT_AOD_GIVEN_ON,
                                          LNACNT_NEXT_AOD_DUE_ON1,
                                          LNACNT_REPAY_SCHD_REQD,
                                          LNACNT_OD_AMT,
                                          LNACNT_OD_DATE,
                                          LNACNT_PRIN_OD_AMT,
                                          LNACNT_INT_OD_AMT,
                                          LNACNT_CHGS_OD_AMT,
                                          LNACNT_PRIN_OD_DATE,
                                          LNACNT_INT_OD_DATE,
                                          LNACNT_CHGS_OD_DATE,
                                          LNACNT_SEGMENT_CODE,
                                          LNACNT_HO_DEPT_CODE,
                                          LNACNT_INDUS_CODE,
                                          LNACNT_SUB_INDUS_CODE,
                                          LNACNT_BSR_ACT_OCC_CODE,
                                          LNACNT_BSR_MAIN_ORG_CODE,
                                          LNACNT_BSR_SUB_ORG_CODE,
                                          LNACNT_BSR_STATE_CODE,
                                          LNACNT_BSR_DISTRICT_CODE,
                                          LNACNT_NATURE_BORROWAL_AC,
                                          LNACNT_POP_GROUP_CODE,
                                          LNACNT_SEC_TYPE_SPECIFIED,
                                          LNACNT_COLLAT_TYPE1,
                                          LNACNT_COLLAT_AMT_CURR1,
                                          LNACNT_COLLAT_AMT1,
                                          LNACNT_COLLAT_TYPE2,
                                          LNACNT_COLLAT_AMT_CURR2,
                                          LNACNT_COLLAT_AMT2,
                                          LNACNT_COLLAT_TYPE3,
                                          LNACNT_COLLAT_AMT_CURR3,
                                          LNACNT_COLLAT_AMT3,
                                          LNACNT_COLLAT_TYPE4,
                                          LNACNT_COLLAT_AMT_CURR4,
                                          LNACNT_COLLAT_AMT4,
                                          LNACNT_COLLAT_TYPE5,
                                          LNACNT_COLLAT_AMT_CURR5,
                                          LNACNT_COLLAT_AMT5,
                                          LNACNT_COLLAT_TYPE6,
                                          LNACNT_COLLAT_AMT_CURR6,
                                          LNACNT_COLLAT_AMT6,
                                          LNACNT_COLLAT_TYPE7,
                                          LNACNT_COLLAT_AMT_CURR7,
                                          LNACNT_COLLAT_AMT7,
                                          LNACNT_COLLAT_TYPE8,
                                          LNACNT_COLLAT_AMT_CURR8,
                                          LNACNT_COLLAT_AMT8,
                                          LNACNT_COLLAT_TYPE9,
                                          LNACNT_COLLAT_AMT_CURR9,
                                          LNACNT_COLLAT_AMT9,
                                          LNACNT_COLLAT_TYPE10,
                                          LNACNT_COLLAT_AMT_CURR10,
                                          LNACNT_COLLAT_AMT10,
                                          LNACNT_TOT_CASH_MARGIN_RECVD,
                                          LNACNT_TOT_CASH_MARGIN_REL,
                                          LNACNT_INT_APPL_DISABLED,
                                          LNACNT_INT_DISABLED_DATE)
            SELECT    SUBSTR (ACTNUM, 1, 3)
                   || '0'
                   || SUBSTR (ACTNUM, 4, 3)
                   || '0'
                   || SUBSTR (ACTNUM, 7)
                      ACTNUM,  --LNACNT_ACNUM                         VARCHAR2
                   TO_NUMBER (f.brancd) BRANCD, --LNACNT_BRN_CODE                      NUMBER
                   f.CUSCOD,     --LNACNT_CLIENT_NUM                    NUMBER
                   '0000', --LNACNT_PURPOSE_CODE                  VARCHAR2   --req  4210, 9300, 9810,9815, 9820, 9873, 9874
                   f.OPNDAT,       --LNACNT_LAST_AOD_GIVEN_ON             DATE
                   f.EXPDAT,       --LNACNT_NEXT_AOD_DUE_ON               DATE
                   'S',            --LNACNT_DISB_TYPE                     CHAR
                   '0',            --LNACNT_SUBSIDY_AVAILABLE             CHAR
                   '0',            --LNACNT_AUTO_INSTALL_RECOV_REQD       CHAR
                   '',         --LNACNT_RECOV_ACNT_NUM1               VARCHAR2
                   '',         --LNACNT_RECOV_ACNT_NUM2               VARCHAR2
                   '',         --LNACNT_RECOV_ACNT_NUM3               VARCHAR2
                   '',         --LNACNT_RECOV_ACNT_NUM4               VARCHAR2
                   '',         --LNACNT_RECOV_ACNT_NUM5               VARCHAR2
                   '',         --LNACNT_RECOV_ACNT_NUM6               VARCHAR2
                   '',         --LNACNT_RECOV_ACNT_NUM7               VARCHAR2
                   '',         --LNACNT_RECOV_ACNT_NUM8               VARCHAR2
                   '',         --LNACNT_RECOV_ACNT_NUM9               VARCHAR2
                   '',         --LNACNT_RECOV_ACNT_NUM10              VARCHAR2
                   P_MONTH_END,    --LNACNT_INT_ACCR_UPTO                 DATE
                   P_LAST_INT_POST, --LNACNT_INT_APPLIED_UPTO_DATE         DATE
                   f.OPNDAT,       --LNACNT_LIMIT_SANCTION_DATE           DATE
                   '',         --LNACNT_LIMIT_SANCTION_REF_NUM        VARCHAR2
                   f.APPDAT,       --LNACNT_LIMIT_EFF_DATE                DATE
                   f.EXPDAT,       --LNACNT_LIMIT_EXPIRY_DATE             DATE
                   '0',            --LNACNT_REVOLVING_LIMIT               CHAR
                   '',         --LNACNT_SAUTH_CODE                    VARCHAR2
                   f.CURCDE,   --LNACNT_SANCTION_CURR                 VARCHAR2
                   f.DEPAMT,     --LNACNT_SANCTION_AMT                  NUMBER
                   f.CURBAL, --LNACNT_LIMIT_AVL_ON_DATE             NUMBER  ***??
                   '',             --LNACNT_SEC_LIMIT_LINE                CHAR
                   0,            --LNACNT_SEC_AMT_REQD                  NUMBER
                   '',             --LNACNT_DP_REQD                       CHAR
                   0,            --LNACNT_DP_AMT                        NUMBER
                   '',             --LNACNT_DP_VALID_UPTO                 DATE
                   '',             --LNACNT_DUE_DATE_REVIEW               DATE
                   0,            --LNACNT_LIMIT_CURR_DISB_MADE          NUMBER
                   f.CURBAL, --LNACNT_OUTSTANDING_BALANCE           NUMBER  ***??
                   (SELECT SUM (DECODE (doctyp,  'IN', 0,  'CH', 0,  dbamlc))
                           - SUM (
                                DECODE (doctyp,  'IN', 0,  'CH', 0,  cramlc))
                      FROM STLBAS.stfetran
                     WHERE     brancd = f.brancd
                           AND actype = f.actype
                           AND actnum = f.actnum)
                      prnc_amt,  --LNACNT_PRIN_OS                       NUMBER
                   (SELECT SUM (
                              DECODE (doctyp,
                                      'IN', DECODE (DEBCRE, 'D', DBAMLC, 0),
                                      0))
                           - SUM (
                                DECODE (
                                   doctyp,
                                   'IN', DECODE (DEBCRE, 'C', CRAMLC, 0),
                                   0))
                      FROM STLBAS.stfetran
                     WHERE     brancd = f.brancd
                           AND actype = f.actype
                           AND actnum = f.actnum)
                      int_amt,   --LNACNT_INT_OS                        NUMBER
                   (SELECT SUM (
                              DECODE (doctyp,
                                      'CH', DECODE (DEBCRE, 'D', DBAMLC, 0),
                                      0))
                      FROM STLBAS.stfetran
                     WHERE     brancd = f.brancd
                           AND actype = f.actype
                           AND actnum = f.actnum)
                      Chrg_amt,  --LNACNT_CHG_OS                        NUMBER
                   (CASE NVL (F.LONCON, 'UCL')
                       WHEN 'UCL' THEN 'UC'
                       WHEN 'SMA' THEN 'SM'
                       WHEN 'SUB' THEN 'SS'
                       WHEN 'DBT' THEN 'DF'
                       WHEN 'BDL' THEN 'BL'
                    END)
                      LONCON,
                   CASE LONCON1 WHEN 'UCL' THEN NULL ELSE f.LONCDT END LONCDT, --LNACNT_DATE_OF_NPA                   DATE
                   CASE LONCON1 WHEN 'UCL' THEN NULL ELSE F.LONCDT END LONCDT, --LNACNT_NPA_IDENTIFIED_DATE           DATE
                   0,            --LNACNT_TOT_SUSPENSE_BALANCE          NUMBER
                   0,            --LNACNT_INT_SUSP_BALANCE              NUMBER
                   0,            --LNACNT_CHG_SUSP_BALANCE              NUMBER
                   0,            --LNACNT_TOT_PROV_HELD                 NUMBER
                   0,            --LNACNT_WRITTEN_OFF_AMT               NUMBER
                   '',             --LNACNT_AOD_GIVEN_ON                  DATE
                   '',             --LNACNT_NEXT_AOD_DUE_ON1              DATE
                   '1',            --LNACNT_REPAY_SCHD_REQD               CHAR
                   0,            --LNACNT_OD_AMT                        NUMBER
                   f.LONCDT,       --LNACNT_OD_DATE                       DATE
                   0,            --LNACNT_PRIN_OD_AMT                   NUMBER
                   0,            --LNACNT_INT_OD_AMT                    NUMBER
                   0,            --LNACNT_CHGS_OD_AMT                   NUMBER
                   '',             --LNACNT_PRIN_OD_DATE                  DATE
                   '',             --LNACNT_INT_OD_DATE                   DATE
                   '',             --LNACNT_CHGS_OD_DATE                  DATE
                   '911000', --LNACNT_SEGMENT_CODE                  VARCHAR2  --req 911000, 915059  mig_lnacnt
                   '001', --LNACNT_HO_DEPT_CODE                  VARCHAR2  --req
                   '0000', --LNACNT_INDUS_CODE                    VARCHAR2  --req  9873, 9820,
                   '0000', --LNACNT_SUB_INDUS_CODE                VARCHAR2  --req 9873, 9820,
                   '',         --LNACNT_BSR_ACT_OCC_CODE              VARCHAR2
                   '10', --LNACNT_BSR_MAIN_ORG_CODE             VARCHAR2  1000, 0300
                   '11', --LNACNT_BSR_SUB_ORG_CODE              VARCHAR2   1001, 0304
                   01,           --LNACNT_BSR_STATE_CODE                NUMBER
                   101,          --LNACNT_BSR_DISTRICT_CODE             NUMBER
                   99, --LNACNT_NATURE_BORROWAL_AC            NUMBER  --req   99, 12
                   0,            --LNACNT_POP_GROUP_CODE                NUMBER
                   '',             --LNACNT_SEC_TYPE_SPECIFIED            CHAR
                   '',         --LNACNT_COLLAT_TYPE1                  VARCHAR2
                   f.CURCDE,   --LNACNT_COLLAT_AMT_CURR1              VARCHAR2
                   0,            --LNACNT_COLLAT_AMT1                   NUMBER
                   '',         --LNACNT_COLLAT_TYPE2                  VARCHAR2
                   '',         --LNACNT_COLLAT_AMT_CURR2              VARCHAR2
                   0,            --LNACNT_COLLAT_AMT2                   NUMBER
                   '',         --LNACNT_COLLAT_TYPE3                  VARCHAR2
                   '',         --LNACNT_COLLAT_AMT_CURR3              VARCHAR2
                   0,            --LNACNT_COLLAT_AMT3                   NUMBER
                   '',         --LNACNT_COLLAT_TYPE4                  VARCHAR2
                   '',         --LNACNT_COLLAT_AMT_CURR4              VARCHAR2
                   0,            --LNACNT_COLLAT_AMT4                   NUMBER
                   '',         --LNACNT_COLLAT_TYPE5                  VARCHAR2
                   '',         --LNACNT_COLLAT_AMT_CURR5              VARCHAR2
                   0,            --LNACNT_COLLAT_AMT5                   NUMBER
                   '',         --LNACNT_COLLAT_TYPE6                  VARCHAR2
                   '',         --LNACNT_COLLAT_AMT_CURR6              VARCHAR2
                   0,            --LNACNT_COLLAT_AMT6                   NUMBER
                   '',         --LNACNT_COLLAT_TYPE7                  VARCHAR2
                   '',         --LNACNT_COLLAT_AMT_CURR7              VARCHAR2
                   0,            --LNACNT_COLLAT_AMT7                   NUMBER
                   '',         --LNACNT_COLLAT_TYPE8                  VARCHAR2
                   '',         --LNACNT_COLLAT_AMT_CURR8              VARCHAR2
                   0,            --LNACNT_COLLAT_AMT8                   NUMBER
                   '',         --LNACNT_COLLAT_TYPE9                  VARCHAR2
                   '',         --LNACNT_COLLAT_AMT_CURR9              VARCHAR2
                   0,            --LNACNT_COLLAT_AMT9                   NUMBER
                   '',         --LNACNT_COLLAT_TYPE10                 VARCHAR2
                   '',         --LNACNT_COLLAT_AMT_CURR10             VARCHAR2
                   0,            --LNACNT_COLLAT_AMT10                  NUMBER
                   0,            --LNACNT_TOT_CASH_MARGIN_RECVD         NUMBER
                   0,            --LNACNT_TOT_CASH_MARGIN_REL           NUMBER
                   '',             --LNACNT_INT_APPL_DISABLED             CHAR
                   ''              --LNACNT_INT_DISABLED_DATE             DATE
              FROM STLBAS.STFACMAS f                              --, STFALIMT
             WHERE     f.brancd = P_BRANCH_CODE       --, '041', '042', '043')
                   AND f.acstat NOT IN ('CLS', 'TRF')
                   AND f.CLSDAT IS NULL
                   AND (f.actype LIKE 'C%' OR f.actype LIKE 'L%')
                   AND f.actype NOT IN ('C01', 'L70', 'L71', 'L72');

         -- ----------------------
         BEGIN
            UPDATE BCBL.MIG_LNACNT
               SET LNACNT_PRIN_OS = -LNACNT_PRIN_OS,
                   LNACNT_INT_OS = -LNACNT_INT_OS,
                   LNACNT_CHG_OS = -LNACNT_CHG_OS;
         END;

         -- ---------------------------

         DBMS_OUTPUT.
          PUT_LINE (
            'COMPLETE MIG_LNACNT TABLE ' || SQL%ROWCOUNT || ' ROWS INSERTED');
      EXCEPTION
         WHEN OTHERS
         THEN
            V_ERRCODE := SQLCODE;
            V_ERRM := SQLERRM;

            INSERT
              INTO MIG_DATA_COLLECT_ERROR (MIG_BRANCH_CODE,
                                           MIG_SQLERRCODE,
                                           MIG_SQL_ERRM,TABLE_NAME)
            VALUES (P_BRANCH_CODE, V_ERRCODE, V_ERRM,'MIG_LNACNT');
      END;

      BEGIN
         DBMS_OUTPUT.PUT_LINE ('STARTING DATA INSERT INTO MIG_LNACIRS TABLE');

         INSERT INTO BCBL.MIG_LNACIRS (LNACIRS_ACNUM,
                                           LNACIRS_EFF_DATE,
                                           LNACIRS_AC_LEVEL_INT_REQD,
                                           LNACIRS_FIXED_FLOATING_RATE,
                                           LNACIRS_STD_INT_RATE_TYPE,
                                           LNACIRS_DIFF_INT_RATE_CHOICE,
                                           LNACIRS_DIFF_INT_RATE,
                                           LNACIRS_TENOR_SLAB_CODE,
                                           LNACIRS_TENOR_SLAB_SL,
                                           LNACIRS_AMT_SLAB_CODE,
                                           LNACIRS_AMT_SLAB_SL,
                                           LNACIRS_OVERDUE_INT_APPLICABLE,
                                           LNACIRS_AMT_SLABS_REQD,
                                           LNACIRS_APPL_INT_RATE,
                                           LNACIRS_UPTO_AMT1,
                                           LNACIRS_INT_RATE1,
                                           LNACIRS_UPTO_AMT2,
                                           LNACIRS_INT_RATE2,
                                           LNACIRS_UPTO_AMT3,
                                           LNACIRS_INT_RATE3,
                                           LNACIRS_UPTO_AMT4,
                                           LNACIRS_INT_RATE4,
                                           LNACIRS_UPTO_AMT5,
                                           LNACIRS_INT_RATE5)
            SELECT    SUBSTR (f.ACTNUM, 1, 3)
                   || '0'
                   || SUBSTR (f.ACTNUM, 4, 3)
                   || '0'
                   || SUBSTR (f.ACTNUM, 7)
                      ACTNUM,                                  --LNACIRS_ACNUM
                   l.EFFDAT,                                --LNACIRS_EFF_DATE
                   1,                              --LNACIRS_AC_LEVEL_INT_REQD
                   1,                            --LNACIRS_FIXED_FLOATING_RATE
                   '0',                            --LNACIRS_STD_INT_RATE_TYPE
                   '0',                         --LNACIRS_DIFF_INT_RATE_CHOICE
                   0,                                  --LNACIRS_DIFF_INT_RATE
                   '',                               --LNACIRS_TENOR_SLAB_CODE
                   '',                                 --LNACIRS_TENOR_SLAB_SL
                   '',                                 --LNACIRS_AMT_SLAB_CODE
                   '',                                   --LNACIRS_AMT_SLAB_SL
                   '0',                       --LNACIRS_OVERDUE_INT_APPLICABLE
                   0,                                 --LNACIRS_AMT_SLABS_REQD
                   l.DBINRT,                           --LNACIRS_APPL_INT_RATE
                   0,                                      --LNACIRS_UPTO_AMT1
                   0,                                      --LNACIRS_INT_RATE1
                   0,                                      --LNACIRS_UPTO_AMT2
                   0,                                      --LNACIRS_INT_RATE2
                   0,                                      --LNACIRS_UPTO_AMT3
                   0,                                      --LNACIRS_INT_RATE3
                   0,                                      --LNACIRS_UPTO_AMT4
                   0,                                      --LNACIRS_INT_RATE4
                   0,                                      --LNACIRS_UPTO_AMT5
                   0                                       --LNACIRS_INT_RATE5
              FROM STLBAS.stfacmas f, STLBAS.stfalimt l
             WHERE     f.BRANCD = l.BRANCD
                   AND f.ACTYPE = l.ACTYPE
                   AND f.ACTNUM = l.ACTNUM
                   AND f.BRANCD = P_BRANCH_CODE
                   AND f.ACSTAT NOT IN ('TRF', 'CLS')
                   AND f.CLSDAT IS NULL
                   AND SUBSTR (f.actype, 1, 1) IN ('C', 'L')
                   AND f.actype NOT IN ('C01', 'L70', 'L71', 'L72');

         DBMS_OUTPUT.
          PUT_LINE (
            'COMPLETE MIG_LNACIRS TABLE ' || SQL%ROWCOUNT || ' ROWS INSERTED');
      --AND L.EFFDAT >= F.OPNDAT AND APPFLG = 'Y'
      EXCEPTION
         WHEN OTHERS
         THEN
            V_ERRCODE := SQLCODE;
            V_ERRM := SQLERRM;

            INSERT
              INTO MIG_DATA_COLLECT_ERROR (MIG_BRANCH_CODE,
                                           MIG_SQLERRCODE,
                                           MIG_SQL_ERRM,TABLE_NAME)
            VALUES (P_BRANCH_CODE, V_ERRCODE, V_ERRM,'MIG_LNACIRS');
      END;
   END;


   BEGIN
      DBMS_OUTPUT.PUT_LINE ('STARTING DATA INSERT INTO MIG_ASSETCLS TABLE');

      INSERT INTO BCBL.MIG_ASSETCLS (ASSETCLS_ACNUM,
                                         ASSETCLS_EFF_DATE,
                                         ASSETCLSH_ASSET_CODE,
                                         ASSETCLSH_NPA_DATE,
                                         ASSETCLSH_REMARKS,
                                         ASSETCLSH_ENTD_BY,
                                         ASSETCLSH_ENTD_ON)
         SELECT    SUBSTR (ACTNUM, 1, 3)
                || '0'
                || SUBSTR (ACTNUM, 4, 3)
                || '0'
                || SUBSTR (ACTNUM, 7)
                   ACTNUM,
                CONDAT EFF_DATE,
                (CASE Loncon
                    WHEN 'BDL' THEN 'BL'
                    WHEN 'DBT' THEN 'DF'
                    WHEN 'SUB' THEN 'SS'
                    WHEN 'SMA' THEN 'SM'
                    WHEN 'UCL' THEN 'UC'
                 END)
                   ASSET_CODE,
                CONDAT NPA_DATE,
                NVL (REMARKS, 'MIGRATION'),
                OPRSTAMP,
                TIMSTAMP
           FROM STLBAS.STFACMAS
          WHERE     BRANCD = P_BRANCH_CODE
                AND ACTNUM <> P_BRANCH_CODE || '21099999'
                AND ACSTAT NOT IN ('TRF', 'CLS')
                AND CLSDAT IS NULL
                AND LONCON IN ('SMA', 'DBT', 'SUB', 'BDL', 'UCL')
                AND LONCON IS NOT NULL;

      DBMS_OUTPUT.
       PUT_LINE (
         'COMPLETE MIG_ASSETCLS TABLE ' || SQL%ROWCOUNT || ' ROWS INSERTED');
   EXCEPTION
      WHEN OTHERS
      THEN
         V_ERRCODE := SQLCODE;
         V_ERRM := SQLERRM;

         INSERT
           INTO MIG_DATA_COLLECT_ERROR (MIG_BRANCH_CODE,
                                        MIG_SQLERRCODE,
                                        MIG_SQL_ERRM,TABLE_NAME)
         VALUES (P_BRANCH_CODE, V_ERRCODE, V_ERRM,'MIG_ASSETCLS');
   END;

   BEGIN
      DBMS_OUTPUT.PUT_LINE ('STARTING DATA INSERT INTO MIG_LNDP TABLE');

      INSERT INTO BCBL.MIG_LNDP (LNDP_ACNUM,
                                     LNDP_EFF_DATE,
                                     LNDP_DP_CURR,
                                     LNDP_DP_AMT,
                                     LNDP_DP_AMT_AS_PER_SEC,
                                     LNDP_DP_VALID_UPTO_DATE,
                                     LNDP_DP_REVIEW_DUE_DATE)
         SELECT    SUBSTR (F.ACTNUM, 1, 3)
                || '0'
                || SUBSTR (F.ACTNUM, 4, 3)
                || '0'
                || SUBSTR (F.ACTNUM, 7)
                   ACTNUM,
                --  ACTYPE, RAJIB
                F.OPNDAT,
                F.CURCDE,
                CURBAL, /* RAJIB
                 (SELECT MAX (DBAMLC)
                    FROM STLBAS.STFETRAN
                   WHERE     BRANCD = F.BRANCD
                         AND ACTYPE = F.ACTYPE
                         AND ACTNUM = F.ACTNUM
                         AND DEBCRE = 'D'
                         AND UPPER (REMARK) LIKE '%DISBURSE%'
                         AND OPRCOD IN ('LDA', 'DEB', 'LDG'))
                    LN_DP,*/
                (SELECT NVL (MAX (DBAMLC), 0)
                   FROM STLBAS.STFETRAN
                  WHERE     BRANCD = F.BRANCD
                        AND ACTYPE = F.ACTYPE
                        AND ACTNUM = F.ACTNUM
                        AND DEBCRE = 'D'
                        AND UPPER (REMARK) LIKE '%DISBURSE%'
                        AND OPRCOD IN ('LDA', 'DEB', 'LDG'))
                   LNDP_DP_AMT_AS_PER_SEC,
                EXPDAT,
                ''
           FROM STLBAS.STFACMAS F
          WHERE     BRANCD = P_BRANCH_CODE
                AND ACSTAT NOT IN ('TRF', 'CLS')
                AND CLSDAT IS NULL
                AND SUBSTR (actype, 1, 1) IN ('C', 'L')
                AND actype NOT IN ('C01', 'L70', 'L71', 'L72');

      DBMS_OUTPUT.
       PUT_LINE (
         'COMPLETE MIG_LNDP TABLE ' || SQL%ROWCOUNT || ' ROWS INSERTED');
   EXCEPTION
      WHEN OTHERS
      THEN
         V_ERRCODE := SQLCODE;
         V_ERRM := SQLERRM;

         INSERT
           INTO MIG_DATA_COLLECT_ERROR (MIG_BRANCH_CODE,
                                        MIG_SQLERRCODE,
                                        MIG_SQL_ERRM,TABLE_NAME)
         VALUES (P_BRANCH_CODE, V_ERRCODE, V_ERRM,'MIG_LNDP');
   END;

   BEGIN
      DBMS_OUTPUT.PUT_LINE ('STARTING DATA INSERT INTO MIG_LNACRSDTL TABLE');

      INSERT INTO BCBL.MIG_LNACRSDTL (LNACRSDTL_ACNUM,
                                          LNACRS_EFF_DATE,
                                          LNACRS_EQU_INSTALLMENT,
                                          LNACRS_REPH_ON_AMT,
                                          LNACRS_SANC_BY,
                                          LNACRS_SANC_REF_NUM,
                                          LNACRS_SANC_DATE,
                                          LNACRS_CLIENT_REF_NUM,
                                          LNACRS_CLIENT_REF_DATE,
                                          LNACRS_REMARKS1,
                                          LNACRS_REMARKS2,
                                          LNACRS_REMARKS3,
                                          LNACRSDTL_REPAY_AMT_CURR,
                                          LNACRSDTL_REPAY_AMT,
                                          LNACRSDTL_REPAY_FREQ,
                                          LNACRSDTL_REPAY_FROM_DATE,
                                          LNACRSDTL_NUM_OF_INSTALLMENT)
         SELECT    SUBSTR (ACTNUM, 1, 3)
                || '0'
                || SUBSTR (ACTNUM, 4, 3)
                || '0'
                || SUBSTR (ACTNUM, 7)
                   ACTNUM,                                  --LNACRSDTL_ACNUM,
                OPNDAT,                                     --LNACRS_EFF_DATE,
                '1',                                 --LNACRS_EQU_INSTALLMENT,
                DEPAMT,                                  --LNACRS_REPH_ON_AMT,
                REPLACE (NVL (APRVBY, 'H O'), 'HEAD OFFICE', 'H O'), --LNACRS_SANC_BY,
                SUBSTR (SANAD1, GREATEST (-25, -LENGTH (SANAD1)), 25)
                   sanc_ref_no,                         --LNACRS_SANC_REF_NUM,
                APPDAT,                                    --LNACRS_SANC_DATE,
                '',                                   --LNACRS_CLIENT_REF_NUM,
                '',                                  --LNACRS_CLIENT_REF_DATE,
                '',                                         --LNACRS_REMARKS1,
                '',                                         --LNACRS_REMARKS2,
                '',                                         --LNACRS_REMARKS3,
                CURCDE,                            --LNACRSDTL_REPAY_AMT_CURR,
                INSAMT,                                 --LNACRSDTL_REPAY_AMT,
                INSFRQ,                                --LNACRSDTL_REPAY_FREQ,
                FINSDT,                           --LNACRSDTL_REPAY_FROM_DATE,
                NODAYS                          --LNACRSDTL_NUM_OF_INSTALLMENT
           FROM STLBAS.STFACMAS
          WHERE     BRANCD = P_BRANCH_CODE
                AND ACSTAT IN ('TRF', 'CLS')
                AND CLSDAT IS NULL
                AND SUBSTR (actype, 1, 1) IN ('L')
                AND actype NOT IN ('L70', 'L71', 'L72')
                AND NVL (CLTYPE, 'TRM') = 'TRM';

      DBMS_OUTPUT.
       PUT_LINE (
         'COMPLETE MIG_LNACRSDTL TABLE ' || SQL%ROWCOUNT || ' ROWS INSERTED');
   EXCEPTION
      WHEN OTHERS
      THEN
         V_ERRCODE := SQLCODE;
         V_ERRM := SQLERRM;

         INSERT
           INTO MIG_DATA_COLLECT_ERROR (MIG_BRANCH_CODE,
                                        MIG_SQLERRCODE,
                                        MIG_SQL_ERRM,TABLE_NAME)
         VALUES (P_BRANCH_CODE, V_ERRCODE, V_ERRM,'MIG_LNACRSDTL');
   END;


   BEGIN
      DBMS_OUTPUT.PUT_LINE ('STARTING DATA INSERT INTO MIG_GLOP_BAL TABLE');

      INSERT INTO BCBL.MIG_GLOP_BAL (GLOP_BRANCH_CODE,
                                         GLOP_GL_HEAD,
                                         GLOP_BAL_DATE,
                                         GLOP_BALANCE,
                                         GLOP_CURR_CODE,
                                         GLOP_LCY_BAL)
         SELECT GLOP_BRANCH_CODE,
                GLOP_GL_HEAD,
                P_MIG_DATE GLOP_BAL_DATE,
                GL_BAL GLOP_BALANCE,
                'BDT' GLOP_CURR_CODE,
                GL_BAL GLOP_LCY_BAL
           FROM (  SELECT compcode GLOP_BRANCH_CODE,
                          acctcode GLOP_GL_HEAD,
                          NVL (
                             SUM (DECODE (dbcrcode, 'C', jvlcamnt, -jvlcamnt)),
                             0)
                             GL_BAL
                     FROM STLBAS.sttrndtl
                    WHERE     compcode = P_BRANCH_CODE
                          AND doctdate <= P_MIG_DATE
                          AND acctcode NOT LIKE '14100%'
                 GROUP BY compcode, acctcode
                 --ORDER BY compcode, acctcode
                 UNION ALL
                   SELECT compcode GLOP_BRANCH_CODE,
                          '14100-01' GLOP_GL_HEAD,
                          NVL (
                             SUM (DECODE (dbcrcode, 'C', jvlcamnt, -jvlcamnt)),
                             0)
                             GL_BAL
                     FROM STLBAS.sttrndtl
                    WHERE     compcode = P_BRANCH_CODE
                          AND doctdate <= P_MIG_DATE
                          AND acctcode LIKE '14100%'
                 GROUP BY compcode
                 ORDER BY GLOP_BRANCH_CODE, GLOP_GL_HEAD)
          WHERE GL_BAL <> 0;

      DBMS_OUTPUT.
       PUT_LINE (
         'COMPLETE MIG_GLOP_BAL TABLE ' || SQL%ROWCOUNT || ' ROWS INSERTED');
   EXCEPTION
      WHEN OTHERS
      THEN
         V_ERRCODE := SQLCODE;
         V_ERRM := SQLERRM;

         INSERT
           INTO MIG_DATA_COLLECT_ERROR (MIG_BRANCH_CODE,
                                        MIG_SQLERRCODE,
                                        MIG_SQL_ERRM,TABLE_NAME)
         VALUES (P_BRANCH_CODE, V_ERRCODE, V_ERRM,'MIG_GLOP_BAL');
   END;

   BEGIN
      DBMS_OUTPUT.PUT_LINE ('STARTING DATA INSERT INTO MIG_ACOP_BAL TABLE');

      INSERT INTO BCBL.MIG_ACOP_BAL (ACOP_BRANCH_CODE,
                                         ACOP_AC_NUM,
                                         ACOP_AC_NAME,
                                         ACOP_BALANCE,
                                         ACOP_BAL_DATE,
                                         ACOP_CALC_INTEREST,
                                         ACOP_PRINCIPAL_OS,
                                         ACOP_INTEREST_OS,
                                         ACOP_CHGS_OS,
                                         ACOP_GL_HEAD,
                                         ACOP_RECPT_NUM,
                                         ACOP_CURR_CODE,
                                         ACOP_LCY_BAL)
           SELECT TO_NUMBER (brancd) BRANCH_CODE,
                  SUBSTR (ACTNUM, 1, 3) || '0'
                  || (CASE ACTYPE
                         WHEN 'S01' THEN '318'
                         WHEN 'S02' THEN '310'
                         WHEN 'D25' THEN '410'
                         WHEN 'D26' THEN '420'
                         ELSE SUBSTR (ACTNUM, 4, 3)
                      END)
                  || '0'
                  || SUBSTR (ACTNUM, 7)
                     AC_NUM,
                  SUBSTR (TRIM (UPPER (stfacmas.acttit)), 1, 50) AC_NAME,
                  NVL (
                     (  SELECT SUM (fet.cramlc) - SUM (fet.dbamlc)
                          FROM STLBAS.stfetran fet
                         WHERE     fet.actype = stfacmas.actype
                               AND fet.actnum = stfacmas.actnum
                               AND fet.docdat <= P_MIG_DATE
                      GROUP BY fet.actnum),
                     0)
                     curbal,
                  P_MIG_DATE BAL_DATE,
                  0 CALC_INT,
                  0 PRINC_OS,
                  0 INT_OS,
                  0 CHGS_OS,
                  (SELECT GLCODE
                     FROM STLBAS.stfaccur
                    WHERE     brancd = STFACMAS.BRANCD
                          AND actype = stfacmas.actype
                          AND typcde = 'GEN'
                          AND CURCDE = 'BDT')
                     GL_HEAD,
                  NVL (FDRNUM, 0) RECPT_NUM,
                  'BDT',
                  NVL (
                     (  SELECT SUM (fet.cramlc) - SUM (fet.dbamlc)
                          FROM STLBAS.stfetran fet
                         WHERE     fet.actype = stfacmas.actype
                               AND fet.actnum = stfacmas.actnum
                               AND fet.docdat <= P_MIG_DATE
                      GROUP BY fet.actnum),
                     0)
                     bc_curbal
             FROM STLBAS.stfacmas
            WHERE     brancd = P_BRANCH_CODE
                  AND acstat NOT IN ('CLS', 'TRF')
                  AND CLSDAT IS NULL
                  AND stfacmas.actnum <> P_BRANCH_CODE || '21099999'
                  AND ACTYPE NOT LIKE 'R%'
         ORDER BY BRANCD, GL_HEAD, ACTNUM;

      -- ------------------------------------
      BEGIN
         UPDATE mig_acop_bal
            SET mig_acop_bal.ACOP_PRINCIPAL_OS =
                   (SELECT mig_lnacnt.LNACNT_PRIN_OS
                      FROM mig_lnacnt
                     WHERE mig_lnacnt.lnacnt_acnum = mig_acop_bal.ACOP_AC_NUM),
                mig_acop_bal.ACOP_INTEREST_OS =
                   (SELECT mig_lnacnt.LNACNT_INT_OS
                      FROM mig_lnacnt
                     WHERE mig_lnacnt.lnacnt_acnum = mig_acop_bal.ACOP_AC_NUM),
                mig_acop_bal.ACOP_CHGS_OS =
                   (SELECT mig_lnacnt.LNACNT_CHG_OS
                      FROM mig_lnacnt
                     WHERE mig_lnacnt.lnacnt_acnum = mig_acop_bal.ACOP_AC_NUM)
          WHERE mig_acop_bal.ACOP_AC_NUM IN
                   (SELECT mig_lnacnt.lnacnt_acnum
                      FROM mig_lnacnt
                     WHERE mig_lnacnt.lnacnt_acnum = mig_acop_bal.ACOP_AC_NUM);
      END;

      -- ---------------------------------------

      DBMS_OUTPUT.
       PUT_LINE (
         'COMPLETE MIG_ACOP_BAL TABLE ' || SQL%ROWCOUNT || ' ROWS INSERTED');
   EXCEPTION
      WHEN OTHERS
      THEN
         V_ERRCODE := SQLCODE;
         V_ERRM := SQLERRM;

         INSERT
           INTO MIG_DATA_COLLECT_ERROR (MIG_BRANCH_CODE,
                                        MIG_SQLERRCODE,
                                        MIG_SQL_ERRM,TABLE_NAME)
         VALUES (P_BRANCH_CODE, V_ERRCODE, V_ERRM,'MIG_ACOP_BAL');
   END;

   BEGIN
      DBMS_OUTPUT.
       PUT_LINE ('STARTING DATA INSERT INTO MIG_LNTOTINTDBMIG (CON) TABLE');

      INSERT INTO BCBL.MIG_LNTOTINTDBMIG (LNTOTINTDB_INTERNAL_ACNUM,
                                              LNTOTINTDB_TOT_INT_DB_AMT)
           SELECT actnum,                          --LNTOTINTDB_INTERNAL_ACNUM
                         SUM (dbamlc) dbintamt     --LNTOTINTDB_TOT_INT_DB_AMT
             FROM STLBAS.stfetran
            WHERE brancd = P_BRANCH_CODE AND oprcod = 'IND'
                  AND actnum IN
                         (SELECT actnum
                            FROM STLBAS.stfacmas
                           WHERE     acstat <> 'CLS'
                                 AND cltype = 'CON' -- For continuous types of loan
                                 AND SUBSTR (actype, 1, 1) IN ('C', 'L')
                                 AND actype NOT IN ('C01', 'L70', 'L71', 'L72'))
         GROUP BY actnum;

      DBMS_OUTPUT.
       PUT_LINE (
            'COMPLETE MIG_LNTOTINTDBMIG TABLE '
         || SQL%ROWCOUNT
         || ' ROWS INSERTED');
   EXCEPTION
      WHEN OTHERS
      THEN
         V_ERRCODE := SQLCODE;
         V_ERRM := SQLERRM;

         INSERT
           INTO MIG_DATA_COLLECT_ERROR (MIG_BRANCH_CODE,
                                        MIG_SQLERRCODE,
                                        MIG_SQL_ERRM,TABLE_NAME)
         VALUES (P_BRANCH_CODE, V_ERRCODE, V_ERRM,'MIG_LNTOTINTDBMIG');
   END;

   BEGIN
      DBMS_OUTPUT.
       PUT_LINE ('STARTING DATA INSERT INTO MIG_LNTOTINTDBMIG (TRM) TABLE');

      INSERT INTO BCBL.MIG_LNTOTINTDBMIG (LNTOTINTDB_INTERNAL_ACNUM,
                                              LNTOTINTDB_TOT_INT_DB_AMT)
           SELECT actnum,                          --LNTOTINTDB_INTERNAL_ACNUM
                         SUM (dbamlc) dbintamt     --LNTOTINTDB_TOT_INT_DB_AMT
             FROM STLBAS.stfetran
            WHERE brancd = P_BRANCH_CODE AND oprcod = 'IND'
                  AND actnum IN
                         (SELECT actnum
                            FROM STLBAS.stfacmas
                           WHERE     acstat <> 'CLS'
                                 AND NVL (cltype, 'TRM') = 'TRM' -- For terms types of loan
                                 AND SUBSTR (actype, 1, 1) IN ('C', 'L')
                                 AND actype NOT IN ('C01', 'L70', 'L71', 'L72'))
         GROUP BY actnum;

      DBMS_OUTPUT.
       PUT_LINE (
            'COMPLETE MIG_LNTOTINTDBMIG TABLE '
         || SQL%ROWCOUNT
         || ' ROWS INSERTED');
   EXCEPTION
      WHEN OTHERS
      THEN
         V_ERRCODE := SQLCODE;
         V_ERRM := SQLERRM;

         INSERT
           INTO MIG_DATA_COLLECT_ERROR (MIG_BRANCH_CODE,
                                        MIG_SQLERRCODE,
                                        MIG_SQL_ERRM,TABLE_NAME)
         VALUES (P_BRANCH_CODE, V_ERRCODE, V_ERRM,'MIG_LNTOTINTDBMIG');
   END;

   BEGIN
      DBMS_OUTPUT.PUT_LINE ('STARTING DATA INSERT INTO MIG_LNACDSDTL TABLE');

      INSERT INTO BCBL.MIG_LNACDSDTL (LNACDSDTL_INTERNAL_ACNUM,
                                          LNACDSDTL_SL_NUM,
                                          LNACDSDTL_STAGE_DESCN,
                                          LNACDSDTL_DISB_CURR,
                                          LNACDSDTL_DISB_DATE,
                                          LNACDSDTL_DISB_AMOUNT)
         SELECT    SUBSTR (ACTNUM, 1, 3)
                || '0'
                || SUBSTR (ACTNUM, 4, 3)
                || '0'
                || SUBSTR (ACTNUM, 7)
                   ACTNUM,                         --LNACDSDTL_INTERNAL_ACNUM,
                '1',                                       --LNACDSDTL_SL_NUM,
                'Stage-1',                            --LNACDSDTL_STAGE_DESCN,
                'BDT',                                  --LNACDSDTL_DISB_CURR,
                DOCDAT,                                 --LNACDSDTL_DISB_DATE,
                DBAMLC                                 --LNACDSDTL_DISB_AMOUNT
           FROM STLBAS.STFETRAN
          WHERE     BRANCD = P_BRANCH_CODE
                AND SUBSTR (actype, 1, 1) = 'L'
                AND actype NOT IN ('L70', 'L71', 'L72')
                AND OPRCOD IN ('LDA', 'DEB', 'LDG')
                AND DEBCRE = 'D'
                AND DOCTYP NOT IN ('CH', 'IN')
                AND ACTNUM IN
                       (SELECT actnum
                          FROM STLBAS.stfacmas
                         WHERE     BRANCD = P_BRANCH_CODE
                               AND SUBSTR (actype, 1, 1) = 'L'
                               AND NVL (CLTYPE, 'TRM') = 'TRM'
                               AND ACSTAT <> 'CLS');

      DBMS_OUTPUT.
       PUT_LINE (
         'COMPLETE MIG_LNACDSDTL TABLE ' || SQL%ROWCOUNT || ' ROWS INSERTED');
   EXCEPTION
      WHEN OTHERS
      THEN
         V_ERRCODE := SQLCODE;
         V_ERRM := SQLERRM;

         INSERT
           INTO MIG_DATA_COLLECT_ERROR (MIG_BRANCH_CODE,
                                        MIG_SQLERRCODE,
                                        MIG_SQL_ERRM,TABLE_NAME)
         VALUES (P_BRANCH_CODE, V_ERRCODE, V_ERRM,'MIG_LNACDSDTL');
   END;



   BEGIN
      DBMS_OUTPUT.PUT_LINE ('STARTING DATA INSERT INTO MIG_MINBAL TABLE');

      INSERT INTO BCBL.MIG_MINBAL (BRN_CODE,
                                       ACCOUNTNO,
                                       BAL_DATE,
                                       AC_BALANCE,
                                       BC_BALANCE)
           SELECT TO_NUMBER (brancd) BRANCD,
                  SUBSTR (ACTNUM, 1, 3) || '0'
                  || (CASE ACTYPE
                         WHEN 'S01' THEN '318'
                         WHEN 'S02' THEN '310'
                         WHEN 'D25' THEN '410'
                         WHEN 'D26' THEN '420'
                         ELSE SUBSTR (ACTNUM, 4, 3)
                      END)
                  || '0'
                  || SUBSTR (ACTNUM, 7)
                     ACTNUM,
                  P_MIG_DATE,
                  MIN (run_bal),
                  MIN (run_bal) BC_BALANCE
             FROM (  SELECT BRANCD,
                            ACTYPE,
                            ACTNUM,
                            DOCDAT,
                            SUM (cramlc - dbamlc)
                               OVER (PARTITION BY actnum ORDER BY docdat)
                               run_bal
                       FROM STLBAS.stfetran
                      WHERE brancd = P_BRANCH_CODE AND actype = 'S02'
                            AND ACTNUM IN
                                   (SELECT actnum
                                      FROM STLBAS.stfacmas
                                     WHERE     BRANCD = P_BRANCH_CODE
                                           AND SUBSTR (actype, 1, 1) = 'S'
                                           AND ACSTAT = 'ACT')
                            AND docdat <= P_MIG_DATE
                   ORDER BY BRANCD,
                            ACTYPE,
                            ACTNUM,
                            DOCDAT)
         GROUP BY BRANCD, ACTYPE, ACTNUM;

      DBMS_OUTPUT.
       PUT_LINE (
         'COMPLETE MIG_MINBAL TABLE ' || SQL%ROWCOUNT || ' ROWS INSERTED');
   EXCEPTION
      WHEN OTHERS
      THEN
         V_ERRCODE := SQLCODE;
         V_ERRM := SQLERRM;

         INSERT
           INTO MIG_DATA_COLLECT_ERROR (MIG_BRANCH_CODE,
                                        MIG_SQLERRCODE,
                                        MIG_SQL_ERRM,TABLE_NAME)
         VALUES (P_BRANCH_CODE, V_ERRCODE, V_ERRM,'MIG_MINBAL');
   END;

   BEGIN
      DBMS_OUTPUT.PUT_LINE ('STARTING DATA INSERT INTO MIG_MAXBAL TABLE');

      INSERT INTO BCBL.MIG_MAXBAL (BRN_CODE,
                                       ACCOUNTNO,
                                       BAL_DATE,
                                       AC_BALANCE,
                                       BC_BALANCE)
           SELECT TO_NUMBER (brancd) BRANCD,
                  SUBSTR (ACTNUM, 1, 3) || '0'
                  || (CASE ACTYPE
                         WHEN 'S01' THEN '318'
                         WHEN 'S02' THEN '310'
                         ELSE SUBSTR (ACTNUM, 4, 3)
                      END)
                  || '0'
                  || SUBSTR (ACTNUM, 7)
                     ACTNUM,
                  P_MIG_DATE,
                  MAX (run_bal),
                  MAX (run_bal) BC_BALANCE
             FROM (  SELECT BRANCD,
                            ACTYPE,
                            ACTNUM,
                            DOCDAT,
                            SUM (cramlc - dbamlc)
                               OVER (PARTITION BY actnum ORDER BY docdat)
                               run_bal
                       FROM STLBAS.stfetran
                      WHERE brancd = P_BRANCH_CODE
                            AND SUBSTR (actype, 1, 1) = 'S'
                            AND ACTNUM IN
                                   (SELECT actnum
                                      FROM STLBAS.stfacmas
                                     WHERE     BRANCD = P_BRANCH_CODE
                                           AND SUBSTR (actype, 1, 1) = 'S'
                                           AND ACSTAT = 'ACT')
                            AND docdat <= P_MIG_DATE
                   ORDER BY BRANCD,
                            ACTYPE,
                            ACTNUM,
                            DOCDAT)
         GROUP BY BRANCD, ACTYPE, ACTNUM;


      DBMS_OUTPUT.
       PUT_LINE (
         'COMPLETE MIG_MAXBAL TABLE ' || SQL%ROWCOUNT || ' ROWS INSERTED');
   EXCEPTION
      WHEN OTHERS
      THEN
         V_ERRCODE := SQLCODE;
         V_ERRM := SQLERRM;

         INSERT
           INTO MIG_DATA_COLLECT_ERROR (MIG_BRANCH_CODE,
                                        MIG_SQLERRCODE,
                                        MIG_SQL_ERRM,TABLE_NAME)
         VALUES (P_BRANCH_CODE, V_ERRCODE, V_ERRM,'MIG_MAXBAL');
   END;

   BEGIN
      DBMS_OUTPUT.PUT_LINE ('STARTING DATA INSERT INTO MIG_DEPIA TABLE');

      INSERT INTO BCBL.MIG_DEPIA (DEPIA_BRN_CODE,
                                      DEPIA_ACCOUNTNUM,
                                      DEPIA_CONTRACT_NUM,
                                      DEPIA_DATE_OF_ENTRY,
                                      DEPIA_DAY_SL,
                                      DEPIA_AC_INT_ACCR_AMT,
                                      DEPIA_INT_ACCR_DB_CR,
                                      DEPIA_BC_INT_ACCR_AMT,
                                      DEPIA_ACCR_FROM_DATE,
                                      DEPIA_ACCR_UPTO_DATE,
                                      DEPIA_ENTRY_TYPE,
                                      DEPIA_PREV_YR_INT_ACCR)
           SELECT TO_NUMBER (d.brancd) DEPIA_BRN_CODE,        --DEPIA_BRN_CODE
                  SUBSTR (d.actnum, 1, 3) || '0'
                  || CASE D.ACTYPE
                        WHEN 'D25' THEN '410'
                        WHEN 'D26' THEN '420'
                        ELSE SUBSTR (d.actnum, 4, 3)
                     END
                  || '0'
                  || SUBSTR (d.actnum, 7)
                     DEPIA_ACCOUNTNUM,                      --DEPIA_ACCOUNTNUM
                  0 DEPIA_CONTRACT_NUM,                   --DEPIA_CONTRACT_NUM
                  TRUNC (d.timstamp) DEPIA_DATE_OF_ENTRY, --DEPIA_DATE_OF_ENTRY
                  1 DEPIA_DAY_SL,                               --DEPIA_DAY_SL
                  CRIAMT DEPIA_AC_INT_ACCR_AMT,        --DEPIA_AC_INT_ACCR_AMT
                  DECODE (d.postflg,  'Y', 'D',  'N', 'C') DEPIA_INT_ACCR_DB_CR, --DEPIA_INT_ACCR_DB_CR
                  CRIAMT DEPIA_BC_INT_ACCR_AMT,        --DEPIA_BC_INT_ACCR_AMT
                  BGNDAY DEPIA_ACCR_FROM_DATE,          --DEPIA_ACCR_FROM_DATE
                  ENDDAY DEPIA_ACCR_UPTO_DATE,          --DEPIA_ACCR_UPTO_DATE
                  DECODE (d.postflg,  'Y', 'IP',  'N', 'IA') DEPIA_ENTRY_TYPE, --DEPIA_ENTRY_TYPE
                  0 DEPIA_PREV_YR_INT_ACCR            --DEPIA_PREV_YR_INT_ACCR
             FROM STLBAS.stdepint d,
                  (SELECT brancd,
                          actype,
                          actnum,
                          curbal,
                          acstat
                     FROM STLBAS.stfacmas
                    WHERE     brancd = P_BRANCH_CODE
                          AND SUBSTR (actype, 1, 1) = 'D'
                          AND acstat = 'ACT'
                          AND CLSDAT IS NULL
                          AND curbal > 0) a
            WHERE     d.brancd = a.brancd
                  AND d.actype = a.actype
                  AND d.actnum = a.actnum
                  AND d.postflg IN ('N', 'Y')
                  AND d.brancd = P_BRANCH_CODE
         ORDER BY 1,
                  2,
                  3,
                  4,
                  5,
                  6;

      DBMS_OUTPUT.
       PUT_LINE (
         'COMPLETE MIG_DEPIA TABLE ' || SQL%ROWCOUNT || ' ROWS INSERTED');
   EXCEPTION
      WHEN OTHERS
      THEN
         V_ERRCODE := SQLCODE;
         V_ERRM := SQLERRM;

         INSERT
           INTO MIG_DATA_COLLECT_ERROR (MIG_BRANCH_CODE,
                                        MIG_SQLERRCODE,
                                        MIG_SQL_ERRM,TABLE_NAME)
         VALUES (P_BRANCH_CODE, V_ERRCODE, V_ERRM,'MIG_DEPIA');
   END;


   BEGIN
      DBMS_OUTPUT.PUT_LINE ('STARTING DATA INSERT INTO TEMP_LOANIA TABLE');

      INSERT INTO BCBL.TEMP_LOANIA (LOANIA_BRN_CODE,
                                        LOANIA_ACNT_NUM,
                                        LOANIA_VALUE_DATE,
                                        LOANIA_ACCRUAL_DATE,
                                        LOANIA_ACNT_CURR,
                                        LOANIA_ACNT_BAL,
                                        LOANIA_INT_ON_AMT,
                                        LOANIA_TOTAL_NEW_OD_INT_AMT,
                                        LOANIA_INT_RATE,
                                        LOANIA_OD_INT_RATE,
                                        LOANIA_LIMIT,
                                        LOANIA_DP,
                                        LOANIA_NPA_STATUS,
                                        LOANIA_NPA_AMT)
         SELECT TO_NUMBER (brancd) BRANCD,
                   SUBSTR (ACTNUM, 1, 3)
                || '0'
                || SUBSTR (ACTNUM, 4, 3)
                || '0'
                || SUBSTR (ACTNUM, 7)
                   ACTNUM,
                P_MIG_DATE MIG_DATE,
                P_MONTH_END ACCR_DATE,
                CURCDE,
                0 LNAC_BAL,
                INT_ACCRUED,
                0 OD_INT_AMT,
                INTRAT,
                0 OD_INT_RATE,
                0 LOAN_LIMIT,
                0 LOAN_DP,
                0 NPA_STATUS,
                0 NPA_AMOUNT
           FROM (  SELECT BRANCD,
                          ACTNUM,
                          CURCDE,
                          INTRAT,
                          SUM (DBIAMT) INT_ACCRUED
                     FROM STLBAS.stprodct
                    WHERE     BRANCD = P_BRANCH_CODE
                          AND SUBSTR (actype, 1, 1) IN ('C', 'L')
                          AND actype NOT IN ('C01', 'L70', 'L71', 'L72')
                          AND postflg = 'N'
                          AND bgnday BETWEEN P_LAST_INT_POST + 1
                                         AND P_MONTH_END
                 GROUP BY BRANCD,
                          ACTNUM,
                          CURCDE,
                          INTRAT);

      DBMS_OUTPUT.
       PUT_LINE (
         'COMPLETE TEMP_LOANIA TABLE ' || SQL%ROWCOUNT || ' ROWS INSERTED');
   EXCEPTION
      WHEN OTHERS
      THEN
         V_ERRCODE := SQLCODE;
         V_ERRM := SQLERRM;

         INSERT
           INTO MIG_DATA_COLLECT_ERROR (MIG_BRANCH_CODE,
                                        MIG_SQLERRCODE,
                                        MIG_SQL_ERRM,TABLE_NAME)
         VALUES (P_BRANCH_CODE, V_ERRCODE, V_ERRM,'TEMP_LOANIA');
   END;

   BEGIN
      DBMS_OUTPUT.PUT_LINE ('STARTING DATA INSERT INTO TEMP_SBCAIA TABLE');

      -- TEMP_SBCAIA (SAVING ACCRUAL) -----
      INSERT INTO BCBL.TEMP_SBCAIA (SBCAIA_BRN_CODE,
                                        SBCAIA_INTERNAL_ACNUM,
                                        SBCAIA_CR_DB_INT_FLG,
                                        SBCAIA_DATE_OF_ENTRY,
                                        SBCAIA_INT_ACCR_UPTO_DT,
                                        SBCAIA_TOT_NEW_INT_AMT,
                                        SBCAIA_AC_INT_ACCR_AMT,
                                        SBCAIA_BC_INT_ACCR_AMT,
                                        SBCAIA_BC_CONV_RATE,
                                        SBCAIA_INT_ACCR_DB_CR,
                                        SBCAIA_FROM_DATE,
                                        SBCAIA_UPTO_DATE,
                                        SBCAIA_INT_RATE)
         SELECT TO_NUMBER (brancd) BRANCD,                --   SBCAIA_BRN_CODE
                '0'
                || (CASE ACTYPE
                       WHEN 'S01' THEN '318'
                       WHEN 'S02' THEN '310'
                       ELSE SUBSTR (ACTNUM, 4, 3)
                    END)
                || '0'
                || SUBSTR (ACTNUM, 4, 3)
                || '00'
                || SUBSTR (ACTNUM, 7)
                   ACTNUM,                             --SBCAIA_INTERNAL_ACNUM
                '',                                     --SBCAIA_CR_DB_INT_FLG
                P_MIG_DATE MIG_DATE,                    --SBCAIA_DATE_OF_ENTRY
                P_MONTH_END ACCR_DATE,               --SBCAIA_INT_ACCR_UPTO_DT
                INT_ACCRUED,                          --SBCAIA_TOT_NEW_INT_AMT
                INT_ACCRUED,                          --SBCAIA_AC_INT_ACCR_AMT
                INT_ACCRUED,                          --SBCAIA_BC_INT_ACCR_AMT
                1,                                       --SBCAIA_BC_CONV_RATE
                'C',                                   --SBCAIA_INT_ACCR_DB_CR
                P_LAST_INT_POST,                            --SBCAIA_FROM_DATE
                P_MONTH_END,                                --SBCAIA_UPTO_DATE
                INTRAT                                       --SBCAIA_INT_RATE
           FROM (  SELECT BRANCD,
                          ACTYPE,
                          ACTNUM,
                          CURCDE,
                          INTRAT,
                          SUM (CRIAMT) INT_ACCRUED
                     FROM STLBAS.stprodct
                    WHERE     BRANCD = P_BRANCH_CODE
                          AND SUBSTR (actype, 1, 1) IN ('S')
                          AND postflg = 'N'
                          AND bgnday BETWEEN P_LAST_INT_POST AND P_MONTH_END
                 GROUP BY BRANCD,ACTYPE,
                          ACTNUM,
                          CURCDE,
                          INTRAT);

      DBMS_OUTPUT.
       PUT_LINE (
         'COMPLETE TEMP_SBCAIA TABLE ' || SQL%ROWCOUNT || ' ROWS INSERTED');
   EXCEPTION
      WHEN OTHERS
      THEN
         V_ERRCODE := SQLCODE;
         V_ERRM := SQLERRM;

         INSERT
           INTO MIG_DATA_COLLECT_ERROR (MIG_BRANCH_CODE,
                                        MIG_SQLERRCODE,
                                        MIG_SQL_ERRM,TABLE_NAME)
         VALUES (P_BRANCH_CODE, V_ERRCODE, V_ERRM,'TEMP_SBCAIA');
   END;


   BEGIN
      DBMS_OUTPUT.PUT_LINE ('STARTING DATA INSERT INTO MIG_NOMREG TABLE');

      INSERT INTO BCBL.MIG_NOMREG (NOMREG_AC_NUM,
                                       NOMREG_CONT_NUM,
                                       NOMREG_REG_DATE,
                                       NOMREG_REG_SL,
                                       NOMREG_DTL_SL,
                                       NOMREG_CUST_CODE,
                                       NOMREG_NOMINEE_NAME,
                                       NOMREG_DOB,
                                       NOMREG_ALOTTED_PERCENTAGE,
                                       NOMREG_GUAR_CUST_CODE,
                                       NOMREG_GUAR_CUST_NAME,
                                       NOMREG_NATURE_OF_GUAR,
                                       NOMREG_RELATIONSHIP,
                                       NOMREG_ADDR,
                                       NOMREG_MANUAL_REF_NUM,
                                       NOMREG_CUST_LTR_REF_DATE,
                                       NOMREG_BRN_CODE)
         SELECT   SUBSTR (ACTNUM, 1, 3) || '0'
                   || (CASE ACTYPE
                          WHEN 'S01' THEN '318'
                          WHEN 'S02' THEN '310'
                          WHEN 'D25' THEN '410'
                          WHEN 'D26' THEN '420'
                          ELSE SUBSTR (ACTNUM, 4, 3)
                       END)
                   || '0'
                   || SUBSTR (ACTNUM, 7) NOMREG_AC_NUM,
                1 NOMREG_CONT_NUM,
                TIMSTAMP REG_DATE,
                SERNUM REG_SL,
                '1' DTL_SL,
                NOMINE CUST_CODE,
                (SELECT SUBSTR (UPPER (CUSNMF) || ' ' || UPPER (CUSNML),
                                1,
                                50)
                   FROM STLBAS.STCUSMAS
                  WHERE CUSCOD = STNOMDTL.NOMINE)
                   NOMINEE_NAME,
                (SELECT CUSDOB
                   FROM STLBAS.STCUSMAS
                  WHERE CUSCOD = STNOMDTL.NOMINE)
                   NOM_DOB,
                NOMPER NOM_PCT,
                '' GUAR_CUST_CODE,
                '' GUAR_CUST_NAME,
                '' NATUAR_OF_GUAR,
                RELDES RELATION,
                (SELECT SUBSTR (ADDRS1 || ' ' || ADDRS2, 1, 35)
                   FROM STLBAS.STCUSMAS
                  WHERE CUSCOD = STNOMDTL.NOMINE)
                   ADDR,
                '' REF_NO,
                '' LTR_REF_DATE,
                BRANCD
           FROM STLBAS.STNOMDTL
          WHERE BRANCD = P_BRANCH_CODE 
               AND TYPCDE = 'NOM' 
               AND ACTNUM  IN
                          (SELECT STFACMAS.ACTNUM -- ADDED BY RAJIB FOR FILTER CLOSE ACCOUNT
                             FROM STLBAS.STFACMAS
                            WHERE     BRANCD = P_BRANCH_CODE
                                  AND ACSTAT NOT IN ('TRF', 'CLS')
                                  AND CLSDAT IS NULL);


      DBMS_OUTPUT.
       PUT_LINE (
         'COMPLETE MIG_NOMREG TABLE ' || SQL%ROWCOUNT || ' ROWS INSERTED');
   EXCEPTION
      WHEN OTHERS
      THEN
         V_ERRCODE := SQLCODE;
         V_ERRM := SQLERRM;

         INSERT
           INTO MIG_DATA_COLLECT_ERROR (MIG_BRANCH_CODE,
                                        MIG_SQLERRCODE,
                                        MIG_SQL_ERRM,TABLE_NAME)
         VALUES (P_BRANCH_CODE, V_ERRCODE, V_ERRM,'MIG_NOMREG');
   END;

   COMMIT;
   
   SP_MIGRATION_DATA_CROSSMATCH;
END;



declare
v_data varchar2(3000);
begin
SP_MIG_MIGRATIONDATACLEAN(v_data);
end;


BEGIN
MIG_BCBL_DATA_EXTRACT('040','28-FEB-2014','31-DEC-2013','03-MAR-2014');
END;


-- ACCOUNT/ PRODUCT CHACKING
SELECT DISTINCT ACNTS_AC_TYPE
FROM MIG_ACNTS
MINUS 
SELECT ACTYPE_CODE
FROM ACTYPES

-- NEW GL FINDING FROM STELAR

SELECT * FROM MIG_STL_GL_MAPING
WHERE INT_GL_CODE IS NULL;

-- GL LIST NOT MATCH IN INTELLECT WITH GLOPBAL

SELECT GLOP_GL_HEAD
FROM MIG_GLOP_BAL 
MINUS
SELECT EXTGL_ACCESS_CODE 
FROM EXTGL

-- CHECKING PRODUCTS LIST 

SELECT ACNTS_PROD_CODE
FROM MIG_ACNTS 
MINUS
SELECT PRODUCT_CODE 
FROM PRODUCTS

-- GL LIST NOT MATCH IN INTELLECT WITH AC_OPBAL

SELECT ACOP_GL_HEAD
FROM MIG_ACOP_BAL 
MINUS
SELECT EXTGL_ACCESS_CODE 
FROM EXTGL

-- GL LIST NOT MATCH WITH ACCONT 

SELECT ACNTS_GLACC_CODE
FROM MIG_ACNTS 
MINUS
SELECT EXTGL_ACCESS_CODE 
FROM EXTGL



SELECT COUNT(*), STL_GL_CODE
FROM MIG_STL_GL_MAPING
GROUP BY STL_GL_CODE
ORDER BY 1 DESC

---------------- THIS TABLE CONTAIN STLBAS AND INTELLECT GL MAPING INFORMATION ----------

c----Validation Query---------------------------- 
1.
--Interest Accrual (IA) related validation -------
----IA_mismatch_with_pbdcontract_and_depia

select
p.migdep_dep_ac_num,nvl(p.migdep_ac_int_accr_amt,0) ,migdep_dep_ac_num,sum_accr,
nvl(p.migdep_ac_int_accr_amt,0) -sum_accr,accr_date,p.migdep_int_accr_upto ,
accr_date - p.migdep_int_accr_upto
from mig_pbdcontract p ,
(select m.depia_accountnum,sum(nvl(m.depia_ac_int_accr_amt,0)) sum_accr,
max(m.depia_accr_upto_date) accr_date
from mig_depia m
where m.depia_entry_type= 'IA'
group by m.depia_accountnum) b
where p.migdep_dep_ac_num = b.depia_accountnum
AND (nvl(p.migdep_ac_int_accr_amt,0)-sum_accr) <> 0;

2.
---Interest Payed related validation 
---IP  CHEKING MIG_DEPIA and PBDCONTRACT 
------IP_mismatch_with_pbdcontract_and_depia

select                     
p.migdep_dep_ac_num,nvl(p.migdep_ac_int_pay_amt ,0),migdep_dep_ac_num,sum_accr,
nvl(p.migdep_ac_int_pay_amt,0)-sum_accr,accr_date,p.migdep_int_paid_upto ,
accr_date - p.migdep_int_paid_upto
from mig_pbdcontract p ,
(select m.depia_accountnum,sum(nvl(m.depia_ac_int_accr_amt,0)) sum_accr,
max(m.depia_accr_upto_date) accr_date
from mig_depia m
where m.depia_entry_type= 'IP'
group by m.depia_accountnum) b
where p.migdep_dep_ac_num = b.depia_accountnum
AND (nvl(p.migdep_ac_int_pay_amt ,0)-sum_accr) <> 0;

3.

---------------------------------- 
---DEPIA Related Validation 
----------------------------------------
-- IA in PBDCONTRACT but not in DEPIA

select migdep_dep_ac_num, nvl(p.migdep_ac_int_accr_amt,0)
from mig_pbdcontract p
where p.migdep_dep_ac_num not in
(select mig_depia.depia_accountnum  from mig_depia )
and nvl(p.migdep_ac_int_accr_amt,0) > 0;


4.
------
----- IP in PBDCONTRACT but not in depia ;

select migdep_dep_ac_num, p.migdep_ac_int_pay_amt
from mig_pbdcontract p
where p.migdep_dep_ac_num not in
(select mig_depia.depia_accountnum  from mig_depia )
and nvl(p.migdep_ac_int_pay_amt,0) > 0;

5.

-----Checking Interest_accrued_amount_(IA)_should_not_be_less_than_Interest_pay_amount

select migdep_dep_ac_num,
       p.migdep_dep_open_date,
       p.migdep_eff_date,
       p.migdep_eff_date,
       p.migdep_ac_int_accr_amt,
       migdep_ac_int_pay_amt
  from mig_pbdcontract p
 where nvl(p.migdep_ac_int_accr_amt, 0) < nvl(p.migdep_ac_int_pay_amt, 0);

6.

--Interest payable less then 0
select sum(nvl(p.migdep_ac_int_accr_amt, 0)) -
sum(nvl(p.migdep_ac_int_pay_amt, 0)) samt,
p.migdep_prod_code
from mig_pbdcontract p
where p.migdep_prod_code in
(select products.product_code
from products
where products.product_for_deposits = 1
and products.product_for_run_acs = 0)
group by p.migdep_prod_code; 

7.
-----Maturity Date mismatch for SBL

SELECT P.Migdep_Dep_Ac_Num,
       P.Migdep_Dep_Open_Date,
       P.Migdep_Dep_Prd_Months,
       p.migdep_mat_date,
       add_months(Migdep_Dep_Open_Date, P.Migdep_Dep_Prd_Months) MATURITY_DATE 
  FROM MIG_PBDCONTRACT P
  where add_months(Migdep_Dep_Open_Date, P.Migdep_Dep_Prd_Months) <> p.migdep_mat_date ;
  
  8.
 ------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------ 
 -----Checking  Last Interest Accrued Date is provided for Savings Accounts 


9.
----- check Last Interest posted Date is provided for Savings Accounts


10.




12.
-----query for last transaction date 

select * from mig_acnts where mig_acnts.acnts_last_tran_date  is null ;


13.

-----Pbdcontract INT_PAID_UPTO_should_not_be_null

select *  from mig_pbdcontract p where MIGDEP_INT_PAID_UPTO is null  and p.migdep_dep_open_date < '30-dec-2014' ;


14. 

--TWDS_INSTALLMENT SHOULD BE MULTIPLE OF INSTALLMENT IN PBDCONTRACT

select m.migdep_ac_dep_amt,
m.migdep_bc_dep_amt,
m.migdep_dep_ac_num,
r.rdins_entry_date,
r.rdins_amt_of_pymt,
r.rdins_twds_instlmnt,
r.rdins_twds_int
from mig_pbdcontract m,mig_rdins r
where m.migdep_prod_code in
(select p.product_code
from products p
where p.product_for_deposits = 1
and p.product_for_run_acs = 0)
and m.migdep_cont_num = 0
and mod(r.rdins_twds_instlmnt, m.migdep_ac_dep_amt) <> 0
and m.migdep_dep_ac_num = r.rdins_rd_ac_num

15. 

-- GLWISE DEPOSIT INTEREST PAYABLE FROM MIG_PBDCONTRACT 

-- If data show no need to verify 

SELECT DEPGL.depprcur_prod_code ,depprcur_int_accr_glacc,interest_payable    FROM
 (select distinct d.depprcur_prod_code, d.depprcur_int_accr_glacc
    from depprodcur d) DEPGL
,(select sum(nvl(p.migdep_ac_int_accr_amt, 0) -
           nvl(p.migdep_ac_int_pay_amt, 0)) interest_payable,
       p.migdep_prod_code
  from  mig_pbdcontract p
  group by   p.migdep_prod_code
  ) SUMDEP
  where DEPGL.DEPPRCUR_PROD_CODE = SUMDEP.migdep_prod_code
        and SUMDEP.interest_payable<>0
        
16 .

--INSTALLATIOS FROM MIG_RDINS  + IP from DEPIA should be equal to MIG_ACOP_BAL (FOR BCBL )

select  P.sl SERIAL , P.total+l.TDS    , l.TDS ,m.acop_lcy_bal,m.acop_lcy_bal-( P.total+l.TDS) Difference  from 
 (select r.rdins_rd_ac_num sl , sum(r.rdins_amt_of_pymt)   total  from mig_rdins r group by r.rdins_rd_ac_num  ) P ,
(
select a.depia_internal_acnum , a.IP_AMOUNT , b.TD_AMOUNT , a.IP_AMOUNT - b.TD_AMOUNT  TDS from 
(
select depia_internal_acnum, sum(nvl(depia_ac_int_accr_amt,0)) IP_AMOUNT,depia_entry_type  from temp_depia 
where temp_depia.depia_entry_type = 'IP'
group by depia_internal_acnum ,depia_entry_type
) a ,
(
select depia_internal_acnum, sum(nvl(depia_ac_int_accr_amt,0)) TD_AMOUNT ,depia_entry_type  from temp_depia 
where temp_depia.depia_entry_type = 'TD'
group by depia_internal_acnum ,depia_entry_type
) b
where a.depia_internal_acnum = b.depia_internal_acnum
) l ,
mig_acop_bal m
where      l.depia_internal_acnum = P.sl
         and m.acop_ac_num = P.sl
        -- and t.depia_entry_type='IP'
         and m.acop_lcy_bal<> P.total+l.TDS
         
17. 

-- WRONG PRINCIPAL INTEREST BIFERCATION IN STUFF mismatch with mig_acop_bal (for BCBL)

select s.accountno,
       m.acop_ac_num,
       m.acop_lcy_bal  ,
       (s.principal_bal + s.interest_bal) total
  from staffloans_pib s, mig_acop_bal m
 where s.accountno = m.acop_ac_num
       and (s.principal_bal + s.interest_bal)  <> m.acop_lcy_bal

18.

--MIG_RDINS where r.rdins_amt_of_pymt <> r.rdins_twds_instlmnt + r.rdins_twds_penal_chgs + r.rdins_twds_int 

select * from mig_rdins r where r.rdins_amt_of_pymt <> r.rdins_twds_instlmnt + r.rdins_twds_penal_chgs + r.rdins_twds_int ;         

19. loan interest suspence gl matching / loan interest receivable mathcing



----------------------------------------------


previous querries--


20. -- account number gl head mismatch for mig_acnts & mig_acop_bal  ACOP_GL_HEAD

select *
  from (select acop_ac_num,
               acop_gl_head,
               m.acnts_glacc_code,
               products.product_glacc_code,
               (acop_gl_head - products.product_glacc_code) Product_Accountbal,
               (m.acnts_glacc_code - products.product_glacc_code) Product_Mig_acnts
          from mig_acop_bal , products, mig_acnts m
         where acop_ac_num = m.acnts_acnum
           and products.product_code = acnts_prod_code)
 where Product_Accountbal <> 0
    or Product_Mig_acnts <> 0

select * from mig_acnts;

21.  
-- Checking GL Heads

select * from mig_acop_bal a
   where a.acop_gl_head not in (SELECT E.EXTGL_ACCESS_CODE FROM EXTGL E);

22.  

-- Checking GL Heads 

SELECT * FROM MIG_GLOP_BAL G 
   WHERE G.GLOP_GL_HEAD NOT IN (SELECT E.EXTGL_ACCESS_CODE FROM EXTGL E);

23.  

-- gl balance & gl account sum balance mismatch

--Whether the GL Access code provided in GL balances template is a valid code in GL Access Code master in Intellect ?

select glop_gl_head,glop_balance,acop_gl_head, samt , glop_balance - samt
from mig_glop_bal glop,
(select acop_gl_head,sum(acop_balance) samt from mig_acop_bal
group by acop_gl_head) acop
where glop.glop_gl_head = acop.acop_gl_head

24. 

--Junk account numbers query

select * from mig_acnts m
             where length(trim(translate(m.acnts_acnum,'0123456789',' ')))<>0;


select * from mig_lnacnt m
             where length(trim(translate(m.lnacnt_acnum,'0123456789',' ')))<>0;
       
select * from mig_pbdcontract m
             where length(trim(translate(m.migdep_dep_ac_num,'0123456789',' ')))<>0;
       
select * from mig_acop_bal m
             where length(trim(translate(m.acop_ac_num,'0123456789',' ')))<>0;
             
select * from mig_lnacrsdtl ml where 
length(trim(translate(ml.lnacrsdtl_acnum,'0123456789',' ')))<>0;



select distinct mig_err_code, mig_err_desc from mig_errorlog;


----clients not in mig_clients bt present in accounts

select *
  from mig_acnts
 where mig_acnts.acnts_client_num not in
       (select mig_clients.clients_code from mig_clients)


----acnts not in products

select *
  from acnts a
 where a.acnts_prod_code not in (select p.product_code from products p)
       
     
25. -- Depia Entry type checking entry types

select distinct t.depia_entry_type,t.depia_int_accr_db_cr from temp_depia t;

IA C
IP D

26. --  

select * from mig_acnts m where m.acnts_opening_date is null;

27. -- Checing Deposit entry for contract allowed records

SELECT ACNTS_ACNUM, ACNTS_PROD_CODE
  FROM MIG_ACNTS MA
 WHERE MA.ACNTS_PROD_CODE IN
       (SELECT PRODUCT_CODE
          FROM PRODUCTS
         WHERE PRODUCT_CONTRACT_ALLOWED = '1')
   AND ACNTS_ACNUM NOT IN
       (SELECT MIGDEP_DEP_AC_NUM FROM MIG_PBDCONTRACT MP);
       
       
       
       
-- QUERY TO CHECK THE CONTRACT ACCOUNTS for the Contract number

SELECT  * FROM MIG_PBDCONTRACT MP WHERE MP.MIGDEP_PROD_CODE  IN    (
 SELECT ACNTS_PROD_CODE FROM MIG_ACNTS  WHERE ACNTS_PROD_CODE IN     
 (
 SELECT PRODUCT_CODE
          FROM PRODUCTS
         WHERE PRODUCT_CONTRACT_ALLOWED = '1'
  )
  )
AND MIGDEP_CONT_NUM = 0;
  

28.  

select * from mig_acop_bal for update;

select drcr, sum(bal)
  from (SELECT GLOP_GL_HEAD,
               0,
               '0' ACOP_AC_NUM,
               ABS(GLOP_BALANCE) BAL,
               DECODE(SIGN(GLOP_BALANCE), 1, 'C', 'D') DRCR,
               0,
               0,
               0,
               0,
               null
          FROM mig_glop_bal
         WHERE GLOP_BAL_DATE =:P_MIG_DATE
           AND GLOP_BRANCH_CODE = :P_BRANCH_CODE
           AND GLOP_BALANCE <> 0
           and GLOP_GL_HEAD in
               (select extgl.extgl_access_code
                  from extgl
                 where extgl.extgl_gl_head in
                       (select glmast.gl_number
                          from glmast
                         where glmast.gl_cust_ac_allowed = 0))
        UNION
        SELECT ACOP_GL_HEAD,
               0,
               ACOP_AC_NUM,
               ABS(ACOP_BALANCE) BAL,
               DECODE(SIGN(ACOP_BALANCE), 1, 'C', 'D') DRCR,
               ACOP_CALC_INTEREST,
               ACOP_PRINCIPAL_OS,
               ACOP_INTEREST_OS,
               ACOP_CHGS_OS,
               ACOP_RECPT_NUM
          FROM mig_acop_bal
         WHERE ACOP_BAL_DATE =:P_MIG_DATE
           AND ACOP_BRANCH_CODE = :P_BRANCH_CODE
           and ACOP_BALANCE <> 0
         ORDER BY GLOP_GL_HEAD, ACOP_AC_NUM, DRCR, BAL)
 group by drcr;
 
29. -- GL marked as customer gl, there is no accounts present in mig_acop_bal.

select distinct 
m.glop_gl_head,e.extgl_ext_head_descn,e.extgl_access_code,e.extgl_gl_head,g.gl_cust_ac_allowed
from extgl e , glmast g,mig_glop_bal m where e.extgl_gl_head = g.gl_number and m.glop_gl_head = e.extgl_access_code
and m.glop_gl_head not in ( select mig_acop_bal.acop_gl_head from mig_acop_bal ) and g.gl_cust_ac_allowed <> 0

select * from mig_glop_bal b where b.glop_gl_head = 50201

EXTGL
PRODUCTS

30. -- Customer GL marked as non customer gl but having accounts & balance.

select distinct m.acop_gl_head,e.extgl_access_code,g.gl_cust_ac_allowed 
from extgl e , glmast g,mig_acop_bal m 
where e.extgl_gl_head = g.gl_number
and m.acop_gl_head = e.extgl_access_code
and g.gl_cust_ac_allowed <> 1;

31. 


select * from mig_lnacnt ml where ml.lnacnt_acnum 
 not in 
(
select mig_acnts.acnts_acnum from mig_acnts 
where mig_acnts.acnts_prod_code in 
(
select products.product_code from products
where 
products.product_for_loans = 1)
);

32.  

----vaultbal and denombal difference validation query if any

--denombal data check after


select sum(d.denombal_cur_good_stock),
       g.glsum_ac_db_sum,
       d.denombal_brn_code,
       sum(d.denombal_cur_good_stock) - g.glsum_ac_db_sum denomsumbal
  from denombal d, glsum2013 g
 where d.denombal_brn_code = g.glsum_branch_code
   and g.glsum_glacc_code = 201101101
 group by g.glsum_ac_db_sum,d.denombal_brn_code;


33.

----pbdcontract maturity date check 
         
       select t.migdep_eff_date,
       t.migdep_mat_date,
       add_months(t.migdep_eff_date, t.migdep_dep_prd_months),
       add_months(t.migdep_eff_date, t.migdep_dep_prd_months)- t.migdep_mat_date,
       t.*
  from mig_pbdcontract t


Begin
  for rec in (select t.pbdcont_eff_date,
                     t.pbdcont_mat_date,
                     t.pbdcont_dep_ac_num,
                     add_months(t.pbdcont_eff_date, t.pdbcont_dep_prd_months) matdate,
                     add_months(t.pbdcont_eff_date, t.pdbcont_dep_prd_months) -
                     t.pbdcont_mat_date
                from pbdcontract t) loop
  
    update pbdcontract p
       set p.pbdcont_mat_date = rec.matdate
     where p.pbdcont_dep_ac_num = rec.pbdcont_dep_ac_num;
  End loop;
End;

  /* 

if required
     


34.

--rdins date validation with pbdcontract
      
  select to_date(p.pbdcont_eff_date) - to_date(r.rdins_eff_date)
  from pbdcontract p, rdins r
 where p.pbdcont_dep_ac_num = r.rdins_rd_ac_num;

35.

----duplicate leaf cheque script

select count(m.cbiss_from_leaf_num),
       m.cbiss_from_leaf_num,
       m.cbiss_chqbk_prefix,
       m.cbiss_issue_date,
       m.cbiss_acnum
  from mig_cheque m
  group by m.cbiss_from_leaf_num,
          m.cbiss_chqbk_prefix,
          m.cbiss_issue_date,
          m.cbiss_acnum
having count(m.cbiss_from_leaf_num) > 1;



--------------------------------

SELECT c.cbiss_from_leaf_num,c.*
  FROM CBISS c
 where (c.cbiss_from_leaf_num, c.cbiss_chqbk_prefix, c.cbiss_issue_date,
        c.cbiss_client_acnum) IN
       (select m.cbiss_from_leaf_num,
               m.cbiss_chqbk_prefix,
               m.cbiss_issue_date,
               m.cbiss_client_acnum
          from cbiss m
         group by m.cbiss_from_leaf_num,
                  m.cbiss_chqbk_prefix,
                  m.cbiss_issue_date,
                  m.cbiss_client_acnum
        having count(m.cbiss_from_leaf_num) > 1)
 order by cbiss_client_acnum
   FOR UPDATE;

*/

DECLARE
V_MESSAGE VARCHAR2(3000);
BEGIN
SP_MIG_CLIENTS(40,V_MESSAGE);
DBMS_OUTPUT.PUT_LINE(V_MESSAGE);
END;

DECLARE
V_MESSAGE VARCHAR2(3000);
BEGIN
SP_MIG_acnts(40,V_MESSAGE);
DBMS_OUTPUT.PUT_LINE(V_MESSAGE);
END;

DECLARE
V_MESSAGE VARCHAR2(3000);
BEGIN
SP_MIG_CHEQUE(40,V_MESSAGE);
DBMS_OUTPUT.PUT_LINE(V_MESSAGE);
END;


DECLARE
V_MESSAGE VARCHAR2(3000);
BEGIN
SP_MIG_DDPO(40,V_MESSAGE);
DBMS_OUTPUT.PUT_LINE(V_MESSAGE);
END;


DECLARE
V_MESSAGE VARCHAR2(3000);
BEGIN
SP_MIG_DEPOSITS(40,V_MESSAGE);
DBMS_OUTPUT.PUT_LINE(V_MESSAGE);
END;

DECLARE
V_MESSAGE VARCHAR2(3000);
BEGIN
SP_MIG_LOANS(40,V_MESSAGE);
DBMS_OUTPUT.PUT_LINE(V_MESSAGE);
END;

DECLARE
V_MESSAGE VARCHAR2(3000);
BEGIN
SP_MIG_OPENBAL(40,'03-MAR-2014',V_MESSAGE);
DBMS_OUTPUT.PUT_LINE(V_MESSAGE);
END;

-- FOR ANY ERROR 
BEGIN
SP_MIG_TRANCLEAN;
END;



clients

CORPCLIENTS


mig_errorlog

posterrorlog

acnts


mig_acntlien

iaclink

