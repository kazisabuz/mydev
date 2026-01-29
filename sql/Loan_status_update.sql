/*The users might change the asset status of a loan account. There are some rules from the customers. We needed to change the the asset code of the accounts thouse were changed by the users from the frontend.*/
UPDATE ASSETCLSHIST AM
   SET AM.ASSETCLSH_ASSET_CODE = 'ST'
 WHERE     AM.ASSETCLSH_ENTITY_NUM = 1
       AND AM.ASSETCLSH_INTERNAL_ACNUM IN
              (SELECT a.acnts_internal_acnum
                 FROM acnts a,
                      lnprodpm lp,
                      Lnacrs lr,
                      limitline lm,
                      Acaslldtl asd,
                      ASSETCLS
                WHERE     a.acnts_entity_num = 1
                      AND a.acnts_prod_code = lp.lnprd_prod_code
                      AND a.acnts_closure_date IS NULL
                      AND lp.lnprd_short_term_loan = '1'
                      AND lr.lnacrs_entity_num = 1
                      AND lr.lnacrs_rephasement_entry = '1'
                      AND a.acnts_internal_acnum = lr.lnacrs_internal_acnum
                      AND lm.lmtline_entity_num = 1
                      AND asd.acaslldtl_entity_num = 1
                      AND LR.LNACRS_PURPOSE = 'R'
                      AND asd.acaslldtl_internal_acnum =
                             a.acnts_internal_acnum
                      AND lm.lmtline_client_code = asd.acaslldtl_client_num
                      AND lm.lmtline_num = asd.acaslldtl_limit_line_num
                      AND lm.lmtline_limit_expiry_date >= LAST_DAY(TO_DATE(SYSDATE))
                      AND ASSETCLS_ENTITY_NUM = 1
                      AND ASSETCLS_INTERNAL_ACNUM = lr.lnacrs_internal_acnum
                      AND ASSETCLS_ASSET_CODE <> 'ST')
       AND AM.ASSETCLSH_EFF_DATE =
              (SELECT MAX (ASSETCLSH_EFF_DATE)
                 FROM ASSETCLSHIST ASS
                WHERE     ASS.ASSETCLSH_ENTITY_NUM = 1
                      AND ASS.ASSETCLSH_INTERNAL_ACNUM =
                             AM.ASSETCLSH_INTERNAL_ACNUM);

UPDATE ASSETCLS
   SET ASSETCLS_ASSET_CODE = 'ST'
 WHERE     ASSETCLS_ENTITY_NUM = 1
       AND ASSETCLS_INTERNAL_ACNUM IN
              (SELECT a.acnts_internal_acnum
                 FROM acnts a,
                      lnprodpm lp,
                      Lnacrs lr,
                      limitline lm,
                      Acaslldtl asd,
                      ASSETCLS
                WHERE     a.acnts_entity_num = 1
                      AND a.acnts_prod_code = lp.lnprd_prod_code
                      AND a.acnts_closure_date IS NULL
                      AND lp.lnprd_short_term_loan = '1'
                      AND lr.lnacrs_entity_num = 1
                      AND lr.lnacrs_rephasement_entry = '1'
                      AND a.acnts_internal_acnum = lr.lnacrs_internal_acnum
                      AND lm.lmtline_entity_num = 1
                      AND asd.acaslldtl_entity_num = 1
                      AND LR.LNACRS_PURPOSE = 'R'
                      AND asd.acaslldtl_internal_acnum =
                             a.acnts_internal_acnum
                      AND lm.lmtline_client_code = asd.acaslldtl_client_num
                      AND lm.lmtline_num = asd.acaslldtl_limit_line_num
                      AND lm.lmtline_limit_expiry_date >= LAST_DAY(TO_DATE(SYSDATE))
                      AND ASSETCLS_ENTITY_NUM = 1
                      AND ASSETCLS_INTERNAL_ACNUM = lr.lnacrs_internal_acnum
                      AND ASSETCLS_ASSET_CODE <> 'ST');
					  
					  
					  
UPDATE ASSETCLSHIST A SET A.ASSETCLSH_ASSET_CODE = 'UC', A.ASSETCLSH_NPA_DATE = NULL  WHERE A.ASSETCLSH_ENTITY_NUM = 1 AND (A.ASSETCLSH_INTERNAL_ACNUM, A.ASSETCLSH_EFF_DATE) IN (
SELECT ASSETCLSH_INTERNAL_ACNUM, MAX(ASSETCLSH_EFF_DATE) FROM ACNTS, ASSETCLSHIST
WHERE ACNTS_ENTITY_NUM = 1
AND ACNTS_PROD_CODE = 2502
AND ACNTS_CLOSURE_DATE is null
AND ACNTS_INTERNAL_ACNUM = ASSETCLSH_INTERNAL_ACNUM
AND ASSETCLSH_ENTITY_NUM = 1
GROUP BY ASSETCLSH_INTERNAL_ACNUM)
AND A.ASSETCLSH_ASSET_CODE <> 'UC' ;


UPDATE ASSETCLS A SET A.ASSETCLS_ASSET_CODE = 'UC', A.ASSETCLS_NPA_DATE = NULL  WHERE A.ASSETCLS_ENTITY_NUM = 1 AND (A.ASSETCLS_INTERNAL_ACNUM, A.ASSETCLS_LATEST_EFF_DATE) IN (
SELECT ASSETCLS_INTERNAL_ACNUM, MAX(ASSETCLS_LATEST_EFF_DATE) FROM ACNTS, ASSETCLS 
WHERE ACNTS_ENTITY_NUM = 1
AND ACNTS_PROD_CODE = 2502
AND ACNTS_CLOSURE_DATE is null
AND ACNTS_INTERNAL_ACNUM = ASSETCLS_INTERNAL_ACNUM
AND ASSETCLS_ENTITY_NUM = 1
GROUP BY ASSETCLS_INTERNAL_ACNUM)
AND A.ASSETCLS_ASSET_CODE <> 'UC' ;