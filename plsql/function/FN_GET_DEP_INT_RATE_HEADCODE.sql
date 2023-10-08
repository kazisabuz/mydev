CREATE OR REPLACE FUNCTION FN_GET_DEP_INT_RATE_HEADCODE (
   HEAD_CODE    IN VARCHAR2,
   AS_ON_DATE   IN DATE)
   RETURN VARCHAR2
IS
   INT_RATE   VARCHAR2 (20);
BEGIN
   SELECT CASE
             WHEN TT.MAX_INT_RATE IS NULL AND TT.MIN_INT_RATE IS NULL
             THEN
                NULL
             WHEN TT.MAX_INT_RATE <> TT.MIN_INT_RATE
             THEN
                MIN_INT_RATE || '%'||'-' || TT.MAX_INT_RATE||'%'
             WHEN TT.MAX_INT_RATE = TT.MIN_INT_RATE
             THEN
                TO_CHAR (TT.MIN_INT_RATE)||'%'
             ELSE
                NULL
          END
             INTEREST_RATE
     INTO INT_RATE
     FROM (SELECT MAX (DEPIRHDT_INT_RATE) MAX_INT_RATE,
                  MIN (DEPIRHDT_INT_RATE) MIN_INT_RATE
             FROM (SELECT DD.DEPIRHDT_PROD_CODE,
                          DD.DEPIRHDT_EFF_DATE,
                          DEPIRHDT_INT_RATE
                     FROM RPTHEADGLDTL, PRODUCTS, DEPIRHDT DD
                    WHERE     RPTHDGLDTL_GLACC_CODE = PRODUCT_GLACC_CODE
                          AND PRODUCT_CODE = DD.DEPIRHDT_PROD_CODE
                          AND DD.DEPIRHDT_ENTITY_NUM = 1
                          AND RPTHDGLDTL_CODE = HEAD_CODE
                          AND DD.DEPIRHDT_EFF_DATE =
                                 (SELECT MAX (D.DEPIRHDT_EFF_DATE)
                                    FROM DEPIRHDT D
                                   WHERE     D.DEPIRHDT_ENTITY_NUM = 1
                                         AND D.DEPIRHDT_PROD_CODE =
                                                DD.DEPIRHDT_PROD_CODE
                                         AND D.DEPIRHDT_EFF_DATE <=
                                                AS_ON_DATE))) TT;

   RETURN INT_RATE;
END FN_GET_DEP_INT_RATE_HEADCODE;
/
