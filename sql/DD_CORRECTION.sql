/* Formatted on 4/19/2022 11:45:46 AM (QP5 v5.252.13127.32867) */
BEGIN
   FOR IDX IN (  SELECT *
                   FROM MIG_DETAIL
               ORDER BY BRANCH_CODE)
   LOOP
      BEGIN
         FOR IDX1
            IN (SELECT DDPOPAYDB_ISSUED_ON_BRN,
                       DDPOPAYDB_REMIT_CODE,
                       DDPOPAYDB_INST_PFX,
                       DDPOPAYDB_LEAF_NUM,
                       DDPOPAYDB_INST_AMT
                  FROM DDPOPAYDB
                 WHERE     DDPOPAYDB_ENTITY_NUM = 1
                       -- AND DDPOPAYDB_REMIT_CODE  ='1'
                       AND DDPOPAYDB_ISSUED_ON_BRN = IDX.BRANCH_CODE
                       AND DDPOPAYDB_PAY_CAN_DUP_DATE IS NOT NULL
                       AND DDPOPAYDB_PAY_CAN_DUP_DATE > '19-apr-2022'
                       AND TRIM (DDPOPAYDB_STATUS) IS NULL
                       AND (DDPOPAYDB_ISSUED_ON_BRN,
                            DDPOPAYDB_REMIT_CODE,
                            DDPOPAYDB_INST_PFX,
                            DDPOPAYDB_LEAF_NUM,
                            DDPOPAYDB_INST_AMT) IN (SELECT DDPOPAY_BRN_CODE,
                                                           DDPOPAY_REMIT_CODE,
                                                           DDPOPAY_INST_PFX,
                                                           DDPOPAY_INST_NUM,
                                                           DDPOPAY_INST_AMT
                                                      FROM DDPOPAY
                                                     WHERE     DDPOPAY_AUTH_BY
                                                                  IS NOT NULL
                                                           AND DDPOPAY_BRN_CODE =
                                                                  IDX.BRANCH_CODE
                                                           AND DDPOPAY_REJ_BY
                                                                  IS NULL))
         LOOP
            UPDATE DDPOPAYDB
               SET DDPOPAYDB_STATUS = 'P'
             WHERE     DDPOPAYDB_ISSUED_ON_BRN = IDX1.DDPOPAYDB_ISSUED_ON_BRN
                   AND DDPOPAYDB_REMIT_CODE = IDX1.DDPOPAYDB_REMIT_CODE
                   AND DDPOPAYDB_INST_PFX = IDX1.DDPOPAYDB_INST_PFX
                   AND DDPOPAYDB_LEAF_NUM = IDX1.DDPOPAYDB_LEAF_NUM
                   AND DDPOPAYDB_INST_AMT = IDX1.DDPOPAYDB_INST_AMT;
         END LOOP;
      END;
/*
      BEGIN
         FOR IDX1
            IN (SELECT DDPOPAYDB_ISSUED_ON_BRN,
                       DDPOPAYDB_REMIT_CODE,
                       DDPOPAYDB_INST_PFX,
                       DDPOPAYDB_LEAF_NUM,
                       DDPOPAYDB_INST_AMT
                  FROM DDPOPAYDB
                 WHERE     DDPOPAYDB_ENTITY_NUM = 1
                       -- AND DDPOPAYDB_REMIT_CODE  ='1'
                       AND DDPOPAYDB_ISSUED_ON_BRN = IDX.BRANCH_CODE
                       AND DDPOPAYDB_PAY_CAN_DUP_DATE IS NULL
                       AND TRIM (DDPOPAYDB_STATUS) IS NULL
                       AND (DDPOPAYDB_ISSUED_ON_BRN,
                            DDPOPAYDB_REMIT_CODE,
                            DDPOPAYDB_INST_PFX,
                            DDPOPAYDB_LEAF_NUM,
                            DDPOPAYDB_INST_AMT) IN (SELECT DDPOPAY_BRN_CODE,
                                                           DDPOPAY_REMIT_CODE,
                                                           DDPOPAY_INST_PFX,
                                                           DDPOPAY_INST_NUM,
                                                           DDPOPAY_INST_AMT
                                                      FROM DDPOPAY
                                                     WHERE     DDPOPAY_AUTH_BY
                                                                  IS NOT NULL
                                                           AND DDPOPAY_BRN_CODE =
                                                                  IDX.BRANCH_CODE
                                                           AND DDPOPAY_REJ_BY
                                                                  IS NULL))
         LOOP
            UPDATE DDPOPAYDB
               SET DDPOPAYDB_STATUS = 'P',
                   DDPOPAYDB_PAY_CAN_DUP_DATE =
                      (SELECT DDPOPAY_PAY_DATE
                         FROM DDPOPAY
                        WHERE     DDPOPAY_BRN_CODE =
                                     IDX1.DDPOPAYDB_ISSUED_ON_BRN
                              AND DDPOPAY_REMIT_CODE =
                                     IDX1.DDPOPAYDB_REMIT_CODE
                              AND DDPOPAY_INST_PFX = IDX1.DDPOPAYDB_INST_PFX
                              AND DDPOPAY_INST_NUM = IDX1.DDPOPAYDB_LEAF_NUM
                              AND DDPOPAY_INST_AMT = IDX1.DDPOPAYDB_INST_AMT
                              AND DDPOPAY_AUTH_BY IS NOT NULL
                              AND DDPOPAY_REJ_BY IS NULL)
             WHERE     DDPOPAYDB_ISSUED_ON_BRN = IDX1.DDPOPAYDB_ISSUED_ON_BRN
                   AND DDPOPAYDB_REMIT_CODE = IDX1.DDPOPAYDB_REMIT_CODE
                   AND DDPOPAYDB_INST_PFX = IDX1.DDPOPAYDB_INST_PFX
                   AND DDPOPAYDB_LEAF_NUM = IDX1.DDPOPAYDB_LEAF_NUM
                   AND DDPOPAYDB_INST_AMT = IDX1.DDPOPAYDB_INST_AMT;
         END LOOP;
      END;


      BEGIN
         FOR idx1
            IN (SELECT DDPOPAYDB_ISSUED_ON_BRN,
                       DDPOPAYDB_REMIT_CODE,
                       DDPOPAYDB_INST_PFX,
                       DDPOPAYDB_LEAF_NUM,
                       DDPOPAYDB_INST_AMT
                  FROM DDPOPAYDB
                 WHERE     DDPOPAYDB_ENTITY_NUM = 1
                       -- AND DDPOPAYDB_REMIT_CODE  ='1'
                       AND DDPOPAYDB_ISSUED_ON_BRN = IDX.BRANCH_CODE
                       AND DDPOPAYDB_PAY_CAN_DUP_DATE IS NULL
                       AND TRIM (DDPOPAYDB_STATUS) IS NOT NULL
                       AND (DDPOPAYDB_ISSUED_ON_BRN,
                            DDPOPAYDB_REMIT_CODE,
                            DDPOPAYDB_INST_PFX,
                            DDPOPAYDB_LEAF_NUM,
                            DDPOPAYDB_INST_AMT) IN (SELECT DDPOPAY_BRN_CODE,
                                                           DDPOPAY_REMIT_CODE,
                                                           DDPOPAY_INST_PFX,
                                                           DDPOPAY_INST_NUM,
                                                           DDPOPAY_INST_AMT
                                                      FROM DDPOPAY
                                                     WHERE     DDPOPAY_AUTH_BY
                                                                  IS NOT NULL
                                                           AND DDPOPAY_BRN_CODE =
                                                                  IDX.BRANCH_CODE
                                                           AND DDPOPAY_REJ_BY
                                                                  IS NULL))
         LOOP
            UPDATE DDPOPAYDB
               SET DDPOPAYDB_PAY_CAN_DUP_DATE =
                      (SELECT DDPOPAY_PAY_DATE
                         FROM DDPOPAY
                        WHERE     DDPOPAY_BRN_CODE =
                                     IDX1.DDPOPAYDB_ISSUED_ON_BRN
                              AND DDPOPAY_REMIT_CODE =
                                     IDX1.DDPOPAYDB_REMIT_CODE
                              AND DDPOPAY_INST_PFX = IDX1.DDPOPAYDB_INST_PFX
                              AND DDPOPAY_INST_NUM = IDX1.DDPOPAYDB_LEAF_NUM
                              AND DDPOPAY_INST_AMT = IDX1.DDPOPAYDB_INST_AMT
                              AND DDPOPAY_AUTH_BY IS NOT NULL
                              AND DDPOPAY_REJ_BY IS NULL)
             WHERE     DDPOPAYDB_ISSUED_ON_BRN = IDX1.DDPOPAYDB_ISSUED_ON_BRN
                   AND DDPOPAYDB_REMIT_CODE = IDX1.DDPOPAYDB_REMIT_CODE
                   AND DDPOPAYDB_INST_PFX = IDX1.DDPOPAYDB_INST_PFX
                   AND DDPOPAYDB_LEAF_NUM = IDX1.DDPOPAYDB_LEAF_NUM
                   AND DDPOPAYDB_INST_AMT = IDX1.DDPOPAYDB_INST_AMT;

            COMMIT;
         END LOOP;
      END;*/
   END LOOP;
END;
-----------------------------------------------------------------------------------------


BEGIN
   FOR IDX IN (  SELECT *
                   FROM MIG_DETAIL
               ORDER BY BRANCH_CODE)
   LOOP
      FOR IDZ
         IN (SELECT DISTINCT ACNTS_BRN_CODE, ACNTS_CLIENT_NUM, LMTLINE_NUM
               FROM LIMITLINE,
                    LIMITLINEHIST,
                    ACASLLDTL,
                    ACNTS
              WHERE     ACNTS_ENTITY_NUM = 1
                    AND ACNTS_INTERNAL_ACNUM = ACASLLDTL_INTERNAL_ACNUM
                    AND ACASLLDTL_ENTITY_NUM = 1
                    AND LMTLINE_CLIENT_CODE = ACASLLDTL_CLIENT_NUM
                    AND ACNTS_CLIENT_NUM = ACASLLDTL_CLIENT_NUM
                    AND ACNTS_CLIENT_NUM = LMTLINE_CLIENT_CODE
                    AND ACNTS_CLIENT_NUM = LIMLNEHIST_CLIENT_CODE
                    AND LMTLINE_NUM = ACASLLDTL_LIMIT_LINE_NUM
                    AND (   LMTLINE_HOME_BRANCH = 0
                         OR LIMLNEHIST_HOME_BRANCH = 0)
                    AND ACNTS_CLOSURE_DATE IS NULL
                    AND LMTLINE_ENTITY_NUM = 1
                    AND ACNTS_BRN_CODE = IDX.BRANCH_CODE
                    AND LIMLNEHIST_LIMIT_LINE_NUM = LMTLINE_NUM
                    AND LMTLINE_CLIENT_CODE = LIMLNEHIST_CLIENT_CODE
                    AND LIMLNEHIST_CLIENT_CODE = ACASLLDTL_CLIENT_NUM
                    AND LMTLINE_NUM = LIMLNEHIST_LIMIT_LINE_NUM
                    AND LIMLNEHIST_ENTITY_NUM = 1)
      LOOP
         UPDATE LIMITLINE
            SET LMTLINE_HOME_BRANCH = idz.ACNTS_BRN_CODE
          WHERE     LMTLINE_CLIENT_CODE = IDZ.ACNTS_CLIENT_NUM
                AND LMTLINE_NUM = IDZ.LMTLINE_NUM;

         UPDATE LIMITLINEHIST
            SET LIMLNEHIST_HOME_BRANCH = IDZ.ACNTS_BRN_CODE
          WHERE     LIMLNEHIST_CLIENT_CODE = IDZ.ACNTS_CLIENT_NUM
                AND LIMLNEHIST_LIMIT_LINE_NUM = IDZ.LMTLINE_NUM;

         COMMIT;
      END LOOP;
   END LOOP;
END;