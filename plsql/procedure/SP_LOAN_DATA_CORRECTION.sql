CREATE OR REPLACE PROCEDURE SP_LOAN_DATA_CORRECTION (
   P_ENTITY_NUM        NUMBER,
   P_AC_NUM            VARCHAR2,
   P_NEW_INT_RATE      NUMBER,
   P_EFFECTIVE_DATE    DATE)
AS
   P_INT_AC_NUM    NUMBER (14);
   P_BRN_CODE      NUMBER (6);
   V_MRR_ACCRUAL   NUMBER (18, 3);
   V_ERROR_MSG     VARCHAR2 (1000);
BEGIN
   BEGIN
      SELECT IACLINK_INTERNAL_ACNUM, IACLINK_BRN_CODE
        INTO P_INT_AC_NUM, P_BRN_CODE
        FROM IACLINK
       WHERE     IACLINK_ENTITY_NUM = P_ENTITY_NUM
             AND IACLINK_ACTUAL_ACNUM = P_AC_NUM;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         V_ERROR_MSG := 'Account does not exist';
   END;


   --<<INTEREST_RATE_UPDATE_BLOCK>>
   BEGIN
      MERGE INTO LNACIR s1
           USING (SELECT P_ENTITY_NUM P_ENTITY_NUM,
                         P_INT_AC_NUM P_INT_AC_NUM,
                         P_EFFECTIVE_DATE P_EFFECTIVE_DATE,
                         P_NEW_INT_RATE P_NEW_INT_RATE
                    FROM DUAL) s2
              ON (s1.LNACIR_INTERNAL_ACNUM = s2.P_INT_AC_NUM)
      WHEN MATCHED
      THEN
         UPDATE SET
            s1.LNACIR_LATEST_EFF_DATE = S2.P_EFFECTIVE_DATE,
            S1.LNACIR_APPL_INT_RATE = S2.P_NEW_INT_RATE
      WHEN NOT MATCHED
      THEN
         INSERT     (LNACIR_ENTITY_NUM,
                     LNACIR_INTERNAL_ACNUM,
                     LNACIR_LATEST_EFF_DATE,
                     LNACIR_AMT_SLABS_REQD,
                     LNACIR_SLAB_APPL_CHOICE,
                     LNACIR_APPL_INT_RATE,
                     LNACIR_BACK_DATED_ENTRY,
                     LNACIR_REMARKS1,
                     LNACIR_REMARKS2,
                     LNACIR_REMARKS3)
             VALUES (s2.P_ENTITY_NUM,
                     s2.P_INT_AC_NUM,
                     S2.P_EFFECTIVE_DATE,
                     '0',
                     '1',
                     S2.P_NEW_INT_RATE,
                     '0',
                     'Interest rate changed on request',
                     'Of Bank',
                     'HO 886');


      MERGE INTO LNACIRS s1
           USING (SELECT P_ENTITY_NUM P_ENTITY_NUM,
                         P_INT_AC_NUM P_INT_AC_NUM,
                         P_EFFECTIVE_DATE P_EFFECTIVE_DATE, 
                         P_NEW_INT_RATE P_NEW_INT_RATE
                    FROM DUAL) s2
              ON (s1.LNACIRS_INTERNAL_ACNUM = s2.P_INT_AC_NUM)
      WHEN MATCHED
      THEN
         UPDATE SET
            s1.LNACIRS_LATEST_EFF_DATE = S2.P_EFFECTIVE_DATE,
            S1.LNACIRS_AC_LEVEL_INT_REQD = '1'
      WHEN NOT MATCHED
      THEN
         INSERT     (LNACIRS_ENTITY_NUM,
                     LNACIRS_INTERNAL_ACNUM,
                     LNACIRS_LATEST_EFF_DATE,
                     LNACIRS_AC_LEVEL_INT_REQD,
                     LNACIRS_FIXED_FLOATING_RATE,
                     LNACIRS_DIFF_INT_RATE_CHOICE,
                     LNACIRS_DIFF_INT_RATE,
                     LNACIRS_TENOR_SLAB_SL,
                     LNACIRS_AMT_SLAB_SL,
                     LNACIRS_OVERDUE_INT_APPLICABLE,
                     LNACIRS_REMARKS1,
                     LNACIRS_REMARKS2,
                     LNACIRS_REMARKS3,
                     LNACIRS_PENAL_INT_RATE)
             VALUES (S2.P_ENTITY_NUM,
                     s2.P_INT_AC_NUM,
                     S2.P_EFFECTIVE_DATE,
                     '1',
                     '1',
                     '0',
                     0,
                     0,
                     0,
                     '1',
                     'Interest rate changed on request',
                     'Of Bank',
                     'HO 886',
                     0);


      MERGE INTO LNACIRHIST s1
           USING (SELECT P_ENTITY_NUM P_ENTITY_NUM,
                         P_INT_AC_NUM P_INT_AC_NUM,
                         P_EFFECTIVE_DATE P_EFFECTIVE_DATE,
                         P_NEW_INT_RATE P_NEW_INT_RATE
                    FROM DUAL) s2
              ON (    s1.LNACIRH_INTERNAL_ACNUM = s2.P_INT_AC_NUM
                  AND s1.LNACIRH_EFF_DATE = s2.P_EFFECTIVE_DATE)
      WHEN MATCHED
      THEN
         UPDATE SET S1.LNACIRH_APPL_INT_RATE = s2.P_NEW_INT_RATE
      WHEN NOT MATCHED
      THEN
         INSERT     (LNACIRH_ENTITY_NUM,
                     LNACIRH_INTERNAL_ACNUM,
                     LNACIRH_EFF_DATE,
                     LNACIRH_AMT_SLABS_REQD,
                     LNACIRH_SLAB_APPL_CHOICE,
                     LNACIRH_APPL_INT_RATE,
                     LNACIRH_BACK_DATED_ENTRY,
                     LNACIRH_REMARKS1,
                     LNACIRH_REMARKS2,
                     LNACIRH_REMARKS3,
                     LNACIRH_ENTD_BY,
                     LNACIRH_ENTD_ON,
                     LNACIRH_LAST_MOD_BY,
                     LNACIRH_AUTH_BY,
                     LNACIRH_AUTH_ON)
             VALUES (S2.P_ENTITY_NUM,
                     s2.P_INT_AC_NUM,
                     s2.P_EFFECTIVE_DATE,
                     '0',
                     '1',
                     s2.P_NEW_INT_RATE,
                     '0',
                     'Interest rate changed on request',
                     'Of Bank',
                     'HO 886',
                     'INTELECT',
                     SYSDATE,
                     ' ',
                     'INTELECT',
                     SYSDATE);



      MERGE INTO LNACIRSHIST s1  
           USING (SELECT P_ENTITY_NUM P_ENTITY_NUM,
                         P_INT_AC_NUM P_INT_AC_NUM,
                         P_EFFECTIVE_DATE P_EFFECTIVE_DATE
                    FROM DUAL) s2
              ON (    s1.LNACIRSH_INTERNAL_ACNUM = s2.P_INT_AC_NUM
                  AND s1.LNACIRSH_EFF_DATE = s2.P_EFFECTIVE_DATE)
      WHEN MATCHED
      THEN
         UPDATE SET S1.LNACIRSH_AC_LEVEL_INT_REQD = '1'
      WHEN NOT MATCHED
      THEN
         INSERT     (LNACIRSH_ENTITY_NUM,
                     LNACIRSH_INTERNAL_ACNUM,
                     LNACIRSH_EFF_DATE,
                     LNACIRSH_AC_LEVEL_INT_REQD,
                     LNACIRSH_FIXED_FLOATING_RATE,
                     LNACIRSH_DIFF_INT_RATE_CHOICE,
                     LNACIRSH_DIFF_INT_RATE,
                     LNACIRSH_TENOR_SLAB_SL,
                     LNACIRSH_AMT_SLAB_SL,
                     LNACIRSH_OD_INT_APPLICABLE,
                     LNACIRSH_REMARKS1,
                     LNACIRSH_REMARKS2,
                     LNACIRSH_REMARKS3,
                     LNACIRSH_ENTD_BY,
                     LNACIRSH_ENTD_ON,
                     LNACIRSH_LAST_MOD_BY,
                     LNACIRSH_AUTH_BY,
                     LNACIRSH_AUTH_ON,
                     LNACIRSH_PENAL_INT_RATE)
             VALUES (S2.P_ENTITY_NUM,
                     s2.P_INT_AC_NUM,
                     s2.P_EFFECTIVE_DATE,
                     '1',
                     '1',
                     '0',
                     0,
                     0,
                     0,
                     '1',
                     'Interest rate changed on request',
                     'Of Bank',
                     'HO 886',
                     'INTELECT',
                     SYSDATE,
                     ' ',
                     'INTELECT',
                     SYSDATE,
                     0);
                     
   DELETE FROM LNACIRHIST WHERE LNACIRH_ENTITY_NUM = 1  AND LNACIRH_INTERNAL_ACNUM = P_INT_AC_NUM AND LNACIRH_EFF_DATE > P_EFFECTIVE_DATE ;
   
   DELETE FROM LNACIRSHIST WHERE LNACIRSH_ENTITY_NUM = 1 AND LNACIRSH_INTERNAL_ACNUM = P_INT_AC_NUM AND LNACIRSH_EFF_DATE > P_EFFECTIVE_DATE ;
   
   EXCEPTION
      WHEN OTHERS
      THEN
         V_ERROR_MSG := SQLERRM;
   END;
END SP_LOAN_DATA_CORRECTION;
/
