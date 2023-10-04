 SELECT *
  FROM CLCHGWAIVEDTL
 WHERE     CLCHGWAIVDT_ENTITY_NUM = 1
      -- AND CLCHGWAIVDT_INTERNAL_ACNUM = 131333
       AND CLCHGWAIVDT_CLIENT_NUM = 8020820;
       
CHGCD
--program ID
MCLCHGWAIVER

---Update following table with proper charge code 
edit CLCHGWAIVEDTL
CLCHGWAIVEDTLHIST
CLCHGWAIVER
CLCHGWAIVERHIST

/* Formatted on 12/27/2017 8:04:42 PM (QP5 v5.227.12220.39754) */
SELECT *
  FROM CHGCD
 WHERE CHGCD_CHARGE_CODE IN ('CDM', 'CDC', 'SBM', 'SBC', 'ED');


---------------------------------------------------------

/* Formatted on 12/13/2018 1:47:34 PM (QP5 v5.227.12220.39754) */
BEGIN
   FOR idx IN (SELECT IACLINK_INTERNAL_ACNUM ACC_NO,'09-JAN-2023' eff_date
               FROM   iaclink,acc5
              WHERE    IACLINK_ACTUAL_ACNUM =ACC_NO AND IACLINK_ENTITY_NUM = 1)
   LOOP
      INSERT INTO SBLPROD.CLCHGWAIVER (CLCHGWAIV_ENTITY_NUM,
                                       CLCHGWAIV_CLIENT_NUM,
                                       CLCHGWAIV_INTERNAL_ACNUM,
                                       CLCHGWAIV_LATEST_EFF_DATE,
                                       CLCHGWAIV_APPROVAL_BY,
                                       CLCHGWAIV_WAIVE_REQD)
           VALUES (1,
                   0,
                   idx.ACC_NO,
                   idx.eff_date,
                   '01',
                   '1');



      INSERT INTO SBLPROD.CLCHGWAIVERHIST (CLCHGWAIVHIST_ENTITY_NUM,
                                           CLCHGWAIVHIST_CLIENT_NUM,
                                           CLCHGWAIVHIST_INT_ACNUM,
                                           CLCHGWAIVHIST_EFF_DATE,
                                           CLCHGWAIVHIST_APPROVAL_BY,
                                           CLCHGWAIVHIST_ENTD_BY,
                                           CLCHGWAIVHIST_ENTD_ON,
                                           CLCHGWAIVHIST_AUTH_BY,
                                           CLCHGWAIVHIST_AUTH_ON,
                                           CLCHGWAIVHIST_WAIVE_REQD)
           VALUES (1,
                   0,
                   idx.ACC_NO,
                   idx.eff_date,
                   '01',
                   'INTELECT',
                   sysdate,
                   'INTELECT',
                   sysdate,
                   '1');



      INSERT INTO SBLPROD.CLCHGWAIVEDTL (CLCHGWAIVDT_ENTITY_NUM,
                                         CLCHGWAIVDT_CLIENT_NUM,
                                         CLCHGWAIVDT_INTERNAL_ACNUM,
                                         CLCHGWAIVDT_CHARGE_CODE,
                                         CLCHGWAIVDT_LATEST_EFF_DATE,
                                         CLCHGWAIVDT_WAIVER_TYPE,
                                         CLCHGWAIVDT_DISCOUNT_PER)
           VALUES (1,
                   0,
                   idx.ACC_NO,
                   'ED',
                   idx.eff_date,
                   'F',
                   0);

    
      INSERT INTO SBLPROD.CLCHGWAIVEDTL (CLCHGWAIVDT_ENTITY_NUM,
                                         CLCHGWAIVDT_CLIENT_NUM,
                                         CLCHGWAIVDT_INTERNAL_ACNUM,
                                         CLCHGWAIVDT_CHARGE_CODE,
                                         CLCHGWAIVDT_LATEST_EFF_DATE,
                                         CLCHGWAIVDT_WAIVER_TYPE,
                                         CLCHGWAIVDT_DISCOUNT_PER)
           VALUES (1,
                   0,
                   idx.ACC_NO,
                   'SBM',
                   idx.eff_date,
                   'F',
                   0);

       


      INSERT INTO SBLPROD.CLCHGWAIVEDTLHIST (CLCHGWAIVDTHIST_ENTITY_NUM,
                                             CLCHGWAIVDTHIST_CLIENT_NUM,
                                             CLCHGWAIVDTHIST_INT_ACNUM,
                                             CLCHGWAIVDTHIST_EFF_DATE,
                                             CLCHGWAIVDTHIST_CHARGE_CODE,
                                             CLCHGWAIVDTHIST_WAIVER_TYPE,
                                             CLCHGWAIVDTHIST_DISCOUNT_PER)
           VALUES (1,
                   0,
                   idx.ACC_NO,
                  idx.eff_date,
                   'ED',
                   'F',
                   0);
   
   INSERT INTO SBLPROD.CLCHGWAIVEDTLHIST (CLCHGWAIVDTHIST_ENTITY_NUM,
                                          CLCHGWAIVDTHIST_CLIENT_NUM,
                                          CLCHGWAIVDTHIST_INT_ACNUM,
                                          CLCHGWAIVDTHIST_EFF_DATE,
                                          CLCHGWAIVDTHIST_CHARGE_CODE,
                                          CLCHGWAIVDTHIST_WAIVER_TYPE,
                                          CLCHGWAIVDTHIST_DISCOUNT_PER)
        VALUES (1,
                0,
                idx.ACC_NO,
                idx.eff_date,
                'SBM',
                'F',
                0);
   
   END LOOP;
END;