/* Formatted on 07/09/2018 2:53:37 PM (QP5 v5.227.12220.39754) */
SELECT MBRN_PARENT_ADMIN_CODE GMO_PO_RO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_CODE = B.MBRN_PARENT_ADMIN_CODE)
          GMO_PO_RO_NAME,
       ACNTS_BRN_CODE BRANCH_CODE,
       MBRN_NAME BRANCH_NAME,
       PRODUCT_CODE,
       PRODUCT_NAME,
       LNACDISB_DISB_AMT DISB_AMT,
       LNACDISB_DISB_ON DISB_DATE
  FROM (SELECT MBRN_PARENT_ADMIN_CODE,
               ACNTS_BRN_CODE,
               MBRN_NAME,
               PRODUCT_CODE,
               PRODUCT_NAME,
               LNACDISB_DISB_AMT,
               LNACDISB_DISB_ON
          FROM (  SELECT ACNTS_BRN_CODE,
                         PRODUCT_CODE,
                         PRODUCT_NAME,
                         SUM (LNACDISB_DISB_AMT) LNACDISB_DISB_AMT,
                         LNACDISB_DISB_ON
                    FROM ACNTS, LNACDISB, PRODUCTS
                   WHERE     ACNTS_ENTITY_NUM = 1
                         AND LNACDISB_ENTITY_NUM = 1
                         AND ACNTS_INTERNAL_ACNUM = LNACDISB_INTERNAL_ACNUM
                         AND ACNTS_PROD_CODE = PRODUCT_CODE
                         AND ACNTS_CLOSURE_DATE IS NOT NULL
                         AND ACNTS_PROD_CODE IN
                                (2501,
                                 2502,
                                 2503,
                                 2504,
                                 2505,
                                 2506,
                                 2507,
                                 2508,
                                 2509,
                                 2510,
                                 2511,
                                 2512,
                                 2514,
                                 2534,
                                 2536,
                                 2537,
                                 2542,
                                 2546,
                                 2547,
                                 2548,
                                 2550,
                                 2551,
                                 2552,
                                 2553,
                                 2554)
                GROUP BY ACNTS_BRN_CODE,
                         PRODUCT_CODE,
                         PRODUCT_NAME,
                         LNACDISB_DISB_ON) A,
               MBRN
         WHERE A.ACNTS_BRN_CODE = MBRN_CODE) B