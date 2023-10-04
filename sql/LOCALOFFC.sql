/* Formatted on 6/19/2022 5:13:30 PM (QP5 v5.252.13127.32867) */
BEGIN
   FOR IDX
      IN (SELECT *
            FROM (SELECT (SELECT DISTINCT INDCLIENT_CODE
                            FROM IACLINK, indclients
                           WHERE     IACLINK_ENTITY_NUM = 1
                                 AND IACLINK_CIF_NUMBER = INDCLIENT_CODE
                                 AND IACLINK_ACTUAL_ACNUM = aa.NON_COM_ACC)
                            INDCLIENT_CODE,
                         (SELECT INDCLIENT_PID_INV_NUM
                            FROM IACLINK, indclients
                           WHERE     IACLINK_ENTITY_NUM = 1
                                 AND IACLINK_CIF_NUMBER = INDCLIENT_CODE
                                 AND IACLINK_ACTUAL_ACNUM = aa.NON_COM_ACC)
                            PID_INV_NUM,
                         INDCLIENT_FATHER_NAME,
                         INDCLIENT_BIRTH_DATE,
                         INDCLIENT_MOTHER_NAME,
                         CASE
                            WHEN TRIM (PIDDOCS_PID_TYPE) IN ('99', 'TIN')
                            THEN
                               'NID'
                            ELSE
                               TRIM (PIDDOCS_PID_TYPE)
                         END
                            PIDDOCS_PID_TYPE,
                         PIDDOCS_DOCID_NUM,
                         (SELECT ADDRDTLS_INV_NUM
                            FROM IACLINK, clients, ADDRDTLS
                           WHERE     IACLINK_ENTITY_NUM = 1
                                 AND IACLINK_CIF_NUMBER = CLIENTS_CODE
                                 AND CLIENTS_ADDR_INV_NUM = ADDRDTLS_INV_NUM
                                 AND ADDRDTLS_ADDR_SL = 1
                                 AND IACLINK_ACTUAL_ACNUM = aa.NON_COM_ACC)
                            ADDRDTL_INV_NUM,
                         CASE
                            WHEN TRIM (ADDRDTLS_CURR_ADDR) = '0' THEN '1'
                            ELSE TRIM (ADDRDTLS_CURR_ADDR)
                         END
                            ADDRDTLS_CURR_ADDR,
                         INDCLIENT_FIRST_NAME,
                         INDCLIENT_LAST_NAME,
                         INDCLIENT_SUR_NAME,
                         INDCLIENT_MIDDLE_NAME,
                         ADDRDTLS_PERM_ADDR,
                         ADDRDTLS_COMM_ADDR,
                         CASE
                            WHEN TRIM (ADDRDTLS_DISTRICT_CODE) IS NULL
                            THEN
                               '101'
                            ELSE
                               TRIM (ADDRDTLS_DISTRICT_CODE)
                         END
                            ADDRDTLS_DISTRICT_CODE,
                         CASE
                            WHEN TRIM (ADDRDTLS_POSTOFFC_NAME) IS NULL
                            THEN
                               'Motijheel'
                            ELSE
                               TRIM (ADDRDTLS_POSTOFFC_NAME)
                         END
                            ADDRDTLS_POSTOFFC_NAME,
                         CASE
                            WHEN TRIM (ADDRDTLS_STATE_CODE) IS NULL THEN '01'
                            ELSE TRIM (ADDRDTLS_STATE_CODE)
                         END
                            ADDRDTLS_STATE_CODE,
                         CASE
                            WHEN TRIM (ADDRDTLS_POSTAL_CODE) IS NULL
                            THEN
                               '1000'
                            ELSE
                               TRIM (ADDRDTLS_POSTAL_CODE)
                         END
                            ADDRDTLS_POSTAL_CODE,
                         ADDRDTLS_MOBILE_NUM,
                         ADDRDTLS_ADDR1,
                         ADDRDTLS_ADDR2,
                         ADDRDTLS_ADDR3,
                         ADDRDTLS_ADDR4,
                         ADDRDTLS_ADDR5
                    FROM ACC5 aa,
                         IACLINK,
                         indclients,
                         piddocs,
                         clients,
                         ADDRDTLS
                   WHERE     ACC_no = IACLINK_ACTUAL_ACNUM
                         AND IACLINK_ENTITY_NUM = 1
                         AND IACLINK_CIF_NUMBER = CLIENTS_CODE
                         AND CLIENTS_ADDR_INV_NUM = ADDRDTLS_INV_NUM
                         AND CLIENTS_CODE = INDCLIENT_CODE
                         AND INDCLIENT_PID_INV_NUM = PIDDOCS_INV_NUM --                 AND ACC_NO IN ('0002634229958',
                            --                                '0002634237861',
                            --                                '0002634237861',
                            --                                '0002634210372',
                            --                                '0002634221881',
                            --                                '0002634221881')
                 )
           WHERE PID_INV_NUM IS NOT NULL AND ADDRDTL_INV_NUM IS NOT NULL)
   LOOP
      --and PIDDOCS_PID_TYPE='99'


      UPDATE indclients
         SET INDCLIENT_FATHER_NAME = IDX.INDCLIENT_FATHER_NAME,
             INDCLIENT_BIRTH_DATE = IDX.INDCLIENT_BIRTH_DATE,
             INDCLIENT_MOTHER_NAME = IDX.INDCLIENT_MOTHER_NAME,
             INDCLIENT_FIRST_NAME = idx.INDCLIENT_FIRST_NAME,
             INDCLIENT_LAST_NAME = idx.INDCLIENT_LAST_NAME,
             INDCLIENT_SUR_NAME = idx.INDCLIENT_SUR_NAME,
             INDCLIENT_MIDDLE_NAME = idx.INDCLIENT_MIDDLE_NAME
       WHERE INDCLIENT_CODE = IDX.INDCLIENT_CODE;


      UPDATE piddocs
         SET PIDDOCS_PID_TYPE = IDX.PIDDOCS_PID_TYPE,
             PIDDOCS_DOCID_NUM = IDX.PIDDOCS_DOCID_NUM
       WHERE PIDDOCS_INV_NUM = IDX.PID_INV_NUM;

      UPDATE ADDRDTLS
         SET ADDRDTLS_CURR_ADDR = IDX.ADDRDTLS_CURR_ADDR,
             ADDRDTLS_MOBILE_NUM = idx.ADDRDTLS_MOBILE_NUM,
             ADDRDTLS_PERM_ADDR = idx.ADDRDTLS_PERM_ADDR,
             ADDRDTLS_COMM_ADDR = idx.ADDRDTLS_COMM_ADDR,
             ADDRDTLS_DISTRICT_CODE = IDX.ADDRDTLS_DISTRICT_CODE,
             ADDRDTLS_POSTOFFC_NAME = IDX.ADDRDTLS_POSTOFFC_NAME,
             ADDRDTLS_STATE_CODE = IDX.ADDRDTLS_STATE_CODE,
             ADDRDTLS_POSTAL_CODE = IDX.ADDRDTLS_POSTAL_CODE,
             ADDRDTLS_ADDR1 = idx.ADDRDTLS_ADDR1,
             ADDRDTLS_ADDR2 = idx.ADDRDTLS_ADDR2,
             ADDRDTLS_ADDR3 = idx.ADDRDTLS_ADDR3,
             ADDRDTLS_ADDR4 = idx.ADDRDTLS_ADDR4,
             ADDRDTLS_ADDR5 = idx.ADDRDTLS_ADDR5
       WHERE ADDRDTLS_INV_NUM = IDX.ADDRDTL_INV_NUM;
   END LOOP;
END;