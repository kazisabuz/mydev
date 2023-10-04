/* Formatted on 29/12/2020 7:52:04 PM (QP5 v5.227.12220.39754) */
SELECT MBRN_CODE Branch_Code,
       MBRN_NAME Branch_Name,
       facno (1, ACNTS_INTERNAL_ACNUM) 
       Account_Number,
       ACNTS_AC_NAME1 || ACNTS_AC_NAME2 Account_Name,
       CLIENTS_CODE Corporate_Client_Number,
       CLIENTS_CONST_CODE Constitution_Code
  FROM mbrn, clients, acnts
 WHERE     ACNTS_CLIENT_NUM = CLIENTS_CODE
       AND ACNTS_BRN_CODE = mbrn_code
       AND ACNTS_CLOSURE_DATE IS NULL
       and CLIENTS_CONST_CODE=9