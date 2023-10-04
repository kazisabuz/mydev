CREATE OR REPLACE FUNCTION FN_GET_LEAN_AVG_BAL (
   P_ENTITY_NUM    NUMBER,
   P_AC_NUM        NUMBER,
   P_FROM_DATE     DATE,
   P_TO_DATE       DATE)
   RETURN NUMBER
AS
   V_AVG_BAL         NUMBER := 0;
   V_ERRM            VARCHAR2 (1000);
   V_NO_OF_DAYS      NUMBER;
   V_TOTAL_BALANCE   NUMBER;
   V_AVG_BALANCE     NUMBER (18, 3);
   V_NOD             NUMBER;
BEGIN
   V_NOD := (P_TO_DATE - P_FROM_DATE) + 1;

   FOR ACNT
      IN (SELECT ACNTS_ENTITY_NUM,
                 ACNTLIEN_INTERNAL_ACNUM,
                 ACNTLIEN_LIEN_TO_ACNUM
            FROM ACNTLIEN, ACNTS, LNPRODPM
           WHERE     ACNTS_ENTITY_NUM = ACNTLIEN_ENTITY_NUM
                 AND ACNTS_INTERNAL_ACNUM = ACNTLIEN_INTERNAL_ACNUM
                 AND LNPRD_PROD_CODE = ACNTS_PROD_CODE
                 AND LNPRD_INT_FREE_LOANS = '1'
                 AND ACNTLIEN_ENTITY_NUM = P_ENTITY_NUM
                 AND ACNTLIEN_INTERNAL_ACNUM = P_AC_NUM
                 AND ACNTLIEN_REVOKED_ON IS NULL)
   LOOP
      IF ACNT.ACNTLIEN_LIEN_TO_ACNUM <> 0
      THEN
         SP_GET_AVG_DETAIL (ACNT.ACNTS_ENTITY_NUM,
                            ACNT.ACNTLIEN_LIEN_TO_ACNUM,
                            P_FROM_DATE,
                            P_TO_DATE,
                            V_NO_OF_DAYS,
                            V_TOTAL_BALANCE,
                            V_AVG_BALANCE);
         V_AVG_BAL := V_AVG_BAL + ( (V_AVG_BALANCE * V_NO_OF_DAYS) / V_NOD);
      END IF;
   END LOOP;

   RETURN V_AVG_BAL;
EXCEPTION
   WHEN OTHERS
   THEN
      V_ERRM := SQLERRM;
      RETURN 0;
END FN_GET_LEAN_AVG_BAL;
/