INSERT INTO MV_LOAN_ACCOUNT_BAL_OD
SELECT /*+PARALLEL(16) */
       2017 VALUE_YEAR,
       TRAN_INTERNAL_ACNUM,
       TRANADV_INTRD_BC_AMT,
       TRANADV_CHARGE_BC_AMT,
       TRAN_DB_CR_FLG,
       TRAN_DATE_OF_TRAN
  FROM LOANACNTS L,
       ACNTS A,
       TRANADV2017 T,
       TRAN2017 TR
 WHERE     TR.TRAN_ENTITY_NUM = A.ACNTS_ENTITY_NUM
       AND TRANADV_ENTITY_NUM = A.ACNTS_ENTITY_NUM
       AND TRANADV_BRN_CODE = TRAN_BRN_CODE
       AND TRAN_DATE_OF_TRAN = TRANADV_DATE_OF_TRAN
       AND TRANADV_BATCH_NUMBER = TRAN_BATCH_NUMBER
       AND TRANADV_BATCH_SL_NUM = TRAN_BATCH_SL_NUM
       AND L.LNACNT_INTERNAL_ACNUM = TR.TRAN_INTERNAL_ACNUM
       AND L.LNACNT_INTERNAL_ACNUM = A.ACNTS_INTERNAL_ACNUM
       AND A.ACNTS_INTERNAL_ACNUM = TR.TRAN_INTERNAL_ACNUM
       AND TRAN_AUTH_ON IS NOT NULL
       and tr.tran_entd_by = 'MIG'
       AND (TRANADV_INTRD_BC_AMT <> 0 OR TRANADV_CHARGE_BC_AMT <> 0) 
