DELETE FROM AUTOPOST_TRAN_TEMP;
  ------------------------------------

INSERT INTO AUTOPOST_TRAN_TEMP
   SELECT  /*+ PARALLEL( 16) */  1 BATCH_SL,
          1 LEG_SL,
          '31-DEC-2021' TRAN_DATE,
          '31-DEC-2021' VALUE_DATE,
          1 SUPP_TRAN,
          GLBALH_BRN_CODE BRN_CODE,
          GLBALH_BRN_CODE ACING_BRN_CODE,
          CASE
             WHEN SIGN (GLBALH_BC_BAL) = 1 THEN 'D'
             WHEN SIGN (GLBALH_BC_BAL) = -1 THEN 'C'
             ELSE NULL
          END
             DR_CR,
          GLBALH_GLACC_CODE GLACC_CODE,
          NULL INT_AC_NO,
          NULL CONT_NO,
          'BDT' CURR_CODE,
          ABS (GLBALH_BC_BAL) AC_AMOUNT,
          'Profit/Los trf-2021|email: CAD, Wed 5/18/2022 12:43 PM' NARRATION
     FROM GLBALASONHIST
    WHERE     GLBALH_GLACC_CODE  LIKE '300%'
          AND GLBALH_ASON_DATE = '31-DEC-2021'
         -- and GLBALH_BRN_CODE=1024
          AND GLBALH_ENTITY_NUM = 1
          AND GLBALH_BC_BAL <> 0
   UNION ALL
   SELECT /*+ PARALLEL( 16) */   1 BATCH_SL,
          1 LEG_SL,
          '31-DEC-2021' TRAN_DATE,
          '31-DEC-2021' VALUE_DATE,
          1 SUPP_TRAN,
          GLBALH_BRN_CODE BRN_CODE,
          GLBALH_BRN_CODE ACING_BRN_CODE,
          CASE
             WHEN SIGN (GLBALH_BC_BAL) = 1 THEN 'D'
             WHEN SIGN (GLBALH_BC_BAL) = -1 THEN 'C'
             ELSE NULL
          END
             DR_CR,
          GLBALH_GLACC_CODE GLACC_CODE,
          NULL INT_AC_NO,
          NULL CONT_NO,
          'BDT' CURR_CODE,
          ABS (GLBALH_BC_BAL) AC_AMOUNT,
          'Profit/Los trf-2021|email: CAD, Wed 5/18/2022 12:43 PM' NARRATION
     FROM GLBALASONHIST
    WHERE     GLBALH_GLACC_CODE LIKE '400%'
          AND GLBALH_ASON_DATE = '31-DEC-2021'
         -- and GLBALH_BRN_CODE=1024
          AND GLBALH_ENTITY_NUM = 1
          AND GLBALH_BC_BAL <> 0;

INSERT INTO AUTOPOST_TRAN
   SELECT DENSE_RANK () OVER (ORDER BY TRAN_DATE,BRN_CODE) BATCH_SL,
          ROW_NUMBER () OVER (PARTITION BY TRAN_DATE,BRN_CODE ORDER BY TRAN_DATE,BRN_CODE) LEG_SL,
         TRAN_DATE TRAN_DATE,
          VALUE_DATE VALUE_DATE,
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
           NARRATION,
           NARRATION,
          'INTELECT' USER_ID,
          NULL TERMINAL_ID,
          NULL PROCESSED,
          NULL BATCH_NO,
          NULL ERR_MSG,
          NULL DEPT_CODE
     FROM AUTOPOST_TRAN_TEMP TT;


EXEC SP_AUTO_SCRIPT_TRAN;

