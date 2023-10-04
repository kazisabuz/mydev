--insert into mig_ddpo from excel

UPDATE MIG_ACOP_BAL  SET ACOP_BRANCH_CODE=51128;

exec sp_macro_ddpo;

EDIT errorlog;


------------INSERT DATA ON DD_FINDING FROM PRODUCTION-----------------------------------------

  SELECT D.DDPOPAYDB_ISSUED_BRN,
             D.DDPOPAYDB_INST_DATE,
             D.DDPOPAYDB_INST_PFX,
             D.DDPOPAYDB_LEAF_NUM,
             D.DDPOPAYDB_INST_AMT
        FROM DDPOPAYDB  D
       WHERE     TO_NUMBER (D.DDPOPAYDB_ISSUED_ON_BRN) = 51128 
             AND D.DDPOPAYDB_ADVICE_REC_DATE IS NULL;  

 
declare
v_errorlog varchar2(100);
begin 
sp_mig_ddpo(51128  , v_errorlog);
end;


EDIT  mig_errorlog;


UPDATE DDPOISS
         SET DDPOISS_STATUS = 'A'
       WHERE DDPOISS.DDPOISS_REMIT_CODE = 1;
       

UPDATE DDPOISSDTLANX
         SET DDPOANX_DUPISS_DAY_SL = '0'
       WHERE DDPOANX_DUPISS_DAY_SL IS NULL;

UPDATE DDPOPAYDB
         SET DDPOPAYDB_ISSUED_ON_BNK = DDPOPAYDB_ISSUED_BANK,
             DDPOPAYDB_ISSUED_ON_BRN = DDPOPAYDB_ISSUED_BRN
       WHERE DDPOPAYDB_REMIT_CODE = 1;                         --FOR PAY ORDER

      --COMMIT;


UPDATE DDPOPAYDB
         SET DDPOPAYDB_ISSUED_ON_BRN = TO_NUMBER (DDPOPAYDB_ISSUED_ON_BRN);
         
------------transfer table INTO PRODUCTION ------
--DDADVPART    ---DD
--DDADVPARTDTL --DD
--DDPOISS
--DDPOISSDTL
--DDPOISSDTLANX
--DDPOPAYDB

---------------------------------------------
    