/* Formatted on 22/11/2020 6:39:50 PM (QP5 v5.227.12220.39754) */
---BACK DATED
SELECT MBRN_CODE,
       MBRN_NAME,
       NVL (
          (SELECT GLBALH_BC_BAL
             FROM GLBALASONHIST
            WHERE     GLBALH_ENTITY_NUM = 1
                  AND GLBALH_GLACC_CODE = '225122306'
                  AND GLBALH_ASON_DATE =  '30-SEP-2022'
                  AND GLBALH_BRN_CODE = MBRN_CODE),
          0)
          GL_BAL_225122306,
       NVL (
          (SELECT GLBALH_BC_BAL
             FROM GLBALASONHIST
            WHERE     GLBALH_ENTITY_NUM = 1
                  AND GLBALH_GLACC_CODE = '300116113'
                  AND GLBALH_ASON_DATE = '30-SEP-2022'
                  AND GLBALH_BRN_CODE = MBRN_CODE),
          0)
          GLBC_BAL_300116113,
       NVL (
          (SELECT GLBALH_BC_BAL
             FROM GLBALASONHIST
            WHERE     GLBALH_ENTITY_NUM = 1
                  AND GLBALH_GLACC_CODE = '225122231'
                  AND GLBALH_ASON_DATE =  '30-SEP-2022'
                  AND GLBALH_BRN_CODE = MBRN_CODE),
          0)
          GL_BAL_225122231,
       NVL (
          (SELECT GLBALH_BC_BAL
             FROM GLBALASONHIST
            WHERE     GLBALH_ENTITY_NUM = 1
                  AND GLBALH_GLACC_CODE = '300116101'
                  AND GLBALH_ASON_DATE = '30-SEP-2022'
                  AND GLBALH_BRN_CODE = MBRN_CODE),
          0)
          GLBC_BAL_300116101,
       NVL (
          (SELECT GLBALH_BC_BAL
             FROM GLBALASONHIST
            WHERE     GLBALH_ENTITY_NUM = 1
                  AND GLBALH_GLACC_CODE = '137101165'
                  AND GLBALH_ASON_DATE =  '30-SEP-2022'
                  AND GLBALH_BRN_CODE = MBRN_CODE),
          0)
          GLBC_BAL_137101165,
       NVL (
          (SELECT GLBALH_BC_BAL
             FROM GLBALASONHIST
            WHERE     GLBALH_ENTITY_NUM = 1
                  AND GLBALH_GLACC_CODE = '400104101'
                  AND GLBALH_ASON_DATE = '30-SEP-2022'
                  AND GLBALH_BRN_CODE = MBRN_CODE),
          0)
          GL_BAL_400104101,
       NVL (
          (SELECT GLBALH_BC_BAL
             FROM GLBALASONHIST
            WHERE     GLBALH_ENTITY_NUM = 1
                  AND GLBALH_GLACC_CODE = '225116204'
                  AND GLBALH_ASON_DATE =  '30-SEP-2022'
                  AND GLBALH_BRN_CODE = MBRN_CODE),
          0)
          GLBC_BAL_225116204,
       NVL (
          (SELECT GLBALH_BC_BAL
             FROM GLBALASONHIST
            WHERE     GLBALH_ENTITY_NUM = 1
                  AND GLBALH_GLACC_CODE = '300131117'
                  AND GLBALH_ASON_DATE =  '30-SEP-2022'
                  AND GLBALH_BRN_CODE = MBRN_CODE),
          0)
          GL_BAL_300131117,
       NVL (
          (SELECT GLBALH_BC_BAL
             FROM GLBALASONHIST
            WHERE     GLBALH_ENTITY_NUM = 1
                  AND GLBALH_GLACC_CODE = '225127101'
                  AND GLBALH_ASON_DATE = '30-SEP-2022'
                  AND GLBALH_BRN_CODE = MBRN_CODE),
          0)
          GLBC_BAL_225127101,
       NVL (
          (SELECT GLBALH_BC_BAL
             FROM GLBALASONHIST
            WHERE     GLBALH_ENTITY_NUM = 1
                  AND GLBALH_GLACC_CODE = '300119104'
                  AND GLBALH_ASON_DATE = '30-SEP-2022'
                  AND GLBALH_BRN_CODE = MBRN_CODE),
          0)
          GL_BAL_300119104
  FROM MBRN;
  
----CURRENT DATE 
/* Formatted on 22/11/2020 6:39:50 PM (QP5 v5.227.12220.39754) */
SELECT MBRN_CODE,
       MBRN_NAME,
       NVL (
          (SELECT GLBBAL_BC_BAL
             FROM GLBbal
            WHERE     GLBBAL_ENTITY_NUM = 1
                  AND GLBBAL_GLACC_CODE = '225122306'
                  AND  GLBBAL_YEAR=2020
                  AND GLBBAL_BRANCH_CODE = MBRN_CODE),
          0)
          GL_BAL_225122306,
       NVL (
          (SELECT GLBBAL_BC_BAL
             FROM GLBbal
            WHERE     GLBBAL_ENTITY_NUM = 1
                  AND GLBBAL_GLACC_CODE = '300116113'
                  AND  GLBBAL_YEAR=2020
                  AND GLBBAL_BRANCH_CODE = MBRN_CODE),
          0)
          GLBC_BAL_300116113,
       NVL (
          (SELECT GLBBAL_BC_BAL
             FROM GLBbal
            WHERE     GLBBAL_ENTITY_NUM = 1
                  AND GLBBAL_GLACC_CODE = '225122231'
                  AND  GLBBAL_YEAR=2020
                  AND GLBBAL_BRANCH_CODE = MBRN_CODE),
          0)
          GL_BAL_225122231,
       NVL (
          (SELECT GLBBAL_BC_BAL
             FROM GLBbal
            WHERE     GLBBAL_ENTITY_NUM = 1
                  AND GLBBAL_GLACC_CODE = '300116101'
                  AND  GLBBAL_YEAR=2020
                  AND GLBBAL_BRANCH_CODE = MBRN_CODE),
          0)
          GLBC_BAL_300116101,
       NVL (
          (SELECT GLBBAL_BC_BAL
             FROM GLBbal
            WHERE     GLBBAL_ENTITY_NUM = 1
                  AND GLBBAL_GLACC_CODE = '137101165'
                  AND  GLBBAL_YEAR=2020
                  AND GLBBAL_BRANCH_CODE = MBRN_CODE),
          0)
          GLBC_BAL_137101165,
       NVL (
          (SELECT GLBBAL_BC_BAL
             FROM GLBbal
            WHERE     GLBBAL_ENTITY_NUM = 1
                  AND GLBBAL_GLACC_CODE = '400104101'
                  AND  GLBBAL_YEAR=2020
                  AND GLBBAL_BRANCH_CODE = MBRN_CODE),
          0)
          GL_BAL_400104101,
       NVL (
          (SELECT GLBBAL_BC_BAL
             FROM GLBbal
            WHERE     GLBBAL_ENTITY_NUM = 1
                  AND GLBBAL_GLACC_CODE = '225116204'
                  AND  GLBBAL_YEAR=2020
                  AND GLBBAL_BRANCH_CODE = MBRN_CODE),
          0)
          GLBC_BAL_225116204,
       NVL (
          (SELECT GLBBAL_BC_BAL
             FROM GLBbal
            WHERE     GLBBAL_ENTITY_NUM = 1
                  AND GLBBAL_GLACC_CODE = '300131117'
                  AND  GLBBAL_YEAR=2020
                  AND GLBBAL_BRANCH_CODE = MBRN_CODE),
          0)
          GL_BAL_300131117,
       NVL (
          (SELECT GLBBAL_BC_BAL
             FROM GLBbal
            WHERE     GLBBAL_ENTITY_NUM = 1
                  AND GLBBAL_GLACC_CODE = '225127101'
                  AND  GLBBAL_YEAR=2020
                  AND GLBBAL_BRANCH_CODE = MBRN_CODE),
          0)
          GLBC_BAL_225127101,
       NVL (
          (SELECT GLBBAL_BC_BAL
             FROM GLBbal
            WHERE     GLBBAL_ENTITY_NUM = 1
                  AND GLBBAL_GLACC_CODE = '300119104'
                  AND  GLBBAL_YEAR=2020
                  AND GLBBAL_BRANCH_CODE = MBRN_CODE),
          0)
          GL_BAL_300119104
  FROM MBRN