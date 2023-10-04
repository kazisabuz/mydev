/* Formatted on 7/12/2023 11:24:10 AM (QP5 v5.388) */
------CL CODE-------------

BEGIN
    FOR idx
        IN (SELECT IACLINK_INTERNAL_ACNUM, NON_COM_ACC ACNO_1
              FROM acc5, iaclink
             WHERE IACLINK_ENTITY_NUM = 1 AND IACLINK_ACTUAL_ACNUM = acc_no)
    LOOP
        UPDATE lnacmis
           SET LNACMIS_HO_DEPT_CODE = idx.ACNO_1
         WHERE LNACMIS_INTERNAL_ACNUM = idx.IACLINK_INTERNAL_ACNUM;

        UPDATE lnacmishist
           SET LNACMISH_HO_DEPT_CODE = idx.ACNO_1
         WHERE     LNACMISH_INTERNAL_ACNUM = idx.IACLINK_INTERNAL_ACNUM
               AND LNACMISH_ENTITY_NUM = 1
               AND LNACMISH_EFF_DATE =
                   (SELECT MAX (LNACMISH_EFF_DATE)
                     FROM lnacmishist ms
                    WHERE ms.LNACMISH_INTERNAL_ACNUM =
                          idx.IACLINK_INTERNAL_ACNUM);
    END LOOP;
END;
-----------MIS CODE----------------

INSERT INTO LNACMIS
    SELECT 1                          LNACMIS_ENTITY_NUM,
           IACLINK_INTERNAL_ACNUM     LNACMIS_INTERNAL_ACNUM,
           '30-may-2021'              LNACMIS_LATEST_EFF_DATE,
           '911000'                   LNACMIS_SEGMENT_CODE,
           'CL24'                     LNACMIS_HO_DEPT_CODE,
           ''                         LNACMIS_INDUS_CODE,
           NULL                       LNACMIS_SUB_INDUS_CODE,
           NULL                       LNACMIS_BSR_ACT_OCC_CODE,
           NULL                       LNACMIS_BSR_MAIN_ORG_CODE,
           NULL                       LNACMIS_BSR_SUB_ORG_CODE,
           NULL                       LNACMIS_BSR_STATE_CODE,
           NULL                       LNACMIS_BSR_DISTRICT_CODE,
           99                         LNACMIS_NATURE_BORROWAL_AC,
           NULL                       LNACMIS_POP_GROUP_CODE,
           43                         LNACMIS_PURPOSE_CODE,
           0                          LNACMIS_PROD_WITH_ETP,
           0                          LNACMIS_PROD_WITHOUT_ETP,
           NULL                       LNACMIS_CROPCODE,
           64                         LNACMIS_SEC_TYPE
      FROM iaclink
     WHERE     IACLINK_ENTITY_NUM = 1
           AND IACLINK_ACTUAL_ACNUM IN ('0003443001564',
                                        '0111543001075',
                                        '0003443001562',
                                        '0111543001076');



INSERT INTO LNACMISHIST
    SELECT LNACMIS_ENTITY_NUM             LNACMISH_ENTITY_NUM,
           LNACMIS_INTERNAL_ACNUM         LNACMISH_INTERNAL_ACNUM,
           LNACMIS_LATEST_EFF_DATE        LNACMISH_EFF_DATE,
           LNACMIS_SEGMENT_CODE           LNACMISH_SEGMENT_CODE,
           LNACMIS_HO_DEPT_CODE           LNACMISH_HO_DEPT_CODE,
           LNACMIS_INDUS_CODE             LNACMISH_INDUS_CODE,
           LNACMIS_SUB_INDUS_CODE         LNACMISH_SUB_INDUS_CODE,
           LNACMIS_BSR_ACT_OCC_CODE       LNACMISH_BSR_ACT_OCC_CODE,
           LNACMIS_BSR_MAIN_ORG_CODE      LNACMISH_BSR_MAIN_ORG_CODE,
           LNACMIS_BSR_SUB_ORG_CODE       LNACMISH_BSR_SUB_ORG_CODE,
           LNACMIS_BSR_STATE_CODE         LNACMISH_BSR_STATE_CODE,
           LNACMIS_BSR_DISTRICT_CODE      LNACMISH_BSR_DISTRICT_CODE,
           LNACMIS_NATURE_BORROWAL_AC     LNACMISH_NATURE_BORROWAL_AC,
           LNACMIS_POP_GROUP_CODE         LNACMISH_POP_GROUP_CODE,
           'INTELECT'                     LNACMIS_ENTD_BY,
           SYSDATE                        LNACMIS_ENTD_ON,
           NULL                           LNACMIS_LAST_MOD_BY,
           NULL                           LNACMIS_LAST_MOD_ON,
           'INTELECT'                     LNACMISH_AUTH_BY,
           SYSDATE                        LNACMISH_AUTH_ON,
           NULL                           TBA_MAIN_KEY,
           LNACMIS_PURPOSE_CODE           LNACMISH_PURPOSE_CODE,
           LNACMIS_PROD_WITH_ETP          LNACMISH_PROD_WITH_ETP,
           LNACMIS_PROD_WITHOUT_ETP       LNACMISH_PROD_WITHOUT_ETP,
           LNACMIS_CROPCODE               LNACMISH_CROPCODE,
           LNACMIS_SEC_TYPE               LNACMISH_SEC_TYPE
      FROM LNACMIS
     WHERE     LNACMIS_ENTITY_NUM = 1
           AND LNACMIS_INTERNAL_ACNUM IN (10003400011852,
                                          10003400011855,
                                          10111500056880,
                                          10111500056933);



INSERT INTO LNACMIS
    SELECT 1                               LNACMIS_ENTITY_NUM,
           LNACMISH_INTERNAL_ACNUM         LNACMIS_INTERNAL_ACNUM,
           LNACMISH_EFF_DATE               LNACMIS_LATEST_EFF_DATE,
           LNACMISH_SEGMENT_CODE           LNACMIS_SEGMENT_CODE,
           LNACMISH_HO_DEPT_CODE           LNACMIS_HO_DEPT_CODE,
           LNACMISH_INDUS_CODE             LNACMIS_INDUS_CODE,
           LNACMISH_SUB_INDUS_CODE         LNACMIS_SUB_INDUS_CODE,
           LNACMISH_BSR_ACT_OCC_CODE       LNACMIS_BSR_ACT_OCC_CODE,
           LNACMISH_BSR_MAIN_ORG_CODE      LNACMIS_BSR_MAIN_ORG_CODE,
           LNACMISH_BSR_SUB_ORG_CODE       LNACMIS_BSR_SUB_ORG_CODE,
           LNACMISH_BSR_STATE_CODE         LNACMIS_BSR_STATE_CODE,
           NULL                            LNACMIS_BSR_DISTRICT_CODE,
           LNACMISH_NATURE_BORROWAL_AC     LNACMIS_NATURE_BORROWAL_AC,
           NULL                            LNACMIS_POP_GROUP_CODE,
           LNACMISH_PURPOSE_CODE           LNACMIS_PURPOSE_CODE,
           LNACMISH_PROD_WITH_ETP          LNACMIS_PROD_WITH_ETP,
           LNACMISH_PROD_WITHOUT_ETP       LNACMIS_PROD_WITHOUT_ETP,
           LNACMISH_CROPCODE               LNACMIS_CROPCODE,
           LNACMISH_SEC_TYPE               LNACMIS_SEC_TYPE
      FROM LNACMISHIST
     WHERE     LNACMISH_ENTITY_NUM = 1
           AND LNACMISH_INTERNAL_ACNUM IN ('14204400024199');