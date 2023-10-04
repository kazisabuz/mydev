/* Formatted on 3/28/2021 8:00:53 PM (QP5 v5.252.13127.32867) */
/*----------------------------------*
 *  Dr 140143245
   CR 140107101
---------------------------------------------
140143127 
140145125
  Account level Suspense Ledger update (C)*
*/      ---------------------------------*
INSERT INTO AUTOPOST_TRAN_TEMP
   SELECT /*+ PARALLEL( 16) */
         1 BATCH_SL,
          1 LEG_SL,
          NULL TRAN_DATE,
          NULL VALUE_DATE,
          1 SUPP_TRAN,
          BRANCH_CODE BRN_CODE,
          BRANCH_CODE ACING_BRN_CODE,
          'C' DR_CR,
          '140107101' GLACC_CODE,
          NULL INT_AC_NO,
          NULL CONT_NO,
          'BDT' CURR_CODE,
          ABS (WAIVE_AMT) AC_AMOUNT,
          'Suspense Reversal for April and May,2020 For Covid-19 ' || ACCOUNT_NUMBER  NARRATION

             FROM backuptable.COVID19_BATCH
            WHERE     nvl(CURR_SUSPBAL,0)<>0
            AND nvl(ACCOUNT_STATUS,'#') ='Open'
            and CL_STATUS='N'
            union all
 SELECT /*+ PARALLEL( 16) */
         1 BATCH_SL,
          1 LEG_SL,
          null TRAN_DATE,
          NULL VALUE_DATE,
          1 SUPP_TRAN,
          BRANCH_CODE BRN_CODE,
          BRANCH_CODE ACING_BRN_CODE,
          'D' DR_CR,
          LNPRDAC_INT_INCOME_GL GLACC_CODE,
          NULL INT_AC_NO,
          NULL CONT_NO,
          'BDT' CURR_CODE,
          ABS (WAIVE_AMT) AC_AMOUNT,
          'Suspense Reversal for April and May,2020 For Covid-19 ' || ACCOUNT_NUMBER  NARRATION

             FROM backuptable.COVID19_BATCH,IACLINK,LNPRODACPM
             WHERE     nvl(CURR_SUSPBAL,0)<>0
            AND nvl(ACCOUNT_STATUS,'#') ='Open'
            and CL_STATUS='N'
            AND ACCOUNT_NUMBER =IACLINK_ACTUAL_ACNUM
            AND  IACLINK_PROD_CODE=LNPRDAC_PROD_CODE ;

---------------
INSERT INTO AUTOPOST_TRAN
   SELECT DENSE_RANK () OVER (ORDER BY BRN_CODE) BATCH_SL,
          ROW_NUMBER () OVER (PARTITION BY BRN_CODE ORDER BY BRN_CODE) LEG_SL,
          '31-MAR-2021' TRAN_DATE,
          '31-MAR-2021' VALUE_DATE,
          1 SUPP_TRAN,
          BRN_CODE,
          ACING_BRN_CODE,
          DR_CR,
          GLACC_CODE,
          INT_AC_NO,
          CONT_NO,
          CURR_CODE,
          AC_AMOUNT,
          AC_AMOUNT BC_AMOUNT,
          NULL PRINCIPAL,
          NULL INTEREST,
          NULL CHARGE,
          NULL INST_PREFIX,
          NULL INST_NUM,
          NULL INST_DATE,
          NULL IBR_GL,
          NULL ORIG_RESP,
          NULL CONT_BRN_CODE,
          NULL ADV_NUM,
          NULL ADV_DATE,
          NULL IBR_CODE,
          NULL CAN_IBR_CODE,
          NARRATION LEG_NARRATION,
          NARRATION BATCH_NARRATION,
          'INTELECT' USER_ID,
          NULL TERMINAL_ID,
          NULL PROCESSED,
          NULL BATCH_NO,
          NULL ERR_MSG,
          NULL DEPT_CODE
     FROM AUTOPOST_TRAN_TEMP TT;

-----------------------------------------------------


/* Formatted on 4/1/2021 12:08:39 AM (QP5 v5.252.13127.32867) */
INSERT INTO LNSUSPLED
   SELECT 1 LNSUSP_ENTITY_NUM,
          IACLINK_INTERNAL_ACNUM LNSUSP_ACNT_NUM,
          '31-MAR-2021' LNSUSP_TRAN_DATE,
          ROWNUM LNSUSP_SL_NUM,
          '31-MAR-2021' LNSUSP_VALUE_DATE,
          2 LNSUSP_ENTRY_TYPE,
          'C' LNSUSP_DB_CR_FLG,
          'BDT' LNSUSP_CURR_CODE,
          WAIVE_AMT LNSUSP_AMOUNT,
          WAIVE_AMT LNSUSP_INT_AMT,
          0 LNSUSP_CHGS_AMT,
          '31-DEC-2020' LNSUSP_INT_FROM_DATE,
          '31-DEC-2020' LNSUSP_INT_UPTO_DATE,
          'Suspense Reversal for April' LNSUSP_REMARKS1,
          ' and May, 2020 ' LNSUSP_REMARKS2,
          ' For Covid-19 ' LNSUSP_REMARKS3,
          'A' LNSUSP_AUTO_MANUAL,
          NULL LNSUSP_RECOV_THRU,
          NULL LNSUSP_SRC_REF_KEY,
          'INTELECT' LNSUSP_ENTD_BY,
          SYSDATE LNSUSP_ENTD_ON,
          'INTELECT' LNSUSP_LAST_MOD_BY,
          SYSDATE LNSUSP_LAST_MOD_ON,
          'INTELECT' LNSUSP_AUTH_BY,
          SYSDATE LNSUSP_AUTH_ON,
          NULL TBA_MAIN_KEY
     FROM backuptable.COVID19_BATCH, iaclink
    WHERE     NVL (CURR_SUSPBAL, 0) <> 0
          AND NVL (ACCOUNT_STATUS, '#') = 'Open'
          and CL_STATUS='N'
          AND ACCOUNT_NUMBER = IACLINK_ACTUAL_ACNUM
          AND IACLINK_ENTITY_NUM = 1;

 -----------------------------------------------
/* Formatted on 3/31/2021 6:27:19 PM (QP5 v5.252.13127.32867) */
/* Formatted on 4/1/2021 12:08:18 AM (QP5 v5.252.13127.32867) */
BEGIN
   FOR IDX
      IN (  SELECT LNSUSP_ACNT_NUM,
                   SUM (CREDIT_BAL) - SUM (DEBIT_BAL) SUSP_BAL,
                   SUM (CREDIT_BAL) CREDIT_SUM,
                   SUM (DEBIT_BAL) DEBIT_SUM
              FROM (SELECT LNSUSP_ACNT_NUM,
                           CASE
                              WHEN LNSUSP_DB_CR_FLG = 'C' THEN LNSUSP_AMOUNT
                              ELSE 0
                           END
                              CREDIT_BAL,
                           CASE
                              WHEN LNSUSP_DB_CR_FLG = 'D' THEN LNSUSP_AMOUNT
                              ELSE 0
                           END
                              DEBIT_BAL
                      FROM LNSUSPLED
                     WHERE     LNSUSP_ENTITY_NUM = 1
                           AND LNSUSP_ACNT_NUM IN (SELECT IACLINK_INTERNAL_ACNUM
                                                     FROM backuptable.COVID19_BATCH,
                                                          iaclink
                                                    WHERE     NVL (
                                                                 CURR_SUSPBAL,
                                                                 0) <> 0
                                                          AND NVL (
                                                                 ACCOUNT_STATUS,
                                                                 '#') = 'Open'
                                                                 and CL_STATUS='N'
                                                          AND ACCOUNT_NUMBER =
                                                                 IACLINK_ACTUAL_ACNUM
                                                          AND IACLINK_ENTITY_NUM =
                                                                 1))
          GROUP BY LNSUSP_ACNT_NUM
          ORDER BY LNSUSP_ACNT_NUM)
   LOOP
      UPDATE LNSUSPBAL
         SET LNSUSPBAL_SUSP_BAL = IDX.SUSP_BAL,
             LNSUSPBAL_SUSP_DB_SUM = IDX.DEBIT_SUM,
             LNSUSPBAL_SUSP_CR_SUM = IDX.CREDIT_SUM,
             LNSUSPBAL_INT_BAL = IDX.SUSP_BAL
       WHERE     LNSUSPBAL_ENTITY_NUM = 1
             AND LNSUSPBAL_ACNT_NUM = IDX.LNSUSP_ACNT_NUM;
   END LOOP;
END;



-----------------------------------------------------------------------------

create table  backuptable.COVID19_BATCH as 
SELECT *
  FROM (SELECT /*+ PARALLEL( 16) */
              BT.PARENT_BRANCH HEAD_OFFICE_CODE,
               (SELECT MBRN_NAME
                  FROM MBRN
                 WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = PARENT_BRANCH)
                  HEAD_OFFICE_NAME,
               BT.GMO_BRANCH GMO_CODE,
               (SELECT MBRN_NAME
                  FROM MBRN
                 WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = GMO_BRANCH)
                  GMO_NAME,
               BT.PO_BRANCH PO_RO_CODE,
               (SELECT MBRN_NAME
                  FROM MBRN
                 WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = PO_BRANCH)
                  PO_RO_NAME,
               ACBLK_BRN_CODE BRANCH_CODE,
               (SELECT MBRN_NAME
                  FROM MBRN
                 WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = ACBLK_BRN_CODE)
                  BRANCH_NAME,
               ACC_NO ACCOUNT_NUMBER,
               ACNTS_AC_NAME1 ACCOUNT_NAME,
               ACBLK_OS_BAL_31MAR OS_BAL_ON_31_03_2020,
               ACBLK_AMT_TRF_BLK_GL INTERST_AMT_ON_APRIL_MAY,
               ACBLK_INT_RATE INTERST_RATE,
               ACBLK_AMT_TRF_BLK_GL - ACBLK_AMT_RECOVERED BLOCKED_AMOUNT,
               ACBLK_AMT_TRF_BLK_GL BLOCKED_TRANSFER_AMT,
               (SELECT WAIVED_INTEREST_AMOUNT
                  FROM COVID_SBL_DATA a
                 WHERE a.acc_no = c.acc_no)
                  WAIVE_AMT,
               CASE
                  WHEN ACNTS_CLOSURE_DATE IS NULL THEN 'Open'
                  ELSE 'Closed'
               END
                  ACCOUNT_STATUS,ACBLK_ASSET_TYPE
                  CL_STATUS,FN_GET_SUSPBAL (1,
                                                          ACNTS_INTERNAL_ACNUM,
                                                          '31-MAR-2021')curr_suspbal
          FROM IACLINK,
               ACBLKCOVID,
               ACNTS,
               MBRN_TREE1 BT,
               backuptable.acc7 c,lnprodpm
         WHERE     IACLINK_ENTITY_NUM = 1
               AND IACLINK_ACTUAL_ACNUM = ACC_NO
               AND ACBLK_ENTITY_NUM = 1
               AND ACBLK_INTERNAL_ACNUM = IACLINK_INTERNAL_ACNUM
               and LNPRD_PROD_CODE=IACLINK_PROD_CODE
                and LNPRD_INT_APPL_FREQ='Y'
               -- AND ACBLK_ASSET_TYPE = 'P'
               AND ACNTS_ENTITY_NUM = 1
               AND ACNTS_INTERNAL_ACNUM = IACLINK_INTERNAL_ACNUM
              --  AND ACBLK_AMT_TRF_BLK_GL - ACBLK_AMT_RECOVERED > WAIVED_INTEREST_AMOUNT
               AND ACBLK_BRN_CODE = BT.BRANCH) T
               where BLOCKED_AMOUNT=WAIVE_AMT
               and      NVL (CURR_SUSPBAL, 0) <> 0
          AND NVL (ACCOUNT_STATUS, '#') = 'Open';
 
-------------------------------------------------------------------------------

/* Formatted on 3/29/2021 12:22:03 PM (QP5 v5.252.13127.32867) */
SELECT *
  FROM (SELECT /*+ PARALLEL( 16) */
              BT.PARENT_BRANCH HEAD_OFFICE_CODE,
               (SELECT MBRN_NAME
                  FROM MBRN
                 WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = PARENT_BRANCH)
                  HEAD_OFFICE_NAME,
               BT.GMO_BRANCH GMO_CODE,
               (SELECT MBRN_NAME
                  FROM MBRN
                 WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = GMO_BRANCH)
                  GMO_NAME,
               BT.PO_BRANCH PO_RO_CODE,
               (SELECT MBRN_NAME
                  FROM MBRN
                 WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = PO_BRANCH)
                  PO_RO_NAME,
               ACBLK_BRN_CODE BRANCH_CODE,
               (SELECT MBRN_NAME
                  FROM MBRN
                 WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = ACBLK_BRN_CODE)
                  BRANCH_NAME,
               ACC_NO ACCOUNT_NUMBER,
               ACNTS_AC_NAME1 ACCOUNT_NAME,
               ACBLK_OS_BAL_31MAR OS_BAL_ON_31_03_2020,
               ACBLK_AMT_TRF_BLK_GL INTERST_AMT_ON_APRIL_MAY,
               ACBLK_INT_RATE INTERST_RATE,
               ACBLK_AMT_TRF_BLK_GL - ACBLK_AMT_RECOVERED BLOCKED_AMOUNT,
               ACBLK_AMT_TRF_BLK_GL BLOCKED_TRANSFER_AMT,
               (SELECT WAIVED_INTEREST_AMOUNT
                  FROM COVID_SBL_DATA a
                 WHERE a.acc_no = c.acc_no)
                  WAIVE_AMT,
               CASE
                  WHEN ACNTS_CLOSURE_DATE IS NULL THEN 'Open'
                  ELSE 'Closed'
               END
                  ACCOUNT_STATUS,ACBLK_ASSET_TYPE
                  CL_STATUS,FN_GET_SUSPBAL (1,
                                                          ACNTS_INTERNAL_ACNUM,
                                                          '31-MAR-2021')curr_suspbal
          FROM IACLINK,
               ACBLKCOVID,
               ACNTS,
               MBRN_TREE1 BT,
               backuptable.acc7 c,lnprodpm
         WHERE     IACLINK_ENTITY_NUM = 1
               AND IACLINK_ACTUAL_ACNUM = ACC_NO
               AND ACBLK_ENTITY_NUM = 1
               AND ACBLK_INTERNAL_ACNUM = IACLINK_INTERNAL_ACNUM
               and LNPRD_PROD_CODE=IACLINK_PROD_CODE
                and LNPRD_INT_APPL_FREQ='Y'
               -- AND ACBLK_ASSET_TYPE = 'P'
               AND ACNTS_ENTITY_NUM = 1
              --- AND ACNTS_BRN_CODE = 33076
               AND ACNTS_INTERNAL_ACNUM = IACLINK_INTERNAL_ACNUM
              --  AND ACBLK_AMT_TRF_BLK_GL - ACBLK_AMT_RECOVERED > WAIVED_INTEREST_AMOUNT
               AND ACBLK_BRN_CODE = BT.BRANCH) T
               where WAIVE_AMT<BLOCKED_AMOUNT;

 