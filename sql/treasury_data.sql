/*<TOAD_FILE_CHUNK>*/
/* Formatted on 8/6/2023 4:54:38 PM (QP5 v5.388) */
---------------------CASA--------------------------

BEGIN
    FOR idx IN (SELECT mbrn_code FROM mbrn)
    LOOP
        INSERT INTO slabwisedata_int
            SELECT *
              FROM (  SELECT ACNTS_BRN_CODE,
                             ACNTS_PROD_CODE,
                             CASE
                                 WHEN CLIENTS_TYPE_FLG = 'I' THEN 'INDIVISUAL'
                                 WHEN CLIENTS_TYPE_FLG = 'C' THEN 'CORP'
                                 ELSE 'INDIVISUAL'
                             END                                        CL_TYPE,
                             SUM (fn_get_ason_acbal (1,
                                                     ACNTS_INTERNAL_ACNUM,
                                                     'BDT',
                                                     '30-JUN-2023',
                                                     '02-AUG-2023'))    BC_BAL,
                             '<1 CRORE'                                 ITEM,
                             SUM (SBCAIA_AC_INT_ACCR_AMT)               INT_ACCR_AMT
                        FROM products,
                             acnts,
                             clients,
                             SBCAIA
                       WHERE     ACNTS_ENTITY_NUM = 1
                             AND ACNTS_BRN_CODE = idx.mbrn_code
                             AND SBCAIA_ENTITY_NUM = 1
                             AND SBCAIA_BRN_CODE = ACNTS_BRN_CODE
                             AND SBCAIA_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                             AND SBCAIA_INT_ACCR_DB_CR = 'D'
                             AND SBCAIA_DATE_OF_ENTRY = '30-JUN-2023'
                             AND ACNTS_CLIENT_NUM = CLIENTS_CODE
                             AND ACNTS_OPENING_DATE <= '30-jun-2023'
                             AND (   ACNTS_CLOSURE_DATE IS NULL
                                  OR ACNTS_CLOSURE_DATE > '30-jun-2023')
                             --AND ACNTS_PROD_CODE = 1030
                             AND PRODUCT_CODE = ACNTS_PROD_CODE
                             AND PRODUCT_FOR_RUN_ACS = 1
                             AND PRODUCT_FOR_DEPOSITS = 1
                    GROUP BY ACNTS_BRN_CODE,
                             ACNTS_PROD_CODE,
                             CLIENTS_TYPE_FLG)
             WHERE BC_BAL <= 10000000
            UNION ALL
            SELECT *
              FROM (  SELECT ACNTS_BRN_CODE,
                             ACNTS_PROD_CODE,
                             CASE
                                 WHEN CLIENTS_TYPE_FLG = 'I' THEN 'INDIVISUAL'
                                 WHEN CLIENTS_TYPE_FLG = 'C' THEN 'CORP'
                                 ELSE 'INDIVISUAL'
                             END                                        CL_TYPE,
                             SUM (fn_get_ason_acbal (1,
                                                     ACNTS_INTERNAL_ACNUM,
                                                     'BDT',
                                                     '30-JUN-2023',
                                                     '02-AUG-2023'))    BC_BAL,
                             '<1 CRORE'                                 ITEM,
                             SUM (SBCAIA_AC_INT_ACCR_AMT)               INT_ACCR_AMT
                        FROM products,
                             acnts,
                             clients,
                             SBCAIA
                       WHERE     ACNTS_ENTITY_NUM = 1
                             AND ACNTS_BRN_CODE = idx.mbrn_code
                             AND ACNTS_CLIENT_NUM = CLIENTS_CODE
                             AND ACNTS_OPENING_DATE <= '30-jun-2023'
                             --AND ACNTS_PROD_CODE = 1030
                             AND PRODUCT_CODE = ACNTS_PROD_CODE
                             AND SBCAIA_ENTITY_NUM = 1
                             AND SBCAIA_BRN_CODE = ACNTS_BRN_CODE
                             AND SBCAIA_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                             AND SBCAIA_INT_ACCR_DB_CR = 'D'
                             AND SBCAIA_DATE_OF_ENTRY = '30-JUN-2023'
                             AND (   ACNTS_CLOSURE_DATE IS NULL
                                  OR ACNTS_CLOSURE_DATE > '30-jun-2023')
                             AND PRODUCT_FOR_RUN_ACS = 1
                             AND PRODUCT_FOR_DEPOSITS = 1
                    GROUP BY ACNTS_BRN_CODE,
                             ACNTS_PROD_CODE,
                             CLIENTS_TYPE_FLG)
             WHERE BC_BAL > 10000000 AND BC_BAL <= 250000000
            UNION ALL
            SELECT *
              FROM (  SELECT ACNTS_BRN_CODE,
                             ACNTS_PROD_CODE,
                             CASE
                                 WHEN CLIENTS_TYPE_FLG = 'I' THEN 'INDIVISUAL'
                                 WHEN CLIENTS_TYPE_FLG = 'C' THEN 'CORP'
                                 ELSE 'INDIVISUAL'
                             END                                        CL_TYPE,
                             SUM (fn_get_ason_acbal (1,
                                                     ACNTS_INTERNAL_ACNUM,
                                                     'BDT',
                                                     '30-JUN-2023',
                                                     '02-AUG-2023'))    BC_BAL,
                             '<1 CRORE'                                 ITEM,
                             SUM (SBCAIA_AC_INT_ACCR_AMT)               INT_ACCR_AMT
                        FROM products,
                             acnts,
                             clients,
                             SBCAIA
                       WHERE     ACNTS_ENTITY_NUM = 1
                             AND ACNTS_BRN_CODE = idx.mbrn_code
                             AND ACNTS_CLIENT_NUM = CLIENTS_CODE
                             AND SBCAIA_ENTITY_NUM = 1
                             AND SBCAIA_BRN_CODE = ACNTS_BRN_CODE
                             AND SBCAIA_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                             AND SBCAIA_INT_ACCR_DB_CR = 'D'
                             AND SBCAIA_DATE_OF_ENTRY = '30-JUN-2023'
                             AND ACNTS_OPENING_DATE <= '30-jun-2023'
                             AND (   ACNTS_CLOSURE_DATE IS NULL
                                  OR ACNTS_CLOSURE_DATE > '30-jun-2023')
                             --AND ACNTS_PROD_CODE = 1030
                             AND PRODUCT_CODE = ACNTS_PROD_CODE
                             AND PRODUCT_FOR_RUN_ACS = 1
                             AND PRODUCT_FOR_DEPOSITS = 1
                    GROUP BY ACNTS_BRN_CODE,
                             ACNTS_PROD_CODE,
                             CLIENTS_TYPE_FLG)
             WHERE BC_BAL > 250000000 AND BC_BAL <= 500000000
            UNION ALL
            SELECT *
              FROM (  SELECT ACNTS_BRN_CODE,
                             ACNTS_PROD_CODE,
                             CASE
                                 WHEN CLIENTS_TYPE_FLG = 'I' THEN 'INDIVISUAL'
                                 WHEN CLIENTS_TYPE_FLG = 'C' THEN 'CORP'
                                 ELSE 'INDIVISUAL'
                             END                                        CL_TYPE,
                             SUM (fn_get_ason_acbal (1,
                                                     ACNTS_INTERNAL_ACNUM,
                                                     'BDT',
                                                     '30-JUN-2023',
                                                     '02-AUG-2023'))    BC_BAL,
                             '<1 CRORE'                                 ITEM,
                             SUM (SBCAIA_AC_INT_ACCR_AMT)               INT_ACCR_AMT
                        FROM products,
                             acnts,
                             clients,
                             SBCAIA
                       WHERE     ACNTS_ENTITY_NUM = 1
                             AND ACNTS_BRN_CODE = idx.mbrn_code
                             AND ACNTS_CLIENT_NUM = CLIENTS_CODE
                             AND SBCAIA_ENTITY_NUM = 1
                             AND SBCAIA_BRN_CODE = ACNTS_BRN_CODE
                             AND SBCAIA_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                             AND SBCAIA_INT_ACCR_DB_CR = 'D'
                             AND SBCAIA_DATE_OF_ENTRY = '30-JUN-2023'
                             AND ACNTS_OPENING_DATE <= '30-jun-2023'
                             AND (   ACNTS_CLOSURE_DATE IS NULL
                                  OR ACNTS_CLOSURE_DATE > '30-jun-2023')
                             --AND ACNTS_PROD_CODE = 1030
                             AND PRODUCT_CODE = ACNTS_PROD_CODE
                             AND PRODUCT_FOR_RUN_ACS = 1
                             AND PRODUCT_FOR_DEPOSITS = 1
                    GROUP BY ACNTS_BRN_CODE,
                             ACNTS_PROD_CODE,
                             CLIENTS_TYPE_FLG)
             WHERE BC_BAL > 500000000 AND BC_BAL <= 1000000000
            UNION ALL
            SELECT *
              FROM (  SELECT ACNTS_BRN_CODE,
                             ACNTS_PROD_CODE,
                             CASE
                                 WHEN CLIENTS_TYPE_FLG = 'I' THEN 'INDIVISUAL'
                                 WHEN CLIENTS_TYPE_FLG = 'C' THEN 'CORP'
                                 ELSE 'INDIVISUAL'
                             END                                        CL_TYPE,
                             SUM (fn_get_ason_acbal (1,
                                                     ACNTS_INTERNAL_ACNUM,
                                                     'BDT',
                                                     '30-JUN-2023',
                                                     '02-AUG-2023'))    BC_BAL,
                             '<1 CRORE'                                 ITEM,
                             SUM (SBCAIA_AC_INT_ACCR_AMT)               INT_ACCR_AMT
                        FROM products,
                             acnts,
                             clients,
                             SBCAIA
                       WHERE     ACNTS_ENTITY_NUM = 1
                             AND ACNTS_BRN_CODE = idx.mbrn_code
                             AND SBCAIA_ENTITY_NUM = 1
                             AND SBCAIA_BRN_CODE = ACNTS_BRN_CODE
                             AND SBCAIA_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                             AND SBCAIA_INT_ACCR_DB_CR = 'D'
                             AND SBCAIA_DATE_OF_ENTRY = '30-JUN-2023'
                             AND ACNTS_CLIENT_NUM = CLIENTS_CODE
                             AND ACNTS_OPENING_DATE <= '30-jun-2023'
                             AND (   ACNTS_CLOSURE_DATE IS NULL
                                  OR ACNTS_CLOSURE_DATE > '30-jun-2023')
                             --AND ACNTS_PROD_CODE = 1030
                             AND PRODUCT_CODE = ACNTS_PROD_CODE
                             AND PRODUCT_FOR_RUN_ACS = 1
                             AND PRODUCT_FOR_DEPOSITS = 1
                    GROUP BY ACNTS_BRN_CODE,
                             ACNTS_PROD_CODE,
                             CLIENTS_TYPE_FLG)
             WHERE BC_BAL > 1000000000;

        COMMIT;
    END LOOP;
END;


BEGIN
    FOR idx IN (SELECT mbrn_code FROM mbrn)
    LOOP
        INSERT INTO slabwisedata
            SELECT *
              FROM (  SELECT ACNTS_BRN_CODE,
                             ACNTS_PROD_CODE,
                             CASE
                                 WHEN CLIENTS_TYPE_FLG = 'I' THEN 'INDIVISUAL'
                                 WHEN CLIENTS_TYPE_FLG = 'C' THEN 'CORP'
                                 ELSE 'INDIVISUAL'
                             END                                        CL_TYPE,
                             SUM (fn_get_ason_acbal (1,
                                                     ACNTS_INTERNAL_ACNUM,
                                                     'BDT',
                                                     '31-JUL-2023',
                                                     '08-AUG-2023'))    BC_BAL,
                             '<1 CRORE'                                 ITEM
                        FROM products, acnts, clients
                       WHERE     ACNTS_ENTITY_NUM = 1
                             AND ACNTS_BRN_CODE = idx.mbrn_code
                             AND ACNTS_CLIENT_NUM = CLIENTS_CODE
                             AND ACNTS_OPENING_DATE <= '31-jul-2023'
                             AND (   ACNTS_CLOSURE_DATE IS NULL
                                  OR ACNTS_CLOSURE_DATE > '31-jul-2023')
                             --AND ACNTS_PROD_CODE = 1030
                             AND PRODUCT_CODE = ACNTS_PROD_CODE
                             AND PRODUCT_FOR_RUN_ACS = 1
                             AND PRODUCT_FOR_DEPOSITS = 1
                    GROUP BY ACNTS_BRN_CODE,
                             ACNTS_PROD_CODE,
                             CLIENTS_TYPE_FLG)
             WHERE BC_BAL <= 10000000
            UNION ALL
            SELECT *
              FROM (  SELECT ACNTS_BRN_CODE,
                             ACNTS_PROD_CODE,
                             CASE
                                 WHEN CLIENTS_TYPE_FLG = 'I' THEN 'INDIVISUAL'
                                 WHEN CLIENTS_TYPE_FLG = 'C' THEN 'CORP'
                                 ELSE 'INDIVISUAL'
                             END                                        CL_TYPE,
                             SUM (fn_get_ason_acbal (1,
                                                     ACNTS_INTERNAL_ACNUM,
                                                     'BDT',
                                                     '31-JUL-2023',
                                                     '08-AUG-2023'))    BC_BAL,
                             '<1 CRORE'                                 ITEM
                        FROM products, acnts, clients
                       WHERE     ACNTS_ENTITY_NUM = 1
                             AND ACNTS_BRN_CODE = idx.mbrn_code
                             AND ACNTS_CLIENT_NUM = CLIENTS_CODE
                             AND ACNTS_OPENING_DATE <= '31-jul-2023'
                             AND (   ACNTS_CLOSURE_DATE IS NULL
                                  OR ACNTS_CLOSURE_DATE > '31-jul-2023')
                             --AND ACNTS_PROD_CODE = 1030
                             AND PRODUCT_CODE = ACNTS_PROD_CODE
                             AND PRODUCT_FOR_RUN_ACS = 1
                             AND PRODUCT_FOR_DEPOSITS = 1
                    GROUP BY ACNTS_BRN_CODE,
                             ACNTS_PROD_CODE,
                             CLIENTS_TYPE_FLG)
             WHERE BC_BAL > 10000000 AND BC_BAL <= 250000000
            UNION ALL
            SELECT *
              FROM (  SELECT ACNTS_BRN_CODE,
                             ACNTS_PROD_CODE,
                             CASE
                                 WHEN CLIENTS_TYPE_FLG = 'I' THEN 'INDIVISUAL'
                                 WHEN CLIENTS_TYPE_FLG = 'C' THEN 'CORP'
                                 ELSE 'INDIVISUAL'
                             END                                        CL_TYPE,
                             SUM (fn_get_ason_acbal (1,
                                                     ACNTS_INTERNAL_ACNUM,
                                                     'BDT',
                                                     '31-JUL-2023',
                                                     '08-AUG-2023'))    BC_BAL,
                             '<1 CRORE'                                 ITEM
                        FROM products, acnts, clients
                       WHERE     ACNTS_ENTITY_NUM = 1
                             AND ACNTS_BRN_CODE = idx.mbrn_code
                             AND ACNTS_CLIENT_NUM = CLIENTS_CODE
                             AND ACNTS_OPENING_DATE <= '31-jul-2023'
                             AND (   ACNTS_CLOSURE_DATE IS NULL
                                  OR ACNTS_CLOSURE_DATE > '31-jul-2023')
                             --AND ACNTS_PROD_CODE = 1030
                             AND PRODUCT_CODE = ACNTS_PROD_CODE
                             AND PRODUCT_FOR_RUN_ACS = 1
                             AND PRODUCT_FOR_DEPOSITS = 1
                    GROUP BY ACNTS_BRN_CODE,
                             ACNTS_PROD_CODE,
                             CLIENTS_TYPE_FLG)
             WHERE BC_BAL > 250000000 AND BC_BAL <= 500000000
            UNION ALL
            SELECT *
              FROM (  SELECT ACNTS_BRN_CODE,
                             ACNTS_PROD_CODE,
                             CASE
                                 WHEN CLIENTS_TYPE_FLG = 'I' THEN 'INDIVISUAL'
                                 WHEN CLIENTS_TYPE_FLG = 'C' THEN 'CORP'
                                 ELSE 'INDIVISUAL'
                             END                                        CL_TYPE,
                             SUM (fn_get_ason_acbal (1,
                                                     ACNTS_INTERNAL_ACNUM,
                                                     'BDT',
                                                     '31-JUL-2023',
                                                     '08-AUG-2023'))    BC_BAL,
                             '<1 CRORE'                                 ITEM
                        FROM products, acnts, clients
                       WHERE     ACNTS_ENTITY_NUM = 1
                             AND ACNTS_BRN_CODE = idx.mbrn_code
                             AND ACNTS_CLIENT_NUM = CLIENTS_CODE
                             AND ACNTS_OPENING_DATE <= '31-jul-2023'
                             AND (   ACNTS_CLOSURE_DATE IS NULL
                                  OR ACNTS_CLOSURE_DATE > '31-jul-2023')
                             --AND ACNTS_PROD_CODE = 1030
                             AND PRODUCT_CODE = ACNTS_PROD_CODE
                             AND PRODUCT_FOR_RUN_ACS = 1
                             AND PRODUCT_FOR_DEPOSITS = 1
                    GROUP BY ACNTS_BRN_CODE,
                             ACNTS_PROD_CODE,
                             CLIENTS_TYPE_FLG)
             WHERE BC_BAL > 500000000 AND BC_BAL <= 1000000000
            UNION ALL
            SELECT *
              FROM (  SELECT ACNTS_BRN_CODE,
                             ACNTS_PROD_CODE,
                             CASE
                                 WHEN CLIENTS_TYPE_FLG = 'I' THEN 'INDIVISUAL'
                                 WHEN CLIENTS_TYPE_FLG = 'C' THEN 'CORP'
                                 ELSE 'INDIVISUAL'
                             END                                        CL_TYPE,
                             SUM (fn_get_ason_acbal (1,
                                                     ACNTS_INTERNAL_ACNUM,
                                                     'BDT',
                                                     '31-JUL-2023',
                                                     '08-AUG-2023'))    BC_BAL,
                             '<1 CRORE'                                 ITEM
                        FROM products, acnts, clients
                       WHERE     ACNTS_ENTITY_NUM = 1
                             AND ACNTS_BRN_CODE = idx.mbrn_code
                             AND ACNTS_CLIENT_NUM = CLIENTS_CODE
                             AND ACNTS_OPENING_DATE <= '31-jul-2023'
                             AND (   ACNTS_CLOSURE_DATE IS NULL
                                  OR ACNTS_CLOSURE_DATE > '31-jul-2023')
                             --AND ACNTS_PROD_CODE = 1030
                             AND PRODUCT_CODE = ACNTS_PROD_CODE
                             AND PRODUCT_FOR_RUN_ACS = 1
                             AND PRODUCT_FOR_DEPOSITS = 1
                    GROUP BY ACNTS_BRN_CODE,
                             ACNTS_PROD_CODE,
                             CLIENTS_TYPE_FLG)
             WHERE BC_BAL > 1000000000;

        COMMIT;
    END LOOP;
END;
/

/*<TOAD_FILE_CHUNK>*/
/* Formatted on 8/8/2023 2:43:32 PM (QP5 v5.388) */
----------------------fdr--------------

BEGIN
    FOR idx IN (SELECT mbrn_code FROM mbrn)
    LOOP
        INSERT INTO /*+ PARALLEL( 16) */
                    slabwisedata_int
              SELECT /*+ PARALLEL( 16) */
                     ACNTS_BRN_CODE,
                     ACNTS_PROD_CODE,
                     CASE
                         WHEN CLIENTS_TYPE_FLG = 'I' THEN 'INDIVISUAL'
                         WHEN CLIENTS_TYPE_FLG = 'C' THEN 'CORP'
                         ELSE 'INDIVISUAL'
                     END                                                             CL_TYPE,
                     SUM (ACBALH_BC_BAL)                                             BC_BAL,
                     '<3 Months-<6 Months'                                           ITEM,
                     SUM (
                         (SELECT SUM (NVL (DEPIA_AC_INT_ACCR_AMT, 0))
                           FROM depia
                          WHERE     DEPIA_DATE_OF_ENTRY <= '31-JUL-2023'
                                AND DEPIA_ENTRY_TYPE = 'IP'
                                AND DEPIA_ENTITY_NUM = 1
                                AND DEPIA_BRN_CODE = idx.mbrn_code
                                -- AND DEPIA_CONTRACT_NUM = PBDCONT_CONT_NUM
                                AND DEPIA_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM))    int_paid
                FROM products,
                     acnts,
                     clients,
                     pbdcontract,
                     acbalasonhist
               WHERE     ACNTS_ENTITY_NUM = 1
                     AND ACNTS_BRN_CODE = idx.mbrn_code
                     AND ACNTS_CLIENT_NUM = CLIENTS_CODE
                     AND ACBALH_ENTITY_NUM = 1
                     AND ACBALH_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                     AND ACBALH_ASON_DATE =
                         (SELECT MAX (ACBALH_ASON_DATE)
                           FROM acbalasonhist
                          WHERE     ACBALH_ENTITY_NUM = 1
                                AND ACBALH_INTERNAL_ACNUM =
                                    ACNTS_INTERNAL_ACNUM
                                AND ACBALH_ASON_DATE <= '31-jul-2023')
                     AND PBDCONT_ENTITY_NUM = 1
                     AND PBDCONT_BRN_CODE = ACNTS_BRN_CODE
                     AND PBDCONT_DEP_AC_NUM = ACNTS_INTERNAL_ACNUM
                     AND PDBCONT_DEP_PRD_MONTHS <= 6
                     AND PBDCONT_DEP_OPEN_DATE <= '31-jul-2023'
                     AND (   PBDCONT_CLOSURE_DATE IS NULL
                          OR PBDCONT_CLOSURE_DATE > '31-jul-2023')
                     AND PRODUCT_CODE = ACNTS_PROD_CODE
                     AND ACNTS_PROD_CODE IN (1050, 1052, 1054)
            GROUP BY ACNTS_BRN_CODE, ACNTS_PROD_CODE, CLIENTS_TYPE_FLG
            UNION ALL
              SELECT /*+ PARALLEL( 16) */
                     ACNTS_BRN_CODE,
                     ACNTS_PROD_CODE,
                     CASE
                         WHEN CLIENTS_TYPE_FLG = 'I' THEN 'INDIVISUAL'
                         WHEN CLIENTS_TYPE_FLG = 'C' THEN 'CORP'
                         ELSE 'INDIVISUAL'
                     END                                                             CL_TYPE,
                     SUM (ACBALH_BC_BAL)                                             BC_BAL,
                     '6 Months-<12 Months'                                           ITEM,
                     SUM (
                         (SELECT SUM (NVL (DEPIA_AC_INT_ACCR_AMT, 0))
                           FROM depia
                          WHERE     DEPIA_DATE_OF_ENTRY <= '31-JUL-2023'
                                AND DEPIA_ENTRY_TYPE = 'IP'
                                AND DEPIA_ENTITY_NUM = 1
                                AND DEPIA_BRN_CODE = idx.mbrn_code
                                --AND DEPIA_CONTRACT_NUM = PBDCONT_CONT_NUM
                                AND DEPIA_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM))    int_paid
                FROM products,
                     acnts,
                     clients,
                     pbdcontract,
                     acbalasonhist
               WHERE     ACNTS_ENTITY_NUM = 1
                     AND ACNTS_BRN_CODE = idx.mbrn_code
                     AND ACNTS_CLIENT_NUM = CLIENTS_CODE
                     AND ACBALH_ENTITY_NUM = 1
                     AND ACBALH_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                     AND ACBALH_ASON_DATE =
                         (SELECT MAX (ACBALH_ASON_DATE)
                           FROM acbalasonhist
                          WHERE     ACBALH_ENTITY_NUM = 1
                                AND ACBALH_INTERNAL_ACNUM =
                                    ACNTS_INTERNAL_ACNUM
                                AND ACBALH_ASON_DATE <= '31-jul-2023')
                     AND PBDCONT_ENTITY_NUM = 1
                     AND PBDCONT_BRN_CODE = ACNTS_BRN_CODE
                     AND PBDCONT_DEP_AC_NUM = ACNTS_INTERNAL_ACNUM
                     AND PDBCONT_DEP_PRD_MONTHS > 6
                     AND PDBCONT_DEP_PRD_MONTHS < = 12
                     AND PBDCONT_DEP_OPEN_DATE <= '31-jul-2023'
                     AND (   PBDCONT_CLOSURE_DATE IS NULL
                          OR PBDCONT_CLOSURE_DATE > '31-jul-2023')
                     AND PRODUCT_CODE = ACNTS_PROD_CODE
                     AND ACNTS_PROD_CODE IN (1050, 1052, 1054)
            GROUP BY ACNTS_BRN_CODE, ACNTS_PROD_CODE, CLIENTS_TYPE_FLG
            UNION ALL
              SELECT /*+ PARALLEL( 16) */
                     ACNTS_BRN_CODE,
                     ACNTS_PROD_CODE,
                     CASE
                         WHEN CLIENTS_TYPE_FLG = 'I' THEN 'INDIVISUAL'
                         WHEN CLIENTS_TYPE_FLG = 'C' THEN 'CORP'
                         ELSE 'INDIVISUAL'
                     END                                                             CL_TYPE,
                     SUM (ACBALH_BC_BAL)                                             BC_BAL,
                     '12 Months-above'                                               ITEM,
                     SUM (
                         (SELECT SUM (NVL (DEPIA_AC_INT_ACCR_AMT, 0))
                           FROM depia
                          WHERE     DEPIA_DATE_OF_ENTRY <= '31-JUL-2023'
                                AND DEPIA_ENTRY_TYPE = 'IP'
                                AND DEPIA_ENTITY_NUM = 1
                                AND DEPIA_BRN_CODE = idx.mbrn_code
                                --  AND DEPIA_CONTRACT_NUM = PBDCONT_CONT_NUM
                                AND DEPIA_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM))    int_paid
                FROM products,
                     acnts,
                     clients,
                     pbdcontract,
                     acbalasonhist
               WHERE     ACNTS_ENTITY_NUM = 1
                     AND ACNTS_BRN_CODE = idx.mbrn_code
                     AND ACNTS_CLIENT_NUM = CLIENTS_CODE
                     AND ACBALH_ENTITY_NUM = 1
                     AND ACBALH_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                     AND ACBALH_ASON_DATE =
                         (SELECT MAX (ACBALH_ASON_DATE)
                           FROM acbalasonhist
                          WHERE     ACBALH_ENTITY_NUM = 1
                                AND ACBALH_INTERNAL_ACNUM =
                                    ACNTS_INTERNAL_ACNUM
                                AND ACBALH_ASON_DATE <= '31-jul-2023')
                     AND PBDCONT_ENTITY_NUM = 1
                     AND PBDCONT_BRN_CODE = ACNTS_BRN_CODE
                     AND PBDCONT_DEP_AC_NUM = ACNTS_INTERNAL_ACNUM
                     AND PDBCONT_DEP_PRD_MONTHS > 12
                     AND PBDCONT_DEP_OPEN_DATE <= '31-jul-2023'
                     AND (   PBDCONT_CLOSURE_DATE IS NULL
                          OR PBDCONT_CLOSURE_DATE > '31-jul-2023')
                     AND PRODUCT_CODE = ACNTS_PROD_CODE
                     AND ACNTS_PROD_CODE IN (1050, 1052, 1054)
            GROUP BY ACNTS_BRN_CODE, ACNTS_PROD_CODE, CLIENTS_TYPE_FLG;

        COMMIT;
    END LOOP;
END;

