/* Formatted on 12/30/2019 6:37:10 PM (QP5 v5.227.12220.39754) */  
BEGIN 
   FOR X
      IN (SELECT distinct IACLINK_INTERNAL_ACNUM ACC_NO
            FROM iaclink, acc5
           WHERE     IACLINK_ACTUAL_ACNUM = acc_no 
           and CONT_NUM in (3,4)
                 AND IACLINK_ENTITY_NUM = 1
                 AND IACLINK_INTERNAL_ACNUM NOT IN
                        (SELECT CLCHGWAIV_INTERNAL_ACNUM FROM CLCHGWAIVER where CLCHGWAIV_WAIVE_REQD=1))
   LOOP
      INSERT INTO CLCHGWAIVER (CLCHGWAIV_ENTITY_NUM,
                               CLCHGWAIV_CLIENT_NUM,
                               CLCHGWAIV_INTERNAL_ACNUM,
                               CLCHGWAIV_LATEST_EFF_DATE,
                               CLCHGWAIV_APPROVAL_BY,
                               CLCHGWAIV_WAIVE_REQD,
                               CLCHGWAIV_NOTES1, 
                               CLCHGWAIV_NOTES2)
           VALUES (1,
                   0,
                   X.ACC_NO,
                   sysdate ,
                   '01',
                   '1',
                   'Special RSDL and Special',
                   'One Time exit');



      INSERT INTO SBLPROD.CLCHGWAIVERHIST (CLCHGWAIVHIST_ENTITY_NUM,
                                           CLCHGWAIVHIST_CLIENT_NUM,
                                           CLCHGWAIVHIST_INT_ACNUM,
                                           CLCHGWAIVHIST_EFF_DATE,
                                           CLCHGWAIVHIST_APPROVAL_BY,
                                           CLCHGWAIVHIST_ENTD_BY,
                                           CLCHGWAIVHIST_ENTD_ON,
                                           CLCHGWAIVHIST_AUTH_BY,
                                           CLCHGWAIVHIST_AUTH_ON,
                                           CLCHGWAIVHIST_WAIVE_REQD,
                                           CLCHGWAIVHIST_NOTES1, 
                                           CLCHGWAIVHIST_NOTES2)
           VALUES (1,
                   0,
                   X.ACC_NO,
                   sysdate,
                   '01',
                   'INTELECT',
                   sysdate,
                   'INTELECT',
                  sysdate,
                   '1',
                   'Special RSDL and Special',
                   'One Time exit');



      INSERT INTO  CLCHGWAIVEDTL (CLCHGWAIVDT_ENTITY_NUM,
                                         CLCHGWAIVDT_CLIENT_NUM,
                                         CLCHGWAIVDT_INTERNAL_ACNUM,
                                         CLCHGWAIVDT_CHARGE_CODE,
                                         CLCHGWAIVDT_LATEST_EFF_DATE,
                                         CLCHGWAIVDT_WAIVER_TYPE,
                                         CLCHGWAIVDT_DISCOUNT_PER)
           VALUES (1,
                   0,
                   X.ACC_NO,
                   'ED',
                   sysdate,
                   'F',
                   0);

      /*
      INSERT INTO SBLPROD.CLCHGWAIVEDTL (CLCHGWAIVDT_ENTITY_NUM,
                                         CLCHGWAIVDT_CLIENT_NUM,
                                         CLCHGWAIVDT_INTERNAL_ACNUM,
                                         CLCHGWAIVDT_CHARGE_CODE,
                                         CLCHGWAIVDT_LATEST_EFF_DATE,
                                         CLCHGWAIVDT_WAIVER_TYPE,
                                         CLCHGWAIVDT_DISCOUNT_PER)
           VALUES (1,
                   0,
                   X.ACC_NO,
                   'SBM',
                   TO_DATE ('01/01/2017 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
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
                   X.ACC_NO,
                   'SBC',
                   TO_DATE ('01/01/2017 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
                   'F',
                   0);
      */


      INSERT INTO SBLPROD.CLCHGWAIVEDTLHIST (CLCHGWAIVDTHIST_ENTITY_NUM,
                                             CLCHGWAIVDTHIST_CLIENT_NUM,
                                             CLCHGWAIVDTHIST_INT_ACNUM,
                                             CLCHGWAIVDTHIST_EFF_DATE,
                                             CLCHGWAIVDTHIST_CHARGE_CODE,
                                             CLCHGWAIVDTHIST_WAIVER_TYPE,
                                             CLCHGWAIVDTHIST_DISCOUNT_PER)
           VALUES (1,
                   0,
                   X.ACC_NO,
                   sysdate,
                   'ED',
                   'F',
                   0);
   /*
   INSERT INTO SBLPROD.CLCHGWAIVEDTLHIST (CLCHGWAIVDTHIST_ENTITY_NUM,
                                          CLCHGWAIVDTHIST_CLIENT_NUM,
                                          CLCHGWAIVDTHIST_INT_ACNUM,
                                          CLCHGWAIVDTHIST_EFF_DATE,
                                          CLCHGWAIVDTHIST_CHARGE_CODE,
                                          CLCHGWAIVDTHIST_WAIVER_TYPE,
                                          CLCHGWAIVDTHIST_DISCOUNT_PER)
        VALUES (1,
                0,
                X.ACC_NO,
                TO_DATE ('01/01/2017 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
                'SBM',
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
                X.ACC_NO,
                TO_DATE ('01/01/2017 00:00:00', 'MM/DD/YYYY HH24:MI:SS'),
                'SBC',
                'F',
                0);*/

   END LOOP;
END;



UPDATE ACNTS AC
   SET AC.ACNTS_MMB_INT_ACCR_UPTO = '31-DEC-2019',
       AC.ACNTS_INT_ACCR_UPTO ='31-DEC-2019'
 WHERE     AC.ACNTS_ENTITY_NUM = 1
       AND AC.ACNTS_INTERNAL_ACNUM IN
              (SELECT IACLINK_INTERNAL_ACNUM
                 FROM IACLINK IA
                WHERE     IA.IACLINK_ENTITY_NUM = 1
                      AND IA.IACLINK_ACTUAL_ACNUM IN (select acc_no from acc5 where CONT_NUM=3
));

UPDATE LOANACNTS LON
   SET LON.LNACNT_INT_ACCR_UPTO =  '31-DEC-2019',
       LON.LNACNT_INT_APPLIED_UPTO_DATE =  '31-DEC-2019'
 WHERE     LON.LNACNT_ENTITY_NUM = 1
       AND LON.LNACNT_INTERNAL_ACNUM IN
              (SELECT IA.IACLINK_INTERNAL_ACNUM
                 FROM IACLINK IA
                WHERE     IA.IACLINK_ENTITY_NUM = 1
                      AND IA.IACLINK_ACTUAL_ACNUM IN (select acc_no from acc5 where CONT_NUM=3));
