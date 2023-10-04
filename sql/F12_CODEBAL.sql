/* Formatted on 7/16/2020 5:42:29 PM (QP5 v5.227.12220.39754) */
SELECT RPTHDGLDTL_CODE,
       GLSUM_GLACC_CODE,
       (SELECT SUM (GLBALH_BC_BAL)
          FROM GLBALASONHIST
         WHERE     GLBALH_ENTITY_NUM = 1
               AND GLBALH_GLACC_CODE = GLSUM_GLACC_CODE
               AND GLBALH_ASON_DATE = '30-june-2020')
          outstandinggl,
       SUM (total_debit_sum) total_debit_sum,
       SUM (total_credit_sum) total_credit_sum,
       SUM (outstanding_bal) outstanding_bal
  FROM (  SELECT RPTHDGLDTL_CODE,
                 GLSUM_GLACC_CODE,
                 SUM (GLSUM_BC_DB_SUM) total_debit_sum,
                 SUM (GLSUM_BC_CR_SUM) total_credit_sum,
                 SUM (GLSUM_BC_DB_SUM - GLSUM_BC_CR_SUM) outstanding_bal
            FROM (  SELECT MBRN_CODE BR_CODE,
                           MBRN_NAME,
                           GLSUM_GLACC_CODE,
                           EXTGL_EXT_HEAD_DESCN,
                           RPTHDGLDTL_CODE,
                           NVL (GLSUM_BC_DB_SUM, 0) GLSUM_BC_DB_SUM,
                           NVL (GLSUM_BC_CR_SUM, 0) GLSUM_BC_CR_SUM
                      FROM glsum2019,
                           RPTHEADGLDTL H,
                           EXTGL,
                           MBRN
                     WHERE     RPTHDGLDTL_GLACC_CODE = GLSUM_GLACC_CODE
                           AND GLSUM_ENTITY_NUM = 1
                           -- AND GLBALH_GLACC_CODE = '400113167'
                           AND GLSUM_BRANCH_CODE = MBRN_CODE
                           AND GLSUM_TRAN_DATE BETWEEN '01-JUL-2019'
                                                   AND '31-dec-2019'
                           AND GLSUM_GLACC_CODE = EXTGL_ACCESS_CODE
                           -- AND GLBALH_BC_BAL <> 0
                           --AND GLBALH_ASON_DATE = '31-AUG-2018'
                           AND H.RPTHDGLDTL_CODE IN
                                  (SELECT RPTLAYOUTDTL_RPT_HEAD_CODE
                                     FROM RPTLAYOUTDTL
                                    WHERE RPTLAYOUTDTL_RPT_CODE = 'F12')
                           AND RPTHDGLDTL_CODE IN
                                  ('A0306', 'A0319', 'A0351', 'A0352', 'A0353')
                  ORDER BY 1)
        GROUP BY RPTHDGLDTL_CODE, GLSUM_GLACC_CODE
        UNION ALL
          SELECT RPTHDGLDTL_CODE,
                 GLSUM_GLACC_CODE,
                 SUM (GLSUM_BC_DB_SUM) total_debit_sum,
                 SUM (GLSUM_BC_CR_SUM) total_credit_sum,
                 SUM (GLSUM_BC_DB_SUM - GLSUM_BC_CR_SUM) outstanding_bal
            FROM (SELECT MBRN_CODE BR_CODE,
                         MBRN_NAME,
                         GLSUM_GLACC_CODE,
                         EXTGL_EXT_HEAD_DESCN,
                         RPTHDGLDTL_CODE,
                         NVL (GLSUM_BC_DB_SUM, 0) GLSUM_BC_DB_SUM,
                         NVL (GLSUM_BC_CR_SUM, 0) GLSUM_BC_CR_SUM
                    FROM glsum2020,
                         RPTHEADGLDTL H,
                         EXTGL,
                         MBRN
                   WHERE     RPTHDGLDTL_GLACC_CODE = GLSUM_GLACC_CODE
                         AND GLSUM_ENTITY_NUM = 1
                         -- AND GLBALH_GLACC_CODE = '400113167'
                         AND GLSUM_BRANCH_CODE = MBRN_CODE
                         AND GLSUM_TRAN_DATE BETWEEN '01-jan-2020'
                                                 AND '30-JUN-2020'
                         AND GLSUM_GLACC_CODE = EXTGL_ACCESS_CODE
                         -- AND GLBALH_BC_BAL <> 0
                         --AND GLBALH_ASON_DATE = '31-AUG-2018'
                         AND H.RPTHDGLDTL_CODE IN
                                (SELECT RPTLAYOUTDTL_RPT_HEAD_CODE
                                   FROM RPTLAYOUTDTL
                                  WHERE RPTLAYOUTDTL_RPT_CODE = 'F12')
                         AND RPTHDGLDTL_CODE IN
                                ('A0306', 'A0319', 'A0351', 'A0352', 'A0353'))
        GROUP BY RPTHDGLDTL_CODE, GLSUM_GLACC_CODE)
        group by RPTHDGLDTL_CODE,
       GLSUM_GLACC_CODE