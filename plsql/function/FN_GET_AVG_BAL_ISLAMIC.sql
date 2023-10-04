CREATE OR REPLACE FUNCTION FN_GET_AVG_BAL_ISLAMIC (P_ENTITY_NUM   IN NUMBER,
                                                   P_ACC_NUMBER   IN NUMBER,
                                                   P_START_DATE   IN DATE,
                                                   P_END_DATE     IN DATE)
   RETURN NUMBER
IS
   V_AVG_BAL           NUMBER (18, 3);
   V_SQLERRM           VARCHAR2 (3000);
   V_ACNTS_CURR_CODE   VARCHAR2 (10);
   V_ASON_DATE         DATE;
   V_NO_OF_DAYS        NUMBER;
   V_TOTAL_BALANCE     NUMBER;
BEGIN
   IF P_START_DATE = P_END_DATE
   THEN
      V_ASON_DATE := PKG_PB_GLOBAL.FN_GET_CURR_BUS_DATE (P_ENTITY_NUM);

      SELECT ACNTS_CURR_CODE
        INTO V_ACNTS_CURR_CODE
        FROM ACNTS
       WHERE     ACNTS_ENTITY_NUM = P_ENTITY_NUM
             AND ACNTS_INTERNAL_ACNUM = P_ACC_NUMBER;

      V_AVG_BAL :=
         FN_GET_ASON_ACBAL (P_ENTITY_NUM,
                            P_ACC_NUMBER,
                            V_ACNTS_CURR_CODE,
                            P_START_DATE,
                            V_ASON_DATE);
      RETURN V_AVG_BAL;
   END IF;

   SP_GET_AVG_DETAIL (P_ENTITY_NUM,
                      P_ACC_NUMBER,
                      P_START_DATE,
                      P_END_DATE,
                      V_NO_OF_DAYS,
                      V_TOTAL_BALANCE,
                      V_AVG_BAL);

   RETURN V_AVG_BAL;
EXCEPTION
   WHEN OTHERS
   THEN
      V_SQLERRM := SQLERRM;
END;
/