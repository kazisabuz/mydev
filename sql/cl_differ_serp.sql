select   GMO_BRANCH                                                 GMO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = GMO_BRANCH)    GMO_NAME,
       PO_BRANCH                                                  PO_CODE,
       (SELECT MBRN_NAME
          FROM MBRN
         WHERE MBRN_ENTITY_NUM = 1 AND MBRN_CODE = PO_BRANCH)     PO_NAME,
       TT.*
from (SELECT mbrn_code,
       mbrn_name,
       IACLINK_CIF_NUMBER                   client_id,
       IACLINK_ACTUAL_ACNUM                 account_no,
       fn_get_ason_acbal (1,
                          IACLINK_INTERNAL_ACNUM,
                          'BDT',
                          '30-JUN-2023',
                          '17-JUL-2023')    acbal
  FROM IACLINK, mbrn
 WHERE     IACLINK_BRN_CODE = mbrn_code
       AND IACLINK_ENTITY_NUM = 1
       AND IACLINK_ENTITY_NUM = 1
       AND IACLINK_ACTUAL_ACNUM IN ('4106674000384',
                                    '4208563000072',
                                    '4208563000077',
                                    '4215051000163',
                                    '4602963000061',
                                    '4619348001348',
                                    '4804421001048',
                                    '4903407002438',
                                    '5611963000024',
                                    '5620102001942',
                                    '5805735019258',
                                    '5805735028647',
                                    '5805735041278',
                                    '5909763000054'))TT, MBRN_TREE
 WHERE TT.MBRN_CODE = BRANCH;



/* Formatted on 7/18/2023 4:47:53 PM (QP5 v5.388) */
SELECT facno (1, ACNTS_INTERNAL_ACNUM) acc_no, ACBAL
  FROM CL_TMP_DATA
 WHERE     ASON_DATE = '30-jun-2023'
 and ACBAL<>0
       AND ACNTS_BRN_CODE IN (SELECT BRANCH
                                FROM MBRN_TREE@dr, MBRN@dr
                               WHERE     BRANCH = MBRN_CODE
                                     AND GMO_BRANCH IN (50995,
                                                        18994,
                                                        46995,
                                                        6999,
                                                        56993))
MINUS
SELECT ACNO, BAL_OUT FROM cl_full_serp@dr
where  BAL_OUT<>0