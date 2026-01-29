/*Typically the total number of data in acnts, iaclink and acntlink table needs to be same. Sometimes, we face problem like the total number of records in those 3 tables are not same. So, we had to rely on the records in the table which has the maximum records.*/
insert into iaclink 
select 1                       IACLINK_ENTITY_NUM,
       a.acnts_internal_acnum  IACLINK_INTERNAL_ACNUM,
       a.acnts_brn_code        IACLINK_BRN_CODE,
       a.acnts_client_num      IACLINK_CIF_NUMBER,
       a.acnts_ac_seq_num      IACLINK_AC_SEQ_NUM,
       a.acnts_account_number  IACLINK_ACCOUNT_NUMBER,
       ac.acntotn_old_acnt_num IACLINK_ACTUAL_ACNUM,
       ac.acntotn_old_acnt_num IACLINK_ACNT_IN_NUMBER,
       a.acnts_prod_code       IACLINK_PROD_CODE
  from acnts a, acntotn ac
 where a.acnts_internal_acnum not in
       (select iaclink.iaclink_internal_acnum from iaclink)
   and a.acnts_internal_acnum = ac.acntotn_internal_acnum;
   
   
----- acntlink table query------------
insert into acntlink 
select 1,
       a.acnts_brn_code,
       a.acnts_client_num,
       a.acnts_ac_seq_num,
       a.acnts_internal_acnum,
       a.acnts_account_number
  from acnts a
 where a.acnts_internal_acnum not in
       (select acntlink.acntlink_internal_acnum from acntlink);