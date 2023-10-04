CREATE OR REPLACE PROCEDURE  SP_GEN_CONSOLIDATED_SMS (p_entity_num   NUMBER,
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
       PKG_PREP_CONSOLIDATE_SMS.START_BRNWISE(p_entity_num,idx.BRANCH_CODE);
        COMMIT;
    END LOOP;
END;
/