DROP TABLE SBLPROD.ACCUPDATELABEL CASCADE CONSTRAINTS;

CREATE TABLE SBLPROD.ACCUPDATELABEL
(
  ACCLABEL_CODE      NUMBER(6),
  ACCLABEL_DESC      VARCHAR2(150 BYTE),
  ACCLABEL_SUB_TYPE  NUMBER(6),
  ACCFIELD_DESC      VARCHAR2(150 BYTE)
)
TABLESPACE TBFES
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE;


ALTER TABLE SBLPROD.ACCUPDATELABEL ADD (
  PRIMARY KEY
  (ACCLABEL_CODE, ACCLABEL_SUB_TYPE)
  USING INDEX
    TABLESPACE TBFES
    PCTFREE    10
    INITRANS   2
    MAXTRANS   255
    STORAGE    (
                INITIAL          64K
                NEXT             1M
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                PCTINCREASE      0
                BUFFER_POOL      DEFAULT
               )
  ENABLE VALIDATE);


--  There is no statement for index SBLPROD.SYS_C001388517.
--  The object is created when the parent object is created.
