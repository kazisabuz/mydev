/*Sometimes there are some situations where we need to take backup from the live production to 
prepare UAT for running Monthend. But if there are some unathorized balance present in the 
production, the same data will come to the UAT as well. So, we need to clear the 
unautorized transactions from UAT. We can execute the below script and clear the UAT server 
for doing the test of "End of Day(EoD)"*/

delete from tran2016 where TRAN_AUTH_BY is null and TRAN_DATE_OF_TRAN = '30-OCT-2016'
AND TRAN_ENTITY_NUM = 1; 

UPDATE CASHCTL SET
CASHCTL_STATUS = 'C',
CASHCTL_CLOSING_INIT_BY =  CASHCTL_OPENED_BY,
CASHCTL_CLOSING_INT_ON = SYSDATE , 
CASHCTL_CLOSED_BY = CASHCTL_OPENED_BY, 
CASHCTL_CLOSED_ON= SYSDATE 
 WHERE CASHCTL_DATE = '30-OCT-2016'; 
 
 
UPDATE BRNSTATUS
   SET BRNSTATUS_SIGN_OUT = SYSDATE,
       BRNSTATUS_SIGNOUT_USER_ID = BRNSTATUS_SIGNIN_USER_ID,
       BRNSTATUS_STATUS = 'O'
 WHERE BRNSTATUS_CURR_DATE = '30-OCT-2016';

UPDATE acntbal SET
ACNTBAL_AC_UNAUTH_CR_SUM = 0, 
ACNTBAL_AC_UNAUTH_DB_SUM = 0, 
ACNTBAL_BC_UNAUTH_CR_SUM = 0, 
ACNTBAL_BC_UNAUTH_DB_SUM = 0 ;

UPDATE acntcbal SET 
ACNTCBAL_AC_UNAUTH_CR_SUM = 0, 
ACNTCBAL_AC_UNAUTH_DB_SUM = 0, 
ACNTCBAL_BC_UNAUTH_CR_SUM = 0, 
ACNTCBAL_BC_UNAUTH_DB_SUM = 0;


UPDATE glbbal SET 
GLBBAL_AC_UNAUTH_CR_SUM = 0, 
GLBBAL_AC_UNAUTH_DB_SUM = 0, 
GLBBAL_BC_UNAUTH_CR_SUM = 0, 
GLBBAL_BC_UNAUTH_DB_SUM  = 0 ;


DELETE FROM  ctran2016
WHERE CT_AUTH_BY IS NULL 
AND CT_REJ_BY IS NULL 
AND CT_TRAN_DATE = '30-may-2016';