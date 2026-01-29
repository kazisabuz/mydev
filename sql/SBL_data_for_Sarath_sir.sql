-- System statistics for the management of the organization.

-- number of accounts, -- 19,241,089
    -- LOAN    1728442
    -- FD    428744
    -- RD    449083
    -- SAVING    15802338
    -- CURRENT    832482
    
-- customers.--- 20853120

-- EoD timing, --- 1 HOUR - 1 HOUR 5 MINUTES
-- SoD timing, --- 15 MINUTES - 20 MINUTES

-- Number of transactions processed per day, --- 925228 (Based on transactions in this month(October, 2019))



SELECT COUNT(*) NUMBER_OF_PROCESS, MIN(SODEODLOG_START_DATE) ,MAX(SODEODLOG_END_DATE) , 
 FLOOR ( (MAX(SODEODLOG_END_DATE) - MIN(SODEODLOG_START_DATE)) * 24)
       || ' HOURS '
       || FLOOR (MOD ( ( ( (MAX(SODEODLOG_END_DATE) - MIN(SODEODLOG_START_DATE)) * 24) * 60), 60))
       || ' MINUTES '
       || ROUND( MOD ( (MOD ( ( ( (MAX(SODEODLOG_END_DATE) - MIN(SODEODLOG_START_DATE)) * 24) * 60), 60) * 60),60), 0)
       || ' SECONDS ' TOTAL_TIME 
FROM SODEODLOG@DR 
WHERE SODEODLOG_ENTITY_NUM = 1 
AND SODEODLOG_FLG = 'S' 
AND SODEODLOG_DATE= '28-OCT-2019';


SELECT TRAN_DATE_OF_TRAN, COUNT(*)
 FROM TRAN2019@DR 
WHERE TRAN_ENTITY_NUM = 1 
AND TRAN_DATE_OF_TRAN BETWEEN '01-OCT-2019' AND '27-OCT-2019'
AND TO_CHAR(TRAN_DATE_OF_TRAN,'DY') NOT IN ('FRI', 'SAT')
GROUP BY TRAN_DATE_OF_TRAN ;


SELECT TO_CHAR(SYSDATE,'DY') FROM DUAL  ;


SELECT COUNT(*) FROM CLIENTS@DR ;




SELECT PRODUCTCATEGORY, COUNT(*) FROM (
SELECT ACNTS_INTERNAL_ACNUM,
       ACNTS_PROD_CODE,
       CASE
          WHEN PRODUCT_FOR_DEPOSITS = '1'
          THEN
             CASE
                WHEN PRODUCT_FOR_RUN_ACS = '1'
                THEN
                   CASE WHEN PRODUCT_CODE = 1020 THEN 'CURRENT' ELSE 'SAVING' END
                ELSE
                   CASE
                      WHEN PRODUCT_CONTRACT_ALLOWED = '1' THEN 'FD'
                      ELSE 'RD'
                   END
             END
          ELSE
             'LOAN'
       END
          PRODUCTCATEGORY
  FROM ACNTS@DR, PRODUCTS@DR
 WHERE ACNTS_ENTITY_NUM = 1 AND ACNTS_PROD_CODE = PRODUCT_CODE
 --AND ACNTS_BRN_CODE = 26
 AND ACNTS_CLOSURE_DATE IS NULL 
 ORDER BY ACNTS_INTERNAL_ACNUM
 ) 
 GROUP BY PRODUCTCATEGORY