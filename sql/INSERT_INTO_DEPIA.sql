/*Insert scrpit for DEPIA table for the rectification.*/
INSERT INTO DEPIA 
  SELECT ACNTS_ENTITY_NUM DEPIA_ENTITY_NUM,
         ACNTS_BRN_CODE DEPIA_BRN_CODE,
         ACNTS_INTERNAL_ACNUM DEPIA_INTERNAL_ACNUM,
         PBDCONT_CONT_NUM DEPIA_CONTRACT_NUM,
         0 DEPIA_AUTO_ROLLOVER_SL,
         TRAN_DATE_OF_TRAN DEPIA_DATE_OF_ENTRY,
         NVL((SELECT MAX (DEPIA_DAY_SL) 
            FROM DEPIA
           WHERE     DEPIA_ENTITY_NUM = ACNTS_ENTITY_NUM
                 AND DEPIA_BRN_CODE = ACNTS_BRN_CODE
                 AND DEPIA_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                 AND DEPIA_CONTRACT_NUM = PBDCONT_CONT_NUM
                 AND DEPIA_AUTO_ROLLOVER_SL = 0
                 AND DEPIA_DATE_OF_ENTRY = TRAN_DATE_OF_TRAN),0) + 1
            DEPIA_DAY_SL,
         TRAN_AMOUNT DEPIA_AC_INT_ACCR_AMT,
         'D' DEPIA_INT_ACCR_DB_CR,
         TRAN_AMOUNT DEPIA_BC_INT_ACCR_AMT,
         0 DEPIA_AC_FULL_INT_ACCR_AMT,
         0 DEPIA_BC_FULL_INT_ACCR_AMT,
         0 DEPIA_AC_PREV_INT_ACCR_AMT,
         0 DEPIA_BC_PREV_INT_ACCR_AMT,
         ADD_MONTHS (TRAN_DATE_OF_TRAN, -12) DEPIA_ACCR_FROM_DATE,
         TRAN_DATE_OF_TRAN - 1 DEPIA_ACCR_UPTO_DATE,
         'TD' DEPIA_ENTRY_TYPE,
         TRAN_ENTD_BY DEPIA_ACCR_POSTED_BY,
         TRUNC (TRAN_ENTD_ON) DEPIA_ACCR_POSTED_ON,
         NULL DEPIA_LAST_MOD_BY,
         NULL DEPIA_LAST_MOD_ON,
         'PKG_DEP_INT_APPLY' DEPIA_SOURCE_TABLE,
         NULL DEPIA_SOURCE_KEY,
         0 DEPIA_PREV_YR_INT_ACCR
    FROM ACNTS,
         DEPPROD,
         TRAN2014,
         PBDCONTRACT
   WHERE     DEPPR_TYPE_OF_DEP = '2'
         AND ACNTS_ENTITY_NUM = 1
         AND ACNTS_CLOSURE_DATE IS NULL
         AND ACNTS_PROD_CODE = DEPPR_PROD_CODE
         --AND ACNTS_BRN_CODE = 1016
         AND ACNTS_INTERNAL_ACNUM = TRAN_INTERNAL_ACNUM
         AND TRAN_ENTITY_NUM = 1
         AND PBDCONT_ENTITY_NUM = 1
         AND PBDCONT_BRN_CODE = ACNTS_BRN_CODE
         AND PBDCONT_DEP_AC_NUM = TRAN_INTERNAL_ACNUM
         AND TRAN_AMOUNT <> 0 
         AND TRAN_NARR_DTL1 IN ('TDS Deduction On Interest Earned', 'TDS On Interest') 
         AND (ACNTS_BRN_CODE, TRAN_INTERNAL_ACNUM, TRAN_DATE_OF_TRAN) NOT IN
                (SELECT DEPIA_BRN_CODE,
                        DEPIA_INTERNAL_ACNUM,
                        DEPIA_DATE_OF_ENTRY
                   FROM DEPIA
                  WHERE     DEPIA_ENTITY_NUM = 1
                        AND DEPIA_BRN_CODE = ACNTS_BRN_CODE
                        AND DEPIA_CONTRACT_NUM = 1
                        AND DEPIA_ENTRY_TYPE = 'TD')
ORDER BY TRAN_INTERNAL_ACNUM, TRAN_DATE_OF_TRAN ;


/* Formatted on 3/20/2019 5:08:53 PM (QP5 v5.227.12220.39754) */
INSERT INTO DEPIA
     SELECT ACNTS_ENTITY_NUM DEPIA_ENTITY_NUM,
            ACNTS_BRN_CODE DEPIA_BRN_CODE,
            ACNTS_INTERNAL_ACNUM DEPIA_INTERNAL_ACNUM,
            PBDCONT_CONT_NUM DEPIA_CONTRACT_NUM,
            0 DEPIA_AUTO_ROLLOVER_SL,
            TRAN_DATE_OF_TRAN DEPIA_DATE_OF_ENTRY,
              NVL (
                 (SELECT MAX (DEPIA_DAY_SL)
                    FROM DEPIA
                   WHERE     DEPIA_ENTITY_NUM = ACNTS_ENTITY_NUM
                         AND DEPIA_BRN_CODE = ACNTS_BRN_CODE
                         AND DEPIA_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                         AND DEPIA_CONTRACT_NUM = PBDCONT_CONT_NUM
                         AND DEPIA_AUTO_ROLLOVER_SL = 0
                         AND DEPIA_DATE_OF_ENTRY = TRAN_DATE_OF_TRAN),
                 0)
            + 1
               DEPIA_DAY_SL,
            TRAN_AMOUNT DEPIA_AC_INT_ACCR_AMT,
            'D' DEPIA_INT_ACCR_DB_CR,
            TRAN_AMOUNT DEPIA_BC_INT_ACCR_AMT,
            0 DEPIA_AC_FULL_INT_ACCR_AMT,
            0 DEPIA_BC_FULL_INT_ACCR_AMT,
            0 DEPIA_AC_PREV_INT_ACCR_AMT,
            0 DEPIA_BC_PREV_INT_ACCR_AMT,
            ADD_MONTHS (TRAN_DATE_OF_TRAN, -12) DEPIA_ACCR_FROM_DATE,
            TRAN_DATE_OF_TRAN - 1 DEPIA_ACCR_UPTO_DATE,
            'TD' DEPIA_ENTRY_TYPE,
            TRAN_ENTD_BY DEPIA_ACCR_POSTED_BY,
            TRUNC (TRAN_ENTD_ON) DEPIA_ACCR_POSTED_ON,
            NULL DEPIA_LAST_MOD_BY,
            NULL DEPIA_LAST_MOD_ON,
            'PKG_DEP_INT_APPLY' DEPIA_SOURCE_TABLE,
            NULL DEPIA_SOURCE_KEY,
            0 DEPIA_PREV_YR_INT_ACCR
       FROM ACNTS,
            DEPPROD,
            TRAN2015,
            PBDCONTRACT
      WHERE     DEPPR_TYPE_OF_DEP = '2'
            AND ACNTS_ENTITY_NUM = 1
            AND ACNTS_CLOSURE_DATE IS NULL
            AND ACNTS_PROD_CODE = DEPPR_PROD_CODE
            --AND ACNTS_BRN_CODE = 1016
            AND ACNTS_INTERNAL_ACNUM = TRAN_INTERNAL_ACNUM
            AND TRAN_ENTITY_NUM = 1
            AND PBDCONT_ENTITY_NUM = 1
            AND PBDCONT_BRN_CODE = ACNTS_BRN_CODE
            AND PBDCONT_DEP_AC_NUM = TRAN_INTERNAL_ACNUM
            AND TRAN_AMOUNT <> 0 
            AND TRAN_NARR_DTL1 IN
                   ('TDS Deduction On Interest Earned', 'TDS On Interest')
            AND (ACNTS_BRN_CODE, TRAN_INTERNAL_ACNUM, TRAN_DATE_OF_TRAN) NOT IN
                   (SELECT DEPIA_BRN_CODE,
                           DEPIA_INTERNAL_ACNUM,
                           DEPIA_DATE_OF_ENTRY
                      FROM DEPIA
                     WHERE     DEPIA_ENTITY_NUM = 1
                           AND DEPIA_BRN_CODE = ACNTS_BRN_CODE
                           AND DEPIA_CONTRACT_NUM = 1
                           AND DEPIA_ENTRY_TYPE = 'TD')
   ORDER BY TRAN_INTERNAL_ACNUM, TRAN_DATE_OF_TRAN ;
    
	
	
	/* Formatted on 3/20/2019 5:08:53 PM (QP5 v5.227.12220.39754) */
INSERT INTO DEPIA
     SELECT ACNTS_ENTITY_NUM DEPIA_ENTITY_NUM,
            ACNTS_BRN_CODE DEPIA_BRN_CODE,
            ACNTS_INTERNAL_ACNUM DEPIA_INTERNAL_ACNUM,
            PBDCONT_CONT_NUM DEPIA_CONTRACT_NUM,
            0 DEPIA_AUTO_ROLLOVER_SL,
            TRAN_DATE_OF_TRAN DEPIA_DATE_OF_ENTRY,
              NVL (
                 (SELECT MAX (DEPIA_DAY_SL)
                    FROM DEPIA
                   WHERE     DEPIA_ENTITY_NUM = ACNTS_ENTITY_NUM
                         AND DEPIA_BRN_CODE = ACNTS_BRN_CODE
                         AND DEPIA_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                         AND DEPIA_CONTRACT_NUM = PBDCONT_CONT_NUM
                         AND DEPIA_AUTO_ROLLOVER_SL = 0
                         AND DEPIA_DATE_OF_ENTRY = TRAN_DATE_OF_TRAN),
                 0)
            + 1
               DEPIA_DAY_SL,
            TRAN_AMOUNT DEPIA_AC_INT_ACCR_AMT,
            'D' DEPIA_INT_ACCR_DB_CR,
            TRAN_AMOUNT DEPIA_BC_INT_ACCR_AMT,
            0 DEPIA_AC_FULL_INT_ACCR_AMT,
            0 DEPIA_BC_FULL_INT_ACCR_AMT,
            0 DEPIA_AC_PREV_INT_ACCR_AMT,
            0 DEPIA_BC_PREV_INT_ACCR_AMT,
            ADD_MONTHS (TRAN_DATE_OF_TRAN, -12) DEPIA_ACCR_FROM_DATE,
            TRAN_DATE_OF_TRAN - 1 DEPIA_ACCR_UPTO_DATE,
            'TD' DEPIA_ENTRY_TYPE,
            TRAN_ENTD_BY DEPIA_ACCR_POSTED_BY,
            TRUNC (TRAN_ENTD_ON) DEPIA_ACCR_POSTED_ON,
            NULL DEPIA_LAST_MOD_BY,
            NULL DEPIA_LAST_MOD_ON,
            'PKG_DEP_INT_APPLY' DEPIA_SOURCE_TABLE,
            NULL DEPIA_SOURCE_KEY,
            0 DEPIA_PREV_YR_INT_ACCR
       FROM ACNTS,
            DEPPROD,
            TRAN2016,
            PBDCONTRACT
      WHERE     DEPPR_TYPE_OF_DEP = '2'
            AND ACNTS_ENTITY_NUM = 1
            AND ACNTS_CLOSURE_DATE IS NULL
            AND ACNTS_PROD_CODE = DEPPR_PROD_CODE
            --AND ACNTS_BRN_CODE = 1016
            AND ACNTS_INTERNAL_ACNUM = TRAN_INTERNAL_ACNUM
            AND TRAN_ENTITY_NUM = 1
            AND PBDCONT_ENTITY_NUM = 1
            AND PBDCONT_BRN_CODE = ACNTS_BRN_CODE
            AND PBDCONT_DEP_AC_NUM = TRAN_INTERNAL_ACNUM
            AND TRAN_AMOUNT <> 0 
            AND TRAN_NARR_DTL1 IN
                   ('TDS Deduction On Interest Earned', 'TDS On Interest')
            AND (ACNTS_BRN_CODE, TRAN_INTERNAL_ACNUM, TRAN_DATE_OF_TRAN) NOT IN
                   (SELECT DEPIA_BRN_CODE,
                           DEPIA_INTERNAL_ACNUM,
                           DEPIA_DATE_OF_ENTRY
                      FROM DEPIA
                     WHERE     DEPIA_ENTITY_NUM = 1
                           AND DEPIA_BRN_CODE = ACNTS_BRN_CODE
                           AND DEPIA_CONTRACT_NUM = 1
                           AND DEPIA_ENTRY_TYPE = 'TD')
   ORDER BY TRAN_INTERNAL_ACNUM, TRAN_DATE_OF_TRAN ;
    
	
	
	
/* Formatted on 3/20/2019 5:08:53 PM (QP5 v5.227.12220.39754) */
INSERT INTO DEPIA
     SELECT ACNTS_ENTITY_NUM DEPIA_ENTITY_NUM,
            ACNTS_BRN_CODE DEPIA_BRN_CODE,
            ACNTS_INTERNAL_ACNUM DEPIA_INTERNAL_ACNUM,
            PBDCONT_CONT_NUM DEPIA_CONTRACT_NUM,
            0 DEPIA_AUTO_ROLLOVER_SL,
            TRAN_DATE_OF_TRAN DEPIA_DATE_OF_ENTRY,
              NVL (
                 (SELECT MAX (DEPIA_DAY_SL)
                    FROM DEPIA
                   WHERE     DEPIA_ENTITY_NUM = ACNTS_ENTITY_NUM
                         AND DEPIA_BRN_CODE = ACNTS_BRN_CODE
                         AND DEPIA_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                         AND DEPIA_CONTRACT_NUM = PBDCONT_CONT_NUM
                         AND DEPIA_AUTO_ROLLOVER_SL = 0
                         AND DEPIA_DATE_OF_ENTRY = TRAN_DATE_OF_TRAN),
                 0)
            + 1
               DEPIA_DAY_SL,
            TRAN_AMOUNT DEPIA_AC_INT_ACCR_AMT,
            'D' DEPIA_INT_ACCR_DB_CR,
            TRAN_AMOUNT DEPIA_BC_INT_ACCR_AMT,
            0 DEPIA_AC_FULL_INT_ACCR_AMT,
            0 DEPIA_BC_FULL_INT_ACCR_AMT,
            0 DEPIA_AC_PREV_INT_ACCR_AMT,
            0 DEPIA_BC_PREV_INT_ACCR_AMT,
            ADD_MONTHS (TRAN_DATE_OF_TRAN, -12) DEPIA_ACCR_FROM_DATE,
            TRAN_DATE_OF_TRAN - 1 DEPIA_ACCR_UPTO_DATE,
            'TD' DEPIA_ENTRY_TYPE,
            TRAN_ENTD_BY DEPIA_ACCR_POSTED_BY,
            TRUNC (TRAN_ENTD_ON) DEPIA_ACCR_POSTED_ON,
            NULL DEPIA_LAST_MOD_BY,
            NULL DEPIA_LAST_MOD_ON,
            'PKG_DEP_INT_APPLY' DEPIA_SOURCE_TABLE,
            NULL DEPIA_SOURCE_KEY,
            0 DEPIA_PREV_YR_INT_ACCR
       FROM ACNTS,
            DEPPROD,
            TRAN2017,
            PBDCONTRACT
      WHERE     DEPPR_TYPE_OF_DEP = '2'
            AND ACNTS_ENTITY_NUM = 1
            AND ACNTS_CLOSURE_DATE IS NULL
            AND ACNTS_PROD_CODE = DEPPR_PROD_CODE
            --AND ACNTS_BRN_CODE = 1016
            AND ACNTS_INTERNAL_ACNUM = TRAN_INTERNAL_ACNUM
            AND TRAN_ENTITY_NUM = 1
            AND PBDCONT_ENTITY_NUM = 1
            AND PBDCONT_BRN_CODE = ACNTS_BRN_CODE
            AND PBDCONT_DEP_AC_NUM = TRAN_INTERNAL_ACNUM
            AND TRAN_AMOUNT <> 0 
            AND TRAN_NARR_DTL1 IN
                   ('TDS Deduction On Interest Earned', 'TDS On Interest')
            AND (ACNTS_BRN_CODE, TRAN_INTERNAL_ACNUM, TRAN_DATE_OF_TRAN) NOT IN
                   (SELECT DEPIA_BRN_CODE,
                           DEPIA_INTERNAL_ACNUM,
                           DEPIA_DATE_OF_ENTRY
                      FROM DEPIA
                     WHERE     DEPIA_ENTITY_NUM = 1
                           AND DEPIA_BRN_CODE = ACNTS_BRN_CODE
                           AND DEPIA_CONTRACT_NUM = 1
                           AND DEPIA_ENTRY_TYPE = 'TD')
   ORDER BY TRAN_INTERNAL_ACNUM, TRAN_DATE_OF_TRAN ;
  
  
  
  
/* Formatted on 3/20/2019 5:08:53 PM (QP5 v5.227.12220.39754) */
INSERT INTO DEPIA
     SELECT ACNTS_ENTITY_NUM DEPIA_ENTITY_NUM,
            ACNTS_BRN_CODE DEPIA_BRN_CODE,
            ACNTS_INTERNAL_ACNUM DEPIA_INTERNAL_ACNUM,
            PBDCONT_CONT_NUM DEPIA_CONTRACT_NUM,
            0 DEPIA_AUTO_ROLLOVER_SL,
            TRAN_DATE_OF_TRAN DEPIA_DATE_OF_ENTRY,
              NVL (
                 (SELECT MAX (DEPIA_DAY_SL)
                    FROM DEPIA
                   WHERE     DEPIA_ENTITY_NUM = ACNTS_ENTITY_NUM
                         AND DEPIA_BRN_CODE = ACNTS_BRN_CODE
                         AND DEPIA_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                         AND DEPIA_CONTRACT_NUM = PBDCONT_CONT_NUM
                         AND DEPIA_AUTO_ROLLOVER_SL = 0
                         AND DEPIA_DATE_OF_ENTRY = TRAN_DATE_OF_TRAN),
                 0)
            + 1
               DEPIA_DAY_SL,
            TRAN_AMOUNT DEPIA_AC_INT_ACCR_AMT,
            'D' DEPIA_INT_ACCR_DB_CR,
            TRAN_AMOUNT DEPIA_BC_INT_ACCR_AMT,
            0 DEPIA_AC_FULL_INT_ACCR_AMT,
            0 DEPIA_BC_FULL_INT_ACCR_AMT,
            0 DEPIA_AC_PREV_INT_ACCR_AMT,
            0 DEPIA_BC_PREV_INT_ACCR_AMT,
            ADD_MONTHS (TRAN_DATE_OF_TRAN, -12) DEPIA_ACCR_FROM_DATE,
            TRAN_DATE_OF_TRAN - 1 DEPIA_ACCR_UPTO_DATE,
            'TD' DEPIA_ENTRY_TYPE,
            TRAN_ENTD_BY DEPIA_ACCR_POSTED_BY,
            TRUNC (TRAN_ENTD_ON) DEPIA_ACCR_POSTED_ON,
            NULL DEPIA_LAST_MOD_BY,
            NULL DEPIA_LAST_MOD_ON,
            'PKG_DEP_INT_APPLY' DEPIA_SOURCE_TABLE,
            NULL DEPIA_SOURCE_KEY,
            0 DEPIA_PREV_YR_INT_ACCR
       FROM ACNTS,
            DEPPROD,
            TRAN2018,
            PBDCONTRACT
      WHERE     DEPPR_TYPE_OF_DEP = '2'
            AND ACNTS_ENTITY_NUM = 1
            AND ACNTS_CLOSURE_DATE IS NULL
            AND ACNTS_PROD_CODE = DEPPR_PROD_CODE
            --AND ACNTS_BRN_CODE = 1016
            AND ACNTS_INTERNAL_ACNUM = TRAN_INTERNAL_ACNUM
            AND TRAN_ENTITY_NUM = 1
            AND PBDCONT_ENTITY_NUM = 1
            AND PBDCONT_BRN_CODE = ACNTS_BRN_CODE
            AND PBDCONT_DEP_AC_NUM = TRAN_INTERNAL_ACNUM
            AND TRAN_AMOUNT <> 0 
            AND TRAN_NARR_DTL1 IN
                   ('TDS Deduction On Interest Earned', 'TDS On Interest')
            AND (ACNTS_BRN_CODE, TRAN_INTERNAL_ACNUM, TRAN_DATE_OF_TRAN) NOT IN
                   (SELECT DEPIA_BRN_CODE,
                           DEPIA_INTERNAL_ACNUM,
                           DEPIA_DATE_OF_ENTRY
                      FROM DEPIA
                     WHERE     DEPIA_ENTITY_NUM = 1
                           AND DEPIA_BRN_CODE = ACNTS_BRN_CODE
                           AND DEPIA_CONTRACT_NUM = 1
                           AND DEPIA_ENTRY_TYPE = 'TD')
   ORDER BY TRAN_INTERNAL_ACNUM, TRAN_DATE_OF_TRAN ;
  


INSERT INTO DEPIA
     SELECT ACNTS_ENTITY_NUM DEPIA_ENTITY_NUM,
            ACNTS_BRN_CODE DEPIA_BRN_CODE,
            ACNTS_INTERNAL_ACNUM DEPIA_INTERNAL_ACNUM,
            PBDCONT_CONT_NUM DEPIA_CONTRACT_NUM,
            0 DEPIA_AUTO_ROLLOVER_SL,
            TRAN_DATE_OF_TRAN DEPIA_DATE_OF_ENTRY,
              NVL (
                 (SELECT MAX (DEPIA_DAY_SL)
                    FROM DEPIA
                   WHERE     DEPIA_ENTITY_NUM = ACNTS_ENTITY_NUM
                         AND DEPIA_BRN_CODE = ACNTS_BRN_CODE
                         AND DEPIA_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
                         AND DEPIA_CONTRACT_NUM = PBDCONT_CONT_NUM
                         AND DEPIA_AUTO_ROLLOVER_SL = 0
                         AND DEPIA_DATE_OF_ENTRY = TRAN_DATE_OF_TRAN),
                 0)
            + 1
               DEPIA_DAY_SL,
            TRAN_AMOUNT DEPIA_AC_INT_ACCR_AMT,
            'D' DEPIA_INT_ACCR_DB_CR,
            TRAN_AMOUNT DEPIA_BC_INT_ACCR_AMT,
            0 DEPIA_AC_FULL_INT_ACCR_AMT,
            0 DEPIA_BC_FULL_INT_ACCR_AMT,
            0 DEPIA_AC_PREV_INT_ACCR_AMT,
            0 DEPIA_BC_PREV_INT_ACCR_AMT,
            ADD_MONTHS (TRAN_DATE_OF_TRAN, -12) DEPIA_ACCR_FROM_DATE,
            TRAN_DATE_OF_TRAN - 1 DEPIA_ACCR_UPTO_DATE,
            'TD' DEPIA_ENTRY_TYPE,
            TRAN_ENTD_BY DEPIA_ACCR_POSTED_BY,
            TRUNC (TRAN_ENTD_ON) DEPIA_ACCR_POSTED_ON,
            NULL DEPIA_LAST_MOD_BY,
            NULL DEPIA_LAST_MOD_ON,
            'PKG_DEP_INT_APPLY' DEPIA_SOURCE_TABLE,
            NULL DEPIA_SOURCE_KEY,
            0 DEPIA_PREV_YR_INT_ACCR
       FROM ACNTS,
            DEPPROD,
            TRAN2019,
            PBDCONTRACT
      WHERE     DEPPR_TYPE_OF_DEP = '2'
            AND ACNTS_ENTITY_NUM = 1
            AND ACNTS_CLOSURE_DATE IS NULL
            AND ACNTS_PROD_CODE = DEPPR_PROD_CODE
            --AND ACNTS_BRN_CODE = 1016
            AND ACNTS_INTERNAL_ACNUM = TRAN_INTERNAL_ACNUM
            AND TRAN_ENTITY_NUM = 1
            AND PBDCONT_ENTITY_NUM = 1
            AND PBDCONT_BRN_CODE = ACNTS_BRN_CODE
            AND PBDCONT_DEP_AC_NUM = TRAN_INTERNAL_ACNUM
            AND TRAN_AMOUNT <> 0 
            AND TRAN_NARR_DTL1 IN
                   ('TDS Deduction On Interest Earned', 'TDS On Interest')
            AND (ACNTS_BRN_CODE, TRAN_INTERNAL_ACNUM, TRAN_DATE_OF_TRAN) NOT IN
                   (SELECT DEPIA_BRN_CODE,
                           DEPIA_INTERNAL_ACNUM,
                           DEPIA_DATE_OF_ENTRY
                      FROM DEPIA
                     WHERE     DEPIA_ENTITY_NUM = 1
                           AND DEPIA_BRN_CODE = ACNTS_BRN_CODE
                           AND DEPIA_CONTRACT_NUM = 1
                           AND DEPIA_ENTRY_TYPE = 'TD')
   ORDER BY TRAN_INTERNAL_ACNUM, TRAN_DATE_OF_TRAN ;
  