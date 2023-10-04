/* Formatted on 6/24/2020 4:42:04 PM (QP5 v5.227.12220.39754) */
---ATM CARD----
SELECT 'total ATM CARD', count(distinct CIFISS_CARD_NUMBER )
  FROM cifiss
 WHERE  CIFISS_ISS_DATE <='31-dec-2020';
 
 --SME depsitor
 select 'SME depsitor',count(distinct ACNTS_CLIENT_NUM)
 from products,acnts
 where ACNTS_ENTITY_NUM=1
 and PRODUCT_CODE=ACNTS_PROD_CODE
 and PRODUCT_FOR_DEPOSITS='1'
 and ACNTS_OPENING_DATE <='31-dec-2020'
 AND (ACNTS_CLOSURE_DATE IS NULL OR ACNTS_CLOSURE_DATE <= '31-DEC-2020')
 AND NVL (TRIM (ACNTS_SME_CODE), '#') NOT IN ('99', '91');
 
 ---Household depsitor
 select 'Household depsitor',count(distinct ACNTS_CLIENT_NUM)
 from products,acnts,clients
 where ACNTS_ENTITY_NUM=1
 and PRODUCT_CODE=ACNTS_PROD_CODE
 and PRODUCT_FOR_DEPOSITS='1'
 and ACNTS_OPENING_DATE <='31-dec-2020'
 AND (ACNTS_CLOSURE_DATE IS NULL OR ACNTS_CLOSURE_DATE <= '31-DEC-2020')
 and CLIENTS_CUST_SUB_CATG = '12390'
 and ACNTS_CLIENT_NUM=clients_code;
 
 
  ---Household depsitor male
 select 'Household depsitor male',count(distinct ACNTS_CLIENT_NUM)
 from products,acnts,clients,indclients
 where ACNTS_ENTITY_NUM=1
 and PRODUCT_CODE=ACNTS_PROD_CODE
 and PRODUCT_FOR_DEPOSITS='1'
 and ACNTS_OPENING_DATE <='31-dec-2020'
 AND (ACNTS_CLOSURE_DATE IS NULL OR ACNTS_CLOSURE_DATE <= '31-DEC-2020')
 and CLIENTS_CUST_SUB_CATG = '12390'
 and ACNTS_CLIENT_NUM=clients_code
 and INDCLIENT_CODE=clients_code
 and trim(INDCLIENT_SEX)='M';
 
 
   ---Household depsitor female
 select 'Household depsitor female',count(distinct ACNTS_CLIENT_NUM)
 from products,acnts,clients,indclients
 where ACNTS_ENTITY_NUM=1
 and PRODUCT_CODE=ACNTS_PROD_CODE
 and PRODUCT_FOR_DEPOSITS='1'
 and ACNTS_OPENING_DATE <='31-dec-2020'
 AND (ACNTS_CLOSURE_DATE IS NULL OR ACNTS_CLOSURE_DATE <= '31-DEC-2020')
 and CLIENTS_CUST_SUB_CATG = '12390'
 and ACNTS_CLIENT_NUM=clients_code
 and INDCLIENT_CODE=clients_code
 and trim(INDCLIENT_SEX)='F';
 
 ---TOTAL DEPOSIT ACC
 select 'TOTAL DEPOSIT ACC', COUNT(ACNTS_INTERNAL_ACNUM)
 from products,acnts
 where ACNTS_ENTITY_NUM=1
 and PRODUCT_CODE=ACNTS_PROD_CODE
 and PRODUCT_FOR_DEPOSITS='1'
 and ACNTS_OPENING_DATE <='31-dec-2020'
 AND (ACNTS_CLOSURE_DATE IS NULL OR ACNTS_CLOSURE_DATE <= '31-DEC-2020')
 and trim(ACNTS_SME_CODE) not in (99,91);
 
 
 ---Household depsitor ACC
 select 'Household depsitor ACC',COUNT(ACNTS_INTERNAL_ACNUM)
 from products,acnts,clients
 where ACNTS_ENTITY_NUM=1
 and PRODUCT_CODE=ACNTS_PROD_CODE
 and PRODUCT_FOR_DEPOSITS='1'
 and ACNTS_OPENING_DATE <='31-dec-2020'
 AND (ACNTS_CLOSURE_DATE IS NULL OR ACNTS_CLOSURE_DATE <= '31-DEC-2020')
 and CLIENTS_CUST_SUB_CATG = '12390'
 and ACNTS_CLIENT_NUM=clients_code;
 
 
  ---Household depsitor male ACC
 select 'Household depsitor male ACC', COUNT(ACNTS_INTERNAL_ACNUM)
 from products,acnts,clients,indclients
 where ACNTS_ENTITY_NUM=1
 and PRODUCT_CODE=ACNTS_PROD_CODE
 and PRODUCT_FOR_DEPOSITS='1'
 and ACNTS_OPENING_DATE <='31-dec-2020'
 AND (ACNTS_CLOSURE_DATE IS NULL OR ACNTS_CLOSURE_DATE <= '31-DEC-2020')
 and CLIENTS_CUST_SUB_CATG = '12390'
 and ACNTS_CLIENT_NUM=clients_code
 and INDCLIENT_CODE=clients_code
 and trim(INDCLIENT_SEX)='M';
 
 
   ---Household depsitor female
 select 'Household depsitor female', count(distinct ACNTS_CLIENT_NUM)
 from products,acnts,clients,indclients
 where ACNTS_ENTITY_NUM=1
 and PRODUCT_CODE=ACNTS_PROD_CODE
 and PRODUCT_FOR_DEPOSITS='1'
 and ACNTS_OPENING_DATE <='31-dec-2020'
 AND (ACNTS_CLOSURE_DATE IS NULL OR ACNTS_CLOSURE_DATE <= '31-DEC-2020')
 and CLIENTS_CUST_SUB_CATG = '12390'
 and ACNTS_CLIENT_NUM=clients_code
 and INDCLIENT_CODE=clients_code
 and trim(INDCLIENT_SEX)='F';
 
 
  --SME Borrower
 select 'SME Borrower',count(distinct ACNTS_CLIENT_NUM)
 from products,acnts,lnacmis
 where ACNTS_ENTITY_NUM=1
 and PRODUCT_CODE=ACNTS_PROD_CODE
 and PRODUCT_FOR_LOANS='1'
 and ACNTS_OPENING_DATE <='31-dec-2020'
 AND (ACNTS_CLOSURE_DATE IS NULL OR ACNTS_CLOSURE_DATE <= '31-DEC-2020')
 and LNACMIS_INTERNAL_ACNUM=ACNTS_INTERNAL_ACNUM
  and LNACMIS_NATURE_BORROWAL_AC not in (99,91)
  and LNACMIS_ENTITY_NUM=1;
  
  ---Household Borrower
 select 'Household Borrower', count(distinct ACNTS_CLIENT_NUM)
 from products,acnts,clients
 where ACNTS_ENTITY_NUM=1
 and PRODUCT_CODE=ACNTS_PROD_CODE
 and PRODUCT_FOR_LOANS='1'
 and ACNTS_OPENING_DATE <='31-dec-2020'
 AND (ACNTS_CLOSURE_DATE IS NULL OR ACNTS_CLOSURE_DATE <= '31-DEC-2020')
 and CLIENTS_CUST_SUB_CATG = '12390'
 and ACNTS_CLIENT_NUM=clients_code;
 
 
  ---Household Borrower male
 select 'Household Borrower male',count(distinct ACNTS_CLIENT_NUM)
 from products,acnts,clients,indclients
 where ACNTS_ENTITY_NUM=1
 and PRODUCT_CODE=ACNTS_PROD_CODE
 and PRODUCT_FOR_LOANS='1'
 and ACNTS_OPENING_DATE <='31-dec-2017'
 AND (ACNTS_CLOSURE_DATE IS NULL OR ACNTS_CLOSURE_DATE <= '31-DEC-2020')
 and CLIENTS_CUST_SUB_CATG = '12390'
 and ACNTS_CLIENT_NUM=clients_code
 and INDCLIENT_CODE=clients_code
 and trim(INDCLIENT_SEX)='M';
 
 
   ---Household Borrower female
 select 'Household Borrower female', count(distinct ACNTS_CLIENT_NUM)
 from products,acnts,clients,indclients
 where ACNTS_ENTITY_NUM=1
 and PRODUCT_CODE=ACNTS_PROD_CODE
 and PRODUCT_FOR_LOANS='1'
 and ACNTS_OPENING_DATE <='31-dec-2020'
 AND (ACNTS_CLOSURE_DATE IS NULL OR ACNTS_CLOSURE_DATE <= '31-DEC-2020')
 and CLIENTS_CUST_SUB_CATG = '12390'
 and ACNTS_CLIENT_NUM=clients_code
 and INDCLIENT_CODE=clients_code
 and trim(INDCLIENT_SEX)='F';
 
 
  --SME Borrower acc
 select 'SME Borrower acc',COUNT(ACNTS_INTERNAL_ACNUM)
 from products,acnts,lnacmis
 where ACNTS_ENTITY_NUM=1
 and PRODUCT_CODE=ACNTS_PROD_CODE
 and PRODUCT_FOR_LOANS='1'
 and ACNTS_OPENING_DATE <='31-dec-2020'
 AND (ACNTS_CLOSURE_DATE IS NULL OR ACNTS_CLOSURE_DATE <= '31-DEC-2020')
 and LNACMIS_INTERNAL_ACNUM=ACNTS_INTERNAL_ACNUM
  and LNACMIS_NATURE_BORROWAL_AC not in (99,91)
  and LNACMIS_ENTITY_NUM=1;
  
  
    ---Household Borrower acc
 select 'Household Borrower acc', COUNT(ACNTS_INTERNAL_ACNUM)
 from products,acnts,clients
 where ACNTS_ENTITY_NUM=1
 and PRODUCT_CODE=ACNTS_PROD_CODE
 and PRODUCT_FOR_LOANS='1'
 and ACNTS_OPENING_DATE <='31-dec-2020'
 AND (ACNTS_CLOSURE_DATE IS NULL OR ACNTS_CLOSURE_DATE <= '31-DEC-2020')
 and CLIENTS_CUST_SUB_CATG = '12390'
 and ACNTS_CLIENT_NUM=clients_code;
 
 
  ---Household Borrower female ACC
 select 'Household Borrower female ACC', COUNT(ACNTS_INTERNAL_ACNUM)
 from products,acnts,clients,indclients
 where ACNTS_ENTITY_NUM=1
 and PRODUCT_CODE=ACNTS_PROD_CODE
 and PRODUCT_FOR_LOANS='1'
 and ACNTS_OPENING_DATE <='31-dec-2020'
 AND (ACNTS_CLOSURE_DATE IS NULL OR ACNTS_CLOSURE_DATE <= '31-DEC-2020')
 and CLIENTS_CUST_SUB_CATG = '12390'
 and ACNTS_CLIENT_NUM=clients_code
 and INDCLIENT_CODE=clients_code
 and trim(INDCLIENT_SEX)='F'
 and ACNTS_CLIENT_NUM=INDCLIENT_CODE;
 
 
   ---Household Borrower male ACC
 select 'Household Borrower male ACC', COUNT(ACNTS_INTERNAL_ACNUM)
 from products,acnts,clients,indclients
 where ACNTS_ENTITY_NUM=1
 and PRODUCT_CODE=ACNTS_PROD_CODE
 and PRODUCT_FOR_LOANS='1'
 and ACNTS_OPENING_DATE <='31-dec-2020'
 AND (ACNTS_CLOSURE_DATE IS NULL OR ACNTS_CLOSURE_DATE <= '31-DEC-2020')
 and CLIENTS_CUST_SUB_CATG = '12390'
 and ACNTS_CLIENT_NUM=clients_code
 and INDCLIENT_CODE=clients_code
 and trim(INDCLIENT_SEX)='M'
 and ACNTS_CLIENT_NUM=INDCLIENT_CODE;