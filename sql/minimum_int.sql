/* Formatted on 6/30/2021 1:39:00 PM (QP5 v5.252.13127.32867) */
BEGIN
   UPDATE raoperparam
      SET RAOPER_CR_MIN_INT_AMT = 1
    WHERE     RAOPER_AC_TYPE IN (SELECT ACTYPE_CODE
                                   FROM raoperparam, actypes
                                  WHERE     ACTYPE_CODE = RAOPER_AC_TYPE
                                        AND ACTYPE_PROD_CODE IN (1000,
                                                                 1005,
                                                                 1003,
                                                                 1030,
                                                                 1040,
                                                                 1060)
                                        AND RAOPER_CR_MIN_INT_AMT = 50);

   UPDATE RAOPERHIST h
      SET RAOPHIST_CR_MIN_INT_AMT = 1
    WHERE     RAOPHIST_AC_TYPE IN (SELECT ACTYPE_CODE
                                     FROM RAOPERHIST, actypes
                                    WHERE     ACTYPE_CODE = RAOPHIST_AC_TYPE
                                          AND ACTYPE_PROD_CODE IN (1000,
                                                                   1005,
                                                                   1003,
                                                                   1030,
                                                                   1040,
                                                                   1060)
                                          AND RAOPHIST_CR_MIN_INT_AMT = 50)
          AND RAOPHIST_CR_MIN_INT_AMT = 1
          AND RAOPHIST_EFF_DATE =
                 (SELECT MAX (RAOPHIST_EFF_DATE)
                    FROM RAOPERHIST a
                   WHERE a.RAOPHIST_AC_TYPE = h.RAOPHIST_AC_TYPE);
END;


------AC TYPE WISE MINIMUM BALANCE -------------------
SELECT *FROM RAMINBAL