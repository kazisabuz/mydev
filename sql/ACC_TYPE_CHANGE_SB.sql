  UPDATE ACNTS   SET  ACNTS_AC_TYPE = 'SB', 
         ACNTS_AC_SUB_TYPE =1
   WHERE  ACNTS_BRN_CODE = 58156
   AND ACNTS_PROD_CODE = 1000
   AND ACNTS_INTERNAL_ACNUM in  ( SELECT IACLINK_INTERNAL_ACNUM  
                FROM IACLINK  WHERE IACLINK_ACTUAL_ACNUM IN (
));