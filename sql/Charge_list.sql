/* Formatted on 2/23/2020 4:22:52 PM (QP5 v5.227.12220.39754) */
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
         ACNTS_BRN_CODE BRN_CODE,
         (SELECT MBRN_NAME
            FROM MBRN
           WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = ACNTS_BRN_CODE)
            Branch_name,
         CLCHGWAIVDT_CLIENT_NUM,
         CLIENTS_NAME,
         account_no,
         account_name,
         CHGCD_CHARGE_CODE,
         CHGCD_CHARGE_DESCN,
         LATEST_EFF_DATE,CLCHGWAIV_WAIVE_REQD
    FROM (SELECT CLCHGWAIVDT_CLIENT_NUM,
                 (SELECT CLIENTS_NAME
                    FROM clients
                   WHERE CLIENTS_CODE = CLCHGWAIVDT_CLIENT_NUM)
                    CLIENTS_NAME,
                 facno (1, CLCHGWAIVDT_INTERNAL_ACNUM) account_no,
                 (SELECT ACNTS_AC_NAME1 || ACNTS_AC_NAME2
                    FROM acnts
                   WHERE ACNTS_INTERNAL_ACNUM = CLCHGWAIVDT_INTERNAL_ACNUM)
                    account_name,
                 NVL (
                    (SELECT ACNTS_BRN_CODE
                       FROM acnts
                      WHERE ACNTS_INTERNAL_ACNUM = CLCHGWAIVDT_INTERNAL_ACNUM),
                    (SELECT CLIENTS_HOME_BRN_CODE
                       FROM clients
                      WHERE CLIENTS_CODE = CLCHGWAIVDT_CLIENT_NUM))
                    ACNTS_BRN_CODE,
                 CHGCD_CHARGE_CODE,
                 CHGCD_CHARGE_DESCN,
                 CLCHGWAIVDT_LATEST_EFF_DATE LATEST_EFF_DATE,CLCHGWAIV_WAIVE_REQD
            FROM CLCHGWAIVER, CLCHGWAIVEDTL, CHGCD
           WHERE     CLCHGWAIVDT_ENTITY_NUM = 1
                 --AND CLCHGWAIVDT_CLIENT_NUM in (86955,87586)
                 AND TRUNC (CLCHGWAIVDT_LATEST_EFF_DATE) > '31-DEC-2019'
                 AND CLCHGWAIV_ENTITY_NUM = 1
                 AND TRUNC (CLCHGWAIV_LATEST_EFF_DATE) > '31-DEC-2019'
                 AND CLCHGWAIV_WAIVE_REQD = '1'
                 AND CLCHGWAIV_CLIENT_NUM = CLCHGWAIVDT_CLIENT_NUM
                 and CLCHGWAIV_WAIVE_REQD=1
                 AND CLCHGWAIV_INTERNAL_ACNUM = CLCHGWAIVDT_INTERNAL_ACNUM
                 AND CLCHGWAIVDT_CHARGE_CODE = CHGCD_CHARGE_CODE) tt,
         MBRN_TREE2
   WHERE BRANCH_CODE = TT.ACNTS_BRN_CODE
ORDER BY ACNTS_BRN_CODE