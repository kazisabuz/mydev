---------TOTAL ACTIVE USERS---------------

SELECT COUNT (*)
  FROM USERS
 WHERE USER_SUSP_REL_FLAG != 'R';

--------TOTAL SING IN USERS-------------------

SELECT COUNT (*)
  FROM SIGNINOUT S
 WHERE     SIGN_OUT_TIME IS NULL
       AND (S.SIGN_USER_ID, S.SIGN_IN_TIME) IN
              (  SELECT SIGN_USER_ID, MAX (SIGN_IN_TIME)
                   FROM SIGNINOUT
                  WHERE SIGN_EFF_DATE = '08-AUG-2017'
               GROUP BY SIGN_USER_ID);

---------TOTAL SING IN USERS BRANCH WISE-------------

SELECT SIGN_BRN_CODE, MBRN_NAME, TOTAL
  FROM (  SELECT S.SIGN_BRN_CODE, COUNT (*) TOTAL
            FROM SIGNINOUT S
           WHERE     SIGN_OUT_TIME IS NULL
                 AND (S.SIGN_USER_ID, S.SIGN_IN_TIME) IN
                        (  SELECT SIGN_USER_ID, MAX (SIGN_IN_TIME)
                             FROM SIGNINOUT
                            WHERE SIGN_EFF_DATE = '08-AUG-2017'
                         GROUP BY SIGN_USER_ID)
        GROUP BY S.SIGN_BRN_CODE
        ORDER BY S.SIGN_BRN_CODE) A,
       MBRN
 WHERE A.SIGN_BRN_CODE = MBRN_CODE