/* Formatted on 6/19/2023 2:08:19 PM (QP5 v5.388) */
CREATE OR REPLACE PACKAGE PKG_LOAN_UPDATE
IS
    PROCEDURE PROC_BRN (P_ENTITY_NUMBER   IN NUMBER,
                        P_BRAN_CODE       IN NUMBER DEFAULT 0);
END;
/



CREATE OR REPLACE PACKAGE BODY PKG_LOAN_UPDATE
IS
    PROCEDURE PROC_BRN (P_ENTITY_NUMBER   IN NUMBER,
                        P_BRAN_CODE       IN NUMBER DEFAULT 0)
    IS
        v_intrn_ac_num   NUMBER;
        v_monthdff       NUMBER;
        v_asset_code     VARCHAR2 (2);
        V_CBD            DATE;
    BEGIN
        V_CBD := PKG_PB_GLOBAL.FN_GET_CURR_BUS_DATE (P_ENTITY_NUMBER);

        FOR rec
            IN (SELECT a.acnts_internal_acnum,
                       lm.lmtline_limit_expiry_date,
                       FLOOR (
                           MONTHS_BETWEEN (V_CBD,
                                           lm.lmtline_limit_expiry_date))    monthdff
                 FROM acnts      a,
                      lnprodpm   lp,
                      Lnacrs     lr,
                      limitline  lm,
                      Acaslldtl  asd,
                      ASSETCLS
                WHERE     a.acnts_entity_num = P_ENTITY_NUMBER
                      AND ASSETCLS_ENTITY_NUM = P_ENTITY_NUMBER
                      AND a.acnts_prod_code = lp.lnprd_prod_code
                      AND a.acnts_closure_date IS NULL
                      AND lp.lnprd_short_term_loan = '1'
                      AND lr.lnacrs_entity_num = P_ENTITY_NUMBER
                      AND lr.lnacrs_rephasement_entry = '1'
                      AND a.acnts_internal_acnum = lr.lnacrs_internal_acnum
                      AND ASSETCLS_INTERNAL_ACNUM = a.acnts_internal_acnum
                      AND (   ASSETCLS_AUTO_MAN_FLG <> 'M'
                           OR (    ASSETCLS_AUTO_MAN_FLG = 'M'
                               AND ASSETCLS_EXEMPT_END_DATE < V_CBD))
                      AND lm.lmtline_entity_num = P_ENTITY_NUMBER
                      AND asd.acaslldtl_entity_num = P_ENTITY_NUMBER
                      AND LR.LNACRS_PURPOSE = 'R'
                      --AND A.ACNTS_BRN_CODE = P_BRAN_CODE
                      AND asd.acaslldtl_internal_acnum =
                          a.acnts_internal_acnum
                      AND lm.lmtline_client_code = asd.acaslldtl_client_num
                      AND lm.lmtline_num = asd.acaslldtl_limit_line_num
                      AND a.acnts_prod_code NOT IN (2042,
                                                    2301,
                                                    2311,
                                                    2315,
                                                    2319,
                                                    2324,
                                                    2401,
                                                    2502,
                                                    2508,
                                                    2514,
                                                    2546,
                                                    2547)
                      AND lm.lmtline_limit_expiry_date <= V_CBD)
        LOOP
            v_asset_code := '';

            IF rec.monthdff <= 12
            THEN
                v_asset_code := 'ST';
            END IF;

            IF rec.monthdff > 12 AND rec.monthdff <= 36
            THEN
                v_asset_code := 'SS';
            END IF;

            IF rec.monthdff > 36 AND rec.monthdff <= 60
            THEN
                v_asset_code := 'DF';
            END IF;

            IF rec.monthdff > 60
            THEN
                v_asset_code := 'BL';
            END IF;


            UPDATE Assetcls a
               SET a.assetcls_asset_code = v_asset_code,
                   a.assetcls_latest_eff_date = V_CBD,
                   a.assetcls_auto_man_flg = 'M',
                   a.assetcls_exempt_end_date = V_CBD,
                   a.assetcls_npa_date = V_CBD,
                   a.assetcls_remarks =
                          SUBSTR (TO_CHAR (V_CBD, 'Month'), 1, 3)
                       || ', '
                       || TO_CHAR (V_CBD, 'YYYY')
                       || ' Manual Classification for short term-RS'
             WHERE     a.assetcls_entity_num = P_ENTITY_NUMBER
                   AND a.assetcls_internal_acnum = rec.acnts_internal_acnum;



            MERGE INTO ASSETCLSHIST A
                 USING DUAL
                    ON (    A.ASSETCLSH_ENTITY_NUM = P_ENTITY_NUMBER
                        AND A.ASSETCLSH_INTERNAL_ACNUM =
                            rec.acnts_internal_acnum
                        AND A.ASSETCLSH_EFF_DATE = V_CBD)
            WHEN MATCHED
            THEN
                UPDATE SET
                    A.ASSETCLSH_ASSET_CODE = v_asset_code,
                    A.ASSETCLSH_NPA_DATE = V_CBD,
                    A.ASSETCLSH_AUTO_MAN_FLG = 'M',
                    A.ASSETCLSH_REMARKS =
                           SUBSTR (TO_CHAR (V_CBD, 'Month'), 1, 3)
                        || ', '
                        || TO_CHAR (V_CBD, 'YYYY')
                        || ' Manual Classification for short term-RS',
                    A.ASSETCLSH_ENTD_BY = 'INTELECT',
                    A.ASSETCLSH_ENTD_ON = V_CBD,
                    A.ASSETCLSH_AUTH_BY = 'INTELECT',
                    A.ASSETCLSH_AUTH_ON = V_CBD,
                    A.ASSETCLSH_EXEMPT_END_DATE = V_CBD
            WHEN NOT MATCHED
            THEN
                INSERT     (A.ASSETCLSH_ENTITY_NUM,
                            A.ASSETCLSH_INTERNAL_ACNUM,
                            A.ASSETCLSH_EFF_DATE,
                            A.ASSETCLSH_ASSET_CODE,
                            A.ASSETCLSH_NPA_DATE,
                            A.ASSETCLSH_AUTO_MAN_FLG,
                            A.ASSETCLSH_REMARKS,
                            A.ASSETCLSH_ENTD_BY,
                            A.ASSETCLSH_ENTD_ON,
                            A.ASSETCLSH_LAST_MOD_BY,
                            A.ASSETCLSH_LAST_MOD_ON,
                            A.ASSETCLSH_AUTH_BY,
                            A.ASSETCLSH_AUTH_ON,
                            A.TBA_MAIN_KEY,
                            A.ASSETCLSH_PURPOSE_FLAG,
                            A.ASSETCLSH_EXEMPT_END_DATE)
                    VALUES (P_ENTITY_NUMBER,
                            rec.acnts_internal_acnum,
                            V_CBD,
                            v_asset_code,
                            V_CBD,
                            'M',
                            'Manual Classification for short term-RS',
                            'INTELECT',
                            V_CBD,
                            NULL,
                            NULL,
                            'INTELECT',
                            V_CBD,
                            '',
                            '',
                            V_CBD);
        END LOOP;

        COMMIT;
    END;
END;
/
