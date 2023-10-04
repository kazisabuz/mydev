/* Formatted on 9/12/2021 4:17:00 PM (QP5 v5.149.1003.31008) */
  SELECT TRAN_DB_CR_FLG,
         TRAN_TYPE_OF_TRAN,
         SUM (VOCH_CNT) VOCH_CNT,
         SUM (CSHAMT) CSHAMT,
         SUM (CLGAMT) CLGAMT,
         SUM (TRFAMT) TRFAMT
    FROM (  SELECT /*+ PARALLEL( 16) */  TRAN_GLACC_CODE,
                   TRAN_DB_CR_FLG,
                   TRAN_TYPE_OF_TRAN,
                   COUNT (1) VOCH_CNT,
                   SUM (
                      DECODE (TRAN_TYPE_OF_TRAN, '1', TRAN_BASE_CURR_EQ_AMT, 0))
                      TRFAMT,
                   SUM (
                      DECODE (TRAN_TYPE_OF_TRAN, '2', TRAN_BASE_CURR_EQ_AMT, 0))
                      CLGAMT,
                   SUM (
                      DECODE (TRAN_TYPE_OF_TRAN, '3', TRAN_BASE_CURR_EQ_AMT, 0))
                      CSHAMT
              FROM (SELECT /*+ PARALLEL( 16) */ TRAN_BRN_CODE,
                           TRAN_DATE_OF_TRAN,
                           TRAN_BATCH_NUMBER,
                           TRAN_BATCH_SL_NUM,
                           TRAN_DB_CR_FLG,
                           TRAN_GLACC_CODE,
                           TRAN_BASE_CURR_EQ_AMT,
                           TRAN_TYPE_OF_TRAN
                      FROM (SELECT TRAN_BRN_CODE,
                                   TRAN_DATE_OF_TRAN,
                                   TRAN_BATCH_NUMBER,
                                   TRAN_BATCH_SL_NUM,
                                   TRAN_DB_CR_FLG,
                                   TRAN_GLACC_CODE,
                                   TRAN_BASE_CURR_EQ_AMT,
                                   TRAN_TYPE_OF_TRAN
                              FROM TRAN2021
                             WHERE TRAN_ENTITY_NUM = 1
                                   AND TRAN_DATE_OF_TRAN BETWEEN :from_date
                                                             AND :TO_DATE
                                   AND TRAN_BASE_CURR_EQ_AMT <> 0
                                   AND TRAN_AUTH_ON IS NOT NULL--   AND TRAN_BRN_CODE = :W_BRNCODE
                           )
                     WHERE (TRAN_BRN_CODE,
                            TRAN_DATE_OF_TRAN,
                            TRAN_BATCH_NUMBER,
                            TRAN_BATCH_SL_NUM) NOT IN
                              (SELECT SUPTRANDTL_BRN_CODE,
                                      SUPTRANDTL_DATE_OF_TRAN,
                                      SUPTRANDTL_BATCH_NUMBER,
                                      SUPTRANDTL_BATCH_SL
                                 FROM SUPTRANDTL
                                WHERE SUPTRANDTL_ENTITY_NUM =
                                         PKG_ENTITY.FN_GET_ENTITY_CODE
                                      AND SUPTRANDTL_DATE_OF_TRAN BETWEEN :from_date
                                                                      AND :TO_DATE
                                      AND SUPTRANDTL_BASE_CURR_EQ_AMT <> 0--      AND SUPTRANDTL_BRN_CODE = :W_BRNCODE
                              ))
          GROUP BY TRAN_GLACC_CODE, TRAN_DB_CR_FLG, TRAN_TYPE_OF_TRAN),
         EXTGL,
         GLMAST
   WHERE TRAN_GLACC_CODE = EXTGL_ACCESS_CODE AND GL_NUMBER = EXTGL_GL_HEAD
GROUP BY TRAN_DB_CR_FLG, TRAN_TYPE_OF_TRAN