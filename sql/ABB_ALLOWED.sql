UPDATE ACNTS
   SET ACNTS_ABB_TRAN_ALLOWED = '1'
 WHERE     ACNTS_BRN_CODE IN (SELECT BRANCH_CODE
                                FROM MIG_DETAIL
                               WHERE MIG_END_DATE = '02-NOV-2017')
       AND ACNTS_ENTD_BY = 'MIG'
       AND ACNTS_ENTITY_NUM = 1