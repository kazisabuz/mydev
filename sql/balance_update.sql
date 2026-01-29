/*update in the loan account's balance related tables according to the data given by the customers*/
begin
  for idx in (select i.iaclink_internal_acnum, l.balance
                from iaclink i, acntbal a, loan_bal l
               where a.acntbal_internal_acnum = i.iaclink_internal_acnum
                 and l.acc_no = i.iaclink_actual_acnum) loop
    update acntbal c
       set c.acntbal_ac_cur_db_sum = abs (idx.balance),
       c.acntbal_bc_cur_db_sum = abs (idx.balance),
       c.acntbal_ac_bal = idx.balance,
       c.acntbal_bc_bal = idx.balance
     where c.acntbal_internal_acnum = idx.iaclink_internal_acnum;
  end loop;
end;


begin
  for idx in (select i.iaclink_internal_acnum, l.balance
                from tran2014 t, loan_bal l, iaclink i
               where i.iaclink_internal_acnum = t.tran_internal_acnum
                 and i.iaclink_actual_acnum = l.acc_no) loop
    update tran2014 c
       set c.tran_amount                = abs(idx.balance),
           c.tran_base_curr_eq_amt      = abs(idx.balance),
           c.tran_limit_curr_equivalent = abs(idx.balance)
     where c.tran_internal_acnum = idx.iaclink_internal_acnum;
  end loop;
end;


begin
  for idx in (select i.iaclink_internal_acnum, l.balance
                from acbalasonhist a, loan_bal l, iaclink i
               where i.iaclink_internal_acnum = a.acbalh_internal_acnum
                 and l.acc_no = i.iaclink_actual_acnum
                 and a.acbalh_ason_date = '27-OCT-2014') loop
    update acbalasonhist c
       set c.acbalh_ac_bal              = idx.balance,
           c.acbalh_bc_bal              = idx.balance
     where c.acbalh_internal_acnum = idx.iaclink_internal_acnum;
  end loop;
end;