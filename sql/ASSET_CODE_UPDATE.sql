/* Formatted on 7/12/2023 12:22:39 PM (QP5 v5.388) */
BEGIN
    FOR IDX
        IN (SELECT ACC_NO,
                   ASSET_CODE,
                   EFFECTIVE_DATE,
                   EXAMPION_DATE,
                   REMARKS
              FROM backuptable.ASSET_UPDATE)
    LOOP
        SP_LOAN_ASSET_CORRECTION (1,
                                  idx.ACC_NO,
                                  idx.ASSET_CODE,
                                  idx.EFFECTIVE_DATE,
                                  idx.EXAMPION_DATE,
                                  idx.REMARKS);
    END LOOP;
END;



---------------manually update-------------------

UPDATE ASSETCLS
   SET ASSETCLS_ASSET_CODE = idx.REPAY_FREQ,
       -- ASSETCLS_LATEST_EFF_DATE='31-DEC-2018',
       ASSETCLS_AUTO_MAN_FLG = 'M',
       ASSETCLS_NPA_DATE = idx.ACOPEN_DATE,
       ASSETCLS_REMARKS = 'Special Reschedule and One Time Exit',
       ASSETCLS_EXEMPT_END_DATE = IDX.REPAY_FROM
 WHERE ASSETCLS_INTERNAL_ACNUM = IDX.IACLINK_INTERNAL_ACNUM;

UPDATE ASSETCLSHIST
   SET ASSETCLSH_ASSET_CODE = idx.REPAY_FREQ,
       --  ASSETCLSH_EFF_DATE='31-DEC-2018',
       ASSETCLSH_AUTO_MAN_FLG = 'M',
       ASSETCLSH_NPA_DATE = idx.ACOPEN_DATE,
       ASSETCLSH_REMARKS = 'Special Reschedule and One Time Exit',
       ASSETCLSH_LAST_MOD_BY = 'INTELECT',
       ASSETCLSH_LAST_MOD_ON = SYSDATE,
       ASSETCLSH_PURPOSE_FLAG = '2',
       ASSETCLSH_EXEMPT_END_DATE = IDX.REPAY_FROM
 WHERE     ASSETCLSH_INTERNAL_ACNUM = IDX.IACLINK_INTERNAL_ACNUM
       AND ASSETCLSH_EFF_DATE =
           (SELECT MAX (ASSETCLSH_EFF_DATE)
             FROM ASSETCLSHIST
            WHERE     ASSETCLSH_ENTITY_NUM = 1
                  AND ASSETCLSH_INTERNAL_ACNUM = IDX.IACLINK_INTERNAL_ACNUM);


UPDATE LNACMIS
   SET LNACMIS_HO_DEPT_CODE = 'CL45'
 WHERE LNACMIS_INTERNAL_ACNUM = IDX.IACLINK_INTERNAL_ACNUM;

UPDATE LNACMISHIST
   SET LNACMISH_HO_DEPT_CODE = 'CL45',
       LNACMISH_LAST_MOD_BY = 'INTELECT',
       LNACMISH_LAST_MOD_ON = SYSDATE
 WHERE LNACMISH_INTERNAL_ACNUM = IDX.IACLINK_INTERNAL_ACNUM;


-----------------MANUALLY CHANGE ASSET CODE--------------------

SELECT GMO_BRANCH
           GMO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = GMO_BRANCH)
           GMO_NAME,
       PO_BRANCH
           PO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = PO_BRANCH)
           PO_NAME,
       (SELECT MBRN_CODE
          FROM MBRN
         WHERE MBRN_CODE = BRANCH_CODE)
           BRANCH_NAME,
       TT.*
  FROM (  SELECT ACNTS_BRN_CODE                       BRANCH_CODE,
                 ACNTS_PROD_CODE,
                 product_name,
                 facno (1, ACNTS_INTERNAL_ACNUM)      ACCOUNT_NUMBER,
                 ACNTS_AC_NAME1 || ACNTS_AC_NAME2     ACCOUNT_NAME,
                 ASSETCLSH_ASSET_CODE                 ASSET_CODE,
                 ASSETCLSH_EFF_DATE,
                 ACNTS_OPENING_DATE
            FROM ASSETCLSHIST, acnts, products
           WHERE     ASSETCLSH_EFF_DATE =
                     (SELECT MAX (ASSETCLSH_EFF_DATE)
                       FROM ASSETCLSHIST
                      WHERE     ASSETCLSH_ENTITY_NUM = 1
                            AND ASSETCLSH_EFF_DATE >= '1-jan-2023'
                            AND ASSETCLSH_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM)
                 AND product_code = ACNTS_PROD_CODE
                 AND ASSETCLSH_AUTO_MAN_FLG = 'M'
                 and ASSETCLSH_ASSET_CODE in ('UC','SM','ST','SD')
                 AND ASSETCLSH_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                 AND ACNTS_ENTITY_NUM = 1
        ORDER BY ACNTS_OPENING_DATE DESC) TT,
       MBRN_TREE
 WHERE TT.BRANCH_CODE = BRANCH AND GMO_BRANCH IN (23994, 27995);

------CLOSSING ACCONT

SELECT ACNTS_BRN_CODE,
       (SELECT mbrn_name
          FROM mbrn
         WHERE mbrn_code = ACNTS_BRN_CODE)        mbrn_name,
       ACNTS_PROD_CODE,
       (SELECT product_name
          FROM products
         WHERE product_code = ACNTS_PROD_CODE)    product_name,
       facno (1, ACNTS_INTERNAL_ACNUM)            account_no,
       ACNTS_AC_NAME1 || ACNTS_AC_NAME2           account_name,
       ACNTS_CLOSURE_DATE,
       ((NVL (FN_GET_ASON_ACBAL (1,
                                 ACNTS_INTERNAL_ACNUM,
                                 'BDT',
                                 ASSETCLS_LATEST_EFF_DATE,
                                 '28-JAN-2021'),
              0)))                                OUTSTANDING,
       ASSETCLS_ASSET_CODE,
       ASSETCLS_LATEST_EFF_DATE,
       ASSETCLS_REMARKS
  FROM ASSETCLS, acnts
 WHERE     ASSETCLS_ASSET_CODE = 'ST'
       AND ASSETCLS_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
       AND ACNTS_ENTITY_NUM = 1
       AND ACNTS_PROD_CODE <> 2501
       AND ACNTS_CLOSURE_DATE IS NOT NULL
       AND ASSETCLS_LATEST_EFF_DATE BETWEEN '01-DEC-2019' AND '31-DEC-2020'
       AND REGEXP_REPLACE (ASSETCLS_REMARKS, '[[:space:]]+', CHR (32)) LIKE
               '%One Time Exit%'
UNION ALL
SELECT ACNTS_BRN_CODE,
       (SELECT mbrn_name
          FROM mbrn
         WHERE mbrn_code = ACNTS_BRN_CODE)        mbrn_name,
       ACNTS_PROD_CODE,
       (SELECT product_name
          FROM products
         WHERE product_code = ACNTS_PROD_CODE)    product_name,
       facno (1, ACNTS_INTERNAL_ACNUM)            account_no,
       ACNTS_AC_NAME1 || ACNTS_AC_NAME2           account_name,
       ACNTS_CLOSURE_DATE,
       ((NVL (FN_GET_ASON_ACBAL (1,
                                 ACNTS_INTERNAL_ACNUM,
                                 'BDT',
                                 ASSETCLS_LATEST_EFF_DATE,
                                 '28-JAN-2021'),
              0)))                                OUTSTANDING,
       ASSETCLS_ASSET_CODE,
       ASSETCLS_LATEST_EFF_DATE,
       ASSETCLS_REMARKS
  FROM ASSETCLS, acnts
 WHERE     ASSETCLS_ASSET_CODE = 'ST'
       AND ASSETCLS_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
       AND ACNTS_ENTITY_NUM = 1
       AND ACNTS_CLOSURE_DATE IS NOT NULL
       AND ASSETCLS_LATEST_EFF_DATE BETWEEN '01-DEC-2019' AND '31-DEC-2020'
       AND ACNTS_PROD_CODE <> 2501
       AND ASSETCLS_INTERNAL_ACNUM IN
               (SELECT DISTINCT LNACRSDTL_INTERNAL_ACNUM
                 FROM LNACRSDTL
                WHERE LNACRSDTL_REPAY_FREQ = 'X' AND LNACRSDTL_ENTITY_NUM = 1);

-----ONE TIME EXIT

  SELECT ACNTS_BRN_CODE,
         ACNTS_PROD_CODE,
         product_name,
         PRODUCT_NAME,
         facno@dr (1, ACNTS_INTERNAL_ACNUM)     ACCOUNT_NUMBER,
         ACNTS_AC_NAME1 || ACNTS_AC_NAME2       ACCOUNT_NAME,
         ''                                     CL_Status_In_SERP_31122018,
         ASSETCLSH_ASSET_CODE                   CL_Status_In_CBS_31122018,
         ACNTS_OPENING_DATE
    FROM ASSETCLSHIST@dr, acnts@dr, products@dr
   WHERE     ASSETCLSH_EFF_DATE =
             (SELECT MAX (ASSETCLSH_EFF_DATE)
               FROM ASSETCLSHIST@dr
              WHERE     ASSETCLSH_ENTITY_NUM = 1
                    AND ASSETCLSH_EFF_DATE <= '31-DEC-2018'
                    AND ASSETCLSH_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM)
         AND product_code = ACNTS_PROD_CODE
         AND ASSETCLSH_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
         AND ACNTS_ENTITY_NUM = 1
         AND ASSETCLSH_INTERNAL_ACNUM IN
                 (SELECT IACLINK_INTERNAL_ACNUM
                   FROM acc4, iaclink@dr
                  WHERE     acc_no = IACLINK_ACTUAL_ACNUM
                        AND IACLINK_ENTITY_NUM = 1)
ORDER BY ACNTS_OPENING_DATE DESC;