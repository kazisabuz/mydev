/* Formatted on 7/16/2020 2:18:55 PM (QP5 v5.227.12220.39754) */
SELECT mbrn_code, mbrn_name
  FROM (  SELECT DISTINCT A.TRAN_ACING_BRN_CODE
            /*,
              B.MBRN_NAME,
              A.TRAN_INTERNAL_ACNUM,
              A.TRAN_DATE_OF_TRAN,
              DECODE (A.TRAN_DB_CR_FLG, 'D', 'Withdrawal', 'Deposit') TRANTYPE,
              COUNT (DISTINCT A.TRAN_INTERNAL_ACNUM) CTR,
              SUM (A.TRAN_AMOUNT) AS GROUPAMOUNT */
            FROM TRAN2020 A, ACNTS AN, CLIENTS C
           --, MBRN B
           WHERE                     --A.TRAN_ACING_BRN_CODE = B.MBRN_CODE AND
                A    .TRAN_INTERNAL_ACNUM = AN.ACNTS_INTERNAL_ACNUM
                 AND AN.ACNTS_ENTITY_NUM = 1
                 AND AN.ACNTS_CLIENT_NUM = C.CLIENTS_CODE
                 AND A.TRAN_INTERNAL_ACNUM != 0
                 AND A.TRAN_TYPE_OF_TRAN = 3
                 AND a.tran_entd_by != 'MIG'
                 AND AN.ACNTS_BRN_CODE = A.TRAN_ACING_BRN_CODE
                 AND A.TRAN_AUTH_BY IS NOT NULL
                 AND A.TRAN_DATE_OF_TRAN BETWEEN '01-JUN-2020'
                                             AND '30-JUN-2020'
                 AND A.TRAN_ACING_BRN_CODE NOT IN
                        (SELECT N.RPT_BRANCH_CODE
                           FROM GOAML_RPT_HISTORY N
                          WHERE     N.RPT_YEAR = 2020
                                AND N.RPT_MONTH = 6
                                AND n.process_status = 'F')
                 AND 1 =
                        (CASE
                            WHEN     (   C.CLIENTS_CONST_CODE = 9
                                      OR C.CLIENTS_CONST_CODE = 10)
                                 AND A.TRAN_DB_CR_FLG = 'C'
                            THEN
                               2
                            ELSE
                               1
                         END)
                 AND NOT EXISTS
                        (SELECT 1
                           FROM GOAML_SP_ACCTYPE
                          WHERE NAME = AN.ACNTS_AC_TYPE)
        GROUP BY A.TRAN_ACING_BRN_CODE,
                 A.TRAN_INTERNAL_ACNUM,
                 A.TRAN_DATE_OF_TRAN,
                 A.TRAN_DB_CR_FLG
          HAVING (SUM (A.TRAN_AMOUNT) >= 1000000)) t,
       mbrn
 WHERE t.TRAN_ACING_BRN_CODE = mbrn_code;