/* Formatted on 11/16/2021 4:26:03 PM (QP5 v5.252.13127.32867) */
SELECT GLPC_GLACC_CODE,EXTGL_EXT_HEAD_DESCN,
       GLPC_LATEST_EFF_DATE,
       CASE WHEN GLPC_CASH_DB_ALLOWED = '1' THEN 'yes' ELSE 'no' END
          CASH_DB_ALLOWED,
       CASE WHEN GLPC_TRF_DB_ALLOWED = '1' THEN 'yes' ELSE 'no' END
          TRF_DB_ALLOWED
  FROM GLPC,extgl
 WHERE     (GLPC_GLACC_CODE LIKE '300%')
       AND (GLPC_CASH_DB_ALLOWED = '1' OR GLPC_TRF_DB_ALLOWED = 1)
       AND GLPC_GLACC_CODE = EXTGL_ACCESS_CODE
UNION ALL
SELECT GLPC_GLACC_CODE,EXTGL_EXT_HEAD_DESCN,
       GLPC_LATEST_EFF_DATE,
       CASE WHEN GLPC_CASH_CR_ALLOWED = '1' THEN 'yes' ELSE 'no' END
          CASH_CR_ALLOWED,
       CASE WHEN GLPC_TRF_CR_ALLOWED = '1' THEN 'yes' ELSE 'no' END
          TRF_CR_ALLOWED
  FROM GLPC,extgl
 WHERE     (GLPC_GLACC_CODE LIKE '400%')
       AND (GLPC_CASH_CR_ALLOWED = '1' OR GLPC_TRF_CR_ALLOWED = 1)
          AND GLPC_GLACC_CODE = EXTGL_ACCESS_CODE