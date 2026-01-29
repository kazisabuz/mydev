/*Due to some system problem, system was not updating the LLACNTOS table properly. But the update was happening in the LNACDISB table correctly. This upadte was written so that we can update the LLACNTOS table with the data of LNACDISB table.*/
declare
  V_COUNT NUMBER := 0;
begin
  for idx in (SELECT ac.acaslldtl_client_num,
                     ac.acaslldtl_limit_line_num,
                     LL_OS.LLACNTOS_CLIENT_ACNUM,
                     LL_OS.LLACNTOS_LIMIT_CURR_DISB_MADE,
                     LL_DISB.LNACDISB_INTERNAL_ACNUM,
                     LL_DISB.TOTAL_DISB
                FROM LLACNTOS LL_OS,
                     acaslldtl ac,
                     (SELECT L.LNACDISB_INTERNAL_ACNUM,
                             SUM(L.LNACDISB_DISB_AMT) TOTAL_DISB
                        FROM LNACDISB L
                       WHERE L.LNACDISB_AUTH_BY IS NOT NULL
                       GROUP BY L.LNACDISB_INTERNAL_ACNUM) LL_DISB
               WHERE LL_OS.LLACNTOS_CLIENT_ACNUM =
                     LL_DISB.LNACDISB_INTERNAL_ACNUM
                 AND - 1 * (ABS(LL_DISB.TOTAL_DISB)) <>
                     LL_OS.LLACNTOS_LIMIT_CURR_DISB_MADE
                 AND AC.ACASLLDTL_INTERNAL_ACNUM =
                     LL_OS.LLACNTOS_CLIENT_ACNUM
                 AND AC.ACASLLDTL_LIMIT_LINE_NUM =
                     LL_OS.LLACNTOS_LIMIT_LINE_NUM
                 AND LL_OS.LLACNTOS_CLIENT_ACNUM NOT IN
                     (SELECT A.ACNTINWTRF_DEP_AC_NUM FROM Acntinwtrf A)) loop
    update llacntos l_os
       set l_os.llacntos_limit_curr_disb_made =
           (-1) * idx.total_disb
    
     where l_os.llacntos_client_acnum = idx.llacntos_client_acnum
       AND L_OS.LLACNTOS_CLIENT_CODE = IDX.ACASLLDTL_CLIENT_NUM
       AND L_OS.LLACNTOS_LIMIT_LINE_NUM = IDX.ACASLLDTL_LIMIT_LINE_NUM
       and l_os.llacntos_client_acnum not in
           (SELECT AA.ACNTINWTRF_DEP_AC_NUM FROM Acntinwtrf AA);
    V_COUNT := V_COUNT + SQL%ROWCOUNT;
  end loop;
  DBMS_OUTPUT.put_line(V_COUNT);
end;
