CREATE OR REPLACE PROCEDURE SP_MIG_NOMREG (
   P_BRANCH_CODE       NUMBER,
   P_ERR_MSG       OUT VARCHAR2)
IS
   /*
      Author: Ramesh Mullamuri
      Date  : 16-May-2013

      List of  Table/s Referred

      1. MIG_NOMREG


      List of Tables Updated


      1. NOMREG
      2. NOMREGDTL

   */
   W_CURR_DATE     DATE;
   W_ENTD_BY       VARCHAR2 (8) := 'MIG';
   W_CLIENT_NUM    VARCHAR2 (14);
   W_ACNT_NUMBER   NUMBER (14);

   W_SRC_KEY       VARCHAR2 (1000);
   W_ER_CODE       VARCHAR2 (5);
   W_ER_DESC       VARCHAR2 (1000);
   W_ENTITY_NUM    NUMBER (3) := GET_OTN.ENTITY_NUMBER;

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
      EXECUTE IMMEDIATE
         'SELECT I.IACLINK_INTERNAL_ACNUM, I.IACLINK_CIF_NUMBER
  FROM IACLINK I
 WHERE IACLINK_ENTITY_NUM = :1
   and I.IACLINK_BRN_CODE = :2
   AND I.IACLINK_ACTUAL_ACNUM = :3 '
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

   DELETE FROM MIG_NOMREG
         WHERE NOMREG_AC_NUM NOT IN (SELECT ACNTS_ACNUM FROM MIG_ACNTS);

   UPDATE MIG_NOMREG M
      SET M.NOMREG_CONT_NUM = 0
    WHERE M.NOMREG_AC_NUM IN (SELECT P.MIGDEP_DEP_AC_NUM
                                FROM MIG_PBDCONTRACT P
                               WHERE p.MIGDEP_CONT_NUM = 0);

   COMMIT;

   FOR IDX IN (SELECT NOMREG_AC_NUM,
                      NOMREG_CONT_NUM,
                      NOMREG_REG_DATE,
                      ROW_NUMBER () OVER ( PARTITION BY NOMREG_AC_NUM ORDER BY NOMREG_AC_NUM, NOMREG_REG_DATE) NOMREG_REG_SL,
                      ROW_NUMBER () OVER ( PARTITION BY NOMREG_AC_NUM ORDER BY NOMREG_AC_NUM, NOMREG_REG_DATE) NOMREG_DTL_SL,
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
                      NOMREG_CUST_LTR_REF_DATE
                 FROM MIG_NOMREG)
   LOOP
      FETCH_ACNUM (IDX.NOMREG_AC_NUM,
                   W_ACNT_NUMBER,
                   'DEP1',
                   'MIG_DEPOSITS GETOTN');

     <<IN_NOMREG>>
      BEGIN
         INSERT INTO NOMREG (NOMREG_ENTITY_NUM,
                             NOMREG_AC_NUM,
                             NOMREG_CONT_NUM,
                             NOMREG_REG_YEAR,
                             NOMREG_REG_SL,
                             NOMREG_REG_DATE,
                             NOMREG_ENTD_BY,
                             NOMREG_ENTD_ON,
                             NOMREG_AUTH_BY,
                             NOMREG_AUTH_ON)
              VALUES (
                        W_ENTITY_NUM,
                        W_ACNT_NUMBER,
                        IDX.NOMREG_CONT_NUM,
                        TO_CHAR (IDX.NOMREG_REG_DATE, 'YYYY'),
                        (SELECT NVL (MAX (NOMREG_REG_SL), 0) + 1
                           FROM NOMREG
                          WHERE     NOMREG_AC_NUM = W_ACNT_NUMBER
                                AND NOMREG_CONT_NUM = IDX.NOMREG_CONT_NUM
                                AND TO_CHAR (NOMREG_REG_DATE, 'YYYY') =
                                       TO_CHAR (IDX.NOMREG_REG_DATE, 'YYYY')),
                        IDX.NOMREG_REG_DATE,
                        W_ENTD_BY,
                        W_CURR_DATE,
                        W_ENTD_BY,
                        W_CURR_DATE);
      EXCEPTION
         WHEN OTHERS
         THEN
            W_ER_CODE := 'NOMREG';
            W_ER_DESC := 'SP_NOMREG-INSERT-NOMREG' || SQLERRM;
            W_SRC_KEY :=
               P_BRANCH_CODE || '-' || 'OLD_AC_NUMBER' || IDX.NOMREG_AC_NUM;

            POST_ERR_LOG (W_SRC_KEY,
                          W_CURR_DATE,
                          W_ER_CODE,
                          W_ER_DESC);
      END IN_NOMREG;

     <<IN_NOMREGDTL>>
      BEGIN
         INSERT INTO NOMREGDTL (NOMREGDTL_ENTITY_NUM,
                                NOMREGDTL_AC_NUM,
                                NOMREGDTL_CONT_NUM,
                                NOMREGDTL_REG_YEAR,
                                NOMREGDTL_REG_SL,
                                NOMREGDTL_DTL_SL,
                                NOMREGDTL_NOMINEE_NAME,
                                NOMREGDTL_ALOTTED_PERCENTAGE,
                                NOMREGDTL_ADDR)
              VALUES (
                        W_ENTITY_NUM,
                        W_ACNT_NUMBER,
                        IDX.NOMREG_CONT_NUM,
                        TO_CHAR (IDX.NOMREG_REG_DATE, 'YYYY'),
                        (  SELECT NVL (MAX (NOMREG_REG_SL), 0) + 1
                             FROM NOMREG
                            WHERE     NOMREG_AC_NUM = W_ACNT_NUMBER
                                  AND NOMREG_CONT_NUM = IDX.NOMREG_CONT_NUM
                         GROUP BY TO_CHAR (NOMREG_REG_DATE, 'YYYY')),
                        (  SELECT NVL (MAX (NOMREG_REG_SL), 0) + 1
                             FROM NOMREG
                            WHERE     NOMREG_AC_NUM = W_ACNT_NUMBER
                                  AND NOMREG_CONT_NUM = IDX.NOMREG_CONT_NUM
                         GROUP BY TO_CHAR (NOMREG_REG_DATE, 'YYYY')),
                        SUBSTR (IDX.NOMREG_NOMINEE_NAME, 1, 15),
                        IDX.NOMREG_ALOTTED_PERCENTAGE,
                        SUBSTR (IDX.NOMREG_ADDR, 1, 50));
      EXCEPTION
         WHEN OTHERS
         THEN
            W_ER_CODE := 'NOMREG';
            W_ER_DESC := 'SP_NOMREG-INSERT-NOMREGDTL' || SQLERRM;
            W_SRC_KEY :=
               P_BRANCH_CODE || '-' || 'OLD_AC_NUMBER' || IDX.NOMREG_AC_NUM;

            POST_ERR_LOG (W_SRC_KEY,
                          W_CURR_DATE,
                          W_ER_CODE,
                          W_ER_DESC);
      END IN_NOMREGDTL;
   END LOOP;


   
   
   SCRIPT_MIG_NOMREG_TO_CONNPINFO;
      COMMIT;
EXCEPTION
   WHEN OTHERS
   THEN
      P_ERR_MSG := SQLERRM;
      ROLLBACK;
/*
TRUNCATE TABLE  NOMREG;
TRUNCATE TABLE  NOMREGDTL;
*/

END SP_MIG_NOMREG;
/
