PL/SQL Developer Test script 3.0
15
begin
  -- Call the procedure
  pkg_gen_acnum.sp_acnts_num(v_entity_num => :v_entity_num,
                             p_brn_code => :p_brn_code,
                             p_cif_num => :p_cif_num,
                             p_prod_code => :p_prod_code,
                             p_curr_code => :p_curr_code,
                             p_int_acnum => :p_int_acnum,
                             p_account_number => :p_account_number,
                             p_seq_num_in => :p_seq_num_in,
                             p_seq_num_out => :p_seq_num_out,
                             p_err_msg => :p_err_msg,
                             p_manual_num => :p_manual_num,
                             p_sub_brn_code => :p_sub_brn_code);
end;
12
v_entity_num
1
1
4
p_brn_code
1
40097
4
p_cif_num
1
24555382
4
p_prod_code
1
1000
4
p_curr_code
1
BDT
5
p_int_acnum
1
14009700015348
4
p_account_number
1
40097000024555382100001
5
p_seq_num_in
0
4
p_seq_num_out
1
100001
4
p_err_msg
0
5
p_manual_num
0
5
p_sub_brn_code
0
4
0
