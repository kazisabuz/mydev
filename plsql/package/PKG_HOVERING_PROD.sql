DROP PACKAGE PKG_HOVERING;

CREATE OR REPLACE PACKAGE PKG_HOVERING
IS
   -- AUTHOR  : ARUN
   -- CREATED : 11/2/2007 2:27:14 PM
   -- PURPOSE : HOVERING EODSOD
   PROCEDURE SP_HOVERING (V_ENTITY_NUM       IN NUMBER,
                          P_BRAN_CODE        IN NUMBER DEFAULT 0,
                          P_ACCOUNT_NUMBER   IN NUMBER DEFAULT 0);
END PKG_HOVERING;
/
DROP PACKAGE BODY PKG_HOVERING;

CREATE OR REPLACE PACKAGE BODY PKG_HOVERING
IS
   PROCEDURE SP_HOVERING (V_ENTITY_NUM       IN NUMBER,
                          P_BRAN_CODE        IN NUMBER DEFAULT 0,
                          P_ACCOUNT_NUMBER   IN NUMBER DEFAULT 0)
   IS
      TYPE TY_HOEVER_REC IS RECORD
      (
         V_HOVERING_BRN_CODE             NUMBER,
         V_HOVERING_YEAR                 NUMBER,
         V_HOVERING_SL_NUM               NUMBER,
         V_HOVERING_RECOVERY_FROM_ACNT   NUMBER,
         V_HOVERING_RECOVERY_TO_ACNT     NUMBER,
         V_HOVERING_RECOVERY_CURR        VARCHAR2 (3),
         V_HOVERING_PENDING_AMT          NUMBER,
         V_HOVERING_RECOVERY_NARR1       VARCHAR2 (35),
         V_HOVERING_RECOVERY_NARR2       VARCHAR2 (35),
         V_HOVERING_RECOVERY_NARR3       VARCHAR2 (35),
         V_HOVERING_GLACC_CODE           VARCHAR2 (15),
         V_HOVERING_CHG_CODE             VARCHAR2 (6),
         V_HOVERTYPE_PARTIAL_REC_ALL     CHAR (1),
         V_HOVERTYPE_TRAN_CODE           VARCHAR2 (6)
      );

      TYPE TAB_HOEVER_REC IS TABLE OF TY_HOEVER_REC
         INDEX BY PLS_INTEGER;

      HOEVER_REC             TAB_HOEVER_REC;

      W_REC_AMT              NUMBER;
      W_AMT_TOBE_RECOV       NUMBER;
      W_AVL_BAL              NUMBER;
      W_SQL                  VARCHAR2 (10300);
      W_CBD                  DATE;
      HOVER_MAX_SL           NUMBER;
      IDX                    NUMBER;
      W_ERR_CODE             VARCHAR2 (10);
      W_BATCH_NUMBER         NUMBER;
      W_ERROR                VARCHAR2 (1300);
      W_ACNTS_CR_FREEZED     CHAR (1);
      W_USERID               VARCHAR2 (8);
      W_ACNTS_CLOSURE_DATE   DATE;
      USR_EXCEPTION          EXCEPTION;

      PROCEDURE CANCEL_HOVERING;

      PROCEDURE INIT_PARA
      IS
      BEGIN
         W_SQL := NULL;
         W_CBD := PKG_EODSOD_FLAGS.PV_CURRENT_DATE;
         W_USERID := PKG_EODSOD_FLAGS.PV_USER_ID;
      END INIT_PARA;

      PROCEDURE INIT_LOOP_VARIABLE
      IS
      BEGIN
         W_REC_AMT := 0;
         W_AMT_TOBE_RECOV := 0;
         W_AVL_BAL := 0;
         HOVER_MAX_SL := 0;
         IDX := 0;
         W_ACNTS_CR_FREEZED := 0;
         W_ACNTS_CLOSURE_DATE := NULL;
      END INIT_LOOP_VARIABLE;

      PROCEDURE GETMAXSL (L IN NUMBER)
      IS
      BEGIN
         SELECT NVL (MAX (HOVREC_RECOVERY_SL), 0) + 1
           INTO HOVER_MAX_SL
           FROM HOVREC
          WHERE     HOVREC_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
                AND HOVREC_BRN_CODE = HOEVER_REC (L).V_HOVERING_BRN_CODE
                AND HOVREC_YEAR = HOEVER_REC (L).V_HOVERING_YEAR
                AND HOVREC_SL_NUM = HOEVER_REC (L).V_HOVERING_SL_NUM;
      END GETMAXSL;

      PROCEDURE UPDATE_HOVERREC (L IN NUMBER)
      IS
         EODSODVAL   CHAR (1);
      BEGIN
         IF (TRIM (PKG_EODSOD_FLAGS.PV_EODSODFLAG) IS NOT NULL)
         THEN
            EODSODVAL := PKG_EODSOD_FLAGS.PV_EODSODFLAG;
         ELSE
            EODSODVAL := 'O';
         END IF;

         GETMAXSL (L);

         INSERT INTO HOVREC
              VALUES (
                        PKG_ENTITY.FN_GET_ENTITY_CODE,
                        HOEVER_REC (L).V_HOVERING_BRN_CODE,
                        HOEVER_REC (L).V_HOVERING_YEAR,
                        HOEVER_REC (L).V_HOVERING_SL_NUM,
                        HOVER_MAX_SL,
                        TO_DATE (
                              W_CBD
                           || ' '
                           || PKG_PB_GLOBAL.FN_GET_CURR_BUS_TIME (
                                 PKG_ENTITY.FN_GET_ENTITY_CODE),
                           'DD-MM-YYYY HH24:MI:SS'),
                        W_REC_AMT,
                        HOEVER_REC (L).V_HOVERING_BRN_CODE,
                        W_CBD,
                        0,
                        1,
                        EODSODVAL);
      END UPDATE_HOVERREC;

      PROCEDURE SETTRANKEYVALUE (BRN_CODE IN NUMBER, CBD IN DATE)
      IS
      BEGIN
         PKG_AUTOPOST.PV_SYSTEM_POSTED_TRANSACTION := FALSE;
         PKG_AUTOPOST.PV_CALLED_FROM_HOVERING := TRUE;
         PKG_AUTOPOST.PV_TRAN_KEY.TRAN_BRN_CODE := BRN_CODE;
         PKG_AUTOPOST.PV_TRAN_KEY.TRAN_DATE_OF_TRAN := CBD;
         PKG_AUTOPOST.PV_TRAN_KEY.TRAN_BATCH_SL_NUM := 0;
         PKG_AUTOPOST.PV_TRAN_KEY.TRAN_BATCH_NUMBER := 0;
      END SETTRANKEYVALUE;

      PROCEDURE SETTRANBATVALUE (L IN NUMBER)
      IS
      BEGIN
         PKG_AUTOPOST.PV_TRANBAT.TRANBAT_SOURCE_TABLE := 'HOVEREC';
         PKG_AUTOPOST.PV_TRANBAT.TRANBAT_SOURCE_KEY :=
               HOEVER_REC (L).V_HOVERING_BRN_CODE
            || '|'
            || HOEVER_REC (L).V_HOVERING_YEAR
            || '|'
            || HOEVER_REC (L).V_HOVERING_SL_NUM
            || '|'
            || HOVER_MAX_SL;

         IF (TRIM (HOEVER_REC (L).V_HOVERING_RECOVERY_NARR1) IS NOT NULL)
         THEN
            PKG_AUTOPOST.PV_TRANBAT.TRANBAT_NARR_DTL1 :=
               HOEVER_REC (L).V_HOVERING_RECOVERY_NARR1;
            PKG_AUTOPOST.PV_TRANBAT.TRANBAT_NARR_DTL2 :=
               HOEVER_REC (L).V_HOVERING_RECOVERY_NARR2;
            PKG_AUTOPOST.PV_TRANBAT.TRANBAT_NARR_DTL3 :=
               HOEVER_REC (L).V_HOVERING_RECOVERY_NARR3;
         ELSE
            PKG_AUTOPOST.PV_TRANBAT.TRANBAT_NARR_DTL1 := 'HOVERING RECOVERY';
         END IF;
      END SETTRANBATVALUE;

      PROCEDURE SETTRANVALUES (L IN NUMBER)
      IS
         W_COU            NUMBER DEFAULT 0;
         W_TEMP_REC_AMT   NUMBER DEFAULT 0;                                 --
         W_EXIT_LOOP      BOOLEAN DEFAULT FALSE;                           ---
      BEGIN
         W_TEMP_REC_AMT := W_REC_AMT;                                      ---
         IDX := IDX + 1;
         PKG_AUTOPOST.PV_TRAN_REC (IDX).TRAN_INTERNAL_ACNUM :=
            HOEVER_REC (L).V_HOVERING_RECOVERY_FROM_ACNT;
         PKG_AUTOPOST.PV_TRAN_REC (IDX).TRAN_DB_CR_FLG := 'D';
         PKG_AUTOPOST.PV_TRAN_REC (IDX).TRAN_AMOUNT := W_REC_AMT;
         PKG_AUTOPOST.PV_TRAN_REC (IDX).TRAN_CODE :=
            HOEVER_REC (L).V_HOVERTYPE_TRAN_CODE;

         FOR IDX2
            IN (SELECT HOVERBRK_BRK_SL,
                       HOVERBRK_INTERNAL_ACNUM,
                       HOVERBRK_GLACC_CODE,
                       HOVERBRK_CURR_CODE,
                       HOVERBRK_RECOVERY_AMT
                  FROM HOVERRECBRK
                 WHERE     HOVERBRK_ENTITY_NUM =
                              PKG_ENTITY.FN_GET_ENTITY_CODE
                       AND HOVERBRK_BRN_CODE =
                              HOEVER_REC (L).V_HOVERING_BRN_CODE
                       AND HOVERBRK_YEAR = HOEVER_REC (L).V_HOVERING_YEAR
                       AND HOVERBRK_SL_NUM = HOEVER_REC (L).V_HOVERING_SL_NUM
                       AND HOVERBRK_RECOVERY_AMT <> 0)
         LOOP
            --ARUNMUGESH.J 17-SEP-2009

            IDX := IDX + 1;
            W_COU := W_COU + 1;
            PKG_AUTOPOST.PV_TRAN_REC (IDX).TRAN_BRN_CODE :=
               HOEVER_REC (L).V_HOVERING_BRN_CODE;

            IF (TRIM (IDX2.HOVERBRK_GLACC_CODE) IS NOT NULL)
            THEN
               PKG_AUTOPOST.PV_TRAN_REC (IDX).TRAN_GLACC_CODE :=
                  IDX2.HOVERBRK_GLACC_CODE;
            END IF;

            PKG_AUTOPOST.PV_TRAN_REC (IDX).TRAN_INTERNAL_ACNUM :=
               IDX2.HOVERBRK_INTERNAL_ACNUM;
            PKG_AUTOPOST.PV_TRAN_REC (IDX).TRAN_CURR_CODE :=
               IDX2.HOVERBRK_CURR_CODE;
            PKG_AUTOPOST.PV_TRAN_REC (IDX).TRAN_DB_CR_FLG := 'C';
            PKG_AUTOPOST.PV_TRAN_REC (IDX).TRAN_CHARGE_CODE :=
               HOEVER_REC (L).V_HOVERING_CHG_CODE;

            IF (W_TEMP_REC_AMT < IDX2.HOVERBRK_RECOVERY_AMT)
            THEN
               PKG_AUTOPOST.PV_TRAN_REC (IDX).TRAN_AMOUNT := W_TEMP_REC_AMT;

               UPDATE HOVERRECBRK
                  SET HOVERBRK_RECOVERY_AMT =
                         HOVERBRK_RECOVERY_AMT - W_TEMP_REC_AMT
                WHERE     HOVERBRK_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
                      AND HOVERBRK_BRN_CODE =
                             HOEVER_REC (L).V_HOVERING_BRN_CODE
                      AND HOVERBRK_YEAR = HOEVER_REC (L).V_HOVERING_YEAR
                      AND HOVERBRK_SL_NUM = HOEVER_REC (L).V_HOVERING_SL_NUM
                      AND HOVERBRK_BRK_SL = IDX2.HOVERBRK_BRK_SL;


               GOTO EXIT_LOOP;
            ELSE
               PKG_AUTOPOST.PV_TRAN_REC (IDX).TRAN_AMOUNT :=
                  IDX2.HOVERBRK_RECOVERY_AMT;
               W_TEMP_REC_AMT := W_TEMP_REC_AMT - IDX2.HOVERBRK_RECOVERY_AMT;

               UPDATE HOVERRECBRK
                  SET HOVERBRK_RECOVERY_AMT =
                         HOVERBRK_RECOVERY_AMT - IDX2.HOVERBRK_RECOVERY_AMT
                WHERE     HOVERBRK_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
                      AND HOVERBRK_BRN_CODE =
                             HOEVER_REC (L).V_HOVERING_BRN_CODE
                      AND HOVERBRK_YEAR = HOEVER_REC (L).V_HOVERING_YEAR
                      AND HOVERBRK_SL_NUM = HOEVER_REC (L).V_HOVERING_SL_NUM
                      AND HOVERBRK_BRK_SL = IDX2.HOVERBRK_BRK_SL;
            END IF;
         END LOOP;                                  --ARUNMUGESH.J 17-SEP-2009

        <<EXIT_LOOP>>
         NULL;

         IF (W_COU = 1)
         THEN
            --ARUNMUGESH.J 18-SEP-2009
            PKG_AUTOPOST.PV_TRAN_REC (IDX).TRAN_AMOUNT := W_REC_AMT;
         END IF;                                    --ARUNMUGESH.J 18-SEP-2009

         -- IDX := PKG_AUTOPOST.PV_TRAN_REC.LAST;
         PKG_APOST_INTERFACE.SP_POST_SODEOD_BATCH (
            PKG_ENTITY.FN_GET_ENTITY_CODE,
            'A',
            IDX,
            0,
            W_ERR_CODE,
            W_ERROR,
            W_BATCH_NUMBER);

         IF (W_ERR_CODE <> '0000')
         THEN
            W_ERROR := FN_GET_AUTOPOST_ERR_MSG (PKG_ENTITY.FN_GET_ENTITY_CODE);
            RAISE USR_EXCEPTION;
         END IF;
      END SETTRANVALUES;

      PROCEDURE UPDATE_HOVREC (L IN NUMBER)
      IS
         COU   NUMBER;
      BEGIN
         SELECT COUNT (1)
           INTO COU
           FROM HOVREC
          WHERE     HOVREC_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
                AND HOVREC_BRN_CODE = HOEVER_REC (L).V_HOVERING_BRN_CODE
                AND HOVREC_YEAR = HOEVER_REC (L).V_HOVERING_YEAR
                AND HOVREC_SL_NUM = HOEVER_REC (L).V_HOVERING_SL_NUM
                AND HOVREC_RECOVERY_SL = HOVER_MAX_SL;

         IF (COU <> 1)
         THEN
            W_ERROR :=
               'NO ROW UPDATETED OR MORE THAN ONE ROW UPDATE IN HOVREC';
            RAISE USR_EXCEPTION;
         END IF;

         UPDATE HOVREC
            SET POST_TRAN_BATCH_NUM = W_BATCH_NUMBER
          WHERE     HOVREC_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
                AND HOVREC_BRN_CODE = HOEVER_REC (L).V_HOVERING_BRN_CODE
                AND HOVREC_YEAR = HOEVER_REC (L).V_HOVERING_YEAR
                AND HOVREC_SL_NUM = HOEVER_REC (L).V_HOVERING_SL_NUM
                AND HOVREC_RECOVERY_SL = HOVER_MAX_SL;
      END UPDATE_HOVREC;

      PROCEDURE UPDATE_HOVERING (L IN NUMBER)
      IS
         COU           NUMBER;
         PENDING_AMT   NUMBER (3);
      BEGIN
         SELECT COUNT (1)
           INTO COU
           FROM HOVERING
          WHERE     HOVERING_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
                AND HOVERING_BRN_CODE = HOEVER_REC (L).V_HOVERING_BRN_CODE
                AND HOVERING_YEAR = HOEVER_REC (L).V_HOVERING_YEAR
                AND HOVERING_SL_NUM = HOEVER_REC (L).V_HOVERING_SL_NUM;

         IF (COU <> 1)
         THEN
            W_ERROR :=
               'NO ROW UPDATETED OR MORE THAN ONE ROW UPDATE IN HOVERING';
            RAISE USR_EXCEPTION;
         END IF;

         /*
             UPDATE HOVERING
                SET HOVERING_PENDING_AMT = HOVERING_PENDING_AMT - W_REC_AMT,
                    HOVERING_STATUS      = 'E'
                WHERE HOVERING_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND  HOVERING_BRN_CODE = HOEVER_REC(L)
             .V_HOVERING_BRN_CODE
                AND HOVERING_YEAR = HOEVER_REC(L)
             .V_HOVERING_YEAR
                AND HOVERING_SL_NUM = HOEVER_REC(L).V_HOVERING_SL_NUM;
                */

         SELECT HOVERING_PENDING_AMT - W_REC_AMT
           INTO PENDING_AMT
           FROM HOVERING
          WHERE     HOVERING_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
                AND HOVERING_BRN_CODE = HOEVER_REC (L).V_HOVERING_BRN_CODE
                AND HOVERING_YEAR = HOEVER_REC (L).V_HOVERING_YEAR
                AND HOVERING_SL_NUM = HOEVER_REC (L).V_HOVERING_SL_NUM;

         IF PENDING_AMT <> 0
         THEN
            UPDATE HOVERING
               SET HOVERING_PENDING_AMT = HOVERING_PENDING_AMT - W_REC_AMT,
                   HOVERING_STATUS = ' '
             WHERE     HOVERING_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
                   AND HOVERING_BRN_CODE = HOEVER_REC (L).V_HOVERING_BRN_CODE
                   AND HOVERING_YEAR = HOEVER_REC (L).V_HOVERING_YEAR
                   AND HOVERING_SL_NUM = HOEVER_REC (L).V_HOVERING_SL_NUM;
         ELSE
            UPDATE HOVERING
               SET HOVERING_PENDING_AMT = HOVERING_PENDING_AMT - W_REC_AMT,
                   HOVERING_STATUS = 'E'
             WHERE     HOVERING_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
                   AND HOVERING_BRN_CODE = HOEVER_REC (L).V_HOVERING_BRN_CODE
                   AND HOVERING_YEAR = HOEVER_REC (L).V_HOVERING_YEAR
                   AND HOVERING_SL_NUM = HOEVER_REC (L).V_HOVERING_SL_NUM;
         END IF;
      END UPDATE_HOVERING;

      PROCEDURE POST_PROCESS (K IN NUMBER)
      IS
      BEGIN
         PKG_APOST_INTERFACE.SP_POSTING_BEGIN (PKG_ENTITY.FN_GET_ENTITY_CODE);
         SETTRANKEYVALUE (HOEVER_REC (K).V_HOVERING_BRN_CODE, W_CBD);
         SETTRANBATVALUE (K);
         SETTRANVALUES (K);
      END POST_PROCESS;

      PROCEDURE REDUCE_ACNTBAL (K IN NUMBER)
      IS
         COU   NUMBER;
      BEGIN
         SP_LOCK_ACNTBAL (PKG_ENTITY.FN_GET_ENTITY_CODE,
                          HOEVER_REC (K).V_HOVERING_RECOVERY_FROM_ACNT,
                          HOEVER_REC (K).V_HOVERING_RECOVERY_CURR,
                          W_ERROR);

         IF (TRIM (W_ERROR) IS NOT NULL)
         THEN
            W_ERROR := 'ERROR UPDATING ACNTBAL';
            RAISE USR_EXCEPTION;
         END IF;

         SELECT COUNT (1)
           INTO COU
           FROM ACNTBAL
          WHERE     ACNTBAL_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
                AND ACNTBAL_INTERNAL_ACNUM =
                       HOEVER_REC (K).V_HOVERING_RECOVERY_FROM_ACNT
                AND ACNTBAL_CURR_CODE =
                       HOEVER_REC (K).V_HOVERING_RECOVERY_CURR;

         IF (COU <> 1)
         THEN
            W_ERROR := 'ERROR UPDATING ACNTBAL';
            RAISE USR_EXCEPTION;
         END IF;

         UPDATE ACNTBAL
            SET ACNTBAL_AC_DB_QUEUE_AMT = ACNTBAL_AC_DB_QUEUE_AMT - W_REC_AMT
          WHERE     ACNTBAL_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
                AND ACNTBAL_INTERNAL_ACNUM =
                       HOEVER_REC (K).V_HOVERING_RECOVERY_FROM_ACNT
                AND ACNTBAL_CURR_CODE =
                       HOEVER_REC (K).V_HOVERING_RECOVERY_CURR;
      END REDUCE_ACNTBAL;

      PROCEDURE GET_SELECT_DETAILS
      IS
         COU           NUMBER;
         W_EXIT_LOOP   BOOLEAN DEFAULT FALSE;
      BEGIN
         W_SQL :=
               'SELECT HOVERING_BRN_CODE,HOVERING_YEAR,HOVERING_SL_NUM,
       HOVERING_RECOVERY_FROM_ACNT,HOVERING_RECOVERY_TO_ACNT,HOVERING_RECOVERY_CURR,
       HOVERING_PENDING_AMT,HOVERING_RECOVERY_NARR1,HOVERING_RECOVERY_NARR2,HOVERING_RECOVERY_NARR3,
       HOVERING_GLACC_CODE,HOVERING_CHG_CODE,HOVERTYPE_PARTIAL_REC_ALLOWED,
        HOVERTYPE_TRAN_CODE FROM ACNTS,ACNTBAL,HOVERING,HOVERTYPE WHERE HOVERING_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND ACNTBAL_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE 
        AND ACNTS_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND  HOVERING_START_DATE <= '
            || CHR (39)
            || W_CBD
            || CHR (39)
            || ' AND (HOVERING_END_DATE IS NULL OR HOVERING_END_DATE  >=  '
            || CHR (39)
            || W_CBD
            || CHR (39)
            || ') AND HOVERING_STATUS <> ''C'' AND HOVERING_PENDING_AMT > 0 AND HOVERING_AUTH_ON IS NOT NULL AND HOVERING_CANC_ON IS NULL AND HOVERING_TYPE = HOVERTYPE_CODE AND HOVERING_RECOVERY_FROM_ACNT = ACNTBAL_INTERNAL_ACNUM AND HOVERING_RECOVERY_FROM_ACNT = ACNTS_INTERNAL_ACNUM AND ACNTS_CLOSURE_DATE IS NULL AND ACNTS_DB_FREEZED <> ''1'' AND HOVERING_RECOVERY_CURR  = ACNTBAL_CURR_CODE AND ACNTBAL_AC_DB_QUEUE_AMT > 0';

         IF (P_BRAN_CODE <> 0)
         THEN
            W_SQL := W_SQL || ' AND HOVERING_BRN_CODE =' || P_BRAN_CODE;
         END IF;

         IF (P_ACCOUNT_NUMBER <> 0)
         THEN
            W_SQL :=
                  W_SQL
               || ' AND HOVERING_RECOVERY_FROM_ACNT = '
               || P_ACCOUNT_NUMBER;
         END IF;

         IF (P_ACCOUNT_NUMBER = 0)
         THEN
            IF (PKG_EODSOD_FLAGS.PV_EODSODFLAG = 'E')
            THEN
               W_SQL :=
                     W_SQL
                  || ' AND HOVERTYPE_AT_EOD = '
                  || CHR (39)
                  || '1'
                  || CHR (39);
            END IF;

            IF (PKG_EODSOD_FLAGS.PV_EODSODFLAG = 'S')
            THEN
               W_SQL :=
                     W_SQL
                  || ' AND HOVERTYPE_AT_SOD = '
                  || CHR (39)
                  || '1'
                  || CHR (39);
            END IF;
         END IF;

         IF P_ACCOUNT_NUMBER > 0
         THEN
            W_SQL :=
                  W_SQL
               || ' AND HOVERTYPE_ONLINE = '
               || CHR (39)
               || '1'
               || CHR (39);
         END IF;

         -- MUKUND-CHN-19/03/2011-REM-BEG
         --      W_SQL := W_SQL ||
         --               ' ORDER BY HOVERING_RECOVERY_FROM_ACNT,HOVERTYPE_PRIORITY';
         -- MUKUND-CHN-19/03/2011-REM-END

         W_SQL :=
               W_SQL
            || ' ORDER BY HOVERING_RECOVERY_FROM_ACNT,HOVERTYPE_PRIORITY,HOVERING_AUTH_ON,HOVERING_ENTITY_NUM,HOVERING_BRN_CODE,HOVERING_YEAR,HOVERING_SL_NUM';


         EXECUTE IMMEDIATE W_SQL BULK COLLECT INTO HOEVER_REC;
         dbms_output.put_line(W_SQL);
        dbms_output.put_line(HOEVER_REC.count());
         IF HOEVER_REC.FIRST IS NOT NULL
         THEN
            FOR J IN HOEVER_REC.FIRST .. HOEVER_REC.LAST
            LOOP
               INIT_LOOP_VARIABLE;
               W_AMT_TOBE_RECOV := HOEVER_REC (J).V_HOVERING_PENDING_AMT;
               PKG_AVLBAL_WRAPPER.P_ERR_MSG := '';
               PKG_AVLBAL_WRAPPER.SP_AVLBAL_WRAP (
                  PKG_ENTITY.FN_GET_ENTITY_CODE,
                  HOEVER_REC (J).V_HOVERING_RECOVERY_FROM_ACNT,
                  0,
                  1,
                  1); -- 0,1,1 FOR CONTRACT NUMBER, MINIMUM BALANCE NOT REQ, SHADOW BALANCE

               IF (TRIM (PKG_AVLBAL_WRAPPER.P_ERR_MSG) IS NOT NULL)
               THEN
                  W_ERROR := PKG_AVLBAL_WRAPPER.P_ERR_MSG;
                  RAISE USR_EXCEPTION;
               END IF;

               W_AVL_BAL := PKG_AVLBAL_WRAPPER.P_AC_EFFBAL;
               DBMS_OUTPUT.put_line (W_AVL_BAL);

              IF (W_AVL_BAL > 0)
               THEN
                  IF     ((W_AMT_TOBE_RECOV > W_AVL_BAL)
                     AND (HOEVER_REC (J).V_HOVERTYPE_PARTIAL_REC_ALL = '1'))
                  THEN
                     W_REC_AMT := W_AVL_BAL;
                  ELSIF (W_AMT_TOBE_RECOV <= W_AVL_BAL)
                  THEN
                     W_REC_AMT := W_AMT_TOBE_RECOV;
                  ELSE
                     W_REC_AMT := 0;
                  END IF;

                  /*
                    <<READ_HOVERBRK>> --ARUNMUGESH.J 17-Sep-2009 BEG
                    BEGIN
                      SELECT COUNT(1)
                        INTO COU
                        FROM HOVERRECBRK
                        WHERE HOVERBRK_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE AND  HOVERBRK_BRN_CODE = HOEVER_REC(J)
                      .V_HOVERING_BRN_CODE
                         AND HOVERBRK_YEAR = HOEVER_REC(J)
                      .V_HOVERING_YEAR
                         AND HOVERBRK_SL_NUM = HOEVER_REC(J)
                      .V_HOVERING_SL_NUM;
                      IF COU > 1 THEN
                        W_REC_AMT := 0;
                      ELSE
                        W_REC_AMT := W_AVL_BAL;
                      END IF;
                    END READ_HOVERBRK; --ARUNMUGESH.J 17-Sep-2009 END
                    */


                  IF (W_REC_AMT > 0)
                  THEN
                     IF (HOEVER_REC (J).V_HOVERING_RECOVERY_TO_ACNT > 0)
                     THEN
                       <<READACNTS>>
                        BEGIN
                           --Prasanth NS-CHN-03-03-2008-changed
                           FOR IDX1
                              IN (  SELECT HOVERBRK_BRK_SL,
                                           HOVERBRK_INTERNAL_ACNUM,
                                           HOVERBRK_GLACC_CODE,
                                           HOVERBRK_CURR_CODE,
                                           HOVERBRK_RECOVERY_AMT
                                      FROM HOVERRECBRK
                                     WHERE     HOVERBRK_ENTITY_NUM =
                                                  PKG_ENTITY.FN_GET_ENTITY_CODE
                                           AND HOVERBRK_BRN_CODE =
                                                  HOEVER_REC (J).V_HOVERING_BRN_CODE
                                           AND HOVERBRK_YEAR =
                                                  HOEVER_REC (J).V_HOVERING_YEAR
                                           AND HOVERBRK_SL_NUM =
                                                  HOEVER_REC (J).V_HOVERING_SL_NUM
                                  ORDER BY HOVERBRK_BRK_SL ASC)
                           LOOP
                              --ARUNMUGESH 17-Sep-2009
                              --Poorani - chn- 19/08/2011 - Beg
                              W_ACNTS_CR_FREEZED := '';
                              W_ACNTS_CLOSURE_DATE := NULL;

                              --Poorani - chn- 19/08/2011 - End
                              SELECT ACNTS_CR_FREEZED, ACNTS_CLOSURE_DATE
                                INTO W_ACNTS_CR_FREEZED, W_ACNTS_CLOSURE_DATE
                                FROM ACNTS
                               WHERE     ACNTS_ENTITY_NUM =
                                            PKG_ENTITY.FN_GET_ENTITY_CODE
                                     AND ACNTS_INTERNAL_ACNUM =
                                            IDX1.HOVERBRK_INTERNAL_ACNUM;

                              IF (   W_ACNTS_CR_FREEZED <> 0
                                  OR W_ACNTS_CLOSURE_DATE IS NOT NULL)
                              THEN
                                 --ARUNMUGESH 17-Sep-2009
                                 W_EXIT_LOOP := TRUE;
                              --poorani - chn- 19/08/2011 - Beg
                              ELSE                                          --
                                 W_EXIT_LOOP := FALSE;
                              --poorani - chn- 19/08/2011 - Beg
                              END IF;
                           END LOOP;
                        EXCEPTION
                           WHEN NO_DATA_FOUND
                           THEN
                              W_ERROR := 'INVALID ACCOUNT';
                              RAISE USR_EXCEPTION;
                        END READACNTS;
                     END IF;

                     --Prasanth NS-CHN-03-03-2008-changed
                     IF (NOT W_EXIT_LOOP)
                     THEN
                        --ARUNMUGESH 17-Sep-2009
                        UPDATE_HOVERREC (J);
                        POST_PROCESS (J);
                        UPDATE_HOVREC (J);
                        REDUCE_ACNTBAL (J);
                        UPDATE_HOVERING (J);
                     END IF;
                  END IF;
               END IF;
            END LOOP;
         END IF;

         CANCEL_HOVERING;
      END GET_SELECT_DETAILS;

      PROCEDURE CANCEL_HOVERING
      IS
         DUMMY   VARCHAR2 (3);
      BEGIN
         FOR HOV_IDX
            IN (SELECT HOVERING_BRN_CODE,
                       HOVERING_YEAR,
                       HOVERING_SL_NUM,
                       HOVERING_RECOVERY_FROM_ACNT,
                       HOVERING_PENDING_AMT,
                       HOVERING_RECOVERY_CURR
                  FROM HOVERING
                 WHERE     HOVERING_ENTITY_NUM =
                              PKG_ENTITY.FN_GET_ENTITY_CODE
                       AND HOVERING_END_DATE IS NOT NULL
                       AND HOVERING_END_DATE < W_CBD
                       AND HOVERING_STATUS <> 'C'
                       AND HOVERING_PENDING_AMT > 0
                       AND HOVERING_AUTH_ON IS NOT NULL
                       AND HOVERING_CANC_ON IS NULL)
         LOOP
            UPDATE HOVERING
               SET HOVERING_STATUS = 'C',
                   HOVERING_CANC_BY = W_USERID,
                   HOVERING_CANC_ON =
                      TO_DATE (
                            W_CBD
                         || ' '
                         || PKG_PB_GLOBAL.FN_GET_CURR_BUS_TIME (
                               PKG_ENTITY.FN_GET_ENTITY_CODE),
                         'DD-MM-YYYY HH24:MI:SS')
             WHERE     HOVERING_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
                   AND HOVERING_BRN_CODE = HOV_IDX.HOVERING_BRN_CODE
                   AND HOVERING_YEAR = HOV_IDX.HOVERING_YEAR
                   AND HOVERING_SL_NUM = HOV_IDX.HOVERING_SL_NUM;

           <<READ_ACNTBAL>>
            BEGIN
               SELECT ACNTBAL_CURR_CODE
                 INTO DUMMY
                 FROM ACNTBAL
                WHERE     ACNTBAL_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
                      AND ACNTBAL_INTERNAL_ACNUM =
                             HOV_IDX.HOVERING_RECOVERY_FROM_ACNT
                      AND ACNTBAL_CURR_CODE = HOV_IDX.HOVERING_RECOVERY_CURR;

               SP_LOCK_ACNTBAL (PKG_ENTITY.FN_GET_ENTITY_CODE,
                                HOV_IDX.HOVERING_RECOVERY_FROM_ACNT,
                                HOV_IDX.HOVERING_RECOVERY_CURR,
                                W_ERROR);

               IF (TRIM (W_ERROR) IS NOT NULL)
               THEN
                  RAISE USR_EXCEPTION;
               END IF;

               UPDATE ACNTBAL
                  SET ACNTBAL_AC_DB_QUEUE_AMT =
                           ACNTBAL_AC_DB_QUEUE_AMT
                         - HOV_IDX.HOVERING_PENDING_AMT
                WHERE     ACNTBAL_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
                      AND ACNTBAL_INTERNAL_ACNUM =
                             HOV_IDX.HOVERING_RECOVERY_FROM_ACNT
                      AND ACNTBAL_CURR_CODE = HOV_IDX.HOVERING_RECOVERY_CURR;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  W_ERROR := 'Error in Updating Account Balance';
                  RAISE USR_EXCEPTION;
            END READ_ACNTBAL;
         END LOOP;
      END CANCEL_HOVERING;

   BEGIN
      --ENTITY CODE COMMONLY ADDED - 06-11-2009  - BEG
      PKG_ENTITY.SP_SET_ENTITY_CODE (V_ENTITY_NUM);

     --ENTITY CODE COMMONLY ADDED - 06-11-2009  - END
     <<START_PROCESS>>
      BEGIN
         INIT_PARA;
         GET_SELECT_DETAILS;
      EXCEPTION
         WHEN OTHERS
         THEN
            IF (TRIM (W_ERROR) IS NULL)
            THEN
               W_ERROR := 'ERROR IN SP_HOVERING';
            END IF;

            PKG_EODSOD_FLAGS.PV_ERROR_MSG := W_ERROR;
            PKG_PB_GLOBAL.DETAIL_ERRLOG (PKG_ENTITY.FN_GET_ENTITY_CODE,
                                         'E',
                                         PKG_EODSOD_FLAGS.PV_ERROR_MSG,
                                         ' ',
                                         0);
            PKG_PB_GLOBAL.DETAIL_ERRLOG (PKG_ENTITY.FN_GET_ENTITY_CODE,
                                         'E',
                                         SUBSTR (SQLERRM, 1, 1000),
                                         ' ',
                                         0);
      END START_PROCESS;
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.PUT_LINE (SQLERRM);
   END SP_HOVERING;
END PKG_HOVERING;
/
