/* Formatted on 12/23/2021 2:16:03 PM (QP5 v5.252.13127.32867) */
SELECT BT.PARENT_BRANCH Head_Office_Code,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = PARENT_BRANCH)
          Head_Office_Name,
       BT.GMO_BRANCH GMO_Code,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = GMO_BRANCH)
          GMO_Name,
       BT.PO_BRANCH PO_RO_Code,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = PO_BRANCH)
          PO_RO_Name,
       ACNTS_BRN_CODE Branch_Code,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = ACNTS_BRN_CODE)
          Branch_Name,
       t.*
  FROM (SELECT ACNTS_BRN_CODE,
               ACNTS_PROD_CODE,
               facno (1, ACNTS_INTERNAL_ACNUM) account_no,
               ACNTS_AC_NAME1 || ACNTS_AC_NAME2 account_name,
               ACNTS_AC_TYPE,
               ACNTS_AC_SUB_TYPE,
               LNACMIS_HO_DEPT_CODE cl_code
          FROM lnacmis, acnts
         WHERE     ACNTS_ENTITY_NUM = 1
               AND ACNTS_INTERNAL_ACNUM = LNACMIS_INTERNAL_ACNUM
               AND LNACMIS_ENTITY_NUM = 1
               AND ACNTS_CLOSURE_DATE IS NULL
               AND LNACMIS_HO_DEPT_CODE <> 'CL51'
               AND ACNTS_PROD_CODE = 2580) t,
       MBRN_TREE1 BT
 WHERE ACNTS_BRN_CODE = bt.BRANCH