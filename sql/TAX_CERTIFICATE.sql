/* Formatted on 7/24/2022 5:57:56 PM (QP5 v5.252.13127.32867) */
SELECT T_INT,
       T_TDS,
       S_TDS,
       S_INT,
       tds_rate,
       AC_AC_NO,
       ACNTS_AC_NAME1 AS AC_NAME,
       REPLACE (
             NVL (ACNTS_AC_ADDR1, ' ')
          || NVL (ACNTS_AC_ADDR2, ' ')
          || NVL (ACNTS_AC_ADDR3, ' ')
          || NVL (ACNTS_AC_ADDR4, ' ')
          || NVL (ACNTS_AC_ADDR5, ' '),
          ';',
          ',')
          AS AC_ADDRESS,
       NVL (
          Fn_get_ason_acbal (
             1,
             DECODE (AC_NO, NULL, TO_NUMBER (12422400004208), AC_NO),
             'BDT',
             '30-jun-2022',
             Fn_get_currbuss_date (1, NULL),
             0),
          0)
          AS bal,
       SP_AMOUNTTOWORD.SP_AMOUNT_TO_WORD (
          1,
          'BDT',
          NVL (
             Fn_get_ason_acbal (
                1,
                DECODE (AC_NO, NULL, TO_NUMBER (12422400004208), AC_NO),
                'BDT',
                '30-jun-2022',
                Fn_get_currbuss_date (1, NULL),
                0),
             0))
          AS bal_word,
       (SELECT UPPER (INS_NAME_OF_BANK) BANK_NAME
          FROM INSTALL
         WHERE ROWNUM = 1)
          AS BANK_NAME
  FROM ACNTS A
       LEFT JOIN
       (  SELECT AC_NO,
                 AC_AC_NO,
                 AC_ADDRESS,
                 AC_NAME,
                 SUM (T_INT) T_INT,
                 SUM (T_TDS) T_TDS,
                 CASE WHEN tds_rate <= 12.5 THEN 10 ELSE 15 END AS tds_rate,
                 S_INT,
                 S_TDS
            FROM (  SELECT BANK_NAME,
                           AC_NO,
                           AC_AC_NO,
                           AC_ADDRESS,
                           AC_NAME,
                           T_INT,
                           T_TDS,
                           TDS_RATE,
                           SUM (T_INT) OVER (PARTITION BY TRUNC (AC_NO)) AS S_INT,
                           SUM (T_TDS) OVER (PARTITION BY TRUNC (AC_NO)) AS S_TDS
                      FROM TABLE (PKG_TDS_REPORT.DEP_AC_STMT (
                                     1,
                                     24224,
                                     0,
                                     12422400004208,
                                     'BDT',
                                     TO_DATE ('01-jul-2021', 'DD-MM-YYYY'),
                                     TO_DATE ('30-jun-2022', 'DD-MM-YYYY')))
                  ORDER BY TRUNC (AC_NO))
        GROUP BY AC_NO,
                 AC_AC_NO,
                 AC_ADDRESS,
                 AC_NAME,
                 tds_rate,
                 S_INT,
                 S_TDS) pk
          ON pk.AC_NO = ACNTS_INTERNAL_ACNUM
 WHERE A.ACNTS_BRN_CODE = 24224 AND ACNTS_INTERNAL_ACNUM = 12422400004208