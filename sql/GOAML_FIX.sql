
--connecting roll
SELECT AC.ACNTS_INTERNAL_ACNUM,
       AC.ACNTS_CLIENT_NUM,
       AC.ACNTS_AC_NAME1,
       CASE WHEN CR.CONNROLE_CODE = '7' THEN CONNP_CLIENT_NUM ELSE NULL END
          direct_cl,
       CASE WHEN CR.CONNROLE_CODE = '8' THEN CONNP_CLIENT_NUM ELSE NULL END
          auth_cl,
       CASE WHEN CR.CONNROLE_CODE = '16' THEN CONNP_CLIENT_NUM ELSE NULL END
          md_cl,
       CASE WHEN CR.CONNROLE_CODE = '4' THEN CONNP_CLIENT_NUM ELSE NULL END
          p_cl,
       CONNROLE_CODE,
       CR.CONNROLE_DESCN,
       C.CONNP_CLIENT_NUM,
       C.CONNP_INTERNAL_ACNUM
  FROM ACNTS AC
       LEFT JOIN CONNPINFO C ON AC.ACNTS_CONNP_INV_NUM = C.CONNP_INV_NUM
       LEFT JOIN CONNROLE CR ON CR.CONNROLE_CODE = C.CONNP_CONN_ROLE
 WHERE AC.ACNTS_INTERNAL_ACNUM = 11628700017241;
 
 ---trade
 /* Formatted on 8/16/2022 1:47:55 PM (QP5 v5.252.13127.32867) */
SELECT CLIENTS_NAME,
       SEGMENTS_DESCN,
       CORPCL_REG_NUM,
       CASE
          WHEN CORPCL_REG_DATE IS NOT NULL
          THEN
             TO_CHAR (CORPCL_REG_DATE, 'YYYY-MM-DD') || 'T00:00:00'
          ELSE
             ''
       END
          CORPCL_REG_DATE,
       CORPCL_INCORP_CNTRY,
       CLIENTS_CONST_CODE,
       TAX_NO
  FROM (SELECT CLIENTS_CODE,
               C.CLIENTS_NAME,
               SEGMENTS_DESCN,
               CASE
                  WHEN CLIENTS_CONST_CODE IN (8, 13)
                  THEN
                     (SELECT CORPCLAH_TRADE_LICENSE
                        FROM CORPCLIENTSAHIST
                       WHERE     CORPCLAH_CLIENT_CODE = C.CLIENTS_CODE
                             AND CORPCLAH_EFF_DATE =
                                    (SELECT MAX (CORPCLAH_EFF_DATE)
                                       FROM CORPCLIENTSAHIST
                                      WHERE CORPCLAH_CLIENT_CODE =
                                               C.CLIENTS_CODE))
                  ELSE
                     CO.CORPCL_REG_NUM
               END
                  CORPCL_REG_NUM,
               CASE
                  WHEN CLIENTS_CONST_CODE IN (8, 13)
                  THEN
                     (SELECT CORPCLAH_TRADE_LIC_ISS_DATE
                        FROM CORPCLIENTSAHIST
                       WHERE     CORPCLAH_CLIENT_CODE = C.CLIENTS_CODE
                             AND CORPCLAH_EFF_DATE =
                                    (SELECT MAX (CORPCLAH_EFF_DATE)
                                       FROM CORPCLIENTSAHIST
                                      WHERE CORPCLAH_CLIENT_CODE =
                                               C.CLIENTS_CODE))
                  ELSE
                     CO.CORPCL_REG_DATE
               END
                  CORPCL_REG_DATE,
               NVL (TRIM (CO.CORPCL_INCORP_CNTRY), 'BD') CORPCL_INCORP_CNTRY,
               C.CLIENTS_CONST_CODE,
               COALESCE (C.CLIENTS_PAN_GIR_NUM, C.CLIENTS_VIN_NUM, '') TAX_NO
          FROM CLIENTS C
               INNER JOIN CORPCLIENTS CO
                  ON CO.CORPCL_CLIENT_CODE = C.CLIENTS_CODE
               LEFT JOIN SEGMENTS S
                  ON S.SEGMENTS_CODE = C.CLIENTS_SEGMENT_CODE
       WHERE C.CLIENTS_CODE = :P_CLIENTS_CODE)