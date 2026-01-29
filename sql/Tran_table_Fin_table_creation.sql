/*Creating the tables those have the impact of financial year.*/

ALTER TABLE ACCASHPOST2021
 DROP PRIMARY KEY CASCADE;

DROP TABLE ACCASHPOST2021 CASCADE CONSTRAINTS;

CREATE TABLE ACCASHPOST2021
(
  ACCASHPOST_ENTITY_NUM        NUMBER(4)        NOT NULL,
  ACCASHPOST_BRN_CODE          NUMBER(6)        NOT NULL,
  ACCASHPOST_CURR_CODE         VARCHAR2(3 BYTE) NOT NULL,
  ACCASHPOST_DATE              DATE             NOT NULL,
  ACCASHPOST_TOT_TAX_FOR_DAY   NUMBER(18,3),
  ACCASHPOST_NUM_TAXED_TRANS   NUMBER(5),
  ACCASHPOST_TOT_TAX_CALC_AMT  NUMBER(18,3),
  ACCASHPOST_TOT_UNTAX_TRANS   NUMBER(5),
  ACCASHPOST_TOT_UNTAX_AMT     NUMBER(18,3),
  ACCASHSUM_POST_BY            VARCHAR2(8 BYTE),
  ACCASHSUM_POST_ON            DATE,
  POST_TRAN_BRN                NUMBER(6),
  POST_TRAN_DATE               DATE,
  POST_TRAN_BATCH_NUM          NUMBER(7)
)
TABLESPACE DATA
RESULT_CACHE (MODE DEFAULT)
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            MAXSIZE          UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      DEFAULT
            CELL_FLASH_CACHE DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING;


ALTER TABLE ACCASHSUM2021
 DROP PRIMARY KEY CASCADE;

DROP TABLE ACCASHSUM2021 CASCADE CONSTRAINTS;

CREATE TABLE ACCASHSUM2021
(
  ACCASHSUM_ENTITY_NUM         NUMBER(4)        NOT NULL,
  ACCASHSUM_BRN_CODE           NUMBER(6)        NOT NULL,
  ACCASHSUM_ACNT_NUM           NUMBER(14)       NOT NULL,
  ACCASHSUM_TRAN_DATE          DATE             NOT NULL,
  ACCASHSUM_TOT_CASH_WDRAW     NUMBER(18,3)     DEFAULT 0,
  ACCASHSUM_TOT_NUM_TRANS      NUMBER(5)        DEFAULT 0,
  ACCASHSUM_BCTT_TAX_CALC_AMT  NUMBER(18,3)     DEFAULT 0,
  ACCASHSUM_BCTT_TAX_RATE      NUMBER(4,2)      DEFAULT 0,
  ACCASHSUM_BCTT_CUT_OFF_AMT   NUMBER(18,3)     DEFAULT 0,
  ACCASHSUM_ENTD_BY            VARCHAR2(8 BYTE) NOT NULL,
  ACCASHSUM_ENTD_ON            DATE
)
TABLESPACE DATA
RESULT_CACHE (MODE DEFAULT)
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            MAXSIZE          UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      DEFAULT
            CELL_FLASH_CACHE DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING;


DROP TABLE AUDITLOG2021 CASCADE CONSTRAINTS;

CREATE TABLE AUDITLOG2021
(
  AUDITLOG_ENTITY_NUM  NUMBER(4)                NOT NULL,
  ATLOG_BRN_CODE       NUMBER(6)                NOT NULL,
  ATLOG_DATETIME       DATE                     NOT NULL,
  ATLOG_LOG_SL         NUMBER(8)                NOT NULL,
  ATLOG_DTL_SL         NUMBER(6)                NOT NULL,
  ATLOG_FORM_NAME      VARCHAR2(40 BYTE),
  ATLOG_USER_ID        VARCHAR2(8 BYTE),
  ATLOG_IP             VARCHAR2(15 BYTE),
  ATLOG_ACTION         CHAR(1 BYTE),
  ATLOG_TABLE_NAME     VARCHAR2(30 BYTE),
  ATLOG_PK             VARCHAR2(100 BYTE),
  ATLOG_IMAGE_TYPE     CHAR(1 BYTE),
  ATLOG_DESC           VARCHAR2(1000 BYTE),
  ATLOG_DATA           VARCHAR2(4000 BYTE)
)
TABLESPACE DATA
RESULT_CACHE (MODE DEFAULT)
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            MAXSIZE          UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      DEFAULT
            CELL_FLASH_CACHE DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING;


ALTER TABLE CTRAN2021
 DROP PRIMARY KEY CASCADE;

DROP TABLE CTRAN2021 CASCADE CONSTRAINTS;

CREATE TABLE CTRAN2021
(
  CTRAN_ENTITY_NUM        NUMBER(4)             NOT NULL,
  CT_BRN_CODE             NUMBER(6)             NOT NULL,
  CT_TRAN_DATE            DATE                  NOT NULL,
  CT_CASHIER_ID           VARCHAR2(8 BYTE)      NOT NULL,
  CT_DAY_SL               NUMBER(5)             NOT NULL,
  CT_TYPE_OF_ENTRY        CHAR(1 BYTE),
  CT_REC_PAYMENT          CHAR(1 BYTE),
  CT_TOKEN_NUMBER         NUMBER(5)             DEFAULT 0,
  CT_TRAN_BAT_NUMBER      NUMBER(7)             DEFAULT 0,
  CT_TRAN_BAT_SL_NUM      NUMBER(6)             DEFAULT 0,
  CT_TRAN_CODE            VARCHAR2(6 BYTE),
  CT_INTERNAL_AC_NUM      NUMBER(14)            DEFAULT 0,
  CT_GLACC_CODE           VARCHAR2(15 BYTE),
  CT_CURR_CODE            VARCHAR2(3 BYTE),
  CT_AMOUNT               NUMBER(18,3)          DEFAULT 0,
  CT_PAN_GIR_NUMBER       VARCHAR2(35 BYTE),
  CT_WITHDRAW_MODE        CHAR(1 BYTE),
  CT_CHEQUE_PFX           VARCHAR2(6 BYTE),
  CT_CHEQUE_NUM           NUMBER(15)            DEFAULT 0,
  CT_CHEQUE_DATE          DATE,
  CT_WITHDRAW_SLIP_NUM    VARCHAR2(15 BYTE),
  CT_CHQ_RETURN           CHAR(1 BYTE)          DEFAULT 0,
  CT_TOT_PAID_AMT         NUMBER(18,3)          DEFAULT 0,
  CT_TOT_REC_AMT          NUMBER(18,3)          DEFAULT 0,
  CT_CASH_COUNTED         CHAR(1 BYTE)          DEFAULT 0,
  CT_PRINT_WITHDRAW_SLIP  CHAR(1 BYTE)          DEFAULT 0,
  CT_SCROLL_NUM           NUMBER(6)             DEFAULT 0,
  CT_SELF_THPARTY         CHAR(1 BYTE),
  CT_PID_VERIFIED         CHAR(1 BYTE)          DEFAULT 0,
  CT_SIGN_VERIFIED        CHAR(1 BYTE)          DEFAULT 0,
  CT_SIGN_COMB_SL         NUMBER(5)             DEFAULT 0,
  CT_PERSON_NAME          VARCHAR2(50 BYTE),
  CT_REMARKS1             VARCHAR2(35 BYTE),
  CT_REMARKS2             VARCHAR2(35 BYTE),
  CT_REMARKS3             VARCHAR2(35 BYTE),
  POST_TRAN_BRN           NUMBER(6)             DEFAULT 0,
  POST_TRAN_DATE          DATE,
  POST_TRAN_BATCH_NUM     NUMBER(7)             DEFAULT 0,
  POST_TRAN_BATCH_SL      NUMBER(6)             DEFAULT 0,
  CT_ENTD_BY              VARCHAR2(8 BYTE)      DEFAULT 0,
  CT_ENTD_ON              DATE,
  CT_LAST_MOD_BY          VARCHAR2(8 BYTE),
  CT_LAST_MOD_ON          DATE,
  CT_AUTH_BY              VARCHAR2(8 BYTE),
  CT_AUTH_ON              DATE,
  CT_REJ_BY               VARCHAR2(8 BYTE),
  CT_REJ_ON               DATE
)
PARTITION BY RANGE(CT_TRAN_DATE)
 INTERVAL(NUMTODSINTERVAL (1, 'DAY'))  STORE IN (TBFES, TBSTRAN)
  (PARTITION EMPTY_PART VALUES LESS THAN (TO_DATE('01-01-2015', 'DD-MM-YYYY')) TABLESPACE TBSTRAN); 

ALTER TABLE CTRANDD2021
 DROP PRIMARY KEY CASCADE;

DROP TABLE CTRANDD2021 CASCADE CONSTRAINTS;

CREATE TABLE CTRANDD2021
(
  CTRANDD_ENTITY_NUM    NUMBER(4)               NOT NULL,
  CTDD_BRN_CODE         NUMBER(6)               NOT NULL,
  CTDD_TRAN_DATE        DATE                    NOT NULL,
  CTDD_CASHIER_ID       VARCHAR2(8 BYTE)        NOT NULL,
  CTDD_DAY_SL           NUMBER(5)               NOT NULL,
  CTDD_UP_SL            NUMBER(3)               NOT NULL,
  CTDD_REC_PAYMENT      CHAR(1 BYTE),
  CTDD_NOTE_COIN        CHAR(1 BYTE),
  CTDD_DENOM            NUMBER(11,3)            DEFAULT 0,
  CTDD_GSC_FLAG         CHAR(1 BYTE),
  CTDD_GOOD_SECTIONS    NUMBER(15)              DEFAULT 0,
  CTDD_GOOD_UNITS       NUMBER(15)              DEFAULT 0,
  CTDD_SOILED_SECTIONS  NUMBER(15)              DEFAULT 0,
  CTDD_SOILED_UNITS     NUMBER(15)              DEFAULT 0,
  CTDD_CUT_SECTIONS     NUMBER(15)              DEFAULT 0,
  CTDD_CUT_UNITS        NUMBER(15)              DEFAULT 0,
  CTDD_AMOUNT           NUMBER(18,3)            DEFAULT 0
)
TABLESPACE DATA
RESULT_CACHE (MODE DEFAULT)
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            MAXSIZE          UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      DEFAULT
            CELL_FLASH_CACHE DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING;


ALTER TABLE GLSUM2021
 DROP PRIMARY KEY CASCADE;

DROP TABLE GLSUM2021 CASCADE CONSTRAINTS;

CREATE TABLE GLSUM2021
(
  GLSUM_ENTITY_NUM        NUMBER(4)             NOT NULL,
  GLSUM_BRANCH_CODE       NUMBER(6)             NOT NULL,
  GLSUM_GLACC_CODE        VARCHAR2(15 BYTE)     NOT NULL,
  GLSUM_CURR_CODE         VARCHAR2(3 BYTE)      NOT NULL,
  GLSUM_TRAN_DATE         DATE                  NOT NULL,
  GLSUM_AC_DB_SUM         NUMBER(18,3)          DEFAULT 0,
  GLSUM_BC_DB_SUM         NUMBER(18,3)          DEFAULT 0,
  GLSUM_NUM_DBS           NUMBER(10)            DEFAULT 0,
  GLSUM_AC_CR_SUM         NUMBER(18,3)          DEFAULT 0,
  GLSUM_BC_CR_SUM         NUMBER(18,3)          DEFAULT 0,
  GLSUM_NUM_CRS           NUMBER(10)            DEFAULT 0,
  GLSUM_FWDVAL_AC_DB_SUM  NUMBER(18,3)          DEFAULT 0,
  GLSUM_FWDVAL_BC_DB_SUM  NUMBER(18,3)          DEFAULT 0,
  GLSUM_FWDVAL_NUM_DBS    NUMBER(10)            DEFAULT 0,
  GLSUM_FWDVAL_AC_CR_SUM  NUMBER(18,3)          DEFAULT 0,
  GLSUM_FWDVAL_BC_CR_SUM  NUMBER(18,3)          DEFAULT 0,
  GLSUM_FWDVAL_NUM_CRS    NUMBER(10)            DEFAULT 0
)
TABLESPACE DATA
RESULT_CACHE (MODE DEFAULT)
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MAXSIZE          UNLIMITED
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      DEFAULT
            CELL_FLASH_CACHE DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING;


DROP TABLE OPRLOG2021 CASCADE CONSTRAINTS;

CREATE TABLE OPRLOG2021
(
  OPRLOG_ENTITY_NUM  NUMBER(4)                  NOT NULL,
  OPRLOG_BRN_CODE    NUMBER(6)                  NOT NULL,
  OPRLOG_USER_ID     VARCHAR2(8 BYTE)           NOT NULL,
  OPRLOG_FORM_NAME   VARCHAR2(40 BYTE)          NOT NULL,
  OPRLOG_OPR_SL      NUMBER(8)                  NOT NULL,
  OPRLOG_IN_TIME     DATE,
  OPRLOG_OUT_TIME    DATE,
  OPRLOG_IP_ADDRESS  VARCHAR2(15 BYTE)
)
TABLESPACE DATA
RESULT_CACHE (MODE DEFAULT)
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            MAXSIZE          UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      DEFAULT
            CELL_FLASH_CACHE DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING;


ALTER TABLE SEGGLASUM2021
 DROP PRIMARY KEY CASCADE;

DROP TABLE SEGGLASUM2021 CASCADE CONSTRAINTS;

CREATE TABLE SEGGLASUM2021
(
  SEGGLAS_ENTITY_NUM  NUMBER(4)                 NOT NULL,
  SEGGLAS_BRN_CODE    NUMBER(6)                 NOT NULL,
  SEGGLAS_SEG_METHOD  VARCHAR2(6 BYTE)          NOT NULL,
  SEGGLAS_SEG_CODE    VARCHAR2(6 BYTE)          NOT NULL,
  SEGGLAS_PROC_DATE   DATE                      NOT NULL,
  SEGGLAS_GLACC_CODE  VARCHAR2(15 BYTE)         NOT NULL,
  SEGGLAS_CURR_CODE   VARCHAR2(3 BYTE)          NOT NULL,
  SEGGLAS_TRAN_DATE   DATE                      NOT NULL,
  SEGGLAS_AC_DB_SUM   NUMBER(18,3)              DEFAULT 0,
  SEGGLAS_BC_DB_SUM   NUMBER(18,3)              DEFAULT 0,
  SEGGLAS_AC_CR_SUM   NUMBER(18,3)              DEFAULT 0,
  SEGGLAS_BC_CR_SUM   NUMBER(18,3)              DEFAULT 0
)
TABLESPACE DATA
RESULT_CACHE (MODE DEFAULT)
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            MAXSIZE          UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      DEFAULT
            CELL_FLASH_CACHE DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING;


ALTER TABLE SEGREPTRAN2021
 DROP PRIMARY KEY CASCADE;

DROP TABLE SEGREPTRAN2021 CASCADE CONSTRAINTS;

CREATE TABLE SEGREPTRAN2021
(
  SEGREPTRAN_ENTITY_NUM         NUMBER(4)       NOT NULL,
  SEGREPTRAN_BRN_CODE           NUMBER(6)       NOT NULL,
  SEGREPTRAN_METHOD             VARCHAR2(6 BYTE) NOT NULL,
  SEGREPTRAN_SEG_CODE           VARCHAR2(6 BYTE) NOT NULL,
  SEGREPTRAN_PROC_DATE          DATE            NOT NULL,
  SEGREPTRAN_TR_DATE            DATE            NOT NULL,
  SEGREPTRAN_TR_BATCH           NUMBER(7)       NOT NULL,
  SEGREPTRAN_TR_BAT_SL_NUM      NUMBER(6)       NOT NULL,
  SEGREPTRAN_CONTRA_BAT_SL_NUM  NUMBER(6)       NOT NULL,
  SEGREPTRAN_PROC_TYPE          CHAR(1 BYTE),
  SEGREPTRAN_GLACC_CODE         VARCHAR2(15 BYTE),
  SEGREPTRAN_TR_CURR_CODE       VARCHAR2(3 BYTE),
  SEGREPTRAN_TR_AMT             NUMBER(18,3)    DEFAULT 0,
  SEGREPTRAN_TR_BASE_CURR       VARCHAR2(3 BYTE),
  SEGREPTRAN_TR_BC_EQ_AMT       NUMBER(18,3)    DEFAULT 0
)
TABLESPACE DATA
RESULT_CACHE (MODE DEFAULT)
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            MAXSIZE          UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      DEFAULT
            CELL_FLASH_CACHE DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING;


ALTER TABLE TRAN2021
 DROP PRIMARY KEY CASCADE;

DROP TABLE TRAN2021 CASCADE CONSTRAINTS;

CREATE TABLE TRAN2021
(
  TRAN_ENTITY_NUM             NUMBER(4)         NOT NULL,
  TRAN_BRN_CODE               NUMBER(6)         NOT NULL,
  TRAN_DATE_OF_TRAN           DATE              NOT NULL,
  TRAN_BATCH_NUMBER           NUMBER(7)         NOT NULL,
  TRAN_BATCH_SL_NUM           NUMBER(6)         NOT NULL,
  TRAN_PROD_CODE              NUMBER(4)         DEFAULT 0,
  TRAN_CODE                   VARCHAR2(6 BYTE),
  TRAN_VALUE_DATE             DATE,
  TRAN_ACING_BRN_CODE         NUMBER(6)         DEFAULT 0,
  TRAN_INTERNAL_ACNUM         NUMBER(14)        DEFAULT 0,
  TRAN_CONTRACT_NUM           NUMBER(8)         DEFAULT 0,
  TRAN_GLACC_CODE             VARCHAR2(15 BYTE),
  TRAN_DB_CR_FLG              CHAR(1 BYTE),
  TRAN_TYPE_OF_TRAN           CHAR(1 BYTE),
  TRAN_CURR_CODE              VARCHAR2(3 BYTE),
  TRAN_AMOUNT                 NUMBER(18,3)      DEFAULT 0,
  TRAN_BASE_CURR_CODE         VARCHAR2(3 BYTE),
  TRAN_BASE_CURR_CONV_RATE    NUMBER(14,9)      DEFAULT 0,
  TRAN_BASE_CURR_EQ_AMT       NUMBER(18,3)      DEFAULT 0,
  TRAN_AMT_BRKUP              CHAR(1 BYTE)      DEFAULT 0,
  TRAN_SERVICE_CODE           VARCHAR2(6 BYTE),
  TRAN_CHARGE_CODE            VARCHAR2(6 BYTE),
  TRAN_DELIVERY_CHANNEL_CODE  VARCHAR2(6 BYTE),
  TRAN_DEVICE_CODE            VARCHAR2(6 BYTE),
  TRAN_DEVICE_UNIT_NUMBER     VARCHAR2(20 BYTE),
  TRAN_TRN_EXT_REF_NUMBER     VARCHAR2(25 BYTE),
  TRAN_INSTR_CHQ_PFX          VARCHAR2(6 BYTE),
  TRAN_INSTR_CHQ_NUMBER       NUMBER(15)        DEFAULT 0,
  TRAN_INSTR_DATE             DATE,
  TRAN_PROFIT_CUST_CODE       NUMBER(12),
  TRAN_REMITTANCE_CODE        VARCHAR2(6 BYTE),
  TRAN_SIGN_COMB_SL           NUMBER(2)         DEFAULT 0,
  TRAN_SIGN_VERIFIED_FLG      CHAR(1 BYTE)      DEFAULT 0,
  TRAN_LIMIT_CURR             VARCHAR2(3 BYTE),
  TRAN_CRATE_TO_LIMIT_CURR    NUMBER(14,9)      DEFAULT 0,
  TRAN_LIMIT_CURR_EQUIVALENT  NUMBER(18,3)      DEFAULT 0,
  TRAN_ENTD_BY                VARCHAR2(8 BYTE)  NOT NULL,
  TRAN_ENTD_ON                DATE              NOT NULL,
  TRAN_LAST_MOD_BY            VARCHAR2(8 BYTE),
  TRAN_LAST_MOD_ON            DATE,
  TRAN_FIRST_AUTH_BY          VARCHAR2(8 BYTE),
  TRAN_FIRST_AUTH_ON          DATE,
  TRAN_AUTH_BY                VARCHAR2(8 BYTE),
  TRAN_AUTH_ON                DATE,
  TRAN_RISK_AUTH_BY           VARCHAR2(8 BYTE),
  TRAN_RISK_AUTH_ON           DATE,
  TRAN_SYSTEM_POSTED_TRAN     CHAR(1 BYTE)      DEFAULT 0,
  TRAN_CASHIER_ID             VARCHAR2(8 BYTE),
  TRAN_CASH_TRAN_DATE         DATE,
  TRAN_CASH_TRAN_DAY_SL       NUMBER(5),
  TRAN_AC_CANCEL_AMT          NUMBER(18,3)      DEFAULT 0,
  TRAN_BC_CANCEL_AMT          NUMBER(18,3)      DEFAULT 0,
  TRAN_INTERMED_VCR_FLG       CHAR(1 BYTE)      DEFAULT 0,
  TRAN_BACKOFF_SYS_CODE       VARCHAR2(6 BYTE),
  TRAN_CHANNEL_DT_TIME        DATE,
  TRAN_CHANNEL_UNIQ_NUM       VARCHAR2(20 BYTE),
  TRAN_COST_CNTR_CODE         VARCHAR2(6 BYTE),
  TRAN_SUB_COST_CNTR          VARCHAR2(6 BYTE),
  TRAN_PROFIT_CNTR_CODE       VARCHAR2(6 BYTE),
  TRAN_SUB_PROFIT_CNTR        VARCHAR2(6 BYTE),
  TRAN_NOM_AC_ENT_TYPE        CHAR(1 BYTE),
  TRAN_NOM_AC_PRE_ENT_YR      NUMBER(4)         DEFAULT 0,
  TRAN_NOM_AC_REF_NUM         NUMBER(8)         DEFAULT 0,
  TRAN_HOLD_REFNUM            NUMBER(10)        DEFAULT 0,
  TRAN_ACNT_INVALID           CHAR(1 BYTE)      DEFAULT 0,
  TRAN_AVAILABLE_AC_BAL       NUMBER(18,3)      DEFAULT 0,
  TRAN_AGENCY_BANK_CODE       VARCHAR2(6 BYTE),
  TRAN_IBR_BRN_CODE           NUMBER(6)         DEFAULT 0,
  TRAN_IBR_CODE               VARCHAR2(3 BYTE),
  TRAN_ORIG_RESP              CHAR(1 BYTE),
  TRAN_IBR_YEAR               NUMBER(4)         DEFAULT 0,
  TRAN_IBR_NUM                NUMBER(8)         DEFAULT 0,
  TRAN_ADVICE_NUM             NUMBER(6)         DEFAULT 0,
  TRAN_ADVICE_DATE            DATE,
  TRAN_TERMINAL_ID            VARCHAR2(15 BYTE),
  TRAN_NARR_DTL1              VARCHAR2(35 BYTE),
  TRAN_NARR_DTL2              VARCHAR2(35 BYTE),
  TRAN_NARR_DTL3              VARCHAR2(35 BYTE),
  TRAN_NOTICE_REF_NUM         VARCHAR2(35 BYTE),
  TRAN_CANC_IBR_CODE          VARCHAR2(3 BYTE),
  TRAN_DEPT_CODE              VARCHAR2(6 BYTE),
  TRAN_COUNTERPARTY_NAME      VARCHAR2(200 BYTE)
)
PARTITION BY RANGE(TRAN_DATE_OF_TRAN)
 INTERVAL(NUMTODSINTERVAL (1, 'DAY'))  STORE IN (TBFES, TBSTRAN)
  (PARTITION EMPTY_PART VALUES LESS THAN (TO_DATE('01-01-2015', 'DD-MM-YYYY')) TABLESPACE TBFES);



ALTER TABLE TRANADV2021
 DROP PRIMARY KEY CASCADE;

DROP TABLE TRANADV2021 CASCADE CONSTRAINTS;

CREATE TABLE TRANADV2021
(
  TRANADV_ENTITY_NUM     NUMBER(4)              NOT NULL,
  TRANADV_BRN_CODE       NUMBER(6)              NOT NULL,
  TRANADV_DATE_OF_TRAN   DATE                   NOT NULL,
  TRANADV_BATCH_NUMBER   NUMBER(7)              NOT NULL,
  TRANADV_BATCH_SL_NUM   NUMBER(6)              NOT NULL,
  TRANADV_PRIN_AC_AMT    NUMBER(18,3)           DEFAULT 0,
  TRANADV_PRIN_BC_AMT    NUMBER(18,3)           DEFAULT 0,
  TRANADV_INTRD_AC_AMT   NUMBER(18,3)           DEFAULT 0,
  TRANADV_INTRD_BC_AMT   NUMBER(18,3)           DEFAULT 0,
  TRANADV_CHARGE_AC_AMT  NUMBER(18,3)           DEFAULT 0,
  TRANADV_CHARGE_BC_AMT  NUMBER(18,3)           DEFAULT 0
)
TABLESPACE DATA
RESULT_CACHE (MODE DEFAULT)
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MAXSIZE          UNLIMITED
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      DEFAULT
            CELL_FLASH_CACHE DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING;


ALTER TABLE TRANADVADDN2021
 DROP PRIMARY KEY CASCADE;

DROP TABLE TRANADVADDN2021 CASCADE CONSTRAINTS;

CREATE TABLE TRANADVADDN2021
(
  TRANADVADDN_ENTITY_NUM     NUMBER(4)          NOT NULL,
  TRANADV_BRN_CODE           NUMBER(6)          NOT NULL,
  TRANADV_DATE_OF_TRAN       DATE               NOT NULL,
  TRANADV_BATCH_NUMBER       NUMBER(7)          NOT NULL,
  TRANADV_BATCH_SL_NUM       NUMBER(6)          NOT NULL,
  TRANADV_PRI_BRK_AMT        NUMBER(18,3)       DEFAULT 0,
  TRANADV_INT_BRK_AMT        NUMBER(18,3)       DEFAULT 0,
  TRANADV_CHG_BRK_AMT        NUMBER(18,3)       DEFAULT 0,
  TRANADV_INT_ACCR_BRK_AMT   NUMBER(18,3)       DEFAULT 0,
  TRANADV_CHGQ_BRK_AMT       NUMBER(18,3)       DEFAULT 0,
  TRANADV_PENAL_INT_BRK_AMT  NUMBER(18,3)       DEFAULT 0,
  TRANADV_INTSUSP_BRK_AMT    NUMBER(18,3)       DEFAULT 0,
  TRANADV_FUTURE_BRK_AMT     NUMBER(18,3)       DEFAULT 0
)
TABLESPACE DATA
RESULT_CACHE (MODE DEFAULT)
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MAXSIZE          UNLIMITED
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      DEFAULT
            CELL_FLASH_CACHE DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING;


ALTER TABLE TRANBAT2021
 DROP PRIMARY KEY CASCADE;

DROP TABLE TRANBAT2021 CASCADE CONSTRAINTS;

CREATE TABLE TRANBAT2021
(
  TRANBAT_ENTITY_NUM            NUMBER(4)       NOT NULL,
  TRANBAT_BRN_CODE              NUMBER(6)       NOT NULL,
  TRANBAT_DATE_OF_TRAN          DATE            NOT NULL,
  TRANBAT_BATCH_NUMBER          NUMBER(7)       NOT NULL,
  TRANBAT_ENTRY_BRN_CODE        NUMBER(6)       DEFAULT 0,
  TRANBAT_WITHDRAW_SLIP         VARCHAR2(15 BYTE),
  TRANBAT_TOKEN_ISSUED          NUMBER(5)       DEFAULT 0,
  TRANBAT_BACKOFF_SYS_CODE      VARCHAR2(6 BYTE),
  TRANBAT_DEVICE_CODE           VARCHAR2(6 BYTE),
  TRANBAT_DEVICE_UNIT_NUM       VARCHAR2(15 BYTE),
  TRANBAT_CHANNEL_DT_TIME       DATE,
  TRANBAT_CHANNEL_UNIQ_NUM      VARCHAR2(20 BYTE),
  TRANBAT_COST_CNTR_CODE        VARCHAR2(6 BYTE),
  TRANBAT_SUB_COST_CNTR         VARCHAR2(6 BYTE),
  TRANBAT_PROFIT_CNTR_CODE      VARCHAR2(6 BYTE),
  TRANBAT_SUB_PROFIT_CNTR       VARCHAR2(6 BYTE),
  TRANBAT_NUM_TRANS             NUMBER(6)       DEFAULT 0,
  TRANBAT_BASE_CURR_TOT_CR      NUMBER(18,3)    DEFAULT 0,
  TRANBAT_BASE_CURR_TOT_DB      NUMBER(18,3)    DEFAULT 0,
  TRANBAT_CANCEL_BY             VARCHAR2(8 BYTE),
  TRANBAT_CANCEL_ON             DATE,
  TRANBAT_CANCEL_REM1           VARCHAR2(35 BYTE),
  TRANBAT_CANCEL_REM2           VARCHAR2(35 BYTE),
  TRANBAT_CANCEL_REM3           VARCHAR2(35 BYTE),
  TRANBAT_SOURCE_TABLE          VARCHAR2(30 BYTE),
  TRANBAT_SOURCE_KEY            VARCHAR2(100 BYTE),
  TRANBAT_NARR_DTL1             VARCHAR2(35 BYTE),
  TRANBAT_NARR_DTL2             VARCHAR2(35 BYTE),
  TRANBAT_NARR_DTL3             VARCHAR2(35 BYTE),
  TRANBAT_AUTH_BY               VARCHAR2(8 BYTE),
  TRANBAT_AUTH_ON               DATE,
  TRANBAT_SHIFT_TO_TRAN_DATE    DATE,
  TRANBAT_SHIFT_TO_BAT_NUM      NUMBER(7)       DEFAULT 0,
  TRANBAT_SHIFT_FROM_TRAN_DATE  DATE,
  TRANBAT_SHIFT_FROM_BAT_NUM    NUMBER(7)       DEFAULT 0,
  TRANBAT_REV_TO_TRAN_DATE      DATE,
  TRANBAT_REV_TO_BAT_NUM        NUMBER(7)       DEFAULT 0,
  TRANBAT_REV_FROM_TRAN_DATE    DATE,
  TRANBAT_REV_FROM_BAT_NUM      NUMBER(7)       DEFAULT 0,
  TRANBAT_SUBBRN_CODE           NUMBER(8)       DEFAULT 0
)
PARTITION BY RANGE(TRANBAT_DATE_OF_TRAN)
 INTERVAL(NUMTODSINTERVAL (1, 'DAY'))  STORE IN (TBFES, TBSTRAN)
  (PARTITION EMPTY_PART VALUES LESS THAN (TO_DATE('01-01-2015', 'DD-MM-YYYY')) TABLESPACE TBSTRAN);



CREATE INDEX IDX_AUDITLOG2021 ON AUDITLOG2021
(AUDITLOG_ENTITY_NUM, ATLOG_BRN_CODE, ATLOG_DATETIME, ATLOG_LOG_SL, ATLOG_DTL_SL)
LOGGING
TABLESPACE TBFES
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            MAXSIZE          UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      DEFAULT
            CELL_FLASH_CACHE DEFAULT
           )
NOPARALLEL;


CREATE UNIQUE INDEX IDX_CTRAN2021 ON CTRAN2021
(CTRAN_ENTITY_NUM, CT_BRN_CODE, CT_TRAN_DATE, CT_CASHIER_ID, CT_DAY_SL)
LOGGING
TABLESPACE TBFES
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MAXSIZE          UNLIMITED
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      DEFAULT
            CELL_FLASH_CACHE DEFAULT
           )
NOPARALLEL;


CREATE INDEX IDX_OPRLOG2021 ON OPRLOG2021
(OPRLOG_ENTITY_NUM, OPRLOG_BRN_CODE, OPRLOG_USER_ID, OPRLOG_FORM_NAME, OPRLOG_OPR_SL)
LOGGING
TABLESPACE TBFES
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            MAXSIZE          UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      DEFAULT
            CELL_FLASH_CACHE DEFAULT
           )
NOPARALLEL;


CREATE INDEX IDX_TRAN2021_ACTNUM_DATE ON TRAN2021
(TRAN_INTERNAL_ACNUM, TRAN_DATE_OF_TRAN)
LOGGING
TABLESPACE TBFES
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MAXSIZE          UNLIMITED
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      DEFAULT
            CELL_FLASH_CACHE DEFAULT
           )
NOPARALLEL;


CREATE INDEX IDX_TRAN2021_GL_ACBRN_ENTITY ON TRAN2021
(TRAN_ENTITY_NUM, TRAN_ACING_BRN_CODE, TRAN_GLACC_CODE, TRAN_DATE_OF_TRAN)
LOGGING
TABLESPACE TBFES
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MAXSIZE          UNLIMITED
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      DEFAULT
            CELL_FLASH_CACHE DEFAULT
           )
NOPARALLEL;


CREATE INDEX IDX_TRAN2021_NOTICE_REFNO ON TRAN2021
(TRAN_NOTICE_REF_NUM)
LOGGING
TABLESPACE TBFES
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MAXSIZE          UNLIMITED
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      DEFAULT
            CELL_FLASH_CACHE DEFAULT
           )
NOPARALLEL;


CREATE UNIQUE INDEX IDX_TRAN2021_PK ON TRAN2021
(TRAN_ENTITY_NUM, TRAN_BRN_CODE, TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER, TRAN_BATCH_SL_NUM)
LOGGING
TABLESPACE TBFES
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MAXSIZE          UNLIMITED
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      DEFAULT
            CELL_FLASH_CACHE DEFAULT
           )
NOPARALLEL;


CREATE UNIQUE INDEX IDX_TRANBAT2021_PK ON TRANBAT2021
(TRANBAT_ENTITY_NUM, TRANBAT_BRN_CODE, TRANBAT_DATE_OF_TRAN, TRANBAT_BATCH_NUMBER)
LOGGING
TABLESPACE TBFES
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MAXSIZE          UNLIMITED
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      DEFAULT
            CELL_FLASH_CACHE DEFAULT
           )
NOPARALLEL;


--  There is no statement for index SYS_C001870658.
--  The object is created when the parent object is created.

--  There is no statement for index SYS_C001871283.
--  The object is created when the parent object is created.

--  There is no statement for index SYS_C001871906.
--  The object is created when the parent object is created.

--  There is no statement for index SYS_C001872647.
--  The object is created when the parent object is created.

--  There is no statement for index SYS_C001872880.
--  The object is created when the parent object is created.

--  There is no statement for index SYS_C001873128.
--  The object is created when the parent object is created.

--  There is no statement for index SYS_C001874500.
--  The object is created when the parent object is created.

--  There is no statement for index SYS_C001874530.
--  The object is created when the parent object is created.

CREATE OR REPLACE TRIGGER SBBD_IUT_DF.TRIG_CTRAN_LOG_2021 
   BEFORE INSERT OR UPDATE OR DELETE
   ON CTRAN2021
   FOR EACH ROW
DECLARE
   V_LOGIN_USER          VARCHAR2 (1000);
   V_INSTANCE_NUM        VARCHAR2 (1000);
   V_CLIENT_IP_ADDRESS   VARCHAR2 (1000);
   V_CURRENT_SCN         VARCHAR2 (1000);
   V_OS_USER             VARCHAR2 (1000);
   V_TERMINAL            VARCHAR2 (1000);
   V_IP_ADDRESS          VARCHAR2 (1000);
   V_SID                 VARCHAR2 (1000);
   V_SERIAL              VARCHAR2 (1000);
   V_LOGON_TIME          DATE;
   V_DML_TYPE            VARCHAR2(10);
   V_AUDSID                 NUMBER;
BEGIN
   V_LOGIN_USER := ORA_LOGIN_USER;
   V_INSTANCE_NUM := ORA_INSTANCE_NUM;
   V_OS_USER := SYS_CONTEXT ('USERENV', 'OS_USER');
   V_IP_ADDRESS := SYS_CONTEXT ('USERENV', 'IP_ADDRESS');
   V_SID := SYS_CONTEXT ('USERENV', 'SID');

   SELECT SERIAL#,LOGON_TIME,MACHINE,AUDSID
   INTO V_SERIAL,V_LOGON_TIME,V_TERMINAL,V_AUDSID FROM GV$SESSION
   WHERE SID=SYS_CONTEXT('USERENV','SID')
    AND INST_ID=ORA_INSTANCE_NUM;
    
    IF INSERTING THEN
    V_DML_TYPE:='I';
    END IF;
    
    IF UPDATING THEN
    V_DML_TYPE:='U';
    END IF;
    
    IF DELETING THEN
    V_DML_TYPE:='D';
    END IF;

   INSERT INTO CTRANLOG (DML_TYPE,
                         CT_LOGIN_USER,
                         CT_INSTANCE_NUM,
                         CT_OS_USER,
                         CT_TERMINAL,
                         CT_IP_ADDRESS,
                         CT_SID,
                         CT_SERIAL,
                         CT_AUDSID,
                         CT_SYSTIMESTAMP,
                         CT_LOGON_TIME,
                         CTRAN_ENTITY_NUM,
                         CT_BRN_CODE,
                         CT_TRAN_DATE,
                         CT_CASHIER_ID,
                         CT_DAY_SL,
                         CT_TYPE_OF_ENTRY,
                         CT_REC_PAYMENT,
                         CT_TOKEN_NUMBER,
                         CT_TRAN_BAT_NUMBER,
                         CT_TRAN_BAT_SL_NUM,
                         CT_TRAN_CODE,
                         CT_INTERNAL_AC_NUM,
                         CT_GLACC_CODE,
                         CT_CURR_CODE,
                         CT_AMOUNT,
                         CT_PAN_GIR_NUMBER,
                         CT_WITHDRAW_MODE,
                         CT_CHEQUE_PFX,
                         CT_CHEQUE_NUM,
                         CT_CHEQUE_DATE,
                         CT_WITHDRAW_SLIP_NUM,
                         CT_CHQ_RETURN,
                         CT_TOT_PAID_AMT,
                         CT_TOT_REC_AMT,
                         CT_CASH_COUNTED,
                         CT_PRINT_WITHDRAW_SLIP,
                         CT_SCROLL_NUM,
                         CT_SELF_THPARTY,
                         CT_PID_VERIFIED,
                         CT_SIGN_VERIFIED,
                         CT_SIGN_COMB_SL,
                         CT_PERSON_NAME,
                         CT_REMARKS1,
                         CT_REMARKS2,
                         CT_REMARKS3,
                         POST_TRAN_BRN,
                         POST_TRAN_DATE,
                         POST_TRAN_BATCH_NUM,
                         POST_TRAN_BATCH_SL,
                         CT_ENTD_BY,
                         CT_ENTD_ON,
                         CT_LAST_MOD_BY,
                         CT_LAST_MOD_ON,
                         CT_AUTH_BY,
                         CT_AUTH_ON,
                         CT_REJ_BY,
                         CT_REJ_ON)
        VALUES (V_DML_TYPE,
                V_LOGIN_USER,
                V_INSTANCE_NUM,
                V_OS_USER,
                V_TERMINAL,
                V_IP_ADDRESS,
                V_SID,V_SERIAL,
                V_AUDSID,
                SYSTIMESTAMP,
                V_LOGON_TIME,
                NVL(:NEW.CTRAN_ENTITY_NUM,:OLD.CTRAN_ENTITY_NUM),
                NVL(:NEW.CT_BRN_CODE,:OLD.CT_BRN_CODE),
                NVL(:NEW.CT_TRAN_DATE,:OLD.CT_TRAN_DATE),
                NVL(:NEW.CT_CASHIER_ID,:OLD.CT_CASHIER_ID),
                NVL(:NEW.CT_DAY_SL,:OLD.CT_DAY_SL),
                NVL(:NEW.CT_TYPE_OF_ENTRY,:OLD.CT_TYPE_OF_ENTRY),
                NVL(:NEW.CT_REC_PAYMENT,:OLD.CT_REC_PAYMENT),
                :NEW.CT_TOKEN_NUMBER,
                :NEW.CT_TRAN_BAT_NUMBER,
                :NEW.CT_TRAN_BAT_SL_NUM,
                :NEW.CT_TRAN_CODE,
                :NEW.CT_INTERNAL_AC_NUM,
                :NEW.CT_GLACC_CODE,
                :NEW.CT_CURR_CODE,
                :NEW.CT_AMOUNT,
                :NEW.CT_PAN_GIR_NUMBER,
                :NEW.CT_WITHDRAW_MODE,
                :NEW.CT_CHEQUE_PFX,
                :NEW.CT_CHEQUE_NUM,
                :NEW.CT_CHEQUE_DATE,
                :NEW.CT_WITHDRAW_SLIP_NUM,
                :NEW.CT_CHQ_RETURN,
                :NEW.CT_TOT_PAID_AMT,
                :NEW.CT_TOT_REC_AMT,
                :NEW.CT_CASH_COUNTED,
                :NEW.CT_PRINT_WITHDRAW_SLIP,
                :NEW.CT_SCROLL_NUM,
                :NEW.CT_SELF_THPARTY,
                :NEW.CT_PID_VERIFIED,
                :NEW.CT_SIGN_VERIFIED,
                :NEW.CT_SIGN_COMB_SL,
                :NEW.CT_PERSON_NAME,
                :NEW.CT_REMARKS1,
                :NEW.CT_REMARKS2,
                :NEW.CT_REMARKS3,
                :NEW.POST_TRAN_BRN,
                :NEW.POST_TRAN_DATE,
                :NEW.POST_TRAN_BATCH_NUM,
                :NEW.POST_TRAN_BATCH_SL,
                :NEW.CT_ENTD_BY,
                :NEW.CT_ENTD_ON,
                :NEW.CT_LAST_MOD_BY,
                :NEW.CT_LAST_MOD_ON,
                :NEW.CT_AUTH_BY,
                :NEW.CT_AUTH_ON,
                :NEW.CT_REJ_BY,
                :NEW.CT_REJ_ON);
END;
/


CREATE OR REPLACE TRIGGER ISLAMIC_IUT.TRIG_CTRAN_LOG_2021 
   BEFORE INSERT OR UPDATE OR DELETE
   ON CTRAN2021
   FOR EACH ROW
DISABLE
DECLARE
   V_LOGIN_USER          VARCHAR2 (1000);
   V_INSTANCE_NUM        VARCHAR2 (1000);
   V_CLIENT_IP_ADDRESS   VARCHAR2 (1000);
   V_CURRENT_SCN         VARCHAR2 (1000);
   V_OS_USER             VARCHAR2 (1000);
   V_TERMINAL            VARCHAR2 (1000);
   V_IP_ADDRESS          VARCHAR2 (1000);
   V_SID                 VARCHAR2 (1000);
   V_SERIAL              VARCHAR2 (1000);
   V_LOGON_TIME          DATE;
   V_DML_TYPE            VARCHAR2(10);
   V_AUDSID                 NUMBER;
BEGIN
   V_LOGIN_USER := ORA_LOGIN_USER;
   V_INSTANCE_NUM := ORA_INSTANCE_NUM;
   V_OS_USER := SYS_CONTEXT ('USERENV', 'OS_USER');
   V_IP_ADDRESS := SYS_CONTEXT ('USERENV', 'IP_ADDRESS');
   V_SID := SYS_CONTEXT ('USERENV', 'SID');

   SELECT SERIAL#,LOGON_TIME,MACHINE,AUDSID
   INTO V_SERIAL,V_LOGON_TIME,V_TERMINAL,V_AUDSID FROM GV$SESSION
   WHERE SID=SYS_CONTEXT('USERENV','SID')
    AND INST_ID=ORA_INSTANCE_NUM;
    
    IF INSERTING THEN
    V_DML_TYPE:='I';
    END IF;
    
    IF UPDATING THEN
    V_DML_TYPE:='U';
    END IF;
    
    IF DELETING THEN
    V_DML_TYPE:='D';
    END IF;

   INSERT INTO CTRANLOG (DML_TYPE,
                         CT_LOGIN_USER,
                         CT_INSTANCE_NUM,
                         CT_OS_USER,
                         CT_TERMINAL,
                         CT_IP_ADDRESS,
                         CT_SID,
                         CT_SERIAL,
                         CT_AUDSID,
                         CT_SYSTIMESTAMP,
                         CT_LOGON_TIME,
                         CTRAN_ENTITY_NUM,
                         CT_BRN_CODE,
                         CT_TRAN_DATE,
                         CT_CASHIER_ID,
                         CT_DAY_SL,
                         CT_TYPE_OF_ENTRY,
                         CT_REC_PAYMENT,
                         CT_TOKEN_NUMBER,
                         CT_TRAN_BAT_NUMBER,
                         CT_TRAN_BAT_SL_NUM,
                         CT_TRAN_CODE,
                         CT_INTERNAL_AC_NUM,
                         CT_GLACC_CODE,
                         CT_CURR_CODE,
                         CT_AMOUNT,
                         CT_PAN_GIR_NUMBER,
                         CT_WITHDRAW_MODE,
                         CT_CHEQUE_PFX,
                         CT_CHEQUE_NUM,
                         CT_CHEQUE_DATE,
                         CT_WITHDRAW_SLIP_NUM,
                         CT_CHQ_RETURN,
                         CT_TOT_PAID_AMT,
                         CT_TOT_REC_AMT,
                         CT_CASH_COUNTED,
                         CT_PRINT_WITHDRAW_SLIP,
                         CT_SCROLL_NUM,
                         CT_SELF_THPARTY,
                         CT_PID_VERIFIED,
                         CT_SIGN_VERIFIED,
                         CT_SIGN_COMB_SL,
                         CT_PERSON_NAME,
                         CT_REMARKS1,
                         CT_REMARKS2,
                         CT_REMARKS3,
                         POST_TRAN_BRN,
                         POST_TRAN_DATE,
                         POST_TRAN_BATCH_NUM,
                         POST_TRAN_BATCH_SL,
                         CT_ENTD_BY,
                         CT_ENTD_ON,
                         CT_LAST_MOD_BY,
                         CT_LAST_MOD_ON,
                         CT_AUTH_BY,
                         CT_AUTH_ON,
                         CT_REJ_BY,
                         CT_REJ_ON)
        VALUES (V_DML_TYPE,
                V_LOGIN_USER,
                V_INSTANCE_NUM,
                V_OS_USER,
                V_TERMINAL,
                V_IP_ADDRESS,
                V_SID,V_SERIAL,
                V_AUDSID,
                SYSTIMESTAMP,
                V_LOGON_TIME,
                NVL(:NEW.CTRAN_ENTITY_NUM,:OLD.CTRAN_ENTITY_NUM),
                NVL(:NEW.CT_BRN_CODE,:OLD.CT_BRN_CODE),
                NVL(:NEW.CT_TRAN_DATE,:OLD.CT_TRAN_DATE),
                NVL(:NEW.CT_CASHIER_ID,:OLD.CT_CASHIER_ID),
                NVL(:NEW.CT_DAY_SL,:OLD.CT_DAY_SL),
                NVL(:NEW.CT_TYPE_OF_ENTRY,:OLD.CT_TYPE_OF_ENTRY),
                NVL(:NEW.CT_REC_PAYMENT,:OLD.CT_REC_PAYMENT),
                :NEW.CT_TOKEN_NUMBER,
                :NEW.CT_TRAN_BAT_NUMBER,
                :NEW.CT_TRAN_BAT_SL_NUM,
                :NEW.CT_TRAN_CODE,
                :NEW.CT_INTERNAL_AC_NUM,
                :NEW.CT_GLACC_CODE,
                :NEW.CT_CURR_CODE,
                :NEW.CT_AMOUNT,
                :NEW.CT_PAN_GIR_NUMBER,
                :NEW.CT_WITHDRAW_MODE,
                :NEW.CT_CHEQUE_PFX,
                :NEW.CT_CHEQUE_NUM,
                :NEW.CT_CHEQUE_DATE,
                :NEW.CT_WITHDRAW_SLIP_NUM,
                :NEW.CT_CHQ_RETURN,
                :NEW.CT_TOT_PAID_AMT,
                :NEW.CT_TOT_REC_AMT,
                :NEW.CT_CASH_COUNTED,
                :NEW.CT_PRINT_WITHDRAW_SLIP,
                :NEW.CT_SCROLL_NUM,
                :NEW.CT_SELF_THPARTY,
                :NEW.CT_PID_VERIFIED,
                :NEW.CT_SIGN_VERIFIED,
                :NEW.CT_SIGN_COMB_SL,
                :NEW.CT_PERSON_NAME,
                :NEW.CT_REMARKS1,
                :NEW.CT_REMARKS2,
                :NEW.CT_REMARKS3,
                :NEW.POST_TRAN_BRN,
                :NEW.POST_TRAN_DATE,
                :NEW.POST_TRAN_BATCH_NUM,
                :NEW.POST_TRAN_BATCH_SL,
                :NEW.CT_ENTD_BY,
                :NEW.CT_ENTD_ON,
                :NEW.CT_LAST_MOD_BY,
                :NEW.CT_LAST_MOD_ON,
                :NEW.CT_AUTH_BY,
                :NEW.CT_AUTH_ON,
                :NEW.CT_REJ_BY,
                :NEW.CT_REJ_ON);
END;
/


CREATE OR REPLACE TRIGGER ISLAMIC_DEV.TRIG_CTRAN_LOG_2021 
   BEFORE INSERT OR UPDATE OR DELETE
   ON CTRAN2021
   FOR EACH ROW
DISABLE
DECLARE
   V_LOGIN_USER          VARCHAR2 (1000);
   V_INSTANCE_NUM        VARCHAR2 (1000);
   V_CLIENT_IP_ADDRESS   VARCHAR2 (1000);
   V_CURRENT_SCN         VARCHAR2 (1000);
   V_OS_USER             VARCHAR2 (1000);
   V_TERMINAL            VARCHAR2 (1000);
   V_IP_ADDRESS          VARCHAR2 (1000);
   V_SID                 VARCHAR2 (1000);
   V_SERIAL              VARCHAR2 (1000);
   V_LOGON_TIME          DATE;
   V_DML_TYPE            VARCHAR2(10);
   V_AUDSID                 NUMBER;
BEGIN
   V_LOGIN_USER := ORA_LOGIN_USER;
   V_INSTANCE_NUM := ORA_INSTANCE_NUM;
   V_OS_USER := SYS_CONTEXT ('USERENV', 'OS_USER');
   V_IP_ADDRESS := SYS_CONTEXT ('USERENV', 'IP_ADDRESS');
   V_SID := SYS_CONTEXT ('USERENV', 'SID');

   SELECT SERIAL#,LOGON_TIME,MACHINE,AUDSID
   INTO V_SERIAL,V_LOGON_TIME,V_TERMINAL,V_AUDSID FROM GV$SESSION
   WHERE SID=SYS_CONTEXT('USERENV','SID')
    AND INST_ID=ORA_INSTANCE_NUM;
    
    IF INSERTING THEN
    V_DML_TYPE:='I';
    END IF;
    
    IF UPDATING THEN
    V_DML_TYPE:='U';
    END IF;
    
    IF DELETING THEN
    V_DML_TYPE:='D';
    END IF;

   INSERT INTO CTRANLOG (DML_TYPE,
                         CT_LOGIN_USER,
                         CT_INSTANCE_NUM,
                         CT_OS_USER,
                         CT_TERMINAL,
                         CT_IP_ADDRESS,
                         CT_SID,
                         CT_SERIAL,
                         CT_AUDSID,
                         CT_SYSTIMESTAMP,
                         CT_LOGON_TIME,
                         CTRAN_ENTITY_NUM,
                         CT_BRN_CODE,
                         CT_TRAN_DATE,
                         CT_CASHIER_ID,
                         CT_DAY_SL,
                         CT_TYPE_OF_ENTRY,
                         CT_REC_PAYMENT,
                         CT_TOKEN_NUMBER,
                         CT_TRAN_BAT_NUMBER,
                         CT_TRAN_BAT_SL_NUM,
                         CT_TRAN_CODE,
                         CT_INTERNAL_AC_NUM,
                         CT_GLACC_CODE,
                         CT_CURR_CODE,
                         CT_AMOUNT,
                         CT_PAN_GIR_NUMBER,
                         CT_WITHDRAW_MODE,
                         CT_CHEQUE_PFX,
                         CT_CHEQUE_NUM,
                         CT_CHEQUE_DATE,
                         CT_WITHDRAW_SLIP_NUM,
                         CT_CHQ_RETURN,
                         CT_TOT_PAID_AMT,
                         CT_TOT_REC_AMT,
                         CT_CASH_COUNTED,
                         CT_PRINT_WITHDRAW_SLIP,
                         CT_SCROLL_NUM,
                         CT_SELF_THPARTY,
                         CT_PID_VERIFIED,
                         CT_SIGN_VERIFIED,
                         CT_SIGN_COMB_SL,
                         CT_PERSON_NAME,
                         CT_REMARKS1,
                         CT_REMARKS2,
                         CT_REMARKS3,
                         POST_TRAN_BRN,
                         POST_TRAN_DATE,
                         POST_TRAN_BATCH_NUM,
                         POST_TRAN_BATCH_SL,
                         CT_ENTD_BY,
                         CT_ENTD_ON,
                         CT_LAST_MOD_BY,
                         CT_LAST_MOD_ON,
                         CT_AUTH_BY,
                         CT_AUTH_ON,
                         CT_REJ_BY,
                         CT_REJ_ON)
        VALUES (V_DML_TYPE,
                V_LOGIN_USER,
                V_INSTANCE_NUM,
                V_OS_USER,
                V_TERMINAL,
                V_IP_ADDRESS,
                V_SID,V_SERIAL,
                V_AUDSID,
                SYSTIMESTAMP,
                V_LOGON_TIME,
                NVL(:NEW.CTRAN_ENTITY_NUM,:OLD.CTRAN_ENTITY_NUM),
                NVL(:NEW.CT_BRN_CODE,:OLD.CT_BRN_CODE),
                NVL(:NEW.CT_TRAN_DATE,:OLD.CT_TRAN_DATE),
                NVL(:NEW.CT_CASHIER_ID,:OLD.CT_CASHIER_ID),
                NVL(:NEW.CT_DAY_SL,:OLD.CT_DAY_SL),
                NVL(:NEW.CT_TYPE_OF_ENTRY,:OLD.CT_TYPE_OF_ENTRY),
                NVL(:NEW.CT_REC_PAYMENT,:OLD.CT_REC_PAYMENT),
                :NEW.CT_TOKEN_NUMBER,
                :NEW.CT_TRAN_BAT_NUMBER,
                :NEW.CT_TRAN_BAT_SL_NUM,
                :NEW.CT_TRAN_CODE,
                :NEW.CT_INTERNAL_AC_NUM,
                :NEW.CT_GLACC_CODE,
                :NEW.CT_CURR_CODE,
                :NEW.CT_AMOUNT,
                :NEW.CT_PAN_GIR_NUMBER,
                :NEW.CT_WITHDRAW_MODE,
                :NEW.CT_CHEQUE_PFX,
                :NEW.CT_CHEQUE_NUM,
                :NEW.CT_CHEQUE_DATE,
                :NEW.CT_WITHDRAW_SLIP_NUM,
                :NEW.CT_CHQ_RETURN,
                :NEW.CT_TOT_PAID_AMT,
                :NEW.CT_TOT_REC_AMT,
                :NEW.CT_CASH_COUNTED,
                :NEW.CT_PRINT_WITHDRAW_SLIP,
                :NEW.CT_SCROLL_NUM,
                :NEW.CT_SELF_THPARTY,
                :NEW.CT_PID_VERIFIED,
                :NEW.CT_SIGN_VERIFIED,
                :NEW.CT_SIGN_COMB_SL,
                :NEW.CT_PERSON_NAME,
                :NEW.CT_REMARKS1,
                :NEW.CT_REMARKS2,
                :NEW.CT_REMARKS3,
                :NEW.POST_TRAN_BRN,
                :NEW.POST_TRAN_DATE,
                :NEW.POST_TRAN_BATCH_NUM,
                :NEW.POST_TRAN_BATCH_SL,
                :NEW.CT_ENTD_BY,
                :NEW.CT_ENTD_ON,
                :NEW.CT_LAST_MOD_BY,
                :NEW.CT_LAST_MOD_ON,
                :NEW.CT_AUTH_BY,
                :NEW.CT_AUTH_ON,
                :NEW.CT_REJ_BY,
                :NEW.CT_REJ_ON);
END;
/


CREATE OR REPLACE TRIGGER TRIG_CTRAN_LOG_2021
   BEFORE INSERT OR UPDATE OR DELETE
   ON CTRAN2021
   FOR EACH ROW
DISABLE
DECLARE
   V_LOGIN_USER          VARCHAR2 (1000);
   V_INSTANCE_NUM        VARCHAR2 (1000);
   V_CLIENT_IP_ADDRESS   VARCHAR2 (1000);
   V_CURRENT_SCN         VARCHAR2 (1000);
   V_OS_USER             VARCHAR2 (1000);
   V_TERMINAL            VARCHAR2 (1000);
   V_IP_ADDRESS          VARCHAR2 (1000);
   V_SID                 VARCHAR2 (1000);
   V_SERIAL              VARCHAR2 (1000);
   V_LOGON_TIME          DATE;
   V_DML_TYPE            VARCHAR2(10);
   V_AUDSID                 NUMBER;
BEGIN
   V_LOGIN_USER := ORA_LOGIN_USER;
   V_INSTANCE_NUM := ORA_INSTANCE_NUM;
   V_OS_USER := SYS_CONTEXT ('USERENV', 'OS_USER');
   V_IP_ADDRESS := SYS_CONTEXT ('USERENV', 'IP_ADDRESS');
   V_SID := SYS_CONTEXT ('USERENV', 'SID');

   SELECT SERIAL#,LOGON_TIME,MACHINE,AUDSID
   INTO V_SERIAL,V_LOGON_TIME,V_TERMINAL,V_AUDSID FROM GV$SESSION
   WHERE SID=SYS_CONTEXT('USERENV','SID')
    AND INST_ID=ORA_INSTANCE_NUM;
    
    IF INSERTING THEN
    V_DML_TYPE:='I';
    END IF;
    
    IF UPDATING THEN
    V_DML_TYPE:='U';
    END IF;
    
    IF DELETING THEN
    V_DML_TYPE:='D';
    END IF;

   INSERT INTO CTRANLOG (DML_TYPE,
                         CT_LOGIN_USER,
                         CT_INSTANCE_NUM,
                         CT_OS_USER,
                         CT_TERMINAL,
                         CT_IP_ADDRESS,
                         CT_SID,
                         CT_SERIAL,
                         CT_AUDSID,
                         CT_SYSTIMESTAMP,
                         CT_LOGON_TIME,
                         CTRAN_ENTITY_NUM,
                         CT_BRN_CODE,
                         CT_TRAN_DATE,
                         CT_CASHIER_ID,
                         CT_DAY_SL,
                         CT_TYPE_OF_ENTRY,
                         CT_REC_PAYMENT,
                         CT_TOKEN_NUMBER,
                         CT_TRAN_BAT_NUMBER,
                         CT_TRAN_BAT_SL_NUM,
                         CT_TRAN_CODE,
                         CT_INTERNAL_AC_NUM,
                         CT_GLACC_CODE,
                         CT_CURR_CODE,
                         CT_AMOUNT,
                         CT_PAN_GIR_NUMBER,
                         CT_WITHDRAW_MODE,
                         CT_CHEQUE_PFX,
                         CT_CHEQUE_NUM,
                         CT_CHEQUE_DATE,
                         CT_WITHDRAW_SLIP_NUM,
                         CT_CHQ_RETURN,
                         CT_TOT_PAID_AMT,
                         CT_TOT_REC_AMT,
                         CT_CASH_COUNTED,
                         CT_PRINT_WITHDRAW_SLIP,
                         CT_SCROLL_NUM,
                         CT_SELF_THPARTY,
                         CT_PID_VERIFIED,
                         CT_SIGN_VERIFIED,
                         CT_SIGN_COMB_SL,
                         CT_PERSON_NAME,
                         CT_REMARKS1,
                         CT_REMARKS2,
                         CT_REMARKS3,
                         POST_TRAN_BRN,
                         POST_TRAN_DATE,
                         POST_TRAN_BATCH_NUM,
                         POST_TRAN_BATCH_SL,
                         CT_ENTD_BY,
                         CT_ENTD_ON,
                         CT_LAST_MOD_BY,
                         CT_LAST_MOD_ON,
                         CT_AUTH_BY,
                         CT_AUTH_ON,
                         CT_REJ_BY,
                         CT_REJ_ON)
        VALUES (V_DML_TYPE,
                V_LOGIN_USER,
                V_INSTANCE_NUM,
                V_OS_USER,
                V_TERMINAL,
                V_IP_ADDRESS,
                V_SID,V_SERIAL,
                V_AUDSID,
                SYSTIMESTAMP,
                V_LOGON_TIME,
                NVL(:NEW.CTRAN_ENTITY_NUM,:OLD.CTRAN_ENTITY_NUM),
                NVL(:NEW.CT_BRN_CODE,:OLD.CT_BRN_CODE),
                NVL(:NEW.CT_TRAN_DATE,:OLD.CT_TRAN_DATE),
                NVL(:NEW.CT_CASHIER_ID,:OLD.CT_CASHIER_ID),
                NVL(:NEW.CT_DAY_SL,:OLD.CT_DAY_SL),
                NVL(:NEW.CT_TYPE_OF_ENTRY,:OLD.CT_TYPE_OF_ENTRY),
                NVL(:NEW.CT_REC_PAYMENT,:OLD.CT_REC_PAYMENT),
                :NEW.CT_TOKEN_NUMBER,
                :NEW.CT_TRAN_BAT_NUMBER,
                :NEW.CT_TRAN_BAT_SL_NUM,
                :NEW.CT_TRAN_CODE,
                :NEW.CT_INTERNAL_AC_NUM,
                :NEW.CT_GLACC_CODE,
                :NEW.CT_CURR_CODE,
                :NEW.CT_AMOUNT,
                :NEW.CT_PAN_GIR_NUMBER,
                :NEW.CT_WITHDRAW_MODE,
                :NEW.CT_CHEQUE_PFX,
                :NEW.CT_CHEQUE_NUM,
                :NEW.CT_CHEQUE_DATE,
                :NEW.CT_WITHDRAW_SLIP_NUM,
                :NEW.CT_CHQ_RETURN,
                :NEW.CT_TOT_PAID_AMT,
                :NEW.CT_TOT_REC_AMT,
                :NEW.CT_CASH_COUNTED,
                :NEW.CT_PRINT_WITHDRAW_SLIP,
                :NEW.CT_SCROLL_NUM,
                :NEW.CT_SELF_THPARTY,
                :NEW.CT_PID_VERIFIED,
                :NEW.CT_SIGN_VERIFIED,
                :NEW.CT_SIGN_COMB_SL,
                :NEW.CT_PERSON_NAME,
                :NEW.CT_REMARKS1,
                :NEW.CT_REMARKS2,
                :NEW.CT_REMARKS3,
                :NEW.POST_TRAN_BRN,
                :NEW.POST_TRAN_DATE,
                :NEW.POST_TRAN_BATCH_NUM,
                :NEW.POST_TRAN_BATCH_SL,
                :NEW.CT_ENTD_BY,
                :NEW.CT_ENTD_ON,
                :NEW.CT_LAST_MOD_BY,
                :NEW.CT_LAST_MOD_ON,
                :NEW.CT_AUTH_BY,
                :NEW.CT_AUTH_ON,
                :NEW.CT_REJ_BY,
                :NEW.CT_REJ_ON);
END;
/


CREATE OR REPLACE SYNONYM CTRAN FOR CTRAN2021;


CREATE OR REPLACE SYNONYM CTRANDD FOR CTRANDD2021;


CREATE OR REPLACE SYNONYM TRAN FOR TRAN2021;


CREATE OR REPLACE SYNONYM TRANBAT FOR TRANBAT2021;


ALTER TABLE ACCASHPOST2021 ADD (
  PRIMARY KEY
  (ACCASHPOST_ENTITY_NUM, ACCASHPOST_BRN_CODE, ACCASHPOST_CURR_CODE, ACCASHPOST_DATE)
  USING INDEX
    TABLESPACE CBSINDEX
    PCTFREE    10
    INITRANS   2
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                PCTINCREASE      0
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               )
  ENABLE VALIDATE);

ALTER TABLE ACCASHSUM2021 ADD (
  PRIMARY KEY
  (ACCASHSUM_ENTITY_NUM, ACCASHSUM_BRN_CODE, ACCASHSUM_ACNT_NUM, ACCASHSUM_TRAN_DATE)
  USING INDEX
    TABLESPACE CBSINDEX
    PCTFREE    10
    INITRANS   2
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                PCTINCREASE      0
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               )
  ENABLE VALIDATE);

ALTER TABLE CTRAN2021 ADD (
  CONSTRAINT IDX_CTRAN2021
  PRIMARY KEY
  (CTRAN_ENTITY_NUM, CT_BRN_CODE, CT_TRAN_DATE, CT_CASHIER_ID, CT_DAY_SL)
  USING INDEX IDX_CTRAN2021
  ENABLE VALIDATE);

ALTER TABLE CTRANDD2021 ADD (
  PRIMARY KEY
  (CTRANDD_ENTITY_NUM, CTDD_BRN_CODE, CTDD_TRAN_DATE, CTDD_CASHIER_ID, CTDD_DAY_SL, CTDD_UP_SL)
  USING INDEX
    TABLESPACE CBSINDEX
    PCTFREE    10
    INITRANS   2
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                PCTINCREASE      0
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               )
  ENABLE VALIDATE);

ALTER TABLE GLSUM2021 ADD (
  PRIMARY KEY
  (GLSUM_ENTITY_NUM, GLSUM_BRANCH_CODE, GLSUM_GLACC_CODE, GLSUM_CURR_CODE, GLSUM_TRAN_DATE)
  USING INDEX
    TABLESPACE CBSINDEX
    PCTFREE    10
    INITRANS   2
    MAXTRANS   255
    STORAGE    (
                INITIAL          64K
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                PCTINCREASE      0
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               )
  ENABLE VALIDATE);

ALTER TABLE SEGGLASUM2021 ADD (
  PRIMARY KEY
  (SEGGLAS_ENTITY_NUM, SEGGLAS_BRN_CODE, SEGGLAS_SEG_METHOD, SEGGLAS_SEG_CODE, SEGGLAS_PROC_DATE, SEGGLAS_GLACC_CODE, SEGGLAS_CURR_CODE, SEGGLAS_TRAN_DATE)
  USING INDEX
    TABLESPACE CBSINDEX
    PCTFREE    10
    INITRANS   2
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                PCTINCREASE      0
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               )
  ENABLE VALIDATE);

ALTER TABLE SEGREPTRAN2021 ADD (
  PRIMARY KEY
  (SEGREPTRAN_ENTITY_NUM, SEGREPTRAN_BRN_CODE, SEGREPTRAN_METHOD, SEGREPTRAN_SEG_CODE, SEGREPTRAN_PROC_DATE, SEGREPTRAN_TR_DATE, SEGREPTRAN_TR_BATCH, SEGREPTRAN_TR_BAT_SL_NUM, SEGREPTRAN_CONTRA_BAT_SL_NUM)
  USING INDEX
    TABLESPACE CBSINDEX
    PCTFREE    10
    INITRANS   2
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                PCTINCREASE      0
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               )
  ENABLE VALIDATE);

ALTER TABLE TRAN2021 ADD (
  CONSTRAINT PK_TRAN2021
  PRIMARY KEY
  (TRAN_ENTITY_NUM, TRAN_BRN_CODE, TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER, TRAN_BATCH_SL_NUM)
  USING INDEX IDX_TRAN2021_PK
  ENABLE VALIDATE);

ALTER TABLE TRANADV2021 ADD (
  PRIMARY KEY
  (TRANADV_ENTITY_NUM, TRANADV_BRN_CODE, TRANADV_DATE_OF_TRAN, TRANADV_BATCH_NUMBER, TRANADV_BATCH_SL_NUM)
  USING INDEX
    TABLESPACE CBSINDEX
    PCTFREE    10
    INITRANS   2
    MAXTRANS   255
    STORAGE    (
                INITIAL          64K
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                PCTINCREASE      0
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               )
  ENABLE VALIDATE);

ALTER TABLE TRANADVADDN2021 ADD (
  PRIMARY KEY
  (TRANADVADDN_ENTITY_NUM, TRANADV_BRN_CODE, TRANADV_DATE_OF_TRAN, TRANADV_BATCH_NUMBER, TRANADV_BATCH_SL_NUM)
  USING INDEX
    TABLESPACE CBSINDEX
    PCTFREE    10
    INITRANS   2
    MAXTRANS   255
    STORAGE    (
                INITIAL          64K
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                PCTINCREASE      0
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               )
  ENABLE VALIDATE);

ALTER TABLE TRANBAT2021 ADD (
  CONSTRAINT PK_TRANBAT2021
  PRIMARY KEY
  (TRANBAT_ENTITY_NUM, TRANBAT_BRN_CODE, TRANBAT_DATE_OF_TRAN, TRANBAT_BATCH_NUMBER)
  USING INDEX IDX_TRANBAT2021_PK
  ENABLE VALIDATE);
