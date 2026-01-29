CREATE OR REPLACE PROCEDURE         SP_GEN_F12_F42_DATA (
   P_FROM_BRN    NUMBER,
   P_TO_BRN      NUMBER)
IS
   V_CBD            DATE;
   P_ERROR_MSG      VARCHAR2 (1000);
   V_DUMMY_COUNT    NUMBER;
   V_ASON_DATE      DATE;

   P_TEMPSER        NUMBER;

   P_PROCESS_DATE   DATE;
   P_ERR_MSG        VARCHAR2 (32767);
--P_ERR_MSG           OUT VARCHAR2
BEGIN
   V_ASON_DATE := TRUNC (SYSDATE) - 1;

--    V_ASON_DATE := '07-DEC-2021';

   FOR IDX IN (  SELECT *
                   FROM (  SELECT BRANCH_CODE, ROWNUM BRANCH_SL
                             FROM MIG_DETAIL
                         ORDER BY BRANCH_CODE)
                  WHERE BRANCH_SL BETWEEN P_FROM_BRN AND P_TO_BRN
               ORDER BY BRANCH_CODE)
   LOOP
      DELETE FROM INCOMEEXPENSE
            WHERE     RPT_ENTRY_DATE = V_ASON_DATE
                  AND RPT_BRN_CODE = IDX.BRANCH_CODE;


      DELETE FROM PROFIT_LOSS
            WHERE     RPT_ENTRY_DATE = V_ASON_DATE
                  AND RPT_BRN_CODE = IDX.BRANCH_CODE;



      SP_INCOMEEXPENSE (IDX.BRANCH_CODE,
                        V_ASON_DATE,
                        P_ERROR_MSG,
                        1,
                        1,
                        1,
                        NULL);
      COMMIT;
   END LOOP;



   FOR IDX IN (  SELECT *
                   FROM (  SELECT BRANCH_CODE, ROWNUM BRANCH_SL
                             FROM MIG_DETAIL
                         ORDER BY BRANCH_CODE)
                  WHERE BRANCH_SL BETWEEN P_FROM_BRN AND P_TO_BRN
               ORDER BY BRANCH_CODE)
   LOOP
      DELETE FROM STATMENTOFAFFAIRS
            WHERE     RPT_ENTRY_DATE = V_ASON_DATE
                  AND RPT_BRN_CODE = IDX.BRANCH_CODE;

      SP_STATEMENT_OF_AFFAIRS_F12 (IDX.BRANCH_CODE,
                                   V_ASON_DATE,
                                   P_ERROR_MSG,
                                   1,
                                   1,
                                   1,
                                   NULL);
      COMMIT;
   END LOOP;


   FOR IDX IN (  SELECT *
                   FROM (  SELECT BRANCH_CODE, ROWNUM BRANCH_SL
                             FROM MIG_DETAIL
                         ORDER BY BRANCH_CODE)
                  WHERE BRANCH_SL BETWEEN P_FROM_BRN AND P_TO_BRN
               ORDER BY BRANCH_CODE)
   LOOP
      DELETE FROM STATMENTOFAFFAIRS_OLD
            WHERE     RPT_ENTRY_DATE = V_ASON_DATE
                  AND RPT_BRN_CODE = IDX.BRANCH_CODE;

      SP_STATEMENT_OF_AFFAIRS_OLD (IDX.BRANCH_CODE,
                                   V_ASON_DATE,
                                   P_ERROR_MSG,
                                   1,
                                   1,
                                   1,
                                   NULL);
      COMMIT;
   END LOOP;



   FOR IDX IN (  SELECT *
                   FROM (  SELECT BRANCH_CODE, ROWNUM BRANCH_SL
                             FROM MIG_DETAIL
                         ORDER BY BRANCH_CODE)
                  WHERE     BRANCH_SL BETWEEN P_FROM_BRN AND P_TO_BRN
                        AND BRANCH_CODE NOT IN (SELECT BRN_CODE
                                                  FROM GLWISE_AMOUNT
                                                 WHERE RPTDATE = V_ASON_DATE)
               ORDER BY BRANCH_CODE)
   LOOP
      PKG_STATEMENT_OF_AFFAIRS_F12.SP_GET_ASSETS_LIABILITIES (
         'F12',
         1,
         IDX.BRANCH_CODE,
         V_ASON_DATE,
         NULL);
      COMMIT;
   END LOOP;



   FOR IDX
      IN (  SELECT *
              FROM (  SELECT BRANCH_CODE, ROWNUM BRANCH_SL
                        FROM MIG_DETAIL
                    ORDER BY BRANCH_CODE)
             WHERE     BRANCH_SL BETWEEN P_FROM_BRN AND P_TO_BRN
                   AND BRANCH_CODE NOT IN (SELECT RPT_BRN_CODE
                                             FROM SCHEDULE_TELEGRAM_F32
                                            WHERE RPT_ENTRY_DATE = V_ASON_DATE)
          ORDER BY BRANCH_CODE)
   LOOP
      SP_SCHEDULE_TELEGRAM_F32 (IDX.BRANCH_CODE,
                                V_ASON_DATE,
                                P_ERROR_MSG,
                                'F32');
      COMMIT;
   END LOOP;



   BEGIN
      P_TEMPSER := NULL;
      P_ERR_MSG := NULL;

      SP_DEPOSIT_ADVANCE_CASH_DATA (V_ASON_DATE, P_TEMPSER, P_ERR_MSG);
      COMMIT;
   END;



   IF TRUNC (V_ASON_DATE + 1, 'MONTH') = V_ASON_DATE + 1
   THEN
      FOR IDX IN (  SELECT *
                      FROM (  SELECT BRANCH_CODE, ROWNUM BRANCH_SL
                                FROM MIG_DETAIL      --WHERE BRANCH_CODE=28050
                            ORDER BY BRANCH_CODE)
                     WHERE BRANCH_SL BETWEEN P_FROM_BRN AND P_TO_BRN
                  ORDER BY BRANCH_CODE)
      LOOP
         PKG_F12_SME_DATA_GENERATE.SP_GET_ASSETS_LIABILITIES (
            'F12',
            1,
            IDX.BRANCH_CODE,
            V_ASON_DATE,
            1);
         COMMIT;
      END LOOP;



      FOR IDX IN (  SELECT *
                      FROM (SELECT BRANCH_CODE, ROWNUM BRANCH_SL
                              FROM (  SELECT BRANCH_CODE
                                        FROM MIG_DETAIL
                                    --   WHERE BRANCH_CODE NOT IN (SELECT BRANCH_CODE FROM CIB_CONTRACT)
                                    ORDER BY BRANCH_CODE))
                     WHERE BRANCH_SL BETWEEN P_FROM_BRN AND P_TO_BRN
                  ORDER BY BRANCH_CODE)
      LOOP
         DELETE FROM SME_DATA4
               WHERE BRN_CODE = IDX.BRANCH_CODE AND RPTDATE = V_ASON_DATE;

         INSERT INTO SME_DATA4
            SELECT *
              FROM (  SELECT brn_code,
                             prod_code,
                             sme_code,
                             SUM (cr) cr,
                             SUM (dr) dr,
                             CASE
                                WHEN sme_code = 11
                                THEN
                                   'Total SME Finance (Term Loan to Service)'
                                WHEN sme_code = 21
                                THEN
                                   'Total SME Finance (Term Loan to Service)'
                                WHEN sme_code = 31
                                THEN
                                   'Total SME Finance (Term Loan to Service)'
                                --            13, 23, 33, 43
                                WHEN sme_code = 13
                                THEN
                                   'Total SME Finance (Term Loan to Manufacturing)'
                                WHEN sme_code = 23
                                THEN
                                   'Total SME Finance (Term Loan to Manufacturing)'
                                WHEN sme_code = 33
                                THEN
                                   'Total SME Finance (Term Loan to Manufacturing)'
                                WHEN sme_code = 43
                                THEN
                                   'Total SME Finance (Term Loan to Manufacturing)'
                                WHEN sme_code = 12
                                THEN
                                   'Total SME Finance (Term Loan to Trading)'
                                WHEN sme_code = 22
                                THEN
                                   'Total SME Finance (Term Loan to Trading)'
                                WHEN sme_code = 32
                                THEN
                                   'Total SME Finance (Term Loan to Trading)'
                                ELSE
                                   'OTHERS'
                             END
                                AS SME_TYPE,
                             'Total SME Finance (Term Loan):' AS TYPE1,
                             'Total SME Finance:' AS TYPE2,
                             RPTDATE
                        FROM GLWISE_AMOUNT_SME3 A
                       WHERE     RPTHDGLDTL_CODE <> 'L2607'
                             AND BRN_CODE = IDX.BRANCH_CODE
                             AND RPTDATE = V_ASON_DATE
                             AND RPTHDGLDTL_CODE IN (SELECT DISTINCT
                                                            SME_GRP_CODE
                                                       FROM SMEFINGRP)
                             AND prod_code IN (SELECT PRODUCT_CODE
                                                 FROM PRODUCTS
                                                WHERE     PRODUCT_FOR_LOANS =
                                                             '1'
                                                      AND PRODUCT_FOR_RUN_ACS =
                                                             '0')
                    GROUP BY brn_code,
                             prod_code,
                             sme_code,
                             RPTDATE
                    UNION ALL
                      SELECT brn_code,
                             prod_code,
                             sme_code,
                             SUM (cr),
                             SUM (dr),
                             CASE
                                WHEN sme_code = 11
                                THEN
                                   'Total SME Finance (Working Capital to Service)'
                                WHEN sme_code = 21
                                THEN
                                   'Total SME Finance (Working Capital to Service)'
                                WHEN sme_code = 31
                                THEN
                                   'Total SME Finance (Working Capital to Service)'
                                --            13, 23, 33, 43
                                WHEN sme_code = 13
                                THEN
                                   'Total SME Finance (Working Capital to Manufacturing)'
                                WHEN sme_code = 23
                                THEN
                                   'Total SME Finance (Working Capital to Manufacturing)'
                                WHEN sme_code = 33
                                THEN
                                   'Total SME Finance (Working Capital to Manufacturing)'
                                WHEN sme_code = 43
                                THEN
                                   'Total SME Finance (Working Capital to Manufacturing)'
                                WHEN sme_code = 12
                                THEN
                                   'Total SME Finance (Working Capital to Trading)'
                                WHEN sme_code = 22
                                THEN
                                   'Total SME Finance (Working Capital to Trading)'
                                WHEN sme_code = 32
                                THEN
                                   'Total SME Finance (Working Capital to Trading)'
                                ELSE
                                   'OTHERS'
                             END
                                AS SME_TYPE,
                             'Total SME Finance (Working Capital):' AS TYPE1,
                             'Total SME Finance:' AS TYPE2,
                             RPTDATE
                        FROM GLWISE_AMOUNT_SME3 A
                       WHERE     RPTHDGLDTL_CODE <> 'L2607'
                             AND BRN_CODE = IDX.BRANCH_CODE
                             AND RPTDATE = V_ASON_DATE
                             AND RPTHDGLDTL_CODE IN (SELECT DISTINCT
                                                            SME_GRP_CODE
                                                       FROM SMEFINGRP)
                             AND prod_code IN (SELECT PRODUCT_CODE
                                                 FROM PRODUCTS
                                                WHERE     PRODUCT_FOR_LOANS =
                                                             '1'
                                                      AND PRODUCT_FOR_RUN_ACS =
                                                             '1')
                    GROUP BY brn_code,
                             prod_code,
                             sme_code,
                             RPTDATE
                    UNION ALL
                      SELECT brn_code,
                             prod_code,
                             sme_code,
                             SUM (cr),
                             SUM (dr),
                             CASE
                                WHEN sme_code = 11
                                THEN
                                   'Total CMSME (Working Capital to Service)'
                                WHEN sme_code = 21
                                THEN
                                   'Total CMSME (Working Capital to Service)'
                                WHEN sme_code = 31
                                THEN
                                   'Total CMSME (Working Capital to Service)'
                                --            13, 23, 33, 43
                                WHEN sme_code = 13
                                THEN
                                   'Total CMSME (Working Capital to Manufacturing)'
                                WHEN sme_code = 23
                                THEN
                                   'Total CMSME (Working Capital to Manufacturing)'
                                WHEN sme_code = 33
                                THEN
                                   'Total CMSME (Working Capital to Manufacturing)'
                                WHEN sme_code = 43
                                THEN
                                   'Total CMSME (Working Capital to Manufacturing)'
                                WHEN sme_code = 12
                                THEN
                                   'Total CMSME (Working Capital to Trading)'
                                WHEN sme_code = 22
                                THEN
                                   'Total CMSME (Working Capital to Trading)'
                                WHEN sme_code = 32
                                THEN
                                   'Total CMSME (Working Capital to Trading)'
                                ELSE
                                   'OTHERS'
                             END
                                AS SME_TYPE,
                             'Total CMSME (Working Capital):' AS TYPE1,
                             'Total CMSME' AS TYPE2,
                             RPTDATE
                        FROM GLWISE_AMOUNT_SME3 A
                       WHERE     RPTHDGLDTL_CODE <> 'L2607'
                             AND BRN_CODE = IDX.BRANCH_CODE
                             AND RPTDATE = V_ASON_DATE
                             AND RPTHDGLDTL_CODE IN (SELECT DISTINCT
                                                            SME_GRP_CODE
                                                       FROM SMEFINGRP)
                             AND prod_code = 2220
                    GROUP BY brn_code,
                             prod_code,
                             sme_code,
                             RPTDATE);

         COMMIT;
      END LOOP;
   END IF;
END SP_GEN_F12_F42_DATA;
/
