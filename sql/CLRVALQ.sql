/* Formatted on 9/1/2022 2:57:07 AM (QP5 v5.388) */
INSERT INTO CLRVALQ_BKP
    SELECT *
      FROM CLRVALQ
     WHERE     CLRVALQ_ENTITY_NUM = 1
           AND CLRVALQ_TRAN_DATE = TO_DATE ('8/31/2022', 'MM/DD/YYYY')
           AND CLRVALQ_BRANCH_CODE = 1206