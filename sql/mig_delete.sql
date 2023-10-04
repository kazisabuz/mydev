/* Formatted on 12/13/2022 4:15:51 PM (QP5 v5.388) */
SELECT *
  FROM ACASLL
 WHERE ACASLL_CLIENT_NUM IN
           (SELECT ACNTS_CLIENT_NUM
             FROM acnts, products
            WHERE     PRODUCT_CODE = ACNTS_PROD_CODE
                  AND ACNTS_ENTITY_NUM = 1
                  AND ACNTS_BRN_CODE = 18
                  AND ACNTS_CLOSURE_DATE IS NULL
                  AND PRODUCT_FOR_LOANS = 1);


SELECT *
  FROM ACASLLDTL
 WHERE     ACASLLDTL_ENTITY_NUM = 1
       AND (ACASLLDTL_CLIENT_NUM) IN
              (SELECT ACNTS_CLIENT_NUM
             FROM acnts, products
            WHERE     PRODUCT_CODE = ACNTS_PROD_CODE
                  AND ACNTS_ENTITY_NUM = 1
                  AND ACNTS_BRN_CODE = 18
                  AND ACNTS_CLOSURE_DATE IS NULL
                  AND PRODUCT_FOR_LOANS = 1);

SELECT *
  FROM ACNTBAL
 WHERE     ACNTBAL_ENTITY_NUM = 1
       AND (ACNTBAL_INTERNAL_ACNUM) IN
               (SELECT ACNTS_INTERNAL_ACNUM
                 FROM acnts, products
                WHERE     PRODUCT_CODE = ACNTS_PROD_CODE
                      AND ACNTS_ENTITY_NUM = 1
                      AND ACNTS_BRN_CODE = 18
                      AND ACNTS_CLOSURE_DATE IS NULL
                      AND PRODUCT_FOR_LOANS = 1);


SELECT *
  FROM ACNTLINK
 WHERE     ACNTLINK_ENTITY_NUM = 1
       AND ACNTLINK_INTERNAL_ACNUM IN
               (SELECT ACNTS_INTERNAL_ACNUM
                 FROM acnts, products
                WHERE     PRODUCT_CODE = ACNTS_PROD_CODE
                      AND ACNTS_ENTITY_NUM = 1
                      AND ACNTS_BRN_CODE = 18
                      AND ACNTS_CLOSURE_DATE IS NULL
                      AND PRODUCT_FOR_LOANS = 1);



SELECT *
  FROM ACNTMAIL
 WHERE     ACNTMAIL_ENTITY_NUM = 1
       AND ACNTMAIL_INTERNAL_ACNUM IN
               (SELECT ACNTS_INTERNAL_ACNUM
                 FROM acnts, products
                WHERE     PRODUCT_CODE = ACNTS_PROD_CODE
                      AND ACNTS_ENTITY_NUM = 1
                      AND ACNTS_BRN_CODE = 18
                      AND ACNTS_CLOSURE_DATE IS NULL
                      AND PRODUCT_FOR_LOANS = 1);

SELECT *
  FROM ACNTOTN
 WHERE     ACNTOTN_ENTITY_NUM = 1
       AND ACNTOTN_INTERNAL_ACNUM IN
               (SELECT ACNTS_INTERNAL_ACNUM
                 FROM acnts, products
                WHERE     PRODUCT_CODE = ACNTS_PROD_CODE
                      AND ACNTS_ENTITY_NUM = 1
                      AND ACNTS_BRN_CODE = 18
                      AND ACNTS_CLOSURE_DATE IS NULL
                      AND PRODUCT_FOR_LOANS = 1);

SELECT *
  FROM ACNTOTNNEW
 WHERE     ACNTOTNNEW_ENTITY_NUM = 1
       AND ACNTOTN_INTERNAL_ACNUM IN
               (SELECT ACNTS_INTERNAL_ACNUM
                 FROM acnts, products
                WHERE     PRODUCT_CODE = ACNTS_PROD_CODE
                      AND ACNTS_ENTITY_NUM = 1
                      AND ACNTS_BRN_CODE = 18
                      AND ACNTS_CLOSURE_DATE IS NULL
                      AND PRODUCT_FOR_LOANS = 1);

SELECT *
  FROM ACNTS
 WHERE     ACNTS_ENTITY_NUM = 1
       AND ACNTS_INTERNAL_ACNUM IN
               (SELECT ACNTS_INTERNAL_ACNUM
                 FROM acnts, products
                WHERE     PRODUCT_CODE = ACNTS_PROD_CODE
                      AND ACNTS_ENTITY_NUM = 1
                      AND ACNTS_BRN_CODE = 18
                      AND ACNTS_CLOSURE_DATE IS NULL
                      AND PRODUCT_FOR_LOANS = 1);

SELECT *
  FROM ACSEQGEN
 WHERE (ACSEQGEN_ENTITY_NUM,
        ACSEQGEN_BRN_CODE,
        ACSEQGEN_CIF_NUMBER,
        ACSEQGEN_PROD_CODE,
        ACSEQGEN_SEQ_NUMBER) IN
           (SELECT ACSEQGEN_ENTITY_NUM,
                   ACSEQGEN_BRN_CODE,
                   ACSEQGEN_CIF_NUMBER,
                   ACSEQGEN_PROD_CODE,
                   ACSEQGEN_SEQ_NUMBER
              FROM ACSEQGEN@DR3);

SELECT *
  FROM ADDRDTLS
 WHERE (ADDRDTLS_INV_NUM, ADDRDTLS_ADDR_SL) IN
           (SELECT ADDRDTLS_INV_NUM, ADDRDTLS_ADDR_SL FROM ADDRDTLS@DR3);

SELECT *
  FROM ASSETCLS
 WHERE     ASSETCLS_ENTITY_NUM = 1
       AND ASSETCLS_INTERNAL_ACNUM IN
               (SELECT ACNTS_INTERNAL_ACNUM
                 FROM acnts, products
                WHERE     PRODUCT_CODE = ACNTS_PROD_CODE
                      AND ACNTS_ENTITY_NUM = 1
                      AND ACNTS_BRN_CODE = 18
                      AND ACNTS_CLOSURE_DATE IS NULL
                      AND PRODUCT_FOR_LOANS = 1);

SELECT *
  FROM ASSETCLSHIST
 WHERE     ASSETCLSH_ENTITY_NUM = 1
       AND ASSETCLSH_INTERNAL_ACNUM IN
               (SELECT ACNTS_INTERNAL_ACNUM
                 FROM acnts, products
                WHERE     PRODUCT_CODE = ACNTS_PROD_CODE
                      AND ACNTS_ENTITY_NUM = 1
                      AND ACNTS_BRN_CODE = 18
                      AND ACNTS_CLOSURE_DATE IS NULL
                      AND PRODUCT_FOR_LOANS = 1);

SELECT *
  FROM CLIENTNUM
 WHERE CLIENTNUM_CODE IN
           (SELECT ACNTS_CLIENT_NUM
             FROM acnts, products
            WHERE     PRODUCT_CODE = ACNTS_PROD_CODE
                  AND ACNTS_ENTITY_NUM = 1
                  AND ACNTS_BRN_CODE = 18
                  AND ACNTS_CLOSURE_DATE IS NULL
                  AND PRODUCT_FOR_LOANS = 1);

SELECT *
  FROM CLIENTS
 WHERE CLIENTS_CODE IN
           (SELECT ACNTS_CLIENT_NUM
             FROM acnts, products
            WHERE     PRODUCT_CODE = ACNTS_PROD_CODE
                  AND ACNTS_ENTITY_NUM = 1
                  AND ACNTS_BRN_CODE = 18
                  AND ACNTS_CLOSURE_DATE IS NULL
                  AND PRODUCT_FOR_LOANS = 1);

SELECT *
  FROM CORPCLIENTS
 WHERE CORPCL_CLIENT_CODE IN
           (SELECT ACNTS_CLIENT_NUM
             FROM acnts, products
            WHERE     PRODUCT_CODE = ACNTS_PROD_CODE
                  AND ACNTS_ENTITY_NUM = 1
                  AND ACNTS_BRN_CODE = 18
                  AND ACNTS_CLOSURE_DATE IS NULL
                  AND PRODUCT_FOR_LOANS = 1);

SELECT *
  FROM LIMFACCURR
 WHERE (LFCURR_CLIENT_NUM) IN
           (SELECT ACNTS_CLIENT_NUM
             FROM acnts, products
            WHERE     PRODUCT_CODE = ACNTS_PROD_CODE
                  AND ACNTS_ENTITY_NUM = 1
                  AND ACNTS_BRN_CODE = 18
                  AND ACNTS_CLOSURE_DATE IS NULL
                  AND PRODUCT_FOR_LOANS = 1);

SELECT *
  FROM LIMITLINE
 WHERE     LMTLINE_ENTITY_NUM = 1
       AND (LMTLINE_CLIENT_CODE) IN
               (SELECT ACNTS_CLIENT_NUM
                 FROM acnts, products
                WHERE     PRODUCT_CODE = ACNTS_PROD_CODE
                      AND ACNTS_ENTITY_NUM = 1
                      AND ACNTS_BRN_CODE = 18
                      AND ACNTS_CLOSURE_DATE IS NULL
                      AND PRODUCT_FOR_LOANS = 1);

SELECT *
  FROM LIMITLINEAUX
 WHERE     LMTLINEAUX_ENTITY_NUM = 1
       AND (LMTLINEAUX_CLIENT_CODE) IN
               (SELECT ACNTS_CLIENT_NUM
                 FROM acnts, products
                WHERE     PRODUCT_CODE = ACNTS_PROD_CODE
                      AND ACNTS_ENTITY_NUM = 1
                      AND ACNTS_BRN_CODE = 18
                      AND ACNTS_CLOSURE_DATE IS NULL
                      AND PRODUCT_FOR_LOANS = 1);

SELECT *
  FROM LIMITLINEHIST
 WHERE     LIMLNEHIST_ENTITY_NUM = 1
       AND (LIMLNEHIST_CLIENT_CODE) IN
               (SELECT ACNTS_CLIENT_NUM
                 FROM acnts, products
                WHERE     PRODUCT_CODE = ACNTS_PROD_CODE
                      AND ACNTS_ENTITY_NUM = 1
                      AND ACNTS_BRN_CODE = 18
                      AND ACNTS_CLOSURE_DATE IS NULL
                      AND PRODUCT_FOR_LOANS = 1);


SELECT *
  FROM LIMITSERIAL
 WHERE     LMTSL_ENTITY_NUM = 1
       AND LMTSL_CLIENT_CODE IN
               (SELECT ACNTS_CLIENT_NUM
                 FROM acnts, products
                WHERE     PRODUCT_CODE = ACNTS_PROD_CODE
                      AND ACNTS_ENTITY_NUM = 1
                      AND ACNTS_BRN_CODE = 18
                      AND ACNTS_CLOSURE_DATE IS NULL
                      AND PRODUCT_FOR_LOANS = 1);

SELECT *
  FROM LLACNTOS
 WHERE     LLACNTOS_ENTITY_NUM = 1
       AND (LLACNTOS_CLIENT_CODE
              ) IN
               (SELECT LLACNTOS_CLIENT_ACNUM
                 FROM acnts, products
                WHERE     PRODUCT_CODE = ACNTS_PROD_CODE
                      AND ACNTS_ENTITY_NUM = 1
                      AND ACNTS_BRN_CODE = 18
                      AND ACNTS_CLOSURE_DATE IS NULL
                      AND PRODUCT_FOR_LOANS = 1);

SELECT *
  FROM LNACAODHIST
 WHERE     LNACAODH_ENTITY_NUM = 1
       AND LNACAODH_INTERNAL_ACNUM IN
               (SELECT ACNTS_INTERNAL_ACNUM
                 FROM acnts, products
                WHERE     PRODUCT_CODE = ACNTS_PROD_CODE
                      AND ACNTS_ENTITY_NUM = 1
                      AND ACNTS_BRN_CODE = 18
                      AND ACNTS_CLOSURE_DATE IS NULL
                      AND PRODUCT_FOR_LOANS = 1);

SELECT *
  FROM LNACDISB
 WHERE     LNACDISB_ENTITY_NUM = 1
       AND LNACDISB_INTERNAL_ACNUM IN
               (SELECT ACNTS_INTERNAL_ACNUM
                 FROM acnts, products
                WHERE     PRODUCT_CODE = ACNTS_PROD_CODE
                      AND ACNTS_ENTITY_NUM = 1
                      AND ACNTS_BRN_CODE = 18
                      AND ACNTS_CLOSURE_DATE IS NULL
                      AND PRODUCT_FOR_LOANS = 1);

SELECT *
  FROM LNACDSDTL
 WHERE     LNACDSDTL_ENTITY_NUM = 1
       AND LNACDSDTL_INTERNAL_ACNUM IN
               (SELECT ACNTS_INTERNAL_ACNUM
                 FROM acnts, products
                WHERE     PRODUCT_CODE = ACNTS_PROD_CODE
                      AND ACNTS_ENTITY_NUM = 1
                      AND ACNTS_BRN_CODE = 18
                      AND ACNTS_CLOSURE_DATE IS NULL
                      AND PRODUCT_FOR_LOANS = 1);

SELECT *
  FROM LNACDSDTLHIST
 WHERE     LNACDSDTLH_ENTITY_NUM = 1
       AND LNACDSDTLH_INTERNAL_ACNUM IN
               (SELECT ACNTS_INTERNAL_ACNUM
                 FROM acnts, products
                WHERE     PRODUCT_CODE = ACNTS_PROD_CODE
                      AND ACNTS_ENTITY_NUM = 1
                      AND ACNTS_BRN_CODE = 18
                      AND ACNTS_CLOSURE_DATE IS NULL
                      AND PRODUCT_FOR_LOANS = 1);

SELECT *
  FROM LNACIR
 WHERE     LNACIR_ENTITY_NUM = 1
       AND LNACIR_INTERNAL_ACNUM IN
               (SELECT ACNTS_INTERNAL_ACNUM
                 FROM acnts, products
                WHERE     PRODUCT_CODE = ACNTS_PROD_CODE
                      AND ACNTS_ENTITY_NUM = 1
                      AND ACNTS_BRN_CODE = 18
                      AND ACNTS_CLOSURE_DATE IS NULL
                      AND PRODUCT_FOR_LOANS = 1);

SELECT *
  FROM LNACIRHIST
 WHERE     LNACIRH_ENTITY_NUM = 1
       AND LNACIRH_INTERNAL_ACNUM IN
               (SELECT ACNTS_INTERNAL_ACNUM
                 FROM acnts, products
                WHERE     PRODUCT_CODE = ACNTS_PROD_CODE
                      AND ACNTS_ENTITY_NUM = 1
                      AND ACNTS_BRN_CODE = 18
                      AND ACNTS_CLOSURE_DATE IS NULL
                      AND PRODUCT_FOR_LOANS = 1);

SELECT *
  FROM LNACIRS
 WHERE     LNACIRS_ENTITY_NUM = 1
       AND LNACIRS_INTERNAL_ACNUM IN
               (SELECT ACNTS_INTERNAL_ACNUM
                 FROM acnts, products
                WHERE     PRODUCT_CODE = ACNTS_PROD_CODE
                      AND ACNTS_ENTITY_NUM = 1
                      AND ACNTS_BRN_CODE = 18
                      AND ACNTS_CLOSURE_DATE IS NULL
                      AND PRODUCT_FOR_LOANS = 1);

SELECT *
  FROM LNACIRSHIST
 WHERE     LNACIRSH_ENTITY_NUM = 1
       AND LNACIRSH_INTERNAL_ACNUM IN
               (SELECT ACNTS_INTERNAL_ACNUM
                 FROM acnts, products
                WHERE     PRODUCT_CODE = ACNTS_PROD_CODE
                      AND ACNTS_ENTITY_NUM = 1
                      AND ACNTS_BRN_CODE = 18
                      AND ACNTS_CLOSURE_DATE IS NULL
                      AND PRODUCT_FOR_LOANS = 1);

SELECT *
  FROM LNACMIS
 WHERE     LNACMIS_ENTITY_NUM = 1
       AND LNACMIS_INTERNAL_ACNUM IN
               (SELECT ACNTS_INTERNAL_ACNUM
                 FROM acnts, products
                WHERE     PRODUCT_CODE = ACNTS_PROD_CODE
                      AND ACNTS_ENTITY_NUM = 1
                      AND ACNTS_BRN_CODE = 18
                      AND ACNTS_CLOSURE_DATE IS NULL
                      AND PRODUCT_FOR_LOANS = 1);

SELECT *
  FROM LNACMISHIST
 WHERE     LNACMISH_ENTITY_NUM = 1
       AND LNACMISH_INTERNAL_ACNUM IN
               (SELECT ACNTS_INTERNAL_ACNUM
                 FROM acnts, products
                WHERE     PRODUCT_CODE = ACNTS_PROD_CODE
                      AND ACNTS_ENTITY_NUM = 1
                      AND ACNTS_BRN_CODE = 18
                      AND ACNTS_CLOSURE_DATE IS NULL
                      AND PRODUCT_FOR_LOANS = 1);

SELECT *
  FROM LOANACHIST
 WHERE     LNACH_ENTITY_NUM = 1
       AND LNACH_INTERNAL_ACNUM IN
               (SELECT ACNTS_INTERNAL_ACNUM
                 FROM acnts, products
                WHERE     PRODUCT_CODE = ACNTS_PROD_CODE
                      AND ACNTS_ENTITY_NUM = 1
                      AND ACNTS_BRN_CODE = 18
                      AND ACNTS_CLOSURE_DATE IS NULL
                      AND PRODUCT_FOR_LOANS = 1);

SELECT *
  FROM LOANACNTS
 WHERE     LNACNT_ENTITY_NUM = 1
       AND LNACNT_INTERNAL_ACNUM IN
               (SELECT ACNTS_INTERNAL_ACNUM
                 FROM acnts, products
                WHERE     PRODUCT_CODE = ACNTS_PROD_CODE
                      AND ACNTS_ENTITY_NUM = 1
                      AND ACNTS_BRN_CODE = 18
                      AND ACNTS_CLOSURE_DATE IS NULL
                      AND PRODUCT_FOR_LOANS = 1);

SELECT *
  FROM TEMP_CLIENT
 WHERE (  NEW_CLCODE) IN
          (SELECT ACNTS_CLIENT_NUM
                 FROM acnts, products
                WHERE     PRODUCT_CODE = ACNTS_PROD_CODE
                      AND ACNTS_ENTITY_NUM = 1
                      AND ACNTS_BRN_CODE = 18
                      AND ACNTS_CLOSURE_DATE IS NULL
                      AND PRODUCT_FOR_LOANS = 1);