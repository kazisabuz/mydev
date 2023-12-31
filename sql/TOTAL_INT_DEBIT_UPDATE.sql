 BEGIN
   FOR IDX IN (SELECT I.IACLINK_INTERNAL_ACNUM, ACC4.TOTAL
                 FROM ACC4, IACLINK I
                WHERE ACC4.ACC_NO = I.IACLINK_ACTUAL_ACNUM)
   LOOP
      UPDATE LNTOTINTDBMIG
         SET LNTOTINTDB_TOT_INT_DB_AMT = IDX.TOTAL
       WHERE LNTOTINTDB_INTERNAL_ACNUM = IDX.IACLINK_INTERNAL_ACNUM;
   END LOOP;
END;