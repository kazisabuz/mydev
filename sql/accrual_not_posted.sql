/* Formatted on 3/23/2023 12:53:14 PM (QP5 v5.388) */
SELECT ACNTS_BRN_CODE,
       ACCOUNT_NUMBER,
       ACNTS_INTERNAL_ACNUM,
       RAPARAM_CRINT_EXP_GL,
       ACCRUED_AMOUNT,
       CLIENTS_PAN_GIR_NUM,
       CASE
           WHEN TRIM (CLIENTS_PAN_GIR_NUM) IS NOT NULL THEN 10
           WHEN TRIM (CLIENTS_PAN_GIR_NUM) IS NULL THEN 15
           ELSE 15
       END    tds_rate
  FROM ACCRU_NOT_POSTED_2019_DEC,
       iaclink,
       raparam,
       acnts,
       clients
 WHERE     IACLINK_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
       AND ACNTS_ENTITY_NUM = 1
       AND IACLINK_ENTITY_NUM = 1
       AND IACLINK_ACTUAL_ACNUM = ACCOUNT_NUMBER
       AND ACCRUED_AMOUNT >= 1
       AND ACNTS_AC_TYPE = RAPARAM_AC_TYPE
       AND ACNTS_CLOSURE_DATE IS NULL
       AND CLIENTS_CODE = ACNTS_CLIENT_NUM;

--400101104
TRUNCATE TABLE AUTOPOST_TRAN_TEMP;

  --------------INTEREST----------------------

INSERT /*+ PARALLEL( 16) */ INTO AUTOPOST_TRAN_TEMP
    SELECT /*+ PARALLEL( 16) */
           1                                               BATCH_SL,
           1                                               LEG_SL,
           NULL                                            TRAN_DATE,
           NULL                                            VALUE_DATE,
           NULL                                            SUPP_TRAN,
           ACNTS_BRN_CODE                                  BRN_CODE,
           ACNTS_BRN_CODE                                  ACING_BRN_CODE,
           'C'                                             DR_CR,
           NULL                                            GLACC_CODE,
           ACNTS_INTERNAL_ACNUM                            INT_AC_NO,
           NULL                                            CONT_NO,
           'BDT'                                           CURR_CODE,
           ACCRUED_AMOUNT                                  AC_AMOUNT,
           'Interest Applied for the year of 2019-DEC'     NARRATION,
           0
      FROM (SELECT ACNTS_BRN_CODE,
                   ACCOUNT_NUMBER,
                   ACNTS_INTERNAL_ACNUM,
                   RAPARAM_CRINT_EXP_GL,
                   ACCRUED_AMOUNT,
                   CLIENTS_PAN_GIR_NUM,
                   CASE
                       WHEN TRIM (CLIENTS_PAN_GIR_NUM) IS NOT NULL THEN 10
                       WHEN TRIM (CLIENTS_PAN_GIR_NUM) IS NULL THEN 15
                       ELSE 15
                   END    tds_rate
              FROM ACCRU_NOT_POSTED_2019_DEC,
                   iaclink,
                   raparam,
                   acnts,
                   clients
             WHERE     IACLINK_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                   AND ACNTS_ENTITY_NUM = 1
                   AND IACLINK_ENTITY_NUM = 1
                   AND ACNTS_AC_TYPE <> 'SBNI'
                   AND IACLINK_ACTUAL_ACNUM = ACCOUNT_NUMBER
                   AND ACCRUED_AMOUNT >= 1
                   AND ACNTS_AC_TYPE = RAPARAM_AC_TYPE
                   AND ACNTS_CLOSURE_DATE IS NULL
                   AND CLIENTS_CODE = ACNTS_CLIENT_NUM)
    UNION ALL
      SELECT /*+ PARALLEL( 16) */
             1                                                  BATCH_SL,
             1                                                  LEG_SL,
             NULL                                               TRAN_DATE,
             NULL                                               VALUE_DATE,
             NULL                                               SUPP_TRAN,
             ACNTS_BRN_CODE                                     BRN_CODE,
             ACNTS_BRN_CODE                                     ACING_BRN_CODE,
             'D'                                                DR_CR,
             NVL (TRIM (RAPARAM_CRINT_EXP_GL), '400101104')     GLACC_CODE,
             NULL                                               INT_AC_NO,
             NULL                                               CONT_NO,
             'BDT'                                              CURR_CODE,
             SUM (ACCRUED_AMOUNT)                               AC_AMOUNT,
             'Interest Applied for the year of 2019-DEC'        NARRATION,
             0
        FROM (SELECT ACNTS_BRN_CODE,
                     ACCOUNT_NUMBER,
                     ACNTS_INTERNAL_ACNUM,
                     RAPARAM_CRINT_EXP_GL,
                     ACCRUED_AMOUNT,
                     CLIENTS_PAN_GIR_NUM,
                     CASE
                         WHEN TRIM (CLIENTS_PAN_GIR_NUM) IS NOT NULL THEN 10
                         WHEN TRIM (CLIENTS_PAN_GIR_NUM) IS NULL THEN 15
                         ELSE 15
                     END    tds_rate
                FROM ACCRU_NOT_POSTED_2019_DEC,
                     iaclink,
                     raparam,
                     acnts,
                     clients
               WHERE     IACLINK_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                     AND ACNTS_ENTITY_NUM = 1
                     AND IACLINK_ENTITY_NUM = 1
                     AND IACLINK_ACTUAL_ACNUM = ACCOUNT_NUMBER
                     AND ACCRUED_AMOUNT >= 1
                     AND ACNTS_AC_TYPE <> 'SBNI'
                     AND ACNTS_AC_TYPE = RAPARAM_AC_TYPE
                     AND ACNTS_CLOSURE_DATE IS NULL
                     AND CLIENTS_CODE = ACNTS_CLIENT_NUM)
    GROUP BY ACNTS_BRN_CODE, RAPARAM_CRINT_EXP_GL;


---------------------TDS------------------------------------------------------

INSERT INTO AUTOPOST_TRAN_TEMP
    SELECT /*+ PARALLEL( 16) */
           1
               BATCH_SL,
           1
               LEG_SL,
           NULL
               TRAN_DATE,
           NULL
               VALUE_DATE,
           NULL
               SUPP_TRAN,
           ACNTS_BRN_CODE
               BRN_CODE,
           ACNTS_BRN_CODE
               ACING_BRN_CODE,
           'D'
               DR_CR,
           NULL
               GLACC_CODE,
           ACNTS_INTERNAL_ACNUM
               INT_AC_NO,
           NULL
               CONT_NO,
           'BDT'
               CURR_CODE,
           CASE WHEN AC_AMOUNT < 1 THEN 1 ELSE AC_AMOUNT END
               AC_AMOUNT,
           'TDS Deduction on Interest Amount for the year of 2019-DEC'
               NARRATION,
           0
      FROM (SELECT ACNTS_BRN_CODE,
                   ACCOUNT_NUMBER,
                   ACNTS_INTERNAL_ACNUM,
                   RAPARAM_CRINT_EXP_GL,
                   ROUND (((ACCRUED_AMOUNT * tds_rate) / 100))     AC_AMOUNT,
                   CLIENTS_PAN_GIR_NUM
              FROM (SELECT ACNTS_BRN_CODE,
                           ACCOUNT_NUMBER,
                           ACNTS_INTERNAL_ACNUM,
                           RAPARAM_CRINT_EXP_GL,
                           ACCRUED_AMOUNT,
                           CLIENTS_PAN_GIR_NUM,
                           CASE
                               WHEN TRIM (CLIENTS_PAN_GIR_NUM) IS NOT NULL
                               THEN
                                   10
                               WHEN TRIM (CLIENTS_PAN_GIR_NUM) IS NULL
                               THEN
                                   15
                               ELSE
                                   15
                           END    tds_rate
                      FROM ACCRU_NOT_POSTED_2019_DEC,
                           iaclink,
                           raparam,
                           acnts,
                           clients
                     WHERE     IACLINK_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                           AND ACNTS_ENTITY_NUM = 1
                           AND IACLINK_ENTITY_NUM = 1
                           AND IACLINK_ACTUAL_ACNUM = ACCOUNT_NUMBER
                           AND ACCRUED_AMOUNT >= 1
                           AND ACNTS_AC_TYPE <> 'SBNI'
                           AND ACNTS_AC_TYPE = RAPARAM_AC_TYPE
                           AND ACNTS_CLOSURE_DATE IS NULL
                           AND CLIENTS_CODE = ACNTS_CLIENT_NUM))
    UNION ALL
      SELECT /*+ PARALLEL( 16) */
             1
                 BATCH_SL,
             1
                 LEG_SL,
             NULL
                 TRAN_DATE,
             NULL
                 VALUE_DATE,
             NULL
                 SUPP_TRAN,
             ACNTS_BRN_CODE
                 BRN_CODE,
             ACNTS_BRN_CODE
                 ACING_BRN_CODE,
             'C'
                 DR_CR,
             '140146110'
                 GLACC_CODE,
             NULL
                 INT_AC_NO,
             NULL
                 CONT_NO,
             'BDT'
                 CURR_CODE,
             SUM (CASE WHEN AC_AMOUNT < 1 THEN 1 ELSE AC_AMOUNT END)
                 AC_AMOUNT,
             'TDS Deduction on Interest Amount for the year of 2019-DEC'
                 NARRATION,
             0
        FROM (SELECT ACNTS_BRN_CODE,
                     ACCOUNT_NUMBER,
                     ACNTS_INTERNAL_ACNUM,
                     RAPARAM_CRINT_EXP_GL,
                     ROUND (((ACCRUED_AMOUNT * tds_rate) / 100))     AC_AMOUNT,
                     CLIENTS_PAN_GIR_NUM
                FROM (SELECT ACNTS_BRN_CODE,
                             ACCOUNT_NUMBER,
                             ACNTS_INTERNAL_ACNUM,
                             RAPARAM_CRINT_EXP_GL,
                             ACCRUED_AMOUNT,
                             CLIENTS_PAN_GIR_NUM,
                             CASE
                                 WHEN TRIM (CLIENTS_PAN_GIR_NUM) IS NOT NULL
                                 THEN
                                     10
                                 WHEN TRIM (CLIENTS_PAN_GIR_NUM) IS NULL
                                 THEN
                                     15
                                 ELSE
                                     15
                             END    tds_rate
                        FROM ACCRU_NOT_POSTED_2019_DEC,
                             iaclink,
                             raparam,
                             acnts,
                             clients
                       WHERE     IACLINK_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                             AND ACNTS_ENTITY_NUM = 1
                             AND IACLINK_ENTITY_NUM = 1
                             AND IACLINK_ACTUAL_ACNUM = ACCOUNT_NUMBER
                             AND ACCRUED_AMOUNT >= 1
                             AND ACNTS_AC_TYPE <> 'SBNI'
                             AND ACNTS_AC_TYPE = RAPARAM_AC_TYPE
                             AND ACNTS_CLOSURE_DATE IS NULL
                             AND CLIENTS_CODE = ACNTS_CLIENT_NUM))
    GROUP BY ACNTS_BRN_CODE;

----------------for thread----------
--SP_GEN_TRAN_THREAD
-- SP_AUTO_SCRIPT_TRAN_BR_WISE	 
--
--
--SP_GEN_TRAN

exec SP_GEN_TRAN_THREAD
TRUNCATE TABLE AUTOPOST_TRAN;

INSERT INTO AUTOPOST_TRAN
    SELECT * FROM AUTOPOST_TRAN_BATCH;


INSERT INTO AUTOPOST_TRAN
    SELECT /*+ PARALLEL( 32) */
           DENSE_RANK () OVER (ORDER BY TRAN_DATE, BRN_CODE)
               BATCH_SL,
           ROW_NUMBER ()
               OVER (PARTITION BY TRAN_DATE, BRN_CODE
                     ORDER BY TRAN_DATE, BRN_CODE)
               LEG_SL,
           TRAN_DATE
               TRAN_DATE,
           VALUE_DATE
               VALUE_DATE,
           NULL
               SUPP_TRAN,
           BRN_CODE,
           ACING_BRN_CODE,
           DR_CR,
           GLACC_CODE,
           INT_AC_NO,
           CONT_NO,
           CURR_CODE,
           AC_AMOUNT,
           AC_AMOUNT
               BC_AMOUNT,
           NULL
               PRINCIPAL,
           NULL
               INTEREST,
           NULL
               CHARGE,
           NULL
               INST_PREFIX,
           NULL
               INST_NUM,
           NULL
               INST_DATE,
           NULL
               IBR_GL,
           NULL
               ORIG_RESP,
           NULL
               CONT_BRN_CODE,
           NULL
               ADV_NUM,
           NULL
               ADV_DATE,
           NULL
               IBR_CODE,
           NULL
               CAN_IBR_CODE,
           NARRATION,
           NARRATION,
           'INTELECT'
               USER_ID,
           NULL
               TERMINAL_ID,
           NULL
               PROCESSED,
           NULL
               BATCH_NO,
           NULL
               ERR_MSG,
           NULL
               DEPT_CODE
      FROM AUTOPOST_TRAN_TEMP TT;

 

      --------------------------



BEGIN
    -- V_ASON_DATE := '09-APR-2020';

    FOR IDX IN (SELECT BRANCH_CODE FROM MIG_DETAIL)
    LOOP
        INSERT INTO AUTOPOST_TRAN
            SELECT /*+ PARALLEL( 16) */
                   (SELECT NVL (MAX (BATCH_SL), 0) + 1 FROM AUTOPOST_TRAN)
                       BATCH_SL,
                   ROWNUM
                       LEG_SL,
                   TRAN_DATE
                       TRAN_DATE,
                   VALUE_DATE
                       VALUE_DATE,
                   NULL
                       SUPP_TRAN,
                   BRN_CODE,
                   ACING_BRN_CODE,
                   DR_CR,
                   GLACC_CODE,
                   INT_AC_NO,
                   CONT_NO,
                   CURR_CODE,
                   AC_AMOUNT,
                   AC_AMOUNT
                       BC_AMOUNT,
                   NULL
                       PRINCIPAL,
                   NULL
                       INTEREST,
                   NULL
                       CHARGE,
                   NULL
                       INST_PREFIX,
                   NULL
                       INST_NUM,
                   NULL
                       INST_DATE,
                   NULL
                       IBR_GL,
                   NULL
                       ORIG_RESP,
                   NULL
                       CONT_BRN_CODE,
                   NULL
                       ADV_NUM,
                   NULL
                       ADV_DATE,
                   NULL
                       IBR_CODE,
                   NULL
                       CAN_IBR_CODE,
                   NARRATION,
                   NARRATION,
                   'INTELECT'
                       USER_ID,
                   NULL
                       TERMINAL_ID,
                   NULL
                       PROCESSED,
                   NULL
                       BATCH_NO,
                   NULL
                       ERR_MSG,
                   NULL
                       DEPT_CODE
              FROM AUTOPOST_TRAN_TEMP TT
             WHERE BRN_CODE = idx.BRANCH_CODE;

        COMMIT;
    END LOOP;
END;

---------------------------QUERY INT----------------

  SELECT /*+ PARALLEL( 8) */
         ACNTS_BRN_CODE                         BRN_CODE,
         (SELECT mbrn_name
            FROM mbrn
           WHERE mbrn_code = ACNTS_BRN_CODE)    branch_name,
         COUNT (ACNTS_INTERNAL_ACNUM)           INT_AC_NO,
         SUM (ACCRUED_AMOUNT)                   AC_AMOUNT,
         '2019-DEC'                             NARRATION
    FROM (SELECT ACNTS_BRN_CODE,
                 ACCOUNT_NUMBER,
                 ACNTS_INTERNAL_ACNUM,
                 RAPARAM_CRINT_EXP_GL,
                 ACCRUED_AMOUNT,
                 CLIENTS_PAN_GIR_NUM,
                 CASE
                     WHEN TRIM (CLIENTS_PAN_GIR_NUM) IS NOT NULL THEN 10
                     WHEN TRIM (CLIENTS_PAN_GIR_NUM) IS NULL THEN 15
                     ELSE 15
                 END    tds_rate
            FROM ACCRU_NOT_POSTED_2019_DEC,
                 iaclink,
                 raparam,
                 acnts,
                 clients
           WHERE     IACLINK_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                 AND ACNTS_ENTITY_NUM = 1
                 AND IACLINK_ENTITY_NUM = 1
                 AND ACNTS_AC_TYPE <> 'SBNI'
                 AND IACLINK_ACTUAL_ACNUM = ACCOUNT_NUMBER
                 AND ACCRUED_AMOUNT >= 1
                 AND ACNTS_AC_TYPE = RAPARAM_AC_TYPE
                 AND ACNTS_CLOSURE_DATE IS NULL
                 AND CLIENTS_CODE = ACNTS_CLIENT_NUM)
GROUP BY ACNTS_BRN_CODE;

SELECT /*+ PARALLEL( 8) */
         ACNTS_BRN_CODE                         BRN_CODE,
         (SELECT mbrn_name
            FROM mbrn
           WHERE mbrn_code = ACNTS_BRN_CODE)    branch_name,
         COUNT (ACNTS_INTERNAL_ACNUM)           INT_AC_NO,
         SUM (ACCRUED_AMOUNT)                   AC_AMOUNT,
         '2019-JUN'                             NARRATION
    FROM (SELECT ACNTS_BRN_CODE,
                 ACCOUNT_NUMBER,
                 ACNTS_INTERNAL_ACNUM,
                 RAPARAM_CRINT_EXP_GL,
                 ACCRUED_AMOUNT,
                 CLIENTS_PAN_GIR_NUM,
                 CASE
                     WHEN TRIM (CLIENTS_PAN_GIR_NUM) IS NOT NULL THEN 10
                     WHEN TRIM (CLIENTS_PAN_GIR_NUM) IS NULL THEN 15
                     ELSE 15
                 END    tds_rate
            FROM ACCRU_NOT_POSTED_2019,
                 iaclink,
                 raparam,
                 acnts,
                 clients
           WHERE     IACLINK_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                 AND ACNTS_ENTITY_NUM = 1
                 AND IACLINK_ENTITY_NUM = 1
                 AND ACNTS_AC_TYPE <> 'SBNI'
                 AND IACLINK_ACTUAL_ACNUM = ACCOUNT_NUMBER
                 AND ACCRUED_AMOUNT >= 1
                 AND ACNTS_AC_TYPE = RAPARAM_AC_TYPE
                 AND ACNTS_CLOSURE_DATE IS NULL
                 AND CLIENTS_CODE = ACNTS_CLIENT_NUM)
GROUP BY ACNTS_BRN_CODE;

--------------QUERY TDS--------------------
/* Formatted on 3/23/2023 12:53:25 PM (QP5 v5.388) */
  SELECT /*+ PARALLEL( 16) */
         ACNTS_BRN_CODE
             BRN_CODE,
         (SELECT mbrn_name
            FROM mbrn
           WHERE mbrn_code = ACNTS_BRN_CODE)
             branch_name,
             COUNT(ACCOUNT_NUMBER) ACCOUNT_NUMBER,
         SUM (CASE WHEN AC_AMOUNT < 1 THEN 1 ELSE AC_AMOUNT END)
             AC_AMOUNT,
         '2019-DEC'
             NARRATION
    FROM (SELECT ACNTS_BRN_CODE,
                 ACCOUNT_NUMBER,
                 ACNTS_INTERNAL_ACNUM,
                 RAPARAM_CRINT_EXP_GL,
                 ROUND (((ACCRUED_AMOUNT * tds_rate) / 100))     AC_AMOUNT,
                 CLIENTS_PAN_GIR_NUM
            FROM (SELECT ACNTS_BRN_CODE,
                         ACCOUNT_NUMBER,
                         ACNTS_INTERNAL_ACNUM,
                         RAPARAM_CRINT_EXP_GL,
                         ACCRUED_AMOUNT,
                         CLIENTS_PAN_GIR_NUM,
                         CASE
                             WHEN TRIM (CLIENTS_PAN_GIR_NUM) IS NOT NULL
                             THEN
                                 10
                             WHEN TRIM (CLIENTS_PAN_GIR_NUM) IS NULL
                             THEN
                                 15
                             ELSE
                                 15
                         END    tds_rate
                    FROM ACCRU_NOT_POSTED_2019_DEC,
                         iaclink,
                         raparam,
                         acnts,
                         clients
                   WHERE     IACLINK_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                         AND ACNTS_ENTITY_NUM = 1
                         AND IACLINK_ENTITY_NUM = 1
                         AND IACLINK_ACTUAL_ACNUM = ACCOUNT_NUMBER
                         AND ACCRUED_AMOUNT >= 1
                         AND ACNTS_AC_TYPE <> 'SBNI'
                         AND ACNTS_AC_TYPE = RAPARAM_AC_TYPE
                         AND ACNTS_CLOSURE_DATE IS NULL
                         AND CLIENTS_CODE = ACNTS_CLIENT_NUM))
GROUP BY ACNTS_BRN_CODE
UNION ALL
SELECT /*+ PARALLEL( 16) */
         ACNTS_BRN_CODE
             BRN_CODE,
         (SELECT mbrn_name
            FROM mbrn
           WHERE mbrn_code = ACNTS_BRN_CODE)
             branch_name,
             COUNT(ACCOUNT_NUMBER) ACCOUNT_NUMBER,
         SUM (CASE WHEN AC_AMOUNT < 1 THEN 1 ELSE AC_AMOUNT END)
             AC_AMOUNT,
         '2019-JUN'
             NARRATION
    FROM (SELECT ACNTS_BRN_CODE,
                 ACCOUNT_NUMBER,
                 ACNTS_INTERNAL_ACNUM,
                 RAPARAM_CRINT_EXP_GL,
                 ROUND (((ACCRUED_AMOUNT * tds_rate) / 100))     AC_AMOUNT,
                 CLIENTS_PAN_GIR_NUM
            FROM (SELECT ACNTS_BRN_CODE,
                         ACCOUNT_NUMBER,
                         ACNTS_INTERNAL_ACNUM,
                         RAPARAM_CRINT_EXP_GL,
                         ACCRUED_AMOUNT,
                         CLIENTS_PAN_GIR_NUM,
                         CASE
                             WHEN TRIM (CLIENTS_PAN_GIR_NUM) IS NOT NULL
                             THEN
                                 10
                             WHEN TRIM (CLIENTS_PAN_GIR_NUM) IS NULL
                             THEN
                                 15
                             ELSE
                                 15
                         END    tds_rate
                    FROM ACCRU_NOT_POSTED_2019,
                         iaclink,
                         raparam,
                         acnts,
                         clients
                   WHERE     IACLINK_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                         AND ACNTS_ENTITY_NUM = 1
                         AND IACLINK_ENTITY_NUM = 1
                         AND IACLINK_ACTUAL_ACNUM = ACCOUNT_NUMBER
                         AND ACCRUED_AMOUNT >= 1
                         AND ACNTS_AC_TYPE <> 'SBNI'
                         AND ACNTS_AC_TYPE = RAPARAM_AC_TYPE
                         AND ACNTS_CLOSURE_DATE IS NULL
                         AND CLIENTS_CODE = ACNTS_CLIENT_NUM))
GROUP BY ACNTS_BRN_CODE;