/*<TOAD_FILE_CHUNK>*/
/* Formatted on 12/18/2022 12:35:49 PM (QP5 v5.388) */
CREATE OR REPLACE PROCEDURE SP_GEN_CL_DATA_SERP (P_FROM_BRN   NUMBER,
                                                 P_TO_BRN     NUMBER)
IS
    V_CBD           DATE;
    P_ERROR_MSG     VARCHAR2 (1000);
    V_DUMMY_COUNT   NUMBER;
    V_ASON_DATE     DATE;
    V_CURR_DATE     DATE;
    P_FROM_DATE     DATE := '01-DEC-2022';
    P_TO_DATE       DATE := '31-DEC-2022';
BEGIN
    FOR IDX
        IN (  SELECT *
               FROM (  SELECT BRANCH_CODE, ROWNUM BRANCH_SL
                         FROM MIG_DETAIL
                     ORDER BY BRANCH_CODE)
              WHERE     BRANCH_SL BETWEEN P_FROM_BRN AND P_TO_BRN
                    AND BRANCH_CODE NOT IN (SELECT BRCODE FROM CL_SERP_SOFT)
           ORDER BY BRANCH_CODE)
    LOOP
        INSERT INTO /*+ PARALLEL( 16) */CL_SERP_SOFT
            SELECT /*+ PARALLEL( 16) */
                   CASE
                       WHEN    SUBSTR (CL_FORM_NO, 1, 2)
                            || '-'
                            || SUBSTR (CL_FORM_NO, 3, 1) =
                            'CL-7'
                       THEN
                           'CL-6'
                       ELSE
                              SUBSTR (CL_FORM_NO, 1, 2)
                           || '-'
                           || SUBSTR (CL_FORM_NO, 3, 1)
                   END
                       CLHEAD,
                   BRANCH_CODE,
                   TMP_ACCNT_NAME
                       ACNAME,
                   (SELECT A.ACNTS_AC_TYPE
                      FROM ACNTS A
                     WHERE     A.ACNTS_ENTITY_NUM = 1
                           AND A.ACNTS_INTERNAL_ACNUM =
                               (SELECT IACLINK_INTERNAL_ACNUM
                                 FROM IACLINK
                                WHERE     IACLINK_ACTUAL_ACNUM =
                                          MIS_TAB.ACC_NO
                                      AND IACLINK_ENTITY_NUM = 1))
                       NATURE_OF_LOAN,
                   CASE
                       WHEN LENGTH (CL_FORM_NO) = 3
                       THEN
                           CASE
                               WHEN    SUBSTR (CL_FORM_NO, 1, 2)
                                    || '-'
                                    || SUBSTR (CL_FORM_NO, 3, 1) =
                                    'CL-7'
                               THEN
                                   'STAFF'
                               ELSE
                                      SUBSTR (CL_FORM_NO, 1, 2)
                                   || '-'
                                   || SUBSTR (CL_FORM_NO, 3, 1)
                           END
                       WHEN LENGTH (CL_FORM_NO) = 4
                       THEN
                              SUBSTR (CL_FORM_NO, 1, 2)
                           || '-'
                           || SUBSTR (CL_FORM_NO, 3, 1)
                           || '('
                           || CASE
                                  WHEN SUBSTR (CL_FORM_NO, 4) = 1
                                  THEN
                                      'i' || ')'
                                  WHEN SUBSTR (CL_FORM_NO, 4) = 2
                                  THEN
                                      'ii' || ')'
                                  WHEN SUBSTR (CL_FORM_NO, 4) = 3
                                  THEN
                                      'iii' || ')'
                                  WHEN SUBSTR (CL_FORM_NO, 4) = 4
                                  THEN
                                      'iv' || ')'
                                  WHEN SUBSTR (CL_FORM_NO, 4) = 5
                                  THEN
                                      'v' || ')'
                                  WHEN SUBSTR (CL_FORM_NO, 4) = 6
                                  THEN
                                      'vi' || ')'
                              END
                   END
                       ENTRY_SL,
                   ACC_NO
                       ACNO,
                   TO_CHAR (TO_DATE (FIRST_SANC_DATE, 'DD-MM-RRRR'))
                       SANC_DT,
                   TO_CHAR (TO_DATE (RENW_DATE, 'DD-MM-RRRR'))
                       RENEWAL_DT,
                   RENW_TIME
                       RENEWAL_NO,
                   SANC_RESCHE_AMT
                       SANC_AMT,
                   FIRST_SANC_LIMIT
                       RENEWAL_AMT,
                   TMP_OS_AMT
                       BAL_OUT,
                   EXPIRY_DATE
                       EXP_DT,
                   TMP_PRD_OF_ARREARS
                       POA1,
                   (SELECT FN_GET_PAID_AMT (
                               1,
                               (SELECT IACLINK_INTERNAL_ACNUM
                                 FROM iaclink
                                WHERE     IACLINK_ENTITY_NUM = 1
                                      AND IACLINK_ACTUAL_ACNUM =
                                          MIS_TAB.ACC_NO),
                               P_TO_DATE)
                     FROM DUAL)
                       AMT_PAID,
                   NO_OF_INSTALLMENT
                       NO_INT,
                   TMP_PRD_OF_ARREARS
                       POA,
                   TMP_OBJ_CRITERIA
                       OC,
                   TMP_QA_JUDG
                       QJ,
                   TMP_CLASS_STATUS
                       CL_STATUS,
                   TMP_CLASS_BASIS
                       BASIS_OF_CL,
                   TMP_SD_AMT
                       OUT_AMT_STD,
                   TMP_SM_AMT
                       OUT_AMT_SMA,
                   TMP_SS_AMT
                       OUT_AMT_SS,
                   TMP_DF_AMT
                       OUT_AMT_DF,
                   TMP_BL_AMT
                       OUT_AMT_BL,
                   TMP_DF_AMT
                       OUT_AMT_DEFLTR,
                   TMP_SD_SUSP_AMT
                       SUSP_AMT_UC,
                   TMP_SM_SUSP_AMT
                       SUSP_AMT_SMA,
                   TMP_CLASS_SUSP_AMT
                       SUSP_AMT_CLAC,
                   TMP_TOTAL_SUSP_AMT
                       TOTAL_SUSP,
                   NO_OF_INSTALLMENT
                       SIZEE,
                   REPAY_FREQ
                       FREQUENCY,
                   INT_SUSP
                       INT_SUSP,
                   TMP_SEC_VALUE
                       VAL_OF_SECURITY,
                   TMP_SM_PROV_BASE
                       BASE_SMA,
                   TMP_SS_PROV_BASE
                       BASE_SS,
                   TMP_DF_PROV_BASE
                       BASE_DF,
                   TMP_BL_PROV_BASE
                       BASE_BL,
                   TMP_REMARKS
                       REMARKS,
                   NID_NO
                       NID,
                   TO_CHAR (P_TO_DATE, 'DDMM')
                       RPT_QTR,
                   NULL
                       ENTRYDT,
                   NULL
                       USER_ID,
                   0
                       AMT_PROB_REQ,
                   'P'
                       TRANSTATS,
                   NULL
                       BASE_SMA1,
                   0
                       BASE_SS1,
                   0
                       BASE_DF1,
                   0
                       BASE_BL1,
                   NULL
                       TRANNO,
                   TMP_DEF_AMT
                       OUT_AMT_DEFLTR1,
                   0
                       AMT_BASE_EXIT,
                   PROD_CODE
                       PRODUCT_CODE,
                   LOAN_CODE,
                   SME_CODE
                       SME_ID,
                   0
                       ACTUAL_PROV,
                   BORROWER_FIS_CODE
                       FIS_CODE,
                   SEGMENT_CODE
                       SECTOR_CODE,
                   SEC_CODE
                       SECURITY_CODE,
                   0
                       AUTO_MANUAL
              FROM TABLE (PKG_PARALLEL_CL.GET_LOAN_DETAILS_CL2 (
                              'CL',
                              1,
                              IDX.BRANCH_CODE,
                              P_TO_DATE,
                              1,
                              'CL%')) CL4,
                   (SELECT *
                      FROM TABLE (PKG_MIS_STATS.GET_BRANCH_WISE (
                                      1,
                                      IDX.BRANCH_CODE,
                                      P_FROM_DATE,
                                      P_TO_DATE))) MIS_TAB
             WHERE CL4.TMP_ACTUAL_ACNUM = MIS_TAB.ACC_NO;

        COMMIT;
    END LOOP;
END SP_GEN_CL_DATA_SERP;
/

/*<TOAD_FILE_CHUNK>*/
CREATE OR REPLACE PROCEDURE SBLPROD.SP_GEN_CL_SERP_THREAD AS

  LN_DUMMY NUMBER;

BEGIN

  DBMS_JOB.SUBMIT(LN_DUMMY, 'begin SP_GEN_CL_DATA_SERP(1,100); end;',INSTANCE=>1);

  DBMS_JOB.SUBMIT(LN_DUMMY, 'begin SP_GEN_CL_DATA_SERP(101,200); end;',INSTANCE=>1);

  DBMS_JOB.SUBMIT(LN_DUMMY, 'begin SP_GEN_CL_DATA_SERP(201,300); end;',INSTANCE=>1);

  DBMS_JOB.SUBMIT(LN_DUMMY, 'begin SP_GEN_CL_DATA_SERP(301,400); end;',INSTANCE=>1);

  DBMS_JOB.SUBMIT(LN_DUMMY, 'begin SP_GEN_CL_DATA_SERP(401,500); end;',INSTANCE=>1);

  DBMS_JOB.SUBMIT(LN_DUMMY, 'begin SP_GEN_CL_DATA_SERP(501,600); end;',INSTANCE=>1);

  DBMS_JOB.SUBMIT(LN_DUMMY, 'begin SP_GEN_CL_DATA_SERP(601,700); end;',INSTANCE=>1);

  DBMS_JOB.SUBMIT(LN_DUMMY, 'begin SP_GEN_CL_DATA_SERP(701,800); end;',INSTANCE=>1);

  DBMS_JOB.SUBMIT(LN_DUMMY, 'begin SP_GEN_CL_DATA_SERP(801,900); end;',INSTANCE=>1);

  DBMS_JOB.SUBMIT(LN_DUMMY, 'begin SP_GEN_CL_DATA_SERP(901,1000); end;',INSTANCE=>1);

  DBMS_JOB.SUBMIT(LN_DUMMY, 'begin SP_GEN_CL_DATA_SERP(1001,1100); end;',INSTANCE=>1);

  DBMS_JOB.SUBMIT(LN_DUMMY, 'begin SP_GEN_CL_DATA_SERP(1101,1200); end;',INSTANCE=>1);

  DBMS_JOB.SUBMIT(LN_DUMMY, 'begin SP_GEN_CL_DATA_SERP(1201,1300); end;',INSTANCE=>1); 
   DBMS_JOB.SUBMIT(LN_DUMMY, 'begin SP_GEN_CL_DATA_SERP(1301,1400); end;',INSTANCE=>1); 

  COMMIT;

END SP_GEN_CL_SERP_THREAD;
/

/*<TOAD_FILE_CHUNK>*/
CREATE OR REPLACE PROCEDURE SP_GEN_CL1_DATA_SERP (P_FROM_BRN   NUMBER,
                                                 P_TO_BRN     NUMBER)
IS
    V_CBD           DATE;
    P_ERROR_MSG     VARCHAR2 (1000);
    V_DUMMY_COUNT   NUMBER;
    V_ASON_DATE     DATE;
    V_CURR_DATE     DATE;
    P_FROM_DATE     DATE := '01-DEC-2022';
    P_TO_DATE       DATE := '31-DEC-2022';
BEGIN
    FOR IDX
        IN (  SELECT *
               FROM (  SELECT BRANCH_CODE, ROWNUM BRANCH_SL
                         FROM MIG_DETAIL
                     ORDER BY BRANCH_CODE)
              WHERE     BRANCH_SL BETWEEN P_FROM_BRN AND P_TO_BRN
                    AND BRANCH_CODE NOT IN (SELECT BRCODE FROM cl_full_serp)
           ORDER BY BRANCH_CODE)
    LOOP
        INSERT INTO cl_full_serp
            SELECT CLHEAD,
                   BRCODE,
                   ACNAME,
                   NATURE_OF_LOAN                        NATURE_OF_LOAN,
                   ENTRY_SL                              ENTRY_SL,
                   ACNO,
                   TO_DATE (SANC_DT, 'DD/MM/RRRR')       SANC_DATE,
                   TO_DATE (RENEWAL_DT, 'DD/MM/RRRR')    LAST_RENEWAL_DATE,
                   RENEWAL_NO                            RENEWAL_NO,
                   SANC_AMT                              SANC_AMOUNT,
                   RENEWAL_AMT                           LAST_RENEWAL_AMT,
                   ACBAL                                 BAL_OUT,
                   TO_DATE (EXP_DT, 'DD/MM/RRRR')        EXP_DATE,
                   POA1                                  POA1,
                   AMT_PAID                              AMT_PAID,
                   NO_INT                                NOI,
                   POA                                   POA,
                   OC,
                   QJ,
                   CASE
                       WHEN OC = QJ THEN OC
                       WHEN OC <> QJ THEN QJ
                       ELSE NULL
                   END                                   CL_STATUS,
                   BASIS_OF_CL,
                   CASE
                       WHEN ASSETCLSH_ASSET_CODE = 'UC' THEN ACBAL
                       ELSE 0
                   END                                   OUT_AMT_STD,
                   CASE
                       WHEN ASSETCLSH_ASSET_CODE = 'SM' THEN ACBAL
                       ELSE 0
                   END                                   OUT_AMT_SMA,
                   CASE
                       WHEN ASSETCLSH_ASSET_CODE = 'SS' THEN ACBAL
                       ELSE 0
                   END                                   OUT_AMT_SS,
                   CASE
                       WHEN ASSETCLSH_ASSET_CODE = 'DF' THEN ACBAL
                       ELSE 0
                   END                                   OUT_AMT_DF,
                   CASE
                       WHEN ASSETCLSH_ASSET_CODE = 'BL' THEN ACBAL
                       ELSE 0
                   END                                   OUT_AMT_BL,
                   OUT_AMT_DEFLTR,
                   CASE
                       WHEN ASSETCLSH_ASSET_CODE = 'UC' THEN INT_SUSPENSE_AMT
                       ELSE 0
                   END                                   SUSP_AMT_UC,
                   CASE
                       WHEN ASSETCLSH_ASSET_CODE = 'SM' THEN INT_SUSPENSE_AMT
                       ELSE 0
                   END                                   SUSP_AMT_SMA,
                   CASE
                       WHEN ASSETCLSH_ASSET_CODE NOT IN ('SM', 'UC')
                       THEN
                           INT_SUSPENSE_AMT
                       ELSE
                           0
                   END                                   SUSP_AMT_CLAC,
                   INT_SUSPENSE_AMT                      TOTAL_SUSP,
                   SIZEE                                 INST_SIZE,
                   CASE
                       WHEN FREQUENCY = 'M' THEN '1'
                       WHEN FREQUENCY = 'Q' THEN '3'
                       WHEN FREQUENCY = 'Y' THEN '12'
                       ELSE '1'
                   END                                   FREQUENCY,
                   INT_SUSP                              INTT_SUSP,
                   SECURITY_AMOUNT                       VAL_OF_SECURITY,
                   BASE_SMA,
                   BASE_SS,
                   BASE_DF,
                   BASE_BL,
                   REMARKS,
                   NID,
                   RPT_QTR                               RPT_QTR,
                   0                                     ENTRYDT,
                   0                                     USER_ID,
                   CASE
                       WHEN SME_ID IN (91, 99) THEN 'OTHERS'
                       WHEN SME_ID IN ('11', '12', '13') THEN 'CMSME-S'
                       WHEN SME_ID IN ('21', '22', '23') THEN 'SME'
                       WHEN SME_ID IN ('31', '32', '33') THEN 'CMSME-M'
                       WHEN SME_ID = '43' THEN 'CMSME-C'
                   END                                   SME_ID,
                   BC_PROV_AMT                                    AMT_PROB_REQ,
                   FIS_CODE,
                   SECTOR_CODE,
                   SECURITY_CODE,
                   0                                     AUTO_MANUAL
              FROM (SELECT /*+ PARALLEL( 24) */
                           CL_SERP_SOFT.*, IACLINK_INTERNAL_ACNUM
                      FROM CL_SERP_SOFT, IACLINK
                     WHERE     IACLINK_ENTITY_NUM = 1
                           AND IACLINK_ACTUAL_ACNUM = ACNO
                           AND IACLINK_BRN_CODE = idx.BRANCH_CODE) A
                   LEFT JOIN CL_TMP_DATA B
                       ON (    B.ACNTS_INTERNAL_ACNUM =
                               A.IACLINK_INTERNAL_ACNUM
                           AND ACNTS_BRN_CODE = idx.BRANCH_CODE
                           AND ASON_DATE = '31-DEC-2022');

        COMMIT;
    END LOOP;
END;

