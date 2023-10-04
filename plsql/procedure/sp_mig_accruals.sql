CREATE OR REPLACE PROCEDURE SP_MIG_ACCRUALS (
   P_BRANCH_CODE       NUMBER,
   P_ERR_MSG       OUT VARCHAR2)
IS
   /*  

    List of  Table/s Referred

      1. MIG_DEPIA
      2. TEMP_SBCAIA
      3. TEMP_LOANIA



      List of Tables Updated


      1. DEPIA
      2. SBCAIA
      3. SBCAIABRK
      4. LOANIA
      5. LOANIADTL
      6. LOANIAMRR
      7. LOANIAMRRDTL

   */

   W_CURR_DATE     DATE;
   W_ENTD_BY       VARCHAR2 (8) := 'MIG';
   W_CLIENT_NUM    VARCHAR2 (14);
   W_ACNT_NUMBER   NUMBER (14);

   W_SRC_KEY       VARCHAR2 (1000);
   W_ER_CODE       VARCHAR2 (5);
   W_ER_DESC       VARCHAR2 (1000);
   W_ENTITY_NUM    NUMBER (3) := GET_OTN.ENTITY_NUMBER;

   W_SQL           VARCHAR2 (1000);

   PROCEDURE POST_ERR_LOG (W_SOURCE_KEY    VARCHAR2,
                           W_START_DATE    DATE,
                           W_ERROR_CODE    VARCHAR2,
                           W_ERROR         VARCHAR2)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      INSERT INTO MIG_ERRORLOG (MIG_ERR_SRC_KEY,
                                MIG_ERR_DTL_SL,
                                MIG_ERR_MIGDATE,
                                MIG_ERR_CODE,
                                MIG_ERR_DESC)
           VALUES (W_SOURCE_KEY,
                   (SELECT NVL (MAX (MIG_ERR_DTL_SL), 0) + 1
                      FROM MIG_ERRORLOG P
                     WHERE P.MIG_ERR_MIGDATE = W_START_DATE),
                   W_START_DATE,
                   W_ERROR_CODE,
                   W_ERROR);

      COMMIT;
   END POST_ERR_LOG;

   PROCEDURE FETCH_ACNUM (P_OLDAC            VARCHAR2,
                          O_ACNUM        OUT NUMBER,
                          PUT_ERR            VARCHAR2,
                          PUT_ERR_DESC       VARCHAR2)
   IS
   BEGIN
      EXECUTE IMMEDIATE 'SELECT I.IACLINK_INTERNAL_ACNUM , I.IACLINK_CIF_NUMBER
  FROM IACLINK I
 WHERE IACLINK_ENTITY_NUM = :1 
   and I.IACLINK_BRN_CODE = :2
   AND I.IACLINK_ACTUAL_ACNUM = :3'
         INTO O_ACNUM, W_CLIENT_NUM
         USING W_ENTITY_NUM, P_BRANCH_CODE, P_OLDAC;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         W_ER_CODE := PUT_ERR;
         W_ER_DESC := PUT_ERR_DESC || SQLERRM;
         W_SRC_KEY := P_BRANCH_CODE || '-' || P_OLDAC;
         POST_ERR_LOG (W_SRC_KEY,
                       W_CURR_DATE,
                       W_ER_CODE,
                       W_ER_DESC);
         O_ACNUM := NULL;
   END FETCH_ACNUM;
BEGIN
   P_ERR_MSG := '0';

   SELECT MN_CURR_BUSINESS_DATE INTO W_CURR_DATE FROM MAINCONT;

   W_SQL := 'TRUNCATE TABLE DEPIA';

   EXECUTE IMMEDIATE W_SQL;

   W_SQL := 'TRUNCATE TABLE SBCAIA';

   EXECUTE IMMEDIATE W_SQL;

   W_SQL := 'TRUNCATE TABLE SBCAIABRK';

   EXECUTE IMMEDIATE W_SQL;

   W_SQL := 'TRUNCATE TABLE LOANIAMRR';

   EXECUTE IMMEDIATE W_SQL;

   W_SQL := 'TRUNCATE TABLE LOANIAMRRDTL';

   EXECUTE IMMEDIATE W_SQL;



   UPDATE MIG_DEPIA D
      SET D.DEPIA_CONTRACT_NUM = 0
    WHERE D.DEPIA_ACCOUNTNUM IN (SELECT P.MIGDEP_DEP_AC_NUM
                                   FROM MIG_PBDCONTRACT P
                                  WHERE P.MIGDEP_CONT_NUM = 0);

   COMMIT;



   UPDATE TEMP_SBCAIA S
      SET S.SBCAIA_INT_ACCR_UPTO_DT = S.SBCAIA_UPTO_DATE;

   COMMIT;

   UPDATE TEMP_LOANIA
      SET TEMP_LOANIA.LOANIA_INT_ON_AMT =
             (TEMP_LOANIA.LOANIA_INT_ON_AMT * -1)
    WHERE LOANIA_INT_ON_AMT > 0;

   COMMIT;



   FOR IDX IN (SELECT DEPIA_BRN_CODE,
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
                      DEPIA_PREV_YR_INT_ACCR
                 FROM MIG_DEPIA)
   LOOP
     <<INSERT_DEPIA>>
      FETCH_ACNUM (IDX.DEPIA_ACCOUNTNUM,
                   W_ACNT_NUMBER,
                   'ACCRUALS',
                   'MIG_DEPIA GETOTN');

      BEGIN
         INSERT INTO DEPIA (DEPIA_ENTITY_NUM,
                            DEPIA_BRN_CODE,
                            DEPIA_INTERNAL_ACNUM,
                            DEPIA_CONTRACT_NUM,
                            DEPIA_AUTO_ROLLOVER_SL,
                            DEPIA_DATE_OF_ENTRY,
                            DEPIA_DAY_SL,
                            DEPIA_AC_INT_ACCR_AMT,
                            DEPIA_INT_ACCR_DB_CR,
                            DEPIA_BC_INT_ACCR_AMT,
                            DEPIA_AC_FULL_INT_ACCR_AMT,
                            DEPIA_BC_FULL_INT_ACCR_AMT,
                            DEPIA_AC_PREV_INT_ACCR_AMT,
                            DEPIA_BC_PREV_INT_ACCR_AMT,
                            DEPIA_ACCR_FROM_DATE,
                            DEPIA_ACCR_UPTO_DATE,
                            DEPIA_ENTRY_TYPE,
                            DEPIA_ACCR_POSTED_BY,
                            DEPIA_ACCR_POSTED_ON,
                            DEPIA_SOURCE_TABLE,
                            DEPIA_PREV_YR_INT_ACCR)
              VALUES (
                        W_ENTITY_NUM,
                        IDX.DEPIA_BRN_CODE,
                        W_ACNT_NUMBER,
                        IDX.DEPIA_CONTRACT_NUM,
                        0,
                        IDX.DEPIA_DATE_OF_ENTRY,
                        (SELECT NVL (MAX (DEPIA_DAY_SL), 0) + 1
                           FROM DEPIA
                          WHERE     DEPIA_ENTITY_NUM = W_ENTITY_NUM
                                AND DEPIA_BRN_CODE = IDX.DEPIA_BRN_CODE
                                AND DEPIA_INTERNAL_ACNUM = W_ACNT_NUMBER
                                AND DEPIA_CONTRACT_NUM =
                                       IDX.DEPIA_CONTRACT_NUM
                                AND DEPIA_DATE_OF_ENTRY =
                                       IDX.DEPIA_DATE_OF_ENTRY),
                        IDX.DEPIA_AC_INT_ACCR_AMT,
                        SUBSTR (TRIM (IDX.DEPIA_INT_ACCR_DB_CR), 1, 1),
                        IDX.DEPIA_BC_INT_ACCR_AMT,
                        0.00,
                        0.00,
                        0.00,
                        0.00,
                        (SELECT PBDCONT_DEP_OPEN_DATE
                           FROM PBDCONTRACT P
                          WHERE P.PBDCONT_DEP_AC_NUM = W_ACNT_NUMBER
                                AND P.PBDCONT_BRN_CODE = IDX.DEPIA_BRN_CODE),
                        IDX.DEPIA_ACCR_UPTO_DATE,
                        IDX.DEPIA_ENTRY_TYPE,
                        W_ENTD_BY,
                        W_CURR_DATE,
                        IDX.DEPIA_ENTRY_TYPE,
                        IDX.DEPIA_PREV_YR_INT_ACCR);
      EXCEPTION
         WHEN OTHERS
         THEN
            W_ER_CODE := 'DEPIA';
            W_ER_DESC := 'SP_ACCRUALS-INSERT-DEPIA' || SQLERRM;
            W_SRC_KEY :=
                  P_BRANCH_CODE
               || '-'
               || 'OLD_AC_NUMBER'
               || IDX.DEPIA_ACCOUNTNUM;

            POST_ERR_LOG (W_SRC_KEY,
                          W_CURR_DATE,
                          W_ER_CODE,
                          W_ER_DESC);
      END INSERT_DEPIA;
   END LOOP;

   FOR IDX IN (SELECT SBCAIA_BRN_CODE,
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
                      SBCAIA_INT_RATE
                 FROM TEMP_SBCAIA
                WHERE SBCAIA_BRN_CODE = P_BRANCH_CODE)
   LOOP
     <<INSERT_SBCAIA>>
      FETCH_ACNUM (IDX.SBCAIA_INTERNAL_ACNUM,
                   W_ACNT_NUMBER,
                   'SBCAIA',
                   'TEMP_SBCAIA GETOTN');

      BEGIN
         INSERT INTO sbcaia (SBCAIA_ENTITY_NUM,
                             SBCAIA_BRN_CODE,
                             SBCAIA_INTERNAL_ACNUM,
                             SBCAIA_CR_DB_INT_FLG,
                             SBCAIA_DATE_OF_ENTRY,
                             SBCAIA_DAY_SL,
                             SBCAIA_PREV_INT_ACCR_UPTO_DT,
                             SBCAIA_INT_ACCR_UPTO_DT,
                             SBCAIA_TOT_PREV_INT_AMT,
                             SBCAIA_TOT_NEW_INT_AMT,
                             SBCAIA_AC_INT_ACCR_AMT,
                             SBCAIA_BC_INT_ACCR_AMT,
                             SBCAIA_BC_CONV_RATE,
                             SBCAIA_INT_ACCR_DB_CR,
                             SBCAIA_FROM_DATE,
                             SBCAIA_UPTO_DATE,
                             SBCAIA_ACCR_POSTED_BY,
                             SBCAIA_ACCR_POSTED_ON,
                             SBCAIA_LAST_MOD_BY,
                             SBCAIA_LAST_MOD_ON,
                             SBCAIA_INT_RATE,
                             SBCAIA_SOURCE_TABLE,
                             SBCAIA_SOURCE_KEY,
                             SBCAIA_AC_INT_ACTUAL_ACCR_AMT,
                             SBCAIA_BC_INT_ACTUAL_ACCR_AMT)
              VALUES (
                        W_ENTITY_NUM,
                        IDX.SBCAIA_BRN_CODE,
                        W_ACNT_NUMBER,
                        IDX.SBCAIA_CR_DB_INT_FLG,
                        IDX.sbcaia_date_of_entry,                         -- 1
                        (SELECT NVL (MAX (SBCAIA_DAY_SL), 0) + 1
                           FROM SBCAIA
                          WHERE     SBCAIA_ENTITY_NUM = W_ENTITY_NUM
                                AND SBCAIA_BRN_CODE = IDX.SBCAIA_BRN_CODE
                                AND SBCAIA_INTERNAL_ACNUM = W_ACNT_NUMBER
                                AND SBCAIA_CR_DB_INT_FLG =
                                       IDX.SBCAIA_CR_DB_INT_FLG
                                AND SBCAIA_DATE_OF_ENTRY =
                                       IDX.SBCAIA_DATE_OF_ENTRY),
                        NULL,
                        IDX.sbcaia_int_accr_upto_dt,
                        0,
                        0,                                                -- 2
                        IDX.sbcaia_ac_int_accr_amt,
                        IDX.sbcaia_bc_int_accr_amt,
                        IDX.sbcaia_bc_conv_rate,
                        IDX.sbcaia_cr_db_int_flg,
                        IDX.sbcaia_from_date,                             -- 3
                        IDX.sbcaia_upto_date,
                        W_ENTD_BY,
                        W_CURR_DATE,
                        NULL,
                        NULL,                                              --4
                        IDX.SBCAIA_INT_RATE,
                        'TEMP_SBCAIA',
                        'MIG',
                        IDX.SBCAIA_AC_INT_ACCR_AMT,
                        IDX.sbcaia_bc_int_accr_amt);
      EXCEPTION
         WHEN OTHERS
         THEN
            W_ER_CODE := 'SBCAIA';
            W_ER_DESC := 'SP_ACCRUALS-INSERT-SBCAIA' || SQLERRM;
            W_SRC_KEY :=
                  P_BRANCH_CODE
               || '-'
               || 'OLD_AC_NUMBER'
               || IDX.SBCAIA_INTERNAL_ACNUM;

            POST_ERR_LOG (W_SRC_KEY,
                          W_CURR_DATE,
                          W_ER_CODE,
                          W_ER_DESC);
      END INSERT_SBCAIA;

     <<INSERT_SBCAIABRK>>
      BEGIN
         INSERT INTO SBCAIABRK (SBCAIBRK_ENTITY_NUM,
                                SBCAIBRK_BRN_CODE,
                                SBCAIBRK_INTERNAL_ACNUM,
                                SBCAIBRK_CR_DB_INT_FLG,
                                SBCAIBRK_DATE_OF_ENTRY,
                                SBCAIBRK_DAY_SL,
                                SBCAIBRK_BREAKUP_DATE,
                                SBCAIBRK_PREV_BALANCE,
                                SBCAIBRK_NEW_BALANCE,
                                SBCAIBRK_PREV_DB_INT,
                                SBCAIBRK_PREV_CR_INT,
                                SBCAIBRK_NEW_DB_INT,
                                SBCAIBRK_NEW_CR_INT)
              VALUES (
                        W_ENTITY_NUM,
                        IDX.SBCAIA_BRN_CODE,
                        W_ACNT_NUMBER,
                        IDX.SBCAIA_CR_DB_INT_FLG,
                        IDX.sbcaia_date_of_entry,                         -- 1
                        (SELECT NVL (MAX (SBCAIBRK_DAY_SL), 0) + 1
                           FROM SBCAIABRK
                          WHERE     SBCAIBRK_ENTITY_NUM = W_ENTITY_NUM
                                AND SBCAIBRK_BRN_CODE = IDX.SBCAIA_BRN_CODE
                                AND SBCAIBRK_INTERNAL_ACNUM = W_ACNT_NUMBER
                                AND SBCAIBRK_CR_DB_INT_FLG =
                                       IDX.SBCAIA_CR_DB_INT_FLG
                                AND SBCAIBRK_DATE_OF_ENTRY =
                                       IDX.SBCAIA_DATE_OF_ENTRY
                                AND SBCAIBRK_BREAKUP_DATE =
                                       IDX.SBCAIA_DATE_OF_ENTRY),
                        IDX.SBCAIA_DATE_OF_ENTRY,
                        0,
                        0,
                        0,
                        0,
                        DECODE (IDX.sbcaia_cr_db_int_flg,
                                'D', IDX.sbcaia_ac_int_accr_amt,
                                0),
                        DECODE (IDX.sbcaia_cr_db_int_flg,
                                'C', IDX.sbcaia_ac_int_accr_amt,
                                0));
      EXCEPTION
         WHEN OTHERS
         THEN
            W_ER_CODE := 'SBCAIABRK';
            W_ER_DESC := 'SP_ACCRUALS-INSERT-SBCAIABRK' || SQLERRM;
            W_SRC_KEY :=
                  P_BRANCH_CODE
               || '-'
               || 'OLD_AC_NUMBER'
               || IDX.SBCAIA_INTERNAL_ACNUM;

            POST_ERR_LOG (W_SRC_KEY,
                          W_CURR_DATE,
                          W_ER_CODE,
                          W_ER_DESC);
      END INSERT_SBCAIABRK;
   END LOOP;

   -- Loan Interest Accrual
   -- Amount columns has to be verified for signs

   FOR IDX IN (SELECT LOANIA_BRN_CODE,
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
                      LOANIA_NPA_AMT
                 FROM TEMP_LOANIA)
   LOOP
     <<INSERT_LOANIAMRR>>
      FETCH_ACNUM (IDX.LOANIA_ACNT_NUM,
                   W_ACNT_NUMBER,
                   'DEP1',
                   'MIG_DEPOSITS GETOTN');

      BEGIN
         INSERT INTO LOANIAMRR (LOANIAMRR_ENTITY_NUM,
                                LOANIAMRR_BRN_CODE,
                                LOANIAMRR_ACNT_NUM,
                                LOANIAMRR_VALUE_DATE,
                                LOANIAMRR_ACCRUAL_DATE,
                                LOANIAMRR_ACNT_CURR,
                                LOANIAMRR_ACNT_BAL,
                                LOANIAMRR_TOTAL_NEW_INT_AMT,
                                LOANIAMRR_INT_RATE,
                                LOANIAMRR_INT_AMT,
                                LOANIAMRR_INT_AMT_RND)
              VALUES (W_ENTITY_NUM,
                      IDX.LOANIA_BRN_CODE,
                      W_ACNT_NUMBER,
                      IDX.LOANIA_VALUE_DATE,
                      IDX.LOANIA_ACCRUAL_DATE,
                      IDX.LOANIA_ACNT_CURR,
                      IDX.LOANIA_ACNT_BAL,
                      IDX.LOANIA_INT_ON_AMT,
                      IDX.LOANIA_INT_RATE,
                      IDX.LOANIA_INT_ON_AMT,
                      ROUND (IDX.LOANIA_INT_ON_AMT, 2));
      EXCEPTION
         WHEN OTHERS
         THEN
            W_ER_CODE := 'LOANIAMRR';
            W_ER_DESC := 'SP_ACCRUALS-INSERT-LOANIAMRR' || SQLERRM;
            W_SRC_KEY :=
               P_BRANCH_CODE || '-' || 'OLD_AC_NUMBER' || IDX.LOANIA_ACNT_NUM;

            POST_ERR_LOG (W_SRC_KEY,
                          W_CURR_DATE,
                          W_ER_CODE,
                          W_ER_DESC);
      END INSERT_LOANIAMRR;

     <<INSERT_LOANIAMRRDTL>>
      BEGIN
         INSERT INTO LOANIAMRRDTL (LOANIAMRRDTL_ENTITY_NUM,
                                   LOANIAMRRDTL_BRN_CODE,
                                   LOANIAMRRDTL_ACNT_NUM,
                                   LOANIAMRRDTL_VALUE_DATE,
                                   LOANIAMRRDTL_ACCRUAL_DATE,
                                   LOANIAMRRDTL_SL_NUM,
                                   LOANIAMRRDTL_INT_RATE,
                                   LOANIAMRRDTL_UPTO_AMT,
                                   LOANIAMRRDTL_INT_AMT,
                                   LOANIAMRRDTL_INT_AMT_RND)
              VALUES (1,
                      IDX.LOANIA_BRN_CODE,
                      W_ACNT_NUMBER,
                      IDX.LOANIA_VALUE_DATE,
                      IDX.LOANIA_ACCRUAL_DATE,
                      1,
                      IDX.LOANIA_INT_RATE,
                      IDX.LOANIA_INT_ON_AMT,
                      IDX.LOANIA_INT_ON_AMT,
                      ROUND (IDX.LOANIA_INT_ON_AMT, 2));
      EXCEPTION
         WHEN OTHERS
         THEN
            W_ER_CODE := 'LOANIAMRRDTL';
            W_ER_DESC := 'SP_ACCRUALS-INSERT-LOANIAMRRDTL' || SQLERRM;
            W_SRC_KEY :=
               P_BRANCH_CODE || '-' || 'OLD_AC_NUMBER' || IDX.LOANIA_ACNT_NUM;

            POST_ERR_LOG (W_SRC_KEY,
                          W_CURR_DATE,
                          W_ER_CODE,
                          W_ER_DESC);
      END INSERT_LOANIAMRRDTL;
   END LOOP;

   COMMIT;
EXCEPTION
   WHEN OTHERS
   THEN
      P_ERR_MSG := SQLERRM;
      ROLLBACK;
/*
TRUNCATE TABLE  DEPIA;
TRUNCATE TABLE  SBCAIA;
TRUNCATE TABLE  SBCAIABRK;
TRUNCATE TABLE  LOANIA;
TRUNCATE TABLE  LOANIADTL;
*/
END;

/
