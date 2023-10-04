

---normal F12/F42B-------------------
DECLARE
   P_ERROR_MSG     VARCHAR2 (1000);
   P_ASON_DATE     DATE := '30-sep-2023';
 --  P_BRANCH_CODE   NUMBER := 1149;
BEGIN
   FOR IDX IN (SELECT MBRN_CODE P_BRANCH_CODE
                 FROM MBRN
                WHERE MBRN_CODE in ( 56069))
   LOOP
      DELETE FROM STATMENTOFAFFAIRS
         WHERE     RPT_ENTRY_DATE = P_ASON_DATE
              AND RPT_BRN_CODE = IDX.P_BRANCH_CODE;

      SP_STATEMENT_OF_AFFAIRS_F12 (IDX.P_BRANCH_CODE,
                                   P_ASON_DATE,
                                   P_ERROR_MSG,
                                   1,
                                   1,
                                   1,
                                   NULL);
     DELETE FROM INCOMEEXPENSE
          WHERE     RPT_ENTRY_DATE = P_ASON_DATE
              AND RPT_BRN_CODE = IDX.P_BRANCH_CODE;

      SP_INCOMEEXPENSE (IDX.P_BRANCH_CODE,
                        P_ASON_DATE,
                        P_ERROR_MSG,
                        1,
                        1,
                        1,
                        NULL);

      COMMIT;
   END LOOP;
END;
-------------------Landscape F12/F42B---------------
DECLARE
   V_ASON_DATE   DATE := '30-jun-2021';
BEGIN
   FOR IDX IN (  SELECT *
                   FROM (  SELECT BRANCH_CODE, ROWNUM BRANCH_SL
                             FROM MIG_DETAIL
                            WHERE branch_code IN
                                     (8219)
                         ORDER BY BRANCH_CODE)
                  WHERE BRANCH_CODE NOT IN (SELECT BRN_CODE
                                              FROM GLWISE_AMOUNT
                                             WHERE RPTDATE = V_ASON_DATE)
               ORDER BY BRANCH_CODE)
   LOOP
      PKG_STATEMENT_OF_AFFAIRS_F12.
       SP_GET_ASSETS_LIABILITIES ('F12',
                                  1,
                                  IDX.BRANCH_CODE,
                                  V_ASON_DATE,
                                  NULL);
      COMMIT;
   END LOOP;
END;


-----To view the report for PO/All branches please Process/Regenerate the data first.--------------

    SELECT BRANCH_LIST, (REGEXP_COUNT (BRANCH_LIST, ',') + 1) AS cnt
  FROM (SELECT LISTAGG (BRANCH_CODE, ',') WITHIN GROUP (ORDER BY BRANCH_CODE)
                  AS BRANCH_LIST
          FROM (SELECT BRANCH_CODE
                  FROM (SELECT DISTINCT BRANCH_CODE
                          FROM MIG_DETAIL
                         WHERE     MIG_END_DATE <= '15-MAY-2022'
                               AND BRANCH_CODE IN
                                      (    SELECT MBRN_CODE
                                             FROM MBRN
                                       START WITH MBRN_CODE = 18
                                       CONNECT BY PRIOR MBRN_CODE =
                                                     MBRN_PARENT_ADMIN_CODE)
                        MINUS
                        SELECT DISTINCT BRN_CODE
                          FROM GLWISE_AMOUNT
                         WHERE RPTDATE = '15-MAY-2022')));
                         
                         
                         
---------MULTIPLE DATE----------------------------------------------------------
/* Formatted on 10/18/2021 8:53:25 PM (QP5 v5.149.1003.31008) */
DECLARE
   P_ERROR_MSG   VARCHAR2 (1000);
   P_ASON_DATE   DATE := '26-jun-2023';
--  P_BRANCH_CODE   NUMBER := 1149;
BEGIN
   FOR IDX IN (SELECT MBRN_CODE P_BRANCH_CODE
                 FROM MBRN
                WHERE MBRN_CODE IN (34))
   LOOP
      WHILE P_ASON_DATE <= '30-jun-2023'
      LOOP
         DELETE FROM STATMENTOFAFFAIRS
               WHERE RPT_ENTRY_DATE = P_ASON_DATE
                     AND RPT_BRN_CODE = IDX.P_BRANCH_CODE;

         SP_STATEMENT_OF_AFFAIRS_F12 (IDX.P_BRANCH_CODE,
                                      P_ASON_DATE,
                                      P_ERROR_MSG,
                                      1,
                                      1,
                                      1,
                                      NULL);


         DELETE FROM INCOMEEXPENSE
               WHERE RPT_ENTRY_DATE = P_ASON_DATE
                     AND RPT_BRN_CODE = IDX.P_BRANCH_CODE;

         SP_INCOMEEXPENSE (IDX.P_BRANCH_CODE,
                           P_ASON_DATE,
                           P_ERROR_MSG,
                           1,
                           1,
                           1,
                           NULL);

         COMMIT;
         P_ASON_DATE := P_ASON_DATE + 1;
      END LOOP;
   END LOOP;
END;
