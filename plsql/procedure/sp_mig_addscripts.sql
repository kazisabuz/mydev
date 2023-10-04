CREATE OR REPLACE PROCEDURE SP_MIG_ADDSCRIPTS (
   P_BRANCH_CODE       NUMBER,
   P_ERR_MSG       OUT VARCHAR2)
IS
   /*
      Author: Ramesh Mullamuri
      Date  : 16-May-2013

      List of  Table/s Referred

      1. MIG_MAXBAL
      2. MIG_AVGBAL
      3. MIG_MINBAL


      List of Tables Updated


      1. ACBALASONHIST_MAX
      2. ACBALASONHIST_MIN
      3. ACBALASONHIST_AVGBAL

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
   --   PRAGMA AUTONOMOUS_TRANSACTION;
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
      EXECUTE IMMEDIATE 'SELECT ACNTOTN_INTERNAL_ACNUM,acnts_client_num
   FROM ACNTOTN,acnts WHERE ACNTOTN_ENTITY_NUM=ACNTS_ENTITY_NUM and ACNTOTN_ENTITY_NUM=:1 
   and acntotn.acntotn_internal_acnum=acnts.acnts_internal_acnum and
     ACNTOTN_OLD_ACNT_BRN =:2 AND ACNTOTN.ACNTOTN_OLD_ACNT_NUM =:3 '
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

   --SELECT INS_BASE_CURR_CODE INTO W_BASE_CURR FROM INSTALL;

   W_SQL := 'TRUNCATE TABLE ACBALASONHIST_MAX';

   EXECUTE IMMEDIATE W_SQL;

   W_SQL := 'TRUNCATE TABLE ACBALASONHIST_MIN';

   EXECUTE IMMEDIATE W_SQL;

   W_SQL := 'TRUNCATE TABLE ACBALASONHIST_AVGBAL';

   EXECUTE IMMEDIATE W_SQL;

   DELETE FROM MIG_MAXBAL M
         WHERE M.ACCOUNTNO NOT IN
                  (SELECT MIG_ACNTS.ACNTS_ACNUM FROM MIG_ACNTS);

   COMMIT;

   DELETE FROM MIG_MINBAL M
         WHERE M.ACCOUNTNO NOT IN
                  (SELECT MIG_ACNTS.ACNTS_ACNUM FROM MIG_ACNTS);

   COMMIT;

   DELETE FROM MIG_AVGBAL M
         WHERE M.ACCOUNTNO NOT IN
                  (SELECT MIG_ACNTS.ACNTS_ACNUM FROM MIG_ACNTS);

   COMMIT;

   DELETE FROM MIG_NOMREG M
         WHERE M.NOMREG_AC_NUM NOT IN
                  (SELECT MIG_ACNTS.ACNTS_ACNUM FROM MIG_ACNTS);

   COMMIT;

   FOR IDX IN (SELECT BRN_CODE,
                      ACCOUNTNO,
                      BAL_DATE,
                      AC_BALANCE,
                      BC_BALANCE
                 FROM MIG_MAXBAL
                WHERE BRN_CODE = P_BRANCH_CODE)
   LOOP
      FETCH_ACNUM (IDX.ACCOUNTNO,
                   W_ACNT_NUMBER,
                   'MAXBAL',
                   'MIG_MAXBAL GETOTN');

     <<IN_MAXBAL>>
      BEGIN
         INSERT INTO ACBALASONHIST_MAX (ACBALH_ENTITY_NUM,
                                        ACBALH_INTERNAL_ACNUM,
                                        ACBALH_ASON_DATE,
                                        ACBALH_AC_BAL,
                                        ACBALH_BC_BAL)
              VALUES (W_ENTITY_NUM,
                      W_ACNT_NUMBER,
                      IDX.BAL_DATE,
                      IDX.AC_BALANCE,
                      IDX.BC_BALANCE);
      EXCEPTION
         WHEN OTHERS
         THEN
            W_ER_CODE := 'MAXBAL';
            W_ER_DESC := 'SP_ADDSCRIPTS-INSERT-ACBALASONHIST_MAX' || SQLERRM;
            W_SRC_KEY :=
               P_BRANCH_CODE || '-' || 'OLD_AC_NUMBER' || IDX.ACCOUNTNO;

            POST_ERR_LOG (W_SRC_KEY,
                          W_CURR_DATE,
                          W_ER_CODE,
                          W_ER_DESC);
      END IN_MAXBAL;
   END LOOP;

   FOR IDX IN (SELECT BRN_CODE,
                      ACCOUNTNO,
                      BAL_DATE,
                      AC_BALANCE,
                      BC_BALANCE
                 FROM MIG_AVGBAL
                WHERE BRN_CODE = P_BRANCH_CODE)
   LOOP
      FETCH_ACNUM (IDX.ACCOUNTNO,
                   W_ACNT_NUMBER,
                   'MAXBAL',
                   'MIG_MAXBAL GETOTN');

     <<IN_AVGBAL>>
      BEGIN
         INSERT INTO ACBALASONHIST_AVGBAL (ACBALH_ENTITY_NUM,
                                           ACBALH_INTERNAL_ACNUM,
                                           ACBALH_ASON_DATE,
                                           ACBALH_AC_BAL,
                                           ACBALH_BC_BAL)
              VALUES (W_ENTITY_NUM,
                      W_ACNT_NUMBER,
                      IDX.BAL_DATE,
                      IDX.AC_BALANCE,
                      IDX.BC_BALANCE);
      EXCEPTION
         WHEN OTHERS
         THEN
            W_ER_CODE := 'AVGBAL';
            W_ER_DESC :=
               'SP_ADDSCRIPTS-INSERT-ACBALASONHIST_AVGBAL' || SQLERRM;
            W_SRC_KEY :=
               P_BRANCH_CODE || '-' || 'OLD_AC_NUMBER' || IDX.ACCOUNTNO;

            POST_ERR_LOG (W_SRC_KEY,
                          W_CURR_DATE,
                          W_ER_CODE,
                          W_ER_DESC);
      END IN_AVGBAL;
   END LOOP;

   FOR IDX IN (SELECT BRN_CODE,
                      ACCOUNTNO,
                      BAL_DATE,
                      AC_BALANCE,
                      BC_BALANCE
                 FROM MIG_MINBAL
                WHERE BRN_CODE = P_BRANCH_CODE)
   LOOP
      FETCH_ACNUM (IDX.ACCOUNTNO,
                   W_ACNT_NUMBER,
                   'MINBAL',
                   'MIG_MINBAL GETOTN');

     <<IN_MAXBAL>>
      BEGIN
         INSERT INTO ACBALASONHIST_MIN (ACBALH_ENTITY_NUM,
                                        ACBALH_INTERNAL_ACNUM,
                                        ACBALH_ASON_DATE,
                                        ACBALH_AC_BAL,
                                        ACBALH_BC_BAL)
              VALUES (W_ENTITY_NUM,
                      W_ACNT_NUMBER,
                      IDX.BAL_DATE,
                      IDX.AC_BALANCE,
                      IDX.BC_BALANCE);
      EXCEPTION
         WHEN OTHERS
         THEN
            W_ER_CODE := 'MINBAL';
            W_ER_DESC := 'SP_ADDSCRIPTS-INSERT-ACBALASONHIST_MIN' || SQLERRM;
            W_SRC_KEY :=
               P_BRANCH_CODE || '-' || 'OLD_AC_NUMBER' || IDX.ACCOUNTNO;

            POST_ERR_LOG (W_SRC_KEY,
                          W_CURR_DATE,
                          W_ER_CODE,
                          W_ER_DESC);
      END IN_MAXBAL;
   END LOOP;


   COMMIT;
EXCEPTION
   WHEN OTHERS
   THEN
      P_ERR_MSG := SQLERRM;
      ROLLBACK;
/*
TRUNCATE TABLE  ACBALASONHIST_MAX;
TRUNCATE TABLE  ACBALASONHIST_AVGBAL;
*/

END SP_MIG_ADDSCRIPTS;

/
