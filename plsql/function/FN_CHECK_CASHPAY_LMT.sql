CREATE OR REPLACE FUNCTION FN_CHECK_CASHPAY_LMT(V_ENTITY_NUM   IN NUMBER,
                                                W_BRN_CODE     IN NUMBER,
                                                W_PRODUCT_CODE IN NUMBER,
                                                W_CLIENT_CODE  IN NUMBER,
                                                W_CURR         IN VARCHAR2)
  RETURN VARCHAR2 AS
  V_CUTOFF_AMT      NUMBER(18, 3) := 0;
  V_ACNTCBAL_AC_BAL NUMBER(18, 3) := 0;
  W_PROD_CODE       NUMBER(6) := 0;
  W_CBD             DATE := null;
  V_CUTOFF_AMT1     NUMBER(18, 3) := 0;
BEGIN
  PKG_ENTITY.SP_SET_ENTITY_CODE(V_ENTITY_NUM);
  W_CBD := PKG_PB_GLOBAL.FN_GET_CURR_BUS_DATE(PKG_ENTITY.FN_GET_ENTITY_CODE);

  W_PROD_CODE := W_PRODUCT_CODE;

  <<CUTOFF_CHECK>>
  BEGIN
    SELECT CASHPAYOUTLMTH_CUTOFF_AMT
      INTO V_CUTOFF_AMT
      FROM CASHPAYOUTLMTHIST
     WHERE CASHPAYOUTLMTH_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
       AND CASHPAYOUTLMTH_CURR_CODE = W_CURR
       AND CASHPAYOUTLMTH_PROD_CODE = W_PROD_CODE
       AND CASHPAYOUTLMTH_EFF_DATE =
           (SELECT MAX(CASHPAYOUTLMTH_EFF_DATE)
              FROM CASHPAYOUTLMTHIST
             WHERE CASHPAYOUTLMTH_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
               AND CASHPAYOUTLMTH_CURR_CODE = W_CURR
               AND CASHPAYOUTLMTH_PROD_CODE = W_PROD_CODE
               AND CASHPAYOUTLMTH_EFF_DATE <= W_CBD);
    IF V_CUTOFF_AMT > 0 THEN
      SELECT (SUM(NVL(ACNTCBAL_AC_BAL, 0)) + SUM(NVL(PBDOD_AMT_TRF_OD, 0))) --Sriram B - chn - 23-aug-2010 - added pbdod_amt_trf_od
        INTO V_ACNTCBAL_AC_BAL
        FROM PBDCONTRACT, ACNTS, ACNTCBAL, PBDCONTTRFOD
       WHERE PBDCONT_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
         AND ACNTS_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
         AND ACNTCBAL_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
            -- AND PBDCONT_BRN_CODE = W_BRN_CODE
         AND PBDCONT_DEP_AC_NUM = ACNTS_INTERNAL_ACNUM
         AND PBDCONT_PROD_CODE = ACNTS_PROD_CODE
         AND PBDCONT_PROD_CODE = W_PROD_CODE
         AND PBDCONT_DEP_CURR = W_CURR
         AND ACNTS_CLIENT_NUM = W_CLIENT_CODE
         AND PBDCONT_CONT_NUM > 0
         AND PBDCONT_CLOSURE_DATE IS NULL
            --Sriram B - chn - 23-aug-2010 - AND PBDCONT_TRF_TO_OD_ON IS NULL
         AND PBDCONT_AUTH_ON IS NOT NULL
         AND ACNTS_BRN_CODE = PBDCONT_BRN_CODE
         AND ACNTCBAL_INTERNAL_ACNUM = PBDCONT_DEP_AC_NUM
         AND ACNTCBAL_CURR_CODE = PBDCONT_DEP_CURR
         AND ACNTCBAL_CONTRACT_NUM = PBDCONT_CONT_NUM
         --Sriram B - chn - 23-aug-2010 - beg
         AND PBDCONT_ENTITY_NUM = PBDOD_ENTITY_NUM(+)
         AND PBDCONT_BRN_CODE = PBDOD_BRN_CODE(+)
         AND PBDCONT_DEP_AC_NUM = PBDOD_DEP_AC_NUM(+)
         AND PBDCONT_CONT_NUM = PBDOD_CONT_NUM(+)
         --Sriram B - chn - 23-aug-2010 - end
       GROUP BY PBDCONT_PROD_CODE, PBDCONT_DEP_CURR
       ORDER BY PBDCONT_PROD_CODE, PBDCONT_DEP_CURR;
      IF V_ACNTCBAL_AC_BAL > V_CUTOFF_AMT THEN
        RETURN 'TRUE';
      ELSE
        RETURN 'FALSE';
      END IF;
    ELSIF V_CUTOFF_AMT = 0 THEN
      RETURN 'FALSE';
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      <<CHK_VAL>>
      BEGIN
        SELECT CASHPAYOUTLMTH_CUTOFF_AMT
          INTO V_CUTOFF_AMT
          FROM CASHPAYOUTLMTHIST
         WHERE CASHPAYOUTLMTH_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
           AND CASHPAYOUTLMTH_CURR_CODE = W_CURR
           AND CASHPAYOUTLMTH_PROD_CODE = 0
           AND CASHPAYOUTLMTH_EFF_DATE =
               (SELECT MAX(CASHPAYOUTLMTH_EFF_DATE)
                  FROM CASHPAYOUTLMTHIST
                 WHERE CASHPAYOUTLMTH_ENTITY_NUM =
                       PKG_ENTITY.FN_GET_ENTITY_CODE
                   AND CASHPAYOUTLMTH_CURR_CODE = W_CURR
                   AND CASHPAYOUTLMTH_PROD_CODE = 0
                   AND CASHPAYOUTLMTH_EFF_DATE <= W_CBD);
        IF V_CUTOFF_AMT > 0 THEN
          --  V_ACNTCBAL_AC_BAL := 0;
          --  V_CUTOFF_AMT      := 0;
          FOR IDX IN (SELECT (SUM(NVL(ACNTCBAL_AC_BAL, 0)) +
                             SUM(NVL(PBDOD_AMT_TRF_OD, 0))) ACNTCBAL_AC_BAL,
                             PBDCONT_PROD_CODE,
                             PBDCONT_DEP_CURR
                        FROM PBDCONTRACT, ACNTS, ACNTCBAL, PBDCONTTRFOD
                       WHERE PBDCONT_ENTITY_NUM =
                             PKG_ENTITY.FN_GET_ENTITY_CODE
                         AND ACNTS_ENTITY_NUM =
                             PKG_ENTITY.FN_GET_ENTITY_CODE
                         AND ACNTCBAL_ENTITY_NUM =
                             PKG_ENTITY.FN_GET_ENTITY_CODE
                            --  AND PBDCONT_BRN_CODE = W_BRN_CODE
                         AND PBDCONT_DEP_AC_NUM = ACNTS_INTERNAL_ACNUM
                         AND PBDCONT_PROD_CODE = ACNTS_PROD_CODE
                         AND PBDCONT_DEP_CURR = W_CURR
                         AND ACNTS_CLIENT_NUM = W_CLIENT_CODE
                         AND PBDCONT_CONT_NUM > 0
                         AND PBDCONT_CLOSURE_DATE IS NULL
                            --Sriram B - chn - 23-aug-2010 - AND PBDCONT_TRF_TO_OD_ON IS NULL
                         AND PBDCONT_AUTH_ON IS NOT NULL
                         AND ACNTS_BRN_CODE = PBDCONT_BRN_CODE
                         AND ACNTCBAL_INTERNAL_ACNUM = PBDCONT_DEP_AC_NUM
                         AND ACNTCBAL_CURR_CODE = PBDCONT_DEP_CURR
                         AND ACNTCBAL_CONTRACT_NUM = PBDCONT_CONT_NUM
                         --Sriram B - chn - 23-aug-2010 - beg
                         AND PBDCONT_ENTITY_NUM = PBDOD_ENTITY_NUM(+)
                         AND PBDCONT_BRN_CODE = PBDOD_BRN_CODE(+)
                         AND PBDCONT_DEP_AC_NUM = PBDOD_DEP_AC_NUM(+)
                         AND PBDCONT_CONT_NUM = PBDOD_CONT_NUM(+)
                         --Sriram B - chn - 23-aug-2010 - beg
                       GROUP BY PBDCONT_PROD_CODE, PBDCONT_DEP_CURR
                       ORDER BY PBDCONT_PROD_CODE, PBDCONT_DEP_CURR) LOOP
            <<CHECK_VAL>>
            BEGIN
              SELECT CASHPAYOUTLMTH_CUTOFF_AMT
              --INTO V_CUTOFF_AMT
                INTO V_CUTOFF_AMT1
                FROM CASHPAYOUTLMTHIST
               WHERE CASHPAYOUTLMTH_ENTITY_NUM =
                     PKG_ENTITY.FN_GET_ENTITY_CODE
                 AND CASHPAYOUTLMTH_CURR_CODE = W_CURR
                 AND CASHPAYOUTLMTH_PROD_CODE = IDX.PBDCONT_PROD_CODE
                 AND CASHPAYOUTLMTH_EFF_DATE =
                     (SELECT MAX(CASHPAYOUTLMTH_EFF_DATE)
                        FROM CASHPAYOUTLMTHIST
                       WHERE CASHPAYOUTLMTH_ENTITY_NUM =
                             PKG_ENTITY.FN_GET_ENTITY_CODE
                         AND CASHPAYOUTLMTH_CURR_CODE = W_CURR
                         AND CASHPAYOUTLMTH_PROD_CODE =
                             IDX.PBDCONT_PROD_CODE
                         AND CASHPAYOUTLMTH_EFF_DATE <= W_CBD);
              --   IF V_CUTOFF_AMT = 0 THEN
              IF V_CUTOFF_AMT1 = 0 THEN
                goto CONTINUE_LOOP;
              END IF;
              V_ACNTCBAL_AC_BAL := IDX.ACNTCBAL_AC_BAL + V_ACNTCBAL_AC_BAL;
              IF V_ACNTCBAL_AC_BAL > V_CUTOFF_AMT THEN
                RETURN 'TRUE';
              END IF;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                V_ACNTCBAL_AC_BAL := IDX.ACNTCBAL_AC_BAL +
                                     V_ACNTCBAL_AC_BAL;
                IF V_ACNTCBAL_AC_BAL > V_CUTOFF_AMT THEN
                  RETURN 'TRUE';
                END IF;
              WHEN OTHERS THEN
                -- RETURN NULL;
                RETURN 'FALSE';
            END CHECK_VAL;

            <<CONTINUE_LOOP>>
          --       --    BEGIN
            NULL;
            --      --   END CONTINUE_LOOP;

          END LOOP;
          RETURN 'FALSE';
        ELSE
          RETURN 'FALSE';
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RETURN 'FALSE';
      END CHK_VAL;
  END CUTOFF_CHECK;
EXCEPTION
  WHEN OTHERS THEN
    RETURN 'FALSE';
END FN_CHECK_CASHPAY_LMT;
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/
