SELECT COUNT(NUMBER_OF_TALLER),TRAN_MONTH,SUM(TOTAL_TRAN) TOTAL_TRAN,SUM(TRAN_AMOUNT)
FROM(select   DISTINCT(TRAN_ENTD_BY) NUMBER_OF_TALLER,TO_CHAR(TRAN_DATE_OF_TRAN,'MON') TRAN_MONTH,count(TRAN_CODE) TOTAL_TRAN,SUM(TRAN_AMOUNT) TRAN_AMOUNT
from tran2018
where TRAN_ENTITY_NUM=1
 AND TRAN_ENTD_BY <> 'CBSATM'
 AND TRAN_DATE_OF_TRAN <= '31-MAY-2018'
  AND TRAN_CODE IN( 'CW','CC','CW1','CWSLP')
 AND TRAN_INTERNAL_ACNUM<>0
 AND TRAN_ENTD_BY IS NOT NULL
 AND TRAN_AUTH_BY IS NOT NULL
  GROUP BY TRAN_ENTD_BY, TO_CHAR(TRAN_DATE_OF_TRAN,'MON'))
  GROUP BY TRAN_MONTH