CREATE OR REPLACE PACKAGE PKG_ALERT IS

  PROCEDURE SP_INSERT_TRAN_SMSALERT(P_ENTITY_NUM IN NUMBER,
                                    V_ERR_MSG    OUT VARCHAR2,
                                    V_ERR_CODE   OUT VARCHAR2);

  PROCEDURE SP_INSERT_SMSALERT(P_ENTITY_NUM             IN NUMBER,
                               P_SMSALERTQ_TYPE         IN VARCHAR2,
                               P_SMSALERTQ_BRN_CODE     IN NUMBER,
                               P_SMSALERTQ_DATE_OF_TRAN IN DATE,
                               P_SMSALERTQ_BATCH_NUMBER IN NUMBER,
                               P_SMSALERTQ_BATCH_SL_NUM IN NUMBER,
                               P_SMSALERTQ_SRC_TABLE    IN VARCHAR2,
                               P_SMSALERTQ_SRC_KEY      IN VARCHAR2,
                               P_SMSALERTQ_DISP_TEXT    IN VARCHAR2);
END PKG_ALERT;
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/


GRANT EXECUTE ON PKG_ALERT TO RL_SBLCRS;

CREATE OR REPLACE PACKAGE BODY PKG_ALERT IS

  PROCEDURE SP_INSERT_SMSALERT(P_ENTITY_NUM             IN NUMBER,
                               P_SMSALERTQ_TYPE         IN VARCHAR2,
                               P_SMSALERTQ_BRN_CODE     IN NUMBER,
                               P_SMSALERTQ_DATE_OF_TRAN IN DATE,
                               P_SMSALERTQ_BATCH_NUMBER IN NUMBER,
                               P_SMSALERTQ_BATCH_SL_NUM IN NUMBER,
                               P_SMSALERTQ_SRC_TABLE    IN VARCHAR2,
                               P_SMSALERTQ_SRC_KEY      IN VARCHAR2,
                               P_SMSALERTQ_DISP_TEXT    IN VARCHAR2) IS
  BEGIN
    PKG_ENTITY.SP_SET_ENTITY_CODE(P_ENTITY_NUM);
    <<INSERTSMSQALERTQ>>
    BEGIN
      INSERT INTO SMSALERTQ
        (SMSALERTQ_ENTITY_NUM,
         SMSALERTQ_TYPE,
         SMSALERTQ_BRN_CODE,
         SMSALERTQ_DATE_OF_TRAN,
         SMSALERTQ_BATCH_NUMBER,
         SMSALERTQ_BATCH_SL_NUM,
         SMSALERTQ_SRC_TABLE,
         SMSALERTQ_SRC_KEY,
         SMSALERTQ_DISP_TEXT,
         SMSALERTQ_REQ_TIME)
      VALUES
        (PKG_ENTITY.FN_GET_ENTITY_CODE,
         P_SMSALERTQ_TYPE,
         P_SMSALERTQ_BRN_CODE,
         P_SMSALERTQ_DATE_OF_TRAN,
         P_SMSALERTQ_BATCH_NUMBER,
         0,
         NVL(P_SMSALERTQ_SRC_TABLE,' '),
         NVL(P_SMSALERTQ_SRC_KEY,' '),
         P_SMSALERTQ_DISP_TEXT,
         SYSDATE);
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END INSERTSMSQALERTQ;

  END SP_INSERT_SMSALERT;

  PROCEDURE SP_INSERT_TRAN_SMSALERT(P_ENTITY_NUM IN NUMBER,
                                    V_ERR_MSG    OUT VARCHAR2,
                                    V_ERR_CODE   OUT VARCHAR2) IS
    W_ERR_CODE VARCHAR2(4);
    W_ERR_MSG  VARCHAR2(1000);
  BEGIN

    PKG_ENTITY.SP_SET_ENTITY_CODE(P_ENTITY_NUM);
    <<SMSCHECK>>
    W_ERR_CODE := '0000';
    W_ERR_MSG  := ' ';
    SP_INSERT_SMSALERT(PKG_ENTITY.FN_GET_ENTITY_CODE,
                       'TR',
                       PKG_AUTOPOST.PV_TRAN_KEY.TRAN_BRN_CODE,
                       PKG_AUTOPOST.PV_TRAN_KEY.TRAN_DATE_OF_TRAN,
                       PKG_AUTOPOST.PV_TRAN_KEY.TRAN_BATCH_NUMBER,
                       PKG_AUTOPOST.PV_TRAN_KEY.TRAN_BATCH_SL_NUM,
                       PKG_AUTOPOST.PV_TRANBAT.TRANBAT_SOURCE_TABLE,
                       PKG_AUTOPOST.PV_TRANBAT.TRANBAT_SOURCE_KEY,
                       ' ');
  EXCEPTION
    WHEN OTHERS THEN
      W_ERR_MSG  := SUBSTR('Error in SMSQ insert -' || SQLERRM, 1, 1000);
      W_ERR_CODE := '9532';
      V_ERR_MSG  := W_ERR_MSG;
      V_ERR_CODE := W_ERR_CODE;
  END SP_INSERT_TRAN_SMSALERT;
END PKG_ALERT;
/


GRANT EXECUTE ON PKG_ALERT TO RL_SBLCRS;
