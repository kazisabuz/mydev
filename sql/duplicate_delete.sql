/* Formatted on 6/5/2022 2:45:23 PM (QP5 v5.252.13127.32867) */
DELETE FROM INWARD_CLEARING_ITEM
      WHERE     ROWID NOT IN (  SELECT MIN (ROWID)
                                  FROM INWARD_CLEARING_ITEM
                                 WHERE     BRANCH_CODE = 01164
                                       AND CHEQUE_DATE =
                                              TO_DATE ('04/26/2022 00:00:00',
                                                       'MM/DD/YYYY HH24:MI:SS')
                                       AND CLEARING_BATCH_NUMBER = 22
                              GROUP BY CHEQUE_DATE,
                                       LEAF_NUMBER,
                                       AMOUNT,
                                       BRANCH_CODE)
            AND BRANCH_CODE = 01164
            AND CLEARING_BATCH_NUMBER = 22
            AND CHEQUE_DATE =
                   TO_DATE ('04/26/2022 00:00:00', 'MM/DD/YYYY HH24:MI:SS');



  SELECT MIN (ROWID)
    FROM HOVERING
   WHERE HOVERING_ENTITY_NUM = 1 AND HOVERING_YEAR = 2021
GROUP BY HOVERING_RECOVERY_FROM_ACNT, HOVERING_YEAR
  HAVING COUNT (*) > 1;


DELETE FROM HOVERING
      WHERE ROWID NOT IN     (  SELECT MIN (ROWID)
                                   FROM HOVERING
                                  WHERE     HOVERING_ENTITY_NUM = 1
                                        AND HOVERING_YEAR = 2020
                               GROUP BY HOVERING_RECOVERY_FROM_ACNT,
                                        HOVERING_YEAR)
                          AND HOVERING_ENTITY_NUM = 1
                          AND HOVERING_YEAR = 2020;


DELETE FROM ACNTEXCISEAMT_2020
      WHERE ROWID NOT IN (  SELECT MIN (ROWID)
                              FROM ACNTEXCISEAMT_2020
                          GROUP BY ACNTEXCAMT_INTERNAL_ACNUM)