DROP PACKAGE SBLPROD.PKG_ACUPDCONFIG_REPORT;

CREATE OR REPLACE PACKAGE SBLPROD.PKG_ACUPDCONFIG_REPORT
IS
   TYPE TY_AC_VALUE IS RECORD
   (
      ACC_NO            VARCHAR2 (1000),
      BRN_CODE          NUMBER,
      PROD_CODE         NUMBER,
      AC_TYPE           VARCHAR2 (10),
      ACC_HOLDER_NAME   VARCHAR2 (1000),
      COLUMN_SL         NUMBER,
      COLUMN_NAME       VARCHAR2 (50),
      COLUMN_VAL        VARCHAR2 (10),
      KYC_STATUS        VARCHAR2 (10),
      ACC_STATUS        VARCHAR2 (20)
   );

   TYPE TY_AC_VALUE_DTL IS TABLE OF TY_AC_VALUE;

   FUNCTION AC_VALUE_DTL (P_ENTITYNUM     IN NUMBER,
                          P_BRANCH_CODE      NUMBER,
                          P_PROD_CODE        NUMBER,
                          P_ACTYPE           VARCHAR2,
                          P_RPT_CODE         VARCHAR2,
                          P_KYC_NONKYC_FLAG  VARCHAR2,
                          P_ACC_STATUS       VARCHAR2)
      --RETURN VARCHAR2 ;
      RETURN TY_AC_VALUE_DTL
      PIPELINED;
END PKG_ACUPDCONFIG_REPORT;
/
DROP PACKAGE BODY SBLPROD.PKG_ACUPDCONFIG_REPORT;

CREATE OR REPLACE PACKAGE BODY SBLPROD.PKG_ACUPDCONFIG_REPORT
IS
   TABLE1        PKG_ACUPDCONFIG_REPORT.TY_AC_VALUE;
   W_SQL         CLOB;
   W_ERROR_MSG   VARCHAR2 (1000);
   W_COL_NAME    VARCHAR2 (4000);


   TYPE R_AC_VALUE IS RECORD
   (
      TM_ACC_NO            VARCHAR2 (1000),
      TM_BRN_CODE          NUMBER,
      TM_PROD_CODE         NUMBER,
      TM_AC_TYPE           VARCHAR2 (10),
      TM_ACC_HOLDER_NAME   VARCHAR2 (1000),
      TM_COLUMN_SL         NUMBER,
      TM_COLUMN_NAME       VARCHAR2 (50),
      TM_COLUMN_VAL        VARCHAR2 (10),
      TM_KYC_STATUS        VARCHAR2 (10),
      TM_ACC_STATUS        VARCHAR2 (20)
   );

   TYPE R_TY_AC_VALUE_DTL IS TABLE OF R_AC_VALUE
      INDEX BY PLS_INTEGER;

   TM_AC_VALUE   R_TY_AC_VALUE_DTL;

   FUNCTION GET_COLUMN_ALIAS (P_COLUMN_NAME VARCHAR2, P_REPORT_CODE VARCHAR2)
      RETURN VARCHAR2
   IS
      V_COLUMN_ALIAS   VARCHAR2 (200);
   BEGIN
      SELECT CASE
                WHEN ACCCONFIG_LBL_TYPE = '01'
                THEN
                   'Present Address ' || ACCLABEL_DESC
                WHEN ACCCONFIG_LBL_TYPE = '02'
                THEN
                   'Permanent Address ' || ACCLABEL_DESC
                WHEN ACCCONFIG_LBL_TYPE = '03'
                THEN
                   'Communication Address ' || ACCLABEL_DESC
                WHEN ACCCONFIG_LBL_TYPE = 'NID'
                THEN
                   'National ID ' || ACCLABEL_DESC
                WHEN ACCCONFIG_LBL_TYPE = 'PP'
                THEN
                   'Passport ' || ACCLABEL_DESC
                WHEN ACCCONFIG_LBL_TYPE = 'BC'
                THEN
                   'Birth Certificate ' || ACCLABEL_DESC
                WHEN ACCCONFIG_LBL_TYPE = 'SC'
                THEN
                   'Smart Card ' || ACCLABEL_DESC
                WHEN ACCCONFIG_LBL_TYPE = '1'
                THEN
                   'Introducer ' || ACCLABEL_DESC
                WHEN ACCCONFIG_LBL_TYPE = '2'
                THEN
                   'Nominee ' || ACCLABEL_DESC
                WHEN ACCCONFIG_LBL_TYPE = '4'
                THEN
                   'Proprietor ' || ACCLABEL_DESC
                WHEN ACCCONFIG_LBL_TYPE = '8'
                THEN
                   'Authorised Signatory ' || ACCLABEL_DESC
                ELSE
                   ACCLABEL_DESC
             END
                ACCLABEL_DESC
        INTO V_COLUMN_ALIAS
        FROM ACCUPDATELABEL, ACCUPDATECONFIG, KYC_COLUMN_CONFIG
       WHERE     ACCLABEL_CODE = ACCCONFIG_LBL_CODE
             AND ACCCONFIG_RPT_CODE = P_REPORT_CODE
             AND COLUMN_ID_MAPPING = ACCCONFIG_LBL_TYPE || ACCFIELD_DESC
             AND COLUMN_NAME = P_COLUMN_NAME;

      RETURN V_COLUMN_ALIAS;
   END GET_COLUMN_ALIAS;

   FUNCTION AC_VALUE_DTL (P_ENTITYNUM     IN NUMBER,
                          P_BRANCH_CODE      NUMBER,
                          P_PROD_CODE        NUMBER,
                          P_ACTYPE           VARCHAR2,
                          P_RPT_CODE         VARCHAR2,
                          P_KYC_NONKYC_FLAG  VARCHAR2,
                          P_ACC_STATUS       VARCHAR2)
      --RETURN VARCHAR2 ;
      RETURN TY_AC_VALUE_DTL
      PIPELINED
   IS
   BEGIN
      --W_SQL := '';
      W_COL_NAME := '';

      FOR IDX
         IN (  SELECT COLUMN_NAME
                 FROM ACCUPDATELABEL, ACCUPDATECONFIG, KYC_COLUMN_CONFIG
                WHERE     ACCLABEL_CODE = ACCCONFIG_LBL_CODE
                      AND ACCCONFIG_RPT_CODE = '' || P_RPT_CODE || ''
                      AND COLUMN_ID_MAPPING =
                             ACCCONFIG_LBL_TYPE || ACCFIELD_DESC
             ORDER BY ACCCONFIG_SL)
      LOOP
         W_COL_NAME := W_COL_NAME || IDX.COLUMN_NAME || ',';
      END LOOP;

      W_SQL :=
            'SELECT  T.ACNTS_INTERNAL_ACNUM, T.ACNTS_BRN_CODE,
       T.ACNTS_PROD_CODE,
       T.ACNTS_AC_TYPE,
       T.ACNTS_AC_NAME, ACCCONFIG_SL  , T.COLUMN_NAME,
       T.VALUE_EXIST,
       T.KYC_STATUS,
       T.ACC_STATUS FROM (SELECT ACNTS_INTERNAL_ACNUM,
       ACNTS_BRN_CODE,
       ACNTS_PROD_CODE,
       ACNTS_AC_TYPE,
       ACNTS_AC_NAME,
       RANK () OVER (PARTITION BY ACNTS_INTERNAL_ACNUM ORDER BY COLUMN_NAME) COLUMN_SL,
       COLUMN_NAME,
       VALUE_EXIST,
       KYC_STATUS,
       ''' || NVL(P_ACC_STATUS, 'ALL') || ''' ACC_STATUS
        FROM (SELECT ACNTS_INTERNAL_ACNUM,
       ACNTS_BRN_CODE,
       ACNTS_PROD_CODE,
       ACNTS_AC_TYPE,
       ACNTS_AC_NAME,
       CASE
          WHEN (  ACCOUNT_NAME
                * INDCLIENT_BIRTH_DATE
                * INDCLIENT_FATHER_NAME
                * INDCLIENT_MOTHER_NAME
                * CASE WHEN ( 
CASE WHEN (  PER_ADDRDTLS_CURR_ADDR
                           * PER_ADDRDTLS_DISTRICT_CODE
                         * PER_ADDRDTLS_POSTOFFC_NAME
                         * PER_ADDRDTLS_STATE_CODE
                         * PER_ADDRDTLS_POSTAL_CODE) = 1
                     THEN
                        1
                     ELSE
                        0
                  END
                + CASE
                     WHEN (  CURR_ADDRDTLS_CURR_ADDR
                          * CURR_ADDRDTLS_DISTRICT_CODE
                         * CURR_ADDRDTLS_STATE_CODE
                         * CURR_ADDRDTLS_LOCN_CODE
                         *CURR_ADDRDTLS_POSTAL_CODE) = 1
                     THEN
                        1
                     ELSE
                        0
                  END ) >=1 THEN 1 ELSE 0 END
                * NOMINEE_CLIENT_NAME
                * (NID_PIDDOCS_DOCID_NUM+PP_PIDDOCS_DOCID_NUM+SC_PIDDOCS_DOCID_NUM+BC_PIDDOCS_DOCID_NUM)  >= 1)
          THEN
             ''KYC''
          ELSE
             ''NKYC''
        END
          KYC_STATUS, '
         || SUBSTR (W_COL_NAME, 0, LENGTH (W_COL_NAME) - 1)
         || '
          FROM KYC_DATA';



      IF P_BRANCH_CODE <> 0
      THEN
         W_SQL := W_SQL || ' WHERE ACNTS_BRN_CODE =' || P_BRANCH_CODE;
      END IF;

      IF P_PROD_CODE <> 0
      THEN
         W_SQL := W_SQL || ' AND ACNTS_PROD_CODE =' || P_PROD_CODE;
      END IF;

      IF P_ACTYPE IS NOT NULL
      THEN
         W_SQL :=
               W_SQL
            || ' AND ACNTS_AC_TYPE ='
            || CHR (39)
            || P_ACTYPE
            || CHR (39);
      END IF;

      IF P_ACC_STATUS = 'ACT' THEN 
        W_SQL := W_SQL || ' AND ACNTS_INOP_ACNT = 0 AND ACNTS_DORMANT_ACNT  = 0 ' ;
      ELSIF P_ACC_STATUS = 'DOR' THEN 
        W_SQL := W_SQL || ' AND ACNTS_DORMANT_ACNT = 1 AND ACNTS_INOP_ACNT = 0 ' ;
      ELSIF P_ACC_STATUS = 'INP' THEN 
        W_SQL := W_SQL || ' AND ACNTS_INOP_ACNT = 1 ';
      END IF ;
      
      W_SQL :=
            W_SQL
         || ' ) UNPIVOT (VALUE_EXIST  FOR COLUMN_NAME IN  ('
         || SUBSTR (W_COL_NAME, 0, LENGTH (W_COL_NAME) - 1)
         || ')) WHERE KYC_STATUS = ''' || P_KYC_NONKYC_FLAG || ''' ) T ,  ACCUPDATELABEL, ACCUPDATECONFIG, KYC_COLUMN_CONFIG
       WHERE     ACCLABEL_CODE = ACCCONFIG_LBL_CODE
             AND ACCCONFIG_RPT_CODE = ''' || P_RPT_CODE || ''' 
             AND COLUMN_ID_MAPPING = ACCCONFIG_LBL_TYPE || ACCFIELD_DESC
             AND T.COLUMN_NAME = KYC_COLUMN_CONFIG.COLUMN_NAME
             ORDER BY ACNTS_INTERNAL_ACNUM, ACCCONFIG_SL';

      DBMS_OUTPUT.put_line (W_SQL);

      EXECUTE IMMEDIATE W_SQL BULK COLLECT INTO TM_AC_VALUE;

      IF (TM_AC_VALUE.FIRST IS NOT NULL)
      THEN
         FOR IDX IN TM_AC_VALUE.FIRST .. TM_AC_VALUE.LAST
         LOOP
            TABLE1.ACC_NO := TM_AC_VALUE (IDX).TM_ACC_NO;
            TABLE1.BRN_CODE := TM_AC_VALUE (IDX).TM_BRN_CODE;
            TABLE1.PROD_CODE := TM_AC_VALUE (IDX).TM_PROD_CODE;
            TABLE1.AC_TYPE := TM_AC_VALUE (IDX).TM_AC_TYPE;
            TABLE1.ACC_HOLDER_NAME := TM_AC_VALUE (IDX).TM_ACC_HOLDER_NAME;
            TABLE1.COLUMN_SL := TM_AC_VALUE (IDX).TM_COLUMN_SL;
            TABLE1.COLUMN_NAME :=
               GET_COLUMN_ALIAS (TM_AC_VALUE (IDX).TM_COLUMN_NAME,
                                 P_RPT_CODE);
            TABLE1.COLUMN_VAL := TM_AC_VALUE (IDX).TM_COLUMN_VAL;
            TABLE1.KYC_STATUS := TM_AC_VALUE (IDX).TM_KYC_STATUS;
            TABLE1.ACC_STATUS := TM_AC_VALUE (IDX).TM_ACC_STATUS;
            PIPE ROW (TABLE1);
         END LOOP;
      END IF;

      TM_AC_VALUE.DELETE;
   --TY_AC_VALUE.DELETE;
   EXCEPTION
      WHEN OTHERS
      THEN
         W_ERROR_MSG := SUBSTR (SQLERRM, 1, 500);
   --LOG_ERROR('', W_ERROR_MSG);
   END;
END PKG_ACUPDCONFIG_REPORT;
/
