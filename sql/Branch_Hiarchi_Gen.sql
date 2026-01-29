/*In a banking system, there is a bank which is the head office. Under that branch, there are some GM office and under that GM office, there are some principle office or regional office. And in the last stage, we see the regular branch. In the MBRN table, there is a relation from top to bottom. From this SQL, we can pass a branch code and it will return the branch list which lies bottom of the branch. The LISTAGG function will return the result in on record seperated by ",".*/

SELECT BRANCH_LIST, (REGEXP_COUNT (BRANCH_LIST, ',') + 1) AS cnt
  FROM (SELECT LISTAGG (BRANCH_CODE, ',') WITHIN GROUP (ORDER BY BRANCH_CODE)
                  AS BRANCH_LIST
          FROM (SELECT BRANCH_CODE
                  FROM (SELECT BRANCH_CODE
                          FROM MIG_DETAIL
                         WHERE     MIG_END_DATE <= :1
                               AND BRANCH_CODE IN (    SELECT MBRN_CODE
                                                         FROM MBRN
                                                   START WITH MBRN_CODE = :2
                                                   CONNECT BY PRIOR MBRN_CODE =
                                                                 MBRN_PARENT_ADMIN_CODE))));