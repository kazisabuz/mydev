------ GENERATING THE TEMPORARY

BEGIN
   FOR IDX IN (  SELECT MBRN_CODE
                   FROM MBRN  where MBRN_CODE IN (SELECT BRANCH
                                FROM MBRN_TREE
                               WHERE GMO_BRANCH IN (50995, 18994))
               ORDER BY MBRN_CODE)
   LOOP
      INSERT INTO CL_TMP_DATA_BAK
         SELECT TT.*,IDX.MBRN_CODE FROM TABLE(PKG_CLREPORT.CL_RPT(1,'30-SEP-2022',IDX.MBRN_CODE)) TT;

      COMMIT;
   END LOOP;
END;


----- DATA SQL


SELECT --(SELECT MBRN_NAME FROM MBRN WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = BRANCH_HO   ) HO_NAME,
 --BRANCH_HO, 
 (SELECT MBRN_NAME FROM MBRN WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = GMO_BRANCH   ) GMO_NAME,
  GMO_BRANCH, 
  (SELECT MBRN_NAME FROM MBRN WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = PO_BRANCH   ) PO_NAME,
  PO_BRANCH,  
  (SELECT MBRN_NAME FROM MBRN WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = TT.BR_CODE   ) BRANCH_NAME,
  TT.* FROM 
(  SELECT BR_CODE,
         SUM (TOT_BAL_OUT) TOT_BAL_OUT,
         SUM (BAL_UNCLASS) BAL_UNCLASS,
         SUM (BAL_SPECIAL) BAL_SPECIAL,
         SUM (BAL_SUBSS) BAL_SUBSS,
         SUM (BAL_DOUBT) BAL_DOUBT,
         SUM (BAL_BAD_LOSS) BAL_BAD_LOSS,
         SUM (BAL_SUBSS) + SUM (BAL_DOUBT) + SUM (BAL_BAD_LOSS) Defaulted_total,
         SUM (PRO_BASE_UN) PRO_BASE_UN ,
         SUM (PRO_BASE_SP) BASE_PRO_SMA,
         SUM (PRO_BASE_SS) PRO_BASE_SS,
         SUM (PRO_BASE_DF) PRO_BASE_DF,
         SUM (PRO_BASE_BL) PRO_BASE_BL,
         SUM (AMT_PROV_RE) AMT_PROV_RE,
         SUM (INT_SUS_UN) INT_SUS_UN,
         SUM (INT_SUS_SP) INT_SUS_SP,
         SUM (INT_CLA_TOT) INT_CLA_TOT, 
         SUM (INT_SUS_UN) + SUM (INT_SUS_SP) + SUM (INT_CLA_TOT) INT_SUS_TOT,
         SUM (SEC_VAL) SEC_VAL,
         SUM(INT_SS_MIN_SUM) INT_SS_MIN_SUM
    FROM BACKUPTABLE.CL_TMP_DATA_BAK
GROUP BY BR_CODE
ORDER BY BR_CODE
) TT,
MBRN_TREE1 MB
WHERE TT.BR_CODE = MB.BRANCH;






---SHORT---------------
SELECT --(SELECT MBRN_NAME FROM MBRN WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = BRANCH_HO   ) HO_NAME,
 --BRANCH_HO, 
 (SELECT MBRN_NAME FROM MBRN WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = GMO_BRANCH   ) GMO_NAME,
  GMO_BRANCH, 
  (SELECT MBRN_NAME FROM MBRN WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = PO_BRANCH   ) PO_NAME,
  PO_BRANCH,  
  (SELECT MBRN_NAME FROM MBRN WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = TT.BR_CODE   ) BRANCH_NAME,
  TT.* FROM 
(  SELECT BR_CODE,RPT_DESCN,
         SUM (TOT_BAL_OUT) TOT_BAL_OUT,
         SUM (BAL_UNCLASS) BAL_UNCLASS,
         SUM (BAL_SPECIAL) BAL_SPECIAL,
         SUM (BAL_SUBSS) BAL_SUBSS,
         SUM (BAL_DOUBT) BAL_DOUBT,
         SUM (BAL_BAD_LOSS) BAL_BAD_LOSS,
         SUM (BAL_SUBSS) + SUM (BAL_DOUBT) + SUM (BAL_BAD_LOSS) Defaulted_total, 
         SUM (INT_SUS_UN) + SUM (INT_SUS_SP) + SUM (INT_CLA_TOT) INT_SUS_TOT,
         SUM (SEC_VAL) SEC_VAL,
         SUM(INT_SS_MIN_SUM) INT_SS_MIN_SUM
    FROM BACKUPTABLE.CL_TMP_DATA_BAK
GROUP BY BR_CODE,RPT_DESCN
ORDER BY BR_CODE
) TT,
MBRN_TREE1 MB
WHERE TT.BR_CODE = MB.BRANCH;


----------GENERAL----------------
  SELECT BR_CODE,
         (SELECT MBRN_NAME
            FROM MBRN
           WHERE MBRN_CODE = BR_CODE)
            BRANCH_NAME,
         SUM (BAL_UNCLASS) BAL_UNCLASS,
         SUM (BAL_SPECIAL) BAL_SMA,
         SUM (BAL_SUBSS) BAL_SUBSS,
         SUM (BAL_DOUBT) BAL_DOUBT,
         SUM (BAL_BAD_LOSS) BAL_BAD_LOSS,
         SUM (PRO_BASE_UN) PRO_BASE_UN,
         SUM (PRO_BASE_SP) PRO_BASE_SMA,
         SUM (PRO_BASE_SS) PRO_BASE_SS,
         SUM (PRO_BASE_DF) PRO_BASE_DF,
         SUM (PRO_BASE_BL) PRO_BASE_BL,
         SUM(AMT_PROV_RE)AMT_PROV_REQUIRED
    FROM BACKUPTABLE.CL_TMP_DATA_BAK
   WHERE     TRIM (RPT_DESCN) <> 'Staff Loan'
         AND BR_CODE IN (26,
                         16121,
                         16063,
                         16089,
                         1024,
                         44255,
                         44263,
                         36137,
                         10090,
                         8011,
                         9035,
                         10033,
                         49098,
                         46177,
                         30122,
                         50195,
                         19125,
                         19190,
                         18176,
                         5041,
                         43059,
                         7039,
                         51110,
                         57059,
                         27151,
                         27086,
                         27094,
                         24158,
                         26054)
GROUP BY BR_CODE;

----------STAFF------------------------

/* Formatted on 2/17/2022 12:31:50 PM (QP5 v5.252.13127.32867) */
  SELECT BR_CODE,
         (SELECT MBRN_NAME
            FROM MBRN
           WHERE MBRN_CODE = BR_CODE)
            BRANCH_NAME,
         SUM (BAL_UNCLASS) BAL_UNCLASS,
         SUM (BAL_SPECIAL) BAL_SMA,
         SUM (BAL_SUBSS) BAL_SUBSS,
         SUM (BAL_DOUBT) BAL_DOUBT,
         SUM (BAL_BAD_LOSS) BAL_BAD_LOSS,
         SUM (PRO_BASE_UN) PRO_BASE_UN,
         SUM (PRO_BASE_SP) PRO_BASE_SMA,
         SUM (PRO_BASE_SS) PRO_BASE_SS,
         SUM (PRO_BASE_DF) PRO_BASE_DF,
         SUM (PRO_BASE_BL) PRO_BASE_BL,
         SUM(AMT_PROV_RE)AMT_PROV_REQUIRED
    FROM BACKUPTABLE.CL_TMP_DATA_BAK
   WHERE     TRIM (RPT_DESCN) = 'Staff Loan'
         AND BR_CODE IN (26,
                         16121,
                         16063,
                         16089,
                         1024,
                         44255,
                         44263,
                         36137,
                         10090,
                         8011,
                         9035,
                         10033,
                         49098,
                         46177,
                         30122,
                         50195,
                         19125,
                         19190,
                         18176,
                         5041,
                         43059,
                         7039,
                         51110,
                         57059,
                         27151,
                         27086,
                         27094,
                         24158,
                         26054)
GROUP BY BR_CODE