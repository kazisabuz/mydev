/* Formatted on 2/25/2019 3:36:49 PM (QP5 v5.227.12220.39754) */
SELECT /*+ PARALLEL(8) */ (SELECT /*+ PARALLEL(6) */ COUNT (ACNTS_INTERNAL_ACNUM)
          FROM ACNTS, CLIENTS
         WHERE     ACNTS_ENTITY_NUM = 1
               AND ACNTS_CLIENT_NUM = CLIENTS_CODE
               AND CLIENTS_TYPE_FLG <> 'C'
               --AND ACNTS_CURR_CODE='BDT'
               AND ACNTS_PROD_CODE = 1020
               AND (   ACNTS_OPENING_DATE <= '31-DEC-2016'
                    OR ACNTS_CLOSURE_DATE >= '31-DEC-2016'))
          IND_2016,
       (SELECT /*+ PARALLEL(6) */ COUNT (ACNTS_INTERNAL_ACNUM)
          FROM ACNTS, CLIENTS
         WHERE     ACNTS_ENTITY_NUM = 1
               AND ACNTS_CLIENT_NUM = CLIENTS_CODE
               AND CLIENTS_TYPE_FLG <> 'C'
               AND ACNTS_PROD_CODE = 1020
               --AND ACNTS_CURR_CODE='BDT'
               AND (   ACNTS_OPENING_DATE <= '31-DEC-2017'
                    OR ACNTS_CLOSURE_DATE >= '31-DEC-2017'))
          IND_2017,
       (SELECT /*+ PARALLEL(6) */ COUNT (ACNTS_INTERNAL_ACNUM)
          FROM ACNTS, CLIENTS
         WHERE     ACNTS_ENTITY_NUM = 1
               AND ACNTS_CLIENT_NUM = CLIENTS_CODE
               AND CLIENTS_TYPE_FLG <> 'C'
               AND ACNTS_PROD_CODE = 1020
             --  AND ACNTS_CURR_CODE='BDT'
               AND (   ACNTS_OPENING_DATE <= '31-DEC-2018'
                    OR ACNTS_CLOSURE_DATE >= '31-DEC-2018'))
          IND_2018,
       (SELECT /*+ PARALLEL(6) */ COUNT (ACNTS_INTERNAL_ACNUM)
          FROM ACNTS, CLIENTS
         WHERE     ACNTS_ENTITY_NUM = 1
               AND ACNTS_CLIENT_NUM = CLIENTS_CODE
               AND CLIENTS_TYPE_FLG = 'C'
               AND ACNTS_PROD_CODE = 1020
              -- AND ACNTS_CURR_CODE='BDT'
               AND (   ACNTS_OPENING_DATE <= '31-DEC-2016'
                    OR ACNTS_CLOSURE_DATE >= '31-DEC-2016'))
          CORP_2016,
       (SELECT /*+ PARALLEL(6) */ COUNT (ACNTS_INTERNAL_ACNUM)
          FROM ACNTS, CLIENTS
         WHERE     ACNTS_ENTITY_NUM = 1
               AND ACNTS_CLIENT_NUM = CLIENTS_CODE
               AND CLIENTS_TYPE_FLG = 'C'
               AND ACNTS_PROD_CODE = 1020
               --AND ACNTS_CURR_CODE='BDT'
               AND (   ACNTS_OPENING_DATE <= '31-DEC-2017'
                    OR ACNTS_CLOSURE_DATE >= '31-DEC-2017'))
          CORP_2017,
       (SELECT /*+ PARALLEL(6) */ COUNT (ACNTS_INTERNAL_ACNUM)
          FROM ACNTS, CLIENTS
         WHERE     ACNTS_ENTITY_NUM = 1
               AND ACNTS_CLIENT_NUM = CLIENTS_CODE
               AND CLIENTS_TYPE_FLG = 'C'
               AND ACNTS_PROD_CODE = 1020
               AND (   ACNTS_OPENING_DATE <= '31-DEC-2018'
                    OR ACNTS_CLOSURE_DATE >= '31-DEC-2018'))
          CORP_2018,
       (  SELECT /*+ PARALLEL(6) */
                COUNT (DISTINCT (TRAN_BATCH_NUMBER))
            FROM TRAN2016, ACNTS, CLIENTS
           WHERE     TRAN_ENTITY_NUM = 1
                 AND TRAN_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                 AND ACNTS_CLIENT_NUM = CLIENTS_CODE
                 AND CLIENTS_TYPE_FLG <> 'C'
                 AND ACNTS_ENTITY_NUM = 1
                 AND TRAN_INTERNAL_ACNUM <> 0
                 AND ACNTS_PROD_CODE = 1020
                 AND TRAN_DATE_OF_TRAN BETWEEN '01-dec-2016' AND '31-dec-2016'
        GROUP BY TO_CHAR (TRAN_DATE_OF_TRAN, 'MON')
          HAVING COUNT (*) >= 1)
          MON_TRAN_2016_IND,
       (  SELECT /*+ PARALLEL(6) */
                COUNT (DISTINCT (TRAN_BATCH_NUMBER))
            FROM TRAN2017, ACNTS, CLIENTS
           WHERE     TRAN_ENTITY_NUM = 1
                 AND TRAN_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                 AND ACNTS_CLIENT_NUM = CLIENTS_CODE
                 AND CLIENTS_TYPE_FLG <> 'C'
                 AND ACNTS_ENTITY_NUM = 1
                 AND TRAN_INTERNAL_ACNUM <> 0
                 AND ACNTS_PROD_CODE = 1020
                 AND TRAN_DATE_OF_TRAN BETWEEN '01-dec-2017' AND '31-dec-2017'
        GROUP BY TO_CHAR (TRAN_DATE_OF_TRAN, 'MON')
          HAVING COUNT (*) >= 1)
          MON_TRAN_2017_IND,
       (  SELECT /*+ PARALLEL(6) */
                COUNT (DISTINCT (TRAN_BATCH_NUMBER))
            FROM TRAN2018, ACNTS, CLIENTS
           WHERE     TRAN_ENTITY_NUM = 1
                 AND TRAN_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                 AND ACNTS_CLIENT_NUM = CLIENTS_CODE
                 AND CLIENTS_TYPE_FLG <> 'C'
                 AND ACNTS_ENTITY_NUM = 1
                 AND TRAN_INTERNAL_ACNUM <> 0
                 AND ACNTS_PROD_CODE = 1020
                 AND TRAN_DATE_OF_TRAN BETWEEN '01-dec-2018' AND '31-dec-2018'
        GROUP BY TO_CHAR (TRAN_DATE_OF_TRAN, 'MON')
          HAVING COUNT (*) >= 1)
          MON_TRAN_2018_IND,
          ----
          (  SELECT /*+ PARALLEL(6) */
                COUNT (DISTINCT (TRAN_BATCH_NUMBER))
            FROM TRAN2016, ACNTS, CLIENTS
           WHERE     TRAN_ENTITY_NUM = 1
                 AND TRAN_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                 AND ACNTS_CLIENT_NUM = CLIENTS_CODE
                 AND CLIENTS_TYPE_FLG = 'C'
                 AND ACNTS_ENTITY_NUM = 1
                 AND TRAN_INTERNAL_ACNUM <> 0
                 AND ACNTS_PROD_CODE = 1020
                 AND TRAN_DATE_OF_TRAN BETWEEN '01-dec-2016' AND '31-dec-2016'
        GROUP BY TO_CHAR (TRAN_DATE_OF_TRAN, 'MON')
          HAVING COUNT (*) >= 1)
          MON_TRAN_2016_CORP,
       (  SELECT /*+ PARALLEL(6) */
                COUNT (DISTINCT (TRAN_BATCH_NUMBER))
            FROM TRAN2017, ACNTS, CLIENTS
           WHERE     TRAN_ENTITY_NUM = 1
                 AND TRAN_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                 AND ACNTS_CLIENT_NUM = CLIENTS_CODE
                 AND CLIENTS_TYPE_FLG = 'C'
                 AND ACNTS_ENTITY_NUM = 1
                 AND TRAN_INTERNAL_ACNUM <> 0
                 AND ACNTS_PROD_CODE = 1020
                 AND TRAN_DATE_OF_TRAN BETWEEN '01-dec-2017' AND '31-dec-2017'
        GROUP BY TO_CHAR (TRAN_DATE_OF_TRAN, 'MON')
          HAVING COUNT (*) >= 1)
          MON_TRAN_2017_CORP,
       (  SELECT /*+ PARALLEL(6) */
                COUNT (DISTINCT (TRAN_BATCH_NUMBER))
            FROM TRAN2018, ACNTS, CLIENTS
           WHERE     TRAN_ENTITY_NUM = 1
                 AND TRAN_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                 AND ACNTS_CLIENT_NUM = CLIENTS_CODE
                 AND CLIENTS_TYPE_FLG = 'C'
                 AND ACNTS_ENTITY_NUM = 1
                 AND TRAN_INTERNAL_ACNUM <> 0
                 AND ACNTS_PROD_CODE = 1020
                 AND TRAN_DATE_OF_TRAN BETWEEN '01-dec-2018' AND '31-dec-2018'
        GROUP BY TO_CHAR (TRAN_DATE_OF_TRAN, 'MON')
          HAVING COUNT (*) >= 1)
          MON_TRAN_2018_CORP,

       (SELECT /*+ PARALLEL(6) */
              COUNT (ACNTS_INTERNAL_ACNUM)
          FROM ACNTS, CLIENTS
         WHERE     ACNTS_ENTITY_NUM = 1
               AND ACNTS_CLIENT_NUM = CLIENTS_CODE
               AND CLIENTS_TYPE_FLG <> 'C'
               AND ACNTS_PROD_CODE = 1020
               AND (FN_BIS_GET_ASON_ACBAL (ACNTS_ENTITY_NUM,
                                           ACNTS_INTERNAL_ACNUM,
                                           'BDT',
                                           '29-dec-2016',
                                           '25-feb-2019')) > 0)
          ACC_WITH_BAL_IND_2016,
       (SELECT /*+ PARALLEL(6) */
              COUNT (ACNTS_INTERNAL_ACNUM)
          FROM ACNTS, CLIENTS
         WHERE     ACNTS_ENTITY_NUM = 1
               AND ACNTS_CLIENT_NUM = CLIENTS_CODE
               AND CLIENTS_TYPE_FLG <> 'C'
               AND ACNTS_PROD_CODE = 1020
               AND (FN_BIS_GET_ASON_ACBAL (ACNTS_ENTITY_NUM,
                                           ACNTS_INTERNAL_ACNUM,
                                           'BDT',
                                           '28-dec-2017',
                                           '25-feb-2019')) > 0)
          ACC_WITH_BAL_IND_2017,
       (SELECT /*+ PARALLEL(6) */
              COUNT (ACNTS_INTERNAL_ACNUM)
          FROM ACNTS, CLIENTS
         WHERE     ACNTS_ENTITY_NUM = 1
               AND ACNTS_CLIENT_NUM = CLIENTS_CODE
               AND CLIENTS_TYPE_FLG <> 'C'
               AND ACNTS_PROD_CODE = 1020
               AND (FN_BIS_GET_ASON_ACBAL (ACNTS_ENTITY_NUM,
                                           ACNTS_INTERNAL_ACNUM,
                                           'BDT',
                                           '27-dec-2018',
                                           '25-feb-2019')) > 0)
          ACC_WITH_BAL_IND_2018,
          
          
       (SELECT /*+ PARALLEL(6) */
              COUNT (ACNTS_INTERNAL_ACNUM)
          FROM ACNTS, CLIENTS
         WHERE     ACNTS_ENTITY_NUM = 1
               AND ACNTS_CLIENT_NUM = CLIENTS_CODE
               AND CLIENTS_TYPE_FLG = 'C'
               AND ACNTS_PROD_CODE = 1020
               AND (FN_BIS_GET_ASON_ACBAL (ACNTS_ENTITY_NUM,
                                           ACNTS_INTERNAL_ACNUM,
                                           'BDT',
                                           '29-dec-2016',
                                           '25-feb-2019')) > 0)
          ACC_WITH_BAL_CORP_2016,
       (SELECT /*+ PARALLEL(6) */
              COUNT (ACNTS_INTERNAL_ACNUM)
          FROM ACNTS, CLIENTS
         WHERE     ACNTS_ENTITY_NUM = 1
               AND ACNTS_CLIENT_NUM = CLIENTS_CODE
               AND CLIENTS_TYPE_FLG = 'C'
               AND ACNTS_PROD_CODE = 1020
               AND (FN_BIS_GET_ASON_ACBAL (ACNTS_ENTITY_NUM,
                                           ACNTS_INTERNAL_ACNUM,
                                           'BDT',
                                           '28-dec-2017',
                                           '25-feb-2019')) > 0)
          ACC_WITH_BAL_CORP_2017,
       (SELECT /*+ PARALLEL(6) */
              COUNT (ACNTS_INTERNAL_ACNUM)
          FROM ACNTS, CLIENTS
         WHERE     ACNTS_ENTITY_NUM = 1
               AND ACNTS_CLIENT_NUM = CLIENTS_CODE
               AND CLIENTS_TYPE_FLG = 'C'
               AND ACNTS_PROD_CODE = 1020
               AND (FN_BIS_GET_ASON_ACBAL (ACNTS_ENTITY_NUM,
                                           ACNTS_INTERNAL_ACNUM,
                                           'BDT',
                                           '27-dec-2018',
                                           '25-feb-2019')) > 0)
          ACC_WITH_BAL_CORP_2018,
          
          (SELECT /*+ PARALLEL(6) */ COUNT (ACNTS_INTERNAL_ACNUM)
          FROM ACNTS, CLIENTS
         WHERE     ACNTS_ENTITY_NUM = 1
               AND ACNTS_CLIENT_NUM = CLIENTS_CODE
               AND CLIENTS_TYPE_FLG <> 'C'
                AND ACNTS_CURR_CODE<>'BDT'
               ---AND ACNTS_PROD_CODE = 1020
               AND (   ACNTS_OPENING_DATE <= '31-DEC-2016'
                    OR ACNTS_CLOSURE_DATE >= '31-DEC-2016'))
          FOR_ACC_IND_2016,
       (SELECT /*+ PARALLEL(6) */ COUNT (ACNTS_INTERNAL_ACNUM)
          FROM ACNTS, CLIENTS
         WHERE     ACNTS_ENTITY_NUM = 1
               AND ACNTS_CLIENT_NUM = CLIENTS_CODE
               AND CLIENTS_TYPE_FLG <> 'C'
                AND ACNTS_CURR_CODE<>'BDT'
               -- AND ACNTS_PROD_CODE = 1020
               AND (   ACNTS_OPENING_DATE <= '31-DEC-2017'
                    OR ACNTS_CLOSURE_DATE >= '31-DEC-2017'))
          FOR_ACC_IND_2017,
       (SELECT /*+ PARALLEL(6) */ COUNT (ACNTS_INTERNAL_ACNUM)
          FROM ACNTS, CLIENTS
         WHERE     ACNTS_ENTITY_NUM = 1
               AND ACNTS_CLIENT_NUM = CLIENTS_CODE
               AND CLIENTS_TYPE_FLG <> 'C'
               AND ACNTS_CURR_CODE<>'BDT'
               --AND ACNTS_PROD_CODE = 1020
               AND (   ACNTS_OPENING_DATE <= '31-DEC-2018'
                    OR ACNTS_CLOSURE_DATE >= '31-DEC-2018'))
          FOR_ACC_IND_2018,
       (SELECT /*+ PARALLEL(6) */ COUNT (ACNTS_INTERNAL_ACNUM)
          FROM ACNTS, CLIENTS
         WHERE     ACNTS_ENTITY_NUM = 1
               AND ACNTS_CLIENT_NUM = CLIENTS_CODE
               AND CLIENTS_TYPE_FLG = 'C'
                AND ACNTS_CURR_CODE<>'BDT'
               -- AND ACNTS_PROD_CODE = 1020
               AND (   ACNTS_OPENING_DATE <= '31-DEC-2016'
                    OR ACNTS_CLOSURE_DATE >= '31-DEC-2016'))
          FOR_ACC_CORP_2016,
       (SELECT /*+ PARALLEL(6) */ COUNT (ACNTS_INTERNAL_ACNUM)
          FROM ACNTS, CLIENTS
         WHERE     ACNTS_ENTITY_NUM = 1
               AND ACNTS_CLIENT_NUM = CLIENTS_CODE
               AND CLIENTS_TYPE_FLG = 'C'
                AND ACNTS_CURR_CODE<>'BDT'
                AND ACNTS_PROD_CODE = 1020
               AND (   ACNTS_OPENING_DATE <= '31-DEC-2017'
                    OR ACNTS_CLOSURE_DATE >= '31-DEC-2017'))
          FOR_ACC_CORP_2017,
       (SELECT /*+ PARALLEL(6) */ COUNT (ACNTS_INTERNAL_ACNUM)
          FROM ACNTS, CLIENTS
         WHERE     ACNTS_ENTITY_NUM = 1
               AND ACNTS_CLIENT_NUM = CLIENTS_CODE
               AND CLIENTS_TYPE_FLG = 'C'
               AND ACNTS_CURR_CODE<>'BDT'
               AND ACNTS_PROD_CODE = 1020
               AND (   ACNTS_OPENING_DATE <= '31-DEC-2018'
                    OR ACNTS_CLOSURE_DATE >= '31-DEC-2018'))
          FOR_ACC_CORP_2018,
     (SELECT /*+ PARALLEL(6) */ SUM (TRAN_AMOUNT)
          FROM TRAN2016
         WHERE     TRAN_ENTITY_NUM = 1
               AND TRAN_DATE_OF_TRAN = '29-dec-2016'
               AND TRAN_CODE IN ('CW', 'CWSLP', 'CW1', 'CC'))
          CASH_WIDRAW_2016,
       (SELECT /*+ PARALLEL(6) */ SUM (TRAN_AMOUNT)
          FROM TRAN2017
         WHERE     TRAN_ENTITY_NUM = 1
               AND TRAN_DATE_OF_TRAN = '28-dec-2017'
               AND TRAN_CODE IN ('CW', 'CWSLP', 'CW1', 'CC'))
          CASH_WIDRAW_2017,
       (SELECT /*+ PARALLEL(6) */ SUM (TRAN_AMOUNT)
          FROM TRAN2018
         WHERE     TRAN_ENTITY_NUM = 1
               AND TRAN_DATE_OF_TRAN = '27-dec-2018'
               AND TRAN_CODE IN ('CW', 'CWSLP', 'CW1', 'CC'))
          CASH_WIDRAW_2018,
       (SELECT /*+ PARALLEL(6) */ SUM (TRAN_AMOUNT)
          FROM TRAN2016
         WHERE     TRAN_ENTITY_NUM = 1
               AND TRAN_DATE_OF_TRAN = '29-dec-2016'
               AND TRAN_CODE IN ('CD'))
          CASH_DEPOSIT_2016,
       (SELECT /*+ PARALLEL(6) */ SUM (TRAN_AMOUNT)
          FROM TRAN2017
         WHERE     TRAN_ENTITY_NUM = 1
               AND TRAN_DATE_OF_TRAN = '28-dec-2017'
               AND TRAN_CODE IN ('CD'))
          CASH_DEPOSIT_2017,
       (SELECT /*+ PARALLEL(6) */ SUM (TRAN_AMOUNT)
          FROM TRAN2018
         WHERE     TRAN_ENTITY_NUM = 1
               AND TRAN_DATE_OF_TRAN = '27-dec-2018'
               AND TRAN_CODE IN ('CD'))
          CASH_DEPOSIT_2018
          
          ----------------------------------
 /* Formatted on 2/27/2019 2:40:14 PM (QP5 v5.227.12220.39754) */
SELECT (SELECT /*+ PARALLEL(6) */
              SUM (TRAN_AMOUNT)
          FROM TRAN2016
         WHERE     TRAN_ENTITY_NUM = 1
               AND TRAN_DATE_OF_TRAN = '29-dec-2016'
               AND TRAN_CODE = 'TD'
               AND TRAN_BRN_CODE <> TRAN_ACING_BRN_CODE)
          INTER_BRANCH_DEBIT_2016,
       (SELECT /*+ PARALLEL(6) */
              SUM (TRAN_AMOUNT)
          FROM TRAN2017
         WHERE     TRAN_ENTITY_NUM = 1
               AND TRAN_DATE_OF_TRAN = '28-dec-2017'
               AND TRAN_CODE = 'TD'
               AND TRAN_BRN_CODE <> TRAN_ACING_BRN_CODE)
          INTER_BRANCH_DEBIT_2017,
       (SELECT /*+ PARALLEL(6) */
              SUM (TRAN_AMOUNT)
          FROM TRAN2018
         WHERE     TRAN_ENTITY_NUM = 1
               AND TRAN_DATE_OF_TRAN = '27-dec-2018'
               AND TRAN_CODE = 'TD'
               AND TRAN_BRN_CODE <> TRAN_ACING_BRN_CODE)
          INTER_BRANCH_DEBIT_2018,
       (SELECT /*+ PARALLEL(6) */
              SUM (TRAN_AMOUNT)
          FROM TRAN2016
         WHERE     TRAN_ENTITY_NUM = 1
               AND TRAN_DATE_OF_TRAN = '29-dec-2016'
               AND TRAN_CODE = 'TC'
               AND TRAN_BRN_CODE <> TRAN_ACING_BRN_CODE)
          INTER_BRANCH_CREDIT_2016,
       (SELECT /*+ PARALLEL(6) */
              SUM (TRAN_AMOUNT)
          FROM TRAN2017
         WHERE     TRAN_ENTITY_NUM = 1
               AND TRAN_DATE_OF_TRAN = '28-dec-2017'
               AND TRAN_CODE = 'TC'
               AND TRAN_BRN_CODE <> TRAN_ACING_BRN_CODE)
          INTER_BRANCH_CREDIT_2017,
       (SELECT /*+ PARALLEL(6) */
              SUM (TRAN_AMOUNT)
          FROM TRAN2018
         WHERE     TRAN_ENTITY_NUM = 1
               AND TRAN_DATE_OF_TRAN = '27-dec-2018'
               AND TRAN_CODE = 'TC'
               AND TRAN_BRN_CODE <> TRAN_ACING_BRN_CODE)
          INTER_BRANCH_CREDIT_2018,
           (SELECT /*+ PARALLEL(6) */
              COUNT (DISTINCT (TRAN_BATCH_NUMBER))
          FROM TRAN2016
         WHERE     TRAN_ENTITY_NUM = 1
               AND TRAN_DATE_OF_TRAN = '29-dec-2016'
               AND TRAN_CODE = 'TD'
               AND TRAN_BRN_CODE <> TRAN_ACING_BRN_CODE)
          INTER_BRANCH_DEBIT_NOTRAN_2016,
       (SELECT /*+ PARALLEL(6) */
              COUNT (DISTINCT (TRAN_BATCH_NUMBER))
          FROM TRAN2017
         WHERE     TRAN_ENTITY_NUM = 1
               AND TRAN_DATE_OF_TRAN = '28-dec-2017'
               AND TRAN_CODE = 'TD'
               AND TRAN_BRN_CODE <> TRAN_ACING_BRN_CODE)
          INTER_BRANCH_DEBIT_NOTRAN2017,
       (SELECT /*+ PARALLEL(6) */
              COUNT (DISTINCT (TRAN_BATCH_NUMBER))
          FROM TRAN2018
         WHERE     TRAN_ENTITY_NUM = 1
               AND TRAN_DATE_OF_TRAN = '27-dec-2018'
               AND TRAN_CODE = 'TD'
               AND TRAN_BRN_CODE <> TRAN_ACING_BRN_CODE)
          INTER_BRANCH_DEBIT_NOTRAN2018,
       (SELECT /*+ PARALLEL(6) */
             COUNT (DISTINCT (TRAN_BATCH_NUMBER))
          FROM TRAN2016
         WHERE     TRAN_ENTITY_NUM = 1
               AND TRAN_DATE_OF_TRAN = '29-dec-2016'
               AND TRAN_CODE = 'TC'
               AND TRAN_BRN_CODE <> TRAN_ACING_BRN_CODE)
          INTER_BRANCH_CREDIT_NOTRAN2016,
       (SELECT /*+ PARALLEL(6) */
            COUNT (DISTINCT (TRAN_BATCH_NUMBER))
          FROM TRAN2017
         WHERE     TRAN_ENTITY_NUM = 1
               AND TRAN_DATE_OF_TRAN = '28-dec-2017'
               AND TRAN_CODE = 'TC'
               AND TRAN_BRN_CODE <> TRAN_ACING_BRN_CODE)
          INTER_BRANCH_CREDIT_NOTRAN2017,
       (SELECT /*+ PARALLEL(6) */
             COUNT (DISTINCT (TRAN_BATCH_NUMBER))
          FROM TRAN2018
         WHERE     TRAN_ENTITY_NUM = 1
               AND TRAN_DATE_OF_TRAN = '27-dec-2018'
               AND TRAN_CODE = 'TC'
               AND TRAN_BRN_CODE <> TRAN_ACING_BRN_CODE)
          INTER_BRANCH_CREDIT_NOTRAN2018 ,
       (SELECT /*+ PARALLEL(6) */
              COUNT (DISTINCT (TRAN_BATCH_NUMBER))
          FROM TRAN2016
         WHERE     TRAN_ENTITY_NUM = 1
               AND TRAN_DATE_OF_TRAN = '29-dec-2016'
               AND TRAN_CODE IN ('CW', 'CWSLP', 'CW1', 'CC'))
          CASH_WIDRAW_NO_OF_TRAN2016,
       (SELECT /*+ PARALLEL(6) */
              COUNT (DISTINCT (TRAN_BATCH_NUMBER))
          FROM TRAN2017
         WHERE     TRAN_ENTITY_NUM = 1
               AND TRAN_DATE_OF_TRAN = '28-dec-2017'
               AND TRAN_CODE IN ('CW', 'CWSLP', 'CW1', 'CC'))
          CASH_WIDRAW_NO_OF_TRAN2017,
       (SELECT /*+ PARALLEL(6) */
              COUNT (DISTINCT (TRAN_BATCH_NUMBER))
          FROM TRAN2018
         WHERE     TRAN_ENTITY_NUM = 1
               AND TRAN_DATE_OF_TRAN = '27-dec-2018'
               AND TRAN_CODE IN ('CW', 'CWSLP', 'CW1', 'CC'))
          CASH_WIDRAW_NO_OF_TRAN2018,
       (SELECT /*+ PARALLEL(6) */
              COUNT (DISTINCT (TRAN_BATCH_NUMBER))
          FROM TRAN2016
         WHERE     TRAN_ENTITY_NUM = 1
               AND TRAN_DATE_OF_TRAN = '29-dec-2016'
               AND TRAN_CODE IN ('CD'))
          CASH_DEPOSIT_NO_OF_TRAN2016,
       (SELECT /*+ PARALLEL(6) */
              COUNT (DISTINCT (TRAN_BATCH_NUMBER))
          FROM TRAN2017
         WHERE     TRAN_ENTITY_NUM = 1
               AND TRAN_DATE_OF_TRAN = '28-dec-2017'
               AND TRAN_CODE IN ('CD'))
          CASH_DEPOSIT_NO_OF_TRAN2017,
       (SELECT /*+ PARALLEL(6) */
              COUNT (DISTINCT (TRAN_BATCH_NUMBER))
          FROM TRAN2018
         WHERE     TRAN_ENTITY_NUM = 1
               AND TRAN_DATE_OF_TRAN = '27-dec-2018'
               AND TRAN_CODE IN ('CD'))
          CASH_DEPOSIT_NO_OF_TRAN2018
  FROM DUAL