/* Formatted on 06/01/2021 12:38:39 PM (QP5 v5.227.12220.39754) */
SELECT ACNTS_BRN_CODE MBRN_CODE,
       MBRN_NAME,
       ACC_NO ACCOUNT_NUMBER,
       ACNTS_AC_NAME1 || ACNTS_AC_NAME2 ACCOUNT_NAME,
       (SELECT PIDDOCS_DOCID_NUM
          FROM PIDDOCS
         WHERE     PIDDOCS_INV_NUM = ACNTS_CLIENT_NUM
               AND PIDDOCS_DOC_SL = 1
               AND PIDDOCS_PID_TYPE = 'NID')
          NID,
       CASE WHEN ACNTS_INOP_ACNT = '0' THEN 'NO' ELSE 'YES' END INOP_STATUS,
       CASE WHEN ACNTS_DORMANT_ACNT = '0' THEN 'NO' ELSE 'YES' END
          DORMANT_STATUS,
       CASE WHEN ACNTS_CLOSURE_DATE IS NULL THEN 'OPEN' ELSE 'CLOSED' END
          OPEN_CLOSED_STATUS
  FROM MBRN,
       ACC4,
       IACLINK I,
       ACNTS
 WHERE     ACC_NO = IACLINK_ACTUAL_ACNUM
       AND IACLINK_ENTITY_NUM = 1
       AND ACNTS_ENTITY_NUM = 1
       AND ACNTS_BRN_CODE = MBRN_CODE
       AND ACNTS_INTERNAL_ACNUM = IACLINK_INTERNAL_ACNUM;
       
       
--UNCLAIMED DEPOSIT AC 
SELECT *
  FROM (SELECT ACNTS_INTERNAL_ACNUM,
               ACNTS_DORMANT_ACNT,
               ACNTS_INOP_ACNT,
               FLOOR (
                    MONTHS_BETWEEN (TRUNC (SYSDATE), ACNTS_NONSYS_LAST_DATE)
                  / 12)
                  claim_year,
               FLOOR (
                  MONTHS_BETWEEN (TRUNC (SYSDATE), ACNTS_NONSYS_LAST_DATE))
                  months
          FROM ACNTS
         WHERE     ACNTS_ENTITY_NUM = 1
               AND ACNTS_DORMANT_ACNT = '1'
               AND ACNTS_INOP_ACNT = '1'
               
               AND ACNTS_NONSYS_LAST_DATE <='28-FEB-2021')
               WHERE   months>=120;



SELECT COUNT(DISTINCT ACNTS_INTERNAL_ACNUM)      
  FROM acntstatus a, acnts  a
 WHERE     ACNTSTATUS_EFF_DATE =
              (SELECT MAX (ACNTSTATUS_EFF_DATE)
                 FROM acntstatus t
                WHERE     ACNTSTATUS_ENTITY_NUM = 1
                      AND ACNTSTATUS_FLG = 'I'
                      AND ACNTSTATUS_EFF_DATE <= '28-FEB-2021'
                      AND t.ACNTSTATUS_INTERNAL_ACNUM =
                             a.ACNTSTATUS_INTERNAL_ACNUM)
       AND ACNTSTATUS_FLG = 'I'
       AND ACNTSTATUS_INTERNAL_ACNUM = ACNTS_INTERNAL_ACNUM
       AND ACNTS_ENTITY_NUM = 1;
       
      '31-dec-2020' 
       inop ---8116905
    dOR   5890666
    UNCLAIME 1,485,983
    
    
    '28-FEB-2021'
    
    DORMANT 6005231
    INPO 8186901
    
    '28-FEB-2021'
 Dormant  AC            > 6005231
Inoperative AC        > 8186901
Unclaimed Deposit AC > 1,485,982

 '31-dec-2020' 
Dormant  AC            > 5890666
Inoperative AC        > 8116905
Unclaimed Deposit AC > 1,485,983