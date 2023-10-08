CREATE OR REPLACE FUNCTION FN_BIS_GET_ASON_GLBAL(V_ENTITY_NUM IN NUMBER,
                                             P_BRN_CODE    IN NUMBER,
                                             P_GL_ACC_CODE IN VARCHAR2,
                                             P_CURR_CODE   IN VARCHAR2 DEFAULT NULL,
                                             P_ASON_DATE   IN DATE,
                                             P_CURR_DATE   IN DATE,
                                             P_INC_UNAUTH_BAL IN     NUMBER DEFAULT 0
                                             ) RETURN NUMBER IS
  W_GL_BAL_AC NUMBER(18,3);
  W_GL_BAL_BC NUMBER(18,3);
  W_ERR_MSG   VARCHAR2(100);
  W_YEAR      NUMBER(4);
  W_SQL       VARCHAR2(2300);
  UNAUTHORISEZ_BAL   NUMBER(25, 3) DEFAULT 0;

  BEGIN
      PKG_ENTITY.SP_SET_ENTITY_CODE(V_ENTITY_NUM);
               GET_ASON_GLBAL (PKG_ENTITY.FN_GET_ENTITY_CODE,
                                             P_BRN_CODE,
                                             P_GL_ACC_CODE,
                                             P_CURR_CODE,
                                             P_ASON_DATE,
                                             P_CURR_DATE,
                                             W_GL_BAL_AC,
                                             W_GL_BAL_BC,
                                             W_ERR_MSG
                                             );




    IF (P_INC_UNAUTH_BAL = 1) THEN

        W_YEAR     := SP_GETFINYEAR(PKG_ENTITY.FN_GET_ENTITY_CODE,P_ASON_DATE);

        W_SQL := '  SELECT   NVL (SUM (DECODE (TRAN_DB_CR_FLG, ''C'', TRAN_BASE_CURR_EQ_AMT, 0)), 0) - NVL (SUM (DECODE (TRAN_DB_CR_FLG, ''D'', TRAN_BASE_CURR_EQ_AMT, 0)), 0)  BALANCE  FROM  TRAN' || W_YEAR || ' WHERE TRAN_AUTH_ON IS NULL AND TRAN_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND  TRAN_GLACC_CODE = :1
                         AND TRAN_DATE_OF_TRAN = :2   AND TRAN_BRN_CODE = :3';

        IF TRIM(P_CURR_CODE) IS NOT NULL THEN
          W_SQL := W_SQL || ' AND TRAN_CURR_CODE = :4  ';
        END IF;

        IF TRIM(P_CURR_CODE) IS NOT NULL   THEN
          EXECUTE IMMEDIATE W_SQL
            INTO UNAUTHORISEZ_BAL
            USING P_GL_ACC_CODE, P_ASON_DATE, P_BRN_CODE, P_CURR_CODE ;
        ELSE
          EXECUTE IMMEDIATE W_SQL
            INTO UNAUTHORISEZ_BAL
            USING P_GL_ACC_CODE, P_ASON_DATE, P_BRN_CODE;
        END IF;

        W_GL_BAL_BC := UNAUTHORISEZ_BAL +W_GL_BAL_BC;
      END IF;

  RETURN W_GL_BAL_BC;
   EXCEPTION
   WHEN OTHERS THEN
   RETURN 0;
   END FN_BIS_GET_ASON_GLBAL;

/
