/* Formatted on 10/30/2019 5:06:00 PM (QP5 v5.227.12220.39754) */
SELECT ACNTS_CLIENT_NUM CUSTOMERNO,
       CASE
          WHEN CLIENTS_TYPE_FLG = 'I' THEN 'INDIVIDUAL'
          WHEN CLIENTS_TYPE_FLG = 'C' THEN 'ENTITY'
          ELSE 'OTHERS'
       END
          SCRCUSTOMERTYPE,
       (SELECT ACTP_SRC_FUND
          FROM ACNTRNPR
         WHERE     ACTP_ACNT_NUM = ACNTS_INTERNAL_ACNUM
               AND ACTP_LATEST_EFF_DATE =
                      (SELECT MAX (ACTP_LATEST_EFF_DATE)
                         FROM ACNTRNPR
                        WHERE ACTP_ACNT_NUM = ACNTS_INTERNAL_ACNUM))
          SOURCEOFFUND,
       (SELECT ACTP_SRC_FUND
          FROM ACNTRNPR
         WHERE     ACTP_ACNT_NUM = ACNTS_INTERNAL_ACNUM
               AND ACTP_LATEST_EFF_DATE =
                      (SELECT MAX (ACTP_LATEST_EFF_DATE)
                         FROM ACNTRNPR
                        WHERE ACTP_ACNT_NUM = ACNTS_INTERNAL_ACNUM))
          SOURCEOFINCOME,
       (SELECT USER_NAME
          FROM USERS
         WHERE USER_ID = ACNTS_ENTD_BY)
          ACCOUNTOPENINGOFFICER,
       NULL ACCOUNTOPENINGPURPOSE,
       (SELECT OCCUPATIONS_DESCN
          FROM OCCUPATIONS, INDCLIENTS
         WHERE     INDCLIENT_CODE = CLIENTS_CODE
               AND OCCUPATIONS_CODE = INDCLIENT_OCCUPN_CODE)
          CUSTOMERPROFESSION,
       ROUND (
            (SELECT CASE
                       WHEN NVL (INDCLIENT_BC_ANNUAL_INCOME, 0) <> 0
                       THEN
                          INDCLIENT_BC_ANNUAL_INCOME
                       WHEN (    NVL (INDCLIENT_BC_ANNUAL_INCOME, 0) = 0
                             AND  INDCLIENT_ANNUAL_INCOME_SLAB  IS NULL)
                       THEN
                          100000
                       WHEN INDCLIENT_ANNUAL_INCOME_SLAB = 1
                       THEN
                          100000
                       WHEN INDCLIENT_ANNUAL_INCOME_SLAB = 2
                       THEN
                          250000
                       WHEN INDCLIENT_ANNUAL_INCOME_SLAB = 3
                       THEN
                          500000
                       WHEN INDCLIENT_ANNUAL_INCOME_SLAB = 4
                       THEN
                          500000
                       ELSE
                          100000
                    END
               FROM INDCLIENTS
              WHERE INDCLIENT_CODE = CLIENTS_CODE)
          / 12)
          NETWORTH,
       CASE
          WHEN ACNTS_MKT_CHANNEL_CODE = 1 THEN 'BY RELATIONSHIP MANAGER'
          WHEN ACNTS_MKT_CHANNEL_CODE = 2 THEN 'WALK IN CUSTOMER'
          WHEN ACNTS_MKT_CHANNEL_CODE = 3 THEN 'OTHERS MARKETING CHANNEL'
          ELSE 'OTHERS MARKETING CHANNEL'
       END
          ACCOUNTOPENINGWAY
  FROM acACNTS_CLOSURE_DATEnts, CLIENTS
 WHERE     ACNTS_ENTITY_NUM = 1
       AND ACNTS_CLIENT_NUM = CLIENTS_CODE
       AND ACNTS_CLOSURE_DATE IS NULL
    --   AND ACNTS_BRN_CODE = 18
    ORDER BY CLIENTS_CODE