DROP TABLE SBLPROD.ACCUPDATETYPE CASCADE CONSTRAINTS;

CREATE TABLE SBLPROD.ACCUPDATETYPE
(
  ACCTYPE_CODE  NUMBER,
  ACCTYPE_DESC  VARCHAR2(200 BYTE)
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


ALTER TABLE SBLPROD.ACCUPDATETYPE ADD (
  PRIMARY KEY
  (ACCTYPE_CODE)
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


--  There is no statement for index SBLPROD.SYS_C001388512.
--  The object is created when the parent object is created.
