/* Formatted on 2/23/2022 4:24:20 PM (QP5 v5.252.13127.32867) */
DECLARE
   P_TM    NUMBER (18);
   P_ERR   VARCHAR2 (500);
BEGIN
   PKG_RGLSTMT_UPD.SP_RGLSTMT_UPD (1,
                                   26,
                                   '140146225',
                                   'BDT',
                                   '01-JAN-2020',
                                   '30-JUN-2021',
                                   0,
                                   P_TM,
                                   P_ERR,
                                   0);
    DBMS_OUTPUT.PUT_LINE('SERIAL '||P_TM'  ' ||P_ERR);
END;

----------------------------QUERY---------

  SELECT /*+ PARALLEL( 16) */
        TRAN_BRN_CODE,
         (SELECT MBRN_NAME
            FROM MBRN
           WHERE     MBRN_ENTITY_NUM = 1
                 AND MBRN_CLOSURE_DATE IS NULL
                 AND MBRN_STATUS_FLG <> 'I'
                 AND MBRN_CODE = 26)
            AS MBRN_NAME,
         ADDL_GLACC_CODE,
         TRAN_DATE_OF_TRAN,
         NARRDTL,
         TRAN_AMTCR_FRMT CREDIT_AMOUNT,
         TRAN_AMTDB_FRMT DEBIT_AMOUNT,
         AMT_FRMT BALANCE,
         DB_CR,
         SP_GETFORMAT (1, ADDL_CURR_CODE, ADDL_OPEN_BAL) ADDL_OPEN_BAL,
         SP_GETFORMAT (1, ADDL_CURR_CODE, ADDL_CLOS_BAL) ADDL_CLOS_BAL
    FROM RTMPGLST, RTMPGLSTADDL
   WHERE     ADDL_TEMP_SERIAL = 311147
         AND TEMP_SERIAL(+) = ADDL_TEMP_SERIAL
         AND TRAN_BRN_CODE = 26
         AND TRAN_GLACC_CODE = '140146225'
         AND TRAN_GLACC_CODE(+) = ADDL_GLACC_CODE
ORDER BY TRAN_DATE_OF_TRAN;


-----RACST----------------

  SELECT TRAN_ACING_BRN_CODE BRN_CODE,
         (SELECT mbrn_name
            FROM mbrn
           WHERE mbrn_code = TRAN_ACING_BRN_CODE)
            mbrn_name,
         TRAN_DATE_OF_TRAN,
         facno (1, TRAN_INTERNAL_ACNUM) account_no,
         ACNTS_AC_NAME1 || ACNTS_AC_NAME2 account_name,
         TRAN_AMOUNT
    FROM TRAN2021, acnts
   WHERE     TRAN_ENTITY_NUM = 1
         AND UPPER (TRAN_NARR_DTL1 || TRAN_NARR_DTL2 || TRAN_NARR_DTL3) =
                'STATEMENT CHARGE'
         AND TRAN_INTERNAL_ACNUM <> 0
         AND TRAN_DB_CR_FLG = 'D'
         AND ACNTS_ENTITY_NUM = 1
         AND ACNTS_INTERNAL_ACNUM = TRAN_INTERNAL_ACNUM
         -- AND TRAN_BRN_CODE = 1065
         AND TRAN_AUTH_BY IS NOT NULL
ORDER BY TRAN_DATE_OF_TRAN;


  SELECT GLSUM_BRANCH_CODE BRANCH_CODE,
         (SELECT mbrn_name
            FROM mbrn
           WHERE mbrn_code = GLSUM_BRANCH_CODE)
            mbrn_name,
         GLSUM_TRAN_DATE TRAN_DATE,
         GLSUM_BC_CR_SUM credit_amount
    FROM glsum2021
   WHERE GLSUM_ENTITY_NUM = 1 AND GLSUM_GLACC_CODE = '300125149'
--    AND GLSUM_BRANCH_CODE = 1065
ORDER BY GLSUM_TRAN_DATE;

--------------------NOMINAL GL TO INCOME-----------------


SELECT  /*+ PARALLEL( 8) */  TRAN_BRN_CODE,
       (SELECT mbrn_name
          FROM mbrn
         WHERE mbrn_code = TRAN_BRN_CODE)
          mbrn_name,
       TRAN_GLACC_CODE GLACC_CODE,
       TRAN_DATE_OF_TRAN DATE_OF_TRAN,
       TRAN_AMOUNT,
       UPPER (TRAN_NARR_DTL1 || TRAN_NARR_DTL2 || TRAN_NARR_DTL3) NARRATION
  FROM TRAN2021
 WHERE     TRAN_ENTITY_NUM = 1
       AND TRAN_GLACC_CODE ='140107101'
       AND TRAN_DB_CR_FLG = 'C'
     --  AND TRAN_BRN_CODE = 26
       AND TRAN_AUTH_BY IS NOT NULL
       AND (TRAN_BRN_CODE,
        TRAN_DATE_OF_TRAN,
         TRAN_BATCH_NUMBER) 
IN (SELECT /*+ PARALLEL( 8) */ TRAN_BRN_CODE,
    TRAN_DATE_OF_TRAN,
    TRAN_BATCH_NUMBER
FROM TRAN2021
WHERE     TRAN_ENTITY_NUM =
           1
    AND TRAN_GLACC_CODE IN ('300137113')
                                                                            
    AND TRAN_DB_CR_FLG =
           'D'
    AND TRAN_AUTH_BY
           IS NOT NULL);