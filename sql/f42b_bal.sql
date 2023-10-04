/* Formatted on 27/12/2018 2:34:32 PM (QP5 v5.227.12220.39754) */
  SELECT MBRN_CODE,
         MBRN_NAME,
         GLBBAL_GLACC_CODE,
         EXTGL_EXT_HEAD_DESCN,
         RPTHDGLDTL_CODE,
         NVL (GLBBAL_BC_BAL, 0) OUTSTANDING_BALANCE
    FROM GLBBAL,
         RPTHEADGLDTL H,
         EXTGL,
         MBRN
   WHERE     RPTHDGLDTL_GLACC_CODE = GLBBAL_GLACC_CODE
         AND GLBBAL_ENTITY_NUM = 1
         --AND GLBALH_GLACC_CODE = '400101101'
         AND GLBBAL_BRANCH_CODE = MBRN_CODE
         AND GLBBAL_YEAR = '2019'
         AND GLBBAL_GLACC_CODE = EXTGL_ACCESS_CODE
         AND GLBBAL_BC_BAL <> 0
         --AND GLBALH_ASON_DATE = '31-AUG-2018'
         AND H.RPTHDGLDTL_CODE IN (SELECT RPTLAYOUTDTL_RPT_HEAD_CODE
                                     FROM RPTLAYOUTDTL
                                    WHERE RPTLAYOUTDTL_RPT_CODE = 'F12')
         AND RPTHDGLDTL_CODE IN ('A0702')
ORDER BY 1;

------------------CODE WISE DIFFERNT DATE BALANCE----------------------------------
/* Formatted on 6/16/2021 4:33:00 PM (QP5 v5.252.13127.32867) */
SELECT A.RPT_BRN_CODE,
       A.RPT_BRN_NAME,
       A.RPT_HEAD_CODE,
       B.APRIL_BAL,
       A.RPT_HEAD_BAL MAY_BAL
  FROM STATMENTOFAFFAIRS A,
       (SELECT RPT_BRN_CODE,
               RPT_BRN_NAME,
               RPT_HEAD_CODE,
               RPT_HEAD_BAL APRIL_BAL
          FROM STATMENTOFAFFAIRS
         WHERE     RPT_HEAD_CODE IN ('L2001', 'L2101', 'L2002')
               AND RPT_ENTRY_DATE = '30-apr-2021') B
 WHERE     A.RPT_HEAD_CODE IN ('L2001', 'L2101', 'L2002')
       AND A.RPT_ENTRY_DATE = '31-may-2021'
       AND A.RPT_HEAD_CODE = B.RPT_HEAD_CODE
       AND A.RPT_BRN_CODE = B.RPT_BRN_CODE;


------------------------------
/* Formatted on 27/12/2018 2:34:32 PM (QP5 v5.227.12220.39754) */
  SELECT  BRANCH_GMO GMO_CODE, (SELECT MBRN_NAME FROM MBRN WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = BRANCH_GMO   ) GMO_NAME,
   
 BRANCH_PO PO_CODE, (SELECT MBRN_NAME FROM MBRN WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = BRANCH_PO   ) PO_NAME,
   
   TT.* FROM (SELECT   MBRN_CODE BR_CODE,
         MBRN_NAME,
         GLBALH_GLACC_CODE,
         EXTGL_EXT_HEAD_DESCN,
         RPTHDGLDTL_CODE,
         NVL (GLBALH_BC_BAL, 0) OUTSTANDING_BALANCE
    FROM GLBALASONHIST,
         RPTHEADGLDTL H,
         EXTGL,
         MBRN
   WHERE     RPTHDGLDTL_GLACC_CODE = GLBALH_GLACC_CODE
         AND GLBALH_ENTITY_NUM = 1
         -- AND GLBALH_GLACC_CODE = '400113167'
         AND GLBALH_BRN_CODE = MBRN_CODE
         AND GLBALH_ASON_DATE ='31-DEC-2021'
         AND GLBALH_GLACC_CODE = EXTGL_ACCESS_CODE
         AND GLBALH_BC_BAL <> 0
         --AND GLBALH_ASON_DATE = '31-AUG-2018'
         AND H.RPTHDGLDTL_CODE IN (SELECT RPTLAYOUTDTL_RPT_HEAD_CODE
                                     FROM RPTLAYOUTDTL
                                    WHERE RPTLAYOUTDTL_RPT_CODE = 'F12')
         AND RPTHDGLDTL_CODE IN ('A0910')
ORDER BY 1)TT,MBRN_TREE2
WHERE TT.BR_CODE=BRANCH_CODE;


---------------------diffrent date -----------------------------
/* Formatted on 09/14/2020 4:04:18 PM (QP5 v5.227.12220.39754) */
  SELECT BR_CODE,
         MBRN_NAME,
         GLBALH_GLACC_CODE,
         EXTGL_EXT_HEAD_DESCN,
         RPTHDGLDTL_CODE,
         SUM (JUL_OUTSTANDING_BALANCE) JUL_OUTSTANDING_BALANCE,
         SUM (AUG_BAL) AUG_BAL
    FROM (SELECT BR_CODE,
                 MBRN_NAME,
                 GLBALH_GLACC_CODE,
                 EXTGL_EXT_HEAD_DESCN,
                 RPTHDGLDTL_CODE,
                 JUL_OUTSTANDING_BALANCE,
                 AUG_BAL
            FROM (  SELECT MBRN_CODE BR_CODE,                         ---48984
                           MBRN_NAME,
                           GLBALH_GLACC_CODE,
                           EXTGL_EXT_HEAD_DESCN,
                           RPTHDGLDTL_CODE,
                           SUM (NVL (GLBALH_BC_BAL, 0)) JUL_OUTSTANDING_BALANCE,
                           0 AUG_BAL
                      FROM GLBALASONHIST,
                           RPTHEADGLDTL H,
                           EXTGL,
                           MBRN
                     WHERE     RPTHDGLDTL_GLACC_CODE = GLBALH_GLACC_CODE
                           AND GLBALH_ENTITY_NUM = 1
                           -- AND GLBALH_GLACC_CODE = '400113167'
                           AND GLBALH_BRN_CODE = MBRN_CODE
                           AND GLBALH_ASON_DATE = '31-jul-2020'
                           AND GLBALH_GLACC_CODE = EXTGL_ACCESS_CODE
                           AND GLBALH_BC_BAL <> 0
                           --AND GLBALH_ASON_DATE = '31-AUG-2018'
                           AND H.RPTHDGLDTL_CODE IN
                                  (SELECT RPTLAYOUTDTL_RPT_HEAD_CODE
                                     FROM RPTLAYOUTDTL
                                    WHERE RPTLAYOUTDTL_RPT_CODE = 'F12')
                           AND RPTHDGLDTL_CODE IN ('L2001', 'L2101')
                  GROUP BY MBRN_CODE,
                           MBRN_NAME,
                           GLBALH_GLACC_CODE,
                           RPTHDGLDTL_CODE,
                           EXTGL_EXT_HEAD_DESCN
                  UNION ALL
                    SELECT MBRN_CODE BR_CODE,                         ---48984
                           MBRN_NAME,
                           GLBALH_GLACC_CODE,
                           EXTGL_EXT_HEAD_DESCN,
                           RPTHDGLDTL_CODE,
                           0 JUL_OUTSTANDING_BALANCE,
                           SUM (NVL (GLBALH_BC_BAL, 0)) AUG_BAL
                      FROM GLBALASONHIST,
                           RPTHEADGLDTL H,
                           EXTGL,
                           MBRN
                     WHERE     RPTHDGLDTL_GLACC_CODE = GLBALH_GLACC_CODE
                           AND GLBALH_ENTITY_NUM = 1
                           -- AND GLBALH_GLACC_CODE = '400113167'
                           AND GLBALH_BRN_CODE = MBRN_CODE
                           AND GLBALH_ASON_DATE = '31-aug-2020'
                           AND GLBALH_GLACC_CODE = EXTGL_ACCESS_CODE
                           AND GLBALH_BC_BAL <> 0
                           --AND GLBALH_ASON_DATE = '31-AUG-2018'
                           AND H.RPTHDGLDTL_CODE IN
                                  (SELECT RPTLAYOUTDTL_RPT_HEAD_CODE
                                     FROM RPTLAYOUTDTL
                                    WHERE RPTLAYOUTDTL_RPT_CODE = 'F12')
                           AND RPTHDGLDTL_CODE IN ('L2001', 'L2101')
                  GROUP BY MBRN_CODE,
                           RPTHDGLDTL_CODE,
                           MBRN_NAME,
                           GLBALH_GLACC_CODE,
                           EXTGL_EXT_HEAD_DESCN))
GROUP BY BR_CODE,
         MBRN_NAME,
         GLBALH_GLACC_CODE,
         EXTGL_EXT_HEAD_DESCN,
         RPTHDGLDTL_CODE;
 
 ------------------------
 /* Formatted on 12/24/2019 6:51:00 PM (QP5 v5.227.12220.39754) */
  SELECT GMO_CODE,
         GMO_NAME,
         PO_CODE,
         PO_NAME,
         BR_CODE,
         MBRN_NAME,
         GLBALH_GLACC_CODE,
         EXTGL_EXT_HEAD_DESCN,
         SUM (NOV_BALANCE) NOV_BALANCE,
         SUM (DEC_BALANCE) DEC_BALANCE
    FROM (SELECT BRANCH_GMO GMO_CODE,
                 (SELECT MBRN_NAME
                    FROM MBRN
                   WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = BRANCH_GMO)
                    GMO_NAME,
                 BRANCH_PO PO_CODE,
                 (SELECT MBRN_NAME
                    FROM MBRN
                   WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = BRANCH_PO)
                    PO_NAME,
                 BR_CODE,
                 MBRN_NAME,
                 GLBALH_GLACC_CODE,
                 EXTGL_EXT_HEAD_DESCN,
                 NOV_BALANCE,
                 0 DEC_BALANCE
            FROM (  SELECT MBRN_CODE BR_CODE,
                           MBRN_NAME,
                           GLBALH_GLACC_CODE,
                           EXTGL_EXT_HEAD_DESCN,
                           NVL (GLBALH_BC_BAL, 0) NOV_BALANCE
                      FROM GLBALASONHIST, EXTGL, MBRN
                     WHERE     GLBALH_ENTITY_NUM = 1
                           AND GLBALH_GLACC_CODE IN
                                  ('300122117',
                                   '300122119',
                                   '300116113',
                                   '300122120',
                                   '300125185')
                           AND GLBALH_BRN_CODE = MBRN_CODE
                           AND GLBALH_ASON_DATE = '30-NOV-2019'
                           AND GLBALH_GLACC_CODE = EXTGL_ACCESS_CODE
                           AND GLBALH_BC_BAL <> 0
                  --AND GLBALH_ASON_DATE = '31-AUG-2018'
                  ORDER BY 1) TT,
                 MBRN_TREE2
           WHERE TT.BR_CODE = BRANCH_CODE AND BRANCH_GMO = 46995
          UNION ALL
          SELECT BRANCH_GMO GMO_CODE,
                 (SELECT MBRN_NAME
                    FROM MBRN
                   WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = BRANCH_GMO)
                    GMO_NAME,
                 BRANCH_PO PO_CODE,
                 (SELECT MBRN_NAME
                    FROM MBRN
                   WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = BRANCH_PO)
                    PO_NAME,
                 BR_CODE,
                 MBRN_NAME,
                 GLBALH_GLACC_CODE,
                 EXTGL_EXT_HEAD_DESCN,
                 0 NOV_BALANCE,
                 DEC_BALANCE
            FROM (  SELECT MBRN_CODE BR_CODE,
                           MBRN_NAME,
                           GLBALH_GLACC_CODE,
                           EXTGL_EXT_HEAD_DESCN,
                           NVL (GLBALH_BC_BAL, 0) DEC_BALANCE
                      FROM GLBALASONHIST, EXTGL, MBRN
                     WHERE     GLBALH_ENTITY_NUM = 1
                           AND GLBALH_GLACC_CODE IN
                                  ('300122117',
                                   '300122119',
                                   '300116113',
                                   '300122120',
                                   '300125185')
                           AND GLBALH_BRN_CODE = MBRN_CODE
                           AND GLBALH_ASON_DATE = '19-DEC-2019'
                           AND GLBALH_GLACC_CODE = EXTGL_ACCESS_CODE
                           AND GLBALH_BC_BAL <> 0
                  --AND GLBALH_ASON_DATE = '31-AUG-2018'
                  ORDER BY 1) TT,
                 MBRN_TREE2
           WHERE TT.BR_CODE = BRANCH_CODE AND BRANCH_GMO = 46995)
GROUP BY GMO_CODE,
         GMO_NAME,
         PO_CODE,
         PO_NAME,
         BR_CODE,
         MBRN_NAME,
         GLBALH_GLACC_CODE,
         EXTGL_EXT_HEAD_DESCN;
         
         
         
--------------------------------MCD/RCD-------------------------------
/* Formatted on 5/6/2021 2:54:27 PM (QP5 v5.252.13127.32867) */
SELECT *
  FROM (SELECT BR_CODE,
               MBRN_NAME,
               RPTHDGLDTL_CODE,
               LNPRDAC_PROD_CODE,
               GLBALH_GLACC_CODE,
               OUTSTANDING_BALANCE,
               ROW_NUMBER ()
               OVER (
                  PARTITION BY RPTHDGLDTL_CODE,
                               GLBALH_GLACC_CODE,
                               OUTSTANDING_BALANCE
                  ORDER BY RPTHDGLDTL_CODE)
                  AS nof
          FROM (SELECT /*+ PARALLEL( 24) */
                      MBRN_CODE BR_CODE,
                       MBRN_NAME,
                       LNPRDAC_PROD_CODE,
                       GLBALH_GLACC_CODE,
                       EXTGL_EXT_HEAD_DESCN,
                       RPTHDGLDTL_CODE,
                       FN_ISS_HEAD_BAL (MBRN_CODE,
                                        '31-DEC-2020',
                                        RPTHDGLDTL_CODE,
                                        'F42B')
                          OUTSTANDING_BALANCE              --245849.00  245849
                  FROM GLBALASONHIST,
                       lnprodacpm,
                       RPTHEADGLDTL H,
                       EXTGL,
                       MBRN
                 WHERE     RPTHDGLDTL_GLACC_CODE = GLBALH_GLACC_CODE
                       AND GLBALH_ENTITY_NUM = 1
                       AND LNPRDAC_INT_INCOME_GL = GLBALH_GLACC_CODE
                       AND GLBALH_BRN_CODE = MBRN_CODE
                       AND GLBALH_ASON_DATE = '31-DEC-2020'
                       AND GLBALH_GLACC_CODE = EXTGL_ACCESS_CODE
                       AND H.RPTHDGLDTL_CODE IN (SELECT RPTLAYOUTDTL_RPT_HEAD_CODE
                                                   FROM RPTLAYOUTDTL
                                                  WHERE RPTLAYOUTDTL_RPT_CODE =
                                                           'F42B')
                       AND RPTHDGLDTL_CODE IN ('I0115',
                                               'I0116',
                                               'I0117',
                                               'I0118',
                                               'I0243',
                                               'I0244',
                                               'I0119',
                                               'I0245',
                                               'I0249')
                       AND MBRN_CODE IN (6064, 17095)))
 WHERE nof = 1;
 
 
/* Formatted on 9/21/2021 3:31:21 PM (QP5 v5.149.1003.31008) */
SELECT                                                            --BRANCH_HO,
      GMO_BRANCH GMO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = GMO_BRANCH)
          GMO_NAME,
       PO_BRANCH PO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = PO_BRANCH)
          PO_NAME,
       MBRN_NAME,
       FN_F12_HEAD_BAL (mbrn_code,
                        '31-aug-2021',
                        'L2001',
                        'F12')
          L2001_31AUG,
       FN_F12_HEAD_BAL (mbrn_code,
                        '15-SEP-2021',
                        'L2001',
                        'F12')
          L2001_15SEP,
       FN_F12_HEAD_BAL (mbrn_code,
                        '31-AUG-2021',
                        'L2101',
                        'F12')
          L2101_31AUG,
       FN_F12_HEAD_BAL (mbrn_code,
                        '15-SEP-2021',
                        'L2101',
                        'F12')
          L2101_15SEP
  FROM mbrn, MBRN_TREE1
 WHERE mbrn_code = BRANCH;
 
 
 -----------------------------------------------------------------------------------------------------------------------------------------
 /* Formatted on 10/6/2021 5:20:22 PM (QP5 v5.149.1003.31008) */
  SELECT GLBALH_BRN_CODE,
         'BAGHA' RPT_BRN_NAME,
         GLBALH_ASON_DATE,
       ABS(  FN_BIS_GET_ASON_GLBAL (1,
                                GLBALH_BRN_CODE,
                                '225110114',
                                'BDT',
                                GLBALH_ASON_DATE,
                                '11-OCT-2021'))
            BALANCE_A0939,
      ABS(   FN_BIS_GET_ASON_GLBAL (1,
                                GLBALH_BRN_CODE,
                                '225110113',
                                'BDT',
                                GLBALH_ASON_DATE,
                                '11-OCT-2021'))
            BALANCE_A0927
    FROM GLBALASONHIST
   WHERE     GLBALH_ASON_DATE BETWEEN '01-JAN-2021' AND '11-OCT-2021'
         AND GLBALH_BRN_CODE = 46029
         AND GLBALH_GLACC_CODE = '225110113'
ORDER BY GLBALH_ASON_DATE