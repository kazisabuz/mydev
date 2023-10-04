EDIT  CIFREG WHERE  CIFREG_ACC_NUM = 14818100016605;

EDIT  CIFISS  WHERE CIFISS_ACC_NUM = 14818100016605;




----------REPORT---------------

SELECT *
    FROM TABLE (PKG_ATM_REPORT.ATM_REPORT_BRANCHWISE ('',  --???????P_ISSUER_BANK
                                                      '', --???????P_ISSUER_BRANCH
                                                      '44164', --???????P_AQUERER_BRANCH
                                                      '',
                                                      '',
                                                      '',
                                                      '',
                                                      '',
                                                      '',
                                                      '',
                                                      '01-JUL-2021',
                                                      '15-aug-2021',
                                                      '',
                                                      '',
                                                      '',
                                                      '',
                                                      '',
                                                      ''))
ORDER BY RETRIEVAL_REFERENCE_NUMBER, TRANSACTION_DATE, BATCH_NUMBER