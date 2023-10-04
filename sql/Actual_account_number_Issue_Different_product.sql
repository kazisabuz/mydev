---- Different product----

SELECT * FROM 
(select I.IACLINK_INTERNAL_ACNUM,
       i.IACLINK_ACTUAL_ACNUM,
       I.IACLINK_PROD_CODE
  from iaclink i
 where i.IACLINK_ENTITY_NUM = 1
   and (IACLINK_ACTUAL_ACNUM) in
       (SELECT IACLINK_ACTUAL_ACNUM
          FROM IACLINK
         WHERE IACLINK_ENTITY_NUM = 1
         GROUP BY IACLINK_ACTUAL_ACNUM 
        HAVING COUNT(*) > 1)
 order by i.IACLINK_ACTUAL_ACNUM
) A,
(select I.IACLINK_INTERNAL_ACNUM,
       i.IACLINK_ACTUAL_ACNUM,
       I.IACLINK_PROD_CODE
  from iaclink i
 where i.IACLINK_ENTITY_NUM = 1
   and (IACLINK_ACTUAL_ACNUM) in
       (SELECT IACLINK_ACTUAL_ACNUM
          FROM IACLINK
         WHERE IACLINK_ENTITY_NUM = 1
         GROUP BY IACLINK_ACTUAL_ACNUM 
        HAVING COUNT(*) > 1)
 order by i.IACLINK_ACTUAL_ACNUM
) B
WHERE A.IACLINK_ACTUAL_ACNUM = B.IACLINK_ACTUAL_ACNUM
AND A.IACLINK_PROD_CODE <> B.IACLINK_PROD_CODE ;







 SELECT I.IACLINK_INTERNAL_ACNUM,
				   I.IACLINK_BRN_CODE ,
                   I.IACLINK_ACTUAL_ACNUM,
                   ROW_NUMBER ()
                   OVER (PARTITION BY I.IACLINK_ACTUAL_ACNUM
                         ORDER BY I.IACLINK_ACTUAL_ACNUM)
                      SL,
                   I.IACLINK_PROD_CODE,
                   A.ACNTBAL_BC_CUR_DB_SUM,
                   A.ACNTBAL_BC_CUR_CR_SUM,
                   A.ACNTBAL_BC_BAL
              FROM IACLINK I,
                   ACNTBAL A,
                   (  SELECT IACLINK_ACTUAL_ACNUM, IACLINK_PROD_CODE
                        FROM IACLINK
                       WHERE IACLINK_ENTITY_NUM = 1
                    GROUP BY IACLINK_ACTUAL_ACNUM, IACLINK_PROD_CODE
                      HAVING COUNT (*) > 1) TEM
             WHERE     I.IACLINK_ENTITY_NUM = 1
                   AND I.IACLINK_ACTUAL_ACNUM = TEM.IACLINK_ACTUAL_ACNUM
                   AND TEM.IACLINK_PROD_CODE = I.IACLINK_PROD_CODE
                   AND A.ACNTBAL_ENTITY_NUM = 1
                   AND A.ACNTBAL_INTERNAL_ACNUM = I.IACLINK_INTERNAL_ACNUM
                   AND I.IACLINK_ACTUAL_ACNUM NOT IN ---------------------------------- same actual account number but in different product
                          (SELECT A.IACLINK_ACTUAL_ACNUM
                             FROM (  SELECT I.IACLINK_INTERNAL_ACNUM,
                                            i.IACLINK_ACTUAL_ACNUM,
                                            I.IACLINK_PROD_CODE
                                       FROM iaclink i
                                      WHERE     i.IACLINK_ENTITY_NUM = 1
                                            AND (IACLINK_ACTUAL_ACNUM) IN
                                                   (  SELECT IACLINK_ACTUAL_ACNUM
                                                        FROM IACLINK
                                                       WHERE IACLINK_ENTITY_NUM = 1
                                                    GROUP BY IACLINK_ACTUAL_ACNUM --, IACLINK_PROD_CODE
                                                      HAVING COUNT (*) > 1)
                                   ORDER BY i.IACLINK_ACTUAL_ACNUM) A,
                                  (  SELECT I.IACLINK_INTERNAL_ACNUM,
                                            i.IACLINK_ACTUAL_ACNUM,
                                            I.IACLINK_PROD_CODE
                                       FROM iaclink i
                                      WHERE     i.IACLINK_ENTITY_NUM = 1
                                            AND (IACLINK_ACTUAL_ACNUM) IN
                                                   (  SELECT IACLINK_ACTUAL_ACNUM
                                                        FROM IACLINK
                                                       WHERE IACLINK_ENTITY_NUM = 1
                                                    GROUP BY IACLINK_ACTUAL_ACNUM --, IACLINK_PROD_CODE
                                                      HAVING COUNT (*) > 1)
                                   ORDER BY i.IACLINK_ACTUAL_ACNUM) B
                            WHERE     A.IACLINK_ACTUAL_ACNUM =
                                         B.IACLINK_ACTUAL_ACNUM
                                  AND A.IACLINK_PROD_CODE <>
                                         B.IACLINK_PROD_CODE)
          ORDER BY I.IACLINK_ACTUAL_ACNUM