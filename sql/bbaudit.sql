/* Formatted on 2/2/2020 3:18:28 PM (QP5 v5.227.12220.39754) */
SELECT ACNTS_BRN_CODE,
MBRN_NAME,
       ACNTS_PROD_CODE,
       PRODUCT_NAME,
       FACNO (1, ACNTS_INTERNAL_ACNUM) ACCOUNT_NO,
       ACCOUNT_NAME,
      'BDT' LNSUSP_CURR_CODE,
       OUTSTANDING_BAL,
     ABS(NVL(  INT_010119_311219,0)) INT_010119_311219,
       NVL(SUSBAL_BFOR_311219,0) SUSBAL_BFOR_311219,
       NVL(SUSBAL_010119TO311219,0)SUSBAL_010119TO311219,
      NVL(RECV_010119TO311219,0) RECV_010119TO311219,
        CL_CODE
  FROM (SELECT ACNTS_BRN_CODE,
               ACNTS_PRO
               
               
               
               
               
               
               D_CODE,
               ACNTS_INTERNAL_ACNUM,
               ACNTS_AC_NAME1 || ACNTS_AC_NAME2 ACCOUNT_NAME,
               ABS (FN_GET_ASON_ACBAL (1,
                                       ACNTS_INTERNAL_ACNUM,
                                       'BDT',
                                       '31-DEC-2019',
                                       '26-JAN-2020'))
                  OUTSTANDING_BAL,
               (SELECT SUM (LNINTAPPL_ACT_INT_AMT)
                  FROM LNINTAPPL
                 WHERE     LNINTAPPL_ACNT_NUM = ACNTS_INTERNAL_ACNUM
                       AND LNINTAPPL_APPL_DATE BETWEEN '01-JAN-2019'
                                                   AND '31-DEC-2019')
                  INT_010119_311219,
               (SELECT   SUM (
                            CASE
                               WHEN LNSUSP_DB_CR_FLG = 'C' THEN LNSUSP_AMOUNT
                               ELSE 0
                            END)
                       - SUM (
                            CASE
                               WHEN LNSUSP_DB_CR_FLG = 'D' THEN LNSUSP_AMOUNT
                               ELSE 0
                            END)
                  FROM LNSUSPLED
                 WHERE     LNSUSP_ENTITY_NUM = 1
                       AND LNSUSP_TRAN_DATE < '31-dec-2019'
                       AND LNSUSP_AUTH_BY IS NOT NULL
                       AND LNSUSP_ACNT_NUM = ACNTS_INTERNAL_ACNUM)
                  SUSBAL_BFOR_311219,
               (SELECT   SUM (
                            CASE
                               WHEN LNSUSP_DB_CR_FLG = 'C' THEN LNSUSP_AMOUNT
                               ELSE 0
                            END)
                       - SUM (
                            CASE
                               WHEN LNSUSP_DB_CR_FLG = 'D' THEN LNSUSP_AMOUNT
                               ELSE 0
                            END)
                  FROM LNSUSPLED
                 WHERE     LNSUSP_ENTITY_NUM = 1
                       AND LNSUSP_TRAN_DATE BETWEEN '01-JAN-2019'
                                                AND '31-dec-2019'
                       AND LNSUSP_AUTH_BY IS NOT NULL
                       AND LNSUSP_ACNT_NUM = ACNTS_INTERNAL_ACNUM)
                  SUSBAL_010119TO311219,
               (SELECT SUM (NVL (LNSUSP_AMOUNT, 0))
                  FROM LNSUSPLED
                 WHERE     LNSUSP_ENTITY_NUM = 1
                       AND LNSUSP_TRAN_DATE BETWEEN '01-JAN-2019'
                                                AND '31-DEC-2019'
                       AND LNSUSP_AUTH_BY IS NOT NULL
                       AND LNSUSP_ACNT_NUM = ACNTS_INTERNAL_ACNUM
                       AND LNSUSP_AUTO_MANUAL='M'
                       AND LNSUSP_DB_CR_FLG = 'D')
                  RECV_010119TO311219,
               (SELECT LNACMIS_HO_DEPT_CODE
                  FROM LNACMIS
                 WHERE LNACMIS_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM)
                  CL_CODE
          FROM ACNTS
         WHERE                                     -- LNSUSP_AUTO_MANUAL = 'M'
              ACNTS_INTERNAL_ACNUM IN
                  (SELECT IACLINK_INTERNAL_ACNUM
                     FROM IACLINK
                    WHERE     IACLINK_ACTUAL_ACNUM IN
                                 ('1617037000246',
                                  '1617037000072',
                                  '1617037004197',
                                  '1617037003983',
                                  '1617037000221',
                                  '1617037000254',
                                  '1617037002622',
                                  '1617037000287',
                                  '1617037000122',
                                  '1617037000196',
                                  '1617037002614',
                                  '1617037000147',
                                  '1617037000106',
                                  '1617037000205',
                                  '1617037000213',
                                  '1617037000238',
                                  '1617037000089',
                                  '1617037000097',
                                  '1617037000114',
                                  '1617037000139',
                                  '1617037005716',
                                  '1617041000002',
                                  '1617043000042')
                          AND IACLINK_ENTITY_NUM = 1) --  AND ACNTS_CLOSURE_DATE IS NULL
                                                     --  AND LNSUSP_DB_CR_FLG = 'D'
       ) A,
       PRODUCTS,
       MBRN
 WHERE ACNTS_PROD_CODE = PRODUCT_CODE AND MBRN_CODE = ACNTS_BRN_CODE