/* Formatted on 12/30/2019 9:44:02 PM (QP5 v5.227.12220.39754) */
  SELECT BRANCH_HO,
         (SELECT MBRN_NAME
            FROM MBRN
           WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = BRANCH_HO)
            HO_NAME,
         BRANCH_GMO,
         (SELECT MBRN_NAME
            FROM MBRN
           WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = BRANCH_GMO)
            GMO_NAME,
         BRANCH_PO,
         (SELECT MBRN_NAME
            FROM MBRN
           WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = BRANCH_PO)
            PO_NAME,
         TT.*
    FROM (SELECT BRNSTATUS_BRN_CODE BRN_CODE,mbrn_name
            FROM brnstatus,mbrn
           WHERE     BRNSTATUS_ENTITY_NUM = 1
                 AND BRNSTATUS_CURR_DATE = '30-dec-2019'
                 and BRNSTATUS_BRN_CODE=mbrn_code
                 AND BRNSTATUS_STATUS = 'I') TT,
         MBRN_TREE2
   WHERE BRANCH_CODE = TT.BRN_CODE
ORDER BY BRN_CODE