/*LLACNTOS table rectification after migration.*/
-- For Continuous Loans  
insert into llacntos
  select 1,
         a.iaclink_cif_number,
         1,
         a.iaclink_internal_acnum,
         l.lnacnt_outstanding_balance -
         (-1) * nvl(l.lnacnt_limit_curr_disb_made, 0), -- For Continuous Loans  
         (-1) * l.lnacnt_limit_curr_disb_made
    from mig_lnacnt l, iaclink a
   where l.lnacnt_acnum = a.iaclink_actual_acnum
     and a.iaclink_prod_code in
         (select p.product_code
            from products p
           where p.product_for_loans = 1
             and p.product_for_run_acs = 1);
   
-- For Term Loans        
insert into llacntos
  select 1,
         a.iaclink_cif_number,
         1,
         a.iaclink_internal_acnum,
         (-1) * (NVL(l.LNACNT_SANCTION_AMT, 0) -
         NVL(LNACNT_LIMIT_CURR_DISB_MADE, 0)), -- For Term Loans 
         (-1) * l.lnacnt_limit_curr_disb_made
    from mig_lnacnt l, iaclink a
   where l.lnacnt_acnum = a.iaclink_actual_acnum
     and a.iaclink_prod_code in
         (select p.product_code
            from products p
           where p.product_for_loans = 1
             and p.product_for_run_acs = 0);
			 
			 
-------------- If data is not imported during the migration........---------------			 
			 
			 
DECLARE
   V_COUNT   NUMBER := 0;
BEGIN
   FOR IDX
      IN (SELECT B.LLACNTOS_ENTITY_NUM,
                 B.LLACNTOS_CLIENT_CODE,
                 B.LLACNTOS_LIMIT_LINE_NUM,
                 B.LLACNTOS_CLIENT_ACNUM,
                 B.LLACNTOS_LIMIT_CURR_OS_AMT,
                 B.LLACNTOS_LIMIT_CURR_DISB_MADE
            FROM LLACNTOS A, LLACNTOS_TEMP B
           WHERE     A.LLACNTOS_ENTITY_NUM = B.LLACNTOS_ENTITY_NUM
                 AND A.LLACNTOS_CLIENT_CODE = B.LLACNTOS_CLIENT_CODE
                 AND A.LLACNTOS_LIMIT_LINE_NUM = B.LLACNTOS_LIMIT_LINE_NUM
                 AND A.LLACNTOS_CLIENT_ACNUM = B.LLACNTOS_CLIENT_ACNUM)
   LOOP
      UPDATE LLACNTOS
         SET LLACNTOS_LIMIT_CURR_OS_AMT =
                LLACNTOS_LIMIT_CURR_OS_AMT + IDX.LLACNTOS_LIMIT_CURR_OS_AMT,
             LLACNTOS_LIMIT_CURR_DISB_MADE =
                  LLACNTOS_LIMIT_CURR_DISB_MADE
                + IDX.LLACNTOS_LIMIT_CURR_DISB_MADE
       WHERE     LLACNTOS_ENTITY_NUM = IDX.LLACNTOS_ENTITY_NUM
             AND LLACNTOS_CLIENT_CODE = IDX.LLACNTOS_CLIENT_CODE
             AND LLACNTOS_LIMIT_LINE_NUM = IDX.LLACNTOS_LIMIT_LINE_NUM
             AND LLACNTOS_CLIENT_ACNUM = IDX.LLACNTOS_CLIENT_ACNUM;

      V_COUNT := V_COUNT + SQL%ROWCOUNT;
   END LOOP;

   DBMS_OUTPUT.PUT_LINE (V_COUNT);
END;


INSERT INTO LLACNTOS
   SELECT *
     FROM LLACNTOS_TEMP L
    WHERE (L.LLACNTOS_ENTITY_NUM,
           L.LLACNTOS_CLIENT_CODE,
           L.LLACNTOS_LIMIT_LINE_NUM,
           L.LLACNTOS_CLIENT_ACNUM) NOT IN
             (SELECT LL.LLACNTOS_ENTITY_NUM,
                     LL.LLACNTOS_CLIENT_CODE,
                     LL.LLACNTOS_LIMIT_LINE_NUM,
                     LL.LLACNTOS_CLIENT_ACNUM
                FROM LLACNTOS LL)