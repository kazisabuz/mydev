/* Formatted on 12/4/2022 2:38:08 PM (QP5 v5.388) */
SELECT C.TFCADRPT_BRANCH_CODE
           TRAN_BRN_CODE,
       TO_CHAR (C.TFCADRPT_POST_TRAN_DATE, 'DD-MON-YYYY')
           TRAN_DATE,
       C.TFCADRPT_POST_TRAN_BATCH
           TRAN_BATCH,
       C.TFCADRPT_BATCH_SL_NO
           BATCH_SL,
       TRD.TFTMDRD_FET_NO
           FET_NO,
       TRD.TFTMDRD_FET_DATE
           FET_DATE,
       TRD.TFTMDRD_DR_CR_FLAG
           DB_CR_FLG,
       TRD.TFTMDRD_FET_FC_CURR
           TRAN_CURR_CODE,
       TRD.TFTMDRD_FET_FC_AMOUNT
           TRAN_AMOUNT,
       TRD.TFTMDRD_CONV_RATE
           CONV_RATE,
       TRD.TFTMDRD_FC_BASE_EQV
           BASE_EQ_AMT,
       TRD.TFTMDRD_VOSTRO_AC_CODE
           VOSTRO_CODE,
       TRD.TFTMDRD_NOSTRO_AC_CODE
           NOSTRO_CODE,
       TRD.TFTMDRD_REIM_BANK_DESC
           REIM_BANK_DESC,
       TRD.TFTMDRD_REFERENCE
           TFCADRPT_REFERENCE,
       TRD.TFTMDRD_MODULE
           TFCADRPT_MODULE,
       TRD.TFTMDRD_PGMID
           TFCADRPT_PGMID,
       TRD.TFTMDRD_PGM_SOURCE_KEY
           TRAN_SOURCEKEY,
       TR.POST_TRAN_BRN
           RECON_POST_TRAN_BRN,
       TR.POST_TRAN_DATE
           RECON_POST_TRAN_DATE,
       TR.POST_TRAN_BATCH_NUM
           RECON_POST_TRAN_BATCH_NUM,
       'Reconciled and Authorized'
           RECON_STATUS
  FROM TFTMDRECON  TR
       INNER JOIN TFTMDRECONDTL TRD
           ON (    TR.TFTMDR_ENTITY_NUM = TRD.TFTMDRD_ENTITY_NUM
               AND TR.TFTMDR_BRN_CODE = TRD.TFTMDRD_BRN_CODE
               AND TR.TFTMDR_DATE_OF_RECON = TRD.TFTMDRD_DATE_OF_RECON
               AND TR.TFTMDR_RECON_DAY_SL = TRD.TFTMDRD_RECON_DAY_SL)
       LEFT JOIN TFCADRPT C
           ON (    TRIM (C.TFCADRPT_MODULE) = TRIM (TRD.TFTMDRD_MODULE)
               AND TRIM (C.TFCADRPT_PGMID) = TRIM (TRD.TFTMDRD_PGMID)
               AND C.TFCADRPT_BRANCH_CODE = TRD.TFTMDRD_BRANCH_CODE
               AND C.TFCADRPT_FET_NO = TRD.TFTMDRD_FET_NO
               AND C.TFCADRPT_POST_TRAN_DATE = TRD.TFTMDRD_FET_DATE
               AND C.TFCADRPT_FC_CURR = TRD.TFTMDRD_FET_FC_CURR
               AND C.TFCADRPT_FC_AMT = TRD.TFTMDRD_FET_FC_AMOUNT
               AND TRIM (C.TFCADRPT_REFERENCE) = TRIM (TRD.TFTMDRD_REFERENCE))
       LEFT JOIN NOSTRO N
           ON (    TRD.TFTMDRD_ENTITY_NUM = N.NOSTRO_ENTITY_NUM
               AND TRD.TFTMDRD_NOSTRO_AC_CODE = N.NOSTRO_AC_CODE)
       LEFT JOIN VOSTRO V
           ON (    TRD.TFTMDRD_ENTITY_NUM = V.VOSTRO_ENTITY_NUM
               AND TRD.TFTMDRD_VOSTRO_AC_CODE = V.VOSTRO_AC_CODE)
 WHERE     TR.TFTMDR_ENTITY_NUM = 1
       AND TR.TFTMDR_BRN_CODE = 18
       AND TRD.TFTMDRD_FET_DATE BETWEEN '15-OCT-18' AND '16-OCT-18'
       AND TR.TFTMDR_AUTH_ON IS NOT NULL
       AND TR.TFTMDR_REJ_ON IS NULL
UNION ALL
SELECT TRAN_BRN_CODE,
       TO_CHAR (TRAN_DATE, 'DD-MON-YYYY')     TRAN_DATE,
       TRAN_BATCH,
       BATCH_SL,
       FET_NO,
       FET_DATE,
       DB_CR_FLG,
       TRAN_CURR_CODE,
       TRAN_AMOUNT,
       CONV_RATE,
       BASE_EQ_AMT,
       VOSTRO_CODE,
       NOSTRO_CODE,
       REIM_BANK_DESC,
       TFCADRPT_REFERENCE,
       TFCADRPT_MODULE,
       TFCADRPT_PGMID,
       TRAN_SOURCEKEY,
       RECON_POST_TRAN_BRN,
       RECON_POST_TRAN_DATE,
       RECON_POST_TRAN_BATCH_NUM,
       RECON_STATUS
  FROM TABLE (PKG_TFTMDRECON.FN_GET_RECON_DATA (1,
                                                18,
                                                '',
                                                '15-OCT-18',
                                                '16-OCT-18',
                                                '',
                                                '',
                                                '',
                                                '',
                                                '',
                                                '',
                                                '',
                                                'D',
                                                'U'))
ORDER BY
    TRAN_BRN_CODE,
    TRAN_DATE,
    TRAN_BATCH,
    BATCH_SL