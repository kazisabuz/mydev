/*Manually update different tables for changing the product code of a particular account*/
create table PRODUCT_CODE_CHANGE
(
  BRANCH_CODE               NUMBER(5),
  ACCTUAL_ACCOUNT_NUMBER    VARCHAR2(25),
  INTERNAL_ACCOUNT_NUMBER   NUMBER(14),
  PREVIOUS_ACCOUNT_TYPE     VARCHAR2(5),
  NEW_ACCOUNT_TYPE          VARCHAR2(5),
  PREVIOUS_ACCOUNT_SUB_TYPE VARCHAR2(5),
  NEW_ACCOUNT_SUB_TYPE      VARCHAR2(5),
  PREVIOUS_PRODUCT_CODE     NUMBER(4),
  NEW_PRODUCT_CODE          NUMBER(4),
  PREVIOUS_GL_CODE          VARCHAR2(15),
  NEW_GL_CODE               VARCHAR2(15),
  PREVIOUS_ACCRUAL_GL       VARCHAR2(15),
  NEW_ACCRUAL_GL            VARCHAR2(15),
  PREVIOUS_INCOME_GL        VARCHAR2(15),
  NEW_INCOME_GL             VARCHAR2(15)
) ;

----------------- Internal account number generation ----------------------


DECLARE
  V_COUNT NUMBER := 0;
begin
  for idx in (select p.acctual_account_number, i.iaclink_internal_acnum
                from product_code_change p, iaclink i
               where i.iaclink_actual_acnum = p.acctual_account_number) loop
    update product_code_change c
       set c.internal_account_number = idx.iaclink_internal_acnum
     where c.acctual_account_number = idx.acctual_account_number;
    V_COUNT := V_COUNT + SQL%ROWCOUNT;
  end loop;
  DBMS_OUTPUT.put_line(V_COUNT);
end;


---------------------- Previous subtype update --------------



UPDATE PRODUCT_CODE_CHANGE P
   SET P.PREVIOUS_ACCOUNT_SUB_TYPE =
       (SELECT A.ACNTS_AC_SUB_TYPE
          FROM ACNTS A
         WHERE A.ACNTS_INTERNAL_ACNUM = P.INTERNAL_ACCOUNT_NUMBER);
		 
-------------------- SUBTYPE required, but not present----------------------


		 
SELECT *
  FROM PRODUCT_CODE_CHANGE P
 WHERE P.NEW_ACCOUNT_TYPE IN
       (SELECT A.ACTYPE_CODE FROM ACTYPES A WHERE A.ACTYPE_SUB_TYPE_REQD = 1)
   AND P.NEW_ACCOUNT_SUB_TYPE IS NULL;
   


------------------------ Previous GL code update -----------------


declare
  V_COUNT NUMBER := 0;
begin
  for idx in (select p.acctual_account_number, l.product_glacc_code
                from product_code_change p, products l
               where l.product_code = p.previous_product_code) loop
    update product_code_change c
       set c.previous_gl_code = idx.product_glacc_code
     where c.acctual_account_number = idx.acctual_account_number;
    V_COUNT := V_COUNT + SQL%ROWCOUNT;
  end loop;
  DBMS_OUTPUT.put_line(V_COUNT);
end;



------------------------ New GL code update -----------------



declare
  V_COUNT NUMBER := 0;
begin
  for idx in (select p.acctual_account_number, l.product_glacc_code
                from product_code_change p, products l
               where l.product_code = p.new_product_code) loop
    update product_code_change c
       set c.new_gl_code = idx.product_glacc_code
     where c.acctual_account_number = idx.acctual_account_number;
    V_COUNT := V_COUNT + SQL%ROWCOUNT;
  end loop;
  DBMS_OUTPUT.put_line(V_COUNT);
end;



------------------------ Previous Accrual & Income GL code update -----------------


declare
  V_COUNT NUMBER := 0;
begin
  for idx in (select p.acctual_account_number,
                     l.lnprdac_int_accr_gl,
                     l.lnprdac_int_income_gl
                from product_code_change p, lnprodacpm l
               where l.lnprdac_prod_code = p.previous_product_code) loop
    update product_code_change c
       set c.previous_accrual_gl = idx.lnprdac_int_accr_gl,
           c.previous_income_gl  = idx.lnprdac_int_income_gl
     where c.acctual_account_number = idx.acctual_account_number;
    V_COUNT := V_COUNT + SQL%ROWCOUNT;
  end loop;
  DBMS_OUTPUT.put_line(V_COUNT);
end;



------------------------ New Accrual & Income GL code update -----------------


declare
  V_COUNT NUMBER := 0;
begin
  for idx in (select p.acctual_account_number,
                     l.lnprdac_int_accr_gl,
                     l.lnprdac_int_income_gl
                from product_code_change p, lnprodacpm l
               where l.lnprdac_prod_code = p.new_product_code) loop
    update product_code_change c
       set c.new_accrual_gl = idx.lnprdac_int_accr_gl,
           c.new_income_gl  = idx.lnprdac_int_income_gl
     where c.acctual_account_number = idx.acctual_account_number;
    V_COUNT := V_COUNT + SQL%ROWCOUNT;
  end loop;
  DBMS_OUTPUT.put_line(V_COUNT);
end;




-------------------  Total Accrual amount update ----------------------



declare
  V_COUNT NUMBER := 0;
begin
  for idx in (SELECT LIA.BRANCH_CODE,
       LM.LOANIAMRR_ACNT_NUM,
       ROUND(ABS(SUM(LM.LOANIAMRR_TOTAL_NEW_INT_AMT) + NORM_SUM), 2) TOTAL_ACCRUAL_AMOUNT
  FROM LOANIAMRR LM,
       (SELECT P.BRANCH_CODE,
               P.INTERNAL_ACCOUNT_NUMBER,
               SUM(L.LOANIA_TOTAL_NEW_INT_AMT) NORM_SUM,
               MAX(L.LOANIA_VALUE_DATE) LATEST_ACC_DATE
          FROM PRODUCT_CODE_CHANGE P, LOANIA L, LOANACNTS LL
         WHERE LL.LNACNT_INTERNAL_ACNUM = P.INTERNAL_ACCOUNT_NUMBER
           AND P.INTERNAL_ACCOUNT_NUMBER = L.LOANIA_ACNT_NUM
           AND L.LOANIA_VALUE_DATE > LL.LNACNT_INT_APPLIED_UPTO_DATE
           AND L.LOANIA_ENTITY_NUM = 1
           AND LL.LNACNT_ENTITY_NUM = 1
           AND L.LOANIA_ACNT_NUM = LL.LNACNT_INTERNAL_ACNUM
           AND L.LOANIA_BRN_CODE = P.BRANCH_CODE
           AND L.LOANIA_NPA_STATUS = 0
         GROUP BY P.BRANCH_CODE, P.INTERNAL_ACCOUNT_NUMBER) LIA
 WHERE LM.LOANIAMRR_ENTITY_NUM = 1
   AND LM.LOANIAMRR_BRN_CODE = LIA.BRANCH_CODE
   AND LM.LOANIAMRR_ACNT_NUM = LIA.INTERNAL_ACCOUNT_NUMBER
   AND LM.LOANIAMRR_VALUE_DATE > LIA.LATEST_ACC_DATE
   AND LM.LOANIAMRR_NPA_STATUS = 0
 GROUP BY LIA.BRANCH_CODE, LM.LOANIAMRR_ACNT_NUM, NORM_SUM) loop
    update PRODUCT_CODE_CHANGE  c
       set c.accrual_amount  = idx.total_accrual_amount
     where c.internal_account_number = idx.loaniamrr_acnt_num;
       V_COUNT := V_COUNT + SQL%ROWCOUNT;
  end loop;
    DBMS_OUTPUT.put_line(V_COUNT);
end;















---------------- UPDATE ACNTLINK ------------acntlink_ac_seq_num, acntlink_account_number

declare
  V_COUNT NUMBER := 0;
begin
  for idx in (select p.*
                from acntlink a, product_code_change p
               where a.acntlink_internal_acnum = p.internal_account_number) loop
    update acntlink c
       set c.acntlink_ac_seq_num     = idx.new_product_code ||
                                       SUBSTR(c.ACNTLINK_AC_SEQ_NUM, 5, 2),
           c.acntlink_account_number = substr(c.acntlink_account_number,
                                              1,
                                              17) || idx.new_product_code ||
                                       substr(C.acntlink_account_number,
                                              22,
                                              2)
     where c.acntlink_internal_acnum = idx.internal_account_number;
    V_COUNT := V_COUNT + SQL%ROWCOUNT;
  end loop;
  DBMS_OUTPUT.put_line(V_COUNT);
end;


-------------- UPDATE IACLINK -------------------- iaclink_ac_seq_num, iaclink_account_number, IACLINK_PROD_CODE


declare
  V_COUNT NUMBER := 0;
begin
  for idx in (select p.*
                from acntlink a, product_code_change p
               where a.acntlink_internal_acnum = p.internal_account_number) loop
    update iaclink c
       set c.iaclink_ac_seq_num     = TO_NUMBER (idx.new_product_code ||
                                      SUBSTR(c.iaclink_ac_seq_num, 5, 2)),
           c.iaclink_account_number = substr(c.iaclink_account_number, 1, 17) ||
                                      idx.new_product_code ||
                                      substr(C.IACLINK_ACCOUNT_NUMBER, 22, 2),
           C.IACLINK_PROD_CODE      = IDX.NEW_PRODUCT_CODE
     where c.iaclink_internal_acnum = idx.internal_account_number;
    V_COUNT := V_COUNT + SQL%ROWCOUNT;
  end loop;
  DBMS_OUTPUT.put_line(V_COUNT);
end;


----------- UPDATE ACNTS ---------- acnts_ac_seq_num, acnts_account_number, ACNTS_PROD_CODE, ACNTS_AC_TYPE, ACNTS_GLACC_CODE


declare
  V_COUNT NUMBER := 0;
begin
  for idx in (select p.*
                from acntlink a, product_code_change p
               where a.acntlink_internal_acnum = p.internal_account_number) loop
    update ACNTS c
       set c.acnts_ac_seq_num     = TO_NUMBER (idx.new_product_code ||
                                      SUBSTR(c.acnts_ac_seq_num, 5, 2)),
           c.acnts_account_number = substr(c.acnts_account_number, 1, 17) ||
                                      idx.new_product_code ||
                                      substr(C.ACNTS_ACCOUNT_NUMBER, 22, 2),
           C.ACNTS_PROD_CODE      = IDX.NEW_PRODUCT_CODE,
           C.ACNTS_AC_TYPE = IDX.NEW_ACCOUNT_TYPE,
           C.ACNTS_AC_SUB_TYPE = IDX.NEW_ACCOUNT_SUB_TYPE ,
           C.ACNTS_GLACC_CODE = IDX.NEW_GL_CODE
     where c.acnts_internal_acnum = idx.internal_account_number;
    V_COUNT := V_COUNT + SQL%ROWCOUNT;
  end loop;
  DBMS_OUTPUT.put_line(V_COUNT);
end;



/*



declare
  V_COUNT                   NUMBER := 0;
  V_new_product_code        NUMBER(4) := 0;
  V_internal_account_number NUMBER(14);
  V_NEW_ACCOUNT_TYPE VARCHAR2 (10) ;
  V_NEW_ACCOUNT_SUB_TYPE VARCHAR2(4);
  V_NEW_GL_CODE VARCHAR2(10);
  
  
begin
  for idx in (select p.*
                from acntlink a, product_code_change p
               where a.acntlink_internal_acnum = p.internal_account_number) loop
               
    BEGIN 
               
    V_new_product_code        := IDX.new_product_code;
    V_internal_account_number := IDX.internal_account_number;
    V_NEW_ACCOUNT_TYPE := IDX.NEW_ACCOUNT_TYPE;
    V_NEW_ACCOUNT_SUB_TYPE := IDX.NEW_ACCOUNT_SUB_TYPE ;
    V_NEW_GL_CODE := IDX.NEW_GL_CODE ;
  
    update acntlink c
       set c.acntlink_ac_seq_num     = idx.new_product_code ||
                                       SUBSTR(c.ACNTLINK_AC_SEQ_NUM, 5, 2),
           c.acntlink_account_number = substr(c.acntlink_account_number,
                                              1,
                                              17) || idx.new_product_code ||
                                       substr(C.acntlink_account_number,
                                              22,
                                              2)
     where c.acntlink_internal_acnum = idx.internal_account_number;
     
     update iaclink c
       set c.iaclink_ac_seq_num     = TO_NUMBER (idx.new_product_code ||
                                      SUBSTR(c.iaclink_ac_seq_num, 5, 2)),
           c.iaclink_account_number = substr(c.iaclink_account_number, 1, 17) ||
                                      idx.new_product_code ||
                                      substr(C.IACLINK_ACCOUNT_NUMBER, 22, 2),
           C.IACLINK_PROD_CODE      = IDX.NEW_PRODUCT_CODE
     where c.iaclink_internal_acnum = idx.internal_account_number;
     
     
     update ACNTS c
       set c.acnts_ac_seq_num     = TO_NUMBER (idx.new_product_code ||
                                      SUBSTR(c.acnts_ac_seq_num, 5, 2)),
           c.acnts_account_number = substr(c.acnts_account_number, 1, 17) ||
                                      idx.new_product_code ||
                                      substr(C.ACNTS_ACCOUNT_NUMBER, 22, 2),
           C.ACNTS_PROD_CODE      = IDX.NEW_PRODUCT_CODE,
           C.ACNTS_AC_TYPE = IDX.NEW_ACCOUNT_TYPE,
           C.ACNTS_AC_SUB_TYPE = IDX.NEW_ACCOUNT_SUB_TYPE ,
           C.ACNTS_GLACC_CODE = IDX.NEW_GL_CODE
     where c.acnts_internal_acnum = idx.internal_account_number;
     
     
    V_COUNT := V_COUNT + SQL%ROWCOUNT;
    
    
exception
  when DUP_VAL_ON_INDEX then
    update acntlink c
       set c.acntlink_ac_seq_num     = V_new_product_code ||
                                       SUBSTR(c.ACNTLINK_AC_SEQ_NUM, 5, 1) ||
                                       SUBSTR(c.ACNTLINK_AC_SEQ_NUM, 6, 1) + 1,
           c.acntlink_account_number = substr(c.acntlink_account_number,
                                              1,
                                              17) || V_new_product_code ||
                                       substr(C.acntlink_account_number,
                                              22,
                                              2)
     where c.acntlink_internal_acnum = V_internal_account_number;
     
     
     
     update iaclink c
       set c.iaclink_ac_seq_num     = TO_NUMBER (V_new_product_code ||
                                      SUBSTR(c.iaclink_ac_seq_num, 5, 1) ||  SUBSTR(c.iaclink_ac_seq_num, 6, 1) +1 ),
           c.iaclink_account_number = substr(c.iaclink_account_number, 1, 17) ||
                                      V_new_product_code ||
                                      substr(C.IACLINK_ACCOUNT_NUMBER, 22, 2),
           C.IACLINK_PROD_CODE      = V_NEW_PRODUCT_CODE
     where c.iaclink_internal_acnum = V_internal_account_number;
     
     
     
     
     update ACNTS c
       set c.acnts_ac_seq_num     = TO_NUMBER (V_new_product_code ||
                                      SUBSTR(c.acnts_ac_seq_num, 5, 1) ||SUBSTR(c.acnts_ac_seq_num, 6, 1) +1 ),
           c.acnts_account_number = substr(c.acnts_account_number, 1, 17) || 
                                      V_new_product_code ||
                                      substr(C.ACNTS_ACCOUNT_NUMBER, 22, 2),
           C.ACNTS_PROD_CODE      = V_NEW_PRODUCT_CODE,
           C.ACNTS_AC_TYPE = V_NEW_ACCOUNT_TYPE,
           C.ACNTS_AC_SUB_TYPE = V_NEW_ACCOUNT_SUB_TYPE ,
           C.ACNTS_GLACC_CODE = V_NEW_GL_CODE
     where c.acnts_internal_acnum = V_internal_account_number;
      V_COUNT := V_COUNT + SQL%ROWCOUNT;
      DBMS_OUTPUT.put_line(V_COUNT);
      
      END;
  end loop;
  DBMS_OUTPUT.put_line(V_COUNT);
end;






*/

-------------------------------- LIMITLINE UPDATE -------------------------- lmtline_prod_code


DECLARE
  V_COUNT NUMBER := 0;
BEGIN
  FOR IDX IN (SELECT P.PREVIOUS_PRODUCT_CODE,
                     P.NEW_PRODUCT_CODE,
                     L.LMTLINE_CLIENT_CODE,
                     L.LMTLINE_NUM,
                     L.LMTLINE_PROD_CODE,
                     A.ACASLLDTL_INTERNAL_ACNUM
                FROM LIMITLINE L, PRODUCT_CODE_CHANGE P, ACASLLDTL A
               WHERE P.INTERNAL_ACCOUNT_NUMBER = A.ACASLLDTL_INTERNAL_ACNUM
                 AND A.ACASLLDTL_CLIENT_NUM = L.LMTLINE_CLIENT_CODE
                 AND A.ACASLLDTL_LIMIT_LINE_NUM = L.LMTLINE_NUM) LOOP
    UPDATE LIMITLINE C
       SET C.LMTLINE_PROD_CODE = IDX.NEW_PRODUCT_CODE
     WHERE C.LMTLINE_CLIENT_CODE = IDX.LMTLINE_CLIENT_CODE
       AND C.LMTLINE_NUM = IDX.LMTLINE_NUM
       AND C.LMTLINE_PROD_CODE = IDX.PREVIOUS_PRODUCT_CODE;
    V_COUNT := V_COUNT + SQL%ROWCOUNT;
  END LOOP;
  DBMS_OUTPUT.PUT_LINE(V_COUNT);
END;







---------------------

MERGE INTO ACSEQGEN AC
USING (SELECT 1 ACSEQGEN_ENTITY_NUM,
              P.BRANCH_CODE ACSEQGEN_BRN_CODE,
              0 ACSEQGEN_CIF_NUMBER,
              P.PREVIOUS_PRODUCT_CODE ACSEQGEN_PROD_CODE,
              0 ACSEQGEN_SEQ_NUMBER,
              COUNT(*) ACSEQGEN_LAST_NUM_USED
       --P.BRANCH_CODE, P.PREVIOUS_PRODUCT_CODE, COUNT(*)
         FROM PRODUCT_CODE_CHANGE P
        GROUP BY P.BRANCH_CODE, P.PREVIOUS_PRODUCT_CODE) PROD
ON (AC.ACSEQGEN_ENTITY_NUM = PROD.ACSEQGEN_ENTITY_NUM AND AC.ACSEQGEN_BRN_CODE = PROD.ACSEQGEN_BRN_CODE AND AC.ACSEQGEN_CIF_NUMBER = PROD.ACSEQGEN_CIF_NUMBER AND AC.ACSEQGEN_PROD_CODE = PROD.ACSEQGEN_PROD_CODE AND AC.ACSEQGEN_SEQ_NUMBER = PROD.ACSEQGEN_SEQ_NUMBER)
WHEN MATCHED THEN
  UPDATE
     SET AC.ACSEQGEN_LAST_NUM_USED = AC.ACSEQGEN_LAST_NUM_USED -
                                     PROD.ACSEQGEN_LAST_NUM_USED
WHEN NOT MATCHED THEN
  INSERT
    (AC.ACSEQGEN_ENTITY_NUM,
     AC.ACSEQGEN_BRN_CODE,
     AC.ACSEQGEN_CIF_NUMBER,
     AC.ACSEQGEN_PROD_CODE,
     AC.ACSEQGEN_SEQ_NUMBER,
     AC.ACSEQGEN_LAST_NUM_USED)
  VALUES
    (PROD.ACSEQGEN_ENTITY_NUM,
     PROD.ACSEQGEN_BRN_CODE,
     PROD.ACSEQGEN_CIF_NUMBER,
     PROD.ACSEQGEN_PROD_CODE,
     PROD.ACSEQGEN_SEQ_NUMBER,
     PROD.ACSEQGEN_LAST_NUM_USED)
	 
	 
	 
	 
	 
	 
	 
	 
	 
merge into acseqgen ac
using (SELECT 1 ACSEQGEN_ENTITY_NUM,
              P.BRANCH_CODE ACSEQGEN_BRN_CODE,
              0 ACSEQGEN_CIF_NUMBER,
              P.NEW_PRODUCT_CODE ACSEQGEN_PROD_CODE,
              0 ACSEQGEN_SEQ_NUMBER,
              count(*) ACSEQGEN_LAST_NUM_USED
       --P.BRANCH_CODE, P.PREVIOUS_PRODUCT_CODE, COUNT(*)
         FROM product_code_change P
        GROUP BY P.BRANCH_CODE, P.NEW_PRODUCT_CODE) prod
on (ac.acseqgen_entity_num = prod.acseqgen_entity_num and ac.acseqgen_brn_code = prod.acseqgen_brn_code and ac.acseqgen_cif_number = prod.acseqgen_cif_number and ac.acseqgen_prod_code = prod.acseqgen_prod_code and ac.acseqgen_seq_number = prod.acseqgen_seq_number)
when matched then
  update
     set ac.acseqgen_last_num_used = ac.acseqgen_last_num_used +
                                     prod.acseqgen_last_num_used
when not matched then
  insert
    (ac.acseqgen_entity_num,
     ac.acseqgen_brn_code,
     ac.acseqgen_cif_number,
     ac.acseqgen_prod_code,
     ac.acseqgen_seq_number,
     ac.acseqgen_last_num_used)
  values
    (prod.acseqgen_entity_num,
     prod.acseqgen_brn_code,
     prod.acseqgen_cif_number,
     prod.acseqgen_prod_code,
     prod.acseqgen_seq_number,
     prod.acseqgen_last_num_used)

	 
	 
	 


	 
	 
-----------------------  GL voucher --------------------
truncate table MANUAL_TRAN ;


INSERT INTO MANUAL_TRAN
SELECT ROWNUM, TT.*
  FROM (SELECT P.BRANCH_CODE BRANCH_CODE,
               0 PRODUCT_CODE,
               0 DEBIT_AC_NUMBER,
               0 CREDIT_AC_NUMBER,
               P.NEW_GL_CODE DEBIT_GL_NUMBER,
               P.PREVIOUS_GL_CODE CREDIT_GL_NUMBER,
               ABS(SUM(AB.ACNTBAL_BC_BAL)) DEBIT_AMOUNT,
               ABS(SUM(AB.ACNTBAL_BC_BAL)) CREDIT_AMOUNT,
               NULL BATCH_NUMBER,
               NULL ACNTS_CLOSER_DATE,
               'Product code change' NARATION,
               null CONTRACT_NUMBER,
               NULL INT_CHECK_PREF,
               NULL INT_CHECK_NUM,
               NULL INST_DATE
          FROM PRODUCT_CODE_CHANGE P, ACNTBAL AB
         WHERE P.INTERNAL_ACCOUNT_NUMBER = AB.ACNTBAL_INTERNAL_ACNUM
         GROUP BY P.BRANCH_CODE,
                  P.PREVIOUS_PRODUCT_CODE,
                  P.NEW_GL_CODE,
                  P.PREVIOUS_GL_CODE) TT;
		  

select * from manual_tran ;

		  
		  
update  glmast g set g.gl_cust_ac_allowed = 0  where g.gl_number in (
select substr(gl, 1,3) from (
select p.new_gl_code gl 
          from product_code_change p
        union all
        select p.previous_gl_code gl from product_code_change p) ) ;
        
commit ;





DECLARE
V_BATCH_NUMBER NUMBER;
BEGIN
   FOR IND IN (SELECT SERIAL_NUMBER,BRANCH_CODE, DEBIT_AC_NUMBER, CREDIT_AC_NUMBER, DEBIT_GL_NUMBER, CREDIT_GL_NUMBER, DEBIT_AMOUNT, CREDIT_AMOUNT, BATCH_NUMBER, NARATION
FROM MANUAL_TRAN WHERE BATCH_NUMBER IS NULL
ORDER BY BRANCH_CODE)
   LOOP
        SP_AUTOPOST_TRANSACTION_MANUAL(
                            IND.BRANCH_CODE, -- branch code
                            IND.DEBIT_GL_NUMBER, -- debit gl
                            IND.CREDIT_GL_NUMBER, -- credit gl 
                            IND.DEBIT_AMOUNT, -- debit amount
                            IND.CREDIT_AMOUNT, -- credit amount 
                            IND.DEBIT_AC_NUMBER, -- debit account 
                            0, -- DR contract number
                            0, -- CR contract number
                            IND.CREDIT_AC_NUMBER, -- credit account
                            0, -- advice num debit
                            NULL,-- advice date debit 
                            0, -- advice num credit
                            NULL, -- advice date credit
                            'BDT', -- currency
                            '127.0.0.1', -- terminal id 
                            'INTELECT', -- user
                            IND.NARATION, -- narration
                            V_BATCH_NUMBER -- BATCH NUMBER
                            );
                            
              UPDATE MANUAL_TRAN
        SET BATCH_NUMBER=V_BATCH_NUMBER
        WHERE DEBIT_GL_NUMBER=IND.DEBIT_GL_NUMBER
        AND BRANCH_CODE=IND.BRANCH_CODE
        AND CREDIT_GL_NUMBER=IND.CREDIT_GL_NUMBER
        AND SERIAL_NUMBER=IND.SERIAL_NUMBER;
        
   END LOOP;
END;






update  glmast g set g.gl_cust_ac_allowed = 1  where g.gl_number in (
select substr(gl, 1,3) from (
select p.new_gl_code gl 
          from product_code_change p
        union all
        select p.previous_gl_code gl from product_code_change p) ) ;
        
commit ;
		  
		  

------------------------- LOAN ACCRUAL VOUCHER ---------------------------
		  
		  
		  
SELECT BR_CODE ,ACCOUNT_NUMBER , SUM(AMOUNT) FROM 
(SELECT L.LOANIA_BRN_CODE BR_CODE,
       L.LOANIA_ACNT_NUM ACCOUNT_NUMBER,
       abs(sum(round(L.LOANIA_TOTAL_NEW_INT_AMT, 2))) AMOUNT
  FROM PRODUCT_CODE_CHANGE P, LOANIA L, LOANACNTS LL
 WHERE L.LOANIA_ACNT_NUM = P.INTERNAL_ACCOUNT_NUMBER
   AND LL.LNACNT_INTERNAL_ACNUM = L.LOANIA_ACNT_NUM
   AND LL.LNACNT_ENTITY_NUM = 1
   AND L.LOANIA_ENTITY_NUM = 1
   AND L.LOANIA_BRN_CODE = P.BRANCH_CODE
   AND L.LOANIA_ACCRUAL_DATE > LL.LNACNT_INT_APPLIED_UPTO_DATE
   AND L.LOANIA_NPA_STATUS = 0
 GROUP BY L.LOANIA_BRN_CODE, L.LOANIA_ACNT_NUM
 UNION ALL
 SELECT L.LOANIAMRR_BRN_CODE BR_CODE,
        L.LOANIAMRR_ACNT_NUM ACCOUNT_NUMBER,
        ROUND(ABS(SUM(L.LOANIAMRR_TOTAL_NEW_INT_AMT)), 2) AMOUNT
   FROM PRODUCT_CODE_CHANGE P, LOANIAMRR L, LOANACNTS LL
  WHERE L.LOANIAMRR_ACNT_NUM = P.INTERNAL_ACCOUNT_NUMBER
    AND LL.LNACNT_INTERNAL_ACNUM = L.LOANIAMRR_ACNT_NUM
    AND LL.LNACNT_ENTITY_NUM = 1
    AND L.LOANIAMRR_ENTITY_NUM = 1
    AND L.LOANIAMRR_BRN_CODE = P.BRANCH_CODE
    AND L.LOANIAMRR_ACCRUAL_DATE > LL.LNACNT_INT_APPLIED_UPTO_DATE
    AND L.LOANIAMRR_NPA_AMT = 0
  GROUP BY L.LOANIAMRR_BRN_CODE, L.LOANIAMRR_ACNT_NUM)
  GROUP BY BR_CODE ,ACCOUNT_NUMBER 
  ;



  
  
  
  
  
  
  
  
  
TRUNCATE TABLE  MANUAL_TRAN ;

INSERT INTO MANUAL_TRAN 
SELECT ROWNUM SERIAL_NUMBER, ACCRUAL_VOUCHER.*
  FROM (SELECT PPP.BRANCH_CODE BRANCH_CODE,
               0 PRODUCT_CODE,
               0 DEBIT_AC_NUMBER,
               0 CREDIT_AC_NUMBER,
               PPP.PREVIOUS_INCOME_GL DEBIT_GL_NUMBER,
               PPP.PREVIOUS_ACCRUAL_GL CREDIT_GL_NUMBER,
               SUM(AMOUNT_TOTAL) DEBIT_AMOUNT,
               SUM(AMOUNT_TOTAL) CREDIT_AMOUNT,
               NULL BATCH_NUMBER,
               NULL ACNTS_CLOSER_DATE,
               'PRODUCT CODE CHANGE' NARATION,
               NULL CONTRACT_NUMBER ,
               NULL INT_CHECK_PREF,
               NULL INT_CHECK_NUM,
               NULL INST_DATE
          FROM PRODUCT_CODE_CHANGE PPP,
               (SELECT BR_CODE, ACCOUNT_NUMBER, SUM(AMOUNT) AMOUNT_TOTAL
                  FROM (SELECT L.LOANIA_BRN_CODE BR_CODE,
                               L.LOANIA_ACNT_NUM ACCOUNT_NUMBER,
                               abs(sum(round(L.LOANIA_TOTAL_NEW_INT_AMT, 2))) AMOUNT
                          FROM PRODUCT_CODE_CHANGE P, LOANIA L, LOANACNTS LL
                         WHERE L.LOANIA_ACNT_NUM = P.INTERNAL_ACCOUNT_NUMBER
                           AND LL.LNACNT_INTERNAL_ACNUM = L.LOANIA_ACNT_NUM
                           AND LL.LNACNT_ENTITY_NUM = 1
                           AND L.LOANIA_ENTITY_NUM = 1
                           AND L.LOANIA_BRN_CODE = P.BRANCH_CODE
                           AND L.LOANIA_VALUE_DATE >
                               LL.LNACNT_INT_APPLIED_UPTO_DATE
                           AND L.LOANIA_NPA_STATUS = 0
                         GROUP BY L.LOANIA_BRN_CODE, L.LOANIA_ACNT_NUM
                        UNION ALL
                        SELECT L.LOANIAMRR_BRN_CODE BR_CODE,
                               L.LOANIAMRR_ACNT_NUM ACCOUNT_NUMBER,
                               ROUND(ABS(SUM(L.LOANIAMRR_TOTAL_NEW_INT_AMT)),
                                     2) AMOUNT
                          FROM PRODUCT_CODE_CHANGE P,
                               LOANIAMRR           L,
                               LOANACNTS           LL
                         WHERE L.LOANIAMRR_ACNT_NUM =
                               P.INTERNAL_ACCOUNT_NUMBER
                           AND LL.LNACNT_INTERNAL_ACNUM = L.LOANIAMRR_ACNT_NUM
                           AND LL.LNACNT_ENTITY_NUM = 1
                           AND L.LOANIAMRR_ENTITY_NUM = 1
                           AND L.LOANIAMRR_BRN_CODE = P.BRANCH_CODE
                           AND L.LOANIAMRR_VALUE_DATE >
                               LL.LNACNT_INT_APPLIED_UPTO_DATE
                           AND L.LOANIAMRR_NPA_AMT = 0
                         GROUP BY L.LOANIAMRR_BRN_CODE, L.LOANIAMRR_ACNT_NUM)
                 GROUP BY BR_CODE, ACCOUNT_NUMBER) ACCRU
         WHERE PPP.INTERNAL_ACCOUNT_NUMBER = ACCRU.ACCOUNT_NUMBER
           AND PPP.PREVIOUS_ACCRUAL_GL <> PPP.NEW_ACCRUAL_GL
         GROUP BY PPP.BRANCH_CODE,
                  PPP.PREVIOUS_ACCRUAL_GL,
                  PPP.NEW_ACCRUAL_GL,
                  PPP.PREVIOUS_INCOME_GL,
                  PPP.NEW_INCOME_GL
        UNION ALL
        SELECT PPP.BRANCH_CODE BRANCH_CODE,
               0 PRODUCT_CODE,
               0 DEBIT_AC_NUMBER,
               0 CREDIT_AC_NUMBER,
               PPP.NEW_ACCRUAL_GL DEBIT_GL_NUMBER,
               PPP.NEW_INCOME_GL CREDIT_GL_NUMBER,
               SUM(AMOUNT_TOTAL) DEBIT_AMOUNT,
               SUM(AMOUNT_TOTAL) CREDIT_AMOUNT,
               NULL BATCH_NUMBER,
               NULL ACNTS_CLOSER_DATE,
               'PRODUCT CODE CHANGE' NARATION,
               NULL CONTRACT_NUMBER ,
               NULL INT_CHECK_PREF,
               NULL INT_CHECK_NUM,
               NULL INST_DATE
          FROM PRODUCT_CODE_CHANGE PPP,
               (SELECT BR_CODE, ACCOUNT_NUMBER, SUM(AMOUNT) AMOUNT_TOTAL
                  FROM (SELECT L.LOANIA_BRN_CODE BR_CODE,
                               L.LOANIA_ACNT_NUM ACCOUNT_NUMBER,
                               abs(sum(round(L.LOANIA_TOTAL_NEW_INT_AMT, 2))) AMOUNT
                          FROM PRODUCT_CODE_CHANGE P, LOANIA L, LOANACNTS LL
                         WHERE L.LOANIA_ACNT_NUM = P.INTERNAL_ACCOUNT_NUMBER
                           AND LL.LNACNT_INTERNAL_ACNUM = L.LOANIA_ACNT_NUM
                           AND LL.LNACNT_ENTITY_NUM = 1
                           AND L.LOANIA_ENTITY_NUM = 1
                           AND L.LOANIA_BRN_CODE = P.BRANCH_CODE
                           AND L.LOANIA_VALUE_DATE >
                               LL.LNACNT_INT_APPLIED_UPTO_DATE
                           AND L.LOANIA_NPA_STATUS = 0
                         GROUP BY L.LOANIA_BRN_CODE, L.LOANIA_ACNT_NUM
                        UNION ALL
                        SELECT L.LOANIAMRR_BRN_CODE BR_CODE,
                               L.LOANIAMRR_ACNT_NUM ACCOUNT_NUMBER,
                               ROUND(ABS(SUM(L.LOANIAMRR_TOTAL_NEW_INT_AMT)),
                                     2) AMOUNT
                          FROM PRODUCT_CODE_CHANGE P,
                               LOANIAMRR           L,
                               LOANACNTS           LL
                         WHERE L.LOANIAMRR_ACNT_NUM =
                               P.INTERNAL_ACCOUNT_NUMBER
                           AND LL.LNACNT_INTERNAL_ACNUM = L.LOANIAMRR_ACNT_NUM
                           AND LL.LNACNT_ENTITY_NUM = 1
                           AND L.LOANIAMRR_ENTITY_NUM = 1
                           AND L.LOANIAMRR_BRN_CODE = P.BRANCH_CODE
                           AND L.LOANIAMRR_VALUE_DATE >
                               LL.LNACNT_INT_APPLIED_UPTO_DATE
                           AND L.LOANIAMRR_NPA_AMT = 0
                         GROUP BY L.LOANIAMRR_BRN_CODE, L.LOANIAMRR_ACNT_NUM)
                 GROUP BY BR_CODE, ACCOUNT_NUMBER) ACCRU
         WHERE PPP.INTERNAL_ACCOUNT_NUMBER = ACCRU.ACCOUNT_NUMBER
           AND PPP.PREVIOUS_ACCRUAL_GL <> PPP.NEW_ACCRUAL_GL
         GROUP BY PPP.BRANCH_CODE,
                  PPP.PREVIOUS_ACCRUAL_GL,
                  PPP.NEW_ACCRUAL_GL,
                  PPP.PREVIOUS_INCOME_GL,
                  PPP.NEW_INCOME_GL) ACCRUAL_VOUCHER ;
				  
				  

/*

SELECT LIA.BRANCH_CODE,
       LM.LOANIAMRR_ACNT_NUM,
       ROUND(ABS(SUM(LM.LOANIAMRR_TOTAL_NEW_INT_AMT) + NORM_SUM), 2)
  FROM LOANIAMRR LM,
       (SELECT P.BRANCH_CODE,
               P.INTERNAL_ACCOUNT_NUMBER,
               SUM(L.LOANIA_TOTAL_NEW_INT_AMT) NORM_SUM,
               MAX(L.LOANIA_VALUE_DATE) LATEST_ACC_DATE
          FROM PRODUCT_CODE_CHANGE P, LOANIA L, LOANACNTS LL
         WHERE LL.LNACNT_INTERNAL_ACNUM = P.INTERNAL_ACCOUNT_NUMBER
           AND P.INTERNAL_ACCOUNT_NUMBER = L.LOANIA_ACNT_NUM
           AND L.LOANIA_VALUE_DATE > LL.LNACNT_INT_APPLIED_UPTO_DATE
           AND L.LOANIA_ENTITY_NUM = 1
           AND LL.LNACNT_ENTITY_NUM = 1
           AND L.LOANIA_ACNT_NUM = LL.LNACNT_INTERNAL_ACNUM
           AND L.LOANIA_BRN_CODE = P.BRANCH_CODE
           AND L.LOANIA_NPA_STATUS = 0
         GROUP BY P.BRANCH_CODE, P.INTERNAL_ACCOUNT_NUMBER) LIA
 WHERE LM.LOANIAMRR_ENTITY_NUM = 1
   AND LM.LOANIAMRR_BRN_CODE = LIA.BRANCH_CODE
   AND LM.LOANIAMRR_ACNT_NUM = LIA.INTERNAL_ACCOUNT_NUMBER
   AND LM.LOANIAMRR_VALUE_DATE > LIA.LATEST_ACC_DATE
   AND LM.LOANIAMRR_NPA_STATUS = 0
 GROUP BY LIA.BRANCH_CODE, LM.LOANIAMRR_ACNT_NUM, NORM_SUM







*/

				  
				  
				  
-------------------------------------- CONTINUOUS LOAN TO TERM LOAN --------------------------------------

--------------------------- REPAYMENT SCHEDULE & DISBURSMENT DETAIL REQUIRED -----------------------------





select *
  from product_code_change p
 where p.previous_product_code in
       (select pp.product_code
          from products pp
         where pp.product_for_loans = 1
           and pp.product_for_run_acs = 1)
   and p.new_product_code in
       (select pp.product_code
          from products pp
         where pp.product_for_loans = 1
           and pp.product_for_run_acs = 0) ;
		   
		   
		   
		   
		   
		   
		   
		   
		   
		   
		   
		   
		   
		   
SELECT * FROM MIG_LNACDSDTL FOR UPDATE ;

SELECT * FROM MIG_LNACRSDTL FOR UPDATE ;


select * from mig_lnacdsdtl ;
---- LNACDSDTL , LNACDISB , LNACDSDTLHIST

SELECT * FROM MIG_LNACRSDTL ; 
---- LNACRSDTL, LNACRSHIST , LNACRS , LNACRSHDTL

-- LNACDSDTL
INSERT INTO LNACDSDTL
SELECT I.IACLINK_ENTITY_NUM     LNACDSDTL_ENTITY_NUM,
       I.IACLINK_INTERNAL_ACNUM LNACDSDTL_INTERNAL_ACNUM,
       L.LNACDSDTL_SL_NUM       LNACDSDTL_SL_NUM,
       L.LNACDSDTL_STAGE_DESCN  LNACDSDTL_STAGE_DESCN,
       L.LNACDSDTL_DISB_CURR    LNACDSDTL_DISB_CURR,
       L.LNACDSDTL_DISB_DATE    LNACDSDTL_DISB_DATE,
       L.LNACDSDTL_DISB_AMOUNT  LNACDSDTL_DISB_AMOUNT
  FROM MIG_LNACDSDTL L, IACLINK I
 WHERE I.IACLINK_ACTUAL_ACNUM = L.LNACDSDTL_INTERNAL_ACNUM 
 AND I.IACLINK_ENTITY_NUM = 1;
 
-- LNACDISB
INSERT INTO LNACDISB
SELECT I.IACLINK_ENTITY_NUM LNACDISB_ENTITY_NUM,
       I.IACLINK_INTERNAL_ACNUM LNACDISB_INTERNAL_ACNUM,
       L.LNACDSDTL_SL_NUM LNACDISB_DISB_SL_NUM,
       L.LNACDSDTL_DISB_DATE LNACDISB_DISB_ON,
       L.LNACDSDTL_SL_NUM LNACDISB_STAGE_SERIAL,
       L.LNACDSDTL_DISB_CURR LNACDISB_DISB_AMT_CURR,
       L.LNACDSDTL_DISB_AMOUNT LNACDISB_DISB_AMT,
       0 LNACDISB_TRANSTL_INV_NUM,
       'PRODUCT_CODE_CHANGE' LNACDISB_REMARKS1,
       NULL LNACDISB_REMARKS2,
       NULL LNACDISB_REMARKS3,
       '2' POST_TRAN_BRN,
       L.LNACDSDTL_DISB_DATE POST_TRAN_DATE,
       NULL POST_TRAN_BATCH_NUM,
       'MIG_R' LNACDISB_ENTD_BY,
       L.LNACDSDTL_DISB_DATE LNACDISB_ENTD_ON,
       NULL LNACDISB_LAST_MOD_BY,
       NULL LNACDISB_LAST_MOD_ON,
       'MIG_R' LNACDISB_AUTH_BY,
       L.LNACDSDTL_DISB_DATE LNACDISB_AUTH_ON,
       NULL LNACDISB_REJ_BY,
       NULL LNACDISB_REJ_ON,
       0 AMORT_DAY_SL,
       0.000 LNACDISB_CASH_MARGIN_AMT,
       0.000 LNACDISB_BORR_MARG_AMT,
       NULL LNACDISB_BORR_ACC_NO,
	   0,
	   0
  FROM MIG_LNACDSDTL L, IACLINK I
 WHERE I.IACLINK_ACTUAL_ACNUM = L.LNACDSDTL_INTERNAL_ACNUM 
 AND I.IACLINK_ENTITY_NUM = 1;
 
 -------------
 
--- LNACDSDTLHIST
INSERT INTO LNACDSDTLHIST
SELECT I.IACLINK_ENTITY_NUM LNACDSDTLH_ENTITY_NUM,
       I.IACLINK_INTERNAL_ACNUM LNACDSDTLH_INTERNAL_ACNUM,
       A.ACNTS_OPENING_DATE LNACDSDTLH_EFF_DATE,
       L.LNACDSDTL_SL_NUM LNACDSDTLH_SL_NUM,
       'PRODUCT_CODE_CHANGE' LNACDSDTLH_STAGE_DESCN,
       L.LNACDSDTL_DISB_CURR LNACDSDTLH_DISB_CURR,
       L.LNACDSDTL_DISB_DATE LNACDSDTLH_DISB_DATE,
       L.LNACDSDTL_DISB_AMOUNT LNACDSDTLH_DISB_AMOUNT
  FROM MIG_LNACDSDTL L, IACLINK I, ACNTS A
 WHERE I.IACLINK_ACTUAL_ACNUM = L.LNACDSDTL_INTERNAL_ACNUM
   AND A.ACNTS_INTERNAL_ACNUM = I.IACLINK_INTERNAL_ACNUM
   AND A.ACNTS_ENTITY_NUM = 1
   AND I.IACLINK_ENTITY_NUM = 1;
   
   
   
BEGIN
  FOR IDX IN (
              
              SELECT I.IACLINK_ENTITY_NUM     LNACDSDTL_ENTITY_NUM,
                      I.IACLINK_INTERNAL_ACNUM LNACDSDTL_INTERNAL_ACNUM,
                      L.LNACDSDTL_DISB_AMOUNT  LNACDSDTL_DISB_AMOUNT
                FROM MIG_LNACDSDTL L, IACLINK I
               WHERE I.IACLINK_ACTUAL_ACNUM = L.LNACDSDTL_INTERNAL_ACNUM
                 AND I.IACLINK_ENTITY_NUM = 1) LOOP
    UPDATE LLACNTOS LL
       SET LL.LLACNTOS_LIMIT_CURR_DISB_MADE = IDX.LNACDSDTL_DISB_AMOUNT
     WHERE LL.LLACNTOS_CLIENT_ACNUM = IDX.LNACDSDTL_INTERNAL_ACNUM
       AND LL.LLACNTOS_ENTITY_NUM = IDX.LNACDSDTL_ENTITY_NUM;
  END LOOP;
END;

   
---- NEED TO BE VERIFIED
--- LNACRSDTL
INSERT INTO LNACRSDTL
  SELECT I.IACLINK_ENTITY_NUM LNACRSDTL_ENTITY_NUM,
         I.IACLINK_INTERNAL_ACNUM LNACRSDTL_INTERNAL_ACNUM,
         '1' LNACRSDTL_SL_NUM,
         L.LNACRSDTL_REPAY_AMT_CURR LNACRSDTL_REPAY_AMT_CURR,
         L.LNACRSDTL_REPAY_AMT LNACRSDTL_REPAY_AMT,
         L.LNACRSDTL_REPAY_FREQ LNACRSDTL_REPAY_FREQ,
         L.LNACRSDTL_REPAY_FROM_DATE LNACRSDTL_REPAY_FROM_DATE,
         L.LNACRSDTL_NUM_OF_INSTALLMENT LNACRSDTL_NUM_OF_INSTALLMENT,
         L.LNACRS_REPH_ON_AMT LNACRSDTL_TOT_REPAY_AMT
    FROM MIG_LNACRSDTL L, IACLINK I
   WHERE L.LNACRSDTL_ACNUM = I.IACLINK_ACTUAL_ACNUM
     AND I.IACLINK_ENTITY_NUM = 1;




--- LNACRSHIST
INSERT INTO LNACRSHIST
  SELECT I.IACLINK_ENTITY_NUM LNACRSH_ENTITY_NUM,
         I.IACLINK_INTERNAL_ACNUM LNACRSH_INTERNAL_ACNUM,
         L.LNACRS_EFF_DATE LNACRSH_EFF_DATE,
         L.LNACRS_EQU_INSTALLMENT LNACRSH_EQU_INSTALLMENT,
         L.LNACRS_REPH_ON_AMT LNACRSH_REPH_ON_AMT,
         NULL LNACRSH_REPHASEMENT_ENTRY,
         NULL LNACRSH_AUTO_REPHASED_FLG,
         L.LNACRS_SANC_BY LNACRSH_SANC_BY,
         L.LNACRS_SANC_REF_NUM LNACRSH_SANC_REF_NUM,
         L.LNACRS_SANC_DATE LNACRSH_SANC_DATE,
         L.LNACRS_CLIENT_REF_NUM LNACRSH_CLIENT_REF_NUM,
         L.LNACRS_CLIENT_REF_DATE LNACRSH_CLIENT_REF_DATE,
         'PRODUCT_CODE_CHANGE' LNACRSH_REMARKS1,
         NULL LNACRSH_REMARKS2,
         NULL LNACRSH_REMARKS3,
         'MIG_R' LNACRSH_ENTD_BY,
         SYSDATE LNACRSH_ENTD_ON,
         NULL LNACRSH_LAST_MOD_BY,
         NULL LNACRSH_LAST_MOD_ON,
         'MIG_R' LNACRSH_AUTH_BY,
         SYSDATE LNACRSH_AUTH_ON,
         NULL TBA_MAIN_KEY,
         NULL LNACRSH_REDISB_DATE,
         NULL LNACIRSH_INTR_CAPTL,
         NULL LNACRSH_PURPOSE,
         NULL LNACRSH_RS_NO,
		 0,
		 0,
		 0
    FROM MIG_LNACRSDTL L, IACLINK I
   WHERE L.LNACRSDTL_ACNUM = I.IACLINK_ACTUAL_ACNUM
     AND I.IACLINK_ENTITY_NUM = 1;

--- NEED TO BE VERIFIED
---LNACRS 
INSERT INTO LNACRS
SELECT I.IACLINK_ENTITY_NUM LNACRS_ENTITY_NUM,
       I.IACLINK_INTERNAL_ACNUM LNACRS_INTERNAL_ACNUM,
       L.LNACRS_EFF_DATE LNACRS_LATEST_EFF_DATE,
       L.LNACRS_EQU_INSTALLMENT LNACRS_EQU_INSTALLMENT,
       L.LNACRS_REPH_ON_AMT LNACRS_REPH_ON_AMT,
       NULL LNACRS_REPHASEMENT_ENTRY,
       NULL LNACRS_AUTO_REPHASED_FLG,
       L.LNACRS_SANC_BY LNACRS_SANC_BY,
       L.LNACRS_SANC_REF_NUM LNACRS_SANC_REF_NUM,
       L.LNACRS_SANC_DATE LNACRS_SANC_DATE,
       L.LNACRS_CLIENT_REF_NUM LNACRS_CLIENT_REF_NUM,
       L.LNACRS_CLIENT_REF_DATE LNACRS_CLIENT_REF_DATE,
       'PRODUCT_CODE_CHANGE' LNACRS_REMARKS1,
       NULL LNACRS_REMARKS2,
       NULL LNACRS_REMARKS3,
       NULL LNACRS_REDISB_DATE,
       NULL LNACRS_INTR_CAPTL,
       NULL LNACRS_PURPOSE,
       NULL LNACRS_RS_NO,
	   0,
	   0,
	   0
  FROM MIG_LNACRSDTL L, IACLINK I
 WHERE L.LNACRSDTL_ACNUM = I.IACLINK_ACTUAL_ACNUM
   AND I.IACLINK_ENTITY_NUM = 1;





--- LNACRSHDTL
INSERT INTO LNACRSHDTL
  SELECT I.IACLINK_ENTITY_NUM LNACRSHDTL_ENTITY_NUM,
         I.IACLINK_INTERNAL_ACNUM LNACRSHDTL_INTERNAL_ACNUM,
         L.LNACRS_EFF_DATE LNACRSHDTL_EFF_DATE,
         1 LNACRSHDTL_SL_NUM,
         L.LNACRSDTL_REPAY_AMT_CURR LNACRSHDTL_REPAY_AMT_CURR,
         L.LNACRSDTL_REPAY_AMT LNACRSHDTL_REPAY_AMT,
         L.LNACRSDTL_REPAY_FREQ LNACRSHDTL_REPAY_FREQ,
         L.LNACRSDTL_REPAY_FROM_DATE LNACRSHDTL_REPAY_FROM_DATE,
         L.LNACRSDTL_NUM_OF_INSTALLMENT LNACRSHDTL_NUM_OF_INSTALLMENT,
         L.LNACRS_REPH_ON_AMT LNACRSHDTL_TOT_REPAY_AMT 
    FROM MIG_LNACRSDTL L, IACLINK I
   WHERE L.LNACRSDTL_ACNUM = I.IACLINK_ACTUAL_ACNUM
     AND I.IACLINK_ENTITY_NUM = 1;


insert into product_code_change_hist
  select P.BRANCH_CODE,
         p.acctual_account_number,
         p.internal_account_number,
         p.previous_account_type,
         p.new_account_type,
         p.previous_account_sub_type,
         p.new_account_sub_type,
         p.previous_product_code,
         p.new_product_code,
         p.previous_gl_code,
         p.new_gl_code,
         p.previous_accrual_gl,
         p.new_accrual_gl,
         p.previous_income_gl,
         p.new_income_gl,
         SYSDATE,
         p.accrual_amount
    from product_code_change P;
 
   
   
SELECT * FROM MIG_LNTOTINTDBMIG FOR UPDATE ;

INSERT INTO LNTOTINTDBMIG
  SELECT I.IACLINK_ENTITY_NUM        LNTOTINTDB_ENTITY_NUM,
         I.IACLINK_INTERNAL_ACNUM    LNTOTINTDB_INTERNAL_ACNUM,
         L.LNTOTINTDB_TOT_INT_DB_AMT LNTOTINTDB_TOT_INT_DB_AMT,
         0                           LNTOTINTDB_TOT_PRIN_DB_AMT
    FROM MIG_LNTOTINTDBMIG L, IACLINK I
   WHERE I.IACLINK_ACTUAL_ACNUM = L.LNTOTINTDB_INTERNAL_ACNUM
     AND I.IACLINK_ENTITY_NUM = 1 ;
     
     
SELECT * FROM LOANACNTS L WHERE L.LNACNT_INTERNAL_ACNUM = 11608900003014 FOR UPDATE ; -- LNACNT_DISB_TYPE	S


SELECT * FROM LNACMIS L WHERE L.LNACMIS_INTERNAL_ACNUM = 11608900003014 FOR UPDATE ;
SELECT * FROM LNACMISHIST L WHERE L.LNACMISH_INTERNAL_ACNUM = 11608900003014 FOR UPDATE ;
