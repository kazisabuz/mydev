CREATE OR REPLACE FUNCTION FN_GET_KYC_STATUS (P_INTERNAL_AC_NUMBER   NUMBER,
                                              P_BRANCH_CODE          NUMBER)
    RETURN NUMBER
IS
    KYC_STAT   NUMBER (2);
BEGIN
    SELECT CASE WHEN KYC_STATUS = 'NKYC' THEN 0 ELSE 1 END
      INTO KYC_STAT
      FROM (SELECT ACNTS_INTERNAL_ACNUM,
                   ACNTS_BRN_CODE,
                   ACNTS_PROD_CODE,
                   PROD_TYPE,
                   ACNTS_AC_TYPE,
                   ACNTS_AC_NAME,
                   0      GOV_STATUS,
                   CASE
                       WHEN CLIENTS_TYPE_FLG = 'I' OR CLIENTS_TYPE_FLG = 'J'
                       THEN
                           CASE
                               WHEN (  INDCLIENT_BIRTH_DATE
                                     * INDCLIENT_FATHER_NAME
                                     * INDCLIENT_MOTHER_NAME
                                     * ACNTS_PURPOSE_AC_OPEN
                                     * INDCLIENT_OCCUPN_CODE
                                     * ACTP_SRC_FUND
                                     * ACTP_SRC_FUND_DOC
                                     * INDCLIENT_ADDR_VERIF_DTLS
                                     * CASE
                                           WHEN (  CASE
                                                       WHEN (  PER_ADDRDTLS_CURR_ADDR
                                                             * PER_ADDRDTLS_DISTRICT_CODE
                                                             * PER_ADDRDTLS_POSTOFFC_NAME
                                                             * PER_ADDRDTLS_STATE_CODE
                                                             * PER_ADDRDTLS_POSTAL_CODE) =
                                                            1
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
                                                             * CURR_ADDRDTLS_POSTAL_CODE) =
                                                            1
                                                       THEN
                                                           1
                                                       ELSE
                                                           0
                                                   END) >=
                                                1
                                           THEN
                                               1
                                           ELSE
                                               0
                                       END
                                     * CASE
                                           WHEN   NID_PIDDOCS_DOCID_NUM
                                                + PP_PIDDOCS_DOCID_NUM
                                                + SC_PIDDOCS_DOCID_NUM
                                                + BC_PIDDOCS_DOCID_NUM
                                                + DL_PIDDOCS_DOCID_NUM =
                                                0
                                           THEN
                                               0
                                           ELSE
                                               1
                                       END) =
                                    0
                               THEN
                                   'NKYC'
                               ELSE
                                   'KYC'
                           END
                       WHEN CLIENTS_TYPE_FLG = 'C'
                       THEN
                           CASE
                               WHEN (  CLIENTS_CONST_CODE
                                     * ACTP_SRC_FUND
                                     * ACTP_SRC_FUND_DOC
                                     * INDCLIENT_ADDR_VERIF_DTLS
                                     * CASE
                                           WHEN (  CASE
                                                       WHEN (  PER_ADDRDTLS_CURR_ADDR
                                                             * PER_ADDRDTLS_DISTRICT_CODE
                                                             * PER_ADDRDTLS_POSTOFFC_NAME
                                                             * PER_ADDRDTLS_STATE_CODE
                                                             * PER_ADDRDTLS_POSTAL_CODE) =
                                                            1
                                                       THEN
                                                           1
                                                       ELSE
                                                           0
                                                   END
                                                 + CASE
                                                       WHEN (  OFF_ADDRDTLS_CURR_ADDR
                                                             * OFF_ADDRDTLS_DISTRICT_CODE
                                                             * OFF_ADDRDTLS_POSTOFFC_NAME
                                                             * OFF_ADDRDTLS_STATE_CODE
                                                             * OFF_ADDRDTLS_POSTAL_CODE) =
                                                            1
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
                                                             * CURR_ADDRDTLS_POSTAL_CODE) =
                                                            1
                                                       THEN
                                                           1
                                                       ELSE
                                                           0
                                                   END) >=
                                                1
                                           THEN
                                               1
                                           ELSE
                                               0
                                       END
                                     * CASE
                                           WHEN   CORPCL_REG_NUM
                                                + NVL (
                                                      CORPCLAH_TRADE_LICENSE,
                                                      0)
                                                + CLIENTS_PAN_GIR_NUM
                                                + CLIENTS_VIN_NUM =
                                                0
                                           THEN
                                               0
                                           ELSE
                                               1
                                       END) =
                                    0
                               THEN
                                   'NKYC'
                               ELSE
                                   'KYC'
                           END
                   END    KYC_STATUS,
                   INDCLIENT_FATHER_NAME,
                   INDCLIENT_MOTHER_NAME,
                   ACNTS_PURPOSE_AC_OPEN,
                   INDCLIENT_OCCUPN_CODE,
                   ACTP_SRC_FUND,
                   ACTP_SRC_FUND_DOC,
                   CURR_ADDRDTLS_STATE_CODE,
                   CURR_ADDRDTLS_DISTRICT_CODE,
                   CURR_ADDRDTLS_POSTAL_CODE,
                   CURR_ADDRDTLS_LOCN_CODE,
                   NID_PIDDOCS_PID_TYPE,
                   SC_PIDDOCS_PID_TYPE,
                   INDCLIENT_TERROR_INV,
                   CLIENTS_RISK_CATEGORIZATION
              FROM KYC_DATA_FRAME K, KYC_PROD
             WHERE     ACNTS_PROD_CODE = PROD_CODE
                   AND IACLINK_INTERNAL_ACNUM = P_INTERNAL_AC_NUMBER
                   AND ACNTS_BRN_CODE = P_BRANCH_CODE);

    RETURN KYC_STAT;
EXCEPTION
    WHEN NO_DATA_FOUND
    THEN
        RETURN 0;
END;
/
