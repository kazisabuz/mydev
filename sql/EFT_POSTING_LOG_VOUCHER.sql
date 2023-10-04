TRUNCATE TABLE  AUTOPOST_TRAN_TEMP;

INSERT INTO AUTOPOST_TRAN_TEMP
   SELECT /*+ PARALLEL( 8) */
         1 BATCH_SL,
          1 LEG_SL,
          NULL TRAN_DATE,
          NULL VALUE_DATE,
          NULL SUPP_TRAN,
          BRN_CODE BRN_CODE,
          ACCOUNTING_BRN_CODE ACING_BRN_CODE,
          DR_CR DR_CR,
          GLACC_CODE GLACC_CODE,
          NULL INT_AC_NO,
          NULL CONT_NO,
          'BDT' CURR_CODE,
          AMOUNT AC_AMOUNT,
         LEG_NARRATION,
         null,null,null
     FROM TRAN_BATCH_UPLOAD
    WHERE     BRN_CODE = 26
         -- AND PURPOSE_CODE = 'REGUCORDCR'   
          and DR_CR='C'
         -- AND PROCESSED = 'V'
          AND TRAN_DATE ='26-jun-2023' --current date
   UNION ALL
   SELECT /*+ PARALLEL( 8) */
         1 BATCH_SL,
          1 LEG_SL,
          NULL TRAN_DATE,
          NULL VALUE_DATE,
          NULL SUPP_TRAN,
          BRN_CODE BRN_CODE,
          ACCOUNTING_BRN_CODE ACING_BRN_CODE,
          DR_CR DR_CR,
          GLACC_CODE GLACC_CODE,
          NULL INT_AC_NO,
          NULL CONT_NO,
          'BDT' CURR_CODE,
          AMOUNT AC_AMOUNT,
         LEG_NARRATION, null,null,null
     FROM TRAN_BATCH_UPLOAD
    WHERE     BRN_CODE = 26
          --AND PURPOSE_CODE = 'REGUCORDCR'
          and DR_CR='D'
         -- AND PROCESSED = 'V'
          AND TRAN_DATE ='26-jun-2023'; --current date;

---If batch not posting----

delete AUTOPOST_TRAN_TEMP;
--------2nd step---------------
INSERT INTO AUTOPOST_TRAN_TEMP
   SELECT /*+ PARALLEL( 8) */
         1 BATCH_SL,
          1 LEG_SL,
          NULL TRAN_DATE,
          NULL VALUE_DATE,
          NULL SUPP_TRAN,
          ACCOUNTING_BRN_CODE BRN_CODE,
          26 ACING_BRN_CODE,
          'C' DR_CR,
          GLACC_CODE GLACC_CODE,
          NULL INT_AC_NO,
          NULL CONT_NO,
          'BDT' CURR_CODE,
          AMOUNT AC_AMOUNT,
         LEG_NARRATION
     FROM TRAN_BATCH_UPLOAD
    WHERE     PURPOSE_CODE = 'EFTC3SETTLDR'
          and DR_CR='D'
          AND TRAN_DATE ='29-DEC-2022' --current date
   UNION ALL
   SELECT /*+ PARALLEL( 8) */
         1 BATCH_SL,
          1 LEG_SL,
          NULL TRAN_DATE,
          NULL VALUE_DATE,
          NULL SUPP_TRAN,
          ACCOUNTING_BRN_CODE BRN_CODE,
          ACCOUNTING_BRN_CODE ACING_BRN_CODE,
          'D' DR_CR,
          GLACC_CODE GLACC_CODE,
          NULL INT_AC_NO,
          NULL CONT_NO,
          'BDT' CURR_CODE,
          AMOUNT AC_AMOUNT,
         LEG_NARRATION
     FROM TRAN_BATCH_UPLOAD
    WHERE     BRN_CODE = 26
          AND PURPOSE_CODE = 'EFTC3SETTLDR'
          and DR_CR='D'
          AND TRAN_DATE ='29-DEC-2022'; --current date;



---------------------------------FOR VOUCHER---------------------------------------------------

 
DELETE FROM AUTOPOST_TRAN;

INSERT INTO AUTOPOST_TRAN
   SELECT DENSE_RANK () OVER (ORDER BY BRN_CODE) BATCH_SL,
          ROW_NUMBER () OVER (PARTITION BY BRN_CODE ORDER BY BRN_CODE) LEG_SL,
          NULL TRAN_DATE,
          NULL VALUE_DATE,
          NULL SUPP_TRAN,
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
          '40046' USER_ID,
          NULL TERMINAL_ID,
          NULL PROCESSED,
          NULL BATCH_NO,
          NULL ERR_MSG,
          NULL DEPT_CODE
     FROM AUTOPOST_TRAN_TEMP TT;

     EXEC SP_AUTO_SCRIPT_TRAN;

UPDATE TRAN_BATCH_UPLOAD
   SET PROCESSED = 'P', BATCH_NO = 909, ERR_MSG = NULL
 WHERE     BRN_CODE = 26
       AND PURPOSE_CODE = 'REGUCORECR'
       AND TRAN_DATE ='21-MAy-2023';
       
       
       
       
--------BULK-----------
BEGIN
   FOR IDX IN (  SELECT DISTINCT BRN_CODE
                   FROM AUTOPOST_TRAN
               ORDER BY BRN_CODE ASC)
   LOOP
      SP_AUTO_SCRIPT_TRAN_BR_WISE (IDX.BRN_CODE);
      COMMIT;
   END LOOP;
END SP_GEN_TRAN;