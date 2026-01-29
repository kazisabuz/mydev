/*On every month start dates, system should insert data in historical balance related tables. But due to some network error/system error, data insertion got inturrepted. We had to insert data manually for a particular branch.*/

INSERT INTO ACNTCVDBBAL
          (ACNTCVBBAL_ENTITY_NUM,
           ACNTCVBBAL_INTERNAL_ACNUM,
           ACNTCVBBAL_CURR_CODE,
           ACNTCVBBAL_CONT_NUM,
           ACNTCVBBAL_YEAR,
           ACNTCVBBAL_MONTH,
           ACNTCVBBAL_AC_OPNG_DB_SUM,
           ACNTCVBBAL_AC_OPNG_CR_SUM,
           ACNTCVBBAL_BC_OPNG_DB_SUM,
           ACNTCVBBAL_BC_OPNG_CR_SUM,
           ACNTCVBBAL_OPBAL_ENTD_BY,
           ACNTCVBBAL_OPBAL_ENTD_ON,
           ACNTCVBBAL_OPBAL_MOD_BY,
           ACNTCVBBAL_OPBAL_MOD_ON)
          (SELECT 1,
                  ACNTCBAL_INTERNAL_ACNUM,
                  ACNTCBAL_CURR_CODE,
                  ACNTCBAL_CONTRACT_NUM,
                  2016,
                  4,
                  ACNTCBAL_AC_CUR_DB_SUM - ACNTCBAL_AC_CLG_DB_SUM,
                  ACNTCBAL_AC_CUR_CR_SUM - ACNTCBAL_AC_CLG_CR_SUM,
                  ACNTCBAL_BC_CUR_DB_SUM - ACNTCBAL_BC_CLG_DB_SUM,
                  ACNTCBAL_BC_CUR_CR_SUM - ACNTCBAL_BC_CLG_CR_SUM,
                  'MIG',
                  '31-MAR-2016',
                  ' ',
                  NULL
             FROM ACNTCBAL, ACNTS  
			 WHERE ACNTCBAL_ENTITY_NUM = 1
             AND ACNTS_ENTITY_NUM = ACNTCBAL_ENTITY_NUM
             AND ACNTS_INTERNAL_ACNUM = ACNTCBAL_INTERNAL_ACNUM
             AND ACNTS_BRN_CODE = 56119
             AND ACNTS_ENTD_BY = 'MIG'
             AND ACNTCBAL_CONTRACT_NUM = 1)






INSERT INTO ACNTCBBAL
          (ACNTCBBAL_ENTITY_NUM,
           ACNTCBBAL_INTERNAL_ACNUM,
           ACNTCBBAL_CURR_CODE,
           ACNTCBBAL_CONT_NUM,
           ACNTCBBAL_YEAR,
           ACNTCBBAL_MONTH,
           ACNTCBBAL_AC_OPNG_DB_SUM,
           ACNTCBBAL_AC_OPNG_CR_SUM,
           ACNTCBBAL_BC_OPNG_DB_SUM,
           ACNTCBBAL_BC_OPNG_CR_SUM,
           ACNTCBBAL_OPBAL_ENTD_BY,
           ACNTCBBAL_OPBAL_ENTD_ON,
           ACNTCBBAL_OPBAL_LAST_MOD_BY,
           ACNTCBBAL_OPBAL_LAST_MOD_ON)
          (SELECT 1,
                  ACNTCBAL_INTERNAL_ACNUM,
                  ACNTCBAL_CURR_CODE,
                  ACNTCBAL_CONTRACT_NUM,
                  2016,
                  4,
                  ACNTCBAL_AC_CUR_DB_SUM,
                  ACNTCBAL_AC_CUR_CR_SUM,
                  ACNTCBAL_BC_CUR_DB_SUM,
                  ACNTCBAL_BC_CUR_CR_SUM,
                  'MIG',
                  '31-MAR-2016',
                  ' ',
                  NULL
             FROM ACNTCBAL, ACNTS WHERE ACNTCBAL_ENTITY_NUM = 1
             AND ACNTS_ENTITY_NUM = ACNTCBAL_ENTITY_NUM
             AND ACNTS_INTERNAL_ACNUM = ACNTCBAL_INTERNAL_ACNUM
             AND ACNTS_BRN_CODE = 56119
             AND ACNTS_ENTD_BY = 'MIG'
             AND ACNTCBAL_CONTRACT_NUM = 1)







insert into ADVBBAL
select 1 ADVBBAL_ENTITY_NUM,
       tt.tran_internal_acnum ADVBBAL_INTERNAL_ACNUM,
       'BDT' ADVBBAL_CURR_CODE,
       2016 ADVBBAL_YEAR,
       4 ADVBBAL_MONTH,
       (-1)* t.tranadv_prin_ac_amt ADVBBAL_PRIN_AC_OPBAL,
       (-1)* t.tranadv_prin_bc_amt ADVBBAL_PRIN_BC_OPBAL,
       (-1)* t.tranadv_intrd_ac_amt ADVBBAL_INTRD_AC_OPBAL,
       (-1)* t.tranadv_intrd_bc_amt ADVBBAL_INTRD_BC_OPBAL,
       (-1)* t.tranadv_charge_ac_amt ADVBBAL_CHARGE_AC_OPBAL,
       (-1)* t.tranadv_charge_bc_amt ADVBBAL_CHARGE_BC_OPBAL,
       t.tranadv_prin_ac_amt ADVBBAL_PRIN_AC_DB_OPBAL,
       0 ADVBBAL_PRIN_AC_CR_OPBAL,
       t.tranadv_prin_ac_amt ADVBBAL_PRIN_BC_DB_OPBAL,
       0 ADVBBAL_PRIN_BC_CR_OPBAL,
       t.tranadv_intrd_ac_amt ADVBBAL_INTRD_AC_DB_OPBAL,
       0 ADVBBAL_INTRD_AC_CR_OPBAL,
       t.tranadv_intrd_ac_amt ADVBBAL_INTRD_BC_DB_OPBAL,
       0 ADVBBAL_INTRD_BC_CR_OPBAL,
       t.tranadv_charge_ac_amt ADVBBAL_CHARGE_AC_DB_OPBAL,
       0 ADVBBAL_CHARGE_AC_CR_OPBAL,
       t.tranadv_charge_ac_amt ADVBBAL_CHARGE_BC_DB_OPBAL,
       0 ADVBBAL_CHARGE_BC_CR_OPBAL,
       0 ADVBBAL_PRIN_AC_OPCLG_CR_SUM,
       0 ADVBBAL_PRIN_AC_OPCLG_DB_SUM,
       0 ADVBBAL_PRIN_BC_OPCLG_CR_SUM,
       0 ADVBBAL_PRIN_BC_OPCLG_DB_SUM,
       0 ADVBBAL_INTRD_AC_OPCLG_CR_SUM,
       0 ADVBBAL_INTRD_AC_OPCLG_DB_SUM,
       0 ADVBBAL_INTRD_BC_OPCLG_CR_SUM,
       0 ADVBBAL_INTRD_BC_OPCLG_DB_SUM,
       0 ADVBBAL_CHARGE_AC_OPCLG_CR_SUM,
       0 ADVBBAL_CHARGE_AC_OPCLG_DB_SUM,
       0 ADVBBAL_CHARGE_BC_OPCLG_CR_SUM,
       0 ADVBBAL_CHARGE_BC_OPCLG_DB_SUM
--select *
  from tranadv2016 t, tran2016 tt
 where t.tranadv_brn_code = 56119
   and t.tranadv_date_of_tran = '31-MAR-2016'
   and tt.tran_date_of_tran = t.tranadv_date_of_tran
   and tt.tran_batch_number = t.tranadv_batch_number
   and tt.tran_batch_sl_num = t.tranadv_batch_sl_num
   and tt.tran_brn_code = t.tranadv_brn_code;


insert into ADVVDBBAL
select 1 ADVVDBBAL_ENTITY_NUM,
       tt.tran_internal_acnum ADVVDBBAL_INTERNAL_ACNUM,
       'BDT' ADVVDBBAL_CURR_CODE,
       2016 ADVVDBBAL_YEAR,
       4 ADVVDBBAL_MONTH,
       (-1)* t.tranadv_prin_ac_amt ADVVDBBAL_PRIN_AC_OPBAL,
       (-1)* t.tranadv_prin_ac_amt ADVVDBBAL_PRIN_BC_OPBAL,
       (-1)* t.tranadv_intrd_ac_amt ADVVDBBAL_INTRD_AC_OPBAL,
       (-1)* t.tranadv_intrd_bc_amt ADVVDBBAL_INTRD_BC_OPBAL,
       (-1)* t.tranadv_charge_ac_amt ADVVDBBAL_CHARGE_AC_OPBAL,
       (-1)* t.tranadv_charge_bc_amt ADVVDBBAL_CHARGE_BC_OPBAL
  from tranadv2016 t, tran2016 tt
 where t.tranadv_brn_code = 56119
   and t.tranadv_date_of_tran = '31-MAR-2016'
   and tt.tran_date_of_tran = t.tranadv_date_of_tran
   and tt.tran_batch_number = t.tranadv_batch_number
   and tt.tran_batch_sl_num = t.tranadv_batch_sl_num
   and tt.tran_brn_code = t.tranadv_brn_code;

   
   
   
   
   
   
   
insert into ACNTBBAL
select 1 ACNTBBAL_ENTITY_NUM,
       t.tran_internal_acnum ACNTBBAL_INTERNAL_ACNUM,
       'BDT' ACNTBBAL_CURR_CODE,
       2016 ACNTBBAL_YEAR,
       4 ACNTBBAL_MONTH,
       0 ACNTBBAL_AC_OPNG_DB_SUM,
       t.tran_amount ACNTBBAL_AC_OPNG_CR_SUM,
       0 ACNTBBAL_BC_OPNG_DB_SUM,
       t.tran_amount ACNTBBAL_BC_OPNG_CR_SUM,
       'MIG' ACNTBBAL_OPBAL_ENTD_BY,
       '31-MAR-2016' ACNTBBAL_OPBAL_ENTD_ON,
       null ACNTBBAL_OPBAL_LAST_MOD_BY,
       null ACNTBBAL_OPBAL_LAST_MOD_ON,
       0 ACNTBBAL_AC_OPNG_FWDVAL_DB_SUM,
       0 ACNTBBAL_BC_OPNG_FWDVAL_DB_SUM,
       0 ACNTBBAL_AC_OPNG_FWDVAL_CR_SUM,
       0 ACNTBBAL_BC_OPNG_FWDVAL_CR_SUM,
       0 ACNTBBAL_AC_OPNG_CLG_CR_SUM,
       0 ACNTBBAL_AC_OPNG_CLG_DB_SUM,
       0 ACNTBBAL_BC_OPNG_CLG_CR_SUM,
       0 ACNTBBAL_BC_OPNG_CLG_DB_SUM
  from tran2016 t
 where t.tran_brn_code = 56119
   and t.tran_date_of_tran = '31-MAR-2016'
   and t.tran_internal_acnum <> 0
   and t.tran_db_cr_flg = 'C';


insert into ACNTBBAL
select 1 ACNTBBAL_ENTITY_NUM,
       t.tran_internal_acnum ACNTBBAL_INTERNAL_ACNUM,
       'BDT' ACNTBBAL_CURR_CODE,
       2016 ACNTBBAL_YEAR,
       4 ACNTBBAL_MONTH,
       t.tran_amount ACNTBBAL_AC_OPNG_DB_SUM,
       0 ACNTBBAL_AC_OPNG_CR_SUM,
       t.tran_amount ACNTBBAL_BC_OPNG_DB_SUM,
       0 ACNTBBAL_BC_OPNG_CR_SUM,
       'MIG' ACNTBBAL_OPBAL_ENTD_BY,
       '31-MAR-2016' ACNTBBAL_OPBAL_ENTD_ON,
       null ACNTBBAL_OPBAL_LAST_MOD_BY,
       null ACNTBBAL_OPBAL_LAST_MOD_ON,
       0 ACNTBBAL_AC_OPNG_FWDVAL_DB_SUM,
       0 ACNTBBAL_BC_OPNG_FWDVAL_DB_SUM,
       0 ACNTBBAL_AC_OPNG_FWDVAL_CR_SUM,
       0 ACNTBBAL_BC_OPNG_FWDVAL_CR_SUM,
       0 ACNTBBAL_AC_OPNG_CLG_CR_SUM,
       0 ACNTBBAL_AC_OPNG_CLG_DB_SUM,
       0 ACNTBBAL_BC_OPNG_CLG_CR_SUM,
       0 ACNTBBAL_BC_OPNG_CLG_DB_SUM
  from tran2016 t
 where t.tran_brn_code = 56119
   and t.tran_date_of_tran = '31-MAR-2016'
   and t.tran_internal_acnum <> 0
   and t.tran_db_cr_flg = 'D';
  

insert into ACNTVDBBAL
select 1 ACNTVBBAL_ENTITY_NUM,
       t.tran_internal_acnum ACNTVBBAL_INTERNAL_ACNUM,
       'BDT' ACNTVBBAL_CURR_CODE,
       2016 ACNTVBBAL_YEAR,
       4 ACNTVBBAL_MONTH,
       t.tran_amount ACNTVBBAL_AC_OPNG_DB_SUM,
       0 ACNTVBBAL_AC_OPNG_CR_SUM,
       t.tran_amount ACNTVBBAL_BC_OPNG_DB_SUM,
       0 ACNTVBBAL_BC_OPNG_CR_SUM,
       'MIG' ACNTVBBAL_OPBAL_ENTD_BY,
       '31-MAR-2016' ACNTVBBAL_OPBAL_ENTD_ON,
       null ACNTVBBAL_OPBAL_LAST_MOD_BY,
       null ACNTVBBAL_OPBAL_LAST_MOD_ON
  from tran2016 t
 where t.tran_brn_code = 56119
   and t.tran_date_of_tran = '31-MAR-2016'
   and t.tran_internal_acnum <> 0
   and t.tran_db_cr_flg = 'D';
   
insert into ACNTVDBBAL
select 1 ACNTVBBAL_ENTITY_NUM,
       t.tran_internal_acnum ACNTVBBAL_INTERNAL_ACNUM,
       'BDT' ACNTVBBAL_CURR_CODE,
       2016 ACNTVBBAL_YEAR,
       4 ACNTVBBAL_MONTH,
       0 ACNTVBBAL_AC_OPNG_DB_SUM,
       t.tran_amount ACNTVBBAL_AC_OPNG_CR_SUM,
       0 ACNTVBBAL_BC_OPNG_DB_SUM,
       t.tran_amount ACNTVBBAL_BC_OPNG_CR_SUM,
       'MIG' ACNTVBBAL_OPBAL_ENTD_BY,
       '31-MAR-2016' ACNTVBBAL_OPBAL_ENTD_ON,
       null ACNTVBBAL_OPBAL_LAST_MOD_BY,
       null ACNTVBBAL_OPBAL_LAST_MOD_ON
  from tran2016 t
 where t.tran_brn_code = 56119
   and t.tran_date_of_tran = '31-MAR-2016'
   and t.tran_internal_acnum <> 0
   and t.tran_db_cr_flg = 'C';