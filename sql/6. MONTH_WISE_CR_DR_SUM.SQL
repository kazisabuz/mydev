/*<TOAD_FILE_CHUNK>*/
/* Formatted on 6/7/2023 6:40:29 PM (QP5 v5.388) */
CREATE TABLE ACNTBBAL_ACTUAL_AC
AS
    SELECT *
      FROM ACNTBBAL
     WHERE     ACNTBBAL_ENTITY_NUM = 1
           AND ACNTBBAL_INTERNAL_ACNUM IN
                   (SELECT IACLINK_INTERNAL_ACNUM FROM ACTUAL_ACCOUNT_UPDATE);


CREATE TABLE MONTHS_WISE_AC_BALANCE
(
    INT_AC_NO             NUMBER (14),
    TRANSACTION_YEAR      VARCHAR2 (4 BYTE),
    TRANSACTION_MONTHS    VARCHAR2 (2 BYTE),
    MW_CR_SUM             NUMBER,
    MW_DR_SUM             NUMBER,
    SL                    NUMBER
);


TRUNCATE TABLE MONTHS_WISE_AC_BALANCE;

CREATE INDEX IND_MONTHS_WISE_AC_BALANCE
    ON MONTHS_WISE_AC_BALANCE (INT_AC_NO,
                               TRANSACTION_YEAR,
                               TRANSACTION_MONTHS);

CREATE OR REPLACE PROCEDURE SP_MONTHWISE_DR_CR_SUM
IS
    V_ACNUM        NUMBER (14);
    V_YEAR         NUMBER (4);
    V_MONTH        NUMBER (2);
    V_CBD_YEAR     NUMBER (4);
    V_CBD_MONTH    NUMBER (2);
    V_CR_SUM       NUMBER (18, 3);
    V_DR_SUM       NUMBER (18, 3);
    V_SQL          VARCHAR2 (200);
    V_CBD          DATE;
    V_START_DATE   DATE;
    V_END_DATE     DATE;
    V_COUNT        NUMBER;
BEGIN
    V_SQL := 'TRUNCATE TABLE MONTHS_WISE_AC_BALANCE';

    EXECUTE IMMEDIATE V_SQL;


    INSERT INTO MONTHS_WISE_AC_BALANCE
        WITH
            MONTHS_WISE_AC_BALANCE
            AS
                ( ------------------- FORMONTHS WISE TRANSACTION SUMMATION --------------------
                   SELECT TRAN_INTERNAL_ACNUM,
                          TRANSACTION_YEAR,
                          TRANSACTION_MONTHS,
                          SUM (CREDIT_AMOUNT)
                              MONTHS_WISE_CREDIT_SUM,
                          SUM (DEBIT_AMOUNT)
                              MONTHS_WISE_DEBIT_SUM,
                          SUM (CREDIT_TRANSACTION)
                              MONTHS_WISE_CREDIT_TRAN,
                          SUM (DEBIT_TRANSACTION)
                              MONTHS_WISE_DEBIT_TRAN,
                          SUM (PRIN_AC_AMT_CR)
                              MONTHS_WISE_PRIN_AC_AMT_CR,
                          SUM (PRIN_AC_AMT_DR)
                              MONTHS_WISE_PRIN_AC_AMT_DR,
                          SUM (INTRD_AC_AMT_CR)
                              MONTHS_WISE_INTRD_AC_AMT_CR,
                          SUM (INTRD_AC_AMT_DR)
                              MONTHS_WISE_INTRD_AC_AMT_DR,
                          SUM (CHARGE_AC_AMT_CR)
                              MONTHS_WISE_CHARGE_AC_AMT_CR,
                          SUM (CHARGE_AC_AMT_DR)
                              MONTHS_WISE_CHARGE_AC_AMT_DR
                     FROM ( ( ------------------- FORMONTHS WISE TRANSACTION SELECTION --------------------
                             SELECT /*+ FULL(TA) PARALLEL(TA, DEFAULT,DEFAULT)  PARALLEL(TR, DEFAULT,DEFAULT) */
                                    TR.TRAN_INTERNAL_ACNUM,
                                    TO_CHAR (
                                        ADD_MONTHS (TR.TRAN_DATE_OF_TRAN, 1),
                                        'MM')      TRANSACTION_MONTHS,
                                    TO_CHAR (
                                        ADD_MONTHS (TR.TRAN_DATE_OF_TRAN, 1),
                                        'YYYY')    TRANSACTION_YEAR,
                                    TRAN_BATCH_NUMBER,
                                    TRAN_BATCH_SL_NUM,
                                    TRAN_DB_CR_FLG,
                                    TRAN_AMOUNT,
                                    (CASE
                                         WHEN TRAN_DB_CR_FLG = 'D'
                                         THEN
                                             NVL (TRAN_AMOUNT, 0)
                                         ELSE
                                             0
                                     END)          DEBIT_AMOUNT,
                                    (CASE
                                         WHEN TRAN_DB_CR_FLG = 'C'
                                         THEN
                                             NVL (TRAN_AMOUNT, 0)
                                         ELSE
                                             0
                                     END)          CREDIT_AMOUNT,
                                    (CASE
                                         WHEN TRAN_DB_CR_FLG = 'C' THEN 1
                                         ELSE 0
                                     END)          CREDIT_TRANSACTION,
                                    (CASE
                                         WHEN TRAN_DB_CR_FLG = 'D' THEN 1
                                         ELSE 0
                                     END)          DEBIT_TRANSACTION,
                                    (CASE
                                         WHEN TRAN_DB_CR_FLG = 'D'
                                         THEN
                                             NVL (TRANADV_PRIN_AC_AMT, 0)
                                         ELSE
                                             0
                                     END)          PRIN_AC_AMT_DR,
                                    (CASE
                                         WHEN TRAN_DB_CR_FLG = 'C'
                                         THEN
                                             NVL (TRANADV_PRIN_AC_AMT, 0)
                                         ELSE
                                             0
                                     END)          PRIN_AC_AMT_CR,
                                    (CASE
                                         WHEN TRAN_DB_CR_FLG = 'D'
                                         THEN
                                             NVL (TRANADV_INTRD_AC_AMT, 0)
                                         ELSE
                                             0
                                     END)          INTRD_AC_AMT_DR,
                                    (CASE
                                         WHEN TRAN_DB_CR_FLG = 'C'
                                         THEN
                                             NVL (TRANADV_INTRD_AC_AMT, 0)
                                         ELSE
                                             0
                                     END)          INTRD_AC_AMT_CR,
                                    (CASE
                                         WHEN TRAN_DB_CR_FLG = 'D'
                                         THEN
                                             NVL (TRANADV_CHARGE_AC_AMT, 0)
                                         ELSE
                                             0
                                     END)          CHARGE_AC_AMT_DR,
                                    (CASE
                                         WHEN TRAN_DB_CR_FLG = 'C'
                                         THEN
                                             NVL (TRANADV_CHARGE_AC_AMT, 0)
                                         ELSE
                                             0
                                     END)          CHARGE_AC_AMT_CR
                             FROM TRAN2014 TR
                                  LEFT OUTER JOIN TRANADV2014 TA
                                      ON (    TA.TRANADV_ENTITY_NUM =
                                              TR.TRAN_ENTITY_NUM
                                          AND TA.TRANADV_BRN_CODE =
                                              TR.TRAN_BRN_CODE
                                          AND TA.TRANADV_DATE_OF_TRAN =
                                              TR.TRAN_DATE_OF_TRAN
                                          AND TA.TRANADV_BATCH_NUMBER =
                                              TR.TRAN_BATCH_NUMBER
                                          AND TA.TRANADV_BATCH_SL_NUM =
                                              TR.TRAN_BATCH_SL_NUM)
                            WHERE     TR.TRAN_AUTH_ON IS NOT NULL
                                  AND TR.TRAN_INTERNAL_ACNUM IN
                                          (SELECT IACLINK_INTERNAL_ACNUM
                                             FROM ACTUAL_ACCOUNT_UPDATE)
                                  AND TR.TRAN_INTERNAL_ACNUM <> 0
                                  AND TR.TRAN_AMOUNT <> 0)
                           UNION ALL
                           (SELECT /*+ FULL(TA) PARALLEL(TA, DEFAULT,DEFAULT)  PARALLEL(TR, DEFAULT,DEFAULT) */
                                   TR.TRAN_INTERNAL_ACNUM,
                                   TO_CHAR (
                                       ADD_MONTHS (TR.TRAN_DATE_OF_TRAN, 1),
                                       'MM')      TRANSACTION_MONTHS,
                                   TO_CHAR (
                                       ADD_MONTHS (TR.TRAN_DATE_OF_TRAN, 1),
                                       'YYYY')    TRANSACTION_YEAR,
                                   TRAN_BATCH_NUMBER,
                                   TRAN_BATCH_SL_NUM,
                                   TRAN_DB_CR_FLG,
                                   TRAN_AMOUNT,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'D'
                                        THEN
                                            NVL (TRAN_AMOUNT, 0)
                                        ELSE
                                            0
                                    END)          DEBIT_AMOUNT,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'C'
                                        THEN
                                            NVL (TRAN_AMOUNT, 0)
                                        ELSE
                                            0
                                    END)          CREDIT_AMOUNT,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'C' THEN 1
                                        ELSE 0
                                    END)          CREDIT_TRANSACTION,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'D' THEN 1
                                        ELSE 0
                                    END)          DEBIT_TRANSACTION,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'D'
                                        THEN
                                            NVL (TRANADV_PRIN_AC_AMT, 0)
                                        ELSE
                                            0
                                    END)          PRIN_AC_AMT_DR,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'C'
                                        THEN
                                            NVL (TRANADV_PRIN_AC_AMT, 0)
                                        ELSE
                                            0
                                    END)          PRIN_AC_AMT_CR,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'D'
                                        THEN
                                            NVL (TRANADV_INTRD_AC_AMT, 0)
                                        ELSE
                                            0
                                    END)          INTRD_AC_AMT_DR,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'C'
                                        THEN
                                            NVL (TRANADV_INTRD_AC_AMT, 0)
                                        ELSE
                                            0
                                    END)          INTRD_AC_AMT_CR,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'D'
                                        THEN
                                            NVL (TRANADV_CHARGE_AC_AMT, 0)
                                        ELSE
                                            0
                                    END)          CHARGE_AC_AMT_DR,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'C'
                                        THEN
                                            NVL (TRANADV_CHARGE_AC_AMT, 0)
                                        ELSE
                                            0
                                    END)          CHARGE_AC_AMT_CR
                             FROM TRAN2015 TR
                                  LEFT OUTER JOIN TRANADV2015 TA
                                      ON (    TA.TRANADV_ENTITY_NUM =
                                              TR.TRAN_ENTITY_NUM
                                          AND TA.TRANADV_BRN_CODE =
                                              TR.TRAN_BRN_CODE
                                          AND TA.TRANADV_DATE_OF_TRAN =
                                              TR.TRAN_DATE_OF_TRAN
                                          AND TA.TRANADV_BATCH_NUMBER =
                                              TR.TRAN_BATCH_NUMBER
                                          AND TA.TRANADV_BATCH_SL_NUM =
                                              TR.TRAN_BATCH_SL_NUM)
                            WHERE     TR.TRAN_AUTH_ON IS NOT NULL
                                  AND TR.TRAN_INTERNAL_ACNUM IN
                                          (SELECT IACLINK_INTERNAL_ACNUM
                                             FROM ACTUAL_ACCOUNT_UPDATE)
                                  AND TR.TRAN_INTERNAL_ACNUM <> 0
                                  AND TR.TRAN_AMOUNT <> 0)
                           UNION ALL
                           ( ------------------- FORMONTHS WISE TRANSACTION SELECTION --------------------
                            SELECT /*+ FULL(TA) PARALLEL(TA, DEFAULT,DEFAULT)  PARALLEL(TR, DEFAULT,DEFAULT) */
                                   TR.TRAN_INTERNAL_ACNUM,
                                   TO_CHAR (
                                       ADD_MONTHS (TR.TRAN_DATE_OF_TRAN, 1),
                                       'MM')      TRANSACTION_MONTHS,
                                   TO_CHAR (
                                       ADD_MONTHS (TR.TRAN_DATE_OF_TRAN, 1),
                                       'YYYY')    TRANSACTION_YEAR,
                                   TRAN_BATCH_NUMBER,
                                   TRAN_BATCH_SL_NUM,
                                   TRAN_DB_CR_FLG,
                                   TRAN_AMOUNT,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'D'
                                        THEN
                                            NVL (TRAN_AMOUNT, 0)
                                        ELSE
                                            0
                                    END)          DEBIT_AMOUNT,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'C'
                                        THEN
                                            NVL (TRAN_AMOUNT, 0)
                                        ELSE
                                            0
                                    END)          CREDIT_AMOUNT,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'C' THEN 1
                                        ELSE 0
                                    END)          CREDIT_TRANSACTION,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'D' THEN 1
                                        ELSE 0
                                    END)          DEBIT_TRANSACTION,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'D'
                                        THEN
                                            NVL (TRANADV_PRIN_AC_AMT, 0)
                                        ELSE
                                            0
                                    END)          PRIN_AC_AMT_DR,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'C'
                                        THEN
                                            NVL (TRANADV_PRIN_AC_AMT, 0)
                                        ELSE
                                            0
                                    END)          PRIN_AC_AMT_CR,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'D'
                                        THEN
                                            NVL (TRANADV_INTRD_AC_AMT, 0)
                                        ELSE
                                            0
                                    END)          INTRD_AC_AMT_DR,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'C'
                                        THEN
                                            NVL (TRANADV_INTRD_AC_AMT, 0)
                                        ELSE
                                            0
                                    END)          INTRD_AC_AMT_CR,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'D'
                                        THEN
                                            NVL (TRANADV_CHARGE_AC_AMT, 0)
                                        ELSE
                                            0
                                    END)          CHARGE_AC_AMT_DR,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'C'
                                        THEN
                                            NVL (TRANADV_CHARGE_AC_AMT, 0)
                                        ELSE
                                            0
                                    END)          CHARGE_AC_AMT_CR
                             FROM TRAN2016 TR
                                  LEFT OUTER JOIN TRANADV2016 TA
                                      ON (    TA.TRANADV_ENTITY_NUM =
                                              TR.TRAN_ENTITY_NUM
                                          AND TA.TRANADV_BRN_CODE =
                                              TR.TRAN_BRN_CODE
                                          AND TA.TRANADV_DATE_OF_TRAN =
                                              TR.TRAN_DATE_OF_TRAN
                                          AND TA.TRANADV_BATCH_NUMBER =
                                              TR.TRAN_BATCH_NUMBER
                                          AND TA.TRANADV_BATCH_SL_NUM =
                                              TR.TRAN_BATCH_SL_NUM)
                            WHERE     TR.TRAN_AUTH_ON IS NOT NULL
                                  AND TR.TRAN_INTERNAL_ACNUM IN
                                          (SELECT IACLINK_INTERNAL_ACNUM
                                             FROM ACTUAL_ACCOUNT_UPDATE)
                                  AND TR.TRAN_INTERNAL_ACNUM <> 0
                                  AND TR.TRAN_AMOUNT <> 0)
                           UNION ALL
                           ( ------------------- FOR MONTHS WISE TRANSACTION SELECTION --------------------
                            SELECT /*+ FULL(TA) PARALLEL(TA, DEFAULT,DEFAULT)  PARALLEL(TR, DEFAULT,DEFAULT) */
                                   TR.TRAN_INTERNAL_ACNUM,
                                   TO_CHAR (
                                       ADD_MONTHS (TR.TRAN_DATE_OF_TRAN, 1),
                                       'MM')      TRANSACTION_MONTHS,
                                   TO_CHAR (
                                       ADD_MONTHS (TR.TRAN_DATE_OF_TRAN, 1),
                                       'YYYY')    TRANSACTION_YEAR,
                                   TRAN_BATCH_NUMBER,
                                   TRAN_BATCH_SL_NUM,
                                   TRAN_DB_CR_FLG,
                                   TRAN_AMOUNT,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'D'
                                        THEN
                                            NVL (TRAN_AMOUNT, 0)
                                        ELSE
                                            0
                                    END)          DEBIT_AMOUNT,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'C'
                                        THEN
                                            NVL (TRAN_AMOUNT, 0)
                                        ELSE
                                            0
                                    END)          CREDIT_AMOUNT,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'C' THEN 1
                                        ELSE 0
                                    END)          CREDIT_TRANSACTION,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'D' THEN 1
                                        ELSE 0
                                    END)          DEBIT_TRANSACTION,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'D'
                                        THEN
                                            NVL (TRANADV_PRIN_AC_AMT, 0)
                                        ELSE
                                            0
                                    END)          PRIN_AC_AMT_DR,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'C'
                                        THEN
                                            NVL (TRANADV_PRIN_AC_AMT, 0)
                                        ELSE
                                            0
                                    END)          PRIN_AC_AMT_CR,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'D'
                                        THEN
                                            NVL (TRANADV_INTRD_AC_AMT, 0)
                                        ELSE
                                            0
                                    END)          INTRD_AC_AMT_DR,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'C'
                                        THEN
                                            NVL (TRANADV_INTRD_AC_AMT, 0)
                                        ELSE
                                            0
                                    END)          INTRD_AC_AMT_CR,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'D'
                                        THEN
                                            NVL (TRANADV_CHARGE_AC_AMT, 0)
                                        ELSE
                                            0
                                    END)          CHARGE_AC_AMT_DR,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'C'
                                        THEN
                                            NVL (TRANADV_CHARGE_AC_AMT, 0)
                                        ELSE
                                            0
                                    END)          CHARGE_AC_AMT_CR
                             FROM TRAN2017 TR
                                  LEFT OUTER JOIN TRANADV2017 TA
                                      ON (    TA.TRANADV_ENTITY_NUM =
                                              TR.TRAN_ENTITY_NUM
                                          AND TA.TRANADV_BRN_CODE =
                                              TR.TRAN_BRN_CODE
                                          AND TA.TRANADV_DATE_OF_TRAN =
                                              TR.TRAN_DATE_OF_TRAN
                                          AND TA.TRANADV_BATCH_NUMBER =
                                              TR.TRAN_BATCH_NUMBER
                                          AND TA.TRANADV_BATCH_SL_NUM =
                                              TR.TRAN_BATCH_SL_NUM)
                            WHERE     TR.TRAN_AUTH_ON IS NOT NULL
                                  AND TR.TRAN_INTERNAL_ACNUM IN
                                          (SELECT IACLINK_INTERNAL_ACNUM
                                             FROM ACTUAL_ACCOUNT_UPDATE)
                                  AND TR.TRAN_INTERNAL_ACNUM <> 0
                                  AND TR.TRAN_AMOUNT <> 0)
                           UNION ALL
                           ( ------------------- FOR MONTHS WISE TRANSACTION SELECTION --------------------
                            SELECT /*+ FULL(TA) PARALLEL(TA, DEFAULT,DEFAULT)  PARALLEL(TR, DEFAULT,DEFAULT) */
                                   TR.TRAN_INTERNAL_ACNUM,
                                   TO_CHAR (
                                       ADD_MONTHS (TR.TRAN_DATE_OF_TRAN, 1),
                                       'MM')      TRANSACTION_MONTHS,
                                   TO_CHAR (
                                       ADD_MONTHS (TR.TRAN_DATE_OF_TRAN, 1),
                                       'YYYY')    TRANSACTION_YEAR,
                                   TRAN_BATCH_NUMBER,
                                   TRAN_BATCH_SL_NUM,
                                   TRAN_DB_CR_FLG,
                                   TRAN_AMOUNT,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'D'
                                        THEN
                                            NVL (TRAN_AMOUNT, 0)
                                        ELSE
                                            0
                                    END)          DEBIT_AMOUNT,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'C'
                                        THEN
                                            NVL (TRAN_AMOUNT, 0)
                                        ELSE
                                            0
                                    END)          CREDIT_AMOUNT,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'C' THEN 1
                                        ELSE 0
                                    END)          CREDIT_TRANSACTION,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'D' THEN 1
                                        ELSE 0
                                    END)          DEBIT_TRANSACTION,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'D'
                                        THEN
                                            NVL (TRANADV_PRIN_AC_AMT, 0)
                                        ELSE
                                            0
                                    END)          PRIN_AC_AMT_DR,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'C'
                                        THEN
                                            NVL (TRANADV_PRIN_AC_AMT, 0)
                                        ELSE
                                            0
                                    END)          PRIN_AC_AMT_CR,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'D'
                                        THEN
                                            NVL (TRANADV_INTRD_AC_AMT, 0)
                                        ELSE
                                            0
                                    END)          INTRD_AC_AMT_DR,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'C'
                                        THEN
                                            NVL (TRANADV_INTRD_AC_AMT, 0)
                                        ELSE
                                            0
                                    END)          INTRD_AC_AMT_CR,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'D'
                                        THEN
                                            NVL (TRANADV_CHARGE_AC_AMT, 0)
                                        ELSE
                                            0
                                    END)          CHARGE_AC_AMT_DR,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'C'
                                        THEN
                                            NVL (TRANADV_CHARGE_AC_AMT, 0)
                                        ELSE
                                            0
                                    END)          CHARGE_AC_AMT_CR
                             FROM TRAN2018 TR
                                  LEFT OUTER JOIN TRANADV2018 TA
                                      ON (    TA.TRANADV_ENTITY_NUM =
                                              TR.TRAN_ENTITY_NUM
                                          AND TA.TRANADV_BRN_CODE =
                                              TR.TRAN_BRN_CODE
                                          AND TA.TRANADV_DATE_OF_TRAN =
                                              TR.TRAN_DATE_OF_TRAN
                                          AND TA.TRANADV_BATCH_NUMBER =
                                              TR.TRAN_BATCH_NUMBER
                                          AND TA.TRANADV_BATCH_SL_NUM =
                                              TR.TRAN_BATCH_SL_NUM)
                            WHERE     TR.TRAN_AUTH_ON IS NOT NULL
                                  AND TR.TRAN_INTERNAL_ACNUM IN
                                          (SELECT IACLINK_INTERNAL_ACNUM
                                             FROM ACTUAL_ACCOUNT_UPDATE)
                                  AND TR.TRAN_INTERNAL_ACNUM <> 0
                                  AND TR.TRAN_AMOUNT <> 0)
                           UNION ALL
                           ( ------------------- FOR MONTHS WISE TRANSACTION SELECTION --------------------
                            SELECT /*+ FULL(TA) PARALLEL(TA, DEFAULT,DEFAULT)  PARALLEL(TR, DEFAULT,DEFAULT) */
                                   TR.TRAN_INTERNAL_ACNUM,
                                   TO_CHAR (
                                       ADD_MONTHS (TR.TRAN_DATE_OF_TRAN, 1),
                                       'MM')      TRANSACTION_MONTHS,
                                   TO_CHAR (
                                       ADD_MONTHS (TR.TRAN_DATE_OF_TRAN, 1),
                                       'YYYY')    TRANSACTION_YEAR,
                                   TRAN_BATCH_NUMBER,
                                   TRAN_BATCH_SL_NUM,
                                   TRAN_DB_CR_FLG,
                                   TRAN_AMOUNT,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'D'
                                        THEN
                                            NVL (TRAN_AMOUNT, 0)
                                        ELSE
                                            0
                                    END)          DEBIT_AMOUNT,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'C'
                                        THEN
                                            NVL (TRAN_AMOUNT, 0)
                                        ELSE
                                            0
                                    END)          CREDIT_AMOUNT,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'C' THEN 1
                                        ELSE 0
                                    END)          CREDIT_TRANSACTION,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'D' THEN 1
                                        ELSE 0
                                    END)          DEBIT_TRANSACTION,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'D'
                                        THEN
                                            NVL (TRANADV_PRIN_AC_AMT, 0)
                                        ELSE
                                            0
                                    END)          PRIN_AC_AMT_DR,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'C'
                                        THEN
                                            NVL (TRANADV_PRIN_AC_AMT, 0)
                                        ELSE
                                            0
                                    END)          PRIN_AC_AMT_CR,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'D'
                                        THEN
                                            NVL (TRANADV_INTRD_AC_AMT, 0)
                                        ELSE
                                            0
                                    END)          INTRD_AC_AMT_DR,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'C'
                                        THEN
                                            NVL (TRANADV_INTRD_AC_AMT, 0)
                                        ELSE
                                            0
                                    END)          INTRD_AC_AMT_CR,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'D'
                                        THEN
                                            NVL (TRANADV_CHARGE_AC_AMT, 0)
                                        ELSE
                                            0
                                    END)          CHARGE_AC_AMT_DR,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'C'
                                        THEN
                                            NVL (TRANADV_CHARGE_AC_AMT, 0)
                                        ELSE
                                            0
                                    END)          CHARGE_AC_AMT_CR
                             FROM TRAN2019 TR
                                  LEFT OUTER JOIN TRANADV2019 TA
                                      ON (    TA.TRANADV_ENTITY_NUM =
                                              TR.TRAN_ENTITY_NUM
                                          AND TA.TRANADV_BRN_CODE =
                                              TR.TRAN_BRN_CODE
                                          AND TA.TRANADV_DATE_OF_TRAN =
                                              TR.TRAN_DATE_OF_TRAN
                                          AND TA.TRANADV_BATCH_NUMBER =
                                              TR.TRAN_BATCH_NUMBER
                                          AND TA.TRANADV_BATCH_SL_NUM =
                                              TR.TRAN_BATCH_SL_NUM)
                            WHERE     TR.TRAN_AUTH_ON IS NOT NULL
                                  AND TR.TRAN_INTERNAL_ACNUM IN
                                          (SELECT IACLINK_INTERNAL_ACNUM
                                             FROM ACTUAL_ACCOUNT_UPDATE)
                                  AND TR.TRAN_INTERNAL_ACNUM <> 0
                                  AND TR.TRAN_AMOUNT <> 0)
                           UNION ALL
                           ( ------------------- FOR MONTHS WISE TRANSACTION SELECTION --------------------
                            SELECT /*+ FULL(TA) PARALLEL(TA, DEFAULT,DEFAULT)  PARALLEL(TR, DEFAULT,DEFAULT) */
                                   TR.TRAN_INTERNAL_ACNUM,
                                   TO_CHAR (
                                       ADD_MONTHS (TR.TRAN_DATE_OF_TRAN, 1),
                                       'MM')      TRANSACTION_MONTHS,
                                   TO_CHAR (
                                       ADD_MONTHS (TR.TRAN_DATE_OF_TRAN, 1),
                                       'YYYY')    TRANSACTION_YEAR,
                                   TRAN_BATCH_NUMBER,
                                   TRAN_BATCH_SL_NUM,
                                   TRAN_DB_CR_FLG,
                                   TRAN_AMOUNT,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'D'
                                        THEN
                                            NVL (TRAN_AMOUNT, 0)
                                        ELSE
                                            0
                                    END)          DEBIT_AMOUNT,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'C'
                                        THEN
                                            NVL (TRAN_AMOUNT, 0)
                                        ELSE
                                            0
                                    END)          CREDIT_AMOUNT,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'C' THEN 1
                                        ELSE 0
                                    END)          CREDIT_TRANSACTION,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'D' THEN 1
                                        ELSE 0
                                    END)          DEBIT_TRANSACTION,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'D'
                                        THEN
                                            NVL (TRANADV_PRIN_AC_AMT, 0)
                                        ELSE
                                            0
                                    END)          PRIN_AC_AMT_DR,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'C'
                                        THEN
                                            NVL (TRANADV_PRIN_AC_AMT, 0)
                                        ELSE
                                            0
                                    END)          PRIN_AC_AMT_CR,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'D'
                                        THEN
                                            NVL (TRANADV_INTRD_AC_AMT, 0)
                                        ELSE
                                            0
                                    END)          INTRD_AC_AMT_DR,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'C'
                                        THEN
                                            NVL (TRANADV_INTRD_AC_AMT, 0)
                                        ELSE
                                            0
                                    END)          INTRD_AC_AMT_CR,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'D'
                                        THEN
                                            NVL (TRANADV_CHARGE_AC_AMT, 0)
                                        ELSE
                                            0
                                    END)          CHARGE_AC_AMT_DR,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'C'
                                        THEN
                                            NVL (TRANADV_CHARGE_AC_AMT, 0)
                                        ELSE
                                            0
                                    END)          CHARGE_AC_AMT_CR
                             FROM TRAN2020 TR
                                  LEFT OUTER JOIN TRANADV2020 TA
                                      ON (    TA.TRANADV_ENTITY_NUM =
                                              TR.TRAN_ENTITY_NUM
                                          AND TA.TRANADV_BRN_CODE =
                                              TR.TRAN_BRN_CODE
                                          AND TA.TRANADV_DATE_OF_TRAN =
                                              TR.TRAN_DATE_OF_TRAN
                                          AND TA.TRANADV_BATCH_NUMBER =
                                              TR.TRAN_BATCH_NUMBER
                                          AND TA.TRANADV_BATCH_SL_NUM =
                                              TR.TRAN_BATCH_SL_NUM)
                            WHERE     TR.TRAN_AUTH_ON IS NOT NULL
                                  AND TR.TRAN_INTERNAL_ACNUM IN
                                          (SELECT IACLINK_INTERNAL_ACNUM
                                             FROM ACTUAL_ACCOUNT_UPDATE)
                                  AND TR.TRAN_INTERNAL_ACNUM <> 0
                                  AND TR.TRAN_AMOUNT <> 0)
                           UNION ALL
                           ( ------------------- FOR MONTHS WISE TRANSACTION SELECTION --------------------
                            SELECT /*+ FULL(TA) PARALLEL(TA, DEFAULT,DEFAULT)  PARALLEL(TR, DEFAULT,DEFAULT) */
                                   TR.TRAN_INTERNAL_ACNUM,
                                   TO_CHAR (
                                       ADD_MONTHS (TR.TRAN_DATE_OF_TRAN, 1),
                                       'MM')      TRANSACTION_MONTHS,
                                   TO_CHAR (
                                       ADD_MONTHS (TR.TRAN_DATE_OF_TRAN, 1),
                                       'YYYY')    TRANSACTION_YEAR,
                                   TRAN_BATCH_NUMBER,
                                   TRAN_BATCH_SL_NUM,
                                   TRAN_DB_CR_FLG,
                                   TRAN_AMOUNT,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'D'
                                        THEN
                                            NVL (TRAN_AMOUNT, 0)
                                        ELSE
                                            0
                                    END)          DEBIT_AMOUNT,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'C'
                                        THEN
                                            NVL (TRAN_AMOUNT, 0)
                                        ELSE
                                            0
                                    END)          CREDIT_AMOUNT,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'C' THEN 1
                                        ELSE 0
                                    END)          CREDIT_TRANSACTION,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'D' THEN 1
                                        ELSE 0
                                    END)          DEBIT_TRANSACTION,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'D'
                                        THEN
                                            NVL (TRANADV_PRIN_AC_AMT, 0)
                                        ELSE
                                            0
                                    END)          PRIN_AC_AMT_DR,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'C'
                                        THEN
                                            NVL (TRANADV_PRIN_AC_AMT, 0)
                                        ELSE
                                            0
                                    END)          PRIN_AC_AMT_CR,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'D'
                                        THEN
                                            NVL (TRANADV_INTRD_AC_AMT, 0)
                                        ELSE
                                            0
                                    END)          INTRD_AC_AMT_DR,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'C'
                                        THEN
                                            NVL (TRANADV_INTRD_AC_AMT, 0)
                                        ELSE
                                            0
                                    END)          INTRD_AC_AMT_CR,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'D'
                                        THEN
                                            NVL (TRANADV_CHARGE_AC_AMT, 0)
                                        ELSE
                                            0
                                    END)          CHARGE_AC_AMT_DR,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'C'
                                        THEN
                                            NVL (TRANADV_CHARGE_AC_AMT, 0)
                                        ELSE
                                            0
                                    END)          CHARGE_AC_AMT_CR
                             FROM TRAN2021 TR
                                  LEFT OUTER JOIN TRANADV2021 TA
                                      ON (    TA.TRANADV_ENTITY_NUM =
                                              TR.TRAN_ENTITY_NUM
                                          AND TA.TRANADV_BRN_CODE =
                                              TR.TRAN_BRN_CODE
                                          AND TA.TRANADV_DATE_OF_TRAN =
                                              TR.TRAN_DATE_OF_TRAN
                                          AND TA.TRANADV_BATCH_NUMBER =
                                              TR.TRAN_BATCH_NUMBER
                                          AND TA.TRANADV_BATCH_SL_NUM =
                                              TR.TRAN_BATCH_SL_NUM)
                            WHERE     TR.TRAN_AUTH_ON IS NOT NULL
                                  AND TR.TRAN_INTERNAL_ACNUM IN
                                          (SELECT IACLINK_INTERNAL_ACNUM
                                             FROM ACTUAL_ACCOUNT_UPDATE)
                                  AND TR.TRAN_INTERNAL_ACNUM <> 0
                                  AND TR.TRAN_AMOUNT <> 0)
                           UNION ALL
                           ( ------------------- FOR MONTHS WISE TRANSACTION SELECTION --------------------
                            SELECT /*+ FULL(TA) PARALLEL(TA, DEFAULT,DEFAULT)  PARALLEL(TR, DEFAULT,DEFAULT) */
                                   TR.TRAN_INTERNAL_ACNUM,
                                   TO_CHAR (
                                       ADD_MONTHS (TR.TRAN_DATE_OF_TRAN, 1),
                                       'MM')      TRANSACTION_MONTHS,
                                   TO_CHAR (
                                       ADD_MONTHS (TR.TRAN_DATE_OF_TRAN, 1),
                                       'YYYY')    TRANSACTION_YEAR,
                                   TRAN_BATCH_NUMBER,
                                   TRAN_BATCH_SL_NUM,
                                   TRAN_DB_CR_FLG,
                                   TRAN_AMOUNT,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'D'
                                        THEN
                                            NVL (TRAN_AMOUNT, 0)
                                        ELSE
                                            0
                                    END)          DEBIT_AMOUNT,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'C'
                                        THEN
                                            NVL (TRAN_AMOUNT, 0)
                                        ELSE
                                            0
                                    END)          CREDIT_AMOUNT,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'C' THEN 1
                                        ELSE 0
                                    END)          CREDIT_TRANSACTION,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'D' THEN 1
                                        ELSE 0
                                    END)          DEBIT_TRANSACTION,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'D'
                                        THEN
                                            NVL (TRANADV_PRIN_AC_AMT, 0)
                                        ELSE
                                            0
                                    END)          PRIN_AC_AMT_DR,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'C'
                                        THEN
                                            NVL (TRANADV_PRIN_AC_AMT, 0)
                                        ELSE
                                            0
                                    END)          PRIN_AC_AMT_CR,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'D'
                                        THEN
                                            NVL (TRANADV_INTRD_AC_AMT, 0)
                                        ELSE
                                            0
                                    END)          INTRD_AC_AMT_DR,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'C'
                                        THEN
                                            NVL (TRANADV_INTRD_AC_AMT, 0)
                                        ELSE
                                            0
                                    END)          INTRD_AC_AMT_CR,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'D'
                                        THEN
                                            NVL (TRANADV_CHARGE_AC_AMT, 0)
                                        ELSE
                                            0
                                    END)          CHARGE_AC_AMT_DR,
                                   (CASE
                                        WHEN TRAN_DB_CR_FLG = 'C'
                                        THEN
                                            NVL (TRANADV_CHARGE_AC_AMT, 0)
                                        ELSE
                                            0
                                    END)          CHARGE_AC_AMT_CR
                             FROM TRAN2022 TR
                                  LEFT OUTER JOIN TRANADV2022 TA
                                      ON (    TA.TRANADV_ENTITY_NUM =
                                              TR.TRAN_ENTITY_NUM
                                          AND TA.TRANADV_BRN_CODE =
                                              TR.TRAN_BRN_CODE
                                          AND TA.TRANADV_DATE_OF_TRAN =
                                              TR.TRAN_DATE_OF_TRAN
                                          AND TA.TRANADV_BATCH_NUMBER =
                                              TR.TRAN_BATCH_NUMBER
                                          AND TA.TRANADV_BATCH_SL_NUM =
                                              TR.TRAN_BATCH_SL_NUM)
                            WHERE     TR.TRAN_AUTH_ON IS NOT NULL
                                  AND TR.TRAN_INTERNAL_ACNUM IN
                                          (SELECT IACLINK_INTERNAL_ACNUM
                                             FROM ACTUAL_ACCOUNT_UPDATE)
                                  AND TR.TRAN_INTERNAL_ACNUM <> 0
                                  AND TR.TRAN_AMOUNT <> 0)
                           UNION ALL
                           ------------------- FOR MONTHS WISE TRANSACTION SELECTION --------------------
                           SELECT /*+ FULL(TA) PARALLEL(TA, DEFAULT,DEFAULT)  PARALLEL(TR, DEFAULT,DEFAULT) */
                                  TR.TRAN_INTERNAL_ACNUM,
                                  TO_CHAR (
                                      ADD_MONTHS (TR.TRAN_DATE_OF_TRAN, 1),
                                      'MM')      TRANSACTION_MONTHS,
                                  TO_CHAR (
                                      ADD_MONTHS (TR.TRAN_DATE_OF_TRAN, 1),
                                      'YYYY')    TRANSACTION_YEAR,
                                  TRAN_BATCH_NUMBER,
                                  TRAN_BATCH_SL_NUM,
                                  TRAN_DB_CR_FLG,
                                  TRAN_AMOUNT,
                                  (CASE
                                       WHEN TRAN_DB_CR_FLG = 'D'
                                       THEN
                                           NVL (TRAN_AMOUNT, 0)
                                       ELSE
                                           0
                                   END)          DEBIT_AMOUNT,
                                  (CASE
                                       WHEN TRAN_DB_CR_FLG = 'C'
                                       THEN
                                           NVL (TRAN_AMOUNT, 0)
                                       ELSE
                                           0
                                   END)          CREDIT_AMOUNT,
                                  (CASE
                                       WHEN TRAN_DB_CR_FLG = 'C' THEN 1
                                       ELSE 0
                                   END)          CREDIT_TRANSACTION,
                                  (CASE
                                       WHEN TRAN_DB_CR_FLG = 'D' THEN 1
                                       ELSE 0
                                   END)          DEBIT_TRANSACTION,
                                  (CASE
                                       WHEN TRAN_DB_CR_FLG = 'D'
                                       THEN
                                           NVL (TRANADV_PRIN_AC_AMT, 0)
                                       ELSE
                                           0
                                   END)          PRIN_AC_AMT_DR,
                                  (CASE
                                       WHEN TRAN_DB_CR_FLG = 'C'
                                       THEN
                                           NVL (TRANADV_PRIN_AC_AMT, 0)
                                       ELSE
                                           0
                                   END)          PRIN_AC_AMT_CR,
                                  (CASE
                                       WHEN TRAN_DB_CR_FLG = 'D'
                                       THEN
                                           NVL (TRANADV_INTRD_AC_AMT, 0)
                                       ELSE
                                           0
                                   END)          INTRD_AC_AMT_DR,
                                  (CASE
                                       WHEN TRAN_DB_CR_FLG = 'C'
                                       THEN
                                           NVL (TRANADV_INTRD_AC_AMT, 0)
                                       ELSE
                                           0
                                   END)          INTRD_AC_AMT_CR,
                                  (CASE
                                       WHEN TRAN_DB_CR_FLG = 'D'
                                       THEN
                                           NVL (TRANADV_CHARGE_AC_AMT, 0)
                                       ELSE
                                           0
                                   END)          CHARGE_AC_AMT_DR,
                                  (CASE
                                       WHEN TRAN_DB_CR_FLG = 'C'
                                       THEN
                                           NVL (TRANADV_CHARGE_AC_AMT, 0)
                                       ELSE
                                           0
                                   END)          CHARGE_AC_AMT_CR
                             FROM TRAN2023 TR
                                  LEFT OUTER JOIN TRANADV2023 TA
                                      ON (    TA.TRANADV_ENTITY_NUM =
                                              TR.TRAN_ENTITY_NUM
                                          AND TA.TRANADV_BRN_CODE =
                                              TR.TRAN_BRN_CODE
                                          AND TA.TRANADV_DATE_OF_TRAN =
                                              TR.TRAN_DATE_OF_TRAN
                                          AND TA.TRANADV_BATCH_NUMBER =
                                              TR.TRAN_BATCH_NUMBER
                                          AND TA.TRANADV_BATCH_SL_NUM =
                                              TR.TRAN_BATCH_SL_NUM)
                            WHERE     TR.TRAN_AUTH_ON IS NOT NULL
                                  AND TR.TRAN_INTERNAL_ACNUM IN
                                          (SELECT IACLINK_INTERNAL_ACNUM
                                             FROM ACTUAL_ACCOUNT_UPDATE)
                                  AND TR.TRAN_INTERNAL_ACNUM <> 0
                                  AND TR.TRAN_AMOUNT <> 0)
                 GROUP BY TRAN_INTERNAL_ACNUM,
                          TRANSACTION_YEAR,
                          TRANSACTION_MONTHS)
        SELECT INT_AC_NO,
               TRANSACTION_YEAR,
               TRANSACTION_MONTHS,
               SUM (MW_CR_SUM)
                   OVER (
                       PARTITION BY INT_AC_NO
                       ORDER BY
                           INT_AC_NO, TRANSACTION_YEAR, TRANSACTION_MONTHS)
                   MW_CR_SUM,
               SUM (MW_DR_SUM)
                   OVER (
                       PARTITION BY INT_AC_NO
                       ORDER BY
                           INT_AC_NO, TRANSACTION_YEAR, TRANSACTION_MONTHS)
                   MW_DR_SUM,
               ROW_NUMBER ()
                   OVER (
                       PARTITION BY INT_AC_NO
                       ORDER BY
                           INT_AC_NO, TRANSACTION_YEAR, TRANSACTION_MONTHS)
                   SL
          FROM (SELECT TRAN_INTERNAL_ACNUM             INT_AC_NO,
                       TRANSACTION_YEAR,
                       TRANSACTION_MONTHS,
                       MONTHS_WISE_CREDIT_TRAN         MW_NO_OF_CR,
                       MONTHS_WISE_DEBIT_TRAN          MW_NO_OF_DR,
                       CREDIT_TRAN_SUMMATION           TOT_NO_OF_CR,
                       DEBIT_TRAN_SUMMATION            TOT_NO_OF_DR,
                       MONTHS_WISE_CREDIT_SUM          MW_CR_SUM,
                       MONTHS_WISE_DEBIT_SUM           MW_DR_SUM,
                       --CREDIT_OPENING_BALANCE, DEBIT_OPENING_BALANCE,
                       NVL (
                           LAG (ACCOUNT_CURRENT_BALANCE)
                               OVER (
                                   PARTITION BY TRAN_INTERNAL_ACNUM
                                   ORDER BY
                                       TRAN_INTERNAL_ACNUM,
                                       TRANSACTION_YEAR,
                                       TRANSACTION_MONTHS),
                           0)                          MW_OP_BAL,
                       ACCOUNT_CURRENT_BALANCE         MW_CLS_BAL,
                       ---------------------  LOAN ACCOUNT PRENCIPAL BALANCE CALCULATION ---------------
                       MONTHS_WISE_PRIN_AC_AMT_CR      MW_PRIN_CR_SUM,
                       MONTHS_WISE_PRIN_AC_AMT_DR      MW_PRIN_DR_SUM,
                       --CREDIT_OPENING_PRIN_BALANCE, DEBIT_OPENING_PRIN_BALANCE,
                       NVL (
                           LAG (PRIN_OUTSTANDING)
                               OVER (
                                   PARTITION BY TRAN_INTERNAL_ACNUM
                                   ORDER BY
                                       TRAN_INTERNAL_ACNUM,
                                       TRANSACTION_YEAR,
                                       TRANSACTION_MONTHS),
                           0)                          MW_PRIN_OP_BAL,
                       PRIN_OUTSTANDING                MW_PRIN_CLS_BAL,
                       ---------------------  LOAN ACCOUNT INTEREST BALANCE CALCULATION ---------------
                       MONTHS_WISE_INTRD_AC_AMT_CR     MW_INT_CR_SUM,
                       MONTHS_WISE_INTRD_AC_AMT_DR     MW_INT_DR_SUM,
                       -- CREDIT_OPENING_INTRD_BALANCE, DEBIT_OPENING_INTRD_BALANCE,
                       NVL (
                           LAG (INTRD_OUTSTANDING)
                               OVER (
                                   PARTITION BY TRAN_INTERNAL_ACNUM
                                   ORDER BY
                                       TRAN_INTERNAL_ACNUM,
                                       TRANSACTION_YEAR,
                                       TRANSACTION_MONTHS),
                           0)                          MW_INT_OP_BAL,
                       INTRD_OUTSTANDING               MW_INT_CLS_BAL,
                       ---------------------  LOAN ACCOUNT CHARGE BALANCE CALCULATION ---------------
                       MONTHS_WISE_CHARGE_AC_AMT_CR    MW_CHG_CR_SUM,
                       MONTHS_WISE_CHARGE_AC_AMT_DR    MW_CHG_DR_SUM,
                       --CREDIT_OPENING_CHARGE_BALANCE, DEBIT_OPENING_CHARGE_BALANCE,
                       NVL (
                           LAG (INTRD_OUTSTANDING)
                               OVER (
                                   PARTITION BY TRAN_INTERNAL_ACNUM
                                   ORDER BY
                                       TRAN_INTERNAL_ACNUM,
                                       TRANSACTION_YEAR,
                                       TRANSACTION_MONTHS),
                           0)                          MW_CHG_OP_BAL,
                       CHARGE_OUTSTANDING              MW_CHG_CLS_BAL
                  FROM ( ------------------ START SELECT QUERY FROM MONTHS WISE ACCOUNT BALANCE ---------------------
                          SELECT TRAN_INTERNAL_ACNUM,
                                 TRANSACTION_YEAR,
                                 TRANSACTION_MONTHS,
                                 MONTHS_WISE_CREDIT_TRAN,
                                 MONTHS_WISE_DEBIT_TRAN,
                                 SUM (MONTHS_WISE_CREDIT_TRAN)
                                     OVER (
                                         PARTITION BY TRAN_INTERNAL_ACNUM
                                         ORDER BY
                                             TRAN_INTERNAL_ACNUM,
                                             TRANSACTION_YEAR,
                                             TRANSACTION_MONTHS)
                                     CREDIT_TRAN_SUMMATION,
                                 SUM (MONTHS_WISE_DEBIT_TRAN)
                                     OVER (
                                         PARTITION BY TRAN_INTERNAL_ACNUM
                                         ORDER BY
                                             TRAN_INTERNAL_ACNUM,
                                             TRANSACTION_YEAR,
                                             TRANSACTION_MONTHS)
                                     DEBIT_TRAN_SUMMATION,
                                 MONTHS_WISE_CREDIT_SUM,
                                 MONTHS_WISE_DEBIT_SUM,
                                 SUM (MONTHS_WISE_CREDIT_SUM)
                                     OVER (
                                         PARTITION BY TRAN_INTERNAL_ACNUM
                                         ORDER BY
                                             TRAN_INTERNAL_ACNUM,
                                             TRANSACTION_YEAR,
                                             TRANSACTION_MONTHS)
                                     CREDIT_OPENING_BALANCE,
                                 SUM (MONTHS_WISE_DEBIT_SUM)
                                     OVER (
                                         PARTITION BY TRAN_INTERNAL_ACNUM
                                         ORDER BY
                                             TRAN_INTERNAL_ACNUM,
                                             TRANSACTION_YEAR,
                                             TRANSACTION_MONTHS)
                                     DEBIT_OPENING_BALANCE,
                                 SUM (
                                       MONTHS_WISE_CREDIT_SUM
                                     - MONTHS_WISE_DEBIT_SUM)
                                     OVER (
                                         PARTITION BY TRAN_INTERNAL_ACNUM
                                         ORDER BY
                                             TRAN_INTERNAL_ACNUM,
                                             TRANSACTION_YEAR,
                                             TRANSACTION_MONTHS)
                                     ACCOUNT_CURRENT_BALANCE,
                                 ------------------ START CALCULATION FOR LOAN TYPES OF ACCOUNT --------------------------
                                 ------------------ FOR PRENCIPAL TRANSACTION AMOUNT -------------------------------------
                                 MONTHS_WISE_PRIN_AC_AMT_CR,
                                 MONTHS_WISE_PRIN_AC_AMT_DR,
                                 SUM (MONTHS_WISE_PRIN_AC_AMT_CR)
                                     OVER (
                                         PARTITION BY TRAN_INTERNAL_ACNUM
                                         ORDER BY
                                             TRAN_INTERNAL_ACNUM,
                                             TRANSACTION_YEAR,
                                             TRANSACTION_MONTHS)
                                     CREDIT_OPENING_PRIN_BALANCE,
                                 SUM (MONTHS_WISE_PRIN_AC_AMT_DR)
                                     OVER (
                                         PARTITION BY TRAN_INTERNAL_ACNUM
                                         ORDER BY
                                             TRAN_INTERNAL_ACNUM,
                                             TRANSACTION_YEAR,
                                             TRANSACTION_MONTHS)
                                     DEBIT_OPENING_PRIN_BALANCE,
                                 SUM (
                                       MONTHS_WISE_PRIN_AC_AMT_CR
                                     - MONTHS_WISE_PRIN_AC_AMT_DR)
                                     OVER (
                                         PARTITION BY TRAN_INTERNAL_ACNUM
                                         ORDER BY
                                             TRAN_INTERNAL_ACNUM,
                                             TRANSACTION_YEAR,
                                             TRANSACTION_MONTHS)
                                     PRIN_OUTSTANDING,
                                 ------------------ FOR INTEREST TRANSACTION AMOUNT -------------------------------------
                                 MONTHS_WISE_INTRD_AC_AMT_CR,
                                 MONTHS_WISE_INTRD_AC_AMT_DR,
                                 SUM (MONTHS_WISE_INTRD_AC_AMT_CR)
                                     OVER (
                                         PARTITION BY TRAN_INTERNAL_ACNUM
                                         ORDER BY
                                             TRAN_INTERNAL_ACNUM,
                                             TRANSACTION_YEAR,
                                             TRANSACTION_MONTHS)
                                     CREDIT_OPENING_INTRD_BALANCE,
                                 SUM (MONTHS_WISE_INTRD_AC_AMT_DR)
                                     OVER (
                                         PARTITION BY TRAN_INTERNAL_ACNUM
                                         ORDER BY
                                             TRAN_INTERNAL_ACNUM,
                                             TRANSACTION_YEAR,
                                             TRANSACTION_MONTHS)
                                     DEBIT_OPENING_INTRD_BALANCE,
                                 SUM (
                                       MONTHS_WISE_INTRD_AC_AMT_CR
                                     - MONTHS_WISE_INTRD_AC_AMT_DR)
                                     OVER (
                                         PARTITION BY TRAN_INTERNAL_ACNUM
                                         ORDER BY
                                             TRAN_INTERNAL_ACNUM,
                                             TRANSACTION_YEAR,
                                             TRANSACTION_MONTHS)
                                     INTRD_OUTSTANDING,
                                 ------------------ FOR CHARGE TRANSACTION AMOUNT -------------------------------------
                                 MONTHS_WISE_CHARGE_AC_AMT_CR,
                                 MONTHS_WISE_CHARGE_AC_AMT_DR,
                                 SUM (MONTHS_WISE_CHARGE_AC_AMT_CR)
                                     OVER (
                                         PARTITION BY TRAN_INTERNAL_ACNUM
                                         ORDER BY
                                             TRAN_INTERNAL_ACNUM,
                                             TRANSACTION_YEAR,
                                             TRANSACTION_MONTHS)
                                     CREDIT_OPENING_CHARGE_BALANCE,
                                 SUM (MONTHS_WISE_CHARGE_AC_AMT_DR)
                                     OVER (
                                         PARTITION BY TRAN_INTERNAL_ACNUM
                                         ORDER BY
                                             TRAN_INTERNAL_ACNUM,
                                             TRANSACTION_YEAR,
                                             TRANSACTION_MONTHS)
                                     DEBIT_OPENING_CHARGE_BALANCE,
                                 SUM (
                                       MONTHS_WISE_CHARGE_AC_AMT_CR
                                     - MONTHS_WISE_CHARGE_AC_AMT_DR)
                                     OVER (
                                         PARTITION BY TRAN_INTERNAL_ACNUM
                                         ORDER BY
                                             TRAN_INTERNAL_ACNUM,
                                             TRANSACTION_YEAR,
                                             TRANSACTION_MONTHS)
                                     CHARGE_OUTSTANDING
                            FROM MONTHS_WISE_AC_BALANCE
                        ORDER BY TRAN_INTERNAL_ACNUM,
                                 TRANSACTION_YEAR,
                                 TRANSACTION_MONTHS));


    SELECT MN_CURR_BUSINESS_DATE INTO V_CBD FROM MAINCONT;

    V_CBD_YEAR := TO_CHAR (V_CBD, 'YYYY');
    V_CBD_MONTH := TO_CHAR (V_CBD, 'MM');

    FOR IDX IN (SELECT *
                  FROM MONTHS_WISE_AC_BALANCE
                 WHERE SL = 1)
    LOOP
        V_YEAR := IDX.TRANSACTION_YEAR;
        V_MONTH := IDX.TRANSACTION_MONTHS;
        V_START_DATE :=
            TO_DATE ('01-' || V_MONTH || '-' || V_YEAR, 'DD-MM-YYYY');
        V_END_DATE :=
            TO_DATE ('01-' || V_CBD_MONTH || '-' || V_CBD_YEAR, 'DD-MM-YYYY');

        WHILE (V_START_DATE <= V_END_DATE)
        LOOP
            SELECT COUNT (*)
              INTO V_COUNT
              FROM MONTHS_WISE_AC_BALANCE
             WHERE     INT_AC_NO = IDX.INT_AC_NO
                   AND TRANSACTION_YEAR = TO_CHAR (V_START_DATE, 'YYYY')
                   AND TRANSACTION_MONTHS = TO_CHAR (V_START_DATE, 'MM');

            IF V_COUNT = 0
            THEN
                INSERT INTO MONTHS_WISE_AC_BALANCE (INT_AC_NO,
                                                    TRANSACTION_YEAR,
                                                    TRANSACTION_MONTHS,
                                                    MW_CR_SUM,
                                                    MW_DR_SUM,
                                                    SL)
                         VALUES (
                                    IDX.INT_AC_NO,
                                    TO_CHAR (V_START_DATE, 'YYYY'),
                                    TO_CHAR (V_START_DATE, 'MM'),
                                    (SELECT MW_CR_SUM
                                      FROM MONTHS_WISE_AC_BALANCE
                                     WHERE     INT_AC_NO = IDX.INT_AC_NO
                                           AND TRANSACTION_YEAR =
                                               TO_CHAR (
                                                   ADD_MONTHS (V_START_DATE,
                                                               -1),
                                                   'YYYY')
                                           AND TRANSACTION_MONTHS =
                                               TO_CHAR (
                                                   ADD_MONTHS (V_START_DATE,
                                                               -1),
                                                   'MM')),
                                    (SELECT MW_DR_SUM
                                      FROM MONTHS_WISE_AC_BALANCE
                                     WHERE     INT_AC_NO = IDX.INT_AC_NO
                                           AND TRANSACTION_YEAR =
                                               TO_CHAR (
                                                   ADD_MONTHS (V_START_DATE,
                                                               -1),
                                                   'YYYY')
                                           AND TRANSACTION_MONTHS =
                                               TO_CHAR (
                                                   ADD_MONTHS (V_START_DATE,
                                                               -1),
                                                   'MM')),
                                    0);

                COMMIT;
            END IF;

            SELECT ADD_MONTHS (V_START_DATE, 1) INTO V_START_DATE FROM DUAL;
        END LOOP;
    END LOOP;
END SP_MONTHWISE_DR_CR_SUM;
/

/*<TOAD_FILE_CHUNK>*/
EXEC SP_MONTHWISE_DR_CR_SUM;





BEGIN
   FOR IDX IN (  SELECT *
                   FROM MONTHS_WISE_AC_BALANCE
               ORDER BY INT_AC_NO, TRANSACTION_YEAR, TRANSACTION_MONTHS)
   LOOP
      UPDATE ACNTBBAL
         SET ACNTBBAL_AC_OPNG_DB_SUM = IDX.MW_DR_SUM,
             ACNTBBAL_AC_OPNG_CR_SUM = IDX.MW_CR_SUM,
             ACNTBBAL_BC_OPNG_DB_SUM = IDX.MW_DR_SUM,
             ACNTBBAL_BC_OPNG_CR_SUM = IDX.MW_CR_SUM
       WHERE     ACNTBBAL_ENTITY_NUM = 1
             AND ACNTBBAL_INTERNAL_ACNUM = IDX.INT_AC_NO
             AND ACNTBBAL_YEAR = IDX.TRANSACTION_YEAR 
             AND ACNTBBAL_MONTH = IDX.TRANSACTION_MONTHS;
   END LOOP;
END;



MERGE INTO ACNTBBAL G1
     USING (  SELECT INT_AC_NO, TO_NUMBER(TRANSACTION_YEAR) TRANSACTION_YEAR, TO_NUMBER(TRANSACTION_MONTHS) TRANSACTION_MONTHS, MW_CR_SUM, MW_DR_SUM
                FROM MONTHS_WISE_AC_BALANCE WHERE TO_NUMBER(TRANSACTION_YEAR) >=2019
            ORDER BY INT_AC_NO, TO_NUMBER(TRANSACTION_YEAR), TO_NUMBER(TRANSACTION_MONTHS)) G2
        ON (    G1.ACNTBBAL_ENTITY_NUM = 1
            AND G1.ACNTBBAL_INTERNAL_ACNUM = G2.INT_AC_NO
            AND G1.ACNTBBAL_CURR_CODE = 'BDT'
            AND G1.ACNTBBAL_YEAR = G2.TRANSACTION_YEAR
            AND G1.ACNTBBAL_MONTH = G2.TRANSACTION_MONTHS)
WHEN MATCHED
THEN
   UPDATE SET G1.ACNTBBAL_AC_OPNG_DB_SUM = G2.MW_DR_SUM,
              G1.ACNTBBAL_AC_OPNG_CR_SUM = G2.MW_CR_SUM,
              G1.ACNTBBAL_BC_OPNG_DB_SUM = G2.MW_DR_SUM,
              G1.ACNTBBAL_BC_OPNG_CR_SUM = G2.MW_CR_SUM
WHEN NOT MATCHED
THEN
   INSERT     (ACNTBBAL_ENTITY_NUM,
               ACNTBBAL_INTERNAL_ACNUM,
               ACNTBBAL_CURR_CODE,
               ACNTBBAL_YEAR,
               ACNTBBAL_MONTH,
               ACNTBBAL_AC_OPNG_DB_SUM,
               ACNTBBAL_AC_OPNG_CR_SUM,
               ACNTBBAL_BC_OPNG_DB_SUM,
               ACNTBBAL_BC_OPNG_CR_SUM,
               ACNTBBAL_OPBAL_ENTD_BY,
               ACNTBBAL_OPBAL_ENTD_ON,
               ACNTBBAL_OPBAL_LAST_MOD_BY,
               ACNTBBAL_AC_OPNG_FWDVAL_DB_SUM,
               ACNTBBAL_BC_OPNG_FWDVAL_DB_SUM,
               ACNTBBAL_AC_OPNG_FWDVAL_CR_SUM,
               ACNTBBAL_BC_OPNG_FWDVAL_CR_SUM,
               ACNTBBAL_AC_OPNG_CLG_CR_SUM,
               ACNTBBAL_AC_OPNG_CLG_DB_SUM,
               ACNTBBAL_BC_OPNG_CLG_CR_SUM,
               ACNTBBAL_BC_OPNG_CLG_DB_SUM)
       VALUES (1,
               G2.INT_AC_NO,
               'BDT',
               G2.TRANSACTION_YEAR,
               G2.TRANSACTION_MONTHS,
               G2.MW_DR_SUM,
               G2.MW_CR_SUM,
               G2.MW_DR_SUM,
               G2.MW_CR_SUM,
               'INTELECT',
               SYSDATE,
               ' ',
               0,
               0,
               0,
               0,
               0,
               0,
               0,
               0);
			   
			   
			   
COMMIT;

