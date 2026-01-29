/*
ATM migration procedure for newly created debit cards. We had to 
insert those data in 2 tables. One for the card request and one 
for the card issue. Those data was necessary in the code banking 
side for the charge deduction on every year-end.
*/

DROP TABLE CIFISS_DATA CASCADE CONSTRAINTS;

CREATE TABLE CIFISS_DATA
(
  CARDNO     VARCHAR2(20 BYTE),
  CBSAC      VARCHAR2(16 BYTE),
  CREATION   DATE,
  CARD_TYPE  VARCHAR2(1 BYTE)
)
TABLESPACE TBFES
RESULT_CACHE (MODE DEFAULT)
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MAXSIZE          UNLIMITED
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      DEFAULT
            CELL_FLASH_CACHE DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING;


CREATE OR REPLACE PROCEDURE SP_INSERT_ATM_DATA_ISSUE
IS
   V_CIFREG_BRN_CODE     NUMBER (6);
   V_CIFREG_REQ_DATE     DATE;
   V_CIFREG_REQ_DAY_SL   NUMBER;
   V_AC_NUM              NUMBER;
   V_ERROR               VARCHAR2 (1000);
   V_CIFISS_ENTD_BY     VARCHAR2(5);
   V_CIFISS_ENTD_ON DATE;
   V_CIFISS_AUTH_BY VARCHAR2(5); 
   V_CIFISS_AUTH_ON DATE;
BEGIN
   FOR IDX
      IN (SELECT 1 CIFISS_ENTITY_NUM,
                 IACLINK_BRN_CODE CIFISS_BRN_CODE,
                 CREATION CIFISS_ISS_DATE,
                 1 CIFISS_ISS_DAY_SL,
                 IACLINK_INTERNAL_ACNUM CIFISS_ACC_NUM,
                 CARDNO CIFISS_CARD_NUMBER,
                 CARD_TYPE CIFISS_ISS_TYPE,
                 1 CIFISS_ATM_OPR,
                 'MIG' CIFISS_ENTD_BY,
                 SYSDATE CIFISS_ENTD_ON,
                 NULL CIFISS_LAST_MOD_BY,
                 NULL CIFISS_LAST_MOD_ON,
                 'MIG' CIFISS_AUTH_BY,
                 SYSDATE CIFISS_AUTH_ON,
                 SYSDATE || 1 TBA_MAIN_KEY,
                 NULL CIFISS_REJ_BY,
                 NULL CIFISS_REJ_ON
            FROM CIFISS_DATA, IACLINK
           WHERE IACLINK_ENTITY_NUM = 1 AND IACLINK_ACTUAL_ACNUM = CBSAC)
   LOOP
      BEGIN
         V_AC_NUM := IDX.CIFISS_ACC_NUM;

         SELECT CIFISS_BRN_CODE, CIFISS_ISS_DATE, CIFISS_ISS_DAY_SL, CIFISS_ENTD_BY, CIFISS_ENTD_ON, CIFISS_AUTH_BY, CIFISS_AUTH_ON
           INTO V_CIFREG_BRN_CODE, V_CIFREG_REQ_DATE, V_CIFREG_REQ_DAY_SL, V_CIFISS_ENTD_BY, V_CIFISS_ENTD_ON, V_CIFISS_AUTH_BY, V_CIFISS_AUTH_ON
           FROM CIFISS
          WHERE CIFISS_ENTITY_NUM = 1 AND CIFISS_ACC_NUM = IDX.CIFISS_ACC_NUM;

         DELETE FROM CIFISS
               WHERE     CIFISS_ENTITY_NUM = 1
                     AND CIFISS_ACC_NUM = IDX.CIFISS_ACC_NUM;

         INSERT INTO CIFISS
              VALUES (1,
                      V_CIFREG_BRN_CODE,
                      V_CIFREG_REQ_DATE,
                      V_CIFREG_REQ_DAY_SL,
                      IDX.CIFISS_ACC_NUM,
                      IDX.CIFISS_CARD_NUMBER,
                      IDX.CIFISS_ISS_TYPE,
                      1,
                      V_CIFISS_ENTD_BY,
                      V_CIFISS_ENTD_ON,
                      NULL,
                      NULL,
                      V_CIFISS_AUTH_BY,
                      V_CIFISS_AUTH_ON,
                      SYSDATE || '|' || 1,
                      NULL,
                      NULL);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            V_CIFREG_BRN_CODE := IDX.CIFISS_BRN_CODE;
            V_CIFREG_REQ_DATE := IDX.CIFISS_ISS_DATE;

            SELECT   NVL (
                        ( (SELECT MAX (CIFISS_ISS_DAY_SL)
                             FROM CIFISS
                            WHERE     CIFISS_ENTITY_NUM = 1
                                  AND CIFISS_ISS_DATE = IDX.CIFISS_ISS_DATE
                                  AND CIFISS_BRN_CODE = IDX.CIFISS_BRN_CODE)),
                        0)
                   + 1
              INTO V_CIFREG_REQ_DAY_SL
              FROM DUAL;

            INSERT INTO CIFISS
                 VALUES (1,
                         V_CIFREG_BRN_CODE,
                         V_CIFREG_REQ_DATE,
                         V_CIFREG_REQ_DAY_SL,
                         IDX.CIFISS_ACC_NUM,
                         IDX.CIFISS_CARD_NUMBER,
                         IDX.CIFISS_ISS_TYPE,
                         1,
                         'MIG',
                         SYSDATE,
                         NULL,
                         NULL,
                         'MIG',
                         SYSDATE,
                         SYSDATE || '|' || 1,
                         NULL,
                         NULL);
         WHEN OTHERS
         THEN
            V_CIFREG_BRN_CODE := IDX.CIFISS_BRN_CODE;
            V_CIFREG_REQ_DATE := IDX.CIFISS_ISS_DATE;

            DELETE FROM CIFISS
                  WHERE     CIFISS_ENTITY_NUM = 1
                        AND CIFISS_ACC_NUM = IDX.CIFISS_ACC_NUM;

            SELECT   NVL (
                        ( (SELECT MAX (CIFISS_ISS_DAY_SL)
                             FROM CIFISS
                            WHERE     CIFISS_ENTITY_NUM = 1
                                  AND CIFISS_ISS_DATE = IDX.CIFISS_ISS_DATE
                                  AND CIFISS_BRN_CODE = IDX.CIFISS_BRN_CODE)),
                        0)
                   + 1
              INTO V_CIFREG_REQ_DAY_SL
              FROM DUAL;

            INSERT INTO CIFISS
                 VALUES (1,
                         V_CIFREG_BRN_CODE,
                         V_CIFREG_REQ_DATE,
                         V_CIFREG_REQ_DAY_SL,
                         IDX.CIFISS_ACC_NUM,
                         IDX.CIFISS_CARD_NUMBER,
                         IDX.CIFISS_ISS_TYPE,
                         1,
                         'MIG',
                         SYSDATE,
                         NULL,
                         NULL,
                         'MIG',
                         SYSDATE,
                         SYSDATE || '|' || 1,
                         NULL,
                         NULL);
      END;
   END LOOP;
EXCEPTION
   WHEN OTHERS
   THEN
      V_ERROR := V_AC_NUM || '   ' || SQLERRM;
END SP_INSERT_ATM_DATA_ISSUE;
/



UPDATE  CIFISS SET CIFISS_ISS_TYPE = 'C'  WHERE CIFISS_ENTITY_NUM = 1 AND 
CIFISS_ACC_NUM IN (
SELECT IACLINK_INTERNAL_ACNUM FROM ACC4, IACLINK 
WHERE IACLINK_ENTITY_NUM = 1
AND IACLINK_ACTUAL_ACNUM = ACC_NO);



