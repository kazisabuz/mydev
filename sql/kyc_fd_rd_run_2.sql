create table palash.kyc_fd as
select * from(
SELECT ACNTS_BRN_CODE,
       ACNTS_PROD_CODE,ACNTS_INTERNAL_ACNUM INTERNAL_ACNUM,
       ACNTS_CLIENT_NUM,
       FN_REP_GET_ASON_ACBAL@dr (1,
                                 ACNTS_INTERNAL_ACNUM,
                                 ACNTS_CURR_CODE,
                                 '28-FEB-2022',
                                 '2-mar-2022')
          balance
  FROM acnts@dr
 WHERE     ACNTS_PROD_CODE IN (1063,
                               1050,
                               1065,
                               1070,
                               1075,
                               1078,
                               1072,
                               1052,
                               1054
                               )
      
       AND ACNTS_CLOSURE_DATE IS NULL)
       where balance=0;
------------
create table palash.kyc_rd as
SELECT ACNTS_BRN_CODE,
       ACNTS_PROD_CODE,ACNTS_INTERNAL_ACNUM INTERNAL_ACNUM,
       facno@dr (1, ACNTS_INTERNAL_ACNUM) ACC_NUM,
       ACNTS_CLIENT_NUM,
       FN_REP_GET_ASON_ACBAL@dr (1,
                                 ACNTS_INTERNAL_ACNUM,
                                 ACNTS_CURR_CODE,
                                 '28-feb-2022',
                                 '02-mar-2022')
          balance
  FROM acnts@dr
 WHERE     ACNTS_PROD_CODE IN (1080,
                               1082,
                               1084,
                               1086,
                               1088,
                               1090,
                               1092,
                               1094,
                               1098,
                               1093)
       AND FN_REP_GET_ASON_ACBAL@dr (1,
                                     ACNTS_INTERNAL_ACNUM,
                                     ACNTS_CURR_CODE,
                                      '28-feb-2022',
                                 '02-mar-2022') = 0
       AND ACNTS_CLOSURE_DATE IS NULL;