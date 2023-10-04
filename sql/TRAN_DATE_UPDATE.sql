BEGIN
   FOR IDX
      IN (SELECT ACC_NO,IACLINK_INTERNAL_ACNUM, LAST_TRAN_DATE
            FROM acc4, iaclink
           WHERE IACLINK_ENTITY_NUM = 1 AND ACC_NO = IACLINK_ACTUAL_ACNUM)
   LOOP
      UPDATE ACNTS
         SET ACNTS_LAST_TRAN_DATE = IDX.LAST_TRAN_DATE,
             ACNTS_NONSYS_LAST_DATE = IDX.LAST_TRAN_DATE
       WHERE     ACNTS_INTERNAL_ACNUM = IDX.IACLINK_INTERNAL_ACNUM
             AND ACNTS_ENTITY_NUM = 1;
   END LOOP;
END;