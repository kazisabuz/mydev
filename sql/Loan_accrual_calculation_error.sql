/*Report for the accounts those had some problem in the loan interest calculation process. It was written in the development phase of loan interest process.*/
  SELECT FACNO(1,ACNT_NUM) ACNT_NUM,
         VALUE_DATE,
         AC_BAL,
         LOANIA_INT_ON_AMT,
         INT_ON_AMOUNT_SHOULD_BE,
         LOANIA_INT_RATE,
         SYSTEM_REDUCE_AMT, 
         ACTUAL_REDUCE_AMOUNT, SYSTEM_REDUCE_AMT-   ACTUAL_REDUCE_AMOUNT REDUCE_AMT_GAP,      
         CHARGES_AMT,
         LOANIA_INT_AMT_RND SYS_INT,
         ROUND ( (INT_ON_AMOUNT_SHOULD_BE * LOANIA_INT_RATE) / 36000, 2)
            ACTUAL_INT_BAL,
           LOANIA_INT_AMT_RND
         - ROUND ( (INT_ON_AMOUNT_SHOULD_BE * LOANIA_INT_RATE) / 36000, 2)
            INT_GAP
    FROM (SELECT LOANIA_ACNT_NUM ACNT_NUM,
                 LOANIA_VALUE_DATE VALUE_DATE,
                 LOANIA_ACNT_BAL AC_BAL,
                 LOANIA_INT_ON_AMT,
                 LOANIA_INT_RATE,
                 LOANIA_ACNT_BAL - LOANIA_INT_ON_AMT SYSTEM_REDUCE_AMT,
                   FN_GET_BIFURCATED_AMOUNT (LOANIA_ACNT_NUM,
                                             LOANIA_VALUE_DATE,
                                             'I')
                 + FN_GET_BIFURCATED_AMOUNT (LOANIA_ACNT_NUM,
                                             LOANIA_VALUE_DATE,
                                             'C')
                    ACTUAL_REDUCE_AMOUNT,
                   LOANIA_ACNT_BAL
                 - (  FN_GET_BIFURCATED_AMOUNT (LOANIA_ACNT_NUM,
                                                LOANIA_VALUE_DATE,
                                                'I')
                    + FN_GET_BIFURCATED_AMOUNT (LOANIA_ACNT_NUM,
                                                LOANIA_VALUE_DATE,
                                                'C'))
                    INT_ON_AMOUNT_SHOULD_BE,
                 LOANIA_INT_AMT_RND ,
                 FN_GET_BIFURCATED_AMOUNT (LOANIA_ACNT_NUM,
                                             LOANIA_VALUE_DATE,
                                             'C') CHARGES_AMT 
            FROM LOANIA, ACNTS, LNPRODPM
           WHERE     LOANIA_ENTITY_NUM = 1
                 AND LOANIA_BRN_CODE IN (33167) 
                 AND LOANIA_VALUE_DATE =
                        TO_DATE ('01/09/2018 00:00:00',
                                 'MM/DD/YYYY HH24:MI:SS')
                 AND LOANIA_ACNT_BAL - LOANIA_INT_ON_AMT <> 0
                 AND   FN_GET_BIFURCATED_AMOUNT (LOANIA_ACNT_NUM,
                                                 LOANIA_VALUE_DATE,
                                                 'I')
                     + FN_GET_BIFURCATED_AMOUNT (LOANIA_ACNT_NUM,
                                                 LOANIA_VALUE_DATE,
                                                 'C') <>
                        LOANIA_ACNT_BAL - LOANIA_INT_ON_AMT
                 AND ACNTS_ENTITY_NUM = 1
                 AND ACNTS_INTERNAL_ACNUM = LOANIA_ACNT_NUM
                 AND ACNTS_CLOSURE_DATE IS NULL
                 AND ACNTS_PROD_CODE = LNPRD_PROD_CODE
                 AND LNPRD_SIMPLE_COMP_INT = 'S')
ORDER BY ACNT_NUM, VALUE_DATE