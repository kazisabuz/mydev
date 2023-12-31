 BEGIN
   FOR IDX
      IN (SELECT I.IACLINK_INTERNAL_ACNUM,
                 TRIM (UPPER (ACC4.ACC_TYPE)) ACC_TYPE,
                 TRIM (ACC4.ACC_SUB_TYPE) ACC_SUB_TYPE
            FROM acc4, IACLINK I
           WHERE TRIM(ACC4.ACC_NO) = I.IACLINK_ACTUAL_ACNUM)
   LOOP
      UPDATE ACNTS A
         SET A.ACNTS_AC_TYPE = IDX.ACC_TYPE,
             A.ACNTS_AC_SUB_TYPE = IDX.ACC_SUB_TYPE
       WHERE A.ACNTS_INTERNAL_ACNUM = IDX.IACLINK_INTERNAL_ACNUM;
   END LOOP;
END;