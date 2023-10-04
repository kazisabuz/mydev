/* Formatted on 10/26/2021 6:18:33 PM (QP5 v5.149.1003.31008) */
PROCEDURE HANDLE_RESP_UNDO
AS
BEGIN
   SELECT *
     INTO S_MBRN_CORE_REC
     FROM MBRN_CORE
    WHERE MBRN_CODE =
             PKG_AUTOPOST.PV_TRAN_PREV_REC (RECORDINDEX).TRAN_IBR_BRN_CODE;



   IF S_MBRN_CORE_REC.NONCORE = '0'
      AND PKG_AUTOPOST.PV_TRAN_PREV_REC (RECORDINDEX).TRAN_ADVICE_DATE >
             S_MBRN_CORE_REC.MIG_DATE
   THEN
      UPDATE IBRADVICES
         SET IBRADVICES_RESP_ON_DATE = NULL,
             IBRADVICES_RESP_IN_BATCH_NUM = NULL,
             IBRADVICES_RESP_IN_BATCH_SL = NULL
       WHERE IBRADVICES_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
             AND IBRADVICES_ORIG_BRN_CODE =
                    PKG_AUTOPOST.PV_TRAN_PREV_REC (RECORDINDEX).
                     TRAN_IBR_BRN_CODE
             AND IBRADVICES_IBR_CODE =
                    PKG_AUTOPOST.PV_TRAN_PREV_REC (RECORDINDEX).TRAN_IBR_CODE
             AND IBRADVICES_YEAR = S_ADVICE_YEAR
             AND IBRADVICES_ADVICE_NUM =
                    PKG_AUTOPOST.PV_TRAN_PREV_REC (RECORDINDEX).
                     TRAN_ADVICE_NUM
             AND IBRADVICES_CONTRA_BRN_CODE =
                    DECODE (S_ADVGEN_CONT_BRN,
                            '1', PKG_AUTOPOST.PV_TRAN_KEY.TRAN_BRN_CODE,
                            IBRADVICES_CONTRA_BRN_CODE)
             AND IBRADVICES_ADVICE_DATE =
                    DECODE (
                       S_ADVGEN_ADV_DATE,
                       '1', PKG_AUTOPOST.PV_TRAN_PREV_REC (RECORDINDEX).
                             TRAN_ADVICE_DATE,
                       IBRADVICES_ADVICE_DATE);
   ELSE
      DELETE FROM IBRADVICES
            WHERE IBRADVICES_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
                  AND IBRADVICES_ORIG_BRN_CODE =
                         PKG_AUTOPOST.PV_TRAN_PREV_REC (RECORDINDEX).
                          TRAN_IBR_BRN_CODE
                  AND IBRADVICES_IBR_CODE =
                         PKG_AUTOPOST.PV_TRAN_PREV_REC (RECORDINDEX).
                          TRAN_IBR_CODE
                  AND IBRADVICES_YEAR = S_ADVICE_YEAR
                  AND IBRADVICES_ADVICE_NUM =
                         PKG_AUTOPOST.PV_TRAN_PREV_REC (RECORDINDEX).
                          TRAN_ADVICE_NUM
                  AND IBRADVICES_CONTRA_BRN_CODE =
                         DECODE (S_ADVGEN_CONT_BRN,
                                 '1', PKG_AUTOPOST.PV_TRAN_KEY.TRAN_BRN_CODE,
                                 IBRADVICES_CONTRA_BRN_CODE)
                  AND IBRADVICES_ADVICE_DATE =
                         DECODE (
                            S_ADVGEN_ADV_DATE,
                            '1', PKG_AUTOPOST.PV_TRAN_PREV_REC (RECORDINDEX).
                                  TRAN_ADVICE_DATE,
                            IBRADVICES_ADVICE_DATE);
   END IF;



   IF SQL%ROWCOUNT <> 1
   THEN
      V_ERROR_CODE := '9599';
      PKG_AUTOPOST.PV_ERR_MSG := 'Error in rejecting responding transaction';
      RAISE E_ERREXISTS;
   END IF;
END;