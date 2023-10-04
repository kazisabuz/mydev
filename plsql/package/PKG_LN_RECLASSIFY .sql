CREATE OR REPLACE PACKAGE PKG_LN_RECLASSIFY IS
  -- created by bibhu prasad on 08-04-2013

  PROCEDURE IDENTIFICATION_PROCESS(P_ENTITY_NUM IN NUMBER,
                                   P_ASON_DATE  IN DATE,
                                   P_BRN_CODE   NUMBER,
                                   P_PROD_CODE  NUMBER,
                                   P_ACNT_NUM   NUMBER,
                                   P_ERROR_MSG  OUT VARCHAR2);

  PROCEDURE POSTING_PROCESS(P_ENTITY_NUM IN NUMBER,
                            P_ASON_DATE  DATE,
                            P_BRN_CODE   NUMBER,
                            P_PROD_CODE  NUMBER,
                            P_ERROR_MSG  OUT VARCHAR2);
  PROCEDURE START_PROCESS(P_ENTITY_NUM IN NUMBER,
                                  P_BRN_CODE   IN NUMBER DEFAULT 0,
                                  P_ASON_DATE  IN DATE,
                                  P_TYPE       IN VARCHAR2,
                                  P_ERROR      OUT VARCHAR2);
  PROCEDURE START_BRNWISE(V_ENTITY_NUM   IN NUMBER,
                            P_BRN_CODE     IN NUMBER DEFAULT 0);
END PKG_LN_RECLASSIFY;
/

CREATE OR REPLACE PACKAGE BODY PKG_LN_RECLASSIFY
IS
   W_CBD                         DATE;
   W_ASON_DATE                   DATE;
   W_ACNTS_INTERNAL_ACNUM        NUMBER (14);
   W_ACNTS_CLIENT_NUM            NUMBER (12);
   W_ASSETCD_ASSET_CLASS         CHAR (1);
   W_CURR_ASSET_CODE             VARCHAR2 (2);
   W_NEW_ASSET_CLASS             CHAR (1);
   W_ERROR_MSG                   VARCHAR2 (2000);
   W_STD_ASSET                   CHAR (1);
   W_ACNTS_PROD_CODE             NUMBER (4);
   W_ACNTS_AC_TYPE               VARCHAR2 (5);
   W_PROD_TYPE                   CHAR (1);
   W_CMSME_CATEGORY              CHAR(1);
   W_PRODUCT_FOR_RUN_ACS         CHAR (1);
   W_SQL_PARAM                   VARCHAR2 (2000);
   W_DTL_PRESENT                 CHAR (1);
   V_ASON_DATE                   DATE;
   W_USER_ID                     VARCHAR2 (8);

   W_OVERDUE_PRD                 NUMBER (10, 2);
   W_NEW_ASSET_CODE              VARCHAR2 (2);
   W_ASSET_FOUND                 VARCHAR2 (1);
   W_MAX_OVERDUE_PRD             NUMBER (4);
   W_MAX_ASSET_CODE              VARCHAR2 (2);
   W_SQL                         VARCHAR2 (2000);
   W_ACNT_NUM                    NUMBER (14);
   W_BRN_CODE                    NUMBER (6);
   W_ACNTS_CURR_CODE             VARCHAR2 (3);
   W_ACNTS_OPENING_DATE          DATE;
   W_LIMIT_EXP_DATE              DATE;
   W_INSERT_INTO_PROCASSETRECL   CHAR (1);
   W_INCOME_REV                  CHAR (1);
   W_SUSP_REV                    CHAR (1);
   W_SUSP_REV_CHK                CHAR (1);
   W_SUSP_BAL                    NUMBER (18, 3);
   W_SUSP_PRIN_BAL               NUMBER (18, 3);
   W_SUSP_INT_BAL                NUMBER (18, 3);
   W_SUSP_CHGS_BAL               NUMBER (18, 3);
   W_EXT_NPA_DATE                DATE;
   W_NPA_DATE                    DATE;
   W_COUNT1                      NUMBER;
   ASON_DATE                     DATE;
   TRAN_IDX                      NUMBER (8) := 0;
   W_ERROR_CODE                  VARCHAR2 (10);
   W_ERROR                       VARCHAR2 (1000);
   W_BATCH_NUM                   NUMBER;
   W_MAX_SL                      NUMBER (5);
   -- Note: Newly Added
   V_GLOB_ENTITY_NUM             MAINCONT.MN_ENTITY_NUM%TYPE;
   V_REPHASEMENT_ENTRY           CHAR (1);
   V_PURPOSE_CODE                CHAR (1);
   V_REPHASE_ON_DATE             DATE;
   V_LNRSCLS_NO_OF_MON           NUMBER (5);
   V_LNRSCLS_EXP_DATE            CHAR (1);
   V_LNACRS_MONTHS_TO_BL         LNACRS.LNACRS_MONTHS_TO_BL%TYPE;
   V_TOT_DISB_AMOUNT             NUMBER (18, 3);
   V_REPH_ON_AMT                 NUMBER (18, 3);
   V_REPAY_SIZE                  NUMBER (18, 3);
   V_ASON_BC_BAL                 NUMBER (18, 3);
   V_PAID_AMOUNT                 NUMBER (18, 3);
   V_REPAY_FREQ                  CHAR (1);
   V_REPAY_FREQ_IN_MON           NUMBER (2);
   V_REPAY_START_DATE            DATE;
   W_TOT_INT_DB_MIG              NUMBER (18, 3);
   W_LAT_EFF_DATE                DATE;
   W_PROC_YEAR                   NUMBER;
   W_UPTO_YEAR                   NUMBER;
   I                             NUMBER;
   J                             NUMBER;
   W_INTRD_BC_AMT                NUMBER (18, 3);
   W_CHARGE_BC_AMT               NUMBER (18, 3);
   W_TOT_INT_DB                  NUMBER (18, 3);
   W_TOT_DISB_AMOUNT             NUMBER (18, 3);
   W_TOT_CHGS_DB                 NUMBER (18, 3);
   W_DB_CR_FLG                   CHAR (1);
   W_DATE_OF_TRAN                DATE;
   W_ACC_MIG_DATE                DATE;

   -- End

   W_OS_BAL                      NUMBER;
   W_SANC_LIMIT                  NUMBER;
   W_DP_AMT                      NUMBER;
   W_OD_AMT                      NUMBER;
   W_OD_DATE                     DATE;
   W_PRIN_OD_AMT                 NUMBER;
   W_PRIN_OD_DATE                DATE;
   W_INT_OD_AMT                  NUMBER DEFAULT 0;
   W_INT_OD_DATE                 DATE;
   W_CHGS_OD_AMT                 NUMBER DEFAULT 0;
   W_CHGS_OD_DATE                DATE;
   DUMMY                         NUMBER (18, 3);
   V_DUMMY                       NUMBER (18, 3);
   V_TRAN_CURR                   VARCHAR2 (3);
   V_INDEX_BY                    VARCHAR2 (3);
   V_TYPE                        VARCHAR2 (3);
   E_USEREXCEP                   EXCEPTION;
   V_NEW_ASSET_CODE              VARCHAR2 (2);
   
   --covid start    
  TYPE COVID_ASSET_TAB_TYPE IS TABLE OF NUMBER INDEX BY VARCHAR2(5);
  COVID_ASSET_TAB COVID_ASSET_TAB_TYPE;
--covid end

   TYPE TAB_CURR IS TABLE OF VARCHAR2 (3)
      INDEX BY VARCHAR2 (3);

   V_CURR                        TAB_CURR;

   TYPE TMP_ASSETRECL IS RECORD
   (
      TMP_PRD_TYPE   CHAR (1),
      TMP_PRD_CODE   NUMBER (4),
      TMP_SANC_AMT   NUMBER (18, 3),
      TMP_SUSP_REV   CHAR (1),
      TMP_CMSME_CATE CHAR(1)
   );

   TYPE TAB_ASSETRECL IS TABLE OF TMP_ASSETRECL
      INDEX BY PLS_INTEGER;

   V_ASSETRECL                   TAB_ASSETRECL;

   TYPE AC_PROD_REC IS RECORD
   (
      V_PRODUCT_FOR_RUN_ACS    CHAR,
      V_ACNTS_INTERNAL_ACNUM   NUMBER (14),
      V_ACNTS_CLIENT_NUM       NUMBER (12),
      V_ACNTS_PROD_CODE        NUMBER (4),
      V_ACNTS_AC_TYPE          VARCHAR2 (5),
      V_ACNTS_CURR_CODE        VARCHAR2 (3),
      V_ACNTS_OPENING_DATE     DATE,
      V_LIMIT_EXP_DATE         DATE,
      V_CMSME_CATEEGORY       CHAR(1) --CMSME
   );

   TYPE TAB_AC_PROD IS TABLE OF AC_PROD_REC
      INDEX BY PLS_INTEGER;

   TAB_AC_PROD_REC               TAB_AC_PROD;

   TYPE TYP_SUSP_DETAILS IS RECORD
   (
      TMP_ACNT_NUM        NUMBER (14),
      TMP_PROD_CODE       NUMBER (4),
      TMP_ACNT_CURR       VARCHAR2 (3),
      TMP_SUSP_BAL        NUMBER (18, 3),
      TMP_SUSP_PRIN_BAL   NUMBER (18, 3),
      TMP_SUSP_INT_BAL    NUMBER (18, 3),
      TMP_SUSP_CHG_BAL    NUMBER (18, 3)
   );

   TYPE TAB_SUSP_DETAILS IS TABLE OF TYP_SUSP_DETAILS
      INDEX BY PLS_INTEGER;

   V_SUSP_DETAILS                TAB_SUSP_DETAILS;

   TYPE TMP_PROCASSETRECL IS RECORD
   (
      TMP_PROC_DATE            DATE,
      TMP_BRN_CODE             NUMBER (6),
      TMP_PROD_CODE            NUMBER (4),
      TMP_ACNT_NUM             NUMBER (14),
      TMP_ACNT_CURR            VARCHAR2 (3),
      TMP_OS_BAL               NUMBER (18, 3),
      TMP_OD_AMT               NUMBER (18, 3),
      TMP_OD_DATE              DATE,
      TMP_INT_OD_AMT           NUMBER (18, 3),
      TMP_INT_OD_DATE          DATE,
      TMP_PRIN_OD_AMT          NUMBER (18, 3),
      TMP_PRIN_OD_DATE         DATE,
      TMP_CHGS_OD_AMT          NUMBER (18, 3),
      TMP_CHGS_OD_DATE         DATE,
      TMP_LIMIT_AMT            NUMBER (18, 3),
      TMP_DP_AMT               NUMBER (18, 3),
      TMP_NPA_DATE             DATE,
      TMP_STD_ASSET            CHAR (1),
      TMP_CURR_ASSET_CODE      VARCHAR2 (2),
      TMP_NEW_ASSET_CODE       VARCHAR2 (2),
      TMP_IGNORE_FROM_NPACLS   CHAR (1)
   );

   TYPE TAB_PROCASSETRECL IS TABLE OF TMP_PROCASSETRECL
      INDEX BY PLS_INTEGER;

   V_PROCASSETRECL               TAB_PROCASSETRECL;

   TYPE TMP_LNPRODACPM IS RECORD
   (
      TMP_PROD_CODE     NUMBER (4),
      TMP_ACNT_CURR     VARCHAR2 (3),
      TMP_INCOME_GL     VARCHAR2 (15),
      TMP_SUSPENSE_GL   VARCHAR2 (15)
   );

   TYPE TAB_LNPRODACPM IS TABLE OF TMP_LNPRODACPM
      INDEX BY VARCHAR2 (7);

   V_LNPRODACPM                  TAB_LNPRODACPM;

   -- Note: Newly Added For Avoiding Fraction...
   TYPE TY_TRAN_REC IS RECORD
   (
      V_INTRD_BC_AMT    NUMBER (18, 3),
      V_CHARGE_BC_AMT   NUMBER (18, 3),
      V_DB_CR_FLG       VARCHAR2 (1),
      V_DATE_OF_TRAN    DATE
   );

   TYPE TAB_TRAN_REC IS TABLE OF TY_TRAN_REC
      INDEX BY PLS_INTEGER;

   TRAN_REC                      TAB_TRAN_REC;

   PROCEDURE INSERT_INTO_PROCASSETRECL
   IS
   BEGIN
      INSERT INTO PROCASSETRECL
           VALUES (V_GLOB_ENTITY_NUM,
                   W_ASON_DATE,
                   W_ACNTS_INTERNAL_ACNUM,
                   W_ACNTS_CURR_CODE,
                   W_OS_BAL,
                   W_OD_AMT,
                   W_OD_DATE,
                   W_INT_OD_AMT,
                   W_INT_OD_DATE,
                   W_PRIN_OD_AMT,
                   W_PRIN_OD_DATE,
                   W_CHGS_OD_AMT,
                   W_CHGS_OD_DATE,
                   W_SANC_LIMIT,
                   W_DP_AMT,
                   W_NPA_DATE,
                   W_OD_DATE,
                   W_STD_ASSET,
                   W_CURR_ASSET_CODE,
                   W_NEW_ASSET_CODE,
                   '0',
                   W_INCOME_REV,
                   W_SUSP_REV,
                   ABS (W_SUSP_BAL),
                   ABS (W_SUSP_PRIN_BAL),
                   ABS (W_SUSP_INT_BAL),
                   ABS (W_SUSP_CHGS_BAL),
                   '',
                   NULL,
                   NULL);
   EXCEPTION
      WHEN OTHERS
      THEN
         W_ERROR_MSG :=
            'Error in INSERT_INTO_PROCASSETRECL ' || SUBSTR (SQLERRM, 1, 500);
         RAISE E_USEREXCEP;
   END INSERT_INTO_PROCASSETRECL;

   -- Note: (Newly Added For Report)

   PROCEDURE UPDATE_STDNPACLS
   IS
   BEGIN
      UPDATE STDNPACLS
         SET STDNPACLS_ENTITY_NUM = V_GLOB_ENTITY_NUM,
             STDNPACLS_OS_BAL = W_OS_BAL,
             STDNPACLS_OD_DATE = W_OD_DATE,
             STDNPACLS_OD_AMT = W_OD_AMT,
             STDNPACLS_INT_OD_AMT = W_INT_OD_AMT,
             STDNPACLS_INT_OD_DATE = W_INT_OD_DATE,
             STDNPACLS_PRIN_OD_AMT = W_PRIN_OD_AMT,
             STDNPACLS_PRIN_OD_DATE = W_PRIN_OD_DATE,
             STDNPACLS_CHGS_OD_AMT = W_CHGS_OD_AMT,
             STDNPACLS_CHGS_OD_DATE = W_CHGS_OD_DATE,
             STDNPACLS_LIMIT_AMT = W_SANC_LIMIT,
             STDNPACLS_DP_AMT = W_DP_AMT,
             STDNPACLS_NPA_DATE = W_NPA_DATE,
             STDNPACLS_CURR_ASSET_CODE = W_CURR_ASSET_CODE,
             STDNPACLS_NEW_ASSET_CODE = W_NEW_ASSET_CODE,
             STDNPACLS_IGNORE_FROM_NPACLS = '0',
             STDNPACLS_IGNORE_BY = NULL,
             STDNPACLS_IGNORE_ON = NULL,
             STDNPACLS_IGNORE_REMARKS1 = NULL,
             STDNPACLS_IGNORE_REMARKS2 = NULL,
             STDNPACLS_IGNORE_REMARKS3 = NULL
       WHERE     STDNPACLS_ENTITY_NUM = V_GLOB_ENTITY_NUM
             AND STDNPACLS_ACNT_NUM = W_ACNTS_INTERNAL_ACNUM
             AND STDNPACLS_PROC_DATE = W_ASON_DATE;
   EXCEPTION
      WHEN OTHERS
      THEN
         W_ERROR_MSG :=
            'Error in UPDATE_STDNPACLS ' || SUBSTR (SQLERRM, 1, 500);
         RAISE E_USEREXCEP;
   END UPDATE_STDNPACLS;

   PROCEDURE INSERT_INTO_STDNPACLS
   IS
      V_CNT   NUMBER;
   BEGIN
      V_CNT := 0;

      SELECT COUNT (*)
        INTO V_CNT
        FROM STDNPACLS A
       WHERE     STDNPACLS_ENTITY_NUM = V_GLOB_ENTITY_NUM
             AND STDNPACLS_ACNT_NUM = W_ACNTS_INTERNAL_ACNUM
             AND STDNPACLS_PROC_DATE = W_ASON_DATE;

      IF V_CNT > 0
      THEN
         UPDATE_STDNPACLS;
      ELSE
         INSERT INTO STDNPACLS
              VALUES (V_GLOB_ENTITY_NUM,
                      W_ASON_DATE,
                      W_ACNTS_INTERNAL_ACNUM,
                      W_ACNTS_CURR_CODE,
                      W_OS_BAL,
                      W_OD_AMT,
                      W_OD_DATE,
                      W_INT_OD_AMT,
                      W_INT_OD_DATE,
                      W_PRIN_OD_AMT,
                      W_PRIN_OD_DATE,
                      W_CHGS_OD_AMT,
                      W_CHGS_OD_DATE,
                      W_SANC_LIMIT,
                      W_DP_AMT,
                      0,                            --STDNPACLS_TOT_CR_AMT_PRD
                      0,                            --STDNPACLS_TOT_DB_AMT_PRD
                      0,                        --STDNPACLS_TOT_INT_DB_AMT_PRD
                      W_NPA_DATE,
                      W_CURR_ASSET_CODE,
                      W_NEW_ASSET_CODE,
                      '0',
                      W_BRN_CODE,
                      PKG_EODSOD_FLAGS.PV_USER_ID,
                      W_CBD,
                      '0',                     -- STDNPACLS_IGNORE_FROM_NPACLS
                      '',
                      '',
                      '',
                      '',
                      '',
                      '0',                            -- STDNPACLS_POSTED_FLAG
                      NULL,
                      NULL);
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         W_ERROR_MSG :=
            'Error in INSERT_INTO_STDNPACLS ' || SUBSTR (SQLERRM, 1, 500);
         RAISE E_USEREXCEP;
   END INSERT_INTO_STDNPACLS;

   PROCEDURE UPDATE_STDNPACLSDTL
   IS
   BEGIN
      UPDATE STDNPACLSDTL
         SET STDNPADTL_ENTITY_NUM = V_GLOB_ENTITY_NUM,
             STDNPADTL_OD_DATE = W_OD_DATE,
             STDNPADTL_OD_AMT = W_OD_AMT
       WHERE     STDNPADTL_ENTITY_NUM = V_GLOB_ENTITY_NUM
             AND STDNPADTL_ACNT_NUM = W_ACNTS_INTERNAL_ACNUM
             AND STDNPADTL_PROC_DATE = W_ASON_DATE;
   EXCEPTION
      WHEN OTHERS
      THEN
         W_ERROR_MSG :=
            'Error in UPDATE_STDNPACLSDTL ' || SUBSTR (SQLERRM, 1, 500);
         RAISE E_USEREXCEP;
   END UPDATE_STDNPACLSDTL;

   PROCEDURE INSERT_INTO_STDNPACLSDTL
   IS
      V_CNT   NUMBER;
   BEGIN
      V_CNT := 0;

      SELECT COUNT (*)
        INTO V_CNT
        FROM STDNPACLSDTL A
       WHERE     STDNPADTL_ENTITY_NUM = V_GLOB_ENTITY_NUM
             AND STDNPADTL_ACNT_NUM = W_ACNTS_INTERNAL_ACNUM
             AND STDNPADTL_PROC_DATE = W_ASON_DATE;

      IF V_CNT > 0
      THEN
         UPDATE_STDNPACLSDTL;
      ELSE
         INSERT INTO STDNPACLSDTL
              VALUES (V_GLOB_ENTITY_NUM,
                      W_ASON_DATE,
                      W_ACNTS_INTERNAL_ACNUM,
                      3,
                      W_OD_DATE,
                      W_OD_AMT,
                      NULL);
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         W_ERROR_MSG :=
            'Error in INSERT_INTO_STDNPACLSDTL ' || SUBSTR (SQLERRM, 1, 500);
         RAISE E_USEREXCEP;
   END INSERT_INTO_STDNPACLSDTL;

   -- Note: For Mapping With Report Purpose
   PROCEDURE FETCH_LLACNTOS (W_INTERNAL_ACNUM    IN     NUMBER,
                             V_TOT_DISB_AMOUNT      OUT NUMBER)
   AS
      W_CLIENT_NUM       NUMBER (12) := 0;
      W_LIMIT_LINE_NUM   NUMBER (6) := 0;
   BEGIN
     <<FETCH_ACASLLDTL>>
      BEGIN
         SELECT ACASLLDTL_CLIENT_NUM, ACASLLDTL_LIMIT_LINE_NUM
           INTO W_CLIENT_NUM, W_LIMIT_LINE_NUM
           FROM ACASLLDTL
          WHERE     ACASLLDTL_ENTITY_NUM = V_GLOB_ENTITY_NUM
                AND ACASLLDTL_INTERNAL_ACNUM = W_INTERNAL_ACNUM;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            W_CLIENT_NUM := 0;
            W_LIMIT_LINE_NUM := 0;
      END FETCH_ACASLLDTL;

     <<FETCH_REPAY_SCHEDULE>>
      BEGIN
         SELECT LNACRS_REPH_ON_AMT,
                NVL (LNACRS_PURPOSE, 'X'),
                NVL (LNACRS_REPHASEMENT_ENTRY, '0'),
                LNACRS_LATEST_EFF_DATE,
                NVL (LNACRSDTL_REPAY_AMT, 1),
                LNACRSDTL_REPAY_FREQ,
                LNACRSDTL_REPAY_FROM_DATE,
                LNACRS_LATEST_EFF_DATE,
                NVL (LNACRS_MONTHS_TO_BL, 0)
           INTO V_REPH_ON_AMT,
                V_PURPOSE_CODE,
                V_REPHASEMENT_ENTRY,
                W_LAT_EFF_DATE,
                V_REPAY_SIZE,
                V_REPAY_FREQ,
                V_REPAY_START_DATE,
                V_REPHASE_ON_DATE,
                V_LNACRS_MONTHS_TO_BL
           FROM LNACRSDTL, LNACRS
          WHERE     LNACRSDTL_ENTITY_NUM = V_GLOB_ENTITY_NUM
                AND LNACRSDTL.LNACRSDTL_ENTITY_NUM = V_GLOB_ENTITY_NUM
                AND LNACRSDTL.LNACRSDTL_INTERNAL_ACNUM =
                       LNACRS.LNACRS_INTERNAL_ACNUM
                AND LNACRSDTL_INTERNAL_ACNUM = W_INTERNAL_ACNUM;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            V_REPH_ON_AMT := 0;
            V_REPHASEMENT_ENTRY := '0';
            V_PURPOSE_CODE := '';
            V_REPH_ON_AMT := 0;
            V_REPAY_FREQ := '';
            V_REPAY_SIZE := 1;
            V_REPAY_START_DATE := NULL;
            V_REPHASE_ON_DATE := NULL;
      END FETCH_REPAY_SCHEDULE;

      IF (   V_REPHASEMENT_ENTRY = 0
          OR (V_REPHASEMENT_ENTRY = 1 AND V_PURPOSE_CODE <> 'R'))
      THEN
         SELECT LLACNTOS_LIMIT_CURR_DISB_MADE
           INTO V_TOT_DISB_AMOUNT
           FROM LLACNTOS
          WHERE     LLACNTOS_ENTITY_NUM = V_GLOB_ENTITY_NUM
                AND LLACNTOS_CLIENT_CODE = W_CLIENT_NUM
                AND LLACNTOS_LIMIT_LINE_NUM = W_LIMIT_LINE_NUM
                AND LLACNTOS_CLIENT_ACNUM = W_INTERNAL_ACNUM;
      ELSE
         V_TOT_DISB_AMOUNT := V_REPH_ON_AMT;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         V_TOT_DISB_AMOUNT := 0;
   END FETCH_LLACNTOS;

   PROCEDURE GET_TOT_INT_DB_MIG
   IS
   BEGIN
     <<READLNTOTINTDBMIG>>
      BEGIN
         IF (   V_REPHASEMENT_ENTRY = 0
             OR (V_REPHASEMENT_ENTRY = 1 AND V_PURPOSE_CODE <> 'R')
             OR (    V_REPHASEMENT_ENTRY = 1
                 AND V_PURPOSE_CODE = 'R'
                 AND V_REPHASE_ON_DATE <= W_ACC_MIG_DATE))
         THEN
            SELECT ABS (NVL (L.LNTOTINTDB_TOT_INT_DB_AMT, 0))
              INTO W_TOT_INT_DB_MIG
              FROM LNTOTINTDBMIG L
             WHERE     L.LNTOTINTDB_ENTITY_NUM = V_GLOB_ENTITY_NUM
                   AND L.LNTOTINTDB_INTERNAL_ACNUM = W_ACNTS_INTERNAL_ACNUM;
         ELSE
            W_TOT_INT_DB_MIG := 0;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            W_TOT_INT_DB_MIG := 0;
      END READLNTOTINTDBMIG;
   END GET_TOT_INT_DB_MIG;

   PROCEDURE TRANADV_PROC
   IS
      V_WP   VARCHAR2 (5);
   BEGIN
      W_SQL :=
         'SELECT TRANADV_INTRD_BC_AMT, TRANADV_CHARGE_BC_AMT,TRAN_DB_CR_FLG,TRAN_DATE_OF_TRAN FROM MV_LOAN_ACCOUNT_BAL_OD
        WHERE VALUE_YEAR=:1 AND TRAN_INTERNAL_ACNUM=:2 AND TRAN_DB_CR_FLG = :3 AND TRAN_DATE_OF_TRAN <= :4';

      IF (V_REPHASEMENT_ENTRY = 1 AND V_PURPOSE_CODE = 'R')
      THEN
         W_SQL :=
               W_SQL
            || ' AND TRAN_DATE_OF_TRAN >= '
            || CHR (39)
            || W_LAT_EFF_DATE
            || CHR (39);
      END IF;

      EXECUTE IMMEDIATE W_SQL
         BULK COLLECT INTO TRAN_REC
         USING W_PROC_YEAR,
               W_ACNTS_INTERNAL_ACNUM,
               'D',
               W_ASON_DATE;

      J := 0;

      IF TRAN_REC.FIRST IS NOT NULL
      THEN
         FOR J IN TRAN_REC.FIRST .. TRAN_REC.LAST
         LOOP
            W_INTRD_BC_AMT := TRAN_REC (J).V_INTRD_BC_AMT;
            W_CHARGE_BC_AMT := TRAN_REC (J).V_CHARGE_BC_AMT;
            W_DB_CR_FLG := TRAN_REC (J).V_DB_CR_FLG;
            W_DATE_OF_TRAN := TRAN_REC (J).V_DATE_OF_TRAN;

            IF W_ACC_MIG_DATE = W_DATE_OF_TRAN
            THEN
               W_INTRD_BC_AMT := 0;
               W_CHARGE_BC_AMT := 0;
            END IF;

            W_TOT_INT_DB := W_TOT_INT_DB + W_INTRD_BC_AMT;
            W_TOT_CHGS_DB := W_TOT_CHGS_DB + W_CHARGE_BC_AMT;
         END LOOP;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         W_ERROR := '';
   END TRANADV_PROC;

   -- End . For Mapping Purpose
   
   PROCEDURE GET_SUSPBAL
   IS
   BEGIN
      IF W_ASON_DATE = W_CBD
      THEN
        <<BEGIN_LNSUSPBAL>>
         BEGIN
            SELECT LNSUSPBAL_SUSP_BAL,
                   LNSUSPBAL_PRIN_BAL,
                   LNSUSPBAL_INT_BAL,
                   LNSUSPBAL_CHG_BAL
              INTO W_SUSP_BAL,
                   W_SUSP_PRIN_BAL,
                   W_SUSP_INT_BAL,
                   W_SUSP_CHGS_BAL
              FROM LNSUSPBAL
             WHERE     LNSUSPBAL_ENTITY_NUM = V_GLOB_ENTITY_NUM
                   AND LNSUSPBAL_ACNT_NUM = W_ACNTS_INTERNAL_ACNUM
                   AND LNSUSPBAL_CURR_CODE = W_ACNTS_CURR_CODE;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               W_SUSP_BAL := 0;
               W_SUSP_PRIN_BAL := 0;
               W_SUSP_INT_BAL := 0;
               W_SUSP_CHGS_BAL := 0;
         END BEGIN_LNSUSPBAL;
      ELSE
         PKG_LNSUSPASON.SP_LNSUSPASON (V_GLOB_ENTITY_NUM,
                                       W_ACNTS_INTERNAL_ACNUM,
                                       W_ACNTS_CURR_CODE,
                                       TO_CHAR (W_ASON_DATE, 'DD-MM-YYYY'),
                                       W_ERROR_MSG,
                                       W_SUSP_INT_BAL,
                                       W_SUSP_CHGS_BAL,
                                       W_SUSP_BAL,
                                       V_DUMMY,
                                       V_DUMMY,
                                       V_DUMMY,
                                       V_DUMMY,
                                       V_DUMMY,
                                       V_DUMMY,
                                       V_DUMMY,
                                       V_DUMMY);

         IF (W_ERROR_MSG IS NOT NULL)
         THEN
            RAISE E_USEREXCEP;
         END IF;
      END IF;

      IF W_SUSP_BAL > 0
      THEN
         W_SUSP_BAL := 0;
         W_SUSP_PRIN_BAL := 0;
         W_SUSP_INT_BAL := 0;
         W_SUSP_CHGS_BAL := 0;
      END IF;
   END GET_SUSPBAL;
   
             --covid start
   PROCEDURE GET_COVID_ASSET_CODE (P_NEW_ASSET_CODE VARCHAR2, P_CURR_ASSET_CODE VARCHAR2)
   IS
   BEGIN
       COVID_ASSET_TAB('UC') := 1;
       COVID_ASSET_TAB('SM') := 2;
       COVID_ASSET_TAB('SS') := 3;
       COVID_ASSET_TAB('DF') := 4;
       COVID_ASSET_TAB('BL') := 5;
     IF P_CURR_ASSET_CODE='ST' THEN
       W_NEW_ASSET_CODE :='ST';
     ELSE
       IF(COVID_ASSET_TAB(P_NEW_ASSET_CODE)>COVID_ASSET_TAB(P_CURR_ASSET_CODE)) THEN
       W_NEW_ASSET_CODE:= W_CURR_ASSET_CODE;
       END IF;
 END IF;
 EXCEPTION
      WHEN OTHERS
      THEN
         W_ERROR_MSG :=
            'Error in GET_COVID_ASSET_CODE for account-' || FACNO (V_GLOB_ENTITY_NUM, W_ACNTS_INTERNAL_ACNUM) ;
         RAISE E_USEREXCEP;
  END;
   --covid end

   PROCEDURE GET_ASSET_CLASS (P_ASSET_CODE VARCHAR2, P_ASSET_CLASS OUT CHAR)
   IS
      V_ASSET_CLASS   CHAR (1);
   BEGIN
      SELECT ASSETCD_ASSET_CLASS
        INTO V_ASSET_CLASS
        FROM ASSETCD
       WHERE ASSETCD_CODE = P_ASSET_CODE;

      P_ASSET_CLASS := V_ASSET_CLASS;
   EXCEPTION
      WHEN OTHERS
      THEN
         W_ERROR_MSG :=
            'Error in GET_ASSET_CLASS for Asset Code' || P_ASSET_CODE;
         RAISE E_USEREXCEP;
   END;

   PROCEDURE CHECK_ASSET_STAT
   IS
   BEGIN
      SELECT ASSETCD_ASSET_CLASS, ASSETCLS_ASSET_CODE, ASSETCLS_NPA_DATE
        INTO W_ASSETCD_ASSET_CLASS, W_CURR_ASSET_CODE, W_EXT_NPA_DATE
        FROM ASSETCLS, ASSETCD
       WHERE     ASSETCLS_ENTITY_NUM = V_GLOB_ENTITY_NUM
             AND ASSETCD_CODE = ASSETCLS_ASSET_CODE
             AND ASSETCLS_INTERNAL_ACNUM = W_ACNTS_INTERNAL_ACNUM;

      W_STD_ASSET := '0';
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         W_STD_ASSET := '1';
   END CHECK_ASSET_STAT;

   PROCEDURE FETCH_OVERDUE
   IS
      W_OD_DATE1        VARCHAR2 (15);
      W_PRIN_OD_DATE1   VARCHAR2 (15);
      W_INT_OD_DATE1    VARCHAR2 (15);
      W_CHGS_OD_DATE1   VARCHAR2 (15);
   BEGIN
      PKG_LNOVERDUE.SP_LNOVERDUE (V_GLOB_ENTITY_NUM,
                                  W_ACNTS_INTERNAL_ACNUM,
                                  TO_CHAR (W_ASON_DATE, 'DD-MM-YYYY'),
                                  TO_CHAR (W_CBD, 'DD-MM-YYYY'),
                                  W_ERROR_MSG,
                                  W_OS_BAL,
                                  W_SANC_LIMIT,
                                  W_DP_AMT,
                                  DUMMY,
                                  W_OD_AMT,
                                  W_OD_DATE1,
                                  W_PRIN_OD_AMT,
                                  W_PRIN_OD_DATE1,
                                  W_INT_OD_AMT,
                                  W_INT_OD_DATE1,
                                  W_CHGS_OD_AMT,
                                  W_CHGS_OD_DATE1);

      IF (W_ERROR_MSG IS NOT NULL)
      THEN
         RAISE E_USEREXCEP;
      END IF;

      W_OD_DATE := TO_DATE (W_OD_DATE1, 'dd-MM-yyyy');
      W_PRIN_OD_DATE := TO_DATE (W_PRIN_OD_DATE1, 'dd-MM-yyyy');
      W_INT_OD_DATE := TO_DATE (W_INT_OD_DATE1, 'dd-MM-yyyy');
      W_CHGS_OD_DATE := TO_DATE (W_CHGS_OD_DATE1, 'dd-MM-yyyy');
   END FETCH_OVERDUE;

   PROCEDURE GET_OVERDUE_DTLS
   IS
   BEGIN
      SELECT LNODHIST_OS_BAL,
             LNODHIST_SANC_LIMIT_AMT,
             LNODHIST_DP_AMT,
             LNODHIST_OD_AMT,
             LNODHIST_OD_DATE,
             LNODHIST_PRIN_OD_AMT,
             LNODHIST_PRIN_OD_DATE,
             LNODHIST_INT_OD_AMT,
             LNODHIST_INT_OD_DATE,
             LNODHIST_CHGS_OD_AMT,
             LNODHIST_CHGS_OD_DATE
        INTO W_OS_BAL,
             W_SANC_LIMIT,
             W_DP_AMT,
             W_OD_AMT,
             W_OD_DATE,
             W_PRIN_OD_AMT,
             W_PRIN_OD_DATE,
             W_INT_OD_AMT,
             W_INT_OD_DATE,
             W_CHGS_OD_AMT,
             W_CHGS_OD_DATE
        FROM LNODHIST
       WHERE     LNODHIST_ENTITY_NUM = V_GLOB_ENTITY_NUM
             AND LNODHIST_INTERNAL_ACNUM = W_ACNTS_INTERNAL_ACNUM
             AND LNODHIST_EFF_DATE = W_ASON_DATE;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         --FETCH_OVERDUE;
         DBMS_OUTPUT.PUT_LINE ('');
   END GET_OVERDUE_DTLS;

   PROCEDURE GET_ASSETRECL_PARAM
   IS
   BEGIN
     <<GET_PARAM1>>
      BEGIN
         W_DTL_PRESENT := '0';
         W_ASSET_FOUND := '0';
         W_MAX_OVERDUE_PRD := 0;
         W_MAX_ASSET_CODE := '';

         W_SQL_PARAM :=
               'SELECT ASSETRECL_PRD_TYPE,
                      ASSETRECL_PRD_CODE,
                     ASSETRECL_SANC_AMT,
                     ASSETRECL_SUSP_REVCHK,
                     ASSETRECL_CMSME_CAT
                    FROM ASSETRECL
                   WHERE ASSETRECL_EFF_DATE =
                 (SELECT MAX(ASSETRECL_EFF_DATE) FROM ASSETRECL
                  WHERE ASSETRECL_PRD_TYPE = '
            || CHR (39)
            || W_PROD_TYPE
            || CHR (39)
            || '
                  AND ASSETRECL_PRD_CODE = '
            || W_ACNTS_PROD_CODE
            || '
                   AND ASSETRECL_CMSME_CAT = '
            || CHR(39)
            || W_CMSME_CATEGORY
            || CHR(39)  
            ||')
                  AND ASSETRECL_PRD_TYPE = '
            || CHR (39)
            || W_PROD_TYPE
            || CHR (39)
            || '
                  AND ASSETRECL_PRD_CODE = '
            || CHR (39)
            || W_ACNTS_PROD_CODE
            || CHR (39)
            || '
                AND ASSETRECL_CMSME_CAT = '
            || CHR(39)    
            || W_CMSME_CATEGORY
            || CHR(39) 
            ||'
                  ORDER BY ASSETRECL_SANC_AMT ASC';

         EXECUTE IMMEDIATE W_SQL_PARAM BULK COLLECT INTO V_ASSETRECL;
      EXCEPTION
         WHEN OTHERS
         THEN
            W_ERROR_MSG :=
                  'Error in GET_ASSETRECL_PARAM for product '
               || W_ACNTS_PROD_CODE;
            RAISE E_USEREXCEP;
      END GET_PARAM1;

      IF V_ASSETRECL.COUNT = 0
      THEN
        <<GET_PARAM2>>
         BEGIN
            W_SQL_PARAM :=
                  'SELECT ASSETRECL_PRD_TYPE,
                     ASSETRECL_PRD_CODE,
                     ASSETRECL_SANC_AMT,
                     ASSETRECL_SUSP_REVCHK,
                     ASSETRECL_CMSME_CAT
                     FROM ASSETRECL
                     WHERE ASSETRECL_EFF_DATE =
                    (SELECT MAX(ASSETRECL_EFF_DATE) FROM ASSETRECL
                    WHERE ASSETRECL_PRD_TYPE = '
               || CHR (39)
               || W_PROD_TYPE
               || CHR (39)
               || '
                  AND ASSETRECL_CMSME_CAT = '
               || CHR(39)
               || W_CMSME_CATEGORY
               || CHR(39)
               || '
                    AND ASSETRECL_PRD_CODE = 0) AND ASSETRECL_PRD_TYPE = '
               || CHR (39)
               || W_PROD_TYPE
               || CHR (39)
               || '
                 AND ASSETRECL_CMSME_CAT = '
               || CHR(39)
               || W_CMSME_CATEGORY
               || CHR(39)
               || '
                    AND ASSETRECL_PRD_CODE = 0
                    ORDER BY ASSETRECL_SANC_AMT ASC';

            EXECUTE IMMEDIATE W_SQL_PARAM BULK COLLECT INTO V_ASSETRECL;

            IF V_ASSETRECL.COUNT = 0
            THEN
               W_ERROR_MSG :=
                     'Reclassification Parameters Not Defined for product '
                  || W_ACNTS_PROD_CODE;
               RAISE E_USEREXCEP;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               W_ERROR_MSG :=
                  'GET_ASSETRECL_PARAM ' || '-' || SUBSTR (SQLERRM, 1, 500);
               RAISE E_USEREXCEP;
         END GET_PARAM2;
      END IF;

      FOR INX IN 1 .. V_ASSETRECL.COUNT
      LOOP
         IF     W_SANC_LIMIT <= V_ASSETRECL (INX).TMP_SANC_AMT
            AND W_ASSET_FOUND = '0'
         THEN
            W_DTL_PRESENT := '1';
            W_SUSP_REV_CHK := V_ASSETRECL (INX).TMP_SUSP_REV;

            FOR IPX
               IN (SELECT ASSETRECLD_OVERDUE_PRD, ASSETRECLD_ASSET_CODE
                     FROM ASSETRECLDTL
                    WHERE     ASSETRECLD_PRD_TYPE =
                                 V_ASSETRECL (INX).TMP_PRD_TYPE
                          AND ASSETRECLD_PRD_CODE =
                                 V_ASSETRECL (INX).TMP_PRD_CODE
                          AND ASSETRECLD_SANC_AMT =
                                 V_ASSETRECL (INX).TMP_SANC_AMT
                          AND ASSETRECLD_CMSME_CAT = 
                                 V_ASSETRECL (INX).TMP_CMSME_CATE 
                            ORDER BY ASSETRECLD_OVERDUE_PRD ASC
                                 )
            LOOP
               IF W_OVERDUE_PRD <= IPX.ASSETRECLD_OVERDUE_PRD
               THEN
                  W_NEW_ASSET_CODE := IPX.ASSETRECLD_ASSET_CODE;
                  W_ASSET_FOUND := '1';
                  EXIT;
               ELSE
                  W_ASSET_FOUND := '0';
               END IF;
            END LOOP;
            
            IF W_ASSET_FOUND = '0'
            THEN
               SELECT ASSETRECLD_OVERDUE_PRD, ASSETRECLD_ASSET_CODE
                 INTO W_MAX_OVERDUE_PRD, W_MAX_ASSET_CODE
                 FROM ASSETRECLDTL
                WHERE     ASSETRECLD_PRD_TYPE =
                             V_ASSETRECL (INX).TMP_PRD_TYPE
                      AND ASSETRECLD_PRD_CODE =
                             V_ASSETRECL (INX).TMP_PRD_CODE
                      AND ASSETRECLD_SANC_AMT =
                             V_ASSETRECL (INX).TMP_SANC_AMT
                      AND ASSETRECLD_CMSME_CAT =      
                             V_ASSETRECL (INX).TMP_CMSME_CATE      
                      AND ASSETRECLD_OVERDUE_PRD =
                             (SELECT MAX (ASSETRECLD_OVERDUE_PRD)
                                FROM ASSETRECLDTL
                               WHERE     ASSETRECLD_PRD_TYPE =
                                            V_ASSETRECL (INX).TMP_PRD_TYPE
                                     AND ASSETRECLD_PRD_CODE =
                                            V_ASSETRECL (INX).TMP_PRD_CODE
                                     AND ASSETRECLD_CMSME_CAT =      
                                             V_ASSETRECL (INX).TMP_CMSME_CATE
                                     AND ASSETRECLD_SANC_AMT =
                                            V_ASSETRECL (INX).TMP_SANC_AMT);

               IF W_OVERDUE_PRD > W_MAX_OVERDUE_PRD
               THEN
                  W_NEW_ASSET_CODE := W_MAX_ASSET_CODE;
               END IF;
            END IF;
         ELSIF W_ASSET_FOUND = '0'
         THEN
            W_DTL_PRESENT := '0';
         END IF;
      END LOOP;

      IF W_DTL_PRESENT = '0'
      THEN
         W_ERROR_MSG :=
               'Reclassification Parameters Not Defined for Product '
            || W_ACNTS_PROD_CODE
            || ' and Sanction Amount '
            || W_SANC_LIMIT;
         RAISE E_USEREXCEP;
      END IF;
   END GET_ASSETRECL_PARAM;

   PROCEDURE INIT_PARA
   IS
   BEGIN
      W_ERROR_MSG := '';
      W_SQL := '';
      W_SQL_PARAM := '';
      W_PRODUCT_FOR_RUN_ACS := '0';
      W_ACNTS_INTERNAL_ACNUM := 0;
      W_ACNTS_CLIENT_NUM := 0;
      W_CURR_ASSET_CODE := '';
      W_NEW_ASSET_CODE := '';
      W_NEW_ASSET_CLASS := '';
      W_STD_ASSET := '';
      W_ACNTS_PROD_CODE := 0;
      W_ACNTS_AC_TYPE := '';
      W_PROD_TYPE := '';
      W_CMSME_CATEGORY:= '';
      W_ACNTS_CURR_CODE := '';
      W_INSERT_INTO_PROCASSETRECL := '0';
      W_INCOME_REV := '0';
      W_SUSP_REV := '0';
      W_SUSP_BAL := 0;
      W_SUSP_PRIN_BAL := 0;
      W_SUSP_INT_BAL := 0;
      W_SUSP_CHGS_BAL := 0;
      W_ACNTS_OPENING_DATE := NULL;
      W_LIMIT_EXP_DATE := NULL;
      W_NPA_DATE := NULL;
      W_SUSP_REV_CHK := '0';
      W_MAX_SL := 0;
      W_OS_BAL := 0;
      W_SANC_LIMIT := 0;
      W_DP_AMT := 0;
      W_OD_AMT := 0;
      W_OD_DATE := NULL;
      W_PRIN_OD_AMT := 0;
      W_PRIN_OD_DATE := NULL;
      W_INT_OD_AMT := 0;
      W_INT_OD_DATE := NULL;
      W_CHGS_OD_AMT := 0;
      W_CHGS_OD_DATE := NULL;
      W_OVERDUE_PRD := 0;
      W_EXT_NPA_DATE := NULL;
      V_REPHASEMENT_ENTRY := 0;
      V_REPH_ON_AMT := 0;
      V_PURPOSE_CODE := '';
      V_REPHASE_ON_DATE := NULL;
   END INIT_PARA;

   PROCEDURE UPDATE_ASSETCLS (ADX NUMBER)
   IS
   BEGIN
      UPDATE ASSETCLS
         SET ASSETCLS_LATEST_EFF_DATE = V_PROCASSETRECL (ADX).TMP_PROC_DATE,
             ASSETCLS_ASSET_CODE = V_NEW_ASSET_CODE,
             ASSETCLS_NPA_DATE = V_PROCASSETRECL (ADX).TMP_NPA_DATE,
             ASSETCLS_AUTO_MAN_FLG = 'A',
             ASSETCLS_REMARKS = 'Auto Reclassification',
             ASSETCLS.ASSETCLS_EXEMPT_END_DATE = NULL
       WHERE     ASSETCLS_ENTITY_NUM = V_GLOB_ENTITY_NUM
             AND ASSETCLS_INTERNAL_ACNUM = V_PROCASSETRECL (ADX).TMP_ACNT_NUM;
   EXCEPTION
      WHEN OTHERS
      THEN
         W_ERROR_MSG :=
               'Error in UPDATE_ASSETCLS for '
            || FACNO (V_GLOB_ENTITY_NUM, V_PROCASSETRECL (ADX).TMP_ACNT_NUM)
            || '-'
            || SUBSTR (SQLERRM, 1, 500);
         RAISE E_USEREXCEP;
   END UPDATE_ASSETCLS;

   PROCEDURE INSERT_INTO_ASSETCLS (ADX NUMBER)
   IS
      V_CNT   NUMBER;
   BEGIN
      V_CNT := 0;

      SELECT COUNT (*)
        INTO V_CNT
        FROM ASSETCLS A
       WHERE     ASSETCLS_ENTITY_NUM = V_GLOB_ENTITY_NUM
             AND ASSETCLS_INTERNAL_ACNUM = V_PROCASSETRECL (ADX).TMP_ACNT_NUM;

      IF V_CNT > 0
      THEN
         UPDATE_ASSETCLS (ADX);
      ELSE
         INSERT INTO ASSETCLS
              VALUES (V_GLOB_ENTITY_NUM,
                      V_PROCASSETRECL (ADX).TMP_ACNT_NUM,
                      V_PROCASSETRECL (ADX).TMP_PROC_DATE,
                      V_NEW_ASSET_CODE,
                      V_PROCASSETRECL (ADX).TMP_NPA_DATE,
                      'A',
                      'Auto Reclassification',
                      NULL);
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         W_ERROR_MSG :=
               'Error in INSERT_INTO_ASSETCLS for '
            || FACNO (V_GLOB_ENTITY_NUM, V_PROCASSETRECL (ADX).TMP_ACNT_NUM)
            || '-'
            || SUBSTR (SQLERRM, 1, 500);
         RAISE E_USEREXCEP;
   END INSERT_INTO_ASSETCLS;

   PROCEDURE INSERT_INTO_ASSETCLSH (ADX NUMBER)
   IS
      V_CNT   NUMBER;
   BEGIN
      V_CNT := 0;

      SELECT COUNT (*)
        INTO V_CNT
        FROM ASSETCLSHIST A
       WHERE     A.ASSETCLSH_ENTITY_NUM = V_GLOB_ENTITY_NUM
             AND A.ASSETCLSH_INTERNAL_ACNUM =
                    V_PROCASSETRECL (ADX).TMP_ACNT_NUM
             AND A.ASSETCLSH_EFF_DATE = V_PROCASSETRECL (ADX).TMP_PROC_DATE;

      IF V_CNT > 0
      THEN
         UPDATE ASSETCLSHIST A
            SET A.ASSETCLSH_ASSET_CODE = V_NEW_ASSET_CODE,
                A.ASSETCLSH_NPA_DATE = V_PROCASSETRECL (ADX).TMP_NPA_DATE,
                A.ASSETCLSH_AUTO_MAN_FLG = 'A',
                A.ASSETCLSH_REMARKS = 'Auto Reclassification',
                A.ASSETCLSH_LAST_MOD_BY = PKG_EODSOD_FLAGS.PV_USER_ID,
                A.ASSETCLSH_LAST_MOD_ON = V_PROCASSETRECL (ADX).TMP_NPA_DATE,
                A.ASSETCLSH_AUTH_BY = PKG_EODSOD_FLAGS.PV_USER_ID,
                A.ASSETCLSH_AUTH_ON = V_PROCASSETRECL (ADX).TMP_PROC_DATE, -- Remove It.
                A.ASSETCLSH_EXEMPT_END_DATE = NULL
          WHERE     A.ASSETCLSH_ENTITY_NUM = V_GLOB_ENTITY_NUM
                AND A.ASSETCLSH_INTERNAL_ACNUM =
                       V_PROCASSETRECL (ADX).TMP_ACNT_NUM
                AND A.ASSETCLSH_EFF_DATE =
                       V_PROCASSETRECL (ADX).TMP_PROC_DATE;
      ELSE
         INSERT INTO ASSETCLSHIST
              VALUES (V_GLOB_ENTITY_NUM,
                      V_PROCASSETRECL (ADX).TMP_ACNT_NUM,
                      V_PROCASSETRECL (ADX).TMP_PROC_DATE,
                      V_NEW_ASSET_CODE,
                      V_PROCASSETRECL (ADX).TMP_NPA_DATE,
                      'A',
                      'Auto Reclassification',
                      PKG_EODSOD_FLAGS.PV_USER_ID,
                      V_PROCASSETRECL (ADX).TMP_PROC_DATE,
                      NULL,
                      NULL,
                      PKG_EODSOD_FLAGS.PV_USER_ID,
                      V_PROCASSETRECL (ADX).TMP_PROC_DATE,
                      NULL,
                      0,
                      NULL);
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         W_ERROR_MSG :=
               'Error in INSERT_INTO_ASSETCLSH for '
            || FACNO (V_GLOB_ENTITY_NUM, V_PROCASSETRECL (ADX).TMP_ACNT_NUM)
            || '-'
            || SUBSTR (SQLERRM, 1, 500);
         RAISE E_USEREXCEP;
   END INSERT_INTO_ASSETCLSH;

   PROCEDURE GET_LNPRODACPM
   IS
      V_PROD_CURR_KEY   VARCHAR2 (7);
   BEGIN
      FOR IQX IN (SELECT LNPRDAC_PROD_CODE,
                         LNPRDAC_CURR_CODE,
                         LNPRDAC_INT_INCOME_GL,
                         LNPRDAC_INT_SUSP_GL
                    FROM LNPRODACPM)
      LOOP
         V_PROD_CURR_KEY :=
            LPAD (IQX.LNPRDAC_PROD_CODE, 4, 0) || IQX.LNPRDAC_CURR_CODE;

         V_LNPRODACPM (V_PROD_CURR_KEY).TMP_PROD_CODE := IQX.LNPRDAC_PROD_CODE;
         V_LNPRODACPM (V_PROD_CURR_KEY).TMP_ACNT_CURR := IQX.LNPRDAC_CURR_CODE;
         V_LNPRODACPM (V_PROD_CURR_KEY).TMP_INCOME_GL :=
            IQX.LNPRDAC_INT_INCOME_GL;
         V_LNPRODACPM (V_PROD_CURR_KEY).TMP_SUSPENSE_GL :=
            IQX.LNPRDAC_INT_SUSP_GL;
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         W_ERROR_MSG :=
            'Error in GET_LNPRODACPM - ' || SUBSTR (SQLERRM, 1, 500);
         RAISE E_USEREXCEP;
   END GET_LNPRODACPM;

   --------------------------------------------------------------------------------------------
   /* PROCEDURE GET_SUSP_REV_DETAILS(IBX NUMBER) IS
     BEGIN
       W_COUNT1 := W_COUNT1 + 1;

       V_SUSP_DETAILS(W_COUNT1).TMP_ACNT_NUM := V_PROCASSETRECL(IBX).TMP_ACNT_NUM;
       V_SUSP_DETAILS(W_COUNT1).TMP_PROD_CODE := V_PROCASSETRECL(IBX).TMP_PROD_CODE;
       V_SUSP_DETAILS(W_COUNT1).TMP_ACNT_CURR := V_PROCASSETRECL(IBX).TMP_ACNT_CURR;
       V_SUSP_DETAILS(W_COUNT1).TMP_SUSP_BAL := V_PROCASSETRECL(IBX).TMP_SUSP_BAL;
       V_SUSP_DETAILS(W_COUNT1).TMP_SUSP_PRIN_BAL := V_PROCASSETRECL(IBX).TMP_SUSP_PRIN_BAL;
       V_SUSP_DETAILS(W_COUNT1).TMP_SUSP_INT_BAL := V_PROCASSETRECL(IBX).TMP_SUSP_INT_BAL;
       V_SUSP_DETAILS(W_COUNT1).TMP_SUSP_CHG_BAL := V_PROCASSETRECL(IBX).TMP_SUSP_CHG_BAL;

       EXCEPTION
         WHEN OTHERS THEN
           W_ERROR_MSG := 'Error in GET_SUSP_REV_DETAILS for '||FACNO(PKG_ENTITY.FN_GET_ENTITY_CODE,V_PROCASSETRECL(IBX).TMP_ACNT_NUM)||' '||SUBSTR(SQLERRM,1,500);
           RAISE E_USEREXCEP;
       END GET_SUSP_REV_DETAILS;
   */

   PROCEDURE SET_TRANBAT_VALUES
   IS
   BEGIN
      PKG_AUTOPOST.PV_TRANBAT.TRANBAT_SOURCE_TABLE := 'PROCASSETRECL';
      PKG_AUTOPOST.PV_TRANBAT.TRANBAT_SOURCE_KEY := ASON_DATE;
      PKG_AUTOPOST.PV_TRANBAT.TRANBAT_NARR_DTL1 :=
         'Interest Suspense Reversal ';
      PKG_AUTOPOST.PV_TRANBAT.TRANBAT_NARR_DTL2 := 'Ason ' || ASON_DATE;
      PKG_AUTOPOST.PV_TRANBAT.TRANBAT_NARR_DTL3 := '';
      pkg_autopost.PV_AUTO_AUTHORISE := TRUE;
   END SET_TRANBAT_VALUES;

   PROCEDURE SET_TRAN_KEY_VALUES
   IS
   BEGIN
      PKG_AUTOPOST.PV_TRAN_KEY.TRAN_BRN_CODE := W_BRN_CODE;
      PKG_AUTOPOST.PV_TRAN_KEY.TRAN_DATE_OF_TRAN :=
         Pkg_Pb_Global.FN_GET_CURR_BUS_DATE (V_GLOB_ENTITY_NUM);
      PKG_AUTOPOST.PV_TRAN_KEY.TRAN_BATCH_NUMBER := 0;
      PKG_AUTOPOST.PV_TRAN_KEY.TRAN_BATCH_SL_NUM := 0;
   END SET_TRAN_KEY_VALUES;

   PROCEDURE SET_TRAN_VALUES (P_CURR VARCHAR2)
   IS
      W_INDEX_KEY   VARCHAR2 (7);
   BEGIN
      FOR CBX IN 1 .. V_SUSP_DETAILS.COUNT
      LOOP
         IF V_SUSP_DETAILS (CBX).TMP_ACNT_CURR = P_CURR
         THEN
            W_INDEX_KEY :=
                  LPAD (V_SUSP_DETAILS (CBX).TMP_PROD_CODE, 4, 0)
               || V_SUSP_DETAILS (CBX).TMP_ACNT_CURR;

            IF V_LNPRODACPM.EXISTS (W_INDEX_KEY) = TRUE
            THEN
               IF V_SUSP_DETAILS (CBX).TMP_SUSP_BAL > 0
               THEN
                  IF V_LNPRODACPM (W_INDEX_KEY).TMP_SUSPENSE_GL IS NOT NULL
                  THEN
                     TRAN_IDX := TRAN_IDX + 1;
                     PKG_AUTOPOST.PV_TRAN_REC (TRAN_IDX).TRAN_DB_CR_FLG := 'D';
                     PKG_AUTOPOST.PV_TRAN_REC (TRAN_IDX).TRAN_DATE_OF_TRAN :=
                        ASON_DATE;
                     PKG_AUTOPOST.PV_TRAN_REC (TRAN_IDX).TRAN_ACING_BRN_CODE :=
                        W_BRN_CODE;
                     PKG_AUTOPOST.PV_TRAN_REC (TRAN_IDX).TRAN_GLACC_CODE :=
                        V_LNPRODACPM (W_INDEX_KEY).TMP_SUSPENSE_GL;
                     PKG_AUTOPOST.PV_TRAN_REC (TRAN_IDX).TRAN_CURR_CODE :=
                        V_SUSP_DETAILS (CBX).TMP_ACNT_CURR;
                     PKG_AUTOPOST.PV_TRAN_REC (TRAN_IDX).TRAN_AMOUNT :=
                        V_SUSP_DETAILS (CBX).TMP_SUSP_BAL;
                     PKG_AUTOPOST.PV_TRAN_REC (TRAN_IDX).TRAN_VALUE_DATE :=
                        ASON_DATE;
                     PKG_AUTOPOST.PV_TRAN_REC (TRAN_IDX).TRAN_NARR_DTL1 :=
                        'Interest Suspense Reversal';
                     PKG_AUTOPOST.PV_TRAN_REC (TRAN_IDX).TRAN_NARR_DTL2 :=
                           'For '
                        || FACNO (V_GLOB_ENTITY_NUM,
                                  V_SUSP_DETAILS (CBX).TMP_ACNT_NUM);
                  ELSE
                     W_ERROR_MSG :=
                           'Interest Suspense GL Not Defined For Prod Code = '
                        || V_SUSP_DETAILS (CBX).TMP_PROD_CODE
                        || '  '
                        || ' Curr Code = '
                        || V_SUSP_DETAILS (CBX).TMP_ACNT_CURR;
                     RAISE E_USEREXCEP;
                  END IF;

                  IF V_LNPRODACPM (W_INDEX_KEY).TMP_INCOME_GL IS NOT NULL
                  THEN
                     TRAN_IDX := TRAN_IDX + 1;
                     PKG_AUTOPOST.PV_TRAN_REC (TRAN_IDX).TRAN_DB_CR_FLG := 'C';
                     PKG_AUTOPOST.PV_TRAN_REC (TRAN_IDX).TRAN_DATE_OF_TRAN :=
                        ASON_DATE;
                     PKG_AUTOPOST.PV_TRAN_REC (TRAN_IDX).TRAN_ACING_BRN_CODE :=
                        W_BRN_CODE;
                     PKG_AUTOPOST.PV_TRAN_REC (TRAN_IDX).TRAN_GLACC_CODE :=
                        V_LNPRODACPM (W_INDEX_KEY).TMP_INCOME_GL;
                     PKG_AUTOPOST.PV_TRAN_REC (TRAN_IDX).TRAN_CURR_CODE :=
                        V_SUSP_DETAILS (CBX).TMP_ACNT_CURR;
                     PKG_AUTOPOST.PV_TRAN_REC (TRAN_IDX).TRAN_AMOUNT :=
                        V_SUSP_DETAILS (CBX).TMP_SUSP_BAL;
                     PKG_AUTOPOST.PV_TRAN_REC (TRAN_IDX).TRAN_VALUE_DATE :=
                        ASON_DATE;
                     PKG_AUTOPOST.PV_TRAN_REC (TRAN_IDX).TRAN_NARR_DTL1 :=
                        'Interest Suspense Reversal';
                     PKG_AUTOPOST.PV_TRAN_REC (TRAN_IDX).TRAN_NARR_DTL2 :=
                           'For '
                        || FACNO (V_GLOB_ENTITY_NUM,
                                  V_SUSP_DETAILS (CBX).TMP_ACNT_NUM);
                  ELSE
                     W_ERROR_MSG :=
                           'Interest Income GL Not Defined For Prod Code = '
                        || V_SUSP_DETAILS (CBX).TMP_PROD_CODE
                        || '  '
                        || ' Curr Code = '
                        || V_SUSP_DETAILS (CBX).TMP_ACNT_CURR;
                     RAISE E_USEREXCEP;
                  END IF;
               END IF;
            ELSE
               W_ERROR_MSG :=
                     'Accounting Parameter Not Defined For Prod Code = '
                  || V_SUSP_DETAILS (CBX).TMP_PROD_CODE
                  || '  '
                  || ' Curr Code = '
                  || V_SUSP_DETAILS (CBX).TMP_ACNT_CURR;
               RAISE E_USEREXCEP;
            END IF;
         END IF;
      END LOOP;
   END SET_TRAN_VALUES;

   PROCEDURE UPDATE_SUSP_DETAILS
   IS
   BEGIN
      FOR CDX IN 1 .. V_SUSP_DETAILS.COUNT
      LOOP
         IF V_SUSP_DETAILS (CDX).TMP_SUSP_BAL > 0
         THEN
           <<UPDATE_SUSPBAL>>
            BEGIN
               UPDATE LNSUSPBAL
                  SET LNSUSPBAL_SUSP_BAL =
                           LNSUSPBAL_SUSP_BAL
                         + V_SUSP_DETAILS (CDX).TMP_SUSP_BAL,
                      LNSUSPBAL_SUSP_CR_SUM =
                           LNSUSPBAL_SUSP_CR_SUM
                         + V_SUSP_DETAILS (CDX).TMP_SUSP_BAL,
                      LNSUSPBAL_PRIN_BAL =
                           LNSUSPBAL_PRIN_BAL
                         + V_SUSP_DETAILS (CDX).TMP_SUSP_PRIN_BAL,
                      LNSUSPBAL_INT_BAL =
                           LNSUSPBAL_INT_BAL
                         + V_SUSP_DETAILS (CDX).TMP_SUSP_INT_BAL,
                      LNSUSPBAL_CHG_BAL =
                           LNSUSPBAL_CHG_BAL
                         + V_SUSP_DETAILS (CDX).TMP_SUSP_CHG_BAL
                WHERE     LNSUSPBAL_ENTITY_NUM = V_GLOB_ENTITY_NUM
                      AND LNSUSPBAL_ACNT_NUM =
                             V_SUSP_DETAILS (CDX).TMP_ACNT_NUM
                      AND LNSUSPBAL_CURR_CODE =
                             V_SUSP_DETAILS (CDX).TMP_ACNT_CURR;

               SELECT NVL (MAX (LNSUSP_SL_NUM), 0) + 1
                 INTO W_MAX_SL
                 FROM LNSUSPLED
                WHERE     LNSUSP_ENTITY_NUM = V_GLOB_ENTITY_NUM
                      AND LNSUSP_ACNT_NUM = V_SUSP_DETAILS (CDX).TMP_ACNT_NUM
                      AND LNSUSP_TRAN_DATE = ASON_DATE;

               INSERT INTO LNSUSPLED
                    VALUES (V_GLOB_ENTITY_NUM,
                            V_SUSP_DETAILS (CDX).TMP_ACNT_NUM,
                            ASON_DATE,
                            W_MAX_SL,
                            ASON_DATE,
                            '3',
                            'C',
                            V_SUSP_DETAILS (CDX).TMP_ACNT_CURR,
                            V_SUSP_DETAILS (CDX).TMP_SUSP_BAL,
                            V_SUSP_DETAILS (CDX).TMP_SUSP_INT_BAL,
                            V_SUSP_DETAILS (CDX).TMP_SUSP_CHG_BAL,
                            ASON_DATE,
                            ASON_DATE,
                            'Interest Suspense Reversal',
                            '',
                            '',
                            'A',
                            '',
                            '',
                            PKG_EODSOD_FLAGS.PV_USER_ID,
                            ASON_DATE,
                            '',
                            '',
                            '',
                            '',
                            '');
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  W_ERROR_MSG :=
                        'Error in Updating Suspense for - '
                     || FACNO (1, V_SUSP_DETAILS (CDX).TMP_ACNT_NUM)
                     || '-'
                     || SUBSTR (SQLERRM, 1, 500);
                  RAISE E_USEREXCEP;
            END UPDATE_SUSPBAL;
         END IF;
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         W_ERROR_MSG :=
            'Error in UPDATE_SUSP_DETAILS - ' || SUBSTR (SQLERRM, 1, 500);
         RAISE E_USEREXCEP;
   END UPDATE_SUSP_DETAILS;

   -- Note: Now Here
   FUNCTION FN_GET_OVERDUE_PRD
      RETURN NUMBER
   IS
      V_TOT_MONTH_FROM_REPAY_DATE   NUMBER;
      V_TOT_PAID_MONTH              NUMBER;
      V_OD_MONTH                    NUMBER;
   BEGIN
    
    /*
      W_SQL :=
            'SELECT ABS(NVL(FN_GET_ASON_DR_OR_CR_BAL('
         || V_GLOB_ENTITY_NUM
         || ','
         || W_ACNTS_INTERNAL_ACNUM
         || ', '
         || CHR (39)
         || W_ACNTS_CURR_CODE
         || CHR (39)
         || ' ,'
         || CHR (39)
         || W_ASON_DATE
         || CHR (39)
         || ', '
         || CHR (39)
         || W_CBD
         || CHR (39)
         || ', ''D'' , 0),0)) ACBAL FROM dual';

      BEGIN
         EXECUTE IMMEDIATE W_SQL INTO V_ASON_BC_BAL;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            V_ASON_BC_BAL := 0;
      END;
    */

      W_SQL := 'SELECT ABS(NVL(FN_GET_ASON_DR_OR_CR_BAL(:V_GLOB_ENTITY_NUM,:W_ACNTS_INTERNAL_ACNUM,:W_ACNTS_CURR_CODE,:W_ASON_DATE,: W_CBD ,''D'' , 0),0)) ACBAL FROM dual';

      BEGIN
         EXECUTE IMMEDIATE W_SQL INTO V_ASON_BC_BAL
         USING V_GLOB_ENTITY_NUM,W_ACNTS_INTERNAL_ACNUM,W_ACNTS_CURR_CODE, W_ASON_DATE, W_CBD ;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            V_ASON_BC_BAL := 0;
      END;

      V_PAID_AMOUNT :=
           (  ABS (NVL (W_TOT_DISB_AMOUNT, 0))
            + ABS (NVL (W_TOT_INT_DB_MIG, 0))
            + ABS (W_TOT_INT_DB)
            + ABS (W_TOT_CHGS_DB))
         - V_ASON_BC_BAL;

      IF V_REPAY_FREQ = 'M'
      THEN
         V_REPAY_FREQ_IN_MON := 1;
      ELSIF V_REPAY_FREQ = 'Q'
      THEN
         V_REPAY_FREQ_IN_MON := 3;
      ELSIF V_REPAY_FREQ = 'H'
      THEN
         V_REPAY_FREQ_IN_MON := 6;
      ELSIF V_REPAY_FREQ = 'Y'
      THEN
         V_REPAY_FREQ_IN_MON := 12;
      ELSE
         V_REPAY_FREQ_IN_MON := 1;
      END IF;

      IF V_REPAY_START_DATE <= W_ASON_DATE
      THEN
         V_TOT_MONTH_FROM_REPAY_DATE :=
              (  FLOOR (
                      (TRUNC (
                          (MONTHS_BETWEEN (W_ASON_DATE, V_REPAY_START_DATE))))
                    / V_REPAY_FREQ_IN_MON)
               * V_REPAY_FREQ_IN_MON)
            + V_REPAY_FREQ_IN_MON;
      ELSE
         V_TOT_MONTH_FROM_REPAY_DATE := 0;
      END IF;

      IF V_REPAY_SIZE = NULL OR V_REPAY_SIZE = 0
      THEN
         V_REPAY_SIZE := 1;
      END IF;

      V_TOT_PAID_MONTH :=
         FLOOR ( (V_REPAY_FREQ_IN_MON * V_PAID_AMOUNT) / V_REPAY_SIZE);
      /*
      DBMS_OUTPUT.PUT_LINE(FACNO(1, W_ACNTS_INTERNAL_ACNUM));
      DBMS_OUTPUT.PUT_LINE('V_REPAY_START_DATE = ' || V_REPAY_START_DATE);
      DBMS_OUTPUT.PUT_LINE('V_TOT_PAID_MONTH = ' || V_TOT_PAID_MONTH);
      DBMS_OUTPUT.PUT_LINE('W_ASON_DATE = ' || W_ASON_DATE);
      DBMS_OUTPUT.PUT_LINE('V_TOT_MONTH_FROM_REPAY_DATE =' || V_TOT_MONTH_FROM_REPAY_DATE);
      DBMS_OUTPUT.PUT_LINE('V_REPAY_SIZE =' || V_REPAY_SIZE);
      DBMS_OUTPUT.PUT_LINE('W_OD_DATE =' || W_OD_DATE);
      DBMS_OUTPUT.PUT_LINE('V_REPAY_FREQ = ' || V_REPAY_FREQ);
      DBMS_OUTPUT.PUT_LINE('W_OVERDUE_PRD = ' || W_OVERDUE_PRD);
      DBMS_OUTPUT.PUT_LINE('Prev: = ' ||
                           (FLOOR(MONTHS_BETWEEN(W_ASON_DATE, W_OD_DATE))));
      */
      V_OD_MONTH := V_TOT_MONTH_FROM_REPAY_DATE - V_TOT_PAID_MONTH;

      IF V_OD_MONTH < 0
      THEN
         V_OD_MONTH := 0;
      END IF;

      RETURN V_OD_MONTH;
   END FN_GET_OVERDUE_PRD;

   -- Note: Identifying the loan accounts for which the asset code status need to be changed
   --       Main Select Query
   PROCEDURE IDENTIFICATION_PROCESS (P_ENTITY_NUM   IN     NUMBER,
                                     P_ASON_DATE    IN     DATE,
                                     P_BRN_CODE            NUMBER,
                                     P_PROD_CODE           NUMBER,
                                     P_ACNT_NUM            NUMBER,
                                     P_ERROR_MSG       OUT VARCHAR2)
   IS
   BEGIN
      PKG_ENTITY.SP_SET_ENTITY_CODE (P_ENTITY_NUM);
      V_GLOB_ENTITY_NUM := P_ENTITY_NUM;
      W_CBD := PKG_PB_GLOBAL.FN_GET_CURR_BUS_DATE (P_ENTITY_NUM);

      IF P_ASON_DATE IS NULL
      THEN
         W_ERROR_MSG := 'Ason Date Cannot be Null';
         RAISE E_USEREXCEP;
      ELSE
         W_ASON_DATE := P_ASON_DATE;
      END IF;

     W_SQL :=
            'SELECT PRODUCT_FOR_RUN_ACS, ACNTS_INTERNAL_ACNUM, ACNTS_CLIENT_NUM,ACNTS_PROD_CODE,
       ACNTS_AC_TYPE,ACNTS_CURR_CODE,ACNTS_OPENING_DATE,LMTLINE_LIMIT_EXPIRY_DATE,BSRNBAC_CMSME_CATEGORY
       FROM LOANACNTS,ACNTS,PRODUCTS,LNPRODPM,LIMITLINE, ACASLLDTL,ASSETCLS,LNACMIS,BSRNBAC
       WHERE ACNTS_ENTITY_NUM = '
         || V_GLOB_ENTITY_NUM
         || '
       AND LNACNT_ENTITY_NUM = '
         || V_GLOB_ENTITY_NUM
         || '
       AND ACASLLDTL_ENTITY_NUM = '
         || V_GLOB_ENTITY_NUM
         || '
       AND LMTLINE_ENTITY_NUM = '
         || V_GLOB_ENTITY_NUM
         || '
       AND ASSETCLS_ENTITY_NUM = '
         || V_GLOB_ENTITY_NUM
         || '
         AND LNACMIS_ENTITY_NUM = '
         || V_GLOB_ENTITY_NUM
         || '        
       AND ACNTS_INTERNAL_ACNUM = LNACNT_INTERNAL_ACNUM
       AND LNACNT_INTERNAL_ACNUM = LNACMIS_INTERNAL_ACNUM 
       AND BSRNBAC_CODE = LNACMIS_NATURE_BORROWAL_AC
       AND ACNTS_INTERNAL_ACNUM = LNACNT_INTERNAL_ACNUM
       AND ACNTS_INTERNAL_ACNUM NOT IN (SELECT L.LNWRTOFF_ACNT_NUM FROM LNWRTOFF L )
       AND ACNTS_PROD_CODE = PRODUCT_CODE
       AND LNPRD_PROD_CODE = PRODUCT_CODE
       AND PRODUCT_CODE NOT IN (2042, 2301, 2311, 2315, 2319, 2324, 2401, 2502, 2508, 2514, 2546 , 2547)
       AND ACASLLDTL_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
       AND ACNTS_INTERNAL_ACNUM = ASSETCLS_INTERNAL_ACNUM
       AND (ASSETCLS_AUTO_MAN_FLG <> ''M'' OR ( ASSETCLS_AUTO_MAN_FLG = ''M''
       AND ASSETCLS_EXEMPT_END_DATE < '
         || CHR (39)
         || W_ASON_DATE
         || CHR (39)
         || '))
       AND LMTLINE_NUM = ACASLLDTL_LIMIT_LINE_NUM
       AND LMTLINE_CLIENT_CODE = ACASLLDTL_CLIENT_NUM
       AND LNPRD_STAFF_LOAN <> '
         || CHR (39)
         || 1
         || CHR (39)
         || 'AND PRODUCT_FOR_LOANS = '
         || CHR (39)
         || 1
         || CHR (39)
         || ' AND PRODUCT_EXEMPT_FROM_NPA <>'
         || CHR (39)
         || 1
         || CHR (39)
         || '
       AND (ACNTS_CLOSURE_DATE IS NULL OR ACNTS_CLOSURE_DATE > '
         || CHR (39)
         || W_ASON_DATE
         || CHR (39)
         || ') AND ACNTS_AUTH_ON IS NOT NULL ';

      IF (P_BRN_CODE > 0)
      THEN
         W_SQL := W_SQL || ' AND ACNTS_BRN_CODE=' || P_BRN_CODE;
      END IF;

      IF (P_PROD_CODE > 0)
      THEN
         W_SQL := W_SQL || ' AND ACNTS_PROD_CODE=' || P_PROD_CODE;
      END IF;

      IF (P_ACNT_NUM > 0)
      THEN
         W_SQL := W_SQL || ' AND ACNTS_INTERNAL_ACNUM=' || P_ACNT_NUM;
      END IF;

      --W_SQL := W_SQL || ' AND ACNTS_INTERNAL_ACNUM IN (14814000000620)';

      EXECUTE IMMEDIATE W_SQL BULK COLLECT INTO TAB_AC_PROD_REC;

      FOR IDX IN 1 .. TAB_AC_PROD_REC.COUNT
      LOOP
         INIT_PARA;
         W_PRODUCT_FOR_RUN_ACS := TAB_AC_PROD_REC (IDX).V_PRODUCT_FOR_RUN_ACS;

         W_ACNTS_INTERNAL_ACNUM :=
            TAB_AC_PROD_REC (IDX).V_ACNTS_INTERNAL_ACNUM;
         W_ACNTS_CLIENT_NUM := TAB_AC_PROD_REC (IDX).V_ACNTS_CLIENT_NUM;
         W_ACNTS_PROD_CODE := TAB_AC_PROD_REC (IDX).V_ACNTS_PROD_CODE;
         W_ACNTS_AC_TYPE := TAB_AC_PROD_REC (IDX).V_ACNTS_AC_TYPE;
         W_ACNTS_CURR_CODE := TAB_AC_PROD_REC (IDX).V_ACNTS_CURR_CODE;
         W_ACNTS_OPENING_DATE := TAB_AC_PROD_REC (IDX).V_ACNTS_OPENING_DATE;
         W_LIMIT_EXP_DATE := TAB_AC_PROD_REC (IDX).V_LIMIT_EXP_DATE;
         W_CMSME_CATEGORY := TAB_AC_PROD_REC (IDX).V_CMSME_CATEEGORY;
         W_OVERDUE_PRD := 0;

         GET_OVERDUE_DTLS;

         CHECK_ASSET_STAT;
         W_NEW_ASSET_CODE := W_CURR_ASSET_CODE;

         --Note: If no overdue then Asset Status become UC
         IF W_OD_AMT = 0.0 AND W_OD_DATE IS NULL
         THEN
            W_OD_DATE := W_ASON_DATE;
         END IF;

         IF W_OD_DATE IS NOT NULL
         THEN
            IF W_OD_DATE > W_ASON_DATE
            THEN
               W_OD_DATE := W_ASON_DATE;
            END IF;

            /*
            Note: This portion is OK for Monthly installment but Create Problem for Q,H and Y
             W_OVERDUE_PRD := (FLOOR(MONTHS_BETWEEN(W_ASON_DATE, W_OD_DATE)));
             So, for solving it, the following changes made.
             */
            --Note: Ajker Main Work
            W_PROC_YEAR :=
               SP_GETFINYEAR (V_GLOB_ENTITY_NUM, W_ACNTS_OPENING_DATE);
            W_UPTO_YEAR := SP_GETFINYEAR (V_GLOB_ENTITY_NUM, W_ASON_DATE);
            FETCH_LLACNTOS (W_ACNTS_INTERNAL_ACNUM, W_TOT_DISB_AMOUNT);
            GET_TOT_INT_DB_MIG;

            IF W_PROC_YEAR < 2014
            THEN
               W_PROC_YEAR := 2014;
            END IF;

            W_TOT_INT_DB := 0;
            W_TOT_CHGS_DB := 0;

            WHILE (W_PROC_YEAR <= W_UPTO_YEAR)
            LOOP
               TRANADV_PROC;
               W_PROC_YEAR := W_PROC_YEAR + 1;
            END LOOP;

            IF W_PRODUCT_FOR_RUN_ACS = '0'
            THEN
               W_PROD_TYPE := '2';

               -- Note: For Behaving as Continus Loan, It will be Parameterized
               IF (   W_ACNTS_PROD_CODE = 2501
                   OR W_ACNTS_PROD_CODE = 2502
                   OR W_ACNTS_PROD_CODE = 2504
                   OR W_ACNTS_PROD_CODE = 2509
                   OR W_ACNTS_PROD_CODE = 2511
                   OR W_ACNTS_PROD_CODE = 2512
                   OR W_ACNTS_PROD_CODE = 2514
                   OR W_ACNTS_PROD_CODE = 2515
                   OR W_ACNTS_PROD_CODE = 2516
                   OR W_ACNTS_PROD_CODE = 2517
                   OR W_ACNTS_PROD_CODE = 2528
                   OR W_ACNTS_PROD_CODE = 2529
                   OR W_ACNTS_PROD_CODE = 2530
                   OR W_ACNTS_PROD_CODE = 2532
                   OR W_ACNTS_PROD_CODE = 2533
                   OR W_ACNTS_PROD_CODE = 2534
                   OR W_ACNTS_PROD_CODE = 2538
                   OR W_ACNTS_PROD_CODE = 2540
                   OR W_ACNTS_PROD_CODE = 2546
                   OR W_ACNTS_PROD_CODE = 2553
                   ---as per request added by sabuj
                    OR W_ACNTS_PROD_CODE = 2555
                    OR W_ACNTS_PROD_CODE = 2556
                    OR W_ACNTS_PROD_CODE = 2571
                    OR W_ACNTS_PROD_CODE = 2580
                    OR W_ACNTS_PROD_CODE = 2572
                    OR W_ACNTS_PROD_CODE = 2597
                    OR W_ACNTS_PROD_CODE = 2599
                    OR W_ACNTS_PROD_CODE = 2577
                    OR W_ACNTS_PROD_CODE = 2578
                    OR W_ACNTS_PROD_CODE = 2539
                    OR W_ACNTS_PROD_CODE = 2598
                   )
               THEN
                  W_OVERDUE_PRD :=
                     (FLOOR (MONTHS_BETWEEN (W_ASON_DATE, W_OD_DATE)));
               ELSIF (V_REPAY_FREQ = 'X')
               THEN
                  W_PROD_TYPE := '1';
                  W_OVERDUE_PRD :=
                     (FLOOR (MONTHS_BETWEEN (W_ASON_DATE, W_OD_DATE)));
               ELSE
                  W_OVERDUE_PRD := FN_GET_OVERDUE_PRD;
               --DBMS_OUTPUT.PUT_LINE(W_OVERDUE_PRD);
               END IF;
            ELSIF ( (W_PRODUCT_FOR_RUN_ACS = '1'))
            THEN
               W_PROD_TYPE := '1';
               W_OVERDUE_PRD :=
                  (FLOOR (MONTHS_BETWEEN (W_ASON_DATE, W_OD_DATE)));
            END IF;

            IF (V_PURPOSE_CODE = 'R' AND V_REPHASEMENT_ENTRY = '1')
            THEN
               IF NVL (V_LNACRS_MONTHS_TO_BL, 0) > 0
               THEN
                  V_LNRSCLS_NO_OF_MON := V_LNACRS_MONTHS_TO_BL;
                  V_LNRSCLS_EXP_DATE := 0;
               ELSE
                 <<FETCH_LNRSCLSPM>>
                  BEGIN
                     SELECT LNRSCLS_NO_OF_MON, LNRSCLS_EXP_DATE
                       INTO V_LNRSCLS_NO_OF_MON, V_LNRSCLS_EXP_DATE
                       FROM LNRSCLSPM
                      WHERE LNRSCLS_PRD_CODE = W_ACNTS_PROD_CODE;
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        V_LNRSCLS_NO_OF_MON := 0;
                        V_LNRSCLS_EXP_DATE := 0;
                  END FETCH_LNRSCLSPM;
               END IF;

               IF V_LNRSCLS_EXP_DATE = 1
               THEN
                  IF W_ASON_DATE > W_LIMIT_EXP_DATE
                  THEN
                     W_NEW_ASSET_CODE := 'BL';
                  ELSE
                     W_NEW_ASSET_CODE := W_CURR_ASSET_CODE;
                  END IF;
               ELSE
                  IF W_OVERDUE_PRD >= V_LNRSCLS_NO_OF_MON
                  THEN
                     W_NEW_ASSET_CODE := 'BL';
                  ELSE
                     W_NEW_ASSET_CODE := W_CURR_ASSET_CODE;
                  END IF;
               END IF;
            ELSE
               GET_ASSETRECL_PARAM;
            END IF;

            IF W_NEW_ASSET_CODE IS NOT NULL
            THEN
               IF W_STD_ASSET <> '1'
               THEN
                 -- Disabled: GET_COVID_ASSET_CODE (W_NEW_ASSET_CODE, W_CURR_ASSET_CODE);
                  IF W_NEW_ASSET_CODE <> W_CURR_ASSET_CODE
                  THEN
                     --IF TRUE THEN
                     
                     GET_ASSET_CLASS (W_NEW_ASSET_CODE, W_NEW_ASSET_CLASS);

                     IF     W_ASSETCD_ASSET_CLASS = 'P'
                        AND W_NEW_ASSET_CLASS = 'N'
                     THEN
                        W_INCOME_REV := '1';
                        W_SUSP_REV := '0';
                        W_SUSP_BAL := 0;
                        W_SUSP_PRIN_BAL := 0;
                        W_SUSP_INT_BAL := 0;
                        W_SUSP_CHGS_BAL := 0;
                        W_NPA_DATE := W_ASON_DATE;
                     ELSIF     W_NEW_ASSET_CLASS = 'N'
                           AND W_ASSETCD_ASSET_CLASS = 'N'
                     THEN
                        W_NPA_DATE := W_EXT_NPA_DATE;
                        W_INCOME_REV := '0';
                        W_SUSP_REV := '0';
                        W_SUSP_BAL := 0;
                        W_SUSP_PRIN_BAL := 0;
                        W_SUSP_INT_BAL := 0;
                        W_SUSP_CHGS_BAL := 0;
                        W_NPA_DATE := W_ASON_DATE;
                     ELSIF W_NEW_ASSET_CLASS = 'P'
                     THEN
                        W_INCOME_REV := '0';

                        -- GET_SUSPBAL; (No Suspense Bal Recov Happen Now)
                        IF ABS (W_SUSP_BAL) > 0
                        THEN
                           IF W_SUSP_REV_CHK = '1'
                           THEN
                              W_SUSP_REV := '1';
                           END IF;
                        ELSE
                           W_SUSP_BAL := 0;
                           W_SUSP_PRIN_BAL := 0;
                           W_SUSP_INT_BAL := 0;
                           W_SUSP_CHGS_BAL := 0;
                           W_SUSP_REV := '0';
                        END IF;
                     END IF;

                     W_INSERT_INTO_PROCASSETRECL := '1';
                  ELSE
                     IF W_NEW_ASSET_CLASS = 'P' AND W_NEW_ASSET_CLASS = 'P'
                     THEN
                        W_INCOME_REV := '0';

                        -- GET_SUSPBAL; (No Suspense Bal Recov Happen Now)
                        IF ABS (W_SUSP_BAL) > 0
                        THEN
                           IF W_SUSP_REV_CHK = '1'
                           THEN
                              W_SUSP_REV := '1';
                           END IF;
                        ELSE
                           W_SUSP_BAL := 0;
                           W_SUSP_PRIN_BAL := 0;
                           W_SUSP_INT_BAL := 0;
                           W_SUSP_CHGS_BAL := 0;
                           W_SUSP_REV := '0';
                        END IF;

                        W_INSERT_INTO_PROCASSETRECL := '1';
                     ELSE
                        GOTO PROCESS_NEXT_ACCOUNT;
                     END IF;
                  END IF;
               ELSE
                  IF W_NEW_ASSET_CLASS = 'N'
                  THEN
                     W_NPA_DATE := W_ASON_DATE;
                     W_INCOME_REV := '1';
                  END IF;

                  W_INSERT_INTO_PROCASSETRECL := '1';
               END IF;
            ELSE
               GOTO PROCESS_NEXT_ACCOUNT;
            END IF;

            IF W_INSERT_INTO_PROCASSETRECL = '1'
            THEN
               IF V_TYPE = 'P'
               THEN
                  INSERT_INTO_PROCASSETRECL;
               ELSIF V_TYPE = 'R'
               THEN
                  INSERT_INTO_STDNPACLS;
                  INSERT_INTO_STDNPACLSDTL;
               END IF;
            END IF;

           <<PROCESS_NEXT_ACCOUNT>>
            BEGIN
               NULL;
            END PROCESS_NEXT_ACCOUNT;
         END IF;

         V_ASSETRECL.DELETE;
      END LOOP;

      TAB_AC_PROD_REC.DELETE;
   EXCEPTION
      WHEN E_USEREXCEP
      THEN
         PKG_EODSOD_FLAGS.PV_ERROR_MSG := W_ERROR_MSG;
         PKG_PB_GLOBAL.DETAIL_ERRLOG (V_GLOB_ENTITY_NUM,
                                      'E',
                                      W_ERROR_MSG,
                                      ' ',
                                      0);
         P_ERROR_MSG := W_ERROR_MSG;
      WHEN OTHERS
      THEN
         W_ERROR_MSG :=
               'Error in IDENTIFICATION_PROCESS '
            || '-'
            || FACNO (V_GLOB_ENTITY_NUM, W_ACNTS_INTERNAL_ACNUM)
            || '-'
            || SUBSTR (SQLERRM, 1, 500);
         PKG_EODSOD_FLAGS.PV_ERROR_MSG := W_ERROR_MSG;
         PKG_PB_GLOBAL.DETAIL_ERRLOG (V_GLOB_ENTITY_NUM,
                                      'E',
                                      W_ERROR_MSG,
                                      ' ',
                                      0);
         P_ERROR_MSG := W_ERROR_MSG;
   END IDENTIFICATION_PROCESS;

   PROCEDURE POSTING_PROCESS (P_ENTITY_NUM       NUMBER,
                              P_ASON_DATE        DATE,
                              P_BRN_CODE         NUMBER,
                              P_PROD_CODE        NUMBER,
                              P_ERROR_MSG    OUT VARCHAR2)
   IS
      V_NEW_ASSET_CLASS   CHAR (1);
      V_OLD_ASSET_CLASS   CHAR (1);
      V_IGNORE_NPA        CHAR (1);
   BEGIN
      PKG_ENTITY.SP_SET_ENTITY_CODE (P_ENTITY_NUM);
      ASON_DATE := P_ASON_DATE;
      W_COUNT1 := 0;
      TRAN_IDX := 0;
      W_BRN_CODE := P_BRN_CODE;
      GET_LNPRODACPM;
      --
      W_SQL :=
            'SELECT STDNPACLS_PROC_DATE,
              ACNTS_BRN_CODE,
              ACNTS_PROD_CODE,
              STDNPACLS_ACNT_NUM,
              STDNPACLS_ACNT_CURR,
              STDNPACLS_OS_BAL,
              STDNPACLS_OD_AMT,
              STDNPACLS_OD_DATE,
              STDNPACLS_INT_OD_AMT,
              STDNPACLS_INT_OD_DATE,
              STDNPACLS_PRIN_OD_AMT,
              STDNPACLS_PRIN_OD_DATE,
              STDNPACLS_CHGS_OD_AMT,
              STDNPACLS_CHGS_OD_DATE,
              STDNPACLS_LIMIT_AMT,
              STDNPACLS_DP_AMT,
              STDNPACLS_NPA_DATE,
              ''1'',
              STDNPACLS_CURR_ASSET_CODE,
              STDNPACLS_NEW_ASSET_CODE,
              STDNPACLS_IGNORE_FROM_NPACLS

            FROM STDNPACLS,ACNTS,LOANACNTS
            WHERE STDNPACLS_ENTITY_NUM = '
         || V_GLOB_ENTITY_NUM
         || '
            AND LNACNT_ENTITY_NUM = '
         || V_GLOB_ENTITY_NUM
         || '
            AND ACNTS_ENTITY_NUM = '
         || V_GLOB_ENTITY_NUM
         || '
            AND ACNTS_INTERNAL_ACNUM = LNACNT_INTERNAL_ACNUM
            AND ACNTS_INTERNAL_ACNUM = STDNPACLS_ACNT_NUM
            AND ACNTS_CLOSURE_DATE IS NULL
            AND STDNPACLS_PROC_DATE = '
         || CHR (39)
         || P_ASON_DATE
         || CHR (39);

      IF P_BRN_CODE > 0
      THEN
         W_SQL := W_SQL || ' AND ACNTS_BRN_CODE = ' || P_BRN_CODE;
      END IF;

      IF P_PROD_CODE > 0
      THEN
         W_SQL := W_SQL || ' AND ACNTS_PROD_CODE = ' || P_PROD_CODE;
      END IF;

      /*
         W_SQL := 'SELECT PROCASSET_PROC_DATE,
                           ACNTS_BRN_CODE,
                           ACNTS_PROD_CODE,
                           PROCASSET_ACNT_NUM,
                           PROCASSET_ACNT_CURR,
                           PROCASSET_OS_BAL,
                           PROCASSET_OD_AMT ,
                           PROCASSET_OD_DATE,
                           PROCASSET_INT_OD_AMT,
                           PROCASSET_INT_OD_DATE,
                           PROCASSET_PRIN_OD_AMT,
                           PROCASSET_PRIN_OD_DATE,
                           PROCASSET_CHGS_OD_AMT,
                           PROCASSET_CHGS_OD_DATE,
                           PROCASSET_LIMIT_AMT,
                           PROCASSET_DP_AMT,
                           PROCASSET_NPA_DATE,
                           PROCASSET_NPA_IDENT_DATE,
                           PROCASSET_STD_ASSET,
                           PROCASSET_CURR_ASSET_CODE,
                           PROCASSET_NEW_ASSET_CODE,
                           PROCASSET_CLIENT_EXEMP_FLG,
                           PROCASSET_INCOME_REV_REQ,
                           PROCASSET_SUSP_REV_REQ,
                           PROCASSET_SUSP_BAL,
                           PROCASSET_SUSP_PRIN_BAL,
                           PROCASSET_SUSP_INT_BAL,
                           PROCASSET_SUSP_CHG_BAL
       FROM PROCASSETRECL,ACNTS WHERE PROCASSET_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND
       ACNTS_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND
       ACNTS_INTERNAL_ACNUM = PROCASSET_ACNT_NUM AND
       ACNTS_CLOSURE_DATE IS NULL AND
       PROCASSET_ACNT_NUM IN (SELECT LNACNT_INTERNAL_ACNUM FROM LOANACNTS WHERE LNACNT_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE)
       AND PROCASSET_PROC_DATE = '||CHR(39)||P_ASON_DATE||CHR(39) ;

       IF P_BRN_CODE > 0 THEN
         W_SQL := W_SQL || ' AND ACNTS_BRN_CODE = '||P_BRN_CODE;
         END IF;

       IF P_PROD_CODE >0 THEN
         W_SQL := W_SQL || ' AND ACNTS_PROD_CODE = '||P_PROD_CODE;
         END IF;
      */
      EXECUTE IMMEDIATE W_SQL BULK COLLECT INTO V_PROCASSETRECL;

      FOR ICX IN 1 .. V_PROCASSETRECL.COUNT
      LOOP
         V_NEW_ASSET_CLASS := '';
         V_OLD_ASSET_CLASS := '';

         V_IGNORE_NPA := V_PROCASSETRECL (ICX).TMP_IGNORE_FROM_NPACLS;

         IF V_IGNORE_NPA = '1'
         THEN
            V_NEW_ASSET_CODE := V_PROCASSETRECL (ICX).TMP_CURR_ASSET_CODE;
         ELSE
            V_NEW_ASSET_CODE := V_PROCASSETRECL (ICX).TMP_NEW_ASSET_CODE;
         END IF;

         IF V_PROCASSETRECL (ICX).TMP_STD_ASSET = '1'
         THEN
            IF V_PROCASSETRECL (ICX).TMP_NEW_ASSET_CODE IS NOT NULL
            THEN
               INSERT_INTO_ASSETCLS (ICX);
               INSERT_INTO_ASSETCLSH (ICX);
            END IF;
         ELSE
            IF     V_PROCASSETRECL (ICX).TMP_NEW_ASSET_CODE IS NOT NULL
               AND V_PROCASSETRECL (ICX).TMP_CURR_ASSET_CODE IS NOT NULL
            THEN
               GET_ASSET_CLASS (V_PROCASSETRECL (ICX).TMP_NEW_ASSET_CODE,
                                V_NEW_ASSET_CLASS);
               GET_ASSET_CLASS (V_PROCASSETRECL (ICX).TMP_CURR_ASSET_CODE,
                                V_OLD_ASSET_CLASS);

               IF V_PROCASSETRECL (ICX).TMP_CURR_ASSET_CODE <>
                     V_PROCASSETRECL (ICX).TMP_NEW_ASSET_CODE
               THEN
                  UPDATE_ASSETCLS (ICX);
                  INSERT_INTO_ASSETCLSH (ICX);
               /* IF V_PROCASSETRECL(ICX).TMP_SUSP_REV_REQ = '1' THEN
                IF NOT V_CURR.EXISTS(V_PROCASSETRECL(ICX).TMP_ACNT_CURR) THEN
                 V_CURR(V_PROCASSETRECL(ICX).TMP_ACNT_CURR) := V_PROCASSETRECL(ICX).TMP_ACNT_CURR;
                 END IF;
               GET_SUSP_REV_DETAILS(ICX);
               END IF; */

               /*ELSE
               IF V_NEW_ASSET_CLASS = 'P' AND V_OLD_ASSET_CLASS = 'P' THEN

                 IF V_PROCASSETRECL(ICX).TMP_SUSP_REV_REQ = '1' THEN

                   IF NOT V_CURR.EXISTS(V_PROCASSETRECL(ICX).TMP_ACNT_CURR) THEN
                   V_CURR(V_PROCASSETRECL(ICX).TMP_ACNT_CURR) := V_PROCASSETRECL(ICX).TMP_ACNT_CURR;
                   END IF;
                 GET_SUSP_REV_DETAILS(ICX);
                 END IF;
               END IF; */
               END IF;
            END IF;
         END IF;
      END LOOP;

      /*
      V_INDEX_BY := NULL;
      V_TRAN_CURR := NULL;
      V_INDEX_BY := V_CURR.FIRST;

      WHILE V_INDEX_BY IS NOT NULL LOOP
      TRAN_IDX := 0;
      V_TRAN_CURR := V_CURR(V_INDEX_BY);
      PKG_APOST_INTERFACE.SP_POSTING_BEGIN(PKG_ENTITY.FN_GET_ENTITY_CODE);
      SET_TRAN_KEY_VALUES;
      SET_TRANBAT_VALUES;
      SET_TRAN_VALUES(V_TRAN_CURR);

      IF TRAN_IDX > 0 THEN
      PKG_APOST_INTERFACE.SP_POST_SODEOD_BATCH(PKG_ENTITY.FN_GET_ENTITY_CODE,'A',
                                                     TRAN_IDX,
                                                     0,
                                                     W_ERROR_CODE,
                                                     W_ERROR,
                                                     W_BATCH_NUM);

       IF (W_ERROR_CODE <> '0000') THEN
         W_ERROR_MSG := 'ERROR IN POST_TRANSACTION - '|| FN_GET_AUTOPOST_ERR_MSG(PKG_ENTITY.FN_GET_ENTITY_CODE);
         RAISE E_USEREXCEP;
       END IF;
       END IF;
       PKG_APOST_INTERFACE.SP_POSTING_END(PKG_ENTITY.FN_GET_ENTITY_CODE);
       V_INDEX_BY := V_CURR.NEXT(V_INDEX_BY);
       END LOOP;

      UPDATE_SUSP_DETAILS;
       */
      V_LNPRODACPM.DELETE;
      V_SUSP_DETAILS.DELETE;
      V_PROCASSETRECL.DELETE;
      V_CURR.DELETE;
   EXCEPTION
      WHEN E_USEREXCEP
      THEN
         PKG_EODSOD_FLAGS.PV_ERROR_MSG := W_ERROR_MSG;
         PKG_PB_GLOBAL.DETAIL_ERRLOG (V_GLOB_ENTITY_NUM,
                                      'E',
                                      W_ERROR_MSG,
                                      ' ',
                                      0);
         P_ERROR_MSG := W_ERROR_MSG;
      WHEN OTHERS
      THEN
         W_ERROR_MSG :=
               'Error in POSTING_PROCESS '
            || '-'
            || FACNO (V_GLOB_ENTITY_NUM, W_ACNTS_INTERNAL_ACNUM)
            || '-'
            || SUBSTR (SQLERRM, 1, 500);
         PKG_EODSOD_FLAGS.PV_ERROR_MSG := W_ERROR_MSG;
         PKG_PB_GLOBAL.DETAIL_ERRLOG (V_GLOB_ENTITY_NUM,
                                      'E',
                                      W_ERROR_MSG,
                                      ' ',
                                      0);
         P_ERROR_MSG := W_ERROR_MSG;
   END POSTING_PROCESS;

   PROCEDURE START_PROCESS (P_ENTITY_NUM   IN     NUMBER,
                            P_BRN_CODE     IN     NUMBER DEFAULT 0,
                            P_ASON_DATE    IN     DATE,
                            P_TYPE         IN     VARCHAR2,
                            P_ERROR           OUT VARCHAR2)
   IS
      L_BRN_CODE    NUMBER (6);
      V_ERROR_MSG   VARCHAR2 (2000);
      V_ASON_DATE   DATE;
   BEGIN
      V_GLOB_ENTITY_NUM := P_ENTITY_NUM;
      V_ERROR_MSG := '';
      V_TYPE := P_TYPE;
      V_ASON_DATE := P_ASON_DATE;
      L_BRN_CODE := P_BRN_CODE;

      SELECT MIG_END_DATE
        INTO W_ACC_MIG_DATE
        FROM MIG_DETAIL
       WHERE BRANCH_CODE = L_BRN_CODE;

      IF V_TYPE = 'R'
      THEN
         DELETE FROM STDNPACLS S
               WHERE     S.STDNPACLS_ENTITY_NUM = V_GLOB_ENTITY_NUM
                     AND S.STDNPACLS_ACNT_NUM IN
                            (SELECT A.ACNTS_INTERNAL_ACNUM
                               FROM STDNPACLS S1, ACNTS A
                              WHERE     A.ACNTS_ENTITY_NUM =
                                           V_GLOB_ENTITY_NUM
                                    AND S1.STDNPACLS_ENTITY_NUM =
                                           V_GLOB_ENTITY_NUM
                                    AND A.ACNTS_INTERNAL_ACNUM =
                                           S1.STDNPACLS_ACNT_NUM
                                    AND A.ACNTS_BRN_CODE = L_BRN_CODE);

         DELETE FROM STDNPACLSDTL SD
               WHERE     SD.STDNPADTL_ENTITY_NUM = V_GLOB_ENTITY_NUM
                     AND SD.STDNPADTL_ACNT_NUM IN
                            (SELECT A.ACNTS_INTERNAL_ACNUM
                               FROM STDNPACLSDTL SD1, ACNTS A
                              WHERE     A.ACNTS_ENTITY_NUM =
                                           V_GLOB_ENTITY_NUM
                                    AND SD1.STDNPADTL_ENTITY_NUM =
                                           V_GLOB_ENTITY_NUM
                                    AND A.ACNTS_INTERNAL_ACNUM =
                                           SD1.STDNPADTL_ACNT_NUM
                                    AND A.ACNTS_BRN_CODE = L_BRN_CODE);

         COMMIT;
         IDENTIFICATION_PROCESS (V_GLOB_ENTITY_NUM,
                                 V_ASON_DATE,
                                 L_BRN_CODE,
                                 0,
                                 0,
                                 V_ERROR_MSG);
      ELSE
         POSTING_PROCESS (V_GLOB_ENTITY_NUM,
                          V_ASON_DATE,
                          L_BRN_CODE,
                          0,
                          V_ERROR_MSG);
      END IF;

      P_ERROR := V_ERROR_MSG;
   END START_PROCESS;


   PROCEDURE START_BRNWISE (V_ENTITY_NUM   IN NUMBER,
                            P_BRN_CODE     IN NUMBER DEFAULT 0)
   IS
      L_BRN_CODE      NUMBER (6);
      V_PROCESS_ALL   CHAR (1) := 'N';
      W_ENTITY_CODE   NUMBER;
   BEGIN
      PKG_ENTITY.SP_SET_ENTITY_CODE (V_ENTITY_NUM);

      W_ENTITY_CODE := V_ENTITY_NUM;
      V_ASON_DATE := PKG_EODSOD_FLAGS.PV_CURRENT_DATE;
      W_USER_ID := PKG_EODSOD_FLAGS.PV_USER_ID;

      PKG_PROCESS_CHECK.INIT_PROC_BRN_WISE (W_ENTITY_CODE, P_BRN_CODE);


      FOR IDX IN 1 .. PKG_PROCESS_CHECK.V_ACNTBRN.COUNT
      LOOP
         L_BRN_CODE := PKG_PROCESS_CHECK.V_ACNTBRN (IDX).LN_BRN_CODE;
        /*
         IF L_BRN_CODE IN (26, 1024, 6064, 10090, 13094, 16063, 16089, 16170, 18093, 27094, 27144, 33167, 36137, 1115, 56275, 27086, 27151, 44263) THEN
          CONTINUE;
        END IF;
        */
         IF PKG_PROCESS_CHECK.CHK_BRN_ALREADY_PROCESSED (W_ENTITY_CODE,
                                                         L_BRN_CODE) = FALSE
         THEN
            START_PROCESS (W_ENTITY_CODE,
                           L_BRN_CODE,
                           V_ASON_DATE,
                           'R',
                           W_ERROR);
            START_PROCESS (W_ENTITY_CODE,
                           L_BRN_CODE,
                           V_ASON_DATE,
                           'P',
                           W_ERROR);
            PKG_PROCESS_CHECK.CHECK_COMMIT_ROLLBACK_STATUS (W_ENTITY_CODE);

            IF TRIM (PKG_EODSOD_FLAGS.PV_ERROR_MSG) IS NULL
            THEN
               PKG_PROCESS_CHECK.INSERT_ROW_INTO_EODSODPROCBRN (
                  W_ENTITY_CODE,
                  L_BRN_CODE);
            END IF;
         END IF;
      END LOOP;

      PKG_PROCESS_CHECK.CHECK_COMMIT_ROLLBACK_STATUS (W_ENTITY_CODE);
   END START_BRNWISE;
BEGIN
   NULL;
END PKG_LN_RECLASSIFY;
/
