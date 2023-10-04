CREATE OR REPLACE PROCEDURE SP_MIG_OPENBAL (
   P_BRANCH_CODE   IN     NUMBER,
   P_START_DATE    IN     DATE,
   W_ERR              OUT VARCHAR2)
IS
  

   W_ERROR            VARCHAR2 (1000);
   W_BATCH_NUM        TRANBAT2005.TRANBAT_BATCH_NUMBER%TYPE := 0;
   W_REC              TRAN2005.TRAN_BATCH_SL_NUM%TYPE := 0;
   W_ERROR_CODE       VARCHAR2 (5) := '0000';
   W_SOURCE_KEY       VARCHAR2 (500) := 'MIGRATION..';
   I                  NUMBER (6) := 0;
   J                  NUMBER (6) := 0;
   W_SQL              VARCHAR2 (5000);
   W_START_DATE       DATE;
   W_INTERNAL_ACNUM   ACNTS.ACNTS_INTERNAL_ACNUM%TYPE;
   W_GLACESSCODE      ACNTS.ACNTS_GLACC_CODE%TYPE;
   W_DUMMY_NUM        NUMBER (3);                 --ACNTS.acnts_internal%TYPE;
   W_PREV_STAT_DATE   DATE;
   W_CR_AMT           NUMBER (18, 3);
   W_DB_AMT           NUMBER (18, 3);
   W_BCR_AMT          NUMBER (18, 3);
   W_BDB_AMT          NUMBER (18, 3);
   --w_glhead         varchar2(10);
   W_ENTITY_NUM       NUMBER (3) := GET_OTN.ENTITY_NUMBER;

   W_MIG_TRANSIT_GL   EXTGL.EXTGL_ACCESS_CODE%TYPE := '1061502';
   W_CURR             VARCHAR2 (3) DEFAULT 'BDT';
   W_TOTAL_AMOUNT     NUMBER (18, 3);

   TYPE MIG_AC_BAL_REC IS RECORD
   (
      --GL_HEAD                 NUMBER(6),
      GL_HEAD                   extgl.extgl_access_code%TYPE,
      SUB_GL                    NUMBER (6),
      AC_NUM                    VARCHAR2 (16),
      BALANCE                   NUMBER (18, 3),
      DRCR                      CHAR (1),
      CALC_INTEREST             NUMBER (18, 3),
      PRINCIPLE_TOBE_RECEIVED   NUMBER (18, 3),
      INTEREST_TOBE_RECEIVED    NUMBER (18, 3),
      CHARGES_TOBE_RECEIVED     NUMBER (18, 3),
      RECPT_NUM                 VARCHAR2 (10)
   );

   TYPE T_MIG_AC_BAL_REC IS TABLE OF MIG_AC_BAL_REC
                               INDEX BY BINARY_INTEGER;

   W_MIG_AC_BAL_REC   T_MIG_AC_BAL_REC;

   TYPE W_CUST_GL IS TABLE OF VARCHAR2 (15)
                        INDEX BY BINARY_INTEGER;

   V_CUST_GL          W_CUST_GL;

   TYPE ARR_CUST_GL IS TABLE OF MIG_CUSTOMER_GLS.GL_HEAD%TYPE
                          INDEX BY VARCHAR2 (14);

   VA_CUST_GL         ARR_CUST_GL;

   TYPE W_LOAN_GL IS TABLE OF MIG_LOAN_GLS.GL_HEAD%TYPE
                        INDEX BY BINARY_INTEGER;

   V_LOAN_GL          W_LOAN_GL;

   TYPE ARR_LOAN_GL IS TABLE OF MIG_CUSTOMER_GLS.GL_HEAD%TYPE
                          INDEX BY VARCHAR2 (14);

   VA_LOAN_GL         ARR_LOAN_GL;

   PROCEDURE POST_ERR_LOG (W_SOURCE_KEY    VARCHAR2,
                           W_START_DATE    DATE,
                           W_ERROR_CODE    VARCHAR2,
                           W_ERROR         VARCHAR2)
   IS
   --   PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      INSERT INTO MIG_ERRORLOG (MIG_ERR_SRC_KEY,
                                MIG_ERR_DTL_SL,
                                MIG_ERR_MIGDATE,
                                MIG_ERR_CODE,
                                MIG_ERR_DESC)
           VALUES (W_SOURCE_KEY,
                   (SELECT NVL (MAX (MIG_ERR_DTL_SL), 0) + 1
                      FROM MIG_ERRORLOG P
                     WHERE P.MIG_ERR_MIGDATE = W_START_DATE),
                   W_START_DATE,
                   W_ERROR_CODE,
                   W_ERROR);
   --COMMIT;
   END POST_ERR_LOG;

   PROCEDURE WRITE_LOG
   IS
   BEGIN
      W_ERROR := W_ERROR;
      W_ERROR_CODE := W_ERROR_CODE;
      W_SOURCE_KEY := W_SOURCE_KEY;
      W_START_DATE := P_START_DATE;
      POST_ERR_LOG (W_SOURCE_KEY,
                    W_START_DATE,
                    W_ERROR_CODE,
                    W_ERROR);
   END WRITE_LOG;

   PROCEDURE SET_CBD
   IS
   BEGIN
      UPDATE MAINCONT M
         SET M.MN_CURR_BUSINESS_DATE = W_START_DATE,
             M.MN_PREV_BUSINESS_DATE = W_PREV_STAT_DATE;
   END SET_CBD;

   PROCEDURE INITPARA
   IS
   BEGIN
      --natarajan.a-chn-13-06-2008-rem    W_ERROR      := '00000';
      W_ERROR := '';
      W_BATCH_NUM := 0;
      W_REC := 0;
      W_ERROR_CODE := '00000';
      W_SOURCE_KEY := 'MIGRATION..';
      I := 0;
      J := 0;

     <<CUST_GL>>
      BEGIN
         --SELECT GL_HEAD BULK COLLECT INTO V_CUST_GL FROM MIG_CUSTOMER_GLS;
         SELECT EXTGL_ACCESS_CODE
           BULK COLLECT INTO V_CUST_GL
           FROM EXTGL
          WHERE EXTGL.EXTGL_GL_HEAD IN (SELECT GLMAST.GL_NUMBER
                                          FROM GLMAST
                                         WHERE GLMAST.GL_CUST_AC_ALLOWED = 1);

         FOR I IN V_CUST_GL.FIRST .. V_CUST_GL.LAST
         LOOP
            VA_CUST_GL (V_CUST_GL (I)) := V_CUST_GL (I);
         END LOOP;

         VA_CUST_GL (3400) := 3400;                                    -- TEMP
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END CUST_GL;

     -- Storing LoanGLs (FOR WHICH BREAK UP REQUIRED )in Array and Search from Array
     /* The following GLS will be having break up
     6300, 6400, 6405, 6410, 6415, 6420, 6430, 6450, 6460, 6461,
     6462, 6480, 6490, 6500, 6510, 6520, 6523, 6525, 6530, 6540,
     6550, 6600, 6605, 6610, 6611, 6620, 6630, 6640, 6650, 6700,
     6800, 6810, 6820, 6900, 6950, 7000, 7010, 7015, 7030, 7040,
     7211, 7215, 7216, 7235, 7236, 7258, 7260, 7280, 7295, 7290,
     7305, 7350, 7340 and 7360 */
     <<LOAN_GL>>
      BEGIN
         SELECT GL_HEAD
           BULK COLLECT INTO V_LOAN_GL
           FROM MIG_LOAN_GLS
          WHERE BREAKUP_REQD = 'Y';

         IF V_LOAN_GL.COUNT > 0
         THEN
            FOR I IN V_LOAN_GL.FIRST .. V_LOAN_GL.LAST
            LOOP
               VA_LOAN_GL (V_LOAN_GL (I)) := V_LOAN_GL (I);
            END LOOP;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END LOAN_GL;
   EXCEPTION
      WHEN OTHERS
      THEN
         W_ERROR := 'INITPARA : ' || SQLERRM;
         WRITE_LOG;
   END INITPARA;

   PROCEDURE SET_SOURCE_KEY
   IS
   BEGIN
      W_SOURCE_KEY :=
            'OPENING BALANCE  MIG :'
         || TRIM (W_REC)
         || '**'
         || TRIM (W_MIG_AC_BAL_REC (W_REC).GL_HEAD)
         || '**'
         || TRIM (W_MIG_AC_BAL_REC (W_REC).SUB_GL)
         || '**'
         || TRIM (W_MIG_AC_BAL_REC (W_REC).AC_NUM)
         || '**'
         || TRIM (W_MIG_AC_BAL_REC (W_REC).BALANCE)
         || '**'
         || TRIM (W_MIG_AC_BAL_REC (W_REC).DRCR)
         || '**';
   END SET_SOURCE_KEY;

   FUNCTION CHECK_GL (P_GL_HEAD       IN     VARCHAR2,
                      --P_SUBGL_HEAD  IN VARCHAR2,
                      P_PRODCODE      IN     VARCHAR2,
                      P_ACCOUNT_NUM   IN     VARCHAR2,
                      P_A_G              OUT VARCHAR2)
      RETURN BOOLEAN
   IS
      W_GL_HEAD   GLOTN.GLOTN_IBS_GL_HEAD%TYPE := P_GL_HEAD;
      W_SUBGL     GLOTN.GLOTN_IBS_SUB_GL_HEAD%TYPE := 0;
      W_PROD      VARCHAR2 (10);                                      
   --  W_SQL_GL VARCHAR2(1000);
   -- W_GLHEAD MIG_CUSTOMER_GLS.GL_HEAD%TYPE := '';
   BEGIN
      /*
        ===================================================
                                   C H E C K I N G    G L
        ===================================================
        1.  Check the p_gl_head in mig_customer_gls
            if record found then select int ac num from acntont using p_account num
            else if record not found  select glaccesscode in glotn using gl_head and subgl_head

        2.  P_A_G  = 'A' if Customer GL ; 'N' - Non customer GL

        3.  W_error '002' if record not found in both otn

      ===================================================
       */

      -- Instead of Accessing Database Every Time Array Used

      IF VA_CUST_GL.EXISTS (TO_NUMBER (P_GL_HEAD))
      THEN
         P_A_G := 'A';
      ELSE
         P_A_G := 'N';
      END IF;

      IF P_A_G = 'A'
      THEN
         --S.karthik-10-OCT-2009-Beg
         IF P_PRODCODE IS NULL
         THEN
            SELECT ACNTS.ACNTS_PROD_CODE
              INTO W_PROD
              FROM ACNTS
             WHERE ACNTS_CLIENT_NUM = 90000099 AND ROWNUM = 1;
         ELSE
            W_PROD := P_PRODCODE;
         END IF;

         --S.karthik-10-OCT-2009-End

         IF GET_OTN.GET_AC_OTN (P_BRANCH_CODE,
                                P_ACCOUNT_NUM,
                                W_GL_HEAD,
                                W_PROD,
                                W_INTERNAL_ACNUM,
                                W_ERROR,
                                W_ERROR_CODE) = FALSE
         THEN
            WRITE_LOG;
            RETURN FALSE;
         ELSE
            W_ERROR_CODE := '00000';

           --S.Karthik-02-NOV-2007-Beg
           <<CHK_DUMMY>>
            DECLARE
               W_COUNT   NUMBER (3) := 0;
            BEGIN
               SELECT COUNT (1)
                 INTO W_COUNT
                 FROM DUMMY_ACNTS
                WHERE INTERNAL_ACNUM = W_INTERNAL_ACNUM;

               IF W_COUNT <> 0
               THEN
                  CHECK_DUMMY_PROD (P_BRANCH_CODE,
                                    P_GL_HEAD,
                                    P_ACCOUNT_NUM,
                                    P_START_DATE,
                                    W_MIG_AC_BAL_REC (W_REC).BALANCE,
                                    W_INTERNAL_ACNUM,
                                    W_ERROR);
               --S.Karthik-02-NOV-2007-End
               END IF;
            END CHK_DUMMY;

            RETURN TRUE;
         END IF;
      ELSIF P_A_G = 'N'
      THEN
         IF GET_OTN.GET_GL_OTN (P_BRANCH_CODE,
                                W_GL_HEAD,
                                W_SUBGL,
                                W_GLACESSCODE,
                                W_ERROR,
                                W_ERROR_CODE) = FALSE
         THEN
            WRITE_LOG;
            RETURN FALSE;
         ELSE
            RETURN TRUE;
         END IF;
      END IF;
   END CHECK_GL;

   PROCEDURE SET_VOUCHER_DETAILS
   IS
      W_A_G    CHAR (1) := '';
      -- VARCHAR2(3) := 'BDT';
      W_TAMT   NUMBER (18, 3);
      W_BAMT   NUMBER (18, 3);
   BEGIN
      IF W_INTERNAL_ACNUM = 1001100016767
      THEN
         NULL;
      END IF;

      I := I + 1;
      --PKG_AUTOPOST.PV_ALLOW_ZERO_TRANAMT := TRUE; --S.Karthik-02-NOV-2007-Added
      PKG_AUTOPOST.PV_TRAN_REC (I).TRAN_ENTITY_NUM := W_ENTITY_NUM;
      PKG_AUTOPOST.PV_TRAN_REC (I).TRAN_ACING_BRN_CODE := P_BRANCH_CODE;
      PKG_AUTOPOST.PV_TRAN_REC (I).TRAN_DB_CR_FLG :=
         W_MIG_AC_BAL_REC (W_REC).DRCR;
      PKG_AUTOPOST.PV_TRAN_REC (I).TRAN_AMOUNT :=
         TO_NUMBER (ABS (W_MIG_AC_BAL_REC (W_REC).BALANCE));
      PKG_AUTOPOST.PV_TRAN_REC (I).TRAN_BASE_CURR_EQ_AMT :=
         TO_NUMBER (W_MIG_AC_BAL_REC (W_REC).BALANCE);
      PKG_AUTOPOST.PV_TRAN_REC (I).TRAN_CURR_CODE := W_CURR;
      W_TAMT := TO_NUMBER (ABS (W_MIG_AC_BAL_REC (W_REC).BALANCE));
      W_BAMT := W_TAMT;
      PKG_AUTOPOST.PV_TRAN_REC (I).TRAN_SYSTEM_POSTED_TRAN := '1'; --Neel-mds-19-dec-2007

      IF W_MIG_AC_BAL_REC (w_rec).ac_num = '0020316000018'
      THEN
         NULL;
      END IF;

      -- CHECK ACCOUNT VALIDATIONS
      IF CHECK_GL (W_MIG_AC_BAL_REC (W_REC).GL_HEAD,
                   --W_MIG_AC_BAL_REC(W_REC).SUB_GL,
                   --SUBSTR(W_MIG_AC_BAL_REC(W_REC).AC_NUM, 4, 3),
                   SUBSTR (W_MIG_AC_BAL_REC (W_REC).AC_NUM, 4, 4),
                   W_MIG_AC_BAL_REC (W_REC).AC_NUM,
                   W_A_G)
      THEN
         IF W_A_G = 'A'
         THEN
            PKG_AUTOPOST.PV_TRAN_REC (I).TRAN_INTERNAL_ACNUM :=
               W_INTERNAL_ACNUM;

            W_SQL :=
                  'SELECT ACNTS_CURR_CODE '
               || ' FROM   ACNTS '
               || ' WHERE  ACNTS.ACNTS_INTERNAL_ACNUM = :1 ';

            EXECUTE IMMEDIATE W_SQL INTO W_CURR USING W_INTERNAL_ACNUM;

            PKG_AUTOPOST.PV_TRAN_REC (I).TRAN_CURR_CODE := W_CURR;

            -- Notional Rate Changes Beg
            /*
              1) GBP  - Rs. 68.00       2) Euro  - Rs. 48.00           3) USD  - Rs. 45.00
              4) JPY   - Rs. 30/100     5) CHF   - Rs. 30.00           6) CAD   - Rs.37.00
              7) AUD   - Rs. 32.00
              The abov rates provided by bank later theses to be deleted and
              base currency EQ. should be provide by bank along with Opening Balance
              Trnsaction File
            */
            IF W_CURR <> 'BDT'
            THEN
               CASE
                  WHEN W_CURR = 'BDT'
                  THEN
                     PKG_AUTOPOST.PV_TRAN_REC (I).TRAN_BASE_CURR_CONV_RATE :=
                        129;
                  WHEN W_CURR = 'CHF'
                  THEN
                     PKG_AUTOPOST.PV_TRAN_REC (I).TRAN_BASE_CURR_CONV_RATE :=
                        86;
                  WHEN W_CURR = 'USD'
                  THEN
                     PKG_AUTOPOST.PV_TRAN_REC (I).TRAN_BASE_CURR_CONV_RATE :=
                        81;
                  WHEN W_CURR = 'CAD'
                  THEN
                     PKG_AUTOPOST.PV_TRAN_REC (I).TRAN_BASE_CURR_CONV_RATE :=
                        80;
                  WHEN W_CURR = 'AUD'
                  THEN
                     PKG_AUTOPOST.PV_TRAN_REC (I).TRAN_BASE_CURR_CONV_RATE :=
                        0.99;
                  WHEN W_CURR = 'EUR'
                  THEN
                     PKG_AUTOPOST.PV_TRAN_REC (I).TRAN_BASE_CURR_CONV_RATE :=
                        0.77;
                  ELSE
                     PKG_AUTOPOST.PV_TRAN_REC (I).TRAN_BASE_CURR_CONV_RATE :=
                        10;
               END CASE;

               W_BAMT :=
                  W_TAMT
                  / PKG_AUTOPOST.PV_TRAN_REC (I).TRAN_BASE_CURR_CONV_RATE;
               DBMS_OUTPUT.
                PUT_LINE (
                     'Account'
                  || W_INTERNAL_ACNUM
                  || ' Base Currency'
                  || W_BAMT
                  || ' Tran Currency'
                  || W_TAMT
                  || ' DR CR'
                  || W_MIG_AC_BAL_REC (W_REC).DRCR);
               PKG_AUTOPOST.PV_TRAN_REC (I).TRAN_AMOUNT :=
                  TO_NUMBER (W_MIG_AC_BAL_REC (W_REC).BALANCE)
                  / PKG_AUTOPOST.PV_TRAN_REC (I).TRAN_BASE_CURR_CONV_RATE;
            END IF;
         -- Notional Rate Changes end
         ELSE
            PKG_AUTOPOST.PV_TRAN_REC (I).TRAN_ENTITY_NUM := W_ENTITY_NUM;
            PKG_AUTOPOST.PV_TRAN_REC (I).TRAN_ACING_BRN_CODE := P_BRANCH_CODE;
            PKG_AUTOPOST.PV_TRAN_REC (I).TRAN_GLACC_CODE := W_GLACESSCODE;
         END IF;
      ELSE
         W_ERROR := 'GL MAPPING NOT FOUND ';
         W_ERROR_CODE := '002';
         WRITE_LOG;
      END IF;

      IF PKG_AUTOPOST.PV_TRAN_REC (I).TRAN_INTERNAL_ACNUM <> 0
      THEN
        <<READPROD>>
         W_DUMMY_NUM := '0';

         BEGIN
            SELECT COUNT (ACNTS_CONTRACT_BASED_FLG)                 --COUNT(1)
              INTO W_DUMMY_NUM
              FROM ACNTS A, PRODUCTS P
             WHERE A.ACNTS_INTERNAL_ACNUM =
                      PKG_AUTOPOST.PV_TRAN_REC (I).TRAN_INTERNAL_ACNUM
                   AND P.PRODUCT_CODE = A.ACNTS_PROD_CODE
                   AND (P.PRODUCT_FOR_DEPOSITS = '1'
                        AND P.PRODUCT_CONTRACT_ALLOWED = '1');

            --Commented by S.Karthik-02-NOV-2007-Beg
            --AND    A.ACNTS_INTERNAL_ACNUM; NOT IN (SELECT INTERNAL_ACNUM FROM DUMMY_ACNTS);
            --Commented by S.Karthik-02-NOV-2007-End
            --PKG_AUTOPOST.PV_TRAN_REC(I).TRAN_CONTRACT_NUM := W_DUMMY_NUM;
            IF W_DUMMY_NUM > 0
            THEN
               SELECT MIGDEP_CONT_NUM
                 INTO W_DUMMY_NUM
                 FROM MIG_PBDCONTRACT
                WHERE MIGDEP_DEP_AC_NUM = W_MIG_AC_BAL_REC (W_REC).AC_NUM
                      AND MIGDEP_RECPT_NUM =
                             W_MIG_AC_BAL_REC (W_REC).RECPT_NUM;

               PKG_AUTOPOST.PV_TRAN_REC (I).TRAN_CONTRACT_NUM := W_DUMMY_NUM;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               --PKG_AUTOPOST.PV_TRAN_REC(I).TRAN_CONTRACT_NUM := W_DUMMY_NUM;
               IF W_DUMMY_NUM > 0
               THEN
                  PKG_AUTOPOST.PV_TRAN_REC (I).TRAN_CONTRACT_NUM := 1;
               ELSE
                  PKG_AUTOPOST.PV_TRAN_REC (I).TRAN_CONTRACT_NUM := 0;
               END IF;
         END READPROD;
      END IF;

      PKG_AUTOPOST.PV_TRAN_REC (I).TRAN_NARR_DTL1 := 'MIGRATION';

      -- PKG_AUTOPOST.PV_TRAN_REC(I).TRAN_NARR_DTL2 := 'LEG SL. ' || I;
      -- FOR LOAN ACCOUNT MOVE BREAK UP DETAILS - --   26-Oct-2007  BEG
      --IF VA_LOAN_GL.EXISTS(TO_NUMBER(W_MIG_DATA(W_REC).GL_HEAD)) AND
      IF W_MIG_AC_BAL_REC (W_REC).DRCR = 'D'
         -- AND VA_LOAN_GL.EXISTS(TO_NUMBER(W_MIG_AC_BAL_REC(W_REC).GL_HEAD)) --RASHMI/RAMESH SONALI 5/FEB/2013
         AND (NVL (W_MIG_AC_BAL_REC (W_REC).INTEREST_TOBE_RECEIVED, 0) <> 0
              OR NVL (W_MIG_AC_BAL_REC (W_REC).CHARGES_TOBE_RECEIVED, 0) <> 0)
      THEN
         PKG_AUTOPOST.PV_TRAN_REC (I).TRAN_AMT_BRKUP := 1; -- PKG_AUTOPOST.PV_TRAN_REC(I).TRAN_AMT_BRKUP = 1
         J := J + 1;

         PKG_AUTOPOST.PV_TRAN_ADV_REC (J).TRANADV_BRN_CODE := P_BRANCH_CODE;
         PKG_AUTOPOST.PV_TRAN_ADV_REC (J).TRANADV_DATE_OF_TRAN := W_START_DATE;
         PKG_AUTOPOST.PV_TRAN_ADV_REC (J).TRANADV_BATCH_NUMBER := 0;
         PKG_AUTOPOST.PV_TRAN_ADV_REC (J).TRANADV_BATCH_SL_NUM := I; -- NEEL-MDS-27-DEC-2007 MOVED I

         PKG_AUTOPOST.PV_TRAN_ADV_REC (J).TRANADV_PRIN_AC_AMT :=
            ABS (W_MIG_AC_BAL_REC (W_REC).PRINCIPLE_TOBE_RECEIVED);

         PKG_AUTOPOST.PV_TRAN_ADV_REC (J).TRANADV_INTRD_AC_AMT :=
            ABS (W_MIG_AC_BAL_REC (W_REC).INTEREST_TOBE_RECEIVED);

         PKG_AUTOPOST.PV_TRAN_ADV_REC (J).TRANADV_CHARGE_AC_AMT :=
            ABS (W_MIG_AC_BAL_REC (W_REC).BALANCE)
            - (ABS (W_MIG_AC_BAL_REC (W_REC).PRINCIPLE_TOBE_RECEIVED)
               + ABS (W_MIG_AC_BAL_REC (W_REC).INTEREST_TOBE_RECEIVED));
      END IF;
   -- FOR LOAN ACCOUNT MOVE BREAK UP DETAILS - --   26-Oct-2007  END

   EXCEPTION
      WHEN OTHERS
      THEN
         W_ERROR_CODE := '1111';
         W_ERROR := 'SET_VOUCHER_DETAILS : ' || SQLERRM;
         WRITE_LOG;
   END SET_VOUCHER_DETAILS;

   PROCEDURE SET_TRAN_KEY_VALUES
   IS
   BEGIN
      PKG_AUTOPOST.PV_TRAN_KEY.TRAN_BRN_CODE := P_BRANCH_CODE;
      PKG_AUTOPOST.PV_TRAN_KEY.TRAN_DATE_OF_TRAN := P_START_DATE;
      PKG_AUTOPOST.PV_TRAN_KEY.TRAN_BATCH_NUMBER := 0;
      PKG_AUTOPOST.PV_TRAN_KEY.TRAN_BATCH_SL_NUM := 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         W_ERROR := 'SET_TRAN_KEY_VALUES : ' || SQLERRM;
         WRITE_LOG;
   END SET_TRAN_KEY_VALUES;

   PROCEDURE SET_TRANBAT_VALUES
   IS
   BEGIN
      PKG_AUTOPOST.PV_TRANBAT.TRANBAT_SOURCE_TABLE := 'MIG';
      PKG_AUTOPOST.PV_TRANBAT.TRANBAT_SOURCE_KEY := 'MIG';

      --- Need to check
      PKG_AUTOPOST.PV_TRANBAT.TRANBAT_NARR_DTL1 := 'MIGRATED DATA';
      PKG_AUTOPOST.PV_TRANBAT.TRANBAT_NARR_DTL2 :=
         'FOR THE DATE' || TO_CHAR (P_START_DATE, 'DD-MON-YYYY');
      PKG_AUTOPOST.PV_TRANBAT.TRANBAT_NARR_DTL3 := '**';
   EXCEPTION
      WHEN OTHERS
      THEN
         W_ERROR := 'SET_TRANBAT_VALUES : ' || SQLERRM;
         WRITE_LOG;
   END SET_TRANBAT_VALUES;

   PROCEDURE POSTING_PROCESS
   IS
   BEGIN
      INITPARA;

     <<REC_FOUND>>
      BEGIN
         EXECUTE IMMEDIATE W_SQL
            BULK COLLECT INTO W_MIG_AC_BAL_REC
            USING P_START_DATE,
                  P_BRANCH_CODE,
                  P_START_DATE,
                  P_BRANCH_CODE;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            W_ERROR_CODE := '0001';                        -- No Recored Found
            W_ERROR := SQLERRM;
         WHEN OTHERS
         THEN
            W_ERROR_CODE := '0002';                        -- No Recored Found
            W_ERROR := SQLERRM;
      END REC_FOUND;

      W_CR_AMT := 0;
      W_DB_AMT := 0;
      W_BCR_AMT := 0;
      W_BDB_AMT := 0;

      IF W_MIG_AC_BAL_REC.COUNT >= 1
      THEN
         PKG_APOST_INTERFACE.SP_POSTING_BEGIN (1);

         FOR W_RECORD IN W_MIG_AC_BAL_REC.FIRST .. W_MIG_AC_BAL_REC.LAST
         LOOP
            W_REC := W_RECORD;
            SET_SOURCE_KEY;
            SET_VOUCHER_DETAILS;

            IF PKG_AUTOPOST.PV_TRAN_REC (W_RECORD).TRAN_DB_CR_FLG = 'C'
            THEN
               W_CR_AMT :=
                  W_CR_AMT + PKG_AUTOPOST.PV_TRAN_REC (W_RECORD).TRAN_AMOUNT;
               W_BCR_AMT :=
                  W_BCR_AMT
                  + PKG_AUTOPOST.PV_TRAN_REC (W_RECORD).TRAN_BASE_CURR_EQ_AMT;
            ELSE
               W_DB_AMT :=
                  W_DB_AMT + PKG_AUTOPOST.PV_TRAN_REC (W_RECORD).TRAN_AMOUNT;
               W_BDB_AMT :=
                  W_BDB_AMT
                  + PKG_AUTOPOST.PV_TRAN_REC (W_RECORD).TRAN_BASE_CURR_EQ_AMT;
            END IF;

            IF W_ERROR_CODE <> '00000'
            THEN
               DBMS_OUTPUT.
                PUT_LINE (
                  'Error in Record ' || W_REC || '   ' || W_SOURCE_KEY);
               EXIT;
            END IF;
         END LOOP;

         DBMS_OUTPUT.PUT_LINE ('W_MIG_AC_BAL_REC ' || W_MIG_AC_BAL_REC.COUNT);
         DBMS_OUTPUT.PUT_LINE ('I ' || I);
         DBMS_OUTPUT.PUT_LINE ('CR AMT ' || W_CR_AMT);
         DBMS_OUTPUT.PUT_LINE ('DB AMT ' || W_DB_AMT);

         DBMS_OUTPUT.PUT_LINE ('BASE CURRENCY CR AMT ' || W_BCR_AMT);
         DBMS_OUTPUT.PUT_LINE ('BASE CURRENCY DB AMT ' || W_BDB_AMT);

         --natarajan.a-chn-13-06-2008-rem    END IF;

         IF W_ERROR_CODE = '00000'
         THEN
            SET_TRAN_KEY_VALUES;
            SET_TRANBAT_VALUES;
            PKG_AUTOPOST.PV_USERID := 'MIG';
            PKG_PB_AUTOPOST.G_FORM_NAME := 'MIGRATION';
            PKG_PB_AUTOPOST.G_CURR_BUSSI_DATE := P_START_DATE;
            PKG_POST_INTERFACE.G_BATCH_NUMBER_UPDATE_REQ := FALSE;
            PKG_PB_GLOBAL.G_TERMINAL_ID := 'MIG01';

            --RAMESH/RASHMI 29/5/2012
            W_TOTAL_AMOUNT := 0;

            FOR IDX IN 1 .. PKG_AUTOPOST.PV_TRAN_REC.COUNT
            LOOP
               IF PKG_AUTOPOST.PV_TRAN_REC (IDX).TRAN_DB_CR_FLG = 'D'
               THEN
                  -- w_total_amount  := w_total_amount + PKG_AUTOPOST.PV_TRAN_REC(IDX).TRAN_BASE_CURR_EQ_aMT;
                  w_total_amount :=
                     w_total_amount
                     - PKG_AUTOPOST.PV_TRAN_REC (IDX).TRAN_BASE_CURR_EQ_aMT;
               ELSIF PKG_AUTOPOST.PV_TRAN_REC (IDX).TRAN_DB_CR_FLG = 'C'
               THEN
                  w_total_amount :=
                     w_total_amount
                     + PKG_AUTOPOST.PV_TRAN_rEC (IDX).TRAN_BASE_CURR_eQ_aMT;
               END IF;
            END LOOP;

            W_TOTAL_AMOUNT := W_BCR_AMT - W_BDB_AMT;      --RASHMI K ON 29/12/

            IF W_TOTAL_AMOUNT <> 0
            THEN
               i := i + 1;
               PKG_AUTOPOST.PV_TRAN_REC (I).TRAN_BATCH_SL_NUM := I;
               --MODIFIED BY RASHMI K ON 20/02/2012 PKG_AUTOPOST.PV_TRAN_REC(I).TRAN_ENTITY_NUM := 1;
               PKG_AUTOPOST.PV_TRAN_REC (I).TRAN_ENTITY_NUM := W_ENTITY_NUM;
               PKG_AUTOPOST.PV_TRAN_REC (I).TRAN_ACING_BRN_CODE :=
                  P_BRANCH_CODE;
               PKG_AUTOPOST.PV_TRAN_REC (I).TRAN_GLACC_CODE :=
                  W_MIG_TRANSIT_GL;
               PKG_AUTOPOST.PV_TRAN_REC (I).TRAN_AMOUNT :=
                  ABS (W_TOTAL_AMOUNT);
               --MODIFIED BY RASHMI K ON 20/02/2012PKG_AUTOPOST.PV_TRAN_REC(I).TRAN_CURR_CODE := 'TZS';
               PKG_AUTOPOST.PV_TRAN_REC (I).TRAN_CURR_CODE := W_CURR;
               --MODIFIED TO CHECK FOR PARKING GL TRANS COUNTPKG_AUTOPOST.PV_TRAN_REC(I).TRAN_SYSTEM_POSTED_TRAN := '0';
               PKG_AUTOPOST.PV_TRAN_REC (I).TRAN_SYSTEM_POSTED_TRAN := '2';
               PKG_AUTOPOST.PV_TRAN_REC (I).TRAN_BASE_CURR_CONV_RATE := 1;
               PKG_AUTOPOST.PV_TRAN_REC (I).TRAN_BASE_CURR_EQ_AMT :=
                  ABS (W_TOTAL_AMOUNT);

               IF W_TOTAL_AMOUNT > 0
               THEN
                  PKG_AUTOPOST.PV_TRAN_REC (I).TRAN_DB_CR_FLG := 'D';
                  --ADDED BY RASHMI ON 02/05/2011
                  PKG_AUTOPOST.PV_TRAN_REC (I).TRAN_CODE := 'TD';
               ELSE
                  PKG_AUTOPOST.PV_TRAN_REC (I).TRAN_DB_CR_FLG := 'C';
                  --ADDED BY RASHMI K ON 02/05/2011
                  PKG_AUTOPOST.PV_TRAN_REC (I).TRAN_CODE := 'TC';
               END IF;

               PKG_AUTOPOST.PV_TRAN_REC (I).TRAN_NARR_DTL1 :=
                  'Migration Transit GL';
            END IF;

            --RAMESH/RASHMI 29/5/2012
            PKG_APOST_INTERFACE.SP_POST_AUTO_AUTHORIZED (1,
                                                         'A',
                                                         I,
                                                         0,
                                                         W_ERROR_CODE,
                                                         W_ERROR,
                                                         W_BATCH_NUM);

            IF (W_ERROR_CODE <> '0000')
            THEN
               W_ERROR := SUBSTR (FN_GET_AUTOPOST_ERR_MSG (1), 1, 1000);
               WRITE_LOG;
            END IF;
         ELSE
            DBMS_OUTPUT.
             PUT_LINE ('Error in Record ... ' || W_REC || W_SOURCE_KEY);
         END IF;
      --natarajan.a-chn-13-06-2008-beg
      ELSE
         W_ERROR := '';
      END IF;
   --natarajan.a-chn-13-06-2008-end

   END POSTING_PROCESS;
/*
Commented 09-JAN-2008-Run Manually-S.Karthik
PROCEDURE MONTH_END_PROCESS IS
BEGIN
  -- Befor Processing the Month End CBD must be set
  W_PREV_STAT_DATE := W_START_DATE;
  W_START_DATE     := '01-OCT-2007'; -- HARD CODING OPENING 1ST OCTOBER 2007 FOR MONTH END PROCESS
  SET_CBD;
  PKG_EODSOD_FLAGS.PV_ERROR_MSG     := '';
  PKG_EODSOD_FLAGS.PV_CURRENT_DATE  := W_START_DATE;
  PKG_EODSOD_FLAGS.PV_PREVIOUS_DATE := W_PREV_STAT_DATE;
  PKG_EODSOD_FLAGS.PV_USER_ID       := 'MIG';
  PKG_MONBAL.SP_MONBAL;
  COMMIT;
END MONTH_END_PROCESS;
*/
BEGIN
   BEGIN
      UPDATE MIG_ACOP_BAL
         SET MIG_ACOP_BAL.ACOP_PRINCIPAL_OS =
                (SELECT MIG_LNACNT.LNACNT_PRIN_OS
                   FROM MIG_LNACNT
                  WHERE MIG_LNACNT.LNACNT_ACNUM = MIG_ACOP_BAL.ACOP_AC_NUM),
             MIG_ACOP_BAL.ACOP_INTEREST_OS =
                (SELECT MIG_LNACNT.LNACNT_INT_OS
                   FROM MIG_LNACNT
                  WHERE MIG_LNACNT.LNACNT_ACNUM = MIG_ACOP_BAL.ACOP_AC_NUM),
             MIG_ACOP_BAL.ACOP_CHGS_OS =
                (SELECT MIG_LNACNT.LNACNT_CHG_OS
                   FROM MIG_LNACNT
                  WHERE MIG_LNACNT.LNACNT_ACNUM = MIG_ACOP_BAL.ACOP_AC_NUM)
       WHERE MIG_ACOP_BAL.ACOP_AC_NUM IN
                (SELECT MIG_LNACNT.LNACNT_ACNUM
                   FROM MIG_LNACNT
                  WHERE MIG_LNACNT.LNACNT_ACNUM = MIG_ACOP_BAL.ACOP_AC_NUM);

      COMMIT;

      UPDATE ACNTS
         SET ACNTS_OD_ALLOWED = '1';

      COMMIT;
   END;

  <<REC_FOUND>>
   W_ERR := '';
   DBMS_OUTPUT.ENABLE (500000);
   W_START_DATE := P_START_DATE;
   W_PREV_STAT_DATE := P_START_DATE - 1;
   SET_CBD;
   PKG_ENTITY.SP_SET_ENTITY_CODE (1);
   -- PICKING GL          BALANCE
   -- TEMP EXCLUEDE 3400
   -- MIG_CONTRA_GLS eXECLUDED
   -- Handling Subgl balances (Multiplyig with -1 of Subgls 100 to 799)  -21-NOV-2007-  Beg
   -- NEEL UPDATION COMMENTED DONE IN MIG TOOL NEEL-14-JAN-2008
   /*  W_SQL := 'UPDATE IBS_GL_BAL SET BALANCE = BALANCE * -1 WHERE GL_HEAD BETWEEN 100 AND 799 AND BRANCH_CODE = ' ||
            P_BRANCH_CODE;
   EXECUTE IMMEDIATE W_SQL;*/
   -- Handling Subgl balances -21-NOV-2007- End

   W_SQL :=
      ' SELECT  GLOP_GL_HEAD,0,' || CHR (39) || '0' || CHR (39)
      || ' ACOP_AC_NUM , ABS(GLOP_BALANCE) BAL, DECODE(SIGN(GLOP_BALANCE)  , 1,'
      || CHR (39)
      || 'C'
      || CHR (39)
      || ','
      || CHR (39)
      || 'D'
      || CHR (39)
      || ')'
      || ' DRCR  ,0,0,0,0,null FROM  mig_glop_bal '
      || '  WHERE  GLOP_BAL_DATE = :1 AND GLOP_BRANCH_CODE = :2 AND GLOP_BALANCE <> 0
           and GLOP_GL_HEAD in (select extgl.extgl_access_code from extgl where extgl.extgl_gl_head in
(select glmast.gl_number from glmast where glmast.gl_cust_ac_allowed=0))  ';

   -- PICKING ACCOUNT  BALANCE
   W_SQL :=
      W_SQL
      || ' UNION SELECT ACOP_GL_HEAD, 0, ACOP_AC_NUM, ABS(ACOP_BALANCE) BAL, '
      || ' DECODE(SIGN(ACOP_BALANCE), 1, '
      || CHR (39)
      || 'C'
      || CHR (39)
      || ', '
      || CHR (39)
      || 'D'
      || CHR (39)
      || ') '
      || ' DRCR,  ACOP_CALC_INTEREST, ACOP_PRINCIPAL_OS, ACOP_INTEREST_OS,ACOP_CHGS_OS,ACOP_RECPT_NUM FROM mig_acop_bal '
      || ' WHERE ACOP_BAL_DATE = :3 AND ACOP_BRANCH_CODE = :4 and ACOP_BALANCE<>0 '
      || ' ORDER BY GLOP_GL_HEAD, ACOP_AC_NUM, DRCR, BAL';
   SP_DISP (1, W_SQL);
   POSTING_PROCESS;
   W_ERR := TRIM (W_ERROR);

   --natarajan.a-chn-13-06-2008-removed IF W_ERROR_CODE = '0000'
   IF W_ERROR_CODE = '0000' OR W_ERROR_CODE = '00000'
   THEN
      DBMS_OUTPUT.PUT_LINE (' OPENING BALANCE SUCCESSFUL .. . ');
      DBMS_OUTPUT.PUT_LINE (' MONTH END STARTED .. . ');



      UPDATE ACNTS
         SET ACNTS_OD_ALLOWED = '0';

      COMMIT;



      UPDATE ACNTS A
         SET A.ACNTS_OD_ALLOWED = 1
       WHERE A.ACNTS_PROD_CODE IN
                (SELECT P.PRODUCT_CODE
                   FROM PRODUCTS P
                  WHERE P.PRODUCT_CODE IN
                           (SELECT ACNTS.ACNTS_PROD_CODE
                              FROM ACNTS
                             WHERE ACNTS.ACNTS_INTERNAL_ACNUM IN
                                      (SELECT L.LNACNT_INTERNAL_ACNUM
                                         FROM LOANACNTS L))
                        AND P.PRODUCT_FOR_LOANS = 1
                        AND P.PRODUCT_FOR_RUN_ACS = 1);

      COMMIT;
   --MONTH_END_PROCESS;--09-JAN-2008-Commented-S.Karthik
   --COMMIT;
   ELSE
      W_ERR := 'ERROR IN OPENING BALANCE';
      DBMS_OUTPUT.PUT_LINE (' OPENING BALANCE UN SUCCESSFUL .. . ');
   --ROLLBACK;
   END IF;
END SP_MIG_OPENBAL;
/
