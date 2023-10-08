CREATE OR REPLACE FUNCTION FN_CALC_TERMLOAN_REC_AMOUNT(P_ENTITY_NUM IN NUMBER,W_INTERNAL_ACNUM IN NUMBER,P_FROM_DATE IN DATE,P_TO_DATE IN DATE,P_BRN_CODE IN NUMBER)
 RETURN NUMBER

 IS
 W_SQL VARCHAR2(10000);
 TRAN            NUMBER(18, 3):=0;
  type RR_TABLEB is RECORD(
                         TMP_TRANAMOUNT NUMBER(18, 3));
                    TYPE TABLEB IS TABLE OF RR_TABLEB INDEX BY PLS_INTEGER;
                    V_TEMP_TABLEB TABLEB;
    W_FRM_YEAR NUMBER :=0;
    W_TO_YEAR NUMBER :=0;
    V_TOTAL NUMBER(18,3):=0;

  BEGIN
    W_FRM_YEAR := SP_GETFINYEAR(P_ENTITY_NUM, P_FROM_DATE);
    W_TO_YEAR  := SP_GETFINYEAR(P_ENTITY_NUM, P_TO_DATE);




    IF W_FRM_YEAR = W_TO_YEAR THEN
      W_SQL := 'SELECT  T.TRAN_AMOUNT
                       FROM TRAN'||W_FRM_YEAR || ' T, TRANADV'||W_FRM_YEAR||' D,ACNTS AC
                       WHERE T.TRAN_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
                       AND T.TRAN_INTERNAL_ACNUM ='||W_INTERNAL_ACNUM||'
                       AND T.TRAN_DATE_OF_TRAN >= '||CHR(39)||P_FROM_DATE||CHR(39)||'
                       AND T.TRAN_DATE_OF_TRAN <= '||CHR(39)||P_TO_DATE||CHR(39)||'
                       AND T.TRAN_DB_CR_FLG = ''C''
                       AND T.TRAN_ENTITY_NUM = AC.ACNTS_ENTITY_NUM
                       AND T.TRAN_INTERNAL_ACNUM = AC.ACNTS_INTERNAL_ACNUM
                       AND D.TRANADV_ENTITY_NUM = T.TRAN_ENTITY_NUM
                       AND D.TRANADV_BATCH_NUMBER = T.TRAN_BATCH_NUMBER
                       AND D.TRANADV_BRN_CODE = T.TRAN_BRN_CODE
                       AND D.TRANADV_DATE_OF_TRAN = T.TRAN_DATE_OF_TRAN
                       AND D.TRANADV_BATCH_SL_NUM = T.TRAN_BATCH_SL_NUM';
                       --AND D.TRANADV_PRIN_AC_AMT <> 0

                      -- DBMS_OUTPUT.PUT_LINE('W_SQL'||W_SQL);


                    IF NVL(P_BRN_CODE, 0) <> 0 THEN
                      W_SQL := W_SQL || ' AND T.TRAN_BRN_CODE =' || P_BRN_CODE;
                    END IF;

                    W_SQL:=W_SQL||' ORDER BY T.TRAN_DATE_OF_TRAN,
                             FACNO(PKG_ENTITY.FN_GET_ENTITY_CODE, T.TRAN_INTERNAL_ACNUM)';

      EXECUTE IMMEDIATE W_SQL BULK COLLECT INTO V_TEMP_TABLEB;
        IF (V_TEMP_TABLEB.FIRST IS NOT NULL) THEN
          FOR INC IN V_TEMP_TABLEB.FIRST..V_TEMP_TABLEB.LAST
          LOOP
          TRAN:=V_TEMP_TABLEB(INC).TMP_TRANAMOUNT;
          V_TOTAL:=V_TOTAL+TRAN;
          END LOOP;

        END IF;
       -- RETURN 0;
        RETURN V_TOTAL;
    ELSE
      WHILE W_FRM_YEAR <= W_TO_YEAR LOOP
        W_SQL := 'SELECT T.TRAN_AMOUNT
                       FROM TRAN'||W_FRM_YEAR || ' T, TRANADV'||W_FRM_YEAR||' D,ACNTS AC
                       WHERE T.TRAN_ENTITY_NUM = PKG_ENTITY.FN_GET_ENTITY_CODE
                       AND T.TRAN_INTERNAL_ACNUM ='||W_INTERNAL_ACNUM||'
                       AND T.TRAN_DATE_OF_TRAN >='||CHR(39)||P_FROM_DATE||CHR(39)||'
                       AND T.TRAN_DATE_OF_TRAN <= '||CHR(39)||P_TO_DATE||CHR(39)||'
                       AND T.TRAN_DB_CR_FLG = ''C''
                       AND T.TRAN_ENTITY_NUM = AC.ACNTS_ENTITY_NUM
                       AND T.TRAN_INTERNAL_ACNUM = AC.ACNTS_INTERNAL_ACNUM
                       AND D.TRANADV_ENTITY_NUM = T.TRAN_ENTITY_NUM
                       AND D.TRANADV_BATCH_NUMBER = T.TRAN_BATCH_NUMBER
                       AND D.TRANADV_BRN_CODE = T.TRAN_BRN_CODE
                       AND D.TRANADV_DATE_OF_TRAN = T.TRAN_DATE_OF_TRAN
                       AND D.TRANADV_BATCH_SL_NUM = T.TRAN_BATCH_SL_NUM';
                      -- AND D.TRANADV_PRIN_AC_AMT <> 0
                       --DBMS_OUTPUT.PUT_LINE('W_SQL'||W_SQL);

                       IF NVL(P_BRN_CODE, 0) <> 0 THEN
                      W_SQL := W_SQL || ' AND T.TRAN_BRN_CODE =' || P_BRN_CODE;
                    END IF;

                    W_SQL:=W_SQL||' ORDER BY T.TRAN_DATE_OF_TRAN,
                             FACNO(PKG_ENTITY.FN_GET_ENTITY_CODE, T.TRAN_INTERNAL_ACNUM)';


        EXECUTE IMMEDIATE W_SQL BULK COLLECT
          --DBMS_OUTPUT.PUT_LINE('W_SQL'||W_SQL);
          INTO V_TEMP_TABLEB ;
         IF (V_TEMP_TABLEB.FIRST IS NOT NULL) THEN

               FOR INC IN V_TEMP_TABLEB.FIRST..V_TEMP_TABLEB.LAST
                   LOOP
                       TRAN:=V_TEMP_TABLEB(INC).TMP_TRANAMOUNT;
                       V_TOTAL:=V_TOTAL+TRAN;
                    END LOOP;

         END IF;
       -- RETURN 0;
        W_FRM_YEAR := W_FRM_YEAR + 1;
      END LOOP;
      RETURN V_TOTAL;
    END IF;


  END FN_CALC_TERMLOAN_REC_AMOUNT;
 
 
 
 
 
 
 
 
 
 
/
