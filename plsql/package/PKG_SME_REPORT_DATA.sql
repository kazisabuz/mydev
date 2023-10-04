CREATE OR REPLACE PACKAGE PKG_SME_REPORT_DATA
IS
    

   TYPE SME_PKG_DATA IS RECORD
   (
      SME_PROD_GRP_NAME   VARCHAR2 (100),
      SME_GRP             CHAR (1),
      SME_GRP_NAME        VARCHAR2 (100),
      SME_TYPE            VARCHAR2 (100),
      DR                  NUMBER (20),
      NO_OF_ACCOUNT       NUMBER (6),
      ORD_BY              NUMBER (6),
      BY_TYPE             VARCHAR2 (100),
      ROWGRP              NUMBER (6)
   );

   TYPE TY_SME_PKG_DATA IS TABLE OF SME_PKG_DATA;


   FUNCTION GET_SME_DATA (P_BRANCH_CODE NUMBER DEFAULT NULL, P_DATE DATE)
      --RETURN VARCHAR2 ;
      RETURN TY_SME_PKG_DATA
      PIPELINED;
END PKG_SME_REPORT_DATA;
/

CREATE OR REPLACE PACKAGE BODY PKG_SME_REPORT_DATA
IS
   TABLE_SME             PKG_SME_REPORT_DATA.SME_PKG_DATA;
   W_SQL                 CLOB;
   W_SQL1                 CLOB;
   W_ERROR_MSG           VARCHAR2 (1000);
   V_BRN_TYPE               VARCHAR2 (10);



   TYPE RECORD_SME_PKG_DATA IS RECORD
   (
      TMP_SME_PROD_GRP_NAME   VARCHAR2 (100),
      TMP_SME_GRP               CHAR (1),
      TMP_SME_GRP_NAME        VARCHAR2 (100),
      TMP_SME_TYPE            VARCHAR2 (100),
      TMP_DR                  NUMBER (18,6),
      TMP_NO_OF_ACCOUNT       NUMBER (6),
      TMP_ORD_BY              NUMBER (6),
      TMP_BY_TYPE             VARCHAR2 (100),
      TMP_ROWGRP              NUMBER (6)
   );

   TYPE R_TY_SME_PKG_DATA IS TABLE OF RECORD_SME_PKG_DATA
      INDEX BY PLS_INTEGER;

   TMP_TY_SME_PKG_DATA   R_TY_SME_PKG_DATA;



   FUNCTION GET_SME_DATA (P_BRANCH_CODE NUMBER DEFAULT NULL, P_DATE DATE)
      RETURN TY_SME_PKG_DATA
      PIPELINED
   IS
   BEGIN
      W_SQL := '';
       W_SQL1 := '';

  DBMS_OUTPUT.PUT_LINE (P_BRANCH_CODE);
      W_SQL := '
    WITH dt
     AS (SELECT SME_PROD_GRP_NAME,
                SME_GRP,
                SME_GRP_NAME,
                SME_TYPE,
                TYPE1,
                ABS (dr) dr,
                NO_OF_ACCOUNT,
                prod_code
           FROM abcd where    RPTDATE=:1 ';

            IF P_BRANCH_CODE = 0

         THEN
            W_SQL :=
                  W_SQL
              ;

               ELSE
                W_SQL :=
                  W_SQL
               || ' AND BRN_CODE=:2 ';


               END IF;


       W_SQL :=
                  W_SQL
               || '

           )
  SELECT SME_PROD_GRP_NAME,
         SME_GRP,
         SME_GRP_NAME,
         SME_TYPE,
         SUM (dr) dr,
         SUM (NO_OF_ACCOUNT) NO_OF_ACCOUNT,
         1 ord_by,
         ''1.Total SME Finance Details'' by_type,
         1 rowgrp
    FROM dt
   WHERE TYPE1 <> ''CMSME''
GROUP BY SME_PROD_GRP_NAME,
         SME_GRP,
         SME_GRP_NAME,
         SME_TYPE
UNION ALL
  SELECT ''SME Finance Summary'',
         '''',
         ''SME Finance'',
         SME_GRP_NAME,
         SUM (dr) dr,
         SUM (NO_OF_ACCOUNT) NO_OF_ACCOUNT,
         2 ord_by,
         ''2.Total SME Finance By Loan Type'' by_type,
         1 rowgrp
    FROM dt
   WHERE TYPE1 <> ''CMSME''
GROUP BY SME_GRP_NAME
UNION ALL
  SELECT ''SME Finance Summary'',
         '''',
         CASE
            WHEN SME_TYPE LIKE ''%Manufacturing%''
            THEN
               ''Total SME Finance For Manufacturing''
            WHEN SME_TYPE LIKE ''%Service%''
            THEN
               ''Total SME Finance For Service''
            WHEN SME_TYPE LIKE ''%Trading%''
            THEN
               ''Total SME Finance For Trading''
            ELSE
               ''SME-91,SME-99''
         END
            SME_TYPE_grp,
         SME_TYPE,
         SUM (dr) dr,
         SUM (NO_OF_ACCOUNT) NO_OF_ACCOUNT,
         3 ord_by,
         ''3.Total SME Finance By Service Type'' by_type,
         1 rowgrp
    FROM dt
   WHERE TYPE1 <> ''CMSME''
GROUP BY SME_TYPE
UNION ALL
  SELECT ''CMSME FOR COVID-19'',
         '''',
         CASE
            WHEN SME_TYPE LIKE ''%Manufacturing%''
            THEN
               ''Total SME Finance For Manufacturing''
            WHEN SME_TYPE LIKE ''%Service%''
            THEN
               ''Total SME Finance For Service''
            WHEN SME_TYPE LIKE ''%Trading%''
            THEN
               ''Total SME Finance For Trading''
            ELSE
               ''SME-91,SME-99''
         END
            SME_TYPE_grp,
         SME_TYPE,
         SUM (dr) dr,
         SUM (NO_OF_ACCOUNT) NO_OF_ACCOUNT,
         4 ord_by,
         ''4.CMSME-2220-covid'',
         1 rowgrp
    FROM dt
   WHERE prod_code IN (2220, 2223, 2224)
GROUP BY SME_TYPE';
W_SQL1 := '
    SELECT SME_PROD_GRP_NAME, SME_GRP, SME_GRP_NAME, SME_TYPE, DR, NO_OF_ACCOUNT, ORD_BY, BY_TYPE, ROWGRP
           FROM abcd2 where    RPTDATE=:1 ';

      DBMS_OUTPUT.PUT_LINE (W_SQL1);


          IF P_BRANCH_CODE = 0

         THEN
            EXECUTE IMMEDIATE W_SQL1
               BULK COLLECT INTO TMP_TY_SME_PKG_DATA
                USING P_DATE ;
         ELSE
            EXECUTE IMMEDIATE W_SQL1
               BULK COLLECT INTO TMP_TY_SME_PKG_DATA USING P_DATE ;
             --  USING P_DATE,   P_BRANCH_CODE;
         END IF;






      IF (TMP_TY_SME_PKG_DATA.FIRST IS NOT NULL)
      THEN
         FOR IDX IN TMP_TY_SME_PKG_DATA.FIRST .. TMP_TY_SME_PKG_DATA.LAST
         LOOP
            TABLE_SME.SME_PROD_GRP_NAME :=
               TMP_TY_SME_PKG_DATA (IDX).TMP_SME_PROD_GRP_NAME;
            TABLE_SME.SME_GRP := TMP_TY_SME_PKG_DATA (IDX).TMP_SME_GRP;
            TABLE_SME.SME_GRP_NAME := TMP_TY_SME_PKG_DATA (IDX).TMP_SME_GRP_NAME;

            TABLE_SME.SME_TYPE := TMP_TY_SME_PKG_DATA (IDX).TMP_SME_TYPE;
            TABLE_SME.DR := TMP_TY_SME_PKG_DATA (IDX).TMP_DR;
            TABLE_SME.NO_OF_ACCOUNT :=
               TMP_TY_SME_PKG_DATA (IDX).TMP_NO_OF_ACCOUNT;
            TABLE_SME.ORD_BY := TMP_TY_SME_PKG_DATA (IDX).TMP_ORD_BY;
            TABLE_SME.BY_TYPE := TMP_TY_SME_PKG_DATA (IDX).TMP_BY_TYPE;
            TABLE_SME.ROWGRP := TMP_TY_SME_PKG_DATA (IDX).TMP_ROWGRP;

            PIPE ROW (TABLE_SME);
         END LOOP;
      END IF;

      TMP_TY_SME_PKG_DATA.DELETE;
   --TY_AC_VALUE.DELETE;

   EXCEPTION
      WHEN OTHERS
      THEN
         NULL;
   END;
END PKG_SME_REPORT_DATA;
/
