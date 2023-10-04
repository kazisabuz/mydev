BEGIN
   FOR IDX IN (SELECT I.IACLINK_INTERNAL_ACNUM, ACC4.INT_AMOUNT
                 FROM ACC4, IACLINK I
                WHERE ACC4.ACCOUNT_NO = I.IACLINK_ACTUAL_ACNUM)
   LOOP
      UPDATE LOANIAMRR M
         SET M.LOANIAMRR_TOTAL_NEW_INT_AMT = IDX.INT_AMOUNT,
             M.LOANIAMRR_INT_AMT = IDX.INT_AMOUNT,
             M.LOANIAMRR_INT_AMT_RND = IDX.INT_AMOUNT
       WHERE     LOANIAMRR_ACNT_NUM = IDX.IACLINK_INTERNAL_ACNUM
             AND LOANIAMRR_ENTITY_NUM = '1'
             AND LOANIAMRR_ACCRUAL_DATE = '12-OCT-2017';

      UPDATE LOANIAMRRDTL 
         SET LOANIAMRRDTL_UPTO_AMT = IDX.INT_AMOUNT,
             LOANIAMRRDTL_INT_AMT = IDX.INT_AMOUNT,
             LOANIAMRRDTL_INT_AMT_RND = IDX.INT_AMOUNT
       WHERE     LOANIAMRRDTL_ACNT_NUM = IDX.IACLINK_INTERNAL_ACNUM
             AND LOANIAMRRDTL_ENTITY_NUM = '1'
             AND LOANIAMRRDTL_ACCRUAL_DATE = '12-OCT-2017';
   END LOOP;
END;