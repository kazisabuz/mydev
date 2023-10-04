/* Formatted on 5/31/2023 3:13:19 PM (QP5 v5.388) */
SELECT GMO_BRANCH                                                 GMO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = GMO_BRANCH)    GMO_NAME,
       PO_BRANCH                                                  PO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = PO_BRANCH)     PO_NAME,
       TT.*
  FROM (SELECT MBRN_CODE, MBRN_NAME FROM MBRN) TT, MBRN_TREE
 WHERE TT.MBRN_CODE = BRANCH;

SELECT *
  FROM (SELECT ROWNUM            SL,
               MBRN_CODE         "Office Code",
               MBRN_NAME         "Office Name",
               MBRN_CATEGORY     "Branch Category Code",
               BRNCAT_DESCN      "Branch Category",
               MBRN_BSR_CODE     "SBS Code"
          FROM MBRN, BRNCAT
         WHERE MBRN_CATEGORY = BRNCAT_CODE);

 --------------------

SELECT TT.MBRN_CODE,
       TT.MBRN_NAME,
       BRANCH_GMO                                                 GMO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = BRANCH_GMO)    GMO_NAME,
       BRANCH_PO                                                  PO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = BRANCH_PO)     PO_NAME,
       TT.BRANCH_ADDRESS,
       ROUTING_NUMBER,
       EMAIL_ADDRESS,
       MOBILE,
       PHONE,
       DISTRICT,
       LATITUDE,
       LONGITUDE,
       SWIFTCODE
  FROM (SELECT MBRN_CODE,
               MBRN_NAME,
                  MBRN_ADDR1
               || MBRN_ADDR2
               || MBRN_ADDR3
               || MBRN_ADDR4
               || MBRN_ADDR5                             BRANCH_ADDRESS,
               MBRN_MICR_CODE                            ROUTING_NUMBER,
               MBRN_EMAIL_ADDR1 || MBRN_EMAIL_ADDR2      EMAIL_ADDRESS,
               MBRN_TEL_NO1                              MOBILE,
               MBRN_TEL_NO2                              PHONE,
               (SELECT DISTRICT_NAME
                 FROM LOCATION, DISTRICT
                WHERE     LOCN_DISTRICT_CODE = DISTRICT_CODE
                      AND LOCN_CODE = MBRN_LOCN_CODE)    DISTRICT,
               NULL                                      LATITUDE,
               NULL                                      LONGITUDE,
               MBRN_SWIFT_BIC_CODE                       SWIFTCODE
          FROM MBRN) TT,
       MBRN_TREE2
 WHERE TT.MBRN_CODE = BRANCH_CODE;