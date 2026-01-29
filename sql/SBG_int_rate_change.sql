/*Interest rate change for a particular GL for the inter branch interest calculation. All the impacts we considered and managed here.*/

DELETE FROM AUTOPOST_TRAN ;


INSERT INTO AUTOPOST_TRAN
  SELECT DENSE_RANK () OVER (ORDER BY TRAN_BRN_CODE) BATCH_SL,
         ROW_NUMBER () OVER (PARTITION BY TRAN_BRN_CODE ORDER BY TRAN_BRN_CODE) LEG_SL,
         null TRAN_DATE,
         null VALUE_DATE,
         null SUPP_TRAN,
         TRAN_BRN_CODE BRN_CODE,
         TRAN_BRN_CODE ACING_BRN_CODE,
         DECODE (TRAN_DB_CR_FLG, 'C', 'D','C')DR_CR,
         TRAN_GLACC_CODE GLACC_CODE,
         NULL INT_AC_NO,
         NULL CONT_NO,
         TRAN_CURR_CODE CURR_CODE,
         TRAN_AMOUNT AC_AMOUNT,
         TRAN_AMOUNT BC_AMOUNT,
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
         'SBG interest change | reversal | October and November | mail: November 30, 2020 07:41PM' LEG_NARRATION,
         'SBG interest change | reversal | October and November | mail: November 30, 2020 07:41PM' BATCH_NARRATION,
         'INTELECT' USER_ID,
         NULL TERMINAL_ID,
         NULL PROCESSED,
         NULL BATCH_NO,
         NULL ERR_MSG,
         NULL DEPT_CODE
    FROM   TRAN2020
 WHERE     TRAN_ENTITY_NUM = 1
       AND (TRAN_BRN_CODE, TRAN_DATE_OF_TRAN, TRAN_BATCH_NUMBER) IN (SELECT POST_TRAN_BRN,
                                                                            POST_TRAN_DATE,
                                                                            POST_TRAN_BATCH_NUM
                                                                       FROM IBRNINTCALC
                                                                      WHERE     IBRNINTCALC_ENTITY_NUM =
                                                                                   1
                                                                            AND IBRNINTCALC_BRN_CODE IN (13383, 13409, 13391, 38117 , 39057 , 39065 )
                                                                            AND IBRNINTCALC_PROC_DATE IN ('31-OCT-2020', '30-NOV-2020'));
                                                                            
                                                                            
DELETE FROM IBRINTPOSTCTL WHERE IBRINTPOSTCTL_ENTITY_NUM = 1
AND IBRINTPOSTCTL_BRN_CODE IN (13383, 13409, 13391, 38117 , 39057 , 39065 )
AND IBRINTPOSTCTL_PROC_DATE = TO_DATE('11/30/2020 00:00:00', 'MM/DD/YYYY HH24:MI:SS');


DELETE FROM IBRNINTCALC WHERE IBRNINTCALC_ENTITY_NUM = 1
AND IBRNINTCALC_BRN_CODE IN (13383, 13409, 13391, 38117 , 39057 , 39065 )
AND IBRNINTCALC_PROC_DATE = TO_DATE('11/30/2020 00:00:00', 'MM/DD/YYYY HH24:MI:SS');


DELETE FROM IBRNINTCALCDTL WHERE IBRNICDTL_ENTITY_NUM = 1
AND IBRNICDTL_BRN_CODE IN (13383, 13409, 13391, 38117 , 39057 , 39065 )
AND IBRNICDTL_PROC_DATE = TO_DATE('11/30/2020 00:00:00', 'MM/DD/YYYY HH24:MI:SS');


EXEC SP_AUTO_SCRIPT_TRAN  ;




DECLARE
   V_BRN_CODE   NUMBER := 39065;
   V_CR_RATE    NUMBER (8, 5) := 5;
   V_DR_RATE    NUMBER (8, 5) := 6.5;
BEGIN
   INSERT INTO GLINT (GLINT_ENTITY_NUM,
                      GLINT_BRN_CODE,
                      GLINT_GLACC_CODE,
                      GLINT_CURR_CODE,
                      GLINT_LATEST_EFF_DATE,
                      GLINT_INT_RATE_CR_BAL,
                      GLINT_INT_RATE_DB_BAL)
        VALUES (1,
                V_BRN_CODE,
                '216101101',
                'BDT',
                TO_DATE ('10/01/2020 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
                V_CR_RATE,
                V_DR_RATE);

   INSERT INTO GLINT (GLINT_ENTITY_NUM,
                      GLINT_BRN_CODE,
                      GLINT_GLACC_CODE,
                      GLINT_CURR_CODE,
                      GLINT_LATEST_EFF_DATE,
                      GLINT_INT_RATE_CR_BAL,
                      GLINT_INT_RATE_DB_BAL)
        VALUES (1,
                V_BRN_CODE,
                '216101104',
                'BDT',
                TO_DATE ('10/01/2020 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
                V_CR_RATE,
                V_DR_RATE);

   INSERT INTO GLINT (GLINT_ENTITY_NUM,
                      GLINT_BRN_CODE,
                      GLINT_GLACC_CODE,
                      GLINT_CURR_CODE,
                      GLINT_LATEST_EFF_DATE,
                      GLINT_INT_RATE_CR_BAL,
                      GLINT_INT_RATE_DB_BAL)
        VALUES (1,
                V_BRN_CODE,
                '216101107',
                'BDT',
                TO_DATE ('10/01/2020 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
                V_CR_RATE,
                V_DR_RATE);

   INSERT INTO GLINT (GLINT_ENTITY_NUM,
                      GLINT_BRN_CODE,
                      GLINT_GLACC_CODE,
                      GLINT_CURR_CODE,
                      GLINT_LATEST_EFF_DATE,
                      GLINT_INT_RATE_CR_BAL,
                      GLINT_INT_RATE_DB_BAL)
        VALUES (1,
                V_BRN_CODE,
                '216101110',
                'BDT',
                TO_DATE ('10/01/2020 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
                V_CR_RATE,
                V_DR_RATE);

   INSERT INTO GLINT (GLINT_ENTITY_NUM,
                      GLINT_BRN_CODE,
                      GLINT_GLACC_CODE,
                      GLINT_CURR_CODE,
                      GLINT_LATEST_EFF_DATE,
                      GLINT_INT_RATE_CR_BAL,
                      GLINT_INT_RATE_DB_BAL)
        VALUES (1,
                V_BRN_CODE,
                '216101113',
                'BDT',
                TO_DATE ('10/01/2020 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
                V_CR_RATE,
                V_DR_RATE);

   INSERT INTO GLINT (GLINT_ENTITY_NUM,
                      GLINT_BRN_CODE,
                      GLINT_GLACC_CODE,
                      GLINT_CURR_CODE,
                      GLINT_LATEST_EFF_DATE,
                      GLINT_INT_RATE_CR_BAL,
                      GLINT_INT_RATE_DB_BAL)
        VALUES (1,
                V_BRN_CODE,
                '217101101',
                'BDT',
                TO_DATE ('10/01/2020 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
                V_CR_RATE,
                V_DR_RATE);

   COMMIT;



   INSERT INTO GLINTHIST (GLINTHIST_ENTITY_NUM,
                          GLINTHIST_BRN_CODE,
                          GLINTHIST_GLACC_CODE,
                          GLINTHIST_CURR_CODE,
                          GLINTHIST_EFF_DATE,
                          GLINTHIST_INT_RATE_CR_BAL,
                          GLINTHIST_INT_RATE_DB_BAL,
                          GLINTHIST_ENTD_BY,
                          GLINTHIST_ENTD_ON,
                          GLINTHIST_LAST_MOD_BY,
                          GLINTHIST_AUTH_BY,
                          GLINTHIST_AUTH_ON,
                          TBA_MAIN_KEY)
        VALUES (1,
                V_BRN_CODE,
                '216101101',
                'BDT',
                TO_DATE ('10/01/2020 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
                V_CR_RATE,
                V_DR_RATE,
                '40981',
                TO_DATE ('11/30/2020 16:42:19', 'MM/DD/YYYY HH24:MI:SS'),
                ' ',
                '43040',
                TO_DATE ('11/30/2020 16:45:37', 'MM/DD/YYYY HH24:MI:SS'),
                ' ');

   INSERT INTO GLINTHIST (GLINTHIST_ENTITY_NUM,
                          GLINTHIST_BRN_CODE,
                          GLINTHIST_GLACC_CODE,
                          GLINTHIST_CURR_CODE,
                          GLINTHIST_EFF_DATE,
                          GLINTHIST_INT_RATE_CR_BAL,
                          GLINTHIST_INT_RATE_DB_BAL,
                          GLINTHIST_ENTD_BY,
                          GLINTHIST_ENTD_ON,
                          GLINTHIST_LAST_MOD_BY,
                          GLINTHIST_AUTH_BY,
                          GLINTHIST_AUTH_ON,
                          TBA_MAIN_KEY)
        VALUES (1,
                V_BRN_CODE,
                '216101104',
                'BDT',
                TO_DATE ('10/01/2020 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
                V_CR_RATE,
                V_DR_RATE,
                '40981',
                TO_DATE ('11/30/2020 16:43:44', 'MM/DD/YYYY HH24:MI:SS'),
                ' ',
                '43040',
                TO_DATE ('11/30/2020 16:45:47', 'MM/DD/YYYY HH24:MI:SS'),
                ' ');

   INSERT INTO GLINTHIST (GLINTHIST_ENTITY_NUM,
                          GLINTHIST_BRN_CODE,
                          GLINTHIST_GLACC_CODE,
                          GLINTHIST_CURR_CODE,
                          GLINTHIST_EFF_DATE,
                          GLINTHIST_INT_RATE_CR_BAL,
                          GLINTHIST_INT_RATE_DB_BAL,
                          GLINTHIST_ENTD_BY,
                          GLINTHIST_ENTD_ON,
                          GLINTHIST_LAST_MOD_BY,
                          GLINTHIST_AUTH_BY,
                          GLINTHIST_AUTH_ON,
                          TBA_MAIN_KEY)
        VALUES (1,
                V_BRN_CODE,
                '216101107',
                'BDT',
                TO_DATE ('10/01/2020 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
                V_CR_RATE,
                V_DR_RATE,
                '40981',
                TO_DATE ('11/30/2020 16:43:06', 'MM/DD/YYYY HH24:MI:SS'),
                ' ',
                '43040',
                TO_DATE ('11/30/2020 16:45:51', 'MM/DD/YYYY HH24:MI:SS'),
                ' ');

   INSERT INTO GLINTHIST (GLINTHIST_ENTITY_NUM,
                          GLINTHIST_BRN_CODE,
                          GLINTHIST_GLACC_CODE,
                          GLINTHIST_CURR_CODE,
                          GLINTHIST_EFF_DATE,
                          GLINTHIST_INT_RATE_CR_BAL,
                          GLINTHIST_INT_RATE_DB_BAL,
                          GLINTHIST_ENTD_BY,
                          GLINTHIST_ENTD_ON,
                          GLINTHIST_LAST_MOD_BY,
                          GLINTHIST_AUTH_BY,
                          GLINTHIST_AUTH_ON,
                          TBA_MAIN_KEY)
        VALUES (1,
                V_BRN_CODE,
                '216101110',
                'BDT',
                TO_DATE ('10/01/2020 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
                V_CR_RATE,
                V_DR_RATE,
                '40981',
                TO_DATE ('11/30/2020 16:45:10', 'MM/DD/YYYY HH24:MI:SS'),
                ' ',
                '43040',
                TO_DATE ('11/30/2020 16:45:57', 'MM/DD/YYYY HH24:MI:SS'),
                ' ');

   INSERT INTO GLINTHIST (GLINTHIST_ENTITY_NUM,
                          GLINTHIST_BRN_CODE,
                          GLINTHIST_GLACC_CODE,
                          GLINTHIST_CURR_CODE,
                          GLINTHIST_EFF_DATE,
                          GLINTHIST_INT_RATE_CR_BAL,
                          GLINTHIST_INT_RATE_DB_BAL,
                          GLINTHIST_ENTD_BY,
                          GLINTHIST_ENTD_ON,
                          GLINTHIST_LAST_MOD_BY,
                          GLINTHIST_AUTH_BY,
                          GLINTHIST_AUTH_ON,
                          TBA_MAIN_KEY)
        VALUES (1,
                V_BRN_CODE,
                '216101113',
                'BDT',
                TO_DATE ('10/01/2020 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
                V_CR_RATE,
                V_DR_RATE,
                '40981',
                TO_DATE ('11/30/2020 16:44:45', 'MM/DD/YYYY HH24:MI:SS'),
                ' ',
                '43040',
                TO_DATE ('11/30/2020 16:46:00', 'MM/DD/YYYY HH24:MI:SS'),
                ' ');

   INSERT INTO GLINTHIST (GLINTHIST_ENTITY_NUM,
                          GLINTHIST_BRN_CODE,
                          GLINTHIST_GLACC_CODE,
                          GLINTHIST_CURR_CODE,
                          GLINTHIST_EFF_DATE,
                          GLINTHIST_INT_RATE_CR_BAL,
                          GLINTHIST_INT_RATE_DB_BAL,
                          GLINTHIST_ENTD_BY,
                          GLINTHIST_ENTD_ON,
                          GLINTHIST_LAST_MOD_BY,
                          GLINTHIST_AUTH_BY,
                          GLINTHIST_AUTH_ON,
                          TBA_MAIN_KEY)
        VALUES (1,
                V_BRN_CODE,
                '217101101',
                'BDT',
                TO_DATE ('10/01/2020 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
                V_CR_RATE,
                V_DR_RATE,
                '40981',
                TO_DATE ('11/30/2020 16:42:41', 'MM/DD/YYYY HH24:MI:SS'),
                ' ',
                '43040',
                TO_DATE ('11/30/2020 16:46:05', 'MM/DD/YYYY HH24:MI:SS'),
                ' ');

   COMMIT;
END;