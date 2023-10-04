CREATE OR REPLACE PROCEDURE SP_GEN_BULK_SMS_DATA (p_entity_num   NUMBER,
                                                  p_ason_date    DATE,
                                                  p_from_branh   NUMBER,
                                                  p_to_branch    NUMBER)
AS
BEGIN
    FOR IDX IN (  SELECT *
                    FROM (  SELECT BRANCH_CODE, ROWNUM BRANCH_SL
                              FROM MIG_DETAIL
                          ORDER BY BRANCH_CODE ASC)
                   WHERE BRANCH_SL BETWEEN p_from_branh AND p_to_branch
                ORDER BY BRANCH_CODE)
    LOOP
        PKG_CONSOLIDATE_SMS_DATA.SP_PROC_BRANCH (p_entity_num,
                                                 idx.BRANCH_CODE,
                                                 p_ason_date);
        COMMIT;
    END LOOP;
END;
/