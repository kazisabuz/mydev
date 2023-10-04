---CLEARING BATCH OPEN/CLOSE

--------INWORD-------------------------------------------------------------------
 EDIT ICLGBATCH   WHERE ICLGBAT_BRN_CODE=44354 AND ICLGBAT_CLG_DATE =TRUNC(SYSDATE);
 --------OUTWORD-------------------------------
 EDIT  OCLGBATCH WHERE OCLGBAT_BRN_CODE=44354      AND OCLGBAT_CLG_DATE =TRUNC(SYSDATE); 
 ---------------------------------------------------------------------------------------
 

--OUTWARD_CLEARING_DOUBLE_UPLOADING  delete record both table 
edit OCLGDEP OP WHERE     OP.OCLGDEP_BRN_CODE IN ('1115')      AND OP.OCLGDEP_CLG_DATE = TRUNC(SYSDATE);


EDIT OCLGINST OT
 WHERE     OT.OCLGINST_BRN_CODE IN ('1115')
       AND OT.OCLGINST_CLG_DATE = TRUNC(SYSDATE)
       --AND OT.OCLGINST_VOUCHER_NUM = 25
       AND OT.OCLGINST_CLG_BATCH = 9;
	   
-----Unauthorized return transaction present. Can not proceed..delete  Unauthorized batch
SELECT * FROM OCLGRTN OCC WHERE OCC.OCLGRTN_BRN_CODE=1115 AND OCC.OCLGRTN_CLG_DATE=sysdate;



----------------inward duplicate delete ---------------------
/* Formatted on 09/15/2020 4:50:51 PM (QP5 v5.227.12220.39754) */
delete FROM INWARD_CLEARING_ITEM
      WHERE     ROWID NOT IN
                   (  SELECT MIN (ROWID)
                        FROM INWARD_CLEARING_ITEM
                       WHERE     BRANCH_CODE = 36137
                             AND TRUNC(CHEQUE_DATE) ='28-MAR-2023'
                             AND CLEARING_BATCH_NUMBER = 11
                             AND TRANSACTION_BATCH_NUMBER =0
                    GROUP BY CHEQUE_DATE,
                             LEAF_NUMBER,
                             AMOUNT,
                             BRANCH_CODE)
            AND BRANCH_CODE = 36137
            AND    TRUNC(CHEQUE_DATE) ='28-MAR-2023' and CLEARING_BATCH_NUMBER=11;
                  