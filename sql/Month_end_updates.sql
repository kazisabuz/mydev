/* Formatted on 3/31/2022 8:32:23 PM (QP5 v5.252.13127.32867) */
----------  1. The interest rate must be changed to 9% ( Maximum) in account level for those SOD Loan A/Cs that are opened from 01 May 2021 under SOD/OD loan product code 2008, 2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2048, 2049, 2050 & 2051. Please be noted that SOD loan accounts with interest rate less than 9% will be unchanged.


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
                 AND A.ACNTS_OPENING_DATE >=
                        (SELECT TRUNC (MN_CURR_BUSINESS_DATE, 'MM')
                           FROM MAINCONT)
                 AND A.ACNTS_PROD_CODE = LNPRD_PROD_CODE
                 AND LNPRD_INT_ACCR_FREQ = 'M'
                 AND A.ACNTS_CLOSURE_DATE IS NULL
                 AND FN_GET_LNINTRATE (1, A.ACNTS_INTERNAL_ACNUM) > 9.89)
   LOOP
      SP_LOAN_DATA_CORRECTION (1,
                               IDX.ACCOUNT_NUMBER,
                               9.89,
                               IDX.ACNTS_OPENING_DATE);
   END LOOP;
END;



--------  2. Interest rate of overdue Packing Credit loan A/Cs will be changed to 9% and re-accrue will be happen with 9% rate from effective date that is mentioned in excel file. List of overdue Packing Credit for the month of May 2021 is attached herewith in excel file.



BEGIN
   FOR IDX IN (SELECT T.ACCNUMBER ACCOUNT_NUMBER,   EFF_DATE
                 FROM ACC_TF T )
   LOOP
      SP_LOAN_DATA_CORRECTION (1,
                               IDX.ACCOUNT_NUMBER,
                               10.35,
                               IDX.EFF_DATE);
   END LOOP;
END;


UPDATE ACC_TF
   SET INTERNAL_NUMBER =
          (SELECT IACLINK_INTERNAL_ACNUM
             FROM IACLINK
            WHERE IACLINK_ENTITY_NUM = 1 AND IACLINK_ACTUAL_ACNUM = ACCNUMBER);


-------------------------------------------------------------------------------------------------

DELETE FROM LOANIADLY LL
      WHERE (LL.RTMPLNIA_BRN_CODE, LL.RTMPLNIA_ACNT_NUM) 
      IN (SELECT A.ACNTS_BRN_CODE,
                       A.ACNTS_INTERNAL_ACNUM
                  FROM ACNTS A,
                       ACC_TF T
                 WHERE     A.ACNTS_ENTITY_NUM =
                              1
                       AND A.ACNTS_INTERNAL_ACNUM =
                              T.INTERNAL_NUMBER
                       AND A.ACNTS_CLOSURE_DATE
                              IS NULL);

----------------------------------------------

UPDATE LOANACNTS
   SET LNACNT_RTMP_ACCURED_UPTO = NULL, LNACNT_RTMP_PROCESS_DATE = NULL
 WHERE     LNACNT_ENTITY_NUM = 1
       AND LNACNT_INTERNAL_ACNUM IN (SELECT A.ACNTS_INTERNAL_ACNUM
                                       FROM ACNTS A, ACC_TF T
                                      WHERE     A.ACNTS_ENTITY_NUM = 1
                                            AND A.ACNTS_INTERNAL_ACNUM =
                                                   T.INTERNAL_NUMBER
                                            AND A.ACNTS_CLOSURE_DATE IS NULL);

------------------------


-----------------  3. Please mark all short term reschedule loan as ST that are marked as reschedule from 01 May 2021 to till date (previous all ST marked account up to 30 April 2021 will be unchanged).


UPDATE ASSETCLSHIST AA
   SET ASSETCLSH_ASSET_CODE = 'ST'
 WHERE     AA.ASSETCLSH_ENTITY_NUM = 1
       AND (AA.ASSETCLSH_INTERNAL_ACNUM, AA.ASSETCLSH_EFF_DATE) 
       IN (  SELECT ASSETCLSH_INTERNAL_ACNUM,
            MAX (
               ASSETCLSH_EFF_DATE)
       FROM ASSETCLSHIST
      WHERE     ASSETCLSH_ENTITY_NUM =
                   1
            AND ASSETCLSH_INTERNAL_ACNUM IN (SELECT a.acnts_internal_acnum
                                               FROM acnts a,
                 lnprodpm lp,
                 Lnacrs lr,
                 limitline lm,
                 Acaslldtl asd,
                 assetcls
           WHERE     a.acnts_entity_num =
                        1
                 AND a.acnts_prod_code =
                        lp.lnprd_prod_code
                 AND a.acnts_closure_date
                        IS NULL
                 AND lp.lnprd_short_term_loan =
                                   '1'
                            AND lr.lnacrs_entity_num =
                                   1
                            AND lr.lnacrs_rephasement_entry =
                                   '1'
                            AND a.acnts_internal_acnum =
                                   lr.lnacrs_internal_acnum
                            AND lm.lmtline_entity_num =
                                   1
                            AND asd.acaslldtl_entity_num =
                                   1
                            AND LR.LNACRS_PURPOSE =
                                   'R'
                            AND asd.acaslldtl_internal_acnum =
                                   a.acnts_internal_acnum
                            AND lm.lmtline_client_code =
                                   asd.acaslldtl_client_num
                            AND lm.lmtline_num =
                                   asd.acaslldtl_limit_line_num
                            AND lm.LMTLINE_LIMIT_EXPIRY_DATE >=
                                   TRUNC (
                                      (SELECT MN_CURR_BUSINESS_DATE
                                         FROM MAINCONT),
                                      'MONTH')
                            AND ASSETCLS_ENTITY_NUM =
                                   1
                            AND ASSETCLS_INTERNAL_ACNUM =
                                   lr.lnacrs_internal_acnum
                            AND ASSETCLS_ASSET_CODE <>
                                   'ST')
 GROUP BY ASSETCLSH_INTERNAL_ACNUM);



UPDATE ASSETCLS
   SET ASSETCLS_ASSET_CODE = 'ST'
 WHERE     ASSETCLS_ENTITY_NUM = 1
       AND ASSETCLS_INTERNAL_ACNUM IN (SELECT a.acnts_internal_acnum
                                         FROM acnts a,
                                              lnprodpm lp,
                                              Lnacrs lr,
                                              limitline lm,
                                              Acaslldtl asd,
                                              assetcls
                                        WHERE     a.acnts_entity_num = 1
                                              AND a.acnts_prod_code =
                                                     lp.lnprd_prod_code
                                              AND a.acnts_closure_date
                                                     IS NULL
                                              AND lp.lnprd_short_term_loan =
                                                     '1'
                                              AND lr.lnacrs_entity_num = 1
                                              AND lr.lnacrs_rephasement_entry =
                                                     '1'
                                              AND a.acnts_internal_acnum =
                                                     lr.lnacrs_internal_acnum
                                              AND lm.lmtline_entity_num = 1
                                              AND asd.acaslldtl_entity_num =
                                                     1
                                              AND LR.LNACRS_PURPOSE = 'R'
                                              AND asd.acaslldtl_internal_acnum =
                                                     a.acnts_internal_acnum
                                              AND lm.lmtline_client_code =
                                                     asd.acaslldtl_client_num
                                              AND lm.lmtline_num =
                                                     asd.acaslldtl_limit_line_num
                                              AND lm.LMTLINE_LIMIT_EXPIRY_DATE >=
                                                     TRUNC (
                                                        (SELECT MN_CURR_BUSINESS_DATE
                                                           FROM MAINCONT),
                                                        'MONTH')
                                              AND ASSETCLS_ENTITY_NUM = 1
                                              AND ASSETCLS_INTERNAL_ACNUM =
                                                     lr.lnacrs_internal_acnum
                                              AND ASSETCLS_ASSET_CODE <> 'ST');


---------- Duplicate value delete from LOANIADLY table

DELETE FROM LOANIADLY
      WHERE ROWID IN (SELECT rid
                        FROM (SELECT ROWID rid,
                                     ROW_NUMBER ()
                                     OVER (
                                        PARTITION BY RTMPLNIA_ACNT_NUM,
                                                     RTMPLNIA_VALUE_DATE
                                        ORDER BY ROWID)
                                        rn
                                FROM LOANIADLY)
                       WHERE rn <> 1);

