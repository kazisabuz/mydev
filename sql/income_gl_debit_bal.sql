/* Formatted on 11/18/2021 2:16:24 PM (QP5 v5.252.13127.32867) */
SELECT *
  FROM (SELECT GLBALH_BRN_CODE,
               LNPRDAC_PROD_CODE,
               PRODUCT_NAME,
               LNPRDAC_INT_ACCR_GL,
               LNPRDAC_INT_INCOME_GL,
               EXTGL_EXT_HEAD_DESCN,
               GLBALH_BC_BAL income_balance
          FROM PRODUCTS,
               EXTGL,
               glbalasonhist,
               lnprodacpm
         WHERE     LNPRDAC_INT_INCOME_GL = GLBALH_GLACC_CODE
               AND GLBALH_ENTITY_NUM = 1
               AND GLBALH_ASON_DATE = '30-DEC-2021'
               AND GLBALH_BC_BAL < 0
               AND EXTGL_ACCESS_CODE = GLBALH_GLACC_CODE
               AND EXTGL_ACCESS_CODE = LNPRDAC_INT_INCOME_GL
               AND PRODUCT_CODE = LNPRDAC_PROD_CODE) a,
       (SELECT GLBALH_BRN_CODE,
               LNPRDAC_PROD_CODE,
               LNPRDAC_INT_INCOME_GL,
               LNPRDAC_INT_ACCR_GL,
               EXTGL_EXT_HEAD_DESCN,
               GLBALH_BC_BAL receiveble_balance
          FROM PRODUCTS,
               EXTGL,
               glbalasonhist,
               lnprodacpm
         WHERE     LNPRDAC_INT_ACCR_GL = GLBALH_GLACC_CODE
               AND GLBALH_ENTITY_NUM = 1
               AND EXTGL_ACCESS_CODE = LNPRDAC_INT_ACCR_GL
               AND GLBALH_ASON_DATE = '30-DEC-2021'
               AND EXTGL_ACCESS_CODE = GLBALH_GLACC_CODE
               AND PRODUCT_CODE = LNPRDAC_PROD_CODE) b
 WHERE     a.LNPRDAC_INT_ACCR_GL = b.LNPRDAC_INT_ACCR_GL
       AND a.LNPRDAC_PROD_CODE = b.LNPRDAC_PROD_CODE
       AND a.LNPRDAC_INT_INCOME_GL = b.LNPRDAC_INT_INCOME_GL
       AND a.GLBALH_BRN_CODE = b.GLBALH_BRN_CODE