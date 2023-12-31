CREATE OR REPLACE FUNCTION FN_GET_SND_INT_RATE (
   P_ENTITY_NO   IN SBCAIA.SBCAIA_ENTITY_NUM%TYPE,
   P_BRN_CD      IN SBCAIA.SBCAIA_BRN_CODE%TYPE,
   P_INT_ACNUM   IN IACLINK.IACLINK_INTERNAL_ACNUM%TYPE,
   P_DR_CR_FLG   IN SBCAIA.SBCAIA_CR_DB_INT_FLG%TYPE := 'C',
   P_ASON_DATE   IN SBCAIA.SBCAIA_DATE_OF_ENTRY%TYPE)
   RETURN PKG_COMMON_TYPES.int_rate
IS
   W_SND_INT_RATE   PKG_COMMON_TYPES.int_rate := 0.0;
BEGIN
   SELECT NVL (MAX (SBCAIA_INT_RATE), 0)
     INTO W_SND_INT_RATE
     FROM SBCAIA SB
    WHERE     SB.SBCAIA_ENTITY_NUM = P_ENTITY_NO
          AND SB.SBCAIA_BRN_CODE = P_BRN_CD
          AND SB.SBCAIA_INTERNAL_ACNUM = P_INT_ACNUM
          AND SB.SBCAIA_CR_DB_INT_FLG = P_DR_CR_FLG
          AND SB.SBCAIA_INT_ACCR_DB_CR = P_DR_CR_FLG
          AND SB.SBCAIA_DATE_OF_ENTRY =
                 (SELECT MAX (SBCAIA_DATE_OF_ENTRY)
                    FROM SBCAIA
                   WHERE     SB.SBCAIA_ENTITY_NUM = P_ENTITY_NO
                         AND SB.SBCAIA_BRN_CODE = P_BRN_CD
                         AND SBCAIA_INTERNAL_ACNUM = P_INT_ACNUM
                         AND SB.SBCAIA_CR_DB_INT_FLG = P_DR_CR_FLG
                         AND SB.SBCAIA_INT_ACCR_DB_CR = P_DR_CR_FLG
                         AND SBCAIA_DATE_OF_ENTRY <= P_ASON_DATE);
RETURN W_SND_INT_RATE;
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      W_SND_INT_RATE := 0.0;
      --- Added by rajib.pradhan for handle multiple rows which was raise on 11/01/2015 for grnerat SBS reports
      --- Removed by Fahim.Ahmad(this part is repaced to the main pl/sql block)
RETURN W_SND_INT_RATE;
END;

/
