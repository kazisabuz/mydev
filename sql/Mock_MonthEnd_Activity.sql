/*There are few updats those are necessary before every monthend. So, before running a monthend, we need to run the updates in the production.*/
-------- 1. Common Update ----------


DELETE FROM LOANIADLY
      WHERE ROWID IN (
               SELECT rid
                 FROM (SELECT ROWID rid,
                              ROW_NUMBER () OVER (PARTITION BY  RTMPLNIA_ACNT_NUM,
                       RTMPLNIA_VALUE_DATE ORDER BY ROWID) rn
                         FROM LOANIADLY)
                WHERE rn <> 1);


BEGIN
   FOR idx
      IN (  SELECT LNACNT_INTERNAL_ACNUM,
                   LNACNT_RTMP_ACCURED_UPTO,
                   LOANIADLY_TABLE.RTMPLNIA_VALUE_DATE
              FROM LOANACNTS,
                   (  SELECT RTMPLNIA_ACNT_NUM,
                             MAX (RTMPLNIA_VALUE_DATE) RTMPLNIA_VALUE_DATE
                        FROM loaniadly
                    GROUP BY RTMPLNIA_ACNT_NUM) LOANIADLY_TABLE
             WHERE     LNACNT_ENTITY_NUM = 1
                   AND LNACNT_INTERNAL_ACNUM =
                          LOANIADLY_TABLE.RTMPLNIA_ACNT_NUM
                   AND LNACNT_RTMP_ACCURED_UPTO <
                          LOANIADLY_TABLE.RTMPLNIA_VALUE_DATE
          ORDER BY LNACNT_INTERNAL_ACNUM)
   LOOP
      UPDATE loanacnts
         SET LNACNT_RTMP_ACCURED_UPTO = idx.RTMPLNIA_VALUE_DATE,
             LNACNT_RTMP_PROCESS_DATE = idx.RTMPLNIA_VALUE_DATE
       WHERE     LNACNT_ENTITY_NUM = 1
             AND LNACNT_INTERNAL_ACNUM = idx.LNACNT_INTERNAL_ACNUM;
   END LOOP;
END;

-----------2. Short Term Reschedule -----------

UPDATE ASSETCLSHIST AA
   SET ASSETCLSH_ASSET_CODE = 'ST'
 WHERE     AA.ASSETCLSH_ENTITY_NUM = 1
       AND (AA.ASSETCLSH_INTERNAL_ACNUM, AA.ASSETCLSH_EFF_DATE) IN
              (  SELECT ASSETCLSH_INTERNAL_ACNUM, MAX (ASSETCLSH_EFF_DATE)
                   FROM ASSETCLSHIST
                  WHERE     ASSETCLSH_ENTITY_NUM = 1
                        AND ASSETCLSH_INTERNAL_ACNUM IN
                               (SELECT a.acnts_internal_acnum
                                  FROM acnts a,
                                       lnprodpm lp,
                                       Lnacrs lr,
                                       limitline lm,
                                       Acaslldtl asd,
                                       assetcls
                                 WHERE     a.acnts_entity_num = 1
                                       AND a.acnts_prod_code =
                                              lp.lnprd_prod_code
                                       AND a.acnts_closure_date IS NULL
                                       AND lp.lnprd_short_term_loan = '1'
                                       AND lr.lnacrs_entity_num = 1
                                       AND lr.lnacrs_rephasement_entry = '1'
                                       AND a.acnts_internal_acnum =
                                              lr.lnacrs_internal_acnum
                                       AND lm.lmtline_entity_num = 1
                                       AND asd.acaslldtl_entity_num = 1
                                       AND LR.LNACRS_PURPOSE = 'R'
                                       AND asd.acaslldtl_internal_acnum =
                                              a.acnts_internal_acnum
                                       AND lm.lmtline_client_code =
                                              asd.acaslldtl_client_num
                                       AND lm.lmtline_num =
                                              asd.acaslldtl_limit_line_num
                                       AND lr.lnacrs_latest_eff_date>= TRUNC((SELECT MN_CURR_BUSINESS_DATE FROM MAINCONT), 'MONTH')
                                       AND ASSETCLS_ENTITY_NUM = 1
                                       AND ASSETCLS_INTERNAL_ACNUM =
                                              lr.lnacrs_internal_acnum
                                       AND ASSETCLS_ASSET_CODE <> 'ST')
               GROUP BY ASSETCLSH_INTERNAL_ACNUM) ;
               
               
               
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
                      assetcls
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
                      AND lr.lnacrs_latest_eff_date>= TRUNC((SELECT MN_CURR_BUSINESS_DATE FROM MAINCONT), 'MONTH')
                      AND ASSETCLS_ENTITY_NUM = 1
                      AND ASSETCLS_INTERNAL_ACNUM = lr.lnacrs_internal_acnum
                      AND ASSETCLS_ASSET_CODE <> 'ST') ;
            
            
            
UPDATE ASSETCLSHIST
   SET ASSETCLSH_ASSET_CODE = 'UC'
 WHERE     ASSETCLSH_ENTITY_NUM = 1
       AND (ASSETCLSH_INTERNAL_ACNUM, ASSETCLSH_EFF_DATE) IN
              (SELECT ASSETCLS_INTERNAL_ACNUM, ASSETCLS_LATEST_EFF_DATE
                 FROM ASSETCLS
                WHERE     ASSETCLS_ENTITY_NUM = 1
                      AND ASSETCLS_INTERNAL_ACNUM IN
                             (SELECT ACNTS_INTERNAL_ACNUM
                                FROM ACNTS
                               WHERE     ACNTS_ENTITY_NUM = 1
                                     AND ACNTS_PROD_CODE = 2502
                                     AND ACNTS_CLOSURE_DATE IS NULL)
                      AND ASSETCLS_ASSET_CODE <> 'UC');

UPDATE ASSETCLS
   SET ASSETCLS_ASSET_CODE = 'UC'
 WHERE     ASSETCLS_ENTITY_NUM = 1
       AND ASSETCLS_INTERNAL_ACNUM IN
              (SELECT ACNTS_INTERNAL_ACNUM
                 FROM ACNTS
                WHERE     ACNTS_ENTITY_NUM = 1
                      AND ACNTS_PROD_CODE = 2502
                      AND ACNTS_CLOSURE_DATE IS NULL)
       AND ASSETCLS_ASSET_CODE <> 'UC';
	   
	   
	   
	   
-------------- 3. SOD Loan --------------------
BEGIN
   FOR IDX
      IN (SELECT FACNO (1, A.ACNTS_INTERNAL_ACNUM) ACCOUNT_NUMBER,
                 A.ACNTS_BRN_CODE,
                 ACNTS_OPENING_DATE,
                 FN_GET_LNINTRATE (1, A.ACNTS_INTERNAL_ACNUM)
                    INT_RATE_FROM_FN
            FROM ACNTS A, LOANACNTS L, LNPRODPM 
           WHERE     A.ACNTS_ENTITY_NUM = 1
                 AND L.LNACNT_ENTITY_NUM = 1
                 AND A.ACNTS_INTERNAL_ACNUM = L.LNACNT_INTERNAL_ACNUM
                 AND A.ACNTS_OPENING_DATE >= ( SELECT TRUNC(MN_CURR_BUSINESS_DATE, 'MM') FROM MAINCONT )
                 AND A.ACNTS_PROD_CODE = LNPRD_PROD_CODE
                 AND LNPRD_INT_ACCR_FREQ = 'M'
                 AND A.ACNTS_CLOSURE_DATE IS NULL
                 AND FN_GET_LNINTRATE (1, A.ACNTS_INTERNAL_ACNUM) > 9)
   LOOP
      SP_LOAN_DATA_CORRECTION (1,
                               IDX.ACCOUNT_NUMBER,
                               9.00,
                               IDX.ACNTS_OPENING_DATE);
   END LOOP;
END;






