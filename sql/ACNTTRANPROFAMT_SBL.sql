CREATE TABLE ACNTTRANPROFAMT
(
  ACNTTRANPAMT_ENTITY_NUM         NUMBER(4)     NOT NULL,
  ACNTTRANPAMT_BRN_CODE           NUMBER(6)     NOT NULL,
  ACNTTRANPAMT_INTERNAL_ACNUM     NUMBER(14)    NOT NULL,
  ACNTTRANPAMT_MONTH              VARCHAR2(8 BYTE) NOT NULL,
  ACNTTRANPAMT_PROCESS_YEAR       NUMBER(6)     NOT NULL,
  ACNTTRANPAMT_TRANSFER_DB_AMT    NUMBER(18,3),
  ACNTTRANPAMT_TRANSFER_DB_COUNT  NUMBER(8),
  ACNTTRANPAMT_TRANSFER_CR_AMT    NUMBER(18,3),
  ACNTTRANPAMT_TRANSFER_CR_COUNT  NUMBER(8),
  ACNTTRANPAMT_CASH_DB_AMT        NUMBER(18,3),
  ACNTTRANPAMT_CASH_DB_COUNT      NUMBER(8),
  ACNTTRANPAMT_CASH_CR_AMT        NUMBER(18,3),
  ACNTTRANPAMT_CASH_CR_COUNT      NUMBER(8),
  ACNTTRANPAMT_CLEARING_DB_AMT    NUMBER(18,3),
  ACNTTRANPAMT_CLEARING_DB_COUNT  NUMBER(8),
  ACNTTRANPAMT_CLEARING_CR_AMT    NUMBER(18,3),
  ACNTTRANPAMT_CLEARING_CR_COUNT  NUMBER(8),
  ACNTTRANPAMT_TRADE_DB_AMT       NUMBER(18,3),
  ACNTTRANPAMT_TRADE_DB_COUNT     NUMBER(8),
  ACNTTRANPAMT_TRADE_CR_AMT       NUMBER(18,3),
  ACNTTRANPAMT_TRADE_CR_COUNT     NUMBER(8),
  ACNTTRANPAMT_ENTD_BY            VARCHAR2(8 BYTE),
  ACNTTRANPAMT_ENTD_ON            DATE,
  ACNTTRANPAMT_LAST_MOD_BY        VARCHAR2(8 BYTE),
  ACNTTRANPAMT_LAST_MOD_ON        DATE,
  ACNTTRANPAMT_AUTH_BY            VARCHAR2(8 BYTE),
  ACNTTRANPAMT_AUTH_ON            DATE,
  ACNTTRANPAMT_REJ_BY             VARCHAR2(8 BYTE),
  ACNTTRANPAMT_REJ_ON             DATE
)