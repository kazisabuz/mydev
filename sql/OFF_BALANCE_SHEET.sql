/* Formatted on 7/13/2023 11:08:44 AM (QP5 v5.388) */
BEGIN
    FOR IDX IN (SELECT *
                  FROM MBRN
                 WHERE MBRN_CODE IN (SELECT BRANCH
                                       FROM MBRN_TREE, MBRN
                                      WHERE     BRANCH = MBRN_CODE
                                            AND GMO_BRANCH IN (50995,
                                                               18994,
                                                               46995,
                                                               6999,
                                                               56993)))
    LOOP
        INSERT INTO CL_TMP_DATA_BAK
            SELECT T.*, IDX.MBRN_CODE
              FROM (SELECT *
                      FROM TABLE (
                               PKG_CLREPORT.CL_RPT (1,
                                                    '31-MAR-2023',
                                                    IDX.MBRN_CODE))) T;
    END LOOP;

    COMMIT;
END;

SELECT BRANCH_CODE,
       RPT_DESCN,
         (NVL (TOT_BAL_OUT, 0))
       - (SELECT NVL (RPT_HEAD_BAL, 0)
           FROM STATMENTOFAFFAIRS
          WHERE     RPT_BRN_CODE = BRANCH_CODE
                AND CASHTYPE = '1'
                AND RPT_ENTRY_DATE = '30-JUN-2023'
                AND RPT_HEAD_CODE = 'A0703')    bal
  FROM CL_TMP_DATA_BAK@DR
 WHERE RPT_DESCN = 'Off-Balance Sheet Exposure';


  SELECT RPT_BRN_CODE                    BRANCH_CODE,
         RPT_HEAD_CODE,
         RPT_HEAD_DESCN                  RPT_DESCN,
         SUM (NVL (RPT_HEAD_BAL, 0))     BALANCE
    FROM STATMENTOFAFFAIRS@dr, MBRN@dr
   WHERE     RPT_ENTRY_DATE = '30-JUN-2023'
         AND CASHTYPE = '1'
         AND RPT_HEAD_CODE IN ('A0601',
                               'A0602',
                               'A0604',
                               'A0604',
                               'A0701',
                               'A0702',
                               'A0704')
         AND RPT_BRN_CODE = MBRN_CODE
         AND RPT_BRN_CODE IN (SELECT BRANCH
                                FROM MBRN_TREE@dr, MBRN@dr
                               WHERE     BRANCH = MBRN_CODE
                                     AND GMO_BRANCH IN (50995,
                                                        18994,
                                                        46995,
                                                        6999,
                                                        56993))
         AND RPT_HEAD_BAL <> 0
GROUP BY RPT_BRN_CODE, RPT_HEAD_CODE, RPT_HEAD_DESCN
ORDER BY RPT_BRN_CODE ASC, RPT_BRN_CODE ASC;