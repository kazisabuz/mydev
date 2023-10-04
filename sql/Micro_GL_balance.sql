/* Formatted on 6/21/2021 2:11:50 PM (QP5 v5.252.13127.32867) */
select GMO_BRANCH GMO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = GMO_BRANCH)
          GMO_NAME,
       PO_BRANCH PO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = PO_BRANCH)
          PO_NAME,tt.*
from (SELECT MBRN_CODE Branch_Code,
       MBRN_NAME Branch_Name,
       CASE
          WHEN GL_TYPE = 'L' THEN 'Liability GL'
          WHEN GL_TYPE = 'A' THEN 'Asset GL'
          WHEN GL_TYPE = 'I' THEN 'INCOME GL'
          ELSE NULL
       END
          GL_Status,
       EXTGL_ACCESS_CODE GL_Access_Code,
       EXTGL_EXT_HEAD_DESCN Micro_GL_NAME,
       GLBALH_BC_BAL GL_Balance
  FROM EXTGL, GLMAST,GLBALASONHIST,MBRN
 WHERE GL_NUMBER = EXTGL_GL_HEAD
 AND EXTGL_ACCESS_CODE=GLBALH_GLACC_CODE
 AND GLBALH_BRN_CODE=MBRN_CODE
 AND GLBALH_ENTITY_NUM=1
 AND  GLBALH_ASON_DATE='20-JUNE-2021'
 AND GL_TYPE ='I'
 AND GLBALH_BC_BAL<0)TT,
       MBRN_TREE1
 WHERE TT.Branch_Code = BRANCH
 order by GL_ACCESS_CODE;