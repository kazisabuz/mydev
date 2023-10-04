/* Formatted on 4/1/2021 12:39:51 AM (QP5 v5.252.13127.32867) */
DECLARE
   V_COUNT   NUMBER := 0;
BEGIN
   FOR idx
      IN (SELECT ac.acaslldtl_client_num,
                 ac.acaslldtl_limit_line_num,
                 LL_OS.LLACNTOS_CLIENT_ACNUM,
                 LL_OS.LLACNTOS_LIMIT_CURR_DISB_MADE,
                 LL_DISB.LNACDISB_INTERNAL_ACNUM,
                 LL_DISB.TOTAL_DISB
            FROM LLACNTOS LL_OS,
                 acaslldtl ac,
                 (  SELECT L.LNACDISB_INTERNAL_ACNUM,
                           SUM (L.LNACDISB_DISB_AMT) TOTAL_DISB
                      FROM LNACDISB L
                     WHERE L.LNACDISB_AUTH_BY IS NOT NULL
                  GROUP BY L.LNACDISB_INTERNAL_ACNUM) LL_DISB
           WHERE     LL_OS.LLACNTOS_CLIENT_ACNUM =
                        LL_DISB.LNACDISB_INTERNAL_ACNUM
                 AND -1 * (ABS (LL_DISB.TOTAL_DISB)) <>0
                       
                 AND AC.ACASLLDTL_INTERNAL_ACNUM =
                        LL_OS.LLACNTOS_CLIENT_ACNUM
                        and LL_OS.LLACNTOS_LIMIT_CURR_DISB_MADE=0
                 AND AC.ACASLLDTL_LIMIT_LINE_NUM =
                        LL_OS.LLACNTOS_LIMIT_LINE_NUM
                 AND LL_OS.LLACNTOS_CLIENT_ACNUM NOT IN (SELECT A.ACNTINWTRF_DEP_AC_NUM
                                                           FROM Acntinwtrf A))
   LOOP
      UPDATE llacntos l_os
         SET l_os.llacntos_limit_curr_disb_made = (-1) * idx.total_disb
       WHERE     l_os.llacntos_client_acnum = idx.llacntos_client_acnum
             AND L_OS.LLACNTOS_CLIENT_CODE = IDX.ACASLLDTL_CLIENT_NUM
             AND L_OS.LLACNTOS_LIMIT_LINE_NUM = IDX.ACASLLDTL_LIMIT_LINE_NUM
             AND l_os.llacntos_client_acnum NOT IN (SELECT AA.ACNTINWTRF_DEP_AC_NUM
                                                      FROM Acntinwtrf AA);

      V_COUNT := V_COUNT + SQL%ROWCOUNT;
   END LOOP;

   DBMS_OUTPUT.put_line (V_COUNT);
END;