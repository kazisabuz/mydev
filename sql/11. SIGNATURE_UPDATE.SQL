-- CLAMIMAGE

CREATE TABLE CLAMIMAGE_ACTUAL_AC
AS
   SELECT *
     FROM CLAMIMAGE
    WHERE     CLAMIMAGE_ENTITY_NUM = 1
          AND CLAMIMAGE_INTERNAL_ACNUM IN
                 (SELECT IACLINK_INTERNAL_ACNUM FROM ACTUAL_ACCOUNT_UPDATE);

DECLARE
   V_COUNT    NUMBER := 0;
   V_AC_NUM   NUMBER;
BEGIN
   FOR IDX
      IN (  SELECT * FROM ACTUAL_ACCOUNT_UPDATE)
   LOOP
      IF IDX.SL = 1
      THEN
         V_AC_NUM := IDX.IACLINK_INTERNAL_ACNUM;
      END IF;

      UPDATE CLAMIMAGE
         SET CLAMIMAGE_INTERNAL_ACNUM = V_AC_NUM
       WHERE     CLAMIMAGE_ENTITY_NUM = 1
             AND CLAMIMAGE_INTERNAL_ACNUM = IDX.IACLINK_INTERNAL_ACNUM;
   END LOOP;
END;


-- INVSPDOCIMG


CREATE TABLE INVSPDOCIMG_ACTUAL_AC
AS
   SELECT *
     FROM INVSPDOCIMG
    WHERE     SPDOCIMG_INV_NUM = 1
          AND SPDOCIMG_INTERNAL_ACNUM IN
                 (SELECT IACLINK_INTERNAL_ACNUM FROM ACTUAL_ACCOUNT_UPDATE);

DECLARE
   V_COUNT    NUMBER := 0;
   V_AC_NUM   NUMBER;
BEGIN
   FOR IDX
      IN (  SELECT * FROM ACTUAL_ACCOUNT_UPDATE)
   LOOP
      IF IDX.SL = 1
      THEN
         V_AC_NUM := IDX.IACLINK_INTERNAL_ACNUM;
      END IF;

      UPDATE INVSPDOCIMG
         SET SPDOCIMG_INTERNAL_ACNUM = V_AC_NUM
       WHERE  SPDOCIMG_INTERNAL_ACNUM = IDX.IACLINK_INTERNAL_ACNUM;
   END LOOP;
END;