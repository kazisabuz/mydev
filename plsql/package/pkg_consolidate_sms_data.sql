/*<TOAD_FILE_CHUNK>*/
CREATE OR REPLACE PACKAGE PKG_CONSOLIDATE_SMS_DATA
IS
   PROCEDURE SP_PROC_BRANCH (P_ENTITY_NUM    IN NUMBER,
                             P_BRANCH_CODE   IN NUMBER,
                             P_PROC_DATE        DATE);
END PKG_CONSOLIDATE_SMS_DATA;
/

/*<TOAD_FILE_CHUNK>*/
CREATE OR REPLACE PACKAGE BODY PKG_CONSOLIDATE_SMS_DATA
IS
   W_SQL              VARCHAR2 (4000);

   TYPE TT_INTERNAL_ACNUM IS TABLE OF VARCHAR2 (15)
      INDEX BY PLS_INTEGER;

   T_INTERNAL_ACNUM   TT_INTERNAL_ACNUM;

   W_INDEX_NUMBER     NUMBER (10) := 1;
   W_ACCOUNT_KEY      VARCHAR2 (14);

   TYPE REC_ACCOUNT_LIST IS RECORD
   (
      ACCOUNT_NUMBER   NUMBER (14),
      CHARGE_AMOUNT    NUMBER (18, 3),
      VAT_AMOUNT       NUMBER (18, 3)
   );

   TYPE TT_ACCOUNT_LIST IS TABLE OF REC_ACCOUNT_LIST
      INDEX BY PLS_INTEGER;

   T_ACCOUNT_LIST     TT_ACCOUNT_LIST;

   TYPE REC_CHARGES_LIST IS RECORD
   (
      ACCOUNT_NUMBER      NUMBER (14),
      EXCISE_DUTY         NUMBER (18, 3),
      SMS_CHARGES         NUMBER (18, 3),
      SMSCHARGE_VAT_AMT   NUMBER (18, 3),
      INTEREST_AMT        NUMBER (18, 3),
      INTEREST_TDS_AMT    NUMBER (18, 3),
      AMC_AMOUNT          NUMBER (18, 3),
      AMC_VAT_AMT         NUMBER (18, 3),
      ATM_CHARGE_AMT      NUMBER (18, 3),
      ATM_VAT_AMT         NUMBER (18, 3)
   );

   TYPE TT_CHARGES_LIST IS TABLE OF REC_CHARGES_LIST
      INDEX BY VARCHAR2 (14);

   T_CHARGES_LIST     TT_CHARGES_LIST;

   PROCEDURE SP_UPDATE_EXCISE_AMOUNT (P_ACCOUNT_NUMBER   IN NUMBER,
                                      P_CHARGE_AMOUNT       NUMBER)
   IS
   BEGIN
      IF T_CHARGES_LIST.EXISTS (P_ACCOUNT_NUMBER)
      THEN
         T_CHARGES_LIST (P_ACCOUNT_NUMBER).EXCISE_DUTY := P_CHARGE_AMOUNT;
      ELSE
         T_CHARGES_LIST (P_ACCOUNT_NUMBER).ACCOUNT_NUMBER := P_ACCOUNT_NUMBER;
         T_CHARGES_LIST (P_ACCOUNT_NUMBER).EXCISE_DUTY := P_CHARGE_AMOUNT;
      END IF;
   END;

   PROCEDURE SP_UPDATE_SMS_AMOUNT (P_ACCOUNT_NUMBER   IN NUMBER,
                                   P_CHARGE_AMOUNT       NUMBER,
                                   P_VAT_AMOUNT          NUMBER)
   IS
   BEGIN
      IF T_CHARGES_LIST.EXISTS (P_ACCOUNT_NUMBER)
      THEN
         T_CHARGES_LIST (P_ACCOUNT_NUMBER).SMS_CHARGES := P_CHARGE_AMOUNT;
         T_CHARGES_LIST (P_ACCOUNT_NUMBER).SMSCHARGE_VAT_AMT :=P_VAT_AMOUNT;
      ELSE
         T_CHARGES_LIST (P_ACCOUNT_NUMBER).ACCOUNT_NUMBER := P_ACCOUNT_NUMBER;
         T_CHARGES_LIST (P_ACCOUNT_NUMBER).SMS_CHARGES := P_CHARGE_AMOUNT;
         T_CHARGES_LIST (P_ACCOUNT_NUMBER).SMSCHARGE_VAT_AMT :=P_VAT_AMOUNT;
      END IF;
   END;


   PROCEDURE SP_UPDATE_INT_AMOUNT (P_ACCOUNT_NUMBER   IN NUMBER,
                                   P_CHARGE_AMOUNT       NUMBER,
                                   P_VAT_AMOUNT          NUMBER)
   IS
   BEGIN
      IF T_CHARGES_LIST.EXISTS (P_ACCOUNT_NUMBER)
      THEN
         T_CHARGES_LIST (P_ACCOUNT_NUMBER).INTEREST_AMT := P_CHARGE_AMOUNT;
         T_CHARGES_LIST (P_ACCOUNT_NUMBER).INTEREST_TDS_AMT := P_VAT_AMOUNT;
      ELSE
         T_CHARGES_LIST (P_ACCOUNT_NUMBER).ACCOUNT_NUMBER := P_ACCOUNT_NUMBER;
         T_CHARGES_LIST (P_ACCOUNT_NUMBER).INTEREST_AMT := P_CHARGE_AMOUNT;
         T_CHARGES_LIST (P_ACCOUNT_NUMBER).INTEREST_TDS_AMT := P_VAT_AMOUNT;
      END IF;
   END;

   PROCEDURE SP_UPDATE_AMC_AMOUNT (P_ACCOUNT_NUMBER   IN NUMBER,
                                   P_CHARGE_AMOUNT       NUMBER,
                                   P_VAT_AMOUNT          NUMBER)
   IS
   BEGIN
      IF T_CHARGES_LIST.EXISTS (P_ACCOUNT_NUMBER)
      THEN
         T_CHARGES_LIST (P_ACCOUNT_NUMBER).AMC_AMOUNT := P_CHARGE_AMOUNT;
         T_CHARGES_LIST (P_ACCOUNT_NUMBER).AMC_VAT_AMT := P_VAT_AMOUNT;
      ELSE
         T_CHARGES_LIST (P_ACCOUNT_NUMBER).ACCOUNT_NUMBER := P_ACCOUNT_NUMBER;
         T_CHARGES_LIST (P_ACCOUNT_NUMBER).AMC_AMOUNT := P_CHARGE_AMOUNT;
         T_CHARGES_LIST (P_ACCOUNT_NUMBER).AMC_VAT_AMT := P_VAT_AMOUNT;
      END IF;
   END;

   PROCEDURE SP_UPDATE_ATM_AMOUNT (P_ACCOUNT_NUMBER   IN NUMBER,
                                   P_CHARGE_AMOUNT       NUMBER,
                                   P_VAT_AMOUNT          NUMBER)
   IS
   BEGIN
      IF T_CHARGES_LIST.EXISTS (P_ACCOUNT_NUMBER)
      THEN
         T_CHARGES_LIST (P_ACCOUNT_NUMBER).ATM_CHARGE_AMT := P_CHARGE_AMOUNT;
         T_CHARGES_LIST (P_ACCOUNT_NUMBER).ATM_VAT_AMT := P_VAT_AMOUNT;
      ELSE
         T_CHARGES_LIST (P_ACCOUNT_NUMBER).ACCOUNT_NUMBER := P_ACCOUNT_NUMBER;
         T_CHARGES_LIST (P_ACCOUNT_NUMBER).ATM_CHARGE_AMT := P_CHARGE_AMOUNT;
         T_CHARGES_LIST (P_ACCOUNT_NUMBER).ATM_VAT_AMT := P_VAT_AMOUNT;
      END IF;
   END;


   PROCEDURE SP_UPDATE_ACCOUNT_ARRAY (P_ACCOUNT_NUMBER IN NUMBER)
   IS
   BEGIN
      IF T_CHARGES_LIST.EXISTS (P_ACCOUNT_NUMBER) = FALSE
      THEN
         T_INTERNAL_ACNUM (W_INDEX_NUMBER) := P_ACCOUNT_NUMBER;
         W_INDEX_NUMBER := W_INDEX_NUMBER + 1;
      END IF;
   END;


   PROCEDURE SP_PROC_BRANCH (P_ENTITY_NUM    IN NUMBER,
                             P_BRANCH_CODE   IN NUMBER,
                             P_PROC_DATE        DATE)
   IS
   BEGIN
      SELECT ACNTEXCAMT_INTERNAL_ACNUM, ACNTEXCAMT_EXCISE_AMT, 0
        BULK COLLECT INTO T_ACCOUNT_LIST
        FROM ACNTEXCISEAMT
       WHERE     ACNTEXCAMT_ENTITY_NUM = P_ENTITY_NUM
             AND ACNTEXCAMT_FIN_YEAR =
                    TO_NUMBER (TO_CHAR (P_PROC_DATE, 'YYYY'))
             AND ACNTEXCAMT_PROCESS_DATE = P_PROC_DATE
             AND ACNTEXCAMT_EXCISE_AMT > 0
             AND ACNTEXCAMT_BRN_CODE = P_BRANCH_CODE;


      FOR IDX IN 1 .. T_ACCOUNT_LIST.COUNT
      LOOP
         SP_UPDATE_ACCOUNT_ARRAY (T_ACCOUNT_LIST (IDX).ACCOUNT_NUMBER);
         SP_UPDATE_EXCISE_AMOUNT (T_ACCOUNT_LIST (IDX).ACCOUNT_NUMBER,
                                  T_ACCOUNT_LIST (IDX).CHARGE_AMOUNT);
      END LOOP;


      SELECT SMSCHARGE_INTERNAL_ACNUM,
             SUM(NVL (SMSCHARGE_CHARGE_AMT, 0)),
             SUM(NVL (SMSCHARGE_VAT_AMT, 0))
        BULK COLLECT INTO T_ACCOUNT_LIST
        FROM SMSCHARGE
       WHERE     SMSCHARGE_ENTITY_NUM = P_ENTITY_NUM
             AND SMSCHARGE_CHARGE_AMT > 0
             AND SMSCHARGE_BRN_CODE = P_BRANCH_CODE
             AND SMSCHARGE_FIN_YEAR =
                    TO_NUMBER (TO_CHAR (P_PROC_DATE, 'YYYY'))
             AND SMSCHARGE_PROCESS_DATE = P_PROC_DATE
             group by SMSCHARGE_INTERNAL_ACNUM;


      FOR IDX IN 1 .. T_ACCOUNT_LIST.COUNT
      LOOP
         SP_UPDATE_ACCOUNT_ARRAY (T_ACCOUNT_LIST (IDX).ACCOUNT_NUMBER);
         SP_UPDATE_SMS_AMOUNT (T_ACCOUNT_LIST (IDX).ACCOUNT_NUMBER,
                               T_ACCOUNT_LIST (IDX).CHARGE_AMOUNT,
                               T_ACCOUNT_LIST (IDX).VAT_AMOUNT);
      END LOOP;


      SELECT TDSPIDT_AC_NUM, TDSPIDT_TOT_INT_CR, TDSPIDT_TDS_AMT
        BULK COLLECT INTO T_ACCOUNT_LIST
        FROM TDSPIDTL
       WHERE     TDSPIDT_ENTITY_NUM = P_ENTITY_NUM
             AND TDSPIDT_TOT_INT_CR > 0
             AND TDSPIDT_BRN_CODE = P_BRANCH_CODE
             AND TDSPIDT_FIN_YR = TO_NUMBER (TO_CHAR (P_PROC_DATE, 'YYYY'))
             AND TDSPIDT_DATE_OF_REC = P_PROC_DATE;


      FOR IDX IN 1 .. T_ACCOUNT_LIST.COUNT
      LOOP
         SP_UPDATE_ACCOUNT_ARRAY (T_ACCOUNT_LIST (IDX).ACCOUNT_NUMBER);
         SP_UPDATE_INT_AMOUNT (T_ACCOUNT_LIST (IDX).ACCOUNT_NUMBER,
                               T_ACCOUNT_LIST (IDX).CHARGE_AMOUNT,
                               T_ACCOUNT_LIST (IDX).VAT_AMOUNT);
      END LOOP;

      SELECT ACNTCHGAMT_INTERNAL_ACNUM,
             ACNTCHGAMT_CHARGE_AMT,
             ACNTCHGAMT_SERV_TAX_AMT
        BULK COLLECT INTO T_ACCOUNT_LIST
        FROM ACNTCHARGEAMT
       WHERE     ACNTCHGAMT_ENTITY_NUM = P_ENTITY_NUM
             AND ACNTCHGAMT_BRN_CODE = P_BRANCH_CODE
             AND ACNTCHGAMT_CHARGE_AMT > 0
             AND ACNTCHGAMT_FIN_YEAR =
                    TO_NUMBER (TO_CHAR (P_PROC_DATE, 'YYYY'))
             AND ACNTCHGAMT_PROCESS_DATE = P_PROC_DATE;


      FOR IDX IN 1 .. T_ACCOUNT_LIST.COUNT
      LOOP
         SP_UPDATE_ACCOUNT_ARRAY (T_ACCOUNT_LIST (IDX).ACCOUNT_NUMBER);
         SP_UPDATE_AMC_AMOUNT (T_ACCOUNT_LIST (IDX).ACCOUNT_NUMBER,
                               T_ACCOUNT_LIST (IDX).CHARGE_AMOUNT,
                               T_ACCOUNT_LIST (IDX).VAT_AMOUNT);
      END LOOP;

      SELECT ATM_CHG_REC_INTERNAL_ACNUM,
             NVL (ATM_CHG_REC_CHARGE_AMT, 0),
             NVL (ATM_CHG_REC_VAT_AMT, 0)
        BULK COLLECT INTO T_ACCOUNT_LIST
        FROM ATM_CHG_REC
       WHERE     ATM_CHG_REC_ENTITY_NUM = P_ENTITY_NUM
             AND ATM_CHG_REC_BRN_CODE = P_BRANCH_CODE
             AND ATM_CHG_REC_FIN_YEAR =
                    TO_NUMBER (TO_CHAR (P_PROC_DATE, 'YYYY'))
             AND ATM_CHG_REC_CHARGE_AMT > 0
             AND ATM_CHG_REC_PROCESS_DATE = P_PROC_DATE;


      FOR IDX IN 1 .. T_ACCOUNT_LIST.COUNT
      LOOP
         SP_UPDATE_ACCOUNT_ARRAY (T_ACCOUNT_LIST (IDX).ACCOUNT_NUMBER);
         SP_UPDATE_ATM_AMOUNT (T_ACCOUNT_LIST (IDX).ACCOUNT_NUMBER,
                               T_ACCOUNT_LIST (IDX).CHARGE_AMOUNT,
                               T_ACCOUNT_LIST (IDX).VAT_AMOUNT);
      END LOOP;

      IF T_INTERNAL_ACNUM.COUNT > 0
      THEN
         FOR INDX IN T_INTERNAL_ACNUM.FIRST .. T_INTERNAL_ACNUM.LAST
         LOOP
            W_ACCOUNT_KEY := T_INTERNAL_ACNUM (INDX);

            INSERT INTO MOBSMSCONSOLQ (MOBSMSCNSL_BRN_CODE,
                                       MOBSMSCNSL_DATE,
                                       MOBSMSCNSL_ACC_NUM,
                                       MOBSMSCNSL_DEPINT_AMT,
                                       MOBSMSCNSL_SRCTAX_AMT,
                                       MOBSMSCNSL_MNTCHG_AMT,
                                       MOBSMSCNSL_EXCISDT_AMT,
                                       MOBSMSCNSL_SMSCHG_AMT,
                                       MOBSMSCNSL_DRCRD_MNTCHG_AMT,
                                       MOBSMSCNSL_VAT_AMT,
                                       MOBSMSCNSL_ATMCHG_AMT,
                                       MOBSMSCNSL_ATM_VAT_AMT)
                 VALUES (P_BRANCH_CODE,
                         P_PROC_DATE,
                         T_CHARGES_LIST (W_ACCOUNT_KEY).ACCOUNT_NUMBER,
                         T_CHARGES_LIST (W_ACCOUNT_KEY).INTEREST_AMT,
                         T_CHARGES_LIST (W_ACCOUNT_KEY).INTEREST_TDS_AMT,
                         T_CHARGES_LIST (W_ACCOUNT_KEY).AMC_AMOUNT,
                         T_CHARGES_LIST (W_ACCOUNT_KEY).EXCISE_DUTY,
                         T_CHARGES_LIST (W_ACCOUNT_KEY).SMS_CHARGES,
                         T_CHARGES_LIST (W_ACCOUNT_KEY).AMC_VAT_AMT,
                         T_CHARGES_LIST (W_ACCOUNT_KEY).SMSCHARGE_VAT_AMT,
                          T_CHARGES_LIST (W_ACCOUNT_KEY).ATM_CHARGE_AMT,
                         T_CHARGES_LIST (W_ACCOUNT_KEY).ATM_VAT_AMT);
         END LOOP;
      END IF;
      T_INTERNAL_ACNUM.DELETE;
      T_CHARGES_LIST.DELETE;
      T_ACCOUNT_LIST.DELETE;
   END;
END PKG_CONSOLIDATE_SMS_DATA;
/
