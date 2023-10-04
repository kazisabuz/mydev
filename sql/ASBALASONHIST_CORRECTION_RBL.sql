/* Formatted on 12/28/2022 3:29:27 PM (QP5 v5.388) */

--add all branch and batch
INSERT INTO ACTUAL_ACCOUNT_UPDATE (IACLINK_INTERNAL_ACNUM)
    SELECT TRAN_INTERNAL_ACNUM
      FROM TRAN2022
     WHERE     TRAN_ENTITY_NUM = 1
           AND TRAN_BRN_CODE = 927
           AND TRAN_DATE_OF_TRAN = '03-DEC-2022'
           AND TRAN_BATCH_NUMBER = 3
    UNION ALL
    SELECT TRAN_INTERNAL_ACNUM
      FROM TRAN2022
     WHERE     TRAN_ENTITY_NUM = 1
           AND TRAN_BRN_CODE = 0844
           AND TRAN_DATE_OF_TRAN = '03-DEC-2022'
           AND TRAN_BATCH_NUMBER = 1
               UNION ALL
    SELECT TRAN_INTERNAL_ACNUM
      FROM TRAN2022
     WHERE     TRAN_ENTITY_NUM = 1
           AND TRAN_BRN_CODE = 0851
           AND TRAN_DATE_OF_TRAN = '03-DEC-2022'
           AND TRAN_BATCH_NUMBER = 2
                          UNION ALL
    SELECT TRAN_INTERNAL_ACNUM
      FROM TRAN2022
     WHERE     TRAN_ENTITY_NUM = 1
           AND TRAN_BRN_CODE = 901
           AND TRAN_DATE_OF_TRAN = '03-DEC-2022'
           AND TRAN_BATCH_NUMBER = 5
                                     UNION ALL
    SELECT TRAN_INTERNAL_ACNUM
      FROM TRAN2022
     WHERE     TRAN_ENTITY_NUM = 1
           AND TRAN_BRN_CODE = 943
           AND TRAN_DATE_OF_TRAN = '03-DEC-2022'
           AND TRAN_BATCH_NUMBER = 2;
 
 


--make sure balance is zero
--DELETE ALL BRANCHES DATA
DELETE FROM
    ACBALASONHIST
      WHERE     ACBALH_ENTITY_NUM = 1
            AND ACBALH_INTERNAL_ACNUM IN
                    (SELECT TRAN_INTERNAL_ACNUM
                      FROM TRAN2022
                     WHERE     TRAN_ENTITY_NUM = 1
                           AND TRAN_BRN_CODE = 927
                           AND TRAN_DATE_OF_TRAN = '03-DEC-2022'
                           AND TRAN_BATCH_NUMBER = 3 --batch number
                           AND TRAN_INTERNAL_ACNUM NOT IN
                                   (SELECT TRAN_INTERNAL_ACNUM
                                     FROM TRAN2022
                                    WHERE     TRAN_ENTITY_NUM = 1
                                          AND TRAN_BRN_CODE = 927 ---tran branch
                                          AND TRAN_DATE_OF_TRAN =
                                              '03-DEC-2022'   ---tran_date
                                          AND TRAN_BATCH_NUMBER = 3
                                          AND TRAN_INTERNAL_ACNUM IN
                                                  (SELECT TRAN_INTERNAL_ACNUM
                                                    FROM TRAN2022
                                                   WHERE     TRAN_ENTITY_NUM =
                                                             1
                                                         AND TRAN_DATE_OF_TRAN =
                                                             '04-DEC-2022'))) --batch cancel date
            AND ACBALH_ASON_DATE = '04-DEC-2022' --batch cancel date;