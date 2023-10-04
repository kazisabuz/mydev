/* Formatted on 2/8/2019 1:29:22 AM (QP5 v5.227.12220.39754) */
SELECT MBRN_CODE,
       MBRN_NAME,
       (SELECT COUNT (DISTINCT (ACNTS_CLIENT_NUM))
          FROM ACNTS
         WHERE     ACNTS_ENTITY_NUM = 1
                AND ACNTS_PROD_CODE <> 2518
               -- and ACNTS_BRN_CODE=1016
               AND ACNTS_BRN_CODE = M.MBRN_CODE
               AND ACNTS_GLACC_CODE IN
                      ('210116114',
'210137110',
'210137117',
'210137122',
'210137124',
'210137126',
'212101101',
'210137113',
'210137115',
'210137120'))
          AGR_CLIENTS,
       (SELECT COUNT   (ACNTS_INTERNAL_ACNUM)
          FROM ACNTS
         WHERE     ACNTS_ENTITY_NUM = 1
                 AND ACNTS_PROD_CODE <> 2518
               --and ACNTS_BRN_CODE=1065
               AND ACNTS_BRN_CODE = M.MBRN_CODE
               AND ACNTS_GLACC_CODE IN
                      ('210116114',
'210137110',
'210137117',
'210137122',
'210137124',
'210137126',
'212101101',
'210137113',
'210137115',
'210137120'))
          AGR_TOTAL_ACCOUNT,
       (SELECT COUNT (*)
          FROM CLIENTS
         WHERE     CLIENTS_CODE NOT IN
                      (SELECT ACNTS_CLIENT_NUM
                         FROM ACNTS
                        WHERE     ACNTS_ENTITY_NUM = 1
                                 AND ACNTS_PROD_CODE <> 2518
                              AND ACNTS_BRN_CODE = M.MBRN_CODE
                              --and ACNTS_BRN_CODE=1065
                              AND ACNTS_GLACC_CODE IN
                                     ('210116114',
'210137110',
'210137117',
'210137122',
'210137124',
'210137126',
'212101101',
'210137113',
'210137115',
'210137120'))
               AND CLIENTS_HOME_BRN_CODE = M.MBRN_CODE)
          OTHERS_CLIENTS,
       (SELECT COUNT ( ACNTS_INTERNAL_ACNUM)
          FROM ACNTS 
         WHERE     ACNTS_ENTITY_NUM = 1
                 AND ACNTS_PROD_CODE <> 2518
               --and ACNTS_BRN_CODE=1065
               AND ACNTS_BRN_CODE = M.MBRN_CODE
               AND ACNTS_GLACC_CODE NOT IN
                      ('210116114',
'210137110',
'210137117',
'210137122',
'210137124',
'210137126',
'212101101',
'210137113',
'210137115',
'210137120'))
          OTHERS_ACCOUNT
  FROM MBRN M
 WHERE MBRN_ENTITY_NUM = 1;






---------------------------------------------------------------------------------
SELECT (SELECT MBRN_CODE, MBRN_NAME, COUNT (DISTINCT (ACNTS_CLIENT_NUM))
            FROM acnts, mbrn
           WHERE     ACNTS_ENTITY_NUM = 1
                 AND ACNTS_PROD_CODE <> 2518
                 --and ACNTS_BRN_CODE=1065
                 AND ACNTS_BRN_CODE = MBRN_CODE
                 AND ACNTS_GLACC_CODE IN
                        ('210116114',
                         '210137110',
                         '210137113',
                         '210137115',
                         '210137117',
                         '210137120',
                         '210137122',
                         '210137124',
                         '210137126',
                         '212101101')
        GROUP BY MBRN_CODE, MBRN_NAME)
          total_clients,
       (  SELECT MBRN_CODE, MBRN_NAME, COUNT (DISTINCT (ACNTS_INTERNAL_ACNUM))
            FROM acnts,mbrn
           WHERE     ACNTS_ENTITY_NUM = 1
                 AND ACNTS_PROD_CODE <> 2518
                 --and ACNTS_BRN_CODE=1065
                 AND ACNTS_BRN_CODE = MBRN_CODE
                 AND ACNTS_GLACC_CODE IN
                        ('210116114',
                         '210137110',
                         '210137113',
                         '210137115',
                         '210137117',
                         '210137120',
                         '210137122',
                         '210137124',
                         '210137126',
                         '212101101')
        GROUP BY MBRN_CODE, MBRN_NAME)
          total_account,
        (  SELECT MBRN_CODE, MBRN_NAME, COUNT (*)
     FROM clients, mbrn
    WHERE     CLIENTS_CODE NOT IN
                 (SELECT ACNTS_CLIENT_NUM
                    FROM acnts, mbrn
                   WHERE     ACNTS_ENTITY_NUM = 1
                         AND ACNTS_PROD_CODE <> 2518
                         AND ACNTS_BRN_CODE = MBRN_CODE
                         --and ACNTS_BRN_CODE=1065
                         AND ACNTS_GLACC_CODE IN
                                ('210116114',
                                 '210137110',
                                 '210137113',
                                 '210137115',
                                 '210137117',
                                 '210137120',
                                 '210137122',
                                 '210137124',
                                 '210137126',
                                 '212101101'))
          AND MBRN_CODE = CLIENTS_HOME_BRN_CODE
 GROUP BY MBRN_CODE, MBRN_NAME)
          others_clients,
       (  SELECT MBRN_CODE, MBRN_NAME, COUNT (DISTINCT (ACNTS_INTERNAL_ACNUM))
            FROM acnts,mbrn
           WHERE     ACNTS_ENTITY_NUM = 1
                 AND ACNTS_PROD_CODE <> 2518
                 --and ACNTS_BRN_CODE=1065
                 and ACNTS_BRN_CODE=MBRN_CODE
                 AND ACNTS_GLACC_CODE NOT IN
                        ('210116114',
                         '210137110',
                         '210137113',
                         '210137115',
                         '210137117',
                         '210137120',
                         '210137122',
                         '210137124',
                         '210137126',
                         '212101101')
        GROUP BY MBRN_CODE, MBRN_NAME)
 
          others_account
  FROM DUAL;