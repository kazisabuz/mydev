delete AUTOPOST_TRAN_TEMP;
INSERT INTO AUTOPOST_TRAN_TEMP
   SELECT /*+ PARALLEL( 16) */
         1 BATCH_SL,
          1 LEG_SL,
          NULL TRAN_DATE,
          NULL VALUE_DATE,
          NULL SUPP_TRAN,
          EXCISE_BRN_CODE BRN_CODE,
          EXCISE_BRN_CODE ACING_BRN_CODE,
          'D' DR_CR,
          NULL GLACC_CODE,
          EXCISE_INTERNAL_ACNUM INT_AC_NO,
          NULL CONT_NO,
          'BDT' CURR_CODE,
          ABS (NEW_EXCISE_AMT) AC_AMOUNT,
          'EXCISE DUTY 2021' NARRATION
     FROM (SELECT /*+ PARALLEL( 16) */
                  DISTINCT HOVERING_ENTITY_NUM EXCISE_ENTITY_NUM,
                           HOVERING_BRN_CODE EXCISE_BRN_CODE,
                           HOVERING_YEAR,
                           HOVERING_RECOVERY_FROM_ACNT EXCISE_INTERNAL_ACNUM,
                           'BDT' EXCISE_CURR_CODE,
                           0 EXCISE_MAX_BALANCE,
                           0 NEW_EXCISE_MAX_BALANCE,
                           0 ACNTEXCAMT_EXCISE_AMT,
                           HOVERING_PENDING_AMT NEW_EXCISE_AMT,
                           0 NEW_VAT_AMOUNT,
                           ABS(FN_GET_ASON_ACBAL (1,
                                              HOVERING_RECOVERY_FROM_ACNT,
                                              'BDT',
                                              :P_ASON_DATE,
                                              :P_ASON_DATE))
                              OUTSTANDING_BAL
             FROM HOVERING
            WHERE     HOVERING_ENTITY_NUM = 1
                  AND HOVERING_CHG_CODE = 'ED'
                  AND HOVERING_YEAR = :P_FIN_YEAR
                  AND HOVERING_PENDING_AMT <> 0)
    WHERE OUTSTANDING_BAL >= NEW_EXCISE_AMT;



INSERT INTO AUTOPOST_TRAN_TEMP
     SELECT /*+ PARALLEL( 16) */
           1 BATCH_SL,
            1 LEG_SL,
            NULL TRAN_DATE,
            NULL VALUE_DATE,
            NULL SUPP_TRAN,
            BRN_CODE,
            ACING_BRN_CODE,
            'C' DR_CR,
            '140146113' GLACC_CODE,
            NULL INT_AC_NO,
            NULL CONT_NO,
            'BDT' CURR_CODE,
            SUM (AC_AMOUNT) AC_AMOUNT,
            'EXCISE DUTY 2021' NARRATION
       FROM AUTOPOST_TRAN_TEMP
   GROUP BY BRN_CODE, ACING_BRN_CODE;
   
-------
DELETE FROM AUTOPOST_TRAN_SUPPORT3;

INSERT INTO AUTOPOST_TRAN_SUPPORT3
   SELECT DENSE_RANK () OVER (ORDER BY BRN_CODE) BATCH_SL,
          ROW_NUMBER () OVER (PARTITION BY BRN_CODE ORDER BY BRN_CODE) LEG_SL,
          NULL TRAN_DATE,
       NULL VALUE_DATE,
          NULL  SUPP_TRAN,
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
     
   EXEC SP_AUTO_SCRIPT_TRAN_SUPPORT3;
   
  DELETE FROM ACNTEXCISEAMT_2020;
    DELETE AUTOPOST_TRAN_TEMP;

DECLARE
   P_ASON_DATE   DATE := '18-MAY-2022';
   P_FIN_YEAR    NUMBER := 2021;
BEGIN
  -- DELETE FROM ACNTEXCISEAMT_2020;
   
 --  DELETE AUTOPOST_TRAN_TEMP;


   FOR IDX
      IN ( SELECT   
         BRN_CODE  EXCISE_BRN_CODE,
         INT_AC_NO EXCISE_INTERNAL_ACNUM,
         2021 HOVERING_YEAR
          
     FROM   AUTOPOST_TRAN_SUPPORT3
    WHERE   INT_AC_NO  is not null AND BATCH_NO <>0)
   LOOP
      INSERT INTO ACNTEXCISEAMT_2020
         SELECT *
           FROM ACNTEXCISEAMT
          WHERE     ACNTEXCAMT_ENTITY_NUM = 1
                AND ACNTEXCAMT_BRN_CODE =         IDX.EXCISE_BRN_CODE
                AND ACNTEXCAMT_INTERNAL_ACNUM = IDX.EXCISE_INTERNAL_ACNUM
                AND ACNTEXCAMT_FIN_YEAR =    IDX.HOVERING_YEAR;

      DELETE FROM ACNTEXCISEAMT 
            WHERE     ACNTEXCAMT_ENTITY_NUM = 1
                  AND ACNTEXCAMT_BRN_CODE = IDX.EXCISE_BRN_CODE
                  AND ACNTEXCAMT_INTERNAL_ACNUM = IDX.EXCISE_INTERNAL_ACNUM
                  AND ACNTEXCAMT_FIN_YEAR = IDX.HOVERING_YEAR;
   END LOOP;

   COMMIT;
END;
------------------
/* Formatted on 2/6/2022 3:59:55 PM (QP5 v5.252.13127.32867) */
INSERT INTO ACNTEXCISEAMT (ACNTEXCAMT_ENTITY_NUM,
                           ACNTEXCAMT_BRN_CODE,
                           ACNTEXCAMT_INTERNAL_ACNUM,
                           ACNTEXCAMT_PROCESS_DATE,
                           ACNTEXCAMT_FIN_YEAR,
                           ACNTEXCAMT_EXCISE_AMT,
                           ACNTEXCAMT_POST_TRAN_BRN,
                           ACNTEXCAMT_POST_TRAN_DATE,
                           ACNTEXCAMT_POST_TRAN_BATCH_NUM,
                           ACNTEXCAMT_ENTD_BY,
                           ACNTEXCAMT_ENTD_ON,
                           ACNTEXCAMT_LAST_MOD_BY,
                           ACNTEXCAMT_LAST_MOD_ON,
                           ACNTEXCAMT_AUTH_BY,
                           ACNTEXCAMT_AUTH_ON,
                           ACNTEXCAMT_REJ_BY,
                           ACNTEXCAMT_REJ_ON,
                           ACNTSEXCISE_MAX_BAL)
  SELECT distinct 1 ACNTEXCAMT_ENTITY_NUM,
       BRN_CODE ACNTEXCAMT_BRN_CODE,
       INT_AC_NO ACNTEXCAMT_INTERNAL_ACNUM,
       '31-dec-2021' ACNTEXCAMT_PROCESS_DATE,
       '2021' ACNTEXCAMT_FIN_YEAR,                            ---hovering year
      sum( BC_AMOUNT) ACNTEXCAMT_EXCISE_AMT,
       BRN_CODE ACNTEXCAMT_POST_TRAN_BRN,
       '18-may-2022' ACNTEXCAMT_POST_TRAN_DATE,
       BATCH_NO ACNTEXCAMT_POST_TRAN_BATCH_NUM,
       USER_ID ACNTEXCAMT_ENTD_BY,
       SYSDATE ACNTEXCAMT_ENTD_ON,
       NULL ACNTEXCAMT_LAST_MOD_BY,
       NULL ACNTEXCAMT_LAST_MOD_ON,
       USER_ID ACNTEXCAMT_AUTH_BY,
       SYSDATE ACNTEXCAMT_AUTH_ON,
       NULL ACNTEXCAMT_REJ_BY,
       NULL ACNTEXCAMT_REJ_ON,
        NVL (
          (SELECT sum( ACNTSEXCISE_MAX_BAL)
             FROM ACNTEXCISEAMT_2020
            WHERE     ACNTEXCAMT_ENTITY_NUM = 1
                  AND ACNTEXCAMT_BRN_CODE = BRN_CODE
                  AND ACNTEXCAMT_INTERNAL_ACNUM = INT_AC_NO
                  AND ACNTEXCAMT_FIN_YEAR = 2021),
          0)
          ACNTSEXCISE_MAX_BAL
  FROM AUTOPOST_TRAN_SUPPORT3
 WHERE INT_AC_NO IS NOT NULL AND BATCH_NO <>0   group by BRN_CODE  ,BATCH_NO,USER_ID,
       INT_AC_NO ;
                         
/*


delete  ACNTEXCISEAMT_RECALC;

INSERT INTO ACNTEXCISEAMT_RECALC
   SELECT distinct  EXCISE_ENTITY_NUM,
          EXCISE_BRN_CODE,
          EXCISE_INTERNAL_ACNUM,
          EXCISE_PROD_CODE,
          EXCISE_AC_TYPE,
          EXCISE_CURR_CODE,
          EXCISE_MAX_BALANCE,
          NEW_EXCISE_MAX_BALANCE,
          ACNTEXCAMT_EXCISE_AMT,
          NEW_EXCISE_AMT,
          NEW_VAT_AMOUNT
     FROM (SELECT HOVERING_ENTITY_NUM EXCISE_ENTITY_NUM,
                  HOVERING_BRN_CODE EXCISE_BRN_CODE,
                  ACNTS_INTERNAL_ACNUM EXCISE_INTERNAL_ACNUM,
                  ACNTS_PROD_CODE EXCISE_PROD_CODE,
                  ACNTS_AC_TYPE EXCISE_AC_TYPE,
                  'BDT' EXCISE_CURR_CODE,
                  0 EXCISE_MAX_BALANCE,
                  0 NEW_EXCISE_MAX_BALANCE,
                  0 ACNTEXCAMT_EXCISE_AMT,
                  HOVERING_PENDING_AMT NEW_EXCISE_AMT,
                  0 NEW_VAT_AMOUNT,
                  FN_GET_ASON_ACBAL (1,
                                     ACNTS_INTERNAL_ACNUM,
                                     'BDT',
                                     '29-AUG-2021',
                                     '29-AUG-2021')
                     OUTSTANDING_BAL
             FROM HOVERING, ACNTS
            WHERE     ACNTS_INTERNAL_ACNUM = HOVERING_RECOVERY_FROM_ACNT
                  AND ACNTS_ENTITY_NUM = 1
                  AND HOVERING_CHG_CODE = 'ED'
                  -- and ACNTS_AC_TYPE='SBST'
       -- AND ACNTS_PROD_CODE  in (2101,2102,2103,2104,2105,2106,2107,2108 , 2109)
                  and HOVERING_YEAR =2020
                  AND HOVERING_PENDING_AMT <> 0)
    WHERE OUTSTANDING_BAL >= NEW_EXCISE_AMT;
    */

--SP_EXCISE_AMOUNT_CALCULATE;
--EXEC SP_EXCISE_DUTY_2020;

------alll
SELECT COUNT (ACNTEXCAMT_INTERNAL_ACNUM), SUM (ACNTEXCAMT_EXCISE_AMT) --22257300  338050
  FROM ACNTEXCISEAMT,acnts
 WHERE     ACNTEXCAMT_ENTITY_NUM = 1
       --AND ACNTEXCAMT_FIN_YEAR = 2021
           and    ACNTEXCAMT_INTERNAL_ACNUM=ACNTS_INTERNAL_ACNUM
       and ACNTS_ENTITY_NUM=1
       AND ACNTEXCAMT_POST_TRAN_DATE ='18-MAY-2022'
    -- AND ACNTS_AC_TYPE<>'SBST'
       AND ACNTEXCAMT_EXCISE_AMT <> 0;

-------------------staff--------------
SELECT  COUNT (ACNTEXCAMT_INTERNAL_ACNUM), SUM (A.ACNTEXCAMT_EXCISE_AMT)
FROM ACNTS ,ACNTEXCISEAMT A
WHERE ACNTEXCAMT_INTERNAL_ACNUM=ACNTS_INTERNAL_ACNUM
AND A.ACNTEXCAMT_EXCISE_AMT <> 0
 AND ACNTEXCAMT_POST_TRAN_DATE ='18-MAY-2022'   ---72,978,400       3,207,400      
AND ACNTS_AC_TYPE='SBST';
 

---------slab wise -------------------
  SELECT TRANBAT_NARR_DTL1||TRANBAT_NARR_DTL2 ED_YEAR,
         COUNT (ACNTS_INTERNAL_ACNUM) TOTAL_ACCOUNT,
         TRAN_AMOUNT SLAB,
         SUM (TRAN_AMOUNT) EXCISE_AMT                       --22257300  338050
    FROM TRAN2022, ACNTS,TRANBAT2022
   WHERE     TRAN_AMOUNT <> 0
         AND ACNTS_ENTITY_NUM = 1
         AND TRAN_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
        -- AND ACNTS_AC_TYPE <> 'SBST'
         AND TRAN_ENTITY_NUM = 1
         AND TRAN_DB_CR_FLG='D'
          AND TRANBAT_ENTITY_NUM=1
         AND TRANBAT_SOURCE_TABLE='HOVEREC'
         AND TRANBAT_BRN_CODE=TRAN_BRN_CODE
        AND  TRANBAT_DATE_OF_TRAN=TRAN_DATE_OF_TRAN
         AND TRANBAT_BATCH_NUMBER=TRAN_BATCH_NUMBER
         AND (TRAN_BRN_CODE, TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER) IN (
SELECT TRAN_BRN_CODE, TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER
  FROM TRAN2022,TRANBAT2022
 WHERE     TRAN_ENTITY_NUM = 1
       AND TRAN_GLACC_CODE = '140146113'
       AND TRANBAT_SOURCE_TABLE='HOVEREC'
       AND TRANBAT_ENTITY_NUM=1
         AND TRANBAT_BRN_CODE=TRAN_BRN_CODE
        AND  TRANBAT_DATE_OF_TRAN=TRAN_DATE_OF_TRAN
         AND TRANBAT_BATCH_NUMBER=TRAN_BATCH_NUMBER
       AND TRAN_DATE_OF_TRAN BETWEEN '01-JUN-2022' AND  '30-JUN-2022'
       AND TRAN_DB_CR_FLG = 'C')
GROUP BY TRAN_AMOUNT, TRANBAT_NARR_DTL1|| TRANBAT_NARR_DTL2;
---------------
/* Formatted on 8/19/2021 11:16:04 AM (QP5 v5.149.1003.31008) */
BEGIN
   UPDATE ACNTBAL
      SET ACNTBAL_AC_DB_QUEUE_AMT = 0, ACNTBAL_BC_DB_QUEUE_AMT = 0
    WHERE ACNTBAL_INTERNAL_ACNUM IN
             (SELECT ACNTEXCAMT_INTERNAL_ACNUM
                FROM ACNTEXCISEAMT
               WHERE     ACNTEXCAMT_ENTITY_NUM = 1
                     AND ACNTEXCAMT_FIN_YEAR=2021
                     AND ACNTEXCAMT_POST_TRAN_DATE ='18-MAY-2022'
                     --AND ACNTEXCAMT_INTERNAL_ACNUM IN  (SELECT  EXCISE_INTERNAL_ACNUM FROM ACNTEXCISEAMT_RECALC_LIST)
                     AND ACNTEXCAMT_EXCISE_AMT <> 0);

   UPDATE HOVERING
      SET HOVERING_PENDING_AMT = 0, HOVERING_STATUS = 'E'
    WHERE HOVERING_CHG_CODE = 'ED'
          AND HOVERING_RECOVERY_FROM_ACNT IN
                 (SELECT ACNTEXCAMT_INTERNAL_ACNUM
                    FROM ACNTEXCISEAMT
                   WHERE     ACNTEXCAMT_ENTITY_NUM = 1
                         AND ACNTEXCAMT_FIN_YEAR =2021
                         AND ACNTEXCAMT_POST_TRAN_DATE = '18-MAY-2022'
                         --AND ACNTEXCAMT_INTERNAL_ACNUM IN  (SELECT  EXCISE_INTERNAL_ACNUM FROM ACNTEXCISEAMT_RECALC_LIST)
                         AND ACNTEXCAMT_EXCISE_AMT <> 0);
END;


DELETE FROM ACNTEXCISEAMT
WHERE ACNTEXCAMT_INTERNAL_ACNUM IN ( SELECT EXCISE_INTERNAL_ACNUM  FROM ACNTEXCISEAMT_RECALC)
AND ACNTEXCAMT_FIN_YEAR IN (2020,2021)
AND ACNTEXCAMT_EXCISE_AMT=0;