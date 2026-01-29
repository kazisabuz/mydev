/*Data generation for the Remittance came from abroad for a particular time duration.*/
CREATE TABLE REM_DATA
(
  NAME_RECIEVER          VARCHAR2(256 BYTE),
  DOC_ID                 VARCHAR2(35 BYTE),
  ACTUAL_ACCOUNT_NUMBER  CHAR(4 BYTE),
  BANK_NAME              CHAR(4 BYTE),
  SENDER_NAME            VARCHAR2(128 BYTE),
  PROFESSION             CHAR(4 BYTE),
  EXCHANGE_NAME          VARCHAR2(20 BYTE)      NOT NULL,
  REMCSP_REF_DATE        DATE,
  FC_AMOUNT              CHAR(4 BYTE),
  EXC_RATE               CHAR(4 BYTE),
  CREDIT                 NUMBER,
  PAYMENT_TYPE           CHAR(3 BYTE),
  INCENTIVE_AMT          NUMBER,
  PAID_DATE              DATE                   NOT NULL,
  REF_NO                 VARCHAR2(50 BYTE),
  DOCUMENT_1             VARCHAR2(250 BYTE),
  DOCUMENT_2             VARCHAR2(250 BYTE),
  BRN_CODE				 NUMBER 
)
TABLESPACE TBFES
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


CREATE OR REPLACE PROCEDURE SP_GEN_REM_THREAD AS
  LN_DUMMY NUMBER;
BEGIN
  DBMS_JOB.SUBMIT(LN_DUMMY, 'begin SP_GEN_REM_DATA(1,50); end;',instance=>1);
  DBMS_JOB.SUBMIT(LN_DUMMY, 'begin SP_GEN_REM_DATA(51,100); end;',instance=>1);
  DBMS_JOB.SUBMIT(LN_DUMMY, 'begin SP_GEN_REM_DATA(101,150); end;',instance=>1);
  DBMS_JOB.SUBMIT(LN_DUMMY, 'begin SP_GEN_REM_DATA(151,200); end;',instance=>1);
  DBMS_JOB.SUBMIT(LN_DUMMY, 'begin SP_GEN_REM_DATA(201,250); end;',instance=>1);
  DBMS_JOB.SUBMIT(LN_DUMMY, 'begin SP_GEN_REM_DATA(251,300); end;',instance=>1);
  DBMS_JOB.SUBMIT(LN_DUMMY, 'begin SP_GEN_REM_DATA(301,350); end;',instance=>2);
  DBMS_JOB.SUBMIT(LN_DUMMY, 'begin SP_GEN_REM_DATA(351,400); end;',instance=>2);
  DBMS_JOB.SUBMIT(LN_DUMMY, 'begin SP_GEN_REM_DATA(401,450); end;',instance=>2);
  DBMS_JOB.SUBMIT(LN_DUMMY, 'begin SP_GEN_REM_DATA(451,500); end;',instance=>2);
  DBMS_JOB.SUBMIT(LN_DUMMY, 'begin SP_GEN_REM_DATA(501,550); end;',instance=>2);
  DBMS_JOB.SUBMIT(LN_DUMMY, 'begin SP_GEN_REM_DATA(551,600); end;',instance=>2);
  COMMIT;
END SP_GEN_REM_THREAD;
/

CREATE OR REPLACE PROCEDURE SP_REM_DATA (
   P_BRANCH_CODE      IN     NUMBER DEFAULT 0 )
IS
    P_ERROR_MSG VARCHAR2(1000);
BEGIN
   INSERT INTO REM_DATA 
SELECT (SELECT d.creditor_name
          FROM remittance_data d
         WHERE     d.exchange_house_code = m.remcsp_exchou_code
               AND d.reference_no = m.remcsp_ref_no
               AND d.reference_date = m.remcsp_ref_date
               AND D.PROCCESS_STATUS = 'COMPLETED'
               AND d.remittance_msg_type = 'WEB')
          AS NAME_RECIEVER,
       m.remcsp_id_num AS DOC_ID,
       '' actual_account_number,
       '' BANK_NAME,
       (SELECT d.sender_name
          FROM remittance_data d
         WHERE     d.remittance_msg_type = 'WEB'
               AND d.exchange_house_code = m.remcsp_exchou_code
               AND d.reference_no = m.remcsp_ref_no
               AND d.reference_date = m.remcsp_ref_date)
          AS SENDER_NAME,
       '' AS PROFESSION,
       m.remcsp_exchou_code AS EXCHANGE_NAME,
       m.remcsp_ref_date,
       '' AS FC_AMOUNT,
       '' AS EXC_RATE,
       TO_NUMBER (
          (SELECT r.remcsp_tran_amount AS CREDIT
             FROM remcashpay r
            WHERE     r.remcsp_entity_num = 1
                  AND r.remcsp_brn_code = m.remcsp_brn_code
                  AND r.remcsp_tran_date >=
                         TO_DATE ('01-07-2019', 'dd-MM-yyyy')
                  AND r.remcsp_tran_date <=
                         TO_DATE ('31-12-2019', 'dd-MM-yyyy')
                  AND r.remcsp_auth_by IS NOT NULL
                  AND r.remcsp_entry_type = 'R'
                  AND r.remcsp_is_reversed = 0
                  AND r.remcsp_ref_no = m.remcsp_ref_no
                  AND r.remcsp_pin = m.remcsp_pin))
          AS CREDIT,
       'WEB' AS PAYMENT_TYPE,
       TO_NUMBER (m.remcsp_tran_amount) INCENTIVE_AMT,
       m.remcsp_tran_date PAID_DATE,
       m.REMCSP_REF_NO AS REF_NO,
       m.remcsp_doc1 AS DOCUMENT_1,
       m.remcsp_doc2 AS DOCUMENT_2,
	   M.remcsp_brn_code  BRN_CODE
  FROM remcashpay m
 WHERE     m.remcsp_entity_num = 1
       AND M.remcsp_tran_date >= TO_DATE ('01-07-2019', 'dd-MM-yyyy')
       AND M.remcsp_tran_date <= TO_DATE ('31-12-2019', 'dd-MM-yyyy')
       AND m.remcsp_auth_by IS NOT NULL
       AND m.remcsp_is_reversed = 0
       AND m.REMCSP_ENTRY_TYPE = 'B'
       AND m.remcsp_cash_type = '2'
       AND M.remcsp_brn_code = P_BRANCH_CODE ;
   COMMIT;
EXCEPTION
   WHEN OTHERS
   THEN
      P_ERROR_MSG := 'ERROR ' || P_BRANCH_CODE || ' IN SP_INCOMEEXPENSE' || SQLERRM;
END;
/

CREATE OR REPLACE PROCEDURE SP_GEN_REM_DATA (
   P_FROM_BRN    NUMBER,
   P_TO_BRN      NUMBER)
IS
   V_CBD           DATE;
   P_ERROR_MSG     VARCHAR2 (1000);
   V_DUMMY_COUNT   NUMBER;
   V_ASON_DATE     DATE;
BEGIN
   V_ASON_DATE := TRUNC (SYSDATE)-1 ;

  --V_ASON_DATE := '03-JUN-2019';

   FOR IDX IN (  SELECT *
                   FROM (  SELECT BRANCH_CODE, ROWNUM BRANCH_SL
                             FROM MIG_DETAIL
                         ORDER BY BRANCH_CODE)
                  WHERE BRANCH_SL BETWEEN P_FROM_BRN AND P_TO_BRN
               ORDER BY BRANCH_CODE)
   LOOP


      SP_REM_DATA (IDX.BRANCH_CODE );
      COMMIT;
   END LOOP;

END SP_GEN_REM_DATA;
/
