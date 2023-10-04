SELECT COUNT(BRNSTATUS_BRN_CODE) BRANCH_OPEN,
      1400 - COUNT(BRNSTATUS_BRN_CODE) SIGN_OUT,
      COUNT(CLOSED_ON) CASH_CLOSED
 FROM (SELECT BRNSTATUS_BRN_CODE,
              DECODE(BRNSTATUS_STATUS,
                     'I', 
                     'Open',
                     'O',
                     'Close',
                     'Not Sign-in'),
              DECODE(CASHCTL_STATUS, 'C', 'Close', 'O', 'Open') CASH_STATUS,  --MEC201900821120
              TO_CHAR(CASHCTL_CLOSED_ON, 'HH:MI:SS') CLOSED_ON
         FROM BRNSTATUS B, CASHCTL C,MBRN B
        WHERE BRNSTATUS_ENTITY_NUM = CASHCTL_ENTITY_NUM(+)
          AND BRNSTATUS_BRN_CODE = CASHCTL_BRN_CODE(+)
          AND BRNSTATUS_CURR_DATE = CASHCTL_DATE(+)
          AND BRNSTATUS_BRN_CODE = MBRN_CODE
          AND BRNSTATUS_CURR_DATE = trunc(SYSDATE)
          AND BRNSTATUS_BRN_CODE <> 18
          AND BRNSTATUS_STATUS = 'I');
          
          
          EALWBRNSIGOUT
          
 -----------------
 select mbrn.*
from BRNSTATUS,mbrn
where BRNSTATUS_BRN_CODE=mbrn_code
and BRNSTATUS_STATUS='I'
and trunc(BRNSTATUS_SIGN_IN)='30-apr-2022';