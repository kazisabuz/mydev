/* Formatted on 3/16/2023 2:00:52 PM (QP5 v5.388) */
---BRANCH WISE --------------------   10106500003711,12316800004708,10106500005265  pc posted -10106500004452

SELECT t.*, GLBALANCE - NET_ACCRUAL
  FROM (SELECT DEPIA_BRN_CODE                                 branch_code,
               (SELECT mbrn_name
                  FROM mbrn
                 WHERE mbrn_code = DEPIA_BRN_CODE)            branch_name,
               IA_AMOUNT - (IP_AMOUNT + INT_TD_AMT)           NET_ACCRUAL,
               IA_AMOUNT,
               IP_AMOUNT,
               INT_TD_AMT,
               (SELECT GLBALH_BC_BAL
                 FROM glbalasonhist
                WHERE     GLBALH_ENTITY_NUM = 1
                      AND GLBALH_GLACC_CODE = '137101101'
                      AND GLBALH_BRN_CODE = DEPIA_BRN_CODE
                      AND GLBALH_ASON_DATE = :p_ason_date)    GLBALANCE
          FROM (  SELECT DEPIA_BRN_CODE,
                         SUM (
                             CASE
                                 WHEN DEPIA_ENTRY_TYPE = 'IA'
                                 THEN
                                     NVL (DEPIA_AC_INT_ACCR_AMT, 0)
                                 ELSE
                                     0
                             END)    IA_AMOUNT,
                         SUM (
                             CASE
                                 WHEN DEPIA_ENTRY_TYPE = 'IP'
                                 THEN
                                     NVL (DEPIA_AC_INT_ACCR_AMT, 0)
                                 ELSE
                                     0
                             END)    IP_AMOUNT,
                         SUM (
                             CASE
                                 WHEN DEPIA_ENTRY_TYPE IN ('PC', 'TD')
                                 THEN
                                     NVL (DEPIA_AC_INT_ACCR_AMT, 0)
                                 ELSE
                                     0
                             END)    INT_TD_AMT
                    FROM PBDCONTRACT,
                         DEPIA,
                         ACNTS,
                         DEPPROD
                   WHERE     PBDCONT_ENTITY_NUM = 1
                         AND DEPPR_PROD_CODE = PBDCONT_PROD_CODE
                         AND PBDCONT_CONT_NUM = DEPIA_CONTRACT_NUM
                         AND PBDCONT_PROD_CODE IN (1052, 1054, 1050)
                         AND ACNTS_BRN_CODE = :1
                         AND DEPIA_ACCR_POSTED_ON <= :p_ason_date        -----
                         AND ACNTS_INTERNAL_ACNUM = DEPIA_INTERNAL_ACNUM
                         AND DEPIA_INTERNAL_ACNUM = PBDCONT_DEP_AC_NUM
                         -- and DEPIA_INTERNAL_ACNUM=10106500001786
                         -- AND DEPPR_TYPE_OF_DEP = '1'    -----
                         AND ACNTS_ENTITY_NUM = PBDCONT_ENTITY_NUM
                         AND ACNTS_BRN_CODE = PBDCONT_BRN_CODE
                         AND ACNTS_INTERNAL_ACNUM = PBDCONT_DEP_AC_NUM
                         AND PBDCONT_EFF_DATE <= :p_ason_date             ----
                         AND (   PBDCONT_CLOSURE_DATE IS NULL
                              OR PBDCONT_CLOSURE_DATE >= :p_ason_date)
                GROUP BY DEPIA_BRN_CODE)) t;

------------------------account wise-----------------------

SELECT DEPIA_BRN_CODE                                 branch_code,
       DEPIA_INTERNAL_ACNUM,
       PBDCONT_CONT_NUM,
       (SELECT mbrn_name
          FROM mbrn
         WHERE mbrn_code = DEPIA_BRN_CODE)            branch_name,
       IA_AMOUNT - (IP_AMOUNT + INT_TD_AMT)           NET_ACCRUAL,
       IA_AMOUNT,
       IP_AMOUNT,
       INT_TD_AMT,
       (SELECT GLBALH_BC_BAL
         FROM glbalasonhist
        WHERE     GLBALH_ENTITY_NUM = 1
              AND GLBALH_GLACC_CODE = '137101101'
              AND GLBALH_BRN_CODE = DEPIA_BRN_CODE
              AND GLBALH_ASON_DATE = :p_ason_date)    GLBALANCE
  FROM (  SELECT DEPIA_BRN_CODE,
                 DEPIA_INTERNAL_ACNUM,
                 PBDCONT_CONT_NUM,
                 SUM (
                     CASE
                         WHEN DEPIA_ENTRY_TYPE = 'IA'
                         THEN
                             NVL (DEPIA_AC_INT_ACCR_AMT, 0)
                         ELSE
                             0
                     END)    IA_AMOUNT,
                 SUM (
                     CASE
                         WHEN DEPIA_ENTRY_TYPE = 'IP'
                         THEN
                             NVL (DEPIA_AC_INT_ACCR_AMT, 0)
                         ELSE
                             0
                     END)    IP_AMOUNT,
                 SUM (
                     CASE
                         WHEN DEPIA_ENTRY_TYPE IN ('PC', 'TD')
                         THEN
                             NVL (DEPIA_AC_INT_ACCR_AMT, 0)
                         ELSE
                             0
                     END)    INT_TD_AMT
            FROM PBDCONTRACT,
                 DEPIA,
                 ACNTS,
                 DEPPROD
           WHERE     PBDCONT_ENTITY_NUM = 1
                 AND DEPPR_PROD_CODE = PBDCONT_PROD_CODE
                 AND PBDCONT_CONT_NUM = DEPIA_CONTRACT_NUM
                 AND PBDCONT_BRN_CODE = :1
                 AND DEPIA_ACCR_POSTED_ON <= :p_ason_date
                 AND PBDCONT_PROD_CODE IN (1052, 1054, 1050)
                 AND ACNTS_INTERNAL_ACNUM = DEPIA_INTERNAL_ACNUM
                 AND DEPIA_INTERNAL_ACNUM = PBDCONT_DEP_AC_NUM
                 AND PBDCONT_DEP_AC_NUM = 15910500023904
                 --AND DEPPR_TYPE_OF_DEP = '1'
                 AND ACNTS_ENTITY_NUM = PBDCONT_ENTITY_NUM
                 AND ACNTS_BRN_CODE = PBDCONT_BRN_CODE
                 AND ACNTS_INTERNAL_ACNUM = PBDCONT_DEP_AC_NUM
                 AND PBDCONT_EFF_DATE <= :p_ason_date
                 AND (   PBDCONT_CLOSURE_DATE IS NULL
                      OR PBDCONT_CLOSURE_DATE >= :p_ason_date)
        GROUP BY DEPIA_BRN_CODE, DEPIA_INTERNAL_ACNUM, PBDCONT_CONT_NUM);


 ------------------mig date------------------------

SELECT DEPIA_BRN_CODE                                 branch_code,
       (SELECT mbrn_name
          FROM mbrn
         WHERE mbrn_code = DEPIA_BRN_CODE)            branch_name,
       MIG_END_DATE,
       FACNO (1, DEPIA_INTERNAL_ACNUM)                ACCOUNT_NO,
       PBDCONT_CONT_NUM,
       IA_AMOUNT - (IP_AMOUNT + INT_TD_AMT)           NET_ACCRUAL,
       IA_AMOUNT,
       IP_AMOUNT,
       INT_TD_AMT,
       (SELECT GLBALH_BC_BAL
         FROM glbalasonhist
        WHERE     GLBALH_ENTITY_NUM = 1
              AND GLBALH_GLACC_CODE = '137101101'
              AND GLBALH_BRN_CODE = DEPIA_BRN_CODE
              AND GLBALH_ASON_DATE = MIG_END_DATE)    GLBALANCE
  FROM (  SELECT DEPIA_BRN_CODE,
                 MIG_END_DATE,
                 DEPIA_INTERNAL_ACNUM,
                 PBDCONT_CONT_NUM,
                 SUM (
                     CASE
                         WHEN DEPIA_ENTRY_TYPE = 'IA'
                         THEN
                             NVL (DEPIA_AC_INT_ACCR_AMT, 0)
                         ELSE
                             0
                     END)    IA_AMOUNT,
                 SUM (
                     CASE
                         WHEN DEPIA_ENTRY_TYPE = 'IP'
                         THEN
                             NVL (DEPIA_AC_INT_ACCR_AMT, 0)
                         ELSE
                             0
                     END)    IP_AMOUNT,
                 SUM (
                     CASE
                         WHEN DEPIA_ENTRY_TYPE IN ('PC', 'TD')
                         THEN
                             NVL (DEPIA_AC_INT_ACCR_AMT, 0)
                         ELSE
                             0
                     END)    INT_TD_AMT
            FROM PBDCONTRACT,
                 DEPIA,
                 ACNTS,
                 DEPPROD,
                 mig_detail
           WHERE     PBDCONT_ENTITY_NUM = 1
                 AND DEPPR_PROD_CODE = PBDCONT_PROD_CODE
                 AND PBDCONT_CONT_NUM = DEPIA_CONTRACT_NUM
                 AND PBDCONT_BRN_CODE = branch_code
                 AND DEPIA_ACCR_POSTED_ON <= MIG_END_DATE
                 AND PBDCONT_PROD_CODE IN (1052, 1054, 1050)
                 AND ACNTS_INTERNAL_ACNUM = DEPIA_INTERNAL_ACNUM
                 AND DEPIA_INTERNAL_ACNUM = PBDCONT_DEP_AC_NUM
                 -- AND PBDCONT_DEP_AC_NUM=15910500023904
                 --AND DEPPR_TYPE_OF_DEP = '1'
                 AND ACNTS_ENTITY_NUM = PBDCONT_ENTITY_NUM
                 AND ACNTS_BRN_CODE = PBDCONT_BRN_CODE
                 AND ACNTS_INTERNAL_ACNUM = PBDCONT_DEP_AC_NUM
                 AND PBDCONT_EFF_DATE <= MIG_END_DATE
                 AND (   PBDCONT_CLOSURE_DATE IS NULL
                      OR PBDCONT_CLOSURE_DATE >= MIG_END_DATE)
        GROUP BY DEPIA_BRN_CODE,
                 DEPIA_INTERNAL_ACNUM,
                 PBDCONT_CONT_NUM,
                 MIG_END_DATE)
 WHERE IA_AMOUNT - (IP_AMOUNT + INT_TD_AMT) <> 0;

--FDR--------

  SELECT /*+ PARALLEL(16) */
         PBDCONT_ACTUAL_INT_RATE,
         SUM (FN_GET_ASON_ACBAL (1,
                                 DEPIA_INTERNAL_ACNUM,
                                 'BDT',
                                 '31-MAY-2022',
                                 '31-MAY-2022'))    ACCOUNT_BAL,
         SUM (
             CASE
                 WHEN DEPIA_ENTRY_TYPE = 'IA' THEN DEPIA_BC_INT_ACCR_AMT
                 ELSE 0
             END)                                   IA_AMOUNT,
         SUM (
             CASE
                 WHEN DEPIA_ENTRY_TYPE = 'IP' THEN DEPIA_BC_INT_ACCR_AMT
                 ELSE 0
             END)                                   IP_AMOUNT
    FROM pbdcontract, depia, acnts
   WHERE     PBDCONT_PROD_CODE = 1050
         -- AND PDBCONT_DEP_PRD_MONTHS < 6
         AND PBDCONT_CONT_NUM = DEPIA_CONTRACT_NUM
         AND ACNTS_INTERNAL_ACNUM = DEPIA_INTERNAL_ACNUM
         AND ACNTS_INTERNAL_ACNUM = PBDCONT_DEP_AC_NUM
         AND PBDCONT_CONT_NUM <> 0
         AND PBDCONT_DEP_AC_NUM = DEPIA_INTERNAL_ACNUM
         AND DEPIA_DATE_OF_ENTRY BETWEEN '01-jan-2022' AND '30-APR-2022'
         --  AND DEPIA_ENTRY_TYPE = 'IP'
         -- AND DEPIA_INT_ACCR_DB_CR = 'D'
         AND ACNTS_AC_TYPE = 'FDR'
         AND PBDCONT_ENTITY_NUM = 1
         -- AND PBDCONT_ACTUAL_INT_RATE = 5.6
         AND DEPIA_ENTITY_NUM = 1
         AND DEPIA_BRN_CODE = PBDCONT_BRN_CODE
GROUP BY PBDCONT_ACTUAL_INT_RATE;

-----SND-----------

  SELECT (PRODIRS_UPTO_AMOUNT) SLAB, SUM (CR_AMOUNT) IA_AMOUNT
    FROM (SELECT /*+ PARALLEL(16) */
                 ACNTS_INTERNAL_ACNUM,
                 SBCAIA_INT_RATE,
                 PRODIRS_INT_RATE,
                 PRODIRS_UPTO_AMOUNT,
                 SBCAIA_AC_INT_ACCR_AMT,
                 SBCAIA_DATE_OF_ENTRY,
                 CASE
                     WHEN SBCAIA_INT_ACCR_DB_CR = 'C'
                     THEN
                         SBCAIA_BC_INT_ACTUAL_ACCR_AMT
                     ELSE
                         0
                 END    CR_AMOUNT
            FROM PRODIRSLAB,
                 acnts,
                 SBCAia,
                 mbrn
           WHERE     ACNTS_ENTITY_NUM = 1
                 AND ACNTS_INTERNAL_ACNUM = SBCAia_INTERNAL_ACNUM
                 --AND ACNTS_BRN_CODE = 26
                 AND SBCAIA_BRN_CODE = ACNTS_BRN_CODE
                 AND ACNTS_PROD_CODE = 1030
                 AND PRODIRS_BRANCH_CAT = MBRN_CATEGORY
                 AND ACNTS_BRN_CODE = mbrn_code
                 -- AND ACNTS_INTERNAL_ACNUM = 10002600035484
                 AND SBCAia_ENTITY_NUM = 1
                 AND PRODIRS_PROD_CODE = ACNTS_PROD_CODE
                 AND NVL (TRIM (PRODIRS_AC_TYPE), '#') = ACNTS_AC_TYPE
                 AND SBCAIA_AC_INT_ACCR_AMT <> 0
                 AND SBCAIA_DATE_OF_ENTRY BETWEEN '01-jan-2022'
                                              AND '30-APR-2022'
                 AND NVL (SBCAIA_INT_RATE, 0) = NVL (PRODIRS_INT_RATE, 0))
GROUP BY PRODIRS_UPTO_AMOUNT;

--------------------DEPIA ACC WISE----------------------

SELECT MIG_AMT.DEPIA_BRN_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_CODE = MIG_AMT.DEPIA_BRN_CODE)                   MBRN_NAME,
       (SELECT MIG_END_DATE
          FROM MIG_DETAIL
         WHERE BRANCH_CODE = MIG_AMT.DEPIA_BRN_CODE)                 MIG_END_DATE,
       MIG_AMT.DEPIA_INTERNAL_ACNUM,
       NVL (MIG_AMT.IA_AMT, 0)                                       IA_AMT,
       NVL (MIG_AMT.IP_AMT, 0)                                       IP_AMT,
       NVL ((MIG_AMT.IA_AMT - MIG_AMT.IP_AMT), 0)                    MIG_REMAINING_IA,
       NVL (AFTER_MIG.AFTER_IA_AMT, 0)                               AFTER_IA_AMT,
       NVL (AFTER_MIG.AFTER_IP_AMT, 0)                               AFTER_IP_AMT,
       NVL ((AFTER_MIG.AFTER_IA_AMT - AFTER_MIG.AFTER_IP_AMT), 0)    AFTER_REMAINING_IA
  FROM (  SELECT DEPIA_BRN_CODE,
                 DEPIA_INTERNAL_ACNUM,
                 SUM (
                     CASE
                         WHEN DEPIA_ENTRY_TYPE = 'IA'
                         THEN
                             DEPIA_AC_INT_ACCR_AMT
                         ELSE
                             0
                     END)    IA_AMT,
                 SUM (
                     CASE
                         WHEN DEPIA_ENTRY_TYPE = 'IP'
                         THEN
                             DEPIA_AC_INT_ACCR_AMT
                         ELSE
                             0
                     END)    IP_AMT
            FROM ACC4, DEPIA
           WHERE     ACC4.ACC_NO = DEPIA_BRN_CODE
                 AND DEPIA_ENTITY_NUM = 1
                 AND DEPIA_ACCR_POSTED_BY = 'MIG'
                 AND DEPIA_ENTRY_TYPE IN ('IA', 'IP')
        -- AND DEPIA_BRN_CODE = 45054
        GROUP BY DEPIA_BRN_CODE, DEPIA_INTERNAL_ACNUM) MIG_AMT
       RIGHT OUTER JOIN
       (  SELECT DEPIA_BRN_CODE,
                 DEPIA_INTERNAL_ACNUM,
                 SUM (
                     CASE
                         WHEN DEPIA_ENTRY_TYPE = 'IA'
                         THEN
                             DEPIA_AC_INT_ACCR_AMT
                         ELSE
                             0
                     END)    AFTER_IA_AMT,
                 SUM (
                     CASE
                         WHEN DEPIA_ENTRY_TYPE = 'IP'
                         THEN
                             DEPIA_AC_INT_ACCR_AMT
                         ELSE
                             0
                     END)    AFTER_IP_AMT
            FROM ACC4, DEPIA
           WHERE     ACC4.ACC_NO = DEPIA_BRN_CODE
                 AND DEPIA_ENTITY_NUM = 1
                 AND DEPIA_ENTRY_TYPE IN ('IA', 'IP')
                 --AND DEPIA_BRN_CODE = 45054
                 AND DEPIA_DATE_OF_ENTRY <= (SELECT LAST_DAY (MIG_END_DATE + 1)
                                               FROM MIG_DETAIL
                                              WHERE BRANCH_CODE = ACC4.ACC_NO)
        GROUP BY DEPIA_BRN_CODE, DEPIA_INTERNAL_ACNUM) AFTER_MIG
           ON (MIG_AMT.DEPIA_INTERNAL_ACNUM = AFTER_MIG.DEPIA_INTERNAL_ACNUM);

------------------------------BRANCH WISE----------------------------------------

SELECT MIG_AMT.DEPIA_BRN_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_CODE = MIG_AMT.DEPIA_BRN_CODE)                   MBRN_NAME,
       (SELECT MIG_END_DATE
          FROM MIG_DETAIL
         WHERE BRANCH_CODE = MIG_AMT.DEPIA_BRN_CODE)                 MIG_END_DATE,
       NVL (MIG_AMT.IA_AMT, 0)                                       IA_AMT,
       NVL (MIG_AMT.IP_AMT, 0)                                       IP_AMT,
       NVL ((MIG_AMT.IA_AMT - MIG_AMT.IP_AMT), 0)                    MIG_REMAINING_IA,
       NVL (AFTER_MIG.AFTER_IA_AMT, 0)                               AFTER_IA_AMT,
       NVL (AFTER_MIG.AFTER_IP_AMT, 0)                               AFTER_IP_AMT,
       NVL ((AFTER_MIG.AFTER_IA_AMT - AFTER_MIG.AFTER_IP_AMT), 0)    AFTER_REMAINING_IA
  FROM (  SELECT DEPIA_BRN_CODE,
                 SUM (
                     CASE
                         WHEN DEPIA_ENTRY_TYPE = 'IA'
                         THEN
                             DEPIA_AC_INT_ACCR_AMT
                         ELSE
                             0
                     END)    IA_AMT,
                 SUM (
                     CASE
                         WHEN DEPIA_ENTRY_TYPE = 'IP'
                         THEN
                             DEPIA_AC_INT_ACCR_AMT
                         ELSE
                             0
                     END)    IP_AMT
            FROM ACC4, DEPIA
           WHERE     ACC4.ACC_NO = DEPIA_BRN_CODE
                 AND DEPIA_ENTITY_NUM = 1
                 AND DEPIA_ACCR_POSTED_BY = 'MIG'
                 AND DEPIA_ENTRY_TYPE IN ('IA', 'IP')
        -- AND DEPIA_BRN_CODE = 45054
        GROUP BY DEPIA_BRN_CODE) MIG_AMT
       RIGHT OUTER JOIN
       (  SELECT DEPIA_BRN_CODE,
                 SUM (
                     CASE
                         WHEN DEPIA_ENTRY_TYPE = 'IA'
                         THEN
                             DEPIA_AC_INT_ACCR_AMT
                         ELSE
                             0
                     END)    AFTER_IA_AMT,
                 SUM (
                     CASE
                         WHEN DEPIA_ENTRY_TYPE = 'IP'
                         THEN
                             DEPIA_AC_INT_ACCR_AMT
                         ELSE
                             0
                     END)    AFTER_IP_AMT
            FROM ACC4, DEPIA
           WHERE     ACC4.ACC_NO = DEPIA_BRN_CODE
                 AND DEPIA_ENTITY_NUM = 1
                 AND DEPIA_ENTRY_TYPE IN ('IA', 'IP')
                 --AND DEPIA_BRN_CODE = 45054
                 AND DEPIA_DATE_OF_ENTRY <= (SELECT LAST_DAY (MIG_END_DATE + 1)
                                               FROM MIG_DETAIL
                                              WHERE BRANCH_CODE = ACC4.ACC_NO)
        GROUP BY DEPIA_BRN_CODE) AFTER_MIG
           ON (MIG_AMT.DEPIA_BRN_CODE = AFTER_MIG.DEPIA_BRN_CODE);



 -----------------------------

SELECT DEPIA_BRN_CODE, DEPIA_ACCR_POSTED_ON, DEPIA_AC_INT_ACCR_AMT
  FROM depia, pbdcontract
 WHERE     DEPIA_ENTITY_NUM = 1
       AND PBDCONT_CONT_NUM = DEPIA_CONTRACT_NUM
       AND DEPIA_INTERNAL_ACNUM = PBDCONT_DEP_AC_NUM
       AND DEPIA_BRN_CODE = 1065
       AND PBDCONT_BRN_CODE = DEPIA_BRN_CODE
       AND PBDCONT_ENTITY_NUM = 1
       AND PBDCONT_PROD_CODE IN (1052, 1054, 1050)
       AND DEPIA_ENTRY_TYPE = 'PC'
       AND DEPIA_ACCR_POSTED_ON BETWEEN :P_FROM_DATE AND :P_ASON_DATE
       AND (DEPIA_BRN_CODE, DEPIA_ACCR_POSTED_ON, DEPIA_AC_INT_ACCR_AMT) NOT IN
               (SELECT TRAN_BRN_CODE, TRAN_DATE_OF_TRAN, TRAN_AMOUNT
                 FROM tran2022
                WHERE     TRAN_ENTITY_NUM = 1
                      AND TRAN_GLACC_CODE = '137101101'
                      AND TRAN_AUTH_BY IS NOT NULL
                      AND TRAN_AMOUNT <> 0);


 -----------------------DBS

SELECT *
  FROM DEPIA@DR
 WHERE DEPIA_ENTITY_NUM = 1 --AND DEPIA_BRN_CODE = 51011
                            --AND DEPIA_DATE_OF_ENTRY = TO_DATE('9/30/2015', 'MM/DD/YYYY')
                            --AND DEPIA_INTERNAL_ACNUM in ( 10106500005332,10106500005377)
                            --AND DEPIA_DATE_OF_ENTRY = TO_DATE('7/13/2022', 'MM/DD/YYYY')
                            --AND DEPIA_INTERNAL_ACNUM = 10106500005265----
                            --AND DEPIA_ENTRY_TYPE = 'PC'
                            --AND DEPIA_ACCR_POSTED_ON = TO_DATE('5/31/2018', 'MM/DD/YYYY')
                            -- AND DEPIA_INTERNAL_ACNUM = 15101100020852
                            --AND DEPIA_ENTRY_TYPE = 'PC'
                            AND DEPIA_SOURCE_TABLE = 'TDSPIDTL';