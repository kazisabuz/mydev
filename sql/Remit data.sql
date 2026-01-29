/*Report for the customer*/
SELECT CREDITACCOUNTNAME "Name of Benificiary",
NULL "Address of the beneficiary",
CBS_ACCOUNT "Beneficiary Account No.",
TO_CHAR((SELECT WM_CONCAT(PIDDOCS_PID_TYPE|| ': ' || PIDDOCS_DOCID_NUM) FROM PIDDOCS, IACLINK WHERE
IACLINK_ENTITY_NUM = 1
AND TO_CHAR( IACLINK_CIF_NUMBER) =  PIDDOCS_SOURCE_KEY 
AND IACLINK_ACTUAL_ACNUM = CBS_ACCOUNT))"NID/PP/BC No.",
EXCHANGE_NAME "Name of the Exchange House",
REFERENCE_DATE "Remittance Date",
CREDIT "Remittance Amount"    ,
INCENTIVE_AMOUNT "Bonus Amount"    ,
REFERENCE_DATE "Bonus Date",
CHANNEL_TYPE "Type of Remittance"                
FROM RMS_RECORDS
 WHERE     CBS_DATE >= '14-OCT-2019'
       AND CBS_DATE <= '30-JUN-2020'
       AND INCENTIVE_GIVEN = 1
       AND STATUS = 'BATCH_AUTHORIZED'
       AND REFERENCE_NO || '_ADJ' NOT IN (SELECT RR.REFERENCE_NO FROM RMS_RECORDS RR )
       AND REFERENCE_NO || '_ADJ2'  NOT IN (SELECT RR.REFERENCE_NO FROM RMS_RECORDS RR ) ;
	   
	   
SELECT REMCSP_BENF_NAME "Name of Benificiary",
  NULL "Address of the beneficiary",
  REMCSP_PIN "Beneficiary Account No./Ref no",
  REMCSP_ID_NUM "NID/PP/BC No.",
  (SELECT REMEXC_EXC_NAME FROM REMEXCHOUSE WHERE REMEXC_ENTITY_NUM = 1 AND REMEXC_REM_TYPE = REMCSP_CASH_TYPE AND REMEXC_EXC_CODE = REMCSP_EXCHOU_CODE ) "Name of the Exchange House",
         TO_DATE(TO_CHAR(WM_CONCAT(REM_DATE))) "Remittance Date",
         SUM (REM_AMOUNT) "Remittance Amount",
         TO_DATE(TO_CHAR(WM_CONCAT(BONUS_DATE))) "Bonus Date",
         SUM (BONUS_AMOUNT) "Bonus Date",
         'SPOT Cash' "Type of Remittance"
    FROM (SELECT REMCSP_PIN,
                 REMCSP_EXCHOU_CODE,
                 REMCSP_CASH_TYPE,
                 REMCSP_ENTRY_TYPE,
                 REMCSP_BENF_NAME,
                 REMCSP_ID_NUM,
                 CASE
                    WHEN REMCSP_ENTRY_TYPE = 'R'
                    THEN
                       TO_NUMBER (REMCSP_TRAN_AMOUNT)
                    ELSE
                       0
                 END
                    REM_AMOUNT,
                 CASE
                    WHEN REMCSP_ENTRY_TYPE = 'R'
                    THEN
                       REMCSP_REF_DATE
                    ELSE
                       NULL
                 END
                    REM_DATE,
                 CASE
                    WHEN REMCSP_ENTRY_TYPE = 'B'
                    THEN
                       TO_NUMBER (REMCSP_TRAN_AMOUNT)
                    ELSE
                       0
                 END
                    BONUS_AMOUNT,
                 CASE
                    WHEN REMCSP_ENTRY_TYPE = 'B'
                    THEN
                       REMCSP_REF_DATE
                    ELSE
                       NULL
                 END
                    BONUS_DATE
            FROM REMCASHPAY
           WHERE     REMCSP_ENTITY_NUM = 1
                 AND REMCSP_AUTH_ON IS NOT NULL
                 AND REMCSP_IS_REVERSED = 0
                 AND REMCSP_TRAN_DATE >= '14-Oct-2019'
                 AND REMCSP_TRAN_DATE <= '30-JUN-2020' 
         )
GROUP BY REMCSP_PIN,
         REMCSP_EXCHOU_CODE,
         REMCSP_CASH_TYPE,
         REMCSP_BENF_NAME,
         REMCSP_ID_NUM;