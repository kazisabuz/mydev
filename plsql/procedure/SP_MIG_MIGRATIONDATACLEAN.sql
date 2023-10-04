DROP PROCEDURE SBL_MIG.SP_MIG_MIGRATIONDATACLEAN;

CREATE OR REPLACE PROCEDURE SBL_MIG.SP_MIG_MIGRATIONDATACLEAN (

   O_ERR OUT VARCHAR2)

IS

   /*

     AUTHOR:S.Karthik

     Date:27-DEC-2009

     Purpose:To Delete all the Migration Tables



     Note:Signature migration Table is commented



   */



   W_SQL   VARCHAR2 (1000);



   PROCEDURE EXECUTE_QUERY

   IS

   BEGIN

      EXECUTE IMMEDIATE W_SQL;

   EXCEPTION

      WHEN OTHERS

      THEN

         DBMS_OUTPUT.PUT_LINE (W_SQL);

         O_ERR := SQLERRM;

         DBMS_OUTPUT.PUT_LINE (O_ERR);

   END EXECUTE_QUERY;



BEGIN

   W_SQL := 'TRUNCATE TABLE GLCAT';



   EXECUTE_QUERY;



   INSERT INTO GLCAT

      SELECT * FROM GLCAT@MIG_MASTER_DATA;



   W_SQL := 'TRUNCATE TABLE GLMAST';



   EXECUTE_QUERY;



   INSERT INTO GLMAST

      SELECT * FROM GLMAST@MIG_MASTER_DATA;



   W_SQL := 'TRUNCATE TABLE SUBGL';



   EXECUTE_QUERY;



   INSERT INTO SUBGL

      SELECT * FROM SUBGL@MIG_MASTER_DATA;



   W_SQL := 'TRUNCATE TABLE BRKGL';



   EXECUTE_QUERY;



   INSERT INTO BRKGL

      SELECT * FROM BRKGL@MIG_MASTER_DATA;



   W_SQL := 'TRUNCATE TABLE EXTGL';



   EXECUTE_QUERY;



   INSERT INTO EXTGL

      SELECT * FROM EXTGL@MIG_MASTER_DATA;



   W_SQL := 'TRUNCATE TABLE PRODUCTS';



   EXECUTE_QUERY;



   INSERT INTO PRODUCTS

      SELECT * FROM PRODUCTS@MIG_MASTER_DATA;



   W_SQL := 'TRUNCATE TABLE LNPRODACPM';



   EXECUTE_QUERY;
   



   INSERT INTO LNPRODACPM

      SELECT * FROM LNPRODACPM@MIG_MASTER_DATA;





   W_SQL := 'TRUNCATE TABLE LNPRODPM';



   EXECUTE_QUERY;



   INSERT INTO LNPRODPM

      SELECT * FROM LNPRODPM@MIG_MASTER_DATA;



   W_SQL := 'TRUNCATE TABLE RAPARAM';



   EXECUTE_QUERY;



   INSERT INTO RAPARAM

      SELECT * FROM RAPARAM@MIG_MASTER_DATA;



   W_SQL := 'TRUNCATE TABLE ACTYPES';



   EXECUTE_QUERY;



   INSERT INTO ACTYPES

      SELECT * FROM ACTYPES@MIG_MASTER_DATA;



   W_SQL := 'TRUNCATE TABLE ACSUBTYPES';



   EXECUTE_QUERY;



   INSERT INTO ACSUBTYPES

      SELECT * FROM ACSUBTYPES@MIG_MASTER_DATA;



   W_SQL := 'TRUNCATE TABLE DEPPRODCUR';



   EXECUTE_QUERY;



   INSERT INTO DEPPRODCUR

      SELECT * FROM DEPPRODCUR@MIG_MASTER_DATA;



   W_SQL := 'TRUNCATE TABLE ACSEQ';



   EXECUTE_QUERY;



   INSERT INTO ACSEQ

      SELECT * FROM ACSEQ@MIG_MASTER_DATA;



   W_SQL := 'TRUNCATE TABLE ACSEQDTL';



   EXECUTE_QUERY;



   W_SQL := 'TRUNCATE TABLE ACSEQDTL';



   EXECUTE_QUERY;



   INSERT INTO ACSEQDTL

      SELECT * FROM ACSEQDTL@MIG_MASTER_DATA;



   ---ERRORLOG

   W_SQL := 'truncate table ERRORLOG ';

   EXECUTE_QUERY;



   W_SQL := 'truncate table MIG_ERRORLOG ';

   EXECUTE_QUERY;



   --- Habijabi



   W_SQL := 'truncate table MIG_LNACRSDTL_TEMP	';

   EXECUTE_QUERY;



   W_SQL := 'truncate table MIG_BLLOANIA	';

   EXECUTE_QUERY;



   W_SQL := 'truncate table MIG_WRITEOFF	';

   EXECUTE_QUERY;



   W_SQL := 'truncate table MIG_WRITEOFF_RECOV	';

   EXECUTE_QUERY;



   W_SQL := 'truncate table LNWRTOFF ';

   EXECUTE_QUERY;



   W_SQL := 'truncate table LNWRTOFFRECOV ';

   EXECUTE_QUERY;



   W_SQL := 'truncate table MOTHER ';

   EXECUTE_QUERY;

   W_SQL := 'truncate table mig_reschedule ';

   EXECUTE_QUERY;



   W_SQL := 'truncate table mig_sec_regis_temp ';

   EXECUTE_QUERY;



   --Clients

   W_SQL := 'truncate table MIG_CLIENTCONTACTS	';

   EXECUTE_QUERY;

   W_SQL := 'truncate table MIG_CLIENTS	';

   EXECUTE_QUERY;

   W_SQL := 'truncate table MIG_CLIENTSBKDTL 	';

   EXECUTE_QUERY;

   W_SQL := 'truncate table MIG_PIDDOCS	';

   EXECUTE_QUERY;

   W_SQL := 'truncate table MIG_JOINTCLIENTS	';

   EXECUTE_QUERY;



   --Accounts

   W_SQL := 'truncate table MIG_ACNTS	';

   EXECUTE_QUERY;

   W_SQL := 'truncate table MIG_ACNTLIEN 	';

   EXECUTE_QUERY;

   W_SQL := 'truncate table MIG_CONNPINFO	';

   EXECUTE_QUERY;



   --Deposits

   W_SQL := 'truncate table MIG_pbdcontract	';

   EXECUTE_QUERY;

   W_SQL := 'truncate table MIG_TDSPIDTL	';

   EXECUTE_QUERY;

   W_SQL := 'truncate table MIG_RDINS	';

   EXECUTE_QUERY;

   W_SQL := 'truncate table MIG_TDSREMITGOV	';

   EXECUTE_QUERY;

   W_SQL := 'truncate table MIG_DEPIA 	';

   EXECUTE_QUERY;



   --Loans

   W_SQL := 'truncate table MIG_LNACNT 	';

   EXECUTE_QUERY;

   W_SQL := 'truncate table MIG_LNACGUAR	';

   EXECUTE_QUERY;

   W_SQL := 'truncate table MIG_LNACIRS	';

   EXECUTE_QUERY;

   W_SQL := 'truncate table MIG_LNACDSDTL	';

   EXECUTE_QUERY;

   W_SQL := 'truncate table MIG_LNDP	';

   EXECUTE_QUERY;

   W_SQL := 'truncate table MIG_LNSUBRCV	';

   EXECUTE_QUERY;

   W_SQL := 'truncate table MIG_LNSUBSIDY	';

   EXECUTE_QUERY;

   W_SQL := 'truncate table MIG_LNSUSP	';

   EXECUTE_QUERY;

   W_SQL := 'truncate table MIG_ASSETCLS	';

   EXECUTE_QUERY;

   W_SQL := 'truncate table MIG_LNACRSDTL 	';

   EXECUTE_QUERY;
   
    W_SQL := 'truncate table MV_LOAN_ACCOUNT_BAL';
     EXECUTE_QUERY;
   
W_SQL := 'truncate table MV_LOAN_ACCOUNT_BAL_OD';
   EXECUTE_QUERY;



   --DDPO

   W_SQL := 'truncate table MIG_DDPO	';

   EXECUTE_QUERY;



   --Cheque Book

   W_SQL := 'truncate table MIG_CHEQUE	';

   EXECUTE_QUERY;

   W_SQL := 'truncate table MIG_STOPCHQ	';

   EXECUTE_QUERY;



   --Security

   W_SQL := 'truncate table MIG_SECMORT	';

   EXECUTE_QUERY;

   W_SQL := 'truncate table MIG_SECINVEST	';

   EXECUTE_QUERY;

   W_SQL := 'truncate table MIG_SECVPM	';

   EXECUTE_QUERY;

   W_SQL := 'truncate table MIG_SECSHA	';

   EXECUTE_QUERY;

   W_SQL := 'truncate table MIG_SECSHACER  	';

   EXECUTE_QUERY;

   W_SQL := 'truncate table MIG_SECSTOCK	';

   EXECUTE_QUERY;

   W_SQL := 'truncate table MIG_LAD	';

   EXECUTE_QUERY;

   W_SQL := 'truncate table MIG_LADDTL	';

   EXECUTE_QUERY;

   W_SQL := 'truncate table MIG_SECINSUR	';

   EXECUTE_QUERY;

   --Locker

   W_SQL := 'truncate table MIG_LOCKER	';

   EXECUTE_QUERY;

   W_SQL := 'truncate table MIG_LOCKERCHG	';

   EXECUTE_QUERY;

   W_SQL := 'truncate table MIG_LOCKERACC	';

   EXECUTE_QUERY;

   W_SQL := 'truncate table MIG_LOCKERKEY	';

   EXECUTE_QUERY;

   W_SQL := 'truncate table MIG_LOCKERDTLS	';

   EXECUTE_QUERY;

   W_SQL := 'truncate table MIG_HOVERRECBRK	';

   EXECUTE_QUERY;



   W_SQL := 'truncate table MIG_LOCKERRENT	';

   EXECUTE_QUERY;



   --Signature

   --w_sql:=     'truncate table MIG_SIGNATURE ';execute_query;

   --Opening Balance and Transaction

   W_SQL := 'truncate table MIG_GLOP_BAL	';

   EXECUTE_QUERY;

   W_SQL := 'truncate table MIG_ACOP_BAL	';

   EXECUTE_QUERY;

   W_SQL := 'truncate table MIG_TRAN	';

   EXECUTE_QUERY;

   W_SQL := 'truncate table mig_hoverrecbrk';

   EXECUTE_QUERY;



   W_SQL := 'truncate table mig_legalstat';

   EXECUTE_QUERY;



   W_SQL := 'truncate table MIG_LNNOMMEM';

   EXECUTE_QUERY;

   W_SQL := 'truncate table mig_memnum';

   EXECUTE_QUERY;



   W_SQL := 'truncate table mig_acseqgen';

   EXECUTE_QUERY;



   W_SQL := 'truncate table mig_acseqgen';

   EXECUTE_QUERY;



   W_SQL := 'truncate table MIG_LNACCHGS';

   EXECUTE_QUERY;



   W_SQL := 'truncate table MIG_LNTOTINTDBMIG';

   EXECUTE_QUERY;



   W_SQL := 'truncate table mig_signature';

   EXECUTE_QUERY;



   W_SQL := 'truncate table IVRACNTS';

   EXECUTE_QUERY;



   W_SQL := 'truncate table MIG_ABB_CHECK';

   EXECUTE_QUERY;



   W_SQL := 'truncate table LNMISMAPPM';
   EXECUTE_QUERY;


   W_SQL := 'truncate table MIG_ACNTRNPR';
   EXECUTE_QUERY;

 W_SQL := 'truncate table ACNTRNPR';
   EXECUTE_QUERY;
   
    W_SQL := 'truncate table ACNTRNPRHIST';
   EXECUTE_QUERY;




INSERT INTO LNMISMAPPM
WITH temp AS (SELECT * FROM LNMISMAPPM@MIG_MASTER_DATA)
  SELECT DISTINCT LNMISMAPPM_ENTITY_NUM,
                  t.LNMISMAPPM_PRODUCT_CODE,
                  LNMISMAPPM_CLIENT_TYPE,
                  TRIM (REGEXP_SUBSTR (t.LNMISMAPPM_CL_CODE,
                                       '[^|]+',
                                       1,
                                       levels.COLUMN_VALUE))
                     AS LNMISMAPPM_CL_CODE,
                  TRIM (REGEXP_SUBSTR (t.LNMISMAPPM_SME_NONSME_CODE,
                                       '[^|]+',
                                       1,
                                       levels.COLUMN_VALUE))
                     AS LNMISMAPPM_SME_NONSME_CODE,
                  TRIM (REGEXP_SUBSTR (t.LNMISMAPPM_SECURITY_CODE,
                                       '[^|]+',
                                       1,
                                       levels.COLUMN_VALUE))
                     AS LNMISMAPPM_SECURITY_CODE,
                  LNMISMAPPM_ENTD_BY,
                  LNMISMAPPM_ENTD_ON,
                  LNMISMAPPM_LAST_MOD_BY,
                  LNMISMAPPM_LAST_MOD_ON,
                  LNMISMAPPM_AUTH_BY,
                  LNMISMAPPM_AUTH_ON,
                  TBA_MAIN_KEY
    FROM temp t,
         TABLE (
            CAST (
               MULTISET (
                      SELECT LEVEL
                        FROM DUAL
                  CONNECT BY LEVEL <=
                                  LENGTH (
                                     REGEXP_REPLACE (
                                        t.LNMISMAPPM_SME_NONSME_CODE,
                                        '[^|]+'))
                                + 1) AS SYS.OdciNumberList)) levels
ORDER BY LNMISMAPPM_PRODUCT_CODE;
COMMIT;
  /*

  

  List of Tables and the Export Command from Bank/Bank@Usp06

  

  Clients

  

     1. MIG_CLIENTCONTACTS

     2. MIG_CLIENTS

     3. MIG_CLIENTSBKDTL

     4. MIG_PIDDOCS

     5. MIG_JOINTCLIENTS

  

  Accounts

      1. MIG_ACNTS

      2. MIG_ACNTLIEN

      3. MIG_CONNPINFO

  

  Deposits

       1. MIG_DEPOSITS

       2. MIG_TDSPIDTL

       3. MIG_RDINS

       4. MIG_TDSREMITGOV

       5. MIG_DEPIA

  

  Advances

    1. MIG_LNACNT

    2. MIG_LNACGUAR

    3. MIG_LNACIRS

    4. MIG_LNACDSDTL

    5. MIG_LNDP

    6. MIG_LNSUBRCV

    7. MIG_LNSUBSIDY

    8. MIG_LNSUSP

    9. MIG_ASSETCLS

    10. MIG_LNACRSDTL

  

  DDPO

    1.MIG_DDPO

  

  Cheque Book

  

    1.MIG_CHEQUE

    2.MIG_STOPCHQ

  

  Security

     1.MIG_SECMORT

     2.MIG_SECINVEST

     3.MIG_SECVPM

     4.MIG_SECSHA

     5.MIG_SECSHACER

     6.MIG_SECSTOCK

     7.MIG_LAD

     8.MIG_LADDTL

     9.MIG_SECINSUR

  

  Locker

  

    1.MIG_LOCKER

    2.MIG_LOCKERCHG

    3.MIG_LOCKERACC

    4.MIG_LOCKERKEY

    5.MIG_LOCKERDTLS

  

  Hovering

   1.MIG_HOVERRECBRK

  

  Singnature

    1.MIG_SIGNATURE

  

  Opening Balance

    1.MIG_GLOP_BAL

    2.MIG_ACOP_BAL

  

  Transaction

    1.MIG_TRAN

  

  MIG_CLIENTCONTACTS,MIG_CLIENTS,MIG_CLIENTSBKDTL,MIG_PIDDOCS,MIG_JOINTCLIENTS,MIG_ACNTS,MIG_ACNTLIEN,

  MIG_CONNPINFO,MIG_PBDCONTRACT,MIG_TDSPIDTL,MIG_RDINS,MIG_TDSREMITGOV,MIG_DEPIA,MIG_LNACNT,MIG_LNACGUAR,

  MIG_LNACIRS,MIG_LNACDSDTL,MIG_LNDP,MIG_LNSUBRCV,MIG_LNSUBSIDY,MIG_LNSUSP,MIG_ASSETCLS,MIG_LNACRSDTL,

  MIG_DDPO,MIG_CHEQUE,MIG_STOPCHQ,MIG_SECMORT,MIG_SECINVEST,

  MIG_SECVPM,MIG_SECSHA,MIG_SECSHACER,MIG_SECSTOCK,MIG_LAD,MIG_LADDTL,MIG_SECINSUR,

  MIG_LOCKER,MIG_LOCKERCHG,MIG_LOCKERACC,MIG_LOCKERKEY,MIG_LOCKERDTLS,

  MIG_HOVERRECBRK,MIG_SIGNATURE,MIG_GLOP_BAL,MIG_ACOP_BAL,MIG_TRAN

  

  MIG_SIGNATURE -- To be done separately

  

  MIG_CLIENTCONTACTS,MIG_CLIENTS,MIG_CLIENTSBKDTL,MIG_PIDDOCS,MIG_JOINTCLIENTS,MIG_ACNTS,MIG_ACNTLIEN,MIG_CONNPINFO,MIG_PBDCONTRACT,MIG_TDSPIDTL,MIG_RDINS,MIG_TDSREMITGOV,MIG_DEPIA,MIG_LNACNT,MIG_LNACGUAR,MIG_LNACIRS,MIG_LNACDSDTL,MIG_LNDP,MIG_LNSUBRCV,MIG_LNSUBSIDY,MIG_LNSUSP,MIG_ASSETCLS,MIG_LNACRSDTL MIG_DDPO,MIG_CHEQUE,MIG_STOPCHQ,MIG_SECMORT,MIG_SECINVEST,MIG_SECVPM,MIG_SECSHA,MIG_SECSHACER,MIG_SECSTOCK,MIG_LAD,MIG_LADDTL,MIG_SECINSUR,MIG_LOCKER,MIG_LOCKERCHG,MIG_LOCKERACC,MIG_LOCKERKEY,MIG_LOCKERDTLS,MIG_HOVERRECBRK,MIG_GLOP_BAL,MIG_ACOP_BAL,MIG_TRAN

  

  

  Export Command

  exp bank/bank@usp06 file=c:\x1.dmp log=c:\x1.log tables=MIG_CLIENTCONTACTS,MIG_CLIENTS,MIG_CLIENTSBKDTL,MIG_PIDDOCS,MIG_JOINTCLIENTS,MIG_ACNTS,MIG_ACNTLIEN,MIG_CONNPINFO,MIG_PBDCONTRACT,MIG_TDSPIDTL,MIG_RDINS,MIG_TDSREMITGOV,MIG_DEPIA,MIG_LNACNT,MIG_LNACGUAR,MIG_LNACIRS,MIG_LNACDSDTL,MIG_LNDP,MIG_LNSUBRCV,MIG_LNSUBSIDY,MIG_LNSUSP,MIG_ASSETCLS,MIG_LNACRSDTL MIG_DDPO,MIG_CHEQUE,MIG_STOPCHQ,MIG_SECMORT,MIG_SECINVEST,MIG_SECVPM,MIG_SECSHA,MIG_SECSHACER,MIG_SECSTOCK,MIG_LAD,MIG_LADDTL,MIG_SECINSUR,MIG_LOCKER,MIG_LOCKERCHG,MIG_LOCKERACC,MIG_LOCKERKEY,MIG_LOCKERDTLS,MIG_HOVERRECBRK,MIG_GLOP_BAL,MIG_ACOP_BAL,MIG_TRAN statistics=none

  

  

  

      truncate table MIG_CLIENTCONTACTS

      truncate table MIG_CLIENTS

      truncate table MIG_CLIENTSBKDTL

      truncate table MIG_PIDDOCS

      truncate table MIG_JOINTCLIENTS

  

  

      truncate table MIG_ACNTS

      truncate table MIG_ACNTLIEN

      truncate table MIG_CONNPINFO

  

  

      truncate table MIG_DEPOSITS

      truncate table MIG_TDSPIDTL

      truncate table MIG_RDINS

      truncate table MIG_TDSREMITGOV

      truncate table MIG_DEPIA

  

  

      truncate table MIG_LNACNT

      truncate table MIG_LNACGUAR

      truncate table MIG_LNACIRS

      truncate table MIG_LNACDSDTL

      truncate table MIG_LNDP

      truncate table MIG_LNSUBRCV

      truncate table MIG_LNSUBSIDY

      truncate table MIG_LNSUSP

      truncate table MIG_ASSETCLS

      truncate table MIG_LNACRSDTL

  

      truncate table MIG_DDPO

  

      truncate table MIG_CHEQUE

      truncate table MIG_STOPCHQ

  

      truncate table MIG_SECMORT

      truncate table MIG_SECINVEST

      truncate table MIG_SECVPM

      truncate table MIG_SECSHA

      truncate table MIG_SECSHACER

      truncate table MIG_SECSTOCK

      truncate table MIG_LAD

      truncate table MIG_LADDTL

      truncate table MIG_SECINSUR

  

      truncate table MIG_LOCKER

      truncate table MIG_LOCKERCHG

      truncate table MIG_LOCKERACC

      truncate table MIG_LOCKERKEY

      truncate table MIG_LOCKERDTLS

      truncate table MIG_HOVERRECBRK

  

      truncate table MIG_SIGNATURE

  

      truncate table MIG_GLOP_BAL

      truncate table MIG_ACOP_BAL

      truncate table MIG_TRAN

  

  

  */



END SP_MIG_MIGRATIONDATACLEAN;
/
