/* Formatted on 2/3/2022 3:11:20 PM (QP5 v5.252.13127.32867) */
SELECT  
       ACNTS_BRN_CODE,
       (SELECT mbrn_name
          FROM mbrn
         WHERE mbrn_code = ACNTS_BRN_CODE)
          mbrn_name,IACLINK_ACTUAL_ACNUM,
       ACNTS_AC_NAME1 || ACNTS_AC_NAME2 account_name,
          ACNTS_AC_ADDR1
       || ACNTS_AC_ADDR2
       || ACNTS_AC_ADDR3
       || ACNTS_AC_ADDR4
       || ACNTS_AC_ADDR5
          address
  FROM acnts a, iaclink i
 WHERE     IACLINK_ENTITY_NUM = 1
 --and upper(ACNTS_AC_NAME1 || ACNTS_AC_NAME2)  LIKE '%TOUFI% IMAM%'
       AND IACLINK_ACTUAL_ACNUM LIKE '%34024017%'
       AND a.ACNTS_INTERNAL_ACNUM = i.IACLINK_INTERNAL_ACNUM
       AND ACNTS_ENTITY_NUM = 1