CREATE OR REPLACE PACKAGE PKG_RDINSREC IS

   

   PROCEDURE start_dep_accr_brnwise(V_ENTITY_NUM IN NUMBER,P_brn_code IN NUMBER DEFAULT 0);

   PROCEDURE start_rdinsrec(V_ENTITY_NUM IN NUMBER,p_brn_code number default 0,p_dep_ac_num NUMBER DEFAULT 0, p_rec_date DATE DEFAULT NULL);



 END PKG_RDINSREC;

/


GRANT EXECUTE ON PKG_RDINSREC TO RL_SBLCRS;

CREATE OR REPLACE PACKAGE BODY PKG_RDINSREC IS


   TYPE DEPCONT IS RECORD(
     PBDCONT_BRN_CODE      NUMBER(6),
     PBDCONT_DEP_AC_NUM    NUMBER(14),
     PBDCONT_AC_DEP_AMT    NUMBER(18, 3),
     PBDCONT_INST_REC_FROM NUMBER(14),
     PBDCONT_EFF_DATE      DATE,
     PBDCONT_FREQ_OF_DEP   CHAR,
     PBDCONT_DEP_CURR      VARCHAR2(3),
     ACNTS_AC_NAME1        VARCHAR2(50),
     PBDCONT_INST_REC_DAY  NUMBER(2),
     PBDCONT_NO_OF_INST    NUMBER(5));
     --Sriram B - chn - 05-10-2009 - changed to skip for noof inst completed

   TYPE TY_TAB_DEPCONT IS TABLE OF DEPCONT INDEX BY PLS_INTEGER;
   --CHANGES BEG
   TYPE TY_START_DATE_REC IS RECORD(
     START_DATE DATE);
   TYPE START_DATE_REC IS TABLE OF TY_START_DATE_REC INDEX BY PLS_INTEGER;

   TYPE RDINS_TABLE IS TABLE OF RDINS%ROWTYPE INDEX BY PLS_INTEGER;



   W_RDINS_REC RDINS_TABLE;

   PKG_ERR_MSG VARCHAR2(2300);
   IDX         NUMBER := 0;
   E_USEREXCEP EXCEPTION;

   FUNCTION AUTOPOSTINT(P_BRANCH IN NUMBER) RETURN BOOLEAN;
   FUNCTION UPDATE_RDINS RETURN BOOLEAN;
   PROCEDURE UPDATE_PARA(P_BRANCH IN NUMBER);


   --Sriram B - chn - 07-03-2009 - beg
   PROCEDURE start_dep_accr_brnwise(V_ENTITY_NUM IN NUMBER,P_brn_code IN NUMBER DEFAULT 0) IS
    L_BRN_CODE NUMBER(6);
   BEGIN
 --ENTITY CODE COMMONLY ADDED - 21-11-2009  - BEG
       PKG_ENTITY.SP_SET_ENTITY_CODE(V_ENTITY_NUM);
 --ENTITY CODE COMMONLY ADDED - 21-11-2009  - END
     PKG_PROCESS_CHECK.INIT_PROC_BRN_WISE(PKG_ENTITY.FN_GET_ENTITY_CODE,P_BRN_CODE);
     FOR IDX IN 1 .. PKG_PROCESS_CHECK.V_ACNTBRN.COUNT LOOP
       L_BRN_CODE := PKG_PROCESS_CHECK.V_ACNTBRN(IDX).LN_BRN_CODE;
       IF PKG_PROCESS_CHECK.CHK_BRN_ALREADY_PROCESSED(PKG_ENTITY.FN_GET_ENTITY_CODE,L_BRN_CODE) = FALSE THEN
          START_RDINSREC(PKG_ENTITY.FN_GET_ENTITY_CODE,L_BRN_CODE);
          IF TRIM(PKG_EODSOD_FLAGS.PV_ERROR_MSG) IS NULL THEN
             PKG_PROCESS_CHECK.INSERT_ROW_INTO_EODSODPROCBRN(PKG_ENTITY.FN_GET_ENTITY_CODE,l_BRN_CODE);
          END IF;
          PKG_PROCESS_CHECK.CHECK_COMMIT_ROLLBACK_STATUS(PKG_ENTITY.FN_GET_ENTITY_CODE);
       END IF;
     END LOOP;
   END start_dep_accr_brnwise;
   --Sriram B - chn - 07-03-2009 - end

   PROCEDURE START_RDINSREC(V_ENTITY_NUM IN NUMBER,P_BRN_CODE   NUMBER DEFAULT 0,
                            P_DEP_AC_NUM NUMBER DEFAULT 0,
                            P_REC_DATE   DATE DEFAULT NULL) IS
 --Sriram B - chn - 07-04-2009 - added p_brn_code

     W_PREV_BRANCH  NUMBER(6) := 0;
     W_INS_AMT_PAID NUMBER(18, 3) := 0;
     W_REC_DATE     DATE := NULL;
     W_QRY_STRING   VARCHAR2(2300) := NULL;

     W_NOOF_INS      NUMBER;
     W_PART_AMT_PAID NUMBER(18, 3) := 0;
     W_AVL_BAL       NUMBER(18, 3) := 0;
     W_CLS_DATE      DATE; --Sriram B - chn - 18-03-09
     W_INSTAMT       NUMBER(18, 3) := 0;
     W_REC_AMT       NUMBER(18, 3) := 0;
     W_TOT_REC_AMT   NUMBER(18, 3) := 0;
     W_INS_IND       NUMBER := 1;
     W_REC_INS       NUMBER := 0;
     W_START_DATE    DATE;
     W_SEED_DATE     DATE;
     W_FREQ_MON      NUMBER := 0;
     W_DAY_SL        NUMBER(4) := 0;

     --INXES
     IDX_DATE  NUMBER := 0;
     IDX_RDINS NUMBER := 0;
     --sp_avalbal parameters

     AC_CURR_CODE         CHAR(3);
     TEMP_SP_AVL_N        NUMBER;
     TEMP_SP_AVL_D        DATE;
     AC_ACNT_FREEZED      VARCHAR2(5);
     AC_ACNT_DORMANT_ACNT CHAR;
     AC_ACNT_INOP_ACNT    CHAR;
     AC_ACNT_DB_FREEZED   CHAR;
     AC_ACNT_CR_FREEZED   CHAR;
     P_ERR_MSG            VARCHAR2(2000);
     V_ONE_INST           NUMBER := 0;
     V_TOT_CHECK_AMT      NUMBER(18,3) DEFAULT 0; -- Sriram B - chn - 17-04-2009

     L_TABDEPCONT     TY_TAB_DEPCONT;
     W_START_DATE_REC START_DATE_REC;
    --gkash chn 11-mar-2011 beg
     W_EXT_DAY        NUMBER(2);
    --gkash chn 11-mar-2011 end

   BEGIN
 --ENTITY CODE COMMONLY ADDED - 21-11-2009  - BEG
       PKG_ENTITY.SP_SET_ENTITY_CODE(V_ENTITY_NUM);
 --ENTITY CODE COMMONLY ADDED - 21-11-2009  - END

     IF P_REC_DATE IS NULL
     THEN
       W_REC_DATE := PKG_PB_GLOBAL.FN_GET_CURR_BUS_DATE(PKG_ENTITY.FN_GET_ENTITY_CODE);
     ELSE
       W_REC_DATE := P_REC_DATE;
     END IF;
     --gkash chn 10-mar-2011 beg
     W_EXT_DAY := EXTRACT(DAY FROM W_REC_DATE);
     --gkash chn 10-mar-2011 end

     W_QRY_STRING := 'SELECT PBDCONTRACT.PBDCONT_BRN_CODE,
        PBDCONTRACT.PBDCONT_DEP_AC_NUM,
        PBDCONTRACT.PBDCONT_AC_DEP_AMT,
        PBDCONTRACT.PBDCONT_INST_REC_FROM_AC,
        PBDCONTRACT.PBDCONT_EFF_DATE,
        PBDCONTRACT.PBDCONT_FREQ_OF_DEP,
        PBDCONTRACT.PBDCONT_DEP_CURR,
        ACNTS.ACNTS_AC_NAME1,
        PBDCONTRACT.PBDCONT_INST_REC_DAY,
        PBDCONT_NO_OF_INST
         FROM PBDCONTRACT, ACNTS, DEPPROD WHERE ACNTS_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND PBDCONT_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND  PBDCONT_DEP_AC_NUM = ACNTS_INTERNAL_ACNUM AND
        ACNTS_PROD_CODE = DEPPR_PROD_CODE AND DEPPR_TYPE_OF_DEP =''3''  AND PBDCONT_AUTH_ON IS NOT NULL AND
        PBDCONT_CLOSURE_DATE IS NULL AND PBDCONT_TRF_TO_OD_ON IS NULL AND PBDCONT_AUTO_INST_REC_REQD = ''1'' ';
   /* gkash chn 10-mar-2011 beg
   --Sriram B - chn - 05-10-2009 - changed to skip for noof inst completed
     W_QRY_STRING := W_QRY_STRING || ' and PBDCONT_INST_REC_DAY <=' ||
                     EXTRACT(DAY FROM W_REC_DATE);
     --Sriram B - chn - 07-04-2009 - beg

   gkash chn 10-mar-2011 end */
   -- gkash chn copied from change done for csb 10-mar-2011 beg
    W_QRY_STRING := W_QRY_STRING ||
                    ' and PBDCONT_INST_REC_DAY <= (SELECT CASE WHEN EXTRACT(DAY FROM(LAST_DAY(' ||
                    CHR(39) || W_REC_DATE || CHR(39) || '))) = ' ||
                    W_EXT_DAY || ' AND EXTRACT(DAY FROM(LAST_DAY(' ||
                    CHR(39) || W_REC_DATE || CHR(39) ||
                    '))) <
                        PBDCONTRACT.PBDCONT_INST_REC_DAY THEN
                    PBDCONTRACT.PBDCONT_INST_REC_DAY
                   ELSE
                    ' || W_EXT_DAY || '
                 END
            FROM DUAL) ';
    --gkash chn copied from change done for csb 10-mar-2011 end

     IF P_BRN_CODE > 0 THEN
         W_QRY_STRING := W_QRY_STRING || ' and PBDCONT_BRN_CODE=' ||
                       P_BRN_CODE;
     END IF;
     --Sriram B - chn - 07-04-2009 - end

     IF P_DEP_AC_NUM <> 0
     THEN
       W_QRY_STRING := W_QRY_STRING || ' and PBDCONT_DEP_AC_NUM=' ||
                       P_DEP_AC_NUM;
     END IF;
     --SRINIVAS M-13-11-07-ADD
     W_QRY_STRING := W_QRY_STRING ||
                     ' ORDER BY  PBDCONTRACT.PBDCONT_BRN_CODE, PBDCONTRACT.PBDCONT_DEP_AC_NUM ';

     EXECUTE IMMEDIATE W_QRY_STRING BULK COLLECT
       INTO L_TABDEPCONT;

     FOR I IN 1 .. L_TABDEPCONT.COUNT
     LOOP

       --V_ONE_INST := 0; --Sriram B - chn - 17-mar-2009  -- Commented on 23-mar-2009

       <<SUM_RDINS_TWDS_INSTLMNT>>
       BEGIN
         SELECT SUM(RDINS_TWDS_INSTLMNT)
           INTO W_INSTAMT
           FROM RDINS
           WHERE RDINS_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND  RDINS.RDINS_RD_AC_NUM = L_TABDEPCONT(I)
         .PBDCONT_DEP_AC_NUM
            AND RDINS.RDINS_ENTRY_DATE <= W_REC_DATE;
         --SRIRAM
         IF NVL(W_INSTAMT, 0) = 0
         THEN
           W_INSTAMT := 0;
         END IF;
       EXCEPTION
         WHEN OTHERS THEN
           PKG_ERR_MSG := 'error in getting SUM(RDINS_TWDS_INSTLMNT) IN RDINS';
           RAISE E_USEREXCEP;
       END SUM_RDINS_TWDS_INSTLMNT;
       W_INS_AMT_PAID := W_INSTAMT;
       W_NOOF_INS     := W_INS_AMT_PAID / L_TABDEPCONT(I).PBDCONT_AC_DEP_AMT;

       W_PART_AMT_PAID := W_INS_AMT_PAID -
                          (W_NOOF_INS * L_TABDEPCONT(I).PBDCONT_AC_DEP_AMT);

       --Sriram B - chn - 05-10-2009 - changed to skip for noof inst completed
       IF W_NOOF_INS >=L_TABDEPCONT(I).PBDCONT_NO_OF_INST THEN
            GOTO NEXT_PBDCONTRACT;
       END IF;

       <<GETTING_SP_AVLBAL>>
       BEGIN
         SP_AVLBAL(PKG_ENTITY.FN_GET_ENTITY_CODE,L_TABDEPCONT(I).PBDCONT_INST_REC_FROM,
                   AC_CURR_CODE,
                   TEMP_SP_AVL_N,
                   TEMP_SP_AVL_N,
                   TEMP_SP_AVL_N,
                   TEMP_SP_AVL_N,
                   TEMP_SP_AVL_N,
                   TEMP_SP_AVL_N,
                   TEMP_SP_AVL_N,
                   TEMP_SP_AVL_N,
                   TEMP_SP_AVL_N,
                   W_AVL_BAL,
                   TEMP_SP_AVL_N,
                   TEMP_SP_AVL_N,
                   TEMP_SP_AVL_N,
                   TEMP_SP_AVL_N,
                   TEMP_SP_AVL_N,
                   TEMP_SP_AVL_N,
                   TEMP_SP_AVL_N,
                   TEMP_SP_AVL_N,
                   TEMP_SP_AVL_N,
                   TEMP_SP_AVL_N,
                   TEMP_SP_AVL_N,
                   W_CLS_DATE,
                   AC_ACNT_FREEZED,
                   TEMP_SP_AVL_D,
                   AC_ACNT_DORMANT_ACNT,
                   AC_ACNT_INOP_ACNT,
                   AC_ACNT_DB_FREEZED,
                   AC_ACNT_CR_FREEZED,
                   TEMP_SP_AVL_N,
                   TEMP_SP_AVL_N,
                   P_ERR_MSG,
                   '0',
                   TEMP_SP_AVL_N,
                   TEMP_SP_AVL_N,
                   TEMP_SP_AVL_N,
                   TEMP_SP_AVL_N,
                   TEMP_SP_AVL_N,
                   TEMP_SP_AVL_N,
                   TEMP_SP_AVL_N,
                   TEMP_SP_AVL_N,
                   '1');
         --Sriram B - chn - 18-03-2009 - added w_cls_date

         --Sriram B - chn - 15-09-2009 - beg
         IF PKG_AUTOPOST.PV_TRAN_REC.COUNT > 0 THEN
           FOR IDDX IN 1 .. PKG_AUTOPOST.PV_TRAN_REC.COUNT LOOP
               IF PKG_AUTOPOST.PV_TRAN_REC(IDDX).TRAN_INTERNAL_aCNUM = L_TABDEPCONT(I).PBDCONT_INST_REC_FROM THEN
                  IF PKG_AUTOPOST.PV_TRAN_REC(IDDX).TRAN_DB_CR_FLG = 'D' THEN
                    W_AVL_BAL := W_AVL_BAL - PKG_AUTOPOST.PV_TRAN_REC(IDDX).TRAN_aMOUNT;
                    IF W_AVL_BAL < 0 THEN
                      W_AVL_BAL := 0;
                    END IF;
                  END IF;
               END IF;
           END LOOP;
         END IF;
         --Sriram B - chn - 15-09-2009 - end






         --SRIRAM
         /*           IF P_ERR_MSG IS NOT NULL  THEN
                  --SRIRAM
                     W_AVL_BAL:=0;
                    --pkg_err_msg :=   P_ERR_MSG;
                    --RAISE E_USEREXCEP;
                  END IF;
         */
       EXCEPTION
         WHEN OTHERS THEN

           PKG_ERR_MSG := 'error in calling SP_AVLBAL function';
           RAISE E_USEREXCEP;

       END GETTING_SP_AVLBAL;

       --Sriram B - chn - added W_CLS_DATE checking and error message
       IF AC_ACNT_FREEZED = '1' OR AC_ACNT_DORMANT_ACNT = '1' OR
          AC_ACNT_INOP_ACNT = '1' OR AC_ACNT_DB_FREEZED = '1' OR
          W_CLS_DATE IS NOT NULL
       THEN

         PKG_ERR_MSG                   := 'Account Freezed/Dormant/Inoperative/Closed ' ||
                                          FACNO(PKG_ENTITY.FN_GET_ENTITY_CODE,L_TABDEPCONT(I)
                                                .PBDCONT_INST_REC_FROM);
 --PKG_EODSOD_FLAGS.PV_ERROR_MSG := PKG_ERR_MSG; --Sriram B - 20-03-2009

         PKG_PB_GLOBAL.DETAIL_ERRLOG(PKG_ENTITY.FN_GET_ENTITY_CODE,'X', PKG_ERR_MSG);

         GOTO NEXT_PBDCONTRACT;
       END IF;

       W_INS_IND    := 1;
       W_REC_INS    := 0;
       W_START_DATE := L_TABDEPCONT(I).PBDCONT_EFF_DATE;
       W_SEED_DATE  := L_TABDEPCONT(I).PBDCONT_EFF_DATE;
       --CHANGES BEG
       IDX_DATE := 0;
       W_START_DATE_REC.DELETE;
       --end
       LOOP

         W_INS_IND := W_INS_IND + 1;
         IF L_TABDEPCONT(I).PBDCONT_FREQ_OF_DEP = 'M'
         THEN
           W_FREQ_MON := 1;
         ELSIF L_TABDEPCONT(I).PBDCONT_FREQ_OF_DEP = 'Q'
         THEN
           W_FREQ_MON := 3;
         ELSIF L_TABDEPCONT(I).PBDCONT_FREQ_OF_DEP = 'H'
         THEN
           W_FREQ_MON := 6;
         ELSIF L_TABDEPCONT(I).PBDCONT_FREQ_OF_DEP = 'Y'
         THEN
           W_FREQ_MON := 12;
         END IF;

         W_START_DATE := ADD_MONTHS(W_SEED_DATE,
                                    (W_INS_IND - 1) * W_FREQ_MON);
         IF W_START_DATE > PKG_EODSOD_FLAGS.PV_CURRENT_DATE
         THEN
           IF W_REC_INS = 0
           THEN
             GOTO NEXT_PBDCONTRACT;
           END IF;
         END IF;

         IF W_INS_IND <= W_NOOF_INS
         THEN
           GOTO NEXT_LOOP;
         END IF;

         IF W_START_DATE <= PKG_PB_GLOBAL.FN_GET_CURR_BUS_DATE(PKG_ENTITY.FN_GET_ENTITY_CODE)
         THEN
           W_REC_INS := W_REC_INS + 1;

         ELSE
           EXIT;
         END IF;
         --CHANGES BEG
         IDX_DATE := IDX_DATE + 1;
         W_START_DATE_REC(IDX_DATE).START_DATE := W_START_DATE;
         --end
         <<NEXT_LOOP>>
         NULL;
       END LOOP;

       --changes beg

       IF W_PREV_BRANCH = 0
       THEN
         W_PREV_BRANCH := L_TABDEPCONT(I).PBDCONT_BRN_CODE;
         W_RDINS_REC.DELETE;
         IDX_RDINS     := 0;
         IDX           := 0;
         --W_TOT_REC_AMT := 0; --Sriram B - chn - 17-MAR-2009 - added  -- Commented on 23-mar-2009
         V_ONE_INST:=0; --Sriram B - chn - 23-MAR-2009 - added
       ELSIF W_PREV_BRANCH <> L_TABDEPCONT(I).PBDCONT_BRN_CODE
       THEN
         --IF W_TOT_REC_AMT > 0  --Sriram B - chn - 17-MAR-2009 - added -- Commented on 23-mar-2009
         IF V_ONE_INST=1 --Sriram B - chn - 23-MAR-2009 - added
         THEN
           --Sriram B - chn - 04-aug-2008 - added
           UPDATE_PARA(W_PREV_BRANCH);
         END IF;
         W_PREV_BRANCH := L_TABDEPCONT(I).PBDCONT_BRN_CODE;
         --gkash chn 28-11-2007 beg
         W_RDINS_REC.DELETE;
         IDX_RDINS := 0;
         --gkash chn 28-11-2007 beg
         IDX           := 0;
         --W_TOT_REC_AMT := 0; --Sriram B - chn - 17-MAR-2009 - added   -- Commented on 23-mar-2009
         V_ONE_INST:=0; --Sriram B - chn - 23-MAR-2009 - added
       END IF;
       --end
       w_tot_rec_amt := 0;  --Sriram B - chn - 17-MAR-2009 - added -- Uncommented on 23-mar-2009
       <<RDINS_DAYSERIAL_GEN>>
       BEGIN
         W_DAY_SL := 0;
         SELECT MAX(RDINS_ENTRY_DAY_SL) + 1
           INTO W_DAY_SL
           FROM RDINS
           WHERE RDINS_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND  RDINS.RDINS_RD_AC_NUM = L_TABDEPCONT(I)
         .PBDCONT_DEP_AC_NUM
            AND RDINS.RDINS_ENTRY_DATE = PKG_PB_GLOBAL.FN_GET_CURR_BUS_DATE(PKG_ENTITY.FN_GET_ENTITY_CODE);

         IF NVL(W_DAY_SL, 0) = 0
         THEN
           W_DAY_SL := 1;
         END IF;

       EXCEPTION
         WHEN NO_DATA_FOUND THEN
           W_DAY_SL := 1;
         WHEN OTHERS THEN
           W_DAY_SL := 1;
       END RDINS_DAYSERIAL_GEN;

       FOR W_IND IN 1 .. W_REC_INS
       LOOP

         IF W_PART_AMT_PAID > 0
         THEN
           W_REC_AMT       := L_TABDEPCONT(I)
                             .PBDCONT_AC_DEP_AMT - W_PART_AMT_PAID;
           W_PART_AMT_PAID := 0;
         ELSE
           W_REC_AMT := L_TABDEPCONT(I).PBDCONT_AC_DEP_AMT;
         END IF;

         V_TOT_CHECK_AMT:=0;
         V_TOT_CHECK_AMT:=W_REC_AMT*W_REC_INS;

         IF V_TOT_CHECK_AMT <= W_AVL_BAL THEN  --Sriram B - chn - 17-04-2009

         IF W_REC_AMT <= W_AVL_BAL
         THEN
           <<COLLECTION_ADDING_RDINS>>
           BEGIN
             IDX_RDINS := IDX_RDINS + 1;
             W_RDINS_REC(IDX_RDINS).RDINS_RD_AC_NUM := L_TABDEPCONT(I)
                                                      .PBDCONT_DEP_AC_NUM;
             W_RDINS_REC(IDX_RDINS).RDINS_ENTRY_DATE := PKG_PB_GLOBAL.FN_GET_CURR_BUS_DATE(PKG_ENTITY.FN_GET_ENTITY_CODE);
             W_RDINS_REC(IDX_RDINS).RDINS_ENTRY_DAY_SL := W_DAY_SL;
             W_RDINS_REC(IDX_RDINS).RDINS_EFF_DATE := W_START_DATE_REC(W_IND)
                                                     .START_DATE;
             W_RDINS_REC(IDX_RDINS).RDINS_AMT_OF_PYMT := W_REC_AMT;
             W_RDINS_REC(IDX_RDINS).RDINS_TWDS_INSTLMNT := W_REC_AMT;
             W_RDINS_REC(IDX_RDINS).RDINS_TWDS_PENAL_CHGS := 0;
             W_RDINS_REC(IDX_RDINS).RDINS_TWDS_INT := 0;
             W_RDINS_REC(IDX_RDINS).RDINS_REM1 := 'Auto Recovery for ';
             --SITHIK-CHG-25-09-2008-BEG
             --w_rdins_rec(IDX_RDINS).RDINS_REM2 := l_tabdepCont(i).acnts_ac_name1;
             W_RDINS_REC(IDX_RDINS).RDINS_REM2 := SUBSTR(L_TABDEPCONT(I)
                                                         .ACNTS_AC_NAME1,
                                                         1,
                                                         35);
             --SITHIK-CHG-25-09-2008-END
             W_RDINS_REC(IDX_RDINS).RDINS_REM3 := 'DUE DATE : ' ||
                                                  W_START_DATE_REC(W_IND)
                                                 .START_DATE;
             W_RDINS_REC(IDX_RDINS).RDINS_TRANSTL_INV_NUM := 0;

             W_RDINS_REC(IDX_RDINS).RDINS_ENTD_BY := PKG_EODSOD_FLAGS.PV_USER_ID;
             W_RDINS_REC(IDX_RDINS).RDINS_ENTD_ON := PKG_EODSOD_FLAGS.PV_CURRENT_DATE;
             W_RDINS_REC(IDX_RDINS).RDINS_AUTH_BY := PKG_EODSOD_FLAGS.PV_USER_ID;
             W_RDINS_REC(IDX_RDINS).RDINS_AUTH_ON := PKG_EODSOD_FLAGS.PV_CURRENT_DATE;
             W_RDINS_REC(IDX_RDINS).RDINS_REJ_BY := NULL;
             W_RDINS_REC(IDX_RDINS).RDINS_REJ_ON := NULL;
             W_RDINS_REC(IDX_RDINS).RDINS_LAST_MOD_BY := NULL;
             W_RDINS_REC(IDX_RDINS).RDINS_LAST_MOD_ON := NULL;
             W_RDINS_REC(IDX_RDINS).RDINS_TWDS_CHG := 0;
             W_RDINS_REC(IDX_RDINS).RDINS_TWDS_VAT := 0;

             W_TOT_REC_AMT := W_TOT_REC_AMT + W_REC_AMT;

             DBMS_OUTPUT.PUT_LINE('TOTAMT' || '-' || L_TABDEPCONT(I).PBDCONT_DEP_AC_NUM || '-' ||
                                              '-' || L_TABDEPCONT(I).PBDCONT_INST_REC_FROM || '-' ||
                                              W_TOT_REC_AMT);

             W_DAY_SL      := W_DAY_SL + 1;



           EXCEPTION
             WHEN OTHERS THEN
               PKG_ERR_MSG := 'Error in COLLECTION_ADDING_RDINS  ';
               RAISE E_USEREXCEP;
           END COLLECTION_ADDING_RDINS;
           --Sriram B - 18-03-2009 - beg
         ELSE
           PKG_ERR_MSG                   := 'Available Balance Should be Greater than Recovery Amount - ' ||
                                            FACNO(PKG_ENTITY.FN_GET_ENTITY_CODE,L_TABDEPCONT(I)
                                                  .PBDCONT_INST_REC_FROM);
 --PKG_EODSOD_FLAGS.PV_ERROR_MSG := PKG_ERR_MSG; --Sriram B - 20-03-2009
           PKG_PB_GLOBAL.DETAIL_ERRLOG(PKG_ENTITY.FN_GET_ENTITY_CODE,'X', PKG_ERR_MSG);
           GOTO NEXT_PBDCONTRACT;
           --Sriram B - 18-03-2009 - end
         END IF;
       END IF;  --Sriram B - chn - 17-04-2009

       END LOOP;

       --Sriram B - chn - 17-MAR-2009
       IF w_tot_rec_amt > 0 and (W_AVL_BAL >= w_tot_rec_amt) --Sriram B - chn - 07-04-2009 -  added -(W_AVL_BAL >= w_tot_rec_amt)
       --IF W_TOT_REC_AMT > 0 AND V_ONE_INST = 1  --Sriram B - chn - 23-MAR-2009
       THEN
         <<SET_TRAN_VALUES>>
         BEGIN
           IF I = 1
           THEN
             PKG_APOST_INTERFACE.SP_POSTING_BEGIN(PKG_ENTITY.FN_GET_ENTITY_CODE);
           END IF;

           IDX := IDX + 1;
           PKG_AUTOPOST.PV_TRAN_REC(IDX).TRAN_INTERNAL_ACNUM := L_TABDEPCONT(I)
                                                               .PBDCONT_DEP_AC_NUM;
           PKG_AUTOPOST.PV_TRAN_REC(IDX).TRAN_DB_CR_FLG := 'C';
           PKG_AUTOPOST.PV_TRAN_REC(IDX).TRAN_AMOUNT := W_TOT_REC_AMT;
           PKG_AUTOPOST.PV_TRAN_REC(IDX).TRAN_VALUE_DATE := PKG_PB_GLOBAL.FN_GET_CURR_BUS_DATE(PKG_ENTITY.FN_GET_ENTITY_CODE);
           --PKG_AUTOPOST.PV_TRAN_REC(IDX).TRAN_NARR_DTL1        := 'RD Installment Recovery    ' || l_tabdepCont(i).pbdcont_dep_ac_num || ' for '; --SRIRAM
           PKG_AUTOPOST.PV_TRAN_REC(IDX).TRAN_NARR_DTL1 := 'RD Installment Recovery  '; --SRIRAM
           PKG_AUTOPOST.PV_TRAN_REC(IDX).TRAN_NARR_DTL2 := ' Recovery Date : ' ||
                                                           PKG_PB_GLOBAL.FN_GET_CURR_BUS_DATE(PKG_ENTITY.FN_GET_ENTITY_CODE);

           IDX := IDX + 1;
           PKG_AUTOPOST.PV_TRAN_REC(IDX).TRAN_INTERNAL_ACNUM := L_TABDEPCONT(I)
                                                               .PBDCONT_INST_REC_FROM;
           PKG_AUTOPOST.PV_TRAN_REC(IDX).TRAN_DB_CR_FLG := 'D';
           PKG_AUTOPOST.PV_TRAN_REC(IDX).TRAN_VALUE_DATE := PKG_PB_GLOBAL.FN_GET_CURR_BUS_DATE(PKG_ENTITY.FN_GET_ENTITY_CODE);
           PKG_AUTOPOST.PV_TRAN_REC(IDX).TRAN_AMOUNT := W_TOT_REC_AMT;
           -- PKG_AUTOPOST.PV_TRAN_REC(IDX).TRAN_NARR_DTL1        := ' Amount Recovered From ' || facno(l_tabdepCont(i).pbdcont_inst_rec_from);
           PKG_AUTOPOST.PV_TRAN_REC(IDX).TRAN_NARR_DTL1 := ' Twds. RD Installment Recovery For ';
           PKG_AUTOPOST.PV_TRAN_REC(IDX).TRAN_NARR_DTL2 := FACNO(PKG_ENTITY.FN_GET_ENTITY_CODE,L_TABDEPCONT(I)
                                                                 .PBDCONT_DEP_AC_NUM);
           PKG_AUTOPOST.PV_TRAN_REC(IDX).TRAN_NARR_DTL3 := ' Recovery Date : ' ||
                                                           PKG_PB_GLOBAL.FN_GET_CURR_BUS_DATE(PKG_ENTITY.FN_GET_ENTITY_CODE);

           DBMS_OUTPUT.PUT_LINE('POSTING' || '-' || L_TABDEPCONT(I).PBDCONT_DEP_AC_NUM || '-' ||
                                 '-' || L_TABDEPCONT(I).PBDCONT_INST_REC_FROM || '-' ||
                                 W_TOT_REC_AMT);

           V_ONE_INST    := 1;

         EXCEPTION
           WHEN OTHERS THEN
             PKG_ERR_MSG := 'Error when moving values to Auto Post: ' ||
                            SUBSTR(SQLERRM, 1, 500);
             DBMS_OUTPUT.PUT_LINE(PKG_ERR_MSG);

         END SET_TRAN_VALUES;
       ELSE
          PKG_ERR_MSG                   := 'Available Balance Should be Greater than Recovery Amount - ' ||
                                            FACNO(PKG_ENTITY.FN_GET_ENTITY_CODE,L_TABDEPCONT(I).PBDCONT_INST_REC_FROM);
          PKG_PB_GLOBAL.DETAIL_ERRLOG(PKG_ENTITY.FN_GET_ENTITY_CODE,'X', PKG_ERR_MSG);
       END IF;

       W_INS_AMT_PAID := 0;

       <<NEXT_PBDCONTRACT>>
       NULL;

     END LOOP;

     -- CHANGES -BEG
     --SRIRAM
     --IF W_TOT_REC_AMT <> 0 AND W_PREV_BRANCH <> 0 -- Commented on 23-mar-2009
     IF V_ONE_INST=1 -- Sriram B - added on 23-mar-2009
     THEN
       UPDATE_PARA(W_PREV_BRANCH);
       --IDX_RDINS := 1;
     END IF;
     -- END

   EXCEPTION
     WHEN OTHERS THEN
       IF TRIM(PKG_ERR_MSG) IS NULL
       THEN
         PKG_ERR_MSG := 'Error in start_rdinsrec (PKG_ENTITY.FN_GET_ENTITY_CODE,RD Installmet Recovery) ';
       END IF;
       PKG_EODSOD_FLAGS.PV_ERROR_MSG := PKG_ERR_MSG;
       PKG_PB_GLOBAL.DETAIL_ERRLOG(PKG_ENTITY.FN_GET_ENTITY_CODE,'E',
                                   PKG_EODSOD_FLAGS.PV_ERROR_MSG,
                                   ' ',
                                   0);
       PKG_PB_GLOBAL.DETAIL_ERRLOG(PKG_ENTITY.FN_GET_ENTITY_CODE,'E', SUBSTR(SQLERRM, 1, 1000), ' ', 0);
   END START_RDINSREC;

   FUNCTION AUTOPOSTINT(P_BRANCH IN NUMBER) RETURN BOOLEAN IS
     W_ERR_CODE  NUMBER;
     W_BATCH_NUM NUMBER(7);

     PROCEDURE SET_TRAN_KEY_VALUES IS
     BEGIN
       PKG_AUTOPOST.PV_TRAN_KEY.TRAN_BRN_CODE     := P_BRANCH;
       PKG_AUTOPOST.PV_TRAN_KEY.TRAN_DATE_OF_TRAN := PKG_PB_GLOBAL.FN_GET_CURR_BUS_DATE(PKG_ENTITY.FN_GET_ENTITY_CODE);
       PKG_AUTOPOST.PV_TRAN_KEY.TRAN_BATCH_NUMBER := 0;
       PKG_AUTOPOST.PV_TRAN_KEY.TRAN_BATCH_SL_NUM := 0;

     END SET_TRAN_KEY_VALUES;

     PROCEDURE SET_TRANBAT_VALUES IS
     BEGIN
       PKG_AUTOPOST.PV_TRANBAT.TRANBAT_SOURCE_TABLE := 'RDINS';
       PKG_AUTOPOST.PV_TRANBAT.TRANBAT_SOURCE_KEY   := P_BRANCH ||
                                                       PKG_PB_GLOBAL.FN_GET_CURR_BUS_DATE(PKG_ENTITY.FN_GET_ENTITY_CODE);
       PKG_AUTOPOST.PV_TRANBAT.TRANBAT_NARR_DTL1    := 'RD Auto Installment Recovery    ';
       PKG_AUTOPOST.PV_TRANBAT.TRANBAT_NARR_DTL2    := 'Recorver Date:' ||
                                                       PKG_PB_GLOBAL.FN_GET_CURR_BUS_DATE(PKG_ENTITY.FN_GET_ENTITY_CODE);
     END SET_TRANBAT_VALUES;

   BEGIN

     SET_TRAN_KEY_VALUES;
     SET_TRANBAT_VALUES;

     PKG_APOST_INTERFACE.SP_POST_SODEOD_BATCH(PKG_ENTITY.FN_GET_ENTITY_CODE,'A',
                                              IDX,
                                              0,
                                              W_ERR_CODE,
                                              PKG_ERR_MSG,
                                              W_BATCH_NUM);
     IF (W_ERR_CODE <> '0000')
     THEN
       PKG_ERR_MSG := FN_GET_AUTOPOST_ERR_MSG(PKG_ENTITY.FN_GET_ENTITY_CODE);
       RAISE E_USEREXCEP;
     END IF;

     PKG_APOST_INTERFACE.SP_POSTING_END(PKG_ENTITY.FN_GET_ENTITY_CODE);

     FOR RDINS_IDX IN 1 .. W_RDINS_REC.COUNT
     LOOP
       W_RDINS_REC(RDINS_IDX).POST_TRAN_BRN := P_BRANCH;
       W_RDINS_REC(RDINS_IDX).POST_TRAN_DATE := PKG_PB_GLOBAL.FN_GET_CURR_BUS_DATE(PKG_ENTITY.FN_GET_ENTITY_CODE);
       W_RDINS_REC(RDINS_IDX).POST_TRAN_BATCH_NUM := W_BATCH_NUM;

     END LOOP;

     IDX := 0;
     RETURN TRUE;
   EXCEPTION
     WHEN OTHERS THEN
       IF TRIM(PKG_ERR_MSG) IS NULL
       THEN
         PKG_ERR_MSG := 'error in AutoPostInt function for ';
         PKG_ERR_MSG := PKG_ERR_MSG || P_BRANCH;

       END IF;
       PKG_EODSOD_FLAGS.PV_ERROR_MSG := PKG_ERR_MSG;
       PKG_PB_GLOBAL.DETAIL_ERRLOG(PKG_ENTITY.FN_GET_ENTITY_CODE,'E', PKG_ERR_MSG, ' ');

       RETURN FALSE;

   END AUTOPOSTINT;
   FUNCTION UPDATE_RDINS RETURN BOOLEAN IS
   BEGIN
     FOR IDX IN 1 ..  W_RDINS_REC .Count
        LOOP
            W_RDINS_REC (IDX).RDINS_ENTITY_NUM := PKG_ENTITY.FN_GET_ENTITY_CODE;
      END LOOP;
     FORALL RDINX_IDX IN 1 .. W_RDINS_REC.COUNT
       INSERT INTO RDINS VALUES W_RDINS_REC (RDINX_IDX);

     W_RDINS_REC.DELETE;
     RETURN TRUE;
   EXCEPTION
     WHEN OTHERS THEN
       PKG_ERR_MSG := 'error in INSERTING RDINS TABLE   ' ||
                      SUBSTR(SQLERRM, 1, 500);
       RETURN FALSE;
   END UPDATE_RDINS;
   PROCEDURE UPDATE_PARA(P_BRANCH IN NUMBER) IS
   BEGIN

     --  Call AutoPostInt
     IF NOT AUTOPOSTINT(P_BRANCH)
     THEN
       RAISE E_USEREXCEP;
     END IF;
     IF NOT UPDATE_RDINS
     THEN
       RAISE E_USEREXCEP;
     END IF;
   END;



 END PKG_RDINSREC;

/


GRANT EXECUTE ON PKG_RDINSREC TO RL_SBLCRS;
