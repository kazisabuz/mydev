CREATE OR REPLACE PACKAGE PKG_CASHTRANRPT IS


  PROCEDURE SP_CASHTRANRPT(V_ENTITY_NUM IN NUMBER,
                           P_BRN_CODE   IN NUMBER,
                           P_BRN_LIST   IN NUMBER,
                           P_FROM_DATE  IN VARCHAR2,
                           P_UPTO_DATE  IN VARCHAR2,
                           P_RPT_CODE   IN VARCHAR2,
                           P_TEMP_SL    IN OUT NUMBER,
                           P_ERROR      OUT VARCHAR2,
                           P_CTR_FLG    IN VARCHAR2 DEFAULT '0');

  PROCEDURE SP_GOAMLSRPT(V_ENTITY_NUM 	IN NUMBER,
                           P_BRN_CODE   IN NUMBER,
                           P_BRN_LIST   IN NUMBER,
                           P_TABLE_NAME	IN VARCHAR2,
						   P_DATE_TYPE  IN VARCHAR2,
						   P_DATE  		IN VARCHAR2,
						   P_MONTH  	IN VARCHAR2,
                           P_TEMP_SL    IN OUT NUMBER,
                           P_ERROR      OUT VARCHAR2);

  FUNCTION FN_CHK_AMLCTRIGN(V_ENTITY_NUM     IN NUMBER,
                            P_INTERNAL_ACNUM IN NUMBER,
                            P_TRAN_DATE      IN DATE,
                            P_BRN_CODE       IN NUMBER DEFAULT 0,
                            P_BATCH_NUM      IN NUMBER DEFAULT 0,
                            P_BATCH_SLNUM    IN NUMBER DEFAULT 0,
                            P_TRAN_TYPE      IN VARCHAR2 DEFAULT NULL,
                            P_DBCR_FLG       IN VARCHAR2 DEFAULT NULL)
    RETURN CHAR;

  FUNCTION FN_CTRIGN_AMT(V_ENTITY_NUM     IN NUMBER,
                         P_INTERNAL_ACNUM IN NUMBER,
                         P_FROM_DATE      IN DATE,
                         P_UPTO_DATE      IN DATE,
                         P_TRAN_TYPE      IN VARCHAR2 DEFAULT NULL,
                         P_DBCR_FLG       IN VARCHAR2 DEFAULT NULL)
    RETURN NUMBER;
END PKG_CASHTRANRPT;

/

CREATE OR REPLACE PACKAGE BODY PKG_CASHTRANRPT IS
  USR_EXCEP EXCEPTION;

  W_SQL          VARCHAR2(2300);
  W_ERROR        VARCHAR2(1000);
  W_BRN_CODE     NUMBER(6);
  W_BRN_LIST     NUMBER(6);
  W_FROM_DATE    DATE;
  W_UPTO_DATE    DATE;
  W_RPT_CODE     VARCHAR2(6);
  W_TEMP_SL      NUMBER(6);
  W_INDIV_TRAN   NUMBER(18, 3);
  W_AMT_PM       NUMBER(18, 3);
  W_FIN_YEAR     NUMBER(4);
  W_CTR_FLG      CHAR(1);
  W_TRAN_RPT_AMT NUMBER(18, 3);
  PROCEDURE INIT_PARA IS
  BEGIN
    W_SQL          := '';
    W_ERROR        := '';
    W_BRN_CODE     := 0;
    W_BRN_LIST     := 0;
    W_FROM_DATE    := NULL;
    W_UPTO_DATE    := NULL;
    W_RPT_CODE     := '';
    W_TEMP_SL      := 0;
    W_INDIV_TRAN   := 0;
    W_AMT_PM       := 0;
    W_FIN_YEAR     := 0;
    W_CTR_FLG      := '0';
    W_TRAN_RPT_AMT := 0;
  END INIT_PARA;
  PROCEDURE FETCH_CTRRPTPM IS
  BEGIN
    SELECT CTRRPTPM_CUTOFF_INDIV_TRAN,
           CTRRPTPM_CUTOFF_AMT_PM,
           CTRRPTPM_TRAN_REPORT_AMT
      INTO W_INDIV_TRAN, W_AMT_PM, W_TRAN_RPT_AMT
      FROM CTRRPTPM
     WHERE CTRRPTPM_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
       AND CTRRPTPM_REPORT_CODE = W_RPT_CODE;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      W_ERROR := 'Cash Transaction Report Parameter Not Specified ';
      RAISE USR_EXCEP;
  END FETCH_CTRRPTPM;
  PROCEDURE INSERT_INDIV_TRAN IS
  BEGIN
    IF (W_INDIV_TRAN > 0) THEN
      --Prasanth NS-CHN-10-02-2011-beg-removed
      --W_SQL := 'SELECT /*+ INDEX(A,IDX_AMLACTURNOVER)*/ ACTOVER_BRN_CODE,ACTOVER_INTERNAL_ACNUM,ACTOVER_DATE FROM AMLACTURNOVER A WHERE ACTOVER_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND  ACTOVER_INTERNAL_ACNUM > 0
      /*AND ACTOVER_DATE >=' || CHR(39) || W_FROM_DATE ||
               CHR(39) || ' AND ACTOVER_DATE <= ' || CHR(39) || W_UPTO_DATE ||
               CHR(39) || ' AND (ACTOVER_MAX_CASH_DB > ' || W_INDIV_TRAN ||
               ' OR ACTOVER_MAX_CASH_CR > ' || W_INDIV_TRAN || ' ) ';
      IF (W_BRN_CODE > 0) THEN
        W_SQL := W_SQL || ' AND ACTOVER_BRN_CODE =' || W_BRN_CODE;
      END IF;
      IF (W_BRN_LIST > 0) THEN
        W_SQL := W_SQL ||
                 ' AND ACTOVER_BRN_CODE IN (SELECT BRNLISTDTL_BRN_CODE FROM BRNLISTDTL WHERE BRNLISTDTL_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND  BRNLISTDTL_LIST_NUM =' ||
                 W_BRN_LIST || ')';
      END IF;
      EXECUTE IMMEDIATE W_SQL BULK COLLECT
        INTO ACT_REC;
      IF ACT_REC.FIRST IS NOT NULL THEN
        FOR J IN ACT_REC.FIRST .. ACT_REC.LAST LOOP
          IF (PKG_PMLEXEMPT.SP_CHECK_EXCEMPT(PKG_ENTITY.FN_GET_ENTITY_CODE,
                                             ACT_REC(J).V_ACT_INTERNAL_ACNUM,
                                             0)) = FALSE THEN
            --Prasanth NS-CHN-08-03-2010-Changed-Query
            W_SQL := 'INSERT INTO RTMPCTINDIV (SELECT TMPSL,TRAN_ACING_BRN_CODE,TRAN_INTERNAL_ACNUM,
            TRAN_BRN_CODE||''/''||TO_CHAR(TRAN_DATE_OF_TRAN,''DD-Mon-YYYY'')||''/''||TRAN_BATCH_NUMBER||''/''||TRAN_BATCH_SL_NUM,
            TRAN_BASE_CURR_EQ_AMT,TRAN_DB_CR_FLG, NARR_DTL ,TRAN_DATE_OF_TRAN FROM (SELECT ' ||
                     W_TEMP_SL ||
                     ' TMPSL,TRAN_ACING_BRN_CODE,TRAN_INTERNAL_ACNUM,TRAN_BRN_CODE,TRAN_DATE_OF_TRAN,TRAN_BATCH_NUMBER,TRAN_BATCH_SL_NUM,TRAN_BASE_CURR_EQ_AMT,TRAN_DB_CR_FLG,
                     DECODE(TRIM(TRAN_NARR_DTL1),NULL,''Cash Transaction'',TRAN_NARR_DTL1) NARR_DTL,TRAN_TYPE_OF_TRAN FROM TRAN' ||
                     W_FIN_YEAR ||
                     ' WHERE TRAN_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND TRAN_TYPE_OF_TRAN = ''3'' AND TRAN_ACING_BRN_CODE = ' ||
                     ACT_REC(J).V_ACT_BRN || ' AND TRAN_INTERNAL_ACNUM = ' ||
                     ACT_REC(J).V_ACT_INTERNAL_ACNUM ||
                     ' AND TRAN_AUTH_ON IS NOT NULL AND TRAN_DATE_OF_TRAN =' ||
                     CHR(39) || ACT_REC(J)
                    .V_ACT_DATE || CHR(39) ||
                     ' AND TRAN_BASE_CURR_EQ_AMT > ' || W_INDIV_TRAN;
            W_SQL := W_SQL ||
                     ') WHERE ''0'' = PKG_CASHTRANRPT.FN_CHK_AMLCTRIGN(PKG_ENTITY.FN_GET_ENTITY_CODE,
                     TRAN_INTERNAL_ACNUM,TRAN_DATE_OF_TRAN,TRAN_BRN_CODE,TRAN_BATCH_NUMBER,TRAN_BATCH_SL_NUM,TRAN_TYPE_OF_TRAN))';
            EXECUTE IMMEDIATE W_SQL;
          END IF;
        END LOOP;
      END IF;*/
      --Prasanth NS-CHN-10-02-2011-end-removed

      --Prasanth NS-CHN-10-02-2011-beg
      W_SQL := 'INSERT INTO RTMPCTINDIV (SELECT TMPSL,TRAN_ACING_BRN_CODE,TRAN_INTERNAL_ACNUM,
            TRAN_BRN_CODE||''/''||TO_CHAR(TRAN_DATE_OF_TRAN,''DD-Mon-YYYY'')||''/''||TRAN_BATCH_NUMBER||''/''||TRAN_BATCH_SL_NUM,
            TRAN_BASE_CURR_EQ_AMT,TRAN_DB_CR_FLG, NARR_DTL ,TRAN_DATE_OF_TRAN FROM (SELECT ' ||
               W_TEMP_SL ||
               ' TMPSL,TRAN_ACING_BRN_CODE,TRAN_INTERNAL_ACNUM,TRAN_BRN_CODE,TRAN_DATE_OF_TRAN,TRAN_BATCH_NUMBER,TRAN_BATCH_SL_NUM,TRAN_BASE_CURR_EQ_AMT,TRAN_DB_CR_FLG,
                     DECODE(TRIM(TRAN_NARR_DTL1),NULL,''Cash Transaction'',TRAN_NARR_DTL1) NARR_DTL,TRAN_TYPE_OF_TRAN FROM TRAN' ||
               W_FIN_YEAR ||
               ' WHERE TRAN_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND TRAN_TYPE_OF_TRAN = ''3'' AND TRAN_INTERNAL_ACNUM > 0 AND TRAN_AUTH_ON IS NOT NULL AND TRAN_DATE_OF_TRAN >=' ||
               CHR(39) || W_FROM_DATE || CHR(39) ||
               ' AND TRAN_DATE_OF_TRAN <= ' || CHR(39) || W_UPTO_DATE ||
               CHR(39) || ' AND TRAN_BASE_CURR_EQ_AMT >= ' || W_INDIV_TRAN;
      IF (W_BRN_CODE > 0) THEN
        W_SQL := W_SQL || ' AND TRAN_ACING_BRN_CODE =' || W_BRN_CODE;
      END IF;
      IF (W_BRN_LIST > 0) THEN
        W_SQL := W_SQL ||
                 ' AND TRAN_ACING_BRN_CODE IN (SELECT BRNLISTDTL_BRN_CODE FROM BRNLISTDTL WHERE BRNLISTDTL_LIST_NUM =' ||
                 W_BRN_LIST || ')';
      END IF;
      W_SQL := W_SQL ||
               ') WHERE ''0'' = PKG_CASHTRANRPT.FN_CHK_AMLCTRIGN(PKG_ENTITY.FN_GET_ENTITY_CODE,
                     TRAN_INTERNAL_ACNUM,TRAN_DATE_OF_TRAN,TRAN_BRN_CODE,TRAN_BATCH_NUMBER,TRAN_BATCH_SL_NUM,TRAN_TYPE_OF_TRAN))';
      EXECUTE IMMEDIATE W_SQL;

      DELETE FROM RTMPCTINDIV
       WHERE RTMPCTIND_TEMP_SER = W_TEMP_SL
         AND PKG_PMLEXEMPT.SP_CHECK_EXCEMPT_WRAP(PKG_ENTITY.FN_GET_ENTITY_CODE,
                                                 RTMPCTIND_INTERNAL_ACNUM,
                                                 0) = 0;
      --Prasanth NS-CHN-10-02-2011-end

    END IF;
  END INSERT_INDIV_TRAN;
  PROCEDURE INSERT_OVERALL_PM IS
  BEGIN
    --Prasanth NS-CHN-10-02-2011-beg
    W_SQL := 'INSERT INTO RTMPCTOVERALL (SELECT ' || W_TEMP_SL ||
             ',ACING_BRN_CODE,INTERNAL_ACNUM, CASE WHEN TRAN_BCAMT_DEP > ' ||
             W_AMT_PM || ' THEN TRAN_BCAMT_DEP ELSE 0 END,
CASE WHEN TRAN_BCAMT_WITHD  > ' || W_AMT_PM ||
             ' THEN TRAN_BCAMT_WITHD ELSE 0 END FROM
    (SELECT ACING_BRN_CODE,INTERNAL_ACNUM, TRAN_BCAMT_DEP-PKG_CASHTRANRPT.FN_CTRIGN_AMT(PKG_ENTITY.FN_GET_ENTITY_CODE,INTERNAL_ACNUM,' ||
             CHR(39) || W_FROM_DATE || CHR(39) || ',' || CHR(39) ||
             W_UPTO_DATE || CHR(39) ||
             ',''3'',''C'') TRAN_BCAMT_DEP,
             TRAN_BCAMT_WITHD-PKG_CASHTRANRPT.FN_CTRIGN_AMT(PKG_ENTITY.FN_GET_ENTITY_CODE,INTERNAL_ACNUM,' ||
             CHR(39) || W_FROM_DATE || CHR(39) || ',' || CHR(39) ||
             W_UPTO_DATE || CHR(39) ||
             ',''3'',''D'') TRAN_BCAMT_WITHD FROM
    (SELECT ACING_BRN_CODE,INTERNAL_ACNUM, SUM(TRAN_BCAMT_DEP) TRAN_BCAMT_DEP, SUM(TRAN_BCAMT_WITHD) TRAN_BCAMT_WITHD FROM
    (SELECT TRAN_ACING_BRN_CODE ACING_BRN_CODE,TRAN_INTERNAL_ACNUM INTERNAL_ACNUM,
    SUM(DECODE(TRAN_DB_CR_FLG,''C'',TRAN_BASE_CURR_EQ_AMT,0)) TRAN_BCAMT_DEP,
    SUM(DECODE(TRAN_DB_CR_FLG,''D'',TRAN_BASE_CURR_EQ_AMT,0)) TRAN_BCAMT_WITHD FROM TRAN' ||
             W_FIN_YEAR ||
             ' WHERE ''0'' = PKG_CASHTRANRPT.FN_CHK_AMLCTRIGN(PKG_ENTITY.FN_GET_ENTITY_CODE,
             TRAN_INTERNAL_ACNUM,TRAN_DATE_OF_TRAN,TRAN_BRN_CODE,
             TRAN_BATCH_NUMBER,TRAN_BATCH_SL_NUM,TRAN_TYPE_OF_TRAN)
             AND TRAN_TYPE_OF_TRAN = ''3'' AND TRAN_INTERNAL_ACNUM > 0 AND TRAN_AUTH_ON IS NOT NULL AND TRAN_DATE_OF_TRAN >=' ||
             CHR(39) || W_FROM_DATE || CHR(39) ||
             ' AND TRAN_DATE_OF_TRAN <= ' || CHR(39) || W_UPTO_DATE ||
             CHR(39);
    IF (W_BRN_CODE > 0) THEN
      W_SQL := W_SQL || ' AND TRAN_ACING_BRN_CODE =' || W_BRN_CODE;
    END IF;
    IF (W_BRN_LIST > 0) THEN
      W_SQL := W_SQL ||
               ' AND TRAN_ACING_BRN_CODE IN (SELECT BRNLISTDTL_BRN_CODE FROM BRNLISTDTL WHERE BRNLISTDTL_LIST_NUM =' ||
               W_BRN_LIST || ')';
    END IF;
    W_SQL := W_SQL ||
             ' GROUP BY TRAN_ACING_BRN_CODE,TRAN_INTERNAL_ACNUM UNION ALL SELECT RTMPCTIND_ACING_BRN_CODE ACING_BRN_CODE,RTMPCTIND_INTERNAL_ACNUM INTERNAL_ACNUM,-SUM(DECODE(RTMPCTIND_DB_CR_FLG,''C'',RTMPCTIND_TRAN_AMT,0)) TRAN_BCAMT_DEP, -SUM(DECODE(RTMPCTIND_DB_CR_FLG,''D'',RTMPCTIND_TRAN_AMT,0)) TRAN_BCAMT_WITHD FROM RTMPCTINDIV WHERE RTMPCTIND_TEMP_SER =' ||
             W_TEMP_SL ||
             ' GROUP BY RTMPCTIND_ACING_BRN_CODE,RTMPCTIND_INTERNAL_ACNUM) GROUP BY ACING_BRN_CODE,INTERNAL_ACNUM) WHERE (TRAN_BCAMT_DEP  > ' ||
             W_AMT_PM || ' OR TRAN_BCAMT_WITHD > ' || W_AMT_PM || ')';
    W_SQL := W_SQL || '))';
    --Prasanth NS-CHN-10-02-2011-end

    --Prasanth NS-CHN-10-02-2011-beg-removed
    /*W_SQL := 'INSERT INTO RTMPCTOVERALL (SELECT ' || W_TEMP_SL ||
           ',ACING_BRN_CODE,INTERNAL_ACNUM, CASE WHEN TRAN_BCAMT_DEP > ' ||
           W_AMT_PM ||
           ' THEN TRAN_BCAMT_DEP ELSE 0 END, CASE WHEN TRAN_BCAMT_WITHD  > ' ||
           W_AMT_PM ||
           ' THEN TRAN_BCAMT_WITHD ELSE 0 END FROM
           (SELECT ACING_BRN_CODE,INTERNAL_ACNUM,
           TRAN_BCAMT_DEP-PKG_CASHTRANRPT.FN_CTRIGN_AMT(PKG_ENTITY.FN_GET_ENTITY_CODE,INTERNAL_ACNUM,' ||
           CHR(39) || W_FROM_DATE || CHR(39) || ',' || CHR(39) ||
           W_UPTO_DATE || CHR(39) ||
           ',''3'',''C'') TRAN_BCAMT_DEP,
           TRAN_BCAMT_WITHD-PKG_CASHTRANRPT.FN_CTRIGN_AMT(PKG_ENTITY.FN_GET_ENTITY_CODE,INTERNAL_ACNUM,' ||
           CHR(39) || W_FROM_DATE || CHR(39) || ',' || CHR(39) ||
           W_UPTO_DATE || CHR(39) ||
           ',''3'',''D'') TRAN_BCAMT_WITHD FROM
    (SELECT /*+ INDEX(A,IDX_AMLACTURNOVER)*/ /* ACTOVER_BRN_CODE ACING_BRN_CODE,ACTOVER_INTERNAL_ACNUM INTERNAL_ACNUM,
                          SUM(ACTOVER_TOTAL_CASH_CRS) TRAN_BCAMT_DEP,
                           SUM(ACTOVER_TOTAL_CASH_DBS) TRAN_BCAMT_WITHD FROM AMLACTURNOVER A WHERE ACTOVER_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND  ACTOVER_INTERNAL_ACNUM > 0 AND ACTOVER_DATE >=' ||
                                 CHR(39) || W_FROM_DATE || CHR(39) || ' AND ACTOVER_DATE <= ' ||
                                 CHR(39) || W_UPTO_DATE || CHR(39);
                        IF (W_BRN_CODE > 0) THEN
                          W_SQL := W_SQL || ' AND ACTOVER_BRN_CODE =' || W_BRN_CODE;
                        END IF;
                        IF (W_BRN_LIST > 0) THEN
                          W_SQL := W_SQL ||
                                   ' AND ACTOVER_BRN_CODE IN (SELECT BRNLISTDTL_BRN_CODE FROM BRNLISTDTL WHERE BRNLISTDTL_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND  BRNLISTDTL_LIST_NUM =' ||
                                   W_BRN_LIST || ')';
                        END IF;
                        W_SQL := W_SQL ||
                                 ' GROUP BY ACTOVER_BRN_CODE,ACTOVER_INTERNAL_ACNUM)) WHERE (TRAN_BCAMT_DEP > ' ||
                                 W_AMT_PM || ' OR TRAN_BCAMT_WITHD > ' || W_AMT_PM || ')';
                        W_SQL := W_SQL || ') ';
                        EXECUTE IMMEDIATE W_SQL;*/
    --Prasanth NS-CHN-10-02-2011-end-removed

    EXECUTE IMMEDIATE W_SQL;

    DELETE FROM RTMPCTOVERALL
     WHERE RTMPCTOA_TEMP_SER = W_TEMP_SL
       AND PKG_PMLEXEMPT.SP_CHECK_EXCEMPT_WRAP(PKG_ENTITY.FN_GET_ENTITY_CODE,
                                               RTMPCTOA_INTERNAL_ACNUM,
                                               0) = 0;
  END INSERT_OVERALL_PM;
  PROCEDURE UPD_OVERALLTOINDIV IS
    W_TEMP_DATE VARCHAR2(12);
  BEGIN
    --Prasanth NS-CHN-08-03-2010-Changed-Query
    W_SQL := 'SELECT TRAN_ACING_BRN_CODE,TRAN_INTERNAL_ACNUM,TRAN_BRN_CODE||''/''||TO_CHAR(TRAN_DATE_OF_TRAN,''DD-Mon-YYYY'')||''/''||TRAN_BATCH_NUMBER||''/''||TRAN_BATCH_SL_NUM,
    TRAN_BASE_CURR_EQ_AMT,TRAN_DB_CR_FLG,NARR_DTL FROM (SELECT TRAN_ACING_BRN_CODE,TRAN_INTERNAL_ACNUM,TRAN_BRN_CODE,TRAN_DATE_OF_TRAN,TRAN_BATCH_NUMBER,TRAN_BATCH_SL_NUM,
    TRAN_BASE_CURR_EQ_AMT,TRAN_DB_CR_FLG,DECODE(TRIM(TRAN_NARR_DTL1),NULL,''Cash Transaction '',TRAN_NARR_DTL1) NARR_DTL,TRAN_TYPE_OF_TRAN FROM TRAN' ||
             W_FIN_YEAR ||
             ',RTMPCTOVERALL WHERE TRAN_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND  RTMPCTOA_TEMP_SER =' ||
             W_TEMP_SL ||
             ' AND TRAN_TYPE_OF_TRAN = ''3'' AND TRAN_INTERNAL_ACNUM > 0 AND TRAN_AUTH_ON IS NOT NULL AND TRAN_DATE_OF_TRAN >=' ||
             CHR(39) || W_FROM_DATE || CHR(39) ||
             ' AND TRAN_DATE_OF_TRAN <= ' || CHR(39) || W_UPTO_DATE ||
             CHR(39) || ' AND TRAN_ACING_BRN_CODE = RTMPCTOA_ACING_BRN_CODE AND TRAN_INTERNAL_ACNUM = RTMPCTOA_INTERNAL_ACNUM
                AND TRAN_BASE_CURR_EQ_AMT >= ' ||
             W_TRAN_RPT_AMT;
    IF (W_INDIV_TRAN <> 0) THEN
      W_SQL := W_SQL || ' AND TRAN_BASE_CURR_EQ_AMT <= ' || W_INDIV_TRAN;
    END IF;
    W_SQL := W_SQL ||
             ') WHERE ''0'' = PKG_CASHTRANRPT.FN_CHK_AMLCTRIGN(PKG_ENTITY.FN_GET_ENTITY_CODE,TRAN_INTERNAL_ACNUM,
             TRAN_DATE_OF_TRAN,TRAN_BRN_CODE,TRAN_BATCH_NUMBER,TRAN_BATCH_SL_NUM,TRAN_TYPE_OF_TRAN)';

    EXECUTE IMMEDIATE 'INSERT INTO RTMPAMLCTR (' || W_SQL || ') ';
    --    EXECUTE IMMEDIATE W_SQL BULK COLLECT
    --      INTO TRN_REC;
    FOR IDX IN (SELECT * FROM RTMPAMLCTR) LOOP
      --    IF TRN_REC.FIRST IS NOT NULL THEN
      --      FOR J IN TRN_REC.FIRST .. TRN_REC.LAST LOOP
      W_TEMP_DATE := SUBSTR(IDX.RTMPACTR_TRAN_REF_NUM,
                            INSTR(IDX.RTMPACTR_TRAN_REF_NUM, '/') + 1,
                            11); --Arunmugesh.J 14-Sep-2009
      <<INS_RTMPCTINDIV>>
      BEGIN
        INSERT INTO RTMPCTINDIV
          (RTMPCTIND_TEMP_SER,
           RTMPCTIND_ACING_BRN_CODE,
           RTMPCTIND_INTERNAL_ACNUM,
           RTMPCTIND_TRN_REF_NUM,
           RTMPCTIND_TRAN_AMT,
           RTMPCTIND_DB_CR_FLG,
           RTMPCTIND_NARR_DTL1,
           RTMPCTIND_TRAN_DATE) --Arunmugesh.J 14-Sep-2009
        VALUES
          (W_TEMP_SL,
           IDX.RTMPACTR_BRN_CODE,
           IDX.RTMPACTR_INTERNAL_ACNUM,
           IDX.RTMPACTR_TRAN_REF_NUM,
           IDX.RTMPACTR_BASE_CURR_AMT,
           IDX.RTMPACTR_DB_CR_FLG,
           IDX.RTMPACTR_TRAN_NARR,
           TO_DATE(W_TEMP_DATE, 'DD-Mon-YYYY')); --Arunmugesh.J 14-Sep-2009
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          W_ERROR := '';
      END INS_RTMPCTINDIV;
    END LOOP;
    --    END IF;
  END UPD_OVERALLTOINDIV;
  PROCEDURE SP_CASHTRANRPT(V_ENTITY_NUM IN NUMBER,
                           P_BRN_CODE   IN NUMBER,
                           P_BRN_LIST   IN NUMBER,
                           P_FROM_DATE  IN VARCHAR2,
                           P_UPTO_DATE  IN VARCHAR2,
                           P_RPT_CODE   IN VARCHAR2,
                           P_TEMP_SL    IN OUT NUMBER,
                           P_ERROR      OUT VARCHAR2,
                           P_CTR_FLG    IN VARCHAR2 DEFAULT '0') IS
  BEGIN
    --ENTITY CODE COMMONLY ADDED - 06-11-2009  - BEG
    PKG_ENTITY.SP_SET_ENTITY_CODE(V_ENTITY_NUM);
    --ENTITY CODE COMMONLY ADDED - 06-11-2009  - END
    <<START_PROC>>
    BEGIN
      INIT_PARA;
      IF (P_BRN_CODE IS NULL OR P_BRN_CODE = 0) THEN
        W_BRN_CODE := 0;
      ELSE
        W_BRN_CODE := P_BRN_CODE;
      END IF;
      IF (P_BRN_LIST IS NULL OR P_BRN_LIST = 0) THEN
        W_BRN_LIST := 0;
      ELSE
        W_BRN_LIST := P_BRN_LIST;
      END IF;
      W_FROM_DATE := TO_DATE(P_FROM_DATE, 'DD-MM-YYYY');
      W_UPTO_DATE := TO_DATE(P_UPTO_DATE, 'DD-MM-YYYY');
      W_FIN_YEAR  := SP_GETFINYEAR(PKG_ENTITY.FN_GET_ENTITY_CODE,
                                   W_FROM_DATE);
      IF TRIM(P_RPT_CODE) IS NULL THEN
        W_RPT_CODE := '';
      ELSE
        W_RPT_CODE := P_RPT_CODE;
      END IF;
      IF (P_TEMP_SL IS NULL OR P_TEMP_SL = 0) THEN
        W_TEMP_SL := 0;
      ELSE
        W_TEMP_SL := P_TEMP_SL;
      END IF;
      IF (W_TEMP_SL = 0) THEN
        W_TEMP_SL := PKG_PB_GLOBAL.SP_GET_REPORT_SL(PKG_ENTITY.FN_GET_ENTITY_CODE);
      END IF;
      IF TRIM(P_CTR_FLG) IS NULL THEN
        W_CTR_FLG := '0';
      ELSE
        W_CTR_FLG := P_CTR_FLG;
      END IF;
      DELETE FROM AMLCHKLOGSTAT WHERE AMLCHKLOG_TMP_SL = W_TEMP_SL;
      IF (TRIM(W_RPT_CODE) IS NULL) THEN
        W_ERROR := 'Mandatory Fields Should be Specified ';
        RAISE USR_EXCEP;
      END IF;
      FETCH_CTRRPTPM;
      INSERT_INDIV_TRAN;
      INSERT_OVERALL_PM;
      IF (W_CTR_FLG = '1') THEN
        UPD_OVERALLTOINDIV;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        IF TRIM(W_ERROR) IS NULL THEN
          W_ERROR := SUBSTR('Error in SP_CASHTRANRPT ' || SQLERRM, 1, 1000);
        END IF;
    END START_PROC;
    PKG_CHECK_DUP_CLIENT.INSERT_AMLCHKLOGSTAT(PKG_ENTITY.FN_GET_ENTITY_CODE,
                                              W_TEMP_SL,
                                              '1',
                                              W_ERROR);
    COMMIT;
    P_TEMP_SL := W_TEMP_SL;
    P_ERROR   := W_ERROR;
  END SP_CASHTRANRPT;



  --Prasanth NS-CHN-09-03-2010-beg
  FUNCTION FN_CHK_AMLCTRIGN(V_ENTITY_NUM     IN NUMBER,
                            P_INTERNAL_ACNUM IN NUMBER,
                            P_TRAN_DATE      IN DATE,
                            P_BRN_CODE       IN NUMBER DEFAULT 0,
                            P_BATCH_NUM      IN NUMBER DEFAULT 0,
                            P_BATCH_SLNUM    IN NUMBER DEFAULT 0,
                            P_TRAN_TYPE      IN VARCHAR2 DEFAULT NULL,
                            P_DBCR_FLG       IN VARCHAR2 DEFAULT NULL)
    RETURN CHAR IS
    W_RET_FLG CHAR(1) DEFAULT '0';
    W_DUMMY   NUMBER(18, 3);
    W_SQL_STR VARCHAR2(4000);
  BEGIN
    PKG_ENTITY.SP_SET_ENTITY_CODE(V_ENTITY_NUM);
    <<START_PARA>>
    BEGIN
      W_SQL_STR := ' SELECT AMLCTRIG_TRAN_AMOUNT FROM AMLCTRIG WHERE AMLCTRIG_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
      AND AMLCTRIG_INTERNAL_ACNUM = :2 AND AMLCTRIG_TRAN_DATE = :3
      AND AMLCTRIG_TRAN_BRN_CODE = DECODE(:4, 0, AMLCTRIG_TRAN_BRN_CODE, :5)
      AND AMLCTRIG_TRAN_BATCH_NUM = DECODE(:6, 0, AMLCTRIG_TRAN_BATCH_NUM, :7)
      AND AMLCTRIG_TRAN_BATCH_SL = DECODE(:8, 0, AMLCTRIG_TRAN_BATCH_SL, :9)
      AND AMLCTRIG_IGNORE_FLG = 1
      AND AMLCTRIG_TYPE_OF_TRAN = DECODE(TRIM(:10),NULL,AMLCTRIG_TYPE_OF_TRAN,TRIM(:11))
      AND AMLCTRIG_DB_CR_FLG = DECODE(TRIM(:12),NULL,AMLCTRIG_DB_CR_FLG,TRIM(:13))';
      EXECUTE IMMEDIATE W_SQL_STR
        INTO W_DUMMY
        USING P_INTERNAL_ACNUM, P_TRAN_DATE, P_BRN_CODE, P_BRN_CODE, P_BATCH_NUM, P_BATCH_NUM, P_BATCH_SLNUM, P_BATCH_SLNUM, P_TRAN_TYPE, P_TRAN_TYPE, P_DBCR_FLG, P_DBCR_FLG;
      W_RET_FLG := '1';
    EXCEPTION
      WHEN OTHERS THEN
        W_RET_FLG := '0';
    END START_PARA;
    RETURN NVL(W_RET_FLG, '0');
  END FN_CHK_AMLCTRIGN;

  FUNCTION FN_CTRIGN_AMT(V_ENTITY_NUM     IN NUMBER,
                         P_INTERNAL_ACNUM IN NUMBER,
                         P_FROM_DATE      IN DATE,
                         P_UPTO_DATE      IN DATE,
                         P_TRAN_TYPE      IN VARCHAR2 DEFAULT NULL,
                         P_DBCR_FLG       IN VARCHAR2 DEFAULT NULL)
    RETURN NUMBER IS
    W_BC_AMT  NUMBER(18, 3) DEFAULT 0;
    W_SQL_STR VARCHAR2(4000);
  BEGIN
    PKG_ENTITY.SP_SET_ENTITY_CODE(V_ENTITY_NUM);
    <<START_PARA>>
    BEGIN
      IF TRIM(P_DBCR_FLG) IS NULL THEN
        W_SQL_STR := ' SELECT SUM(AMLCTRIG_TRAN_AMOUNT) FROM AMLCTRIG';
      ELSE
        W_SQL_STR := ' SELECT SUM(DECODE(AMLCTRIG_DB_CR_FLG,' || CHR(39) ||
                     P_DBCR_FLG || CHR(39) ||
                     ',AMLCTRIG_TRAN_AMOUNT,0)) FROM AMLCTRIG';
      END IF;
      W_SQL_STR := W_SQL_STR ||
                   ' WHERE AMLCTRIG_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND AMLCTRIG_INTERNAL_ACNUM = :2
      AND AMLCTRIG_TRAN_DATE >= :3 AND AMLCTRIG_TRAN_DATE <= :4
      AND AMLCTRIG_IGNORE_FLG = 1
      AND AMLCTRIG_TYPE_OF_TRAN = DECODE(TRIM(:5),NULL,AMLCTRIG_TYPE_OF_TRAN,TRIM(:6))';
      EXECUTE IMMEDIATE W_SQL_STR
        INTO W_BC_AMT
        USING P_INTERNAL_ACNUM, P_FROM_DATE, P_UPTO_DATE, P_TRAN_TYPE, P_TRAN_TYPE;
    EXCEPTION
      WHEN OTHERS THEN
        W_BC_AMT := 0;
    END START_PROC;
    RETURN NVL(W_BC_AMT, 0);
  END FN_CTRIGN_AMT;
  --Prasanth NS-CHN-09-03-2010-end

  PROCEDURE SP_GOAMLSRPT(V_ENTITY_NUM 	IN NUMBER,
                           P_BRN_CODE   IN NUMBER,
                           P_BRN_LIST   IN NUMBER,
                           P_TABLE_NAME	IN VARCHAR2,
						   P_DATE_TYPE  IN VARCHAR2,
						   P_DATE  		IN VARCHAR2,
						   P_MONTH  	IN VARCHAR2,
                           P_TEMP_SL    IN OUT NUMBER,
                           P_ERROR      OUT VARCHAR2) IS
	W_SQL_STR VARCHAR2(4000);
	W_BRANCH_CON_STR VARCHAR2(512);
	W_DATE_STR VARCHAR2(512);
    W_DATE_STR_2 VARCHAR2(512);
  BEGIN
    PKG_ENTITY.SP_SET_ENTITY_CODE(V_ENTITY_NUM);
    <<START_PROC>>
    BEGIN
      INIT_PARA;

	  IF P_BRN_LIST != 0 THEN
        W_BRANCH_CON_STR := ' AND A.TRAN_ACING_BRN_CODE IN  (SELECT BRNLISTDTL_BRN_CODE FROM BRNLISTDTL WHERE BRNLISTDTL_LIST_NUM = ' || P_BRN_LIST || ')';
    ELSIF P_BRN_CODE != 0 THEN
        W_BRANCH_CON_STR := ' AND A.TRAN_ACING_BRN_CODE = ' || P_BRN_CODE || ' ';
	  ELSE
        W_BRANCH_CON_STR := '';
      END IF;

	  IF P_DATE_TYPE  = 'MONTHLY' THEN
        W_DATE_STR := ' TO_CHAR(A.TRAN_VALUE_DATE,''MON-YYYY'')=''' || P_MONTH || '''';
        W_DATE_STR_2 := ' TO_CHAR(M.TRAN_VALUE_DATE,''MON-YYYY'')=''' || P_MONTH || '''';

      ELSE
        W_DATE_STR := ' TO_CHAR(A.TRAN_VALUE_DATE,''DD-MON-YYYY'')= ''' || P_DATE || '''';
        W_DATE_STR_2 := ' TO_CHAR(M.TRAN_VALUE_DATE,''DD-MON-YYYY'')= ''' || P_DATE || '''';
      END IF;


      IF (P_TEMP_SL IS NULL OR P_TEMP_SL = 0) THEN
        W_TEMP_SL := 0;
      ELSE
        W_TEMP_SL := P_TEMP_SL;
      END IF;

      IF (W_TEMP_SL = 0) THEN
        W_TEMP_SL := PKG_PB_GLOBAL.SP_GET_REPORT_SL(PKG_ENTITY.FN_GET_ENTITY_CODE);
      END IF;

	  DELETE FROM AMLCHKLOGSTAT WHERE AMLCHKLOG_TMP_SL = W_TEMP_SL;

	  W_SQL_STR := 'INSERT INTO RTMPCTINDIV(SELECT ' || W_TEMP_SL || ' RTMPCTIND_TEMP_SER,
						M.TRAN_ACING_BRN_CODE RTMPCTIND_ACING_BRN_CODE,
						M.TRAN_INTERNAL_ACNUM RTMPCTIND_INTERNAL_ACNUM,
						M.TRAN_BRN_CODE||''/''||TO_CHAR(M.TRAN_DATE_OF_TRAN,''DD-Mon-YYYY'')||''/''||M.TRAN_BATCH_NUMBER||''/''||M.TRAN_BATCH_SL_NUM RTMPCTIND_TRN_REF_NUM,
						M.TRAN_AMOUNT RTMPCTIND_TRAN_AMT,
						M.TRAN_DB_CR_FLG RTMPCTIND_DB_CR_FLG,
						DECODE(M.TRAN_DB_CR_FLG,''D'',''WITHDRAWAL'',''DEPOSIT'') RTMPCTIND_NARR_DTL1 ,
						M.TRAN_DATE_OF_TRAN RTMPCTIND_TRAN_DATE

					FROM TRAN_REPLICA M
					WHERE  (M.TRAN_ACING_BRN_CODE, M.TRAN_INTERNAL_ACNUM, M.TRAN_DATE_OF_TRAN, M.TRAN_DB_CR_FLG) IN
					(
						SELECT A.TRAN_ACING_BRN_CODE,
						A.TRAN_INTERNAL_ACNUM, A.TRAN_DATE_OF_TRAN, A.TRAN_DB_CR_FLG
						FROM TRAN_REPLICA A, MBRN B, ACNTS AN, CLIENTS C
						WHERE A.TRAN_ACING_BRN_CODE=B.MBRN_CODE
						AND A.TRAN_INTERNAL_ACNUM = AN.ACNTS_INTERNAL_ACNUM
						AND AN.ACNTS_CLIENT_NUM = C.CLIENTS_CODE
						AND A.TRAN_INTERNAL_ACNUM !=0
						AND A.TRAN_TYPE_OF_TRAN=3
						AND A.TRAN_AUTH_BY IS NOT NULL
						AND A.TRAN_ENTD_BY != ''MIG''
						' || W_BRANCH_CON_STR || '
						AND ' || W_DATE_STR || '
						AND 1 = (CASE WHEN (C.CLIENTS_CONST_CODE=9 OR C.CLIENTS_CONST_CODE=10) AND A.TRAN_DB_CR_FLG = ''C'' THEN 2 ELSE 1 END)
						AND AN.ACNTS_AC_TYPE NOT IN (SELECT NAME FROM GOAML_SP_ACCTYPE)
						GROUP BY A.TRAN_ACING_BRN_CODE,A.TRAN_INTERNAL_ACNUM, A.TRAN_DATE_OF_TRAN, A.TRAN_DB_CR_FLG
						HAVING (SUM (A.TRAN_AMOUNT) >= 1000000)
					)  AND M.TRAN_INTERNAL_ACNUM != 0
             AND ' || W_DATE_STR_2 || '
             AND M.TRAN_TYPE_OF_TRAN=3
             AND M.TRAN_AMOUNT > 0 )';
    --dbms_output.put_line('W_SQL_STR = '||W_SQL_STR);
	EXECUTE IMMEDIATE W_SQL_STR;

    EXCEPTION

      WHEN OTHERS THEN
        IF TRIM(W_ERROR) IS NULL THEN
          W_ERROR := SUBSTR('Error in SP_GOAMLSRPT ' || SQLERRM, 1, 1000);
        END IF;
    END START_PROC;

    PKG_CHECK_DUP_CLIENT.INSERT_AMLCHKLOGSTAT(PKG_ENTITY.FN_GET_ENTITY_CODE,W_TEMP_SL, '1', W_ERROR);
    COMMIT;

    P_TEMP_SL := W_TEMP_SL;
    P_ERROR   := W_ERROR;
  END SP_GOAMLSRPT;

END PKG_CASHTRANRPT;
/

