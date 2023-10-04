/* Formatted on 12/26/2022 2:47:29 PM (QP5 v5.388) */
BEGIN
    UPDATE clients
       SET CLIENTS_IT_STAT_CODE = '1', CLIENTS_IT_SUB_STAT_CODE = '1'
     WHERE     (   TRIM (CLIENTS_IT_STAT_CODE) IS NULL
                OR TRIM (CLIENTS_IT_STAT_CODE) = 99)
           AND CLIENTS_TYPE_FLG = 'I';

    COMMIT;

    UPDATE clients
       SET CLIENTS_IT_STAT_CODE = '6', CLIENTS_IT_SUB_STAT_CODE = '1'
     WHERE     (   TRIM (CLIENTS_IT_STAT_CODE) IS NULL
                OR TRIM (CLIENTS_IT_STAT_CODE) = 99)
           AND CLIENTS_TYPE_FLG = 'C';

    COMMIT;



    UPDATE clients
       SET CLIENTS_IT_STAT_CODE = '1', CLIENTS_IT_SUB_STAT_CODE = '1'
     WHERE     (TRIM (CLIENTS_IT_STAT_CODE) IN ('2',
                                                '3',
                                                '5',
                                                '6',
                                                '7',
                                                '8',
                                                '9',
                                                '99'))
           AND CLIENTS_TYPE_FLG = 'I';

    COMMIT;


    UPDATE clients
       SET CLIENTS_IT_STAT_CODE = '6', CLIENTS_IT_SUB_STAT_CODE = '1'
     WHERE     TRIM (CLIENTS_IT_STAT_CODE) IN ('1', '4', '99')
           AND CLIENTS_TYPE_FLG = 'C';

    COMMIT;

    UPDATE clients
       SET CLIENTS_EXEMP_TDS_PER = 0, CLIENTS_EXEMP_IN_TDS = 0
     WHERE     TRIM (CLIENTS_EXEMP_IN_TDS) = '1'
           AND (NVL (CLIENTS_EXEMP_TDS_PER, 0)) <> 0
           AND CLIENTS_TYPE_FLG = 'I'
           AND CLIENTS_CODE IN (SELECT ACNTS_CLIENT_NUM
                                  FROM clients, ACNTS
                                 WHERE     CLIENTS_CODE = ACNTS_CLIENT_NUM
                                       AND ACNTS_AC_TYPE IN ('SBST',
                                                             'MCL',
                                                             'COMPU',
                                                             'SHBL',
                                                             'CARLN',
                                                             'LAPF')
                                       AND ACNTS_CLOSURE_DATE IS NULL
                                       AND ACNTS_ENTITY_NUM = 1);
END;



SELECT ACNTS_BRN_CODE,
       CLTDS_CLIENT_CODE,
       CLIENTS_NAME,
       CLIENTS_TYPE_FLG,
       ACNTS_PROD_CODE,
       facno(1,ACNTS_INTERNAL_ACNUM) account_no,
       ACNTS_AC_TYPE,
       CLTDS_EFF_DATE,
       CLTDS_IT_STAT_CODE,
       CLTDS_IT_SUB_STAT_CODE,
       CLIENTS_IT_STAT_CODE,
       CLIENTS_IT_SUB_STAT_CODE
  FROM CLIENTTDS, CLIENTS, acnts
 WHERE     CLIENTS_CODE = CLTDS_CLIENT_CODE
       AND CLTDS_EFF_DATE = (SELECT MAX (CLTDS_EFF_DATE)
                               FROM CLIENTTDS
                              WHERE CLTDS_CLIENT_CODE = CLIENTS_CODE)
       AND CLTDS_IT_STAT_CODE <> CLIENTS_IT_STAT_CODE
       AND CLTDS_IT_SUB_STAT_CODE <> CLIENTS_IT_SUB_STAT_CODE
       AND ACNTS_CLIENT_NUM = CLTDS_CLIENT_CODE
       AND ACNTS_CLIENT_NUM = CLIENTS_CODE
       AND ACNTS_ENTITY_NUM = 1
       and ACNTS_CLOSURE_DATE is null