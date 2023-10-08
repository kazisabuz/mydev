CREATE OR REPLACE FUNCTION FN_GET_CALL_CENTER_DATA (
    P_ACCOUNT_NUMBER   VARCHAR2)
    RETURN CLOB
IS
    W_ERRM                          VARCHAR2 (1000) := '';
    W_SQL                           CLOB;
    W_TRAN_COUNT                    NUMBER := 0;
    W_TEXT                          CLOB;
    W_CBD                           DATE;
    W_TRAN_YEAR                     NUMBER := 0;
    W_CLIENTS_CODE                  NUMBER;
    W_ACTUAL_ACCOUNT                VARCHAR2 (100);
    W_ACCOUNT_BALANCE               NUMBER;
    W_LAST_5_TRANSACTION            CLOB;                           -- (4000);
    W_TRANSACTION_PROFILE           CLOB;                           -- (4000);
    W_ACTYPE_NAME                   VARCHAR2 (1000);
    W_INSTALLMENT_AMOUNT            NUMBER;
    W_MATURITY_DATE                 DATE;
    w_ADDRDTLS_INV_NUM              NUMBER;
    W_ENTITY_NUM                    NUMBER;
    W_INTERNAL_ACNUM                NUMBER;
    W_AC_STATUS                     ASSETCD.ASSETCD_DESCN%TYPE;
    W_CHQUSAGEDATE                  CHQUSG.CHQUSG_DATE_OF_USAGE%TYPE;
    W_CHQUSAGELEFNUM                VARCHAR2 (30);
    W_CURR_INT_RATE                 NUMBER;
    W_INT_RATE                      NUMBER;
    W_PRIN_BAL                      NUMBER (18, 3);
    W_INT_BAL                       NUMBER (18, 3);
    W_CHG_BAL                       NUMBER (18, 3);
    W_INT_ACCRUAL_AMT               NUMBER (18, 3);
    W_ACCRUAL_AMOUNT                NUMBER (18, 3);
    INT_ACCR_UPTO                   DATE;
    INT_APPLIED_UPTO_DATE           DATE;
    GUR_CLIENTS_NAME_ONE            CLIENTS.CLIENTS_NAME%TYPE;
    GUR_CLIENTS_NAME_TWO            CLIENTS.CLIENTS_NAME%TYPE;
    GUR_RELATION_DESCN_ONE          RELATION.RELATION_DESCN%TYPE;
    GUR_RELATION_DESCN_TWO          RELATION.RELATION_DESCN%TYPE;
    W_LAST_INT_POSTING_AMT          NUMBER (18, 3);
    W_INT_POSTED_AMT_TILL_DATE      NUMBER (18, 3);
    W_DUE_OVERDUE_AMT               NUMBER (18, 3);
    W_LIEN_DEPOSIT_MATURITY_VALUE   NUMBER (18, 3);
    W_LIEN_DEPOSIT_MATURITY_DATE    DATE;
    W_LIEN_DEPOSIT_ACC_NUM          ACNTS.ACNTS_INTERNAL_ACNUM%TYPE;
    W_ACNTLIEN_INTERNAL_ACNUM       ACNTS.ACNTS_INTERNAL_ACNUM%TYPE;
    W_ACNTLIEN_LIEN_TO_BRN          MBRN.MBRN_CODE%TYPE;
    W_LIENT_DEPOSIT_ACC_BALANCE     NUMBER (18, 3);
    W_EXCISE_AMT                    ACNTEXCISEAMT.ACNTEXCAMT_EXCISE_AMT%TYPE;
    W_INT_APPL_FREQ                 LNPRODPM.LNPRD_INT_APPL_FREQ%TYPE;
    W_CALCULATION_BASIS             CHAR (1);
    W_REPAY_AMT                     NUMBER (18, 3);
    W_NUM_OF_INSTALLMENT            NUMBER (4);
    W_COUNTER                       NUMBER (3);
    V_NEWEAL_TIME                   NUMBER (3);
    V_LIMIT_EXPIRY_DATE             DATE;
    V_FIRST_SANC_LIMIT              NUMBER (18, 3);
    V_FIRST_SANC_DATE               DATE;
    W__RESCHEDULED_AMT              NUMBER (18, 3);
    W_RESCHEDULED_DATE              DATE;
    W_NOOF_RESCHEDULED              NUMBER (4);
    w_DEP_PERIOD                    NUMBER (4);
    w_MAT_DATE                      DATE;
    w_INST_AMT                      NUMBER (18, 3);
    w_RD_INT_RATE                   NUMBER (4);
    w_NOOF_INST_PAID                NUMBER (4);
    w_TOT_INST_AMT_PAID             NUMBER (18, 3);
    w_NOOF_INST_DUE                 NUMBER (18, 3);
    w_NOOF_INST_ADV_PAID            NUMBER (4);
    w_NOOF_INST_OVERDUE             NUMBER (4);
    w_PROD_CUTOFF_DAY               NUMBER (4);
    w_TOT_PENALY_AMT                NUMBER (18, 3);
    w_AUTO_REC_ENABLED              CHAR (1);
    w_AUTOREC_INT_ACNO              IACLINK.IACLINK_INTERNAL_ACNUM%TYPE;
    w_AUTOREC_START_DAY             NUMBER (4);
    W_AUTOROLL_PERIOD               PBDCONTRACT.PBDCONT_AUTOROLL_PERIOD%TYPE;
    W_RENEWAL_OPTION                VARCHAR2 (5);
    W_INT_CR_TO_ACNT                PBDCONTRACT.PBDCONT_INT_CR_TO_ACNT%TYPE;
    W_INT_CR_AC_NUM                 IACLINK.IACLINK_ACTUAL_ACNUM%TYPE;
    W_REPAY_FROM_DATE               DATE;
    V_PAID_AMT                      NUMBER (18, 2);
    V_INST_SIZE                     NUMBER;
    V_FREG                          VARCHAR2 (20);
    V_INST_FREQ                     VARCHAR2 (20);
    V_NOI                           NUMBER;
    V_NOI_DUE                       NUMBER (4);
    V_NUM_INS                       NUMBER (4);
    W_KYC_COMPILED                  NUMBER (2);
    W_TOT_IA_FROM_LOANIA            NUMBER (18, 3);
    W_LATEST_ACC_DATE_FROM_LOANIA   DATE;
    W_TOT_IA_FROM_LOANIADLY         NUMBER (18, 3);
    W_TOT_IA_FROM_LOANIAMRR         NUMBER (18, 3);
    UNAPPLIED_INT_AMT               NUMBER (18, 3);
    W_LAST_DATE_OF_INS_PAY          DATE;
    W_ACC_TOTAL_BALANCE             NUMBER (18, 3);
    W_OUTSTAN_BAL                   NUMBER (18, 3);
    W_DEP_AMT                       NUMBER (18, 3);
    W_MAT_VALUE                     NUMBER (18, 3);
    W_PBD_MAT_DATE                  DATE;
    W_PRD_MONTHS                    NUMBER (5);
    W_SUSP_BAL                      NUMBER (18, 3);
    W_KYC_DOCUMENT_NAME             VARCHAR2 (100);
    W_KYC_DOCUMENT_NUMBER           VARCHAR2 (100);
BEGIN
    W_TEXT := '[';

    SELECT MN_CURR_BUSINESS_DATE, MN_ENTITY_NUM
      INTO W_CBD, W_ENTITY_NUM
      FROM MAINCONT;

    --W_CLIENTS_CODE := 11837635;
    BEGIN
        SELECT IACLINK_CIF_NUMBER, IACLINK_INTERNAL_ACNUM
          INTO W_CLIENTS_CODE, W_INTERNAL_ACNUM
          FROM IACLINK
         WHERE     IACLINK_ENTITY_NUM = W_ENTITY_NUM
               AND IACLINK_ACTUAL_ACNUM = P_ACCOUNT_NUMBER;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            NULL;
    END;


    FOR CLIENT_DATA
        IN (SELECT CLIENTS_CODE
                       ID,
                   CASE
                       WHEN CLIENTS_TYPE_FLG = 'I'
                       THEN
                           'Individual'
                       WHEN CLIENTS_TYPE_FLG = 'C'
                       THEN
                           'Corporate'
                       WHEN CLIENTS_TYPE_FLG = 'J'
                       THEN
                           'Joint Client'
                       ELSE
                           'Undefine'
                   END
                       TYPE,
                   INITCAP (CLIENTS_NAME)
                       NAME,
                   INITCAP (
                       (SELECT INDCLIENT_FATHER_NAME
                          FROM INDCLIENTS
                         WHERE INDCLIENT_CODE = CLIENTS_CODE))
                       FATHER_NAME,
                   INITCAP ( (SELECT INDCLIENT_MOTHER_NAME
                                FROM INDCLIENTS
                               WHERE INDCLIENT_CODE = CLIENTS_CODE))
                       MOTHER_NAME,
                   INITCAP ( (SELECT INDSPOUSE_SPOUSE_NAME
                                FROM INDCLIENTSPOUSE
                               WHERE INDSPOUSE_CLIENT_CODE = CLIENTS_CODE))
                       SPOUSE_NAME,
                   (SELECT CASE
                               WHEN INDCLIENT_SEX = 'M' THEN 'MALE'
                               WHEN INDCLIENT_SEX = 'F' THEN 'FAMALE'
                               ELSE 'OTHERS'
                           END
                     FROM INDCLIENTS
                    WHERE INDCLIENT_CODE = CLIENTS_CODE)
                       GENDER,
                   INITCAP (
                       (SELECT    ADDRDTLS_ADDR1
                               || ADDRDTLS_ADDR2
                               || ADDRDTLS_ADDR3
                               || ADDRDTLS_ADDR4
                               || ADDRDTLS_ADDR5
                         FROM ADDRDTLS
                        WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
                              AND ADDRDTLS_CURR_ADDR = '1'
                              AND ADDRDTLS_EFF_FROM_DATE IN
                                      (SELECT MAX (ADDRDTLS_EFF_FROM_DATE)
                                        FROM ADDRDTLS
                                       WHERE     ADDRDTLS_INV_NUM =
                                                 CLIENTS_ADDR_INV_NUM
                                             AND ADDRDTLS_CURR_ADDR = '1')))
                       PRESENT_ADDRESS,
                   INITCAP (
                       (SELECT    ADDRDTLS_ADDR1
                               || ADDRDTLS_ADDR2
                               || ADDRDTLS_ADDR3
                               || ADDRDTLS_ADDR4
                               || ADDRDTLS_ADDR5
                         FROM ADDRDTLS
                        WHERE     ADDRDTLS_INV_NUM = CLIENTS_ADDR_INV_NUM
                              AND ADDRDTLS_PERM_ADDR = '1'
                              AND ADDRDTLS_EFF_FROM_DATE IN
                                      (SELECT MAX (ADDRDTLS_EFF_FROM_DATE)
                                        FROM ADDRDTLS
                                       WHERE     ADDRDTLS_INV_NUM =
                                                 CLIENTS_ADDR_INV_NUM
                                             AND ADDRDTLS_PERM_ADDR = '1')))
                       PERMANENT_ADDRESS,
                   INITCAP (
                       (SELECT OCCUPATIONS_DESCN
                         FROM INDCLIENTS, OCCUPATIONS
                        WHERE     INDCLIENT_CODE = CLIENTS_CODE
                              AND INDCLIENT_OCCUPN_CODE = OCCUPATIONS_CODE))
                       PROFESSION,
                   GET_NID_NUMBER (CLIENTS_CODE, 'NID')
                       NID,
                   (SELECT PIDDOCS_DOCID_NUM
                     FROM INDCLIENTS, PIDDOCS
                    WHERE     INDCLIENT_CODE = CLIENTS_CODE
                          AND INDCLIENT_PID_INV_NUM = PIDDOCS_INV_NUM
                          AND PIDDOCS_PID_TYPE = 'PP')
                       PASSPORT,
                   (SELECT PIDDOCS_DOCID_NUM
                     FROM INDCLIENTS, PIDDOCS
                    WHERE     INDCLIENT_CODE = CLIENTS_CODE
                          AND INDCLIENT_PID_INV_NUM = PIDDOCS_INV_NUM
                          AND PIDDOCS_PID_TYPE = 'SID')
                       SID,
                   (SELECT PIDDOCS_DOCID_NUM
                     FROM INDCLIENTS, PIDDOCS
                    WHERE     INDCLIENT_CODE = CLIENTS_CODE
                          AND INDCLIENT_PID_INV_NUM = PIDDOCS_INV_NUM
                          AND PIDDOCS_PID_TYPE = 'BC')
                       BIRTH_CER,
                   (SELECT PIDDOCS_DOCID_NUM
                     FROM INDCLIENTS, PIDDOCS
                    WHERE     INDCLIENT_CODE = CLIENTS_CODE
                          AND INDCLIENT_PID_INV_NUM = PIDDOCS_INV_NUM
                          AND PIDDOCS_PID_TYPE = 'DL')
                       DRIV_LIC,
                   CLIENTS_PAN_GIR_NUM
                       TIN,
                   CLIENTS_VIN_NUM
                       VIN,
                   CLIENTS_SEGMENT_CODE,
                   GET_MOBILE_NUM (CLIENTS_CODE)
                       MOBILE,
                   (SELECT NVL (INDCLIENT_EMAIL_ADDR1, INDCLIENT_EMAIL_ADDR2)
                      FROM INDCLIENTS
                     WHERE INDCLIENT_CODE = CLIENTS_CODE)
                       EMAIL,
                   CASE
                       WHEN TRIM (TO_CHAR (CLIENTS_BIRTH_DATE, 'YYYY-MM-DD'))
                                IS NULL
                       THEN
                           (SELECT INDCLIENT_BIRTH_DATE
                              FROM indclients
                             WHERE INDCLIENT_CODE = W_CLIENTS_CODE)
                       ELSE
                           NULL
                   END
                       DOB
             FROM CLIENTS, MBRN
            WHERE     CLIENTS_HOME_BRN_CODE = MBRN_CODE
                  AND CLIENTS_CODE = W_CLIENTS_CODE)
    LOOP
        --W_TEXT := W_TEXT || '"accounts":[';


        FOR ACNT
            IN (SELECT ACNTS_INTERNAL_ACNUM,
                       ACNTS_PROD_CODE,
                       INITCAP (PRODUCT_NAME)
                           PRODUCT_NAME,
                       PRODUCT_FOR_DEPOSITS,
                       PRODUCT_FOR_LOANS,
                       PRODUCT_FOR_RUN_ACS,
                       PRODUCT_CONTRACT_ALLOWED,
                       INITCAP (ACNTS_AC_NAME1 || ACNTS_AC_NAME2)
                           ACNTS_AC_NAME,
                       ACNTS_AC_TYPE,
                       ACNTS_AC_SUB_TYPE,
                       ACNTS_OPENING_DATE,
                       ACNTS_CURR_CODE,
                       ACNTS_BRN_CODE,
                       INITCAP (MBRN_NAME)
                           MBRN_NAME,
                       (SELECT DISTRICT_NAME
                         FROM district
                        WHERE (DISTRICT_CNTRY_CODE,
                               DISTRICT_STATE_CODE,
                               DISTRICT_CODE) IN
                                  ( (SELECT LOCN_CNTRY_CODE,
                                            LOCN_STATE_CODE,
                                            LOCN_DISTRICT_CODE
                                     FROM LOCATION
                                    WHERE LOCN_CODE =
                                          (SELECT MBRN_LOCN_CODE
                                             FROM MBRN
                                            WHERE MBRN_CODE = ACNTS_BRN_CODE))))
                           MBRN_LOC,
                       (SELECT COUNT (*)     SMS_SERVICE_ACTIVE
                         FROM MOBILEREG
                        WHERE     INT_ACNUM = ACNTS_INTERNAL_ACNUM
                              AND SERVICE1 = 1)
                           SMS_SERVICE_ACTIVE,
                       ACNTS_CLOSURE_DATE
                           CLS_DATE,
                       ACNTS_DORMANT_ACNT
                           DORM_ACNT,
                       ACNTS_INOP_ACNT
                           INOP_ACNT,
                       ACNTS_DECEASED_APPL
                           DECSED_ACNT,
                       ACNTS_ABB_TRAN_ALLOWED
                           ABB_ALLOWD,
                       ACNTS_ATM_OPERN
                 FROM ACNTS, MBRN, PRODUCTS
                WHERE     ACNTS_CLIENT_NUM = W_CLIENTS_CODE
                      AND ACNTS_BRN_CODE = MBRN_CODE
                      AND PRODUCT_CODE = ACNTS_PROD_CODE
                      AND ACNTS_INTERNAL_ACNUM = W_INTERNAL_ACNUM)
        LOOP
            --W_TEXT := W_TEXT || '{';
            W_ACTUAL_ACCOUNT :=
                FACNO (W_ENTITY_NUM, ACNT.ACNTS_INTERNAL_ACNUM);

            SELECT FN_GET_ASON_ACBAL (W_ENTITY_NUM,
                                      ACNT.ACNTS_INTERNAL_ACNUM,
                                      ACNT.ACNTS_CURR_CODE,
                                      W_CBD,
                                      W_CBD)
              INTO W_ACCOUNT_BALANCE
              FROM DUAL;



            SELECT FN_GET_LAST_TRANSACTION (ACNT.ACNTS_INTERNAL_ACNUM, 10, 0)
              INTO W_LAST_5_TRANSACTION
              FROM DUAL;



            SELECT INITCAP (ACTYPE_DESCN)
              INTO W_ACTYPE_NAME
              FROM ACTYPES
             WHERE ACTYPE_CODE = ACNT.ACNTS_AC_TYPE;

            IF ACNT.PRODUCT_FOR_LOANS = '1'
            THEN
                W_INT_RATE :=
                    FN_GET_LNINTRATE (W_ENTITY_NUM,
                                      ACNT.ACNTS_INTERNAL_ACNUM);
                SP_GET_ASON_LNPRIN_BAL (W_ENTITY_NUM,
                                        ACNT.ACNTS_INTERNAL_ACNUM,
                                        ACNT.ACNTS_CURR_CODE,
                                        W_CBD,
                                        W_CBD,
                                        0,
                                        W_PRIN_BAL,
                                        W_INT_BAL,
                                        W_CHG_BAL);


                BEGIN
                    SELECT (SELECT CLIENTS_NAME
                              FROM clients
                             WHERE CLIENTS_CODE = LNGUAR_GUAR_CLIENT_CODE)    CLIENTS_NAME
                      INTO GUR_CLIENTS_NAME_ONE
                      FROM LNACGUAR
                     WHERE     LNGUAR_ENTITY_NUM = W_ENTITY_NUM
                           AND LNGUAR_INTERNAL_ACNUM =
                               ACNT.ACNTS_INTERNAL_ACNUM
                           AND LNGUAR_GUAR_COOBLIGANT = 'G'
                           AND LNGUAR_SL_NUM = 1;
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        GUR_CLIENTS_NAME_ONE := 'NO GUARANTOR FOUND';
                END;


                BEGIN
                   <<OUTSTANDING_BALANCE>>
                    W_OUTSTAN_BAL :=
                        FN_GET_ASON_ACBAL (W_ENTITY_NUM,
                                           ACNT.ACNTS_INTERNAL_ACNUM,
                                           ACNT.ACNTS_CURR_CODE,
                                           W_CBD,
                                           W_CBD);
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        W_OUTSTAN_BAL := 0;
                END OUTSTANDING_BALANCE;


                BEGIN
                    SELECT (SELECT CLIENTS_NAME
                              FROM clients
                             WHERE CLIENTS_CODE = LNGUAR_GUAR_CLIENT_CODE)    CLIENTS_NAME
                      INTO GUR_CLIENTS_NAME_TWO
                      FROM LNACGUAR
                     WHERE     LNGUAR_ENTITY_NUM = W_ENTITY_NUM
                           AND LNGUAR_INTERNAL_ACNUM =
                               ACNT.ACNTS_INTERNAL_ACNUM
                           AND LNGUAR_GUAR_COOBLIGANT = 'G'
                           AND LNGUAR_SL_NUM = 2;
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        GUR_CLIENTS_NAME_TWO := 'NO GUARANTOR FOUND';
                END;

                BEGIN
                    SELECT (SELECT RELATION_DESCN
                              FROM RELATION
                             WHERE RELATION_CODE = LNGUAR_RELATION_CODE)    RELATION_DESCN
                      INTO GUR_RELATION_DESCN_ONE
                      FROM LNACGUAR
                     WHERE     LNGUAR_ENTITY_NUM = W_ENTITY_NUM
                           AND LNGUAR_INTERNAL_ACNUM =
                               ACNT.ACNTS_INTERNAL_ACNUM
                           AND LNGUAR_GUAR_COOBLIGANT = 'G'
                           AND LNGUAR_SL_NUM = 1;
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        GUR_RELATION_DESCN_ONE := 'NO GUARANTOR FOUND';
                END;

                BEGIN
                    SELECT (SELECT RELATION_DESCN
                              FROM RELATION
                             WHERE RELATION_CODE = LNGUAR_RELATION_CODE)    RELATION_DESCN
                      INTO GUR_RELATION_DESCN_TWO
                      FROM LNACGUAR
                     WHERE     LNGUAR_ENTITY_NUM = W_ENTITY_NUM
                           AND LNGUAR_INTERNAL_ACNUM =
                               ACNT.ACNTS_INTERNAL_ACNUM
                           AND LNGUAR_GUAR_COOBLIGANT = 'G'
                           AND LNGUAR_SL_NUM = 2;
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        GUR_RELATION_DESCN_TWO := 'NO GUARANTOR FOUND';
                END;


                BEGIN
                    SELECT LNACNT_INT_ACCR_UPTO, LNACNT_INT_APPLIED_UPTO_DATE
                      INTO INT_ACCR_UPTO, INT_APPLIED_UPTO_DATE
                      FROM LOANACNTS
                     WHERE     LNACNT_ENTITY_NUM = W_ENTITY_NUM
                           AND LNACNT_INTERNAL_ACNUM =
                               ACNT.ACNTS_INTERNAL_ACNUM;
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        INT_ACCR_UPTO := NULL;
                        INT_APPLIED_UPTO_DATE := NULL;
                END;

                W_DUE_OVERDUE_AMT :=
                    FN_GET_OD_AMT (W_ENTITY_NUM,
                                   ACNT.ACNTS_INTERNAL_ACNUM,
                                   W_CBD,
                                   W_CBD);


                BEGIN
                    SELECT ABS (SUM (NVL (LOANIA_INT_AMT_RND, 0)))    ACCRUAL_AMT
                      INTO W_ACCRUAL_AMOUNT
                      FROM LOANIA, LOANACNTS
                     WHERE     LOANIA_ENTITY_NUM = W_ENTITY_NUM
                           AND LOANIA_BRN_CODE = ACNT.ACNTS_BRN_CODE
                           AND LOANIA_ACNT_NUM = LNACNT_INTERNAL_ACNUM
                           AND LNACNT_INTERNAL_ACNUM =
                               ACNT.ACNTS_INTERNAL_ACNUM
                           --AND LOANIA_VALUE_DATE > LNACNT_INT_ACCR_UPTO
                           AND LNACNT_ENTITY_NUM = W_ENTITY_NUM;
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        W_ACCRUAL_AMOUNT := 0;
                END;


                BEGIN
                    SELECT LNSUSPBAL_SUSP_BAL
                      INTO W_SUSP_BAL
                      FROM LNSUSPBAL
                     WHERE     LNSUSPBAL_ENTITY_NUM = W_ENTITY_NUM
                           AND LNSUSPBAL_ACNT_NUM = ACNT.ACNTS_INTERNAL_ACNUM
                           AND LNSUSPBAL_CURR_CODE = ACNT.ACNTS_CURR_CODE;
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        W_SUSP_BAL := 0;
                END;



                BEGIN
                    SELECT ABS (LNINTAPPL_ACT_INT_AMT)
                      INTO W_LAST_INT_POSTING_AMT
                      FROM LNINTAPPL
                     WHERE     LNINTAPPL_ENTITY_NUM = W_ENTITY_NUM
                           AND LNINTAPPL_BRN_CODE = ACNT.ACNTS_BRN_CODE
                           AND LNINTAPPL_ACNT_NUM = ACNT.ACNTS_INTERNAL_ACNUM
                           AND (LNINTAPPL_APPL_DATE) =
                               (SELECT MAX (LNINTAPPL_APPL_DATE)
                                 FROM LNINTAPPL
                                WHERE     LNINTAPPL_ENTITY_NUM = W_ENTITY_NUM
                                      AND LNINTAPPL_BRN_CODE =
                                          ACNT.ACNTS_BRN_CODE
                                      AND LNINTAPPL_ACNT_NUM =
                                          ACNT.ACNTS_INTERNAL_ACNUM);
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        W_LAST_INT_POSTING_AMT := 0;
                END;

                BEGIN
                    SELECT ABS (SUM (LNINTAPPL_ACT_INT_AMT))
                      INTO W_INT_POSTED_AMT_TILL_DATE
                      FROM LNINTAPPL
                     WHERE     LNINTAPPL_ENTITY_NUM = W_ENTITY_NUM
                           AND LNINTAPPL_BRN_CODE = ACNT.ACNTS_BRN_CODE
                           AND LNINTAPPL_ACNT_NUM = ACNT.ACNTS_INTERNAL_ACNUM;
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        W_INT_POSTED_AMT_TILL_DATE := 0;
                END;


                BEGIN
                    /*
                        SELECT FACNO (1, ACNTLIEN_INTERNAL_ACNUM),
                               ACNTLIEN_INTERNAL_ACNUM,
                               ACNTLIEN_LIEN_TO_BRN
                          INTO W_LIEN_DEPOSIT_ACC_NUM,
                               W_ACNTLIEN_INTERNAL_ACNUM,
                               W_ACNTLIEN_LIEN_TO_BRN
                          FROM ACNTLIEN
                         WHERE     ACNTLIEN_ENTITY_NUM = W_ENTITY_NUM
                               AND ACNTLIEN_LIEN_TO_ACNUM =
                                   ACNT.ACNTS_INTERNAL_ACNUM
                               AND ACNTLIEN_REVOKED_ON IS NULL;
                               */

                    SELECT FACNO (1, DEPACLIEN_DEP_AC_NUM),
                           DEPACLIEN_DEP_AC_NUM,
                           DEPACLIEN_LIEN_TO_BRN
                      INTO W_LIEN_DEPOSIT_ACC_NUM,
                           W_ACNTLIEN_INTERNAL_ACNUM,
                           W_ACNTLIEN_LIEN_TO_BRN
                      FROM DEPACCLIEN
                     WHERE     DEPACLIEN_ENTITY_NUM = W_ENTITY_NUM
                           AND DEPACLIEN_LIEN_TO_ACNUM =
                               ACNT.ACNTS_INTERNAL_ACNUM
                           AND DEPACLIEN_REVOKED_ON IS NULL;


                    IF W_LIEN_DEPOSIT_ACC_NUM IS NOT NULL
                    THEN
                        W_LIENT_DEPOSIT_ACC_BALANCE :=
                            FN_GET_ASON_ACBAL (W_ENTITY_NUM,
                                               W_ACNTLIEN_INTERNAL_ACNUM,
                                               ACNT.ACNTS_CURR_CODE,
                                               W_CBD,
                                               W_CBD);

                        GET_RD_INST_DETAILS (W_ENTITY_NUM,
                                             W_ACNTLIEN_INTERNAL_ACNUM,
                                             W_CBD,
                                             0,
                                             w_DEP_PERIOD,
                                             w_MAT_DATE,
                                             w_INST_AMT,
                                             W_RD_INT_RATE,
                                             w_NOOF_INST_PAID,
                                             w_TOT_INST_AMT_PAID,
                                             w_NOOF_INST_DUE,
                                             w_NOOF_INST_ADV_PAID,
                                             w_NOOF_INST_OVERDUE,
                                             w_PROD_CUTOFF_DAY,
                                             w_TOT_PENALY_AMT,
                                             w_AUTO_REC_ENABLED,
                                             w_AUTOREC_INT_ACNO,
                                             w_AUTOREC_START_DAY);
                    END IF;
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        W_LIEN_DEPOSIT_ACC_NUM := NULL;
                        W_LIENT_DEPOSIT_ACC_BALANCE := 0;
                END;

                BEGIN
                    SELECT PBDCONT_MAT_DATE, PBDCONT_MAT_VALUE
                      INTO W_LIEN_DEPOSIT_MATURITY_DATE,
                           W_LIEN_DEPOSIT_MATURITY_VALUE
                      FROM PBDCONTRACT
                     WHERE     PBDCONT_ENTITY_NUM = W_ENTITY_NUM
                           AND PBDCONT_BRN_CODE = W_ACNTLIEN_LIEN_TO_BRN
                           AND PBDCONT_DEP_AC_NUM = W_ACNTLIEN_INTERNAL_ACNUM
                           AND PBDCONT_CLOSURE_DATE IS NULL;
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        W_LIEN_DEPOSIT_MATURITY_DATE := NULL;
                        W_LIEN_DEPOSIT_MATURITY_VALUE := NULL;
                END;

                BEGIN
                    SELECT LNPRD_SIMPLE_COMP_INT
                      INTO W_CALCULATION_BASIS
                      FROM LNPRODPM
                     WHERE LNPRD_PROD_CODE = ACNT.ACNTS_PROD_CODE;
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        W_CALCULATION_BASIS := NULL;
                END;

                BEGIN
                   <<INTEREST_APPLY_FRREQUENCY>>
                    SELECT LNPRD_INT_APPL_FREQ
                      INTO W_INT_APPL_FREQ
                      FROM LNPRODPM
                     WHERE LNPRD_PROD_CODE = ACNT.ACNTS_PROD_CODE;
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        W_INT_APPL_FREQ := NULL;
                END INTEREST_APPLY_FRREQUENCY;

                BEGIN
                   <<INSTALLMENT_SIZE>>
                    SELECT LNACRSHDTL_REPAY_AMT,
                           LNACRSHDTL_NUM_OF_INSTALLMENT,
                           LNACRSHDTL_REPAY_FROM_DATE
                      INTO W_REPAY_AMT,
                           W_NUM_OF_INSTALLMENT,
                           W_REPAY_FROM_DATE
                      FROM LNACRSHDTL
                     WHERE     LNACRSHDTL_ENTITY_NUM = 1
                           AND (LNACRSHDTL_INTERNAL_ACNUM,
                                LNACRSHDTL_EFF_DATE) IN
                                   (  SELECT LNACRSHDTL_INTERNAL_ACNUM,
                                             MAX (LNACRSHDTL_EFF_DATE)    LNACRSHDTL_EFF_DATE
                                       FROM LNACRSHDTL
                                      WHERE     LNACRSHDTL_ENTITY_NUM =
                                                W_ENTITY_NUM
                                            AND LNACRSHDTL_INTERNAL_ACNUM =
                                                ACNT.ACNTS_INTERNAL_ACNUM
                                   GROUP BY LNACRSHDTL_INTERNAL_ACNUM);
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        W_REPAY_AMT := NULL;
                END INSTALLMENT_SIZE;


                BEGIN
                   <<NOI_DUE>>
                    SELECT LNACRSDTL_REPAY_FREQ
                      INTO V_FREG
                      FROM LNACRSDTL
                     WHERE     LNACRSDTL_ENTITY_NUM = W_ENTITY_NUM
                           AND LNACRSDTL_INTERNAL_ACNUM =
                               ACNT.ACNTS_INTERNAL_ACNUM;



                    IF V_FREG = 'M'
                    THEN
                        V_INST_FREQ := 1;
                    ELSIF V_FREG = 'Q'
                    THEN
                        V_INST_FREQ := 3;
                    ELSIF V_FREG = 'H'
                    THEN
                        V_INST_FREQ := 6;
                    ELSIF V_FREG = 'Y'
                    THEN
                        V_INST_FREQ := 12;
                    ELSE
                        V_INST_FREQ := 1;
                    END IF;



                    SELECT FN_GET_PAID_AMT (W_ENTITY_NUM,
                                            ACNT.ACNTS_INTERNAL_ACNUM,
                                            W_CBD)
                      INTO V_PAID_AMT
                      FROM DUAL;



                    SELECT LNACRSDTL_REPAY_AMT, LNACRSDTL_NUM_OF_INSTALLMENT
                      INTO V_INST_SIZE, V_NUM_INS
                      FROM LNACRSDTL
                     WHERE     LNACRSDTL_ENTITY_NUM = W_ENTITY_NUM
                           AND LNACRSDTL_INTERNAL_ACNUM =
                               ACNT.ACNTS_INTERNAL_ACNUM;



                    V_NOI := TRUNC ((V_INST_FREQ * V_PAID_AMT) / V_INST_SIZE);
                    V_NOI_DUE := V_NUM_INS - V_NOI;
                -- DBMS_OUTPUT.PUT_LINE('paid amr '||V_PAID_AMT||' '||V_NOI ||' '|| V_NOI_DUE);

                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        V_INST_FREQ := NULL;
                END;



                BEGIN
                   <<SANCTION_RESCHEDULED_DATE_AMT>>
                    SELECT MAX (LIMLNEHIST_LIMIT_EXPIRY_DATE),
                           MAX (LIMLNEHIST_SANCTION_AMT),
                           MAX (LIMLNEHIST_DATE_OF_SANCTION),
                           COUNT (*)
                      INTO V_LIMIT_EXPIRY_DATE,
                           V_FIRST_SANC_LIMIT,
                           V_FIRST_SANC_DATE,
                           W_COUNTER
                      FROM LIMITLINEHIST
                     WHERE     LIMLNEHIST_ENTITY_NUM = 1
                           AND (LIMLNEHIST_CLIENT_CODE,
                                LIMLNEHIST_LIMIT_LINE_NUM) =
                               (SELECT ACASLLDTL.ACASLLDTL_CLIENT_NUM,
                                       ACASLLDTL.ACASLLDTL_LIMIT_LINE_NUM
                                 FROM ACASLLDTL
                                WHERE     ACASLLDTL_ENTITY_NUM = W_ENTITY_NUM
                                      AND ACASLLDTL_INTERNAL_ACNUM =
                                          ACNT.ACNTS_INTERNAL_ACNUM)
                           AND LIMLNEHIST_EFF_DATE <= W_CBD;
                /*
                    IF W_COUNTER >= 1
                    THEN
                        V_NEWEAL_TIME := W_COUNTER - 1;

                        SELECT LIMIT_EXPIRY_DATE, MIN_SANC_AMT, MIN_SANC_DATE
                          INTO V_LIMIT_EXPIRY_DATE,
                               V_FIRST_SANC_LIMIT,
                               V_FIRST_SANC_DATE
                          FROM (  SELECT L.LIMLNEHIST_SAUTH_CODE,
                                         L.LIMLNEHIST_LIMIT_EXPIRY_DATE
                                             LIMIT_EXPIRY_DATE,
                                         L.LIMLNEHIST_EFF_DATE,
                                         LEAD (LIMLNEHIST_SANCTION_AMT,
                                               V_NEWEAL_TIME)
                                             OVER (
                                                 ORDER BY
                                                     LIMLNEHIST_EFF_DATE ASC)
                                             MIN_SANC_AMT,
                                         LEAD (LIMLNEHIST_DATE_OF_SANCTION,
                                               V_NEWEAL_TIME)
                                             OVER (
                                                 ORDER BY
                                                     LIMLNEHIST_EFF_DATE ASC)
                                             MIN_SANC_DATE,
                                           LIMLNEHIST_SANCTION_AMT
                                         - LEAD (LIMLNEHIST_SANCTION_AMT, 1)
                                               OVER (
                                                   ORDER BY
                                                       LIMLNEHIST_EFF_DATE ASC)
                                             ENHANCEMENT
                                    FROM LIMITLINEHIST L
                                   WHERE     LIMLNEHIST_ENTITY_NUM = 1
                                         AND (LIMLNEHIST_CLIENT_CODE,
                                              LIMLNEHIST_LIMIT_LINE_NUM) =
                                             (SELECT ACASLLDTL.ACASLLDTL_CLIENT_NUM,
                                                     ACASLLDTL.ACASLLDTL_LIMIT_LINE_NUM
                                               FROM ACASLLDTL
                                              WHERE     ACASLLDTL_ENTITY_NUM =
                                                        W_ENTITY_NUM
                                                    AND ACASLLDTL_INTERNAL_ACNUM =
                                                        ACNT.ACNTS_INTERNAL_ACNUM)
                                         AND LIMLNEHIST_EFF_DATE <= W_CBD
                                ORDER BY LIMLNEHIST_EFF_DATE ASC) A
                         WHERE A.MIN_SANC_DATE IS NOT NULL;
                    --DBMS_OUTPUT.PUT_LINE(V_LIMIT_EXPIRY_DATE);


                    END IF;

                      */
                END SANCTION_RESCHEDULED_DATE_AMT;

                BEGIN
                   <<SANCTION_RESCHEDULED_AMT_DATE>>
                    SELECT LNACRSH_REPH_ON_AMT, LNACRSH_EFF_DATE
                      INTO W__RESCHEDULED_AMT, W_RESCHEDULED_DATE
                      FROM LNACRSHIST
                     WHERE     LNACRSH_REPHASEMENT_ENTRY = W_ENTITY_NUM
                           AND (LNACRSH_INTERNAL_ACNUM, LNACRSH_EFF_DATE) =
                               (  SELECT L.LNACRSH_INTERNAL_ACNUM,
                                         MAX (L.LNACRSH_EFF_DATE)
                                   FROM LNACRSHIST L
                                  WHERE     L.LNACRSH_REPHASEMENT_ENTRY =
                                            W_ENTITY_NUM
                                        AND L.LNACRSH_PURPOSE = 'R'
                                        AND L.LNACRSH_INTERNAL_ACNUM =
                                            ACNT.ACNTS_INTERNAL_ACNUM
                               GROUP BY L.LNACRSH_INTERNAL_ACNUM);

                      SELECT COUNT (*)
                        INTO W_NOOF_RESCHEDULED
                        FROM LNACRSHIST L
                       WHERE     L.LNACRSH_REPHASEMENT_ENTRY = W_ENTITY_NUM
                             AND L.LNACRSH_PURPOSE = 'R'
                             AND L.LNACRSH_INTERNAL_ACNUM =
                                 ACNT.ACNTS_INTERNAL_ACNUM
                    GROUP BY L.LNACRSH_INTERNAL_ACNUM;
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        W__RESCHEDULED_AMT := NULL;
                        W_RESCHEDULED_DATE := NULL;
                        W_NOOF_RESCHEDULED := NULL;
                END SANCTION_RESCHEDULED_AMT_DATE;
            ELSE
                IF FN_IS_SND_PRODUCT (ACNT.ACNTS_PROD_CODE) = TRUE
                THEN
                    W_INT_RATE :=
                        FN_GET_SND_INT_RATE (W_ENTITY_NUM,
                                             ACNT.ACNTS_BRN_CODE,
                                             ACNT.ACNTS_INTERNAL_ACNUM,
                                             'C',
                                             W_CBD);
                ELSIF     ACNT.PRODUCT_FOR_DEPOSITS = '1'
                      AND ACNT.PRODUCT_FOR_RUN_ACS = '1'
                THEN
                    W_INT_RATE :=
                        FN_GET_INTRATE_RUN_ACS_NEW (
                            ACNT.ACNTS_INTERNAL_ACNUM,
                            ACNT.ACNTS_PROD_CODE,
                            ACNT.ACNTS_CURR_CODE,
                            ACNT.ACNTS_AC_TYPE,
                            ACNT.ACNTS_AC_SUB_TYPE,
                            'C',
                            W_CBD);
                ELSE
                    SELECT NVL (PBDCONT_ACTUAL_INT_RATE,
                                PBDCONT_STD_INT_RATE)
                      INTO W_INT_RATE
                      FROM PBDCONTRACT
                     WHERE     PBDCONT_ENTITY_NUM = 1
                           AND PBDCONT_BRN_CODE = ACNT.ACNTS_BRN_CODE
                           AND PBDCONT_DEP_AC_NUM = ACNT.ACNTS_INTERNAL_ACNUM
                           AND PBDCONT_CLOSURE_DATE IS NULL;
                END IF;
            END IF;

            BEGIN
                SELECT ACNTEXCAMT_EXCISE_AMT
                  INTO W_EXCISE_AMT
                  FROM ACNTEXCISEAMT
                 WHERE     ACNTEXCAMT_ENTITY_NUM = W_ENTITY_NUM
                       AND ACNTEXCAMT_INTERNAL_ACNUM =
                           ACNT.ACNTS_INTERNAL_ACNUM
                       AND ACNTEXCAMT_PROCESS_DATE =
                           (SELECT MAX (ACNTEXCAMT_PROCESS_DATE)
                             FROM ACNTEXCISEAMT
                            WHERE     ACNTEXCAMT_ENTITY_NUM = W_ENTITY_NUM
                                  AND ACNTEXCAMT_INTERNAL_ACNUM =
                                      ACNT.ACNTS_INTERNAL_ACNUM);
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    W_EXCISE_AMT := NULL;
                WHEN OTHERS
                THEN
                    W_EXCISE_AMT := NULL;
            END;


            IF ACNT.PRODUCT_FOR_LOANS = '11'
            THEN
                SELECT A1.ASSETCD_DESCN
                  INTO W_AC_STATUS
                  FROM ASSETCLS A, ASSETCD A1
                 WHERE     A.ASSETCLS_ENTITY_NUM = 1
                       AND A.ASSETCLS_ASSET_CODE = A1.ASSETCD_CODE
                       AND A.ASSETCLS_INTERNAL_ACNUM =
                           ACNT.ACNTS_INTERNAL_ACNUM;
            ELSE
                IF ACNT.CLS_DATE IS NOT NULL
                THEN
                    W_AC_STATUS := 'closed';
                ELSIF (    ACNT.DECSED_ACNT = '1'
                       AND (ACNT.INOP_ACNT = '0' OR ACNT.INOP_ACNT = '1')
                       AND (ACNT.DORM_ACNT = '0' OR ACNT.DORM_ACNT = '1'))
                THEN
                    W_AC_STATUS := 'deceased';
                ELSIF (    ACNT.DECSED_ACNT = '0'
                       AND ACNT.DORM_ACNT = '1'
                       AND (ACNT.INOP_ACNT = '0' OR ACNT.INOP_ACNT = '1'))
                THEN
                    W_AC_STATUS := 'dormant';
                ELSIF (ACNT.INOP_ACNT = '1' AND ACNT.DORM_ACNT = '0')
                THEN
                    W_AC_STATUS := 'inoperative';
                ELSE
                    W_AC_STATUS := 'active';
                END IF;
            END IF;

            BEGIN
               <<RD_INFOR>>
                IF     ACNT.PRODUCT_FOR_DEPOSITS = '1'
                   AND ACNT.PRODUCT_FOR_RUN_ACS = '0'
                   AND ACNT.PRODUCT_CONTRACT_ALLOWED = '0'
                THEN
                    GET_RD_INST_DETAILS (W_ENTITY_NUM,
                                         ACNT.ACNTS_INTERNAL_ACNUM,
                                         W_CBD,
                                         0,
                                         w_DEP_PERIOD,
                                         w_MAT_DATE,
                                         w_INST_AMT,
                                         W_RD_INT_RATE,
                                         w_NOOF_INST_PAID,
                                         w_TOT_INST_AMT_PAID,
                                         w_NOOF_INST_DUE,
                                         w_NOOF_INST_ADV_PAID,
                                         w_NOOF_INST_OVERDUE,
                                         w_PROD_CUTOFF_DAY,
                                         w_TOT_PENALY_AMT,
                                         w_AUTO_REC_ENABLED,
                                         w_AUTOREC_INT_ACNO,
                                         w_AUTOREC_START_DAY);


                    SELECT MAX (POST_TRAN_DATE)
                      INTO W_LAST_DATE_OF_INS_PAY
                      FROM RDINS
                     WHERE     RDINS_ENTITY_NUM = W_ENTITY_NUM
                           AND RDINS_RD_AC_NUM = ACNT.ACNTS_INTERNAL_ACNUM
                           AND RDINS_TWDS_INSTLMNT <> 0;
                END IF;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    W_LAST_DATE_OF_INS_PAY := NULL;
            END RD_INFOR;


           <<UNAPPL_INT_AMT>>
            BEGIN
               <<ACCRUAL_FROM_LOANIA>>
                BEGIN
                      SELECT NVL (
                                 ROUND (ABS (SUM (LOANIA_TOTAL_NEW_INT_AMT)),
                                        2),
                                 0),
                             MAX (LOANIA_VALUE_DATE)
                        INTO W_TOT_IA_FROM_LOANIA,
                             W_LATEST_ACC_DATE_FROM_LOANIA
                        FROM LOANIA, LOANACNTS
                       WHERE     LNACNT_ENTITY_NUM = W_ENTITY_NUM
                             AND LNACNT_INTERNAL_ACNUM =
                                 ACNT.ACNTS_INTERNAL_ACNUM
                             AND LOANIA_ENTITY_NUM = W_ENTITY_NUM
                             AND LOANIA_BRN_CODE = ACNT.ACNTS_BRN_CODE
                             AND LOANIA_ACNT_NUM = ACNT.ACNTS_INTERNAL_ACNUM
                             AND LOANIA_ACNT_NUM = LNACNT_INTERNAL_ACNUM
                             AND LOANIA_VALUE_DATE >=
                                 LNACNT_INT_APPLIED_UPTO_DATE
                             AND LOANIA_NPA_STATUS = 0
                    GROUP BY LOANIA_BRN_CODE, LOANIA_ACNT_NUM;
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        W_TOT_IA_FROM_LOANIA := 0;

                        SELECT ACNTS_OPENING_DATE
                          INTO W_LATEST_ACC_DATE_FROM_LOANIA
                          FROM ACNTS
                         WHERE     ACNTS_ENTITY_NUM = W_ENTITY_NUM
                               AND ACNTS_INTERNAL_ACNUM =
                                   ACNT.ACNTS_INTERNAL_ACNUM;
                END ACCRUAL_FROM_LOANIA;

                  SELECT NVL (
                             ROUND (ABS (SUM (LOANIAMRR_TOTAL_NEW_INT_AMT)), 2),
                             0)
                    INTO W_TOT_IA_FROM_LOANIAMRR
                    FROM LOANIAMRR
                   WHERE     LOANIAMRR_ENTITY_NUM = W_ENTITY_NUM
                         AND LOANIAMRR_BRN_CODE = ACNT.ACNTS_BRN_CODE
                         AND LOANIAMRR_ACNT_NUM = ACNT.ACNTS_INTERNAL_ACNUM
                         AND LOANIAMRR_VALUE_DATE >
                             W_LATEST_ACC_DATE_FROM_LOANIA
                         AND LOANIAMRR_NPA_STATUS = 0
                GROUP BY LOANIAMRR_ACNT_NUM;

                SELECT NVL (ROUND (ABS (SUM (RTMPLNIA_INT_AMT)), 2), 0)
                  INTO W_TOT_IA_FROM_LOANIADLY
                  FROM LOANIADLY
                 WHERE     RTMPLNIA_ACNT_NUM = ACNT.ACNTS_INTERNAL_ACNUM
                       AND RTMPLNIA_VALUE_DATE >
                           W_LATEST_ACC_DATE_FROM_LOANIA
                       AND RTMPLNIA_NPA_STATUS = 0;

                UNAPPLIED_INT_AMT :=
                    W_TOT_IA_FROM_LOANIAMRR + W_TOT_IA_FROM_LOANIADLY;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    UNAPPLIED_INT_AMT := 0;
            --W_LAST_DATE_OF_INS_PAY := '01-jan-2018';
            END UNAPPL_INT_AMT;



            BEGIN
                SELECT LAST_USED_CHQ_DATE, LAST_USED_CHQ
                  INTO W_CHQUSAGEDATE, W_CHQUSAGELEFNUM
                  FROM (SELECT ROWNUM                                    SERIAL_NUMBER,
                               LAST_USED_CHQ_DATE,
                               LAST_USED_CHQ,
                               RANK ()
                                   OVER (PARTITION BY LAST_USED_CHQ_DATE
                                         ORDER BY LAST_USED_CHQ DESC)    dest_rank
                          FROM (  SELECT CHQUSG_DATE_OF_USAGE
                                             LAST_USED_CHQ_DATE,
                                            CHQUSG_CHQ_PFX
                                         || '-'
                                         || CHQUSG_CHQ_NUM
                                             LAST_USED_CHQ
                                    FROM CHQUSG
                                   WHERE     CHQUSG_ENTITY_NUM = W_ENTITY_NUM
                                         AND CHQUSG_INTERNAL_AC_NUM =
                                             W_INTERNAL_ACNUM
                                         AND CHQUSG_DATE_OF_USAGE =
                                             (SELECT MAX (CHQUSG_DATE_OF_USAGE)
                                               FROM CHQUSG
                                              WHERE     CHQUSG_ENTITY_NUM =
                                                        W_ENTITY_NUM
                                                    AND CHQUSG_INTERNAL_AC_NUM =
                                                        W_INTERNAL_ACNUM)
                                ORDER BY CHQUSG_USED_IN_TRAN_BATCH DESC,
                                         CHQUSG_USED_IN_TRAN_BATCH_SL DESC))
                 WHERE dest_rank = 1;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    W_CHQUSAGEDATE := '';
                    W_CHQUSAGELEFNUM := '';
            END;


           <<FD_INFO>>
            BEGIN
                IF     ACNT.PRODUCT_FOR_DEPOSITS = '1'
                   AND ACNT.PRODUCT_FOR_RUN_ACS = '0'
                THEN
                    SELECT PBDCONT_AUTOROLL_PERIOD,
                           CASE
                               WHEN PBDCONT_RENEWAL_OPTION = '1' THEN 'YES'
                               ELSE 'NO'
                           END,
                           PBDCONT_INT_CR_TO_ACNT,
                           PBDCONT_AC_DEP_AMT,
                           PBDCONT_MAT_VALUE,
                           PBDCONT_MAT_DATE,
                           PDBCONT_DEP_PRD_MONTHS
                      INTO W_AUTOROLL_PERIOD,
                           W_RENEWAL_OPTION,
                           W_INT_CR_TO_ACNT,
                           W_DEP_AMT,
                           W_MAT_VALUE,
                           W_PBD_MAT_DATE,
                           W_PRD_MONTHS
                      FROM PBDCONTRACT
                     WHERE     PBDCONT_ENTITY_NUM = W_ENTITY_NUM
                           AND PBDCONT_BRN_CODE = ACNT.ACNTS_BRN_CODE
                           AND PBDCONT_DEP_AC_NUM = ACNT.ACNTS_INTERNAL_ACNUM
                           --AND PBDCONT_INT_CR_TO_ACNT = '1'
                           AND PBDCONT_CLOSURE_DATE IS NULL;

                    IF W_INT_CR_TO_ACNT = '1'
                    THEN
                        BEGIN
                            SELECT FACNO (1, PBDCONTDSA_INT_CR_AC_NUM)
                              INTO W_INT_CR_AC_NUM
                              FROM PBDCONTDSA
                             WHERE     PBDCONTDSA_ENTITY_NUM = W_ENTITY_NUM
                                   AND PBDCONTDSA_DEP_AC_NUM =
                                       ACNT.ACNTS_INTERNAL_ACNUM
                                   AND PBDCONTDSA_CLOSURE_STL_AC_NUM IS NULL;
                        EXCEPTION
                            WHEN NO_DATA_FOUND
                            THEN
                                W_INT_CR_AC_NUM := NULL;
                        END;
                    END IF;
                END IF;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    W_INT_CR_AC_NUM := NULL;
                    W_RENEWAL_OPTION := NULL;
                    W_INT_CR_TO_ACNT := NULL;
                    W_DEP_AMT := NULL;
                    W_MAT_VALUE := NULL;
                    W_PBD_MAT_DATE := NULL;
                    W_PRD_MONTHS := NULL;
            END FD_INFO;


            W_KYC_COMPILED :=
                FN_GET_KYC_STATUS (ACNT.ACNTS_INTERNAL_ACNUM,
                                   ACNT.ACNTS_BRN_CODE);


            BEGIN
               <<CASA>>
                IF     ACNT.PRODUCT_FOR_RUN_ACS = '1'
                   AND ACNT.PRODUCT_FOR_DEPOSITS = '1'
                THEN
                    W_ACC_TOTAL_BALANCE :=
                        FN_GET_ASON_ACBAL (W_ENTITY_NUM,
                                           ACNT.ACNTS_INTERNAL_ACNUM,
                                           ACNT.ACNTS_CURR_CODE,
                                           W_CBD,
                                           W_CBD);
                END IF;
            EXCEPTION
                WHEN OTHERS
                THEN
                    W_ACC_TOTAL_BALANCE := 0;
            END CASA;



            IF CLIENT_DATA.NID IS NOT NULL
            THEN
                W_KYC_DOCUMENT_NAME := 'NID';
                W_KYC_DOCUMENT_NUMBER := CLIENT_DATA.NID;
            ELSIF CLIENT_DATA.SID IS NOT NULL
            THEN
                W_KYC_DOCUMENT_NAME := 'SID';
                W_KYC_DOCUMENT_NUMBER := CLIENT_DATA.SID;
            ELSIF CLIENT_DATA.PASSPORT IS NOT NULL
            THEN
                W_KYC_DOCUMENT_NAME := 'PASSPORT';
                W_KYC_DOCUMENT_NUMBER := CLIENT_DATA.PASSPORT;
            ELSIF CLIENT_DATA.BIRTH_CER IS NOT NULL
            THEN
                W_KYC_DOCUMENT_NAME := 'BIRTH_CER';
                W_KYC_DOCUMENT_NUMBER := CLIENT_DATA.BIRTH_CER;
            ELSIF CLIENT_DATA.DRIV_LIC IS NOT NULL
            THEN
                W_KYC_DOCUMENT_NAME := 'DL';
                W_KYC_DOCUMENT_NUMBER := CLIENT_DATA.DRIV_LIC;
            END IF;

           <<TRANSACTION_PROFILE>>
            BEGIN
                --W_TRANSACTION_PROFILE := fn_GET_TRANSACTION_PROFILE ('ACNT.ACNTS_INTERNAL_ACNUM');
                SELECT FN_GET_TRANSACTION_PROFILE (ACNT.ACNTS_INTERNAL_ACNUM)
                  INTO W_TRANSACTION_PROFILE
                  FROM DUAL;
            EXCEPTION
                WHEN OTHERS
                THEN
                    W_TRANSACTION_PROFILE := NULL;
            END;



            W_TEXT := W_TEXT || '{';
            W_TEXT :=
                W_TEXT || '"CLIENT_ID":' || '"' || CLIENT_DATA.ID || '",';
            W_TEXT :=
                   W_TEXT
                || '"ACC_HOLDER_NAME":'
                || '"'
                || ACNT.ACNTS_AC_NAME
                || '",';

            W_TEXT :=
                   W_TEXT
                || '"FATHERS_NAME":'
                || '"'
                || CLIENT_DATA.FATHER_NAME
                || '",';
            W_TEXT :=
                   W_TEXT
                || '"MOTHERS_NAME":'
                || '"'
                || CLIENT_DATA.MOTHER_NAME
                || '",';
            W_TEXT :=
                   W_TEXT
                || '"CUSTOMER_PRE_ADDR":'
                || '"'
                || CLIENT_DATA.PRESENT_ADDRESS
                || '",';
            W_TEXT :=
                   W_TEXT
                || '"CUSTOMER_PAR_ADDR":'
                || '"'
                || CLIENT_DATA.PERMANENT_ADDRESS
                || '",';

            W_TEXT :=
                   W_TEXT
                || '"KYC_DOCUMENT_NAME":'
                || '"'
                || W_KYC_DOCUMENT_NAME
                || '",';

            W_TEXT :=
                   W_TEXT
                || '"KYC_DOCUMENT_NUMBER":'
                || '"'
                || W_KYC_DOCUMENT_NUMBER
                || '",';



            W_TEXT :=
                W_TEXT || '"ETIN_NUM":' || '"' || CLIENT_DATA.TIN || '",';
            W_TEXT :=
                   W_TEXT
                || '"REGISTERED_MOBILE_NUM":'
                || '"'
                || CLIENT_DATA.MOBILE
                || '",';
            W_TEXT := W_TEXT || '"DOB":' || '"' || CLIENT_DATA.DOB || '",';
            W_TEXT :=
                   W_TEXT
                || '"ACCOUNT_NUMBER":'
                || '"'
                || W_ACTUAL_ACCOUNT
                || '",';
            W_TEXT :=
                   W_TEXT
                || '"PRODUCT_CODE":'
                || '"'
                || ACNT.ACNTS_PROD_CODE
                || '",';

            W_TEXT :=
                   W_TEXT
                || '"PRODUCT_NAME":'
                || '"'
                || ACNT.PRODUCT_NAME
                || '",';
            W_TEXT :=
                   W_TEXT
                || '"ACC_OPEN_DATE":'
                || '"'
                || TO_CHAR (ACNT.ACNTS_OPENING_DATE, 'YYYY-MM-DD')
                || '",';
            W_TEXT :=
                W_TEXT || '"ACC_BRN_NAME":' || '"' || ACNT.MBRN_NAME || '",';
            W_TEXT :=
                   W_TEXT
                || '"ACC_BRN_DIST_NAME":'
                || '"'
                || ACNT.MBRN_LOC
                || '",';
            W_TEXT :=
                W_TEXT || '"CURRENT_INT_RATE":' || '"' || W_INT_RATE || '",';
            W_TEXT :=
                   W_TEXT
                || '"LAST_EXCISE_DUTY_DEDUCT_AMT":'
                || '"'
                || W_CHG_BAL
                || '",';

            IF ACNT.SMS_SERVICE_ACTIVE = 1
            THEN
                W_TEXT := W_TEXT || '"SMS_SERVICE":' || '"active",';
            ELSE
                W_TEXT := W_TEXT || '"SMS_SERVICE":' || '"inactive",';
            END IF;


            W_TEXT :=
                W_TEXT || '"KYC_COMPILED":' || '"' || W_KYC_COMPILED || '",';
            W_TEXT :=
                   W_TEXT
                || '"INSTALLMENT_DUE_DATE":'
                || '"'
                || TO_CHAR (W_REPAY_FROM_DATE, 'YYYY-MM-DD')
                || '",';
            --W_TEXT := W_TEXT || '"TOTAL_NOOF_INSTALLMENT":"need to work",';

            W_TEXT :=
                   W_TEXT
                || '"SANCTION_RESCHEDULED_AMT":'
                || '"'
                || W__RESCHEDULED_AMT
                || '",';
            W_TEXT :=
                   W_TEXT
                || '"SANCTION_RESCHEDULED_DATE":'
                || '"'
                || TO_CHAR (W_RESCHEDULED_DATE, 'YYYY-MM-DD')
                || '",';

            W_TEXT :=
                   W_TEXT
                || '"NOOF_RESCHEDULED_TILL":'
                || '"'
                || TO_CHAR (W_NOOF_RESCHEDULED)
                || '",';
            W_TEXT :=
                   W_TEXT
                || '"NOOF_INSTALLMENT_DUE_OF_LIEN_DEPOSIT_AC":'
                || '"'
                || W_NOOF_INST_DUE
                || '",';

            W_TEXT :=
                   W_TEXT
                || '"NOOF_INSTALLMENT_DUE_FOR_TILL_DATE":'
                || '"'
                || V_NOI_DUE
                || '",';
            W_TEXT :=
                   W_TEXT
                || '"INSTALLMENT_SIZE_OF_LIEN_DEPOSIT_ACC":'
                || '"'
                || W_INST_AMT
                || '",';

            W_TEXT :=
                W_TEXT || '"INSTALLMENT_SIZE":' || '"' || W_REPAY_AMT || '",';



            W_TEXT :=
                   W_TEXT
                || '"LOAN_ACC_NUMBER":'
                || '"'
                || CASE
                       WHEN ACNT.PRODUCT_FOR_LOANS = '1'
                       THEN
                           W_ACTUAL_ACCOUNT
                       ELSE
                           NULL
                   END
                || '",';

            W_TEXT :=
                   W_TEXT
                || '"LIEN_DEPOSIT_MATURITY_VALUE":'
                || '"'
                || W_LIEN_DEPOSIT_MATURITY_VALUE
                || '",';
            W_TEXT :=
                   W_TEXT
                || '"LIEN_DEPOSIT_MATURITY_DATE":'
                || '"'
                || TO_CHAR (W_LIEN_DEPOSIT_MATURITY_DATE, 'YYYY-MM-DD')
                || '",';

            W_TEXT :=
                   W_TEXT
                || '"LIEN_DEPOSIT_ACC_NUM":'
                || '"'
                || W_LIEN_DEPOSIT_ACC_NUM
                || '",';
            W_TEXT :=
                   W_TEXT
                || '"GUARANTOR_FULL_NAME1":'
                || '"'
                || GUR_CLIENTS_NAME_ONE
                || '",';
            W_TEXT :=
                   W_TEXT
                || '"GUARANTOR_FULL_NAME2":'
                || '"'
                || GUR_CLIENTS_NAME_TWO
                || '",';

            W_TEXT :=
                   W_TEXT
                || '"GUARANTOR1_REL_WITH_CUSTOMER":'
                || '"'
                || GUR_RELATION_DESCN_ONE
                || '",';
            W_TEXT :=
                   W_TEXT
                || '"GUARANTOR2_REL_WITH_CUSTOMER":'
                || '"'
                || GUR_RELATION_DESCN_TWO
                || '",';


            W_TEXT :=
                   W_TEXT
                || '"SANCTION_RENEWAL_DATE":'
                || '"'
                || TO_CHAR (V_FIRST_SANC_DATE, 'YYYY-MM-DD')
                || '",';
            W_TEXT :=
                   W_TEXT
                || '"SANCTION_RENEWAL_AMT":'
                || '"'
                || V_FIRST_SANC_LIMIT
                || '",';
            W_TEXT :=
                   W_TEXT
                || '"DUE_OVERDUE_AMT":'
                || '"'
                || W_DUE_OVERDUE_AMT
                || '",';

            W_TEXT :=
                   W_TEXT
                || '"PRINCIPAL_AMT_OF_OS":'
                || '"'
                || W_PRIN_BAL
                || '",';
            W_TEXT :=
                W_TEXT || '"INTEREST_AMT_OF_OS":' || '"' || W_INT_BAL || '",';
            W_TEXT :=
                W_TEXT || '"CHARGES_AMT_OF_OS":' || '"' || W_CHG_BAL || '",';

            W_TEXT :=
                   W_TEXT
                || '"CUSTOMER_SEGMENT":'
                || '"'
                || CLIENT_DATA.CLIENTS_SEGMENT_CODE
                || '",';
            W_TEXT :=
                   W_TEXT
                || '"LOAN_EXPIRY_DATE":'
                || '"'
                || TO_CHAR (V_LIMIT_EXPIRY_DATE, 'YYYY-MM-DD')
                || '",';
            W_TEXT :=
                   W_TEXT
                || '"LIENT_DEPOSIT_ACC_BALANCE":'
                || '"'
                || W_LIENT_DEPOSIT_ACC_BALANCE
                || '",';


            W_TEXT :=
                   W_TEXT
                || '"ACC_OUTSTANDING_BALANCE":'
                || '"'
                || W_OUTSTAN_BAL
                || '",';

            W_TEXT :=
                   W_TEXT
                || '"INTEREST_CALCULATION_BASIS":'
                || '"'
                || W_CALCULATION_BASIS
                || '",';
            W_TEXT :=
                   W_TEXT
                || '"INTEREST_CALCULATION_FREQUENCY":'
                || '"'
                || W_INT_APPL_FREQ
                || '",';

            W_TEXT :=
                   W_TEXT
                || '"LAST_INT_POSTING_AMT":'
                || '"'
                || W_LAST_INT_POSTING_AMT
                || '",';
            W_TEXT :=
                   W_TEXT
                || '"INT_POSTED_AMT_TILL_DATE":'
                || '"'
                || W_INT_POSTED_AMT_TILL_DATE
                || '",';

            W_TEXT :=
                   W_TEXT
                || '"INT_ACCRUAL_UPTO_DATE":'
                || '"'
                || TO_CHAR (INT_ACCR_UPTO, 'YYYY-MM-DD')
                || '",';
            W_TEXT :=
                   W_TEXT
                || '"INT_ACCRUAL_AMT":'
                || '"'
                || W_ACCRUAL_AMOUNT
                || '",';
            W_TEXT :=
                   W_TEXT
                || '"LAST_INT_POSTING_DATE":'
                || '"'
                || TO_CHAR (INT_APPLIED_UPTO_DATE, 'YYYY-MM-DD')
                || '",';
            W_TEXT :=
                   W_TEXT
                || '"UNAPPLIED_INT_AMT":'
                || '"'
                || UNAPPLIED_INT_AMT
                || '",';

            W_TEXT :=
                W_TEXT || '"ACCOUNT_STATUS":' || '"' || W_AC_STATUS || '",';


            W_TEXT :=
                   W_TEXT
                || '"LAST_USED_CHEQUE_LEAF_DATE":'
                || '"'
                || TO_CHAR (W_CHQUSAGEDATE, 'YYYY-MM-DD')
                || '",';
            W_TEXT :=
                   W_TEXT
                || '"LAST_USED_CHEQUE_LEAF_NO":'
                || '"'
                || W_CHQUSAGELEFNUM
                || '",';

            W_TEXT := W_TEXT || '"CLOSURE_BALANCE":"TODO",';

            IF ACNT.ABB_ALLOWD = 1
            THEN
                W_TEXT :=
                    W_TEXT || '"ONLINE_TRANSACTION_ALLOWED":' || '"yes",';
            ELSE
                W_TEXT :=
                    W_TEXT || '"ONLINE_TRANSACTION_ALLOWED":' || '"no",';
            END IF;


            W_TEXT :=
                   W_TEXT
                || '"ACC_TOTAL_BALANCE":'
                || '"'
                || W_ACC_TOTAL_BALANCE
                || '",';



            W_TEXT :=
                   W_TEXT
                || '"INTEREST_SETTEMENT_ACCOUNT":'
                || '"'
                || W_INT_CR_AC_NUM
                || '",';
            W_TEXT :=
                   W_TEXT
                || '"AUTO_RENEWAL_PERIOD":'
                || '"'
                || W_AUTOROLL_PERIOD
                || '",';
            W_TEXT :=
                W_TEXT || '"AUTO_RENEW":' || '"' || W_RENEWAL_OPTION || '",';

            IF ACNT.PRODUCT_FOR_LOANS = 1
            THEN
                W_TEXT :=
                       W_TEXT
                    || '"TOTAL_NOOF_INSTALLMENT":'
                    || '"'
                    || W_NUM_OF_INSTALLMENT
                    || '",';
            ELSE
                W_NUM_OF_INSTALLMENT := W_NOOF_INST_PAID + W_NOOF_INST_DUE;
                W_TEXT :=
                       W_TEXT
                    || '"TOTAL_NOOF_INSTALLMENT":'
                    || '"'
                    || W_NUM_OF_INSTALLMENT
                    || '",';
            END IF;

            W_TEXT :=
                   W_TEXT
                || '"NOOF_INSTALLMENT_PAID":'
                || '"'
                || W_NOOF_INST_PAID
                || '",';
            W_TEXT :=
                   W_TEXT
                || '"NOOF_INSTALLMENT_DUE_OF_DEPOSIT_AC":'
                || '"'
                || W_NOOF_INST_DUE
                || '",';

            W_TEXT :=
                   W_TEXT
                || '"LAST_DATE_OF_INSTALLMENT_PAYMENT":'
                || '"'
                || TO_CHAR (W_LAST_DATE_OF_INS_PAY, 'YYYY-MM-DD')
                || '",';
            W_TEXT :=
                   W_TEXT
                || '"FINE_PENALTY_AMT":'
                || '"'
                || W_TOT_PENALY_AMT
                || '",';
            W_TEXT :=
                W_TEXT || '"TRANSACTION_DETAILS":' || W_LAST_5_TRANSACTION;
            W_TEXT := W_TEXT || ',';
            W_TEXT :=
                W_TEXT || '"TRANSACTION_PROFILE":' || W_TRANSACTION_PROFILE;
            W_TEXT := W_TEXT || ',';
            --------------------------------------------------

            W_TEXT :=
                   W_TEXT
                || '"BRANCH_CODE":'
                || '"'
                || ACNT.ACNTS_BRN_CODE
                || '",';

            W_TEXT :=
                   W_TEXT
                || '"EMAIL_ADDRESS":'
                || '"'
                || CLIENT_DATA.EMAIL
                || '",';


            W_TEXT :=
                   W_TEXT
                || '"PRINCIPAL_DEPOSIT_AMOUNT":'
                || '"'
                || W_DEP_AMT
                || '",';


            W_TEXT :=
                   W_TEXT
                || '"DEPOSIT_MATURITY_VALUE":'
                || '"'
                || W_MAT_VALUE
                || '",';


            W_TEXT :=
                   W_TEXT
                || '"DEPOSIT_MATURITY_DATE":'
                || '"'
                || W_PBD_MAT_DATE
                || '",';


            W_TEXT :=
                W_TEXT || '"DEPOSIT_PERIOD":' || '"' || W_PRD_MONTHS || '",';


            W_TEXT :=
                   W_TEXT
                || '"INTEREST_SUSPENSE_BALANCE":'
                || '"'
                || W_SUSP_BAL
                || '",';

            ---------------------------


            W_TEXT := W_TEXT || FN_GET_NOMINEE (ACNT.ACNTS_INTERNAL_ACNUM);
            W_TEXT := W_TEXT || ',';
            W_TEXT :=
                   W_TEXT
                || '"ATM_OPERATION_ALLOW":'
                || '"'
                || ACNT.ACNTS_ATM_OPERN
                || '",';

            W_TEXT :=
                   W_TEXT
                || '"ACCOUNT_AVAILABLE_BALANCE":'
                || '"'
                || FN_GET_AVLBAL (W_ENTITY_NUM, ACNT.ACNTS_INTERNAL_ACNUM)
                || '",';
        END LOOP;

        W_TEXT := W_TEXT || '"StatusCode":"00"';

        W_TEXT := W_TEXT || '}';
    END LOOP;

    W_TEXT := W_TEXT || ']';

    RETURN W_TEXT;
END;
/
