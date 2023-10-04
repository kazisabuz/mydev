CREATE OR REPLACE PROCEDURE SBL_IUT.sp_intsusglpm (P_ENTITY_NUM   IN NUMBER,
                                           P_BRNCODE      IN NUMBER,
                                           P_CURR_DATE    IN DATE)
IS
    W_ERROR_MSG                      VARCHAR2 (500);
    P_GL_BAL_AC                      NUMBER (18, 2);
    P_GL_BAL_BC                      NUMBER (18, 2);
    E_USEREXCEP                      EXCEPTION;
    P_BGL_BAL_AC                     NUMBER (18, 2);
    P_BGL_BAL_BC                     NUMBER (18, 2);
    V_INTSUSGL_GL_CODE               INTSUSGL.INTSUSGL_GL_CODE%TYPE;
    V_INTSUSGL_GL_CODE_BLOCK         INTSUSGL.INTSUSGL_GL_CODE_BLOCK%TYPE;
    V_INTSUSGL_GL_MISMATCH_BLOCKGL   INTSUSGL.INTSUSGL_GL_MISMATCH_BLOCKGL%TYPE;
    V_INTSUSGL_GL_MISMATCH           INTSUSGL.INTSUSGL_GL_MISMATCH%TYPE;
    v_SUSP_BAL                       lnsuspbal.LNSUSPBAL_SUSP_BAL%TYPE;
BEGIN
    BEGIN
        SELECT INTSUSGL_GL_CODE,
               INTSUSGL_GL_CODE_BLOCK,
               INTSUSGL_GL_MISMATCH_BLOCKGL,
               INTSUSGL_GL_MISMATCH
          INTO V_INTSUSGL_GL_CODE,
               V_INTSUSGL_GL_CODE_BLOCK,
               V_INTSUSGL_GL_MISMATCH_BLOCKGL,
               V_INTSUSGL_GL_MISMATCH
          FROM INTSUSGL;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            V_INTSUSGL_GL_CODE := NULL;
            V_INTSUSGL_GL_CODE_BLOCK := NULL;
            V_INTSUSGL_GL_MISMATCH_BLOCKGL := NULL;
            V_INTSUSGL_GL_MISMATCH := NULL;
        WHEN TOO_MANY_ROWS
        THEN
            W_ERROR_MSG := 'Error in INTSUSGL';
             DBMS_OUTPUT.put_line (W_ERROR_MSG);           
    END;

    IF V_INTSUSGL_GL_MISMATCH = '1'
    THEN
        SELECT SUM (LNSUSPBAL_SUSP_BAL)
          INTO v_SUSP_BAL
          FROM acnts, lnsuspbal
         WHERE     ACNTS_ENTITY_NUM = P_ENTITY_NUM
               AND LNSUSPBAL_ENTITY_NUM = P_ENTITY_NUM
               AND ACNTS_INTERNAL_ACNUM = LNSUSPBAL_ACNT_NUM
               AND ACNTS_INTERNAL_ACNUM NOT IN
                       (SELECT LNWRTOFF_ACNT_NUM
                          FROM lnwrtoff
                         WHERE LNWRTOFF_ENTITY_NUM = P_ENTITY_NUM)
               AND ACNTS_BRN_CODE = P_BRNCODE;

        GET_ASON_GLBAL (P_ENTITY_NUM,
                        P_BRNCODE,
                        V_INTSUSGL_GL_CODE,
                        NULL,
                        P_CURR_DATE,
                        P_CURR_DATE,
                        P_GL_BAL_AC,
                        P_GL_BAL_BC,
                        W_ERROR_MSG,
                        NULL,
                        NULL,
                        NULL);
        GET_ASON_GLBAL (P_ENTITY_NUM,
                        P_BRNCODE,
                        V_INTSUSGL_GL_CODE_BLOCK,
                        NULL,
                        P_CURR_DATE,
                        P_CURR_DATE,
                        P_BGL_BAL_AC,
                        P_BGL_BAL_BC,
                        W_ERROR_MSG,
                        NULL,
                        NULL,
                        NULL);
    END IF;

    ---DBMS_OUTPUT.put_line (P_GL_BAL_BC);
   --- DBMS_OUTPUT.put_line (v_SUSP_BAL);

   -- DBMS_OUTPUT.put_line (P_BGL_BAL_BC);

    IF P_BGL_BAL_BC = 0
    THEN
        IF ABS (v_SUSP_BAL) <> ABS (P_GL_BAL_BC)
        THEN
            W_ERROR_MSG := 'Interest Suspense GL Balance Mismatch with Account Level Interest Suspense GL Balance';
        ELSIF P_BGL_BAL_BC <> 0
        THEN
            IF ABS (v_SUSP_BAL) <> ABS (P_GL_BAL_BC)
            THEN
                NULL;
            END IF;
        END IF;
    END IF;

   ---DBMS_OUTPUT.put_line (W_ERROR_MSG);
EXCEPTION
    WHEN OTHERS
    THEN
        IF TRIM (W_ERROR_MSG) IS NOT NULL
        THEN
            W_ERROR_MSG := 'ERROR IN sp_intsusglpm ' || SQLERRM;
        END IF;

     ---   DBMS_OUTPUT.put_line (W_ERROR_MSG);
END;
/

