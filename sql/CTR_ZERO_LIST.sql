SELECT MBRN_CODE , (SELECT  MBRN_NAME FROM MBRN WHERE MBRN_CODE=T.MBRN_CODE) MBRN_NAME
FROM (SELECT MBRN_CODE 
  FROM MBRN
 WHERE MBRN_CODE NOT IN (SELECT MBRN_PARENT_ADMIN_CODE FROM MBRN)
MINUS
SELECT RPT_BRANCH_CODE
  FROM GOAML_TRAN_MASTER
 WHERE RPT_YEAR = 2020 AND RPT_MONTH = 12)  T 