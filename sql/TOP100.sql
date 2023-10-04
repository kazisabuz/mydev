/* Formatted on 8/28/2019 5:41:48 PM (QP5 v5.227.12220.39754) */
BEGIN
   FOR IDX IN (  SELECT *
                   FROM MBRN
               ORDER BY 1)
   LOOP
      INSERT INTO TOP100CLIENTSB
         SELECT ACNTS_INTERNAL_ACNUM, BALANCE
           FROM (  SELECT *
                     FROM (SELECT ACNTS_BRN_CODE,
                                  ACNTS_INTERNAL_ACNUM,
                                  FN_GET_ASON_ACBAL (ACNTS_ENTITY_NUM,
                                                     ACNTS_INTERNAL_ACNUM,
                                                     ACNTS_CURR_CODE,
                                                     '30-jun-2021',
                                                     '27-jul-2021')
                                     BALANCE
                             FROM PRODUCTS, ACNTS
                            WHERE     ACNTS_ENTITY_NUM = 1
                                  AND ACNTS_OPENING_DATE <= '30-jun-2021'
                                       AND (   ACNTS_CLOSURE_DATE IS NULL
                                            OR ACNTS_CLOSURE_DATE > '30-jun-2021')
                                  AND ACNTS_PROD_CODE = PRODUCT_CODE
                                  AND PRODUCT_FOR_LOANS = 1)
                    WHERE ACNTS_BRN_CODE = IDX.MBRN_CODE
                 ORDER BY ABS (BALANCE) DESC)
          WHERE ROWNUM <= 100;

      COMMIT;
   END LOOP;
END;

/* Formatted on 8/28/2019 5:41:48 PM (QP5 v5.227.12220.39754) */
BEGIN
   FOR IDX IN (  SELECT *
                   FROM MBRN
               ORDER BY 1)
   LOOP
      INSERT INTO TOP100CLIENTS
         SELECT ACNTS_INTERNAL_ACNUM, BALANCE
           FROM (  SELECT *
                     FROM (SELECT ACNTS_BRN_CODE,
                                  ACNTS_INTERNAL_ACNUM,
                                  FN_GET_ASON_ACBAL (ACNTS_ENTITY_NUM,
                                                     ACNTS_INTERNAL_ACNUM,
                                                     ACNTS_CURR_CODE, ----balance date
                                                     '30-jun-2021',
                                                     '27-jul-2021')  ----current date
                                     BALANCE
                             FROM PRODUCTS, ACNTS
                            WHERE     ACNTS_ENTITY_NUM = 1
                                  AND ACNTS_OPENING_DATE <= '31-DEC-2018'
                                       AND (   ACNTS_CLOSURE_DATE IS NULL
                                            OR ACNTS_CLOSURE_DATE > '31-DEC-2018')
                                  AND ACNTS_PROD_CODE = PRODUCT_CODE
                                  AND PRODUCT_FOR_DEPOSITS = 1)
                    WHERE ACNTS_BRN_CODE = IDX.MBRN_CODE
                 ORDER BY ABS (BALANCE) DESC)
          WHERE ROWNUM <= 100;

      COMMIT;
   END LOOP;
END;


-----------------query----------------
/* Formatted on 8/29/2019 1:02:35 PM (QP5 v5.227.12220.39754) */
SELECT *
  FROM (SELECT ACNTS_BRN_CODE,
               facno (1, acnts.ACNTS_INTERNAL_ACNUM) account_no,
               ACNTS_AC_NAME1 || ACNTS_AC_NAME2 account_name,
               BALANCE
          FROM TOP100CLIENTS, acnts
         WHERE BALANCE > 0 AND TOP100CLIENTS.ACNTS_INTERNAL_ACNUM =acnts.ACNTS_INTERNAL_ACNUM and ACNTS_ENTITY_NUM=1
          ORDER BY ABS (BALANCE) DESC)
WHERE ROWNUM <= 100;







      INSERT INTO TOP100CLIENTSB
  SELECT ACNTS_INTERNAL_ACNUM, BALANCE,1,2016
           FROM (  SELECT *
                     FROM (SELECT  /*+ PARALLEL( 4) */   ACNTS_BRN_CODE,
                                  ACNTS_INTERNAL_ACNUM,
                                  FN_GET_ASON_ACBAL (ACNTS_ENTITY_NUM,
                                                     ACNTS_INTERNAL_ACNUM,
                                                     ACNTS_CURR_CODE,
                                                     '31-DEC-2016',
                                                     '28-SEP-2021')
                                     BALANCE
                             FROM PRODUCTS, ACNTS,ASSETCLS
                            WHERE     ACNTS_ENTITY_NUM = 1
                                 AND ACNTS_OPENING_DATE <= '31-DEC-2016'
                                       AND (   ACNTS_CLOSURE_DATE IS NULL
                                            OR ACNTS_CLOSURE_DATE > '31-DEC-2016')
                                  AND ACNTS_PROD_CODE = PRODUCT_CODE
                                  AND ASSETCLS_ASSET_CODE='UC'
                                  AND ASSETCLS_INTERNAL_ACNUM=ACNTS_INTERNAL_ACNUM
                                  AND ASSETCLS_ENTITY_NUM=1
                                  AND PRODUCT_FOR_LOANS = 1)
                 ORDER BY ABS (BALANCE) DESC)
          WHERE ROWNUM <= 100
          UNION ALL
            SELECT ACNTS_INTERNAL_ACNUM, BALANCE,2,2016
           FROM (  SELECT *
                     FROM (SELECT  /*+ PARALLEL( 4) */    ACNTS_BRN_CODE,
                                  ACNTS_INTERNAL_ACNUM,
                                  FN_GET_ASON_ACBAL (ACNTS_ENTITY_NUM,
                                                     ACNTS_INTERNAL_ACNUM,
                                                     ACNTS_CURR_CODE,
                                                     '31-DEC-2016',
                                                     '28-SEP-2021')
                                     BALANCE
                             FROM PRODUCTS, ACNTS,ASSETCLS
                            WHERE     ACNTS_ENTITY_NUM = 1
                                 aND ACNTS_OPENING_DATE <= '31-DEC-2016'
                                       AND (   ACNTS_CLOSURE_DATE IS NULL
                                            OR ACNTS_CLOSURE_DATE > '31-DEC-2016')
                                  AND ACNTS_PROD_CODE = PRODUCT_CODE
                                  AND ASSETCLS_ASSET_CODE='SM'
                                  AND ASSETCLS_INTERNAL_ACNUM=ACNTS_INTERNAL_ACNUM
                                  AND ASSETCLS_ENTITY_NUM=1
                                  AND PRODUCT_FOR_LOANS = 1)
                 ORDER BY ABS (BALANCE) DESC)
          WHERE ROWNUM <= 100
               UNION ALL
            SELECT ACNTS_INTERNAL_ACNUM, BALANCE,3 ,2016     ---SMA, SS, DF & BL data
           FROM (  SELECT *
                     FROM (SELECT  /*+ PARALLEL( 4) */   ACNTS_BRN_CODE,
                                  ACNTS_INTERNAL_ACNUM,
                                  FN_GET_ASON_ACBAL (ACNTS_ENTITY_NUM,
                                                     ACNTS_INTERNAL_ACNUM,
                                                     ACNTS_CURR_CODE,
                                                     '31-DEC-2016',
                                                     '28-SEP-2021')
                                     BALANCE
                             FROM PRODUCTS, ACNTS,ASSETCLS
                            WHERE     ACNTS_ENTITY_NUM = 1
                                  AND ACNTS_OPENING_DATE <= '31-DEC-2016'
                                       AND (   ACNTS_CLOSURE_DATE IS NULL
                                            OR ACNTS_CLOSURE_DATE > '31-DEC-2016')
                                  AND ACNTS_PROD_CODE = PRODUCT_CODE
                                  AND ASSETCLS_ASSET_CODE='SS'
                                  AND ASSETCLS_INTERNAL_ACNUM=ACNTS_INTERNAL_ACNUM
                                  AND ASSETCLS_ENTITY_NUM=1
                                  AND PRODUCT_FOR_LOANS = 1)
                 ORDER BY ABS (BALANCE) DESC)
          WHERE ROWNUM <= 100
                    UNION ALL
            SELECT ACNTS_INTERNAL_ACNUM, BALANCE,3 ,2016    ---SMA, SS, DF & BL data
           FROM (  SELECT *
                     FROM (SELECT  /*+ PARALLEL( 4) */   ACNTS_BRN_CODE,
                                  ACNTS_INTERNAL_ACNUM,
                                  FN_GET_ASON_ACBAL (ACNTS_ENTITY_NUM,
                                                     ACNTS_INTERNAL_ACNUM,
                                                     ACNTS_CURR_CODE,
                                                     '31-DEC-2016',
                                                     '28-SEP-2021')
                                     BALANCE
                             FROM PRODUCTS, ACNTS,ASSETCLS
                            WHERE     ACNTS_ENTITY_NUM = 1
                                 AND ACNTS_OPENING_DATE <= '31-DEC-2016'
                                       AND (   ACNTS_CLOSURE_DATE IS NULL
                                            OR ACNTS_CLOSURE_DATE > '31-DEC-2016')
                                  AND ACNTS_PROD_CODE = PRODUCT_CODE
                                  AND ASSETCLS_ASSET_CODE='DF'
                                  AND ASSETCLS_INTERNAL_ACNUM=ACNTS_INTERNAL_ACNUM
                                  AND ASSETCLS_ENTITY_NUM=1
                                  AND PRODUCT_FOR_LOANS = 1)
                 ORDER BY ABS (BALANCE) DESC)
          WHERE ROWNUM <= 100
               UNION ALL
            SELECT ACNTS_INTERNAL_ACNUM, BALANCE,4  ,2016  ---SMA, SS, DF & BL data
           FROM (  SELECT *
                     FROM (SELECT   /*+ PARALLEL( 4) */   ACNTS_BRN_CODE,
                                  ACNTS_INTERNAL_ACNUM,
                                  FN_GET_ASON_ACBAL (ACNTS_ENTITY_NUM,
                                                     ACNTS_INTERNAL_ACNUM,
                                                     ACNTS_CURR_CODE,
                                                     '31-DEC-2016',
                                                     '28-SEP-2021')
                                     BALANCE
                             FROM PRODUCTS, ACNTS,ASSETCLS
                            WHERE     ACNTS_ENTITY_NUM = 1
                                  AND ACNTS_OPENING_DATE <= '31-DEC-2016'
                                       AND (   ACNTS_CLOSURE_DATE IS NULL
                                            OR ACNTS_CLOSURE_DATE > '31-DEC-2016')
                                  AND ACNTS_PROD_CODE = PRODUCT_CODE
                                  AND ASSETCLS_ASSET_CODE='DF'
                                  AND ASSETCLS_INTERNAL_ACNUM=ACNTS_INTERNAL_ACNUM
                                  AND ASSETCLS_ENTITY_NUM=1
                                  AND PRODUCT_FOR_LOANS = 1)
                 ORDER BY ABS (BALANCE) DESC)
          WHERE ROWNUM <= 100
               UNION ALL
            SELECT ACNTS_INTERNAL_ACNUM, BALANCE,5  ,2016   ---SMA, SS, DF & BL data
           FROM (  SELECT *
                     FROM (SELECT  /*+ PARALLEL( 4) */   ACNTS_BRN_CODE,
                                  ACNTS_INTERNAL_ACNUM,
                                  FN_GET_ASON_ACBAL (ACNTS_ENTITY_NUM,
                                                     ACNTS_INTERNAL_ACNUM,
                                                     ACNTS_CURR_CODE,
                                                     '31-DEC-2016',
                                                     '28-SEP-2021')
                                     BALANCE
                             FROM PRODUCTS, ACNTS,ASSETCLS
                            WHERE     ACNTS_ENTITY_NUM = 1
                                  AND ACNTS_OPENING_DATE <= '31-DEC-2016'
                                       AND (   ACNTS_CLOSURE_DATE IS NULL
                                            OR ACNTS_CLOSURE_DATE > '31-DEC-2016')
                                  AND ACNTS_PROD_CODE = PRODUCT_CODE
                                  AND ASSETCLS_ASSET_CODE='BL'
                                  AND ASSETCLS_INTERNAL_ACNUM=ACNTS_INTERNAL_ACNUM
                                  AND ASSETCLS_ENTITY_NUM=1
                                  AND PRODUCT_FOR_LOANS = 1)
                 ORDER BY ABS (BALANCE) DESC)
          WHERE ROWNUM <= 100;
          
          
          
          
          /* Formatted on 9/28/2021 5:42:15 PM (QP5 v5.149.1003.31008) */
SELECT GMO_BRANCH GMO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = GMO_BRANCH)
          GMO_NAME,
       PO_BRANCH PO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = PO_BRANCH)
          PO_NAME,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = TT.ACNTS_BRN_CODE)
          BRANCH_NAME,
       TT.*
  FROM (SELECT ACNTS_BRN_CODE,
               facno (1, acnts.ACNTS_INTERNAL_ACNUM) account_no,
               ACNTS_AC_NAME1 || ACNTS_AC_NAME2 account_name,
               BALANCE,
               CASE
                  WHEN year = 1 THEN 'UC'
                  WHEN year = 2 THEN 'SM'
                  WHEN year = 3 THEN 'SS'
                  WHEN year = 4 THEN 'DF'
                  WHEN year = 5 THEN 'BL'
                  ELSE ''
               END
                  ASSET_CODE
          FROM TOP100CLIENTSB, acnts
         WHERE TOP100CLIENTSB.ACNTS_INTERNAL_ACNUM =
                  acnts.ACNTS_INTERNAL_ACNUM
               AND ACNTS_ENTITY_NUM = 1) TT,
       MBRN_TREE1
 WHERE TT.ACNTS_BRN_CODE = BRANCH