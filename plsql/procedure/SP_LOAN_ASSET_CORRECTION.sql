CREATE OR REPLACE PROCEDURE SP_LOAN_ASSET_CORRECTION (
   P_ENTITY_NUM        NUMBER,
   P_AC_NUM            VARCHAR2,
   P_NEW_ASSET_CODE    VARCHAR2,
   P_EFFECTIVE_DATE    DATE,
   P_EXAMPION_DATE     DATE,
   P_NARRATION VARCHAR2 )
AS
   P_INT_AC_NUM    NUMBER (14);
   P_BRN_CODE      NUMBER (6);
   V_MRR_ACCRUAL   NUMBER (18, 3);
   V_ERROR_MSG     VARCHAR2 (1000);
   
/*
Author : sabuj
Purpose: Update asset code
*/
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

   MERGE INTO ASSETCLS S1
        USING (SELECT P_ENTITY_NUM P_ENTITY_NUM,
                      P_INT_AC_NUM P_INT_AC_NUM,
                      P_EFFECTIVE_DATE P_EFFECTIVE_DATE,
                      P_NEW_ASSET_CODE P_NEW_ASSET_CODE,
                      P_EXAMPION_DATE P_EXAMPION_DATE,
                       P_NARRATION P_NARRATION
                 FROM DUAL) S2
           ON (S1.ASSETCLS_INTERNAL_ACNUM = S2.P_INT_AC_NUM)
   WHEN MATCHED
   THEN
      UPDATE SET
         S1.ASSETCLS_LATEST_EFF_DATE = S2.P_EFFECTIVE_DATE,
         S1.ASSETCLS_ASSET_CODE = S2.P_NEW_ASSET_CODE,
         S1.ASSETCLS_EXEMPT_END_DATE = S2.P_EXAMPION_DATE,
         S1.ASSETCLS_AUTO_MAN_FLG='M',
         ASSETCLS_REMARKS=P_NARRATION
         
   WHEN NOT MATCHED
   THEN
      INSERT     (ASSETCLS_ENTITY_NUM,
                  ASSETCLS_INTERNAL_ACNUM,
                  ASSETCLS_LATEST_EFF_DATE,
                  ASSETCLS_ASSET_CODE,
                  ASSETCLS_NPA_DATE,
                  ASSETCLS_AUTO_MAN_FLG,
                  ASSETCLS_REMARKS,
                  ASSETCLS_EXEMPT_END_DATE)
          VALUES (S2.P_ENTITY_NUM,
                  S2.P_INT_AC_NUM,
                  S2.P_EFFECTIVE_DATE,
                  P_NEW_ASSET_CODE,
                  P_EFFECTIVE_DATE,
                  'M',
                  P_NARRATION,
                  P_EXAMPION_DATE);



   MERGE INTO ASSETCLSHIST A
        USING (SELECT P_ENTITY_NUM P_ENTITY_NUM,
                      P_INT_AC_NUM P_INT_AC_NUM,
                      P_EFFECTIVE_DATE P_EFFECTIVE_DATE,
                      P_NEW_ASSET_CODE P_NEW_ASSET_CODE,
                        P_EXAMPION_DATE P_EXAMPION_DATE,
                        P_NARRATION P_NARRATION
                 FROM DUAL) B
           ON (    A.ASSETCLSH_INTERNAL_ACNUM = B.P_INT_AC_NUM
               AND A.ASSETCLSH_EFF_DATE = B.P_EFFECTIVE_DATE)
   WHEN MATCHED
   THEN
      UPDATE SET A.ASSETCLSH_ASSET_CODE = B.P_NEW_ASSET_CODE,
      ASSETCLSH_EXEMPT_END_DATE=b.P_EXAMPION_DATE,
      ASSETCLSH_PURPOSE_FLAG='2',
      ASSETCLSH_AUTO_MAN_FLG='M',
     ASSETCLSH_REMARKS= P_NARRATION
   WHEN NOT MATCHED
   THEN
      INSERT     (ASSETCLSH_ENTITY_NUM,
                  ASSETCLSH_INTERNAL_ACNUM,
                  ASSETCLSH_EFF_DATE,
                  ASSETCLSH_ASSET_CODE,
                  ASSETCLSH_NPA_DATE,
                  ASSETCLSH_AUTO_MAN_FLG,
                  ASSETCLSH_REMARKS,
                  ASSETCLSH_ENTD_BY,
                  ASSETCLSH_ENTD_ON,
                  ASSETCLSH_LAST_MOD_BY,
                  ASSETCLSH_LAST_MOD_ON,
                  ASSETCLSH_AUTH_BY,
                  ASSETCLSH_AUTH_ON,
                  TBA_MAIN_KEY,
                  ASSETCLSH_PURPOSE_FLAG,
                  ASSETCLSH_EXEMPT_END_DATE)
          VALUES (B.P_ENTITY_NUM,
                  B.P_INT_AC_NUM,
                  B.P_EFFECTIVE_DATE,
                  P_NEW_ASSET_CODE,
                  B.P_EFFECTIVE_DATE,
                  'M',
                  P_NARRATION,
                  'INTELECT',
                  SYSDATE,
                  NULL,
                  NULL,
                  'INTELECT',
                  SYSDATE,
                  '',
                  '2',
                  P_EXAMPION_DATE);
                  
                                       
   DELETE FROM ASSETCLSHIST WHERE ASSETCLSH_ENTITY_NUM = 1  AND ASSETCLSH_INTERNAL_ACNUM = P_INT_AC_NUM AND ASSETCLSH_EFF_DATE > P_EFFECTIVE_DATE ;
   
 EXCEPTION
   WHEN OTHERS
   THEN
      V_ERROR_MSG := SQLERRM;
END;
/
