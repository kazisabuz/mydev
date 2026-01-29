---------- Spot Cash Summary --------------

SELECT MONTH_YEAR "Month", COUNT(*) "Number of remittances" , SUM(REM_AMOUNT) "Total amount" FROM (
  SELECT REMCSP_BRN_CODE, TRIM(TO_CHAR(REMCSP_TRAN_DATE,'MONTH')) || ', ' || TO_CHAR(REMCSP_TRAN_DATE,'YYYY') MONTH_YEAR, REMCSP_PIN,REMCSP_REF_NO, REM_AMOUNT, BONUS_AMOUNT-- TO_CHAR (REMCSP_TRAN_DATE, 'MM-YYYY'), COUNT (*), SUM (REM_AMOUNT)
    FROM (  SELECT R.REMCSP_BRN_CODE,
                   (SELECT REMCSP_TRAN_DATE
                      FROM REMCASHPAY@DR RR
                     WHERE     RR.REMCSP_ENTITY_NUM = 1
                           AND RR.REMCSP_TRAN_DATE >= '01-MAR-2019'
                           AND RR.REMCSP_TRAN_DATE <= '30-APR-2020'
                           AND RR.REMCSP_IS_REVERSED = '0'
                           AND RR.REMCSP_AUTH_BY IS NOT NULL
                           AND RR.REMCSP_REJ_BY IS NULL
                           AND RR.REMCSP_BRN_CODE = R.REMCSP_BRN_CODE
                           AND RR.REMCSP_PIN = R.REMCSP_PIN
                           AND RR.REMCSP_REF_NO = R.REMCSP_REF_NO
                           AND RR.REMCSP_ENTRY_TYPE = 'R')
                      REMCSP_TRAN_DATE,
                   R.REMCSP_PIN,
                   R.REMCSP_REF_NO,
                   SUM (R.REM_AMOUNT) REM_AMOUNT,
                   SUM (R.BONUS_AMOUNT) BONUS_AMOUNT
              FROM (SELECT REMCSP_BRN_CODE,
                           REMCSP_TRAN_DATE,
                           REMCSP_TRAN_BATCH,
                           REMCSP_EXCHOU_CODE,
                           REMCSP_PIN,
                           REMCSP_REF_NO,
                           REMCSP_REF_DATE,
                           REMCSP_BENF_NAME,
                           REMCSP_SNDR_NAME,
                           REMCSP_ENTRY_TYPE,
                           CASE
                              WHEN REMCSP_ENTRY_TYPE = 'R'
                              THEN
                                 TO_NUMBER (REMCSP_TRAN_AMOUNT)
                              ELSE
                                 0
                           END
                              REM_AMOUNT,
                           CASE
                              WHEN REMCSP_ENTRY_TYPE = 'B'
                              THEN
                                 TO_NUMBER (REMCSP_TRAN_AMOUNT)
                              ELSE
                                 0
                           END
                              BONUS_AMOUNT
                      FROM REMCASHPAY@DR
                     WHERE     REMCSP_ENTITY_NUM = 1
                           AND REMCSP_TRAN_DATE >= '01-MAR-2019'
                           AND REMCSP_TRAN_DATE <= '30-APR-2020'
                           AND REMCSP_IS_REVERSED = '0'
                           AND REMCSP_AUTH_BY IS NOT NULL
                           AND REMCSP_REJ_BY IS NULL) R
          GROUP BY R.REMCSP_BRN_CODE, R.REMCSP_PIN, R.REMCSP_REF_NO
            HAVING SUM (R.REM_AMOUNT) > 500000 AND SUM (R.BONUS_AMOUNT) = 0
          ORDER BY R.REMCSP_BRN_CODE, R.REMCSP_PIN, R.REMCSP_REF_NO)) GROUP BY MONTH_YEAR
          ORDER BY 1 ;
		  
		  
------------ Spot Cash Details -----------
SELECT R.REMCSP_BRN_CODE,
       R.REMCSP_TRAN_DATE,
       R.REMCSP_TRAN_BATCH,
       R.REMCSP_EXCHOU_CODE,
       R.REMCSP_PIN,
       R.REMCSP_REF_NO,
       R.REMCSP_REF_DATE,
       R.REMCSP_BENF_NAME,
       R.REMCSP_SNDR_NAME,
       R.REMCSP_ENTRY_TYPE,
       TO_NUMBER (REMCSP_TRAN_AMOUNT) REMCSP_TRAN_AMOUNT,
       NVL((SELECT TO_NUMBER (RR.REMCSP_TRAN_AMOUNT) FROM REMCASHPAY@DR RR WHERE RR.REMCSP_ENTITY_NUM = 1
       AND RR.REMCSP_TRAN_DATE >= '01-MAR-2019'
       AND RR.REMCSP_TRAN_DATE <= '30-APR-2020'
       AND RR.REMCSP_IS_REVERSED = '0'
       AND RR.REMCSP_AUTH_BY IS NOT NULL
       AND RR.REMCSP_REJ_BY IS NULL
       AND RR.REMCSP_ENTRY_TYPE = 'B'
       AND RR.REMCSP_BRN_CODE = R.REMCSP_BRN_CODE
       AND RR.REMCSP_PIN = R.REMCSP_PIN
       AND RR.REMCSP_REF_NO = R.REMCSP_REF_NO ),0) BONUS_AMOUNT
  FROM REMCASHPAY@DR R
 WHERE     R.REMCSP_ENTITY_NUM = 1
       AND R.REMCSP_TRAN_DATE >= '01-MAR-2019'
       AND R.REMCSP_TRAN_DATE <= '30-APR-2020'
       AND R.REMCSP_IS_REVERSED = '0'
       AND R.REMCSP_AUTH_BY IS NOT NULL
       AND R.REMCSP_REJ_BY IS NULL
       AND R.REMCSP_ENTRY_TYPE = 'R'
       AND TO_NUMBER (R.REMCSP_TRAN_AMOUNT) > 500000
       AND NVL((SELECT TO_NUMBER (RR.REMCSP_TRAN_AMOUNT) FROM REMCASHPAY@DR RR WHERE RR.REMCSP_ENTITY_NUM = 1
       AND RR.REMCSP_TRAN_DATE >= '01-MAR-2019'
       AND RR.REMCSP_TRAN_DATE <= '30-APR-2020'
       AND RR.REMCSP_IS_REVERSED = '0'
       AND RR.REMCSP_AUTH_BY IS NOT NULL
       AND RR.REMCSP_REJ_BY IS NULL
       AND RR.REMCSP_ENTRY_TYPE = 'B'
       AND RR.REMCSP_BRN_CODE = R.REMCSP_BRN_CODE
       AND RR.REMCSP_PIN = R.REMCSP_PIN
       AND RR.REMCSP_REF_NO = R.REMCSP_REF_NO ),0) = 0  ;
	   
	   
--------------- EFT Summary ---------------
SELECT MONTH_YEAR, COUNT(*), SUM(CREDIT) FROM (
SELECT CBS_DATE,
TRIM(TO_CHAR(CBS_DATE,'MONTH')) || ', ' || TO_CHAR(CBS_DATE,'YYYY') MONTH_YEAR,
       RES_BRANCH_CODE,
       TRANSACTION_BATCH_NUMBER,
       EXCHANGE_CODE,
       REFERENCE_NO,
       REFERENCE_DATE,
       ACCOUNT_TITLE,
       CREDITACCOUNTNAME,
       CHANNEL_TYPE,
       CREDIT,
       INCENTIVE_AMOUNT
  FROM RMS_RECORDS@DR
 WHERE     CBS_DATE >= '01-MAR-2019'
       AND CBS_DATE <= '30-APR-2020'
       AND CREDIT > 500000
       AND INCENTIVE_GIVEN = 0
       AND STATUS = 'BATCH_AUTHORIZED'
       AND REFERENCE_NO || '_ADJ' NOT IN (SELECT RR.REFERENCE_NO FROM RMS_RECORDS@DR RR )
       AND REFERENCE_NO || '_ADJ2'  NOT IN (SELECT RR.REFERENCE_NO FROM RMS_RECORDS@DR RR ))
       GROUP BY MONTH_YEAR ;
	   
	   
---------------- EFT Details ----------------

SELECT CBS_DATE,
       RES_BRANCH_CODE,
       TRANSACTION_BATCH_NUMBER,
       EXCHANGE_CODE,
       REFERENCE_NO, 
       REFERENCE_DATE,
       ACCOUNT_TITLE,
       CREDITACCOUNTNAME,
       CHANNEL_TYPE,
       CREDIT,
       INCENTIVE_AMOUNT
  FROM RMS_RECORDS@DR
 WHERE     CBS_DATE >= '01-MAR-2019'
       AND CBS_DATE <= '30-APR-2020'
       AND CREDIT > 500000
       AND INCENTIVE_GIVEN = 0
       AND STATUS = 'BATCH_AUTHORIZED'
       AND REFERENCE_NO || '_ADJ' NOT IN (SELECT RR.REFERENCE_NO FROM RMS_RECORDS@DR RR )
       AND REFERENCE_NO || '_ADJ2'  NOT IN (SELECT RR.REFERENCE_NO FROM RMS_RECORDS@DR RR ) ;